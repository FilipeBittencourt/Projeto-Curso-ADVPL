#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TAFParProrrogacaoBoletoReceber
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automação Financeira
@version 1.0
@description Classe para calculo de juros da rotina prorrogação de boletos a receber
@type function
/*/

Class TAFParProrrogacaoBoletoReceber From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	
	Data cCalc // Calcula ou nao juros
	Data nPerc // Percentual de juros negociado
	Data dVencto // Data de vencimento De

	Data cBanco
	Data cAgencia
	Data cConta
	Data cObs
	Data lDepAnt // Se sera gerado Deposito antecipado (Renegociacao devido COVID-19)
	//Data dDeposito
	Data cUserJrNDepAnt

	Method New() Constructor
	Method Add()
	Method Box()
	Method Validate()
	Method Confirm()	
	
EndClass


Method New() Class TAFParProrrogacaoBoletoReceber
	
	::cName := "ProrrogacaoBoletoReceber"
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.
	
	::cCalc := "Sim"
	::nPerc := 6
	::dVencto := dDataBase

	::cBanco := Space(TamSx3("A6_COD")[1])
	::cAgencia := Space(TamSx3("A6_AGENCIA")[1])
	::cConta := Space(TamSx3("A6_NUMCON")[1])
	::cObs := ""
	::lDepAnt := .F.
	//::dDeposito := dDataBase
	::cUserJrNDepAnt := U_GetBIAPAR("MV_YUSJDAN", "001120")

	::Add()
	
Return()


Method Add() Class TAFParProrrogacaoBoletoReceber
		
	aAdd(::aParam, {9, "Informe os dados para o cálculo ou não de juros", 200,, .T.})	
	aAdd(::aParam, {2, "Calc. juros", ::cCalc, {"Sim", "Nao"}, 50, ".T.", .T.})		
	aAdd(::aParam, {1, "Percentual", ::nPerc, X3Picture("E1_PORCJUR"), ".T.",,"MV_PAR02 == 'Sim'", 50,.F.})
	aAdd(::aParam, {1, "Dt. Vencto JR", ::dVencto, "@D", ".T.",,"MV_PAR02 == 'Sim'",,.F.})

	If ::lDepAnt

		aAdd(::aParam, {9, "Informe os dados para depósito identificado", 200,, .T.})

		aAdd(::aParam, {1, "Banco"		, ::cBanco		, "@!", ".T.", "SA6", "MV_PAR02 == 'Sim'",,.F.})
		aAdd(::aParam, {1, "Agência"	, ::cAgencia	, "@!", ".T.",, "MV_PAR02 == 'Sim'",,.F.})
		aAdd(::aParam, {1, "Conta"		, ::cConta		, "@!", ".T.",, "MV_PAR02 == 'Sim'",,.F.})
		//aAdd(::aParam, {1, "Dt. Depósito", ::dDeposito, "@D", ".T.",,".T.",,.T.})

		aAdd(::aParam, {11,"Observação","",".T.",".T.",.F.})

	EndIf

Return()


Method Box() Class TAFParProrrogacaoBoletoReceber
Local lRet := .F.
Private cCadastro := "Parametros"
	
	If ::lDepAnt

		::aParam := {}

		::Add()

	EndIf

	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .F., .T.)
		
		lRet := .T.
			
		::cCalc := ::aParRet[2]
		::nPerc := ::aParRet[3]
		::dVencto := ::aParRet[4]

		If ::lDepAnt
			
			::cBanco := ::aParRet[6]
			::cAgencia := ::aParRet[7]
			::cConta := ::aParRet[8]
			//::dDeposito := ::aParRet[9]

			::cObs := ::aParRet[9]

		EndIf

	EndIf
	
Return(lRet)


Method Validate() Class TAFParProrrogacaoBoletoReceber
Local lRet := .T.

	If Upper(MV_PAR02) == "SIM"
	
		If MV_PAR03 <= 0
		
			lRet := .F.
		
			MsgStop("Atenção, percentual de júros inválido.")
		
		ElseIf MV_PAR04 <> DataValida(MV_PAR04)
			
			lRet := .F.
			
			MsgStop("Atenção, data de vencimento inválida.")
			
		ElseIf MV_PAR04 < dDataBase
			
			lRet := .F.
			
			MsgStop("A data de vencimento não poderá ser menor do que data base.")
			
		EndIf

	ElseIf Upper(MV_PAR02) == "NAO"

		If ::lDepAnt
		
			If !(__cUserID $ ::cUserJrNDepAnt)
			
				lRet := .F.
			
				MsgStop("Usuario não autorizado a não geração do título de Juros!")

			EndIf

		EndIf
	
	EndIf

	If lRet .And.::lDepAnt

		If Len(AllTrim(MV_PAR09)) > TamSx3("E1_HIST")[1]

			lRet := .F.
			
			MsgStop("O campo Observação está com " + cValTochar(Len(AllTrim(MV_PAR09))) + " digitos, o tamanho limite para o campo Observação é de " + AllTrim(cValToChar(TamSx3("E1_HIST")[1])) + " digitos !")

		EndIf

	EndIf
	
Return(lRet)


Method Confirm() Class TAFParProrrogacaoBoletoReceber
	
	::lConfirm := ::Validate()
		
Return(::lConfirm)