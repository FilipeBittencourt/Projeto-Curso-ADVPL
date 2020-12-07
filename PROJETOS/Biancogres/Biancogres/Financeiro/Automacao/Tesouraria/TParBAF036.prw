#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBAF036
@author Tiago Rossini Coradini
@since 01/07/2019
@project Automação Financeira
@version 1.0
@description Classe para manipulação de parametros da rotina BAF036
@type function
/*/

Class TParBAF036 From LongClassName

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


Method New() Class TParBAF036
	
	::cName := cEmpAnt + "_" + GetClassName(Self)
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.	
	
	::cBanco := Space(TamSx3("A6_COD")[1])
	::cAgencia := Space(TamSx3("A6_AGENCIA")[1])
	::cConta := Space(TamSx3("A6_NUMCON")[1])
	::dDataDe := dDatabase
	::dDataAte := dDatabase

	::Add()
	
Return()


Method Add() Class TParBAF036

  aAdd(::aParam, {1, "Banco", ::cBanco, "@!", "ExistCpo('SA6', MV_PAR01)", "SA6", ".T.",,.T.})
  aAdd(::aParam, {1, "Agência", ::cAgencia, "@!", ".T.",, ".T.",,.T.})
  aAdd(::aParam, {1, "Conta", ::cConta, "@!", ".T.",, ".T.",,.T.})
	aAdd(::aParam, {1, "Data De", ::dDataDe, "@D", ".T.",,".T.",,.T.})
	aAdd(::aParam, {1, "Data Até", ::dDataAte, "@D", ".T.",,".T.",,.T.})	
  
Return()


Method Box() Class TParBAF036
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::cBanco := ::aParRet[1]
		::cAgencia := ::aParRet[2]
		::cConta := ::aParRet[3]
		::dDataDe := ::aParRet[4]
		::dDataAte := ::aParRet[5]
		
	EndIf
	
Return(lRet)


Method Update() Class TParBAF036
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBAF036
Local lRet := .T.
	
Return(lRet)