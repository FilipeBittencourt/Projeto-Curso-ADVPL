#INCLUDE "TOTVS.CH"

User Function FCLA0049; Return()

/*
|------------------------------------------------------------|
| Classe:	| TWBiaComposicaoDesconto						 |
| Autor:	| Fernando Rocha - Facile Sistemas				 |
| Data:		| 24/08/15										 |
|------------------------------------------------------------|
| Desc.:	| Classe para vizualização (tela) da composicao  |
| 			| do desconto no pedido de venda                 |
|------------------------------------------------------------|
*/


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
#DEFINE TIT_MAIN_WND "Composição dos Descontos"

// TITULOS DAS COLUNAS - BROWSE DE PRODUTOS DISTRIBUIDOS POR CD
#DEFINE TIT_COL1_BRW "Tipo"
#DEFINE TIT_COL2_BRW "Cod.Politica"
#DEFINE TIT_COL3_BRW "P.Desc(%)"
#DEFINE TIT_COL4_BRW "FC"
#DEFINE TIT_COL5_BRW "Verba Cat.(%)"
#DEFINE TIT_COL6_BRW "Verba Sol.(%)"
#DEFINE TIT_COL7_BRW "ICMS(%)"
#DEFINE TIT_COL8_BRW "PIS(%)"
#DEFINE TIT_COL9_BRW "COFINS(%)"
#DEFINE TIT_COL10_BRW "Comissao(%)"
#DEFINE TIT_COL11_BRW "Desc.Ori(%)"

Class TWBiaComposicaoDesconto From LongClassName

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
	
	Data oLst // Lista com os campos do browse

	Data oBrw // Browse de historica
	Data oButtonBar // Barra de botoes
	Data oBtnOk // Botao OK
	
	// paineis
	Data oPnl
	
	//parametros para buscar dados gravados da ZA4
	Data cPedido
	Data cItem
	                
	//objeto para receber o desconto calculado quando vindo por parametros na memoria
	Data oDesconto
			
	Method New() Constructor // Metodo construtor
	Method LoadInterface(nOpc) // Carrega a interface principal
	Method LoadDialog() // Carrega Dialog principal
	Method LoadButtonBar() // Carrega barra de botoes	
	Method LoadLayer(nOpc) // Carrega Layer principal
	Method LoadBrowser(nOpc) // Carrega Browse com ou sem edição
	
	Method Activate(nOpc) // Ativa exibicao do objeto nOpc == 1 (ZA4)  nOpc == 2 (Memoria)	
			
EndClass


// construtor da classe
Method New(_cPedido, _cItem) Class TWBiaComposicaoDesconto
	
	::oDlg := Nil
	::oLayer := Nil	
	::aCoors := {}
		
	::oBusiness := TBiaComposicaoDesconto():New() 
	
	::oDesconto := Nil
	
	::oLst := ArrayList():New()

	::oBrw := Nil
	
	::oButtonBar := Nil
			
	::oFnt := TFont():New('Arial',,14)
	::oFntBold := TFont():New('Arial',,14,,.T.)	

	::oPnl := Nil
	
	::cPedido := _cPedido
	::cItem := _cItem	
	
Return()


// Contrutor da interface
Method LoadInterface(nOpc) Class TWBiaComposicaoDesconto
	
	::LoadDialog()	
	::LoadButtonBar()
	::LoadLayer(nOpc)		
	::LoadBrowser(nOpc)
		
Return()


Method LoadDialog() Class TWBiaComposicaoDesconto
	
	::aCoors := FWGetDialogSize(oMainWnd)	
		
	::oDlg := MsDialog():Create()
	::oDlg:cName := "oDlg"
	::oDlg:cCaption := TIT_MAIN_WND 
	::oDlg:nTop := ::aCoors[1]
	::oDlg:nLeft := ::aCoors[2]
	::oDlg:nHeight := ::aCoors[3] / 2//2.5
	::oDlg:nWidth := ::aCoors[4] / 2
	::oDlg:lShowHint := .F.
	::oDlg:lCentered := .T.
		
Return()


Method LoadButtonBar() Class TWBiaComposicaoDesconto

	::oButtonBar := FWButtonBar():New()
	::oButtonBar:Init(::oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)

	::oButtonBar:AddBtnText("OK", "", {|| ::oDlg:End() },,,CONTROL_ALIGN_LEFT,.T.)
	
