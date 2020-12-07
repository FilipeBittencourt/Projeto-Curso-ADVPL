#INCLUDE "TOTVS.CH"

User Function FCLA0010; Return()

/*
|------------------------------------------------------------|
| Classe:	| TWPesquisaPrecoProduto													 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 12/08/15																				 |
|------------------------------------------------------------|
| Desc.:	|	Classe (tela) para pesquisa de precos de produtos|
|------------------------------------------------------------|
| OS:			|	0069-15 - Usuário: Claudia Carvalho   		 			 |
|------------------------------------------------------------|
*/


// IDENTIFICADORES DE LINHA
#DEFINE LIN_UP "LIN_UP"
#DEFINE LIN_DOWN "LIN_DOWN"

// PERCENTUAL DAS LINHAS
#DEFINE PER_LIN_UP 12
#DEFINE PER_LIN_DOWN 88

// IDENTIFICADORES DE COLUNA
#DEFINE COL "COL"

// PERCENTUAL DAS COLUNAS POR LINHA
#DEFINE PER_COL 100

// IDENTIFICADORES DE JANELA
#DEFINE WND_UP "WND_UP"
#DEFINE WND_DOWN "WND_DOWN"

// TITULOS DAS JANELAS
#DEFINE TIT_MAIN_WND "Pesquisa de Preços de Produto"
#DEFINE TIT_WND_UP "Filtros"
#DEFINE TIT_WND_DOWN "Tabela de Preços"

// TITULOS DAS COLUNAS - BROWSE 
#DEFINE TIT_COL1_BRW "Produto"
#DEFINE TIT_COL2_BRW "Descrição"
#DEFINE TIT_COL3_BRW "Preço Unit."
#DEFINE TIT_COL4_BRW "Frete"
#DEFINE TIT_COL5_BRW "Vigência"
#DEFINE TIT_COL6_BRW "Fornecedor"
#DEFINE TIT_COL7_BRW "Loja"
#DEFINE TIT_COL8_BRW "Nome"
#DEFINE TIT_COL9_BRW "Cond Pagto"


Class TWPesquisaPrecoProduto From LongClassName

	Data oDlg // Janela principal
	Data oLayer	// Organizador de objetos
	Data aCoors // array com a coordenadas de tela

	// Fontes
	Data oFnt // Fonte comum
	Data oFntBold // Fonte negrito
			
	// Objetos da coluna acima - Pesquisa
	Data oGetCodPrd // TGet de selecao do produto
  Data cCodPrd // Variavel SetGet para o objeto oGetCodPrd
	Data oGetCodFor // TGet de selecao do fornecedor
  Data cCodFor // Variavel SetGet para o objeto oGetCodFor
	Data oGetPrcCom // TGet de selecao do preço de compra
  Data nPrcCom // Variavel SetGet para o objeto oGetPrcCom		

	Data oBtnSearch // Botao de carregar o arquivo
	
	// Objetos da coluna esquerda abaixo - Tabela de precos
	Data oBusiness
	Data oLst // Lista com os campos do browse
	Data oBrw // Browse
				
	// Paineis
	Data oPnlUp // Painel acima
	Data oPnlDown // Painel abaixo

	Method New() Constructor // Metodo construtor
	Method LoadInterface() // Carrega a interface principal
	Method LoadDialog() // Carrega Dialog principal
	Method LoadLayer() // Carrega Layer principal
	Method LoadLineUp() // Carrega a interface da linha Acima
	Method LoadLineDown() // Carrega a interface da linha Acima
	Method Activate() // Ativa exibicao do objeto	
	Method Search() // Executa busca
			
EndClass


