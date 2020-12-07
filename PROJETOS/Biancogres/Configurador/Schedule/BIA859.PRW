#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"'

/*/{Protheus.doc} BIA859
@author Ranisses A. Corona
@since 08/11/2013
@version 1.0
@description Rotina para atualizar o status dos Pedidos de Venda, com forma de pagamento de RA.   
@history 02/01/2017, Ranisses A. Corona, Correção para pedidos liberados no mesmo dia, com títulos de RA vencidos. Neste caso o sistema irá estonar o item liberado. Ticket 1306
@type function
/*/

User Function BIA859(nCli,nLoja)
	Local aArea 	:= GetArea()
	Local lDebug	:= .F.
	Local x

	//Tratamento especial para Replicacao de reajuste de preço
	If (IsInCallStack("U_M410RPRC")) .OR. (AllTrim(FunName()) == "RPC")
		Return Nil
	EndIf

	If Empty(Alltrim(nCli)) .AND. !lDebug

		xv_Emps    := U_BAGtEmpr("01_05_13_14") //NÃO PRECISA ANALISAR RA NA LM, POIS A QUERY CONTEMPLA
		//xv_Emps    := U_BAGtEmpr("13")

		For x := 1 to Len(xv_Emps)

			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv(xv_Emps[x,1], xv_Emps[x,2])

			ConOut("HORA: "+TIME()+" - BIA859 - ESTORNO PEDIDOS DE RA SEM SALDO - INICIO " + xv_Emps[x,1])

			Processa({||WK_BIA859('','')})

			ConOut("HORA: "+TIME()+" - BIA859 - ESTORNO PEDIDOS DE RA SEM SALDO - FIM " + xv_Emps[x,1])

			//Finaliza o ambiente criado
			RpcClearEnv()

		Next
		
		RPCSetType(3)
		WfPrepEnv('07', '05')
			ConOut("HORA: "+TIME()+" - BIA859 - ESTORNO PEDIDOS DE RA SEM SALDO - INICIO 07")
			Processa({||WK_BIA859('','')})
			ConOut("HORA: "+TIME()+" - BIA859 - ESTORNO PEDIDOS DE RA SEM SALDO - FIM 07")
		RpcClearEnv()

	Else

		If lDebug
			nCli	   := "011647"
			nLoja	   := "01"

			//Inicializa o ambiente
			RPCSetType(3)
			WfPrepEnv("01","01")
		EndIf

		ConOut("HORA: "+TIME()+" - BIA859 - VALIDA SALDO MANUALMENTE - INICIO "  )

		Processa({||WK_BIA859(nCli,nLoja)})

		ConOut("HORA: "+TIME()+" - BIA859 - VALIDA SALDO MANUALMENTE - FIM "  )


		If lDebug
			//Finaliza o ambiente criado
			RpcClearEnv()
		EndIf

	EndIf

	RestArea(aArea)

Return

