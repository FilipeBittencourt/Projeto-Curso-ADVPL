#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#include "topconn.ch"
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function Bia041A()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local x

	SetPrvt("_PESO,WNREL,TAMANHO,TITULO,CDESC1,CDESC2")
	SetPrvt("CDESC3,CBCONT,CABEC1,CABEC2,CSTRING,LCONTINUA")
	SetPrvt("LFIRST,CPEDANT,CPERG,ARETURN,NOMEPROG,NLASTKEY")
	SetPrvt("NBEGIN,ALINHA,LI,LIMITE,LRODAPE,NTOTQTD")
	SetPrvt("NTOTVAL,NTOT2UM,WMENS1,WMENS2,WMENS3,CBTXT")
	SetPrvt("M_PAG,NTIPO,WROMANEIO,WPESOBR,LEND,WTOT2UM")
	SetPrvt("CNREDUZ,CNOME,WTOTPROD,WPALLETS,WPALLETSCX,WSOK")
	SetPrvt("WXPALLETS,WSOMAPALLETS,")
	Private WSDIVISOR := 1

	#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/01/01 ==>     #DEFINE PSAY SAY
	#ENDIF

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ BIA041A  ³ Autor ³ Gustav Koblinger Jr   ³ Data ³ 05.08.99 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Romaneio de Despacho  (Expedicao)  - SEM M2                ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe e ³ BIA041(void)                                               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Alteracao ³                              Data                          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_peso := 0
	wnrel     := ""
	tamanho   := "P"
	titulo    := "ROMANEIO DE DESPACHO  (EXPEDICAO)"
	cDesc1    := "Emiss„o do Romaneio de Despacho para a Expedic„o, Almoxarifado"
	cDesc2    := "atraves de intervalo de N.Fiscais informado na op‡„o Parƒmetros."
	cDesc3    := ""
	CbCont    := 0
	cabec1    := ""
	cabec2    := ""
	cString   := "SZ9"
	lContinua := .T.
	lFirst    := .T.
	cPedAnt   := "   "
	cPerg     := " "
	aReturn   := { "Zebrado", 1,"Administracao", 2, 2, 1, "",0 }
	nomeprog  := "BIA041"
	nLastKey  := 0
	nBegin    := 0
	aLinha    := { }
	li        := 80
	//limite    := 132 
	limite    := 80
	lRodape   := .F.
	nTotQtd   := nTotVal:=0
	wnrel     := "BIA041"
	nTot2UM   := 0
	Pergunte("BIA041",.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.)

	If  nLastKey == 27
		Set Filter to
		Return
	Endif
	SetDefault(aReturn,cString)
	If  nLastKey == 27
		Set Filter to
		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                                     ³
	//³ mv_par01              Do Romaneio                                        ³
	//³ mv_par02              Ate o Romaneio                                     ³
	//³ mv_par03              Mensagem 1                                         ³
	//³ mv_par04              Mensagem 2                                         ³
	//³ mv_par05              Mensagem 3                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wMens1 := mv_par03
	wMens2 := mv_par04
	wMens3 := mv_par05
	For x:=1 to 1
		nTotQtd := 0
		nTot2UM := 0
		_Peso   := 0
		RptStatus({|| C790Imp()},Titulo)// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>     RptStatus({|| Execute(C790Imp)},Titulo)
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a Integridade dos dados                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SZ9")
	Set Filter To
	dbSetOrder(1)
	Set Device To Screen
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se em disco, desvia para Spool                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		dbCommitAll()
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>     Function C790Imp
Static Function C790Imp()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	tamanho   := "P"
	cDesc1    := "Emiss„o do Romaneio de Despacho para a Expedic„o, Almoxarifado"
	cDesc2    := ""
	cDesc3    := ""
	lContinua := .T.
	lFirst    := .T.
	cPedAnt   := "   "

	@ nLin, 01  PSAY Chr(27)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cbtxt    := SPACE(10)
	cbcont   := 0
	li       := 80
	m_pag    := 1
	nTipo    := IIF(aReturn[4]==1,15,15)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao dos cabecalhos                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	titulo := "ROMANEIO DE DESPACHO"
	cabec1 := " Codigo  Desc. do Material                     Ton. Tam.   Qtd 1a.UM  1UM      Emissao    Almx Localiz.  Pallet/CX      Pedido/It"
	cabec2 := ""

	DbSelectArea("SX6")
	If DbSeek(xFilial("SX6")+"MV_IMPSX1 ",.F.)
		If RecLock("SX6",.F.)
			SX6->X6_CONTEUD := "N"
		Endif
	Endif

	dbSelectArea("SZ9")
	dbSetOrder(1)
	dbSeek( xFilial("SZ9")+mv_par01,.T. )

	wRomaneio := SZ9->Z9_NUMERO
	wPesoBr   := SZ9->Z9_PESOBR
	SetRegua(RecCount())		// Total de Elementos da regua

	While !Eof()                       .And. ;
	lContinua                       .And. ;
	SZ9->Z9_NUMERO <= mv_par02      .And. ;
	xFilial()      == SZ9->Z9_FILIAL

		IncRegua()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿   // Se nao esta dentro das datas limite ele salta.
		//³ Verifica se ha interrupcao                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		#IFNDEF WINDOWS
		If  LastKey() == 286    //ALT_A
			lEnd := .t.
		End
		#ENDIF

		IF  lEnd
			@PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		Endif

		If wRomaneio <> SZ9->Z9_NUMERO
			li := li + 1
			@ li,000 PSAY Replicate("-",limite)
			li := li + 1
			@ li,000 PSAY " T O T A I S "
			@ li,056 PSAY nTotQtd   Picture PESQPICTQT("Z9_QTDLIB",10)
			li := li + 1
			@ li,000 PSAY Replicate("-",limite)

			li := li + 1
			@ li,025 PSAY " PESO BRUTO "
			@ li,040 PSAY _peso  Picture PESQPICTQT("Z9_PESOBR",13)
			@ li,054 PSAY "KG"
			_peso := 0

			li := li + 1
			@ li,000 PSAY Replicate("-",limite)


			li := li + 5
			IF  li+8 > 55
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				lFirst := .t.
			Endif
			@li,10 PSAY "____________________                                        ______________________"
			li := li + 1
			@li,10 PSAY "   OP.EMPILHADEIRA                                             ENC.EXPEDICAO"

			li ++ ; li ++; li ++

			@li,10 PSAY "      A CARGA FOI CONFERIDA ENCONTRANDO-SE EM PERFEITO ESTADO, FICANDO SOB"
			li ++
			@li,10 PSAY "      MINHA RESPONSABILIDADE AMARRAR E LONAR A MESMA PARA O TRANSPORTE"

			li := li + 3
			@li,10 PSAY "                          ________________________________                        "
			li ++
			@li,10 PSAY "                           ASSINATURA DO TRANSPORTADOR                    "


			li := 80
			nTot2um  := 0
			wTot2um  := 0
			wPesoBr  := SZ9->Z9_PESOBR
			lFirst   := .T.
		EndIf

		IF  li > 55 .or. lFirst
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			wRomaneio := SZ9->Z9_NUMERO
			lRodape   := .T.
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ler SC9                                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//dbSelectArea("SC9")
		//dbSetOrder(1)
		//If  dbSeek(xFilial("SC9")+SZ9->Z9_PEDIDO+SZ9->Z9_ITEM)
		//    While ! Eof()                       .And. ;
		//       xFilial("SC9") == SZ9->Z9_FILIAL .And. ;
		//       SC9->C9_PEDIDO == SZ9->Z9_PEDIDO .And. ;
		//       SC9->C9_ITEM   == SZ9->Z9_ITEM
		IF SZ9->Z9_NUMSEQ == Space(6)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acessa o Pedido                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SC5")
			dbSetOrder(1)
			dbSeek(xFilial("SC5")+SZ9->Z9_PEDIDO)

			dbSelectArea("SA4")
			dbSetOrder(1)
			dbSeek(xFilial("SA4")+SC5->C5_TRANSP)
			cNreduz := SA4->A4_NREDUZ

			dbSelectArea("SC6")
			dbSetOrder(1)
			dbSeek(xFilial("SC6")+SZ9->Z9_PEDIDO+SZ9->Z9_ITEM+SZ9->Z9_PRODUTO)

			//Grava o Nome do Cliente ou Fornecedor
			If SC5->C5_TIPO == "B"
				dbSelectArea("SA2")
				dbSetOrder(1)
				dbSeek(xFilial("SA2")+SC6->C6_CLI)
				cNome   := SA2->A2_NOME
			Else
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1")+SC6->C6_CLI)
				cNome   := SA1->A1_NOME
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do Cabecalho do Pedido                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF  li > 55
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				lFirst := .t.
			Endif

			If  lFirst
				lFirst  := .F.
				nTotQtd := 0
				nTotVal := 0

				@ li,000 PSAY "ROMANEIO : "+SZ9->Z9_NUMERO
				@ li,030 PSAY "EMISSAO : "+DTOC(SZ9->Z9_EMISSAO)
				li := li +1
				@ li,000 PSAY "CLIENTE : "+SC6->C6_CLI+"/"+SC6->C6_LOJA+"-"+cNOME+" MUNICIPIO : "+SA1->A1_MUN+" UF : "+SA1->A1_EST
				li := li +1
				@ li,000 PSAY "TRANSPORTADORA : "+SC5->C5_TRANSP+"-"+CNREDUZ+"  "+"VIA : "+SA4->A4_VIA+" PLACA : "+TRANS(SZ9->Z9_PLACA,'@R !!!-9999')+"    MOTORISTA : "+SZ9->Z9_MOTOR
				li := li + 1
				@ li,000 PSAY "OBSERVACAO : "+SA1->A1_YOBSROM
				li := li +1
				@ li,000 PSAY Replicate("-",limite)
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime detalhes do Romaneio                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			li := li + 1
			ImpItem()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Proximo registro SC9                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//dbSelectArea("SC9")
			//dbSetOrder(1)
			//dbSkip()
			//EndDo
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do Cabecalho do Pedido                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF  li > 55
				cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				lFirst := .t.
			Endif
			If  lFirst
				lFirst  := .F.
				nTotQtd := 0
				nTotVal := 0

				@ li,000 PSAY "ROMANEIO : "+SZ9->Z9_NUMERO
				@ li,030 PSAY "EMISSAO : "+DTOC(SZ9->Z9_EMISSAO)
				li := li +1
				@ li,000 PSAY "CLIENTE : "+SC9->C9_CLIENTE+"/"+SC9->C9_LOJA+"-"+cNOME+" MUNICIPIO : "+SA1->A1_MUN+" UF : "+SA1->A1_EST
				li := li +1
				@ li,000 PSAY "TRANSPORTADORA : "+SC5->C5_TRANSP+"-"+CNREDUZ+"  "+"VIA : "+SA4->A4_VIA+" PLACA : "+TRANS(SZ9->Z9_PLACA,'@R !!!-9999')+"    MOTORISTA : "+SZ9->Z9_MOTOR
				li := li + 1
				@ li,000 PSAY "OBSERVACAO : "+SA1->A1_YOBSROM
				li := li +1
				@ li,000 PSAY Replicate("-",limite)
			Endif
			li := li + 1
			RotMov()
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Proximo registro SZ9                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SZ9")
		dbSetOrder(1)
		dbSkip()
	EndDo

	li := li + 1

	IF  li+13 > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		lFirst := .t.
	Endif

	If  lFirst
		lFirst  := .F.
		nTotQtd := 0
		nTotVal := 0

		@ li,000 PSAY "ROMANEIO : "+SZ9->Z9_NUMERO
		@ li,030 PSAY "EMISSAO : "+DTOC(SZ9->Z9_EMISSAO)
		li := li +1
		@ li,000 PSAY "CLIENTE : "+SC6->C6_CLI+"/"+SC6->C6_LOJA+"-"+SA1->A1_NOME+" MUNICIPIO : "+SA1->A1_MUN+" UF : "+SA1->A1_EST
		li := li +1
		@ li,000 PSAY "TRANSPORTADORA : "+SC5->C5_TRANSP+"-"+SA4->A4_NREDUZ+"  "+"VIA : "+SA4->A4_VIA+" PLACA : "+TRANS(SZ9->Z9_PLACA,'@R !!!-9999')+"    MOTORISTA : "+SZ9->Z9_MOTOR
		li := li + 1          
		@ li,000 PSAY "OBSERVACAO : "+SA1->A1_YOBSROM
		li := li +1
		@ li,000 PSAY Replicate("-",limite)
	Endif

	@ li,000 PSAY Replicate("-",limite)
	li := li + 1
	@ li,000 PSAY " T O T A I S "
	@ li,055 PSAY nTotQtd   Picture PESQPICTQT("Z9_QTDLIB",10)
	li := li + 1
	@ li,000 PSAY Replicate("-",limite)

	li := li + 1
	@ li,020 PSAY " PESO BRUTO "
	@ li,041 PSAY _peso  Picture PESQPICTQT("Z9_PESOBR",13)
	@ li,055 PSAY "KG"

	li := li + 1
	@ li,000 PSAY Replicate("-",limite)

	li := li + 2
	If ! Empty(wMens1) .Or. ! Empty(wMens2) .Or. ! Empty(wMens3)
		@ li,00 psay "Mensagem: "
		@ li,10 psay wMens1
		li := li + 1
		@ li,10 psay wMens2
		li := li + 1
		@ li,10 psay wMens3
	EndIf

	li := li + 5

	IF  li+5 > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		lFirst := .t.
	Endif

	@li,10 PSAY "____________________                                        ______________________"
	li := li + 1
	@li,10 PSAY "   OP.EMPILHADEIRA                                             ENC.EXPEDICAO"

	li := li + 1
	@li,10 PSAY " A CARGA FOI CONFERIDA ENCONTRANDO-SE EM PERFEITO ESTADO, FICANDO SOB "
	li := li + 1
	@li,10 PSAY " MINHA RESPONSABILIDADE AMARRAR E LONAR A MESMA PARA O TRANSPORTE "

	li := li + 3
	@li,10 PSAY "                          ________________________________                        "
	li ++
	@li,10 PSAY "                           ASSINATURA DO TRANSPORTADOR                    "

	IF  lRodape
		roda(cbcont,cbtxt,"M")
	Endif

	DbSelectArea("SX6")
	MsUnLock()
	If DbSeek(xFilial("SX6")+"MV_IMPSX1 ",.F.)
		RecLock("SX6",.F.)
		SX6->X6_CONTEUD := "S"
		MsUnLock()
	Endif
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpItem  ³ Autor ³ Gilson do Nascimento  ³ Data ³ 05.10.93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Impressao de Itens do Romaneio  de Despacho                ³±±
±±³          ³ Ordem de Impressao : LOCALIZACAO NO ALMOXARIFADO           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpItem(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BIA041                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function ImpItem
Static Function ImpItem()

	dbSelectArea("SB1")
	dbSeek(xFilial()+SC6->C6_PRODUTO)

	wTotProd := 0
	wTot2UM  := 0

	If SB1->B1_CONV > 0
		If  SB1->B1_TIPCONV == "D"
			wTot2UM  := wTot2UM  + (SZ9->Z9_QTDLIB/SB1->B1_CONV)
		ELSEIf SB1->B1_TIPCONV == "M"
			wTot2UM  := wTot2UM  + (SZ9->Z9_QTDLIB*SB1->B1_CONV)
		ENDIF
	ENDIF

	DO CASE 
		CASE Subs(SZ9->Z9_PRODUTO,8,1) == "1"
		xCod := "100"
		CASE Subs(SZ9->Z9_PRODUTO,8,1) == "2"
		xCod := "200"
		CASE Subs(SZ9->Z9_PRODUTO,8,1) == "3"
		xCod := "300"
		CASE Subs(SZ9->Z9_PRODUTO,8,1) == "4"
		xCod := "400"
		CASE Subs(SZ9->Z9_PRODUTO,8,1) == "5"
		xCod := Posicione("ZZ6",1,xFilial("ZZ6")+SB1->B1_YFORMAT,"ZZ6_DESC")
		OTHERWISE
		xCod := ""
	ENDCASE

	@li,001 PSAY Alltrim(xCod)

	@li,006 PSAY SUBS(SZ9->Z9_DESCRIC,1,38)

	IF Len(AllTrim(SZ9->Z9_LOTECTL)) <= 5
		@li,Pcol()+3 Psay Subs(SZ9->Z9_LOTECTL,1,2)  //Ton
		@li,Pcol()+3 Psay Subs(SZ9->Z9_LOTECTL,3,3)  //Tam
	ELSE                                                   
		@li,Pcol()+3 Psay SZ9->Z9_LOTECTL  //Ton
	ENDIF

	@li,Pcol()+1 PSAY SZ9->Z9_QTDLIB Picture PESQPICTQT("C9_QTDLIB",10)
	@li,Pcol()+3 PSAY SC6->C6_UM
	@li,Pcol()+10 PSAY SZ9->Z9_EMISSAO
	@li,Pcol()+3 PSAY SZ9->Z9_LOCAL
	@li,Pcol()+3 PSAY SUBS(SZ9->Z9_LOCALIZ,1,7)

	Pallets()

	@li,102 PSAY wPallets PICTURE "@E 9,999"
	If !Empty(wPalletsCx)
		@li,107 PSAY "/"
		@li,108 PSAY wPalletsCx PICTURE "@E 9,999"
	EndIf
	@li,120 PSAY SZ9->Z9_PEDIDO+"/"+SZ9->Z9_ITEM
	li := li + 1
	_peso := _peso + SZ9->Z9_PESOBR
	wTotProd := wTotProd + SZ9->Z9_QTDLIB
	nTotQtd  := nTotQtd + wTotProd
	nTot2UM  := nTot2UM + wTot2UM

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RotMov   ³ Autor ³ Gustav Koblinger Jr   ³ Data ³ 05.08.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Movimentacao                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RotMov                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BIA041                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function RotMov
Static Function RotMov()

	dbSelectArea("SD3")
	dbSetOrder(4)
	dbSeek(xFilial()+SZ9->Z9_NUMSEQ)

	dbSelectArea("SB1")
	dbSeek(xFilial()+SD3->D3_COD)

	wTotProd := 0
	wTot2UM  := 0

	If SB1->B1_CONV > 0
		If  SB1->B1_TIPCONV == "D"
			wTot2UM  := wTot2UM  + (SZ9->Z9_QTDLIB/SB1->B1_CONV)
		ELSEIf SB1->B1_TIPCONV == "M"
			wTot2UM  := wTot2UM  + (SZ9->Z9_QTDLIB*SB1->B1_CONV)
		ENDIF
	ENDIF

	//???????????????????LOTE
	If Subs(SD3->D3_COD,8,1) == "1"
		@li,001 PSAY "100"
	ElseIf Subs(SD3->D3_COD,8,1) == "2"
		@li,001 PSAY "200"
	ElseIf Subs(SD3->D3_COD,8,1) == "3"
		@li,001 PSAY "300"
	EndIf
	@li,006 PSAY SUBS(SZ9->Z9_DESCRIC,1,38)

	IF Len(AllTrim(SZ9->Z9_LOTECTL)) <= 5
		@li,Pcol()+4 Psay Subs(SZ9->Z9_LOTECTL,1,2) //Ton
		@li,Pcol()+3 Psay Subs(SZ9->Z9_LOTECTL,3,3) //Tam
	ELSE                                                  
		@li,Pcol()+4 Psay SZ9->Z9_LOTECTL //Ton
	ENDIF

	@li,Pcol()+1 PSAY SZ9->Z9_QTDLIB Picture PESQPICTQT("C9_QTDLIB",10)
	@li,Pcol()+3 PSAY SD3->D3_SEGUM
	@li,Pcol()+10 PSAY SZ9->Z9_EMISSAO
	@li,Pcol()+3 PSAY SD3->D3_LOCAL
	@li,Pcol()+3 PSAY SUBS(SD3->D3_LOCALIZ,1,7)

	//Calculo dos Pallets
	Pallets()
	@li,102 PSAY wPallets PICTURE "@E 9,999"
	If !Empty(wPalletsCx)
		@li,107 PSAY "/"
		@li,108 PSAY wPalletsCx PICTURE "@E 9,999"
	EndIf
	@li,120 PSAY SD3->D3_DOC
	li := li + 1
	wTotProd := wTotProd + SZ9->Z9_QTDLIB
	nTotQtd  := nTotQtd + wTotProd
	nTot2UM  := nTot2UM + wTot2UM

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Pallets  ³ Autor ³ Cesar Magnago         ³ Data ³ 09/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo dos Pallets do Romaneio de Carga                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Rotina Pallets                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ BIA041                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Pallets
Static Function Pallets()

	wsOk         := .T.
	wPallets     := 0
	wxPallets    := 0
	wPalletsCx   := 0
	wSomaPallets := 0
	//wsDivisor    := SB1->B1_YDIVPA  //Alterado em 18/02/03 - Colocar o divisor no cadastro do produto - Nilton
	wPallets     := wTot2UM


	/*aCODPRODUTO := (SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE)
	DbSelectArea("ZZ9")
	DbSetOrder(1)
	IF !DbSeek(xFilial("ZZ9")+ aCODPRODUTO + SD2->D2_LOTECTL )
	sPESEMB := ZZ9->ZZ9_PESEMB
	sPESO	:= ZZ9->ZZ9_PESO
	sDIVPA	:= ZZ9->ZZ9_DIVPA
	END IF*/

	aCODPRODUTO := (SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE)
	cSQLL := ""							
	cSQLL := "SELECT * FROM ZZ9010 "
	cSQLL += "WHERE	ZZ9_PRODUT = '" +aCODPRODUTO+ "' AND  "
	cSQLL += "		ZZ9_LOTE = '" +SC6->C6_LOTECTL+ "' AND "
	cSQLL += "		D_E_L_E_T_ = '' "
	IF chkfile("_ZZ9")
		dbSelectArea("_ZZ9")
		dbCloseArea()
	ENDIF
	TCQuery cSQLL Alias "_ZZ9" New							
	IF ! _ZZ9->(EOF())
		sPESEMB := _ZZ9->ZZ9_PESEMB
		sPESO	:= _ZZ9->ZZ9_PESO
		sDIVPA	:= _ZZ9->ZZ9_DIVPA
	END IF																					


	wsDivisor    := sDIVPA  //Alterado em 18/02/03 - Colocar o divisor no cadastro do produto - Nilton

	While wsOk

		wxPallets := wPallets - wsDivisor

		If wxPallets == 0
			wPallets      := 0
		EndIf

		If wxPallets >= wsDivisor
			wSomaPallets  := wSomaPallets + 1
			wPallets      := wxPallets
			wxPallets     := 0
			Loop
		Else
			wSomaPallets  := wSomaPallets + 1
			wPalletsCx    := wxPallets
			wPallets      := wSomaPallets
			wsOk          := .F.
		EndIf

	EndDo

Return