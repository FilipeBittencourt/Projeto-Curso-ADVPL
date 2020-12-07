#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWCancelarEliminacaoResiduo
@author Tiago Rossini Coradini
@since 28/11/2016
@version 1.0
@description Classe (tela) para efetuar cancelamento de eliminação de resíduo (Pedidos de venda) 
@obs OS: 3844-16 - Ranisses Corona
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

// PERCENTUAL DAS JANELAS
#DEFINE PER_WIN 100

// IDENTIFICADORES DE JANELA
#DEFINE WND "WND"

// TITULOS DAS JANELAS
#DEFINE TIT_MAIN_WND "Cancelamento de Eliminação de Resíduo"
#DEFINE TIT_WND "Pedidos de Venda Eliminados por Resíduo"

// DESCRICAO E IMAGENS DOS BOTOES DA BARRA PRINCIPAL (oBtnBar)
#DEFINE DSC_BTN_CANC_RES "Cancelar Eli."
#DEFINE HINT_BTN_CANC_RES "Cancelar Eliminação de Resíduo"
#DEFINE DSC_BTN_SEARCH "Pesquisar"
#DEFINE DSC_BTN_CLOSE "Sair"

// INDICES DO ARRAY DE COLUNAS BO BROWSER DE PEDIDOS
#DEFINE nF_CHECK 1
#DEFINE nF_PEDIDO 2
#DEFINE nF_ITEM 3
#DEFINE nF_PRODUTO 4
#DEFINE nF_QTD 5
#DEFINE nF_EMISSAO 6
#DEFINE nF_DTRESI 7
#DEFINE nF_CLIENTE 8
#DEFINE nF_LOJA 9
#DEFINE nF_NOME 10
#DEFINE nF_MOTIVO 11
#DEFINE nF_DESMOT 12

Class TWCancelarEliminacaoResiduo From LongClassName

	// Msdialog
	Data oDlg 

	// Layer 
	Data oLayer

	// Array com a coordenadas de tela
	Data aCoors

	Data oBtnBar // Barra de Botoes 	

	// Paineis
	Data oPnl

	// CheckBox
	Data cChk
	Data cUnChk
	Data oChk // CheckBox para marcao
	Data lChkAll	// Variavel de controle de marcacao de todos os itens	

	// MsNewGetDados
	Data oBrw // Browse (MsNewGetDados) - Vendedor Origem	
	Data oField // Objeto (TGDField) para criacao dinamica das colunas Header

	Data oParam // Objeto de parametros

	Method New() Constructor // Metodo construtor
	Method LoadInterface() // Carrega a interface principal
	Method LoadDialog() // Carrega Dialog principal
	Method LoadLayer() // Carrega Layer principal
	Method LoadLine() // Carrega a interface da linha
	Method LoadButtonBar() // Carrega barra de botoes
	Method Activate() // Ativa exibicao do objeto	
	Method SetWinFont(cIDCol, cIDWin, cIDLin) // Seta fonte da janela 
	Method GetHeader() // Retorna configurações dos campos - aHeader
	Method GetData() // Reotorna dados dos pedidos 
	Method Mark() // Efetua marcacao
	Method MarkAll() // Efetua marcacao de todos os itens
	Method ExistMark() // Verifica se existe algum item marcado
	Method Cancel() // Cancelar
	Method CancelRes() // Cancelar Eliminação de Resíduo
	Method Update(cPedido, cItem, cProduto) // Atualiza campos referentes a eliminação de resíduo	
	Method Refresh() // Atualiza dados do grid
	Method Search() // Pesquisa

EndClass


// construtor da classe
Method New() Class TWCancelarEliminacaoResiduo

	::oDlg := Nil
	::oLayer := Nil	
	::aCoors := {}

	::oBtnBar := Nil

	::oPnl := Nil

	::cChk := "WFCHK"
	::cUnChk := "WFUNCHK"	
	::oChk := Nil
	::lChkAll := .F.	

	::oBrw := Nil	
	::oField := TGDField():New()

	::oParam := TParBIAF054():New()

