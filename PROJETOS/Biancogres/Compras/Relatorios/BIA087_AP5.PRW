#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

User Function Bia087()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CDESC1,CDESC2,CDESC3,TAMANHO,LIMITE,CSTRING")
SetPrvt("TITULO,ARETURN,CPERG,WNREL,NLASTKEY,WNUMBER")
SetPrvt("CBCONT,CABEC1,CABEC2,C15,CBTXT,LI")
SetPrvt("M_PAG,WCLVLDE,WCLVLATE,WMOEDA,WDATADE,WDATAATE")
SetPrvt("WPRODDE,WPRODATE,ACAMPO,cTrab,WOLDDATA,WINCREGUA")
SetPrvt("WCUSTOT,TOTPROD,TOTGRUPO,TOTCLVL,TOTGERAL,OLDPROD")
SetPrvt("OLDCOD,OLDCLVL,OLDFORNEC,OLDNF,OLDORIGEM,WPRIMVEZ")
SetPrvt("WCLVL,WDESCCLVL,WCDESCPROD,WCDESCFORN,WNTOTUNIT,WLINDEIMP")

//Programa		 : BIA087
//Autor			 : MAGNAGO
//Data			 : 24/01/2000
//Descricao 	 : Despesas por Classe de Valor
//Ordem			 : Classe de Valor + Produto
//Uso 			 : SIGAEST

#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 		#DEFINE PSAY SAY
#ENDIF

//Inicializa variaveis
cDesc1	  := "Este programa tem como objetivo emitir um relatorio de   "
cDesc2	  := "despesas por Classe de Valor.       "
cDesc3	  := ""
tamanho	  := "G"
limite	  := 200
cString	  := "SD3"
titulo	  := "DESPESAS POR CLASSE DE VALOR"
aReturn    := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
cPerg 	  := "BIA087"
wnrel 	  := "BIA087"
nLastKey   := wNumber := cbcont := 0
Cabec1	  :="C.CUSTO DESCRICAO                  PRODUTO          DESCRICAO                      N.FISCAL        FORNECEDOR                         UN    QUANTIDADE         CUSTO         CUSTO"
Cabec2	  :="                                                                                                                                                            UNITARIO         TOTAL"
C15		  := 15
cbtxt      := space(10)
li 	     := 80
m_pag      := 1

PERGUNTE( cPerg, .F. )

//Envia controle para a funcao SETPRINT
wnrel:= SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,""  ,.F.,tamanho)
IF ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
	Return
ENDIF

//Verifica Posicao do Formulario na Impressora
SetDefault(aReturn,cString)
IF ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
	Return
ENDIF

wCLVLDe  := mv_par01 // C.Valor de
wCLVLAte := mv_par02 // C.Valor ate
wMoeda	 := mv_par03 // Qual Moeda
wDatade	 := mv_par04 // Emissao Requisicoes de
wDataAte  := mv_par05 // Emissao Requisicoes ate
wProdDe	 := mv_par06 // Produto de
wProdAte  := mv_par07 // Produto ate

fCriaArq()

RptStatus({|| fMapAtePed() })  // Fun‡Æo Despesas por Classe de Valor// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	RptStatus({|| Execute(fMapAtePed) })  // Fun‡Æo Despesas por Classe de Valor
DBSELECTAREA("cTrab")
DBCLOSEAREA("cTrab")
FERASE(cTrab+".*")

//Libera impressao
IF aReturn[5] == 1
	Set Printer To
	Ourspool(cPerg)
ENDIF
MS_FLUSH()
//Fim do programa
RETURN( NIL )

// CRIA ARQUIVO TEMPORARIO
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fCriaArq
Static FUNCTION fCriaArq()

aCampo	:= { { "PRODUTO ", "C", 15, 0 },;
{ "FORNECE ", "C", 06, 0 },;
{ "CLVL"  , "C", 09, 0 },;
{ "NRNF"    , "C", 06, 0 },;
{ "ORIGEM"  , "C", 03, 0 },;
{ "TIPO"    , "C", 01, 0 },;
{ "SERIE"   , "C", 03, 0 },;
{ "QTD"     , "N", 11, 4 },;
{ "CUSTOT"  , "N", 14, 2 },;
{ "DESC"    , "C", 30, 0 },;
{ "CUSUNIT" , "N", 11, 4 } }