// Construtor da classe
Method New() Class TWPesquisaPrecoProduto
	
	::oDlg := Nil		
	::oLayer := Nil	
	::aCoors := {}
	
	::oGetCodPrd := Nil
	::cCodPrd := Space(15)

	::oGetCodFor := Nil
	::cCodFor := Space(6)	
	
	::oGetPrcCom := Nil
	::nPrcCom := 0	
	
	::oBtnSearch := Nil
		
	::oBusiness := TPesquisaPrecoProduto():New()
	::oLst := ArrayList():New()
	::oBrw := Nil
			
	::oFnt := TFont():New('Arial',,14)
	::oFntBold := TFont():New('Arial',,14,,.T.)	

	::oPnlUp := Nil
	::oPnlDown := Nil
	
Return()


// Contrutor da interface
Method LoadInterface() Class TWPesquisaPrecoProduto

	::LoadDialog()
		
	::LoadLayer()
		
	::LoadLineUp()
	
	::LoadLineDown()

Return()


// Carrega Dialog Principal
Method LoadDialog() Class TWPesquisaPrecoProduto
	
	::aCoors := FWGetDialogSize(oMainWnd)	

	::oDlg := MsDialog():Create()
	::oDlg:cName := "oDlg"
	::oDlg:cCaption := TIT_MAIN_WND
	::oDlg:nTop := ::aCoors[1]
	::oDlg:nLeft := ::aCoors[2]
	::oDlg:nHeight := ::aCoors[3]
	::oDlg:nWidth := ::aCoors[4] / 1.5
	::oDlg:lShowHint := .F.
	::oDlg:lCentered := .T.

Return()


Method LoadLayer() Class TWPesquisaPrecoProduto

	::oLayer := FWLayer():New()
	::oLayer:Init(::oDlg, .F., oAPP:lMDI)

Return()


