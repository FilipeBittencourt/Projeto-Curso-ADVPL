#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TWRescisaoVendedor
@author Tiago Rossini Coradini
@since 29/11/2016
@version 1.0
@description Classe (tela) para visualizar as informações de rescisão do vendedor 
@obs OS: 3861-16 - Ranisses Corona
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
#DEFINE TIT_MAIN_WND "Informações de Rescisão do Vendedor"
#DEFINE TIT_WND "Rescisões do Vendedor:"

// DESCRICAO E IMAGENS DOS BOTOES DA BARRA PRINCIPAL (oBtnBar)
#DEFINE DSC_BTN_CLOSE "Sair"


Class TWRescisaoVendedor From LongClassName

	// Msdialog
	Data oDlg 
	
	// Layer 
	Data oLayer
	
	// Array com a coordenadas de tela
	Data aCoors

	Data oBtnBar // Barra de Botoes 	

	// Paineis
	Data oPnl

	// MsNewGetDados
	Data oBrw // Browse (MsNewGetDados) - Vendedor Origem	
	Data oField // Objeto (TGDField) para criacao dinamica das colunas Header	
		
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
	
EndClass


// construtor da classe
Method New() Class TWRescisaoVendedor
	
	::oDlg := Nil
	::oLayer := Nil	
	::aCoors := {}
		
	::oBtnBar := Nil
		
	::oPnl := Nil

	::oBrw := Nil	
	
	::oField := TGDField():New()
		
Return()


// Contrutor da interface
Method LoadInterface() Class TWRescisaoVendedor
	
	::LoadDialog()

	::LoadButtonBar()
	
	::LoadLayer()
	
	::LoadLine()	
			
Return()


Method LoadDialog() Class TWRescisaoVendedor
	
	::aCoors := FWGetDialogSize(oMainWnd)			
	
	::oDlg := MsDialog():Create()
	::oDlg:cName := "oDlg"
	::oDlg:cCaption := TIT_MAIN_WND 
	::oDlg:nTop := ::aCoors[1]
	::oDlg:nLeft := ::aCoors[2]
	::oDlg:nHeight := ::aCoors[3]
	::oDlg:nWidth := ::aCoors[4] / 1.5
	::oDlg:lCentered := .T.
	::oDlg:lEscClose := .T.		
	
Return()


Method LoadLayer() Class TWRescisaoVendedor

	::oLayer := FWLayer():New()
	::oLayer:Init(::oDlg)

Return()


// Carrega linha
Method LoadLine() Class TWRescisaoVendedor
Local cVldDef := "AllwaysTrue"

	::oLayer:AddLine(LIN, PER_LIN, .F.)
	
	::oLayer:AddCollumn(COL, PER_COL, .T., LIN)
	
	::oLayer:AddWindow(COL, WND, TIT_WND + SA3->A3_COD + " - " + AllTrim(SA3->A3_NREDUZ), PER_WIN, .F. ,.T.,, LIN, { || })
	
	::oPnl := ::oLayer:GetWinPanel(COL, WND, LIN)
		 
	::SetWinFont(COL, WND, LIN)
	
	::oBrw := MsNewGetDados():New(0, 0, 0, 0, 0, cVldDef, cVldDef, "", {},,, cVldDef,, cVldDef, ::oPnl, ::GetHeader(), ::GetData())
	::oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrw:oBrowse:lVScroll := .T.
	::oBrw:oBrowse:lHScroll := .T.
					
Return()


Method LoadButtonBar() Class TWRescisaoVendedor
	
	::oBtnBar := FWButtonBar():New()		
	
	::oBtnBar:Init(::oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)
		
	::oBtnBar:AddBtnText(DSC_BTN_CLOSE, DSC_BTN_CLOSE, {|| ::oDlg:End() },,,CONTROL_ALIGN_RIGHT, .T.)

Return()


Method Activate() Class TWRescisaoVendedor	
	
	::LoadInterface()

	//::oDlg:bInit := {|| ::Refresh()}	
	::oDlg:Activate()
			
Return()


Method SetWinFont(cIDCol, cIDWin, cIDLin) Class TWRescisaoVendedor
Local oWindow := Nil
	
	::oLayer:GetWindow(cIDCol, cIDWin, @oWindow, cIDLin)
		
	oWindow:oTitleBar:oFont := TFont():New("MS Sans Serif",,18,,.T.)
	
Return()


Method GetHeader() Class TWRescisaoVendedor

	::oField:Clear()
	
	::oField:AddField("EMP") 	
	::oField:FieldName("EMP"):cTitle := "Empresa"
	::oField:FieldName("EMP"):cPict := "@!"
	::oField:FieldName("EMP"):nSize := 10
	::oField:FieldName("EMP"):cType := "C"
	
	::oField:AddField("Z78_DTRESC")
	::oField:AddField("Z78_OBS")
	::oField:AddField("Z78_VALOR")
	::oField:AddField("Z78_MARCA")
	::oField:AddField("Z37_DESCR")
		
Return(::oField:GetHeader())


Method GetData() Class TWRescisaoVendedor
Local aCols := {}
Local cSQL := ""
Local cQry := GetNextAlias()	
	
	cSQL := " SELECT * FROM FNC_RESCISAO_VENDEDOR("+ ValToSQL(SA3->A3_COD) +") " 

	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())	
				
		aAdd(aCols, {Capital((cQry)->EMP), sToD((cQry)->Z78_DTRESC), (cQry)->Z78_OBS, (cQry)->Z78_VALOR, (cQry)->Z78_MARCA, (cQry)->Z37_DESCR, .F.})
								 								
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())
			
Return(aCols)