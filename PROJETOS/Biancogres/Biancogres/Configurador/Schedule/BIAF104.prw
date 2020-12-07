#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF104
@author Tiago Rossini Coradini
@since 24/04/2018
@version 1.0
@description Workflow de Pedidos com Sugestão de Lote Recusada 
@obs Ticket: 3598
@type Function
/*/

// Indices das colunas do array
#DEFINE _DesEmp 1
#DEFINE _DatEmi 2
#DEFINE _NomAte 3
#DEFINE _MailAte 4
#DEFINE _NomVen 5
#DEFINE _Cliente 6
#DEFINE _Loja 7
#DEFINE _NomCli 8
#DEFINE _NumPed 9
#DEFINE _ItePed 10
#DEFINE _NumPedLM 11
#DEFINE _Produto 12
#DEFINE _DesPro 13
#DEFINE _QtdVen 14
#DEFINE _NumOp 15
#DEFINE _LotSug 16
#DEFINE _QtdSug 17


User Function BIAF104()
Local cSQL := ""
Local cQry := GetNextAlias()
Local cSC501 := RetFullName("SC5", "01")
Local cSC505 := RetFullName("SC5", "05")
Local cSC601 := RetFullName("SC6", "01")
Local cSC605 := RetFullName("SC6", "05")
Local cPZ001 := RetFullName("PZ0", "01")
Local cPZ005 := RetFullName("PZ0", "05")
Local cNomAte := ""
Local cMailAte := "" 
Local cNomVen := ""
Local cNomCli := ""
Local aPedVen := {}
Local nCount := 1
Local cHtml := ""
Local cItem := ""			
	
	RpcSetType(3)
	RpcSetEnv("01", "01")
	
	cSQL := " SELECT EMPRESA, C5_EMISSAO, ZZI_ATENDE, C5_VEND1, C5_CLIENTE, C5_LOJACLI, C6_NUM, C6_ITEM, PEDIDO_LM, C6_PRODUTO, B1_DESC, C6_QTDVEN, PZ0_OPNUM, C6_YLOTSUG, C6_YQTDSUG "
	cSQL += " FROM "
	cSQL += " ( "
	cSQL += " 	SELECT 'Biancogres' AS EMPRESA, C5_EMISSAO, "
	cSQL += " 	C5_VEND1 = CASE WHEN C5_CLIENTE <> '010064' THEN C5_VEND1 ELSE (SELECT TOP 1 LM.C5_VEND1 FROM SC5070 LM WHERE LM.C5_YPEDORI = SC5.C5_NUM AND LM.C5_YEMPPED = '01' AND LM.D_E_L_E_T_ = '') END, "
	cSQL += " 	C5_CLIENTE = CASE WHEN C5_YCLIORI <> '' THEN C5_YCLIORI ELSE C5_CLIENTE END, "
	cSQL += " 	C5_LOJACLI = CASE WHEN C5_YLOJORI <> '' THEN C5_YLOJORI ELSE C5_LOJACLI END, "
	cSQL += " 	C6_NUM, C6_ITEM, "
	cSQL += " 	PEDIDO_LM = CASE WHEN C5_CLIENTE <> '010064' THEN '' ELSE (SELECT TOP 1 LM.C5_NUM FROM SC5070 LM WHERE LM.C5_YPEDORI = SC5.C5_NUM AND LM.C5_YEMPPED = '01' AND LM.D_E_L_E_T_ = '') END, "
	cSQL += " 	C6_PRODUTO, B1_DESC, C6_QTDVEN, PZ0_OPNUM, C6_YLOTSUG, C6_YQTDSUG, ZZ7_EMP "
	cSQL += " 	FROM " + cSC501 + " SC5 "
	cSQL += " 	INNER JOIN " + cSC601 + " SC6 "
	cSQL += " 	ON C5_FILIAL = SC6.C6_FILIAL "
	cSQL += " 	AND C5_NUM = SC6.C6_NUM "
	cSQL += " 	INNER JOIN " + cPZ001 + " PZ0 "
	cSQL += " 	ON C6_FILIAL = PZ0_FILIAL "
	cSQL += " 	AND C6_NUM = PZ0_PEDIDO "
	cSQL += " 	AND C6_ITEM = PZ0_ITEMPV "
	cSQL += " 	AND C6_PRODUTO = PZ0_CODPRO "
	cSQL += " 	INNER JOIN " + RetSQLName("SB1") + " SB1 "
	cSQL += " 	ON C6_PRODUTO = B1_COD "
	cSQL += " 	INNER JOIN " + RetSQLName("ZZ7") + " ZZ7 "
	cSQL += " 	ON B1_YLINHA = ZZ7_COD "
	cSQL += " 	AND B1_YLINSEQ = ZZ7_LINSEQ "
	cSQL += " 	WHERE C5_FILIAL = " + ValToSQL(xFilial("SC5"))
	cSQL += " 	AND C5_EMISSAO >= " + ValToSQL(DaySub(dDataBase, 1))
	cSQL += " 	AND SC5.D_E_L_E_T_ = '' "
	cSQL += " 	AND C6_YLOTSUG <> '' "
	cSQL += " 	AND SC6.D_E_L_E_T_ = '' "
	cSQL += " 	AND PZ0.D_E_L_E_T_ = '' "
	cSQL += " 	AND SB1.D_E_L_E_T_ = '' "
	cSQL += " 	AND ZZ7.D_E_L_E_T_ = ''	"	
	cSQL += " 	UNION ALL "		 
	cSQL += " 	SELECT 'Incesa' AS EMPRESA, C5_EMISSAO, "
	cSQL += " 	C5_VEND1 = CASE WHEN C5_CLIENTE <> '010064' THEN C5_VEND1 ELSE (SELECT TOP 1 LM.C5_VEND1 FROM SC5070 LM WHERE LM.C5_YPEDORI = SC5.C5_NUM AND LM.C5_YEMPPED = '05' AND LM.D_E_L_E_T_ = '') END, "
	cSQL += " 	C5_CLIENTE = CASE WHEN C5_YCLIORI <> '' THEN C5_YCLIORI ELSE C5_CLIENTE END, "
	cSQL += " 	C5_LOJACLI = CASE WHEN C5_YLOJORI <> '' THEN C5_YLOJORI ELSE C5_LOJACLI END, "
	cSQL += " 	C6_NUM, C6_ITEM, "
	cSQL += " 	PEDIDO_LM = CASE WHEN C5_CLIENTE <> '010064' THEN '' ELSE (SELECT TOP 1 LM.C5_NUM FROM SC5070 LM WHERE LM.C5_YPEDORI = SC5.C5_NUM AND LM.C5_YEMPPED = '05' AND LM.D_E_L_E_T_ = '') END, "
	cSQL += " 	C6_PRODUTO, B1_DESC, C6_QTDVEN, PZ0_OPNUM, C6_YLOTSUG, C6_YQTDSUG, ZZ7_EMP "
	cSQL += " 	FROM " + cSC505 + " SC5 "
	cSQL += " 	INNER JOIN " + cSC605 + " SC6 "
	cSQL += " 	ON C5_FILIAL = SC6.C6_FILIAL "
	cSQL += " 	AND C5_NUM = SC6.C6_NUM "
	cSQL += " 	INNER JOIN " + cPZ005 + " PZ0 "
	cSQL += " 	ON C6_FILIAL = PZ0_FILIAL "
	cSQL += " 	AND C6_NUM = PZ0_PEDIDO "
	cSQL += " 	AND C6_ITEM = PZ0_ITEMPV "
	cSQL += " 	AND C6_PRODUTO = PZ0_CODPRO "
	cSQL += " 	INNER JOIN " + RetSQLName("SB1") + " SB1 "
	cSQL += " 	ON C6_PRODUTO = B1_COD "
	cSQL += " 	INNER JOIN " + RetSQLName("ZZ7") + " ZZ7 "
	cSQL += " 	ON B1_YLINHA = ZZ7_COD "
	cSQL += " 	AND B1_YLINSEQ = ZZ7_LINSEQ "
	cSQL += " 	WHERE C5_FILIAL = " + ValToSQL(xFilial("SC5"))
	cSQL += " 	AND C5_EMISSAO >= " + ValToSQL(DaySub(dDataBase, 1))
	cSQL += " 	AND SC5.D_E_L_E_T_ = '' "
	cSQL += " 	AND C6_YLOTSUG <> '' "
	cSQL += " 	AND SC6.D_E_L_E_T_ = '' "
	cSQL += " 	AND PZ0.D_E_L_E_T_ = '' "
	cSQL += " 	AND SB1.D_E_L_E_T_ = '' "
	cSQL += " 	AND ZZ7.D_E_L_E_T_ = ''	"	
	cSQL += " ) AS PEDVEN "
	cSQL += " INNER JOIN " + RetSQLName("SA1")
	cSQL += " ON C5_CLIENTE = A1_COD "
	cSQL += " AND C5_LOJACLI = A1_LOJA "
	cSQL += " LEFT JOIN VW_SAP_ZZI "
	cSQL += " ON ZZ7_EMP = MARCA "
	cSQL += " AND C5_VEND1 = ZZI_VEND "
	cSQL += " AND A1_YTPSEG = ZZI_TPSEG "
	cSQL += " ORDER BY ZZI_ATENDE, EMPRESA, C5_EMISSAO, C6_NUM, C6_ITEM "		
	
	TcQuery cSQL New Alias (cQry)
	  			
	While (cQry)->(!Eof())			 			
		 
		cNomAte := Capital(AllTrim(UsrFullName((cQry)->ZZI_ATENDE)))
		cMailAte := AllTrim(UsrRetMail((cQry)->ZZI_ATENDE))
		
		If !Empty(cNomAte) .And. !Empty(cMailAte)			
			
			cNomVen := Capital(AllTrim(Posicione("SA3", 1, xFilial("SA3") + (cQry)->C5_VEND1, "A3_NREDUZ")))
			
			cNomCli := Capital(AllTrim(Posicione("SA1", 1, xFilial("SA1") + (cQry)->C5_CLIENTE + (cQry)->C5_LOJACLI, "A1_NOME")))
						
			aAdd(aPedVen, {(cQry)->EMPRESA, dToC(sToD((cQry)->C5_EMISSAO)), cNomAte, cMailAte, cNomVen, (cQry)->C5_CLIENTE, (cQry)->C5_LOJACLI, cNomCli,;
										(cQry)->C6_NUM, (cQry)->C6_ITEM, (cQry)->PEDIDO_LM, AllTrim((cQry)->C6_PRODUTO), AllTrim((cQry)->B1_DESC), cValToChar((cQry)->C6_QTDVEN),;
										AllTrim((cQry)->PZ0_OPNUM), AllTrim((cQry)->C6_YLOTSUG), cValToChar((cQry)->C6_YQTDSUG)})			
	  EndIf
	  
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(dbCloseArea())
	
		
	If !Empty(aPedVen)	
		
		aPedVen := aSort(aPedVen,,, {|x,y| x[_MailAte] + x[_DesEmp] + x[_DatEmi] + x[_NumPed] + x[_ItePed] < ;
																			 y[_MailAte] + y[_DesEmp] + y[_DatEmi] + y[_NumPed] + y[_ItePed] })

    cMailAte := aPedVen[1, _MailAte]
    
    While nCount <= Len(aPedVen)
    	
			While nCount <= Len(aPedVen) .And. cMailAte == aPedVen[nCount, _MailAte]
			
				cItem	+= fRetItem(aPedVen[nCount])
				
				cMailAte := aPedVen[nCount, _MailAte]
				
				nCount++
				
			EndDo()
						
			cHtml	:= fRetCab()
			cHtml	+= cItem
			cHtml	+= fRetRod()
			
			fSendMail(cMailAte, cHtml)
						
			cItem := ""
			
			If nCount <= Len(aPedVen)
				cMailAte := aPedVen[nCount, _MailAte]
			EndIf
    	    	
    EndDo()
    
	EndIf
			
	RpcClearEnv()
		
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

	cRet += '    <table class="styleTable" align="center">
	
	cRet += '        <tr align=center>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Empresa </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Emissão </th>
	cRet += '            <th class="styleCabecalho" width="200" scope="col"> Atendente </th>
	cRet += '            <th class="styleCabecalho" width="200" scope="col"> Representante </th>
	cRet += '            <th class="styleCabecalho" width="300" scope="col"> Cliente </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Pedido </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Item </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Pedido LM </th>
	cRet += '            <th class="styleCabecalho" width="300" scope="col"> Produto </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Quantidade </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Num. OP </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Lote Sugerido </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Qtd. Lt. Sugerido </th>
	
	cRet += '        </tr>
			
Return(cRet)


Static Function fRetItem(aPedVen)
Local cRet := ""
		
	cRet += '        <tr align=center>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_DesEmp] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_DatEmi] +' </th>
	cRet += '            <th class="styleLinha" width="200" scope="col"> '+ aPedVen[_NomAte] +' </th>
	cRet += '            <th class="styleLinha" width="200" scope="col"> '+ aPedVen[_NomVen] +' </th>	
	cRet += '            <th class="styleLinha" width="300" scope="col"> '+ aPedVen[_Cliente] + " - " + aPedVen[_Loja] + " - " + aPedVen[_NomCli] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_NumPed] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_ItePed] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_NumPedLM] +' </th>
	cRet += '            <th class="styleLinha" width="300" scope="col"> '+ aPedVen[_Produto] + " - " + aPedVen[_DesPro] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_QtdVen] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_NumOp] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_LotSug] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aPedVen[_QtdSug] +' </th>
	cRet += '        </tr>
		
Return(cRet)


Static Function fRetRod()
Local cRet := ""

	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td class="styleRodape" width="60" scope="col" colspan="13">
	cRet += '                E-mail enviado automaticamente pelo sistema Protheus (by BIAF104).
	cRet += '            </td>
	cRet += '        </tr>
	cRet += '	</table>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


Static Function fSendMail(cMail, cHtml)
			
	cMail += ";" + U_EmailWF("BIAF104", cEmpAnt)
	
	If U_BIAEnvMail(, cMail, "Pedidos com Sugestão de Lote Recusada", cHtml)
	
		ConOut("[" + cValToChar(dDataBase) + Space(1) + Time() + "] - BIAF104:fSendMail('"+ cMail +"')")
	
	EndIf
		
Return()