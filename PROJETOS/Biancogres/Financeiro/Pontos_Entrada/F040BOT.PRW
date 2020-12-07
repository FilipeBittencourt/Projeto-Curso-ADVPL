#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F040BOT
@author Tiago Rossini Coradini
@since 25/10/2016
@version 1.0
@description Ponto de entrada para inclusão de rotinas no menu do Contas a Receber. 
@type function
/*/

User Function F040BOT()
Local aBotao := {}
	
	aBotao := {{"BUDGETY", {|| U_BIAF051() }, "Histórico de Tarifas"}}

Return(aBotao)