#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VIXA063   ºAutor  ³Ihorran Milholi     º Data ³  09/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de conferencia via coletor de dados                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAWMS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function VIXA063(lRadioF,cStatRF)  

Local aAreaAnt	:= GetArea()
Local aAreaSDB	:= SDB->(GetArea())
Local lRet			:= .t.
Local cDocto		:= SDB->DB_DOC
Local cSerie		:= SDB->DB_SERIE
Local cOrigem		:= SDB->DB_ORIGEM
Local cServic		:= SDB->DB_SERVIC
Local cTarefa		:= SDB->DB_TAREFA
Local cAtivid		:= SDB->DB_ATIVID
Local cCliFor		:= SDB->DB_CLIFOR
Local cLoja		:= SDB->DB_LOJA
Local cRecHum		:= SDB->DB_RECHUM
Local cLocal		:= SDB->DB_LOCAL
Local cLoteAConf	:= Space(Len(SDB->DB_DOC))
Local cEndereco	:= Space(Len(SDB->DB_LOCALIZ))
Local cWmsUMI 	:= If(AllTrim(SuperGetMv('MV_WMSUMI',.F.,'0')) == '5','3',AllTrim(SuperGetMv('MV_WMSUMI',.F.,'0')))
Local lDigita		:= (SuperGetMV('MV_DLCOLET',.F.,'N') == 'N')
Local lWmsLote	:= SuperGetMv('MV_WMSLOTE',.F.,.F.)
Local cStatExec	:= SuperGetMV('MV_RFSTEXE',.F.,'1') //-- DB_STATUS indincando Atividade Executada

//Variaveis para controle do produto na conferencia
Local aRecSDB		:= {}
Local aPrdSYS		:= {}
Local aLoteSYS	:= {}
Local nPos			:= 0
Local nPos2		:= 0
Local nPosEti		:= 0
Local cProduto	:= ""
Local cDescPro	:= ""
Local cDescPr2	:= ""
Local nConver		:= 0
Local cNorma		:= ""
Local nLinha		:= 0
Local nQtde		:= 0
Local nQtdAvar	:= 0
Local cDscUM		:= ""
Local cPictQt		:= ""
Local cLoteCtl	:= ""
Local aEtBurra	:= {}
Local cEtBurra	:= ""
Local lRetrab		:= .f.
Local cIDOPera	:= ""
Local nQtdNorma	:= 0
Local nQtdNorma2	:= 0
Local cStage		:= ""
Local aAvarias	:= {}
Local cLote		:= Space(TamSx3("DB_LOTECTL")[1])
Local nQtdEnder	:= 0
Local lLiberEnd	:= .f.
Local nQtdeEti	:= 0
Local cIdMovto	:= ""
Local cServErro	:= AllTrim(GetNewPar("MV_YSRVERR","015"))   

Local nQtdConfNor	:= 0

Private cCadastro	:= 'Conferencia'

//Destrava Registros SDB travado pela rotina DLGV001
MsUnlockAll()

//-- Atribui a funcao de JA CONFERIDOS a combinacao de teclas <CTRL> + <Q>
VTSetKey(17,{|| VA063JaConf(cDocto,aPrdSYS)},'Ja Conferidos')

//-- Atribui a funcao de LIBEREAR ETIQUETA PARA ENDEREÇAMENTO a combinacao de teclas <CTRL> + <L>
VTSetKey(12,{|| VA063LibVol(cDocto,@aEtBurra,aRecSDB,@aPrdSYS)},'Liberar Volume')

//Verifica se é pos sivel inicia esta conferencia
lRet := VA063TravaReg(cServic,cDocto,cSerie,cCliFor,cLoja,cOrigem,cServic,cTarefa,cAtivid,@aRecSDB)

//Valida parametro MV_WMSUMI
If lRet .and. !(cWmsUMI $ '0ú1ú2ú3ú4')
	DLVTAviso('VIXA063','Parametro MV_WMSUMI incorreto...')
	lRet := .F.
	RestArea(aAreaSDB)
	RestArea(aAreaAnt)
EndIf

//-- Indica ao operador o endereco de origem da conferencia
If lRet
                         
	DLVTCabec(,.F.,.F.,.T.)
	DLVEndereco(0,0,SDB->DB_LOCALIZ,SDB->DB_LOCAL,,,'Va para o Endereco')
	
	lRet := VA063ESC(aRecSDB)
	
EndIf

//Confirma o endereço de origem
If lRet

	While lRet .and. Empty(cEndereco)
			
		DLVTCabec(,.F.,.F.,.T.)
		@ 02,00 VTSay PadR('Endereco',VTMaxCol())
		@ 03,00 VTSay PadR(SDB->DB_LOCALIZ,VTMaxCol())
		@ 05,00 VTSay PadR('Confirme !',VTMaxCol())
		@ 06,00 VTGet cEndereco Pict '@!' Valid VA063End(SDB->DB_LOCALIZ,@cEndereco,cLocal)
		VTRead
		
		lRet := VA063ESC(aRecSDB,"C",@cEndereco)

	EndDo
				
EndIf

//Confirma o codigo do lote de conferencia ou de retrabalho
If lRet

	While lRet .and. Empty(cLoteAConf)
	
		DLVTCabec(,.F.,.F.,.T.)
		@ 01,00 VTSay PadR('LOTE '+SDB->DB_DOC,VTMaxCol())
		@ 02,00 VTGet cLoteAConf Picture '@!' Valid(iif(cLoteAConf==SDB->DB_DOC,.t.,.f.))
		VTRead
		
		lRet := VA063ESC(aRecSDB,"C",@cLoteAConf)
	
	EndDo
			
EndIf

