#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} r
@author Tiago Rossini Coradini
@since 02/10/2018
@project Automação Financeira
@version 1.0
@description Classe de retorno de tituloas a receber
@type class
/*/

Class TAFRetornoReceber From TAFAbstractClass

	Data oApi // Objeto de integracao com a API
	
	Method New() Constructor
	Method Receive() // Recebe tirulos da API
	Method Validate() // Validacao geral dos titulos
	
EndClass


Method New() Class TAFRetornoReceber

	_Super:New()
	
	::oApi := TAFIntegracaoApi():New()
	
Return()


Method Receive() Class TAFRetornoReceber
	
	::oPro:Start()
	
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "I_RET"	

	::oLog:Insert()
	
	If ::Validate()			

		::oApi:cTipo := "R"
		::oApi:cIDProc := ::oPro:cIDProc
		
		::oApi:Receive()
	
	EndIf
	
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "F_RET"	

	::oLog:Insert()
	
	::oPro:Finish()
		 	
Return()


Method Validate() Class TAFRetornoReceber
Local lRet := .T.
	
Return(lRet)