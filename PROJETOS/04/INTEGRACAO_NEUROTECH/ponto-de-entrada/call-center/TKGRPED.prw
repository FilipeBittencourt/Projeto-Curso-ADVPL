#INCLUDE "rwmake.ch"   
#INCLUDE "TOPCONN.ch"

/*
@Title   : Ponto de entrada para validar o pedido de venda do call center
@Type    : FUN = Funcao
@Name    : TKGRPED
@Author  : Ihorran Milholi
@Date    : 15/07/2015
@DCT     : Documentacao tecnica
@DCO     : Documentacao operacional
*/
User Function TKGRPED(valor,a,b,c,d,cCondPag)                           

Local aArea 	:= GetArea(),nvalunit:=0 ,desc_max :=0, _ntotaberto:=0,_ntotdesc:=0
Local nSaldo 	:= 0, nCred_Vend := 0, nCred := 0, nTotUtil := 0 
Local lRet		:= .t.  
Local dDataFim		:= dDataBase+1
Local cProduto		:= ""
Local cLocal		:= ""   
Local nPrUnit		:= 0
Local nQuant		:= 0
Local nValPis		:= 0
Local nValCof		:= 0
Local nValIPI		:= 0
Local nValICMSRet	:= 0
Local nValICMS		:= 0                                                                                                                       
Local nFrete		:= 0
Local nDespesa		:= 0
Local nImpostos		:= 0
Local nPreco		:= 0
Local aEstoque		:= {}
Local nCustoMedio	:= 0
Local nRecLiquida	:= 0
Local nLucroBruto	:= 0
Local nMargemBruta	:= 0
Local nTotRecLiquida:= 0
Local nTotLucroBruto:= 0        
Local nQtTotPed		:= 0
Local nQtItBriga	:= 0
Local nFator		:= 0
Local nDif			:= 0
Local nPercItBriga 	:= SuperGetMv("MV_YPERITB",.F.,15.50) 
Local nPerc06DE 	:= SuperGetMv("MV_YPER6DE",.F.,26.50) 
Local nPerc08DE 	:= SuperGetMv("MV_YPER8DE",.F.,26.50)                                                                
Local nPerc01DE 	:= SuperGetMv("MV_YPER1DE",.F.,26.50)
Local nPerc06FE 	:= SuperGetMv("MV_YPER6FE",.F.,23.30) 
Local nPerc08FE 	:= SuperGetMv("MV_YPER8FE",.F.,23.30)                                                                
Local nPerc01FE 	:= SuperGetMv("MV_YPER1FE",.F.,23.30)
Local xN			:= 0
	
DbSelectArea("SA3")
DbSetOrder(1)
DbSeek(xFilial("SA3")+M->UA_VEND)

SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+M->UA_CLIENTE))

//posiciona na tabela SLG
SLG->(DbSetOrder(1))
If SLG->(DbSeek(xFilial("SLG")))

	If Type("cEstacao") == "C"
	
		cEstacao := SLG->LG_CODIGO
	
	EndIf
	
EndIf

//Se for atendimento, nao devera passar pelo ponto de entrada.
If M->UA_OPER == "3"
	
	Return .T.
	
EndIf

//If cEmpAnt == "08"

	//Comentado pois as validações serão feitas pela NeuroTech
	//lRet := u_VIXA110(M->UA_CLIENTE,M->UA_LOJA,"N",aValores[6],.f.)
	
	//If lRet
	
		If M->UA_OPER == "3"
			
			Return .T.
			
		EndIf
	
	//EndIf

//EndIf

