#include "rwmake.ch"
#include "topconn.ch"

User Function BIA436()
	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ BIA436     ³ Autor ³ MICROSIGA VITORIA     ³ Data ³ 24/07/08 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o ³ Obtem Preco de Venda para o Produto                          ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Interpretador x Base                                         ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	Local aArea		:= GetArea()
	Local aAreaSA1	:= SA1->(GetArea())
	Local aAreaSB1	:= SB1->(GetArea())

	//Tratamento especial para Replcacao de pedido LM
	If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC###MATA440")
		Return(GdFieldGet("C6_PRCVEN",n))
	EndIf



	Private wCalcPreco, wCliente, wLoja, wC6QTDVEN, wProduto, wItem
	Private nPosDesc, nPosDOut, nPosDVer, wValPrc, wNPrcVen, nPosPerc, nPolit, nPosLote, nPosQtdVnd, nPosProd, nPosVlPrc, nPosVlUni, nPosVlTotal, wLote, nPreco, cQuery, nPrcUntOri
	Private wEmpPed

	Private cEmpNPOL := AllTrim(GetNewPar("FA_EMPNPOL",""))

	//Fernando/Facile em 10/08/15 - nova politica passa a so calcular preco/desconto nestes campos
	If (!(AllTrim(cEmpAnt) $ cEmpNPOL) .And. !(ALLTRIM(__READVAR) $ 'M->C6_QTDVEN#M->C6_YDTNECE#M->C6_YDESP#M->C6_YDNV#M->C6_YDVER#M->C6_YDACO#M->C6_YDAI#M->C6_YPREAJU#M->C6_YDFRA')) .And. !(AllTrim(M->C5_YSUBTP) ==  "O")
		If !(AllTrim(M->C5_YSUBTP) $ "A#M#F")
			If !(isincallstack("U_ConsEst") .And. Type("__FCESTALTLTPOL") <> "U")
				Return(GdFieldGet("C6_PRCVEN",n))
			EndIf
		EndIf
	EndIf

	wCliente   		:= M->C5_CLIENTE
	wLoja      		:= M->C5_LOJAENT
	wCalcPreco		:= .F.
	nPreco      	:= 0

	IF ALLTRIM(FUNNAME()) == "EECAP100"
		RestArea(aArea)
		RestArea(aAreaSA1)
		RestArea(aAreaSB1)
		Return
	ENDIF

	IF ALLTRIM(FUNNAME()) <> "EECAP100"
		nPreco 		:= 0
		nPosProd	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRODUTO'})
		nPosItem	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_ITEM'})
		nPosQtdVnd	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_QTDVEN'})
		nPosVlPrc   := AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRCVEN'})
		nPosVlUni   := AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRUNIT'})
		nPosVlTab   := AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YPRCTAB'})
		nPosVlTotal	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_VALOR'})
		nPosLote   	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_LOTECTL'})
		nPosDesc   	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YDESC'})
		nPosDOut	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YDESP'})
		nPosDVer	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YDVER'})
		nPosPerc  	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YPERC'})
		nPosPDesc	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_DESCONT'})
		nPosVlDesc	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_VALDESC'})
		nPosRegra	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YREGRA'})
		nPosDescReg	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YDESCLI'})
		nPosTes		:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_TES'})
		nPosEmpPed	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YEMPPED'})
		nPosVFrtUn	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YVFRTUN'})
		nPosVSegUn	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YVSEGUN'})
		nPosPReaj  	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YPREAJU'})

		//Campos para salvar os fatores multiplicador de preço e redutor da LM
		nPosFMul	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YFATMUL'})
		nPosFRed	:= AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_YFATRED'})

		wC6QTDVEN	:= aCols[n,nPosQtdVnd]
		wProduto	:= aCols[n,nPosProd]
		wItem		:= aCols[n,nPosItem]
		wLote   	:= aCols[n,nPosLote]
		wValPrc   	:= aCols[n,nPosVlTab]
		wRegra    	:= aCols[n,nPosRegra]
		cTES		:= aCols[n,nPosTes]
		wEmpPed		:= aCols[n,nPosEmpPed]

		wC5YMAXCND := M->C5_YMAXCND
		wC5VLRFRET := M->C5_VLRFRET
		wC5YVLRREV := M->C5_YVLRREV
		wCliente   := M->C5_CLIENTE
		wLoja      := M->C5_LOJAENT

		nPosVlUnit := AScan(aHeader, { |x| Alltrim(x[2]) == 'C6_PRUNIT'})
		wNPrcVen   := aCols[n,nPosVlPrc]
		nPrcVenOri := aCols[n,nPosVlPrc]
		nPrcUntOri := aCols[n,nPosVlUnit]

		//Verifica se o codigo do produto nao esta vazio
		If !EMPTY(wProduto) .AND. M->C5_TIPO == 'N'
			dbSelectArea("SA1")
			dbSetOrder(1)
			If !dbSeek(xFilial("SA1")+wCliente+wLoja)
				MsgStop("Cliente "+wCliente+"/"+wLoja+", nao cadastrado no Cadastro de Clientes")
			Else

				DbSelectArea("SB1")
				DbSetOrder(1)
				If !dbSeek(xFilial("SB1")+wProduto,.F.)
					MsgStop("Produto "+Alltrim(wProduto)+", nao esta cadastrado")
				ElseIf Alltrim(SB1->B1_GRUPO) $ "PA#PR" .AND. M->C5_TIPO == "N"
					wCalcPreco	:= .T.
				Else
					wCalcPreco	:= .F.
				EndIf

				If wCalcPreco


					//transferencia vinilico
					If (AllTrim(cEmpAnt) == "07" .And. AllTrim(M->C5_CLIENTE) == '029954' .AND. AllTrim(M->C5_YLINHA) == '6')
						wNPrcVen 				:= PrcVenTrans()
						wNPrcVen				:= Round(wNPrcVen,2)
						wValor 					:= Round(wC6QTDVEN * wNPrcVen, 2)
						aCols[n,nPosVlTab]		:= wNPrcVen
						aCols[n,nPosVlUni]  	:= wNPrcVen
						aCols[n,nPosVlTotal]  	:= wValor
						Return(wNPrcVen)
					EndIf

					//Busca o preco do Produto na tabela de preco.
					If cEmpAnt <> "07" .And. M->C5_CLIENTE == "010064"

						__nFatRed := 0

						nPreco	:= U_fGetPrcLM(M->C5_NUM,M->C5_YEMPPED,wProduto,wItem,M->C5_CLIENTE,M->C5_LOJACLI,@__nFatRed)

						aCols[n,nPosFRed] := __nFatRed

					Else
						aImp 	:= U_fItImpos(N,{"IT_ALIQICM","IT_ALIQCMP","IT_ALFCCMP"}) //Icms Origem / Icms Destino / Aliq. Fundo Pobreza

						__nFatMul := 0

						nPreco	:= U_fBuscaPreco(M->C5_YLINHA,M->C5_TABELA,wProduto,Dtos(M->C5_EMISSAO),M->C5_CLIENTE,M->C5_LOJACLI,M->C5_YSUBTP,aImp[1],aImp[2],aImp[3],cTES,@__nFatMul,M->C5_TRANSP, wEmpPed)

						aCols[n,nPosFMul] := __nFatMul

						If AllTrim(CEMPANT) == "07"

							SM0->(DbSetOrder(1))
							SM0->(DbSeek(AllTrim(CEMPANT)+AllTrim(CFILANT)))

							aCols[n,nPosFRed] := U_LMFatRed(SM0->M0_ESTCOB)

						EndIf

					EndIf

					//Verifica se existe mais de 1 registro
					If nPreco == 0
						nPreco					:= 0
						aCols[n,nPosVlPrc]		:= 0
						aCols[n,nPosVlUni]   	:= 0
						aCols[n,nPosVlTotal]	:= 0
					Else

						If nPreco <= 0
							MsgStop("Nao existe tabela de preco para este produto.")
						EndIf

						IF ALLTRIM(__READVAR) <> 'M->C6_PRCVEN' //CAMPOS QUANTIDADE, DT. NECESSIDADE, DESCONTO ESPECIAL - OUTROS, E DNV

							//Calcula Acrescimo financeiro, frete, seguro, descontos
							wNPrcVen  	:= 0
							wC6PRCVEN	:= 0

							wC6QTDVEN	:= aCols[n,nPosQtdVnd]
							wC6YDESC	:= aCols[n,nPosDesc]
							wC6YPERC	:= aCols[n,nPosPerc]
							wC6DESCONT 	:= aCols[n,nPosVlDesc]

							//Calcular Descontos
							wNPrcVen := nPreco

							//Para atender as vendas de industrialização da Victer para Biancogres - OS: 0754-16
							If cEmpAnt == "14" .And. M->C5_CLIENTE == "000481" .And. Alltrim(M->C5_YSUBTP) == "N" .And. M->C5_TABELA == "001"
								wC5YMAXCND		:= 1
								M->C5_YMAXCND	:= 1
							EndIf

							//Multiplica preco da tabela * fator financeiro
							If wC5YMAXCND > 0
								wNPrcVen := wNPrcVen * wC5YMAXCND
							EndIf

							//Fernando/Facile em 18/09 - nao estava calculando esse campo em tempo de pedido - so no M410AGRV
							//Salvar o preço antes da aplicacao do desconto.
							aCols[n,nPosVlTab]		:= wNPrcVen

							//Aplicar o desconto do item
							wNPrcVen := wNPrcVen - (wNPrcVen * (wC6YDESC / 100))

							//Aplicar Acrescimo quando for função de REAJUSTE DE PREÇO
							If (IsInCallStack("U_M410RPRC"))

								wC6REAJUST	:= aCols[n,nPosPReaj]
								If ( wC6REAJUST > 0 )

									wNPrcVen := wNPrcVen + (wNPrcVen * (wC6REAJUST / 100))

								EndIf

							EndIf

							//Quando usando Proposta de Engenharia Aprovada - Ajustar o desconto especial para o preco final ser o mesmo da proposta
							IF !Empty(M->C5_YNPRENG) .And. (ALLTRIM(__READVAR) <> 'M->C6_YDESP') .And. !(IsInCallStack("U_M410RPRC"))

								__nTabZ68 := "% Z69010 %"

								If M->C5_YLINHA == "2" .Or. M->C5_YLINHA == "3"
									__nTabZ68 := "% Z69050 %"
								EndIf

								__cAliasTmp := GetNextAlias()
								BeginSql Alias __cAliasTmp
								%NoParser%

								select Z69_PRCVEN 
								from %Exp:__nTabZ68% 
								where Z69_FILIAL = %XFilial:Z68% 
								and Z69_NUM+Z69_REV = %Exp:AllTRim(M->C5_YNPRENG)% 
								and Z69_CODPRO = %Exp:wProduto% 
								and Z69_ITEM = %Exp:wItem%
								and D_E_L_E_T_=''   
								ORDER BY Z69_CODPRO, Z69_ITEM

								EndSql

								If !(__cAliasTmp)->(Eof()) .And. ( Round(wNPrcVen,2) <> Round((__cAliasTmp)->Z69_PRCVEN,2) )

									__nNovoPrc := Round((__cAliasTmp)->Z69_PRCVEN,2)

									__nDTOT := Round(((aCols[n,nPosVlTab] - __nNovoPrc)/aCols[n,nPosVlTab])*100 ,2)

									__nDESP := (1 - ( 1 -  __nDTOT/100 )/(1 - (aCols[n,nPosDescReg]/100)))*100

									aCols[n,nPosDOut] := __nDESP
									aCols[n,nPosDesc] := __nDTOT
									wC6YDESC	:= aCols[n,nPosDesc]
									__nDESP := 0

									wNPrcVen := aCols[n,nPosVlTab] - (aCols[n,nPosVlTab] * (wC6YDESC / 100))

								EndIf

								(__cAliasTmp)->(DbCloseArea())

							ENDIF

							//Somou o valor do frete/seguro
							wNPrcVen := wNPrcVen + wC5VLRFRET + wC5YVLRREV

							ProcFrete()//atualizo variaveis privadas dentro dessa funcao


							//Substraindo o DM
							If M->C5_YRECR == "S"
								wNPrcVen := wNPrcVen * GetMV("MV_YRECR")
							EndIf

							SA1->(dbSetOrder(1))
							If  SA1->(dbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,.F.))
								If SA1->A1_EST == "EX"
									wNPrcVen := Round(wNPrcVen,4)
								Else
									wNPrcVen := Round(wNPrcVen,2)
								EndIf
							EndIf

							//Calcular Total
							wValor := Round(wC6QTDVEN * wNPrcVen,2)
							aCols[n,nPosVlUni]  	:= wNPrcVen
							aCols[n,nPosVlTotal]  	:= wValor
							RETURN( wNPrcVen )

						ELSE

							wC6QTDVEN	:= aCols[n,nPosQtdVnd]
							wC6YDESC	:= aCols[n,nPosDesc]
							wC6YPERC	:= aCols[n,nPosPerc]

							aCols[n,nPosVlUnit] := aCols[n,nPosVlPrc]
							RETURN( aCols[n,nPosVlPrc] )

						ENDIF

					EndIf

				Else
					//Para produtos DIFERENTE DE PA
					IF Alltrim(M->C5_TIPO) $ "N_B" .AND. M->C5_CLIENTE <> "010064"
						wValor					:= Round(wC6QTDVEN * wNPrcVen,2)
						aCols[n,nPosVlUnit]		:= wNPrcVen
						aCols[n,nPosVlPrc]		:= wNPrcVen
						aCols[n,nPosVlTotal]	:= wValor
					ENDIF
					IF M->C5_CLIENTE == "010064"
						aCols[n,nPosVlPrc]  := nPrcVenOri
						aCols[n,nPosVlUnit] := nPrcUntOri
					ENDIF
				EndIf
			EndIf
		EndIf
	EndIf

	//PROVISÓRIO - SERA SUBSTITUIDO POR OUTRA OPERAÇÃO - RANISSES, WANISAY E TANIA EM 08/07/16
	IF Alltrim(M->C5_YSUBTP) $ "O" .And. SUBSTR(wProduto,1,3) == "216"
		wValor					:= Round(wC6QTDVEN * wNPrcVen,2)
		aCols[n,nPosVlUnit]		:= wNPrcVen
		aCols[n,nPosVlPrc]		:= wNPrcVen
		aCols[n,nPosVlTotal]	:= wValor
	ENDIF

	IF Alltrim(M->C5_TIPO) $ "B"
		wValor					:= Round(wC6QTDVEN * wNPrcVen,2)
		aCols[n,nPosVlUnit]		:= wNPrcVen
		aCols[n,nPosVlPrc]		:= wNPrcVen
		aCols[n,nPosVlTotal]	:= wValor
	ENDIF

	//TRATAMENTO EMPRESA VITCER
	IF Alltrim(M->C5_YSUBTP) $ "RR_RQ" .And. cEmpAnt == "14"
		aCols[n,nPosVlUnit]		:= wNPrcVen
		aCols[n,nPosVlPrc]		:= wNPrcVen
		wValor					:= Round(wC6QTDVEN * wNPrcVen,2)
		aCols[n,nPosVlTotal]	:= wValor
	ENDIF

	IF M->C5_CLIENTE == "010064"
		aCols[n,nPosVlUnit] := aCols[n,nPosVlPrc]
	ENDIF

	RestArea(aAreaSA1)
	RestArea(aAreaSB1)
	RestArea(aArea)

