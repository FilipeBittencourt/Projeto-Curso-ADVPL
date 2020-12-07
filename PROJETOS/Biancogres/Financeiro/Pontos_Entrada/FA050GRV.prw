#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TContaContabil
@author Wlysses Cerqueira (Facile)
@since 04/07/2019
@project Automação Financeira
@version 1.0
@description 
@type class
/*/

User Function FA050GRV()
	
	Local oContaCont := TContaContabil():New()
	
	oContaCont:SetContContab("F", SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_TIPO)

Return()