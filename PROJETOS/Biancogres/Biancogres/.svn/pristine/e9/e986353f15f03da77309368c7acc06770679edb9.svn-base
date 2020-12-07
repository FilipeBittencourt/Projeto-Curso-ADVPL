#INCLUDE "PROTHEUS.CH"
#INCLUDE "AP5MAIL.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³BUS_TITULOS³ Autor ³ BRUNO MADALENO        ³ Data ³ 28/01/10   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe os titulos vencidos do cliente	(F3/ACG/SXB)             ³±±
±±³Descri‡„o ³ ESSA FUNCAO FOI COPIADA DA FUNCAO TK274Tit DO FONTE TMKA274   ³±±
±±³Descri‡„o ³ POIS DEVEMOS MOSTRAR OS TITULOS DE TODAS AS EMPRESAS          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TELECOBRANCA                                                  ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER Function BUS_TITULOS()

	Local aTitulos	:= {}										// Array com os titulos vencidos
	Local nOpcao	:= 0										// Opcao de confirmacao
	Local nCampo	:= 0										// Controle para carregar o acols
	Local nTitulo	:= 1										// Titulo selecionado
	Local oDlg													// Dialog com Titulos
	Local oTitulos												// Listbox com titulos vencidos
	Local oOk		:= LoaDbitmap(GetResources(),"LBOK")		// X Verde
	Local oNo		:= LoaDbitmap(GetResources(),"LBNO")		// X Vermelho
	Local lFlag		:= .F.										// Define se o titulo sera marcado ou desmarcado
	Local oVerd		:= LoaDbitmap(GetResources(),"ENABLE")		// Bitmap Verde
	Local oVerm		:= LoaDbitmap(GetResources(),"DISABLE")		// Bitmap Vermelho
	Local lVencido	:= .F.										// Define se o titulo esta vencido ou nao
	Local nPTitulo	:= aPosicoes[1][2]                         	// Posicao do Titulo
	Local nPPrefix	:= aPosicoes[2][2]							// Posicao do Prefixo
	Local nPParcel	:= aPosicoes[3][2]							// Posicao da Parcela
	Local nPTipo	:= aPosicoes[4][2]							// Posicao do Tipo
	Local nPRecebe	:= aPosicoes[11][2]							// Valor a Receber do Titulo
	Local nPJuros	:= aPosicoes[12][2]							// Valor de Juros do Titulo
	Local nPValRef	:= aPosicoes[28][2]							// Valor de Referencia
	Local nPBaixa   := aPosicoes[29][2]							// Log de Baixa
	Local nPStatus  := aPosicoes[30][2]	   						// Status do Atendimento
	Local nPPromoc	:= aPosicoes[16][2]							// Codigo da Promocao de cobranca
	Local nPDescFi	:= aPosicoes[13][2]							// Posicao do desconto financeiro
	Local nPDescJu	:= 0										// Posicao do desconto sobre os juros
	Local lRet		:= .F.										// Retorno da funcao
	Local oTodos												// Objeto de selecao
	Local lTodos	:= .F.										// Valor do objeto de selecao
	Local oInverte												// Objeto de selecao
	Local lInverte	:= .F.										// Valor do objeto de selecao
	Local cSK1		:= "SK1"									// Alias temporario de controle
	Local cSE1		:= "SE1"									// Alias temporario de controle
	Local aValores	:= {}										// Array com todos os valores para o rodape.
	Local oBmp1													// Objeto da legenda
	Local oBmp2													// Objeto da legenda
	Local aButtons	:= {}										// Botoes da tool bar
	Local oPanel												// Painel de pesquisa
	Local oPrefixo												// Objetos de pesquisa
	Local oNum													// Objetos de pesquisa
	Local oParcela												// Objetos de pesquisa
	Local oTipo													// Objetos de pesquisa
	Local oVencimento											// Objetos de pesquisa
	Local oVencOrig												// Objetos de pesquisa
	Local oHistorico											// Objetos de pesquisa
	Local oNaturez												// Objetos de pesquisa
	Local oPortado												// Objetos de pesquisa
	Local oNumBor												// Objetos de pesquisa
	Local oEmissao												// Objetos de pesquisa
	Local oVencRea												// Objetos de pesquisa
	Local lPrefixo		:= .F.									// Variaveis de pesquisa
	Local lNum			:= .F.									// Variaveis de pesquisa
	Local lParcela		:= .F.									// Variaveis de pesquisa
	Local lTipo			:= .F.									// Variaveis de pesquisa
	Local lVencimento	:= .F.									// Variaveis de pesquisa
	Local lVencOrig		:= .F.									// Variaveis de pesquisa
	Local lHistorico	:= .F.									// Variaveis de pesquisa
	Local lNaturez		:= .F.									// Variaveis de pesquisa
	Local lPortado		:= .F.									// Variaveis de pesquisa
	Local lNumBor		:= .F.									// Variaveis de pesquisa
	Local lEmissao		:= .F.									// Variaveis de pesquisa
	Local lVencRea		:= .F.									// Variaveis de pesquisa
	Local oExpressao											// Objetos de pesquisa
	Local cExpressao	:= Space(100)							// Variaveis de pesquisa
	Local nLenAux		:= 0 									// Variavel auxiliar para o FOR/NEXT
	Local nLenaHead		:= 0 									// Variavel auxiliar para o FOR/NEXT
	Local nPFilOrig		:= 0                                   	// Posicao da filial de origem do titulo da tabela SK1
	Local nPFilACG 		:= 0                                   	// Posicao da filial de origem do titulo da tabela ACG
	Local cFilOrig		:= ""									// Filial de Origem do titulo
	Local aRet			:= {}  									// Retorno da funcao que calcula os juros do titulo baseado nos parametros do sigaloja
	Local nPMulta		:= 0									// Posicao do campo ACG_MULTA que armazena o valor de multa nos itens do atendimento de telecobranca  (somente para integracao com sigaloja)
	Local cTmkJuros		:= GetNewPar("MV_TMKAJUR","1")			// Define se o calculo de juros sera baseado nos campos do financeiro ou nos parametros do sigaloja.  1-Financeiro, 2- Sigaloja
	Local lMV_TMKTLCT	:= SuperGetMv("MV_TMKTLCT")				// Le o parametro para carregar os titulos a vencer. Somente quando a selecao de titulos for MANUAL.
	Local aBkRdpTlc		:= {}									// Armazena o Rodape para reprocessamento dos descontos
	Local aFilAux     := {}                 // Filial auxiliar para o DBSeek , pois tem tabelas SE1070 com filial 05 e outras
	Local nFilAux     := 1                  // Filial auxiliar para o DBSeek , pois tem tabelas SE1070 com filial 05 e outras

	#IFDEF TOP
		Local cQuery	:= ""									// Query para TOP
		Local aStruSK1	:= SK1->(DbStruct())					// Estrutura do Alias SK1
		Local aStruSE1	:= SE1->(DbStruct())					// Estrutura do Alias SE1
		Local nI		:= 0 									// Contador de loop
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Recupera posicao do campo ACG_DESCJU³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aPosicoes) >= 32
		nPDescJu := aPosicoes[32][2]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Evita que entre nesta tela caso seja Simulacao de Valores do Telecobranca|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IsInCallStack("Tk274Simul")
		Return(.T.)
	EndIf

	If (SK1->(FieldPos("K1_FILORIG"))  > 0)
		nPFilOrig	:= Ascan(aHeader, {|x| x[2] == "K1_FILORIG"} )
	Endif

	If (ACG->(FieldPos("ACG_FILORI"))  > 0)
		nPFilACG 	:= Ascan(aHeader, {|x| x[2] == "ACG_FILORI"} )
	Endif

	If (ACG->(FieldPos("ACG_MULTA "))  > 0)
		nPMulta		:= Ascan(aHeader, {|x| x[2] == "ACG_MULTA "} )
	Endif

	CursorWait()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Seleciona os titulos atrasados do cliente atual.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SK1")
	DbSetOrder(4)		// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)

	DbSelectArea("SA1")
	DbSetOrder(1)
	dbSeek(xFilial("SA1")+M->ACF_CLIENT+M->ACF_LOJA,.F.)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³DbSelectArea no SE1 para abrir o arquivo on Demand     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SE1")
	DbSetOrder(1)


	#IFDEF TOP
		cSK1	:= "TMPSK1"				// Alias temporario do SK1
		cSE1	:= "TMPSK1"				// Alias temporario do SK1
		// *****************************************************************************************************
		// BUSCANDO BIANCOGRES
		// *****************************************************************************************************
		//"		SK1.K1_CLIENTE 	= '" + M->ACF_CLIENT + "' AND" +;
			//"		SK1.K1_LOJA 	= '" + M->ACF_LOJA + "' AND" +;
			cQuery	:=	" SELECT	'BI' AS EMPRESA, K1_FILIAL, K1_CLIENTE, K1_LOJA, K1_NUM, K1_PARCELA, K1_TIPO, K1_PREFIXO, K1_NUM, K1_PARCELA, K1_TIPO, " +;
			" 			E1_FILIAL, E1_VENCREA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_VENCTO, E1_VENCORI, " +;
			" 			E1_LOJA, E1_NATUREZ, E1_PORTADO, E1_NUMBOR, E1_EMISSAO, E1_VENCREA, E1_VALOR, E1_SALDO, E1_HIST " +;
			" FROM SK1010 SK1, SE1010 SE1, SA1010 SA1 " +;
			" WHERE	SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND SK1.K1_FILIAL 	= '" + xFilial("SK1") + "' AND" +;
			"		SK1.K1_CLIENTE 	= A1_COD AND " +;
			"		SK1.K1_LOJA 	= A1_LOJA AND " +;
			"		SK1.K1_OPERAD 	<> 'XXXXXX' AND" +;
			"		SK1.D_E_L_E_T_ 	= '' AND"

		IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
			cQuery += "		SA1.A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND 	SA1.A1_YTIPOLC = 'G' AND "
		ELSE
			cQuery += "		SA1.A1_COD = '"+ACF_CLIENT+"' AND SA1.A1_LOJA = '"+ACF_LOJA+"'	AND "
		END IF

		cQuery+=	"	'01' 	= SK1.K1_FILORIG 	AND"

		cQuery+= "		SE1.E1_PREFIXO 	= SK1.K1_PREFIXO 	AND"
		cQuery+= "		SE1.E1_NUM 		= SK1.K1_NUM 		AND"
		cQuery+= "		SE1.E1_PARCELA 	= SK1.K1_PARCELA 	AND"
		cQuery+= "		SE1.E1_TIPO 	= SK1.K1_TIPO 		AND"
		cQuery+= "		SE1.E1_SALDO    > 0  AND "
		cQuery+= "		SE1.D_E_L_E_T_ 	= '' AND SA1.D_E_L_E_T_ 	= '' "
		//	cQuery+= " 		ORDER BY " + SqlOrder(IndexKey())

		cQuery	+=	" UNION ALL "
		// *****************************************************************************************************
		// BUSCANDO INCESA
		// *****************************************************************************************************
		cQuery	+=	" SELECT	'IN' AS EMPRESA, K1_FILIAL, K1_CLIENTE, K1_LOJA, K1_NUM, K1_PARCELA, K1_TIPO, K1_PREFIXO, K1_NUM, K1_PARCELA, K1_TIPO, " +;
			" 			E1_FILIAL, E1_VENCREA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_VENCTO, E1_VENCORI, " +;
			" 			E1_LOJA, E1_NATUREZ, E1_PORTADO, E1_NUMBOR, E1_EMISSAO, E1_VENCREA, E1_VALOR, E1_SALDO, E1_HIST " +;
			" FROM SK1010 SK1, SE1050 SE1, SA1010 SA1  " +;
			" WHERE	SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND SK1.K1_FILIAL 	= '" + xFilial("SK1") + "' AND" +;
			"		SK1.K1_CLIENTE 	= A1_COD AND " +;
			"		SK1.K1_LOJA 	= A1_LOJA AND " +;
			"		SK1.K1_OPERAD 	<> 'XXXXXX' AND" +;
			"		SK1.D_E_L_E_T_ 	= '' AND"

		IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
			cQuery += "		SA1.A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND SA1.A1_YTIPOLC = 'G' AND "
		ELSE
			cQuery += "		SA1.A1_COD = '"+ACF_CLIENT+"' AND SA1.A1_LOJA = '"+ACF_LOJA+"'	AND "
		END IF

		cQuery+=	"	'05' 	= SK1.K1_FILORIG 	AND"

		cQuery+= "		SE1.E1_PREFIXO 	= SK1.K1_PREFIXO 	AND"
		cQuery+= "		SE1.E1_NUM 		= SK1.K1_NUM 		AND"
		cQuery+= "		SE1.E1_PARCELA 	= SK1.K1_PARCELA 	AND"
		cQuery+= "		SE1.E1_TIPO 	= SK1.K1_TIPO 		AND"
		cQuery+= "		SE1.E1_SALDO    > 0  AND "
		cQuery+= "		SE1.D_E_L_E_T_ 	= '' AND SA1.D_E_L_E_T_ 	= '' "
		//	cQuery+= " 		ORDER BY " + SqlOrder(IndexKey())

		cQuery	+=	" UNION ALL "
		// *****************************************************************************************************
		// BUSCANDO EMPRESA LM
		// *****************************************************************************************************
		cQuery	+=	" SELECT	'LM' AS EMPRESA, K1_FILIAL, K1_CLIENTE, K1_LOJA, K1_NUM, K1_PARCELA, K1_TIPO, K1_PREFIXO, K1_NUM, K1_PARCELA, K1_TIPO, " +;
			" 			E1_FILIAL, E1_VENCREA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_VENCTO, E1_VENCORI, " +;
			" 			E1_LOJA, E1_NATUREZ, E1_PORTADO, E1_NUMBOR, E1_EMISSAO, E1_VENCREA, E1_VALOR, E1_SALDO, E1_HIST " +;
			" FROM SK1010 SK1, SE1070 SE1, SA1010 SA1 " +;
			" WHERE	SE1.E1_FILIAL in ('01','05') AND SK1.K1_FILIAL 	= '" + xFilial("SK1") + "' AND" +;
			"		SK1.K1_CLIENTE 	= A1_COD AND " +;
			"		SK1.K1_LOJA 	= A1_LOJA AND " +;
			"		SK1.K1_OPERAD 	<> 'XXXXXX' AND" +;
			"		SK1.D_E_L_E_T_ 	= '' AND"

		IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
			cQuery += "		SA1.A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND SA1.A1_YTIPOLC = 'G' AND "
		ELSE
			cQuery += "		SA1.A1_COD = '"+ACF_CLIENT+"' AND SA1.A1_LOJA = '"+ACF_LOJA+"'	AND "
		END IF

		cQuery+=	"	'07' 	= SK1.K1_FILORIG 	AND"

		cQuery+= "		SE1.E1_PREFIXO 	= SK1.K1_PREFIXO 	AND"
		cQuery+= "		SE1.E1_NUM 		= SK1.K1_NUM 		AND"
		cQuery+= "		SE1.E1_PARCELA 	= SK1.K1_PARCELA 	AND"
		cQuery+= "		SE1.E1_TIPO 	= SK1.K1_TIPO 		AND"
		cQuery+= "		SE1.E1_SALDO    > 0  AND "
		cQuery+= "		SE1.D_E_L_E_T_ 	= '' AND SA1.D_E_L_E_T_ 	= '' "

		// Vitcer - OS: 2087-14 - Usuário: Clebes Jose Andre
		cQuery	+=	" UNION ALL "
		// *****************************************************************************************************
		// BUSCANDO EMPRESA VITCER
		// *****************************************************************************************************
		cQuery	+=	" SELECT	'VC' AS EMPRESA, K1_FILIAL, K1_CLIENTE, K1_LOJA, K1_NUM, K1_PARCELA, K1_TIPO, K1_PREFIXO, K1_NUM, K1_PARCELA, K1_TIPO, " +;
			" 			E1_FILIAL, E1_VENCREA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_VENCTO, E1_VENCORI, " +;
			" 			E1_LOJA, E1_NATUREZ, E1_PORTADO, E1_NUMBOR, E1_EMISSAO, E1_VENCREA, E1_VALOR, E1_SALDO, E1_HIST " +;
			" FROM SK1010 SK1, SE1140 SE1, SA1010 SA1 " +;
			" WHERE	SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND SK1.K1_FILIAL 	= '" + xFilial("SK1") + "' AND" +;
			"		SK1.K1_CLIENTE 	= A1_COD AND " +;
			"		SK1.K1_LOJA 	= A1_LOJA AND " +;
			"		SK1.K1_OPERAD 	<> 'XXXXXX' AND" +;
			"		SK1.D_E_L_E_T_ 	= '' AND"

		IF ALLTRIM(SA1->A1_GRPVEN) <> "" .AND. SA1->A1_YTIPOLC == "G"
			cQuery += "		SA1.A1_GRPVEN = '"+SA1->A1_GRPVEN+"' AND SA1.A1_YTIPOLC = 'G' AND "
		ELSE
			cQuery += "		SA1.A1_COD = '"+ACF_CLIENT+"' AND SA1.A1_LOJA = '"+ACF_LOJA+"'	AND "
		END IF

		cQuery+=	"	'14' 	= SK1.K1_FILORIG 	AND"

		cQuery+= "		SE1.E1_PREFIXO 	= SK1.K1_PREFIXO 	AND"
		cQuery+= "		SE1.E1_NUM 		= SK1.K1_NUM 		AND"
		cQuery+= "		SE1.E1_PARCELA 	= SK1.K1_PARCELA 	AND"
		cQuery+= "		SE1.E1_TIPO 	= SK1.K1_TIPO 		AND"
		cQuery+= "		SE1.E1_SALDO    > 0  AND "
		cQuery+= "		SE1.D_E_L_E_T_ 	= '' AND SA1.D_E_L_E_T_ 	= '' "

		cQuery+= " 		ORDER BY " + SqlOrder(IndexKey())

		cQuery	:= ChangeQuery(cQuery)
		MemoWrite("TK274F3.SQL", cQuery)
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cSK1, .F., .T.)

		DbSelectArea(cSK1)
		For nI := 1 To Len(aStruSK1)
			If aStruSK1[nI][2] $ "NDL" .AND. FieldPos(aStruSK1[nI][1]) > 0
				TCSetField(cSK1, aStruSK1[nI][1], aStruSK1[nI][2], aStruSK1[nI][3], aStruSK1[nI][4])
			Endif
		Next nI

		For nI := 1 To Len(aStruSE1)
			If aStruSE1[nI][2] $ "NDL" .AND. FieldPos(aStruSE1[nI][1]) > 0
				TCSetField(cSK1, aStruSE1[nI][1], aStruSE1[nI][2], aStruSE1[nI][3], aStruSE1[nI][4])
			Endif
		Next nI
	#ELSE
		DbSelectArea("SK1")
		DbSetOrder(4)		// K1_FILIAL+K1_CLIENTE+K1_LOJA+DTOS(K1_VENCREA)
		DbSeek(xFilial("SK1")+M->ACF_CLIENT+M->ACF_LOJA)
	#ENDIF

	//While	!(cSK1)->(Eof())						.AND.;
		//		(cSK1)->K1_FILIAL  == xFilial("SK1")	.AND.;
		//		(cSK1)->K1_CLIENTE == M->ACF_CLIENT	.AND.;
		//		(cSK1)->K1_LOJA    == M->ACF_LOJA

	While	!(cSK1)->(Eof())						.AND.;
			(cSK1)->K1_FILIAL  == xFilial("SK1")	.AND.;
			(cSK1)->K1_LOJA    == M->ACF_LOJA

		#IFNDEF TOP
			If (cSK1)->K1_OPERAD == "XXXXXX"
				DbSelectArea(cSK1)
				(cSK1)->(DbSkip())
				Loop
			Endif

			If nPFilOrig > 0
				cFilOrig 	:= (cSK1)->K1_FILORIG
			Else
				cFilOrig	:= xFilial("SE1")
			Endif
			DbSelectArea("SE1")
			DbSetOrder(1)
			If !DbSeek(cFilOrig + (cSK1)->K1_PREFIXO + (cSK1)->K1_NUM + (cSK1)->K1_PARCELA + (cSK1)->K1_TIPO)
				DbSelectArea(cSK1)
				(cSK1)->(DbSkip())
				Loop
			Endif
		#ENDIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Atualiza o flag de marcado se o titulo ja existir no Acols³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If !Empty(aCols[n][nPTitulo])
			If Ascan(aCols, {|x| x[nPPrefix]+x[nPTitulo]+x[nPParcel]+x[nPTipo] == (cSK1)->K1_PREFIXO+(cSK1)->K1_NUM+(cSK1)->K1_PARCELA+(cSK1)->K1_TIPO} ) > 0
				lFlag := .T.
			Else
				lFlag := .F.
			Endif
		Endif

		_CEMPRESA := ""
		IF (cSE1)->EMPRESA = "BI"
			_CEMPRESA = "Bianco"
		ELSEIF (cSE1)->EMPRESA = "IN"
			_CEMPRESA = "Incesa"
		ELSEIF (cSE1)->EMPRESA = "LM"
			_CEMPRESA = "LM"
		ELSEIF (cSE1)->EMPRESA = "VC"
			_CEMPRESA = "Vitcer"
		END IF

		Aadd( aTitulos, {	lFlag,;														// 01 - [x] ou [ ]
		lVencido,;													// 02 - Vermelho ou O - Verde
		(cSE1)->E1_PREFIXO,;										// 03 - Prefixo
		(cSE1)->E1_NUM,;											// 04 - Titulo
		(cSE1)->E1_PARCELA,;										// 05 - Parcela
		(cSE1)->E1_TIPO,;											// 06 - Tipo
		DtoC((cSE1)->E1_EMISSAO),;									// 07 - Emissao
		DtoC((cSE1)->E1_VENCTO),;									// 08 - Vencimento
		DtoC((cSE1)->E1_VENCREA),;									// 09 - Venc. Real
		DtoC((cSE1)->E1_VENCORI),;									// 10 - Venc. Original
		(cSE1)->E1_HIST,;											// 11 - Historico
		(cSE1)->E1_NATUREZ,;										// 12 - Natureza
		(cSE1)->E1_PORTADO,;										// 13 - Portador
		(cSE1)->E1_NUMBOR,;											// 14 - Numero do Bordero
		TRANSFORM((cSE1)->E1_VALOR,   PESQPICT("SE1", "E1_VALOR")),;// 15 - Valor
		TRANSFORM((cSE1)->E1_SALDO,   PESQPICT("SE1", "E1_SALDO")),;
			_CEMPRESA;
			} )
		DbSelectArea(cSK1)
		(cSK1)->(DbSkip())
	End
	#IFDEF TOP
		DbSelectArea(cSK1)
		DbCloseArea()
	#ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega titulos a vencer se a opcao Selecao de titulos = SIM³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMV_TMKTLCT
		lVencido := .T.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Seleciona os titulos A VENCER do cliente atual. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SE1")
		DbSetOrder(7)		// E1_FILIAL+DTOS(E1_VENCREA)+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA

		#IFDEF TOP
			cSE1	:= "TMPSE1"				// Alias temporario do SE1
			cQuery	:=	" SELECT	E1_FILIAL, E1_VENCREA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_VENCTO, E1_VENCORI, " +;
				" 			E1_LOJA, E1_NATUREZ, E1_PORTADO, E1_NUMBOR, E1_EMISSAO, E1_VALOR, E1_SALDO, E1_HIST " +;
				" FROM " +	RetSqlName("SE1") + " SE1 " +;
				" WHERE	SE1.E1_VENCREA 	>= 	'" + DtoS(dDataBase) + 	"' AND" +;
				"		SE1.E1_CLIENTE 	= 	'" + M->ACF_CLIENT + 	"' AND" +;
				"		SE1.E1_LOJA 	= 	'" + M->ACF_LOJA + 		"' AND" +;
				"		SE1.D_E_L_E_T_ 	= 	''" +;
				" ORDER BY " + SqlOrder(IndexKey())

			cQuery	:= ChangeQuery(cQuery)
			MemoWrite("TK274F3.SQL", cQuery)
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cSE1, .F., .T.)

			DbSelectArea(cSE1)
			nLenAux := Len(aStruSE1)
			For nI := 1 TO nLenAux
				If aStruSE1[nI][2] $ "NDL" .AND. FieldPos(aStruSE1[nI][1]) > 0
					TCSetField(cSE1, aStruSE1[nI][1], aStruSE1[nI][2], aStruSE1[nI][3], aStruSE1[nI][4])
				Endif
			Next nI

		#ELSE

			DbSeek(xFilial("SE1")+DtoS(dDataBase),.T.)

		#ENDIF

		While (!(cSE1)->(Eof())) .AND.(cSE1)->E1_VENCREA >= dDataBase

			#IFNDEF TOP
				If (cSE1)->E1_CLIENTE <> M->ACF_CLIENT .OR. (cSE1)->E1_LOJA <> M->ACF_LOJA
					(cSE1)->(DbSkip())
					Loop
				Endif
			#ENDIF

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o flag de marcado se o titulo ja existir no Acols³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aCols[n][nPTitulo])
				If Ascan(aCols, {|x| x[nPPrefix]+x[nPTitulo]+x[nPParcel]+x[nPTipo] == (cSE1)->E1_PREFIXO+(cSE1)->E1_NUM+(cSE1)->E1_PARCELA+(cSE1)->E1_TIPO} ) > 0
					lFlag := .T.
				Else
					lFlag := .F.
				Endif
			Endif


			Aadd( aTitulos, {	lFlag,;															// 01 - [x] ou [ ]
			lVencido,;														// 02 - Vermelho ou O - Verde
			(cSE1)->E1_PREFIXO,;											// 03 - Prefixo
			(cSE1)->E1_NUM,;												// 04 - Titulo
			(cSE1)->E1_PARCELA,;											// 05 - Parcela
			(cSE1)->E1_TIPO,;												// 06 - Tipo
			DtoC((cSE1)->E1_EMISSAO),;										// 07 - Emissao
			DtoC((cSE1)->E1_VENCTO),;										// 08 - Vencimento
			DtoC((cSE1)->E1_VENCREA),;										// 09 - Venc. Real
			DtoC((cSE1)->E1_VENCORI),;										// 10 - Venc. Original
			(cSE1)->E1_HIST,;												// 11 - Historico
			(cSE1)->E1_NATUREZ,;											// 12 - Natureza
			(cSE1)->E1_PORTADO,;											// 13 - Portador
			(cSE1)->E1_NUMBOR,;												// 14 - Numero do Bordero
			TRANSFORM((cSE1)->E1_VALOR,   PESQPICT("SE1", "E1_VALOR")),;	// 15 - Valor
			TRANSFORM((cSE1)->E1_SALDO,   PESQPICT("SE1", "E1_SALDO")),;	//16 - Saldo
			(cSE1)->E1_FILIAL;                                         		// 17 - Filial de Origem
			} )
			(cSE1)->(DbSkip())
		End

		#IFDEF TOP
			DbSelectArea(cSE1)
			DbCloseArea()
		#ENDIF

	Endif

	If (Len(aTitulos) == 0)
		AAdd(aTitulos,{.F., .F., "", "", "", "", "", "", "", "", "", "", "", "", "", "",""} )
	Else
		Asort( aTitulos,,, { |x,y| CtoD(x[9]) < CtoD(y[9]) } )
	Endif

	CursorArrow()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria tela para a escolha do titulo a ser negociado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE "Seleção de Títulos para negociação" FROM 0,0 To 400,500 PIXEL //"Seleção de Títulos para negociação"

	Aadd(aButtons, { "VERNOTA", { || Tk274SE1Visual(	aTitulos[oTitulos:nAt,3]	,aTitulos[oTitulos:nAt,4]	,aTitulos[oTitulos:nAt,5],;
		aTitulos[oTitulos:nAt,6]	,aTitulos[oTitulos:nAt,17]) }, "Visualiza"} ) //"Visualiza"
	Aadd(aButtons, { "TK_FIND", { || Tk274SE1Pesq(	oPanel		,oTodos			,oInverte	,cExpressao	,;
		oTitulos	,lPrefixo		,lNum		,lParcela	,;
		lTipo		,lVencimento	,lVencOrig	,lHistorico	,;
		lNaturez	,lPortado		,lNumBor	,lEmissao	,;
		lVencRea	,.F.) }, "Pesquisa"} ) //"Pesquisa"
	//EnchoiceBar(oDlg, {|| (nOpcao:= 1,oDlg:End())}, {|| oDlg:End() },,aButtons )

	@ 20,05	Listbox oTitulos Fields;
		HEADER	"",;		// "01 - [x] ou [ ]
	"",;		// "02 - Vermelho ou Verde
	"Empresa",;	// "03 - empresa"
	"03 - Prefixo",;	// "03 - Prefixo"
	"04 - Titulo",;	// "04 - Titulo"
	"05 - Parcela",;	// "05 - Parcela"
	"06 - Tipo",;	// "06 - Tipo"
	"07 - Emissao",;   // "07 - Emissao"
	"08 - Vencimento",;   // "08 - Vencimento"
	"09 - Venc. Real",; 	// "09 - Venc. Real"
	"10 - Venc. Orig",;	// "10 - Venc. Orig"
	"11 - Historico",;	// "11 - Historico"
	"12 - Natureza",;	// "12 - Natureza"
	"13 - Portador",;	// "13 - Portador"
	"14 - Bordero",;	// "14 - Bordero"
	"15 - Valor",;	// "15 - Valor"
	"16 - Saldo";	// 16 - Saldo
	On DbLCLICK (aTitulos[oTitulos:nAt,1]:= !aTitulos[oTitulos:nAt,1], oTitulos:Refresh());
		On Change (nTitulo:= oTitulos:nAt) Size 242,115 Of oDlg Pixel NoScroll

	oTitulos:SetArray(aTitulos)
	oTitulos:bLine:={||{IIF(aTitulos[oTitulos:nAt,1],oOk,oNo),;			// 01 - [x] ou [ ]
	IIF(aTitulos[oTitulos:nAt,2],oVerd,oVerm),;		// 02 - Vermelho ou Verde
	aTitulos[oTitulos:nAt,17],;
		aTitulos[oTitulos:nAt,3],;						// 03 - Prefixo
	aTitulos[oTitulos:nAt,4],;						// 04 - Titulo
	aTitulos[oTitulos:nAt,5],;						// 05 - Parcela
	aTitulos[oTitulos:nAt,6],;						// 06 - Tipo
	aTitulos[oTitulos:nAt,7],;						// 07 - Emissao
	aTitulos[oTitulos:nAt,8],;						// 08 - Vencimento
	aTitulos[oTitulos:nAt,9],;						// 09 - Venc. Real
	aTitulos[oTitulos:nAt,10],;						// 10 - Venc. Orig
	aTitulos[oTitulos:nAt,11],;						// 11 - Historico
	aTitulos[oTitulos:nAt,12],;						// 12 - Natureza
	aTitulos[oTitulos:nAt,13],;						// 13 - Portador
	aTitulos[oTitulos:nAt,14],;						// 14 - Bordero
	aTitulos[oTitulos:nAt,15],;						// 15 - Valor
	aTitulos[oTitulos:nAt,16],;
		aTitulos[oTitulos:nAt,17]}}
	oTitulos:Refresh()

	// Painel de Pesquisa
	@ 020,05 MsPanel oPanel Prompt "" Size 242,115 Of oDlg Centered Lowered
	oPanel:lVisible := .F.
	@ 005,05 To 80,230 Of oPanel Label "Composicao Sequencial da pesquisa avancada" Pixel //"Composicao Sequencial da pesquisa avancada"

	@ 15,010 CheckBox oPrefixo		Var lPrefixo	Size 60,9 Pixel Of oPanel Prompt "01 - Prefixo" //"01 - Prefixo"
	@ 15,085 CheckBox oNum			Var lNum		Size 60,9 Pixel Of oPanel Prompt "02 - Numero" //"02 - Numero"
	@ 15,165 CheckBox oParcela		Var lParcela	Size 60,9 Pixel Of oPanel Prompt "03 - Parcela" //"03 - Parcela"
	@ 30,010 CheckBox oTipo			Var lTipo		Size 60,9 Pixel Of oPanel Prompt "04 - Tipo" //"04 - Tipo"
	@ 30,085 CheckBox oEmissao		Var lEmissao	Size 60,9 Pixel Of oPanel Prompt "05 - Emissso" //"05 - Emissso"
	@ 30,165 CheckBox oVencimento	Var lVencimento	Size 60,9 Pixel Of oPanel Prompt "06 - Vencimento" //"06 - Vencimento"
	@ 45,010 CheckBox oVencRea		Var lVencRea	Size 60,9 Pixel Of oPanel Prompt "07 - Vencto Real" //"07 - Vencto Real"
	@ 45,085 CheckBox oVencOrig		Var lVencOrig	Size 60,9 Pixel Of oPanel Prompt "08 - Vencto Original" //"08 - Vencto Original"
	@ 45,165 CheckBox oHistorico	Var lHistorico	Size 60,9 Pixel Of oPanel Prompt "09 - Historico" //"09 - Historico"
	@ 60,010 CheckBox oNaturez		Var lNaturez	Size 60,9 Pixel Of oPanel Prompt "10 - Natureza" //"10 - Natureza"
	@ 60,085 CheckBox oPortado		Var lPortado	Size 60,9 Pixel Of oPanel Prompt "11 - Portador" //"11 - Portador"
	@ 60,165 CheckBox oNumBor		Var lNumBor		Size 60,9 Pixel Of oPanel Prompt "12 - Bordero" //"12 - Bordero"

	@ 85,05 Say "Expressão da pesquisa" Of oPanel Pixel //"Expressão da pesquisa"
	@ 95,05 MsGet oExpressao Var cExpressao Size 225,09 Of oPanel Pixel When .T. Valid Tk274SE1Pesq(	oPanel,		oTodos,		oInverte,	cExpressao,;
		oTitulos,	lPrefixo,	lNum,		lParcela,;
		lTipo,		lVencimento,lVencOrig,	lHistorico,;
		lNaturez,	lPortado,	lNumBor,	lEmissao,;
		lVencRea,	.T.)


	@ 140,05 CheckBox oTodos Var lTodos Size 130,9 Pixel Of oDlg Prompt "Marca e Desmarca Todos" On Change Tk274Tools(1, oTitulos, lTodos) //"Marca e Desmarca Todos"
	@ 140,85 CheckBox oInverte Var lInverte Size 130,9 Pixel Of oDlg Prompt "Inverte e Retorna Seleção" On Change Tk274Tools(2, oTitulos, lInverte) //"Inverte e Retorna Seleção"

	// Legendas da Tela
	@ 155,05 To 175,247 Of oDlg Label "Legenda" Pixel //"Legenda"
	@ 163,10 BitMap oBmp1 ResName "BR_VERDE" OF oDlg Size 10,10 NoBorder When .F. Pixel
	@ 163,20 Say "Titulos a Vencer em aberto" Of oDlg Pixel //"Titulos a Vencer em aberto"

	@ 163,120 BitMap oBmp2 ResName "BR_VERMELHO" OF oDlg Size 10,10 NoBorder When .F. Pixel
	@ 163,130 Say "Titulos Vencidos em aberto" Of oDlg Pixel //"Titulos Vencidos em aberto"

	//ACTIVATE MSDIALOG oDlg CENTERED
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg, {|| (nOpcao:= 1,oDlg:End())}, {|| oDlg:End() },,aButtons ))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Na confirmacao posiciona no titulo selecionado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOpcao == 1)
		nUsado:= Len(aHeader) + 1
		aCols := {}
		lRet  := .T.

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cria linhas no acols se existir mais de um item selecionado.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLenAux := Len(aTitulos)
		Tk274LimpaRdp()
		I := 1

		aFilAux := {}
		AADD(aFilAux,"01")
		AADD(aFilAux,"05")

		For nTitulo := 1 To nLenAux

			If (aTitulos[nTitulo][1])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Adiciona uma linha no acols e inicializa os campos.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AAdd(aCols,Array(nUsado))
				nLenaHead := Len(aHeader)
				For nCampo := 1 TO nLenaHead
					aCols[Len(aCols)][nCampo] := CriaVar(aHeader[nCampo][2])
				Next nCampo
				aCols[Len(aCols)][nUsado] := .F.
				CC_EMPRESA := ""

				IF 	aTitulos[nTitulo,17] = "Bianco"
					ABRE_TABELA("SE1010")
					CC_EMPRESA := "BI"
				ELSEIF aTitulos[nTitulo,17] = "Incesa"
					ABRE_TABELA("SE1050")
					CC_EMPRESA := "IN"
				ELSEIF aTitulos[nTitulo,17] = "LM"
					ABRE_TABELA("SE1070")
					CC_EMPRESA := "LM"

				ELSEIF aTitulos[nTitulo,17] = "Vitcer"
					ABRE_TABELA("SE1140")
					CC_EMPRESA := "VC"
				END IF

				DbSelectArea("_SE1")
				DbSetOrder(1)

				For nFilAux := 1 To Len(aFilAux)

					If DbSeek(aFilAux[nFilAux] + aTitulos[nTitulo,3] + aTitulos[nTitulo,4] + aTitulos[nTitulo,5] + aTitulos[nTitulo,6])
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Atualiza o campos do acols e executa os gatilhos.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//aCols[Len(aCols)][nPTitulo] := aTitulos[nTitulo][4] // TITULO
						aCols[Len(aCols)][1]  := aTitulos[nTitulo][4] // TITULO
						aCols[Len(aCols)][2]  := aTitulos[nTitulo][3] // PREFIXO
						aCols[Len(aCols)][3]  := aTitulos[nTitulo][5] // PARCELA
						aCols[Len(aCols)][4]  := aTitulos[nTitulo][6] // TIPO
						aCols[Len(aCols)][5]  := _SE1->E1_NOMCLI // DESCRICAO

						aCols[Len(aCols)][6]  := CTOD(aTitulos[nTitulo][7]) // EMISSAO

						aCols[Len(aCols)][7]  := _SE1->E1_VENCTO // VENCIMENTO
						aCols[Len(aCols)][8]  := _SE1->E1_VALOR // VALOR
						aCols[Len(aCols)][9]  := CC_EMPRESA // FILIAL ORIGINAL

						If (DDATABASE - _SE1->E1_VENCTO) > 0
							aCols[Len(aCols)][10] := (((_SE1->E1_PORCJUR * (DDATABASE - _SE1->E1_VENCTO) )     / 100) *  _SE1->E1_SALDO)
						END IF
						aCols[Len(aCols)][11] := _SE1->E1_SALDO + aCols[Len(aCols)][10]  //VALOR A RECEBER

						aCols[Len(aCols)][12] := ((DDATABASE - _SE1->E1_VENCTO))  // ATRASO
						aCols[Len(aCols)][14] := _SE1->E1_PORTADOR // ATRASO
						aCols[Len(aCols)][15] := "" // STATUS
						aCols[Len(aCols)][42] := "1" // STATUS

						aCols[Len(aCols)][18] := _SE1->E1_NATUREZ // NATUREZA
						aCols[Len(aCols)][19] := _SE1->E1_VENCREA // VENCIMENTO REAL
						aCols[Len(aCols)][22] := _SE1->E1_HIST // HISTORICO
						aCols[Len(aCols)][33] := _SE1->E1_NUMBCO // NUMERO BANCO
						aCols[Len(aCols)][34] := _SE1->E1_VALJUR // VAL JUROS
						aCols[Len(aCols)][35] := _SE1->E1_PORCJUR // PERCENTUAL DE JUROS


						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Valido a existencia do campo ACG_FILORI criado. Caso nao exista, assumo a filial corrente do SE1³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						//If nPFilACG > 0
						//	aCols[Len(aCols)][nPFilACG]:= aTitulos[nTitulo][17]
						//Endif

					/*
					Posicione("SX3",2,"ACG_TITULO","")
					RunTrigger(2,Len(aCols))

					aValores := FaVlAtuCr(	NIL					, NIL	, NIL	, NIL	,;
					aTitulos[nTitulo,17], .T.	)


					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se o calculo dos juros do titulo for baseado nos parametros MV_LJJUROS e MV_LJMULT ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cTmkJuros == "2" // SIGALOJA
					Tk274CalcJuros(	@aValores		, @aCols		, aHeader, NIL,;
					M->ACF_CLIENT	, M->ACF_LOJA)
						Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza o Valor de Referencia, Receber, Juros, Baixa e Status na Inclusao dos tit³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aCols[Len(aCols)][nPValRef]	:= aValores[6]		// Saldo do Titulo 
					aCols[Len(aCols)][nPJuros]	:= aValores[8]		// Valor de Juros
					aCols[Len(aCols)][nPRecebe]	:= aValores[12] 	// Valor a Receber
						Endif

						Do Case
						Case !Empty(_SE1->E1_BAIXA) // Se houve uma baixa verifica se foi TOTAL ou PARCIAL
							If (_SE1->E1_SALDO > 0)
					aCols[Len(aCols)][nPBaixa] := "1" //Baixa Parcial
					aCols[Len(aCols)][nPStatus]:= "4" //Baixa
							Endif

							If (SE1->E1_SALDO == 0)
					aCols[Len(aCols)][nPBaixa] := "3" //Baixa Total
					aCols[Len(aCols)][nPStatus]:= "1" //Pago
							Endif

						Case Empty(SE1->E1_BAIXA) // Nao houve nenhuma baixa
					aCols[Len(aCols)][nPBaixa] := "2" //Sem Baixa            	

						EndCase

					// [2] Abatimentos
					// [A] Correcao Monetaria
					// [8] Juros
					// [5] Acrescimo     - E1_SDACRES
					// [4] Decrescimo    - E1_SDDECRE
					// [9] Desconto
					// [1] Valor Original do Titulo
					// [6] Saldo do Titulo na Moeda do Titulo
					// [7] Saldo do Titulo na Moeda Corrente
					// [3] Pagto Parcial
					// [B] Valor a ser Recebido na moeda do titulo
					// [C] Valor a ser Recebido na moeda corrente
					*/

					/*
					aRdpTlc[1][2]	:= aRdpTlc[1][2] + 0
					aRdpTlc[2][2]	:= aRdpTlc[2][2] + 0 //aValores[10]
					aRdpTlc[3][2]	:= aRdpTlc[3][2] + 0 //aValores[8]
					aRdpTlc[4][2]	:= aRdpTlc[4][2] + _SE1->E1_SDACRES 
					aRdpTlc[5][2]	:= aRdpTlc[5][2] + _SE1->E1_SDDECRE 
					aRdpTlc[6][2]	:= aRdpTlc[6][2] + 0
					aRdpTlc[7][2]	:= aRdpTlc[7][2] + 0 //aValores[1]
					aRdpTlc[8][2]	:= aRdpTlc[8][2] + 0 //aValores[6]
					aRdpTlc[9][2]	:= aRdpTlc[9][2] + 0 //aValores[7]
					aRdpTlc[10][2]	:= aRdpTlc[10][2] + 0 //aValores[3]
					aRdpTlc[11][2]	:= aRdpTlc[11][2] + 0 + _SE1->E1_SDACRES - _SE1->E1_SDDECRE 
					aRdpTlc[12][2]	:= aRdpTlc[12][2] + 0 + _SE1->E1_SDACRES - _SE1->E1_SDDECRE 
					*/

					/*
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica as regras de desconto no cadastro ³
					//³ de Promocao de Cobranca (SK3)              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("SK3")
					DbSetOrder(2)		// K3_FILIAL+K3_VCTINI
					DbSeek(xFilial("SK3") + DtoS(_SE1->E1_VENCREA), .T.)
						If SE1->E1_VENCREA >= SK3->K3_VCTINI .AND. SE1->E1_VENCREA <= SK3->K3_VCTFIM
							If dDataBase >= SK3->K3_INICIO .AND. dDataBase <= SK3->K3_FINAL
					aCols[Len(aCols)][nPPromoc] := SK3->K3_CODIGO
							Endif
						Else
					SK3->(DbSkip(-1))
							If SE1->E1_VENCREA >= SK3->K3_VCTINI .AND. SE1->E1_VENCREA <= SK3->K3_VCTFIM
								If dDataBase >= SK3->K3_INICIO .AND. dDataBase <= SK3->K3_FINAL
					aCols[Len(aCols)][nPPromoc] := SK3->K3_CODIGO
								Endif
							Endif
						Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Recalcula os descontos ja aplicados³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						

					aBkRdpTlc 	:= aClone(aRdpTlc) 

					Tk274DescFi(aCols[Len(aCols)][nPDescFi]		, aCols		, Len(aCols)	, Nil	,;
					Nil								, @aBkRdpTlc, .T.			)

					aRdpTlc := aClone(aBkRdpTlc)

						If (nPDescJu <> 0)

					aBkRdpTlc 	:= aClone(aRdpTlc)

					Tk274DescJu(aCols[Len(aCols)][nPDescJu]	, aCols		, Len(aCols) 	, Nil	,;
					Nil								, @aBkRdpTlc, .T.			)

					aRdpTlc := aClone(aBkRdpTlc)   

						EndIf
					*/
					Endif
				Next nFilAux
			Endif
		Next nTitulo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Depois de carregar o aCols com os titulos selecionados atualiza os totais do Rodape³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRdpTlc[1][1]:Refresh()
		aRdpTlc[2][1]:Refresh()
		aRdpTlc[3][1]:Refresh()
		aRdpTlc[4][1]:Refresh()
		aRdpTlc[5][1]:Refresh()
		aRdpTlc[6][1]:Refresh()
		aRdpTlc[7][1]:Refresh()
		aRdpTlc[8][1]:Refresh()
		aRdpTlc[9][1]:Refresh()
		aRdpTlc[10][1]:Refresh()
		aRdpTlc[11][1]:Refresh()
		aRdpTlc[12][1]:Refresh()
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso chegar ate aqui com o aCols vazio, entao carrega em branco³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aCols) == 0
		AAdd(aCols,Array(nUsado))

		nLenaHead := Len(aHeader)
		For nCampo := 1 TO nLenaHead
			aCols[Len(aCols)][nCampo] := CriaVar(aHeader[nCampo][2])
		Next nCampo

		aCols[Len(aCols)][nUsado] := .F.
		lRet := .F.
	Else
		// Posiciona no primeiro titulo dos itens do atendimento de Telecobranca
		n := 1
		oGetTlc:oBrowse:Refresh()

		//DbSelectArea("_SE1")
		//DbSeek(xFilial("_SE1") + aCols[n][nPPrefix]+aCols[n][nPTitulo]+aCols[n][nPParcel]+aCols[n][nPTipo] )
	Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274ToolsºAutor  ³ Vendas Clientes    º Data ³  25/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para selecao dos Titulos apresentados no browser paraº±±
