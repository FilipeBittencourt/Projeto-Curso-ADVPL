#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
	#IFNDEF WINDOWS
		#DEFINE PSAY SAY
	#ENDIF

User Function Bia071()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CDESC1,CDESC2,CDESC3,TAMANHO,LIMITE,CSTRING")
SetPrvt("TITULO,ARETURN,NOMEPROG,NLASTKEY,WNUMBER,CBCONT")
SetPrvt("CABEC1,CABEC2,C15,CBTXT,LI,M_PAG")
SetPrvt("WPEDIDE,WPEDIATE,WPRODDE,WPRODATE,WCLIEDE,WCLIEATE")
SetPrvt("WVENDDE,WVENDATE,WENTRDE,WENTRATE,WEMABERTO,WGERADUP")
SetPrvt("WORDEM,WFORMATO,WCLASSE,ACAMPO,_cTrb,WOLDDATA")
SetPrvt("WINCREGUA,TCLIENTE,TCLAACLI,TCLACCLI,TCLADCLI,TFORACLI")
SetPrvt("TFORBCLI,TFORCCLI,GCLIENTE,GVENDEDO,GCLAACLI,GCLACCLI")
SetPrvt("GCLADCLI,GFORACLI,GFORBCLI,GFORCCLI,GGERAL,WOLDVEND")
SetPrvt("WPRIMVEZ,WOLDCLI,WLINDEIMP,WA3_NOME,")

	//Programa	: BIA071
	//Autor		: _cTrb
	//Data		: 27.09.1999
	//Descricao : Relacao de Pedidos nao entregues - Por Cliente
	//Ordem		: Representante, Cliente(pedido+item)
	//Uso 		: SIGAFAT

	#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 		#DEFINE PSAY SAY
	#ENDIF

	//Inicializa variaveis
	cDesc1	  := "Este programa tem como objetivo emitir um relatorio das"
	cDesc2	  := "disponibilidades em estoque dos produtos"
	cDesc3	  := ""
	tamanho	  := "G"
	limite	  := 140
	cString	  := "SC6"
	titulo	  := "PEDIDOS PENDENTES"
	aReturn	  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	NomeProg   := "BIA071"
	nLastKey   := wNumber := cbcont := 0
	Cabec1	  := "CODIGO    NOME DO   NUMERO IT  DATA       CODIGO           DESCRICAO                          DATA       QUANT.      QUANT.    QUANT."
	Cabec2	  := "CLIENTE   CLIENTE   PEDIDO     EMISSAO    PRODUTO          PRODUTO                          ENTREGA      PEDIDA     ENTREGUE  PENDENTE"
	C15		  := 15
	cbtxt 	  := space(10)
	li 		  := 80
	m_pag 	  := 1

	//Envia controle para a funcao SETPRINT
	NomeProg := SetPrint(cString,NomeProg,NomeProg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)

	//Verifica Posicao do Formulario na Impressora
	SetDefault(aReturn,cString)

	PERGUNTE( NomeProg, .F. )

	If ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
		Return
	Endif

	wPediDe	 := mv_par01 // pedido de
	wPediAte  := mv_par02 // pedido ate
	wProdDe	 := mv_par03 // produto de
	wProdAte  := mv_par04 // produto ate
	wClieDe	 := mv_par05 // cliente de
	wClieAte  := mv_par06 // cliente ate
	wVendDe	 := mv_par07 // vendedor de
	wVendAte  := mv_par08 // vendedor ate
	wEntrDe	 := mv_par09 // data entrega de
	wEntrAte  := mv_par10 // data entrega ate
	wEmAberto := (mv_par11 == 1)// pedidos em aberto ou todos
	wGeraDup  := (mv_par12 == 1)// pedidos com TES gerador de nota fiscal
	wOrdem	 := mv_par13 // ordenacao por cliente ou vendedor
	wFormato  :=  IIF(mv_par14==1,"A",IIF(mv_par14==2,"B",IIF(mv_par14==3,"C",;
	              IIF(mv_par14==4,"D",IIF(mv_par14==5,"Q",IIF(mv_par14==3,"R",;
	              IIF(mv_par14==3,"S","A,B,C"))))))) // 30X30, 40X40, 25X35 OU TODOS
	wClasse	 := IIF( mv_par15 == 4, "1,2,3", STR(mv_par15) )

	If ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
		Return
	Endif

	fCriaArq()

	RptStatus({|| fPedNaoEnt() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	RptStatus({|| Execute(fPedNaoEnt) })

	//RODAPE
	Roda(cbcont,cbtxt,tamanho)

	DBSELECTAREA("_cTrb")
	DBCLOSEAREA("_cTrb")

	FERASE(_cTrb+".DBF")
	FERASE(_cTrb+".MEM")
	FERASE(_cTrb+".NTX")

	//Libera impressao
	If aReturn[5] == 1
		Set Printer To
		Ourspool(NomeProg)
	Endif

	MS_FLUSH()

	//Fim do programa

RETURN( NIL )

// CRIA ARQUIVO TEMPORARIO
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fCriaArq
Static FUNCTION fCriaArq()

	aCampo	:= { { "PRODUTO ", "C", 15, 0 },;
					  { "CLIENTE ", "C", 06, 0 },;
					  { "VENDEDOR", "C", 06, 0 },;
					  { "PEDIDO  ", "C", 06, 0 },;
					  { "EMISSAO" , "D", 08, 0 },;
					  { "ENTREGA" , "D", 08, 0 },;
					  { "ITEM    ", "C", 02, 0 },;
					  { "DESC    ", "C", 30, 0 },;
					  { "QTDPED  ", "N", 12, 2 },;
					  { "QTDJENT ", "N", 12, 2 },;
					  { "SALDO   ", "N", 12, 2 } }
	If chkfile("_cTrb")
		dbSelectArea("_cTrb")
		dbCloseArea()
	EndIf
	_cTrb := CRIATRAB(aCampo, .T.)
	DBUSEAREA(.T.,,_cTrb,"_cTrb")

	DBCREATEINDEX(_cTrb,"VENDEDOR+CLIENTE+PRODUTO",{|| VENDEDOR+CLIENTE+PRODUTO} )

RETURN( NIL )

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fPedNaoEnt
Static FUNCTION fPedNaoEnt()

	DBSELECTAREA("SC6")
	DBSETORDER(3)

	DBSEEK( xFILIAL("SC6")+DTOS(wEntrDe)+wPediDe, .T. )

	SETREGUA( wEntrAte - wEntrDe )
	wOldData := CTOD("")

	WHILE !EOF() .AND. ( SC6->C6_ENTREG < wEntrAte )

		// VALIDA: SE FOI INCREMENTADA A DATA
		IF wOldData == CTOD("") .OR. wOldData < SC6->C6_ENTREG
			wIncRegua := IIF( wOldData == CTOD(""), 1, SC6->C6_ENTREG - wOldData )
			wOldData  := SC6->C6_ENTREG
		ENDIF

		// VALIDA: SE FOI INCREMENTADA A REGUA
		IF wIncRegua > 0
			INCREGUA( wIncRegua )
			wIncRegua := 0
		ENDIF

		// VALIDA: SE FOI PRESSIONADO [ESC]
		IF ( LASTKEY() == 27 )
			EXIT
		ENDIF

		// VALIDA: SE O CODIGO DO PEDIDO ESTA NO INTERVALO DOS PARAMETROS
		IF ( SC6->C6_NUM < wPediDe ) .OR. ( SC6->C6_NUM > wPediAte )
			DBSELECTAREA("SC6")
			DBSKIP()
			LOOP
		ENDIF

		// VALIDA: SE O CODIGO DO PRODUTO ESTA NO INTERVALO DOS PARAMETROS
		IF ( SC6->C6_PRODUTO < wProdDe ) .OR. ( SC6->C6_PRODUTO > wProdAte )
			DBSELECTAREA("SC6")
			DBSKIP()
			LOOP
		ENDIF

		// VALIDA: SE A CLASSE ESTA DENTRO DOS PARAMETROS
		IF ! ( SUBS(SC6->C6_PRODUTO,8,1) $ wClasse )
			DBSELECTAREA("SC6")
			DBSKIP()
			LOOP
		ENDIF

		// VALIDA: SE O FORMATO ESTA DENTRO DOS PARAMETROS
		IF wFormato <> "D"
			IF ! ( SUBS(SC6->C6_PRODUTO,1,1) $ wFormato )
				DBSELECTAREA("SC6")
				DBSKIP()
				LOOP
			ENDIF
		END IF
		// VALIDA: SE DEVE IMPRIMIR APENAS OS PEDIDOS EM ABERTO
		IF wEmAberto
			IF ( SC6->C6_QTDVEN - SC6->C6_QTDENT ) == 0
				DBSELECTAREA("SC6")
				DBSKIP()
				LOOP
			ENDIF
		ENDIF

		// VALIDA: SE O TES GERA DUPLICATA
		IF wGeraDup
			IF SF4->(DBSEEK(xFILIAL("SF4")+SC6->C6_TES))
				IF ( SF4->F4_DUPLIC #"S" )
					DBSELECTAREA("SC6")
					DBSKIP()
					LOOP
				ENDIF
			ELSE
				ALERT( "TES "+SC6->C6_TES+" NAO CADASTRADO" )
				DBSELECTAREA("SC6")
				DBSKIP()
				LOOP
			ENDIF
		ENDIF

		DBSELECTAREA("SC5")
		DBSEEK(xFILIAL("SC5")+SC6->C6_NUM)

		// VALIDA: SE CODIGO DO VENDEDOR ESTA NO INTERVALO DOS PARAMETROS
		IF ( SC5->C5_VEND1 < wVendDe ) .OR. ( SC5->C5_VEND1 > wVendAte )
			DBSELECTAREA("SC6")
			DBSKIP()
			LOOP
		ENDIF

		// VALIDA: SE O CODIGO DO CLIENTER ESTA NO INTERVALO DOS PARAMETROS
		IF ( SC5->C5_CLIENTE < wClieDe ) .OR. ( SC5->C5_CLIENTE > wClieAte )
			DBSELECTAREA("SC6")
			DBSKIP()
			LOOP
		ENDIF

		DBSELECTAREA("SB1")
		DBSETORDER(1)

		// PESQUISA: SE PRODUTO EXISTE NO CADASTRO DE PRODUTOS
		IF ! DBSEEK( xFilial("SB1")+SC6->C6_PRODUTO )
			ALERT( "PRODUTO " + SC6->C6_PRODUTO + " NAO ENCONTRADO" )
			DBSELECTAREA("SC6")
			DBSKIP()
			LOOP
		ENDIF

		fGrava()

		DBSELECTAREA("SC6")
		DBSKIP()

	ENDDO

	fImprime()

RETURN( NIL )

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fGrava
Static FUNCTION fGrava()

	DBSELECTAREA("_cTrb")

	WHILE !RECLOCK( "_cTrb",.T.); ENDDO

	_cTrb->PRODUTO  := SC6->C6_PRODUTO
	_cTrb->CLIENTE  := SC5->C5_CLIENTE
	_cTrb->VENDEDOR := SC5->C5_VEND1
	_cTrb->PEDIDO   := SC5->C5_NUM
	_cTrb->EMISSAO  := SC5->C5_EMISSAO
	_cTrb->ENTREGA  := SC6->C6_ENTREG
	_cTrb->ITEM	  := SC6->C6_ITEM
	_cTrb->DESC	  := SB1->B1_DESC
	_cTrb->QTDPED   := SC6->C6_QTDVEN
	_cTrb->QTDJENT  := SC6->C6_QTDENT
	_cTrb->SALDO	  := SC6->C6_QTDVEN - SC6->C6_QTDENT

	MSUNLOCK()

RETURN( NIL )

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImprime
Static FUNCTION fImprime()

	DBSELECTAREA("_cTrb")
	DBGOTOP()

	SETREGUA( _cTrb->( LASTREC() ) )

	// SE€ÇO PARA INICIALIZA€ÇO DAS VARIµVEIS DE TRABALHO

	tCliente := {0,0,0}

	tClaACli := {0,0,0}
	tClaCCli := {0,0,0}
	tClaDCli := {0,0,0}

	tForACli := {0,0,0}
	tForBCli := {0,0,0}
	tForCCli := {0,0,0}
	tForDCli := {0,0,0}
	tForQCli := {0,0,0}
	tForRCli := {0,0,0}
	tForSCli := {0,0,0}	

	gCliente := {0,0,0}

	gVendedo := {0,0,0}

	gClaACli := {0,0,0}
	gClaCCli := {0,0,0}
	gClaDCli := {0,0,0}

	gForACli := {0,0,0}
	gForBCli := {0,0,0}
	gForCCli := {0,0,0}
	gForDCli := {0,0,0}
	gForQCli := {0,0,0}
	gForRCli := {0,0,0}			
	gForSCli := {0,0,0}
	
	gGeral	:= {0,0,0}
	gGeral	:= {0,0,0}
	gGeral	:= {0,0,0}

	wOldVend := _cTrb->VENDEDOR
	wPrimVez := .T.
	wOldCli	:= ""

	// SE€ÇO IMPRESSAO
	WHILE ! _cTrb->( EOF() )

		INCREGUA()

		// IMPRIME CABE€ALHO
		IF li >= 60
			li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 2
		ENDIF

		IF wPrimVez
			fImpVend()
			wPrimVez := .F.
		ENDIF

		IF ( wOldCli #_cTrb->CLIENTE )

			IF ! Empty(wOldCli)

				fImpTotCli()

				IF !( wOldVend #_cTrb->VENDEDOR )
					fImpCli()
				ENDIF

			ELSE

				fImpCli()

			ENDIF

			wLinDeImp := _cTrb->CLIENTE + SPACE( 14 )

		ELSE
			wLinDeImp := SPACE(20)
		ENDIF

		IF ( wOldVend #_cTrb->VENDEDOR )

			IF ! ( wOldCli #_cTrb->CLIENTE )
				fImpTotCli()
			ENDIF

			fImpTotVen()

			fImpVend()

			fImpCli()

		ENDIF

		fAcumula()

		wLinDeImp := wLinDeImp + _cTrb->PEDIDO  + SPACE( 1 )
		wLinDeImp := wLinDeImp + _cTrb->ITEM	  + SPACE( 2 )
		wLinDeImp := wLinDeImp + DTOC(_cTrb->EMISSAO) + SPACE( 1 )
		wLinDeImp := wLinDeImp + _cTrb->PRODUTO + SPACE( 2 )
		wLinDeImp := wLinDeImp + _cTrb->DESC	  + SPACE( 2 )
		wLinDeImp := wLinDeImp + DTOC(_cTrb->ENTREGA) + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(_cTrb->QTDPED, "@E 999,999.99") + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(_cTrb->QTDJENT,"@E 999,999.99") + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(_cTrb->SALDO,  "@E 999,999.99")

		@ li, 000 PSAY wLinDeImp

		li := li + 1

		wOldCli	 := _cTrb->CLIENTE
		wOldVend  := _cTrb->VENDEDOR

		DBSELECTAREA("_cTrb")
		DBSKIP()

	ENDDO

	fImpTotCli()

	fImpTotVen()

	wLinDeImp := 'TOTAL GERAL              '                  + SPACE( 6 )
	wLinDeImp := wLinDeImp + TRANS(gGeral[1],"@E 999,999.99") + SPACE( 2 )
	wLinDeImp := wLinDeImp + TRANS(gGeral[2],"@E 999,999.99") + SPACE( 2 )
	wLinDeImp := wLinDeImp + TRANS(gGeral[3],"@E 999,999.99")
	@ li, 071 PSAY wLinDeImp
	li := li + 1

	@ li, 000 PSAY REPL("-",Limite)
	li := li + 1

RETURN( NIL )

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpTotCli
Static FUNCTION fImpTotCli()

	@ li, 000 PSAY REPL("-",Limite)
	li := li + 1

	IF ( tClaACli[1] > 0 )
		wLinDeImp	:= 'Total da Classe "A"      '                    + SPACE( 6 )
		wLinDeImp	:= wLinDeImp + TRANS(tClaACli[1],"@E 999,999.99") + SPACE( 2 )
		wLinDeImp	:= wLinDeImp + TRANS(tClaACli[2],"@E 999,999.99") + SPACE( 2 )
		wLinDeImp	:= wLinDeImp + TRANS(tClaACli[3],"@E 999,999.99")
		tClaACli[1] := tClaACli[2] := tClaACli[3] := 0
		@ li, 071 PSAY wLinDeImp
		li := li + 1
	ENDIF

	IF ( tClaCCli[1] > 0 )
		wLinDeImp := 'Total da Classe "C"      '                    + SPACE( 6 )
		wLinDeImp := wLinDeImp + TRANS(tClaCCli[1],"@E 999,999.99") + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(tClaCCli[2],"@E 999,999.99") + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(tClaCCli[3],"@E 999,999.99")
		tClaCCli[1] := tClaCCli[2] := tClaCCli[3] := 0
		@ li, 071 PSAY wLinDeImp
		li := li + 1
	ENDIF

	IF ( tClaDCli[1] > 0 )
		wLinDeImp	:= 'Total da Classe "D"      '                    + SPACE( 6 )
		wLinDeImp	:= wLinDeImp + TRANS(tClaDCli[1],"@E 999,999.99") + SPACE( 2 )
		wLinDeImp	:= wLinDeImp + TRANS(tClaDCli[2],"@E 999,999.99") + SPACE( 2 )
		wLinDeImp	:= wLinDeImp + TRANS(tClaDCli[3],"@E 999,999.99")
		tClaDCli[1] := tClaDCli[2] := tClaDCli[3] := 0
		@ li, 071 PSAY wLinDeImp
		li := li + 1
	ENDIF

	IF ( tForACli[1] > 0 )
		wLinDeImp := 'Total do Formato 30X30   '                    + SPACE( 6 )
		wLinDeImp := wLinDeImp + TRANS(tForACli[1],"@E 999,999.99") + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(tForACli[2],"@E 999,999.99") + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(tForACli[3],"@E 999,999.99")
		tForACli[1] := tForACli[2] := tForACli[3] := 0
		@ li, 071 PSAY wLinDeImp
		li := li + 1
	ENDIF

	IF ( tForBCli[1] > 0 )
		wLinDeImp := 'Total do Formato 40X40   '                    + SPACE( 6 )
		wLinDeImp := wLinDeImp + TRANS(tForBCli[1],"@E 999,999.99") + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(tForBCli[2],"@E 999,999.99") + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(tForBCli[3],"@E 999,999.99")
		tForBCli[1] := tForBCli[2] := tForBCli[3] := 0
		@ li, 071 PSAY wLinDeImp
		li := li + 1
	ENDIF

	IF ( tForCCli[1] > 0 )
		wLinDeImp := 'Total do Formato 25X35   '                    + SPACE( 6 )
		wLinDeImp := wLinDeImp + TRANS(tForCCli[1],"@E 99,999,999") + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(tForCCli[2],"@E 99,999,999") + SPACE( 1 )
		wLinDeImp := wLinDeImp + TRANS(tForCCli[3],"@E 99,999,999")
		tForCCli[1] := tForCCli[2] := tForCCli[3] := 0
		@ li, 071 PSAY wLinDeImp
		li := li + 1
	ENDIF
	
	IF ( tForDCli[1] > 0 )
		wLinDeImp := 'Total do Formato 43X43   '                    + SPACE( 6 )
		wLinDeImp := wLinDeImp + TRANS(tForDCli[1],"@E 99,999,999") + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(tForDCli[2],"@E 99,999,999") + SPACE( 1 )
		wLinDeImp := wLinDeImp + TRANS(tForDCli[3],"@E 99,999,999")
		tForDCli[1] := tForDCli[2] := tForDCli[3] := 0
		@ li, 071 PSAY wLinDeImp
		li := li + 1
	ENDIF              
	
  IF ( tForQCli[1] > 0 )
  	wLinDeImp := 'Total do Formato 31X31   '                    + SPACE( 6 )
		wLinDeImp := wLinDeImp + TRANS(tForQCli[1],"@E 99,999,999") + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(tForQCli[2],"@E 99,999,999") + SPACE( 1 )
		wLinDeImp := wLinDeImp + TRANS(tForQCli[3],"@E 99,999,999")
		tForQCli[1] := tForQCli[2] := tForQCli[3] := 0
		@ li, 071 PSAY wLinDeImp
		li := li + 1
	ENDIF

	IF ( tForRCli[1] > 0 )
		wLinDeImp := 'Total do Formato 25X25   '                    + SPACE( 6 )
		wLinDeImp := wLinDeImp + TRANS(tForRCli[1],"@E 99,999,999") + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(tForRCli[2],"@E 99,999,999") + SPACE( 1 )
		wLinDeImp := wLinDeImp + TRANS(tForRCli[3],"@E 99,999,999")
		tForRCli[1] := tForRCli[2] := tForRCli[3] := 0
		@ li, 071 PSAY wLinDeImp
		li := li + 1
	ENDIF


	IF ( tForSCli[1] > 0 )
		wLinDeImp := 'Total do Formato 44X44   '                    + SPACE( 6 )
		wLinDeImp := wLinDeImp + TRANS(tForSCli[1],"@E 99,999,999") + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(tForSCli[2],"@E 99,999,999") + SPACE( 1 )
		wLinDeImp := wLinDeImp + TRANS(tFoSCCli[3],"@E 99,999,999")
		tForSCli[1] := tForSCli[2] := tForSCli[3] := 0
		@ li, 071 PSAY wLinDeImp
		li := li + 1
	ENDIF


	wLinDeImp := 'Total do Cliente         '                    + SPACE( 6 )
	wLinDeImp := wLinDeImp + TRANS(gCliente[1],"@E 999,999.99") + SPACE( 2 )
	wLinDeImp := wLinDeImp + TRANS(gCliente[2],"@E 999,999.99") + SPACE( 2 )
	wLinDeImp := wLinDeImp + TRANS(gCliente[3],"@E 999,999.99")
	gCliente[1] := gCliente[2] := gCliente[3] := 0
	@ li, 071 PSAY wLinDeImp
	li := li + 1

RETURN( NIL )

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpTotVen
Static FUNCTION fImpTotVen()

	wLinDeImp := 'TOTAL DO VENDEDOR        '                    + SPACE( 6 )
	wLinDeImp := wLinDeImp + TRANS(gVendedo[1],"@E 999,999.99") + SPACE( 2 )
	wLinDeImp := wLinDeImp + TRANS(gVendedo[2],"@E 999,999.99") + SPACE( 2 )
	wLinDeImp := wLinDeImp + TRANS(gVendedo[3],"@E 999,999.99")

	gVendedo[1] := gVendedo[2] := gVendedo[3] := 0

	@ li, 071 PSAY wLinDeImp

	li := li + 1

RETURN(NIL)

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpVend
Static FUNCTION fImpVend()

	DBSELECTAREA("SA3")
	DBSETORDER(1)

	//POSICIONA: VENDEDOR PARA IMPRIMIR DADOS CADASTRAIS
	IF DBSEEK( xFilial("SA3")+_cTrb->VENDEDOR,.F.)
		wA3_NOME := SA3->A3_NOME
	ELSE
		wA3_NOME := "VENDEDOR NAO CADASTRADO"
	ENDIF

	@ li, 000 PSAY REPL("-",Limite)
	li := li + 1
	@ li, 000 PSAY "VENDEDOR: "+_cTrb->VENDEDOR+" - "+wA3_NOME
	li := li + 1

RETURN( NIL )

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fAcumula
Static FUNCTION fAcumula()

		// ACUMULA VALORES DO CLIENTE
		tCliente[1] := tCliente[1] + _cTrb->QTDPED
		tCliente[2] := tCliente[2] + _cTrb->QTDJENT
		tCliente[3] := tCliente[3] + _cTrb->SALDO

		// Geral
		gGeral[1] := gGeral[1] + _cTrb->QTDPED
		gGeral[2] := gGeral[2] + _cTrb->QTDJENT
		gGeral[3] := gGeral[3] + _cTrb->SALDO

		// ACUMULA VALORES DA CLASSE "A"
		IF SUBS(_cTrb->PRODUTO, 6, 1) == "1"
			tClaACli[1] := tClaACli[1] + _cTrb->QTDPED
			tClaACli[2] := tClaACli[2] + _cTrb->QTDJENT
			tClaACli[3] := tClaACli[3] + _cTrb->SALDO
		ENDIF

		// ACUMULA VALORES DA CLASSE "C"
		IF SUBS(_cTrb->PRODUTO, 6, 1) == "2"
			tClaCCli[1] := tClaCCli[1] + _cTrb->QTDPED
			tClaCCli[2] := tClaCCli[2] + _cTrb->QTDJENT
			tClaCCli[3] := tClaCCli[3] + _cTrb->SALDO
		ENDIF

		// ACUMULA VALORES DA CLASSE "D"
		IF SUBS(_cTrb->PRODUTO, 6, 1) == "3"
			tClaDCli[1] := tClaDCli[1] + _cTrb->QTDPED
			tClaDCli[2] := tClaDCli[2] + _cTrb->QTDJENT
			tClaDCli[3] := tClaDCli[3] + _cTrb->SALDO
		ENDIF

		// ACUMULA VALORES DO FORMATO 30X30
		IF SUBS(_cTrb->PRODUTO, 1, 1) == "A"
			tForACli[1] := tForACli[1] + _cTrb->QTDPED
			tForACli[2] := tForACli[2] + _cTrb->QTDJENT
			tForACli[3] := tForACli[3] + _cTrb->SALDO
		ENDIF

		// ACUMULA VALORES DO FORMATO 40X40
		IF SUBS(_cTrb->PRODUTO, 1, 1) == "B"
			tForBCli[1] := tForBCli[1] + _cTrb->QTDPED
			tForBCli[2] := tForBCli[2] + _cTrb->QTDJENT
			tForBCli[3] := tForBCli[3] + _cTrb->SALDO
		ENDIF

		// ACUMULA VALORES DO FORMATO 25X35
		IF SUBS(_cTrb->PRODUTO, 1, 1) == "C"
			tForCCli[1] := tForCCli[1] + _cTrb->QTDPED
			tForCCli[2] := tForCCli[2] + _cTrb->QTDJENT
			tForCCli[3] := tForCCli[3] + _cTrb->SALDO
		ENDIF
		
		// ACUMULA VALORES DO FORMATO 43X43
		IF SUBS(_cTrb->PRODUTO, 1, 1) == "D"
			tForDCli[1] := tForDCli[1] + _cTrb->QTDPED
			tForDCli[2] := tForDCli[2] + _cTrb->QTDJENT
			tForDCli[3] := tForDCli[3] + _cTrb->SALDO
		ENDIF

		// ACUMULA VALORES DO FORMATO 31X31
		IF SUBS(_cTrb->PRODUTO, 1, 1) == "Q"
			tForQCli[1] := tForQCli[1] + _cTrb->QTDPED
			tForQCli[2] := tForQCli[2] + _cTrb->QTDJENT
			tForQCli[3] := tForQCli[3] + _cTrb->SALDO
		ENDIF
		
		// ACUMULA VALORES DO FORMATO 25X25
		IF SUBS(_cTrb->PRODUTO, 1, 1) == "R"
			tForRCli[1] := tForRCli[1] + _cTrb->QTDPED
			tForRCli[2] := tForRCli[2] + _cTrb->QTDJENT
			tForRCli[3] := tForRCli[3] + _cTrb->SALDO
		ENDIF

		// ACUMULA VALORES DO FORMATO 44X44
		IF SUBS(_cTrb->PRODUTO, 1, 1) == "S"
			tForSCli[1] := tForSCli[1] + _cTrb->QTDPED
			tForSCli[2] := tForSCli[2] + _cTrb->QTDJENT
			tForSCli[3] := tForSCli[3] + _cTrb->SALDO
		ENDIF

		gVendedo[1] := gVendedo[1] + _cTrb->QTDPED
		gVendedo[2] := gVendedo[2] + _cTrb->QTDJENT
		gVendedo[3] := gVendedo[3] + _cTrb->SALDO

		gCliente[1] := gCliente[1] + _cTrb->QTDPED
		gCliente[2] := gCliente[2] + _cTrb->QTDJENT
		gCliente[3] := gCliente[3] + _cTrb->SALDO

		// ACUMULA VALORES PARA MONTAR O TOTAL GERAL DA CLASSE  "A"
		IF SUBS(_cTrb->PRODUTO, 6, 1) == "1"
			gClaACli[1] := gClaACli[1] + _cTrb->QTDPED
			gClaACli[2] := gClaACli[2] + _cTrb->QTDJENT
			gClaACli[3] := gClaACli[3] + _cTrb->SALDO
		ENDIF

		// ACUMULA VALORES PARA MONTAR O TOTAL GERAL DA CLASSE  "C"
		IF SUBS(_cTrb->PRODUTO, 6, 1) == "2"
			gClaCCli[1] := gClaCCli[1] + _cTrb->QTDPED
			gClaCCli[2] := gClaCCli[2] + _cTrb->QTDJENT
			gClaCCli[3] := gClaCCli[3] + _cTrb->SALDO
		ENDIF

		// ACUMULA VALORES PARA MONTAR O TOTAL GERAL DA CLASSE  "D"
		IF SUBS(_cTrb->PRODUTO, 6, 1) == "3"
			gClaDCli[1] := gClaDCli[1] + _cTrb->QTDPED
			gClaDCli[2] := gClaDCli[2] + _cTrb->QTDJENT
			gClaDCli[3] := gClaDCli[3] + _cTrb->SALDO
		ENDIF

		// ACUMULA VALORES PARA MONTAR O TOTAL GERAL DO FORMATO 30X30
		IF SUBS(_cTrb->PRODUTO, 1, 1) == "A"
			gForACli[1] := gForACli[1] + _cTrb->QTDPED
			gForACli[2] := gForACli[2] + _cTrb->QTDJENT
			gForACli[3] := gForACli[3] + _cTrb->SALDO
		ENDIF

		// ACUMULA VALORES PARA MONTAR O TOTAL GERAL DO FORMATO 40X40
		IF SUBS(_cTrb->PRODUTO, 1, 1) == "B"
			gForBCli[1] := gForBCli[1] + _cTrb->QTDPED
			gForBCli[2] := gForBCli[2] + _cTrb->QTDJENT
			gForBCli[3] := gForBCli[3] + _cTrb->SALDO
		ENDIF

		// ACUMULA VALORES PARA MONTAR O TOTAL GERAL DO FORMATO 25X35
		IF SUBS(_cTrb->PRODUTO, 1, 1) == "C"
			gForCCli[1] := gForCCli[1] + _cTrb->QTDPED
			gForCCli[2] := gForCCli[2] + _cTrb->QTDJENT
			gForCCli[3] := gForCCli[3] + _cTrb->SALDO
		ENDIF
		
		// ACUMULA VALORES PARA MONTAR O TOTAL GERAL DO FORMATO 25X35
		IF SUBS(_cTrb->PRODUTO, 1, 1) == "D"
			gForDCli[1] := gForDCli[1] + _cTrb->QTDPED
			gForDCli[2] := gForDCli[2] + _cTrb->QTDJENT
			gForDCli[3] := gForDCli[3] + _cTrb->SALDO
		ENDIF

		// ACUMULA VALORES PARA MONTAR O TOTAL GERAL DO FORMATO 25X35
		IF SUBS(_cTrb->PRODUTO, 1, 1) == "Q"
			gForQCli[1] := gForQCli[1] + _cTrb->QTDPED
			gForQCli[2] := gForQCli[2] + _cTrb->QTDJENT
			gForQCli[3] := gForQCli[3] + _cTrb->SALDO
		ENDIF
		
		// ACUMULA VALORES PARA MONTAR O TOTAL GERAL DO FORMATO 25X35
		IF SUBS(_cTrb->PRODUTO, 1, 1) == "R"
			gForRCli[1] := gForRCli[1] + _cTrb->QTDPED
			gForRCli[2] := gForRCli[2] + _cTrb->QTDJENT
			gForRCli[3] := gForRCli[3] + _cTrb->SALDO
		ENDIF
		
		// ACUMULA VALORES PARA MONTAR O TOTAL GERAL DO FORMATO 25X35
		IF SUBS(_cTrb->PRODUTO, 1, 1) == "S"
			gForSCli[1] := gForSCli[1] + _cTrb->QTDPED
			gForSCli[2] := gForSCli[2] + _cTrb->QTDJENT
			gForSCli[3] := gForSCli[3] + _cTrb->SALDO
		ENDIF

RETURN( NIL )

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpCli
Static FUNCTION fImpCli()

	DBSELECTAREA("SA1")
	DBSETORDER(1)

	//POSICIONA: CLIENTE PARA IMPRIMIR DADOS CADASTRAIS
	IF ! DBSEEK( xFilial("SA1")+_cTrb->CLIENTE)
		ALERT( "CLIENTE " + _cTrb->CLIENTE + " NAO ENCONTRADO" )
	ENDIF

	@ li, 000 PSAY REPL("-",Limite)
	li := li + 1
	@ li, 000 PSAY "CLIENTE: " + RTRIM(SA1->A1_NOME) + " -  " + RTRIM(SA1->A1_END) + " - " + RTRIM(SA1->A1_MUN) + " - " + SA1->A1_EST + " - " + RTRIM(SA1->A1_TEL)
	li := li + 1
	wLinDeImp:= _cTrb->CLIENTE + SPACE( 14 )

RETURN( NIL )