#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} M410STTS
@description Ponto de Entrada apos gravacao do Pedido de Vendas fora da transacao
@author ferna
@since 25/11/2005
@version 9.0
@type function
@version  ultima revisao em 04/10/2018 por Fernando Rocha - projeto PBI - empenho automatico
/*/
User Function M410STTS()

	Local cSql		:= ""

	Local cArqSC6	:= ""
	Local cIndSC6	:= 0
	Local cRegSC6	:= 0

	Local cArqSB1	:= ""
	Local cIndSB1	:= 0
	Local cRegSB1	:= 0

	Local cArqSA1	:= ""
	Local cIndSA1	:= 0
	Local cRegSA1	:= 0

	Local nBloq		:= .F.
	lOCAL cPedVenda := ""
	lOCAL cItempedv := ""

	ConOut("M410STTS => INICIO, thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())

	DbSelectArea("SC6")
	cArqSC6 := Alias()
	cIndSC6 := IndexOrd()
	cRegSC6 := Recno()

	DbSelectArea("SB1")
	cArqSB1 := Alias()
	cIndSB1 := IndexOrd()
	cRegSB1 := Recno()

	DbSelectArea("SA1")
	cArqSA1 := Alias()
	cIndSA1 := IndexOrd()
	cRegSA1 := Recno()

	//Tratamento especial para Replcacao de pedido LM
	If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC") .OR. AllTrim(FunName()) $ GetNewPar("FA_XPEDRQC","FRQCTE01###FRQCRT02")
		Return Nil
	EndIf

	//Tratamento especial para Replicacao de reajuste de preço
	IF ALTERA
		//REAJUSTE DE PREÇO - LM para ORIGEM
		IF AllTrim(CEMPANT) == "07" .And. IsInCallStack("U_M410RPRC") .And. SC6->(FieldPos("C6_YPREAJU")) > 0

			U_REAJREPL(M->C5_NUM, .F.)
			Return Nil

		ELSEIF (AllTrim(CEMPANT) <> "07") .And. (IsInCallStack("U_M410RPRC")) .And. SC6->(FieldPos("C6_YPREAJU")) > 0

			U_RECXEMPS()
			Return Nil

		ELSEIF (IsInCallStack("U_M410RPRC"))
			Return Nil
		EndIf
	ENDIF

	//OS 3494-16 - Tania c/ aprovação do Fabio
	If cEmpAnt == "02"
		Return Nil
	EndIf

	ConOut("M410STTS => ANTES DO SEMAFORO, thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())

	// Tiago Rossini Coradini - 26/09/2016 - OS: 3239-16 - Ranisses Corona - Adiciona controle de semaforo
	MayIUseCode("SC5" + cEmpAnt + cFilAnt + SC5->C5_NUM)


	ConOut("M410STTS => POS01, thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())

	//Comunica o setor de Crédito e Cobrança, sobre inclusão de Pedido de Contrato.
	If SC5->C5_YTPCRED == "2" .And. INCLUI
		cRecebe   := U_EmailWF('M410STTS', cEmpAnt)
		cRecebeCC := ""

		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))

		If (cEmpAnt == "01" .Or. cEmpAnt == "0101") .And. Alltrim(SA1->A1_YTPSEG) == "E"
			cRecebeO 	:= U_EmailWF('M410STTSOC', cEmpAnt)
		Else
			cRecebeO 	:= ""
		EndIf
		cAssunto  := "Inclusão de Pedido de Venda Nº "+M->C5_NUM+" - referente Contrato - Empresa "+FWEmpName(cEmpAnt)
		cMsg	  := "Foi incluído no sistema um Pedido de Venda de Contrato (Nº "+M->C5_NUM+"), para o Cliente/Loja "+M->C5_CLIENTE+"/"+M->C5_LOJACLI+", que necessita de sua aprovação." + CHR(13)+CHR(10)
		cMsg	  += "Acesse o menu 'Liberação Cred. Pv', para realizar a análise e aprovação deste Pedido."
		U_BIAEnvMail(,cRecebe,cAssunto,cMsg,,,.F.,cRecebeCC,cRecebeO)
	EndIf

	ConOut("M410STTS => POS02, thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())

	IF cEmpAnt <> '02'

		//Verifica se existem Itens com Bloqueio de Credito
		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			SELECT COUNT(C9_BLCRED) BLCRED FROM %Table:SC9% WHERE C9_FILIAL = %xfilial:SC9% AND C9_PEDIDO = %Exp:M->C5_NUM% AND C9_NFISCAL = ' ' AND (C9_BLCRED <> ' ' OR (C9_YDTBLCT <> '' AND C9_YDTLICT = '') ) AND %NOTDEL% 
		EndSql
		If (cAliasTmp)->BLCRED > 0
			If Type("nTpBlq") <> "U"
				If nTpBlq == "01"
					Msgbox("Este pedido possui itens com Bloqueio de Crédito, pois ultrapassa o Limite de Crédito.","M410STTS","STOP")
				ElseIf nTpBlq == "02"
					Msgbox("Este pedido possui itens com Bloqueio de Crédito, pois não possui saldo de RA.","M410STTS","STOP")
				ElseIf nTpBlq == "03"
					Msgbox("Este pedido possui itens com Bloqueio de Crédito, pois o Cliente possui Risco 'E'.","M410STTS","STOP")
				ElseIf nTpBlq == "04"
					Msgbox("Este pedido possui itens com Bloqueio de Crédito, pois o Cliente está com o Limite de Crédito vencido.","M410STTS","STOP")
				ElseIf nTpBlq == "05"
					Msgbox("Este pedido possui itens com Bloqueio de Crédito, pois o Cliente possui títulos em atraso.","M410STTS","STOP")
				ElseIf nTpBlq == "061"
					Msgbox("Este pedido possui itens com Bloqueio de Crédito, pois teve alteração na data de entrega aprovada.","M410STTS","STOP")
				ElseIf nTpBlq == "062"
					Msgbox("Este pedido possui itens com Bloqueio de Crédito, pois teve alteração nos valores aprovados.","M410STTS","STOP")
				ElseIf nTpBlq == "063"
					Msgbox("Este pedido possui itens com Bloqueio de Crédito, pois está sendo liberado antes da data de entrega.","M410STTS","STOP")
				ElseIf nTpBlq == "064"
					Msgbox("Este pedido possui itens com Bloqueio de Crédito, pois está com títulos de Contrato em atraso.","M410STTS","STOP")
				EndIf
			Else
				Msgbox("Este pedido possui itens com  Bloqueio de Crédito.","M410STTS","STOP")
			EndIf
		EndIf

		//Verifica se existem Itens com Bloqueio de Estoque
		cAliasTmp2 := GetNextAlias()
		BeginSql Alias cAliasTmp2
			SELECT COUNT(C9_BLEST) BLEST FROM %Table:SC9% WHERE C9_FILIAL = %xfilial:SC9% AND C9_PEDIDO = %Exp:M->C5_NUM% AND C9_NFISCAL = ' ' AND C9_BLEST <> ' ' AND %NOTDEL%
		EndSql
		If (cAliasTmp2)->BLEST > 0
			Msgbox("Este pedido possui itens com  Bloqueio de Estoque.","M440STTS","STOP")
		EndIf
		(cAliasTmp)->(dbCloseArea())
		(cAliasTmp2)->(dbCloseArea())

		//Grava Status do RA na Liberação dos Pedidos
		//Comentado abaixo para teste ticket 22342 - Ja eh chamada no PE M440SC9I
		//U_BIA859(SC5->C5_CLIENTE,SC5->C5_LOJACLI)

		aArea := GetArea()
		//Grava o pedido na Sol. de Crédito caso não tenha pedido
		cSZU :=" SELECT ZUN.ZU_CODIGO 								"
		cSZU +=" FROM SZU010 ZUN WITH (NOLOCK)						"
		cSZU +=" WHERE ZUN.ZU_PEDIDO = '*'							"
		cSZU +=" AND ZUN.ZU_CODCLI	= '"+SC5->C5_CLIENTE+"'			"
		cSZU +=" AND ZUN.ZU_CHAVTMP	= ''							"
		cSZU +=" AND ZUN.ZU_CODCLI NOT IN (SELECT ZUP.ZU_CODCLI 	"
		cSZU +=" 			FROM SZU010 ZUP WITH (NOLOCK)       	"
		cSZU +=" 			WHERE ZUP.ZU_PEDIDO = '"+SC5->C5_NUM+"'	"
		cSZU +=" 			AND ZUP.ZU_EMPRESA  = '"+cEmpAnt+"'		"
		cSZU +="			AND ZUN.ZU_CHAVTMP  = ''				"
		cSZU +=" 			AND ZUP.ZU_CODCLI   = ZUN.ZU_CODCLI)  	"
		cSZU +=" ORDER BY ZU_DATA DESC                          	"
		TCQUERY cSZU ALIAS "_cSZU" NEW
		DbSelectArea("_cSZU")

		If!_cSZU->(EOF()) .And. cEmpAnt $ "01_05_07_14" .And. INCLUI
			SZU->(DbSetOrder(1))
			If SZU->(DbSeek(xFilial("SZU")+_cSZU->ZU_CODIGO))
				RecLock("SZU",.F.)
				SZU->ZU_PEDIDO 	:= SC5->C5_NUM
				SZU->ZU_EMPRESA := cEmpAnt
				SZU->(MsUnlock())
			EndIf
			SZU->(dbCloseArea())
		EndIf
		_cSZU->(dbCloseArea())
		RestArea(aArea)

		//Altera o tipo do cliente no pedido para nao gerar substituicao tributaria para SP.
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		IF SA1->A1_EST == 'SP' .AND. SC5->C5_TIPOCLI == 'S' .AND. ALLTRIM(SC5->C5_YSUBTP) == 'A'
			DbSelectArea("SC5")
			RecLock("SC5",.F.)
			SC5->C5_TIPOCLI := 'R'
			MsUnLock()
		ENDIF

		//Deleta Romaneio apos Estornar o Pedido
		If ALTERA = .T.
			cSql := ""
			cSql += "UPDATE "+ retsqlname("SZ9") +" SET D_E_L_E_T_ = '*' "
			cSql += "FROM "+ retsqlname("SZ9") +" "
			cSql += "WHERE 	Z9_FILIAL = '"+ xFilial("SZ9") +"' AND Z9_PEDIDO = '"+ ALLTRIM(M->C5_NUM) +"' AND "
			cSql += "	D_E_L_E_T_ = '' 	AND "
			cSql += "	EXISTS(SELECT * FROM "+ retsqlname("SC9") +" "
			cSql += "			WHERE		C9_FILIAL   = '"+ xFilial("SC9") +"' AND "
			cSql += "						C9_PEDIDO	= Z9_PEDIDO 		AND	"
			cSql += "						C9_PRODUTO	= Z9_PRODUTO 		AND	"
			cSql += "						C9_AGREG   	= Z9_AGREG 			AND	"
			cSql += "	      		C9_ITEM    	= Z9_ITEM 			AND	"
			cSql += "       		C9_SEQUEN		= Z9_SEQUEN 		AND	"
			cSql += "						C9_NFISCAL 	= '') 							"
			TcSQLExec(cSql)
		EndIf



		//Acumula valor para Margem
		nVlOld := GetNextAlias()
		BeginSql Alias nVlOld
			SELECT SUM(C6_YPERCMC) AS VL FROM %Table:SC6% WHERE C6_FILIAL = %xfilial:SC6% AND C6_NUM = %Exp:M->C5_NUM%  AND %NOTDEL%
		EndSql

		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		//Rotina para calcular e gravar a margem
		//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
		If Inclui .Or. Altera
			//U_CalcMargem(M->C5_NUM,"2")
			//U_fMargem2(M->C5_NUM,"2")
			U_fMargem3(M->C5_NUM,"2")
		EndIf

		/*
		//Acumula valor para Margem
		nVlNew := GetNextAlias()
		BeginSql Alias nVlNew
		SELECT SUM(C6_YPERCMC) AS VL FROM %Table:SC6% WHERE C6_FILIAL = %xfilial:SC6% AND C6_NUM = %Exp:M->C5_NUM%  AND %NOTDEL%
		EndSql

		//Verifica se houve alteracao na Margem
		If (nVlOld)->VL <> (nVlNew)->VL .And. Alltrim(M->C5_TIPO) == 'N'
			Conout("M410STTS APROVAÇÃO PEDIDO " + M->C5_NUM + " => Motivo: (nVlOld)->VL <> (nVlNew)->VL .And. Alltrim(M->C5_TIPO) == 'N' " + Str((nVlOld)->VL) + " e " + Str((nVlNew)->VL) + " e " + Alltrim(M->C5_TIPO) + ", thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
			lCheckPV := .T.
		EndIf

		//Caso o pedido não tenha aprovador, submete novamente a analise
		If Alltrim(M->C5_TIPO) == 'N' .And. Alltrim(M->C5_YAAPROV) == ''
			Conout("M410STTS APROVAÇÃO PEDIDO " + M->C5_NUM + " => Motivo: Alltrim(M->C5_TIPO) == 'N' .And. Alltrim(M->C5_YAAPROV) == '' " + Alltrim(M->C5_TIPO) + " e " + Alltrim(M->C5_YAAPROV) + " , thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())
			lCheckPV := .T.
		EndIf

		//Rotina para bloqueio testando Desconto e Margem
		If Inclui .Or. Altera
			nBloq := U_fBloqPV()
		EndIf
		*/

		If Inclui .Or. Altera

			SC6->(DbSetOrder(1))
			SB1->(DbSetOrder(1))
			SC6->(DbSeek(XFilial("SC6")+SC5->C5_NUM))

			If(SB1->(DbSeek(XFilial("SB1")+SC6->C6_PRODUTO)))

				//If AllTrim(SB1->B1_TIPO) == "PA" .Or. (ALLTRIM(SC5->C5_YSUBTP) $ "A_G_B_M" //Ticket 30911 - Adicionado o tipo 'O'
				If(	AllTrim(SB1->B1_TIPO) == "PA" ;	
    				.Or. ALLTRIM(SC5->C5_YSUBTP) $ "A_G_B_M" ;
    				.Or. (SC5->C5_YSUBTP == 'O' .And. AllTrim(SB1->B1_TIPO) == "PA") ;//Ticket 30911 - Adicionado o tipo 'O' //Ticket 31528 - Complemento da regra para tipos diferenets de PA
					)
					If (Alltrim(SC5->C5_TIPO) == 'N')
						oBloqPedVenda := TBloqueioPedidoVenda():New(M->C5_NUM)
						nBloq := oBloqPedVenda:Check()
					EndIf

				EndIf

			EndIf

		EndIf



		//PROJETO2014
		//ESTORNA A LIBERAÇÃO CASO O PEDIDO ESTEJA BLOQUEADO!!!!
		If nBloq
			dbSelectArea("SC9")
			dbSetOrder(1)
			dbSeek(xFilial("SC9")+M->C5_NUM,.F.)
			While ( !Eof() .And. SC9->C9_PEDIDO == M->C5_NUM )
				If ( SC9->C9_BLCRED <> "10"  .And. SC9->C9_BLEST <> "10" .And. SC9->C9_BLCRED <> "ZZ"  .And. SC9->C9_BLEST <> "ZZ")
					Begin Transaction
						SC9->(a460Estorna()) // lMata410 , lAtuEmp , nVlrCred -> OBRIGATÓRIO PASSAR O SEGUNDO PARAMETRO COMO .T. PARA ESTORNAR O EMPENHO NA TABELA SC6
					End Transaction
				EndIf
				dbSelectArea("SC9")
				dbSkip()
			EndDo
		EndIf

		ConOut("M410STTS => POS03 ANTES DE ENVIAR E-MAIL, thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())



		//caso não ocorrer bloqueio
		/*If (!nBloq)

		_nOpcao := IIF(Inclui,1, IIF(Altera, 2, 0))
		_oConfPedVen := TConferenciaPedidoVenda():New(cEmpAnt, cFilAnt, _nOpcao, CUSERNAME)
		_oConfPedVen:Checar(M->C5_NUM)

	EndIf
		*/


	__lEnvMail := .F.
	//ROTINA PARA MANDAR O EMAIL PARA O REPRESENTANTE E PARA O CLIENTE
	//*****************************************************************************************************************************
	//Fernando/Facile em 02/10/2014 - Projeto Reserva de OP/Lote - Só enviaar o email de pedido apos liberacao das rejeicoes de lote
	//*****************************************************************************************************************************
	If U_FROPVLPV(M->C5_NUM, .F., .F.) .And. U_fVlLbDes(M->C5_NUM,M->C5_YCLIORI)

		__lEnvMail := .T.

		SEMAIL := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_YEMAIL")

		_SC5 := GetNextAlias()
		BeginSql Alias _SC5
				SELECT C5_YAPROV FROM %Table:SC5% WHERE C5_FILIAL = %xfilial:SC5% AND C5_NUM = %Exp:M->C5_NUM% AND %NOTDEL%
		EndSql

		//(Thiago - 17/04/15) -> Envitar o envio do pedido errado.
		cEmpPed := cEmpAnt

		If !Empty(SC5->C5_YEMPPED)
			cEmpPed := M->C5_YEMPPED
		EndIf

		// If Substr(SC5->C5_NUM,1,1) == "R" .And. SC5->C5_TIPO == "N" .And. Alltrim((_SC5)->C5_YAPROV) <> "" .AND. SEMAIL == "S" .AND. (SC5->C5_YENVIO <> "S")
		If SC5->C5_YCONF == "S" .And. SC5->C5_TIPO == "N" .AND. SEMAIL == "S" .AND. (SC5->C5_YENVIO <> "S") //.And. Alltrim((_SC5)->C5_YAPROV) <> ""

			// Não envia e-mail para a JK
			If cEmpAnt <> "06"

				If 	Upper(AllTrim(getenvserver())) == "PRODUCAO" .OR.;
						Upper(AllTrim(getenvserver())) == "REMOTO" .OR.;
						Upper(AllTrim(getenvserver())) == "DEV-IPI" .OR.;
						Upper(AllTrim(getenvserver())) == "FACILE-PROD-FERNANDO" .OR.;
						Upper(AllTrim(getenvserver())) == "COMP-FERNANDO-TESTE-FIN"

					U_Env_Pedido(SC5->C5_NUM,,,cEmpPed)

					IF (SC5->C5_YENVIO <> "S")
						U_GravaPZ2(SC5->(RecNo()),"SC5",SC5->C5_YEMPPED+SC5->C5_NUM,"ENV_PED_1",AllTrim(FunName()),"ENV", CUSERNAME)
					ENDIF

				EndIf

				//Fernando/Facile em 02/09 - atualizar data das reservas de acordo com vencimento dodo boleto antecipado
				U_FR2VLRES(SC5->C5_NUM)
			EndIf

			IF (SC5->C5_YENVIO <> "S")
				U_GravaPZ2(SC5->(RecNo()),"SC5",SC5->C5_YEMPPED+SC5->C5_NUM,"ENV_PED_2",AllTrim(FunName()),"ENV", CUSERNAME)
			ENDIF

		EndIf
		(_SC5)->(dbCloseArea())

	EndIf//Fernando

	ConOut("M410STTS => POS04, thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())

	//Acerta Descricao do Produto no PV
	dbSelectArea("SC6")
	dbSetOrder(1)
	DbSeek(xFilial("SC6")+SC5->C5_NUM,.F.)
	While !Eof() .and. xFilial("SC6") == SC6->C6_FILIAL .and. SC6->C6_NUM == SC5->C5_NUM
		//Alteração - Gabriel - Solicitado por Marcos - Apagar o campo C6_YSTTSAM quando for Alteração
		If ALTERA
			RECLOCK("SC6",.F.)
			SC6->C6_YSTTSAM	:=	""
			SC6->C6_YECONAM	:=	""
			SC6->(MsUnlock())
		EndIf

		//So faz ajuste na descricao se o tipo do produto for PA
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
		If Alltrim(SB1->B1_TIPO)=="PA"
			While !RecLock("SC6",.F.) ; End
				If cempant = "01"

					IF Alltrim(SC5->C5_YRECR) == "S" //AGUARDANDO APROVACAO LUISMAR

						SC6->C6_YIMPNF := "D"
						SC6->C6_DESCRI := Subs(Alltrim(SB1->B1_YREF),1,(Len(Alltrim(SB1->B1_YREF))-1))
					Else
						If SUBS(SC6->C6_PRODUTO,8,1)=="1"
							SC6->C6_YIMPNF := "A"
							SC6->C6_DESCRI := Alltrim(SB1->B1_YREF)
						Else
							SC6->C6_YIMPNF := "C"
							SC6->C6_DESCRI := Alltrim(SB1->B1_YREF)
						Endif
					Endif
				ELSE

					IF Alltrim(SC5->C5_YRECR) == "S" //.OR. ( cempant == "05" .AND. SB1->B1_YCLASSE$"1_2_3" .AND. SC5->C5_CLIENTE $ "000481") //DESATIVADO CONFORME SOLICITACAO LUISMAR EM 18/05/2011
						SC6->C6_YIMPNF := "D"
						If Alltrim(Subs(Alltrim(SB1->B1_YREF),Len(Alltrim(SB1->B1_YREF))-3,4)) == "C/B"
							SC6->C6_DESCRI := Subs(Alltrim(SB1->B1_YREF),1,(Len(Alltrim(SB1->B1_YREF))-3))
						Else
							SC6->C6_DESCRI := Subs(Alltrim(SB1->B1_YREF),1,(Len(Alltrim(SB1->B1_YREF))-1))
						EndIf
					Else
						If SUBS(SC6->C6_PRODUTO,8,1)=="1"
							SC6->C6_YIMPNF := "A"
							SC6->C6_DESCRI := Alltrim(SB1->B1_YREF)
						Else
							SC6->C6_YIMPNF := "C"
							SC6->C6_DESCRI := Alltrim(SB1->B1_YREF)
						Endif
					Endif

				END IF
				MsUnLock()
			EndIf
			DbSkip()
		End
	ENDIF

	If cArqSC6 <> ""
		dbSelectArea(cArqSC6)
		dbSetOrder(cIndSC6)
		dbGoTo(cRegSC6)
		RetIndex("SC6")
	EndIf

	If cArqSB1 <> ""
		dbSelectArea(cArqSB1)
		dbSetOrder(cIndSB1)
		dbGoTo(cRegSB1)
		RetIndex("SB1")
	EndIf

	If cArqSA1 <> ""
		dbSelectArea(cArqSA1)
		dbSetOrder(cIndSA1)
		dbGoTo(cRegSA1)
		RetIndex("SA1")
	EndIf

	//---------------------------------------------------------------------------------------------------------------------------
	//FERNANDO/FACILE em 25/08/2014 - Projeto ACORDO DE OBJETIVOS - gerar baixas automaticamente
	//---------------------------------------------------------------------------------------------------------------------------
	ConOut("M410STTS => POS05 ANTES CONTROLE AI,  m->pedido: "+M->C5_NUM+", sc5->pedido: "+SC5->C5_NUM+", inclui: "+cvaltochar(INCLUI)+" altera: "+cvaltochar(ALTERA)+", thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())

	If !Empty(M->C5_YNUMSI) .And. !(AllTrim(CEMPANT) $ '14')
		If Inclui .Or. Altera

			U_AO_INCBX(M->C5_NUM,M->C5_YNUMSI)

		EndIf
	EndIf

	If SC6->(FieldPos("C6_YDAI")) > 0 .And. !Empty(M->C5_YNOUTAI) .And. !(AllTrim(CEMPANT) $ '14')
		If Inclui .Or. Altera

			U_AO_INCBX(M->C5_NUM,M->C5_YNOUTAI,"Baixa.Aut.Ped.c/Desc.", 2)

		EndIf
	EndIf

	//---------------------------------------------------------------------------------------------------------------------------
	//RANISSES em 22/10/2015 - Ajusta o Numero do Pedido na SC, caso seja alterado antes de salvar.
	//---------------------------------------------------------------------------------------------------------------------------
	If INCLUI .And. SC5->C5_YCRDENG == '03'
		If Type("_FROPCHVTEMPRES") <> "U" .And. !Empty(_FROPCHVTEMPRES)
			SZU->(DbSetOrder(2))
			If SZU->(DbSeek(xFilial("SZU")+_FROPCHVTEMPRES))
				RecLock("SZU",.F.)
				SZU->ZU_PEDIDO := SC5->C5_NUM
				SZU->(MsUnlock())
			EndIf
		EndIf
	EndIf

	//---------------------------------------------------------------------------------------------------------------------------
	//FERNANDO/FACILE em 12/03/2014 - Projeto RESERVA DE OP - Alterar reservas temporarias para permanente ao confirmar o pedido
	//---------------------------------------------------------------------------------------------------------------------------
	SC5->(DbSetOrder(1))

	If (Inclui .Or. Altera) .And.;
			SC5->(DbSeek(XFilial("SC5")+M->C5_NUM)) .And.;
			SC5->C5_TIPO == 'N' .And.;
			!(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES",""))) .And.;
			SC5->C5_YLINHA <> "4"

		ConOut("M410STTS => POS06, thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())

		//Fernando em 24/5 produto PR (manta) - efetivar reservas na LM
		SC6->(DbSetOrder(1))
		SB1->(DbSetOrder(1))
		SC6->(DbSeek(XFilial("SC6")+SC5->C5_NUM))
		SB1->(DbSeek(XFilial("SB1")+SC6->C6_PRODUTO))

		//nao faz para LM - na LM faz atraves de update depois da replicacao do pedido
		If Type("_FROPCHVTEMPRES") <> "U" .And. !Empty(_FROPCHVTEMPRES) .And. ( AllTrim(CEMPANT) <> "07" .Or.  SB1->B1_TIPO == "PR" .Or. (AllTrim(CEMPANT) == "07" .And.  AllTrim(cFilAnt) == "05"))

			ConOut("M410STTS => POS07 EFETIVA RESERVAS, thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())

			_cUserName 	:= _FROPCHVTEMPRES

			SC0->(DbSetOrder(5))
			If SC0->(DbSeek(XFilial("SC0")+_cUserName))
				While !SC0->(Eof()) .And. AllTrim(SC0->(C0_FILIAL+C0_SOLICIT)) == AllTrim((XFilial("SC0")+_cUserName))
					//Efetiva reservas temporarias pela chave do usuario e confirma numero do pedido que pode ter mudado
					If SC0->C0_YTEMP == "S"

						RecLock("SC0",.F.)

						If AllTrim(CEMPANT) <> "07" .Or. (AllTrim(CEMPANT) == "07" .And.  AllTrim(cFilAnt) == "05")
							SC0->C0_YPEDIDO 	:= SC5->C5_NUM
						Else
							SC0->C0_YPITORI 	:= STUFF(SC0->C0_YPITORI,1,6,SC5->C5_NUM)
						EndIf

						SC0->C0_YTEMP		:= "N"
						SC0->(MsUnlock())

					EndIf
					SC0->(DbSkip())
				EndDo
			EndIf
			//segundo loop - alterar o usuario da chave temporaria para o definitivo
			SC0->(DbOrderNickName("PEDIDO"))
			If SC0->(DbSeek(XFilial("SC0")+SC5->C5_NUM))
				While !SC0->(Eof()) .And. SC0->(C0_FILIAL+C0_YPEDIDO) == (XFilial("SC0")+SC5->C5_NUM)

					If SC0->C0_YTEMP == "N" .And. AllTrim(SC0->C0_SOLICIT) == _cUserName
						RecLock("SC0",.F.)
						SC0->C0_SOLICIT := CUSERNAME
						SC0->(MsUnlock())
					EndIf

					SC0->(DbSkip())
				EndDo
			EndIf

			//Reservas de OP
			PZ0->(DbSetOrder(4))
			If PZ0->(DbSeek(XFilial("PZ0")+_cUserName))
				While !PZ0->(Eof()) .And. AllTrim(PZ0->(PZ0_FILIAL+PZ0_USUINC)) == AllTrim((XFilial("PZ0")+_cUserName))

					//Efetiva reservas temporarias pela chave do usuario e confirma numero do pedido que pode ter mudado
					If PZ0->PZ0_STATUS == "T"
						RecLock("PZ0",.F.)
						PZ0->PZ0_PEDIDO := SC5->C5_NUM
						PZ0->PZ0_STATUS := "P"
						PZ0->(MsUnlock())
					EndIf

					PZ0->(DbSkip())
				EndDo
			EndIf
			//segundo loop - alterar o usuario da chave temporaria para o definitivo
			PZ0->(DbSetOrder(2))
			If PZ0->(DbSeek(XFilial("PZ0")+SC5->C5_NUM))
				While !PZ0->(Eof()) .And. PZ0->(PZ0_FILIAL+PZ0_PEDIDO) == (XFilial("PZ0")+SC5->C5_NUM)

					If PZ0->PZ0_STATUS == "P" .And. AllTrim(PZ0->PZ0_USUINC) == _cUserName
						RecLock("PZ0",.F.)
						PZ0->PZ0_USUINC := CUSERNAME
						PZ0->(MsUnlock())
					EndIf

					PZ0->(DbSkip())
				EndDo
			EndIf

		EndIf


		//Conferencia de pedido - registrar o usuario que fez a conferencia
		ConOut("M410STTS => POS08 ANTES C5_YUSCONF, thread: "+AllTrim(Str(ThreadId()))+"  data: "+DTOC(dDataBase)+" hora: "+Time())



		If Altera .And. (M->C5_YCONF == "S")

			ConOut("M410STTS => gravando C5_YUSCONF m->pedido: "+M->C5_NUM+", sc5->pedido: "+SC5->C5_NUM+",  data: "+DTOC(dDataBase)+" hora: "+Time())

			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(XFilial("SC5")+M->C5_NUM))

				RecLock("SC5",.F.)
				SC5->C5_YUSCONF := CUSERNAME
				SC5->(MsUnlock())

			EndIf

		EndIf

		//Conferencia de Pedido - Ao conferir na LM - replicar o campo C5_YCONF para a empresa origem tambem
		ConOut("M410STTS => depois de gravar C5_YUSCONF m->pedido: "+M->C5_NUM+", sc5->pedido: "+SC5->C5_NUM+",  data: "+DTOC(dDataBase)+" hora: "+Time())

		If Altera .And. AllTrim(CEMPANT) == "07"

			ConOut("M410STTS => replicando C5_YCONF ( LM >>> ORIGEM ) m->pedido: "+M->C5_NUM+", sc5->pedido: "+SC5->C5_NUM+",  data: "+DTOC(dDataBase)+" hora: "+Time())

			SC5->(DbSetOrder(1))
			If SC5->(DbSeek(XFilial("SC5")+M->C5_NUM)) .And. !Empty(SC5->C5_YPEDORI) .And. SC5->C5_YCONF == "S"

				_cRet := U_FRUTCONF(SC5->C5_NUM, SC5->C5_YPEDORI, SC5->C5_YAPROV)
				If !Empty(_cRet)

					U_FROPMSG("M410STTS - EMPENHO AUTOMATICO","Alerta empenho automático do pedido: "+CRLF+_cRet,,2,"Empenho Automático de Pedidos")

				EndIf

			EndIf

		EndIf



	Else

		ConOut("M410STTS => POS99 (ERRO), thread: "+AllTrim(Str(ThreadId()))+" inclui: "+cvaltochar(INCLUI)+" altera: "+cvaltochar(ALTERA)+"  data: "+DTOC(dDataBase)+" hora: "+Time())

	EndIf

	//---------------------------------------------------------------------------------------------------------------------------
	//FERNANDO/FACILE em 24/03/2014 - Projeto RESERVA DE OP - Limpar variveis de controle
	//---------------------------------------------------------------------------------------------------------------------------
	U_FRRT03CL()

	//---------------------------------------------------------------------------------------------------------------------------
	//FERNANDO/FACILE em 12/12/2014 - Projeto RESERVA DE OP - Apresentar mensagem de pedido com bloqueio
	//---------------------------------------------------------------------------------------------------------------------------
	__lBloq1 := .F.
	__lBloq2 := .F.
	If !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES",""))) .And. M->C5_YLINHA <> "4" .And. !U_FROPVLPV(M->C5_NUM, .F., .F., @__lBloq1, @__lBloq2)

		If __lBloq1
			U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP","Solicite liberação para "+U_FRGERADM(M->C5_NUM)+".",,2,"PEDIDO BLOQUEADO POR REJEIÇÃO DE SUGESTÃO")
		EndIf

		If __lBloq2
			U_FROPMSG("SISTEMA - RESERVA DE ESTOQUE/OP","Solicite liberação para "+U_FCHKATEN(M->C5_NUM)+".",,2,"PEDIDO BLOQUEADO POR LOTE RESTRITO")
		EndIf

	EndIf

	//---------------------------------------------------------------------------------------------------------------------------
	//FERNANDO/FACILE em 24/06/2015 - COMERCIAL - incremento de comissao - enviar workflow
	//---------------------------------------------------------------------------------------------------------------------------
	If CHKFILE("PZ8") .And. PZ8->(FieldPos("PZ8_COMINC")) > 0 .And. SC5->C5_CLIENTE <> "010064"

		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

		_aCabWF := {}
		_aItensWF := {}

		_cA1TpSeg := SA1->A1_YTPSEG

		SC6->(DbSetOrder(1))
		If SC6->(DbSeek(XFilial("SC6")+SC5->C5_NUM))
			While !SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == (XFilial("SC6")+SC5->C5_NUM)

				//buscando a marca do produto
				__cEmpPed := AllTrim(CEMPANT)+AllTrim(CFILANT)
				SB1->(DbSetOrder(1))
				IF SB1->(DbSeek(XFilial("SB1")+SC6->C6_PRODUTO))
					ZZ7->(DbSetOrder(1))
					If ZZ7->(DbSeek(XFilial("ZZ7")+SB1->(B1_YLINHA+B1_YLINSEQ))) .And. !Empty(ZZ7->ZZ7_EMP)
						__cEmpPed := ZZ7->ZZ7_EMP
					EndIf
				ENDIF

				//se tem regra configurado para o representante/segmento/marca
				If !Empty(SC5->C5_VEND1) .And. (SC6->C6_COMIS1 > 0)
					PZ8->(DbSetOrder(1))
					If PZ8->(DbSeek(XFilial("PZ8")+SC5->C5_VEND1+_cA1TpSeg+__cEmpPed))
						While !PZ8->(Eof()) .And. PZ8->(PZ8_FILIAL+PZ8_VEND+PZ8_TPSEG+PZ8_MARCA) == (XFilial("PZ8")+SC5->C5_VEND1+_cA1TpSeg+__cEmpPed)

							//se tem desconto e data valida - incrementa comissao - enviar workflow
							If (dDataBase >= PZ8->PZ8_PERINI .And. dDataBase <= PZ8->PZ8_PERFIM) .And.  (SC6->C6_YDESP <= PZ8->PZ8_MAXDES)

								If ( Empty(PZ8->PZ8_PCGMR3) .Or. SB1->B1_YPCGMR3 $ Replace(PZ8->PZ8_PCGMR3, " ","") ) .And. ( Empty(PZ8->PZ8_GRPVEN) .Or. PZ8->PZ8_GRPVEN == SA1->A1_GRPVEN )

									RecLock("SC6",.F.)
									SC6->C6_COMIS1 := SC6->C6_COMIS1 + PZ8->PZ8_COMINC
									SC6->(MsUnlock())

									aAdd(_aItensWF, {SC6->C6_PRODUTO, SC6->C6_QTDVEN, SC6->C6_PRCVEN, SC6->C6_VALOR, SC6->C6_YPERC, SC6->C6_YDESP, (SC6->C6_COMIS1 - PZ8->PZ8_COMINC), SC6->C6_COMIS1 })

									EXIT

								EndIf

							EndIf

							PZ8->(DbSkip())
						EndDo
					EndIf
				EndIf

				SC6->(DbSkip())
			EndDo
		EndIf

		If Len(_aItensWF) > 0
			SA3->(DbSetOrder(1))
			SA3->(DbSeek(XFilial("SA3")+SC5->C5_VEND1))

			aAdd(_aCabWF, SC5->C5_NUM)
			aAdd(_aCabWF, SA3->A3_NREDUZ)
			aAdd(_aCabWF, SA1->A1_NREDUZ)

			U_FCOMWF01(_aCabWF, _aItensWF)
		EndIf

	EndIf

	//---------------------------------------------------------------------------------------------------------------------------
	//FERNANDO/FACILE em 25/08/2015 - Projeto POLITICA COMERCIAL - Buscar politica e gravar a tabela ZA4 por item
	//---------------------------------------------------------------------------------------------------------------------------

	//cancela todos os registros do ZA4 - pode ter havido alteracoes no pedido
	ZA4->(DbSetOrder(1))
	If ZA4->(DbSeek(XFilial("ZA4")+SC5->C5_NUM))

		While !ZA4->(EOF()) .And. ZA4->(ZA4_FILIAL+ZA4_PEDIDO) == (XFilial("ZA4")+SC5->C5_NUM)

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
	If SC6->(DbSeek(XFilial("SC6")+SC5->C5_NUM))
		While !SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == (XFilial("SC6")+SC5->C5_NUM)

			U_BPOLGZA4()

			SC6->(DbSkip())
		EndDo
	EndIf

	If Inclui .Or. Altera

		RecLock("SC5", .F.)

		SC5->C5_YCATCLI := fRetCatBia(SC5->C5_CLIENTE, SC5->C5_LOJACLI, SC5->C5_YEMP)

		SC5->(MsUnlock())

	EndIf

	//---------------------------------------------------------------------------------------------------------------------------
	//FERNANDO/FACILE em 29/07/2014 - Projeto PEDIDO REPRESENTANTE - Gravar hora final da gravacao de todos os dados do pedido antes da replicacao LM
	//---------------------------------------------------------------------------------------------------------------------------
	If Inclui .And. SC5->(FieldPos("C5_YHORA")) > 0

		RecLock("SC5",.F.)
		SC5->C5_YHORA := SubStr(Time(),1,5)
		SC5->(MsUnlock())

	EndIf

	//---------------------------------------------------------------------------------------------------------------------------
	//FERNANDO/FACILE em 29/07/2014 - Projeto PEDIDO REPRESENTANTE - Replicar pedido para LM Automaticamente
	//---------------------------------------------------------------------------------------------------------------------------
	If (Inclui) .And. AllTrim(CEMPANT) $ "07" .And. Empty(M->C5_YPEDORI) .And. Alltrim(M->C5_TIPO) == "N" //.And. M->C5_YLINHA <> "4" --testando para mundialli - estava sendo replicado manualmente - Fernando em 30/10/15

		///Fernando em 12/04/17 -> repliacacao do pedido para a LM Matriz
		//AllTrim(CFILANT) <> "01" == .T.

		SC6->(DbSetOrder(1))
		SB1->(DbSetOrder(1))
		SC6->(DbSeek(XFilial("SC6")+SC5->C5_NUM))
		SB1->(DbSeek(XFilial("SB1")+SC6->C6_PRODUTO))

		IF SB1->B1_TIPO <> "PR"

			//Não Replica LM => Filial 05
			If (AllTrim(cEmpAnt) <> '07' .Or. (AllTrim(cEmpAnt) == '07' .And. AllTrim(cFilAnt) <> '05') )
				U_FCOMRT01(M->C5_NUM, .T., .F., AllTrim(CFILANT) <> "01" )
			EndIf

			ConOut("M410STTS => PEDIDO: "+M->C5_NUM+", NBloq: "+cvaltochar(nBloq)+",  Data: "+DTOC(dDataBase)+" Hora: "+Time())

			//caso não ocorrer bloqueio
			If (!nBloq)

				_nOpcao := IIF(Inclui,1, IIF(Altera, 2, 0))
				_oConfPedVen := TConferenciaPedidoVenda():New(cEmpAnt, cFilAnt, _nOpcao, CUSERNAME)
				_oConfPedVen:Checar(M->C5_NUM)

				EnvMailCli()

			EndIf


		ENDIF

		//Nao é LM >>> disparar metodo de check e empenho automatico - Fernnado em 04/10/2018
	ElseIf (Inclui .Or. Altera) .And. AllTrim(CEMPANT) <> "07" .And. M->C5_YCONF == "S" .And. AllTrim(M->C5_YAPROV) <> "" .And. ALLTRIM(M->C5_YSUBTP) <> "A"

		//ALLTRIM(M->C5_YSUBTP) $ "N#E"

		If (!nBloq)

			_oEmpAut := TBiaEmpenhoPedido():New()
			_aRetEmp := _oEmpAut:LibPedido(SC5->C5_NUM)
			If (!Empty(_aRetEmp[2]))

				U_FROPMSG("M410STTS - EMPENHO AUTOMATICO","Alerta empenho automático do pedido: "+CRLF+_aRetEmp[2],,2,"Empenho Automático de Pedidos")

			EndIf

		EndIf

		//Fernando em 25/10/19 - alterado a logica destes IF`s, estava estranho e entrando duas vezes para LM - o metodo Checar da conferencia Ja faz empenho automatico se houver
	ElseIf (Inclui .Or. Altera) .And. Alltrim(M->C5_TIPO) == "N"


		SC6->(DbSetOrder(1))
		SB1->(DbSetOrder(1))
		SC6->(DbSeek(XFilial("SC6")+SC5->C5_NUM))

		If(SB1->(DbSeek(XFilial("SB1")+SC6->C6_PRODUTO)))

			If AllTrim(SB1->B1_TIPO) == "PA" .Or. ALLTRIM(SC5->C5_YSUBTP) $ "A_G_B_M"

				ConOut("M410STTS => PEDIDO: "+M->C5_NUM+", NBloq: "+cvaltochar(nBloq)+",  Data: "+DTOC(dDataBase)+" Hora: "+Time())

				If (!nBloq)

					_nOpcao := IIF(Inclui,1, IIF(Altera, 2, 0))
					_oConfPedVen := TConferenciaPedidoVenda():New(cEmpAnt, cFilAnt, _nOpcao, CUSERNAME)
					_oConfPedVen:Checar(M->C5_NUM)

					EnvMailCli()
				EndIf


			EndIf

		EndIf

	EndIf


	//---------------------------------------------------------------------------------------------------------------------------
	//FERNANDO/FACILE em 17/08/2016 - Projeto RODAPE VITCER - Criar pedido BASE automaticamente na empresa origem do piso do Rodape
	//---------------------------------------------------------------------------------------------------------------------------
	//DESTAIVADO EM 21/05/2020 - VITCER FABRICA DE VINILICO
	// If (Inclui) .And. AllTrim(CEMPANT) $ "14" .And. Empty(M->C5_YPEDBAS) .And. Alltrim(M->C5_TIPO) == "N"

	// 	SC6->(DbSetOrder(1))
	// 	ZA6->(DbSetOrder(2))
	// 	If SC6->(DbSeek(XFilial("SC6")+M->C5_NUM)) .And. ZA6->(DbSeek(XFilial("ZA6")+SC6->C6_PRODUTO))
	// 		U_BFATRT01(M->C5_NUM, .T., .F.)
	// 	EndIf
	// EndIf


	//---------------------------------------------------------------------------------------------------------------------------
	//FERNANDO/FACILE em 14/10/2016 - Projeto proposta Engenahria - Vincular pedido a proposta
	//---------------------------------------------------------------------------------------------------------------------------
	If (Inclui .Or. Altera) .And. !Empty(M->C5_YNPRENG)

		__nTabZ68 := "Z68010"
		__nTabZZO := "ZZO010"

		If M->C5_YLINHA <> "1"
			__nTabZ68 := "Z68050"
			__nTabZZO := "ZZO050"
		EndIf

		cSql := "UPDATE "+__nTabZ68+" SET Z68_STATUS = '4', Z68_PEDIDO = '"+M->C5_NUM+"', Z68_SITOBR = '2', Z68_ALTSTA = '"+DTOS(dDataBase)+"' "
		cSql += " WHERE Z68_FILIAL = '"+xFilial("Z68")+"' AND Z68_NUM+Z68_REV = '"+M->C5_YNPRENG+"' AND D_E_L_E_T_ = '' "
		TcSQLExec(cSql)

		cSql := "UPDATE "+__nTabZZO+" set ZZO_STATUS = '2' "
		cSql += " FROM "+__nTabZZO+" ZZO "
		cSql += " JOIN "+__nTabZ68+" Z68 on Z68_FILIAL = ZZO_FILIAL and Z68_NUMZZO = ZZO_NUM "
		cSql += " WHERE Z68_FILIAL = '"+xFilial("Z68")+"' "
		cSql += " AND Z68_NUM+Z68_REV = '"+M->C5_YNPRENG+"' "
		cSql += " AND Z68.D_E_L_E_T_ = '' "
		cSql += " AND ZZO.D_E_L_E_T_ = '' "
		TcSQLExec(cSql)

	EndiF

	// Tiago Rossini Coradini - 15/03/2016 - OS: 1048-16 e 1049-16 - Tratamento para atualizar numero do pedido na tabela de parcelas de contrato Z60
	DbSelectArea("Z60")
	If (Inclui .Or. Altera) .And. Z60->(FieldPos("Z60_CHVTMP")) > 0

		Z60->(DbSetOrder(2))
		If Z60->(DbSeek(xFilial("Z60")+M->C5_YCHVRES)) .And. Z60->Z60_NUMPED <> M->C5_NUM
			RecLock("Z60", .F.)
			Z60->Z60_NUMPED := M->C5_NUM
			Z60->(MsUnlock())
		EndIf

	EndIf

    
    // Gabriel Pinheiro Leite da Silva(G3) - 26/05/2021 - OS:32367 - Configurar para que ao alterar os campos de data do pedido na empresa origem, eles repliquem para o pedido da LM.
    If (Altera) .And. cEmpAnt == '01' //barba

        begincontent var cSql

            UPDATE SC67 
            SET  SC67.C6_ENTREG=SC61.C6_ENTREG
                ,SC67.C6_YDTNERE=SC61.C6_YDTNERE
                ,SC67.C6_YDTNECE=SC61.C6_YDTNECE
            FROM SC6070 SC67
            JOIN SC5070 SC57 ON (SC57.C5_FILIAL=SC67.C6_FILIAL AND SC57.C5_NUM=SC67.C6_NUM)
            JOIN SC5010 SC51 ON (SC57.C5_YPEDORI=SC51.C5_NUM)
            JOIN SC6010 SC61 ON (SC51.C5_FILIAL=SC61.C6_FILIAL AND SC51.C5_NUM=SC61.C6_NUM)
            WHERE   SC57.D_E_L_E_T_=''
                AND SC67.D_E_L_E_T_=''
                AND SC51.D_E_L_E_T_=''
                AND SC61.D_E_L_E_T_=''
                AND SC51.C5_NUM='@C5_NUM'
                AND SC57.C5_YEMP='@C5_YEMP'
                AND SC67.C6_PRODUTO=SC61.C6_PRODUTO
                AND SC67.C6_ITEM=SC61.C6_ITEM
                AND SC51.C5_FILIAL='@C5_FILIAL'

        endcontent

        cSql:=strTran(cSql,"SC5010",retSQLName("SC5"))
        cSql:=strTran(cSql,"SC6010",retSQLName("SC6"))
        cSql:=strTran(cSql,"@C5_NUM",M->C5_NUM)
        cSql:=strTran(cSql,"@C5_YEMP",M->C5_YEMP)
        cSql:=strTran(cSql,"@C5_FILIAL",xFilial("SC5"))

        TCSQLExec(cSql)

    EndIf

	
	//Ticket 36494 - Replicar informação do pedido de compra da LM para Mundi e Biancogres Vinílico
		If (Altera) .And. cEmpAnt == '07' .And. M->C5_YLINHA=='6' //Vinilico
			if M->C5_YLINHA == '6' .AND. AllTrim(M->C5_YSUBTP) == 'E'
				cPedVenda:='SC5140'
				cItempedv:='SC6140'
			Elseif M->C5_YLINHA == '6' .AND. AllTrim(M->C5_YSUBTP) == 'IM'
				cPedVenda:='SC5130'
				cItempedv:='SC6130'
			EndIf

			begincontent var cSql

				UPDATE SC51 
				SET  SC51.C5_YPC = SC57.C5_YPC
				FROM @SC5010 SC51
				JOIN SC5070 SC57 ON (SC57.C5_YPEDORI=SC51.C5_NUM)
				JOIN @SC6010 SC61 ON (SC51.C5_FILIAL=SC61.C6_FILIAL AND SC51.C5_NUM=SC61.C6_NUM)
				WHERE   SC57.D_E_L_E_T_=''
					AND SC51.D_E_L_E_T_=''
					AND SC61.D_E_L_E_T_=''
					AND SC57.C5_NUM='@C5_NUM'
					AND SC57.C5_YEMP='@C5_YEMP'
					AND SC51.C5_FILIAL='@C5_FILIAL'
			endcontent

		// cSql:=strTran(cSql,"SC5010",retSQLName("SC5"))
			cSql:=StrTran(cSql,"@SC5010",cPedVenda)
			cSql:=StrTran(cSql,"@SC6010",cItempedv)
			cSql:=strTran(cSql,"@C5_NUM",M->C5_NUM)
			cSql:=strTran(cSql,"@C5_YEMP",M->C5_YEMP)
			cSql:=strTran(cSql,"@C5_FILIAL",xFilial("SC5"))

			TCSQLExec(cSql)

   		EndIf 

	// Tiago Rossini Coradini - 26/09/2016 - OS: 3229-16 - Ranisses Corona - Desativa controle de semaforo ao final da rotina
	Leave1Code("SC5" + cEmpAnt + cFilAnt + SC5->C5_NUM)



Return()

/*/{Protheus.doc} fBloqPV
@description Funcao para avaliar os Descontos e Margens praticados no Pedido de Venda submentendo a aprovacao
@author Ranisses A. Corona
@since 16/05/12
@version 1.0
@type function
/*/
User Function fBloqPV()
	Local lPassou	:= .F.      //Variavel que informa se o pedido será ou não bloqueado
	Local nTpBlq	:= "0"		//Variavel para gravar o Tipo de Bloqueio/Liberacao do Pedido
	Local cTrabZA9	:= ""		//
	Local nSubTp	:= Tabela("DJ",Alltrim(SC5->C5_YSUBTP))
	Local aAprov	:= {}		//Retorno Aprovador Final, comparando o Aprovador 1 e 2
	Local aAprvRg1	:= {}		//Retorno Aprovador da Regra 1
	Local aAprvRg2	:= {}		//Retorno Aprovador da Regra 2
	Local _cCmpVer
	Local _cCmpExcl
	Local nSA1		:= Iif(Alltrim(M->C5_YEMP) $ "0101_1401","SA1010" ,"SA1050")

	If lCheckPV

		//Campos do desconto de verda e AI - Fernando em 23/02/17
		_cCmpVer := "% 0 DVER, 0 DACO %"
		If SC6->(FieldPos("C6_YDACO")) > 0
			_cCmpVer := "% MAX(C6_YDVER) DVER, MAX(C6_YDACO) DACO %"
		EndIf

		_cCmpExcl := "% 'N' BLOQ_EXCL %"
		If (SB1->(FieldPos("B1_YEXCL"))) > 0

			_cCmpExcl := "% CASE WHEN (SELECT COUNT(*) "
			_cCmpExcl += " 	FROM "+RetSQLName("SC6")+" A "
			_cCmpExcl += " 	JOIN "+RetSQLName("SB1")+" B on B1_COD = C6_PRODUTO "
			_cCmpExcl += " 	JOIN (SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_YCAT "
			_cCmpExcl += " 			FROM "+nSA1+" "
			_cCmpExcl += " 			WHERE D_E_L_E_T_='') C on A1_COD = C6_CLI and A1_LOJA = C6_LOJA "
			_cCmpExcl += " 	WHERE 	C6_FILIAL	= '"+XFILIAL("SC6")+"' "
			_cCmpExcl += " 	AND C6_NUM 		= '"+M->C5_NUM+"' "
			_cCmpExcl += " 	AND B1_YEXCL = 'E' and A1_YCAT <> 'LOJA ESPEC' "
			_cCmpExcl += " 	AND A.D_E_L_E_T_ = '' "
			_cCmpExcl += " 	AND B.D_E_L_E_T_= '') > 0 THEN 'S' ELSE 'N' END BLOQ_EXCL %"

		EndIf

		//Carrega tabela Roteiro de Desconto
		cTrabZA9 := GetNextAlias()
		BeginSql Alias cTrabZA9
			SELECT *
			FROM %Table:ZA9%
			WHERE	ZA9_FILIAL	= %xFilial:ZA9%		AND
			ZA9_MARCA	= %Exp:M->C5_YEMP%	AND 
			ZA9_MSBLQD	= ''				AND
			%NOTDEL%
			ORDER BY ZA9_ORDEM
		EndSql

		//Calcula Media do Desconto Padrão e Realizada - Gravação de Campos legados no SC5
		//Campos para usar nas formulas das regras de bloqueio comercial - tabela ZA9
		BeginSql Alias "cTrabSC6"
			%noparser%    

			SELECT 	DESCORI = CASE WHEN SUM(C6_YPRCTAB*C6_QTDVEN) > 0 THEN ISNULL(ROUND(SUM(C6_YDESCLI*(C6_YPRCTAB*C6_QTDVEN))/SUM(C6_YPRCTAB*C6_QTDVEN),2),0) ELSE 0 END,	
			DESCREA = CASE WHEN SUM(C6_YPRCTAB*C6_QTDVEN) > 0 THEN ISNULL(ROUND(SUM(C6_YDESC*(C6_YPRCTAB*C6_QTDVEN))/SUM(C6_YPRCTAB*C6_QTDVEN),2),0) ELSE 0 END, 
			ISNULL(SUM(C6_VALDESC),0) AS DESCINC,
			ISNULL(MAX(SUBSTRING(C6_PRODUTO,8,1)),0) AS CLASSE,
			%Exp:cEmpAnt% AS EMPRESA,
			PRODPA = CASE WHEN SUBSTRING(MAX(C6_PRODUTO),1,1) >= 'A' THEN 1 ELSE 0 END, 
			MAX(C6_YDESP) DESCONTO, 
			MARGEM = CASE WHEN SUM(C6_VALOR) > 0 THEN SUM(C6_VALOR*C6_YPERCMC)/SUM(C6_VALOR) ELSE 0 END,
			SUM(C6_QTDVEN) VOLUME,
		CASE WHEN EXISTS(SELECT 1 FROM %Table:ZA6% ZA6 WHERE ZA6_RODAPE in ( select C6_PRODUTO from %Table:SC6% X where X.C6_NUM = %Exp:M->C5_NUM% and X.D_E_L_E_T_='' ) AND ZA6.D_E_L_E_T_='') THEN 'S' ELSE 'N' END RODAPE
			,%Exp:_cCmpVer%
			,%Exp:_cCmpExcl%
			FROM %Table:SC6%
			WHERE 	C6_FILIAL	= %xFilial:SC6% 	AND 
			C6_NUM 		= %Exp:M->C5_NUM% 	AND 
			%NOTDEL%

		EndSql

		//Posiciona Condicao de Pagamento
		SE4->(DbSetOrder(1))
		SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))

		(cTrabZA9)->(DbGoTop())
		While !(cTrabZA9)->(Eof()) .And. !lPassou

			If (cTrabZA9)->&(ZA9_REGRA)


				//Executa Regra do Aprovador 1
				aAprvRg1	:= fAprov((cTrabZA9)->ZA9_MARCA,(cTrabZA9)->ZA9_APROV1,cTrabSC6->DESCONTO,cTrabSC6->MARGEM,M->C5_CLIENTE,M->C5_LOJACLI,M->C5_VEND1)

				//Executa Regra do Aprovador 2
				aAprvRg2	:= fAprov((cTrabZA9)->ZA9_MARCA,(cTrabZA9)->ZA9_APROV2,cTrabSC6->DESCONTO,cTrabSC6->MARGEM,M->C5_CLIENTE,M->C5_LOJACLI,M->C5_VEND1)

				//Compara o retorno das aprovações, e matém o Aprovador de maior importancia (nivel mais baixo)
				If aAprvRg1[1] .Or. aAprvRg2[1]
					If aAprvRg1[4] < aAprvRg2[4]
						aAprov	:= aAprvRg1
						lPassou	:= aAprvRg1[1]
					Else
						aAprov	:= aAprvRg2
						lPassou	:= aAprvRg2[1]
					End
				Else
					aAprov 	:= aAprvRg1
					lPassou	:= !aAprvRg1[1]
				EndIf

			EndIf

			If !lPassou
				(cTrabZA9)->(DbSkip())
			EndIf

		EndDo

		//Define o Tipo de Bloqueio/Liberacao
		If (cTrabZA9)->ZA9_TPBLQ <> "9"
			nTpBlq := Iif(aAprov[4]=="999","0",(cTrabZA9)->ZA9_TPBLQ)
		Else
			nTpBlq := (cTrabZA9)->ZA9_TPBLQ
		EndIf

	Else

		aAprov	:= fAprov(M->C5_YEMP,"",0,0,M->C5_CLIENTE,M->C5_LOJACLI,M->C5_VEND1)

	EndIf

	//Verifica se o pedido será Bloqueado ou Liberado
	If aAprov[1]

		If Empty(Alltrim(aAprov[4]))
			MsgBox("Este pedido será bloqueado, pois não foi encontrado aprovador!"+Chr(10)+Chr(13)+"Favor informar ao seu Atendente ou Gerente Comercial!","M410STTS","STOP")
		Else
			MsgBox((cTrabZA9)->(ZA9_MSGBLQ)+ IIf(nTpBlq=="5"," ("+ nSubTp +")","") +Chr(10)+Chr(13)+"Favor solicitar ao "+IIf(aAprov[4]=="1",Alltrim(aAprov[5]),"Sr(a). "+Alltrim(aAprov[3]))+" liberar este pedido!","M410STTS","STOP")
		EndIf

		//Atualiza SC5
		cSql := "UPDATE "+RetSqlName("SC5")+" SET C5_YTPBLQ = '"+nTpBlq+"', C5_YAAPROV = '"+Upper(Substr(Alltrim(aAprov[3]),1,15))+"', C5_YAPROV = '               ', C5_YMDESPD = '"+Alltrim(Str(cTrabSC6->DESCORI))+"', C5_YMEDDES = '"+Alltrim(Str(cTrabSC6->DESCREA))+"', "
		If  Inclui
			cSql += " C5_YDIGP = '"+Substr(Alltrim(cUserName),1,15)+"', "
		EndIf
		cSql += " C5_YALTP = '"+Substr(Alltrim(cUserName),1,15)+"' "
		cSql += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = '"+SC5->C5_NUM+"' AND D_E_L_E_T_ = '' "
		TcSQLExec(cSql)

		//Atualiza SC6
		cSql := "UPDATE "+RetSqlName("SC6")+" SET C6_BLQ = 'S', C6_BLOQUEI = 'S', C6_MSEXP = '' WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+M->C5_NUM+"' AND C6_BLQ <> 'R' AND D_E_L_E_T_ = '' "
		TcSQLExec(cSql)

		// Tiago Rossini Coradini - 03/08/2017 - OS: 4538-16 - Inclui bloqueio comercial do pedido de venda
		U_BIAF082(M->C5_NUM, aAprov[2], Upper(Substr(Alltrim(aAprov[3]),1,15)), (aAprov[4] <> "1"))

	Else
		If lCheckPV //ATENCAO - Apenas desbloqueia o pedido, o mesmo sofreu algum tipo de alteracao.

			//Atualiza SC5
			cSql := "UPDATE "+RetSqlName("SC5")+" SET C5_YTPBLQ = '"+nTpBlq+"', C5_YAAPROV = '"+Upper(Substr(Alltrim(aAprov[3]),1,15))+"', C5_YAPROV = '"+Upper(Substr(Alltrim(aAprov[3]),1,15))+"', C5_YMDESPD = '"+Alltrim(Str(cTrabSC6->DESCORI))+"', C5_YMEDDES = '"+Alltrim(Str(cTrabSC6->DESCREA))+"', "
			If  Inclui
				cSql += " C5_YDIGP = '"+Substr(Alltrim(cUserName),1,15)+"', "
			EndIf
			cSql += " C5_YALTP = '"+Substr(Alltrim(cUserName),1,15)+"' "
			cSql += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = '"+M->C5_NUM+"' AND D_E_L_E_T_ = '' "
			TcSQLExec(cSql)

			//Atualiza SC6
			cSql := "UPDATE "+RetSqlName("SC6")+" SET C6_BLQ = 'N', C6_BLOQUEI = '', C6_MSEXP = '' WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+M->C5_NUM+"' AND C6_BLQ <> 'R' AND D_E_L_E_T_ = '' "
			TcSQLExec(cSql)

			// Tiago Rossini Coradini - 03/08/2017 - OS: 4538-16 - Exclui bloqueio comercial do pedido de venda
			U_BIAF083(M->C5_NUM)

		EndIf
	ENDIF

	If chkfile("cTrabSC6")
		DbSelectArea("cTrabSC6")
		DbCloseArea()
	EndIf

	If !Empty(cTrabZA9)
		dbSelectArea((cTrabZA9))
		dbCloseArea()
	EndIf

Return(aAprov[1])


//Funcao para Definir Aprovador 
Static Function fAprov(cEmp,cTipo,nDesc,nMargem,cCli,cLoja,cVend)
	Local cTmpSZM	:= "" //Tabela Temporário SZM - Aprovadores
	Local nZZI		:= Iif(Alltrim(cEmp) $ "0101_0199_1401","%ZZI010%" ,"%ZZI050%")
	Local nSA1		:= Iif(Alltrim(cEmp) $ "0101_0199_1401","%SA1010%" ,"%SA1050%")
	Local nTotReg	:= 0 //Total de Aprovadores

	Local lBloq		:= .F.
	Local nCodAprv	:= __cUserId
	Local nNomAprv	:= cUserName
	Local nNivel	:= "999"
	Local nDescNiv	:= "PADRAO"
	Local aRet		:= {}

	//Se for Bloqueio por Desconto
	If Alltrim(cTipo) == "D"

		If nDesc > 0

			//Busca Aprovador de acordo com Faixa de Desconto
			cTmpSZM	:= GetNextAlias()
			BeginSql Alias cTmpSZM
				SELECT ZM_CODAPRO AS CODAPRO, ZM_NIVEL, ZM_DESCNIV 
				FROM %Table:SZM% 
				WHERE 	ZM_FILIAL	= %xFilial:SZM% AND 
				ZM_MARCA	= %Exp:cEmp% 	AND	
				%Exp:nDesc% BETWEEN ZM_DESCINI AND ZM_DESCFIM AND 
				%NOTDEL%
			EndSql

			nTotReg := Contar(cTmpSZM,"!Eof()")

			//Se retornar mais de um Aprovador, procura por Tipo Segmento
			If nTotReg > 1

				//Feche arquivo, para criacao de um novo.
				(cTmpSZM)->(dbCloseArea())

				cTmpSZM	:= GetNextAlias()
				BeginSql Alias cTmpSZM
					SELECT ZM_CODAPRO AS CODAPRO, ZM_NIVEL, ZM_DESCNIV 
					FROM %Table:SZM% 
					WHERE 	ZM_FILIAL	= %xFilial:SZM% 			AND 
					ZM_MARCA	= %Exp:cEmp% 				AND	
					%Exp:nDesc% BETWEEN ZM_DESCINI AND ZM_DESCFIM AND
					ZM_CODAPRO IN	(SELECT A3_CODUSR AS CODAPRO
					FROM %EXP:nZZI% ZZI INNER JOIN %Table:SA3% SA3 ON
					ZZI.ZZI_GERENT = SA3.A3_COD	
					WHERE	ZZI.ZZI_VEND   = %Exp:cVend%		AND
					ZZI.ZZI_TPSEG  IN	(SELECT A1_YTPSEG 
					FROM %EXP:nSA1% 
					WHERE	A1_FILIAL	= %xFilial:SA1% AND 
					A1_COD 		= %EXP:cCli% AND 
					A1_LOJA 	= %EXP:cLoja% AND 
					%NOTDEL%) 		AND
					ZZI.%NOTDEL%								AND
					SA3.%NOTDEL%)	AND		
					%NOTDEL%	
				EndSql

			EndIf

			(cTmpSZM)->(dbGoTop())
			If !(cTmpSZM)->(Eof())
				lBloq		:=	.T.
				nCodAprv 	:=	(cTmpSZM)->CODAPRO
				nNomAprv	:=	UsrRetName(nCodAprv)
				nNivel		:=	(cTmpSZM)->ZM_NIVEL
				nDescNiv	:=	(cTmpSZM)->ZM_DESCNIV
			Else
				lBloq		:=	.T.
				nCodAprv 	:=	""
				nNomAprv	:=	"SEM LIBERADOR"
				nNivel		:=	""
				nDescNiv	:=	"SEM NIVEL"
			EndIf

		EndIf

		//Se for Bloqueio por Margem
	ElseIf Alltrim(cTipo) == "M"

		If nMargem <> 0

			//Busca Aprovador
			cTmpSZM := GetNextAlias()
			BeginSql Alias cTmpSZM
				%NoParser%

				SELECT ZM_CODAPRO AS CODAPRO, ZM_NIVEL, ZM_DESCNIV
				FROM %Table:SZM% 
				WHERE 	ZM_FILIAL	= %xFilial:SZM% AND 
				ZM_MARCA	= %Exp:cEmp% 	AND	
				%Exp:nMargem% BETWEEN ZM_MARGINI AND ZM_MARGFIM AND 
				%NOTDEL%	
			EndSql

			//Se retornar mais de um Aprovador, procura por Tipo Segmento
			nTotReg := Contar(cTmpSZM,"!Eof()")

			//Se retornar mais de um Aprovador, procura por Tipo Segmento
			If nTotReg > 1

				//Feche arquivo, para criacao de um novo.
				(cTmpSZM)->(dbCloseArea())

				cTmpSZM	:= GetNextAlias()
				BeginSql Alias cTmpSZM
					%NoParser%

					SELECT ZM_CODAPRO AS CODAPRO, ZM_NIVEL, ZM_DESCNIV 
					FROM %Table:SZM% 
					WHERE 	ZM_FILIAL	= %xFilial:SZM% 			AND 
					ZM_MARCA	= %Exp:cEmp% 				AND	
					%Exp:nDesc% BETWEEN ZM_MARGINI AND ZM_MARGFIM AND
					ZM_CODAPRO IN	(SELECT A3_CODUSR AS CODAPRO
					FROM %EXP:nZZI% ZZI INNER JOIN %Table:SA3% SA3 ON
					ZZI.ZZI_GERENT = SA3.A3_COD	
					WHERE	ZZI.ZZI_VEND   = %Exp:cVend%		AND
					ZZI.ZZI_TPSEG  IN	(SELECT A1_YTPSEG 
					FROM %EXP:nSA1% 
					WHERE	A1_FILIAL	= %xFilial:SA1% AND 
					A1_COD 		= %EXP:cCli% AND 
					A1_LOJA 	= %EXP:cLoja% AND 
					%NOTDEL%) 		AND
					ZZI.%NOTDEL%								AND
					SA3.%NOTDEL%)	AND		
					%NOTDEL%	
				EndSql

			EndIf

			(cTmpSZM)->(dbGoTop())
			If !(cTmpSZM)->(Eof())
				lBloq		:=	.T.
				nCodAprv 	:=	(cTmpSZM)->CODAPRO
				nNomAprv	:=	UsrRetName(nCodAprv)
				nNivel		:=	(cTmpSZM)->ZM_NIVEL
				nDescNiv	:=	(cTmpSZM)->ZM_DESCNIV
			Else
				lBloq		:=	.T.
				nCodAprv 	:=	""
				nNomAprv	:=	"SEM LIBERADOR"
				nNivel		:=	""
				nDescNiv	:=	"SEM NIVEL"
			EndIf

		EndIf

		//Demais bloqueios
	Else

		If !Empty(Alltrim(cTipo))

			cTmpSZM	:= GetNextAlias()
			BeginSql Alias cTmpSZM
				%NoParser%

				SELECT ZM_CODAPRO AS CODAPRO, ZM_NIVEL, ZM_DESCNIV 
				FROM %Table:SZM% 
				WHERE	ZM_FILIAL 	= %xFilial:SZM% AND 
				ZM_MARCA	= %Exp:cEmp% 	AND 
				ZM_NIVEL 	= %Exp:cTipo% 	AND 
				%NOTDEL%
			EndSql

			//Se retornar mais de um Aprovador, procura por Tipo Segmento
			nTotReg := Contar(cTmpSZM,"!Eof()")

			//Se retornar mais de um Aprovador, procura por Tipo Segmento
			If nTotReg > 1

				//Feche arquivo, para criacao de um novo.
				(cTmpSZM)->(dbCloseArea())

				cTmpSZM	:= GetNextAlias()
				BeginSql Alias cTmpSZM
					%NoParser%

					SELECT ZM_CODAPRO AS CODAPRO, ZM_NIVEL, ZM_DESCNIV 
					FROM %Table:SZM% 
					WHERE	ZM_FILIAL 	= %xFilial:SZM% AND 
					ZM_MARCA	= %Exp:cEmp% 	AND 
					ZM_NIVEL 	= %Exp:cTipo% 	AND 
					ZM_CODAPRO IN	(SELECT A3_CODUSR AS CODAPRO
					FROM %EXP:nZZI% ZZI INNER JOIN %Table:SA3% SA3 ON
					ZZI.ZZI_GERENT = SA3.A3_COD	
					WHERE	ZZI.ZZI_VEND   = %Exp:cVend%		AND
					ZZI.ZZI_TPSEG  IN	(SELECT A1_YTPSEG 
					FROM %EXP:nSA1% 
					WHERE	A1_FILIAL	= %xFilial:SA1% AND 
					A1_COD 		= %EXP:cCli% AND 
					A1_LOJA 	= %EXP:cLoja% AND 
					%NOTDEL%) 		AND
					ZZI.%NOTDEL%								AND
					SA3.%NOTDEL%)	AND		
					%NOTDEL%
				EndSql


			End

			(cTmpSZM)->(dbGoTop())
			If !(cTmpSZM)->(Eof())
				lBloq		:=	.T.
				nCodAprv 	:=	(cTmpSZM)->CODAPRO
				nNomAprv	:=	UsrRetName(nCodAprv)
				nNivel		:=	(cTmpSZM)->ZM_NIVEL
				nDescNiv	:=	(cTmpSZM)->ZM_DESCNIV
			EndIf

		EndIf

	EndIf

	AADD(aRet,lBloq)
	AADD(aRet,nCodAprv)
	AADD(aRet,nNomAprv)
	AADD(aRet,nNivel)
	AADD(aRet,nDescNiv)

	If !Empty(cTmpSZM)
		dbSelectArea((cTmpSZM))
		dbCloseArea()
	EndIf

Return(aRet)



Static Function EnvMailCli()


	If (__lEnvMail)

		DbSelectArea('SC5')
		SC5->(DbSetOrder(1))

		If (SC5->(DbSeek(xFilial('SC5')+SC5->C5_NUM)))

			SEMAIL := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_YEMAIL")

			cEmpPed := cEmpAnt

			If !Empty(SC5->C5_YEMPPED)
				cEmpPed := M->C5_YEMPPED
			EndIf

			// If Substr(SC5->C5_NUM,1,1) == "R" .And. SC5->C5_TIPO == "N" .And. Alltrim((_SC5)->C5_YAPROV) <> "" .AND. SEMAIL == "S" .AND. (SC5->C5_YENVIO <> "S")
			If SC5->C5_YCONF == "S" .And. SC5->C5_TIPO == "N" .AND. SEMAIL == "S" .AND. (SC5->C5_YENVIO <> "S") //.And. Alltrim((_SC5)->C5_YAPROV) <> ""

				// Não envia e-mail para a JK
				If cEmpAnt <> "06"

					If 	Upper(AllTrim(getenvserver())) == "PRODUCAO" .OR.;
							Upper(AllTrim(getenvserver())) == "REMOTO" .OR.;
							Upper(AllTrim(getenvserver())) == "DEV-IPI" .OR.;							
							Upper(AllTrim(getenvserver())) == "FACILE-PROD-FERNANDO" .OR.;
							Upper(AllTrim(getenvserver())) == "COMP-FERNANDO-TESTE-FIN"

						U_Env_Pedido(SC5->C5_NUM,,,cEmpPed)

						IF (SC5->C5_YENVIO <> "S")
							U_GravaPZ2(SC5->(RecNo()),"SC5",SC5->C5_YEMPPED+SC5->C5_NUM,"ENV_PED_1",AllTrim(FunName()),"ENV", CUSERNAME)
						ENDIF

					EndIf

					//Fernando/Facile em 02/09 - atualizar data das reservas de acordo com vencimento dodo boleto antecipado
					U_FR2VLRES(SC5->C5_NUM)
				EndIf

				IF (SC5->C5_YENVIO <> "S")
					U_GravaPZ2(SC5->(RecNo()),"SC5",SC5->C5_YEMPPED+SC5->C5_NUM,"ENV_PED_2",AllTrim(FunName()),"ENV", CUSERNAME)
				ENDIF

			EndIf


		EndIf

	EndIf

Return


Static Function fRetCatBia(cCodCli, cLojCli, cMarca)
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := "SELECT CAT=[dbo].[GET_CATEGORIA_CLIENTE] ('"+cMarca+"','"+cCodCli+"','"+cLojCli+"')"

	TcQuery cSQL New Alias (cQry)

	cRet := (cQry)->CAT

	(cQry)->(dbCloseArea())

Return(cRet)
