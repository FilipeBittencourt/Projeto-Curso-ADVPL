#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAF153
@author ERP-Tools
@since 14/09/2018
@version 1.0
@description Classe para manipulação de parametros da rotina BIAF153 
@type Class
/*/

Class TParBIAF153 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm

	Data cVersao
	Data cRevisao
	Data cAno
	Data cPeriodo

	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()

EndClass

Method New() Class TParBIAF153

	::cName    := cEmpAnt + "_" + GetClassName(Self)	
	::aParam   := {}
	::aParRet  := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.	

	::cVersao  := Space(10)
	::cRevisao := Space(3)
	::cAno     := Space(4)
	::cPeriodo := Space(2)

	::Add()

Return()

Method Add() Class TParBIAF153

	aAdd(::aParam, {1, "Versão:"   , ::cVersao,  "@!", "NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd(::aParam, {1, "Revisão"   , ::cRevisao, "@!", "NAOVAZIO()",,     '.T.', 04,.T.})		
	aAdd(::aParam, {1, "Ano Ref.:" , ::cAno,     "@!", "NAOVAZIO()",,     '.T.', 03,.T.})
	aAdd(::aParam, {1, "Período"   , ::cPeriodo, "@!", ".T."       ,,     '.T.', 02,.T.})	

Return()

Method Box() Class TParBIAF153

	Local lRet := .F.
	Private cCadastro := "Parametros"

	::bConfirm := {|| ::Confirm() }

	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .F., .F.)

		lRet := .T.

		::cVersao  := ::aParRet[1]
		::cRevisao := ::aParRet[2]
		::cAno     := ::aParRet[3]
		::cPeriodo := ::aParRet[4]

	EndIf

Return(lRet)

Method Update() Class TParBIAF153

	::aParam := {}	
	::Add()

Return()

Method Confirm() Class TParBIAF153

	::lConfirm := .T.

Return(::lConfirm)
