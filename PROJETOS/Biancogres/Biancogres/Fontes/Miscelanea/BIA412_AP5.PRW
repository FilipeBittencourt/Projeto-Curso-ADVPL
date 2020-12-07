#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 10/09/03
#IFNDEF WINDOWS
	#DEFINE PSAY SAY
#ENDIF

User Function BIA412()        // incluido pelo assistente de conversao do AP5 IDE em 10/09/03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CDESC1,CDESC2,CDESC3,TAMANHO,LIMITE,CSTRING")
SetPrvt("TITULO,ARETURN,NOMEPROG,NLASTKEY,WNUMBER,CBCONT")
SetPrvt("CPERG,WNREL,CABEC1,CABEC2,C15,CBTXT")
SetPrvt("LI,M_PAG,WDATADE,WDATAATE,WPRODDE,WPRODATE")
SetPrvt("_ACAMPOS,_CTRAB,cTrb,MAG,RAN,WOLDCLAS")
SetPrvt("WOLDCOR,WOLDLINE,WOLDNOME,WOLDPROD,ACLASSE,ACORES")
SetPrvt("ALINHA,ACLASSEA,ACLASSEC,ACLASSED,ATOTGER,WPRIMVEZ")
SetPrvt("WNOMELINHA,WICLASSE,WICORES,WILINHA,WNTOTPROD,WNTOTLIB")
SetPrvt("WDIFPROD,WIDETALHE,CB_COND0,CB_COND1,CB_COND2,CB_COND3")
SetPrvt("CSD3IND,CCHAVE,CFILTRO,WSEXISTE,WD3_TM,OLDDATA")
SetPrvt("WINCREMEN,WITGERAL,OLDAREA,CHA_PESQ,OLDFORMATO,OLDPRODUTO")
SetPrvt("WSTOTPROD,WSTOTLIBER,")

//Programa  : BIA412
//Autor     : Cesar Magnago
//Data      : 30/10/00
//Descricao : Comparativo Producao Realizada e Producao Liberada
//Uso       : SIGAEST

#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 10/09/03 ==>       #DEFINE PSAY SAY
#ENDIF

//Inicializa variaveis
cDesc1     := "Este programa tem como objetivo emitir um relatorio de "
cDesc2     := "Comparacao entre a Qtd Produzida e a Qtd Liberada"
cDesc3     := ""
tamanho    := "M"
limite     := 132
cString    := "SD3"
titulo     := "COMPARATIVO QTD PRODUZIDA X QTD LIBERADA"
aReturn    := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
nomeprog   := "BIA412"
nLastKey   := wNumber := cbcont := 0
cPerg      := "BIA412"
wnrel      := "BIA412"
Cabec1     := "CODIGO       DESCRICAO DO PRODUTO               QTD M2       QTD M2    DIFERENCA  DT ULTIMO "
Cabec2     := "                                             PRODUDIZA     LIBERADA     PRODUCAO  MOVIMENTO "
//                XXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXX.XXX,XX   XXX.XXX,XX   XXX.XXX,XX   XX/XX/XX
//                0            12                             43           56           69           82
C15        := 15
cbtxt      := space(10)
li         := 80
m_pag      := 1

//Envia controle para a funcao SETPRINT
wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,tamanho)

PERGUNTE( cPerg, .F. )

If ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
	Return
Endif

wDataDe  := mv_par03
wDataAte := mv_par04
wProdDe  := mv_par01
wProdAte := mv_par02

//Verifica Posicao do Formulario na Impressora
SetDefault(aReturn,cString)

If ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
	Return
Endif

// Monta arquivo de trabalho
Processa( {|| fMonta_Arq() } )// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==>    Processa( {|| Execute(fMonta_Arq) } )

// Monta Filtro do SD3
Processa({|| _TempSD3() })// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==>    Processa({|| Execute(_TempSD3) })

// LE MOVIMENTACOES INTENAS
Processa( {|| fLe_SD3() } )// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==>    Processa( {|| Execute(fLe_SD3) } )

// LE ARQUIVO DE QTD PRODUZIDA
Processa( {|| fLe_UZ6() } )// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==>    Processa( {|| Execute(fLe_UZ6) } )

