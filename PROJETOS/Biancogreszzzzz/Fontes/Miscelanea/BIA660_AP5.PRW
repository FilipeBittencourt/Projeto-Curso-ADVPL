#Include "RwMake.ch"
#Include "TOPCONN.CH"
#Include "Totvs.ch"                      
#Include "PROTHEUS.CH"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BIA660           ³ Cesar Magnago      º Data ³  23/07/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ VISUALIZAR PEDIDO DE VENDA BLOQUEADO POR PRECO      		    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faturamento                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA660()

	Local cEmpNPOL := AllTrim(GetNewPar("FA_EMPNPOL","14#"))
	local _ni

	//Inicialização de variáveis
	aCols := {}; aHeader := {}; nUsado := 0
	wCpo := "UZ7_PEDIDO,UZ7_CLIENT,UZ7_DESCLI,UZ7_LOJACL,UZ7_NOMECL,UZ7_APROV,UZ7_AAPROV,C6_NUM,C6_QTDEMP"

	//Opcoes de acesso para a Modelo 3
	cOpcao := "VISUALIZAR"; nOpcE := 2; nOpcG := 2; aCpoEnchoice:= {}

	//Cria variaveis M->????? da Enchoice
	REGTOMEMORY("UZ7",.T.)

	//Tecla de atalho para consultar a composicao do desconto
	If !(AllTrim(cEmpAnt) $ cEmpNPOL)
		SetKey(K_CTRL_F5,{|| U_B660CPOL() })
	EndIf


	//Cria aCpoEnchoice da GetDados
	DBSELECTAREA("SX3")
	DBSETORDER(1)
	DBSEEK("UZ7")

	WHILE !EOF() .AND. (X3_ARQUIVO=="UZ7")
		IF X3USO(x3_usado) .AND. cNivel >= X3_NIVEL .AND. (ALLTRIM(X3_CAMPO) # "UZ7_LOJAEN")
			AADD(aCpoEnchoice,ALLTRIM(SX3->X3_CAMPO))
		ENDIF
		DBSKIP()
	ENDDO

	//Cria aHeader e aCols da GetDados
	DBSELECTAREA("SX3")
	DBSETORDER(1)
	DBSEEK("SC6")

	WHILE !EOF() .AND. (X3_ARQUIVO=="SC6")
		IF X3USO(x3_usado) .AND. cNivel >= X3_NIVEL .AND. !(RTRIM(X3_CAMPO) $ wCpo)
			nUsado:=nUsado+1
			AADD(aHeader,{ TRIM(x3_titulo), ALLTRIM(x3_campo)	, x3_picture		,;
			x3_tamanho		, x3_decimal			,"AllwaysTrue()"	,;
			x3_usado			, x3_tipo				, x3_arquivo		, x3_context } )
		ENDIF
		DBSKIP()
	ENDDO

	//Inicializa ou valoriza aCols com dados dos itens da programação
	IF cOpcao=="VISUALIZAR"
		DBSELECTAREA("SC6"); DBSETORDER(1)
		IF DBSEEK(XFILIAL("SC6")+UZ7->UZ7_PEDIDO)
			WHILE !EOF() .AND. (UZ7->UZ7_FILIAL == SC6->C6_FILIAL) .AND. (UZ7->UZ7_PEDIDO == SC6->C6_NUM) 
				IF SC6->C6_QTDVEN - SC6->C6_QTDENT > 0
					AADD(aCols,ARRAY(nUsado+1)) 					// Cria uma linha nova com a quantidade de colunas determinadas pelo SX3 ou outra fonte qualquer
					aCols[LEN(aCols)][nUsado+1] := .F. 	//.F. Ativa a linha  .T. Desativa (Marca para deleção)
					FOR _ni:=1 TO nUsado 									//Inicializa as variaveis conforme SX3
						wVarTmp := "SC6->"+aHeader[_ni,2]
						IF FIELDPOS(aHeader[_ni,2]) == 0 	//Inicializa campos que não existem na tabela e portanto são virtuais e por isso tem tratamento específico
							IF aHeader[_ni][2] == "C6_DESCRI"
								aCols[LEN(aCols),_ni] := RETFIELD("SA1",1,xFILIAL("SA1")+UZ7->UZ7_CLIENT+UZ7->UZ7_LOJACL,"SA1->A1_NOME")
							ELSE
								aCols[LEN(aCols),_ni]:= CRIAVAR(aHeader[_ni,2])
							ENDIF
						ELSE
							aCols[LEN(aCols),_ni]:= &wVarTmp //Inicializa campo que reais, que existem na tabela
						ENDIF
					NEXT
				ENDIF
				DBSKIP()
			ENDDO
		ENDIF
		IF LEN(aCols) == 0 // Caso não existam itens a serem incluidos em aCols cria-se uma linha em branco: isso evita erros indesejados
			aCols:={ARRAY(nUsado+1)}
			aCols[1,nUsado+1]:=.F.
			FOR _ni:=1 to nUsado
				aCols[1,_ni]:=CRIAVAR(aHeader[_ni,2])
			NEXT
		ENDIF

	ENDIF

	//Executa a funcao MODELO3 conforme parametros
	IF LEN(aCols) > 0

		cTitulo			:="Pedidos Bloqueados por Preco"
		cAliasEnchoice	:="UZ7"
		cAliasGetD		:="SC6"
		cLinOk			:="AllwaysTrue()"
		cTudOk			:="AllwaysTrue()"
		cFieldOk		:="AllwaysTrue()"

		MODELO3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk,,,,,U_aButtons(),{0,0,MSADVSIZE()[6],MSADVSIZE()[5]},400)

	ENDIF

RETURN()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ aButtons         ³ Ranisses A. Corona º Data ³  11/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para incluir botao na Visualizacao do PV            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function aButtons()
	aBotao :={}	

	If U_VALOPER("003",.F.) //Apenas para Diretores e Gerentes
		//aBotao :={{"BUDGETY",{|| U_CalcMargem(UZ7->UZ7_PEDIDO,"1") },"Margem"}}
		//aBotao :={{"BUDGETY",{|| U_fMargem2(UZ7->UZ7_PEDIDO,"3") },"Margem2"}}	
		//aBotao :={{"BUDGETY",{|| U_fMargem3(UZ7->UZ7_PEDIDO,"3") },"Margem Operacional"}}
		AADD(aBotao,{"BUDGETY",{|| U_fMargem3(UZ7->UZ7_PEDIDO,"3") },"Margem Operacional"})	
	EndIf

	AADD(aBotao,{"BUDGETY",{|| U_BIA584() },"Total Quant."})

