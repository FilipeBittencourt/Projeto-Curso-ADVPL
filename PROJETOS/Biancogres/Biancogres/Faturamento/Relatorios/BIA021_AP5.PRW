#include "rwmake.ch"
#include "relato.ch"
#include "topconn.ch"

User Function Bia021()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CQUERY,CWHERE,CPRODDE,CPRODATE,CAGLGRAD,CSERIEDE,CSERIEATE,CREPDE,CREPATE")
SetPrvt("CDESC1,CDESC2,CDESC3,CALIAS,CNOMEPROG,CNOMEARQ,COLDALIAS,CCLIDE,CCLIATE")
SetPrvt("CTITULO,CCABEC1,CCABEC2,CTAMANHO,CDADOS,CARQTEMP1,CARQTEMP2,CTIPOREL")
SetPrvt("CCLAATUAL,CCORATUAL,CLINATUAL")
SetPrvt("LGRAVPARAM,LTEMDIC,LPODECOMP,LABORTPRINT")
SetPrvt("ARETURN,ACAMPOS,ACONCENC,ADCONCENC")
SetPrvt("NCRCCONTROL,NL,NTOTREGS,NTAMANHO,NUNIMED,NPRCUNIT,CFORANT")
SetPrvt("DDATADE,DDATAATE,CCODANT,CFLAG,NTAM1")
Private cfop_de, cfop_ate
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 	 ³ BIA021	  ³ Autor ³ Microsiga Vitoria     ³ Data ³29/04/1999³±±
±±³          ³          ³ Alter.³ Luana P. de Souza     ³ Data ³03/05/1999³±±
±±³          ³          ³ Alter.³ Augusto C. de Oliveira³ Data ³27/09/1999³±±
±±³          ³          ³ Alter.³ Wladimir Illiushenko  ³ Data ³17/12/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relacao de vendas por produto.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		   ³ SIGAFAT	                        												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis.												     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDesc1			:= "Este programa tem como objetivo emitir um relatorio das vendas por produto     "
cDesc2			:= ""
cDesc3			:= ""
cTamanho        := "M"
cAlias 			:= "SC5"
cTitulo			:= "RELACAO DE VENDAS POR PRODUTO (EM METROS QUADRADOS)"
aReturn			:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
cNomeProg 		:= "BIA021"
nLastkey        := 0
nCbcont			:= 0
cCbtxt 			:= space(10)
m_pag			:= 1
aOrd		   	:= { }
lGravParam 	   	:= .F.
lPodeComp      	:= .T.
lTemDic	       	:= .F.
lGravParam     	:= .F.
nL             	:= 80

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT.								     ³
//³ Verifica Posicao do Formulario na Impressora.						     ³
//³                                          							     ³
//³ Pega os valores passados como parametro: 							     ³
//³ MV_PAR01 -> Da Data de Emissao    ?      							     ³
//³ MV_PAR02 -> Ate a Data de Emissao ?      							     ³
//³ MV_PAR03 -> Do Produto            ?      							     ³
//³ MV_PAR04 -> Ate o Produto         ?      							     ³
//³ MV_PAR05 -> Unidade de Medida     ?      							     ³
//³ MV_PAR06 -> Da Serie de NF        ?      							     ³
//³ MV_PAR07 -> Ate a Serie de NF     ?      							     ³
//³ MV_PAR08 -> Tipo do Relatorio     ?      							     ³
//³ MV_PAR09 -> Do Cliente            ?      							     ³
//³ MV_PAR10 -> Ate o Cliente         ?      							     ³
//³ MV_PAR11 -> Do Representante      ?      							     ³
//³ MV_PAR12 -> Ate o Representante   ?      							     ³
//³ MV_PAR13 -> Soma IPI              ?      							     ³
//³ MV_PAR14 -> CFOP de               ?      							     ³
//³ MV_PAR15 -> CFOP ate              ?                                      |
//| MV_PAR16 -> Classificacao de      ?                                      |
//| MV_PAR17 -> Classificacao ate     ?                                      ³
//| MV_PAR18 -> Atendente             ?                                      ³
//| MV_PAR19 -> Segmento De           ?                                      ³
//| MV_PAR20 -> Segmento Ate          ?                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Pergunte(cNomeProg,lGravParam)

cNomeArq := SetPrint(cAlias, cNomeProg, cNomeProg, @cTitulo, cDesc1, cDesc2, cDesc3, lTemDic, aOrd, lPodeComp, cTamanho)

If ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
	Return
Endif
SetDefault(aReturn, cAlias)

dDataDe     := mv_par01
dDataAte    := mv_par02
cProdDe     := mv_par03
cProdAte    := mv_par04
nUniMed     := mv_par05
cSerieDe    := mv_par06
cSerieAte   := mv_par07
cTipoRel    := IIF(mv_par08 == 1, "ANALITICO", IIF(mv_par08 == 2,"SINTETICO","TOTALIZADO"))
cCliDe      := mv_par09
cCliAte     := mv_par10
cRepDe      := mv_par11
cRepAte     := mv_par12
nSomaIPI    := mv_par13
cfop_de     := mv_par14
cfop_ate    := mv_par15
cClassifDe  := mv_par16
cClassifAte := mv_par17
cAtendente  := mv_par18 
cSegDe		:= mv_par19
cSegAte		:= mv_par20

nTamanho    := 132
nCrcControl := iif(aReturn[4]==1,15,18)
cCabec1     := "CODIGO     DESCRICAO DO PRODUTO              PRECO     QUANTIDADE          VALOR   UNIT.     QUANTIDADE          VALOR      DESCONTO"
cCabec2     := "                                          UNITARIO    EM CARTEIRA    EM CARTEIRA  FATUR.       FATURADA       FATURADA     CONCEDIDO"

