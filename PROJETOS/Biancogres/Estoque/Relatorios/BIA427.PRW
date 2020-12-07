#include "rwmake.ch"
#include "relato.ch"
#include "topconn.ch"

User Function Bia427()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("CQUERY,CWHERE")
SetPrvt("CDESC1,CDESC2,CDESC3,CALIAS,CNOMEPROG,CNOMEARQ,COLDALIAS")
SetPrvt("CTITULO,CCABEC1,CCABEC2,CTAMANHO,CDADOS,CARQTEMP,CTIPO")
SetPrvt("LGRAVPARAM,LTEMDIC,LPODECOMP,LABORTPRINT")
SetPrvt("ARETURN,ACAMPOS,ACONCENC,ADCONCENC")
SetPrvt("CANOPESQ,CMESPESQ")
SetPrvt("NCRCCONTROL,NL,NCONCENC,NMEDIA,NTOTREGS,NTIPOS,NTOTTIPO,NTOTPARC,NTOTGERAL")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ BIA427	³ Autor ³ Wanisay William       ³ Data ³19/05/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio de materiais obsoletos.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGACOM													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis.													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cDesc1			:= "Este programa tem como objetivo emitir um relatorio de materiais obsoletos que   "
cDesc2			:= "estao com o campo ATIVO no cadastro de produtos igual a NAO.                           "
cDesc3			:= ""
cTamanho	    := "M"
cAlias 			:= "SB1"
cTitulo			:= "Materiais obsoletos"
aReturn			:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
cNomeProg 		:= "BIA427"
nCbcont			:= 0
cCbtxt 			:= space(10)
m_pag 			:= 1
aOrd			:= { }
lGravParam 	    := .F.
lPodeComp       := .T.
lTemDic	        := .F.
lGravParam      := .F.
nL              := 80

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT.									 ³
//³ Verifica Posicao do Formulario na Impressora.							 ³
//³                                          								 ³
//³ Pega os valores passados como parametro: 								 ³
//³ MV_PAR01 -> Da Data           ?          								 ³
//³ MV_PAR02 -> Ate a Data        ?          								 ³
//³ MV_PAR03 -> Do Produto        ?          								 ³
//³ MV_PAR04 -> Ate o Produto     ?          								 ³
//³ MV_PAR05 -> Do Tipo           ?          								 ³
//³ MV_PAR06 -> Ate o Tipo        ?          								 ³
//³ MV_PAR07 -> Saldo             ? 1-Saldo Atual 2 - Fechamento			 ³
//³ MV_PAR08 -> Ordem             ? 1-Por Localizacao 2 - Por Valor  		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNomeArq := SetPrint(cAlias, cNomeProg, cNomeProg, @cTitulo, cDesc1, cDesc2, cDesc3, lTemDic, aOrd, lPodeComp, cTamanho)
if lastkey()==27 .OR. nLastKey==27
	Return
endif

Pergunte("BIA427",lGravParam)
SetDefault(aReturn, cAlias)

nCrcControl := iif(aReturn[4]==1,15,18)
cCabec1	   := "TIPO  CODIGO.  DESCRICAO...........................................ALM...LOCAL... ........ESTOQUE UND  .....CUSTO(R$)  .....TOTAL(R$)"
cCabec2	   := ""

Processa({|| fCriaTemp() })
Processa({|| fAcumula()  })
if nTotRegs > 0
	Processa({|| fImprime()  })
endif
Processa({|| fApagaTemp()})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera impressao.												                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if nTotRegs > 0
	if aReturn[5] == 1
		set printer to
		OurSpool(cNomeArq)
	endif
	
	Ft_PFlush()
