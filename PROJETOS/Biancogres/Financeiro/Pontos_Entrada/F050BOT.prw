#Include "TOTVS.CH"

/*/{Protheus.doc} F050BOT
@author Tiago Rossini Coradini
@since 05/11/15   
@project Financeiro
@version 1.0
@description Adiciona botoes na rotina Consulta de Titulos a Pagar
@history 05/11/2015, Tiago Rossini Coradini, 2393-15 - Mikaelly Gentil
@history 25/05/2021, Ranisses A. Corona, Projeto FIDC - Adicionado funcao de Rastraamento
@type function
/*/ 

User Function F050BOT()
Local aBotao := {}
	
	AADD(aBotao, {"BUDGETY",  {|| U_FINR710A() }, "Bordero"}) 
	AADD(aBotao, {"HISTORIC", {|| Fin250Pag(2) }, "Rastreamento" }) //"Rastreamento"

Return(aBotao)
