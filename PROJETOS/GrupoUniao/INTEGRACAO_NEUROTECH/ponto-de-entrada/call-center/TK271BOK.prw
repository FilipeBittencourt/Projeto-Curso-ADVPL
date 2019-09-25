#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"

#DEFINE TOTMERC		1
#DEFINE TOTPED		6
#DEFINE DESP  		5
#DEFINE FRETE  		4
#DEFINE DESCONTO	2

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณTK271BOK  บ Autor ณIHORRAN MILHOLI     บ Data ณ  01/08/14     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDescricao ณponto de entrada TK271BOK na chamada do OK da Toolbar da      บฑฑ
ฑฑบ			 ณtela de atendimento. Se o retorno for negativo, nao chama   	  บฑฑ
ฑฑบ			 ณa funcao   de gravacao e nao sai da tela. 			        	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                              		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function TK271BOK(nOpc)
	
	Local lRet 			:= .t.
	Local nPercMaxFr	:= SuperGetMv("MV_YPERFRM",.F.,2.5)
	Local nPercDesc		:= SuperGetMv("MV_YDESCVI",.F.,0)
	Local cCondPgAV		:= SuperGetMv("MV_YAVISTA",.F.,"")
	Local nValFrtMin		:= 0
	Local cTpFrete		:= ''
	Local cTransp			:= ''
	Local cCondPg			:= ''
	Local nTotMerc		:= 0
	Local nValMaxFre		:= 0
	Local nTotFrtVlr		:= 0
	Local nTotFrtPes		:= 0
	Local nValFrtPes		:= 0
	Local nTotFrete		:= 0
	Local nFreteMin		:= 0
	Local nFreteOld		:= 0
	Local lDentroEst		:= .f.
	Local lCliGrupo		:= .f.
	Local aAux				:= {}
	Local nValExFrPeso	:= 0
	Local x				:= 0
	Local nCallCenter 	:= AllTrim(TkGetTipoAte()) // U7_TIPOATE
	
	Local lTelevGFE		:= SuperGetMV("MV_YTELGFE",.F.,.F.)
	Local nValDesp		:= SuperGetMv("MV_YVLDESP",.F.,2.5)
	Local lFinal			:= iif(nOpc<>NIL,.T.,.F.)
	Local lPossuiPrd		:= .F.
	
	Local cGrpPneu 		:= SuperGetMV("MV_YGRPNEU",.F.,"3002/3004/3005/3006/3007/3008/3009/3010/3011/3012/3013/3014/3016/3017")
	
	Local nPosProd		:= aScan(aHeader, {|x| Trim(x[2]) == "UB_PRODUTO"	})
	Local nPosQuant     := aScan(aHeader, {|x| Trim(x[2]) == "UB_QUANT" 	})
	Local nPosCFOP      := aScan(aHeader, {|x| Trim(x[2]) == "UB_CF" 		})
	Local nPosACG		:= 0
	Local nQtdDESCJU    :=0
	Local nGrpAro13		:= 0
	Local nGrpAros		:= 0
	Local latvRg		:= SuperGetMV("MV_YRARO13",.F.,.F.)
