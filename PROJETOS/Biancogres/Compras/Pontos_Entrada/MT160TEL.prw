#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT160TEL
@author Tiago Rossini Coradini
@since 31/07/2018
@version 1.0
@description Ponto de entrada na montagem das folders da analise de cotacao
@obs Ticket: 7049
@type function
/*/

User Function MT160TEL()
	
	SetKey(VK_F9, {|| U_BIAF117() })
	
Return()
