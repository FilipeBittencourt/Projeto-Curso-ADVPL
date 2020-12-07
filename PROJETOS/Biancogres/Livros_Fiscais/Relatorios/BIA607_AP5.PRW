#include "rwmake.ch"
#include "relato.ch"
#include "topconn.ch"

User Function BIA607()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CDESC1,CDESC2,CDESC3,CALIAS,CNOMEPROG,CNOMEARQ,CPERGUNTA")
SetPrvt("CTITULO,CCABEC1,CCABEC2,CTAMANHO,CLINDEIMP,CARQTEMP1,CARQTEMP2")
SetPrvt("LGRAVPARAM,LTEMDIC,LPODECOMP")
SetPrvt("ARETURN,ACAMPOS,AORD")
SetPrvt("NCRCCONTROL,NL,NI,NTOTFIL,NTOTREGS1,NTOTREGS2,NCBCONT")
SetPrvt("CQUERY,CCHAVE,CCBTXT")
SetPrvt("CNOMETRANS,NSUBTOTVAC,NTOTGERVAC,NRANKING")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³ BIA607	  ³ Autor ³ CESAR MAGNAGO         ³ Data ³22/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio de Internamento da SUFRAMA                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		   ³ SIGAFIS													  												³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis.													              						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDesc1	   := "Este programa tem como objetivo emitir um relatorio de   "
cDesc2	   := "Internamento na SUFRAMA.                                 "
cDesc3	   := "                                                         "
cTamanho    := "G"
cAlias	   := "SF2"
cTitulo	   := "INTERNAMENTO DA SUFRAMA"
aReturn	   := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
cNomeProg   := "BIA607"
aOrd	      := { }
lGravParam  := .F.
lPodeComp   := .T.
lTemDic	   := .F.
lGravParam  := .F.
nTotRegs    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT.							         						 ³
//³ Verifica Posicao do Formulario na Impressora.							 							 ³
//³                                          								 								 ³
//³ Pega os valores passados como parametro: 								 								 ³	
//³ MV_PAR01 -> Do Cliente                   								 								 ³
//³ MV_PAR02 -> Ate Cliente                                                  ³
//³ MV_PAR03 -> Da Emissao                                                   ³
//³ MV_PAR04 -> Ate Emissao                                                  ³
//³ MV_PAR05 -> Opcao ? 1=Pendentes 2=Internadas 3=Ambas                     ³
//³ MV_PAR06 -> Ordenar por ? 1=Estado 2=Cliente 3=NF                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeArq := SetPrint(cAlias, cNomeProg, cNomeProg, @cTitulo, cDesc1, cDesc2, cDesc3, lTemDic, aOrd, lPodeComp, cTamanho)
if lastkey()==27 .OR. nLastkey == 27
	Return
endif

Pergunte(cNomeProg,lGravParam)
if lastkey()==27 .OR. nLastkey == 27
	Return
endif

SetDefault(aReturn,cAlias)
if lastkey()==27 .OR. nLastkey == 27
	Return
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis usadas no relatorio.                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nCbcont	   := 1
cCbtxt 	   := "USUARIO: "+cUserName
m_pag 	   := 1
nL          := 80
nCrcControl := iif(aReturn[4]==1,15,18)
cTitulo	   += " NO PERIODO DE "+dtoc(MV_PAR03)+" A "+dtoc(MV_PAR04)
cCabec1	   := "EST CLIENTE                                Nº SUFRAMA       NF               VALOR NF  VALOR ICMS  %ICMS   EMISSAO   LIMITE  PRZ LIM.  DT INTER  RESP.INTERNACAO  OBS.INTERNACAO"
cCabec2	   := "                                                                       "

Processa({|| fCriaTemp() })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera impressao.												                    						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if aReturn[5] == 1 .and. (nTotRegs) > 0
	set printer to
	OurSpool(cNomeArq)
endif
Ft_PFlush()
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 	 ³ fCriaTemp³ Autor ³ CESAR MAGNAGO                   	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria tabela temporaria.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static FUNCTION fCriaTemp()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reconfigura os indices das tabelas auxiliares.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SF2->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula quantidade de registros existentes no SF2010.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery  := ""
cQuery  += "SELECT COUNT(DISTINCT SF2.F2_DOC) AS TOTREGS "
cQuery  += "FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SA1")+" SA1 "
cQuery  += "WHERE "
cQuery  += "SF2.F2_FILIAL = '"+xFilial("SF2")+"'     AND "
cQuery  += "SA1.A1_FILIAL = '"+xFilial("SA1")+"'     AND "
//cQuery  += "(SF2.F2_VALICM/SF2.F2_VALMERC)*100 < 12  AND "
cQuery  += "SF2.F2_CLIENTE = SA1.A1_COD              AND "
cQuery  += "SF2.F2_LOJA    = SA1.A1_LOJA             AND "
cQuery  += "SA1.A1_SUFRAMA <> ''                     AND "
cQuery  += "SF2.F2_CLIENTE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
cQuery  += "SF2.F2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND "
cQuery  += "SF2.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' "
TCQuery cQuery Alias "X" New
nTotRegs := X->TOTREGS
X->(DbCloseArea())

If MV_PAR06 == 1
	wsOrdem := "ORDER BY SF2.F2_EST, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_DOC "
EndIf
If MV_PAR06 == 2
	wsOrdem := "ORDER BY SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_DOC"
EndIf
If MV_PAR06 == 3
	wsOrdem := "ORDER BY SF2.F2_DOC, SF2.F2_EST, SF2.F2_CLIENTE, SF2.F2_LOJA"