//Inicia a conferencia da mercadoria
If lRet
	
	VtAlert('Aguarde... Contando produtos.',cCadastro,.T.,1000,3)
	
	For i := 1 to Len(aRecSDB)
		
		//Seta no registro a conferir
		SDB->(dbGoTo(aRecSDB[i][2]))
		
		//Trava registro para mudanças em outros processos
		If SoftLock("SDB")
                                                                        
			If lWmsLote .And. Rastro(cProduto)

				nPos := aScan(aPrdSYS,{|x| x[1] == SDB->DB_PRODUTO .and. x[2] == SDB->DB_LOTECTL})
			   	cLote:= SDB->DB_LOTECTL
			    
			Else
			                                                                                        
				nPos := aScan(aPrdSYS,{|x| x[1] == SDB->DB_PRODUTO})
			   	cLote:= Space(TamSx3("DB_LOTECTL")[1])
			    			
			EndIf
			
			If nPos == 0

				//-- Inclui produto no array aTotPrdSY
				aAdd(aPrdSYS,{SDB->DB_PRODUTO,cLote,SDB->DB_QUANT,SDB->DB_QTDLID,SDB->DB_YQTAVAR,SDB->DB_YQTLIBE,{SDB->(Recno())}})
			     
			    nPos := Len(aPrdSYS)
			           
			Else
			   
				aPrdSYS[nPos][3] += SDB->DB_QUANT                                              
				aPrdSYS[nPos][4] += SDB->DB_QTDLID
				aPrdSYS[nPos][5] += SDB->DB_YQTAVAR
				aPrdSYS[nPos][6] += SDB->DB_YQTLIBE
				
				aAdd(aPrdSYS[nPos][7],SDB->(Recno()))
					
			EndIf
			
			//-- Inclui lote no array aLoteSYS, para validacao apos a digitacao do lote
			If !Empty(SDB->DB_LOTECTL)
				aAdd(aLoteSYS,{SDB->DB_PRODUTO,SDB->DB_LOTECTL})
			EndIf
							           
			SZS->(dbSetOrder(2))
			If SZS->(dbSeek(xFilial("SZS")+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA+SDB->DB_ORIGEM+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_LOTECTL+SDB->DB_NUMLOTE))
						
				While SZS->(!Eof()) .and. 	SZS->ZS_FILIAL+SZS->ZS_DOC+SZS->ZS_SERIE+SZS->ZS_CLIFOR+SZS->ZS_LOJA+SZS->ZS_ORIGEM+SZS->ZS_PROD+SZS->ZS_LOCAL+SZS->ZS_LOTECTL+SZS->ZS_NUMLOTE == ;
											xFilial("SZS")+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA+SDB->DB_ORIGEM+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_LOTECTL+SDB->DB_NUMLOTE
			            
					If SZS->ZS_STATUS == "1"
											
						//Inclui registros no vetor de controle de etiquetas
						//lRetrab := iif(!Empty(Posicione("SB5",1,xFilial("SB5")+SZS->ZS_PROD,"B5_YRETRAB")) .and. SDB->DB_ORIGEM == "Z54",.t.,.f.)
						lRetrab := .f.
						nPosEti := aScan(aEtBurra,{|x| x[1] == SZS->ZS_CODIGO})  
						cStage	:= VA063GetStage(SZS->ZS_IDOPERA)
                                           
						If !Empty(cStage)
						
							//aPrdSYS[nPos][6] += SZS->ZS_QUANT
    
						EndIf
						
						If nPosEti == 0
						
							aAdd(aEtBurra,{SZS->ZS_CODIGO,cStage,lRetrab,{}})
							    
							nPosEti := Len(aEtBurra)
							
						EndIf
	                        
						//Inclui registros no vetor..
						If aScan(aEtBurra[nPosEti][4],{|x| x[1] == SZS->ZS_PROD}) == 0
						
							aAdd(aEtBurra[nPosEti][4],{SZS->ZS_PROD,SZS->ZS_QUANT,SZS->ZS_IDOPERA})
						
						EndIf												

					EndIf
					                   
					SZS->(dbSkip())
				
				EndDo		

 			EndIf
 			
		Else
			
			//-- Destrava os Registros Utilizados
			dbSelectArea("SDB")
			MaDestrava(aRecSDB)
			
			//Caso não consiga travar o registro o sistema deverá
			//sair da conferencia por segurança
			VA063Abandona(aRecSDB)
			
			lRet := .f.
			
			VtAlert('Houve um erro ao selecionar os produtos para conferencia',cCadastro,.T.,1000,3)
			
		EndIf
		
	Next
	
	If lRet
		
		//-- Inicio da contagem de produtos
		While lRet
			
			If	lDigita
				cProduto := Space(Len(SDB->DB_PRODUTO))
			Else
				If Len(SB1->B1_CODBAR) > 48
					cProduto := Space(Len(SB1->B1_CODBAR))
				Else
					cProduto := Space(48) //-- Tamanho minimo da Etiqueta
				EndIf
			EndIf
			
			//Apaga valores das variaveis
			cDescPro	:= ""
			cDescPr2	:= ""
			cNorma		:= ""
			nConver		:= 0
			nQtde		:= 0
			nQtdAvar	:= 0
			cDscUM		:= ""
			cPictQt		:= ""
			cLoteCtl	:= Space(TamSx3("DB_LOTECTL")[1])
			cEtBurra	:= Space(TamSx3("ZS_CODIGO")[1]+1)
			lRetrab		:= .f.
			cIDOPera	:= ""
			cEtSugest	:= ""
			cStage		:= ""
			lLiberEnd	:= .f.
			cIdMovto	:= ""
			nQtdNorma	:= 0
			nQtdConfNor	:= 0
			nQtdNorma2	:= 0 
						
			//-- Escolha do Produto a ser Conferido
			DLVTCabec(,.F.,.F.,.T.)
			@ 01,00 VTSay PadR('Produto',VTMaxCol())
			@ 02,00 VTGet cProduto Picture '@!' Valid VA063Prd(aPrdSYS,@cProduto,@cDescPro,@cDescPr2,@nConver,@cNorma,@cDscUM,@cPictQt,@cLoteCtl,@nQtdNorma,@nQtdNorma2,@lRetrab,@cIDOPera,@cStage,@cIdMovto)
			VTRead

			lRet := VA063ESC(aRecSDB,"C",@cProduto)
			
			If lRet .and. Empty(cProduto)
				Loop			
			EndIf
			
			If	lRet .And. lWmsLote .And. Rastro(cProduto) .And. aScan(aLoteSYS,{|x| x[1] == cProduto}) > 0
				
				@ 04,00 VTSay PadR('Lote',VTMaxCol())
				@ 05,00 VTGet cLoteCtl Picture PesqPict('SDB','DB_LOTECTL') When Empty(cLoteCtl) Valid VA063Lot(aLoteSYS,cProduto,@cLoteCtl)
				VTRead
				
				lRet := VA063ESC(aRecSDB,"C",@cLoteCtl)

				If lRet .and. Empty(cLoteCtl)
					Loop			
				EndIf

			EndIf
                
			If lRet
			
		   		If lRetrab
		
					nPos := aSCan(aEtBurra,{|x| x[3] == lRetrab})
		
					If nPos > 0
		
						cEtSugest := Alltrim(aEtBurra[nPos][1])						
		
					EndIf
		
				ElseIf nQtdNorma == 0
	
					For i := 1 to Len(aEtBurra)
		
						nPos := aSCan(aEtBurra[i][4],{|x| x[1] == cProduto})
	
						If nPos > 0
					                    
							cEtSugest := Alltrim(aEtBurra[i][1])					
							Exit
									
						EndIf
							
					Next						
						
				ElseIf nQtdNorma > 0 .and. Empty(cStage)
							                                                 
					For i := 1 to Len(aEtBurra)
		                                                                                                                   
						If Empty(aEtBurra[i][2])
								
							nPos := aSCan(aEtBurra[i][4],{|x| x[1] == cProduto .and. x[2] < nQtdNorma .and. x[3] == cIdOpera})
		
							If nPos > 0
						                    
								cEtSugest := Alltrim(aEtBurra[i][1])	
								nQtdConfNor := aEtBurra[i][4][nPos][2]
								Exit
										
							EndIf
									
						EndIf
														
					Next						
		
				Else
							
					nPos := aSCan(aEtBurra,{|x| x[2] == cStage})
								
					If nPos > 0
		                    
						cEtSugest 	:= Alltrim(aEtBurra[nPos][1])	 						
						nPos2		:= aSCan(aEtBurra[nPos][4],{|x| x[1] == cProduto .and. x[2] < nQtdNorma .and. x[3] == cIdOpera})
		
						If nPos2 > 0
						                    
							nQtdConfNor := aEtBurra[nPos][4][nPos2][2]

						EndIf						
						
					EndIf					
					
				EndIf					
					
				If !Empty(cEtSugest)
					
					DLVTCabec('Associe a Etiqueta',.F.,.F.,.T.)
					@ 01, 00 VTSay PadR(cProduto	,VTMaxCol())
					@ 02, 00 VTSay PadR('Etiqueta'	,VTMaxCol())
					@ 03, 00 VTSay PadR(cEtSugest	,VTMaxCol())
					@ 05, 00 VTSay PadR('Confirme!'	,VTMaxCol())
					@ 06, 00 VTGet cEtBurra Pict '@!' Valid VA063EtBurra(1,@cEtBurra,aEtBurra,cEtSugest)
					VTRead 
					
				Else
								
					//-- Escolha do Produto a ser Conferido
					DLVTCabec(,.F.,.F.,.T.)
					@ 01,00 VTSay PadR('Etiqueta Burra',VTMaxCol())
					@ 02,00 VTGet cEtBurra Picture "@!" Valid VA063EtBurra(1,@cEtBurra,aEtBurra,cEtSugest)
					VTRead
				
				EndIf
                    
    			lRet := VA063ESC(aRecSDB,"C",@cEtBurra)
				
				If lRet .and. Empty(cEtBurra)
					Loop			
				EndIf

			EndIf

			If lRet

				//-- Exibe informações para conferencia
				nLinha := 0

				DLVTCabec(,.F.,.F.,.T.)

				nLinha++; @ nLinha,00 VTSay PadR('Cod.:'+AllTrim(cProduto),VTMaxCol())
				nLinha++; @ nLinha,00 VTSay PadR('Desc:'+AllTrim(cDescPro),VTMaxCol())

				If !Empty(cDescPr2)
					nLinha++; @ nLinha,00 VTSay PadR(cDescPr2,VTMaxCol())
				EndIf
				
				If nQtdNorma <> nQtdNorma2				
				
					If lWmsLote .And. Rastro(cProduto)

						nPos := aScan(aPrdSYS,{|x| x[1] == cProduto .and. x[2] == cLoteCtl})
	
					Else
	                                                                                        
						nPos := aScan(aPrdSYS,{|x| x[1] == cProduto})
					
					EndIf

					If aPrdSYS[nPos][4] <  nQtdNorma

						nLinha++; @ nLinha,00 VTSay PadR("Fracionado: "+AllTrim(Transform(nQtdNorma,PesqPict('SDB','DB_QUANT'))),VTMaxCol())

					EndIf
			
				EndIf
						
				nLinha++; @ nLinha,00 VTSay PadR('Emb.:'+AllTrim(cDscUM)+" com "+AllTrim(Transform(nConver,PesqPict('SB1','B1_CONV'))),VTMaxCol())
				nLinha++; @ nLinha,00 VTSay PadR('Norm:'+AllTrim(cNorma),VTMaxCol())
				nLinha++; @ nLinha,00 VTSay PadR('Qtde '+cDscUM,VTMaxCol())
				nLinha++; @ nLinha,00 VTGet nQtde Picture cPictQt Valid VA063Qtd(@nQtde,nConver,cProduto,cLoteCtl,aPrdSYS,@nQtdNorma,cStage,cIDOPera,nQtdConfNor)
				VTRead
				
				lRet := VA063ESC(aRecSDB,"N",@nQtde)

				If lRet .and. nQtde == 0
					Loop			
				EndIf
								
				If lRet
					
					If cOrigem == "Z54"
										
						//-- Escolha do Produto a ser Conferido
						DLVTCabec(,.F.,.F.,.T.)
						@ 01,00 VTSay PadR('Qtde '+cDscUM+' Avariada',VTMaxCol())
						@ 02,00 VTGet nQtdAvar Picture cPictQt Valid VA063AvarValid(@nQtdAvar,nQtde,aRecSDB)
						VTRead

					EndIf
					
				EndIf
				
				If lRet
                                                 
					//Transforma as quantidades em multiplos devido a embalagem
					nQtde		:= nQtde*nConver
					nQtdAvar	:= nQtdAvar*nConver
					
					//Se o produto for retrabalho poderá ser aglutinado em apenas uma etiqueta
					//Se o produto for pulmão só poderá ter um produto na etique e esta não poderá ultrapassar a norma
					//Se o produto for stage a etiqueta poderá ser aglutina podem entre estruturas fisicas 
					//Se não tiver seq. de abastecimento o produto poderá ter mais de uma etiqueta porem não poderá ser aglutinado a outro produto
					  
					If nQtde == nQtdAvar
					
						cEtSugest := ""
						
					EndIf					
					
				EndIf                   
				
				If lRet                      
									           
					If !Empty(cEtBurra)
					
						//Inclui registros no vetor de controle de etiquetas
						nPosEti := aScan(aEtBurra,{|x| x[1] == cEtBurra})
						
						If nPosEti == 0
						
							aAdd(aEtBurra,{Alltrim(cEtBurra),cStage,lRetrab,{}}) 
							    
							nPosEti := Len(aEtBurra)
							
						EndIf
	                        
						//Inclui registros no vetor
						nPos := aScan(aEtBurra[nPosEti][4],{|x| x[1] == cProduto .and. x[3] == cIDOpera})
																		
						If nPos == 0
							aAdd(aEtBurra[nPosEti][4],{cProduto,nQtde-nQtdAvar,cIDOpera})
						Else
							aEtBurra[nPosEti][4][nPos][2] += nQtde-nQtdAvar
						EndIf												

					EndIf
					                
     				//Posiciona no vetor dos produtos em conferencia
					nPos := aScan(aPrdSYS,{|x| x[1] == cProduto .and. x[2] == cLoteCtl})
					
					aPrdSYS[nPos][4] += nQtde
					aPrdSYS[nPos][5] += nQtdAvar
										
					For z := 1 to Len(aPrdSYS[nPos][7])

						SDB->(dbGoTo(aPrdSYS[nPos][7][z]))
						
						nQtdeEti := 0
						
						If nQtde > 0
						
							If SDB->DB_QUANT > SDB->DB_QTDLID 
								
								If nQtde > SDB->DB_QUANT-SDB->DB_QTDLID
	
									nQtde 		-= SDB->DB_QUANT-SDB->DB_QTDLID
									nQtdeEti	:= SDB->DB_QUANT-SDB->DB_QTDLID
										
									RecLock("SDB",.F.)
									SDB->DB_QTDLID += SDB->DB_QUANT-SDB->DB_QTDLID
									SDB->(msUnlock())                           
																		
								Else
	
									RecLock("SDB",.F.)
									SDB->DB_QTDLID += nQtde
									SDB->(msUnlock())
								            
									nQtdeEti:= nQtde
									nQtde 	:= 0								
									
								EndIf
								
							EndIf
	
						EndIf

						If nQtdAvar > 0
						
							If SDB->DB_QUANT > SDB->DB_YQTAVAR

								If nQtdAvar > SDB->DB_QUANT-SDB->DB_YQTAVAR

									nQtdAvar -= SDB->DB_QUANT-SDB->DB_YQTAVAR

									RecLock("SDB",.f.)
									SDB->DB_YQTAVAR += SDB->DB_QUANT-SDB->DB_YQTAVAR
									SDB->(msUnlock())

									nQtdeEti-= nQtdAvar							

								Else

									RecLock("SDB",.f.)
									SDB->DB_YQTAVAR += nQtdAvar
									SDB->(msUnlock())

									nQtdeEti -= nQtdAvar
									nQtdAvar := 0								

								EndIf
								
							EndIf

						EndIf
                          
                      // Verifica se a conf
                     If ( SDB->DB_QUANT -  SDB->DB_QTDLID ) == 0
                     
                     	DLVTCabec("CONFERENCIA TOTAL",.F.,.F.,.T.)
							@ 01,00 VTSay 'PRODUTO: ' 
							@ 02,00 VTSay SDB->DB_PRODUTO
							DLVTRodaPe()
                     End If                           
                     
						//Indice da tabela SZS
						//ZS_FILIAL+ZS_CODIGO+ZS_DOC+ZS_SERIE+ZS_CLIFOR+ZS_LOJA+ZS_ORIGEM+ZS_PROD+ZS_LOCAL+ZS_LOTECTL+ZS_NUMLOTE
                         
						IF !Empty(cEtBurra)
                        
							//Inclui os registros para etiqueta burra
							SZS->(dbSetOrder(3))
							If SZS->(dbSeek(xFilial("SZS")+cEtBurra))
		
								RecLock("SZS",.F.)
							
							//Procura itens para aglutinar		                    
							//ElseIf SZS->(dbSeek(xFilial("SZS")+cEtBurra+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA+SDB->DB_ORIGEM+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_LOTECTL+SDB->DB_NUMLOTE))
							ElseIf SZS->(dbSeek(xFilial("SZS")+cEtBurra+SDB->DB_NUMSEQ+cIDOPera+cIdMovto+SDB->DB_IDDCF))
							                      
								RecLock("SZS",.F.)
							
							Else
							                      
								RecLock("SZS",.T.)
								
							EndIf
						   
							//Inclui os registros de etiqueta burra	                    
							SZS->ZS_FILIAL	:= xFilial("SZS") 
							SZS->ZS_CODIGO	:= cEtBurra
							SZS->ZS_DOC   	:= SDB->DB_DOC
							SZS->ZS_SERIE  	:= SDB->DB_SERIE
							SZS->ZS_CLIFOR 	:= SDB->DB_CLIFOR
							SZS->ZS_LOJA   	:= SDB->DB_LOJA
							SZS->ZS_ORIGEM 	:= SDB->DB_ORIGEM
							SZS->ZS_PROD   	:= SDB->DB_PRODUTO
							SZS->ZS_LOTECTL	:= SDB->DB_LOTECTL
							SZS->ZS_NUMLOTE	:= SDB->DB_NUMLOTE
							SZS->ZS_QUANT		+= nQtdeEti
							SZS->ZS_STATUS	:= "1"
							SZS->ZS_LOCAL		:= SDB->DB_LOCAL
							SZS->ZS_NUMSEQ	:= SDB->DB_NUMSEQ
							SZS->ZS_IDDCF  	:= SDB->DB_IDDCF
							SZS->ZS_IDOPERA	:= cIDOPera
							SZS->ZS_IDMOVTO	:= cIdMovto
							SZS->(msUnLock())         
							
							//altera prioridade de convocacao de acordo com a data e hora de liberação da etiqueta burra
							u_VWMSPriorid(SDB->(Recno()),cIdMovto)
	                        
							//Verifica regras de pulmão para liberar o endereçamento
							If nQtdNorma > 0 .and. Empty(cStage) .and. !lRetrab
		
								If SZS->ZS_QUANT == nQtdNorma //.or. SDB->DB_QUANT == SDB->DB_QTDLID
									              
									aPrdSYS[nPos][6] += SZS->ZS_QUANT
									                  
				           		RecLock('SDB',.F.)
									SDB->DB_YQTLIBE += SZS->ZS_QUANT
									SDB->(MsUnLock())
	
									RecLock('SZS',.F.)
									SZS->ZS_STATUS := "2"
									SZS->(MsUnLock())   
									
									//Elimina a etiqueta do vetor de etiquetas
									nPosEti := aScan(aEtBurra,{|x| x[1] == cEtBurra})
									
									aDel(aEtBurra,nPosEti)	
									aSize(aEtBurra,Len(aEtBurra)-1)
		
								EndIf
	                        
							ElseIf nQtdNorma > 0 .and. !Empty(cStage)
							
								//aPrdSYS[nPos][6] := SDB->DB_QTDLID-SDB->DB_YQTAVAR-SDB->DB_YQTLIBE
									
		      				ElseIf nQtdNorma == 0
		      				
		      					If SDB->DB_SERVIC == cServErro .and. SDB->DB_QUANT == SDB->DB_QTDLID .and. SDB->DB_QUANT == SZS->ZS_QUANT

									aPrdSYS[nPos][6] := SDB->DB_QUANT
									                  
				           			RecLock('SDB',.F.)
									SDB->DB_YQTLIBE := SDB->DB_QUANT
									SDB->(MsUnLock())
	
									RecLock('SZS',.F.)
									SZS->ZS_STATUS := "2"
									SZS->(MsUnLock())   

		      						//cria serviço para endereçamento
									u_VA062CriaDCF(SDB->DB_QUANT)	    		
									
									//Elimina a etiqueta do vetor de etiquetas
									nPosEti := aScan(aEtBurra,{|x| x[1] == cEtBurra})
									
									aDel(aEtBurra,nPosEti)
									aSize(aEtBurra,Len(aEtBurra)-1)
		      					                                                     
								EndIf
										      						      				
		      				EndIf
						
						EndIf
	
						//Força a saida do FOR	                    
						If nQtde == 0 .and. nQtdAvar == 0
							Exit
						EndIf

					Next
      														
				EndIf
				
			EndIf
			
		EndDo
		
		//-- Destrava os Registros Utilizados
		dbSelectArea("SDB")
		MaDestrava(aRecSDB)
		
	EndIf
	
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VA063ESC  ºAutor  ³Ihorran Milholi     º Data ³  09/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o conferente ira abandonar a rotina TECLAR ESC  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAWMS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VA063ESC(aRecSDB,xTipo,xParam)

Local lRet 		:= .f.
Local nOpc		:= 0
Default xTipo 	:= "C"
Default xParam 	:= ""