Return(aBotao)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CalcMargem       ³ Ranisses A. Corona º Data ³  11/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para calcular a Margem no Pedido a Liberar = MC     º±±
±±º          ³ Parametro: Pedido => Numero Pedido de Venda                º±±
±±º          ³            1,2,3  => 1 -> Calcula e Exibe Mensagem         º±±
±±º          ³                      2 -> Apenas Calcula                   º±±
±±º          ³                      3 -> Apenas Exibe                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CalcMargem(nNumPed,lFlag)
	Local nRet	 	:= 0
	Local cSQL   	:= ""
	Local nFator 	:= 0
	Local nVlrPre	:= 0
	Local nDescZF 	:= 0
	Local nVlrM		:= 0  
	Local nVlMCM	:= 0
	Local nPcMCM	:= 0
	Local lMundi	:= .F.
	Local oFont1 	:= TFont():New("Arial",,018,,.T.,,,,,.F.,.T.)
	Local oFont2 	:= TFont():New("Arial",,017,,.T.,,,,,.F.,.F.)
	Local oFont3 	:= TFont():New("Arial",,018,,.T.,,,,,.F.,.F.)
	Local oFont4 	:= TFont():New("Arial",,018,,.T.,,,,,.F.,.T.)
	Local oGet1
	Local cGet1 := "Define variable value"
	Local oGet2
	Local cGet2 := "Define variable value"
	Local oGet3
	Local cGet3 := "Define variable value"
	Local oGet4
	Local cGet4 := "Define variable value"
	Local oGet5
	Local cGet5 := "Define variable value"
	Local oGet6
	Local cGet6 := "Define variable value"
	Local oGet7
	Local cGet7 := "Define variable value"
	Local oGet8
	Local cGet8 := "Define variable value"
	Local oGet9
	Local cGet9 := "Define variable value"
	Local oGet10
	Local cGet10 := "Define variable value"
	Local oGet11
	Local cGet11 := "Define variable value"
	Local oPanel1
	Local oPanel2
	Local oPanel3
	Local oPanel4
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local oSay8
	Local oSay9
	Local oSay10
	Local oSay11
	Local oSay12
	Local oSay13
	Local oSay14
	Local oSay15
	Local oSay16
	Local oSay17
	Local oSay18
	Static oDlg

	cSQL := ""
	cSQL += "SELECT SUM(C6_VALOR) VALOR, SUM(COMISSAO) COMISSAO, SUM(ROUND((C6_QTDVEN*CHU),2)) CP, SUM(C6_YDESCZF) AS DESCZF, MAX(C6_YEMP) AS EMP, MAX(C5_YSUBTP) AS TIPO, MAX(C5_YPEDORI) PEDORI " + CRLF
	cSQL += "FROM 										" + CRLF
	//cSQL += "(SELECT	CHU =	CASE 			" + CRLF
	//cSQL += "									WHEN C6_YEMP = '0101' THEN ISNULL((SELECT ZZ5_CV FROM ZZ5010 WHERE ZZ5_FILIAL = '01' AND ZZ5_FORMAT = B1_YFORMAT AND ZZ5_LINHA = B1_YLINHA AND C5_EMISSAO >= ZZ5_DTINI AND C5_EMISSAO <= ZZ5_DTFIM AND ZZ5_CLASSE = '' AND ZZ5_TIPO = '1' AND D_E_L_E_T_ = ''),0) " + CRLF
	//cSQL += "									WHEN SUBSTRING(C6_YEMP,1,2) = '05' THEN ISNULL((SELECT ZZ5_CV FROM ZZ5050 WHERE ZZ5_FILIAL = '01' AND ZZ5_FORMAT = B1_YFORMAT AND ZZ5_LINHA = B1_YLINHA AND C5_EMISSAO >= ZZ5_DTINI AND C5_EMISSAO <= ZZ5_DTFIM AND ZZ5_CLASSE = '' AND ZZ5_TIPO = '1' AND D_E_L_E_T_ = ''),0)	" + CRLF
	//cSQL += "									ELSE 0	" + CRLF
	//cSQL += "								END, 			" + CRLF
	cSQL += "(SELECT 	(SELECT dbo.FN_CH(SUBSTRING(C6_YEMP,1,2),C6_PRODUTO,C6_YEMISSA,C6_YEMISSA)) CHU,		" + CRLF
	cSQL += "					C6_QTDVEN, (C6_VALOR-C6_YDESCZF) AS C6_VALOR, C6_YDESCZF, C6_YEMP,				" + CRLF
	cSQL += "					ROUND((((C6_VALOR-C6_YDESCZF)*C6_COMIS1)/100)+									" + CRLF
	cSQL += "						  (((C6_VALOR-C6_YDESCZF)*C6_COMIS2)/100)+									" + CRLF
	cSQL += "						  (((C6_VALOR-C6_YDESCZF)*C6_COMIS3)/100)+									" + CRLF
	cSQL += "						  (((C6_VALOR-C6_YDESCZF)*C6_COMIS4)/100)+									" + CRLF
	cSQL += "						  (((C6_VALOR-C6_YDESCZF)*C6_COMIS5)/100),2) AS COMISSAO, C5_YSUBTP, C5_YPEDORI	" + CRLF
	//DESATIVADO EM 19/03/12 PARA CONSIDERAR NOVAS REGRAS FATURAMENTO
	//If cEmpAnt == "07"
	//	cSQL += "					(SELECT ROUND(((C6_VALOR*C6_COMIS1)/100),2) FROM SC6010 WHERE C6_NUM = C5_YPEDORI AND C6_PRODUTO = SC6.C6_PRODUTO AND C6_ITEM = SC6.C6_ITEM AND D_E_L_E_T_ = '' ) COMISSAO " + CRLF
	//Else
	//	cSQL += "					ROUND(((C6_VALOR*C6_COMIS1)/100),2) AS COMISSAO " + CRLF
	//EndIf
	cSQL += "FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SC6")+" SC6 " + CRLF
	cSQL += "WHERE	C5_NUM			= C6_NUM		AND " + CRLF
	cSQL += "		C5_NUM			= '"+nNumPed+"'	AND " + CRLF
	cSQL += "		SC6.D_E_L_E_T_ 	= '' 			AND	" + CRLF
	cSQL += "		SC5.D_E_L_E_T_ 	= '' ) AS TMP	" + CRLF
	If chkfile("_TMP")
		dbSelectArea("_TMP")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_TMP" NEW

	//Verifica se o campo C6_YEMP esta preenchido
	IF Empty(Alltrim(_TMP->EMP))
		MsgAlert("Existem campos que não estão preenchidos nos itens de pedidos. Favor informar o Setor de TI.")
		Return(nRet)
	EndIf

	cSQL := ""
	cSQL += "SELECT C5_YEMP, C5_EMISSAO, (SELECT E4_YMEDIA FROM SE4010 WHERE E4_CODIGO = C5_CONDPAG AND D_E_L_E_T_ = '') PZM, (C5_YVLTICM+C5_YVLTCOF+C5_YVLTPIS) IMPOSTO " + CRLF
	cSQL += "FROM "+RetSqlName("SC5")+"  " + CRLF
	cSQL += "WHERE C5_NUM = '"+nNumPed+"'	 AND D_E_L_E_T_ = ''	" + CRLF
	If chkfile("_TMP2")
		dbSelectArea("_TMP2")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_TMP2" NEW

	//Alteração da gravação da Taxa Financeira, conforme OS 2349-15
	nFator	:= U_fBuscaTxBI(_TMP2->C5_YEMP,"TXF",_TMP2->C5_EMISSAO)
	IF nFator == 0
		MsgBox("Favor verificar o preenchimento da tabela Parametros BI (Z40), pois a Taxa Financeira (TXF) esta vencida para a Marca "+_TMP2->C5_YEMP+". Entre em contato com a Controladoria ou Direção Administrativa.","BIA660","STOP")		
		Return(nRet)
	EndIf

	//Apura valor Operacao Mundi
	If cEmpAnt == "07" .And. Alltrim(_TMP->TIPO) == "IM"
		//cSQL := ""
		//cSQL += "SELECT C5_YVLTOTP FROM SC5130	WHERE C5_FILIAL = '01' AND C5_NUM = '"+_TMP->PEDORI+"' AND D_E_L_E_T_ = ''	" + CRLF
		cSQL := ""
		cSQL += "SELECT SUM(VL_MUNDI) VL_MUNDI			" + CRLF
		cSQL += "FROM 									" + CRLF
		cSQL += "(SELECT ROUND((((ISNULL((SELECT AVG(C6_PRCVEN) FROM SC6130 C6 WHERE C6_NUM = SC5.C5_YPEDORI AND C6.C6_PRODUTO = SC6.C6_PRODUTO AND C6.D_E_L_E_T_ = ''),0)*C6_QTDVEN)*9)/100),2) VL_MUNDI " + CRLF
		cSQL += "FROM SC5070 SC5, SC6070 SC6			" + CRLF
		cSQL += "WHERE	SC5.C5_NUM = SC6.C6_NUM 	AND	" + CRLF
		cSQL += "		SC5.C5_NUM = '"+nNumPed+"'	AND	" + CRLF
		cSQL += "      	SC5.D_E_L_E_T_ = '' 		AND " + CRLF
		cSQL += "     	SC6.D_E_L_E_T_ = '') AS TMP		" + CRLF
		If chkfile("_TMP3")
			dbSelectArea("_TMP3")
			dbCloseArea()
		EndIf
		TCQUERY cSQL ALIAS "_TMP3" NEW
		If !_TMP3->(EOF())
			//nVlrM		:= Round((_TMP3->C5_YVLTOTP*9)/100,2)
			nVlrM		:= _TMP3->VL_MUNDI
			lMundi		:= .T.
		EndIf
	EndIf

	//Realiza o calculo da Margem
	//nVlrPre	:= Round(_TMP->VALOR/((1+nFator)^_TMP2->PZM),2) //DESATIVADO EM 19/03/12 CONFORME SOLICITACAO DO CAMERINO FILHO - AGUARDAR DEFINICAO DE VALOR PRESENTE
	nVlrPre	:= _TMP->VALOR										//ATIVADO EM 19/03/12 PARA CONSIDERAR O VALOR DO PEDIDO - AGUARDAR DEFINICAO DE VALOR PRESENTE
	nDescZF	:= _TMP->DESCZF
	nRL		:= nVlrPre-(_TMP->COMISSAO+_TMP2->IMPOSTO)
	nVlrMC	:= nRL-_TMP->CP
	nPercMC	:= Round((nVlrMC/nVlrPre)*100,2)
	If lMundi
		nVlMCM	:= nVlrMC+nVlrM
		nPcMCM	:= Round((nVlMCM/nVlrPre)*100,2)
	EndIf

	If cEmpAnt <> "14"
		If lFlag <> "3" //1 ou 2

			//ATUALIZA CAMPO SC5
			//If lMundi
			//	cSQL := "UPDATE "+RetSqlName("SC5")+" SET C5_YPERCMC = '"+Alltrim(Str(nPcMCM))+"' WHERE C5_NUM = '"+nNumPed+"' AND D_E_L_E_T_ = ''	"
			//Else
			cSQL := "UPDATE "+RetSqlName("SC5")+" SET C5_YPERCMC = '"+Alltrim(Str(nPercMC))+"' WHERE C5_NUM = '"+nNumPed+"' AND D_E_L_E_T_ = ''	"
			//EndIf
			TcSqlExec(cSQL)

			//ATUALIZA CAMPO SC6
			cSQL := "UPDATE "+RetSqlName("SC6")+" SET C6_YPERCMC = ROUND((((C6_VALOR-C6_YDESCZF)-(ROUND((C6_VALOR-C6_YDESCZF)*C6_COMIS1/100,2)+C6_YVLTICM+C6_YVLTPIS+C6_YVLTCOF+	ROUND(C6_QTDVEN*(SELECT dbo.FN_CH(SUBSTRING(C6_YEMP,1,2),C6_PRODUTO,C6_YEMISSA,C6_YEMISSA)),2)))/(C6_VALOR-C6_YDESCZF))*100,2) "
			cSQL += " WHERE C6_NUM = '"+nNumPed+"' AND D_E_L_E_T_ = '' "
			TcSqlExec(cSQL)

		EndIf
	EndIf

	//ARMAZENA VARIAVEIS PARA MONTAGEM DA TELA
	If nDescZF > 0
		cGet1 := Transform(nVlrPre+nDescZF		, "@E 999,999,999.99")
		cGet8 := Transform(nDescZF				, "@E 999,999,999.99")	
	Else
		cGet1 := Transform(nVlrPre				, "@E 999,999,999.99")
	EndIf
	cGet2 	:= Transform(_TMP->COMISSAO			, "@E 999,999,999.99")
	cGet3 	:= Transform(_TMP2->IMPOSTO			, "@E 999,999,999.99")
	cGet4 	:= Transform(nRL					, "@E 999,999,999.99")
	cGet5	:= Transform(_TMP->CP				, "@E 999,999,999.99")
	cGet6	:= Transform(nVlrMC					, "@E 999,999,999.99")
	cGet7	:= Transform(nPercMC				, "@E 999,999,999.99")
	cGet9	:= Transform(nVlrM					, "@E 999,999,999.99")
	cGet10	:= Transform(nVlMCM					, "@E 999,999,999.99")
	cGet11	:= Transform(nPcMCM					, "@E 999,999,999.99")

	lMundi := .F.

	If lFlag <> "2" //1 ou 3 

		If lMundi
			DEFINE MSDIALOG oDlg TITLE "Cálculo da Margem" FROM 000, 000  TO 440, 285 COLORS 0, 16777215 PIXEL
		Else
			DEFINE MSDIALOG oDlg TITLE "Cálculo da Margem" FROM 000, 000  TO 280, 285 COLORS 0, 16777215 PIXEL
		EndIf

		//@ 015, 012 SAY oSay1 PROMPT "Valor Presente" SIZE 049, 007 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
		If nDescZF > 0
			@ 001, 012 SAY 		oSay1 PROMPT 	"Valor Pedido" 	SIZE 049, 007 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
			@ 001, 062 SAY		oSay8 PROMPT	"+" 						SIZE 006, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
			@ 001, 070 MSGET	oGet1 VAR 		cGet1 					SIZE 060, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 READONLY PIXEL

			@ 015, 012 SAY 		oSay14 PROMPT "Desc. Suframa"	SIZE 049, 007 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
			@ 015, 062 SAY		oSay15 PROMPT	"-" 						SIZE 006, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
			@ 015, 070 MSGET	oGet8  VAR 		cGet8 					SIZE 060, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		Else
			@ 015, 012 SAY 		oSay1 PROMPT 	"Valor Pedido" 	SIZE 049, 007 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
			@ 015, 062 SAY		oSay8 PROMPT	"+" 						SIZE 006, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
			@ 015, 070 MSGET	oGet1 VAR 		cGet1 					SIZE 060, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		EndIF

		@ 030, 012 SAY 		oSay2 PROMPT 	"Valor Comissão"	SIZE 049, 007 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 030, 062 SAY 		oSay9 PROMPT 	"-" 							SIZE 006, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 030, 070 MSGET 	oGet2 VAR 		cGet2 						SIZE 060, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 READONLY PIXEL

		@ 045, 012 SAY 		oSay3  PROMPT "Valor Impostos"	SIZE 049, 007 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 045, 062 SAY 		oSay10 PROMPT "-" 							SIZE 006, 007 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 045, 070 MSGET 	oGet3 VAR 		cGet3 						SIZE 060, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 READONLY PIXEL

		@ 060, 012 MSPANEL oPanel1 SIZE 120, 014 OF oDlg COLORS 0, 16777215 RAISED
		@ 001, 000 SAY oSay4	PROMPT "Valor RL"	SIZE 030, 007 OF oPanel1 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 001, 049 SAY oSay12	PROMPT "="				SIZE 006, 007 OF oPanel1 FONT oFont1 COLORS 128, 16777215 PIXEL
		//@ 000, 035 SAY oSay11 PROMPT "=" SIZE 000, 006 OF oSay4 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 000, 058 MSGET oGet4 VAR	cGet4 			SIZE 060, 011 OF oPanel1 COLORS 128, 16777215 FONT oFont1 READONLY PIXEL

		@ 080, 012 SAY 		oSay5		PROMPT "Valor CH"	SIZE 035, 007 OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 080, 061 SAY 		oSay13	PROMPT "-" 				SIZE 006, 006 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 080, 070 MSGET	oGet5 VAR			 cGet5 			SIZE 060, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 READONLY PIXEL

		@ 093, 012 MSPANEL oPanel2 SIZE 120, 034 OF oDlg COLORS 0, 16777215 RAISED
		@ 003, 000 SAY 		oSay6 PROMPT	"Valor MC"	SIZE 038, 007 OF oPanel2 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 003, 058 MSGET 	oGet6 VAR 		cGet6 			SIZE 060, 011 OF oPanel2 COLORS 128, 16777215 FONT oFont1 READONLY PIXEL

		@ 018, 000 SAY 		oSay7 PROMPT	"% MC"	SIZE 032, 009 OF oPanel2 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 018, 058 MSGET	oGet7 VAR 		cGet7		SIZE 060, 012 OF oPanel2 COLORS 128, 16777215 FONT oFont1 READONLY PIXEL

		If lMundi
			@ 132, 011 MSPANEL oPanel3 SIZE 120, 033 OF oDlg COLORS 0, 255 RAISED
			@ 004, 030 SAY oSay17 PROMPT "OPERAÇÃO MUNDI" SIZE 065, 007 OF oPanel3 FONT oFont4 COLORS 16777215, 255 PIXEL

			@ 019, 005 SAY oSay14 PROMPT "Valor"	SIZE 045, 007 OF oPanel3 FONT oFont4 COLORS 16777215, 255 PIXEL
			@ 017, 058 MSGET oGet9 VAR cGet9 			SIZE 060, 012 OF oPanel3 COLORS 16777215, 255 FONT oFont4 PIXEL

			@ 170, 011 MSPANEL oPanel4 SIZE 120, 047 OF oDlg COLORS 0, 255 RAISED
			@ 004, 030 SAY oSay18 PROMPT "OPERAÇÃO TOTAL" 	SIZE 065, 007 OF oPanel4 FONT oFont4 COLORS 16777215, 255 PIXEL
			@ 020, 006 SAY oSay15 PROMPT "Valor MC Total"		SIZE 050, 007 OF oPanel4 FONT oFont4 COLORS 16777215, 255 PIXEL
			@ 018, 058 MSGET oGet10 VAR cGet10 							SIZE 060, 012 OF oPanel4 COLORS 16777215, 255 FONT oFont4 PIXEL

			@ 032, 005 SAY oSay16 PROMPT "% MC Total" SIZE 045, 007 OF oPanel4 FONT oFont4 COLORS 16777215, 255 PIXEL
			@ 032, 058 MSGET oGet11 VAR cGet11 SIZE 060, 012 OF oPanel4 COLORS 16777215, 255 FONT oFont4 PIXEL

		EndIf

		ACTIVATE MSDIALOG oDlg CENTERED

	Else

		nRet := nPercMC

	EndIf

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fMargem2         ³ Ranisses A. Corona º Data ³  01/09/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para calcular a Margem no Pedido a Liberar = MC     º±±
±±º          ³ Parametro: Pedido => Numero Pedido de Venda                º±±
±±º          ³            1,2,3  => 1 -> Calcula e Exibe Mensagem         º±±
±±º          ³                      2 -> Apenas Calcula                   º±±
±±º          ³                      3 -> Apenas Exibe                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fMargem2(nNumPed,lFlag)
	Local nRet	 	:= 0
	Local cSQL   	:= ""
	Local nFator 	:= 0
	Local oFont1 	:= TFont():New("Arial",,018,,.T.,,,,,.F.,.T.)
	Local oFont2 	:= TFont():New("Arial",,017,,.T.,,,,,.F.,.F.)
	Local oFont3 	:= TFont():New("Arial",,018,,.T.,,,,,.F.,.F.)
	Local oFont4 	:= TFont():New("Arial",,018,,.T.,,,,,.F.,.T.)
	Local nDAO
	Local cDAO 		:= "Define variable value"
	Local nDCF
	Local cDCF 		:= "Define variable value"
	Local nDCVc
	Local cDCVc 	:= "Define variable value"
	Local nDCVi
	Local cDCVi 	:= "Define variable value"
	Local nDCVp
	Local cDCVp 	:= "Define variable value"
	Local nPercMC2
	Local cPercMC2 	:= "Define variable value"
	Local nVlrCP
	Local cVlrCP 	:= "Define variable value"
	Local nVlrImp
	Local cVlrImp 	:= "Define variable value"
	Local nVlrMC
	Local cVlrMC 	:= "Define variable value"
	Local nVlrMC2
	Local cVlrMC2 	:= "Define variable value"
	Local nVlrPr
	Local cVlrPr 	:= "Define variable value"
	Local nVlrRLC
	Local cVlrRLC 	:= "Define variable value"
	Local nVlrFt	
	Local cVlrFt 	:= "Define variable value"
	Local nVlrINSS
	Local cVlrINSS 	:= "Define variable value"
	Local oPanel1
	Local oPanel2
	Local oPanel3
	Local oPanel4
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local oSay8
	Local oSay9
	Local oSay10
	Local oSay11
	Local oSay12
	Local oSay13
	Local oSay14
	Local oSay15
	Local oSay16
	Local oSay17
	Local oSay18
	Local oSay19
	Local oSay20
	Local oSay21
	Local oSay22
	Local oSay23
	Local oSay24
	Local oSay25
	Local oSay26
	Local oSay27

	Static oDlg

	cSQL := ""
	cSQL += "SELECT C5_CONDPAG, SUM(C6_VALOR) VALOR, SUM(COMISSAO) COMISSAO, SUM(ROUND((C6_QTDVEN*CPU),2)) CP, SUM(C6_YDESCZF) AS DESCZF, MAX(C6_YEMP) AS EMP, MAX(C5_YSUBTP) AS TIPO, MAX(C5_YPEDORI) PEDORI " + CRLF
	cSQL += "FROM 										" + CRLF
	cSQL += "(SELECT 									" + CRLF
	cSQL += "					CPU = CASE 				" + CRLF
	cSQL += "							WHEN SUBSTRING(C5_YEMP,1,2) = '13' THEN (SELECT dbo.FN_CM(SUBSTRING(C6_YEMP,1,2),C6_PRODUTO,C6_LOCAL,C6_YEMISSA)) 	" + CRLF
	cSQL += "							ELSE (SELECT dbo.FN_CP(SUBSTRING(C6_YEMP,1,2),C6_PRODUTO,C6_YEMISSA,C6_YEMISSA)) 									" + CRLF
	cSQL += "					  	END,																													" + CRLF
	cSQL += "					C6_QTDVEN, (C6_VALOR-C6_YDESCZF) AS C6_VALOR, C6_YDESCZF, C6_YEMP,				" + CRLF
	cSQL += "					ROUND((((C6_VALOR-C6_YDESCZF)*C6_COMIS1)/100)+									" + CRLF
	cSQL += "						  (((C6_VALOR-C6_YDESCZF)*C6_COMIS2)/100)+									" + CRLF
	cSQL += "						  (((C6_VALOR-C6_YDESCZF)*C6_COMIS3)/100)+									" + CRLF
	cSQL += "						  (((C6_VALOR-C6_YDESCZF)*C6_COMIS4)/100)+									" + CRLF
	cSQL += "						  (((C6_VALOR-C6_YDESCZF)*C6_COMIS5)/100),2) AS COMISSAO, C5_YSUBTP, C5_YPEDORI, C5_CONDPAG " + CRLF
	cSQL += "FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SC6")+" SC6 " + CRLF
	cSQL += "WHERE	C5_NUM			= C6_NUM		AND " + CRLF
	cSQL += "		C5_NUM			= '"+nNumPed+"'	AND " + CRLF
	cSQL += "		SC6.D_E_L_E_T_ 	= '' 			AND	" + CRLF
	cSQL += "		SC5.D_E_L_E_T_ 	= '' ) AS TMP		" + CRLF
	cSQL += "GROUP BY C5_CONDPAG   						" + CRLF
	If chkfile("_TMP")
		dbSelectArea("_TMP")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_TMP" NEW

	//Verifica se o campo C6_YEMP esta preenchido
	IF Empty(Alltrim(_TMP->EMP))
		MsgAlert("Existem campos que não estão preenchidos nos itens de pedidos. Favor informar o Setor de TI.")
		Return(nRet)
	EndIf

	cSQL := ""
	cSQL += "SELECT C5_EMISSAO, C5_YEMP, (SELECT E4_YMEDIA FROM SE4010 WHERE E4_CODIGO = C5_CONDPAG AND D_E_L_E_T_ = '') PZM, (C5_YVLTICM+C5_YVLTCOF+C5_YVLTPIS) IMPOSTO " + CRLF
	cSQL += "FROM "+RetSqlName("SC5")+"  " + CRLF
	cSQL += "WHERE C5_NUM = '"+nNumPed+"'	 AND D_E_L_E_T_ = ''	" + CRLF
	If chkfile("_TMP2")
		dbSelectArea("_TMP2")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_TMP2" NEW

	//Alteração da gravação da Taxa Financeira, conforme OS 2349-15
	nFator	:= U_fBuscaTxBI(_TMP2->C5_YEMP,"TXF",_TMP2->C5_EMISSAO)
	IF nFator == 0
		MsgBox("Favor verificar o preenchimento da tabela Parametros BI (Z40), pois a Taxa Financeira (TXF) esta vencida para a Marca "+_TMP2->C5_YEMP+". Entre em contato com a Controladoria ou Direção Administrativa.","BIA660","STOP")		
		Return(nRet)
	EndIf

	cSQL := ""                 
	cSQL += "SELECT Z40_PERC FROM "+RetSqlName("Z40")+" WHERE Z40_MARCA = '"+_TMP->EMP+"' AND Z40_TIPO = 'DAO' AND Z40_DATDE <= '"+dtos(dDataBase)+"' AND Z40_DATATE >= '"+dtos(dDataBase)+"' AND D_E_L_E_T_ = '' "
	If chkfile("_DAO")
		dbSelectArea("_DAO")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_DAO" NEW

	cSQL := ""                 
	cSQL += "SELECT Z40_PERC FROM "+RetSqlName("Z40")+" WHERE Z40_MARCA = '"+_TMP->EMP+"' AND Z40_TIPO = 'DCF' AND Z40_DATDE <= '"+dtos(dDataBase)+"' AND Z40_DATATE >= '"+dtos(dDataBase)+"' AND D_E_L_E_T_ = '' "
	If chkfile("_DCF")
		dbSelectArea("_DCF")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_DCF" NEW

	cSQL := ""                 
	cSQL += "SELECT Z40_PERC FROM "+RetSqlName("Z40")+" WHERE Z40_MARCA = '"+_TMP->EMP+"' AND Z40_TIPO = 'DVi' AND Z40_DATDE <= '"+dtos(dDataBase)+"' AND Z40_DATATE >= '"+dtos(dDataBase)+"' AND D_E_L_E_T_ = '' "
	If chkfile("_DCVI")
		dbSelectArea("_DCVI")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_DCVI" NEW

	cSQL := ""                 
	cSQL += "SELECT Z40_PERC FROM "+RetSqlName("Z40")+" WHERE Z40_MARCA = '"+_TMP->EMP+"' AND Z40_TIPO = 'DVp' AND Z40_DATDE <= '"+dtos(dDataBase)+"' AND Z40_DATATE >= '"+dtos(dDataBase)+"' AND D_E_L_E_T_ = '' "
	If chkfile("_DCVP")
		dbSelectArea("_DCVP")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_DCVP" NEW


	//Realiza o calculo da Margem           
	cVlrFt		:= Round((_TMP->VALOR+_TMP->DESCZF),2)
	cVlrPr		:= Round((_TMP->VALOR+_TMP->DESCZF)/((1+nFator)^_TMP2->PZM),2)
	cVlrImp		:= _TMP2->IMPOSTO
	cVlrINSS	:= Round((cVlrFt * 1 / 100),2)
	cVlrRLC 	:= cVlrPr - (cVlrImp + cVlrINSS)			//SUBTOTAL

	cVlrCP 		:= _TMP->CP
	cVlrMC 		:= cVlrRLC - cVlrCP							//SUBTOTAL

	cDAO 		:= Round((_DAO->Z40_PERC*cVlrFt)/100,2)
	cDCF 		:= Round((_DCF->Z40_PERC*cVlrFt)/100,2)
	cDCVc 		:= _TMP->COMISSAO
	cDCVi 		:= Round((_DCVI->Z40_PERC*cVlrFt)/100,2)
	cDCVp 		:= Round((_DCVP->Z40_PERC*cVlrFt)/100,2)
	cVlrMC2 	:= cVlrMC - (cDAO+cDCF+cDCVc+cDCVi+cDCVp)
	//cPercMC2	:= Round((cVlrMC2/cVlrPr)*100,2)			//SUBTOTAL
	cPercMC2	:= Round((cVlrMC2/cVlrFt)*100,2)			//SUBTOTAL
	rPercMC2	:= cPercMC2		

	cVlrFt		:= Transform(cVlrFt,	"@E 999,999,999.99")
	cVlrPr		:= Transform(cVlrPr,	"@E 999,999,999.99")
	cVlrImp		:= Transform(cVlrImp,	"@E 999,999,999.99")
	cVlrINSS	:= Transform(cVlrINSS,	"@E 999,999,999.99")
	cVlrCP 		:= Transform(cVlrCP, 	"@E 999,999,999.99")
	cVlrRLC 	:= Transform(cVlrRLC, 	"@E 999,999,999.99")
	cVlrMC 		:= Transform(cVlrMC, 	"@E 999,999,999.99")
	cDAO 		:= Transform(cDAO, 		"@E 999,999,999.99")
	cDCF 		:= Transform(cDCF, 		"@E 999,999,999.99")
	cDCVc 		:= Transform(cDCVc, 	"@E 999,999,999.99")
	cDCVi 		:= Transform(cDCVi, 	"@E 999,999,999.99")
	cDCVp 		:= Transform(cDCVp, 	"@E 999,999,999.99")
	cVlrMC2 	:= Transform(cVlrMC2, 	"@E 999,999,999.99")
	cPercMC2	:= Transform(cPercMC2, 	"@E 999,999,999.99")

	If cEmpAnt <> "14"
		If lFlag <> "3" //1 ou 2

			//ATUALIZA CAMPO SC5
			cSQL := "UPDATE "+RetSqlName("SC5")+" SET C5_YPERCMC = '"+Alltrim(Str(rPercMC2))+"' WHERE C5_NUM = '"+nNumPed+"' AND D_E_L_E_T_ = ''	"
			TcSqlExec(cSQL)

			//ATUALIZA CAMPO SC6
			cSQL := "UPDATE "+RetSqlName("SC6")+" SET C6_YPERCMC = ROUND((VPF-(IMP+INSS+CP+DAO+DCF+DCVc+DCVi+DCVp))/VPF*100,2) "
			cSQL += "FROM "
			cSQL += "(SELECT C6_NUM AS PEDIDO, C6_PRODUTO AS PRODUTO, C6_ITEM AS ITEM, "
			cSQL += "		ROUND ((C6_VALOR-C6_YDESCZF)/POWER(1+"+Alltrim(Str(nFator))+","+Alltrim(Str(_TMP2->PZM))+"),2) VPF,"
			cSQL += "		C6_YVLTICM+C6_YVLTCOF+C6_YVLTPIS AS IMP,  "
			cSQL += "		ROUND((((C6_VALOR-C6_YDESCZF)*1)/100),2) INSS, " 
			cSQL += "		CP = CASE "
			cSQL += "				WHEN SUBSTRING(C6_YEMP,1,2) = '13' THEN ROUND((SELECT dbo.FN_CM(SUBSTRING(C6_YEMP,1,2),C6_PRODUTO,C6_LOCAL,C6_YEMISSA))*C6_QTDVEN,2) "
			cSQL += "				ELSE ROUND((SELECT dbo.FN_CP(SUBSTRING(C6_YEMP,1,2),C6_PRODUTO,C6_YEMISSA,C6_YEMISSA))*C6_QTDVEN,2) "
			cSQL += "			END, "
			//cSQL += "		ROUND((SELECT dbo.FN_CP(SUBSTRING(C6_YEMP,1,2),C6_PRODUTO,C6_YEMISSA,C6_YEMISSA))*C6_QTDVEN,2) AS CP, "
			cSQL += "		ROUND((((C6_VALOR-C6_YDESCZF)*C6_COMIS1)/100)+(((C6_VALOR-C6_YDESCZF)*C6_COMIS2)/100)+(((C6_VALOR-C6_YDESCZF)*C6_COMIS3)/100)+(((C6_VALOR-C6_YDESCZF)*C6_COMIS4)/100)+(((C6_VALOR-C6_YDESCZF)*C6_COMIS5)/100),2) AS DCVc,      "
			cSQL += "		ROUND((((C6_VALOR-C6_YDESCZF)*"+Alltrim(Str(_DAO->Z40_PERC))+")/100),2) DAO, "
			cSQL += "		ROUND((((C6_VALOR-C6_YDESCZF)*"+Alltrim(Str(_DCF->Z40_PERC))+")/100),2) DCF, "
			cSQL += "		ROUND((((C6_VALOR-C6_YDESCZF)*"+Alltrim(Str(_DCVI->Z40_PERC))+")/100),2) DCVi, "
			cSQL += "		ROUND((((C6_VALOR-C6_YDESCZF)*"+Alltrim(Str(_DCVP->Z40_PERC))+")/100),2) DCVp "
			cSQL += "FROM "+RetSqlName("SC6")+" "
			cSQL += "WHERE C6_NUM = '"+nNumPed+"' AND D_E_L_E_T_ = '') TMP1, "+RetSqlName("SC6")+" "
			cSQL += "WHERE PEDIDO  = C6_NUM 	AND "	
			cSQL += "	   PRODUTO = C6_PRODUTO	AND "
			cSQL += "	   ITEM    = C6_ITEM 	AND "
			cSQL += "      D_E_L_E_T_ = '' 			"
			TcSqlExec(cSQL)

		EndIf
	EndIf

	If lFlag <> "2" //1 ou 3 

		/*                                       
		DEFINE MSDIALOG oDlg TITLE "Cálculo da Margem" FROM 000, 000  TO 400, 285 COLORS 0, 16777215 PIXEL

		@ 008, 011 MSPANEL oPanel1 SIZE 120, 043 OF oDlg COLORS 0, 16777215 RAISED
		@ 030, 000 SAY oSay4 PROMPT "Valor RLC" SIZE 036, 007 OF oPanel1 FONT oFont1 COLORS 128, 16777215 PIXEL   
		@ 000, 035 SAY oSay11 PROMPT "=" SIZE 000, 007 OF oSay4 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 028, 058 MSGET nVlrRLC VAR cVlrRLC SIZE 060, 012 OF oPanel1 COLORS 128, 16777215 FONT oFont1 READONLY PIXEL
		@ 031, 047 SAY oSay12 PROMPT "=" SIZE 007, 007 OF oPanel1 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 017, 000 SAY oSay21 PROMPT "Valor Impostos" SIZE 050, 007 OF oPanel1 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 017, 048 SAY oSay22 PROMPT "-" SIZE 006, 007 OF oPanel1 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 015, 058 MSGET nVlrImp VAR cVlrImp SIZE 060, 011 OF oPanel1 COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 003, 000 SAY oSay10 PROMPT "Valor Presente" SIZE 050, 007 OF oPanel1 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 004, 048 SAY oSay1 PROMPT "+" SIZE 006, 007 OF oPanel1 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 002, 058 MSGET nVlrPr VAR cVlrPr SIZE 060, 011 OF oPanel1 COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 057, 011 MSPANEL oPanel3 SIZE 121, 030 OF oDlg COLORS 0, 16777215 RAISED
		@ 004, 000 SAY oSay14 PROMPT "Valor CP" SIZE 035, 007 OF oPanel3 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 004, 049 SAY oSay5 PROMPT "-" SIZE 006, 006 OF oPanel3 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 001, 059 MSGET nVlrCP VAR cVlrCP SIZE 060, 011 OF oPanel3 COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 017, 000 SAY oSay13 PROMPT "Valor MC" SIZE 037, 007 OF oPanel3 FONT oFont1 COLORS 128, 16777215 PIXEL 
		@ 015, 059 MSGET nVlrMC VAR cVlrMC SIZE 060, 012 OF oPanel3 COLORS 128, 16777215 FONT oFont1 READONLY PIXEL
		@ 016, 048 SAY oSay15 PROMPT "=" SIZE 007, 007 OF oPanel3 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 094, 011 MSPANEL oPanel4 SIZE 121, 101 OF oDlg COLORS 0, 16777215 RAISED
		@ 006, 000 SAY oSay16 PROMPT "Valor DAO" SIZE 038, 007 OF oPanel4 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 005, 049 SAY oSay2 PROMPT "-" SIZE 006, 007 OF oPanel4 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 003, 059 MSGET nDAO VAR cDAO SIZE 060, 011 OF oPanel4 COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 019, 000 SAY oSay9 PROMPT "Valor DCF" SIZE 035, 007 OF oPanel4 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 033, 000 SAY oSay17 PROMPT "Valor DCVc" SIZE 039, 007 OF oPanel4 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 045, 000 SAY oSay18 PROMPT "Valor DCVp" SIZE 039, 007 OF oPanel4 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 058, 000 SAY oSay19 PROMPT "Valor DCVi" SIZE 039, 007 OF oPanel4 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 017, 059 MSGET nDCF VAR cDCF SIZE 060, 011 OF oPanel4 COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 075, 000 SAY oSay3 PROMPT "Valor MC2" SIZE 038, 007 OF oPanel4 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 071, 059 MSGET nVlrMC2 VAR cVlrMC2 SIZE 060, 012 OF oPanel4 COLORS 128, 16777215 FONT oFont1 READONLY PIXEL
		@ 088, 000 SAY oSay8 PROMPT "% MC2" SIZE 032, 009 OF oPanel4 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 085, 059 MSGET nPercMC2 VAR cPercMC2 SIZE 060, 012 OF oPanel4 COLORS 128, 16777215 FONT oFont1 READONLY PIXEL
		@ 019, 048 SAY oSay6 PROMPT "-" SIZE 006, 007 OF oPanel4 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 033, 048 SAY oSay7 PROMPT "-" SIZE 006, 007 OF oPanel4 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 046, 048 SAY oSay20 PROMPT "-" SIZE 006, 007 OF oPanel4 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 059, 048 SAY oSay23 PROMPT "-" SIZE 006, 007 OF oPanel4 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 075, 048 SAY oSay24 PROMPT "=" SIZE 007, 007 OF oPanel4 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 124, 070 MSGET nDCVc VAR cDCVc SIZE 060, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 138, 070 MSGET nDCVp VAR cDCVp SIZE 060, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 151, 070 MSGET nDCVi VAR cDCVi SIZE 060, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 READONLY PIXEL

		ACTIVATE MSDIALOG oDlg CENTERED
		*/

		DEFINE MSDIALOG oDlg TITLE "Cálculo da Margem" FROM 000, 000  TO 470, 320 COLORS 0, 16777215 PIXEL

		@ 025, 006 MSPANEL oPanel2 SIZE 147, 059 OF oDlg COLORS 0, 16777215 RAISED
		@ 046, 001 SAY oSay4 PROMPT "Valor RLC" SIZE 036, 007 OF oPanel2 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 000, 035 SAY oSay11 PROMPT "=" SIZE 000, 007 OF oSay4 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 043, 085 MSGET nVlrRLC VAR cVlrRLC SIZE 060, 012 OF oPanel2 COLORS 128, 16777215 FONT oFont1 READONLY PIXEL
		@ 046, 077 SAY oSay12 PROMPT "=" SIZE 007, 007 OF oPanel2 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 017, 000 SAY oSay21 PROMPT "Vlr. Pis+Cofins+Icms" SIZE 075, 007 OF oPanel2 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 016, 077 SAY oSay22 PROMPT "-" SIZE 006, 007 OF oPanel2 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 015, 085 MSGET nVlrImp VAR cVlrImp SIZE 060, 011 OF oPanel2 COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 003, 001 SAY oSay10 PROMPT "Valor Presente" SIZE 072, 007 OF oPanel2 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 004, 077 SAY oSay1 PROMPT "+" SIZE 006, 007 OF oPanel2 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 002, 085 MSGET nVlrPr VAR cVlrPr SIZE 060, 011 OF oPanel2 COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 032, 001 SAY oSay25 PROMPT "Valor  INSS 1%" SIZE 075, 007 OF oPanel2 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 030, 077 SAY oSay26 PROMPT "-" SIZE 006, 007 OF oPanel2 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 029, 085 MSGET nVlrINSS VAR cVlrINSS SIZE 060, 011 OF oPanel2 COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 090, 006 MSPANEL oPanel3 SIZE 147, 030 OF oDlg COLORS 0, 16777215 RAISED
		@ 004, 002 SAY oSay14 PROMPT "Vlr. CP (Custo Padrão)" SIZE 072, 007 OF oPanel3 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 004, 077 SAY oSay5 PROMPT "-" SIZE 006, 006 OF oPanel3 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 001, 085 MSGET nVlrCP VAR cVlrCP SIZE 060, 011 OF oPanel3 COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 017, 003 SAY oSay13 PROMPT "Valor MC" SIZE 037, 007 OF oPanel3 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 015, 085 MSGET nVlrMC VAR cVlrMC SIZE 060, 012 OF oPanel3 COLORS 128, 16777215 FONT oFont1 READONLY PIXEL
		@ 017, 077 SAY oSay15 PROMPT "=" SIZE 007, 007 OF oPanel3 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 127, 006 MSPANEL oPanel4 SIZE 147, 101 OF oDlg COLORS 0, 16777215 RAISED
		@ 006, 001 SAY oSay16 PROMPT "Valor DAO" SIZE 038, 007 OF oPanel4 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 005, 077 SAY oSay2 PROMPT "-" SIZE 006, 007 OF oPanel4 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 003, 085 MSGET nDAO VAR cDAO SIZE 060, 011 OF oPanel4 COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 019, 001 SAY oSay9 PROMPT "Valor DCF" SIZE 035, 007 OF oPanel4 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 033, 001 SAY oSay17 PROMPT "Valor DCVc" SIZE 039, 007 OF oPanel4 FONT oFont2 COLORS 0, 16777215 PIXEL
		//@ 045, 001 SAY oSay18 PROMPT "Valor DCVp" SIZE 039, 007 OF oPanel4 FONT oFont2 COLORS 0, 16777215 PIXEL
		//@ 058, 001 SAY oSay19 PROMPT "Valor DCVi" SIZE 039, 007 OF oPanel4 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 045, 001 SAY oSay18 PROMPT "Vlr DCVCLI" SIZE 039, 007 OF oPanel4 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 058, 001 SAY oSay19 PROMPT "Vlr DCVFAB" SIZE 039, 007 OF oPanel4 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 017, 085 MSGET nDCF VAR cDCF SIZE 060, 011 OF oPanel4 COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 075, 001 SAY oSay3 PROMPT "Valor MC2" SIZE 038, 007 OF oPanel4 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 071, 085 MSGET nVlrMC2 VAR cVlrMC2 SIZE 060, 012 OF oPanel4 COLORS 128, 16777215 FONT oFont1 READONLY PIXEL
		@ 088, 002 SAY oSay8 PROMPT "% MC2" SIZE 032, 009 OF oPanel4 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 085, 085 MSGET nPercMC2 VAR cPercMC2 SIZE 060, 012 OF oPanel4 COLORS 128, 16777215 FONT oFont1 READONLY PIXEL
		@ 019, 077 SAY oSay6 PROMPT "-" SIZE 006, 007 OF oPanel4 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 033, 077 SAY oSay7 PROMPT "-" SIZE 006, 007 OF oPanel4 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 046, 077 SAY oSay20 PROMPT "-" SIZE 006, 007 OF oPanel4 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 059, 077 SAY oSay23 PROMPT "-" SIZE 006, 007 OF oPanel4 FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 075, 077 SAY oSay24 PROMPT "=" SIZE 007, 007 OF oPanel4 FONT oFont1 COLORS 128, 16777215 PIXEL
		@ 030, 085 MSGET nDCVc VAR cDCVc SIZE 060, 011 OF oPanel4 COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 044, 085 MSGET nDCVp VAR cDCVp SIZE 060, 011 OF oPanel4 COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 057, 085 MSGET nDCVi VAR cDCVi SIZE 060, 011 OF oPanel4 COLORS 0, 16777215 FONT oFont2 READONLY PIXEL
		@ 004, 006 MSPANEL oPanel1 SIZE 147, 015 OF oDlg COLORS 0, 16777215 RAISED
		@ 003, 002 SAY oSay27 PROMPT "Valor Futuro" SIZE 045, 007 OF oPanel1 FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 001, 085 MSGET nVlrFt VAR cVlrFt SIZE 060, 011 OF oPanel1 COLORS 0, 16777215 FONT oFont2 READONLY PIXEL

		ACTIVATE MSDIALOG oDlg CENTERED

	Else
		nRet := rPercMC2
	EndIf