Processa({|| fCriaTemp() })
Processa({|| fAcumula()  })
Processa({|| fImprime()  })
Processa({|| fApagaTemp()})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera impressao.												         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if aReturn[5] == 1
	set printer to
	OurSpool(cNomeArq)
endif

Ft_PFlush()
return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fCriaTemp³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria arquivo temporario para impressao do relatorio.       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FUNCTION fCriaTemp()
Local aCampos

aCampos := {}
AADD(aCampos,{"PRODUTO ","C",15, 0})
AADD(aCampos,{"NOMEPROD","C",32, 0})
AADD(aCampos,{"PRUNIT  ","N",12, 2})
AADD(aCampos,{"QTDEVEND","N",12, 2})
AADD(aCampos,{"VLRVEND ","N",12, 2})
AADD(aCampos,{"QTDEFAT ","N",12, 2})
AADD(aCampos,{"PRUNIFAT","N",12, 2})
AADD(aCampos,{"VLRFAT  ","N",12, 2})
AADD(aCampos,{"UM      ","C",02, 2})
AADD(aCampos,{"DESCONTO","N",12, 2})
cArqTemp1 := CriaTrab(aCampos, .T.)
DbUseArea(.T.,,cArqTemp1,"REL")
DbCreateInd(cArqTemp1,"PRODUTO+STR(PRUNIT,10,2)",{||PRODUTO+STR(PRUNIT,10,2)})

aCampos := {}
AADD(aCampos,{"PRODUTO ","C",15, 0})
AADD(aCampos,{"NOMEPROD","C",32, 0})
AADD(aCampos,{"PRUNIT  ","N",12, 2})
AADD(aCampos,{"QTDEVEND","N",12, 2})
AADD(aCampos,{"VLRVEND ","N",12, 2})
AADD(aCampos,{"QTDEFAT ","N",12, 2})
AADD(aCampos,{"PRUNIFAT","N",12, 2})
AADD(aCampos,{"VLRFAT  ","N",12, 2})
AADD(aCampos,{"UM      ","C",02, 2})
AADD(aCampos,{"DESCONTO","N",12, 2})
cArqTemp2 := CriaTrab(aCampos, .T.)
DbUseArea(.T.,,cArqTemp2,"TMP")
DbCreateInd(cArqTemp2,"PRODUTO",{||PRODUTO})
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³ fAcumula ³ Autor ³ WLADIMIR ILLIUSHENKO				            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Acumula os dados no arquivo temporario.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FUNCTION fAcumula()

cQuery  := ""
cWhere  := ""
cQuery  += "SELECT COUNT(SC6.C6_NUM) AS TOTREGS "
cWhere  += "FROM "+RetSqlName("SC6")+" SC6 ,"+RetSqlName("SB1")+" SB1 ,"+RetSqlName("SC5")+" SC5, "+RetSqlName("SA1")+" SA1 "
cWhere  += "WHERE "
cWhere  += "      (SC6.C6_FILIAL	= '"+xFilial("SC6")+"') AND "
cWhere  += "      (SC5.C5_FILIAL	= '"+xFilial("SC5")+"') AND "
cWhere  += "      (SC5.C5_NUM		= SC6.C6_NUM) AND "
cWhere  += "      (SC5.C5_CLIENTE	= SC6.C6_CLI) AND "
cWhere  += "      (SC5.C5_LOJACLI	= SC6.C6_LOJA) AND "

cWhere  += "      (SC5.C5_CLIENTE	= SA1.A1_COD) AND "
cWhere  += "      (SC5.C5_LOJACLI	= SA1.A1_LOJA) AND "

cWhere  += "      (SC5.C5_EMISSAO BETWEEN '"+dtos(dDataDe)+"' AND '"+dtos(dDataAte)+"') AND "
cWhere  += "      (SC5.C5_CLIENTE BETWEEN '"+cCliDe+"' AND '"+cCliAte+"') AND "
cWhere  += "      (SC5.C5_VEND1 BETWEEN '"+cRepDe+"' AND '"+cRepAte+"') AND "

If Alltrim(cAtendente) <> ""
	cWhere += "		(SC5.C5_VEND1 IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+" WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND ZZI_ATENDE = '"+cAtendente+"'	AND D_E_L_E_T_ = '')) AND "
EndIf

cWhere  += ""
cWhere  += "      (SC6.C6_PRODUTO BETWEEN '"+cProdDe+"' AND '"+cProdAte+"') AND "
cWhere  += "      (SC6.C6_CF      BETWEEN '"+ cfop_de +"' AND '"+cfop_ate+"') AND "
cWhere  += "      (SC6.C6_TES IN ('797',( "
cWhere  += "                             SELECT SF4.F4_CODIGO "
cWhere  += "                             FROM "+RetSqlName("SF4")+" SF4 "
cWhere  += "                             WHERE                "
cWhere  += "                                   (SF4.F4_FILIAL = '"+xFilial("SF4")+"') AND "
cWhere  += "                                   (SF4.F4_CODIGO = SC6.C6_TES) AND "
//cWhere  += "                                   (SF4.F4_DUPLIC+F4_ESTOQUE = 'SS') AND "
cWhere  += "                                   (SF4.F4_DUPLIC = 'S') AND "
cWhere  += "                                   (SF4.D_E_L_E_T_ = '') ))) AND "
cWhere  += ""
cWhere  += "      (SB1.B1_FILIAL = '"+xFilial("SB1")+"') AND "
cWhere  += "      (SB1.B1_COD  = SC6.C6_PRODUTO) AND "
cWhere  += "      (SB1.B1_TIPO = 'PA') AND "
cWhere  += "      (SB1.B1_YCLASSE BETWEEN '"+cClassifDe+"' AND '"+cClassifAte+"') AND "
cWhere  += "      (SA1.A1_SATIV1  BETWEEN '"+cSegDe+"' AND '"+cSegAte+"') AND "
cWhere  += "      (SC5.D_E_L_E_T_ = '') AND "
cWhere  += "      (SC6.D_E_L_E_T_ = '') AND "
cWhere  += "      (SA1.D_E_L_E_T_ = '') AND "
cWhere  += "      (SB1.D_E_L_E_T_ = '')     "
cQuery  := cQuery + cWhere
TCQuery cQuery Alias "X" New
nTotRegs := X->TOTREGS
X->(DbCloseArea())

