#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0025; Return()

/*
|-----------------------------------------------------------|
| Função: | BIAFR007																			  |
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 25/03/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação de parametros da rotina |
| Desc.:	| BIAFR007 																				|
|-----------------------------------------------------------|
| OS:			|	1806-13 - Usuário: Vagner Salles								|
|-----------------------------------------------------------|
*/

Class TParBIAFR007 From LongClassName

	Data cName
	Data aParam
	
	Data cCodVen // código do vendedor
	Data dDatDe // Data de
	Data dDatAte // Data ate
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Load() // Carrega parametros
	Method Update() // Atualiza variaveis e parametros
	
EndClass


Method New() Class TParBIAFR007
	
	::cName := "BIAFR007"
	
	::aParam := {}
	
	::Load()
	
	::Add()
	
Return()


Method Add() Class TParBIAFR007	
		
	aAdd(::aParam, {1, "Vendedor", ::cCodVen, "@!", "NaoVazio() .And. ExistCPO('SA3')", "SA3", ".T.",,.F.})	
	aAdd(::aParam, {1, "Emissão De", ::dDatDe, "@D",".T.",,".T.",,.F.})	
	aAdd(::aParam, {1, "Emissão Ate", ::dDatAte, "@D",".T.",,".T.",,.F.})
		
Return()


Method Box() Class TParBIAFR007
Local lRet := .F.
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Relatório",,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
		
		::Load()
		
	EndIf
	
Return(lRet)


Method Load() Class TParBIAFR007
Local cFileName := __cUserID +"_"+ ::cName

	::cCodVen := ParamLoad(cFileName,,1, Space(6))
	::dDatDe := ParamLoad(cFileName,,2, dDataBase)
	::dDatAte := ParamLoad(cFileName,,3, dDataBase)

Return()


Method Update() Class TParBIAFR007
	
	::aParam := {}
	
	::Load()
	
	::Add()
	
Return()