//Verifica se o ultimo botão foi ESC
If	VTLastKey() == 27
	                          
	DLVTCabec(,.F.,.F.,.T.)
	@ 01,00 VTSay PadR('MENU CONFERENCIA',VTMaxCol())
	@ 03,00 VTSay PadR('1 - RETORNAR',VTMaxCol())
	@ 04,00 VTSay PadR('2 - FINALIZAR',VTMaxCol())
	@ 05,00 VTSay PadR('3 - TROCAR CONFERENCIA',VTMaxCol())
	@ 06,00 VTSay PadR('4 - ABANDONAR',VTMaxCol())
	@ 07,00 VTGet nOpc Picture "9" Valid (nOpc > 0 .and. nOpc < 5)
	VTRead
			
	Do Case 
	                                                             
		Case nOpc == 1
		    
		    lRet := .t.
		     
		    //Zera parametros digitados anteriormente 
			Do Case
				Case xTipo == "C"; xParam := Space(Len(xParam))
				Case xTipo == "N"; xParam := 0
			EndCase

		Case nOpc == 2; lRet := VA063FinConf(aRecSDB)
		
		Case nOpc == 3; VA063TrocaLote(aRecSDB,@lRet)
		
		Case nOpc == 4; VA063Abandona(aRecSDB,"000001",@lAbandona,@lRet)		
		
		OtherWise; lRet := .t.
		
	EndCase
	
Else
	
	lRet := .t.
	
EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VA063AbandºAutor  ³Ihorran Milholi     º Data ³  09/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o conferente ira abandonar a rotina TECLAR ESC  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAWMS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VA063Abandona(aRecSDB,cOcorr,lAbandona,lRet)

Local nCont		:= 0
Local cStatAExe	:= SuperGetMV('MV_RFSTAEX',.F.,'4') 	//-- DB_STATUS indincando Atividade A Executar
                                            
Default cOcorr		:= ""
Default lAbandona	:= .t.
Default lRet		:= .f.

If !Empty(cOcorr)

	//Seta o primeiro registro a conferir
	SDB->(dbGoTo(aRecSDB[1][2]))
			
	//Chama rotina para verificar a autorização do lider
	If u_VIXA065(SDB->DB_DOC,SDB->DB_ORIGEM,cOcorr)
		lAbandona 	:= .t.
		lRet		:= .f.
	Else
		lAbandona 	:= .f.
		lRet		:= .t.	                                     
	EndIf

EndIf

If lAbandona

	//Percorre os registros para verificar se já houve alguma contagem
	For i := 1 to Len(aRecSDB)
		
		//Seta no registro a conferir
		SDB->(dbGoTo(aRecSDB[i][2]))
		
		If SDB->DB_QTDLID > 0
			nCont++
		EndIf
		
	Next
	
	//Caso não tenha ocorrido nenhuma contagem libera o registro para outro conferente
	If nCont == 0
		
		For i := 1 to Len(aRecSDB)
			
			//Seta no registro a conferir
			SDB->(dbGoTo(aRecSDB[i][2]))
			
			RecLock('SDB',.F.)
			SDB->DB_RECHUM := ""
			SDB->DB_STATUS := cStatAExe
			SDB->DB_HRINI  := ""
			SDB->(msUnLock())
			
		Next
		
	EndIf

EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VA063TrocaºAutor  ³Ihorran Milholi     º Data ³  09/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida novo LOTE de conferencia                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAWMS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VA063TrocaLote(aRecSDB,lRet)

Local lRet 		:= .t.
Local cAlias	:= GetNextAlias()
Local cDocto	:= Space(Len(SDB->DB_DOC))

//Chama rotina para abandonar a conferencia que esta sendo executada
VA063Abandona(aRecSDB,"000002",,@lRet)

If !lRet
	//Chama tela para escolha do novo lote
	DLVTCabec(,.F.,.F.,.T.)
	@ 01,00 VTSay PadR("NOVO LOTE",VTMaxCol())
	@ 02,00 VTGet cDocto Picture '@!' Valid VA063ValTroca(@cDocto)
	VTRead
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VA063TrocaºAutor  ³Ihorran Milholi     º Data ³  09/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o conferente ira mudar de LOTE de conferencia   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAWMS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VA063ValTroca(cDocto)

Local lRet		:= .t.
Local cAlias	:= GetNextAlias()
Local cSerie	:= Space(Len(SDB->DB_SERIE))
Local cOrigem	:= SDB->DB_ORIGEM
Local cServic	:= SDB->DB_SERVIC
Local cTarefa	:= SDB->DB_TAREFA
Local cAtivid	:= SDB->DB_ATIVID
Local cCliFor	:= SDB->DB_CLIFOR
Local cLoja		:= SDB->DB_LOJA
Local cRecHum	:= __cUserID
Local lRadioF	:= (SuperGetMV('MV_RADIOF')=='S') 	//-- Como Default o parametro MV_RADIOF e verificado
Local cStatRF	:= '1' 								//-- Como Default a radio frequencia VAI gerar movimentos no SDB SEM atualizar estoque

//Verifica a existencia do documento para conferencia
//Query para recuperar todos os itens a executar conferencia
BeginSql Alias cAlias
	
	SELECT	TOP 1 SDB.R_E_C_N_O_ RECSDB

	FROM	%table:SDB% SDB

	WHERE	SDB.DB_FILIAL	= %xFilial:SDB%
		AND	SDB.DB_ESTORNO	= %Exp:''%
		AND	SDB.DB_ATUEST	= %Exp:'N'%
		AND	SDB.DB_DOC		= %Exp:cDocto%
		AND	SDB.DB_TAREFA	= %Exp:cTarefa%
		AND	SDB.DB_ATIVID	= %Exp:cAtivid%

		AND	(	SDB.DB_RECHUM	= %Exp:cRecHum%
			OR	SDB.DB_RECHUM	= %Exp:''%)
			
		AND	SDB.%NotDel%

EndSql

(cAlias)->(dbGoTop())

//Percorre todos os itens
If (cAlias)->(!Eof())
	
	//Seta no registro a conferir
	SDB->(dbGoTo((cAlias)->RECSDB))

	//Chama rotina de conferencia via coletor
	u_VIXA063(lRadioF,cStatRF)

Else

	lRet	:= .f.
	cDocto	:= Space(Len(SDB->DB_DOC))
	DLVTAviso('VA063ValTroca',"LOTE INCORRETO")

EndIf

//Elimina a area de trabalho
(cAlias)->(dbCloseArea())

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VA063FinC ºAutor  ³Ihorran Milholi     º Data ³  09/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para finalização da conferencia                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAWMS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VA063FinConf(aRecSDB)

Local i
Local j             

Local cStatExec	:= SuperGetMV('MV_RFSTEXE',.F.,'1') 	//-- DB_STATUS indincando Atividade Executada
Local cStatProb	:= SuperGetMV('MV_RFSTPRO',.F.,'2') 	//-- DB_STATUS indincando Atividade com Problemas   
Local cStatAuto	:= SuperGetMV('MV_RFSTAUT',.F.,'A')	//-- DB_STATUS indincando Atividade Automatica
Local cStatAExe	:= SuperGetMV('MV_RFSTAEX',.F.,'4') 	//-- DB_STATUS indincando Atividade A Executar

Local cOcorrFalta	:= AllTrim(SuperGetMV('MV_YOCOFAL',.F.,"0001"))
Local cOcorrAvar	:= AllTrim(SuperGetMV('MV_YOCOAVA',.F.,"0002"))    

Local cServErro	:= AllTrim(GetNewPar("MV_YSRVERR","015"))   
Local cTarefEnd	:= AllTrim(GetNewPar("MV_YTAREND","009"))   
Local cServEnd	:= AllTrim(GetNewPar("MV_YSRVEND","005"))

Local nQtdOcorr	:= 0
Local nQtdEnder	:= 0
Local cNumSeq		:= ""      
Local cIdMovto	:= ""
Local aEndFalta	:= {}
Local aExcecoes	:= {}
                                                             
Local cAlias		:= GetNextAlias()
Local cAliasSDB	:= GetNextAlias()
            
Local nPos			:= 0
Local lInc			:= .f.
Local nRecDC5 	:= 0   		
                                          
Local aTelaAnt	:= VTSave(00,00,VTMaxRow(),VTMaxCol())
Local cOcorr		:= "000005"
Local lRet			:= .t.

Private lMsErroAuto

//Percorre todos os registros para verificar se existe falta
//caso afirmativo pede autorização do superior
For i := 1 to Len(aRecSDB)
                          
	//Seta no registro a conferir
	SDB->(dbGoTo(aRecSDB[i][2]))

	If SDB->DB_QUANT > SDB->DB_QTDLID
			
		//Chama rotina para verificar a autorização do lider
		If u_VIXA065(SDB->DB_DOC,SDB->DB_ORIGEM,cOcorr)

			lRet := .t.
			Exit

		Else

			lRet := .f.
			
			Return .t.
			
		EndIf
		
	EndIf
	
Next

