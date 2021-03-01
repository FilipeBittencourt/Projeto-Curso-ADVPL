#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWComunicado
@author Tiago Rossini Coradini
@since 22/02/2019
@version 1.0
@description Classe para envio de comunicados
@obs Ticket: 11376
@history 12/11/2019, Ranisses A. Corona, Melhoria para considerar o envio do e-mail para somente os cliente ativos.
@history 19/02/2021, Ranisses A. Corona, Envio comunicado FIDC.
@type class
/*/

// TITULOS DAS JANELAS
#DEFINE TIT_WND "Envio de comunicados"

Class TWComunicado From LongClassName

	Data oWindow  
	Data oContainer	
	Data oPanel
	Data cIdBox
	Data oFntBold	
	Data cSendTo
	Data aSendTo
	Data cTitle
	Data oEditor
	
	Data cTo // E-mail dos usuarios que receberao o workflow
	Data cSubject // Tituto do workflow
	Data cHtml // Codigo Html do workflow: Header + Body
	Data oMail // Objeto para envio de e-mail		
		
	Method New() Constructor
	Method LoadInterface()
	Method LoadWindow()
	Method LoadContainer()
	Method LoadComponent()
	Method Activate()	 
	Method Validate()
	Method VldSelOpt()
	Method VldTitle() 
	Method VldEditor()
	Method Confirm()
	Method Send()
	Method GetSQL()
	Method GetHtml()
	Method GetHeader()
	Method GetBody()

EndClass


Method New() Class TWComunicado

	::oWindow := Nil	
	::oContainer := Nil	
	::oPanel := Nil
	::cIdBox := ""
	::oFntBold := TFont():New('Arial',,14,,.T.)	

	::cSendTo := Space(14)

	::aSendTo := {}

	aAdd(::aSendTo, "1-Clientes")
	aAdd(::aSendTo, "2-Fornecedores")
	aAdd(::aSendTo, "3-Vendedores")
	
	::cTitle := Space(200)

	::cTo := ""
	::cSubject := ""
	::cHtml := ""	
	::oMail := TAFMail():New()
	
Return()


Method LoadInterface() Class TWComunicado

	::LoadWindow()

	::LoadContainer()

	::LoadComponent()

Return()


Method LoadWindow() Class TWComunicado
Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()
	::oWindow:SetBackground(.T.) 
	::oWindow:SetTitle(TIT_WND)
	::oWindow:SetEscClose(.F.)
	::oWindow:SetSize(260, 300)
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()
	
	::oWindow:AddOKButton({|| ::Confirm() })
	::oWindow:AddCloseButton()

Return()


Method LoadContainer() Class TWComunicado

	::oContainer := FWFormContainer():New()
	
	::cIdBox := ::oContainer:CreateHorizontalBox(100)
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadComponent() Class TWComunicado

	::oPanel := ::oContainer:GetPanel(::cIdBox)
	
	oSay := TSay():Create(::oPanel)
	oSay:cName := "oSay"
	oSay:cCaption := "Enviar para"
	oSay:nLeft := 00
	oSay:nTop := 00
	oSay:nWidth := 85
	oSay:nHeight := 20
	oSay:cToolTip := "Enviar para"
	oSay:oFont := ::oFntBold
	oSay:Align := CONTROL_ALIGN_TOP
			
	oCbxSendTo := TComboBox():Create(::oPanel)
	oCbxSendTo:cName := "oCbxSendTo"
	oCbxSendTo:nLeft := 00
	oCbxSendTo:nTop := 00
	oCbxSendTo:nWidth := 120
	oCbxSendTo:nHeight := 30
	oCbxSendTo:bSetGet := bSetGet(::cSendTo)
	oCbxSendTo:aItems := ::aSendTo
	oCbxSendTo:nAt := 1
	oCbxSendTo:cToolTip := "Enviar para"
	oCbxSendTo:Align := CONTROL_ALIGN_TOP

	oSay := TSay():Create(::oPanel)
	oSay:cName := ""
	oSay:cCaption := ""
	oSay:nLeft := 00
	oSay:nTop := 00
	oSay:nWidth := 85
	oSay:nHeight := 20
	oSay:cToolTip := ""
	oSay:Align := CONTROL_ALIGN_TOP

	oSay := TSay():Create(::oPanel)
	oSay:cName := "oSay"
	oSay:cCaption := "Título"
	oSay:nLeft := 00
	oSay:nTop := 00
	oSay:nWidth := 85
	oSay:nHeight := 20
	oSay:cToolTip := "Informe o título do comunicado"
	oSay:oFont := ::oFntBold	
	oSay:Align := CONTROL_ALIGN_TOP
	
	oGetTitle := TGet():Create(::oPanel)
	oGetTitle:cName := "oGetTitle"
	oGetTitle:nLeft := 00
	oGetTitle:nTop := 00
	oGetTitle:nWidth := 85
	oGetTitle:nHeight := 30
	oGetTitle:cVariable := "::cTitle"
	oGetTitle:bSetGet := bSetGet(::cTitle)
	oGetTitle:cToolTip := "Informe o título do comunicado"
	oGetTitle:Align := CONTROL_ALIGN_TOP

	oSay := TSay():Create(::oPanel)
	oSay:cName := ""
	oSay:cCaption := ""
	oSay:nLeft := 00
	oSay:nTop := 00
	oSay:nWidth := 85
	oSay:nHeight := 20
	oSay:cToolTip := ""
	oSay:Align := CONTROL_ALIGN_TOP

	oSay := TSay():Create(::oPanel)
	oSay:cName := "oSay"
	oSay:cCaption := "Mensagem"
	oSay:nLeft := 00
	oSay:nTop := 00
	oSay:nWidth := 85
	oSay:nHeight := 20
	oSay:cToolTip := "Informe mensagem do comunicado"
	oSay:oFont := ::oFntBold
	oSay:Align := CONTROL_ALIGN_TOP

	::oEditor := TSimpleEditor():Create(::oPanel)
	::oEditor:TextFormat(2)
	::oEditor:Align := CONTROL_ALIGN_ALLCLIENT

Return()


Method Activate() Class TWComunicado	

	::LoadInterface()
	
	::oWindow:Activate()

Return()


Method Validate() Class TWComunicado
Local lRet := .T.

	lRet := ::VldSelOpt() .And. ::VldTitle() .And. ::VldEditor()
	
Return(lRet)


Method VldSelOpt() Class TWComunicado
Local lRet := .T.
Local cSelOpt := SubStr(::cSendTo, 1, 1)

	If cSelOpt == "1" .Or. cSelOpt == "3"

		lRet := U_VALOPER("055", .T., .T.)

	ElseIf cSelOpt == "2"

		lRet := U_VALOPER("056", .T., .T.)
		
	EndIf

Return(lRet)


Method VldTitle() Class TWComunicado
Local lRet := .T.

	If Empty(AllTrim(::cTitle))
	
		lRet := .F.
		
		MsgStop("Atenção, é obrigatório o preenchimento do título do comunicado.")
	
	EndIf

Return(lRet)


Method VldEditor() Class TWComunicado
Local lRet := .T.

	If Empty(AllTrim(::oEditor:RetText()))
	
		lRet := .F.
		
		MsgStop("Atenção, é obrigatório o preenchimento da mensagem do comunicado.")
	
	EndIf

Return(lRet)


Method Confirm() Class TWComunicado

	
	If ::Validate()
		
		MsgAlert('<p font="color:red">Imagens copiadas para caixa de texto, não serão enviadas no e-mail.</p>', 'Atenção')
		
		If MsgYesNo("Deseja realmente enviar o comunicado para os " + AllTrim(SubStr(::cSendTo, 3, Len(::cSendTo))) + "?")
			
			U_BIAMsgRun("Enviando comunicado para os " + AllTrim(SubStr(::cSendTo, 3, Len(::cSendTo))) + "...", "Aguarde!", {|| ::Send() })
			
			MsgInfo("Comunicado enviado com sucesso!")
			
		EndIf
	
	EndIf

Return()


Method Send() Class TWComunicado
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := ::GetSQL()
	
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())	
		
		::oMail:cTo			:= AllTrim((cQry)->EMAIL)
		::oMail:cSubject	:= ::cTitle
		::oMail:cBody		:= ::GetHtml()
	
		::oMail:Send()		

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())
	
Return()


Method GetSQL() Class TWComunicado
Local cSelOpt := SubStr(::cSendTo, 1, 1)
Local cSQL := ""

	If cSelOpt == "1"
		
		cSQL := "" 
		cSQL += " WITH TBLCLIENTE AS "
		cSQL += " (SELECT E1_CLIENTE AS CLIENTE, E1_LOJA AS LOJA "
		cSQL += " FROM SE1010 WITH (NOLOCK) " 
		//cSQL += " WHERE E1_EMISSAO >= CONVERT(varchar,DATEADD(d,-365,GETDATE()),112) AND "
		cSQL += " WHERE E1_EMISSAO >= CONVERT(varchar,DATEADD(d,-90,GETDATE()),112) AND "
		cSQL += " 	  E1_TIPO IN ('NF','FT') AND "
		cSQL += " 	  D_E_L_E_T_ = '' "
		cSQL += " GROUP BY E1_CLIENTE, E1_LOJA "
		cSQL += " UNION "
		cSQL += " SELECT E1_CLIENTE, E1_LOJA "
		cSQL += " FROM SE1050 WITH (NOLOCK) "
		//cSQL += " WHERE E1_EMISSAO >= CONVERT(varchar,DATEADD(d,-365,GETDATE()),112) AND "
		cSQL += " WHERE E1_EMISSAO >= CONVERT(varchar,DATEADD(d,-90,GETDATE()),112) AND "		
		cSQL += " 	  E1_TIPO IN ('NF','FT') AND "
		cSQL += " 	  D_E_L_E_T_ = '' "
		cSQL += " GROUP BY E1_CLIENTE, E1_LOJA "
		cSQL += " UNION "
		cSQL += " SELECT E1_CLIENTE, E1_LOJA "
		cSQL += " FROM SE1070 WITH (NOLOCK) "
		//cSQL += " WHERE E1_EMISSAO >= CONVERT(varchar,DATEADD(d,-365,GETDATE()),112) AND "
		cSQL += " WHERE E1_EMISSAO >= CONVERT(varchar,DATEADD(d,-90,GETDATE()),112) AND "		 
		cSQL += " 	  E1_TIPO IN ('NF','FT') AND "
		cSQL += " 	  D_E_L_E_T_ = '' "
		cSQL += " GROUP BY E1_CLIENTE, E1_LOJA) "	
		cSQL += " SELECT LOWER(RTRIM(LTRIM(A1_YEMABOL))) AS EMAIL "
		cSQL += " FROM " + RetSQLName("SA1") + " INNER JOIN TBLCLIENTE ON A1_COD = CLIENTE AND A1_LOJA = LOJA "
		//cSQL += " WHERE A1_MSBLQL <> '1' AND A1_EMAIL <> '' AND D_E_L_E_T_ = '' "
		cSQL += " WHERE A1_YCDGREG = '000029' AND A1_MSBLQL <> '1' AND A1_YEMABOL <> '' AND D_E_L_E_T_ = '' "
		//cSQL += " GROUP BY A1_EMAIL "
		cSQL += " GROUP BY A1_YEMABOL "
		
	ElseIf cSelOpt == "2"

		cSQL := " SELECT A2_EMAIL AS EMAIL "
		cSQL += " FROM " + RetSQLName("SA2")
		cSQL += " WHERE A2_MSBLQL <> '1' "
		cSQL += " AND A2_EMAIL <> '' " "
		cSQL += " AND D_E_L_E_T_ = '' "
		cSQL += " GROUP BY A2_EMAIL "
	
	ElseIf cSelOpt == "3"

		cSQL := " SELECT A3_EMAIL AS EMAIL "
		cSQL += " FROM " + RetSQLName("SA3")
		cSQL += " WHERE A3_MSBLQL <> '1' "
		cSQL += " AND A3_EMAIL <> '' " "
		cSQL += " AND D_E_L_E_T_ = '' "
		cSQL += " GROUP BY A3_EMAIL "
	
	EndIf

Return(cSQL)


Method GetHtml() Class TWComunicado
Local cHtml := ""

	cHtml	:= ::GetHeader()
	cHtml	+= ::GetBody()

Return(cHtml)


Method GetHeader() Class TWComunicado
Local cRet := ""

	cRet := ' <!DOCTYPE HTML PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	cRet += ' <html xmlns="http://www.w3.org/1999/xhtml"> '
	cRet += ' <head> '
	cRet += '     <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	cRet += '     <title>Workflow</title> '
	cRet += '     <style type="text/css"> '
	cRet += '         body { '
	cRet += '             font-family: tahoma; '
	cRet += '             font-size: 15px; '
	cRet += '         } '
	cRet += '     </style> '
	cRet += ' </head> '

Return(cRet)


Method GetBody() Class TWComunicado
Local cRet := ""
Local aText := {}
Local nCount := 0

	aText := StrTokArr(::oEditor:RetText(), CRLF)

	cRet := ' <body> '

	If Len(aText) > 0
	
		For nCount := 1 To Len(aText)
	
			cRet += ' <p><span>' + aText[nCount] + '</span></p> '
			
		Next
							
	EndIf

	cRet += ' </body> '	
	cRet += ' </html> '

Return(cRet)