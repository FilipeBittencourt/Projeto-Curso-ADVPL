#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function RETP0006()
	
	Local lOk        := .T.
	Local aRet       := {}
	Local _cPedNum   := ""
	Local _cPedItem  := ""
	Local aArea      := SC8->(GetArea())
	
	Local nI         := 0
	Local nJ         := 0
	Local nK         := 0
	Local nL         := 0
		
	Local cAliasTemp := Nil
	Local cQuery     := ""
	Local _cFornece  := ""
	Local _cLoja     := ""
	Local _cProd     := ""
	Local _aListCont := {}
	Local _aListPed  := {}
	
	Local _cNumCot   := SC8->C8_NUM
	Local _cTppSS    := SC8->C8_YTPPSS
	
	
	//_cPedNum	:= SC7->C7_NUM
	
	If ((AllTrim(_cTppSS) == "1" .Or. AllTrim(_cTppSS) == "2"))
		
		/*Pega dos os pedidos que foram gerados cotação*/
		DbSelectArea('SC8')
		SC8->(DbSetOrder(1))
		SC8->(DbSeek(xFilial('SC8')+_cNumCot))
		
		While (!SC8->(Eof()) .And. SC8->C8_FILIAL+SC8->C8_NUM == xFilial('SC8')+_cNumCot)
			If (!Empty(SC8->C8_NUMPED) .And. AllTrim(SC8->C8_NUMPED) != 'XXXXXX')
				
				_nPos := AScan(_aListPed, {|x| AllTrim(x) == AllTrim(SC8->C8_NUMPED)})
				If (_nPos <= 0)
					Aadd(_aListPed, SC8->C8_NUMPED)
				EndIf 
				
				Aadd(_aListCont, ;
					{;
					 SC8->C8_NUMPED,;
					 SC8->C8_ITEMPED,;
					 SC8->C8_FILIAL,;
					 SC8->C8_NUM,;
					 SC8->C8_FORNECE,;
					 SC8->C8_LOJA,;
					 SC8->C8_ITEM,;
					 SC8->C8_PRODUTO,;
					 SC8->C8_NUMPRO;
					 };
				)
				
			EndIf
			SC8->(DbSkip())	
		EndDo
		
		varinfo("_aListPed", _aListPed)
		varinfo("_aListCont", _aListCont)
		
		
		For nK=1 To Len(_aListPed)
			
			_cPedNum	:= _aListPed[nK]
			_aList		:= {}
			//armazena todos pedidos que foram gerados na cotação
			For nL=1 To Len(_aListCont)
				If (AllTrim(_cPedNum) == AllTrim(_aListCont[nL][1]))
					Aadd(_aList, _aListCont[nL])
				EndIf
			Next nL

			//|Atualiza histórico do pedido |
			oPIntCCConfirm	:= TPortalIntegracaoCC():New()
			oPIntCCConfirm:AtualizaHistorico(_cPedNum, "Incluido Pedido de Compra no Protheus com numero: " + _cPedNum )

			FreeObj(oPIntCCConfirm)
			
			cNumContrato := ""
			//geração de contrato para cada pedido que foi gerado
			If (AllTrim(_cTppSS) == "1")
				Begin Transaction
					
					aRet			:= U_RETP0004(_cPedNum)//cria o contrato de parceria
					lOK		 		:= aRet[1]
					cNumContrato	:= aRet[2]
					
					If (lOk)
						
						lOk := U_RETP0005(_cPedNum)//elimina pedido por residuo
						If (!lOk)
							DisarmTransaction()
						EndIf
						
					Else
						DisarmTransaction()
					EndIf
			
				End Transaction 
			EndIf	
			
			If (lOk)

				_aAreaSA2	:= SA2->( GetArea() )
				dbSelectArea("SA2")
				SA2->( dbSetOrder(1) )
				
				For nL := 1 To Len(_aList)
				
					_cPedNum      := _aList[nL][1]
					_cPedItem     := _aList[nL][2]
					_cCotFil      := _aList[nL][3]
					_cCotNum      := _aList[nL][4]
					_cCotForne    := _aList[nL][5]
					_cCotLoja     := _aList[nL][6]
					_cCotItem     := _aList[nL][7]
					_cCotProd     := _aList[nL][8]
					_cCotProposta := _aList[nL][9]

					_cCotCnpjForn	:= ""
					If SA2->( dbSeek( xFilial("SA2") + _cCotForne + _cCotLoja ) )
						_cCotCnpjForn	:= SA2->A2_CGC
					EndIf
				
					oPIntCCConfirm	:= TPortalIntegracaoCC():New()
					oPIntCCConfirm:AtualizaPedido(_cCotNum, _cCotItem, _cCotForne, _cCotLoja, _cCotProd, _cCotProposta, _cPedNum, _cPedItem, _cCotCnpjForn)//confirma item como integrado
					If (AllTrim(_cTppSS) == "1")
						oPIntCCConfirm:AtualizaContrato(_cCotNum, _cCotItem, _cCotForne, _cCotLoja, _cCotProd, _cCotProposta, cNumContrato, _cPedItem, _cCotCnpjForn)//confirma item como integrado
					EndIf
					oPIntCCConfirm:AtualizaVencedor(_cCotNum, _cCotItem, _cCotForne, _cCotLoja, _cCotProd, _cCotProposta, _cCotCnpjForn)//confirma item como integrado
						
					If (AllTrim(_cTppSS) == "1")
						//atualização data necessidade do contrato
						oList		:= oPIntCCConfirm:GetPorContrato(cNumContrato, _cPedItem)//confirma item como integrado
								
						For nI := 1 To oList:GetCount()
							
							oItens	:= oList:GetItem(nI):oItens
							For nJ := 1 To oItens:GetCount()
								
								_cFornece := oItens:GetItem(nJ):cFornece
								_cLoja	  := oItens:GetItem(nJ):cLoja
								_cProd	  := oItens:GetItem(nJ):cProd
														
								cAliasTemp	:= GetNextAlias()
								cQuery		:= "select ID=R_E_C_N_O_ from " + RetSQLName("SC3")+"					"
								cQuery		+= " where 																"
								cQuery		+= " C3_FILIAL			= '"+xFilial('SC3')+"'							"
								cQuery		+= " AND C3_NUM			= '"+cNumContrato+"'							"
								cQuery		+= " AND C3_ITEM		= '"+_cPedItem+"'								"
								cQuery		+= " AND C3_FORNECE		= '"+_cFornece+"'								"
								cQuery		+= " AND C3_LOJA		= '"+_cLoja+"'									"
								cQuery		+= " AND C3_PRODUTO		= '"+_cProd+"'									"
								cQuery		+= " AND D_E_L_E_T_ 	= '' 											"
								
								TcQuery cQuery New Alias (cAliasTemp)
				
								If (!(cAliasTemp)->(EoF()))
									DbSelectArea('SC3')
									SC3->(DbSetOrder(1))
									SC3->(DbGoTo((cAliasTemp)->ID))
									RecLock('SC3', .F.)
										SC3->C3_DATPRI	:= stod(oItens:GetItem(nJ):dInicioContrato)
										SC3->C3_DATPRF	:= stod(oItens:GetItem(nJ):dFinalContrato)
									SC3->(MsUnLock())
								EndIf
								
								(cAliasTemp)->(DbCloseArea())
								
							Next nJ
							
						Next nI
						
					EndIf
				
				Next nL

				RestArea(_aAreaSA2)
						
			EndIf
			
		Next nK
		
	EndIf
	
	
	
	/*
	DbSelectArea('SC7')
	SC7->(DbSetOrder(1))
	If (SC7->(DbSeek(xFilial('SC7')+_cPedNum)))
		_cFornece := SC7->C7_FORNECE 
	EndIf
	
		
	If (AllTrim(_cTppSS) == "1")
		Begin Transaction
			
			aRet	:= U_RETP0004(_cPedNum)
			lOK	 	:= aRet[1]
			cNumContrato:= aRet[2]
			
			If (lOk)
				lOk := U_RETP0005(_cPedNum)
				If (!lOk)
					DisarmTransaction()
				EndIf
				
				oPIntCCConfirm	:= TPortalIntegracaoCC():New()
				oPIntCCConfirm:AtualizaPedido(_cNumCot, '',_cPedNum, '')//confirma item como integrado
				oPIntCCConfirm:AtualizaContrato(_cNumCot, '',cNumContrato, '')//confirma item como integrado
				oPIntCCConfirm:AtualizaVencedor(_cNumCot, '',_cFornece)//confirma item como integrado
				
				oList		:= oPIntCCConfirm:GetPorContrato(cNumContrato, '')//confirma item como integrado
				
				For nI := 1 To oList:GetCount()
					
					oItens	:= oList:GetItem(nI):oItens
					For nJ := 1 To oItens:GetCount()
						
						_cFornece := oItens:GetItem(nJ):cFornece
						_cLoja	  := oItens:GetItem(nJ):cLoja
						_cProd	  := oItens:GetItem(nJ):cProd
												
						cAliasTemp	:= GetNextAlias()
						cQuery		:= "select ID=R_E_C_N_O_ from " + RetSQLName("SC3")+"					"
						cQuery		+= " where 																"
						cQuery		+= " C3_FILIAL			= '"+xFilial('SC3')+"'							"
						cQuery		+= " AND C3_NUM			= '"+cNumContrato+"'								"
						cQuery		+= " AND C3_FORNECE		= '"+_cFornece+"'								"
						cQuery		+= " AND C3_LOJA		= '"+_cLoja+"'									"
						cQuery		+= " AND C3_PRODUTO		= '"+_cProd+"'									"
						cQuery		+= " AND D_E_L_E_T_ 	= '' 											"
						
						conout(cQuery)
						
						TcQuery cQuery New Alias (cAliasTemp)
		
						If (!(cAliasTemp)->(EoF()))
							DbSelectArea('SC3')
							SC3->(DbSetOrder(1))
							SC3->(DbGoTo((cAliasTemp)->ID))
							RecLock('SC3', .F.)
								SC3->C3_DATPRI	:= stod(oItens:GetItem(nJ):dInicioContrato)
								SC3->C3_DATPRF	:= stod(oItens:GetItem(nJ):dFinalContrato)
							SC3->(MsUnLock())
						EndIf
						
						(cAliasTemp)->(DbCloseArea())
						
					Next nJ
					
				Next nI						
				
			Else
				DisarmTransaction()
			EndIf
	
		End Transaction 
	ElseIf(AllTrim(_cTppSS) == "2")
		oPIntCCConfirm	:= TPortalIntegracaoCC():New()
		oPIntCCConfirm:AtualizaPedido(_cNumCot, '',_cPedNum, '')//confirma item como integrado		
		oPIntCCConfirm:AtualizaVencedor(_cNumCot, '',_cFornece)//confirma item como integrado		
	EndIf
	*/
	SC8->(RestArea(aArea))	
	
Return lOk


User Function RETP06PT()	

	Local cEmp			:= "01"
	Local cFil			:= "01"
	Local cNumSC		:= "SSD074"

	If Select("SX6") == 0
		RPCSetEnv(cEmp, cFil)
	EndIf

	//|REPROCESSA UMA COTAÇÃO |
	dbSelectArea('SC8')
	SC8->( dbSetOrder(12) )
	If SC8->( dbSeek( xFilial('SC8') + cNumSC ) )

		U_RETP0006()

	EndIf

Return
