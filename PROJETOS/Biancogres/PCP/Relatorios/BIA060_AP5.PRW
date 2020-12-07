#include "rwmake.ch"
#INCLUDE "topconn.ch"

#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BIA060_AP5ºAutor  ³Microsiga           º Data ³  11/09/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relacao de Producao                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Fatauramento/Estoque                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BIA060()

	Local nI

	SetPrvt("CDESC1,CDESC2,CDESC3,TAMANHO,LIMITE,CSTRING")
	SetPrvt("TITULO,ARETURN,NOMEPROG,NLASTKEY,WNUMBER,CBCONT")
	SetPrvt("CPERG,WNREL,CABEC1,CABEC2,C15,CBTXT")
	SetPrvt("LI,M_PAG,WDATADE,WDATAATE,WPRODDE,WPRODATE")
	SetPrvt("CMASCARA,NI,_ACAMPOS,_CTRAB,_cTrb,WOLDCLAS")
	SetPrvt("WOLDCOR,WOLDLINE,WOLDNOME,WOLDPROD,ACLASSE,ACORES")
	SetPrvt("ALINHA,ACLASSEA,ACLASSEC,ACLASSED,ATOTGER,WPRIMVEZ")
	SetPrvt("WNOMELINHA,WICLASSE,WPOSICAO,WICORES,WILINHA,WIDETALHE")
	SetPrvt("WSEXISTE,OLDDATA,WINCREMEN,WITGERAL,OLDAREA,CHA_PESQ")
	SetPrvt("OLDFORMATO,_SALIAS,AREGS,I,J,CMARCA,")

	//Programa	: BIA060
	//Autor		: Cesar Magnago
	//Data		: 04/10/99
	//Descricao : Relacao de Producao de Produtos Acabados
	//Uso 		: SIGAEST

	//Inicializa variaveis
	cDesc1	  := "Este programa tem como objetivo emitir um relatorio das"
	cDesc2	  := "Vendas por Produto"
	cDesc3	  := ""
	tamanho	  := "M"
	limite	  := 132
	cString	  := "SD3"
	titulo	  := "RELACAO DE PRODUCAO DOS PRODUTOS ACABADOS"
	aReturn	  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	nomeprog   := "BIA060"
	nLastKey   := wNumber := cbcont := 0
	cPerg 	  := "BIA060"
	wnrel 	  := "BIA060"
	Cabec1	  := "CODIGO         DESCRICAO DO PRODUTO             QTD   M2    QTD   CX      DATA     DOCUM.      LOCALIZACAO       FATOR CONV."
	Cabec2	  := "                                                PRODUZIDA    PRODUZIDA  MOVIMENTO                                                    "
	// 					XXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXX.XXX,XX	 XXX.XXX,XX   XX/XX/XX	 XXXXXX
	// 					0			  12										43 			 56			  69			 80
	C15		  := 15
	cbtxt 	  := space(10)
	li 		  := 80
	m_pag 	  := 1


	//Envia controle para a funcao SETPRINT
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)

	//fValidPerg()
	PERGUNTE( cPerg, .F. )

	If ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
		Return
	Endif

	wDataDe	 := mv_par03
	wDataAte := mv_par04
	wProdDe	 := mv_par01
	wProdAte := mv_par02

	//Determina a variavel de mascara.
	cMascara := ""
	for nI:=1 to len(mv_par05)
		cMascara := cMascara + iif(SubStr(mv_par05,nI,1)#"*","X","*")
	next

	//Verifica Posicao do Formulario na Impressora
	SetDefault(aReturn,cString)

	If ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
		Return
	Endif

	// Monta arquivo de trabalho
	Processa( {|| fMonta_Arq() } )// Substituido pelo assistente de conversao do AP5 IDE em 25/04/01 ==> 	Processa( {|| Execute(fMonta_Arq) } )

	// LE MOVIMENTACOES INTENAS
	Processa( {|| fLe_SD3() } )// Substituido pelo assistente de conversao do AP5 IDE em 25/04/01 ==> 	Processa( {|| Execute(fLe_SD3) } )

	// IMPRIME RELATORIO
	Processa( {|| fImpressao() } )// Substituido pelo assistente de conversao do AP5 IDE em 25/04/01 ==> 	Processa( {|| Execute(fImpressao) } )

	//RODAPE
	Roda(cbcont,cbtxt,tamanho)

	//APAGA ARQUIVO DE TRABALHO
	DbSelectArea("_cTrab")
	DBCLOSEAREA()

	If File(_cTrab+".DBF")
		Ferase(_cTrab+".DBF")
		Ferase(_cTrab+".cdx")
	Endif

	//APAGA ARQUIVO DE TRABALHO
	DbSelectArea("_cTrb")
	DBCLOSEAREA()

	If File(_cTrb+".DBF")
		Ferase(_cTrb+".DBF")
		Ferase(_cTrb+".cdx")
	Endif

	//LIBERA IMPRESSAO
	If aReturn[5] == 1
		Set Printer To
		Ourspool(wnrel)
	Endif

	MS_FLUSH()

	//FIM DO PROGRAMA

RETURN( NIL )

//Descricao   : Monta arquivo de trabalho
Static FUNCTION fMonta_Arq()

	If chkfile("_cTrab")
		DbSelectArea("_cTrab")
		DbCloseArea()
	EndIf

	_aCampos := { {"PRODUTO ","C",20, 0},;
	{"NOMEPROD","C",30, 0},;
	{"QTDPROD ","N",11, 2},;
	{"DTMOV   ","D",08, 0},;
	{"DOCTO   ","C",09, 0},; // 10 BRUNOMADALENO
	{"QTDCX   ","N",12, 2},;
	{"FATCONV ","N",06, 2},;
	{"LOCALIZ ","C",10, 0},;
	{"LOTE    ","C",10, 0} }
	_cTrab := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,,_cTrab,"_cTrab")
	DbCreateInd(_cTrab,"PRODUTO+LOTE",{||PRODUTO+LOTE})

	If chkfile("_cTrb")
		DbSelectArea("_cTrb")
		DbCloseArea()
	EndIf

	_aCampos := { {"PRODUTO ","C",20, 0},;
	{"NOMEPROD","C",30, 0},;
	{"QTDPROD ","N",11, 2},;
	{"DTMOV   ","D",08, 0},;
	{"DOCTO   ","C",09, 0},; // // 10 BRUNOMADALENO
	{"QTDCX   ","N",12, 2},;
	{"FATCONV ","N",06, 2},;
	{"LOCALIZ ","C",10, 0},;
	{"LOTE    ","C",10, 0} }
	_cTrb := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,,_cTrb,"_cTrb")
	DbCreateInd(_cTrb,"PRODUTO",{||PRODUTO})

