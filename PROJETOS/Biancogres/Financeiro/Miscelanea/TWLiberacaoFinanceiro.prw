#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWLiberacaoFinanceiro
@author Wlysses Cerqueira (Facile)
@since 15/01/2019
@project Automa��o Financeira
@version 1.0
@description Classe para manutencao de deposito identificado
@type class
/*/

#DEFINE TIT_WND "Libera��o Financeira"

#DEFINE nP_CHECK	01
#DEFINE nP_LEGENDA	02


User Function LIB_FINAN()

	Local oObj := TWLiberacaoFinanceiro():New()

	Private cCadastro := OemToAnsi("Liberacao Financeira")

	If ( oObj:oLiberacao:lReceber .Or. oObj:oLiberacao:lPagar ) .Or. ( FWIsAdmin(__cUserID) .And. ( oObj:oLiberacao:lReceber .Or. oObj:oLiberacao:lPagar ) )

		oObj:Pergunte()

		oObj:Activate()

	Else

		Alert("Usuario nao habilitado para acessar a rotina!")

	EndIf

Return()


	Class TWLiberacaoFinanceiro From TAFAbStractClass

		Data oLiberacao

		Data oWindow // Janela principal - FWDialogModal
		Data oContainer	// Divisor de janelas - FWFormContainer
		Data cHeaderBox // Identificador do cabecalho da janela
		Data cItemBox // Identificador dos itens da janela

		Data cChk // Imagem de marcacao
		Data cUnChk // Imagem de marcacao

		Data oChkRec	// Objeto de marcacao
		Data lMarkAllRec // Controla marcacao de todas as linhas
		Data oGridRec // Grid - MsNewGetDados
		Data oGridRecField // EStrutura dos campos do grid - TGDField

		Data oChkPag	// Objeto de marcacao
		Data lMarkAllPag // Controla marcacao de todas as linhas
		Data oGridPag // Grid - MsNewGetDados
		Data oGridPagField // EStrutura dos campos do grid - TGDField

		Data oPanel
		Data oFolder
		Data lFolderReceber
		Data lFolderPagar

		Data cBanco
		Data cAgencia
		Data cConta

		Data aParam
		Data aParRet
		Data bConfirm

		Data lFinalizados
		Data cFinalizados
		Data aAprovador
		Data cCCObrItCt

		Method New() ConStructor
		Method LoadInterface()
		Method LoadWindow()
		Method LoadContainer()
		Method LoadFolder()
		Method LoadBrowser(oWnd, lReceber, lPagar)
		Method Activate()

		Method GDEditableField(lReceber, lPagar)
		Method GDFieldProperty(lReceber, lPagar)

		Method Mark(oGrid)
		Method MarkAll(oGrid, lReceber, lPagar)
		Method ExistMark(oGrid)

		Method ValidAcao(oGrid, lAprovar, lConfirma)
		Method Valid(oGrid, lAprovar, lConfirma)

		Method Save(oGrid, lAprovar, lConfirma)
		Method Confirm(lAprovar, lConfirma)

		Method Pergunte()
		Method PergBanco()

		Method GetQueryReceber()
		Method GetQueryPagar()
		Method GdSeek()
		Method Load(lPergunte)
		Method OrdenarGrid(nCol, oGrid)
		Method Legenda()
		Method TrackerContabil()
		Method DetalheTitulo()
		Method WorkFlow(lAprovado)
		Method SetParam()
		Method SetFolder(nOption)
		Method RateioRPV()



	EndClass

Method New() Class TWLiberacaoFinanceiro

	_Super:New()

	::oLiberacao := TLiberacaoFinanceiro():New()

	::aAprovador := {}

	::SetParam()

	::lFolderReceber := .F.
	::lFolderPagar := .F.

	::oWindow := Nil
	::oPanel := Nil
	::oContainer := Nil
	::cHeaderBox := ""
	::cItemBox := ""

	::oGridRec := Nil
	::oGridRecField := TGDField():New()
	::oChkRec := Nil
	::lMarkAllRec := .F.

	::oGridPag := Nil
	::oGridPagField := TGDField():New()
	::oChkPag := Nil
	::lMarkAllPag := .F.

	::cChk := "WFCHK"
	::cUnChk := "WFUNCHK"

	::cBanco := Space(TamSx3("A6_COD")[1])
	::cAgencia := Space(TamSx3("A6_AGENCIA")[1])
	::cConta := Space(TamSx3("A6_NUMCON")[1])

	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::cFinalizados := "1"
	::cCCObrItCt := "2000"

Return()

Method SetParam() Class TWLiberacaoFinanceiro

	//R001280 - Ticket 23134 (Thiago Haagensen) / R000998|R001412 - Ticket 22205 (Pablo S. Nascimento) /
	//R001454 - Ticket 26279 (Thiago Haagenen)	/ R001625 - Ticket 35280 (Nataniel Junior)
	Local cSolicitante	:= U_GETBIAPAR("MV_YLBSOL", "R000615|R001323|R001154|R001206|R000064|R000998|R001412|R001280|R001454|R001625")
	Local cFinanceiro	:= U_GETBIAPAR("MV_YLBFIN", "R000615|R001323|R001154|R001625")
	Local cAprovador	:= ""
	Local nW 			:= 0
	Local nTamCC		:= 0

	cAprovador += U_GETBIAPAR("MV_YLBAP1", "R0005311000-1|R0005312000-2|R0005313000-3|R0005314000-4|P000531|") // MIKAELLY
	cAprovador += U_GETBIAPAR("MV_YLBAP2", "R0000932000-2|R0000933000-3|R0000931000-1|R0000934000-4|P000093|") // GARDENIA

	cAprovador += U_GETBIAPAR("MV_YLBAP3", "R0000671000-1|R0000674000-4|") // JECIMAR
	cAprovador += U_GETBIAPAR("MV_YLBAP4", "R0000032000-2|") // CAMERINO
	cAprovador += U_GETBIAPAR("MV_YLBAP5", "R0004722000-2|") // VALMIR
	cAprovador += U_GETBIAPAR("MV_YLBAP6", "R0000642000-2|") // CLAUDEIR
	cAprovador += U_GETBIAPAR("MV_YLBAP7", "R0006053000-3|") // SAULO
	cAprovador += U_GETBIAPAR("MV_YLBAP8", "R0004743000-3|") // LUCAS ZENI
	//cAprovador += U_GETBIAPAR("MV_YLBAP9", "P001323|") // THAMARA PLANT

	// Ticket: 22910 - ESTAMOS LEVANDO OS PARAMETROS ACIMA PARA ZL4

	::oLiberacao:lSolicitante	:= ("R" + __cUserID $ cSolicitante) .Or. (FWIsAdmin(__cUserID))
	::oLiberacao:lFinanceiro	:= ("R" + __cUserID $ cFinanceiro) .Or. (FWIsAdmin(__cUserID))
	::oLiberacao:lReceber		:= ("R" + __cUserID $ cSolicitante) .Or. ("R" + __cUserID $ cFinanceiro) .Or. (FWIsAdmin(__cUserID))

	::aAprovador := StrToKarr(cAprovador, "|")

	For nW := 1 To Len(::aAprovador)

		cAprovador := SubStr(::aAprovador[nW], 2, 6)

		nTamCC := Len(SubStr(::aAprovador[nW], 8)) - 2

		If SubStr(::aAprovador[nW], 1, 1) == "R" .And. nTamCC > 0

			If __cUserID == cAprovador

				::oLiberacao:lAprovador := .T.

				::oLiberacao:lReceber := .T.

				::oLiberacao:cCcClaVL += If(Empty(::oLiberacao:cCcClaVL), "", "|") + SubStr(::aAprovador[nW], 8, nTamCC) + SubStr(::aAprovador[nW], Len(::aAprovador[nW]), 1)

			ElseIf FWIsAdmin(__cUserID)

				::oLiberacao:lAprovador := .T.

				::oLiberacao:lReceber := .T.

			EndIf

		ElseIf SubStr(::aAprovador[nW], 1, 1) == "P"

			If __cUserID == cAprovador

				::oLiberacao:lPagar := .T.

			ElseIf FWIsAdmin(__cUserID)

				::oLiberacao:lPagar := .T.

			EndIf

		EndIf

	Next nW

Return()

Method SetFolder(nOption) Class TWLiberacaoFinanceiro

	If ::oLiberacao:lReceber

		If ::oLiberacao:lPagar

			If nOption == 1

				::lFolderReceber := .T.

			Else

				::lFolderReceber := .F.

			EndIf

		Else

			::lFolderReceber := .T.

		EndIf

	EndIf

	If ::oLiberacao:lPagar

		If ::oLiberacao:lReceber

			If nOption == 2

				::lFolderPagar := .T.

			Else

				::lFolderPagar := .F.

			EndIf

		Else

			::lFolderPagar := .T.

		EndIf

	EndIf

Return()

Method LoadInterface() Class TWLiberacaoFinanceiro

	::LoadWindow()

	::LoadContainer()

	::LoadFolder()

Return()


Method LoadWindow() Class TWLiberacaoFinanceiro

	Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()
	::oWindow:SetBackground(.T.)
	::oWindow:SetTitle(TIT_WND + " - Modo:" + If(::oLiberacao:lSolicitante, " Solicitante", "") + If(::oLiberacao:lAprovador, " Aprovador", "") + If(::oLiberacao:lFinanceiro, " Financeiro", ""))
	::oWindow:SetEscClose(.T.)
	::oWindow:SetSize(aCoors[4], aCoors[3])
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()

	If ::oLiberacao:lFinanceiro .Or. ::oLiberacao:lSolicitante

		::oWindow:AddOKButton({|| ::Confirm(.F., .T.) })

	EndIf

	If ::oLiberacao:lAprovador

		::oWindow:AddButton("APROVAR"	, {|| ::Confirm(.T.) },,, .T., .F., .T.)

		::oWindow:AddButton("REJEITAR"	, {|| ::Confirm(.F.) },,, .T., .F., .T.)

	EndIf

	::oWindow:AddCloseButton()

	If FWIsAdmin(__cUserID)

		::oWindow:AddButton("Detalhes titulo"	, {|| U_BIAMsgRun("Carregando dados...", "Aguarde!", {||::DetalheTitulo()}) },,, .T., .F., .T.)

		::oWindow:AddButton("Tracker Contabil"	, {|| U_BIAMsgRun("Carregando dados...", "Aguarde!", {||::TrackerContabil()}) },,, .T., .F., .T.)

		::oWindow:AddButton("Pesquisar"			, {|| ::GdSeek() },,, .T., .F., .T.)

		::oWindow:AddButton("Recarregar", {|| U_BIAMsgRun("Carregando dados...", "Aguarde!", {|| ::Load() }) },,, .T., .F., .T.)

	EndIf

	// Emerson (Facile) em 27/08/2021 - Tela Rateio RPV (BIAFG106)
	::oWindow:AddButton("Rateio RPV", {|| ::RateioRPV() },,, .T., .F., .T.)

	::oWindow:AddButton("Legenda", {|| ::Legenda() },,, .T., .F., .T.)

Return()

Method GdSeek() Class TWLiberacaoFinanceiro

	Local oGrid	:= If(::lFolderReceber, @::oGridRec, If(::lFolderPagar, @::oGridPag, Nil))

	GdSeek(oGrid,,,,.F.)

Return()

Method Legenda() Class TWLiberacaoFinanceiro

	Local aLegenda := {}

	AADD(aLegenda, {"BR_VERDE"		, "T�tulo normal"			})
	AADD(aLegenda, {"BR_AMARELO"	, "Aguardando aprova��o"	})
	AADD(aLegenda, {"BR_AZUL"		, "Aprovado"				})
	AADD(aLegenda, {"BR_VERMELHO"	, "Rejeitado"				})
	AADD(aLegenda, {"BR_PRETO"		, "Finalizado"				})

	BrwLegenda(TIT_WND, "Legenda", aLegenda)

Return()

Method LoadContainer() Class TWLiberacaoFinanceiro

	::oContainer := FWFormContainer():New()

	//::cHeaderBox := ::oContainer:CreateHorizontalBox(30)

	::cItemBox := ::oContainer:CreateHorizontalBox(100)

	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)

Return()

Method LoadBrowser(oWnd, lReceber, lPagar) Class TWLiberacaoFinanceiro

	Local cVldDef := "AllwayStrue"
	Local nMaxLine := 1000

	Default lReceber := .F.
	Default lPagar := .F.

	If lReceber

		::oChkRec := TCheckBox():Create(oWnd)
		::oChkRec:cName := 'oChkRec'
		::oChkRec:cCaption := "Marca / Desmarca todos"
		::oChkRec:nLeft := 0
		::oChkRec:nTop := 0
		::oChkRec:nWidth := 300
		::oChkRec:nHeight := 20
		::oChkRec:lShowHint := .T.
		::oChkRec:cVariable := "::lMarkAllRec"
		::oChkRec:bSetGet := bSetGet(::lMarkAllRec)
		::oChkRec:Align := CONTROL_ALIGN_TOP
		::oChkRec:lVisibleControl := .T.

		::oGridRec := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", ::GDEditableField(lReceber, lPagar),, nMaxLine, cVldDef,, cVldDef, oWnd, ::GDFieldProperty(lReceber, lPagar), ::oLiberacao:GDFieldData(lReceber, lPagar))
		::oGridRec:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		::oGridRec:oBrowse:bLDblClick := {|| ::Mark(@::oGridRec, lReceber, lPagar) }
		::oGridRec:oBrowse:bHeaderClick := {|oGrid, nCol| ::OrdenarGrid(nCol, @::oGridRec)}
		::oGridRec:oBrowse:lVScroll := .T.
		::oGridRec:oBrowse:lHScroll := .T.

		::oChkRec:bChange := {|| ::MarkAll(@::oGridRec, lReceber, lPagar) }

		::oGridRec:oBrowse:Refresh()

	EndIf

	If lPagar

		::oChkPag := TCheckBox():Create(oWnd)
		::oChkPag:cName := 'oChkPag'
		::oChkPag:cCaption := "Marca / Desmarca todos"
		::oChkPag:nLeft := 0
		::oChkPag:nTop := 0
		::oChkPag:nWidth := 300
		::oChkPag:nHeight := 20
		::oChkPag:lShowHint := .T.
		::oChkPag:cVariable := "::lMarkAllPag"
		::oChkPag:bSetGet := bSetGet(::lMarkAllPag)
		::oChkPag:Align := CONTROL_ALIGN_TOP
		::oChkPag:lVisibleControl := .T.

		::oGridPag := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", ::GDEditableField(lReceber, lPagar),, nMaxLine, cVldDef,, cVldDef, oWnd, ::GDFieldProperty(lReceber, lPagar), ::oLiberacao:GDFieldData(lReceber, lPagar))
		::oGridPag:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		::oGridPag:oBrowse:bLDblClick := {|| ::Mark(@::oGridPag, lReceber, lPagar) }
		::oGridPag:oBrowse:bHeaderClick := {|oGrid, nCol| ::OrdenarGrid(nCol, @::oGridPag)}
		::oGridPag:oBrowse:lVScroll := .T.
		::oGridPag:oBrowse:lHScroll := .T.

		::oChkPag:bChange := {|| ::MarkAll(@::oGridPag, lReceber, lPagar) }

		::oGridPag:oBrowse:Refresh()

	EndIf

Return()

Method OrdenarGrid(nCol, oGrid) Class TWLiberacaoFinanceiro

	oGrid:aCols := aSort( oGrid:aCols,,,{|x,y| x[nCol] < y[nCol]} )

	oGrid:SetArray(oGrid:aCols, .F.)

	oGrid:oBrowse:Refresh()

Return()

Method LoadFolder() Class TWLiberacaoFinanceiro

	Local nCount := 0

	::oPanel := ::oContainer:GetPanel(::cItemBox)

	::oFolder := TFolder():New(0, 0, {},, ::oPanel,,,,.T.,,0,0)
	::oFolder:Align := CONTROL_ALIGN_ALLCLIENT

	::oFolder:bSetOption := {|nOption| ::SetFolder(nOption)}

	If ::oLiberacao:lReceber

		::oFolder:AddItem("Contas a Receber", .T.)

		::LoadBrowser(::oFolder:aDialogs[1], .T., .F.)

	EndIf

	If ::oLiberacao:lPagar

		::oFolder:AddItem("Contas a Pagar", .T.)

		If ::oLiberacao:lReceber

			::LoadBrowser(::oFolder:aDialogs[2], .F., .T.)

		Else

			::LoadBrowser(::oFolder:aDialogs[1], .F., .T.)

		EndIf

	EndIf

	::oFolder:SetOption(1)

Return()

Method Load(lPergunte) Class TWLiberacaoFinanceiro

	Local oGrid	:= If(::lFolderReceber, @::oGridRec, If(::lFolderPagar, @::oGridPag, Nil))

	Default lPergunte := .T.

	If lPergunte

		::Pergunte()

	EndIf

	oGrid:aCols := ::oLiberacao:GDFieldData(::lFolderReceber, ::lFolderPagar)

	oGrid:SetArray(oGrid:aCols, .F.)

	oGrid:oBrowse:Refresh()

	oGrid:Refresh()

Return()

Method Activate() Class TWLiberacaoFinanceiro

	::LoadInterface()

	::oWindow:Activate()

Return()


Method GDEditableField(lReceber, lPagar) Class TWLiberacaoFinanceiro

	Local aRet := {}

	If ::oLiberacao:lSolicitante .Or. (lPagar .And. ::oLiberacao:lAprovador)

		aRet := {"ZL0_VENCTO", "ZL0_DESCON", "ZL0_OBSLIB", "ZL0_ITEMD", "ZL0_DEBITO", "ZL0_CLVLDB", "ZL0_CCD", "ZL0_CTRVER"}

	EndIf

Return(aRet)


Method GDFieldProperty(lReceber, lPagar) Class TWLiberacaoFinanceiro

	Local aRet := {}

	If lReceber

		::oGridRecField:Clear()

		// Adciona coluna para tratamento de marcacao no grid
		::oGridRecField:AddField("MARK")
		::oGridRecField:FieldName("MARK"):cTitle := ""
		::oGridRecField:FieldName("MARK"):cPict := "@BMP"

		// Adciona coluna para tratamento de marcacao no grid
		::oGridRecField:AddField("LEGENDA")
		::oGridRecField:FieldName("LEGENDA"):cTitle := ""
		::oGridRecField:FieldName("LEGENDA"):cPict := "@BMP"

		::oGridRecField:AddField("ZL0_NUM")
		::oGridRecField:AddField("ZL0_PREFIX")
		::oGridRecField:AddField("ZL0_PARCEL")
		::oGridRecField:AddField("ZL0_TIPO")
		::oGridRecField:AddField("E1_NATUREZ")
		::oGridRecField:AddField("ZL0_CLIFOR")
		::oGridRecField:FieldName("ZL0_CLIFOR"):cTitle := "Cliente"
		::oGridRecField:AddField("ZL0_LOJA")
		::oGridRecField:AddField("E1_NOMCLI")
		::oGridRecField:AddField("ZL0_EMISSA")
		::oGridRecField:AddField("ZL0_VENCTO")
		::oGridRecField:AddField("ZL0_VENCRE")
		::oGridRecField:AddField("ZL0_VALOR")
		::oGridRecField:AddField("ZL0_SALDO")
		::oGridRecField:AddField("ZL0_DESCON")
		::oGridRecField:AddField("ZL0_CLVLDB")
		::oGridRecField:AddField("ZL0_CCD")
		::oGridRecField:AddField("ZL0_ITEMD")
		::oGridRecField:AddField("ZL0_DEBITO")
		::oGridRecField:AddField("ZL0_CTRVER")
		::oGridRecField:AddField("ZL0_OBSLIB")

		//::oGridRecField:AddField("Space")

		aRet := ::oGridRecField:GetHeader()

	EndIf

	If lPagar

		::oGridPagField:Clear()

		// Adciona coluna para tratamento de marcacao no grid
		::oGridPagField:AddField("MARK")
		::oGridPagField:FieldName("MARK"):cTitle := ""
		::oGridPagField:FieldName("MARK"):cPict := "@BMP"

		// Adciona coluna para tratamento de marcacao no grid
		::oGridPagField:AddField("LEGENDA")
		::oGridPagField:FieldName("LEGENDA"):cTitle := ""
		::oGridPagField:FieldName("LEGENDA"):cPict := "@BMP"

		::oGridPagField:AddField("ZL0_NUM")
		::oGridPagField:AddField("ZL0_PREFIX")
		::oGridPagField:AddField("ZL0_PARCEL")
		::oGridPagField:AddField("ZL0_TIPO")
		::oGridPagField:AddField("E1_NATUREZ")
		::oGridPagField:AddField("ZL0_CLIFOR")
		::oGridPagField:FieldName("ZL0_CLIFOR"):cTitle := "Fornecedor"
		::oGridPagField:AddField("ZL0_LOJA")
		::oGridPagField:AddField("E1_NOMCLI")
		::oGridPagField:AddField("ZL0_EMISSA")
		::oGridPagField:AddField("ZL0_VENCTO")
		::oGridPagField:AddField("ZL0_VENCRE")
		::oGridPagField:AddField("ZL0_VALOR")
		::oGridPagField:AddField("ZL0_SALDO")
		::oGridPagField:AddField("ZL0_OBSLIB")

		aRet := ::oGridPagField:GetHeader()

	EndIf

Return(aRet)

Method Mark(oGrid) Class TWLiberacaoFinanceiro

	If oGrid:lActive

		If Len(oGrid:aCols) > 0

			If oGrid:aCols[oGrid:oBrowse:nAT][nP_LEGENDA] $ "BR_VERDE|BR_AMARELO|BR_AZUL" .And. aScan(oGrid:aAlter, {|x| AllTrim(x) == AllTrim(oGrid:aHeader[oGrid:oBrowse:Colpos, 2])}) > 0 .And. oGrid:aHeader[oGrid:oBrowse:Colpos, 3] <> "@BMP"

				oGrid:EditCell()

			ElseIf oGrid:aCols[oGrid:nAt, nP_CHECK] == ::cChk

				oGrid:aCols[oGrid:nAt, nP_CHECK] := ::cUnChk

			Else

				oGrid:aCols[oGrid:nAt, nP_CHECK] := ::cChk

			EndIf

		EndIf

	EndIf

Return()


Method MarkAll(oGrid, lReceber, lPagar) Class TWLiberacaoFinanceiro

	Local nCount := 0
	Local lMarkAll := If(lReceber, ::lMarkAllRec, ::lMarkAllPag)

	If oGrid:lActive

		If Len(oGrid:aCols) > 0

			For nCount := 1 To Len(oGrid:aCols)

				If lMarkAll

					oGrid:aCols[nCount, nP_CHECK] := ::cChk

				Else

					oGrid:aCols[nCount, nP_CHECK] := ::cUnChk

				EndIf

			Next nCount

			oGrid:oBrowse:Refresh()

		EndIf

	EndIf

Return()


Method ExistMark(oGrid) Class TWLiberacaoFinanceiro

	Local lRet := .T.

	If aScan(oGrid:aCols, {|x| x[nP_CHECK] == ::cChk }) == 0

		lRet := .F.

		MsgAlert("Aten��o, nenhum t�tulo foi selecionado.")

	EndIf

Return(lRet)


Method Valid(oGrid, lAprovar, lConfirma) Class TWLiberacaoFinanceiro

	Local lRet := .T.

	lRet := oGrid:TudoOk() .And. ::ExistMark(oGrid) .And. ::ValidAcao(oGrid, lAprovar, lConfirma)

Return(lRet)

Method ValidAcao(oGrid, lAprovar, lConfirma) Class TWLiberacaoFinanceiro

	Local aAreaSE1 := SE1->(GetArea())
	Local aAreaSE2 := SE2->(GetArea())
	Local aAreaSX3 := SX3->(GetArea())

	Local nW := 0
	Local nX := 0
	Local lRet := .T.
	Local cAlias := ""
	Local nPosPref := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_PREFIX"})
	Local nPosNum  := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_NUM"})
	Local nPosParc := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_PARCEL"})
	Local nPosTipo := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_TIPO"})
	Local nPosCliF := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_CLIFOR"})
	Local nPosLoja := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_LOJA"})
	Local nPosEmis := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_EMISSA"})
	Local nPosVenc := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_VENCTO"})
	Local nPosVenR := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_VENCRE"})
	Local nPosVlr  := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_VALOR"})
	Local nPosSald := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_SALDO"})
	Local nPosDesc := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_DESCON"})
	Local nPosObs  := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_OBSLIB"})

	Local nPosIteD  := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_ITEMD"})
	Local nPosDebi  := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_DEBITO"})
	Local nPosClDb  := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_CLVLDB"})
	Local nPosCCD 	:= aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_CCD"})
	Local nPosVerb  := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_CTRVER"})

	Local aCpoObrDes := {"ZL0_VENCTO", "ZL0_DESCON", "ZL0_OBSLIB", "ZL0_DEBITO", "ZL0_CLVLDB", "ZL0_CCD"}
	Local aCpoObrVen := {"ZL0_OBSLIB", "ZL0_CLVLDB", "ZL0_CCD"}

	Local nPos := 0

	If ::lFolderReceber

		cAlias := "SE1"

		DBSelectArea("SE1")
		SE1->(DBSetOrder(2)) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_

	ElseIf ::lFolderPagar

		cAlias := "SE2"

		DBSelectArea("SE2")
		SE2->(DBSetOrder(6)) // E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, R_E_C_N_O_, D_E_L_E_T_

	EndIf

	DBSelectArea("SX3")
	SX3->(DBSetOrder(2))

	For nW := 1 To Len(oGrid:aCols)

		If oGrid:aCols[nW, nP_CHECK] == ::cChk

			If !(cAlias)->(DBSeek(xFilial(cAlias) + oGrid:aCols[nW][nPosCliF] + oGrid:aCols[nW][nPosLoja] + oGrid:aCols[nW][nPosPref] + oGrid:aCols[nW][nPosNum] + oGrid:aCols[nW][nPosParc] + oGrid:aCols[nW][nPosTipo]))

				MsgAlert("Aten��o, t�tulo n�o encontrado no financeiro.")

				oGrid:GoTo(nW)

				oGrid:oBrowse:SetFocus()

				lRet := .F.

				Exit

			EndIf

			If oGrid:aCols[nW, nP_LEGENDA] == "BR_AZUL" .And. !lConfirma

				MsgAlert("Aten��o, t�tulo ja esta aprovado!")

				lRet := .F.

				oGrid:GoTo(nW)

				oGrid:oBrowse:SetFocus()

				Exit

			EndIf

			If oGrid:aCols[nW, nP_LEGENDA] == "BR_AZUL" .And. !::oLiberacao:lFinanceiro

				MsgAlert("Aten��o, usu�rio n�o habilitado!")

				lRet := .F.

				oGrid:GoTo(nW)

				oGrid:oBrowse:SetFocus()

				Exit

			EndIf

			If oGrid:aCols[nW, nP_LEGENDA] == "BR_VERDE" .And. !lConfirma

				MsgAlert("Aten��o, t�tulo n�o foi enviado para aprova��o!")

				lRet := .F.

				oGrid:GoTo(nW)

				oGrid:oBrowse:SetFocus()

				Exit

			EndIf

			If oGrid:aCols[nW, nP_LEGENDA] == "BR_AMARELO" .And. lConfirma

				MsgAlert("Aten��o, t�tulo deve ser aprovado ou rejeitado!")

				lRet := .F.

				oGrid:GoTo(nW)

				oGrid:oBrowse:SetFocus()

				Exit

			EndIf

			If oGrid:aCols[nW, nP_LEGENDA] == "BR_PRETO"

				MsgAlert("Aten��o, t�tulo ja foi finalizado!")

				lRet := .F.

				oGrid:GoTo(nW)

				oGrid:oBrowse:SetFocus()

				Exit

			EndIf

			If oGrid:aCols[nW, nP_LEGENDA] == "BR_VERMELHO"

				MsgAlert("Aten��o, t�tulo foi rejeitado!")

				lRet := .F.

				oGrid:GoTo(nW)

				oGrid:oBrowse:SetFocus()

				Exit

			EndIf

			If oGrid:aCols[nW, nP_LEGENDA] == "BR_VERDE"

				If oGrid:aCols[nW][nPosDesc] == 0 .And. oGrid:aCols[nW][nPosVenc] == SE1->E1_VENCTO

					MsgAlert("Aten��o, n�o informado desconto ou nova data de vencimento.")

					oGrid:GoTo(nW)

					oGrid:oBrowse:SetFocus()

					lRet := .F.

					Exit

				EndIf

				If oGrid:aCols[nW][nPosDesc] > oGrid:aCols[nW][nPosSald]

					MsgAlert("Aten��o, o desconto n�o pode ser maior que o saldo.")

					oGrid:GoTo(nW)

					oGrid:oBrowse:SetFocus()

					lRet := .F.

					Exit

				EndIf

			EndIf

			If !lRet

				Exit

			EndIf

			If oGrid:aCols[nW, nP_LEGENDA] == "BR_AMARELO" .And. ::lFolderPagar .And. !lConfirma

				If AllTrim(oGrid:aCols[nW, nPosObs]) == "PA" .Or. AllTrim(oGrid:aCols[nW, nPosObs]) == "DESCONTO"

					MsgAlert("Aten��o, Favor informar o motivo da" + If(lAprovar, " aprova��o", " rejei��o") + " no campo 'Obs Liberac'!")

					lRet := .F.

					oGrid:GoTo(nW)

					oGrid:oBrowse:SetFocus()

					Exit

				EndIf

			EndIf

			If oGrid:aCols[nW, nP_LEGENDA] <> "BR_AMARELO" .And. ::lFolderReceber .And. oGrid:aCols[nW][nPosDesc] > 0

				For nX := 1 To Len(aCpoObrDes)

					SX3->(DBSeek(aCpoObrDes[nX]))

					nPos := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == aCpoObrDes[nX]})

					If aCpoObrDes[nX] == "ZL0_CCD" .And. AllTrim(oGrid:aCols[nW, nPos]) $ ::cCCObrItCt .And. Empty(oGrid:aCols[nW, nPosIteD])

						SX3->(DBSeek("ZL0_ITEMD"))

						MsgAlert("Aten��o, campo '" + AllTrim(X3Titulo()) + "' obrigat�rio para o centro de custo " + AllTrim(::cCCObrItCt) + " !")

						lRet := .F.

						oGrid:GoTo(nW)

						oGrid:oBrowse:SetFocus()

					ElseIf Empty(oGrid:aCols[nW, nPos])

						MsgAlert("Aten��o, campo '" + AllTrim(X3Titulo()) + "' obrigat�rio!")

						lRet := .F.

						oGrid:GoTo(nW)

						oGrid:oBrowse:SetFocus()

						Exit

					EndIf

				Next nX

			EndIf

			If !lRet

				Exit

			EndIf

			If oGrid:aCols[nW, nP_LEGENDA] <> "BR_AMARELO" .And. oGrid:aCols[nW][nPosVenc] <> SE1->E1_VENCTO

				For nX := 1 To Len(aCpoObrVen)

					SX3->(DBSeek(aCpoObrVen[nX]))

					nPos := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == aCpoObrVen[nX]})

					If Empty(oGrid:aCols[nW, nPos])

						MsgAlert("Aten��o, campo '" + AllTrim(X3Titulo()) + "' obrigat�rio!")

						lRet := .F.

						oGrid:GoTo(nW)

						oGrid:oBrowse:SetFocus()

						Exit

					EndIf

				Next nX

			EndIf

			If !lRet

				Exit

			EndIf

		EndIf

	Next nW

	oGrid:Refresh()

	RestArea(aAreaSE1)
	RestArea(aAreaSE2)
	RestArea(aAreaSX3)

Return(lRet)


Method Save(oGrid, lAprovar, lConfirma) Class TWLiberacaoFinanceiro

	Local aAreaSE1 := SE1->(GetArea())
	Local aAreaSE2 := SE2->(GetArea())

	Local nW := 0
	Local lExist := .F.
	Local lPergBanco := .F.
	Local oRecompra		:= Nil

	Local nPosPref := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_PREFIX"})
	Local nPosNum  := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_NUM"})
	Local nPosParc := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_PARCEL"})
	Local nPosTipo := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_TIPO"})
	Local nPosCliF := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_CLIFOR"})
	Local nPosLoja := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_LOJA"})
	Local nPosEmis := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_EMISSA"})
	Local nPosVenc := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_VENCTO"})
	Local nPosVenR := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_VENCRE"})
	Local nPosVlr  := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_VALOR"})
	Local nPosSald := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_SALDO"})
	Local nPosDesc := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_DESCON"})
	Local nPosObs  := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_OBSLIB"})

	Local nPosIteD  := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_ITEMD"})
	Local nPosDebi  := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_DEBITO"})
	Local nPosClDb  := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_CLVLDB"})
	Local nPosCCD 	:= aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_CCD"})
	Local nPosVerb  := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_CTRVER"})

	Default lAprovar := .F.
	Default lConfirma := .F.

	Public __F70TITITEMD
	Public __F70TITDEBITO
	Public __F70TITCLVLDB
	Public __F70TITCTRVER
	Public __F70TITCCD

	If ::lFolderReceber

		cAlias := "SE1"

		DBSelectArea("SE1")
		SE1->(DBSetOrder(2)) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_

	ElseIf ::lFolderPagar

		cAlias := "SE2"

		DBSelectArea("SE2")
		SE2->(DBSetOrder(6)) // E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, R_E_C_N_O_, D_E_L_E_T_

	EndIf

	DBSelectArea("ZL0")
	ZL0->(DBSetorder(1)) // ZL0_FILIAL+ZL0_CODEMP+ZL0_CODFIL+ZL0_CART+ZL0_PREFIX+ZL0_NUM+ZL0_PARCEL+ZL0_TIPO+ZL0_CLIFOR+ZL0_LOJA

	::oPro:Start()

	If ::oLiberacao:lAprovador .And. !lConfirma

		If ! MsgYesNo("Confirma " + If(lAprovar, " aprova��o?", " rejei��o?"))

			Return()

		EndIf

	EndIf

	Begin Transaction

		For nW := 1 To Len(oGrid:aCols)

			If oGrid:aCols[nW, nP_CHECK] == ::cChk

				If (cAlias)->(DBSeek(xFilial(cAlias) + oGrid:aCols[nW][nPosCliF] + oGrid:aCols[nW][nPosLoja] + oGrid:aCols[nW][nPosPref] + oGrid:aCols[nW][nPosNum] + oGrid:aCols[nW][nPosParc] + oGrid:aCols[nW][nPosTipo]))

					lExist := ZL0->(DBSeek(xFilial("ZL0") + cEmpAnt + cFilAnt + If(::lFolderReceber, "R", If(::lFolderPagar, "P", "")) + oGrid:aCols[nW][nPosPref] + oGrid:aCols[nW][nPosNum] + oGrid:aCols[nW][nPosParc] + oGrid:aCols[nW][nPosTipo] + oGrid:aCols[nW][nPosCliF] + oGrid:aCols[nW][nPosLoja]))

					//If oGrid:aCols[nW, nP_LEGENDA] $ "BR_VERDE|BR_AMARELO"

					RecLock("ZL0", !lExist)

					ZL0->ZL0_FILIAL := xFilial("ZL0")
					ZL0->ZL0_CODEMP := cEmpAnt
					ZL0->ZL0_CODFIL := cFilAnt
					ZL0->ZL0_CART   := If(::lFolderReceber, "R", If(::lFolderPagar, "P", ""))
					ZL0->ZL0_NUM    := oGrid:aCols[nW][nPosNum]
					ZL0->ZL0_PREFIX := oGrid:aCols[nW][nPosPref]
					ZL0->ZL0_PARCEL := oGrid:aCols[nW][nPosParc]
					ZL0->ZL0_TIPO   := oGrid:aCols[nW][nPosTipo]
					ZL0->ZL0_CLIFOR := oGrid:aCols[nW][nPosCliF]
					ZL0->ZL0_LOJA   := oGrid:aCols[nW][nPosLoja]
					ZL0->ZL0_EMISSA := oGrid:aCols[nW][nPosEmis]
					ZL0->ZL0_VENCTO := oGrid:aCols[nW][nPosVenc]
					ZL0->ZL0_VENCRE := oGrid:aCols[nW][nPosVenR]
					ZL0->ZL0_VALOR  := oGrid:aCols[nW][nPosVlr]
					ZL0->ZL0_SALDO  := oGrid:aCols[nW][nPosSald]
					ZL0->ZL0_OBSLIB := oGrid:aCols[nW][nPosObs]
					ZL0->ZL0_STATUS := "2" // 1=Normal;2=Aguardando aprov;3=Aprovado;4=Rejeitado;5=Finalizado

					If ::lFolderReceber

						ZL0->ZL0_DESCON := oGrid:aCols[nW][nPosDesc]
						ZL0->ZL0_ITEMD  := oGrid:aCols[nW][nPosIteD]
						ZL0->ZL0_DEBITO := oGrid:aCols[nW][nPosDebi]
						ZL0->ZL0_CLVLDB := oGrid:aCols[nW][nPosClDb]
						ZL0->ZL0_CCD 	  := oGrid:aCols[nW][nPosCCD]
						ZL0->ZL0_CTRVER := oGrid:aCols[nW][nPosVerb]

						//Filipe - Facile - 30/09/2021 | Ticket: 26221

						If CkDescFin()
							FwAlertWarning('Email de libera��o de desconto n�o est� respondendo.','Warning - TWLiberacaoFinanceiro.prw')
							ZL0->(MsUnLock())
							DisarmTransaction()
							RETURN .F.
						EndIf

						//Filipe - Facile - 30/09/2021 | Ticket: 26221

					EndIf

					ZL0->(MsUnLock())

					If oGrid:aCols[nW, nP_LEGENDA] == "BR_VERDE"

						RecLock("SE1", .F.)
						SE1->E1_YBLQ := "02"
						SE1->E1_YVLDESC := oGrid:aCols[nW][nPosDesc]
						SE1->(MsUnLock())

						// Emerson (Facile) em 30/08/2021 - Tela Rateio RPV (BIAFG106) - Efetiva a grava��o na tabela ZNC (Deixa em branco o campo ZNC_FLGGRV), ap�s clicar no
						// U_FGT106EF("3", SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO), "S")

					EndIf

					//EndIf

					If oGrid:aCols[nW, nP_LEGENDA] == "BR_AMARELO"

						RecLock("ZL0", .F.)
						ZL0->ZL0_STATUS := If(lAprovar, "3", "4")
						ZL0->(MsUnLock())

						If ::lFolderReceber

							RecLock("SE1", .F.)

							If lAprovar

								SE1->E1_YBLQ 	:= StrZero(Randomize( 3, 99 ), 2)
								SE1->E1_YVLDESC := oGrid:aCols[nW][nPosDesc]
								SE1->E1_YOBSLIB := oGrid:aCols[nW][nPosObs]

							Else

								SE1->E1_YBLQ 	:= ""
								SE1->E1_YOBSLIB	:= ""

							EndIf

							SE1->(MsUnLock())

						ElseIf ::lFolderPagar

							RecLock("SE2", .F.)

							If lAprovar

								SE2->E2_YBLQ 	:= "XX"
								SE2->E2_YOBSLIB := oGrid:aCols[nW][nPosObs]

							Else

								SE2->E2_YBLQ 	:= ""
								SE2->E2_YOBSLIB	:= oGrid:aCols[nW][nPosObs]

							EndIf

							SE2->(MsUnLock())

						EndIf

						::WorkFlow(lAprovar)

					EndIf

					If oGrid:aCols[nW, nP_LEGENDA] == "BR_AZUL"

						If oGrid:aCols[nW][nPosDesc] > 0

							If !lPergBanco

								If ::PergBanco()

									lPergBanco := .T.

								Else

									Exit

								EndIf

							EndIf

							__F70TITITEMD  := oGrid:aCols[nW][nPosIteD]
							__F70TITDEBITO := oGrid:aCols[nW][nPosDebi]
							__F70TITCLVLDB := oGrid:aCols[nW][nPosClDb]
							__F70TITCTRVER := oGrid:aCols[nW][nPosVerb]
							__F70TITCCD    := oGrid:aCols[nW][nPosCCD]

							lRet := ::oLiberacao:Baixar(oGrid:aCols[nW][nPosDesc], ::cBanco, ::cAgencia, ::cConta)

							If !lRet

								DisarmTransaction()

								Alert("Ocorreu um erro no processamento!" + CRLF + CRLF + ::oLiberacao:cErro)

								Exit

							Else

								//|Projeto FIDC Recompra |
								oRecompra	:= TFPFidcRecompraReceber():New()

								oRecompra:cPrefixo          := SE1->E1_PREFIXO
								oRecompra:cNumero           := SE1->E1_NUM
								oRecompra:cParcela          := SE1->E1_PARCELA
								oRecompra:cTipo             := SE1->E1_TIPO
								oRecompra:cCodigoCliente    := SE1->E1_CLIENTE
								oRecompra:cLojaCliente      := SE1->E1_LOJA
								oRecompra:cNossoNumero      := SE1->E1_NUMBCO
								oRecompra:nValorOriginal    := SE1->E1_VALOR
								oRecompra:nSaldoTitulo      := SE1->E1_SALDO
								oRecompra:dVencimento       := SE1->E1_VENCREA
								oRecompra:nValorDesconto    := oGrid:aCols[nW][nPosDesc]
								oRecompra:nRecnoSE1    			:= SE1->( Recno() )

								oRecompra:AdicionaTituloRecompra()

								FreeObj(oRecompra)

							EndIf

						EndIf

						RecLock("ZL0", .F.)
						ZL0->ZL0_STATUS := "5"
						ZL0->(MsUnLock())

						RecLock("SE1", .F.)
						SE1->E1_YBLQ := "XX"

						If oGrid:aCols[nW][nPosVenc] <> SE1->E1_VENCTO

							SE1->E1_VENCTO := oGrid:aCols[nW][nPosVenc]
							SE1->E1_VENCREA := oGrid:aCols[nW][nPosVenR]

						EndIf

						SE1->(MsUnLock())

					EndIf

				EndIf

			EndIf

		Next nW

	End Transaction

	::oPro:Finish()

	RestArea(aAreaSE1)
	RestArea(aAreaSE2)

Return()


Method Confirm(lAprovar, lConfirma) Class TWLiberacaoFinanceiro

	Local oGrid := Nil

	If ::lFolderReceber

		oGrid := @::oGridRec

	ElseIf ::lFolderPagar

		oGrid := @::oGridPag

	EndIf

	If ::Valid(oGrid, lAprovar, lConfirma)

		U_BIAMsgRun("Salvando dados...", "Aguarde!", {|| ::Save(oGrid, lAprovar, lConfirma) })

		::Load(.F.)

	EndIf

Return()

Method PergBanco() Class TWLiberacaoFinanceiro

	Local lRet := .F.
	Local nTam := 0

	::bConfirm := {|| .T. }

	::aParam := {}

	::aParRet := {}

	aAdd(::aParam, {1, "Banco"		, ::cBanco		, "@!", ".T.", "SA6", ".T.",,.F.})
	aAdd(::aParam, {1, "Ag�ncia"	, ::cAgencia	, "@!", ".T.",, ".T.",,.F.})
	aAdd(::aParam, {1, "Conta"		, ::cConta		, "@!", ".T.",, ".T.",,.F.})

	If Len(::aParam) > 0

		If ParamBox(::aParam, "Opera��es", ::aParRet, ::bConfirm,,,,,,"LIBFI1", .T., .T.)

			lRet := .T.

			nTam++

			::cBanco	:= ::aParRet[nTam++]
			::cAgencia	:= ::aParRet[nTam++]
			::cConta 	:= ::aParRet[nTam++]

		EndIf

	EndIf

Return(lRet)

Method Pergunte() Class TWLiberacaoFinanceiro

	Local lRet := .F.
	Local nTam := 0
	Local dData := DATE() + 365 //um ano a frente para o intervalo de data

	::bConfirm := {|| .T. }

	::aParam := {}

	::aParRet := {}

	If ::oLiberacao:lReceber

		If ::oLiberacao:lSolicitante

			aAdd(::aParam, {1, "Venc. Real de"	, ::oLiberacao:cVencrDe	, "@!", ".T.",		,".T.",,.F.})
			aAdd(::aParam, {1, "Venc. Real ate"	, ::oLiberacao:cVencrAte	, "@!", ".T.",		,".T.",,.F.})

			//aAdd(::aParam, {1, "Bordero de"		, ::oLiberacao:cBorDe		, "@!", ".T.",		,".T.",,.F.})
			//aAdd(::aParam, {1, "Bordero ate"	, ::oLiberacao:cBorAte		, "@!", ".T.",		,".T.",,.F.})

			aAdd(::aParam, {1, "Num. Titulo de"	, ::oLiberacao:cNumDe		, "@!", ".T.",		,".T.",,.F.})
			aAdd(::aParam, {1, "Num. Titulo ate", ::oLiberacao:cNumAte		, "@!", ".T.",		,".T.",,.F.})

			aAdd(::aParam, {1, "Prefixo de"		, ::oLiberacao:cPrefDe		, "@!", ".T.",		,".T.",,.F.})
			aAdd(::aParam, {1, "Prefixo ate"	, ::oLiberacao:cPrefAte	, "@!", ".T.",		,".T.",,.F.})

			aAdd(::aParam, {1, "Tipo de"		, ::oLiberacao:cTipoDe		, "@!", ".T.",		,".T.",,.F.})
			aAdd(::aParam, {1, "Tipo ate"		, ::oLiberacao:cTipoAte	, "@!", ".T.",		,".T.",,.F.})

			aAdd(::aParam, {1, "Parcela de"		, ::oLiberacao:cParcDe		, "@!", ".T.",		,".T.",,.F.})
			aAdd(::aParam, {1, "Parcela ate"	, ::oLiberacao:cParcAte	, "@!", ".T.",		,".T.",,.F.})

			aAdd(::aParam, {1, "Cliente de"		, ::oLiberacao:cForneceDe	, "@!", ".T.","SA2",".T.",,.F.})
			aAdd(::aParam, {1, "Cliente ate"	, ::oLiberacao:cForneceAte, "@!", ".T.","SA2",".T.",,.F.})

			aAdd(::aParam, {1, "Loja de"		, ::oLiberacao:cLojaDe		, "@!", ".T.",		,".T.",,.F.})
			aAdd(::aParam, {1, "Loja ate"		, ::oLiberacao:cLojaAte	, "@!", ".T.",		,".T.",,.F.})

		EndIf

		//If ::oLiberacao:lFinanceiro

		aAdd(::aParam, {2, "Mostrar finalizados/Rejeitados", ::cFinalizados, {"1=N�o", "2=Sim", "3=Ambas"}, 60, ".T.", .F.})

		//EndIf

		If Len(::aParam) > 0

			If ParamBox(::aParam, "Opera��es", ::aParRet, ::bConfirm,,,,,,If(::oLiberacao:lSolicitante, "LIBFI2", "LIBFI3"), .T., .T.)

				lRet := .T.

				nTam++

				If ::oLiberacao:lSolicitante

					::oLiberacao:cVencrDe		:= ::aParRet[nTam++]
					::oLiberacao:cVencrAte		:= ::aParRet[nTam++]
					//::oLiberacao:cBorDe 	    := ::aParRet[nTam++]
					//::oLiberacao:cBorAte      := ::aParRet[nTam++]
					::oLiberacao:cNumDe 	    := ::aParRet[nTam++]
					::oLiberacao:cNumAte       	:= ::aParRet[nTam++]
					::oLiberacao:cPrefDe       	:= ::aParRet[nTam++]
					::oLiberacao:cPrefAte      	:= ::aParRet[nTam++]
					::oLiberacao:cTipoDe       	:= ::aParRet[nTam++]
					::oLiberacao:cTipoAte      	:= ::aParRet[nTam++]
					::oLiberacao:cParcDe       	:= ::aParRet[nTam++]
					::oLiberacao:cParcAte      	:= ::aParRet[nTam++]
					::oLiberacao:cForneceDe    	:= ::aParRet[nTam++]
					::oLiberacao:cForneceAte	:= ::aParRet[nTam++]
					::oLiberacao:cLojaDe 		:= ::aParRet[nTam++]
					::oLiberacao:cLojaAte 		:= ::aParRet[nTam++]

				Else

					::oLiberacao:cVencrAte		:= DTOS(dData)
					::oLiberacao:cNumAte       	:= 'ZZZZZZZZZ'
					::oLiberacao:cPrefAte      	:= 'ZZZ'
					::oLiberacao:cTipoAte      	:= 'ZZZ'
					::oLiberacao:cForneceAte	:= 'ZZZZZZ'
					::oLiberacao:cLojaAte 		:= 'ZZ'

				EndIf

				//If ::oLiberacao:lFinanceiro

				::cFinalizados	:= ::aParRet[nTam++]

				::oLiberacao:lFinalizados := ::cFinalizados $ "2|3"

				//EndIf

			EndIf

		EndIf

	EndIf

Return(lRet)

Method WorkFlow(lAprovado) Class TWLiberacaoFinanceiro

	Local cNum		:= If(::lFolderReceber, SE1->E1_NUM		, If(::lFolderPagar, SE2->E2_NUM		, ""))
	Local cPrefixo	:= If(::lFolderReceber, SE1->E1_PREFIXO	, If(::lFolderPagar, SE2->E2_PREFIXO	, ""))
	Local cParcela	:= If(::lFolderReceber, SE1->E1_PARCELA	, If(::lFolderPagar, SE2->E2_PARCELA	, ""))
	Local cTipo		:= If(::lFolderReceber, SE1->E1_TIPO	, If(::lFolderPagar, SE2->E2_TIPO		, ""))

	Local cCliFor	:= If(::lFolderReceber, SE1->E1_CLIENTE	, If(::lFolderPagar, SE2->E2_FORNECE	, ""))
	Local cLoja		:= If(::lFolderReceber, SE1->E1_LOJA	, If(::lFolderPagar, SE2->E2_LOJA		, ""))
	Local cNome		:= If(::lFolderReceber, SE1->E1_NOMCLI	, If(::lFolderPagar, SE2->E2_NOMFOR		, ""))
	Local nValor 	:= If(::lFolderReceber, SE1->E1_VALOR	, If(::lFolderPagar, SE2->E2_VALOR		, ""))
	Local nSaldo 	:= If(::lFolderReceber, SE1->E1_SALDO	, If(::lFolderPagar, SE2->E2_SALDO		, ""))
	Local cObs 		:= If(::lFolderReceber, SE1->E1_YOBSLIB	, If(::lFolderPagar, SE2->E2_YOBSLIB	, ""))
	Local cBlq 		:= If(::lFolderReceber, SE1->E1_YBLQ	, If(::lFolderPagar, SE2->E2_YBLQ		, ""))

	Local cTitulo 	:= "Titulo do " + If(::lFolderReceber, "Contas a Receber", If(::lFolderPagar, "Contas a Pagar", "")) + If(lAprovado, " Liberado", " Rejeitado")
	Local cDestino	:= ""
	Local cMensagem	:= ""
	Local oMail		:= TAFMail():New()

	Local cLinkImg	 := "https://biancogres.com.br/wp-content/uploads/2018/06/logo1-3-1.png"
	Local cNomeEmp	 := "Biancogres"
	Local cLinkSit 	 := "http://www.biancogres.com.br"

	If ::lFolderReceber

		If lAprovado

			cDestino	:= "nadine.araujo@biancogres.com.br;rylayne.eleuterio@biancogres.com.br"

		Else

			cDestino	:= "wellison.toras@biancogres.com.br;nadine.araujo@biancogres.com.br;rylayne.eleuterio@biancogres.com.br"

		EndIf

	ElseIf ::lFolderPagar

		If lAprovado

			cDestino	:= "alessa.gomes@biancogres.com.br"

		Else

			cDestino	:= "alessa.gomes@biancogres.com.br"

		EndIf

	EndIf

	cMensagem := cMensagem + '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:w="urn:schemas-microsoft-com:office:word"'
	cMensagem := cMensagem + 'xmlns="http://www.w3.org/TR/REC-html40">'
	cMensagem := cMensagem + '<head>'
	cMensagem := cMensagem + '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />'
	cMensagem := cMensagem + '	<title>' + "Titulo " + If(lAprovado, " Liberado", " Rejeitado") + " na " + IIF(cEmpAnt="01","Biancogres",IIF(cEmpAnt="05","Incesa",IIF(cEmpAnt="14","Vitcer","Biancogres"))) + SM0->M0_FILIAL + '</title>'
	cMensagem := cMensagem + '     <style type="text/css">'
	cMensagem := cMensagem + '<!--'
	cMensagem := cMensagem + '.style6 {font-size: 12px; font-weight: bold; }'
	cMensagem := cMensagem + '.style7 {font-size: 12px}'
	cMensagem := cMensagem + '-->'
	cMensagem := cMensagem + '        </style>'
	cMensagem := cMensagem + '</head>'
	cMensagem := cMensagem + '	<body>'
	cMensagem := cMensagem + '<div class="gs">'
	cMensagem := cMensagem + '<div class="gE iv gt"></div>'
	cMensagem := cMensagem + '<div class="utdU2e"></div><div class="tx78Ic"></div><div class="QqXVeb"></div><div id=":10g" tabindex="-1"></div><div id=":118" class="ii gt adP adO"><div id=":119"><u></u>'
	cMensagem := cMensagem + '	<div style="padding:0;margin:0;background:#eaeaea">'
	cMensagem := cMensagem + '		<table style="background:#eaeaea;font-family:Lucida grande,Sans-Serif;border-spacing:0" align="center" border="0" cellpadding="0" cellspacing="0" width="100%">'
	cMensagem := cMensagem + '			<tbody><tr>'
	cMensagem := cMensagem + '				<td style="padding:25px 0 55px" align="center">'
	cMensagem := cMensagem + '					<table style="padding:0 50px;text-align:left;border-spacing:0" align="center" border="0" cellpadding="0" cellspacing="0" width="800">'
	cMensagem := cMensagem + '		    <tbody><tr>'
	cMensagem := cMensagem + '							<td style="padding-bottom:10px">'
	cMensagem := cMensagem + '								<img src="'+cLinkImg+'">							</td>'
	cMensagem := cMensagem + '						</tr>'
	cMensagem := cMensagem + '						<tr>'
	cMensagem := cMensagem + '							<td height="400" style="font-size:13px;color:#888;padding:30px 40px;border:1px solid #b8b8b8;background-color:#fff">'
	cMensagem := cMensagem + '								<p style="color:black;margin:0">Voc� acaba de receber um informativo da '+Capital(SM0->M0_FILIAL)+'.</p>'
	cMensagem := cMensagem + '				  			<div style="background-color:#e3e3e3;padding:20px;color:black;margin:30px 0">'
	cMensagem := cMensagem + '									<span style="font-weight:bold;font-size:14px;margin:0">' + "Titulo " + If(lAprovado, " Liberado", " Rejeitado") + " na " + IIF(cEmpAnt="01","Biancogres",IIF(cEmpAnt="05","Incesa",IIF(cEmpAnt="14","Vitcer","Biancogres"))) + '</span>'
	cMensagem := cMensagem + '			                        <hr style="margin:15px 0">'
	cMensagem := cMensagem + '									<p style="margin:0"></p>'

	cMensagem := cMensagem + '									<table width="674" border="0">'

	cMensagem := cMensagem + '                                      <tr>'
	cMensagem := cMensagem + '                                        <td width="117"><span class="style6">N�mero do Titulo</span></td>'
	cMensagem := cMensagem + '                                       <td width="547"><span class="style4 style7">'+cNum+'</span></td>'
	cMensagem := cMensagem + '                                      </tr>'

	cMensagem := cMensagem + '                                      <tr>'
	cMensagem := cMensagem + '                                        <td width="117"><span class="style6">Prefixo</span></td>'
	cMensagem := cMensagem + '                                       <td width="547"><span class="style4 style7">'+cPrefixo+'</span></td>'
	cMensagem := cMensagem + '                                      </tr>'

	cMensagem := cMensagem + '                                      <tr>'
	cMensagem := cMensagem + '                                        <td width="117"><span class="style6">Parcela</span></td>'
	cMensagem := cMensagem + '                                       <td width="547"><span class="style4 style7">'+cParcela+'</span></td>'
	cMensagem := cMensagem + '                                      </tr>'

	cMensagem := cMensagem + '                                      <tr>'
	cMensagem := cMensagem + '                                        <td width="117"><span class="style6">Tipo</span></td>'
	cMensagem := cMensagem + '                                       <td width="547"><span class="style4 style7">'+cTipo+'</span></td>'
	cMensagem := cMensagem + '                                      </tr>'

	cMensagem := cMensagem + '                                      <tr>'
	cMensagem := cMensagem + '                                        <td><span class="style6">' + If(::lFolderReceber, "Cliente", If(::lFolderPagar, "Fornecedor", "")) + '</span></td>'
	cMensagem := cMensagem + '                                        <td><span class="style4 style7">'+cCliFor+"-"+cLoja +"-"+cNome+'</span></td>'
	cMensagem := cMensagem + '                                      </tr>'

	cMensagem := cMensagem + '                                      <tr>'
	cMensagem := cMensagem + '                                        <td><span class="style6">Valor do Titulo</span></td>'
	cMensagem := cMensagem + '                                        <td><span class="style4 style7">' + 'R$ ' + Transform(nValor, "@E 999,999,999.99") + '</span></td>'
	cMensagem := cMensagem + '                                      </tr>'

	cMensagem := cMensagem + '                                      <tr>'
	cMensagem := cMensagem + '                                        <td><span class="style6">Saldo do Titulo</span></td>'
	cMensagem := cMensagem + '                                        <td><span class="style4 style7"> R$ ' + Transform(nSaldo, "@E 999,999,999.99") + '</span></td>'
	cMensagem := cMensagem + '                                      </tr>'

	If ZL0->ZL0_DESCON > 0 .And. ::lFolderReceber

		cMensagem := cMensagem + '                                      <tr>'
		cMensagem := cMensagem + '                                        <td><span class="style6">Desconto solicitado</span></td>'
		cMensagem := cMensagem + '                                        <td><span class="style4 style7">' + 'R$ ' + Transform(ZL0->ZL0_DESCON, "@E 999,999,999.99") + '</span></td>'
		cMensagem := cMensagem + '                                      </tr>'

	EndIf

	If SE1->E1_VENCTO <> ZL0->ZL0_VENCTO .And. ::lFolderReceber

		cMensagem := cMensagem + '                                      <tr>'
		cMensagem := cMensagem + '                                        <td><span class="style6">Vencimento Real</span></td>'
		cMensagem := cMensagem + '                                        <td><span class="style4 style7">' + DTOC(SE1->E1_VENCTO) + '</span></td>'
		cMensagem := cMensagem + '                                      </tr>'

		cMensagem := cMensagem + '                                      <tr>'
		cMensagem := cMensagem + '                                        <td><span class="style6">Vencimento solicitado</span></td>'
		cMensagem := cMensagem + '                                        <td><span class="style4 style7">' + DTOC(ZL0->ZL0_VENCTO) + '</span></td>'
		cMensagem := cMensagem + '                                      </tr>'

	EndIf

	If ! Empty(cObs)

		cMensagem := cMensagem + '                                      <tr>'
		cMensagem := cMensagem + '                                        <td><span class="style6">Observa��o</span></td>'
		cMensagem := cMensagem + '                                        <td><span class="style4 style7">' + AllTrim(cObs) + '</span></td>'
		cMensagem := cMensagem + '                                      </tr>'

	EndIf

	If ::lFolderReceber .And. lAprovado

		cMensagem := cMensagem + '                                      <tr>'
		cMensagem := cMensagem + '                                        <td><span class="style6">C�digo de Autoriza��o</span></td>'
		cMensagem := cMensagem + '                                        <td><span class="style4 style7">' + AllTrim(cBlq) + '</span></td>'
		cMensagem := cMensagem + '                                      </tr>'

	EndIf

	cMensagem := cMensagem + '                                    </table>'
	cMensagem := cMensagem + '                                    <br>'

	cMensagem := cMensagem + '					          </div>'
	cMensagem := cMensagem + '						  <p>Esta notifica��o foi enviada por um email configurado para n�o receber resposta.<br>'
	cMensagem := cMensagem + '									Por favor, n�o responda esta mensagem.							  </p>'
	cMensagem := cMensagem + '						  </td>'
	cMensagem := cMensagem + '						</tr>'
	cMensagem := cMensagem + '					</tbody></table>'

	cMensagem := cMensagem + '	    <p align="center" style="width:640px;padding:10px 20px;font-size:10px;color:#888;line-height:14px">'
	cMensagem := cMensagem + '						Para acessar o site da '+cNomeEmp+','
	cMensagem := cMensagem + '						<a href="'+cLinkSit+'" style="color:#666;text-decoration:underline" target="_blank">clique aqui.</a>					</p>'
	cMensagem := cMensagem + '			  </td>'
	cMensagem := cMensagem + '			</tr>'
	cMensagem := cMensagem + '		</tbody></table><div class="yj6qo"></div><div class="adL">'
	cMensagem := cMensagem + '	</div></div><div class="adL">'
	cMensagem := cMensagem + '</div></div></div><div id=":104" class="ii gt" style="display:none"><div id=":103"></div></div><div class="hi"></div></div>'
	cMensagem := cMensagem + '		</body>'
	cMensagem := cMensagem + '	</html>'

	oMail:cTo 		:= cDestino
	oMail:cSubject	:= cTitulo
	oMail:cBody		:= cMensagem

	oMail:Send()

Return()

Method DetalheTitulo() Class TWLiberacaoFinanceiro

	Local oGrid		 := If(::lFolderReceber, @::oGridRec	, If(::lFolderPagar, @::oGridPag		, Nil))
	Local aArea		 := If(::lFolderReceber, SE1->(GetArea()), If(::lFolderPagar, SE2->(GetArea())	, Nil))
	Local cAprovador := ""
	Local cListAprov := ""
	Local cCcClaVL	 := ""
	Local nPos		 := 0
	Local aUser		 := {}
	Local aUserAux	 := {}
	Local nW		 := 0
	Local nTamCC	 := 0
	Local nPosPref	:= aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_PREFIX"})
	Local nPosNum	:= aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_NUM"})
	Local nPosParc	:= aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_PARCEL"})
	Local nPosTipo	:= aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_TIPO"})
	Local nPosCliF	:= aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_CLIFOR"})
	Local nPosLoja	:= aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_LOJA"})
	Local nPosClDb  := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_CLVLDB"})
	Local nPosCCD 	:= aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_CCD"})

	If ::lFolderReceber

		DBSelectArea("SE1")
		SE1->(DBSetOrder(2)) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_

		If SE1->(DBSeek(xFilial("SE1") + oGrid:aCols[oGrid:oBrowse:nAT][nPosCliF] + oGrid:aCols[oGrid:oBrowse:nAT][nPosLoja] + oGrid:aCols[oGrid:oBrowse:nAT][nPosPref] + oGrid:aCols[oGrid:oBrowse:nAT][nPosNum] + oGrid:aCols[oGrid:oBrowse:nAT][nPosParc] + oGrid:aCols[oGrid:oBrowse:nAT][nPosTipo]))

			For nW := 1 To Len(::aAprovador)

				nTamCC := Len(SubStr(::aAprovador[nW], 8)) - 2

				cAprovador := SubStr(::aAprovador[nW], 2, 6)

				If nTamCC > 0

					cCcClaVL := SubStr(oGrid:aCols[oGrid:oBrowse:nAT][nPosCCD], 1, nTamCC) + SubStr(oGrid:aCols[oGrid:oBrowse:nAT][nPosClDb], 1, 1)

					If SubStr(::aAprovador[nW], 8, nTamCC) + SubStr(::aAprovador[nW], Len(::aAprovador[nW]), 1) == cCcClaVL

						aUser := FWSFALLUSERS({cAprovador})

						nPos := aScan(aUserAux, {|x| x == cAprovador})

						If nPos == 0

							aAdd(aUserAux, cAprovador)

						EndIf

						If Len(aUser) > 0 .And. nPos == 0

							If ! FWIsAdmin(cAprovador) .Or. FWIsAdmin(__cUserID)

								cListAprov += cAprovador + " - " + aUser[1][4] + CRLF

							EndIf

						ElseIf Len(aUser) == 0

							If FWIsAdmin(__cUserID)

								cListAprov += cAprovador + " - n�o encontrado." + CRLF

							EndIf

						EndIf

					EndIf

				EndIf

			Next nW

			If ! Empty(cCcClaVL)

				If Empty(cListAprov)

					MsgInfo("N�o foram encontrados aprovadores para o centro de custo " + AllTrim(oGrid:aCols[oGrid:oBrowse:nAT][nPosCCD]) + " e classe de valor " + AllTrim(oGrid:aCols[oGrid:oBrowse:nAT][nPosClDb]) + ". Verifique o parametro MV_YLBAP.")

				Else

					MsgInfo("Lista de aprovadores: " + CRLF + CRLF + cListAprov)

				EndIf

			EndIf

			AxVisual("SE1", SE1->(RecNo()), 4,,,,,/*cTudOk*/,,,,,,.T.)

		EndIf

	ElseIf ::lFolderPagar

		DBSelectArea("SE2")
		SE2->(DBSetOrder(6)) // E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, R_E_C_N_O_, D_E_L_E_T_

		If SE2->(DBSeek(xFilial("SE2") + oGrid:aCols[oGrid:oBrowse:nAT][nPosCliF] + oGrid:aCols[oGrid:oBrowse:nAT][nPosLoja] + oGrid:aCols[oGrid:oBrowse:nAT][nPosPref] + oGrid:aCols[oGrid:oBrowse:nAT][nPosNum] + oGrid:aCols[oGrid:oBrowse:nAT][nPosParc] + oGrid:aCols[oGrid:oBrowse:nAT][nPosTipo]))

			AxVisual("SE2", SE2->(RecNo()), 4,,,,,/*cTudOk*/,,,,,,.T.)

		EndIf

	EndIf

	RestArea(aArea)

