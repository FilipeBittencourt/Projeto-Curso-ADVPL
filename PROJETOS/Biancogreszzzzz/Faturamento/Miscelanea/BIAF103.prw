#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF103
@author Tiago Rossini Coradini
@since 16/04/2018
@version 1.0
@description Valida pedidos de rodape, não é permitido produtos de pacotes distintos junto com os de rodape 
@obs Ticket: 3601
@type Function
/*/

User Function BIAF103()
Local lRet := .T.
Local aArea := GetArea()	
	
	If M->C5_CONDPAG == "000"
		
		If fExistRodape()
		
			lRet := fVldRodape()
			
		EndIf 
				
	EndIf
	
	RestArea(aArea)
	
Return(lRet)


Static Function fExistRodape()
Local lRet := .T.
Local nCount := 1
	
	while nCount <= Len(aCols) .And. lRet
	
		If !GdDeleted(nCount)
			
			lRet := Posicione("SB1", 1, xFilial("SB1") + GdFieldGet("C6_PRODUTO", nCount), "B1_YPCGMR3") == "E"
				
		EndIf
	
		nCount++

	EndDo()
	
Return(lRet)


Static Function fVldRodape()
Local lRet := .T.
Local nCount := 1
	
	while nCount <= Len(aCols) .And. lRet
	
		If !GdDeleted(nCount)
			
			If Posicione("SB1", 1, xFilial("SB1") + GdFieldGet("C6_PRODUTO", nCount), "B1_YPCGMR3") <> "E"
			
				lRet := .F. 
			
			EndIf 
				
		EndIf
	
		nCount++

	EndDo()
	
Return(lRet)