// Carrega Linha Acima
Method LoadLineUp() Class TWPesquisaPrecoProduto

	// Linha acima com 10% da tela
	::oLayer:AddLine(LIN_UP, PER_LIN_UP, .F.)
	
	// Coluna com 100% da linha
	::oLayer:AddCollumn(COL, PER_COL, .T., LIN_UP)	
	
	// Janela acima 
	::oLayer:AddWindow(COL, WND_UP, TIT_WND_UP, 100, .F. ,.T.,, LIN_UP, { || })	
	
	// Painel acima
	::oPnlUp := ::oLayer:GetWinPanel(COL, WND_UP, LIN_UP)
			
	// Produto
	oSayCodPrd := TSay():Create(::oPnlUp)
	oSayCodPrd:cName := "oSayCodPrd"
	oSayCodPrd:cCaption := "Produto: "
	oSayCodPrd:nLeft := 00
	oSayCodPrd:nTop := 02
	oSayCodPrd:nWidth := 50
	oSayCodPrd:nHeight := 20
	oSayCodPrd:lShowHint := .F.
	oSayCodPrd:lReadOnly := .T.
	oSayCodPrd:Align := 0
	oSayCodPrd:lVisibleControl := .T.
	oSayCodPrd:lWordWrap := .F.
	oSayCodPrd:lTransparent := .T.	
	oSayCodPrd:nClrText := CLR_BLUE
	oSayCodPrd:oFont := ::oFntBold
			
	::oGetCodPrd := TGet():Create(::oPnlUp)
	::oGetCodPrd:cName := "oGetCodPrd"
	::oGetCodPrd:nLeft := 55
	::oGetCodPrd:nTop := 00
	::oGetCodPrd:nWidth := 120
	::oGetCodPrd:nHeight := 20
	::oGetCodPrd:lShowHint := .F.
	::oGetCodPrd:lReadOnly := .F.
	::oGetCodPrd:Align := 0
	::oGetCodPrd:lVisibleControl := .T. 
	::oGetCodPrd:lPassword := .F.
	::oGetCodPrd:lHasButton := .T. // Habilita imagem da lupa no F3
	::oGetCodPrd:cVariable := "::cCodPrd"
	::oGetCodPrd:bSetGet := bSetGet(::cCodPrd)
	::oGetCodPrd:Picture := "@!"
	::oGetCodPrd:cF3 := "SB1"
	::oGetCodPrd:cToolTip := "Digite o código do produto"	
	::oGetCodPrd:bWhen := {|| .T. }
	::oGetCodPrd:bChange	:= {|| .T. }
	::oGetCodPrd:bValid := {|| .T. }


	// Fornecedor
	oSayCodFor := TSay():Create(::oPnlUp)
	oSayCodFor:cName := "oSayCodFor"
	oSayCodFor:cCaption := "Fornecedor: "
	oSayCodFor:nLeft := 190
	oSayCodFor:nTop := 02
	oSayCodFor:nWidth := 80
	oSayCodFor:nHeight := 20
	oSayCodFor:lShowHint := .F.
	oSayCodFor:lReadOnly := .T.
	oSayCodFor:Align := 0
	oSayCodFor:lVisibleControl := .T.
	oSayCodFor:lWordWrap := .F.
	oSayCodFor:lTransparent := .T.	
	oSayCodFor:nClrText := CLR_BLUE
	oSayCodFor:oFont := ::oFntBold
	
	::oGetCodFor := TGet():Create(::oPnlUp)
	::oGetCodFor:cName := "oGetCodFor"
	::oGetCodFor:nLeft := 265
	::oGetCodFor:nTop := 00
	::oGetCodFor:nWidth := 80	
	::oGetCodFor:nHeight := 20
	::oGetCodFor:lShowHint := .F.
	::oGetCodFor:lReadOnly := .F.
	::oGetCodFor:Align := 0
	::oGetCodFor:lVisibleControl := .T. 
	::oGetCodFor:lPassword := .F.
	::oGetCodFor:lHasButton := .T. // Habilita imagem da lupa no F3
	::oGetCodFor:cVariable := "::cCodFor"
	::oGetCodFor:bSetGet := bSetGet(::cCodFor)
	::oGetCodFor:Picture := "@!"
	::oGetCodFor:cF3 := "SA2"
	::oGetCodFor:cToolTip := "Digite o código do fornecedor"	
	::oGetCodFor:bWhen := {|| .T. }
	::oGetCodFor:bChange	:= {|| .T. }
	::oGetCodFor:bValid := {|| .T. }

	// Preco de Compra
	oSayPrcCom := TSay():Create(::oPnlUp)
	oSayPrcCom:cName := "oSayPrcCom"
	oSayPrcCom:cCaption := "Preço: "
	oSayPrcCom:nLeft := 360
	oSayPrcCom:nTop := 02
	oSayPrcCom:nWidth := 40
	oSayPrcCom:nHeight := 20
	oSayPrcCom:lShowHint := .F.
	oSayPrcCom:lReadOnly := .T.
	oSayPrcCom:Align := 0
	oSayPrcCom:lVisibleControl := .T.
	oSayPrcCom:lWordWrap := .F.
	oSayPrcCom:lTransparent := .T.	
	oSayPrcCom:nClrText := CLR_BLUE
	oSayPrcCom:oFont := ::oFntBold
	
	::oGetPrcCom := TGet():Create(::oPnlUp)
	::oGetPrcCom:cName := "oGetPrcCom"
	::oGetPrcCom:nLeft := 405
	::oGetPrcCom:nTop := 00
	::oGetPrcCom:nWidth := 80
	::oGetPrcCom:nHeight := 20
	::oGetPrcCom:lShowHint := .F.
	::oGetPrcCom:lReadOnly := .F.
	::oGetPrcCom:Align := 0
	::oGetPrcCom:lVisibleControl := .T. 
	::oGetPrcCom:lPassword := .F.
	::oGetPrcCom:lHasButton := .T. // Habilita imagem da lupa no F3
	::oGetPrcCom:cVariable := "::nPrcCom"
	::oGetPrcCom:bSetGet := bSetGet(::nPrcCom)
	::oGetPrcCom:Picture := "@E 999,999.9999"
	::oGetPrcCom:cToolTip := "Digite o preço de compra"	
	::oGetPrcCom:bWhen := {|| .T. }
	::oGetPrcCom:bChange	:= {|| .T. }
	::oGetPrcCom:bValid := {|| .T. }

	
	// Botao de Pesquisa
	::oBtnSearch := TButton():Create(::oPnlUp)
	::oBtnSearch:cName := "oBtnSearch"
	::oBtnSearch:cCaption := "Pesquisar"
	::oBtnSearch:nLeft := 510
	::oBtnSearch:nTop := 00
	::oBtnSearch:nWidth := 80
	::oBtnSearch:nHeight := 22
	::oBtnSearch:lShowHint := .F.
	::oBtnSearch:lReadOnly := .F.
	::oBtnSearch:Align := 0 
	::oBtnSearch:cToolTip := "Clique aqui para pesquisar"
	::oBtnSearch:bAction	:= {|| U_BIAMsgRun("Pesquisando...", "Aguarde!", {|| ::Search() }) }
			
