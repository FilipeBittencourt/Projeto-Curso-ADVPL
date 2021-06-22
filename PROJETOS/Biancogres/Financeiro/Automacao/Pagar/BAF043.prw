#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF043
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Retorna Data - Cnab Banestes 
@type function
/*/

User Function BAF043(dData)
Local cRet := ""

	cRet := SubStr(GravaData(dData, .F.), 1, 4) + Str(Year(dData), 4)
	
Return(cRet)