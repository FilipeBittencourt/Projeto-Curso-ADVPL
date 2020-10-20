#INCLUDE "protheus.ch" 
#INCLUDE "topconn.ch"
#INCLUDE "rwmake.ch"

//------------------------------------------------------------------------
/*/{Protheus.doc} GATSLR01
	@description Efetua a alteração dos campos da GRID conforme campos
	de cabeçalho.
	@author Guilherme Covre Dalleprane
	@since 03.01.2017
	@version 1.0
/*/
//------------------------------------------------------------------------

User Function GATSLR01(nX)

	Local nI			:= 0
	Local cCampo		:= ReadVar()

	Private nPProd		:= 0 // Posicao do codigo do produto
	Private nPCult		:= 0
	Private nPQuant		:= 0 // Posicao da quantidade
	Private nPVlUnit	:= 0 // Posicao do valor unitario do item
	Private nPVlItem	:= 0 // Posicao do valor total do item
	Private nPDesc		:= 0 // Posicao do percentual de desconto
	Private nPValDes	:= 0 // Posicao do valor de desconto
	Private nPValAcr	:= 0 // Posicao do valor de acrescimo da regra
	Private nPPerDes	:= 0 // Posicao do percentual de desconto da regra
	Private nPPrcTab	:= 0 // Posicao do preco de tabela
	Private nPFrete		:= 0 // Posicao do valor do frete
	Private nPTES		:= 0 // Posicao da TES padrao
	Private nPClFis 	:= 0 // Posicao do valor do classe fiscal
	Private nPLocal		:= 0 // Posicao do armazem/local padrao

	Private nPDTabela	:= 0 // Posicao da tabela de preco utilizada
	Private nPDPrcTab	:= 0 // Posicao do preco de tabela
	Private nPDTES		:= 0 // Posicao da TES padrao
	Private nPDCF		:= 0 // Posicao do CF padrao	
	Private nPDLocal	:= 0 // Posicao do armazem/local padrao			   												

	// --------------------------------------------
	// Atualiza posição de campos contidos na 
	// GRID PRINCIPAL
	// --------------------------------------------

	For nI := 1 To Len(aPosCpo)
		If AllTrim(Upper(aPosCpo[nI, 1])) == "LR_PRODUTO"
			nPProd := aPosCpo[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpo[nI, 1])) == "LR_YCULTRA"
			nPCult := aPosCpo[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpo[nI, 1])) == "LR_QUANT"
			nPQuant := aPosCpo[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpo[nI, 1])) == "LR_VRUNIT"
			nPVlUnit := aPosCpo[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpo[nI, 1])) == "LR_VLRITEM"
			nPVlItem := aPosCpo[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpo[nI, 1])) == "LR_DESC"
			nPDesc := aPosCpo[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpo[nI, 1])) == "LR_VALDESC"
			nPValDes := aPosCpo[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpo[nI, 1])) == "LR_YVLRACR"
			nPValAcr := aPosCpo[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpo[nI, 1])) == "LR_YPERDES"
			nPPerDes := aPosCpo[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpo[nI, 1])) == "LR_YPRCTAB"
			nPPrcTab := aPosCpo[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpo[nI, 1])) == "LR_YFRETE"
			nPFrete := aPosCpo[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpo[nI, 1])) == "LR_YTES"
			nPTES := aPosCpo[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpo[nI, 1])) == "LR_CLASFIS"
			nPClFis := aPosCpo[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpo[nI, 1])) == "LR_YLOCAL"
			nPLocal := aPosCpo[nI, 2]
		EndIf
	Next
	
	// --------------------------------------------
	// Atualiza posição dos campos contidos na 
	// GRID DE DETALHES DO ITEM
	// --------------------------------------------

	For nI := 1 To Len(aPosCpoDet)
		If AllTrim(Upper(aPosCpoDet[nI, 1])) == "LR_TABELA"
			nPDTabela := aPosCpoDet[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpoDet[nI, 1])) == "LR_PRCTAB"
			nPDPrcTab := aPosCpoDet[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpoDet[nI, 1])) == "LR_TES"
			nPDTES := aPosCpoDet[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpoDet[nI, 1])) == "LR_CF"
			nPDCF := aPosCpoDet[nI, 2]
		EndIf

		If AllTrim(Upper(aPosCpoDet[nI, 1])) == "LR_LOCAL"
			nPDLocal := aPosCpoDet[nI, 2]
		EndIf		
	Next

	// --------------------------------------------
	// Execução de GATILHOS
	// --------------------------------------------

	If !Empty(aCols) .And. !Empty(aCols[1, nPProd])

		If !Empty(nX)			
			If "LR_QUANT" $ cCampo
				// Atualiza valores do item
				U_GATSLR04(nX)
			EndIf

			If "LR_VRUNIT" $ cCampo
				// Atualiza valores do item
				U_GATSLR04(nX)
			EndIf

			If "LR_PRODUTO" $ cCampo
				// Atualização de dados fiscais
				U_GATSLR03(nX)		

				// Atualização de Armazem
				U_GATSLR02(nX)

				// Atualiza valores do item
				U_GATSLR04(nX)

				// Adiciona produtos sugeridos
				U_GATSLR05(nX)
				
				// Atualiza cultura do item
				U_GATSLR06(nX)
			EndIf
			
			// --------------------------------------------
			//  Campos customizados para visualizacao no 
			//  grid principal do venda assistida
			// --------------------------------------------
			
			If "LR_YLOCAL" $ cCampo
				U_GATSLR07(nX)
			EndIf
			
			If "LR_DESC" $ cCampo
				U_GATSLR04(nX)
			EndIf
			
			If "LR_VALDESC" $ cCampo
				U_GATSLR04(nX)
			EndIf
			
		EndIf

	EndIf
	
	Eval(bRefresh)	

