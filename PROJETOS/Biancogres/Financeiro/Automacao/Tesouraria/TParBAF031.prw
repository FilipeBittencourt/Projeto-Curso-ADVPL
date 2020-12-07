#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBAF031
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automação Financeira
@version 1.0
@description Classe para manipulação de parametros da rotina BAF031
@type function
/*/

Class TParBAF031 From LongClassName

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
	Data cTipo
	Data cVisib
		
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()	
	
EndClass


Method New() Class TParBAF031
	
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
	::cTipo := "Todos"
	::cVisib := "Todos"

	::Add()
	
Return()


Method Add() Class TParBAF031

  aAdd(::aParam, {1, "Banco", ::cBanco, "@!", "ExistCpo('SA6', MV_PAR01)", "SA6", ".T.",,.T.})
  aAdd(::aParam, {1, "Agência", ::cAgencia, "@!", ".T.",, ".T.",,.T.})
  aAdd(::aParam, {1, "Conta", ::cConta, "@!", ".T.",, ".T.",,.T.})
	aAdd(::aParam, {1, "Data De", ::dDataDe, "@D", ".T.",,".T.",,.T.})
	aAdd(::aParam, {1, "Data Até", ::dDataAte, "@D", ".T.",,".T.",,.T.})
	aAdd(::aParam, {2, "Tipo", ::cTipo, {"Credito", "Debito", "Todos"}, 50, ".T.", .T.})
	aAdd(::aParam, {2, "Visibilidade", ::cVisib, {"Conciliados", "Não Conciliados", "Todos"}, 50, ".T.", .T.})
  
Return()


Method Box() Class TParBAF031
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
		::cTipo := ::aParRet[6]
		::cVisib := ::aParRet[7]						
		
	EndIf
	
Return(lRet)


Method Update() Class TParBAF031
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBAF031
Local lRet := .T.
	
Return(lRet)