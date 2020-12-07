#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF059
@author Tiago Rossini Coradini
@since 21/12/2016
@version 1.0
@description Preenchimento automatico do campo data de chegada para todos os itens da cotação/pedido de compra 
@obs OS: 4533-16 - Claudia Carvalho
@type function
/*/

User Function BIAF059(cTip)
Local nCount := 0
Local cFldName := ""
Local cFldDesc := ""
Local xFldValue := Nil
Local nColPos := 0
	
	If fValid(cTip, @nColPos)
	
		cFldName := AllTrim(aHeader[nColPos, 2])
		cFldDesc := AllTrim(aHeader[nColPos, 1])
		xFldValue := GdFieldGet(cFldName)	
		
		If !Empty(xFldValue) .And. Len(aCols) > 1
		
			If MsgYesNo("Deseja realmente replicar a "+ cFldDesc +": " + cValToChar(xFldValue) + " para todos os items?", "Replicação da "+ cFldDesc)
		
				For nCount := 1 To Len(aCols)
				
					If !GdDeleted(nCount) .And. N <> nCount
							
						GdFieldPut(cFldName, xFldValue, nCount)
						
					EndIf
				
				Next
				
			EndIf
				
		Else
		
			MsgInfo("Favor informar a "+ cFldDesc +" do item.", "Replicação da "+ cFldDesc)
		
		EndIf
	
	EndIf
	
Return()


Static Function fValid(cTip, nColPos)
Local lRet := .F.

	If Type("aHeader") == "A"

		nColPos := fGetColPos()
			
		If cTip == "C" // Cotacao de Compra
			
			If GdFieldPos("C8_YDATCHE") == nColPos .Or. GdFieldPos("C8_YOBSCOM") == nColPos .Or. GdFieldPos("C8_PRAZO") == nColPos
				
				lRet := .T.
				
			EndIf
			
		ElseIf cTip == "P" // Pedido de Compra
			
			If GdFieldPos("C7_DATPRF") == nColPos .Or. GdFieldPos("C7_YDATCHE") == nColPos .Or.;
				 GdFieldPos("C7_YDTNECE") == nColPos .Or. GdFieldPos("C7_YOBSCOM") == nColPos .Or.;
				 GdFieldPos("C7_OBS") == nColPos .Or. GdFieldPos("C7_CLVL") == nColPos .Or. GdFieldPos("C7_YSUBITE") == nColPos 
				 
			
				lRet := .T.
						
			EndIf
			
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