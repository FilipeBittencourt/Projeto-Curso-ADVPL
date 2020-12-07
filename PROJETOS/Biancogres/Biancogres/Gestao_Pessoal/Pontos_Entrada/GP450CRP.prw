#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWPRINTSETUP.CH"

/*/{Protheus.doc} GP450CRP
@author Wlysses Cerqueira (Facile)
@since 01/04/2019
@project Automação Financeira
@version 1.0
@description 
@type PE chamado no final da rotina fechamento de periodo.
/*/

User Function GP450CRP()

	Local oObj := BIA934():New()
	
	oObj:Relatorio()
	
Return()