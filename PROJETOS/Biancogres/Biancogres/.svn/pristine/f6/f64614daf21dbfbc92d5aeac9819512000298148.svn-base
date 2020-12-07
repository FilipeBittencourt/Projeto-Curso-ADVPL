#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAF144
@author Tiago Rossini Coradini
@since 01/07/2019
@version 1.0
@description Classe para manipulação de parametros da rotina BIAF144
@type function
/*/

Class TParBIAF144 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data cBanco
	Data cAgencia
	Data cConta	
	Data dDataDe
	Data dDataAte
		
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()	
	
EndClass


Method New() Class TParBIAF144
	
	::cName := cEmpAnt + "_" + GetClassName(Self)
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.	
	
	::dDataDe := dDatabase
	::dDataAte := dDatabase

	::Add()
	
Return()


Method Add() Class TParBIAF144

	aAdd(::aParam, {1, "Data De", ::dDataDe, "@D", ".T.",,".T.",,.T.})
	aAdd(::aParam, {1, "Data Até", ::dDataAte, "@D", ".T.",,".T.",,.T.})	
  
Return()


Method Box() Class TParBIAF144
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::dDataDe := ::aParRet[1]
		::dDataAte := ::aParRet[2]
		
	EndIf
	
Return(lRet)


Method Update() Class TParBIAF144
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBIAF144
Local lRet := .T.
	
Return(lRet)