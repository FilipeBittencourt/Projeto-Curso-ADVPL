User Function AT450BUT()
Local aBotao := {} 

	aAdd( aBotao, { "PRODUTO", { || U_FImOrdSe() }, "OS CAC ATL" } ) 
   // 	aAdd( aBotao, { "PRODUTO", { || U_FImOrdWg() }, "OS CAC WEG" } )  
	aAdd( aBotao, { "PRODUTO", { || U_FImOrdWG() }, "OS CAC WEG" } ) 
  	
Return (aBotao)