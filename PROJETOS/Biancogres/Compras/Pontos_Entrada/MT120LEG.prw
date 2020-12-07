#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT120COR
@author Tiago Rossini Coradini
@since 20/07/2018
@version 1.0
@description Ponto de entrada para adicionar legenda no browse do pedido de compra 
@type function
/*/

User Function MT120LEG()
Local aRet := ParamIxb[1]

	aAdd(aRet, {"BR_VIOLETA", "Eliminado Automaticamente por Residuo"})
	
Return(aRet)