//Local lDtvCall		:= SuperGetMV("MV_YTELCOB",.F.,.T.)
	
	If(LEN(ALLTRIM(M->UA_YOBS3)) > 500) 
		ApMsgInfo("O campo <b>Obs p/Mesa</b> nใo pode pode ter mais de 500 caracteres. No momento o mesmo estแ com <b> "+cValToChar(LEN(M->UA_YOBS3))+"</b>  caracteres.")
		Return .F.
	EndIf 
	
	//IF lDtvCall
		//NรO VALIDA SE FOR TELECOBRANวA
	If Alltrim(FunName()) $ "TMKA350" .OR.  Alltrim(FunName()) $ "TMKA280" .OR. nFolder == 3 .OR. TYPE('M->UA_CLIENTE') == 'U'
			
			// Verifica a posi็ใo do campo 
		nPosACG := aScan(aHeader, {|x| Trim(x[2]) == "ACG_DESCJU" })
	
		
			//Analisa se existe algum desconto concedido em % em cima do valor do juros.
		For nI := 1 To Len(aCols)
			if aCols[nI][nPosACG] > 0
				nQtdDESCJU ++
			End if
		Next
			
			//Caso encontre
		If nQtdDESCJU > 0
				//Pergunte ao usuario se deseja considerar os desconto.
			if MSGYESNO("Deseja considerar os descontos informado no atendimento? ", "Aten็ใo operador" )
				Return .T.
			Else
				
				//Zera o valor do desconto.
				For nI := 1 To Len(aCols)
					if aCols[nI][nPosACG] > 0
						aCols[nI][nPosACG] := 0
					End if
				Next
					
				Return .T.
			End If
				
		End If
			
			
		Return(lRet)
	Endif
	//EndiF

	IF cEmpAnt == '08' .and. !VerifRegraLog()
	
		Alert("Nใo ้ permitido ter no mesmo pedido produtos alocados em diferentes armazens logisticos!")
		Return .F.
			
	EndIf


	//CASO A REGRA ESTEJA ATIVA NA FILIAL.
	IF latvRg .AND. !(Alltrim(M->UA_VEND) $ "0001")
	
		//PECORRE OS ITENS DO ATENDIMENTO
		For i := 1 To Len(aCols)
			
			IF !GDDeleted(i, aHeader, aCols)
				//CONTA QUANTOS PRODUTOS ESTรO NO GRUPO 3003 - ARO 13
				IF Alltrim( POSICIONE( "SB1",1,xFilial("SB1") + acols[i][nPosProd],"B1_GRUPO" ) ) $ "3003"
					
					nGrpAro13 += acols[i][nPosQuant]
					
				End if
				
				//VERIFICA A QUANTIDADE DE PNEUS DE OUTROS AROS NO PEDIDO
				IF Alltrim( POSICIONE( "SB1",1,xFilial("SB1") + acols[i][nPosProd],"B1_GRUPO" ) ) $ cGrpPneu
					
					nGrpAros += acols[i][nPosQuant]
					
				End if
			End if
		Next i
		
		
		If nGrpAro13 > 0
		
			If (nGrpAros < nGrpAro13 )
				Alert("Para grava็ใo do pedido, a quantidade de ARO13 nao pode ser inferior aos outros AROS")
				Return .F.
			End If
		End If

	
	End If
		
	
	If SUPERGETMV('MV_YANACFO', .F. , .T.)
		If !AnaliCFPO()
			Return .F.
		EndIf
	EndIf
	
	cTpFrete:= M->UA_TPFRETE
	cTransp	:= M->UA_TRANSP
	cCondPg	:= M->UA_CONDPG
	
	//Atendendo ao chamado: 106212
	If M->UA_OPER == "3"
		TMK271CRD()
	EndIf
	
	//Zera valores de frete
	aValores[FRETE] := 0
	Tk273RodImposto("NF_FRETE",aValores[FRETE])
	
	//Monta valor do pedido sem frete
	nTotMerc	:= aValores[TOTMERC]
	nValMaxFre	:= nTotMerc*(nPercMaxFr/100)
	
	//Analise de frete do call center
	If lRet .and. M->UA_OPER <> "3"
		
		lRet := AnalEstoque()
		
	EndIf
	
	//vendas no hiper permitidas apenas para pessoa fisica ou isento
	If lRet .and. cEmpAnt == "09"
		
		//Verifica dados do cliente
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA))
			
			If lRet .and. ! (SA1->A1_PESSOA == "F" .or. Empty(SA1->A1_INSCR) .or. AllTrim(SA1->A1_INSCR) == "ISENTO")
				
				Aviso("Aten็ใo","Apenas vendas para pessoa fisica ou ISENTO sใo permitidas nesta empresa!",{"Voltar"})
				
				lRet := .f.
				
			EndIf
			
			If lRet .and. SM0->M0_ESTENT == SA1->A1_EST
				
				Aviso("Aten็ใo","Nใo esta permitido vendas para clientes do mesmo estado desta empresa!",{"Voltar"})
				
				lRet := .f.
				
			EndIf
			
		EndIf
		
	EndIf
	
	//Analise de margem bruta callcenter
	/*
	If lRet .and. M->UA_OPER <> "3"
		
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA))
			
			//verifica se ้ empresa do grupo, caso nใo seja faz a verifica็ใo da margem bruta
			If !u_VerifCliEmp(SA1->A1_CGC)
				
				lRet := AnalMargemBruta()
				
			EndIf
			
		EndIf
		
	EndIf
	*/
	
	//Calculos de frete
	If lRet
		
		//Verifica dados do cliente
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA))
			
			lDentroEst	:= iif(SA1->A1_EST == SM0->M0_ESTENT,.t.,.f.)
			lCliGrupo	:= u_VerifCliEmp(SA1->A1_CGC)
			
			//Valida o frete caso seja CIF e o cliente nใo ้ do grupo
			If !lCliGrupo
				
				If !lTelevGFE
					
					If cTpFrete == "C"
						
						//Verifica a obrigatoriedade do preenchimento da transportadora
						If lRet .and. lFinal
							
							If Empty(cTransp)
								
								lRet := .f.
								
								Aviso("Aten็ใo","Favor preencher a transportadora para este pedido, este campo ้ obrigat๓rio!",{"Voltar"})
								
							EndIf
							
						EndIf
						
						//Verifica a obrigatoriedade do preenchimento da condi็ใo de pagamento
						If lRet .and. lFinal
							
							If Empty(cCondPg)
								
								lRet := .f.
								
								Aviso("Aten็ใo","Favor preencher a Condicao de pagamento para este pedido, este campo ้ obrigat๓rio!",{"Voltar"})
								
							EndIf
							
						EndIf
						
						If lRet
							
							If !Empty(cTransp)
								
								SA4->(DbSetOrder(1))
								SA4->(DbSeek(xFilial("SA4")+cTransp))
								
								If AllTrim(SA4->A4_VIA) == "MOTOBOY"
									
									aValores[FRETE] := SA4->A4_YVALOR
									
								Else
									
									If SA4->(FieldPos("A4_YFREMIN")) > 0
										
										nFreteMin	:= SA4->A4_YFREMIN
										
									EndIf
									
									//Recupera valores de vendas anteriores porem no mesmo dia
									If 	(cEmpAnt == "08" .and. cFilAnt == "01" .and. lDentroEst .and. Substr(SA4->A4_NOME,1,5) == "BRISA") .OR.;
											(cEmpAnt == "01" .and. cFilAnt == "06")
										
										aAux		:= VendasDia(SUA->UA_CLIENTE,SUA->UA_LOJA,cTransp)
										nTotMerc	+= aAux[1]
										nTotFrtPes	+= aAux[2]
										nFreteOld	:= aAux[3]
										
									EndIf
									
									If SA4->(FieldPos("A4_YPERCVL")) > 0 .and. SA4->(FieldPos("A4_YVALPES")) > 0
										
										If SA4->(FieldPos("A4_YPERCFR")) > 0 .and. !lDentroEst .and. SA4->A4_YPERCFR > 0
											
											nTotFrtVlr += nTotMerc*(SA4->A4_YPERCFR/100)
											nPercMaxFr := iif(cTransp == "000508" .and. cEmpAnt == "08",SA4->A4_YPERCFR,nPercMaxFr)
											
										Else
											
											nTotFrtVlr += nTotMerc*(SA4->A4_YPERCVL/100)
											nPercMaxFr := iif(cTransp == "000508" .and. cEmpAnt == "08",SA4->A4_YPERCVL,nPercMaxFr)
											
										EndIf
										
										//Calcula o valor de frete de acordo com os produtos do pedido
										For x := 1 to Len(aCols)
											
											If !Gddeleted(x)
												
												SB1->(DbSetOrder(1))
												SB1->(DbSeek(xFilial("SB1")+gdFieldGet("UB_PRODUTO",x)))
												
												nTotFrtPes	+= SB1->B1_PESBRU*gdFieldGet("UB_QUANT",x)
												
											EndIf
											
										Next
										
										If cTransp == "000508" .and. cEmpAnt == "08" .and. nTotFrtPes <= 80
											
											nTotFrtPes := 0
											
										EndIf
										
										nValFrtPes := nTotFrtPes*SA4->A4_YVALPES
										
										//Verifica qual o valor maior, se por peso ou por valor
										If nTotFrtVlr > nValFrtPes
											
											nTotFrete := nTotFrtVlr
											
										Else
											
											nTotFrete := nValFrtPes
											
										EndIf
										
										If SA4->(FieldPos("A4_YPESOLI")) > 0 .and. SA4->(FieldPos("A4_YEXPESO")) > 0
											
											If SA4->A4_YPESOLI > 0 .and. SA4->A4_YEXPESO > 0
												
												If nTotFrtPes > SA4->A4_YPESOLI
													
													nValExFrPeso:= (nTotFrtPes-SA4->A4_YPESOLI)*SA4->A4_YEXPESO
													nTotFrete 	+= nValExFrPeso
													
												EndIf
												
											EndIf
											
										EndIf
										
									EndIf
									
									//retira o peso dos pedidos anteriores
									If Len(aAux) >= 2
										
										nTotFrtPes -= aAux[2]
										
									EndIf
									
									//calcula maximo de frete que pode ser cobrado
									nValMaxFre := nTotMerc*(nPercMaxFr/100)
									
									If SA4->(FieldPos("A4_YVALOR")) > 0 .and. SA4->(FieldPos("A4_YVALFE")) > 0 .and. nTotMerc < nFreteMin
										
										//Analisa o valor do frete com o frete minimo
										If lDentroEst
											
											If nTotFrete < SA4->A4_YVALOR
												
												nTotFrete := SA4->A4_YVALOR
												
											EndIf
											
										Else
											
											If nTotFrete < SA4->A4_YVALFE
												
												nTotFrete := SA4->A4_YVALFE
												
											EndIf
											
										EndIf
										
									EndIf
									
									//Ajusta valor do frete com frete minimo
									//ou caso a empresa pague o frete nใo pode ultrapassar 3%
									If nTotMerc < nFreteMin
										
										aValores[FRETE] := nTotFrete
										
									Else
										
										aValores[FRETE] := 0
										
										//Caso seja frete proprio nใo cobra do cliente com valor acima do minimo
										If !AllTrim(SA4->A4_VIA) == "PROPRIO"
											
											If nTotFrete > nValMaxFre
												
												aValores[FRETE] := nTotFrete-nFreteOld-nValMaxFre
												
											EndIf
											
										EndIf
										
									EndIf
									
									//temporario, chamado 39204
									//Boa noite,
									//Por gentileza, com o inํcio das entregas de mercadorias dentro do ES sendo realizadas pela Transportadora BRISA, precisamos parametrizar o sistema para que consigamos acatar a seguinte opera็ใo.
									//1 - Frete DE acima de R$ 1.500,00 serแ paga, contudo, o envio serแ obrigat๓rio pela BRISA, impedindo que o vendedor consiga selecionar qualquer outra transportadora.
									//2 - Frete DE abaixo de R$ 1.500,00 deverแ ser FOB, podendo ser pela BRISA desde que cobrado um valor de frete mํnimo ou poderแ seguir por outra transportadora desde que FOB.
									//Obs:. Nใo podemos travar as transportadoras Aguia Branca e Trancherrer aumentando o valor mํnimo de frete, uma vez que utilizamos as mesmas para opera็๕es FE.
									//Sandro
									If cEmpAnt == "08" .and. cFilAnt == "01" .and. lDentroEst .and. nTotMerc > nFreteMin
										
										//If Substr(SA4->A4_NOME,1,5) <> "BRISA" .and. !( "RETIRA" $ AllTrim(SA4->A4_NOME) )
										
										If 	SA4->A4_COD <> "000505" .and. ;
												SA4->A4_COD <> "000506" .and. ;
												SA4->A4_COD <> "000508" .and. ;
												SA4->A4_COD <> "000514" .and. ;
												SA4->A4_COD <> "000517" .and. ;
												SA4->A4_COD <> "000519" .and. ;
												SA4->A4_COD <> "000621" .and. ;
												!( "RETIRA" $ AllTrim(SA4->A4_NOME) )
											
											aValores[FRETE] := 999999
											
										EndIf
										
									EndIf
									
								EndIf
								
							EndIf
							
						EndIf
						
						If aValores[FRETE] > 0
							
							If lFinal
								
								If !MsgYesNo("Serแ cobrado um valor de frete de "+AllTrim(Transform(aValores[FRETE],PesqPict("SUA","UA_FRETE")))+" e o peso do pedido ้ "+AllTrim(Transform(nTotFrtPes,PesqPict("SB1","B1_PESBRU")))+", Deseja continuar a venda?")
									
									aValores[FRETE]	:= 0
									lRet 			:= .f.
									
								EndIf
								
							EndIf
							
						Else
							
							aValores[FRETE]	:= 0
							
						EndIf
						
						Tk273RodImposto("NF_FRETE",aValores[FRETE])
						
					EndIf
					
				Else
					
					//s๓ gera calculo ao efetivar o pedido
					//If M->UA_OPER <> "3" .or. ( M->UA_OPER == "3" .and. MsgYesNo("Deseja realizar a simula็ใo dos valores de frete?") )
					
					lRet := A410SMLFRT(cTpFrete)
					
					//EndIf
					
				EndIf
				
			ElseIf lTelevGFE
				
				//CASO SEJA EMPRESA DO GRUPO O SISTEMA DEVE PEGAR A TRANSPORTADORA DO CADASTRO
				lRet := A410SMLFRT(cTpFrete)
				
			EndIf
			
		Else
			
			lRet := .f.
			
		EndIf
		
	EndIf
	
	//Tratamento para despesa acessorias
	If lRet
		
		//Zera valores de despesa acessorias
		aValores[DESP] := 0
		
		Tk273RodImposto("NF_DESPESA",aValores[DESP])
		
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA))
			
			//verifica se o cliente terแ necessidade de cobrar o cliente
			If SA1->A1_YCOBRA == 'S' .AND. !u_VerifCliEmp(SA1->A1_CGC)
				
				SE4->(dbSetOrder(1))
				If SE4->(dbSeek(xFilial("SE4")+M->UA_CONDPG))
					
					If AllTrim(SE4->E4_FORMA) == "NF" .or. AllTrim(SE4->E4_FORMA) == "BOL" .or. Empty(SE4->E4_FORMA)
						
						aValores[DESP] := nValDesp
						
						Tk273RodImposto("NF_DESPESA",aValores[DESP])
						
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	
	//Tratamento para desconto a vista
	/*
	If lRet
		
		//Zera valores de desconto
		aValores[DESCONTO] := 0
		
		Tk273RodImposto("NF_DESCONTO",aValores[DESCONTO])
		
		If (M->UA_CONDPG $ cCondPgAV )
			
			aValores[DESCONTO] := (nTotMerc * nPercDesc)/100
			
			Tk273RodImposto("NF_DESCONTO",aValores[DESCONTO])
			
		EndIf
		
	EndIf
	*/
	
	//Tratar Condi็ใo de Pagamento do Cadastro do Cliente
	If lRet .and. lFinal
		
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA))
			
			If !Empty(SA1->A1_COND) .AND. (SA1->A1_COND <> M->UA_CONDPG)
				
				lRet := .f.
				
				Aviso("Aten็ใo","Este cliente jแ possui amarra็ใo para prazo de pagamento. Condi็ใo: "+AllTrim(SA1->A1_COND)+", Favor revisar a condi็ใo escolhida!",{"Voltar"})
				
			EndIf
			
		EndIf
		
	EndIf
	
	//If lRet .and. lFinal
	//
	//	//Verifica venda minima de acordo com os dados do cliente
	//	SA1->(dbSetOrder(1))
	//	If SA1->(dbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA))
	//
	//		If SA1->(FieldPos("A1_YFATMIN")) > 0 .and. SA1->A1_YFATMIN > 0 .and. SA1->A1_YFATMIN > aValores[TOTMERC]
	//
	//			lRet := .f.
	//			Aviso("Aten็ใo","Este pedido nใo atingiu o valor minimo de faturamento para este cliente que ้ de "+AllTrim(Transform(SA1->A1_YFATMIN,PesqPict("SA1","A1_YFATMIN")))+", Favor revisar este pedido!",{"Voltar"})
	//
	//		EndIf
	//
	//	EndIf
	//
	//EndIf
	
	*---------------------------------------------------
	// VALIDAวรO DO CHAMADO NUMERO "106800" DO OCOMON
	*---------------------------------------------------
	If lRet
		IF SE4->(FieldPos("E4_YTPCOND")) > 0
			
			_cCond 	:= M->UA_CONDPG
			_cTpCond	:= Posicione("SE4",1,xFilial("SE4")+M->UA_CONDPG,"E4_YTPCOND")
			If _cTpCond = "1" //1=Varejo 2=Atacado e 3=Ambos
				lRet := .F.
				MsgAlert("O tipo da condi็ใo de pagamento invแlido: " + Char(10) + "Tipo Informado: 1-Varejo","TIPO CONDICAO INVALIDA [PE: TK271BOK]" )
			EndIf
		EndIf
	EndIf
	
	//Analisa se o atendimento veio da agenda do operador e se tem produtos
	lPossuiPrd := .F.
	If Alltrim(FunName()) $ "TMKA380/VXTMK380" .AND. M->UA_OPER == '3' //Atendimento
		For x := 1 To Len(aCols)
			If !Gddeleted(x)
				If ! Empty(gdFieldGet("UB_PRODUTO",x))
					lPossuiPrd := .T.
				EndIf
			EndIf
		Next
		
	EndIf
	
	If lPossuiPrd .OR. ! Alltrim(FunName()) $ "TMKA380/VXTMK380"
		If lRet .and. lFinal
			
			//Verifica venda minima de acordo com os dados do cliente
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA))
				
				If SA1->(FieldPos("A1_YFATMIN")) > 0 .and. SA1->A1_YFATMIN > 0 .and. SA1->A1_YFATMIN > aValores[TOTMERC]
					lRet := .f.
					Aviso("Aten็ใo","Este pedido nใo atingiu o valor minimo de faturamento para este cliente que ้ de "+AllTrim(Transform(SA1->A1_YFATMIN,PesqPict("SA1","A1_YFATMIN")))+", Favor revisar este pedido!",{"Voltar"})
					
				EndIf
				
			EndIf
			
		EndIf
		
	EndIf
	
	If lRet
		lRet := CliSefaz()
		
	EndIf
	
	////Caso a origem seja "Agenda do operador"
	//If Alltrim(FunName()) == "TMKA380" .AND. M->UA_OPER == '3' //Atendimento
	//	If !lPossuiPrd
	//		U_VIXA170()
	//	EndIf
	//Endif
	
	//Travar problema de CFOP interestadual
	If lRet 	
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+M->UA_CLIENTE+M->UA_LOJA))
			if SM0->M0_ESTENT <> SA1->A1_EST
				//PECORRE OS ITENS DO ATENDIMENTO
				For i := 1 To Len(aCols)
					if Substr(acols[i][nPosCFOP],1,2) <> "6"

						cAuxCFO := Alltrim(acols[i][nPosCFOP])
						acols[i][nPosCFOP] := "6" + Substr(cAuxCFO,2,len(cAuxCFO))

						//lRet := .F.						
						//MsgAlert("Item de Venda com CFOP invalido para operacao Interestadual." + Char(10)+ Char(10)+"Revalide o item para acertar os dados do gatilho."+ Char(10)+ Char(10)+"Caso necessario entre em contato com a TI."  )
					endif 
				next i
			endif
		endif
	endif	
	
	
	*---------------------------------------------------
	// F	I	M
	*---------------------------------------------------
	
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบPrograma  ณVendasDia บ Autor ณIHORRAN MILHOLI     บ Data ณ  01/08/14   	บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDescricao ณRecupera o valor ja vendido para este cliente e transportadoraบฑฑ
ฑฑบ			 ณneste dia para definir o valor minimo de compra para nใo 		บฑฑ
ฑฑบ			 ณcobran็a do frete										        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5 IDE                                              		บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function VendasDia(cCliente,cLoja,cTransp)
	
	Local nTotMerc		:= 0
	Local nTotPeso		:= 0
	Local nTotFrete		:= 0
	Local cAlias		:= GetNextAlias()
	
	//recupera o faturamento do dia
	BeginSql Alias cAlias
		
		SELECT	ISNULL(SUM(TOTAL),0)		TOTAL
		,	ISNULL(SUM(PESO),0)		PESO
		,	ISNULL(SUM(TOTFRETE),0)	TOTFRETE
		
		FROM	(
		
		SELECT	SUM(SC6.C6_VALOR) 		 			TOTAL
		,	SUM(SB1.B1_PESBRU*SC6.C6_QTDVEN) 	PESO
		,	SC5.C5_NUM				  				NUM
		,	SC5.C5_FRETE			  				TOTFRETE
		
		FROM	%table:SC5%  SC5
		
		INNER JOIN %table:SC6% 	SC6 ON	SC6.C6_FILIAL	= SC5.C5_FILIAL
		AND SC6.C6_NUM		= SC5.C5_NUM
		AND SC6.%notdel%
		
		INNER JOIN %table:SB1% 	SB1 ON	SB1.B1_FILIAL	= %xFilial:SB1%
		AND SB1.B1_COD		= SC6.C6_PRODUTO
		AND SB1.%notdel%
		
		WHERE	SC5.C5_FILIAL		= %xFilial:SC5%
		AND SC5.C5_EMISSAO	= %Exp:dtos(dDatabase)%
		AND SC5.C5_CLIENTE	= %Exp:cCliente%
		AND SC5.C5_LOJACLI	= %Exp:cLoja%
		AND SC5.C5_TRANSP		= %Exp:cTransp%
		AND SC5.C5_TPFRETE	= %Exp:'C'%
		AND SC5.%notdel%
		
		GROUP BY SC5.C5_NUM, SC5.C5_FRETE
		
		UNION ALL
		
		SELECT	SUM(SL1.L1_VALMERC) 		   		TOTAL
		,	SUM(SB1.B1_PESBRU*SL2.L2_QUANT)	PESO
		,	SL1.L1_NUM					  		NUM
		,	SL1.L1_FRETE						TOTFRETE
		
		FROM	%table:SL1%  SL1
		
		INNER JOIN %table:SL2% 	SL2 ON	SL2.L2_FILIAL	= SL1.L1_FILIAL
		AND SL2.L2_NUM		= SL1.L1_NUM
		AND SL2.%notdel%
		
		INNER JOIN %table:SB1% 	SB1 ON	SB1.B1_FILIAL	= %xFilial:SB1%
		AND SB1.B1_COD		= SL2.L2_PRODUTO
		AND SB1.%notdel%
		
		WHERE	SL1.L1_FILIAL		= %xFilial:SL1%
		AND SL1.L1_EMISSAO	= %Exp:dtos(dDatabase)%
		AND SL1.L1_CLIENTE	= %Exp:cCliente%
		AND SL1.L1_LOJA		= %Exp:cLoja%
		AND SL1.L1_TRANSP		= %Exp:cTransp%
		AND SL1.L1_TPFRET		= %Exp:'C'%
		AND SL1.%notdel%
		
		GROUP BY SL1.L1_NUM, SL1.L1_FRETE
		
		)	QRY
		
	EndSql
	
	(cAlias)->(dbGoTop())
	
	//Recupera o valor faturado do dia para o cliente
	If (cAlias)->(!Eof()) .and. (cAlias)->(!Bof())
		
		nTotMerc := (cAlias)->TOTAL
		nTotPeso := (cAlias)->PESO
		nTotFrete:= (cAlias)->TOTFRETE
		
	EndIf
	
	(cAlias)->(dbCloseArea())
	
