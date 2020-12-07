#INCLUDE "TOTVS.CH"

/*
|------------------------------------------------------------|
| Função:	| MA150BUT																				 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 10/09/14																				 |
|------------------------------------------------------------|
| Desc.:	|	Adiciona botao na rotina de Atualiza de Cotação  |
|------------------------------------------------------------|
| OS:			|	1818-14 - Usuário: Claudia Carvalho   		 			 |
|------------------------------------------------------------|
*/


User Function MA150BUT()
Local aButton := {}
	
	aAdd(aButton, {"EDITABLE", {|| U_BIAF002("MATA150") }, "Hist. Preço"})
	aAdd(aButton, {"EDITABLE", {|| U_NOME_SOL() }, "Nome Solicitante"})
	
Return(aButton)