#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWorkflowEngenheiroObraEngenharia
@author Tiago Rossini Coradini
@since 10/02/2019
@version 1.0
@description Classe para envio do Workflow ao Engenheiro da Obra de Engenharia
@obs Ticket: 19122
@type class
/*/

Class TWorkflowEngenheiroObraEngenharia From LongClassName 
	
	Method New() Constructor
	Method GetMessage()	
	Method Send(cMail, cMailVend)
	
EndClass


Method New() Class TWorkflowEngenheiroObraEngenharia
				
Return()


Method GetMessage() Class TWorkflowEngenheiroObraEngenharia
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
	cRet += '    <p><span>Prezado Engenheiro,</span></p>
	cRet += '    <p><span>Segue em anexo documento explicativo com orientação quanto ao Recebimento, Armazenamento e Assentamento dos produtos Biancogres.</span></p>		
	cRet += '	<p><span>Atenciosamente,</span></p>
	cRet += '    <p><span style="font-weight:bold;">GRUPO BIANCOGRES</span></p>
	cRet += '</body>
	cRet += '</html>
		
Return(cRet)


Method Send(cMail, cMailVend) Class TWorkflowEngenheiroObraEngenharia
Local cFile := ""
Local oMail := TAFMail():New()

	If !Empty(cMail)
	
		cFile := Lower("\P10\vistoria_obra\orientacao\orientacoes_biancogres.pdf"	)
				
		oMail:cTo := cMail
		oMail:cCc := cMailVend
		oMail:cSubject := "BIANCOGRES | Orientações para recebimento, armazenamento e assentamento"	
		oMail:cBody := ::GetMessage()
		oMail:cAttachFile := cFile
	
		oMail:Send()
		
	EndIf
	
Return()