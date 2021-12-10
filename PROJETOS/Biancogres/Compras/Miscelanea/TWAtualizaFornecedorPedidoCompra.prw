#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWAtualizaFornecedorPedidoCompra
@author Tiago Rossini Coradini
@since 23/02/2018
@version 1.0
@description Classe para atualização do fornecedor do pedido de compra 
@obs Ticket: 2599 - Projeto Demandas Compras - Pacote 2 - Item 24
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
#DEFINE TIT_MAIN_WND "Informe o novo fornecedor do pedido: "
#DEFINE TIT_WND "Dados do fornecedor"


Class TWAtualizaFornecedorPedidoCompra From LongClassName
	
	Data oFntBold // Fonte
	Data oDlg // Janela principal
	
	// Pedido de Compra
	Data cNumPed // Numero
	
	// Fornecedor Atual
	Data cCodFor // Codigo	
	Data cLojFor // Loja
	Data cNomFor // Nome
	Data cCnpj // Cnpj

	// Novo Fornecedor
	Data cCodNFor // Codigo	
	Data cLojNFor // Loja
	Data cNomNFor // Nome
	Data cCnpjN // Cnpj
			
	Method New() Constructor
	Method Activate() // Ativa exibicao do objeto
	Method Confirm() // Confima
	Method Validate() // Valida
	Method Save() // Salva
	Method SaveLog() // Salva log de alteracao
	Method GetData()
	Method LostFocus()
	Method EnchExecTrig(cFornece, cCodLoja)
	
EndClass


Method New() Class TWAtualizaFornecedorPedidoCompra
	
	::oFntBold := TFont():New('Arial',,14,,.T.)				
	::oDlg := Nil
	
	::cCodFor := Space(TamSx3("C7_FORNECE")[1])
	::cLojFor := Space(TamSx3("C7_LOJA")[1])
	::cNomFor := Space(TamSx3("A2_NOME")[1])
	::cCnpj := Space(TamSx3("A2_CGC")[1])

	::cCodNFor := Space(TamSx3("C7_FORNECE")[1])
	::cLojNFor := Space(TamSx3("C7_LOJA")[1])
	::cNomNFor := Space(TamSx3("A2_NOME")[1])
	::cCnpjN := Space(TamSx3("A2_CGC")[1])	

Return()


