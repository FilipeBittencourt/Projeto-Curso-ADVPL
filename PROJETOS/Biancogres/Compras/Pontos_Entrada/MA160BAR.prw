#INCLUDE "TOTVS.CH"

/*
|------------------------------------------------------------|
| Função:	| MA160BAR																				 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 10/09/14																				 |
|------------------------------------------------------------|
| Desc.:	|	Adiciona botao na rotina de Analise de Cotação   |
|------------------------------------------------------------|
| OS:			|	1818-14 - Usuário: Claudia Carvalho   		 			 |
|------------------------------------------------------------|
*/


User Function MA160BAR()
Local aButton := {}
	
	aAdd(aButton, {"EDITABLE", {|| U_BIAF002("MATA161")}, "Hist. Preço"})
	
Return(aButton)
