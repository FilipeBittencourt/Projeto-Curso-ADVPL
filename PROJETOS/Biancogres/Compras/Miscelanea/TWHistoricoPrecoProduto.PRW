#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TWHistoricoPrecoProduto
@author Tiago Rossini Coradini
@since 22/09/2014
@version 1.1
@description Classe para vizualização (tela) do historico de precos de produtos
@obs OS: 1818-14 - Claudia Carvalho
@obs OS: 1615-17 - Claudia Carvalho
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
#DEFINE TIT_MAIN_WND "Visualizador de Histórico de Preços de Produto"
#DEFINE TIT_WND "Produto:"

// TITULOS DA FOLDER
#DEFINE TIT_FOL1 "Notas de Entrada"
#DEFINE TIT_FOL2 "Pedidos de Compra"

// TITULOS DAS COLUNAS - BROWSE DE NOTAS DE ENTRADA
#DEFINE TIT_COL1_BRW_NFE "Empresa"
#DEFINE TIT_COL2_BRW_NFE "Dt. Entrada"
#DEFINE TIT_COL3_BRW_NFE "Tipo NF"
#DEFINE TIT_COL4_BRW_NFE "Documento"
#DEFINE TIT_COL5_BRW_NFE "Serie"
#DEFINE TIT_COL6_BRW_NFE "Fornecedor"
#DEFINE TIT_COL7_BRW_NFE "Loja"
#DEFINE TIT_COL8_BRW_NFE "Quantidade"
#DEFINE TIT_COL9_BRW_NFE "Vlr. Unitário"
#DEFINE TIT_COL10_BRW_NFE "Dt. Emissão"

// TITULOS DAS COLUNAS - BROWSE DE PEDIDOS DE COMPRA
#DEFINE TIT_COL1_BRW_PEDC "Empresa"
#DEFINE TIT_COL2_BRW_PEDC "Dt. Emissão"
#DEFINE TIT_COL3_BRW_PEDC "Numero"
#DEFINE TIT_COL4_BRW_PEDC "Cond. Pagto"
#DEFINE TIT_COL5_BRW_PEDC "Descricao"
#DEFINE TIT_COL6_BRW_PEDC "Fornecedor"
#DEFINE TIT_COL7_BRW_PEDC "Loja"
#DEFINE TIT_COL8_BRW_PEDC "Quantidade"
#DEFINE TIT_COL9_BRW_PEDC "Vlr. Unitário"

Class TWHistoricoPrecoProduto From LongClassName

	// Identificador
	Data cId

	// msdialog
	Data oDlg 
	
	// layer 
	Data oLayer 
	
	// array com a coordenadas de tela
	Data aCoors
	
	// Fontes
	Data oFnt 
	Data oFntBold 
			
	Data oBusiness
	Data oLstNfe // Lista com os campos do browse de notas de entrada
	Data oLstPedC // Lista com os campos do browse de pedidos de compra

	Data oFolder // Folder
	Data oBrwNfe // Browse de Notas de Entrada
	Data oBrwPedC // Browse de Pedidos de Compra
	Data oButtonBar // Barra de botoes
	Data oBtnOk // Botao OK
	
	// paineis
	Data oPnl
	
	Data cPrd
			
	Method New() Constructor // Metodo construtor
	Method LoadInterface() // Carrega a interface principal
	Method LoadDialog() // Carrega Dialog principal
	Method LoadButtonBar() // Carrega barra de botoes	
	Method LoadLayer() // Carrega Layer principal
	Method LoadBrowser() // Carrega Browse com ou sem edição
	Method Activate() // Ativa exibicao do objeto	
	Method GetPrd() // Retorna codigo do produto
			
EndClass


// construtor da classe
Method New(cId) Class TWHistoricoPrecoProduto
	
	::cId := cId	
	::oDlg := Nil
	::oLayer := Nil	
	::aCoors := {}
	::oBusiness := THistoricoPrecoProduto():New()
	::oLstNfe := ArrayList():New()
	::oLstPedC := ArrayList():New()
	::oFolder := Nil
	::oBrwNfe := Nil
	::oBrwPedC := Nil
	::oButtonBar := Nil		
	::oFnt := TFont():New('Arial',,14)
	::oFntBold := TFont():New('Arial',,14,,.T.)	
	::oPnl := Nil	
	::cPrd := ""
	
Return()


// Contrutor da interface
Method LoadInterface() Class TWHistoricoPrecoProduto
	
	::LoadDialog()
	
	::LoadButtonBar()

	::LoadLayer()	
	
	::LoadBrowser()
		
Return()


