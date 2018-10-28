#Include 'Protheus.ch'
#Include 'Parmtype.ch'
 
Static cStat := '' 

User Function ESCOPO()
 
	// VARIAVEIS LOCAIS 
	Local nVar0 := 1
	Local nVar1 := 20
	  
	// VARIAVEIS Private 
	Private cPri := 'private' 	 
	
 	// VARIAVEIS public 
	Public __cPublic := 'RCTI' 	
	
	TesteEscopo(nVar0, @nVar1) // O @ na frente da variavel quer dizer: Fazer a referencia

Return




Static Function TesteEscopo(nValor1, nValor2)
	
	Local __cPublic := 'Alterei'
	Default nValor1 := 0
	
	//Alterando o valor da variavel
	nValor2 := 10
	
	//Mostra conteudo da variavel private
	alert("Private: "+ cPri)
	
		//Mostra conteudo da variavel private
	alert("Publica: "+ __cPublic)
	
	MsgAlert(nValor2)
	Alert("Variavel Static: "+ cStat)
	
Return