Return()

Method TrackerContabil() Class TWLiberacaoFinanceiro

	Local oGrid		:= If(::lFolderReceber, @::oGridRec		, If(::lFolderPagar, @::oGridPag		, Nil))
	Local aArea		:= If(::lFolderReceber, SE1->(GetArea()), If(::lFolderPagar, SE2->(GetArea())	, Nil))

	Local nPosPref	:= aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_PREFIX"})
	Local nPosNum	:= aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_NUM"})
	Local nPosParc	:= aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_PARCEL"})
	Local nPosTipo	:= aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_TIPO"})
	Local nPosCliF	:= aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_CLIFOR"})
	Local nPosLoja	:= aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_LOJA"})

	If ::lFolderReceber

		DBSelectArea("SE1")
		SE1->(DBSetOrder(2)) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_

		If SE1->(DBSeek(xFilial("SE1") + oGrid:aCols[oGrid:oBrowse:nAT][nPosCliF] + oGrid:aCols[oGrid:oBrowse:nAT][nPosLoja] + oGrid:aCols[oGrid:oBrowse:nAT][nPosPref] + oGrid:aCols[oGrid:oBrowse:nAT][nPosNum] + oGrid:aCols[oGrid:oBrowse:nAT][nPosParc] + oGrid:aCols[oGrid:oBrowse:nAT][nPosTipo]))

			CTBC662("SE1", SE1->(Recno()))

		EndIf

	ElseIf ::lFolderPagar

		DBSelectArea("SE2")
		SE2->(DBSetOrder(6)) // E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, R_E_C_N_O_, D_E_L_E_T_

		If SE2->(DBSeek(xFilial("SE2") + oGrid:aCols[oGrid:oBrowse:nAT][nPosCliF] + oGrid:aCols[oGrid:oBrowse:nAT][nPosLoja] + oGrid:aCols[oGrid:oBrowse:nAT][nPosPref] + oGrid:aCols[oGrid:oBrowse:nAT][nPosNum] + oGrid:aCols[oGrid:oBrowse:nAT][nPosParc] + oGrid:aCols[oGrid:oBrowse:nAT][nPosTipo]))

			CTBC662("SE2", SE2->(Recno()))

		EndIf

	EndIf

	RestArea(aArea)

