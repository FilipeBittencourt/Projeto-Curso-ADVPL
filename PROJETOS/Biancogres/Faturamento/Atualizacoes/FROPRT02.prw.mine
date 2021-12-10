#include "PROTHEUS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} FROPRT02
@description Programas Uteis Reserva de Estoque para pedidos de venda
@description fernando/facile em 30/03/2016 - adicionado o parametro Subtp para reservas de amostra - OS 4467-15
@author Fernando Rocha
@since 25/07/2017
@version undefined
@param _cPedido, , descricao
@param _cItem, , descricao
@param _cProduto, , descricao
@param _cLocal, , descricao
@param _nQuant, , descricao
@param _cVendPed, , descricao
@param _cLoteSel, , descricao
@param _lNoTemp, , descricao
@param _cMotExc, , descricao
@param _cSubTp, , descricao
@type function
/*/

#DEFINE TIT_MSG "SISTEMA - RESERVA DE ESTOQUE/OP"

User Function FROPRT02(_cPedido, _cItem, _cProduto, _cLocal, _nQuant, _cVendPed, _cLoteSel, _lNoTemp, _cMotExc, _cSubTp, _cEmpEst, _cNumRes)
	Local aArea := GetArea()
	Local nSaldo
	Local aRet
	Local nLinhaEmp
	Local _cUserName := CUSERNAME

	Default _cLoteSel := ""
	Default _lNoTemp  := .F.
	Default _cMotExc  := "LOK"
	Default _cSubTp	  := ""
	Default _cEmpEst  := ""
	Default _cNumRes  := ""

	If Type("_FROPCHVTEMPRES") <> "U" .And. !Empty(_FROPCHVTEMPRES)
		_cUserName := _FROPCHVTEMPRES
	EndIf

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+_cProduto))

	If !( AllTrim(CEMPANT) $ "07" ) .OR. (SB1->B1_TIPO == "PR")

		aRet := U_FRRT02IR(_cPedido, _cItem, _cProduto, _cLocal, _nQuant, _cVendPed, _cLoteSel,,_cUserName, _lNoTemp, _cMotExc, _cSubTp, _cNumRes)

	ElseIf (AllTrim(cEmpAnt) == '07' .And. AllTrim(cFilAnt) == '05' )

		aRet := U_FRRT02IR(_cPedido, _cItem, _cProduto, _cLocal, _nQuant, _cVendPed, _cLoteSel, ,_cUserName, _lNoTemp, _cMotExc, _cSubTp, _cNumRes)

	Else

		SB1->(DbSetOrder(1))
		IF SB1->(DbSeek(XFilial("SB1")+_cProduto)) .And. !Empty(SB1->B1_YEMPEST)

			If Alltrim(FunName()) == "MATA410" .And. !Empty(_cEmpEst)

				nLinhaEmp := _cEmpEst+"01"

			Else

				nLinhaEmp := SB1->B1_YEMPEST

			EndIf

			aRet := U_FROPCPRO(SubStr(nLinhaEmp,1,2),SubStr(nLinhaEmp,3,2),"U_FRRT02IR", _cPedido, _cItem, _cProduto, _cLocal, _nQuant, _cVendPed, _cLoteSel, AllTrim(CEMPANT)+AllTrim(CFILANT), _cUserName, _lNoTemp, _cMotExc, _cSubTp, _cNumRes)

		Else

			U_FROPMSG(TIT_MSG, 	"Formato sem EMPRESA DE FABRICAÇÃO cadastrada. Verifique.",,,"CONFIGURAÇÃO DO FORMATO")
			aRet := {1,{}}

		EndIf

		If Len(aRet[2]) <= 0

			U_GravaPZ2(0,"SC0","NORES","FRRT02IR_LM","Qtde: "+AllTrim(Str(_nQuant)),"997", CUSERNAME)

			__EstLote := U_FROPSAL(_cProduto,_cLocal,_cLoteSel)
			__EstTot := U_FROPSAL(_cProduto,_cLocal)

			U_FROPMSG(TIT_MSG, 	"Não foi possível efetuar reserva do Lote:"+CRLF+;
				"Quantidade a reservar: "+AllTrim(Str(_nQuant))+CRLF+;
				"Produto: "+AllTrim(_cProduto)+CRLF+;
				"Lote: "+_cLoteSel+CRLF+;
				"Saldo Lote Calculado: "+AllTrim(Str( __EstLote ))+CRLF+;
				"Saldo Total Arm. Calculado: "+AllTrim(Str( __EstTot ))+CRLF+CRLF+;
				"Verificar - Inconsistência no estoque.";
				,,3,"ATENÇÃO!!!")

			aRet := {1,{}}

		EndIf

	EndIf

	RestArea(aArea)
Return(aRet)

User Function FRRT02IR(_cPedido, _cItem, _cProduto, _cLocal, _nQuant, _cVendPed, _cLoteSel, _cEmpOri, _cUserName, _lNoTemp, _cMotExc, _cSubTp, _cNumRes)
	Local cAliasSld
	Local nSaldo
	Local nTotRes
	Local aRetLotes := {}
	Local _cExpLot
	Local _cExpEnd
	Local _cChaveC0
	Local _cIndexC0
	Local _cFieldsC0
	Local _cUserChv
	Local _lOkRes

	Default _cVendPed 	:= ""
	Default _cLoteSel 	:= ""
	Default _cEmpOri 	:= ""
	Default _cUserName 	:= CUSERNAME
	Default _lNoTemp 	:= .F.
	Default _cMotExc 	:= "LOK"
	Default _cSubTp		:= ""
	Default _cNumRes	:= ""




	//Indice 8 personalido -> C0_YPEDIDO+C0_YITEMPV   nick  'PEDIDO'
	//Indice 9 personalido -> C0_YEMPORI+C0_YPITORI   nick  'EMPPEDORI'
	//Apagar reservas anteriores

	If _cEmpOri == "0701"
		_cChaveC0 := XFilial("SC0")+_cEmpOri+_cPedido+_cItem
		_cIndexC0 := 'EMPPEDORI'
		_cFieldsC0 := "C0_FILIAL+C0_YEMPORI+C0_YPITORI"
	Else
		_cChaveC0 := XFilial("SC0")+_cPedido+_cItem
		_cIndexC0 := 'PEDIDO'
		_cFieldsC0 := "C0_FILIAL+C0_YPEDIDO+C0_YITEMPV"
	EndIf

	If (!Empty(_cNumRes))

		__nQuantAnt := U_GQTRESPI(_cUserName, _cProduto, _cLoteSel, _cPedido, _cItem, _cEmpOri, '')
		If (__nQuantAnt > 0 .And.  __nQuantAnt <> _nQuant)
			U_CSRESPRO(_cNumRes, _cProduto, _cLoteSel, __nQuantAnt)	//Volta a quantidad da reserva anterior*/
		EndIf

		If !(U_EXRESPEI(_cUserName, _cProduto, _cLoteSel, _nQuant, _cPedido, _cItem, _cEmpOri, ''))
			U_BSRESPRO(_cNumRes, _cProduto, _cLoteSel, _nQuant)
		EndIf

	EndIf

	//Apagar reservas do Item para gerar novamente
	U_FRRT02EX(_cPedido, _cItem, _cProduto, _cMotExc, _cEmpOri, _cUserName)

	//Alert('Passei: '+_cNumRes)



	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+_cProduto))

	IF SB1->B1_TIPO <> "PR"

		//Pesquisa dos Lotes para reserva
		//Retornar todos os Enderecos para o mesmo lote com capacidade para atender na totalidade o item do pedido

		If !Empty(_cLoteSel)
			_cExpLot := "% and BF_LOTECTL = '"+_cLoteSel+"' %"
		Else
			_cExpLot := "% and 1 = 1 %"
		EndIf

		If AllTrim(CEMPANT) <> "13"
			If (_cLocal <> "05")
				_cExpEnd := "% and BF_LOCALIZ in ('ZZZZ','P. DEVOL') %"
			Else
				_cExpEnd := "% and BF_LOCALIZ in ('AMT') %"
			EndIf
		Else
			_cExpEnd := "% and 1 = 1 %"
		EndIf

		If (AllTrim(cEmpAnt) == '07' .And. AllTrim(cFilAnt) == '05' )
			_cExpEnd := "% and BF_FILIAL	= '05' %"
		EndIf

		cAliasSld := GetNextAlias()
		BeginSql Alias cAliasSld
			%NOPARSER%

			With TAB_LOT as
			(select BF_LOTECTL, SALDO = SUM(BF_QUANT - BF_EMPENHO)
			from %TABLE:SBF% SBF (nolock)
			where 	BF_PRODUTO = %EXP:_cProduto%
			and BF_LOCAL = %EXP:_cLocal%
			and (BF_QUANT - BF_EMPENHO) > 0
			%EXP:_cExpLot%
			and SBF.D_E_L_E_T_ = ''
			%EXP:_cExpEnd%
			group by BF_LOTECTL)
			,TAB_LOT2 as
			(select top 1 LOTE = BF_LOTECTL
			from TAB_LOT
			where Round(SALDO,2) >= Round(%EXP:_nQuant%,2)
			order by SALDO)

			select BF_FILIAL, BF_PRODUTO, BF_LOCAL,BF_LOTECTL, BF_LOCALIZ, BF_NUMSERI
			,SALDO = SUM(BF_QUANT - BF_EMPENHO)
			from %TABLE:SBF% SBF (nolock), TAB_LOT2
			where BF_PRODUTO = %EXP:_cProduto%
			and BF_LOCAL = %EXP:_cLocal%
			and BF_LOTECTL = TAB_LOT2.LOTE
			%EXP:_cExpEnd%
			and SBF.D_E_L_E_T_ = ''
			group by BF_FILIAL, BF_PRODUTO, BF_LOCAL,BF_LOTECTL, BF_LOCALIZ, BF_NUMSERI
			order by SALDO desc

		EndSql

	ELSE

		//Buscando Saldo de Produtos PR
		cAliasSld := GetNextAlias()
		BeginSql Alias cAliasSld
			%NoParser%

			select top 1 
			BF_FILIAL = B2_FILIAL, 
			BF_PRODUTO = B2_COD, 
			BF_LOCAL = B2_LOCAL,
			BF_LOTECTL = '', 
			BF_LOCALIZ = '', 
			BF_NUMSERI = '',
			SALDO = ISNULL(B2_QATU - (B2_QEMP + B2_RESERVA),0) 
			FROM SB2070 SB2 (nolock)
			JOIN SB1010 SB1 (nolock) ON B1_COD = B2_COD
			WHERE 
			B1_TIPO = 'PR' 
			AND B2_COD = %EXP:_cProduto%
			AND B2_LOCAL IN ('02','04') 
			AND B2_QATU > 0 
			AND SB1.D_E_L_E_T_=' ' 
			AND SB2.D_E_L_E_T_=' ' 

		EndSql

	ENDIF

	If (cAliasSld)->(Eof()) .And. !Empty(_cLoteSel)

		__EstLote := U_FROPSAL(_cProduto,_cLocal, _cLoteSel)
		__EstTot := U_FROPSAL(_cProduto,_cLocal)

		U_FROPMSG(TIT_MSG, 	"Não foi possível efetuar reserva do Lote:"+CRLF+;
			"Quantidade a reservar: "+AllTrim(Str(_nQuant))+CRLF+;
			"Produto: "+AllTrim(_cProduto)+CRLF+;
			"Lote: "+_cLoteSel+CRLF+;
			"Saldo Lote Calculado: "+AllTrim(Str( __EstLote ))+CRLF+;
			"Saldo Total Arm. Calculado: "+AllTrim(Str( __EstTot ))+CRLF+CRLF+;
			"Verificar - Incosistência no estoque.";
			,,3,"ATENÇÃO!!!")

		return({1,aRetLotes})

	ElseIf (cAliasSld)->(Eof()) .And. Empty(_cLoteSel)

		__EstTot := U_FROPSAL(_cProduto,_cLocal)

		U_FROPMSG(TIT_MSG, 	"Não foi possível efetuar reserva do Produto:"+CRLF+;
			"Quantidade a reservar: "+AllTrim(Str(_nQuant))+CRLF+;
			"Produto: "+AllTrim(_cProduto)+CRLF+;
			"Saldo Total Arm. Calculado: "+AllTrim(Str( __EstTot ))+CRLF+CRLF+;
			"Verificar - Incosistência no estoque.";
			,,3,"ATENÇÃO!!!")

		return({1,aRetLotes})

	EndIf

	nSaldo := _nQuant
	(cAliasSld)->(DbGoTop())
	While !(cAliasSld)->(Eof())

		If nSaldo <= 0 .And. !Empty(_cLoteSel)

			__EstLote := U_FROPSAL(_cProduto,_cLocal,(cAliasSld)->BF_LOTECTL)
			__EstTot := U_FROPSAL(_cProduto,_cLocal)

			U_FROPMSG(TIT_MSG, 	"Não foi possível efetuar reserva do Lote:"+CRLF+;
				"Quantidade a reservar: "+AllTrim(Str(Min(nSaldo,(cAliasSld)->SALDO)))+CRLF+;
				"Produto: "+AllTrim(_cProduto)+CRLF+;
				"Lote: "+(cAliasSld)->BF_LOTECTL+CRLF+;
				"Saldo Lote Calculado: "+AllTrim(Str( __EstLote ))+CRLF+;
				"Saldo Total Arm. Calculado: "+AllTrim(Str( __EstTot ))+CRLF+CRLF+;
				"Verificar - Incosistência no estoque.";
				,,3,"ATENÇÃO!!!")

			Exit

		ElseIf nSaldo <= 0 .And. Empty(_cLoteSel)

			__EstTot := U_FROPSAL(_cProduto,_cLocal)

			U_FROPMSG(TIT_MSG, 	"Não foi possível efetuar reserva do Produto:"+CRLF+;
				"Quantidade a reservar: "+AllTrim(Str(_nQuant))+CRLF+;
				"Produto: "+AllTrim(_cProduto)+CRLF+;
				"Saldo Total Arm. Calculado: "+AllTrim(Str( __EstTot ))+CRLF+CRLF+;
				"Verificar - Incosistência no estoque.";
				,,3,"ATENÇÃO!!!")

			Exit

		EndIf

		cNumero := GetSx8Num("SC0","C0_NUM")
		ConfirmSx8()

		_lOkRes := a430Reserva({1,"VD","",_cUserName,XFilial("SC0")},;
			cNumero,;
			_cProduto,;
			_cLocal,;
			Round(Min(nSaldo,(cAliasSld)->SALDO),2),;
			{	"",;
			(cAliasSld)->BF_LOTECTL,;
			(cAliasSld)->BF_LOCALIZ,;
			(cAliasSld)->BF_NUMSERI})


		If !_lOkRes
			U_GravaPZ2(0,"SC0",cNumero,"ERROGR","Qtde: "+AllTrim(Str(Min(nSaldo,(cAliasSld)->SALDO))),"999", _cUserName)

			__EstLote := U_FROPSAL(_cProduto,_cLocal,(cAliasSld)->BF_LOTECTL)
			__EstTot := U_FROPSAL(_cProduto,_cLocal)

			U_FROPMSG(TIT_MSG, 	"Não foi possível efetuar reserva do Lote:"+CRLF+;
				"Quantidade a reservar: "+AllTrim(Str(Min(nSaldo,(cAliasSld)->SALDO)))+CRLF+;
				"Produto: "+AllTrim(_cProduto)+CRLF+;
				"Lote: "+(cAliasSld)->BF_LOTECTL+CRLF+;
				"Saldo Lote Calculado: "+AllTrim(Str( __EstLote ))+CRLF+;
				"Saldo Total Arm. Calculado: "+AllTrim(Str( __EstTot ))+CRLF+CRLF+;
				"Verificar - Incosistência no estoque.";
				,,3,"ATENÇÃO!!!")

			return({1,aRetLotes})
			exit

		EndIf

		SC0->(DbSetOrder(1))
		If SC0->(DbSeek(XFilial("SC0")+cNumero+_cProduto))

			RecLock("SC0",.F.)

			If Empty(_cEmpOri)
				SC0->C0_YPEDIDO 	:= _cPedido
				SC0->C0_YITEMPV		:= _cItem
			Else
				SC0->C0_YPITORI 	:= _cPedido+_cItem
				SC0->C0_YEMPORI		:= _cEmpOri
			EndIf

			If !Empty(_cSubTp) .And. ( _cSubTp $ "A #G #F #M " )  //Fernando/Facile em 30/03/2016
				SC0->C0_VALIDA		:= dDataBase + 99      //Pedidos de amostra reserva de 30 dias - OS 4865-15  //Alterado para 90 Dias Ticket 7590
			Else
				SC0->C0_VALIDA		:= dDataBase + 10
			EndIf

			If _lNoTemp
				SC0->C0_YTEMP		:= "N"
			Else
				SC0->C0_YTEMP		:= "S"
			EndIf

			SC0->C0_YHORA		:= SubStr(Time(),1,5)
			SC0->C0_YVEND		:= IIF(Type("CREPATU") <> "U" .And. !EMPTY(CREPATU),CREPATU,_cVendPed)  //Buscar o Vendedor logado quando representante
			SC0->C0_YUSER		:= __CUSERID
			SC0->C0_OBS 		:= "RESERVA PARA PEDIDO"
			SC0->(MsUnlock())

			AAdd(aRetLotes, SC0->C0_LOTECTL)

			nSaldo := nSaldo - Min(nSaldo,(cAliasSld)->SALDO)

		Else

			U_GravaPZ2(0,"SC0",cNumero,"ERROGR","Qtde: "+AllTrim(Str(Min(nSaldo,(cAliasSld)->SALDO))),"998", _cUserName)

			__EstLote := U_FROPSAL(_cProduto,_cLocal,(cAliasSld)->BF_LOTECTL)
			__EstTot := U_FROPSAL(_cProduto,_cLocal)

			U_FROPMSG(TIT_MSG, 	"Não foi possível efetuar reserva do Lote:"+CRLF+;
				"Quantidade a reservar: "+AllTrim(Str(Min(nSaldo,(cAliasSld)->SALDO)))+CRLF+;
				"Produto: "+AllTrim(_cProduto)+CRLF+;
				"Lote: "+(cAliasSld)->BF_LOTECTL+CRLF+;
				"Saldo Lote Calculado: "+AllTrim(Str( __EstLote ))+CRLF+;
				"Saldo Total Arm. Calculado: "+AllTrim(Str( __EstTot ))+CRLF+CRLF+;
				"Verificar - Incosistência no estoque.";
				,,3,"ATENÇÃO!!!")

			return({1,aRetLotes})

		EndIf

		If nSaldo <= 0
			Exit
		EndIf

		(cAliasSld)->(DbSkip())
	EndDo
	(cAliasSld)->(DbCloseArea())
	DbCommitAll()

