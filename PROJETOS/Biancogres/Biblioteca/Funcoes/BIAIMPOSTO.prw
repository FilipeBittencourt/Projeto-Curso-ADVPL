#include "PROTHEUS.CH"

/*/{Protheus.doc} fItImpos
@author Fernando Rocha 
@since 10/08/2015
@version 1.0
@description Funções para calculo de imposto na tela do pedido de venda.
@history 04/11/2016, Ranisses A. Corona, Correção e melhorias na gravação do valor dos impostos por item. OS: 4052-16 Mayara Trigueiro / 3888-16 Elaine Sales
@history 07/11/2016, Ranisses A. Corona, Melhoria no retorno da função. Quando a variavel _Item for igual a 0(zero), será retornado a matriz com todos os itens do Pedido
@type function
/*/

//RETORNA IMPOSTO CONFORME VARIAVEIS Char no vetor _aCampos
//Exemplos:

//IT_ALIQICM 
//IT_ALIQIPI
//IT_ALIQCOF
//IT_ALIQPIS  

//Calcula PIS/COFINS/CSLL por Retencao
//IT_VALICM 
//IT_VALIPI
//IT_VALCOF
//IT_VALPIS                       

//Calcula PIS/COFINS/CSLL por Apuracao
//IT_BASEPS2
//IT_BASECF2
//IT_BASESOL
//IT_VALPS2
//IT_VALCF2
//IT_ALIQPS2
//IT_ALIQCF2
//IT_VALSOL

//IMPORTANTE VARIAVEL _Item 
//_Item =  0 retorna matriz com todos os itens do Pedido de Venda
//_Item <> 0 retorna array com o valor do iten selecionado


User Function fItImpos(_Item,_aCampos)

	Local _aAreaSA1 	:= SA1->(GetArea())

	//Carrega aCols/aHeader do Pedido ou Orçamento
	Local _aHeadPC		:= Iif(Alltrim(FunName()) == "MATA416",_aHeader,aHeader)
	Local _aColsPC		:= Iif(Alltrim(FunName()) == "MATA416",_aCols,aCols)

	//Carrega variaveis dos Itens do Pedido de Venda
	Local _nPosQtd		:= aScan(_aHeadPC,{|x| ALLTRIM(x[2]) == "C6_QTDVEN"})
	Local _nPosVUni		:= aScan(_aHeadPC,{|x| ALLTRIM(x[2]) == "C6_PRCVEN"})
	Local _nPosVTot		:= aScan(_aHeadPC,{|x| ALLTRIM(x[2]) == "C6_VALOR"})
	Local _nPosTes 		:= aScan(_aHeadPC,{|x| ALLTRIM(x[2]) == "C6_TES"})
	Local _nPosProd		:= aScan(_aHeadPC,{|x| ALLTRIM(x[2]) == "C6_PRODUTO"})
	Local _nPosDesc		:= aScan(_aHeadPC,{|x| ALLTRIM(x[2]) == "C6_VALDESC"})
	Local _nTotal		:= IIf(_Item==0,{},0) 

	//Modificado por Ranisses em 08/12/2015
	Local nCli			:= IIF(Type("M->C5_CLIENTE")=="U",SC5->C5_CLIENTE,M->C5_CLIENTE)
	Local nLj			:= IIF(Type("M->C5_LOJACLI")=="U",SC5->C5_LOJACLI,M->C5_LOJACLI) 
	Local nTpPed		:= IIF(Type("M->C5_TIPO")=="U"   ,SC5->C5_TIPO   ,M->C5_TIPO)
	Local nTpCli		:= ""
	Local lM410Soli		:= ExistBlock("M410SOLI")
	Local _nX			:= 0  
	Local _aRetCampos	:= {}  

	//Modificado por Ranisses 05/04/2018
	Local nQtd			:= 0
	Local nVlrUnit		:= 0
	Local nVlrTot		:= 0 
	Local _nI

	//Posiciona no Cliente/Fornecedor
	If !(nTpPed $ "DB")
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+nCli+nLj))
		nTpCli := SA1->A1_TIPO
	Else
		SA2->(DbSetOrder(1))
		SA2->(DbSeek(xFilial("SA2")+nCli+nLj))
		nTpCli := SA2->A2_TIPO
	EndIf

	//Inicia funçao para Cálculo do Imposto
	MaFisIni(nCli,nLj,"C","N",nTpCli,Nil,Nil,Nil,Nil,"MATA461")

	For _nI := 1 To Len(_aColsPC)	

		nQtd		:= _aColsPC[_nI,_nPosQtd]
		nVlrUnit	:= _aColsPC[_nI,_nPosVUni]		
		nVlrTot		:= _aColsPC[_nI,_nPosVTot]

		If nQtd	== 0
			nQtd := 10
		EndIf

		If nVlrUnit == 0
			nVlrUnit := 10
		EndIf

		If nVlrTot == 0 
			nVlrTot	:= nQtd * nVlrUnit
		EndIf 

		MaFisAdd(;
		_aColsPC[_nI,_nPosProd]	,;      					// 1-Codigo do Produto ( Obrigatorio )
		_aColsPC[_nI,_nPosTes]	,;                   		// 2-Codigo do TES ( Opcional )
		nQtd					,;                  		// 3-Quantidade ( Obrigatorio )
		nVlrUnit				,;               			// 4-Preco Unitario ( Obrigatorio )
		_aColsPC[_nI,_nPosDesc]	,;                    	 	// 5-Valor do Desconto ( Opcional )
		""		,;                                       	// 6-Numero da NF Original ( Devolucao/Benef )
		""		,;                                       	// 7-Serie da NF Original ( Devolucao/Benef )
		0		,;                                        	// 8-RecNo da NF Original no arq SD1/SD2
		0		,;                                          // 9-Valor do Frete do Item ( Opcional )
		0		,;                                          // 10-Valor da Despesa do item ( Opcional )
		0		,;                                          // 11-Valor do Seguro do item ( Opcional )
		0		,;                                          // 12-Valor do Frete Autonomo ( Opcional )
		nVlrTot	,;                         					// 13-Valor da Mercadoria ( Obrigatorio )
		0;													// 14-Valor da Embalagem ( Opiconal )
		)

		//Calcula ICMS ST
		If lM410Soli .And. ( aScan(_aCampos,"IT_BASESOL")>0 .Or. aScan(_aCampos,"IT_VALSOL")>0)
			ICMSITEM    := MaFisRet(_nI,"IT_VALICM")		// variavel para ponto de entrada
			QUANTITEM   := MaFisRet(_nI,"IT_QUANT")			// variavel para ponto de entrada
			BASEICMRET  := MaFisRet(_nI,"IT_BASESOL")	    // criado apenas para o ponto de entrada
			MARGEMLUCR  := MaFisRet(_nI,"IT_MARGEM")		// criado apenas para o ponto de entrada
			aSolid := ExecBlock("M410SOLI",.f.,.f.,{_nI})
			aSolid := IIF(ValType(aSolid) == "A" .And. Len(aSolid) > 0, aSolid,{})
			If !Empty(aSolid)
				MaFisLoad("IT_BASESOL",NoRound(aSolid[1],2),_nI)
				MaFisLoad("IT_VALSOL" ,NoRound(aSolid[2],2),_nI)
				MaFisLoad("IT_BSFCPST",NoRound(aSolid[3],2),_nI) //BASE
				MaFisLoad("IT_ALFCST" ,NoRound(aSolid[4],2),_nI) //ALIQ		
				MaFisLoad("IT_VFECPST",NoRound(aSolid[5],2),_nI) //VALOR
				MaFisEndLoad(_nI,1)
			Endif
		EndIf

		//Quando _Item for IGUAL a 0(ZERO) retorna matriz com todos os itens do Pedido de Venda 
		If _Item == 0
			For _nX := 1 To Len(_aCampos)
				AAdd(_nTotal, Iif(!GdDeleted(_nI),MaFisRet(_nI,_aCampos[_nX]),0) )				
			Next _nX
			AAdd(_aRetCampos, _nTotal )
			_nTotal := {}
		EndIf

	Next _nI

	//Quando _Item DIFERENTE de 0(ZERO) retorna matriz referente ao item posicionado do Pedido de Venda
	If _Item <> 0
		For _nX := 1 To Len(_aCampos)
			If _aCampos[_nX] == "IT_ALIQICM" 
				If  MaFisRet(_Item,_aCampos[_nX]) <> 0 .And. ( MaFisRet(_Item,"IT_VALICM") <> 0 .Or. MaFisRet(_Item,"IT_DESCZF") <> 0 ) 	
					_nTotal := MaFisRet(_Item,_aCampos[_nX])	
				Else
					_nTotal := 0
				EndIf
			Else
				_nTotal := MaFisRet(_Item,_aCampos[_nX])			
			EndIf			
			AAdd(_aRetCampos, _nTotal)	
		Next _nX
	EndIf

	//Finaliza função do cálculo do Imposto
	MaFisEnd()  

	RestArea(_aAreaSA1)
