#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FA290OKC
@author Wlysses Cerqueira (Facile)
@since 22/05/2019
@project Automação Financeira
@version 1.0
@description Ponto de entrada para validacao de exclusao de fatura a pagar.
@type PE
/*/

User Function FA290OKC()
	
	Local lRet := .T.
	Local oObj := TFaturaReceberIntercompany():New()
	
	lRet := oObj:ExisteFaturaDestino(.T.)

Return(lRet)