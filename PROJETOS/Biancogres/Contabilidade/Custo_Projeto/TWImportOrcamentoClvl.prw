#INCLUDE "TOTVS.CH"

// IDENTIFICADORES DE LINHA
#DEFINE LIN_UP "LIN_UP"
#DEFINE LIN_DOWN "LIN_DOWN"

// PERCENTUAL DAS LINHAS
#DEFINE PER_LIN_UP 10
#DEFINE PER_LIN_DOWN 90

// IDENTIFICADORES DE COLUNA
#DEFINE COL "COL"

// PERCENTUAL DAS COLUNAS POR LINHA
#DEFINE PER_COL 100

// IDENTIFICADORES DE JANELA
#DEFINE WND_UP "WND_UP"
#DEFINE WND_DOWN "WND_DOWN"

// TITULOS DAS JANELAS
#DEFINE TIT_MAIN_WND "Importação de Orçamento de Classe de Valor"
#DEFINE TIT_WND_UP "Arquivo de Importação"
#DEFINE TIT_WND_DOWN "Dados do Arquivo"

// TITULOS DAS COLUNAS(BROWSE) - DADOS DO ARQUIVO
#DEFINE TIT_COL1_BRW_FILE "Clvl"
#DEFINE TIT_COL2_BRW_FILE "Item"
#DEFINE TIT_COL3_BRW_FILE "Dólar"
#DEFINE TIT_COL4_BRW_FILE "Libra"
#DEFINE TIT_COL5_BRW_FILE "Euro"
#DEFINE TIT_COL6_BRW_FILE "Subitem"
#DEFINE TIT_COL7_BRW_FILE "Unidade"
#DEFINE TIT_COL8_BRW_FILE "Quantidade"
#DEFINE TIT_COL9_BRW_FILE "Moeda"
#DEFINE TIT_COL10_BRW_FILE "Valor"
#DEFINE TIT_COL11_BRW_FILE "Total"
#DEFINE TIT_COL12_BRW_FILE "Encerrado"

// Indices do array de dados do arquivo
#DEFINE IDX_CLVL 1
#DEFINE IDX_ITEM 2
#DEFINE IDX_DOLAR 3
#DEFINE IDX_LIBRA 4
#DEFINE IDX_EURO 5
#DEFINE IDX_SUBITEM 6
#DEFINE IDX_UNIDADE 7
#DEFINE IDX_QUANTIDADE 8
#DEFINE IDX_MOEDA 9
#DEFINE IDX_VALOR 10
#DEFINE IDX_TOTAL 11
#DEFINE IDX_ENCERRADO 12


Class TWImportOrcamentoClvl From LongClassName

	Data oDlg // Janela principal                         
	Data bOK // Bloco de codigo do botao OK
	Data bCancel // Bloco de codigo do botao Cancel
	Data aButtons // Array de botoes adicionais	
	Data oLayer	// Organizador de objetos
	Data aCoors // array com a coordenadas de tela

	// Fontes
	Data oFnt // Fonte comum
	Data oFntBold // Fonte negrito
			
	// Objetos da coluna acima - Arquivo de Importação
	Data oGetFile // TGet de selecao do arquivo
  Data cFile // Variavel SetGet para o objeto oGetFile
	Data oBtnLoadFile // Botao de carregar o arquivo
  Data oBtnImpFile // Botao de importacao do arquivo  
  Data oBtnClose // Botao Fechar Janela
	
	// Objetos da coluna esquerda abaixo - Dados do Arquivo
	Data oBrwFile // Browse de dados do arquivo
	Data aFile // Itens do Arquivo 
		
	Data lLoaded // Indica se o arquivo foi carregado corretamente
			
	// Paineis
	Data oPnlUp // Painel acima
	Data oPnlDown // Painel abaixo
	
	Data oBusiness // Objeto com as regras de negocio de importação
	
	Data oProcess // Barra de progresso

	Method New() Constructor // Metodo construtor
	Method LoadInterface() // Carrega a interface principal
	Method LoadDialog() // Carrega Dialog principal
	Method LoadLayer() // Carrega Layer principal
	Method LoadLineUp() // Carrega a interface da linha Acima
	Method LoadLineDown() // Carrega a interface da linha Acima
	Method Activate() // Ativa exibicao do objeto	
	Method Refresh() // Efetua refresh em todos os browsers	
	Method LoadFile() // Efetua Carregamento do arquivo
	Method ImportFile() // Efetua Importacao do arquivo
	Method VldFile() // Valida arquivo
			
EndClass


// Construtor da classe
Method New() Class TWImportOrcamentoClvl
	
	::oDlg := Nil
	::bOK := {|| }
	::bCancel := {|| }
	::aButtons := {}
		
	::oLayer := Nil	
	::aCoors := {}
	
	::oGetFile := Nil
	::cFile := Space(100)
	::oBtnLoadFile := Nil
	::oBtnImpFile := Nil
	
	::oBrwFile := Nil
	::aFile := Array(1, 13)
	
	::lLoaded := .F.
			
	::oFnt := TFont():New('Arial',,14)
	::oFntBold := TFont():New('Arial',,14,,.T.)	

	::oPnlUp := Nil
	::oPnlDown := Nil
	
	::oBusiness := TImportOrcamentoClvl():New()
	
	::oProcess := Nil
	
