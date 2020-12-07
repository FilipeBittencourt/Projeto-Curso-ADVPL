#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAFR010
@author Tiago Rossini Coradini
@since 09/02/2017
@version 1.0
@description Classe para manipulação de parametros da rotina BIAFR010 
@obs OS: 4752-16 - Clebes Jose
@type Class
/*/

Class TParBIAFR010 From LongClassName

	Data cName
	Data aParam
	
	Data dDatDe // Data de
	Data dDatAte // Data ate
	Data cCliDe // Cliente de
	Data cCliAte // Cliente ate
	Data cVenDe // Vendedor de
	Data cVenAte // Vendedor ate
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Update() // Atualiza variaveis e parametros	
	
EndClass


Method New() Class TParBIAFR010
	
	::cName := "BIAFR010"
	
	::aParam := {}
	
	::dDatDe := dDataBase
	::dDatAte := dDataBase
	::cCliDe := Space(6)
	::cCliAte := Replicate("Z", 6)
	::cVenDe := Space(6)
	::cVenAte := Replicate("Z", 6)	
	
	::Add()		
	
Return()


Method Add() Class TParBIAFR010
		
	aAdd(::aParam, {1, "Data De", ::dDatDe, "@D",".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Data Ate", ::dDatAte, "@D",".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Cliente De", ::cCliDe, "@!", ".T.", "SA1", ".T.",,.F.})
	aAdd(::aParam, {1, "Cliente Ate", ::cCliAte, "@!", ".T.", "SA1", ".T.",,.F.})
	aAdd(::aParam, {1, "Vendedor De", ::cVenDe, "@!", ".T.", "SA3", ".T.",,.F.})
	aAdd(::aParam, {1, "Vendedor Ate", ::cVenAte, "@!", ".T.", "SA3", ".T.",,.F.})
		
Return()


Method Box() Class TParBIAFR010
Local lRet := .F.
Local aRet := {}
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Operações", aRet,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::dDatDe := aRet[1]
		::dDatAte := aRet[2]
		::cCliDe := aRet[3]
		::cCliAte := aRet[4]
		::cVenDe := aRet[5]
		::cVenAte := aRet[6]		
		
	EndIf
	
Return(lRet)


Method Update() Class TParBIAFR010
	
	::aParam := {}	
	
	::Add()
	
Return()