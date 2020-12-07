#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0021; Return()

/*
|-----------------------------------------------------------|
| Classe: | TParBIAF016																			|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 25/03/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação de parametros da rotina |
| Desc.:	| BIAF016 																				|
|-----------------------------------------------------------|
| OS:			|	1806-13 - Usuário: Vagner Salles								|
|-----------------------------------------------------------|
*/

Class TParBIAF016 From LongClassName

	Data cName
	Data aParam
	
	Data dData
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Load() // Carrega parametros
	Method Update() // Atualiza variaveis e parametros
	
EndClass


Method New() Class TParBIAF016
	
	::cName := "BIAF016"
	
	::aParam := {}
	
	::Load()
	
	::Add()
	
Return()


Method Add() Class TParBIAF016	
		
	aAdd(::aParam, {1, "Período", ::dData, "@D",".T.",,".T.",,.F.})
		
Return()


Method Box() Class TParBIAF016
Local lRet := .F.
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Consumo Produto Comum",,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
		
		::Load()
		
	EndIf
	
Return(lRet)


Method Load() Class TParBIAF016
Local cFileName := __cUserID +"_"+ ::cName

	::dData := ParamLoad(cFileName,,1, dDataBase)

Return()


Method Update() Class TParBIAF016
	
	::aParam := {}
	
	::Load()
	
	::Add()
	
Return()