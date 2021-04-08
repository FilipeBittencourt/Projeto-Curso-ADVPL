#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FROPMSG
@description Funcoes Uteis gerais para a reservas de pedidos
@author Fernando Rocha
@since 25/07/2017
@version undefined
@type function
/*/

//FUNCAO DE MENSAGENS PADRAO PARA O MODULO
User function FROPMSG(cTitulo, cMsg, aBtn, nOpc, cSubTit, lEditErro)
	Local nRet

	Default aBtn := {"OK"}
	Default nOpc := 3
	Default cSubTit := ""
	Default lEditErro := .F.

	nRet := Aviso(cTitulo,cMsg,aBtn,nOpc,cSubTit,,,lEditErro)

Return nRet

//Funcao para Efetuar o Login em Outra Empresa
User Function FROPLEMP(oServer, cEmp, cFil)
	Local lConnect
	Local cRpcServer := GetServerIP()
	Local nRpcPort := GetPvProFileInt("TCP", "PORT", 0, GetAdv97())
	Local cRpcEnv := GetEnvServer()

	ConOut("FUNCAO: "+AllTrim(FunName())+" - ABRINDO AMBIENTE EMPRESA: "+cEmp+" - FILIAL: "+cFil)

	oServer := TRPC():New(cRpcEnv)

	lConnect := oServer:Connect(cRpcServer, nRpcPort)

	If lConnect
		If !IsInCallStack("U_BIA938") .And. !IsInCallStack("U_INTRATCON")
			oServer:CallProc("RPCSetType", 3)
		EndIf
		oServer:CallProc("RPCSetEnv", cEmp, cFil)
		ConOut("FUNCAO: "+AllTrim(FunName())+" - AMBIENTE INICIADO COM SUCESSO.")
	EndIf

Return lConnect

//Executar qualquer metodo em outra empresa
User Function FROPCPRO(_cEmpDes,_cFilDes,_cNomeProc, _uPar1, _uPar2, _uPar3, _uPar4, _uPar5, _uPar6, _uPar7, _uPar8, _uPar9, _uPar10, _uPar11, _uPar12, _uPar13, _uPar14, _uPar15)
	Local oServer
	Local uReturn

	U_FROPLEMP(@oServer, _cEmpDes, _cFilDes)

	ConOut("FUNCAO: "+AllTrim(FunName())+" - EXECUTANDO CALLPROC METODO: "+_cNomeProc)
	uReturn := oServer:CallProc(_cNomeProc, _uPar1, _uPar2, _uPar3, _uPar4, _uPar5, _uPar6, _uPar7, _uPar8, _uPar9, _uPar10, _uPar11, _uPar12, _uPar13, _uPar14, _uPar15)

	oServer:Disconnect()
	ConOut("FUNCAO: "+AllTrim(FunName())+" - AMBIENTE ENCERRADO")

Return uReturn

User Function FROPCJOB(_cEmpDes,_cFilDes,_cNomeProc, _uPar1, _uPar2, _uPar3, _uPar4, _uPar5, _uPar6, _uPar7, _uPar8, _uPar9, _uPar10, _uPar11, _uPar12, _uPar13, _uPar14, _uPar15)
	Local oServer
	Local uReturn
	Local lWait := .F.  //Indica se a chamada deve aguardar a execucao da Job

	U_FROPLEMP(@oServer, _cEmpDes, _cFilDes)

	uReturn := oServer:StartJob(_cNomeProc, lWait, _uPar1, _uPar2, _uPar3, _uPar4, _uPar5, _uPar6, _uPar7, _uPar8, _uPar9, _uPar10, _uPar11, _uPar12, _uPar13, _uPar14, _uPar15)

	oServer:Disconnect()

Return uReturn

//Funcao para checar se pedido de venda tem Bloqueio
User Function FROPVLPV(cPedido, lConf ,lShow, lBloq1, lBloq2)
	Local lRetorno := .T.
	Local cAliasTmp
	Local cAliasTmp2
	Local cSQL
	Local _cTabSC6

	Default lConf	:= .T. //Testa pedido conferido
	Default lShow	:= .T. //Se exibe mensagens
	Default lBloq1	:= .F. //Definir se existe bloqueio de sugestao de lote - passar por @
	Default lBloq2	:= .F. //Definir se existe bloqueio de lote restrito - passar por @

	If lConf

		SC5->(DbSetOrder(1))
		IF SC5->(DbSeek(XFilial("SC5")+cPedido)) .And. SC5->C5_YCONF <> "S"

			If lShow
				U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP","Não é possível liberar o pedido "+cPedido+"."+CRLF+"O mesmo ainda NÃO FOI CONFERIDO.",,,"PEDIDO NÃO CONFERIDO")
			EndIf

			lRetorno := .F.
		ENDIF

	EndIf

	If lRetorno

		_cTabSC6 := RetSQLName("SC6")

		If AllTrim(cEmpAnt) == "07"
			SC6->(dbSetOrder(1))
			If SC6->(DbSeek(xFilial("SC6")+cPedido))

				SB1->(DbSetOrder(1))
				IF SB1->(DbSeek(XFilial("SB1")+SC6->C6_PRODUTO)) .And. !Empty(SB1->B1_YEMPEST)

					_cTabSC6 := "SC6"+SubStr(SB1->B1_YEMPEST,1,2)+"0"

					//projeto PBI - empresa depende do pedido
					If !Empty(SC6->C6_YEMPPED)
						_cTabSC6 := "SC6"+SC6->C6_YEMPPED+"0"
					EndIf

					SC5->(DbSetOrder(1))
					SC5->(DbSeek(XFilial("SC5")+cPedido))

					cPedido := SC5->C5_YPEDORI

				EndIf
			EndIf
		EndIf

		cAliasTmp := GetNextAlias()

		cSQL := "select CONT = count(*) from "+_cTabSC6+" where C6_NUM = '"+cPedido+"' and C6_YBLQLOT <> ' ' and SUBSTRING(C6_YBLQLOT,1,1) <> '0' and D_E_L_E_T_=' '"

		TCQUERY cSQL ALIAS (cAliasTmp) NEW


		cAliasTmp2 := GetNextAlias()
		cSQL := "select CONT = count(*) from "+_cTabSC6+" where C6_NUM = '"+cPedido+"' and C6_YBLQLOT <> ' ' and SUBSTRING(C6_YBLQLOT,2,1) <> '0' and D_E_L_E_T_=' '"

		TCQUERY cSQL ALIAS (cAliasTmp2) NEW

		If (cAliasTmp)->CONT > 0
			lBloq1 := .T.
		EndIf
		(cAliasTmp)->(DbCloseArea())

		If (cAliasTmp2)->CONT > 0
			lBloq2 := .T.
		EndIf
		(cAliasTmp2)->(DbCloseArea())


		If lBloq1

			If lShow
				U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP","Não é possível liberar o pedido "+cPedido+"."+CRLF+"Existem bloqueios de Sugestão de Lote"+CRLF+"Solicite ao GERENTE ADM DE VENDAS para liberar o pedido.",,,"PEDIDO COM BLOQUEIO DE LOTE")
			EndIf

			lRetorno := .F.

		EndIf

		If lBloq2

			If lShow
				U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP","Não é possível liberar o pedido "+cPedido+"."+CRLF+"Existem bloqueios de Lote Restrito"+CRLF+"Solicite ao ATENDENTE para liberar o pedido.",,,"PEDIDO COM BLOQUEIO DE LOTE")
			EndIf

			lRetorno := .F.

		EndIf

	EndIf

Return(lRetorno)

//Gravar Log de exclusao de reservas
User Function GravaPZ2(_nRECNO,_cCODENT,_cCHVENT,_cCAMPO,_cCONTEUDO,_cCODMOT, _cUSUARIO)

	RecLock("PZ2",.T.)

	PZ2->PZ2_FILIAL 	:= XFilial("PZ2")
	PZ2->PZ2_ID			:= AllTrim(Str(_nRECNO))
	PZ2->PZ2_CODENT 	:= _cCODENT
	PZ2->PZ2_CHVENT 	:= _cCHVENT
	PZ2->PZ2_CAMPO		:= _cCAMPO
	PZ2->PZ2_CONT		:= _cCONTEUDO
	PZ2->PZ2_DATA		:= dDataBase
	PZ2->PZ2_HORA		:= SubStr(Time(),1,5)
	PZ2->PZ2_CODMOT		:= _cCODMOT
	PZ2->PZ2_USURES 	:= _cUSUARIO

	PZ2->(MsUnlock())

Return

//Calculo de dias uteis para definir data de entrega do pedido
User Function FROPAD3U(_dData, _nDias)
	Local nDu 		:= 0
	Local dDt
	Default _nDias 	:= 3

	dDt := _dData
	While nDu < _nDias
		dDt := dDt + 1
		If DOW(dDt) <> 1 .and. DOW(dDt) <> 7
			nDu++
		EndIf
	EndDo

return(dDt)


//Conferir pedido da empresa de fabricao apos conferir na LM - PE M410STTS
User Function FRUTCONF(_cPedido, _cPedOri, _cAprov)
	Local aArea := GetArea()
	Local aAreaC5 := SC5->(GetArea())
	Local cAliasTmp
	Local cRet := ""

	SC6->(dbSetOrder(1))
	If SC6->(DbSeek(xFilial("SC6")+_cPedido))

		nLinhaEmp := SubStr(SC6->C6_YEMPPED,1,2)+"01"
		cRet := U_FROPCPRO(SubStr(nLinhaEmp,1,2),SubStr(nLinhaEmp,3,2),"U_XFRUTCON", _cPedOri, _cAprov)

		//Se for FILIAL LM - replicar também para a Matriz
		If AllTrim(CFILANT) <> "01"

			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				%NoParser%

				SELECT C5_NUM FROM SC5070 WHERE C5_FILIAL = '01' AND C5_YEMPPED = %Exp:SubStr(nLinhaEmp,1,2)% AND C5_YPEDORI = %Exp:_cPedOri% AND %NotDel% 

			EndSql

			If !(cAliasTmp)->(Eof())

				SC5->(DbSetOrder(1))
				If SC5->(DbSeek("01"+(cAliasTmp)->C5_NUM))

					RecLock("SC5",.F.)
					SC5->C5_YCONF := "S"
					SC5->(MsUnlock())

				EndIf
			EndIf

		EndIf
	EndIf

	RestArea(aAreaC5)
	RestArea(aArea)

Return(cRet)

User Function XFRUTCON(_cPedido, _cAprov)

	Local cRet := ""

	Begin Transaction

		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(XFilial("SC5")+_cPedido))

			RecLock("SC5",.F.)
			SC5->C5_YCONF := "S"
			SC5->(MsUnlock())

			If (AllTrim(_cAprov) <> ""  .And. ALLTRIM(SC5->C5_YSUBTP) <> "A")

				_oEmpAut := TBiaEmpenhoPedido():New()

				_aRetEmp := _oEmpAut:LibPedido(SC5->C5_NUM)
				cRet 	 := _aRetEmp[2]

				If (!Empty(_aRetEmp[2]))

					CONOUT("XFRUTCON - EMPENHO AUTOMATICO - Alerta empenho automático do pedido: "+_aRetEmp[2])

				EndIf

			EndIf

		EndIf

	End Transaction

Return(cRet)

//Empenho automatico pedido origem
User Function XEMPAUPO(_cPedido, _cAprov)

	Local cRet := ""

	Begin Transaction

		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(XFilial("SC5")+_cPedido))

			CONOUT("XEMPAUPO - SITUACAO_2 C5_NUM: "+SC5->C5_NUM+", C5_YCONF: "+SC5->C5_YCONF+", C5_YAPROV: "+_cAprov)

			If (AllTrim(_cAprov) <> ""  .And. ALLTRIM(SC5->C5_YSUBTP) <> "A")

				_oEmpAut := TBiaEmpenhoPedido():New()
				_aRetEmp := _oEmpAut:LibPedido(SC5->C5_NUM)
				cRet 	 := _aRetEmp[2]

				If (!Empty(_aRetEmp[2]))

					CONOUT("XEMPAUPO - EMPENHO AUTOMATICO - Alerta empenho automático do pedido: "+_aRetEmp[2])

				EndIf

			EndIf

		EndIf

	End Transaction

Return(cRet)



//VALIDAR SE EXISTE OP DISPONIVEL E BLOQUEAR ENTRADA DA NF - VALIDACAO DO CAMPO D1_QUANT
User function FOPVCR01(_nLIN)
	Local aArea := GetArea()
	Local _cProduto := Gdfieldget('D1_COD',_nLIN)
	Local _nQuant 	:= Gdfieldget('D1_QUANT',_nLIN)
	Local _cCfop	:= Gdfieldget('D1_CF',_nLIN)
	Local _cOp := ""

	If AllTrim(CA100FOR) <> "003721"
		Return(.T.)
	EndIf

	If !Substr(_cCfop,2,3) $ "124" //903" Retirado por Marcos Alberto Soprani em 07/05/15. Ainda não está bem claro a questão da distribuição pela rotina do Fernando...
		Return(.T.)
	EndIf

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+_cProduto)) .And. SB1->B1_TIPO == "PA" .And. SB1->B1_LOCALIZ == "S" .And. AllTrim(CA100FOR) == "003721"

		_cOp := PesqOPD1(_cProduto,_nQuant)

		If Empty(_cOp)

			U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP","Não foi encontrada OP com saldo disponível para entrada deste Item/NF, verificar com o Setor de PCP.",,,"Pesquisa de OP Vitcer")

			RestArea(aArea)
			Return(.F.)
		EndIf

	EndIf

	RestArea(aArea)
Return(.T.)

//PESQUISAR OP MAIS ANTIGA QUE ATENDE AO ITEM
Static Function PesqOPD1(_cProduto,_nQuant)
	Local cSQL
	Local cAliasTmp
	Local _cOp := ""

	cSQL := " select top 1 DATA = case when C2_YDTDISP <> '' then C2_YDTDISP else C2_DATPRF end "+CRLF
	cSQL += " , OP = (C2_NUM+C2_ITEM+C2_SEQUEN) "+CRLF
	cSQL += " from "+RetSQLName("SC2")+"  "+CRLF
	cSQL += " where  "+CRLF
	cSQL += " 	C2_FILIAL = '"+XFILIAL("SC2")+"' "+CRLF
	cSQL += " 	and C2_PRODUTO = '"+_cProduto+"' "+CRLF
	cSQL += " 	and (C2_QUANT - C2_QUJE) >= "+AllTrim(Str(_nQuant))+" "+CRLF
	cSQL += " 	and C2_DATRF = '' "+CRLF
	cSQL += " 	and D_E_L_E_T_ = ' ' "+CRLF
	cSQL += " 	order by 1  "+CRLF

	cAliasTmp := GetNextAlias()
	TCQUERY cSQL ALIAS (cAliasTmp) NEW

	(cAliasTmp)->(DbGoTop())

	If !(cAliasTmp)->(Eof())
		_cOp := (cAliasTmp)->OP
	EndIf

return(_cOp)

//GRAVAR O CAMPO D1_OP APOS A GRAVACAO DA NF - PONTO DE ENTRADA MT100AGR
User function FOPVCR02()
	Local aArea := GetArea()
	Local _cOp

	If AllTrim(SF1->F1_FORNECE) == "003721"

		SD1->(DbSetOrder(1))
		If SD1->(DbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))

			While !SD1->(Eof()) .And. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

				SF4->(DbSetOrder(1))
				IF !SF4->(DbSeek(XFilial("SF4")+SD1->D1_TES)) .Or. SF4->F4_ESTOQUE <> "S"
					SD1->(DbSkip())
					loop
				ENDIF

				If !Substr(SD1->D1_CF,2,3) $ "124" //903" Retirado por Marcos Alberto Soprani em 07/05/15. Ainda não está bem claro a questão da distribuição pela rotina do Fernando...
					SD1->(DbSkip())
					loop
				EndIf

				SB1->(DbSetOrder(1))
				If SB1->(DbSeek(XFilial("SB1")+SD1->D1_COD)) .And. SB1->B1_TIPO == "PA" .And. SB1->B1_LOCALIZ == "S"

					_cOp := PesqOPD1(SD1->D1_COD,SD1->D1_QUANT)
					If Empty(_cOp)
						U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP","Não foi encontrada OP com saldo disponível para entrada do Item: "+SD1->D1_ITEM+", verificar com o Setor de PCP.",,,"Pesquisa de OP Vitcer")
					Else

						SC2->(DbSetOrder(1))
						If SC2->(DbSeek(XFilial("SC2")+_cOp))

							If SD1->(FieldPos("D1_YOP"))>0

								RecLock("SD1",.F.)
								SD1->D1_YOP := _cOp
								SD1->(MsUnlock())

								RecLock("SC2",.F.)
								SC2->C2_QUJE  := SC2->C2_QUJE + SD1->D1_QUANT
								SC2->(MsUnlock())

							EndIf

						EndIf

					EndIf

				EndIf

				SD1->(DbSkip())
			EndDo

		EndIf

	EndIf

	RestArea(aArea)
Return

//EXCLUSAO DA NF - VOLTAR O SALDO DA OP - PONTO DE ENTRADA SD1100E
User function FOPVCR03()
	Local aArea := GetArea()
	Local _cOp

	If !(SD1->(FieldPos("D1_YOP"))>0)
		Return
	EndIf

	If AllTrim(SF1->F1_FORNECE) == "003721"

		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(XFilial("SB1")+SD1->D1_COD)) .And. SB1->B1_TIPO == "PA" .And. SB1->B1_LOCALIZ == "S"

			_cOp := SD1->D1_YOP
			If !Empty(_cOp)

				SC2->(DbSetOrder(1))
				If SC2->(DbSeek(XFilial("SC2")+_cOp))

					RecLock("SC2",.F.)
					SC2->C2_QUJE  := SC2->C2_QUJE - SD1->D1_QUANT
					SC2->(MsUnlock())

				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(aArea)
Return

//Buscar nomes dos liberadores para mensagem na inclusao de pedido
User Function FRGERADM(_cPedido)
	Local I       := 1
	Local aIdGAdm := {}
	Local aUser   := {}
	Local cRet    := ""
	Local cEmpPed := CEMPANT
	Local aAreaC6 := SC6->(GetArea())
	Local aAreaB1 := SB1->(GetArea())
	Local aAreaZ7 := ZZ7->(GetArea())

	/*
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(XFilial("SC6")+_cPedido))
		SB1->(DbSetOrder(1))
		IF SB1->(DbSeek(XFilial("SB1")+SC6->C6_PRODUTO)) .And. !Empty(SB1->B1_YEMPEST)
			cEmpPed := SubStr(SB1->B1_YEMPEST,1,2) 
		ENDIF
	EndIf
	aIdGAdm := StrToKArr(AllTrim(GetNewPar("FA_RGADM"+AllTrim(cEmpPed),"")),";")
	*/

	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(XFilial("SC6")+_cPedido))

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(XFilial("SB1")+SC6->C6_PRODUTO))

		ZZ7->(DbSetOrder(1))
		If ZZ7->(DbSeek(XFilial("ZZ7")+SB1->B1_YLINHA+SB1->B1_YLINSEQ))
			If Alltrim(ZZ7->ZZ7_EMP) == "1302"
				aIdGAdm := StrToKArr(AllTrim(U_GETBIAPAR("FA_RGADM1302",.F.)),";")
			Else
				aIdGAdm := StrToKArr(AllTrim(U_GETBIAPAR("FA_RGADMXXXX",.F.)),";")
			EndIf
		EndIf
	EndIf

	For I := 1 To Len(aIdGAdm)

		PswOrder(2)
		If (PswSeek(aIdGAdm[I], .T.))
			aUser := Pswret(1)

			If !Empty(cRet)
				cRet+="#"
			EndIf

			cRet += AllTrim(aUser[1][2])

		EndIf

	Next I

	RestArea(aAreaC6)
	RestArea(aAreaB1)
	RestArea(aAreaZ7)
