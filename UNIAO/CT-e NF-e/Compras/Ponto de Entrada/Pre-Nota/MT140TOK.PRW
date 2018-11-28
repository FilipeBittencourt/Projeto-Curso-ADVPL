#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include "Ap5Mail.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT140TOK  ºAutor  ³ANDERSON ANDRADE    º Data ³  13/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  FAZ VALIDAÇÃO DOS ITENS DO PEDIDO NA TABELA SC7
±± IMPOSSIBILITANDO SUA GRAVAÇÃO CASO NÃO EXISTA O PEDIDO/ITEM DE COMPRAS º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT140TOK

	Local lRet		:= .T.
	Local aPedidos	:= {}
	Local nPosCod	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD"})
	Local nPosItem	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_ITEM"})
	Local nPosLocal	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_LOCAL"})
	Local nPosQuant	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_QUANT"})
	Local nPosQt2a	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_QTSEGUM"})
	Local nPosVUnit	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_VUNIT"})
	Local nPosTotal	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_TOTAL"})
	Local nPosVICM 	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_VALICM"})	//A IMPORTAÇÃO POR TOTVS COLABORAÇÃO NÃO TRAZ ESTE VALOR
	Local nPosVIPI 	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_VALIPI"})	//A IMPORTAÇÃO POR TOTVS COLABORAÇÃO NÃO TRAZ ESTE VALOR
	Local nPosPICMS := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_PICM"})
	Local nPosPIPI 	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_IPI"})
	Local nPosPICMR	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_ICMSRET"})
	Local nPosPed	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_PEDIDO"})
	Local nPosItPc	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_ITEMPC"})
	Local nPosDscPr	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_VALDESC"})
	Local cItem		:= StrZero(Len(aCols),TamSx3("D1_ITEM")[1])
	Local nPos		:= 0
	Local aAux		:= 0
	Local aErro		:= {}
	Local aColsBkp	:= {}
	Local nTotaCols	:= 0
	Local aHeadExec	:= {}
	
	Local nCol		:= 0
	Local lPCNFE	:= GetNewPar("MV_PCNFE",.F.) //-- Nota Fiscal tem que ser amarrada a um Pedido de Compra ?
	Local aArea		:= GetArea()
	Local nIPI		:= 0
	Local cMsg		:= ""
	Local cCFOPSPC	:= AllTrim(GetNewPar("MV_YCFOSPC","5916;6916;6910;5910;5949;6949"))
	Local lValidPC	:= .t.
	Local cCFOP
	Local cCNPJ
	Local cFabric
	Local cGrupCom  := ''
	Local cCodPrf   := ''
	Local nPeTolPrc1:= 1 + ( SuperGetMv("MV_YPTOLPR",.F.,0.8) / 100 )
	Local nPeTolPrc2:= 1 - ( SuperGetMv("MV_YPTOLPR",.F.,0.8) / 100 )
	Local oImposNfEn:= ImposNfEn():New
	Local i		  := 0
	Local x			:= 0
	Local nRecSM0	:= 0
	Local cGrupTrb	:= ''
	Local lCestOK	:= .T.