Return _aRetCampos   



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BIAIMPOSTOºAutor  ³Fernando Rocha      º Data ³ 10/08/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retornar aliquotas de imposto conforme parametros          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BIANCOGRES 												  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fGetImp(_aCampos, _cCodCli, _cLojCli, _cProduto, _cTES, _nQuant, _nPrUnit, _nValTot)

	Local _aAreaSA1 := SA1->(GetArea())
	Local _nTotal	:= 0
	Local I 
	Local _aRetCampos	:= {}     

	Default _cTES := ""

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+_cCodCli+_cLojCli))

	//Inicia funçao para Cálculo do Imposto
	MaFisIni(_cCodCli,_cLojCli,"C","N",SA1->A1_TIPO)

	MaFisAdd(;
	_cProduto	,;      			// 1-Codigo do Produto ( Obrigatorio )
	_cTES		,;            		// 2-Codigo do TES ( Opcional )
	_nQuant		,;                	// 3-Quantidade ( Obrigatorio )
	_nPrUnit	,;               	// 4-Preco Unitario ( Obrigatorio )
	0			,;             	 	// 5-Valor do Desconto ( Opcional )
	""			,;	          		// 6-Numero da NF Original ( Devolucao/Benef )
	""			,;            		// 7-Serie da NF Original ( Devolucao/Benef )
	0			,;            		// 8-RecNo da NF Original no arq SD1/SD2
	0			,;                 	// 9-Valor do Frete do Item ( Opcional )
	0			,;                 	// 10-Valor da Despesa do item ( Opcional )
	0			,;               	// 11-Valor do Seguro do item ( Opcional )
	0			,;                	// 12-Valor do Frete Autonomo ( Opcional )
	_nValTot	,;   				// 13-Valor da Mercadoria ( Obrigatorio )
	0;								// 14-Valor da Embalagem ( Opiconal )
	)

	For I := 1 To Len(_aCampos)	
		_nTotal := MaFisRet(1,_aCampos[I])	
		AAdd(_aRetCampos, _nTotal)
	Next I

	//Finaliza função do cálculo do Imposto
	MaFisEnd()  

	RestArea(_aAreaSA1)
Return _aRetCampos