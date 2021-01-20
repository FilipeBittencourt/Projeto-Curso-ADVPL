#include "PROTHEUS.CH"
#include "TOPCONN.CH"

#DEFINE TIT_MSG "SISTEMA - RESERVA DE ESTOQUE/OP"

Static __FRT04ALTDT

/*/{Protheus.doc} FROPRT04
@description Gerar reserva temporaria PZ0 no LIOK do pedido de venda
@author Fernando Rocha
@since 25/07/2014
@version undefined
@param _cPedido, , descricao
@param _cItem, , descricao
@param _cProduto, , descricao
@param _nQuant, , descricao
@param _cSegmento, , descricao
@param _dDataNece, , descricao
@param _cOPDoc, , descricao
@type function
/*/
User Function FROPRT04(_cPedido, _cItem, _cProduto, _nQuant, _cSegmento, _dDataNece, _cOPDoc, _cEmpEst)
	Local aArea := GetArea()
	Local aRet
	Local nLinhaEmp
	Local _cUserName := CUSERNAME

	Default _cOPDoc := ""
	Default _cEmpEst := ""

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+_cProduto))

	If Type("_FROPCHVTEMPRES") <> "U" .And. !Empty(_FROPCHVTEMPRES)
		_cUserName := _FROPCHVTEMPRES
	EndIf

	If !(AllTrim(CEMPANT) $ "07#14") .OR. (SB1->B1_TIPO == "PR")

		aRet := U_FRT04PRC(_cPedido, _cItem, _cProduto, _nQuant, _cSegmento, _dDataNece, _cUserName, _cOPDoc)

	Else

		SB1->(DbSetOrder(1))
		IF SB1->(DbSeek(XFilial("SB1")+_cProduto)) .And. !Empty(SB1->B1_YEMPEST)

			If Alltrim(FunName()) == "MATA410" .And. !Empty(_cEmpEst)

				nLinhaEmp := _cEmpEst+"01"

			Else

				nLinhaEmp := SB1->B1_YEMPEST

			EndIf
			
			aRet := U_FROPCPRO(SubStr(nLinhaEmp,1,2),SubStr(nLinhaEmp,3,2),"U_FRT04PRC", _cPedido, _cItem, _cProduto, _nQuant, _cSegmento, _dDataNece, _cUserName, _cOPDoc, AllTrim(CEMPANT)+AllTrim(CFILANT))

		Else

			U_FROPMSG(TIT_MSG, 	"Formato sem EMPRESA DE FABRICAÇÃO cadastrada. Verifique.",,,"CONFIGURAÇÃO DO FORMATO")
			aRet := {.F.,"Formato sem EMPRESA DE FABRICAÇÃO cadastrada. Verifique."}

		EndIf

	EndIf

	RestArea(aArea)
Return(aRet)

