#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWorkflowtTituloVencidoCliente
@author Tiago Rossini Coradini
@since 08/08/2019
@version 1.0
@description Classe para envio de workflow de titulos vencidos de clientes
@obs Ticket: 16502
@type class
/*/

Class TWorkflowtTituloVencidoCliente From LongClassName

	Data oParam
	Data cTabTit // Tabela temporaria de titulos vencidos	de clientes
			
	Method New(oParam) Constructor
	Method Process()
	Method GetData()
	Method GetHeader()
	Method GetBody(cCodVen, cNomVen, nVlrTot, lSeparator)
	Method GetMail(cMail, cMail_1, cMail_2)	
	Method GetSeparator()
	Method GetFooter()	
	Method GetMessage()
	Method SendWorkFlow(cCGC, cMail, cHtml)
	
EndClass


Method New(oParam) Class TWorkflowtTituloVencidoCliente	

	Default oParam := Nil
	
	::oParam := oParam

	::cTabTit := "##TMP_TVC_" + cEmpAnt + __cUserID + StrZero(Seconds() * 3500, 10)	
								
Return()


Method Process() Class TWorkflowtTituloVencidoCliente	
Local cSQL := ""
Local cQry := GetNextAlias()
Local cCGC := ""
Local cMail := ""
Local cHtml := ""
Local cBody := ""
Local nVlrTot := 0

	cSQL := " SELECT A3_CGC, A3_COD, A3_NOME, A3_NREDUZ, A3_EMAIL, A3_YEMAIL "
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
	cSQL += " GROUP BY A3_CGC, A3_COD, A3_NOME, A3_NREDUZ, A3_EMAIL, A3_YEMAIL "
	cSQL += " ORDER BY A3_CGC, A3_COD, A3_EMAIL, A3_YEMAIL "
			
	TcQuery cSQL New Alias (cQry)

	If !Empty(cCGC := (cQry)->A3_CGC)
	
		::GetData()
	
		While !(cQry)->(Eof())
			
			While cCGC == (cQry)->A3_CGC
															
				cBody	+= ::GetBody((cQry)->A3_COD, AllTrim((cQry)->A3_NOME), @nVlrTot, !Empty(cBody))
				
				cMail += ::GetMail(cMail, (cQry)->A3_YEMAIL, (cQry)->A3_EMAIL) + ";"
				
				cCGC := (cQry)->A3_CGC
				
				(cQry)->(DbSkip())
				
			EndDo()
						
			If nVlrTot > 0
				
				cHtml	:= ::GetHeader()
				cHtml	+= cBody
				cHtml	+= ::GetFooter()
				
				::SendWorkFlow(cCGC, cMail, cHtml)
			
			EndIf
						
			cBody := ""
			cMail := ""
			nVlrTot := 0
			
			If !(cQry)->(Eof())
	
				cCGC := (cQry)->A3_CGC
				
			EndIf
	
		EndDo()
			
		(cQry)->(DbCloseArea())
		
	EndIf
								
Return()


Method GetData() Class TWorkflowtTituloVencidoCliente
	
	TcSQLExec("EXEC SP_ENV_LIM " + ValToSQL(::cTabTit))

Return()


Method GetHeader() Class TWorkflowtTituloVencidoCliente
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
	cRet += '        
	cRet += '        .table-not-border-spacing {
	cRet += '            border-spacing: 2px 0px !important;
	cRet += '        }
	cRet += '        
	cRet += '        .style_table_header {
	cRet += '            background: #0c2c65;
	cRet += '            color: #ffffff;
	cRet += '            font: 13px Arial, Helvetica, sans-serif;
	cRet += '            font-weight: bold;
	cRet += '            padding: 5px;
	cRet += '        }
	cRet += '        
	cRet += '        .style_column_header {
	cRet += '            background: #0c2c65;
	cRet += '            color: #ffffff;
	cRet += '            font: 13px Arial, Helvetica, sans-serif;
	cRet += '            font-weight: bold;
	cRet += '            padding: 2px;			
	cRet += '        }
	cRet += '        
	cRet += '        .style_column_rows {
	cRet += '            background: #f6f6f6;
	cRet += '            color: #747474;
	cRet += '            font: 12px Arial, Helvetica, sans-serif;
	cRet += '            padding: 2px;
	cRet += '        }
	cRet += '        
	cRet += '        .style_table_footer {
	cRet += '            background: #63a0d7;
	cRet += '            color: #ffffff;
	cRet += '            font: 12px Arial, Helvetica, sans-serif;
	cRet += '            font-weight: bold;
	cRet += '            padding: 5px;
	cRet += '        }
	cRet += '        
	cRet += '        .hide {
	cRet += '            display: none;
	cRet += '        }
	cRet += '        
	cRet += '        .btn {
	cRet += '            width: 15px;
	cRet += '            height: 100%;
	cRet += '            border-radius: 30px;
	cRet += '            color: #63a0d7;
	cRet += '            font-weight: bold;
	cRet += '            cursor: pointer;
	cRet += '            font-weight: bold;
	cRet += '            font: 24px Arial, Helvetica, sans-serif;
	cRet += '        }        
	cRet += '        -->
	cRet += '    </style>
	cRet += '</head>
	cRet += '<body>
	cRet += '    <table class="style_table table-not-border-spacing">
	cRet += '        <tr>
	cRet += '            <th class="style_table_header" align="center" scope="col">Títulos Vencidos por Cliente</th>
	cRet += '        </tr>
	cRet += '    </table>	
				
Return(cRet)


Method GetBody(cCodVen, cNomVen, nVlrTot, lSeparator) Class TWorkflowtTituloVencidoCliente
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()
Local cCodCli := ""
Local nVlrTit := 0

	cSQL := " SELECT EMP, A1_COD, A1_NOME, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_SALDO, E1_VENCTO, DATEDIFF(DAY, E1_VENCTO, GETDATE()) AS DIA "
	cSQL += " FROM " + ::cTabTit
	cSQL += " INNER JOIN SA1010 SA1 "
	cSQL += " ON E1_CLIENTE = A1_COD "
	cSQL += " AND E1_LOJA = A1_LOJA "
	cSQL += " WHERE E1_VEND1 = " + ValToSQL(cCodVen)
	cSQL += " AND A1_FILIAL	= '' "
	cSQL += " AND SA1.D_E_L_E_T_ = '' "
	cSQL += " ORDER BY A1_COD, EMP, DIA "
			
	TcQuery cSQL New Alias (cQry)
	
	If !(cQry)->(Eof())
	
		If lSeparator
			
			cRet += ::GetSeparator()
			
		EndIf	
	
		cRet += '	<table class="style_table">
		cRet += ' 	<tr>
		cRet += '   	<th class="style_table_header" colspan="8" scope="col" align="left">Vendedor: '+ cCodVen +' - ' + Capital(cNomVen) +'</th>
		cRet += '		</tr>	
		cRet += '   <tr align=center>
		cRet += '   	<th class="style_column_header" width="2%" align="left" scope="col"></th>
		cRet += '     	<th class="style_column_header" width="98%" style="padding-left: 5px;" align="left" scope="col">Cliente</th>
		cRet += '		</tr>
		
		cCodCli := (cQry)->A1_COD

		While !(cQry)->(Eof())

			cRet += '	<tr align=center>
			cRet += ' 	<th class="style_column_rows" width="2%" scope="col">
			cRet += '   	<div class="btn" title="Clique aqui para visualizar os títulos do Cliente" id="btn-show-detalhe-'+ cCodVen + (cQry)->A1_COD +'" onclick="showDetalhe('+ ValToSQL(cCodVen + (cQry)->A1_COD) +')">+</div>
			cRet += '		</th>
			cRet += '		<th class="style_column_rows" width="98%" style="padding-left: 5px;" align="left" scope="col" style="padding-left: 5px;">'+ (cQry)->A1_COD + ' - ' + Capital(AllTrim((cQry)->A1_NOME)) +'</th>
			cRet += '	</tr>
			cRet += ' <tr>
			cRet += ' 	<td colspan="2">
			cRet += '			<table width="100%" id="detalhe-titulo-'+ cCodVen + (cQry)->A1_COD +'" class="hide">
			cRet += '     	<tr>
			cRet += '       	<td colspan="8" class="style_table_header" align="center" style="background: #63a0d7;">Informações dos Títulos</td>
			cRet += '				</tr>
			cRet += '       <tr align=center>
			cRet += '       	<th class="style_column_header" width="40" align="left" style="background: #63a0d7;" scope="col">Empresa</th>
			cRet += '         <th class="style_column_header" width="20" align="left" style="background: #63a0d7;" scope="col">Prefixo</th>
			cRet += '         <th class="style_column_header" width="40" align="left" style="background: #63a0d7;" scope="col">Número</th>
			cRet += '         <th class="style_column_header" width="20" align="left" style="background: #63a0d7;" scope="col">Parcela</th>
			cRet += '         <th class="style_column_header" width="20" align="left" style="background: #63a0d7;" scope="col">Tipo</th>
			cRet += '         <th class="style_column_header" width="40" align="right" style="background: #63a0d7;" scope="col">Vencimento</th>
			cRet += '					<th class="style_column_header" width="40" align="right" style="background: #63a0d7;" scope="col">Dias Atraso</th>
			cRet += '         <th class="style_column_header" width="40" align="right" style="background: #63a0d7;" scope="col">Valor</th>
			cRet += '				</tr>						

			nVlrTit := 0

			While cCodCli == (cQry)->A1_COD
			
				nVlrTit += (cQry)->E1_SALDO
				
				cRet += '	<tr align=center>
				cRet += ' 	<th class="style_column_rows" width="40" align="left" scope="col">'+ Capital(AllTrim(FWEmpName((cQry)->EMP))) +'</th>
				cRet += '   <th class="style_column_rows" width="20" align="left" scope="col">'+ AllTrim((cQry)->E1_PREFIXO) +'</th>
				cRet += '   <th class="style_column_rows" width="40" align="left" scope="col">'+ (cQry)->E1_NUM +'</th>
				cRet += '   <th class="style_column_rows" width="20" align="left" scope="col">'+ (cQry)->E1_PARCELA +'</th>
				cRet += '   <th class="style_column_rows" width="20" align="left" scope="col">'+ (cQry)->E1_TIPO +'</th>
				cRet += '   <th class="style_column_rows" width="40" align="right" scope="col">'+ dToC(sToD((cQry)->E1_VENCTO)) +'</th>
				cRet += '   <th class="style_column_rows" width="40" align="right" scope="col">'+ cValToChar((cQry)->DIA) +'</th>
				cRet += '   <th class="style_column_rows" width="40" align="right" scope="col">'+ Transform((cQry)->E1_SALDO, X3Picture("E1_SALDO")) +'</th>
				cRet += '</tr>

				cCodCli := (cQry)->A1_COD				
				
				(cQry)->(DbSkip())
				
			EndDo()

			cRet += '	<tr>
			cRet += ' 	<td colspan="8" class="style_table_footer" align="right">'+ Transform(nVlrTit, X3Picture("E1_SALDO")) +'</td>
			cRet += '	</tr>

			cRet += '	</table>
			cRet += '	</td>
			cRet += '	</tr>
			
			nVlrTot += nVlrTit
			
			cCodCli := (cQry)->A1_COD
							
		EndDo()

		cRet += '	</table>		
	
	EndIf
			
	(cQry)->(DbCloseArea())
		
Return(cRet)


Method GetMail(cMail, cMail_1, cMail_2) Class TWorkflowtTituloVencidoCliente
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


Method GetSeparator() Class TWorkflowtTituloVencidoCliente
Local cRet := ""

	cRet := '	<table class="style_table">
	cRet += '		<tr>
	cRet += '			<th colspan="8"><hr size="4" style="background: #63a0d7;border:0px;"></th>
	cRet += '		</tr>
	cRet += '	</table>

Return(cRet)


Method GetFooter() Class TWorkflowtTituloVencidoCliente
Local cRet := ""

	cRet += '</body>
	cRet += '<script>
	cRet += 'function showDetalhe(id) {
	cRet += '	document.getElementById("detalhe-titulo-"+id).classList.toggle("hide") ' + Chr(13)
	cRet += '	var result = document.getElementById("btn-show-detalhe-"+id).innerHTML;
	cRet += '	
	cRet += '	if (result == "+") {
	cRet += '		document.getElementById("btn-show-detalhe-"+id).innerHTML = "-"
	cRet += '	} else {
	cRet += '		document.getElementById("btn-show-detalhe-"+id).innerHTML = "+"
	cRet += '	}		
	cRet += '}
	cRet += '</script>
	cRet += '</html>
		
Return(cRet)


Method GetMessage() Class TWorkflowtTituloVencidoCliente
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
	cRet += '    <p><span>Segue em anexo Relatório de Títulos Vencidos por Cliente.</span></p>
	cRet += '		 <p><span>Atenciosamente,</span></p>
	cRet += '    <p><span style="font-weight:bold;">GRUPO BIANCOGRES</span></p>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


Method SendWorkFlow(cCGC, cMail, cHtml) Class TWorkflowtTituloVencidoCliente
Local cFile := ""
Local oMail := TAFMail():New()

	cFile := "\P10\Relato\Rep\título_vencido\TVC_" + AllTrim(cCGC) + "_" + cEmpAnt + ".html"
	
	If File(cFile)

		FErase(cFile)
		
	EndIf	
	
	fHandle := fCreate(cFile)
	FWrite(fHandle, cHtml)	
	fClose(fHandle)
	
	oMail:cTo := cMail
	oMail:cSubject := "Títulos Vencidos por Cliente"
	oMail:cBody := ::GetMessage()	
	oMail:cAttachFile := cFile
	
	oMail:Send()
	
Return()