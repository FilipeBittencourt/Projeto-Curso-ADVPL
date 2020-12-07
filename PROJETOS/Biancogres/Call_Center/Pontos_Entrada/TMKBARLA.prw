#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TMKBARLA
@author Marcos Alberto Soprani
@since 06/11/2011
@version 1.0
@description Ponto de entrada para inclusão de rotinas barra lateral da tela de Telecobrança.
@type function
/*/

User Function TMKBARLA(aBotao, aTitulo)
	
	aAdd(aBotao, {"POSCLI", {|| U_ATALHOS() }, "Posição de Cliente"})
	aAdd(aBotao, {"BAIXATIT", {|| U_IMP_SK1() }, "Imp.Tit. p/ Cliente"})
	
	// Tiago Rossini Coradini - 25/10/2016 - OS: 3762-16 - Clebes Jose - Inclusão da rotina de Histórico de Tarifas na tela de Telecobrança. 
	aAdd(aBotao, {"BUDGETY", {|| U_BIAF050() }, "Histórico de Tarifas"})

Return(aBotao)