RETURN( NIL )

//Descricao : Emite relatorio
Static FUNCTION fImpressao()

	If !wsExiste
		MsgAlert("Nao Existe Movimento para este(s) produtos...")
		Return
	EndIf

	dbSelectArea("_cTrab")
	dbGoTop()

	//Monta regua
	ProcRegua( _cTrab->( LastRec() ) )

	//Inicializa variaveis normais e de quebra
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+_cTrab->PRODUTO)

	wOldClas   := SB1->B1_YCLASSE
	wOldCor	   := SUBSTR(SB1->B1_YLINHA,4,1)
	wOldLine   := SUBSTR(SB1->B1_YLINHA,1,3)
	wOldNome   := _cTrab->NOMEPROD
	wOldProd   := _cTrab->PRODUTO
	wNomeLinha := SPACE(1)
	aClasse	   := {0,0,0,0,0,0,0}
	aCores	   := {0,0,0,0,0,0,0}
	aLinha	   := {0,0,0,0,0,0,0}
	aClasseA   := {0,0,0,0,0,0,0}
	aClasseC   := {0,0,0,0,0,0,0}
	aClasseD   := {0,0,0,0,0,0,0}
	aTotGer	   := {0,0,0,0,0,0,0}
	wPrimVez   := .T.
	cMarca     := ' '

	DbSelectArea("_cTrab")
	//Processa arquivo de trabalho
	While !EOF()
		//Incrementa regua
		IncProc()

		If li >= 62
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		Endif

		// IMPRIME O NOME DA LINHA SE E A PRIMEIRA VEZ QUE PASSA POR AQUI
		IF wPrimVez

			// DEFINE SUBSTRING A SER IMPRESSA NO RELATORIO
			IF "OVIEDO BISOTADO" $ _cTrab->NOMEPROD
				wNomeLinha := "OVIEDO BISOTADO"
				wNomeLinha := wNomeLinha + SPACE(30 - LEN(wNomeLinha))
			ELSE
				wNomeLinha := SUBS( _cTrab->NOMEPROD, 1, AT( " ", _cTrab->NOMEPROD ) )
				wNomeLinha := wNomeLinha + SPACE(30 - LEN(wNomeLinha))
			ENDIF

			IF "SAN " $ _cTrab->NOMEPROD
				wNomeLinha := "SAN MARINO"
				wNomeLinha := wNomeLinha + SPACE(30 - LEN(wNomeLinha))
			ENDIF

			@ li, 000 PSAY wNomeLinha

			li := li + 1

			wPrimVez   := .F.
		ENDIF

		//Quebra de Classe
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+_cTrab->PRODUTO)
		cProduto := SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE

		IF SB1->B1_YCLASSE            # wOldClas .OR.;
		SUBSTR(SB1->B1_YLINHA,4,1) # wOldCor  .OR.;
		SUBSTR(SB1->B1_YLINHA,1,3) # wOldLine

			DbSelectArea("ZZ8")
			DbSeek(xFilial("ZZ8")+wOldClas)

			wOldClas := ALLTRIM(ZZ8->ZZ8_DESC)
			wIClasse := "TOTAL CLASSE  " + wOldClas  + Space(31 - LEN(wOldClas))
			wIClasse := wIClasse + Tran( aClasse[1], "@E 9,999,999.99"      ) + Space(03)
			wIClasse := wIClasse + Tran( aClasse[2], "@E 9,999,999.99"      )

			li := li + 1

			@ li,000 PSAY wIClasse

			li := li + 1

			aClasse	:= {0,0,0,0,0,0,0}
			wOldClas := SB1->B1_YCLASSE
		EndIf

		//Quebra de Cores
		If SUBSTR(SB1->B1_YLINHA,4,1) #wOldCor .OR.;
		SUBSTR(SB1->B1_YLINHA,1,3) #wOldLine

			DbSelectArea("ZZ6")
			DbSeek(xFilial("ZZ6")+SB1->B1_YFORMAT)

			///*IF RAT(ALLTRIM(ZZ6->ZZ6_DESC), wOldNome ) > 0
			//	wPosicao := RAT(ALLTRIM(ZZ6->ZZ6_DESC), wOldNome ) + 5
			//ELSE
			//	wPosicao := 0
			//ENDIF*/

			If Subs(wOldNome,Len(Alltrim(wOldNome))-2,3) == "B/C"
				nVar := 3
			ElseIf Alltrim(wOldNome) == "CACO CERAMICO"
				nVar := 0
			Else
				nVar := 1
			EndIf

			wOldNome := Subs(wOldNome,1,Len(Alltrim(wOldNome))-nVar ) //IF( wPosicao > 0, SUBS( wOldNome, 1, wPosicao ), "OUTROS FORMATOS " )
			wICores  := "TOTAL REFER.  " + SUBS(wOldNome,1,27) + Space(31 - LEN(wOldNome))
			wICores  := wICores + Tran( aCores[1], "@E 9,999,999.99"      ) + Space(03)
			wICores	 := wICores + Tran( aCores[2], "@E 9,999,999.99"      )

			li := li + 1

			@ li,000 PSAY wICores

			li := li + 1

			aCores	:= {0,0,0,0,0,0,0}
			wOldCor	:= SUBSTR(SB1->B1_YLINHA,4,1)
		EndIf

		//Quebra de Linha
		If SUBSTR(SB1->B1_YLINHA,1,3) #wOldLine

			wILinha	:= "TOTAL LINHA   " + SUBS(wNomeLinha,1,30)         + Space(01)
			wILinha	:= wILinha + Tran( aLinha[1], "@E 9,999,999.99"     ) + Space(03)
			wILinha	:= wILinha + Tran( aLinha[2], "@E 9,999,999.99"     )

			li := li + 1

			@ li,000 PSAY wILinha

			li := li + 1

			@ li,000 PSAY Replicate( "-", Limite )

			aLinha	:= {0,0,0,0,0,0,0}
			wOldLine := SUBSTR(SB1->B1_YLINHA,1,3)

			// DEFINE SUBSTRING A SER IMPRESSA NO RELATORIO
			IF "OVIEDO BISOTADO" $ _cTrab->NOMEPROD
				wNomeLinha := "OVIEDO BISOTADO"
				wNomeLinha := wNomeLinha + SPACE(30 - LEN(wNomeLinha))
			ELSE
				wNomeLinha := SUBS( _cTrab->NOMEPROD, 1, AT( " ", _cTrab->NOMEPROD ) )
				wNomeLinha := wNomeLinha + SPACE(30 - LEN(wNomeLinha))
			ENDIF

			IF "SAN " $ _cTrab->NOMEPROD
				wNomeLinha := "SAN MARINO"
				wNomeLinha := wNomeLinha + SPACE(30 - LEN(wNomeLinha))
			ENDIF

			li := li + 1

			IF li+3 >= 62
				Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
			ENDIF

			@ li, 000 PSAY wNomeLinha

			li := li + 1
		EndIf

		fAcumula()

		fGravaRes()

		//IMPRIME DETALHES ( PRODUTO / PRECO )
		DbSelectArea("SG1")
		DbSetOrder(1)
		DbSeek(xFilial("SG1")+SUBSTR(cProduto,1,7),.T.)
		IF SUBSTR(cProduto,1,7) == SUBSTR(SG1->G1_COD,1,7)
			cMarca := ' '
		ELSE
			cMarca := '*'
		ENDIF

		wIDetalhe := SUBS(cProduto,1,8)+SUBS(_cTrab->LOTE,1,5)	        		+ Space(01)
		wIDetalhe := wIDetalhe + cMarca+_cTrab->NOMEPROD					    + Space(01)
		wIDetalhe := wIDetalhe + Tran( _cTrab->QTDPROD	, "@E 9,999,999.99"     ) + Space(03)
		wIDetalhe := wIDetalhe + Tran( _cTrab->QTDCX 	, "@E 9,999,999.99"     ) + Space(03)
		wIDetalhe := wIDetalhe + Tran( _cTrab->DTMOV 	, "@D"                ) + Space(03)
		wIDetalhe := wIDetalhe + _cTrab->DOCTO + Space(10)
		wIDetalhe := wIDetalhe + _cTrab->LOCALIZ + Space(05)
		wIDetalhe := wIDetalhe + Tran( _cTrab->FATCONV	, "@E 999.99" )

		li := li + 1

		@ li,000 PSAY wIDetalhe

		wOldNome := _cTrab->NOMEPROD
		wOldProd := cProduto

		DbSelectArea("_cTrab")
		DbSkip()
	EndDo

	If li >= 62
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif

	fImpRes()