Return &(cCampo)

//------------------------------------------------------------------------
/*/{Protheus.doc} GATSLR02
	@description Atualiza ARMAZEM (LOCAL DE ESTOQUE)
	@author Guilherme Covre Dalleprane
	@since 08.02.2017
	@version 1.0
/*/
//------------------------------------------------------------------------

User Function GATSLR02(nI)
	Local cCampo := ReadVar()
	Local cLocal := "" 

	If !lAutoExec

		If M->LQ_YVENFUT == "S" .And. M->LQ_YESTVEF == "C"
			cLocal := "08" // Alterar para parametro
		Else
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1") + aCols[nI, nPProd]))
				cLocal:= SB1->B1_LOCPAD
			EndIf
		EndIf

		aCols[nI,nPLocal] 		:= cLocal
		aColsDet[nI,nPDLocal]	:= cLocal
	EndIf

Return &(cCampo)

//------------------------------------------------------------------------
/*/{Protheus.doc} GATSLR03
	@description Atualiza INFORMACOES FISCAIS da tela de vendas
	@author Guilherme Covre Dalleprane
	@since 08.02.2017
	@version 1.0
/*/
//------------------------------------------------------------------------

User Function GATSLR03(nI)
	Local cCampo	:= ReadVar()
	Local cTES 		:= ""
	Local cYTESVEF	:= GetMv('MV_YTESVEF')

	If (M->LQ_YVENFUT == "S")
		cTes := cYTESVEF
	Else
		cTes := MaTesInt(2, "01", M->LQ_CLIENTE, M->LQ_LOJA, "C", aCols[nI, nPProd])
	EndIf

	If MaFisFound("NF")
		MaFisAlt("NF_UFDEST", SA1->A1_EST)
	EndIf

	SF4->(DbSetOrder(1))
	If SF4->(DbSeek(xFilial("SF4")+cTes))			
		MaFisAlt("IT_TES", cTes, nI)

		aColsDet[nI,nPDTES]		:= cTes
		aColsDet[nI,nPDCF] 		:= SF4->F4_CF

		aCols[nI,nPTES] 		:= cTes
		aCols[nI,nPClFis]		:= StrZero(Val(SF4->F4_SITTRIB), 3)		
	EndIf
	
Return &(cCampo)

//------------------------------------------------------------------------
/*/{Protheus.doc} GATSLR04
	@description Atualiza VALORES
	@author Guilherme Covre Dalleprane
	@since 08.02.2017
	@version 1.0
/*/
//------------------------------------------------------------------------