Return()


// Contrutor da interface
Method LoadInterface() Class TWCancelarEliminacaoResiduo

	::LoadDialog()

	::LoadLayer()

	::LoadLine()

	::LoadButtonBar()

Return()


Method LoadDialog() Class TWCancelarEliminacaoResiduo

	::aCoors := FWGetDialogSize(oMainWnd)			

	::oDlg := MsDialog():Create()
	::oDlg:cName := "oDlg"
	::oDlg:cCaption := TIT_MAIN_WND 
	::oDlg:nTop := ::aCoors[1]
	::oDlg:nLeft := ::aCoors[2]
	::oDlg:nHeight := ::aCoors[3]
	::oDlg:nWidth := ::aCoors[4]
	::oDlg:lMaximized := .T.
	::oDlg:lEscClose := .T.		

Return()


Method LoadLayer() Class TWCancelarEliminacaoResiduo

	::oLayer := FWLayer():New()
	::oLayer:Init(::oDlg)

Return()


// Carrega linha
Method LoadLine() Class TWCancelarEliminacaoResiduo
	Local cVldDef := "AllwaysTrue"

	::oLayer:AddLine(LIN, PER_LIN, .F.)

	::oLayer:AddCollumn(COL, PER_COL, .T., LIN)

	::oLayer:AddWindow(COL, WND, TIT_WND, PER_WIN, .F. ,.T.,, LIN, { || })

	::oPnl := ::oLayer:GetWinPanel(COL, WND, LIN)

	::SetWinFont(COL, WND, LIN)

	::oChk := TCheckBox():Create(::oPnl)
	::oChk:cName := 'oChk'
	::oChk:cCaption := "Marca / Desmarca todos"
	::oChk:nLeft := 05
	::oChk:nTop := 210
	::oChk:nWidth := 300
	::oChk:nHeight := 17
	::oChk:lShowHint := .T.
	::oChk:cVariable := "::lChkAll"
	::oChk:bSetGet := bSetGet(::lChkAll)
	::oChk:Align := CONTROL_ALIGN_TOP
	::oChk:lVisibleControl := .T.
	::oChk:bChange:= {|| ::MarkAll() }

	::oBrw := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", {},,, cVldDef,, cVldDef, ::oPnl, ::GetHeader(), ::GetData())
	::oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrw:oBrowse:bLDblClick := {|| ::Mark() }
	::oBrw:oBrowse:lVScroll := .T.
	::oBrw:oBrowse:lHScroll := .T.

Return()


Method LoadButtonBar() Class TWCancelarEliminacaoResiduo

	::oBtnBar := FWButtonBar():New()		

	::oBtnBar:Init(::oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)

	::oBtnBar:AddBtnText(DSC_BTN_CLOSE, DSC_BTN_CLOSE, {|| ::oDlg:End() },,,CONTROL_ALIGN_RIGHT, .T.)
	::oBtnBar:AddBtnText(DSC_BTN_SEARCH, DSC_BTN_SEARCH, {|| ::Search() },,,CONTROL_ALIGN_RIGHT, .T.)
	::oBtnBar:AddBtnText(DSC_BTN_CANC_RES, HINT_BTN_CANC_RES, {|| ::Cancel() },,,CONTROL_ALIGN_RIGHT, .T.)		

Return()


Method Activate() Class TWCancelarEliminacaoResiduo	

	::LoadInterface()

	//::oDlg:bInit := {|| ::Refresh()}	
	::oDlg:Activate()

Return()


Method SetWinFont(cIDCol, cIDWin, cIDLin) Class TWCancelarEliminacaoResiduo
	Local oWindow := Nil

	::oLayer:GetWindow(cIDCol, cIDWin, @oWindow, cIDLin)

	oWindow:oTitleBar:oFont := TFont():New("MS Sans Serif",,18,,.T.)

Return()


