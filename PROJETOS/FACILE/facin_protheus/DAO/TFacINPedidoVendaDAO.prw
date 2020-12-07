#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TFacINPedidoVendaDAO
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/


Class TFacINPedidoVendaDAO From LongClassName

	Data oModel
	Data oConn
	Method New() Constructor
	Method ListarFacIN(paramAux)
	Method CriarPTH()
	Method EditarPVFacIN(oObjFacIN, cNumPed) // MAX de 10 caracteres.

EndClass

Method New() Class TFacINPedidoVendaDAO

	::oModel   := ""
	::oConn     := TFacINConexao():New()

Return Self


Method ListarFacIN(paramAux) Class TFacINPedidoVendaDAO


	Local oJsonOBJ  := Nil
	Local oRequest  := Nil


	If !Empty(::oConn:OUSERM)

		oRequest  := FWRest():New(::oConn:cHostWS)

		if !Empty(paramAux)
			oRequest:setPath("/api/pedidovendaPTH"+paramAux+"")
		Else
			oRequest:setPath("/api/pedidovendaPTH")
		EndIf

		oRequest:Get(::oConn:aHeader)	  // chama a API
		If VAL(oRequest:ORESPONSEH:CSTATUSCODE) <= 201
			FWJsonDeserialize(oRequest:CRESULT, @oJsonOBJ)
			//conout(oRequest:CRESULT)
		ElseIf VAL(oRequest:ORESPONSEH:CSTATUSCODE) > 201
			conout("CodeHTTP: ",  VAL(oRequest:ORESPONSEH:CSTATUSCODE))
			conout(oRequest:CRESULT)
		Else
			conout(oRequest:GetLastError())
		Endif
	Endif

Return oJsonOBJ

Method EditarPVFacIN(oObjFacIN,cNumPed) Class TFacINPedidoVendaDAO


	Local oRequest  := ""
	Local cBody     := ""


	If !Empty(::oConn:OUSERM)
		oRequest  := FWRest():New(::oConn:cHostWS)
		cBody := '{"CodigoLegado":"'+cNumPed+'"}'
		oRequest:setPath("/api/pedidovendaPTH/"+cValToChar(oObjFacIN:Id)+"")
		oRequest:Put(::oConn:aHeader, cBody)	// Chama a API
		If !(oRequest:ORESPONSEH:CSTATUSCODE $ "409|405")
			If VAL(oRequest:ORESPONSEH:CSTATUSCODE) <= 201
				conout("Edicao NO PROTHEUS do Pedido de Venda  para o  FACIN")
				conout(oRequest:CRESULT)
			ElseIf VAL(oRequest:ORESPONSEH:CSTATUSCODE) > 201
				cError := " CodeHTTP: "+cValToChar(oRequest:ORESPONSEH:CSTATUSCODE)+" "+ CRLF + CRLF
				cError += " Error: "+cValToChar(oRequest:CRESULT)+" "+ CRLF + CRLF
				U_EmailFac("Erro em PUT Pedido de Venda - Protheus >> FacIN", cError, oRequest:CPATH, cBody)
			Endif
		Endif
	EndIf

Return(.T.)