RETURN( NIL )

// REGRAVA PRODUTOS DA MOVIMENTACAO INTERNA
Static FUNCTION fLe_SD3()

	ProcRegua( IIF( ( wDataDe	- wDataAte) == 0, 1, (wDataAte  - wDataDe) ) )

	wsExiste := .F.
	DbSelectArea("SD3")
	DbSetOrder(6)
	DbSeek(xFilial("SD3")+Dtos(wDataDe),.T.)
	OldData :=	wDataDe

	While !Eof() .and. (SD3->D3_EMISSAO <= wDataAte)

		wIncremen := SD3->D3_EMISSAO - OldData

		If ( wIncremen > 0 )
			IncProc( wIncremen )
		EndIf

		// Por Marcos Alberto Soprani em 18/04/12 atendendo o novo tratamento de apontamento de Produção/Apuração de Custo.
		//If AllTrim(SD3->D3_TM) <> "500" .AND. AllTrim(SD3->D3_TM) <> "501"
		If AllTrim(SD3->D3_TM) <> "500" .and. AllTrim(SD3->D3_TM) <> "501"
			If SD3->D3_YORIMOV <> "PR0"
				DbSelectArea("SD3")
				DbSkip()
				Loop
			EndIf
		Endif

		If AllTrim(SD3->D3_ESTORNO) == "S"
			DbSelectArea("SD3")
			DbSkip()
			Loop
		Endif

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFILIAL("SB1")+SD3->D3_COD, .F. )
		cProduto := SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA+SB1->B1_YCLASSE

		If AllTrim(SB1->B1_TIPO) <> "PA"
			DbSelectArea("SD3")
			DbSkip()
			Loop
		Endif

		If SUBST(cProduto,8,1) == " "
			DbSelectArea("SD3")
			DbSkip()
			Loop
		Endif

		If SD3->D3_COD < MV_PAR01
			DbSelectArea("SD3")
			DbSkip()
			Loop
		Endif

		If SD3->D3_COD > MV_PAR02
			DbSelectArea("SD3")
			DbSkip()
			Loop
		Endif

		// VERIFICA SE O PRODUTO PERTENCE A MASCARA DETERMINADA
		If Upper(Transform(cProduto,cMascara)) #Upper(MV_PAR05)
			DbSelectArea("SD3")
			DbSkip()
			Loop
		endif

		// Procura a Localizacao do Produto
		cQuery := ""
		cQuery += "	SELECT	* "
		cQuery += "	FROM " + RetSqlName("SDB") + " SDB "
		cQuery += "	WHERE	DB_ESTORNO	<>	'S' AND  "
		cQuery += "			DB_DOC		=	'"+SD3->D3_DOC+"'	AND "
		cQuery += "			DB_PRODUTO	=	'"+SD3->D3_COD+"'	AND "
		cQuery += "			DB_LOCAL	=	'"+SD3->D3_LOCAL+"'	AND "
		cQuery += "			DB_NUMSEQ	=	'"+SD3->D3_NUMSEQ+"' "
		If chkfile("_SDB")
			DbSelectArea("_SDB")
			DbCloseArea()
		EndIf
		TCQUERY cQuery NEW ALIAS "_SDB"

		DbSelectArea("_cTrab")

		RecLock("_cTrab", .T. )
		_cTrab->PRODUTO		:= cProduto
		_cTrab->NOMEPROD	:= SB1->B1_DESC
		IF AllTrim(SD3->D3_TM) <= '500'
			_cTrab->QTDPROD		:= SD3->D3_QUANT
			_cTrab->QTDCX			:= SD3->D3_QTSEGUM
		ELSE
			_cTrab->QTDPROD		:= SD3->D3_QUANT 	 * (-1)
			_cTrab->QTDCX			:= SD3->D3_QTSEGUM * (-1)
		ENDIF
		_cTrab->DTMOV			:= SD3->D3_EMISSAO
		_cTrab->DOCTO			:= SD3->D3_DOC
		_cTrab->FATCONV		:= SB1->B1_CONV
		_cTrab->LOCALIZ		:= _SDB->DB_LOCALIZ
		_cTrab->LOTE			:= SD3->D3_LOTECTL
		wsExiste					:= .T.
		MsUnLock()
		DbCommit()

		OldData := SD3->D3_EMISSAO

		DbSelectArea("SD3")
		DbSkip()

	EndDo

	IncProc()