Method Activate() Class TWAtualizaFornecedorPedidoCompra
Local oWindow := Nil
	
	::GetData()
		
	// Cria Dialog padrão
	::oDlg := MsDialog():New(0, 0, 210, 550, TIT_MAIN_WND + ::cNumPed,,,,,,,,,.T.)
	::oDlg:cName := "oDlg"
	::oDlg:lCentered := .T.
	::oDlg:lEscClose := .F.
	::oDlg:bValid := {|| .T. }
	
	// Barra de botoes
	oBtnBar := FWButtonBar():New()
	oBtnBar:Init(::oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)
	
	oBtnBar:AddBtnText("Salvar", "Salvar", {|| ::Confirm() },,,CONTROL_ALIGN_RIGHT,.T.)
	oBtnBar:AddBtnText("Cancelar", "Cancelar", {|| ::oDlg:End() },,,CONTROL_ALIGN_RIGHT,.T.)	
		
	// Layer
	oLayer := FWLayer():New()
	oLayer:Init(::oDlg, .F., .T.)
	
	// Adiciona linha ao Layer
	oLayer:AddLine(LIN, 100, .F.)
	// Adiciona coluna ao Layer
	oLayer:AddCollumn(COL, PER_COL, .T., LIN)
	// Adiciona janela ao Layer
	oLayer:AddWindow(COL, WND, TIT_WND, 100, .F. ,.T.,, LIN, { || })
	
	oLayer:SetWinTitle(COL, WND, TIT_WND, LIN)
	  
	// Muda fonte do Layes
	oLayer:GetWindow(COL, WND, @oWindow, LIN)			
	oWindow:oTitleBar:oFont := ::oFntBold
	
	// Retorna paimel da janela do Layer
	oPnl := oLayer:GetWinPanel(COL, WND, LIN)	
	
	// Fornecedor	
	oSayCodFor := TSay():Create(oPnl)
	oSayCodFor:cName := "oSayCodFor"
	oSayCodFor:cCaption := "Atual"
	oSayCodFor:nLeft := 06
	oSayCodFor:nTop := 06
	oSayCodFor:nWidth := 65
	oSayCodFor:nHeight := 30
	oSayCodFor:cToolTip := "Código do fornecedor atual"	
	
	oGetCodFor:= TGet():Create(oPnl)
	oGetCodFor:cName := "oGetCodFor"
	oGetCodFor:nLeft := 06
	oGetCodFor:nTop := 22
	oGetCodFor:nWidth := 60
	oGetCodFor:nHeight := 20
	oGetCodFor:cVariable := "::cCodFor"
	oGetCodFor:bSetGet := bSetGet(::cCodFor)
	oGetCodFor:Picture := PesqPict("SA2", "A2_COD")
	oGetCodFor:cToolTip := "Código do fornecedor atual"
	oGetCodFor:Disable()		
	
	// Loja	
	oSayLojFor := TSay():Create(oPnl)
	oSayLojFor:cName := "oSayLojFor"
	oSayLojFor:cCaption := "Loja"
	oSayLojFor:nLeft := 80
	oSayLojFor:nTop := 06
	oSayLojFor:nWidth := 65
	oSayLojFor:nHeight := 30
	oSayLojFor:cToolTip := "Loja do fornecedor atual"	
	
	oGetLojFor := TGet():Create(oPnl)
	oGetLojFor:cName := "oGetLojFor"
	oGetLojFor:nLeft := 80
	oGetLojFor:nTop := 22
	oGetLojFor:nWidth := 60 
	oGetLojFor:nHeight := 20
	oGetLojFor:cVariable := "::cLojFor"
	oGetLojFor:bSetGet := bSetGet(::cLojFor)
	oGetLojFor:Picture := PesqPict("SA2", "A2_LOJA")
	oGetLojFor:cToolTip := "Loja do fornecedor atual"
	oGetLojFor:Disable()

	// Nome	
	oSayNomFor := TSay():Create(oPnl)
	oSayNomFor:cName := "oSayNomFor"
	oSayNomFor:cCaption := "Nome"
	oSayNomFor:nLeft := 154
	oSayNomFor:nTop := 06
	oSayNomFor:nWidth := 65
	oSayNomFor:nHeight := 30
	oSayNomFor:cToolTip := "Nome do fornecedor atual"
	
	oGetNomFor := TGet():Create(oPnl)
	oGetNomFor:cName := "oGetNomFor"
	oGetNomFor:nLeft := 154
	oGetNomFor:nTop := 22
	oGetNomFor:nWidth := 250 
	oGetNomFor:nHeight := 20
	oGetNomFor:cVariable := "::cNomFor"
	oGetNomFor:bSetGet := bSetGet(::cNomFor)
	oGetNomFor:Picture := PesqPict("SA2", "A2_NOME")
	oGetNomFor:cToolTip := "Nome do fornecedor atual"
	oGetNomFor:Disable()	
	
	// CNPJ	
	oSayCnpj := TSay():Create(oPnl)
	oSayCnpj:cName := "oSayCnpj"
	oSayCnpj:cCaption := "CNPJ"
	oSayCnpj:nLeft := 418
	oSayCnpj:nTop := 06
	oSayCnpj:nWidth := 65
	oSayCnpj:nHeight := 30
	oSayCnpj:cToolTip := "CNPJ do fornecedor atual"			

	oGetCnpj := TGet():Create(oPnl)
	oGetCnpj:cName := "oGetCnpj"
	oGetCnpj:nLeft := 418
	oGetCnpj:nTop := 22
	oGetCnpj:nWidth := 110 
	oGetCnpj:nHeight := 20
	oGetCnpj:cVariable := "::cCnpj"
	oGetCnpj:bSetGet := bSetGet(::cCnpj)
	oGetCnpj:Picture := PesqPict("SA2", "A2_CGC")
	oGetCnpj:cToolTip := "CNPJ do fornecedor atual"
	oGetCnpj:Disable()		

	// Novo Fornecedor	
	oSayCodNFor := TSay():Create(oPnl)
	oSayCodNFor:cName := "oSayCodNFor"
	oSayCodNFor:cCaption := "Novo"
	oSayCodNFor:nLeft := 06
	oSayCodNFor:nTop := 64
	oSayCodNFor:nWidth := 65
	oSayCodNFor:nHeight := 30
	oSayCodNFor:oFont := ::oFntBold
	oSayCodNFor:cToolTip := "Código do novo fornecedor"	
	
	oGetCodNFor:= TGet():Create(oPnl)
	oGetCodNFor:cName := "oGetCodNFor"
	oGetCodNFor:nLeft := 06
	oGetCodNFor:nTop := 80
	oGetCodNFor:nWidth := 70
	oGetCodNFor:nHeight := 20
	oGetCodNFor:cVariable := "::cCodNFor"
	oGetCodNFor:bSetGet := bSetGet(::cCodNFor)
	oGetCodNFor:Picture := PesqPict("SA2", "A2_COD")
	oGetCodNFor:bLostFocus := {|| ::LostFocus() }
	oGetCodNFor:cF3 := "FOR"
	oGetCodNFor:lHasButton := .T.
	oGetCodNFor:cToolTip := "Código do novo fornecedor"
	oGetCodNFor:SetFocus()
	
	// Loja	
	oSayLojNFor := TSay():Create(oPnl)
	oSayLojNFor:cName := "oSayLojNFor"
	oSayLojNFor:cCaption := "Loja"
	oSayLojNFor:nLeft := 80
	oSayLojNFor:nTop := 64
	oSayLojNFor:nWidth := 65
	oSayLojNFor:nHeight := 30
	oSayLojNFor:cToolTip := "Loja do novo fornecedor"	
	
	oGetLojNFor := TGet():Create(oPnl)
	oGetLojNFor:cName := "oGetLojNFor"
	oGetLojNFor:nLeft := 80
	oGetLojNFor:nTop := 80
	oGetLojNFor:nWidth := 60 
	oGetLojNFor:nHeight := 20
	oGetLojNFor:cVariable := "::cLojNFor"
	oGetLojNFor:bSetGet := bSetGet(::cLojNFor)
	oGetLojNFor:Picture := PesqPict("SA2", "A2_LOJA")
	oGetLojNFor:cToolTip := "Loja do novo fornecedor"
	//oGetLojNFor:lReadOnly := .T.
	oGetLojNFor:Disable()

	// Nome	
	oSayNomNFor := TSay():Create(oPnl)
	oSayNomNFor:cName := "oSayNomNFor"
	oSayNomNFor:cCaption := "Nome"
	oSayNomNFor:nLeft := 154
	oSayNomNFor:nTop := 64
	oSayNomNFor:nWidth := 65
	oSayNomNFor:nHeight := 30
	oSayNomNFor:cToolTip := "Nome do novo fornecedor"
	
	oGetNomNFor := TGet():Create(oPnl)
	oGetNomNFor:cName := "oGetNomNFor"
	oGetNomNFor:nLeft := 154
	oGetNomNFor:nTop := 80
	oGetNomNFor:nWidth := 250 
	oGetNomNFor:nHeight := 20
	oGetNomNFor:cVariable := "::cNomNFor"
	oGetNomNFor:bSetGet := bSetGet(::cNomNFor)
	oGetNomNFor:Picture := PesqPict("SA2", "A2_NOME")
	oGetNomNFor:cToolTip := "Nome do novo fornecedor"
	oGetNomNFor:Disable()	

	// CNPJ	
	oSayCnpjN := TSay():Create(oPnl)
	oSayCnpjN:cName := "oSayCnpjN"
	oSayCnpjN:cCaption := "CNPJ"
	oSayCnpjN:nLeft := 418
	oSayCnpjN:nTop := 64
	oSayCnpjN:nWidth := 65
	oSayCnpjN:nHeight := 30
	oSayCnpjN:cToolTip := "CNPJ do novo fornecedor"	
	
	oGetCnpjN := TGet():Create(oPnl)
	oGetCnpjN:cName := "oGetCnpjN"
	oGetCnpjN:nLeft := 418
	oGetCnpjN:nTop := 80
	oGetCnpjN:nWidth := 110 
	oGetCnpjN:nHeight := 20
	oGetCnpjN:cVariable := "::cCnpjN"
	oGetCnpjN:bSetGet := bSetGet(::cCnpjN)
	oGetCnpjN:Picture := PesqPict("SA2", "A2_CGC")
	oGetCnpjN:cToolTip := "CNPJ do novo fornecedor"
	oGetCnpjN:Disable()										
	
	::oDlg:Activate()

