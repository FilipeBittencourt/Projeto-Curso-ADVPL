#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF116
@author Tiago Rossini Coradini
@since 30/07/2018
@version 1.0
@description Envia workflow de recebimento de materiais
@obs Ticket: 7061
@type Function
/*/

// Indices das colunas do array de solicitações de compra
#DEFINE _MailSol 1
#DEFINE _CodSol 2
#DEFINE _NomEmp 3
#DEFINE _Local 4
#DEFINE _NumBiz 5
#DEFINE _NumSol 6
#DEFINE _NumPed 7
#DEFINE _CodPrd 8
#DEFINE _DesPrd 9
#DEFINE _Quant 10
#DEFINE _UM 11
#DEFINE _Valor 12
#DEFINE _Tag 13
#DEFINE _Clvl 14
#DEFINE _DtDigit 15
#DEFINE _MD 16


User Function BIAF116(nOpc, nConfirm)
Local cSQL := ""
Local cQry := GetNextAlias()
Local cHtml := ""
Local cItem := ""
Local cMailSol := ""
Local aSolCom := {}
Local nCount := 1
Local aArea := GetArea()
Local cBizagi := U_fGetBase("2") 

	If cEmpAnt $ "01/05" .And. SF1->F1_TIPO == "N" .And. nConfirm == 1 .And. (nOpc >= 3 .And. nOpc <= 4)
	
		cSQL := " SELECT ISNULL(EMAIL, '') AS EMAIL, C1_USER, "+ ValToSQL(Capital(FWEmpName(cEmpAnt))) +" AS EMP, C1_YBIZAGI, C1_NUM, C1_PEDIDO, "
		cSQL += " C1_PRODUTO, C1_DESCRI, D1_QUANT, D1_UM, D1_VUNIT, D1_YTAG, D1_CLVL, D1_DTDIGIT, D1_LOCAL, ZCN_MD "
		cSQL += " FROM "+ RetSQLName("SD1") +" SD1 "
		cSQL += " INNER JOIN "+ RetSQLName("SA2") +" SA2 "
		cSQL += " ON D1_FORNECE = A2_COD "
		cSQL += " AND D1_LOJA = A2_LOJA "
		cSQL += " AND SA2.D_E_L_E_T_ = '' "
		cSQL += " AND A2_FILIAL = " + ValToSQL(xFilial("SA2"))
		cSQL += " INNER JOIN "+ RetSQLName("SC7") +" SC7 "
		cSQL += " ON D1_PEDIDO = C7_NUM "
		cSQL += " AND D1_ITEMPC = C7_ITEM "
		cSQL += " AND SC7.D_E_L_E_T_ = '' "
		cSQL += " AND C7_FILIAL = " + ValToSQL(xFilial("SC7"))	
		cSQL += " INNER JOIN "+ RetSQLName("SC1") +" SC1 "
		cSQL += " ON C7_NUMSC = C1_NUM "
		cSQL += " AND C7_ITEMSC = C1_ITEM "
		cSQL += " AND SC1.D_E_L_E_T_ = '' "
		cSQL += " AND C1_FILIAL = " + ValToSQL(xFilial("SC1"))
		cSQL += " INNER JOIN "+ RetSQLName("ZCN") +" ZCN "
		cSQL += " ON C1_PRODUTO = ZCN_COD "
		cSQL += " AND C1_LOCAL = ZCN_LOCAL "
		cSQL += " AND ZCN.D_E_L_E_T_ = '' "
		cSQL += " AND ZCN_FILIAL = " + ValToSQL(xFilial("ZCN"))
		cSQL += " LEFT JOIN "+cBizagi+".dbo.BZ_DADOS_SC SC_BIZ " 
		cSQL += " ON BIZAGI COLLATE Latin1_General_BIN = C1_YBIZAGI "
		cSQL += " AND PROTHEUS COLLATE Latin1_General_BIN = C1_NUM "
		cSQL += " AND EMPRESA = " + ValToSQL(cEmpAnt + "01")
		cSQL += " WHERE D1_FILIAL = "+ ValToSQL(xFilial("SD1"))
		cSQL += " AND D1_DOC = "+ ValToSQL(SF1->F1_DOC)	
		cSQL += " AND D1_SERIE = "+ ValToSQL(SF1->F1_SERIE)
		cSQL += " AND D1_FORNECE = "+ ValToSQL(SF1->F1_FORNECE)
		cSQL += " AND D1_LOJA = "+ ValToSQL(SF1->F1_LOJA)
		cSQL += " AND D1_TIPO = 'N' "
		cSQL += " AND SD1.D_E_L_E_T_ = '' "
		cSQL += " AND C1_NUM <> '' "		
		cSQL += " ORDER BY EMAIL, C1_USER, BIZAGI, C1_NUM, C7_NUM, C1_DESCRI "

		TcQuery cSQL New Alias (cQry)
		
		While (cQry)->(!Eof())			 			
			 
			cMailSol := AllTrim((cQry)->EMAIL)
			
			If Empty(cMailSol)
			
				cMailSol := AllTrim(UsrRetMail((cQry)->C1_USER))
			
			EndIf
			
			If !Empty(cMailSol)

				aAdd(aSolCom, {cMailSol, (cQry)->C1_USER, (cQry)->EMP, (cQry)->D1_LOCAL, (cQry)->C1_YBIZAGI, (cQry)->C1_NUM, (cQry)->C1_PEDIDO, AllTrim((cQry)->C1_PRODUTO), AllTrim((cQry)->C1_DESCRI),;
										 cValToChar((cQry)->D1_QUANT), (cQry)->D1_UM, cValToChar((cQry)->D1_VUNIT), (cQry)->D1_YTAG, (cQry)->D1_CLVL, dToC(sToD((cQry)->D1_DTDIGIT)), (cQry)->ZCN_MD})											
				
		  EndIf
		  
			(cQry)->(DbSkip())
			
		EndDo()

		(cQry)->(DbCloseArea())
		
		
		If !Empty(aSolCom)
			
			aSolCom := aSort(aSolCom,,, {|x,y| x[_MailSol] < y[_MailSol]})
	
	    cMailSol := aSolCom[1, _MailSol]
	    
	    While nCount <= Len(aSolCom)
	    	
				While nCount <= Len(aSolCom) .And. cMailSol == aSolCom[nCount, _MailSol]
				
					cItem	+= fRetItem(aSolCom[nCount])
					
					cMailSol := aSolCom[nCount, _MailSol]
					
					nCount++
					
				EndDo()
							
				cHtml	:= fRetCab()
				cHtml	+= cItem
				cHtml	+= fRetRod()
				
				cAssunto := "Recebimento de Material"
				/*
				if aSolCom[_MD] == 'S'
				  cAssunto := "Recebimento de Material - RETIRADA IMEDIATA"
				endif
				*/
 				if Len(aSolCom) == _MD .And. aSolCom[_MD] == 'S'
					cAssunto := "Recebimento de Material - RETIRADA IMEDIATA"
				endif

				fSendMail(cMailSol, cHtml, cAssunto)
							
				cItem := ""
				
				If nCount <= Len(aSolCom)
					cMailSol := aSolCom[nCount, _MailSol]
				EndIf
	    	    	
	    EndDo()
	    
		EndIf
		
		
		RestArea(aArea)	
		
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
	cRet += '    <table class="styleTable" align="center">	
	cRet += '        <tr align=center>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Empresa </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Local </th>	
	cRet += '            <th class="styleCabecalho" width="85" scope="col"> SC Bizagi </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> SC </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Pedido </th>
	cRet += '            <th class="styleCabecalho" width="250" scope="col"> Produto </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Quantidade </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> UM </th>	
	cRet += '            <th class="styleCabecalho" width="85" scope="col"> Valor </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Tag </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Clvl </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Dt. Entrada </th>
	cRet += '        </tr>
			
