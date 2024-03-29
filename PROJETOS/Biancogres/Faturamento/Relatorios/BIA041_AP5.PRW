#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#include "Protheus.Ch" //RANISSES
#include "topconn.ch"

#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function Bia041()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
	//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
	//� identificando as variaveis publicas do sistema utilizadas no codigo �
	//� Incluido pelo assistente de conversao do AP5 IDE                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
	複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
	굇쿑un뇚o    � BIA041   � Autor � Gustav Koblinger Jr   � Data � 05.08.99 낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
	굇쿏escri뇚o � Romaneio de Despacho  (Expedicao)                          낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
	굇쿞intaxe e � BIA041(void)                                               낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
	굇� Uso      � Generico                                                   낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
	굇쿌lteracao �                              Data                          낢�
	굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
	/*/

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Define Variaveis                                                         �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	_peso := 0
	wnrel     := ""
	tamanho   := "M"
	titulo    := "ROMANEIO DE DESPACHO  (EXPEDICAO)"
	cDesc1    := "Emiss꼘 do Romaneio de Despacho para a Expedic꼘, Almoxarifado"
	cDesc2    := "atraves de intervalo de N.Fiscais informado na op뇙o Par긩etros."
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
	limite    := 132
	lRodape   := .F.
	nTotQtd   := nTotVal:=0
	wnrel     := "BIA041"
	nTot2UM   := 0
	Pergunte("BIA041",.T.)

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Verifica as perguntas selecionadas                                       �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

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
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Variaveis utilizadas para parametros                                     �
	//� mv_par01              Do Romaneio                                        �
	//� mv_par02              Ate o Romaneio                                     �
	//� mv_par03              Situacao do Pedido                                 �//RANISSES
	//� mv_par04              Mensagem 1                                         �
	//� mv_par05              Mensagem 2                                         �
	//� mv_par06              Mensagem 3                                         �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	wMens1 := mv_par04 //RANISSES
	wMens2 := mv_par05
	wMens3 := mv_par06
	For x:=1 to 1
		nTotQtd := 0
		nTot2UM := 0
		_Peso   := 0
		RptStatus({|| C790Imp()},Titulo)
	Next

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Restaura a Integridade dos dados                                         �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	dbSelectArea("SZ9")
	Set Filter To 
	dbSetOrder(1)
	Set Device To Screen

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Se em disco, desvia para Spool                                           �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If  aReturn[5] == 1    // Se Saida para disco, ativa SPOOL
		Set Printer TO
		dbCommitAll()
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>     Function C790Imp
Static Function C790Imp()
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Define Variaveis                                                         �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	tamanho   := "M"
	cDesc1    := "Emiss꼘 do Romaneio de Despacho para a Expedic꼘, Almoxarifado"
	cDesc2    := ""
	cDesc3    := ""
	lContinua := .T.
	lFirst    := .T.
	cPedAnt   := "   "
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Variaveis utilizadas para Impressao do Cabecalho e Rodape                �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cbtxt    := SPACE(10)
	cbcont   := 0
	li       := 80
	m_pag    := 1
	nTipo    := IIF(aReturn[4]==1,15,18)
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Definicao dos cabecalhos                                                 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	titulo := "ROMANEIO DE DESPACHO"
	cabec1 := " Codigo  Desc. do Material                       Ton. Tam.   Qtd 2a.UM 2UM     Localiz.    Pallet/CX    Pedido/It      Qtd 1a.UM 1UM"
	cabec2 := ""

	/*DbSelectArea("SX6")
	If DbSeek(xFilial("SX6")+"MV_IMPSX1 ",.F.)
	If RecLock("SX6",.F.)
	SX6->X6_CONTEUD := "N"
	Endif
	Endif*/
	PutMV("MV_IMPSX1","N")


	dbSelectArea("SZ9")
	//dbSetOrder(1) ECOSIS
	dbSetOrder(8) 
	If !dbSeek( xFilial("SZ9")+MV_PAR01,.F.)
		MsgAlert("Romaneio n�o encontrado. Favor verifique o N�mero digitado!")
		Return
	EndIf

	wRomaneio := SZ9->Z9_NUMERO
	wPedido 	:= SZ9->Z9_PEDIDO
	wPesoBr   := SZ9->Z9_PESOBR

	SetRegua(RecCount())
	SetPrc(0,0)

	//SZ9->Z9_NUMERO <= MV_PAR02			.And. ;

	While !Eof()											.And. ;
	lContinua                       .And. ;
	SZ9->Z9_NUMERO == MV_PAR01			.And. ;
	xFilial()      == SZ9->Z9_FILIAL

		IncRegua()

		//wPedido 	:= SZ9->Z9_PEDIDO

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  
		//� Verifica se ha interrupcao                                            �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		#IFNDEF WINDOWS
		If  LastKey() == 286
			lEnd := .t.
		End
		#ENDIF

		IF  lEnd
			@PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		Endif

		//wPedido 	:= SZ9->Z9_PEDIDO

		//If wRomaneio <> SZ9->Z9_NUMERO
		If wPedido <> SZ9->Z9_PEDIDO //ECOSIS
			li := li + 1
			@ li,000 PSAY Replicate("-",limite)
			li := li + 1
			@ li,000 PSAY " T O T A I S "
			@ li,060 PSAY nTot2UM   Picture PESQPICTQT("Z9_QTDLIB",10)
			@ li,117 PSAY nTotQtd   Picture PESQPICTQT("Z9_QTDLIB",10)
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
			lFirst   := .T.
		EndIf

		IF  li > 55 .or. lFirst
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			wRomaneio := SZ9->Z9_NUMERO
			lRodape   := .T.
		Endif

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Ler SZ9                                                               �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		IF SZ9->Z9_NUMSEQ == Space(6)
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Acessa o Pedido                                                �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Impressao do Cabecalho do Pedido                           �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Imprime detalhes do Romaneio                                   �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			li := li + 1
			ImpItem()
		Else
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Impressao do Cabecalho do Pedido                           �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Proximo registro SZ9                                                  �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

		wPedido 	:= SZ9->Z9_PEDIDO

		dbSelectArea("SZ9")
		dbSetOrder(8) //ECOSIS
		//dbSetOrder(1) 
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
	@ li,060 PSAY nTot2UM   Picture PESQPICTQT("Z9_QTDLIB",10)
	@ li,117 PSAY nTotQtd   Picture PESQPICTQT("Z9_QTDLIB",10)
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

	IF  lRodape
		roda(cbcont,cbtxt,"M")
	Endif

	/*DbSelectArea("SX6")
	MsUnLock()
	If DbSeek(xFilial("SX6")+"MV_IMPSX1 ",.F.)
	RecLock("SX6",.F.)
	SX6->X6_CONTEUD := "S"
	MsUnLock()
	Endif */
	PutMV("MV_IMPSX1","S")


Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � ImpItem  � Autor � Gilson do Nascimento  � Data � 05.10.93 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Impressao de Itens do Romaneio  de Despacho                낢�
굇�          � Ordem de Impressao : LOCALIZACAO NO ALMOXARIFADO           낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � ImpItem(void)                                              낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � BIA041                                                     낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function ImpItem
Static Function ImpItem()

	dbSelectArea("SB1")
	dbSeek(xFilial()+SC6->C6_PRODUTO)
	aCODPRODUTO := (SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE)

	cSQLL := ""
	cSQLL := "SELECT * FROM ZZ9010 "
	cSQLL += "WHERE	ZZ9_PRODUT = '" +aCODPRODUTO+ "' AND  "
	cSQLL += "		ZZ9_LOTE = '" +SZ9->Z9_LOTECTL+ "' AND "
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
	ELSE
		sPESEMB := SB1->B1_YPESEMB
		sPESO	:= SB1->B1_PESO
		sDIVPA	:= SB1->B1_YDIVPA
	END IF

	CSQL := "SELECT C9_NFISCAL, C9_SERIENF FROM "+RetSqlName("SC9")+" "
	CSQL += "WHERE 	C9_PEDIDO	= '"+SZ9->Z9_PEDIDO+"' 	AND "
	CSQL += "		C9_AGREG	= '"+SZ9->Z9_AGREG+"'  	AND "
	CSQL += "		C9_SEQUEN   = '"+SZ9->Z9_SEQUEN+"'  AND "
	CSQL += "		C9_PRODUTO	= '"+SZ9->Z9_PRODUTO+"' AND "
	CSQL += "		C9_ITEM     = '"+SZ9->Z9_ITEM+"' 	AND " //RANISSES 
	CSQL += "		D_E_L_E_T_ 	= '' "

	If chkfile("_AUX")
		dbSelectArea("_AUX")
		dbCloseArea()
	EndIf
	TCQUERY CSQL ALIAS 	"_AUX" NEW

	If _AUX->(EOF())
		Return
	EndIf

	If MV_PAR03 == 1 //Romaneios Pendentes
		IF Alltrim(_AUX->C9_NFISCAL) <> ''
			Return
		END IF
	ElseIf MV_PAR03 == 2 //Faturados
		IF Alltrim(_AUX->C9_NFISCAL) == ''
			Return
		END IF
	EndIf

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

	@li,001 	 PSAY Alltrim(xCod)
	@li,Pcol()+3 PSAY SUBS(SZ9->Z9_DESCRIC,1,38) //Descricao

	IF Len(AllTrim(SZ9->Z9_LOTECTL)) <= 5
		@li,Pcol()+6 Psay Subs(SZ9->Z9_LOTECTL,1,2)  //Ton
		@li,Pcol()+3 Psay Subs(SZ9->Z9_LOTECTL,3,3)  //Tam  
	ELSE                                                   
		@li,Pcol()+6 Psay SZ9->Z9_LOTECTL  //Ton
	ENDIF

	@li,Pcol()+1 PSAY wTot2UM Picture PESQPICTQT("Z9_QTDLIB",10)
	@li,Pcol()+3 PSAY SC6->C6_SEGUM
	@li,Pcol()+08 PSAY SUBS(SZ9->Z9_LOCALIZ,1,7)
	Pallets()
	@li,Pcol()+1 PSAY wPallets PICTURE "@E 9,999"
	If !Empty(wPalletsCx)
		@li,Pcol()+1 PSAY "/"
		@li,Pcol()+0 PSAY wPalletsCx PICTURE "@E 9,999"
	EndIf
	@li,104 PSAY SZ9->Z9_PEDIDO+"/"+SZ9->Z9_ITEM //Pcol()+5
	@li,Pcol()+4 PSAY SZ9->Z9_QTDLIB Picture PESQPICTQT("C9_QTDLIB",10)
	@li,Pcol()+3 PSAY SC6->C6_UM
	li := li + 1

	IF alltrim(_AUX->C9_NFISCAL) = ""
		@li,60 Psay ("---------------")
		li := li + 1
		@li,000 PSAY Replicate("-",limite) //REPLICATE("-",120)
	ELSE
		@li,60 Psay ("---------------")
		@li,80 Psay "NOTA FISCAL: "  + _AUX->C9_NFISCAL + "  - DATA EMISSAO: " + DTOC(  POSICIONE("SF2",1,xFilial("SF2")+_AUX->C9_NFISCAL+_AUX->C9_SERIENF,"F2_EMISSAO")   )
		li := li + 1
		@li,000 PSAY Replicate("-",limite) //REPLICATE("-",120)
	END IF
	li := li + 1

	wPesoEmb	:= ( SZ9->Z9_QTDLIB2 * sPESEMB ) //PESO DA EMBALAGEM
	_Peso 		:= _Peso + wPesoEmb + (SZ9->Z9_QTDLIB * sPESO) //PESO EMBALAGEM + PESO LIQ. PRODUTO


	wTotProd := wTotProd + SZ9->Z9_QTDLIB
	nTotQtd  := nTotQtd + wTotProd
	nTot2UM  := nTot2UM + wTot2UM
Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � RotMov   � Autor � Gustav Koblinger Jr   � Data � 05.08.99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Movimentacao                                               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � RotMov                                                     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � BIA041                                                     낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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

	If Subs(SD3->D3_COD,8,1) == "1"
		@li,001 PSAY "100"
	ElseIf Subs(SD3->D3_COD,8,1) == "2"
		@li,001 PSAY "200"
	ElseIf Subs(SD3->D3_COD,8,1) == "3"
		@li,001 PSAY "300"
	EndIf
	@li,Pcol()+3 PSAY SUBS(SZ9->Z9_DESCRIC,1,38)

	IF Len(AllTrim(SD3->D3_LOTECTL)) <= 5
		@li,Pcol()+6 Psay Subs(SD3->D3_LOTECTL,1,2)
		@li,Pcol()+3 Psay Subs(SD3->D3_LOTECTL,3,3)
	ELSE
		@li,Pcol()+6 Psay SD3->D3_LOTECTL
	ENDIF

	@li,Pcol()+1 PSAY wTot2UM Picture PESQPICTQT("Z9_QTDLIB",10)
	@li,Pcol()+3 PSAY SD3->D3_SEGUM
	@li,Pcol()+8 PSAY SUBS(SD3->D3_LOCALIZ,1,7)

	Pallets()

	@li,Pcol()+1 PSAY wPallets PICTURE "@Z 9,999"
	If !Empty(wPalletsCx)
		@li,Pcol()+1 PSAY "/"
		@li,Pcol()+0 PSAY wPalletsCx PICTURE "@E 9,999"
	EndIf
	@li,104 PSAY SD3->D3_DOC
	@li,Pcol()+4 PSAY SZ9->Z9_QTDLIB Picture PESQPICTQT("Z9_QTDLIB",10)
	@li,Pcol()+3 PSAY SD3->D3_UM

	li := li + 1

	@li,60 Psay ("---------------")

	li := li + 1

	wTotProd := wTotProd + SZ9->Z9_QTDLIB
	nTotQtd  := nTotQtd + wTotProd
	nTot2UM  := nTot2UM + wTot2UM

Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � Pallets  � Autor � Cesar Magnago         � Data � 09/12/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇚o � Calculo dos Pallets do Romaneio de Carga                   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿞intaxe   � Rotina Pallets                                             낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � BIA041                                                     낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function Pallets
Static Function Pallets()

	wsOk         := .T.
	wPallets     := 0
	wxPallets    := 0
	wPalletsCx   := 0
	wSomaPallets := 0
	wsDivisor    := sDIVPA

	wPallets := wTot2UM
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