±±º          ³serem cobrados.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Tk274Tools(nTipo, oTitulos, lCheck)

	Local nI	:= 0		// Variavel de Controle

	If nTipo == 1
		If lCheck
			For nI := 1 To Len(oTitulos:aArray)
				oTitulos:aArray[nI][1] := .T.
				oTitulos:Refresh()
			Next nI
		Else
			For nI := 1 To Len(oTitulos:aArray)
				oTitulos:aArray[nI][1] := .F.
				oTitulos:Refresh()
			Next nI
		Endif
	Else
		For nI := 1 To Len(oTitulos:aArray)
			If oTitulos:aArray[nI][1]
				oTitulos:aArray[nI][1] := .F.
			Else
				oTitulos:aArray[nI][1] := .T.
			Endif
			oTitulos:Refresh()
		Next nI
	Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Tk274SE1VisualºAutor³ Vendas Clientes    º Data ³ 04/11/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao de visualizacao do Titulo, auxiliar da pesquisa F3 naº±±
±±º          ³rotina de Telecobranca Tk274Tit().                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function Tk274SE1Visual(cPrefixo, cNum, cParcela, cTipo, cFilOrig)

	IF 	_CEMPRESA = "Bianco"
		ABRE_TABELA("SE1010")
	ELSEIF _CEMPRESA = "Incesa"
		ABRE_TABELA("SE1050")
	ELSEIF _CEMPRESA == "LM"
		ABRE_TABELA("SE1070")
	ELSEIF _CEMPRESA == "Vitcer"
		ABRE_TABELA("SE1140")
	END IF

	DbSelectArea("_SE1")
	DbSetOrder(1)
	DbSeek("01" + cPrefixo + cNum + cParcela + cTipo)

	AxVisual("_SE1", _SE1->(Recno()), 2)

Return(.T.)
/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SEPARA_CAMPOS  ³ Autor ³ MADALENO              ³ Data ³ 26/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ABRE A TABELA NA EMPRESA CORRESPONDENTE                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PARAMETRO³ cLinha   : NOME DA TABELA                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION ABRE_TABELA(cTABELA)

	Local x

	cIndex  := ""
	cArq    := ""
	cInd    := ""

	cArq := cTABELA
	cTABELA := ("_" + SUBSTR(cTABELA,1,3))
	ccTabela := SUBSTR(cArq,1,3)
	DbSelectArea("SIX")
	DbSetOrder(1)
	DbSeek(ccTabela)
	Do while .not. eof() .and. INDICE==ccTabela
		cIndex+=cArq+SIX->ORDEM
		DbSkip()
	EndDo
	If chkfile(cTABELA)
		DbSelectArea(cTABELA)
		DbCloseArea()
	EndIf
	Use &cArq Alias &cTABELA Shared New Via "TopConn"
	For x:=1 to 15 step 7
		cInd := Subs(cIndex,x,7)
		DbSetIndex(cInd)
	Next
RETURN