User Function GATSLR04(nI)
	Local lLJCNVDA		:= GetMV("MV_LJCNVDA")
	Local lYCALFRE		:= GetMV("MV_YCALFRE")
	Local cTABPAD		:= GetMV("MV_TABPAD")
	Local cLJRETVL		:= GetMV("MV_LJRETVL")
	Local cCampo 		:= ReadVar()
	Local lSomaFre		:= .F.
	Local lErroFre		:= .F.	
	Local lPanVA3		:= .F.
	Local aDescAcres	:= {}	
	Local aCalcFre		:= {}
	Local nValFre   	:= 0
	Local nDespesa		:= 0
	Local nAuxTotal   	:= 0
	Local nPrcTab		:= 0
	Local nX			:= 0

	Local aAreaSE4		:= SE4->(GetArea())
	Local aAreaSF4      := SF4->(GetArea())
	Local aAreaSB1      := SB1->(GetArea())
	Local aAreaSB0      := SB0->(GetArea())
	Local aAreaSA1      := SA1->(GetArea())
	Local aAreaSZA      := SZA->(GetArea())
	Local aAreaSZS		:= SZS->(GetArea())
	
	SZS->(DbSetOrder(1))
	If SZS->(DbSeek(xFilial("SZS") + FWFilial())) .And. !SZS->ZS_TIPOFIL == "8" 
	
		If !lLJCNVDA
			
			If Type("oCondPg") == "O"
				lPanVA3 := oCondPg:lVisible 	//Quando igual a .T., foi chamado a partir da tela de definicao de pagamentos.
			EndIf
	
			If !Empty(M->LQ_CLIENTE) .And. !Empty(M->LQ_LOJA) .And. !Empty(M->LQ_YCOND) .And. !Empty(aCols) .And. !Empty(aCols[nI, nPProd])
				// ------------------------------------------------------
				// Caso o produto não esteja excluído, retira o valor 
				// do item do total e subtotal da tela de vendas, pois
				// este valor será recalculado e somado posteriormente.
				// ------------------------------------------------------
		
				SB1->(DbSetOrder(1))
				If SB1->(DbSeek(xFilial("SB1") + aCols[nI, nPProd]))
		
					nAuxTotal := 0
					For nX := 1 To Len(aCols)
						If nX != nI .And. !GdDeleted(nX, aHeader, aCols)
							nAuxTotal += aCols[nX,nPVlItem]
						EndIf
					Next
		
					Lj7T_Subtotal(2, nAuxTotal)
							
					// Obtem regra de descontos e acrescimos
					aDescAcres := U_LIBY002D(aCols[nI, nPProd], M->LQ_CLIENTE, M->LQ_LOJA, M->LQ_YCOND, M->LQ_YFILPED)
					
					If SB0->(DbSeek(xFilial("SB0") + aCols[nI, nPProd]))
						nPrcTab := SB0->&("B0_PRV" + cTABPAD)		
					EndIf
		
					// ----------------------------------------------------------------------------------------
					// IMPORTANTE: Por padrao a ECF nao faz arredondamento, portanto o parametro MV_ARREFAT
					//             deve estar como N - NAO ARREDONDA.
					//             O calculo abaixo esta configurado para nao arredondar os valores.
					//             Observar que o valor desconto calcula com a precisao do numero de decimais 
					//             do campo L2_VALDESC
					// ----------------------------------------------------------------------------------------
		
					nPerDes		:= aDescAcres[1]
					nPerAcr		:= aDescAcres[2]
		
					nVlrAcr		:= Round(nPrcTab * nPerAcr / 100,2)				
					
					SE4->(DbSetOrder(1))
					If SE4->(DbSeek(xFilial("SE4") + M->LQ_YCOND))					
						If lYCALFRE .And. SE4->E4_YCALFRE
							//Valor total do frete
							aCalcFre 	:= U_CLJCFV(SB1->B1_COD,M->LQ_CLIENTE,M->LQ_LOJA,aCols[nI, nPQuant],aColsDet[nI,nPDPrcTab])
							
							nValFre := aCalcFre[1]
							
							lSomaFre 	:= aCalcFre[2]
							lErroFre	:= aCalcFre[3]
			
							If lSomaFre		
								// Soma o valor do frete aos acrescimos.
								nVlrAcr	:= nVlrAcr + (nValFre / aCols[nI, nPQuant])
								nValFre	:= 0
							EndIf
			
						EndIf
					EndIf
					
					// Soma acrescimos ao preço de tabela
					nPrcTab     += nVlrAcr
		
					//Valor total do acrescimo conforme a quantidade
					nVlrAcr     := nVlrAcr * aCols[nI, nPQuant]
		
					//Valor total bruto do item pelo preco de tabela
					nVlrItem 	:= nPrcTab * aCols[nI, nPQuant]
		
					//Valor total do desconto
					nVlrDes  	:= nPrcTab - NoRound(nPrcTab - (nPerDes * nPrcTab / 100), 2)
					nVlrDes		:= Round(nVlrDes * aCols[nI, nPQuant], 2)
		
					//Valor total liquido
					nVlrItem 	:= Round(nVlrItem - nVlrDes,2)
		
					//Valor unitario liquido
					nVlrUni  	:= Round(nVlrItem / aCols[nI, nPQuant],2)
		
					// Atualiza aCols PRINCIPAL
					aCols[nI,nPPrcTab] 	:= nPrcTab
					aCols[nI,nPVlUnit]	:= nVlrUni
					aCols[nI,nPVlItem] 	:= nVlrItem
					
					aCols[nI,nPDesc] 	:= nPerDes
					aCols[nI,nPValDes] 	:= nVlrDes
					
					aCols[nI,nPPerDes] 	:= nPerDes	
					aCols[nI,nPFrete] 	:= nValFre

					aCols[nI,nPValAcr] 	:= nVlrAcr				
		
					// Atualiza aCols DE DETALHES
					aColsDet[nI,nPDPrcTab] := nPrcTab
		
					// Chama a funcao MaFisAlt somente quando for alteracao de algum produto.   ³
					// Cuidado com a alteracao destas linhas pois afeta diretamente quando eh   ³
					// utilizado descontos no item e total dos produtos                         ³
					MaFisAlt("IT_VALMERC"	, nVlrItem + nVlrDes, nI)
					MaFisAlt("IT_PRCUNI"	, nVlrUni, nI)
					MaFisAlt("IT_DESCONTO"	, nVlrDes, nI)
		
					//Armazena o valor da despesa, que corresponde ao frete informado sobre o total da venda.
					If lPanVA3
						nDespesa := MaFisRet(nI, "IT_DESPESA")
					EndIf
		
					//Caso esteja na tela de definicao de pagamentos, restaura o valor da despesa que existia anteriormente,
					//pois ao ajustar o array de Detalhe o mesmo fica zerado, o que faz com que o calculo dos totais fique inconsistente.
					If lPanVA3
						MaFisAlt("IT_DESPESA"	,nDespesa , nI)
					EndIf
		
					If !GdDeleted(nI, aHeader, aCols)
		
						// Acrescenta o valor do item no SubTotal e Total
		
						nAuxTotal := LJ7T_Subtotal(2) + MaFisRet(nI, "IT_TOTAL")
						//Se resultar num valor negativo, zera o Subtotal e Total
						nAuxTotal := Max(nAuxTotal, 0)
		
						Lj7T_Subtotal(2, nAuxTotal)
						If lPanVA3
							Lj7T_Total( 2, Lj7T_SubTotal(2) - Lj7T_DescV(2) + LJ7CalcFrete() )
						Else
							Lj7T_Total( 2, Lj7T_SubTotal(2) - Lj7T_DescV(2) )
						EndIf
					EndIf
		
					lCLJGPG := .T.
				EndIf
			EndIf
		EndIf
	EndIf
	RestArea(aAreaSE4)
	RestArea(aAreaSF4)
	RestArea(aAreaSB1)
	RestArea(aAreaSB0)
	RestArea(aAreaSA1)
	RestArea(aAreaSZA)
	RestArea(aAreaSZS)

