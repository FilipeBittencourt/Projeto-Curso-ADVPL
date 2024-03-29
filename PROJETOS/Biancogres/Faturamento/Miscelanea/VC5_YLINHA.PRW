#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} VC5_YLINHA
@author Fernando Rocha
@since 03/10/2014
@version 1.0
@description Validar campo Linha do Pedido - Projeto Reserva de OP
@type function
/*/

User Function VC5_YLINHA   

Local _lRet := .T. 

//1=Biancogres;2=Incesa;3=Bellacasa;4=Mundialli

If Type("CREPATU")<>"U" .And. !Empty(CREPATU)
    
	SA3->(DbSetOrder(1))
	If SA3->(DbSeek(XFilial("SA3")+CREPATU))
	
	    If M->C5_YLINHA == "1" .And. !("0101" $ SA3->A3_YEMP)
	    	_lRet := .F.
	    ElseIf M->C5_YLINHA == "2" .And. !("0501" $ SA3->A3_YEMP)	                                                  
	    	_lRet := .F.
	    ElseIf M->C5_YLINHA == "3" .And. !("0599" $ SA3->A3_YEMP)	                                                  
	    	_lRet := .F.
	    ElseIf M->C5_YLINHA == "4" .And. !("1399" $ SA3->A3_YEMP)	                                                  
	    	_lRet := .F.
	    ElseIf M->C5_YLINHA == "5" .And. !("0199" $ SA3->A3_YEMP)	                                                  
	    	_lRet := .F.
	    ElseIf M->C5_YLINHA == "6" .And. !("1302" $ SA3->A3_YEMP)	                                                  
	    	_lRet := .F.	
	    EndIf

		If !_lRet
			MsgAlert("Empresa/Linha n�o permitida para o REPRESENTANTE.","Empresa do Pedido")
		EndIf

		//Ticket 32120, solicita��o da Paloma
		If _lRet .And. M->C5_YLINHA == "6" .And. !cEmpAnt $ "07_14" 
			MsgAlert("Pedidos Vin�lico s� podem ser feitos pela 07-LM Com�rcio ou 14-Biancogres Vinilico.","Empresa do Pedido")
			_lRet := .F.
		Endif
	EndIf

EndIf

Return(_lRet)
