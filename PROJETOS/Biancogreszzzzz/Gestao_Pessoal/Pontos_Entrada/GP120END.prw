#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} GP120END
@author Wlysses Cerqueira (Facile)
@since 01/04/2019
@project Automação Financeira
@version 1.0
@description 
@type PE chamado no final da rotina fechamento de periodo.
/*/

User Function GP120END()
	
	Local oObj := TBaixaDacaoReceber():New("RES")
	
	oObj:Processa()

Return()