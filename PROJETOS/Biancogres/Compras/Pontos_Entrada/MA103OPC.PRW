#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MA103OPC
Ponto de entrada para adicionar rotinas no documento de entrada
@author Emerson Salvador
@since 26/08/2021
@version 1.0
@type function
/*/

User Function MA103OPC()

	Local aRet := {}
	 
	aAdd(aRet,{"Rateio RPV", "U_BIAFG106('1',0)", 0, 5})

Return aRet