return({0,aRetLotes})



//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Funcao para Estornar as reservas SC0 temporarias quando cancela a tela de inclusão
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function FRRT02EX(_cPedido, _cItem, _cProduto, _cMotExc, _cEmpOri, _cUserOri, _lDelOP)
	Local _cSPName
	Local nLinhaEmp
	Local _aAreaSC6 := SC6->(GetArea())
	Local _aAreaSB1 := SB1->(GetArea())
	Local _aAreaZZ7 := ZZ7->(GetArea())
	Local _cUserName := CUSERNAME
	Local _lDelTemp := .F.
	Local _cEmpEst	:= ""

	Default _cItem := ""
	Default _cProduto := ""
	Default _cEmpOri := ""
	Default _cUserOri := ""
	Default _lDelOP := .T.

	If Type("_FROPCHVTEMPRES") <> "U" .And. !Empty(_FROPCHVTEMPRES)
		_cUserName 	:= _FROPCHVTEMPRES
		_lDelTemp	:= .T.
	ElseIf AllTrim(_cEmpOri) == "0701"  //esta digitando pedido via conexao RPC com a empresa origem
		_cUserName 	:= _cUserOri
		_lDelTemp	:= .T.
	EndIf

	//Apagar reservas do Item para gerar novamente
	If !( AllTrim(CEMPANT) $ "07" )

		ConOut("FRRT02EX => thread: "+AllTrim(Str(ThreadId()))+", PEDIDO: "+_cPedido+", Data: "+DTOC(dDataBase)+" Hora: "+Time()+" - Excluindo Reserva - NOT LM.")
		U_FRRT02XR(_cPedido, _cItem, _cEmpOri, _cUserName, _cMotExc, _lDelTemp, _lDelOP)
	ElseIf (AllTrim(cEmpAnt) == '07' .And. AllTrim(cFilAnt) == '05' )

		ConOut("FRRT02EX => thread: "+AllTrim(Str(ThreadId()))+", PEDIDO: "+_cPedido+", Data: "+DTOC(dDataBase)+" Hora: "+Time()+" - Excluindo Reserva - LM => FILAL 05.")
		U_FRRT02XR(_cPedido, _cItem, _cEmpOri, _cUserName, _cMotExc, _lDelTemp, _lDelOP)

	Else

		ConOut("FRRT02EX => thread: "+AllTrim(Str(ThreadId()))+", PEDIDO: "+_cPedido+", Data: "+DTOC(dDataBase)+" Hora: "+Time()+" - Excluindo Reserva - LM.")
		If Empty(_cProduto) .And. Type("n") <> "U"
			_cProduto := Gdfieldget("C6_PRODUTO",n)
		EndIf

		If !Empty(_cPedido)

			SC6->(DbSetOrder(1))
			If SC6->(DbSeek(XFilial("SC6")+_cPedido+AllTrim(_cItem)))

				_cEmpEst := SC6->C6_YEMPPED

				If Empty(_cProduto)
					_cProduto := SC6->C6_PRODUTO
				EndIf

			EndIf

		EndIf

		SB1->(DbSetOrder(1))

		IF SB1->(DbSeek(XFilial("SB1")+_cProduto)) .And. !Empty(SB1->B1_YEMPEST)

			nLinhaEmp := SB1->B1_YEMPEST

			IF !Empty(_cEmpEst)

				nLinhaEmp := _cEmpEst+"01"

			ENDIF

			U_FROPCPRO(SubStr(nLinhaEmp,1,2),SubStr(nLinhaEmp,3,2),"U_FRRT02XR", _cPedido, _cItem, AllTrim(CEMPANT)+AllTrim(CFILANT), _cUserName, _cMotExc, _lDelTemp, _lDelOP)

		Else

			U_FROPMSG(TIT_MSG, 	"Não foi possível definir a EMPRESA DE FABRICAÇÃO. Contate o setor Comercial.",,,"CONFIGURAÇÃO DO FORMATO")

		EndIf

	EndIf

	RestArea(_aAreaSC6)
	RestArea(_aAreaSB1)
	RestArea(_aAreaZZ7)
