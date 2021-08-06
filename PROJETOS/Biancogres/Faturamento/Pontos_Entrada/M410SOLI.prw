#include "rwmake.ch"
#include "topconn.ch"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} M410SOLI
@author Ranisses A. Corona
@since 25/07/2008
@version 1.0
@description P.E. utilizado para calculo dos valores do ICMS ST na Planilha Financeira no Pedido de Venda.
@history 04/11/2016, Ranisses A. Corona, Correção e melhorias na gravação do valor dos impostos por item. OS: 4052-16 Mayara Trigueiro / 3888-16 Elaine Sales
@type function
/*/

User Function M410SOLI()

	//Definicao de variaveis
	Local wLinhas			:= PARAMIXB[1]
	Local cCliEsp			:= "N" //CLIENTE ESPECIAL - APENAS PARA TRATAR O CLIENTE 015966-01
	Local nVlrFret			:= 0
	Local nVlrMerc			:= 0
	Local cUFSTCD			:= GetMV("MV_YUFSTCD") //Estados COM Destaque do ICMS ST na NF
	Local cUFSTSD			:= GetMV("MV_YUFSTSD") //Estados SEM Destaque do ICMS ST na NF
	Local aCliFor			:= {}
	Local lAchouPes			:= .F.
	Local cEST				:= ""
	Local cMUN				:= ""
	Local cRegEsp			:= ""
	Local __nAliIcms
	Local __nBaseIcms


	//Variaveis de Posicionamento
	//--------------------------------
	Private	aArea	:= GetArea()
	//--------------------------------

	Private aSolid			:= {}
	Private aMVA			:= {}
	Private nAliqIcms		:= AliqIcms(M->C5_TIPO,"S",M->C5_TIPOCLI,"S")/100 					// Retorna a Aliquota interna do Estado de Origem
	Private cTpTrans		:= Posicione("SA4",1,xFilial("SA4")+M->C5_TRANSP,"A4_YTIPO")		// Define o Tipo de Transportadora
	Private cUFTrans		:= SA4->A4_EST
	Private wPesoLiq		:= 0
	Private LiqC 			:= 0
	Private _peso			:= 0
	Private _volu			:= 0
	Private wPesoBr			:= 0
	Private wVt				:= 0
	Private wBaseCalc		:= 0
	Private aVlST			:= {}  //Base e Valor ST
	Private cRegEsp			:= ""
	Private cGrpPd			:= SB1->B1_GRTRIB
	Private	cNCM			:= SB1->B1_POSIPI

	If Type("lAtuImp") == "U"
		Private	lAtuImp	:= .F.
	EndIf

	//Inicio do Programa
	If Alltrim(M->C5_TIPO) == "I" //Complemento de ICMS - Não realiza o calculo

		Return(aSolid)

	Else

		If  !(M->C5_TIPO $ "D_B") .And. M->C5_CLIENTE == "015966"
			cCliEsp := "S"
		EndIf

		//Posiciona e busca informações do cadastro do CLIENTE ou FORNECEDOR, pelo Tipo do Pedido e função.
		aCliFor		:= U_fGetUF(FunName())
		lAchouPes	:= aCliFor[1]
		cEST		:= aCliFor[2]
		cMUN		:= aCliFor[3]
		cRegEsp		:= aCliFor[4]

		If lAchouPes

			//ICMS ST com e sem Destaque na NF
			If Alltrim(M->C5_TIPOCLI) == "S" .And. AllTrim(SB1->B1_TIPO) $ "PA_PR" .And. ( Alltrim(cEST) $ cUFSTCD .Or. Alltrim(cEST) $ cUFSTSD )

				//Calcula ST se houver a cobranca do ICMS
				If MaFisRet(wLinhas,"IT_VALICM") > 0 .Or. ( Alltrim(cEST) == "AP" .And. (  MaFisRet(wLinhas,"IT_DESCZF") - ( MaFisRet(wLinhas,"IT_DESCZFCOF")+MaFisRet(wLinhas,"IT_DESCZFPIS") ) ) > 0)

					If MaFisRet(wLinhas,"IT_VALICM") > 0
						nIcms := MaFisRet(wLinhas,"IT_VALICM")
					Else
						nIcms := ( MaFisRet(wLinhas,"IT_DESCZF") - ( MaFisRet(wLinhas,"IT_DESCZFCOF")+MaFisRet(wLinhas,"IT_DESCZFPIS") ) )
					EndIf

					If GdDeleted(wLinhas) == .F.

						//Grava o Produto e Lote
						nProduto	:= Gdfieldget("C6_PRODUTO",wLinhas)
						nLote		:= Gdfieldget("C6_LOTECTL",wLinhas)

						//Se o Transportador for do Tipo 1 Autonomo ou Tipo 2 Transportadora de fora do estado - OS 3724-16
						If (cTpTrans == "1") .Or. (cTpTrans == "2" .And. !cUFTrans == "ES")
							wBaseCalc 	:= U_fCalcFreteAut(cEST,cMUN,nProduto,nLote,QUANTITEM)[1] //Posicao 1 retorna a Base
						EndIf

						//CONFORME OS 2771-12 E OS 1048-13 (ES)
						//If MaFisRet(wLinhas,"IT_DESCONTO") > 0 .And. Alltrim(cEST) $ ("BA_ES")
						If MaFisRet(wLinhas,"IT_DESCONTO") > 0 .And. Alltrim(cEST) == "ES" //Retira UF da BA conforme OS 3371-15, em 27/08/15
							nVlrMerc := MaFisRet(wLinhas,"IT_VALMERC")-MaFisRet(wLinhas,"IT_DESCONTO")
						Else
							nVlrMerc := MaFisRet(wLinhas,"IT_VALMERC")
						EndIf

						//Buscando base e aliquota ICMS - Ticket 21807
						__nAliIcms := MaFisRet(wLinhas,"IT_ALIQICM")
						__nBaseIcms := MaFisRet(wLinhas,"IT_BASEICM")

						//Grava a Base e o Valor da ST
						aSolid := U_fCalcVlrST(cGrpPd,cNCM,cRegEsp,cCliEsp,cEST,nVlrMerc,nIcms,MaFisRet(wLinhas,"IT_VALIPI"),wBaseCalc,nVlrFret,M->C5_CLIENTE,__nAliIcms,__nBaseIcms)

						//NFE 4.0 - ajustando calculo de FECP quando o ICMS ST eh ajusatdo pelo ponto de entrada
						_ALIQFECP := MaFisRet(1,"IT_ALFCST")

						If (_ALIQFECP > 0)

							aAdd(aSolid, aSolid[1])  //5  BASE FECP
							aAdd(aSolid, _ALIQFECP)  //6  aliq FECP
							aAdd(aSolid, Round( (aSolid[1] * _ALIQFECP)/100 ,2) )  // VALOR FECP

						Else

							aAdd(aSolid, 0)
							aAdd(aSolid, 0)
							aAdd(aSolid, 0)

						EndIf

					Else

						//Tratamento para Zerar o ICMS quando nao houver calculo pelo sistema.
						aAdd(aSolid, 0) //1
						aAdd(aSolid, 0) //2
						aAdd(aSolid, 0) //3
						aAdd(aSolid, 0) //4
						aAdd(aSolid, 0) //5
						aAdd(aSolid, 0) //6
						aAdd(aSolid, 0) //7

					EndIf

				Else

					//Tratamento para Zerar o ICMS quando nao houver calculo pelo sistema.
					aAdd(aSolid, 0) //1
					aAdd(aSolid, 0) //2
					aAdd(aSolid, 0) //3
					aAdd(aSolid, 0) //4
					aAdd(aSolid, 0) //5
					aAdd(aSolid, 0) //6
					aAdd(aSolid, 0) //7

				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(aArea)

Return(aSolid)


//---------------------------------------------------------------------------------------------
//Função para Buscar a UF/MUN/LOCAL do Cliente/Fornecedor - TEM QUE ESTAR COM SC5 POSICIONADO 
//---------------------------------------------------------------------------------------------
User Function fGetUF(nFuncao)
	Local aRet 		:= {}
	Local aAreaA1 	:= SA1->(GetArea())
	Local aAreaA2 	:= SA2->(GetArea())
	Local lAchouPes	:= .F.
	Local cEST		:= ""
	Local cMUN		:= ""
	Local cRegEsp	:= ""

	If Alltrim(Upper(nFuncao)) == "MATA410"

		If Alltrim(M->C5_YFLAG) == "2"
			lAchouPes	:= .T.
			cEST		:= M->C5_YEST
			cMUN		:= M->C5_YCODMUN
			cRegEsp		:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_YREGESP")
		Else
			If !(M->C5_TIPO $ "DB")
				SA1->(DbSetOrder(1))
				If SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
					lAchouPes	:= .T.
					cEST		:= SA1->A1_EST
					cMUN 		:= SA1->A1_COD_MUN
					cRegEsp		:= SA1->A1_YREGESP
				EndIf
			Else
				SA2->(DbSetOrder(1))
				If SA2->(DbSeek(xFilial("SA2")+M->C5_CLIENTE+M->C5_LOJACLI))
					lAchouPes	:= .T.
					cEST 		:= SA2->A2_EST
					cMUN 		:= SA2->A2_COD_MUN
					cRegEsp		:= ""
				EndIf
			EndIf
		EndIf

	Else

		If Alltrim(SC5->C5_YFLAG) == "2"
			cEST		:= SC5->C5_YEST
			cMUN		:= SC5->C5_YCODMUN
			cRegEsp		:= Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_YREGESP")
		Else
			IF !(SC5->C5_TIPO $ "DB")
				SA1->(DbSetOrder(1))
				If SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
					lAchouPes	:= .T.
					cEST		:= SA1->A1_EST
					cMUN		:= SA1->A1_COD_MUN
					cRegEsp		:= SA1->A1_YREGESP
				EndIf
			ELSE
				SA2->(DbSetOrder(1))
				If SA2->(DbSeek(xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
					lAchouPes	:= .T.
					cEST		:= SA2->A2_EST
					cMUN		:= SA2->A2_COD_MUN
					cRegEsp		:= ""
				EndIf
			ENDIF
		EndIf

	EndIf

	//Armazena as Variaveis encontradas
	aAdd(aRet, lAchouPes)
	aAdd(aRet, cEST)
	aAdd(aRet, cMUN)
	aAdd(aRet, cRegEsp)

	RestArea(aAreaA1)
	RestArea(aAreaA2)

Return(aRet)

//==================================================================================
//Função para grava os Valor do Impostos nos Itens do Pedido de Venda 
//Utilizados nos P.E. M410SOLI e MT410TOK ***AVALIAR PARA DEIXAR SOMENTE NO MT410TOK                                                                       
//===================================================================================
User Function fAtuImp(I,nBasePIS,nBaseCOF,nPIS,nCOFINS,nICMS,nIPI,nPercPIS,nPercCOF,nValMerc,nDescZF,nValST,nBaseICM,nBaseIPI)

	If U_fBuscaTxBI(cEmpAnt,"RPC",Dtos(M->C5_EMISSAO)) == 1
		nBasePIS := Iif(nBasePIS>0,nBasePIS-nICMS,nBasePIS)
		nBaseCOF := Iif(nBaseCOF>0,nBaseCOF-nICMS,nBaseCOF)
		nPIS	 := Round((nBasePIS*nPercPIS)/100,2)
		nCOFINS  := Round((nBaseCOF*nPercCOF)/100,2)
	EndIf

	//GRAVA O VALOR DO ICMS ST PARA CADA ITEM DO PEDIDO //ATIVADO EM 23/01/15 PARA CORREÇÃO DO VALOR DO ST NO ITEM PARA CORRIGIR PEDIDOS DE ST
	If (INCLUI .or. ALTERA) .And. nValST <> 0
		Gdfieldput("C6_YVLTST",	nValST,I)	//Grava ICMS ST
	EndIf

	//GRAVA O VALOR DO DESCONTO SUFRAMA E CORRIGE O PROBLEMA DO CAMPO C6_YVLIMP (ELIMONDA) //ATIVADO EM 05/03/15
	If (INCLUI .or. ALTERA) .And. nDescZF <> 0
		Gdfieldput("C6_YDESCZF",nDescZF,I)	//Grava Desconto Suframa
	EndIf

	//GRAVA O VALOR DO ICMS/IPI/PIS/COFINS //ATIVADO EM 09/12/15
	If (INCLUI .or. ALTERA) .And. (nBasePIS <> 0 .Or. nBaseCOF <> 0 .Or. nBaseICM <> 0 .Or. nBaseIPI <> 0)
		Gdfieldput("C6_YVLIMP", Gdfieldget("C6_VALOR",I)+ nValST - nDescZF ,I) 	//Grava Total das Mercadorias + Imposto ST - Desconto Suframa
		Gdfieldput("C6_YVLTICM",nICMS,I)										//Grava ICMS
		Gdfieldput("C6_YVLTPIS",nPIS,I)											//Grava PIS
		Gdfieldput("C6_YVLTCOF",nCOFINS,I)										//Grava COFINS
		Gdfieldput("C6_YVLTIPI",nIPI,I)											//Grava IPI
	EndIf

Return()
