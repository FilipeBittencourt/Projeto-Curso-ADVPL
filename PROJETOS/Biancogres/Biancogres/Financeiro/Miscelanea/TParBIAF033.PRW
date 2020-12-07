#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------|
| Função: | BIAF033																			  	|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 27/04/16																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação de parametros da rotina |
| Desc.:	| BIAF033 																				|
|-----------------------------------------------------------|
| OS:			|	4647-15 - Vagner Amaro													|
|-----------------------------------------------------------|
*/

Class TParBIAF033 From LongClassName

	Data cName
	Data aParam
	
	Data cCNPJ
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Load() // Carrega parametros
	Method Update() // Atualiza variaveis e parametros
	
EndClass


Method New() Class TParBIAF033
	
	::cName := "BIAF033"
	
	::aParam := {}
	
	::Load()
	
	::Add()
	
Return()


Method Add() Class TParBIAF033	
		
	aAdd(::aParam, {1, "CNPJ", ::cCNPJ, "@!","NaoVazio()",,".T.",,.F.})	
		
Return()


Method Box() Class TParBIAF033	
Local lRet := .F.
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Operações",,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
		
		::Load()
		
	EndIf
	
Return(lRet)


Method Load() Class TParBIAF033
Local cFileName := __cUserID +"_"+ ::cName

	::cCNPJ := ParamLoad(cFileName,,1, Space(14))

Return()


Method Update() Class TParBIAF033
	
	::aParam := {}
	
	::Load()
	
	::Add()
	
Return()