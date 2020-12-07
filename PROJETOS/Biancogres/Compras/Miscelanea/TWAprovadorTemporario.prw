#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TWAprovadorTemporario
@author Tiago Rossini Coradini
@since 22/06/2017
@version 1.0
@description Classe para atualização de aprovadores de compra temporarios. 
@obs OS: 0179-17 - Ranisses Corona
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
#DEFINE TIT_MAIN_WND "Aprovação Temporaria de Compra"
#DEFINE TIT_WND "Dados dos Aprovadores: "


Class TWAprovadorTemporario From LongClassName
	
	Data oFntBold // Fonte
	Data oDlg // Janela principal
	Data cCodApr // Codigo do aprovador
	Data cNomApr // Nome do aprovador
	Data cCodAprT // Codigo do aprovador temporario
	Data cNomAprT // Nome do aprovador temporario
			
	Method New() Constructor
	Method Activate() // Ativa exibicao do objeto
	Method Confirm() // Confima
	Method Cancel() // Cancela
	Method Validate() // Valida
	Method Save() // Salva
	Method SetFocus()
	
EndClass


Method New() Class TWAprovadorTemporario
			
	DbSelectArea("SAK")
	DbSetOrder(2)
	If SAK->(DbSeek(xFilial("SAK") + __cUserId))
	
		::oFntBold := TFont():New('Arial',,14,,.T.)
		::cCodApr := SAK->AK_USER
		::cNomApr := SAK->AK_NOME
		::cCodAprT := SAK->AK_APROSUP
		::cNomAprT := UsrFullName(Posicione("SAK", 1, xFilial("SAK") + SAK->AK_APROSUP, "AK_USER"))
  		
	Else
	
		MsgAlert("Atenção, o usuário: " + __cUserId + "-" + AllTrim(cUserName) + " não é um aprovador.")
	
	EndIf
					
Return()