Return(cRet)


Static Function fRetItem(aSolCom)
Local cRet := ""
	
	cRet += '        <tr align=center>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_NomEmp] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_Local] +' </th>
	cRet += '            <th class="styleLinha" width="85" scope="col"> '+ aSolCom[_NumBiz] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_NumSol] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_NumPed] +' </th>	
	cRet += '            <th class="styleLinha" width="250" scope="col"> '+ aSolCom[_CodPrd] + " - " + aSolCom[_DesPrd] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_Quant] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_UM] +' </th>
	cRet += '            <th class="styleLinha" width="85" scope="col"> '+ aSolCom[_Valor] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_Tag] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_Clvl] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> '+ aSolCom[_DtDigit] +' </th>		
	cRet += '        </tr>

Return(cRet)


Static Function fRetRod()
Local cRet := ""

	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td class="styleRodape" width="60" scope="col" colspan="12">
	cRet += '                E-mail enviado automaticamente pelo sistema Protheus (by BIAF116).
	cRet += '            </td>
	cRet += '        </tr>
	cRet += '	</table>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


Static Function fSendMail(cMail, cHtml, cAssunto)
			
	If U_BIAEnvMail(,cMail, cAssunto, cHtml)
	
		ConOut("[" + cValToChar(dDataBase) + Space(1) + Time() + "] - BIAF116:fSendMail('"+ cMail +"')")
	
	EndIf
		
Return()
