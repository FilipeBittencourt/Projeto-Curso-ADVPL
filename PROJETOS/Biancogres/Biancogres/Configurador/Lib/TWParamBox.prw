#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TWParamBox
@author Tiago Rossini Coradini
@since 12/06/2017
@version 1.0
@description Classe generica para atualização de parametros 
@obs OS: 1297-17 - Claudeir Fadini
@type function
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
#DEFINE TIT_MAIN_WND "Atualização de Parâmetros"
#DEFINE TIT_WND "Parâmetro: "


Class TWParamBox From LongClassName
	
	Data oFntBold // Fonte
	Data oDlg // Janela principal
	Data cName // Nome do parametro
	Data cDesc // Descrição
	Data cType // Tipo
	Data cDscType // Descrição do Tipo
	Data cValue // Valor
	Data nRecNo 
			
	Method New() Constructor
	Method Activate() // Ativa exibicao do objeto
	Method Confirm() // Confima
	Method Cancel() // Cancela
	Method Validate() // Valida
	Method GetType(cType) // Retorna tipo de dado
	Method Save() // Salva
	
EndClass


Method New(cName) Class TWParamBox
	
	::oFntBold := TFont():New('Arial',,14,,.T.)	

	If !Empty(cName)
	
		DbSelectArea("SX6")
		DbSetOrder(1)
		If SX6->(DbSeek(xFilial("SX6") + cName))
	
			::cName := cName
			::cType := SX6->X6_TIPO
			::cDscType := ::GetType(SX6->X6_TIPO)
			::cValue := SX6->X6_CONTEUD			
			::cDesc := AllTrim(SX6->X6_DESCRIC) + Space(1) + AllTrim(SX6->X6_DESC1) + Space(1) + AllTrim(SX6->X6_DESC2)
			::nRecNo := SX6->(RecNo())  
		
		Else
		
			MsgAlert("Atenção, o parâmetro: " + cName + " não existe.")
		
		EndIf

	Else
	
		MsgAlert("Atenção, parâmetro não informado.")
			
	EndIf
		
Return()


