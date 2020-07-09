#Include 'Protheus.ch'
#Include 'Parmtype.ch'


User Function AVETOR2()
		/**
	AADD() - PERMITE A INSER��O DE UM ITEM EM UM ARRAY JA EXISTENTE
	AINS() - PERMITE A INSER��O DE UM ELEMENTO EM QUALQUER POSI��O DO ARRAY
	ACLONE() - REALIZA A COPIA DE UM ARRAY PARA OUTRO
	ADEL() - REALIZA A EXCLUS�O DE UM ELEMENTO DO ARRAY, TORNANDO O ULTIMO VALOR NULL
	ASIZE() - REDEFINE A ESTRUTURA DE UM ARRAY PR-E-EXISTENTE, ADICIONANDO OU REMOVENDO
	LEN() - RETORNA A QUANTIDADE DE ELEMENTOS DE UM ARRAY
  LOCAL aVetor := { “Java”, “AdvPL”, “C++” } 
  LOCAL nPos   := ASCAN(aVetor, “AdvPL” } // Resulta: 2
MSGALERT( ASCAN(aArray, { |x| UPPER(x) == "“AdvPL”" }) )    // Resulta: 2
aRespI[aScan( aRespI, { |x| x[3] == 'msg erro' } ),3]

  aScan( aNFVinc[1], { |x| x[1] == 'LOJTRAN' } )
  aNFVinc[1,aScan( aNFVinc[1], { |x| x[1] == 'LOJTRAN' } ),2]
	**/
	
	Local aVetor := {10,20,30}
  Local aRespI := {}
  Local aRespI := {}
  Local aNFVinc := {}
 
  Local cMsg	:= "DOCUMENTO DE ENTRADA DO FRETE COM SUCESSO"
  aRespII := {{.T.,"OK",Nil},{.F.,"ERRO",Nil}}
  AADD(aRespI,{.T.,"ERRO","01"})   
  AADD(aRespI,{.F.,"ERRO","msg erro"})  

 	 aAdd(aNFVinc,{{'NFDIFRE' , "A"},;
    {'SEDIFRE' , "B"},;
    {'DTDIGIT' , "C"},;
    {'TRANSP'  , "D"},;
    {'LOJTRAN' , "E"};
  })        
  //aScan( aNFVinc[1], { |x| x[1] == 'LOJTRAN' } )
  //aNFVinc[1,aScan( aNFVinc[1], { |x| x[1] == 'LOJTRAN' } ),2]

  ConOut("OK")
  

 

  
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
 	 
 	 
 	ASIZE(aVetor, 2) // ELE PEGA O INDICE QUE PARA ESSA FUN��O COME�A COM ZERO 0 , 1 , 2
	Alert(Len(aVetor))
  FOR nCount := 1 To LEN(aVetor)	  // PARA PERCORRER O ARRAY COM FOR/WHILE COME�A COM NUMERO 1, SE COLOCAR ZERO DA ERRO.
		Alert(aVetor[nCount]) 
  NEXT nCount
	 
	 
	 
	 
	 
	 
Return