if nTotRegs > 0
	ProcRegua(nTotRegs)
	
	cQuery  := ""
	cQuery  += "SELECT "
	cQuery  += "       C6_PRODUTO, "
	cQuery  += "       C6_PRCVEN,  "
	cQuery  += "       C6_QTDVEN,  "
	cQuery  += "       C6_UM,      "
	cQuery  += "       C6_UNSVEN,  "
	cQuery  += "       C6_VALOR,   "
	cQuery  += "       C6_SEGUM,   "
	cQuery  += "       C6_YDESC,   "
	cQuery  += "       B1_DESC     "
	cQuery  := cQuery + cWhere
	TCQuery cQuery Alias "QRY" New
	
	do while !QRY->(Eof())
		IncProc("Processando Pedidos em Carteira ...")
		RecLock("REL", !REL->(DbSeek( QRY->C6_PRODUTO + IIF( cTipoRel == "ANALITICO", str(QRY->C6_PRCVEN,10,2), "" ), .F. )) )
		REL->QTDEVEND := IIF(nUniMed == 1,REL->QTDEVEND + QRY->C6_QTDVEN, REL->QTDEVEND + QRY->C6_UNSVEN)
		REL->PRUNIT   := IIF(nUniMed == 1,QRY->C6_PRCVEN, QRY->C6_VALOR/QRY->C6_UNSVEN)
		REL->UM       := IIF(nUniMed == 1,QRY->C6_UM, QRY->C6_SEGUM)
		REL->PRODUTO  := QRY->C6_PRODUTO
		REL->NOMEPROD := QRY->B1_DESC
		REL->VLRVEND  := REL->VLRVEND  + QRY->C6_VALOR
		REL->DESCONTO := REL->DESCONTO + ((QRY->C6_VALOR * QRY->C6_YDESC) / 100)
		REL->(MSUnLock())
		REL->(DBCommit())
		QRY->(DBSkip())
	enddo
	
	QRY->(DbCloseArea())
endif

cQuery  := ""
cWhere  := ""
cQuery  += "SELECT COUNT(SD2.D2_DOC) AS TOTREGS "
cWhere  += "FROM "+RetSqlName("SD2")+" SD2,"+RetSqlName("SB1")+" SB1,"+RetSqlName("SF2")+" SF2 , "+RetSqlName("SA1")+" SA1 "
cWhere  += "WHERE "
cWhere  += "      (SD2.D2_FILIAL = '"+xFilial("SD2")+"') AND "
cWhere  += "      (SD2.D2_GRUPO = 'PA') AND "
cWhere  += "      (SD2.D2_COD BETWEEN '"+cProdDe+"' AND '"+cProdAte+"') AND "
cWhere  += "      (SD2.D2_CF  BETWEEN '"+cfop_de +"' AND '"+cfop_ate +"') AND "
cWhere  += "      (SF2.F2_FILIAL  = '"+xFilial("SF2")+"'  ) AND "

cWhere  += "      (SF2.F2_DOC   = SD2.D2_DOC    ) AND "
cWhere  += "      (SF2.F2_SERIE = SD2.D2_SERIE  ) AND "     

cWhere  += "      (SD2.D2_CLIENTE = SA1.A1_COD  ) AND "
cWhere  += "      (SD2.D2_LOJA	  = SA1.A1_LOJA ) AND "     

cWhere  += "      (SF2.F2_SERIE BETWEEN '"+cSerieDe+"' AND '"+cSerieAte+"') AND  "
cWhere  += "      (SF2.F2_EMISSAO BETWEEN '"+dtos(dDataDe)+"' AND '"+dtos(dDataAte)+"') AND "
cWhere  += "      (SF2.F2_CLIENTE BETWEEN '"+cCliDe+"' AND '"+cCliAte+"') AND "
cWhere  += "      (SF2.F2_VEND1 BETWEEN '"+cRepDe+"' AND '"+cRepAte+"') AND "

If Alltrim(cAtendente) <> ""
	cWhere += "		(SF2.F2_VEND1 IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+" WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND ZZI_ATENDE = '"+cAtendente+"'	AND D_E_L_E_T_ = '')) AND "
	/*If cEmpAnt == "01"
		cWhere  += "	(SF2.F2_VEND1 IN (SELECT A3_COD FROM SA3010 WHERE A3_YATEBIA = '"+cAtendente+"' AND D_E_L_E_T_ = '')) AND "
	Else 
		cWhere  += "	(SF2.F2_VEND1 IN (SELECT A3_COD FROM SA3010 WHERE A3_YATEINC = '"+cAtendente+"' AND D_E_L_E_T_ = '')) AND "
	EndIf*/
