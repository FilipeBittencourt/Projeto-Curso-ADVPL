#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function BACP0006(_cNumPed, _cFilial)

	Private oWindow			:= Nil
	Private oContainer		:= Nil
	Private cItemBox		:= Nil
	Private oLayer			:= Nil
	Private oPanel1			:= Nil
	Private oPanelConteiner	:= Nil
	Private oGridMargem		:= Nil
	Private oGrid			:= Nil
	Private aFieldsZKL		:= {"ZKL_APROV", "ZKL_NAPROV", "ZKL_DATA","ZKL_HORA","ZKL_ACAO", "ZKL_ORDEM", "ZKL_ORIGEM", "ZKL_STATUS", "ZKL_OBS"}
	Private cNumPed			:= _cNumPed
	Private cFilPed			:= _cFilial

	LoadModal()
	LoadContainer()
	LoadLayer()

	GridZKL()

	oWindow:Activate()	
Return


Static Function LoadModal()

	Local aCoors := MsAdvSize()

	oWindow := FWDialogModal():New()
	oWindow:SetBackground(.T.)
	oWindow:SetTitle("Pedido x Aprovadores")
	oWindow:SetEscClose(.T.)
	//oWindow:SetSize(aCoors[4], aCoors[3])
	oWindow:SetSize(aCoors[4]-100, aCoors[3]-140)
	oWindow:EnableFormBar(.T.)
	oWindow:CreateDialog()
	oWindow:CreateFormBar()

	oWindow:AddCloseButton({|| oWindow:OOWNER:End()})

Return

Static Function LoadContainer()

	oContainer	:= FWFormContainer():New()
	cItemBox 	:= oContainer:CreateHorizontalBox(100)
	oContainer:Activate(oWindow:GetPanelMain(), .T.)

Return 


Static Function LoadLayer()

	oPanelConteiner := oContainer:GetPanel(cItemBox)	

	// Layer
	oLayer := FWLayer():New()
	oLayer:Init(oPanelConteiner, .F., .T.)

	oLayer:AddLine("LINHA_1", 100, .F.)

	oLayer:AddCollumn('COLUNA_1', 100, .T., 'LINHA_1')

	// Janela acima 
	oLayer:AddWindow('COLUNA_1', 'JANELA_1', '', 100, .F. ,.T.,, 'LINHA_1', { || })	

	oPanel1 := oLayer:GetWinPanel('COLUNA_1', 'JANELA_1', 'LINHA_1')

Return


Static Function GridZKL()

	Local aHeader		:= {}
	Local aCols			:= {}
*	Local aFieldFill 	:= {}
	Local aAlterFields	:= AClone(aFieldsZKL)

	aHeader := GetHeader(aFieldsZKL)
	Aadd(aHeader, {"Regras", "REGRAS", "@!", 10, 0, , , "M", , , ,})

	oGrid := MsNewGetDados():New( 0, 0, 0, 0,  0, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "", oPanel1, aHeader, aCols)
	oGrid:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGrid:oBrowse:lVScroll := .T.
	oGrid:oBrowse:lHScroll := .T.

	LoadZKL()

Return



Static Function LoadZKL()

	Local nI			:= 1
	Local aCols			:= {}
*	Local aHeader		:= AClone(oGrid:aHeader)
	Local aLinha		:= {}
*	Local nI			:= 0
	Local cRegras		:= ""
	Local cObs as character
	Local aRegras		:= {}
	Local aObs

	If (ZKL->(DbSeek(cFilPed+cNumPed)))

		While(!ZKL->(Eof()) .And. ZKL->ZKL_FILIAL+ZKL->ZKL_PEDIDO == cFilPed+cNumPed)
			
			aRegras := StrTokArr(ZKL->ZKL_REGRA, "/")
			cRegras := ""
			For nI := 1 To Len (aRegras)
	
				DbSelectArea("ZKI")
				ZKI->(DbSetOrder(1))
	
				If (ZKI->(DbSeek(xFilial('ZKI')+aRegras[nI])))
	
					cRegras += ZKI->ZKI_DESBLQ
					
				EndIf
	
			Next nI
			
			cObs:=SQLStripHTML():StripHTML(ZKL->ZKL_OBS)
			aObs:=StrToKArr2(cObs,CRLF)
			cObs:=""
			aEval(aObs,{|c|if(!empty(c),cObs+=(c+CRLF),nil)})
			
			aLinha := {;
			ZKL->ZKL_APROV,;
			UsrRetName(ZKL->ZKL_APROV),;
			ZKL->ZKL_DATA,;
			ZKL->ZKL_HORA,;
			ZKL->ZKL_ACAO,;
			ZKL->ZKL_ORDEM,;
			ZKL->ZKL_ORIGEM,;
			ZKL->ZKL_STATUS,;
			cObs,;
			cRegras,;
			.F.;
			}


			Aadd(aCols, aLinha)

			ZKL->(DbSkip())
		EndDo

		oGrid:SetArray(aCols, .T.)
		oGrid:oBrowse:Refresh()
	EndIf

	ZKL->(DbCloseArea())

Return


Static Function GetHeader(aFields)

	Local aHeader := {}
	Local nX

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeader, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

Return aHeader
