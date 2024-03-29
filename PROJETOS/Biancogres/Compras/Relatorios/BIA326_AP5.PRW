#include "rwmake.ch"
#include "relato.ch"
#include "topconn.ch"

User Function Bia326()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("CDESC1,CDESC2,CDESC3,CALIAS,CNOMEPROG,CNOMEARQ,CPERGUNTA")
SetPrvt("CTITULO,CCABEC1,CCABEC2,CTAMANHO,CLINDEIMP,CARQTEMP1,CARQTEMP2")
SetPrvt("LGRAVPARAM,LTEMDIC,LPODECOMP")
SetPrvt("ARETURN,ACAMPOS,AORD")
SetPrvt("NCRCCONTROL,NL,NI,NTOTFIL,NTOTREGS")
SetPrvt("CQUERY,CCONDQRY,CCHAVE")
SetPrvt("CNOMEFOR,NSUBTOTVAC,NTOTGERVAC,NRANKING")

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao	 � BIA326	� Autor � WLADIMIR ILLIUSHENKO  � Data �22/06/2001낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Relatorio Ranking dos Maiores Fornecedores                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so		 � SIGAFAT													              낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa variaveis.													              �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cDesc1	   := "Este programa tem como objetivo emitir um relatorio de   "
cDesc2	   := "Ranking dos maiores produtos consumidos por valor.       "
cDesc3	   := "                                                         "
cTamanho    := "M"
cAlias	   := "SD1"
cTitulo	   := "RANKING DOS MAIORES PRODUTOS CONSUMIDOS POR VALOR"
aReturn	   := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
cNomeProg   := "BIA326"
aOrd	      := { }
lGravParam  := .F.
lPodeComp   := .T.
lTemDic	   := .F.
lGravParam  := .F.
nTotRegs    := 0
nVlrTot     := 0
wsTotPeds   := 0
nSubTotPro  := 0
nTotGerPro  := 0
nTotAcuPro  := 0
nTotImpPro  := 0
nTotIAcPro  := 0
nTotGerAcu  := 0
nTotGerImp  := 0
nTotGerIAc  := 0
nTotAcuGru  := 0
nTotImpGru  := 0
nTotIAcGru  := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT.									        �
//� Verifica Posicao do Formulario na Impressora.							        �
//�                                          								        �
//� Pega os valores passados como parametro: 								        �
//� MV_PAR01 -> Do Produto ?                 								        �
//� MV_PAR02 -> Ate o Produto ?              								        �
//� MV_PAR03 -> Do Grupo   ?                 								        �
//� MV_PAR04 -> Ate o Grupo   ?              								        �
//� MV_PAR05 -> Da Data ?                    								        �
//� MV_PAR06 -> Ate a Data ?                                                 �
//� MV_PAR07 -> Tot. de Produtos     ?                                       �
//� MV_PAR08 -> Ordenado por         ?                                       �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa variaveis usadas no relatorio.                                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
nCbcont	   := 1
cCbtxt 	   := "USUARIO: "+cUserName
m_pag 	   := 1
nL          := 80
nCrcControl := iif(aReturn[4]==1,15,18)
cTitulo	   += " NO PERIODO DE "+dtoc(MV_PAR05)+" A "+dtoc(MV_PAR06)
cCabec1	   :="RANK  PRODUTO  DESCRICAO                 PRC UNITARIO     QTD TOTAL       VLR TOTAL   VLR ACUMULADO  % IMPACTO   % IMP.ACUM."
cCabec2	   :="                                                                                "

Processa({|| fCriaTemp() })
Processa({|| fAcumula()  })
if nTotRegs > 0
	Processa({|| fImprime()  })
endif
Processa({|| fApagaTemp()})

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Libera impressao.												                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
if aReturn[5] == 1 .and. nTotRegs > 0
	set printer to
	OurSpool(cNomeArq)
