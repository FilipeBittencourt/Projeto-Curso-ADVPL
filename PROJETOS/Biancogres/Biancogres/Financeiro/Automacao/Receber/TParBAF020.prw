#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBAF020
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automação Financeira
@version 1.0
@description Classe para manipulação de parametros da rotina BAF020
@type function
/*/

Class TParBAF020 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data cGrpCli // Grupo de Clientes
	Data cCodCli // Codigo do Cliente
	Data dVenctoDe // Data de vencimento De
	Data dVenctoAte // Data de vencimento Ate
	Data dDeposito // Data do deposito
			
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()	
	
EndClass


Method New() Class TParBAF020
	
	::cName := "BAF020"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.	
	
	::cGrpCli := Space(TamSx3("ZK8_GRPVEN")[1])
	::cCodCli := Space(TamSx3("ZK8_CODCLI")[1])
	::dVenctoDe := dDataBase
	::dVenctoAte := dDataBase
	::dDeposito := dDataBase
	
	::Add()
	
Return()


Method Add() Class TParBAF020
		
  aAdd(::aParam, {1, "Grp. Clientes", ::cGrpCli, "@!", ".T.","ACY",".T.",,.F.})
  aAdd(::aParam, {1, "Cliente", ::cCodCli, "@!", ".T.","SA1",".T.",,.F.})  
	aAdd(::aParam, {1, "Dt. Vencto De", ::dVenctoDe, "@D", ".T.",,".T.",,.T.})
	aAdd(::aParam, {1, "Dt. Vencto Ate", ::dVenctoAte, "@D", ".T.",,".T.",,.T.})
	aAdd(::aParam, {1, "Dt. Depósito", ::dDeposito, "@D", ".T.",,".T.",,.T.})	
  
Return()


Method Box() Class TParBAF020
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::cGrpCli := ::aParRet[1]
		::cCodCli := ::aParRet[2]
		::dVenctoDe := ::aParRet[3]
		::dVenctoAte := ::aParRet[4]
		::dDeposito := ::aParRet[5]
	
	EndIf
	
Return(lRet)


Method Update() Class TParBAF020
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBAF020

	If !Empty(MV_PAR01) .Or. !Empty(MV_PAR02)
		
		::lConfirm := .T.
	
	Else
		
		MsgStop("Atenção, o Grp. Clientes ou o Cliente não foram preenchido(s).")
	
	EndIf
	
Return(::lConfirm)