#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0028; Return()

/*
|-----------------------------------------------------------|
| Classe: | TParBIAFR004																		|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 18/11/14																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação de parametros da rotina |
| Desc.:	| BIAFR004 																				|
|-----------------------------------------------------------|
| OS:			|	0384-14 - Usuário: Francine Araujo							|
|-----------------------------------------------------------|
*/

Class TParBIAFR004 From LongClassName

	Data cName
	Data aParam
	
	Data cMatDe // Matricula de
	Data cMatAte // Matricula ate
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Load() // Carrega parametros
	Method Update() // Atualiza variaveis e parametros
	
EndClass


Method New() Class TParBIAFR004
	
	::cName := "BIAFR004"
	
	::aParam := {}
	
	::Load()
	
	::Add()
	
Return()


Method Add() Class TParBIAFR004	
		
	aAdd(::aParam, {1, "Matricula De", ::cMatDe, "@!", ".T.", "SRA", ".T.",,.F.})
	aAdd(::aParam, {1, "Matricula Ate", ::cMatAte, "@!", ".T.", "SRA", ".T.",,.F.})
			
Return()


Method Box() Class TParBIAFR004
Local lRet := .F.
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Funcionários",,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
		
		::Load()
		
	EndIf
	
Return(lRet)


Method Load() Class TParBIAFR004
Local cFileName := __cUserID +"_"+ ::cName

	::cMatDe := ParamLoad(cFileName,,1, Space(6))
	::cMatAte := ParamLoad(cFileName,,2, Replicate("Z", 6))

Return()


Method Update() Class TParBIAFR004
	
	::aParam := {}
	
	::Load()
	
	::Add()
	
Return()