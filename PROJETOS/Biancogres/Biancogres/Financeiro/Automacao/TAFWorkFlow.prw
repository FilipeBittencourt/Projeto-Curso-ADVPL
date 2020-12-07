#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFWorkFlow
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Classe para tratamento de workflow (Html)
@type class
/*/

Class TAFWorkFlow From LongClassName

	Data cIDProc // Identificador do processo	
	Data cDate // Data 
	Data cTime // Hora
	Data cType // Tipo:P=Contas a Pagar; R=Contas a Receber; T=Tesouraria 
	Data cDscType // Tipo:P=Contas a Pagar; R=Contas a Receber; T=Tesouraria 
	Data cMethod // Method executado
	Data cEmp // Empresa
	Data cFil // Filial
	Data oLst // Lista de campos e registros do workflow	
	
	Data cTo // E-mail dos usuarios que receberao o workflow
	Data cSubject // Tituto do workflow
	Data cHtml // Codigo Html do workflow: Header + Body + Footer
	Data oMail // Objeto para envio de e-mail	
	
	Method New() Constructor
	Method GetHtml()
	Method GetHeader()
	Method GetBody()
	Method GetcFooter()
	Method Send()
	Method SetConsoleLog()

EndClass


Method New() Class TAFWorkFlow

	::cIDProc := ""	
	::cDate := "" 
	::cTime := ""
	::cType := "" 
	::cMethod := ""
	::cEmp := ""
	::cFil := ""
	::oLst := ArrayList():New()	

	::cTo := ""
	::cSubject := ""
	::cHtml := ""	
	::oMail := TAFMail():New()

Return()


Method GetHtml() Class TAFWorkFlow

	::cHtml := ""

	::cHtml	:= ::GetHeader()
	::cHtml	+= ::GetBody()
	::cHtml	+= ::GetcFooter()

Return(::cHtml)


Method GetHeader() Class TAFWorkFlow
Local cRet := ""

	cRet := ' <!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	cRet += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
	cRet += ' <head> '
	cRet += '     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	cRet += '     <title>Workflow</title> '
	cRet += '     <style type="text/css"> '
	cRet += '         <!-- ' 
	cRet += ' 		.style_table{ '
	cRet += ' 			border:0; '
	cRet += ' 			cellpadding:0; '
	cRet += ' 			cellspacing:0; '
	cRet += ' 			width:100%; '
	cRet += ' 		} '
	cRet += '     .style_table_Header{ '
	cRet += ' 				color: #000; '
	cRet += ' 				font: 12px Arial, Helvetica, sans-serif; '
	cRet += ' 				padding: 0px; '
	cRet += ' 		} '    		
	cRet += '     .style_column_header{ '
	cRet += '         background: #0c2c65; '
	cRet += '         color: #ffffff; '
	cRet += '         font: 12px Arial, Helvetica, sans-serif; '
	cRet += ' 				font-weight: bold; '
	cRet += ' 				padding: 0px; '
	cRet += '     } '
	cRet += ' 		.style_column_rows{ '
	cRet += '         color: #000; '
	cRet += '         font: 12px Arial, Helvetica, sans-serif; '
	cRet += ' 				padding: 0px; '
	cRet += '     } '
	cRet += '         --> '
	cRet += '     </style> '
	cRet += ' </head> '
	cRet += ' <body> '
	cRet += '     <table class="style_table" align="left"> '	
	cRet += ' 			<tr> '
	cRet += ' 			<td class="style_table_Header" colspan="' + cValToChar(::oLst:GetCount()) + '"> '
	cRet += ' 				<table class="style_table"> '
	cRet += ' 					<tr> '
	cRet += ' 						<td style="text-align:left;"><span style="font-weight:bold;">Processo: </span>' + ::cIDProc + ' </td> '
	cRet += ' 						<td style="text-align:right;"><span style="font-weight:bold;">Data/Hora: </span>' + ::cDate + ' / ' + ::cTime +' </td> '
	cRet += ' 					</tr> '
	cRet += ' 					<tr> '
	cRet += ' 						<td style="text-align:left;"><span style="font-weight:bold;">Tipo: </span>' + ::cDscType +' </td> '
	cRet += ' 					</tr>	'
	cRet += ' 					<tr> '
	cRet += ' 						<td style="text-align:left;"><span style="font-weight:bold;">Metodo: </span>' + ::cMethod +' </td> '
	cRet += ' 					</tr>	'
	cRet += ' 					<tr> '
	cRet += ' 						<td style="text-align:left;"><span style="font-weight:bold;">Empresa/Filial: </span>' + ::cEmp +' / ' + ::cFil +' </td> '
	cRet += ' 					</tr>	'
	cRet += ' 				</table> '
	cRet += ' 			</td> '
	cRet += ' 			</tr> '

Return(cRet)


Method GetBody() Class TAFWorkFlow
Local cRet := ""
Local nColumn := 0
Local nRow := 0

	cRet := ' <tr align=center> '

	For nColumn := 1 To ::oLst:GetCount()		 

		cRet += ' <th class="style_column_header" width="' + cValToChar(::oLst:GetItem(nColumn):nWidth) + '"> ' + ::oLst:GetItem(nColumn):cTitle + ' </th> '

	Next

	cRet += ' </tr> '

	For nRow := 1 To ::oLst:GetItem(1):oRow:GetCount()

		cRet += ' <tr align=center> '

		For nColumn := 1 To ::oLst:GetCount()

			cRet += ' <th class="style_column_rows" width="' + cValToChar(::oLst:GetItem(nColumn):nWidth) + '"> ' + ::oLst:GetItem(nColumn):oRow:GetItem(nRow) + ' </th> '

		Next

		cRet += ' <tr> ' 
		cRet += ' <td style="border-bottom:1px solid #0c2c65;" colspan="' + cValToChar(::oLst:GetCount()) + '"></td> '
		cRet += ' </tr> '

		cRet += ' </tr> '

	Next	

Return(cRet)


Method GetcFooter() Class TAFWorkFlow
Local cRet := ""

	cRet += ' </table> '
	cRet += ' </body> '
	cRet += ' </html> '

Return(cRet)


Method Send() Class TAFWorkFlow

	::oMail:cTo := ::cTo
	::oMail:cSubject := ::cSubject
	::oMail:cBody := ::GetHtml()

	If ::oMail:Send()
	
		::SetConsoleLog()
	
	EndIf
	
Return()


Method SetConsoleLog() Class TAFWorkFlow
Local cLog := ""

	cLog := Replicate("-", 120) + Chr(13)
	cLog += "[" + Dtoc(Date()) + Space(1) + Time() + "] -- Automacao Financeira -- Envio de Workflow" + Chr(13)
	cLog += "[Thread: " + AllTrim(cValToChar(ThreadId())) + "]" + Chr(13)
	cLog += "[Empresa: " + cEmpAnt + "]" + Chr(13)
	cLog += "[Filial: " + cFilAnt + "]" + Chr(13)	
	cLog += "[Processo: " + ::cIDProc + "]" + Chr(13)
	cLog += "[Operacao: " + AllTrim(::cDscType) + "]" + Chr(13)
	cLog += "[Metodo: " + AllTrim(::cMethod) + "]" + Chr(13)
	cLog += "[Email: " + AllTrim(::cTo) + "]" + Chr(13)
	cLog += Replicate("-", 120)
	
	ConOut(Chr(13) + cLog)

Return()