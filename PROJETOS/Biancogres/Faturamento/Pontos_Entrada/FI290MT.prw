
User Function FI290MT()
Local lMostraTela := .F.
	If MsgYesNo("Deseja exibir tela de Parcelas a serem geradas?","Atenção") 
		lMostraTela := .T. 
	Else 
		lMostraTela := .F. 
	EndIf
Return lMostraTela