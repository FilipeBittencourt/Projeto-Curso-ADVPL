#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFRetornoConciliacao
@author Tiago Rossini Coradini
@since 02/10/2018
@project Automação Financeira
@version 1.0
@description Classe de retorno de extrato bancario/conciliacao
@type class
/*/

Class TAFRetornoConciliacao From TAFAbstractClass

	Data oApi // Objeto de integracao com a API
	
	Method New() Constructor
	Method Receive() // Recebe tirulos da API
	Method Validate() // Validacao geral dos titulos
	
EndClass


Method New() Class TAFRetornoConciliacao

	_Super:New()
	
	::oApi := TAFIntegracaoApi():New()
	
Return()


Method Receive() Class TAFRetornoConciliacao
	
	::oPro:Start()
	
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "C"
	::oLog:cMetodo := "I_RET"
	
	::oLog:Insert()
	
	If ::Validate()

		::oApi:cTipo := "C"
		::oApi:cIDProc := ::oPro:cIDProc
		
		::oApi:Receive()
	
	EndIf
	
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "C"
	::oLog:cMetodo := "F_RET"
	
	::oLog:Insert()
	
	::oPro:Finish()
		 	
Return()


Method Validate() Class TAFRetornoConciliacao
Local lRet := .T.
	
Return(lRet)