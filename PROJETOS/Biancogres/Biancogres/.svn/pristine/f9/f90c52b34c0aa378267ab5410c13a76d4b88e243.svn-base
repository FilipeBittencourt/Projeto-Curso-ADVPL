#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
	#IFNDEF WINDOWS
		#DEFINE PSAY SAY
	#ENDIF

User Function Bia300()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CDESC1,CDESC2,CDESC3,TAMANHO,LIMITE,CSTRING")
SetPrvt("TITULO,ARETURN,NOMEPROG,NLASTKEY,WNUMBER,CBCONT")
SetPrvt("CPERG,WNREL,C15,CBTXT,LI,M_PAG")
SetPrvt("WDATADE,WDATAATE,WREPDE,WREPATE,WMERCADO,WESTADO")
SetPrvt("WPAIS,WFORMATO,WRESUM,WORDEM,WPRODE,WPROATE")
SetPrvt("BMERCADO,BQUA_ACO,CABEC1,CABEC2,BQUA_NEW,BQUA_UZ8")
SetPrvt("BCHAVE_ACO,BPEDPM,BFATPM,BCARPM,BFOMETPM,BFOPEDPM")
SetPrvt("BFOFATPM,BFOCARPM,BFOATIVO,BFOATIPM,BREMETPM,BREPEDPM")
SetPrvt("BREFATPM,BRECARPM,BREATIVO,BREATIPM,BTGMETPM,BTGPEDPM")
SetPrvt("BTGFATPM,BTGCARPM,BTGATIVO,BTGATIPM,BCODPRO,BCPODATA")
SetPrvt("BVEND,BOLD_QUA,BASCAN,BPOSFOR,BATIVOL,BATIPM")
SetPrvt("BUF,BPEDNAOOK,BFORMATO,BREP,BMESANO,BANOMES")
SetPrvt("BDATAATE,BPOSEST,BPOSESTA,BREGIAO,BPAIS,NUMMESES")
SetPrvt("BPRODUTO,AREP,AFOR,ATOTAL,ATOTEXT,ATOTBRA")
SetPrvt("LCABEC,LCARTEIRA,ACAMPOS,TAM_PAIS,TAM_NOME,cTrb")
SetPrvt("AESTADO,AFORMATO,BQUA_SX5,BDESCFOR,BDEVOLU,WMVOLFOR")
SetPrvt("WMPMFOR,WQTDDEVOL,WVALDEVOL,OLDDATA,BPEDCAR1,BPEDCAR2")
SetPrvt("WPAR,OLDREP,LREPDIF,BNOME,OLDQUA,OLDPAIS")
SetPrvt("OLDEST,OLDREG,ATOTREG,ATOTPAIS,IMPTXT,I")
SetPrvt("WINCREMEN,LLOOP,")

*------------------------------------------------------------------------------------------------------------------------------------------------------
// Programa : BIA300
// Autor 	: AUGUSTO CESAR DE OLIVEIRA
// Data		: 12/04/2000 AS 19:18 a 22:15; 18:15 as 19:45; 19:30 a 21:10
// 								 20:10 a
// Descricao: Desempenho por Representante
// Uso		: SIGAFAT
// FUNCOES	: fCriaArq()	-> Cria arquivo temporario
*-------------------------------------------------------------------------------------------------------------------------------------------------------
	#IFNDEF WINDOWS
// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 		#DEFINE PSAY SAY
	#ENDIF

	//Inicializa variaveis

	cDesc1	:= "Este programa tem como objetivo emitir um relatorio do"
	cDesc2	:= "Desempenho por representante"
	cDesc3	:= ""
	tamanho	:= "M"
	limite	:= 132
	cString	:= "SD2"
	titulo	:= " RELATORIOS FLASH DE VENDAS "
	aRETURN	:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	nomeprog := "BIA300"
	nLastKey := wNumber := cbcont := 0
	cPerg 	:= "BIA300"
	wnrel 	:= "BIA300"
	C15		:= 15
	cbtxt 	:= space(10)
	li 		:= 80
	m_pag 	:= 1

	//Envia controle para a funcao SETPRINT
	wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)

	PERGUNTE( cPerg, .F. )

	IF ( nLastKey == 27 ) .OR. ( LastKey() == 27 ); RETURN; ENDIF

	//INICIALIZACAO DE VARIAVEIS GLOBAIS
	//----------------------------------

	wDataDe	 := mv_par01
	wDataAte  := mv_par02
	wRepDe	 := mv_par03
	wRepAte	 := mv_par04
	wMercado  := Alltrim(STR(mv_par05))
	wEstado	 := mv_par06
	wPais 	 := mv_par07
	wFormato  := mv_par08
	wResum	 := mv_par09 == 2
	wOrdem	 := AllTrim(STR(mv_par10))
	wProDe	 := mv_par11
	wProAte	 := mv_par12
	lCarteira := .F.
   
   DO CASE 
	   CASE wMercado == "1"; bMercado := {|| SA1->A1_EST $ wEstado}      // INTERNO
		CASE wMercado == "2"; bMercado := {|| !(SA1->A1_EST $ wEstado) } // EXTERNO
      CASE wMercado == "3"; bMercado := {|| .T. }                       // AMBOS
	ENDCASE
	
	bQua_ACO := {|X| IIF( wResum, LEFT(X,1)+SPACE(1), LEFT(X,1)+SUBS(X,2,1)) }
	bCodPro	:= {|| IIF(lCarteira, SC6->C6_PRODUTO,SD2->D2_COD) }
	bVend 	:= {|| IIF(lCarteira, SC5->C5_VEND1	,SF2->F2_VEND1) }

	IF wOrdem == "1"     //FORMATO
		titulo:= "  SEGMENTACAO POR FORMATO   "
		Cabec1:=  "                    |______META_______|_____PEDIDOS_____|_____FATURADO____|____ATINGIMENTO____|_SALDO EM CARTEIRA_|                |"
		Cabec2:=  "FORMATO             |      VOL.|    PM|      VOL.|    PM|      VOL.|    PM|      VOL.|      PM|      VOL.|    PM  |                |"
		bQua_New   := {|X| IIF( wResum, LEFT(X,1)+SPACE(1), LEFT(X,1)+SUBS(X,6,1))}
		bQua_UZ8   := {|X| IIF( wResum, LEFT(X,1)+SPACE(1), LEFT(X,1)+SUBS(X,2,1))}
		bChave_ACO := {|| EVAL(bQua_New,EVAL(bCodPro))}
	ELSEIF wOrdem == "2" //REPRESENTANTE
		titulo:= "DESEMPENHO POR REPRESENTANTE "+IIF(wResum,"(Sintetico)","(Analitico)")
		Cabec1:= " REPRESENTANTE              |       |_______META______|_____PEDIDOS_____|_____FATURADO____|___ATINGIMENTO___|_____CARTEIRA____|"
		Cabec2:= " CODIGO|NOME                |FORMATO|      VOL.|    PM|      VOL.|    PM|      VOL.|    PM|      VOL.|    PM|      VOL.|    PM|"
		bQua_New   := {|wX| IIF( wResum,SPACE(2), LEFT(wX,1)+SPACE(1))}
		bQua_UZ8   := {|wwX| IIF( wResum,SPACE(2), LEFT(wwX,1)+SPACE(1))}
		bChave_ACO := {|| EVAL(bVend)+EVAL(bQua_New,EVAL(bCodPro))}
	ELSEIF wOrdem == "3" //ESTADO
		titulo:= "FATURAMENTO POR ESTADO "+IIF(wResum,"(Sintetico)","(Analitico)")
		Cabec1:= "ESTADO/PAIS                            |                |PRECO     | VALOR        | VOLUME       |   VALOR          "
		Cabec2:= "FORMATO                                |  VOLUME EM (M2)|MEDIO (R$)| FATURADO (R$)| MEDIO EM (M2)|   MEDIO EM (R$)  "
		bQua_New   := {|X| IIF( wResum,SPACE(2), LEFT(X,1)+SPACE(1))}
		bQua_UZ8   := {|X| IIF( wResum,SPACE(2), LEFT(X,1)+SPACE(1))}
		bChave_ACO := {|| EVAL(bPais)+EVAL(bRegiao,1)+EVAL(bUf)+EVAL(bQua_New,SD2->D2_COD)}
	ENDIF

	bPedPm	:= {|| cTrb->PED_PM / cTrb->PED_VOL}
	bFatPm	:= {|| cTrb->FAT_PM / cTrb->FAT_VOL}
	bCarPm	:= {|| cTrb->CAR_PM / cTrb->CAR_VOL}
	bFoMetPm := {|| aFor[4]	/ aFor[3]}
	bFoPedPm := {|| aFor[6]	/ aFor[5]}
	bFoFatPm := {|| aFor[8]	/ aFor[7]}
	bFoCarPm := {|| aFor[10] / aFor[9]}
	bFoAtiVo := {|| ROUND( aFor[7] / aFor[3] * 100, 2 )}
	bFoAtiPm := {|| ROUND((aFor[8] / aFor[7]) / aFor[4] * 100, 2 )}
	bReMetPm := {|| aRep[2] / aRep[1]}
	bRePedPm := {|| aRep[4] / aRep[3]}
	bReFatPm := {|| aRep[6] / aRep[5]}
	bReCarPm := {|| aRep[8] / aRep[7]}
	bReAtiVo := {|| ROUND( aRep[5] / aRep[1] * 100, 2 )}
	bReAtiPm := {|| ROUND((aRep[6] / aRep[5]) / (aRep[2] / aRep[1]) * 100, 2 )}
	bTgMetPm := {|| aTotal[2] / aTotal[1]}
	bTgPedPm := {|| aTotal[4] / aTotal[3]}
	bTgFatPm := {|| aTotal[6] / aTotal[5]}
	bTgCarPm := {|| aTotal[8] / aTotal[7]}
	bTgAtiVo := {|| ROUND((aTotal[5] / aTotal[1]) * 100, 2 )}
	bTgAtiPm := {|| ROUND((EVAL(bTgFatPm) / EVAL(bTgMetPm)) * 100, 2 )}
	//bCodPro	:= {|| IIF(lCarteira, SC6->C6_PRODUTO,SD2->D2_COD)}
	bCpoData := {|| IIF(lCarteira, SC6->C6_YEMISSA,SD2->D2_EMISSAO)}
	//bVend 	:= {|| IIF(lCarteira, SC5->C5_VEND1	,SF2->F2_VEND1) }	
	bOld_Qua := {|| LEFT(EVAL(bCodPro),1)+SUBS(EVAL(bCodPro),6,1) }
	bAscan	:= 'ASCAN( aFormato, { |X| X[1] == EVAL(bOld_Qua) })'
	bPosFor	:= {|| &bAscan }
	bAtiVol	:= {|| ROUND(cTrb->FAT_VOL / cTrb->MET_VOL * 100,2)}
	bAtiPm	:= {|| ROUND((cTrb->FAT_PM/cTrb->FAT_VOL)/cTrb->MET_PM * 100,2)}
	bUf		:= {|| IIF(wMercado $ "3" .AND. (!(SA1->A1_EST $ wEstado) .OR. SA1->A1_EST == "EX"),"ZZ", SA1->A1_EST)}
	bPedNaoOk:= {|| !(SF4->F4_DUPLIC == "S" .AND. SF4->F4_ESTOQUE == "S") }
	bFormato := {|| IIF( EVAL(bPosFor) > 0, aFormato[EVAL(bPosFor)][1], "")}
	bRep		:= {|X| wRepDe  > X .OR. wRepAte < X }
	bMesAno	:= {|| STRZERO(MONTH(wDataDe),2,0)+"/"+LEFT(DTOS(wDataDe),4) }
	bAnoMes	:= {|DATA| LEFT(DTOS(DATA),6)}
	bDataAte := {|X| X <= wDataAte	}
	bPosEst	:= 'ASCAN(aEstado,{|x| x[2] == wPar})'
	bPosEsta := {|| &bPosEst }
	bRegiao	:= {|A| aEstado[ IIF( EVAL(bPosEsta)==0,MSGALERT("Estado do cliente "+SA1->A1_COD+ " nao valido. "+wPAR), EVAL(bPosEsta))][ A ]}
	bPais 	:= {|| IIF(wPar $ "ZZ,EX",IIF(EMPTY(SA1->A1_YPAIS),"EXTERIOR"+SPACE(TAM_PAIS-8),SA1->A1_YPAIS),"BRASIL" +SPACE(TAM_PAIS-6))}
	NumMeses := VAL(EVAL(bAnoMes,wDataAte)) - VAL(EVAL(bAnoMes,wDataDe)) + 1
	bProduto := {|X| wProDe > X .OR. wProAte < X }

	// 			 1 2 3 4 5 6 7 8 9 0
	aRep		:= {0,0,0,0,0,0,0,0,0,0}
	aFor		:= {0,0,0,0,0,0,0,0,0,0}
	aTotal	:= {0,0,0,0,0,0,0,0,0,0}
	aTotExt	:= {0,0}
	aTotBra	:= {0,0}
	lCabec	:= .F.

	//MONTA TABELA DOS ESTADOS BRASILEIROS
	//------------------------------------
	IF EMPTY(wEstado); fTabEst(); ENDIF

	//MONTA TABELA DOS FORMATOS DE PISOS
	//----------------------------------
	fTabFor()

	//Verifica Posicao do Formulario na Impressora
	SetDefault(aRETURN,cString)

	IF ( nLastKey == 27 ) .OR. ( LastKey() == 27 ); RETURN; ENDIF

	PROCESSA( {|| fCriaArq() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	PROCESSA( {|| Execute(fCriaArq) } )

	DBSELECTAREA("SC5")
	DBSETORDER(1)
	DBSELECTAREA("SA1")
	DBSETORDER(1)
	DBSELECTAREA("SA3")
	DBSETORDER(1)
	DbSelectArea("SF4")
	DbSetOrder(1)

	lCarteira := .F.
	PROCESSA( {|| fSeleDado() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	PROCESSA( {|| Execute(fSeleDado) } )

	IF wOrdem #"3"
		lCarteira := .T.
		PROCESSA( {|| fCarteira() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 		PROCESSA( {|| Execute(fCarteira) } )
	ENDIF

	IF wOrdem == "1"
		PROCESSA( {|| fImpFor() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 		PROCESSA( {|| Execute(fImpFor) } )
	ELSEIF wOrdem == "2"
		PROCESSA( {|| fImpRep() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 		PROCESSA( {|| Execute(fImpRep) } )
	ELSEIF wOrdem == "3"
		PROCESSA( {|| fImpEst() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 		PROCESSA( {|| Execute(fImpEst) } )
	ENDIF

	IF lCabec; fImpResFin(); ENDIF

	Roda(cbcont,cbtxt,tamanho)

	DBSELECTAREA("cTrb")
	DBCLOSEAREA()

	IF FILE(cTrb+".DBF")
		FERASE(cTrb+".*")
	ENDIF

	IF aRETURN[5] == 1
		SET PRINTER TO
		OURSPOOL(wnrel)
	ENDIF

	MS_FLUSH()

RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fCriaArq
Static FUNCTION fCriaArq()
	aCampos	:= {}
	TAM_PAIS := LEN(SA1->A1_YPAIS)
	TAM_NOME := LEN(SA3->A3_NOME)
	AADD(aCampos,{"REGIAO ","C",08, 0}) // Regiao
	AADD(aCampos,{"ESTADO ","C",02, 0}) // Estado do representante
	AADD(aCampos,{"PAIS   ","C",TAM_PAIS, 0}) // Pais do representante
	AADD(aCampos,{"REP    ","C",06, 0}) // Codigo do representante
	AADD(aCampos,{"NOME   ","C",TAM_NOME, 0}) // Nome do representante
	AADD(aCampos,{"QUALIDA","C",02, 0}) // Formato
	AADD(aCampos,{"MET_VOL","N",12, 2}) // Meta em volume
	AADD(aCampos,{"MET_PM ","N",12, 2}) // Meta em preco medio
	AADD(aCampos,{"PED_VOL","N",12, 2}) // Volume pedido
	AADD(aCampos,{"PED_PM ","N",12, 2}) // Preco medio do volume pedido
	AADD(aCampos,{"FAT_VOL","N",12, 2}) // Volume faturado
	AADD(aCampos,{"FAT_PM ","N",12, 2}) // Preco medio do volume faturado
	AADD(aCampos,{"ATI_VOL","N",12, 2}) // Volume atingido
	AADD(aCampos,{"ATI_PM ","N",12, 2}) // Preco medio atingido
	AADD(aCampos,{"CAR_VOL","N",12, 2}) // Volume em carteira (saldo)
	AADD(aCampos,{"CAR_PM ","N",12, 2}) // Preco medio do volume em carteira
	cTrb := CriaTrab(aCampos, .T.)
	DbUseArea(.T.,,cTrb,"cTrb")
	dbCreateInd(cTrb+".001","QUALIDA",{|| QUALIDA})
	dbCreateInd(cTrb+".002","REP+QUALIDA",{|| REP+QUALIDA})
	dbCreateInd(cTrb+".003","PAIS+REGIAO+ESTADO+QUALIDA",{|| PAIS+REGIAO+ESTADO+QUALIDA})
	OrdListClear()
	OrdListAdd(cTrb+".001")
	OrdListAdd(cTrb+".002")
	OrdListAdd(cTrb+".003")

	OrdSetFocus(VAL(wOrdem))

RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fTabEst
Static FUNCTION fTabEst()

	aEstado := {}

	AADD(aEstado, {"NORDESTE","AL","ALAGOAS            "})
	AADD(aEstado, {"NORDESTE","BA","BAHIA              "})
	AADD(aEstado, {"NORDESTE","CE","CEARA              "})
	AADD(aEstado, {"NORDESTE","MA","MARANHAO           "})
	AADD(aEstado, {"NORDESTE","PB","PARAIBA            "})
	AADD(aEstado, {"NORDESTE","PE","PERNAMBUCO         "})
	AADD(aEstado, {"NORDESTE","RN","RIO GRANDE DO NORTE"})
	AADD(aEstado, {"NORDESTE","SE","SERGIPE            "})
	AADD(aEstado, {"NORDESTE","PI","PIAUI              "})
	AADD(aEstado, {"NORTE   ","AM","AMAZONAS           "})
	AADD(aEstado, {"NORTE   ","PA","PARA               "})
	AADD(aEstado, {"NORTE   ","RO","RONDONIA           "})
	AADD(aEstado, {"NORTE   ","RR","RORAIMA            "})
	AADD(aEstado, {"NORTE   ","AC","ACRE               "})
	AADD(aEstado, {"NORTE   ","AP","AMAPA              "})
	AADD(aEstado, {"C. OESTE","DF","DISTRITO FEDERAL   "})
	AADD(aEstado, {"C. OESTE","GO","GOIAS              "})
	AADD(aEstado, {"C. OESTE","MT","MATO GROSSO        "})
	AADD(aEstado, {"C. OESTE","MS","MATO GROSSO DO SUL "})
	AADD(aEstado, {"C. OESTE","TO","TOCANTINS          "})
	AADD(aEstado, {"SUDESTE ","MG","MINAS GERAIS       "})
	AADD(aEstado, {"SUDESTE ","RJ","RIO DE JANEIRO     "})
	AADD(aEstado, {"SUDESTE ","SP","SAO PAULO          "})
	AADD(aEstado, {"SUDESTE ","ES","ESPIRITO SANTO     "})
	AADD(aEstado, {"SUL     ","RS","RIO GRANDE DO SUL  "})
	AADD(aEstado, {"SUL     ","SC","SANTA CATARINA     "})
	AADD(aEstado, {"SUL     ","PR","PARANA             "})
	AADD(aEstado, {"ZZZZZZZZ","ZZ","EXTERIOR           "})
	AADD(aEstado, {"ZZZZZZZZ","EX","EXTERIOR           "})

	DBSELECTAREA("SX5")
	DBSETORDER(1)
	DBSEEK(XFILIAL("SX5")+"12")
	WHILE !EOF() .AND. RTRIM(SX5->X5_TABELA) == "12"
		wEstado := wEstado + RTRIM(SX5->X5_CHAVE)+";"
		DBSKIP()
	ENDDO
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fTabFor
Static FUNCTION fTabFor()

	aFormato := {}
	bQua_Sx5 := {|| LEFT(SX5->X5_CHAVE,2)}
	bDescFor := {|| RTRIM(UPPER(SX5->X5_DESCRI))}

	DBSELECTAREA("SX5")
	DBSETORDER(1)
	IF ! DBSEEK(XFILIAL("SX5")+"U1"+RTRIM(wFormato))
		MSGALERT("Tabela "+"U1"+wFormato+"nao encontrada")
		nLastKey := 27
		RETURN( NIL)
	ENDIF
	//AADD(aFormato,{EVAL(bQua_Sx5),EVAL(bDescFor)})
	IF EMPTY(wFormato)
		WHILE !EOF() .AND. RTRIM(SX5->X5_TABELA) == "U1"
			AADD(aFormato,{EVAL(bQua_Sx5),EVAL(bDescFor)})
			SX5->(DBSKIP())
		ENDDO
	ELSE
		WHILE !EOF() .AND. RTRIM(SX5->X5_TABELA) == "U1"
			IF LEFT(SX5->X5_CHAVE,2) $ RTRIM(wFormato)
				AADD(aFormato,{EVAL(bQua_Sx5),EVAL(bDescFor)})
			ENDIF
			SX5->(DBSKIP())
		ENDDO
	ENDIF
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fSeleDado
Static FUNCTION fSeleDado()

	bDevolu	 := {|| SD1->(DBSEEK(XFILIAL("SD1")+SD2->D2_DOC+SD2->D2_SERIE))}
	wMVolFor  := wMpmFor := wQtdDevol := wValDevol := 0

	ProcRegua( IIF( ( wDataDe	- wDataAte) == 0, 1, (wDataAte  - wDataDe)+1 ) )

	DBSELECTAREA("UZ8")
	IF wOrdem == "1"
		DBSETORDER(2)
	ELSEIF wOrdem == "2"
		DBSETORDER(1)
	ENDIF
	DbSelectArea("SD1")
	DbSetOrder(11)
	DbSelectArea("SF2")
	DbSetOrder(1)
	DbSelectArea("SD2")
	DbSetOrder(5)
	DbSeek(xFilial("SD2")+DTOS(wDataDe),.T.)
	OldData	 := SD2->D2_EMISSAO

	WHILE ! Eof() .AND. EVAL(bDataAte, EVAL(bCpoData))

		fIncRegua(1)

		SF2->( DBSEEK(XFILIAL("SF2")+SD2->D2_DOC))
		SA3->( DBSEEK(XFILIAL("SA3")+SF2->F2_VEND1))
		SA1->( DBSEEK(XFILIAL("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
		SF4->( DBSEEK(XFILIAL("SF4")+SD2->D2_TES))

		IF EVAL(bRep,SF2->F2_VEND1)
			SD2->(DBSKIP())
			LOOP
		ENDIF

		fValida()

		IF lLoop
			SD2->(DBSKIP())
			LOOP
		ENDIF

		IF EVAL(bDevolu);fDevolu();ENDIF

		fGraFat()

		DBSELECTAREA("SD2")
		DBSKIP()

	ENDDO
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fCarteira
Static FUNCTION fCarteira()

	ProcRegua( IIF( ( wDataAte - (wDataAte - 90)) == 0, 1, (wDataAte - (wDataAte - 90)) ) )

	DbSelectArea("SC6")
	DbSetOrder(6)

	DBSEEK(XFILIAL("SC6")+DTOS(wDataAte-90),.T.)

	OldData := SC6->C6_YEMISSA

	WHILE ! Eof() .AND. EVAL(bDataAte,EVAL(bCpoData))

		fIncRegua()

		SC5->( DBSEEK(XFILIAL("SC5")+SC6->C6_NUM))
		SA3->( DBSEEK(XFILIAL("SA3")+SC5->C5_VEND1))
		SA1->( DBSEEK(XFILIAL("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
		SF4->( DBSEEK(XFILIAL("SF4")+SC6->C6_TES))

		IF EVAL(bRep,SC5->C5_VEND1)
			SC6->(DBSKIP())
			LOOP
		ENDIF

		fValida()

		IF lLoop
			SC6->(DBSKIP())
			LOOP
		ENDIF

		fGraCar()

		DBSELECTAREA("SC6")
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
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fGraCar
Static FUNCTION fGraCar()

	bPedCar1  := {|| SC6->C6_QTDVEN - SC6->C6_QTDENT }
	bPedCar2  := {|| (SC6->C6_VALOR / SC6->C6_QTDVEN) * EVAL(bPedCar1) }
	wPar		 := EVAL(bUf)

	DBSELECTAREA("cTrb")
	DBSETORDER(VAL(wOrdem))

	IF ! DBSEEK(EVAL(bChave_cTrb),.F.)

		WHILE ! RECLOCK("cTrb",.T.); ENDDO
		cTrb->QUALIDA := EVAL(bQua_New,SC6->C6_PRODUTO)
		cTrb->NOME	 := SA3->A3_NOME
		cTrb->PAIS	 := EVAL(bPais)
		cTrb->REGIAO  := EVAL(bRegiao,1)
		cTrb->ESTADO  := EVAL(bUf)
		cTrb->REP 	 := SC5->C5_VEND1
		cTrb->MET_VOL := wMVolFor
		cTrb->MET_PM  := wMPmFor

		IF EVAL(bAnoMes, SC6->C6_YEMISSA) == EVAL(bAnoMes, wDataAte)
			cTrb->PED_VOL := cTrb->PED_VOL + SC6->C6_QTDVEN  // Volume pedido
			cTrb->PED_PM  := cTrb->PED_PM  + SC6->C6_VALOR   // Preco medio do volume pedido
		ENDIF

		cTrb->CAR_VOL := cTrb->CAR_VOL + EVAL(bPedCar1) // Volume em carteira (saldo)
		cTrb->CAR_PM  := cTrb->CAR_PM  + EVAL(bPedCar2)  // Preco medio do volume em carteira

	ELSE

		WHILE ! RECLOCK("cTrb",.F.); ENDDO

		IF EVAL(bAnoMes, SC6->C6_YEMISSA) == EVAL(bAnoMes, wDataAte)
			cTrb->PED_VOL := cTrb->PED_VOL + SC6->C6_QTDVEN  // Volume pedido
			cTrb->PED_PM  := cTrb->PED_PM  + SC6->C6_VALOR   // Preco medio do volume pedido
		ENDIF

		cTrb->CAR_VOL := cTrb->CAR_VOL + EVAL(bPedCar1) // Volume em carteira (saldo)
		cTrb->CAR_PM  := cTrb->CAR_PM  + EVAL(bPedCar2)  // Preco medio do volume em carteira

	ENDIF

	MSUNLOCK()
	DBCOMMIT()

RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fGraFat
Static FUNCTION fGraFat()

	wPar := EVAL(bUf)

	DBSELECTAREA("cTrb")
	DBSETORDER(VAL(wOrdem))

	IF wOrdem == "1"
		fAcuMetFor()
	ELSEIF wOrdem == "2"
		fAcuMetRep()
	ENDIF

	IF ! DBSEEK(EVAL(bChave_ACO),.F.)

		WHILE ! RECLOCK("cTrb",.T.); ENDDO
		cTrb->NOME	 := SA3->A3_NOME
		cTrb->PAIS	 := EVAL(bPais)
		cTrb->REGIAO  := EVAL(bRegiao,1)
		cTrb->ESTADO  := EVAL(bUf)
		cTrb->REP 	 := SF2->F2_VEND1
		cTrb->QUALIDA := EVAL(bQua_New,SD2->D2_COD)
		cTrb->FAT_VOL := cTrb->FAT_VOL + (SD2->D2_QUANT-wQtdDevol) 		// Volume faturado
		cTrb->FAT_PM  := cTrb->FAT_PM  + (SD2->D2_TOTAL-wValDevol) // Preco medio do volume faturado
		cTrb->MET_VOL := wMVolFor
		cTrb->MET_PM  := wMPmFor

		cTrb->ATI_VOL := EVAL(bAtiVol) 											// Volume atingido
		cTrb->ATI_PM  := EVAL(bAtiPm)												// Preco medio atingido

	ELSE

		WHILE ! RECLOCK("cTrb",.F.); ENDDO

		cTrb->FAT_VOL := cTrb->FAT_VOL + (SD2->D2_QUANT-wQtdDevol)// Volume faturado
		cTrb->FAT_PM  := cTrb->FAT_PM  + (SD2->D2_TOTAL-wValDevol) // Preco medio do volume faturado
		cTrb->ATI_VOL := EVAL(bAtiVol) 							 // Volume atingido
		cTrb->ATI_PM  := EVAL(bAtiPm)								 // Preco medio atingido

	ENDIF

	wQtdDevol := wValDevol := wMVolFor := wMpmFor := 0

	MSUNLOCK()
	DBCOMMIT()

RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fAcuMetFor
Static FUNCTION fAcuMetFor()

  UZ8->( DBSEEK( XFILIAL("UZ8")+EVAL(bMesAno)+EVAL(bQua_New,EVAL(bCodPro)),.T.))

  WHILE EVAL(bQua_New,EVAL(bCodPro)) == EVAL(bQua_UZ8,UZ8->UZ8_FORQUA) .AND. !UZ8->(EOF())

	  IF EVAL(bRep,UZ8->UZ8_REP)
		  SC6->(DBSKIP())
		  LOOP
	  ENDIF

	  wMVolFor := wMVolFor + UZ8->UZ8_VOLUME
	  wMpmFor  := wMpmFor  + (UZ8->UZ8_VOLUME * UZ8->UZ8_PM)

	  UZ8->(DBSKIP())

  ENDDO

  IF wMVolFor > 0
	  wMpmFor  := ROUND(wMpmFor / wMVolFor,2)
  ENDIF

RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fAcuMetRep
Static FUNCTION fAcuMetRep()

  UZ8->( DBSEEK( XFILIAL("UZ8")+EVAL(bVend)+EVAL(bMesAno)+RTRIM(EVAL(bQua_New,EVAL(bCodPro))),.T.))

  WHILE ( EVAL(bVend) == UZ8->UZ8_REP ) .AND. !UZ8->(EOF())

	  IF EVAL(bQua_New,EVAL(bCodPro)) == EVAL(bQua_UZ8,UZ8->UZ8_FORQUA)
		  wMVolFor := wMVolFor + UZ8->UZ8_VOLUME
		  wMpmFor  := wMpmFor  + (UZ8->UZ8_VOLUME * UZ8->UZ8_PM)
	  ENDIF

	  wMVolFor := wMVolFor + UZ8->UZ8_VOLUME
	  wMpmFor  := wMpmFor  + (UZ8->UZ8_VOLUME * UZ8->UZ8_PM)

	  UZ8->(DBSKIP())

  ENDDO

  IF wMVolFor > 0
	  wMpmFor  := ROUND(wMpmFor / wMVolFor,2)
  ENDIF

RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpRep
Static FUNCTION fImpRep()

	DBSELECTAREA("cTrb")
	DBGOTOP()

	OldRep	:= cTrb->NOME
	lRepDif	:= .T.
	bNome 	:= {|| SUBS(cTrb->NOME,1,20) }

	WHILE !EOF()
		IF li >= 62
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
			lCabec := .T.
		ENDIF
		IF (OldRep #cTrb->NOME .AND. !wResum); fTotRep(); ENDIF
		// Acumula valores do representante
		aRep[1]	 := aRep[1] + cTrb->MET_VOL
		aRep[2]	 := aRep[2] + ( cTrb->MET_PM * cTrb->MET_VOL )
		aRep[3]	 := aRep[3] + cTrb->PED_VOL
		aRep[4]	 := aRep[4] + cTrb->PED_PM
		aRep[5]	 := aRep[5] + cTrb->FAT_VOL
		aRep[6]	 := aRep[6] + cTrb->FAT_PM
		aRep[7]	 := aRep[7] + cTrb->CAR_VOL
		aRep[8]	 := aRep[8] + cTrb->CAR_PM
		fImpDet()
		fTotal()
		OldRep := cTrb->NOME
		cTrb->(DBSKIP())
	ENDDO
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpFor
Static FUNCTION fImpFor()
	DBSELECTAREA("cTrb")
	DBGOTOP()
	OldQua	:= LEFT(cTrb->QUALIDA,1)
	WHILE ! cTrb->(EOF())
		IF li >= 62
			Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
			lCabec := .T.
		ENDIF
		IF OldQua #LEFT(cTrb->QUALIDA,1) .AND. !wResum; fTotFor(); ENDIF
		// Totaliza valores por formato
		aFor[3] := aFor[3] + cTrb->MET_VOL
		aFor[4] := aFor[4] + cTrb->MET_PM * cTrb->MET_VOL
		aFor[5] := aFor[5] + cTrb->PED_VOL
		aFor[6] := aFor[6] + cTrb->PED_PM
		aFor[7] := aFor[7] + cTrb->FAT_VOL
		aFor[8] := aFor[8] + cTrb->FAT_PM
		aFor[9] := aFor[9] + cTrb->CAR_VOL
		aFor[10]:= aFor[10]+ cTrb->CAR_PM
		fTotal()
		fImpDet()
		OldQua := LEFT(cTrb->QUALIDA,1)
		cTrb->(DBSKIP())
	ENDDO
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpEst
Static FUNCTION fImpEst()

	DBSELECTAREA("cTrb")
	DBGOTOP()

	ProcRegua( LASTREC() )

	OldPais := cTrb->PAIS
	OldEst  := cTrb->ESTADO
	OldReg  := cTrb->REGIAO
	wPar	  := cTrb->ESTADO
	aTotReg := {0,0}
	aTotPais:= {0,0}

	IF li >= 58  // IMPRIME O CABECALHO DO RELATORIO
		li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		li := li + 2

		IF wPar == "ZZ"
			@ li, 001 PSAY "REGIAO: " + IIF( EMPTY(cTrb->PAIS),EVAL(bRegiao,3),cTrb->PAIS)
		ELSE
			@ li, 001 PSAY "REGIAO: " + EVAL(bRegiao,1)
		ENDIF

		li := li + 2
		@ li, 001 PSAY "Estado: " + EVAL(bRegiao,3)

		lCabec := .T.

	ENDIF

	WHILE ! cTrb->(EOF())

		IncProc()

		IF li >= 58  // IMPRIME O CABECALHO DO RELATORIO
			li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
			li := li + 1
			lCabec := .T.
		ENDIF

		IF OldReg #cTrb->REGIAO  //IMPRIME O TOTAL DA REGIAO
			IF !wResum
				fTotEst()
			ENDIF
			fTotReg()
			OldEst := cTrb->ESTADO
			OldReg := cTrb->REGIAO
		ELSEIF OldEst #cTrb->ESTADO  // IMPRIME O TOTAL DO ESTADO
			IF !wResum
				fTotEst()
			ENDIF
			li := li + 2
			wPar := cTrb->ESTADO
			@ li, 001 PSAY "Estado: " + EVAL(bRegiao,3)
			OldEst := cTrb->ESTADO
		ENDIF

		// Totaliza valores por ESTADO
		aFor[7]	  := aFor[7]	+ cTrb->FAT_VOL
		aFor[8]	  := aFor[8]	+ cTrb->FAT_PM

		// Totaliza valores por REGIAO
		aTotReg[1] := aTotReg[1]+ cTrb->FAT_VOL
		aTotReg[2] := aTotReg[2]+ cTrb->FAT_PM

		// Totaliza valores por PAIS
		aTotPais[1] := aTotPais[1]+ cTrb->FAT_VOL
		aTotPais[2] := aTotPais[2]+ cTrb->FAT_PM

		fTotal()
		fImpDet()

		OldPais:= cTrb->PAIS
		OldEst := cTrb->ESTADO
		OldReg := cTrb->REGIAO

		cTrb->(DBSKIP())

	ENDDO

RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fTotReg
Static FUNCTION fTotReg()

	wPar := OldEst

	IF wPar == "ZZ"
		ImpTxt := "Total da regiao: "+ SUBS(IIF(EMPTY(cTrb->PAIS),EVAL(bRegiao,3),cTrb->PAIS),1,8) + SPACE(16)
	ELSE
		ImpTxt := "Total da regiao: "+ EVAL(bRegiao,1) + SPACE(16)
	ENDIF

	ImpTxt := ImpTxt + TRANS(aTotReg[1],"@E 999,999,999.99") + SPACE(5)
	ImpTxt := ImpTxt + TRANS(aTotReg[2]/aTotReg[1],"@E 999.99") + SPACE(1)
	ImpTxt := ImpTxt + TRANS(aTotReg[2] ,"@E 999,999,999.99") + SPACE(1)
	ImpTxt := ImpTxt + TRANS(aTotReg[1]/NumMeses,"@E 999,999,999.99")+ SPACE(5)
	ImpTxt := ImpTxt + TRANS(aTotReg[2]/NumMeses,"@E 999,999,999.99")
	li 	 := li + 1

	@ li, 001 PSAY ImpTxt

	aTotReg:= {0,0}

// IF OldPais #cTrb->PAIS		  //IMPRIME O TOTAL DO PAIS
// 	fTotPais()
// 	OldPais:= cTrb->PAIS
// ENDIF

	wPar := cTrb->ESTADO

	IF !cTrb->(EOF())

		li   := li + 2

		IF wPar $ "ZZ"
			@ li, 001 PSAY "REGIAO: " + IIF(EMPTY(cTrb->PAIS),EVAL(bRegiao,3),cTrb->PAIS)

		ELSE
			@ li, 001 PSAY "REGIAO: " + EVAL(bRegiao,1)
		ENDIF

		li := li + 2
		@ li, 001 PSAY "Estado: " + EVAL(bRegiao,3)

	ENDIF

RETURN(NIL)
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fTotEst
Static FUNCTION fTotEst()
	wPar := OldEst
	ImpTxt	:= "Total do Estado: "+EVAL(bRegiao,3)  + SPACE(5)
	ImpTxt	:= ImpTxt + TRANS(aFor[7]			 ,"@E 999,999,999.99") + SPACE(5)
	ImpTxt	:= ImpTxt + TRANS(EVAL(bFoFatPm)  ,"@E 999.99")         + SPACE(1)
	ImpTxt	:= ImpTxt + TRANS(aFor[8]			 ,"@E 999,999,999.99") + SPACE(1)
	ImpTxt	:= ImpTxt + TRANS(aFor[7]/NumMeses,"@E 999,999,999.99")+ SPACE(5)
	ImpTxt	:= ImpTxt + TRANS(aFor[8]/NumMeses,"@E 999,999,999.99")
	aFor		:= {0,0,0,0,0,0,0,0,0,0}
	li 		:= li + 1
	@ li, 001 PSAY ImpTxt
RETURN(NIL)
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpDet
Static FUNCTION fImpDet()
	IF wOrdem == "1"
		ImpTxt := LEFT(aFormato[ASCAN(aFormato,{|x| IIF(wResum,LEFT(x[1],1)==LEFT(cTrb->QUALIDA,1),x[1]==cTrb->QUALIDA) })][2],IIF(wResum,7,9)) + SPACE(iif(wResum,14,12))
		ImpTxt := ImpTxt + TRANS(cTrb->MET_VOL,"@E 999,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(cTrb->MET_PM ,"@E 999.99"    ) + SPACE(1)
		ImpTxt := ImpTxt + TRANS(cTrb->PED_VOL,"@E 999,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bPedPm),"@E 999.99"    ) + SPACE(1)
		ImpTxt := ImpTxt + TRANS(cTrb->FAT_VOL,"@E 999,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bFatPm),"@E 999.99"    ) + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bAtiVol),"@E 9,999.99")  + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bAtiPm),"@E 9,999.99")   + SPACE(1)
		ImpTxt := ImpTxt + TRANS(cTrb->CAR_VOL,"@E 999,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bCarPm),"@E 999.99"    )
	ELSEIF wOrdem == "2"
		ImpTxt := IIF(lRepDif .OR. wResum,cTrb->REP+" "+EVAL(bNome),SPACE(LEN(EVAL(bNome)+cTrb->REP)+1))+SPACE(2)
		ImpTxt := ImpTxt + IIF(wResum,SPACE(7),LEFT(aFormato[ASCAN(aFormato,{|x| LEFT(x[1],1)==LEFT(cTrb->QUALIDA,1)})][2],7)) + SPACE(1)	
		lRepDif:= .F.
		ImpTxt := ImpTxt + TRANS(cTrb->MET_VOL,"@E 999,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(cTrb->MET_PM ,"@E 999.99"    ) + SPACE(1)
		ImpTxt := ImpTxt + TRANS(cTrb->PED_VOL,"@E 999,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bPedPm),"@E 999.99"    ) + SPACE(1)
		ImpTxt := ImpTxt + TRANS(cTrb->FAT_VOL,"@E 999,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bFatPm),"@E 999.99"    ) + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bAtiVol),"@E 9,999.99")  + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bAtiPm),"@E 9,999.99")   + SPACE(1)
		ImpTxt := ImpTxt + TRANS(cTrb->CAR_VOL,"@E 999,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bCarPm),"@E 999.99"    )
	ELSEIF wOrdem == "3"
		ImpTxt := IIF(wResum,SPACE(7),LEFT(aFormato[ASCAN(aFormato,{|x| left(x[1],1)==left(cTrb->QUALIDA,1)})][2],7)) + SPACE(34)
		ImpTxt := ImpTxt + TRANS(cTrb->FAT_VOL,"@E 999,999,999.99")          + SPACE(5)
		ImpTxt := ImpTxt + TRANS(EVAL(bFatPm),"@E 999.99")                  + SPACE(1)
		ImpTxt := ImpTxt + TRANS(cTrb->FAT_PM ,"@E 999,999,999.99")          + SPACE(1)
		ImpTxt := ImpTxt + TRANS(cTrb->FAT_VOL/NumMeses,"@E 999,999,999.99") + SPACE(5)
		ImpTxt := ImpTxt + TRANS(cTrb->FAT_PM/NumMeses ,"@E 999,999,999.99")
	ENDIF
	li 	 := li + 1
	@ li, 001 PSAY ImpTxt
RETURN(NIL)
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpResFin
Static FUNCTION fImpResFin()

	IF wOrdem == "1"
		IF !wResum; fTotFor(); ENDIF
	ELSEIF wOrdem == "2"
		IF !wResum; fTotRep(); ENDIF
	ENDIF

	aTotal[9]  := ROUND((  aTotal[5] / aTotal[1]) * 100,2)
	aTotal[10] := ROUND((EVAL(bTgFatPm)/ aTotal[2]) * 100, 2 )

	IF wOrdem == "3" // POR ESTADO

		fTotEst()
		fTotReg()

		ImpTxt := "TOTAL BRASIL   " + SPACE(26)
		ImpTxt := ImpTxt + TRANS(aTotBra[1] 	 ,"@E 999,999,999.99") + SPACE(5)
		ImpTxt := ImpTxt + TRANS(aTotBra[2]/aTotBra[1],"@E 999.99"    ) + SPACE(1)
		ImpTxt := ImpTxt + TRANS(aTotBra[2] 	 ,"@E 999,999,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(aTotBra[1]/NumMeses,"@E 999,999,999.99") + SPACE(5)
		ImpTxt := ImpTxt + TRANS(aTotBra[2]/NumMeses ,"@E 999,999,999.99")

		li := li + 2

		@ li, 001 PSAY ImpTxt

		ImpTxt := "TOTAL EXTERIOR " + SPACE(26)
		ImpTxt := ImpTxt + TRANS(aTotExt[1] 	 ,"@E 999,999,999.99") + SPACE(5)
		ImpTxt := ImpTxt + TRANS(aTotExt[2]/aTotExt[1],"@E 999.99"    ) + SPACE(1)
		ImpTxt := ImpTxt + TRANS(aTotExt[2] 	 ,"@E 999,999,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(aTotExt[1]/NumMeses,"@E 999,999,999.99") + SPACE(5)
		ImpTxt := ImpTxt + TRANS(aTotExt[2]/NumMeses ,"@E 999,999,999.99")

		li := li + 1

		@ li, 001 PSAY ImpTxt

		li := li + 1

		ImpTxt := "TOTAL GERAL    " + SPACE(26)
		ImpTxt := ImpTxt + TRANS(aTotal[5]			  ,"@E 999,999,999.99") + SPACE(5)
		ImpTxt := ImpTxt + TRANS(aTotal[6]/aTotal[5],"@E 999.99")+ SPACE(1)
		ImpTxt := ImpTxt + TRANS(aTotal[6]			  ,"@E 999,999,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(aTotal[5]/NumMeses ,"@E 999,999,999.99") + SPACE(5)
		ImpTxt := ImpTxt + TRANS(aTotal[6]/NumMeses ,"@E 999,999,999.99")

	ELSE

		IF wOrdem == "1"
			ImpTxt := "TOTAL GERAL" + SPACE(10)
		ELSE
			ImpTxt := "TOTAL GERAL" + SPACE(26)
		ENDIF

		ImpTxt := ImpTxt + TRANS(aTotal[1]		,"@E 999,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bTgMetPm),"@E 999.99"    ) + SPACE(1)
		ImpTxt := ImpTxt + TRANS(aTotal[3]		,"@E 999,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bTgPedPm),"@E 999.99"    ) + SPACE(1)
		ImpTxt := ImpTxt + TRANS(aTotal[5]		,"@E 999,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bTgFatPm),"@E 999.99"    ) + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bTgAtiVo),"@E 9,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bTgAtiPm),"@E 9,999.99"    ) + SPACE(1)
		ImpTxt := ImpTxt + TRANS(aTotal[7]		,"@E 999,999.99") + SPACE(1)
		ImpTxt := ImpTxt + TRANS(EVAL(bTgCarPm),"@E 999.99"    )

	ENDIF

	li := li + 1

	@ li, 001 PSAY ImpTxt

RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fTotal
Static FUNCTION fTotal()
	aTotal[1] := aTotal[1] + cTrb->MET_VOL
	aTotal[2] := aTotal[2] + (cTrb->MET_PM * cTrb->MET_VOL)
	aTotal[3] := aTotal[3] + cTrb->PED_VOL
	aTotal[4] := aTotal[4] + cTrb->PED_PM
	aTotal[5] := aTotal[5] + cTrb->FAT_VOL
	aTotal[6] := aTotal[6] + cTrb->FAT_PM
	aTotal[7] := aTotal[7] + cTrb->CAR_VOL
	aTotal[8] := aTotal[8] + cTrb->CAR_PM
	IF wOrdem == "3"
	  IF cTrb->ESTADO $ "ZZ,EX"
		  aTotExt[1] := aTotExt[1] + cTrb->FAT_VOL
		  aTotExt[2] := aTotExt[2] + cTrb->FAT_PM
	  ELSE
		  aTotBra[1] := aTotBra[1] + cTrb->FAT_VOL
		  aTotBra[2] := aTotBra[2] + cTrb->FAT_PM
	  ENDIF
	ENDIF
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fTotRep
Static FUNCTION fTotRep()
	aRep[9]	:= ROUND(	(aRep[5] / aRep[1]) * 100				 , 2 )
	aRep[10] := ROUND( ( (aRep[6] / aRep[5]) / aRep[2] ) * 100, 2 )
	ImpTxt	:= IIF(wResum,cTrb->REP+" "+EVAL(bNome),"Total do Representante ")+SPACE(14)
	ImpTxt	:= ImpTxt + TRANS(aRep[1]			,"@E 999,999.99")   + SPACE(1)
	ImpTxt	:= ImpTxt + TRANS(EVAL(bReMetPm) ,"@E 999.99"    )   + SPACE(1)
	ImpTxt	:= ImpTxt + TRANS(aRep[3]			,"@E 999,999.99")   + SPACE(1)
	ImpTxt	:= ImpTxt + TRANS(EVAL(bRePedPm) ,"@E 999.99"    )   + SPACE(1)
	ImpTxt	:= ImpTxt + TRANS(aRep[5]			,"@E 999,999.99")   + SPACE(1)
	ImpTxt	:= ImpTxt + TRANS(EVAL(bReFatPm) ,"@E 999.99"    )   + SPACE(1)
	ImpTxt	:= ImpTxt + TRANS(EVAL(bReAtiVo) ,"@E 9,999.99"  )   + SPACE(1)
	ImpTxt	:= ImpTxt + TRANS(EVAL(bReAtiPm) ,"@E 9,999.99"  )   + SPACE(1)
	ImpTxt	:= ImpTxt + TRANS(aRep[7]			,"@E 999,999.99")   + SPACE(1)
	ImpTxt	:= ImpTxt + TRANS(EVAL(bReCarPm) ,"@E 999.99"    )   + SPACE(1)
	aRep		:= {0,0,0,0,0,0,0,0,0,0}
	lRepDif	:= .T.
	li := li + 1
	@ li, 001 PSAY ImpTxt
	li := li + 1
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fTotFor
Static FUNCTION fTotFor()
// IF wOrdem == "1"
		aFor[9]	:= ROUND(	(aFor[5] / aFor[1]) * 100				 , 2 )
		aFor[10] := ROUND( ( (aFor[6] / aFor[5]) / aFor[2] ) * 100, 2 )
		ImpTxt	:= "Total do Formato"                                + SPACE(05)
		ImpTxt	:= ImpTxt + TRANS(aFor[3]			,"@E 999,999.99")   + SPACE(1)
		ImpTxt	:= ImpTxt + TRANS(EVAL(bFoMetPm) ,"@E 999.99"    )   + SPACE(1)
		ImpTxt	:= ImpTxt + TRANS(aFor[5]			,"@E 999,999.99")   + SPACE(1)
		ImpTxt	:= ImpTxt + TRANS(EVAL(bFoPedPm) ,"@E 999.99"    )   + SPACE(1)
		ImpTxt	:= ImpTxt + TRANS(aFor[7]			,"@E 999,999.99")   + SPACE(1)
		ImpTxt	:= ImpTxt + TRANS(EVAL(bFoFatPm) ,"@E 999.99"    )   + SPACE(1)
		ImpTxt	:= ImpTxt + TRANS(EVAL(bFoAtiVo) ,"@E 9,999.99"  )   + SPACE(1)
		ImpTxt	:= ImpTxt + TRANS(EVAL(bFoAtiPm) ,"@E 9,999.99"  )   + SPACE(1)
		ImpTxt	:= ImpTxt + TRANS(aFor[9]			,"@E 999,999.99")   + SPACE(1)
		ImpTxt	:= ImpTxt + TRANS(EVAL(bFoCarPm) ,"@E 999.99"    )   + SPACE(1)
// ENDIF
	aFor		:= {0,0,0,0,0,0,0,0,0,0}
	li := li + 1
	@ li, 001 PSAY ImpTxt
	li := li + 1
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fIncRegua
Static FUNCTION fIncRegua()
	wIncremen := IIF(lCarteira,SC6->C6_YEMISSA,SD2->D2_EMISSAO) - OldData
	IF ( wIncremen > 0 )
		IncProc( wIncremen )
		OldData := IIF(lCarteira,SC6->C6_YEMISSA,SD2->D2_EMISSAO)
	ENDIF
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fValida
Static FUNCTION fValida()

	lLoop := .T.

	IF ! EMPTY(wPais) .AND. ! (RTRIM(SUBS(SA1->A1_YPAIS,1,6)) $ wPais)
		RETURN(NIL)
	ENDIF

	IF EVAL(bProduto,EVAL(bCodPro));RETURN(NIL); ENDIF
	IF ! EVAL(bMercado)		; RETURN(NIL); ENDIF
	IF EVAL(bPedNaoOk)		; RETURN(NIL); ENDIF
	IF !ISALPHA(EVAL(bOld_Qua)); RETURN(NIL); ENDIF
	
	IF VALTYPE(LEFT(EVAL(bCodPro),1)) == "U"
	   ALERT("LEFT(EVAL(bCodPro),1) -> ")
	ENDIF
	IF VALTYPE(SUBS(EVAL(bCodPro),6,1)) == "U"
	   ALERT("SUBS(EVAL(bCodPro),6,1)")
	ENDIF                          
	
	IF EMPTY(EVAL(bFormato)); RETURN(NIL); ENDIF

	lLoop := .F.

RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fTotPais
Static FUNCTION fTotPais()

	ImpTxt  := "TOTAL " + OldPais + SPACE(15)
	ImpTxt  := ImpTxt + TRANS(aTotPais[1]		,"@E 999,999,999.99") + SPACE(5)
	ImpTxt  := ImpTxt + TRANS(aTotPais[2]/aTotPais[1],"@E 999.99"    ) + SPACE(1)
	ImpTxt  := ImpTxt + TRANS(aTotPais[2]		,"@E 999,999,999.99") + SPACE(1)
	ImpTxt  := ImpTxt + TRANS(aTotPais[1]/NumMeses,"@E 999,999,999.99") + SPACE(5)
	ImpTxt  := ImpTxt + TRANS(aTotPais[2]/NumMeses ,"@E 999,999,999.99")
	aTotPais:= {0,0}
	li 	  := li + 2

	@ li, 001 PSAY ImpTxt

RETURN( NIL )

