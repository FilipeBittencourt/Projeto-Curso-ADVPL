#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWMotivoCancelamentoPedidoVenda
@author Tiago Rossini Coradini
@since 01/02/2018
@version 1.0
@description Classe para associar o motivo de cancelamento do pedido de venda. 
@obs Ticket: 2123
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
#DEFINE TIT_MAIN_WND "Informe o Motivo do Cancelamento"
#DEFINE TIT_WND "Pedido de Venda: "


Class TWMotivoCancelamentoPedidoVenda From LongClassName
	
	Data oFntBold // Fonte
	Data oDlg // Janela principal
	Data lValid // Identifica se a tela esta validada
	
	// Pedido de Venda
	Data cNumero // Numero
	Data cCliente // Cliente
	Data cLoja // Loja
	Data cItem // Item
	
	// Motivo
	Data cCodMot // Codigo 
	Data cDesMot // Descrição 
	Data cObsMot // Observação
				
	Method New() Constructor
	Method Activate() // Ativa exibicao do objeto
	Method Confirm() // Confima
	Method Validate() // Valida
	Method VldMot() // Valida motivo	
	Method Save() // Salva
	Method GetMot() // Retorna motivo
	
EndClass


Method New() Class TWMotivoCancelamentoPedidoVenda
	
	::oFntBold := TFont():New('Arial',,14,,.T.)
	::oDlg := Nil
	::lValid := .F.			
	
	::cNumero := Space(TamSx3("C5_NUM")[1])
	::cCliente := Space(TamSx3("C5_CLIENTE")[1])
	::cLoja := Space(TamSx3("C5_LOJACLI")[1])
	::cItem := Space(TamSx3("C6_ITEM")[1])
	
	::cCodMot := Space(3)
	::cDesMot := Space(55)
	::cObsMot := Space(250)
		
Return()


Method Activate() Class TWMotivoCancelamentoPedidoVenda
Local oWindow := Nil
	
	// Cria Dialog padrão
	::oDlg := MsDialog():New(0, 0, 200, 500, TIT_MAIN_WND,,,,DS_MODALFRAME,,,,,.T.)
	::oDlg:cName := "oDlg"
	::oDlg:lCentered := .T.
	::oDlg:lEscClose := .T.
	::oDlg:bValid := {|| ::lValid }
	
	// Barra de botoes
	oBtnBar := FWButtonBar():New()
	oBtnBar:Init(::oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)
	oBtnBar:AddBtnText("Salvar", "Salvar", {|| ::Confirm() },,,CONTROL_ALIGN_RIGHT,.T.)
		
	// Layer
	oLayer := FWLayer():New()
	oLayer:Init(::oDlg, .F., .T.)
	
	// Adiciona linha ao Layer
	oLayer:AddLine(LIN, 100, .F.)
	// Adiciona coluna ao Layer
	oLayer:AddCollumn(COL, PER_COL, .T., LIN)
	// Adiciona janela ao Layer
	oLayer:AddWindow(COL, WND, TIT_WND, 100, .F. ,.T.,, LIN, { || })
	
	oLayer:SetWinTitle(COL, WND, TIT_WND + ::cNumero, LIN)
	  
	// Muda fonte do Layes
	oLayer:GetWindow(COL, WND, @oWindow, LIN)			
	oWindow:oTitleBar:oFont := ::oFntBold
	
	// Retorna paimel da janela do Layer
	oPnl := oLayer:GetWinPanel(COL, WND, LIN)	
	
	// Motivo	
	oSayCodMot := TSay():Create(oPnl)
	oSayCodMot:cName := "oSayCodMot"
	oSayCodMot:cCaption := "Motivo"
	oSayCodMot:nLeft := 06
	oSayCodMot:nTop := 06
	oSayCodMot:nWidth := 65
	oSayCodMot:nHeight := 30
	oSayCodMot:cToolTip := "Motivo do cancelamento"	
	
	oGetCodMot:= TGet():Create(oPnl)
	oGetCodMot:cName := "oGetCodMot"
	oGetCodMot:nLeft := 06
	oGetCodMot:nTop := 22
	oGetCodMot:nWidth := 60
	oGetCodMot:nHeight := 20
	oGetCodMot:cVariable := "::cCodMot"
	oGetCodMot:bSetGet := bSetGet(::cCodMot)
	oGetCodMot:Picture := "@!"	
	oGetCodMot:bLostFocus := {|| ::cDesMot := Posicione("SX5", 1, xFilial("SX5") + "ZZ" + ::cCodMot, "X5_DESCRI"), oGetCodMot:Refresh() }			
	oGetCodMot:cF3 := "ZZ"
	oGetCodMot:lHasButton := .T.
	oGetCodMot:cToolTip := "Motivo do cancelamento"
	oGetCodMot:SetFocus()	
	
	// Descrição	
	oSayDscMot := TSay():Create(oPnl)
	oSayDscMot:cName := "oSayDscMot"
	oSayDscMot:cCaption := "Descrição"
	oSayDscMot:nLeft := 80
	oSayDscMot:nTop := 06
	oSayDscMot:nWidth := 65
	oSayDscMot:nHeight := 30
	oSayDscMot:cToolTip := "Descrição do motivo"

	oGetDscMot := TGet():Create(oPnl)
	oGetDscMot:cName := "oGetDscMot"
	oGetDscMot:nLeft := 80
	oGetDscMot:nTop := 22
	oGetDscMot:nWidth := 326 
	oGetDscMot:nHeight := 20
	oGetDscMot:cVariable := "::cDesMot"
	oGetDscMot:bSetGet := bSetGet(::cDesMot)
	oGetDscMot:cToolTip := "Descrição do motivo"
	oGetDscMot:Disable()	
		
	// Observação	
	oSayObsMot := TSay():Create(oPnl)
	oSayObsMot:cName := "oSayObsMot"
	oSayObsMot:cCaption := "Observação"
	oSayObsMot:nLeft := 06
	oSayObsMot:nTop := 64
	oSayObsMot:nWidth := 80
	oSayObsMot:nHeight := 30
	oSayObsMot:cToolTip := "Observação do motivo (250 caracteres)"
		
	oGetObsMot := TGet():Create(oPnl)//TMultiGET():Create(oPnl)
	oGetObsMot:cName := "oGetObsMot"
	oGetObsMot:nLeft := 06
	oGetObsMot:nTop := 80
	oGetObsMot:nWidth := 472
	oGetObsMot:nHeight := 20
	oGetObsMot:cVariable := "::cObsMot"
	oGetObsMot:bSetGet := bSetGet(::cObsMot)
	oGetObsMot:cToolTip := "Observação do motivo (250 caracteres)"

	::oDlg:Activate()