Return

User Function FRRT02XR(_cPedido, _cItem, _cEmpOri, _cUserName, _cMotExc, _lDelTemp, _lDelOP)

	Default _cItem := ""
	Default _cEmpOri := ""
	Default _cUserName := CUSERNAME
	Default _cMotExc := ""
	Default _lDelTemp := .F.
	Default _lDelOP := .T.

	//Apagar reservas do Item para gerar novamente
	//SE ESTA DIGITANDO PEDIDO - RESERVA TEMPORARIA - APAGAR PELA CHAVE GRAVADA NO CAMPO USUARIO
	If _lDelTemp

		SC0->(DbSetOrder(5))
		If SC0->(DbSeek(XFilial("SC0")+_cUserName))
			While !SC0->(Eof()) .And. AllTrim(SC0->(C0_FILIAL+C0_SOLICIT)) == AllTrim((XFilial("SC0")+_cUserName))

				//Deleta reservas temporarias e do mesmo item caso seja delecao de linha especifica
				If SC0->C0_YTEMP == "S" .And.  (Empty(_cItem) .Or. _cItem == IIF(Empty(_cEmpOri), SC0->C0_YITEMPV, SubStr(SC0->C0_YPITORI,7,2)))

					U_GravaPZ2(SC0->(RecNo()),"SC0",SC0->(C0_FILIAL+C0_NUM+C0_PRODUTO),"R02XR_TEMP",AllTrim(FunName()),_cMotExc, _cUserName)

					__cChaveSDC := SC0->(C0_FILIAL+C0_PRODUTO+C0_LOCAL+'SC0'+C0_NUM)

					a430Reserv({3,"VD","",_cUserName,XFilial("SC0")},;
						SC0->C0_NUM,;
						SC0->C0_PRODUTO,;
						SC0->C0_LOCAL,;
						SC0->C0_QUANT,;
						{	SC0->C0_NUMLOTE,;
						SC0->C0_LOTECTL,;
						SC0->C0_LOCALIZ,;
						SC0->C0_NUMSERI})

					//Checkagem se SDC existe - problema
					U_FRCHKSDC(__cChaveSDC, _cUserName)

				EndIf

				SC0->(DbSkip())
			EndDo
		EndIf

		//Reservas de OP
		If _lDelOP
			PZ0->(DbSetOrder(4))
			If PZ0->(DbSeek(XFilial("PZ0")+_cUserName))
				While !PZ0->(Eof()) .And. AllTrim(PZ0->(PZ0_FILIAL+PZ0_USUINC)) == AllTrim((XFilial("PZ0")+_cUserName))

					//Deleta reservas temporarias e do mesmo item caso seja delecao de linha especifica
					If PZ0->PZ0_STATUS == "T" .And.  (Empty(_cItem) .Or. _cItem == PZ0->PZ0_ITEMPV)

						U_GravaPZ2(PZ0->(RecNo()),"PZ0",PZ0->(PZ0_FILIAL+PZ0_PEDIDO+PZ0_ITEMPV),"R02XR_TEMP",AllTrim(FunName()),_cMotExc, _cUserName)

						RecLock("PZ0",.F.)
						PZ0->(DbDelete())
						PZ0->(MsUnlock())

					EndIf

					PZ0->(DbSkip())
				EndDo
			EndIf
		EndIf

		//SE ESTA APAGANDO RESERVAS PELA TELA - RESERVAS EFETIVADAS NO PEDIDO
		//NAO DEVE APAGAR PELA LM
	Else

		SC0->(DbOrderNickName("PEDIDO"))
		If SC0->(DbSeek(XFilial("SC0")+_cPedido+AllTrim(_cItem)))
			While !SC0->(Eof()) .And. SC0->(C0_FILIAL+C0_YPEDIDO+IIF(!Empty(_cItem),C0_YITEMPV,"")) == (XFilial("SC0")+_cPedido+AllTrim(_cItem))

				ConOut("FRRT02XR => thread: "+AllTrim(Str(ThreadId()))+", PEDIDO: "+_cPedido+", Data: "+DTOC(dDataBase)+" Hora: "+Time()+" - Excluindo Reserva - Processamento.")

				//Marcar o item como NAO RESERVADO
				SC6->(DbSetOrder(1))
				If SC6->(DbSeek(XFilial("SC6")+SC0->C0_YPEDIDO+SC0->C0_YITEMPV))
					RecLock("SC6",.F.)
					SC6->C6_YTPEST := "N"
					SC6->(MsUnlock())
				EndIf

				U_GravaPZ2(SC0->(RecNo()),"SC0",SC0->(C0_FILIAL+C0_NUM+C0_PRODUTO),"R02XR_PERM",AllTrim(FunName()),_cMotExc, _cUserName)

				__cChaveSDC := SC0->(C0_FILIAL+C0_PRODUTO+C0_LOCAL+'SC0'+C0_NUM)

				a430Reserv({3,"VD","",_cUserName,XFilial("SC0")},;
					SC0->C0_NUM,;
					SC0->C0_PRODUTO,;
					SC0->C0_LOCAL,;
					SC0->C0_QUANT,;
					{	SC0->C0_NUMLOTE,;
					SC0->C0_LOTECTL,;
					SC0->C0_LOCALIZ,;
					SC0->C0_NUMSERI})

				U_FRCHKSDC(__cChaveSDC, _cUserName)

				SC0->(DbSkip())
			EndDo
		EndIf

		//Apagar reservas de OP se existir - reservas definitivas pelo pedido
		If _lDelOP
			PZ0->(DbSetOrder(2))
			If PZ0->(DbSeek(XFilial("PZ0")+_cPedido+AllTrim(_cItem)))
				While !PZ0->(Eof()) .And. AllTrim(PZ0->(PZ0_FILIAL+PZ0_PEDIDO+PZ0_ITEMPV)) == (XFilial("PZ0")+_cPedido+AllTrim(_cItem))

					//Marcar o item como NAO RESERVADO
					SC6->(DbSetOrder(1))
					If SC6->(DbSeek(XFilial("SC6")+PZ0->PZ0_PEDIDO+PZ0->PZ0_ITEMPV))
						RecLock("SC6",.F.)
						SC6->C6_YTPEST := "N"
						SC6->(MsUnlock())
					EndIf

					U_GravaPZ2(PZ0->(RecNo()),"PZ0",PZ0->(PZ0_FILIAL+PZ0_PEDIDO+PZ0_ITEMPV),"R02XR_PERM",AllTrim(FunName()),_cMotExc, _cUserName)

					RecLock("PZ0",.F.)
					PZ0->(DbDelete())
					PZ0->(MsUnlock())

					PZ0->(DbSkip())
				EndDo
			EndIf
		EndIf

	EndIf

