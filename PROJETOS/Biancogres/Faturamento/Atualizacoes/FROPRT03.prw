#include "PROTHEUS.CH"
#include "TOPCONN.CH"

#DEFINE TIT_MSG "SISTEMA - RESERVA DE ESTOQUE/OP"

Static __FRT03RESERVA

/*/{Protheus.doc} FROPRT03
@description Checkar e excluir reservas no caso de alteracao de pedido / Utilidades reserva de estoque
@author Fernando Rocha
@since 25/02/2014 
@version undefined
@param _cPedido, , descricao
@param _cItem, , descricao
@type function
/*/
User Function FROPRT03(_cPedido, _cItem)
	Local lRetorno := .T.
	Local nRet
	Local cOption
	Local aButtons

	Default _cItem := ""

	//Checkar - representante pode alterar o proprio pedido
	//Checkar - funcao de exibicao e validacao das reservas

	If Len(U_FRTE02LO("", _cPedido, _cItem, "", "")) > 0


		If ALTERA

			cOption := 	"CONSULTA: Consulta e exclui reservas se autorizado."+CRLF+;
				"ATENDENTE: Permite atendente ajustar quantidade."+CRLF+;
				"CANCELA: Cancelar alteração."

			aButtons := {"CONSULTA","ATENDENTE","CANCELA"}

		Else

			cOption := 	"CONSULTA: Consulta e exclui reservas se autorizado."+CRLF+;
				"CANCELA: Cancelar exclusão."

			aButtons := {"CONSULTA","CANCELA"}

		EndIf


		nRet := U_FROPMSG(TIT_MSG, 	"Existem RESERVAS de estoque vinculadas a este PEDIDO."+CRLF+;
			"É Necessário excluir as reservas antes de alterar/excluir o pedido."+CRLF+;
			"Escolha Opção:"+CRLF+;
			cOption;
			,aButtons,,;
			"Pedido com Reservas de Estoque")

		__FRT03RESERVA := nRet

		If (ALTERA .And. nRet == 3) .Or. (!ALTERA .And. nRet == 2)

			lRetorno := .F.
			__FRT03RESERVA := Nil

		ElseIf (ALTERA .And. nRet == 2)

			lRetorno := .T.  //Acesso para todos os internos - reuniao com comercial em 08/01/15

			If !lRetorno
				U_FROPMSG(TIT_MSG, 	"Usuário sem acesso a esta Operação."+CRLF+"OU não é o ATENDENTE responsável pelo pedido")
			EndIf

		ElseIf nRet == 1

			lRetorno := U_FROPTE02("", _cPedido, "", "","")

		EndIf

	EndIf

return(lRetorno)

