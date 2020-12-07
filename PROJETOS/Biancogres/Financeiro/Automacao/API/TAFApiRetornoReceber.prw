#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFApiRetornoReceber
@author Tiago Rossini Coradini
@since 25/02/2019
@project Automação Financeira
@version 1.0
@description Classe para Integracao dos titulos a receber com a API
@type class
/*/

Class TAFApiRetornoReceber From LongClassName
	
	Data cIDProc // Identificar do processo
	Data oIApi // Interface da API
	Data oRB // Objeto de retornos bancarios
	
	Method New() Constructor
	Method Receive() // Envia tirulos para a API

EndClass


Method New() Class TAFApiRetornoReceber

	::cIDProc := ""
	::oIApi := TIAFApiRetorno():New()
	::oRB := TAFRetornoBancario():New()

Return()


Method Receive() Class TAFApiRetornoReceber
	
	::oIApi:cTipo := "R"
	::oIApi:cIDProc := ::cIDProc
					
	::oRB:oLst := ::oIApi:Receive()
	::oRB:cIDProc := ::cIDProc
	::oRB:Process()
			
Return()