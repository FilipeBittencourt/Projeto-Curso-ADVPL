#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

User Function FCLA0048; Return()

/*/{Protheus.doc} TBiaPoliticaDesconto
@description Classe para controle dos metodos de calculo de Descontos da politica comercial
@author Fernando Rocha
@since 17/02/2017
@version undefined
@type class
/*/
Class TBiaPoliticaDesconto From LongClassName

Data DPAL as Float
Data DCAT as Float
Data DREG as Float
Data DGER as Float
Data DNV  as Float
Data DESP as Float
Data DACO as Float
Data DVER as Float
Data DAI  as Float

Data FC as Float  //Fator Contratual  
Data DPAL_ORI as Float
Data DCAT_ORI as Float
Data DREG_ORI as Float
Data DGER_ORI as Float
Data DNV_ORI  as Float
Data DACO_ORI as Float
Data DVER_ORI as Float
Data DAI_ORI as Float

Data DNV_MAX  //OS 4184-16 DNV maximo da politica para validacao da digitacao
Data DVER_MAX

Data DPOL as Float
Data DTOT as Float
Data DTOT_ORI as Float  //Desconto total sem o DESP para bloqueio de desconto

Data oDetalhe  //Lista detalhada da composicao do desconto para exibicao na tela na memoria

//Parametrros para executar o metodo GetPolitica
Data _cCliente 	
Data _cVendedor 	
Data _cProduto 	
Data _lPaletizado  
Data _nPICMS
Data _nPPIS
Data _nPCOF
Data _nAComis
Data _cLote
Data _dData //OS 2472-17 - processar a politica conforme a data de emissao dos pedidos (para casos de alteracao depois que foi modificada alguma regra) 

Method New()
Method GetPolitica()
Method Calculate()   
Method LoadParMem()  
Method LoadParAlt() 
Method LoadParSC6(_cPedido, _cItem)
Method CalVlDACO(_nPrcTab)
Method CalVlDAI(_nPrcTab)
Method PrcAntVer(_nPrcTab)

EndClass

//Construtor da Classe
Method New() Class TBiaPoliticaDesconto

	::DPAL := 0
	::DCAT := 0
	::DREG := 0
	::DGER := 0
	::DNV  := 0
	::DESP := 0
	::DVER := 0
	::DACO := 0
	::DAI  := 0

	::DPOL := 0
	::DTOT := 0   

	::_cCliente 	:= ""
	::_cVendedor 	:= ""
	::_cProduto 	:= ""
	::_lPaletizado 	:= .F.
	::_nPICMS	    := 0
	::_nPPIS		:= 0
	::_nPCOF		:= 0
	::_nAComis	    := 0
	::_cLote		:= ""
	::_dData		:= dDataBase

Return Self

//Metodo para buscar os descontos da politica baseado nos parametros da venda
Method GetPolitica() Class TBiaPoliticaDesconto

	Local aAreaB1 := SB1->(GetArea())
	Local aAreaZ7 := ZZ7->(GetArea())
	Local lRet := .T.
	Local cEmpSql
	Local cSpName
	Local _aRet     
	Local _cAliasDet  

	//Funcao SQL para retornar os descontos
	cEmpSql := "01"  //PROJETO CONSOLIDAÇÃO - POLITICAS COMERCIAIS TODAS CONCENTRADAS NA BIANCOGRES

	cSpName := "SP_POL_GET_POLITICA_DATA_"+cEmpSql

	IF TCSPEXIST(cSpName)

		_cAliasDet := GetNextAlias()
		_cSQL := "EXEC "+cSpName+" '"+XFilial("ZA0")+"', '"+::_cCliente+"' , '"+::_cVendedor+"', '"+::_cProduto+"', '"+::_cLote+"', "+AllTrim(Str(IIf(::_lPaletizado,1,0)))+", "+AllTrim(Str(::_nPICMS))+", "+AllTrim(Str(::_nPPIS))+", "+AllTrim(Str(::_nPCOF))+", "+AllTrim(Str(::_nAComis))+", "+DTOS(::_dData)+" "
		TCQuery _cSQL Alias (_cAliasDet) New

		If !(_cAliasDet)->(Eof())	

			::DPAL 		:= (_cAliasDet)->DPAL
			::DCAT 		:= (_cAliasDet)->DCAT
			::DREG 		:= (_cAliasDet)->DREG
			::DGER 		:= (_cAliasDet)->DGER

			//::DNV  		:= (_cAliasDet)->DNV  //nao preenche mais OS 4184-16 - vai ser informado manualmente com no maximo o DNV_MAX
			::DNV_MAX	:= (_cAliasDet)->DNV

			If SC6->(FieldPos("C6_YDVER")) > 0

				::DVER		:= (_cAliasDet)->DVER
				::DVER_ORI	:= (_cAliasDet)->DVER_ORI
				::DVER_MAX	:= (_cAliasDet)->DVER 

			Else

				::DVER		:= 0
				::DVER_ORI	:= 0
				::DVER_MAX	:= 0

			EndIf

			::FC   		:= (_cAliasDet)->FC
			::DPAL_ORI 	:= (_cAliasDet)->DPAL_ORI
			::DCAT_ORI 	:= (_cAliasDet)->DCAT_ORI
			::DREG_ORI 	:= (_cAliasDet)->DREG_ORI
			::DGER_ORI 	:= (_cAliasDet)->DGER_ORI
			::DNV_ORI  	:= (_cAliasDet)->DNV_ORI

		EndIf

	ENDIF

	::Calculate()

	RestArea(aAreaB1)
	RestArea(aAreaZ7)

