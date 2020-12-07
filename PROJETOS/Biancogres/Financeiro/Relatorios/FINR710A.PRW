#INCLUDE "FINR710.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	   ³ FinR710	³ Autor ³ Wagner Xavier 	      ³ Data ³ 05.10.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Bordero de Pagamento.									  									³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FinR710(void)											  											³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 	 ³ Generico 							 					 													³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FINR710A()

	Local oReport
	Local aAreaR4	:= GetArea()
	Private cArqAnt	:= ""
	Private cIndAnt	:= 0
	Private cRegAnt	:= 0
	Private cArqSEA	:= ""
	Private cIndSEA	:= 0
	Private cRegSEA	:= 0
	PRIVATE __cInternet
	// Tiago Rosssini Coradini - 05/11/15 - OS: 2393-15 - Mikaelly Gentil - Impressao de bordero sem interface de parametros, utilizado na consulta de titulos a pagar
	Private lNoAsk := If (AllTrim(Upper(FunName())) == "FINC050", .T., .F.)

	cArqAnt := Alias()
	cIndAnt := IndexOrd()
	cRegAnt := Recno()

	// Tiago Rosssini Coradini - 05/11/15 - OS: 2393-15 - Mikaelly Gentil - Impressao de bordero sem interface de parametros, utilizado na consulta de titulos a pagar
	If lNoAsk

		FinR710R3()

	ElseIf FindFunction("TRepInUse") .And. TRepInUse()
		oReport := ReportDef()
		oReport:PrintDialog()
	Else
		Return FinR710R3() // Executa versão anterior do fonte
	Endif

	If cArqAnt <> ""
		dbSelectArea(cArqAnt)
		dbSetOrder(cIndAnt)
		dbGoTo(cRegAnt)
	EndIf

	RestArea(aAreaR4)  

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ReportDef º Autor ³ Marcio Menon	      º Data ³  27/07/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPC1 - Grupo de perguntas do relatorio                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 									                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()

	Local oReport
	Local oSection1
	Local oSection2
	Local cReport 	:= "FINR710" 				// Nome do relatorio
	Local cDescri 	:= STR0001 + STR0002   	//"Este programa tem a fun‡„o de emitir os borderos de pagamen-" ### "tos."
	Local cTitulo 	:= STR0003 					//"Emiss„o de Borderos de Pagamentos"
	Local cPerg		:= "FIN710"					// Nome do grupo de perguntas

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas 					 	     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//AcertaSx1()
	pergunte("FIN710",.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vari veis utilizadas para parametros						³
	//³ mv_par01				// Do Bordero						³
	//³ mv_par02				// At‚ o Bordero					³
	//³ mv_par03				// Data para d‚bito					³
	//³ mv_par04				// Qual Moeda						³
	//³ mv_par05				// Outras Moedas					³
	//³ mv_par06				// Converte por						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia a data para debito com a data base do sistema		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Em 20/01/17, por Marcos Alberto Soprani
	//dbSelectArea("SX1")
	//If dbSeek ("FIN710"+"03")  // Busca a pergunta para mv_par03
	//	Reclock("SX1",.F.)
	//	Replace X1_CNT01 With "'"+dtoc(dDataBase)+"'"
	//	MsUnlock()
	//Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do componente de impressao                                      ³
	//³                                                                        ³
	//³TReport():New                                                           ³
	//³ExpC1 : Nome do relatorio                                               ³
	//³ExpC2 : Titulo                                                          ³
	//³ExpC3 : Pergunte                                                        ³
	//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
	//³ExpC5 : Descricao                                                       ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := TReport():New(cReport, cTitulo, cPerg, {|oReport| ReportPrint(oReport)}, cDescri) 

	oReport:HideHeader()		//Oculta o cabecalho do relatorio
	oReport:SetPortrait()	//Imprime o relatorio no formato retrato
	oReport:HideFooter()		//Oculta o rodape do relatorio

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                                                                        ³
	//³                      Definicao das Secoes                              ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Secao 01                                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1 := TRSection():New(oReport, STR0054 , {"SEA"})	//"CABECALHO"

	TRCell():New(oSection1, "CABEC", "", STR0054 , "", 80,/*lPixel*/,/*CodeBlock*/)		//"CABECALHO"

	oSection1:SetHeaderSection(.F.)	//Nao imprime o cabecalho da secao
	oSection1:SetPageBreak(.T.)		//Salta a pagina na quebra da secao

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Secao 02                                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection2 := TRSection():New(oSection1, STR0041 , {"SEA","SA6","SEF","SA2","SE2"})		//"BORDERO"

	TRCell():New(oSection2, "EA_PREFIXO", "SEA", STR0042 , PesqPict("SEA","EA_PREFIXO"), TamSX3("EA_PREFIXO")[1],/*lPixel*/,/*CodeBlock*/)	//"PRF"
	TRCell():New(oSection2, "EA_NUM"    , "SEA", STR0043 , PesqPict("SEA","EA_NUM")    , TamSX3("EA_NUM")[1]    ,/*lPixel*/,/*CodeBlock*/)	//"NUMERO"
	TRCell():New(oSection2, "EA_PARCELA", "SEA", STR0044 , PesqPict("SEA","EA_PARCELA"), TamSX3("EA_PARCELA")[1],/*lPixel*/,/*CodeBlock*/)	//"PC"
	TRCell():New(oSection2, "BENEF"     , ""   , STR0045 , PesqPict("SA2","A2_NOME")   , 33,/*lPixel*/,/*CodeBlock*/)								//"B E N E F I C I A R I O"
	TRCell():New(oSection2, "A6_NREDUZ" , "SA6", STR0046 , PesqPict("SA6","A6_NREDUZ") , 15,/*lPixel*/,/*CodeBlock*/)								//"BANCO"
	TRCell():New(oSection2, "EF_NUM"    , "SEF", STR0047 , PesqPict("SEF","EF_NUM")    , TamSX3("EF_NUM")[1]    ,/*lPixel*/,/*CodeBlock*/)	//"HISTORICO"
	TRCell():New(oSection2, "A2_BANCO"  , "SA2", STR0048 , PesqPict("SA2","A2_BANCO")  , TamSX3("A2_BANCO")[1]  ,/*lPixel*/,/*CodeBlock*/)	//"BCO"
	TRCell():New(oSection2, "A2_AGENCIA", "SA2", STR0049 , PesqPict("SA2","A2_AGENCIA"), TamSX3("A2_AGENCIA")[1],/*lPixel*/,/*CodeBlock*/)	//"AGENC"
	TRCell():New(oSection2, "A2_NUMCON" , "SA2", STR0050 , PesqPict("SA2","A2_NUMCON") , TamSX3("A2_NUMCON")[1] ,/*lPixel*/,/*CodeBlock*/)	//"NUMERO CONTA"
	TRCell():New(oSection2, "A2_CGC"  	 , "SA2", STR0051 , "@R 99999999/9999999"       , 20,/*lPixel*/,/*CodeBlock*/) 								//"CNPJ/CPF"
	TRCell():New(oSection2, "E2_VENCREA", "SE2", STR0052 , PesqPict("SE2","E2_VENCREA"), TamSX3("E2_VENCREA")[1],/*lPixel*/,/*CodeBlock*/)	//"DT.VENC"
	TRCell():New(oSection2, "VALORPAGAR", ""   , STR0053 , TM(0,17), 18,/*lPixel*/,/*CodeBlock*/)															//"VALOR A PAGAR"

	oSection2:SetTotalInLine (.F.) 	//O totalizador da secao sera impresso em coluna
	oSection2:SetHeaderBreak(.T.)   //Imprime o cabecalho das celulas apos a quebra

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrint ºAutor³ Marcio Menon       º Data ³  27/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Imprime o objeto oReport definido na funcao ReportDef.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPO1 - Objeto TReport do relatorio                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint(oReport)

	Local oSection1 	:= oReport:Section(1) 
	Local oSection2 	:= oReport:Section(1):Section(1)
	Local oBreak1
	Local oFunction1
	Local cChave      := ""
	Local cFiltro     := ""
	Local cAliasSea	:= "SEA"
	Local cJoin 		:= ""
	Local lBaixa		:= .F.
	Local lCheque     := .F.
	Local lAbatimento := .F.
	Local cLoja  		:= ""
	Local nVlrPagar	:= 0
	Local cModelo   	:= CriaVar("EA_MODELO")
	Local cNumConta	:= CriaVar("EA_NUMCON")
	Local lSeaEof     := .F.

	Private nJuros := 0

	cChave := SEA->(IndexKey())

	#IFDEF TOP

	cAliasSea 		:= GetNextAlias()
	cChave 	:= "%"+SqlOrder(cChave)+"%"

	oSection1:BeginQuery()

	BeginSql Alias cAliasSea
	SELECT 	SEA.EA_FILIAL, SEA.EA_FILORIG, SEA.EA_NUMBOR, SEA.EA_CART, SEA.EA_FILORIG, SEA.EA_PREFIXO, SEA.EA_NUM,
	SEA.EA_PARCELA, SEA.EA_TIPO, SEA.EA_FORNECE, SEA.EA_LOJA, SEA.EA_MODELO , SEA.EA_PORTADO, SEA.EA_AGEDEP,
	SEA.EA_NUMCON, SEA.EA_DATABOR
	FROM
	%table:SEA% SEA
	WHERE
	SEA.EA_FILIAL = %xfilial:SEA% AND
	SEA.EA_NUMBOR >= %Exp:mv_par01% AND 
	SEA.EA_NUMBOR <= %Exp:mv_par02% AND 
	SEA.EA_CART = 'P' AND
	SEA.%notDel%
	ORDER BY %Exp:cChave%
	EndSql
	oSection1:EndQuery()
	oSection2:SetParentQuery()

	#ELSE

	cFiltro := "EA_FILIAL == '" + xFilial("SEA") + "' .And. "
	cFiltro += "EA_NUMBOR >= '" + mv_par01 + "' .And. "
	cFiltro += "EA_NUMBOR <= '" + mv_par02 + "' .And. "
	cFiltro += "EA_CART = 'P' "

	TRPosition():New(oSection2,"SE2",1,{|| If( Empty((cAliasSea)->EA_FILORIG) .AND. !Empty(xFilial("SE2")),;
	xFilial("SE2")+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+AllTrim((cAliasSea)->EA_LOJA),;
	(cAliasSea)->EA_FILORIG+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+AllTrim((cAliasSea)->EA_LOJA)) } )
	oSection1:SetFilter(cFiltro,cChave)

	#ENDIF

	oSection1:SetLineCondition( { ||	 MV_PAR05 == 1 .Or. SE2->E2_NUMBOR == (cAliasSea)->EA_NUMBOR } )
	oSection2:SetLineCondition( { ||	 MV_PAR05 == 1 .Or. SE2->E2_MOEDA == MV_PAR04 } )

	TRPosition():New(oSection2,"SE2",1,{|| If( Empty((cAliasSea)->EA_FILORIG) .AND. !Empty(xFilial("SE2")),;
	xFilial("SE2")+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+AllTrim((cAliasSea)->EA_LOJA),;
	(cAliasSea)->EA_FILORIG+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+AllTrim((cAliasSea)->EA_LOJA)) } )

	oSection2:OnPrintLine( { || lBaixa := Fr710BxVL(cAliasSea, IIf (Empty((cAliasSea)->EA_LOJA), "", (cAliasSea)->EA_LOJA)), If(!lBaixa, lBaixa := Fr710BxBA(cAliasSea), Nil ),;
	lCheque := (!Empty(SE5->E5_NUMCHEQ) .And. SEF->(MsSeek(xFilial("SEF")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+SE5->E5_NUMCHEQ))),;
	Fr710Config(cAliasSea, oSection2), .T. } )

	oReport:OnPageBreak( { || ReportCabec(oReport, cModelo := (cAliasSea)->EA_MODELO, cAliasSea, lBaixa, lSeaEof) } )

	oSection2:Cell("BENEF"):SetBlock( { || cNumConta := (cAliasSea)->EA_NUMCON, Fr710Benef(cAliasSea, lBaixa, lCheque, lAbatimento) } )

	oSection2:Cell("A2_CGC" ):SetBlock( { || Transform(SA2->A2_CGC, IIF(Len(Alltrim(SA2->A2_CGC))>11,"@R 99999999/9999-99","@R 999999999-99")) } )

	oSection2:Cell("E2_VENCREA"):SetBlock( { || SE2->E2_VENCREA } )

	oSection2:Cell("VALORPAGAR"):SetBlock( { || Fr710VPagar(cAliasSea, lBaixa, lCheque, lAbatimento) } )

	oBreak1 := TRBreak():New(oSection1, { || (cAliasSea)->EA_NUMBOR }, STR0007)

	oFunction1 := TRFunction():New(oSection2:Cell("VALORPAGAR"),,"SUM", oBreak1,,,,.F.,.F.)	

	oBreak1:OnPrintTotal( { || ReportTxtAut(oReport, cModelo, cNumConta, oFunction1:GetLastValue()), "" } )

	oSection2:SetParentFilter({|cParam| (cAliasSea)->EA_NUMBOR == cParam },{|| (cAliasSea)->EA_NUMBOR } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia a impressao.						 					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oSection1:Print()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fr710BxVL ºAutor  ³ Marcio Menon       º Data ³  28/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe movimentação bancaria ou baixas que     º±±
±±º          ³ movimentam banco.                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 	                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fr710BxVL(cAliasSea, cLoja, lBaixa)

	Local cChave := ""

	// Borderos gerados em versao anterior
	IF Empty((cAliasSea)->EA_FILORIG) .AND. !Empty(xFilial("SE2"))
		cChave := xFilial("SE2")+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+cLoja
	Else //Borderos gerados a partir da versao 7.10
		cChave := (cAliasSea)->EA_FILORIG+(cAliasSea)->EA_PREFIXO+(cAliasSea)->EA_NUM+(cAliasSea)->EA_PARCELA+(cAliasSea)->EA_TIPO+(cAliasSea)->EA_FORNECE+cLoja
	Endif

	DbSelectArea("SE2")
	dbSetOrder(1)
	MsSeek(cChave)

	dbSelectArea("SE5")
	dbSetOrder(2)
	SE5->(MsSeek(xFilial("SE5")+"VL"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+DtoS(SE2->E2_BAIXA)+SE2->E2_FORNECE+SE2->E2_LOJA ))

	While SE5->(!Eof()) .and. ;
	SE5->E5_FILIAL		== xFilial("SE5")	 .and. ;
	SE5->E5_TIPODOC	== "VL"            .and. ;
	SE5->E5_PREFIXO	== SE2->E2_PREFIXO .and. ;
	SE5->E5_NUMERO		== SE2->E2_NUM 	 .and. ;
	SE5->E5_PARCELA	== SE2->E2_PARCELA .and. ;
	SE5->E5_TIPO		== SE2->E2_TIPO	 .and. ;
	SE5->E5_DATA		== SE2->E2_BAIXA	 .and. ;
	SE5->E5_CLIFOR		== SE2->E2_FORNECE .and. ;
	SE5->E5_LOJA		== cLoja

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ S¢ considera baixas que nao possuem estorno   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !TemBxCanc(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
			If SubStr( SE5->E5_DOCUMEN,1,6 ) == (cAliasSea)->EA_NUMBOR .And. SE5->E5_MOTBX != "PCC"
				lBaixa := .T.
				Exit
			Endif
		EndIf
		SE5->(dbSkip())
	Enddo

Return lBaixa

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fr710BxBA ºAutor  ³ Marcio Menon       º Data ³  28/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe baixa automatica ou baixa que nao tenha º±±
±±º          ³ movimentacao bancaria.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 	                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fr710BxBA(cAliasSea, lBaixa)

	Local sFilial

	If (xFilial("SE2") <> "  " .and. xFilial("SE5") <> "  ") .or. (xFilial("SE2") == "  " .and. xFilial("SE5") <> "  ")
		sFilial := SE2->E2_FILIAL
	Else
		sFilial := xFilial("SE5")
	EndIf

	If (SE5->(MsSeek( sFilial +"BA"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+DtoS(SE2->E2_BAIXA)+SE2->E2_FORNECE+SE2->E2_LOJA)))
		While SE5->(!Eof()) .and. ;
		SE5->E5_FILIAL		== sFilial	 .and. ;
		SE5->E5_TIPODOC	== "BA"            .and. ;
		SE5->E5_PREFIXO	== SE2->E2_PREFIXO .and. ;
		SE5->E5_NUMERO		== SE2->E2_NUM 	 .and. ;
		SE5->E5_PARCELA	== SE2->E2_PARCELA .and. ;
		SE5->E5_TIPO		== SE2->E2_TIPO	 .and. ;
		SE5->E5_DATA		== SE2->E2_BAIXA	 .and. ;
		SE5->E5_CLIFOR		== SE2->E2_FORNECE .and. ;
		SE5->E5_LOJA		== SE2->E2_LOJA

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ S¢ considera baixas que nao possuem estorno   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !TemBxCanc(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))
				If SubStr( SE5->E5_DOCUMEN,1,6 ) == (cAliasSea)->EA_NUMBOR .And. SE5->E5_MOTBX != "PCC"
					lBaixa := .T.
					Exit
				Endif
			EndIf
			SE5->(dbSkip())
		Enddo
	Endif

Return lBaixa

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fr710BenefºAutor  ³  Marcio Menon      º Data ³  28/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o campo Beneficiario conforme o modelo do          º±±
±±º          ³ bordero.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fr710Benef(cAliasSea, lBaixa, lCheque, lAbatimento)

	Local cBenef 		:= ""
	Local cChave      := ""

	// Localiza o fornecedor do titulo que esta no bordero
	// Borderos gerados em versao anterior
	IF Empty((cAliasSea)->EA_FILORIG) .AND. !Empty(xFilial("SA2"))
		cChave := xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA
	Else //Borderos gerados a partir da versao 7.10
		If !Empty((cAliasSea)->EA_FILORIG) .AND. !Empty(xFilial("SA2"))	
			cChave := (cAliasSea)->EA_FILORIG+SE2->E2_FORNECE+SE2->E2_LOJA
		Else	
			cChave := xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA
		Endif
	Endif

	SA2->(MsSeek(cChave))

	If (cAliasSea)->EA_MODELO $ "CH/02"
		If !lAbatimento
			If lCheque
				cBenef := SEF->EF_BENEF
			ElseIf lBaixa
				cBenef := SE5->E5_BENEF
			Else
				cBenef := SA2->A2_NOME
			Endif
		EndIf
	Else
		cBenef := SA2->A2_NOME
	Endif

Return cBenef

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fr710VPagar ºAutor  ³ Marcio Menon       º Data ³  28/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Faz os calculos dos valores a pagar dos titulos.		        º±±
±±º          ³ 						                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 	                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fr710VPagar(cAliasSea, lBaixa, lCheque, lAbatimento)

	Local nAbat  		:= 0
	Local nVlrPagar	:= 0

	If lAbatimento
		nAbat 	:= SE2->E2_SALDO
	Else
		nAbat := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",SE2->E2_MOEDA,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua calculo dos juros do titulo posicionado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	fa080Juros(1)	
	If lBaixa
		If ! lAbatimento
			nVlrPagar := Round(NoRound(xMoeda(SE5->E5_VALOR,SE2->E2_MOEDA,MV_PAR04,Iif(MV_PAR06==1,(cAliasSea)->EA_DATABOR,dDataBase),MsDecimais(1)+1),MsDecimais(1)+1),MsDecimais(1))
			nAbat := 0
		EndIf
	Else
		If ! lAbatimento
			nVlrPagar := Round(NoRound(xMoeda(SE2->E2_SALDO-SE2->E2_SDDECRE+SE2->E2_SDACRES-nAbat+nJuros,SE2->E2_MOEDA,MV_PAR04,Iif(MV_PAR06==1,(cAliasSea)->EA_DATABOR,dDataBase),MsDecimais(1)+1),MsDecimais(1)+1),MsDecimais(1))
		Endif
	Endif

Return nVlrPagar

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportCabec ºAutor  ³ Marcio Menon       º Data ³  28/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o cabecalho do relatorio.						        º±±
±±º          ³ 						                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 	                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportCabec(oReport, cModelo, cAliasSea, lBaixa, lSeaEof)

	Local cStartPath	:= GetSrvProfString("Startpath","")
	Local cLogo			:= ""
	Local cTexto 		:= ""
	Local lHlpNoTab 	:= .F.

	//Se a quebra de secao for na impressao do texto da autorizacao
	//Volta o registro para imprimir o cabecalho
	If (cAliasSea)->(EOF())
		lSeaEof := .T.
		(cAliasSea)->(dbSkip(-1))	
		cModelo := (cAliasSea)->EA_MODELO
	EndIf

	If lBaixa
		SA6->(MsSeek(xFilial("SA6")+SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA)))
	Else
		SA6->(MsSeek(xFilial("SA6")+(cAliasSea)->(EA_PORTADO+EA_AGEDEP+EA_NUMCON)))
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o modelo do documento.				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lHlpNoTab := IIf(Empty(cModelo),.F.,.T.)
	If cModelo $ "CH/02"
		cTexto := Tabela("58",@cModelo,lHlpNoTab)
	Elseif cModelo $ "CT/30"
		cTexto := Tabela("58",@cModelo,lHlpNoTab)
	Elseif cModelo $ "CP/31"
		cTexto := Tabela("58",@cModelo,lHlpNoTab)
	ElseIf cModelo $ "CC/01/03/04/05/10/41/43"
		cTexto := Tabela("58",@cModelo,lHlpNoTab) 
	Else
		cTexto := Tabela("58",@cModelo,lHlpNoTab)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o cabecalho.							  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:ThinLine()

	cLogo := cStartPath + "LGRL" + FWCodEmp() + FwCodFil() + ".BMP" 	// Empresa+Filial

	If !File( cLogo )
		cLogo := cStartPath + "LGRL" + FWCodEmp() + ".BMP" 						// Empresa
	endif

	oReport:SkipLine()
	oReport:SayBitmap (oReport:Row(),005,cLogo,291,057)
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:ThinLine()
	oReport:SkipLine()
	oReport:SkipLine()
	//Texto do tipo de bordero
	oReport:PrintText(SM0->M0_NOME + PadC(OemToAnsi(STR0034),100) + OemToAnsi(STR0035)+DtoC(dDataBase))
	oReport:PrintText(Space(Len(SM0->M0_NOME)) + PadC(cTexto,100) + OemToAnsi(STR0036) + (cAliasSea)->EA_NUMBOR)
	oReport:SkipLine()
	oReport:SkipLine()
	//Dados do Banco
	oReport:PrintText(Pad(OemToAnsi(STR0037) + SA6->A6_NOME,100))
	//oReport:PrintText(Pad(OemToAnsi(STR0038) + SA6->A6_AGENCIA+"-"+SA6->A6_DVAGE + STR0040 + SA6->A6_NUMCON+"-"+SA6->A6_DVCTA,100))
	oReport:PrintText(Pad(OemToAnsi(STR0038) + SA6->A6_AGENCIA + STR0040 + SA6->A6_NUMCON,100))
	oReport:PrintText(Pad(SA6->A6_END + " "  + SA6->A6_MUN + " " + SA6->A6_EST,100))
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:ThinLine()

	If lSeaEof
		(cAliasSea)->(dbSkip())
	EndIf

Return ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fr710Config ºAutor  ³ Marcio Menon       º Data ³  01/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Exibe ou oculta as colunas do relatorio, conforme o modelo   º±±
±±º          ³ do bordero.			                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 	                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fr710Config(cAliasSea, oSection2)

	Do Case

		Case	(cAliasSea)->EA_MODELO $ "CH/02"

		oSection2:Cell("EF_NUM"    ):Enable()	
		oSection2:Cell("EF_NUM"    ):SetBlock({ || "CH. " + SEF->EF_NUM})
		oSection2:Cell("A2_BANCO"  ):Disable()	
		oSection2:Cell("A2_AGENCIA"):Disable()	
		oSection2:Cell("A2_NUMCON" ):Disable()	
		oSection2:Cell("A2_CGC"    ):Disable()	

		Case	(cAliasSea)->EA_MODELO $ "CT/30"

		oSection2:Cell("A6_NREDUZ" ):Disable()	
		oSection2:Cell("A2_BANCO"  ):Disable()	
		oSection2:Cell("A2_AGENCIA"):Disable()	
		oSection2:Cell("A2_NUMCON" ):Disable()	
		oSection2:Cell("A2_CGC"    ):Disable()	
		//Verifica se existe numero de cheque
		If (SEF->(MsSeek(xFilial("SEF") + SE5->E5_BANCO + SE5->E5_AGENCIA + SE5->E5_CONTA + SE5->E5_NUMCHEQ)))
			oSection2:Cell("EF_NUM"    ):SetTitle("NUM. CHEQUE")
			oSection2:Cell("EF_NUM"    ):SetBlock({ || SEF->EF_NUM})
			oSection2:Cell("EF_NUM"    ):Enable()	
		Else
			oSection2:Cell("EF_NUM"    ):SetTitle("")
		EndIf

		Case	(cAliasSea)->EA_MODELO $ "CT/31"

		oSection2:Cell("A6_NREDUZ" ):Enable()	
		oSection2:Cell("A2_BANCO"  ):Disable()	
		oSection2:Cell("A2_AGENCIA"):Disable()	
		oSection2:Cell("A2_NUMCON" ):Disable()	
		oSection2:Cell("A2_CGC"    ):Disable()	
		//Verifica se existe numero de cheque
		If (SEF->(MsSeek(xFilial("SEF") + SE5->E5_BANCO + SE5->E5_AGENCIA + SE5->E5_CONTA + SE5->E5_NUMCHEQ)))
			oSection2:Cell("EF_NUM"    ):SetTitle("NUM. CHEQUE")
			oSection2:Cell("EF_NUM"    ):SetBlock({ || SEF->EF_NUM})
			oSection2:Cell("EF_NUM"    ):Enable()	
		Else
			oSection2:Cell("EF_NUM"    ):SetTitle("NUM. CHEQUE")
		EndIf

		Case	(cAliasSea)->EA_MODELO $ "CC/01/03/04/05/10/41/43"

		oSection2:Cell("A6_NREDUZ" ):Enable()	
		oSection2:Cell("A2_BANCO"  ):Enable()	
		oSection2:Cell("A2_AGENCIA"):Enable()	
		oSection2:Cell("A2_NUMCON" ):Enable()	
		oSection2:Cell("A2_CGC"    ):Enable()	
		oSection2:Cell("EF_NUM"    ):Disable()	

	EndCase

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportTxtAutºAutor  ³ Marcio Menon       º Data ³  01/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime o Total Geral por extenso e as mensagens de	        º±±
±±º          ³ autorizacao, conforme o modelo do bordero.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 	                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportTxtAut(oReport, cModelo, cNumConta, nVlrSecao)

	Local nCount

	oReport:SkipLine()
	oReport:PrintText(Extenso(nVlrSecao,.F.,MV_PAR04))
	oReport:SkipLine()

	If cModelo $ "CH/02"
		//"AUTORIZAMOS V.SAS. A EMITIR OS CHEQUES NOMINATIVOS AOS BENEFICIARIOS EM REFERENCIA,"
		oReport:PrintText(STR0008)
		//"DEBITANDO EM NOSSA CONTA CORRENTE NO DIA "
		oReport:PrintText(STR0009 + DtoC( mv_par03 ))
		//"PELO VALOR ACIMA TOTALIZADO."
		oReport:PrintText(STR0010)
	Elseif cModelo $ "CT/30"
		//"AUTORIZAMOS V.SAS. A PAGAR OS TITULOS ACIMA RELACIONADOS EM NOSSA"
		oReport:PrintText(STR0011)
		//"CONTA MOVIMENTO NO DIA "###", PELO VALOR ACIMA TOTALIZADO."
		oReport:PrintText(STR0012 + DtoC( mv_par03 ) + OemToAnsi(STR0013))	
	Elseif cModelo $ "CP/31"
		//"AUTORIZAMOS V.SAS. A PAGAR OS TITULOS EM REFERENCIA, LEVANDO A DEBITO DE NOSSA"
		oReport:PrintText(STR0014)
		//"CONTA CORRENTE NUM. "###" NO DIA "###" PELO VALOR ACIMA TOTALIZADO."
		oReport:PrintText(STR0015 + cNumConta + OemToAnsi(STR0016) + DtoC( mv_par03 ) + OemToAnsi(STR0017))	
	Elseif cModelo $ "CC/01/03/04/05/10/41/43"
		//"AUTORIZAMOS V.SAS. A EMITIREM ORDEM DE PAGAMENTO, OU DOC PARA OS BANCOS/CONTAS ACIMA."
		oReport:PrintText(STR0018)
		//"DOS TITULOS RESPECTIVOS DEBITANDO EM NOSSA C/CORRENTE NUM "
		oReport:PrintText(STR0019 + cNumConta)  
		//"NO DIA "### " PELO VALOR ACIMA TOTALIZADO."
		oReport:PrintText(STR0020 + dToC( mv_par03 ) + OemToAnsi(STR0021))   	
	Else
		//"AUTORIZAMOS V.SAS. A PAGAR OS TITULOS EM REFERENCIA, LEVANDO A DEBITO DE NOSSA"
		oReport:PrintText(STR0022)  
		//"CONTA CORRENTE NUM. "###" NO DIA "###" PELO VALOR ACIMA TOTALIZADO."
		oReport:PrintText(STR0023 + cNumConta + OemToAnsi(STR0016) + DtoC( mv_par03 ) + OemToAnsi(STR0017))   	
	EndIf

	For nCount := 1 to 5
		oReport:SkipLine()
	Next

	oReport:PrintText("-----------------------------------",/*nRow*/,900)
	oReport:PrintText(SM0->M0_NOMECOM,/*nRow*/,900)

Return ""

/*
---------------------------------------------- Release 3 ---------------------------------------------------------
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FinR710	³ Autor ³ Wagner Xavier 		³ Data ³ 05.10.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Bordero de Pagamento.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FinR710(void)							    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 									    		  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FinR710R3()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis 							 			     										 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LOCAL wnrel := "FINR710"  //Nome Default do relatorio em Disco
	LOCAL cDesc1 := STR0001  //"Este programa tem a fun‡„o de emitir os borderos de pagamen-"
	LOCAL cDesc2 := STR0002  //"tos."
	LOCAL cDesc3 :=""
	LOCAL Tamanho:="M"
	LOCAL cString:="SEA"

	PRIVATE titulo := STR0003 //"Emiss„o de Borderos de Pagamentos"
	PRIVATE cabec1 := ""
	PRIVATE cabec2 := ""
	PRIVATE aReturn := { OemToAnsi(STR0004), 1,OemToAnsi(STR0005), 1, 2, 1, "",1 }  //"Zebrado"###"Administracao"
	PRIVATE nomeprog:="FINR710"
	PRIVATE aLinha  := { },nLastKey := 0
	PRIVATE cPerg	 :="FIN710"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas 						     					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//AcertaSx1()
	pergunte("FIN710",.F.)

	// Tiago Rosssini Coradini - 05/11/15 - OS: 2393-15 - Mikaelly Gentil - Impressao de bordero sem interface de parametros, utilizado na consulta de titulos a pagar
	// Define parametros automaticamente para impressão sem interface de parametros
	If lNoAsk

		// Define automaticamente nome do relatorio em disco
		wnRel += "_" + GetNextAlias()

		MV_PAR01 := SE2->E2_NUMBOR
		MV_PAR02 := SE2->E2_NUMBOR
		MV_PAR03 := Posicione("SEA", 1, xFilial("SEA") + SE2->E2_NUMBOR, "EA_DATABOR")
		MV_PAR04 := 1
		MV_PAR05 := 1
		MV_PAR06 := 1

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vari veis utilizadas para parametros					 							³
	//³ mv_par01				// Do Bordero					 											³
	//³ mv_par02				// At‚ o Bordero														³
	//³ mv_par03				// Data para d‚bito													³
	//³ mv_par04				// Qual Moeda																³
	//³ mv_par05				// Outras Moedas														³
	//³ mv_par06				// Converte por					 										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicia a data para debito com a data base do sistema		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Retirado em 20/01/17, por Marcos Alberto Soprani
	//dbSelectArea("SX1")
	//If dbSeek ("FIN710"+"03")  // Busca a pergunta para mv_par03
	//	Reclock("SX1",.F.)
	//	Replace X1_CNT01 With "'"+dtoc(dDataBase)+"'"
	//	MsUnlock()
	//Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT 					     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,,,,lNoAsk)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString,,lNoAsk)

	If nLastKey == 27
		Return
	Endif

	RptStatus({|lEnd| Fa710Imp(@lEnd,wnRel,cString,Tamanho)},titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 	 ³ fa710Imp ³ Autor ³ Wagner Xavier 	      ³ Data ³ 05.10.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Bordero de Pagamento.									  									³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ fa710imp 												  												³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		   ³ Generico 												  												³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FA710Imp(lEnd,wnRel,cString, Tamanho)

	LOCAL CbCont,CbTxt
	LOCAL cModelo
	LOCAL nTotValor	:= 0
	LOCAL lCheque		:= .f.
	LOCAL lBaixa		:= .f.
	LOCAL nTipo
	LOCAL nColunaTotal
	LOCAL cNumConta	:= CriaVar("EA_NUMCON")
	LOCAL lNew			:= .F.
	LOCAL cNumBor
	LOCAL lAbatimento := .F.
	LOCAL nAbat 		:= 0
	Local lFirst := .T.
	Local cChave
	Local aArea	:= {}   
	Local sFilial

	Private nJuros := 0
	Private dBaixa := CriaVar("E2_BAIXA")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Vari veis utilizadas para Impress„o do Cabe‡alho e Rodap‚	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cbtxt 	:= SPACE(10)
	cbcont	:= 0
	li 		:= 80
	m_pag 	:= 1

	DbSelectArea("SEA")
	cArqSEA := Alias()
	cIndSEA := IndexOrd()
	cRegSEA := Recno()

	// Tiago Rosssini Coradini - 05/11/15 - OS: 1661-15 - Margareth Sartorio - Adicionado indice por valor do bordero
	//DbSetOrder(4)
	//DbSeek(cFilial+mv_par01,.T.)

	// Em 19/01/19, por Marcos Alberto Soprani
	dbSetOrder(5)
	dbSeek(cFilial+dtos(mv_par03)+MV_PAR01,.T.)

	nTipo := aReturn[4]
	nContador := 0

	SetRegua(RecCount())
	lNew := .T.

	While !Eof() .And. cFilial == EA_FILIAL .And. EA_NUMBOR <= mv_par02 .And. dtos(EA_DATABOR) = dtos(mv_par03)

		cNumBor  := SEA->EA_NUMBOR
		cbfRecEA := SEA->(Recno())

		IF lEnd
			@Prow()+1,001 PSAY OemToAnsi(STR0006)  //"CANCELADO PELO OPERADOR"
			Exit
		EndIF

		IncRegua()

		IF Empty(EA_NUMBOR)
			SEA->(dbSkip())
			Loop
		Endif

		IF SEA->EA_CART != "P"
			SEA->(dbSkip())
			Loop
		Endif

		lCheque := .f.
		lBaixa  := .f.
		cModelo := SEA->EA_MODELO
		dbSelectArea("SE2")
		cLoja := Iif ( Empty(SEA->EA_LOJA) , "" , SEA->EA_LOJA )

		// Borderos gerados em versao anterior
		IF Empty(SEA->EA_FILORIG) .AND. !Empty(xFilial("SE2"))
			cChave := xFilial("SE2")+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA+SEA->EA_TIPO+SEA->EA_FORNECE+cLoja
		Else //Borderos gerados a partir da versao 7.10
			cChave := SEA->EA_FILORIG+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA+SEA->EA_TIPO+SEA->EA_FORNECE+cLoja
		Endif
		aArea:=GetArea()
		DbSelectArea("SE2")
		dbSetOrder(1)
		dbSeek(cChave)
		RestArea(aArea)

		IF MV_PAR05 == 2 .And. SE2->E2_MOEDA <> MV_PAR04
			dbSelectArea("SEA")
			SEA->(dbSkip())
			Loop
		Endif

		MsSeek(cChave)
		dbSelectArea("SE5")
		dbSetOrder(2)
		dbSeek( cFilial+"VL"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+DtoS(SE2->E2_BAIXA)+SE2->E2_FORNECE+SE2->E2_LOJA )

		While !Eof() .and. ;
		E5_FILIAL		== cFilial			 		.and. ;
		E5_TIPODOC	== "VL"            	.and. ;
		E5_PREFIXO	== SE2->E2_PREFIXO 	.and. ;
		E5_NUMERO		== SE2->E2_NUM 	 		.and. ;
		E5_PARCELA	== SE2->E2_PARCELA 	.and. ;
		E5_TIPO			== SE2->E2_TIPO	 		.and. ;
		E5_DATA			== SE2->E2_BAIXA		.and. ;
		E5_CLIFOR		== SE2->E2_FORNECE	.and. ;
		E5_LOJA			== cLoja
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ S¢ considera baixas que nao possuem estorno   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !TemBxCanc(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)
				If SubStr( E5_DOCUMEN,1,6 ) == cNumBor .And. E5_MOTBX != "PCC"
					lBaixa := .t.
					Exit
				Endif
			EndIf
			dbSkip()
		Enddo

		If !lBaixa 
			If (xFilial("SE2") <> "  " .and. xFilial("SE5") <> "  ") .or. (xFilial("SE2") == "  " .and. xFilial("SE5") <> "  ")
				sFilial := SE2->E2_FILIAL
			Else
				sFilial := xFilial("SE5")
			EndIf
			If (dbSeek( sFilial+"BA"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+DtoS(SE2->E2_BAIXA)+SE2->E2_FORNECE+SE2->E2_LOJA))
				While !Eof() .and. ;
				E5_FILIAL		== sFilial 					.and. ;
				E5_TIPODOC	== "BA"            	.and. ;
				E5_PREFIXO	== SE2->E2_PREFIXO	.and. ;
				E5_NUMERO		== SE2->E2_NUM 	 		.and. ;
				E5_PARCELA	== SE2->E2_PARCELA	.and. ;
				E5_TIPO			== SE2->E2_TIPO	 		.and. ;
				E5_DATA			== SE2->E2_BAIXA	 	.and. ;
				E5_CLIFOR		== SE2->E2_FORNECE 	.and. ;
				E5_LOJA			== SE2->E2_LOJA

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ S¢ considera baixas que nao possuem estorno   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !TemBxCanc(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)
						If SubStr( E5_DOCUMEN,1,6 ) == cNumBor .And. E5_MOTBX != "PCC"
							lBaixa := .t.
							Exit
						Endif
					EndIf
					dbSkip()
				Enddo
			Endif
		Endif

		dbSelectArea("SEF")
		/*	If (!Empty(SE5->E5_NUMCHEQ) .And. dbSeek( cFilial+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+SE5->E5_NUMCHEQ))
		lCheque := .t.
		Endif*/
		//TROQUEI O SFILIAL PARA XFILIAL POIS ESTAVA DANDO ERRO
		//If (dbSeek( sFilial+"BA"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+DtoS(SE2->E2_BAIXA)+SE2->E2_FORNECE+SE2->E2_LOJA))
		If (dbSeek( XFILIAL("SEF")+"BA"+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+DtoS(SE2->E2_BAIXA)+SE2->E2_FORNECE+SE2->E2_LOJA))
			If (!Empty(SE5->E5_NUMCHEQ) .And. dbSeek( cFilial+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA+SE5->E5_NUMCHEQ))
				lCheque := .t.
			Endif
		EndIf

		// Localiza o fornecedor do titulo que esta no bordero
		dbSelectArea("SA2")
		// Borderos gerados em versao anterior
		IF Empty(SEA->EA_FILORIG) .AND. !Empty(xFilial("SA2"))
			cChave := xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA
		Else //Borderos gerados a partir da versao 7.10
			If !Empty(SEA->EA_FILORIG) .AND. !Empty(xFilial("SA2"))	
				cChave := SEA->EA_FILORIG+SE2->E2_FORNECE+SE2->E2_LOJA
			Else	
				cChave := xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA
			Endif
		Endif
		MsSeek( cChave )

		dbSelectArea("SEA")

		IF li > 55 .Or. lNew
			fr710Cabec( SEA->EA_MODELO, nTipo, Tamanho, @lFirst)
			m_pag++
			lNew := .F.
		Endif

		lAbatimento := SEA->EA_TIPO $ MV_CPNEG .or. SEA->EA_TIPO $ MVABATIM
		If lAbatimento
			nAbat 	:= SE2->E2_SALDO
		Else
			nAbat := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",SE2->E2_MOEDA,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA)
		EndIf

		If ! lAbatimento
			li++
			@li, 0 PSAY SEA->EA_PREFIXO
			@li, 4 PSAY SEA->EA_NUM
			@li,17 PSAY SEA->EA_PARCELA
		EndIf
		cNumConta := SEA->EA_NUMCON

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua calculo dos juros do titulo posicionado ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fa080Juros(1)	

		If SEA->EA_MODELO $ "CH/02"
			dbSelectArea("SEA")
			If ! lAbatimento
				If lCheque
					@li,20 PSAY SubStr(SEF->EF_BENEF,1, 33)
				Elseif lBaixa
					@li,20 PSAY SubStr(SE5->E5_BENEF,1, 33)
				Else
					@li,20 PSAY SubStr(SA2->A2_NOME,1, 33)
				Endif
			EndIf

			dbSelectArea("SA6")
			If lBaixa
				dbSeek( xFilial("SA6")+SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA))
			Else
				dbSeek( xFilial("SA6")+SEA->(EA_PORTADO+EA_AGEDEP+EA_NUMCON))
			Endif
			dbSelectArea("SEA")
			If ! lAbatimento
				@li,55 PSAY Left(SA6->A6_NREDUZ,15)
				@li,71 PSAY SE2->E2_VENCREA
				If lCheque
					@li,82 PSAY "CH. " + SEF->EF_NUM
				Endif
			EndIf
			nColunaTotal := 102
		Elseif SEA->EA_MODELO $ "CT/30"
			If ! lAbatimento
				@li,20 PSAY SubStr(SA2->A2_NOME,1, 33)
				@li,55 PSAY SE2->E2_VENCREA
				If lCheque
					@li,78 PSAY SEF->EF_NUM
				Endif
			EndIf
			nColunaTotal := 94
		Elseif SEA->EA_MODELO $ "CP/31"
			If ! lAbatimento
				@li,20 PSAY SubStr(SA2->A2_NOME,1, 33)
			EndIf
			dbSelectArea("SA6")
			dbSeek( xFilial("SA6")+SEA->(EA_PORTADO+EA_AGEDEP+EA_NUMCON))
			dbSelectArea("SEA")
			If ! lAbatimento
				@li,55 PSAY Left(SA6->A6_NREDUZ,15)
				@li,71 PSAY SE2->E2_VENCREA
				@li,83 PSAY SE2->E2_NUMBCO
			EndIf
			nColunaTotal := 99
		Elseif SEA->EA_MODELO $ "CC/01/03/04/05/10/41/43"
			dbSelectArea("SA6")
			dbSeek( xFilial("SA6")+SEA->(EA_PORTADO+EA_AGEDEP+EA_NUMCON))
			dbSelectArea("SEA")
			If ! lAbatimento
				@li,20  PSAY Left(SA6->A6_NREDUZ,15)
				@li,36  PSAY SA2->A2_BANCO + " " + PadR(AllTrim(SA2->A2_AGENCIA) + If (Empty(SA2->A2_YDVAG), "", "-" + SA2->A2_YDVAG), 8) + AllTrim(SA2->A2_NUMCON) + If (Empty(SA2->A2_YDVCTA), "", "-" + SA2->A2_YDVCTA)
				@li,60  PSAY SubStr(SA2->A2_NOME, 1, 25 )
				@li,86  PSAY SA2->A2_CGC Picture IIF(Len(Alltrim(SA2->A2_CGC))>11,"@R 99999999/9999-99","@R 999999999-99")
				@li,104 PSAY SE2->E2_VENCREA
			EndIf
			nColunaTotal := 115
		Else
			If ! lAbatimento
				@li,20 PSAY SubStr(SA2->A2_NOME,1, 33)
			EndIf
			dbSelectArea("SA6")
			dbSeek( xFilial("SA6")+SEA->(EA_PORTADO+EA_AGEDEP+EA_NUMCON))
			dbSelectArea("SEA")
			If ! lAbatimento
				@li,55 PSAY Left(SA6->A6_NREDUZ,15)
				@li,71 PSAY SE2->E2_VENCREA
				@li,84 PSAY SE2->E2_NUMBCO
			EndIf
			nColunaTotal := 100
		Endif

		If lBaixa
			If ! lAbatimento
				@li,nColunaTotal PSAY Round(NoRound(xmoeda(SE5->E5_VALOR,SE2->E2_MOEDA,MV_PAR04,Iif(MV_PAR06==1,SEA->EA_DATABOR,dDataBase),MsDecimais(1)+1),MsDecimais(1)+1),MsDecimais(1)) Picture "@E 999,999,999.99"
			EndIf
			nTotValor += xMoeda(SE5->E5_VALOR,SE2->E2_MOEDA,MV_PAR04,Iif(MV_PAR06==1,SEA->EA_DATABOR,dDataBase))
			nAbat := 0
		Else
			If ! lAbatimento
				@li,nColunaTotal PSAY Round(NoRound(xMoeda(SE2->E2_SALDO-SE2->E2_SDDECRE+SE2->E2_SDACRES-nAbat+nJuros,SE2->E2_MOEDA,MV_PAR04,Iif(MV_PAR06==1,SEA->EA_DATABOR,dDataBase),MsDecimais(1)+1),MsDecimais(1)+1),MsDecimais(1))Picture "@E 999,999,999.99"
			EndIf
			If lAbatimento
				nTotValor -= Round(NoRound(xMoeda(SE2->E2_SALDO+nJuros,SE2->E2_MOEDA,MV_PAR04,Iif(MV_PAR06==1,SEA->EA_DATABOR,dDataBase),MsDecimais(1)+1),MsDecimais(1)+1),MsDecimais(1))
			Else
				nTotValor += Round(NoRound(xMoeda(SE2->E2_SALDO-SE2->E2_SDDECRE+SE2->E2_SDACRES-nAbat+nJuros,SE2->E2_MOEDA,MV_PAR04,Iif(MV_PAR06==1,SEA->EA_DATABOR,dDataBase),MsDecimais(1)+1),MsDecimais(1)+1),MsDecimais(1))
			Endif
		Endif

		dbSelectArea("SEA")
		dbGoTo(cbfRecEA)
		SEA->(dbSkip())

		// Problema de posicionamento de fim de arquivo
		cbfFinTab := .F.
		If cbfRecEA == SEA->(Recno())
			cNumBor   := ""
			cbfFinTab := .T.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se n„o h  mais registros v lidos a analisar.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DO WHILE !Eof() .And. cFilial == EA_FILIAL .And. EA_NUMBOR <= mv_par02 .and. (Empty(EA_NUMBOR) .or. SEA->EA_CART != "P")
			SEA->(dbSkip())
		ENDDO

		If cNumBor != SEA->EA_NUMBOR
			lNew := .T. 							// Novo bordero a ser impresso
			If li != 80
				li+=2
				@li,	00 PSAY __PrtThinLine()
				li++
				@li, 75 PSAY OemToAnsi(STR0007)  //"TOTAL GERAL ..... "
				@li,nColunaTotal PSAY nTotValor	Picture "@E 999,999,999.99"
				cExtenso := Extenso( nTotValor, .F., MV_PAR04 )
				li+=2
				@li,	1 PSAY Trim(SubStr(cExtenso,1,100))
				If Len(Trim(cExtenso)) > 100
					li++
					@li, 0 PSAY SubStr(cExtenso,101,Len(Trim(cExtenso))-100)
				Endif
				li+=2
				If cModelo $ "CH/02"
					@li, 0 PSAY OemToAnsi(STR0008)  //"AUTORIZAMOS V.SAS. A EMITIR OS CHEQUES NOMINATIVOS AOS BENEFICIARIOS EM REFERENCIA,"
					li++
					@li, 0 PSAY OemToAnsi(STR0009) + DtoC( mv_par03 )  //"DEBITANDO EM NOSSA CONTA CORRENTE NO DIA "
					li++
					@li, 0 PSAY OemToAnsi(STR0010)  //"PELO VALOR ACIMA TOTALIZADO."
				Elseif cModelo $ "CT/30"
					@li, 0 PSAY OemToAnsi(STR0011)  //"AUTORIZAMOS V.SAS. A PAGAR OS TITULOS ACIMA RELACIONADOS EM NOSSA"
					li++
					@li, 0 PSAY OemToAnsi(STR0012)   + DtoC( mv_par03 ) + OemToAnsi(STR0013)  //"CONTA MOVIMENTO NO DIA "###", PELO VALOR ACIMA TOTALIZADO."
				Elseif cModelo $ "CP/31"
					@li, 0 PSAY OemToAnsi(STR0014)  //"AUTORIZAMOS V.SAS. A PAGAR OS TITULOS EM REFERENCIA, LEVANDO A DEBITO DE NOSSA"
					li++
					@li, 0 PSAY OemToAnsi(STR0015) + cNumConta + OemToAnsi(STR0016)+ DtoC( mv_par03 ) +OemToAnsi(STR0017)  //"CONTA CORRENTE NUM. "###" NO DIA "###" PELO VALOR ACIMA TOTALIZADO."
				Elseif cModelo $ "CC/01/03/04/05/10/41/43"
					@li, 0 PSAY OemToAnsi(STR0018)  //"AUTORIZAMOS V.SAS. A EMITIREM ORDEM DE PAGAMENTO, OU DOC PARA OS BANCOS/CONTAS ACIMA."
					li++
					@li, 0 PSAY OemToAnsi(STR0019)   + cNumConta  //"DOS TITULOS RESPECTIVOS DEBITANDO EM NOSSA C/CORRENTE NUM "
					li++
					@li, 0 PSAY OemToAnsi(STR0020) + dToC( mv_par03 ) +OemToAnsi(STR0021)  //"NO DIA "### " PELO VALOR ACIMA TOTALIZADO."
				Else
					@li, 0 PSAY OemToAnsi(STR0022)  //"AUTORIZAMOS V.SAS. A PAGAR OS TITULOS EM REFERENCIA, LEVANDO A DEBITO DE NOSSA"
					li++
					@li, 0 PSAY OemToAnsi(STR0023) + cNumConta + OemToAnsi(STR0016) + DtoC( mv_par03 ) +OemToAnsi(STR0017)  //"CONTA CORRENTE NUM. "###" NO DIA "###" PELO VALOR ACIMA TOTALIZADO."
				Endif
				li+=3
				@li,60 PSAY "----------------------------"
				li++
				@li,60 PSAY SM0->M0_NOMECOM
				li++
				@li, 0 PSAY " "
				nTotValor := 0
			Endif
		EndIf
		dbSelectArea("SEA")

		// Problema de posicionamento de fim de arquivo
		If cbfFinTab
			Exit
		EndIf

	Enddo

	If cArqSEA <> ""
		dbSelectArea(cArqSEA)
		dbSetOrder(cIndSEA)
		dbGoTo(cRegSEA)
		RetIndex("SEA")
	EndIf

	Set Device To Screen
	dbSelectArea("SE5")
	dbSetOrder( 1 )
	dbSelectArea("SE2")
	dbSetOrder(1)      
	dbSelectArea("SEA")
	dbSetOrder(1)

	Set Filter To
	If aReturn[5] = 1
		Set Printer To
		dbCommit( )
		Ourspool(wnrel)
	Endif
	MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fr710cabec³ Autor ³ Wagner Xavier 		³ Data ³ 24.05.93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cabe‡alho do Bordero 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³fr710cabec() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fr710cabec( cModelo, nTipo, Tamanho, lFirst)

	Local cCabecalho
	Local cTexto

	If cModelo $ "CH/02" // Tabela("58",cModelo)
		cTexto := Tabela("58",@cModelo)
		cCabecalho := OemToAnsi(STR0025)  //"PRF NUMERO PC B E N E F I C I A R I O                  BANCO           DT.VENC  HISTORICO               VALOR A PAGAR"
	Elseif cModelo $ "CT/30"
		cTexto := Tabela("58",@cModelo)
		cCabecalho := OemToAnsi(STR0027)  //"PRF NUMERO PC B E N E F I C I A R I O                   DT.VENC BCO AGENCIA NUM CHEQUE         VALOR A PAGAR"
	Elseif cModelo $ "CP/31"
		cTexto := Tabela("58",@cModelo)
		cCabecalho := OemToAnsi(STR0029)  //"PRF NUMERO PC B E N E F I C I A R I O                  BANCO           DT.VENC  NUM.CHEQUE        VALOR  A PAGAR"
	ElseIf cModelo $ "CC/01/03/04/05/10/41/43"
		cTexto := Tabela("58",@cModelo) 
		cCabecalho := OemToAnsi(STR0031)  //"PRF NUMERO       PC B A N C O       BCO AGENC NUMERO 			 BENEFICIARIO              CNPJ/CPF        DT.VENC       VALOR A PAGAR"
	Else
		cTexto := Tabela("58",@cModelo)
		cCabecalho := OemToAnsi(STR0033)  //"PRF NUMERO PC B E N E F I C I A R I O                  BANCO           DT.VENC  NUM.CHEQUE        VALOR  A PAGAR"
	Endif

	dbSelectArea( "SA6" )
	dbSeek( cFilial+SEA->EA_PORTADO+SEA->EA_AGEDEP+SEA->EA_NUMCON )
	// Implementado por Marcos Alberto Soprani em 04/12/13 a pedido da Mikaelly
	cfAgencia := SA6->A6_AGENCIA
	cfNumCont := SA6->A6_NUMCON
	If !Empty(SA6->A6_DVAGE)
		cfAgencia := Alltrim(SA6->A6_AGENCIA)+"-"+SA6->A6_DVAGE
	EndIf
	If !Empty(SA6->A6_DVCTA)
		cfNumCont := Alltrim(SA6->A6_NUMCON)+"-"+SA6->A6_DVCTA
	EndIf

	aCabec := {Sm0->M0_nome,;
	PadC(OemToAnsi(STR0034),97),;
	OemToAnsi(STR0035)+DtoC(dDataBase),;
	PadC(cTexto,97),;
	OemToAnsi(STR0036)+SEA->EA_NUMBOR,;
	Pad(OemToAnsi(STR0037) + SA6->A6_NOME,130),;
	Pad(OemToAnsi(STR0038) + cfAgencia+STR0040+cfNumCont,130),; //" - C/C "
	Pad(SA6->A6_END + " "  + SA6->A6_MUN + " " + SA6->A6_EST,130)}

	Cabec1 := cCabecalho			  
	li := Cabec710(Titulo,Cabec1,NomeProg,tamanho,Iif(aReturn[4]==1,GetMv("MV_COMP"),;
	GetMv("MV_NORM")), aCabec, @lFirst)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³fa710DtDeb³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 12.01.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da data de d‚bito para o bordero				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³fa710DtDeb() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//Static Function fa710DtDeb()

