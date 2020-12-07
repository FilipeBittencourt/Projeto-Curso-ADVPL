#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParLancamentoManual
@author Tiago Rossini Coradini
@since 07/06/2018
@version 1.0
@description Classe para inclusao de lancamentos manuais da rotina de composicao de saldo financeiro  
@obs Ticket: 4615
@type Class
/*/

Class TParLancamentoManual From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data cBank
	Data cAgency
	Data cAccount
	
	Data dDate
	Data cHist
	Data nValue
	Data cType	
		
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()	
	
EndClass


Method New() Class TParLancamentoManual
	
	::cName := "BIAF110_LM"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| ::Confirm() }
	::lConfirm := .F.
	
	::cBank := ""
	::cAgency := ""
	::cAccount := ""
	
	::dDate := cToD("")
	::cHist := Space(100)
	::nValue := 0
	::cType := "Credito"		
	
Return()


Method Add() Class TParLancamentoManual
	
	aAdd(::aParam, {9, "Banco: " + ::cBank + " Ag: " + ::cAgency + " Cc: " + ::cAccount, 200,, .T.})
	aAdd(::aParam, {1, "Data", ::dDate, "@D", ".T.",,".T.", 50, .T.})
	aAdd(::aParam, {1, "Historico", ::cHist, "@!", ".T.",,".T.", 100,.T.})
	aAdd(::aParam, {1, "Valor", ::nValue, X3Picture("E5_VALOR"), ".T.",,".T.", 50,.T.})
	aAdd(::aParam, {2, "Tipo", ::cType, {"Credito", "Debito"}, 50, ".T.", .T.})	
	
Return()


Method Box() Class TParLancamentoManual
Local lRet := .F.
Private cCadastro := "Lançamentos Manuais"
	
	::Add()
	
	If ParamBox(::aParam, "Inclusão", ::aParRet, ::bConfirm,,,,,,::cName, .F., .F.)
		
		lRet := .T.
			
		::dDate := ::aParRet[2]
		::cHist := ::aParRet[3]
		::nValue := ::aParRet[4]
		::cType := ::aParRet[5]

	EndIf
	
Return(lRet)


Method Update() Class TParLancamentoManual
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParLancamentoManual
Local lRet := .T.
		
Return(lRet)