Return(nRet)

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
//Fernando/Facile em 25/08/2015 - validar e chamar funcao de composicao desconto
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
User Function B660CPOL()
	Local aArea := GetArea()
	Local aAreaC5 := SC5->(GetArea())
	Local aAreaC6 := SC6->(GetArea())
	Local _cItem

	If (Type("N") <> "U") .And. (N > 0) .And. (Len(aCols) >= N)

		SC5->(DbSetOrder(1))
		SC5->(DbSeek(XFilial("SC5")+UZ7->UZ7_PEDIDO))

		_cItem 	:= aCols[N][aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})] 

		SC6->(DbSetOrder(1))
		SC6->(DbSeek(XFilial("SC5")+UZ7->UZ7_PEDIDO+_cItem))

		U_BPOLTST1(.T., .F., .T.)

	EndIf

	RestArea(aAreaC5)
	RestArea(aAreaC6)
	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fMargem3         ³ Ranisses A. Corona º Data ³  04/12/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para calcular a Margem no Pedido a Liberar = MC     º±±
±±º          ³ Parametro: Pedido => Numero Pedido de Venda                º±±
±±º          ³            1,2,3  => 1 -> Calcula e Exibe Mensagem         º±±
±±º          ³                      2 -> Apenas Calcula                   º±±
±±º          ³                      3 -> Apenas Exibe                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fMargem3(nNumPed,lFlag)
	Local nRet	 	:= 0
	Local cSQL   	:= ""
	Local nFator 	:= 0

	Local nCPfix	:= 0
	Local nCPvar 	:= 0
	Local nDAO 		:= 0
	Local nDCF 		:= 0
	Local nDCVc 	:= 0
	Local nDCVCLI 	:= 0
	Local nDCVFAB 	:= 0
	Local nIMP 		:= 0
	Local nINSS 	:= 0
	Local nMB 		:= 0
	Local nMC 		:= 0
	Local nMO 		:= 0
	Local nPercMO 	:= 0
	Local nRB		:= 0
	Local nRL		:= 0
	Local nVOL		:= 0
	Local nVP		:= 0
	Local oFont1 	:= TFont():New("Lucida Sans Typewriter",,018,,.F.,,,,,.F.,.F.)
	Local oFont2 	:= TFont():New("Lucida Sans Typewriter",,018,,.T.,,,,,.F.,.F.)
	Local oGroup2
	Local oGroup3
	Local oGroup4
	Local oGroup5
	Local oGroup6
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local oSay8
	Local oSay9
	Local oSay10
	Local oSay11
	Local oSay12
	Local oSay13
	Local oSay14
	Local oSay15
	Local oSay16
	Local oSay17

	Static oDlg  


	cSQL := ""
	cSQL += "SELECT C5_CLIENTE, C5_CONDPAG, SUM(C6_QTDVEN) QUANTIDADE, SUM(C6_VALOR) VALOR " + CRLF
	If cEmpAnt == "07"

		SM0->(DbSetOrder(1))
		SM0->(DbSeek(cEmpAnt+cFilAnt))	
		_nFator		:= U_LMFatRed(SM0->M0_ESTCOB)

		cSQL += "	,BS_INS_DES = CASE " + CRLF
		cSQL += "					WHEN C6_YEMISSA <= '20150630' THEN ISNULL(ROUND(SUM((C6_VALOR-C6_YDESCZF)*0.9),2),0) " + CRLF
		cSQL += "					WHEN C6_YEMISSA > '20150630' THEN ISNULL(ROUND(SUM((C6_VALOR-C6_YDESCZF)*"+AllTrim(Str(_nFator))+"),2),0) " + CRLF	
		cSQL += "					ELSE ISNULL(ROUND(SUM((C6_VALOR-C6_YDESCZF)*"+AllTrim(Str(_nFator))+"),2),0) " + CRLF
		cSQL += "				END " + CRLF
	Else
		cSQL += "	,SUM(C6_VALOR-C6_YDESCZF) BS_INS_DES " + CRLF
	EndIf
	cSQL += "		,SUM(COMISSAO) COMISSAO, SUM(ROUND((C6_QTDVEN*CVU),2)) CV, SUM(ROUND((C6_QTDVEN*CFU),2)) CF, SUM(C6_YDESCZF) AS DESCZF, MAX(C6_YEMP) AS EMP, MAX(C5_YSUBTP) AS TIPO, MAX(C5_YPEDORI) PEDORI " + CRLF
	cSQL += "FROM 														" + CRLF
	cSQL += "(SELECT 													" + CRLF
	cSQL += "					CVU = CASE 								" + CRLF
	cSQL += "							WHEN C5_YEMP = '1399' THEN (SELECT dbo.FN_CM(SUBSTRING(C6_YEMP,1,2),C6_PRODUTO,C6_LOCAL,C6_YEMISSA)) " + CRLF
	cSQL += "							WHEN C5_YEMP = '1301' THEN 0 	" + CRLF
	cSQL += "							WHEN C5_YEMP = '1401' THEN 0 	" + CRLF
	cSQL += "							ELSE (SELECT dbo.FN_CV(SUBSTRING(C6_YEMP,1,2),C6_PRODUTO,C6_YEMISSA,C6_YEMISSA)) 	" + CRLF
	cSQL += "					  	END,								" + CRLF
	cSQL += "					CFU = CASE 								" + CRLF
	cSQL += "							WHEN C5_YEMP = '1399' THEN 0 	" + CRLF
	cSQL += "							WHEN C5_YEMP = '1301' THEN 0 	" + CRLF
	cSQL += "							WHEN C5_YEMP = '1401' THEN 0 	" + CRLF
	cSQL += "							ELSE (SELECT dbo.FN_CF(SUBSTRING(C6_YEMP,1,2),C6_PRODUTO,C6_YEMISSA,C6_YEMISSA)) " + CRLF
	cSQL += "					  	END,								" + CRLF
	cSQL += "					C6_QTDVEN, (C6_VALOR-C6_YDESCZF) AS C6_VALOR, C6_YDESCZF, C6_YEMP,				" + CRLF
	cSQL += "					ROUND((((C6_VALOR-C6_YDESCZF)*C6_COMIS1)/100)+									" + CRLF
	cSQL += "						  (((C6_VALOR-C6_YDESCZF)*C6_COMIS2)/100)+									" + CRLF
	cSQL += "						  (((C6_VALOR-C6_YDESCZF)*C6_COMIS3)/100)+									" + CRLF
	cSQL += "						  (((C6_VALOR-C6_YDESCZF)*C6_COMIS4)/100)+									" + CRLF
	cSQL += "						  (((C6_VALOR-C6_YDESCZF)*C6_COMIS5)/100),2) AS COMISSAO, C5_YSUBTP, C5_YPEDORI, C5_CONDPAG, C6_YEMISSA, C5_CLIENTE " + CRLF
	cSQL += "FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SC6")+" SC6 " + CRLF
	cSQL += "WHERE	C5_FILIAL		= '"+xFilial("SC5")+"' AND " + CRLF 
	cSQL += "		C6_FILIAL		= '"+xFilial("SC6")+"' AND " + CRLF
	cSQL += "		C5_NUM			= C6_NUM		AND " + CRLF
	cSQL += "		C5_NUM			= '"+nNumPed+"'	AND " + CRLF
	cSQL += "		SC6.D_E_L_E_T_ 	= '' 			AND	" + CRLF
	cSQL += "		SC5.D_E_L_E_T_ 	= '' ) AS TMP		" + CRLF
	cSQL += "GROUP BY C5_CLIENTE, C5_CONDPAG, C6_YEMISSA			" + CRLF
	If chkfile("_TMP")
		dbSelectArea("_TMP")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_TMP" NEW

	//Calcula MO somente nas vendas para o Cliente Final
	If cEmpAnt <> "07" .And. Alltrim(_TMP->C5_CLIENTE) == "010064"
		If lFlag <> "2"
			Msgbox("A Margem Operacional (MO) é cálculada somente nas vendas para o Cliente final!","BIA660","STOP")
		EndIf
		Return(nRet)
	EndIf

	//Verifica se o campo C6_YEMP esta preenchido
	IF Empty(Alltrim(_TMP->EMP))
		MsgAlert("Existem campos que não estão preenchidos nos itens de pedidos. Favor informar o Setor de TI.")
		Return(nRet)
	EndIf

	cSQL := ""
	cSQL += "SELECT C5_EMISSAO, C5_YEMP, (SELECT E4_YMEDIA FROM SE4010 WHERE E4_CODIGO = C5_CONDPAG AND D_E_L_E_T_ = '') PZM, (C5_YVLTICM+C5_YVLTCOF+C5_YVLTPIS) IMPOSTO " + CRLF
	cSQL += "FROM "+RetSqlName("SC5")+"  " + CRLF
	cSQL += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = '"+nNumPed+"' AND D_E_L_E_T_ = ''	" + CRLF
	If chkfile("_TMP2")
		dbSelectArea("_TMP2")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_TMP2" NEW

	//Alteração da gravação da Taxa Financeira, conforme OS 2349-15
	nFator	:= U_fBuscaTxBI(_TMP2->C5_YEMP,"TXF",_TMP2->C5_EMISSAO)
	IF nFator == 0
	CONOUT("ESTOU AQUI************************")
		MsgBox("Favor verificar o preenchimento da tabela Parametros BI (Z40), pois a Taxa Financeira (TXF) esta vencida para a Marca "+_TMP2->C5_YEMP+". Entre em contato com a Controladoria ou Direção Administrativa.","BIA660","STOP")
		CONOUT("ESTOU AQUI************************VOU DAR RETURN")
		Return(nRet)
	EndIf

	cSQL := ""                 
	cSQL += "SELECT ISNULL(Z40_PERC,0) PERC FROM "+RetSqlName("Z40")+" WHERE Z40_FILIAL = '"+xFilial("Z40")+"' AND Z40_MARCA = '"+_TMP->EMP+"' AND Z40_TIPO = 'DAO' AND Z40_DATDE <= '"+dtos(dDataBase)+"' AND Z40_DATATE >= '"+dtos(dDataBase)+"' AND D_E_L_E_T_ = '' "
	If chkfile("_DAO")
		dbSelectArea("_DAO")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_DAO" NEW

	cSQL := ""                 
	cSQL += "SELECT ISNULL(Z40_PERC,0) PERC FROM "+RetSqlName("Z40")+" WHERE Z40_FILIAL = '"+xFilial("Z40")+"' AND Z40_MARCA = '"+_TMP->EMP+"' AND Z40_TIPO = 'DCF' AND Z40_DATDE <= '"+dtos(dDataBase)+"' AND Z40_DATATE >= '"+dtos(dDataBase)+"' AND D_E_L_E_T_ = '' "
	If chkfile("_DCF")
		dbSelectArea("_DCF")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_DCF" NEW

	cSQL := ""                 
	cSQL += "SELECT ISNULL(Z40_PERC,0) PERC FROM "+RetSqlName("Z40")+" WHERE Z40_FILIAL = '"+xFilial("Z40")+"' AND Z40_MARCA = '"+_TMP->EMP+"' AND Z40_TIPO = 'DVi' AND Z40_DATDE <= '"+dtos(dDataBase)+"' AND Z40_DATATE >= '"+dtos(dDataBase)+"' AND D_E_L_E_T_ = '' "
	If chkfile("_DCVI")
		dbSelectArea("_DCVI")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_DCVI" NEW

	cSQL := ""                 
	cSQL += "SELECT ISNULL(Z40_PERC,0) PERC FROM "+RetSqlName("Z40")+" WHERE Z40_FILIAL = '"+xFilial("Z40")+"' AND Z40_MARCA = '"+_TMP->EMP+"' AND Z40_TIPO = 'DVp' AND Z40_DATDE <= '"+dtos(dDataBase)+"' AND Z40_DATATE >= '"+dtos(dDataBase)+"' AND D_E_L_E_T_ = '' "
	If chkfile("_DCVP")
		dbSelectArea("_DCVP")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_DCVP" NEW

	cSQL := ""                 
	cSQL += "SELECT ISNULL(Z40_PERC,0) PERC FROM "+RetSqlName("Z40")+" WHERE Z40_FILIAL = '"+xFilial("Z40")+"' AND Z40_MARCA = '"+_TMP->EMP+"' AND Z40_TIPO = 'INS' AND Z40_DATDE <= '"+dtos(dDataBase)+"' AND Z40_DATATE >= '"+dtos(dDataBase)+"' AND D_E_L_E_T_ = '' "
	If chkfile("_INSS")
		dbSelectArea("_INSS")
		dbCloseArea()
	EndIf
	TCQUERY cSQL ALIAS "_INSS" NEW

	//Informações do Pedido
	nVOL		:= _TMP->QUANTIDADE
	nRB			:= _TMP->VALOR //NA QUERY _TMP É FEITO A CONTA VALOR-DESCZF

	//Cálculo da RL
	nVP			:= Round((nRB)/((1+nFator)^_TMP2->PZM),2)
	nIMP		:= _TMP2->IMPOSTO
	nINSS		:= Round((_INSS->PERC*_TMP->BS_INS_DES/100),2)
	nRL			:= nVP - (nIMP + nINSS)

	//Cálculo da MC
	nCPvar 		:= _TMP->CV
	nMC 		:= nRL - nCPvar

	//Cálculo da MB
	nCPfix 		:= _TMP->CF
	nMB 		:= nMC - nCPfix

	//Cálculo da MO
	If _TMP2->C5_EMISSAO >= "20160701" //A partir de 01/07/2016 o cálculo do DAO/DCF serão calculos pela RL  
		nDAO 	:= Round((_DAO->PERC*nRL)/100,2)
		nDCF 	:= Round((_DCF->PERC*nRL)/100,2)
	Else
		nDAO 	:= Round((_DAO->PERC*nRB)/100,2)
		nDCF 	:= Round((_DCF->PERC*nRB)/100,2)
	EndIf
	nDCVc 		:= _TMP->COMISSAO
	nDCVCLI 	:= Round((_DCVI->PERC*nRB)/100,2)
	nDCVFAB		:= Round((_DCVP->PERC*nRB)/100,2)
	nMO 		:= nMB - (nDAO+nDCF+nDCVc+nDCVCLI+nDCVFAB)
	nPercMO		:= Round((nMO/nRL)*100,2)			
	rPercMO		:= nPercMO		

	nVOL		:= Transform(nVOL,		"@E 999,999,999.99")
	nRB			:= Transform(nRB,		"@E 999,999,999.99")
	nVP			:= Transform(nVP,		"@E 999,999,999.99")
	nIMP		:= Transform(nIMP,		"@E 999,999,999.99")
	nINSS 		:= Transform(nINSS, 	"@E 999,999,999.99")
	nRL 		:= Transform(nRL, 		"@E 999,999,999.99")
	nCPvar 		:= Transform(nCPvar,	"@E 999,999,999.99")
	nMC 		:= Transform(nMC, 		"@E 999,999,999.99")
	nCPfix 		:= Transform(nCPfix,	"@E 999,999,999.99")
	nMB 		:= Transform(nMB, 		"@E 999,999,999.99")
	nDAO 		:= Transform(nDAO, 		"@E 999,999,999.99")
	nDCF 		:= Transform(nDCF, 		"@E 999,999,999.99")
	nDCVc 		:= Transform(nDCVc, 	"@E 999,999,999.99")
	nDCVCLI		:= Transform(nDCVCLI,	"@E 999,999,999.99")
	nDCVFAB		:= Transform(nDCVFAB, 	"@E 999,999,999.99")
	nMO			:= Transform(nMO, 		"@E 999,999,999.99")
	nPercMO		:= Transform(nPercMO, 	"@E 999,999,999.99")

	If cEmpAnt <> "14"
		If lFlag <> "3" //1 ou 2

			//ATUALIZA CAMPO SC5
			cSQL := "UPDATE "+RetSqlName("SC5")+" SET C5_YPERCMC = '"+Alltrim(Str(rPercMO))+"' WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = '"+nNumPed+"' AND D_E_L_E_T_ = ''	" 
			TcSqlExec(cSQL)

			//ATUALIZA CAMPO SC6
			cSQL := "UPDATE "+RetSqlName("SC6")+" SET C6_YPERCMC = ROUND((MB-(DAO+DCF+DCVc+DCVi+DCVp))/RL*100,2) " + CRLF 
			cSQL += "FROM " + CRLF
			cSQL += "(SELECT VPF-(IMP+INSS) AS RL, VPF-(IMP+INSS+CV) AS MC, VPF-(IMP+INSS+CV+CF) AS MB, " + CRLF 
			If _TMP2->C5_EMISSAO >= "20160701" //A partir de 01/07/2016 o cálculo do DAO/DCF serão calculos pela RL
				cSQL += "		ROUND(((VPF-(IMP+INSS))*"+Alltrim(Str(_DAO->PERC))+")/100,2) AS DAO,	" + CRLF 
				cSQL += "		ROUND(((VPF-(IMP+INSS))*"+Alltrim(Str(_DCF->PERC))+")/100,2) AS DCF,	" + CRLF
			Else
				cSQL += "		ROUND((RB*"+Alltrim(Str(_DAO->PERC))+")/100,2) AS DAO,					" + CRLF 
				cSQL += "		ROUND((RB*"+Alltrim(Str(_DCF->PERC))+")/100,2) AS DCF,					" + CRLF
			EndIf
			cSQL += "  		*																			" + CRLF
			cSQL += "FROM																				" + CRLF 		
			cSQL += "(SELECT C6_NUM AS PEDIDO, C6_PRODUTO AS PRODUTO, C6_ITEM AS ITEM, 	" + CRLF
			cSQL += "		(C6_VALOR-C6_YDESCZF) RB,									" + CRLF 
			cSQL += "		ROUND ((C6_VALOR-C6_YDESCZF)/POWER(1+"+Alltrim(Str(nFator))+","+Alltrim(Str(_TMP2->PZM))+"),2) VPF," + CRLF
			cSQL += "		C6_YVLTICM+C6_YVLTCOF+C6_YVLTPIS AS IMP,  " + CRLF
			If cEmpAnt == "07"

				SM0->(DbSetOrder(1))
				SM0->(DbSeek(cEmpAnt+cFilAnt))	
				_nFator		:= U_LMFatRed(SM0->M0_ESTCOB)

				cSQL += "		INSS = CASE WHEN C6_YEMISSA <= '20150630' THEN ROUND(((((C6_VALOR-C6_YDESCZF*0.9))*"+Alltrim(Str(_INSS->PERC))+")/100),2) ELSE ROUND(((((C6_VALOR-C6_YDESCZF*"+AllTrim(Str(_nFator))+"))*"+Alltrim(Str(_INSS->PERC))+")/100),2) END, " + CRLF
			Else
				cSQL += "		ROUND((((C6_VALOR-C6_YDESCZF)*"+Alltrim(Str(_INSS->PERC))+")/100),2) INSS, " + CRLF 
			EndIf
			cSQL += "		CV = CASE 								" + CRLF 
			cSQL += "				WHEN C6_YEMP IN ('1399','1302') THEN ROUND((SELECT dbo.FN_CM(SUBSTRING(C6_YEMP,1,2),C6_PRODUTO,C6_LOCAL,C6_YEMISSA))*C6_QTDVEN,2) " + CRLF 
			cSQL += "				WHEN C6_YEMP IN ('1301','1401') THEN 0 " + CRLF 
			cSQL += "				ELSE ROUND((SELECT dbo.FN_CV(SUBSTRING(C6_YEMP,1,2),C6_PRODUTO,C6_YEMISSA,C6_YEMISSA))*C6_QTDVEN,2) " + CRLF
			cSQL += "		  	END,								" + CRLF 
			cSQL += "		CF = CASE 								" + CRLF 
			cSQL += "				WHEN C6_YEMP IN ('1399','1302') THEN 0" + CRLF 
			cSQL += "				WHEN C6_YEMP IN ('1301','1401') THEN 0 " + CRLF 
			cSQL += "				ELSE ROUND((SELECT dbo.FN_CF(SUBSTRING(C6_YEMP,1,2),C6_PRODUTO,C6_YEMISSA,C6_YEMISSA))*C6_QTDVEN,2) " + CRLF 
			cSQL += "			END,								" + CRLF 
			cSQL += "		ROUND((((C6_VALOR-C6_YDESCZF)*C6_COMIS1)/100)+(((C6_VALOR-C6_YDESCZF)*C6_COMIS2)/100)+(((C6_VALOR-C6_YDESCZF)*C6_COMIS3)/100)+(((C6_VALOR-C6_YDESCZF)*C6_COMIS4)/100)+(((C6_VALOR-C6_YDESCZF)*C6_COMIS5)/100),2) AS DCVc,      " + CRLF
			cSQL += "		ROUND((((C6_VALOR-C6_YDESCZF)*"+Alltrim(Str(_DCVI->PERC))+")/100),2) DCVi, " + CRLF
			cSQL += "		ROUND((((C6_VALOR-C6_YDESCZF)*"+Alltrim(Str(_DCVP->PERC))+")/100),2) DCVp " + CRLF
			cSQL += "FROM "+RetSqlName("SC6")+" " + CRLF
			cSQL += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+nNumPed+"' AND D_E_L_E_T_ = '') TMP1) TMP2, "+RetSqlName("SC6")+" " + CRLF
			cSQL += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND " + CRLF 
			cSQL += "	   PEDIDO  = C6_NUM 	AND " + CRLF	
			cSQL += "	   PRODUTO = C6_PRODUTO	AND " + CRLF
			cSQL += "	   ITEM    = C6_ITEM 	AND " + CRLF
			cSQL += "      D_E_L_E_T_ = '' 			" + CRLF
			TcSqlExec(cSQL)

		EndIf
	EndIf

	If lFlag <> "2" //1 ou 3 

		DEFINE MSDIALOG oDlg TITLE "Cálculo Margem Operacional (MO)" FROM 000, 000  TO 610, 345 COLORS 0, 16777215 PIXEL

		@ 008, 010 GROUP oGroup2 TO 042, 163 OF oDlg COLOR 0, 16777215 PIXEL
		@ 048, 010 GROUP oGroup3 TO 110, 163 OF oDlg COLOR 0, 16777215 PIXEL
		@ 115, 010 GROUP oGroup4 TO 149, 163 OF oDlg COLOR 0, 16777215 PIXEL
		@ 156, 010 GROUP oGroup5 TO 190, 163 OF oDlg COLOR 0, 16777215 PIXEL
		@ 196, 010 GROUP oGroup6 TO 295, 163 OF oDlg COLOR 0, 16777215 PIXEL

		//@ 017, 012 SAY oSay1 PROMPT "Volume(VOL)         " SIZE 088, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 017, 012 SAY oSay1 PROMPT "Volume(VOL)         " OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 017, 101 SAY nVOL  OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
		//@ 015, 101 MSGET nVOL VAR nVOL SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

		//@ 030, 012 SAY oSay2 PROMPT "Receita Bruta(RB)    " SIZE 088, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 030, 012 SAY oSay2 PROMPT "Receita Bruta(RB)    " OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 030, 101 SAY nRB   OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
		//@ 028, 101 MSGET nRB VAR nRB SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

		//@ 057, 012 SAY oSay3 PROMPT "Valor Presente(VP)   +" SIZE 089, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 057, 012 SAY oSay3 PROMPT "Valor Presente    (VP)+" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 057, 101 SAY nVP 	  OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
		//@ 055, 101 MSGET nVP VAR nVP SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

		//@ 070, 012 SAY oSay4 PROMPT "PIS+COFINS+ICMS(IMP) -" SIZE 088, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 070, 012 SAY oSay4 PROMPT "PIS+COFINS+ICMS  (IMP)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 070, 101 SAY nIMP  OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
		//@ 068, 101 MSGET nIMP VAR nIMP SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

		//@ 083, 012 SAY oSay5 PROMPT "%INSS Deson.(IMP)    -" SIZE 088, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 083, 012 SAY oSay5 PROMPT "%INSS Deson.     (IMP)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 083, 101 SAY nINSS OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
		//@ 081, 101 MSGET nINSS VAR nINSS SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

		//@ 096, 012 SAY oSay6 PROMPT "Receita Líquida(RL)  =" SIZE 088, 007 OF oDlg FONT oFont2 COLORS 16711680, 16777215 PIXEL
		@ 096, 012 SAY oSay6 PROMPT "Receita Líquida   (RL)=" OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 096, 101 SAY nRL OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
		//@ 094, 101 MSGET nRL VAR nRL SIZE 060, 010 OF oDlg COLORS 128, 16777215 FONT oFont2 PIXEL

		//@ 123, 012 SAY oSay7 PROMPT "Custo Variável(CPvar)-" SIZE 088, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 123, 012 SAY oSay7 PROMPT "Custo Variável (CPvar)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 123, 101 SAY nCPvar OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
		//@ 121, 101 MSGET nCPvar VAR nCPvar SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

		//@ 136, 012 SAY oSay8 PROMPT "Margem Bruta(MB)     =" SIZE 088, 007 OF oDlg FONT oFont2 COLORS 16711680, 16777215 PIXEL
		@ 136, 012 SAY oSay8 PROMPT "Margem Contrib.   (MC)=" OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 136, 101 SAY nMC OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
		//@ 134, 101 MSGET nMB VAR nMB SIZE 060, 010 OF oDlg COLORS 16711680, 16777215 FONT oFont2 PIXEL

		//@ 163, 012 SAY oSay9 PROMPT "Custo Fixo(CPfix)    -" SIZE 088, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 163, 012 SAY oSay9 PROMPT "Custo Fixo     (CPfix)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 163, 101 SAY nCPfix OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
		//@ 161, 101 MSGET nCPfix VAR nCPfix SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

		//@ 176, 012 SAY oSay10 PROMPT "Margem Contrib.(MC)  =" SIZE 088, 007 OF oDlg FONT oFont2 COLORS 16711680, 16777215 PIXEL
		@ 176, 012 SAY oSay10 PROMPT "Margem Bruta      (MB)=" OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 176, 101 SAY nMB OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
		//@ 174, 101 MSGET nMC VAR nMC SIZE 060, 010 OF oDlg COLORS 16711680, 16777215 FONT oFont2 PIXEL

		//@ 204, 012 SAY oSay11 PROMPT "Desp. Adm. Oper.(DAO)-" SIZE 089, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 204, 012 SAY oSay11 PROMPT "Desp. Adm. Oper. (DAO)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 204, 101 SAY nDAO OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
		//@ 202, 101 MSGET nDAO VAR nDAO SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

		//@ 217, 012 SAY oSay12 PROMPT "Desp. Com. Fixa(DCF) -" SIZE 088, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 217, 012 SAY oSay12 PROMPT "Desp. Com. Fixa  (DCF)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 217, 101 SAY nDCF OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
		//@ 215, 101 MSGET nDCF VAR nDCF SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

		//@ 230, 012 SAY oSay13 PROMPT "Comissão(DCVc)       -" SIZE 088, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 230, 012 SAY oSay13 PROMPT "Comissão        (DCVc)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 230, 101 SAY nDCVc OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
		//@ 228, 101 MSGET nDCVc VAR nDCVc SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

		//@ 243, 012 SAY oSay14 PROMPT "Invest. Cli.(DCVCLI) -" SIZE 088, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 243, 012 SAY oSay14 PROMPT "Invest. Cli.  (DCVCLI)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 243, 101 SAY nDCVCLI OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
		//@ 241, 101 MSGET nDCVCLI VAR nDCVCLI SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

		//@ 256, 012 SAY oSay15 PROMPT "Invest. Emp.(DCVFAB) -" SIZE 088, 007 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 256, 012 SAY oSay15 PROMPT "Invest. Emp.  (DCVFAB)-" OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL
		@ 256, 101 SAY nDCVFAB OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL
		//@ 254, 101 MSGET nDCVFAB VAR nDCVFAB SIZE 060, 010 OF oDlg COLORS 0, 16777215 FONT oFont1 PIXEL

		//@ 269, 012 SAY oSay16 PROMPT "Margem Oper.(MO)     =" SIZE 089, 007 OF oDlg FONT oFont2 COLORS 16711680, 16777215 PIXEL
		@ 269, 012 SAY oSay16 PROMPT "Margem Oper.      (MO)=" OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 269, 101 SAY nMO OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
		//@ 267, 101 MSGET nMO VAR nMO SIZE 060, 010 OF oDlg COLORS 128, 16777215 FONT oFont2 PIXEL

		//@ 282, 012 SAY oSay17 PROMPT "% Margem Oper.(MO%)  =" SIZE 088, 007 OF oDlg FONT oFont2 COLORS 16711680, 16777215 PIXEL
		@ 282, 012 SAY oSay17 PROMPT "% Margem Oper.   (MO%)=" OF oDlg FONT oFont2 COLORS 0, 16777215 PIXEL
		@ 282, 101 SAY nPercMO OF oDlg COLORS 0, 16777215 FONT oFont2 PIXEL
		//@ 280, 101 MSGET nPercMO VAR nPercMO SIZE 060, 010 OF oDlg COLORS 16711680, 16777215 FONT oFont2 PIXEL

		ACTIVATE MSDIALOG oDlg CENTERED

	Else
		nRet := rPercMO
	EndIf

Return(nRet)