// CALCULA O TOTAL PRODUZIDO E O TOTAL LIBERADO
Processa( {|| fLe_TRAB() } )// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==>    Processa( {|| Execute(fLe_TRAB) } )

// CALCULA O TOTAL PRODUZIDO E O TOTAL LIBERADO POR LINHA
Processa( {|| fLe_RAN() } )// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==>    Processa( {|| Execute(fLe_RAN) } )

// IMPRIME RELATORIO
Processa( {|| fImpressao() } )// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==>    Processa( {|| Execute(fImpressao) } )

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
DbSelectArea("cTrb")
DBCLOSEAREA()

If File(cTrb+".DBF")
	Ferase(cTrb+".DBF")
	Ferase(cTrb+".cdx")
Endif

//APAGA ARQUIVO DE TRABALHO
DbSelectArea("MAG")
DBCLOSEAREA()

If File(MAG+".DBF")
	Ferase(MAG+".DBF")
	Ferase(MAG+".cdx")
Endif

//APAGA ARQUIVO DE TRABALHO
DbSelectArea("RAN")
DBCLOSEAREA()

If File(RAN+".DBF")
	Ferase(RAN+".DBF")
	Ferase(RAN+".cdx")
Endif

//APAGA ARQUIVO DO FILTRO SD3
RetIndex("SD3")

If File(cSD3Ind+".DBF")
	Ferase(cSD3Ind+".DBF")
	Ferase(cSD3Ind+".cdx")
Endif

//LIBERA IMPRESSAO
If aReturn[5] == 1
	Set Printer To
	Ourspool(wnrel)
Endif

MS_FLUSH()

//FIM DO PROGRAMA

RETURN( NIL )


//Funcao      : fMonta_Arq
//Descricao   : Monta arquivo de trabalho

// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==> FUNCTION fMonta_Arq
Static FUNCTION fMonta_Arq()

_aCampos := { {"PRODUTO ","C",15, 0},;
{"NOMEPROD","C",50, 0},;
{"LINHA"   ,"C",30, 0},;
{"QTDPROD ","N",11, 2},;
{"DTMOV   ","D",08, 0},;
{"QTDLIBER","N",12, 2} }

_cTrab := CriaTrab(_aCampos)

DbUseArea(.T.,,_cTrab,"_cTrab")
DbCreateInd(_cTrab,"1",{||PRODUTO})

_aCampos := { {"PRODUTO ","C",15, 0},;
{"NOMEPROD","C",50, 0},;
{"LINHA"   ,"C",30, 0},;
{"QTDPROD ","N",11, 2},;
{"DTMOV   ","D",08, 0},;
{"QTDLIBER","N",12, 2} }

cTrb := CriaTrab(_aCampos)

DbUseArea(.T.,,cTrb,"cTrb")
DbCreateInd(cTrb,"PRODUTO",{||PRODUTO})

_aCampos := { {"PRODUTO ","C",06, 0},;
{"QTDPROD ","N",11, 2},;
{"QTDLIBER","N",12, 2} }

MAG := CriaTrab(_aCampos)

DbUseArea(.T.,,MAG,"MAG")
DbCreateInd(MAG,"PRODUTO",{||PRODUTO})

_aCampos := { {"REFER"   ,"C",05, 0},;
{"QTDPROD ","N",11, 2},;
{"QTDLIBER","N",12, 2} }

RAN := CriaTrab(_aCampos)

DbUseArea(.T.,,RAN,"RAN")
DbCreateInd(RAN,"REFER",{||REFER})

RETURN( NIL )


//Funcao    : fImpressao
//Descricao : Emite relatorio

// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==> FUNCTION fImpressao
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