cTrab := CRIATRAB(aCampo, .T.)
DBUSEAREA(.T.,,cTrab,"cTrab")

DBCREATEINDEX(cTrab,"CLVL+PRODUTO",{||CLVL+PRODUTO} )

RETURN( NIL )


// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fMapAtePed
Static FUNCTION fMapAtePed()

DBSELECTAREA("SD3")
DBSETORDER(6)

DBSEEK( xFILIAL("SD3")+DTOS(wDataDe),.T. )

SETREGUA( wDataAte - wDataDe )
wOldData := CTOD("")

WHILE !EOF() .AND. ( SD3->D3_EMISSAO <= wDataAte )
	
	// VALIDA: SE FOI INCREMENTADA A DATA
	IF wOldData == CTOD("") .OR. wOldData < SD3->D3_EMISSAO
		wIncRegua := IIF( wOldData == CTOD(""), 1, SD3->D3_EMISSAO - wOldData )
		wOldData  := SD3->D3_EMISSAO
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
	
	// PESQUISA: SE O CLASSE DE VALOR E O SOLICITADO
	IF SD3->D3_CLVL < wCLVLde
		DBSELECTAREA("SD3")
		DBSKIP()
		LOOP
	ENDIF
	
	IF SD3->D3_CLVL > wCLVLate
		DBSELECTAREA("SD3")
		DBSKIP()
		LOOP
	ENDIF
	
	// PESQUISA: SE O PRODUTO E O SOLICITADO
	IF SD3->D3_COD < wProdDe
		DBSELECTAREA("SD3")
		DBSKIP()
		LOOP
	ENDIF
	
	IF SD3->D3_COD > wProdAte
		DBSELECTAREA("SD3")
		DBSKIP()
		LOOP
	ENDIF
	
	DBSELECTAREA("SB1")
	DBSETORDER(1)
	
	// PESQUISA: SE PRODUTO EXISTE NO CADASTRO DE PRODUTOS
	IF ! DBSEEK( xFilial("SB1")+SD3->D3_COD,.T. )
		DBSELECTAREA("SD3")
		DBSKIP()
		LOOP
	ENDIF
	
	IF SUBST(SB1->B1_TIPO,1,2) == "PA"
		DBSELECTAREA("SD3")
		DBSKIP()
		LOOP
	ENDIF
	
	fGravaSD3()
	
	DBSELECTAREA("SD3")
	DBSETORDER(6)
	DBSKIP()
ENDDO

DBSELECTAREA("SD1")
DBSETORDER(6)

DBSEEK( xFILIAL("SD1")+DTOS(wDataDe),.T. )

SETREGUA( wDataAte - wDataDe )
wOldData := CTOD("")

WHILE !EOF() .AND. ( SD1->D1_DTDIGIT <= wDataAte )
	
	// VALIDA: SE FOI INCREMENTADA A DATA
	IF wOldData == CTOD("") .OR. wOldData < SD1->D1_DTDIGIT
		wIncRegua := IIF( wOldData == CTOD(""), 1, SD1->D1_DTDIGIT - wOldData )
		wOldData  := SD1->D1_DTDIGIT
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
	
	// PESQUISA: SE O CLASSE DE VALOR E O SOLICITADO
	IF SD1->D1_CLVL < wCLVLde
		DBSELECTAREA("SD1")
		DBSKIP()
		LOOP
	ENDIF
	
	IF SD1->D1_CLVL > wCLVLate
		DBSELECTAREA("SD1")
		DBSKIP()
		LOOP
	ENDIF
	
	// PESQUISA: SE O PRODUTO E O SOLICITADO
	IF SD1->D1_COD < wProdDe
		DBSELECTAREA("SD1")
		DBSKIP()
		LOOP
	ENDIF
	
	IF SD1->D1_COD > wProdAte
		DBSELECTAREA("SD1")
		DBSKIP()
		LOOP
	ENDIF
	
	// PESQUISA: SE A CONTA CONTABIL ESTA NO INTERVALO ABAIXO
	IF SUBST(SD1->D1_CONTA,1,8) < "32101001"
		DBSELECTAREA("SD1")
		DBSKIP()
		LOOP
	ENDIF
	
	IF SUBST(SD1->D1_CONTA,1,8) > "51599999"
		DBSELECTAREA("SD1")
		DBSKIP()
		LOOP
	ENDIF
	
	DBSELECTAREA("SB1")
	DBSETORDER(1)
	
	// PESQUISA: SE PRODUTO EXISTE NO CADASTRO DE PRODUTOS
	IF ! DBSEEK( xFilial("SD1")+SD1->D1_COD,.T. )
		DBSELECTAREA("SD1")
		DBSKIP()
		LOOP
	ENDIF
	
	IF SUBST(SB1->B1_TIPO,1,2) == "PA"
		DBSELECTAREA("SD1")
		DBSKIP()
		LOOP
	ENDIF
	
	fGravaSD1()
	
	DBSELECTAREA("SD1")
	DBSETORDER(6)
	DBSKIP()