Return

//Funcao para gerar reserva do saldo pendente apos liberacao de SC9
User Function FRRT02C9(_cPedido)
	Local cAreaC6 := SC6->(GetArea())
	Local cAreaC9 := SC9->(GetArea())
	Local cAreaC5 := SC5->(GetArea())
	Local cAliasTmp
	Local __aRetRes
	Local __aListRes
	Local __cLocAmo := AllTrim(GetNewPar("FA_LOCAMO","05"))

	//Gravacao de campos de controle de arremate de lote
	If SC9->(FieldPos("C9_YARELOT")) > 0 .And. SC9->(FieldPos("C9_YLOTTOT")) > 0 .And. !(SC9->C9_LOCAL == __cLocAmo)

		SC9->(DbSetOrder(1))
		If SC9->(DbSeek(XFilial("SC9")+_cPedido))

			While !SC9->(Eof()) .And. SC9->(C9_FILIAL+C9_PEDIDO) ==  (XFilial("SC9")+_cPedido)

				If !Empty(SC9->C9_BLEST) .Or. !Empty(SC9->C9_BLCRED) .Or. Empty(SC9->C9_LOTECTL) .Or. (SC9->C9_DATALIB < dDataBase)
					SC9->(DbSkip())
					loop
				EndIf

				If Empty(SC9->C9_YARELOT) .And. ( AllTrim(cEmpAnt) $ "01_05_13" )
					U_FR2C9LOT()
				EndIf

				SC9->(DbSkip())
			EndDo

		EndIf
	EndIf

	//Geração automatica de reservas
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(XFilial("SC6")+_cPedido))

		SC5->(DbSetOrder(1))
		SC5->(DbSeek(SC6->(C6_FILIAL+C6_NUM)))

		While !SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == (XFilial("SC6")+_cPedido)

			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				%NOPARSER%

				select SALDO = C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from %Table:SC9% SC9 where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.%NotDel%),0)
				from %Table:SC6% SC6 where C6_FILIAL = %XFILIAL:SC6% and C6_NUM = %EXP:SC6->C6_NUM% and C6_ITEM = %EXP:SC6->C6_ITEM% and SC6.%NotDel%

			EndSql

			If !(cAliasTmp)->(Eof())

				//Fernando em 06/04/2015 - so entrar no metodo que exclui e gera novamente se nao haver reserva para o pedido/item
				__aListRes := U_FRTE02LO("", SC6->C6_NUM, SC6->C6_ITEM, "", "")

				//Fernando/Facile - Projeto Reserva - Itens com reserva de estoque - se tiver saldo pendente reservar novamente
				If (cAliasTmp)->SALDO > 0

					//Se tem reserva de OP - nao foi excluida no M440VLD - reservar a mesma OP - Fernando/Facile em 27/04/2015 - lista comercial
					If Len(__aListRes) > 0 .And. AllTrim(__aListRes[1][1]) == "OP" .And. Alltrim(SC6->C6_BLQ) <> "R"

						PZ0->(DbSetOrder(2))
						If PZ0->(DbSeek(XFilial("PZ0")+SC6->(C6_NUM+C6_ITEM))) .And. ( PZ0->PZ0_QUANT <> (cAliasTmp)->SALDO )

							//log de atendimento de op direto para empenho
							U_GravaPZ2(PZ0->(RecNo()),"PZ0",AllTrim(Str(PZ0->PZ0_QUANT)),"ATEPED",AllTrim(FunName()),"ATP", CUSERNAME)

							//ajustar a reserva de OP existente para ficar com o saldo remanescente do item liberado parcial
							RecLock("PZ0",.F.)
							PZ0->PZ0_QUANT := (cAliasTmp)->SALDO
							PZ0->(MsUnlock())

						EndIf

					ElseIf Len(__aListRes) <= 0 .And. !Empty(SC6->C6_LOTECTL) .And. Alltrim(SC6->C6_BLQ) <> "R"

						__aRetRes := U_FROPRT02(SC6->C6_NUM, SC6->C6_ITEM, SC6->C6_PRODUTO, SC6->C6_LOCAL, (cAliasTmp)->SALDO, SC5->C5_VEND1, SC6->C6_LOTECTL, .T., "LC9")
						If __aRetRes[1] > 0
							U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP","Não foi possível criar reserva para o pedido: "+SC6->C6_NUM+" item "+SC6->C6_ITEM+"."+CRLF+"Verifique a quantidade e saldo disponível")
						Else

							//fernando em 06/04/15 - conseguir gerar a reserva de estoque - marca flag que pode estar diferente
							RecLock("SC6",.F.)
							SC6->C6_YTPEST := "E"
							SC6->(MsUnlock())

						EndIf

					EndIf

					//se nao tiver saldo pendente - liberacao total
				Else

					//log de atendimento de op direto para empenho
					PZ0->(DbSetOrder(2))
					If Len(__aListRes) > 0 .And. AllTrim(__aListRes[1][1]) == "OP" .And. PZ0->(DbSeek(XFilial("PZ0")+SC6->(C6_NUM+C6_ITEM)))
						U_GravaPZ2(PZ0->(RecNo()),"PZ0",AllTrim(Str(PZ0->PZ0_QUANT)),"ATEPED",AllTrim(FunName()),"ATP", CUSERNAME)
					EndIf

					//Fernando/Facile em 30/04/15 - forcar apagar reserva se ainda tiver - se for OP nao eh apagada no M440VLD
					U_FRRT02EX(SC6->C6_NUM, SC6->C6_ITEM,Nil,"LIB")

					//Fernando/Facile em 13/02/2015 - Se nao haver saldo pendente para liberacao - marcar campo tipo de estoque como Empenhado
					RecLock("SC6",.F.)
					SC6->C6_YTPEST := "P"
					SC6->(MsUnlock())

				EndIf

			EndIf

			SC6->(DbSkip())
		EndDo

	EndIf

	RestArea(cAreaC6)
	RestArea(cAreaC9)
	RestArea(cAreaC5)
