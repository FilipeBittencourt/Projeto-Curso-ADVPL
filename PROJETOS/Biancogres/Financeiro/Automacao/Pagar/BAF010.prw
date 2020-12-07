#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF010
@author Tiago Rossini Coradini
@since 10/12/2018
@project Automação Financeira
@version 1.0
@description Atualiza titulos de DDA
@type function
/*/

User Function BAF010()
Local oObj := Nil

	oObj := TAFDDA():New()
	oObj:Update()
			
Return()