ENDDO

DBSELECTAREA("SI2")
DBSETORDER(3)

DBSEEK( xFILIAL("SI2")+DTOS(wDataDe),.T. )

SETREGUA( wDataAte - wDataDe )
wOldData := CTOD("")

WHILE !EOF() .AND. ( SI2->I2_DATA <= wDataAte )
	
	// VALIDA: SE FOI INCREMENTADA A DATA
	IF wOldData == CTOD("") .OR. wOldData < SI2->I2_DATA
		wIncRegua := IIF( wOldData == CTOD(""), 1, SI2->I2_DATA - wOldData )
		wOldData  := SI2->I2_DATA
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
	
	// PESQUISA: SE O LOTE É IGUAL A 8801
	IF SUBST(SI2->I2_NUM,1,4) <> "8801"
		DBSELECTAREA("SI2")
		DBSKIP()
		LOOP
	ENDIF
	
	// PESQUISA: SE A CONTA CONTABIL É MAIOR QUE 32100000
	IF SUBST(SI2->I2_DEBITO,1,8) < "32100000"
		DBSELECTAREA("SI2")
		DBSKIP()
		LOOP
	ENDIF
	
	// PESQUISA: SE A CONTA DEBITO PERTENCE A CLASSE DE VALOR ESCOLHIDA
	IF SUBST(SI2->I2_DEBITO,9,4) < SUBST(wCLVLde,1,4)
		DBSELECTAREA("SI2")
		DBSKIP()
		LOOP
	ENDIF
	
	// PESQUISA: SE A CONTA DEBITO PERTENCE A CLASSE DE VALOR ESCOLHIDA
	IF SUBST(SI2->I2_DEBITO,9,4) > SUBST(wCLVLate,1,4)
		DBSELECTAREA("SI2")
		DBSKIP()
		LOOP
	ENDIF
	
	fGravaSI2()
	
	DBSELECTAREA("SI2")
	DBSETORDER(3)
	DBSKIP()
ENDDO

fImprime()

RETURN( NIL )

//GRAVA: DADOS NO ARQUIVO TEMPORARIO LENDO O ARQUIVO SD3 - MOV. INTERNAS
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fGravaSD3
Static FUNCTION fGravaSD3()

DBSELECTAREA("SF5")
DBSETORDER(1)
DBSEEK(xFILIAL("SF5")+SD3->D3_TM,.T.)
DBSELECTAREA("cTrab")

WHILE !RECLOCK( "cTrab",.T.); ENDDO

wCUSTOT		  := 0
cTrab->PRODUTO  := SD3->D3_COD
cTrab->FORNECE  := SPACE(6)
cTrab->CLVL   := SD3->D3_CLVL
cTrab->NRNF	  := SPACE(6)
cTrab->SERIE	  := SPACE(3)
cTrab->QTD 	  := SD3->D3_QUANT
cTrab->ORIGEM   := "SD3"
DO CASE
	CASE wMoeda   == 1
		wCUSTOT	  := SD3->D3_CUSTO1
	CASE wMoeda   == 2
		wCUSTOT	  := SD3->D3_CUSTO2
	CASE wMoeda   == 3
		wCUSTOT	  := SD3->D3_CUSTO3
	CASE wMoeda   == 4
		wCUSTOT	  := SD3->D3_CUSTO4
	CASE wMoeda   == 5
		wCUSTOT	  := SD3->D3_CUSTO5
