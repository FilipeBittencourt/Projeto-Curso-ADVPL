#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWComposicaoSaldoFinanceiroEmpresa
@author Tiago Rossini Coradini
@since 07/06/2018
@version 1.0
@description Classe para vizualização (tela) de composicao de saldo financeiro por empresa
@obs Ticket: 1937
@type class
/*/

// TITULOS DAS JANELAS
#DEFINE TIT_WND "Composição de Saldo Financeiro por Empresa"

#DEFINE TIT_BTN_REL "Imprimir"

#DEFINE nP_EMP 1
#DEFINE nP_NREDUZ 3
#DEFINE nP_COL 3

#DEFINE nP_BRW_LEG 1
#DEFINE nP_BRW_BANCO 2
#DEFINE nP_BRW_AGENCIA 3
#DEFINE nP_BRW_CONTA 4
#DEFINE nP_BRW_NOME 5
#DEFINE nP_BRW_DATA 6
#DEFINE nP_BRW_VALOR 7
#DEFINE nP_BRW_CHECK 8
#DEFINE nP_BRW_SPACE 9

#DEFINE nP_REP_EMP 1
#DEFINE nP_REP_NOME 2
#DEFINE nP_REP_CODIGO 3
#DEFINE nP_REP_AGENCIA 4
#DEFINE nP_REP_CONTA 5
#DEFINE nP_REP_BANCO 6
#DEFINE nP_REP_DATA 7
#DEFINE nP_REP_VALOR 8
#DEFINE nP_REP_CHECK 9

Class TWComposicaoSaldoFinanceiroEmpresa From LongClassName

	Data oWindow  
	Data oContainer	
	Data oPanel
	Data cIdHBox
	Data oFolder
	Data oBO	
	Data dDate
	Data aCompany		
	Data aBrowser
	Data aReportData
	Data cChk
	Data cUnChk
	Data oProfile
					
	Method New() Constructor
	Method LoadInterface()
	Method LoadWindow()
	Method LoadContainer()
	Method LoadFolder()	
	Method LoadBrowser(oWnd, cCompany, cName)
	Method Activate()
	Method GetFieldProperty()
	Method GetFieldData(cCompany)
	Method GetBankName(cBank)
	Method Report()
	Method PrintReport(oReport)
	Method Mark(oBrw)
	Method ExistMark()
	Method GetMark()
	Method LoadProfile()
	Method SaveProfile()	
			
EndClass


Method New(oParam) Class TWComposicaoSaldoFinanceiroEmpresa

	::oWindow := Nil
	::oContainer := Nil	
	::oPanel := Nil
	::cIdHBox := ""	
	::oFolder := Nil
	::oBO := TComposicaoSaldoFinanceiroEmpresa():New()
	::dDate := oParam:dDate
	::aCompany := oParam:aCompany	
	::aBrowser := {}
	::aReportData := {}
	::cChk := "WFCHK"
	::cUnChk := "WFUNCHK"
	
	::oProfile := FWProfile():New()
	
Return()


Method LoadInterface() Class TWComposicaoSaldoFinanceiroEmpresa
	
	::LoadWindow()	
	
	::LoadContainer()
	
	::LoadFolder()	
			
Return()


Method LoadWindow() Class TWComposicaoSaldoFinanceiroEmpresa
Local aCoors := MsAdvSize()
	
	::oWindow := FWDialogModal():New()
	::oWindow:SetBackground(.T.) 
	::oWindow:SetTitle(TIT_WND + " - " + cValToChar(::dDate))
	::oWindow:SetEscClose(.T.)
	::oWindow:SetSize(aCoors[4], aCoors[3] / 1.5)
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()
	
	::oWindow:AddCloseButton()
	
	::oWindow:AddButton(TIT_BTN_REL, {|| ::Report() }, TIT_BTN_REL,, .T., .F., .T.)
		
Return()


Method LoadContainer() Class TWComposicaoSaldoFinanceiroEmpresa

	::oContainer := FWFormContainer():New()
	
	::cIdHBox := ::oContainer:CreateHorizontalBox(100)	
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadFolder() Class TWComposicaoSaldoFinanceiroEmpresa
Local nCount := 0
	
	::oPanel := ::oContainer:GetPanel(::cIdHBox)

	::oFolder := TFolder():New(0, 0, {},, ::oPanel,,,,.T.,,0,0)
	::oFolder:Align := CONTROL_ALIGN_ALLCLIENT
			
	For nCount := 1 To Len(::aCompany)
					
		::oFolder:AddItem(::aCompany[nCount, nP_EMP] + "-" + ::aCompany[nCount, nP_NREDUZ], .T.)		
				
		::LoadBrowser(::oFolder:aDialogs[nCount], ::aCompany[nCount, nP_EMP], ::aCompany[nCount, nP_NREDUZ])		
		
	Next
	
	::oFolder:SetOption(1)
								
Return()


Method LoadBrowser(oWnd, cCompany, cName) Class TWComposicaoSaldoFinanceiroEmpresa
Local cVldDef := "AllwaysTrue"
Local oBrw := Nil 

	oBrw := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", {},,, cVldDef,, cVldDef, oWnd, ::GetFieldProperty(), ::GetFieldData(cCompany))
	oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrw:oBrowse:bLDblClick := {|| ::Mark(oBrw) }
	oBrw:oBrowse:lVScroll := .T.
	oBrw:oBrowse:lHScroll := .T.
	
	oBrw:oBrowse:Refresh()
	
	aAdd(::aBrowser, {cCompany, cName, oBrw:aCols})
	
Return()


Method GetFieldProperty() Class TWComposicaoSaldoFinanceiroEmpresa
Local oField := TGDField():New()
	
	// Adciona coluna para tratamento de legenda
	oField:AddField("LEG")
	oField:FieldName("LEG"):cTitle := ""
	oField:FieldName("LEG"):cPict := "@BMP"

	oField:AddField("E5_BANCO")
	oField:FieldName("E5_BANCO"):cTitle := "Codigo"
	
	oField:AddField("E5_AGENCIA")
	oField:FieldName("E5_AGENCIA"):cTitle := "Agencia"
	
	oField:AddField("E5_CONTA")
	oField:FieldName("E5_CONTA"):cTitle := "Conta"
	
	oField:AddField("A6_NOME")
	oField:FieldName("A6_NOME"):cTitle := "Banco"
	
	oField:AddField("E5_DTDISPO")
	oField:FieldName("E5_DTDISPO"):cTitle := "Data"
	
	oField:AddField("E5_VALOR")
	oField:FieldName("E5_VALOR"):cTitle := "Saldo"

	oField:AddField("MARK")
	oField:FieldName("MARK"):cTitle := "Imprime"
	oField:FieldName("MARK"):cPict := "@BMP"
				
	oField:AddField("SPACE")
	
Return(oField:GetHeader())


Method GetFieldData(cCompany) Class TWComposicaoSaldoFinanceiroEmpresa

	::oBO:cCompany := cCompany
	::oBO:dDate := ::dDate
				
Return(::oBO:GetMovBan(::LoadProfile()))


Method Activate() Class TWComposicaoSaldoFinanceiroEmpresa
	
	::LoadInterface()
			
	::oWindow:Activate()
		
Return()


Method GetBankName(cBank) Class TWComposicaoSaldoFinanceiroEmpresa
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT NOME "
	cSQL += "	FROM BANCOS_FEBRABAN "
	cSQL += "	WHERE CODIGO = "+ ValToSQL(cBank)
	
	TcQuery cSQL New Alias (cQry)

	cRet := AllTrim((cQry)->NOME)
	
	If Empty(cRet)
		
		cRet := AllTrim(Posicione("SA6", 1, xFilial("SA6") + cBank, "A6_NOME"))
				
	EndIf
	
	(cQry)->(DbCloseArea())
		 
Return(cRet)


Method Report() Class TWComposicaoSaldoFinanceiroEmpresa
Local oReport := Nil
Local oSecCompany := Nil
Local oSecBank := Nil

	If ::ExistMark()
				
		::aReportData := ::GetMark()
		
		::SaveProfile()
	
		oReport := TReport():New("COMPSAL", TIT_WND + " - " + cValToChar(::dDate), {|| }, {|oReport| ::PrintReport(oReport)}, TIT_WND)
			
		// Aumenta o tamanho da fonte
		oReport:nFontBody := 8
				
		oSecCompany := TRSection():New(oReport, "Empresa")
		
		TRCell():New(oSecCompany, "E5_FILIAL",, "Empresa")
		TRCell():New(oSecCompany, "A1_NREDUZ",, "Nome")
	
		oSecBank := TRSection():New(oReport, "Banco")
			
		TRCell():New(oSecBank, "E5_BANCO",, "Codigo")
		TRCell():New(oSecBank, "E5_AGENCIA",, "Agencia")
		TRCell():New(oSecBank, "E5_CONTA",, "Conta")
		TRCell():New(oSecBank, "A6_NOME",, "Banco")
		TRCell():New(oSecBank, "E5_DTDISPO",, "Data")
		TRCell():New(oSecBank, "E5_VALOR",, "Saldo")
		
		TRFunction():New(oSecBank:Cell("E5_VALOR"), NIL, "SUM", TRBreak():New(oSecBank, ".T.", ""), NIL, NIL, NIL, .F., .F.)	
		
		oReport:PrintDialog()	
	
	Else
	
		MsgStop("Não existem itens selecionados para impressão!")
	
	EndIf
					
Return()


Method PrintReport(oReport) Class TWComposicaoSaldoFinanceiroEmpresa
Local oSecCompany := oReport:Section(1)
Local oSecBank := oReport:Section(2)
Local cCompany := ""
Local nCount := 0

	For nCount := 1 To Len(::aReportData)

		If cCompany <> ::aReportData[nCount, nP_REP_EMP]
		
			If !Empty(cCompany)
				
				oSecBank:Finish()
				
				oReport:SkipLine()
				
			EndIf
			
			oSecCompany:Init()
					
			oSecCompany:Cell("E5_FILIAL"):SetValue(::aReportData[nCount, nP_REP_EMP])			
			oSecCompany:Cell("A1_NREDUZ"):SetValue(::aReportData[nCount, nP_REP_NOME])
				
			oSecCompany:PrintLine()
						
			oSecCompany:Finish()
			
		EndIf
		
		oSecBank:Init()
				
		oSecBank:Cell("E5_BANCO"):SetValue(::aReportData[nCount, nP_REP_CODIGO])			
		oSecBank:Cell("E5_AGENCIA"):SetValue(::aReportData[nCount, nP_REP_AGENCIA])
		oSecBank:Cell("E5_CONTA"):SetValue(::aReportData[nCount, nP_REP_CONTA])			
		oSecBank:Cell("A6_NOME"):SetValue(::aReportData[nCount, nP_REP_BANCO])
		oSecBank:Cell("E5_DTDISPO"):SetValue(::aReportData[nCount, nP_REP_DATA])			
		oSecBank:Cell("E5_VALOR"):SetValue(::aReportData[nCount, nP_REP_VALOR])
			
		oSecBank:PrintLine()							
		
		cCompany := ::aReportData[nCount, nP_REP_EMP]
	
	Next
	
	oSecBank:Finish()
	
Return()


Method Mark(oBrw) Class TWComposicaoSaldoFinanceiroEmpresa
	
	If !Empty(oBrw:aCols[oBrw:nAt, nP_BRW_BANCO])
	
		If oBrw:aCols[oBrw:nAt, nP_BRW_CHECK] == ::cChk
			
			oBrw:aCols[oBrw:nAt, nP_BRW_CHECK] := ::cUnChk
			
		Else
			
			oBrw:aCols[oBrw:nAt, nP_BRW_CHECK] := ::cChk
			
		EndIf
		
	EndIf
	
Return()


Method ExistMark() Class TWComposicaoSaldoFinanceiroEmpresa
Local lRet := .F.
Local nCount := 1
	
	While nCount <= Len(::aBrowser) .And. !lRet
				
		lRet := aScan(::aBrowser[nCount, 3], {|x| x[nP_BRW_CHECK] == ::cChk }) > 0
		
		nCount++
		
	EndDo

Return(lRet)


Method GetMark() Class TWComposicaoSaldoFinanceiroEmpresa
Local aRet := {}
Local nX := 1
Local nY := 1

	For nX := 1 To Len(::aBrowser)
	
		For nY := 1 To Len(::aBrowser[nX, nP_COL])
		
			If ::aBrowser[nX, nP_COL, nY, nP_BRW_CHECK] == ::cChk
		
				aAdd(aRet, {::aBrowser[nX, nP_REP_EMP], ::aBrowser[nX, nP_REP_NOME], ::aBrowser[nX, nP_COL, nY, nP_BRW_BANCO], ::aBrowser[nX, nP_COL, nY, nP_BRW_AGENCIA],;
										::aBrowser[nX, nP_COL, nY, nP_BRW_CONTA], ::aBrowser[nX, nP_COL, nY, nP_BRW_NOME], ::aBrowser[nX, nP_COL, nY, nP_BRW_DATA], ::aBrowser[nX, nP_COL, nY, nP_BRW_VALOR]})

			EndIf
			
		Next
				
	Next

Return(aRet)


Method LoadProfile() Class TWComposicaoSaldoFinanceiroEmpresa

	::oProfile:SetTask(GetClassName(Self))
	::oProfile:SetType("PRINT_MARKBROWSE")
	::oProfile:Load()
			
Return(::oProfile:GetProfile())


Method SaveProfile() Class TWComposicaoSaldoFinanceiroEmpresa
Local nCount := 0
Local aProfile := {}

	For nCount := 1 To Len(::aReportData)
	
		aAdd(aProfile, {::aReportData[nCount, nP_REP_EMP], ::aReportData[nCount, nP_REP_CODIGO], ::aReportData[nCount, nP_REP_AGENCIA], ::aReportData[nCount, nP_REP_CONTA]})

	Next

	::oProfile:SetProfile(aProfile)
	
	::oProfile:Save()

Return()