#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWHistoricoReservaEstoque
@author Tiago Rossini Coradini
@since 09/05/2018
@version 1.0
@description Classe (tela) para visualizar o historico de alteracoes de reserva de estoque 
@obs Ticket: 319
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
#DEFINE TIT_MAIN_WND "Histórico da Reserva"

// DESCRICAO E IMAGENS DOS BOTOES DA BARRA PRINCIPAL (oBtnBar)
#DEFINE DSC_BTN_CLOSE "Sair"


Class TWHistoricoReservaEstoque From LongClassName

	// Msdialog
	Data oDlg 
	
	// Layer 
	Data oLayer
	
	// Array com a coordenadas de tela
	Data aCoors

	Data oBtnBar // Barra de Botoes 	

	// Paineis
	Data oPnl
	
	Data cProduto
	Data cDescProd
	Data cLote

	// MsNewGetDados
	Data oBrw // Browse (MsNewGetDados) - Vendedor Origem	
	Data oField // Objeto (TGDField) para criacao dinamica das colunas Header	
		
	Method New(cProduto, cDescProd, cLote) Constructor // Metodo construtor
	Method LoadInterface() // Carrega a interface principal
	Method LoadDialog() // Carrega Dialog principal
	Method LoadLayer() // Carrega Layer principal
	Method LoadLine() // Carrega a interface da linha
	Method LoadButtonBar() // Carrega barra de botoes
	Method Activate() // Ativa exibicao do objeto	
	Method SetWinFont(cIDCol, cIDWin, cIDLin) // Seta fonte da janela 
	Method GetHeader() // Retorna configurações dos campos - aHeader
	Method GetData() // Reotorna dados dos pedidos 
	
EndClass


// construtor da classe
Method New(cProduto, cDescProd, cLote) Class TWHistoricoReservaEstoque
	
	::oDlg := Nil
	::oLayer := Nil	
	::aCoors := {}
		
	::oBtnBar := Nil
		
	::oPnl := Nil

	::oBrw := Nil
	
	::cProduto := cProduto
	::cDescProd := cDescProd
	::cLote := cLote
		
	::oField := TGDField():New()
		
Return()


// Contrutor da interface
Method LoadInterface() Class TWHistoricoReservaEstoque
	
	::LoadDialog()

	::LoadButtonBar()
	
	::LoadLayer()
	
	::LoadLine()	
			
Return()


Method LoadDialog() Class TWHistoricoReservaEstoque
	
	::aCoors := FWGetDialogSize(oMainWnd)			
		
	::oDlg := MsDialog():Create()
	::oDlg:cName := "oDlg"
	::oDlg:cCaption := TIT_MAIN_WND 
	::oDlg:nTop := ::aCoors[1]
	::oDlg:nLeft := ::aCoors[2]
	::oDlg:nHeight := ::aCoors[3] / 2
	::oDlg:nWidth := ::aCoors[4] / 2
	::oDlg:lCentered := .T.
	
Return()


Method LoadLayer() Class TWHistoricoReservaEstoque

	::oLayer := FWLayer():New()
	::oLayer:Init(::oDlg)

Return()


// Carrega linha
Method LoadLine() Class TWHistoricoReservaEstoque
Local cVldDef := "AllwaysTrue"

	::oLayer:AddLine(LIN, PER_LIN, .F.)
	
	::oLayer:AddCollumn(COL, PER_COL, .T., LIN)
	
	::oLayer:AddWindow(COL, WND, "Produto: " + ::cProduto + " - " + AllTrim(::cDescProd) + " -- Lote: " + AllTrim(::cLote), PER_WIN, .F. ,.T.,, LIN, { || })
	
	::oPnl := ::oLayer:GetWinPanel(COL, WND, LIN)
		 
	::SetWinFont(COL, WND, LIN)
	
	::oBrw := MsNewGetDados():New(0, 0, 0, 0, 0, cVldDef, cVldDef, "", {},,, cVldDef,, cVldDef, ::oPnl, ::GetHeader(), ::GetData())
	::oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrw:oBrowse:lVScroll := .T.
	::oBrw:oBrowse:lHScroll := .T.
					
Return()


Method LoadButtonBar() Class TWHistoricoReservaEstoque
	
	::oBtnBar := FWButtonBar():New()		
	
	::oBtnBar:Init(::oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)
		
	::oBtnBar:AddBtnText(DSC_BTN_CLOSE, DSC_BTN_CLOSE, {|| ::oDlg:End() },,,CONTROL_ALIGN_RIGHT, .T.)

Return()


Method Activate() Class TWHistoricoReservaEstoque	
	
	::LoadInterface()

	::oDlg:Activate()
			
Return()


Method SetWinFont(cIDCol, cIDWin, cIDLin) Class TWHistoricoReservaEstoque
Local oWindow := Nil
	
	::oLayer:GetWindow(cIDCol, cIDWin, @oWindow, cIDLin)
		
	oWindow:oTitleBar:oFont := TFont():New("MS Sans Serif",,18,,.T.)
	
Return()


Method GetHeader() Class TWHistoricoReservaEstoque

	::oField:Clear()
		
	::oField:AddField("ZCD_DATA")
	::oField:AddField("ZCD_HORA")
	::oField:AddField("ZCD_TIPO")
	::oField:AddField("ZCD_LOCAL")
	::oField:AddField("ZCD_QTD")
	::oField:AddField("ZCD_USR")
	::oField:AddField("_SPACE_")
		
Return(::oField:GetHeader())


Method GetData() Class TWHistoricoReservaEstoque
Local aCols := {}
Local cSQL := ""
Local cQry := GetNextAlias()	
 
	cSQL := " SELECT ZCD_DATA, ZCD_HORA, ZCD_TIPO, ZCD_LOCAL, ZCD_QTD, ZCD_USR " 
	cSQL += " FROM " + RetSQLName("ZCD")
	cSQL += " WHERE ZCD_FILIAL = " + ValToSQL(xFilial("ZCD"))
	cSQL += " AND ZCD_PRODUT = " + ValToSQL(::cProduto)
	cSQL += " AND ZCD_LOTE = " + ValToSQL(::cLote)
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " ORDER BY ZCD_DATA, ZCD_HORA "

	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())
				
		aAdd(aCols, {sToD((cQry)->ZCD_DATA), (cQry)->ZCD_HORA, (cQry)->ZCD_TIPO, (cQry)->ZCD_LOCAL, (cQry)->ZCD_QTD, (cQry)->ZCD_USR, Space(1), .F.})
								 								
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())
			
Return(aCols)