ENDCASE
cTrab->TIPO	  := SF5->F5_TIPO
cTrab->CUSTOT   := wCUSTOT
cTrab->CUSUNIT  := wCUSTOT / cTrab->QTD
cTrab->DESC	  := SPACE(30)

MSUNLOCK()

RETURN( NIL )

//GRAVA: DADOS NO ARQUIVO TEMPORARIO LENDO O ARQUIVO SD1 - NOTAS FISCAIS ENTRADA
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fGravaSD1
Static FUNCTION fGravaSD1()

DBSELECTAREA("cTrab")

WHILE !RECLOCK( "cTrab",.T.); ENDDO

wCUSTOT		  := 0
cTrab->PRODUTO  := SD1->D1_COD
cTrab->FORNECE  := SD1->D1_FORNECE
cTrab->CLVL   := SD1->D1_CLVL
cTrab->NRNF	  := SD1->D1_DOC
cTrab->SERIE	  := SD1->D1_SERIE
cTrab->QTD 	  := SD1->D1_QUANT
cTrab->ORIGEM   := "SD1"
DO CASE
	CASE wMoeda   == 1
		wCUSTOT	  := SD1->D1_CUSTO - SD1->D1_ICMSCOM
	CASE wMoeda   == 2
		wCUSTOT	  := SD1->D1_CUSTO2
	CASE wMoeda   == 3
		wCUSTOT	  := SD1->D1_CUSTO3
	CASE wMoeda   == 4
		wCUSTOT	  := SD1->D1_CUSTO4
	CASE wMoeda   == 5
		wCUSTOT	  := SD1->D1_CUSTO5
ENDCASE
cTrab->TIPO	  := SPACE(1)
cTrab->CUSTOT   := wCUSTOT
cTrab->CUSUNIT  := wCUSTOT / cTrab->QTD
cTrab->DESC	  := SPACE(30)

MSUNLOCK()

RETURN( NIL )

//GRAVA: DADOS NO ARQUIVO TEMPORARIO LENDO O ARQUIVO SI2 - LANCTO CONTABEIS
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fGravaSI2
Static FUNCTION fGravaSI2()

DBSELECTAREA("cTrab")

WHILE !RECLOCK( "cTrab",.T.); ENDDO

cTrab->PRODUTO  := "PAGAMENTOS     "
cTrab->FORNECE  := SPACE(6)
IF SUBST(SI2->I2_DEBITO,9.4) == "   "
	cTrab->CLVL := "1090     "
ELSE
	cTrab->CLVL := SUBST(SI2->I2_DEBITO,9,4)+SPACE(5)
ENDIF
cTrab->NRNF	  := SPACE(6)
cTrab->SERIE	  := SPACE(3)
cTrab->QTD 	  := 0
cTrab->ORIGEM   := "SI2"
cTrab->TIPO	  := SPACE(1)
cTrab->CUSTOT   := xMoeda(SI2->I2_VALOR,1,wMoeda,SI2->I2_DATA)
cTrab->CUSUNIT  := 0
cTrab->DESC	  := SUBST(SI2->I2_HIST,1,30)

MSUNLOCK()

RETURN( NIL )

//IMPRIME: OS DADOS DA TABELA TEMPORµRIA
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fImprime
Static FUNCTION fImprime()

DBSELECTAREA("cTrab")
DBGOTOP()

SETREGUA( cTrab->( LASTREC() ) )

// SE€ÇO PARA INICIALIZA€ÇO DAS VARIµVEIS DE TRABALHO

totProd	   := { 0, 0, 0 }
totGrupo   := { 0, 0, 0 }
totCLVL    := { 0, 0, 0 }
totGeral   := { 0, 0, 0 }