EndIf

cWhere  += ""
cWhere  += "      (SD2.D2_TES IN ('797',( "
cWhere  += ""
cWhere  += "                             SELECT SF4.F4_CODIGO "
cWhere  += "                             FROM "+RetSqlName("SF4")+" SF4 "
cWhere  += "                             WHERE                "
cWhere  += "                                   (SF4.F4_FILIAL = '"+xFilial("SF4")+"') AND "
cWhere  += "                                   (SF4.F4_CODIGO = SD2.D2_TES) AND "
//cWhere  += "                                   (SF4.F4_DUPLIC+F4_ESTOQUE = 'SS') AND "
cWhere  += "                                   (SF4.F4_DUPLIC = 'S') AND "
cWhere  += "                                   (SF4.D_E_L_E_T_ = '') ))) AND "
cWhere  += ""
cWhere  += "      (SB1.B1_FILIAL = '"+xFilial("SB1")+"') AND "
cWhere  += "      (SB1.B1_COD  = SD2.D2_COD) AND "
cWhere  += "      (SB1.B1_TIPO = 'PA') AND "
cWhere  += "      (SB1.B1_YCLASSE BETWEEN '"+cClassifDe+"' AND '"+cClassifAte+"') AND "
cWhere  += "      (SA1.A1_SATIV1  BETWEEN '"+cSegDe+"' AND '"+cSegAte+"') AND "
cWhere  += "      (SF2.D_E_L_E_T_ = '') AND "
cWhere  += "      (SD2.D_E_L_E_T_ = '') AND "
cWhere  += "      (SA1.D_E_L_E_T_ = '') AND "
cWhere  += "      (SB1.D_E_L_E_T_ = '')     "

cQuery  := cQuery + cWhere
TCQuery cQuery Alias "X" New
nTotRegs := X->TOTREGS
X->(DbCloseArea())

if nTotRegs > 0
	ProcRegua(nTotRegs)
	
	cQuery  := ""
	cQuery  += "SELECT "
	cQuery  += "       D2_PRCVEN,  "
	cQuery  += "       D2_TOTAL,   "
	cQuery  += "       D2_QTSEGUM, "
	cQuery  += "       D2_COD,     "
	cQuery  += "       D2_UM,      "
	cQuery  += "       D2_QUANT,   "
	cQuery  += "       D2_VALIPI,  "
	cQuery  += "       B1_DESC     "
	cQuery  := cQuery + cWhere
	TCQuery cQuery Alias "QRY" New
	
	do while !QRY->(Eof())
		IncProc("Processando Produtos Faturados ...")
		
		nPrcUnit := IIF( nUniMed == 1, QRY->D2_PRCVEN, QRY->D2_TOTAL/QRY->D2_QTSEGUM )
		if !REL->(DbSeek( QRY->D2_COD+IIF( cTipoRel == "ANALITICO", Str(nPrcUnit,10,2), "" ), .F. ))
			
			RecLock("REL",.T.)
			REL->PRODUTO  := QRY->D2_COD
			REL->NOMEPROD := QRY->B1_DESC
			REL->VLRFAT   += If(nSomaIPI == 1,QRY->D2_TOTAL,QRY->D2_TOTAL+QRY->D2_VALIPI)
			if nUniMed == 1
				REL->UM      := QRY->D2_UM
				REL->QTDEFAT := REL->QTDEFAT + QRY->D2_QUANT
				REL->PRUNIFAT:= QRY->D2_PRCVEN
			else
				REL->UM      := SD2->D2_SEGUM
				REL->QTDEFAT := REL->QTDEFAT + SD2->D2_QTSEGUM
				REL->PRUNIFAT:= SD2->D2_TOTAL/SD2->D2_QTSEGUM
			endif
			REL->(MSUnLock())
			
		else
			
			RecLock("REL",.F.)
			REL->VLRFAT += If(nSomaIPI == 1,QRY->D2_TOTAL,QRY->D2_TOTAL+QRY->D2_VALIPI)
			if nUniMed == 1
				REL->QTDEFAT := REL->QTDEFAT + QRY->D2_QUANT
				REL->PRUNIFAT:= QRY->D2_PRCVEN
			else
				REL->QTDEFAT := REL->QTDEFAT + QRY->D2_QTSEGUM
				REL->PRUNIFAT:= QRY->D2_TOTAL/QRY->D2_QTSEGUM
			endif
			REL->(MSUnLock())
			
		endif
		
		QRY->(DbSkip())
	enddo
	
	QRY->(DbCloseArea())
endif
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fImprime  ³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprime os dados da tabela temporaria. 					  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FUNCTION fImprime()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona a tabela temporaria.											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua(REL->(LastRec()))
REL->(DBGoTop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa as variaveis utilizadas na impressao.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+REL->PRODUTO)

