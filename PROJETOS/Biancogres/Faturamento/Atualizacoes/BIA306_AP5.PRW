#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
	#IFNDEF WINDOWS
		#DEFINE PSAY SAY
	#ENDIF

User Function Bia306()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CDESC1,CDESC2,CDESC3,TAMANHO,LIMITE,CSTRING")
SetPrvt("TITULO,ARETURN,NOMEPROG,NLASTKEY,WNUMBER,CBCONT")
SetPrvt("CPERG,WNREL,C15,CBTXT,LI,M_PAG")
SetPrvt("WDATADE,WDATAATE,WFORMATO,WMERCADO,WPRODE,WPROATE")
SetPrvt("CABEC1,CABEC2,BFATPM,BTGMETPM,BTGFATPM,BTGATIVO")
SetPrvt("BTGATIPM,BQUA_ACO,BQUA_SC6,BQUA_SD2,BASCANC6,BASCAND2")
SetPrvt("BPOSFOR,BATIVOL,BATIPM,BTAMREGUA,BDATA,ADIASEMANA")
SetPrvt("AFOR,ATOTAL,LCABEC,WESTADO,ACAMPOS,TAM_PAIS")
SetPrvt("TAM_NOME,cTrb,AFORMATO,BDESCFOR,BFORMATO,BDATAATE")
SetPrvt("BDATADE,BNOTNAOOK,BDEVOLU,BPRODUTO,BMERCADO,WQTDDEVOL")
SetPrvt("WVALDEVOL,WFAT_PM,WFAT_VOL,DATAREGUA,MFUNC,BEMISSAO")
SetPrvt("WMETAVOL,WMETAPM,BMESANO,WACUMMETA,NVEZES,IMPTXT")
SetPrvt("WINCREMEN,AFERIADO,XXI,DIASUTEIS,BDIAMES,BSABDOM")
SetPrvt("BULTDIAMES,BSOMA_A,BSOMA_B,")

*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Programa : BIA306
// Autor 	: AUGUSTO CESAR DE OLIVEIRA
// Data		: 11/06/2000 AS 19:18 a 22:15; 18:15 as 19:45; 19:30 a 21:10
// 								 20:10 a
// Descricao: Comparativo da evolucao do faturamento x objetivo
// Uso		: SIGAFAT
// FUNCOES	: fCriaArq()	-> Cria arquivo temporario
// 			  fTabFor() 	-> Cria matriz com os formatos/medidas dos pisos
// 			  fSeleDado()	-> Seleciona dados a serem impressos
// 			  fDevolu() 	-> Verifica e apropria as devolucoes de venda
// 			  FGrava()		-> Grava dados selecionados por fSeleDado()
// 			  fAcuMeta()	-> Acumula os valores meta
// 			  fImpRep() 	-> Imprime o relatorio ordenado e totalizado por representante
// 			  fImpDet() 	-> Imprime detalhes do relatorio
// 			  fImpResFin() -> Imprime o resumo final
*-------------------------------------------------------------------------------------------------------------------------------------------------------
	#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 		#DEFINE PSAY SAY
	#ENDIF
	//Inicializa variaveis
	cDesc1	 := "Este programa tem como objetivo emitir um relatorio do"
	cDesc2	 := "Comprativo da Evolucao do Faturamento x Objetivo"
	cDesc3	 := ""
	tamanho	 := "M"
	limite	 := 132
	cString	 := "SD2"
	titulo	 := "FATURAMENTO X OBJETIVO"
	aRETURN	 := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	nomeprog  := "BIA306"
	nLastKey  := wNumber := cbcont := 0
	cPerg 	 := "BIA306"
	wnrel 	 := "BIA306"
	C15		 := 15
	cbtxt 	 := space(10)
	li 		 := 80
	m_pag 	 := 1
	//Envia controle para a funcao SETPRINT
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)
	PERGUNTE( cPerg, .F. )
	IF ( nLastKey == 27 ) .OR. ( LastKey() == 27 ); RETURN; ENDIF
	//PARAMETROS DO RELATROIO
	//-----------------------
	wDataDe	 := mv_par01
	wDataAte  := mv_par02
	wFormato  := mv_par03
	wMercado  := mv_par04
	wProDe	 := mv_par05
	wProAte	 := mv_par06
	titulo	 := titulo + IIF(wMercado==1,"(Mercado: Interno)",;
					 IIF(wMercado==1,"(Mercado: Externo)","(Mercado: Interno e Externo)"))

	//INICIALIZACAO DE VARIAVEIS GLOBAIS
	//----------------------------------
	Cabec1	 := "|SOMENTE           |______________OBJETIVO_______________|_____________R__E__A__L______________|__________%_REAL_X_OJETIVO_________|"
	Cabec2	 := "|DIAS UTENS        |VOL(000 M2)|P.MEDIO R$|      VALOR R$|VOL(000 M2)|P.MEDIO R$|      VALOR R$|     VOLUME|PRC. MEDIO|      xxxxxx|"
	bFatPm	 := {||cTrb->FAT_PM / cTrb->FAT_VOL}
	bTgMetPm  := {||aTotal[2] / aTotal[1]}
	bTgFatPm  := {||aTotal[4] / aTotal[3]}
	bTgAtiVo  := {||ROUND((aTotal[3]/aTotal[1]) * 100, 2 )}
	bTgAtiPm  := {||ROUND((aTotal[4]/aTotal[2]) * 100, 2 )}
