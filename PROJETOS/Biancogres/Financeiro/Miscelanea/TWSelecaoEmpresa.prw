#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWSelecaoEmpresa
@author Tiago Rossini Coradini
@since 07/06/2018
@version 1.0
@description Classe (tela) selecao de empresas, utilizado na rotina de composicao de saldo financeiro por empresa
@obs Ticket: 1937
@type class
/*/

// TITULOS DAS JANELAS
#DEFINE TIT_WND "Seleção de Empresas"

#DEFINE nP_CHECK 1
#DEFINE nP_EMP 2
#DEFINE nP_NOME 3
#DEFINE nP_NREDUZ 4

// Profile
#DEFINE nPrf_EMP 1
#DEFINE nPrf_NOME 2
#DEFINE nPrf_NREDUZ 3

Class TWSelecaoEmpresa From LongClassName

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
	Method GetMark()
	Method Confirm()
	Method LoadProfile()
	Method SaveProfile()	

EndClass


Method New() Class TWSelecaoEmpresa

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


Method LoadInterface() Class TWSelecaoEmpresa

	::LoadProfile()
	
	::LoadWindow()

	::LoadContainer()

	::LoadBrowser()

Return()


Method LoadWindow() Class TWSelecaoEmpresa
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


Method LoadContainer() Class TWSelecaoEmpresa

	::oContainer := FWFormContainer():New()
	
	::cIdHBox := ::oContainer:CreateHorizontalBox(100)	
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadBrowser() Class TWSelecaoEmpresa
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


Method Activate() Class TWSelecaoEmpresa	

	::LoadInterface()
	
	::oWindow:Activate()

Return()


Method GetFieldProperty() Class TWSelecaoEmpresa

	::oField:Clear()

	// Adciona coluna para tratamento de marcacao no grid
	::oField:AddField("MARK") 	
	::oField:FieldName("MARK"):cTitle := ""
	::oField:FieldName("MARK"):cPict := "@BMP"

	::oField:AddField("EMP")
	::oField:FieldName("EMP"):cTitle := "Empresa"

	::oField:AddField("NOME")
	::oField:FieldName("NOME"):cTitle := "Nome"

Return(::oField:GetHeader())


Method GetFieldData() Class TWSelecaoEmpresa
Local aRet := {}
Local cSQL := ""
Local cQry := GetNextAlias()
Local lCheck := .F.

	cSQL := " SELECT Z35_EMP, Z35_DESCR, Z35_DREDUZ "
	cSQL += "	FROM "+ RetSQLName("Z35")
	cSQL += "	WHERE Z35_FILIAL = "+ ValToSQL(xFilial("Z35"))
	cSQL += "	AND Z35_FIL = '01' "
	cSQL += "	AND D_E_L_E_T_ = '' "
	cSQL += "	GROUP BY Z35_EMP, Z35_DESCR, Z35_DREDUZ "
	cSQL += "	ORDER BY Z35_EMP "
	
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		lCheck := (aScan(::aProfile, {|x| x[nPrf_EMP] == (cQry)->Z35_EMP }) > 0)

		aAdd(aRet, {If (lCheck, ::cChk, ::cUnChk), (cQry)->Z35_EMP, AllTrim((cQry)->Z35_DESCR), AllTrim((cQry)->Z35_DREDUZ), .F.})								 								

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(aRet)


Method Mark() Class TWSelecaoEmpresa

	If ::oBrw:aCols[::oBrw:nAt, nP_CHECK] == ::cChk
		
		::oBrw:aCols[::oBrw:nAt, nP_CHECK] := ::cUnChk
		
	Else
		
		::oBrw:aCols[::oBrw:nAt, nP_CHECK] := ::cChk
		
	EndIf			

Return()


Method MarkAll() Class TWSelecaoEmpresa
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


Method ExistMark() Class TWSelecaoEmpresa
Local lRet := .F.

	lRet := aScan(::oBrw:aCols, {|x| x[nP_CHECK] == ::cChk }) > 0

Return(lRet)


Method GetMark() Class TWSelecaoEmpresa
Local aRet := {}

	aEval(::oBrw:aCols, {|aPar| If (aPar[nP_CHECK] == ::cChk, aAdd(aRet, {aPar[nP_EMP], aPar[nP_NOME], aPar[nP_NREDUZ]}), Nil) })	

Return(aRet)


Method Confirm() Class TWSelecaoEmpresa

	If ::ExistMark()
			
		::SaveProfile()
		
		::oWindow:oOwner:End()
		
		::lConfirm := .T.
	
	Else
	
		MsgStop("Não existem itens selecionados!")
		
	EndIf 

Return()


Method LoadProfile() Class TWSelecaoEmpresa

	::oProfile:SetTask(GetClassName(Self))
	::oProfile:SetType("MARKBROWSE")
	::oProfile:Load()
	
	::aProfile := ::oProfile:GetProfile()

Return()


Method SaveProfile() Class TWSelecaoEmpresa

	::oProfile:SetProfile(::GetMark())
	::oProfile:Save()

Return()