Return()


Method Confirm() Class TWMotivoCancelamentoPedidoVenda
		
	If ::Validate()				
		
		::lValid := .T.

		::oDlg:End()

	EndIf	

Return()


Method Validate() Class TWMotivoCancelamentoPedidoVenda
Local lRet := .T.	
	
	lRet := ::VldMot()
		
Return(lRet)


Method VldMot() Class TWMotivoCancelamentoPedidoVenda
Local lRet := .T.

	If !Empty(::cCodMot)
	
		DbSelectArea("SX5")
		DbSetOrder(1)
		If !SX5->(DbSeek(xFilial("SX5") + "ZZ" + ::cCodMot))
		
			lRet := .F.
			
			MsgAlert("Atenção, código do motivo de cancelamento inválido.")
					
		EndIf
		
	Else
	
		MsgAlert("Atenção, código do motivo de cancelamento inválido.")
	
	EndIf
	
Return(lRet)


Method Save() Class TWMotivoCancelamentoPedidoVenda
Local cSQL := ""

	cSQL := " UPDATE "+ RetSqlName("SC6")
	cSQL += " SET C6_YDTRESI = "+ ValToSQL(dDataBase)
	cSQL += " ,C6_YMOTIVO = "+ ValToSQL(::cCodMot)
	cSQL += " ,C6_YOBSMOT = "+ ValToSQL(FwCutOff(::cObsMot, .T.))
	cSQL += " WHERE	C6_FILIAL	= "+ ValToSQL(xFilial("SC6"))
	cSQL += "	AND C6_NUM = "+ ValToSQL(::cNumero)
	cSQL += "	AND C6_CLI = "+ ValToSQL(::cCliente)
	cSQL += "	AND C6_LOJA = "+ ValToSQL(::cLoja)
	
	If !Empty(::cItem)
		cSQL += "	AND C6_ITEM = "+ ValToSQL(::cItem)
	EndIf
	
	cSQL += "	AND C6_QTDVEN-C6_QTDENT > 0 "
	cSQL += "	AND C6_BLQ <> 'R' "	
	cSQL += "	AND D_E_L_E_T_ = '' "

	TcSQLExec(cSQL)
		
Return()


Method GetMot() Class TWMotivoCancelamentoPedidoVenda
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT TOP 1 C6_YMOTIVO "
	cSQL += " FROM "+ RetSqlName("SC6")
	cSQL += " WHERE C6_FILIAL = "+ ValToSQL(xFilial("SC6"))
	cSQL += "	AND C6_NUM = "+ ValToSQL(::cNumero)
	cSQL += "	AND C6_CLI = "+ ValToSQL(::cCliente)
	cSQL += "	AND C6_LOJA = "+ ValToSQL(::cLoja)
	cSQL += " AND C6_YMOTIVO <> '' "
	cSQL += "	AND C6_OK	"+ If (ThisInv(), "<>", "=") + ValToSQL(ThisMark())
	cSQL += "	AND C6_BLQ <> 'R' "
	cSQL += "	AND D_E_L_E_T_ = ''
	
	TcQuery cSQL New Alias (cQry)

	If Empty((cQry)->C6_YMOTIVO)
	
		lRet := .F.
		
		::cCodMot := Space(3)
	
	Else
	
		::cCodMot := (cQry)->C6_YMOTIVO
	
	EndIf

	(cQry)->(DbCloseArea())

Return(lRet)