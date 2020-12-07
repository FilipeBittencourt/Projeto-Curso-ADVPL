#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF089
@author Tiago Rossini Coradini
@since 05/12/2017
@version 1.0
@description Avalia modo de edição do campo de preço C8_PRECO da cotação de compras 
@obs OS: XXXX-XX
@type function
/*/

User Function BIAF089()
Local lRet := .T.
Local aArea := GetArea() 

	If l150Propost
		
		lRet := .F.
		
	EndIf
			
	RestArea(aArea)		

Return(lRet)