If lRet

	If !u_VerifCliEmp(SA1->A1_CGC)
	
		//If	!(cEmpAnt+cFilAnt == "0301")  //SE NAO FOR EMPRESA 03/01 DEVERA SER FEITA A ANALISE DOS CREDITOS UTILIZADOS NO PEDIDO
			
			//verifica se usou decrescimo em produtos na promocao
			If lRet 
				
				/*
				For n := 1 to Len(acols)
				
					If  !GDDeleted(n)

						//lRet := U_TKEVALI()
						
						If !lRet
							Exit
						EndIf
						
						/*		
						DbSelectArea("SB0")
						DbSetOrder(1)
						DbSeek(xFilial("SB0")+gdFieldGet("UB_PRODUTO",xN))
						
						If GdFieldget("UB_YDECRES",xN) > 0 .and. SB0->B0_PRVZ > 0 .AND. dDatabase < SB0->B0_DATA8
										
							MsgAlert("O produto "+AllTrim(gdFieldGet("UB_PRODUTO",xN))+" nao pode usar decrescimo pois encontra-se em promocao!")
							lRet := .F.
	
						EndIf
						*/
						
				  //  EndIf
				    
				//Next
				
			EndIf
				
			nCred := U_Creditos(M->UA_CONDPG)  //Retorno com o Total de Creditos do Pedido
			
			DbSelectArea("SA3")
			DbSetOrder(1)
			DbSeek(xFilial("SA3")+M->UA_VEND)
			
			//If Empty(SA3->A3_GEREN) .or. SubStr(SA3->A3_GEREN,3,2) <> cEmpAnt .or. SubStr(SA3->A3_GEREN,5,2) <> cFilAnt 
			
				If (U_CREDZZ4(SA3->A3_COD) + nCred) < 0
				
					//MsgAlert("Este vendedor nao pode utilizar decrescimo nesta Empresa\Filial, favor corrigir os precos dos produtos!")
					MsgAlert(	"Vendedor Sem Credito Para Efetuar o Pedido!" + CHR(13) + ;
								"Total de Creditos do Vendedor: " + Transform(U_CREDZZ4(SA3->A3_COD),"@E 999,999,999.99")+ CHR(13) +;
								"Total de Creditos do Pedido   : " + Transform(nCred, "@E 999,999,999.99")+ CHR(13) + ;
								"Desconto nao Faturado: " + Transform(_nTotdesc,"@E 999,999,999.99"))
					lRet := .F.
				
				Else
				
					nCred := nCred
				
				EndIf
			
			//EndIf
			
			If lRet
			
				IF U_CREDZZ4(SA3->A3_COD) < 0 
		
					MsgAlert("Vendedor com Saldo Negativo no Conta Corrente" + CHR(13) + " Total de Creditos do Vendedor: " + Transform(U_CREDZZ4(SA3->A3_COD),"@E 999,999,999.99")+ CHR(13) + "Total de Creditos do Pedido   : " + Transform(nCred, "@E 999,999,999.99")+ CHR(13) + "Desconto nao Faturado: " + Transform(_nTotdesc,"@E 999,999,999.99"))
					lRet := .F.
			
				ElseIf nCred < 0
				
					If M->UA_OPER == "2" // SL1/SL2
						cSQL2 := " SELECT SUM(L2_YDECRES*L2_QUANT) NTOTDESC FROM " + RetSqlName("SL2") 
						cSQL2 += " WHERE L2_FILIAL = '"+XFILIAL("SUB") + "' AND L2_DOC  = ''"
						cSQL2 += " AND L2_VEND = '"+M->UA_VEND+ "' AND D_E_L_E_T_ = ' '
						TCQUERY cSQL2 NEW ALIAS "ctrab2"	            
						ctrab2->(DbGotop())
						_ntotdesc := ctrab2->NTOTDESC
						ctrab2->(DbCloseArea())
					Else
						cSQL2 := " SELECT SUM(C6_YDECRES*C6_QTDVEN) NTOTDESC FROM " + RetSqlName("SC6") + " SC6, " +RetSqlName("SC5")+" SC5" 
						cSQL2 += " WHERE C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND C6_FILIAL = '"+XFILIAL("SUB") + "' AND C6_NOTA  = ''"
						cSQL2 += " AND C5_VEND1 = '"+M->UA_VEND+ "' AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ' AND C6_BLQ <> 'R'
						TCQUERY cSQL2 NEW ALIAS "ctrab2"	            
						ctrab2->(DbGotop())
						_ntotdesc := ctrab2->NTOTDESC
						ctrab2->(DbCloseArea())
					EndIf
				
					If	(U_CREDZZ4(SA3->A3_COD) + Round(nCred,1) - _nTotdesc) < 0 
				
						MsgAlert("Vendedor Sem Credito Para Efetuar o Pedido!" + CHR(13) + " Total de Creditos do Vendedor: " + Transform(U_CREDZZ4(SA3->A3_COD),"@E 999,999,999.99")+ CHR(13) + "Total de Creditos do Pedido   : " + Transform(nCred, "@E 999,999,999.99")+ CHR(13) + "Desconto nao Faturado: " + Transform(_nTotdesc,"@E 999,999,999.99"))
						lRet := .F.
		            Else
		
						MsgAlert("Total de Creditos do Vendedor: " + Transform(U_CREDZZ4(SA3->A3_COD),"@E 999,999,999.99")+ CHR(13) + "Total de Creditos do Pedido   : " + Transform(nCred, "@E 999,999,999.99")+ CHR(13) + "Desconto nao Faturado: " + Transform(_nTotdesc,"@E 999,999,999.99"))
						lRet := .T.		
					EndIf
				Else
				
					MsgAlert("Total de Creditos do Vendedor: " + Transform(U_CREDZZ4(SA3->A3_COD),"@E 999,999,999.99")+ CHR(13) + "Total de Creditos do Pedido   : " + Transform(nCred, "@E 999,999,999.99")+ CHR(13) + "Desconto nao Faturado: " + Transform(_nTotdesc,"@E 999,999,999.99"))
					lRet := .T.
				
				EndIf  		
			
			EndIf
			                        
		//Else    //VALIDACAO PARA NAO PERMITIR QUE O PRODUTO SEJA VENDIDO ABAIXO DA MARGEM MINIMA 
			
			/*
			For x:= 1 to Len(aCols) 
			
				If !Gddeleted(x)
	
		        	DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek(xFilial("SB1")+gdFieldGet("UB_PRODUTO",x))
					
					cProduto 		:= GDFIELDGET("UB_PRODUTO",x) 
					cLocal			:= GDFIELDGET("UB_LOCAL",x)
					nQuant			:= GDFIELDGET("UB_QUANT",x)  
					nPrUnit		:= GDFIELDGET("UB_VRUNIT",x)
					nAliqIcm		:= MaFisRet(x,"IT_ALIQICM")  
					nValPis		:= MaFisRet(x,"IT_VALPS2")
					nValCof		:= MaFisRet(x,"IT_VALCF2")
					nValIPI		:= MaFisRet(x,"IT_VALIPI")
					nValICMSRet	:= MaFisRet(x,"IT_VALSOL")
					nValICMS		:= MaFisRet(x,"IT_VALICM")      
					nFrete			:= MaFisRet(x,"IT_FRETE")              
					nDespesa		:= MaFisRet(x,"IT_DESPESA")  
					nImpostos		:= (nValPis+nValCof+nValIPI+nValICMSRet+nValICMS)/nQuant
					nPreco			:= nPrUnit+(nValIPI+nValICMSRet)/nQuant
					nCustoMedio 	:= SB1->B1_CUSTD
					nRecLiquida	:= (nPreco-nImpostos)
					nLucroBruto	:= (nRecLiquida-nCustoMedio)
					nMargemBruta	:= Round((nLucroBruto/nRecLiquida)*100,TamSx3("B0_YLUCRO")[2])
	
					nQtTotPed			+= nQuant
					nTotRecLiquida	+= nRecLiquida*nQuant
					nTotLucroBruto	+= nLucroBruto*nQuant
					
					If nMargemBruta <= nPercItBriga
							     
						nQtItBriga += nQuant
									
					EndIf				
					
					SB0->(dbSetOrder(1))
					If SB0->(dbSeek(xFilial("SB0")+cProduto))
				   		//Aviso("Atencao","MARGEM BRUTA DO PRODUTO "+AllTrim(cProduto)+" :"+cValtoChar(nMargemBruta),{"Voltar"})					
						
						SF4->(dbSetOrder(1))
						If SF4->(dbSeek(xFilial("SF4")+GDFIELDGET("UB_TES",x)))										
							If SF4->F4_INCIDE == "S"//Desconto em funcao do IPI estar agregado na base do ICMS
								nFator := SF4->F4_CRDTRAN
							EndIf 
						EndIf
						
						If nAliqIcm = 17.00
							
							If nMargemBruta < SB0->B0_YMB17 - SA1->A1_DESC - nFator		
								
					 			Aviso("Atencao","O PRODUTO "+AllTrim(cProduto)+" NAO PODERA SER VENDIDO ABAIXO DA MARGEM MINIMA CADASTRADA, favor entrar em contato com o departamento comercial! MARGEM BRUTA DO PRODUTO:"+cValtoChar(nMargemBruta),{"Voltar"})				
								lRet := .F.                                                                                                                                                                   
								Exit				
							Else	
								lRet := .T.		
							EndIf		
						Else
							If nMargemBruta < SB0->B0_YMB04 - SA1->A1_DESC - nFator		
								Aviso("Atencao","O PRODUTO "+AllTrim(cProduto)+" NAO PODERA SER VENDIDO ABAIXO DA MARGEM MINIMA CADASTRADA, favor entrar em contato com o departamento comercial! MARGEM BRUTA DO PRODUTO:"+cValtoChar(nMargemBruta),{"Voltar"})				
								lRet := .F.                                                                                                                                                                   
								Exit				
							Else	
								lRet := .T.		
							EndIf
						EndIf
					EndIf
				        
				EndIf
			
			Next    
		
			//Verifica a margem bruta total
			//Aviso("Atencao","MARGEM BRUTA DO PEDIDO :"+cValtoChar((nTotLucroBruto/nTotRecLiquida)*100),{"Voltar"})	
			If lRet
				
				If nAliqIcm = 17.00		
					Do Case		
						Case cNivel	== 6				
							lRet := iif( (nTotLucroBruto/nTotRecLiquida)*100 >= nPerc06DE, .t., .f. )
							nDif := nPerc06DE - (nTotLucroBruto/nTotRecLiquida)*100					
						Case cNivel	== 8				
							lRet := iif( (nTotLucroBruto/nTotRecLiquida)*100 >= nPerc08DE, .t., .f. )				
							nDif := nPerc08DE - (nTotLucroBruto/nTotRecLiquida)*100						
						OtherWise					
							lRet := iif( (nTotLucroBruto/nTotRecLiquida)*100 >= nPerc01DE, .t., .f. )
							nDif := nPerc01DE - (nTotLucroBruto/nTotRecLiquida)*100
											
					EndCase                   
				Else
					Do Case		
						Case cNivel	== 6				
							lRet := iif( (nTotLucroBruto/nTotRecLiquida)*100 >= nPerc06FE, .t., .f. )
							nDif := nPerc06FE - (nTotLucroBruto/nTotRecLiquida)*100
												
						Case cNivel	== 8				
							lRet := iif( (nTotLucroBruto/nTotRecLiquida)*100 >= nPerc08FE, .t., .f. )
							nDif := nPerc08FE - (nTotLucroBruto/nTotRecLiquida)*100
													
						OtherWise					
							lRet := iif( (nTotLucroBruto/nTotRecLiquida)*100 >= nPerc01FE, .t., .f. )
							nDif := nPerc01FE - (nTotLucroBruto/nTotRecLiquida)*100				
					EndCase                   
				EndIf					
	
				If !lRet
			
					Aviso("Atencao","Este pedido esta sendo vendido "+cValtoChar(Round(nDif,2))+"% abaixo da margem minima possivel. Favor ajustar ou entrar em contato com o departamento comercial!",{"Voltar"})				
	
				ElseIf nQtItBriga > (nQtTotPed*0.50)
	
					Aviso("Atencao","O MIX DE PRODUTOS DESTE PEDIDO NAO ATENDE AO DETERMINADO, favor entrar em contato com o departamento comercial!",{"Voltar"})							   	
				   	lRet := .f.
				Else
					lRet := .t.		
				EndIf
				
			EndIf
			*/
			
		//EndIf        
	
		If lRet //passou em todas as validacoes anteriores. Efetuar a validacao Financeira
			
			/*
			If cEmpAnt <> "08"
			
				If M->UA_OPER == "2" // SL1/SL2
					cSQL := " SELECT SUM(L1_VLRTOT) NTOTABERTO FROM " + RetSqlName("SL1") 
					cSQL += " WHERE L1_FILIAL = '"+XFILIAL("SL1") + "' AND L1_DOC  = ''"
					cSQL += " AND L1_CLIENTE = '"+SA1->A1_COD+ "' AND D_E_L_E_T_ = ' '"
					TCQUERY cSQL NEW ALIAS "ctrab"	            
					ctrab->(DbGotop())
					_ntotaberto := ctrab->NTOTABERTO
					ctrab->(DbCloseArea())
				Else
					cSQL := " SELECT SUM(C6_VALOR) NTOTABERTO FROM " + RetSqlName("SC6") 
					cSQL += " WHERE C6_FILIAL = '"+XFILIAL("SC6") + "' AND C6_NOTA  = ''"
					cSQL += " AND C6_CLI = '"+SA1->A1_COD+ "' AND D_E_L_E_T_ = ' ' AND C6_BLQ	= ''"
					TCQUERY cSQL NEW ALIAS "ctrab"	            
					ctrab->(DbGotop())
					_ntotaberto := ctrab->NTOTABERTO
					ctrab->(DbCloseArea())
				EndIf					
					
				If ((valor + SA1->A1_SALDUP + _nTotAberto) > SA1->A1_LC) .AND. Empty(M->UA_YCONDPG)   //Testa o limite de credito do cliente
					MsgAlert("Limite de Credito do Cliente Excedido !")  
					lRet := .f.
				EndIf
				
			EndIf
			*/
			

				
			If SUA->(FieldPos("UA_YCONDPG")) > 0 .and. !Empty(M->UA_YCONDPG)
			
				SE4->(dbSetOrder(1))
				If SE4->(dbSeek(xFilial("SE4")+cCondPag)) .and. ! ( AllTrim(SE4->E4_FORMA) $ "R$,CC,CD,CH,DC" )
				
					Aviso("Atencao",'Por se tratar de uma venda a vista so podera ser utilizado as condicoes de pagamento do tipo "R$,CC,CD,CH,DC" !',{"Voltar"})  
					lRet := .f.
					
				EndIf
								
			EndIf
		
			
			
		EndIf
	
	Else
	
		//Trava para venda para empresas do grupo
		SU7->(dbSetOrder(4))
		//If ! ( SU7->(dbSeek(xFilial("SU7")+__cUserId)) .and. SU7->U7_TIPO == "2" )
		If ! ( SU7->(dbSeek(xFilial("SU7")+__cUserId)) .and. SU7->U7_YPEDFIL == "2" )
		
			Aviso("Atencao",'Este operador nao tem permissao para realizar vendas para empresas do grupo!',{"Voltar"})  
			lRet := .f.
					
		EndIf
		
	EndIf

