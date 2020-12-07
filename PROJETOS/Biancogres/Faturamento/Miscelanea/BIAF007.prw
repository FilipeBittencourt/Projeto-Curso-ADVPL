#INCLUDE "TOTVS.CH"

/*
|------------------------------------------------------------|
| Função:	| BIAF007																					 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 27/10/14																				 |
|------------------------------------------------------------|
| Desc.:	|	Aprovação do Orçamento de Venda   						   |
| 				|	Responsável por executar os gatilhos do campo  	 |
| 				|	produto (C6_PRODUTO) ao aprovar um orçamento     |
|------------------------------------------------------------|
| OS:			|	0652-14 - Usuário: Elaine Cristina Sales	 			 |
|------------------------------------------------------------|
*/

User Function BIAF007(aHeaderSC6, aColsSC6, nLine)
Local aArea := GetArea()
Private aHeader	:= aHeaderSC6
Private aCols := aColsSC6
Private N := nLine

	If ExistTrigger("C6_PRODUTO")
		RunTrigger(2, nLine, Nil,,"C6_PRODUTO")
	EndIf

	RestArea(aArea)
	
Return()