Return()




// Filipe - Facile - 30/09/2021 | Ticket: 26221
Static FUNCTION CkDescFin()

	Local cCODEMP := ZL0->ZL0_CODEMP
	Local cCODFIL := ZL0->ZL0_CODFIL
	Local cCLIFOR := ZL0->ZL0_CLIFOR
	Local cLOJA   := ZL0->ZL0_LOJA
	Local cCLVLDB := ZL0->ZL0_CLVLDB
	Local cCCONTA := ZL0->ZL0_DEBITO
	Local cNUM    := ZL0->ZL0_NUM
	Local cPREFIX := ZL0->ZL0_PREFIX
	Local cTIPO   := ZL0->ZL0_TIPO
	Local cPARCEL := ZL0->ZL0_PARCEL
	Local nVALOR  := ZL0->ZL0_VALOR
	Local nDESCON := ZL0->ZL0_DESCON
	Local cEMISSA := ZL0->ZL0_EMISSA
	Local cVENCTO := ZL0->ZL0_VENCTO
	Local cObsLib := ZL0->ZL0_OBSLIB

	Local nRecno  := ZL0->(RecNo())

	Local cEmail    := ""
	Local cAprov    := ""
	Local cQry      := GetNextAlias()
	Local cQry2     := GetNextAlias()
	Local cSQL      := ""
	Local cChave    := ""
	Local lRetErr   := .F.
	Local oApProcss := Nil
	Local cHtml := ""
	Local cEFrom := ""



	cSQL := " select ZDK.* "+  CRLF
	cSQL += " from "+RetSQLName("ZDK")+"  ZDK " + CRLF
	cSQL += " where LTRIM(RTRIM(ZDK.ZDK_CLVLR)) = " + ValToSQL(AllTrim(cCLVLDB))  + CRLF
	cSQL += " AND LTRIM(RTRIM(ZDK.ZDK_CCONTA))  = " + ValToSQL(AllTrim(cCCONTA))  + CRLF
	cSQL += " AND   "+cValTochar(nDESCON)+"  BETWEEN  ZDK.ZDK_VLAPIN AND ZDK.ZDK_VLAPFI  "+  CRLF
	cSQL += " AND   ZDK.ZDK_STATUS =  'A' " + CRLF
	cSQL += " AND   ZDK.D_E_L_E_T_ =  '' " + CRLF
	cSQL += " ORDER BY ZDK.ZDK_VLAPIN, ZDK.ZDK_VLAPFI "+  CRLF

	TcQuery cSQL New Alias (cQry)

	If (cQry)->(!Eof()) .and. nDESCON > 0


		//Regra 1 - AT� 8000 DE desconte
		If nDESCON <= 8000 .AND. !EMPTY(AllTrim(cCCONTA))

			cEmail := UsrRetMail(AllTrim((cQry)->ZDK_APROVA)) //MANDA PARA O GESTOR PRINCIPAL
			cAprov := (cQry)->ZDK_APROVA


			If !EMPTY((cQry)->ZDK_APROVT) .AND. !EMPTY((cQry)->ZDK_DTAPTI) .AND. !EMPTY((cQry)->ZDK_VLAPFI)

				IF (cQry)->ZDK_VLAPFI >= dDataBase

					cEmail    := UsrRetMail(AllTrim((cQry)->ZDK_APROVT)) //MANDA PARA O APROVADOR TEMPORARIO
					cAprov := (cQry)->ZDK_APROVT

				EndIf

			EndIf


			//Regra 2 - acima de 8000.01 e classe de valor come�ando com 2
		ElseIf nDESCON >= 8000.01 .AND. SUBSTR(AllTrim((cQry)->ZDK_CLVLR), 0, 1) == "2" .AND. !EMPTY(AllTrim(cCCONTA))

			cEmail := UsrRetMail(AllTrim((cQry)->ZDK_APROVA)) //MANDA PARA O GESTOR PRINCIPAL
			cAprov := (cQry)->ZDK_APROVA

			If !EMPTY((cQry)->ZDK_APROVT) .AND. !EMPTY((cQry)->ZDK_DTAPTI) .AND. !EMPTY((cQry)->ZDK_VLAPFI)

				IF (cQry)->ZDK_VLAPFI >= dDataBase

					cEmail    := UsrRetMail(AllTrim((cQry)->ZDK_APROVT)) //MANDA PARA O APROVADOR TEMPORARIO
					cAprov := (cQry)->ZDK_APROVT

				EndIf

			EndIf


			//Regra 3 - acima de 8000.01 e classe de valor come�ando com 3
		ElseIf nDESCON >= 8000.01 .AND. SUBSTR(AllTrim((cQry)->ZDK_CLVLR), 0, 1) == "3" .AND. !EMPTY(AllTrim(cCCONTA))

			cEmail := UsrRetMail(AllTrim((cQry)->ZDK_APROVA)) //MANDA PARA O GESTOR PRINCIPAL
			cAprov := (cQry)->ZDK_APROVA

			If !EMPTY((cQry)->ZDK_APROVT) .AND. !EMPTY((cQry)->ZDK_DTAPTI) .AND. !EMPTY((cQry)->ZDK_VLAPFI)

				IF (cQry)->ZDK_VLAPFI >= dDataBase


					cEmail    := UsrRetMail(AllTrim((cQry)->ZDK_APROVT)) //MANDA PARA O APROVADOR TEMPORARIO
					cAprov := (cQry)->ZDK_APROVT

				EndIf

			EndIf

			//Regra 4 - INDEPENDETE DO VALOR, POREM SEM CONTA CONTABIL
		ELSE

			cEmail := UsrRetMail(AllTrim((cQry)->ZDK_APROVA)) //MANDA PARA O GESTOR PRINCIPAL
			cAprov := (cQry)->ZDK_APROVA

			If !EMPTY((cQry)->ZDK_APROVT) .AND. !EMPTY((cQry)->ZDK_DTAPTI) .AND. !EMPTY((cQry)->ZDK_VLAPFI)

				IF (cQry)->ZDK_VLAPFI >= dDataBase

					cEmail    := UsrRetMail(AllTrim((cQry)->ZDK_APROVT)) //MANDA PARA O APROVADOR TEMPORARIO
					cAprov := (cQry)->ZDK_APROVT

				EndIf

			EndIf

		EndIf

		(cQry)->(DbSkip())



		(cQry)->(DbCloseArea())
		//Fim das regras


		If !EMPTY(cEmail)

			cSQL := " SELECT * FROM ZKH010   "+  CRLF
			cSQL += " WHERE ZKH_ID =  "+cValToChar(nRecno)+" "+  CRLF
			cSQL += " AND ZKH_EMP  = '"+cCODEMP+"' "+  CRLF
			cSQL += " AND ZKH_FIL  = '"+cCODFIL+"' "+  CRLF
			cSQL += " AND ZKH_PROCES  = 'FIN00001' "+  CRLF //Libera��o de descontos do financeiro
			cSQL += " AND D_E_L_E_T_ = ''  "+  CRLF

			TcQuery cSQL New Alias (cQry2)

			if EMPTY( (cQry2)->ZKH_CHAVE )

      /*Tratar email para aprovar diversos processos bianco*/

				oApProcss := TAprovaProcessoPorEmail():New()
				cEFrom := oApProcss:oMensagem:cFrom

				cChave := Upper(HMAC(cCODEMP + cCODFIL + cNUM, "Bi@nCoGrEs", 1))

				cHtml := " <html> "
				cHtml += "    <body style='font-family: Courier, Arial, Helvetica, sans-serif;'> "
				cHtml += "       <div style='margin:0;padding:0;background-color:#fff;height:100%; '> "
				cHtml += "          <table align='center' border='0' cellpadding='0' cellspacing='0' style='overflow-x:hidden;margin:0px 20px 0px 20px;border:1px solid #ebebeb'> "
				cHtml += "             <tbody> "
				cHtml += "                <tr> "
				cHtml += "                   <td align='center' bgcolor='#919191'  style='font-size:20px; color:#ffffff; font-family: Courier, Arial, Helvetica, sans-serif;'> "
				cHtml += "                      <h1 style='margin:0px; padding:5px; letter-spacing:15px;'>BIANCOGRES</h1> "
				cHtml += " 					 <h4 style='margin:0px; padding:5px;'>Libera��o de descontos</h4> "
				cHtml += "                   </td> "
				cHtml += "                </tr> "
				cHtml += "                <tr> "
				cHtml += "                   <td align='left' bgcolor='#ffffff' style='padding:30px 30px 30px 30px;font-family: Courier, Arial, Helvetica, sans-serif;'>  "
				cHtml += " 				  Ol�, <b>"+cEmail+"!</b> <br> 	 "
				cHtml += " 				  O titulo abaixo est� pendende de libera��o. "
				cHtml += " 				  </td> "
				cHtml += "                </tr>		 "
				cHtml += " 			    <tr> "
				cHtml += "                   <td align='left' bgcolor='#fff' style='padding:3px;'> "
				cHtml += "                      <table align='center' style='width:100%; border-collapse: collapse;  border: 1px solid #e5e5e5;'> "
				cHtml += "                         <tbody> "
				cHtml += "                            <tr> "



				cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Cliente/Loja</th> "
				cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Nome</th> "
				cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Titulo/Prefixo/Tipo</th> "
				cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Parcela</th> "
				cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Vencimento</th> "
				cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Valor</th> "
				cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Desconto</th> "
				cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Cl. Valor</th> "
				cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>C. Contabil</th> "
				cHtml += "                               <th bgcolor='#919191'   style='padding:5px; border: 1px solid #e5e5e5;color:#fff;'>Obs</th> "
				cHtml += "                            </tr> "
				cHtml += " 						    <tr> "

				cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+cCLIFOR+"/"+cLOJA+"</td> "
				cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+Alltrim(Posicione("SA1", 1, xFilial("SA1") + cCLIFOR + cLOJA, "A1_NOME"))+"</td> "
				cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+cNUM+"/"+cPREFIX+" "+cTIPO+"</td> "
				cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+cPARCEL+"</td> "
				cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+dtoc(cVENCTO)+"</td> "
				cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+TRANSFORM(nVALOR,PesqPict("ZL0","ZL0_VALOR"))+"</td> "
				cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+TRANSFORM(nDESCON,PesqPict("ZL0","ZL0_DESCON"))+"</td> "
				cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+cCLVLDB+"</td> "
				cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+cCCONTA+"</td> "
				cHtml += "                               <td bgcolor='#ffffff' align='center' style='border: 1px solid #e5e5e5; padding:10px;'>"+cObsLib+"</td> "

				cHtml += "                            </tr> "
				cHtml += " 						  </tbody> "
				cHtml += " 						</table> "
				cHtml += " 					</td> "
				cHtml += " 				</tr>		 "
				cHtml += " 			    <tr> "
				cHtml += "                 <td align='center' bgcolor='#ffffff' style='padding:20px;font-family: Courier, Arial, Helvetica, sans-serif;'> 				 						 "
				cHtml += "          <br><br>"




				cHtml += " 					 <a  href='mailto:"+cEFrom+"?subject=Aprovar desconto:"+cNUM+" - PROC:FIN00001 - ACTION:APROVAR - KEY:"+ cChave +"' style='letter-spacing: 30px; text-decoration:none; width:500px; color: #34a853;; MARGIN:0px;  font-weight: bold; text-align: center; cursor: pointer; display: inline-block; padding: 30px; border:10px solid #34a853; font-size:20px;'>  "
				cHtml += "               APROVAR  "
				cHtml += "            </a> "

				cHtml += "          <br><br><br><br>  "


				cHtml += " 				 	 <a  href='mailto:"+cEFrom+"?subject=Recusar desconto:"+cNUM+" - PROC:FIN00001 - ACTION:RECUSAR - KEY:"+ cChave +"' style='letter-spacing: 30px;   text-decoration:none; width:500px; color: #e94235; MARGIN:0px;   font-weight: bold; text-align: center; cursor: pointer; display: inline-block; padding: 30px; border:10px solid #e94235; font-size:20px;'> "
				cHtml += "                 RECUSAR    "
				cHtml += "           </a> "

				cHtml += "          <br><br>"
				cHtml += " 				  </td> "
				cHtml += "              </tr>	 "
				cHtml += "              <tr> "
				cHtml += "                 <td align='center' bgcolor='#FAFAFA' style='padding:30px 30px 30px 30px;'> "
				cHtml += "                      <p style='padding:0px;color:#333f4c;margin:0;font-size:11px;line-height:22px'>                         Esta notifica��o foi enviada por um email configurado para n�o receber resposta. 						Por favor, n�o responda esta mensagem.                       </p> "
				cHtml += "                   </td> "
				cHtml += "              </tr>		 "
				cHtml += "             </tbody> "
				cHtml += "          </table> "
				cHtml += "       </div> "
				cHtml += "    </body> "
				cHtml += " </html> "




				cEmail := "filipe.bittencourt@facilesistemas.com.br;gardenia.stelzer@biancogres.com.br;nadine.araujo@biancogres.com.br"
				//cEmail := "filipe.bittencourt@facilesistemas.com.br"
				oApProcss:oMensagem:cTo 		  := cEmail
				oApProcss:oMensagem:cCc 		  := ""
				oApProcss:oMensagem:cBcc 	  	:= ""
				oApProcss:oMensagem:cSubject	:= "Libera��o de Desconto - "+FWEmpName(cCODEMP)+ ""
				oApProcss:oMensagem:cBody     := cHtml

				oApProcss  := oApProcss:EnviarEmail()

				lRetErr := oApProcss:lError

				If	lRetErr == .F.

					RecLock("ZKH", .T.)
					ZKH->ZKH_FILIAL		:= xFilial("ZKH")
					ZKH->ZKH_EMP 		  := cCODEMP
					ZKH->ZKH_FIL 		  := cCODFIL
					ZKH->ZKH_TABELA		:= "ZL0010"
					ZKH->ZKH_PROCES		:= "FIN00001" //Libera��o de descontos
					ZKH->ZKH_APROV 		:= cAprov
					ZKH->ZKH_EMAIL 		:= cEmail
					ZKH->ZKH_CHAVE 		:= cChave
					ZKH->ZKH_DATAEN 	:= dDataBase
					ZKH->ZKH_STATUS 	:= "E"
					ZKH->ZKH_ID		 	  := cValToChar(nRecno)
					ZKH->(MsUnlock())



				EndIf

			EndIf

		EndIf

	EndIf

	//CONOUT("TAprovaProcessoPorEmail:EnviarEmail() => ERRO ao enviar e-mail: " + oApProcss:cError )

