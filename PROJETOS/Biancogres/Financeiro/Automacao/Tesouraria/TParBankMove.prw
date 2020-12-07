#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBankMove
@author Tiago Rossini Coradini
@since 15/07/2019
@project Automação Financeira
@version 1.0
@description Classe para manipulação de parametros da rotina movimentacao bancaria
@type function
/*/

STATIC _Self := Nil

Class TParBankMove From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm
	Data lConfirm
	Data lEnable
	
	Data cBanco
	Data cAgencia
	Data cConta
	Data dData
	Data cTipo
	Data cMoeda
	Data nValor
	Data cNatureza
	Data cHistorico
	Data cCentroCusto
	Data cClasseValor
	Data nIdApi
		
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()	
	Method Validate(cPar)	
	Method VldMoeda()
	Method VldValor()
	Method VldNatureza()
	Method VldCentroCusto()
	Method VldClasseValor()
	Method RunTrigger()
	Method Clear()
	Method Confirm()
	
EndClass


Method New() Class TParBankMove
	
	::cName := cEmpAnt + "_" + GetClassName(Self)
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}
	::lConfirm := .F.
	::lEnable := .T.
	
	::cBanco := Space(TamSx3("E5_BANCO")[1])
	::cAgencia := Space(TamSx3("E5_AGENCIA")[1])
	::cConta := Space(TamSx3("E5_CONTA")[1])
	::dData := dDataBase
	::cTipo := "Pagar"
	::cMoeda := "M1"
	::nValor := 0
	::cNatureza := Space(TamSx3("E5_NATUREZ")[1])
	::cHistorico := Space(TamSx3("E5_HISTOR")[1])
	::cCentroCusto := Space(TamSx3("E5_CCD")[1])
	::cClasseValor := Space(TamSx3("E5_CLVLDB")[1])
	::nIdApi := 0
	
	_Self := Self
	
Return()


Method Add() Class TParBankMove

	aAdd(::aParam, {9, "Banco: " + ::cBanco + " Ag: " + AllTrim(::cAgencia) + " Cc: " + AllTrim(::cConta), 200,, .T.})
	aAdd(::aParam, {1, "Data", ::dData, "@D", ".T.",,".F.", 50, .T.})
	aAdd(::aParam, {2, "Tipo", ::cTipo, {"Pagar", "Receber"}, 50, ".T.", .T., ::lEnable})
	aAdd(::aParam, {1, "Numerario", ::cMoeda, "@!", "U_BAF031A('04')", "06", ".T.", 50,.T.})
	aAdd(::aParam, {1, "Valor", ::nValor, X3Picture("E5_VALOR"), "U_BAF031A('05')",,cValToChar(::lEnable), 50, .T.})
	aAdd(::aParam, {1, "Natureza", ::cNatureza, "@!", "U_BAF031A('06')", "SED", ".T.", 50, .T.})
	aAdd(::aParam, {1, "Historico", ::cHistorico, "@!", ".T.",,".T.", 100, .T.})
	aAdd(::aParam, {1, "Centro de Custo", ::cCentroCusto, "@!", "U_BAF031A('08')", "CTT", ".T.", 50, .T.})
	aAdd(::aParam, {1, "Classe Valor", ::cClasseValor, "@!", "U_BAF031A('09')", "CTH", ".T.", 50, .T.})
	
Return()


Method Box() Class TParBankMove
Local lRet := .F.
Private cCadastro := "Movimento Bancário"
	
	::Add()
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Inclusão", ::aParRet, ::bConfirm,,,,,,::cName, .F., .F.)
		
		lRet := .T.
			
		::dData := ::aParRet[2]
		::cTipo := ::aParRet[3]
		::cMoeda := ::aParRet[4]
		::nValor := ::aParRet[5]
		::cNatureza := ::aParRet[6]
		::cHistorico := ::aParRet[7]
		::cCentroCusto := ::aParRet[8]
		::cClasseValor := ::aParRet[9]
				
	EndIf
	
Return(lRet)


Method Update() Class TParBankMove
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Validate(cPar) Class TParBankMove
Local lRet := .T.

	If cPar == "04"
		
		lRet := ::VldMoeda()
	
	ElseIf cPar == "05"
		
		lRet := ::VldValor()
	
	ElseIf cPar == "06"
	
		lRet := ::VldNatureza()
	
	ElseIf cPar == "08"
		
		lRet := ::VldCentroCusto()
	
	ElseIf cPar == "09"	
		
		lRet := ::VldClasseValor()
		
	EndIf
	
Return(lRet)


Method VldMoeda() Class TParBankMove
Local lRet := .T.
	
	lRet := ExistCpo('SX5', '06' + MV_PAR04)
	
Return(lRet)


Method VldValor() Class TParBankMove
Local lRet := .T.
	
	lRet := Positivo(MV_PAR05)
	
Return(lRet)


Method VldNatureza() Class TParBankMove
Local lRet := .T.
	
	If (lRet := ExistCpo('SED', MV_PAR06))
	
		::Clear()
		
		::RunTrigger()
	
	EndIf
	
Return(lRet)


Method VldCentroCusto() Class TParBankMove
Local lRet := .T.
	
	lRet := ExistCpo('CTT', MV_PAR08)
	
Return(lRet)


Method VldClasseValor() Class TParBankMove
Local lRet := .T.

	lRet := ExistCpo('CTH', MV_PAR09)
	
Return(lRet)


Method RunTrigger() Class TParBankMove
Local aArea := GetArea()
	
	If SubStr(MV_PAR03, 1, 1) == "P"

		DbSelectArea("SED")
		DbSetOrder(1)
		If SED->(DbSeek(xFilial("SED") + MV_PAR06))
		
			MV_PAR07 := AllTrim(SED->ED_YHIST)
			
			MV_PAR08 := If (SM0->M0_CODIGO == "05", SED->ED_YCCI, SED->ED_YCCUSTO)
			
			MV_PAR09 := U_BIA478G("ZJ0_CLVLDB", MV_PAR06, "P")
					
		EndIf
	
	EndIf

	RestArea(aArea)
	
Return()


Method Clear() Class TParBankMove
	
	MV_PAR07 := ::cHistorico
	MV_PAR08 := ::cCentroCusto
	MV_PAR09 := ::cClasseValor
					
Return()


Method Confirm() Class TParBankMove
	
Return(.T.)


User Function BAF031A(cPar)
Local lRet := .T.
	
	lRet := _Self:Validate(cPar)
	
Return(lRet)