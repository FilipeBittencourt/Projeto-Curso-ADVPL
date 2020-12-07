#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BAF035
@author Tiago Rossini Coradini
@since 01/07/2019
@project Automação Financeira
@version 1.0
@description Cadastro de movimentos bancarios automaticos via extrato bancario
@type function
/*/

User Function BAF035()
Local oObj := Nil

	AxCadastro("ZKB", "Movimento Bancario via Extrato")
			
Return()