Return()


Method Confirm() Class TWAtualizaFornecedorPedidoCompra
	
	If ::Validate()
		
		::Save()
		
		::SaveLog()		

		::oDlg:End()

	EndIf

Return()


Method Validate() Class TWAtualizaFornecedorPedidoCompra
Local lRet := .T.

	If !Empty(::cCodNFor) .And. !Empty(::cLojNFor)  
	
		DbSelectArea("SA2")
		DbSetOrder(1)
		If SA2->(DbSeek(xFilial("SA2") + ::cCodNFor + ::cLojNFor))
		
			If SA2->A2_MSBLQL == "1"
				
				lRet := .F.
				
				MsgAlert("Atenção, o fornecedor selecionado está bloqueado para uso.")
			
			ElseIf SubStr(SA2->A2_CGC, 1, 8) <> SubStr(::cCnpj, 1, 8)  
				
				lRet := .F.
				
				MsgAlert("Atenção, a raiz do CNPJ do novo fornecedor está diferente do fornecedor atual.")
			
			ElseIf SA2->A2_CGC == ::cCnpj
			
				lRet := .F.
				
				MsgAlert("Atenção, o CNPJ do novo fornecedor é igual ao do fornecedor atual.")
			
			ElseIf ::cCodNFor + ::cLojNFor == ::cCodFor + ::cLojFor
			
				lRet := .F.
				
				MsgAlert("Atenção, o novo fornecedor é igual ao fornecedor atual.")
				
			EndIf						
		
		Else
		
			lRet := .F.
			
			MsgAlert("Atenção, fornecedor inválido.")
		
		EndIf

	Else
	
		lRet := .F.
		
		MsgAlert("Atenção, fornecedor inválido.")
			
	EndIf
	