//---------------------------------------------------------------------
//retornar o nome do atendente responsavel pelo pedido
//---------------------------------------------------------------------
User Function FCHKATEN(_cPedido, _cEmpresa)
	Local cAliasTmp
	Local cAliasC5
	Local cSQL
	Local cRet := ""

	Default _cEmpresa := AllTrim(CEMPANT)

	cAliasC5 := GetNextAlias()
	cSQL := "SELECT C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_VEND1, C5_YCLIORI, C5_YLOJORI, C5_YEMP FROM SC5"+_cEmpresa+"0 WHERE C5_FILIAL = '01' and C5_NUM = '"+_cPedido+"' and D_E_L_E_T_ = '' "

	TCQUERY CSQL ALIAS (cAliasC5) NEW
	(cAliasC5)->(DbGoTop())

	//Checkar se e o Atendente responsavel para alterar pedidos
	If !(cAliasC5)->(Eof())

		_cCliente := (cAliasC5)->(C5_CLIENTE+C5_LOJACLI)
		_cVend	  := (cAliasC5)->C5_VEND1

		If _cCliente == "01006401"
			_cCliente := (cAliasC5)->(C5_YCLIORI+C5_YLOJORI)

			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				%NOPARSER%
				SELECT C5_VEND1 FROM SC5070 WHERE C5_FILIAL = '01' and C5_YPEDORI = %EXP:(cAliasC5)->C5_NUM% and C5_YEMPPED = %EXP:_cEmpresa% and D_E_L_E_T_ = ''
			EndSql

			If !(cAliasTmp)->(Eof())
				oGerenteAtendente	:= TGerenteAtendente():New()
				oResult 			:= oGerenteAtendente:GetCliente((cAliasC5)->C5_YEMP, (cAliasC5)->C5_YCLIORI, (cAliasC5)->C5_YLOJORI, (cAliasTmp)->C5_VEND1)
				cRet 				:= AllTrim( oResult:cAtendente)
			EndIf

			(cAliasTmp)->(dbCloseArea())
		Else
			oGerenteAtendente	:= TGerenteAtendente():New()
			oResult 			:= oGerenteAtendente:GetCliente((cAliasC5)->C5_YEMP, (cAliasC5)->C5_CLIENTE, (cAliasC5)->C5_LOJACLI, (cAliasC5)->C5_VEND1)
			cRet 				:= AllTrim(oResult:cAtendente)
		EndIf

		If(!Empty(cRet))
			PswOrder(1)
			If (PswSeek(cRet, .T.))
				aUser	:= Pswret(1)
				cRet	:= AllTrim(aUser[1][2])
			EndIf
		EndIf

	EndIf

	(cAliasC5)->(DbCloseArea())
Return(cRet)


//---------------------------------------------------------------------
//retornar o nome do GERENTE responsavel pelo pedido
//---------------------------------------------------------------------
User Function FCHKGERE(_cPedido, _cEmpresa)
	Local cAliasTmp
	Local cAliasC5
	Local cSQL
	Local cRet := ""

	Default _cEmpresa := AllTrim(CEMPANT)

	cAliasC5 := GetNextAlias()
	cSQL := "SELECT C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_VEND1, C5_YCLIORI, C5_YLOJORI, C5_YEMP FROM SC5"+_cEmpresa+"0 WHERE C5_FILIAL = '01' and C5_NUM = '"+_cPedido+"' and D_E_L_E_T_ = '' "

	TCQUERY CSQL ALIAS (cAliasC5) NEW
	(cAliasC5)->(DbGoTop())

	//Checkar se e o Atendente responsavel para alterar pedidos
	If !(cAliasC5)->(Eof())

		_cCliente := (cAliasC5)->(C5_CLIENTE+C5_LOJACLI)
		_cVend	  := (cAliasC5)->C5_VEND1

		If _cCliente == "01006401"
			_cCliente := (cAliasC5)->(C5_YCLIORI+C5_YLOJORI)

			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				%NOPARSER%
				SELECT C5_VEND1 FROM SC5070 WHERE C5_FILIAL = '01' and C5_YPEDORI = %EXP:(cAliasC5)->C5_NUM% and C5_YEMPPED = %EXP:_cEmpresa% and D_E_L_E_T_ = ''
			EndSql

			If !(cAliasTmp)->(Eof())
				oGerenteAtendente	:= TGerenteAtendente():New()
				oResult 			:= oGerenteAtendente:GetCliente((cAliasC5)->C5_YEMP, (cAliasC5)->C5_YCLIORI, (cAliasC5)->C5_YLOJORI, (cAliasTmp)->C5_VEND1)
				cRet 				:= AllTrim( oResult:cGerente)
			EndIf

			(cAliasTmp)->(dbCloseArea())
		Else
			oGerenteAtendente	:= TGerenteAtendente():New()
			oResult 			:= oGerenteAtendente:GetCliente((cAliasC5)->C5_YEMP, (cAliasC5)->C5_CLIENTE, (cAliasC5)->C5_LOJACLI, (cAliasC5)->C5_VEND1)
			cRet 				:= AllTrim(oResult:cGerente)
		EndIf

	EndIf

	(cAliasC5)->(DbCloseArea())
