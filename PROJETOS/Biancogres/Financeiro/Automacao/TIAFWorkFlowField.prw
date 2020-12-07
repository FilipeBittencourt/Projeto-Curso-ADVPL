#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFWorkFlow
@author Tiago Rossini Coradini
@since 31/10/2018
@project Automação Financeira
@version 1.0
@description Classe para tratamento de workflow (Html)
@type class
/*/

Class TAFWorkFlowField From LongClassName

	Data cName
	Data cTitle
	Data cType
	Data cPict
	Data nHeight
	Data nWidth
	Data lUser
	Data oRow
	
	Method New() Constructor

EndClass


Method New() Class TAFWorkFlowField

	::cName := ""
	::cTitle := ""
	::cType := ""
	::cPict := ""	
	::nHeight := 0
	::nWidth := 60
	::lUser := .F.
	::oRow := ArrayList():New()

Return()