////////----------------- DO FACIN para o PROTHEUS -----------------------------------------
Method CriarPTH() Class TFacINPedidoVendaDAO

	Local aC5CODLJ     := {}
	Local cCodTes      := ""
	Local cNumPed      := ""
	Local cError       := ""
	Local aCab         := {}
	Local aItens       := {}
	Local aDet         := {}
	Local aOFacIN      := {}
	Local nW					 := 0
	Local nX					 := 0


	/*
		SFM - Tes Inteligente. O cadastro das regras de preenchimento do código do TES está 
		vinculado com um código de tipo de 	movimentação (FM_TIPO), por exemplo: 
		01 - Venda de Mercadorias,
		02 - Simples Remessa de Material, 
		03 - Venda para Consumidor Final
	*/
	Local cTipOper 	:= SuperGetMV("ZF_TIPOTES", .F., "03")

	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .F.

	aOFacIN := ::ListarFacIN("?Status=finalizado")

	If !Empty(aOFacIN)

		For nW := 1 To Len(aOFacIN:RESPONSE)
			// Neste RDMAKE (Exemplo), o mesmo número do Pedido de Venda é utilizado para a Rotina Automática (Modelos INCLUSÃO / ALTERAÇÃO e EXCLUSÃO).

			//****************************************************************
			//* Inclusao - INÝCIO
			//****************************************************************
			aCab     := {}
			aItens   := {}

			aC5CODLJ := StrTokArr(AllTrim(aOFacIN:RESPONSE[nW]:CLIENTE:CodigoLegado),"-")
			cNumPed := GetSXENum("SC5","C5_NUM")

			aAdd(aCab,	{"C5_FILIAL" 	, xFilial("SC5")			,Nil})
			aAdd(aCab,	{"C5_NUM"   	, cNumPed				,Nil})
			aAdd(aCab,	{"C5_TIPO"   	, "N"						,Nil})
			aAdd(aCab,	{"C5_CLIENTE"	, aC5CODLJ[1]				,Nil})
			aAdd(aCab,	{"C5_LOJACLI"	, aC5CODLJ[2]				,Nil})
			aAdd(aCab,	{"C5_EMISSAO"	, Date()					,Nil})
			aAdd(aCab,	{"C5_VEND1"  	, AllTrim(aOFacIN:RESPONSE[nW]:Usuario:CodigoVendedor),Nil})
			aAdd(aCab,	{"C5_DESPESA" 	, 0							,Nil})
			aAdd(aCab,	{"C5_CONDPAG" 	, AllTrim(aOFacIN:RESPONSE[nW]:CondicaoPagamento:CodigoLegado)	,Nil})
			aAdd(aCab,	{"C5_DESCONT" 	, aOFacIN:RESPONSE[nW]:ValorDesconto		,Nil})
			aAdd(aCab,	{"C5_INDPRES" 	, "2"						,Nil}) 	//|2 - Significa venda não presencial -> internet |
			aAdd(aCab,	{"C5_YFACIN" 	, aOFacIN:RESPONSE[nW]:Id	,Nil}) 	// Id do FacIN
			aAdd(aCab,	{"C5_YFASYNC" 	, "N"	,Nil}) 	// Sincronizado?  (S)para sim <<APENAS QUANDO EXISTIR NF C5_NOTA>> ou (N) para não.


			For nX := 1 To Len(aOFacIN:RESPONSE[nW]:ListPedidoVendaItem)
				aDet     := {}
				//--- Informando os dados do item do Pedido de Venda
				AAdd(aDet,	{"C6_FILIAL" , xFilial("SC6")	,Nil})
				AAdd(aDet,	{"C6_NUM"  	 , cNumPed			,Nil})
				AAdd(aDet,	{"C6_ITEM"   , StrZero(nX,2)	,Nil})
				AAdd(aDet,	{"C6_PRODUTO", AllTrim(aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:Produto:CodigoLegado)		,Nil})
				AAdd(aDet,	{"C6_UM"     , AllTrim(aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:Produto:UnidadeMedida:CodigoLegado)		,Nil})
				AAdd(aDet,	{"C6_QTDVEN" , aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:Quantidade	,Nil})
				AAdd(aDet,	{"C6_PRCVEN" , aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:ValorUnitario			,Nil})
				AAdd(aDet,	{"C6_PRUNIT" , aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:ValorUnitario			,Nil})

				//|Procura a TES da Venda |
				If !Empty(cTipOper)
					cCodTes  :=  MaTesInt(02, cTipOper, aC5CODLJ[1], aC5CODLJ[2], "C", AllTrim(aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:Produto:CodigoLegado))
				EndIf

				If Empty(cCodTes)
					dbSelectArea("SB1")
					SB1->(dbSetOrder(1))//B1_FILIAL+B1_COD
					SB1->(dbSeek(xFilial("SB1")+AllTrim(aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:Produto:CodigoLegado)))
					cCodTes	:= SB1->B1_TS
				EndIf

				If Empty(cCodTes)
					cCodTes	:=  "502"
				EndIf
				//|Fim Procura a TES da Venda |


				AAdd(aDet,	{"C6_TES"   , cCodTes	,Nil})
				AAdd(aDet,	{"C6_DESCRI" , AllTrim(aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:Produto:Descricao)		,Nil})
				AAdd(aDet,	{"C6_LOCAL"  , "01"			,Nil})
				//AAdd(aDet,	{"C6_VALOR"  , Round((aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:Quantidade*aOFacIN:RESPONSE[nW]:ListPedidoVendaItem[nX]:ValorUnitario),TamSX3("C6_PRCVEN")[2]),Nil})
				AAdd(aItens,AClone(aDet))

			Next nX

			Begin Transaction
				MSExecAuto({|x,y,z|Mata410(x,y,z)},aCab,aItens,3)
				If !lMsErroAuto
					ConOut("Incluido com sucesso! " + cNumPed)
					ConfirmSX8()
					::EditarPVFacIN(aOFacIN:RESPONSE[nW], cNumPed)
				Else
					RollbackSx8()
					cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
					ConOut(PadC("Automatic routine ended with error", 80))
					ConOut("Error: "+ cError)
					U_EmailFac("Erro ao inserir pedido de Venda - FacIN  >> Protheus", cError, "", "")
				EndIf
			End Transaction
			lMsErroAuto    := .F.
			//****************************************************************
			//* Inclusao - FIM
			//****************************************************************
		Next nW

	EndIf