User Function FRT04PRC(_cPedido, _cItem, _cProduto, _nQuant, _cSegmento, _dDataNece, _cUserName, _cOPDoc, _cEmpOri)

	Local cSQL
	Local aRet
	Local _aRetOP

	Default _cSegmento := "R"  
	Default _dDataNece := CTOD(" ")
	Default _cUserName := ""
	Default _cOPDoc := ""
	Default _cEmpOri := ""

	aRet := {.F.,""}

	//Apagar reservas do Item para gerar novamente
	U_FRRT02EX(_cPedido, _cItem, _cProduto, "LK4", _cEmpOri, _cUserName)
	//FRRT02EX(_cPedido, _cItem, _cProduto, _cMotExc, _cEmpOri, _cUserOri, _lDelOP)

	//Pesquisar a OP para inclusao
	If (_cSegmento == "E")

		//fernando - parametro novo para pedido base Vitcer - se estiver preenchido nao pesquisa Op, faz reserva na OP ja selecionada no pedido
		If Empty(_cOPDoc)

			//engenharia regra pela dt de necessidade
			_aRetOP := U_FRRT04PO(_cPedido, _cItem, _cProduto, _nQuant, 'N', _cSegmento, _dDataNece)

			//nao achou - regra geral da revenda
			If _aRetOP[1] == Nil
				_aRetOP := U_FRRT04PO(_cPedido, _cItem, _cProduto, _nQuant)
			EndIf

		Else

			SC2->(DbSetOrder(1))
			If SC2->(DbSeek(XFilial("SC2")+_cOPDoc))

				_aRetOP 	:= Array(8)

				_aRetOP[1]	:= SubStr(_cOPDoc, 1, 6)
				_aRetOP[2]	:= SubStr(_cOPDoc, 7, 2)
				_aRetOP[3]	:= SubStr(_cOPDoc, 9, 3)
				_aRetOP[4]	:= SC2->C2_YDTDISP
				_aRetOP[5]	:= 0
				_aRetOP[6]	:= _cProduto
				_aRetOP[7]	:= AllTrim(CEMPANT)
				_aRetOP[8]	:= SC2->C2_LOCAL

			EndIf

		EndIf

	Else
		//revenda
		_aRetOP := U_FRRT04PO(_cPedido, _cItem, _cProduto, _nQuant)
	EndIf

	If _aRetOP[1] <> Nil

		RecLock("PZ0",.T.)
		PZ0->PZ0_FILIAL := XFilial("PZ0")
		PZ0->PZ0_OPNUM := _aRetOP[1]
		PZ0->PZ0_OPITEM := _aRetOP[2]
		PZ0->PZ0_OPSEQ := _aRetOP[3]
		PZ0->PZ0_CODPRO := _cProduto
		PZ0->PZ0_PEDIDO := _cPedido
		PZ0->PZ0_ITEMPV := _cItem
		PZ0->PZ0_QUANT := _nQuant
		PZ0->PZ0_USUINC := _cUserName
		PZ0->PZ0_DATINC := Date()
		PZ0->PZ0_HORINC := SubStr(Time(),1,5)
		PZ0->PZ0_DATENT := _aRetOP[4] 
		PZ0->PZ0_STATUS := 'T'
		PZ0->(MsUnlock()) 

		aRet[1] := .T.
		aRet[2] := ""

	Else

		aRet[1] := .F.
		aRet[2] := "Não foi possível localizar OP disponível para reserva com os parâmetros informados"

	EndIf

return(aRet)

/*/{Protheus.doc} FRRT04PO
@description Funcao para pesquisar se existe OP disponivel
/*/
User Function FRRT04PO(_cPedido, _cItem, _cProduto, _nQuant, _cTodas, _cSegmento, _dDataNece, _cFormato, _cLinha, _cClasse, _cEmpOP )
	Local cSQL
	Local aRET
	Local _aAux

	Default _cTodas 	:= 'N'
	Default _cSegmento 	:= 'R'
	Default _dDataNece 	:= CTOD(" ")
	Default _cFormato 	:= ""
	Default _cLinha 	:= ""
	Default _cClasse 	:= ""
	Default _cEmpOP 	:= cEmpAnt

	cSQL := "select * from dbo.FNC_ROP_PESQUISA_OP_"+AllTrim(_cEmpOP)+"('01','"+DTOS(dDataBase)+"','"+DTOS(_dDataNece)+"','"+_cPedido+"','"+_cItem+"','"+_cProduto+"','"+_cSegmento+"',"+AllTrim(Str(_nQuant))+",'"+_cTodas+"','"+_cFormato+"','"+_cLinha+"','"+_cClasse+"')"

	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	TCQUERY CSQL ALIAS "QRY" NEW

	If !QRY->(Eof())

		If _cTodas == "N"

			aRET := Array(8)

			aRET[1] := QRY->OPNUM
			aRET[2] := QRY->OPITEM
			aRET[3] := QRY->OPSEQ
			aRET[4] := STOD(QRY->DATADISP)
			aRET[5]	:= QRY->SALDO
			aRET[6]	:= QRY->PRODUTO

			If AllTrim(CEMPANT) <> "07"
				aRET[7]	:= AllTrim(_cEmpOP)
				aRET[8]	:= QRY->LOCEST
			Else
				aRET[7]	:= QRY->EMPORI
				aRET[8]	:= QRY->LOCEST
			EndIf

		Else

			aRET := {}

			While !QRY->(Eof())

				_aAux := {}
				aAdd(_aAux,QRY->OPNUM)
				aAdd(_aAux,QRY->OPITEM)
				aAdd(_aAux,QRY->OPSEQ)
				aAdd(_aAux,STOD(QRY->DATADISP))
				aAdd(_aAux,QRY->SALDO)
				aAdd(_aAux,QRY->PRODUTO)

				If AllTrim(CEMPANT) <> "07"
					aAdd(_aAux,AllTrim(_cEmpOP))
					aAdd(_aAux,QRY->LOCEST)
				Else
					aAdd(_aAux,QRY->EMPORI)
					aAdd(_aAux,QRY->LOCEST)
				EndIf

				aAdd(aRET,_aAux)

				QRY->(DbSkip())
			EndDo

		EndIf

	Else
		If _cTodas == "N"
			aRET := Array(8)
		Else
			aRET := {}
		EndIf
	EndIf

	QRY->(DbCloseArea())

