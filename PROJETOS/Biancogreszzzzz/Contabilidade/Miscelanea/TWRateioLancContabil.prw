#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWRateioLancContabil
@author Wlysses Cerqueira (Facile)
@since 02/08/2019
@project Automação Financeira
@version 1.0
@description 
@type class
/*/

// IDENTIFICADORES DE LINHA
#DEFINE LIN "LIN"

// PERCENTUAL DAS LINHAS
#DEFINE PER_LIN 100

// IDENTIFICADORES DE COLUNA
#DEFINE COL "COL"

// PERCENTUAL DAS COLUNAS POR LINHA
#DEFINE PER_COL 100

// IDENTIFICADORES DE JANELA
#DEFINE WND "WND"

// TITULOS DAS JANELAS
#DEFINE TIT_MAIN_WND "Rateio Despesas Grupo"
#DEFINE TIT_WND1 "Empresa Origem"
#DEFINE TIT_WND2 "Empresa Destino"

Class TWRateioLancContabil From LongClassName

Data cLote
Data cSubLote
Data cDoc

Data cRetMsg

Data oArquivo
Data aArquivo

Data cMesAno
Data dDtIni
Data dDtFim

Data cName
Data aParam
Data aParRet
Data bConfirm
Data lConfirm

Data oWindow // Janela principal - FWDialogModal
Data oContainer	// Divisor de janelas - FWFormContainer
Data cHeaderBox // Identificador do cabecalho da janela
Data cFilhoBox // Identificador dos Filho da janela

Data oFieldPai
Data oPnlPai
Data oGridPai
Data aColsPai
Data aHeaderPai
Data aEditPai

Data oPnlFilho
Data oGridFilho
Data oField
Data aColsFilho
Data aHeaderFilho
Data aEditFilho

Method New() ConStructor
Method ProcessaPai()
Method ProcessaFilho()

Method LoadInterface()
Method LoadWindow()
Method LoadContainer()

Method ExecAuto(nOpc_, dData_, cLote_, cSubLote_, cDoc_, aHeader, aFilhoGrid)
Method Log(lErro, cCodEmp_, cCodFil_, cLote_, cSubLote_, cDoc_, cErro)
Method Activate()

Method GDData()
Method GDField()

Method LoadPai()
Method GDEdiTabPai()

Method LoadFilho()
Method GDEdiTabFilho()

Method Valid()
Method Confirm()
Method Pergunte()
Method GdSeek()
Method Load()
Method OrdenarGrid(nCol, oGrid)

EndClass

Method New() Class TWRateioLancContabil

	::cName := "TWRateioLancContabil"
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.
	::cMesAno := Space(6)
	::dDtIni := STOD("  / /    ")
	::dDtFim := STOD("  / /    ")

	::oArquivo := TBiaArquivo():New()

	::oWindow := Nil
	::oContainer := Nil
	::cHeaderBox := ""
	::cFilhoBox := ""

	::oPnlPai 	:= Nil
	::oGridPai 	:= Nil
	::oFieldPai 	:= TGDField():New()
	::aColsPai	:= {}
	::aHeaderPai	:= {}
	::aEditPai	:= {}

	::oPnlFilho 	:= Nil
	::oGridFilho 	:= Nil
	::oField 		:= TGDField():New()
	::aColsFilho	:= {}
	::aHeaderFilho	:= {}
	::aEditFilho	:= {}

	::cLote 	:= "009003"
	::cSubLote	:= "001"
	::cDoc		:= ""
	::cRetMsg	:= ""

Return()

Method Pergunte() Class TWRateioLancContabil

	Local lRet := .F.
	Local nTam := 1

	::bConfirm := {|| .T. }

	::aParam := {}

	::aParRet := {}

	aAdd(::aParam, {1, "Mes/Ano", ::cMesAno, "@R !!/!!!!", ".T.", "", ".T.",,.F.})

	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)

		lRet := .T.

		::cMesAno := ::aParRet[nTam++]

		::dDtIni := CTOD("01/" + SubStr(::cMesAno, 1, 2) + "/" + SubStr(::cMesAno, 3, 4))

		::dDtFim := LastDay(::dDtIni)

	EndIf

Return(lRet)

Method LoadInterface() Class TWRateioLancContabil

	::LoadWindow()

	::LoadContainer()

	::LoadPai()

	::LoadFilho()

	::Load()

Return()

Method LoadWindow() Class TWRateioLancContabil

	Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()

	::oWindow:SetBackground(.T.)
	::oWindow:SetTitle(TIT_MAIN_WND)
	::oWindow:SetEscClose(.T.)
	::oWindow:SetSize(aCoors[4], aCoors[3])
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()

	::oWindow:AddOKButton({|| ::Confirm() })

	::oWindow:AddCloseButton()

	::oWindow:AddButton("Carregar", {|| ::Load() },,, .T., .F., .T.)

	::oWindow:AddButton("Pesquisar", {|| ::GdSeek() },,, .T., .F., .T.)

Return()

Method GdSeek() Class TWRateioLancContabil

	GdSeek(::oGridFilho,,,,.F.)

Return()

Method LoadContainer() Class TWRateioLancContabil

	::oContainer := FWFormContainer():New()

	::cHeaderBox := ::oContainer:CreateHorizontalBox(50)

	::cFilhoBox := ::oContainer:CreateHorizontalBox(50)

	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)

Return()

Method LoadPai() Class TWRateioLancContabil

	Local cVldDef := "AllwayStrue"

	::oPnlPai := ::oContainer:GetPanel(::cHeaderBox)

	// Layer
	oLayer := FWLayer():New()
	oLayer:Init(::oPnlPai, .F., .T.)

	// Adiciona linha ao Layer
	oLayer:AddLine(LIN, 100, .F.)

	// Adiciona coluna ao Layer
	oLayer:AddCollumn(COL, PER_COL, .T., LIN)

	// Adiciona janela ao Layer
	oLayer:AddWindow(COL, WND, TIT_WND1, 100, .F. ,.T.,, LIN, { || })

	oLayer:SetWinTitle(COL, WND, TIT_WND1, LIN)

	// Retorna paimel da janela do Layer
	oPnl := oLayer:GetWinPanel(COL, WND, LIN)

	::aEditPai := ::GDEdiTabPai()

	::aHeaderPai := ::GDField()

	::oGridPai := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", @::aEditPai,,, cVldDef,, cVldDef, oPnl, @::aHeaderPai, @::aColsPai)

	::oGridPai:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	//::oGridPai:oBrowse:bHeaderClick := {|oGrid, nCol| ::OrdenarGrid(nCol, @::oGridPai)} // Nao usar
	::oGridPai:oBrowse:lVScroll := .T.
	::oGridPai:oBrowse:lHScroll := .T.

	::oGridPai:SetArray(::aColsPai, .F.)

	::oGridPai:oBrowse:Refresh()

	::oGridPai:Refresh()

Return()

Method LoadFilho() Class TWRateioLancContabil

	Local cVldDef := "AllwayStrue"

	::oPnlFilho := ::oContainer:GetPanel(::cFilhoBox)

	// Layer
	oLayer := FWLayer():New()
	oLayer:Init(::oPnlFilho, .F., .T.)

	// Adiciona linha ao Layer
	oLayer:AddLine(LIN, 100, .F.)

	// Adiciona coluna ao Layer
	oLayer:AddCollumn(COL, PER_COL, .T., LIN)

	// Adiciona janela ao Layer
	oLayer:AddWindow(COL, WND, TIT_WND2, 100, .F. ,.T.,, LIN, { || })

	oLayer:SetWinTitle(COL, WND, TIT_WND2, LIN)

	// Retorna paimel da janela do Layer
	oPnl := oLayer:GetWinPanel(COL, WND, LIN)

	::aEditFilho := ::GDEdiTabFilho()

	::aHeaderFilho := ::GDField()

	::oGridFilho := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", @::aEditFilho,,, cVldDef,, cVldDef, oPnl, @::aHeaderFilho, @::aColsFilho)

	::oGridFilho:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	//::oGridFilho:oBrowse:bHeaderClick := {|oGrid, nCol| ::OrdenarGrid(nCol, @::oGridFilho)} // Nao usar
	::oGridFilho:oBrowse:lVScroll := .T.
	::oGridFilho:oBrowse:lHScroll := .T.

	::oGridFilho:SetArray(::aColsFilho, .F.)

	::oGridFilho:oBrowse:Refresh()

	::oGridFilho:Refresh()

Return()

Method OrdenarGrid(nCol, oGrid) Class TWRateioLancContabil

	oGrid:aColsPai := aSort( oGrid:aColsPai,,,{|x,y| x[nCol] < y[nCol]} )

	oGrid:SetArray(oGrid:aColsPai, .F.)

	oGrid:oBrowse:Refresh()

	oGrid:Refresh()

Return()

Method Load() Class TWRateioLancContabil

	DBSelectArea("ZL1")
	ZL1->(DBSetOrder(1)) // ZL1_FILIAL, ZL1_MESANO, ZL1_EMPFIL, ZL1_CNTPON, R_E_C_N_O_, D_E_L_E_T_

	If ::Pergunte()

		If ZL1->(DBSeek(xFilial("ZL1") + ::cMesAno))

			If ZL1->ZL1_EMPFIR == cEmpAnt + cFilAnt

				FWMsgRun(, {|| ::GDData() }, "Processando", "Carregando dados...")

			Else

				MsgStop("Obrigatório acessar a empresa de origem [" + ZL1->ZL1_EMPFIR + "] para processamento!")

			EndIf		

		Else

			MsgStop("Não foi encontrado a data de referencia informada!")

		EndIf

	EndIf

Return()

Method GDData() Class TWRateioLancContabil

	Local cSQL1 := ""
	Local cQry1 := GetNextAlias()

	Local cSQL2 := ""
	Local cQry1 := Nil

	Local nPos := 0
	Local aLinha := {}
	Local cLinha:= ""

	::aColsPai := {}

	::aColsFilho := {}

	cQry1 := GetNextAlias()

	cSQL1 += "SELECT "
	cSQL1 += "         ZL1_EMPFIL, "
	cSQL1 += "         MESANO, "
	cSQL1 += "         ZL1_PERCEN, "
	cSQL1 += "         ZL1_CNTPON, "
	cSQL1 += "         ZL1_CNTPOR, "
	cSQL1 += "         ZL1_EMPFIR, "
	cSQL1 += "         CT1_YPNTDB, "
	cSQL1 += "         CT1_YPNTCR, "
	cSQL1 += "         CTH_YPNTDB, "
	cSQL1 += "         ( "
	cSQL1 += "   	      SELECT TOP 1 "
	cSQL1 += "     	           XXX.CTH_CLVL "
	cSQL1 += "    	      FROM " + RetSqlName("CTH") + " XXX "
	cSQL1 += "      	  WHERE "
	cSQL1 += "      	          XXX.CTH_YPNTDB     = TAB3.CTH_YPNTCR "
	cSQL1 += "      	          AND XXX.CTH_YEMPFL = ZL1_EMPFIL "
	cSQL1 += "      	          AND XXX.D_E_L_E_T_ = ' ' "
	cSQL1 += "     		) NEWCVDB, "
	cSQL1 += "         CTH_YPNTCR, "
	cSQL1 += "         (SUM(SALDO) * ZL1_PERCEN) / 100 SALDO "
	cSQL1 += "FROM "
	cSQL1 += "         ( "
	cSQL1 += "             SELECT "
	cSQL1 += "                 MESANO, "
	cSQL1 += "                 CT1_YPNTDB, "
	cSQL1 += "                 CTH_YPNTDB, "
	cSQL1 += "                 CT1_YPNTCR, "
	cSQL1 += "                 CTH_YPNTCR, "
	cSQL1 += "                 SUM(SALDO) SALDO "
	cSQL1 += "             FROM "
	cSQL1 += "                 ( "
	cSQL1 += "                     SELECT "
	cSQL1 += "                                    TAB2.*, "
	cSQL1 += "                                    CT1_YPNTDB, "
	cSQL1 += "                                    CTH_YPNTDB, "
	cSQL1 += "                                    CT1_YPNTCR, "
	cSQL1 += "                                    CTH_YPNTCR "
	cSQL1 += "                     FROM "
	cSQL1 += "                                    ( "
	cSQL1 += "                                        SELECT "
	cSQL1 += "                                            MESANO, "
	cSQL1 += "                                            CONTA, "
	cSQL1 += "                                            CLVL, "
	cSQL1 += "                                            SUM(VALOR) SALDO "
	cSQL1 += "                                        FROM "
	cSQL1 += "                                            ( "
	cSQL1 += "                                                SELECT "
	cSQL1 += "                                                    SUBSTRING(CT2_DATA, 5, 2) + SUBSTRING(CT2_DATA, 1, 4) MESANO, "
	cSQL1 += "                                                    CT2_DEBITO                                            CONTA, "
	cSQL1 += "                                                    CT2_CLVLDB                                            CLVL, "
	cSQL1 += "                                                    CT2_VALOR                                             VALOR "
	cSQL1 += "                                                FROM "
	cSQL1 += "                                                    " + RetSqlName("CT2") + " CT2 (NOLOCK) "
	cSQL1 += "                                                WHERE "
	cSQL1 += "                                                    CT2_DATA "
	cSQL1 += "                                                    BETWEEN " + ValToSql(::dDtIni) + " AND " + ValToSql(::dDtFim) + " "
	cSQL1 += "                                                    AND CT2_DEBITO     <> '' "
	cSQL1 += "                                                    AND CT2_CLVLDB     <> '' "
	cSQL1 += "                                                    AND CT2.D_E_L_E_T_ = ' ' "
	cSQL1 += "                                                UNION ALL "
	cSQL1 += "                                                SELECT "
	cSQL1 += "                                                    SUBSTRING(CT2_DATA, 5, 2) + SUBSTRING(CT2_DATA, 1, 4) MESANO, "
	cSQL1 += "                                                    CT2_CREDIT                                            CONTA, "
	cSQL1 += "                                                    CT2_CLVLCR                                            CLVL, "
	cSQL1 += "                                                    CT2_VALOR * (-1)                                      VALOR "
	cSQL1 += "                                                FROM "
	cSQL1 += "                                                    " + RetSqlName("CT2") + " CT2 (NOLOCK) "
	cSQL1 += "                                                WHERE "
	cSQL1 += "                                                    CT2_DATA "
	cSQL1 += "                                                    BETWEEN " + ValToSql(::dDtIni) + " AND " + ValToSql(::dDtFim) + " "
	cSQL1 += "                                                    AND CT2_CREDIT     <> '' "
	cSQL1 += "                                                    AND CT2_CLVLCR     <> '' "
	cSQL1 += "                                                    AND CT2.D_E_L_E_T_ = ' ' "
	cSQL1 += "                                            ) TAB1 "
	//cSQL1 += "             									WHERE CONTA = '31302003' " // TESTE
	cSQL1 += "                                        GROUP BY "
	cSQL1 += "                                            MESANO, "
	cSQL1 += "                                            CONTA, "
	cSQL1 += "                                            CLVL "
	cSQL1 += "                                    )      TAB2 "
	cSQL1 += "                         INNER JOIN " + RetSqlName("CT1") + " CT1 ON ( "
	cSQL1 += "                                                      CT1_FILIAL         = " + ValToSql(xFilial("CT1"))
	cSQL1 += "                                                      AND CT1_CONTA      = CONTA "
	cSQL1 += "                                                      AND CT1_YRAT       = 'S' "
	cSQL1 += "                                                      AND CT1.D_E_L_E_T_ = ' ' "
	cSQL1 += "                                                  ) "
	cSQL1 += "                         INNER JOIN " + RetSqlName("CTH") + " CTH ON ( "
	cSQL1 += "                                                      CTH_FILIAL         = " + ValToSql(xFilial("CTH"))
	cSQL1 += "                                                      AND CTH_CLVL       = CLVL "
	cSQL1 += "                                                      AND CTH_YRAT       = 'S' "
	cSQL1 += "                                                      AND CTH.D_E_L_E_T_ = ' ' "
	cSQL1 += "                                                  ) "
	cSQL1 += "                 ) TAB2 "
	cSQL1 += "             GROUP BY "
	cSQL1 += "                 MESANO, "
	cSQL1 += "                 CT1_YPNTDB, "
	cSQL1 += "                 CTH_YPNTDB, "
	cSQL1 += "                 CT1_YPNTCR, "
	cSQL1 += "                 CTH_YPNTCR "
	cSQL1 += "         ) TAB3 "
	cSQL1 += "    JOIN " + RetSqlName("ZL1") + " ZL1 (NOLOCK) ON ( "
	cSQL1 += "                                        ZL1.ZL1_FILIAL = " + ValToSql(xFilial("CT1"))
	cSQL1 += "                                        AND ZL1.ZL1_EMPFIR = " + ValToSql(cEmpAnt + cFilAnt)
	cSQL1 += "                                        AND ZL1.ZL1_MESANO = MESANO "
	cSQL1 += "                                        AND ZL1.D_E_L_E_T_ = '' "
	cSQL1 += "                                    ) "
	cSQL1 += "GROUP BY "
	cSQL1 += "         ZL1_EMPFIL, "
	cSQL1 += "         MESANO, "
	cSQL1 += "         ZL1_PERCEN, "
	cSQL1 += "         ZL1_CNTPON, "
	cSQL1 += "         ZL1_CNTPOR, "
	cSQL1 += "         ZL1_EMPFIR, "
	cSQL1 += "         CT1_YPNTDB, "
	cSQL1 += "         CT1_YPNTCR, "
	cSQL1 += "         CTH_YPNTDB, "
	cSQL1 += "         CTH_YPNTCR "

	TcQuery cSQL1 New Alias (cQry1)

	While !(cQry1)->(EOF())

		nPos := 0

		nPos := aScan(aLinha, {|x| x[1] + x[2] + x[3] == (cQry1)->ZL1_EMPFIR + ::cLote + ::cSubLote})

		If nPos > 0

			cLinha := aLinha[nPos][4]

			cLinha := Soma1(cLinha, TamSx3("CT2_LINHA")[1])

			aLinha[nPos][4] := cLinha

		Else

			aAdd(aLinha, {(cQry1)->ZL1_EMPFIR, ::cLote, ::cSubLote, ""})

			nPos := Len(aLinha)

			cLinha := Soma1(StrZero(0, TamSx3("CT2_LINHA")[1]))

			aLinha[nPos][4] := cLinha

		EndIf

		aAdd(::aColsPai,;
		{;
		(cQry1)->ZL1_EMPFIR,;
		::cLote,;
		::cSubLote,;
		cLinha,;
		"3",;					// CT2_DC
		If((cQry1)->SALDO > 0, (cQry1)->ZL1_CNTPON, (cQry1)->CT1_YPNTCR),;	// CT2_DEBITO
		If((cQry1)->SALDO > 0, (cQry1)->CT1_YPNTCR, (cQry1)->ZL1_CNTPON),;	// CT2_CREDIT
		Abs((cQry1)->SALDO),;		// CT2_VALOR
		If((cQry1)->SALDO > 0, "", (cQry1)->CTH_YPNTCR),;					// CT2_CLVLDB
		If((cQry1)->SALDO > 0, (cQry1)->CTH_YPNTCR, ""),;	// CT2_CLVLCR
		'VLR RATEIO INTERCOMPANY N/MES CONF. RELACAO',;
		.F.;
		})

		nPos := 0

		nPos := aScan(aLinha, {|x| x[1] + x[2] + x[3] == (cQry1)->ZL1_EMPFIL + ::cLote + ::cSubLote})

		If nPos > 0

			cLinha := aLinha[nPos][4]

			cLinha := Soma1(cLinha, TamSx3("CT2_LINHA")[1])

			aLinha[nPos][4] := cLinha

		Else

			aAdd(aLinha, {(cQry1)->ZL1_EMPFIL, ::cLote, ::cSubLote, ""})

			nPos := Len(aLinha)

			cLinha := Soma1(StrZero(0, TamSx3("CT2_LINHA")[1]))

			aLinha[nPos][4] := cLinha

		EndIf

		aAdd(::aColsFilho,;
		{;
		(cQry1)->ZL1_EMPFIL,;
		::cLote,;
		::cSubLote,;
		cLinha,;
		"3",;					// CT2_DC
		If((cQry1)->SALDO > 0, (cQry1)->CT1_YPNTDB, (cQry1)->ZL1_CNTPOR),;	// CT2_DEBITO
		If((cQry1)->SALDO > 0, (cQry1)->ZL1_CNTPOR, (cQry1)->CT1_YPNTDB),;	// CT2_CREDIT
		Abs((cQry1)->SALDO),;		// CT2_VALOR
		If((cQry1)->SALDO > 0, (cQry1)->NEWCVDB, ""),;		// CT2_CLVLDB
		If((cQry1)->SALDO > 0, "", (cQry1)->NEWCVDB),;					// CT2_CLVLCR
		'VLR RATEIO INTERCOMPANY N/MES CONF. RELACAO',;
		.F.;
		})

		(cQry1)->(DbSkip())

	EndDo

	(cQry1)->(DbCloseArea())

	::oGridFilho:SetArray(::aColsFilho, .F.)

	::oGridFilho:oBrowse:Refresh()

	::oGridFilho:Refresh()

	::oGridPai:SetArray(::aColsPai, .F.)

	::oGridPai:oBrowse:Refresh()

	::oGridPai:Refresh()

Return()

Method Activate() Class TWRateioLancContabil

	::LoadInterface()

	::oWindow:Activate()

Return()

Method GDEdiTabPai() Class TWRateioLancContabil

	Local aRet := {}

	aRet := {}

Return(aRet)

Method GDEdiTabFilho() Class TWRateioLancContabil

	Local aRet := {}

	aRet := {}

Return(aRet)

Method GDField() Class TWRateioLancContabil

	Local aRet := {}

	::oField:Clear()

	::oField:AddField("ZL1_EMPFIL")
	::oField:AddField("CT2_LOTE")
	::oField:AddField("CT2_SBLOTE")
	//::oField:AddField("CT2_DOC")
	::oField:AddField("CT2_LINHA")

	::oField:AddField("CT2_DC")
	::oField:AddField("CT2_DEBITO")
	::oField:AddField("CT2_CREDIT")
	::oField:AddField("CT2_VALOR")
	::oField:AddField("CT2_CLVLDB")
	::oField:AddField("CT2_CLVLCR")
	//::oField:AddField("CT2_CCD")
	//::oField:AddField("CT2_CCC")
	//::oField:AddField("CT2_ITEMD")
	//::oField:AddField("CT2_ITEMC")
	//::oField:AddField("CT2_ATIVDE")

	//::oField:AddField("CT2_ORIGEM")
	::oField:AddField("CT2_HIST")

	//::oField:AddField("Space")	

	aRet := ::oField:GetHeader()

Return(aRet)

Method Valid() Class TWRateioLancContabil

	Local lRet		:= .T.

Return(lRet)

Method ProcessaPai(aCols_, aHeader_) Class TWRateioLancContabil

	Local aAreaSE1	:= SE1->(GetArea())
	Local aAreaSE2	:= SE2->(GetArea())
	Local nW		:= 0
	Local aLinha_	:= {}
	Local aRet		:= {}
	Local lRet		:= .T.

	Local cCodEmp_	:= ""
	Local cCodFil_	:= ""

	Local nPosEmpFil:= aScan(aHeader_, {|x| AllTrim(x[2]) == "ZL1_EMPFIL"})	
	Local nPosLote 	:= aScan(aHeader_, {|x| AllTrim(x[2]) == "CT2_LOTE"})
	Local nPosSBLote:= aScan(aHeader_, {|x| AllTrim(x[2]) == "CT2_SBLOTE"})
	//Local nPosDoc	:= aScan(aHeader_, {|x| AllTrim(x[2]) == "CT2_DOC"})

	Local cLote_	:= ""
	Local cSubLote_	:= ""
	Local cDoc_  	:= ""

	BEGIN TRANSACTION

		For nW := 1 To Len(aCols_)

			If !GDdeleted(nW, aHeader_, aCols_)

				If cCodEmp_ + cCodFil_ + cLote_ + cSubLote_ <> aCols_[nW][nPosEmpFil] + aCols_[nW][nPosLote] + aCols_[nW][nPosSBLote] //+ aCols_[nW][nPosDoc]

					If Len(aLinha_) > 0

						aRet := ::ExecAuto(3, dDataBase, cLote_, cSubLote_, cDoc_, aHeader_, aLinha_)

						If aRet[1]

							DisarmTransaction()

							::Log(.T., cCodEmp_, cCodFil_, cLote_, cSubLote_, aRet[2], aRet[3])

							aLinha_ := {}

							lRet := .F.

							Exit

						EndIf

						aLinha_ := {}

						aAdd(aLinha_, aCols_[nW])

						cLote_		:= aCols_[nW][nPosLote]

						cSubLote_	:= aCols_[nW][nPosSBLote]

						cCodEmp_ := SubStr(aCols_[nW][nPosEmpFil], 1, 2)

						cCodFil_ := SubStr(aCols_[nW][nPosEmpFil], 3, 2)

					Else

						aAdd(aLinha_, aCols_[nW])

						cLote_		:= aCols_[nW][nPosLote]

						cSubLote_	:= aCols_[nW][nPosSBLote]

						cCodEmp_ := SubStr(aCols_[nW][nPosEmpFil], 1, 2)

						cCodFil_ := SubStr(aCols_[nW][nPosEmpFil], 3, 2)

					EndIf

				Else

					aAdd(aLinha_, aCols_[nW])

					cLote_		:= aCols_[nW][nPosLote]

					cSubLote_	:= aCols_[nW][nPosSBLote]

					cCodEmp_ := SubStr(aCols_[nW][nPosEmpFil], 1, 2)

					cCodFil_ := SubStr(aCols_[nW][nPosEmpFil], 3, 2)

				EndIf

			EndIf

		Next nW

		If Len(aLinha_) > 0

			aRet := ::ExecAuto(3, dDataBase, cLote_, cSubLote_, cDoc_, aHeader_, aLinha_)

			If aRet[1]

				DisarmTransaction()

				::Log(.T., cCodEmp_, cCodFil_, cLote_, cSubLote_, aRet[2], aRet[3])

				lRet := .F.

			Else

				::Log(.F., cCodEmp_, cCodFil_, cLote_, cSubLote_, aRet[2], aRet[3])

			EndIf

		EndIf

	END TRANSACTION

	RestArea(aAreaSE1)
	RestArea(aAreaSE2)

Return(lRet)

Method Confirm() Class TWRateioLancContabil

	Local lRet := .T.

	If ::Valid()

		If MsgYesNo("Confirma importação?")

			::cRetMsg := ""

			FWMsgRun(, {|| lRet := ::ProcessaPai(::oGridPai:aCols, ::oGridPai:aHeader	)}, "Aguarde!", "Importando lançamentos pai...")

			If lRet

				FWMsgRun(, {|| ::ProcessaFilho(::oGridFilho:aCols, ::oGridFilho:aHeader	)}, "Aguarde!", "Importando lançamentos filho...")

			EndIf

		EndIf

	EndIf

	Aviso("ATENCAO", ::cRetMsg, {"Ok"}, 3)

Return()

Method ProcessaFilho(aCols_, aHeader_) Class TWRateioLancContabil

	Local aFilho 		:= aClone(aCols_)
	Local nW			:= 0
	Local xRet			:= Nil

	Local aLinha_		:= {}
	Local cLote_		:= ""
	Local cSubLote_		:= ""
	Local cDoc_  		:= ""
	Local cCodEmp_		:= ""
	Local cCodFil_		:= ""

	Local nPosEmpFil	:= aScan(aHeader_, {|x| AllTrim(x[2]) == "ZL1_EMPFIL"})
	Local nPosLote 		:= aScan(aHeader_, {|x| AllTrim(x[2]) == "CT2_LOTE"})
	Local nPosSBLote	:= aScan(aHeader_, {|x| AllTrim(x[2]) == "CT2_SBLOTE"})
	Local nPosLinha		:= aScan(aHeader_, {|x| AllTrim(x[2]) == "CT2_LINHA"})

	aFilho := aSort(aFilho,,,{|x,y| x[nPosEmpFil] + x[nPosLote] + x[nPosSBLote] + x[nPosLinha] < y[nPosEmpFil] + y[nPosLote] + y[nPosSBLote] + y[nPosLinha] })

	For nW := 1 To Len(aFilho)

		If !GDdeleted(nW, aHeader_, aFilho)

			If cCodEmp_ + cCodFil_ + cLote_ + cSubLote_ <> aFilho[nW][nPosEmpFil] + aFilho[nW][nPosLote] + aFilho[nW][nPosSBLote] //+ aFilho[nW][nPosDoc]

				If Len(aLinha_) > 0

					xRet := U_FROPCPRO(cCodEmp_, cCodFil_, "U_RATDESP", 3, dDataBase, cLote_, cSubLote_, cDoc_, aHeader_, aLinha_) // _cEmpDes, _cFilDes, _cNomeProc, _uPar1, _uPar2 ... _uPar15

					If ( ValType(xRet) == "C" .And. UPPER(AllTrim(xRet)) == "DEFAULTERRORPROC" ) .Or. ValType(xRet) == "U"

						//DisarmTransaction()	

						::Log(.T., cCodEmp_, cCodFil_, cLote_, cSubLote_, "", "Não foi possivel conectar!")

						aLinha_ := {}

						lRet := .F.

						Loop

					ElseIf ValType(xRet) == "A" .And. xRet[1]

						//DisarmTransaction()

						::Log(.T., cCodEmp_, cCodFil_, cLote_, cSubLote_, xRet[2], xRet[3])

					ElseIf ValType(xRet) == "A" .And. !xRet[1]

						::Log(.F., cCodEmp_, cCodFil_, cLote_, cSubLote_, xRet[2], xRet[3])

					EndIf

				EndIf

				aLinha_ := {}

				aAdd(aLinha_, aFilho[nW])

				cLote_		:= aFilho[nW][nPosLote]

				cSubLote_	:= aFilho[nW][nPosSBLote]

				cCodEmp_ := SubStr(aFilho[nW][nPosEmpFil], 1, 2)

				cCodFil_ := SubStr(aFilho[nW][nPosEmpFil], 3, 2)

			Else

				aAdd(aLinha_, aFilho[nW])

				cLote_		:= aFilho[nW][nPosLote]

				cSubLote_	:= aFilho[nW][nPosSBLote]

				cCodEmp_ := SubStr(aFilho[nW][nPosEmpFil], 1, 2)

				cCodFil_ := SubStr(aFilho[nW][nPosEmpFil], 3, 2)

			EndIf

		Else

			aAdd(aLinha_, aFilho[nW])

			cLote_		:= aFilho[nW][nPosLote]

			cSubLote_	:= aFilho[nW][nPosSBLote]

			cCodEmp_ := SubStr(aFilho[nW][nPosEmpFil], 1, 2)

			cCodFil_ := SubStr(aFilho[nW][nPosEmpFil], 3, 2)

		EndIf

	Next nW

	If Len(aLinha_) > 0

		xRet := U_FROPCPRO(cCodEmp_, cCodFil_, "U_RATDESP", 3, dDataBase, cLote_, cSubLote_, cDoc_, aHeader_, aLinha_) // _cEmpDes, _cFilDes, _cNomeProc, _uPar1, _uPar2 ... _uPar15

		If ( ValType(xRet) == "C" .And. UPPER(AllTrim(xRet)) == "DEFAULTERRORPROC" ) .Or. ValType(xRet) == "U"

			//DisarmTransaction()	

			::Log(.T., cCodEmp_, cCodFil_, cLote_, cSubLote_, "", "Não foi possivel conectar!")

			aLinha_ := {}

			lRet := .F.

		ElseIf ValType(xRet) == "A" .And. xRet[1] // O retorno da classe TFaturaReceber foi false

			//DisarmTransaction()	

			::Log(.T., cCodEmp_, cCodFil_, cLote_, cSubLote_, xRet[2], xRet[3])

			aLinha_ := {}

			lRet := .F.

		ElseIf ValType(xRet) == "A" .And. !xRet[1]

			//DisarmTransaction()

			::Log(.F., cCodEmp_, cCodFil_, cLote_, cSubLote_, xRet[2], xRet[3])

		EndIf

	EndIf

	Return()

Return()

Method ExecAuto(nOpc_, dData_, cLote_, cSubLote_, cDoc_, aHeader, aFilhoGrid) Class TWRateioLancContabil

	Local aArea 	:= GetArea()
	Local aCab  	:= {}
	Local aFilho	:= {}
	Local aFilhoAux	:= {}
	Local CTF_LOCK	:= 0
	Local aErro 	:= {}
	Local cMens 	:= ""
	Local nX		:= 0
	Local aRecSX7 	:= {}
	Local nPosLote 	:= aScan(aHeader, {|x| AllTrim(x[2]) == "CT2_LOTE"})
	Local nPosSBLote:= aScan(aHeader, {|x| AllTrim(x[2]) == "CT2_SBLOTE"})
	Local nPosDoc	:= aScan(aHeader, {|x| AllTrim(x[2]) == "CT2_DOC"})
	Local nW

	Private lMsErroAuto		:= .F.
	Private lMSHelpAuto 	:= .T.
	Private lAutoErrNoFile	:= .T.

	Default aFilhoGrid	:= {}
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

	For nW := 1 To Len(aFilhoGrid)

		aFilhoAux := {}

		aAdd(aFilhoAux, {"CT2_FILIAL", xFilial("CT2")	, .F.})
		aAdd(aFilhoAux, {"CT2_MOEDLC", "01"				, .F.})
		aAdd(aFilhoAux, {"CT2_TPSALD", "1"				, .F.})

		For nX := 1 To Len(aHeader)

			If !( AllTrim(aHeader[nX][2]) $ "CT2_LOTE|CT2_SBLOTE|CT2_DOC" )

				aAdd(aFilhoAux, {AllTrim(aHeader[nX][2]), aFilhoGrid[nW][nX], .F.})

			EndIf

		Next nX

		aAdd(aFilho, aFilhoAux)

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

	MSExecAuto({|x,y,Z| Ctba102(x,y,Z)}, aCab, aFilho, nOpc_)

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

Return({lMsErroAuto, cDoc_, cMens})

Method Log(lErro, cCodEmp_, cCodFil_, cLote_, cSubLote_, cDoc_, cErro) Class TWRateioLancContabil

	::cRetMsg += If(lErro, "[ ERRO ]", "[ SUCESSO ]") + " - Filial: " + cCodEmp_ + cCodFil_ + " Lote: " + cLote_ + " SubLote: " + cSubLote_ + " Doc: " + cDoc_ + If(lErro, CRLF + cErro, "") + CRLF + CRLF

Return(::cRetMsg)

User Function RATDESP(nOpc_, dDataBase_, cLote_, cSubLote_, cDoc_, aHeader_, aLinha_)

	Local oObj := Nil
	Local xRet := Nil

	Default nOpc_		:= 0
	Default dDataBase_	:= dDataBase
	Default cLote_		:= ""
	Default cSubLote_	:= ""
	Default cDoc_		:= ""
	Default aHeader_	:= {}
	Default aLinha_		:= {}

	oObj := TWRateioLancContabil():New()

	xRet := oObj:ExecAuto(nOpc_, dDataBase_, cLote_, cSubLote_, cDoc_, aHeader_, aLinha_)

Return(xRet)

User Function INTRATCON()

	Local oObj := TWRateioLancContabil():New()
	Local aRotBkp := {}

	Private cCadastro := TIT_MAIN_WND

	If Type("aRotina") == "A"

		aRotBkp := aClone(aRotina)

	EndIf

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

	aRotina := aRotBkp

Return()