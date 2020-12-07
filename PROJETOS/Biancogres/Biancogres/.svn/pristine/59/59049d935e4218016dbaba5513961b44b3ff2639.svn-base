#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF017
@author Tiago Rossini Coradini
@since 07/03/2019
@project Automação Financeira
@version 1.0
@description Rotina para visualizar log de automação de titulos a pagar
@type function
/*/

User Function BAF017()
Local oObj := Nil

	oObj := TWAFLogAutomacao():New()
	
	oObj:cEmp := cEmpAnt
	oObj:cFil := cFilAnt
	oObj:cTipo := "P"
	oObj:cTabela := RetSQLName("SE2")
	oObj:nIdTab := SE2->(RecNo())
	
	oObj:Activate()

Return()