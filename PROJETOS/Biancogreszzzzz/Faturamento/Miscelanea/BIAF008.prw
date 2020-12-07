#INCLUDE "TOTVS.CH"

/* 
|------------------------------------------------------------|
| Função:	| BIAF008																					 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 27/10/14																				 |
|------------------------------------------------------------|
| Desc.:	|	Validação no Pedido de Venda   						   		 |
| 				|	Responsável por executar os gatilhos do campo  	 |
| 				|	produto (C6_PRODUTO) para todos os itens ao    	 |
| 				|	alterar o conteudo dos campos: C5_CONDPAG,  	   |
| 				|	C5_YLINHA, C5_YSUBTP, C5_VLRFRET, C5_YMAXCND, 	 |
| 				|	C5_TABELA.  																		 |
| 				|	Executado via gatilho na função ATU_PEDIDO()		 |
|------------------------------------------------------------|
| OS:			|	0652-14 - Usuário: Elaine Cristina Sales	 			 |
|------------------------------------------------------------|
*/

User Function BIAF008(oGedPedVen)
Local aArea := GetArea()
Local nLine := 0
Local nLineAux := N
	
	For nLine := 1 To Len(aCols)
	
		N := nLine
		
		If ExistTrigger("C6_PRODUTO")
			RunTrigger(2, nLine, Nil,,"C6_PRODUTO")
		EndIf
		
	Next
	
	N := nLineAux
	
	oGedPedVen:ForceRefresh()
	
	RestArea(aArea)
	
Return()