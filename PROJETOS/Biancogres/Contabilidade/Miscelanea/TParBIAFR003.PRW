#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0018; Return()

/*
|-----------------------------------------------------------------|
| Fun��o: | BIAFR003									          |
| Autor:	| Tiago Rossini Coradini - Facile Sistemas		      |
| Data:		| 18/11/14										      |
|-----------------------------------------------------------------|
| Desc.:	| Classe para manipula��o de parametros da rotina     |
| Desc.:	| BIAFR003 										      |
|-----------------------------------------------------------------|
| OS:			|	1747-12 - Usu�rio: Fabiana Aparecida Corona	  |
| OS:			|	1743-14 - Usu�rio: Tania de Fatima Monico	  |
| OS:			|	2138-12 - Usu�rio: Antonio Marcio   	      |
|-----------------------------------------------------------------|
*/

Class TParBIAFR003 From LongClassName

	Data cName
	Data aParam

	Data dDatDe // Data de
	Data dDatAte // Data ate
	Data cPrdDe // Produto de
	Data cPrdAte // Produto ate
	Data cTipOpeFis // Tipo de Opera��o Fiscal
	Data cOrdem // Ordem
	Data cCliFDe // Cli/Forn de
	Data cCliFAte // Cli/Forn ate

	Method New() Constructor
	Method Add() // Adiciona lista de parametros	
	Method Box() // Exibe parametros para filtro
	Method Load() // Carrega parametros
	Method Update() // Atualiza variaveis e parametros

EndClass

Method New() Class TParBIAFR003

	::cName := "BIAFR003"

	::aParam := {}

	::Load()

	::Add()

Return()

Method Add() Class TParBIAFR003	

	aAdd(::aParam, {1, "Emiss�o De", ::dDatDe, "@D",".T.",,".T.",,.F.})	
	aAdd(::aParam, {1, "Emiss�o Ate", ::dDatAte, "@D",".T.",,".T.",,.F.})
	aAdd(::aParam, {1, "Produto De", ::cPrdDe, "@!", ".T.", "SB1", ".T.",,.F.})
	aAdd(::aParam, {1, "Produto Ate", ::cPrdAte, "@!", ".T.", "SB1", ".T.",,.F.})
	aAdd(::aParam, {1, "Tipo Op. Fiscal", ::cTipOpeFis, "@!", "NaoVazio() .And. ExistCPO('Z52')", "Z52", ".T.",,.F.})
	aAdd(::aParam, {2, "Ordena��o", ::cOrdem, {"1 - [Entrada - Sa�da]", "2 - [Sa�da - Entrada]"}, 80, ".T.", .F.})
	aAdd(::aParam, {1, "Cli/Forn De", ::cCliFDe, "@!", ".T.", "SA2", ".T.",,.F.})
	aAdd(::aParam, {1, "Cli/Forn Ate", ::cCliFAte, "@!", ".T.", "SA2", ".T.",,.F.})

Return()

Method Box() Class TParBIAFR003	

	Local lRet := .F.
	Private cCadastro := "Parametros"

	If ParamBox(::aParam, "Opera��es",,,,,,,,::cName, .T., .T.)

		lRet := .T.

		::Load()

	EndIf

Return(lRet)

Method Load() Class TParBIAFR003

	Local cFileName := __cUserID +"_"+ ::cName

	::dDatDe := ParamLoad(cFileName,,1, dDataBase)
	::dDatAte := ParamLoad(cFileName,,2, dDataBase)
	::cPrdDe := ParamLoad(cFileName,,3, Space(15))
	::cPrdAte := ParamLoad(cFileName,,4, Replicate("Z", 15))
	::cTipOpeFis := ParamLoad(cFileName,,5, Space(6))
	::cOrdem := ParamLoad(cFileName,,6, "1 - [Entrada - Sa�da]")
	::cCliFDe := ParamLoad(cFileName,,7, Space(6))
	::cCliFAte := ParamLoad(cFileName,,8, Replicate("Z", 6))

Return()

Method Update() Class TParBIAFR003

	::aParam := {}

	::Load()

	::Add()

Return()
