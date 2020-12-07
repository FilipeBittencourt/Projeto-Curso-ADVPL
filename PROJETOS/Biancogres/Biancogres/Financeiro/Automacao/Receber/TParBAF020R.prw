#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBAF020R
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automação Financeira
@version 1.0
@description Classe para manipulação de parametros da rotina BAF020R
@type function
/*/

Class TParBAF020R From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data cNumeroDe // Numero do Deposito De
	Data cNumeroAte // Numero do Deposito Ate
	Data cGrpCliDe // Grupo de Clientes De
	Data cGrpCliAte // Grupo de Clientes Ate
	Data cCodCliDe // Codigo do Cliente De
	Data cCodCliAte // Codigo do Cliente Ate
	Data dVenctoDe // Data de vencimento De
	Data dVenctoAte // Data de vencimento Ate
	Data dDepDe // Data do deposito De
	Data dDepiAte // Data do deposito	Ate
			
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()	
	
EndClass


Method New() Class TParBAF020R
	
	::cName := "BAF020R"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.	
	
	::cNumeroDe := Space(TamSx3("ZK8_NUMERO")[1])
	::cNumeroAte := Replicate("Z", TamSx3("ZK8_NUMERO")[1])
	::cGrpCliDe := Space(TamSx3("ZK8_GRPVEN")[1])
	::cGrpCliAte := Replicate("Z", TamSx3("ZK8_GRPVEN")[1])
	::cCodCliDe := Space(TamSx3("ZK8_CODCLI")[1])
	::cCodCliAte := Replicate("Z", TamSx3("ZK8_CODCLI")[1])
	::dVenctoDe := dDataBase
	::dVenctoAte := dDataBase
	::dDepDe := dDataBase
	::dDepiAte := dDataBase

	::Add()
	
Return()


Method Add() Class TParBAF020R

  aAdd(::aParam, {1, "Num. Depósito De", ::cNumeroDe, "@!", ".T.",, ".T.",,.F.})
  aAdd(::aParam, {1, "Num. Depósito Ate", ::cNumeroAte, "@!", ".T.",, ".T.",,.F.})		
  aAdd(::aParam, {1, "Grp. Clientes De", ::cGrpCliDe, "@!", ".T.", "ACY", ".T.",,.F.})
  aAdd(::aParam, {1, "Grp. Clientes Ate", ::cGrpCliAte, "@!", ".T.", "ACY", ".T.",,.F.})
  aAdd(::aParam, {1, "Cliente De", ::cCodCliDe, "@!", ".T.", "SA1", ".T.",,.F.})  
  aAdd(::aParam, {1, "Cliente Ate", ::cCodCliAte, "@!", ".T.", "SA1", ".T.",,.F.})    
	aAdd(::aParam, {1, "Dt. Vencto De", ::dVenctoDe, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Dt. Vencto Ate", ::dVenctoAte, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Dt. Depósito De", ::dDepDe, "@D", ".T.",,".T.",,.F.})	
	aAdd(::aParam, {1, "Dt. Depósito Ate", ::dDepiAte, "@D", ".T.",,".T.",,.F.})
  
Return()


Method Box() Class TParBAF020R
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::cNumeroDe := ::aParRet[1]
		::cNumeroAte := ::aParRet[2]
		::cGrpCliDe := ::aParRet[3]
		::cGrpCliAte := ::aParRet[4]
		::cCodCliDe := ::aParRet[5]
		::cCodCliAte := ::aParRet[6]
		::dVenctoDe := ::aParRet[7]
		::dVenctoAte := ::aParRet[8]
		::dDepDe := ::aParRet[9]
		::dDepiAte := ::aParRet[10]
		
	EndIf
	
Return(lRet)


Method Update() Class TParBAF020R
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBAF020R
Local lRet := .T.
	
Return(lRet)