Return(cRet)


//Retornar o e-mail do atendente pelo numero do pedido
User Function FMAILATE(_cPedido)
	Local _cUser := U_FCHKATEN(_cPedido)
	Local _cRet := ""

	PswOrder(2)
	If (PswSeek(_cUser, .T.))
		aUser := Pswret(1)
		_cRet := AllTrim(aUser[1][14])
	EndIf

Return(_cRet)


//Retornar o e-mail do GERENTE pelo numero do pedido
User Function FMAILGER(_cPedido)
	Local _cUser := U_FCHKGERE(_cPedido)
	Local _cRet := ""

	If(!Empty(_cUser))
		SA3->(DbSetOrder(1))
		If SA3->(DbSeek(XFilial("SA3")+_cUser))
			_cRet	:= AllTrim(SA3->A3_EMAIL)
		EndIf
	EndIf

Return(_cRet)


//Retornar todos os e-mail de atendentes pela Marca
User Function FMAATEMP(_cEmp)
	Local _cMail := ""
	Local aUser
	Local _cRet := ""
	Local cAliasTmp

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		%NOPARSER%
		SELECT DISTINCT ZZI_ATENDE FROM VW_SAP_ZZI WHERE MARCA = %EXP:AllTrim(_cEmp)+'01'%
	EndSql

	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof())

		PswOrder(1)
		If (PswSeek((cAliasTmp)->ZZI_ATENDE, .T.))
			aUser := Pswret(1)

			If !Empty(_cMail) .And. !Empty(aUser[1][14])
				_cMail += ";"
			EndIf

			If !Empty(aUser[1][14])
				_cMail += AllTrim(aUser[1][14])
			EndIf
		EndIf

		(cAliasTmp)->(DbSkip())
	EndDo
	(cAliasTmp)->(DbCloseArea())

Return(_cMail)

//ROTINA PARA BLOQUEAR ALTERACAO DO PEDIDO - Disparada pelo PE A410CONS
User Function FRRT03VR()
	Local I
	Local nRes := __FRT03RESERVA

	//Alteração de Pedido - Modo Atendente - Ajustar qtde em no maximo 10%
	If nRes <> Nil .And. nRes == 2

		//desahabilita todos os controles do Msmget
		FOR I := 1 To Len(oGetPV:aEntryCtrls)
			oGetPV:aEntryCtrls[I]:lReadOnly := .T.
		NEXT I

		oGetDad:obrowse:bldblclick := { | NROW, NCOL | IIf(CheckCol(NCOL),oGetDad:EDITCELL(),) }
		oGetDad:ForceRefresh()
	EndIf

Return

Static Function CheckCol(nCol)
	Local cAltFields := "C6_QTDVEN#"
	Local lRetorno := .T.

	If !(AllTrim(AHeader[nCol][2]) $ cAltFields)
		U_FROPMSG(TIT_MSG, 	"Pedido com RESERVA - Modo ATENDENTE."+CRLF+;
			"Somente é possível alterar os sequintes campos:"+CRLF+;
			cAltFields)
		lRetorno := .F.
	EndIf

Return(lRetorno)

//ROTINA PARA BLOQUEAR DELETAR LINHA NA ALTERACAO DO PEDIDO - Disparada pelo PE M410LDEL
User Function FRRT03VL()
	Local nRes := __FRT03RESERVA
	Local lRetorno := .T.
	//Alteração de Pedido - Modo Atendente - Deletar Linha
	//verificar se pode cancelar a reserva do item com Motivo
	If nRes <> Nil .And. nRes == 2
		lRetorno := .F.
	EndIf

Return(lRetorno)