Return()


// Carrega Linha Abaixo
Method LoadLineDown() Class TWPesquisaPrecoProduto

	// Linha abaixo com 90% da tela
	::oLayer:AddLine(LIN_DOWN, PER_LIN_DOWN, .F.)
	
	// Coluna com 100% da linha
	::oLayer:AddCollumn(COL, PER_COL, .T., LIN_DOWN)
	
	// Janela abaixo
	::oLayer:AddWindow(COL, WND_DOWN, TIT_WND_DOWN, 100, .F., .T.,, LIN_DOWN, { || })
	
	// Painel abaixo
	::oPnlDown := ::oLayer:GetWinPanel(COL, WND_DOWN, LIN_DOWN)	  	

	::oBrw := TCBrowse():New(00,00,0,0,,,,::oPnlDown,,,,,,,,,,,,.F.,,.T.,,.F.)
	::oBrw:Align := CONTROL_ALIGN_ALLCLIENT
		
	// Get Lista
	::oLst := ::oBusiness:Get(::cCodPrd, ::cCodFor, ::nPrcCom, .T.)
	
	::oBrw:AddColumn(TcColumn():New(TIT_COL1_BRW, {|| ::oLst:GetItem(::oBrw:nAt):cCodPrd }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL2_BRW, {|| ::oLst:GetItem(::oBrw:nAt):cDesPrd }, "@!",nil,nil,nil,80,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL3_BRW, {|| ::oLst:GetItem(::oBrw:nAt):nPrcCom }, "@E 999,999.9999",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))	
	::oBrw:AddColumn(TcColumn():New(TIT_COL4_BRW, {|| ::oLst:GetItem(::oBrw:nAt):nVlrFrt }, "@E 999,999.9999",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL5_BRW, {|| ::oLst:GetItem(::oBrw:nAt):dDtVig }, "@D",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))	
	::oBrw:AddColumn(TcColumn():New(TIT_COL6_BRW, {|| ::oLst:GetItem(::oBrw:nAt):cCodFor }, "@!",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL7_BRW, {|| ::oLst:GetItem(::oBrw:nAt):cLojFor }, "@!",nil,nil,nil,20,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL8_BRW, {|| ::oLst:GetItem(::oBrw:nAt):cNomFor }, "@!",nil,nil,nil,80,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL9_BRW, {|| ::oLst:GetItem(::oBrw:nAt):cConPag }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrw:AddColumn(TcColumn():New("", {|| "" }, "@!",nil,nil,nil,15,.F.,.F.,nil,nil,nil,.F.,nil))			

	::oBrw:lHScroll := .T.
	::oBrw:lVScroll := .T.	
	
	::oBrw:SetArray(::oLst:ToArray())
	::oBrw:Refresh()
		
Return()


Method Activate() Class TWPesquisaPrecoProduto
		
	::LoadInterface()
		
	::oDlg:Activate()
	
Return()


Method Search() Class TWPesquisaPrecoProduto
	                       	
	::oLst := ::oBusiness:Get(::cCodPrd, ::cCodFor, ::nPrcCom)

	::oBrw:SetArray(::oLst:ToArray())
	::oBrw:Refresh()
			
Return()