Return({nTotMerc,nTotPeso,nTotFrete})

//Atendendo ao chamado: 106212
Static Function TMK271CRD()
	
	Local _aArea	:= GetArea()
	
	Local _nPosAc	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "UB_YACRESC"})
	Local _nPosDe	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "UB_YDECRES"})
	Local _nPosQt	:= aScanX( aHeader, { |X,Y| ALLTRIM(X[2]) == "UB_QUANT"})
	
	Local _nPercVenda := SuperGetMV("MV_YVENACR", .F., 1)
	Local _cVend	:= M->UA_VEND
	Local _nCred	:= U_CREDZZ4(_cVend)
	
	Local _nAcre	:= 0
	Local _nDecr	:= 0
	Local _nX		:= 0
	
	For _nX := 1 To Len(aCols)
		_nAcre	+= aCols[_nX,_nPosQt] * aCols[_nX,_nPosAc] * _nPercVenda
		_nDecr	+= aCols[_nX,_nPosQt] * aCols[_nX,_nPosDe]
	Next _nX
	
	MsgAlert(	"Saldo Cr้dito: " + Transform(_nCred, "@E 999,999.99") + Chr(10) + Chr(13) +;
		"Saldo Pedido: " + Transform((_nAcre - _nDecr), "@E 999,999.99") + Chr(10) + Chr(13) +;
		"Saldo Final: " + Transform( ( _nCred + (_nAcre - _nDecr ) ), "@E 999,999.99") )
	
	RestArea(_aArea)
	
