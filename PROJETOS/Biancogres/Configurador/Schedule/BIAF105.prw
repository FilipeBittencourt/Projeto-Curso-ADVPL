#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF105
@author Tiago Rossini Coradini
@since 04/05/2018
@version 1.0
@description Rotina para liberação automatica de pedidos de venda com bloqueio de contrato 
@obs Ticket: 3599
@type Function
/*/

// Indices das colunas do array de pedidos
#DEFINE _NumPed 1
#DEFINE _CodCli 2
#DEFINE _LojCli 3
#DEFINE _EmpOri 4
#DEFINE _PedOri 5
#DEFINE _ItePed 6
#DEFINE _CodPrd 7
#DEFINE _QtdLib 8
#DEFINE _PrcVen 9

User Function BIAF105()
Local aEmp := {}
Local nCount := 0
Local cSQL := ""
Local cQry := GetNextAlias()
Private aPedido := {}

	aAdd(aEmp, "01")
	aAdd(aEmp, "05")
	aAdd(aEmp, "07")
	
	For nCount := 1 To Len(aEmp)
			
		aPedido := {}
		
		RpcSetType(3)
		RpcSetEnv(aEmp[nCount], "01")
	
		cSQL := " SELECT C5_YEMPPED, C5_YPEDORI, ZN_PEDIDO, ZN_CLIENTE, ZN_LOJA, A1_GRPVEN, A1_YTIPOLC, SZN.R_E_C_N_O_ AS RECNO "
		cSQL += " FROM " + RetSQLName("SZN") + " SZN "
		cSQL += " INNER JOIN " + RetSQLName("SC5") + " SC5 "
		cSQL += " ON ZN_FILIAL = C5_FILIAL "
		cSQL += " AND ZN_PEDIDO = C5_NUM "
		cSQL += " AND ZN_CLIENTE = C5_CLIENTE "
		cSQL += " AND ZN_LOJA = C5_LOJACLI "
		cSQL += " INNER JOIN " + RetSQLName("SA1") + " SA1 "
		cSQL += " ON ZN_CLIENTE = A1_COD "
		cSQL += " AND ZN_LOJA = A1_LOJA "
		cSQL += " WHERE ZN_FILIAL = " + ValToSQL(xFilial("SZN"))
		cSQL += " AND ZN_TIPO = '2' "
		cSQL += " AND ZN_BLQPDCT = 'S' "
		cSQL += " AND SZN.D_E_L_E_T_ = '' "
		cSQL += " AND C5_NOTA = '' "
		cSQL += " AND C5_LIBEROK NOT IN ('E') " 
		cSQL += " AND C5_BLQ = '' "
		cSQL += " AND SC5.D_E_L_E_T_ = '' "
		cSQL += " AND A1_FILIAL = '' "
		cSQL += " AND SA1.D_E_L_E_T_ = '' "
		cSQL += " ORDER BY ZN_DATALIM "			
		
		TcQuery cSQL New Alias (cQry)
		
		While !(cQry)->(Eof())
			
			// Verifica se existe titulos em aberto
			If !fTitAberto((cQry)->ZN_CLIENTE, (cQry)->ZN_LOJA, (cQry)->A1_GRPVEN, (cQry)->A1_YTIPOLC)
				
				// Analisa se libera pedido de contrato
				If fLibContrato((cQry)->C5_YEMPPED, (cQry)->C5_YPEDORI, (cQry)->ZN_PEDIDO, (cQry)->ZN_CLIENTE, (cQry)->ZN_LOJA)
				
					// Atualiza liberacao de contrato
					fAtuContrato((cQry)->C5_YEMPPED, (cQry)->C5_YPEDORI, (cQry)->ZN_PEDIDO, (cQry)->RECNO)
					
				EndIf
								
			EndIf				
			
			(cQry)->(DbSkip())
								
		EndDo()
		
		(cQry)->(DbCloseArea())
		
		// Workflow de pedidos de contrato liberados automaticamente
		fEnviaWF(aPedido)
		
		RpcClearEnv()
		
	Next
		
Return()


Static Function fTitAberto(cCliente, cLoja, cGrpVen, cTipLc)
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(SUM(E1_SALDO), 0) E1_SALDO "
	cSQL += " FROM "
	cSQL += " ( "

	cSQL += " SELECT E1_SALDO, E1_CLIENTE, E1_LOJA "
	cSQL += " FROM " + RetFullName("SE1", "01")
	cSQL += " WHERE	E1_FILIAL	= " + ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_YCLASSE = '2' "
	cSQL += " AND E1_SALDO > 0 "
	cSQL += " AND E1_VENCTO < CONVERT(VARCHAR, GETDATE(), 112) "
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "

	cSQL += " SELECT E1_SALDO, E1_CLIENTE, E1_LOJA "
	cSQL += " FROM " + RetFullName("SE1", "05")
	cSQL += " WHERE	E1_FILIAL	= " + ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_YCLASSE = '2' "
	cSQL += " AND E1_SALDO > 0 "
	cSQL += " AND E1_VENCTO < CONVERT(VARCHAR, GETDATE(), 112) "
	cSQL += " AND D_E_L_E_T_ = '' "
	
	cSQL += " UNION ALL "	

	cSQL += " SELECT E1_SALDO, E1_CLIENTE, E1_LOJA "
	cSQL += " FROM " + RetFullName("SE1", "07")
	cSQL += " WHERE	E1_FILIAL	= " + ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_YCLASSE = '2' "
	cSQL += " AND E1_SALDO > 0 "
	cSQL += " AND E1_VENCTO < CONVERT(VARCHAR, GETDATE(), 112) "
	cSQL += " AND D_E_L_E_T_ = '' "

	cSQL += " ) AS SE1 "	
	cSQL += " INNER JOIN " + RetSQLName("SA1")
	cSQL += " ON E1_CLIENTE = A1_COD "
	cSQL += " AND E1_LOJA = A1_LOJA "
	cSQL += " WHERE A1_FILIAL = ''
	
	If Empty(cGrpVen)
		
		cSQL += " AND A1_COD = " + ValToSQL(cCliente)
		cSQL += " AND A1_LOJA	= " + ValToSQL(cLoja)
	
	Else
		
		cSQL += " AND A1_GRPVEN = " + ValToSQL(cGrpVen) 
		cSQL += " AND A1_YTIPOLC = " + ValToSQL(cTipLc)
		
	EndIf
			
	cSQL += " AND D_E_L_E_T_ = ''
		
	TcQuery cSQL New Alias (cQry)
	
	If (cQry)->E1_SALDO > 0
		
		lRet := .T.
		
	EndIf
		
	(cQry)->(DbCloseArea())
		
Return(lRet)


Static Function fLibContrato(cEmpOri, cPedOri, cNumPed, cCodCli, cLojCli)
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT C9_CLIENTE, C9_LOJA, C6_YDTNECE, C9_ITEM, C9_PRODUTO, C9_QTDLIB, C9_PRCVEN, SC9.R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + If (!Empty(cEmpOri), RetFullName("SC6", cEmpOri), RetSQLName("SC6")) + " SC6 "
	cSQL += " INNER JOIN " + If (!Empty(cEmpOri), RetFullName("SC9", cEmpOri), RetSQLName("SC9")) + " SC9 "
	cSQL += " ON C6_FILIAL = C9_FILIAL " 
	cSQL += " AND C6_NUM = C9_PEDIDO "
	cSQL += " AND C6_PRODUTO = C9_PRODUTO "
	cSQL += " AND C6_ITEM	= C9_ITEM "
	cSQL += " WHERE C6_FILIAL	= " + ValToSQL(xFilial("SC6"))
	cSQL += " AND C6_NUM = " + ValToSQL(If (!Empty(cPedOri), cPedOri, cNumPed))
	cSQL += " AND SC6.D_E_L_E_T_ = '' "
	cSQL += " AND C9_YDTBLCT <> '' "
	cSQL += " AND C9_YDTLICT = '' "
	cSQL += " AND SC9.D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())	
	
		If (cQry)->C6_YDTNECE < dToS(dDataBase)
			
			lRet := .T.
		
			cSQL := " UPDATE " + If (!Empty(cEmpOri), RetFullName("SC9", cEmpOri), RetSQLName("SC9")) 
			cSQL += " SET C9_YDTLICT = " + ValToSQL(dDataBase) + ", C9_MSEXP = '' " 
			cSQL += " WHERE	C9_FILIAL = " + ValToSQL(xFilial("SC6"))
			cSQL += "	AND R_E_C_N_O_ = " + ValToSQL((cQry)->RECNO) 				
			cSQL += "	AND D_E_L_E_T_ = '' "	
			
			TCSQLExec(cSQL)
			
			aAdd(aPedido, {cNumPed, cCodCli, cLojCli, cEmpOri, cPedOri, (cQry)->C9_ITEM, (cQry)->C9_PRODUTO, (cQry)->C9_QTDLIB, (cQry)->C9_PRCVEN})
			
		EndIf
		
		(cQry)->(DbSkip())
		
	EndDo()
		
	(cQry)->(DbCloseArea())

Return(lRet)


Static Function fAtuContrato(cEmpOri, cPedOri, cNumPed, nRecno)
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(COUNT(SC9.C9_PEDIDO), 0) COUNT "	
	cSQL += " FROM " + If (!Empty(cEmpOri), RetFullName("SC6", cEmpOri), RetSQLName("SC6")) + " SC6 "
	cSQL += " INNER JOIN " + If (!Empty(cEmpOri), RetFullName("SC9", cEmpOri), RetSQLName("SC9")) + " SC9 "
	cSQL += " ON C6_FILIAL = C9_FILIAL " 
	cSQL += " AND C6_NUM = C9_PEDIDO "
	cSQL += " AND C6_PRODUTO = C9_PRODUTO "
	cSQL += " AND C6_ITEM	= C9_ITEM "
	cSQL += " WHERE C6_FILIAL	= " + ValToSQL(xFilial("SC6"))
	cSQL += " AND C6_NUM = " + ValToSQL(If (!Empty(cPedOri), cPedOri, cNumPed))
	cSQL += " AND SC6.D_E_L_E_T_ = '' "
	cSQL += " AND C9_YDTBLCT <> '' "
	cSQL += " AND C9_YDTLICT = '' "
	cSQL += " AND SC9.D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	
	If (cQry)->COUNT == 0
	
		cSQL := " UPDATE " + RetSQLName("SZN") 
		cSQL += " SET ZN_BLQPDCT = 'N' "
		cSQL += " WHERE	ZN_FILIAL = " + ValToSQL(xFilial("SZN"))
		cSQL += "	AND R_E_C_N_O_ = " + ValToSQL(nRecno) 				
		cSQL += "	AND D_E_L_E_T_ = '' "	
		
		TCSQLExec(cSQL)
		
	EndIf
				
	(cQry)->(DbCloseArea())

Return()


Static Function fEnviaWF(aPedido)
Local nCount := 1
Local cItem := ""
Local cHtml := ""

	If Len(aPedido) > 0
	
		While nCount <= Len(aPedido)
		
			cItem	+= fRetItem(aPedido[nCount])		
		
			nCount++
			
		EndDo()
		
		cHtml	:= fRetCab()
		cHtml	+= cItem
		cHtml	+= fRetRod()
		
		fSendMail(cHtml)
				
	EndIf 

Return()


Static Function fRetCab()
Local cRet := ""

	cRet := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cRet += '<html xmlns="http://www.w3.org/1999/xhtml">
	cRet += '<head>
	cRet += '    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cRet += '    <title>Workflow</title>
	cRet += '    <style type="text/css">
	cRet += '        <!-- 
	cRet += '		.styleTable{
	cRet += '			border:0;
	cRet += '			cellpadding:3;
	cRet += '			cellspacing:2;
	cRet += '			width:100%;
	cRet += '		}
	cRet += '		.styleTableCabecalho{
	cRet += '            background: #fff;
	cRet += '            color: #ffffff;
	cRet += '            font: 14px Arial, Helvetica, sans-serif;
	cRet += '			font-weight: bold;
	cRet += '		}
	cRet += '        .styleCabecalho{
	cRet += '            background: #0c2c65;
	cRet += '            color: #ffffff;
	cRet += '            font: 12px Arial, Helvetica, sans-serif;
	cRet += '			font-weight: bold;
	cRet += '			padding: 5px;
	cRet += '        }
	cRet += '		.styleLinha{
	cRet += '            background: #f6f6f6;
	cRet += '            color: #747474;
	cRet += '            font: 11px Arial, Helvetica, sans-serif;
	cRet += '			padding: 5px;
	cRet += '        }
	cRet += '        .styleRodape{
	cRet += '            background: #0c2c65;
	cRet += '            color: #ffffff;
	cRet += '            font: 12px Arial, Helvetica, sans-serif;
	cRet += '			font-weight: bold;
	cRet += '			text-align: center;
	cRet += '			padding: 5px;
	cRet += '        }
	cRet += '		.styleLabel{
	cRet += '			color:#0c2c65;
	cRet += '		}
	cRet += '		.styleValor{
	cRet += '			color:#747474;
	cRet += '		}
	cRet += '        -->
	cRet += '    </style>
	cRet += '</head>
	cRet += '<body>
	cRet += '    <table class="styleTable">	
	cRet += '        <tr>
	cRet += '            <th class="styleCabecalho" width="60" scope="col" colspan="9" style="font-size: 18px"> '+ Upper(SM0->M0_NOMECOM) +' </th>
	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <th class="styleCabecalho" width="60" scope="col" colspan="9" align="left"> Pedido(s) de contrato liberado(s) automaticamente </th>
	cRet += '        </tr>	
	cRet += '        <tr>
	cRet += '            <th class="styleCabecalho" width="60" scope="col" align="left"> Pedido </th>
	cRet += '            <th class="styleCabecalho" width="250" scope="col" align="left"> Cliente </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col" align="left"> Emp. Origem </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col" align="left"> Ped. Origem </th>	
	cRet += '            <th class="styleCabecalho" width="40" scope="col" align="left"> Item </th>
	cRet += '            <th class="styleCabecalho" width="250" scope="col" align="left"> Produto </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col" align="right"> Quantidade </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col" align="right"> Preço </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col" align="right"> Total </th>	
	cRet += '        </tr>		
				
Return(cRet)


Static Function fRetItem(aPedido)
Local cRet := ""
Local cCliente := ""
Local cEmpOri := ""
Local cProduto := ""
Local nVlrTot := 0
		
	cCliente := aPedido[_CodCli] + "-" + aPedido[_LojCli] + "-" + AllTrim(Posicione("SA1", 1, xFilial("SA1") + aPedido[_CodCli] + aPedido[_LojCli], "A1_NOME"))
	cEmpOri := Capital(FWEmpName(aPedido[_EmpOri]))
	cProduto := AllTrim(aPedido[_CodPrd]) + "-" + AllTrim(Posicione("SB1", 1, xFilial("SB1") + aPedido[_CodPrd], "B1_DESC"))
	nVlrTot := Round(aPedido[_QtdLib] * aPedido[_PrcVen], 2)		
	
	cRet := '	<tr>
	cRet += '			<th class="styleLinha" width="60" scope="col" align="left"> '+ aPedido[_NumPed] +' </th>	
	cRet += '			<th class="styleLinha" width="250" scope="col" align="left"> '+ cCliente +' </th>
	cRet += '			<th class="styleLinha" width="60" scope="col" align="left"> '+ cEmpOri +' </th>
	cRet += '			<th class="styleLinha" width="60" scope="col" align="left"> '+ aPedido[_PedOri] +' </th>	
	cRet += '			<th class="styleLinha" width="40" scope="col" align="left"> '+ aPedido[_ItePed] +' </th>	
	cRet += '			<th class="styleLinha" width="250" scope="col" align="left"> '+ cProduto +' </th>
	cRet += '			<th class="styleLinha" width="60" scope="col" align="right"> '+ cValToChar(aPedido[_QtdLib]) +' </th>
	cRet += '			<th class="styleLinha" width="60" scope="col" align="right"> '+ cValToChar(aPedido[_PrcVen]) +' </th>
	cRet += '			<th class="styleLinha" width="60" scope="col" align="right"> '+ cValToChar(nVlrTot) +' </th>	
	cRet += '	</tr>
	
Return(cRet)


Static Function fRetRod()
Local cRet := ""

	cRet += '	<tr>
	cRet += '		<td class="styleRodape" width="60" scope="col" colspan="9">
	cRet += '			E-mail enviado automaticamente pelo sistema Protheus (by BIAF105).
	cRet += '   </td>
	cRet += '	</tr>
	
	cRet += '</table>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


Static Function fSendMail(cHtml)
Local cMail := AllTrim(U_EmailWF('BIAF105', cEmpAnt))
				
	If U_BIAEnvMail(, cMail, "Liberação de Pedidos de Contrato", cHtml)
	
		ConOut("[" + cValToChar(dDataBase) + Space(1) + Time() + "] - BIAF105:fSendMail('"+ cMail +"')")
	
	EndIf
		
Return()