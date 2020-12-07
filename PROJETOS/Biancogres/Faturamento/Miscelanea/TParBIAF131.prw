#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAF131
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automação Financeira
@version 1.0
@description Classe para manipulação de parametros da rotina BIAF131
@type function
/*/

Class TParBIAF131 From LongClassName

	Data cName
	Data aParam
	Data aParRet
	Data bConfirm

	Data cVendDe // Vendedor de 
	Data cVendAte // Vendedor Ate
			
	Method New() Constructor
	Method Add()
	Method Box()
	Method Update()
	Method Confirm()	
	
EndClass


Method New() Class TParBIAF131
	
	::cName := cEmpAnt + "_" + GetClassName(Self)	
	
	::aParam := {}
	::aParRet := {}
	::bConfirm := {|| .T.}

	::cVendDe := Space(TamSx3("A3_COD")[1])
	::cVendAte := Replicate("Z", TamSx3("A3_COD")[1])

	::Add()
	
Return()


Method Add() Class TParBIAF131
		
	aAdd(::aParam, {1, "Representante de", ::cVendDe, X3Picture("A3_COD"), ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Representante ate", ::cVendAte, X3Picture("A3_COD"), ".T.",,".T.",,.F.})
  
Return()


Method Box() Class TParBIAF131
Local lRet := .F.
Private cCadastro := "Parametros"
	
	::bConfirm := {|| ::Confirm() }
	
	If ParamBox(::aParam, "Operações", ::aParRet, ::bConfirm,,,,,,::cName, .T., .T.)
		
		lRet := .T.

		::cVendDe := ::aParRet[1]
		::cVendAte := ::aParRet[2]
	
	EndIf
	
Return(lRet)


Method Update() Class TParBIAF131
	
	::aParam := {}	
	
	::Add()
	
Return()


Method Confirm() Class TParBIAF131
	
Return(.T.)