Return(wNPrcVen)

Static Function PrcVenTrans()

	Local _cQuery 		:= ""
	Local _cAliasTmp	:= Nil
	Local _nPrecoVend	:= 0
	Local _cLocalProd	:= aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOCAL"})]
	Local _cEmpPed		:= cEmpAnt

	_cQuery := " select B2_CM1 from " + RetFullName("SB2", _cEmpPed) + "			"
	_cQuery += "	where 															"
	_cQuery += "	B2_COD			= '"+wProduto+"'								"
	_cQuery += "	AND B2_LOCAL	= '"+_cLocalProd+"'								"
	_cQuery += "	AND B2_FILIAL	= '"+xFilial('SB2')+"'							"
	_cQuery += "	AND D_E_L_E_T_	= ''											"

	_cAliasTmp	:= GetNextAlias()

	TCQUERY _cQuery NEW ALIAS (_cAliasTmp)

	If !(_cAliasTmp)->(Eof())
		_nPrecoVend	:= (_cAliasTmp)->B2_CM1
	EndIf

	If (_nPrecoVend <= 0)
		Msgbox("Pedido de transferência cliente '029954'. Preço de venda zerado, favor verificar.","BIA436","STOP")
	EndIf

	(_cAliasTmp)->(DbCloseArea())

