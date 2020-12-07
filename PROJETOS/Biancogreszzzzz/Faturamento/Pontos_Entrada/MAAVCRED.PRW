#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} MAAVCRED
@description Avalia o credito do cliente entre as empresas - Liberacao por itens 
@author Biancogres
@since 12/09/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function MAAVCRED

	Local nRet 				:= "  " //Retorno com o codigo de Bloqueio
	Local lRet 				:= .F.  //Retorno da função fVerifiCredito  
	Local Enter				:= CHR(13) + CHR(10)
	Local cSql				:= ""
	Local nSaldo			:= 0
	Local nPedLib 			:= 0
	Local wVencto			:= ""
	Local wDataBase 		:= ""
	Local wsAtraso 			:= ""
	Local nTotalRA			:= 0
	Local nTotalAberto 		:= 0
	Local nValorLib 		:= 0

	Local nnCli				:= ""
	Local nnLoj				:= ""
	Local lLm				:= .F.

	Local _cNumPed
	Local _cItemPed
	Local _cQtdLib

	Local aArea				:= GetArea()
	Local aAreaSC9			:= SC9->(GetArea())

	Local lDebug			:= .F.
	Local lNoMsg			:= AllTrim(FunName()) $ "FROPTE08###BIAEC001"
	
	//Tratamento especial para Reajuste de preço
	If (IsInCallStack("U_M410RPRC")) .And. SC6->(FieldPos("C6_YPREAJU")) > 0
		Return(nRet)
	EndIf

	//DEFINE TIPO DE BLOQUEIO DO CREDITO, PARA EXIBIR O MOTIVO NA TELA - FACILITAR A ANALISE INDEPENDENTE DA TI
	//00 LIBERADO
	//01 FALTA SALDO DE LIMITE DE CREDITO
	//02 FALTA DE RA
	//03 RISCO E
	//04 VENCIMENTO LIMITE DE CREDITO
	//05 TITULO EM ATRASO
	//06 PEDIDOS DE CONTRATO
	//07 PEDIDOS DE ENGENHARIA
	If Type("nTpBlq") == "U"
		Public nTpBlq
	EndIf

	nTpBlq := "00"

	//PARA EMPRESA CERAMICA INCESA NÃO É REALIZADO VERIFICAÇÃO DE CREDITO
	If cEmpAnt == "02"
		Return(nRet)
	EndIf

	//PARA PRODUTOS JA FATURADOS NÃO É REALIZADO VERIFICAÇÃO DE CREDITO
	IF (Type("SC9Item") <> "U")
		If 	!Empty(Alltrim(SC9Nfiscal)) .And. Alltrim(SC9BlCred) == "10"
			Return(nRet)
		EndIf
	EndIf

	//PARA PEDIDOS DE CONTRATOS COM LIBERAÇÃO MANUAL
	IF (Type("SC9Item") <> "U")
		If 	!Empty(Alltrim(SC9DtLbMn))
			Return(nRet)
		EndIf
	EndIf

	//AJUSTE POR FERNANDO - 11/02/2011 - PARA FUNCIONAR PARA FUNCOES EXECUTADAS FORA DA TELA DO PEDIDO
	IF (Type("SC9Item") == "U")
		_cNumPed 	:= SC6->C6_NUM
		_cItemPed	:= SC6->C6_ITEM
		_cQtdLib	:= SC6->C6_QTDLIB
	ELSE
		_cNumPed	:= SC9Pedido
		_cItemPed	:= SC9Item
		_cQtdLib	:= SC9Qtdlib
	ENDIF

	//Seleciona SC5 -- FILTRO C5_NUM
	cTmpSC5 := GetNextAlias()
	BeginSql Alias cTmpSC5
		%NoParser%
		SELECT C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_YCLIORI, C5_YLOJORI, C5_CONDPAG, C5_YVLTOTP, C5_YTPCRED, C5_YCRDENG, C5_YPEDORI, C5_YEMPPED FROM %Table:SC5% WITH (NOLOCK) WHERE C5_FILIAL = %xFilial:SC5% AND C5_NUM = %Exp:_cNumPed% AND %NOTDEL%
	EndSql

	//Seleciona SC6 -- FILTRO C6_NUM / C6_ITEM
	cTmpSC6 := GetNextAlias()
	BeginSql Alias cTmpSC6
		%NoParser%
		SELECT C6_NUM, C6_QTDVEN, C6_QTDLIB, C6_PRCVEN, C6_VALOR, C6_YVLIMP, C6_TES, C6_ENTREG, C6_YDTNECE, C6_YENTREG, C6_YVALOR FROM %Table:SC6% WITH (NOLOCK) WHERE C6_FILIAL = %xFilial:SC6% AND C6_NUM = %Exp:_cNumPed% AND C6_ITEM = %Exp:_cItemPed% AND %NOTDEL%
	EndSql

	//Seleciona SF4 -- FILTRO F4_CODIGO
	cTmpSF4 := GetNextAlias()
	BeginSql Alias cTmpSF4
		SELECT F4_CODIGO, F4_DUPLIC FROM %Table:SF4% WHERE F4_FILIAL = %xFilial:SF4% AND F4_CODIGO = %Exp:(cTmpSC6)->C6_TES% AND %NOTDEL%
	EndSql

	//Determina qual cliente o sistema devera analisar o Crédito
	If Empty(Alltrim((cTmpSC5)->C5_YCLIORI))
		nnCli 	:= (cTmpSC5)->C5_CLIENTE
		nnLoj 	:= (cTmpSC5)->C5_LOJACLI
		lLm		:=	.F.
	Else
		nnCli := (cTmpSC5)->C5_YCLIORI
		nnLoj := (cTmpSC5)->C5_YLOJORI
		lLm		:=	.T.	
	EndIf

	//Seleciona SA1 -- FILTRO A1_COD / A1_LOJA
	cTmpSA1 := GetNextAlias()
	BeginSql Alias cTmpSA1
		%NoParser%
		SELECT A1_COD, A1_LOJA, A1_LC, A1_GRPVEN, A1_RISCO, A1_VENCLC, A1_YTIPOLC FROM %Table:SA1% WITH (NOLOCK) WHERE A1_FILIAL = %xFilial:SA1% AND A1_COD = %Exp:nnCli% AND A1_LOJA = %Exp:nnLoj% AND %NOTDEL%
	EndSql

	//Verifica credito somente de pedidos que geram Duplicatas
	If (cTmpSF4)->F4_DUPLIC == "N"

		If Select(cTmpSC5) > 0; (cTmpSC5)->(dbCloseArea()); EndIf
		If Select(cTmpSC6) > 0; (cTmpSC6)->(dbCloseArea()); EndIf
		If Select(cTmpSA1) > 0; (cTmpSA1)->(dbCloseArea()); EndIf
		If Select(cTmpSF4) > 0; (cTmpSF4)->(dbCloseArea()); EndIf

		Return(nRet)
	EndIf

	//SE FOR PEDIDO PARA O CLIENTE LM, O VALOR SERA ZERADO POIS O PEDIDO NA CONSTA EM CARTEIRA
	//Define Valor Produto Atual
	If (cTmpSC5)->C5_CLIENTE == "010064" .And. !Empty(Alltrim((cTmpSC5)->C5_YCLIORI))

		//RUBENS JUNIOR - OS:1108-14 - BIANCOGRES/INCESA VENDE PARA LM, E LM BONIFICA CLIENTE

		// Tiago Rossini - Item comentado devido a OS: 1755-14
		// If (cEmpAnt == "01" .Or. cEmpAnt =="05")                                               
		If BonificacaoLM(_cNumPed,(cTmpSC5)->C5_YCLIORI,(cTmpSC5)->C5_YLOJORI)	//BUSCAR PARA VERIFICAR SE O PEDIDO DA LM E BONIFICACAO

			If Select(cTmpSC5) > 0; (cTmpSC5)->(dbCloseArea()); EndIf
			If Select(cTmpSC6) > 0; (cTmpSC6)->(dbCloseArea()); EndIf
			If Select(cTmpSA1) > 0; (cTmpSA1)->(dbCloseArea()); EndIf
			If Select(cTmpSF4) > 0; (cTmpSF4)->(dbCloseArea()); EndIf

			Return(nRet)
		EndIf
		//EndIf

		//Obriga validação do RA para processo BIANCOGRES/INCESA -> LM
		If U_fValidaRA((cTmpSC5)->C5_CONDPAG) .Or. Alltrim((cTmpSC5)->C5_CONDPAG) $ "145_975" 
			nValorLib 		:= Iif((cTmpSC6)->C6_YVLIMP<>0,Round((Round((_cQtdLib*(cTmpSC6)->C6_PRCVEN),2)/(cTmpSC6)->C6_VALOR*100)*(cTmpSC6)->C6_YVLIMP/100,2),Round(_cQtdLib*(cTmpSC6)->C6_PRCVEN,2))
		Else
			nValorLib 		:= 0
		EndIf

	Else
		nValorLib 		:= Iif((cTmpSC6)->C6_YVLIMP<>0,Round((Round((_cQtdLib*(cTmpSC6)->C6_PRCVEN),2)/(cTmpSC6)->C6_VALOR*100)*(cTmpSC6)->C6_YVLIMP/100,2),Round(_cQtdLib*(cTmpSC6)->C6_PRCVEN,2))
	EndIf


	nTipoCred	:= (cTmpSC5)->C5_YTPCRED    //Tipo d
	nEntrATU	:= (cTmpSC6)->C6_YDTNECE 	//Data Atual do Pedido
	nEntrAPR	:= (cTmpSC6)->C6_YENTREG	//Data Aprovada pelo Financeiro
	nVlrATU		:= (cTmpSC6)->C6_VALOR		//Valor Atual do Pedido
	nVlrAPR	 	:= (cTmpSC6)->C6_YVALOR		//Valor Aprovado pelo Financeiro

	If lLm
		cSql := "SELECT C5_NUM, C5_YTPCRED, C5_YPEDORI, C6_PRODUTO, C6_ITEM, C6_YDTNECE, C6_YENTREG, C6_VALOR, C6_YVALOR " + Enter
		cSql += "FROM SC5070 SC5 WITH (NOLOCK) INNER JOIN SC6070 SC6 WITH (NOLOCK) ON " + Enter
		cSql += "     SC5.C5_NUM = SC6.C6_NUM					" + Enter
		cSql += "WHERE	SC5.C5_FILIAL  = '01'				AND	" + Enter
		cSql += "		SC6.C6_FILIAL  = '01'				AND	" + Enter	
		cSql += "		SC5.C5_YPEDORI = '"+_cNumPed+"'		AND	" + Enter
		cSql += "		SC5.C5_YEMPPED = '"+cEmpAnt+"'		AND " + Enter
		cSql += "		SC6.C6_ITEM    = '"+_cItemPed+"'	AND " + Enter
		cSql += "		SC5.D_E_L_E_T_ = '' 				AND " + Enter
		cSql += "		SC6.D_E_L_E_T_ = '' 					" + Enter
		If chkfile("_SC6")
			dbSelectArea("_SC6")
			dbCloseArea()
		EndIf
		TCQUERY CSQL ALIAS "_SC6" NEW	

		nTipoCred	:= _SC6->C5_YTPCRED
		nEntrATU	:= _SC6->C6_YDTNECE //Data Atual do Pedido
		nEntrAPR	:= _SC6->C6_YENTREG	//Data Aprovada pelo Financeiro
		nVlrATU		:= _SC6->C6_VALOR	//Valor Atual do Pedido
		nVlrAPR	 	:= _SC6->C6_YVALOR	//Valor Aprovado pelo Financeiro

	EndIf	


	//Verifica se o Credito nao foi Bloqueado
	
	If nTipoCred == "2" //Contrato          

		//Valida se houve alteração entre Data Entrega e Valor Total
		//If (cTmpSC6)->C6_ENTREG <> (cTmpSC6)->C6_YENTREG 
		If nEntrATU <> nEntrAPR 	
			nRet 	:= "  "  //LIBERADO POR PADRÃO 
			nTpBlq 	:= "061" //CONTRATO - ALTERAÇÃO NA DATA DE ENTREGA
		EndIf

		If nVlrATU <> nVlrAPR .And. Substr(nTpBlq,1,2) <> "06"
			nRet 	:= "  "  //LIBERADO POR PADRÃO 
			nTpBlq 	:= "062" //CONTRATO - ALTERAÇÃO NO VALOR 
		EndIf

		//Valida se o faturamento esta ocorrendo antes da Data de Entrega
		//If (cTmpSC6)->C6_ENTREG > Dtos(dDataBase) .And. Substr(nTpBlq,1,2) <> "06"
		If nEntrATU > Dtos(dDataBase) .And. Substr(nTpBlq,1,2) <> "06"
			nRet 	:= "  "  //LIBERADO POR PADRÃO 
			nTpBlq 	:= "063" //CONTRATO - LIBERADO ANTES DA DATA DE NECESSIDADE
		EndIf	

		//Verifica se exitem títulos de Contrato em aberto e vencidos.
		cSql := "SELECT ISNULL(SUM(E1_SALDO),0) SALDO 			" + Enter
		If lLm
			cSql += "FROM SE1070 WITH (NOLOCK) 					" + Enter
			//cSql += "WHERE	E1_PEDIDO = '"+_SC6->C5_NUM+"'	AND " + Enter
		Else
			cSql += "FROM "+RetSqlName("SE1")+" WITH (NOLOCK)	" + Enter
			//cSql += "WHERE	E1_PEDIDO	= '"+_cNumPed+"'	AND " + Enter
		EndIf
		cSql += "WHERE	E1_FILIAL	= '01'				AND " + Enter
		cSql += "		E1_CLIENTE	= '"+nnCli+"'		AND " + Enter
		cSql += "		E1_LOJA		= '"+nnLoj+"'		AND " + Enter
		cSql += "		E1_YCLASSE	= '2' 				AND " + Enter
		cSql += "		E1_SALDO 	> 0  				AND " + Enter
		cSql += "		E1_VENCREA 	< CONVERT(VARCHAR,GETDATE(),112) AND " + Enter
		cSql += "		D_E_L_E_T_ 	= '' 					" + Enter
		If chkfile("_CT")
			dbSelectArea("_CT")
			dbCloseArea()
		EndIf
		TCQUERY CSQL ALIAS "_CT" NEW

		If _CT->SALDO > 0 .And. Substr(nTpBlq,1,2) <> "06"
			nRet 	:= "  "  //LIBERADO POR PADRÃO 
			nTpBlq 	:= "064" //CONTRATO - TITULO DE CONTRATO EM ABERTO E ATRASO
		EndIf		

		//Verifica se o item já foi liberado na empresa Origem
		If cEmpAnt == "07" .And. Substr(nTpBlq,1,2) == "06"
			cSql := "SELECT ISNULL(SUM(C9_QTDLIB),0) QTDLIB FROM SC9"+(cTmpSC5)->C5_YEMPPED+"0 WITH (NOLOCK) WHERE C9_PRODUTO = '"+SC6->C6_PRODUTO+"' AND C9_PEDIDO = '"+(cTmpSC5)->C5_YPEDORI+"' AND C9_ITEM = '"+_cItemPed+"' AND C9_NFISCAL <> '' AND C9_YDTLICT <> '' AND D_E_L_E_T_ = '' "
			If chkfile("_TTT")
				dbSelectArea("_TTT")
				dbCloseArea()
			EndIf
			TCQUERY CSQL ALIAS "_TTT" NEW

			If _TTT->QTDLIB > 0 .And. _cQtdLib <= _TTT->QTDLIB
				nRet 	:= "  "  //LIBERADO POR PADRÃO 
				nTpBlq 	:= "065" //LIBERADO NA EMPRESA ORIGEM 
			EndIf
		EndIf

		If Substr(nTpBlq,1,2) <> "06"
			nRet 	:= "  " //LIBERADO POR PADRÃO 
			nTpBlq 	:= "00" //LIBERADO
		EndIf

	Else
		If SuperGetMv("MV_BLOQUEI")

			//Verifica se existe pedido na tabela de Liberacao de Pedidos
			cSql := "SELECT COUNT(*) AS COUNT 				" + Enter
			cSql += "FROM "+RetSqlName("SZN")+" SZN	WITH (NOLOCK) 			" + Enter
			cSql += "WHERE	SZN.ZN_FILIAL	= '"+xFilial("SZN")+"'		AND	" + Enter
			cSql += "		SZN.ZN_PEDIDO	= '"+_cNumPed+"'			AND	" + Enter
			cSql += "		SZN.ZN_DATAINI	<= '"+Dtos(dDataBase)+"'	AND	" + Enter
			cSql += "		SZN.ZN_DATALIM	>= '"+Dtos(dDataBase)+"'	AND	" + Enter
			cSql += "		SZN.ZN_VALOR	>= '"+Alltrim(Str((cTmpSC5)->C5_YVLTOTP))+"'	AND	" + Enter
			cSql += "		SZN.D_E_L_E_T_	= ''							" + Enter
			If chkfile("_SZN")
				dbSelectArea("_SZN")
				dbCloseArea()
			EndIf
			TCQUERY CSQL ALIAS "_SZN" NEW

			//Caso exista pedido na tabela de Liberação, retorna liberando o Pedido
			If _SZN->COUNT > 0
				nRet 	:= "  "
				nTpBlq	:= "00" //LIBERADO

				If Select(cTmpSC5) > 0; (cTmpSC5)->(dbCloseArea()); EndIf
				If Select(cTmpSC6) > 0; (cTmpSC6)->(dbCloseArea()); EndIf
				If Select(cTmpSA1) > 0; (cTmpSA1)->(dbCloseArea()); EndIf
				If Select(cTmpSF4) > 0; (cTmpSF4)->(dbCloseArea()); EndIf

				Return(nRet)
			EndIf

			//Excuta tratamento/verificao para RA
			//PROJETO2014
			If U_fValidaRA((cTmpSC5)->C5_CONDPAG) .Or. Alltrim((cTmpSC5)->C5_CONDPAG) $ "145_975"

				If Alltrim(Funname())== "MATA410" .Or. Alltrim(Funname())== "MATA440"
					If GETMV("MV_YVLDRA")
						lRet := (U_fVerificaCredito("2",(cTmpSC5)->C5_NUM,nnCli,nnLoj,lLm,0,nValorLib,.F.,.T.,lNoMsg) == '00') //PARAMENTRO DA LM / PARAMENTRO EXIBE MSG
					Else
						//nRaStat := "2" //Aguardando Lancamento Ra DESATIVADO // EM 20/10/14 - RANISSES
						lRet 	:= .T.
					EndIf		
				Else
					lRet := (U_fVerificaCredito("2",(cTmpSC5)->C5_NUM,nnCli,nnLoj,lLm,0,nValorLib,.F.,.T.,lNoMsg)== '00') //PARAMENTRO DA LM / PARAMENTRO EXIBE MSG							
				EndIf

				If lRet
					nRet 	:= "  "
					nTpBlq 	:= "00" //LIBERADO

					If Select(cTmpSC5) > 0; (cTmpSC5)->(dbCloseArea()); EndIf
					If Select(cTmpSC6) > 0; (cTmpSC6)->(dbCloseArea()); EndIf
					If Select(cTmpSA1) > 0; (cTmpSA1)->(dbCloseArea()); EndIf
					If Select(cTmpSF4) > 0; (cTmpSF4)->(dbCloseArea()); EndIf

					Return(nRet)
				Else
					nRet 	:= "01"
					nTpBlq 	:= "02" //CREDITO RA

					If Select(cTmpSC5) > 0; (cTmpSC5)->(dbCloseArea()); EndIf
					If Select(cTmpSC6) > 0; (cTmpSC6)->(dbCloseArea()); EndIf
					If Select(cTmpSA1) > 0; (cTmpSA1)->(dbCloseArea()); EndIf
					If Select(cTmpSF4) > 0; (cTmpSF4)->(dbCloseArea()); EndIf

					Return(nRet)
				EndIf


			Else
				nRet := U_fVerificaCredito("1",(cTmpSC5)->C5_NUM,nnCli,nnLoj,lLm,0,nValorLib,.F.,.T.,lNoMsg) //PARAMENTRO DA LM / PARAMENTRO EXIBE MSG
				lRet := (nRet == "00")

				If lRet
					nRet 	:= "  "
					nTpBlq 	:= "00" //LIBERADO

					If Select(cTmpSC5) > 0; (cTmpSC5)->(dbCloseArea()); EndIf
					If Select(cTmpSC6) > 0; (cTmpSC6)->(dbCloseArea()); EndIf
					If Select(cTmpSA1) > 0; (cTmpSA1)->(dbCloseArea()); EndIf
					If Select(cTmpSF4) > 0; (cTmpSF4)->(dbCloseArea()); EndIf

					Return(nRet)
				EndIf

			EndIf
		EndIf
	EndIf

	(cTmpSC5)->(dbCloseArea())
	(cTmpSC6)->(dbCloseArea())
	(cTmpSA1)->(dbCloseArea())
	(cTmpSF4)->(dbCloseArea())

	RestArea(aAreaSC9)
	RestArea(aArea)

Return(nRet)

//BUSCAR PARA VERIFICAR SE O PEDIDO DA LM E BONIFICACAO
Static Function BonificacaoLM(__cNumPed,__cCliOri,__cLojaOri)	                       
	Local lRet := .F.

	CSQL := "SELECT C5_NUM,C5_YSUBTP FROM SC5070 WITH (NOLOCK) WHERE C5_FILIAL = '01' AND C5_YPEDORI = '"+__cNumPed+"' AND C5_CLIENTE = '"+__cCliOri+"'  AND C5_LOJACLI = '"+__cLojaOri+"' AND D_E_L_E_T_= ''"

	TCQUERY CSQL ALIAS "QRY" NEW 

	QRY->(DbGotop())
	IF !QRY->(EOF())
		If(Alltrim(QRY->C5_YSUBTP) $ 'A_B_D_G')
			lRet := .T.
		EndIf
	EndIf    

	QRY->(DbCloseArea())

Return lRet
