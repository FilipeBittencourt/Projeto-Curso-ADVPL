#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F460VAL
@author Wlysses Cerqueira (Facile)
@since 24/01/2019
@project Automação Financeira
@version 1.0
@description Classe responsavel pela criacao de faturas a receber.   
@type class
/*/

User Function F460VAL()
	
	RecLock("SE1", .F.)
	SE1->E1_VEND1 := U_XF460VEN()
	SE1->(MSUnLock())
		
Return()