Return

/*
@Title   : Rotina para apresenta็ใo do Call Center x Frete Embarcador
@Type    : CLS = Classe
@Name    : A410SMLFRT
@Author  : Ihorran Milholi
@Date    : 25/02/2016
@DCT     : Documentacao tecnica
@DCO     : Documentacao operacional
*/
Static Function A410SMLFRT(cTpFrete)

	Local nTotPed	:= 0
	Local nTotMerc	:= 0
	Local nTotPeso	:= 0
	Local nTotVol	:= 0
	Local nFator	:= 1
	Local aRet		:= {}
	Local lRet		:= .F.
	Local lInclui 	:= INCLUI
	Local lAltera 	:= ALTERA
	Local aItFrete	:= {}
	Local nPos		:= 0
	Local cCdClFr	:= ""

	Local nPProduto		:= aScan(aHeader,{|x| AllTrim(x[2])=="UB_PRODUTO"})
	Local nPQtdVen		:= aScan(aHeader,{|x| AllTrim(x[2])=="UB_QUANT"})
	Local nPValor		:= aScan(aHeader,{|x| AllTrim(x[2])=="UB_VRUNIT"})
	Local nPVlImp		:= aScan(aHeader,{|x| AllTrim(x[2])=="UB_YVLRIMP"})
	Local nX			:= 0