Return lRet

//Metodo para calcular os descontos totais
Method Calculate() Class TBiaPoliticaDesconto

	Local _DPOL
	Local _DTOT

	_DPOL := (1 - ( (1 - (::DCAT/100)) * (1 - (::DREG/100)) * (1 - (::DGER/100)) )) * 100
	::DPOL := _DPOL

	_DTOT := (1 - ( (1 - (::DPAL/100)) * (1 - (::DPOL/100)) * (1 - (::DNV/100))  )) * 100

	::DTOT_ORI := _DTOT  //Desconto total sem o DESP

	//Desconto total com o DESP  
	//DVER e DACO (16/02/17) - desconto de verba adicionado
	::DTOT := (1 - ( (1 - (::DTOT_ORI/100)) * (1 - (::DESP/100)) * (1 - ((::DVER + ::DACO + ::DAI)/100)) )) * 100   

Return   

//carregar parametros para buscar politica a partir de variaveis da memoria - tela do pedido
Method LoadParMem(_NL) Class TBiaPoliticaDesconto 

	//_NL - variavel da posicao da linah do ACOLS

	Local aAreaB1 := SB1->(GetArea())
	Local _cLOTSUG
	Local _cQTDSUG
	Local _cTPEST 
	Local _nQtdDig
	Local nDivPA
	Local _aImposto
	Local _cLOCAL
	Local _cEMPPED

	Default _NL := N

	::_cCliente 	:= M->C5_CLIENTE+M->C5_LOJACLI
	::_cVendedor 	:= M->C5_VEND1
	::_dData		:= M->C5_EMISSAO
	::_cProduto 	:= aCols[_NL][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})]
	::_cLote		:= aCols[_NL][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOTECTL"})]

	_cLOTSUG	:= aCols[_NL][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YLOTSUG"})]
	_cQTDSUG	:= aCols[_NL][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YQTDSUG"})]
	_cLOCAL		:= aCols[_NL][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOCAL"})]
	_cEMPPED	:= aCols[_NL][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YEMPPED"})]

	_cTPEST		:= aCols[_NL][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YTPEST"})]
	_nQtdDig 	:= Round(aCols[_NL][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDVEN"})],2)

	::DESP		:= aCols[_NL][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDESP"})]

	::DVER		:= aCols[_NL][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDVER"})]
	::DACO		:= aCols[_NL][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDACO"})]

	If SC6->(FieldPos("C6_YDAI")) > 0
		::DAI		:= aCols[_NL][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDAI"})]
	EndIf

	//OS 4184-16 - DNV passa a ser digitado
	::DNV		:= aCols[_NL][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YDNV"})] 

	//Se aceitou sugestao do lote dar desconto de paletizado 18%
	::_lPaletizado  := ( ::_cLote == _cLOTSUG ) .And. ( _nQtdDig == _cQTDSUG )

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+::_cProduto))

	//Pode ser que tenha rejeitado sugestao de fracionado mas a quantidade e paletizada
	//Pode estar como OP
	//Tickets 1642 e 1416 - se tiver quantidade paletizada / mesmo lotes com DIVPA diferentes / aplicar desconto de paletizao
	If (_cTPEST $ "R_V")

		nDivPA := SB1->B1_YDIVPA * SB1->B1_CONV
		::_lPaletizado := (_nQtdDig % nDivPA) == 0

	Else

		If  !::_lPaletizado .And. !Empty(::_cLote)

			//Ticket 10625 
			//Calculo se a _nQtdDig é paleta fechado e dar o desconto
			nDivPA := SB1->B1_YDIVPA * SB1->B1_CONV

			ZZ9->(DbSetOrder(1))
			If ZZ9->(DbSeek(XFilial("ZZ9")+::_cLote+::_cProduto))

				nDivPA := ZZ9->ZZ9_DIVPA * SB1->B1_CONV

			EndIf

			::_lPaletizado := (_nQtdDig % nDivPA) == 0

			//Se nao for palete fechado mas estiver arrematando o estoque dar o desconto.
			If (!::_lPaletizado)


				If (AllTrim(cEmpAnt) == '07')

					IF Empty(SB1->B1_YEMPEST)

						nLinhaEmp	:= SB1->B1_YEMPEST
						_nSldLot	:= U_FROPCPRO(SubStr(nLinhaEmp,1,2),SubStr(nLinhaEmp,3,2),"U_FROPRT01", ::_cProduto, _cLOCAL, "", "", _nQtdDig, ::_cLote, "", _cEMPPED)[7]
						::_lPaletizado := ( _nQtdDig == _nSldLot ) .Or. (_nSldLot == 0)			
					
					EndIf
				Else
					
					_nSldLot 		:= U_FROPRT01(::_cProduto, _cLOCAL, "", "", _nQtdDig, ::_cLote, "", _cEMPPED)[7]
					::_lPaletizado	:= ( _nQtdDig == _nSldLot ) .Or. (_nSldLot == 0)			
					
				EndIf		

			EndIf

		EndIf

		//Tratamento produtos classe B/Cliente Livre revestimetos - nao fazer tratamento de lote/reserva
		//Fernando em 05/12/18 - ticket 10318 - repetindo conceito da OS 2831-15 - para dar desconto paletizao para o cliente Livre, pois entra na politica sem selecionar o Lote 
		If !::_lPaletizado .And. Empty(::_cLote) .And. AllTrim(SB1->B1_YCLASSE) == "2" .And. (M->C5_CLIENTE == "006338")
			::_lPaletizado := .T.
		EndIf

	EndIf

	_aImposto := U_fItImpos(N,{"IT_ALIQICM","IT_ALIQPIS","IT_ALIQCOF"})

	::_nPICMS 	:= _aImposto[1]
	::_nPPIS	:= _aImposto[2]
	::_nPCOF	:= _aImposto[3]

	//::_nAComis	:= U_fCalComi(M->C5_COMIS1,::_cProduto)
	//Fernando/Facile em 05/04/2016 -> solicitacao do Patelli para usar a comissao somente do cabelhaco do pedido somando todas
	::_nAComis	:= M->C5_COMIS1+M->C5_COMIS2+M->C5_COMIS3

	RestArea(aAreaB1)

Return    

//carregar parametros para buscar politica pelos dados gravados do SC6 - alterar pedido
Method LoadParAlt() Class TBiaPoliticaDesconto 

	Local aAreaB1 := SB1->(GetArea())
	Local _cTPEST 
	Local _nQtdDig
	Local nDivPA
	Local _aImposto
	Local _nPIt
	Local _cLOTSUG
	Local _cQTDSUG

	::_cCliente 	:= SC5->C5_CLIENTE+SC5->C5_LOJACLI
	::_cVendedor 	:= SC5->C5_VEND1
	::_dData		:= SC5->C5_EMISSAO
	::_cProduto 	:= SC6->C6_PRODUTO
	::_cLote		:= SC6->C6_LOTECTL

	_cTPEST		:= SC6->C6_YTPEST
	_nQtdDig 	:= SC6->C6_QTDVEN
	_cQTDSUG	:= SC6->C6_YQTDSUG
	_cLOTSUG	:= SC6->C6_YLOTSUG

	::DESP		:= SC6->C6_YDESP

	::DVER		:= SC6->C6_YDVER
	::DACO		:= SC6->C6_YDACO

	If SC6->(FieldPos("C6_YDAI")) > 0
		::DAI		:= SC6->C6_YDAI
	EndIf

	//Se eh paletizado ou aceitou sugestao nao tem bloqueio de sugestao
	::_lPaletizado  := ( ::_cLote == _cLOTSUG ) .And. ( _nQtdDig == _cQTDSUG )  

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+::_cProduto))

	//Pode ser que tenha rejeitado sugestao de fracionado mas a quantidade e paletizada
	//Pode estar como OP
	//Tickets 1642 e 1416 - se tiver quantidade paletizada / mesmo lotes com DIVPA diferentes / aplicar desconto de paletizao
	If !::_lPaletizado
		nDivPA := SB1->B1_YDIVPA * SB1->B1_CONV

		ZZ9->(DbSetOrder(1))
		If ZZ9->(DbSeek(XFilial("ZZ9")+::_cLote+::_cProduto))

			nDivPA := ZZ9->ZZ9_DIVPA * SB1->B1_CONV

		EndIf

		::_lPaletizado := (_nQtdDig % nDivPA) == 0
	EndIf

	//buscando posicao do item gravado no aCols para reprocessamento do imposto   
	_nPITEM	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})
	_nPIt := AScan(aCols, {|x| x[_nPITEM] == SC6->C6_ITEM })

	_aImposto := U_fItImpos(_nPIt,{"IT_ALIQICM","IT_ALIQPIS","IT_ALIQCOF"})

	::_nPICMS 	:= _aImposto[1]
	::_nPPIS	:= _aImposto[2]
	::_nPCOF	:= _aImposto[3]

	//::_nAComis	:= SC6->C6_COMIS1                        
	//Fernando/Facile em 05/04/2016 -> solicitacao do Patelli para usar a comissao somente do cabelhaco do pedido somando todas
	::_nAComis	:= SC5->C5_COMIS1+SC5->C5_COMIS2+SC5->C5_COMIS3

	RestArea(aAreaB1)

Return    

//carregar parametros pelo SC6 gravado - ALTERAR - metodo para carregar a ZA4
Method LoadParSC6(_cPedido, _cItem) Class TBiaPoliticaDesconto 

	Local aAreaC5 := SC5->(GetArea())
	Local aAreaC6 := SC6->(GetArea())

	Local _cTPEST 
	Local _nQtdDig
	Local nDivPA
	Local _aImposto  

	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(XFilial("SC6")+_cPedido+_cItem))

		SC5->(DbSetOrder(1))
		SC5->(DbSeek(XFilial("SC5")+SC6->C6_NUM))

		::_cCliente 	:= SC6->(C6_CLI+C6_LOJA)
		::_cVendedor 	:= SC5->C5_VEND1
		::_dData		:= SC5->C5_EMISSAO
		::_cProduto 	:= SC6->C6_PRODUTO
		::_cLote		:= SC6->C6_LOTECTL

		::DESP			:= SC6->C6_YDESP

		::DVER		:= SC6->C6_YDVER	
		::DACO		:= SC6->C6_YDACO

		If SC6->(FieldPos("C6_YDAI")) > 0
			::DAI		:= SC6->C6_YDAI
		EndIf

		::DCAT 			:= SC6->C6_YDCAT
		::DPAL 			:= SC6->C6_YDPAL
		::DREG 			:= SC6->C6_YDREG
		::DGER 			:= SC6->C6_YDMIX
		::DNV  			:= SC6->C6_YDNV

		::DCAT_ORI		:= ::DCAT
		::DPAL_ORI		:= ::DPAL
		::DREG_ORI		:= ::DREG
		::DGER_ORI		:= ::DGER
		::DNV_ORI		:= ::DNV	 

		ZA4->(DbSetOrder(1))
		If ZA4->(DbSeek(XFilial("ZA4")+SC6->(C6_NUM+C6_ITEM)+"DCAT")) .And. ( ZA4->ZA4_FC <> 0 )
			::FC   			:= ZA4->ZA4_FC
			::DCAT_ORI 		:= ZA4->ZA4_PDORI
		EndIf

		If ZA4->(DbSeek(XFilial("ZA4")+SC6->(C6_NUM+C6_ITEM)+"DPAL")) .And. ( ZA4->ZA4_FC <> 0 )
			::DPAL_ORI 		:= ZA4->ZA4_PDORI
		EndIf

		If ZA4->(DbSeek(XFilial("ZA4")+SC6->(C6_NUM+C6_ITEM)+"DREG")) .And. ( ZA4->ZA4_FC <> 0 )
			::DREG_ORI 		:= ZA4->ZA4_PDORI
		EndIf

		If ZA4->(DbSeek(XFilial("ZA4")+SC6->(C6_NUM+C6_ITEM)+"DGER")) .And. ( ZA4->ZA4_FC <> 0 )
			::DGER_ORI 		:= ZA4->ZA4_PDORI
		EndIf

		If ZA4->(DbSeek(XFilial("ZA4")+SC6->(C6_NUM+C6_ITEM)+"DNV")) .And. ( ZA4->ZA4_FC <> 0 )
			::DNV_ORI  		:= ZA4->ZA4_PDORI
		EndIf

	EndIf

	RestArea(aAreaC5)
	RestArea(aAreaC6)

Return  

//Funcao para gravar a tabela ZA4 apos gravacao do pedido - INCLUSAO
User Function BPOLGZA4()

	Local oDesconto := TBiaPoliticaDesconto():New()
	Local oDetalhe
	Local I

	oDesconto:LoadParAlt()

	If oDesconto:GetPolitica()

		oDesconto:Calculate()

		oDetalhe := TBiaComposicaoDesconto():New()
		oDetalhe:GetFromObj(oDesconto)

		For I := 1 To oDetalhe:oLst:GetCount()

			RecLock("ZA4",.T.)

			ZA4->ZA4_FILIAL		:= XFilial("ZA4")
			ZA4->ZA4_PEDIDO		:= SC6->C6_NUM
			ZA4->ZA4_ITEM		:= SC6->C6_ITEM 
			ZA4->ZA4_ALTUSU 	:= CUSERNAME
			ZA4->ZA4_CADDAT 	:= dDataBase
			ZA4->ZA4_CADHOR 	:= SubStr(Time(),1,5)

			ZA4->ZA4_TIPO  		:= 	oDetalhe:oLst:GetItem(I):Tipo
			ZA4->ZA4_CODREG		:=	oDetalhe:oLst:GetItem(I):CodReg
			ZA4->ZA4_PDESC		:=	oDetalhe:oLst:GetItem(I):PDesc
			ZA4->ZA4_FC			:=	oDetalhe:oLst:GetItem(I):FC
			ZA4->ZA4_PVCAT		:= 	oDetalhe:oLst:GetItem(I):PVCat
			ZA4->ZA4_PVSOL		:=	oDetalhe:oLst:GetItem(I):PVSol
			ZA4->ZA4_PICM		:=	oDetalhe:oLst:GetItem(I):PICM
			ZA4->ZA4_PPIS		:=	oDetalhe:oLst:GetItem(I):PPIS
			ZA4->ZA4_PCOF		:=	oDetalhe:oLst:GetItem(I):PCOF
			ZA4->ZA4_PCOMIS		:=	oDetalhe:oLst:GetItem(I):PComis
			ZA4->ZA4_PDORI		:=	oDetalhe:oLst:GetItem(I):PDesc_Ori

			ZA4->(MsUnlock())

		Next I

	EndIf

Return

//Funcao para regravar a politica usada do pedido caso não tenha ou esteja zerada na consulta CTRL F5 do pedido
User Function BPRECZA4(_cPedido)

	Local aAreaZA4 := ZA4->(GetArea())
	Local aAreaSC6 := SC6->(GetArea())

	ZA4->(DbSetOrder(1))
	If ZA4->(DbSeek(XFilial("ZA4")+_cPedido))

		While !ZA4->(EOF()) .And. ZA4->(ZA4_FILIAL+ZA4_PEDIDO) == (XFilial("ZA4")+_cPedido)

			If ( ZA4->ZA4_STATUS <> "X" )

				RecLock("ZA4",.F.)
				ZA4->ZA4_STATUS := "X"
				ZA4->(MsUnlock())

			EndIf

			ZA4->(dbSkip())
		EndDo 

	EndIf

	//grava novos registros conforme politica vigente
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(XFilial("SC6")+_cPedido))
		While !SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == (XFilial("SC6")+_cPedido)

			U_BPOLGZA4()

			SC6->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaZA4)
	RestArea(aAreaSC6)

Return

//Funcao de teste da politica / Tele de composicao do desconto <F4> no pedido
User Function BPOLTST1(_lPedido, _lInclui, _lPedPos)

	Local oDesconto := TBiaPoliticaDesconto():New() 
	Local aPergs := {}
	Local aRet := {Space(6),Space(2),Space(6),Space(15),1,0,12,4}

	Default _lPedido := .F.
	Default _lInclui := .T.  //Se esta na tela de inclusao de pedido
	Default _lPedPos := .F.  //Se esta em alguma tela com o SC5/SC6 posicionado

	If !_lPedido

		aAdd( aPergs ,{1,"Cliente: ",Space(6),"@!","","SA1","",,.F.})
		aAdd( aPergs ,{1,"Loja: ",Space(2),"@!","","","",,.F.})
		aAdd( aPergs ,{1,"Vendedor: ",Space(6),"@!","","SA3","",,.F.})
		aAdd( aPergs ,{1,"Produto: ",Space(15),"@!","","SB1","",,.F.})
		aAdd( aPergs ,{1,"Lote: ",Space(10),"@!","","","",,.F.})
		aAdd( aPergs ,{2,"Paletizado: ",1,{"Sim","Não"},30,Nil,.T.})
		aAdd( aPergs ,{1,"Desc.Especial: ",0.00,"@E 999.99","","","",,.F.})
		aAdd( aPergs ,{1,"ICMS: ",12.00,"@E 999.99","","","",,.F.})
		aAdd( aPergs ,{1,"PIS: ",1.65,"@E 999.99","","","",,.F.})
		aAdd( aPergs ,{1,"COFINS: ",7.60,"@E 999.99","","","",,.F.})
		aAdd( aPergs ,{1,"Comissao: ",4.00,"@E 999.99","","","",,.F.})

		If !ParamBox(aPergs ,"Parâmetros para teste da Política:",aRet,,,,,,,,.F.,.F.)   
			Return oDesconto
		EndIf

		If ( Empty(aRet[1]) .Or. Empty(aRet[2]) .Or. Empty(aRet[4]))
			MsgAlert("Obrigatorio preencher pelo menos Cliente, Loja e Produto!","BPOLTST1")
			Return oDesconto
		EndIf

		//Method GetPolitica(_cCliente, _cProduto, _lPaletizado) 
		//_cCliente => Codigo + Loja do Cliente  (8 Char)
		//_cVendedor => Vendedor
		//_cProduto => Produto
		//_lPaletizado => Qtde paletizada sim ou nao?
		//_nPICMS => Aliquota de ICMS
		//_nPPIS => Aliquota de PIS
		//_nPCOF => Aliquota de COFINS
		//_nAComis => Aliquota de Comissao  

		//Carrega os parametros da pergunta
		oDesconto:_cCliente 	:= aRet[1]+aRet[2]
		oDesconto:_cVendedor 	:= aRet[3]
		oDesconto:_cProduto 	:= aRet[4]
		oDesconto:_cLote		:= aRet[5]
		oDesconto:_lPaletizado 	:= aRet[6]==1
		oDesconto:_nPICMS	 	:= aRet[8]
		oDesconto:_nPPIS	 	:= aRet[9]
		oDesconto:_nPCOF	 	:= aRet[10]
		oDesconto:_nAComis		:= aRet[11]

		If oDesconto:GetPolitica()

			//faca alguma coisa se achar politica
			If (aRet[6] <> 0)  
				oDesconto:DESP := aRet[6]
				oDesconto:Calculate()
			EndIf	    

			DemoShow(oDesconto, 3)

		EndIf

	Else  

		//carregando parametro da tela
		If _lInclui
			oDesconto:LoadParMem()

			If oDesconto:GetPolitica()
				oDesconto:Calculate()
				DemoShow(oDesconto, 2)
			EndIf              
			//Alteracao de pedido - desconto ja gravado
		Else   

			If !_lPedPos 
				_cPedido	:= M->C5_NUM
				_cItem 		:= aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})]
			Else
				_cPedido 	:= SC5->C5_NUM
				_cItem 		:= SC6->C6_ITEM
			EndIf

			oDesconto:LoadParSC6(_cPedido, _cItem)
			oDesconto:Calculate()
			DemoShow(oDesconto, 1, _cPedido, _cItem)

		EndIf

	EndIf

Return	


Static Function DemoShow(oDesconto, _nOpc, _cPedido, _cItem)
	Local nOpc  //1 = Altera / 2 = Incluir / 3 = Teste
	Local oDetalhe
	Local nSeguro := 0

	Default _nOpc := 2 
	Default _cPedido := ""
	Default _cItem := ""      

	If Type("M->C5_VLRFRET") <> "U"
		nSeguro := M->C5_VLRFRET
	EndIf

	nOpc := U_FROPMSG("TBIAPOLITICADESCONTO - BPOLTST1",;
	"Descontos aplicados: "+" (Fator Contratual = "+  Transform(oDesconto:FC,"@E 9,999.999999")+")"+CRLF+;
	"  DPAL = "+			Transform(oDesconto:DPAL,"@E 999.99")+"%"+IIF( oDesconto:DPAL <> oDesconto:DPAL_ORI," (sem FC = "+Transform(oDesconto:DPAL_ORI,"@E 999.99")+")","")+CRLF+;
	"  DPOL = "+			Transform(oDesconto:DPOL,"@E 999.99")+"%"+" Composto por:"+CRLF+;
	"  -------------------------------------------------------"+CRLF+;
	"       DCAT = "+			Transform(oDesconto:DCAT,"@E 999.99")+"%"+IIF( oDesconto:DCAT <> oDesconto:DCAT_ORI," (sem FC = "+Transform(oDesconto:DCAT_ORI,"@E 999.99")+")","")+CRLF+;
	"       DREG = "+			Transform(oDesconto:DREG,"@E 999.99")+"%"+IIF( oDesconto:DREG <> oDesconto:DREG_ORI," (sem FC = "+Transform(oDesconto:DREG_ORI,"@E 999.99")+")","")+CRLF+;
	"       DGER = "+			Transform(oDesconto:DGER,"@E 999.99")+"%"+IIF( oDesconto:DGER <> oDesconto:DGER_ORI," (sem FC = "+Transform(oDesconto:DGER_ORI,"@E 999.99")+")","")+CRLF+CRLF+;
	"  DNV  = "+			Transform(oDesconto:DNV ,"@E 999.99")+"%"+IIF( oDesconto:DNV <> oDesconto:DNV_ORI," (sem FC = "+Transform(oDesconto:DNV_ORI,"@E 999.99")+")","")+CRLF+;
	"  DESP = "+			Transform(oDesconto:DESP,"@E 999.99")+"%"+CRLF+;
	"  DACO = "+			Transform(oDesconto:DACO,"@E 999.99")+"%"+CRLF+;
	"  DAI  = "+			Transform(oDesconto:DAI,"@E 999.99")+"%"+CRLF+;
	"  DVER = "+			Transform(oDesconto:DVER,"@E 999.99")+"%"+CRLF+CRLF+;
	"  Desconto Total = "+	Transform(oDesconto:DTOT,"@E 999.99")+"%"+CRLF+;
	IIF(nSeguro > 0,CRLF+"  Seguro + R$ "+	Transform(nSeguro,"@E 999.99")+CRLF,"")+CRLF;
	,{"OK","Detalhes"}, 3, IIF(nOpc == 3, "Teste de Politica de Desconto", "Composição do Desconto"))

	If ( nOpc == 2 )

		oDetalhe := TWBiaComposicaoDesconto():New()
		oDetalhe:oDesconto 	:= oDesconto
		oDetalhe:cPedido 	:=  _cPedido
		oDetalhe:cItem 		:= _cItem
		oDetalhe:Activate(_nOpc)

	EndIf

Return


Method CalVlDACO(_nPrcTab) Class TBiaPoliticaDesconto

	Local nPrc
	Local nVALDACO

	nPrc := ::PrcAntVer(_nPrcTab)

	nVALDACO := round(( nPrc * ::DACO )/100,2)

Return(nVALDACO)

Method CalVlDAI(_nPrcTab) Class TBiaPoliticaDesconto

	Local nPrc
	Local nVALDAI

	nPrc := ::PrcAntVer(_nPrcTab)

	nVALDAI := round(( nPrc * ::DAI )/100,2)

Return(nVALDAI)

Method PrcAntVer(_nPrcTab) Class TBiaPoliticaDesconto

	Local nPrc := _nPrcTab
	Local nDPOL
	Local nVALDACO

	nPrc := nPrc - round(( nPrc * ::DPAL )/100,2)

	nDPOL := (1 - ( (1 - (::DCAT/100)) * (1 - (::DREG/100)) * (1 - (::DGER/100)) )) * 100

	nPrc := nPrc - round(( nPrc * nDPOL )/100,2)

	nPrc := nPrc - round(( nPrc * ::DNV )/100,2)

	nPrc := nPrc - round(( nPrc * ::DESP )/100,2)

Return(nPrc)