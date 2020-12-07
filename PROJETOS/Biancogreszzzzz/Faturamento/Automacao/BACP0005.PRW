#include "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.ch"

User Function BACP0005(_cCodigo, _cTipo)

	Private oWindow			:= Nil
	Private oContainer		:= Nil
	Private cItemBox		:= Nil
	Private oLayer			:= Nil
	Private oPanel1			:= Nil
	Private oPanelConteiner	:= Nil
	Private oGridMargem		:= Nil
	Private oGrid			:= Nil
	Private aFieldsZKJ		:= {"ZKJ_CODIGO", "ZKJ_ORIAPR", "ZKJ_APROV", 'ZKJ_NIVEL', /*"ZKJ_APROVT",*/ "ZKJ_ORDEM", "ZKJ_ENVEM"}
	Private cCodigo			:= _cCodigo
	Private	cTipo			:= _cTipo

	LoadModal()
	LoadContainer()
	LoadLayer()

	GridZKJ()

	oWindow:Activate()	
Return


Static Function LoadModal()

	Local aCoors := MsAdvSize()

	oWindow := FWDialogModal():New()
	oWindow:SetBackground(.T.)
	oWindow:SetTitle("Aprovadores")
	oWindow:SetEscClose(.T.)
	//oWindow:SetSize(aCoors[4], aCoors[3])
	oWindow:SetSize(aCoors[4]-100, aCoors[3]-140)
	oWindow:EnableFormBar(.T.)
	oWindow:CreateDialog()
	oWindow:CreateFormBar()

	oWindow:AddOKButton({|| GravaZKJ(), oWindow:OOWNER:End() }, "Salvar")
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