Return( Nil )

// ACUMULA VALORES PARA SEREM IMPRESSOS
Static FUNCTION fAcumula()

	//Acumula TOTAL DA CLASSE por quebra
	aClasse[1] := aClasse[1] + _cTrab->QTDPROD
	aClasse[2] := aClasse[2] + _cTrab->QTDCX

	//Acumula TOTAL DO PRODUTO (cores) por quebra
	aCores[1] := aCores[1] + _cTrab->QTDPROD
	aCores[2] := aCores[2] + _cTrab->QTDCX

	//Acumula TOTAL DA LINHA por quebra
	aLinha[1] := aLinha[1] + _cTrab->QTDPROD
	aLinha[2] := aLinha[2] + _cTrab->QTDCX

	//Acumula TOTAL GERAL DA CLASSE A
	IF SB1->B1_YCLASSE == "1"
		aClasseA[1] := aClasseA[1] + _cTrab->QTDPROD
		aClasseA[2] := aClasseA[2] + _cTrab->QTDCX
	ENDIF

	//Acumula TOTAL GERAL DA CLASSE C
	IF SB1->B1_YCLASSE == "2"
		aClasseC[1] := aClasseC[1] + _cTrab->QTDPROD
		aClasseC[2] := aClasseC[2] + _cTrab->QTDCX
	ENDIF

	//Acumula TOTAL GERAL DA CLASSE D
	IF SB1->B1_YCLASSE >= "3"
		aClasseD[1] := aClasseD[1] + _cTrab->QTDPROD
		aClasseD[2] := aClasseD[2] + _cTrab->QTDCX
	ENDIF

	//Acumula TOTAL GERAL
	aTotGer[1] := aTotGer[1] + _cTrab->QTDPROD
	aTotGer[2] := aTotGer[2] + _cTrab->QTDCX

