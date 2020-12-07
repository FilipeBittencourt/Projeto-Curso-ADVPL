#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBAF012
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automação Financeira
@version 1.0
@description Classe para manipulação de parametros da rotina BAF012
@type function
/*/

Class TParBAF012 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data cPrefixoDe // Prefixo De
	Data cPrefixoAte // Prefixo De
	Data cNumeroDe // Numero De
	Data cNumeroAte // Numero Ate
	Data cCliDe // Cliente De
	Data cCliAte // Cliente Ate
	Data dVenctoDe // Data de vencimento De
	Data dVenctoAte // Data de vencimento Ate
	Data dReferenca // Nova data de vencimento
			
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()	
	
EndClass


Method New() Class TParBAF012
	
	::cName := "BAF012"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.	
	
	::cPrefixoDe := Space(TamSx3("E1_PREFIXO")[1])
	::cPrefixoAte := Replicate("Z", TamSx3("E1_PREFIXO")[1])
	::cNumeroDe := Space(TamSx3("E1_NUM")[1])
	::cNumeroAte := Replicate("Z", TamSx3("E1_NUM")[1])
	::cCliDe := Space(TamSx3("E1_CLIENTE")[1])
	::cCliAte := Replicate("Z", TamSx3("E1_CLIENTE")[1])
	::dVenctoDe := dDataBase
	::dVenctoAte := dDataBase
	::dReferenca := dDataBase
	
	::Add()
	
Return()


Method Add() Class TParBAF012
		
	aAdd(::aParam, {1, "Prefixo De", ::cPrefixoDe, "@!", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Prefixo Ate", ::cPrefixoAte, "@!", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Numero De", ::cNumeroDe, "@!", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Numero Ate", ::cNumeroAte, "@!", ".T.",,".T.",,.F.})
  aAdd(::aParam, {1, "Cliente De", ::cCliDe, "@!", ".T.","SA1",".T.",,.F.})
  aAdd(::aParam, {1, "Cliente Ate", ::cCliAte, "@!", ".T.","SA1",".T.",,.F.})
	aAdd(::aParam, {1, "Dt. Vencto De", ::dVenctoDe, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Dt. Vencto Ate", ::dVenctoAte, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Dt. Referencia", ::dReferenca, "@D", ".T.",,".T.",,.F.})	
  
Return()


Method Box() Class TParBAF012
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::cPrefixoDe := ::aParRet[1]
		::cPrefixoAte := ::aParRet[2]
		::cNumeroDe := ::aParRet[3]
		::cNumeroAte := ::aParRet[4]
		::cCliDe := ::aParRet[5]
		::cCliAte := ::aParRet[6]
		::dVenctoDe := ::aParRet[7]
		::dVenctoAte := ::aParRet[8]
		::dReferenca := ::aParRet[9]
	
	EndIf
	
Return(lRet)


Method Update() Class TParBAF012
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBAF012
Local lRet := .T.
	
Return(lRet)