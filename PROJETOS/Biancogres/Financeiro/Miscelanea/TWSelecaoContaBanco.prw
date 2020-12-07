#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWSelecaoContaBanco
@author Tiago Rossini Coradini
@since 23/12/2018
@version 1.0
@description Classe (tela) selecao de contas bancarias, utilizado na rotina de composicao de saldos financeiros  
@obs Ticket: 4615
@type class
/*/

// TITULOS DAS JANELAS
#DEFINE TIT_WND "Seleção de Contas Bancárias"

#DEFINE nP_CHECK 1
#DEFINE nP_BANCO 2
#DEFINE nP_AGENCIA 3
#DEFINE nP_CONTA 4
#DEFINE nP_NOME 5

// Profile
#DEFINE nPrf_BANCO 1
#DEFINE nPrf_AGENCIA 2
#DEFINE nPrf_CONTA 3

Class TWSelecaoContaBanco From LongClassName

	Data oWindow  
	Data oContainer	
	Data oPanel
	Data cIdHBox	
	Data cChk
	Data cUnChk
	Data oChk
	Data lMarkAll
	Data oBrw	
	Data oField
	Data lConfirm
	Data oProfile
	Data aProfile
	
	Method New() Constructor
	Method LoadInterface()
	Method LoadWindow()
	Method LoadContainer()
	Method LoadBrowser()
	Method Activate()	 
	Method GetFieldProperty()
	Method GetFieldData() 
	Method Mark()
	Method MarkAll()
	Method ExistMark()
	Method SetMark()
	Method GetMark()
	Method Confirm()
	Method LoadProfile()
	Method SaveProfile()

EndClass


Method New() Class TWSelecaoContaBanco

	::oWindow := Nil	
	::oContainer := Nil	
	::oPanel := Nil
	::cIdHBox := ""
	::cChk := "WFCHK"
	::cUnChk := "WFUNCHK"
	::oChk := Nil
	::lMarkAll := .F.
	::oBrw := Nil	
	::oField := TGDField():New()
	::lConfirm := .F.
	
	::oProfile := FWProfile():New()
	::aProfile := {}

Return()


Method LoadInterface() Class TWSelecaoContaBanco

	::LoadProfile()

	::LoadWindow()

	::LoadContainer()

	::LoadBrowser()

Return()


Method LoadWindow() Class TWSelecaoContaBanco

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


Method LoadContainer() Class TWSelecaoContaBanco

	::oContainer := FWFormContainer():New()
	
	::cIdHBox := ::oContainer:CreateHorizontalBox(100)	
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadBrowser() Class TWSelecaoContaBanco
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

	::oBrw := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", {},,, cVldDef,, cVldDef, ::oPanel, ::GetFieldProperty(), ::GetFieldData())
	::oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrw:oBrowse:bLDblClick := {|| ::Mark() }
	::oBrw:oBrowse:lVScroll := .T.
	::oBrw:oBrowse:lHScroll := .T.

Return()


Method Activate() Class TWSelecaoContaBanco	

	::LoadInterface()
	
	::oWindow:Activate()

Return()


Method GetFieldProperty() Class TWSelecaoContaBanco

	::oField:Clear()

	// Adciona coluna para tratamento de marcacao no grid
	::oField:AddField("MARK") 	
	::oField:FieldName("MARK"):cTitle := ""
	::oField:FieldName("MARK"):cPict := "@BMP"

	::oField:AddField("A6_COD")
	::oField:FieldName("A6_COD"):cTitle := "Codigo"
	
	::oField:AddField("A6_AGENCIA")
	::oField:FieldName("A6_AGENCIA"):cTitle := "Agencia"
	
	::oField:AddField("A6_NUMCON")
	::oField:FieldName("A6_NUMCON"):cTitle := "Conta"
	
	::oField:AddField("A6_NOME")
	::oField:FieldName("A6_NOME"):cTitle := "Banco"

Return(::oField:GetHeader())


Method GetFieldData() Class TWSelecaoContaBanco
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()
Local lCheck := .F.

	cSQL := " SELECT A6_COD, A6_AGENCIA, A6_NUMCON, A6_NOME "
	cSQL += "	FROM "+ RetSQLName("SA6") + " SA6 "
	cSQL += "	INNER JOIN "+ RetSQLName("SE8") + " SE8 "
	cSQL += "	ON A6_COD = E8_BANCO "
	cSQL += "	AND A6_AGENCIA = E8_AGENCIA "
	cSQL += "	AND A6_NUMCON = E8_CONTA "
	cSQL += "	WHERE A6_FILIAL = "+ ValToSQL(xFilial("SA6"))
	cSQL += "	AND A6_BLOCKED = '2' "
	cSQL += "	AND SA6.D_E_L_E_T_ = '' "
	cSQL += "	AND E8_FILIAL = "+ ValToSQL(xFilial("SE8"))	
	cSQL += "	AND SE8.D_E_L_E_T_ = '' "
	cSQL += "	GROUP BY A6_COD, A6_AGENCIA, A6_NUMCON, A6_NOME "
	cSQL += "	ORDER BY A6_COD "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())	
		
		lCheck := (aScan(::aProfile, {|x| x[nPrf_BANCO] == (cQry)->A6_COD .And. x[nPrf_AGENCIA] == AllTrim((cQry)->A6_AGENCIA) .And. x[nPrf_CONTA] == AllTrim((cQry)->A6_NUMCON)}) > 0)

		aAdd(aRet, {If (lCheck, ::cChk, ::cUnChk), (cQry)->A6_COD, AllTrim((cQry)->A6_AGENCIA), AllTrim((cQry)->A6_NUMCON), AllTrim((cQry)->A6_NOME), .F.})								 								

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(aRet)


Method Mark() Class TWSelecaoContaBanco

	If ::oBrw:aCols[::oBrw:nAt, nP_CHECK] == ::cChk
		
		::oBrw:aCols[::oBrw:nAt, nP_CHECK] := ::cUnChk
		
	Else
		
		::oBrw:aCols[::oBrw:nAt, nP_CHECK] := ::cChk
		
	EndIf			

Return()


Method MarkAll() Class TWSelecaoContaBanco
Local nCount := 0

	If Len(::oBrw:aCols) > 0
		
		For nCount := 1 To Len(::oBrw:aCols)
	
			If ::lMarkAll
				::oBrw:aCols[nCount, nP_CHECK] := ::cChk
			Else
				::oBrw:aCols[nCount, nP_CHECK] := ::cUnChk
			EndIf
	
		Next
			
		::oBrw:oBrowse:Refresh()
		
	EndIf

Return()


Method ExistMark() Class TWSelecaoContaBanco
Local lRet := .F.

	lRet := aScan(::oBrw:aCols, {|x| x[nP_CHECK] == ::cChk }) > 0

Return(lRet)


Method GetMark() Class TWSelecaoContaBanco
Local aRet := {}

	aEval(::oBrw:aCols, {|aPar| If (aPar[nP_CHECK] == ::cChk, aAdd(aRet, {aPar[nP_BANCO], aPar[nP_AGENCIA], aPar[nP_CONTA]}), Nil) })	
				
Return(aRet)


Method Confirm() Class TWSelecaoContaBanco

	If ::ExistMark()

		::SaveProfile()
			
		::oWindow:oOwner:End()
		
		::lConfirm := .T.
	
	Else
	
		MsgStop("Não existem itens selecionados!")
		
	EndIf 

Return()


Method LoadProfile() Class TWSelecaoContaBanco

	::oProfile:SetTask(cEmpAnt + "_" + GetClassName(Self))
	::oProfile:SetType("MARKBROWSE")
	::oProfile:Load()
	
	::aProfile := ::oProfile:GetProfile()

Return()


Method SaveProfile() Class TWSelecaoContaBanco

	::oProfile:SetProfile(::GetMark())
	::oProfile:Save()

Return()