#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBAF034
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automa��o Financeira
@version 1.0
@description Classe para manipula��o de parametros da rotina BAF034
@type function
/*/

Class TParBAF034 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm

    Data cProcesso
	Data cPrefixoDe // Prefixo De
	Data cPrefixoAte // Prefixo De
	Data cNumeroDe // Numero De
	Data cNumeroAte // Numero Ate	
	Data cGrpCli // Grupo de Clientes
	Data cCodCli // Codigo do Cliente
	Data dVenctoDe // Data de vencimento De
	Data dVenctoAte // Data de vencimento Ate
	Data dReferenca // Nova data de vencimento
	Data lDepAnt // Se sera gerado Deposito antecipado (Renegociacao devido COVID-19)
	Data nQtdRef // Caso seja deposito identificado somar no vencimento
			
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()	
	
EndClass


Method New() Class TParBAF034
	
	::cName := "BAF034"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.

    ::cProcesso    := Space(TamSx3("ZK8_NUMERO")[1])
	::cPrefixoDe := Space(TamSx3("E1_PREFIXO")[1])
	::cPrefixoAte := Replicate("Z", TamSx3("E1_PREFIXO")[1])
	::cNumeroDe := Space(TamSx3("E1_NUM")[1])
	::cNumeroAte := Replicate("Z", TamSx3("E1_NUM")[1])	
	::cGrpCli := Space(TamSx3("A1_GRPVEN")[1])
	::cCodCli := Space(TamSx3("A1_COD")[1])	
	::dVenctoDe := dDataBase
	::dVenctoAte := dDataBase
	::dReferenca := dDataBase
	
	::Add()
	
Return()


Method Add() Class TParBAF034

    aAdd(::aParam, {1, "Processo"			, ::cProcesso	, "@!", ".T.", "ZK8", ".T.",50,.F.})
	aAdd(::aParam, {1, "Prefixo De"			, ::cPrefixoDe	, "@!", ".T.",,"Empty(MV_PAR01)",,.F.})
	aAdd(::aParam, {1, "Prefixo Ate"		, ::cPrefixoAte	, "@!", ".T.",,"Empty(MV_PAR01)",,.F.})
	aAdd(::aParam, {1, "Numero De"			, ::cNumeroDe	, "@!", ".T.",,"Empty(MV_PAR01)",,.F.})
	aAdd(::aParam, {1, "Numero Ate"			, ::cNumeroAte	, "@!", ".T.",,"Empty(MV_PAR01)",,.F.})
  	aAdd(::aParam, {1, "Grp. Clientes"		, ::cGrpCli		, "@!", ".T.","ACY","Empty(MV_PAR01)",,.F.})
  	aAdd(::aParam, {1, "Cliente"			, ::cCodCli		, "@!", ".T.","SA1","Empty(MV_PAR01)",,.F.})
	aAdd(::aParam, {1, "Dt. Vencto De"		, ::dVenctoDe	, "@D", ".T.",,"Empty(MV_PAR01)",,.T.})
	aAdd(::aParam, {1, "Dt. Vencto Ate"		, ::dVenctoAte	, "@D", ".T.",,"Empty(MV_PAR01)",,.T.})
	aAdd(::aParam, {2, "Gerar Dep.Ident."	, "2", {"1=Sim", "2=N�o"}, 60, ".T.", .F.})
	aAdd(::aParam, {1, "Qtd. Referencia"	, 0				, "@E 999"	, ".T.",,"Empty(MV_PAR01) .AND. MV_PAR10 == '1'",,.F.})
	aAdd(::aParam, {1, "Dt. Referencia"		, ::dReferenca	, "@D"		, ".T.",,"Empty(MV_PAR01) .AND. MV_PAR10 == '2'",,.F.})

Return()

Method Box() Class TParBAF034
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Opera��es", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.


    	::cProcesso    := ::aParRet[1]
		::cPrefixoDe := ::aParRet[2]
		::cPrefixoAte := ::aParRet[3]
		::cNumeroDe := ::aParRet[4]
		::cNumeroAte := ::aParRet[5]
		::cGrpCli := ::aParRet[6]
		::cCodCli := ::aParRet[7]
		::dVenctoDe := ::aParRet[8]
		::dVenctoAte := ::aParRet[9]
		::lDepAnt := ::aParRet[10] == "1"
		::nQtdRef := ::aParRet[11]
		::dReferenca := ::aParRet[12]
	
	EndIf
	
Return(lRet)


Method Update() Class TParBAF034
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBAF034
	
	If Empty(MV_PAR01)

		If !Empty(MV_PAR02) .Or. !Empty(MV_PAR03)
			
			::lConfirm := .T.
		
		Else
			
			MsgStop("Aten��o, o Grp. Clientes ou o Cliente n�o foram preenchido(s).")
		
		EndIf
	
	Else
		
		::lConfirm := .T.
		
	EndIf
	
Return(::lConfirm)