endif
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
aCampos := {}
AADD(aCampos,{ "TIPO"      , "C", 02, 0 })
AADD(aCampos,{ "CODIGO"    , "C", 07, 0 })
AADD(aCampos,{ "DESCRICAO" , "C", 50, 0 })
AADD(aCampos,{ "ALMOXARIF" , "C", 02, 0 })
AADD(aCampos,{ "LOCALIZ"   , "C", 15, 0 })
AADD(aCampos,{ "ESTOQUE"   , "N", 10, 2 })
AADD(aCampos,{ "UNIDADE"   , "C", 03, 2 })
AADD(aCampos,{ "ULTIMOCUST", "N", 14, 2 })
AADD(aCampos,{ "TOTAL"     , "N", 14, 2 })
cArqTemp := CriaTrab(aCampos, .T.)
DbUseArea(.T.,, cArqTemp, "REL")
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fAcumula ³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Acumula os dados no arquivo temporario.                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static function fAcumula()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existencia de registros para serem relatados                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := ""
cWhere := ""
cQuery += "SELECT COUNT(DISTINCT SB1.B1_COD) AS TOTREGS "
cWhere += "FROM                                         "
cWhere += "     "+RetSqlName("SB1")+" SB1, "
cWhere += "     "+RetSqlName("SB2")+" SB2, " 
cWhere += "     "+RetSqlName("SBZ")+" SBZ,  "
cWhere += "     "+RetSqlName("ZCN")+" ZCN  "
cWhere += ""
cWhere += "WHERE SB1.B1_FILIAL   = '"+xFilial("SB1")+"'   AND  "
cWhere += "   (LEN(SB1.B1_COD) = 7                      ) AND  "
cWhere += "   (SUBSTRING(SB1.B1_COD,4,4) NOT IN ('0000')) AND  "
cWhere += "   (SB1.B1_COD  BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"') AND  "
cWhere += "   (SB1.B1_TIPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"') AND  "
cWhere += "   (SB1.B1_GRUPO NOT IN ('PA')               ) AND  "
//Retirado por Wanisay em 28/03/16 conforme OS 1036-16
//cWhere += "   (SB1.B1_ATIVO = 'N'                       ) AND  "
cWhere += "   (SB1.D_E_L_E_T_ = ''                      ) AND  "
cWhere += "   (SB2.D_E_L_E_T_ = ''                      ) AND  "
cWhere += "   (SB2.B2_FILIAL  = '"+xFilial("SB2")+"'    ) AND "
cWhere += "   (SB2.B2_COD     = SB1.B1_COD) AND "
cWhere += "   (ZCN.ZCN_COD     = SB1.B1_COD) AND "
cWhere += "   (ZCN.ZCN_LOCAL     = SB2.B2_LOCAL) AND "
cWhere += "   (ZCN.ZCN_LOCAL     BETWEEN "+ValtoSql(MV_PAR10) + " AND "+ ValtoSql(MV_PAR11) +") AND "
IF MV_PAR07 == 1
	cWhere += "   (SB2.B2_QATU    >= 0         ) AND "
ELSE
	cWhere += "   (SB2.B2_QFIM    >= 0         ) AND "
ENDIF
cWhere += ""
cWhere += "   (SBZ.BZ_FILIAL  = '"+xFilial("SBZ")+"'      ) AND "
cWhere += "   (SBZ.BZ_COD     = SB1.B1_COD) AND "     
//Inserido por Wanisay em 28/03/16 conforme OS 1363-16        
cWhere += "   (SBZ.BZ_YATIVO = 'N'        ) AND  "
cWhere += "   (SBZ.D_E_L_E_T_ = ''        ) AND "
IF MV_PAR09 == 1
	cWhere += "   (ZCN.ZCN_MD   = 'S'       ) AND "
ELSE
	cWhere += "   (ZCN.ZCN_MD   = 'N'       ) AND "
ENDIF
cWhere += "   (SB2.D_E_L_E_T_ = ''        ) "
cQuery := cQuery + cWhere
TCQuery cQuery Alias "X" New
nTotRegs := X->TOTREGS
X->(DbCloseArea())

