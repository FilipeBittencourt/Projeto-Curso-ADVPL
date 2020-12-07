#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F373CAN
@author Wlysses Cerqueira (Facile)
@since 28/01/2020
@version 1.0
@description Chamado no momento da montagem da tela de selecionar a darf para cancelamento da DARF - FINA373
@type class
/*/

User Function F373CAN()

	Local oObj := TFaturaPagarDarf():New()
	
    oObj:CancelarFatura() // Nao tem PE depois da exclusão da DARF, tive que usar esse PE.

Return("")