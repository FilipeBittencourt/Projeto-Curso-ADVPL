#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*
|-------------------------------------------------------------|
| Função:	| BIA584										  |
| Autor:	| Luana Marin Ribeiro			   	 	   		  |
| Data:		| 22/06/2016									  |
|-------------------------------------------------------------|
| Desc.:	| Rotina para visualização da quantidade total de |
| 			| metros quadrados					  			  |
| 			| É utilizada na rotina de pedido de vendas e  	  |
| 			| de bloqueio de pedidos. Em ambas a coluna   	  |
| 			| quantidade é a 5.					  			  |
|-------------------------------------------------------------|
| OS:	    | 1621-16 - Usuário: Claudeir Fadini   		 	  |
|-------------------------------------------------------------|
*/

User Function BIA584()
	lOCAL I
	Private OK
	Private oDlgQuant
	Private oSayQuant

	dQuantidade := 0

	For I := 1 To Len(ACOLS)
		dQuantidade += ACOLS[I][5]  //QUANTIDADE
	Next

	DEFINE MSDIALOG oDlgQuant FROM 10,20 TO 150,300 TITLE "Quantidade Total" COLORS 0, 16777215 PIXEL

	@ 020, 040 SAY oSayQuant PROMPT "Quant. Total: " + Transform(dQuantidade,"@E 999,999,999.99") SIZE 100, 007 OF oDlgQuant COLORS 0, 16777215 PIXEL

	@ 50,55 BUTTON OK PROMPT "Sair" SIZE 037, 012  OF oDlgQuant  ACTION (oDlgQuant:End())  PIXEL

	ACTIVATE MSDIALOG oDlgQuant

Return()