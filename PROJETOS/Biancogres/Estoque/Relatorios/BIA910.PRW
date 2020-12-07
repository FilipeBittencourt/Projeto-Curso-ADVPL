#INCLUDE "MATR275.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ BIA910 	³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 09/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Kardex p/ Lote Sobre o SDB                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Patricia Sal³13.09.00³XXXXXX³Inclusao mv_par15 (Lista os Estornos ?)   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA910()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cDesc1    := STR0001	//"Este programa emitir  um Kardex com todas as movimenta‡”es"
LOCAL cDesc2    := STR0002	//"do estoque por Localizacao e Numero de Serie, diariamente."
LOCAL cDesc3    := ""
LOCAL titulo	 := STR0003	//"Kardex por Localizacao (por produto)"
LOCAL wnrel     := "MATR275"
LOCAL Tamanho   := "G"
LOCAL cString   := "SDB"

PRIVATE aReturn:= {STR0004,1,STR0005, 1, 2, 1, "",1 }	//"Zebrado"###"Administracao"
PRIVATE aLinha := { },nLastKey := 0
PRIVATE cPerg  :="MTR276"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("MTR276",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                    	³
//³ mv_par01       	// Do  Produto                         	    ³
//³ mv_par02        	// Ate Produto                         	³
//³ mv_par03        	// De  Lote                            	³
//³ mv_par04        	// Ate Lote			        			³
//³ mv_par05        	// De  Sub-Lote                         ³
//³ mv_par06        	// Ate Sub-Lote			        		³
//³ mv_par07        	// De  Local		        			³
//³ mv_par08        	// Ate Local							³
//³ mv_par09        	// De  Data			        			³
//³ mv_par10        	// Ate Data								³
//³ mv_par11        	// De  Localizacao      				³
//³ mv_par12        	// Ate Localizacao   					³
//³ mv_par13        	// De  Numero de Serie  				³
//³ mv_par14        	// Ate Numero de Serie  				³
//³ mv_par15        	// Lista os Estornos    				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel :=SetPrint(cString,wnrel,cPerg,titulo,cDesc1,cDesc2,cDesc3,.F.,,.f.,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| C275Imp(@lEnd,wnRel,tamanho,titulo)},titulo)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C275IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 09/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR275			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C275Imp(lEnd,WnRel,tamanho,titulo)

LOCAL cNomArq2:=""
LOCAL cPictQt:=PesqPict("SDB","DB_QUANT",17)
LOCAL nSaldoIni:=nEntrada:=nSaida:=0
LOCAL nTipo := IIF(aReturn[4]==1,15,18)
LOCAL nIndDB := 0
LOCAL cCond2 :=""
LOCAL cIndex2:= ""
LOCAL cProd , cLocal, cLocaliz, cLoteCtl, cNumLote, cQuantSegun

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cbtxt := SPACE(10)
PRIVATE cbcont:= 0
PRIVATE li    := 80
PRIVATE m_pag := 01

PRIVATE cabec1  := "PRODUTO  LOTE   DESCRICAO                      LOCAL LOCALIZACAO   DATA MOVIM    DOCUMENTO  SERIE EST SALDO INICIAL    ENTRADA/M2     ENTRADA/CX        SAIDA/M2        SAIDA/CX       SALDO/M2       SALDO/CX    DATA SAIDA"
PRIVATE cabec2  := ""
//--                123456789012345 123456789012345678901234567890  99   123456789012345 99/99/9999  999999999999  123   X  12345678901234 12345678901234 12345678901234 12345678901234 12345678901234
//--                0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
//--                01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

/* Cabecalho Original
PRIVATE cabec1  := STR0006	//"PRODUTO         DESCRICAO                      LOCAL LOCALIZACAO     NUMERO DE SERIE      LOTE       SUBLOTE DATA MOVIM    DOCUMENTO  SERIE EST SALDO INICIAL    ENTRADA        SAIDA          SALDO"
PRIVATE cabec2  := ""
//--                         123456789012345 123456789012345678901234567890  99   123456789012345 12345678901234567890 1234567890  123456 99/99/9999  999999999999  123   X  12345678901234 12345678901234 12345678901234 12345678901234
//--                         0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19
//--                         01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega o nome do arquivo de indice de trabalho             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq2 := Substr(CriaTrab(NIL,.F.),1,7)+"A"

cPictQt := "@E 99,999,999.99999"

cIndex2:="DB_PRODUTO+DB_LOCAL+DB_LOCALIZ+DB_NUMSERI+DB_LOTECTL+DB_NUMLOTE+DTOS(DB_DATA)+DB_NUMSEQ"

cCond2 := 'DB_FILIAL=="'+xFilial("SDB")+'".And.DB_PRODUTO>="'+mv_par01+'".And.DB_PRODUTO<="'+mv_par02+'".And.'
cCond2 += 'DB_LOCALIZ>="'+mv_par11+'".And.DB_LOCALIZ<="'+mv_par12+'".And.'
cCond2 += 'DB_LOTECTL>="'+mv_par03+'".And.DB_LOTECTL<="'+mv_par04+'".And.'
cCond2 += 'DB_LOCAL>="'+mv_par07+'".And.DB_LOCAL<="'+mv_par08+'"'
#IFDEF TOP
	cCond2 += '.And.DB_NUMLOTE>="'+mv_par05+'".And.DB_NUMLOTE<="'+mv_par06+'".And.'
	cCond2 += 'DB_NUMSERI>="'+mv_par13+'".And.DB_NUMSERI<="'+mv_par14+'".And.'
	cCond2 += 'DTOS(DB_DATA)>="'+DTOS(mv_par09)+'".And.DTOS(DB_DATA)<="'+DTOS(mv_par10)+'"'
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adapacao ao APDL - Considera somente mov. que atual. Estoque ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar('MV_INTDL', 'N') == 'S'
	cCond2 += '.And.!(DB_ATUEST=="N")'
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o indice de trabalho                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SDB")
IndRegua("SDB",cNomArq2,cIndex2,,If(!Empty(aReturn[7]),aReturn[7]+'.And.','')+cCond2,STR0008) //"Selecionando Registros..."
nIndDB := RetIndex('SDB')
#IFNDEF TOP
	dbSetIndex(cNomArq2 + OrdBagExt())
#ENDIF
dbSetOrder(nIndDB + 1)
dbGoTop()

SetRegua(LastRec())

Do While !Eof()
	
	IncRegua()
	If DB_ESTORNO == "S"  .And. mv_par15 == 2
		DbSkip()
		Loop
	EndIf
	
	#IFNDEF TOP
		If DB_NUMLOTE < mv_par05 .Or. DB_NUMLOTE > mv_par06
			DbSkip()
			Loop
		EndIf
		If DB_NUMSERI < mv_par13 .Or. DB_NUMSERI > mv_par14
			DbSkip()
			Loop
		EndIf
		If DB_DATA < mv_par09 .Or. DB_DATA > mv_par10
			DbSkip()
			Loop
		EndIf
	#ENDIF
	
	IF lEnd
		@PROW()+1,001 PSAY STR0007 //"CANCELADO PELO OPERADOR"
		EXIT
	ENDIF
	
	nSaldoIni:=nEntrada:=nSaida:=0
	
	nSaldoIni:=CalcEstL(DB_PRODUTO,DB_LOCAL,mv_par09,DB_LOTECTL,DB_NUMLOTE,DB_LOCALIZ,DB_NUMSERI)[1]
	
	IF li > 58
		cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
	EndIF
	
	@ li,000 PSAY SUBSTR(DB_PRODUTO,1,8)+"-"+DB_LOTECTL
	If SB1->(dbSeek(xFilial("SB1")+SDB->DB_PRODUTO))
		@ li,016 PSAY Substr(SB1->B1_DESC,1,30)
	EndIf
	@ li,048 PSAY DB_LOCAL
	@ li,053 PSAY DB_LOCALIZ
	//@ li,102 PSAY DB_NUMLOTE
	@ li,100 PSAY nSaldoIni PICTURE cPictQt
	
	Li++
	
	cProd    := DB_PRODUTO
	cLocal   := DB_LOCAL
	cLocaliz := DB_LOCALIZ
	cLoteCtl := DB_LOTECTL
	cNumLote := DB_NUMLOTE
	
	Do While !Eof() .And. cProd+cLocal+cLocaliz+cLoteCtl+cNumLote == DB_PRODUTO+DB_LOCAL+DB_LOCALIZ+DB_LOTECTL+DB_NUMLOTE
		
		If DB_ESTORNO == "S"  .And. mv_par15 == 2
			DbSkip()
			Loop
		EndIf
		
		#IFNDEF TOP
			If DB_NUMLOTE < mv_par05 .Or. DB_NUMLOTE > mv_par06
				DbSkip()
				Loop
			EndIf
			If DB_NUMSERI < mv_par13 .Or. DB_NUMSERI > mv_par14
				DbSkip()
				Loop
			EndIf
			If DB_DATA < mv_par09 .Or. DB_DATA > mv_par10
				DbSkip()
				Loop
			EndIf
		#ENDIF
		
		IF li > 58
			cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		EndIF
		
		//@ li,069 PSAY DB_NUMSERI
		@ li,069 PSAY DB_DATA
		
		If Alltrim(SDB->DB_ORIGEM) $ "SC6,SD2"
			SD2->(DbSetOrder(3))
			SD2->(DbSeek(xFilial("SD2")+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA+SDB->DB_PRODUTO))
			SC9->(DbSetOrder(13))
			SC9->(DbSeek(xFilial("SC9")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_ITEMPV+SD2->D2_COD))
			SZ9->(DbSetOrder(7))
			If SZ9->(DbSeek(xFilial("SZ9")+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_PEDIDO+SC9->C9_AGREG))
				@ li,081 PSAY SZ9->Z9_NUMERO
				@ li,092 PSAY "ROM"
			Else
				@ li,081 PSAY DB_DOC
				@ li,092 PSAY DB_SERIE
			EndIf
		Else
			@ li,081 PSAY DB_DOC
			// Condição incluída por Marcos Alberto em 09/02/12
			If Alltrim(SDB->DB_DOC) <> "INVENT"
				SD3->(DbSetOrder(2))
				If SD3->(DbSeek(xFilial("SD3")+SDB->DB_DOC+SDB->DB_PRODUTO))
					@ li,092 PSAY SD3->D3_TM
				Else
					@ li,092 PSAY DB_TM
				EndIf
			Else
				@ li,092 PSAY DB_TM
			EndIf
			
		EndIf
		@ li,100 PSAY DB_ESTORNO
		If SDB->DB_TM <= "500" .Or. Substr(SDB->DB_TM,1,1) $ "PD"
			@ li,115 PSAY DB_QUANT PICTURE cPictQt
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SDB->DB_PRODUTO))
			@ li,130 PSAY DB_QUANT/SB1->B1_CONV PICTURE cPictQt
			nEntrada+=DB_QUANT
		Else
			@ li,145 PSAY DB_QUANT PICTURE cPictQt
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SDB->DB_PRODUTO))
			@ li,160 PSAY DB_QUANT/SB1->B1_CONV PICTURE cPictQt
			nSaida+=DB_QUANT
		EndIf
		@ li,177 PSAY (nSaldoIni+nEntrada) - nSaida PICTURE cPictQt
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SDB->DB_PRODUTO))
		@ li,192 PSAY ((nSaldoIni+nEntrada) - nSaida)/SB1->B1_CONV PICTURE cPictQt
		If SDB->DB_TM == "509"
			@ li,212 PSAY SD3->D3_YDS
		EndIf
		Li++
		dbSkip()
	EndDo
	
EndDo

IF li != 80
	roda(cbcont,cbtxt,Tamanho)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve as ordens originais do arquivo                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RetIndex("SDB")
Set Filter to

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga indice de trabalho                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomArq2 += OrdBagExt()
Delete File &(cNomArq2)

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
Endif

MS_FLUSH()
