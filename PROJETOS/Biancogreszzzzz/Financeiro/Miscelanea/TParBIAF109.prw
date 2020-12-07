#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAF109
@author Tiago Rossini Coradini
@since 17/05/2018
@version 1.0
@description Classe para manipulação de parametros da rotina BIAF109 
Ticket: 4511
@type Class
/*/

Class TParBIAF109 From LongClassName

	Data cName
	Data aParam
	
	Data dDatDe // Data de 
	Data dDatAte // Data de
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Update() // Atualiza variaveis e parametros	
	
EndClass


Method New() Class TParBIAF109
	
	::cName := "BIAF109"
	
	::aParam := {}
	
	::dDatDe := dDataBase
	::dDatAte := dDataBase

	::Add()		
	
Return()


Method Add() Class TParBIAF109
		
	aAdd(::aParam, {1, "Data Process. De", ::dDatDe, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Data Process. Ate", ::dDatAte, "@D", ".T.",,".T.",,.F.})
	
Return()


Method Box() Class TParBIAF109
Local lRet := .F.
Local aRet := {}
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Operações", aRet,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::dDatDe := aRet[1]
		::dDatAte := aRet[2]

	EndIf
	
Return(lRet)


Method Update() Class TParBIAF109
	
	::aParam := {}	
	
	::Add()
	
Return()