Static Function GridZKJ()

	Local aHeader		:= {}
	Local aCols			:= {}
	Local aFieldFill 	:= {}
	Local aAlterFields	:= AClone(aFieldsZKJ)

	aHeader := GetHeader(aFieldsZKJ)

	oGrid := MsNewGetDados():New( 0, 0, 0, 0,  GD_INSERT + GD_UPDATE + GD_DELETE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", .T., .T., oPanel1, aHeader, aCols)
	oGrid:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGrid:oBrowse:lVScroll := .T.
	oGrid:oBrowse:lHScroll := .T.

	LoadZKJ()

Return


Static Function LoadZKJ()

	Local nI			:= 1
	Local aCols			:= {}
	Local aHeader		:= AClone(oGrid:aHeader)
	Local nPosOriApr	:= aScan(aHeader,{|x| Alltrim(x[2]) == 'ZKJ_ORIAPR'})
	Local nPosAprov		:= aScan(aHeader,{|x| Alltrim(x[2]) == 'ZKJ_APROV'})
	//Local nPosAprovT	:= aScan(aHeader,{|x| Alltrim(x[2]) == 'ZKJ_APROVT'})
	Local nPosCod		:= aScan(aHeader,{|x| Alltrim(x[2]) == 'ZKJ_CODIGO'})
	Local nPosOrdem		:= aScan(aHeader,{|x| Alltrim(x[2]) == 'ZKJ_ORDEM'})
	Local nPosEnvEm		:= aScan(aHeader,{|x| Alltrim(x[2]) == 'ZKJ_ENVEM'})
	Local nPosNivel		:= aScan(aHeader,{|x| Alltrim(x[2]) == 'ZKJ_NIVEL'})
	Local aLinha		:= {}


	If (cTipo == "A")
		DbSelectArea('ZKJ')
		ZKJ->(DbSetOrder(2))
	Else
		DbSelectArea('ZKJ')
		ZKJ->(DbSetOrder(3))
	EndIf


	If (ZKJ->(DbSeek(xFilial('ZKJ')+cCodigo)))

		While(!ZKJ->(Eof()) .And. (ZKJ->ZKJ_CODZKI == cCodigo .Or. ZKJ->ZKJ_CODZKK == cCodigo))

			aLinha := {"", "", "", "", /*"",*/ "", "", .F.}

			aLinha[nPosOriApr]	:= ZKJ->ZKJ_ORIAPR
			aLinha[nPosAprov]	:= ZKJ->ZKJ_APROV
			aLinha[nPosNivel]	:= ZKJ->ZKJ_NIVEL

			//aLinha[nPosAprovT]	:= ZKJ->ZKJ_APROVT
			aLinha[nPosCod]		:= ZKJ->ZKJ_CODIGO
			aLinha[nPosOrdem]	:= ZKJ->ZKJ_ORDEM
			aLinha[nPosEnvEm]	:= ZKJ->ZKJ_ENVEM

			Aadd(aCols, aLinha)

			ZKJ->(DbSkip())
		EndDo

		oGrid:SetArray(aCols, .T.)
		oGrid:oBrowse:Refresh()
	EndIf

	ZKJ->(DbCloseArea())

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


Static Function GravaZKJ()

	Local nI			:= 0
	Local aCols			:= AClone(oGrid:aCols)
	Local aHeader		:= AClone(oGrid:aHeader)
	Local nPosOriApr	:= aScan(aHeader,{|x| Alltrim(x[2]) == 'ZKJ_ORIAPR'})
	Local nPosAprov		:= aScan(aHeader,{|x| Alltrim(x[2]) == 'ZKJ_APROV'})
	Local nPosNivel		:= aScan(aHeader,{|x| Alltrim(x[2]) == 'ZKJ_NIVEL'})

	//Local nPosAprovT	:= aScan(aHeader,{|x| Alltrim(x[2]) == 'ZKJ_APROVT'})
	Local nPosCod		:= aScan(aHeader,{|x| Alltrim(x[2]) == 'ZKJ_CODIGO'})
	Local nPosOrdem		:= aScan(aHeader,{|x| Alltrim(x[2]) == 'ZKJ_ORDEM'})
	Local nPosEnvEm		:= aScan(aHeader,{|x| Alltrim(x[2]) == 'ZKJ_ENVEM'})

	//TODO VALIDAR ORDEM e APROVADORES

	For nI := 1 To Len(aCols)

		If (aCols[nI, Len(aCols[nI])] == .F.)


			cCodZKJ		:= aCols[nI, nPosCod]
			cOriAprov	:= aCols[nI, nPosOriApr]
			cAprov		:= aCols[nI, nPosAprov]
			//cAprovT		:= aCols[nI, nPosAprovT]
			cOrdem		:= aCols[nI, nPosOrdem]
			cEnvMail	:= aCols[nI, nPosEnvEm]
			cNivel		:= aCols[nI, nPosNivel]

			DbSelectArea('ZKJ')
			ZKJ->(DbSetOrder(1))

			If (!Empty(cCodZKJ) .And. ZKJ->(DbSeek(xFilial('ZKJ')+cCodZKJ)) )

				Reclock("ZKJ", .F.)

				ZKJ->ZKJ_ORIAPR	:= cOriAprov

				ZKJ->ZKJ_APROV	:= SPACE(LEN(cAprov))
				If (AllTrim(cOriAprov) == '1')
					ZKJ->ZKJ_APROV	:= cAprov
				EndIf

				ZKJ->ZKJ_NIVEL	:= cNivel
				//ZKJ->ZKJ_APROVT	:= cAprovT
				ZKJ->ZKJ_ORDEM	:= cOrdem
				ZKJ->ZKJ_ENVEM	:= cEnvMail

				If (cTipo == "A")
					ZKJ->ZKJ_CODZKI	:= cCodigo
				Else
					ZKJ->ZKJ_CODZKK	:= cCodigo
				EndIf

				ZKJ->(MsUnlock())

			Else

				Reclock("ZKJ", .T.)

				ZKJ->ZKJ_ORIAPR	:= cOriAprov

				ZKJ->ZKJ_APROV	:= SPACE(LEN(cAprov))
				If (AllTrim(cOriAprov) == '1')
					ZKJ->ZKJ_APROV	:= cAprov
				EndIf

				ZKJ->ZKJ_NIVEL	:= cNivel
				//ZKJ->ZKJ_APROVT	:= cAprovT
				ZKJ->ZKJ_CODIGO	:= GETSX8NUM("ZKJ","ZKJ_CODIGO")
				ZKJ->ZKJ_ORDEM	:= cOrdem
				ZKJ->ZKJ_ENVEM	:= cEnvMail

				If (cTipo == "A")
					ZKJ->ZKJ_CODZKI	:= cCodigo
				Else
					ZKJ->ZKJ_CODZKK	:= cCodigo
				EndIf

				ZKJ->(MsUnlock())

				ConfirmSX8()
			EndIf

		Else

			DbSelectArea('ZKJ')
			ZKJ->(DbSetOrder(1))

			cCodZKJ		:= aCols[nI, nPosCod]

			If (!Empty(cCodZKJ) .And. ZKJ->(DbSeek(xFilial('ZKJ')+cCodZKJ)))

				Reclock("ZKJ", .F.)
				ZKJ->(dbDelete())
				ZKJ->(MsUnlock())
			EndIf

		EndIf

	Next nI		

Return