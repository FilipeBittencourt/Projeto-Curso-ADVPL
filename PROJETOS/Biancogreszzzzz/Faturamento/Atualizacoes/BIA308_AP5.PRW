#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

User Function bia308()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao de variaveis utilizadas no programa atraves da funcao    Ё
//Ё SetPrvt, que criara somente as variaveis definidas pelo usuario,    Ё
//Ё identificando as variaveis publicas do sistema utilizadas no codigo Ё
//Ё Incluido pelo assistente de conversao do AP5 IDE                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

SetPrvt("CDESC1,CDESC2,CDESC3,TAMANHO,LIMITE,CSTRING")
SetPrvt("BTITULO,TITULO,ARETURN,NOMEPROG,NLASTKEY,WNUMBER")
SetPrvt("CBCONT,CPERG,WNREL,C15,CBTXT,LI,ACO")
SetPrvt("M_PAG,WDATADE,WDATAATE,WRANK,WATUALIZA,WFORMATO")
SetPrvt("WMERCADO,WPRODE,WPROATE,WNUMCLI,CABEC1,CABEC2")
SetPrvt("BQUA_SD2,BASCANF2,BPOSFOR,BATIVOL,BATIPM,BTAMREGUA")
SetPrvt("ADIASEMANA,AFOR,ATOTAL,LCABEC,AORDEM,BORDEM")
SetPrvt("WESTADO,ACAMPOS,AFORMATO,BDESCFOR,BFORMATO,BDATAATE")
SetPrvt("BNOTNAOOK,BDEVOLU,BPRODUTO,BMERCADO,WQTDDEVOL,WVALDEVOL")
SetPrvt("WFAT_PM,WFAT_VOL,DATAREGUA,BANOMES,WPMFAT,WVOLMES")
SetPrvt("WVALMES,I,WVARIACUM,NUMMES,BTOTMOV,WTOTALFAT")
SetPrvt("WVARIACAO,IMPTXT,WINCREMEN,ARANK,")

*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Programa : BIA308
// Autor    : AUGUSTO CESAR DE OLIVEIRA
// Data     : 11/06/2000 AS 19:18 a 22:15; 18:15 as 19:45; 19:30 a 21:10
//                          20:10 a
// Descricao: Monta Rank dos dez maiores clientes conforme periodo solicitado
// Uso      : SIGAFAT
// FUNCOES  : fCriaArq()   -> Cria arquivo temporario
//            fTabFor()    -> Cria matriz com os formatos/medidas dos pisos
//            fSeleDado()  -> Seleciona dados a serem impressos
//            fDevolu()    -> Verifica e apropria as devolucoes de venda
//            FGrava()     -> Grava dados selecionados por fSeleDado()
//            aep()    -> Imprime o relatorio ordenado e totalizado por representante
//            fImpDet()    -> Imprime detalhes do relatorio
//            fImpResFin() -> Imprime o resumo final
*-------------------------------------------------------------------------------------------------------------------------------------------------------
#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/01/01 ==>       #DEFINE PSAY SAY
#ENDIF
//Inicializa variaveis
cDesc1    := "Este programa tem como objetivo emitir um relatorio do"
cDesc2    := "Comprativo da Evolucao do Faturamento x Objetivo"
cDesc3    := ""
tamanho   := "M"
limite    := 132
cString   := "SD2"
btitulo   := {|X|"RANK DOS " +X+" MAIORES CLIENTES"}
Titulo    := EVAL(btitulo,"[xxx]")
aRETURN   := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog  := "BIA308"
nLastKey  := wNumber := cbcont := 0
cPerg     := "BIA308"
wnrel     := "BIA308"
C15       := 15
cbtxt     := space(10)
li        := 80
m_pag     := 1
//Envia controle para a funcao SETPRINT
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)
PERGUNTE( cPerg, .F. )
IF ( nLastKey == 27 ) .OR. ( LastKey() == 27 ); RETURN; ENDIF
//PARAMETROS DO RELATROIO
//-----------------------
wDataDe   := mv_par01
wDataAte  := mv_par02
wRank     := mv_par03+1
wAtualiza := mv_par04 == 1
wFormato  := mv_par05
wMercado  := mv_par06
wProDe    := mv_par07
wProAte   := mv_par08
wNumCli   := mv_par09
wCondDe   := mv_par10
wCondAte  := mv_par11

If MV_PAR12 = 1
	GeraDuplicata := "S"
elseIf MV_PAR12 = 2
	GeraDuplicata := "N"