Method Activate() Class TWParamBox
Local oWindow := Nil
	
	If !Empty(::cName)
		
		// Cria Dialog padrão
		::oDlg := MsDialog():New(0, 0, 220, 420, TIT_MAIN_WND,,,,DS_MODALFRAME,,,,,.T.)
		::oDlg:cName := "oDlg"
		::oDlg:lCentered := .T.
		::oDlg:lEscClose := .F.
		::oDlg:bValid := {|| .F. }
		
		// Barra de botoes
		oBtnBar := FWButtonBar():New()
		oBtnBar:Init(::oDlg, 015, 015, CONTROL_ALIGN_BOTTOM, .T.)
		oBtnBar:AddBtnText("OK", "OK", {|| ::Confirm() },,,CONTROL_ALIGN_LEFT,.T.)	
		oBtnBar:AddBtnText("Cancelar", "Cancelar", {|| ::Cancel() },,,CONTROL_ALIGN_LEFT,.T.)
		
		// Layer
		oLayer := FWLayer():New()
		oLayer:Init(::oDlg, .F., .T.)
		
		// Adiciona linha ao Layer
		oLayer:AddLine(LIN, 100, .F.)
		// Adiciona coluna ao Layer
		oLayer:AddCollumn(COL, PER_COL, .T., LIN)
		// Adiciona janela ao Layer
		oLayer:AddWindow(COL, WND, TIT_WND, 100, .F. ,.T.,, LIN, { || })
		
		oLayer:SetWinTitle(COL, WND, TIT_WND + ::cName, LIN)
		  
		// Muda fonte do Layes
		oLayer:GetWindow(COL, WND, @oWindow, LIN)			
		oWindow:oTitleBar:oFont := ::oFntBold //TFont():New("MS Sans Serif",,18,,.T.)
		
		// Retorna paimel da janela do Layer
		oPnl := oLayer:GetWinPanel(COL, WND, LIN)
				
		oSayType := TSay():Create(oPnl)
		oSayType:cName := "oSayType"
		oSayType:cCaption := "Tipo"
		oSayType:nLeft := 06
		oSayType:nTop := 06
		oSayType:nWidth := 45
		oSayType:nHeight := 30
		oSayType:lReadOnly := .T.
		//oSayType:nClrText := CLR_HBLUE
		oSayType:oFont := ::oFntBold
		oSayType:cToolTip := "Tipo do Parâmetro"
		
		oGetType := TGet():Create(oPnl)
		oGetType:cName := "oGetType"
		oGetType:nLeft := 06
		oGetType:nTop := 22
		oGetType:nWidth := 80
		oGetType:nHeight := 20
		oGetType:cVariable := "::cDscType"
		oGetType:bSetGet := bSetGet(::cDscType)
		oGetType:Picture := PesqPict("SD1", "D1_DOC")
		oGetType:lHasButton := .T. 	
		oGetType:cToolTip := "Tipo do Parâmetro"	
		oGetType:Disable()
	
		oSayValue := TSay():Create(oPnl)
		oSayValue:cName := "oSayValue"
		oSayValue:cCaption := "Conteúdo"
		oSayValue:nLeft := 96
		oSayValue:nTop := 06
		oSayValue:nWidth := 60
		oSayValue:nHeight := 20
		//oSayValue:nClrText := CLR_HBLUE
		oSayValue:oFont := ::oFntBold
		oSayValue:cToolTip := "Conteúdo do Parâmetro"	
		
		oGetValue := TGet():Create(oPnl)
		oGetValue:cName := "oGetValue"
		oGetValue:nLeft := 96
		oGetValue:nTop := 22
		oGetValue:nWidth := 300 
		oGetValue:nHeight := 20
		oGetValue:cVariable := "::cValue"
		oGetValue:bSetGet := bSetGet(::cValue)
		//oGetValue:bValid := {|| ::Validate() }
		oGetValue:Picture := "@!"
		oGetValue:cToolTip := "Conteúdo do Parâmetro"
	
		oMDesc := TMultiGET():Create(oPnl)
		oMDesc:cName := "oMDesc"
		oMDesc:nLeft := 06
		oMDesc:nTop := 48
		oMDesc:nWidth := 390
		oMDesc:nHeight := 80
		oMDesc:lShowHint := .F.
		oMDesc:lReadOnly := .T.
		oMDesc:cVariable := "::cDesc"
		oMDesc:bSetGet := bSetGet(::cDesc)
		oMDesc:EnableVScroll(.T.)
					
		::oDlg:Activate()
		
	EndIf
	
Return()


Method Confirm() Class TWParamBox
	
	If ::Validate()
		
		::Save()

		::oDlg:End()

	EndIf

Return()


Method Cancel() Class TWParamBox

	::oDlg:End()

Return()


Method Validate() Class TWParamBox
Local lRet := .T.
Local nCount := 1	
Local xValue := AllTrim(::cValue)
	
	If ::cType $ ("N/D/L")			
	
		If ::cType == "N"	
		
			While nCount <= Len(xValue) .And. lRet
			
				If !SubStr(xValue, nCount, 1) $ "0/1/2/3/4/5/6/7/8/9"
				
					lRet := .F.
				
				EndIf
				
				nCount++
			
			EndDo()
						
		ElseIf ::cType == "D" .And. Empty(cToD(xValue))
		
			lRet := .F.
		
		ElseIf ::cType == "L"
					
			If !(SubStr(xValue, 1, 1) == "." .And. SubStr(xValue, 3, 1) == "." .And. SubStr(xValue, 2, 1) $ "T/F")
			
				lRet := .F.
			
			EndIf
						
		EndIf
			
		If !lRet
		
			MsgAlert("Atenção, tipo inválido para o parâmetro.")
			
		EndIf
		
	EndIf
	
Return(lRet)


Method GetType(cType) Class TWParamBox
Local cRet := ""

	If cType == "C"
		
		cRet := "Caracter"
		
	ElseIf cType == "N"
		
		cRet := "Numérico"

	ElseIf cType == "L"
		
		cRet := "Lógico"
	
	ElseIf cType == "D"
		
		cRet := "Data"
	
	ElseIf cType == "M"
		
		cRet := "Memo"
	
	EndIf
		
Return(cRet)


Method Save() Class TWParamBox
	
	SX6->(DbGoTo(::nRecNo))
	
	RecLock("SX6", .F.)
	
		SX6->X6_CONTEUD := ::cValue
	
	SX6->(MsUnlock())
	
Return()