Return(aRET)

/*/{Protheus.doc} FRRT04VL
@description Funcao para validar as alteracoes em campos/exclusao/alteracao da OP
/*/
User Function FRRT04VL(_cOpDoc)
	Local lRet := .T.
	Local nRet
	Local cOption
	Local aButtons
	Local uAreaAnt := GetArea()
	Local xDtDispo 

	Default _cOpDoc := ""

	If Empty(_cOpDoc)
		If IsInCallStack("U_BIA255") 
			_cOpDoc := GdFieldGet("C2_NUM",oGetDados:oBrowse:nAt)+GdFieldGet("C2_ITEM",oGetDados:oBrowse:nAt)+GdFieldGet("C2_SEQUEN",oGetDados:oBrowse:nAt)	
		Else
			_cOpDoc := M->(C2_NUM+C2_ITEM+C2_SEQUEN)
		EndIf
	EndIf

	xDtDispo := ctod("  /  /  ")
	If IsInCallStack("U_BIA255")
		xDtDispo := GdFieldGet("C2_YDTDISP", oGetDados:oBrowse:nAt)
	Else
		xDtDispo := M->C2_YDTDISP
	EndIf

	If (AllTrim(READVAR()) == "M->C2_DATPRF") .And. (M->C2_DATPRF > xDtDispo)
		nRet := U_FROPMSG(TIT_MSG,	"A data FIM DE PRODUÇÃO está maior que DATA DE DISPONIBILIDADE original."+CRLF+;
		"A alteração será permitida, porém será enviado um e-mail avisando aos representantes sobre a nova previsão de produção.";
		,{"Consulta","Confirma"},,"Alteracao de datas de produção")

		//Se estiver alterando a data de disponibilidade ou Excluindo a OP - somente permitir se excluir as reservas
		If nRet == 1
			U_FROPTE02("", "", "", _cOpDoc, "R")
		EndIf
	EndIf

	RestArea(uAreaAnt)
Return(lRet)

/*/{Protheus.doc} FRRT04AO
@description Apos Alterar OP - PE MTA650A - Alterar as datas de reserva se autorizado
/*/
User Function FRRT04AO(_cChvOp, _dDatPrf, _dDtDisp)

	Local __nPTol := 0

	//Atualiza PZ0 e SC6 se houve alteracao da data de entrega da OP

	SC2->(DbSetOrder(1))
	If SC2->(DbSeek(XFilial("SC2")+_cChvOp))

		//13/3/18 - alteracao para checkar primeiro o cadastro do produto campo novo ticket 3031
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(XFilial("SB1")+SC2->C2_PRODUTO))

			__nPTol := SB1->B1_YPTOL

		EndIf

		ZZ6->(DbSetOrder(1))
		If ZZ6->(DbSeek(XFILIAL("ZZ6")+SUBSTR(SC2->C2_PRODUTO,1,2)))

			__nPTol := ZZ6->ZZ6_PTOL

		EndIf

	EndIf  

	//Alterar sempre - qualquer data diferente da gravada - Fernando em 14/04/15
	If SC2->(DbSeek(XFilial("SC2")+_cChvOp)) .And. (SC2->C2_YDTDISP <> _dDatPrf + __nPTol)

		Begin Transaction  

			SC2->(DbSetOrder(1))
			If SC2->(DbSeek(XFilial("SC2")+_cChvOp))

				//grava log de alteracao da data da op
				U_GravaPZ2(SC2->(RecNo()),"SC2",DTOS(SC2->C2_YDTDISP),"ALTDTDISP",AllTrim(FunName()),"ADT", CUSERNAME)

				//altera data de disponibilidade da op e grava ultima data original
				RecLock("SC2",.F.)
				SC2->C2_YDTDORI := _dDtDisp
				SC2->C2_YDTDISP := _dDatPrf + __nPTol
				SC2->(MsUnlock())

			EndIf     

			PZ0->(DbSetOrder(1))
			If PZ0->(DbSeek(XFilial("PZ0")+_cChvOp))  

				While !PZ0->(Eof()) .And. PZ0->(PZ0_FILIAL+PZ0_OPNUM+PZ0_OPITEM+PZ0_OPSEQ) == (XFilial("PZ0")+_cChvOp)

					//grava log de alteracao da data da reserva de OP
					U_GravaPZ2(PZ0->(RecNo()),"PZ0",DTOS(PZ0->PZ0_DATENT),"ALTDTDISP",AllTrim(FunName()),"ADT", CUSERNAME)

					//altera data da reserva
					RecLock("PZ0",.F.)
					PZ0->PZ0_DATENT := _dDatPrf + __nPTol
					PZ0->(MsUnlock())

					//altera data no item do pedido
					SC6->(DbSetOrder(1))
					If SC6->(DbSeek(XFilial("SC6")+PZ0->(PZ0_PEDIDO+PZ0_ITEMPV)))
						RecLock("SC6",.F.)
						SC6->C6_YDTDISP := _dDatPrf + __nPTol
						SC6->(MsUnlock())              
					EndIf

					PZ0->(DbSkip())
				EndDo

			EndIf

		End Transaction

	EndIf

