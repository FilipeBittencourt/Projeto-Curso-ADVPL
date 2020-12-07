#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF088
@author Tiago Rossini Coradini
@since 05/12/2017
@version 1.0
@description Avalia modo de edição dos campos de desconto C8_YVLDES e C8_YPEDES da cotação de compras
@obs OS: XXXX-XX
@type function
/*/

User Function BIAF088()
Local lRet := .T.
Local aArea := GetArea()
Local nPrcOri := GdFieldGet("C8_YPRCORI") 

	If !l150Propost .Or. nPrcOri <= 0
		
		lRet := .F.
		
	EndIf
			
	RestArea(aArea)		

Return(lRet)