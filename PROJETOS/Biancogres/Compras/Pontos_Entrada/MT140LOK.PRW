#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} MT140LOK
@version MT140LOK - Valida informa��es no pr�-nota de entrada
@description - Este ponto de entrada tem o objetivo de validar as informa��es preenchidas no aCols 
de cada item do pr�-nota de entrada. Ex.: Possibilita realizar um tratamento para os valores preenchidos, 
valida��es espec�ficas de acordo com a necessidade existente.
LOCALIZA��O: Function Ma140LinOk() - Fun��o respons�vel pela valida��o de cada item do pr�-nota de entrada
que est� sendo cadastrado.
@version 1.0
@type function
/*/

User Function MT140LOK()
	Local lRet := .T.

	lRet := U_GTPE012()

Return lRet