//--------------------------------------------------------------------------
//EXECUTA FUNCAO QUE GERA E ENVIA OS RELATÓRIOS
//--------------------------------------------------------------------------
Static Function WK_BIA859(xCli,xLoja)
	Local nDias		:= GetMv("MV_YDIASRA")  //
	Local cSql		:= ""					//
	Local Enter		:= CHR(13)+CHR(10)		//
	Local nSaldo	:= 0 					//Saldo de RA do Cliente/Grupo
	Local nCli		:= ""
	Local nLM		:= .F.
	Local cTimeAtu	:= Time()
	Local cCli		:= xCli
	Local cLj		:= xLoja

	//Seleciona pedidos liberados para Analise
	cSql := "SELECT	SALDO_PEDIDO = CASE 																	" + Enter
	cSql += "						WHEN C5_YCLIORI = '' THEN ROUND(C9_QTDLIB/C6_QTDVEN*VLRIMP_ORI,2) 		" + Enter
	cSql += "						ELSE ROUND(C9_QTDLIB/C6_QTDVEN*VLRIMP_LM,2)								" + Enter
	cSql += "						END, 																	" + Enter
	cSql += "		DATEDIFF(D,ISNULL(VENCT_PR,C9_DATALIB),CONVERT(VARCHAR,GETDATE(),112)) DIAS_ABERTO,  *	" + Enter
	cSql += "FROM																							" + Enter
	
	If (AllTrim(cEmpAnt)+AllTrim(cFilAnt) == '0705')
		cSql += "(SELECT C5_CONDPAG=SC5.C5_CONDPAG, C9_PEDIDO, C9_CLIENTE, C9_LOJA, C9_DATALIB, C9_PRODUTO, C9_ITEM, C9_SEQUEN, C9_QTDLIB, C6_QTDVEN, SC5.C5_YCLIORI, SC5.C5_YLOJORI,	" + Enter
		cSql += "		CLIENTE = CASE	WHEN SC5.C5_YCLIORI = '' THEN SC5.C5_CLIENTE ELSE SC5.C5_YCLIORI END,	" + Enter
		cSql += "		LOJA	= CASE	WHEN SC5.C5_YLOJORI = '' THEN SC5.C5_LOJACLI ELSE SC5.C5_YLOJORI END,	" + Enter
		
		cSql += "		SC9.R_E_C_N_O_ AS RECNO, 													" + Enter
		cSql += "		C6_YVLIMP VLRIMP_ORI,														" + Enter
		cSql += "		RA_PROV = (SELECT ISNULL(SUM(E1_SALDO),0) FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND E1_YCLASSE = '6' AND E1_PEDIDO = SC5.C5_NUM AND D_E_L_E_T_ = '') ,														" + Enter
		cSql += "		RA_EFET = (SELECT ISNULL(SUM(E1_SALDO),0) FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '"+xFilial("SE1")+"'  AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND E1_TIPO = 'RA' AND E1_PEDIDO = SC5.C5_NUM AND D_E_L_E_T_ = ''), 														" + Enter
		cSql += "		RA_SEMPD = (SELECT ISNULL(SUM(E1_SALDO),0) FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND E1_TIPO = 'RA' AND E1_PEDIDO = '' AND D_E_L_E_T_ = '') 	,													" + Enter
		cSql += "		VENCT_PR  = (SELECT E1_VENCTO FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND E1_YCLASSE = '6' AND E1_PEDIDO = SC5.C5_NUM  AND D_E_L_E_T_ = '') , 															" + Enter
		
		cSql += "		ISNULL((SELECT C6_YVLIMP FROM SC6070 WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = SC5.C5_NUM AND C6_PRODUTO = SC6.C6_PRODUTO AND C6_ITEM = SC6.C6_ITEM AND D_E_L_E_T_ = ''),0) VLRIMP_LM " + Enter
	Else
	
		cSql += "(SELECT ISNULL(SC5_07.C5_CONDPAG,SC5.C5_CONDPAG) C5_CONDPAG, C9_PEDIDO, C9_CLIENTE, C9_LOJA, C9_DATALIB, C9_PRODUTO, C9_ITEM, C9_SEQUEN, C9_QTDLIB, C6_QTDVEN, SC5.C5_YCLIORI, SC5.C5_YLOJORI,	" + Enter
		cSql += "		CLIENTE = CASE	WHEN SC5.C5_YCLIORI = '' THEN SC5.C5_CLIENTE ELSE SC5.C5_YCLIORI END,	" + Enter
		cSql += "		LOJA	= CASE	WHEN SC5.C5_YLOJORI = '' THEN SC5.C5_LOJACLI ELSE SC5.C5_YLOJORI END,	" + Enter
		//cSql += "		DATEDIFF(D,C9_DATALIB,GETDATE()) DIAS_ABERTO, 								" + Enter
		cSql += "		SC9.R_E_C_N_O_ AS RECNO, 													" + Enter
		cSql += "		C6_YVLIMP VLRIMP_ORI,														" + Enter
		cSql += "		RA_PROV = CASE 														" + Enter
		cSql += "						WHEN SC5.C5_YCLIORI = '' THEN (SELECT ISNULL(SUM(E1_SALDO),0) FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND E1_YCLASSE = '6' AND E1_PEDIDO = SC5.C5_NUM AND D_E_L_E_T_ = '') 	" + Enter
		cSql += "						ELSE (SELECT ISNULL(SUM(E1_SALDO),0) FROM SE1070 WHERE E1_FILIAL = '01' AND E1_CLIENTE = SC5_07.C5_CLIENTE AND E1_LOJA = SC5_07.C5_LOJACLI AND E1_YCLASSE = '6' AND E1_PEDIDO = SC5_07.C5_NUM AND D_E_L_E_T_ = '') 													" + Enter
		cSql += "					END,															" + Enter
		cSql += "		RA_EFET = CASE 														" + Enter
		cSql += "						WHEN SC5.C5_YCLIORI = '' THEN (SELECT ISNULL(SUM(E1_SALDO),0) FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '"+xFilial("SE1")+"'  AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND E1_TIPO = 'RA' AND E1_PEDIDO = SC5.C5_NUM AND D_E_L_E_T_ = '') 	" + Enter
		cSql += "						ELSE (SELECT ISNULL(SUM(E1_SALDO),0) FROM SE1070 WHERE E1_FILIAL = '01' AND E1_CLIENTE = SC5_07.C5_CLIENTE AND E1_LOJA = SC5_07.C5_LOJACLI AND E1_TIPO = 'RA' AND E1_PEDIDO = SC5_07.C5_NUM AND D_E_L_E_T_ = '') 													" + Enter
		cSql += "					END,															" + Enter
		cSql += "		RA_SEMPD = CASE 														" + Enter
		cSql += "						WHEN SC5.C5_YCLIORI = '' THEN (SELECT ISNULL(SUM(E1_SALDO),0) FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND E1_TIPO = 'RA' AND E1_PEDIDO = '' AND D_E_L_E_T_ = '') 	" + Enter
		cSql += "						ELSE (SELECT ISNULL(SUM(E1_SALDO),0) FROM SE1070 WHERE E1_FILIAL = '01' AND E1_CLIENTE = SC5_07.C5_CLIENTE AND E1_LOJA = SC5_07.C5_LOJACLI AND E1_TIPO = 'RA' AND E1_PEDIDO = '' AND D_E_L_E_T_ = '') 													" + Enter
		cSql += "					END,															" + Enter
		cSql += "		VENCT_PR  = CASE 															" + Enter
		cSql += "						WHEN SC5.C5_YCLIORI = '' THEN (SELECT E1_VENCTO FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND E1_YCLASSE = '6' AND E1_PEDIDO = SC5.C5_NUM  AND D_E_L_E_T_ = '') 	" + Enter
		cSql += "						ELSE (SELECT E1_VENCTO FROM SE1070 WHERE E1_FILIAL = '01' AND E1_CLIENTE = SC5_07.C5_CLIENTE AND E1_LOJA = SC5_07.C5_LOJACLI AND E1_YCLASSE = '6' AND E1_PEDIDO = SC5_07.C5_NUM AND D_E_L_E_T_ = '') 													" + Enter
		cSql += "					END,															" + Enter
		cSql += "		ISNULL((SELECT C6_YVLIMP FROM SC6070 WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = SC5_07.C5_NUM AND C6_PRODUTO = SC6.C6_PRODUTO AND C6_ITEM = SC6.C6_ITEM AND D_E_L_E_T_ = ''),0) VLRIMP_LM " + Enter
		
	EndIf
	
	cSql += "FROM "+RetSqlName("SC9")+" SC9 INNER JOIN "+RetSqlName("SC6")+" SC6 ON " + Enter
	cSql += "		C9_PEDIDO	= C6_NUM	AND					" + Enter
	cSql += "		C9_CLIENTE	= C6_CLI	AND 				" + Enter
	cSql += "		C9_LOJA		= C6_LOJA	AND					" + Enter
	cSql += "		C9_ITEM		= C6_ITEM						" + Enter
	cSql += "		INNER JOIN "+RetSqlName("SC5")+" SC5 ON		" + Enter
	cSql += "		C9_PEDIDO	= C5_NUM		AND				" + Enter
	cSql += "		C9_CLIENTE	= C5_CLIENTE	AND 			" + Enter
	cSql += "		C9_LOJA		= C5_LOJACLI					" + Enter
	cSql += "		INNER JOIN "+RetSqlName("SE4")+" SE4 ON		" + Enter
	cSql += "		C5_CONDPAG  = E4_CODIGO						" + Enter
	cSql += "		INNER JOIN "+RetSqlName("SF4")+" SF4 ON		" + Enter
	cSql += "		C6_TES      = F4_CODIGO						" + Enter
	
	If (AllTrim(cEmpAnt)+AllTrim(cFilAnt) != '0705')
		cSql += "		LEFT JOIN SC5070 SC5_07 ON					" + Enter
		cSql += "		SC5_07.C5_FILIAL	= '01'				AND " + Enter
		cSql += "		SC5_07.C5_CLIENTE	= SC5.C5_YCLIORI	AND	" + Enter
		cSql += "		SC5_07.C5_YPEDORI	= SC9.C9_PEDIDO 	AND " + Enter
		cSql += "		SC5_07.D_E_L_E_T_	= ''					" + Enter
	EndIf
	
	cSql += "WHERE	SC9.C9_FILIAL	= '"+xFilial("SC9")+"'	AND	" + Enter
	cSql += "		SC6.C6_FILIAL	= '"+xFilial("SC6")+"'  AND " + Enter
	cSql += "		SE4.E4_FILIAL	= '"+xFilial("SE4")+"'  AND	" + Enter
	cSql += "		SC5.C5_FILIAL	= '"+xFilial("SC5")+"'  AND	" + Enter
	cSql += "		SF4.F4_FILIAL	= '"+xFilial("SF4")+"'  AND	" + Enter
	cSql += "		SC9.C9_AGREG	= ''	AND 				" + Enter
	cSql += "		SC9.C9_NFISCAL	= ''	AND 				" + Enter
	cSql += "		SC9.C9_BLCRED	= ''	AND					" + Enter
	cSql += "		SC9.C9_BLEST	= ''	AND  	 			" + Enter
	cSql += "		SC6.C6_QTDVEN	>  0	AND  	 			" + Enter //OS 4321-16 - Tania - Pedido de Complemento não tem quantidade
	//cSql += "		SC9.C9_PEDIDO	IN ('XA6506','RAATO1')	AND " + Enter //linha para teste
	cSql += "		( SE4.E4_DESCRI LIKE '%ANTE%' OR SE4.E4_CODIGO IN ('145','975') ) AND " + Enter
	
	cSql += "		SF4.F4_DUPLIC   = 'S'	AND 		" + Enter
	
	
	
	//Tratamento para chamar a rotina para um unico cliente
	If !Empty(Alltrim(cCli))
		cSql += "		SC9.C9_CLIENTE  = '"+cCli+"'	AND 		" + Enter
		cSql += "		SC9.C9_LOJA     = '"+cLj+"'		AND 		" + Enter
	EndIf
	cSql += "		SC9.D_E_L_E_T_	= ''  AND 			" + Enter
	cSql += "		SC6.D_E_L_E_T_	= ''  AND 			" + Enter
	cSql += "		SC5.D_E_L_E_T_	= ''  AND 			" + Enter
	cSql += "		SE4.D_E_L_E_T_	= ''  AND 			" + Enter
	cSql += "		SF4.D_E_L_E_T_	= '' ) AS TMP 		" + Enter
	//cSql += "WHERE CLIENTE = '007568' OR CLIENTE = '016090' " + Enter
	cSql += "ORDER BY C5_YCLIORI, CLIENTE, LOJA, C9_DATALIB, C9_PEDIDO, C9_ITEM, C9_SEQUEN " + Enter //NÃO PODE MUDAR A ORDEM DE "C5_YCLIORI,CLIENTE+LOJA"
	//cSql += "ORDER BY C5_YCLIORI, CLIENTE, LOJA, C9_PEDIDO, C9_DATALIB, C9_ITEM, C9_SEQUEN " + Enter //NÃO PODE MUDAR A ORDEM DE "C5_YCLIORI,CLIENTE+LOJA"
	//cSql += "ORDER BY CLIENTE, LOJA, C9_PEDIDO, C9_DATALIB, C9_ITEM, C9_SEQUEN " + Enter //NÃO PODE MUDAR A ORDEM DE "CLIENTE+LOJA"
	If chkfile("_RAC")
		dbSelectArea("_RAC")
		dbCloseArea()
	EndIf
	TcQuery cSql New Alias "_RAC"
	DbSelectArea("_RAC")

	//Verificacao da OS 1502-15
	If left(cTimeAtu,5) >= "19:00"
		If Empty(Alltrim(cCli))
			//Limpa o Status dos itens liberados, para nova validação.
			cSql := "UPDATE "+RetSqlName("SC9")+" SET C9_YRASTAT = '4', C9_MSEXP = '' WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND C9_AGREG = '' AND C9_YRASTAT <> '' AND C9_NFISCAL = '' AND D_E_L_E_T_ = '' "
			TcSQLExec(cSql)
		EndIf
	EndIf

	While !_RAC->(EOF())

		If Empty(Alltrim(_RAC->C5_YCLIORI))
			nLm := .F.
		Else
			nLm := .T.
		EndIf

		//If _RAC->CLIENTE == "012260" //.OR. _RAC->CLIENTE == "007568"
		//	MsgAlert("teste")
		//EndIf

		//If _RAC->C9_PEDIDO == "RAAUDC"  .Or. _RAC->C9_PEDIDO == "RA9710"
		//	MsgAlert("teste")
		//EndIf

		//Tratamento para nova modalidade de RA (com geração de titulo PR)
		//If Empty(Alltrim(_RAC->PEDIDO_RA))
		//	If nCli <> _RAC->CLIENTE
		//		nCli	:= _RAC->CLIENTE
		//		nSaldo	:= U_fSitFin(_RAC->CLIENTE,_RAC->LOJA,nLm,'')
		//	EndIf
		//Else
		//	nSaldo	:= U_fSitFin(_RAC->CLIENTE,_RAC->LOJA,nLm,_RAC->C9_PEDIDO)
		//EndIf
		If Alltrim(_RAC->C5_CONDPAG) $ "V01_V02" //PARA VENDA VINILICO ONLINE - NAO TEM RA E O PEDIDO SERA SEMPRE LIBERADO 
			nSaldo	:= 999999999.99
		Else
			//Se o pedido estiver com problema de gravação dos valores, grava o pedido como Bloqueado
			If _RAC->VLRIMP_ORI == 0 .And. _RAC->VLRIMP_LM == 0
				nSaldo	:= -999999999.99
	
				//Se o pedido estiver sem RA Lançado, grava o pedido como Bloqueado
			ElseIf _RAC->RA_PROV == 0 .And. _RAC->RA_EFET == 0 .And. _RAC->RA_SEMPD == 0
				nSaldo	:= -999999999.99
	
				//Se o pedido estiver com Título Provisorio em aberto
			ElseIf _RAC->RA_PROV > 0 .And. _RAC->RA_EFET == 0
				nSaldo	:= -999999999.99
	
				//Se o pedido estiver com Título RA em aberto
			ElseIf _RAC->RA_PROV == 0 .And. _RAC->RA_EFET > 0
				nSaldo	:= _RAC->RA_EFET
	
				//Se o pedido estiver com saldo de RA sem pedido
			ElseIf _RAC->RA_SEMPD > 0 .And. _RAC->RA_PROV == 0 .And. _RAC->RA_EFET == 0
				If nCli <> _RAC->CLIENTE
					nCli	:= _RAC->CLIENTE
					nSaldo	:= U_fSitFin(_RAC->CLIENTE,_RAC->LOJA,nLm,'')
				EndIf
			Else
				nSaldo	:= -999999999.99
			EndIf		
		EndIf
		//Atualiza o Status dos Pedidos com data antes do prazo
		If _RAC->DIAS_ABERTO <= Val(nDias)
			nSaldo	:= nSaldo - _RAC->SALDO_PEDIDO + GetMv("MV_YDESCRA") //veriação do desconto financeiro

			If nSaldo >= 0 //.Or. ( nSaldo <= GetMv("MV_YDESCRA") .Or. nSaldo >= GetMv("MV_YDESCRA") )
				//Posiciona no Registro
				SC9->(DBGOTO(_RAC->RECNO))
				//Grava o Status do RA
				SC9->(RecLock("SC9",.F.))
				SC9->C9_YRASTAT := "1" //Liberado com Saldo
				SC9->(MsUnLock())
			Else
				//Posiciona no Registro
				SC9->(DBGOTO(_RAC->RECNO))
				//Grava o Status do RA
				SC9->(RecLock("SC9",.F.))
				SC9->C9_YRASTAT := "2" //Aguardando Lancamento Ra
				SC9->(MsUnLock())
			EndIf

			//Atualiza o Status dos Pedidos com data posterior ao permitido, estornando os saldo.
		Else
			nSaldo	:= nSaldo - _RAC->SALDO_PEDIDO + GetMv("MV_YDESCRA")

			If nSaldo >= 0 //.Or. ( nSaldo <= GetMv("MV_YDESCRA") .Or. nSaldo >= GetMv("MV_YDESCRA") )
				//Posiciona no Registro
				SC9->(DBGOTO(_RAC->RECNO))
				//Grava o Status do RA
				SC9->(RecLock("SC9",.F.))
				SC9->C9_YRASTAT := "1" //Liberado com Saldo
				SC9->(MsUnLock())
			Else
				//Estorna os pedidos, somente na rotina de madrugada.
				If left(cTimeAtu,5) >= "19:00" .Or. Stod(_RAC->C9_DATALIB) == dDataBase //Estorna os pedidos liberados no mesmo dia com títulos vencidos. Ticket 1306
					//Posiciona no Registro
					SC9->(DBGOTO(_RAC->RECNO))
					//Grava o Status do RA
					SC9->(RecLock("SC9",.F.))
					SC9->C9_YRASTAT := "3" 			//Eliminado por falta de saldo de RA
					SC9->C9_YRADTEX	:= dDataBase	//Dia que foi eliminado
					SC9->(MsUnLock())
					//Realiza o Estorno
					//SC9->(a460Estorna(.T.,.T.,0))  // lMata410 , lAtuEmp , nVlrCred -> OBRIGATÓRIO PASSAR O SEGUNDO PARAMETRO COMO .T. PARA ESTORNAR O EMPENHO NA TABELA SC6
					SC9->(a460Estorna())  // Comentado acima para teste ticket 22342

					If !Empty(Alltrim(cCli))
						MsgBox("O Pedido de Venda "+SC9->C9_PEDIDO+", está sendo estornado, pois está sem saldo de RA ou está com RA vencido a mais de "+nDias+" dias.","STOP")
					EndIf

					// Comentado abaixo para teste ticket 22342
					//Acerta C6_QTDEMP
					/*fC6_QTDEMP()

					//Após estono, grava informações
					SC6->(dbcommitall())
					*/
				EndIf
			EndIf
		EndIf

		_RAC->(dbSkip())
	End

	If chkfile("_RAC")
		dbSelectArea("_RAC")
		dbCloseArea()
	EndIf

