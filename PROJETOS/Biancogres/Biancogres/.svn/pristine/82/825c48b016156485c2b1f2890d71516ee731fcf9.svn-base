#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWTransportadorPedidoCompra
@author Tiago Rossini Coradini
@since 18/12/2017
@version 1.0
@description Classe para associar o transportador ao pedido de compra. 
@obs Ticket: 829 - Projeto Demandas Compras - Item 2
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
#DEFINE TIT_MAIN_WND "Informe o Transportador do Pedido de Compra"
#DEFINE TIT_WND "Pedido de Compra: "


Class TWTransportadorPedidoCompra From LongClassName
	
	Data oFntBold // Fonte
	Data oDlg // Janela principal
	Data lValid // Identifica se a tela esta validada
	Data lEnvMan // Identifica envio manual de email
	Data lVldEnvMan // Valida envio manual de email
	
	// Pedido de Compra
	Data cNumPed // Numero
	
	// Fornecedor
	Data cCodFor // Codigo	
	Data cLojFor // Loja
	Data cNomFor // Nome
	Data cEstFor // Estado

	// Transportador
	Data cCodTra // Codigo
	Data cNomTra // Nome
	Data cTipFre // Tipo de frete: C-CIF; F-FOB

	// E-mail automatico transportador
	Data nAtEnvTra // Indice do combo de email
	Data cEnvTra // Envia e-mail
	Data aEnvTra // Array com as opções		

	// E-mail automatico
	Data nAtEnvAut // Indice do combo de email
	Data cEnvAut // Envia e-mail
	Data aEnvAut // Array com as opções
			
	Method New() Constructor
	Method Activate() // Ativa exibicao do objeto
	Method Confirm() // Confima
	Method Validate() // Valida
	Method Save() // Salva
	Method GetData()
	
EndClass


Method New() Class TWTransportadorPedidoCompra
	
	::oFntBold := TFont():New('Arial',,14,,.T.)				
	::oDlg := Nil
	::lValid := .F.			
	::lEnvMan := .F.
	::lVldEnvMan := .F.
	
	::cCodFor := Space(TamSx3("C7_FORNECE")[1])
	::cLojFor := Space(TamSx3("C7_LOJA")[1])
	::cNomFor := Space(TamSx3("A2_NOME")[1])
	::cEstFor := Space(TamSx3("A2_EST")[1])

	::cCodTra := Space(TamSx3("C7_YTRANSP")[1])
	::cNomTra := Space(TamSx3("A4_NOME")[1])
	::cTipFre := Space(TamSx3("C7_TPFRETE")[1])
	
	::nAtEnvTra := 1
	::cEnvTra := Space(5)
	::aEnvTra := {}
	
	aAdd(::aEnvTra, "Sim")
	aAdd(::aEnvTra, "Não")

	::nAtEnvAut := 1
	::cEnvAut := Space(5)
	::aEnvAut := {}
	
	aAdd(::aEnvAut, "Sim")
	aAdd(::aEnvAut, "Não")
		
Return()