Method LoadDialog() Class TWHistoricoPrecoProduto
	
	::aCoors := FWGetDialogSize(oMainWnd)	
		
	::oDlg := MsDialog():Create()
	::oDlg:cName := "oDlg"
	::oDlg:cCaption := TIT_MAIN_WND 
	::oDlg:nTop := ::aCoors[1]
	::oDlg:nLeft := ::aCoors[2]
	::oDlg:nHeight := ::aCoors[3] / 1.5
	::oDlg:nWidth := ::aCoors[4] / 1.8
	::oDlg:lShowHint := .F.
	::oDlg:lCentered := .T.
		
Return()


Method LoadButtonBar() Class TWHistoricoPrecoProduto

	::oButtonBar := FWButtonBar():New()
	::oButtonBar:Init(::oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)

	::oButtonBar:AddBtnText("OK", "", {|| ::oDlg:End() },,,CONTROL_ALIGN_LEFT,.T.)
	
Return()


Method LoadLayer() Class TWHistoricoPrecoProduto
Local oWindow := Nil

	::oLayer := FWLayer():New()
	::oLayer:Init(::oDlg,.F.,.T.)

	::oLayer:AddLine(LIN, PER_LIN, .F.)
	::oLayer:AddCollumn(COL, PER_COL, .T., LIN)			
	::oLayer:AddWindow(COL, WND, "Produto: "+ AllTrim(::cPrd) +"-"+ AllTrim(Posicione("SB1", 1, xFilial("SB1") + ::cPrd, "B1_DESC")), 100, .F. ,.T.,, LIN, { || })

	// Muda fonte do Layes
	::oLayer:GetWindow(COL, WND, @oWindow, LIN)			
	oWindow:oTitleBar:oFont := ::oFntBold
		
Return()


