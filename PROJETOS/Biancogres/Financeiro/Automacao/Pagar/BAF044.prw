#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF044
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Retorna Hora - Cnab Banestes 
@type function
/*/

User Function BAF044(cHora)
Local cRet := ""
	
	cRet := SubStr(cHora, 1, 2) + SubStr(cHora, 4, 2) + SubStr(cHora, 7, 2)
	
Return(cRet)