wOldClas  := Subs(_cTrab->PRODUTO,6,1)
wOldCor   := Subs(_cTrab->PRODUTO,5,1)
wOldLine  := Subs(_cTrab->PRODUTO,2,3)
wOldNome  := _cTrab->NOMEPROD
wOldProd  := _cTrab->PRODUTO
aClasse   := {0,0,0,0,0,0,0}
aCores    := {0,0,0,0,0,0,0}
aLinha    := {0,0,0,0,0,0,0}
aClasseA  := {0,0,0,0,0,0,0}
aClasseC  := {0,0,0,0,0,0,0}
aClasseD  := {0,0,0,0,0,0,0}
aTotGer   := {0,0,0,0,0,0,0}
wPrimVez  := .T.

//Processa arquivo de trabalho


While ! EOF()
	
	//Incrementa regua
	IncProc()
	
	If li >= 62
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif
	
	// IMPRIME O NOME DA LINHA SE E A PRIMEIRA VEZ QUE PASSA POR AQUI
	IF wPrimVez
		
		// DEFINE SUBSTRING A SER IMPRESSA NO RELATORIO
		wNomeLinha := _cTrab->LINHA
		
		@ li, 000 PSAY wNomeLinha
		
		li := li + 1
		
		wPrimVez   := .F.
		
	ENDIF
	
	//Quebra de Classe
	
	IF SUBS(_cTrab->PRODUTO,6,1) #wOldClas .OR.;
		Subs(_cTrab->PRODUTO,5,1) #wOldCor  .OR.;
		Subs(_cTrab->PRODUTO,2,3) #wOldLine
		
		wOldClas := IIF( wOldClas == "1", '"A"', IIF( wOldClas == "2", '"C"', '"D"' ) )
		wIClasse := "TOTAL CLASSE    " + wOldClas  + Space(28 - LEN(wOldClas))
		wIClasse := wIClasse + Tran( aClasse[1], "@E 999,999.99"      ) + Space(03)
		wIClasse := wIClasse + Tran( aClasse[2], "@E 999,999.99"      )
		
		li := li + 1
		
		@ li,000 PSAY wIClasse
		
		li := li + 1
		
		aClasse  := {0,0,0,0,0,0,0}
		wOldClas := Subs(_cTrab->PRODUTO,6,1)
		
	EndIf
	
	//Quebra de Cores
	
	If Subs(_cTrab->PRODUTO,5,1) #wOldCor .OR.;
		Subs(_cTrab->PRODUTO,2,3) #wOldLine
		
		wOldNome := Subst(wOldNome,22)
		wICores := "TOTAL REFER.  " + SUBS(wOldNome,1,30) + Space(30 - LEN(wOldNome))
		wICores  := wICores + Tran( aCores[1], "@E 999,999.99"      ) + Space(03)
		wICores  := wICores + Tran( aCores[2], "@E 999,999.99"      )
		
		li := li + 1
		
		@ li,000 PSAY wICores
		
		li := li + 1
		
		aCores   := {0,0,0,0,0,0,0}
		wOldCor  := Subs(_cTrab->PRODUTO,5,1)
		
	EndIf
	
	//Quebra de Linha
	
	If Subs(_cTrab->PRODUTO,2,3) #wOldLine
		
		DBSELECTAREA("SB1")
		DBSETORDER(1)
		DBSEEK(xFilial("SB1")+wOldLine)
		
		wILinha  := "TOTAL LINHA   " + SUBS(wNomeLinha,1,28)         + Space(02)
		wILinha  := wILinha + Tran( aLinha[1], "@E 999,999.99"     ) + Space(03)
		wILinha  := wILinha + Tran( aLinha[2], "@E 999,999.99"     )
		
		li := li + 1
		
		@ li,000 PSAY wILinha
		
		li := li + 1
		
		@ li,000 PSAY Replicate( "-", Limite )
		
		aLinha   := {0,0,0,0,0,0,0}
		wOldLine := Subs(_cTrab->PRODUTO,2,3)
		
		// DEFINE SUBSTRING A SER IMPRESSA NO RELATORIO
		
		wNomeLinha := _cTrab->LINHA
		
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
	
	DbSelectArea("RAN")
	DbSeek(Subs(_cTrab->PRODUTO,1,5))
	wnTotProd := 0
	wnTotLib  := 0
	wnTotProd := (_cTrab->QTDPROD/RAN->QTDPROD) * 100
	wnTotLib  := (_cTrab->QTDLIBER/RAN->QTDLIBER) * 100
	wDifProd  := (_cTrab->QTDPROD - _cTrab->QTDLIBER)
	wIDetalhe := SUBS(_cTrab->PRODUTO,1,11)                                 + Space(01)
	wIDetalhe := wIDetalhe + Subs(_cTrab->NOMEPROD,1,30)                    + Space(02)
	wIDetalhe := wIDetalhe + Tran( _cTrab->QTDPROD  , "@E 999,999.99"     ) + Space(03)
	wIDetalhe := wIDetalhe + Tran( _cTrab->QTDLIBER , "@E 999,999.99"     ) + Space(03)
	wIDetalhe := wIDetalhe + Tran( wDifProd         , "@E 999,999.99"     ) + Space(03)
	wIDetalhe := wIDetalhe + Tran( _cTrab->DTMOV    , "@D"                ) + Space(04)
	wIDetalhe := wIDetalhe + Tran( wnTotProd        , "@E 999.99"         ) + " %" + Space(02)
	wIDetalhe := wIDetalhe + Tran( wnTotLib         , "@E 999.99"         ) + " %"
	
	li := li + 1
	
	@ li,000 PSAY wIDetalhe
	
	wOldNome   := _cTrab->NOMEPROD
	
	//
	//ACESSA PROXIMO REGISTRO
	//
	dbSelectArea("_cTrab")
	dbSkip()
	