Return( Nil )

// IMPRIME AS ULTIMAS QUEBRAS DO RELATORIO E EM SEGUIDA FAZ UM RESUMO DOS VALORES
Static FUNCTION fImpRes()
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+wOldProd)

	DbSelectArea("ZZ8")
	DbSetOrder(1)
	DbSeek(xFilial("ZZ8")+SB1->B1_YCLASSE)

	//Quebra de Classe
	wOldClas := ALLTRIM(ZZ8->ZZ8_DESC)
	wIClasse := "TOTAL CLASSE  " + wOldClas  + Space(31 - LEN(wOldClas))
	wIClasse := wIClasse + Tran( aClasse[1], "@E 9,999,999.99"     ) + Space(03)
	wIClasse := wIClasse + Tran( aClasse[2], "@E 9,999,999.99"     )

	li := li + 1
	@ li,000 PSAY wIClasse

	li := li + 1

	//Quebra de CORES
	DbSelectArea("ZZ6")
	DbSeek(xFilial("ZZ6")+SB1->B1_YFORMAT)

	///*IF RAT(ALLTRIM(ZZ6->ZZ6_DESC), wOldNome ) > 0
	// 	wPosicao := RAT(ALLTRIM(ZZ6->ZZ6_DESC), wOldNome ) + 5
	//ELSE
	//	wPosicao := 0
	//ENDIF*/

	If Subs(wOldNome,Len(Alltrim(wOldNome))-2,3) == "B/C"
		nVar := 3
	ElseIf Alltrim(wOldNome) == "CACO CERAMICO"
		nVar := 0
	Else
		nVar := 1
	EndIf

	wOldNome := Subs(wOldNome,1,Len(Alltrim(wOldNome))-nVar ) //IF( wPosicao > 0,SUBS( wOldNome, 1, wPosicao ), "OUTROS FORMATOS " )
	wICores	 := "TOTAL REFER.  " + SUBST(wOldNome,1,27) + Space(31 - LEN(wOldNome))
	wICores	 := wICores + Tran( aCores[1], "@E 9,999,999.99"     ) + Space(03)
	wICores	 := wICores + Tran( aCores[2], "@E 9,999,999.99"     )

	li := li + 1

	@ li,000 PSAY wICores

	li := li + 1

	//Quebra de LINHA
	wILinha	:= "TOTAL LINHA   " + SUBS(wNomeLinha,1,30)         + Space(01)
	wILinha	:= wILinha + Tran( aLinha[1], "@E 9,999,999.99"     ) + Space(03)
	wILinha	:= wILinha + Tran( aLinha[2], "@E 9,999,999.99"     )

	li := li + 1
	@ li,000 PSAY wILinha

	li := li + 1
	@ li,000 PSAY Replicate( "-", Limite )

	fImpFormat()

	li := li + 1
	@ li,000 PSAY Replicate( "-", Limite )

	//Quebra de Classe A

	wIClasse := 'TOTAL CLASSE  "A"'                                 + Space(28)
	wIClasse := wIClasse + Tran( aClasseA[1], "@E 9,999,999.99"     ) + Space(03)
	wIClasse := wIClasse + Tran( aClasseA[2], "@E 9,999,999.99"     )

	li := li + 1
	@ li,000 PSAY wIClasse

	//Quebra de Classe C
	wIClasse := 'TOTAL CLASSE  "C"'                                 + Space(28)
	wIClasse := wIClasse + Tran( aClasseC[1], "@E 9,999,999.99"     ) + Space(03)
	wIClasse := wIClasse + Tran( aClasseC[2], "@E 9,999,999.99"     )

	li := li + 1
	@ li,000 PSAY wIClasse

	//Quebra de Classe D
	wIClasse := 'TOTAL CLASSE  "D"'                                 + SPACE(28)
	wIClasse := wIClasse + Tran( aClasseD[1], "@E 9,999,999.99"     ) + Space(03)
	wIClasse := wIClasse + Tran( aClasseD[2], "@E 9,999,999.99"     )

	li := li + 1
	@ li,000 PSAY wIClasse

	//TOTAL GERAL
	wITGeral := "TOTAL GERAL     "                                 + SPACE(29)
	wITGeral := wITGeral + Tran( aTotGer[1], "@E 9,999,999.99"     ) + Space(03)
	wITGeral := wITGeral + Tran( aTotGer[2], "@E 9,999,999.99"     )

	li := li + 1

	@ li,000 PSAY wITGeral

	li := li + 1
	@ li,000 PSAY Replicate( "-", Limite )

