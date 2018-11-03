#Include 'Protheus.ch'
#Include 'Parmtype.ch'
 

User Function AVETOR2()
	/**
	AADD() - PERMITE A INSERÇÃO DE UM ITEM EM UM ARRAY JA EXISTENTE
	AINS() - PERMITE A INSERÇÃO DE UM ELEMENTO EM QUALQUER POSIÇÃO DO ARRAY
	ACLONE() - REALIZA A COPIA DE UM ARRAY PARA OUTRO
	ADEL() - REALIZA A EXCLUSÃO DE UM ELEMENTO DO ARRAY, TORNANDO O ULTIMO VALOR NULL
	ASIZE() - REDEFINE A ESTRUTURA DE UM ARRAY PR-E-EXISTENTE, ADICIONANDO OU REMOVENDO
	LEN() - RETORNA A QUANTIDADE DE ELEMENTOS DE UM ARRAY
	**/
	
	Local aVetor := {10,20,30}
	
	//Local aVetor2 := {100,200,300, aVetor}
	
	
	//AADD(aVetor, 40)
	//Alert(Len(aVetor2))
	//Alert(aVetor2[4][1])
	
		 
	 //AINS(aVetor,2)
	 //aVetor[2] := 200
	 //Alert(aVetor[2])	 
	 //Alert(Len(aVetor))	 
	 
	 
	 //ACLONE 
	//Local aVetor2 :=  //ACLONE(aVetor)
	//FOR nCount := 1 To LEN(aVetor) 	
	//AADD(aVetor2,aVetor[nCount]) 
	//Alert(aVetor2[nCount])
	//NEXT nCount
	
	
	 //ADEL(aVetor,1)
	 //ALert(aVetor[1])	 
	 //ALert(aVetor[2])	 	 
	 //ALert(aVetor[3])	 
	 //Alert(Len(aVetor))
 	 
 	 
 	ASIZE(aVetor, 2) // ELE PEGA O INDICE QUE PARA ESSA FUNÇÃO COMEÇA COM ZERO 0 , 1 , 2
	Alert(Len(aVetor))
	FOR nCount := 1 To LEN(aVetor)	  // PARA PERCORRER O ARRAY COM FOR/WHILE COMEÇA COM NUMERO 1, SE COLOCAR ZERO DA ERRO.
		Alert(aVetor[nCount]) 
	NEXT nCount
	 
	 
	 
	 
	 
	 
Return

