#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWComposicaoSaldoFinanceiro
@author Tiago Rossini Coradini
@since 22/05/2018
@version 1.0
@description Classe para vizualização (tela) de composicao de saldo financeiro
@obs Ticket: 4615
@type class
/*/

#DEFINE TIT_WND "Composição de Saldo Financeiro"

#DEFINE TIT_BTN_INC "Incluir"
#DEFINE TIT_BTN_EXC "Excluir"
#DEFINE TIT_BTN_GER "Gerar Saldo"
#DEFINE TIT_BTN_ATU "Atualizar"

#DEFINE nP_BANCO 1
#DEFINE nP_AGENCIA 2
#DEFINE nP_CONTA 3

#DEFINE nP_BRW_LEG 1
#DEFINE nP_BRW_DATA 2
#DEFINE nP_BRW_HIST 3
#DEFINE nP_BRW_VALOR 4
#DEFINE nP_BRW_SALDO 5
#DEFINE nP_BRW_CHECK 6
#DEFINE nP_BRW_SPACE 7
#DEFINE nP_BRW_DATA_REF 8

#DEFINE nP_FOL 1
#DEFINE nP_FOL_OPTION 2
#DEFINE nP_FOL_BANCO 3
#DEFINE nP_FOL_AGENCIA 4
#DEFINE nP_FOL_CONTA 5
#DEFINE nP_FOL_BROWSE 6

Class TWComposicaoSaldoFinanceiro From LongClassName

	Data oWindow
	Data oContainer	
	Data oPanel
	Data cIdHBox
	Data oFolder	
	Data oBO		
	Data dStartDate 
	Data dEndDate
	Data aBank
	Data oSelBrowser
	Data nFolBank
	Data aFolItem
	Data aFolSelect
	Data cChk
	Data cUnChk	
				
	Method New() Constructor
	Method LoadInterface()
	Method LoadWindow()
	Method LoadContainer()
	Method LoadLayer()	
	Method LoadFolder()
	Method AddItem(oFolder, aFolder, nPos, aBank)
	Method LoadBrowser(oWnd, cBank, cAgency, cAccount)
	Method Activate()
	Method GetFieldProperty()
	Method GetFieldData(cBank, cAgency, cAccount)
	Method GetCompany()
	Method GetBankName(cBank)
	Method GetSelectedFolder()
	Method SetSelectedData()
	Method OnFolBankChange(nOption)
	Method OnFolAccountChange(nOption)
	Method Mark(oBrw)
	Method Insert()
	Method Delete()
	Method Generate()
	Method Refresh(lSet)
			
EndClass


Method New(oParam) Class TWComposicaoSaldoFinanceiro
		
	::oWindow := Nil
	::oContainer := Nil	
	::oPanel := Nil
	::cIdHBox := ""	
	::oFolder := Nil
	::oBO := TComposicaoSaldoFinanceiro():New()
	::dStartDate := oParam:dStartDate
	::dEndDate := oParam:dEndDate
	::aBank := oParam:aBank	
	::oSelBrowser := Nil
	::nFolBank := 1		
	::aFolItem := {}
	::aFolSelect := {}	
	::cChk := "WFCHK"
	::cUnChk := "WFUNCHK"
	
Return()


Method LoadInterface() Class TWComposicaoSaldoFinanceiro
	
	::LoadWindow()
	
	::LoadContainer()	
	
	::LoadFolder()	
			
Return()


Method LoadWindow() Class TWComposicaoSaldoFinanceiro
Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()
	::oWindow:SetBackground(.T.) 
	::oWindow:SetTitle(::GetCompany() + " - " + TIT_WND + " - Período de " + cValToChar(::dStartDate) + " ate " + cValToChar(::dEndDate))
	::oWindow:SetEscClose(.T.)
	::oWindow:SetSize(aCoors[4], aCoors[3] / 1.5)
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()
	
	::oWindow:AddCloseButton()
	
	::oWindow:AddButton(TIT_BTN_INC, {|| ::Insert() }, TIT_BTN_INC,, .T., .F., .T.)
	::oWindow:AddButton(TIT_BTN_EXC, {|| ::Delete() }, TIT_BTN_EXC,, .T., .F., .T.)
	::oWindow:AddButton(TIT_BTN_GER, {|| ::Generate() }, TIT_BTN_GER,, .T., .F., .T.)
	::oWindow:AddButton(TIT_BTN_ATU, {|| ::Refresh(.T.) }, TIT_BTN_ATU,, .T., .F., .T.)
						
Return()


Method LoadContainer() Class TWComposicaoSaldoFinanceiro

	::oContainer := FWFormContainer():New()
	
	::cIdHBox := ::oContainer:CreateHorizontalBox(100)	
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadFolder() Class TWComposicaoSaldoFinanceiro
Local nCount := 0
Local nIdx := 0
Local aAuxFol := {}

	::oPanel := ::oContainer:GetPanel(::cIdHBox)

	::oFolder := TFolder():New(0, 0, {},, ::oPanel,,,,.T.,,0,0)
	::oFolder:bSetOption := {|nOption| ::OnFolBankChange(nOption)}
	::oFolder:Align := CONTROL_ALIGN_ALLCLIENT
					
	For nCount := 1 To Len(::aBank)
					
		If aScan(aAuxFol, {|x| x[nP_BANCO] == ::aBank[nCount, nP_BANCO] }) == 0					
			
			::oFolder:AddItem(::GetBankName(::aBank[nCount, nP_BANCO]), .T.)			
			 
			aAdd(aAuxFol, {::aBank[nCount, nP_BANCO], Len(::oFolder:aDialogs) })
			
			nIdx := 0						
			
		EndIf
		
		nIdx++
		
		aAdd(::aFolItem, {Len(aAuxFol), nIdx, ::aBank[nCount, nP_BANCO], ::aBank[nCount, nP_AGENCIA], ::aBank[nCount, nP_CONTA], Nil})
		
		aAdd(::aFolSelect, 1)				
		
	Next
	
	::oFolder:SetOption(1)
	
	For nCount := 1 To Len(aAuxFol)
	
		oFolder := TFolder():New(0, 0, {},,::oFolder:aDialogs[aAuxFol[nCount, 2]],,,,.T.,,0,0)
		oFolder:bSetOption := {|nOption| ::OnFolAccountChange(nOption)}
		oFolder:Align := CONTROL_ALIGN_ALLCLIENT
		
		aEval(::aBank, {|aBank| ::AddItem(oFolder, aAuxFol, nCount, aBank) })
		
		oFolder:SetOption(1)
		
	Next
			
	::SetSelectedData()			
				
Return()


Method AddItem(oFolder, aFolder, nPos, aBank) Class TWComposicaoSaldoFinanceiro
Local bPos := {|| aScan(::aFolItem, {|x| x[nP_FOL] == nPos .And. x[nP_FOL_OPTION] == Len(oFolder:aDialogs)})} 

	If aFolder[nPos, 1] == aBank[nP_BANCO]
		
		oFolder:AddItem("AG: " + aBank[nP_AGENCIA] + " / CC: " + aBank[nP_CONTA], .T.)
				
		::aFolItem[Eval(bPos)][nP_FOL_BROWSE] := ::LoadBrowser(oFolder:aDialogs[Len(oFolder:aDialogs)], aBank[nP_BANCO], aBank[nP_AGENCIA], aBank[nP_CONTA])
		
	EndIf
	
Return()


Method LoadBrowser(oWnd, cBank, cAgency, cAccount) Class TWComposicaoSaldoFinanceiro
Local cVldDef := "AllwaysTrue"
Local oBrw := Nil

	oBrw := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", {},,, cVldDef,, cVldDef, oWnd, ::GetFieldProperty(), ::GetFieldData(cBank, cAgency, cAccount))
	oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrw:oBrowse:bLDblClick := {|| ::Mark(oBrw) }
	oBrw:oBrowse:lVScroll := .T.
	oBrw:oBrowse:lHScroll := .T.
	
	oBrw:oBrowse:Refresh()

Return(oBrw)


Method GetFieldProperty() Class TWComposicaoSaldoFinanceiro
Local oField := TGDField():New()

	// Adciona coluna para tratamento de legenda
	oField:AddField("LEG")
	oField:FieldName("LEG"):cTitle := ""
	oField:FieldName("LEG"):cPict := "@BMP"

	oField:AddField("E5_DTDISPO")
	oField:FieldName("E5_DTDISPO"):cTitle := "Data"
	oField:FieldName("E5_DTDISPO"):cType := "C"  
		
	oField:AddField("E5_HISTOR")
	
	oField:AddField("E5_VALOR")
	oField:FieldName("E5_VALOR"):cTitle := "Valor"

	oField:AddField("E2_VALOR")
	oField:FieldName("E2_VALOR"):cTitle := "Saldo"
	
	oField:AddField("MARK")
	oField:FieldName("MARK"):cTitle := "Conferido"
	oField:FieldName("MARK"):cPict := "@BMP"

	oField:AddField("SPACE")
	
Return(oField:GetHeader())


Method GetFieldData(cBank, cAgency, cAccount) Class TWComposicaoSaldoFinanceiro

	::oBO:cBank := cBank
	::oBO:cAgency := cAgency
	::oBO:cAccount := cAccount
	::oBO:dStartDate := ::dStartDate
	::oBO:dEndDate := ::dEndDate
	
Return(::oBO:GetMovBan())


Method GetCompany() Class TWComposicaoSaldoFinanceiro
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()	

	cSQL := " SELECT Z35_DREDUZ "
	cSQL += "	FROM "+ RetSQLName("Z35")
	cSQL += "	WHERE Z35_FILIAL = "+ ValToSQL(xFilial("Z35"))
	cSQL += " AND Z35_EMP = "+ ValToSQL(cEmpAnt)
	cSQL += "	AND Z35_FIL = '01' "
	cSQL += "	AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)

	cRet := AllTrim((cQry)->Z35_DREDUZ) 
	
	(cQry)->(DbCloseArea())

Return(cRet)


Method GetBankName(cBank) Class TWComposicaoSaldoFinanceiro
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()
Local cName := ""	

	cSQL := " SELECT NOME "
	cSQL += "	FROM BANCOS_FEBRABAN "
	cSQL += "	WHERE CODIGO = "+ ValToSQL(cBank)
	
	TcQuery cSQL New Alias (cQry)

	cName := AllTrim((cQry)->NOME)
	
	(cQry)->(DbCloseArea())
	
	If Empty(cName)
		
		cName := AllTrim(Posicione("SA6", 1, xFilial("SA6") + cBank, "A6_NOME"))
		
	EndIf
	
	cRet := cBank + "-" + cName
	 
Return(cRet)


Method Activate() Class TWComposicaoSaldoFinanceiro
	
	::LoadInterface()
			
	::oWindow:Activate()
		
Return()


Method GetSelectedFolder() Class TWComposicaoSaldoFinanceiro

Return(aScan(::aFolItem, {|x| x[nP_FOL] == ::nFolBank .And. x[nP_FOL_OPTION] == ::aFolSelect[::nFolBank] }))


Method SetSelectedData() Class TWComposicaoSaldoFinanceiro
Local nPos := ::GetSelectedFolder()
	
	::oBO:cBank := ::aFolItem[nPos, nP_FOL_BANCO]
	::oBO:cAgency := ::aFolItem[nPos, nP_FOL_AGENCIA]
	::oBO:cAccount := ::aFolItem[nPos, nP_FOL_CONTA]
	::oBO:dStartDate := ::dStartDate
	::oBO:dEndDate := ::dEndDate
	
	::oSelBrowser := ::aFolItem[nPos, nP_FOL_BROWSE]
	
Return()


Method OnFolBankChange(nOption) Class TWComposicaoSaldoFinanceiro
	
	::nFolBank := nOption	
			
Return()


Method OnFolAccountChange(nOption) Class TWComposicaoSaldoFinanceiro
		
	::aFolSelect[::nFolBank] := nOption
	
Return()


Method Mark(oBrw) Class TWComposicaoSaldoFinanceiro
	
	If oBrw:nAt > 1
	
		If oBrw:aCols[oBrw:nAt, nP_BRW_CHECK] == ::cChk
			
			oBrw:aCols[oBrw:nAt, nP_BRW_CHECK] := ::cUnChk
			
		Else
			
			oBrw:aCols[oBrw:nAt, nP_BRW_CHECK] := ::cChk
			
		EndIf
		
	EndIf
		
Return()


Method Insert() Class TWComposicaoSaldoFinanceiro	
Local oParam := TParLancamentoManual():New()

	::SetSelectedData()
	
	oParam:cBank := ::oBO:cBank
	oParam:cAgency := AllTrim(::oBO:cAgency)
	oParam:cAccount := AllTrim(::oBO:cAccount)
				
	If oParam:Box()
								
		::oBO:Insert(oParam:dDate, oParam:cHist, oParam:nValue, Upper(SubStr(oParam:cType, 1, 1)))
		
		::Refresh()
							
	EndIf
		
Return()


Method Delete() Class TWComposicaoSaldoFinanceiro
Local dDate := dDataBase
Local cHist := ""
Local nValue := 0
Local cType := ""

	::SetSelectedData()

	If SubStr(::oSelBrowser:aCols[::oSelBrowser:nAt, nP_BRW_HIST], 1, 5) == "*****"
	
		If MsgYesNo("Deseja realmente excluir o lançamento manual?")
	
			dDate := ::oSelBrowser:aCols[::oSelBrowser:nAt, nP_BRW_DATA_REF]
			cHist := ::oSelBrowser:aCols[::oSelBrowser:nAt, nP_BRW_HIST]
			nValue := ::oSelBrowser:aCols[::oSelBrowser:nAt, nP_BRW_VALOR]
			cType := If (::oSelBrowser:aCols[::oSelBrowser:nAt, nP_BRW_LEG] == "BR_VERDE", "C", "D")											
			
			::oBO:Delete(dDate, cHist, nValue, cType)
			
			::Refresh()
						
		EndIf
			
	EndIf

Return()


Method Generate() Class TWComposicaoSaldoFinanceiro	
Local nSalAtu := 0
	
	::SetSelectedData()
	
	If ::oBO:GetSalIni(.T.) == 0
	
		nSalAtu := ::oSelBrowser:aCols[::oSelBrowser:oBrowse:nLen, nP_BRW_SALDO]
		
		If nSalAtu <> 0
				
			If MsgYesNo("Deseja realmente gerar o saldo inicial?" + Chr(13) + Chr(10); 
									+ "Mês: " + Month2Str(MonthSum(::dStartDate, 1)) + "/" + Year2Str(::dStartDate) + Chr(13) + Chr(10);
									+ "Valor: R$ " + Alltrim(Transform(nSalAtu, PesqPict("SE2", "E2_VALOR"))))
			
				::oBO:Generate(::oSelBrowser:aCols[::oSelBrowser:oBrowse:nLen, nP_BRW_SALDO])
			
				::Refresh()
				
			EndIf
			
		Else
		
			MsgStop("O saldo atual está zerado!")
			
		EndIf
	
	Else
	
		MsgStop("O saldo inicial do mês: " + Month2Str(MonthSum(::dStartDate, 1)) + "/" + Year2Str(::dStartDate) + " já foi lançado!")
		
	EndIf
				
Return()


Method Refresh(lSet) Class TWComposicaoSaldoFinanceiro
Local bRefresh := {|| If (lSet, ::SetSelectedData(), Nil), ::oSelBrowser:SetArray(::oBO:GetMovBan()), ::oSelBrowser:Refresh()}
	
	Default lSet := .F. 
	
	U_BIAMsgRun("Atualizando saldo financeiro...", "Aguarde!", {|| Eval(bRefresh) })
		
Return()