//Local lRet := .T.
//lRet := IIf (mv_par03 < dDataBase, .F. , .T. )
//Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Cabec170  ³ Autor ³ Mauricio Pequim Jr.	³ Data ³ 14.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da data de d‚bito para o bordero	    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³Cabec170()	 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FUNCTION cabec710(cTitulo,cCabec1,cNomPrg,nTamanho,nChar,aCustomText,lFirst)

	Local cAlias,nLargura,nLin:=0, aDriver := ReadDriver(),nCont:= 0, cVar,uVar,cPicture
	Local lWin := .f.
	Local nRow, nCol
	Default aCustomText := Nil // Parâmetro que se passado suprime o texto padrao desta função por outro customizado

	#DEFINE INIFIELD    Chr(27)+Chr(02)+Chr(01)
	#DEFINE FIMFIELD    Chr(27)+Chr(02)+Chr(02)
	#DEFINE INIPARAM    Chr(27)+Chr(04)+Chr(01)
	#DEFINE FIMPARAM    Chr(27)+Chr(04)+Chr(02)

	lPerg := If(GetMv("MV_IMPSX1") == "S" ,.T.,.F.)

	cNomPrg := Alltrim(cNomPrg)

	Private cSuf:=""

	DEFAULT lFirst := .t.

	If TYPE("__DRIVER") == "C"
		If "DEFAULT"$__DRIVER
			lWin := .t.
		EndIf
	EndIf

	nLargura:=132

	IF aReturn[5] == 1   // imprime em disco
		lWin := .f.    // Se eh disco , nao eh windows
	Endif

	If lFirst       
		nRow := PRow()
		nCol := PCol()
		SetPrc(0,0)
		If aReturn[5] <> 2 // Se nao for via Windows manda os caracteres para setar a impressora
			If nChar == NIL .and. !lWin .and. __cInternet == Nil
				@ 0,0 PSAY &(If(aReturn[4]=1,aDriver[3],aDriver[4]))
			ElseIf !lWin .and. __cInternet == Nil
				If nChar == 15
					@ 0,0 PSAY &(If(aReturn[4]=1,aDriver[3],aDriver[4]))
				Else
					@ 0,0 PSAY &(aDriver[4])
				EndIf
			EndIf
		EndIF                      		
		If GetMV("MV_CANSALT",,.T.) // Saltar uma página na impressão
			If GetMv("MV_SALTPAG",,"S") != "N"
				Setprc(nRow,nCol)
			EndIf	
		Endif
	Endif
	// Impressão da lista de parametros quando solicitada
	//Cabecalho.
	FinCgcCabec(Titulo, Cabec1, cabec2, nomeprog, nChar, mv_par03, aCustomText)

	@ 05,00 PSAY __PrtLeft(aCustomText[1])		// Empresa
	@ 05,00 PSAY __PrtCenter(aCustomText[2])	// Titulo do relatorio
	@ 05,00 PSAY __PrtRight(aCustomText[3])	// Data EmissÆo
	@ 06,00 PSAY __PrtCenter(aCustomText[4])	// Descri‡Æo do tipo de bordero
	@ 06,00 PSAY __PrtRight(aCustomText[5])	// Nro do bordero
	@ 09,00 PSAY __PrtLeft(aCustomText[6])		// Ao Banco
	@ 10,00 PSAY __PrtLeft(aCustomText[7])	// Agencia - Conta Corrente
	@ 11,00 PSAY __PrtLeft(aCustomText[8])		// Endereco Banco

	If LEN(Trim(cCabec1)) != 0
		@ 12,00  PSAY __PrtThinLine()
		@ 13,00  PSAY cCabec1
		@ 14,00  PSAY __PrtThinLine()
	EndIf
	nLin :=15 	
	m_pag++
	lFirst := .f.
	If Subs(__cLogSiga,4,1) == "S"
		__LogPages()
	EndIf

