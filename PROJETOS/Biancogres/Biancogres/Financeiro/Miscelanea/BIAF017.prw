#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|------------------------------------------------------------|
| Função:	| BIAF017																					 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 13/05/15																				 |
|------------------------------------------------------------|
| Desc.:	|	Rotina de inclusao de titulos provisorios  			 |
| 				|	referente ao recebimento antecipado via pedido	 |
|------------------------------------------------------------|
| OS:			|	1307-15 e 1308-15 - Usuário: Vagner Salles			 |
|------------------------------------------------------------|
*/

User Function BIAF017(cNumPed)
Local oRecAnt := TRecebimentoAntecipado():New()

	oRecAnt:cNumPed := cNumPed
	
	// Inclui titulo provisorio
	oRecAnt:IncluirPr()

Return()