Return

User Function GETOPPED(_cPedido, _cItem)

	Local cAliasTrab	:= Nil
	Local cQuery		:= ""
	Local aRet			:= {"", "", "", "", ""}

	cQuery := " select * from "+RetSQLName("PZ0")+"						"
	cQuery += " where 1=1							 					"
	cQuery += " AND PZ0_FILIAL 		= '"+xFilial('PZ0')+"' 				"
	cQuery += "	AND PZ0_PEDIDO 		= '"+_cPedido+"' 					"
	cQuery += "	AND PZ0_ITEMPV 		= '"+_cItem+"' 						"
	cQuery += "	AND PZ0_STATUS 		= 'P'								"
	cQuery += "	AND D_E_L_E_T_ 		= ''			 					"
	cQuery += "	ORDER BY R_E_C_N_O_ DESC								"

	cAliasTrab := GetNextAlias()
	TCQUERY cQuery ALIAS (cAliasTrab) NEW

	If !(cAliasTrab)->(Eof())

		aRet	:= {;
			(cAliasTrab)->PZ0_FILIAL,;
			(cAliasTrab)->PZ0_OPNUM,;
			(cAliasTrab)->PZ0_OPITEM,;
			(cAliasTrab)->PZ0_OPSEQ,;
			(cAliasTrab)->PZ0_DATENT;
			}

	EndIf
	(cAliasTrab)->(DbCloseArea())