if nTotRegs > 0
	cQuery  := "SELECT "
	cQuery  += "       SB1.B1_TIPO                 AS TIPO,      "
	cQuery  += "       SUBSTRING(SB1.B1_COD,1,7)   AS CODIGO,    "
	cQuery  += "       SUBSTRING(SB1.B1_DESC,1,50) AS DESCRICAO, "
	cQuery  += "       ZCN.ZCN_LOCALI   AS LOCALIZ,    "
	cQuery  += "       ZCN.ZCN_LOCAL  AS ALMOXARIF,    "
	IF MV_PAR07 == 1
		cQuery  += "       SB2.B2_QATU                 AS ESTOQUE,   "
		cQuery  += "       SB1.B1_UM                   AS UNIDADE,   "
		cQuery  += "       SB2.B2_CM1                  AS CUSTO      "
	ELSE
		cQuery  += "       SB2.B2_QFIM                          AS ESTOQUE,   "
		cQuery  += "       SB1.B1_UM                            AS UNIDADE,   "
		cQuery  += "       SB2.B2_VFIM1                         AS CUSTO      "
	ENDIF
	cWhere  += "ORDER BY SB1.B1_YLOCALI, SB1.B1_TIPO, SB1.B1_COD "
	cQuery  := cQuery + cWhere
	TCQuery cQuery Alias "QRY" New
	
	ProcRegua(nTotRegs)
	do while QRY->(!EOF())
		
		IncProc("Coletando dados...")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava na tabela temporaria os dados obtidos.                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("REL", .T.)
		REL->TIPO       := QRY->TIPO
		REL->CODIGO     := QRY->CODIGO
		REL->DESCRICAO  := QRY->DESCRICAO
		REL->ALMOXARIF  := QRY->ALMOXARIF
		REL->LOCALIZ    := QRY->LOCALIZ
		REL->ESTOQUE    := QRY->ESTOQUE
		REL->UNIDADE    := QRY->UNIDADE
		IF MV_PAR07 == 1
			REL->ULTIMOCUST := QRY->CUSTO
	        REL->TOTAL      := QRY->CUSTO * QRY->ESTOQUE							
		ELSE
			IF QRY->ESTOQUE <> 0
				REL->ULTIMOCUST := QRY->CUSTO/QRY->ESTOQUE
			ELSE
				REL->ULTIMOCUST := 0
			ENDIF
	        REL->TOTAL      := QRY->CUSTO			
		ENDIF
		REL->(DbUnlock())
		
		QRY->(DbSkip())
	enddo
	QRY->(DbCloseArea())
else
	alert("Nao ha dados que satisfacam os parametros para serem listados.")
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
//³ Determina a posicao no Ranking.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
REL->(DBCloseArea())
DbUseArea(.T.,,cArqTemp,"REL")

IF MV_PAR08 == 1
	REL->(DbCreateInd(cArqTemp+".001","LOCALIZ+TIPO+descend(str(TOTAL))", {||LOCALIZ+TIPO+descend(str(ESTOQUE))}))
ELSE
	REL->(DbCreateInd(cArqTemp+".001","descend(str(TOTAL))", {||descend(str(ESTOQUE))}))
ENDIF

ProcRegua(REL->(LastRec()))
REL->(DbGoTop())
cTipo     := REL->TIPO
nTipos    := 0
nTotTipo  := 0
nTotParc  := 0
nTotGeral := 0
do while REL->(!EOF())
	
	Incproc("Imprimindo...")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento da impressao pelo usuario.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Interrupcao(@lAbortPrint)
		Return
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime parametros.                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if m_pag == 1
		U_ImpPar(cNomeProg,cTitulo,cTamanho,nCrcControl,nCbCont,cCbtxt,@nL)
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho.												     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nL >= 65
		nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime a linha de dados do relatorio.									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDados := ""
	cDados += REL->TIPO                      + space(04)
	cDados += REL->CODIGO                + space(02)
	cDados += REL->DESCRICAO          + space(02)
	cDados += REL->ALMOXARIF          + space(04)
	cDados += REL->LOCALIZ               + space(01)
	//cDados += u_rtoc(REL->ESTOQUE) + space(02)
	cDados += STR(REL->ESTOQUE,8,2) + space(01)
	cDados += REL->UNIDADE                + space(02)
	cDados += STR(REL->ULTIMOCUST,14,2) + space(02)
	cDados += STR(REL->TOTAL,14,2)
	@ nL, 000 PSay cDados
	nTotParc  += REL->TOTAL
	nTotGeral += REL->TOTAL
	nTotTipo++
	nL++
	
	REL->(DbSkip())
enddo

nL += 2
cDados := "Total de materiais listados: "
cDados += u_rtoc(nTotRegs,"@E 999,999") + IIF(nTotRegs > 1," materiais"+space(71)," material"+space(72)) + STR(nTotGeral,14,2)
@ nL, 000 PSay cDados

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime rodape.													 	                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Roda(nCbCont, cCbtxt, cTamanho)
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
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fApagaTemp
Static function fApagaTemp()
REL->(DbCloseArea("REL")); FErase(cArqTemp+".*")
return
