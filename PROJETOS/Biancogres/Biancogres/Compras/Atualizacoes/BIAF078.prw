#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF078
@author Tiago Rossini Coradini
@since 26/05/2017
@version 1.0
@description Rotina para cadastro de aprovadores de compra temporarios.
@obs OS: 0179-17 - Ranisses Corona
@type function
/*/

User Function BIAF078()  
Local aArea := GetArea()
Local oWAprTmp := Nil 

	oWAprTmp := TWAprovadorTemporario():New()
	oWAprTmp:Activate()
	
	RestArea(aArea)
	
Return()