If lRet
	
	//Percorre todos os registros para analisar se esta OK
	For i := 1 to Len(aRecSDB)
	
		Begin Transaction
		
		//Seta no registro a conferir
		SDB->(dbGoTo(aRecSDB[i][2]))
		
		RecLock('SDB',.F.)
		SDB->DB_DATAFIM:= dDataBase
		SDB->DB_HRFIM  := Time()			
	
		If SDB->DB_QUANT == SDB->DB_QTDLID .and. SDB->DB_YQTAVAR == 0
		
			SDB->DB_STATUS := cStatExec
		
		Else
		
			SDB->DB_STATUS := cStatProb
			SDB->DB_ANOMAL := 'S'
	
		EndIf
		
		SDB->(MsUnLock())
		
		aNotasOrig := VA063GetNfs(AllTrim(SDB->DB_DOC),SDB->DB_PRODUTO,SDB->DB_LOTECTL,SDB->DB_NUMLOTE,SDB->DB_LOCAL)
														
		//Gera as acorrencias para reconferencia ou devolução de venda
		If SDB->DB_YQTAVAR > 0
			
			nQtdOcorr := SDB->DB_YQTAVAR		
				
			While nQtdOcorr <> 0
			
				RecLock("DCN",.T.)
				DCN->DCN_FILIAL	:= xFilial("DCN")
				DCN->DCN_NUMERO	:= GetSxENum("DCN","DCN_NUMERO") 
				DCN->DCN_OCORR	:= cOcorrAvar
				DCN->DCN_STATUS	:= "1"
				DCN->DCN_DTINI	:= dDataBase
				DCN->DCN_HRINI	:= Time()
				DCN->DCN_YLOTER	:= SDB->DB_DOC
				DCN->DCN_PROD		:= SDB->DB_PRODUTO
				DCN->DCN_LOCAL	:= SDB->DB_LOCAL
				DCN->DCN_LOTECT	:= SDB->DB_LOTECTL
				DCN->DCN_NUMLOT	:= SDB->DB_NUMLOTE
				
				If Len(aNotasOrig) > 0
				
					DCN->DCN_DOC		:= aNotasOrig[1][1]
					DCN->DCN_SERIE	:= aNotasOrig[1][2]
					DCN->DCN_CLIFOR	:= aNotasOrig[1][3]
					DCN->DCN_LOJA		:= aNotasOrig[1][4]
					DCN->DCN_NUMSEQ	:= aNotasOrig[1][6]
					DCN->DCN_ITEM		:= aNotasOrig[1][5]
						
					If aNotasOrig[1][7] >= nQtdOcorr	
									
						DCN->DCN_QUANT	:= nQtdOcorr				
					
						//Acerta saldo do vetor para proxima analise
						aNotasOrig[1][7]	-= nQtdOcorr
						nQtdOcorr			:= 0
					
					Else
				
						DCN->DCN_QUANT	:= aNotasOrig[1][7]				
						
						//Acerta saldo do vetor para proxima analise			
						nQtdOcorr			-= aNotasOrig[1][7]
						aNotasOrig[1][7]	:= 0				
				
					EndIf
					
				Else
	                                                   
					DCN->DCN_DOC		:= SDB->DB_DOC
					DCN->DCN_YLOTER	:= SDB->DB_DOC
					DCN->DCN_QUANT	:= nQtdOcorr				
					nQtdOcorr			:= 0
												
				EndIf
	
				DCN->(msUnLock())
					
				ConfirmSX8()
				                      
				If Len(aNotasOrig) > 0
							
					//Apaga registro do vetor caso tenha utilizado
					If aNotasOrig[1][7] == 0
						aDel(aNotasOrig,1)	
						aSize(aNotasOrig,Len(aNotasOrig)-1)
					EndIf
	
				EndIf
								
			EndDo	
				
		EndIf
		
		If SDB->DB_QUANT-SDB->DB_QTDLID > 0
			
			nQtdOcorr := SDB->DB_QUANT-SDB->DB_QTDLID
				
			While nQtdOcorr <> 0
			
				RecLock("DCN",.T.)
				DCN->DCN_FILIAL	:= xFilial("DCN")
				DCN->DCN_NUMERO	:= GetSxENum("DCN","DCN_NUMERO") 
				DCN->DCN_OCORR	:= cOcorrFalta
				DCN->DCN_STATUS	:= "1"
				DCN->DCN_DTINI	:= dDataBase
				DCN->DCN_HRINI	:= Time()
				DCN->DCN_YLOTER	:= SDB->DB_DOC
				DCN->DCN_PROD		:= SDB->DB_PRODUTO
				DCN->DCN_LOCAL	:= SDB->DB_LOCAL
				DCN->DCN_LOTECT	:= SDB->DB_LOTECTL
				DCN->DCN_NUMLOT	:= SDB->DB_NUMLOTE
				
				If Len(aNotasOrig) > 0
				
					DCN->DCN_DOC		:= aNotasOrig[1][1]
					DCN->DCN_SERIE	:= aNotasOrig[1][2]
					DCN->DCN_CLIFOR	:= aNotasOrig[1][3]
					DCN->DCN_LOJA		:= aNotasOrig[1][4]
					DCN->DCN_ITEM		:= aNotasOrig[1][5]
					DCN->DCN_NUMSEQ	:= aNotasOrig[1][6]
									
					If aNotasOrig[1][7] >= nQtdOcorr
										
						DCN->DCN_QUANT	:= nQtdOcorr				
						
						//Acerta saldo do vetor para proxima analise
						aNotasOrig[1][7]	-= nQtdOcorr
						nQtdOcorr			:= 0
		
					Else
					
						DCN->DCN_QUANT	:= aNotasOrig[1][7]				
						
						//Acerta saldo do vetor para proxima analise			
						nQtdOcorr			-= aNotasOrig[1][7]
						aNotasOrig[1][7]	:= 0				
					
					EndIf
	
				Else                                                
	
					DCN->DCN_DOC		:= SDB->DB_DOC
					DCN->DCN_YLOTER	:= SDB->DB_DOC			
					DCN->DCN_QUANT	:= nQtdOcorr				
					nQtdOcorr			:= 0
									
				EndIf
					
				DCN->(msUnLock())
					
				ConfirmSX8()
				                      
				If Len(aNotasOrig) > 0
							
					//Apaga registro do vetor caso tenha utilizado
					If aNotasOrig[1][7] == 0
						aDel(aNotasOrig,1)	
						aSize(aNotasOrig,Len(aNotasOrig)-1)
					EndIf
				
				EndIf
					
			EndDo	
				
		EndIf
		
		//Quantidade a endereçar
		nQtdEnder := SDB->DB_QTDLID-SDB->DB_YQTAVAR-SDB->DB_YQTLIBE
		aEndFalta := {}
		 
		RecLock('SDB',.F.)
		SDB->DB_YQTLIBE += nQtdEnder
		SDB->(MsUnLock())	
		
		//Chamada para criação da função de endereçamento caso tenha erro de cadastro
		If SDB->DB_SERVIC == cServErro
	 
	 		//Libera as etiquetas relacionadas a este produto
			SZS->(dbSetOrder(2))
			If SZS->(dbSeek(xFilial("SZS")+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA+SDB->DB_ORIGEM+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_LOTECTL+SDB->DB_NUMLOTE))
						
				While SZS->(!Eof()) .and. 	SZS->ZS_FILIAL+SZS->ZS_DOC+SZS->ZS_SERIE+SZS->ZS_CLIFOR+SZS->ZS_LOJA+SZS->ZS_ORIGEM+SZS->ZS_PROD+SZS->ZS_LOCAL+SZS->ZS_LOTECTL+SZS->ZS_NUMLOTE == ;
											xFilial("SZS")+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA+SDB->DB_ORIGEM+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_LOTECTL+SDB->DB_NUMLOTE
	                
					If Empty(SZS->ZS_IDOPERA) .and. SZS->ZS_STATUS == "1"
					
						RecLock('SZS',.F.)
						SZS->ZS_STATUS := "2"
						SZS->(MsUnLock())
		
						If SZS->ZS_QUANT == 0						
						
							//COMO NÃO CRIA DCF, UTILIZA O ID JA EXISTENTE
							cIDDCF := SZS->ZS_IDDCF
							
						Else
						
							//cria serviço para endereçamento
							cIDDCF := u_VA062CriaDCF(SZS->ZS_QUANT)
							
						EndIf
						
						If SDB->DB_QUANT <> SZS->ZS_QUANT
	
							nPos := aScan(aEndFalta,{|x|	x[01] == SDB->DB_SERVIC		.and.;
															 	x[02] == SDB->DB_PRODUTO		.and.;
																x[03] == SDB->DB_LOCAL		.and.;
																x[04] == SDB->DB_NUMSEQ		.and.;
																x[05] == SDB->DB_DOC			.and.;
																x[06] == SDB->DB_SERIE		.and.;
																x[07] == SDB->DB_CLIFOR		.and.;
																x[08] == SDB->DB_LOJA		.and.;
																x[09] == SDB->DB_LOCALIZ		.and.;
																x[10] == SDB->DB_ORIGEM 		.and.;
																x[12] == cIDDCF})
	
	
							If nPos == 0
						
								aAdd(aEndFalta,{	SDB->DB_SERVIC,;
													SDB->DB_PRODUTO,;
													SDB->DB_LOCAL,;
													SDB->DB_NUMSEQ,;
													SDB->DB_DOC,;
													SDB->DB_SERIE,;
													SDB->DB_CLIFOR,;
													SDB->DB_LOJA,;
													SDB->DB_LOCALIZ,;
													SDB->DB_ORIGEM,;
													SDB->DB_QUANT-SZS->ZS_QUANT,;
													cIDDCF})				

							Else
						  
								aEndFalta[nPos][11] += SDB->DB_QUANT-SZS->ZS_QUANT
							
							EndIf						
						
						EndIf
					
					EndIf
					                                         
					SZS->(dbSkip())
					
				EndDo
			
			Else

				nPos := aScan(aEndFalta,{|x|	x[01] == SDB->DB_SERVIC		.and.;
												 	x[02] == SDB->DB_PRODUTO		.and.;
													x[03] == SDB->DB_LOCAL		.and.;
													x[04] == SDB->DB_NUMSEQ		.and.;
													x[05] == SDB->DB_DOC			.and.;
													x[06] == SDB->DB_SERIE		.and.;
													x[07] == SDB->DB_CLIFOR		.and.;
													x[08] == SDB->DB_LOJA		.and.;
													x[09] == SDB->DB_LOCALIZ		.and.;
													x[10] == SDB->DB_ORIGEM 		.and.;
													x[12] == SDB->DB_IDDCF})

				If nPos == 0
							
					aAdd(aEndFalta,{	SDB->DB_SERVIC,;
										SDB->DB_PRODUTO,;
										SDB->DB_LOCAL,;
										SDB->DB_NUMSEQ,;
										SDB->DB_DOC,;
										SDB->DB_SERIE,;
										SDB->DB_CLIFOR,;
										SDB->DB_LOJA,;
										SDB->DB_LOCALIZ,;
										SDB->DB_ORIGEM,;
										SDB->DB_QUANT,;
										SDB->DB_IDDCF})	

				Else
					  
					aEndFalta[nPos][11] += SDB->DB_QUANT
						
				EndIf
				
			EndIf
	                  
		//Acerta os endereçamento com quantidade menor devido a falta e avaria e libera as etiquetas para endereçamento	
		Else //If SDB->DB_YQTAVAR > 0 .or. SDB->DB_QUANT-SDB->DB_QTDLID > 0
		    
			//Verifica o ultima atividade de endereçamento para diminuir a quantidade do mesmo 
			BeginSql Alias cAlias
		
			SELECT	SDB.R_E_C_N_O_ SDBREC
				,	SDB.DB_IDOPERA 
				, 	SDB.DB_QUANT
				, 	ISNULL(SZS.ZS_QUANT,%Exp:0%) ZS_QUANT
				,	ISNULL(SZS.R_E_C_N_O_,%Exp:0%) SZSREC
		
			FROM	%table:SDB% SDB                           
			
					LEFT JOIN %table:SZS% SZS ON	SZS.%NotDel%
												AND SZS.ZS_FILIAL	= %xFilial:SZS%
												AND SZS.ZS_DOC		= SDB.DB_DOC
												AND SZS.ZS_SERIE	= SDB.DB_SERIE
												AND SZS.ZS_CLIFOR	= SDB.DB_CLIFOR
												AND SZS.ZS_LOJA		= SDB.DB_LOJA
												AND SZS.ZS_ORIGEM	= SDB.DB_ORIGEM
												AND SZS.ZS_PROD		= SDB.DB_PRODUTO
												AND SZS.ZS_LOTECTL	= SDB.DB_LOTECTL
												AND SZS.ZS_NUMLOTE	= SDB.DB_NUMLOTE
												AND SZS.ZS_LOCAL	= SDB.DB_LOCAL
												AND SZS.ZS_NUMSEQ	= SDB.DB_NUMSEQ
												AND SZS.ZS_IDOPERA	= SDB.DB_IDOPERA
												AND SZS.ZS_IDMOVTO	= SDB.DB_IDMOVTO
												AND SZS.ZS_IDDCF	= SDB.DB_IDDCF
												
			WHERE	SDB.%NotDel%    
				AND	SDB.DB_FILIAL	= %xFilial:SDB%
				AND SDB.DB_STATUS	= %Exp:cStatAExe%
				AND SDB.DB_ESTORNO	= %Exp:''%
				AND SDB.DB_ATUEST	= %Exp:'N'%
				AND SDB.DB_TAREFA	= %Exp:cTarefEnd%
				AND SDB.DB_ORDATIV	= %Exp:'01'%
				AND SDB.DB_SERVIC	= %Exp:SDB->DB_SERVIC%
				AND SDB.DB_DOC		= %Exp:SDB->DB_DOC%
				AND SDB.DB_SERIE	= %Exp:SDB->DB_SERIE%
				AND SDB.DB_CLIFOR	= %Exp:SDB->DB_CLIFOR%
				AND SDB.DB_LOJA		= %Exp:SDB->DB_LOJA%
				AND SDB.DB_PRODUTO	= %Exp:SDB->DB_PRODUTO%
				AND SDB.DB_ORIGEM	= %Exp:SDB->DB_ORIGEM%
				AND SDB.DB_LOCAL 	= %Exp:SDB->DB_LOCAL%
				AND SDB.DB_LOTECTL	= %Exp:SDB->DB_LOTECTL%
				AND SDB.DB_NUMLOTE	= %Exp:SDB->DB_NUMLOTE%
			
			EndSql
		
	       (cAlias)->(dbGoTop())
			While (cAlias)->(!Eof())
					              
				If (cAlias)->DB_QUANT <> (cAlias)->ZS_QUANT
				                                             
					SDB->(dbGoTo((cAlias)->SDBREC))  
	
					//Cria Vetor com produtos a serem endereçados na doca de conferencia
					//produtos falta e avaria
	
					nPos := aScan(aEndFalta,{|x|	x[01] == SDB->DB_SERVIC	.and.;
												 	x[02] == SDB->DB_PRODUTO		.and.;
													x[03] == SDB->DB_LOCAL		.and.;
													x[04] == SDB->DB_NUMSEQ		.and.;
													x[05] == SDB->DB_DOC			.and.;
													x[06] == SDB->DB_SERIE		.and.;
													x[07] == SDB->DB_CLIFOR		.and.;
													x[08] == SDB->DB_LOJA		.and.;
													x[09] == SDB->DB_LOCALIZ		.and.;
													x[10] == SDB->DB_ORIGEM 		.and.;
													x[12] == SDB->DB_IDDCF})
	
					If nPos == 0
					
						aAdd(aEndFalta,{	SDB->DB_SERVIC,;
											SDB->DB_PRODUTO,;
											SDB->DB_LOCAL,;
											SDB->DB_NUMSEQ,;
											SDB->DB_DOC,;
											SDB->DB_SERIE,;
											SDB->DB_CLIFOR,;
											SDB->DB_LOJA,;
											SDB->DB_LOCALIZ,;
											SDB->DB_ORIGEM,;
											SDB->DB_QUANT-(cAlias)->ZS_QUANT,;
											SDB->DB_IDDCF})
	                
					Else
					  
						aEndFalta[nPos][11] += SDB->DB_QUANT-(cAlias)->ZS_QUANT
						
					EndIf
					
			   		//Verifica totas atividade de endereçamento para diminuir a quantidade do mesmo 
					BeginSql Alias cAliasSDB
	
					SELECT	SDB.R_E_C_N_O_	SDBREC
					FROM	%table:SDB%	SDB
					WHERE	SDB.DB_FILIAL	= %xFilial:SDB%
						AND SDB.DB_SERVIC	= %Exp:SDB->DB_SERVIC% 
						AND SDB.DB_DOC		= %Exp:SDB->DB_DOC% 
						AND SDB.DB_SERIE	= %Exp:SDB->DB_SERIE% 
						AND SDB.DB_CLIFOR	= %Exp:SDB->DB_CLIFOR% 
						AND SDB.DB_LOJA		= %Exp:SDB->DB_LOJA% 			
						AND SDB.DB_PRODUTO	= %Exp:SDB->DB_PRODUTO% 
						AND SDB.DB_ORIGEM	= %Exp:SDB->DB_ORIGEM%
						AND SDB.DB_LOCAL 	= %Exp:SDB->DB_LOCAL%
						AND SDB.DB_LOTECTL	= %Exp:SDB->DB_LOTECTL%
						AND SDB.DB_NUMLOTE	= %Exp:SDB->DB_NUMLOTE%
						AND SDB.DB_NUMSEQ	= %Exp:SDB->DB_NUMSEQ%
						AND SDB.DB_IDMOVTO	= %Exp:SDB->DB_IDMOVTO%
						AND SDB.DB_IDDCF	= %Exp:SDB->DB_IDDCF%					
						AND SDB.DB_ESTORNO	= %Exp:''%
						AND SDB.DB_ATUEST	= %Exp:'N'%
						AND SDB.%NotDel%
	
					EndSql
												                               
					(cAliasSDB)->(dbGoTop())
					While (cAliasSDB)->(!Eof())
							
						SDB->(dbGoTo((cAliasSDB)->SDBREC))                 
					        				    
					    RecLock("SDB",.F.)
					             
					    If (cAlias)->ZS_QUANT > 0
					    
						    SDB->DB_QUANT	:= (cAlias)->ZS_QUANT
						    SDB->DB_QTSEGUM	:= ConvUM(SDB->DB_PRODUTO,(cAlias)->ZS_QUANT,0,2)
						                                          
						    DCR->(dbSetOrder(1))
						    If DCR->(dbSeek(xFilial("DCR")+SDB->DB_IDDCF+SDB->DB_IDDCF+SDB->DB_IDMOVTO+SDB->DB_IDOPERA))
						    
						    	RecLock("DCR",.F.)
						    	DCR->DCR_QUANT	:= SDB->DB_QUANT
						    	DCR->DCR_QTSEUM	:= SDB->DB_QTSEGUM
						       DCR->(msUnLock())
						        
						    EndIf
						    
						Else
	                               
							//Apaga amarração
						    DCR->(dbSetOrder(1))
						    If DCR->(dbSeek(xFilial("DCR")+SDB->DB_IDDCF+SDB->DB_IDDCF+SDB->DB_IDMOVTO+SDB->DB_IDOPERA))
						    
						    	RecLock("DCR",.F.)
							    DCR->(dbDelete())
						        DCR->(msUnLock())
						        
						    EndIf
							
							//Apaga movimento					
						    SDB->(dbDelete())
						    
						EndIf		    
	
					    SDB->(msUnLock())
					     
						(cAliasSDB)->(dbSkip())         
						
					EndDo				
					(cAliasSDB)->(dbCloseArea())
								
		        EndIf		 
				 
				If (cAlias)->SZSREC > 0
				    
					SZS->(dbGoTo((cAlias)->SZSREC))	                 
	
					RecLock('SZS',.F.)
					SZS->ZS_STATUS := "2"
					SZS->(MsUnLock())
							
				EndIf
				 
				(cAlias)->(dbSkip())
			EndDo				
			(cAlias)->(dbCloseArea())				
			
		EndIf
		
		//Endereça produtos falta e avaria na doca de conferencia
		For z := 1 to Len(aEndFalta)
	
			//aAdd(aEndFalta,{SDB->DB_SERVIC,SDB->DB_PRODUTO,SDB->DB_LOCAL,SDB->DB_NUMSEQ,SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_LOCALIZ,SDB->DB_QUANT-(cAlias)->ZS_QUANT}
			
			lInc		:= .F.	 
			aExcecoes 	:= {}
			         
			//Verifica as atividades de excessão deste endereço
			SBE->(dbSetOrder(1))
			If SBE->(dbSeek(xFilial("SBE")+aEndFalta[z][3]+aEndFalta[z][9]))
	
				DCL->(dbSetOrder(1))                                     
				If DCL->(dbSeek(xFilial('DCL')+SBE->BE_EXCECAO))
					
					While DCL->(!Eof()) .and. DCL->DCL_FILIAL+DCL->DCL_CODIGO == xFilial('DCL')+SBE->BE_EXCECAO

						aAdd(aExcecoes,DCL->DCL_ATIVID)
						DCL->(dbSkip())
		        	
					EndDo
						
				EndIf
			
				//Rotina para criar as atividades de endereçamento automatico na doca
				DC5->(dbSetOrder(2))
				If DC5->(dbSeek(xFilial("DC5")+cTarefEnd)) 
	                                                    					
					//Rotina executada atravez do execução de serviço
					//serve para gerar os registros do SDB para execução da conferencia
					DC6->(dbSetOrder(1))
					If DC6->(dbSeek(xFilial("DC6")+DC5->DC5_TAREFA))

						cIdMovto := u_WMSProxSeq()
										
						While DC6->(!Eof()) .and. xFilial("DC6")+DC5->DC5_TAREFA == DC6->DC6_FILIAL+DC6->DC6_TAREFA
						    		    
							If aScan(aExcecoes,DC6->DC6_ATIVID) == 0
						                   
						 		//aAdd(aEndFalta,{SDB->DB_SERVIC,SDB->DB_PRODUTO,SDB->DB_LOCAL,SDB->DB_NUMSEQ,SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_LOCALIZ,SDB->DB_QUANT-(cAlias)->ZS_QUANT}
						        
						        lInc := .T.
						                                       
								RecLock("SDB",.t.)
								
								SDB->DB_FILIAL	:= xFilial("SDB")
								SDB->DB_ITEM		:= StrZero(1,2)
								SDB->DB_PRIORI	:= "ZZ"
								SDB->DB_IDOPERA	:= GetSx8Num('SDB','DB_IDOPERA')
								SDB->DB_HRINI		:= Time()
								SDB->DB_DATA		:= dDataBase
								SDB->DB_TIPO		:= "E"
								SDB->DB_ATUEST	:= "N"             
								SDB->DB_TM			:= "499"
								SDB->DB_PRODUTO	:= aEndFalta[z][2]
								SDB->DB_LOCAL		:= aEndFalta[z][3]
								SDB->DB_LOCALIZ	:= SBE->BE_LOCALIZ
								SDB->DB_ESTFIS	:= SBE->BE_ESTFIS
								SDB->DB_ENDDES	:= SBE->BE_LOCALIZ
								SDB->DB_ESTDES	:= SBE->BE_ESTFIS
								SDB->DB_DOC		:= aEndFalta[z][5]
								SDB->DB_SERIE		:= aEndFalta[z][6]
								SDB->DB_CLIFOR	:= aEndFalta[z][7]
								SDB->DB_LOJA		:= aEndFalta[z][8]
								SDB->DB_ORIGEM	:= aEndFalta[z][10]
								SDB->DB_QUANT		:= aEndFalta[z][11]
								SDB->DB_QTSEGUM	:= ConvUM(aEndFalta[z][2],aEndFalta[z][11],0,2)
								SDB->DB_SERVIC	:= aEndFalta[z][1]
								SDB->DB_TAREFA	:= DC5->DC5_TAREFA
								SDB->DB_ORDTARE	:= DC5->DC5_ORDEM 
								SDB->DB_ATIVID	:= DC6->DC6_ATIVID
								SDB->DB_RHFUNC	:= DC6->DC6_FUNCAO
								SDB->DB_RECFIS	:= DC6->DC6_TPREC
								SDB->DB_ORDATIV	:= DC6->DC6_ORDEM
								SDB->DB_NUMSEQ	:= aEndFalta[z][4]
								SDB->DB_STATUS	:= cStatAuto
								SDB->DB_IDMOVTO	:= cIdMovto
								SDB->DB_IDDCF		:= aEndFalta[z][12]
										
								SDB->(MsUnLock())

								ConfirmSX8()
	                                                            
						   		RecLock("DCR",.t.)
								DCR->DCR_FILIAL	:= xFilial("DCR")
								DCR->DCR_IDORI	:= SDB->DB_IDDCF
								DCR->DCR_IDDCF	:= SDB->DB_IDDCF
								DCR->DCR_IDMOV	:= SDB->DB_IDMOVTO
								DCR->DCR_QUANT	:= SDB->DB_QUANT
								DCR->DCR_IDOPER	:= SDB->DB_IDOPERA
								DCR->DCR_QTSEUM	:= SDB->DB_QTSEGUM
								DCR->DCR_EMPENH	:= 0
								DCR->DCR_EMP2	:= 0
								DCR->(msUnLock())  
								
							EndIf
				
							DC6->(dbSkip())
							
						EndDo
	
						//Executa a proxima atividade caso o serviço seja automatico								
						If lInc .and. SDB->DB_STATUS == cStatAuto
			                
							//Declarado apenas aqui devido a problemas em rotina padrão
							aParam150  := Array(34)
						           
							aParam150[01] := SDB->DB_PRODUTO	//-- Produto
							aParam150[02] := SDB->DB_LOCAL		//-- Almoxarifado
							aParam150[03] := SDB->DB_DOC		//-- Documento
							aParam150[04] := SDB->DB_SERIE		//-- Serie
							aParam150[05] := SDB->DB_NUMSEQ		//-- Sequencial
							aParam150[06] := SDB->DB_QUANT		//-- Saldo do produto em estoque
							aParam150[07] := SDB->DB_DATA		//-- Data da Movimentacao
							aParam150[08] := Time()				//-- Hora da Movimentacao
							aParam150[09] := SDB->DB_SERVIC		//-- Servico
							aParam150[10] := SDB->DB_TAREFA		//-- Tarefa
							aParam150[11] := SDB->DB_ATIVID		//-- Atividade
							aParam150[12] := SDB->DB_CLIFOR		//-- Cliente/Fornecedor
							aParam150[13] := SDB->DB_LOJA		//-- Loja
							aParam150[14] := ''					//-- Tipo da Nota Fiscal
							aParam150[15] := '01'				//-- Item da Nota Fiscal
							aParam150[16] := ''					//-- Tipo de Movimentacao
							aParam150[17] := SDB->DB_ORIGEM		//-- Origem de Movimentacao
							aParam150[18] := SDB->DB_LOTECTL	//-- Lote
							aParam150[19] := SDB->DB_NUMLOTE	//-- Sub-Lote
							aParam150[20] := SDB->DB_LOCALIZ	//-- Endereco
							aParam150[21] := SDB->DB_ESTFIS		//-- Estrutura Fisica
							aParam150[22] := '1'				//-- Regra de Apanhe (1=LOTE/2=NUMERO DE SERIE/3=DATA)
							aParam150[23] := SDB->DB_CARGA		//-- Carga
							aParam150[24] := SDB->DB_UNITIZ		//-- Nr. do Pallet
							aParam150[25] := SDB->DB_LOCAL		//-- Centro de Distribuicao Destino
							aParam150[26] := SDB->DB_ENDDES		//-- Endereco Destino
							aParam150[27] := SDB->DB_ESTDES		//-- Estrutura Fisica Destino
							aParam150[28] := SDB->DB_ORDTARE	//-- Ordem da Tarefa
							aParam150[29] := SDB->DB_ORDATIV	//-- Ordem da Atividade
							aParam150[30] := SDB->DB_RHFUNC		//-- Funcao do Recurso Humano
							aParam150[31] := SDB->DB_RECFIS		//-- Recurso Fisico
							aParam150[32] := SDB->DB_IDDCF		//-- Identificador do DCF
							aParam150[33] := Space(TamSx3("DCF_CODNOR")[1])
							aParam150[34] := SDB->DB_IDMOVTO
						            
							//-- Efetua a Gravacao do Produto no Endereco Desejado
							//lRet := DLXGrvEnd(,,,,,,,SBE->BE_CODZON,,'1',.T.,'2',,,,,.F.)
							lRet := WmsEndereca(.T.,'2')
															
						EndIf
						
		    		EndIF
		
				EndIf
	
			EndIf
	
		Next
		
		End Transaction
		
	Next
	
	//-- Destrava os Registros Utilizados
	dbSelectArea("SDB")
	MaDestrava(aRecSDB)
	
