#INCLUDE "PROTHEUS.CH"

/*
##############################################################################################################
# PROGRAMA...: Mt410Ace         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 14/07/2014
# DESCRICAO..: P.E. ROTINA MATA410, PERMITINDO OU NAO ALTERACAO DO PEDIDO
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function Mt410Ace()

Local lContinua := .T.  
Local nOpc  := PARAMIXB [1]

//nOpc == 1 // excluir    
//nOpc == 4 // Alterar        
//nOpc == 2// visualizar ou residuo

//Tratamento especial para Replicacao de reajuste de preço
If (IsInCallStack("U_M410RPRC")) .OR. (AllTrim(FunName()) == "RPC")
	Return(.T.)
EndIf

If nOpc == 4 .Or. nOpc == 1

	If !Empty(cRepAtu) .And. U_GETBIAPAR("REP_BLQPED",.F.)
		MsgInfo("Inclusão de pedidos temporariamente bloqueada pelo departamento comercial","MT410ACE")
		Return .F.
	EndIf
	
	__lRep := Type("CREPATU") <> "U" .And. !Empty(CREPATU)
	If (__lRep)
		DbSelectArea('SA3')
		SA3->(DbSetOrder(1))
		If SA3->(DbSeek(XFilial("SA3")+CREPATU))
			If (SA3->A3_YBLQPED == 'S')
				MsgInfo("Inclusão de pedidos temporariamente bloqueada pelo departamento comercial","MT410ACE")
				Return .F.
			EndIf
		EndIf		
	EndIf

EndIf

//Pedido Encerrado
If (!Empty(SC5->C5_NOTA).Or.SC5->C5_LIBEROK=='E' .And. Empty(SC5->C5_BLQ))		   	
	lContinua := .T.                                                            
	//lContinua := .F.                                                            
	//MsgStop("Pedido Finalizado. Manutenção Não Permitida!","MT410ACE")
Else             	
	IF nOpc == 4    //ALTERACAO
	
		//If (Alltrim(SC5->C5_YCONF) == 'S')
		//	MsgStop("Pedido Já Conferido. Manutenção Não Permitida!","MT410ACE")
		//	lContinua := .F. 
		//EndIf
		
		// Tiago Rossini Coradini - 26/09/2016 - OS: 3239-16 - Ranisses Corona - Adiciona controle para validar se ocorreu erro na gravacao do pedido 
		If Empty(SC5->C5_YHORA)
		
			MsgStop("Atenção, ocorreu um erro na gravação deste pedido, o mesmo deverá ser excluído e adicionado novamente.")
			
			Return(.F.)
			
		EndIf
		
		// Tiago Rossini Coradini - 26/09/2016 - OS: 3239-16 - Ranisses Corona - Adiciona controle de semaforo
		If !MayIUseCode("SC5" + cEmpAnt + cFilAnt + SC5->C5_NUM)
			
			MsgAlert("Rotina está sendo executada por outro usuário.")
	
			Return(.F.)
				
		EndIf
		
		//Tratamento outros tipos de pedido
		If SC5->C5_TIPO <> "N"
			lContinua := .T.
		Else
		
			If !Empty(cRepAtu) 

				MsgStop("Acesso de REPRESENTANTE. Manutenção em pedidos não permitida!","MT410ACE")
				lContinua := .F. 			
			
			EndIf
		
		EndIf
	
	EndIf   
	
EndIf	         

Return(lContinua)