// Carrega Browser
Method LoadBrowser() Class TWHistoricoPrecoProduto
	
	// Painel acima
	::oPnl := ::oLayer:GetWinPanel(COL, WND, LIN)
		
	// Folder
	::oFolder := TFolder():New(0, 0, {},,::oPnl,,,,.T.,,0,0)
	::oFolder:Align := CONTROL_ALIGN_ALLCLIENT	
	::oFolder:AddItem(TIT_FOL1, .T.)
	::oFolder:AddItem(TIT_FOL2, .T.)		
		
	::oBrwNfe := TCBrowse():New(00,00,0,0,,,,::oFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.)
	::oBrwNfe:Align := CONTROL_ALIGN_ALLCLIENT
		
	::oLstNfe := ::oBusiness:GetNfe(::cPrd)
	
	::oBrwNfe:AddColumn(TcColumn():New(TIT_COL1_BRW_NFE, {|| ::oLstNfe:GetItem(::oBrwNfe:nAt):cEmp }, "@!",nil,nil,nil,30,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwNfe:AddColumn(TcColumn():New(TIT_COL2_BRW_NFE, {|| ::oLstNfe:GetItem(::oBrwNfe:nAt):cDtEntrada }, "@D",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwNfe:AddColumn(TcColumn():New(TIT_COL3_BRW_NFE, {|| ::oLstNfe:GetItem(::oBrwNfe:nAt):cTipoNF }, "@!",nil,nil,nil,25,.F.,.F.,nil,nil,nil,.F.,nil))	
	::oBrwNfe:AddColumn(TcColumn():New(TIT_COL4_BRW_NFE, {|| ::oLstNfe:GetItem(::oBrwNfe:nAt):cDoc }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwNfe:AddColumn(TcColumn():New(TIT_COL5_BRW_NFE, {|| ::oLstNfe:GetItem(::oBrwNfe:nAt):cSerie }, "@!",nil,nil,nil,20,.F.,.F.,nil,nil,nil,.F.,nil))	
	::oBrwNfe:AddColumn(TcColumn():New(TIT_COL6_BRW_NFE, {|| ::oLstNfe:GetItem(::oBrwNfe:nAt):cFornece }, "@!",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwNfe:AddColumn(TcColumn():New(TIT_COL7_BRW_NFE, {|| ::oLstNfe:GetItem(::oBrwNfe:nAt):cLoja }, "@!",nil,nil,nil,15,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwNfe:AddColumn(TcColumn():New(TIT_COL8_BRW_NFE, {|| ::oLstNfe:GetItem(::oBrwNfe:nAt):nQtd }, "9999999.9999",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwNfe:AddColumn(TcColumn():New(TIT_COL9_BRW_NFE, {|| ::oLstNfe:GetItem(::oBrwNfe:nAt):nVlrUnit }, "9999999.9999",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwNfe:AddColumn(TcColumn():New(TIT_COL10_BRW_NFE, {|| ::oLstNfe:GetItem(::oBrwNfe:nAt):cDtEmissao }, "@D",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwNfe:AddColumn(TcColumn():New("", {|| "" }, "@!",nil,nil,nil,15,.F.,.F.,nil,nil,nil,.F.,nil))
			
	::oBrwNfe:lHScroll := .T.
	::oBrwNfe:lVScroll := .T.	
	
	::oBrwNfe:SetArray(::oLstNfe:ToArray())
	::oBrwNfe:Refresh()
		
	::oBrwPedC := TCBrowse():New(00,00,0,0,,,,::oFolder:aDialogs[2],,,,,,,,,,,,.F.,,.T.,,.F.)
	::oBrwPedC:Align := CONTROL_ALIGN_ALLCLIENT
		
	::oLstPedC := ::oBusiness:GetPedC(::cPrd)
	
	::oBrwPedC:AddColumn(TcColumn():New(TIT_COL1_BRW_PEDC, {|| ::oLstPedC:GetItem(::oBrwPedC:nAt):cEmp }, "@!",nil,nil,nil,30,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwPedC:AddColumn(TcColumn():New(TIT_COL2_BRW_PEDC, {|| ::oLstPedC:GetItem(::oBrwPedC:nAt):cDtEmissao }, "@D",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwPedC:AddColumn(TcColumn():New(TIT_COL3_BRW_PEDC, {|| ::oLstPedC:GetItem(::oBrwPedC:nAt):cNumero }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))	
	::oBrwPedC:AddColumn(TcColumn():New(TIT_COL4_BRW_PEDC, {|| ::oLstPedC:GetItem(::oBrwPedC:nAt):cCondPag }, "@!",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwPedC:AddColumn(TcColumn():New(TIT_COL5_BRW_PEDC, {|| ::oLstPedC:GetItem(::oBrwPedC:nAt):cDesc }, "@!",nil,nil,nil,20,.F.,.F.,nil,nil,nil,.F.,nil))	
	::oBrwPedC:AddColumn(TcColumn():New(TIT_COL6_BRW_PEDC, {|| ::oLstPedC:GetItem(::oBrwPedC:nAt):cFornece }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwPedC:AddColumn(TcColumn():New(TIT_COL7_BRW_PEDC, {|| ::oLstPedC:GetItem(::oBrwPedC:nAt):cLoja }, "@!",nil,nil,nil,15,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwPedC:AddColumn(TcColumn():New(TIT_COL8_BRW_PEDC, {|| ::oLstPedC:GetItem(::oBrwPedC:nAt):nQtd }, "9999999.9999",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwPedC:AddColumn(TcColumn():New(TIT_COL9_BRW_PEDC, {|| ::oLstPedC:GetItem(::oBrwPedC:nAt):nVlrUnit }, "9999999.9999",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwPedC:AddColumn(TcColumn():New("", {|| "" }, "@!",nil,nil,nil,15,.F.,.F.,nil,nil,nil,.F.,nil))
			
	::oBrwPedC:lHScroll := .T.
	::oBrwPedC:lVScroll := .T.	
	
	::oBrwPedC:SetArray(::oLstPedC:ToArray())
	::oBrwPedC:Refresh()	

	::oFolder:SetOption(1)
				
Return()



Method Activate() Class TWHistoricoPrecoProduto
	
	::cPrd := ::GetPrd()
	
	If !Empty(::cPrd) 
	
		::LoadInterface()
			
		::oDlg:Activate()
		
	EndIf
	
Return()


Method GetPrd() Class TWHistoricoPrecoProduto
Local cPrd := ""
	
	If ::cId == "MATA110" // Solicitação de compra/Gera
		
		cPrd := GdFieldGet("C1_PRODUTO")
		
	ElseIf ::cId == "MATA150" // Atualiza Cotação
	
		cPrd := GdFieldGet("C8_PRODUTO")
		
	ElseIf ::cId == "MATA161" // tação
	
		oOwner := GetWndDefault()
		
		nCount := 1
		
		While nCount <= Len(oOwner:aControls) .And. cPrd == ""
		    
			If oOwner:aControls[nCount]:ClassName() == "TGET"
				cPrd := Eval(oOwner:aControls[nCount]:bSetGet)
			EndIf
			
			nCount++
		
		EndDo
		
	ElseIf ::cId == "MATA161" // Analisa Cotação - NOVA
	
		oOwner := GetWndDefault()
		
		nCount := 1
		
		While nCount <= Len(oOwner:aControls) .And. cPrd == ""
		    
			If oOwner:aControls[nCount]:ClassName() == "FWBROWSE"
				cPrd := Eval(oOwner:aControls[nCount]:bSetGet)
			EndIf
			
			nCount++
		
		EndDo		
	
	ElseIf ::cId == "MATA121" // Pedido de Compra
	
		cPrd := GdFieldGet("C7_PRODUTO")
	
	EndIf
	
Return(cPrd)