else
	GeraDuplicata := "A"	
end if

If MV_PAR13 = 1
	AtualizaEstoque := "S"
elseIf MV_PAR13 = 2
	AtualizaEstoque := "N"
else
	AtualizaEstoque := "A"	
end if


titulo    := EVAL(bTitulo,STR(wNumCli,3,0))+IIF(wMercado==1," (Mercado: Interno)",;
IIF(wMercado==1," (Mercado: Externo)"," (Mercado: Interno e Externo)"))

//INICIALIZACAO DE VARIAVEIS GLOBAIS
//----------------------------------
Cabec1    := "|    |CODIGO DO|NOME DO                                |CODIGO DO|____MEDIA DO PERIODO____|____APURADO NO MES_____|____VARIACAO____|"
Cabec2    := "|RANK|CLIENTE  |CLIENTE                                |VENDEDOR |  VOLUME  |  VALOR R$   |  VOLUME   |  VALOR R$ |   CLI.|   ACUM.|"
bQua_SD2  := {||LEFT(SD2->D2_COD,1)+SUBS(SD2->D2_COD,6,1)}
bAscanF2  := 'ASCAN( aFormato, { |X| X[1] == EVAL(bQua_SD2)})'
bPosFor   := {|| &bAscanF2 }
bAtiVol   := {||ROUND(cTrb->FAT_VOL / cTrb->MET_VOL * 100,2)}
bAtiPm    := {||ROUND((cTrb->FAT_PM/cTrb->FAT_VOL)/cTrb->MET_PM * 100,2)}
bTamRegua := {||((wDataAte+1)  - wDataDe) }
aDiaSemana:= {"DOMINGO","SEGUNDA","TERCA  ","QUARTA ","QUINTA ","SEXTA  ","SABADO "}
//           1 2 3 4 5 6 7 8 9 0
aFor     := {0,0,0,0,0,0,0,0,0,0}
aTotal   := {0,0,0,0,0,0,0,0,0,0}
lCabec   := .F.
//MONTA TABELA DE ESTADOS
//-----------------------
fTabEst()
//MONTA TABELA DOS FORMATOS DE PISOS
//----------------------------------
fTabFor()
//Verifica Posicao do Formulario na Impressora
SetDefault(aRETURN,cString)

aOrdem    := {"ordcod","ordVolume","ordValor"}
bOrdem    := {|X| aOrdem[X]}

IF ( nLastKey == 27 ) .OR. ( LastKey() == 27 ); RETURN; ENDIF