Method Activate() Class TWTransportadorPedidoCompra
Local oWindow := Nil
	
	::GetData()
	
	// Cria Dialog padrão
	::oDlg := MsDialog():New(0, 0, 250, 500, TIT_MAIN_WND,,,,DS_MODALFRAME,,,,,.T.)
	::oDlg:cName := "oDlg"
	::oDlg:lCentered := .T.
	::oDlg:lEscClose := .F.
	::oDlg:bValid := {|| ::lValid }
	
	// Barra de botoes
	oBtnBar := FWButtonBar():New()
	oBtnBar:Init(::oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)
	
	If ::lEnvMan
		
		oBtnBar:AddBtnText("Enviar", "Enviar", {|| ::Confirm() },,,CONTROL_ALIGN_RIGHT,.T.)
		oBtnBar:AddBtnText("Cancelar", "Cancelar", {|| ::lValid := .T., ::lVldEnvMan := .F., ::oDlg:End() },,,CONTROL_ALIGN_RIGHT,.T.)				
		
	Else
		
		oBtnBar:AddBtnText("Salvar", "Salvar", {|| ::Confirm() },,,CONTROL_ALIGN_RIGHT,.T.)
		
	EndIf
		
	// Layer
	oLayer := FWLayer():New()
	oLayer:Init(::oDlg, .F., .T.)
	
	// Adiciona linha ao Layer
	oLayer:AddLine(LIN, 100, .F.)
	// Adiciona coluna ao Layer
	oLayer:AddCollumn(COL, PER_COL, .T., LIN)
	// Adiciona janela ao Layer
	oLayer:AddWindow(COL, WND, TIT_WND, 100, .F. ,.T.,, LIN, { || })
	
	oLayer:SetWinTitle(COL, WND, TIT_WND + ::cNumPed, LIN)
	  
	// Muda fonte do Layes
	oLayer:GetWindow(COL, WND, @oWindow, LIN)			
	oWindow:oTitleBar:oFont := ::oFntBold
	
	// Retorna paimel da janela do Layer
	oPnl := oLayer:GetWinPanel(COL, WND, LIN)	
	
	// Fornecedor	
	oSayCodFor := TSay():Create(oPnl)
	oSayCodFor:cName := "oSayCodFor"
	oSayCodFor:cCaption := "Fornecedor"
	oSayCodFor:nLeft := 06
	oSayCodFor:nTop := 06
	oSayCodFor:nWidth := 65
	oSayCodFor:nHeight := 30
	oSayCodFor:cToolTip := "Código do fornecedor"	
	
	oGetCodFor:= TGet():Create(oPnl)
	oGetCodFor:cName := "oGetCodFor"
	oGetCodFor:nLeft := 06
	oGetCodFor:nTop := 22
	oGetCodFor:nWidth := 60
	oGetCodFor:nHeight := 20
	oGetCodFor:cVariable := "::cCodFor"
	oGetCodFor:bSetGet := bSetGet(::cCodFor)
	oGetCodFor:Picture := PesqPict("SA2", "A2_COD")
	oGetCodFor:cToolTip := "Código do fornecedor"
	oGetCodFor:Disable()		
	
	// Loja	
	oSayLojFor := TSay():Create(oPnl)
	oSayLojFor:cName := "oSayLojFor"
	oSayLojFor:cCaption := "Loja"
	oSayLojFor:nLeft := 80
	oSayLojFor:nTop := 06
	oSayLojFor:nWidth := 65
	oSayLojFor:nHeight := 30
	oSayLojFor:cToolTip := "Loja do fornecedor"	
	
	oGetLojFor := TGet():Create(oPnl)
	oGetLojFor:cName := "oGetLojFor"
	oGetLojFor:nLeft := 80
	oGetLojFor:nTop := 22
	oGetLojFor:nWidth := 60 
	oGetLojFor:nHeight := 20
	oGetLojFor:cVariable := "::cLojFor"
	oGetLojFor:bSetGet := bSetGet(::cLojFor)
	oGetLojFor:Picture := PesqPict("SA2", "A2_LOJA")
	oGetLojFor:cToolTip := "Loja do fornecedor"
	oGetLojFor:Disable()

	// Nome	
	oSayNomFor := TSay():Create(oPnl)
	oSayNomFor:cName := "oSayNomFor"
	oSayNomFor:cCaption := "Nome"
	oSayNomFor:nLeft := 154
	oSayNomFor:nTop := 06
	oSayNomFor:nWidth := 65
	oSayNomFor:nHeight := 30
	oSayNomFor:cToolTip := "Nome do fornecedor"
	
	oGetNomFor := TGet():Create(oPnl)
	oGetNomFor:cName := "oGetNomFor"
	oGetNomFor:nLeft := 154
	oGetNomFor:nTop := 22
	oGetNomFor:nWidth := 250 
	oGetNomFor:nHeight := 20
	oGetNomFor:cVariable := "::cNomFor"
	oGetNomFor:bSetGet := bSetGet(::cNomFor)
	oGetNomFor:Picture := PesqPict("SA2", "A2_NOME")
	oGetNomFor:cToolTip := "Nome do fornecedor"
	oGetNomFor:Disable()	

	// Estado	
	oSayEstFor := TSay():Create(oPnl)
	oSayEstFor:cName := "oSayEstFor"
	oSayEstFor:cCaption := "Estado"
	oSayEstFor:nLeft := 418
	oSayEstFor:nTop := 06
	oSayEstFor:nWidth := 65
	oSayEstFor:nHeight := 30
	oSayEstFor:cToolTip := "Estado do fornecedor"	
	
	oGetEstFor := TGet():Create(oPnl)
	oGetEstFor:cName := "oGetEstFor"
	oGetEstFor:nLeft := 418
	oGetEstFor:nTop := 22
	oGetEstFor:nWidth := 60 
	oGetEstFor:nHeight := 20
	oGetEstFor:cVariable := "::cEstFor"
	oGetEstFor:bSetGet := bSetGet(::cEstFor)
	oGetEstFor:Picture := PesqPict("SA2", "A2_EST")
	oGetEstFor:cToolTip := "Estado do fornecedor"
	oGetEstFor:Disable()
		
	// Transportador	
	oSayCodTra := TSay():Create(oPnl)
	oSayCodTra:cName := "oSayCodTra"
	oSayCodTra:cCaption := "Transportador"
	oSayCodTra:nLeft := 06
	oSayCodTra:nTop := 64
	oSayCodTra:nWidth := 80
	oSayCodTra:nHeight := 30
	oSayCodTra:cToolTip := "Código do transportador"
	
	oGetCodTra:= TGet():Create(oPnl)
	oGetCodTra:cName := "oGetCodTra"
	oGetCodTra:nLeft := 06
	oGetCodTra:nTop := 80
	oGetCodTra:nWidth := 80
	oGetCodTra:nHeight := 20
	oGetCodTra:cVariable := "::cCodTra"
	oGetCodTra:bSetGet := bSetGet(::cCodTra)
	oGetCodTra:Picture := PesqPict("SA4", "A4_COD")
	oGetCodTra:bLostFocus := {|| ::cNomTra := Posicione("SA4", 1, xFilial("SA4") + ::cCodTra, "A4_NOME"), oGetNomTra:Refresh() }		
	oGetCodTra:cF3 := "SA4"
	oGetCodTra:lHasButton := .T.		
	oGetCodTra:cToolTip := "Código do transportador"
	
	If ::cTipFre == "C"		
		oGetCodTra:Disable()		
	EndIf
			
	// Nome Transportador	
	oSayNomTra := TSay():Create(oPnl)
	oSayNomTra:cName := "oSayNomTra"
	oSayNomTra:cCaption := "Nome"
	oSayNomTra:nLeft := 100
	oSayNomTra:nTop := 64
	oSayNomTra:nWidth := 65
	oSayNomTra:nHeight := 30
	oSayNomTra:cToolTip := "Nome do transportador"
	
	oGetNomTra := TGet():Create(oPnl)
	oGetNomTra:cName := "oGetNomTra"
	oGetNomTra:nLeft := 100
	oGetNomTra:nTop := 80
	oGetNomTra:nWidth := 250 
	oGetNomTra:nHeight := 20
	oGetNomTra:cVariable := "::cNomTra"
	oGetNomTra:bSetGet := bSetGet(::cNomTra)
	oGetNomTra:Picture := PesqPict("SA4", "A4_NOME")
	oGetNomTra:cToolTip := "Nome do transportador"
	oGetNomTra:Disable()
		
	// E-mail Transportador
	oSayEnvTra := TSay():Create(oPnl)
	oSayEnvTra:cName := "oSayEnvTra"
	oSayEnvTra:cCaption := "Envia Transportador"
	oSayEnvTra:nLeft := 365
	oSayEnvTra:nTop := 64
	oSayEnvTra:nWidth := 100
	oSayEnvTra:nHeight := 20
	oSayEnvTra:cToolTip := "Envia e-mail para o transportador"	

	oCbEnvTra := TComboBox():Create(oPnl)
	oCbEnvTra:cName := "oCbEnvTra"
	oCbEnvTra:nLeft := 365
	oCbEnvTra:nTop := 80
	oCbEnvTra:nWidth := 65
	oCbEnvTra:nHeight := 20
	oCbEnvTra:bSetGet := bSetGet(::cEnvTra)
	oCbEnvTra:aItems := ::aEnvTra
	oCbEnvTra:nAt := ::nAtEnvTra
	oCbEnvTra:cToolTip := "Envia e-mail para o transportador"
	
	If ::cTipFre == "C"		
		oCbEnvTra:Disable()		
	EndIf		
	
	// E-mail Automático
	oSayEnvAut := TSay():Create(oPnl)
	oSayEnvAut:cName := "oSayEnvAut"
	oSayEnvAut:cCaption := "E-mail automático"
	oSayEnvAut:nLeft := 06
	oSayEnvAut:nTop := 122
	oSayEnvAut:nWidth := 100
	oSayEnvAut:nHeight := 20
	oSayEnvAut:cToolTip := "Envia e-mail automaticamente após aprovação do pedido"	

	oCbEnvAut := TComboBox():Create(oPnl)
	oCbEnvAut:cName := "oCbEnvAut"
	oCbEnvAut:nLeft := 06
	oCbEnvAut:nTop := 138
	oCbEnvAut:nWidth := 65
	oCbEnvAut:nHeight := 20
	oCbEnvAut:bSetGet := bSetGet(::cEnvAut)
	oCbEnvAut:aItems := ::aEnvAut
	oCbEnvAut:nAt := ::nAtEnvAut
	oCbEnvAut:cToolTip := "Envia e-mail automaticamente após aprovação do pedido"									
	
	If ::lEnvMan
		oCbEnvAut:Disable()
	EndIf

	If ::cTipFre == "F"								
		oGetCodTra:SetFocus()
	EndIf
	
	::oDlg:Activate()

