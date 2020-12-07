#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TParBIAFR013
@author Tiago Rossini Coradini
@since 09/03/2018
@version 1.0
@description Classe para manipulação de parametros da rotina BIAFR013 
@obs Ticket: 2049
@type Class
/*/

Class TParBIAFR013 From LongClassName

	Data cName
	Data aParam
	
	Data dDatDe // Data de 
	Data dDatAte // Data de
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Update() // Atualiza variaveis e parametros	
	
EndClass


Method New() Class TParBIAFR013
	
	::cName := "BIAFR013"
	
	::aParam := {}
	
	::dDatDe := FirstYDate(dDataBase)	
	::dDatAte := LastYDate(dDataBase)

	::Add()		
	
Return()


Method Add() Class TParBIAFR013
		
	aAdd(::aParam, {1, "Período do Exame De", ::dDatDe, "@D", ".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Período do Exame Ate", ::dDatAte, "@D", ".T.",,".T.",,.F.})
	
Return()


Method Box() Class TParBIAFR013
Local lRet := .F.
Local aRet := {}
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Operações", aRet,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
			
		::dDatDe := aRet[1]
		::dDatAte := aRet[2]

	EndIf
	
Return(lRet)


Method Update() Class TParBIAFR013
	
	::aParam := {}	
	
	::Add()
	
Return()