endif
Ft_PFlush()
return

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fCriaTemp� Autor � WLADIMIR ILLIUSHENKO					     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Cria tabela temporaria.                                    낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static FUNCTION fCriaTemp()
aCampos := {}
AADD(aCampos,{ "RANKING   ", "N", 04, 0 })
AADD(aCampos,{ "GRUPO     ", "C", 04, 0 })
AADD(aCampos,{ "NOMEGRUPO ", "C", 40, 0 })
AADD(aCampos,{ "CODIGOPRO ", "C", 07, 0 })
AADD(aCampos,{ "NOMEPRO   ", "C", 25, 0 })
AADD(aCampos,{ "UPRC      ", "N",  9, 2 })
AADD(aCampos,{ "QTDTOT    ", "N", 10, 2 })
AADD(aCampos,{ "VALORTOT  ", "N", 12, 2 })
cArqTemp1 := CriaTrab(aCampos, .T.)
DbUseArea(.T.,, cArqTemp1, "REL")
return

Static Function fAcumula()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Reconfigura os indices das tabelas auxiliares.                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
SB1->(DbSetOrder(1))
SBM->(DbSetOrder(1))

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Calcula quantidade de registros a serem analizados.                      �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cQuery    := ""
cCondQry  := ""
cQuery    += "SELECT COUNT(SD3.D3_COD) AS TOTREGS "
cCondQry  += "FROM "+RetSQLName("SD3")+" SD3 , "+RetSQLName("SB1")+" SB1 "
cCondQry  += "WHERE "
cCondQry  += "SD3.D3_FILIAL = '"+xFilial("SD3")+"' AND "
cCondQry  += "SD3.D3_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
cCondQry  += "SD3.D3_EMISSAO BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"' AND "
cCondQry  += "SD3.D3_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "
cCondQry  += "SD3.D3_ESTORNO = '' AND "
cCondQry  += "SD3.D_E_L_E_T_ = '' AND "
cCondQry  += "SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND "
cCondQry  += "SB1.B1_COD = SD3.D3_COD AND "
cCondQry  += "SB1.D_E_L_E_T_ = '' "
cQuery    += cCondQry
TCQuery cQuery Alias "X" New
nTotRegs := X->TOTREGS
X->(DbCloseArea())

