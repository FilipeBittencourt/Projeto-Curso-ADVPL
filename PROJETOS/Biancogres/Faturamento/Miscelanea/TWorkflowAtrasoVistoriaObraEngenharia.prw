#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWorkflowAtrasoVistoriaObraEngenharia
@author Tiago Rossini Coradini
@since 19/09/2019
@version 1.0
@description Classe para controle do Workflow de Vistorias em Obras de Engenharia com Atrasos
@obs Ticket: 19122
@type class
/*/
 
#DEFINE _NUMERO 1
#DEFINE _DATNF 2
#DEFINE _DATVIS 3
#DEFINE _ATRASO 4
#DEFINE _CLIENT 5
#DEFINE _NUMOBR 6
#DEFINE _OBRA 7
#DEFINE _VEND 8
#DEFINE _DOC 9
#DEFINE _SERIE 10
#DEFINE _ITEM 11
#DEFINE _DESC 12
#DEFINE _LOTE 13
#DEFINE _QUANT 14


Class TWorkflowAtrasoVistoriaObraEngenharia From LongClassName 
	
	Data cType // 1=Representante; 2=Gestor
	Data dData
		
	Method New() Constructor
	Method Process()
	Method GetHeader(cNomVen)
	Method GetBody(aItem)	
	Method GetFooter()
	Method GetMessage()
	Method GetMail(cMail_1, cMail_2)	
	Method SendWorkFlow(cCodVen, cMail, cHtml)
	
EndClass


Method New() Class TWorkflowAtrasoVistoriaObraEngenharia

	::cType := "1"
	::dData := dDataBase
				
Return()


Method Process() Class TWorkflowAtrasoVistoriaObraEngenharia
Local cSQL := ""
Local cQry := GetNextAlias()
Local cCodVen := ""
Local cNomVen := ""
Local aItem := {}
Local cMail := ""
Local cMail_1 := ""
Local cMail_2 := ""
Local cHtml := ""

	cSQL := " SELECT ZKS_NUMERO, ZKS_DATA, ZKS_DATPRE, DATEDIFF(DAY, ZKS_DATPRE, " + ValToSQL(::dData) + ") AS ZKS_ATRASO, ZKS_CLIENT + '-' + ZKS_LOJA + '-' + LTRIM(A1_NOME) AS ZKS_CLIENT, ZKS_NUMOBR, 
	cSQL += " ISNULL(
	cSQL += " (
	cSQL += " 	SELECT ZZO_OBRA
	cSQL += " 	FROM "+ RetFullName("ZZO", "01")
	cSQL += " 	WHERE ZZO_FILIAL = " + ValToSQL(cFilAnt)
	cSQL += " 	AND ZZO_NUM = ZKS_NUMOBR
	cSQL += " 	AND D_E_L_E_T_ = ''	
	cSQL += " ), '') AS ZZO_OBRA, 
	cSQL += " ZKS_VEND, ZKS_VEND + '-' + LTRIM(A3_NOME) AS A3_NOME, ZKS_DOC, ZKS_SERIE, ZKS_ITEM, RTRIM(ZKS_PRODUT) + '-' + LTRIM(B1_DESC) AS B1_DESC, ZKS_LOTE, ZKS_QUANT, A3_YEMAIL, A3_EMAIL  
	cSQL += " FROM "+ RetSQLName("ZKS") + " AS ZKS
	cSQL += " INNER JOIN "+ RetSQLName("SA1") + " AS SA1
	cSQL += " ON ZKS_CLIENT = A1_COD
	cSQL += " AND ZKS_LOJA = A1_LOJA
	cSQL += " INNER JOIN "+ RetSQLName("SA3") + "  AS SA3
	cSQL += " ON ZKS_VEND = A3_COD
	cSQL += " INNER JOIN "+ RetSQLName("SB1") + "  AS SB1
	cSQL += " ON ZKS_PRODUT = B1_COD	
	cSQL += " WHERE ZKS_FILIAL = " + ValToSQL(xFilial("ZKS"))
	cSQL += " AND ZKS_DATVIS = '' "
	
	//ticket 31378: enviar notificação para representantes de todos em atraso e não apenas os que forem vistoriados nos próximos 15 dias
	cSQL += " AND DATEDIFF(DAY, ZKS_DATPRE, " + ValToSQL(::dData) + ")" + If (::cType == "1", " > 0 ", " > 15 ")

	cSQL += " AND ZKS.D_E_L_E_T_ = '' 
	cSQL += " AND A1_FILIAL = " + ValToSQL(xFilial("SA1"))
	cSQL += " AND SA1.D_E_L_E_T_ = '' 
	cSQL += " AND A3_FILIAL = " + ValToSQL(xFilial("SA3"))
	cSQL += " AND SA3.D_E_L_E_T_ = '' 
	cSQL += " AND B1_FILIAL = " + ValToSQL(xFilial("SB1"))
	cSQL += " AND SB1.D_E_L_E_T_ = '' "
	cSQL += " ORDER BY ZKS_VEND, ZKS_DATPRE, ZKS_CLIENT, ZKS_LOJA
	
	TcQuery cSQL New Alias (cQry)
		
	If !Empty(cCodVen := (cQry)->ZKS_VEND)
		
		If ::cType == "1"
		
			While !(cQry)->(Eof())
					
				cNomVen := AllTrim((cQry)->A3_NOME)
				
				cMail_1 := (cQry)->A3_YEMAIL
			
				cMail_2 := (cQry)->A3_EMAIL
				
				While cCodVen == (cQry)->ZKS_VEND
																
					aAdd(aItem, {(cQry)->ZKS_NUMERO, (cQry)->ZKS_DATA, (cQry)->ZKS_DATPRE, (cQry)->ZKS_ATRASO, (cQry)->ZKS_CLIENT, (cQry)->ZKS_NUMOBR,;
											 (cQry)->ZZO_OBRA, cNomVen, (cQry)->ZKS_DOC, (cQry)->ZKS_SERIE, (cQry)->ZKS_ITEM, (cQry)->B1_DESC, (cQry)->ZKS_LOTE, (cQry)->ZKS_QUANT})
									
					cCodVen := (cQry)->ZKS_VEND
					
					(cQry)->(DbSkip())
					
				EndDo()
							
				cHtml	:= ::GetHeader(cNomVen)
				cHtml	+= ::GetBody(aItem)
				cHtml	+= ::GetFooter()	
				
				If !Empty(cMail := ::GetMail(cMail_1, cMail_2))
				
					::SendWorkFlow(cCodVen, cMail, cHtml)
					
				EndIf
										
				aItem := {}
				
				cMail := ""
				
				If !(cQry)->(Eof())
		
					cCodVen := (cQry)->ZKS_VEND
					
				EndIf
					
			EndDo()
			
		ElseIf ::cType == "2"
			
			While !(cQry)->(Eof())
			
				aAdd(aItem, {(cQry)->ZKS_NUMERO, (cQry)->ZKS_DATA, (cQry)->ZKS_DATPRE, (cQry)->ZKS_ATRASO, (cQry)->ZKS_CLIENT, (cQry)->ZKS_NUMOBR,;
										(cQry)->ZZO_OBRA, AllTrim((cQry)->A3_NOME), (cQry)->ZKS_DOC, (cQry)->ZKS_SERIE, (cQry)->ZKS_ITEM, (cQry)->B1_DESC, (cQry)->ZKS_LOTE, (cQry)->ZKS_QUANT})
			
			  (cQry)->(DbSkip())
							
			EndDo()
			
			cHtml	:= ::GetHeader()
			cHtml	+= ::GetBody(aItem)
			cHtml	+= ::GetFooter()
			
			::SendWorkFlow(,, cHtml)
											
		EndIf
						
		(cQry)->(DbCloseArea())
		
	EndIf

Return()


Method GetMail(cMail_1, cMail_2) Class TWorkflowAtrasoVistoriaObraEngenharia
Local cRet := ""

	If !Empty(AllTrim(cMail_1))
	
		cRet := AllTrim(cMail_1)
	
	ElseIf !Empty(AllTrim(cMail_2))
	
		cRet := AllTrim(cMail_2)
	
	EndIf
	
Return(cRet)


Method GetHeader(cNomVen) Class TWorkflowAtrasoVistoriaObraEngenharia
Local cRet := ""

	Default cNomVen := ""

	cRet += '<!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cRet += '<html xmlns="http://www.w3.org/1999/xhtml">
	cRet += '<head>
	cRet += '    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cRet += '    <title>Workflow-Biancigres</title>
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
	cRet += '            <th class="style_table_header" align="center" scope="col">Relatório de Vistorias em Obras com Atrasos</th>
	cRet += '        </tr>
	cRet += '    </table>
	cRet += '    <table class="style_table">			

	If ::cType == "1"

		cRet += '        <tr>
		cRet += '            <th class="style_table_header" colspan="13" align="left" scope="col">Vendedor: '+ AllTrim(cNomVen) +'</th>
		cRet += '        </tr>		
		cRet += '        <tr align=center>
		cRet += '            <th class="style_column_header" width="40" align="left" scope="col">Número</th>
		cRet += '            <th class="style_column_header" width="60" align="left" scope="col">Dt. Nota Fiscal</th>
		cRet += '            <th class="style_column_header" width="60" align="left" scope="col">Dt. Previão Vistoria</th>
		cRet += '            <th class="style_column_header" width="50" align="left" scope="col">Atraso (Dias)</th>
		cRet += '            <th class="style_column_header" width="200" align="left" scope="col">Cliente</th>	
		cRet += '            <th class="style_column_header" width="50" align="left" scope="col">Núm. Obra</th>
		cRet += '            <th class="style_column_header" width="80" align="left" scope="col">Obra</th>	
		cRet += '            <th class="style_column_header" width="40" align="left" scope="col">Nota</th>
		cRet += '            <th class="style_column_header" width="20" align="left" scope="col">Série</th>
		cRet += '            <th class="style_column_header" width="20" align="left" scope="col">Item</th>
		cRet += '            <th class="style_column_header" width="200" align="left" scope="col">Produto</th>		
		cRet += '            <th class="style_column_header" width="40" align="left" scope="col">Lote</th>
		cRet += '            <th class="style_column_header" width="40" align="right" scope="col">Qtd.</th>
		cRet += '        </tr>
		cRet += '        </tr>
		
	ElseIf ::cType == "2"
	
		cRet += '        <tr align=center>
		cRet += '            <th class="style_column_header" width="40" align="left" scope="col">Número</th>
		cRet += '            <th class="style_column_header" width="200" align="left" scope="col">Vendedor</th>
		cRet += '            <th class="style_column_header" width="60" align="left" scope="col">Dt. Nota Fiscal</th>
		cRet += '            <th class="style_column_header" width="60" align="left" scope="col">Dt. Previão Vistoria</th>
		cRet += '            <th class="style_column_header" width="50" align="left" scope="col">Atraso (Dias)</th>
		cRet += '            <th class="style_column_header" width="200" align="left" scope="col">Cliente</th>	
		cRet += '            <th class="style_column_header" width="50" align="left" scope="col">Núm. Obra</th>
		cRet += '            <th class="style_column_header" width="80" align="left" scope="col">Obra</th>	
		cRet += '            <th class="style_column_header" width="40" align="left" scope="col">Nota</th>
		cRet += '            <th class="style_column_header" width="20" align="left" scope="col">Série</th>
		cRet += '            <th class="style_column_header" width="20" align="left" scope="col">Item</th>
		cRet += '            <th class="style_column_header" width="200" align="left" scope="col">Produto</th>		
		cRet += '            <th class="style_column_header" width="40" align="left" scope="col">Lote</th>
		cRet += '            <th class="style_column_header" width="40" align="right" scope="col">Qtd.</th>
		cRet += '        </tr>
		cRet += '        </tr>
	
	EndIf
			
Return(cRet)
	

Method GetBody(aItem) Class TWorkflowAtrasoVistoriaObraEngenharia
Local cRet := ""
Local nCount := 1

	While nCount <= Len(aItem)			
	
		cRet += '        <tr align=center>
		cRet += '            <th class="style_column_rows" width="40" align="left" scope="col">'+ aItem[nCount, _NUMERO] +'</th>

		If ::cType == "2"
			
			cRet += '            <th class="style_column_rows" width="100" align="left" scope="col">'+ aItem[nCount, _VEND] +'</th>
			
		EndIf

		cRet += '            <th class="style_column_rows" width="60" align="left" scope="col">'+ dToC(sToD(aItem[nCount, _DATNF])) +'</th>
		cRet += '            <th class="style_column_rows" width="60" align="left" scope="col">'+ dToC(sToD(aItem[nCount, _DATVIS])) +'</th>
		cRet += '            <th class="style_column_rows" width="50" align="left" scope="col">'+ cValToChar(aItem[nCount, _ATRASO]) +'</th>			
		cRet += '            <th class="style_column_rows" width="200" align="left" scope="col">'+ aItem[nCount, _CLIENT] +'</th>	
		cRet += '            <th class="style_column_rows" width="50" align="left" scope="col">'+ aItem[nCount, _NUMOBR] +'</th>
		cRet += '            <th class="style_column_rows" width="80" align="left" scope="col">'+ aItem[nCount, _OBRA] +'</th>	
		cRet += '            <th class="style_column_rows" width="40" align="left" scope="col">'+ aItem[nCount, _DOC] +'</th>
		cRet += '            <th class="style_column_rows" width="20" align="left" scope="col">'+ aItem[nCount, _SERIE] +'</th>
		cRet += '            <th class="style_column_rows" width="20" align="left" scope="col">'+ aItem[nCount, _ITEM] +'</th>
		cRet += '            <th class="style_column_rows" width="200" align="left" scope="col">'+ aItem[nCount, _DESC] +'</th>		
		cRet += '            <th class="style_column_rows" width="40" align="left" scope="col">'+ aItem[nCount, _LOTE] +'</th>
		cRet += '            <th class="style_column_rows" width="40" align="right" scope="col">'+ cValToChar(aItem[nCount, _QUANT]) +'</th>
		cRet += '        </tr>
	
		nCount++
			
	EndDo	
				
Return(cRet)


Method GetFooter() Class TWorkflowAtrasoVistoriaObraEngenharia
Local cRet := ""

	cRet := '    </table>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


Method GetMessage() Class TWorkflowAtrasoVistoriaObraEngenharia
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

	If ::cType == "1"

		cRet += '    <p><span>Prezado Representante,</span></p>
		cRet += '    <p><span>Segue em anexo, relação de obras com datas de vistoria vencidas, o pagamento de comissão das mesmas serão bloqueadas até que seja informada a realização da vistoria.</span></p>
		
	ElseIf ::cType == "2"

		cRet += '    <p><span>Prezados Gestores,</span></p>
		cRet += '    <p><span>Segue em anexo, relação de obras com datas de vistoria vencidas.</span></p>
	
	EndIf
	
	cRet += '	<p><span>Atenciosamente,</span></p>
	cRet += '    <p><span style="font-weight:bold;">GRUPO BIANCOGRES</span></p>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


Method SendWorkFlow(cCodVen, cMail, cHtml) Class TWorkflowAtrasoVistoriaObraEngenharia
Local cFile := ""
Local oMail := TAFMail():New()

	Default cCodVen := "000000"
	Default cMail := ""

	cFile := Lower("\P10\vistoria_obra\atraso\atraso_" + cEmpAnt + "_" + cCodVen + "_" + dToS(::dData) + "_" + StrZero(Seconds() * 3500, 10) + ".html")
	
	If File(cFile)

		fErase(cFile)
		
	EndIf	
	
	fHandle := fCreate(cFile)
	FWrite(fHandle, cHtml)	
	fClose(fHandle)
		
	//Ticket 27358 (Pablo S Nascimento 13/10/2020)
	/*Os emails abaixo antes fixos no código foram transferidos para a parametrização de workflow com os nomes:
	 WVOEA01 - Workflow Vistorias em Obras de Engenharia com Atrasos (atraso a partir de 1 dia = Gerencia de Vendas) 
	 WVOEA02 - Workflow Vistorias em Obras de Engenharia com Atrasos (atraso maior que 14 dias = Gerencia de Vendas + Diretor + Superintendente) */	
			
	If ::cType == "1"
		
		oMail:cTo := cMail
		
		//oMail:cCC := "alexandre.patelli@biancogres.com.br;camila.oliveira@biancogres.com.br"
		oMail:cCC := U_EmailWF("WVOEA01","")
		
	ElseIf ::cType == "2"
	
		//oMail:cTo := "alexandre.patelli@biancogres.com.br;valmir.vali@biancogres.com.br;camerino.filho@biancogres.com.br"
		oMail:cTo := U_EmailWF("WVOEA02","")
	
	EndIf	
	
	oMail:cSubject := "BIANCOGRES | Vistorias em Obras de Engenharia com Atrasos"	
	oMail:cBody := ::GetMessage()
	oMail:cAttachFile := cFile

	oMail:Send()
			
Return()