EndIf

Return .f.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VA063GetNfºAutor  ³Ihorran Milholi     º Data ³  18/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para recuperar as notas fiscais de origem            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAWMS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VA063GetNfs(cDoc,cProduto,cLoteCtl,cNumLote,cLocal)

Local cAlias	:= GetNextAlias()
Local aRet		:= {}

BeginSql Alias cAlias

SELECT	SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_ITEM, SD1.D1_NUMSEQ, SD1.D1_QUANT

FROM	%table:SD1% SD1
		
		INNER JOIN %table:Z54% Z54 ON	Z54.Z54_FILIAL		= %xFilial:Z54% 
										AND	Z54.Z54_DOC		= SD1.D1_DOC 
										AND	Z54.Z54_SERIE	= SD1.D1_SERIE
										AND	Z54.Z54_FORN	= SD1.D1_FORNECE
										AND	Z54.Z54_LOJA	= SD1.D1_LOJA 
										AND	Z54.Z54_TIPO	= SD1.D1_TIPO
										AND	Z54.Z54_NUM		= %Exp:cDoc%
										AND	Z54.%notdel%
														
WHERE	SD1.D1_FILIAL	= %xFilial:SD1%
	AND	SD1.D1_COD		= %Exp:cProduto%
	AND	SD1.D1_LOTECTL	= %Exp:cLoteCtl%
	AND	SD1.D1_NUMLOTE	= %Exp:cNumLote%
	AND	SD1.D1_LOCAL	= %Exp:cLocal%
	AND	SD1.%NotDel%
	
EndSql

(cAlias)->(dbGoTop())

While (cAlias)->(!Eof())

	aAdd(aRet,{(cAlias)->D1_DOC,(cAlias)->D1_SERIE,(cAlias)->D1_FORNECE,(cAlias)->D1_LOJA,(cAlias)->D1_ITEM,(cAlias)->D1_NUMSEQ,(cAlias)->D1_QUANT})
	
	(cAlias)->(dbSkip())

EndDo

(cAlias)->(dbCloseArea())