if nTotRegs > 0
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Definicao de indice temporario.                                          �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	REL->(DBCloseArea())
	DbUseArea(.T.,,cArqTemp1,"REL")
	REL->(DbCreateInd(cArqTemp1+".001","CODIGOPRO", {||CODIGOPRO}))
	
	cQuery  := ""
	cQuery  += "SELECT "
	cQuery  += "   SD3.D3_COD,     "
	cQuery  += "   SD3.D3_GRUPO,   "
	cQuery  += "   SD3.D3_QUANT    "
	cQuery  += cCondQry
	TCQuery cQuery Alias "QRY" New
	
	ProcRegua(nTotRegs)
	do while QRY->(!EOF())
		
		IncProc("Analizando Requisicoes...")
		
		if !REL->(DBSeek(trim(QRY->D3_COD), .T.))
			
			cNomeFor := "PRODUTO NAO CADASTRADO!"
			if SB1->(DBSeek(xFilial("SB1")+QRY->D3_COD))
				cNomePro := SB1->B1_DESC
			endif
			
			cNomeGrupo := "GRUPO NAO CADASTRADO!"
			if SBM->(DBSeek(xFilial("SBM")+QRY->D3_GRUPO))
				cNomeGrupo := SBM->BM_DESC
			endif
			
			RecLock("REL",.T.)
			REL->GRUPO     := QRY->D3_GRUPO
			REL->NOMEGRUPO := cNomeGrupo
			REL->CODIGOPRO := QRY->D3_COD
			REL->NOMEPRO   := cNomePro
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+QRY->D3_COD,.F.)
			REL->UPRC := SB1->B1_UPRC
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Calcula a quantidade total que o produto possui.                         �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			cQuery := ""
			cQuery += "SELECT SUM(SD3.D3_QUANT) AS TOTPROD "
			cQuery += "FROM "+RetSQLName("SD3")+" SD3 "
			cQuery += "WHERE "
			cQuery += "     SD3.D3_FILIAL = '"+xFilial("SD3")+"' AND "
			cQuery += "     SD3.D3_EMISSAO BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"' AND "
			cQuery += "     SD3.D3_COD     = '"+REL->CODIGOPRO+"' AND "
			cQuery += "     SD3.D_E_L_E_T_ = '' "
			TCQuery cQuery Alias "X" New
			wsTOTPEDS := X->TOTPROD
			X->(DbCloseArea())
			
		else
			RecLock("REL",.F.)
		endif
		
		nVlrTot   := 0
		nVlrTot   := SB1->B1_UPRC * wsTOTPEDS
		
		REL->VALORTOT += nVlrTot
		REL->QTDTOT   += wsTOTPEDS
		REL->(DBUnlock())
		wsTotPeds := 0
		
		QRY->(DBSkip())
	enddo
	QRY->(DBCloseArea())
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Determina a posicao no Ranking de cada fornecedor coletado.              �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	REL->(DBCloseArea())
	DbUseArea(.T.,,cArqTemp1,"REL")
	REL->(DbCreateInd(cArqTemp1+".002","descend(str(VALORTOT))+CODIGOPRO", {||descend(str(VALORTOT))+CODIGOPRO}))
	
	nI := 0
	ProcRegua(REL->(LastRec()))
	REL->(DbGoTop())
	do while !REL->(EOF())
		
		IncProc("Determinando o Ranking...")
		
		nI := nI + 1
		
		RecLock("REL",.F.)
		if nI > MV_PAR07
			DBDelete()
		else
			REL->RANKING := nI
			REL->(DBUnlock())
			nTotGerAcu += REL->VALORTOT
		endif
		REL->(DBSkip())
	enddo
else
	alert("Nao ha dados a serem processados!")
endif
return

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fImprime  � Autor � WLADIMIR ILLIUSHENKO					     낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Imprime os dados da tabela temporaria. 					     낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
Static Function fImprime()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Define a order de impressao do relatorio.                                �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
REL->(DBCloseArea())
DbUseArea(.T.,,cArqTemp1,"REL")
do case
	case MV_PAR08 == 1 // Por Ranking
		REL->(DbCreateInd(cArqTemp1+".003","str(RANKING)", {||str(RANKING)}))
	case MV_PAR08 == 2 // Por Produto
		REL->(DbCreateInd(cArqTemp1+".004","CODIGOPRO+str(RANKING)", {||CODIGOPRO+str(RANKING)}))
	case MV_PAR08 == 3 // Por Descricao
		REL->(DbCreateInd(cArqTemp1+".005","NOMEPRO+str(RANKING)", {||NOMEPRO+str(RANKING)}))