Return( Nil )

// Substituido pelo assistente de conversao do AP5 IDE em 25/04/01 ==> FUNCTION fGravaRes
Static FUNCTION fGravaRes()

	OLDAREA	 := ALIAS()

	DbSelectArea("SB1")
	DbSeek(xFilial("SB1")+_cTrab->PRODUTO)

	DbSelectArea("ZZ6")
	DbSeek(xFilial("ZZ6")+SB1->B1_YFORMAT)

	DbSelectArea("ZZ8")
	DbSeek(xFilial("ZZ8")+SB1->B1_YCLASSE)
	Cha_Pesq := ALLTRIM(ZZ6->ZZ6_DESC)+ALLTRIM(ZZ8->ZZ8_DESC)

	DBSELECTAREA("_cTrb")
	DBSETORDER(1)

	//Cha_Pesq := Subs(Cha_Pesq,1,15) // Inserido por Edson Junior //DESATIVADO POR RANISSES

	RECLOCK( "_cTrb", ! DBSEEK( Cha_Pesq, .F. ) )

	_cTrb->PRODUTO	:= Cha_Pesq
	_cTrb->NOMEPROD	:= _ctrab->NOMEPROD
	_cTrb->QTDPROD	:= _cTrb->QTDPROD  + _cTrab->QTDPROD
	_cTrb->DTMOV	:= _cTrb->DTMOV
	_cTrb->DOCTO	:= _cTrb->DOCTO
	_cTrb->QTDCX	:= _cTrb->QTDCX	  + _cTrab->QTDCX
	_cTrb->LOCALIZ	:= _cTrb->LOCALIZ
	_cTrb->LOTE  	:= _cTrb->LOTE

	MSUNLOCK()
	DBSELECTAREA(OLDAREA)

