#Include 'Protheus.ch'
#Include 'Parmtype.ch'
 

User Function VARIAVEL()

	// As lestras  que começam na frente dos nomes das variaveis servem para mostrar o tipo das mesmas. É uma boa pratica feita pela comunidade.
	
	Local nNumero := 66  // 3  |  21.000  |  0.4  | 20000  
	Local lLogico := .T. // .F. 
	Local nCaracter :=  "Nome" // "D"  |  'C' 
	Local dData :=  DATE()
	Local aArray := {"João","Maria","Pedro"}	 
	Local bBloco := {||;
		 nValor := 2,; 
		 MsgAlert("O número é: "+ cValToChar(nValor));
	}  // cValToChar é uma função que converte um valor para string, para ser exibida quando for CONCATENADO SOMENTE. Caso contrario dará erro.  
	
	
	Alert(nNumero)
	Alert(lLogico)
	Alert(nCaracter) // Sempre que for exibir uma variavel do tipo caracter para o user, sempre usar a função cValToChar
	Alert(dData)
	Alert(aArray[1])	
	Eval(bBloco) //Sempre que for necessario retornar o resultado de um bloco de codigo.
	

Return