Return &(cCampo)
//------------------------------------------------------------------------
/*/{Protheus.doc} GATSLR05
	@description Busca os produtos sugeridos a serem vendidos junto 
				 com o produto principal e insere os selecionados na 
				 grid da venda assistida
	@author Alexandre Fortunato Ribeiro
	@since 18.12.2018
	@version 2.0
/*/
//------------------------------------------------------------------------

User Function GATSLR05(nX)
	Local cCampo	:= ReadVar()
	Local nJ := 1
	Local cCodigo := aCols[nX, nPProd]
	Local aCodigos := {}
	

	If !IsBlind() .And. AllTrim(FunName()) $ "LOJA701" .And. !IsInCallStack("Lj7LancItem")
		
		aCodigos := U_LOJAY031(cCodigo)	 

		If !Empty(aCodigos) 
			WHILE nJ <= Len(aCodigos)
				Lj7LancItem(aCodigos[nJ]) //RunTrigger(2,Len(aCols),nil,,'LR_PRODUTO')									
				nJ++				
				//n ++
			Enddo
		Endif
	Endif
	
Return &(cCampo)

//------------------------------------------------------------------------
/*/{Protheus.doc} GATSLR06
	@description Busca a cultura do cadastro de complemento do produto
	@author Guilherme Covre Dalleprane
	@since 17.01.2019
	@version 2.0
/*/
//------------------------------------------------------------------------

User Function GATSLR06(nI)
	Local cCampo	:= ReadVar()
	Local aAreaSB5 	:= SB5->(GetArea())

	SB5->(DbSetOrder(1))
	If SB5->(DbSeek(xFilial("SB5") + aCols[nI, nPProd]))
		If SB5->B5_YCTRCUL == '1'
			aCols[nI, nPCult] := SB5->B5_CULTRA
		Else
			aCols[nI, nPCult] := ""
		EndIf
	EndIf
	
	RestArea(aAreaSB5)
Return &(cCampo)

//------------------------------------------------------------------------
/*/{Protheus.doc} GATSLR07
	@description Propaga gatilhos do campo LR_YLOCAL
	@author Guilherme Covre Dalleprane
	@since 25.01.2019
	@version 2.0
/*/
//------------------------------------------------------------------------

User Function GATSLR07(nI)
	Local cCampo	:= ReadVar()
	
	aColsDet[nI, nPDLocal] := aCols[nI, nPLocal]
	
Return &(cCampo)
