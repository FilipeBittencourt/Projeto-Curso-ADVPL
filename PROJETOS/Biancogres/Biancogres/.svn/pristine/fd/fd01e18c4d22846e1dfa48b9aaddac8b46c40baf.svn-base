#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBAF015
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automação Financeira
@version 1.0
@description Classe para manipulação de parametros da rotina BAF008
@type function
/*/

Class TParBAF015 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data cBorDe
	Data cBorAte
	
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()	
	
EndClass


Method New() Class TParBAF015
	
	::cName := "BAF014"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.	
	
	::cBorDe := Space(TamSx3("E2_NUMBOR")[1])
	::cBorAte := Space(TamSx3("E2_NUMBOR")[1])
		
	::Add()
	
Return()


Method Add() Class TParBAF015

	aAdd(::aParam, {1, "Bordero de", ::cBorDe, "@!", ".T.",,".T.",,.F.})	
	aAdd(::aParam, {1, "Bordero Ate", ::cBorAte, "@!", ".T.",,".T.",,.F.})	
  
Return()


Method Box() Class TParBAF015
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
	
		::cBorDe := ::aParRet[1]
		::cBorAte := ::aParRet[2]
		
	EndIf
	
	/*
	If ::dDataBase <> dDataBase
	
		Alert("Data base do sistema deve ser a mesma do parametro!", "STOP")
		
		lRet := .F.
	
	EndIf
	*/
	
Return(lRet)


Method Update() Class TParBAF015
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBAF015
Local lRet := .T.
	
Return(lRet)