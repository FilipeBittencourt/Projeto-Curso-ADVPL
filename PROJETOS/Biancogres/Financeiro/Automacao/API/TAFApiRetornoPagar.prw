#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFApiRetornoPagar
@author Tiago Rossini Coradini
@since 25/02/2019
@project Automação Financeira
@version 1.0
@description Classe para Integracao dos titulos a Pagar com a API
@type class
/*/

Class TAFApiRetornoPagar From LongClassName
	
	Data cIDProc // Identificar do processo
	Data oIApi // Interface da API
	Data oRB // Objeto de retornos bancarios
	
	Method New() Constructor
	Method Receive() // Envia tirulos para a API

EndClass


Method New() Class TAFApiRetornoPagar

	::cIDProc := ""
	::oIApi := TIAFApiRetorno():New()
	::oRB := TAFRetornoBancario():New()

Return()


Method Receive() Class TAFApiRetornoPagar

	::oIApi:cTipo := "P"
	::oIApi:cIDProc := ::cIDProc
				
	::oRB:oLst := ::oIApi:Receive()
	::oRB:cIDProc := ::cIDProc		
	::oRB:Process()
			
Return()