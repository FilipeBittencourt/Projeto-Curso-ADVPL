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
	Data lFIDC
	//Data dDeposito
	Data cUserJrNDepAnt
	Data oJSon

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

	::cBanco := Space(getSX3Cache("A6_COD","X3_TAMANHO"))
	::cAgencia := Space(getSX3Cache("A6_AGENCIA","X3_TAMANHO"))
	::cConta := Space(getSX3Cache("A6_NUMCON","X3_TAMANHO"))
	::cObs := ""
	::lDepAnt := .F.
	::lFIDC:=.F.
	//::dDeposito := dDataBase
	::cUserJrNDepAnt := U_GetBIAPAR("MV_YUSJDAN","001120")

	::Add()
	
Return()

Method Add() Class TAFParProrrogacaoBoletoReceber

	if (::lFIDC)
		::dVencto:=Ctod("")
	endif

	aAdd(::aParam,{9,"Informe os dados para o cálculo ou não de juros",200,nil,.T.})	
	aAdd(::aParam,{2,"Calc. juros",::cCalc,{"Sim","Nao"},50,".T.",.T.})		
	aAdd(::aParam,{1,"Percentual",::nPerc,X3Picture("E1_PORCJUR"),".T.",nil,"(MV_PAR02=='Sim')",50,.F.})
	aAdd(::aParam,{1,"Dt. Vencto JR",::dVencto,"@D",".T.",nil,if(::lFIDC,"AllWaysFalse().AND.","")+"(MV_PAR02=='Sim')",nil,.F.})

	If ((::lDepAnt).or.(::lFIDC))

		aAdd(::aParam,{9,"Informe os dados para depósito identificado",200,nil,.T.})

		aAdd(::aParam,{1,"Banco",::cBanco,"@!",".T.","SA6",if(::lFIDC,"AllWaysFalse().AND.","")+"(MV_PAR02=='Sim')",nil,.F.})
		aAdd(::aParam,{1,"Agência",::cAgencia,"@!",".T.",nil,if(::lFIDC,"AllWaysFalse().AND.","")+"(MV_PAR02=='Sim')",nil,.F.})
		aAdd(::aParam,{1,"Conta",::cConta,"@!",".T.",nil,if(::lFIDC,"AllWaysFalse().AND.","")+"(MV_PAR02=='Sim')",nil,.F.})

		aAdd(::aParam,{11,"Observação","",".T.",".T.",.F.})

	EndIf

Return()

Method Box() Class TAFParProrrogacaoBoletoReceber

	Local lRet := .F.

	Private cCadastro := "Parametros"
	
	If ((::lDepAnt).or.(::lFIDC))

		aSize(::aParam,0)

		::Add()

	EndIf

	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam,"Operações",::aParRet,::bConfirm,nil,,nil,,nil,::cName,.F.,.T.)
		
		lRet := .T.
			
		::cCalc := ::aParRet[2]
		::nPerc := ::aParRet[3]
		::dVencto := ::aParRet[4]

		If ((::lDepAnt).or.(::lFIDC))
			
			if (::lDepAnt)
				::cBanco := ::aParRet[6]
				::cAgencia := ::aParRet[7]
				::cConta := ::aParRet[8]
			endif

			if (::lFIDC)
				DEFAULT ::oJSon:=JSONArray():New()
				::oJSon:Set("Juros",if((::nPerc>0),"Sim","Nao"))
				::oJSon:Set("txJuros",::nPerc)
				::oJSon:Set("Obs",::aParRet[9])
				::cObs:=::oJSon:toJSON()
			else
				::cObs:=::aParRet[9]
			endif

		EndIf

	EndIf
	
Return(lRet)


Method Validate() Class TAFParProrrogacaoBoletoReceber
	
	Local lRet := .T.

	If Upper(MV_PAR02) == "SIM"
	
		If MV_PAR03 <= 0
		
			lRet := .F.
		
			MsgStop("Atenção,percentual de júros inválido.")
		
		ElseIf ((!::lFIDC).and.(MV_PAR04<>DataValida(MV_PAR04)))
			
			lRet := .F.
			
			MsgStop("Atenção,data de vencimento inválida.")
			
		ElseIf ((!::lFIDC).and.(MV_PAR04<dDataBase))
			
			lRet := .F.
			
			MsgStop("A data de vencimento não poderá ser menor do que data base.")
			
		EndIf

	ElseIf (Upper(MV_PAR02)=="NAO")

		if (!::lFIDC)

			If (::lDepAnt)
			
				If !(__cUserID $ ::cUserJrNDepAnt)
				
					lRet := .F.
				
					MsgStop("Usuario não autorizado a não geração do título de Juros!")

				EndIf

			EndIf

		endif

	EndIf

	If ((lRet).And.(::lDepAnt))

		If Len(AllTrim(MV_PAR09)) > TamSx3("E1_HIST")[1]

			lRet := .F.
			
			MsgStop("O campo Observação está com " + cValTochar(Len(AllTrim(MV_PAR09))) + " digitos,o tamanho limite para o campo Observação é de " + AllTrim(cValToChar(TamSx3("E1_HIST","X3_TAMANHO"))) + " digitos !")

		EndIf

	EndIf
	
Return(lRet)

Method Confirm() Class TAFParProrrogacaoBoletoReceber
	
	::lConfirm := ::Validate()
		
Return(::lConfirm)