RETURN( NIL )

// Substituido pelo assistente de conversao do AP5 IDE em 25/04/01 ==> FUNCTION fImpFormat
Static FUNCTION fImpFormat()

	DBSELECTAREA("_cTrb")
	DBGOTOP()

	OLDFORMATO := ""

	//MONTA REGUA
	ProcRegua( _cTrab->( LastRec() ) )
	li := li + 1
	@ li,000 PSAY "R E S U M O"

	WHILE !EOF()

		INCPROC()

		If li >= 62
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		Endif

		IF Subs(_cTrb->PRODUTO,1,Len(Alltrim(_cTrb->PRODUTO))-1 ) <> OLDFORMATO
			li := li + 2
			@ li,000 PSAY "FORMATO " + Subs(_cTrb->PRODUTO,1,Len(Alltrim(_cTrb->PRODUTO))-1 )
		ENDIF

		wIDetalhe := "CLASSE= " + RIGHT(RTRIM(_cTrb->PRODUTO),1) + SPACE(37)
		wIDetalhe := wIDetalhe + Tran( _cTrb->QTDPROD	, "@E 9,999,999.99"     ) + Space(03)
		wIDetalhe := wIDetalhe + Tran( _cTrb->QTDCX 	, "@E 9,999,999.99"     )

		li := li + 1

		@ li,000 PSAY wIDetalhe

		OLDFORMATO := Subs(_cTrb->PRODUTO,1,Len(Alltrim(_cTrb->PRODUTO))-1 )

		DBSELECTAREA("_cTrb")
		DBSKIP()

	ENDDO

Return( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³VALIDPERG ³ Autor ³ Joao Carlos de Andrade³ Data ³ 12/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica as perguntas incluindo-as caso nao existam		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Especifico - Incesa										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 25/04/01 ==> Function fValidPerg
Static Function fValidPerg()

	Local j
	Local i

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(NomeProg,6)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRegs := {}
	AADD(aRegs,{cPerg,"05","Mascara            ?","mv_ch5","C",11,0,0,"G","NaoVazio","mv_par05","","","","","","","","","","","","","","",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				FieldPut(j,aRegs[i,j])
			Next
			MsUnlock()
			dbCommit()
		Endif
	Next

	dbSelectArea(_sAlias)
Return