EndIf

if nTotRegs > 0
	cQuery  := ""
	cQuery  += " SELECT SF2.F2_EST, SF2.F2_CLIENTE, SF2.F2_LOJA, SA1.A1_NOME,SF2.F2_SERIE, SF2.F2_DOC, "
	cQuery  += "        SF2.F2_VALMERC, SF2.F2_VALICM, SA1.A1_SUFRAMA, 			"
	cQuery  += "				(SF2.F2_VALMERC/100)*SF2.F2_VALICM  AS F2_ALIQICM,	" // (SF2.F2_VALICM/SF2.F2_VALMERC)*100 AS F2_ALIQICM, "
	cQuery  += "        SF2.F2_EMISSAO, SF2.F2_YDTINT, SF2.F2_YRESINT, F2_YOBSINT, SD2.D2_TES "
	cQuery  += "FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SA1")+" SA1, "+RetSqlName("SD2")+" SD2 "
	cQuery  += "WHERE "
	cQuery  += "SF2.F2_EST IN ('AM','AP','AC','RO','RR') AND  "
	cQuery  += "SF2.F2_FILIAL = '"+xFilial("SF2")+"'     AND "
	cQuery  += "SA1.A1_FILIAL = '"+xFilial("SA1")+"'     AND "
	//	cQuery  += "(SF2.F2_VALICM/SF2.F2_VALMERC)*100 < 12  AND "
	//	cQuery  += "(SF2.F2_VALMERC/100)*SF2.F2_VALICM  < 12 AND "
	cQuery  += "SF2.F2_CLIENTE = SA1.A1_COD              AND "
	cQuery  += "SF2.F2_LOJA    = SA1.A1_LOJA             AND "

	cQuery  += "SF2.F2_DOC     = SD2.D2_DOC              AND "
	cQuery  += "SF2.F2_SERIE   = SD2.D2_SERIE            AND "
	cQuery  += "SF2.F2_CLIENTE = SD2.D2_CLIENTE          AND "
	cQuery  += "SF2.F2_LOJA    = SD2.D2_LOJA             AND "
	cQuery  += "SD2.D2_ITEM    = '01'                    AND "
	cQuery  += "SD2.D2_CF IN ('5101','6101','5118','6118','5107','6107','5109','6109','5401','6401','5922','6922','6110') AND "
	
	cQuery  += "SF2.F2_TIPO   = 'N'						 AND "
	cQuery  += "SA1.A1_SUFRAMA <> ''                     AND "
	cQuery  += "SF2.F2_CLIENTE BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	cQuery  += "SF2.F2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND "
	cQuery  += "SF2.D_E_L_E_T_ = '' AND SA1.D_E_L_E_T_ = '' AND SD2.D_E_L_E_T_ = '' "
	cQuery  += wsOrdem
	TCQuery cQuery Alias "QRY" New
	
	ProcRegua(nTotRegs)
	do while QRY->(!EOF())
		
		IncProc("Processando NF Suframa ...")
		
		If MV_PAR05 == 1 .And. !Empty(QRY->F2_YDTINT)
			QRY->(DBSkip())
			Loop
		EndIf
		
		If MV_PAR05 == 2 .And. Empty(QRY->F2_YDTINT)
			QRY->(DBSkip())
			Loop
		EndIf
		
		if SA1->(DBSeek(xFilial("SA1")+QRY->F2_CLIENTE+QRY->F2_LOJA))
			cNomeCli := Subs(SA1->A1_NOME,1,30)
		endif

		fImprime()
		QRY->(DBSkip())
	enddo
	QRY->(DBCloseArea())
	
else
	MsgStop("Nao Ha Notas Fiscais a Serem Processadas!")
endif
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³ fImprime  ³ Autor ³ CESAR MAGNAGO                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprime os dados da tabela temporaria. 			              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fImprime()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do relatorio.                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime parametros.                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if m_pag == 1
	U_ImpPar(cNomeProg,cTitulo,cTamanho,nCrcControl,nCbCont,cCbtxt,@nL)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do cabecalho.         												     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if nL >= 65
	nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 1
endif

cLinDeImp := ""
cLinDeImp += QRY->F2_EST                                             + SPACE(2)
cLinDeImp += QRY->F2_CLIENTE+" "+cNomeCli                            + SPACE(2)
cLinDeImp += QRY->A1_SUFRAMA                                         + SPACE(2) 
cLinDeImp += Subs(QRY->F2_SERIE,1,2)+" "+QRY->F2_DOC                + SPACE(2)
cLinDeImp += Trans(QRY->F2_VALMERC,"@E 999,999,999.99")              + SPACE(2)
cLinDeImp += Trans(QRY->F2_VALICM,"@E 999,999.99")                   + SPACE(2)
cLinDeImp += Trans((QRY->F2_VALICM/QRY->F2_VALMERC)*100,"@E 99.99")  + SPACE(2)
cLinDeImp += Trans(STOD(QRY->F2_EMISSAO),"@D")                       + SPACE(2)
wDtLimite := STOD(QRY->F2_EMISSAO)+120
cLinDeImp += Trans(wDtLimite,"@D")                                   + SPACE(2)
cLinDeImp += If(Empty(QRY->F2_YDTINT),Trans(wDtLimite-dDataBase,"@R 99999"),SPACE(5)) + SPACE(5)
cLinDeImp += Trans(STOD(QRY->F2_YDTINT),"@D")                        + SPACE(2)
cLinDeImp += QRY->F2_YRESINT
cLinDeImp += QRY->F2_YOBSINT 
@ nL,000 PSay cLinDeImp
nL++
return