Return

//-----------------------------------------------------------
//Corrige a quantidade empenhada, caso esteja com problema.
//-----------------------------------------------------------
Static Function fC6_QTDEMP()
	Local cSql 	:= ""
	Local Enter	:= CHR(13)+CHR(10)

	//Seleciona registros com C6_QTDEMP preencido e sem registro na tabela SC9.
	cSql := ""
	cSql += "SELECT C6_NUM, C6_PRODUTO, C6_ITEM, C6_QTDVEN, C6_QTDENT, C6_QTDLIB, C6_QTDEMP, C6_QTDEMP2, SC6.R_E_C_N_O_ AS RECNO, ISNULL(SC9.C9_QTDLIB,0) C9_QTDLIB, ISNULL(SC9.C9_QTDLIB2,0) C9_QTDLIB2 " + Enter
	cSql += "FROM "+RetSqlName("SC6")+" SC6 LEFT JOIN "+RetSqlName("SC9")+" SC9 ON " + Enter
	cSql += "    SC6.C6_NUM		= SC9.C9_PEDIDO  AND		" + Enter
	cSql += "	 SC6.C6_PRODUTO	= SC9.C9_PRODUTO AND 		" + Enter
	cSql += "	 SC6.C6_ITEM	= SC9.C9_ITEM    AND 		" + Enter
	cSql += "	 SC9.C9_NFISCAL = '' 			 AND		" + Enter
	cSql += "	 SC9.D_E_L_E_T_ = ''						" + Enter
	cSql += "WHERE SC6.C6_BLQ     <> 'R' 			 AND    " + Enter
	cSql += "      SC6.C6_FILIAL  = '"+xFilial('SC6')+"' AND " + Enter
	cSql += "      SC9.C9_FILIAL  = '"+xFilial('SC9')+"' AND " + Enter
	cSql += "      SC6.C6_QTDVEN - SC6.C6_QTDENT > 0 AND 	" + Enter
	cSql += "	   SC6.C6_QTDEMP  <> 0  			 AND    " + Enter
	cSql += "	   ISNULL(SC9.C9_QTDLIB,0) = 0 	     AND	" + Enter
	cSql += "      SC6.C6_NUM 	  = '"+_RAC->C9_PEDIDO+"'	AND " + Enter
	cSql += "	   SC6.C6_PRODUTO = '"+_RAC->C9_PRODUTO+"' 	AND " + Enter
	cSql += "	   SC6.C6_ITEM    = '"+_RAC->C9_ITEM+"' 	AND " + Enter
	cSql += "	   SC6.D_E_L_E_T_ = '' 							" + Enter
	If chkfile("_SC6")
		dbSelectArea("_SC6")
		dbCloseArea()
	EndIf
	TcQuery cSql New Alias "_SC6"


	While !_SC6->(EOF())

		//Acerta o campo C6_QTDEMP
		SC6->(DBGOTO(_SC6->RECNO))
		SC6->(RecLock("SC6",.F.))
		SC6->C6_QTDEMP	:= _SC6->C9_QTDLIB
		SC6->C6_QTDEMP2	:= _SC6->C9_QTDLIB2
		SC6->(MsUnLock())
		SC6->(dbcommitall())

		_SC6->(dbSkip())
	End

	//Fecha Arquivo Temporario
	If chkfile("_SC6")
		dbSelectArea("_SC6")
		dbCloseArea()
	EndIf

Return
