#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWorkflowLimiteCreditoCliente
@author Tiago Rossini Coradini
@since 08/08/2019
@version 1.0
@description Classe para envio de workflow de limites de credito de clientes
@obs Ticket: 16502
@type class
/*/

Class TWorkflowLimiteCreditoCliente From LongClassName

	Data oParam
	Data cTabPed // Tabela temporaria de saldo de pedidos de venda pendentes
	Data cTabTit // Tabela temporaria de saldo de titulos vencidos
			
	Method New(oParam) Constructor
	Method Process()
	Method GetData()
	Method GetHeader()	
	Method GetBody(aVend)
	Method GetMail(cMail, cMail_1, cMail_2)	
	Method GetSeparator()
	Method GetFooter()
	Method GetMessage()
	Method SendWorkFlow(cCGC, cMail, cHtml)
	
EndClass


Method New(oParam) Class TWorkflowLimiteCreditoCliente	

	Default oParam := Nil
	
	::oParam := oParam

	::cTabPed := "##TMP_LLC_SALDO_PEDIDO_" + cEmpAnt + __cUserID + StrZero(Seconds() * 3500, 10)
	
	::cTabTit := "##TMP_LLC_SALDO_TITULO_" + cEmpAnt + __cUserID + StrZero(Seconds() * 3500, 10)
								
Return()


Method Process() Class TWorkflowLimiteCreditoCliente	
Local cSQL := ""
Local cQry := GetNextAlias()
Local cCGC := ""
Local cMail := ""
Local cHtml := ""
Local aVend := {}

	cSQL := " SELECT A3_CGC, A3_COD, A3_NOME, A3_NREDUZ, A3_EMAIL, A3_YEMAIL, A3_YEMP "
	cSQL += " FROM " + RetFullName("SA3", "01")
	cSQL += " INNER JOIN "
	cSQL += " ( "
	cSQL += " 	SELECT Z37_MARCA "
	cSQL += " 	FROM " + RetFullName("Z37", "01")
	cSQL += " 	WHERE Z37_FILIAL = '' "
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " 	GROUP BY Z37_MARCA "
	cSQL += " ) AS Z37 "
	cSQL += " ON A3_YEMP LIKE '%' + Z37_MARCA + '%' "
	cSQL += " INNER JOIN "
	cSQL += " ( "
	cSQL += " 	SELECT Z78_VEND "
	cSQL += " 	FROM " + RetFullName("Z78", "01")
	cSQL += " 	WHERE D_E_L_E_T_ = '' "
	cSQL += "   GROUP BY Z78_VEND "
	cSQL += " 	UNION ALL	"
	cSQL += " 	SELECT Z78_VEND "
	cSQL += " 	FROM " + RetFullName("Z78", "05")
	cSQL += " 	WHERE D_E_L_E_T_ = '' "
	cSQL += "   GROUP BY Z78_VEND "
	cSQL += " 	UNION ALL "
	cSQL += " 	SELECT Z78_VEND "
	cSQL += " 	FROM " + RetFullName("Z78", "07")
	cSQL += " 	WHERE D_E_L_E_T_ = '' "
	cSQL += "   GROUP BY Z78_VEND "
	cSQL += " 	UNION ALL "	
	cSQL += " 	SELECT Z78_VEND "
	cSQL += " 	FROM " + RetFullName("Z78", "14")
	cSQL += " 	WHERE D_E_L_E_T_ = '' "
	cSQL += "   GROUP BY Z78_VEND "
	cSQL += " ) AS Z78
	cSQL += " ON A3_COD <> Z78_VEND "
	cSQL += " WHERE A3_FILIAL = '' "
	cSQL += " AND A3_COD BETWEEN " + ValToSQL(::oParam:cVendDe) + " AND " + ValToSQL(::oParam:cVendAte)
	cSQL += " AND A3_CGC <> '' AND A3_CGC <> '00000000000000' "
	cSQL += " AND (A3_EMAIL <> '' OR A3_YEMAIL <> '') "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " AND A3_MSBLQL <> '1' "
	cSQL += " GROUP BY A3_CGC, A3_COD, A3_NOME, A3_NREDUZ, A3_EMAIL, A3_YEMAIL, A3_YEMP "
	cSQL += " ORDER BY A3_CGC, A3_COD, A3_EMAIL, A3_YEMAIL, A3_YEMP "
			
	TcQuery cSQL New Alias (cQry)

	If !Empty(cCGC := (cQry)->A3_CGC)
	
		::GetData()
	
		While !(cQry)->(Eof())
			
			While cCGC == (cQry)->A3_CGC
															
				aAdd(aVend, {(cQry)->A3_COD, AllTrim((cQry)->A3_NOME), AllTrim((cQry)->A3_YEMP)})
				
				cMail += ::GetMail(cMail, (cQry)->A3_YEMAIL, (cQry)->A3_EMAIL) + ";"
				
				cCGC := (cQry)->A3_CGC
				
				(cQry)->(DbSkip())
				
			EndDo()
						
			cHtml	:= ::GetHeader()
			cHtml	+= ::GetBody(aVend)
			cHtml	+= ::GetFooter()
					
			::SendWorkFlow(cCGC, cMail, cHtml)
									
			aVend := {}
			
			cMail := ""
			
			If !(cQry)->(Eof())
	
				cCGC := (cQry)->A3_CGC
				
			EndIf
	
		EndDo()
			
		(cQry)->(DbCloseArea())
		
	EndIf
								
Return()


Method GetData() Class TWorkflowLimiteCreditoCliente
	
	TcSQLExec("SELECT * INTO " + ::cTabPed + " FROM VW_SALDOPEDIDO_NOVO")
	
	TcSQLExec("SELECT * INTO " + ::cTabTit + " FROM VW_SALDOTITULO")

Return()


Method GetHeader() Class TWorkflowLimiteCreditoCliente
Local cRet := ""

	cRet += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cRet += '<html xmlns="http://www.w3.org/1999/xhtml">
	cRet += '<head>
	cRet += '    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cRet += '    <title>Workflow</title>
	cRet += '    <style type="text/css">
	cRet += '        <!-- .style_table {
	cRet += '            border: 0;
	cRet += '            width: 100%;
	cRet += '        }
	cRet += '        .table-not-border-spacing {
	cRet += '        		 border-spacing: 2px 0px !important;
	cRet += '        }
	cRet += '        .style_table_header {
	cRet += '            background: #0c2c65;
	cRet += '            color: #ffffff;
	cRet += '            font: 13px Arial, Helvetica, sans-serif;
	cRet += '            font-weight: bold;
	cRet += '            padding: 5px;
	cRet += '        }
	cRet += '        .style_column_header {
	cRet += '            background: #0c2c65;
	cRet += '            color: #ffffff;
	cRet += '            font: 13px Arial, Helvetica, sans-serif;
	cRet += '            font-weight: bold;
	cRet += '            padding: 2px;
	cRet += '        }        
	cRet += '        .style_column_rows {
	cRet += '            background: #f6f6f6;
	cRet += '            color: #747474;
	cRet += '            font: 12px Arial, Helvetica, sans-serif;
	cRet += '            padding: 2px;
	cRet += '        }
	cRet += '        -->
	cRet += '    </style>	
	cRet += '</head>
	cRet += '<body>
	cRet += '    <table class="style_table table-not-border-spacing">
	cRet += '        <tr>
	cRet += '            <th class="style_table_header" align="center" scope="col">Relatório de Limite de Crédito de Clientes</th>
	cRet += '        </tr>
	cRet += '    </table>	
			
Return(cRet)


Method GetBody(aVend) Class TWorkflowLimiteCreditoCliente
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()
Local nCount := 1
Local aGroup := {}

	If Len(aVend) > 0
					
		cSQL += " SELECT A1_CGC, A1_GRPVEN, ACY_DESCRI, A1_COD, A1_NOME, A1_LC, A1_VENCLC, PEDIDO, TITULO, A1_LC - (PEDIDO + TITULO) AS SALDO, "
		cSQL += " CASE WHEN A1_LC <> 0 THEN (PEDIDO + TITULO) / A1_LC * 100 ELSE 0 END PERC "
		cSQL += " FROM "
		cSQL += " ( "
		cSQL += " 	SELECT SUBSTRING(A1_CGC, 1, 8) AS A1_CGC, A1_GRPVEN, ACY_DESCRI, A1_COD, A1_NOME, ISNULL(SG.LC, A1_LC) AS A1_LC, ISNULL(SG.VENCLC, SA1.A1_VENCLC) AS A1_VENCLC, "
		cSQL += " 	SUM(ISNULL(ISNULL(SG.PEDIDO, SP_A.SALDO), 0)) AS PEDIDO, SUM(ISNULL(ISNULL(SG.TITULO, ST_A.SALDO), 0)) AS TITULO "
		cSQL += " 	FROM "+ RetSQLName("SA1") + " SA1 (NOLOCK) "
		cSQL += " 	LEFT JOIN " + ::cTabPed + " SP_A "
		cSQL += " 	ON A1_COD = C5_CLIENTE "
		cSQL += " 	AND A1_LOJA = C5_LOJACLI "
		cSQL += " 	LEFT JOIN " + ::cTabTit + " ST_A "
		cSQL += " 	ON A1_COD = E1_CLIENTE "
		cSQL += " 	AND A1_LOJA = E1_LOJA "
		cSQL += " 	LEFT JOIN " + RetSQLName("ACY") + " ACY (NOLOCK) "
		cSQL += " 	ON ACY_FILIAL = " + ValToSQL(xFilial("ACY"))
		cSQL += " 	AND A1_GRPVEN = ACY_GRPVEN "
		cSQL += " 	AND ACY.D_E_L_E_T_ = '' "
		cSQL += "   LEFT JOIN "
		cSQL += "		( "
		cSQL += " 		SELECT A1_GRPVEN AS GRPVEN, MAX(A1_VENCLC) AS VENCLC, MAX(A1_LC) AS LC, SUM(ISNULL(SP_B.SALDO, 0)) AS PEDIDO, SUM(ISNULL(ST_B.SALDO, 0)) AS TITULO "
		cSQL += " 		FROM " + RetSQLName("SA1") + " SA1_A (NOLOCK) "
		cSQL += " 		LEFT JOIN " + ::cTabPed + " SP_B "
		cSQL += " 		ON A1_COD = C5_CLIENTE "
		cSQL += " 		AND A1_LOJA = C5_LOJACLI "
		cSQL += " 		LEFT JOIN " + ::cTabTit + " ST_B "
		cSQL += " 		ON A1_COD = E1_CLIENTE "
		cSQL += " 		AND A1_LOJA = E1_LOJA "
		cSQL += " 		WHERE SA1_A.A1_FILIAL = " + ValToSQL(xFilial("SA1"))
		cSQL += " 		AND SA1_A.A1_GRPVEN <> '' "
		cSQL += " 		AND SA1_A.D_E_L_E_T_ = '' "
		cSQL += " 		GROUP BY A1_GRPVEN "
		cSQL += "		) SG "
		cSQL += " 	ON SG.GRPVEN = A1_GRPVEN "
		cSQL += " 	WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
		cSQL += " 	AND ( "
		
		While nCount <= Len(aVend)
		
			cCodVen := aVend[nCount, 1]
			cNomVen := aVend[nCount, 2]
			cEmpVen := aVend[nCount, 3]
		
			cSQL += " ( "
			cSQL += " 	A1_VEND = " + ValToSQL(cCodVen)
			cSQL += " 	OR A1_YVENDB2 = " + ValToSQL(cCodVen)
			cSQL += " 	OR A1_YVENDB3 = " + ValToSQL(cCodVen)
			cSQL += " 	OR A1_YVENDI  = " + ValToSQL(cCodVen)
			cSQL += " 	OR A1_YVENDI2 = " + ValToSQL(cCodVen)
			cSQL += " 	OR A1_YVENDI3 = " + ValToSQL(cCodVen)
			cSQL += " 	OR A1_YVENBE1 = " + ValToSQL(cCodVen)
			cSQL += " 	OR A1_YVENBE2 = " + ValToSQL(cCodVen)
			cSQL += " 	OR A1_YVENBE3 = " + ValToSQL(cCodVen)
			cSQL += " 	OR A1_YVENVT1 = " + ValToSQL(cCodVen)
			cSQL += " 	OR A1_YVENVT2 = " + ValToSQL(cCodVen)
			cSQL += " 	OR A1_YVENVT3 = " + ValToSQL(cCodVen)
			cSQL += " 	OR A1_YVENML1 = " + ValToSQL(cCodVen)
			cSQL += " 	OR A1_YVENML2 = " + ValToSQL(cCodVen)
			cSQL += " 	OR A1_YVENML3 = " + ValToSQL(cCodVen)
			cSQL += " 	OR A1_YVENPEG = " + ValToSQL(cCodVen)
			cSQL += "	OR A1_YVENVI1 = " + ValToSQL(cCodVen)
			cSQL += " ) "
			
			If nCount < Len(aVend)
				
				cSQL += " OR "
				
			EndIf
			
			nCount++
			
		EndDo
		
		cSQL += " ) "
		cSQL += " 	AND SA1.D_E_L_E_T_ = '' "
		cSQL += " 	GROUP BY SUBSTRING(A1_CGC, 1, 8), A1_GRPVEN, ACY_DESCRI, A1_COD, A1_NOME, SG.LC, A1_LC, SG.VENCLC, A1_VENCLC "
		cSQL += " ) AS LMC "		
		cSQL += " ORDER BY PEDIDO DESC, SALDO DESC, A1_VENCLC, A1_NOME "
		
		TcQuery cSQL New Alias (cQry)
		
		If !(cQry)->(Eof())
			
			cRet += '    <table class="style_table">			
			cRet += '        <tr>
			cRet += '            <th class="style_table_header" colspan="9" align="left" scope="col">Vendedor: '+ Capital(cNomVen) +'</th>
			cRet += '        </tr>
			cRet += '        <tr align=center>
			cRet += '            <th class="style_column_header" width="40" align="left" scope="col">Cliente</th>
			cRet += '            <th class="style_column_header" width="200" align="left" scope="col">Nome</th>
			cRet += '            <th class="style_column_header" width="40" align="left" scope="col">Grupo</th>
			cRet += '            <th class="style_column_header" width="60" align="right" scope="col">Lim. Crédito</th>
			cRet += '            <th class="style_column_header" width="60" align="right" scope="col">Vencto LC</th>
			cRet += '            <th class="style_column_header" width="60" align="right" scope="col">Tit. Aberto</th>
			cRet += '            <th class="style_column_header" width="60" align="right" scope="col">Ped. Carteira</th>
			cRet += '            <th class="style_column_header" width="60" align="right" scope="col">Saldo</th>
			cRet += '            <th class="style_column_header" width="60" align="right" scope="col">(%) Utilização</th>
			cRet += '        </tr>
			cRet += '        </tr>
		
			While !(cQry)->(Eof())
	
				If aScan(aGroup, {|x| x[1] == (cQry)->A1_CGC }) == 0
				
					cRet += '        <tr align=center>
					cRet += '            <th class="style_column_rows" width="40" align="left" scope="col">'+ (cQry)->A1_COD +'</th>
					cRet += '            <th class="style_column_rows" width="200" align="left" scope="col">'+ AllTrim((cQry)->A1_NOME) +'</th>
					cRet += '            <th class="style_column_rows" width="40" align="left" scope="col">'+ (cQry)->A1_GRPVEN +'</th>
					cRet += '            <th class="style_column_rows" width="60" align="right" scope="col">'+ Transform((cQry)->A1_LC, X3Picture("A1_LC")) +'</th>
					cRet += '            <th class="style_column_rows" width="60" align="right" scope="col">'+ dToC(sToD((cQry)->A1_VENCLC)) +'</th>
					cRet += '            <th class="style_column_rows" width="60" align="right" scope="col">'+ Transform((cQry)->TITULO, X3Picture("E1_VALOR")) +'</th>
					cRet += '            <th class="style_column_rows" width="60" align="right" scope="col">'+ Transform((cQry)->PEDIDO, X3Picture("E1_VALOR")) +'</th>
					cRet += '            <th class="style_column_rows" width="60" align="right" scope="col">'+ Transform((cQry)->SALDO, X3Picture("E1_SALDO")) +'</th>
					cRet += '            <th class="style_column_rows" width="60" align="right" scope="col">'+ Transform((cQry)->PERC, X3Picture("E3_PORC")) +'</th>
					cRet += '        </tr>					
		
					aAdd(aGroup, {(cQry)->A1_CGC})
					
				EndIf
	
				(cQry)->(DbSkip())
								
			EndDo()
				
		EndIf
				
		(cQry)->(DbCloseArea())		
	
	EndIf	
				
Return(cRet)


Method GetMail(cMail, cMail_1, cMail_2) Class TWorkflowLimiteCreditoCliente
Local cRet := ""

	If !Empty(AllTrim(cMail_1))
	
		cRet := AllTrim(cMail_1)
	
	ElseIf !Empty(AllTrim(cMail_2))
	
		cRet := AllTrim(cMail_2)
	
	EndIf
	
	If AllTrim(cRet) $ AllTrim(cMail)
		
		cRet := ""
		
	EndIf	

Return(cRet)


Method GetFooter() Class TWorkflowLimiteCreditoCliente
Local cRet := ""

	cRet := '    </table>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


Method GetMessage() Class TWorkflowLimiteCreditoCliente
Local cRet := ""

	cRet := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cRet += '<html xmlns="http://www.w3.org/1999/xhtml">
	cRet += '<head>
	cRet += '    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cRet += '    <title>Workflow</title>
	cRet += '    <style type="text/css">
	cRet += '        body {
	cRet += '            font-family: tahoma;
	cRet += '            font-size: 15px;
	cRet += '        }
	cRet += '    </style>
	cRet += '</head>
	cRet += '<body>
	cRet += '    <p><span>Prezado Representante,</span></p>
	cRet += '    <p><span>Segue em anexo Relatório de Limite de Crédito de Clientes.</span></p>
	cRet += '		 <p><span>Atenciosamente,</span></p>
	cRet += '    <p><span style="font-weight:bold;">GRUPO BIANCOGRES</span></p>
	cRet += '</body>
	cRet += '</html>
	
Return(cRet)


Method SendWorkFlow(cCGC, cMail, cHtml) Class TWorkflowLimiteCreditoCliente
Local cFile := ""
Local oMail := TAFMail():New()

	cFile := "\P10\Relato\Rep\limite_credito\LCC_" + AllTrim(cCGC) + "_" + cEmpAnt + ".html"	
	
	If File(cFile)

		FErase(cFile)
		
	EndIf	
	
	fHandle := fCreate(cFile)
	FWrite(fHandle, cHtml)	
	fClose(fHandle)
	
	oMail:cTo := cMail
	oMail:cSubject := "Limite de Crédito de Clientes"
	oMail:cBody := ::GetMessage()	
	oMail:cAttachFile := cFile

	oMail:Send()
		
Return()