Return aRet

User Function REFAZPZ0(_cPedido, _cItem, _cFilOp, _cNumOp, _cItemOp, _cSeqOp, _cDataEnt)

	Local cAreaC6 		:= SC6->(GetArea())
	Local cAliasTmp		:= Nil

	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(XFilial("SC6")+_cPedido+_cItem))

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			%NOPARSER%

			select SALDO = C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from %Table:SC9% SC9 where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.%NotDel%),0)
			from %Table:SC6% SC6 where C6_FILIAL = %XFILIAL:SC6% and C6_NUM = %EXP:SC6->C6_NUM% and C6_ITEM = %EXP:SC6->C6_ITEM% and SC6.%NotDel%

		EndSql

		If !(cAliasTmp)->(Eof()) .And. (cAliasTmp)->SALDO > 0

			__aListRes := U_FRTE02LO("", SC6->C6_NUM, SC6->C6_ITEM, "", "")

			If Len(__aListRes) <= 0 .And. Alltrim(SC6->C6_BLQ) <> "R"

				__nSaldoOp	:= U_FRSALDOP(cEmpAnt, _cFilOp, _cNumOp, _cItemOp, _cSeqOp, '', '')

				If .T.//(__nSaldoOp > 0 .And. (__nSaldoOp - (cAliasTmp)->SALDO) >= 0 )

					RecLock("PZ0",.T.)
					PZ0->PZ0_FILIAL	:= XFilial("PZ0")
					PZ0->PZ0_OPNUM 	:= _cNumOp
					PZ0->PZ0_OPITEM := _cItemOp
					PZ0->PZ0_OPSEQ 	:= _cSeqOp
					PZ0->PZ0_CODPRO := SC6->C6_PRODUTO
					PZ0->PZ0_PEDIDO := SC6->C6_NUM
					PZ0->PZ0_ITEMPV := SC6->C6_ITEM
					PZ0->PZ0_QUANT 	:= (cAliasTmp)->SALDO
					PZ0->PZ0_USUINC := CUSERNAME
					PZ0->PZ0_DATINC := Date()
					PZ0->PZ0_HORINC := SubStr(Time(),1,5)
					PZ0->PZ0_DATENT := stod(_cDataEnt)
					PZ0->PZ0_STATUS := 'P'
					PZ0->(MsUnlock())

					RecLock("SC6",.F.)
					SC6->C6_YTPEST := "R"
					SC6->(MsUnlock())

				EndIf

			EndIf
		EndIf
		(cAliasTmp)->(DbCloseArea())
	EndIf

	RestArea(cAreaC6)