// bTgAtiVo  := {||ROUND(((aTotal[3]-aTotal[1])/aTotal[3]) * 100, 2 )}
// bTgAtiPm  := {||ROUND(((aTotal[4]-aTotal[2])/aTotal[4]) * 100, 2 )}
	bQua_aco  := {||LEFT(cTrb->QUALIDA,1)+SUBS(cTrb->QUALIDA,2,1)}
	bQua_SC6  := {||LEFT(SC6->C6_PRODUTO,1)+SUBS(SC6->C6_PRODUTO,6,1)}
	bQua_SD2  := {||LEFT(SD2->D2_COD,1)+SUBS(SD2->D2_COD,6,1)}
	bAscanC6  := 'ASCAN( aFormato, { |X| X[1] == EVAL(bQua_SC6)})'
	bAscanD2  := 'ASCAN( aFormato, { |X| X[1] == EVAL(bQua_SD2)})'
	bPosFor	 := {|x| IIF( x=="F2", &bAscanD2, &bAscanC6 ) }
	bAtiVol	 := {||ROUND(cTrb->FAT_VOL / cTrb->MET_VOL * 100,2)}
	bAtiPm	 := {||ROUND((cTrb->FAT_PM/cTrb->FAT_VOL)/cTrb->MET_PM * 100,2)}
	bTamRegua := {||((wDataAte+1)  - wDataDe) }
	bData 	 := {|x|DTOS(IIF(x=="F2",SD2->D2_EMISSAO,SC6->C6_YEMISSA))}
	aDiaSemana:= {"DOMINGO","SEGUNDA","TERCA  ","QUARTA ","QUINTA ","SEXTA  ","SABADO "}
	// 			 1 2 3 4 5 6 7 8 9 0
	aFor		:= {0,0,0,0,0,0,0,0,0,0}
	aTotal	:= {0,0,0,0,0,0,0,0,0,0}
	lCabec	:= .F.
	//MONTA TABELA DE ESTADOS
	//-----------------------
	fTabEst()
	//MONTA TABELA DOS FORMATOS DE PISOS
	//----------------------------------
	fTabFor()
	//Verifica Posicao do Formulario na Impressora
	SetDefault(aRETURN,cString)
	IF ( nLastKey == 27 ) .OR. ( LastKey() == 27 ); RETURN; ENDIF
	PROCESSA( {|| fCriaArq() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	PROCESSA( {|| Execute(fCriaArq) } )
	PROCESSA( {|| fTabFer()  } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	PROCESSA( {|| Execute(fTabFer)  } )
	PROCESSA( {|| fAcuMeta() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	PROCESSA( {|| Execute(fAcuMeta) } )
	PROCESSA( {|| fFaturado()} )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	PROCESSA( {|| Execute(fFaturado)} )
	PROCESSA( {|| fImprime() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	PROCESSA( {|| Execute(fImprime) } )
	Roda(cbcont,cbtxt,tamanho)
	DBSELECTAREA("cTrb")
	DBCLOSEAREA()
	IF aRETURN[5] == 1
		SET PRINTER TO
		OURSPOOL(wnrel)
	ENDIF

	IF FILE(cTrb+".DBF")
		FERASE(cTrb+".DBF")
		FERASE(cTrb+".WMF")
		FERASE(cTrb+".IDX")
		FERASE(cTrb+".CDX")
		FERASE(cTrb+".MEM")
	ENDIF

	MS_FLUSH()
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fTabEst
Static FUNCTION fTabEst()
	DBSELECTAREA("SX5")
	DBSETORDER(1)
	wEstado := ""
	DBSEEK(XFILIAL("SX5")+"12")
	WHILE !EOF() .AND. RTRIM(SX5->X5_TABELA) == "12"
		wEstado := wEstado + RTRIM(SX5->X5_CHAVE)+";"
		DBSKIP()
	ENDDO
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fCriaArq
Static FUNCTION fCriaArq()
	aCampos := {}
	TAM_PAIS := LEN(SA1->A1_YPAIS)
	TAM_NOME := LEN(SA3->A3_NOME)
	AADD(aCampos,{"DATA   ","D",08, 0}) // Data
	AADD(aCampos,{"MET_VOL","N",12, 2}) // Meta em volume
	AADD(aCampos,{"MET_PM ","N",12, 2}) // Meta em preco medio
	AADD(aCampos,{"FAT_VOL","N",12, 2}) // Volume faturado
	AADD(aCampos,{"FAT_PM ","N",12, 2}) // Preco medio do volume faturado
	AADD(aCampos,{"ATI_VOL","N",12, 2}) // Volume atingido
	AADD(aCampos,{"ATI_PM ","N",12, 2}) // Preco medio atingido
	cTrb := CriaTrab(aCampos, .T.)
	DbUseArea(.T.,,cTrb,"cTrb")
	INDEX ON DTOS(DATA) TAG DATA TO &cTrb
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fTabFor
Static FUNCTION fTabFor()
	aFormato := {}
	bDescFor := {|| RTRIM(UPPER(SX5->X5_DESCRI))}
	DBSELECTAREA("SX5")
	DBSETORDER(1)
	IF ! DBSEEK(XFILIAL("SX5")+"U1"+RTRIM(wFormato))
		MSGALERT("Tabela "+"U1"+RTRIM(wFormato)+"nao encontrada")
		nLastKey := 27
		RETURN( NIL)
	ENDIF
	AADD(aFormato,{LEFT(SX5->X5_CHAVE,2),EVAL(bDescFor),0,0,0,0,0,0,0,0,0,0,0})
	IF EMPTY(wFormato)
		WHILE !EOF() .AND. RTRIM(SX5->X5_TABELA) == "U1"
			IF ASCAN(aFormato,{|X| X[1] == LEFT(SX5->X5_CHAVE,2) }) > 0
				DBSKIP()
				LOOP
			ENDIF
			AADD(aFormato,{LEFT(SX5->X5_CHAVE,2),EVAL(bDescFor),0,0,0,0,0,0,0,0,0,0,0})
			SX5->(DBSKIP())
		ENDDO
	ELSE
		WHILE !EOF() .AND. RTRIM(SX5->X5_TABELA) == "U1"
			IF ASCAN(aFormato,{|X| X[1] == LEFT(SX5->X5_CHAVE,2) }) > 0
				DBSKIP()
				LOOP
			ENDIF
			AADD(aFormato,{LEFT(SX5->X5_CHAVE,2),EVAL(bDescFor),0,0,0,0,0,0,0,0,0,0,0})
			SX5->(DBSKIP())
		ENDDO
	ENDIF
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fFaturado
Static FUNCTION fFaturado()

	bFormato  := {||IIF( EVAL(bPosFor,mFunc) > 0, aFormato[EVAL(bPosFor,mFunc)][1], "")}
	bDataAte  := {||SD2->D2_EMISSAO <= wDataAte }
	bDataDe	 := {||SD2->D2_EMISSAO < wDataDe  }
	bNotNaoOk := {||!(SF4->F4_DUPLIC == "S" .AND. SF4->F4_ESTOQUE == "S") }
	bDevolu	 := {||SD1->(DBSEEK(XFILIAL("SD1")+SD2->D2_DOC+SD2->D2_SERIE))}
	bProduto  := {||wProDe > SD2->D2_COD .OR. wProAte < SD2->D2_COD }
	IF wMercado == 1									 // INTERNO
		bMercado := {||SA1->A1_EST $ wEstado}
	ELSEIF wMercado == 2 							 // EXTERNO
		bMercado := {|| !(SA1->A1_EST $ wEstado) }
	ELSEIF wMercado  == 3							  // AMBOS
		bMercado := {|| .T. }
	ENDIF
	wQtdDevol := wValDevol := wFAT_PM:= wFAT_VOL := 0
	DataRegua := wDataDe
	mFunc 	 := "F2"

	DBSELECTAREA("SA1")
	DBSETORDER(1)
	DBGOTOP()
	DBSELECTAREA("SF2")
	DBSETORDER(1)
	DBGOTOP()
	DBSELECTAREA("SA3")
	DBSETORDER(1)
	DBGOTOP()
	DbSelectArea("SF4")
	DbSetOrder(1)
	DBGOTOP()
	DbSelectArea("SD1")
	DbSetOrder(11)
	DBGOTOP()
	DBSELECTAREA("SD2")
	DBSETORDER(5)

	DbSeek( xFilial("SD2")+DTOS(wDataDe), .T. )
	ProcRegua( EVAL(bTamRegua) )

	WHILE ! Eof() .AND. EVAL(bDataAte)

		fIncRegua()

		SF2->( DBSEEK(XFILIAL("SF2")+SD2->D2_DOC+SD2->D2_SERIE))
		SA3->( DBSEEK(XFILIAL("SA3")+SF2->F2_VEND1)   )
		SA1->( DBSEEK(XFILIAL("SA1")+SF2->F2_CLIENTE) )
		SF4->( DBSEEK(XFILIAL("SF4")+SD2->D2_TES)     )

		IF EVAL(bDataDe)			; SD2->(DBSKIP()); LOOP; ENDIF
		IF EVAL(bProduto) 		; SD2->(DBSKIP()); LOOP; ENDIF
		IF !EVAL(bMercado)		; SD2->(DBSKIP()); LOOP; ENDIF
		IF EVAL(bNotNaoOk)		; SD2->(DBSKIP()); LOOP; ENDIF
		IF EMPTY(EVAL(bFormato)); SD2->(DBSKIP()); LOOP; ENDIF
		IF EVAL(bDevolu)			; fDevolu() 			  ; ENDIF

		fGrava()

		DBSELECTAREA("SD2")
		DBSKIP()

	ENDDO

RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fDevolu
Static FUNCTION fDevolu()
	DBSELECTAREA("SD1")
	WHILE !EOF() .AND. (SD2->D2_DOC+SD2->D2_SERIE == SD1->D1_NFORI+SD1->D1_SERIORI)
		IF SD1->D1_COD == SD2->D2_COD
			wQtdDevol := wQtdDevol + SD1->D1_QUANT
			wValDevol := wValDevol + SD1->D1_TOTAL
		ENDIF
		DBSKIP()
	ENDDO
	DBSELECTARE("SD2")
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fGrava
Static FUNCTION fGrava()

	bEmissao := {|x| IIF( x == "F2", SD2->D2_EMISSAO,SC6->C6_YEMISSA) }

	DBSELECTAREA("cTrb")
	DBGOTOP()

	IF ! DBSEEK(EVAL(bData,mFunc),.F.)
		WHILE ! RECLOCK("cTrb",.T.); ENDDO
		cTrb->DATA	 := EVAL(bEmissao,mFunc)
		IF mFunc == "F2"
			cTrb->FAT_VOL := SD2->D2_QUANT 	  // Volume faturado
			cTrb->FAT_PM  := SD2->D2_TOTAL 		// Preco medio do volume faturado
		ENDIF
		cTrb->ATI_VOL := EVAL(bAtiVol) // Volume atingido
		cTrb->ATI_PM  := EVAL(bAtiPm)	// Preco medio atingido
	ELSE
		WHILE ! RECLOCK("cTrb",.F.); ENDDO
		IF mFunc == "F2"
			cTrb->FAT_VOL := cTrb->FAT_VOL + wFAT_VOL		// Volume faturado
			cTrb->FAT_PM  := cTrb->FAT_PM  + wFAT_PM 		// Preco medio do volume faturado
		ENDIF
		cTrb->ATI_VOL := EVAL(bAtiVol) // Volume atingido
		cTrb->ATI_PM  := EVAL(bAtiPm)	// Preco medio atingido
	ENDIF
	wQtdDevol := wValDevol := wFAT_VOL := wFAT_PM := 0
	MSUNLOCK()
	DBCOMMIT()
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fAcuMeta
Static FUNCTION fAcuMeta()

	wMetaVol  := wMetaPm :=  0
	bMesAno	 := {|| STRZERO(MONTH(wDataDe),2,0)+"/"+LEFT(DTOS(wDataDe),4) }

	DBSELECTAREA("UZ8")
	DBSETORDER(2)
	DBGOTOP()

	DBSEEK(xFILIAL("UZ8")+EVAL(bMesAno),.T.)

	ProcRegua(LASTREC())

	WHILE !EOF() .AND. EVAL(bMesAno) == UZ8->UZ8_MESANO
		IncProc()
		wMetaVol := wMetaVol +	UZ8->UZ8_VOLUME
		wMetaPm	:= wMetaPm	+ (UZ8->UZ8_VOLUME * UZ8->UZ8_PM)
		UZ8->(DBSKIP())
	ENDDO

	DBSELECTAREA("cTrb")
	cTrb->(DBGOTOP())

	ProcRegua(DiasUteis)

	wAcumMeta := wMetaVol / DiasUteis
	nVezes	 := 0

	WHILE DiasUteis > nVezes
		nVezes := nVezes + 1
		IncProc()
		WHILE !RECLOCK("cTrb",.F.);ENDDO
		cTrb->MET_VOL := wAcumMeta
		cTrb->MET_PM  := wMetaPm / wMetaVol
		wAcumMeta	 := wAcumMeta + (wMetaVol / DiasUteis)
		MSUNLOCK()
		DBCOMMIT()
		cTrb->(DBSKIP())
	ENDDO

RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImprime
Static FUNCTION fImprime()
	DBSELECTAREA("cTrb")
	DBGOTOP()
	WHILE ! cTrb->(EOF())
		IF li >= 62
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
			lCabec := .T.
		ENDIF
		fTotal()
		fImpDet()
		cTrb->(DBSKIP())
	ENDDO
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpDet
Static FUNCTION fImpDet()
	ImpTxt := DTOC(cTrb->DATA)	 + SPACE(1)
	ImpTxt := ImpTxt + " " + aDiaSemana[DOW(cTrb->DATA)]+ SPACE(3)
	ImpTxt := ImpTxt + TRANS(cTrb->MET_VOL,"@E 999,999.99") + SPACE(5)
	ImpTxt := ImpTxt + TRANS(cTrb->MET_PM ,"@E 999.99"    ) + SPACE(2)
	ImpTxt := ImpTxt + TRANS(cTrb->MET_VOL*cTrb->MET_PM,"@E 99,999,999.99") + SPACE(2)
// ImpTxt := ImpTxt + TRANS(cTrb->FAT_VOL,"@E 999,999.99") + SPACE(5)
// ImpTxt := ImpTxt + TRANS(EVAL(bFatPm),"@E 999.99"    ) + SPACE(2)
// ImpTxt := ImpTxt + TRANS(cTrb->FAT_VOL*EVAL(bFatPm),"@E 99,999,999.99") + SPACE(4)
	ImpTxt := ImpTxt + TRANS(aTotal[3],"@E 999,999.99") + SPACE(5)
	ImpTxt := ImpTxt + TRANS(EVAL(bTgFatPm),"@E 999.99"    ) + SPACE(2)
	ImpTxt := ImpTxt + TRANS(aTotal[3]*EVAL(bTgFatPm),"@E 99,999,999.99") + SPACE(4)
	ImpTxt := ImpTxt + TRANS(EVAL(bTgAtiVo),"@E 9,999.99")  +SPACE(3)
	ImpTxt := ImpTxt + TRANS(EVAL(bTgAtiPm),"@E 9,999.99")   +SPACE(5)
// ImpTxt := ImpTxt + TRANS(((cTrb->FAT_VOL*EVAL(bTgFatPm)) / (cTrb->MET_VOL*cTrb->MET_PM))*100,"@E 9,999.99")
	li 	 := li + 1
	@ li, 001 PSAY ImpTxt
RETURN(NIL)
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fTotal
Static FUNCTION fTotal()
	aTotal[1] := cTrb->MET_VOL
	aTotal[2] := (cTrb->MET_PM * cTrb->MET_VOL)
	aTotal[3] := aTotal[3] + cTrb->FAT_VOL
	aTotal[4] := aTotal[4] + cTrb->FAT_PM
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fIncRegua
Static FUNCTION fIncRegua()
	wIncremen := SD2->D2_EMISSAO - DataRegua
	IF ( wIncremen > 0 )
		IncProc( wIncremen )
		DataRegua := SD2->D2_EMISSAO
	ENDIF
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fTabFer
Static FUNCTION fTabFer()

	aFeriado  := {}; xxI := DiasUteis:= 0
	bDiaMes	 := {|| SUBS(DTOC(wDataDe+xxI),5)}
	bSabDom	 := {|| STR(DOW(wDataDe+xxI),1,0) $ "17" }
	bUltDiaMes:= {|| CTOD("01/"+STRZERO(MONTH(wDataDe+31),2,0)+"/"+STR(YEAR(wDataDe),4,0))-1 }

	SX5->(DbSeek("  63"))

	Do While SX5->X5_TABELA == "63"
		AADD(aFeriado,left(alltrim(SX5->X5_DESCRI),5))
		SX5->(DBSKIP())
	EndDo

	DBSELECTAREA("cTrb")
	DBGOTOP()

	ProcRegua(EVAL(bTamRegua))

	WHILE xxI <= ((EVAL(bUltDiaMes)-wDataDe))

		IncProc()

		IF !Eval(bSabDom) .AND. ASCAN( aFeriado, EVAL(bDiaMes) ) == 0
			WHILE !RECLOCK("cTrb",.T.);ENDDO
			cTrb->DATA := wDataDe+xxI
			MSUNLOCK()
			DBCOMMIT()
			DiasUteis := DiasUteis + 1
		ENDIF

		xxI := xxI + 1

	ENDDO

RETURN( NIL )
/*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fRank
Static FUNCTION fRank()

	bSoma_a := {||MedVol3M+wVolMes}
	bSoma_b := {||X[4]+X[5]}

	IF ( LEN(aRank) < 10 )
		AADD( aRank, {SA1->A1_COD,SA1->A1_NOME,SF2->F2_VEND1,wMedVol,wVolMes} )
	ELSE
		IF ASCAN(aRank,{|X| EVAL(bSoma_a) > bSoma_b }) > 0
			ADEL( aRank, 10 )
			AADD( aRank, {SA1->A1_COD,SA1->A1_NOME,SF2->F2_VEND1,wMedVol,wVolMes} )
		ENDIF
	ENDIF

	ASORT(aRank,{|X| EVAL(bSoma_a) > EVAL(bSoma_b)})

RETURN(NIL)
-------------------------------------------------------------------------------------------------------------------------------------------------------*/