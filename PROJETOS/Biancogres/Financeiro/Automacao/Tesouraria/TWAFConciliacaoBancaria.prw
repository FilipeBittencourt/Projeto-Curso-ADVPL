#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWAFConciliacaoBancaria
@author Tiago Rossini Coradini
@since 04/04/2019
@project Automação Financeira
@version 1.0
@description Classe (tela) para efetuar conciliacao bancaria
@type class
/*/

// TITULO DA JANELA
#DEFINE TIT_WND "Conciliação Bancária"
#DEFINE TIT_CAPTION_TOT "[Saldo Inicial: R$ @VLSINI]" + Space(5) + "[Saldo Final: R$ @VLSFIN]"
#DEFINE TIT_CAPTION_EXT "[Crédito: R$ @VLCRE]" + Space(5) + "[Débito: R$ @VLDEB]"
#DEFINE TIT_CAPTION_MOV "[Crédito: R$ @VLCRE" + Space(1) +"---"+ Space(1) + "Dif.: R$ @VLDIFC]" + Space(5) + "[Débito: R$ @VLDEB" + Space(1) +"---"+ Space(1) + "Dif.: R$ @VLDIFD]"

// Titulo dos botoes
#DEFINE TIT_BTN_REC "Conciliar"
#DEFINE TIT_BTN_MOV "Movimento Bancário"
#DEFINE TIT_BTN_TRA "Transferência Bancária"
#DEFINE TIT_BTN_REP "Replicar Extrato"
#DEFINE TIT_BTN_UPD "Atualizar"
#DEFINE TIT_BTN_PAR "Parametros"

// IDENTIFICADORES DO LAYER
#DEFINE LIN_TOP "LIN_TOP"
#DEFINE PER_LIN_TOP 100

#DEFINE COL_EXT_TOP "COL_EXT_TOP"
#DEFINE PER_COL_EXT_TOP 50
#DEFINE WND_EXT_TOP "WND_EXT_TOP"
#DEFINE TIT_WND_EXT_TOP "Extrato Bancário"
#DEFINE PER_WND_EXT_TOP 100

#DEFINE COL_MOV_TOP "COL_MOV_TOP"
#DEFINE PER_COL_MOV_TOP 50
#DEFINE WND_MOV_TOP "WND_MOV_TOP"
#DEFINE TIT_WND_MOV_TOP "Movimento Bancário"
#DEFINE PER_WND_MOV_TOP 100

// IDENTIFICADORES DOS BROWSERS
#DEFINE BRW_EXT "BRW_EXT"
#DEFINE BRW_MOV "BRW_MOV"

// INDICE DAS COLUNAS DOS BROWSERS
#DEFINE nPB_MARK 1
#DEFINE nPB_LEG 2
#DEFINE nPB_DATA 3
#DEFINE nPB_HIST 4
#DEFINE nPB_VALOR 5
#DEFINE nPB_SPACE 6
#DEFINE nPB_TYPE 7
#DEFINE nPB_GROUP 8
#DEFINE nPB_GROUP_REF 9
#DEFINE nPB_RECNO 10

// INDICE DO ARRAY DE TOTAIS DOS EXTRATOS AGRUPADOS
#DEFINE nPE_DATA 1
#DEFINE nPE_TYPE 2
#DEFINE nPE_GROUP_REF 3
#DEFINE nPE_VALOR 4

// INDICE DO ARRAY DE MOVIMENTOS
#DEFINE nPM_DATA 1
#DEFINE nPM_TYPE 2
#DEFINE nPM_GROUP 3
#DEFINE nPM_RECNO 4

Class TWAFConciliacaoBancaria From LongClassName

Data oFntBold // Fonte Bold
Data oWindow // Window
Data oContainer	// Container
Data oLayer // Layer

Data oPnlExt // Panel Top Ext
Data oPnlMov // Panel Top Mov

Data cHBox // Horizontal Box

Data nVlSIni // Saldo Inicial Bancario
Data nVlSFinExt // Saldo Final Extrato
Data nVlSFinMov // Saldo Final Movimento

Data oSayTotExt	
Data oSayExt
Data nVlCExt
Data nVlDExt

Data oSayTotMov
Data oSayMov
Data nVlCMov
Data nVlDMov

Data cChk // Check
Data cUnChk // UnCheck
Data cReconc // Reconcile

Data cCredit // Credito
Data cDebit // Debito
Data cInvalidRate // Tarifa invalida
Data cNotIdentified // Não identificado, exemplo depositos com bloqueio

Data oChkExt // Check Top Ext
Data oChkMov // Check Top Mov

Data lMarkAllExt // Mark All Top Ext
Data lMarkAllMov // Mark All Top Mov

Data oBrwExt // Browser Top Ext
Data oBrwMov // Browser Top Mov

Data oFldExt // TGDField Object
Data oFldMov // TGDField Object	
Data lConfirm	// Window Confirmed
Data oParam // Parameter Object

Data aMov // Array com os movimentos bancarios detalhados	

Data cVwTypeExt // Tipo de visualização de extrato: E=Exclusivo; C=Compartilhado		
Data cVwTypeMov // Tipo de visualização de movimentos bancarios: E=Exclusivo; C=Compartilhado

Method New(oParam) Constructor
Method LoadInterface()
Method LoadWindow()
Method LoadContainer()
Method LoadLayer()
Method LoadBrowser()	
Method LoadExtBrowser()
Method LoadMovBrowser()
Method GetWindowTitle()
Method GetBalance()
Method BankBalance()
Method BalanceStatement()
Method BankTransactionBalance()	
Method GetTotalValue(cID)
Method GetValue(cID)
Method SetLayerFont(cCol, cWnd, cLin)
Method Activate()
Method GetEditableField(cID)
Method GetFieldProperty(cID)
Method GetFieldData(cID)
Method GetFDExt()
Method GetFDMov()
Method GetGroup(cType, cNat, cDoc, cSit, cOri)
Method GetDscGrp(cGroup)
Method GetDscHist(cType, cNat, cHist, cBenef)
Method SortArray(xType, yType, xData, yData, xVlr, yVlr)
Method SortColumn(oBrw, oField, nColumn)
Method SetHeaderImage(oBrw, oField)
Method GetLegend(cType, cStatus)
Method BrowserClick(cID)
Method MarkExt(nAt)
Method MarkAllExt()
Method ExistMarkExt()
Method MarkMov(nAt)
Method MarkAllMov()
Method ExistMarkMov()
Method ExistData()
Method SelfMark()
Method SelfMarkAll()
Method SelfMarkGroup()
Method SelfMarkLine()
Method Validate()
Method VldValue()
Method VlBalance()
Method VlTotal()
Method VlByGroup()
Method GetMsg(dDtExt, cTypeExt, nVlExt, nVlMov)
Method Confirm()
Method BankMove()
Method AddBankMove(oParam)
Method BankTransfer()
Method AddBankTransfer(oParam)
Method ReplicateBankStatement()	
Method VldReplicateBankStatement(nPos)
Method BankStatementReplicated(nPos)
Method Reconcile()
Method UpdateExt(nId)
Method UpdateMov(nId)
Method ParamBox()
Method Refresh()

EndClass


Method New(oParam) Class TWAFConciliacaoBancaria

	Default oParam := Nil

	::oFntBold := TFont():New('Arial',,14,,.T.)
	::oWindow := Nil	
	::oContainer := Nil	
	::oLayer := Nil

	::oPnlExt := Nil
	::oPnlMov := Nil

	::cHBox := ""

	::nVlSIni := 0
	::nVlSFinExt := 0
	::nVlSFinMov := 0

	::oSayTotExt := Nil	
	::oSayExt := Nil
	::nVlCExt := 0
	::nVlDExt := 0	

	::oSayTotMov := Nil
	::oSayMov := Nil
	::nVlCMov := 0
	::nVlDMov := 0

	::cChk := "WFCHK"
	::cUnChk := "WFUNCHK"
	::cReconc := "LBNO.BMP"

	::cCredit := "BR_VERDE"
	::cDebit := "BR_VERMELHO"
	::cInvalidRate := "BR_AMARELO"
	::cNotIdentified := "BR_CINZA"

	::oChkExt := Nil
	::oChkMov := Nil

	::lMarkAllExt := .F.
	::lMarkAllMov := .F.

	::oBrwExt := Nil
	::oBrwMov := Nil

	::oFldExt := TGDField():New()
	::oFldMov := TGDField():New()

	::lConfirm := .F.	

	::oParam := oParam		

	::aMov := {}

	::cVwTypeExt := Upper(GetNewPar("MV_YVWTPEX", "C"))
	::cVwTypeMov := Upper(GetNewPar("MV_YVWTPMO", "C"))

Return()


Method LoadInterface() Class TWAFConciliacaoBancaria

	::LoadWindow()

	::LoadContainer()

	::LoadLayer()

	::LoadBrowser()

Return()


Method LoadWindow() Class TWAFConciliacaoBancaria
	Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()
	::oWindow:SetBackground(.T.) 
	::oWindow:SetTitle(::GetWindowTitle())
	::oWindow:SetEscClose(.T.)
	::oWindow:SetSize(aCoors[4], aCoors[3])
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()

	::oWindow:AddCloseButton()

	::oWindow:AddButton(TIT_BTN_REC, {|| ::Confirm() }, TIT_BTN_REC,, .T., .F., .T.)
	::oWindow:AddButton(TIT_BTN_MOV, {|| ::BankMove() }, TIT_BTN_MOV,, .T., .F., .T.)
	::oWindow:AddButton(TIT_BTN_TRA, {|| ::BankTransfer() }, TIT_BTN_TRA,, .T., .F., .T.)	
	::oWindow:AddButton(TIT_BTN_REP, {|| ::ReplicateBankStatement() }, TIT_BTN_REP,, .T., .F., .T.)
	::oWindow:AddButton(TIT_BTN_UPD, {|| ::Refresh() }, TIT_BTN_UPD,, .T., .F., .T.)
	::oWindow:AddButton(TIT_BTN_PAR, {|| ::ParamBox() }, TIT_BTN_PAR,, .T., .F., .T.)		

Return()


Method LoadContainer() Class TWAFConciliacaoBancaria

	::oContainer := FWFormContainer():New()

	::cHBox := ::oContainer:CreateHorizontalBox(100)

	::oContainer:Activate(::oWindow:GetPanelMain())

Return()


Method LoadLayer() Class TWAFConciliacaoBancaria

	::oLayer := FWLayer():New()
	::oLayer:Init(::oContainer:GetPanel(::cHBox), .F., .F.)

	::oLayer:AddLine(LIN_TOP, PER_LIN_TOP, .F.)

	::oLayer:AddCollumn(COL_EXT_TOP, PER_COL_EXT_TOP, .T., LIN_TOP)	
	::oLayer:AddWindow(COL_EXT_TOP, WND_EXT_TOP, TIT_WND_EXT_TOP, PER_WND_EXT_TOP, .F. ,.T.,, LIN_TOP)
	::SetLayerFont(COL_EXT_TOP, WND_EXT_TOP, LIN_TOP)

	::oLayer:AddCollumn(COL_MOV_TOP, PER_COL_MOV_TOP, .T., LIN_TOP)	
	::oLayer:AddWindow(COL_MOV_TOP, WND_MOV_TOP, TIT_WND_MOV_TOP, PER_WND_MOV_TOP, .F. ,.T.,, LIN_TOP)	
	::SetLayerFont(COL_MOV_TOP, WND_MOV_TOP, LIN_TOP)

Return()


Method LoadBrowser() Class TWAFConciliacaoBancaria

	::GetBalance()

	::LoadExtBrowser()

	::LoadMovBrowser()	

	::SelfMark()

Return()


Method LoadExtBrowser() Class TWAFConciliacaoBancaria
	Local cVldDef := "AllwaysTrue"

	::oPnlExt := ::oLayer:GetWinPanel(COL_EXT_TOP, WND_EXT_TOP, LIN_TOP)

	::oChkExt := TCheckBox():Create(::oPnlExt)
	::oChkExt:cName := 'oChk'
	::oChkExt:cCaption := "Marca / Desmarca todos"
	::oChkExt:nLeft := 0
	::oChkExt:nTop := 0	
	::oChkExt:nWidth := 300
	::oChkExt:nHeight := 20
	::oChkExt:lShowHint := .T.
	::oChkExt:cVariable := "::lMarkAllExt"
	::oChkExt:bSetGet := bSetGet(::lMarkAllExt)
	::oChkExt:Align := CONTROL_ALIGN_TOP	 
	::oChkExt:lVisibleControl := .T.
	::oChkExt:bChange := {|| ::MarkAllExt() }

	::oBrwExt := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", ::GetEditableField(BRW_EXT),,, cVldDef,, cVldDef, ::oPnlExt, ::GetFieldProperty(BRW_EXT), ::GetFieldData(BRW_EXT))
	::oBrwExt:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrwExt:oBrowse:bLDblClick := {|| ::BrowserClick(BRW_EXT) }
	::oBrwExt:oBrowse:bHeaderClick := {|oBrw, nColumn| ::SortColumn(::oBrwExt, ::oFldExt, nColumn) }
	::oBrwExt:oBrowse:lVScroll := .T.
	::oBrwExt:oBrowse:lHScroll := .T.

	::oSayExt := TSay():Create(::oPnlExt)
	::oSayExt:cName := "oSayExt"
	::oSayExt:cCaption := ::GetValue(BRW_EXT)
	::oSayExt:nLeft := 00
	::oSayExt:nTop := 00
	::oSayExt:nWidth := 100
	::oSayExt:nHeight := 15
	::oSayExt:lReadOnly := .T.
	::oSayExt:Align := CONTROL_ALIGN_BOTTOM
	::oSayExt:nClrText := RGB(0,50,100)

	::oSayTotExt := TSay():Create(::oPnlExt)
	::oSayTotExt:cName := "oSayTotExt"
	::oSayTotExt:cCaption := ::GetTotalValue(BRW_EXT)
	::oSayTotExt:nLeft := 00
	::oSayTotExt:nTop := 00
	::oSayTotExt:nWidth := 100
	::oSayTotExt:nHeight := 15
	::oSayTotExt:lReadOnly := .T.
	::oSayTotExt:Align := CONTROL_ALIGN_BOTTOM
	::oSayTotExt:nClrText := RGB(0,50,100)

Return()


Method LoadMovBrowser() Class TWAFConciliacaoBancaria
	Local cVldDef := "AllwaysTrue"

	::oPnlMov := ::oLayer:GetWinPanel(COL_MOV_TOP, WND_MOV_TOP, LIN_TOP)

	::oChkMov := TCheckBox():Create(::oPnlMov)
	::oChkMov:cName := 'oChk'
	::oChkMov:cCaption := "Marca / Desmarca todos"
	::oChkMov:nLeft := 0
	::oChkMov:nTop := 0	
	::oChkMov:nWidth := 300
	::oChkMov:nHeight := 20
	::oChkMov:lShowHint := .T.
	::oChkMov:cVariable := "::lMarkAllMov"
	::oChkMov:bSetGet := bSetGet(::lMarkAllMov)
	::oChkMov:Align := CONTROL_ALIGN_TOP	 
	::oChkMov:lVisibleControl := .T.
	::oChkMov:bChange := {|| ::MarkAllMov() }

	::oBrwMov := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", ::GetEditableField(BRW_MOV),,, cVldDef,, cVldDef, ::oPnlMov, ::GetFieldProperty(BRW_MOV), ::GetFieldData(BRW_MOV))
	::oBrwMov:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrwMov:oBrowse:bLDblClick := {|| ::BrowserClick(BRW_MOV) }
	::oBrwMov:oBrowse:bHeaderClick := {|oBrw, nColumn| ::SortColumn(::oBrwMov, ::oFldMov, nColumn) }	
	::oBrwMov:oBrowse:lVScroll := .T.
	::oBrwMov:oBrowse:lHScroll := .T.

	::oSayMov := TSay():Create(::oPnlMov)
	::oSayMov:cName := "oSayMov"
	::oSayMov:cCaption := ::GetValue(BRW_MOV)
	::oSayMov:nLeft := 00
	::oSayMov:nTop := 00
	::oSayMov:nWidth := 100
	::oSayMov:nHeight := 15
	::oSayMov:lReadOnly := .T.
	::oSayMov:Align := CONTROL_ALIGN_BOTTOM
	::oSayMov:nClrText := RGB(0,50,100)

	::oSayTotMov := TSay():Create(::oPnlMov)
	::oSayTotMov:cName := "oSayTotMov"
	::oSayTotMov:cCaption := ::GetTotalValue(BRW_MOV)
	::oSayTotMov:nLeft := 00
	::oSayTotMov:nTop := 00
	::oSayTotMov:nWidth := 100
	::oSayTotMov:nHeight := 15
	::oSayTotMov:lReadOnly := .T.
	::oSayTotMov:Align := CONTROL_ALIGN_BOTTOM
	::oSayTotMov:nClrText := RGB(0,50,100)	

Return()


Method GetWindowTitle() Class TWAFConciliacaoBancaria
	Local cRet := ""

	cRet := TIT_WND + " - [Banco: " + ::oParam:cBanco + " - Agência: " + AllTrim(::oParam:cAgencia) + " - Conta: " + AllTrim(::oParam:cConta);
	+ " - Período de " + cValToChar(::oParam:dDataDe) + " até " + cValToChar(::oParam:dDataAte) + "]"

Return(cRet)


Method GetBalance() Class TWAFConciliacaoBancaria

	::nVlSIni := ::BankBalance()

	::nVlSFinExt := ::BalanceStatement()

	::nVlSFinMov := ::BankTransactionBalance()

Return()


Method BankBalance() Class TWAFConciliacaoBancaria
	Local nRet := 0
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(ROUND(E8_SALATUA, 2), 0) AS E8_SALATUA "
	cSQL += " FROM " + RetSQLName("SE8")
	cSQL += " WHERE E8_FILIAL = " + ValToSQL(xFilial("SE8"))	
	cSQL += " AND E8_BANCO = " + ValToSQL(::oParam:cBanco)
	cSQL += " AND E8_AGENCIA = " + ValToSQL(::oParam:cAgencia)
	cSQL += " AND E8_CONTA = " + ValToSQL(::oParam:cConta)
	cSQL += " AND E8_DTSALAT = " + ValToSQL(DataValida(DaySub(::oParam:dDataDe, 1), .F.))
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	nRet := (cQry)->E8_SALATUA

	(cQry)->(DbCloseArea())

Return(nRet)


Method BalanceStatement() Class TWAFConciliacaoBancaria
	Local nRet := ::nVlSIni
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT SUBSTRING(ZK4_TPLANC, 1, 1) AS ZK4_TPLANC, ISNULL(ROUND(SUM(ZK4_VLTOT), 2), 0) AS ZK4_VLTOT "
	cSQL += " FROM " + RetSQLName("ZK4")
	cSQL += " WHERE ZK4_FILIAL = " + ValToSQL(xFilial("ZK4"))
	cSQL += " AND ZK4_EMP = " + ValToSQL(cEmpAnt)

	If ::cVwTypeExt == "E"

		cSQL += " AND ZK4_FIL = " + ValToSQL(cFilAnt)

	ElseIf ::cVwTypeExt == "C"

		cSQL += " AND ZK4_FIL BETWEEN " + ValToSQL(Space(Len(cFilAnt))) + " AND " + ValToSQL(Replicate("Z", Len(cFilAnt)))

	EndIf

	cSQL += " AND ZK4_TIPO = 'C' "
	cSQL += " AND ZK4_DTLANC BETWEEN " + ValToSQL(::oParam:dDataDe) + " AND " + ValToSQL(::oParam:dDataAte)
	cSQL += " AND ZK4_BANCO = " + ValToSQL(::oParam:cBanco)
	cSQL += " AND ZK4_AGENCI = " + ValToSQL(::oParam:cAgencia)
	cSQL += " AND ZK4_CONTA = " + ValToSQL(::oParam:cConta)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY SUBSTRING(ZK4_TPLANC, 1, 1) "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		If (cQry)->ZK4_TPLANC == "C"

			nRet += (cQry)->ZK4_VLTOT

		ElseIf (cQry)->ZK4_TPLANC == "D"

			nRet -= (cQry)->ZK4_VLTOT

		EndIf

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(nRet)


Method BankTransactionBalance() Class TWAFConciliacaoBancaria
	Local nRet := ::nVlSIni
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT E5_RECPAG, ISNULL(ROUND(SUM(E5_VALOR), 2), 0) AS E5_VALOR "
	cSQL += " FROM " + RetSQLName("SE5")

	If ::cVwTypeMov == "E"

		cSQL += " WHERE E5_FILIAL = " + ValToSQL(xFilial("SE5"))

	ElseIf ::cVwTypeMov == "C"

		cSQL += " WHERE E5_FILIAL BETWEEN " + ValToSQL(Space(Len(cFilAnt))) + " AND " + ValToSQL(Replicate("Z", Len(cFilAnt)))

	EndIf

	cSQL += " AND E5_DTDISPO BETWEEN " + ValToSQL(::oParam:dDataDe) + " AND " + ValToSQL(::oParam:dDataAte)
	cSQL += " AND E5_BANCO = " + ValToSQL(::oParam:cBanco)
	cSQL += " AND E5_AGENCIA = " + ValToSQL(::oParam:cAgencia)
	cSQL += " AND E5_CONTA = " + ValToSQL(::oParam:cConta)
	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_TIPODOC NOT IN ('BA','DC','JR','MT','CM','D2','J2','M2','C2','V2','CP','TL') "
	cSQL += " AND (E5_MOEDA NOT IN ('C1','C2','C3','C4','C5','CH') OR (E5_MOEDA IN ('C1','C2','C3','C4','C5','CH') AND E5_NUMCHEQ <> '')) "
	cSQL += " AND (E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) "
	cSQL += " AND ((E5_TIPODOC IN ('CH', 'CHF', 'CHP', 'CHR') AND E5_DTDISPO BETWEEN " + ValToSQL(::oParam:dDataDe) + " AND " + ValToSQL(::oParam:dDataAte) + ")"
	cSQL += " OR (E5_TIPODOC NOT IN ('CH', 'CHF', 'CHP', 'CHR') AND E5_DTDISPO BETWEEN " + ValToSQL(::oParam:dDataDe) + " AND " + ValToSQL(::oParam:dDataAte) + "))"
	cSQL += " AND (E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY E5_RECPAG "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		If (cQry)->E5_RECPAG == "R"

			nRet += (cQry)->E5_VALOR

		ElseIf (cQry)->E5_RECPAG == "P"

			nRet -= (cQry)->E5_VALOR

		EndIf		

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(nRet)


Method GetTotalValue(cID) Class TWAFConciliacaoBancaria
	Local cRet := ""

	cRet := StrTran(TIT_CAPTION_TOT, "@VLSINI", AllTrim(Transform(::nVlSIni, PesqPict("SE5", "E5_VALOR"))))
	cRet := StrTran(cRet, "@VLSFIN", AllTrim(Transform(If (cID == BRW_EXT, ::nVlSFinExt, ::nVlSFinMov), PesqPict("SE5", "E5_VALOR"))))

Return(cRet)


Method GetValue(cID) Class TWAFConciliacaoBancaria
	Local cRet := ""

	If cID == BRW_EXT

		cRet := StrTran(TIT_CAPTION_EXT, "@VLCRE", AllTrim(Transform(::nVlCExt, PesqPict("SE5", "E5_VALOR"))))
		cRet := StrTran(cRet, "@VLDEB", AllTrim(Transform(::nVlDExt, PesqPict("SE5", "E5_VALOR"))))

	ElseIf cID == BRW_MOV

		cRet := StrTran(TIT_CAPTION_MOV, "@VLCRE", AllTrim(Transform(::nVlCMov, PesqPict("SE5", "E5_VALOR"))))
		cRet := StrTran(cRet, "@VLDIFC", AllTrim(Transform(::nVlCExt - ::nVlCMov, PesqPict("SE5", "E5_VALOR"))))
		cRet := StrTran(cRet, "@VLDEB", AllTrim(Transform(::nVlDMov, PesqPict("SE5", "E5_VALOR"))))
		cRet := StrTran(cRet, "@VLDIFD", AllTrim(Transform(::nVlDExt - ::nVlDMov, PesqPict("SE5", "E5_VALOR"))))

	EndIf

Return(cRet)


Method SetLayerFont(cCol, cWnd, cLin) Class TWAFConciliacaoBancaria
	Local oWnd := Nil

	::oLayer:GetWindow(cCol, cWnd, @oWnd, cLin)

	oWnd:oTitleBar:oFont := ::oFntBold

Return()


Method Activate() Class TWAFConciliacaoBancaria

	::LoadInterface()

	::oWindow:Activate()

Return()


Method GetEditableField(cID) Class TWAFConciliacaoBancaria
	Local aRet := {}

Return(aRet)


Method GetFieldProperty(cID) Class TWAFConciliacaoBancaria
	Local aRet :=	{}

	If cID == BRW_EXT

		::oFldExt:Clear()

		::oFldExt:AddField("MARK")
		::oFldExt:FieldName("MARK"):cTitle := ""
		::oFldExt:FieldName("MARK"):cPict := "@BMP"

		::oFldExt:AddField("LEG")
		::oFldExt:FieldName("LEG"):cTitle := ""
		::oFldExt:FieldName("LEG"):cPict := "@BMP"

		::oFldExt:AddField("ZK4_DTLANC")
		::oFldExt:FieldName("ZK4_DTLANC"):cTitle := "Data"

		::oFldExt:AddField("ZK4_DSHIST")
		::oFldExt:FieldName("ZK4_DSHIST"):nSize := 50
		::oFldExt:FieldName("ZK4_DSHIST"):cTitle := "Historico"

		::oFldExt:AddField("ZK4_VLTOT")
		::oFldExt:FieldName("ZK4_VLTOT"):cTitle := "Valor"

		::oFldExt:AddField("_SPACE_")

		aRet := ::oFldExt:GetHeader()

	ElseIf cID == BRW_MOV

		::oFldMov:Clear()

		::oFldMov:AddField("MARK")
		::oFldMov:FieldName("MARK"):cTitle := ""
		::oFldMov:FieldName("MARK"):cPict := "@BMP"

		::oFldMov:AddField("LEG")
		::oFldMov:FieldName("LEG"):cTitle := ""
		::oFldMov:FieldName("LEG"):cPict := "@BMP"

		::oFldMov:AddField("E5_DTDISPO")
		::oFldMov:FieldName("E5_DTDISPO"):cTitle := "Data"
		::oFldMov:FieldName("E5_DTDISPO"):cType := "C"  

		::oFldMov:AddField("E5_HISTOR")
		::oFldMov:FieldName("E5_HISTOR"):nSize := 50
		::oFldMov:FieldName("E5_HISTOR"):cTitle := "Historico / Documento"

		::oFldMov:AddField("E5_VALOR")
		::oFldMov:FieldName("E5_VALOR"):cTitle := "Valor"

		::oFldMov:AddField("SPACE")

		aRet := ::oFldMov:GetHeader()

	EndIf

Return(aRet)


Method GetFieldData(cID) Class TWAFConciliacaoBancaria
	Local aRet := {}

	If cID == BRW_EXT

		aRet := ::GetFDExt()

	ElseIf cID == BRW_MOV

		aRet := ::GetFDMov()

	EndIf

Return(aRet)


Method GetFDExt() Class TWAFConciliacaoBancaria
	Local aRet := {}
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT ZK4_STATUS, SUBSTRING(ZK4_TPLANC, 1, 1) AS ZK4_TPLANC, ZK4_DTLANC, ZK4_CDHIST + '-' + ZK4_DSHIST AS ZK4_DSHIST, "
	cSQL += " ZK4_VLTOT, ZK4_RECONC, ZK4_CDHIST, ZK4.R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("ZK4") + " ZK4 "
	cSQL += " WHERE ZK4_FILIAL = " + ValToSQL(xFilial("ZK4"))
	cSQL += " AND ZK4_EMP = " + ValToSQL(cEmpAnt)

	If ::cVwTypeExt == "E"

		cSQL += " AND ZK4_FIL = " + ValToSQL(cFilAnt)

	ElseIf ::cVwTypeExt == "C"

		cSQL += " AND ZK4_FIL BETWEEN " + ValToSQL(Space(Len(cFilAnt))) + " AND " + ValToSQL(Replicate("Z", Len(cFilAnt)))

	EndIf

	cSQL += " AND ZK4_TIPO = 'C' "
	cSQL += " AND ZK4_DTLANC BETWEEN " + ValToSQL(::oParam:dDataDe) + " AND " + ValToSQL(::oParam:dDataAte)
	cSQL += " AND ZK4_BANCO = " + ValToSQL(::oParam:cBanco)
	cSQL += " AND ZK4_AGENCI = " + ValToSQL(::oParam:cAgencia)
	cSQL += " AND ZK4_CONTA = " + ValToSQL(::oParam:cConta)

	If SubStr(::oParam:cTipo, 1, 1) $ "C/D"

		cSQL += " AND SUBSTRING(ZK4_TPLANC, 1, 1) = " + ValToSQL(SubStr(::oParam:cTipo, 1, 1))

	EndIf

	If SubStr(::oParam:cVisib, 1, 1) == "C"

		cSQL += " AND ZK4_RECONC = 'S' "

	ElseIf SubStr(::oParam:cVisib, 1, 1) == "N"

		cSQL += " AND ZK4_RECONC = '' "

	EndIf

	cSQL += " AND ZK4.D_E_L_E_T_ = '' "
	cSQL += " ORDER BY ZK4_DTLANC, RIGHT(ZK4_FILE, CHARINDEX('\', REVERSE(ZK4_FILE))-1), ZK4.R_E_C_N_O_	"

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		aAdd(aRet, {If ((cQry)->ZK4_RECONC == "S", ::cReconc, If (!Empty((cQry)->ZK4_TPLANC), ::cUnChk, Space(1))), ::GetLegend((cQry)->ZK4_TPLANC, (cQry)->ZK4_STATUS), sToD((cQry)->ZK4_DTLANC),;
		AllTrim((cQry)->ZK4_DSHIST), (cQry)->ZK4_VLTOT, Space(1), If (SubStr((cQry)->ZK4_TPLANC, 1, 1) == "C", "R", "P"), Space(1),; 
		(cQry)->ZK4_CDHIST, (cQry)->RECNO, .F.})

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(aRet)


Method GetFDMov() Class TWAFConciliacaoBancaria
	Local aRet := {}
	Local aGrpMov := {}
	Local cSQL := ""
	Local cQry := GetNextAlias()

	::aMov := {}

	cSQL := " SELECT E5_RECPAG, E5_DTDISPO, E5_HISTOR, E5_DOCUMEN, E5_NATUREZ, E5_BENEF, E5_ORIGEM, E5_SITCOB, E5_VALOR, "
	cSQL += "	E5_RECONC, R_E_C_N_O_ AS RECNO "
	cSQL += " FROM " + RetSQLName("SE5")

	If ::cVwTypeMov == "E"

		cSQL += " WHERE E5_FILIAL = " + ValToSQL(xFilial("SE5"))

	ElseIf ::cVwTypeMov == "C"

		cSQL += " WHERE E5_FILIAL BETWEEN " + ValToSQL(Space(Len(cFilAnt))) + " AND " + ValToSQL(Replicate("Z", Len(cFilAnt)))

	EndIf

	cSQL += " AND E5_DTDISPO BETWEEN " + ValToSQL(::oParam:dDataDe) + " AND " + ValToSQL(::oParam:dDataAte)
	cSQL += " AND E5_BANCO = " + ValToSQL(::oParam:cBanco)
	cSQL += " AND E5_AGENCIA = " + ValToSQL(::oParam:cAgencia)
	cSQL += " AND E5_CONTA = " + ValToSQL(::oParam:cConta)
	cSQL += " AND E5_SITUACA <> 'C' "

	If SubStr(::oParam:cTipo, 1, 1) $ "C/D"

		cSQL += " AND E5_RECPAG = " + ValToSQL(If (SubStr(::oParam:cTipo, 1, 1) == "C", "R", "P"))

	EndIf

	If SubStr(::oParam:cVisib, 1, 1) == "C"

		cSQL += " AND E5_RECONC = 'x' "

	ElseIf SubStr(::oParam:cVisib, 1, 1) == "N"

		cSQL += " AND E5_RECONC = '' "

	EndIf

	cSQL += " AND E5_TIPODOC NOT IN ('BA','DC','JR','MT','CM','D2','J2','M2','C2','V2','CP','TL') "
	cSQL += " AND (E5_MOEDA NOT IN ('C1','C2','C3','C4','C5','CH') OR (E5_MOEDA IN ('C1','C2','C3','C4','C5','CH') AND E5_NUMCHEQ <> '')) "
	cSQL += " AND (E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) "
	cSQL += " AND ((E5_TIPODOC IN ('CH', 'CHF', 'CHP', 'CHR') AND E5_DTDISPO BETWEEN " + ValToSQL(::oParam:dDataDe) + " AND " + ValToSQL(::oParam:dDataAte) + ")"
	cSQL += " OR (E5_TIPODOC NOT IN ('CH', 'CHF', 'CHP', 'CHR') AND E5_DTDISPO BETWEEN " + ValToSQL(::oParam:dDataDe) + " AND " + ValToSQL(::oParam:dDataAte) + "))"
	cSQL += " AND (E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY E5_RECPAG DESC, E5_DTDISPO, E5_VALOR "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		cGroup := ::GetGroup((cQry)->E5_RECPAG, AllTrim((cQry)->E5_NATUREZ), AllTrim((cQry)->E5_DOCUMEN), (cQry)->E5_SITCOB, AllTrim((cQry)->E5_ORIGEM))

		aAdd(::aMov, {sToD((cQry)->E5_DTDISPO), (cQry)->E5_RECPAG, cGroup, (cQry)->RECNO})

		If !Empty(cGroup)

			nPos := aScan(aGrpMov, {|x| x[nPB_DATA] == sToD((cQry)->E5_DTDISPO) .And. x[nPB_GROUP] == cGroup })

			If nPos > 0

				aGrpMov[nPos, nPB_VALOR] += (cQry)->E5_VALOR

			Else

				aAdd(aGrpMov, {If ((cQry)->E5_RECONC = "x", ::cReconc, ::cUnChk), ::GetLegend((cQry)->E5_RECPAG), sToD((cQry)->E5_DTDISPO),;
				::GetDscGrp(cGroup), (cQry)->E5_VALOR, Space(1), (cQry)->E5_RECPAG, cGroup, Left(cGroup, 3), (cQry)->RECNO, .F.})

			EndIf

		Else

			aAdd(aGrpMov, {If ((cQry)->E5_RECONC = "x", ::cReconc, ::cUnChk), ::GetLegend((cQry)->E5_RECPAG), sToD((cQry)->E5_DTDISPO),;
			::GetDscHist((cQry)->E5_RECPAG, AllTrim((cQry)->E5_NATUREZ), AllTrim((cQry)->E5_HISTOR), AllTrim((cQry)->E5_BENEF)),;
			(cQry)->E5_VALOR, Space(1), (cQry)->E5_RECPAG, cGroup, AllTrim((cQry)->E5_NATUREZ), (cQry)->RECNO, .F.})

		EndIf

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

	aSort(aGrpMov,,, {|x,y| ::SortArray(x[nPB_TYPE], y[nPB_TYPE], x[nPB_DATA], y[nPB_DATA], x[nPB_VALOR], y[nPB_VALOR]) })

	aRet := aGrpMov

Return(aRet)


Method SortArray(xType, yType, xData, yData, xVlr, yVlr) Class TWAFConciliacaoBancaria
	Local lRet := .T.

	lRet := xType > yType .Or. xType == yType .And. (xData < yData .Or. xData == yData .And. xVlr < yVlr)

Return(lRet)


Method SortColumn(oBrw, oField, nColumn) Class TWAFConciliacaoBancaria
	Local nSort := 0
	Local nCount := 0

	If nColumn > 2 .And. nColumn < 6

		For nCount := 1 To oField:Fields:GetCount()

			If nCount <> nColumn

				oField:Fields:GetValue(nCount):nSort := 0

				oBrw:oBrowse:SetHeaderImage(nCount, "")

			EndIf

		Next

		If oField:Fields:GetValue(nColumn):nSort == 1

			nSort := 2

			aSort(oBrw:aCols,,, {|x,y| (x[nColumn]) > (y[nColumn])})

		Else

			nSort := 1

			aSort(oBrw:aCols,,, {|x,y| (x[nColumn]) < (y[nColumn])})

		EndIf

		oField:Fields:GetValue(nColumn):nSort := nSort

		oBrw:oBrowse:SetHeaderImage(nColumn, If (nSort == 1, "COLDOWN", "COLRIGHT"))

		oBrw:Refresh()

	EndIf

Return()


Method SetHeaderImage(oBrw, oField) Class TWAFConciliacaoBancaria
	Local nCount := 0

	For nCount := 1 To oField:Fields:GetCount()			

		oField:Fields:GetValue(nCount):nSort := 0

		oBrw:oBrowse:SetHeaderImage(nCount, "")

	Next

Return()


Method GetGroup(cType, cNat, cDoc, cSit, cOri) Class TWAFConciliacaoBancaria
	Local cRet := ""

	If cType == "P"

		If !Empty(cDoc)

			cRet := cType + "01" + cDoc // Bordero

		ElseIf cNat == "2915"

			cRet := cType + "02" // Tarifa de cobranca

		ElseIf cNat == "2938"

			cRet := cType + "03" // Tarifa de cartorio

		EndIf

	ElseIf cType == "R"

		If cNat == "1121"

			If cSit == "1" .And. cOri == "RPC"

				cRet := cType + "01" // Cobranca

			Else

				cRet := cType + "02" // Deposito

			EndIf					

		ElseIf cNat == "1230"

			cRet := cType + "01" // Cobranca

		EndIf

	EndIf

Return(cRet)


Method GetDscGrp(cGroup) Class TWAFConciliacaoBancaria
	Local cRet := ""
	Local cType := SubStr(cGroup, 1, 1)
	Local cIdType := SubStr(cGroup, 2, 2)
	Local cDscType := If (Len(cGroup) > 4, SubStr(cGroup, 4, Len(cGroup)), "")

	If cType == "P"

		If cIdType == "01"

			cRet := "BORDERO: " + cDscType

		ElseIf cIdType == "02"

			cRet := "TARIFA COBRANCA"

		ElseIf cIdType == "03"

			cRet := "TARIFA CARTORIO"

		EndIf		

	ElseIf cType == "R"

		If cIdType == "01"

			cRet := "COBRANCA"

		ElseIf cIdType == "02"

			cRet := "DEPOSITO"

		EndIf

	EndIf

Return(cRet)


Method GetDscHist(cType, cNat, cHist, cBenef) Class TWAFConciliacaoBancaria
	Local cRet := cHist

	If cType == "P"

		If cNat == "2601"

			cRet := cBenef

		EndIf

	EndIf

Return(cRet)


Method GetLegend(cType, cStatus) Class TWAFConciliacaoBancaria
	Local cRet := ""

	Default cStatus := ""

	If cType $ "C/R"

		cRet := ::cCredit

	ElseIf cType $ "D/P"

		If cStatus <> "4"

			cRet := ::cDebit

		Else

			cRet := ::cInvalidRate

		EndIf

	ElseIf Empty(cType)

		cRet := ::cNotIdentified

	EndIf

Return(cRet)


Method BrowserClick(cID) Class TWAFConciliacaoBancaria

	If cID == BRW_EXT

		::MarkExt()

	ElseIf cID == BRW_MOV

		::MarkMov()

	EndIf

Return()


Method MarkExt(nAt) Class TWAFConciliacaoBancaria

	Default nAt := ::oBrwExt:nAt

	If ::oBrwExt:lActive

		If ::oBrwExt:aCols[nAt, nPB_MARK] <> ::cReconc .And. ::oBrwExt:aCols[nAt, nPB_LEG] <> ::cNotIdentified

			If ::oBrwExt:aCols[nAt, nPB_MARK] == ::cChk

				::oBrwExt:aCols[nAt, nPB_MARK] := ::cUnChk

				If ::oBrwExt:aCols[nAt, nPB_LEG] == ::cCredit

					::nVlCExt -= ::oBrwExt:aCols[nAt, nPB_VALOR]

				Else

					::nVlDExt -= ::oBrwExt:aCols[nAt, nPB_VALOR]

				EndIf

			Else

				::oBrwExt:aCols[nAt, nPB_MARK] := ::cChk

				If ::oBrwExt:aCols[nAt, nPB_LEG] == ::cCredit

					::nVlCExt += ::oBrwExt:aCols[nAt, nPB_VALOR]

				Else

					::nVlDExt += ::oBrwExt:aCols[nAt, nPB_VALOR]

				EndIf

			EndIf						

			::oSayExt:cCaption := ::GetValue(BRW_EXT)

			::oSayMov:cCaption := ::GetValue(BRW_MOV)

		EndIf

	EndIf

Return()


Method MarkAllExt() Class TWAFConciliacaoBancaria
	Local nCount := 0

	If ::oBrwExt:lActive

		If Len(::oBrwExt:aCols) > 0

			::nVlCExt := 0

			::nVlDExt := 0

			For nCount := 1 To Len(::oBrwExt:aCols)

				If ::oBrwExt:aCols[nCount, nPB_MARK] <> ::cReconc .And. ::oBrwExt:aCols[nCount, nPB_LEG] <> ::cNotIdentified

					If ::lMarkAllExt

						::oBrwExt:aCols[nCount, nPB_MARK] := ::cChk

						If ::oBrwExt:aCols[nCount, nPB_LEG] == ::cCredit

							::nVlCExt += ::oBrwExt:aCols[nCount, nPB_VALOR]

						Else

							::nVlDExt += ::oBrwExt:aCols[nCount, nPB_VALOR]

						EndIf

					Else

						::oBrwExt:aCols[nCount, nPB_MARK] := ::cUnChk

					EndIf

				EndIf

			Next

			::oBrwExt:oBrowse:Refresh()						

		EndIf

		::oSayExt:cCaption := ::GetValue(BRW_EXT)

		::oSayMov:cCaption := ::GetValue(BRW_MOV)

	EndIf

Return()


Method ExistMarkExt() Class TWAFConciliacaoBancaria
	Local lRet := .T.

	If aScan(::oBrwExt:aCols, {|x| x[nPB_MARK] == ::cChk }) == 0

		lRet := .F.

		MsgAlert("Atenção, nenhum item do extrato bancário foi selecionado.", TIT_WND)

	EndIf

Return(lRet)


Method MarkMov(nAt) Class TWAFConciliacaoBancaria

	Default nAt := ::oBrwMov:nAt

	If ::oBrwMov:lActive

		If ::oBrwMov:aCols[nAt, nPB_MARK] <> ::cReconc

			If ::oBrwMov:aCols[nAt, nPB_MARK] == ::cChk

				::oBrwMov:aCols[nAt, nPB_MARK] := ::cUnChk

				If ::oBrwMov:aCols[nAt, nPB_LEG] == ::cCredit

					::nVlCMov -= ::oBrwMov:aCols[nAt, nPB_VALOR]

				Else

					::nVlDMov -= ::oBrwMov:aCols[nAt, nPB_VALOR]

				EndIf

			Else

				::oBrwMov:aCols[nAt, nPB_MARK] := ::cChk

				If ::oBrwMov:aCols[nAt, nPB_LEG] == ::cCredit

					::nVlCMov += ::oBrwMov:aCols[nAt, nPB_VALOR]

				Else

					::nVlDMov += ::oBrwMov:aCols[nAt, nPB_VALOR]

				EndIf

			EndIf

			::oSayMov:cCaption := ::GetValue(BRW_MOV)

		EndIf

	EndIf

Return()


Method MarkAllMov() Class TWAFConciliacaoBancaria
	Local nCount := 0

	If ::oBrwMov:lActive

		If Len(::oBrwMov:aCols) > 0

			::nVlCMov := 0

			::nVlDMov := 0

			For nCount := 1 To Len(::oBrwMov:aCols)

				If ::oBrwMov:aCols[nCount, nPB_MARK] <> ::cReconc

					If ::lMarkAllMov

						::oBrwMov:aCols[nCount, nPB_MARK] := ::cChk

						If ::oBrwMov:aCols[nCount, nPB_LEG] == ::cCredit

							::nVlCMov += ::oBrwMov:aCols[nCount, nPB_VALOR]

						Else

							::nVlDMov += ::oBrwMov:aCols[nCount, nPB_VALOR]

						EndIf

					Else

						::oBrwMov:aCols[nCount, nPB_MARK] := ::cUnChk

					EndIf

				EndIf

			Next

			::oBrwMov:oBrowse:Refresh()						

		EndIf

		::oSayMov:cCaption := ::GetValue(BRW_MOV)

	EndIf

Return()


Method ExistMarkMov() Class TWAFConciliacaoBancaria
	Local lRet := .T.

	If aScan(::oBrwMov:aCols, {|x| x[nPB_MARK] == ::cChk }) == 0

		lRet := .F.

		MsgAlert("Atenção, nenhum item do movimento bancário foi selecionado.", TIT_WND)

	EndIf

Return(lRet)


Method ExistData() Class TWAFConciliacaoBancaria
	Local lRet := .T.

	lRet := (Len(::oBrwExt:aCols) > 0 .And. aScan(::oBrwExt:aCols, {|x| Empty(x[nPB_MARK]) }) == 0) .And. (Len(::oBrwMov:aCols) > 0 .And. aScan(::oBrwMov:aCols, {|x| Empty(x[nPB_MARK]) }) == 0)

Return(lRet)


Method SelfMark() Class TWAFConciliacaoBancaria

	If !::SelfMarkAll()

		::SelfMarkGroup()

		::SelfMarkLine()

	EndIf

Return()


Method SelfMarkAll() Class TWAFConciliacaoBancaria
	Local lRet := .T.

	If (lRet := ::nVlSFinExt == ::nVlSFinMov .And. ::ExistData())

		::lMarkAllExt := .T.
		::MarkAllExt()

		::lMarkAllMov := .T.
		::MarkAllMov()

	EndIf

Return(lRet)


Method SelfMarkGroup() Class TWAFConciliacaoBancaria
	Local nCount := 0
	Local nPos := 0
	Local aExt := ::oBrwExt:aCols
	Local aMov := ::oBrwMov:aCols
	Local aGrpExt := {}
	Local nVlMov := 0
	Local cGroupRef := ""
	Local bMarkExt := {|x, nPos| If (x[nPB_MARK] == ::cUnChk .And. x[nPB_DATA] == aGrpExt[nCount, nPE_DATA] .And. x[nPB_TYPE] == aGrpExt[nCount, nPE_TYPE] .And. x[nPB_GROUP_REF] == aGrpExt[nCount, nPE_GROUP_REF], ::MarkExt(nPos), Nil) }
	Local bSumMov := {|x| If ( x[nPB_MARK] == ::cUnChk .And. x[nPB_DATA] == aGrpExt[nCount, nPE_DATA] .And. x[nPB_TYPE] == aGrpExt[nCount, nPE_TYPE] .And. x[nPB_GROUP_REF] == cGroupRef, nVlMov += x[nPB_VALOR], 0) }
	Local bMarkMov := {|x, nPos| If ( x[nPB_MARK] == ::cUnChk .And. x[nPB_DATA] == aGrpExt[nCount, nPE_DATA] .And. x[nPB_TYPE] == aGrpExt[nCount, nPE_TYPE] .And. x[nPB_GROUP_REF] == cGroupRef, ::MarkMov(nPos), Nil) }

	// Criar tabela/parametro dos bancos que agrupam
	If ::oParam:cBanco == "001" // Brasil

		For nCount := 1 To Len(aExt)

			If aExt[nCount, nPB_MARK] == ::cUnChk

				// Criar tabela/parametro dos agrupamentos dos codigos do banco x natureza sistema
				If aExt[nCount, nPB_GROUP_REF] $ "0109/0250"

					If (nPos := aScan(aGrpExt, {|x| x[nPE_DATA] == aExt[nCount, nPB_DATA] .And. x[nPE_TYPE] == aExt[nCount, nPB_TYPE] ;
					.And. x[nPE_GROUP_REF] == aExt[nCount, nPB_GROUP_REF] })) > 0

						aGrpExt[nPos, nPE_VALOR] += aExt[nCount, nPB_VALOR]

					Else

						aAdd(aGrpExt, {aExt[nCount, nPB_DATA], aExt[nCount, nPB_TYPE], aExt[nCount, nPB_GROUP_REF], aExt[nCount, nPB_VALOR]})

					EndIf

				EndIf

			EndIf

		Next

		nCount := 1

		While nCount <= Len(aGrpExt)

			nVlMov := 0

			cGroupRef := ""

			If aGrpExt[nCount, nPE_GROUP_REF] == "0109"

				cGroupRef := "P01"

			ElseIf aGrpExt[nCount, nPE_GROUP_REF] == "0250"

				cGroupRef := "2601"

			EndIf

			aEval(aMov, bSumMov)

			If aGrpExt[nCount, nPE_VALOR] == nVlMov

				aEval(aExt, bMarkExt)

				aEval(aMov, bMarkMov)

			EndIf

			nCount++

		EndDo()

	EndIf

Return()


Method SelfMarkLine() Class TWAFConciliacaoBancaria
	Local nCount := 0
	Local nPos := 0
	Local aExt := ::oBrwExt:aCols
	Local aMov := ::oBrwMov:aCols

	For nCount := 1 To Len(aExt)

		If aExt[nCount, nPB_MARK] == ::cUnChk

			If (nPos := aScan(aMov, {|x| x[nPB_MARK] == ::cUnChk .And. x[nPB_DATA] == aExt[nCount, nPB_DATA] .And. ;
			x[nPB_TYPE] == aExt[nCount, nPB_TYPE] .And. x[nPB_VALOR] == aExt[nCount, nPB_VALOR] })) > 0

				::MarkExt(nCount)

				::MarkMov(nPos)

			EndIf

		EndIf

	Next

Return()


Method Validate() Class TWAFConciliacaoBancaria
	Local lRet := .T.

	lRet := ::ExistMarkExt() .And. ::ExistMarkMov() .And. ::VldValue()

Return(lRet)


Method VldValue() Class TWAFConciliacaoBancaria
	Local lRet := .T.

	If !(lRet := ::VlBalance())

		lRet := ::VlTotal() .And. ::VlByGroup()

	EndIf	

Return(lRet)


Method VlBalance() Class TWAFConciliacaoBancaria
	Local lRet := .T.

	lRet := ::nVlSFinExt == ::nVlSFinMov

Return(lRet)



Method VlTotal() Class TWAFConciliacaoBancaria
	Local lRet := .T.

	If ::nVlCExt <> ::nVlCMov .Or. ::nVlDExt <> ::nVlDMov

		lRet := .F.

		MsgAlert("Atenção, valores totais selecionados de crédito e/ou débito não conferem.", TIT_WND)

	EndIf

Return(lRet)


Method VlByGroup() Class TWAFConciliacaoBancaria
	Local lRet := .T.
	Local nCount := 0
	Local nPos := 0
	Local aExt := ::oBrwExt:aCols
	Local aMov := ::oBrwMov:aCols
	Local aGrpExt := {}
	Local nVlMov := 0
	Local bSum := {|x| If ( x[nPB_MARK] == ::cChk .And. x[nPB_DATA] == aGrpExt[nCount, nPE_DATA] .And. x[nPB_TYPE] == aGrpExt[nCount, nPE_TYPE], nVlMov += x[nPB_VALOR], 0) }

	For nCount := 1 To Len(aExt)

		If aExt[nCount, nPB_MARK] == ::cChk

			If (nPos := aScan(aGrpExt, {|x| x[nPE_DATA] == aExt[nCount, nPB_DATA] .And. x[nPE_TYPE] == aExt[nCount, nPB_TYPE] })) > 0

				aGrpExt[nPos, nPE_VALOR] += aExt[nCount, nPB_VALOR]

			Else

				aAdd(aGrpExt, {aExt[nCount, nPB_DATA], aExt[nCount, nPB_TYPE], aExt[nCount, nPB_GROUP], aExt[nCount, nPB_VALOR]})

			EndIf

		EndIf

	Next

	nCount := 1

	While nCount <= Len(aGrpExt) .And. lRet

		nVlMov := 0

		aEval(aMov, bSum)

		If aGrpExt[nCount, nPE_VALOR] <> nVlMov

			lRet := .F.

			MsgAlert(::GetMsg(aGrpExt[nCount, nPE_DATA], aGrpExt[nCount, nPE_TYPE], aGrpExt[nCount, nPE_VALOR], nVlMov), TIT_WND)

		EndIf

		nCount++

	EndDo()

Return(lRet)


Method GetMsg(dDtExt, cTypeExt, nVlExt, nVlMov) Class TWAFConciliacaoBancaria
	Local cRet := ""

	cRet := '<p>
	cRet += '	<span>Atenção, o valor de </span><span style="font-weight:bold;">'+ If (cTypeExt == "P", "débito", "crédito") +'</span>
	cRet += '	<span> no extrato do dia </span><span style="font-weight:bold;">'+ dToC(dDtExt) +'</span>
	cRet += '	<span> não confere com o movimento bancário.</span>
	cRet += '</p>
	cRet += '<p><span style="font-weight:bold;">Extrato: </span><span>R$ '+ AllTrim(Transform(nVlExt, PesqPict("SE5", "E5_VALOR"))) +'</span></p>
	cRet += '<p><span style="font-weight:bold;">Movimento: </span><span>R$ '+ AllTrim(Transform(nVlMov, PesqPict("SE5", "E5_VALOR"))) +'</span></p>
	cRet += '<p><span style="font-weight:bold;">Diferença: </span><span style='+ Chr(34) + 'color:' + If (nVlExt - nVlMov > 0, 'blue;', 'red;') + Chr(34) + '>'
	cRet += 'R$ ' + AllTrim(Transform(nVlExt - nVlMov, PesqPict("SE5", "E5_VALOR"))) +'</span></p>

Return(cRet)


Method Confirm() Class TWAFConciliacaoBancaria

	If ::Validate()

		If MsgYesNo("Deseja realmente conciliar os itens selecionados?", TIT_WND)

			U_BIAMsgRun("Conciliando itens...", "Aguarde!", {|| ::Reconcile() })

			::Refresh()						

		EndIf

	EndIf 

Return()


Method BankMove() Class TWAFConciliacaoBancaria
	Local oParam := TParBankMove():New()

	oParam:cBanco := ::oParam:cBanco
	oParam:cAgencia := ::oParam:cAgencia
	oParam:cConta := ::oParam:cConta
	oParam:dData := ::oParam:dDataDe

	If oParam:Box()

		U_BIAMsgRun("Adicionando Movimento Bancário...", "Aguarde!", {|| ::AddBankMove(oParam) })

	EndIf

Return()


Method AddBankMove(oParam) Class TWAFConciliacaoBancaria
	Local oObj := TAFMovimentoBancario():New()

	oObj:cRecPag := SubStr(oParam:cTipo, 1, 1)
	oObj:dData := oParam:dData
	oObj:dDigit := oParam:dData
	oObj:dDispo := oParam:dData
	oObj:cMoeda := oParam:cMoeda
	oObj:nValor := oParam:nValor
	oObj:cNatureza := oParam:cNatureza
	oObj:cBanco := oParam:cBanco
	oObj:cAgencia := oParam:cAgencia
	oObj:cConta := oParam:cConta
	oObj:cHistorico := oParam:cHistorico
	oObj:cCentroCusto := oParam:cCentroCusto
	oObj:cClasseValor := oParam:cClasseValor
	oObj:nIdApi := oParam:nIdApi

	If oObj:Insert()

		::Refresh()

	EndIf

Return()


Method BankTransfer() Class TWAFConciliacaoBancaria
	Local dAuxAux := dDataBase
	Local oParam := TParBankTransfer():New()

	dDataBase := ::oParam:dDataDe

	// Seta propriedades para validacao
	oParam:cBanco := ::oParam:cBanco
	oParam:cAgencia := ::oParam:cAgencia
	oParam:cConta := ::oParam:cConta
	oParam:dData := ::oParam:dDataDe

	If oParam:Box()

		U_BIAMsgRun("Adicionando Transferência Bancária...", "Aguarde!", {|| ::AddBankTransfer(oParam) })

	EndIf

	dDataBase := dAuxAux	

Return()


Method AddBankTransfer(oParam) Class TWAFConciliacaoBancaria
	Local oObj := TAFMovimentoBancario():New()

	oObj:cBcoOri := oParam:cBcoOri
	oObj:cAgOri := oParam:cAgOri
	oObj:cCcOri := oParam:cCcOri
	oObj:cNatOri := oParam:cNatOri
	oObj:cBcoDes := oParam:cBcoDes
	oObj:cAgDes := oParam:cAgDes
	oObj:cCcDes := oParam:cCcDes
	oObj:cNatDes := oParam:cNatDes
	oObj:cTipTra := oParam:cTipTra
	oObj:cNumChe := oParam:cNumChe
	oObj:nValor := oParam:nValor
	oObj:cHistorico := oParam:cHistorico
	oObj:cBenef := oParam:cBenef

	If oObj:Transfer()

		::Refresh()

	EndIf

Return()


Method ReplicateBankStatement() Class TWAFConciliacaoBancaria
	Local oParam := Nil
	Local nPos := 0

	If ::VldReplicateBankStatement(@nPos)		

		oParam := TParBankMove():New()

		oParam:cBanco := ::oParam:cBanco
		oParam:cAgencia := ::oParam:cAgencia
		oParam:cConta := ::oParam:cConta
		oParam:dData := ::oBrwExt:aCols[nPos, nPB_DATA]
		oParam:cTipo := If (::oBrwExt:aCols[nPos, nPB_TYPE] == "P", "Pagar", "Receber")
		oParam:nValor := ::oBrwExt:aCols[nPos, nPB_VALOR]
		oParam:nIdApi := ::oBrwExt:aCols[nPos, nPB_RECNO]
		oParam:lEnable := .F.

		If oParam:Box()

			U_BIAMsgRun("Replicando Extrato Bancário...", "Aguarde!", {|| ::AddBankMove(oParam) })

		EndIf

	EndIf

Return()


Method VldReplicateBankStatement(nPos) Class TWAFConciliacaoBancaria
	Local lRet := .T.
	Local nPos := 0
	Local nCount := 0
	Local bMarkCount := {|x| If (x[nPB_MARK] == ::cChk, nCount++, 0) }

	If (lRet := ::ExistMarkExt())

		aEval(::oBrwExt:aCols, bMarkCount)

		If nCount > 1

			lRet := .F.

			MsgAlert("Atenção, não é permitido selecionar mais de um item na rotina de replicação de extrato bancário.", TIT_WND)

		ElseIf ::BankStatementReplicated(nPos := aScan(::oBrwExt:aCols, {|x| x[nPB_MARK] == ::cChk }))

			lRet := .F.

			MsgAlert("Atenção, o item selecionado no extrato bancário já foi replicado.", TIT_WND)

		EndIf

	EndIf

Return(lRet)


Method BankStatementReplicated(nPos) Class TWAFConciliacaoBancaria
	Local lRet := .T.
	Local nId := ::oBrwExt:aCols[nPos, nPB_RECNO]
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT COUNT(E5_YIDAPIF) AS COUNT "
	cSQL += " FROM " + RetSQLName("SE5")

	If ::cVwTypeMov == "E"

		cSQL += " WHERE E5_FILIAL = " + ValToSQL(xFilial("SE5"))

	ElseIf ::cVwTypeMov == "C"

		cSQL += " WHERE E5_FILIAL BETWEEN " + ValToSQL(Space(Len(cFilAnt))) + " AND " + ValToSQL(Replicate("Z", Len(cFilAnt)))

	EndIf

	cSQL += " AND E5_SITUACA <> 'C' "
	cSQL += " AND E5_BANCO = " + ValToSQL(::oParam:cBanco)
	cSQL += " AND E5_AGENCIA = " + ValToSQL(::oParam:cAgencia)
	cSQL += " AND E5_CONTA = " + ValToSQL(::oParam:cConta)
	cSQL += " AND E5_RECPAG = 'P' "
	cSQL += " AND E5_YIDAPIF = " + ValToSQL(nId)
	cSQL += " AND D_E_L_E_T_ = ''

	TcQuery cSQL New Alias (cQry)

	lRet := (cQry)->COUNT >= 1

	(cQry)->(DbCloseArea())						

Return(lRet)


Method Reconcile() Class TWAFConciliacaoBancaria
	Local aArea := GetArea()
	Local nCount := 0
	Local nX

	Begin Transaction

		For nCount := 1 To Len(::oBrwExt:aCols)

			If ::oBrwExt:aCols[nCount, nPB_MARK] == ::cChk

				::UpdateExt(::oBrwExt:aCols[nCount, nPB_RECNO])

			EndIf

		Next

		nCount := 0

		For nCount := 1 To Len(::oBrwMov:aCols)

			If ::oBrwMov:aCols[nCount, nPB_MARK] == ::cChk					

				If Empty(::oBrwMov:aCols[nCount, nPB_GROUP])

					::UpdateMov(::oBrwMov:aCols[nCount, nPB_RECNO])

				Else

					For nX := 1 To Len(::aMov)

						If ::aMov[nX, nPM_DATA] == ::oBrwMov:aCols[nCount, nPB_DATA] .And. ::aMov[nX, nPM_GROUP] == ::oBrwMov:aCols[nCount, nPB_GROUP]

							::UpdateMov(::aMov[nX, nPM_RECNO])

						EndIf					

					Next

				EndIf

			EndIf

		Next

	End Transaction

	RestArea(aArea)

Return()


Method UpdateExt(nId) Class TWAFConciliacaoBancaria

	DbSelectArea("ZK4")
	ZK4->(DbGoTo(nId))

	RecLock("ZK4", .F.)

	ZK4->ZK4_RECONC := "S"

	ZK4->(MsUnLock())

Return()


Method UpdateMov(nId) Class TWAFConciliacaoBancaria

	DbSelectArea("SE5")
	SE5->(DbGoTo(nId))

	RecLock("SE5", .F.)

	SE5->E5_RECONC := "x"

	SE5->(MsUnLock())

Return()


Method ParamBox() Class TWAFConciliacaoBancaria

	If ::oParam:Box()

		::Refresh()

	EndIf

Return()


Method Refresh() Class TWAFConciliacaoBancaria
	Local bRefresh := {|| .T. }

	bRefresh := {|| ::oWindow:SetTitle(::GetWindowTitle()),;
	::GetBalance(), ::oSayTotExt:cCaption := ::GetTotalValue(BRW_EXT), ::oSayTotMov:cCaption := ::GetTotalValue(BRW_MOV),;
	::oBrwExt:SetArray(::GetFieldData(BRW_EXT)), ::SetHeaderImage(::oBrwExt, ::oFldExt), ::oBrwExt:Refresh(),;
	::lMarkAllExt := .F., ::oChkExt:Refresh(), ::nVlCExt := 0, ::nVlDExt := 0, ::oSayExt:cCaption := ::GetValue(BRW_EXT),;
	::oBrwMov:SetArray(::GetFieldData(BRW_MOV)), ::SetHeaderImage(::oBrwMov, ::oFldMov), ::oBrwMov:Refresh(),; 
	::lMarkAllMov := .F., ::oChkMov:Refresh(), ::nVlCMov := 0, ::nVlDMov := 0, ::oSayMov:cCaption := ::GetValue(BRW_MOV),;
	::SelfMark() }

	U_BIAMsgRun("Atualizando dados...", "Aguarde!", {|| Eval(bRefresh) })

Return()