Return


//Grava os campos de arremate de lote ao gerar novo SC9
User Function FR2C9LOT()
	Local cAliasAux
	Local _aRet

	//Empresas - Vitcer nao usa
	If AllTrim(CEMPANT) == "14"
		Return
	EndIf

	RecLock("SC9",.F.)

	IF !(AllTrim(FunName()) == "BIAEC001")

		_aRet := U_FR2CHKPT(SC9->C9_PRODUTO, SC9->C9_LOTECTL, SC9->C9_QTDLIB, .T., SC9->C9_PEDIDO, SC9->C9_ITEM, SC9->C9_SEQUEN)

		//Arremate
		If (_aRet[2] <= 0)
			SC9->C9_YARELOT := "S"
			SC9->C9_YLOTTOT := _aRet[2]
		Else
			//Ponta
			If (_aRet[1] == "P")
				U_GravaPZ2(SC9->(RecNo()),"SC9",AllTrim(ProcName()),"PONTA",AllTrim(FunName()),"PNT", CUSERNAME)
				SC9->C9_YARELOT := "P"
				SC9->C9_YLOTTOT := _aRet[2]
			Else
				SC9->C9_YARELOT := "N"
				SC9->C9_YLOTTOT := _aRet[2]
			EndIf
		EndIf
	ELSE
		SC9->C9_YARELOT := "C"  //liberacoes na montagem de carga - nao considerar como ponta
		SC9->C9_YLOTTOT := 0
	ENDIF

	SC9->(MsUnlock())

Return

//Checkar se pedido e ponta ou arremate e retornar os dados
User Function FR2CHKPT(_cProduto, _cLote, _nQtde, _lReserva, _cPedido, _cItemPV, _cSeqSC9, _CodEmp, _CodFil)

	Local cSQL   := ""
	Local _marca := ""
	Local aRet := {}

	Default _lReserva	:= .F.
	Default _cPedido	:= ""
	Default _cItemPV	:= ""
	Default _cSeqSC9	:= ""
	Default _CodEmp		:= CEMPANT
	Default _CodFil		:= CFILANT

	aRet := { "N", 0 }

	//produtos da marca Vinílico não devem ser retidos por esta trava.
	_marca := U_CHECKMAR(_cProduto)

	If ( _CodEmp == "07" .Or. _CodEmp == "06" .Or. _marca == "1302")
		Return aRet
	EndIf



	If Select("QRYFR2") > 0
		QRYFR2->(DbCloseArea())
	EndIf

	//Retorto {  Tipo: S = Arremate, P = Ponta, N = Normal;  Saldo do Lote }
	cSQL := "select * from dbo.FNC_ROP_CONSULTA_PONTA_ARREMATE_"+AllTrim(_CodEmp)+"('"+AllTrim(_CodFil)+"','"+_cProduto+"','"+_cLote+"',"+AllTrim(Str(_nQtde))+",'"+_cPedido+"','"+_cItemPV+"','"+_cSeqSC9+"')"

	TCQUERY CSQL ALIAS "QRYFR2" NEW

	If !QRYFR2->(Eof())
		aRet := { QRYFR2->TIPO , QRYFR2->SALDO_RES }
	EndIf
	QRYFR2->(DbCloseArea())

Return aRet

//Buscar a marca do produto.
User Function CHECKMAR(_cProduto)
	Local cSQLMARC
	Local _marca      := ""

	cSQLMARC := "select ZZ7_EMP																			"
	cSQLMARC += " FROM SB1010 with (nolock) INNER JOIN ZZ7010 ON B1_YLINHA = ZZ7_COD AND B1_YLINSEQ = ZZ7_LINSEQ		"
	cSQLMARC += " WHERE B1_COD = '" + _cProduto + "' AND SB1010.D_E_L_E_T_ = '' AND ZZ7010.D_E_L_E_T_ = ''	"

	If Select("QRYMARCA") > 0
		QRYMARCA->(DbCloseArea())
	EndIf

	TCQUERY cSQLMARC ALIAS "QRYMARCA" NEW

	If !QRYMARCA->(Eof())
		_marca := QRYMARCA->ZZ7_EMP
	EndIf
	QRYMARCA->(DbCloseArea())

return _marca

