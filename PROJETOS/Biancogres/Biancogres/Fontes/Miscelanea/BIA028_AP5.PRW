#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 07/03/01
#include "topconn.ch"

User Function bia028()        // incluido pelo assistente de conversao do AP5 IDE em 07/03/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("LEND,CSTRING,CDESC1,CDESC2,CDESC3,TAMANHO")
SetPrvt("ARETURN,NOMEPROG,ALINHA,NLASTKEY,TITULO,CABEC1")
SetPrvt("CABEC2,NBEGIN,CDESCRI,CCANCEL,M_PAG,WNREL")
SetPrvt("LPRIM,LI,NTIPO,WFILIAL,CB_COND0,CB_COND1")
SetPrvt("CB_COND2,CB_COND3,CB_COND4,CSDBIND,CCHAVE,CFILTRO")
SetPrvt("CSB9IND,ACAMPOS,WSBF,WLOCALIZ,WQTDREG,WSALDOINI")
SetPrvt("WSALDOFIM,LOC,_REC,WLOCAL,WPRODUTO,WNENT1UM")
SetPrvt("WNENT2UM,WNSAI1UM,WNSAI2UM,WNSAL1UM,WNSAL2UM,XCF")
SetPrvt("WCONV,LFIRST,_NENT1UM,_NENT2UM,_NSAI1UM,_NSAI2UM")
SetPrvt("cQuery,nSaldoIni,nSaldoFim,nSaldoSBF,_CONV")
SetPrvt("cProduto,cLoc,cLocaliz,nTotRegs,")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA028   ³ Autor ³ Gustav Koblinger Jr.   ³ Data ³ 28/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Kardex fisico - financeiro                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lEnd     := .F.
cString  := "SB9"
cDesc1   := "Este programa emitir  uma rela‡„o com as movimenta‡”es"
cDesc2   := "dos produtos Selecionados,Ordenados por Dia."
cDesc3   := ""
tamanho  := "M"
aReturn  := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }
nomeprog := "BIA028"
aLinha   := {}
nLastKey := 0
titulo   := "Kardex Fisico (DIA)"
cabec1   := "OPERACAO              DOCUMENTO |              1A. UNIDADE MEDIDA               |              2A. UNIDADE MEDIDA               |"
cabec2   := "DATA     TM  CF  EST     NUMERO |     ENTRADAS  |        SAIDAS |         SALDO |     ENTRADAS |         SAIDAS |         SALDO |"
nBegin   := 0
cDescri  := ""
cCancel  := "***** CANCELADO PELO OPERADOR *****"
m_pag    := 1                                    // numero da pagina
wnrel    := "BIA028"
lprim    := .t.
li       := 80
nTipo    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe janela padrao de relatorios                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetPrint(cString,wnrel,"BIA028",titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho)
if (nLastKey == 27) .OR. (LastKey() == 27)
	Return
endif
SetDefault(aReturn,cString)
if (nLastKey == 27) .OR. (LastKey() == 27)
	Return
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza parametros                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("BIA028",.F.)
nTipo := IIF(aReturn[4]==1,15,18)
//---------------------------------
// mv_par01  Almox
// mv_par02  Da Localizacao
// mv_par03  Ate a Localizacao
// mv_par04  Do Produto
// mv_par05  Ate o Produto
// mv_par06  Data do fechamento
//---------------------------------

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria indice temporario arquivo SDB                                       ³
//³ Cria Arquivo temporario saldos na data                                   ³
//³ Monta arquivo temporario com os saldos na data                           ³
//³ Emite Carta de Cobranca ou Etiquetas                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Processa({|| fCriaSaldos() })// Substituido pelo assistente de conversao do AP5 IDE em 07/03/01 ==> Processa({|| Execute(CriaSaldos) })
Processa({|| fMonta() })// Substituido pelo assistente de conversao do AP5 IDE em 07/03/01 ==> Processa({|| Execute(Monta) })
if nTotRegs > 0
	Processa({|| fImprime() })// Substituido pelo assistente de conversao do AP5 IDE em 07/03/01 ==> RptStatus({|| Execute(Imprime) })
