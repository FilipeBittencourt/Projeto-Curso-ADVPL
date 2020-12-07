#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWImportLancContabil
@author Wlysses Cerqueira (Facile)
@since 02/07/2019
@project Automação Financeira
@version 1.0
@description 
@type class
/*/

#DEFINE TIT_WND "Importação Lançamento contábil"

Class TWImportLancContabil From LongClassName

Data oArquivo
Data aArquivo

Data cCaminho
Data cName
Data aParam
Data aParRet
Data bConfirm
Data lConfirm

Data oWindow // Janela principal - FWDialogModal
Data oContainer	// Divisor de janelas - FWFormContainer
Data cHeaderBox // Identificador do cabecalho da janela
Data cItemBox // Identificador dos itens da janela

Data oPanel

Data aCols
Data aHeader
Data aEdit

Data oGridImp
Data oGridImpField

Method New() ConStructor
Method Processa()
Method LoadInterface()
Method LoadWindow()
Method LoadContainer()
Method LoadBrowser(lReLoad)
Method ExecAuto(nOpc_, dData_, cLote_, cSubLote_, cDoc_, aItemGrid)
Method ShowLancamento()
Method Activate()

Method GDFieldData(lReLoad)
Method GDEdiTableField()
Method GDFieldProperty()
Method Valid()
Method Confirm()
Method Pergunte()
Method GdSeek()
Method Load(lReLoad)
Method OrdenarGrid(nCol, oGrid)

EndClass

Method New() Class TWImportLancContabil

	::cName := "TWImportLancContabil"
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.
	::cCaminho := "C:\"

	::oArquivo := TBiaArquivo():New()

	::oWindow := Nil
	::oPanel := Nil
	::oContainer := Nil
	::cHeaderBox := ""
	::cItemBox := ""

	::aCols	:= {}
	::aHeader	:= {}
	::aEdit	:= {}
	::oGridImp := Nil
	::oGridImpField := TGDField():New()

Return()

Method Pergunte() Class TWImportLancContabil

	Local lRet := .F.
	Local nTam := 1

	::bConfirm := {|| .T. }

	::aParam := {}

	::aParRet := {}

	aAdd(::aParam, {6, "Arquivo a importar" , ::cCaminho, "@!", ".T.", ".T.", 75, .T., "Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE})

	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)

		lRet := .T.

		::cCaminho := ::aParRet[nTam++]

	EndIf

Return(lRet)

Method LoadInterface() Class TWImportLancContabil

	::LoadWindow()

	::LoadContainer()

	::LoadBrowser()

Return()

Method LoadWindow() Class TWImportLancContabil

	Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()

	::oWindow:SetBackground(.T.)
	::oWindow:SetTitle(TIT_WND)
	::oWindow:SetEscClose(.T.)
	::oWindow:SetSize(aCoors[4], aCoors[3])
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()

	::oWindow:AddOKButton({|| ::Confirm() })

	::oWindow:AddCloseButton()

	::oWindow:AddButton("Carregar", {|| ::Load(.T.) },,, .T., .F., .T.)

	::oWindow:AddButton("Pesquisar", {|| ::GdSeek() },,, .T., .F., .T.)

	::oWindow:AddButton("Exibir lançamento", {|| ::ShowLancamento() },,, .T., .F., .T.)

Return()

Method GdSeek() Class TWImportLancContabil

	GdSeek(::oGridImp,,,,.F.)

Return()

Method LoadContainer() Class TWImportLancContabil

	::oContainer := FWFormContainer():New()

	//::cHeaderBox := ::oContainer:CreateHorizontalBox(30)

	::cItemBox := ::oContainer:CreateHorizontalBox(100)

	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)

Return()

Method LoadBrowser(lReLoad) Class TWImportLancContabil

	Local cVldDef := "AllwayStrue"

	Default lReLoad := .F.

	::oPanel := ::oContainer:GetPanel(::cItemBox)

	If !lReLoad

		::Load(.F.)

	EndIf

	::GDEdiTableField()

	//::GDFieldProperty()

	::oGridImp := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", @::aEdit,,, cVldDef,, cVldDef, ::oPanel, @::aHeader, @::aCols)

	::oGridImp:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	//::oGridImp:oBrowse:bHeaderClick := {|oGrid, nCol| ::OrdenarGrid(nCol, @::oGridImp)} // Nao usar
	::oGridImp:oBrowse:lVScroll := .T.
	::oGridImp:oBrowse:lHScroll := .T.

	::oGridImp:oBrowse:Refresh()

	::oGridImp:Refresh()

Return()

Method OrdenarGrid(nCol, oGrid) Class TWImportLancContabil

	oGrid:aCols := aSort( oGrid:aCols,,,{|x,y| x[nCol] < y[nCol]} )

	oGrid:SetArray(oGrid:aCols, .F.)

	oGrid:oBrowse:Refresh()

	oGrid:Refresh()

Return()

Method Load(lReLoad) Class TWImportLancContabil

	Default lReLoad := .T.

	::Pergunte()

	If File(AllTrim(::cCaminho))

		Processa({|| ::GDFieldData(lReLoad) }, "Aguarde...", "Carregando Arquivo...", .F.)

	Else

		MsgStop("Caminho inválido!", "Geração de Lançamento")

	EndIf

Return()

Method GDFieldData(lReLoad) Class TWImportLancContabil

	Local msTmpINI	:= Time()
	Local msHrProc  := Time()
	Local msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))
	Local aWorksheet:= {}
	Local aCamposOrd:= {}
	Local nTotLin	:= 0
	Local nImport	:= 0
	Local nPosCampo	:= 0
	Local nW		:= 0
	Local nX		:= 0
	Local lRet		:= .F.

	Local cLote_	:= ""
	Local cSubLote_	:= ""
	Local cDoc_  	:= ""
	Local cLinha	:= ""

	Local nPosDC	:= 0
	Local nPosLote 	:= 0
	Local nPosSBLote:= 0
	Local nPosDoc	:= 0
	Local nPosLinha	:= 0

	::aArquivo := ::oArquivo:GetArquivo(::cCaminho)

	If Len(::aArquivo) > 0

		//msTpLin := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(::aArquivo[1]) ) )

		nTotLin := Len(aWorksheet)

		aWorksheet := ::aArquivo[1]

		ProcRegua(nTotLin)

		::oGridImpField:Clear()

		::aCols := {}

		::aHeader := {}

		For nW := 1 to len(aWorksheet)

			IncProc("Tmp Leit:(" + msTmpRead + ") Proc: " + StrZero(nW,6) + "/" + StrZero(nTotLin,6) )

			lRet := .F.

			For nX := 1 To Len(aWorksheet[nW])

				If ! Empty(aWorksheet[nW][nX])

					lRet := .T.

					Exit

				EndIf

			Next nX

			If !lRet

				Loop

			EndIf

			If nW == 1

				aCampos := aWorksheet[nW]

				DBSelectArea("SX3")
				SX3->(DBSetOrder(1)) // X3_ARQUIVO, X3_ORDEM, R_E_C_N_O_, D_E_L_E_T_

				If SX3->(DbSeek("CT2"))

					While SX3->X3_ARQUIVO == "CT2"

						If aScan(aCampos, {|x| AllTrim(x) == AllTrim(SX3->X3_CAMPO)}) > 0 .Or. AllTrim(SX3->X3_CAMPO) == "CT2_LINHA"

							aAdd(aCamposOrd, {SX3->X3_CAMPO, SX3->X3_TIPO})

							::oGridImpField:AddField(SX3->X3_CAMPO)

						EndIf

						SX3->(DBSkip())

					EndDo

				EndIf

			Else

				aLinha	:= aWorksheet[nW]

				aAdd(::aCols, Array(Len(aLinha) + 2)) // Linha deletada + CT2_LINHA

				nLinha := Len(::aCols)

				For nX := 1 To Len(aCampos)

					nPosCampo := aScan(aCamposOrd, {|x| AllTrim(x[1]) == aCampos[nX]})

					If nPosCampo > 0

						If aCamposOrd[nPosCampo][2] == "N"

							::aCols[nLinha, nPosCampo] := Val(Alltrim(aLinha[nX]))

						Else

							::aCols[nLinha][nPosCampo] := aLinha[nX]

						EndIf

					EndIf

				Next nX

				::aCols[nLinha][Len(aLinha) + 2] := .F.

				nImport++

			EndIf

		Next nW

		::aHeader := ::oGridImpField:GetHeader()

	EndIf

	nPosLote 	:= aScan(::aHeader, {|x| AllTrim(x[2]) == "CT2_LOTE"})
	nPosSBLote	:= aScan(::aHeader, {|x| AllTrim(x[2]) == "CT2_SBLOTE"})
	nPosDoc		:= aScan(::aHeader, {|x| AllTrim(x[2]) == "CT2_DOC"})
	nPosDC	 	:= aScan(::aHeader, {|x| AllTrim(x[2]) == "CT2_DC"})
	nPosLinha	:= aScan(::aHeader, {|x| AllTrim(x[2]) == "CT2_LINHA"})

	If nPosLote > 0 .And. nPosSBLote > 0 .And. nPosDoc > 0

		::aCols := aSort(::aCols,,,{|x, y| x[nPosLote] + x[nPosSBLote] + x[nPosDoc] + x[nPosDC] < y[nPosLote] + y[nPosSBLote] + y[nPosDoc] + y[nPosDC]})

		For nW := 1 To Len(::aCols)

			If cLote_ + cSubLote_ + cDoc_ <> ::aCols[nW][nPosLote] + ::aCols[nW][nPosSBLote] + ::aCols[nW][nPosDoc]

				cLote_		:= ::aCols[nW][nPosLote]
				cSubLote_	:= ::aCols[nW][nPosSBLote]
				cDoc_ 		:= ::aCols[nW][nPosDoc]

				cLinha		:= Soma1(StrZero(0, TamSx3("CT2_LINHA")[1]))

			Else

				cLinha		:= Soma1(cLinha)

			EndIf

			::aCols[nW][nPosLinha] := cLinha

		Next nW

	EndIf

	If lReLoad

		::LoadBrowser(lReLoad)

		::oGridImp:oBrowse:Refresh()

		::oGridImp:Refresh()		

	EndIf

Return()

Method Activate() Class TWImportLancContabil

	::LoadInterface()

	::oWindow:Activate()

Return()

Method GDEdiTableField() Class TWImportLancContabil

	Local aRet := {}

	aRet := {}

Return(aRet)


Method GDFieldProperty() Class TWImportLancContabil

	Local aRet := {}

	::oGridImpField:Clear()

	::oGridImpField:AddField("CT2_LOTE")
	::oGridImpField:AddField("CT2_SBLOTE")
	::oGridImpField:AddField("CT2_DOC")
	::oGridImpField:AddField("CT2_LINHA")

	::oGridImpField:AddField("CT2_DC")
	::oGridImpField:AddField("CT2_DEBITO")
	::oGridImpField:AddField("CT2_CREDIT")
	::oGridImpField:AddField("CT2_VALOR")
	::oGridImpField:AddField("CT2_CLVLDB")
	::oGridImpField:AddField("CT2_CLVLCR")
	::oGridImpField:AddField("CT2_CCD")
	::oGridImpField:AddField("CT2_CCC")
	::oGridImpField:AddField("CT2_ITEMD")
	::oGridImpField:AddField("CT2_ITEMC")
	::oGridImpField:AddField("CT2_ATIVDE")

	::oGridImpField:AddField("CT2_ORIGEM")
	::oGridImpField:AddField("CT2_HIST")

	//::oGridImpField:AddField("Space")	

	aRet := ::oGridImpField:GetHeader()

Return(aRet)

Method Valid() Class TWImportLancContabil

	Local lRet		:= .T.
	Local nW		:= 0
	Local nX		:= 0
	Local aCampObr	:= {"CT2_LOTE", "CT2_SBLOTE", "CT2_DOC"}

	DBSelectArea("SX3")
	SX3->(DBSetOrder(2)) // X3_CAMPO, R_E_C_N_O_, D_E_L_E_T_

	For nW := 1 To Len(::oGridImp:aCols)

		If !lRet

			Exit

		EndIf

		If !GDdeleted(nW, ::oGridImp:aHeader, ::oGridImp:aCols)

			For nX := 1 To Len(aCampObr)

				SX3->(DBSeek(aCampObr[nX]))

				nPos := aScan(::oGridImp:aHeader, {|x| AllTrim(x[2]) == aCampObr[nX]})

				If nPos > 0

					If Empty(::oGridImp:aCols[nW][nPos])

						MsgStop("Linha: " + AllTrim(cValToChar(nW)) + CRLF + CRLF + "Campo '" + AllTrim(::oGridImp:aHeader[nPosDoc][1]) + "' não preenchido!", "Geração de Lançamento")

						::oGridImp:GoTo(nW)

						::oGridImp:oBrowse:SetFocus()

						lRet := .F.

						Exit

					EndIf

				Else

					MsgStop("Campo '" + AllTrim(SX3->X3_TITULO) + "-" + AllTrim(SX3->X3_CAMPO) + "' não encontrado" + " !", "Geração de Lançamento")

					::oGridImp:GoTo(nW)

					::oGridImp:oBrowse:SetFocus()

					lRet := .F.

					Exit

				EndIf

			Next nX

		EndIf

	Next nW

	//lRet := oGrid:TudoOk()

Return(lRet)

Method Processa() Class TWImportLancContabil

	Local aAreaSE1	:= SE1->(GetArea())
	Local aAreaSE2	:= SE2->(GetArea())
	Local nW		:= 0
	Local aItem		:= {}
	Local aRet		:= {}
	Local lRet		:= .T.

	Local nPosLote 	:= aScan(::oGridImp:aHeader, {|x| AllTrim(x[2]) == "CT2_LOTE"})
	Local nPosSBLote:= aScan(::oGridImp:aHeader, {|x| AllTrim(x[2]) == "CT2_SBLOTE"})
	Local nPosDoc	:= aScan(::oGridImp:aHeader, {|x| AllTrim(x[2]) == "CT2_DOC"})

	Local cLote_		:= ""
	Local cSubLote_	:= ""
	Local cDoc_  	:= ""

	BEGIN TRANSACTION

		For nW := 1 To Len(::oGridImp:aCols)

			If !GDdeleted(nW, ::oGridImp:aHeader, ::oGridImp:aCols)

				If cLote_ + cSubLote_ + cDoc_ <> ::oGridImp:aCols[nW][nPosLote] + ::oGridImp:aCols[nW][nPosSBLote] + ::oGridImp:aCols[nW][nPosDoc]

					If Len(aItem) > 0

						aRet := ::ExecAuto(3, dDataBase, cLote_, cSubLote_, cDoc_, aItem)

						If aRet[1]

							DisarmTransaction()

							MsgStop("Lote: " + cLote_ + " Sub Lote: " + cSubLote_ + " Doc: " + cDoc_ + CRLF + CRLF + aRet[2], "Geração de Lançamento")

							aItem := {}

							lRet := .F.

							Exit

						EndIf

						aItem := {}

						aAdd(aItem, ::oGridImp:aCols[nW])

						cLote_		:= ::oGridImp:aCols[nW][nPosLote]

						cSubLote_	:= ::oGridImp:aCols[nW][nPosSBLote]

						cDoc_		:= ::oGridImp:aCols[nW][nPosDoc]

					Else

						aAdd(aItem, ::oGridImp:aCols[nW])

						cLote_		:= ::oGridImp:aCols[nW][nPosLote]

						cSubLote_	:= ::oGridImp:aCols[nW][nPosSBLote]

						cDoc_		:= ::oGridImp:aCols[nW][nPosDoc]

					EndIf

				Else

					aAdd(aItem, ::oGridImp:aCols[nW])

					cLote_		:= ::oGridImp:aCols[nW][nPosLote]

					cSubLote_	:= ::oGridImp:aCols[nW][nPosSBLote]

					cDoc_		:= ::oGridImp:aCols[nW][nPosDoc]

				EndIf

			EndIf

		Next nW

		If Len(aItem) > 0

			aRet := ::ExecAuto(3, dDataBase, cLote_, cSubLote_, cDoc_, aItem)

			If aRet[1]

				DisarmTransaction()

				MsgStop("Lote: " + cLote_ + " SubLote: " + cSubLote_ + " Doc: " + cDoc_ + CRLF + CRLF + aRet[2], "Geração de Lançamento")

				lRet := .F.

			EndIf

		EndIf

	END TRANSACTION

	If lRet

		MsgInfo("Importação do arquivo " + AllTrim(::cCaminho) + " concluída com sucesso!", "Importação planilha")

		::oGridImp:SetArray({}, .F.)

		::oGridImp:oBrowse:Refresh()

		::oGridImp:Refresh()

	EndIf

	RestArea(aAreaSE1)
	RestArea(aAreaSE2)

Return()

Method Confirm() Class TWImportLancContabil

	If ::Valid()

		If MsgYesNo("Confirma importação?")

			U_BIAMsgRun("Importando...", "Aguarde!", {|| ::Processa() })

		EndIf

	EndIf

Return()

Method ShowLancamento() Class TWImportLancContabil

	Local nPosLote 	:= aScan(::oGridImp:aHeader, {|x| AllTrim(x[2]) == "CT2_LOTE"})
	Local nPosSBLote:= aScan(::oGridImp:aHeader, {|x| AllTrim(x[2]) == "CT2_SBLOTE"})
	Local nPosDoc	:= aScan(::oGridImp:aHeader, {|x| AllTrim(x[2]) == "CT2_DOC"})

	Private dDataLanc 	:= ""
	Private cLote 		:= ""
	Private cSubLote 	:= ""
	Private cDoc 		:= ""

	DBSelectArea("CTC")
	CTC->(DBSetOrder(2)) // CTC_FILIAL, CTC_LOTE, CTC_SBLOTE, CTC_DOC, CTC_MOEDA, CTC_TPSALD, CTC_DATA, R_E_C_N_O_, D_E_L_E_T_

	If Len(::oGridImp:aCols) > 0

		If CTC->(DBSeek(xFilial("CTC") + ::oGridImp:aCols[::oGridImp:oBrowse:nAT][nPosLote] + ::oGridImp:aCols[::oGridImp:oBrowse:nAT][nPosSBLote] + ::oGridImp:aCols[::oGridImp:oBrowse:nAT][nPosDoc]))

			dDataLanc 	:= CTC->CTC_DATA
			cLote 		:= CTC->CTC_LOTE
			cSubLote 	:= CTC->CTC_SBLOTE
			cDoc 		:= CTC->CTC_DOC

			Ctba102Cal("CTC", CTC->(Recno()), 2)

		Else

			MsgInfo("Não encontrado lançamento para o Lote: " + ::oGridImp:aCols[::oGridImp:oBrowse:nAT][nPosLote] +;
			" Sub Lote: " + ::oGridImp:aCols[::oGridImp:oBrowse:nAT][nPosSBLote] +;
			" Doc: " + ::oGridImp:aCols[::oGridImp:oBrowse:nAT][nPosDoc], "Importação planilha")

		EndIf

	EndIf

Return()

Method ExecAuto(nOpc_, dData_, cLote_, cSubLote_, cDoc_, aItemGrid) Class TWImportLancContabil

	Local aArea 	:= GetArea()
	Local aCab  	:= {}
	Local aItem		:= {}
	Local aItemAux	:= {}
	Local CTF_LOCK	:= 0
	Local aErro 	:= {}
	Local cMens 	:= ""
	Local nX		:= 0
	Local aRecSX7 	:= {}
	Local nPosLote 	:= aScan(::oGridImp:aHeader, {|x| AllTrim(x[2]) == "CT2_LOTE"})
	Local nPosSBLote:= aScan(::oGridImp:aHeader, {|x| AllTrim(x[2]) == "CT2_SBLOTE"})
	Local nPosDoc	:= aScan(::oGridImp:aHeader, {|x| AllTrim(x[2]) == "CT2_DOC"})
	Local nW

	Private lMsErroAuto		:= .F.
	Private lMSHelpAuto 	:= .T.
	Private lAutoErrNoFile	:= .T.

	Default aItemGrid	:= {}
	Default cLote_		:= ""
	Default cSubLote_	:= ""
	Default cDoc_		:= ""

	If Empty(cDoc_)

		ProxDoc(dData_, Padr(Alltrim(cLote_), TamSx3("CT2_LOTE")[1]), Padr(Alltrim(cSubLote_), TamSx3("CT2_SBLOTE")[1]), @cDoc_, @CTF_LOCK)

	EndIf

	DBSelectArea("CT2")

	aCab := {{"DDATALANC"	, dData_ ,.F.},;
	{"CLOTE"			, Padr(Alltrim(cLote_)	, TamSx3("CT2_LOTE")[1])	,.F.},;
	{"CSUBLOTE"			, Padr(Alltrim(cSubLote_), TamSx3("CT2_SBLOTE")[1])	,.F.},;
	{"CDOC"				, Padr(Alltrim(cDoc_)	, TamSx3("CT2_DOC")[1])		,.F.},;
	{"CPADRAO"			, "", .F.},;
	{"NTOTINF"			, 0	, .F.}}

	For nW := 1 To Len(aItemGrid)

		aItemAux := {}

		aAdd(aItemAux, {"CT2_FILIAL", xFilial("CT2")	, .F.})
		aAdd(aItemAux, {"CT2_MOEDLC", "01"				, .F.})
		aAdd(aItemAux, {"CT2_TPSALD", "1"				, .F.})

		For nX := 1 To Len(::oGridImp:aHeader)

			If !( AllTrim(::oGridImp:aHeader[nX][2]) $ "CT2_LOTE|CT2_SBLOTE|CT2_DOC" )

				aAdd(aItemAux, {AllTrim(::oGridImp:aHeader[nX][2]), aItemGrid[nW][nX], .F.})

			EndIf

		Next nX

		aAdd(aItem, aItemAux)

	Next nW

	DBSelectArea("SX7")
	SX7->(dbSetOrder(1))

	If SX7->(dbSeek("CT2_DC"))

		aAdd(aRecSX7, SX7->(Recno()))

		SX7->(Reclock("SX7", .F.))
		SX7->(DbDelete())
		SX7->(MsUnlock())

	EndIf

	DBSelectArea("SX7")
	SX7->(dbSetOrder(1))

	If SX7->(dbSeek("CT2_CLVLCR"))

		aAdd(aRecSX7, SX7->(Recno()))

		SX7->(Reclock("SX7", .F.))
		SX7->(DbDelete())
		SX7->(MsUnlock())

	EndIf

	DBSelectArea("SX7")
	SX7->(dbSetOrder(1))

	If SX7->(dbSeek("CT2_CLVLDB"))

		aAdd(aRecSX7, SX7->(Recno()))

		SX7->(Reclock("SX7", .F.))
		SX7->(DbDelete())
		SX7->(MsUnlock())

	EndIf

	MSExecAuto({|x,y,Z| Ctba102(x,y,Z)}, aCab, aItem, nOpc_)

	If lMsErroAuto

		aErro := GetAutoGRLog()

		For nX := 1 To Len(aErro)

			cMens += aErro[nX] + CRLF

		Next nX

	Else

		MsUnlockAll()

	EndIf

	If nOpc_ == 3

		ConfirmSX8()

	EndIf

	For nX := 1 TO Len(aRecSX7)

		SX7->(DBGoTo(aRecSX7[nX]))

		SX7->(Reclock("SX7",.F.))
		SX7->(DbRecall())
		SX7->(MsUnlock())

	Next nX

	If CTF_LOCK > 0 // LIBERA O REGISTRO NO CTF COM A NUMERCAO DO DOC FINAL

		DBSelectArea("CTF")
		DBGoTo(CTF_LOCK)

		CtbDestrava( dData_, Padr(Alltrim(cLote_),TamSx3("CT2_LOTE")[1]), Padr(Alltrim(cSubLote_),TamSx3("CT2_SBLOTE")[1]), cDoc_, @CTF_LOCK)

	EndIf

	RestArea(aArea)

Return({lMsErroAuto, cMens})

User Function IMPARQCT2()

	Local oObj := TWImportLancContabil():New()

	Private cCadastro := TIT_WND
	Private aRotina := {}

	aRotina := { {"Pesquisar" ,"AxPesqui"  , 0 , 1,,.F.},; 	// "Pesquisar"
	{"Visualizar" ,"Ctba102Cal", 0 , 2},; 		// "Visualizar"
	{"Incluir" ,"Ctba102Cal", 0 , 3},; 		// "Incluir"
	{"Alterar" ,"Ctba102Cal", 0 , 4},; 		// "Alterar"
	{"Excluir" ,"Ctba102Cal", 0 , 5},;  		// "Excluir"
	{"Estornar","Ctba102Cal" , 0 , 4} ,;  		//"Estornar"
	{"Copiar","Ctba102Cal" , 0 , 3} ,;  		//"Copiar"
	{"Rastrear","CtbC010Rot" , 0 , 2} ,;  		// "Rastrear"
	{"Cópia Filial","Ctba102Cop"	, 0 , 4} }  // "Cópia Filial"

	oObj:Activate()

Return()