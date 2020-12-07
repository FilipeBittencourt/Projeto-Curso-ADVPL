#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 02/02/01
#include "TOPCONN.ch"
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function bia036()        // incluido pelo assistente de conversao do AP5 IDE em 02/02/01

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local nI 

	cDesc1	  := "Este programa tem como objetivo emitir um relatório das"
	cDesc2	  := "disponibilidades em estoque dos produtos"
	cDesc3	  := ""
	tamanho	  := "M"
	limite	  := 132
	cString	  := "SC6"
	titulo	  := "DISPONIBILIDADES DE PRODUTOS EM ESTOQUE"
	aReturn	  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	NomeProg   := "BIA036"
	nLastKey   := wNumber := cbcont := 0
	Cabec1	  := "*CODIGO         D  E  S  C  R  I  C  A  O                     SALDO   UM         PEDIDOS         RESERVA    ROMANEIO    DISPONIVEL"
	Cabec2	  := "*                                                           ESTOQUE            PENDENTES                                P/ VENDAS "
	C15        := 15
	cbtxt 	  := space(10)
	li         := 80
	m_pag 	  := 1
	sFormato := " "

	//Envia controle para a funcao SETPRINT
	wnrel := SetPrint(cString,NomeProg,NomeProg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)
	If ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
		Return
	Endif

	PERGUNTE( NomeProg, .F. )
	If ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
		Return
	Endif

	wProdDe   := mv_par01
	wProdAte  := mv_par02
	wAlmoxDe  := mv_par03
	wAlmoxAte := mv_par04
	cMascara  := Upper(mv_par05)
	wBloqueio := ( mv_par06 == 2 )
	wResiduo  := ( mv_par07 == 1 )
	wEstMax   := mv_par08
	cTipo     := AllTrim(Str(mv_par09)) //1=TIPO A - 2=TIPO C - 3=TIPO D
	wSalProd  := 0
	xDesc     := " "
	xExiste   := .F.

	//Determina a variavel de mascara.
	cContraMsc := ""
	for nI:=1 to len(cMascara)
		cContraMsc += iif(SubStr(cMascara,nI,1) # "*", "X", "*")
	next

	//Verifica Posicao do Formulario na Impressora
	SetDefault(aReturn,cString)
	If ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
		Return
	Endif
	Processa({|| fdisp()})
Return

static function fdisp()
	wPedPend :=  wPedRese := wSalDisp := wPedVend := wPedEntr := wPedRom:=0
	wTotProd := wTotPend := wTotDisp := wTotRese := wTotRom := 0
	aTotGera := { "","", 0, "", 0, 0, 0, 0 }
	aCampo   := {}
	AADD(aCampo,{ "PRODUTO ", "C", 15, 0 })
	AADD(aCampo,{ "LOTE    ", "C", 10, 0 })
	AADD(aCampo,{ "DESC    ", "C", 30, 0 })
	AADD(aCampo,{ "SALDO   ", "N", 12, 2 })
	AADD(aCampo,{ "UM      ", "C", 02, 0 })
	AADD(aCampo,{ "PENDENTE", "N", 12, 2 })
	AADD(aCampo,{ "RESERVA ", "N", 12, 2 })
	AADD(aCampo,{ "ROMANEIO", "N", 12, 2 })
	AADD(aCampo,{ "DISPONIV", "N", 12, 2 })

	cArqTrab := CRIATRAB(aCampo, .T.)
	DBUSEAREA(.T.,,cArqTrab,"TMP")
	DBCREATEINDEX(cArqTrab,"PRODUTO+LOTE",{|| PRODUTO+LOTE} )

	DBSELECTAREA("SC6")
	DBSETORDER(2)

	DBSELECTAREA("SB1")
	DBSETORDER(1)

	A0001 := " SELECT B8_FILIAL, B8_PRODUTO, B1_DESC, B1_UM, B8_LOTECTL, SUM(B8_SALDO) AS B8_SALDO"
	A0001 += " FROM "+RetSqlName("SB8")+" SB8, "+RetSqlName("SB1")+" SB1 "
	A0001 += " WHERE B8_FILIAL = '"+xFilial("SB8")+"' "
	A0001 += " AND B1_FILIAL = '"+xFilial("SB1")+"' "
	A0001 += " AND B8_PRODUTO = B1_COD "
	A0001 += " AND B8_PRODUTO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	A0001 += " AND B1_LOCPAD  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	IF cTipo <> '4'
		A0001 += " AND B1_YCLASSE = '"+cTipo+"' "
	ENDIF
	A0001 += " AND B1_TIPO = 'PA' "
	//A0001 += " AND B8_SALDO > 0 "
	A0001 += " AND SB1.D_E_L_E_T_ = ' ' "
	A0001 += " AND SB8.D_E_L_E_T_ = ' ' "
	A0001 += " GROUP BY B8_FILIAL, B8_PRODUTO, B8_LOTECTL, B1_DESC, B1_UM "
	A0001 += " ORDER BY B8_FILIAL, B8_PRODUTO, B8_LOTECTL, B1_DESC, B1_UM "
	If chkfile("A001")
		dbSelectArea("A001")
		dbCloseArea()
	EndIf
	TcQuery A0001 New Alias "A001"

	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	OldProduto := SPACE(15)

	While !Eof()

		IncProc("Processando produtos ...")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica saldo do produto.                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF A001->B8_SALDO > MV_PAR08
			DBSELECTAREA("A001")
			A001->(DBSKIP())
			LOOP
		ENDIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a mascara do produto atual combina com a mascara ...         ³
		//³ informada nos parametros.                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF Upper(Transform(A001->B8_PRODUTO,cContraMsc)) # cMascara
			DBSELECTAREA("A001")
			A001->(DBSKIP())
			LOOP
		ENDIF

		sFormato := " "
		cOldAlias := Alias()

		Do Case
			Case MV_PAR10 == "1";sFormato := "30x30"
			Case MV_PAR10 == "2";sFormato := "40x40"
			Case MV_PAR10 == "3";sFormato := "25x35"
			Case MV_PAR10 == "4";sFormato := "43x43"
			Case MV_PAR10 == "5";sFormato := "31x31"
			Case MV_PAR10 == "6";sFormato := "25x25"
			Case MV_PAR10 == "7";sFormato := "44x44"
			otherwise
			xDesc := SPACE(30)
		EndCase

		xDesc := sFormato

		xExiste := xDesc $ UPPER(SB1->B1_DESC)
		IF ! xExiste .And. xDesc <> SPACE(30)
			DBSELECTAREA("A001")
			A001->(DBSKIP())
			LOOP
		ENDIF

		IF OldProduto <> A001->B8_PRODUTO
			cLOTECTL   := SPACE(10)
			OldLote    := SPACE(10)
			fPedidos()

			wPedPend   := (wPedVend - wPedEntr)
			wSalDisp   := (wPedPend + wPedRese) * (-1)

			OldProduto := A001->B8_PRODUTO
			OldLote    := A001->B8_LOTECTL
			//wTotProd   := wTotProd + A001->B8_SALDO
			wTotPend   := wTotPend + wPedPend
			wTotDisp   := wTotDisp + wSalDisp
			wTotRese   := wTotRese + wPedRese
			wTotRom    := wTotRom  + wPedRom

			DBSELECTAREA("TMP")
			IF !DbSeek(OldProduto+SPACE(10))
				RecLock("TMP",.T.)
				TMP->PRODUTO  := OldProduto
				TMP->LOTE     := SPACE(10)
				TMP->DESC     := SUBS(A001->B1_DESC,1,30)
				TMP->UM       := A001->B1_UM
				//TMP->SALDO    := A001->B8_SALDO
				TMP->PENDENTE := wPedPend
				TMP->RESERVA  := wPedRese
				TMP->ROMANEIO := wPedRom
				TMP->DISPONIV := wSalDisp
			ELSE
				RecLock("TMP",.F.)
				//TMP->SALDO    := TMP->SALDO + A001->B8_SALDO
				TMP->PENDENTE := TMP->PENDENTE + wPedPend
				TMP->RESERVA  := TMP->RESERVA  + wPedRese
				TMP->ROMANEIO := TMP->ROMANEIO + wPedRom
				TMP->DISPONIV := TMP->DISPONIV + wSalDisp
			ENDIF
			wDesClaAnt    := SUBS(A001->B1_DESC,1,30)
			MSUNLOCK()

			aTotGera[1] := "TOTAL GERAL    "
			aTotGera[2] := SPACE(33)
			//aTotGera[3] := aTotGera[3] + A001->B8_SALDO
			aTotGera[4] := A001->B1_UM
			aTotGera[5] := aTotGera[5] + wPedPend
			aTotGera[6] := aTotGera[6] + wPedRese
			aTotGera[7] := aTotGera[7] + wSalDisp
			aTotGera[8] := aTotGera[8] + wPedRom
		ENDIF

		cLOTECTL := A001->B8_LOTECTL
		fPedidos()

		wPedPend   := (wPedVend - wPedEntr)
		wSalDisp   := A001->B8_SALDO - wPedPend - wPedRese

		OldProduto := A001->B8_PRODUTO
		OldLote    := A001->B8_LOTECTL
		wTotProd   := wTotProd + A001->B8_SALDO
		wTotPend   := wTotPend + wPedPend
		wTotDisp   := wTotDisp + wSalDisp
		wTotRese   := wTotRese + wPedRese
		wTotRom    := wTotRom  + wPedRom

		DBSELECTAREA("TMP")
		IF !DbSeek(OldProduto+OldLote)
			RecLock("TMP",.T.)
			TMP->PRODUTO  := OldProduto
			TMP->LOTE     := OldLote
			TMP->DESC     := SUBS(A001->B1_DESC,1,30)
			TMP->SALDO    := A001->B8_SALDO
			TMP->UM       := A001->B1_UM
			TMP->PENDENTE := wPedPend
			TMP->RESERVA  := wPedRese
			TMP->ROMANEIO := wPedRom
			TMP->DISPONIV := wSalDisp
		ELSE
			RecLock("TMP",.F.)
			TMP->SALDO    := TMP->SALDO + A001->B8_SALDO
			TMP->PENDENTE := TMP->PENDENTE + wPedPend
			TMP->RESERVA  := TMP->RESERVA + wPedRese
			TMP->ROMANEIO := TMP->ROMANEIO + wPedRom
			TMP->DISPONIV := TMP->DISPONIV + wSalDisp
		ENDIF
		wDesClaAnt    := SUBS(A001->B1_DESC,1,30)
		MSUNLOCK()

		aTotGera[1] := "TOTAL GERAL    "
		aTotGera[2] := SPACE(33)
		aTotGera[3] := aTotGera[3] + A001->B8_SALDO
		aTotGera[4] := A001->B1_UM
		aTotGera[5] := aTotGera[5] + wPedPend
		aTotGera[6] := aTotGera[6] + wPedRese
		aTotGera[7] := aTotGera[7] + wSalDisp
		aTotGera[8] := aTotGera[8] + wPedRom

		DBSELECTAREA("A001")
		A001->(DBSKIP())
	enddo

	fProdNovo()

	fImprime()
	DBSELECTAREA("TMP")
	DBCLOSEAREA()
	FERASE(cArqTrab+".*")
	//Libera impressao
	If aReturn[5] == 1
		Set Printer To
		Ourspool(wnrel)
	Endif
	MS_FLUSH()
RETURN

// BUSCA PEDIDOS EM ABERTO PARA O PRODUTO EM QUESTAO
Static FUNCTION fPedidos()
	LOCAL cQUERY
	wPedPend := wPedRese := wSalDisp := wPedVend := wPedEntr := wPedRom := 0

	A0002 := " SELECT C6_FILIAL, C6_PRODUTO, C6_TES, C6_BLOQUEI, C6_NUM, C6_ITEM, C6_QTDVEN, C6_QTDENT "
	A0002 += " FROM "+RetSqlName("SC6")+" SC6 "
	A0002 += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
	A0002 += " AND C6_LOTECTL = '"+cLOTECTL+"' "
	A0002 += " AND C6_PRODUTO = '"+A001->B8_PRODUTO+"' "
	A0002 += " AND C6_QTDVEN > C6_QTDENT "
	A0002 += " AND SC6.D_E_L_E_T_ = ' ' "
	A0002 += " AND C6_BLQ <> 'R'  "
	If chkfile("A002")
		dbSelectArea("A002")
		dbCloseArea()
	EndIf
	TcQuery A0002 New Alias "A002"

	dbSelectArea("A002")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()

		IncProc("Processando produto ..."+A001->B8_PRODUTO)

		IF MV_PAR12 <> 3
			cQUERY := ""
			cQUERY += "SELECT F4_ESTOQUE FROM "+ RETSQLNAME("SF4") +" "
			cQUERY += "WHERE 	F4_CODIGO 	= '"+ A002->C6_TES +"' AND "
			cQUERY += "			D_E_L_E_T_ 	= ''  "
			If chkfile("_cSF4")
				dbSelectArea("_cSF4")
				dbCloseArea()
			EndIf
			TCQUERY cQUERY ALIAS "_cSF4" NEW

			IF MV_PAR12 = 1   // FILTRAR ATUALIZA ESTOQUE = SIM
				IF _cSF4->F4_ESTOQUE <> 'S'
					DBSELECTAREA("A002")
					A002->(DbSkip())
					Loop
				END IF
			ELSEIF MV_PAR12 = 2
				IF _cSF4->F4_ESTOQUE <> 'N'
					DBSELECTAREA("A002")
					A002->(DbSkip())
					Loop
				ENDIF
			ENDIF
		ENDIF

		IF !wBloqueio
			IF !EMPTY(A002->C6_BLOQUEI)
				DBSELECTAREA("A002")
				A002->( DBSKIP() )
				LOOP
			ENDIF
			DBSELECTAREA("SC9")
			DBSETORDER(1)
			IF DBSEEK( xFilial("SC9")+A002->C6_NUM+A002->C6_ITEM,.T. )
				IF ! EMPTY( SC9->C9_BLEST ) .OR. ! EMPTY( SC9->C9_BLCRED )
					DBSELECTAREA("A002")
					A002->( DBSKIP() )
					LOOP
				ENDIF
			ENDIF
		ENDIF

		DbSelectArea("SDC")
		DbSetOrder(4)
		DbSeek(xFilial("SDC")+A002->C6_NUM+A002->C6_ITEM,.T.)
		Do while .not. eof() .and. DC_FILIAL == xFilial("SDC") .and. DC_PEDIDO == A002->C6_NUM .and. DC_ITEM == A002->C6_ITEM
			IF SDC->DC_LOTECTL <> cLOTECTL
				DBSELECTAREA("SDC")
				SDC->(DbSkip())
				Loop
			ENDIF
			If DC_ORIGEM == "SC6"
				wPedRom += SDC->DC_QUANT
			EndIf
			DbSelectArea("SDC")
			DbSkip()
		EndDo

		wPedVend := wPedVend + A002->C6_QTDVEN
		wPedEntr := wPedEntr + A002->C6_QTDENT

		DbSelectArea("A002")
		A002->(DBSKIP())
	ENDDO

	A0003 := " SELECT C0_FILIAL, C0_PRODUTO, C0_LOCAL, C0_NUM, C0_YPEDIDO "
	A0003 += " FROM "+RetSqlName("SC0")+" SC0 "
	A0003 += " WHERE C0_FILIAL = '"+xFilial("SC0")+"' "
	A0003 += " AND C0_LOTECTL = '"+cLOTECTL+"' "
	A0003 += " AND C0_PRODUTO = '"+A001->B8_PRODUTO+"' "
	A0003 += " AND SC0.D_E_L_E_T_ = ' ' "
	If chkfile("A003")
		dbSelectArea("A003")
		dbCloseArea()
	EndIf
	TcQuery A0003 New Alias "A003"

	dbSelectArea("A003")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()

		If !Empty(A003->C0_YPEDIDO)
			DbSelectArea("SC5")
			DbSetOrder(1)
			DbSeek(xFilial("SC5")+A003->C0_YPEDIDO)
			//Verifica se existe o pedido de vendas existe realmente
			If A003->C0_YPEDIDO == SC5->C5_NUM
				DbSelectArea("A003")
				DbSkip()
				Loop
			EndIf
		EndIf

		DbSelectArea("SDC")
		DbSetOrder(1)
		DbSeek(xFilial("SDC")+A003->C0_PRODUTO+A003->C0_LOCAL+"SC0"+A003->C0_NUM,.T.)
		Do while .not. eof() .and. DC_FILIAL == xFilial("SDC") .and. SDC->DC_PRODUTO == A003->C0_PRODUTO ;
		.and. SDC->DC_LOCAL == A003->C0_LOCAL .and. SDC->DC_ORIGEM == "SC0" .and. SDC->DC_PEDIDO == A003->C0_NUM
			IF SDC->DC_LOTECTL <> cLOTECTL
				DBSELECTAREA("SDC")
				SDC->(DbSkip())
				Loop
			ENDIF
			wPedRese += SDC->DC_QUANT
			DbSelectArea("SDC")
			DbSkip()
		EndDo

		DbSelectArea("A003")
		DbSkip()
	EndDo

RETURN

// BUSCA PEDIDOS EM ABERTO PARA O PRODUTO EM QUESTAO
Static FUNCTION fProdNovo()
	LOCAL cQUERY
	wPedPend := wPedRese := wSalDisp := wPedVend := wPedEntr := wPedRom := 0

	A0004 := " SELECT C6_FILIAL, C6_PRODUTO, C6_TES, C6_BLOQUEI, C6_NUM, C6_ITEM, C6_QTDVEN, C6_QTDENT, C6_LOTECTL "
	A0004 += " FROM "+RetSqlName("SC6")+" SC6 "
	A0004 += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
	A0004 += " AND C6_PRODUTO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	A0004 += " AND C6_QTDVEN > C6_QTDENT "
	A0004 += " AND SC6.D_E_L_E_T_ = ' ' "
	A0004 += " AND C6_BLQ <> 'R'  "
	If chkfile("A004")
		dbSelectArea("A004")
		dbCloseArea()
	EndIf
	TcQuery A0004 New Alias "A004"

	dbSelectArea("A004")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()

		IncProc("Processando produto ..."+A004->C6_PRODUTO)

		wPedPend := 0
		wPedRese := 0
		wSalDisp := 0
		wPedVend := 0
		wPedEntr := 0
		wPedRom  := 0

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+A004->C6_PRODUTO)

		IF cTipo <> '4'
			IF SB1->B1_YCLASSE <> cTipo
				DBSELECTAREA("A004")
				A004->( DBSKIP() )
				LOOP
			ENDIF
		ENDIF

		IF MV_PAR12 <> 3
			cQUERY := ""
			cQUERY += "SELECT F4_ESTOQUE FROM "+ RETSQLNAME("SF4") +" "
			cQUERY += "WHERE 	F4_CODIGO 	= '"+ A004->C6_TES +"' AND "
			cQUERY += "			D_E_L_E_T_ 	= ''  "
			If chkfile("_cSF4")
				dbSelectArea("_cSF4")
				dbCloseArea()
			EndIf
			TCQUERY cQUERY ALIAS "_cSF4" NEW

			IF MV_PAR12 = 1   // FILTRAR ATUALIZA ESTOQUE = SIM
				IF _cSF4->F4_ESTOQUE <> 'S'
					DBSELECTAREA("A004")
					A004->(DbSkip())
					Loop
				END IF
			ELSEIF MV_PAR12 = 2
				IF _cSF4->F4_ESTOQUE <> 'N'
					DBSELECTAREA("A004")
					A004->(DbSkip())
					Loop
				ENDIF
			ENDIF
		ENDIF

		IF !wBloqueio
			IF !EMPTY(A004->C6_BLOQUEI)
				DBSELECTAREA("A004")
				A004->( DBSKIP() )
				LOOP
			ENDIF
			DBSELECTAREA("SC9")
			DBSETORDER(1)
			IF DBSEEK( xFilial("SC9")+A004->C6_NUM+A004->C6_ITEM,.T. )
				IF ! EMPTY( SC9->C9_BLEST ) .OR. ! EMPTY( SC9->C9_BLCRED )
					DBSELECTAREA("A004")
					A004->( DBSKIP() )
					LOOP
				ENDIF
			ENDIF
		ENDIF

		DbSelectArea("SDC")
		DbSetOrder(4)
		DbSeek(xFilial("SDC")+A004->C6_NUM+A004->C6_ITEM,.T.)
		Do while .not. eof() .and. DC_FILIAL == xFilial("SDC") .and. DC_PEDIDO == A004->C6_NUM .and. DC_ITEM == A004->C6_ITEM
			IF SDC->DC_LOTECTL <> A004->C6_LOTECTL
				DBSELECTAREA("SDC")
				SDC->(DbSkip())
				Loop
			ENDIF
			If DC_ORIGEM == "SC6"
				wPedRom += SDC->DC_QUANT
			EndIf
			DbSelectArea("SDC")
			DbSkip()
		EndDo

		wPedVend := wPedVend + A004->C6_QTDVEN
		wPedEntr := wPedEntr + A004->C6_QTDENT

		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		DbSelectArea("SB8")
		DbSetOrder(1)
		IF !DbSeek(xFilial("SB8")+A004->C6_PRODUTO)
			wPedPend   := (wPedVend - wPedEntr)
			wSalDisp   := (wPedPend + wPedRese) * (-1)

			wTotPend   := wTotPend + wPedPend
			wTotDisp   := wTotDisp + wSalDisp
			wTotRese   := wTotRese + wPedRese
			wTotRom    := wTotRom  + wPedRom

			DBSELECTAREA("TMP")
			IF !DbSeek(A004->C6_PRODUTO+A004->C6_LOTECTL)
				RecLock("TMP",.T.)
				TMP->PRODUTO  := A004->C6_PRODUTO
				TMP->LOTE     := A004->C6_LOTECTL
				TMP->DESC     := SUBS(SB1->B1_DESC,1,30)
				TMP->UM       := SB1->B1_UM
				TMP->SALDO    := 0
				TMP->PENDENTE := wPedPend
				TMP->RESERVA  := wPedRese
				TMP->ROMANEIO := wPedRom
				TMP->DISPONIV := wSalDisp
				MSUNLOCK()
			ELSE
				RecLock("TMP",.F.)
				TMP->PENDENTE := TMP->PENDENTE + wPedPend
				TMP->RESERVA  := TMP->RESERVA + wPedRese
				TMP->ROMANEIO := TMP->ROMANEIO + wPedRom
				TMP->DISPONIV := TMP->DISPONIV + wSalDisp
			ENDIF

			aTotGera[1] := "TOTAL GERAL    "
			aTotGera[2] := SPACE(33)
			aTotGera[3] := aTotGera[3] + 0
			aTotGera[4] := SB1->B1_UM
			aTotGera[5] := aTotGera[5] + wPedPend
			aTotGera[6] := aTotGera[6] + wPedRese
			aTotGera[7] := aTotGera[7] + wSalDisp
			aTotGera[8] := aTotGera[8] + wPedRom
		ENDIF

		DbSelectArea("A004")
		A004->(DBSKIP())
	ENDDO

	A0005 := " SELECT C0_FILIAL, C0_PRODUTO, C0_LOCAL, C0_NUM, C0_YPEDIDO, C0_LOTECTL "
	A0005 += " FROM "+RetSqlName("SC0")+" SC0 "
	A0005 += " WHERE C0_FILIAL = '"+xFilial("SC0")+"' "
	A0005 += " AND C0_PRODUTO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	A0005 += " AND SC0.D_E_L_E_T_ = ' ' "
	If chkfile("A005")
		dbSelectArea("A005")
		dbCloseArea()
	EndIf
	TcQuery A0005 New Alias "A005"

	dbSelectArea("A005")
	dbGoTop()
	ProcRegua(RecCount())

	While !Eof()

		wPedPend := 0
		wPedRese := 0
		wSalDisp := 0
		wPedVend := 0
		wPedEntr := 0
		wPedRom  := 0

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+A005->C0_PRODUTO)

		IF cTipo <> '4'
			IF SB1->B1_YCLASSE <> cTipo
				DBSELECTAREA("A005")
				A005->( DBSKIP() )
				LOOP
			ENDIF
		ENDIF

		If !Empty(A005->C0_YPEDIDO)
			DbSelectArea("SC5")
			DbSetOrder(1)
			DbSeek(xFilial("SC5")+A005->C0_YPEDIDO)
			//Verifica se existe o pedido de vendas existe realmente
			If A005->C0_YPEDIDO == SC5->C5_NUM
				DbSelectArea("A005")
				DbSkip()
				Loop
			EndIf
		EndIf

		DbSelectArea("SDC")
		DbSetOrder(1)
		DbSeek(xFilial("SDC")+A005->C0_PRODUTO+A005->C0_LOCAL+"SC0"+A005->C0_NUM,.T.)
		Do while .not. eof() .and. DC_FILIAL == xFilial("SDC") .and. SDC->DC_PRODUTO == A005->C0_PRODUTO ;
		.and. SDC->DC_LOCAL == A005->C0_LOCAL .and. SDC->DC_ORIGEM == "SC0" .and. SDC->DC_PEDIDO == A005->C0_NUM
			IF SDC->DC_LOTECTL <> A005->C0_LOTECTL
				DBSELECTAREA("SDC")
				SDC->(DbSkip())
				Loop
			ENDIF
			wPedRese += SDC->DC_QUANT
			DbSelectArea("SDC")
			DbSkip()
		EndDo

		//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		DbSelectArea("SB8")
		DbSetOrder(1)
		IF !DbSeek(xFilial("SB8")+A005->C0_PRODUTO)
			wPedPend   := (wPedVend - wPedEntr)
			wSalDisp   := (wPedPend + wPedRese) * (-1)

			wTotPend   := wTotPend + wPedPend
			wTotDisp   := wTotDisp + wSalDisp
			wTotRese   := wTotRese + wPedRese
			wTotRom    := wTotRom  + wPedRom

			DBSELECTAREA("TMP")
			IF !DbSeek(A005->C0_PRODUTO+A005->C0_LOTECTL)
				RecLock("TMP",.T.)
				TMP->PRODUTO  := A005->C0_PRODUTO
				TMP->LOTE     := A005->C0_LOTECTL
				TMP->DESC     := SUBS(SB1->B1_DESC,1,30)
				TMP->SALDO    := 0
				TMP->UM       := SB1->B1_UM
				TMP->PENDENTE := wPedPend
				TMP->RESERVA  := wPedRese
				TMP->ROMANEIO := wPedRom
				TMP->DISPONIV := wSalDisp
				MSUNLOCK()
			ELSE
				RecLock("TMP",.F.)
				TMP->PENDENTE := TMP->PENDENTE + wPedPend
				TMP->RESERVA  := TMP->RESERVA + wPedRese
				TMP->ROMANEIO := TMP->ROMANEIO + wPedRom
				TMP->DISPONIV := TMP->DISPONIV + wSalDisp
			ENDIF
			aTotGera[1] := "TOTAL GERAL    "
			aTotGera[2] := SPACE(33)
			aTotGera[3] := aTotGera[3] + 0
			aTotGera[4] := SB1->B1_UM
			aTotGera[5] := aTotGera[5] + wPedPend
			aTotGera[6] := aTotGera[6] + wPedRese
			aTotGera[7] := aTotGera[7] + wSalDisp
			aTotGera[8] := aTotGera[8] + wPedRom
		ENDIF

		DbSelectArea("A005")
		DbSkip()
	EndDo

