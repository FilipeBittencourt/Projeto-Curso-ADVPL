#Include 'Protheus.ch'

/*/{Protheus.doc} SFStruJs
Acrescenta aspas duplas à uma string
@type function
@author Giovani
@since 18/09/2017
@version 1.0
@param
xParam, character, string de entrada
lAllTrim, boolean, indica se executa alltrim (default = .F.)
@return xParam, string formatada com aspas duplas
@example
u_SFQuote('String')
/*/
User Function SFQuote(xParam,lAllTrim)

	Default xParam := ''
	Default lAllTrim := .F.

	Do Case
	Case ValType(xParam) == 'C'

		// Remove espaços
		If lAllTrim
			xParam := AllTrim(xParam)
		EndIf

		// Adiciona aspas duplas
		If !Empty(xParam)
			xParam := '"' + xParam + '"'
		Else
			xParam := '""'
		EndIf

	Case ValType(xParam) == 'D'
		If !Empty(xParam)
			xParam := cValToChar(Year(xParam)) +'-'+ cValToChar(Month(xParam)) +'-'+ cValToChar(Day(xParam)) //dToC(xParam)
			xParam := '"' + xParam + '"'
		Else
			xParam := '""'
		EndIf

	Otherwise
		xParam := cValToChar(xParam)
	EndCase

Return(xParam)