//ROTINA PARA VALIDAR A QUANTIDADE - C6_QTDVEN - TOLERANCIA MODO ATENDENTE - VLDUSER
User Function FRRT03V1()
	Local nRes := __FRT03RESERVA
	Local lRetorno := .T.
	Local _nQtdDig := M->C6_QTDVEN
	Local _nPosIt := aScan(aHeader,{|x| alltrim(x[2]) == "C6_ITEM"})
	Local _cItem := acols[n][_nPosIt]
	Local _nQtdOri
	Local _nToler
	Local _nPTol := GetNewPar("MV_YTOLAPV",10)

	//retirado essa regra em 08/01 - reunicao com o comercial
	//Alteração de Pedido - Modo Atendente - Ajustar qtde em no maximo 10%
	/*If nRes <> Nil .And. nRes == 2

	lRetorno := .F.

	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(XFilial("SC6")+M->C5_NUM+_cItem))

	_nQtdOri := SC6->C6_QTDVEN
	_nToler := (_nQtdOri * _nPTol) / 100

		If (_nQtdOri > 0) .And. (_nQtdOri <> _nQtdDig) .And. ( Abs(_nQtdDig - _nQtdOri) <= _nToler )

	lRetorno := .T.

		Else

	U_FROPMSG(TIT_MSG, 	"Alteração de QUANTIDADE fora da faixa de TOLERÃNCIA",,2,"Alterando pedido com RESERVA - Modo ATENDENTE.")

		EndIf

	EndIf

EndIf*/

Return(lRetorno)

//Semelhante a funcao acima para uso no PE M410LIOK para validar a necessidade de alterar a reserva
User Function FRRT03V2(_cPedido, _cItem, _nQtdDig, _cLote)
	Local nRes := __FRT03RESERVA
	Local lRetorno := .T.
	Local _nQtdOri
	Local _nToler
	Local _nPTol := GetNewPar("MV_YTOLAPV",10)
	Local _aAreaC0 := SC0->(GetArea())

	Default _cLote := ""

	//Alteração de Pedido - Modo Atendente - Ajustar qtde em no maximo 10%
	If nRes <> Nil .And. nRes == 2

		lRetorno := .F.

		SC6->(DbSetOrder(1))
		If SC6->(DbSeek(XFilial("SC6")+_cPedido+_cItem))

			_nQtdOri := SC6->C6_QTDVEN
			//_nToler := (_nQtdOri * _nPTol) / 100

			If (_nQtdOri > 0) .And. (_nQtdOri <> _nQtdDig) //.And. ( Abs(_nQtdDig - _nQtdOri) <= _nToler )

				lRetorno := .T.

			EndIf

		EndIf

		//Verificar se tem reserva de estoque e se o Lote está diferente da tela para refazer
		If !lRetorno .And. !Empty(_cLote)

			SC0->(DbSetOrder(8))
			If SC0->(DbSeek(XFilial("SC0")+_cPedido+_cItem)) .And. SC0->C0_LOTECTL <> _cLote

				lRetorno := .T.

			EndIf

		EndIf


	EndIf

	RestArea(_aAreaC0)
Return(lRetorno)

