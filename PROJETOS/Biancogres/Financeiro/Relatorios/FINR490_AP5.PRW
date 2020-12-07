#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function finr490()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetPrvt("WNREL,CDESC1,CDESC2,CDESC3,CSTRING,CSAVCOR")
	SetPrvt("TITULO,ARETURN,NOMEPROG,NLASTKEY,CPERG,LI")
	SetPrvt("TAMANHO,LIMITE,LEND,LABORTPRINT,CEXTENSO,J")
	SetPrvt("NTIPO,NREC,NCONTADOR,CDOCTO,CCHEQUE,NFIRST")
	SetPrvt("LAGLUT,")

	#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/01/01 ==>     #DEFINE PSAY SAY
	#ENDIF

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ FINR490  ³ Autor ³ Paulo Boschetti       ³ Data ³ 23.04.92 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ C¢pia de Cheques                                           ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ FINR490(void)                                              ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³  Uso     ³ Generico                                                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Rdmake    ³ Autor ³  Luiz Carlos Vieira        ³ Data ³ Fri  19/06/98  ³±±
	±±³          ÃÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³          ³ Objetivo: Alteracao da impressao do cabecalho para permitir³±±
	±±³          ³           a impressao em Default do Windows.               ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel    := ""
	cDesc1   := "Este programa ir  imprimir as copias dos cheques emitidos."
	cDesc2   := "Ser  impresso 1 ou 2 cheques for folha."
	cDesc3   := ""
	cString  := "SEF"
	cSavCor  := SetColor()

	titulo      := "Copias de Cheques"
	aReturn     := { "Zebrado", 1,"Administracao", 4, 2, 1, "",1 }
	nomeprog    := "FINR490"
	nLastKey    := 0
	cPerg       := "FIN490"
	li          := 1
	Tamanho     := "P"
	Limite      := 80
	lEnd        := .F.
	lAbortPrint := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte("FIN490",.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01            // Codigo Do Banco                       ³
	//³ mv_par02            // Da Agencia                            ³
	//³ mv_par03            // Da Conta                              ³
	//³ mv_par04            // Do Cheque                             ³
	//³ mv_par05            // Ate o Cheque                          ³
	//³ mv_par06            // Imprime composicao do cheque          ³
	//³ mv_par07            // Copias p/ pagina (1/2)                ³
	//³ mv_par08            // Imprime Numeracao Sequencial          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := "FINR490"            //Nome Default do relatorio em Disco
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"")

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		SetColor(cSavCor)
		Return
	Endif

	#IFDEF WINDOWS
	RptStatus({|| Fa490Imp()},titulo)// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>     RptStatus({|| Execute(Fa490Imp)},titulo)
