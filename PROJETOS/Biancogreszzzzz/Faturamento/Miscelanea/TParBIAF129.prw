#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAF129
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automação Financeira
@version 1.0
@description Classe para manipulação de parametros da rotina BIAF129
@type function
/*/

Class TParBIAF129 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm

	Data dPagto // Data de pagamento
	Data nIR // Aliquota IR
	Data cVendDe // Vendedor de 
	Data cVendAte // Vendedor Ate
	Data dLimNF // Data limite NF
			
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()	
	
EndClass


Method New() Class TParBIAF129
	
	::cName := cEmpAnt + "_" + GetClassName(Self)
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}

	::dPagto := dDataBase
	::nIR := 1.5
	::cVendDe := Space(TamSx3("A3_COD")[1])
	::cVendAte :=  Replicate("Z", TamSx3("A3_COD")[1])
	::dLimNF := dDataBase

	::Add()
	
Return()


Method Add() Class TParBIAF129
		
	aAdd(::aParam, {1, "Data Pagamento", ::dPagto, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "AlÍquota IR", ::nIR, X3Picture("E3_PORC"), ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Representante de", ::cVendDe, X3Picture("A3_COD"), ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Representante ate", ::cVendAte, X3Picture("A3_COD"), ".T.",,".T.",,.F.})	
	aAdd(::aParam, {1, "Data Limite NF", ::dLimNF, "@D", ".T.",,".T.",,.F.})
  
Return()


Method Box() Class TParBIAF129
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.

		::dPagto := ::aParRet[1]
		::nIR := ::aParRet[2]
		::cVendDe := ::aParRet[3]
		::cVendAte := ::aParRet[4]
		::dLimNF := ::aParRet[5]
	
	EndIf
	
Return(lRet)


Method Update() Class TParBIAF129
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBIAF129
	
Return(.T.)