IF wAtualiza .OR. !FILE("RANK.DBF")
	PROCESSA( {|| fCriaArq() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>       PROCESSA( {|| Execute(fCriaArq) } )
	PROCESSA( {|| fSeleDado()} )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>       PROCESSA( {|| Execute(fSeleDado)} )
ELSE
	DbUseArea(.T.,,"RANK.DBF","cTrb")
	INDEX ON cTrb->COD                TAG ordcod    TO RANK
	INDEX ON cTrb->VOLMES+cTrb->VOLACU TAG ordVolume TO RANK
	INDEX ON cTrb->VALMES+cTrb->VALACU TAG ordValor  TO RANK
	dbSETORDER(1)
ENDIF
PROCESSA( {|| fImprime() } )// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>    PROCESSA( {|| Execute(fImprime) } )
Roda(cbcont,cbtxt,tamanho)
DBSELECTAREA("cTrb")
DBCLOSEAREA()
IF aRETURN[5] == 1
	SET PRINTER TO
	OURSPOOL(wnrel)
ENDIF

FERASE("RANK.DBF")
FERASE("RANK.CDX")

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
FERASE("RANK.DBF")
FERASE("RANK.CDX")
AADD(aCampos,{"COD   ","C",06, 0})                 // Codigo do cliente
//AADD(aCampos,{"NOME  ","C",LEN(SA1->A1_NOME), 0}) // Nome do cliente
AADD(aCampos,{"NOME  ","C",40, 0})                 // Nome do cliente
AADD(aCampos,{"VEND  ","C",06, 0})                 // Codigo do vendedor
AADD(aCampos,{"VOLMES","N",12, 2})                 // Volume no mes
AADD(aCampos,{"VALMES","N",12, 2})                 // Valor no mes
AADD(aCampos,{"VOLACU","N",12, 2})                 // Volume do periodo(acumulado)
AADD(aCampos,{"VALACU","N",12, 2})                 // Valor do periodo(acumulado)
DbCreate("RANK.DBF",aCampos)
DbUseArea(.T.,,"RANK.DBF","cTrb")
INDEX ON cTrb->COD    TAG ordcod    TO RANK
INDEX ON cTrb->VOLACU TAG ordVolume TO RANK
INDEX ON cTrb->VALACU TAG ordValor  TO RANK
dbSETORDER(1)
RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fAbreArq
Static FUNCTION fAbreArq()
RETUNR( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------

Return(nil)        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

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
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fSeleDado
Static FUNCTION fSeleDado()
bFormato  := {||IIF( EVAL(bPosFor) > 0, aFormato[EVAL(bPosFor)][1], "")}
bDataAte  := {||SD2->D2_EMISSAO <= wDataAte }
bNotNaoOk := {||!(SF4->F4_DUPLIC == "S" .AND. SF4->F4_ESTOQUE == "S")}
//.OR.;(SF4->F4_CF $ "711" .AND. SF4->F4_ESTOQUE == "S") }
bDevolu   := {||SD1->(DBSEEK(XFILIAL("SD1")+SD2->D2_DOC+SD2->D2_SERIE))}
bProduto  := {||wProDe > SD2->D2_COD .OR. wProAte < SD2->D2_COD }
bCondicao := {||wCondDe > SF2->F2_COND .OR. wCondAte < SF2->F2_COND }
bMercado  := {||IIF( wMercado == 1, SA1->A1_EST $ wEstado, IIF( wMercado == 3,.T., !(SA1->A1_EST $ wEstado))) }
wQtdDevol := wValDevol := wFAT_PM:= wFAT_VOL := 0
DataRegua := wDataDe
bAnoMes   := {|DATA|LEFT(DTOS(DATA),6)}

DBSELECTAREA("SA1")
DBSETORDER(1)
DBGOTOP()
DBSELECTAREA("SC5")
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
DBSELECTAREA("SF2")
DBSETORDER(1)
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
	
	IF EVAL(bProduto)       ; SD2->(DBSKIP()); LOOP; ENDIF
	IF EVAL(bCondicao)      ; SD2->(DBSKIP()); LOOP; ENDIF
	IF !EVAL(bMercado)      ; SD2->(DBSKIP()); LOOP; ENDIF
	
	
	
	//IF EVAL(bNotNaoOk)      ; SD2->(DBSKIP()); LOOP; ENDIF // comentado por BRUNO MADALENO
	if (GeraDuplicata = SF4->F4_DUPLIC .OR. GeraDuplicata = "A") .AND. ;  // Bruno
		(AtualizaEstoque = SF4->F4_DUPLIC .OR. GeraDuplicata = "A")

		IF EMPTY(EVAL(bFormato)); SD2->(DBSKIP()); LOOP; ENDIF
		IF EVAL(bDevolu)        ; fDevolu()       ; ENDIF
		fGrava()

	ELSE
		SD2->(DBSKIP()) // Bruno
		LOOP // Bruno
	end if	// Bruno
	                                                   
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

wFAT_VOL := (SD2->D2_QUANT-wQtdDevol)
wPmFat   := SD2->D2_TOTAL

IF EVAL(bAnoMes,SD2->D2_EMISSAO) == EVAL(bAnoMes,wDataAte)
	wVolMes  := wFAT_VOL
	wValMes  := wPmFat
ELSE
	wVolMes  := 0
	wValMes  := 0
ENDIF

DBSELECTAREA("cTrb")
dbSETORDER(1)

DBGOTOP()

IF ! DBSEEK(SF2->F2_CLIENTE,.F.)
	WHILE ! RECLOCK("cTrb",.T.); ENDDO
	cTrb->COD   := SF2->F2_CLIENTE
	cTrb->NOME  := SUBS(SA1->A1_NOME,1,40)
	cTrb->VEND  := SF2->F2_VEND1
	cTrb->VOLMES:= cTrb->VOLMES+wVolMes
	cTrb->VALMES:= cTrb->VALMES+wValMes
	cTrb->VOLACU:= cTrb->VOLACU+wFAT_VOL
	cTrb->VALACU:= cTrb->VALACU+wPmFat
ELSE
	WHILE ! RECLOCK("cTrb",.F.); ENDDO
	cTrb->VOLMES:= cTrb->VOLMES+wVolMes
	cTrb->VALMES:= cTrb->VALMES+wValMes
	cTrb->VOLACU:= cTrb->VOLACU+wFAT_VOL
	cTrb->VALACU:= cTrb->VALACU+wPmFat
ENDIF

wQtdDevol := wValDevol := 0
MSUNLOCK()
DBCOMMIT()

RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImprime
Static FUNCTION fImprime()

I := 1
wVariAcum := 0
aTotal := {0,0,0,0,0}
//NumMes:= VAL(EVAL(bAnoMes,wDataAte)) - VAL(EVAL(bAnoMes,wDataDe)) + 1 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁCheca o ano em questao e calcula a quantidade de meses solicitado.Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Year(wDataAte) <= Year(wDataDe)
	NumMes:= VAL(EVAL(bAnoMes,wDataAte)) - VAL(EVAL(bAnoMes,wDataDe)) + 1 
Else
	NumMes := ( 12 - ( Month(wDataDe) - Month(wDataAte) ) ) + 1
EndIf

IF mv_par03 == 1
	bTotMov := {||cTrb->VOLACU/NumMes}
ELSE
	bTotMov := {||cTrb->VALACU/NumMes}
ENDIF

DBSELECTAREA("cTrb")
dbSETORDER(wRank)

DBGOTOP()

SUM EVAL(bTotMov) TO wTotalFat WHILE !EOF()

// DBEval( {|| wTotalFat := wTotalFat + EVAL(bTotMov)},, {|| !EOF()},,, .F. )

DBGOBOTTOM()

WHILE I <= wNumCli .AND. !BOF()
	
	IF li >= 60
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
		lCabec := .T.
		li     := li + 1
		@ li, 001 PSAY "Total faturado: "+ TRANS(wTotalFat,"@E 999,999,999.99")
		li     := li + 1
	ENDIF
	
	wVariacao := (EVAL(bTotMov) / wTotalFat) * 100
	wVariAcum := wVariAcum + wVariacao
	
	fTotal()
	fImpDet()
	
	I := I + 1
	
	DBSKIP(-1)
	
ENDDO

fImpTot()

RETURN( NIL )
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpDet
Static FUNCTION fImpDet()
ImpTxt := STR(I,4,0) + SPACE(2)
ImpTxt := ImpTxt +       cTrb->COD   + SPACE(2)
ImpTxt := ImpTxt +       cTrb->NOME  + SPACE(2)
ImpTxt := ImpTxt +       cTrb->VEND  + SPACE(3)
ImpTxt := ImpTxt + TRANS(cTrb->VOLACU/NumMes,"@E 999,999.99") + SPACE(4)
ImpTxt := ImpTxt + TRANS(cTrb->VALACU/NumMes,"@E 999,999.99") + SPACE(2)
ImpTxt := ImpTxt + TRANS(cTrb->VOLMES,"@E 999,999.99") + SPACE(2)
ImpTxt := ImpTxt + TRANS(cTrb->VALMES,"@E 999,999.99") + SPACE(2)
ImpTxt := ImpTxt + TRANS(wVariacao,"@E 999.99") + SPACE(2)
ImpTxt := ImpTxt + TRANS(wVariAcum,"@E 999.99") + SPACE(2)
li     := li + 1
@ li, 001 PSAY ImpTxt
RETURN(NIL)
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImpTot
Static FUNCTION fImpTot()
ImpTxt := SPACE(6)
ImpTxt := ImpTxt + SPACE(LEN(cTrb->COD)+2)
ImpTxt := ImpTxt + SPACE(LEN(cTrb->NOME)+2)
ImpTxt := ImpTxt + SPACE(LEN(cTrb->VEND)+3)
ImpTxt := ImpTxt + TRANS(aTotal[1],"@E 999,999.99")+SPACE(4)
ImpTxt := ImpTxt + TRANS(aTotal[2],"@E 999,999.99") + SPACE(2)
ImpTxt := ImpTxt + TRANS(aTotal[3],"@E 999,999.99") + SPACE(2)
ImpTxt := ImpTxt + TRANS(aTotal[4],"@E 999,999.99") + SPACE(2)
ImpTxt := ImpTxt + TRANS(aTotal[5],"@E 999.99") + SPACE(2)
li     := li + 2
@ li, 001 PSAY ImpTxt
RETURN(NIL)
*-------------------------------------------------------------------------------------------------------------------------------------------------------
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fTotal
Static FUNCTION fTotal()
aTotal[1] := aTotal[1] + (cTrb->VOLACU/NumMes)
aTotal[2] := aTotal[2] + (cTrb->VALACU/NumMes)
aTotal[3] := aTotal[3] + cTrb->VOLMES
aTotal[4] := aTotal[4] + cTrb->VALMES
aTotal[5] := aTotal[5] + wVariacao
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