Method GetHeader() Class TWCancelarEliminacaoResiduo

	::oField:Clear()

	// Adciona coluna para tratamento de marcacao no grid
	::oField:AddField("C5_FILIAL") 	
	::oField:FieldName("C5_FILIAL"):cTitle := ""
	::oField:FieldName("C5_FILIAL"):cPict := "@BMP"
	::oField:FieldName("C5_FILIAL"):cName := "_MARK"		

	::oField:AddField("C5_NUM")
	::oField:AddField("C6_ITEM")
	::oField:AddField("C6_PRODUTO")

	::oField:AddField("C6_QTDVEN")
	::oField:FieldName("C6_QTDVEN"):cTitle := "Saldo Res."

	::oField:AddField("C5_EMISSAO")
	::oField:AddField("C6_YDTRESI")	
	::oField:AddField("C5_CLIENTE")
	::oField:AddField("C5_LOJACLI")
	::oField:AddField("A1_NOME")
	::oField:AddField("C6_YMOTIVO")
	::oField:AddField("X5_DESCRI")

Return(::oField:GetHeader())


Method Mark() Class TWCancelarEliminacaoResiduo

	If ::oBrw:aCols[::oBrw:nAt, nF_CHECK] == ::cChk
		::oBrw:aCols[::oBrw:nAt, nF_CHECK] := ::cUnChk
	Else
		::oBrw:aCols[::oBrw:nAt, nF_CHECK] := ::cChk
	EndIf			

Return()


Method MarkAll() Class TWCancelarEliminacaoResiduo
	Local nCount := 0

	For nCount := 1 To Len(::oBrw:aCols)

		If ::lChkAll
			::oBrw:aCols[nCount, nF_CHECK] := ::cChk
		Else
			::oBrw:aCols[nCount, nF_CHECK] := ::cUnChk
		EndIf

	Next

	::oBrw:oBrowse:Refresh()

Return()


Method ExistMark() Class TWCancelarEliminacaoResiduo
	Local lRet := .F.

	lRet := aScan(::oBrw:aCols, {|x| x[nF_CHECK] == ::cChk }) > 0

Return(lRet)


