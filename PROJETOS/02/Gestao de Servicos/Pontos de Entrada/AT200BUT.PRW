/*
Descrição:
Inclusão de Botões. 
O ponto é chamado no momento da definição dos botões padrão do orçamento. Para adicionar mais de um botão adicionar mais subarrays ao array.
*/

User Function AT200BUT()
Local aBotao := {} 

	aAdd( aBotao, { "PRODUTO", { || U_CONTGOS() }, "Gerar OS" } ) 
	If ALTERA
		aAdd( aBotao, { "Alterar Número", { || U_FCACRT01() }, "Alterar Número" } )
	Endif
	 
Return (aBotao)