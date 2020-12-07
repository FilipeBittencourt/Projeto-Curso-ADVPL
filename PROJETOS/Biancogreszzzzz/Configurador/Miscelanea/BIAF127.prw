#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF127
@author Tiago Rossini Coradini
@since 22/02/2019
@version 1.0
@description Funcao para envio de comunicados
@obs Ticket: 11376
@type class
/*/

User Function BIAF127()
Local aArea := GetArea()
Local oObj := Nil
	
	If U_VALOPER("055", .T., .T.) .Or. U_VALOPER("056", .T., .T.)
	
		oObj := TWComunicado():New()
		
		oObj:Activate()
			
	EndIf

	RestArea(aArea)
	
Return()