Return(aRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VA063TravaReg ºAutor  ³Ihorran Milholi   º Data ³  09/10/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Trava todos os registros da conferencia para inicio do mesmoº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAWMS                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VA063TravaReg(cServic,cDocto,cSerie,cCliFor,cLoja,cOrigem,cServic,cTarefa,cAtivid,aRecSDB)

Local cAlias 	:= GetNextAlias()                                                        
Local cRecHum	:= __cUserID
Local cStatProb	:= SuperGetMV('MV_RFSTPRO',.F.,'2') 	//-- DB_STATUS indincando Atividade com Problemas   
Local cStatInte	:= SuperGetMV('MV_RFSTINT',.F.,'3')	//-- DB_STATUS indincando Atividade Interrompida
Local cStatAExe	:= SuperGetMV('MV_RFSTAEX',.F.,'4') 	//-- DB_STATUS indincando Atividade A Executar
Local cServRetr	:= AllTrim(GetNewPar("MV_YSRVRET","016"))
Local lErro		:= .f.
                                           
//AND	SDB.DB_SERVIC	= %Exp:cServic%
		
//Query para recuperar todos os itens a executar conferencia
BeginSql Alias cAlias
	
	SELECT	SDB.R_E_C_N_O_ RECSDB
	
	FROM	%table:SDB% SDB
	
	WHERE	SDB.DB_FILIAL	= %xFilial:SDB%
		AND	SDB.DB_ESTORNO	= %Exp:''%
		AND	SDB.DB_ATUEST	= %Exp:'N'%
		AND	SDB.DB_DOC		= %Exp:cDocto%
		AND	SDB.DB_SERIE	= %Exp:cSerie%
		AND	SDB.DB_CLIFOR	= %Exp:cCliFor%
		AND	SDB.DB_LOJA		= %Exp:cLoja%
		AND	SDB.DB_ORIGEM	= %Exp:cOrigem%
		AND	SDB.DB_TAREFA	= %Exp:cTarefa%
		AND	SDB.DB_ATIVID	= %Exp:cAtivid%
		AND SDB.DB_STATUS	IN (%Exp:cStatProb%,%Exp:cStatAExe%,%Exp:cStatInte%)
		AND	SDB.%NotDel%

	ORDER BY 	SDB.DB_FILIAL, SDB.DB_STATUS, SDB.DB_PRIORI, SDB.DB_CARGA
			,	SDB.DB_DOC, SDB.DB_SERIE, SDB.DB_CLIFOR, SDB.DB_LOJA, SDB.DB_ITEM
			, 	SDB.DB_SERVIC, SDB.DB_ORDTARE, SDB.DB_ORDATIV
	
EndSql

(cAlias)->(dbGoTop())

Begin TransAction

//Percorre todos os itens
While (cAlias)->(!Eof()) .and. !lErro
	
	//Seta no registro a conferir
	SDB->(dbGoTo((cAlias)->RECSDB))

	If cServRetr == cServic .and. SDB->DB_SERVIC <> cServic
	
		(cAlias)->(dbSkip())
		Loop		 
				
	EndIf
		
	If SDB->(SimpleLock()) 

		//Guarda os registros SDB para posterior utilização
		aAdd(aRecSDB,{"SDB",(cAlias)->RECSDB})
	
		If SDB->DB_STATUS == cStatAExe .or. ( (SDB->DB_STATUS == cStatInte .or. SDB->DB_STATUS == cStatProb) .and. SDB->DB_RECHUM == cRecHum)
		
			RecLock('SDB',.F.)  // Trava para gravacao
			SDB->DB_RECHUM	:= cRecHum
			SDB->DB_STATUS	:= cStatInte
			SDB->DB_DATA	:= dDataBase
			SDB->DB_HRINI	:= Time()
			SDB->(msUnLock())

		Else

			lErro := .t.

		EndIf

	Else
    
		lErro := .t.
		
	EndIf
	
	(cAlias)->(dbSkip())
	
EndDo

//Caso tenha erro na selação dos registros o sistema ira abortar
If lErro

	DisarmTransaction()		

	//Libera todos os registros
	For i:= 1 to Len(aRecSDB)
		//Seta no registro a conferir
		SDB->(dbGoTo(aRecSDB[i][2])) 
		SDB->(msUnLock())	
	Next
		
	aRecSDB := {}
		
	DLVTAviso(cCadastro,'Não foi possivel selecionar este lote para conferencia!',{"Abandonar Conferencia"})
	
EndIf

End TransAction

//Elimina a area de trabalho
(cAlias)->(dbCloseArea())

Return(Len(aRecSDB)>0)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VA063End  | Autor ³ Alex Egydio             ³Data³12.02.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o endereco                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VA063End(cEnderSYS,cEndereco,cLocal)

Local aAreaAnt:= GetArea()
Local aAreaSBE:= SBE->(GetArea())
Local lRet		:= .T.

If	cEndereco != cEnderSYS
	DLVTAviso('VA063End','Endereco incorreto!')
	cEndereco	:= Space(Len(SDB->DB_LOCALIZ))
	lRet 		:= .F.
EndIf

If	lRet
	SBE->(DbSetOrder(1))
	If	SBE->( ! MsSeek(xFilial('SBE')+cLocal+cEndereco))
		DLVTAviso('VA063End','O Endereco '+AllTrim(cEndereco)+' nao esta cadastrado!')
		cEndereco	:= Space(Len(SDB->DB_LOCALIZ))
		lRet 		:= .F.
	EndIf
EndIf

RestArea(aAreaSBE)
RestArea(aAreaAnt)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VA063Prd | Autor ³ Alex Egydio             ³Data³12.02.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o produto                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VA063Prd(aPrdSYS,cProduto,cDescPro,cDescPr2,nConver,cNorma,cDscUM,cPictQt,cLoteCtl,nQtdNorma,nQtdNorma2,lRetrab,cIDOPera,cStage,cIdMovto)

Local lDigita	:= (SuperGetMV('MV_DLCOLET',.F.,'N') == 'N')
Local cWmsUMI	:= AllTrim(SuperGetMv('MV_WMSUMI',.F.,'1'))
Local nMax		:= VTMaxCol()-5
Local cTipId	:= ""
Local lRet		:= .T.
Local aProduto	:= {}
Local nPos		:= 0
Local cAlias	:= GetNextAlias()
Local cEstFis	:= "" 
Local cCodBarra	:= ""

If !lDigita
	
	cTipId := CBRetTipo(cProduto)
	
	//If	cTipId $ "EAN8OU13-EAN14-EAN128"
		
		//CBRetEtiEAN= Produto, Qtde, Lote, Validade, Serie
		aProduto := CBRetEtiEAN(cProduto)
				
		If	Len(aProduto) > 0                          

			cCodBarra	:= cProduto
			cProduto	:= aProduto[1]
			nConver 	:= aProduto[2]
			cLoteCtl	:= Padr(aProduto[3],Len(SDB->DB_LOTECTL))
            
		EndIf
	
	/*		
	Else
		
		aProduto := CBRetEti(cProduto,'01')
		
		If	Len(aProduto) > 0

			cCodBarra	:= cProduto			
			cProduto	:= aProduto[1]
			nConver		:= aProduto[2]
			cLoteCtl	:= Padr(aProduto[16],Len(SDB->DB_LOTECTL))
			
		EndIf
		
	EndIf
	*/
		
	If	Empty(aProduto)
		
		DLVTAviso('VA063Prd','Etiqueta invalida!')
		VTKeyBoard(chr(20))
		lRet := .F.
		
	EndIf
	
EndIf

If	lRet
	
	SB1->(DbSetOrder(1))
	If	!SB1->(MsSeek(xFilial('SB1')+cProduto))
		DLVTAviso('VA063Prd','O produto '+AllTrim(cProduto)+' nao esta cadastrado!')
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf
	
EndIf

If	lRet
	
	If aSCan(aPrdSYS,{|x| x[1] == cProduto}) == 0
		DLVTAviso('VA063Prd','O produto '+AllTrim(cProduto)+' nao consta no lote de recebimento!')
		VTKeyBoard(chr(20))
		lRet := .F.
	EndIf
	
EndIf

If	lRet
	
	//Caso a conversão seja 0, iguala para 1
	nConver := iif(nConver==0,1,nConver)
		
	//-- Divide Descr. do produto em 3 linhas
	cDescPro := SubStr(SB1->B1_DESC,       1,nMax)
	cDescPr2 := SubStr(SB1->B1_DESC,  nMax+1,nMax)

	//recupera a posição do produto	
	nPos := aSCan(aPrdSYS,{|x| x[1] == cProduto})
	
	SDB->(dbGoTo(aPrdSYS[nPos][7][1]))

	//Define o fator de conversão e unidade de medida	                    
	SLK->(dbSetOrder(2))
	If SLK->(dbSeek(xFilial("SLK")+cProduto+Padr(cCodBarra,TamSx3("LK_CODBAR")[1]))) .and. SLK->(FieldPos("LK_YUM")) > 0

		cDscUM := SLK->LK_YUM
		cPictQt:= PesqPict("SDB","DB_QUANT")

	ElseIf SB1->B1_TIPCONV == "D" .and. SB1->B1_CONV == nConver .and. SDB->DB_QTSEGUM > 0

		cDscUM := SB1->B1_SEGUM
		cPictQt:= PesqPict("SDB","DB_QTSEGUM")

	Else

		cDscUM := SB1->B1_UM
		cPictQt:= PesqPict("SDB","DB_QUANT")

	EndIf
	          
   	//Recupera a norma do produto	 
   	aAux		:= VA063GetInfProd(SDB->DB_SERVIC,SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_ORIGEM,SDB->DB_PRODUTO,SDB->DB_LOCAL,SDB->DB_LOTECTL,SDB->DB_NUMLOTE)
	nQtdNorma	:= aAux[1]
	lRetrab		:= aAux[2]
	cStage		:= aAux[3]
	cNorma		:= aAux[4]       
	cIDOPera	:= aAux[5]
	cIdMovto	:= aAux[6]
	nQtdNorma2	:= aAux[7]
				
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³WMSV070LOT| Autor ³ Alex Egydio             ³Data³12.02.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o lote                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VA063Lot(aLoteSYS,cProduto,cLoteCtl)

Local cRetPE := ""
Local lRet   := .T.

lRet := !Empty(cLoteCtl)

If	lRet .And. Len(aLoteSYS)>0 .And. aScan(aLoteSYS,{|x| x[1] == cProduto .And. x[2] == cLoteCtl}) == 0
	DLVTAviso('VA063Lot','O lote '+AllTrim(cLoteCtl)+' nao consta no documento atual!')
	lRet := .F.
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³WMSV070QTD| Autor ³ Alex Egydio             ³Data³12.02.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a quantidade                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VA063Qtd(nQtde,nConver,cProduto,cLoteCtl,aPrdSYS,nQtdNorma,cStage,cIDOPera,nQtdConfNor)

Local lRet 		:= (nQtde>0)
Local lWmsLote	:= SuperGetMv('MV_WMSLOTE',.F.,.F.)
Local nQtdConf	:= 0
Local nQtdTot	:= 0
Local nPos		:= 0  
Local aAux		:= {}

If lRet
	              
	If lWmsLote .And. Rastro(cProduto)

		nPos := aScan(aPrdSYS,{|x| x[1] == cProduto .and. x[2] == cLoteCtl})
	
	Else
	                                                                                        
		nPos := aScan(aPrdSYS,{|x| x[1] == cProduto})
					
	EndIf

	If aPrdSYS[nPos][3] <  aPrdSYS[nPos][4]+(nQtde*nConver)
		DLVTAviso('VA063Qtd','A qtd. ultrapassa a qtd. do Lote de Conferencia!')
		nQtde:= 0
		lRet := .f.
	EndIf               

	If lRet

		If nQtdNorma > 0

		  	//If aPrdSYS[nPos][4]+(nQtde*nConver)-aPrdSYS[nPos][5]-aPrdSYS[nPos][6] > nQtdNorma
			  
			If nQtdConfNor+(nQtde*nConver) > nQtdNorma
												    
				DLVTAviso('VA063Qtd','A qtd. ultrapassa a norma do pallet!')
				nQtde:= 0
				lRet := .f.
		  		  	
		  	EndIf					
		    			   		     
		    
		EndIf

	EndIf
		
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VA063EtBur| Autor ³ Alex Egydio             ³Data³12.02.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a quantidade                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VA063EtBurra(nTipo,cEtBurra,aEtBurra,cEtSugest)

Local lRet := !Empty(cEtBurra)
 
 cEtBurra := alltrim(cEtBurra)                      
 
                                               
If SubStr(cEtBurra,1,1) == "B"
	cEtBurra := AllTrim(SubStr(cEtBurra,2,Len(cEtBurra)))
Else                                                      
	cEtBurra := AllTrim(cEtBurra)
EndIf
            
If lRet

	If nTipo == 1
		
		SZS->(dbSetOrder(1))
		If SZS->(dbSeek(xFilial("SZS")+cEtBurra))
			
			If Empty(SZS->ZS_PROD) .or. aScan(aEtBurra,{|x| Alltrim(x[1]) == Alltrim(cEtBurra)}) > 0 
	                               
				If aScan(aEtBurra,{|x| x[1] == cEtBurra}) > 0 .and. Empty(cEtSugest)
				
					DLVTAviso('VA063EtBurra','Etiqueta Já Utilizada 1!') 
					lRet := .f.
	
				ElseIf !Empty(cEtSugest) .and. Alltrim(cEtBurra) <> Alltrim(cEtSugest) 
				
					DLVTAviso('VA063EtBurra','Etiqueta Invalida, Favor aglutinar o Produto!')
					lRet := .f.			
					
				EndIf
				
			Else                                         
			
				DLVTAviso('VA063EtBurra','Etiqueta Já Utilizada 2!')
				lRet := .f.
				
			EndIf
			
		Else
			
			DLVTAviso('VA063EtBurra','Etiqueta Invalida!')
			lRet := .f.
			
		EndIf
	
	ElseIf nTipo == 2
	                        
	    If aScan(aEtBurra,{|x| x[1] == cEtBurra}) == 0

			DLVTAviso('VA063EtBurra','Etiqueta Invalida!')
			lRet := .f.
			
		EndIf	
	
	EndIf
		
EndIf

If !lRet
	cEtBurra := Space(TamSx3("ZS_CODIGO")[1]+1)
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³WMSV070CON| Autor ³ Alex Egydio             ³Data³12.02.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta produtos conferidos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = vetor dos produtos ja conferidos                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VA063JaConf(cDocto,aPrdSYS)

Local aCab		:= {"Produto","Quantidade","U.M"}
Local aSize		:= {Len(SDB->DB_PRODUTO),Len(aCab[2]),Len(aCab[3])}
Local aTelaAnt	:= VTSave(00,00,VTMaxRow(),VTMaxCol())
Local aJaConf	:= {}
Local cWmsUMI	:= ""
Local nPos
Local i
Local nQuant
Local cUM

//Monta Vetor de Já Conferidos
For i:= 1 to Len(aPrdSYS)
      
    If aPrdSYS[i][4] > 0
                    
        //Verifica a necessidade de converter para a segunda unidade de medida!
    	cWmsUMI := AllTrim(SuperGetMv('MV_WMSUMI',.F.,'1'))             
		nQuant	:= 0
		
		//Posiciona no cadastro de produtos
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+aPrdSYS[i][1]))
		
		// --- Se parametro MV_WMSUMI = 4, utilizar U.M.I. informada no SB5
		If cWmsUMI == '4'        
			SB5->(DbSetOrder(1))
			If SB5->(MsSeek(xFilial('SB5')+aPrdSYS[i][1]))
				cWmsUMI := SB5->B5_UMIND
			EndIf
		EndIf     
		
		If cWmsUMI == "2"	
			nQuant	:= ConvUM(aPrdSYS[i][1],aPrdSYS[i][4],0,2)
			cUM		:= SB1->B1_SEGUM
		EndIf
		
		If nQuant == 0
			nQuant	:= aPrdSYS[i][4]
			cUM		:= SB1->B1_UM
		EndIf
		    
		nPos := aScan(aJaConf,{|x| x[1] == aPrdSYS[i][1]})	
		
		If nPos == 0 
		
			aAdd(aJaConf,{aPrdSYS[i][1],nQuant,cUM})
			
		Else
			
		 	aJaConf[nPos] += nQuant
		   
		EndIf

	EndIf
	
Next

//Ordena por codigo de produto
aJaConf := aSort(aJaConf,,,{|x, y| x[1] < y[1]})

If	Len(aJaConf) > 0

	VTClear()
	
	@ 00, 00 VTSay PadR("Lote",VTMaxCol())
	@ 01, 00 VTSay PadR(cDocto,VTMaxCol())
	
	VTaBrowse(02,00,VTMaxRow()-2,VTMaxCol(),aCab,aJaConf,aSize)
	VTRestore(00,00,VTMaxRow(),VTMaxCol(),aTelaAnt)
	