//ROTINA PARA BLOQUEAR DELETAR LINHA NA ALTERACAO DO PEDIDO - Disparada pelo PE M410LDEL
User Function FRRT03V3()
	Local nRes := __FRT03RESERVA
	Local lRetorno 	:= .T.
	Local _cPctLM 	:= AllTrim(GetNewPar("FA_XPCTLM","8_9_D_B")) 
	Local _lNBlq 	:= (M->C5_YSUBTP $ AllTrim(GetNewPar("FA_TPNPLM","A #F #")))
	Local _aArea := GetArea()
	Local _aAreaC6 := SC6->(GetArea())
	Local _aAreaB1 := SB1->(GetArea())    
	Local _cEFabDig  
	Local _cTabSA1
	Local _cGrpVen  
	Local I

	//Tratamento especial para Replicacao de reajuste de preço
	If (IsInCallStack("U_M410RPRC")) .OR. (AllTrim(FunName()) == "RPC")
		Return(.T.)
	EndIf

	//Tratamento outros tipos de pedido
	If M->C5_TIPO <> "N"
		Return(.T.)
	EndIf

	//OS 3494-16 - Tania c/ aprovação do Fabio
	If cEmpAnt == "02"
		Return(.T.)
	EndIf

	If Alltrim(M->C5_YLINHA) == "2" //INCESA
		_cTabSA1 := "SA1050"
	ElseIf Alltrim(M->C5_YLINHA) == "3" //BELLACASA
		_cTabSA1 := "SA1050"
	ElseIf Alltrim(M->C5_YLINHA) == "4"
		_cTabSA1 := "SA1130"
	Else
		_cTabSA1 := "SA1010"
	EndIf

	//Alteração de Pedido - Modo Atendente - Deletar Linha
	//Nao permitir Alterar o Produto
	If !INCLUI .And. Empty(CREPATU) .And. M->C5_TIPO == 'N' .And. !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES","14"))) .And. M->C5_YLINHA <> "4"

		//Se for o mesmo produto - somente dando ENTER para ativar gatilhos - permite
		If AllTrim(M->C6_PRODUTO) == AllTrim(gdfieldget("C6_PRODUTO"))

			lRetorno := .T.
			RestArea(_aAreaB1)  
			RestArea(_aAreaC6)
			RestArea(_aArea)
			Return(lRetorno)

		Else
			__DataLib := GetNewPar("FA_DALTPPD",STOD("20151231"))

			if (Date() > __DataLib)  //provisorio liberar alteracao de produtos - solicitacao do Claudeir em 25/11
				U_FROPMSG(TIT_MSG, 	"Não é permitido alterar os produtos no modo atendente.",,2,"Tratamento Especial.")
				lRetorno := .F. 
			Else
				U_FROPMSG(TIT_MSG, 	"Alteração de produtos no modo atendente."+CRLF+"Permitida somente até "+DTOC(__DataLib)+" para manutenção especial.",,2,"Tratamento Especial.")
			endif
		EndIf

	EndIf

	//Fernando/Facile em 27/01/15 - OS 4595-16 - Gatilhar o armazem 05 para pedidos de Amostrar apos a digitacao do produto
	If lRetorno

		If (AllTrim(M->C5_YSUBTP) $ "A#M#F")

			aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOCAL"})] := "05"

		Else

			SBZ->(DbSetOrder(1))
			If SBZ->(DbSeek(XFilial("SBZ")+M->C6_PRODUTO)) .And. !Empty(SBZ->BZ_LOCPAD)
				aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_LOCAL"})] := SBZ->BZ_LOCPAD
			EndIf

		EndIF

	EndIf

	RestArea(_aAreaB1)  
	RestArea(_aAreaC6)
	RestArea(_aArea)

Return(lRetorno)

//LIMPAR VARIAVEL STATIC DE CONTRIOLE
User Function FRRT03CL()

	If Type("__FRT03RESERVA") <> "U" .And. __FRT03RESERVA <> Nil
		__FRT03RESERVA := Nil
	EndIf

	If Type("_FROPCHVTEMPRES") <> "U" .And. _FROPCHVTEMPRES <> Nil
		_FROPCHVTEMPRES := Nil
	EndIf

Return  


//Excluir reserva manualmente do item selecionado
User Function FR03ITEX()
	U_BIAMsgRun("Aguarde... Excluindo Reservas.",,{|| DelResProc() })
Return