Return()


Method Confirm() Class TWTransportadorPedidoCompra
	
	If ::Validate()
		
		::Save()
		
		If ::lEnvMan
		
			::lVldEnvMan := .T.
			
		EndIf

		::lValid := .T.

		::oDlg:End()

	EndIf

Return()


Method Validate() Class TWTransportadorPedidoCompra
Local lRet := .T.

	If !Empty(::cCodTra)
	
		DbSelectArea("SA4")
		DbSetOrder(1)
		If SA4->(DbSeek(xFilial("SA4") + ::cCodTra))
		
			If SA4->A4_MSBLQL == "1"
				
				lRet := .F.
				
				MsgAlert("Atenção, o transportador selecionado está bloqueado para uso.")
			
			ElseIf Empty(SA4->A4_EMAIL) 
				
				lRet := .F.
				
				MsgAlert("Atenção, o transportador selecionado não está com o e-mail cadastrado.")
				
			EndIf
		
		Else
		
			lRet := .F.
			
			MsgAlert("Atenção, transportador inválido.")
		
		EndIf

	Else
	
		lRet := .F.
		
		MsgAlert("Atenção, transportador inválido.")
			
	EndIf
	
Return(lRet)


Method Save() Class TWTransportadorPedidoCompra
Local nRecNo := 0 
	
	nRecNo := SC7->(RecNo())
	
	While !SC7->(Eof()) .And. SC7->C7_NUM == ::cNumPed
	
		RecLock("SC7", .F.)
		
			SC7->C7_YTRANSP := ::cCodTra
			SC7->C7_YENVAUT := Upper(SubStr(::cEnvAut, 1, 1))
			SC7->C7_YENVTRA := Upper(SubStr(::cEnvTra, 1, 1))
			
		SC7->(MsUnLock())
		
		SC7->(DbSkip())
		
	EndDo()
	
	SC7->(DbGoTo(nRecNo))
	
Return()


Method GetData() Class TWTransportadorPedidoCompra
	
	::cNumPed := SC7->C7_NUM
	
	::cCodFor := SC7->C7_FORNECE
	::cLojFor := SC7->C7_LOJA
	::cNomFor := Posicione("SA2", 1, xFilial("SA2") + ::cCodFor + ::cLojFor, "A2_NOME")
	::cEstFor := Posicione("SA2", 1, xFilial("SA2") + ::cCodFor + ::cLojFor, "A2_EST")

	::cTipFre := SC7->C7_TPFRETE
	
	If ::cTipFre == "C"
	
		::cCodTra := "000052"
		::nAtEnvTra := 2

	Else
	
		::cCodTra := SC7->C7_YTRANSP
		::nAtEnvTra := If (SC7->C7_YENVTRA == "S", 1, 2)
	
	EndIf
	
	::cNomTra := Posicione("SA4", 1, xFilial("SA4") + ::cCodTra, "A4_NOME")	 

	::nAtEnvAut := If (SC7->C7_YENVAUT == "S", 1, 2)

Return() 