//Retira fun็ใo de limpar tela
	SetKey(VK_F5,{|| Nil})

//Recupera os valores de pedidos PESO E VALOR
//Percorre todos os itens do pedido
	For nX:= 1 To Len(aCols)

		If !GdDeleted(nX)

			SB1->(DbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+aCols[nX,nPProduto]))
		
		//Guarda o total do peso da mercadoria
			nTotPeso:= aCols[nX,nPQtdVen] * SB1->B1_PESBRU
			nTotMerc:= aCols[nX,nPQtdVen] * aCols[nX,nPValor]
			nTotPed	:= aCols[nX,nPQtdVen] * iif(nPVlImp > 0,aCols[nX,nPVlImp],aCols[nX,nPValor])
			cCdClFr	:= GFE044CLF(SB1->B1_COD)
		
		//define o fator de calculo da medida
			If SB1->(FieldPos("B1_YLMDIST")) > 0 .and. SB1->B1_YLMDIST > 0
	
				nFator := SB1->B1_YLMDIST
		
			EndIf
	
		//Tratamento para definir a metragem cubica
			SB5->(dbSetOrder(1))
			If SB5->(dbSeek(xFilial("SB5")+SB1->B1_COD))
		
				nTotVol := ( (SB5->B5_ALTURLC/100) * (SB5->B5_LARGLC/100) * (SB5->B5_COMPRLC/100) ) * (aCols[nX,nPQtdVen]/nFator)
		
			EndIf
		
		//cria o vetor por classfica็ใo de frete
			nPos := aScan(aItFrete,{|x| x[1] == cCdClFr})
		
			If nPos == 0
		
				aAdd(aItFrete,{cCdClFr,nTotPed,nTotVol,nTotMerc,nTotPeso})
			
			Else
		
				aItFrete[nPos][2] += nTotPed
				aItFrete[nPos][3] += nTotVol
				aItFrete[nPos][4] += nTotMerc
				aItFrete[nPos][5] += nTotPeso
			
			EndIf
		
		EndIf
		
	Next nX

