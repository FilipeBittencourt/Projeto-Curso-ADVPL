#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Mtr150()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetPrvt("CDESC1,CDESC2,CDESC3,TITULO,ARETURN,NOMEPROG")
	SetPrvt("NLASTKEY,CSTRING,CPERG,ADRIVER,WNREL,CABEC1")
	SetPrvt("CABEC2,CABEC3,TAMANHO,CBCONT,LIMITE,LI")
	SetPrvt("M_PAG,NPAG,CCONTATO,DEMISSAO,WNUM,WSEQ")
	SetPrvt("CENDERE,CCIDEST,CFAX,CTEL,CNUMERO,CFORNECE")
	SetPrvt("CLOJA,NITEM,CFILENT,LC8FILENT,NREGISTRO,CDESC")
	SetPrvt("CDESCRI,NLINREF,MV_PAR06,NBEGIN,")

	/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ MATR150  ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05/06/92 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Emissao das Cotacoes                                       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDesc1:="Emissao das cotacoes de compras"
	cDesc2:=""
	cDesc3:=" "
	titulo  :="Relacao de Cotacoes"
	aReturn := { "Zebrado", 1,"Administracao", 2, 2, 2, "",0 }
	nomeprog:="MATR150"
	nLastKey:= 0
	cString :="SC8"
	cPerg   :="MTR150"
	aDriver :=ReadDriver()
	wnrel   :="MATR150"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01              Do Numero                              ³
	//³ mv_par02              Ate o Numero                           ³
	//³ mv_par03              Do Fornecedor                          ³
	//³ mv_par04              Ate o Fornecedor                       ³
	//³ mv_par05              Ate a data de validade                 ³
	//³ mv_par06              Campo Descricao do Produto             ³
	//³ mv_par07              Endrre‡o Fiscal                        ³
	//³ mv_par08              Cidade - Estado                        ³
	//³ mv_par09              Fax                                    ³
	//³ mv_par10              Telefone                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte("MTR150",.F.)
	wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.)
	If nLastKey == 27
		Set Filter To
		Return
	Endif
	SetDefault(aReturn,cString)
	If nLastKey == 27
		Set Filter To
		Return
	Endif

	//If aReturn[4] == 1                              // Comprimido
	//   @ 000,000 PSAY &(aDriver[1])
	//ElseIf aReturn[4] == 2                          // Normal
	//   @ 000,000 PSAY &(aDriver[2])
	//EndIf

	RptStatus({|| R150Imp() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>         RptStatus({|| Execute(R150Imp) })

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ R150IMP  ³ Autor ³ Cristina M. Ogura     ³ Data ³ 10.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function R150Imp
Static Function R150Imp()
	cabec1 := ""
	cabec2 := ""
	cabec3 := ""
	tamanho:=" "
	cbCont := 0
	limite := 80
	SetPrc(0,0)
	li     := Prow()
	li     := 80
	m_pag  := 1
	nPag   := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
	//³ Faz manualmente porque nao chama a funcao Cabec()                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//@ 0,0 PSAY AvalImp(Limite)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa Numero da Cotacao                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC8")
	dbSetOrder(1)
	dbSeek(xFilial()+mv_par01,.T.)
	SetRegua(RecCount())
	While xFilial() = SC8->C8_FILIAL .And. SC8->C8_NUM >= mv_par01 .And. SC8->C8_NUM <= mv_par02 .And. ! Eof()
		//IncRegua()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Fornecedor                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF SC8->C8_FORNECE < mv_par03 .OR. SC8->C8_FORNECE > mv_par04
			dbSelectArea("SC8")
			dbSetOrder(1)
			dbSkip()
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Data de Validade ou se ja tem pedido feito          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF SC8->C8_VALIDA > mv_par05 .OR. !Empty(SC8->C8_NUMPED)
			dbSelectArea("SC8")
			dbSetOrder(1)
			dbSkip()
			Loop
		Endif
		cContato := SC8->C8_CONTATO
		dEmissao := SC8->C8_EMISSAO
		If aReturn[4] == 1                              // Comprimido
			aReturn := { "Zebrado", 1,"Administracao", 1, 2, 2, "",0 }
		ElseIf aReturn[4] == 2                          // Normal
			aReturn := { "Zebrado", 1,"Administracao", 2, 2, 2, "",0 }
		EndIf
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial()+SC8->C8_FORNECE+SC8->C8_LOJA)
		wnrel:=SC8->C8_FORNECE+"CO"
		wnrel:=SetPrint(cString,wnrel," ",@Titulo,cDesc1,cDesc2,cDesc3,.T.)
		If nLastKey == 27
			Set Filter To
			Return
		Endif
		SetDefault(aReturn,cString)
		If nLastKey == 27
			Set Filter To
			Return
		Endif

		//If aReturn[4] == 1                              // Comprimido
		//   @ 000,000 PSAY &(aDriver[1])
		//ElseIf aReturn[4] == 2                          // Normal
		//   @ 000,000 PSAY &(aDriver[2])
		//EndIf
		@ 0,0 PSAY AvalImp(Limite)

		IF li > 58
			SetPrc(0,0)
			@ 0 , 0 PSAY ""
			nPag := nPag + 1
			@ 1 , 0 PSAY "COTACAO N. " + SC8->C8_NUM
			@ 1 ,28 PSAY "Vencimento " + DTOC(SC8->C8_VALIDA)
			@ 1 ,66 PSAY "Pagina: " + STRZERO(nPag,4)
			@ 3 , 0 PSAY "PREZADOS SENHORES,"
			//@ 3 ,39 PSAY "|Por favor queira referenciar este numero" 
			@ 3 ,39 PSAY "|Por favor queira referenciar-se ao No.:"
			dbSelectArea("SA2")
			dbSetOrder(1)
			//dbSeek(xFilial()+SC8->C8_FORNECE+SC8->C8_LOJA)
			@ 4 , 0 PSAY SubStr(SA2->A2_NOME,1,39)
			//@ 4 ,39 PSAY "|para quaisquer troca de informacoes re-"
			@ 4 ,39 PSAY "|"+SC8->C8_NUM+" para quaisquer troca de informa-"
			@ 5 , 0 PSAY Substr(SA2->A2_END,1,36)
			//@ 5 ,39 PSAY "|ferentes a esta cotacao."
			@ 5 ,39 PSAY "|coes referentes a esta cotacao."

			@ 6 , 0 PSAY SA2->A2_BAIRRO
			@ 6 ,26 PSAY "("+SA2->A2_COD+" - "+SA2->A2_LOJA+")"+"|           Atenciosamente, "+cUserName
			@ 7 , 0 PSAY "Fone: "+Substr(SA2->A2_TEL,1,14)
			@ 7 ,20 PSAY "CGC: "+SA2->A2_CGC+"|"
			@ 8,  0 PSAY "Fax : "+Substr(SA2->A2_FAX,1,14)
			@ 8, 20 PSAY "IE : "+Substr(SA2->A2_INSCR,1,14)
			dbSelectArea("SM0")
			dbSetOrder(1)   // forca o indice na ordem certa
			dbSeek(SUBS(cNumEmp,1,2))
			@ 8, 39 PSAY "|"+ SM0->M0_NOMECOM
			cEndere := IIf(Empty(MV_PAR07), Iif(Empty(SM0->M0_ENDENT),SM0->M0_ENDCOB,SM0->M0_ENDENT), MV_PAR07)
			cCidEst := IIf(Empty(MV_PAR08), Iif(Empty(SM0->M0_CIDENT+SM0->M0_ESTENT), SM0->M0_CIDCOB + " " + SM0->M0_ESTCOB,  SM0->M0_CIDENT + " " + SM0->M0_ESTENT),MV_PAR08)
			cFax    := IIf(Empty(MV_PAR09), SM0->M0_FAX, MV_PAR09)
			cTel    := IIf(Empty(MV_PAR11), SM0->M0_TEL, MV_PAR11)
			@9 , 39 PSAY "|"+ cEndere
			@10,  0 PSAY "Solicitamos de V Sas. cotacao de precos"
			@10, 39 PSAY "|"+cCidEst
			@11,  0 PSAY "para os produtos discriminados conforme"
			@11, 39 PSAY "|Fax: " + Substr(cFax,1,14)
			@11 ,61 PSAY "CGC: "+SM0->M0_CGC
			@12 , 0 PSAY "os padroes abaixo estabelecidos:"
			@12, 39 PSAY "|Tel: "+Substr(cTel,1,14)
			@12, 61 PSAY "IE : "+SM0->M0_INSC
			@13,  0 PSAY Replicate("-",limite)
			@14,  0 PSAY "ITM N/Codigo Descricao da Mercadoria        Valor Total     Quant. UN Prev Entrg"
			@15,  0 PSAY Replicate("-", 3)
			@15,  4 PSAY Replicate("-", 8)
			@15, 13 PSAY Replicate("-",30)
			@15, 44 PSAY Replicate("-",11)
			@15, 56 PSAY Replicate("-",10)
			@15, 67 PSAY Replicate("-", 2)
			@15, 70 PSAY Replicate("-",10)
			li:=14
		Endif
		dbSelectArea("SC8")
		dbSetOrder(1)
		cNumero := SC8->C8_NUM
		cFornece:= SC8->C8_FORNECE
		cLoja   := SC8->C8_LOJA
		nItem := 0
		While ! Eof()                      .And. ;
		SC8->C8_NUM      == cNumero  .And. ;
		SC8->C8_FORNECE  == cFornece .And. ;
		SC8->C8_LOJA     == cLoja
			IF li > 58
				li := li + 1
				li := li + 1
				nPag := nPag + 1
				@ li,00 PSAY Replicate("-",limite-Len(" Continua ..."))+" Continua ..."
				@ 00,00 PSAY "Continuacao ... "+Replicate("-",limite-Len("Continuacao ... "))
				li := 1
				@li , 0 PSAY "COTACAO N. " + SC8->C8_NUM
				@li ,28 PSAY "Vencimento " + DTOC(SC8->C8_VALIDA)
				@li ,66 PSAY "Pagina: " + STRZERO(nPag,4)
				li := 1
			Endif
			IncRegua()               
			li    := li +1
			nItem := nItem + 1
			//@li,  0 PSAY StrZero(nItem,2)
			//@li,  4 PSAY Substr(SC8->C8_PRODUTO,1,8)
			ImpDescr()
			dbSelectArea("SC8")
			dbSetOrder(1)
			cFilEnt := SC8->C8_FILENT
			dbSkip()
		EndDo
		dbSkip(-1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acessar o Endereco para Entrega do Arquivo de Empresa SM0.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lC8FilEnt := .F.
		If Eof() .Or. cFilEnt != SC8->C8_FILENT
			dbSkip(-1)        // Para ter Certeza que nao e Eof() ou trocou a filial
			lC8FilEnt := .T.  // de Entrega 
		End
		dbSelectArea("SM0")
		dbSetOrder(1)   // forca o indice na ordem certa
		nRegistro := Recno()
		dbSeek(SUBS(cNumEmp,1,2)+SC8->C8_FILENT)
		If lC8FilEnt
			dbSkip()
		EndIf
		If li > 50
			li := li + 1
			li := li + 1
			nPag := nPag + 1
			@ li,00 PSAY Replicate("-",limite-Len(" Continua ..."))+" Continua ..."
			@ 00,00 PSAY "Continuacao ... "+Replicate("-",limite-Len("Continuacao ... "))
			li := 1
			@li , 0 PSAY "COTACAO N. " + SC8->C8_NUM
			@li ,28 PSAY " Vencimento " + DTOC(SC8->C8_VALIDA)
			@li ,66 PSAY "Pagina: " + STRZERO(nPag,4)
			li := 1
		Endif
		li:=50
		@li,  0 PSAY "Local de Entrega:"
		@li, 26 PSAY "|Sub Total......:"
		@li, 58 PSAY "|Condicao de Pagamento"
		li := li + 1
		//@li,  0 PSAY IIf( Empty(SM0->M0_ENDENT), " O mesmo ", SM0->M0_ENDENT )
		@li,  0 PSAY  " O mesmo "
		@li, 26 PSAY "|Descontos......:"
		@li, 58 PSAY "|"
		Go nRegistro
		dbSelectArea("SC8")
		dbSetOrder(1)
		li := li + 1
		@li,  0 PSAY "Local de Pagamento:"
		@li, 26 PSAY "|Total do IPI...:"
		@li, 58 PSAY "|"
		li := li + 1
		//@li,  0 PSAY Iif(Empty(SM0->M0_ENDCOB),Iif(Empty(SM0->M0_ENDENT)," O mesmo ",SM0->M0_ENDENT),SM0->M0_ENDCOB)
		@li,  0 PSAY  " O mesmo "
		@li, 26 PSAY "|Frete..........:"
		@li, 58 PSAY "|Condicao de Reajuste"
		li := li + 1
		@li,  0 PSAY "Contato no Fornecedor"
		@li, 26 PSAY "|"+Replicate("-",31)
		@li, 58 PSAY "|"
		li := li + 1
		@li,  1 PSAY cContato
		@li, 26 PSAY "|TOTAL DO PEDIDO:"
		@li, 58 PSAY "|"
		li := li + 1
		@li,  0 PSAY Replicate("-",limite)
		li := li + 1
		//@li,  0 PSAY "Alcada 1"
		//@li, 28 PSAY "| Alcada 2"
		//@li,111 PSAY "Emitido em :" 
		//@li,124 PSAY dEmissao
		//@li,  09 PSAY "FAVOR INFORMAR PRECO TOTAL COM OS IMPOSTOS E FRETE JA IMBUTIDOS"
		//li := li + 1
		//@li, 0  PSAY Replicate("-",limite)
		Eject
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se em disco, desvia para Spool                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Set device to Screen
		If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
			Set Printer To
			Commit
			OurSpool(wnrel)
		Endif
		MS_FLUSH()

		dbSelectArea("SC8")
		dbSetOrder(1)
		DBSKIP()
		li   := 80
		nPag := 0
	EndDo
	dbSelectArea("SC8")
	dbSetOrder(1)
	Set Filter To
	dbSetOrder(1)

	dbSelectArea("SA5")
	dbSetOrder(1)

//Set device to Screen
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
//   Set Printer To
//   Commit
//   OurSpool(wnrel)
//Endif
//MS_FLUSH()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ImpValores³ Autor ³ Jose Lucas            ³ Data ³ 19.07.93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprimir Valores da Cotacao.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpValores(Void)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function ImpValores
Static Function ImpValores()
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial()+SC8->C8_PRODUTO)
	dbSelectArea("SA5")
	dbSetOrder(2)
	If dbSeek(xFilial()+SC8->C8_PRODUTO+SC8->C8_FORNECE+SC8->C8_LOJA)
		@li,  3 PSAY SA5->A5_CODPRF
	Endif
	dbSelectArea("SC8")
	dbSetOrder(1)
	li := li + 1
	@li,  0 PSAY StrZero(nItem,2)
	@li,  4 PSAY Substr(SC8->C8_PRODUTO,1,8)
	@li, 13 PSAY  SubStr(cDescri,1,30)
	@li, 56 PSAY  SC8->C8_QUANT Picture "@E 99,999.999"
	@li, 67 PSAY  SB1->B1_UM
	@li, 71 PSAY  SC8->C8_DATPRF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImpDescr ³ Autor ³ Jose Lucas            ³ Data ³ 19.07.93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprimir descricao do Produto.	  								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ImpProd(Void)  			                      				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatR150                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function ImpDescr
Static Function ImpDescr()

	Local nBegin

	cDesc  := " "
	cDescri:= " "
	nLinRef:= 0
	If Empty(mv_par06) 
		mv_par06 := "B1_DESC"
	EndIf 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao da descricao cientifica do Produto.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AllTrim(mv_par06) == "B5_CEME"
		dbSelectArea("SB5")
		dbSetOrder(1)
		If dbSeek(xFilial()+SC8->C8_PRODUTO)
			cDescri := B5_CEME
		EndIf
	ElseIf AllTrim(mv_par06) == "A5_NOMPROD"
		dbSelectArea("SA5")
		dbSetOrder(1)
		If dbSeek(xFilial()+SC8->C8_FORNECE+SC8->C8_LOJA+SC8->C8_PRODUTO)
			cDescri := A5_NOMPROD
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao da descricao do produto do arquivo de Cotacoes.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AllTrim(mv_par06) == "C1_DESCRI"
		dbSelectArea("SC1")
		dbSetOrder(1)
		If dbSeek(xFilial()+SC8->C8_NUMSC+SC8->C8_ITEMSC)
			cDescri := C1_DESCRI
		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao da descricao do Produto SB1.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cDescri)
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial()+SC8->C8_PRODUTO)
		cDescri := SB1->B1_DESC
	EndIf
	nBegin:=0
	ImpValores()
	For nBegin := 31 To Len(Trim(cDescri)) Step 30
		li := li + 1
		nLinRef := nLinRef + 1
		cDesc := Substr(cDescri,nBegin,30)
		@ li,013 PSAY cDesc
	Next nBegin
Return