//Personalização apenas para pedidos do tipo normal
	If lPCNFE .and. cTipo == "N" .and. (INCLUI .or. ALTERA)
	
	//Caso a nota venha do totvs colaboração e seja de uma empresa do grupo esta nota não será importada
		SDS->(dbSetOrder(1))
		If SDS->(dbSeek(xFilial("SDS")+cNFiscal+cSerie+cA100For+cLoja))
	
			SA2->(dbSetOrder(1))
			SA2->(dbSeek(xFilial("SA2")+cA100For+cLoja))
		
		//guarda a posição da empresa no SIGAMAT
			nRecSM0 := SM0->(Recno())
		
		//percorre todas as empresas para verificar o CNPJ
			SM0->(dbGoTop())
			While SM0->(!Eof())
			
				If SA2->A2_CGC == SM0->M0_CGC
			
					Help( ,, 'Help',, "Esta bloqueado via TOTVS COLABORAÇÃO o lançamento de notas com CNPJ de empresas do GRUPO", 1, 0 )
				
				//retorna a posição da empresa no SIGAMAT
					SM0->(dbGoTo(nRecSM0))
						
					Return .f.
				
				EndIf
			
				SM0->(dbSkip())
			
			EndDo
		
		//retorna a posição da empresa no SIGAMAT
			SM0->(dbGoTo(nRecSM0))
		
		EndIf
	
	//Verificar se a nota vem do totvs colaboração e se precisa validar processo do compras
		If SDS->(FieldPos("DS_YCFOP")) > 0
	
			SDS->(dbSetOrder(1))
			If SDS->(dbSeek(xFilial("SDS")+cNFiscal+cSerie+cA100For+cLoja))

				cCFOP := SDS->DS_YCFOP
				cCNPJ := SDS->DS_CNPJ
			
				If SDS->DS_YCFOP $ cCFOPSPC .or. SDS->DS_TIPO == "T"
		
					lValidPC := .f.
			
				EndIf
		    
			EndIf
		
		EndIf
	
		If lValidPC
		
			aPedidos 	:= fGetItPC(cA100For,cLoja)
			nTotaCols	:= Len(aCols)
		
		//Define o ultimo D1_ITEM do acols
			For i := 1 to Len(aCols)
			
				If cItem < aCols[i][nPosItem]
			
					cItem := aCols[i][nPosItem]
				
				EndIf
			
			Next
		    
		//Classe que retorna os impostos da NOTA utilizando a TES inteligente com o código de operação 01
			oImposNfEn:cCodOperac 	:= '01'
			oImposNfEn:cNota			:= cNFiscal
			oImposNfEn:cSerie			:= cSerie
			oImposNfEn:cFornec		:= cA100For
			oImposNfEn:cLoja			:= cLoja
			oImposNfEn:cTipoNf		:= cTipo
		
			oImposNfEn:Calcular()
			aImpostos := oImposNfEn:aImpos// U_GeraImpos()
		    
		//Percorre os itens
			While nCol <> nTotaCols
			  
				nCol++
				                                  
				If !aCols[nCol][Len(aCols[nCol])]
					cFabric  := ''
					cGrupCom := ''
					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial("SB1")+aCols[nCol][nPosCod]))
	            
						cFabric  := SB1->B1_FABRIC
	            	//cFabric  := AllTrim(Posicione('SZ1',1, xFilial('SZ1') + SB1->B1_YDESCR2, 'Z1_FABRIC')) //fabricante
						cGrupCom := SB1->B1_GRUPCOM
					EndIf
	            
					cCodPrf  := Alltrim(Posicione('SA5',1,xFilial("SA5")+cA100For+cLoja+aCols[nCol][nPosCod],'A5_CODPRF'))
	
					If Empty(aCols[nCol][nPosPed])
	
						nPos := aScan(aPedidos,{|x| x[3] == aCols[nCol][nPosCod] .and. x[4] == aCols[nCol][nPosLocal]})
					
						If nPos > 0
						
							Do Case
							
							Case aCols[nCol][nPosQuant] <= aPedidos[nPos][5]
								
								aCols[nCol][nPosPed]	:= aPedidos[nPos][1]
								aCols[nCol][nPosItPC]	:= aPedidos[nPos][2]
								
								aPedidos[nPos][5] -= aCols[nCol][nPosQuant]
								
								If aPedidos[nPos][5] == 0
									aDel(aPedidos,nPos)
									aSize(aPedidos,Len(aPedidos)-1)
								EndIf
								
							Case aCols[nCol][nPosQuant] > aPedidos[nPos][5]
								
								//Copia aCols para incluir nova linha
								aColsBkp := aClone(aCols[nCol])
								
								aCols[nCol][nPosDscPr]	:= Round((aCols[nCol][nPosDscPr]/aCols[nCol][nPosQuant])*aPedidos[nPos][5],TamSx3("D1_VALDESC")[1])
								aCols[nCol][nPosQuant]	:= aPedidos[nPos][5]
								aCols[nCol][nPosQt2a]	:= ConvUm(aCols[nCol][nPosCod],aPedidos[nPos][5],0,2)
								aCols[nCol][nPosTotal]	:= Round(aCols[nCol][nPosQuant] * aCols[nCol][nPosVUnit],TamSX3("D1_TOTAL")[2])
								aCols[nCol][nPosPed]	:= aPedidos[nPos][1]
								aCols[nCol][nPosItPC]	:= aPedidos[nPos][2]
														
								cItem := Soma1(cItem)
	
								aColsBkp[nPosDscPr]	:= Round((aColsBkp[nPosDscPr]/aColsBkp[nPosQuant])*(aColsBkp[nPosQuant]-aPedidos[nPos][5]),TamSx3("D1_VALDESC")[1])
								aColsBkp[nPosItem]	:= cItem
								aColsBkp[nPosQuant]	:= (aColsBkp[nPosQuant]-aPedidos[nPos][5])
								aColsBkp[nPosQt2a]	:= ConvUm(aColsBkp[nPosCod],aColsBkp[nPosQuant],0,2)
								aColsBkp[nPosTotal]	:= Round(aColsBkp[nPosQuant] * aColsBkp[nPosVUnit],TamSX3("D1_TOTAL")[2])
		
								aDel(aPedidos,nPos)
								aSize(aPedidos,Len(aPedidos)-1)
								
								aAdd(aCols,aClone(aColsBkp))
								nTotaCols++
								
							EndCase
						
						EndIf
					
					//Validações de Nota para geração do workflow
						If Empty(aCols[nCol][nPosPed])
						
							lRet := .f.
							nPos := aScan(aErro,{|x| x[1] == SB1->B1_GRUPCOM})
							cMsg := "Não foi possivel vincular um pedido de compra para este item Quantidade: "+Transform(aCols[nCol][nPosQuant],PesqPict("SD1","D1_QUANT"))
						                                                 
							If nPos == 0
								aAdd(aErro,{SB1->B1_GRUPCOM,{{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,cFabric,cGrupCom,cCodPrf}}})
							Else
								aAdd(aErro[nPos][2],{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,cFabric,cGrupCom,cCodPrf})
							EndIf
										
						EndIf
	
					EndIf


					SA2->(dbSetOrder(1))
					If SA2->(dbSeek(xFilial("SA2")+	cA100For+cLoja))
	            
						If SM0->M0_CODIGO $ '08' .AND. SA2->A2_B2B <> "1"    //chamado #27504
						
		 					If aCols[nCol][nPosQuant] <= 0
								nQde := 1
							Else
								nQde := aCols[nCol][nPosQuant]
							EndIf
							
							nCustoUnit := aCols[nCol][nPosVUnit]-(aCols[nCol][nPosDscPr]/nQde)
				 
							If ABS(nCustoUnit - SB1->B1_CUSTD) > 0.01
								If nCustoUnit > (SB1->B1_CUSTD * nPeTolPrc1)
								
									lRet := .f.
									nPos := aScan(aErro,{|x| x[1] == SB1->B1_GRUPCOM})
									cMsg := "Preço de Compra "+Transform(nCustoUnit,PesqPict("SB1","B1_CUSTD"))+" maior que Custo Standart "+Transform(SB1->B1_CUSTD,PesqPict("SB1","B1_CUSTD"))+" em "+AllTrim(Transform(((aCols[nCol][nPosVUnit]/SB1->B1_CUSTD)*100)-100,"@E 999.99"))+"%"
								
									If nPos == 0
										aAdd(aErro,{SB1->B1_GRUPCOM,{{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,cFabric,cGrupCom,cCodPrf}}})
									
									Else
										aAdd(aErro[nPos][2],{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,cFabric,cGrupCom,cCodPrf})
				
									EndIF
				
								ElseIf nCustoUnit < (SB1->B1_CUSTD * nPeTolPrc2)
	
									nPos := aScan(aErro,{|x| x[1] == SB1->B1_GRUPCOM})
									
									cMsg := "Preço de Compra "+Transform(nCustoUnit,PesqPict("SB1","B1_CUSTD"))+" menor que Custo Standart "+Transform(SB1->B1_CUSTD,PesqPict("SB1","B1_CUSTD"))+" em "+AllTrim(Transform(100-((aCols[nCol][nPosVUnit]/SB1->B1_CUSTD)*100),"@E 999.99"))+"%"
								
									If nPos == 0
										aAdd(aErro,{SB1->B1_GRUPCOM,{{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,cFabric,cGrupCom,cCodPrf}}})
				
									Else
										aAdd(aErro[nPos][2],{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,cFabric,cGrupCom,cCodPrf})
									
									EndIf
				
								EndIf
							
							EndIf
				
						Endif
	          
	          		//===============================================================
	          		// U_GeraImpos = Retorno - Array
	          		// 1 - Código do produto
	          		// 2 - TES
	          		// 3 - CFOP
	          		// 4 - Aliquota de ICMS
	          		// 5 - Valor do ICMS
	          		// 6 - Aliquota de IPI
	          		// 7 - Valor do IPI
	          		// 8 - Aliquota de substituição tributária
	          		// 9 - Valor da substituição tributária
	          		//===============================================================
	          		
						nPosImp := aScan(aImpostos, {|x| AllTrim(x[1]) == AllTrim(aCols[nCol][nPosCod]) })
						If nPosImp > 0 //aCols[nCol][nPosCod]
							SDT->(dbSetOrder(3))
							If SDT->(dbSeek(xFilial("SDT")+cA100For+cLoja+cNFiscal+cSerie+SB1->B1_COD))
								If !oImposNfEn:lOptanteSN
								//============================================================
								//Analisa a aliquota de ICMS
								//============================================================			
									If SDT->(FieldPos("DT_YPICMS")) > 0
										If SDT->DT_YPICMS <> aImpostos[nPosImp, 4]
											lRet := .F.
											nPos := aScan(aErro,{|x| x[1] == SB1->B1_GRUPCOM})
											cMsg := "A aliquota de ICMS da Nota Fiscal ("+Transform(SDT->DT_YPICMS,PesqPict("SDT","DT_YPICMS"))+") "+;
												"diverge da aliquota calculada pelo sistema ("+Transform(aImpostos[nPosImp, 4],PesqPict("SDT","DT_YPICMS"))+;
												") através da TES inteligênte"
					                   	                          
											If nPos == 0
												aAdd(aErro,{SB1->B1_GRUPCOM,{{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,cFabric,cGrupCom,cCodPrf}}})
											Else
												aAdd(aErro[nPos][2],{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,cFabric,cGrupCom,cCodPrf})
											EndIf
									
										Else
											If nPosPICMS > 0
												aCols[nCol][nPosPICMS] 	:= aImpostos[nPosImp, 4]
											EndIf
										EndIf
									EndIf
								EndIf
							
								If !oImposNfEn:lOptanteSN
								//============================================================
								//Analisa a aliquota de IPI
								//============================================================	
									If SDT->(FieldPos("DT_YIPI")) > 0
										If SDT->DT_YIPI <> aImpostos[nPosImp, 6]
											lRet := .F.
											nPos := aScan(aErro,{|x| x[1] == SB1->B1_GRUPCOM})
											cMsg := "A aliquota de IPI da Nota Fiscal ("+Transform(SDT->DT_YIPI,PesqPict("SDT","DT_YIPI"))+") "+;
												"diverge da aliquota calculada pelo sistema ("+Transform(aImpostos[nPosImp, 6],PesqPict("SDT","DT_YIPI"))+;
												") através da TES inteligênte"
					                   	                          
											If nPos == 0
												aAdd(aErro,{SB1->B1_GRUPCOM,{{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,cFabric,cGrupCom,cCodPrf}}})
											Else
												aAdd(aErro[nPos][2],{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,cFabric,cGrupCom,cCodPrf})
											EndIf
										Else
											If nPosPIPI > 0
												aCols[nCol][nPosPIPI]	:= aImpostos[nPosImp, 6]
											EndIf
										EndIf
									EndIf
								EndIf
							
							//============================================================
							//Analisa a substituição Tributária
							//============================================================
								If SDT->(FieldPos("DT_YICMSRE")) > 0
									If SDT->DT_YICMSRE <> aImpostos[nPosImp, 8]
										lRet := .F.
										nPos := aScan(aErro,{|x| x[1] == SB1->B1_GRUPCOM})
										cMsg := "A aliquota de substituição tributária da Nota Fiscal ("+Transform(SDT->DT_YICMSRE,PesqPict("SDT","DT_YICMSRE"))+") "+;
											"diverge da aliquota calculada pelo sistema ("+Transform(aImpostos[nPosImp, 8],PesqPict("SDT","DT_YICMSRE"))+;
											") através da TES inteligênte"
				                   	                          
										If nPos == 0
											aAdd(aErro,{SB1->B1_GRUPCOM,{{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,cFabric,cGrupCom,cCodPrf}}})
										Else
											aAdd(aErro[nPos][2],{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,cFabric,cGrupCom,cCodPrf})
										EndIf
									Else
										If nPosPICMR>0
											aCols[nCol][nPosPICMR]	:= aImpostos[nPosImp, 8]
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
						
					/*
					If SDT->(FieldPos("DT_YIPI")) > 0 
					
						//Recupera o IPI da nota fiscal XML para comparar com o cadastro de produtos
						SDT->(dbSetOrder(3))                                                                                                                                                                                     	
						If SDT->(dbSeek(xFilial("SDT")+cA100For+cLoja+cNFiscal+cSerie+SB1->B1_COD)) 
						
							If SDT->DT_YIPI <> SB1->B1_IPI
			                                                                   
	           					lRet := .f.                                            
			     				nPos := aScan(aErro,{|x| x[1] == SB1->B1_GRUPCOM})
			                   	cMsg := "Aliquota do IPI "+Transform(SDT->DT_YIPI,PesqPict("SB1","B1_IPI"))+" da Nota Fiscal diverge da Aliquota do IPI "+Transform(SB1->B1_IPI,PesqPict("SB1","B1_IPI"))+" do Cadastro de Produtos"
			                   	                          
								If nPos == 0                   
							
									aAdd(aErro,{SB1->B1_GRUPCOM,{{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,cFabric,cGrupCom,cCodPrf}}})
								
								Else
													
									aAdd(aErro[nPos][2],{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,cFabric,cGrupCom,cCodPrf})
								
								EndIf
							
							EndIf
						    
						EndIf
		
					EndIf
					*/

					EndIf
														
				EndIf
			
			EndDo
   
		EndIf

		//validação para verificar o cadastro dos produtos CEST
		If cTipo == "N" .and. (INCLUI .or. ALTERA)
			lCestOK := AnalisCEST(@aErro)
		
			If lRet
				lRet := lCestOK
			EndIf
		EndIf
	
	EndIf

