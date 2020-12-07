#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF117
@author Tiago Rossini Coradini
@since 31/07/2018
@version 1.0
@description Preenchimento automatico do campo de autidoria na analise de cotacao
@obs Ticket: 7049
@type function
/*/

User Function BIAF117()
Local nCount := 0
Local cFldName := ""
Local cFldDesc := ""
Local xFldValue := Nil
Local nColPos := 0
	
	If fValid(@nColPos)
	
		cFldName := AllTrim(aHeader[nColPos, 2])
		cFldDesc := AllTrim(aHeader[nColPos, 1])
		xFldValue := GdFieldGet(cFldName)	
		
		If !Empty(xFldValue) .And. Len(aCols) > 1
		
			If MsgYesNo("Deseja realmente replicar o "+ cFldDesc +":" + Space(1) + cValToChar(xFldValue) + " para todos os items?", "Replicação do "+ cFldDesc)
		
				For nCount := 1 To Len(aCols)
				
					If !GdDeleted(nCount) .And. N <> nCount
							
						GdFieldPut(cFldName, xFldValue, nCount)
						
					EndIf
				
				Next
				
			EndIf
				
		Else
		
			MsgInfo("Favor informar o "+ cFldDesc +" do item.", "Replicação do "+ cFldDesc)
		
		EndIf
	
	EndIf
	
Return()


Static Function fValid(nColPos)
Local lRet := .F.

	If Type("aHeader") == "A"

		nColPos := fGetColPos()
			
		If GdFieldPos("CE_MOTIVO") == nColPos
			
			lRet := .T.
			
		EndIf
			
	EndIf

Return(lRet)


Static Function fGetColPos()
Local nRet := 0
Local oOwner := GetWndDefault()
Local oFolder := Nil
Local nCount := 1	
Local lLoop := .T.			
	
	While nCount <= Len(oOwner:aControls) .And. lLoop
	    
		If AllTrim(oOwner:aControls[nCount]:ClassName()) == "TFOLDER"			
			
			lLoop := .F.
			
			oFolder := oOwner:aControls[nCount]
			
			// Folder de auditoria
			If oFolder:nOption == 2
			
				// Existe objeto GetDados
				If !Empty(oFolder:aDialogs[oFolder:nOption]:oWnd:oCtlFocus)
									
					// Coluna selecionada no grid
					nRet := oFolder:aDialogs[oFolder:nOption]:oWnd:oCtlFocus:nColPos
				
				EndIf
							
			EndIf
			
		EndIf
		
		nCount++
	
	EndDo()
			
Return(nRet)