//Chama tela para simula็ใo de frete
	aRet := u_VIXA149(M->UA_NUM,IIF(M->UA_OPER <> "3",.T.,.F.),cTpFrete,M->UA_CLIENTE,M->UA_LOJA,aItFrete)

	If Len(aRet) > 0
	
		lRet				:= .t.
		M->UA_TRANSP 		:= aRet[1]	//cCodTrans
		aValores[FRETE] 	:= aRet[2]	//aListBox[nItemMrk,SMVLCOBR]
		
		Tk273RodImposto("NF_FRETE",aValores[FRETE])
		
		lHabilita 	:= .f.
		
	EndIf

	INCLUI := lInclui
	ALTERA	:= lAltera

Return lRet

/*
@Title   : Fun็ใo de analise de margem bruta
@Type    : FUN = Fun็ใo
@Name    : AnalMargemBruta
@Author  : Ihorran Milholi
@Date    : 18/08/2015
@DCT     : Documentacao tecnica
@DCO     : Documentacao operacional
*/
Static Function AnalMargemBruta
	
	Local lRet 			:= .t.
	Local cProduto		:= ""
	Local cLocal			:= ""
	Local nPrUnit			:= 0
	Local nQuant			:= 0
	Local nValPis			:= 0
	Local nValCof			:= 0
	Local nValIPI			:= 0
	Local nValICMSRet		:= 0
	Local nValICMS		:= 0
	Local nFrete			:= 0
	Local nDespesa		:= 0
	Local nImpostos		:= 0
	Local nPreco			:= 0
	Local aEstoque		:= {}
	Local nCustoMedio		:= 0
	Local nRecLiquida		:= 0
	Local nLucroBruto		:= 0
	Local nMargemBruta	:= 0
	Local nTotRecLiquida	:= 0
	Local nTotLucroBruto	:= 0
	Local nQtTotPed		:= 0
	Local nQtItBriga		:= 0
	Local nFator			:= 0
	Local nDif				:= 0
	Local nPercItBriga 	:= SuperGetMv("MV_YPERITB",.F.,15.50)
	Local nPerc06DE 		:= SuperGetMv("MV_YPER6DE",.F.,26.50)
	Local nPerc08DE 		:= SuperGetMv("MV_YPER8DE",.F.,26.50)
	Local nPerc01DE 		:= SuperGetMv("MV_YPER1DE",.F.,26.50)
	Local nPerc06FE 		:= SuperGetMv("MV_YPER6FE",.F.,23.30)
	Local nPerc08FE 		:= SuperGetMv("MV_YPER8FE",.F.,23.30)
	Local nPerc01FE 		:= SuperGetMv("MV_YPER1FE",.F.,23.30)
	Local xN				:= 0
	Local x				:= 0
	
	If cEmpAnt+cFilAnt == "0301"
		
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
					//Aviso("Aten็ใo","MARGEM BRUTA DO PRODUTO "+AllTrim(cProduto)+" :"+cValtoChar(nMargemBruta),{"Voltar"})
					
					SF4->(dbSetOrder(1))
					If SF4->(dbSeek(xFilial("SF4")+GDFIELDGET("UB_TES",x)))
						If SF4->F4_INCIDE == "S"//Desconto em fun็ใo do IPI estar agregado na base do ICMS
							nFator := SF4->F4_CRDTRAN
						EndIf
					EndIf
					
					If nAliqIcm = 17.00
						
						If nMargemBruta < SB0->B0_YMB17 - SA1->A1_DESC - nFator
							
							Aviso("Aten็ใo","O PRODUTO "+AllTrim(cProduto)+" NAO PODERA SER VENDIDO ABAIXO DA MARGEM MINIMA CADASTRADA, favor entrar em contato com o departamento comercial! MARGEM BRUTA DO PRODUTO:"+cValtoChar(nMargemBruta),{"Voltar"})
							lRet := .F.
							Exit
						Else
							lRet := .T.
						EndIf
					Else
						If nMargemBruta < SB0->B0_YMB04 - SA1->A1_DESC - nFator
							Aviso("Aten็ใo","O PRODUTO "+AllTrim(cProduto)+" NAO PODERA SER VENDIDO ABAIXO DA MARGEM MINIMA CADASTRADA, favor entrar em contato com o departamento comercial! MARGEM BRUTA DO PRODUTO:"+cValtoChar(nMargemBruta),{"Voltar"})
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
		//Aviso("Aten็ใo","MARGEM BRUTA DO PEDIDO :"+cValtoChar((nTotLucroBruto/nTotRecLiquida)*100),{"Voltar"})
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
				
				Aviso("Aten็ใo","Este pedido esta sendo vendido "+cValtoChar(Round(nDif,2))+"% abaixo da margem minima possํvel. Favor ajustar ou entrar em contato com o departamento comercial!",{"Voltar"})
				
			ElseIf nQtItBriga > (nQtTotPed*0.50)
				
				Aviso("Aten็ใo","O MIX DE PRODUTOS DESTE PEDIDO NรO ATENDE AO DETERMINADO, favor entrar em contato com o departamento comercial!",{"Voltar"})
				lRet := .f.
			Else
				lRet := .t.
			EndIf
			
		EndIf
		
	EndIf
	