Else

	DLVTAviso('VA063JaConf','Nenhum produto conferido...')
	
EndIf     

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VA063LibVol| Autor³ Alex Egydio             ³Data³12.02.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Libera Volumes para Endereçamento atravez da etiqueta       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VA063LibVol(cDocto,aEtBurra,aRecSDB,aPrdSYS)
                                              
Local cStatExec	:= SuperGetMV('MV_RFSTEXE',.F.,'1') //-- DB_STATUS indincando Atividade Executada
Local aTelaAnt 	:= VTSave(00,00,VTMaxRow(),VTMaxCol())
Local cEtBurra	:= Space(TamSx3("ZS_CODIGO")[1]+1) 
Local lRet		:= .t.
Local nPos		:= 0
                                   
If Len(aEtBurra) > 0
	
	While lRet .and. Empty(cEtBurra)
	
		//-- Escolha do Produto a ser Conferido
		DLVTCabec(,.F.,.F.,.T.)
		@ 02,00 VTSay PadR('Etiqueta Burra',VTMaxCol())
		@ 03,00 VTGet cEtBurra Picture "@!" Valid VA063EtBurra(2,@cEtBurra,aEtBurra)			
		VTRead
	      
		lRet := VA063ESC(aRecSDB,"C",@cEtBurra)

		If lRet .and. Empty(cEtBurra)
			Loop			
		EndIf

	EndDo
          
    If lRet .and. !Empty(cEtBurra)
    
      	lRet := (DLVTAviso('Etiqueta','Deseja Reimprimir a etiqueta '+cEtBurra+'?', {'Sim','Nao'}) == 1)
	
    //	lRet := (DLVTAviso('Etiqueta','Deseja liberar a etiqueta '+cEtBurra+'?', {'Sim','Nao'}) == 1)
	
		If lRet
	        
			nPos := aScan(aEtBurra,{|x| x[1] == cEtBurra})
			
			//If !Empty(aEtBurra[nPos][2]) .or. aEtBurra[nPos][3]
			 
				VA063LibEti(cEtBurra,@aEtBurra,aRecSDB,@aPrdSYS)
				
		//	Else
	
			//	DLVTAviso('VA063LibVol','Não é possivel liberar este tipo de volume!')
			
		//	EndIF
			
		EndIf

	EndIf
		
Else
      
	DLVTAviso('VA063LibVol','Não existem volumes a serem liberados!')

EndIf

//Restaura a tela anterior                                                    
VTClear()
VTRestore(00,00,VTMaxRow(),VTMaxCol(),aTelaAnt)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VA063LibEti| Autor³ Ihorran Milholi         ³Data³28.10.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Libera etiquetas para endereçamento                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VA063LibEti(cEtBurra,aEtBurra,aRecSDB,aPrdSYS)

Local aArea		:= GetArea()
Local nQtdEnd	:= 0
Local nQtdEtiq	:= 0 
Local cNumSeq	:= ""
Local nPosEti	:= 0 
Local aCloneSDB	:= {}                
Local cIdMovto	:= ""
Local cEndereco
Local i            
Local x
Local aAux
Local nPos
Local cImpre := Space(TAMSX3("CB5_CODIGO")[1])
Local cCopias := "01"
Local aEtiqImp := {}

lOCAL lRetrab := .f.
Local cRomaneio := ""
Local cProduto := ""
Local cSeq	:= ""
Local cAliasSDB	:= GetNextAlias()
Local cAlias		:= GetNextAlias()
Local cStage := ""
Local aEtUMA := {}

SZS->(dbSetOrder(1))
If SZS->(dbSeek(xFilial("SZS")+cEtBurra))
       
  	   // Cria uma nova etiqueta e atrela a este produto.
	 	cRomaneio := SZS->ZS_DOC
		cProduto  := SZS->ZS_PROD 
		  
		AADD(aEtUMA,cEtBurra)  
       
        
	/*Begin Transaction
	
	While SZS->(!Eof()) .and. SZS->ZS_FILIAL+SZS->ZS_CODIGO == xFilial("SZS")+cEtBurra
               
		nQtdEtiq := SZS->ZS_QUANT
				
		For i:= 1 to Len(aRecSDB)
									
			//Seta no registro a conferir
			SDB->(dbGoTo(aRecSDB[i][2]))
	
			nQtdEnd	:= SDB->DB_QTDLID-SDB->DB_YQTAVAR-SDB->DB_YQTLIBE				                

			//Posiciona no vetor dos produtos em conferencia
			nPos := aScan(aPrdSYS,{|x| x[1] == SDB->DB_PRODUTO .and. x[2] == SDB->DB_LOTECTL})
					
			If SZS->ZS_PROD+SZS->ZS_LOCAL+SZS->ZS_LOTECTL+SZS->ZS_NUMLOTE+SZS->ZS_NUMSEQ == SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_LOTECTL+SDB->DB_NUMLOTE+SDB->DB_NUMSEQ .and. nQtdEnd > 0
	                     
				If nQtdEtiq > nQtdEnd
						        
					aPrdSYS[nPos][6] += nQtdEnd                           

					RecLock('SDB',.F.)
					SDB->DB_YQTLIBE+= nQtdEnd
					SDB->(MsUnLock())

					nQtdEtiq -= nQtdEnd
					
	           Else                                                      
	           	
					aPrdSYS[nPos][6] += nQtdEtiq                           
											                    	                    	      
           		RecLock('SDB',.F.)
					SDB->DB_YQTLIBE += nQtdEtiq
					SDB->(MsUnLock())
					
					Exit
					
				EndIf
            
			EndIf
									   
		Next
		
		SDB->(dbSetOrder(11))
		If SDB->(dbSeek(xFilial("SDB")+SZS->ZS_DOC+SZS->ZS_SERIE+SZS->ZS_CLIFOR+SZS->ZS_LOJA+SZS->ZS_IDOPERA))
			
	   		//Verifica o ultima atividade de endereçamento para diminuir a quantidade do mesmo 
			BeginSql Alias cAliasSDB

			SELECT	SDB.R_E_C_N_O_ SDBREC
			
			FROM	%table:SDB% SDB
			
			WHERE	SDB.DB_FILIAL		= %xFilial:SDB%            
				AND SDB.DB_SERVIC		= %Exp:SDB->DB_SERVIC% 
				AND SDB.DB_DOC		= %Exp:SDB->DB_DOC% 
				AND SDB.DB_SERIE		= %Exp:SDB->DB_SERIE% 
				AND SDB.DB_CLIFOR		= %Exp:SDB->DB_CLIFOR% 
				AND SDB.DB_LOJA		= %Exp:SDB->DB_LOJA% 			
				AND SDB.DB_PRODUTO	= %Exp:SDB->DB_PRODUTO% 
				AND SDB.DB_ORIGEM		= %Exp:SDB->DB_ORIGEM%
				AND SDB.DB_LOCAL 		= %Exp:SDB->DB_LOCAL%
				AND SDB.DB_LOTECTL	= %Exp:SDB->DB_LOTECTL%
				AND SDB.DB_NUMLOTE	= %Exp:SDB->DB_NUMLOTE%
				AND SDB.DB_NUMSEQ		= %Exp:SDB->DB_NUMSEQ%
				AND SDB.DB_IDMOVTO	= %Exp:SDB->DB_IDMOVTO%
				AND SDB.DB_IDDCF		= %Exp:SDB->DB_IDDCF%
				AND SDB.DB_ESTORNO	= %Exp:''%
				AND SDB.DB_ATUEST		= %Exp:'N'%
				AND SDB.%NotDel%
					
			ORDER BY SDB.DB_IDOPERA

			EndSql
			
			//Atualiza id do movimento para novo registro		
			cIdMovto := u_WMSProxSeq()
			
			//while para modificar a atividade original e criação de outra com mesma caracteristicas							                               
			(cAliasSDB)->(dbGoTop())
			While (cAliasSDB)->(!Eof())
						
				SDB->(dbGoTo((cAliasSDB)->SDBREC))                 
			
				aAux := {}			
			    
			    If SDB->DB_QUANT-SZS->ZS_QUANT > 0          

		   			For x := 1 to SDB->(FCount())                                   
	
						Do Case
							Case SDB->(FieldName(x)) == "DB_QUANT";	aAdd(aAux,{SDB->(FieldName(x)),SDB->DB_QUANT-SZS->ZS_QUANT})
							Case SDB->(FieldName(x)) == "DB_QTSEGUM"; aAdd(aAux,{SDB->(FieldName(x)),ConvUM(SDB->DB_PRODUTO,SDB->DB_QUANT-SZS->ZS_QUANT,0,2)})
							OtherWise; aAdd(aAux,{SDB->(FieldName(x)),&("SDB->"+SDB->(FieldName(x)))})
						EndCase
						
					Next			

					RecLock("SDB",.F.)
					SDB->DB_QUANT		:= SZS->ZS_QUANT
					SDB->DB_QTSEGUM	:= ConvUM(SDB->DB_PRODUTO,SZS->ZS_QUANT,0,2)
					SDB->(msUnLock())
	
					DCR->(dbSetOrder(1))
					If DCR->(dbSeek(xFilial("DCR")+SDB->DB_IDDCF+SDB->DB_IDDCF+SDB->DB_IDMOVTO+SDB->DB_IDOPERA))
						    
						RecLock("DCR",.F.)
				    	DCR->DCR_QUANT	:= SDB->DB_QUANT
				    	DCR->DCR_QTSEUM	:= SDB->DB_QTSEGUM
						DCR->(msUnLock())
						        
					EndIf
									                    
					If Len(aAux) > 0 

						//Inclui novo registro CLONE
						RecLock("SDB",.T.)
		                
						For x := 1 to Len(aAux)
		                
		                 	If aAux[x][1] == "DB_IDOPERA"	
		
		   						SDB->DB_IDOPERA	:= GetSx8Num('SDB','DB_IDOPERA')
		
		                 	ElseIf aAux[x][1] == "DB_IDMOVTO"
		                 	                                                    
	                 	    	SDB->DB_IDMOVTO	:= cIdMovto
		                 	
		                 	Else	
		                 	 	
		                 	 	&("SDB->"+aAux[x][1]) := aAux[x][2]
		                 	
		                 	EndIf                	
		                	
						Next
		
						SDB->(msUnLock())  
	
						ConfirmSX8()      
									    
				    	RecLock("DCR",.t.)
						DCR->DCR_FILIAL	:= xFilial("DCR")
						DCR->DCR_IDORI	:= SDB->DB_IDDCF
						DCR->DCR_IDDCF	:= SDB->DB_IDDCF
						DCR->DCR_IDMOV	:= SDB->DB_IDMOVTO
						DCR->DCR_QUANT	:= SDB->DB_QUANT
						DCR->DCR_IDOPER	:= SDB->DB_IDOPERA
						DCR->DCR_QTSEUM	:= SDB->DB_QTSEGUM
						DCR->DCR_EMPENH	:= 0
						DCR->DCR_EMP2		:= 0
						DCR->(msUnLock())
	
					EndIf
				
				EndIf
								    				     
				(cAliasSDB)->(dbSkip())         
					
			EndDo				
			(cAliasSDB)->(dbCloseArea())
		
		EndIf
				
		RecLock('SZS',.F.)
		SZS->ZS_STATUS := "2" 
		SZS->(MsUnLock())

	   // Cria uma nova etiqueta e atrela a este produto.
	 	cRomaneio := SZS->ZS_DOC
		cProduto  := SZS->ZS_PROD
	
       SZS->(dbSkip())
            	                                                                                    
	EndDo
	
	AADD(aEtUMA,cEtBurra)
		
	//Elimina a etiqueta do vetor de etiquetas
	nPosEti := aScan(aEtBurra,{|x| x[1] == cEtBurra})
	
	aDel(aEtBurra,nPosEti)	
	aSize(aEtBurra,Len(aEtBurra)-1)
    
	// Verifica se sobrou saldo para gerar uma nova etiqueta
	If aPrdSYS[nPos][3] - aPrdSYS[nPos][4] > 0 

	   //Query para selecionar o ultimo numero do sequencial
		BEGINSQL Alias cAlias
			
			SELECT TOP 1 SUBSTRING(ZS_CODIGO,9,12) as SEQ
			FROM %table:SZS%
			WHERE %table:SZS%.%NOTDEL%
			AND ZS_FILIAL = %exp:xFilial("SZS")%
			ORDER BY ZS_CODIGO DESC
			
		ENDSQL
		
		//Verifica se e' o primeiro registro da tabela, e insere se for
		IF EMPTY((cAlias)->SEQ)
			cSeq := DTOS(dDataBase) + STRZERO(1,12)
		ELSE
			cSeq :=  DTOS(dDataBase) + (SOMA1((cAlias)->SEQ))
		ENDIF
	
		(cAlias)->(dbCloseArea())
			
		RecLock('SZS',.T.)
			SZS->ZS_FILIAL := xFilial("SZS")
			SZS->ZS_CODIGO := cSeq
			SZS->ZS_ORIGEM := "Z54"
			SZS->ZS_DOC	 := cRomaneio
			SZS->ZS_PROD	 := cProduto
			SZS->ZS_LOCAL  := "01"
			SZS->ZS_STATUS := '1'
		SZS->(MsUnlock())
		
	    cStage	:= VA063GetStage(SZS->ZS_IDOPERA)
	    
	    aAdd(aEtBurra,{SZS->ZS_CODIGO,cStage,lRetrab,{}})   
	      
	   	//Localiza a etiqueta nova no vetor
		nPosEti := aScan(aEtBurra,{|x| x[1] == cSeq})
	       
	    //Inclui registros no vetor
		If aScan(aEtBurra[nPosEti][4],{|x| x[1] == SZS->ZS_PROD}) == 0
		
			aAdd(aEtBurra[nPosEti][4],{SZS->ZS_PROD,SZS->ZS_QUANT,SZS->ZS_IDOPERA})
		
		EndIf	   
   
 	  //Adiciona no array para imprirmir
  	 	AADD(aEtUMA,cSeq)
   End If*/
  
   
	//IF VTYesNo("Deseja imprimir as etiquetas? (S-SIM,N-NAO)" ,"Atenção ",.T.)
	
		DbSelectArea("SB1")
		DbSetOrder(1)
		SB1->(DbSeek(xFilial("SB1")+cProduto))
		
		cEndereco := u_EndUMA(cProduto,SZS->ZS_LOCAL)
		
		DbSelectArea("SZS")
		DbsetOrder(1)

				
		// Selecione a Impressora
		cImpre := SeleIMP()
		
		If Empty(cImpre)
			Return
		End If

		For i := 1 to len(aEtUMA)
		
			 if SZS->(DbSeek(xFilial("SZS") + aEtUMA[i]))
			
			/*If SZS->ZS_STATUS == "2"
			
				// Como a etiqueta já foi finalizada, imprimi a quantidade
				// vinculado a ela.
				nQtdEnd := SZS->ZS_QUANT
			
			Else
				
				//Quantidade do DB
				nQtdEnd := aPrdSYS[nPos][3] - aPrdSYS[nPos][4]
			
			End If
		
			IF nQtdEnd > 0	*/		
			AADD(aEtiqImp,{SB1->B1_COD,;
						 SB1->B1_DESC,;
						 SB1->B1_UM,;
						 nQtdEnd,;
						 cEndereco,;
						 aEtUMA[i],;
						 SZS->ZS_LOCAL})

						
			// End If @@@comentato
			End if
		Next

		//Localizado no VIXR021 
		
		U_VIX21UMA(aEtiqImp,cImpre,"1",cRomaneio)	
		
	
	//End iF

