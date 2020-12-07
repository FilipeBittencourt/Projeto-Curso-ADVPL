#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFRemessaPagar
@author Tiago Rossini Coradini
@since 02/10/2018
@project Automação Financeira
@version 1.0
@description Classe de envio de remessa de tituloas a Pagar
@type class
/*/

Class TAFRemessaPagar From TAFAbstractClass

Data oMrr // Objeto de movimento de remessa a Pagar	
Data oApi // Objeto de integracao com a API 
Data oERP
Data aArea

Method New() Constructor
Method Send() // Envia tirulos para a API
Method Validate() // Validacao geral dos titulos
Method SplitEnvironment(oList, cEnvironment)

EndClass


Method New() Class TAFRemessaPagar  

	_Super:New()

	::oMrr := TAFMovimentoRemessaPagar():New()
	::oApi := TAFIntegracaoApi():New()
	::oERP := TAFCnabPagar():New()

	::aArea := {}

	aAdd(::aArea, SEA->(GetArea()))
	aAdd(::aArea, SA2->(GetArea()))
	aAdd(::aArea, SE2->(GetArea()))

Return()


Method Send() Class TAFRemessaPagar

	::oPro:Start()

	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "P"
	::oLog:cMetodo := "I_REM_LOT"

	::oLog:Insert()

	::oMrr:cIDProc := ::oPro:cIDProc

	::oMrr:Get()

	If ::Validate()

		// Caso seja gerado pelo ERP
		::oERP:cTipo := "P"
		::oERP:cOpcEnv := "L"
		::oERP:oLst := ::SplitEnvironment(::oMrr:oLst, "1")
		::oERP:cIDProc := ::oPro:cIDProc
		::oERP:aArea := ::aArea

		::oERP:Send()

		//Caso seja gerado pela API
		::oApi:cTipo := "P"
		::oApi:cOpcEnv := "L"
		::oApi:oLst := ::SplitEnvironment(::oMrr:oLst, "2")
		::oApi:GArqRem := If(::oMrr:oLst:GetItem(1):cTpCom $ "2", "S", "N")
		::oApi:cIDProc := ::oPro:cIDProc

		::oApi:Send()

	EndIf

	::oLog:cIDProc := ::oPro:cIDProc
	::oLog:cOperac := "P"	
	::oLog:cMetodo := "F_REM_LOT"
	::oLog:cHrFin := Time()

	::oLog:Insert()

	::oPro:Finish()

Return()

Method SplitEnvironment(oList, cEnvironment) Class TAFRemessaPagar

	Local oListAux := ArrayList():New()
	Local nW

	For nW := 1 To oList:GetCount()

		If oList:GetItem(nW):cAmbiente == cEnvironment //1=ERP;2=Api

			oListAux:Add(oList:GetItem(nW))

		EndIf

	Next nW

Return(oListAux)


Method Validate() Class TAFRemessaPagar
	Local lRet := .T.

	lRet := ::oMrr:oLst:GetCount() > 0

Return(lRet)