Return()


// Contrutor da interface
Method LoadInterface() Class TWImportOrcamentoClvl

	::LoadDialog() 
		
	::LoadLayer()
		
	::LoadLineUp()
	
	::LoadLineDown()

Return()


// Carrega Dialog Principal
Method LoadDialog() Class TWImportOrcamentoClvl
	
	::aCoors := FWGetDialogSize(oMainWnd)	

	::oDlg := MsDialog():New(::aCoors[1], ::aCoors[2], ::aCoors[3], ::aCoors[4], TIT_MAIN_WND,,,,nOR(WS_VISIBLE, WS_POPUP),,,,,.T.)
	::oDlg:cName := "oDlg"
	::oDlg:lMaximized := .T.	
		
Return()


Method LoadLayer() Class TWImportOrcamentoClvl

	::oLayer := FWLayer():New()
	::oLayer:Init(::oDlg, .F., oAPP:lMDI)

Return()


// Carrega Linha Acima
Method LoadLineUp() Class TWImportOrcamentoClvl

	// Linha acima com 10% da tela
	::oLayer:AddLine(LIN_UP, PER_LIN_UP, .F.)	
	
	// Coluna com 100% da linha
	::oLayer:AddCollumn(COL, PER_COL, .T., LIN_UP)	
	
	// Janela acima 
	::oLayer:AddWindow(COL, WND_UP, TIT_WND_UP, 100, .F. ,.T.,, LIN_UP, { || })	
	
	// Painel acima
	::oPnlUp := ::oLayer:GetWinPanel(COL, WND_UP, LIN_UP)
		
	
	oSay := TSay():Create(::oPnlUp)
	oSay:cName := "oSay"
	oSay:cCaption := "Arquivo: "
	oSay:nLeft := 00
	oSay:nTop := 02
	oSay:nWidth := 50
	oSay:nHeight := 20
	oSay:lShowHint := .F.
	oSay:lReadOnly := .T.
	oSay:Align := 0
	oSay:lVisibleControl := .T.
	oSay:lWordWrap := .F.
	oSay:lTransparent := .T.	
	oSay:nClrText := CLR_BLUE
	oSay:oFont := ::oFntBold
	
		
	::oGetFile:= TGet():Create(::oPnlUp)
	::oGetFile:cName := "oGetFile"
	::oGetFile:nLeft := 60
	::oGetFile:nTop := 00
	::oGetFile:nWidth := 320 
	::oGetFile:nHeight := 20
	::oGetFile:lShowHint := .F.
	::oGetFile:lReadOnly := .F.
	::oGetFile:Align := 0
	::oGetFile:lVisibleControl := .T. 
	::oGetFile:lPassword := .F.
	::oGetFile:lHasButton := .T. // Habilita imagem da lupa no F3
	::oGetFile:cVariable := "::cFile"
	::oGetFile:bSetGet := bSetGet(::cFile)
	::oGetFile:Picture := "@!"
	::oGetFile:cF3 := "DIR"
	::oGetFile:cToolTip := "Digite o nome do arquivo que deseja importar"	
	::oGetFile:bWhen := {|| .T. }
	::oGetFile:bChange	:= {|| .T. }
	::oGetFile:bValid := {|| .T. }
	

	::oBtnLoadFile:= TButton():Create(::oPnlUp)
	::oBtnLoadFile:cName := "oBtnLoadFile"
	::oBtnLoadFile:cCaption := "Carregar"
	::oBtnLoadFile:nLeft := 390
	::oBtnLoadFile:nTop := 0
	::oBtnLoadFile:nWidth := 80
	::oBtnLoadFile:nHeight := 22
	::oBtnLoadFile:lShowHint := .F.
	::oBtnLoadFile:lReadOnly := .F.
	::oBtnLoadFile:Align := 0 
	::oBtnLoadFile:cToolTip := "Clique aqui para carregar o arquivo"
	::oBtnLoadFile:bAction := {|| U_BIAMsgRun("Carregando Arquivo...", "Aguarde!", {|| ::LoadFile() }) }		
	

	::oBtnImpFile:= TButton():Create(::oPnlUp)
	::oBtnImpFile:cName := "oBtnImpFile"
	::oBtnImpFile:cCaption := "Importar"
	::oBtnImpFile:nLeft := 490
	::oBtnImpFile:nTop := 0
	::oBtnImpFile:nWidth := 80
	::oBtnImpFile:nHeight := 22
	::oBtnImpFile:lShowHint := .F.
	::oBtnImpFile:lReadOnly := .F.
	::oBtnImpFile:Align := 0 
	::oBtnImpFile:cToolTip := "Clique aqui para importar o arquivo"
	::oBtnImpFile:bAction	:= {|| ::ImportFile() }
	

	::oBtnClose:= TButton():Create(::oPnlUp)
	::oBtnClose:cName := "oBtnClose"
	::oBtnClose:cCaption := "Sair"
	::oBtnClose:nLeft := 590
	::oBtnClose:nTop := 0
	::oBtnClose:nWidth := 80
	::oBtnClose:nHeight := 22
	::oBtnClose:lShowHint := .F.
	::oBtnClose:lReadOnly := .F.
	::oBtnClose:Align := 0 
	::oBtnClose:cToolTip := "Clique aqui para Sair da rotina"
	::oBtnClose:bAction	:= {|| ::oDlg:End() }	
	