EndDo

If li >= 62
	Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
Endif

fImpRes()

RETURN( NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ _TempSD3   ³ Cria indice temporario SD3                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==> Function _TempSD3
Static Function _TempSD3()
cb_Cond0:= {|| DTOS(SD3->D3_EMISSAO) >= DTOS(wDataDe)  .AND. DTOS(SD3->D3_EMISSAO) <= DTOS(wDataAte)}
cb_Cond1:= {|| SD3->D3_FILIAL >= "01"     .AND. SD3->D3_FILIAL <= "02"                              }
// Por Marcos Alberto Soprani em 19/04/12 atendendo o novo tratamento de apontamento de Produção/Apuração de Custo.
//cb_Cond2:= {|| SD3->D3_TM == "500" .OR. SD3->D3_TM == "506"                                         }
cb_Cond2:= {|| (SD3->D3_TM <= "500" .and. SD3->D3_YORIMOV == "PR0") .or. SD3->D3_TM == "506"        }
cb_Cond3:= {|| SD3->D3_COD    >= MV_PAR01 .AND. SD3->D3_COD    <= MV_PAR02                          }
cSD3ind := CriaTrab( NIL,.F. )
cChave  := "D3_FILIAL+DTOS(D3_EMISSAO)"

cFiltro := "Eval(cb_Cond0).AND.Eval(cb_Cond1).AND.Eval(cb_Cond2).AND.Eval(cb_Cond3)"

IndRegua("SD3",cSD3ind,cChave,,cFiltro,"Movimentacoes Internas...")
dbGoTop()
//Axcadastro( "SD3", "SD3" )
//dbGoTop()
Return

// REGRAVA PRODUTOS DA MOVIMENTACAO INTERNA

// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==> FUNCTION fLe_SD3
Static FUNCTION fLe_SD3()

wsExiste := .F.

While ! Eof()
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSeek( xFILIAL("SB1")+SD3->D3_COD, .F. )
	
	If SB1->B1_TIPO <> "PA"
		DbSelectArea("SD3")
		DbSkip()
		Loop
	Endif
	
	wD3_TM   := SD3->D3_TM
	DbSelectArea("_cTrab")
	DbSetOrder(1)
	RecLock( "_cTrab", ! DBSEEK( Subs(SD3->D3_COD,1,6), .F. ) )
	
	_cTrab->PRODUTO  := Subs(SD3->D3_COD,1,6)
	_cTrab->NOMEPROD := SB1->B1_DESC
	_cTrab->QTDPROD  := 0
	_cTrab->DTMOV    := SD3->D3_EMISSAO
	_cTrab->QTDLIBER := If(wD3_TM <= "500" .and. SD3->D3_YORIMOV == "PR0", _cTrab->QTDLIBER + SD3->D3_QUANT, _cTrab->QTDLIBER - SD3->D3_QUANT)
	_cTrab->LINHA    := SUBS(SB1->B1_YREFPV,1,30)
	wsExiste         := .T.
	
	MsUnLock()
	DbCommit()
	
	OldData := SD3->D3_EMISSAO
	
	DbSelectArea("SD3")
	DbSkip()
	
EndDo

IncProc()

Return( Nil )


// REGRAVA PRODUTOS DO ARQUIVO DE QTD PRODUZIDA

// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==> FUNCTION fLe_UZ6
Static FUNCTION fLe_UZ6()

ProcRegua( IIF( ( wDataDe  - wDataAte) == 0, 1, (wDataAte  - wDataDe) ) )

DbSelectArea("UZ6")
DbSetOrder(1)
DbSeek(xFilial("UZ6")+Dtos(wDataDe),.T.)
OldData :=  wDataDe

While ! Eof() .and. UZ6->UZ6_DATA <= wDataAte
	
	wIncremen := UZ6->UZ6_DATA - OldData
	
	If ( wIncremen > 0 )
		IncProc( wIncremen )
	EndIf
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSeek( xFILIAL("SB1")+UZ6->UZ6_COD, .F. )
	
	If SB1->B1_TIPO <> "PA"
		DbSelectArea("UZ6")
		DbSkip()
		Loop
	Endif
	
	If UZ6->UZ6_COD < MV_PAR01
		DbSelectArea("UZ6")
		DbSkip()
		Loop
	Endif
	
	If UZ6->UZ6_COD > MV_PAR02
		DbSelectArea("UZ6")
		DbSkip()
		Loop
	Endif
	
	DbSelectArea("_cTrab")
	DbSetOrder(1)
	RecLock( "_cTrab", ! DBSEEK( UZ6->UZ6_COD, .F. ) )
	
	_cTrab->PRODUTO  := UZ6->UZ6_COD
	_cTrab->NOMEPROD := SB1->B1_DESC
	_cTrab->QTDPROD  := _cTrab->QTDPROD + UZ6->UZ6_QTDPROD
	_cTrab->DTMOV    := UZ6->UZ6_DATA
	_cTrab->QTDLIBER := _cTrab->QTDLIBER
	_cTrab->LINHA    := SUBS(SB1->B1_YREFPV,1,30)
	
	MsUnLock()
	DbCommit()
	
	OldData := UZ6->UZ6_DATA
	
	DbSelectArea("UZ6")
	DbSkip()
	
EndDo

IncProc()

Return( Nil )

// ACUMULA VALORES PARA SEREM IMPRESSOS

// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==> FUNCTION fAcumula
Static FUNCTION fAcumula()

//Acumula TOTAL DA CLASSE por quebra

aClasse[1] := aClasse[1] + _cTrab->QTDPROD
aClasse[2] := aClasse[2] + _cTrab->QTDLIBER

//Acumula TOTAL DO PRODUTO (cores) por quebra

aCores[1] := aCores[1] + _cTrab->QTDPROD
aCores[2] := aCores[2] + _cTrab->QTDLIBER

//Acumula TOTAL DA LINHA por quebra

aLinha[1] := aLinha[1] + _cTrab->QTDPROD
aLinha[2] := aLinha[2] + _cTrab->QTDLIBER

//Acumula TOTAL GERAL DA CLASSE A

IF SUBS( _cTrab->PRODUTO, 6, 1 ) == "1"
	aClasseA[1] := aClasseA[1] + _cTrab->QTDPROD
	aClasseA[2] := aClasseA[2] + _cTrab->QTDLIBER
ENDIF

//Acumula TOTAL GERAL DA CLASSE C

IF SUBS( _cTrab->PRODUTO, 6, 1 ) == "2"
	aClasseC[1] := aClasseC[1] + _cTrab->QTDPROD
	aClasseC[2] := aClasseC[2] + _cTrab->QTDLIBER
ENDIF

//Acumula TOTAL GERAL DA CLASSE D

IF SUBS( _cTrab->PRODUTO, 6, 1 ) >= "3"
	aClasseD[1] := aClasseD[1] + _cTrab->QTDPROD
	aClasseD[2] := aClasseD[2] + _cTrab->QTDLIBER
ENDIF

//Acumula TOTAL GERAL

aTotGer[1] := aTotGer[1] + _cTrab->QTDPROD
aTotGer[2] := aTotGer[2] + _cTrab->QTDLIBER

Return( Nil )

// IMPRIME AS ULTIMAS QUEBRAS DO RELATORIO E EM SEGUIDA FAZ UM RESUMO DOS VALORES

// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==> FUNCTION fImpRes
Static FUNCTION fImpRes()

//Quebra de Classe

wOldClas := IIF( wOldClas == "1", '"A"', IIF( wOldClas == "2", '"C"', '"D"' ) )
wIClasse := "TOTAL CLASSE    " + wOldClas  + Space(28 - LEN(wOldClas))
wIClasse := wIClasse + Tran( aClasse[1], "@E 999,999.99"     ) + Space(03)
wIClasse := wIClasse + Tran( aClasse[2], "@E 999,999.99"     )

li := li + 1

@ li,000 PSAY wIClasse

li := li + 1

//Quebra de CORES

wOldNome := Subst(wOldNome,22)
wICores := "TOTAL REFER.  " + SUBS(wOldNome,1,30) + Space(30 - LEN(wOldNome))
wICores  := wICores + Tran( aCores[1], "@E 999,999.99"     ) + Space(03)
wICores  := wICores + Tran( aCores[2], "@E 999,999.99"     )

li := li + 1

@ li,000 PSAY wICores

li := li + 1

//Quebra de LINHA

DBSELECTAREA("SB1")
DBSETORDER(1)
DBSEEK(xFilial("SB1")+wOldLine)

wILinha  := "TOTAL LINHA   " + SUBS(wNomeLinha,1,28)         + Space(02)
wILinha  := wILinha + Tran( aLinha[1], "@E 999,999.99"     ) + Space(03)
wILinha  := wILinha + Tran( aLinha[2], "@E 999,999.99"     )

li := li + 1

@ li,000 PSAY wILinha

li := li + 1

@ li,000 PSAY Replicate( "-", Limite )

fImpFormat()

li := li + 1

@ li,000 PSAY Replicate( "-", Limite )
wnTotProd := 0

//Quebra de Classe A

wnTotProd := 0
wnTotLib  := 0
wnTotProd := (aClasseA[1]/wsTotProd)  * 100
wnTotLib  := (aClasseA[2]/wsTotLiber) * 100
wIClasse  := 'TOTAL CLASSE  "A"  '                                 + Space(25)
wIClasse  := wIClasse + Tran( aClasseA[1], "@E 999,999.99"     )   + Space(03)
wIClasse  := wIClasse + Tran( aClasseA[2], "@E 999,999.99"     )   + Space(03)
wIClasse  := wIClasse + Tran( wnTotProd,   "@E 999.99"         )   + " %" + Space(03)
wIClasse  := wIClasse + Tran( wnTotLib ,   "@E 999.99"         )   + " %"

li := li + 1

@ li,000 PSAY wIClasse


//Quebra de Classe C

wnTotProd := 0
wnTotLib  := 0
wnTotProd := (aClasseC[1]/wsTotProd) * 100
wnTotLib  := (aClasseC[2]/wsTotLiber) * 100
wIClasse := 'TOTAL CLASSE  "C"  '                                  + Space(25)
wIClasse := wIClasse  + Tran( aClasseC[1], "@E 999,999.99"     )   + Space(03)
wIClasse := wIClasse  + Tran( aClasseC[2], "@E 999,999.99"     )   + Space(03)
wIClasse  := wIClasse + Tran( wnTotProd,   "@E 999.99"         )   + " %" + Space(03)
wIClasse  := wIClasse + Tran( wnTotLib ,   "@E 999.99"         )   + " %"

li := li + 1

@ li,000 PSAY wIClasse

//Quebra de Classe D

wnTotProd := 0
wnTotLib  := 0
wnTotProd := (aClasseD[1]/wsTotProd) * 100
wnTotLib  := (aClasseD[2]/wsTotLiber) * 100
wIClasse := 'TOTAL CLASSE  "D"  '                                  + SPACE(25)
wIClasse := wIClasse  + Tran( aClasseD[1], "@E 999,999.99"     )   + Space(03)
wIClasse := wIClasse  + Tran( aClasseD[2], "@E 999,999.99"     )   + Space(03)
wIClasse  := wIClasse + Tran( wnTotProd,   "@E 999.99"         )   + " %" + Space(03)
wIClasse  := wIClasse + Tran( wnTotLib ,   "@E 999.99"         )   + " %"

li := li + 1

@ li,000 PSAY wIClasse

//TOTAL GERAL

wITGeral := "TOTAL GERAL       "                                 + SPACE(26)
wITGeral := wITGeral + Tran( aTotGer[1], "@E 999,999.99"     )   + Space(03)
wITGeral := wITGeral + Tran( aTotGer[2], "@E 999,999.99"     )   + Space(03)
wITGeral := wITGeral + Tran( 100       , "@E 999.99"         )   + " %" + Space(03)
wITGeral := wITGeral + Tran( 100       , "@E 999.99"         )   + " %"

li := li + 1

@ li,000 PSAY wITGeral

li := li + 1

@ li,000 PSAY Replicate( "-", Limite )

Return( Nil )

// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==> FUNCTION fGravaRes
Static FUNCTION fGravaRes()

OLDAREA   := ALIAS()

DBSELECTAREA("cTrb")
DBSETORDER(1)

DO CASE
	CASE SUBS(_cTrab->PRODUTO,1,1) == "A"
		Cha_Pesq := "30X30"
	CASE SUBS(_cTrab->PRODUTO,1,1) == "B"
		Cha_Pesq := "40X40"
	CASE SUBS(_cTrab->PRODUTO,1,1) == "C"
		Cha_Pesq := "25X25"
	CASE SUBS(_cTrab->PRODUTO,1,1) == "D"
		Cha_Pesq := "43X43"
	CASE SUBS(_cTrab->PRODUTO,1,1) == "F"
		Cha_Pesq := "43X43"
	CASE SUBS(_cTrab->PRODUTO,1,1) == "Q"
		Cha_Pesq := "31X31"
	CASE SUBS(_cTrab->PRODUTO,1,1) == "R"
		Cha_Pesq := "44X44"
	CASE SUBS(_cTrab->PRODUTO,1,1) == "S"
		Cha_Pesq := "31X44"
	CASE SUBS(_cTrab->PRODUTO,1,1) == "T"
		Cha_Pesq := "26X36"
	OTHERWISE
		Cha_Pesq := "OUTROS"
ENDCASE

Cha_Pesq := Cha_Pesq + IIF(SUBS(_cTrab->PRODUTO,6,1) == "1", "A", IIF(SUBS(_cTrab->PRODUTO,6,1) == "2", "C", "D"))

RECLOCK( "cTrb", ! DBSEEK( Cha_Pesq, .F. ) )

cTrb->PRODUTO   := Cha_Pesq
cTrb->NOMEPROD  := _ctrab->NOMEPROD
cTrb->QTDPROD   := cTrb->QTDPROD  + _cTrab->QTDPROD
cTrb->DTMOV     := cTrb->DTMOV
cTrb->QTDLIBER  := cTrb->QTDLIBER + _cTrab->QTDLIBER

MSUNLOCK()
DBSELECTAREA(OLDAREA)

RETURN( NIL )


// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==> FUNCTION fImpFormat
Static FUNCTION fImpFormat()

// GRAVA A QUANTIDADE TOTAL PRODUZIDA E LIBERADA POR FORMATO NO RESUMO

DbSelectArea("cTrb")
DbGoTop()

While ! Eof()
	DbSelectArea("MAG")
	RecLock( "MAG", ! DbSeek( LEFT(cTrb->PRODUTO,2), .F. ) )
	MAG->PRODUTO   := LEFT(cTrb->PRODUTO,2)
	MAG->QTDPROD   := MAG->QTDPROD  + cTrb->QTDPROD
	MAG->QTDLIBER  := MAG->QTDLIBER + cTrb->QTDLIBER
	MsUnLock()
	DbSelectArea("cTrb")
	DbSkip()
End

DBSELECTAREA("cTrb")
DBGOTOP()

OLDFORMATO := ""
OLDPRODUTO := ""

//MONTA REGUA
ProcRegua( _cTrab->( LastRec() ) )

li := li + 1

@ li,000 PSAY "R E S U M O"

WHILE !EOF()
	
	INCPROC()
	
	If li >= 62
		Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15)
	Endif
	
	IF ( OLDFORMATO #LEFT(cTrb->PRODUTO,1) )
		li := li + 2
		@ li,000 PSAY "FORMATO " + LEFT(cTrb->PRODUTO,5)
		OLDPRODUTO := cTrb->PRODUTO
	ENDIF
	
	wnTotProd := 0
	wnTotLib  := 0
	DbSelectArea("MAG")
	DbSeek(LEFT(cTrb->PRODUTO,2))
	wnTotProd := (cTrb->QTDPROD/MAG->QTDPROD) * 100
	wnTotLib  := (cTrb->QTDLIBER/MAG->QTDLIBER) * 100
	wIDetalhe := "CLASSE " +RIGHT(RTRIM(cTrb->PRODUTO),1) + SPACE(36)
	wIDetalhe := wIDetalhe + Tran( cTrb->QTDPROD  , "@E 999,999.99"     ) + Space(03)
	wIDetalhe := wIDetalhe + Tran( cTrb->QTDLIBER , "@E 999,999.99"     ) + Space(03)
	wIDetalhe := wIDetalhe + Tran( wnTotProd     , "@E 999.99"         ) + " %" + Space(03)
	wIDetalhe := wIDetalhe + Tran( wnTotLib      , "@E 999.99"         ) + " %"
	
	li := li + 1
	
	@ li,000 PSAY wIDetalhe
	
	OLDFORMATO := LEFT(cTrb->PRODUTO,1)
	
	DBSELECTAREA("cTrb")
	DBSKIP()
	
	IF ( OLDFORMATO #LEFT(cTrb->PRODUTO,1) )
		li := li + 1
		@ li,000 PSAY "TOTAL FORMATO " + LEFT(OLDPRODUTO,5)
		@ li,044 PSAY Tran( MAG->QTDPROD  , "@E 999,999.99"     )
		@ li,057 PSAY Tran( MAG->QTDLIBER , "@E 999,999.99"     )
		OLDPRODUTO := cTrb-PRODUTO
	ENDIF
	
ENDDO

Return( Nil )

// CALCULA A QUANTIDADE TOTAL PRODUZIDA E A LIBERADA

// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==> FUNCTION fLe_TRAB
Static FUNCTION fLe_TRAB()

DbSelectArea("_cTrab")
DbGoTop()
wsTotProd  := 0
wsTotLiber := 0

While ! Eof()
	wsTotProd  := wsTotProd  + _cTrab->QTDPROD
	wsTotLiber := wsTotLiber + _cTrab->QTDLIBER
	DbSkip()
End

Return

// CALCULA A QUANTIDADE TOTAL PRODUZIDA E A LIBERADA POR LINHA

// Substituido pelo assistente de conversao do AP5 IDE em 10/09/03 ==> FUNCTION fLe_RAN
Static FUNCTION fLe_RAN()

DbSelectArea("_cTrab")
DbGoTop()

While ! Eof()
	DbSelectArea("RAN")
	RecLock( "RAN", ! DbSeek( Subs(_cTrab->PRODUTO,1,5), .F. ) )
	RAN->REFER     := Subs(_cTrab->PRODUTO,1,5)
	RAN->QTDPROD   := RAN->QTDPROD  + _cTrab->QTDPROD
	RAN->QTDLIBER  := RAN->QTDLIBER + _cTrab->QTDLIBER
	MsUnLock()
	DbSelectArea("_cTrab")
	DbSkip()
End

Return

