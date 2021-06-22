#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF047
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Retorna Codigo da Agencia - Cnab Banestes 
@type function
/*/

User Function BAF047(cMod)
Local cRet := ""
	
	cRet := If (cMod $ "01/03/05/07/08/41/43", StrZero(Val(SA2->A2_AGENCIA), If (cMod $ "41/43", 4, 5)), Space(If (cMod $ "41/43", 4, 5)))
	
Return(cRet)