Return
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>     Function FA490Imp
Static Function FA490Imp()
	#ENDIF

	Local  j
	cExtenso  := ""
	j         := 0
	nTipo     := 0
	nRec      := 0
	nContador := 0
	cDocto    := ""

	nTipo     := IIF(aReturn[4]==1,15,18)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe o Banco                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("SA6")
	dbSeek(xFilial()+mv_par01+mv_par02+mv_par03)

	IF !Found()
		Set Device To Screen
		Help(" ",1,"BCONOEXIST")
		Return
	EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localiza o 1.Cheque a ser impresso                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("SEF")
	dbSeek(xFilial()+mv_par01+mv_par02+mv_par03+mv_par04,.T.)

	SetRegua(RecCount())

	If !( "DEFAULT" $ UPPER(__DRIVER) )
		SetPrc(0,0)
	Endif

	@li,00 PSAY AvalImp(Limite)

	While !Eof() .And. EF_FILIAL+EF_BANCO == xFilial("SEF")+mv_par01 .And. ;
	EF_AGENCIA == mv_par02 .And. EF_CONTA == mv_par03 .And. ;
	EF_NUM <= mv_par05

		#IFNDEF WINDOWS
		Inkey()
		If LastKey() == 286
			lEnd := .T.
		End
		#ELSE
		If lAbortPrint
			lEnd := .T.
		Endif
		#ENDIF

		If lEnd
			@Prow()+1,1 PSAY "Cancelado pelo operador"
			Exit
		EndIF

		IncRegua()

		IF EF_IMPRESS $ "AC" .or. SubStr(EF_TIPO,1,2) == "TB"
			dbSkip()
			Loop
		EndIF

		IF mv_par07 == 1		//uma copia por folha
			li := 1
		Elseif li > 32 		//so coube uma copia
			li := 1
		Else				//2 copias por folha
			IF nContador == 0
				li := 1
			Else
				li := 33
			EndIF
		EndIF

		nContador := nContador + 1
		IF nContador > 2
			nContador := 1
			li        := 1
		EndIF

		__LogPages()

		@li, 1 PSAY Alltrim(SM0->M0_NOMECOM) + " - " + Alltrim(SM0->M0_FILIAL) + "  -  COPIA DE CHEQUE"
		li := li + 1
		@li, 0 PSAY Replicate("-",90)
		li := li + 1
		@li, 0 PSAY "|  Numero Cheque "+EF_NUM
		@li,35 PSAY "Data da Emissao " +Dtoc(EF_DATA)
		@li,90 PSAY "|"
		li := li + 1
		@li, 0 PSAY "|  Banco "+EF_BANCO+  "     "    +SA6->A6_NREDUZ
		@li,35 PSAY "Agencia " +EF_AGENCIA+"   Conta "+EF_CONTA
		@li,90 PSAY "|"
		li := li + 1
		@li, 0 PSAY "|  Valor Cheque "+Transform(EF_VALOR,"@E 9999,999,999.99")
		@li,35 PSAY "Data do Cheque  "+Dtoc(EF_DATA)
		@li,90 PSAY "|"
		li := li + 1
		@li, 0 PSAY "|  Favorecido "+EF_BENEF
		@li,90 PSAY "|"
		li := li + 1
		@li, 0 PSAY "|  Historico  "+EF_HIST
		@li,90 PSAY "|"
		li := li + 1
		If mv_par08 == 1

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pegar e gravar o proximo numero da Copia do Cheque       ³
			//³ Posicionar no sx6 utilizando GetMv. N„o Utilize Seek !!! ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDocto := STRZERO(VAL(Getmv("MV_NUMCOP"))+1,6)
			dbSelectArea("SX6")
			GetMv("MV_NUMCOP")
			RecLock("SX6",.F.)
			SX6->X6_CONTEUD := cDocto
			MsUnlock()
			dbSelectArea("SEF")

			@li, 0 PSAY "|  Copia de Cheque No. "+cDocto
			@li,90 PSAY "|"
		Else
			@li, 0 PSAY "|"
			@li,90 PSAY "|"
		End
		li := li + 1
		@li, 0 PSAY "|  Vistos"
		@li,90 PSAY "|"
		li := li + 1
		@li, 0 PSAY "|"+Replicate("-",89)+"|"
		li := li + 1
		@li, 0 PSAY "|Observacoes      |Contas a Pagar|Gerente Financ|Contabilidade |Assinado por              |"
		li := li + 1
		@li, 0 PSAY "|-----------------|--------------|--------------|--------------|--------------------------|"
		li := li + 1
		For j:=1 to 3
			@li, 0 PSAY "|"
			@li,18 PSAY "|"
			@li,33 PSAY "|"
			@li,48 PSAY "|"
			@li,63 PSAY "|"
			@li,90 PSAY "|"
			li := li + 1
		Next j
		@li, 0 PSAY Replicate("-",90)
		nRec:=RecNo()
		IF mv_par06 == 1
			cCheque := SEF->EF_NUM
			fr490Cpos()
		EndIF
		dbGoTo(nRec)
		dbSkip()
	EndDo

	Set Device To Screen
	Set Filter To

	If aReturn[5] == 1
		Set Printer To
		dbCommit()
		ourspool(wnrel)
	Endif

	MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fr490Cpos³ Autor ³ Wagner Xavier         ³ Data ³ 13.11.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Copia de cheques                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FINR490(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fr490Cpos
Static Function fr490Cpos()

	nFirst := 0
	lAglut := .F.

	DbSelectArea("SEF")
	dbSeek(xFilial()+mv_par01+mv_par02+mv_par03+cCheque)
	While !Eof() .And. EF_FILIAL+EF_BANCO == xFilial()+mv_par01 .And. ;
	EF_AGENCIA == mv_par02 .And. EF_CONTA == mv_par03 .And. ;
	EF_NUM == cCheque

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se nao ‚ principal o cancelado                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF EF_IMPRESS == "C"
			dbSkip()
			Loop
		End
		IF li > 58
			li:=1
			@li,0 PSAY "COPIA DO CHEQUE : "+ cCheque + " - Continuacao"
			li := li + 1
		EndIF
		IF nFirst == 0
			IF EF_IMPRESS == "A"
				lAglut:=.T.
			EndIF
			IF !lAglut .and. Empty(SEF->EF_TITULO)
				dbSkip()
				Loop
			End
			li := li + 1
			@li,0 PSAY "|- Composicao do Cheque "+Replicate("-",66)+"|"
			li := li + 1
			@li,0 PSAY "|Fornec|  Nome Fornecedor   |Prf|Numero|P| Natureza |  Vencto  |           Valor do Titulo|"
			li := li + 1
			@li,0 PSAY Repl("-",90)
		EndIF
		IF Empty(SEF->EF_TITULO)
			dbSkip()
			Loop
		End
		nFirst := nFirst + 1
		li := li + 1
		dbSelectArea("SE2")
		dbSeek(xFilial()+SEF->EF_PREFIXO+SEF->EF_TITULO+SEF->EF_PARCELA+SEF->EF_TIPO+SEF->EF_FORNECE+SEF->EF_LOJA)
		@li, 0 PSAY "|"
		@li, 1 PSAY E2_FORNECE
		@li, 7 PSAY "|"
		@li, 8 PSAY SubStr(E2_NOMFOR,1,20)
		@li,28 PSAY "|"
		dbSelectArea("SEF")
		@li,29 PSAY EF_PREFIXO+"|"+EF_TITULO+"|"+EF_PARCELA+"|"
		@li,42 PSAY SE2->E2_NATUREZ
		@li,52 PSAY "|"
		@li,53 PSAY SE2->E2_VENCTO
		@li,63 PSAY "|"
		@li,73 PSAY EF_VALOR PicTure tm(EF_VALOR,17)
		@li,90 PSAY "|"
		dbSkip()
	EndDO
	IF nFirst>0
		li := li + 1
		@li, 0 PSAY Replicate("-",90)
	End

Return
