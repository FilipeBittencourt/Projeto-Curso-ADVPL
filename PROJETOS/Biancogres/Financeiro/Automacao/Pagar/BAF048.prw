#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF048
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Retorna Numero da Conta - Cnab Banestes 
@type function
/*/

User Function BAF048(cMod)
Local cRet := ""
Local nTam := If (cMod $ "41/43", 13, 12)

	cRet := If (cMod $ "01/03/05/07/08/41/43", StrZero(Val(StrTran(AllTrim(SA2->A2_NUMCON) + SA2->A2_YDVCTA, ".", "")), nTam), Space(nTam))

Return(cRet)	