endcase
REL->(DbGoTop())

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa variaveis necessarias a impressao.                            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cGrupoAtual := "NULL"
cNomeGrupo  := ""
wsFlag      := .T.

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Impressao do relatorio.                                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
REL->(DBGoTop())
Procregua( REL->(LastRec()))
do while !REL->(EOF())
	
	Incproc("Imprimindo Curva ABC.....")
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Imprime parametros.                                                      �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if m_pag == 1
		U_ImpPar(cNomeProg,cTitulo,cTamanho,nCrcControl,nCbCont,cCbtxt,@nL)
	endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Impressao do cabecalho.         												     �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if wsFlag
		cNomeGrupo := REL->NOMEGRUPO
		wsFlag := .F.
	endif
	
	if nL >= 65
		nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 1
	endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Imprime o subtotalizador do grupo caso a ordem de impressao seja por ... �
	//� produto.                                                                 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if MV_PAR08 == 2
		if REL->GRUPO <> cGrupoAtual
			if cGrupoAtual <> "NULL"
				nL++
				cLinDeImp := ""+space(06)
				cLinDeImp += "TOTAL GRUPO    "+cNOMEGRUPO+space(24)
				//cLinDeImp += u_rtoc(nSubTotPro)                     + space(2)
            cLinDeImp += Trans(nTotAcuGru,"@E 999,999,999.99")  + space(5)
            cLinDeImp += Trans(nTotImpGru,"@E 999.99")          + space(7)
            //cLinDeImp += Trans(nTotIAcGru,"@E 999.99")
				@ nL,000 PSay cLinDeImp
				nL += 3
				nSubTotPro := 0
				nTotAcuGru := 0
				nTotImpGru := 0
				nTotIAcGru := 0
			endif
			
			cGrupoAtual := REL->GRUPO
			cNomeGrupo  := REL->NOMEGRUPO
		endif
	endif
	
	cLinDeImp  := ""
	cLinDeImp  += trans(REL->RANKING,"@R 999o")            + space(2)
	cLinDeImp  += REL->CODIGOPRO+" "+REL->NOMEPRO          + space(2)
	cLinDeImp  += Trans(REL->UPRC,"@E 9,999,999.99")       + space(2)
	cLinDeImp  += Trans(REL->QTDTOT,"@E 9,999,999.99")     + space(2)
	cLinDeImp  += Trans(REL->VALORTOT,"@E 999,999,999.99") + space(2)
	nTotAcuPro += REL->VALORTOT
	cLinDeImp  += Trans(nTotAcuPro,"@E 999,999,999.99")    + space(6)
	nTotImpPro := 0
	nTotImpPro := ((REL->VALORTOT*100)/nTotGerAcu)
	cLinDeImp  += Trans(nTotImpPro,"@E 99.99")             + space(7)
	nTotIAcPro += nTotImpPro
	cLinDeImp  += Trans(nTotIAcPro,"@E 999.99")
   nTotGerImp += nTotImpPro
	nTotGerIAc += nTotIAcPro
	nTotAcuGru := nTotAcuPro
	nTotImpGru += nTotImpPro
	nTotIAcGru += nTotIAcPro
	@ nL,000 PSay cLinDeImp
	nL++
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Alimenta totais parciais.   										                 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	nSubTotPro += REL->VALORTOT
	nRanking++
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Alimenta totais gerais.     										                 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	nTotGerPro += REL->VALORTOT
	
	REL->(DBSkip())
enddo

if MV_PAR08 == 2
	nL++
	cLinDeImp := ""+space(06)
	cLinDeImp += "TOTAL GRUPO    "+cNOMEGRUPO + space(24)
	//cLinDeImp += u_rtoc(nSubTotPro)           + space(2)
   cLinDeImp += Trans(nTotAcuGru,"@E 999,999,999.99")  + space(5)
   cLinDeImp += Trans(nTotImpGru,"@E 999.99")          + space(7)
   //cLinDeImp += Trans(nTotIAcGru,"@E 999.99")
	@ nL,000 PSay cLinDeImp
	nL += 2
endif

nL++
cLinDeImp := ""+space(06)
cLinDeImp += "TOTAL GERAL ..."                      + space(64)
//cLinDeImp += u_rtoc(nTotGerPro)                     + space(2)
cLinDeImp  += Trans(nTotGerAcu,"@E 999,999,999.99") + space(5)
cLinDeImp  += Trans(nTotGerImp,"@E 999.99")         + space(7)
//cLinDeImp  += Trans(nTotGerIAc,"@E 999.99")
@ nL,000 PSay cLinDeImp
nL ++

return

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 쿯ApagaTemp� Autor � CESAR MAGNAGO                           낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Exclui a tabela temporaria.							           낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fApagaTemp
Static function fApagaTemp()
REL->(DbCloseArea()); FErase(cArqTemp1+".*")
return