Return(lRet)


Method Save() Class TWAtualizaFornecedorPedidoCompra
Local aArea := GetArea()
		
	DbSelectArea("SA2")
	DbSetOrder(1)
	If SA2->(DbSeek(xFilial("SA2") + ::cCodNFor + ::cLojNFor))
		
		While !SC7->(Eof()) .And. SC7->C7_NUM == ::cNumPed
	
			DbSelectArea("SC8")
			DbSetOrder(2)   
			If SC8->(DbSeek(xFilial("SC8") + SC7->(C7_NUMCOT + C7_PRODUTO + C7_FORNECE + C7_LOJA + C7_NUM + C7_ITEM)))
			
				RecLock("SC8", .F.)

					SC8->C8_FORNECE := ::cCodNFor
					SC8->C8_LOJA := ::cLojNFor
					SC8->C8_FORNOME := SA2->A2_NOME
					SC8->C8_FORMAIL := SA2->A2_EMAIL
					SC8->C8_CONTATO := SA2->A2_CONTATO
							
				SC8->(MsUnLock())
			
			EndIf
	
			RecLock("SC7", .F.)
			
				SC7->C7_FORNECE := ::cCodNFor
				SC7->C7_LOJA := ::cLojNFor
				SC7->C7_CONTATO := SA2->A2_CONTATO
				
			SC7->(MsUnLock())
			
			SC7->(DbSkip())			
						
		EndDo()
	
	EndIf		
	
	RestArea(aArea)	
	
Return()


Method SaveLog() Class TWAtualizaFornecedorPedidoCompra

	RecLock("ZC7", .T.)
	
		ZC7->ZC7_FILIAL := xFilial("ZC7")
		ZC7->ZC7_CODIGO := GetSxEnum("ZC7", "ZC7_CODIGO")
		ZC7->ZC7_PEDIDO := ::cNumPed
		ZC7->ZC7_CODFOR := ::cCodFor
		ZC7->ZC7_LOJA := ::cLojFor
		ZC7->ZC7_CODUSR := RetCodUsr()
		ZC7->ZC7_NOMUSR := UsrRetName(RetCodUsr())
		ZC7->ZC7_DATA := dDataBase
		ZC7->ZC7_HORA := Time()
	
	ZC7->(MsUnLock())

Return()


Method GetData() Class TWAtualizaFornecedorPedidoCompra
	
	::cNumPed := SC7->C7_NUM
	
	::cCodFor := SC7->C7_FORNECE
	::cLojFor := SC7->C7_LOJA
	::cNomFor := Posicione("SA2", 1, xFilial("SA2") + ::cCodFor + ::cLojFor, "A2_NOME")
	::cCnpj := Posicione("SA2", 1, xFilial("SA2") + ::cCodFor + ::cLojFor, "A2_CGC")

Return() 


Method LostFocus() Class TWAtualizaFornecedorPedidoCompra
Local aArea := GetArea()
	
	DbSelectArea("SA2")
	SA2->(dbSetOrder(1))	
	
	If !Empty(::cCodNFor)
			
		If SA2->(MsSeek(xFilial("SA2") + ::cCodNFor + ::cLojNFor)) .Or. SA2->(MsSeek(xFilial("SA2") + ::cCodNFor))

			::cLojNFor := SA2->A2_LOJA							 													    
			::cNomNFor := SA2->A2_NOME
			::cCnpjN := SA2->A2_CGC
		
		Else
			
			::cLojNFor := Space(TamSx3("C7_LOJA")[1])
			::cNomNFor := Space(TamSx3("A2_NOME")[1])
			::cCnpjN := Space(TamSx3("A2_CGC")[1])
			
		EndIf
			
	EndIf
	
	oGetLojNFor:Refresh()				 													    
	oGetNomNFor:Refresh()					
	oGetCnpjN:Refresh()	
	
	RestArea(aArea)
	
Return()
