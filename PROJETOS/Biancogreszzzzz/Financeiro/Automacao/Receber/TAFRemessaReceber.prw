#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFRemessaReceber
@author Tiago Rossini Coradini
@since 02/10/2018
@project Automação Financeira
@version 1.0
@description Classe de envio de remessa de tituloas a receber
@type class
/*/

Class TAFRemessaReceber From TAFAbstractClass
	
	Data oMrr // Objeto de movimento de remessa a receber	
	Data oApi // Objeto de integracao com a API 
	
	Method New() Constructor
	Method Send() // Envia tirulos para a API
	Method Validate() // Validacao geral dos titulos
	
EndClass


Method New() Class TAFRemessaReceber  
	
	_Super:New()
	
	::oMrr := TAFMovimentoRemessaReceber():New()
	::oApi := TAFIntegracaoApi():New()
	
Return()


Method Send() Class TAFRemessaReceber
	
	::oPro:Start()
	
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"
	::oLog:cMetodo := "I_REM_LOT"
	
	::oLog:Insert()
		
	::oMrr:cIDProc := ::oPro:cIDProc
	
	::oMrr:Get()
	
	If ::Validate()

		::oApi:cTipo := "R"
		::oApi:cOpcEnv := "L"
		::oApi:oLst := ::oMrr:oLst
		//::oApi:GArqRem := If(::oMrr:oLst:__Item[1]:cTpCom $ "2|4", "S", "N")
		::oApi:cIDProc := ::oPro:cIDProc
		
		::oApi:Send()
	
	EndIf
	
	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "R"	
	::oLog:cMetodo := "F_REM_LOT"
	::oLog:cHrFin := Time()
	
	::oLog:Insert()
	
	::oPro:Finish()
		 	
Return()


Method Validate() Class TAFRemessaReceber
Local lRet := .T.
	
	lRet := !Empty(::oMrr:oBor:oLst)
	
Return(lRet)