Return lRet

/*
@Title   : Fun็ใo de analise de estoque do pedido
@Type    : FUN = Fun็ใo
@Name    : AnalEstoque
@Author  : Ihorran Milholi
@Date    : 18/08/2015
@DCT     : Documentacao tecnica
@DCO     : Documentacao operacional
*/
Static Function AnalEstoque
	
	Local lRet 	:= .t.
	Local cProduto:= ""
	Local nPrUnit	:= 0
	Local cLocal	:= ""
	Local nQuant	:= 0
	Local x
	Local CSQL		:= ""
	Local nreserva:= 0
	Local nEstoque	:= 0
	
	For x := 1 to Len(aCols)
		
		If !Gddeleted(x)
			lRet := U_ESTOQUE2(GDFIELDGET("UB_PRODUTO",x) , GDFIELDGET("UB_LOCAL",x), M->UA_NUM, .T., GDFIELDGET("UB_QUANT",x)	)
			
			If !lRet
				Exit
			EndIf
			
		EndIf
		
	Next
	
Return lRet

/*
------------------------------------------------------------------------------------------------------------
Fun็ใo		: CliSefaz
Tipo		: Fun็ใo estแtica
Descri็ใo	: Analisa na sefaz a situa็ใo cadastral do cliente
Parโmetros	: Nil
Retorno	: Nil
------------------------------------------------------------------------------------------------------------
Atualiza็๕es:
- 29/09/2016 - Henrique - Constru็ใo inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function CliSefaz()
	Local aArea			:= GetArea()
	Local aAreaSA1		:= SA1->(GetArea())
	Local oCadCliente 	:= Nil
	Local lRet				:= .F.
	Local cCliente		:= M->UA_CLIENTE
	Local cLoja			:= M->UA_LOJA
	
	DbSelectArea('SA1')
	DbSetOrder(1)
	If !SA1->(DbSeek(xFilial('SA1')+cCliente+cLoja))
		Return .T.
	EndIf
	
	If Len(AllTrim(SA1->A1_CGC)) != 14
		Return .T.
	EndIf
	
	oCadCliente 		:= WsSitCad():New()
	oCadCliente:cCNPJ 	:= SA1->A1_CGC
	oCadCliente:cUF		:= SA1->A1_EST
	
	oCadCliente:ObtemDados()
	
	//Erro na consulta com a Sefaz
	If Empty(oCadCliente:cCSIT) .and. ! Empty(oCadCliente:cMensErro)
		lRet := .T.
		
	ElseIf oCadCliente:cCSIT == '0'
		If M->UA_OPER == '1' //Faturamento
			Aviso('Aten็ใo', oCadCliente:cSitucao+ chr(13)+chr(10)+;
				'Nใo serแ possํvel fazer a venda para o cliente. Favor alterar a opera็ใo para "Atendimento" ou abandonar o atendimento', {'OK'})
			lRet := .F.
			
		Else
			Aviso('Aten็ใo', oCadCliente:cSitucao, {'OK'})
			lRet := .T.
			
		EndIf
		
	Else
		//Aviso('Aten็ใo', oCadCliente:cSitucao, {'OK'})
		lRet := .T.
		
	EndIf
	
	FreeObj(oCadCliente)
	RestArea(aAreaSA1)
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} AnaliCFPO
(long_description)
@author henrique
@since 23/03/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/Static Function AnaliCFPO()
Local aArea 	:= GetArea()
Local lRet		:= .T.
Local nI		:= 0

For nI := 1 to Len(aCols)
	If ! Empty(GDFIELDGET("UB_PRODUTO",nI)) .and. TK273CFO(M->UA_CLIENTE,M->UA_LOJA, GDFIELDGET("UB_TES",nI)) <> GDFIELDGET("UB_CF",nI)
		Aviso("Aten็ใo","Houve alguma altera็ใo no cadastro do cliente que estแ impactando na forma็ใo dos impostos. "+;
			"Favor refazer o atendimento ou reeditar os itens para atualiza็ใo dos impostos.",{"Voltar"})
		If M->UA_OPER <> "3"
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

RestArea(aArea)

Return lRet

Static Function VerifRegraLog

Local nPosProd	:= aScan(aHeader, {|x| Trim(x[2]) == "UB_PRODUTO" })
Local nQuant	:= 0
Local nQtdTotal	:= 0
Local lRet		:= .f.
Local i

//PECORRE OS ITENS DO ATENDIMENTO
For i := 1 To Len(aCols)
			
	IF !GDDeleted(i, aHeader, aCols)
				
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+acols[i][nPosProd]))		
		
		nQtdTotal++
		
		ZZL->(dbSetOrder(1))
		If ZZL->(dbSeek(xFilial("ZZL")+SB1->B1_FABRIC))
		
			nQuant++
		
		EndIf
		
	EndIf
	
Next

If nQuant == 0 .or. (nQuant == nQtdTotal)

	lRet := .t.
	
EndIf

Return lRet

Static Function GFE044CLF(cProduto)

	Local cRet := ''

	GUK->(dbSetOrder(1))
	If GUK->(dbSeek(xFilial("GUK")+cProduto))
	
		cRet := GUK->GUK_CDCLFR

	Else
		
		/*	
		If cEmpAnt == "08"
		
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+cProduto))
				
				ZZL->(dbSetOrder(1))
				If ZZL->(dbSeek(xFilial("ZZL")+SB1->B1_FABRIC))
					
					cRet := PADR("9",TamSX3("GUK_CDCLFR")[1])
					
				EndIf
				
			EndIf
			
		EndIf
		*/
		
If Empty(cRet)
				
	cRet := PADR(GetNewPar('MV_CDCLFR',''),TamSX3("GUK_CDCLFR")[1])
		
EndIf
	
EndIf

Return cRet