Return()


// Carrega Linha Abaixo
Method LoadLineDown() Class TWImportOrcamentoClvl

	// Linha abaixo com 90% da tela
	::oLayer:AddLine(LIN_DOWN, PER_LIN_DOWN, .F.)
	
	// Coluna com 100% da linha
	::oLayer:AddCollumn(COL, PER_COL, .T., LIN_DOWN)
	
	// Janela abaixo
	::oLayer:AddWindow(COL, WND_DOWN, TIT_WND_DOWN, 100, .F., .T.,, LIN_DOWN, { || })
	
	// Painel abaixo
	::oPnlDown := ::oLayer:GetWinPanel(COL, WND_DOWN, LIN_DOWN)	  	

	// Browse
	::oBrwFile := TCBrowse():New(00,00,222,130,,,,::oPnlDown,,,,,,,,,,,,.F.,,.T.,,.F.)
	::oBrwFile:Align := CONTROL_ALIGN_ALLCLIENT

	::oBrwFile:AddColumn(TcColumn():New(TIT_COL1_BRW_FILE, {|| ::aFile[::oBrwFile:nAt, IDX_CLVL] }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwFile:AddColumn(TcColumn():New(TIT_COL2_BRW_FILE, {|| ::aFile[::oBrwFile:nAt, IDX_ITEM] }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwFile:AddColumn(TcColumn():New(TIT_COL3_BRW_FILE, {|| ::aFile[::oBrwFile:nAt, IDX_DOLAR] }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))	
	::oBrwFile:AddColumn(TcColumn():New(TIT_COL4_BRW_FILE, {|| ::aFile[::oBrwFile:nAt, IDX_LIBRA] }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwFile:AddColumn(TcColumn():New(TIT_COL5_BRW_FILE, {|| ::aFile[::oBrwFile:nAt, IDX_EURO] }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwFile:AddColumn(TcColumn():New(TIT_COL6_BRW_FILE, {|| ::aFile[::oBrwFile:nAt, IDX_SUBITEM] }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwFile:AddColumn(TcColumn():New(TIT_COL7_BRW_FILE, {|| ::aFile[::oBrwFile:nAt, IDX_UNIDADE] }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))	
	::oBrwFile:AddColumn(TcColumn():New(TIT_COL8_BRW_FILE, {|| ::aFile[::oBrwFile:nAt, IDX_QUANTIDADE] }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwFile:AddColumn(TcColumn():New(TIT_COL9_BRW_FILE, {|| ::aFile[::oBrwFile:nAt, IDX_MOEDA] }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwFile:AddColumn(TcColumn():New(TIT_COL10_BRW_FILE, {|| ::aFile[::oBrwFile:nAt, IDX_MOEDA] }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrwFile:AddColumn(TcColumn():New(TIT_COL11_BRW_FILE, {|| ::aFile[::oBrwFile:nAt, IDX_VALOR] }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))	
	::oBrwFile:AddColumn(TcColumn():New(TIT_COL12_BRW_FILE, {|| ::aFile[::oBrwFile:nAt, IDX_ENCERRADO] }, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))				
	::oBrwFile:AddColumn(TcColumn():New("", {|| Space(2) }, "@!",nil,nil,nil,20,.F.,.F.,nil,nil,nil,.F.,nil))			
				
	::oBrwFile:lHScroll := .T.
	::oBrwFile:lVScroll := .T.
		
Return()


Method Activate() Class TWImportOrcamentoClvl
		
	::LoadInterface()
		
	::oDlg:Activate()
	
Return()


Method Refresh() Class TWImportOrcamentoClvl
	                       	
	::oBrwFile:SetArray(::aFile)
	::oBrwFile:Refresh()
			
Return()


Method LoadFile() Class TWImportOrcamentoClvl

	::lLoaded := ::VldFile()
	
Return()


Method ImportFile() Class TWImportOrcamentoClvl
	
	If ::lLoaded
					
		::oProcess := MsNewProcess():New({|| ::oBusiness:ImportFile(::oProcess) })
		::oProcess:Activate()
		
		MsgInfo("Arquivo importado com sucesso!!")
		
		::aFile := {}
		
		::Refresh()
								
	Else
		MsgStop("Arquivo não carregado, favor selecionar um arquivo para importação!")		
	EndIf
						
Return()



Method VldFile() Class TWImportOrcamentoClvl
Local lRet := .F.
	
	If ::oBusiness:VldFile(::cFile)
		
		lRet := .T.
			
		::aFile := ::oBusiness:aValue
		
	Else
		
	  ::aFile := {}
					
	EndIf
	
	::Refresh()
	
Return(lRet)