OldProd	  := SUBST(cTrab->PRODUTO,1,3)
OldCod	  := cTrab->PRODUTO
OldCLVL	  := cTrab->CLVL
OldFornec  := cTrab->FORNECE
OldNf 	  := cTrab->NRNF
OldOrigem  := cTrab->ORIGEM

wPrimVez   := .T.

// SE€ÇO IMPRESSAO
WHILE ! cTrab->( EOF() )
	
	INCREGUA()
	
	// IMPRIME CABE€ALHO
	IF li >= 60
		li := Cabec(titulo,cabec1,cabec2,cPerg,tamanho,15) + 2
	ENDIF
	
	IF wPrimVez
		wCLVL := cTrab->CLVL
		@ li, 000 PSAY SUBST(wCLVL,1,4)
		DBSELECTAREA("CTH")
		DBSETORDER(1)
		DBSEEK(xFILIAL("CTH")+cTrab->CLVL,.T.)
		IF !FOUND()
			wDescCLVL := "C.VALOR NAO EXISTE......."
		ELSE
			wDescCLVL := CTH->CTH_DESC01
		ENDIF
		@ li, 008 PSAY wDescCLVL
		wCLVL 	  := SPACE(9)
		wDescCLVL	:= SPACE(25)
		wPrimVez  := .F.
	ENDIF
	
	//QUEBRA CLASSE DE VALOR
	WHILE OldCLVL == cTrab->CLVL
		
		//QUEBRA GRUPO DE PRODUTOS
		WHILE OldProd == SUBST(cTrab->PRODUTO,1,3)
			
			//QUEBRA PRODUTO
			WHILE OldCod == cTrab->PRODUTO .AND. OldOrigem <> SPACE(3)
				
				DO CASE
					CASE cTrab->TIPO == "R"
						TotProd[1]	:= TotProd[1] + cTrab->QTD
						TotProd[2]	:= TotProd[2] + cTrab->CUSUNIT
						TotProd[3]	:= TotProd[3] + cTrab->CUSTOT
					CASE cTrab->TIPO == "D"
						TotProd[1]	:= TotProd[1] - cTrab->QTD
						TotProd[2]	:= TotProd[2] - cTrab->CUSUNIT
						TotProd[3]	:= TotProd[3] - cTrab->CUSTOT
					CASE cTrab->TIPO == " "
						TotProd[1]	:= TotProd[1] + cTrab->QTD
						TotProd[2]	:= TotProd[2] + cTrab->CUSUNIT
						TotProd[3]	:= TotProd[3] + cTrab->CUSTOT
				ENDCASE
				
				wcDescProd := cTrab->DESC
				DBSELECTAREA("cTrab")
				DBSKIP()
				
				IF cTrab->ORIGEM == "SD1" .OR. cTrab->ORIGEM == "SI2"
					OldOrigem	:= SPACE(3)
				ENDIF
				
			ENDDO
			
			IF wcDescProd == SPACE(30)
				DBSELECTAREA("SB1")
				DBSETORDER(1)
				DBSEEK(xFILIAL("SB1")+OldCod,.T.)
				IF !FOUND()
					wcDescProd := "PRODUTO NAO EXISTE............"
				ELSE
					wcDescProd := SUBST(SB1->B1_DESC,1,30)
				ENDIF
			ENDIF
			
			DBSELECTAREA("SA2")
			DBSETORDER(1)
			DBSEEK(xFILIAL("SA2")+OldFornec,.T.)
			IF !FOUND()
				wcDescForn := "                         "
			ELSE
				wcDescForn := SUBST(SA2->A2_NOME,1,25)
			ENDIF
			
			// IMPRIME CABE€ALHO
			IF li >= 60
				li := Cabec(titulo,cabec1,cabec2,cPerg,tamanho,15) + 2
			ENDIF
			
			wnTotUnit := 0
			wnTotUnit := TotProd[3] / TotProd[1]
			
			wLinDeImp := OldCod																+ SPACE( 2 )
			wLinDeImp := wLinDeImp + wcDescProd 										+ SPACE( 2 )
			wLinDeImp := wLinDeImp + OldNf												+ SPACE( 2 )				+ SPACE( 2 )
			wLinDeImp := wLinDeImp + cTrab->SERIE 										+ SPACE( 2 )
			wLinDeImp := wLinDeImp + OldFornec										+ SPACE( 2 )
			wLinDeImp := wLinDeImp + wcDescForn 										+ SPACE( 2 )
			wLinDeImp := wLinDeImp + SB1->B1_UM 										+ SPACE( 2 )
			wLinDeImp := wLinDeImp + TRANS(TotProd[1], "@R 9,999,999.99")     + SPACE( 2 )
			wLinDeImp := wLinDeImp + TRANS(wnTotUnit,  "@R 999,999.9999")     + SPACE( 2 )
			wLinDeImp := wLinDeImp + TRANS(TotProd[3], "@R 9,999,999.99")
			
			TotGrupo[1] := TotGrupo[1] + Totprod[1]
			TotGrupo[2] := TotGrupo[2] + Totprod[2]
			TotGrupo[3] := TotGrupo[3] + Totprod[3]
			TotProd[1]	:= TotProd[2] := TotProd[3] := 0
			@ li, 035 PSAY wLinDeImp
			OldCod		:= cTrab->PRODUTO
			OldFornec	:= cTrab->FORNECE
			OldNf 		:= cTrab->NRNF
			OldOrigem	:= cTrab->ORIGEM
			
			li := li + 1
		ENDDO
		
		li := li + 1
		wLinDeImp := "TOTAL DO GRUPO   " + SUBST(OldProd,1,3)         + SPACE( 83 )
		wLinDeImp := wLinDeImp + TRANS(TotGrupo[1],"@E 9,999,999.99") + SPACE( 16 )
		// 			wLinDeImp := wLinDeImp + TRANS(TotGrupo[2],"@E 999,999.9999") + SPACE( 02 )
		wLinDeImp := wLinDeImp + TRANS(TotGrupo[3],"@E 9,999,999.99")
		
		TotCLVL[1] := TotCLVL[1] + TotGrupo[1]
		TotCLVL[2] := TotCLVL[2] + TotGrupo[2]
		TotCLVL[3] := TotCLVL[3] + TotGrupo[3]
		TotGrupo[1]  := TotGrupo[2] := TotGrupo[3] := 0
		@ li, 035 PSAY wLinDeImp
		OldProd		 := SUBST(cTrab->PRODUTO,1,3)
		
		li := li + 2
	ENDDO
	
	wLinDeImp := "TOTAL DO C.CUSTO " + OldCLVL                   + SPACE( 77 )
	wLinDeImp := wLinDeImp + TRANS(TotCLVL[1],"@E 9,999,999.99") + SPACE( 16 )
	// 	wLinDeImp := wLinDeImp + TRANS(TotCLVL[2],"@E 999,999.9999") + SPACE( 02 )
	wLinDeImp := wLinDeImp + TRANS(TotCLVL[3],"@E 9,999,999.99")
	
	@ li, 035 PSAY wLinDeImp
	li := li + 2
	
	TotGeral[1]  := TotGeral[1] + TotCLVL[1]
	TotGeral[2]  := TotGeral[2] + TotCLVL[2]
	TotGeral[3]  := TotGeral[3] + TotCLVL[3]
	TotCLVL[1] := TotCLVL[2] := TotCLVL[3] := 0
	OldCLVL 	 := cTrab->CLVL
	wPrimVez 	 := .T.
	
ENDDO

li := li + 1

wLinDeImp := "TOTAL GERAL      "                              + SPACE( 86 )
wLinDeImp := wLinDeImp + TRANS(TotGeral[1],"@E 9,999,999.99") + SPACE( 16 )
// wLinDeImp := wLinDeImp + TRANS(TotGeral[2],"@E 999,999.9999") + SPACE( 02 )
wLinDeImp := wLinDeImp + TRANS(TotGeral[3],"@E 9,999,999.99")

@ li, 035 PSAY wLinDeImp
li := li + 2

TotGeral[1] := TotGeral[2] := TotGeral[3] := 0

//RODAPE
Roda(cbcont,cbtxt,tamanho)

RETURN( NIL )