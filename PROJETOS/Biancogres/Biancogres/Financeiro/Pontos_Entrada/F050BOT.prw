#Include "TOTVS.CH"

/*
|-----------------------------------------------------------|
| Funcao: | F050BOT																    			|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 05/11/15																			  |
|-----------------------------------------------------------|
| Desc.:	|	Ponto de entrada para adicionar botoes na rotina|
| 				|	consulta de titulos a pagar											|
|-----------------------------------------------------------|
| OS:			|	2393-15 - Mikaelly Gentil												|
|-----------------------------------------------------------|
*/

User Function F050BOT()
Local aBotao := {}
	
	aBotao := {{"BUDGETY", {|| U_FINR710A() }, "Bordero"}}

Return(aBotao)