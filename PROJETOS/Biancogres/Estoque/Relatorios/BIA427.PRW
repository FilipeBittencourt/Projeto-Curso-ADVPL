#include "rwmake.ch"
#include "relato.ch"
#include "topconn.ch"

User Function Bia427()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CQUERY,CWHERE")
SetPrvt("CDESC1,CDESC2,CDESC3,CALIAS,CNOMEPROG,CNOMEARQ,COLDALIAS")
SetPrvt("CTITULO,CCABEC1,CCABEC2,CTAMANHO,CDADOS,CARQTEMP,CTIPO")
SetPrvt("LGRAVPARAM,LTEMDIC,LPODECOMP,LABORTPRINT")
SetPrvt("ARETURN,ACAMPOS,ACONCENC,ADCONCENC")
SetPrvt("CANOPESQ,CMESPESQ")
SetPrvt("NCRCCONTROL,NL,NCONCENC,NMEDIA,NTOTREGS,NTIPOS,NTOTTIPO,NTOTPARC,NTOTGERAL")

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao	 � BIA427	� Autor � Wanisay William       � Data �19/05/2008낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Relatorio de materiais obsoletos.                          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so		 � SIGACOM													  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa variaveis.													 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT.									 �
//� Verifica Posicao do Formulario na Impressora.							 �
//�                                          								 �
//� Pega os valores passados como parametro: 								 �
//� MV_PAR01 -> Da Data           ?          								 �
//� MV_PAR02 -> Ate a Data        ?          								 �
//� MV_PAR03 -> Do Produto        ?          								 �
//� MV_PAR04 -> Ate o Produto     ?          								 �
//� MV_PAR05 -> Do Tipo           ?          								 �
//� MV_PAR06 -> Ate o Tipo        ?          								 �
//� MV_PAR07 -> Saldo             ? 1-Saldo Atual 2 - Fechamento			 �
//� MV_PAR08 -> Ordem             ? 1-Por Localizacao 2 - Por Valor  		 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Libera impressao.												                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
if nTotRegs > 0
	if aReturn[5] == 1
		set printer to
		OurSpool(cNomeArq)
	endif
	
	Ft_PFlush()
endif
return

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fCriaTemp� Autor � WLADIMIR ILLIUSHENKO					  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Cria arquivo temporario para impressao do relatorio.       낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
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
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fAcumula � Autor � WLADIMIR ILLIUSHENKO					  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Acumula os dados no arquivo temporario.                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static function fAcumula()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Verifica a existencia de registros para serem relatados                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
		
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
		//� Grava na tabela temporaria os dados obtidos.                        �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
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
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fImprime  � Autor � WLADIMIR ILLIUSHENKO					  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Imprime os dados da tabela temporaria. 					  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static FUNCTION fImprime()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Determina a posicao no Ranking.                                          �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Verifica o cancelamento da impressao pelo usuario.                       �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	If Interrupcao(@lAbortPrint)
		Return
	Endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Imprime parametros.                                                      �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if m_pag == 1
		U_ImpPar(cNomeProg,cTitulo,cTamanho,nCrcControl,nCbCont,cCbtxt,@nL)
	endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Impressao do cabecalho.												     �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if nL >= 65
		nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
	endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Imprime a linha de dados do relatorio.									 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Imprime rodape.													 	                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
//Roda(nCbCont, cCbtxt, cTamanho)
return

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 쿯ApagaTemp� Autor � WLADIMIR ILLIUSHENKO					  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Exclui a tabela temporaria.							      낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fApagaTemp
Static function fApagaTemp()
REL->(DbCloseArea("REL")); FErase(cArqTemp+".*")
return
