#include "rwmake.ch"
#include "relato.ch"
#include "topconn.ch"

User Function Bia070()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("LEND,LABORTPRINT,TAMANHO,LIMITE,TITULO,CDESC1")
SetPrvt("CDESC2,CDESC3,ARETURN,ALINHA,NOMEPROG,NLASTKEY")
SetPrvt("CPERG,LI,CBTXT,CBCONT,CABEC1,CABEC2")
SetPrvt("CSTRING,M_PAG,WNREL,_ACAMPOS,TMP,XNUMERO")
SetPrvt("XPRODUTO,XITEM,XNF,XQTDVEN,XSERIE,XEMISSAO")
SetPrvt("XVALORNF,XNUMSEQ,XCLIENTE,XLOJA,WPESOLIQC,WPESOBR")
SetPrvt("CTRACOS,XNUM,CCHAVE,XCLIENT,XTRANSP,XVEND1")
SetPrvt("XCONDPAG,XENDCOB,XTELCOB,XCGCCOB,XCIDCOB,XESTCOB")
SetPrvt("XFAX,XNOME,XEND,XCEP,XMUN,XEST")
SetPrvt("XCGC,XINSCR,XFAXCLI,XTELCLI,XCONTATO,XDIA")
SetPrvt("XMES,XANO,XTOTQTD,YITEM,XTOTNF,XTOTPB")
SetPrvt("XDESCRI,")