else
	alert("Nao existem dados para os parametros informados!")
endif
Processa({|| fApagaTemp() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa({|| Execute(fApagaTemp) })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera spool de impressao                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  aReturn[5] == 1
	Set Printer To
	Commit
	ourspool(wnrel)    // Chamada do Spool de Impressao
End

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³ CriaSaldos ³ Criar arquivo para saldos na data                        ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 07/03/01 ==> Function CriaSaldos
Static Function fCriaSaldos()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta estrutura do arquivo de saldos                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := {}
AADD(aCampos, { "LOC     " , "C", 02, 0 })
AADD(aCampos, { "LOCALIZ " , "C", 15, 0 })
//???????????????????????????????Inserir Lote						
AADD(aCampos, { "PRODUTO " , "C", 15, 0 })
AADD(aCampos, { "SALDOINI" , "N", 11, 2 })
AADD(aCampos, { "SALDOFIM" , "N", 11, 2 })
AADD(aCampos, { "SALDOSBF" , "N", 11, 2 })
wSBF := CriaTrab(aCampos,.T.)
dbUseArea(.T.,,wSBF,"wSBF",.T.,.F.)
//???????????????????????????????Inserir Lote						
dbCreateInd(wSBF,"LOC+LOCALIZ+PRODUTO",{||LOC+LOCALIZ+PRODUTO } )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³ Monta      ³ Monta arquivo temporario com os saldos na data           ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 07/03/01 ==> Function Monta
Static Function fMonta()
cQuery  := ""
cQuery  := cQuery + "SELECT COUNT(SB9.B9_COD) AS TOTREGS "
cQuery  := cQuery + "FROM "+RetSqlName("SB9")+" SB9 "
cQuery  := cQuery + "WHERE (SB9.B9_DATA     = '"+DTOS(MV_PAR06)+"') AND "
cQuery  := cQuery + "      (SB9.B9_COD     >= '"+MV_PAR04+"') AND "
cQuery  := cQuery + "      (SB9.B9_COD     <= '"+MV_PAR05+"') AND "
cQuery  := cQuery + "      (SB9.B9_LOCAL    = '"+MV_PAR01+"')"
If chkfile("TMP")
	dbSelectArea("TMP")
	dbCloseArea()
EndIf
TCQuery cQuery Alias "TMP" New
nTotRegs := TMP->TOTREGS
TMP->(DbCloseArea())

if nTotRegs > 0
	cQuery  := ""
	cQuery  := cQuery + "SELECT               "
	cQuery  := cQuery + "       SB9.B9_COD,   "
	cQuery  := cQuery + "       SB9.B9_LOCAL, "
	cQuery  := cQuery + "       SB9.B9_QINI,  "
	cQuery  := cQuery + "       SB9.B9_DATA   "
	cQuery  := cQuery + "FROM "+RetSqlName("SB9")+" SB9 "
	cQuery  := cQuery + "WHERE (SB9.B9_DATA     = '"+DTOS(MV_PAR06)+"') AND "
	cQuery  := cQuery + "      (SB9.B9_COD     >= '"+MV_PAR04+"') AND "
	cQuery  := cQuery + "      (SB9.B9_COD     <= '"+MV_PAR05+"') AND "
	cQuery  := cQuery + "      (SB9.B9_LOCAL    = '"+MV_PAR01+"')"
	If chkfile("TMP")
		dbSelectArea("TMP")
		dbCloseArea()
	EndIf
	TCQuery cQuery Alias "TMP" New
	
	DbGoTop()
	ProcRegua(nTotRegs)
	do while !TMP->(Eof())
		
		IncProc("Produto: "+TMP->B9_COD)

//???????????????????????????????Inserir Lote								
		cQuery  := ""
		cQuery  := cQuery + "SELECT                    "
		cQuery  := cQuery + "       SDB.DB_LOCAL,   "
		cQuery  := cQuery + "       SDB.DB_LOCALIZ, "
		cQuery  := cQuery + "       SDB.DB_PRODUTO, "
		cQuery  := cQuery + "       SBF.BF_QUANT    "
		cQuery  := cQuery + "FROM "+RetSqlName("SDB")+" SDB "
		cQuery  := cQuery + "INNER JOIN "+RetSqlName("SBF")+" SBF "+" ON "
		cQuery  := cQuery + "           SDB.DB_LOCAL = SBF.BF_LOCAL AND "
		cQuery  := cQuery + "           SDB.DB_LOCALIZ = SBF.BF_LOCALIZ "
		cQuery  := cQuery + "WHERE (SDB.DB_LOCAL    = '"+TMP->B9_LOCAL+"') AND "
		cQuery  := cQuery + "      (SDB.DB_LOCALIZ >= '"+MV_PAR02+"') AND "
		cQuery  := cQuery + "      (SDB.DB_LOCALIZ <= '"+MV_PAR03+"') AND "
		cQuery  := cQuery + "      (SDB.DB_PRODUTO  = '"+TMP->B9_COD+"') "
		If chkfile("TMP2")
			dbSelectArea("TMP2")
			dbCloseArea()
		EndIf
		TCQuery cQuery Alias "TMP2" New
		
		if (ALIAS()=="TMP2") .AND. (TMP2->(LastRec()) > 0)
			DbSelectArea("TMP2")
			DbGoTop()
			do while !TMP2->(Eof())
				cLoc      := TMP2->DB_LOCAL
				cLocaliz  := TMP2->DB_LOCALIZ
//???????????????????????????????Inserir Lote										
				cProduto  := TMP2->DB_PRODUTO
				nSaldoIni := TMP->B9_QINI
				nSaldoFim := TMP->B9_QINI
				nSaldoSBF := TMP2->BF_QUANT
				TMP2->(DbSkip())
				if (cLocaliz # TMP2->DB_LOCALIZ) .OR. TMP2->(EOF())
					Reclock("wSBF",.T.)
					wSBF->LOC      := cLoc
					wSBF->LOCALIZ  := cLocaliz
					wSBF->PRODUTO  := cProduto
					wSBF->SALDOINI := nSaldoIni
					wSBF->SALDOFIM := nSaldoFim
					wSBF->SALDOSBF := nSaldoSBF
					DbUnlock()
				endif
			enddo
		endif
		TMP2->(DbCloseArea())
		
		TMP->(DbSkip())
	enddo
endif
//TMP->(DbCloseArea())
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Imprime    ³ Impressao Relatorio                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 07/03/01 ==> Function Imprime

Static Function fImprime()

//DbSelectArea("SBF")
//DbSetOrder(1)
//
//DbSelectArea("SDB")
//DbSetOrder(3)
//
//DbSelectArea("SB9")
//DbSetOrder(2)


wLocal   := "  "
wLocaliz := SPACE(15)
//???????????????????????????????Inserir Lote						
wProduto := Space(15)
wnEnt1UM := wnEnt2UM := 0
wnSai1UM := wnSai2UM := 0
wnSal1UM := wnSal2UM := 0
xCF      := Space(3)
wConv    := 0
lFirst   := .t.

DbSelectArea("wSBF")
ProcRegua(wSBF->(LastRec()))
wSBF->(DbGotop())
do while !wSBF->(Eof())
	
	IncProc("Imprimindo ...")
	
	If li >= 56
		cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificar total movimentado  -  By Nilton                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_nEnt1UM := _nEnt2UM := 0
	_nSai1UM := _nSai2UM := 0

//???????????????????????????????Inserir Lote							
	DbSelectArea("SDB")
	SDB->(DbSetOrder(3))
	SDB->(DbSeek(xFilial("SDB")+wSBF->LOC+wSBF->LOCALIZ+wSBF->PRODUTO),.T.)
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	if !SB1->(DbSeek(xFilial("SB1")+wSBF->PRODUTO,.F.))
		alert("Produto ["+wSBF->PRODUTO+"] nao encontrado no cadastro de produtos!")
	endif

//???????????????????????????????Inserir Lote							
	do while !SDB->(EOF())                .AND.;
		(SDB->DB_LOCAL   == wSBF->LOC)     .AND.;
		(SDB->DB_LOCALIZ == wSBF->LOCALIZ) .AND.;
		(SDB->DB_PRODUTO == wSBF->PRODUTO)
		
		do Case
			Case (SDB->DB_ORIGEM=="SD3" .AND. SDB->DB_TM     == "499") .OR. ;
				(SDB->DB_ORIGEM=="SB9" .OR.  SDB->DB_ORIGEM == "SD1")   .OR. ;
				(SDB->DB_ORIGEM=="SD2" .AND. SDB->DB_TM     <= "499")   .OR. ;
				(SDB->DB_ORIGEM=="SC6" .AND. SDB->DB_TM     <= "499")
				
				if SB1->B1_TIPCONV == "D"
					_Conv := SDB->DB_QUANT / SB1->B1_CONV
				else
					_Conv := SDB->DB_QUANT * SB1->B1_CONV
				endif
				_nEnt1UM := _nEnt1UM + SDB->DB_QUANT
				_nEnt2UM := _nEnt2UM + wConv
				
			Case (SDB->DB_ORIGEM == "SD3" .AND. SDB->DB_TM =="999")         .OR. ;
				(SDB->DB_ORIGEM == "SD3" .AND. Subs(SDB->DB_TM,1,1) == "5") .OR. ;
				(SDB->DB_ORIGEM == "SD2" .AND. SDB->DB_TM > "500")           .OR. ;
				(SDB->DB_ORIGEM == "SC6" .AND. SDB->DB_TM > "500")
				
				if SB1->B1_TIPCONV == "D"
					_Conv := SDB->DB_QUANT / SB1->B1_CONV
				else
					_Conv := SDB->DB_QUANT * SB1->B1_CONV
				endif
				_nSai1UM := _nSai1UM + SDB->DB_QUANT
				_nSai2UM := _nSai2UM + wConv
		endcase
		SDB->(DbSkip())
	enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Regravo saldo inicial montado final - movimentacao - By Nilton        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Reclock("wSBF",.F.)
	wSBF->SALDOINI := wSBF->SALDOSBF + _nSai1UM -_nEnt1UM
	MsUnlock()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quebra                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//???????????????????????????????Inserir Lote							
	if (wLocaliz # SDB->DB_LOCALIZ) .OR. (wProduto # wSBF->PRODUTO)
		if !lFirst
			@ li, 000 pSay Replicate("-",132)
			li := li + 1
			@ li, 000 pSay "T O T A I S : "
			@ li, 034 pSay Transform(wnEnt1UM,"@E 999,999,999.99") + "|"
			@ li, 050 pSay Transform(wnSai1UM,"@E 999,999,999.99") + "|"
			@ li, 066 pSay Transform(wnSal1UM,"@E 999,999,999.99") + "|"
			@ li, 082 pSay Transform(wnEnt2UM,"@E 999,999,999.99") + "|"
			@ li, 098 pSay Transform(wnSai2UM,"@E 999,999,999.99") + "|"
			@ li, 114 pSay Transform(wnSal2UM,"@E 999,999,999.99") + "|"
			li := li + 1
			@ li, 000 pSay Replicate("-",132)
			li := li + 1
			wnEnt1UM := wnEnt2UM := 0
			wnSai1UM := wnSai2UM := 0
			wnSal1UM := wnSal2UM := 0
			cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		else
			lFirst := .f.
		endif
		
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+wSBF->PRODUTO)
//???????????????????????????????Inserir Lote								
		@ li, 000 pSay "Localizacao: "+ Subs(wSBF->LOCALIZ,1,10)
		@ li, 025 pSay "Produto: "    + Subs(wSBF->PRODUTO,1,8)
		@ li, 047 pSay "Referencia:"  + Subs(SB1->B1_YREF,1,40)
		li       := li + 2
		wnSal1UM := wSBF->SALDOINI
		wnSal2UM := IF(SB1->B1_TIPCONV=="D",wSBF->SALDOINI/SB1->B1_CONV,wSBF->SALDOINI*SB1->B1_CONV)
		@ li, 000 pSay "Saldo Inicial: "
		@ li, 066 pSay Transform(wnSal1UM,"@E 999,999,999.99")
		@ li, 114 pSay Transform(wnSal2UM,"@E 999,999,999.99")
		li       := li + 1
		wLocaliz := SDB->DB_LOCALIZ
		wProduto := wSBF->PRODUTO
	EndIf
	
	DbSelectArea("SDB")
	SDB->(DbSetOrder(3))
//???????????????????????????????Inserir Lote							
	DbSeek(xFilial("SDB")+wSBF->LOC+wSBF->LOCALIZ+wSBF->PRODUTO,.T.)
	
	do while !SDB->(EOF())	         	    .AND. ;
		(SDB->DB_LOCAL   == wSBF->LOC)     .AND. ;
		(SDB->DB_LOCALIZ == wSBF->LOCALIZ) .AND. ;
		(SDB->DB_PRODUTO == wSBF->PRODUTO)
		
		If SDB->(DB_DATA) <= mv_par06
			DbSkip()
			Loop
		Endif
		
		@ li,000 pSay DtoC(SDB->DB_DATA)
		@ li,009 pSay SDB->DB_TM
		
		Do Case
			Case SDB->DB_ORIGEM == "SD1"
				DbSelectArea("SD1")
				DbSetOrder(1)
				If DbSeek(xFilial("SD1")+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA,.F.)
					xCF := SD1->D1_CF
				EndIf
			Case SDB->DB_ORIGEM == "SD2" .OR. SDB->DB_ORIGEM == "SC6"
				DbSelectArea("SD2")
				DbSetOrder(3)
				If DbSeek(xFilial("SD2")+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA,.F.)
					xCF := SD2->D2_CF
					DbSelectArea("SC9")
					DbSetOrder(1)
					DbSeek(xFilial("SC9")+SD2->D2_PEDIDO+SD2->D2_ITEMPV,.F.)
				EndIf
			Otherwise
				xCF:= Space(3)
		EndCase
		
		@ li,013 pSay xCF
		@ li,018 pSay SDB->DB_ESTORNO
		If SDB->DB_ORIGEM # "SD3"
			@ li,021 pSay IIF(SC9->C9_AGREG<>SPACE(4),SUBS(DTOS(SD2->D2_EMISSAO),1,4)+SC9->C9_AGREG+SPACE(3),SDB->DB_SERIE+SPACE(1))
			IF SC9->C9_AGREG==SPACE(4)
				@ li,025 pSay SDB->DB_DOC
			EndIf
		Else
			@ li,023 pSay SDB->DB_DOC
		EndIf
		Do Case
			Case (SDB->DB_ORIGEM=="SD3".And.SDB->DB_TM     == "499") .Or. ;
				(SDB->DB_ORIGEM=="SB9".Or. SDB->DB_ORIGEM == "SD1") .Or. ;
				(SDB->DB_ORIGEM=="SD2".And.SDB->DB_TM     <= "499") .Or. ;
				(SDB->DB_ORIGEM=="SC6".And.SDB->DB_TM     <= "499")
				wConv    := IF(SB1->B1_TIPCONV=="D",SDB->DB_QUANT/SB1->B1_CONV,SDB->DB_QUANT*SB1->B1_CONV)
				wnEnt1UM := wnEnt1UM + SDB->DB_QUANT
				wnEnt2UM := wnEnt2UM + wConv
				wnSal1UM := wnSal1UM + SDB->DB_QUANT
				wnSal2UM := wnSal2UM + wConv
				@ li, 032 pSay "|"
				@ li, 034 pSay Transform(SDB->DB_QUANT,"@E 999,999,999.99")
				@ li, 048 pSay "|"
				@ li, 064 pSay "|"
				@ li, 066 pSay Transform(wnSal1UM,"@E 999,999,999.99")
				@ li, 080 pSay "|"
				@ li, 082 pSay Transform(wConv,"@E 999,999,999.99")
				@ li, 096 pSay "|"
				@ li, 112 pSay "|"
				@ li, 114 pSay Transform(wnSal2UM,"@E 999,999,999.99")
				@ li, 128 pSay "|"
				
			Case (SDB->DB_ORIGEM=="SD3" .And. SDB->DB_TM =="999")          .Or. ;
				(SDB->DB_ORIGEM=="SD3" .And. Subs(SDB->DB_TM,1,1) == "5") .Or. ;
				(SDB->DB_ORIGEM=="SD2" .And. SDB->DB_TM > "500")          .Or. ;
				(SDB->DB_ORIGEM=="SC6" .And. SDB->DB_TM > "500")
				wConv    := IF(SB1->B1_TIPCONV=="D",SDB->DB_QUANT/SB1->B1_CONV,SDB->DB_QUANT*SB1->B1_CONV)
				wnSai1UM := wnSai1UM + SDB->DB_QUANT
				wnSai2UM := wnSai2UM + wConv
				wnSal1UM := wnSal1UM - SDB->DB_QUANT
				wnSal2UM := wnSal2UM - wConv
				@ li, 032 pSay "|"
				@ li, 048 pSay "|"
				@ li, 050 pSay Transform(SDB->DB_QUANT,"@E 999,999,999.99")
				@ li, 064 pSay "|"
				@ li, 066 pSay Transform(wnSal1UM,"@E 999,999,999.99")
				@ li, 080 pSay "|"
				@ li, 096 pSay "|"
				@ li, 098 pSay Transform(wConv,"@E 999,999,999.99")
				@ li, 112 pSay "|"
				@ li, 114 pSay Transform(wnSal2UM,"@E 999,999,999.99")
				@ li, 128 pSay "|"
			otherwise
				alert("Origem nao encontrada: "+SDB->DB_ORIGEM)
		endcase
		li := li + 1
		SDB->(DbSkip())		
	enddo
	
	wSBF->(DbSkip())	
enddo

@ li, 000 pSay Replicate("-",132)
li := li + 1
@ li, 000 pSay "T O T A I S : "
@ li, 034 pSay Transform(wnEnt1UM,"@E 999,999,999.99") + "|"
@ li, 050 pSay Transform(wnSai1UM,"@E 999,999,999.99") + "|"
@ li, 066 pSay Transform(wnSal1UM,"@E 999,999,999.99") + "|"
@ li, 082 pSay Transform(wnEnt2UM,"@E 999,999,999.99") + "|"
@ li, 098 pSay Transform(wnSai2UM,"@E 999,999,999.99") + "|"
@ li, 114 pSay Transform(wnSal2UM,"@E 999,999,999.99") + "|"
li := li + 1
@ li, 000 pSay Replicate("-",132)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime Rodape                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Roda(0,"","M")

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fApagaTemp ³ Autor ³ WLADIMIR ILLIUSHENKO 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Apaga a tabela temporaria. 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ BIA028      												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fApagaTemp
Static FUNCTION fApagaTemp()
DbSelectArea("wSBF")
DbCloseArea("wSBF")
Ferase(wSBF+".*")
RETURN