//End Transaction 
			
		
EndIf


Static Function SeleIMP()

	Local aArea := GetArea()
	Local lPen	 := .F.
	Local cAlias 	 := GetNextAlias()
	Local aCab		 := {}
	Local aSize	 := {}
	Local nPos		 := {}
	Local aItens 	 := {}
	Local aImpressora := {}
	Local aTela
	Local cCodImpres := ""
	
	VTSave Screen To aTela
	
	BEGINSQL ALIAS cAlias
	
	SELECT  CB5.CB5_CODIGO ,
	        CB5.CB5_DESCRI ,
	        CB5.CB5_SERVER ,
	        CB5.CB5_PORTIP
	FROM    %Table:CB5% CB5
	WHERE   CB5.CB5_FILIAL = %xFilial:SZH%
	        AND CB5.D_E_L_E_T_ = ''
			 AND CB5.CB5_SERVER <> ''
	
	EndSql
	
	
	While (cAlias)->(!EOF())
		lPen := .T.
		AADD(aImpressora,{ (cAlias)->CB5_CODIGO,(cAlias)->CB5_DESCRI,(cAlias)->CB5_SERVER,(cAlias)->CB5_PORTIP })
		(cAlias)->(DbSkip())
	EndDo

	aCab := {"Codigo","Impressora","Server","Porta"}
	aSize:= {6,15,12,04}                                  
	nPos := 1

	If Len(aImpressora) > 0 
		// Solicite ao Usuario o codigo da transportadora
		DLVTCabec("Impressoras", .F., .F., .T.)
		
		@ 01, 00 VTSay "Selecione a Imp:"
		nPos := VTaBrowse(03,0,7,40,aCab,aImpressora,aSize,/*Funcao p/ tratar as teclas*/,nPos)
		
		// pega o codigo da impressora
		If nPos > 0
			cCodImpres := aImpressora[nPos][1]
		End If
		
	End IF
	

	RestArea(aArea)
	VTRestore Screen From aTela	


Return cCodImpres
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VA063GetInfProd| Autor³ Ihorran Milholi     ³Data³28.10.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina para recuperar informaçõe do produto                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function VA063GetInfProd(cServic,cDoc,cSerie,cCliFor,cLoja,cOrigem,cProduto,cLocal,cLoteCtl,cNumLote)    

//SDB->DB_DOC,SDB->DB_SERIE,SDB->DB_CLIFOR,SDB->DB_LOJA,SDB->DB_ORIGEM,SDB->DB_PRODUTO,SDB->DB_LOCAL,,SDB->DB_LOTECTL,SDB->DB_NUMLOTE
      
Local cAlias 	:= GetNextAlias()
Local cTarefEnd	:= AllTrim(GetNewPar("MV_YTAREND","009"))
Local lRetrab 	:= .f. //iif(!Empty(Posicione("SB5",1,xFilial("SB5")+cProduto,"B5_YRETRAB")) .and. cOrigem == "Z54",.t.,.f.)
Local aAux		:= {0,lRetrab,"","",Space(TamSX3("DB_IDOPERA")[1]),Space(TamSX3("DB_IDMOVTO")[1]),0}
Local aAuxRet	:= {}
Local cServErro	:= AllTrim(GetNewPar("MV_YSRVERR","015"))   

/*      
nQtdNorma	:= aAux[1]
lRetrab		:= aAux[2]
cStage		:= aAux[3]
cNorma		:= aAux[4]
ID de Oper	:= aAux[5]
*/

//Depois verifica um endereço final
BeginSql Alias cAlias

SELECT	TOP 1 SDB.DB_LOCAL, SDB.DB_ENDDES, SDB.DB_ESTDES, SDB.DB_QUANT, SDB.DB_IDOPERA, SDB.DB_PRODUTO
	, 	SDB.DB_IDMOVTO, SDB.DB_RECEMB,	SDB.DB_SERVIC
	
FROM	%table:SDB%	SDB

WHERE	SDB.DB_FILIAL	= %xFilial:SDB%  
	AND SDB.DB_SERVIC	= %Exp:cServic%  
	AND SDB.DB_DOC		= %Exp:cDoc% 
	AND SDB.DB_SERIE	= %Exp:cSerie% 
	AND SDB.DB_CLIFOR	= %Exp:cCliFor% 
	AND SDB.DB_LOJA		= %Exp:cLoja% 			
	AND SDB.DB_PRODUTO	= %Exp:cProduto% 
	AND SDB.DB_ORIGEM	= %Exp:cOrigem%
	AND SDB.DB_LOCAL 	= %Exp:cLocal%
	AND SDB.DB_LOTECTL	= %Exp:cLoteCtl%
	AND SDB.DB_NUMLOTE	= %Exp:cNumLote%
	AND SDB.DB_ESTORNO	= %Exp:''%
	AND SDB.DB_ATUEST	= %Exp:'N'%
	AND SDB.DB_TAREFA	= %Exp:cTarefEnd%  
	AND SDB.DB_ORDATIV	= %Exp:'01'%
	AND SDB.DB_IDOPERA NOT IN (	SELECT 	SZS.ZS_IDOPERA 
								FROM 	%table:SZS% SZS 
								WHERE 	SZS.%NotDel%
									AND	SZS.ZS_FILIAL	= %xFilial:SZS%
									AND SZS.ZS_DOC		= SDB.DB_DOC
									AND SZS.ZS_SERIE	= SDB.DB_SERIE
									AND SZS.ZS_CLIFOR	= SDB.DB_CLIFOR
									AND SZS.ZS_LOJA		= SDB.DB_LOJA
									AND SZS.ZS_ORIGEM	= SDB.DB_ORIGEM
									AND SZS.ZS_PROD		= SDB.DB_PRODUTO
									AND SZS.ZS_LOTECTL	= SDB.DB_LOTECTL
									AND SZS.ZS_NUMLOTE	= SDB.DB_NUMLOTE
									AND SZS.ZS_LOCAL	= SDB.DB_LOCAL
									AND SZS.ZS_NUMSEQ	= SDB.DB_NUMSEQ
									AND SZS.ZS_IDMOVTO	= SDB.DB_IDMOVTO
									AND SZS.ZS_IDDCF	= SDB.DB_IDDCF																		
									AND (	SZS.ZS_STATUS	<> %Exp:'1'%
										OR	SZS.ZS_QUANT= SDB.DB_QUANT))
 	AND SDB.%NotDel%

ORDER BY SDB.DB_IDOPERA
                            	
EndSql
      
(cAlias)->(dbGoTop())
If (cAlias)->(!Eof()) .and. (cAlias)->(!Bof())

	aAux[1]	:= iif(lRetrab,0,iif((cAlias)->DB_SERVIC == cServErro,0,(cAlias)->DB_QUANT))	
 	aAux[3]	:= VA063GetStage((cAlias)->DB_IDOPERA)
	aAux[4]	:= Posicione('DC2',1,xFilial('DC2')+(cAlias)->DB_RECEMB,'DC2_DESNOR')
	aAux[4]	:= AllTrim(Replace(aAux[4],"NORMA",""))
	aAux[5]	:= (cAlias)->DB_IDOPERA
	aAux[6]	:= (cAlias)->DB_IDMOVTO
	aAux[7]	:= iif(lRetrab,0,iif((cAlias)->DB_SERVIC == cServErro,0,(cAlias)->DB_QUANT))	
		   
	DC2->(dbSetOrder(1))
	If aAux[7] > 0 .and. DC2->(dbSeek(xFilial("DC2")+(cAlias)->DB_RECEMB))
	
		aAux[7]	:= DC2->DC2_LASTRO*DC2->DC2_CAMADA	                                                  
		
	EndIf

EndIf
(cAlias)->(dbCloseArea())
						
Return(aAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VA063GetStage  | Autor³ Ihorran Milholi     ³Data³06.11.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina para recuperar STAGE a ser endereçado o produto      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VA063GetStage(cIDOpera)

Local cAliasEnd	:= GetNextAlias()
Local cAliasAti	:= GetNextAlias()
Local cStage	:= ""

//Recupara os endereços stage disponiveis para este endereço
BeginSql Alias cAliasAti

SELECT	SDB.DB_LOCAL, SDB.DB_ENDDES, SDB.DB_IDOPERA, SDB.DB_ORDATIV, SDB.DB_PRODUTO, SDB.DB_ESTDES

FROM	%table:SDB% SDB

WHERE	SDB.DB_FILIAL	= %xFilial:SDB%
	AND SDB.DB_ESTORNO	= %Exp:''%
	AND SDB.DB_ATUEST	= %Exp:'N'%
	AND SDB.%notdel%
	AND EXISTS(	SELECT	SDBID.DB_PRODUTO
				FROM	%table:SDB% SDBID
				WHERE	SDBID.DB_FILIAL	= SDB.DB_FILIAL				
					AND SDBID.DB_IDOPERA= %Exp:cIDOpera%
					AND SDBID.DB_ATUEST	= SDB.DB_ATUEST
					AND SDBID.DB_ESTORNO= SDB.DB_ESTORNO
					AND SDBID.DB_DOC	= SDB.DB_DOC
					AND SDBID.DB_ORIGEM	= SDB.DB_ORIGEM
					AND SDBID.DB_SERVIC	= SDB.DB_SERVIC
					AND SDBID.DB_TAREFA	= SDB.DB_TAREFA
					AND SDBID.DB_PRODUTO= SDB.DB_PRODUTO
					AND SDBID.DB_NUMSEQ	= SDB.DB_NUMSEQ
					AND SDBID.DB_IDMOVTO= SDB.DB_IDMOVTO
					AND SDBID.DB_IDDCF	= SDB.DB_IDDCF					
					AND SDBID.DB_ESTORNO= %Exp:''%
					AND SDBID.DB_ATUEST	= %Exp:'N'%				
					AND SDBID.%notdel%)

ORDER BY SDB.DB_IDOPERA DESC

EndSql
                         
(cAliasAti)->(dbGoTop())

If (cAliasAti)->(!Eof()) .and. (cAliasAti)->(!Bof())
                	         
	//Recupara os endereços stage disponiveis para este endereço
	BeginSql Alias cAliasEnd
			      
	SELECT	*
			
	FROM	%table:SZU% SZU
			
	WHERE	SZU.%notdel%
		AND	SZU.ZU_FILIAL	= %xFilial:SZU%
		AND	SZU.ZU_LOCAL	= %Exp:(cAliasAti)->DB_LOCAL%
		AND %Exp:(cAliasAti)->DB_ENDDES% BETWEEN SZU.ZU_ENDINI AND SZU.ZU_ENDFIN
		AND %Exp:(cAliasAti)->DB_ESTDES% BETWEEN SZU.ZU_ESTINI AND SZU.ZU_ESTFIN
			
	EndSql
			                  
	(cAliasEnd)->(dbGoTop())
	    		
	If (cAliasEnd)->(!Eof()) .and. (cAliasEnd)->(!Bof())
	                                 
		cStage := (cAliasEnd)->ZU_STAGE01
			    
	EndIf
			    
	(cAliasEnd)->(dbCloseArea())   
	//Fim
    
EndIf

(cAliasAti)->(dbCloseArea())
                         	
Return cStage
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VA063AvarValid | Autor³ Ihorran Milholi     ³Data³06.11.2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Rotina para validação da avaria com autorização do lider    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function VA063AvarValid(nQtdAvar,nQtde,aRecSDB)
            
Local lRet 		:= .f.
Local cOcorr	:= "000004"
Local aTelaAnt	:= VTSave(00,00,VTMaxRow(),VTMaxCol())
                          
If nQtdAvar == 0

	lRet := .t.

ElseIf nQtde >= nQtdAvar

	//Seta o primeiro registro a conferir
	SDB->(dbGoTo(aRecSDB[1][2]))
			
	//Chama rotina para verificar a autorização do lider
	If u_VIXA065(SDB->DB_DOC,SDB->DB_ORIGEM,cOcorr)
	
		lRet := .t.
	
	Else
		
		lRet 	:= .f.
		nQtdAvar:= 0
		
		//Restaura a tela anterior                                                    
		VTClear()
		VTRestore(00,00,VTMaxRow(),VTMaxCol(),aTelaAnt)

	EndIf

ElseIf nQtdAvar > nQtde 
                    
	lRet 	:= .f.
	nQtdAvar:= 0
		    
	VtAlert('Quantidade de Avaria maior que a quantidade do produto!',cCadastro,.T.,1000,3)
	
	//Restaura a tela anterior                                                    
	VTClear()
	VTRestore(00,00,VTMaxRow(),VTMaxCol(),aTelaAnt)

EndIf

Return(lRet)