Return lRetErr
// FIM  - Filipe - Facile - 30/09/2021 | Ticket: 26221



// Emerson (Facile) em 27/08/2021 - Tela Rateio RPV (BIAFG106)
Method RateioRPV() Class TWLiberacaoFinanceiro

	Local oGrid		 := If(::lFolderReceber, @::oGridRec	, If(::lFolderPagar, @::oGridPag		, Nil))
	Local aArea		 := If(::lFolderReceber, SE1->(GetArea()), If(::lFolderPagar, SE2->(GetArea())	, Nil))
	Local nPosPref	 := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_PREFIX"})
	Local nPosNum	 := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_NUM"})
	Local nPosParc	 := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_PARCEL"})
	Local nPosTipo	 := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_TIPO"})
	Local nPosCliF	 := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_CLIFOR"})
	Local nPosLoja	 := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_LOJA"})
	Local nPosObs  	 := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_OBSLIB"})
	Local nPosDesc	 := aScan(oGrid:aHeader, {|x| AllTrim(x[2]) == "ZL0_DESCON"})	
	Local aNumRPV    := {}
	Local cNumRPV	 := ""
	Local x			 := 0

	If ::lFolderReceber

		If oGrid:aCols[oGrid:oBrowse:nAT, nP_LEGENDA] == "BR_VERDE"

			DBSelectArea("SE1")
			SE1->(DBSetOrder(2)) // E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_

			If SE1->(DBSeek(xFilial("SE1") + oGrid:aCols[oGrid:oBrowse:nAT][nPosCliF] + oGrid:aCols[oGrid:oBrowse:nAT][nPosLoja] + oGrid:aCols[oGrid:oBrowse:nAT][nPosPref] + oGrid:aCols[oGrid:oBrowse:nAT][nPosNum] + oGrid:aCols[oGrid:oBrowse:nAT][nPosParc] + oGrid:aCols[oGrid:oBrowse:nAT][nPosTipo]))

				U_BIAFG106("3", oGrid:aCols[oGrid:oBrowse:nAT][nPosDesc]) //desconto

				// Atualiza campo de Obs.Lib com os RPV�s que foram selecionados para rateio - Retorno do array [1]-Cod.RPV / [2]-Percentual Rat / [3]-Valor Rateado
				aNumRPV := U_FGT106EB("3", SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
				For x:=1 to Len(aNumRPV)
					cNumRPV += aNumRPV[x][1]+IIF(x < Len(aNumRPV), "/", "")
				Next
				oGrid:aCols[oGrid:oBrowse:nAT, nPosObs] := "REFERENTE A " + cNumRPV

			Else
				MsgAlert("Aten��o, t�tulo n�o encontrado no financeiro.")
			Endif

		Else
			MsgAlert("Aten��o, Rateio RPV somente � permitido para t�tulos que ainda n�o foram enviados para Aprova��o.")
		Endif

	ElseIf ::lFolderPagar

		MsgInfo("Rotina de Rateio RPV, dispon�vel somente para t�tulos a receber.")

	Endif

	RestArea(aArea)

Return()



