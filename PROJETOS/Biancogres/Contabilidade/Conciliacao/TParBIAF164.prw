#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAF164
@author Tiago Rossini Coradini
@since 11/10/2018
@version 1.0
@description Classe para manipulação de parametros da rotina BIAF164
@type function
/*/

Class TParBIAF164 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm

	Data cConta
	Data dDataDe
	Data dDataAte	

	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()
	
EndClass


Method New() Class TParBIAF164
	
	::cName := "BIAF164"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .T.

	::cConta := Space(TamSx3("A1_CONTA")[1])
	::dDataDe:= dDataBase
	::dDataAte := dDataBase

	::Add()
	
Return()


Method Add() Class TParBIAF164
	
  aAdd(::aParam, {1, "Conta", ::cConta, "@!", ".T.",, ".T.",,.F.})
	aAdd(::aParam, {1, "Dt Contabil De", ::dDataDe, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Dt Contabil Ate", ::dDataAte, "@D", ".T.",,".T.",,.F.})

Return()


Method Box() Class TParBIAF164
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::cConta := ::aParRet[1]
		::dDataDe:= ::aParRet[2]
		::dDataAte := ::aParRet[3]

	EndIf
	
Return(lRet)


Method Update() Class TParBIAF164
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBIAF164
	
Return(::lConfirm)