#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF114
@author Tiago Rossini Coradini
@since 16/07/2018
@version 1.0
@description Workflow de pedidos de compra que foram excluidos (Eliminação de residuo) por pendencia de aprovacao
@obs Ticket: 3745
@type Function
/*/

// Indices das colunas do array de pedidos
#DEFINE _CodApr 1
#DEFINE _NomEmp 2
#DEFINE _NumPed 3
#DEFINE _CodCom 4
#DEFINE _NumBiz 5
#DEFINE _NumSol 6
#DEFINE _CodSol 7
#DEFINE _MailSol 8
#DEFINE _NomFor 9
#DEFINE _DatEmi 10
#DEFINE _Valor 11


User Function BIAF114()
Local aEmp := {}
Local nCount := 0
Local cSQL := ""
Local cQry := GetNextAlias()
Local aPedCom := {}
Local cBizagi := ""	
	
	aAdd(aEmp, "01")
	aAdd(aEmp, "05")
	
	For nCount := 1 To Len(aEmp)

		aPedCom := {}
		
		RpcSetType(3)
		RpcSetEnv(aEmp[nCount], "01")
		
		cBizagi := U_fGetBase("2") 	
			
		cSQL := " SELECT CR_USER, EMP, C7_NUM, C7_USER, C1_YBIZAGI, C1_NUM, C1_USER, MAILSOL, A2_NOME, CR_EMISSAO, CR_TOTAL, "
		cSQL += " DATEDIFF(DAY, GETDATE(), DATEADD(DAY, 10, CR_EMISSAO)) AS DIA_REP, "
		cSQL += " CONVERT(VARCHAR(8), DATEADD(DAY, 10, CR_EMISSAO), 112) AS DATA_LIM "
		cSQL += " FROM "
		cSQL += " ( "
		cSQL += " 	SELECT CR_USER, "+ ValToSQL(Capital(FWEmpName(aEmp[nCount]))) +" AS EMP, C7_NUM, C7_USER, C1_YBIZAGI, C1_NUM, C1_USER, ISNULL(EMAIL, '') AS MAILSOL, A2_COD+'-'+A2_LOJA+'-'+LTRIM(A2_NOME) AS A2_NOME, "
		cSQL += " 	CASE WHEN "
		cSQL += " 		CASE WHEN CR_YDTINCL = '' THEN CR_EMISSAO ELSE CR_YDTINCL END < '20180725' THEN '20180725' " 
		cSQL += " 		ELSE CASE WHEN CR_YDTINCL = '' THEN CR_EMISSAO ELSE CR_YDTINCL END "
		cSQL += " 	END AS CR_EMISSAO, SUM(CR_TOTAL) AS CR_TOTAL "
		cSQL += " 	FROM "+ RetSQLName("SCR") +" SCR "
		cSQL += " 	INNER JOIN "+ RetSQLName("SC7") +" SC7 "
		cSQL += " 	ON CR_NUM = C7_NUM "
		cSQL += " 	INNER JOIN "+ RetSQLName("SA2") +" SA2 "
		cSQL += " 	ON C7_FORNECE = A2_COD "
		cSQL += " 	AND C7_LOJA = A2_LOJA	"
		cSQL += " 	INNER JOIN "+ RetSQLName("SC1") +" SC1 "
		cSQL += " 	ON C7_NUMSC = C1_NUM "
		cSQL += " 	AND C7_ITEMSC = C1_ITEM "
		cSQL += " 	LEFT JOIN "+cBizagi+".dbo.BZ_DADOS_SC SC_BIZ "
		cSQL += " 	ON C1_YBIZAGI = BIZAGI COLLATE Latin1_General_BIN "
		cSQL += " 	AND C1_NUM = PROTHEUS COLLATE Latin1_General_BIN "
		cSQL += " 	AND EMPRESA = " + ValToSQL(aEmp[nCount] + "01")
		cSQL += " 	WHERE CR_FILIAL = " + ValToSQL(xFilial("SCR"))
		cSQL += " 	AND CR_TIPO = 'PC' "
		cSQL += " 	AND CR_LIBAPRO = '' "
		cSQL += " 	AND CR_DATALIB = '' "
		cSQL += " 	AND CR_USERLIB = '' "
		cSQL += " 	AND CR_VALLIB = 0 "
		cSQL += " 	AND SCR.D_E_L_E_T_ = '' "
		cSQL += " 	AND C7_FILIAL = " + ValToSQL(xFilial("SC7"))
		cSQL += " 	AND C7_RESIDUO = '' "
		cSQL += " 	AND C7_EMISSAO >= '20180725' "
		cSQL += " 	AND SC7.D_E_L_E_T_ = '' "
		cSQL += " 	AND A2_FILIAL = " + ValToSQL(xFilial("SA2"))
		cSQL += " 	AND SA2.D_E_L_E_T_ = '' "
		cSQL += " 	GROUP BY CR_USER, C7_NUM, C7_USER, C1_YBIZAGI, C1_NUM, C1_USER, EMAIL, A2_COD, A2_LOJA, A2_NOME, CR_EMISSAO, CR_YDTINCL "		
		cSQL += " ) AS TMP "		
		cSQL += " WHERE DATEDIFF(DAY, GETDATE(), DATEADD(DAY, 10, CR_EMISSAO)) <= 0 "
		cSQL += " ORDER BY CR_USER, CR_EMISSAO, C7_NUM "
		 
		TcQuery cSQL New Alias (cQry)		  			
		
		While (cQry)->(!Eof())
			
			If fResiduo((cQry)->C7_NUM, sToD((cQry)->CR_EMISSAO), SubStr((cQry)->A2_NOME, 1, 6))
			
				aAdd(aPedCom, {(cQry)->CR_USER, (cQry)->EMP, (cQry)->C7_NUM, (cQry)->C7_USER, (cQry)->C1_YBIZAGI, (cQry)->C1_NUM, (cQry)->C1_USER, (cQry)->MAILSOL, (cQry)->A2_NOME, (cQry)->CR_EMISSAO, (cQry)->CR_TOTAL})						
			
			EndIf
			
			(cQry)->(DbSkip())
			
		EndDo()
		
		(cQry)->(DbCloseArea())
		
		fEnviaWF(aPedCom)
		
		RpcClearEnv()
		
	Next
		
Return()


Static Function fResiduo(cNumPed, dDatEmi, cFornece)
Local lRet := .T.

	MA235PC(100, 1, FirstYDate(YearSub(dDatEmi, 1)), LastYDate(dDatEmi), cNumPed, cNumPed, Space(1), Replicate("Z", 15), cFornece, cFornece)	
		
	If (lRet := fPedEli(cNumPed))
	
		fUpdSC7(cNumPed)
	
	EndIf
	
Return(lRet)


Static Function fPedEli(cNumPed)
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT COUNT(C7_NUM) AS COUNT "
	cSQL += " FROM " + RetSQLName("SC7")
	cSQL += " WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	cSQL += " AND C7_NUM = " + ValToSQL(cNumPed)
	cSQL += " AND C7_RESIDUO = 'S' "
	cSQL += " AND D_E_L_E_T_ = '' "
		
	TcQuery cSQL New Alias (cQry)	

	lRet := (cQry)->COUNT > 0
			
	(cQry)->(DbCloseArea())

Return(lRet)


Static Function fUpdSC7(cNumPed)
	
	DbSelectArea("SC7")
	DbSetOrder(1)
	SC7->(DbSeek(xFilial("SC7") + cNumPed))
	
	While !SC7->(Eof()) .And. SC7->C7_NUM == cNumPed
	
		If SC7->C7_RESIDUO == "S"
		
			RecLock("SC7", .F.)
			
				SC7->C7_YRESAUT = "S"
				
			SC7->(MsUnLock())
			
		EndIf
		
		SC7->(DbSkip())
	
	EndDo()

Return()


Static Function fEnviaWF(aPedCom)
Local nCount := 0
Local cHtml := ""

	If Len(aPedCom) > 0
	
		For nCount := 1 To Len(aPedCom)
		
			cHtml	:= fRetCab()
			cHtml	+= fRetItem(aPedCom[nCount])
			cHtml	+= fRetRod()
								
			fSendMail(aPedCom[nCount, _CodApr], aPedCom[nCount, _CodCom], aPedCom[nCount, _CodSol], aPedCom[nCount, _MailSol], cHtml)
			
		Next
						
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
	cRet += '        <tr>
	cRet += '        		 <td class="styleRodape" width="60" scope="col" colspan="8">Pedido de compra eliminado automaticamente por pendência de aprovação</td>
	cRet += '        </tr>         			
	cRet += '        <tr align=center>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Empresa </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Pedido </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> SC Bizagi </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> SC </th>
	cRet += '            <th class="styleCabecalho" width="200" scope="col"> Fornecedor </th>
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Emissão </th>	
	cRet += '            <th class="styleCabecalho" width="60" scope="col"> Valor </th>
	cRet += '            <th class="styleCabecalho" width="150" scope="col"> Aprovador </th>	
	cRet += '        </tr>
			
Return(cRet)


Static Function fRetItem(aPedCom)
Local cRet := ""
	
	cRet += '        <tr align=center>
	cRet += '            <th class="styleLinha" width="60" scope="col"> ' + aPedCom[_NomEmp] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> ' + aPedCom[_NumPed] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> ' + aPedCom[_NumBiz] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> ' + aPedCom[_NumSol] +' </th>
	cRet += '            <th class="styleLinha" width="200" scope="col"> ' + aPedCom[_NomFor] +' </th>
	cRet += '            <th class="styleLinha" width="60" scope="col"> ' + dToC(sToD(aPedCom[_DatEmi])) +' </th>	
	cRet += '            <th class="styleLinha" width="60" scope="col"> ' + Transform(aPedCom[_Valor], "@E 999,999,999.99") +' </th>
	cRet += '            <th class="styleLinha" width="150" scope="col"> ' + Capital(AllTrim(UsrFullName(aPedCom[_CodApr]))) +' </th>	
	cRet += '        </tr>
		
Return(cRet)


Static Function fRetRod()
Local cRet := ""

	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td class="styleRodape" width="60" scope="col" colspan="8">
	cRet += '                E-mail enviado automaticamente pelo sistema Protheus (by BIAF114)
	cRet += '            </td>
	cRet += '        </tr>
	cRet += '	</table>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


Static Function fSendMail(cCodApr, cCodCom, cCodSol, cMailSol, cHtml)
Local cMail := ""

	cMail := AllTrim(UsrRetMail(cCodApr)) + ";" + AllTrim(UsrRetMail(cCodCom)) 
	
	If !Empty(cMailSol)
	
		cMail += ";" + cMailSol
		
	ElseIf !Empty(cCodSol)
		
		cMail += ";" + AllTrim(UsrRetMail(cCodSol))
	
	EndIf
	
	If U_BIAEnvMail(,cMail, "Pedido de compra eliminado", cHtml)
	
		ConOut("[" + cValToChar(dDataBase) + Space(1) + Time() + "] - BIAF114:fSendMail('"+ cMail +"')")
	
	EndIf
		
Return()