Return _nPrecoVend


Static Function ProcFrete()

	Local _cProdFrete 	:= wProduto
	Local _cLoteFrete	:= wLote
	Local _nQuantFrete	:= wC6QTDVEN
	Local _nPrecoFrete	:= wNPrcVen
	Local _cQuery		:= "SELECT PESO=[dbo].[GET_PESO_PRODUTO] ('"+_cProdFrete+"', '"+_cLoteFrete+"', '"+cValTochar(_nQuantFrete)+"')"
	Local _cAliasTmp	:= Nil
	Local _nPeso		:= 0
	Local oObj 			:= TCalculoFreteVinilico():New()

	Local _nVlrFrete 	:= 0
	Local _nVlrProd		:= 0
	Local _nVlrSeguro	:= 0

	If (AllTrim(M->C5_YLINHA) == '6' .And. M->C5_TPFRETE == 'C')

		_cAliasTmp	:= GetNextAlias()

		TCQUERY _cQuery NEW ALIAS (_cAliasTmp)

		If !(_cAliasTmp)->(Eof())

			_nPeso 	:= (_cAliasTmp)->PESO


			oObj:cCliente 	:= M->C5_CLIENTE
			oObj:cLoja 		:= M->C5_LOJACLI
			oObj:cProduto 	:= _cProdFrete
			oObj:nQuant 	:= _nQuantFrete
			oObj:nPeso 		:= _nPeso
			oObj:nVlrProd	:= _nPrecoFrete

			_nVlrFrete 	:= oObj:CalcFrete()
			_nVlrProd	:= oObj:CalcVlrProd()
			_nVlrSeguro	:= oObj:CalcSeguro()

			wNPrcVen := _nVlrProd + 0.005   //sempre arredondar para cima
			aCols[n, nPosVFrtUn]	:= Round(_nVlrFrete, 4)
			aCols[n, nPosVSegUn]	:= Round(_nVlrSeguro, 4)

		EndIf

		(_cAliasTmp)->(DbCloseArea())

	EndIf


	If (AllTrim(M->C5_YLINHA) == '6' .And. M->C5_TPFRETE == 'C')
		If (_nVlrFrete <= 0)
			Msgbox("Não foi encontrado tabela de frete. Favor verificar.","BIA436","STOP")
		EndIf
	EndIf


Return
