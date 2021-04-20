#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWorkFlowComissaoRepresentante
@author Tiago Rossini Coradini
@since 03/06/2019
@version 1.0
@description Classe para envio de workflow das comissao dos representantes
@type class
/*/

Class TWorkFlowComissaoRepresentante From LongClassName

	Data oParam
			
	Method New(oParam) Constructor
	Method Process()
	Method GetHeader()
	Method GetBody(cCodVen, cNomVen, nVlrTotCom, lSeparator)
	Method GetMail(cMail, cMail_1, cMail_2)	
	Method GetInvoiceBody(cPrefixo, cNumero, cParcela, cNumSeq)
	Method GetSeparator()
	Method GetFooter(nVlrTotCom)
	Method GetMessage()
	Method SendWorkFlow(cCGC, cMail, cHtml)
	
EndClass


Method New(oParam) Class TWorkFlowComissaoRepresentante	

	Default oParam := Nil
	
	::oParam := oParam	
								
Return()


Method Process() Class TWorkFlowComissaoRepresentante	
Local cSQL := ""
Local cQry := GetNextAlias()
Local cCGC := ""
Local cMail := ""
Local cHtml := ""
Local cBody := ""
Local nVlrTotCom := 0

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
	//Ticket 31510 Se o representante possui comissão, envia mesmo se o cadastro estiver bloqueado.
	//cSQL += " AND A3_MSBLQL <> '1' "
	cSQL += " GROUP BY A3_CGC, A3_COD, A3_NOME, A3_NREDUZ, A3_EMAIL, A3_YEMAIL "
	cSQL += " ORDER BY A3_CGC, A3_COD, A3_EMAIL, A3_YEMAIL "
			
	TcQuery cSQL New Alias (cQry)

	cCGC := (cQry)->A3_CGC
	
	While !(cQry)->(Eof())
		
		While cCGC == (cQry)->A3_CGC
														
			cBody	+= ::GetBody((cQry)->A3_COD, AllTrim((cQry)->A3_NOME), @nVlrTotCom, !Empty(cBody))
			
			cMail += ::GetMail(cMail, (cQry)->A3_YEMAIL, (cQry)->A3_EMAIL) + ";"
			
			cCGC := (cQry)->A3_CGC
			
			(cQry)->(DbSkip())
			
		EndDo()
					
		If nVlrTotCom > 0
			
			cHtml	:= ::GetHeader()
			cHtml	+= cBody
			cHtml	+= ::GetFooter(nVlrTotCom)
			
			::SendWorkFlow(cCGC, cMail, cHtml)
		
		EndIf
					
		cBody := ""
		cMail := ""
		nVlrTotCom := 0
		
		If !(cQry)->(Eof())

			cCGC := (cQry)->A3_CGC
			
		EndIf

	EndDo()
		
	(cQry)->(DbCloseArea())
								
Return()


Method GetHeader() Class TWorkFlowComissaoRepresentante
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
	cRet += '        .style_table_footer {
	cRet += '            background: #0c2c65;
	cRet += '            color: #ffffff;
	cRet += '            font: 12px Arial, Helvetica, sans-serif;
	cRet += '            font-weight: bold;
	cRet += '            padding: 5px;
	cRet += '        }        		
	cRet += '				.hide {
	cRet += '						display:none;
	cRet += '				}		
	cRet += '				.btn {
	cRet += '				width: 15px;
	cRet += '				height: 100%;
	cRet += '				border-radius: 30px;
	cRet += '				color: #63a0d7;
	cRet += '				font-weight: bold;
	cRet += '				cursor: pointer;
	cRet += '				font-weight: bold;
	cRet += '				font: 24px Arial, Helvetica, sans-serif;
	cRet += '				}
	cRet += '        -->
	cRet += '    </style>	
	cRet += '</head>
	cRet += '<body>
	cRet += '    <table class="style_table">
	cRet += '        <tr>
	cRet += '            <th class="style_table_header" width="200" rowspan="2" scope="col">'+ Capital(AllTrim(FWEmpName(cEmpAnt))) +'</th>
	cRet += '            <th class="style_table_header" width="500" rowspan="2" scope="col">Relatório de comissões</th>
	cRet += '            <td class="style_table_header" width="200" align="right">Data: '+ dToC(dDataBase) +'</td>
	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td class="style_table_header" align="right">Hora: '+ Time() +'</td>
	cRet += '        </tr>
	cRet += '    </table>	
			
Return(cRet)


Method GetBody(cCodVen, cNomVen, nVlrTotCom, lSeparator) Class TWorkFlowComissaoRepresentante
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()
Local cCodCli := ""
Local cLojCli := ""
Local cNomCli := ""
Local nVlrTit := 0
Local nVlrBas := 0
Local nVlrPer := 0
Local nVlrCom := 0
Local cNumSeq := "000"

	cSQL := " SELECT E3_PREFIXO, E3_NUM, E3_PARCELA, E3_CODCLI, E3_LOJA, E1_VENCTO, E3_EMISSAO, E3_DATA, E3_PEDIDO, E1_VALOR, E3_BASE, E3_COMIS, E3_BAIEMI, E3_PORC, E3_TIPO "
	cSQL += " FROM "+ RetSQLName("SE3") + " SE3 "
	cSQL += " INNER JOIN " + RetSQLName("SE1") + " SE1 "
	cSQL += " ON E3_PREFIXO = E1_PREFIXO "
	cSQL += " AND E3_NUM = E1_NUM "
	cSQL += " AND E3_PARCELA = E1_PARCELA "
	cSQL += " AND E3_TIPO = E1_TIPO "
	cSQL += " AND E3_CODCLI = E1_CLIENTE "
	cSQL += " WHERE E3_FILIAL = " + ValToSQL(xFilial("SE3"))
	cSQL += " AND E3_VEND = " + ValToSQL(cCodVen)
	cSQL += " AND E3_DATA = " + ValToSQL(::oParam:dPagto)
	cSQL += " AND E3_TIPO <> 'RA' "
	cSQL += " AND SE3.D_E_L_E_T_ = '' "
	cSQL += " AND E1_FILIAL = " + ValToSQL(xFilial("SE1"))
	cSQL += " AND SE1.D_E_L_E_T_ = '' "

	cSQL += " UNION ALL "
	
	cSQL += " SELECT E3_PREFIXO, E3_NUM, E3_PARCELA, E3_CODCLI, E3_LOJA, E3_VENCTO, E3_EMISSAO, E3_DATA, E3_PEDIDO, E3_BASE, E3_BASE, E3_COMIS, E3_BAIEMI, E3_PORC, E3_TIPO "
	cSQL += " FROM "+ RetSQLName("SE3")
	cSQL += " WHERE E3_FILIAL = " + ValToSQL(xFilial("SE3"))
	cSQL += " AND E3_VEND = " + ValToSQL(cCodVen)
	cSQL += " AND E3_DATA = " + ValToSQL(::oParam:dPagto)
	cSQL += " AND E3_TIPO <> 'RA' "
	cSQL += " AND E3_CODCLI = '999998' "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY E3_PREFIXO, E3_NUM, E3_PARCELA, E3_TIPO, E3_EMISSAO, E3_CODCLI "
		
	TcQuery cSQL New Alias (cQry)
	
	If !(cQry)->(Eof())
	
		If lSeparator
			
			cRet += ::GetSeparator()
			
		EndIf	
	
		cRet += '    <table class="style_table">
		cRet += '        <tr>
		cRet += '            <th class="style_table_header" colspan="16" scope="col" align="left">Vendedor: '+ cCodVen +' - ' + Capital(cNomVen) +'</th>
		cRet += '        </tr>
		cRet += '        <tr align=center>
		cRet += '            <th class="style_column_header" width="2" scope="col"></th>
		cRet += '            <th class="style_column_header" width="60" scope="col"> Pref/Num/Parc </th>
		cRet += '            <th class="style_column_header" width="20" scope="col"> Tipo </th>
		cRet += '            <th class="style_column_header" width="40" scope="col"> Cliente </th>
		cRet += '            <th class="style_column_header" width="20" scope="col"> Loja </th>
		cRet += '            <th class="style_column_header" width="200" scope="col"> Nome </th>
		cRet += '            <th class="style_column_header" width="60" scope="col">Dt. Comissão</th>
		cRet += '            <th class="style_column_header" width="60" scope="col">Vencto</th>
		cRet += '            <th class="style_column_header" width="60" scope="col">Baixa</th>
		cRet += '            <th class="style_column_header" width="60" scope="col">Pagto</th>
		cRet += '            <th class="style_column_header" width="40" scope="col">Pedido</th>
		cRet += '            <th class="style_column_header" width="60" scope="col">Vlr Título</th>
		cRet += '            <th class="style_column_header" width="60" scope="col">Vlr Base</th>
		cRet += '            <th class="style_column_header" width="60" scope="col">(%)</th>
		cRet += '            <th class="style_column_header" width="60" scope="col">Vlr Comissão</th>
		cRet += '            <th class="style_column_header" width="60" scope="col">Tipo Comissão</th>
		cRet += '        </tr>
		cRet += '        </tr>
	
		While !(cQry)->(Eof())

			DbSelectArea("SC5")
			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(xFilial("SC5") + (cQry)->E3_PEDIDO)) .And. !Empty(SC5->C5_YCLIORI)

				cCodCli := SC5->C5_YCLIORI
				cLojCli := SC5->C5_YLOJORI
				
			Else
			
				cCodCli := (cQry)->E3_CODCLI
				cLoja := (cQry)->E3_LOJA
				
			EndIf
			
			cNomCli := AllTrim(Posicione("SA1", 1, xFilial("SA1") + cCodCli + cLoja, "A1_NOME"))
			
			nVlrTit += (cQry)->E1_VALOR
			nVlrBas += (cQry)->E3_BASE
			nVlrPer += (cQry)->E3_PORC
			nVlrCom += (cQry)->E3_COMIS			
			
			cRet += '        <tr align=center>
			cRet += '            <th class="style_column_rows" width="5" scope="col">
			
			If AllTrim((cQry)->E3_TIPO) == "FT"
				
				cNumSeq := Soma1(cNumSeq)

				cRet += '            		<div class="btn" title="Clique aqui para visualizar os títulos da fatura" 
				cRet += '            					id="btn-show-detalhe-'+ AllTrim((cQry)->E3_PREFIXO) + AllTrim((cQry)->E3_NUM) + AllTrim((cQry)->E3_PARCELA) + cNumSeq + '"
				cRet += '            					onclick="showDetalhe('+ ValToSQL(AllTrim((cQry)->E3_PREFIXO) + AllTrim((cQry)->E3_NUM) + AllTrim((cQry)->E3_PARCELA) + cNumSeq) + ')">+</div>
			
			EndIf
			
			cRet += '            </th>
			cRet += '            <th class="style_column_rows" width="60" scope="col">'+ AllTrim((cQry)->E3_PREFIXO) +'-'+ AllTrim((cQry)->E3_NUM) +'-'+ AllTrim((cQry)->E3_PARCELA) +'</th>
			cRet += '            <th class="style_column_rows" width="20" scope="col">'+ AllTrim((cQry)->E3_TIPO) +'</th>
			cRet += '            <th class="style_column_rows" width="40" scope="col">'+ cCodCli +'</th>
			cRet += '            <th class="style_column_rows" width="20" scope="col">'+ cLoja +'</th>
			cRet += '            <th class="style_column_rows" width="200" scope="col">'+ cNomCli +'</th>
			cRet += '            <th class="style_column_rows" width="60" scope="col">'+ dToC(sToD((cQry)->E3_EMISSAO)) +'</th>
			cRet += '            <th class="style_column_rows" width="60" scope="col">'+ dToC(sToD((cQry)->E1_VENCTO)) +'</th>
			cRet += '            <th class="style_column_rows" width="60" scope="col">'+ dToC(sToD((cQry)->E3_EMISSAO)) +'</th>
			cRet += '            <th class="style_column_rows" width="60" scope="col">'+ dToC(sToD((cQry)->E3_DATA)) +'</th>
			cRet += '            <th class="style_column_rows" width="40" scope="col">'+ (cQry)->E3_PEDIDO +'</th>
			cRet += '            <th class="style_column_rows" width="60" align="right" scope="col">'+ Transform((cQry)->E1_VALOR, X3Picture("E1_VALOR")) +'</th>
			cRet += '            <th class="style_column_rows" width="60" align="right" scope="col">'+ Transform((cQry)->E3_BASE, X3Picture("E3_BASE")) +'</th>
			cRet += '            <th class="style_column_rows" width="60" align="right" scope="col">'+ Transform((cQry)->E3_PORC, X3Picture("E3_PORC")) +'</th>
			cRet += '            <th class="style_column_rows" width="60" align="right" scope="col">'+ Transform((cQry)->E3_COMIS, X3Picture("E3_COMIS")) +'</th>
			cRet += '            <th class="style_column_rows" width="60" scope="col">'+ (cQry)->E3_BAIEMI +'</th>
			cRet += '        </tr>

			If AllTrim((cQry)->E3_TIPO) == "FT"

				cRet += ::GetInvoiceBody((cQry)->E3_PREFIXO, (cQry)->E3_NUM, (cQry)->E3_PARCELA, cNumSeq)

			EndIf
			
			(cQry)->(DbSkip())
				
		EndDo()
		
		nVlrTotCom += nVlrCom

		cRet += '        <tr>
		cRet += '            <td colspan="11" class="style_table_footer">Total do Vendedor: '+ cCodVen +' - ' + Capital(AllTrim(cNomVen)) +'</td>
		cRet += '            <td class="style_table_footer" align="right">'+ Transform(nVlrTit, X3Picture("E1_VALOR")) +'</td>
		cRet += '            <td class="style_table_footer" align="right">'+ Transform(nVlrBas, X3Picture("E3_BASE")) +'</td>
		cRet += '            <td class="style_table_footer" align="right">'+ Transform((nVlrCom / nVlrBas) * 100, X3Picture("E3_PORC")) +'</td>
		cRet += '            <td class="style_table_footer" align="right">'+ Transform(nVlrCom, X3Picture("E3_COMIS")) +'</td>
		cRet += '            <td class="style_table_footer"></td>
		cRet += '        </tr>
	
	EndIf
			
	(cQry)->(DbCloseArea())
		
Return(cRet)


Method GetMail(cMail, cMail_1, cMail_2) Class TWorkFlowComissaoRepresentante
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


Method GetInvoiceBody(cPrefixo, cNumero, cParcela, cNumSeq) Class TWorkFlowComissaoRepresentante
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT RTRIM(E1_PREFIXO) + '-' + RTRIM(E1_NUM) + '-' + RTRIM(E1_PARCELA) AS E1_NUM,	E1_VALOR, E1_PEDIDO "
	cSQL += " FROM " + RetSQLName("SE1")
	cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_PREFIXO = " + ValToSQL(cPrefixo)
	cSQL += " AND E1_FATURA = " + ValToSQL(cNumero)
	cSQL += " AND E1_YPARCFT = " + ValToSQL(cParcela)
	cSQL += " AND E1_TIPO = 'NF' "
	cSQL += " AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)
	
	If !(cQry)->(Eof())
	
		cRet := '        <tr>
		cRet += '            <td colspan="16">
		cRet += '                <table width="40%" id="detalhe-fatura-'+ AllTrim(cPrefixo) + AllTrim(cNumero) + AllTrim(cParcela) + cNumSeq +'" class="hide">
		cRet += '                    <tr>
		cRet += '                        <td colspan="3" class="style_table_header" align="center" style="background: #63a0d7;">Informações - Fatura</td>
		cRet += '                    </tr>
		cRet += '                    <tr>
		cRet += '                        <th class="style_table_header" width="60" scope="col" style="background: #63a0d7;"> Pref/Num/Parc </th>
		cRet += '                        <th class="style_table_header" width="60" scope="col" style="background: #63a0d7;"> Vlr Título </th>
		cRet += '                        <th class="style_table_header" width="40" scope="col" style="background: #63a0d7;"> Pedido </th>
		cRet += '                    </tr>		

		While !(cQry)->(Eof())
		
			cRet += '                    <tr>
			cRet += '                        <th class="style_column_rows" width="60" scope="col">'+ AllTrim((cQry)->E1_NUM) +'</th>
			cRet += '                        <th class="style_column_rows" width="60" align="right" scope="col">'+ Transform((cQry)->E1_VALOR, X3Picture("E1_VALOR")) +'</th>
			cRet += '                        <th class="style_column_rows" width="40" scope="col">'+ (cQry)->E1_PEDIDO +'</th>
			cRet += '                    </tr>

			(cQry)->(DbSkip())
				
		EndDo()

		cRet += '                    <tr>
		cRet += '                        <th colspan="16"><hr style="background: #63a0d7;border:0px;"></th>
		cRet += '                    </tr>		
		cRet += '                </table>
		cRet += '            </td>
		cRet += '        </tr>		
		
	EndIf
	
	(cQry)->(DbCloseArea())		

Return(cRet)


Method GetSeparator() Class TWorkFlowComissaoRepresentante
Local cRet := ""

	cRet := '	<table class="style_table">
	cRet += '		<tr>
	cRet += '			<th colspan="16"><hr size="4" style="background: #63a0d7;border:0px;"></th>
	cRet += '		</tr>
	cRet += '	</table>

Return(cRet)


Method GetFooter(nVlrTotCom) Class TWorkFlowComissaoRepresentante
Local cRet := ""

	cRet += '        <tr>
	cRet += '            <td colspan="14" class="style_table_footer">Total Bruto</td>
	cRet += '            <td class="style_table_footer" align="right">'+ Transform(nVlrTotCom, X3Picture("E1_VALOR")) +'</td>
	cRet += '            <td class="style_table_footer"></td>
	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td colspan="14" class="style_table_footer">Total de IR</td>
	cRet += '            <td class="style_table_footer" align="right">'+ Transform((nVlrTotCom / 100) * ::oParam:nIR, X3Picture("E1_VALOR")) +'</td>
	cRet += '            <td class="style_table_footer"></td>
	cRet += '        </tr>
	cRet += '        <tr>
	cRet += '            <td colspan="14" class="style_table_footer">Total (-) IR</td>
	cRet += '            <td class="style_table_footer" align="right">'+ Transform(nVlrTotCom - ((nVlrTotCom / 100) * ::oParam:nIR), X3Picture("E1_VALOR")) +'</td>
	cRet += '            <td class="style_table_footer"></td>
	cRet += '        </tr>
	cRet += '    </table>
	cRet += '</body>
	cRet += '<script>
	cRet += 'function showDetalhe(id) {
	cRet += '	document.getElementById("detalhe-fatura-"+id).classList.toggle("hide") ' + Chr(13)
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


Method GetMessage() Class TWorkFlowComissaoRepresentante
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
	cRet += '    <p style="text-align:center;"><span style="font-weight:bold; text-decoration:underline;">Orientações para Emissão de Nota Fiscal de Comissão:</span></p>
	cRet += '    <p><span>Favor emitir sua Nota Fiscal de Comissão conforme valores do relatório em anexo e enviá-la para o e-mail nf.comissao@biancogres.com.br até o dia </span><span style="font-weight:bold; text-decoration:underline;">' + dToC(::oParam:dLimNF) + '</span><span> sem falta.</span></span></p>
	cRet += '    <p><span>Atenção! Caso o valor do Imposto de Renda calculado seja menor ou igual a R$ 10.00, este imposto não poderá ser destacado na NF a ser emitida</span></p>
	cRet += '    <p><span>Favor colocar no corpo da nota fiscal: Banco, Agência e Conta Corrente.</span></p>
	cRet += '    <p><span>Ficar atento para emitir a NF para a empresa correta, deverá ser sempre a mesma constante no relatório.</span></p>
	cRet += '	<p><span>Importante lembrar que esta comissão só será paga se a nota fiscal do mês anterior estiver na fábrica.</span></p>
	cRet += '	<p><span>Atenciosamente,</span></p>
	cRet += '    <p><span style="font-weight:bold;">GRUPO BIANCOGRES</span></p>
	cRet += '</body>
	cRet += '</html>
	
Return(cRet)


Method SendWorkFlow(cCGC, cMail, cHtml) Class TWorkFlowComissaoRepresentante
Local cFile := ""
Local oMail := TAFMail():New()

	cFile := "\P10\Relato\Rep\comissao\CR_" + AllTrim(cCGC) + "_" + cEmpAnt + "_" + cFilAnt + "_" + Month2Str(dDataBase) + ".html"
	
	If File(cFile)

		FErase(cFile)
		
	EndIf	
	
	fHandle := fCreate(cFile)
	FWrite(fHandle, cHtml)	
	fClose(fHandle)
		
	oMail:cTo := cMail
	oMail:cSubject := "Demonstrativos de comissão referente a " + U_DATAR(::oParam:dPagto, 4)	
	oMail:cBody := ::GetMessage()	
	oMail:cAttachFile := cFile

	oMail:Send()
	
Return()
