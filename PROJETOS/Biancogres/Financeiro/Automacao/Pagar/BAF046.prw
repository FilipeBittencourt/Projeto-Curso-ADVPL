#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF046
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Retorna Codigo do Banco - Cnab Banestes 
@type function
/*/

User Function BAF046(cMod)
Local cRet := ""
	
	cRet := If (cMod $ "01/03/05/07/08/41/43", SA2->A2_BANCO, Space(3))
	
Return(cRet)