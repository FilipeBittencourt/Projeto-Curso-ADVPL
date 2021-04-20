#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWVistoriaObraEngenharia
@author Tiago Rossini Coradini
@since 19/09/2019
@version 1.0
@description Classe para Manutenção nas Vistorias em Obras de Engenharia
@obs Ticket: 19122
@type class
/*/

// TITULOS DAS JANELAS
#DEFINE TIT_WND "Vistorias em Obras de Engenharia"

// Titulo dos botoes
#DEFINE TIT_BTN_CON "Confirmar"
#DEFINE TIT_BTN_ALT "Alterar"
#DEFINE TIT_BTN_APR "Aprovar"
#DEFINE TIT_BTN_TER "Termo"
#DEFINE TIT_BTN_PAR "Parametros"
#DEFINE TIT_BTN_REP "Relatorio"
#DEFINE TIT_BTN_LEG "Legenda"

#DEFINE nP_MARK 1
#DEFINE nP_LEG 2
#DEFINE nP_DATPRE 3
#DEFINE nP_DATVIS 4
#DEFINE nP_CLIENTE 5
#DEFINE nP_NUMOBR 8
#DEFINE nP_DOC 13
#DEFINE nP_ARQCP3 20
#DEFINE nP_ARQCP2 21
#DEFINE nP_ARQCP3 22
#DEFINE nP_NUMERO 23
#DEFINE nP_RECNO 24


Class TWVistoriaObraEngenharia From LongClassName 

	Data oWindow  
	Data oContainer	
	Data oPanel
	Data cIdHBox	
	Data cVisPen
	Data cVisFin
	Data cVisBlo
	Data cChk
	Data cUnChk
	Data oChk
	Data lMarkAll
	Data oBrw	
	Data oField
	Data lConfirm
	Data oParam
	Data oVoucher // Comprovante
	Data oHistoric // Historicos
	
	Method New() Constructor
	Method LoadInterface()
	Method LoadWindow()
	Method LoadContainer()
	Method LoadBrowser()
	Method Activate()	 
	Method GetEditableField()
	Method GetFieldProperty(lReport)
	Method GetFieldData(lReport)
	Method GetLegend(cStatus)
	Method BrowserClick()
	Method ViewVoucher(nColPos)
	Method ViewTerm()
	Method CopyTerm()	
	Method Mark()
	Method MarkAll()
	Method GetMark()
	Method VldConfirm()
	Method VldUpdate()
	Method VldMark(cPar)	
	Method VldVoucher()
	Method VldHistoric()
	Method VldApprove()
	Method Confirm()
	Method Update()
	Method Approve()
	Method ParamBox(lReport)
	Method Legend()
	Method Refresh()
	Method Report()

EndClass


Method New(oParam) Class TWVistoriaObraEngenharia

	Default oParam := Nil

	::oWindow := Nil	
	::oContainer := Nil	
	::oPanel := Nil
	::cIdHBox := ""
	::cVisPen := "BR_VERDE"
	::cVisFin := "BR_VERMELHO"
	::cVisBlo := "BR_AMARELO"
	::cChk := "WFCHK"
	::cUnChk := "WFUNCHK"
	::oChk := Nil
	::lMarkAll := .F.
	::oBrw := Nil	
	::oField := TGDField():New()
	::lConfirm := .F.

	::oParam := oParam
	::oVoucher := TComprovanteVistoriaObraEngenharia():New()
	::oHistoric := THistoricoVistoriaObraEngenharia():New()
	
Return()


Method LoadInterface() Class TWVistoriaObraEngenharia

	::LoadWindow()

	::LoadContainer()

	::LoadBrowser()

Return()


Method LoadWindow() Class TWVistoriaObraEngenharia
Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()
	::oWindow:SetBackground(.T.) 
	::oWindow:SetTitle(TIT_WND)
	::oWindow:SetEscClose(.F.)
	::oWindow:SetSize(aCoors[4], aCoors[3])
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()
	
	::oWindow:AddCloseButton()

	::oWindow:AddButton(TIT_BTN_CON, {|| ::Confirm() }, TIT_BTN_CON,, .T., .F., .T.)
	::oWindow:AddButton(TIT_BTN_ALT, {|| ::Update() }, TIT_BTN_ALT,, .T., .F., .T.)
	::oWindow:AddButton(TIT_BTN_APR, {|| ::Approve() }, TIT_BTN_APR,, .T., .F., .T.)
	::oWindow:AddButton(TIT_BTN_TER, {|| ::ViewTerm() }, TIT_BTN_TER,, .T., .F., .T.)
	::oWindow:AddButton(TIT_BTN_PAR, {|| ::ParamBox() }, TIT_BTN_PAR,, .T., .F., .T.)
	::oWindow:AddButton(TIT_BTN_REP, {|| ::ParamBox(.T.) }, TIT_BTN_REP,, .T., .F., .T.)
	::oWindow:AddButton(TIT_BTN_LEG, {|| ::Legend() }, TIT_BTN_LEG,, .T., .F., .T.)	
	
Return()


Method LoadContainer() Class TWVistoriaObraEngenharia

	::oContainer := FWFormContainer():New()
	
	::cIdHBox := ::oContainer:CreateHorizontalBox(100)	
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadBrowser() Class TWVistoriaObraEngenharia
Local cVldDef := "AllwaysTrue"
	
	::oPanel := ::oContainer:GetPanel(::cIdHBox)	
	
	::oChk := TCheckBox():Create(::oPanel)
	::oChk:cName := 'oChk'
	::oChk:cCaption := "Marca / Desmarca todos"
	::oChk:nLeft := 0
	::oChk:nTop := 0	
	::oChk:nWidth := 300
	::oChk:nHeight := 20
	::oChk:lShowHint := .T.
	::oChk:cVariable := "::lMarkAll"
	::oChk:bSetGet := bSetGet(::lMarkAll)
	::oChk:Align := CONTROL_ALIGN_TOP	 
	::oChk:lVisibleControl := .T.
	::oChk:bChange := {|| ::MarkAll() }

	::oBrw := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", ::GetEditableField(),,, cVldDef,, cVldDef, ::oPanel, ::GetFieldProperty(), ::GetFieldData())
	::oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrw:oBrowse:bLDblClick := {|| ::BrowserClick() }
	::oBrw:oBrowse:lVScroll := .T.
	::oBrw:oBrowse:lHScroll := .T.

Return()


Method Activate() Class TWVistoriaObraEngenharia	

	::LoadInterface()
		
	::oWindow:Activate()

Return()


Method GetEditableField() Class TWVistoriaObraEngenharia
Local aRet := {}

Return(aRet)


Method GetFieldProperty(lReport) Class TWVistoriaObraEngenharia

	Default lReport := .F.

	::oField:Clear()

	If !lReport

		::oField:AddField("MARK")
		::oField:FieldName("MARK"):cTitle := ""
		::oField:FieldName("MARK"):cPict := "@BMP"
		
		::oField:AddField("LEG")
		::oField:FieldName("LEG"):cTitle := ""
		::oField:FieldName("LEG"):cPict := "@BMP"
	
	EndIf

	::oField:AddField("ZKS_DATPRE")		
	::oField:AddField("ZKS_DATVIS")
	::oField:AddField("ZKS_CLIENT")
	::oField:AddField("ZKS_LOJA")
	::oField:AddField("A1_NOME")
	
	::oField:AddField("ZKS_NUMOBR")
	::oField:FieldName("ZKS_NUMOBR"):cTitle := "Obra"
	
	::oField:AddField("A1_NREDUZ")
	::oField:FieldName("A1_NREDUZ"):cTitle := "Nome"
	::oField:FieldName("A1_NREDUZ"):nSize := 60
	
	::oField:AddField("ZKS_VEND")
	::oField:AddField("A3_NOME")
	::oField:AddField("ZKS_DATA")
	::oField:AddField("ZKS_DOC")
	::oField:AddField("ZKS_SERIE")
	::oField:AddField("ZKS_ITEM")
	::oField:AddField("ZKS_PRODUT")
	
	::oField:AddField("B1_DESC")
	::oField:FieldName("B1_DESC"):nSize := 60
	
	::oField:AddField("ZKS_LOTE")
	::oField:AddField("ZKS_QUANT")
	::oField:AddField("ZKS_ASSINA")
	
	If !lReport
	
		::oField:AddField("ZKS_ARQCP1")
		::oField:FieldName("ZKS_ARQCP1"):cTitle := "Comprovante 01"
		::oField:FieldName("ZKS_ARQCP1"):lObrigat := .F.
		::oField:FieldName("ZKS_ARQCP1"):nSize := 50
		
		::oField:AddField("ZKS_ARQCP2")
		::oField:FieldName("ZKS_ARQCP2"):cTitle := "Comprovante 02"	
		::oField:FieldName("ZKS_ARQCP2"):lObrigat := .F.
		::oField:FieldName("ZKS_ARQCP2"):nSize := 50
			
		::oField:AddField("ZKS_ARQCP3")
		::oField:FieldName("ZKS_ARQCP3"):cTitle := "Comprovante 03"	
		::oField:FieldName("ZKS_ARQCP3"):lObrigat := .F.
		::oField:FieldName("ZKS_ARQCP3"):nSize := 50
		
	EndIf

Return(::oField:GetHeader())


Method GetFieldData(lReport) Class TWVistoriaObraEngenharia
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()

	Default lReport := .F.

	cSQL := " SELECT ZKS_STATUS, ZKS_DATPRE, ZKS_DATVIS, ZKS_CLIENT, ZKS_LOJA, A1_NOME, ZKS_NUMOBR, 
	cSQL += " ISNULL(
	cSQL += " (
	cSQL += " 	SELECT ZZO_OBRA
	cSQL += " 	FROM "+ RetFullName("ZZO", "01")
	cSQL += " 	WHERE ZZO_FILIAL = " + ValToSQL(cFilAnt)
	cSQL += " 	AND ZZO_NUM = ZKS_NUMOBR
	cSQL += " 	AND D_E_L_E_T_ = ''	
	cSQL += " ), '') AS ZZO_OBRA,
	cSQL += " ZKS_VEND, A3_NOME, ZKS_DATA, ZKS_DOC, ZKS_SERIE, ZKS_ITEM, ZKS_PRODUT, LTRIM(B1_DESC) AS B1_DESC, ZKS_LOTE, ZKS_QUANT, ZKS_ASSINA, ZKS_ARQCP1, ZKS_ARQCP2, ZKS_ARQCP3, ZKS_NUMERO, ZKS.R_E_C_N_O_ AS RECNO
	cSQL += " FROM "+ RetSQLName("ZKS") + " AS ZKS
	cSQL += " INNER JOIN "+ RetSQLName("SA1") + " AS SA1
	cSQL += " ON ZKS_CLIENT = A1_COD
	cSQL += " AND ZKS_LOJA = A1_LOJA
	cSQL += " INNER JOIN "+ RetSQLName("SA3") + "  AS SA3
	cSQL += " ON ZKS_VEND = A3_COD
	cSQL += " INNER JOIN "+ RetSQLName("SB1") + "  AS SB1
	cSQL += " ON ZKS_PRODUT = B1_COD
	cSQL += " WHERE ZKS_FILIAL = " + ValToSQL(xFilial("ZKS"))

	If Upper(SubStr(::oParam:cStatus, 1, 1)) == "P"
		
		cSQL += " AND ZKS_STATUS = '1' "
	
	ElseIf Upper(SubStr(::oParam:cStatus, 1, 1)) == "F"
		
		cSQL += " AND ZKS_STATUS = '2' "
		
	ElseIf Upper(SubStr(::oParam:cStatus, 1, 1)) == "E"

		cSQL += " AND ZKS_STATUS = '3' "
		
	EndIf
	
	cSQL += " AND ZKS_DATPRE BETWEEN " + ValToSQL(::oParam:dVisDe) + " AND " + ValToSQL(::oParam:dVisAte)
	cSQL += " AND ZKS_CLIENT BETWEEN " + ValToSQL(::oParam:cCodCliDe) + " AND " + ValToSQL(::oParam:cCodCliAte)
	cSQL += " AND ZKS_NUMOBR BETWEEN " + ValToSQL(::oParam:cNumObrDe) + " AND " + ValToSQL(::oParam:cNumObrAte)
	cSQL += " AND ZKS_VEND BETWEEN " + ValToSQL(::oParam:cCodVenDe) + " AND " + ValToSQL(::oParam:cCodVenAte)
	cSQL += " AND ZKS_PRODUT BETWEEN " + ValToSQL(::oParam:cCodProDe) + " AND " + ValToSQL(::oParam:cCodProAte)
	
	If SubStr(::oParam:cSigned, 1, 1) $ "S/N"
		
		cSQL += " AND ZKS_ASSINA = " + ValToSQL(SubStr(::oParam:cSigned, 1, 1))
		
	EndIf
	
	cSQL += " AND ZKS.D_E_L_E_T_ = '' 
	cSQL += " AND A1_FILIAL = " + ValToSQL(xFilial("SA1"))
	cSQL += " AND SA1.D_E_L_E_T_ = '' 
	cSQL += " AND A3_FILIAL = " + ValToSQL(xFilial("SA3"))
	cSQL += " AND SA3.D_E_L_E_T_ = '' 
	cSQL += " AND B1_FILIAL = " + ValToSQL(xFilial("SB1"))
	cSQL += " AND SB1.D_E_L_E_T_ = ''
	cSQL += " ORDER BY ZKS_DATPRE, ZKS_CLIENT, ZKS_LOJA, ZKS_NUMOBR, ZKS_DOC, ZKS_SERIE, ZKS_PRODUT, ZKS_ITEM, ZKS_LOTE, ZKS_QUANT
		
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		If lReport

			aAdd(aRet, {dToC(sToD((cQry)->ZKS_DATPRE)), dToC(sToD((cQry)->ZKS_DATVIS)), Chr(160) + (cQry)->ZKS_CLIENT, Chr(160) + (cQry)->ZKS_LOJA, (cQry)->A1_NOME, Chr(160) + (cQry)->ZKS_NUMOBR,;
									(cQry)->ZZO_OBRA, Chr(160) + (cQry)->ZKS_VEND, (cQry)->A3_NOME, Chr(160) + dToC(sToD((cQry)->ZKS_DATA)), Chr(160) + (cQry)->ZKS_DOC, Chr(160) + (cQry)->ZKS_SERIE, Chr(160) + (cQry)->ZKS_ITEM, Chr(160) + (cQry)->ZKS_PRODUT,;
									(cQry)->B1_DESC, Chr(160) + (cQry)->ZKS_LOTE, (cQry)->ZKS_QUANT, Chr(160) + (cQry)->ZKS_ASSINA, .F.})
		
		Else
		
			aAdd(aRet, {::cUnChk, ::GetLegend((cQry)->ZKS_STATUS), dToC(sToD((cQry)->ZKS_DATPRE)), dToC(sToD((cQry)->ZKS_DATVIS)), (cQry)->ZKS_CLIENT, (cQry)->ZKS_LOJA, (cQry)->A1_NOME, (cQry)->ZKS_NUMOBR,;
									(cQry)->ZZO_OBRA, (cQry)->ZKS_VEND, (cQry)->A3_NOME, dToC(sToD((cQry)->ZKS_DATA)), (cQry)->ZKS_DOC, (cQry)->ZKS_SERIE, (cQry)->ZKS_ITEM, (cQry)->ZKS_PRODUT, (cQry)->B1_DESC, (cQry)->ZKS_LOTE,; 
									(cQry)->ZKS_QUANT, (cQry)->ZKS_ASSINA, (cQry)->ZKS_ARQCP1, (cQry)->ZKS_ARQCP2, (cQry)->ZKS_ARQCP3, (cQry)->ZKS_NUMERO, (cQry)->RECNO, .F.})
									
		EndIf

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(aRet)


Method GetLegend(cStatus) Class TWVistoriaObraEngenharia
Local cRet := ""

	If cStatus == "1"
		
		cRet := ::cVisPen
		
	ElseIf cStatus == "2"
		
		cRet := ::cVisFin

	ElseIf cStatus == "3"
		
		cRet := ::cVisBlo
	
	EndIf
	
Return(cRet)


Method BrowserClick() Class TWVistoriaObraEngenharia

	If ::oBrw:oBrowse:nColPos == 19 .Or. ::oBrw:oBrowse:nColPos == 20 .Or. ::oBrw:oBrowse:nColPos == 21
		
		U_BIAMsgRun("Abrindo Comprovante...", "Aguarde!", {|| ::ViewVoucher(::oBrw:oBrowse:nColPos) })
		
	Else
	
		::Mark()
		
	EndIf

Return()


Method ViewVoucher(nColPos) Class TWVistoriaObraEngenharia
Local cSourceFile := ""
Local cFile := ""
Local cParam := ""
Local cDrive := ""
Local cDir := ""
Local cTargetPath := "\p10\vistoria_obra\comprovante\"

	cSourceFile := AllTrim(::oBrw:aCols[::oBrw:oBrowse:nAt, nColPos])
	
	cFile := GetTempPath() + cSourceFile
		
	If !Empty(cFile)
	
		SplitPath(cFile, @cDrive, @cDir)
		
		cDir := Alltrim(cDrive) + Alltrim(cDir)
					
		If CpyS2T(cTargetPath + cSourceFile, cDir)
		
			ShellExecute("open", cFile, cParam, cDir, 1)
										
		EndIf
		
	EndIf

Return()


Method ViewTerm() Class TWVistoriaObraEngenharia

	U_BIAMsgRun("Abrindo Termo...", "Aguarde!", {|| ::CopyTerm() })

Return()


Method CopyTerm() Class TWVistoriaObraEngenharia
Local cSourceFile := ""
Local cDtVis := ""
Local cCliente := "" 
Local cNumObr := ""
Local cFile := ""
Local cParam := ""
Local cDrive := ""
Local cDir := ""
Local cTargetPath := "\p10\vistoria_obra\termo\"

	If Len(::oBrw:aCols) > 0
	
		cDtVis := ::oHistoric:GetFirstDate(::oBrw:aCols[::oBrw:oBrowse:nAt, nP_NUMERO])
		
		If Empty(cDtVis)
			
			cDtVis := dToS(cToD(::oBrw:aCols[::oBrw:oBrowse:nAt, nP_DATPRE]))
			
		EndIf
		
		cCliente := AllTrim(::oBrw:aCols[::oBrw:oBrowse:nAt, nP_CLIENTE])
		cNumObr := AllTrim(::oBrw:aCols[::oBrw:oBrowse:nAt, nP_NUMOBR])
	
		cSourceFile := Lower("termo_" + cEmpAnt + "_" + cDtVis + "_" + cCliente + If (!Empty(cNumObr), "_" + cNumObr, "") + ".pdf")
		
		cFile := GetTempPath() + cSourceFile
			
		If !Empty(cFile)
		
			SplitPath(cFile, @cDrive, @cDir)
			
			cDir := Alltrim(cDrive) + Alltrim(cDir)
			
			//ticket 27170 - muitos casos de Termos não gerados precisando ser gerados manualmente.
			//SOLUÇÃO: gerar o termo caso nao exista na pasta.
			if !FILE(cTargetPath + cSourceFile)	
				if MSGYESNO("O termo solicitado não foi encontrado na pasta destino. Deseja gerar novamente?", "Atenção")
					oObjTerm := TTermoVistoriaObraEngenharia():New()
				
					if(!Empty(AllTrim(::oBrw:aCols[::oBrw:oBrowse:nAt, nP_NUMOBR])))
						oObjTerm:nobra := AllTrim(::oBrw:aCols[::oBrw:oBrowse:nAt, nP_NUMOBR])
					else 
						oObjTerm:docto := AllTrim(::oBrw:aCols[::oBrw:oBrowse:nAt, nP_DOC])
					endif
					
					oObjTerm:Process()
					
					FreeObj(oObjTerm)
				endif
			endif
						
			If CpyS2T(cTargetPath + cSourceFile, cDir)
			
				ShellExecute("open", cFile, cParam, cDir, 1)
											
			EndIf
			
		EndIf

	EndIf
	
Return()


Method Mark() Class TWVistoriaObraEngenharia

	If ::oBrw:aCols[::oBrw:nAt, nP_LEG] <> ::cVisFin
	
		If ::oBrw:aCols[::oBrw:nAt, nP_MARK] == ::cChk
			
			::oBrw:aCols[::oBrw:nAt, nP_MARK] := ::cUnChk
			
		Else
			
			::oBrw:aCols[::oBrw:nAt, nP_MARK] := ::cChk
			
		EndIf
		
	EndIf			

Return()


Method MarkAll() Class TWVistoriaObraEngenharia
Local nCount := 0

	If Len(::oBrw:aCols) > 0
		
		For nCount := 1 To Len(::oBrw:aCols)
	
			If ::oBrw:aCols[nCount, nP_LEG] <> ::cVisFin
	
				If ::lMarkAll
					
					::oBrw:aCols[nCount, nP_MARK] := ::cChk
					
				Else
					
					::oBrw:aCols[nCount, nP_MARK] := ::cUnChk
					
				EndIf
				
			EndIf
		
		Next
			
		::oBrw:Refresh()
		
	EndIf

Return()


Method GetMark() Class TWVistoriaObraEngenharia
Local aRet := {}

	aEval(::oBrw:aCols, {|aPar| If (aPar[nP_MARK] == ::cChk, aAdd(aRet, {aPar[nP_DATVIS], aPar[nP_RECNO]}), Nil) })

Return(aRet)


Method VldConfirm() Class TWVistoriaObraEngenharia
Local lRet := .T.

	lRet := ::VldMark(::cVisPen) .And. ::VldVoucher()

Return(lRet)


Method VldUpdate() Class TWVistoriaObraEngenharia
Local lRet := .T.

	lRet := ::VldMark(::cVisPen) .And. ::VldHistoric()

Return(lRet)


Method VldMark(cPar) Class TWVistoriaObraEngenharia
Local lRet := .F.
Local nPos := 0
Local cGroup := ""
Local lDif := .F.
Local bValid := {|x| If ( x[nP_MARK] == ::cChk .And. x[nP_LEG] + x[nP_DATVIS] + x[nP_CLIENTE] + x[nP_NUMOBR] <> cGroup, lDif := .T., ) }

	If (nPos := aScan(::oBrw:aCols, {|x| x[nP_MARK] == ::cChk .And. x[nP_LEG] == cPar })) > 0
		
		cGroup := ::oBrw:aCols[nPos, nP_LEG] + ::oBrw:aCols[nPos, nP_DATVIS] + ::oBrw:aCols[nPos, nP_CLIENTE] + ::oBrw:aCols[nPos, nP_NUMOBR]
		
		aEval(::oBrw:aCols, bValid)
		
		If !lDif
			
			lRet := .T.
		
		Else
		
			MsgStop("Não é permitido dar manutenção em vistorias distintas." + Chr(13) + Chr(10) +;
							"Verifique os campos de Data, Cliente e Obra dos itens selecionados.", TIT_WND)
		
		EndIf
	
	ElseIf  ::cVisBlo <> cPar .And. (nPos := aScan(::oBrw:aCols, {|x| x[nP_MARK] == ::cChk .And. x[nP_LEG] == ::cVisBlo })) > 0

		MsgStop("VISTORIA BLOQUEADA - Aguardando Aprovação", TIT_WND)

	Else
	
		MsgStop("Não existem itens selecionados para a operação executada!", TIT_WND)
	
	EndIf
	
Return(lRet)


Method VldVoucher() Class TWVistoriaObraEngenharia
Local lRet := .F.
		
	::oVoucher:dSurveyForecast := cToD(::oBrw:aCols[aScan(::oBrw:aCols, {|x| x[nP_MARK] == ::cChk}), nP_DATPRE])
	::oVoucher:dSurveyRealization := dDataBase	
	
	If ::oVoucher:SelectFile()
														
		If MsgYesNo("Confirma que os itens selecionados foram vistoriados em: " + dToC(::oVoucher:dSurveyRealization) + "?", TIT_WND)
			
			U_BIAMsgRun("Copiando arquivo para o servidor...", "Aguarde!", {|| lRet := ::oVoucher:CopyFile() })
			
			If !lRet
						
				MsgStop("Erro ao copiar o arquivo do comprovante para o servidor.", TIT_WND)				
				
			EndIf
			
		EndIf				
		
	EndIf

Return(lRet)


Method VldHistoric() Class TWVistoriaObraEngenharia
Local lRet := .F.
		
	::oHistoric:dSurveyForecast := cToD(::oBrw:aCols[aScan(::oBrw:aCols, {|x| x[nP_MARK] == ::cChk}), nP_DATPRE])
	::oHistoric:dSurveySuggestion := dDataBase	 
	
	If ::oHistoric:Validate()
														
		lRet := MsgYesNo("Confirma que os itens selecionados terão a data vistoria alterada para: " + dToC(::oHistoric:dSurveySuggestion) + "?", TIT_WND)
					
	EndIf

Return(lRet)


Method VldApprove() Class TWVistoriaObraEngenharia
Local lRet := .F.
Local cApprover	:= GetMv("MV_YAPRVIS", .F.)

	If "FACILE" $ Alltrim(cUserName) .Or. Alltrim(__cUserId) $ cApprover 

		If ::VldMark(::cVisBlo)
		
			lRet := MsgYesNo("Confirma a alteração das vistoria(s) selecionada(s) para data de: " +;
			 				dToC(cToD(::oBrw:aCols[aScan(::oBrw:aCols, {|x| x[nP_MARK] == ::cChk}), nP_DATPRE])), TIT_WND)
		
		EndIf
		
	Else
	
		MsgStop("Usuário sem acesso a rotina de aprovação, favor consultar o gerente de engenharia.", TIT_WND)
		
	EndIf		

Return(lRet)


Method Confirm() Class TWVistoriaObraEngenharia

	If ::VldConfirm()

		U_BIAMsgRun("Confirmando Vistoria(s)...", "Aguarde!", {|| ::oVoucher:Save(::GetMark()), ::Refresh() })

	EndIf 

Return()


Method Update() Class TWVistoriaObraEngenharia

	If ::VldUpdate()

		U_BIAMsgRun("Atualizando Vistoria(s)...", "Aguarde!", {|| ::oHistoric:Insert(::GetMark()), ::Refresh() })

	EndIf 
	
Return()


Method Approve() Class TWVistoriaObraEngenharia

	If ::VldApprove()
		
		::oHistoric:lApprove := .T.

		::oHistoric:dSurveySuggestion := cToD(::oBrw:aCols[aScan(::oBrw:aCols, {|x| x[nP_MARK] == ::cChk}), nP_DATPRE])	 
				
		U_BIAMsgRun("Aprovando Vistoria(s)...", "Aguarde!", {|| ::oHistoric:Insert(::GetMark()), ::Refresh() })

		::oHistoric:lApprove := .F.
		
	EndIf

Return()


Method ParamBox(lReport) Class TWVistoriaObraEngenharia

	Default lReport := .F. 

	If ::oParam:Box()

		If lReport
		
			U_BIAMsgRun("Gerando Relatório...", "Aguarde!", {|| ::Report() })
			
		Else
		
			U_BIAMsgRun("Atualizando dados...", "Aguarde!", {|| ::Refresh() })
		
		EndIf

	EndIf

Return()


Method Legend() Class TWVistoriaObraEngenharia
Local aLegend := {}
	
	aAdd(aLegend, {"BR_VERDE", "Vistoria Pendente"})
	aAdd(aLegend, {"BR_VERMELHO", "Vistoria Finalizada"})
	aAdd(aLegend, {"BR_AMARELO", "Vistoria Bloqueada - Aguardando Aprovação"})
	
	BrwLegenda(TIT_WND, "Legenda", aLegend)

Return()


Method Refresh() Class TWVistoriaObraEngenharia

	::oBrw:SetArray(::GetFieldData())
	
	::oBrw:Refresh()

Return()


Method Report() Class TWVistoriaObraEngenharia

	DlgToExcel({{"GETDADOS", "Vistorias em Obras", ::GetFieldProperty(.T.), ::GetFieldData(.T.)}})

Return()
