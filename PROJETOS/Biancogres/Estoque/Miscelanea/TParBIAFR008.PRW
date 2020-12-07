#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0022; Return()

/*
|-----------------------------------------------------------|
| Função: | BIAFR008																			  |
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 07/07/15																			  |
|-----------------------------------------------------------|
| Desc.:	| Classe para manipulação de parametros da rotina |
| Desc.:	| BIAFR008 																				|
|-----------------------------------------------------------|
| OS:			|	XXXX-XX - Usuário: Wanisay William   		 			  |
|-----------------------------------------------------------|
*/

Class TParBIAFR008 From LongClassName

	Data cName
	Data aParam
	
	Data dDatDe // Data de
	Data dDatAte // Data ate
	Data cProd // Produto de
		
	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Load() // Carrega parametros
	Method Update() // Atualiza variaveis e parametros
	
EndClass


Method New() Class TParBIAFR008
	
	::cName := "BIAFR008"
	
	::aParam := {}
	
	::Load()
	
	::Add()
	
Return()


Method Add() Class TParBIAFR008	
		
	aAdd(::aParam, {1, "Data De", ::dDatDe, "@D",".T.",,".T.",,.F.})	
	aAdd(::aParam, {1, "Data Ate", ::dDatAte, "@D",".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Produto De", ::cProd, "@!", ".T.", "SB1", ".T.",,.F.})
			
Return()


Method Box() Class TParBIAFR008	
Local lRet := .F.
Private cCadastro := "Parametros"
	
	If ParamBox(::aParam, "Movimentação MP",,,,,,,,::cName, .T., .T.)
		
		lRet := .T.
		
		::Load()
		
	EndIf
	
Return(lRet)


Method Load() Class TParBIAFR008
Local cFileName := __cUserID +"_"+ ::cName

	::dDatDe := ParamLoad(cFileName,,1, dDataBase)
	::dDatAte := ParamLoad(cFileName,,2, dDataBase)
	::cProd := ParamLoad(cFileName,,3, Space(15))

Return()


Method Update() Class TParBIAFR008
	
	::aParam := {}
	
	::Load()
	
	::Add()
	
Return()