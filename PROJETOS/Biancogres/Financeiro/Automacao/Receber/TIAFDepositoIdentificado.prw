#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TIAFDepositoIdentificado
@author Tiago Rossini Coradini
@since 25/04/2019
@project Automação Financeira
@version 1.0
@description Classe de interface de deposito identificado
@type class
/*/

Class TIAFDepositoIdentificado From LongClassName

	Data cEmp
	Data cFil
	Data cNumero
	Data dDtLanc
	Data dDtCont
	Data nValor
	Data nJuros
	Data cBanco
	Data cAgencia
	Data cConta
	Data nRecNo
	Data nRecNoZK4
	Data lOK
	Data oLst
	
	Method New() Constructor

EndClass


Method New() Class TIAFDepositoIdentificado

	::cEmp := cEmpAnt
	::cFil := cFilAnt
	::cNumero := ""
	::dDtLanc := dDataBase
	::dDtCont := dDataBase
	::nValor := 0
	::nJuros := 0
	::cBanco := ""
	::cAgencia := ""
	::cConta := ""
	::nRecNo := 0
	::nRecNoZK4 := 0
	::lOK := .F.
	::oLst := ArrayList():New()

Return()
