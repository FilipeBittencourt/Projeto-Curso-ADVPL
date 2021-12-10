#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF176
@author Tiago Rossini Coradini
@since 08/09/2021
@version 1.0
@description Preenchimento automatico do campo de autidoria na analise de cotacao MATA161
@type function
/*/

User Function BIAF176()
Local nCount := 0
Local cFldName := ""
Local cFldDesc := ""
Local xFldValue := Nil
Local nColPos := 0
	
	If fValid(@nColPos)
	
		cFldName := AllTrim(aHeadAud[nColPos, 2])
		cFldDesc := AllTrim(aHeadAud[nColPos, 1])
		xFldValue := GdFieldGet(cFldName, oGetDad:oBrowse:nAt,, oGetDad:aHeader, oGetDad:aCols)
		
		If !Empty(xFldValue) .And. Len(aColsAud) > 1
		
			If MsgYesNo("Deseja realmente replicar o "+ cFldDesc +":" + Space(1) + cValToChar(xFldValue) + " para todos os items?", "Replicação do "+ cFldDesc)
		
				For nCount := 1 To Len(aColsAud)
				
					If !GdDeleted(nCount, oGetDad:aHeader, oGetDad:aCols) .And. oGetDad:oBrowse:nAt <> nCount
							
						GdFieldPut(cFldName, xFldValue, nCount, oGetDad:aHeader, oGetDad:aCols)
						
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

	If Type("aHeadAud") == "A"

		nColPos := fGetColPos()
			
		If GdFieldPos("CE_MOTIVO", aHeadAud) == nColPos
			
			lRet := .T.
			
		EndIf
			
	EndIf

Return(lRet)


Static Function fGetColPos()
Local nRet := 0
Local oOwner := GetWndDefault()	
Local nCount := 1	
Local lLoop := .T.			
	
	While nCount <= Len(oOwner:aControls) .And. lLoop
	    
		If AllTrim(oOwner:aControls[nCount]:ClassName()) == "MSBRGETDBASE"
			
			lLoop := .F.
			
			nRet := oOwner:aControls[nCount]:nColPos
			
		EndIf
		
		nCount++
	
	EndDo		
	
Return(nRet)