Method GetData() Class TWCancelarEliminacaoResiduo
	Local aCols := {}
	Local cSQL := ""
	Local cSC5 := RetSQLName("SC5")
	Local cSC6 := RetSQLName("SC6")
	Local cSA1 := RetSQLName("SA1")
	Local cSX5 := RetSQLName("SX5")
	Local cQry := GetNextAlias()	

	cSQL := " SELECT C5_NUM, C6_ITEM, C6_PRODUTO, ROUND(C6_QTDVEN - C6_QTDENT, 2) AS C6_QTDVEN, C5_EMISSAO, C6_YDTRESI, " 
	cSQL += "	CASE WHEN C5_YCLIORI = '' THEN C5_CLIENTE ELSE C5_YCLIORI END AS C5_CLIENTE, " 
	cSQL += "	CASE WHEN C5_YLOJORI = '' THEN C5_LOJACLI ELSE C5_YLOJORI END AS C5_LOJACLI, "
	cSQL += "	( "
	cSQL += "		SELECT A1_NOME "
	cSQL += "		FROM "+ cSA1
	cSQL += "		WHERE A1_COD = CASE WHEN C5_YCLIORI = '' THEN C5_CLIENTE ELSE C5_YCLIORI END "
	cSQL += "		AND A1_LOJA = CASE WHEN C5_YLOJORI = '' THEN C5_LOJACLI ELSE C5_YLOJORI END "
	cSQL += "		AND D_E_L_E_T_ = '' "
	cSQL += "	) AS A1_NOME, C6_YMOTIVO, "
	cSQL += " ( "
	cSQL += "		SELECT X5_DESCRI "
	cSQL += "		FROM "+ cSX5
	cSQL += "		WHERE X5_FILIAL = "+ ValToSQL(xFilial("SX5")) 
	cSQL += "		AND X5_TABELA = 'ZZ' "
	cSQL += "		AND X5_CHAVE = C6_YMOTIVO " 
	cSQL += "		AND D_E_L_E_T_ = '' "
	cSQL += "	) AS X5_DESCRI "
	cSQL += "	FROM "+ cSC5 +" SC5 "
	cSQL += "	INNER JOIN "+ cSC6 +" SC6 "
	cSQL += "	ON C5_NUM = C6_NUM "
	cSQL += "	WHERE C5_FILIAL = "+ ValToSQL(xFilial("SC5"))
	cSQL += "	AND C5_NUM BETWEEN "+ ValToSQL(::oParam:cNumPedDe) +" AND "+ ValToSQL(::oParam:cNumPedAte)
	cSQL += "	AND C5_EMISSAO BETWEEN "+ ValToSQL(::oParam:dDatEmiDe) +" AND "+ ValToSQL(::oParam:dDatEmiAte)
	cSQL += "	AND CASE WHEN C5_YCLIORI = '' THEN C5_CLIENTE ELSE C5_YCLIORI END BETWEEN "+ ValToSQL(::oParam:cCodCliDe) +" AND "+ ValToSQL(::oParam:cCodCliAte)
	cSQL += "	AND SC5.D_E_L_E_T_ = '' "
	cSQL += "	AND C6_FILIAL = "+ ValToSQL(xFilial("SC6"))
	cSQL += "	AND C6_BLQ = 'R' "
	cSQL += "	AND C6_YDTRESI <> '' "
	cSQL += "	AND C6_YMOTIVO <> '' "
	cSQL += "	AND C6_PRODUTO BETWEEN "+ ValToSQL(::oParam:cCodPrdDe) +" AND "+ ValToSQL(::oParam:cCodPrdAte)
	cSQL += "	AND C6_YDTRESI BETWEEN "+ ValToSQL(::oParam:dDatResDe) +" AND "+ ValToSQL(::oParam:dDatResAte)
	cSQL += "	AND SC6.D_E_L_E_T_ = '' "
	cSQL += "	ORDER BY C5_NUM, C6_YDTRESI, C6_PRODUTO "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())	

		aAdd(aCols, { ::cUnChk, (cQry)->C5_NUM, (cQry)->C6_ITEM, (cQry)->C6_PRODUTO, (cQry)->C6_QTDVEN, sToD((cQry)->C5_EMISSAO), sToD((cQry)->C6_YDTRESI),;
		(cQry)->C5_CLIENTE, (cQry)->C5_LOJACLI, (cQry)->A1_NOME, (cQry)->C6_YMOTIVO, (cQry)->X5_DESCRI, .F.})								 								

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(aCols)


Method Cancel() Class TWCancelarEliminacaoResiduo
	Local nCount := 0
	Local aColsVOri := {}

	If ::ExistMark()

		If MsgYesNo("Atenção, deseja realmente Cancelar a Eliminação de Resíduo dos itens marcados?")

			U_BIAMsgRun("Cancelando Eliminação de Resíduo...", "Aguarde!", {|| ::CancelRes() })

			U_BIAMsgRun("Atualizando lista de Pedidos de Venda...", "Aguarde!", {|| ::Refresh() })

		EndIf				

	Else
		MsgStop("Não existem itens selecionados para Cancelamento!")
	EndIf

Return()


Method CancelRes() Class TWCancelarEliminacaoResiduo
	Local nCount := 0

	For nCount := 1 To Len(::oBrw:aCols)

		If ::oBrw:aCols[nCount, nF_CHECK] == ::cChk

			::Update(::oBrw:aCols[nCount, nF_PEDIDO], ::oBrw:aCols[nCount, nF_ITEM], ::oBrw:aCols[nCount, nF_PRODUTO])					

		EndIf

	Next

Return()