SetPrvt("CARQTEMP,")
SetPrvt("NL,NTOTREGS")

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇙o	 � BIA070	  � Autor � 	MAGNAGO			  � Data � 20/10/99 낢�
굇�      	 �       	  � Alte. � WLADIMIR ILLIUSHENKO  �      � 12/03/02 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � RELATORIO DE FAX DE EMBARQUE					                낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso		 � FATURAMENTO                                                  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Declaracao de variaveis									                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cNomeProg   := "BIA070"
cNomeArq    := cNomeProg
cTitulo	   := "Fax de Embarque"
cDesc1	   := "Emite o Fax de Embarque para Clientes e Transportadoras"
cDesc2	   := "                                                           "
cDesc3	   := "                                                           "
aReturn	   := {"Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
aLinha	   := {}
aOrdem	   := {}
lPodeComp   := .T.
lTemDic	   := .F.
lGravParam  := .F.
cAlias	   := "SD2"
cTamanho    := "M"
aProdutos   := {}
nLastKey    := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT.								           �
//� Verifica Posicao do Formulario na Impressora.				                 �
//� Solicita os parametros para a emissao do relatorio			              �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cNomeArq := SetPrint(cAlias,cNomeProg,cNomeProg,@cTitulo,cDesc1,cDesc2,cDesc3,lTemDic,aOrdem,lPodeComp,cTamanho)
if LastKey()==27 .OR. nLastKey==27
	Return
endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Aceita par긩etros e faz ajustes necess쟲ios.                           �
//쳐컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴캑
//� mv_par01 � Cliente Inicial															�
//� mv_par02 � Cliente Final																�
//� mv_par03 � Emissao Inicial															�
//� mv_par04 � Emissao Final																�
//읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Pergunte(cNomeProg,lGravParam)
if LastKey()==27 .OR. nLastKey==27
	Return
endif

SetDefault(aReturn,cAlias)
if LastKey()==27 .OR. nLastKey==27
	Return
endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Variaveis utilizadas para impressao.                                     �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
nCrcControl    := iif(aReturn[4]==1,15,18)
cCbTxt	      := SPACE(10)
nCbCont	      := 0
nL 		      := 0
nTotalNF       := 0
m_pag 	      := 1
cCabec1	      := ""
cCabec2	      := ""

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Rotinas.                                                                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Processa({|| fCriaTemp() })
Processa({|| fAcumula()  })
if nTotRegs > 0
	Processa({|| fImprime()  })
endif
Processa({|| fApagaTemp()})

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Se a impress꼘 for em Disco, chama SPOOL                               �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
if aReturn[5]==1
	Set Printer to
	Commit
	OurSpool(cNomeArq)
endif

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Libera relatorio para Spool da Rede                                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
Ft_PFlush()
Return

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fCriaTemp� Autor � WLADIMIR ILLIUSHENKO                    낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Cria uma tabela temporaria para preparacao do relatorio.   낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function fCriaTemp()

//**
//***** TEMPORARIO 01
//**
aCampos := {}
AADD(aCampos, {"DOC"     , "C", 06, 0})
AADD(aCampos, {"SERIE"   , "C", 03, 0})
AADD(aCampos, {"PEDIDO"  , "C", 06, 0})
AADD(aCampos, {"VALORNF" , "N", 12, 2})
AADD(aCampos, {"EMISSAO" , "D", 08, 0})
AADD(aCampos, {"TABELA"  , "C", 01, 0})
AADD(aCampos, {"VOLUME"  , "N", 12, 2})
AADD(aCampos, {"ESPECIE" , "C", 10, 0})
AADD(aCampos, {"ITEMPV"  , "C", 02, 0})
AADD(aCampos, {"PRODUTO" , "C", 15, 0})
AADD(aCampos, {"PRODDESC", "C", 28, 0})
AADD(aCampos, {"QTDVEN"  , "N", 12, 2})
AADD(aCampos, {"PBRUTO"  , "N", 12, 2})
AADD(aCampos, {"VEND"    , "C", 06, 0})
AADD(aCampos, {"VENDDESC", "C", 30, 0})
AADD(aCampos, {"CONDPAG" , "C", 03, 0})
AADD(aCampos, {"CONDDESC", "C", 30, 0})
AADD(aCampos, {"REAJUSTE", "C", 03, 0})
AADD(aCampos, {"FRETE"   , "N", 12, 2})
AADD(aCampos, {"DESPACHO", "C", 06, 0})
AADD(aCampos, {"TRANSP"  , "C", 06, 0})
AADD(aCampos, {"TRANDESC", "C", 30, 0})
AADD(aCampos, {"CLIENTE" , "C", 06, 0})
AADD(aCampos, {"CLILOJA" , "C", 02, 0})
AADD(aCampos, {"CLIDESC" , "C", 30, 0})
AADD(aCampos, {"CLIEND"  , "C", 30, 0})
AADD(aCampos, {"CLICEP"  , "C", 15, 0})
AADD(aCampos, {"CLIMUN"  , "C", 20, 0})
AADD(aCampos, {"CLIEST"  , "C", 02, 0})
AADD(aCampos, {"CLICGC"  , "C", 15, 0})
AADD(aCampos, {"CLIIE"   , "C", 15, 0})
AADD(aCampos, {"CLIFAX"  , "C", 15, 0})
AADD(aCampos, {"CLITEL"  , "C", 15, 0})
AADD(aCampos, {"CLICONT" , "C", 20, 0})
cArqTemp := CriaTrab(aCampos, .T.)
DbUseArea(.T.,,cArqTemp,"REL")
DbCreateInd(cArqTemp+".001","DOC+SERIE+PEDIDO+PRODUTO+ITEMPV",{||DOC+SERIE+PEDIDO+PRODUTO+ITEMPV})
OrdListClear()
OrdListAdd(cArqTemp+".001")
Return



/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fAcumula � Autor � WLADIMIR ILLIUSHENKO					  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Acumula os dados no arquivo temporario para que ...        낢�
굇�          � posteriormente possam ser impressos.                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function fAcumula()
cQuery  := ""
cWhere  := ""
cQuery  += "SELECT COUNT(SD2.D2_COD) AS TOTREGS "
cWhere  += "FROM "
cWhere  += RetSQLName("SD2")+" SD2, "
cWhere  += RetSQLName("SB1")+" SB1, "
cWhere  += RetSQLName("SC5")+" SC5, "
cWhere  += RetSQLName("SA1")+" SA1, "
cWhere  += RetSQLName("SA3")+" SA3, "
cWhere  += RetSQLName("SA4")+" SA4, "
cWhere  += RetSQLName("SE4")+" SE4 "
cWhere  += "WHERE "
cWhere  += "SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND "
cWhere  += "SD2.D2_EMISSAO BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND "
cWhere  += "SD2.D2_CLIENTE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
cWhere  += "SD2.D2_DOC+SD2.D2_SERIE IN ( "
cWhere  +=                             "SELECT SF2.F2_DOC+SF2.F2_SERIE "
cWhere  +=                             "FROM "+RetSQLName("SF2")+" SF2 "
cWhere  +=                             "WHERE "
cWhere  +=                             "SF2.F2_DOC = SD2.D2_DOC AND "
cWhere  +=                             "SF2.F2_SERIE = SD2.D2_SERIE AND "
cWhere  +=                             "SF2.F2_YDES = '' AND "             && Somente NF que ainda nao foram embarcadas.
cWhere  +=                             "SF2.F2_YSUBTP NOT IN ('A ') AND "   && Nao considera NF de Amostra.
cWhere  +=                             "SF2.D_E_L_E_T_ = '') AND "
cWhere  += "SD2.D_E_L_E_T_ = '' AND "
cWhere  += "SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
cWhere  += "SB1.B1_COD = SD2.D2_COD AND "
cWhere  += "SB1.D_E_L_E_T_ = '' AND "
cWhere  += "SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND "
cWhere  += "SC5.C5_NUM = SD2.D2_PEDIDO AND "
cWhere  += "SC5.D_E_L_E_T_ = '' AND "
cWhere  += "SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND "
cWhere  += "SA1.A1_COD = SD2.D2_CLIENTE AND "
cWhere  += "SA1.A1_LOJA = SD2.D2_LOJA AND "
cWhere  += "SA1.D_E_L_E_T_ = '' AND "
cWhere  += "SA3.A3_FILIAL = '"+xFilial("SA3")+"' AND "
cWhere  += "SA3.A3_COD = SC5.C5_VEND1 AND "
cWhere  += "SA3.D_E_L_E_T_ = '' AND "
cWhere  += "SA4.A4_FILIAL = '"+xFilial("SA4")+"' AND "
cWhere  += "SA4.A4_COD = SC5.C5_TRANSP AND "
cWhere  += "SA4.D_E_L_E_T_ = '' AND "
cWhere  += "SE4.E4_FILIAL = '"+xFilial("SE4")+"' AND "
cWhere  += "SE4.E4_CODIGO = SC5.C5_CONDPAG AND "
cWhere  += "SE4.D_E_L_E_T_ = '' "
cQuery  += cWhere
TCQuery cQuery Alias "X" New
nTotRegs := X->TOTREGS
X->(DbCloseArea())

if nTotRegs > 0
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Monta a linha da regua 																�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	ProcRegua(nTotRegs)
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Inicia a leitura do SD2 para posterior impressao. 							�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	nTotRegs := 0
	cQuery   := ""
	cQuery   += "SELECT "
	cQuery   += "SD2.D2_PEDIDO, "
	cQuery   += "SD2.D2_COD, "
	cQuery   += "SD2.D2_ITEMPV, "
	cQuery   += "SD2.D2_DOC, "
	cQuery   += "SD2.D2_QUANT, "
	cQuery   += "SD2.D2_SERIE, "
	cQuery   += "SD2.D2_EMISSAO, "
	cQuery   += "SD2.D2_TOTAL, "
	cQuery   += "SD2.D2_NUMSEQ, "
	cQuery   += "SD2.D2_CLIENTE, "
	cQuery   += "SD2.D2_LOJA, "
	cQuery   += "(SD2.D2_QUANT * SB1.B1_PESO) AS PESOL, "
	cQuery   += "SB1.B1_DESC, "
	cQuery   += "SB1.B1_TIPCONV, "
	cQuery   += "SB1.B1_CONV, "
	cQuery   += "SB1.B1_YPESEMB, "
	cQuery   += "SC5.C5_CLIENTE, "
	cQuery   += "SC5.C5_TRANSP, "
	cQuery   += "SC5.C5_VEND1, "
	cQuery   += "SC5.C5_CONDPAG, "
	cQuery   += "SC5.C5_REAJUST, "
	cQuery   += "SC5.C5_FRETE, "
	cQuery   += "SC5.C5_REDESP, "
	cQuery   += "SC5.C5_TABELA, "
	cQuery   += "SC5.C5_VOLUME1, "
	cQuery   += "SC5.C5_ESPECI1, "
	cQuery   += "SA1.A1_END, "
	cQuery   += "SA1.A1_NOME, "
	cQuery   += "SA1.A1_CEP, "
	cQuery   += "SA1.A1_MUN, "
	cQuery   += "SA1.A1_EST, "
	cQuery   += "SA1.A1_CGC, "
	cQuery   += "SA1.A1_INSCR, "
	cQuery   += "SA1.A1_FAX, "
	cQuery   += "SA1.A1_TEL, "
	cQuery   += "SA1.A1_CONTATO, "
	cQuery   += "SA3.A3_NOME, "
	cQuery   += "SA4.A4_NOME, "
	cQuery   += "SE4.E4_DESCRI "
	cQuery   += cWhere
	cQuery   += "ORDER BY "
	cQuery   += "SD2.D2_DOC, "
	cQuery   += "SD2.D2_SERIE, "
	cQuery   += "SD2.D2_PEDIDO, "
	cQuery   += "SD2.D2_COD, "
	cQuery   += "SD2.D2_ITEMPV "
	TCQuery cQuery Alias "QRY" New
	
	do while !QRY->(EOF())
		
		IncProc("Localizando NFs...")
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Inicializa o totalizador de Peso Bruto do produto atual e captura ...    �
		//� os dados da NF, Cliente, Transportadora, Vendedor e Cond. Pagamento.     �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		
		cDoc		:= QRY->D2_DOC
		cSerie	:= QRY->D2_SERIE
		cPedido  := QRY->D2_PEDIDO
		dEmissao := u_stod(QRY->D2_EMISSAO)
		cTabela  := QRY->C5_TABELA
		nVolume  := QRY->C5_VOLUME1
		cEspecie := QRY->C5_ESPECI1
		cItemPV  := QRY->D2_ITEMPV
		cProduto := QRY->D2_COD
		cProdDesc:= QRY->B1_DESC
		nPesoB   := 0
		nQtdVen  := QRY->D2_QUANT
		nValorNF := QRY->D2_TOTAL
		cVend    := QRY->C5_VEND1
		cVendDesc:= QRY->A3_NOME
		cCondPag := QRY->C5_CONDPAG
		cCondDesc:= QRY->E4_DESCRI
		cReajuste:= QRY->C5_REAJUST
		nFrete   := QRY->C5_FRETE
		cDespacho:= QRY->C5_REDESP
		cTransp  := QRY->C5_TRANSP
		cTranDesc:= QRY->A4_NOME
		cCliente := QRY->C5_CLIENTE
		cCliLoja := QRY->D2_LOJA
		cCliDesc := QRY->A1_NOME
		cCliEnd  := QRY->A1_END
		cCliCep  := QRY->A1_CEP
		cCliMun  := QRY->A1_MUN
		cCliEst  := QRY->A1_EST
		cCliCGC  := QRY->A1_CGC
		cCliIE   := QRY->A1_INSCR
		cCliFax  := QRY->A1_FAX
		cCliTel  := QRY->A1_TEL
		cCliCont := QRY->A1_CONTATO
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Totaliza o Peso Bruto da NF e produto atuais.                            �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		do while QRY->D2_DOC+QRY->D2_SERIE+QRY->D2_COD == cDoc+cSerie+cProduto
			do case
				case QRY->B1_TIPCONV == "M"; nPesoB += (QRY->D2_QUANT * QRY->B1_CONV * QRY->B1_YPESEMB) + QRY->PESOL
				case QRY->B1_TIPCONV == "D"; nPesoB += (QRY->D2_QUANT / QRY->B1_CONV * QRY->B1_YPESEMB) + QRY->PESOL
			endcase
			QRY->(dbSkip())
		enddo
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Grava os dados capturados e o total do Peso Bruto do produto atual no ...�
		//� arquivo temporario a ser usado no relatorio.                             �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		RecLock("REL",.T.)
		REL->DOC      := cDoc
		REL->SERIE    := cSerie
		REL->PEDIDO   := cPedido
		REL->EMISSAO  := dEmissao
		REL->TABELA   := cTabela
		REL->VOLUME   := nVolume
		REL->ESPECIE  := cEspecie
		REL->ITEMPV   := cItemPV
		REL->PRODUTO  := cProduto
		REL->PRODDESC := cProdDesc
		REL->QTDVEN   := nQtdVen
		REL->VALORNF  := nValorNF
		REL->PBRUTO   := nPesoB
		REL->VEND     := cVend
		REL->VENDDESC := cVendDesc
		REL->CONDPAG  := cCondPag
		REL->CONDDESC := cCondDesc
		REL->REAJUSTE := cReajuste
		REL->FRETE    := nFrete
		REL->DESPACHO := cDespacho
		REL->TRANSP   := cTransp
		REL->TRANDESC := cTranDesc
		REL->CLIENTE  := cCliente
		REL->CLILOJA  := cCliLoja
		REL->CLIDESC  := cCliDesc
		REL->CLIEND   := cCliEnd
		REL->CLICEP   := cCliCep
		REL->CLIMUN   := cCliMun
		REL->CLIEST   := cCliEst
		REL->CLICGC   := cCliCGC
		REL->CLIIE    := cCliIE
		REL->CLIFAX   := cCliFax
		REL->CLITEL   := cCliTel
		REL->CLICONT  := cCliCont
		nTotRegs++
		REL->(MsUnLock())
		 
		//Excluida da linha abaixo por C�sar em 09/04/02 por n�o imprimir o �ltimo registro de cada cliente.
		//QRY->(DbSkip())
	enddo
	QRY->(DbCloseArea())
endif
return



/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fImprime � Autor � WLADIMIR ILLIUSHENKO					  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Imprime os dados Acumulados.                               낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function fImprime()
ProcRegua(nTotRegs)

REL->(DBGoTop())
do while !REL->(EOF())
	
	IncProc("Imprimindo...")
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Impressao do cabecalho									  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	cPedido   := REL->PEDIDO
	cCliente  := REL->CLIENTE
	cCliLoja  := REL->CLILOJA
	cTransp   := REL->TRANSP
	cTranDesc := REL->TRANDESC
	cVend     := REL->VEND
	cVendDesc := REL->VENDDESC
	cCondPag  := REL->CONDPAG
	cCondDesc := REL->CONDDESC
	nFrete    := REL->FRETE
	cDespacho := REL->DESPACHO
	cTabela   := REL->TABELA
	nVolume   := REL->VOLUME
	cEspecie  := REL->ESPECIE
	cReajuste := REL->REAJUSTE
	cCliTel   := REL->CLITEL
	cCliFax   := REL->CLIFAX
	cCliCont  := REL->CLICONT
	
	nL++ ; @ nL,000 PSay "OBS: "
	nL++ ; @ nL,000 PSay space(05)+"INFORMAMOS QUE A(S) MERCADORIA(S) ABAIXO JA ESTA(AO) FATURADA(S)."
	nL++ ; @ nL,000 PSay space(05)+"SOLICITAMOS ENTRAR EM CONTATO CONOSCO PARA PROGRAMARMOS A SUA RETIRADA."
	nL++ ; @ nL,000 PSay space(05)+"CONTATO: SR. LUIZ      XXX (27) 348-9012"
	nL++ ; @ nL,000 PSay space(14)+"SRTA FERNANDA XXX (27) 348-9029"
	
	nL+=3; @ nL,000 PSay replicate("-",128)
	nL++ ; @ nL,000 PSay padr(SM0->M0_NOME                                              ,40)+" | "+padr(REL->CLIENTE+"/"+REL->CLILOJA+" "+REL->CLIDESC,55)+" | "+"FAX DE EMBARQUE"
	nL++ ; @ nL,000 PSay padr(SM0->M0_ENDCOB                                            ,40)+" | "+padr(REL->CLIEND                                    ,55)+" | "
	nL++ ; @ nL,000 PSay padr("Tel: "+SM0->M0_TEL+space(5)+"Fax: "+SM0->M0_FAX         ,40)+" | "+padr(REL->CLICEP+" "+REL->CLIMUN+" "+REL->CLIEST   ,55)+" | "+"DATA...: "+dtoc(REL->EMISSAO)
	nL++ ; @ nL,000 PSay padr("CGC: "+SM0->M0_CGC+" "+SM0->M0_CIDCOB+" "+SM0->M0_ESTCOB,40)+" | "+padr(REL->CLICGC+space(5)+"IE: "+REL->CLIIE        ,55)+" | "
	nL++ ; @ nL,000 PSay replicate("-",128)
	
	nL+=2; @ nL,000 PSay replicate("-",128)
	nL++ ; @ nL,000 PSay "IT CODIGO           DESCRICAO                     PEDIDO           QTD M2        P.BRUTO  N.FIS.  SER. EMISSAO            TOT.NF"
	                       
	nL++ ; @ nL,000 PSay replicate("-",128)
	
	nTotalMt := 0
	nItens   := 0	
	nTotalPB := 0
	do while REL->CLIENTE+REL->CLILOJA == cCliente+cCliLoja .AND. !REL->(EOF()) .AND. nItens <= 20
		
		cDoc   := REL->DOC
		cSerie := REL->SERIE
		do while REL->DOC+REL->SERIE == cDoc+cSerie .AND. !REL->(EOF()) .AND. nItens <= 20
			cTexto := ""
			cTexto += padr(REL->ITEMPV        ,03)
			cTexto += padr(REL->PRODUTO       ,17)
			cTexto += padr(REL->PRODDESC      ,30)
			cTexto += padr(REL->PEDIDO        ,08)
			cTexto += padl(u_rtoc(REL->QTDVEN),15)
			cTexto += padl(u_rtoc(REL->PBRUTO),15)+space(2)
			cTexto += padr(REL->DOC           ,08)
			cTexto += padr(REL->SERIE         ,05)
			cTexto += padr(dtoc(REL->EMISSAO) ,10)
			nL++ ; @ nL,000 PSay cTexto 
			
			nTotalMt += REL->QTDVEN
			nTotalNF += REL->VALORNF
			nTotalPB += REL->PBRUTO
			nItens++
			
			REL->(DBSkip())
		enddo
		
		if (REL->DOC+REL->SERIE <> cDoc+cSerie) .OR. REL->(EOF())
		   nL++ ; @ nL,000 PSay padl(u_rtoc(nTotalNF),128)		
		   nTotalNF := 0
		endif   
	enddo
	
	nL++ ; @ nL,000 PSay replicate("-",128)
	nL++ ; @ nL,000 PSay padr("T O T A L",58)+padl(u_rtoc(nTotalMt),15)+padl(u_rtoc(nTotalPB),15)
	
	nL+=3; @ nL,000 PSay "TRANSP...: "+cTransp+" - "+cTranDesc
	nL++ ; @ nL,000 PSay "VENDEDOR.: "+cVend  +" - "+cVendDesc
	
	nL+=2; @ nL,000 PSay padr("COND.PGTO: "+cCondPag+" - "+cCondDesc,64)+"FRETE...: "+padl(u_rtoc(nFrete),13)+space(5) +"REDESPACHO: "+cDespacho
	nL++ ; @ nL,000 PSay padr("TABELA...: "+cTabela                 ,64)+"VOLUMES.: "+padl(u_rtoc(nVolume),13)+space(5)+"ESPECIE...: "+cEspecie
	nL++ ; @ nL,000 PSay padr("REAJUSTE.: "+cReajuste               ,64)+"TEL CLI.: "+padr(cCliTel,18)                  +"FAX CLI...: "+cCliFax
	nL++ ; @ nL,000 PSay padr("CONTATO..: "+cCliCont                ,64)
	nL++ ; @ nL,000 PSay replicate("-",128)
	
	nL+=3; @ nL,000 PSay "PREZADOS SENHORES:"
	nL+=2; @ nL,000 PSay space(5)+"COM A INTENCAO DE OTIMIZAR NOSSA EXPEDICAO, SOLICITAMOS OS SEGUINTES PROCEDIMENTOS:"
	nL+=2; @ nL,000 PSay space(5)+"1-PROGRAMAR ANTECIPADAMENTE SUA CARGA VIA FAX OU TEL, INFORMANDO NOME MOTORISTA, PLACA DO VEICULO (PREFERENCIA MANHA)"
	nL++ ; @ nL,000 PSay space(5)+"2-INFORMAR AO MOTORISTA SOBRE QUAL DESTINO E O PESO QUE IRA TRANSPORTAR"
	nL++ ; @ nL,000 PSay space(5)+"3-A PARTIR DESTA DATA, TODOS OS VEICULOS QUE NAO ESTIVEREM PROGRAMADOS E CHEGAREM APOS AS 15:30H,"
	nL++ ; @ nL,000 PSay space(5)+"  ESTARAO SUJEITOS A FICAREM PARA CARREGAR NO DIA SEGUINTE."
	nL+=2; @ nL,000 PSay space(5)+"CONTAMOS COM A COLABORACAO DE TODOS PARA QUE SE CUMPRA O CITADO ACIMA"
	nL+=2; @ nL,000 PSay replicate("-",128)
	nL:=0
	
	//	if !REL->(EOF())
	//	   eject
	//	endif
enddo
return

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 쿯ApagaTemp� Autor � WLADIMIR ILLIUSHENKO					  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Exclui a(s) tabela(s) temporaria(s).                       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static function fApagaTemp()
REL->(DbCloseArea("REL")); aeval(directory(cArqTemp+".*"),{ |aFile| FErase(aFile[1])})
return