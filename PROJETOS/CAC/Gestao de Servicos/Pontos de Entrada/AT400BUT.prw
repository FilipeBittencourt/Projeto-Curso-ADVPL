/*
Descrição:
Inclusão de Botões. 
O ponto é chamado no momento da definição dos botões padrão do orçamento. Para adicionar mais de um botão adicionar mais subarrays ao array.
*/

User Function AT400BUT()
Local aBotao := {} 

	aAdd( aBotao, { "PRODUTO", { || U_FWordR01() }, "Imp. Prop. Serv - ATLAS" } )  
	aAdd( aBotao, { "PRODUTO", { || U_FWordR0B() }, "Imp. Prop. Serv - WEG" } ) 
	aAdd( aBotao, { "PRODUTO", { || U_FWordR0C() }, "Imp. Prop. Peças- ATLAS" } ) 
	aAdd( aBotao, { "PRODUTO", { || U_FWordR0D() }, "Imp. Prop. Peças- WEG" } ) 	
   //	aAdd( aBotao, { "PRODUTO", { || U_FWordR03() }, "Imp. Prop. Serv - WEG" } ) 
  //	aAdd( aBotao, { "PRODUTO", { || U_FWordR04() }, "Imp. Prop. Peças- WEG" } ) 	

Return (aBotao)