EndIf

//Validar Estoque do Produto
If lRet 
	
	/*
	For x := 1 to Len(aCols)

		If !Gddeleted(x)
	
			cProduto 	:= GDFIELDGET("UB_PRODUTO",x) 
			nPrUnit		:= GDFIELDGET("UB_VRUNIT",x)
			cLocal		:= GDFIELDGET("UB_LOCAL",x)
			nQuant		:= GDFIELDGET("UB_QUANT",x)	
	        
	    	DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+cProduto)
	        
			//Verificar Disponibilidade do Estoque
			CSQL 		:= ""
			If cEmpAnt <> "06"
			
				CSQL += " SELECT SUM(RESERVA) RESERVA
				CSQL += " FROM	(
				
				CSQL += " SELECT SUM(SC6.C6_QTDEMP) RESERVA "
				CSQL += " FROM " + RetSqlName("SC6") + " SC6 " 
				CSQL += " WHERE	SC6.C6_BLQ	= ''"
				CSQL += " 	AND SC6.C6_FILIAL = '"+XFILIAL("SUB")+ "'" 
				CSQL += " 	AND SC6.C6_LOCAL 	= '"+GdFieldget("UB_LOCAL",x)+ "'" 
				CSQL += " 	AND SC6.C6_PRODUTO = '"+GdFieldget("UB_PRODUTO",x)+ "' "
				CSQL += " 	AND SC6.D_E_L_E_T_ = ' ' "
				CSQL += " 	AND SC6.C6_QTDEMP > 0 "
				
				CSQL += " UNION ALL "
			
			EndIf
				
			CSQL += " SELECT SUM(SL2.L2_QUANT) RESERVA "
			CSQL += " FROM " + RetSqlName("SL2") + " SL2, " + RetSqlName("SL1") + " SL1 "
			CSQL += " WHERE	                                                                                
			CSQL += " SL2.L2_FILIAL = SL1.L1_FILIAL AND SL2.L2_NUM = SL1.L1_NUM
			CSQL += " AND SL2.L2_DOC  = ''"
			CSQL += " AND SL2.L2_FILIAL = '"+XFILIAL("SUB")+ "'"
			CSQL += " AND SL2.L2_PRODUTO = '"+GdFieldget("UB_PRODUTO",x)+ "' "
			CSQL += " AND SL2.D_E_L_E_T_ = '' AND SL1.D_E_L_E_T_ = ''"
			CSQL += " AND L2_EMISSAO BETWEEN '"+DTOS(Date()-15)+"' AND '"+DTOS(Date())+"'"
			CSQL += " AND L1_YSTATUS <> '8'"		
			
			If cEmpAnt <> "06"
				
				CSQL += " 	) QRY "
			
			EndIf
			
			TCQUERY CSQL NEW ALIAS "ctrab"	            
			ctrab->(DbGotop())
			nreserva := ctrab->RESERVA
			ctrab->(DbCloseArea())
						
			
			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek(xFilial("SB2")+cProduto+cLocal)
			
			If nQuant > (SB2->B2_QATU - SB2->B2_QACLASS - nreserva)   
			    If nQuant < SB2->B2_QATU - SB2->B2_QACLASS .AND. nreserva > 0
	       			Aviso("Atencao","O PRODUTO "+AllTrim(cProduto)+" ESTA COM O ESTOQUE RESERVADO EM "+STR(nreserva,10,0) +" UNIDADE(S) !",{"Voltar"})                                                   
			   		lRet := .F.
			   		Exit
			   	Else	
	      			Aviso("Atencao","O PRODUTO "+AllTrim(cProduto)+" NAO POSSUI SALDO NO ESTOQUE DISPONIVEL PARA ESTA QUANTIDADE !",{"Voltar"})   
			   		lRet := .F.
			   		Exit
			    Endif
			ElseIf SB2->B2_STATUS = '2'
	      		Aviso("Atencao","O PRODUTO "+AllTrim(cProduto)+" ESTA COM STATUS INDISPONIVEL NO ESTOQUE !",{"Voltar"})   
				lRet := .F.
				Exit
			EndIf 

		EndIf

	Next
	*/
	
