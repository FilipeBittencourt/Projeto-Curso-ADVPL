#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAF166
@author Tiago Rossini Coradini
@since 11/10/2018
@version 1.0
@description Classe para manipulação de parametros da rotina BIAF166
@type function
/*/

Class TParBIAF166 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm

	Data dData	

	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()
	
EndClass


Method New() Class TParBIAF166
	
	::cName := "BIAF166"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .T.

	::dData:= dDataBase

	::Add()
	
Return()


Method Add() Class TParBIAF166
	
	aAdd(::aParam, {1, "Data", ::dData, "@D", ".T.",,".T.",,.F.})

Return()


Method Box() Class TParBIAF166
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::dData:= ::aParRet[1]

	EndIf
	
Return(lRet)


Method Update() Class TParBIAF166
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBIAF166
	
Return(::lConfirm)