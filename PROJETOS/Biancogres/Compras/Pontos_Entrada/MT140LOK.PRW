#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} MT140LOK
@version MT140LOK - Valida informações no pré-nota de entrada
@description - Este ponto de entrada tem o objetivo de validar as informações preenchidas no aCols 
de cada item do pré-nota de entrada. Ex.: Possibilita realizar um tratamento para os valores preenchidos, 
validações específicas de acordo com a necessidade existente.
LOCALIZAÇÃO: Function Ma140LinOk() - Função responsável pela validação de cada item do pré-nota de entrada
que está sendo cadastrado.
@version 1.0
@type function
/*/

User Function MT140LOK()
	Local lRet := .T.

	lRet := U_GTPE012()

Return lRet