EndIf	
	
	/*
	If lRet
		wContinua := MsgBox("PEDIDO APROVADO. DESEJA FINALIZAR A VENDA ?","ATENCAO","YESNO")
		If !wContinua
			lRet := .f.
		Endif   							      
	EndIf  
	*/
	If lRet
		lRet = NeuroVal()
	EndIf

Return(lRet)


Static Function NeuroVal()

	Local lRet			:= .T.
	Local oClienteC  	:= TINClienteController():New() // Instancia o controller
    Local oClienteM  	:= oClienteC:GetCliLoja(XFilial("SA1"),M->UA_CLIENTE,M->UA_LOJA)	 // Recuperar o modelo do negócio
	Local oTVLDBLPC		:= Nil	
	Local cRegras		:= ""
	Local nI			:= 0

	//|Operação de faturamento |
	If M->UA_OPER == "1"	

		oTVLDBLPC	:= TINAvaliaBloqueioPedidoController():New()
		oTVLDBLPC:nVlrVenda	  := MaFisRet(,"NF_TOTAL")
		oTVLDBLPC:cVendedor   := M->UA_VEND
		oTVLDBLPC:cCodOper    := M->UA_OPERADO
		oTVLDBLPC:cNumPedido  := M->UA_NUM
		oTVLDBLPC:cObserv     := M->UA_YOBS3

		oTVLDBLPC:WrapRegra(oClienteM)  // Instancia e aplica as regras com base no obj clinte oClienteM

		If (!oTVLDBLPC:lPermite)

			If  oTVLDBLPC:lRegra04 	;
				.AND. oTVLDBLPC:lRegra01  == .F. ;
				.AND. oTVLDBLPC:lRegra02  == .F. ;
				.AND. oTVLDBLPC:lRegra03  == .F. ;
				.AND. oTVLDBLPC:lRegra05  == .F. ;
				.AND. (oClienteM:dtNeurot >= dDataBase)

				lRet :=  .T.

			ElseIf (oClienteM:cAvista == "S") .AND. ((oTVLDBLPC:lRegra02) .OR. (oTVLDBLPC:lRegra03))

				lRet := U_FPINTE03(oTVLDBLPC:cRetorno,"TKGRPED","2")			

			Else

				//|Mostra log de regras bloqueadas |
				lRet := U_FPINTE03(oTVLDBLPC:cRetorno,"TKGRPED")

				If lRet	//|Clicou em Avaliar Crédito |

					cRegras	+= IIf(oTVLDBLPC:lRegra01,"1","*")
					cRegras	+= IIf(oTVLDBLPC:lRegra02,"2","*")
					cRegras	+= IIf(oTVLDBLPC:lRegra03,"3","*")
					cRegras	+= IIf(oTVLDBLPC:lRegra04,"4","*")
					cRegras	+= IIf(oTVLDBLPC:lRegra05,"5","*")

					//|Flag na venda para identificar o bloqueio |
					M->UA_YRNEGOC	:= cRegras
				EndIf

			EndIf

		EndIf

	EndIf

Return lRet