//Verifica se é empresa do grupo, caso afirmativo deixa gerar a pré nota mesmo sem pedidos
	If !lRet
	
		SA2->(dbSetOrder(1))
		If SA2->(dbSeek(xFilial("SA2")+	cA100For+cLoja))
    	
			lRet := u_VerifCliEmp(SA2->A2_CGC)

		EndIf
	
	EndIf

	If !lRet
		If !IsBlind()
			Aviso("Atenção!","Não será possivel lançar esta nota devido a erros de relacionamento do pedido de compra ou cadastro de produtos!",{"Voltar"},2)
		EndIf
	EndIf
     
//---------------------------------------------------------------------
//Envia Workflow para compradores com erros do relacionamento do pedido
//---------------------------------------------------------------------
	If Len(aErro) > 0 .And. !empty(cCFOP)
		If !IsBlind()
			If !lRet
				If MsgYesNo("Deseja enviar um email para o comprador responsavel relatando os erros?","Atenção")
					fWorkFlow(aErro,cCFOP,cCNPJ)
				EndIf
			Else
				fWorkFlow(aErro,cCFOP,cCNPJ)
			EndIf
		Else
			fWorkFlow(aErro,cCFOP,cCNPJ)
		EndIf
	EndIf

	RestArea(aArea)

//tratamento para manipulação da rotina automatica quando manipula o array
If l140Auto

	If Len(aAutoItens) <> Len(aCols)
		
		For i:= 1 to Len(aAutoItens[1])
			
			aAdd(aHeadExec,aAutoItens[1][i][1])
			
		Next
		
		//limpa vetor de itens para 
		aAutoItens := {}
		
		For i:= 1 to Len(aCols)
		
			aAux := {}
				
			For x:= 1 to Len(aHeadExec)
			
				nPos := aScan(aHeader,{|xn| Alltrim(xn[2]) == AllTrim(aHeadExec[x])})
				
				If nPos > 0
				
					aadd(aAux,{aHeadExec[x],aCols[i][nPos],NIL})
			
				Else
				
					aadd(aAux,{aHeadExec[x],,NIL})
					
				EndIf
				
			Next
			
			aAdd(aAutoItens,aAux)
			
		Next
		
	EndIf

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ fGetItPC                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Recupera os itens em pedido de compras                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fGetItPC(cFornece,cLoja)

	Local lConsLoja	:= .T.
	Local lNfMedic	:= .f.
	Local cFilQuery	:= ""
	Local cAliasPed	:= GetNextAlias()
	Local aRet		:= {}
	Local nPosCod	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD"})
	Local nPosLocal	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_LOCAL"})
	Local nPosQuant	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_QUANT"})
	Local nPosPed	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_PEDIDO"})
	Local nPosItPc	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_ITEMPC"})
	Local nPos		:= 0
	Local nQtd		:= 0
	Local i := 0

	If lConsLoja
		cFilQuery	+= iif(!Empty(cFilQuery)," AND ","")
		cFilQuery	+= " SC7.C7_FORNECE = '"+cFornece+"' AND SC7.C7_LOJA = '"+cLoja+"' "
	Else
		cFilQuery	+= iif(!Empty(cFilQuery)," AND ","")
		cFilQuery	+= " SC7.C7_FORNECE = '"+cFornece+"' "
	EndIf

	If SuperGetMV("MV_RESTNFE") == "S"
		cFilQuery	+= iif(!Empty(cFilQuery)," AND ","")
		cFilQuery	+= " SC7.C7_CONAPRO <> 'B' "
	EndIf

	If Empty(cFilQuery)
		cFilQuery	+= "% 1 = 1 %"
	Else
		cFilQuery	:= "% "+cFilQuery+" %"
	EndIF

	BeginSql Alias cAliasPed
	
		SELECT	SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_PRODUTO, SC7.C7_LOCAL
		,	SC7.C7_QUANT, SC7.C7_QUJE, SC7.C7_PRECO, SC7.C7_QTDACLA
		FROM 	%table:SC7%	SC7
		WHERE	SC7.C7_FILENT	=	%xFilial:SC7%
		AND SC7.C7_TPOP		<>	%Exp:'P'%
		AND SC7.C7_ENCER	=	%Exp:''%
		AND SC7.C7_RESIDUO	=	%Exp:''%
		AND SC7.C7_QUANT-SC7.C7_QUJE-SC7.C7_QTDACLA > %Exp:0%
		AND SC7.%NotDel%
		AND %Exp:cFilQuery%
		ORDER BY SC7.C7_PRODUTO, SC7.C7_DATPRF, SC7.C7_NUM, SC7.C7_ITEM
	
	EndSql
            
	If ALTERA

		For i:= 1 to Len(aCols)
	 
			If !Empty(aCols[i][nPosPed])
			
				nPos := aScan(aRet,{|x|	x[1] == aCols[i][nPosPed] .and. x[2] == aCols[i][nPosItPc] .and. ;
					x[3] == aCols[i][nPosCod] .and. x[4] == aCols[i][nPosLocal] })
			
				If aCols[i][Len(aCols[i])]
				
					nQtd := aCols[i][nPosQuant]
				       
				Else
			
					nQtd := aCols[i][nPosQuant]	*-1
						
				EndIf
		                                       
				If nPos == 0
	
					aAdd(aRet,{	aCols[i][nPosPed],;
						aCols[i][nPosItPc],;
						aCols[i][nPosCod],;
						aCols[i][nPosLocal],;
						nQtd,;
						Posicione("SC7",1,xFilial("SC7")+aCols[i][nPosPed]+aCols[i][nPosItPc],"C7_PRECO")})
				    
				Else
	
					aRet[nPos][5] += nQtd
		    
				EndIf
		    
			EndIf
	
		Next

	EndIf

	(cAliasPed)->(dbGoTop())
	While (cAliasPed)->(!Eof())

		nPos := aScan(aRet,{|x|		x[1] == (cAliasPed)->C7_NUM .and. x[2] == (cAliasPed)->C7_ITEM .and. ;
			x[3] == (cAliasPed)->C7_PRODUTO .and. x[4] == (cAliasPed)->C7_LOCAL })
                                                                                                 
		If nPos == 0

			aAdd(aRet,{	(cAliasPed)->C7_NUM,;
				(cAliasPed)->C7_ITEM,;
				(cAliasPed)->C7_PRODUTO,;
				(cAliasPed)->C7_LOCAL,;
				(cAliasPed)->C7_QUANT-(cAliasPed)->C7_QUJE-(cAliasPed)->C7_QTDACLA,;
				(cAliasPed)->C7_PRECO})

			nPos := Len(aRet)
		
		Else
	                             
			aRet[nPos][5] += (cAliasPed)->C7_QUANT-(cAliasPed)->C7_QUJE-(cAliasPed)->C7_QTDACLA
	   		
		EndIf
	
		If aRet[nPos][5] == 0
			aDel(aRet,nPos)
			aSize(aRet,Len(aRet)-1)
		EndIf
						
		(cAliasPed)->(dbSkip())

	EndDo
	(cAliasPed)->(dbCloseArea())

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ fWorkFlow                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Envia Workflow para compradores com erros do relacionamento³±±	
±±³          ³ do pedido                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fWorkFlow(aErro,cCFOP,cCNPJ)

	Local cDestin	:= ""
	Local cAssunto	:= "Rejeição de Importação de Nota Fiscal "+SM0->M0_NOMECOM
	Local cArqHtm	:= "RejRecNota3.htm"	//Arquivo Html
	Local cPathWF	:= "\workflow\"		//Caminho da pasta Workflow
	Local cFileHTML := CriaTrab(NIL,.F.)+".htm"
	Local cMsg		:= ""
	Local cEmailOut	:= AllTrim(GetNewPar("MV_YEMAREJ","compras7@unialvirtual.com.br"))
	Local oHtml
	Local j, i, k := 0
	Local cPath := "C:\RELATO\"
	Local cArquivo  := Alltrim(cPath) + cNFiscal + "__" + DTOS(dDatabase) +"_"+ StrTran(TIME(),":","_") + ".html"
	Local cHead := ""
	Local aMsgErro := {}
	
	Local cItem := ""
	Local cProd := ""
	Local cFabr := ""
	Local cCFOP1 := ""
	Local cComp := ""
	Local cCodF := ""
	Local cMotv := ""
	Local cMsg2 := ""

	For i := 1 to Len(aErro)
                       				
		oHtml := TWFHTML():New( cPathWF+cArqHtm )

	// Preenche as variaveis no HTML do corpo do e-mail
		oHtml:ValByName("cDia",dtoc(dDatabase))
		oHtml:ValByName("cHora",Time())
	
		oHtml:ValByName("cNota",cNFiscal)
		oHtml:ValByName("cSerie",cSerie)
		oHtml:ValByName("cEmissao",dtoc(dDEmissao))
	
		oHtml:ValByName("cRAZSocial",SM0->M0_NOMECOM)
		oHtml:ValByName("cCNPJ",SubStr(SM0->M0_CGC,1,2)+"."+SubStr(SM0->M0_CGC,3,3)+"."+SubStr(SM0->M0_CGC,6,3)+"/"+SubStr(SM0->M0_CGC,9,4)+"-"+SubStr(SM0->M0_CGC,13,2))
					
		oHtml:ValByName("cFornece",cA100For+"-"+cLoja)
		oHtml:ValByName("cNomFor",Posicione("SA2",1,xFilial("SA2")+cA100For+cLoja,"A2_NOME"))
		oHtml:ValByName("cCNPJFor",SubStr(SA2->A2_CGC,1,2)+"."+SubStr(SA2->A2_CGC,3,3)+"."+SubStr(SA2->A2_CGC,6,3)+"/"+SubStr(SA2->A2_CGC,9,4)+"-"+SubStr(SA2->A2_CGC,13,2))

	//Ordena pelo Item do Erro
		aErro[i][2] := aSort(aErro[i][2],,,{|x,y| x[1] < y[1]})
		AADD(aMsgErro,cAssunto)
		AADD(aMsgErro,"-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
		
		For j := 1 to Len(aErro[i][2])
 	  		
			AAdd(oHtml:ValByName("nf.Item"),aErro[i][2][j][1])
			AAdd(oHtml:ValByName("nf.Prod"),aErro[i][2][j][2])
			AAdd(oHtml:ValByName("nf.Fabri"),aErro[i][2][j][4])
			AAdd(oHtml:ValByName("nf.CFOP"),cCFOP)
			AAdd(oHtml:ValByName("nf.Motiv"),aErro[i][2][j][3])
			AAdd(oHtml:ValByName("nf.grupcom"),aErro[i][2][j][5])
			AAdd(oHtml:ValByName("nf.codprf"),aErro[i][2][j][6])
			
			cItem  := "Item: " + PADR( SUBSTR(aErro[i][2][j][1],1,8) , 8  , " " )
			cProd  := "Prod: " + PADR( SUBSTR(aErro[i][2][j][2],1,24), 24 , " " )
			cFabr  := "Fabr: " + PADR( SUBSTR(aErro[i][2][j][4],1,26), 26 , " " )
			cCFOP1 := "CFOP: " + PADR( SUBSTR(cCFOP,1,10), 10 , " " )
			cComp  := "Comp: " + PADR( SUBSTR(aErro[i][2][j][5],1,13), 13 , " " )
			cCodF  := "CodF: " + PADR( SUBSTR(aErro[i][2][j][6],1,21), 21 , " " )
			cMotv  := "Motv: " + aErro[i][2][j][3]
		
			AADD(aMsgErro,"| " + cItem + "| " + cProd + "| "  + cFabr   + "| " + cCFOP1  + "| " + cComp  + "| " + cCodF + "| " + cMotv)	
			AADD(aMsgErro,"-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------")
						 	  		
		Next
		
		
		For k := 1 to len(aMsgErro)
		
		cMsg2 += aMsgErro[k] + CHR(13) + CHR(10)
		
		Next
		
 	 		                                              
		oHtml:SaveFile( cFileHTML )
		cMsg := WFLoadFile(cFileHTML)
		cMsg := StrTran(cMsg,chr(13),"")
		cMsg := StrTran(cMsg,chr(10),"")
  	
   		If  fUNNAME() $ "COMXCOL"
  	
  			Help( ,, 'Help',, cMsg2 , 1, 0 )
  		
	  	/*	//Caso exista o arquivo, apaga
			If File(cArquivo)
				FErase(cArquivo)
			Endif
	  	
	  		// Verifica se conseguiu abrir o arquivo 
			If !(nHdlArq := FCreate(cArquivo,0)) == -1
				
				Help( ,, 'Help',, cMsg2 , 1, 0 )
				FWrite(nHdlArq,cMsg)
			  	//Fecha o arquivo
				fclose(nHdlArq) 
				
			Endif*/
		
		End if		
		
		FreeObj(oHtml)
	
	//enviar email para o comprador
		SAJ->(Dbsetorder(1))
		If SAJ->(DbSeek(xFilial("SAJ")+aErro[i][1]))
		
			While SAJ->(!Eof()) .and. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+aErro[i][1]
		
				SY1->(Dbsetorder(3))
				If SY1->(DbSeek(xFilial("SY1")+SAJ->AJ_USER))

					cDestin := AllTrim(SY1->Y1_EMAIL)
			 	
					If !Empty(cDestin)

						u_EnvEmail(cDestin,cAssunto,cMsg)
				
					EndIf

				EndIf

				SAJ->(dbSkip())
			
			EndDo
        
		EndIf
  	
		If !Empty(cEmailOut)

			u_EnvEmail(cEmailOut,cAssunto,cMsg)
  	
		EndIf
	
	Next

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ fWorkFlow                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³ Envia Workflow para compradores com erros do relacionamento³±±
±±³          ³ do pedido                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AnalisCEST(aErro)
	Local nCol			:= 0
	Local cGrupTrb	:= ''
	Local nPosCod		:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD"})
	Local nPosItem	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_ITEM"})
	Local cCEST		:= ''
	Local cMsg			:= ''
	Local cCodPrf		:= ''
	Local cNCM			:= ''
	Local lRet			:= .t.
	
	Default aErro		:= {}
	
	SB1->(dbSetOrder(1))
	
		//Percorre os itens
	For nCol := 1 to Len(aCols)
			                                 
		If aCols[nCol][Len(aCols[nCol])]
			Loop
		EndIf

		If !SB1->(dbSeek(xFilial("SB1")+aCols[nCol][nPosCod]))
			Loop
		EndIf



		//Validação do Grupo de tributação do produto
		cGrupTrb := U_AjusGTrib(SB1->B1_COD, SB1->B1_POSIPI, , , cA100For, SB1->B1_ORIGEM)
		cCodPrf  := Alltrim(Posicione('SA5',1,xFilial("SA5")+cA100For+cLoja+aCols[nCol][nPosCod],'A5_CODPRF'))
		
		//Chamado 6009 - Service Desk
		IF cEmpAnt <> "03" 
				
			If AllTrim(cGrupTrb) <> AllTrim(SB1->B1_GRTRIB) 
				lRet := .f.
				cMsg := "O grupo de tributação do produto calculado ("+cGrupTrb+") é diferente do cadastrado ("+SB1->B1_GRTRIB+"), favor entrar em contato com a contabilidade."
				            
				aAdd(aErro,{SB1->B1_GRUPCOM,{{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,SB1->B1_FABRIC,SB1->B1_GRUPCOM,cCodPrf}}})
			EndIf
		
		End If
				
		//Analisa se o grupo de tributação exige o código CEST
		cCEST 	:= SB1->B1_CEST
		cNCM	:= SB1->B1_POSIPI
		
		If ! Empty(cNCM) .and. !Subs(AllTrim(SB1->B1_GRTRIB), 1, 3) $ '024/008/009/007' .and. Empty(cCEST)
		
			lRet := .f.
			cMsg := "O NCM está sem CEST. Para o grupo de tributação "+AllTrim(SB1->B1_GRTRIB)+" este campo é obrigatório. Favor entrar em contato com a contabilidade."
			            
			aAdd(aErro,{SB1->B1_GRUPCOM,{{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,SB1->B1_FABRIC,SB1->B1_GRUPCOM,cCodPrf}}})
		
		ElseIf ! Empty(cNCM) .and. Subs(AllTrim(SB1->B1_GRTRIB), 1, 3) $ '024/008/009' .and. ! Empty(cCEST)
		
			lRet := .f.
			cMsg := "O NCM não tem CEST. Para o grupo de tributação "+AllTrim(SB1->B1_GRTRIB)+" este campo não é obrigatório. Favor entrar em contato com a contabilidade."
			            
			aAdd(aErro,{SB1->B1_GRUPCOM,{{aCols[nCol][nPosItem],aCols[nCol][nPosCod],cMsg,SB1->B1_FABRIC,SB1->B1_GRUPCOM,cCodPrf}}})
		
		EndIf
		
	Next

Return lRet