Return()


Method LoadLayer(nOpc) Class TWBiaComposicaoDesconto

Local _cTitulo

	if ( nOpc == 1 .And. !Empty(::cPedido) .And. !Empty(::cItem))   
		_cTitulo := "Pedido: "+::cPedido+" / Item: "+::cItem
	else
		_cTitulo := ""
	endif

	::oLayer := FWLayer():New()
	::oLayer:Init(::oDlg,.F.,.T.)

	::oLayer:AddLine(LIN, PER_LIN, .F.)
	::oLayer:AddCollumn(COL, PER_COL, .T., LIN)			
	::oLayer:AddWindow(COL, WND, _cTitulo, 100, .F. ,.T.,, LIN, { || })
		
Return()


// Carrega Browser
Method LoadBrowser(nOpc) Class TWBiaComposicaoDesconto
	
	// Painel acima
	::oPnl := ::oLayer:GetWinPanel(COL, WND, LIN)
		
	::oBrw := TCBrowse():New(00,00,0,0,,,,::oPnl,,,,,,,,,,,,.F.,,.T.,,.F.)
	::oBrw:Align := CONTROL_ALIGN_ALLCLIENT
		
	// Get Lista 
	If ( nOpc == 1 )
		::oLst := ::oBusiness:Get(::cPedido+::cItem)
	Else 
		if ( ::oDesconto <> Nil )
			::oLst := ::oBusiness:GetFromPar(::oDesconto:_cCliente, ::oDesconto:_cVendedor, ::oDesconto:_cProduto, ::oDesconto:_cLote, ::oDesconto:_lPaletizado, ::oDesconto:_nPICMS, ::oDesconto:_nPPIS, ::oDesconto:_nPCOF, ::oDesconto:_nAComis)
		endif
	EndIf
	
	::oBrw:AddColumn(TcColumn():New(TIT_COL1_BRW, {|| ::oLst:GetItem(::oBrw:nAt):Tipo 	}, "@!",nil,nil,nil,20,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL2_BRW, {|| ::oLst:GetItem(::oBrw:nAt):CodReg 	}, "@!",nil,nil,nil,35,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL3_BRW, {|| ::oLst:GetItem(::oBrw:nAt):PDesc 	}, "@E 999.99",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))	
	::oBrw:AddColumn(TcColumn():New(TIT_COL4_BRW, {|| ::oLst:GetItem(::oBrw:nAt):FC 		}, "@E 99.999999",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL5_BRW, {|| ::oLst:GetItem(::oBrw:nAt):PVCat 	}, "@E 999.99",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))	
	::oBrw:AddColumn(TcColumn():New(TIT_COL6_BRW, {|| ::oLst:GetItem(::oBrw:nAt):PVSol 	}, "@E 999.99",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL7_BRW, {|| ::oLst:GetItem(::oBrw:nAt):PICM 	}, "@E 999.99",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL8_BRW, {|| ::oLst:GetItem(::oBrw:nAt):PPIS	 	}, "@E 999.99",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL9_BRW, {|| ::oLst:GetItem(::oBrw:nAt):PCOF 	}, "@E 999.99",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL10_BRW, {|| ::oLst:GetItem(::oBrw:nAt):PComis 	}, "@E 999.99",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	::oBrw:AddColumn(TcColumn():New(TIT_COL11_BRW, {|| ::oLst:GetItem(::oBrw:nAt):PDesc_Ori 	}, "@E 999.99",nil,nil,nil,40,.F.,.F.,nil,nil,nil,.F.,nil))
	
	::oBrw:AddColumn(TcColumn():New("", {|| "" }, "@!",nil,nil,nil,15,.F.,.F.,nil,nil,nil,.F.,nil))
			
	::oBrw:lHScroll := .T.
	::oBrw:lVScroll := .T.	
	
	::oBrw:SetArray(::oLst:ToArray())
	::oBrw:Refresh()
					
Return()

Method Activate(nOpc) Class TWBiaComposicaoDesconto
	
	::LoadInterface(nOpc)
	::oDlg:Activate()
	
Return()