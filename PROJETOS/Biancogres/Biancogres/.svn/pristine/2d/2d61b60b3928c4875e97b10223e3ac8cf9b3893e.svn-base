#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF107
@author Tiago Rossini Coradini
@since 15/05/2018
@version 1.0
@description Workflow para os fornecedores que participaram e não ganharam a cotação de compra 
@obs Ticket: 3748
@type Function
/*/

User Function BIAF107(cNumCot)
Local cSQL := ""
Local cQry := GetNextAlias()
Local cCodFor := ""
Local cItem := ""
Local cHtml := ""
	
	cSQL := " SELECT C8_NUM, C8_FORNECE, C8_LOJA, LTRIM(C8_FORNOME) AS C8_FORNOME, LTRIM(C8_FORMAIL) AS C8_FORMAIL, C8_PRODUTO, B1_DESC, C8_QUANT "
	cSQL += " FROM "+ RetSQLName("SC8") +" SC8 "
	cSQL += " INNER JOIN "+ RetSQLName("SB1") +" SB1 "
	cSQL += " ON C8_PRODUTO = B1_COD "
	cSQL += " WHERE C8_FILIAL = "+ ValToSQL(xFilial("SC8")) 
	cSQL += " AND C8_NUM = "+ ValToSQL(cNumCot)
	cSQL += " AND NOT EXISTS "
	cSQL += " ( "
	cSQL += " 	SELECT C8_NUM "
	cSQL += " 	FROM "+ RetSQLName("SC8")
	cSQL += " 	WHERE C8_FILIAL = SC8.C8_FILIAL "
	cSQL += " 	AND C8_NUM = SC8.C8_NUM "
	cSQL += " 	AND C8_ITEM = SC8.C8_ITEM "
	cSQL += " 	AND C8_FORNECE = SC8.C8_FORNECE "
	cSQL += " 	AND C8_LOJA = SC8.C8_LOJA "
	cSQL += " 	AND C8_NUMPED <> 'XXXXXX' "
	cSQL += " 	AND C8_ITEMPED <> 'XXXX' "
	cSQL += " 	AND D_E_L_E_T_ = ''	"
	cSQL += " ) "
	cSQL += " AND SC8.D_E_L_E_T_ = '' "
	cSQL += " AND B1_FILIAL = "+ ValToSQL(xFilial("SB1"))
	cSQL += " AND SB1.D_E_L_E_T_ = '' "
	cSQL += " GROUP BY C8_NUM, C8_FORNECE, C8_LOJA, C8_FORNOME, C8_FORMAIL, C8_PRODUTO, B1_DESC, C8_QUANT "
	cSQL += " ORDER BY C8_FORNECE, C8_LOJA, C8_PRODUTO "

	TcQuery cSQL New Alias (cQry)
	  			
	cCodFor := (cQry)->C8_FORNECE
	
	While !(cQry)->(Eof())
		 
		While cCodFor == (cQry)->C8_FORNECE
		
			cItem	+= fRetItem((cQry)->C8_PRODUTO, (cQry)->B1_DESC, (cQry)->C8_QUANT)
			
			cCodFor := (cQry)->C8_FORNECE
			
			(cQry)->(DbSkip())
			
		EndDo()
					
		cHtml	:= fRetCab((cQry)->C8_FORNOME, cNumCot)
		cHtml	+= cItem
		cHtml	+= fRetRod()
		
		fSendMail((cQry)->C8_FORMAIL, cHtml)
					
		cItem := ""
		
		If !(cQry)->(Eof())
			cCodFor := (cQry)->C8_FORNECE
		EndIf    	    		
		
	EndDo()
	
	(cQry)->(dbCloseArea())
	
Return()


Static Function fRetCab(cNomFor, cNumCot)
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
	cRet += '            <th class="styleCabecalho" width="60" scope="col" colspan="2" style="font-size: 18px"> '+ Upper(SM0->M0_NOMECOM) +' </th>
	cRet += '        </tr>	        
	cRet += '        <tr>
	cRet += '            <th class="styleCabecalho" width="60" scope="col" colspan="2" align="left"> Prezado fornecedor: '+ Upper(AllTrim(cNomFor)) +' </th>
	cRet += '        </tr>	
	cRet += '        <tr>
	cRet += '            <th class="styleLinha" width="60" scope="col" colspan="2" align="left"> 
	cRet += '							<p> Vimos por meio desta agradecer a participação de sua empresa na concorrência dos produtos/serviços da cotação supra citada. </p>							 
	cRet += '							<p> Após análise das propostas, e pautados por critérios técnico-comerciais, optamos por contratar outra empresa para a essa cotação. </p>
	cRet += '							<p> Certos de sua compreensão, agradecemos a prontidão em nos atender, e contamos com a sua participação para novas cotações em outras oportunidades. </p>							
	cRet += '            </th>
	cRet += '        </tr>	        
	cRet += '        <tr>
	cRet += '            <th class="styleCabecalho" width="60" scope="col" colspan="2" align="left"> Número da Cotação: '+ cNumCot +' </th>
	cRet += '        </tr>	        
	cRet += '        <tr>
	cRet += '            <th class="styleCabecalho" width="300" scope="col" align="left"> Produto </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col" align="right"> Quantidade </th>		
	cRet += '        </tr>		
				
Return(cRet)


Static Function fRetItem(cProduto, cDesc, nQtd)
Local cRet := ""
		
	cRet := '	<tr>
	cRet += '			<th class="styleLinha" width="300" scope="col" align="left"> '+ AllTrim(cProduto) + "-" + AllTrim(cDesc) +' </th>
	cRet += '			<th class="styleLinha" width="60" scope="col" align="right"> '+ cValToChar(nQtd) +' </th>
	cRet += '	</tr>
	
Return(cRet)


Static Function fRetRod()
Local cRet := ""

	cRet += '	<tr>
	cRet += '		<td class="styleRodape" width="60" scope="col" colspan="2">
	cRet += '			E-mail enviado automaticamente pelo sistema Protheus (by BIAF107).
	cRet += '   </td>
	cRet += '	</tr>
	
	cRet += '</table>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


Static Function fSendMail(cMail, cHtml)
				
	If U_BIAEnvMail(, cMail, "Obrigado pela participação", cHtml)
	
		ConOut("[" + cValToChar(dDataBase) + Space(1) + Time() + "] - BIAF107:fSendMail('"+ cMail +"')")
	
	EndIf
		
Return()