cNomeLinha := Space(28)
cOldClas   := SB1->B1_YCLASSE
cOldCor    := Subs(SB1->B1_YLINHA,4,1)
cOldLine   := SB1->B1_YFORMAT+SB1->B1_YFATOR+Subs(SB1->B1_YLINHA,1,3)
cOldNome   := REL->NOMEPROD
cOldProd   := REL->PRODUTO
cCodAnt    := REL->PRODUTO
cForAnt    := SUBSTR(REL->PRODUTO,1,2)
aClasse    := {0,0,0,0,0,0,0}
aCores     := {0,0,0,0,0,0,0}
aLinha     := {0,0,0,0,0,0,0}
aClasseA   := {0,0,0,0,0,0,0}
aClasseC   := {0,0,0,0,0,0,0}
aClasseD   := {0,0,0,0,0,0,0}
aTotGer    := {0,0,0,0,0,0,0}
lPrimVez   := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa relatorio.                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
do while !REL->(EOF())
	
	IF SUBSTR(REL->PRODUTO,1,8) == 'AM0090B1'
		lTeste := .F.
	ENDIF
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+REL->PRODUTO)
	
	IF ALLTRIM(REL->PRODUTO) == 'A20056B1'
		lOK := .T.
	ENDIF
	
	Incproc("Imprimindo...")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guarda os dados do produto atual.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cClaAtual  := SB1->B1_YCLASSE
	cCorAtual  := Subs(SB1->B1_YLINHA,4,1)
	cLinAtual  := SB1->B1_YFORMAT+SB1->B1_YFATOR+Subs(SB1->B1_YLINHA,1,3)
	
	cFlag := '*'
	DbSelectArea("SG1")
	DbSetOrder(1)
	DbSeek(xFilial("SG1")+SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA,.T.)
	IF ALLTRIM(SG1->G1_COD) == SB1->B1_YFORMAT+SB1->B1_YFATOR+SB1->B1_YLINHA
		cFlag := ' '
	ENDIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento da impressao pelo usuario.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if Interrupcao(@lAbortPrint)
		return
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime parametros.                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if m_pag == 1
		u_ImpPar(cNomeProg,cTitulo,cTamanho,nCrcControl,nCbCont,cCbtxt,@nL)
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho.												     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nL >= 65
		nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime o nome da linha de produtos se e a primeira vez que passa por... ³
	//³ aqui.                                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if lPrimVez
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define substring a ser impressa no relatorio.                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if "OVIEDO BISOTADO" $ REL->NOMEPROD
			cNomeLinha := "OVIEDO BISOTADO"
			cNomeLinha := cNomeLinha + SPACE(30 - LEN(cNomeLinha))
		else
			if "SAN " $ REL->NOMEPROD
				cNomeLinha := "SAN MARINO"
				cNomeLinha := cNomeLinha + SPACE(30 - LEN(cNomeLinha))
			else
				cNomeLinha := SUBS( REL->NOMEPROD, 1, AT(" ", REL->NOMEPROD ) )
				cNomeLinha := cNomeLinha + SPACE(30 - LEN(cNomeLinha))
			endif
		endif
		
		@nL,000 PSay cNomeLinha
		nL++
		lPrimVez := .F.
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quebra de classe.                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if (cClaAtual <> cOldClas) .OR. (cCorAtual <> cOldCor) .OR. (cLinAtual <> cOldLine)
		DbSelectArea("ZZ8")
		DbSetOrder(1)
		IF DbSeek(xFilial("ZZ8")+cOldClas)
			cOldClas := ALLTRIM(ZZ8->ZZ8_DESC)
		ELSE
			MsgStop("Classe: "+cOldClas+"-"+cCodAnt+", nao programada para este programa: INC021")
		ENDIF
		
		cIClasse := "TOTAL CLASSE  " + cOldClas  + Space(28 - LEN(cOldClas)) + Space(02)
		cIClasse += Tran( aClasse[1], "@E 999.99"          ) + Space(02)
		cIClasse += Tran( aClasse[2], "@E 99,999,999.99"   ) + Space(02)
		cIClasse += Tran( aClasse[3], "@E 99,999,999.99"   ) + Space(02)
		cIClasse += Tran( aClasse[4], "@E 999.99"          ) + Space(02)
		cIClasse += Tran( aClasse[5], "@E 99,999,999.99"   ) + Space(02)
		cIClasse += Tran( aClasse[6], "@E 99,999,999.99"   ) + Space(02)
		cIClasse += Tran( aClasse[7], "@E 9,999,999.99"    )
		
		nL++
		@nL,000 PSay cIClasse
		
		nL       += IIF(cTipoRel <> "TOTALIZADO", 1, 0 )
		aClasse  := {0,0,0,0,0,0,0}
		cOldClas := cClaAtual
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quebra de cores.                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if (cCorAtual <> cOldCor) .OR. (cLinAtual <> cOldLine)
		nPosicao := 0
		DbSelectArea("ZZ6")
		DbSetOrder(1)
		DbSeek(xFilial("ZZ6")+cForAnt)
		
		IF AT('RET',ALLTRIM(ZZ6->ZZ6_DESC)) > 0
			nTam1 := AT('RET',ALLTRIM(ZZ6->ZZ6_DESC)) - 2
		ELSE
			nTam1 := 10
		ENDIF
		
		nPosicao := RAT(ALLTRIM(SUBSTR(ZZ6->ZZ6_DESC,1,nTam1)), Upper(cOldNome)) + 5
		
		cOldNome := IIF( nPosicao > 0, Subs(cOldNome, 1, nPosicao ), "OUTROS FORMATOS " )
		
		cICores  := "TOTAL REFER.  " + Subs(cOldNome,1,30) + Space(30 - LEN(cOldNome))
		cICores  += Tran( aCores[1], "@E 999.99"          ) + Space(02)
		cICores  += Tran( aCores[2], "@E 99,999,999.99"   ) + Space(02)
		cICores  += Tran( aCores[3], "@E 99,999,999.99"   ) + Space(02)
		cICores  += Tran( aCores[4], "@E 999.99"          ) + Space(02)
		cICores  += Tran( aCores[5], "@E 99,999,999.99"   ) + Space(02)
		cICores  += Tran( aCores[6], "@E 99,999,999.99"   ) + Space(02)
		cICores  += Tran( aCores[7], "@E 9,999,999.99"    )
		nL++
		@nL,000 PSay cICores
		
		nL       += IIF(cTipoRel <> "TOTALIZADO", 1, 0 )
		aCores   := {0,0,0,0,0,0,0}
		cOldCor  := cCorAtual
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quebra de linha.                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if cLinAtual <> cOldLine
		
		DBSelectArea("SB1")
		SB1->(DBSetOrder(1))
		SB1->(DBSeek(xFilial("SB1")+cOldLine))
		
		cILinha  := "TOTAL LINHA   " + Subs(cNomeLinha,1,28)         + Space(02)
		cILinha  += Tran( aLinha[1], "@E 999.99"         ) + Space(02)
		cILinha  += Tran( aLinha[2], "@E 99,999,999.99"  ) + Space(02)
		cILinha  += Tran( aLinha[3], "@E 99,999,999.99"  ) + Space(02)
		cILinha  += Tran( aLinha[4], "@E 999.99"         ) + Space(02)
		cILinha  += Tran( aLinha[5], "@E 99,999,999.99"  ) + Space(02)
		cILinha  += Tran( aLinha[6], "@E 99,999,999.99"  ) + Space(02)
		cILinha  += Tran( aLinha[7], "@E 9,999,999.99"   )
		nL++
		@nL,000 PSay cILinha
		
		nL++
		@nL,000 PSay Replicate("-", nTamanho)
		
		aLinha   := {0,0,0,0,0,0,0}
		cOldLine := cLinAtual
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define substring a ser impressa no relatorio.                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if "OVIEDO BISOTADO" $ REL->NOMEPROD
			cNomeLinha := "OVIEDO BISOTADO"
			cNomeLinha := cNomeLinha + SPACE(30 - LEN(cNomeLinha))
		else
			if "SAN " $ REL->NOMEPROD
				cNomeLinha := "SAN MARINO"
				cNomeLinha := cNomeLinha + SPACE(30 - LEN(cNomeLinha))
			else
				cNomeLinha := SUBS( REL->NOMEPROD, 1, AT(" ", REL->NOMEPROD ) )
				cNomeLinha := cNomeLinha + SPACE(30 - LEN(cNomeLinha))
			endif
		endif
		nL++
		
		if nL+3 >= 65
			nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
		ENDIF
		
		@nL,000 PSay cNomeLinha
		nL++
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acumula TOTAL DA CLASSE por quebra.                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aClasse[3] += REL->VLRVEND
	aClasse[2] += REL->QTDEVEND
	aClasse[6] += REL->VLRFAT
	aClasse[5] += REL->QTDEFAT
	aClasse[7] += REL->DESCONTO
	aClasse[1] := aClasse[3] / aClasse[2]
	aClasse[4] := aClasse[6] / aClasse[5]
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acumula TOTAL DO PRODUTO (cores) por quebra.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCores[3] += REL->VLRVEND
	aCores[2] += REL->QTDEVEND
	aCores[6] += REL->VLRFAT
	aCores[5] += REL->QTDEFAT
	aCores[7] := aCores[7] + REL->DESCONTO
	aCores[1] := aCores[3] / aCores[2]
	aCores[4] := aCores[6] / aCores[5]
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acumula TOTAL DA LINHA por quebra.                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aLinha[3] += REL->VLRVEND
	aLinha[2] += REL->QTDEVEND
	aLinha[6] += REL->VLRFAT
	aLinha[5] += REL->QTDEFAT
	aLinha[7] += REL->DESCONTO
	aLinha[1] := aLinha[3] / aLinha[2]
	aLinha[4] := aLinha[6] / aLinha[5]
	
	do case
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula TOTAL GERAL DA CLASSE A.                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		case cClaAtual == "1"
			aClasseA[3] += REL->VLRVEND
			aClasseA[2] += REL->QTDEVEND
			aClasseA[6] += REL->VLRFAT
			aClasseA[5] += REL->QTDEFAT
			aClasseA[7] += REL->DESCONTO
			aClasseA[1] := aClasseA[3] / aClasseA[2]
			aClasseA[4] := aClasseA[6] / aClasseA[5]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula TOTAL GERAL DA CLASSE C.                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		case cClaAtual == "2"
			aClasseC[3] += REL->VLRVEND
			aClasseC[2] += REL->QTDEVEND
			aClasseC[6] += REL->VLRFAT
			aClasseC[5] += REL->QTDEFAT
			aClasseC[7] += REL->DESCONTO
			aClasseC[1] := aClasseC[3] / aClasseC[2]
			aClasseC[4] := aClasseC[6] / aClasseC[5]
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula TOTAL GERAL DA CLASSE D.                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		case cClaAtual >= "3"
			aClasseD[3] += REL->VLRVEND
			aClasseD[2] += REL->QTDEVEND
			aClasseD[6] += REL->VLRFAT
			aClasseD[5] += REL->QTDEFAT
			aClasseD[7] += REL->DESCONTO
			aClasseD[1] := aClasseD[3] / aClasseD[2]
			aClasseD[4] := aClasseD[6] / aClasseD[5]
	endcase
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acumula TOTAL GERAL.                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTotGer[3] += REL->VLRVEND
	aTotGer[2] += REL->QTDEVEND
	aTotGer[6] += REL->VLRFAT
	aTotGer[5] += REL->QTDEFAT
	aTotGer[7] += REL->DESCONTO
	aTotGer[1] := aTotGer[3] / aTotGer[2]
	aTotGer[4] := aTotGer[6] / aTotGer[5]
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acumula RESUMO.                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+REL->PRODUTO)
	
	DbSelectArea("ZZ6")
	DbSetOrder(1)
	DbSeek(xFilial("ZZ6")+SB1->B1_YFORMAT)
	
	DbSelectArea("ZZ8")
	DbSetOrder(1)
	IF DbSeek(xFilial("ZZ8")+SB1->B1_YCLASSE)
		cChavePesq := "OUTROS"+ALLTRIM(ZZ8->ZZ8_DESC)
	ELSE
		MsgStop("Classe: "+SB1->B1_YCLASSE+"-"+SB1->B1_COD+", nao programada para este programa: INC021")
	ENDIF
	cChavePesq := ALLTRIM(ZZ6->ZZ6_DESC)+ALLTRIM(ZZ8->ZZ8_DESC)
	
	RecLock("TMP", !TMP->(DBSeek(cChavePesq,.F.)))
	TMP->QTDEVEND  += REL->QTDEVEND
	TMP->VLRVEND   += REL->VLRVEND
	TMP->DESCONTO  += REL->DESCONTO
	TMP->QTDEFAT   += REL->QTDEFAT
	TMP->VLRFAT    += REL->VLRFAT
	TMP->PRUNIT    := TMP->VLRVEND / TMP->QTDEVEND
	TMP->PRUNIFAT  := TMP->VLRFAT / TMP->QTDEFAT
	TMP->PRODUTO   := cChavePesq
	TMP->NOMEPROD  := REL->NOMEPROD
	TMP->UM        := REL->UM
	TMP->(MSUnlock())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime detalhes (produto x preco).                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if cTipoRel <> "TOTALIZADO"
		cIDetalhe := cFlag+SUBSTR(REL->PRODUTO,1,8) + Space(01)
		cIDetalhe := cIDetalhe + REL->NOMEPROD + Space(02)
		cIDetalhe += Tran( REL->PRUNIT   , "@E 999.99"         ) + Space(02)
		cIDetalhe += Tran( REL->QTDEVEND , "@E 99,999,999.99"  ) + Space(02)
		cIDetalhe += Tran( REL->VLRVEND  , "@E 99,999,999.99"  ) + Space(02)
		cIDetalhe += Tran( REL->PRUNIFAT , "@E 999.99"         ) + Space(02)
		cIDetalhe += Tran( REL->QTDEFAT  , "@E 99,999,999.99"  ) + Space(02)
		cIDetalhe += Tran( REL->VLRFAT   , "@E 99,999,999.99"  ) + Space(02)
		cIDetalhe += Tran( REL->DESCONTO , "@E 9,999,999.99"   )
		nL++
		@nL,000 PSay cIDetalhe
	endif
	
	cOldNome := REL->NOMEPROD
	cCodAnt  := REL->PRODUTO
	cForAnt  := SUBSTR(REL->PRODUTO,1,2)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Proximo registro.                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	REL->(DBSkip())
