#include "rwmake.ch"
#Include "TOPCONN.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA819     ³ Autor ³ Ranisses A. Corona    ³ Data ³ 18/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera arquivo para Serasa - PEFIN                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BIA819()

	Pergunte("BIA819",.T.)

	Private nTipMov		:= MV_PAR01
	Private nTipAcao	:= MV_PAR02
	Private	dDataDe		:= Dtos(MV_PAR03)
	Private dDataAte	:= Dtos(MV_PAR04)
	Private nCaminho	:= MV_PAR05

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Variaveis utilizadas para parametros						 																		³
	³ MV_PAR01  // Tipo Movimento Serasa (1 - Titulos Envio / 2 - Titulos Exclusao				³
	³ MV_PAR02  // Tipo Acao (1 - Selecao/Manutencao / 2 - Gerar Arquivo									³
	³ MV_PAR03  // Data De																																³
	³ MV_PAR04  // Data Ate																																³
	³ MV_PAR05  // Caminho para Gerar o Arquivo																						³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/

	@ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Integração Serasa - PEFIN"
	@ 08,10 TO 84,222
	@ 16,12 SAY "Esta rotina tem por finalidade: "
	@ 24,12 SAY "Selecionar os títulos a serem enviandos para o Serasa"
	@ 32,12 SAY "utilizando o sistema PEFIN - Pendencias Financeira."

	@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
	@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
	@ 91,137 BMPBUTTON TYPE 5 ACTION Pergunte("BIA819", .T.)

	ACTIVATE DIALOG oDlg1 CENTERED

	If chkfile("CTRAB")
		dbSelectArea("CTRAB")
		dbCloseArea()
	EndIf
	If chkfile("TRAB1")
		dbSelectArea("TRAB1")
		dbCloseArea()
	EndIf
	If chkfile("TRAB2")
		dbSelectArea("TRAB2")
		dbCloseArea()
	EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Monta tela do MarkBrowser                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function OkProc()
	Private cSql	   := ""
	Private Enter	   := chr(13) + Chr(10)
	Private TITINC   := {} //Titulos para serem incluidos
	Private TITEXC	 := {} //Titulos para serem excluidos
	Private cTitInc  := ""
	Private cTitExc  := ""
	Private nContInc := 0
	Private nContExc := 0
	Private cMarca   := GetMark()  //Define variavel de marcacao dos Titulos
	Private cTit     := ""
	Private cDescr	 := ""

	//Fecha caixa dialogo1
	Close(oDlg1)

	If nTipAcao == 1 //Selecao/Marcacao

		If nTipMov == 1 //Seleciona Titulos para Inclusao

			cTit	:= "Integração Serasa - PEFIN - INCLUSÃO"
			cDesc := "Selecione os títulos a serem incluidos no sistema PEFIN - Serasa: "

			//Seleciona os Titulos de acordo com os parametros
			cSql := "SELECT	E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, " 
			cSql += " ( "
			cSql += " 	SELECT A1_EST " 
			cSql += " 	FROM "+ RetSQLName("SA1") 
			cSql += " 	WHERE A1_FILIAL = "+ ValToSQL(xFilial("SA1")) 
			cSql += " 	AND A1_COD = E1_CLIENTE "
			cSql += " 	AND A1_LOJA = E1_LOJA "
			cSql += " 	AND D_E_L_E_T_ = '' "
			cSql += " ) AS A1_EST, "
			cSql += " E1_EMISSAO, E1_VENCTO,	E1_BAIXA, 				" + Enter
			cSql += "	DATEDIFF(day,E1_VENCTO,'"+Dtos(dDataBase)+"') DIASATRASO, E1_VALOR, E1_HIST, E1_YINCSER, E1_YEXCSER, R_E_C_N_O_		" + Enter
			cSql += "FROM	"+RetSqlName("SE1")+" SE1			  	" + Enter
			cSql += "WHERE	E1_FILIAL   = '"+xFilial("SE1")+"' 	AND " + Enter
			cSql += "		E1_VENCTO  >= '"+dDataDe+"' 			AND " + Enter
			cSql += "		E1_VENCTO  <= '"+dDataAte+"' 			AND " + Enter
			cSql += "		E1_VALOR    = E1_SALDO									AND " + Enter // Titulos totalmente em aberto
			cSql += "		E1_TIPO	    NOT IN ('RA','NCC')					AND " + Enter
			cSql += "		E1_NATUREZ <> '1131' 										AND	" + Enter
			cSql += "		(E1_YINCSER = '' OR E1_YINCSER  = '"+Dtos(dDataBase)+"') AND " + Enter
			cSql += "		E1_YFLGISE  = ''												AND	" + Enter
			cSql += "		D_E_L_E_T_ = ''						  				" + Enter
			cSql += "ORDER BY E1_VENCTO, E1_NOMCLI					" + Enter
			If chkfile("TRAB1")
				dbSelectArea("TRAB1")
				dbCloseArea()
			EndIf
			TCQUERY cSql ALIAS "TRAB1" NEW
			DbSelectArea("TRAB1")
			TRAB1->(DbGotop())
			nReg := TRAB1->(RecNo())

		Else //Seleciona Titulos para Exclusao

			cTit	:= "Integração Serasa - PEFIN - EXCLUSÃO"
			cDesc := "Selecione os títulos a serem excluidos do sistema PEFIN - Serasa: "

			//Selecionando os Titulos baixados
			cSql := "SELECT	E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, " 
			cSql += " ( "
			cSql += " 	SELECT A1_EST "
			cSql += " 	FROM "+ RetSQLName("SA1") 
			cSql += " 	WHERE A1_FILIAL = "+ ValToSQL(xFilial("SA1")) 
			cSql += " 	AND A1_COD = E1_CLIENTE "
			cSql += " 	AND A1_LOJA = E1_LOJA "
			cSql += " 	AND D_E_L_E_T_ = '' "
			cSql += " ) AS A1_EST, "
			cSql += " E1_EMISSAO, E1_VENCTO,	E1_BAIXA,					" + Enter
			cSql += "				DATEDIFF(day,E1_VENCTO,'"+Dtos(dDataBase)+"') DIASATRASO, E1_VALOR, E1_HIST, E1_YINCSER, E1_YEXCSER, R_E_C_N_O_		" + Enter
			cSql += "FROM	"+RetSqlName("SE1")+" SE1			  				" + Enter
			cSql += "WHERE	E1_FILIAL	= '"+xFilial("SE1")+"' 	AND " + Enter
			cSql += "			E1_BAIXA		>= '"+dDataDe+"' 				AND " + Enter
			cSql += "			E1_BAIXA		<= '"+dDataAte+"' 			AND " + Enter
			cSql += "			E1_SALDO		=  0	  								AND " + Enter
			cSql += "			E1_STATUS 	=  'B'  								AND " + Enter
			cSql += "			E1_YFLGISE 	<> '' 									AND " + Enter
			cSql += "			E1_YFLGESE  = '' 									AND " + Enter
			cSql += "			D_E_L_E_T_ = ''						  						" + Enter
			cSql += "ORDER BY E1_VENCTO, E1_NOMCLI								" + Enter
			If chkfile("TRAB1")
				dbSelectArea("TRAB1")
				dbCloseArea()
			EndIf
			TCQUERY cSql ALIAS "TRAB1" NEW
			DbSelectArea("TRAB1")
			TRAB1->(DbGotop())
			nReg := TRAB1->(RecNo())
		EndIf

	Else //Geracao do Arquivo

		cTit	:= "Integração Serasa - PEFIN - GERAÇÃO DE ARQUIVOS"
		cDesc := "Exibe os titulos que irão gerar o arquivos do PEFIN - Serasa: "

		//Selecionando os Titulos para Gerar o arquivo
		cSql := "SELECT	E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, 
		cSql += " ( "
		cSql += " 	SELECT A1_EST "
		cSql += " 	FROM "+ RetSQLName("SA1") 
		cSql += " 	WHERE A1_FILIAL = "+ ValToSQL(xFilial("SA1")) 
		cSql += " 	AND A1_COD = E1_CLIENTE "
		cSql += " 	AND A1_LOJA = E1_LOJA "
		cSql += " 	AND D_E_L_E_T_ = '' "
		cSql += " ) AS A1_EST, "	
		cSql += " E1_EMISSAO, E1_VENCTO,	E1_BAIXA,					" + Enter
		cSql += "				DATEDIFF(day,E1_VENCTO,'"+Dtos(dDataBase)+"') DIASATRASO, E1_VALOR, E1_HIST, E1_YINCSER, E1_YEXCSER, R_E_C_N_O_		" + Enter
		cSql += "FROM	"+RetSqlName("SE1")+" SE1			  							" + Enter
		cSql += "WHERE	E1_FILIAL	= '"+xFilial("SE1")+"' 				AND " + Enter
		If nTipMov == 1 //Inclusao
			cSql += "			E1_YINCSER 	= '"+Dtos(dDataBase)+"'			AND " + Enter
			cSql += "			E1_YFLGISE  = '' 							AND " + Enter
		Else						//Exclusao
			cSql += "			E1_YEXCSER 	= '"+Dtos(dDataBase)+"'			AND " + Enter
			cSql += "			E1_YFLGESE  = ''												AND " + Enter
		EndIf
		cSql += "			D_E_L_E_T_ = ''						  									" + Enter
		cSql += "ORDER BY E1_VENCTO, E1_NOMCLI											" + Enter
		If chkfile("TRAB1")
			dbSelectArea("TRAB1")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "TRAB1" NEW
		DbSelectArea("TRAB1")
		TRAB1->(DbGotop())
		nReg := TRAB1->(RecNo())

	EndIf

	//Monta Estrutura
	aStru := {}
	AADD(aStru,{"_OK"			,"C",02,0})
	AADD(aStru,{"E1_PREFIXO"	,"C",03,0})
	AADD(aStru,{"E1_NUM"		,"C",09,0})
	AADD(aStru,{"E1_PARCELA"	,"C",01,0})
	AADD(aStru,{"E1_TIPO"		,"C",02,0})
	AADD(aStru,{"E1_CLIENTE"	,"C",06,0})
	AADD(aStru,{"E1_LOJA"		,"C",02,0})
	AADD(aStru,{"E1_NOMCLI"		,"C",20,0})
	AADD(aStru,{"A1_EST"		,"C",02,0})
	AADD(aStru,{"E1_EMISSAO"	,"D",08,0})
	AADD(aStru,{"E1_VENCTO" 	,"D",08,0})
	AADD(aStru,{"DIASATRASO"	,"N",06,0})
	AADD(aStru,{"E1_BAIXA" 		,"D",08,0})
	AADD(aStru,{"E1_VALOR"		,"N",14,2})
	AADD(aStru,{"E1_HIST"		,"C",25,0})
	AADD(aStru,{"R_E_C_N_O_"	,"N",14,0})
	cTrab := Criatrab(aStru,.T.)
	dbUseArea(.T.,,cTrab,"cTrab",.F.,.F.)
	TRAB1->(DbGotop())

	//Preenche a estrutura criada com os dados selecionados
	While !TRAB1->(EOF())
		RecLock("cTrab",.T.)
		ctrab->_OK				:=  IIf(Empty(IIf(nTipMov==1,TRAB1->E1_YINCSER,TRAB1->E1_YEXCSER)),"",cMarca)
		cTrab->E1_PREFIXO	:=  TRAB1->E1_PREFIXO
		cTrab->E1_NUM 	 	:=  TRAB1->E1_NUM
		cTrab->E1_PARCELA	:=  TRAB1->E1_PARCELA
		cTrab->E1_TIPO	 	:=  TRAB1->E1_TIPO
		cTrab->E1_CLIENTE	:=  TRAB1->E1_CLIENTE
		cTrab->E1_LOJA 	 	:=  TRAB1->E1_LOJA
		cTrab->E1_NOMCLI 	:=  TRAB1->E1_NOMCLI
		cTrab->A1_EST 	  :=  TRAB1->A1_EST
		cTrab->E1_EMISSAO	:=  Stod(TRAB1->E1_EMISSAO)
		cTrab->E1_VENCTO 	:=  Stod(TRAB1->E1_VENCTO)
		cTrab->DIASATRASO	:=  TRAB1->DIASATRASO
		cTrab->E1_BAIXA		:=  Stod(TRAB1->E1_BAIXA)
		cTrab->E1_VALOR 	:=  TRAB1->E1_VALOR
		cTrab->E1_HIST		:=  TRAB1->E1_HIST
		cTrab->R_E_C_N_O_	:=  TRAB1->R_E_C_N_O_
		If !Empty(ctrab->_OK)
			AADD(TITINC,CTRAB->R_E_C_N_O_)
		EndIf
		MsUnLock()
		TRAB1->(DbSkip())
	EndDo
	TRAB1->(DbGoTo(nReg))
	cTrab->(DbGotop())

	//Define Montagem do MarkBrowser
	aCpoBro   := {}
	lInverte  := .F.
	aCpoBro	  :=  { 	{ "_OK"       	,,"  "           	,"@!"},;
	{ "E1_PREFIXO"	,,"Prefixo"      	,"@!"},;
	{ "E1_NUM"    	,,"Numero"       	,"@!"},;
	{ "E1_PARCELA"	,,"Parcela"      	,"@!"},;
	{ "E1_TIPO	"	,,"Tipo"			,"@!"},;
	{ "E1_CLIENTE"	,,"Cliente"    		,"@!"},;
	{ "E1_LOJA"		,,"Loja"		 	,"@!"},;
	{ "E1_NOMCLI"	,,"Nome Cliente" 	,"@!"},;
	{ "A1_EST"		,,"UF"		 	,"@!"},;
	{ "E1_EMISSAO"	,,"Emissão"      	,"@!"},;
	{ "E1_VENCTO"	,,"Vencimento"   	,"@!"},;
	{ "E1_BAIXA"	,,"Data Baixa"   	,"@!"},;
	{ "DIASATRASO"	,,"Atraso"       	,"@E 999999"},;
	{ "E1_VALOR"	,,"Valor"        	,"@E 999,999,999.99"},;
	{ "E1_HIST"		,,"Historico"    	,"@!"}}

	nBotao := Iif(nTipAcao==1,13,1)

	Define MsDialog oDlg2 Title cTit From 009,000 To 040,140
	@005,008   Say cDesc
	@220,450   BmpButton Type nBotao	Action Processa( {|| fProcOk() } )
	@220,480   BmpButton Type 2 		Action close(oDlg2)
	oMark 		:= MsSelect():New("CTRAB","_OK","",aCpoBro,@lInverte,@cMarca,{20,5,210,550})
	oMark:bMark	:= {| | fDisp()}
	If nTipAcao == 2 //Para gravacao do arquivo, bloqueia o markbrowser
		oMark:OBROWSE:LREADONLY := .T. 
	EndIf                           
	Activate MsDialog oDlg2 Centered

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Seleciona/Armazena o RECNO dos Titulos                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fDisp()
	nPos := ""

	If nTipAcao == 1	//Para o movimento de Selecao
		If Marked("_OK")
			AADD(TITINC,CTRAB->R_E_C_N_O_)
		Else
			nPos	:= aScan(TITINC,CTRAB->R_E_C_N_O_)
			If !Empty(nPos)
				TITINC[nPos]	:= 0
			EndIf
			AADD(TITEXC,CTRAB->R_E_C_N_O_)     
		EndIf
	Else				//Para o movimento de Geracao de Arquivo, nao permite desmarcar
		If Marked("_OK")
			RecLock("cTrab",.F.)		
			CTRAB->_OK := ""
		Else
			RecLock("cTrab",.F.)		
			CTRAB->_OK := cMarca
		EndIf
		MsUnLock()	
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Marca/Desmarca Titulos / Gera arquivo de envio                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fProcOk()
	Local I
	Local cEOL		:= CHR(13)+CHR(10)
	Local nLogon	:= ""
	Local nSeqArq	:= GetMv("MV_YNUMSER")			//Sequencial Bordero Serasa
	Local nSeqLin	:= "0000001"								//Sequencial de Linha
	Local nImp		:= .F.											//Variavel para controle de impressao
	Local cArqTxt, nHdl     

	//Variaveis para tratamento da Sequencia do Serasa
	Local aPergs	:= {}
	Local aPergRet  := {}
	Local lRet    

	//Define Logon conforme empresa
	If cEmpAnt == "01"
		nLogon := "87011975"
	ElseIf cEmpAnt == "05"
		nLogon := "87014758"
	ElseIf cEmpAnt == "07"
		nLogon := "37675085"
	Else
		nLogon := ""
	EndIf

	If Empty(nLogon)
		MsgAlert("Não está definido nenhuma informacao de Logon para está Empresa. Favor solicitar ao SERESA, antes de continuar.")
		Return
	EndIf

	//Fecha caixa dialogo2
	Close(oDlg2)

	//Monta arquvivos dos Titulos para Inclusao
	nContInc := Len(TITINC)
	For I := 1 TO nContInc
		If nContInc = 1
			cTitInc := cTitInc + "('"+Alltrim(Str(TITINC[I]))+"')"
		EndIf
		If (nContInc > 1) .And. (I = 1)
			cTitInc := cTitInc + "('"+Alltrim(Str(TITINC[I]))+"',"
		EndIf
		If (nContInc > 1) .And. (I > 1) .And. (I < nContInc)
			cTitInc := cTitInc + "'"+Alltrim(Str(TITINC[I]))+"',"
		EndIf
		If (nContInc > 1) .And. (I > 1) .AND. (I = nContInc)
			cTitInc := cTitInc + "'"+Alltrim(Str(TITINC[I]))+"')"
		EndIf
	Next

	//Monta arquvivos dos Titulos para Exclusao
	nContExc := Len(TITEXC)
	For I := 1 TO nContExc
		If nContExc = 1
			cTitExc := cTitExc + "('"+Alltrim(Str(TITEXC[I]))+"')"
		EndIf
		If (nContExc > 1) .And. (I = 1)
			cTitExc := cTitExc + "('"+Alltrim(Str(TITEXC[I]))+"',"
		EndIf
		If (nContExc > 1) .And. (I > 1) .And. (I < nContExc)
			cTitExc := cTitExc + "'"+Alltrim(Str(TITEXC[I]))+"',"
		EndIf
		If (nContExc > 1) .And. (I > 1) .AND. (I = nContExc)
			cTitExc := cTitExc + "'"+Alltrim(Str(TITEXC[I]))+"')"
		EndIf
	Next


	If nTipAcao == 1	//Selecao/Marcacao

		If nContInc > 0
			If nTipMov == 1 //Inclusao
				//Atualiza Titulos selecionados para envio no Serasa
				cSql := "UPDATE "+RetSqlName("SE1")+" SET E1_YINCSER = '"+Dtos(dDataBase)+"' " + Enter
			Else							//Exclusao
				cSql := "UPDATE "+RetSqlName("SE1")+" SET E1_YEXCSER = '"+Dtos(dDataBase)+"' " + Enter
			EndIf
			cSql += "WHERE	E1_FILIAL   = '"+xFilial("SE1")+"' 	AND " + Enter
			cSql += "		R_E_C_N_O_ IN "+cTitInc+"			AND	" + Enter
			cSql += "		D_E_L_E_T_ = ''										" + Enter
			TcSQLExec(cSql)
		EndIf

		If nContExc > 0
			If nTipMov == 1  //Inclusao
				cSql := "UPDATE "+RetSqlName("SE1")+" SET E1_YINCSER = ''		" + Enter
			Else              //Exclusao
				cSql := "UPDATE "+RetSqlName("SE1")+" SET E1_YEXCSER = ''		" + Enter
			EndIf
			cSql += "WHERE	E1_FILIAL   = '"+xFilial("SE1")+"' 	AND 		" + Enter
			cSql += "		R_E_C_N_O_ IN "+cTitExc+"			AND	" + Enter
			cSql += "		D_E_L_E_T_ = ''										" + Enter
			TcSQLExec(cSql)
		EndIf


		If (nContInc-nContExc) <> 0
			//Pergunta se sera necessario imprimir relatorio
			nImp := MsgBox("Os títulos foram salvos com sucesso. Deseja imprimir os títulos selecionados? ","Informação","YesNo")
			If nImp
				//Chama rotina de impressao
				fImprime()
			EndIf
		Else
			MsgBox("Atualizacao realizada com sucesso.","Informação","INFO")
		EndIf


	Else //Geracao do arquivo

		//Abre tela para correção da sequencia do arquivo, caso necessário
		aAdd( aPergs ,{1,"Sequência Serasa ",nSeqArq,"","","","",06,.T.})   	
		lRet := ParamBox(aPergs, "Parametros ", aPergRet, , , , , , , , .F.,.F.) 
		If lRet
			nSeqArq	:= aPergRet[1]
		EndIf		

		//Seleciona os titulos marcados no browser
		cSql := "SELECT	E1_PREFIXO, E1_NUM, E1_PARCELA, E1_VENCTO, E1_VALOR, A1_NOME, A1_PESSOA, A1_CGC, A1_END, A1_BAIRRO, A1_MUN, A1_EST, A1_CEP  " + Enter
		cSql += "FROM	"+RetSqlName("SE1")+" SE1, "+RetSqlName("SA1")+" SA1 " + Enter
		cSql += "WHERE	SE1.E1_FILIAL   = '"+xFilial("SE1")+"' 	AND " + Enter
		cSql += "		SA1.A1_FILIAL   = '"+xFilial("SA1")+"' 	AND " + Enter
		cSql += "		SE1.E1_CLIENTE  = SA1.A1_COD			AND " + Enter
		cSql += "		SE1.E1_LOJA		= SA1.A1_LOJA			AND " + Enter
		cSql += "		SE1.R_E_C_N_O_ IN "+cTitInc+"			AND	" + Enter
		cSql += "		SE1.D_E_L_E_T_ = ''						AND " + Enter
		cSql += "		SA1.D_E_L_E_T_ = ''						  	" + Enter
		cSql += "ORDER BY E1_VENCTO, A1_NOME					" + Enter
		If chkfile("TRAB2")
			dbSelectArea("TRAB2")
			dbCloseArea()
		EndIf
		TCQUERY cSql ALIAS "TRAB2" NEW

		//Abre o arquivo
		If cEmpAnt == "01" 			// Biancogres
			cArqTxt := "C:\SERASA\BIANCO\"+alltrim(nCaminho)
			cPath		:= "C:\SERASA\BIANCO\"
			cPath := If(Right(cPath,1) == "\", Left(cPath,Len(cPath)-1), cPath)
			aDir  := Directory(cPath,"D")
			If Len(aDir) = 0
				MsgAlert("O diretório "+cPath+" não existe. Favor cria-lo antes de continuar!")
				Return
			EndIf		
		ElseIf cEmpAnt == "05"	//Incesa
			cArqTxt := "C:\SERASA\INCESA\"+alltrim(nCaminho)
			cPath		:= "C:\SERASA\INCESA\"
			cPath := If(Right(cPath,1) == "\", Left(cPath,Len(cPath)-1), cPath)
			aDir  := Directory(cPath,"D")
			If Len(aDir) = 0
				MsgAlert("O diretório "+cPath+" não existe. Favor cria-lo antes de continuar!")
				Return
			EndIf				
		ElseIf cEmpAnt == "07"	//LM
			cArqTxt := "C:\SERASA\LM\"+alltrim(nCaminho)
			cPath		:= "C:\SERASA\LM\"
			cPath := If(Right(cPath,1) == "\", Left(cPath,Len(cPath)-1), cPath)
			aDir  := Directory(cPath,"D")
			If Len(aDir) = 0
				MsgAlert("O diretório "+cPath+" não existe. Favor cria-lo antes de continuar!")
				Return
			EndIf		

		EndIf
		nHdl    := fCreate(cArqTxt)

		//Define o telefone da Empresa
		nTel := Alltrim(Str(FisGetTel(SM0->M0_TEL)[1]))+Alltrim(Str(FisGetTel(SM0->M0_TEL)[2])) +Alltrim(Str(FisGetTel(SM0->M0_TEL)[3]))

		//Monta Registro HEADER
		cLin	:= "00"+Subst(SM0->M0_CGC,1,8)+Dtos(dDataBase)+nTel+"9011"+"VAGNER AMARO DE SALLES"+SPACE(48)+"SERASA-CONVEM04"+nSeqArq+"E"+SPACE(7)+nLogon+SPACE(392)+SPACE(60)+nSeqLin
		fWrite(nHdl,cLin+cEOL)

		dbSelectArea("TRAB2")
		dbGotop()

		//Monta Registro DETALHE
		ProcRegua(nContInc)
		Do While !TRAB2->(EOF())

			IncProc("Gerando Informações PEFIN - "+Alltrim(TRAB2->E1_PREFIXO+TRAB2->E1_NUM+TRAB2->E1_PARCELA))

			nSeqLin	:= Soma1(nSeqLin)

			If nTipMov == 1												//Inclusao
				cLin	:= "1"												//Codigo Registro
				cLin	+= Iif(nTipMov==1,"I","E")		//Codigo Operacao
				cLin	+= Subst(SM0->M0_CGC,9,6)		//Filial e Digito do CNPJ Contratante
				cLin	+= TRAB2->E1_VENCTO						//Data Ocorrencia (Vencimento)
				cLin	+= TRAB2->E1_VENCTO						//Data do Termino contrato (Vencimento)
				cLin	+= " DP"											//Codigo Natureza da Operacao
				cLin	+= SPACE(04)									//Codigo Praca para Embratel
				cLin	+= Alltrim(TRAB2->A1_PESSOA)	//Tipo Pessoa (J / F)
				cLin	+= Iif(TRAB2->A1_PESSOA=="J","1","2")	//Tipo Documento (1-CNPJ / 2-CPF)
				cLin	+= REPLICATE("0",15-LEN(Alltrim(TRAB2->A1_CGC)))+Alltrim(TRAB2->A1_CGC)		//CNPJ ou CPF
				cLin	+= SPACE(02)									//Motivo da Baixa
				cLin	+= SPACE(01)									//Tipo do Segundo Documento Principal
				cLin	+= SPACE(15)									//Segundo Documento Principal
				cLin	+= SPACE(02)									//UF do RG
				cLin	+= SPACE(37)									//Informacoes do Cooperados
				cLin	+= Alltrim(TRAB2->A1_NOME)+REPLICATE(" ",70-LEN(Alltrim(TRAB2->A1_NOME)))	//Razao Social
				cLin	+= "00000000"									//Data de Nascimento
				cLin	+= SPACE(70)									//Nome do Pai
				cLin	+= SPACE(70)									//Nome da Mae
				cLin	+= Subst(TRAB2->A1_END,1,45)	//Endereco
				cLin	+= TRAB2->A1_BAIRRO						//Bairro
				cLin	+= Subst(TRAB2->A1_MUN,1,25)	//Municipio
				cLin	+= Alltrim(TRAB2->A1_EST)			//UF
				cLin	+= Alltrim(TRAB2->A1_CEP)			//CEP
				cLin	+= REPLICATE("0",15-LEN(Alltrim(STR((TRAB2->E1_VALOR)*100))))+Alltrim(STR((TRAB2->E1_VALOR)*100))										//Valor
				cLin	+= Alltrim(TRAB2->E1_NUM)+" "+TRAB2->E1_PARCELA+REPLICATE(" ",16-LEN(Alltrim(TRAB2->E1_NUM)+" "+TRAB2->E1_PARCELA))	//Numero/Parcela do Titulo
				cLin	+= SPACE(09)									//Nosso Numero
				cLin	+= Alltrim(Subst(TRAB2->A1_END,46,15))+REPLICATE(" ",25-LEN(Alltrim(Subst(TRAB2->A1_END,46,15))))										//Complemento do Endereco
				cLin	+= SPACE(04)                	//DDD Telefone Devedor
				cLin	+= SPACE(09)									//Telefone Devedor
				cLin	+= SPACE(08)               		//Data do Compromisso assumido pelo Devedor
				cLin	+= SPACE(15)             			//Valor Total do Compromisso
				cLin	+= SPACE(06)									//Deixar em Branco
				cLin	+= SPACE(01)									//Indica Tipo de Comunicado Devedor (Em branco = FAC / B = Comunicado com Boleto Bancario)
				cLin	+= SPACE(02)                 	//Deixar em Branco
				cLin	+= SPACE(60)                 	//Codigo de erros
				cLin	+= nSeqLin										//Sequencia de Linha

				//Grava o registro no arquivo
				fWrite(nHdl,cLin+cEOL)

			Else																	//Exclusao

				cLin	:= "1"												//Codigo Registro
				cLin	+= Iif(nTipMov==1,"I","E")		//Codigo Operacao
				cLin	+= Subst(SM0->M0_CGC,9,6)		//Filial e Digito do CNPJ Contratante
				cLin	+= TRAB2->E1_VENCTO						//Data Ocorrencia (Vencimento)
				cLin	+= TRAB2->E1_VENCTO						//Data do Termino contrato (Vencimento)
				cLin	+= " DP"											//Codigo Natureza da Operacao
				cLin	+= SPACE(04)									//Codigo Praca para Embratel
				cLin	+= Alltrim(TRAB2->A1_PESSOA)	//Tipo Pessoa (J / F)
				cLin	+= Iif(TRAB2->A1_PESSOA=="J","1","2")	//Tipo Documento (1-CNPJ / 2-CPF)
				cLin	+= REPLICATE("0",15-LEN(Alltrim(TRAB2->A1_CGC)))+Alltrim(TRAB2->A1_CGC)		//CNPJ ou CPF
				cLin	+= "01"												//Motivo da Baixa
				cLin	+= SPACE(01)									//Tipo do Segundo Documento Principal
				cLin	+= SPACE(15)									//Segundo Documento Principal
				cLin	+= SPACE(02)									//UF do RG
				cLin	+= SPACE(37)									//Informacoes do Cooperados
				cLin	+= Alltrim(TRAB2->A1_NOME)+REPLICATE(" ",70-LEN(Alltrim(TRAB2->A1_NOME)))	//Razao Social
				cLin	+= "00000000"									//Data de Nascimento
				cLin	+= SPACE(70)									//Nome do Pai
				cLin	+= SPACE(70)									//Nome da Mae
				cLin	+= Subst(TRAB2->A1_END,1,45)	//Endereco
				cLin	+= TRAB2->A1_BAIRRO						//Bairro
				cLin	+= Subst(TRAB2->A1_MUN,1,25)	//Municipio
				cLin	+= Alltrim(TRAB2->A1_EST)			//UF
				cLin	+= Alltrim(TRAB2->A1_CEP)			//CEP
				cLin	+= REPLICATE("0",15-LEN(Alltrim(STR((TRAB2->E1_VALOR)*100))))+Alltrim(STR((TRAB2->E1_VALOR)*100))										//Valor
				cLin	+= Alltrim(TRAB2->E1_NUM)+" "+TRAB2->E1_PARCELA+REPLICATE(" ",16-LEN(Alltrim(TRAB2->E1_NUM)+" "+TRAB2->E1_PARCELA))	//Numero/Parcela do Titulo
				cLin	+= SPACE(09)									//Nosso Numero
				cLin	+= Alltrim(Subst(TRAB2->A1_END,46,15))+REPLICATE(" ",25-LEN(Alltrim(Subst(TRAB2->A1_END,46,15))))										//Complemento do Endereco
				cLin	+= SPACE(04)                	//DDD Telefone Devedor
				cLin	+= SPACE(09)									//Telefone Devedor
				cLin	+= SPACE(08)               		//Data do Compromisso assumido pelo Devedor
				cLin	+= SPACE(15)             			//Valor Total do Compromisso
				cLin	+= SPACE(06)									//Deixar em Branco
				cLin	+= SPACE(01)									//Indica Tipo de Comunicado Devedor (Em branco = FAC / B = Comunicado com Boleto Bancario)
				cLin	+= SPACE(02)                 	//Deixar em Branco
				cLin	+= SPACE(60)                 	//Codigo de erros
				cLin	+= nSeqLin										//Sequencia de Linha

				//Grava o registro no arquivo
				fWrite(nHdl,cLin+cEOL)

			EndIf

			TRAB2->(DbSkip())

		End Do

		//Monta Registro TRAILLER
		nSeqLin	:= Soma1(nSeqLin)
		cLin	:= "9"+SPACE(592)+nSeqLin
		fWrite(nHdl,cLin+cEOL)

		//Fecha arquivo
		fClose(nHdl)

		//Acertar Sequencial do Arquivo
		nSeqArq := Soma1(nSeqArq)
		PutMV("MV_YNUMSER",nSeqArq)

		//Atualiza Titulos selecionados para envio no Serasa
		If nTipMov == 1	//Inclusao
			cSql := "UPDATE "+RetSqlName("SE1")+" SET E1_YFLGISE = '1', E1_HIST = 'SERS '+SUBSTRING(E1_HIST,1,20) " + Enter
		Else						//Exclusao
			cSql := "UPDATE "+RetSqlName("SE1")+" SET E1_YFLGESE = '1' " + Enter
		EndIf
		cSql += "WHERE	E1_FILIAL   = '"+xFilial("SE1")+"' 	AND " + Enter
		cSql += "		R_E_C_N_O_ IN "+cTitInc+"			AND	" + Enter
		cSql += "		D_E_L_E_T_ = ''										" + Enter
		TcSQLExec(cSql)

		MsgBox("Arquivo gerado com sucesso!","Informação","INFO")	

	EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Imprime relatorio com os Titulos a serem enviados para o Serasa       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fImprime()
	cString    := ""
	cDesc1     := "Este programa tem como objetivo imprimir relatorio	"
	cDesc2     := "com os títulos selecionados para envio do Serasa.	"
	cDesc3     := "																										"
	cTamanho   := "P"
	limite     := 80
	aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	cNomeprog  := "BIA819"
	cPerg      := ""
	aLinha     := {}
	nLastKey   := 0
	cTitulo	   := "Titulos a serem enviandos para o Serasa"
	Cabec1     := ""
	Cabec2     := ""
	nBegin     := 0
	cDescri    := ""
	cCancel    := "***** CANCELADO PELO OPERADOR *****"
	m_pag      := 1
	wnrel      := "BIA819"
	lprim      := .t.
	li         := 80
	nTipo      := 0
	wFlag      := .t.
	lFiltra	   := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT.								     ³
	//³ Verifica Posicao do Formulario na Impressora.				       ³
	//³ Solicita os parametros para a emissao do relatorio			   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                            '

	//wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)

	//Cancela a impressao
	/*If nLastKey == 27
	Return
	Endif*/

	//Seleciona os titulos a serem impressos
	cSql := "ALTER VIEW VW_BIA819 AS	" + Enter
	cSql += "SELECT	E1_PREFIXO, E1_NUM, E1_PARCELA, E1_EMISSAO, E1_VENCTO, E1_BAIXA, E1_VALOR, E1_YINCSER, E1_YEXCSER,									" + Enter
	cSql += "		A1_COD, A1_NOME, A1_PESSOA, A1_CGC, A1_END, A1_BAIRRO, A1_MUN, A1_EST, A1_CEP, DATEDIFF(day,E1_VENCTO,'"+Dtos(dDataBase)+"') ATRASO	" + Enter
	cSql += "FROM	"+RetSqlName("SE1")+" SE1, "+RetSqlName("SA1")+" SA1 " + Enter
	cSql += "WHERE	SE1.E1_FILIAL   = '"+xFilial("SE1")+"' 	AND " + Enter
	cSql += "		SA1.A1_FILIAL   = '"+xFilial("SA1")+"' 	AND " + Enter
	cSql += "		SE1.E1_CLIENTE  = SA1.A1_COD			AND " + Enter
	cSql += "		SE1.E1_LOJA		= SA1.A1_LOJA			AND " + Enter
	cSql += "		SE1.R_E_C_N_O_ IN "+cTitInc+"			AND	" + Enter
	cSql += "		SE1.D_E_L_E_T_ = ''						AND " + Enter
	cSql += "		SA1.D_E_L_E_T_ = ''						  	" + Enter
	TcSQLExec(cSql)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//If aReturn[5]==1
	//Parametros Crystal Em Disco
	Private x:="1;0;1;Serasa"
	//Else
	//Direto Impressora
	//	Private x:="3;0;1;Serasa"
	//Endif

	//Chama o Relatorio em Crystal
	callcrys("BIA819",Alltrim(Str(nTipMov))+";"+Alltrim(Str(nTipAcao))+";"+dDataDe+";"+dDataAte+";"+cempant,x)

Return()