Static Function DelResProc()
	Local aArea := GetArea()
	Local _cPedido	:= M->C5_NUM
	Local _cItem	:= Gdfieldget("C6_ITEM",n) 
	Local _nPTpEst	:=  aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YTPEST"})

	//confirma posicionamento do item
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(XFilial("SC6")+_cPedido+_cItem))

		If !MsgNoYes("Tem certeza que deseja excluir as reservas do item "+_cItem+" SELECIONADO?",TIT_MSG)
			Return
		EndIf

		//U_GravaPZ2(SC6->(RecNo()),"SC6",SC6->(C6_NUM+C6_ITEM),"DELRIT",SC6->C6_YTPEST,"XIT",CUSERNAME)
		U_FRRT02XR(_cPedido, _cItem, "", CUSERNAME, "XIT", .F.)
		ACols[n][_nPTpEst] := "N"
		GETDREFRESH()

	EndIf

	RestArea(aArea)
Return

//Gerar reserva de estoque manualmente
User Function FR03ITRE()

	Local _aAreaB1 := SB1->(GetArea())

	Local _cProduto	:= Gdfieldget("C6_PRODUTO",n) 
	Local _cTpEst	:= Gdfieldget("C6_YTPEST",n) 
	Local _cItem	:= Gdfieldget("C6_ITEM",n) 
	Local _cLote	:= Gdfieldget("C6_LOTECTL",n) 
	Local _cBlq		:= Gdfieldget("C6_BLQ",n)
	
	
	If (AllTrim(_cBlq) == 'R')
		MsgAlert("Item pedido com residuo eliminado.")
		Return
	EndIf
	

	If (!Empty(_cTpEst) .And. _cTpEst <> "N")
		MsgInfo("Item "+_cItem+" já RESERVADO!",TIT_MSG)
		Return
	EndIf

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+_cProduto)) .And. SB1->B1_RASTRO == "L"

		If Empty(_cLote)
			MsgInfo("Item "+_cItem+": Selecione o LOTE pela consulta F6.",TIT_MSG)
			Return
		EndIf

	EndIf

	If !MsgNoYes("Tem certeza que deseja gerar a RESERVA DE ESTOQUE:"+CRLF+;
	"Item: "+_cItem+" - Lote: "+_cLote+CRLF+CRLF+;
	"Certifique-se que o saldo do LOTE é suficiente.",TIT_MSG)
		Return
		EndIf

	RestArea(_aAreaB1)

	U_BIAMsgRun("Aguarde... Gerando Reserva de ESTOQUE.",,{|| IncRESProc() })
Return

Static Function IncRESProc()
	Local aArea := GetArea()
	Local _cPedido	:= M->C5_NUM
	Local _cItem	:= Gdfieldget("C6_ITEM",n)
	Local _cLote	:= Gdfieldget("C6_LOTECTL",n) 
	Local _nQtdVen	:= Gdfieldget("C6_QTDVEN",n)
	Local _nPTpEst	:=  aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YTPEST"})
	Local __aRetRes
	Local cAliasTmp

	//confirma posicionamento do item
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(XFilial("SC6")+_cPedido+_cItem))

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			%NOPARSER%

			select SALDO = C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from %Table:SC9% SC9 where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.%NotDel%),0)
			from %Table:SC6% SC6 where C6_FILIAL = %XFILIAL:SC6% and C6_NUM = %EXP:SC6->C6_NUM% and C6_ITEM = %EXP:SC6->C6_ITEM% and SC6.%NotDel%

		EndSql

		If !(cAliasTmp)->(Eof()) .And. (cAliasTmp)->SALDO > 0

			__aRetRes := U_FROPRT02(SC6->C6_NUM, SC6->C6_ITEM, SC6->C6_PRODUTO, SC6->C6_LOCAL, (cAliasTmp)->SALDO, M->C5_VEND1, _cLote, .T., "INC")
			If Len(__aRetRes[2]) <= 0
				MsgAlert("Não foi possível criar reserva para o item. Verifique a quantidade e saldo disponível do lote.",TIT_MSG)
				RestArea(aArea)
				Return
			Else

				DbSelectArea("SA1")
				SA1->(DbSetOrder(1))

				SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE + M->C5_LOJACLI))

				ACols[n][_nPTpEst] := "E"
				RecLock("SC6",.F.)
				SC6->C6_YTPEST := "E"
				SC6->C6_ENTREG := Iif(Alltrim(SA1->A1_YCAT) == 'FUNC',U_FROPAD3U(dDataBase,10),U_FROPAD3U(dDataBase))
				SC6->C6_YOBS := "Ent: "+DTOC(SC6->C6_ENTREG)+" u:"+AllTrim(cUserName)
				SC6->(MsUnlock())
			EndIf

		Else
			MsgAlert("Não foi possível criar reserva para o item. Item sem saldo disponível para reservar.",TIT_MSG)
			RestArea(aArea)
			Return
		EndIf

	EndIf

	RestArea(aArea)