Method Update(cPedido, cItem, cProduto) Class TWCancelarEliminacaoResiduo

	Local cSQL := ""
	Local aAreaC5 := SC5->(GetArea())
	Local dData := Date()
	Local aData := {}
	GetTimeStamp(dData , aData)

	BEGIN TRANSACTION

	// Atualiza empresa corrente
	cSQL := " UPDATE "+ RetSqlName("SC6")
	cSQL += " SET C6_YDTRESI = '' "
	cSQL += " ,C6_YMOTIVO = '' "
	cSQL += " ,C6_BLQ = '' "
	cSQL += " WHERE	C6_FILIAL	= "+ ValToSQL(xFilial("SC6"))
	cSQL += "	AND C6_NUM = "+ ValToSQL(cPedido)
	cSQL += "	AND C6_ITEM = "+ ValToSQL(cItem)
	cSQL += "	AND C6_PRODUTO = "+ ValToSQL(cProduto)		
	cSQL += "	AND D_E_L_E_T_ = ''

	TcSQLExec(cSQL)

	CONOUT( aData[1] + " " + Time() + "CANCELAMENTO DE ELIMINACAO DE RESIDUO "+ RetSqlName("SC6") +":"+ cSQL)

	// Atualiza empresa LM
	cSQL := " UPDATE SC6070 "
	cSQL += " SET C6_YDTRESI = '' "
	cSQL += " ,C6_YMOTIVO = '' "
	cSQL += " ,C6_BLQ 	 = '' "
	cSQL += " ,C6_MSEXP  = '' "	
	cSQL += " FROM SC5070 SC5 "
	cSQL += " INNER JOIN SC6070 SC6 "
	cSQL += " ON C5_NUM = C6_NUM "
	cSQL += " WHERE C5_FILIAL	= '01' " 
	cSQL += " AND C5_YPEDORI = "+ ValToSQL(cPedido)
	cSQL += " AND C5_YEMPPED = "+ ValToSQL(cEmpAnt)
	cSQL += " AND C6_FILIAL	= '01' "
	cSQL += " AND C6_NUM = C5_NUM "
	cSQL += " AND C6_ITEM = "+ ValToSQL(cItem)
	cSQL += " AND C6_PRODUTO = "+ ValToSQL(cProduto)
	cSQL += " AND SC5.D_E_L_E_T_ = '' "
	cSQL += " AND SC6.D_E_L_E_T_ = '' "		

	TcSQLExec(cSQL)
	
	CONOUT( aData[1] + " " + Time() + "CANCELAMENTO DE ELIMINACAO DE RESIDUO LM:"+ cSQL)		

	END TRANSACTION

	//Fernando/Facile em 05/05/2017 - Se deseliminar o residuo tem que recalcular as Baixas de AI
	SC5->(DbSetOrder(1))
	If SC5->(DbSeek(XFilial("SC5")+cPedido)) .And. !(AllTrim(CEMPANT) $ '14')

		If !Empty(SC5->C5_YNUMSI)
			//se existir baixa de AI do pedido exclui
			U_AIEXCBX(SC5->C5_NUM, SC5->C5_YLINHA, SC5->C5_YNUMSI, SC5->C5_CLIENTE, SC5->C5_YEMPPED)
			//incluir nova baixa para itens restantes do pedido
			U_AO_INCBX(SC5->C5_NUM,SC5->C5_YNUMSI)
		EndIf

		If !Empty(SC5->C5_YNOUTAI)
			//se existir baixa de AI do pedido exclui
			U_AIEXCBX(SC5->C5_NUM, SC5->C5_YLINHA, SC5->C5_YNOUTAI, SC5->C5_CLIENTE, SC5->C5_YEMPPED)
			//incluir nova baixa para itens restantes do pedido
			U_AO_INCBX(SC5->C5_NUM,SC5->C5_YNOUTAI,"Baixa.Aut.Ped.c/Desc.", 2)
		EndIf

	EndIf

	RestArea(aAreaC5)

Return()


Method Refresh() Class TWCancelarEliminacaoResiduo

	::lChkAll := .F.

	::oBrw:SetArray(::GetData())
	::oBrw:Refresh()				

Return()


Method Search() Class TWCancelarEliminacaoResiduo
	Local lRet := .F.

	If ::oParam:Box()

		lRet := .T.				

		U_BIAMsgRun("Atualizando lista de Pedidos de Venda...", "Aguarde!", {|| ::Refresh() })

	EndIf

Return(lRet)