enddo

if nL >= 65
	nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Resumo da Quebra de classe.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("ZZ8")
DbSetOrder(1)
DbSeek(xFilial("ZZ8")+cOldClas)

cIClasse := "TOTAL CLASSE  " + cOldClas  + Space(28 - LEN(cOldClas)) + Space(02)
cIClasse += Tran( aClasse[1], "@E 999.99"         ) + Space(02)
cIClasse += Tran( aClasse[2], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasse[3], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasse[4], "@E 999.99"         ) + Space(02)
cIClasse += Tran( aClasse[5], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasse[6], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasse[7], "@E 9,999,999.99"   )
nL++
@nL,000 PSay cIClasse
nL += IIF(cTipoRel <> "TOTALIZADO",1,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Resumo da Quebra de Cores.                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosicao := 0
DbSelectArea("SB1")
DbSetOrder(1)
DbSeek(xFilial("SB1")+cCodAnt)

DbSelectArea("ZZ6")
DbSetOrder(1)
DbSeek(xFilial("ZZ6")+SB1->B1_YFORMAT)

DbSelectArea("ZZ8")
DbSetOrder(1)
IF DbSeek(xFilial("ZZ8")+SB1->B1_YCLASSE)
	cChavePesq := "OUTROS"+ALLTRIM(ZZ8->ZZ8_DESC)
ELSE
	MsgStop("Classe: "+SB1->B1_YCLASSE+"-"+SB1->B1_COD+", nao programada para este programa: INC021")
ENDIF
cChavePesq := ALLTRIM(ZZ6->ZZ6_DESC)+ALLTRIM(ZZ8->ZZ8_DESC)
nPosicao := RAT(ALLTRIM(ZZ6->ZZ6_DESC), Upper(cOldNome)) + 5

cOldNome := IF( nPosicao > 0,Subs(cOldNome, 1, nPosicao ), "OUTROS FORMATOS " )

cICores  := "TOTAL REFER.  " + Subs(cOldNome,1,30) + Space(30 - LEN(cOldNome))
cICores  += Tran( aCores[1], "@E 999.99"         ) + Space(02)
cICores  += Tran( aCores[2], "@E 99,999,999.99"  ) + Space(02)
cICores  += Tran( aCores[3], "@E 99,999,999.99"  ) + Space(02)
cICores  += Tran( aCores[4], "@E 999.99"         ) + Space(02)
cICores  += Tran( aCores[5], "@E 99,999,999.99"  ) + Space(02)
cICores  += Tran( aCores[6], "@E 99,999,999.99"  ) + Space(02)
cICores  += Tran( aCores[7], "@E 9,999,999.99"   )
nL++
@nL,000 PSay cICores
nL += IIF(cTipoRel <> "TOTALIZADO",1,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Resumo da Quebra de Linha.                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSelectArea("SB1")
SB1->(DBSetOrder(1))
SB1->(DBSeek(xFilial("SB1")+cOldLine))

cILinha  := "TOTAL LINHA   " + SubStr(cNomeLinha,1,28)       + Space(02)
cILinha  += Tran( aLinha[1], "@E 999.99"         ) + Space(02)
cILinha  += Tran( aLinha[2], "@E 99,999,999.99"  ) + Space(02)
cILinha  += Tran( aLinha[3], "@E 99,999,999.99"  ) + Space(02)
cILinha  += Tran( aLinha[4], "@E 999.99"         ) + Space(02)
cILinha  += Tran( aLinha[5], "@E 99,999,999.99"  ) + Space(02)
cILinha  += Tran( aLinha[6], "@E 99,999,999.99"  ) + Space(02)
cILinha  += Tran( aLinha[7], "@E 9,999,999.99"   )
nL++
@nL,000 PSay cILinha
nL++
@nL,000 PSay Replicate( "-", nTamanho )

cOldFormato := ""
nL++
@nL,000 PSay "R E S U M O"
TMP->(DBGoTop())
do while !TMP->(EOF())
	if nL >= 65
		nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
	endif
	if (cOldFormato <> Left(TMP->PRODUTO,7) )
		nL++
		nL++
		@nL,000 PSay "FORMATO " + Left(TMP->PRODUTO,7)
	endif
	cIDetalhe := "CLASSE " + Right(RTRIM(TMP->PRODUTO),1) + SPACE(36)
	cIDetalhe += Tran( TMP->PRUNIT   , "@E 999.99"         ) + Space(02)
	cIDetalhe += Tran( TMP->QTDEVEND , "@E 99,999,999.99"  ) + Space(02)
	cIDetalhe += Tran( TMP->VLRVEND  , "@E 99,999,999.99"  ) + Space(02)
	cIDetalhe += Tran( TMP->PRUNIFAT , "@E 999.99"         ) + Space(02)
	cIDetalhe += Tran( TMP->QTDEFAT  , "@E 99,999,999.99"  ) + Space(02)
	cIDetalhe += Tran( TMP->VLRFAT   , "@E 99,999,999.99"  ) + Space(02)
	cIDetalhe += Tran( TMP->DESCONTO , "@E 9,999,999.99"   )
	nL++
	@nL,000 PSay cIDetalhe
	cOldFormato := LEFT(TMP->PRODUTO,7)
	TMP->(DBSkip())
enddo

nL++
@nL,000 PSay Replicate( "-", nTamanho )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Resumo da Quebra de Classe A.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIClasse := 'TOTAL CLASSE  "A"'                       + Space(27)
cIClasse += Tran( aClasseA[1], "@E 999.99"         ) + Space(02)
cIClasse += Tran( aClasseA[2], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasseA[3], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasseA[4], "@E 999.99"         ) + Space(02)
cIClasse += Tran( aClasseA[5], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasseA[6], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasseA[7], "@E 9,999,999.99"   )
nL++
@nL,000 PSay cIClasse

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Resumo da Quebra de Classe C.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIClasse := 'TOTAL CLASSE  "C"' + Space(27)
cIClasse += Tran( aClasseC[1], "@E 999.99"         ) + Space(02)
cIClasse += Tran( aClasseC[2], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasseC[3], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasseC[4], "@E 999.99"         ) + Space(02)
cIClasse += Tran( aClasseC[5], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasseC[6], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasseC[7], "@E 9,999,999.99"   )
nL++
@nL,000 PSay cIClasse

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Resumo da Quebra de Classe D.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cIClasse := 'TOTAL CLASSE  "D"' + SPACE(27)
cIClasse += Tran( aClasseD[1], "@E 999.99"         ) + Space(02)
cIClasse += Tran( aClasseD[2], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasseD[3], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasseD[4], "@E 999.99"         ) + Space(02)
cIClasse += Tran( aClasseD[5], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasseD[6], "@E 99,999,999.99"  ) + Space(02)
cIClasse += Tran( aClasseD[7], "@E 9,999,999.99"   )
nL++
@nL,000 PSay cIClasse

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Resumo do Total Geral.                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cITGeral := "TOTAL GERAL     " + SPACE(28)
cITGeral += Tran( aTotGer[1], "@E 999.99"         ) + Space(02)
cITGeral += Tran( aTotGer[2], "@E 99,999,999.99"  ) + Space(02)
cITGeral += Tran( aTotGer[3], "@E 99,999,999.99"  ) + Space(02)
cITGeral += Tran( aTotGer[4], "@E 999.99"         ) + Space(02)
cITGeral += Tran( aTotGer[5], "@E 99,999,999.99"  ) + Space(02)
cITGeral += Tran( aTotGer[6], "@E 99,999,999.99"  ) + Space(02)
cITGeral += Tran( aTotGer[7], "@E 9,999,999.99"   )
nL++
@nL,000 PSay cITGeral

nL++
@nL,000 PSay Replicate( "-", nTamanho )

Roda(nCbCont, cCbtxt, cTamanho)
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fApagaTemp³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclui a tabela temporaria.							      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function fApagaTemp()
REL->(DbCloseArea("REL")); FErase(cArqTemp1+".*")
TMP->(DbCloseArea("TMP")); FErase(cArqTemp2+".*")
return