Return(.T.)




User Function ZPontin()

	If lNumPar
		cNumPed := GetMV("ZZ_NUMPED")
	Else
		cNumPed	:= GetSXENum("SC5","C5_NUM")
		ConfirmSx8()
	EndIf

	If !Empty(ZZA->ZZA_COND)
		cCondPag := ZZA->ZZA_COND
	EndIf

	aCab	:= {}
	aItens	:= {}
	cItem	:= "00"

	nRecZZA	:= ZZA->(Recno())

	aAdd(aCab,	{"C5_FILIAL" 	, xFilial("SC5")			,Nil})
	aAdd(aCab,	{"C5_NUM"   	, cNumPed					,Nil})
	aAdd(aCab,	{"C5_TIPO"   	, "N"						,Nil})
	aAdd(aCab,	{"C5_CLIENTE"	, cCli						,Nil})
	aAdd(aCab,	{"C5_LOJACLI"	, cLoja						,Nil})
	aAdd(aCab,	{"C5_EMISSAO"	, dDatabase					,Nil})
	aAdd(aCab,	{"C5_INCISS" 	, " "						,Nil})
	//aAdd(aCab,	{"C5_RECISS" 	, cRecISS					,Nil})
	aAdd(aCab,	{"C5_TRANSP" 	, ZZA->ZZA_TRANSP			,Nil})
	aAdd(aCab,	{"C5_VEND1"  	, cCodVend					,Nil})
	//aAdd(aCab,	{"C5_BANCO"		, "001"						,Nil}) //Verificar
	aAdd(aCab,	{"C5_TPFRETE"  	, "C"						,Nil}) //Verificar
	aAdd(aCab,	{"C5_FRETE"   	, ZZA->ZZA_FRETE			,Nil})
	aAdd(aCab,	{"C5_DESPESA" 	, 0							,Nil})
	aAdd(aCab,	{"C5_MENNOTA" 	, ""						,Nil})
	aAdd(aCab,	{"C5_MENPAD"  	, ""						,Nil})
	aAdd(aCab,	{"C5_CONDPAG" 	, cCondPag					,Nil})
	aAdd(aCab,	{"C5_VOLUME1" 	, 1							,Nil})
	aAdd(aCab,	{"C5_ESPECI1" 	, ""						,Nil})
	aAdd(aCab,	{"C5_TABELA" 	, cTabela					,Nil})
	aAdd(aCab,	{"C5_DESCONT" 	, Abs(ZZA->ZZA_VLDESC)		,Nil})
	aAdd(aCab,	{"C5_YWEB" 		, "S"						,Nil})
	aAdd(aCab,	{"C5_YCODMAG" 	, cOrcWeb					,Nil})
	//|Alteração para a EC 87/2015 DIFAL |
	aAdd(aCab,	{"C5_INDPRES" 	, "2"						,Nil}) 	//|2 - Significa venda não presencial -> internet |
	//aAdd(aCab,	{"C5_XCONTRA" 	, "2"						,Nil})
	//aAdd(aCab,	{"C5_ESPECI1" 	, "CAIXA"					,Nil})

	DbSelectArea("ZZB")
	ZZB->(DbSetOrder(1))
	If ZZB->(DbSeek(xFilial("ZZB") + ZZA->ZZA_NUM))
		While ZZB->(ZZB_FILIAL + ZZB_NUM) == ZZA->(ZZA_FILIAL + ZZA_NUM) .And. !ZZB->(EoF())

			aDet  := {}
			cItem := SomC5(cItem)

			dbSelectArea("SB1")
			SB1->(dbSetOrder(1))//B1_FILIAL+B1_COD
			SB1->(dbSeek(xFilial("SB1")+ZZB->ZZB_COD))
			SBZ->(dbSetOrder(1))
			//|Procura a TES da Venda |
			If !Empty(cTipOper)
				cCodTes := MaTesInt(02, cTipOper, cCli, cLoja, "C", ZZB->ZZB_COD) //|Obtem TES Inteligente |
			Else
				If SBZ->(dbSeek(xFilial("SBZ") + SB1->B1_COD))
					cCodTes	:= SBZ->BZ_TS
				EndIf
			EndIf

			If Empty(cCodTes)
				cCodTes	:= SB1->B1_TS
			EndIf

			If Empty(cCodTes)
				cCodTes	:= GetMV("ZZ_TESPAD",.F.,"501")
			EndIf

			//|Alteração para a EC 87/2015 DIFAL |
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			SC5->(dbSeek(xFilial("SC5") + cCli + cLoja))

			cLocal	:= SuperGetMV("ZZ_ARMZVEN",.F.,"01")

				/*
			If AllTrim(GetMV("MV_ARQPROD")) == "SBZ"

					dbSelectArea("SBZ")
					SBZ->(dbSetOrder(1))
				If SBZ->(dbSeek(xFilial("SBZ") + SB1->B1_COD))

					If !Empty(SBZ->BZ_LOCPAD)
							cLocal	:= SBZ->BZ_LOCPAD
					EndIf

				EndIf

			EndIf
				*/

			//|Calcula Totais |
			nPercIPI	:= 1

			dbSelectArea("SBZ")
			SBZ->(dbSetOrder(1))
			If SBZ->(dbSeek(xFilial("SBZ") + SB1->B1_COD))

				If AllTrim(SBZ->BZ_TS) $ "503/504"
					nPercIPI	:= 1 + (SB1->B1_IPI/100)
				EndIf

			EndIf

			nPrcVen	:= NoRound(ZZB->ZZB_PRCVEN / nPercIPI,2)

			nValLiq := (nPrcVen - ZZB->ZZB_VLDESC)
			nValTot := NoRound(nValLiq * ZZB->ZZB_QTDVEN,2)

				/*
				nDescto	:= 0

			If nValTot <> ZZB->ZZB_VALOR

					nDescto	:= nValTot - ZZB->ZZB_VALOR

					nDescto	:= IIf(nDescto<0,0,nDescto)

			EndIf
				*/

			AAdd(aDet,	{"C6_FILIAL" , xFilial("SC6")	,Nil})
			aAdd(aDet,	{"C6_NUM"  	 , cNumPed			,Nil})
			AAdd(aDet,	{"C6_ITEM"   , cItem			,Nil})
			AAdd(aDet,	{"C6_PRODUTO", ZZB->ZZB_COD		,Nil})
			AAdd(aDet,	{"C6_UM"     , SB1->B1_UM		,Nil})
			AAdd(aDet,	{"C6_QTDVEN" , ZZB->ZZB_QTDVEN	,Nil})
			AAdd(aDet,	{"C6_PRCVEN" , nPrcVen			,Nil})
			AAdd(aDet,	{"C6_PRUNIT" , nPrcVen			,Nil})
			AAdd(aDet,	{"C6_TES"    , cCodTes			,Nil})
			AAdd(aDet,	{"C6_DESCRI" , SB1->B1_DESC		,Nil})
			AAdd(aDet,	{"C6_LOCAL"  , cLocal			,Nil})
			AAdd(aDet,	{"C6_VALOR"  , Round((ZZB->ZZB_QTDVEN*nPrcVen),TamSX3("C6_PRCVEN")[2]),Nil})
			//AAdd(aDet,	{"C6_DESCONT", ZZB->ZZB_PERDES	,Nil})
			//AAdd(aDet,	{"C6_VALDESC", ZZB->ZZB_VLDESC	,Nil})

			AAdd(aItens,AClone(aDet))

			ZZB->(DbSkip())

		EndDo

	EndIf

	Begin Transaction

		//|Realiza a gravação do Orçamento |
		If Len(aCab) > 0 .And. Len(aDet) > 0 .And. lRet

			//Chama a execauto
			lMsErroAuto := .F.

			MSExecAuto({|x,y,z|Mata410(x,y,z)},aCab,aItens,3)

			ZZA->(dbGoTo(nRecZZA))

			If lMsErroAuto
				//ConOut(MostraErro())
				cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO

				ConOut(PadC("Automatic routine ended with error", 80))
				ConOut("Error: "+ cError)

				RollBackSX8()
				lRet	:= .F.
				//Else
				//	RecLock("SC5",.F.)
				//	SC5->C5_TRANSP	:= ZZA->ZZA_TRANSP
				//	SC5->(MsUnLock())
			EndIf
		Else
			DisarmTransaction()
			lRet 	:= .F.
			cMsg	+= "Não foram encontrados pedidos/itens para gravação!" + cEOL + cEOL
		EndIf

	End Transaction

	ZZA->(dbGoTo(nRecZZA))

	//|Atualiza numeração sequencial |
	If lRet
		If lNumPar
			PutMV("ZZ_NUMPED",StrZero(Val(cNumPed)+1,Len(cNumPed)))
			//Else
			//	ConfirmSx8()
		EndIf

		//|Atualiza ZZA com o numero do orçamento gerado |
		RecLock("ZZA",.F.)
		ZZA->ZZA_PVENDA := SC5->C5_NUM	//cNumPed
		ZZA->(MsUnLock())
		cMsg := "Pedido de Venda n. " + cNumPed + " criado com Sucesso!" + cEOL + cEOL

		If AllTrim(SC5->C5_CONDPAG) $ "001"
			cForma			:= "BST"
			cDescForma	:= "BOLETO ECOMMERCE"
		ElseIf AllTrim(SC5->C5_CONDPAG) $ "106/011/214/034/265"
			cForma			:= "BOL"
			cDescForma	:= "BOLETO BANCARIO"
		else
			cForma			:= "CC"
			cDescForma	:= "CARTAO CREDITO"
		EndIf

		//|Cria a SCV |
		RecLock("SCV",.T.)
		SCV->CV_FILIAL	:= xFilial("SCV")
		SCV->CV_PEDIDO	:= SC5->C5_NUM
		SCV->CV_FORMAPG	:= cForma
		SCV->CV_DESCFOR	:= cDescForma
		SCV->CV_RATFOR	:= 100
		SCV->(MsUnLock())

		//|gravar histórico |
		u_HistPedWB(ZZA->ZZA_NUM, cMsg)
	EndIf

	dbSelectArea("SC5")
	SC5->(dbOrderNickName("MAGIDX"))
	If SC5->(dbSeek(xFilial("SC5") + ZZA->ZZA_NUM))

		RecLock("ZZA",.F.)
		ZZA->ZZA_PVENDA := SC5->C5_NUM	//cNumPed
		ZZA->(MsUnLock())

		RecLock("SC5",.F.)
		SC5->C5_TRANSP	:= ZZA->ZZA_TRANSP
		SC5->(MsUnLock())

	EndIf

Return(.T.)
