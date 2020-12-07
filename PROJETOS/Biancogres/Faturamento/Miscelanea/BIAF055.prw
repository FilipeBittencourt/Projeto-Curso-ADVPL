#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIAF055
@author Tiago Rossini Coradini
@since 29/11/2016
@version 1.0
@description Rotina para visualizar as informações de rescisão do vendedor 
@obs OS: 3861-16 - Ranisses Corona
@type function
/*/

User Function BIAF055()
Local oObj := TWRescisaoVendedor():New()
	
	oObj:Activate()
	
Return()