RETURN

Static FUNCTION fImprime()

	Local  I

	PROCREGUA( TMP->(LASTREC()))

	DBSELECTAREA("TMP")
	DBGOTOP()

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+TMP->PRODUTO)
	cCodAnt    := SB1->B1_COD
	wPrimVez   := .T.
	wNomeLinha := ""
	wNomeClass := ""
	wNomeRefer := ""
	wOldClass  := SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE
	wOldRefer  := SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA
	wOldLinha  := SB1->B1_YFORMAT+SB1->B1_YFATOR+SUBSTR(SB1->B1_YLINHA,1,3)
	aTotClass  := {0,0,0,0,0}
	aTotRefer  := {0,0,0,0,0}
	aTotLinha  := {0,0,0,0,0}
	SETPRC(0,0)

	WHILE !TMP->(EOF())

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+TMP->PRODUTO)

		INCPROC("Produto Arq. Trabalho -> "+TMP->PRODUTO)

		// byPASSA OS PRODUTOS COM SALDO E QUANTIDADES EM PEDIDOS IGUAL A ZERO
		IF (TMP->SALDO + TMP->PENDENTE) == 0
			DBSELECTAREA("TMP")
			DBSKIP()
			LOOP
		ELSEIF wPrimVez
			wOldClass  := SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE
			wOldRefer  := SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA
			wOldLinha  := SB1->B1_YFORMAT+SB1->B1_YFATOR+SUBSTR(SB1->B1_YLINHA,1,3)
		ENDIF

		// IMPRIME CABE€ALHO
		IF li >= 68
			li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 2
		ENDIF

		// IMPRIME O NOME DA LINHA SE É A PRIMEIRA VEZ QUE PASSA POR AQUI
		IF wPrimVez
			// DEFINE SUBSTRING A SER IMPRESSA NO RELATàRIO
			DbSelectArea("ZZ7")
			DbSetOrder(1)
			DbSeek(xFilial("ZZ7")+SB1->B1_YLINHA+SB1->B1_YLINSEQ)
			wNomeLinha := ALLTRIM(ZZ7->ZZ7_DESC)

			@ li, 000 PSAY wNomeLinha
			li := li + 2
			wPrimVez   := .F.
			wNomeRefer := TMP->DESC
		ENDIF

		// IMPRIME O TOTAL DA CLASSE DOS PRODUTOS
		IF wOldClass # SUBS(TMP->PRODUTO,1,8)
			DbSelectArea("ZZ8")
			DbSetOrder(1)
			IF DbSeek(xFilial("ZZ8")+SUBSTR(wOldClass,8,1))
				wNomeClass := ALLTRIM(ZZ8->ZZ8_DESC)
			ELSE
				MsgStop("Classe: "+SUBSTR(cCodAnt,8,1)+"-"+SUBSTR(cCodAnt,1,8)+", nao programada para este programa: INC036")
			ENDIF

			wLinDeImp := "TOTAL CLASSE    "                                    + SPACE( 1 )
			wLinDeImp := wLinDeImp + wNomeClass 							   + SPACE(33 - LEN(wNomeClass))
			wLinDeImp := wLinDeImp + TRANS( aTotClass[1], "@E 999,999,999.99") + SPACE( 3 )
			wLinDeImp := wLinDeImp + TMP->UM 								   + SPACE( 1 )
			wLinDeImp := wLinDeImp + TRANS( aTotClass[2], "@E 999,999,999.99") + SPACE( 1 )
			wLinDeImp := wLinDeImp + TRANS( aTotClass[3], "@E 999,999,999.99") + SPACE( 1 )
			wLinDeImp := wLinDeImp + TRANS( aTotClass[5], "@E 999,999,999.99") + SPACE( 1 )
			wLinDeImp := wLinDeImp + TRANS( aTotClass[4], "@E 999,999,999.99") + SPACE( 1 )

			@ li, 000 PSAY wLinDeImp

			IF MV_PAR11 == 1
				li := li + 2
			ELSE
				li := li + 1
			ENDIF

			aTotClass[1] := 0
			aTotClass[2] := 0
			aTotClass[3] := 0
			aTotClass[4] := 0
			aTotClass[5] := 0
			wOldClass	 := SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE
		ENDIF

		// IMPRIME CABE€ALHO
		IF li >= 68
			li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
		ENDIF

		// IMPRIME O TOTAL DA REFERENCIA DOS PRODUTO
		IF wOldRefer # SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA

			wLinDeImp := "TOTAL REFERENCIA"                                    + SPACE( 1 )
			wLinDeImp := wLinDeImp + wNomeRefer 							   + SPACE(33 - LEN(wNomeRefer))
			wLinDeImp := wLinDeImp + TRANS( aTotRefer[1], "@E 999,999,999.99") + SPACE( 3 )
			wLinDeImp := wLinDeImp + TMP->UM 								   + SPACE( 1 )
			wLinDeImp := wLinDeImp + TRANS( aTotRefer[2], "@E 999,999,999.99") + SPACE( 1 )
			wLinDeImp := wLinDeImp + TRANS( aTotRefer[3], "@E 999,999,999.99") + SPACE( 1 )
			wLinDeImp := wLinDeImp + TRANS( aTotRefer[5], "@E 999,999,999.99") + SPACE( 1 )
			wLinDeImp := wLinDeImp + TRANS( aTotRefer[4], "@E 999,999,999.99") + SPACE( 1 )

			@ li, 000 PSAY Repli("-",limite)

			li := li + 1

			@ li, 000 PSAY wLinDeImp

			li := li + 1

			@ li, 000 PSAY Repli("-",limite)

			li := li + 2

			aTotRefer[1] := 0
			aTotRefer[2] := 0
			aTotRefer[3] := 0
			aTotRefer[4] := 0
			aTotRefer[5] := 0
			wOldRefer	 := SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA

			nBranco := 0
			FOR I := 1 TO LEN( RTRIM(TMP->DESC) )
				IF SUBS(TMP->DESC,I,1) == " "
					nBranco := nBranco + 1
				ENDIF
				IF nBranco == 2
					EXIT
				ENDIF
			NEXT

			wNomeRefer := TMP->DESC
		ENDIF

		// IMPRIME CABE€ALHO
		IF li >= 68
			li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
		ENDIF

		// IMPRIME O TOTAL DA LINHA DOS PRODUTO
		//IF wOldLinha #SB1->B1_YFORMAT+SB1->B1_YFATOR+SUBSTR(SB1->B1_YLINHA,1,3)
		/*
		IF wOldLinha #SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA

		//If SUBST(wOldLinha,4,3) == "027"
		//	wNomeLinha := "OVIEDO BISOTADO"
		//EndIf

		wLinDeImp := "TOTAL LINHA     "                                    + SPACE( 1 )
		wLinDeImp := wLinDeImp + wNomeLinha		   						   + SPACE(36 - LEN(wNomeLinha))
		wLinDeImp := wLinDeImp + TRANS( aTotLinha[1], "@E 999,999,999.99") + SPACE( 3 )
		wLinDeImp := wLinDeImp + TMP->UM 								   + SPACE( 1 )
		wLinDeImp := wLinDeImp + TRANS( aTotLinha[2], "@E 999,999,999.99") + SPACE( 1 )
		wLinDeImp := wLinDeImp + TRANS( aTotLinha[3], "@E 999,999,999.99") + SPACE( 1 )
		wLinDeImp := wLinDeImp + TRANS( aTotLinha[5], "@E 999,999,999.99") + SPACE( 1 )
		wLinDeImp := wLinDeImp + TRANS( aTotLinha[4], "@E 999,999,999.99") + SPACE( 1 )

		@ li, 000 PSAY Repli("-",limite)

		li := li + 1

		@ li, 000 PSAY wLinDeImp

		li := li + 1

		@ li, 000 PSAY Repli("-",limite)

		li := li + 2

		aTotLinha[1] := 0
		aTotLinha[2] := 0
		aTotLinha[3] := 0
		aTotLinha[4] := 0
		aTotLinha[5] := 0
		//wOldLinha	 := SB1->B1_YFORMAT+SB1->B1_YFATOR+SUBSTR(SB1->B1_YLINHA,1,3)
		wOldLinha	 := SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA

		// DEFINE SUBSTRING A SER IMPRESSA NO RELATàRIO
		wNomeLinha := SUBS( TMP->DESC, 1, AT( " ", TMP->DESC ) )

		li := li + 1

		//If SUBST(wOldLinha,4,3) == "027"
		//	wNomeLinha := "OVIEDO BISOTADO"
		//EndIf

		@ li, 000 PSAY wNomeLinha

		li := li + 2

		ENDIF
		*/

		//VERIFICA SE LOTE DO PRODUTO POSSUI RESTRICAO	
		nRestr	:= ""		
		cAliasTmp := GetNextAlias()
		BeginSql Alias cAliasTmp
			SELECT ZZ9_RESTRI FROM %Table:ZZ9% WHERE ZZ9_PRODUT = %Exp:Alltrim(TMP->PRODUTO)% AND ZZ9_LOTE = %Exp:Alltrim(TMP->LOTE)% AND ZZ9_RESTRI = '*' AND %NOTDEL%
		EndSql
		If !(cAliasTmp)->(EOF()) 
			nRestr :=(cAliasTmp)->ZZ9_RESTRI
		EndIf
		(cAliasTmp)->(dbCloseArea())

		nCompl := 10-Len(Substr(Alltrim(TMP->LOTE)+nRestr,1,10))

		// IMPRIME PRODUTO ( DETALHE )
		wLinDeImp := SUBSTR(TMP->PRODUTO,1,10)+Substr(Alltrim(TMP->LOTE)+nRestr,1,10)+Padr(" ",nCompl) //Alltrim(SUBSTR(TMP->LOTE,1,5))+nRestr
		wLinDeImp := wLinDeImp + SPACE(30)
		wLinDeImp := wLinDeImp + TRANS( TMP->SALDO		, "@E 999,999,999.99")	+ SPACE( 3 )
		wLinDeImp := wLinDeImp + TMP->UM 									 										+ SPACE( 1 )
		wLinDeImp := wLinDeImp + TRANS( TMP->PENDENTE, "@E 999,999,999.99")  + SPACE( 1 )
		wLinDeImp := wLinDeImp + TRANS( TMP->RESERVA , "@E 999,999,999.99")  + SPACE( 1 )
		wLinDeImp := wLinDeImp + TRANS( TMP->ROMANEIO, "@E 999,999,999.99")  + SPACE( 1 )
		wLinDeImp := wLinDeImp + TRANS( TMP->DISPONIV, "@E 999,999,999.99")  + SPACE( 1 )

		IF MV_PAR11 == 1
			@ li, 000 PSAY wLinDeImp
			li := li + 1
		ENDIF

		// ACUMULADORES
		aTotClass[1] := aTotClass[1] + TMP->SALDO
		aTotClass[2] := aTotClass[2] + TMP->PENDENTE
		aTotClass[3] := aTotClass[3] + TMP->RESERVA
		aTotClass[4] := aTotClass[4] + TMP->DISPONIV
		aTotClass[5] := aTotClass[5] + TMP->ROMANEIO

		aTotRefer[1] := aTotRefer[1] + TMP->SALDO
		aTotRefer[2] := aTotRefer[2] + TMP->PENDENTE
		aTotRefer[3] := aTotRefer[3] + TMP->RESERVA
		aTotRefer[4] := aTotRefer[4] + TMP->DISPONIV
		aTotRefer[5] := aTotRefer[5] + TMP->ROMANEIO

		aTotLinha[1] := aTotLinha[1] + TMP->SALDO
		aTotLinha[2] := aTotLinha[2] + TMP->PENDENTE
		aTotLinha[3] := aTotLinha[3] + TMP->RESERVA
		aTotLinha[4] := aTotLinha[4] + TMP->DISPONIV
		aTotLinha[5] := aTotLinha[5] + TMP->ROMANEIO

		// POSICIONA PRàXIMO REGISTRO
		cCodAnt := SB1->B1_COD

		DBSELECTAREA("TMP")
		TMP->( DBSKIP() )
	ENDDO

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+cCodAnt)

	// IMPRIME O TOTAL DA CLASSE DOS PRODUTOS
	DbSelectArea("ZZ8")
	DbSetOrder(1)
	IF DbSeek(xFilial("ZZ8")+SB1->B1_YCLASSE)
		wNomeClass := ALLTRIM(ZZ8->ZZ8_DESC)
	ELSE
		MsgStop("Classe: "+SB1->B1_YCLASSE+"-"+SB1->B1_COD+", nao programada para este programa: INC036")
	ENDIF

	wLinDeImp := "TOTAL CLASSE    "                                    + SPACE( 1 )
	wLinDeImp := wLinDeImp + wNomeClass 							   + SPACE(33 - LEN(wNomeClass))
	wLinDeImp := wLinDeImp + TRANS( aTotClass[1], "@E 999,999,999.99") + SPACE( 3 )
	wLinDeImp := wLinDeImp + TMP->UM 								   + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotClass[2], "@E 999,999,999.99") + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotClass[3], "@E 999,999,999.99") + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotClass[5], "@E 999,999,999.99") + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotClass[4], "@E 999,999,999.99") + SPACE( 1 )

	@ li, 000 PSAY wLinDeImp

	IF MV_PAR11 == 1
		li := li + 2
	ELSE
		li := li + 1
	ENDIF

	// IMPRIME CABE€ALHO
	IF li >= 68
		li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
	ENDIF

	wLinDeImp := "TOTAL REFERENCIA"                                    + SPACE( 1 )
	wLinDeImp := wLinDeImp + wNomeRefer 							   + SPACE(33 - LEN(wNomeRefer))
	wLinDeImp := wLinDeImp + TRANS( aTotRefer[1], "@E 999,999,999.99") + SPACE( 3 )
	wLinDeImp := wLinDeImp + TMP->UM 								   + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotRefer[2], "@E 999,999,999.99") + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotRefer[3], "@E 999,999,999.99") + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotRefer[5], "@E 999,999,999.99") + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotRefer[4], "@E 999,999,999.99") + SPACE( 1 )

	@ li, 000 PSAY Repli("-",limite)

	li := li + 1

	@ li, 000 PSAY wLinDeImp

	li := li + 1

	@ li, 000 PSAY Repli("-",limite)

	li := li + 2

	// IMPRIME CABE€ALHO
	IF li >= 68
		li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
	ENDIF

	wLinDeImp := "TOTAL LINHA     "                                    + SPACE( 1 )
	wLinDeImp := wLinDeImp + wNomeLinha 						 	   + SPACE(33 - LEN(wNomeLinha))
	wLinDeImp := wLinDeImp + TRANS( aTotLinha[1], "@E 999,999,999.99") + SPACE( 3 )
	wLinDeImp := wLinDeImp + TMP->UM 								   + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotLinha[2], "@E 999,999,999.99") + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotLinha[3], "@E 999,999,999.99") + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotLinha[5], "@E 999,999,999.99") + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotLinha[4], "@E 999,999,999.99") + SPACE( 1 )

	@ li, 000 PSAY Repli("-",limite)
	li := li + 1
	@ li, 000 PSAY wLinDeImp
	li := li + 1
	@ li, 000 PSAY Repli("-",limite)
	li := li + 2

	// IMPRIME CABE€ALHO
	If li >= 68
		li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 1
	Endif

	// IMPRIME TOTAL GERAL
	wLinDeImp := aTotGera[1]										  + SPACE( 2 )
	wLinDeImp := wLinDeImp + SPACE(28)								  + SPACE( 8 )
	wLinDeImp := wLinDeImp + TRANS( aTotGera[3], "@E 999,999,999.99") + SPACE( 3 )
	wLinDeImp := wLinDeImp + aTotGera[4]							  + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotGera[5], "@E 999,999,999.99") + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotGera[6], "@E 999,999,999.99") + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotGera[8], "@E 999,999,999.99") + SPACE( 1 )
	wLinDeImp := wLinDeImp + TRANS( aTotGera[7], "@E 999,999,999.99") + SPACE( 1 )

	@ li, 000 PSAY Repli("-",limite)
	li := li + 1
	@ li, 000 PSAY wLinDeImp
	li := li + 1
	@ li, 000 PSAY Repli("-",limite)
	li := li + 2
RETURN
