#INCLUDE "TOTVS.CH"

User Function FCLA0027; Return()

/*
|-----------------------------------------------------------|
| Classe: | TWConsultaClienteCCB														|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas				|
| Data:		| 27/04/16																				|
|-----------------------------------------------------------|
| Desc.:	|	Consulta de credito do cliente via site do ccb	|
|-----------------------------------------------------------|
| OS:			|	4647-15 - Vagner Amaro													|
|-----------------------------------------------------------|
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
#DEFINE TIT_MAIN_WND "Visualizador de Histórico de Crédito"
#DEFINE TIT_WND "Cliente: "


Class TWConsultaClienteCCB From LongClassName

	// Dados do Cliente
	Data cCodigo // Codigo
	Data cLoja // Loja
	Data cNome // Nome
	Data cCNPJ // CNPJ

	// Dados de acesso ao site 
	Data cCCBLogin
	Data cCCBSenha
	Data cCCBCNPJ
	Data cCCBMercado
	Data cCCBLink	

	// MsDialog
	Data oDlg 
	
	// Layer 
	Data oLayer 
	
	// Array com a coordenadas de tela
	Data aCoors
	
	Data oWeb // Internet Browse
	Data oButtonBar // Barra de botoes
	
	// Paineis
	Data oPnl
	
	Data oParam // Parametro
				
	Method New(cCodigo, cLoja) Constructor // Metodo construtor
	Method LoadInterface() // Carrega a interface principal
	Method LoadDialog() // Carrega Dialog principal
	Method LoadButtonBar() // Carrega barra de botoes	
	Method LoadLayer() // Carrega Layer principal
	Method LoadBrowser() // Carrega Browse com ou sem edição
	Method Activate() // Ativa exibicao do objeto	
	Method ParamBox() // Exibe tela de parametros
	Method UpdPass() // Atualiza senha
			
EndClass


// construtor da classe
Method New(cCodigo, cLoja) Class TWConsultaClienteCCB
	
	::cCodigo := cCodigo
	::cLoja := cLoja
	::cNome := Posicione("SA1", 1, xFilial("SA1") + ::cCodigo + ::cLoja, "A1_NOME")
	::cCNPJ := Posicione("SA1", 1, xFilial("SA1") + ::cCodigo + ::cLoja, "A1_CGC")

	::cCCBLogin := "wellison.toras@biancogres.com.br"
	::cCCBSenha := If (cEmpAnt == "01", GetMv("MV_CCBPASS"), U_FROPCPRO("01", "01", "SuperGetMv", "MV_CCBPASS")) 
	::cCCBCNPJ := SubStr(::cCNPJ, 1, 8)
	::cCCBMercado := "N"
	::cCCBLink := "http://www.ccb.inf.br/Conveniado/Consulta/ConsFicha.asp?Email="+ ::cCCBLogin +"&Senha="+ ::cCCBSenha +"&CNPJ="+ ::cCCBCNPJ +"&Mercado="+ ::cCCBMercado

	::oDlg := Nil
	::oLayer := Nil	
	::aCoors := {}
		
	::oWeb := Nil
	
	::oButtonBar := Nil
			
	::oPnl := Nil
	
	::oParam := TParBIAF033():New()
		
Return()


// Contrutor da interface
Method LoadInterface() Class TWConsultaClienteCCB
	
	::LoadDialog()
	
	::LoadButtonBar()

	::LoadLayer()	
	
	::LoadBrowser()
		
Return()


Method LoadDialog() Class TWConsultaClienteCCB
	
	::aCoors := FWGetDialogSize(oMainWnd)	
		
	::oDlg := MsDialog():Create()
	::oDlg:cName := "oDlg"
	::oDlg:cCaption := TIT_MAIN_WND 
	::oDlg:nTop := ::aCoors[1]
	::oDlg:nLeft := ::aCoors[2]
	::oDlg:nHeight := ::aCoors[3] / 1.25
	::oDlg:nWidth := ::aCoors[4] / 1.45
	::oDlg:lShowHint := .F.
	::oDlg:lCentered := .T.
		
Return()


Method LoadButtonBar() Class TWConsultaClienteCCB

	::oButtonBar := FWButtonBar():New()
	::oButtonBar:Init(::oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)

	::oButtonBar:AddBtnText("Sair", "", {|| ::oDlg:End() },,,CONTROL_ALIGN_RIGHT,.T.)
	::oButtonBar:AddBtnText("Alt. Senha", "", {|| ::UpdPass() },,,CONTROL_ALIGN_RIGHT,.T.)
	::oButtonBar:AddBtnText("Pesquisar", "", {|| ::ParamBox() },,,CONTROL_ALIGN_RIGHT,.T.)
	::oButtonBar:AddBtnText("Imprimir", "", {|| ::oWeb:PrintPDF() },,,CONTROL_ALIGN_RIGHT,.T.)
	
Return()


Method LoadLayer() Class TWConsultaClienteCCB

	::oLayer := FWLayer():New()
	::oLayer:Init(::oDlg,.F.,.T.)

	::oLayer:AddLine(LIN, PER_LIN, .F.)
	::oLayer:AddCollumn(COL, PER_COL, .T., LIN)			
	::oLayer:AddWindow(COL, WND, TIT_WND + AllTrim(::cCodigo) +"-"+ AllTrim(::cLoja) +"-"+ AllTrim(::cNome), 100, .F. ,.T.,, LIN, { || })
		
Return()


// Carrega Browser
Method LoadBrowser() Class TWConsultaClienteCCB
	
	// Painel acima
	::oPnl := ::oLayer:GetWinPanel(COL, WND, LIN)
		
	::oWeb := TWebEngine():New(::oPnl, 0, 0, 0, 0, ::cCCBLink)	
	::oWeb:Align := CONTROL_ALIGN_ALLCLIENT
								
Return()


Method Activate() Class TWConsultaClienteCCB
	
	::LoadInterface()
		
	::oDlg:Activate()
	
Return()


Method ParamBox() Class TWConsultaClienteCCB
Local cLink := ""	
	
	If ::oParam:Box()
		
		cLink := "http://www.ccb.inf.br/Conveniado/Consulta/ConsFicha.asp?Email="+ ::cCCBLogin +"&Senha="+ ::cCCBSenha +"&CNPJ="+ SubStr(::oParam:cCNPJ, 1, 8) +"&Mercado="+ ::cCCBMercado
 
		::oWeb:Navigate(cLink)
				
		U_BIAMsgRun("Atualizando Consulta de Crédito...", "Aguarde!", {|| Sleep(3000) })
		
	EndIf
	
Return()


Method UpdPass() Class TWConsultaClienteCCB

	If cEmpAnt == "01"
	
		U_BIAF079("MV_CCBPASS", "044")
	
	Else
	
		MsgAlert("A alteração da senha somente é permitida na empresa 01-Biacogres.", "Validação de Acesso!")
	
	EndIf

Return()