#Include 'Protheus.ch'
#Include 'Parmtype.ch'
 
Static cStat := '' 

User Function OPERADOR()
	 
	Local nNum1 := 10
	Local nNum2 := 20	
	
	//OPERADORES  MATEMATICOS	
	//Alert(nNum1 + nNum2)
	//Alert(nNum2 - nNum1) 
	//Alert(nNum1 * nNum2)   
	//Alert(nNum2 / nNum1)
	//Alert(nNum2 % nNum1)
	
    //OPERADORES  RELACIONAIS	
	Alert(nNum1 < nNum2)
	Alert(nNum1 > nNum2) 
	Alert(nNum1 = nNum2)  // COMPARAÇÃO DE IGUALDADE  
	Alert(nNum1 == nNum2) // EXATAMENTE IGUAL, MAS É MAIS USADO PARA COMPARAR CARACTERES
	Alert(nNum1 <= nNum2)
	Alert(nNum1 >= nNum2)
	Alert(nNum1 != nNum2)
	
	//OPERADORES  DE ATRIBUIÇÕES	
	nNum1 := 10    //  ATRIBUIÇÕES SIMPLES
	nNum1 += nNum2 //  nNum1 = nNum1 + nNum2
	nNum2 -= nNum1 //  nNum2 = nNum2 - nNum1
	nNum1 *= nNum2 //  nNum1 = nNum1 * nNum2
	nNum2 /= nNum1 //  nNum2 = nNum2 / nNum1
	nNum2 %= nNum1 //  nNum2 = nNum2 % nNum1
	
//Os operadores utilizados em AdvPl para operações e avaliações lógicas são:
/*

.And.	E lógico
.Or.	OU lógico
.Not.  ou !	NÃO lógico


*/	
		
	
	
Return