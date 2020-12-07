#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFRetornoPagar
@author Tiago Rossini Coradini
@since 02/10/2018
@project Automação Financeira
@version 1.0
@description Classe de retorno de titulos a pagar
@type class
/*/

Class TAFRetornoPagar From TAFAbstractClass

	Data oApi // Objeto de integracao com a API
	
	Method New() Constructor
	Method Receive() // Recebe tirulos da API
	Method Validate() // Validacao geral dos titulos
	
EndClass


Method New() Class TAFRetornoPagar

	_Super:New()
	
	::oApi := TAFIntegracaoApi():New()
	
Return()


Method Receive() Class TAFRetornoPagar
	
	::oPro:Start()
	
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "I_RET"
	
	::oLog:Insert()
	
	If ::Validate()

		::oApi:cTipo := "P"
		::oApi:cIDProc := ::oPro:cIDProc
		
		::oApi:Receive()
	
	EndIf
	
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "F_RET"
	
	::oLog:Insert()
	
	::oPro:Finish()
		 	
Return()


Method Validate() Class TAFRetornoPagar
	Local lRet := .T.
	
Return(lRet)