Return

//Gerar reserva de OP manualmente
User Function FR03ITRO()
	Local _cTpEst	:= Gdfieldget("C6_YTPEST",n)
	Local _cItem	:= Gdfieldget("C6_ITEM",n)
	Local _cOP		:= Gdfieldget("C6_NUMOP",n)
	Local _cBlq		:= Gdfieldget("C6_BLQ",n)

	Local _cAliasAux

	If (AllTrim(_cBlq) == 'R')
		MsgAlert("Item pedido com residuo eliminado.")
		Return
	EndIf


	If (!Empty(_cTpEst) .And. _cTpEst <> "N")
		MsgInfo("Item "+_cItem+" já RESERVADO!",TIT_MSG)
		Return
	EndIf

	If Empty(_cOP)
		MsgInfo("Item "+_cItem+": Selecione a OP pela consulta F6.",TIT_MSG)
		Return
	EndIf

	If !MsgNoYes("Tem certeza que deseja gerar a RESERVA DE OP:"+CRLF+;
			"Item: "+_cItem+" - OP: "+_cOP+CRLF+CRLF+;
			"Certifique-se que o saldo da OP é suficiente.",TIT_MSG)
		Return
	EndIf

	U_BIAMsgRun("Aguarde... Gerando Reserva de OP.",,{|| IncROPProc() })
Return

