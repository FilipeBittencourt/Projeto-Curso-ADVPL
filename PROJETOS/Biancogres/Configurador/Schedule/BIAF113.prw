#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF113
@author Tiago Rossini Coradini
@since 05/07/2018
@version 1.0
@description Workflow de pedidos de compra com pendencia de aprovacao
@obs Ticket: 3745
@type Function
/*/

User Function BIAF113()
Local cSQL := ""
Local cQry := GetNextAlias()
Local cCodApr := ""
Local cHtml := ""
Local cItem := ""			
	
	RpcSetType(3)
	RpcSetEnv("01", "01")
		
	cSQL := " SELECT CR_USER, EMP, C7_NUM, A2_NOME, CR_EMISSAO, CR_TOTAL, "
	cSQL += " DATEDIFF(DAY, GETDATE(), DATEADD(DAY, 10, CR_EMISSAO)) AS DIA_REP,"
	cSQL += " CONVERT(VARCHAR(8), DATEADD(DAY, 10, CR_EMISSAO), 112) AS DATA_LIM "
	cSQL += " FROM "
	cSQL += " ( "
	cSQL += " 	SELECT CR_USER, 'Biancogres' AS EMP, C7_NUM, A2_COD+'-'+A2_LOJA+'-'+LTRIM(A2_NOME) AS A2_NOME, "
	cSQL += " 	CASE WHEN "
	cSQL += " 		CASE WHEN CR_YDTINCL = '' THEN CR_EMISSAO ELSE CR_YDTINCL END < '20180725' THEN '20180725' " 
	cSQL += " 		ELSE CASE WHEN CR_YDTINCL = '' THEN CR_EMISSAO ELSE CR_YDTINCL END "
	cSQL += " 	END AS CR_EMISSAO, SUM(CR_TOTAL) AS CR_TOTAL "
	cSQL += " 	FROM "+ RetFullName("SCR", "01") +" SCR "
	cSQL += " 	INNER JOIN "
	cSQL += " 	( "
	cSQL += " 		SELECT C7_NUM, C7_FORNECE, C7_LOJA "
	cSQL += " 		FROM "+ RetFullName("SC7", "01")
	cSQL += " 		WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	cSQL += " 		AND C7_RESIDUO = '' "
	cSQL += " 		AND C7_EMISSAO >= '20180725' "
	cSQL += " 		AND D_E_L_E_T_ = '' "
	cSQL += " 		GROUP BY C7_NUM, C7_FORNECE, C7_LOJA "
	cSQL += " 	) AS SC7 "	
	cSQL += " 	ON CR_NUM = C7_NUM "
	cSQL += " 	INNER JOIN "+ RetFullName("SA2", "01") +" SA2 "
	cSQL += " 	ON C7_FORNECE = A2_COD "
	cSQL += " 	AND C7_LOJA = A2_LOJA	"	
	cSQL += " 	WHERE CR_FILIAL = " + ValToSQL(xFilial("SCR"))
	cSQL += " 	AND CR_TIPO = 'PC' "
	cSQL += " 	AND CR_LIBAPRO = '' "
	cSQL += " 	AND CR_DATALIB = '' "
	cSQL += " 	AND CR_USERLIB = '' "
	cSQL += " 	AND CR_VALLIB = 0 "
	cSQL += " 	AND SCR.D_E_L_E_T_ = '' "
	cSQL += " 	AND A2_FILIAL = " + ValToSQL(xFilial("SA2"))
	cSQL += " 	AND SA2.D_E_L_E_T_ = '' "
	cSQL += " 	GROUP BY CR_USER, C7_NUM, CR_EMISSAO, CR_YDTINCL, A2_COD, A2_LOJA, A2_NOME "

	cSQL += " UNION ALL "

	cSQL += " 	SELECT CR_USER, 'Incesa' AS EMP, C7_NUM, A2_COD+'-'+A2_LOJA+'-'+LTRIM(A2_NOME) AS A2_NOME, "
	cSQL += " 	CASE WHEN "
	cSQL += " 		CASE WHEN CR_YDTINCL = '' THEN CR_EMISSAO ELSE CR_YDTINCL END < '20180725' THEN '20180725' " 
	cSQL += " 		ELSE CASE WHEN CR_YDTINCL = '' THEN CR_EMISSAO ELSE CR_YDTINCL END "
	cSQL += " 	END AS CR_EMISSAO, SUM(CR_TOTAL) AS CR_TOTAL "
	cSQL += " 	FROM "+ RetFullName("SCR", "05") +" SCR "
	cSQL += " 	INNER JOIN "
	cSQL += " 	( "
	cSQL += " 		SELECT C7_NUM, C7_FORNECE, C7_LOJA "
	cSQL += " 		FROM "+ RetFullName("SC7", "05")
	cSQL += " 		WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	cSQL += " 		AND C7_RESIDUO = '' "
	cSQL += " 		AND C7_EMISSAO >= '20180725' "
	cSQL += " 		AND D_E_L_E_T_ = '' "
	cSQL += " 		GROUP BY C7_NUM, C7_FORNECE, C7_LOJA "
	cSQL += " 	) AS SC7 "	
	cSQL += " 	ON CR_NUM = C7_NUM "
	cSQL += " 	INNER JOIN "+ RetFullName("SA2", "05") +" SA2 "
	cSQL += " 	ON C7_FORNECE = A2_COD "
	cSQL += " 	AND C7_LOJA = A2_LOJA "
	cSQL += " 	WHERE CR_FILIAL = " + ValToSQL(xFilial("SCR"))
	cSQL += " 	AND CR_TIPO = 'PC' "
	cSQL += " 	AND CR_LIBAPRO = '' "
	cSQL += " 	AND CR_DATALIB = '' "
	cSQL += " 	AND CR_USERLIB = '' "
	cSQL += " 	AND CR_VALLIB = 0 "
	cSQL += " 	AND SCR.D_E_L_E_T_ = '' "	
	cSQL += " 	AND A2_FILIAL = " + ValToSQL(xFilial("SA2"))
	cSQL += " 	AND SA2.D_E_L_E_T_ = '' "
	cSQL += " 	GROUP BY CR_USER, C7_NUM, CR_EMISSAO, CR_YDTINCL, A2_COD, A2_LOJA, A2_NOME "
	cSQL += " ) AS TMP "	
	cSQL += " WHERE DATEDIFF(DAY, GETDATE(), DATEADD(DAY, 10, CR_EMISSAO)) > 0 "
	cSQL += " ORDER BY CR_USER, EMP, CR_EMISSAO, C7_NUM "	
	 
	TcQuery cSQL New Alias (cQry)
	  			
	cCodApr := (cQry)->CR_USER
	
	While (cQry)->(!Eof())
        	
		While cCodApr == (cQry)->CR_USER
		
			cItem	+= fRetItem(@cQry)
			
			cCodApr := (cQry)->CR_USER
			
			(cQry)->(DbSkip())
			
		EndDo()
					
		cHtml	:= fRetCab()
		cHtml	+= cItem
		cHtml	+= fRetRod()
		
		fSendMail(cCodApr, cHtml)
					
		cItem := ""
		
		If (cQry)->(!Eof())
			
			cCodApr := (cQry)->CR_USER
			
		EndIf		
		
	EndDo()
	
	(cQry)->(dbCloseArea())
			
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
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Pedido </th>
	cRet += '            <th class="styleCabecalho" width="200" scope="col"> Fornecedor </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Emissão </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Valor </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Data Limite p/ Aprovação </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Dia(s) p/ Reprovação Automática </th>			
	cRet += '        </tr>
			
Return(cRet)


Static Function fRetItem(cQry)
Local cRet := ""
Local cCor := If ((cQry)->DIA_REP <= 3, 'style="color: #ff0000"', "")
	
	cRet += '        <tr align=center>
	cRet += '            <th class="styleLinha" width="60" scope="col" '+ cCor +'>' + (cQry)->EMP +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col" '+ cCor +'>' + (cQry)->C7_NUM +' </th>
	cRet += '            <th class="styleLinha" width="200" scope="col" '+ cCor +'>' + (cQry)->A2_NOME +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col" '+ cCor +'>' + dToC(sToD((cQry)->CR_EMISSAO)) +' </th>	
	cRet += '            <th class="styleLinha" width="60" scope="col" '+ cCor +'>' + Transform((cQry)->CR_TOTAL, "@E 999,999,999.99") +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col" '+ cCor +'>' + dToC(sToD((cQry)->DATA_LIM)) +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col" '+ cCor +'>' + cValToChar((cQry)->DIA_REP) +' </th>	
	cRet += '        </tr>
		
Return(cRet)


Static Function fRetRod()
Local cRet := ""

	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td class="styleRodape" width="60" scope="col" colspan="7">
	cRet += '                E-mail enviado automaticamente pelo sistema Protheus (by BIAF113).
	cRet += '            </td>
	cRet += '        </tr>
	cRet += '	</table>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


Static Function fSendMail(cCodApr, cHtml)
Local cMail := AllTrim(UsrRetMail(cCodApr))

	If U_BIAEnvMail(,cMail, "Pedido(s) de compra pendente(s) de aprovação", cHtml)
	
		ConOut("[" + cValToChar(dDataBase) + Space(1) + Time() + "] - BIAF113:fSendMail('"+ cMail +"')")
	
	EndIf
		
Return()