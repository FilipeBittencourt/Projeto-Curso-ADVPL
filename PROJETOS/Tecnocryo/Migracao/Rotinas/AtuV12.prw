#Include "Protheus.ch"
#Include "Totvs.ch"   

User Function AtuV12()
Local cMyEmp   := "01"
Local cMyFil   := "0101"
Local aEmps    := {}
Local nE       := 0 
Local aTabs    := {}
Local cTabela  := "" 
Local cTabBkp  := ""
Local cTab     := ""  
Local oSteps   := ArrayList():New({5,7})  
Local nX       := 0
Local cPrefixo := "BKP"//Dtos(Date()) + StrTran(Time(),":","")
Local lOk      := .T.
Local cCampos  := ""  
Local aAreaSX2 := {}

	RPCSetType(3)
	RPCSetEnv(cMyEmp, cMyFil)   

	aEmps := FWAllGrpCompany()
	
	For nE := 1 To Len(aEmps)
		If cMyEmp != aEmps[nE]	
			cMyEmp := aEmps[nE]
			RpcClearEnv()	
			RPCSetEnv(cMyEmp, cMyFil)   	
		End If
		
		//
		/*
		STEP 01
		DELETAR INDICES DUPLICADOS
		*/
		If oSteps:Contains(1)
			ConOut("STEP 01 - DELETAR INDICES DUPLICADOS")	
			
			//TCDelFile("NUZ010")	
	
			aCpos := {"EJZ1", "EJZ2","ELB1", "ELB2", "ELB3","FRF2","TJG1", "TJG2"}
			//aCpos := {"B0Y2"} //UPDDISTR
			
			DbSelectArea("SIX")
			DbSetOrder(1)
			
			For nX := 1 To Len(aCpos)
				If DbSeek(aCpos[nX])
					ConOut("DbDelete() SIX Indice " + aCpos[nX] )				
					RecLock("SIX", .F.)
						DbDelete()
					SIX->(MSUnlock())
				End If
			Next nX
		End If
		/*
		*/		
		//
		/*
		STEP 02
		Descricao: O tamanho no SX3 do campo CL2_PARTI é dIferente do SXG
		*/
		If oSteps:Contains(2)
			ConOut("STEP 02 - Descricao: O tamanho no SX3 do campo CL2_PARTI é dIferente do SXG")		

			aCpos := {"B8_CLIFOR","CVD_CTAREF","FIM_CODMUN","CKY_DTEMIS","F0M_CONTA"}
			
						//aCpos := {"CL2_PARTI", "FIM_CODMUN", "CKY_DTEMIS", "CKY_DTEMIS", "EK_NUM", "CLY_GRUPO", "F02_VLTOTN", ;
			          //"F02_VLDEDU", "F0M_CONTA"}
			
			DbSelectArea("SX3")
			DbSetOrder(2) //X3_CAMPO
			
			For nX := 1 To Len(aCpos)
				If DbSeek(aCpos[nX])
					If !Empty(SX3->X3_GRPSXG)
						ConOut("SX3 - RecLock - X3_GRPSXG = '  ' - " + aCpos[nX])
						RecLock("SX3", .F.)
							SX3->X3_GRPSXG := "   "
						SX3->(MsUnlock())
					End If
				End If
			Next nX
		End If
		/*
		FIM STEP 05
		*/		
		
		//
		/*
		STEP 03
		PERGUNTE SX1
		*/
		If oSteps:Contains(3)
			DbSelectArea("SX1")
			DbSetOrder(1)
			aCpos   := {PadR("AFI381",10) + "03", PadR("AFI381",10) + "04", PadR("AFI381",10) + "10"}
			
			For nX := 1 To Len(aCpos)
				If DbSeek(aCpos[nX]) .And. !Empty(SX1->X1_GRPSXG)
					RecLock("SX1", .F.)
						SX1->X1_GRPSXG := "   "
					SX1->(MsUnlock())
				End If
			Next nX
		End If		
		/*FIM*/			
		//
		/*
		STEP 04
		Descricao: O campo de usuario DHJ_FILIAL existe na na versao padrao e sera substituido pelo campo da versao
		*/
		If oSteps:Contains(4)
			ConOut("STEP 04 - Descricao: O campo de usuario DHJ_FILIAL existe na na versao padrao e sera substituido pelo campo da versao")		
	
			aCpos := {"C2_TPPR","E2_FORBCO","E2_FORAGE","E2_FAGEDV","E2_FORCTA","E2_FCTADV","N1_TPCTRAT","NO_FORNEC", ;
			          "NO_LOJA","NP_CBASE","NP_ITEM","NP_FORNEC","NP_LOJA","NP_STATUS","NP_VIGINI","NP_VIGFIM","NP_CONTATO"}
			//aCpos := {"DHJ_FILIAL", "DHJ_TPOP", "DHJ_DESCTP", "DHJ_CFOP", "DHJ_DESCCF", "K2_ACRESC", "BC_CODLAN", ;
			//          "E2_FORBCO", "E2_FORAGE", "E2_FAGEDV", "E2_FORCTA", "E2_FCTADV", "N1_TPCTRAT", "NO_FORNEC", ;
			//          "NO_LOJA", "NP_CBASE", "NP_ITEM", "NP_FORNEC", "NP_LOJA", "NP_STATUS", "NP_VIGINI", ; 
			//          "NP_VIGFIM", "NP_CONTATO", "TQB_USUARI" }
			
			DbSelectArea("SX3")
			DbSetOrder(2) //X3_CAMPO
			
			For nX := 1 To Len(aCpos)
				If DbSeek(aCpos[nX])
					If SX3->X3_PROPRI != "S"
						ConOut("SX3 - RecLock - X3_PROPRI = 'S' - " + aCpos[nX])
						RecLock("SX3", .F.)
							SX3->X3_PROPRI := "S"
						SX3->(MsUnlock())
					End If
				End If
			Next nX
		End If		
		/*
		FIM STEP 04
		*/		
		//
		/*
		STEP 5
		Descricao: O campo de usuario DHJ_FILIAL existe na na versao padrao e sera substituido pelo campo da versao
		*/
		If oSteps:Contains(5)
			aTabs := {"SA1","SA2","SE1","SE2","SE5","SC2","SC5","SC6","SC9","SF1","SD1","SF2","SD2","SD3","SF3","SFT"}  
			
			//aTabs := {"SC2","SC5","SF3","SAK","SE2","SF2"}
	
			For nX := 1 To Len(aTabs)
				cTab    := aTabs[nX]
				cTabela := RetSqlname(cTab)
			    cTabBkp := cTabela + cPrefixo

			    ConOut(cTab)

				If TCCanOpen(cTabela) //se a tabela existe
					lOk := .T.
				    ConOut(cTabela)				
					If TCCanOpen(cTabBkp) //se existe o backup criado
				 		ConOut("TCDelFile(" + cTabBkp + ")")				
				    	lOk := TCDelFile(cTabBkp)
				    	If !lOk
				    		ConOut(TCSqlError())
				    	End If
				    End If
				    
				    If lOk //se tabela de backup nao existe
			    		ConOut("SELECT * INTO " + cTabBkp + " FROM " + cTabela)
						lOk := TCSqlExec("SELECT * INTO " + cTabBkp + " FROM " + cTabela) >= 0
						
						If !lOk
				    		ConOut(TCSqlError())						
						Else //se conseguiu fazer o backup 
							If Select(cTab) > 0
								(cTab)->(DbCloseArea())
							End if
				    		
				    		ConOut("TCDelFile(" + cTabela + ")")						
							lOk := TCDelFile(cTabela)

					    	If !lOk
					    		ConOut(TCSqlError())							
							Else //se conseguiu dropar a tabela
					    		ConOut("DbSelectArea('" + cTab + "')")
					    		lOk := .F.
					    		Begin Sequence													
									DbSelectArea(cTab) //Recria a tabela
									DbSetOrder(1)
									lOk := .T.
								End Sequence
								
								If !lOk
									ConOut(TCSqlError())
								Else
									ConOut("GetCampos('" + cTabBkp + "')")	
									cCampos := GetCampos(cTabBkp)
	
									ConOut("INSERT INTO " + cTabela + " (cCampos) SELECT Campos FROM " + cTabBkp)									
									lOk := TCSqlExec("INSERT INTO " + cTabela + " (" + cCampos + ") SELECT " + cCampos + " FROM " + cTabBkp ) >= 0
	
	                                If !lOk
							    		ConOut(TCSqlError())
									Else
							    		ConOut("TCRefresh(" + cTabela + ")")								
										TCRefresh(cTabela)
									
										ConOut("TCDelFile(" + cTabBkp + ")")						
										lOk := TCDelFile(cTabBkp)
										
										If !lOk
											ConOut(TCSqlError())
										End If
									End If
								End If								
							End If
						End If
				    End If
				End If				
			Next nX			
		End If  
		/*
		STEP 05
		*/		
		
		If oSteps:Contains(6)
			DbSelectArea("SX2")	
			DbSetOrder(1)
			DbGoTop()
		
			While SX2->(!Eof())
				aAreaSX2 := SX2->(GetArea())
			    cTabela  := AllTrim(SX2->X2_ARQUIVO)
			    
			    If TCCAnOpen(cTabela)
			    	ConOut(cTabela)
			    	TCRefresh(cTabela)
			    End If
			    
			    RestArea(aAreaSX2)
				SX2->(DbSkip())
			End Do
		End If		
		
		/*
		STEP 07
		*/
		If oSteps:Contains(7)
			ConOut("STEP 07 - Tabelas FK1 a FKA..")
		
			DbSelectArea("SX2")
			DbSetOrder(1)
			DbGoTop()
			
			If DbSeek("SE5")
				cModo    := SX2->X2_MODO
				cModoUn  := SX2->X2_MODOUN
				cModoEmp := SX2->X2_MODOEMP
				
				aTabs := {"FK1", "FK2", "FK3", "FK4", "FK5", "FK6", "FK7", "FK8", "FK9", "FKA"}
				
				For nX := 1 To Len(aTabs)
					If DbSeek(aTabs[nX])
						If (SX2->X2_MODO != cModo .Or. SX2->X2_MODOUN != cModoUn .Or. SX2->X2_MODOEMP != cModoEmp)
							cTabela := AllTrim(SX2->X2_ARQUIVO)
							RecLock("SX2", .F.)
								SX2->X2_MODO    := cModo
								SX2->X2_MODOUN  := cModoUn
								SX2->X2_MODOEMP := cModoEmp
							SX2->(MsUnlock())
							TCRefresh(cTabela)
						End If
					End If
				Next nX
			End If
		End If 
		
		If oSteps:Contains(8)
			DbSelectArea("SX2")	
			DbSetOrder(1) 
			DbGoTop() 
			
			While SX2->(!Eof())   
				If SX2->X2_CHAVE <= "CTL"
					SX2->(DbSkip())
					Loop
				End If
			
				aAreaSX2 := SX2->(GetArea())
				cTab     := SX2->X2_CHAVE
			    cTabela  := AllTrim(SX2->X2_ARQUIVO)
			    cTabBkp  := cTabela + cPrefixo

			    ConOut(cTab)

				If TCCanOpen(cTabela) //se a tabela existe
					lOk := .T.
				    ConOut(cTabela)				
					If TCCanOpen(cTabBkp) //se existe o backup criado
				 		ConOut("TCDelFile(" + cTabBkp + ")")				
				    	lOk := TCDelFile(cTabBkp)
				    	If !lOk
				    		ConOut(TCSqlError())
				    	End If
				    End If
				    
				    If lOk //se tabela de backup nao existe
			    		ConOut("SELECT * INTO " + cTabBkp + " FROM " + cTabela)
						lOk := TCSqlExec("SELECT * INTO " + cTabBkp + " FROM " + cTabela) >= 0
						
						If !lOk
				    		ConOut(TCSqlError())						
						Else //se conseguiu fazer o backup 
							If Select(cTab) > 0
								(cTab)->(DbCloseArea())
							End if
				    		
				    		ConOut("TCDelFile(" + cTabela + ")")						
							lOk := TCDelFile(cTabela)

					    	If !lOk
					    		ConOut(TCSqlError())							
							Else //se conseguiu dropar a tabela
					    		ConOut("DbSelectArea('" + cTab + "')")
					    		lOk := .F.
					    		Begin Sequence													
									DbSelectArea(cTab) //Recria a tabela
									DbSetOrder(1)
									lOk := .T.
								End Sequence
								
								If !lOk
									ConOut(TCSqlError())
								Else
									ConOut("GetCampos('" + cTabBkp + "')")	
									cCampos := GetCampos(cTabBkp)
	
									ConOut("INSERT INTO " + cTabela + " (cCampos) SELECT Campos FROM " + cTabBkp)									
									lOk := TCSqlExec("INSERT INTO " + cTabela + " (" + cCampos + ") SELECT " + cCampos + " FROM " + cTabBkp ) >= 0
	
	                                If !lOk
							    		ConOut(TCSqlError())
									Else
							    		ConOut("TCRefresh(" + cTabela + ")")								
										TCRefresh(cTabela)
									
										ConOut("TCDelFile(" + cTabBkp + ")")						
										lOk := TCDelFile(cTabBkp)
										
										If !lOk
											ConOut(TCSqlError())
										End If
									End If
								End If								
							End If
						End If
				    End If
				End If
	            
				RestArea(aAreaSX2)
				SX2->(DbSkip())
			End Do
		End If
		
		
		
		//
		/*
		STEP 09
		Com base num SIX padrão verifico se há algum indice a ser incluido do SIX do protheus 12
		SÓ EXECUTAR ESSE PASSO APÓS FINZALIDOS TODOS OS COMPATIBILIZADORES(MP710TO120 E UPDDISTR) E ANTES DE USAR/TESTAR O SISTEMA
		*/
		If oSteps:Contains(9)
			ConOut("STEP 09 - Com base num SIX padrão verifico se há algum indice a ser incluido no SIX do protheus 12")
			DbSelectArea("SX2")
			DbSetOrder(1)
			
			DbSelectArea("SIX")
			DbSetOrder(1)
			
			Use "\@Append\SIX990.DTC" Alias SIX99 Shared New 
	
			DbSelectArea("SIX99")	
		
			While SIX99->(!Eof())
				If !SIX->(DbSeek(SIX99->(INDICE + ORDEM)))
					If SX2->(DbSeek(SIX99->INDICE))
						ConOut("SIX - Criando chave " + SIX99->(INDICE + ORDEM))
				    	RecLock("SIX", .T.)
				    		SIX->INDICE    := SIX99->INDICE
				    		SIX->ORDEM     := SIX99->ORDEM
				    		SIX->CHAVE     := SIX99->CHAVE
				    		SIX->DESCRICAO := SIX99->DESCRICAO
				    		SIX->DESCSPA   := SIX99->DESCSPA
				    		SIX->DESCENG   := SIX99->DESCENG
				    		SIX->PROPRI    := SIX99->PROPRI
				    		SIX->F3        := SIX99->F3
				    		SIX->NICKNAME  := SIX99->NICKNAME
				    		SIX->SHOWPESQ  := SIX99->SHOWPESQ
				    	SIX->(MsUnlock())
					End If
				End If
				
				SIX99->(DbSkip())
			End Do

			SIX99->(DbCloseArea())	 
		End If
		/*
		FIM STEP 09
		*/		
		
		
						
	Next nE    

	RpcClearEnv()
Return
/*
*/
Static Function GetCampos(cTabela)
Local cFields := ""
Local cAlias  := GetNextAlias()

	BeginSql Alias cAlias
		SELECT C.COLUMN_NAME
		  FROM INFORMATION_SCHEMA.TABLES T
		  JOIN INFORMATION_SCHEMA.COLUMNS C ON C.TABLE_CATALOG = T.TABLE_CATALOG
		                                   AND C.TABLE_SCHEMA = T.TABLE_SCHEMA
		                                   AND C.TABLE_NAME = T.TABLE_NAME
		 WHERE T.TABLE_CATALOG = DB_NAME()
		   AND T.TABLE_SCHEMA = 'dbo'
		   AND T.TABLE_NAME = %Exp:cTabela%
		   AND T.TABLE_TYPE = 'BASE TABLE'
	EndSql
	
	While (cAlias)->(!Eof())
		cFields += If(!Empty(cFields),",","") + AllTrim((cAlias)->COLUMN_NAME)
		(cAlias)->(DbSkip())
	End Do
	
	(cAlias)->(DbCloseArea())
Return cFields