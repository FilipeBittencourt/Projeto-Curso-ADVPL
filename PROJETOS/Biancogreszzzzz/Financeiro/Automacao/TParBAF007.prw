#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBAF007
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automação Financeira
@version 1.0
@description Classe para manipulação de parametros da rotina BAF007
@type function
/*/

Class TParBAF007 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data cNumBorDe
	Data cNumBorAte
	Data cOpcEnv
	Data cReimpr
		
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()	
	
EndClass


Method New() Class TParBAF007
	
	::cName := "BAF007"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.	
	
	::cNumBorDe := Space(6)
	::cNumBorAte := Space(6)
	::cOpcEnv := "Lote"
	::cReimpr := "N"
	
	::Add()
	
Return()


Method Add() Class TParBAF007
		
	aAdd(::aParam, {1, "Bordero de", ::cNumBorDe, "@!", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Bordero até", ::cNumBorAte, "@!", ".T.",,".T.",,.F.})
	aAdd(::aParam, {2, "Opção de envio", ::cOpcEnv, {"Lote", "Titulo"}, 60, ".T.", .F.})	
	aAdd(::aParam, {2, "Reimpressão?", ::cReimpr, {"Não", "Sim"}, 60, ".T.", .F.})
	
Return()


Method Box() Class TParBAF007
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::cNumBorDe := ::aParRet[1]
		::cNumBorAte := ::aParRet[2]
		::cOpcEnv := SubStr(::aParRet[3], 1, 1)
		::cReimpr := SubStr(::aParRet[4], 1, 1)
		
	EndIf
	
Return(lRet)


Method Update() Class TParBAF007
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBAF007
Local lRet := .T.
	
Return(lRet)