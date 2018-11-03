#Include 'Protheus.ch'
#Include 'Parmtype.ch'
 
Static cStat := '' 

User Function ESTRUTUR()
	 
	/*
	Local nNum1 := 22
	Local nNum2 := 50	
	
	If(nNum1 = nNum2)
		MsgInfo("A variavel nNum1 é igual a nNum2")
	ElseIf(nNum1 > nNum2)
		MsgInfo("A variavel nNum1 é manior que nNum2")
	ElseIf(nNum1 != nNum2)
		MsgInfo("A variavel nNum1 é diferente de nNum2")
	Else
		Alert("A variavel nNum1 não é igual ou menor a nNum2")
	EndIf
	*/
	
	//DO CASE
	/*
	Local cDate := "20/12/2017"
	Local cTime := TIME()
	
	Do Case
	
		Case cDate == "24/12/2017"
		Alert("Não é natal "+ cData)
		
		Case cDate == "25/12/2017"
		Alert("É natal")
		
		OtherWise
		Alert("Data de Hoje: "+ cValToChar(DATE()) +" "+ cValToChar(TIME()))
		
	EndCase
	*/
	
	//FOR
	
	/*	 
	  Local nCount
	  Local nNum := 0 
	  
	  For nCount := 0 To 10    // For nCount := 0 To 10 Step 2 --> O STEP pula os numeros como desejar, nesse caso ele vai pular de 2 em 2 
	  	nNum += nCount
	  Next
	
	 Alert("Valor "+ cValToChar(nNum))
	 */
	 
	 
	 
	 //WHILE
	 
	Local nNum1 := 1
	Local nNum2 := 10	
	Local cNome := "Filipe" 
	  
	 //While nNum1 < nNum2
	 //	nNum1++ 
	 //EndDo
	 //Alert(nNum1 + nNum2)
	 
	 
	MsgAlert("Incio do Numero "+ cValToChar(nNum1)+" e o nome inicial é: "+ cValToChar(cNome))
	While nNum1 != 10 .AND. cNome != "Giovani"
		nNum1++ 
	 	If(nNum1 = 5)
	 		cNome := "Giovani"	 			 		
	 	EndIF	 	
	 EndDo	 
	 Alert("Numero mudou para "+ cValToChar(nNum1)+" e o nome agora é: "+ cValToChar(cNome))		
	
Return