Return nLin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³		     ³ Autor ³ Adilson H Yamaguchi   ³ Data ³ 13/12/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Monta Cabecalho do relatorio                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ConCGCCabec(Titulo, Cabec1, Cabec2, NomeProg, nTam,         ³±±
±±³			  |			   dDataRef, aCustomText, lFirst)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGAFIN                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ExpC1 = Conteudo da cabec1               		           ³±±
±±³           ³ExpC2 = Conteudo da cabec2               				   ³±±
±±³           ³ExpC3 = Titulo                           				   ³±±
±±³           ³ExpC4 = Nome da Rotina                   				   ³±±
±±³           ³ExpN1 = Tamanho                          				   ³±±
±±³           ³ExpD1 = Data de Referencia              				       ³±±
±±³           ³ExpL1 = Tamanho                          				   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FinCgcCabec(Titulo, Cabec1, cabec2, nomeprog, nTam, dDataRef, aCustomText, lFirst)

	Local Tamanho := "M"
	Local aCabec

	nTam 	 := 130
	dDataRef := If(dDataRef = Nil, mv_par01, dDataBase)

	aCabec :=	{"","__LOGOEMP__"}

	cabec(Titulo,"","","",tamanho,	nTam, aCabec)

Return .T.

Static Function AcertaSx1()

	Local aPergs	:={}
	Aadd(aPergs,{"Qual Moeda ?","?Cual Moneda?","Which Currency",          "mv_ch4","N",1,0,1,"C","","mv_par04", "Moeda 1  ","Moneda 1","Currency 1","","","Moeda 2","Moneda 2 ","Currency 2","","","Moeda 3","Moneda 3","Currency 3","","","Moeda 4","Moeneda 4","Currency 4","","","Moeda 5","Moneda 5","Currency5","","","","",".FIN15015.",""})
	Aadd(aPergs,{"Outras Moedas ?","?Otras Monedas ?","Other Currencies ?","mv_ch5","N",1,0,1,"C","","mv_par05","Converter","Convertir","Convert   ","","","Nao Imprimir","No Imprimir","Do not Print","","","","","","","","","","","","","","","","","","","",".FIN15029.",""})
	Aadd(aPergs,{"Converte por  ?","?Convierte por ?","Convert per      ?","mv_ch6","N",1,0,1,"C","","mv_par06","Data Bordero","Fecha Bordero","Date of Bordero","","","Data Base","Fecha de Hoy","Base Data","","","","","","","","","","","","","","","","","","","",".FIN15017.",""})

	aJustaSX1("FIN710",aPergs)

Return()
