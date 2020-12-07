#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF087
@author Tiago Rossini Coradini
@since 05/12/2017
@version 1.0
@description Validação do campo valor de desconto C8_YVLDES da cotação de compras 
@obs OS: XXXX-XX
@type function
/*/

User Function BIAF087()
Local lRet := .T.
Local aArea := GetArea()
Local nVlrDes := 0
Local nPrcOri := 0
Local cFVlrDes := "C8_YVLDESC"
Local cFPrcOri := "C8_YPRCORI"

	nVlrDes := GdFieldGet(cFVlrDes,,.T.)
	nPrcOri := GdFieldGet(cFPrcOri)
	
	If nPrcOri <= nVlrDes
		
		lRet := .F.
		
	EndIf
			
	RestArea(aArea)		

Return(lRet)