Static Function IncROPProc()
	Local aArea := GetArea()
	Local _cPedido	:= M->C5_NUM
	Local _cItem	:= Gdfieldget("C6_ITEM",n)
	Local _cOPNum	:= Gdfieldget("C6_NUMOP",n)
	Local _cOPItem	:= Gdfieldget("C6_ITEMOP",n)
	Local _nQtdVen	:= Gdfieldget("C6_QTDVEN",n)
	Local _nPTpEst	:=  aScan(aHeader,{|x| AllTrim(x[2]) == "C6_YTPEST"})
	Local _nSalOP
	Local _lOkOP	:= .F.
	Local cAliasTmp
	Local cAliasPz0

	//confirma posicionamento do item
	SC6->(DbSetOrder(1))
	If SC6->(DbSeek(XFilial("SC6")+_cPedido+_cItem))

		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			%NOPARSER%

			select SALDO = C6_QTDVEN - isnull((select SUM(C9_QTDLIB) from %Table:SC9% SC9 where C9_FILIAL = C6_FILIAL and C9_PEDIDO = C6_NUM and C9_ITEM = C6_ITEM and SC9.%NotDel%),0)
			from %Table:SC6% SC6 where C6_FILIAL = %XFILIAL:SC6% and C6_NUM = %EXP:SC6->C6_NUM% and C6_ITEM = %EXP:SC6->C6_ITEM% and SC6.%NotDel%

		EndSql

		If !(cAliasTmp)->(Eof()) .And. (cAliasTmp)->SALDO > 0

			ZZ6->(DbSetOrder(1))
			ZZ6->(DbSeek(XFilial("ZZ6")+SubStr(SC6->C6_PRODUTO,1,2)))

			SC2->(DbSetOrder(1))
			If SC2->(DbSeek(XFilial("SC2")+_cOPNum+_cOPItem+"001")) .And. SC2->C2_PRODUTO == SC6->C6_PRODUTO

				_nSalOP := U_FRSALDOP(CEMPANT,SC2->C2_FILIAL,SC2->C2_NUM,SC2->C2_ITEM,SC2->C2_SEQUEN,_cPedido,_cItem)

				If _nSalOP > (cAliasTmp)->SALDO

					RecLock("PZ0",.T.)
					PZ0->PZ0_FILIAL := XFilial("PZ0")
					PZ0->PZ0_OPNUM := SC2->C2_NUM
					PZ0->PZ0_OPITEM := SC2->C2_ITEM
					PZ0->PZ0_OPSEQ := SC2->C2_SEQUEN
					PZ0->PZ0_CODPRO := SC2->C2_PRODUTO
					PZ0->PZ0_PEDIDO := SC6->C6_NUM
					PZ0->PZ0_ITEMPV := SC6->C6_ITEM
					PZ0->PZ0_QUANT := (cAliasTmp)->SALDO
					PZ0->PZ0_USUINC := CUSERNAME
					PZ0->PZ0_DATINC := Date()
					PZ0->PZ0_HORINC := SubStr(Time(),1,5)
					PZ0->PZ0_DATENT := SC2->C2_YDTDISP
					PZ0->PZ0_STATUS := 'P'
					PZ0->(MsUnlock())


					//Ticket 11138 - Verificando se existe um registro anterior de reserva de OP para o mesmo item e gravar Log de Alteracao para gerar o Workflow de reprogramacao
					cAliasPz0 := GetNextAlias()
					BeginSql Alias cAliasPz0
						%NoParser%					
						select top 1 REC = R_E_C_N_O_, CHAVE = PZ0_FILIAL+PZ0_OPNUM+PZ0_OPITEM+PZ0_OPSEQ from PZ0010 where PZ0_FILIAL = %Exp:XFilial("PZ0")% and PZ0_PEDIDO = %Exp:SC6->C6_NUM% and PZ0_ITEMPV = %Exp:SC6->C6_ITEM% and PZ0_STATUS = 'P' and D_E_L_E_T_='*' order by R_E_C_N_O_ desc
					EndSql

					If !(cAliasPz0)->(Eof())

						//Gravando log de alteração de reserva de OP para gerar workflow - Ticket 11138 - Fernando em 07/02/19
						U_GravaPZ2((cAliasPz0)->REC,"PZ0",(cAliasPz0)->CHAVE,"REPROG",AllTrim(FunName()),"REP", CUSERNAME)

					EndIf
					(cAliasPz0)->(DbCloseArea())

					_lOkOP := .T.

				EndIf

				If _lOkOP

					ACols[n][_nPTpEst] := "R"
					RecLock("SC6",.F.)
					SC6->C6_YTPEST := "R"
					SC6->C6_YOBS := "Ent: "+DTOC(SC6->C6_ENTREG)+" u:"+AllTrim(cUserName)

					//Ticket 11138 - Fernando em 07/02/19 - Para gerar workflow de alteracao para cliente o C6_ENTREG nao pode ser alterado
					//SC6->C6_ENTREG := IIF(!Empty(SC2->C2_YDTDISP),SC2->C2_YDTDISP,SC2->C2_DATPRF)
					SC6->C6_YDTDISP := IIF(!Empty(SC2->C2_YDTDISP),SC2->C2_YDTDISP,SC2->C2_DATPRF)

					SC6->(MsUnlock())
				Else
					MsgAlert("Não foi possível criar reserva de OP para o item. Verifique a quantidade e saldo disponível da OP.",TIT_MSG)
				EndIf

			EndIf

		Else
			MsgAlert("Não foi possível criar reserva para o item. Item sem saldo disponível para reservar.",TIT_MSG)
			RestArea(aArea)
			Return
		EndIf

	EndIf

	RestArea(aArea)
Return