Return


/*/{Protheus.doc} FGADTDIS
@description GATILHO no campo C2_DATPRF para preencher o C2_YDTDISP
@author Fernando Rocha
@since 20/03/2018
@version 1.0
@obs Ticket 801/3031
/*/
User Function FGADTDIS()

	Local __nPTol		:= 0
	Local _dDatPrf		:= M->C2_DATPRF
	Local _dDataDisp 	:= _dDatPrf
	Local _aAreaB1 		:= SB1->(GetArea())
	Local _aAreaZZ6 	:= ZZ6->(GetArea())

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+M->C2_PRODUTO))

		__nPTol := SB1->B1_YPTOL

	EndIf

	If (__nPTol <= 0 )

		ZZ6->(DbSetOrder(1))
		If ZZ6->(DbSeek(XFILIAL("ZZ6")+SUBSTR(M->C2_PRODUTO,1,2)))
			__nPTol := ZZ6->ZZ6_PTOL
		EndIf

	EndIf

	If ( __nPTol > 0 )

		_dDataDisp := _dDatPrf + __nPTol

	EndIf

	RestArea(_aAreaB1)
	RestArea(_aAreaZZ6)

Return(_dDataDisp)

/*/{Protheus.doc} FRRT04V1
@description Validacoes
/*/
User Function FRRT04V1()
	Local _aArea := GetArea()   

	If (AllTrim(FunName()) == "MATA440") 

		If U_VALOPER("R04",.F.,.F.)
			Return(.T.)
		Else
			U_FROPMSG("OP R04 - "+TIT_MSG, 	"SEGMENTO: ENGENHARIA"+CRLF+;
			"A DATA DE NECESSIDADE so pode ser alterada na liberação pelo GERENTE ADM DE VENDAS.",;
			,,"Alterar Data de Necessidade") 
			Return(.F.)
		EndIf
	EndIf

	If (AllTrim(FunName()) == "MATA410")

		//Verificando Segmento do Cliente
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(XFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
			If AllTrim(SA1->A1_YTPSEG) == "E" .And. !(M->C6_YDTNECE >= U_FROPAD3U(dDataBase))

				U_FROPMSG(TIT_MSG, 	"SEGMENTO: ENGENHARIA"+CRLF+;
				"A DATA DE NECESSIDADE não pode ser para menos que 3 dias úteis.",;
				,,"Informar Data de Necessidade")
				Return(.F.)

			EndIf
			//Thiago Haagensen - Ticket 27599 - Alterar o parâmetro de data máxima de necessidade de engenharia para 180 dias
			//ZZ6_PRZENG
			
			__nPrazoMaximo	:= GetNewPar("FA_PRAZOM", 360)
				
			If AllTrim(SA1->A1_YTPSEG) == "E" .And. ((M->C6_YDTNECE - dDataBase) >__nPrazoMaximo )

				If !U_VALOPER("R04",.F.,.F.)

					U_FROPMSG("OP R04 - "+TIT_MSG, 	"SEGMENTO: ENGENHARIA"+CRLF+;
					"A DATA DE NECESSIDADE não pode ser acima de "+cvaltochar(__nPrazoMaximo)+" dias da data atual.",;
					,,"Informar Data de Necessidade")
					Return(.F.)

				EndIf

			EndIf

		EndIf 

	EndIf

	RestArea(_aArea)
Return(.T.)

/*/{Protheus.doc} FRRT04PP
@description Na distribuicao - faz as reservas de estoque amarradas com a OP
/*/
User Function FRRT04PP(pnLinha,pnQuant,pcLocaliz,pcNumSeri,pcDocNum,pcNumSeq,pcProduto,pcLote,pcLocal)

	Private _nLinha 	:= pnLinha
	Private _nQuant 	:= pnQuant
	Private _cLocaliz	:= pcLocaliz
	Private _cNumSeri	:= pcNumSeri
	Private _cDocNum 	:= pcDocNum
	Private _cNumSeq 	:= pcNumSeq
	Private _cProduto	:= pcProduto
	Private _cLote		:= pcLote
	Private _cLocal		:= pcLocal

	Private _cOpNum 	:= ''
	Private _cVendPed	:= ''
	Private _cPedido	:= ''
	Private _cItemPed	:= ''
	Private _nQuantRes	:= 0
	Private ENTER		:= CHR(13) + CHR(10)

	cSql := " SELECT D3_OP FROM "+RetSqlName("SD3")+" SD3 "+ENTER
	cSql += " WHERE " + ENTER
	cSql += " 	D3_DOC = '"+_cDocNum+"' AND D3_COD = '"+_cProduto+"' AND D3_LOCAL = '"+_cLocal+"' AND D3_NUMSEQ = '"+_cNumSeq+"' " +ENTER
	cSql += "	AND D3_LOTECTL = '"+_cLote+"' AND D_E_L_E_T_='' "

	If chkfile("QRY_SD3")
		dbSelectArea("QRY_SD3")
		dbCloseArea("QRY_SD3")
	EndIf
	TCQUERY cSql ALIAS "QRY_SD3" NEW

	_cOpNum := Substr(QRY_SD3->D3_OP,1,6)

	QRY_SD3->(DbCloseArea())

	//BUSCAR ITEM E SEQUENCIAL DA OP
	cSql := "SELECT C2_NUM,C2_SEQUEN,C2_ITEM FROM "+RetSqlName("SC2")+" SC2 "     +ENTER
	cSql += " WHERE C2_FILIAL = '"+XFILIAL("SC2")+"' AND C2_NUM = '"+_cOpNum+"' AND C2_PRODUTO = '"+_cProduto+"'  " +ENTER
	cSql += " AND C2_LOCAL = '"+_cLocal+"' AND D_E_L_E_T_ = '' "

	If chkfile("QRY_SC2")
		dbSelectArea("QRY_SC2")
		dbCloseArea("QRY_SC2")
	EndIf
	TCQUERY cSql ALIAS "QRY_SC2" NEW

	If !QRY_SC2->(EOF())


		//Controlar quantidade pendente endereçada
		__nQtdARes := _nQuant

		//PROCURAR SE EXISTE RESERVA PARA A OP QUE ORIGINOU O ENDERECAMENTO
		PZ0->(DbSetOrder(1))//PZ0_FILIAL+PZ0_OPNUM+PZ0_OPITEM+PZ0_OPSEQ
		If PZ0->(DbSeek(xFilial("PZ0")+_cOpNum+QRY_SC2->C2_ITEM+QRY_SC2->C2_SEQUEN))
			While !PZ0->(EOF()) .And. PZ0->(PZ0_FILIAL+PZ0_OPNUM+PZ0_OPITEM+PZ0_OPSEQ) == (xFilial("PZ0")+_cOpNum+QRY_SC2->C2_ITEM+QRY_SC2->C2_SEQUEN)

				//A reserva de OP ja foi atendida por outro lote - se sim nao pode usar lotes diferentes
				If (Empty(PZ0->PZ0_LOTRES) .Or. (PZ0->PZ0_LOTRES == _cLote))

					//Essa Reserva tem pendencia de gerar reserva de estoque?
					If (PZ0->PZ0_QUANT - PZ0->PZ0_RESERVA) > 0

						//Tenho quantidade produzida pendente para reservar?
						If __nQtdARes > 0

							//quantidade para reservar - ou fecha a reserva de OP ou reserva a quantidade produzida e mantem o saldo
							__nQtdPEst := Min( (PZ0->PZ0_QUANT - PZ0->PZ0_RESERVA) , __nQtdARes)

							_cPedido 	:= PZ0->PZ0_PEDIDO
							_cItemPed 	:= PZ0->PZ0_ITEMPV
							_nQuantRes	:= PZ0->PZ0_QUANT

							DbSelectArea("SC5")
							DbSetOrder(1)
							If DbSeek(xFilial("SC5")+_cPedido)
								_cVendPed	:= SC5->C5_VEND1
							EndIf

							Begin Transaction

								If Reserva(__nQtdPEst) //Realizar reserva de estoque SC0

									//ATUALIZA O SALDO NA PZ0 DO QUE JA FOI RESERVADO PARA A OP
									RecLock("PZ0",.F.)
									PZ0->PZ0_RESERVA :=  PZ0->PZ0_RESERVA + __nQtdPEst

									If Empty(PZ0->PZ0_LOTRES)
										PZ0->PZ0_LOTRES := _cLote
									EndIf

									//Se a reserva de OP foi totalmente atendida - excluir a mesma
									If (PZ0->PZ0_QUANT - PZ0->PZ0_RESERVA) <= 0
										PZ0->(DbDelete())
									EndIf

									PZ0->(MsUnlock())

									__nQtdARes -= __nQtdPEst //computando quanrtidade pendente para tentar reservar

								EndIf

							End Transaction

						EndIf

					EndIf

				EndIf

				PZ0->(DbSkip())
			EndDo
		EndIf

	EndIf

	QRY_SC2->(DbCloseArea())
	PZ0->(DbCloseArea())

Return Nil

//DESCRICAO..: REALIZAR A RESERVA
Static Function Reserva(nQtdPEst)

	Local cNumero
	Local lRet := .F.
	Local _nPreReserv := 0


	//Verifica se ja existe reserva do mesmo lote - apagar e fazer outra somando a quantidade
	SC0->(DbOrderNickName("PEDIDO"))
	If SC0->(DbSeek(XFilial("SC0")+_cPedido+AllTrim(_cItemPed)))

		While !SC0->(Eof()) .And. SC0->(C0_FILIAL+C0_YPEDIDO+AllTrim(C0_YITEMPV)) == (XFilial("SC0")+_cPedido+AllTrim(_cItemPed))
			//Exclui e computa as reservas do mesmo lote
			If SC0->C0_LOTECTL == _cLote

				_nPreReserv += SC0->C0_QUANT 

				U_GravaPZ2(SC0->(RecNo()),"SC0",SC0->(C0_FILIAL+C0_NUM+C0_PRODUTO),"R04_OPAUTO",AllTrim(FunName()),"OPA", CUSERNAME)

				__cChaveSDC := SC0->(C0_FILIAL+C0_PRODUTO+C0_LOCAL+'SC0'+C0_NUM)

				a430Reserv({3,"VD","",CUSERNAME,XFilial("SC0")},;
				SC0->C0_NUM,;
				SC0->C0_PRODUTO,;
				SC0->C0_LOCAL,;
				SC0->C0_QUANT,;
				{	SC0->C0_NUMLOTE,;
				SC0->C0_LOTECTL,;
				SC0->C0_LOCALIZ,;
				SC0->C0_NUMSERI})

				U_FRCHKSDC(__cChaveSDC, CUSERNAME)

			EndIf

			SC0->(DbSkip())
		EndDo

	EndIf

	//Gerando a nova reserva total do mesmo lote
	cNumero := GetSx8Num("SC0","C0_NUM")
	ConfirmSx8()

	a430Reserva({1,"VD","",cUserName,XFilial("SC0")},;
	cNumero,;
	_cProduto,;
	_cLocal,;
	(nQtdPEst + _nPreReserv),;
	{"",_cLote,_cLocaliz,_cNumSeri})

	SC0->(DbSetOrder(1))
	If SC0->(DbSeek(XFilial("SC0")+cNumero+_cProduto))

		RecLock("SC0",.F.)
		SC0->C0_YHORA		:= SubStr(Time(),1,5)
		SC0->C0_VALIDA		:= dDataBase + 10
		SC0->C0_YPEDIDO 	:= _cPedido
		SC0->C0_YITEMPV		:= _cItemPed
		SC0->C0_YTEMP		:= "N"
		SC0->C0_YVEND		:= _cVendPed
		SC0->C0_YUSER		:= __CUSERID
		SC0->C0_OBS 		:= "RESERVA APOS PRODUCAO"
		SC0->(MsUnlock())

		lRet := .T.
	EndIf

	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(XFilial("SC6")+_cPedido+_cItemPed))
		RecLock("SC6",.F.)
		SC6->C6_YTPEST := "E"
		SC6->C6_LOTECTL := _cLote
		SC6->(MsUnlock())
	EndIf

Return lRet