Method Activate() Class TWAprovadorTemporario
Local oWindow := Nil
	
	If !Empty(::cCodApr)
				
		// Cria Dialog padrão
		::oDlg := MsDialog():New(0, 0, 200, 420, TIT_MAIN_WND,,,,,,,,,.T.)
		::oDlg:cName := "oDlg"
		::oDlg:lCentered := .T.
		::oDlg:lEscClose := .F.
		::oDlg:bValid := {|| .F. }
			
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
				
		oSayApr := TSay():Create(oPnl)
		oSayApr:cName := "oSayApr"
		oSayApr:cCaption := "Aprovador"
		oSayApr:nLeft := 06
		oSayApr:nTop := 06
		oSayApr:nWidth := 100
		oSayApr:nHeight := 30
		oSayApr:lReadOnly := .T.
		oSayApr:oFont := ::oFntBold
		oSayApr:cToolTip := "Código do aprovador"
		
		oGetApr := TGet():Create(oPnl)
		oGetApr:cName := "oGetApr"
		oGetApr:nLeft := 06
		oGetApr:nTop := 22
		oGetApr:nWidth := 80
		oGetApr:nHeight := 20
		oGetApr:cVariable := "::cCodApr"
		oGetApr:bSetGet := bSetGet(::cCodApr)
		oGetApr:Picture := PesqPict("SAK", "AK_USER")
		oGetApr:lHasButton := .T. 	
		oGetApr:cToolTip := "Código do aprovador"	
		oGetApr:Disable()
	
		oGetNom := TGet():Create(oPnl)
		oGetNom:cName := "oGetNom"
		oGetNom:nLeft := 96
		oGetNom:nTop := 22
		oGetNom:nWidth := 300 
		oGetNom:nHeight := 20
		oGetNom:cVariable := "::cNomApr"
		oGetNom:bSetGet := bSetGet(::cNomApr)		
		oGetNom:Picture := "@!"
		oGetNom:cToolTip := "Nome do aprovador"
		oGetNom:Disable()	

		oSayAprTmp := TSay():Create(oPnl)
		oSayAprTmp:cName := "oSayAprTmp"
		oSayAprTmp:cCaption := "Temporário"
		oSayAprTmp:nLeft := 06
		oSayAprTmp:nTop := 64
		oSayAprTmp:nWidth := 100
		oSayAprTmp:nHeight := 30
		oSayAprTmp:lReadOnly := .T.
		oSayAprTmp:oFont := ::oFntBold
		oSayAprTmp:cToolTip := "Código do aprovador temporário"
		
		oGetAprTmp := TGet():Create(oPnl)
		oGetAprTmp:cName := "oGetAprTmp"
		oGetAprTmp:nLeft := 06
		oGetAprTmp:nTop := 80
		oGetAprTmp:nWidth := 80
		oGetAprTmp:nHeight := 20
		oGetAprTmp:cVariable := "::cCodAprT"
		oGetAprTmp:bSetGet := bSetGet(::cCodAprT)
		oGetAprTmp:Picture := PesqPict("SAK", "AK_APROSUP")
		oGetAprTmp:bLostFocus := {|| ::cNomAprT := UsrFullName(Posicione("SAK", 1, xFilial("SAK") + ::cCodAprT, "AK_USER")), oGetNomTmp:Refresh() }		
		oGetAprTmp:cF3 := "SAK"
		oGetAprTmp:lHasButton := .T.
		oGetAprTmp:cToolTip := "Código do aprovador temporário"	
	
		oGetNomTmp := TGet():Create(oPnl)
		oGetNomTmp:cName := "oGetNomTmp"
		oGetNomTmp:nLeft := 96
		oGetNomTmp:nTop := 80
		oGetNomTmp:nWidth := 300 
		oGetNomTmp:nHeight := 20
		oGetNomTmp:cVariable := "::cNomAprT"
		oGetNomTmp:bSetGet := bSetGet(::cNomAprT)	
		oGetNomTmp:Picture := "@!"
		oGetNomTmp:cToolTip := "Nome do aprovador temporário"
		oGetNomTmp:Disable()

		// Barra de botoes
		oBtnBar := FWButtonBar():New()
		oBtnBar:Init(::oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)
		oBtnBar:AddBtnText("OK", "OK", {|| ::Confirm() },,,CONTROL_ALIGN_LEFT,.T.)	
		oBtnBar:AddBtnText("Cancelar", "Cancelar", {|| ::Cancel() },,,CONTROL_ALIGN_LEFT,.T.)
							
		::oDlg:Activate()
		
	EndIf
	
Return()


Method Confirm() Class TWAprovadorTemporario
	
	If ::Validate()
		
		::Save()

		::oDlg:End()

	EndIf

Return()


Method Cancel() Class TWAprovadorTemporario

	::oDlg:End()

Return()


Method Validate() Class TWAprovadorTemporario
Local lRet := .T.
Local aArea := GetArea()

	If !Empty(::cCodAprT)
	
		DbSelectArea("SAK")
		DbSetOrder(1)
		If SAK->(DbSeek(xFilial("SAK") + ::cCodAprT))							
		
			If SAK->AK_USER == ::cCodApr
				
				lRet := .F.
				
				MsgAlert("Atenção, o código de usuário do aprovador temporário não podera ser igual ao aprovador.")
			
			EndIf
		
		Else
		
			lRet := .F.
			
			MsgAlert("Atenção, o código informado não é de um aprovador.")
		
		EndIf
		
	EndIf	
	
	RestArea(aArea)
		
Return(lRet)


Method Save() Class TWAprovadorTemporario
Local aArea := GetArea()

	DbSelectArea("SAK")
	DbSetOrder(2)
	If SAK->(DbSeek(xFilial("SAK") + ::cCodApr))
	
		While !SAK->(Eof()) .And. SAK->AK_USER == ::cCodApr
	
			RecLock("SAK", .F.)
		
				SAK->AK_APROSUP := ::cCodAprT
		
			SAK->(MsUnlock())
			
			SAK->(DbSkip())
			
		EndDo()
			
	EndIf
	
	RestArea(aArea)
	
Return()