Return(cRet)

//Buscar nomes dos liberadores para mensagem na inclusao de pedido
User Function FSEGORI(_cPedido)
	Local cAliasTmp
	Local cRet := ""
	Local aAreaA1 := SA1->(GetArea())
	Local aAreaC5 := SC5->(GetArea())
	Local _cCliente

	//Checkar se e o Atendente responsavel para alterar pedidos
	If AllTrim(FunName()) == "MATA410" .And. INCLUI
		cRet := SA1->A1_YTPSEG
	Else
		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(XFilial("SC5")+_cPedido))
			_cCliente := SC5->(C5_CLIENTE+C5_LOJACLI)
			If _cCliente == "01006401"
				_cCliente := SC5->(C5_YCLIORI+C5_YLOJORI)
			EndIf

			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(XFilial("SA1")+_cCliente))
				cRet := SA1->A1_YTPSEG
			EndIf
		EndIf
	EndIf

	RestArea(aAreaA1)
	RestArea(aAreaC5)
Return(cRet)


//Gatilho no C6_PRODUTO para preencher o campo C6_LOCAL dos pedidos de Porcelanato Incesa na LM
User function FRGAARM()

	Local _cProd := M->C6_PRODUTO
	Local _cLocal


	//tem local e e reserva de OP
	//problema caso gatinhar produto novamente
	If (!Empty(Gdfieldget('C6_LOCAL', n)) .And. AllTrim(Gdfieldget('C6_YTPEST', n)) == 'R')
		_cLocal := Gdfieldget('C6_LOCAL', n)
		Return(_cLocal)
	EndIf


	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+_cProd))
	IF (M->C5_YLINHA == '2' .And. SubStr(SB1->B1_YEMPEST,1,2) == "05")

		_cLocal := "04"

	ELSE

		_cLocal := SB1->B1_LOCPAD

	ENDIF

Return(_cLocal)



/*/{Protheus.doc} FRSALDOP
@description Funcao para retornar o saldo disponivel por OP baseado em funcao geral no SQL
@author Fernando Rocha
@since 24/01/2018
@version 1.0
@type function
/*/
User Function FRSALDOP(_cEmpresa,_cFilial,_cOpNum,_cOpItem,_cOpSeq,_cPedido,_cItemPV )

	Local nSaldo := 0
	Local cAliasTmp
	Local cSQL

	cAliasTmp := GetNextAlias()

	cSQL := "select SALDO = dbo.FNC_ROP_CALC_SALDO_OP_"+_cEmpresa+"('"+_cFilial+"', '"+_cOpNum+"', '"+_cOpItem+"', '"+_cOpSeq+"', '"+_cPedido+"', '"+_cItemPV+"', 1)"

	TCQUERY cSQL ALIAS (cAliasTmp) NEW

	If !(cAliasTmp)->(Eof())

		nSaldo := (cAliasTmp)->SALDO

	EndIf

	(cAliasTmp)->(DbCloseArea())

Return(nSaldo)