//Checkar ponta apos estorno de liberacao de pedido
User Function FR2CPTEX(_cProduto, _cLote, _nQtde, _cPedido, _cItemPV, _cSeqSC9)
	Local cAliasAux
	Local _nQtPalete := 0
	Local _nSaldo := 0
	Local cSQL
	Local aRet := { "N", _nSaldo }

	cSQL := "select * from dbo.FNC_ROP_CONSULTA_PONTA_ESTORNO_"+AllTrim(CEMPANT)+"('"+AllTrim(CFILANT)+"','"+_cProduto+"','"+_cLote+"',"+AllTrim(Str(_nQtde))+",'"+_cPedido+"','"+_cItemPV+"','"+_cSeqSC9+"')"

	If Select("QRYFR2") > 0
		QRYFR2->(DbCloseArea())
	EndIf

	TCQUERY CSQL ALIAS "QRYFR2" NEW

	aRet := { "N", 0 }
	If !QRYFR2->(Eof())
		aRet := { QRYFR2->TIPO , QRYFR2->SALDO_RES }
	EndIf
	QRYFR2->(DbCloseArea())

Return aRet

//retornar saldo produto ou lote via SQL
User Function FROPSAL(_cProduto,_cLocal,_cLoteSel)
	Local cAliasAux := GetNextAlias()
	Local  cSQL
	Local cExpLote := ""
	Local nSaldo := 0

	Default _cLoteSel := ""

	If !Empty(_cLoteSel)
		cExpLote := " AND BF_LOTECTL = '"+_cLoteSel+"' "
	EndIf

	cSQL := "SELECT SALDO = SUM(BF_QUANT-BF_EMPENHO) FROM "+RetSQLName("SBF010")+" WITH (NOLOCK) WHERE BF_PRODUTO = '"+_cProduto+"' AND BF_LOCAL = '"+_cLocal+"' "+cExpLote+" AND  (BF_QUANT-BF_EMPENHO) > 0  AND D_E_L_E_T_ =''"

	TCQUERY cSQL ALIAS (cAliasAux) NEW

	If !(cAliasAux)->(Eof())
		nSaldo := (cAliasAux)->SALDO
	EndIf

	(cAliasAux)->(DbCloseArea())
Return(nSaldo)

//chechagem de problema com SDC ficaar na base apos apagar reserva
User Function FRCHKSDC(_ChaveDC1, _cUserName)

	//_ChaveDC1 := DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO

	SDC->(DbSetOrder(1))
	If SDC->(DbSeek(_ChaveDC1))
		U_GravaPZ2(SDC->(RecNo()),"SDC",AllTrim(ProcName()),"SDC_ERRO",AllTrim(FunName()),"SDC", _cUserName)
		U_BIAEnvMail(, "fernando@facilesistemas.com.br;suporte.ti@biancogres.com.br", "ERRO - SDC NAO EXCLUIDO", "SDC - RECNO: "+AllTrim(Str(SDC->(RecNo())))+" não excluido apos exclusao da reserva.")
	EndIf

Return

//Fernando/Facile em 01/09/2015 - OS 3249-15
//Alterar validade de Reservas para pedidos Antecipados - em funcao do vencimento
User Function FR2VLRES(_cPedido)

	Local aAreaC5 := SC5->(GetArea())
	Local oRecAnt := TRecebimentoAntecipado():New()
	Local cDtVenTit := ""
	Local cAliasTmp
	Local cEmpFab

	SC5->(DbSetOrder(1))

	If SC5->(DbSeek(XFilial("SC5")+_cPedido))

		IF !U_fValidaRA(SC5->C5_CONDPAG)
			Return
		ENDIF

		If AllTrim(cEmpAnt) == "07"

			//procura venc. do titulo na LM
			cDtVenTit := oRecAnt:RetDtVenTit(_cPedido)

			If !Empty(cDtVenTit)

				//Projeto PBI - considerar empresa de origem conforme pedido
				cEmpFab := SC5->C5_YEMPPED

				//atualizar reservas na empresa origem do pedido
				U_FR2VLRE1(_cPedido, cDtVenTit, cEmpFab)

			EndIf

		Else

			//Se for LM -> procura venc. do titulo na LM
			if SC5->C5_CLIENTE == "010064"
				cDtVenTit := oRecAnt:RetDtVenTit(_cPedido,"07")
			else
				cDtVenTit := oRecAnt:RetDtVenTit(_cPedido)
			endIf

			If !Empty(cDtVenTit)
				//atualizar reservas na empresa atual
				U_FR2VLRE1(_cPedido, cDtVenTit)
			EndIf

		EndIf

	EndIf

	RestArea(aAreaC5)

Return

User Function FR2VLRE1(_cPedido, cDtVenTit, cEmpOri)

	Local _cUserName := ""
	Local cSQL
	Local cSC0 := RetSQLName("SC0")

	Default cDtVenTit := ""
	Default cEmpOri := ""

	If !Empty(cEmpOri)
		cSC0 := "SC0"+AllTrim(cEmpOri)+"0"
	EndIf

	If !Empty(cDtVenTit)

		If Type("_FROPCHVTEMPRES") <> "U" .And. !Empty(_FROPCHVTEMPRES)
			_cUserName 	:= _FROPCHVTEMPRES
		EndIf

		If Empty(_cUserName)

			If Empty(cEmpOri)

				cSQL :=	" UPDATE "+ cSC0
				cSQL += " SET C0_VALIDA = '"+DTOS( STOD(cDtVenTit) + 10 )+"' "
				cSQL += " WHERE C0_FILIAL = '01' "
				cSQL += " AND C0_YPEDIDO = '"+_cPedido+"' "
				cSQL += " AND C0_YTEMP = 'N' "
				cSQL += " AND D_E_L_E_T_=' ' "

				//LM
			Else

				cSQL :=	" UPDATE "+ cSC0
				cSQL += " SET C0_VALIDA = '"+DTOS( STOD(cDtVenTit) + 10 )+"' "
				cSQL += " WHERE C0_FILIAL = '01' "
				cSQL += " AND substring(C0_YPITORI,1,6) = '"+_cPedido+"' "
				cSQL += " AND C0_YTEMP = 'N' "
				cSQL += " AND D_E_L_E_T_=' ' "

			EndIf

		Else

			cSQL :=	" UPDATE "+ cSC0
			cSQL += " SET C0_VALIDA = '"+DTOS( STOD(cDtVenTit) + 10 )+"' "
			cSQL += " WHERE C0_FILIAL = '01' "
			cSQL += " AND C0_SOLICIT = '"+_cUserName+"' "
			cSQL += " AND C0_YTEMP = 'S' "
			cSQL += " AND D_E_L_E_T_=' ' "

		EndIf

		TcSQLExec(cSQL)

	EndIf

Return
