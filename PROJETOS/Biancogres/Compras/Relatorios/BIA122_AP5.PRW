#include "rwmake.ch"
#include "relato.ch"
#include "topconn.ch"

User Function Bia122()

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
굇쿑uncao	 � BIA122	� Autor � WLADIMIR ILLIUSHENKO  � Data �22/06/2001낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Relatorio Ranking dos Maiores Fornecedores                 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so		 � SIGAFAT													  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa variaveis.													 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cDesc1	   := "Este programa tem como objetivo emitir um relatorio de   "
cDesc2	   := "Ranking dos maiores fornecedores.                        "
cDesc3	   := "                                                         "
cTamanho    := "M"
cAlias	   := "SD1"
cTitulo	   := "RANKING DOS MAIORES FORNECEDORES"
aReturn	   := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
cNomeProg   := "BIA122"
aOrd	      := { }
lGravParam  := .F.
lPodeComp   := .T.
lTemDic	   := .F.
lGravParam  := .F.
nTotRegs    := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Envia controle para a funcao SETPRINT.									 �
//� Verifica Posicao do Formulario na Impressora.							 �
//�                                          								 �
//� Pega os valores passados como parametro: 								 �
//� MV_PAR01 -> Do Grupo ?                   								 �
//� MV_PAR02 -> Ate o Grupo ?                								 �
//� MV_PAR03 -> Da Data ?                    								 �
//� MV_PAR04 -> Ate a Data ?                                                 �
//� MV_PAR05 -> Tot. de Fornecedores ?                                       �
//� MV_PAR06 -> Ordenar por ?                                                �
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
cTitulo	   += " NO PERIODO DE "+dtoc(MV_PAR03)+" A "+dtoc(MV_PAR04)
cCabec1	   :="RANK  FORNECEDOR                                          VAL.ACUMULADO          QTD.          QTD.          QTD."
cCabec2	   :="                                                                              PEDIDOS          A.E.         ITENS"
             //XXXX  XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX..XXX,XXX,XXX.XX..XXX,XXX,XXXX..XXX,XXX,XXXX..XXX,XXX,XXXX

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
굇쿑uncao	 � fCriaTemp� Autor � WLADIMIR ILLIUSHENKO					  낢�
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
AADD(aCampos,{ "CODIGOFOR ", "C", 06, 0 })
AADD(aCampos,{ "LOJAFOR   ", "C", 02, 0 })
AADD(aCampos,{ "NOMEFOR   ", "C", 37, 0 })
AADD(aCampos,{ "VALORAC   ", "N", 15, 2 })
AADD(aCampos,{ "TOTPEDS   ", "N", 15, 2 })
AADD(aCampos,{ "TOTAES    ", "N", 15, 2 })
AADD(aCampos,{ "TOTITENS  ", "N", 15, 2 })
cArqTemp1 := CriaTrab(aCampos, .T.)
DbUseArea(.T.,, cArqTemp1, "REL")
return

Static Function fAcumula()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Reconfigura os indices das tabelas auxiliares.                         �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
SA2->(DbSetOrder(1))
SBM->(DbSetOrder(1))

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Calcula quantidade de registros a serem analizados.                      �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cQuery    := ""
cCondQry  := ""
cQuery    += "SELECT COUNT(SD1.D1_COD) AS TOTREGS "
cCondQry  += "FROM "+RetSQLName("SD1")+" SD1 , "+RetSQLName("SA2")+" SA2 "
cCondQry  += "WHERE "
cCondQry  += "SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
cCondQry  += "SD1.D1_GRUPO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
cCondQry  += "SD1.D1_DTDIGIT BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND "
cCondQry  += "(SD1.D1_PEDIDO NOT IN ('') OR SA2.A2_STATUS = 3) AND "
cCondQry  += "SD1.D_E_L_E_T_ = '' AND "        
cCondQry  += "SA2.A2_FILIAL = '"+xFilial("SA2")+"' AND "
cCondQry  += "SA2.A2_COD = SD1.D1_FORNECE AND "
cCondQry  += "SA2.A2_LOJA = SD1.D1_LOJA AND "
cCondQry  += "SA2.D_E_L_E_T_ = '' "
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
	REL->(DbCreateInd(cArqTemp1+".001","CODIGOFOR+LOJAFOR", {||CODIGOFOR+LOJAFOR}))
	
	cQuery  := ""
	cQuery  += "SELECT "
	cQuery  += "       D1_PEDIDO,  "
	cQuery  += "       D1_GRUPO,   "
	cQuery  += "       D1_FORNECE, "
	cQuery  += "       D1_LOJA,    "
	cQuery  += "       D1_TOTAL    "
	cQuery  += cCondQry
	TCQuery cQuery Alias "QRY" New
	
	ProcRegua(nTotRegs)
	do while QRY->(!EOF())
		
		IncProc("Analizando NFs de entrada...")
		
		if !REL->(DBSeek(trim(QRY->D1_FORNECE)+trim(QRY->D1_LOJA), .T.))
			
			cNomeFor := "FORNECEDOR NAO CADASTRADO!"
			if SA2->(DBSeek(xFilial("SA2")+QRY->D1_FORNECE))
				cNomeFor := SA2->A2_NOME
			endif
			
			cNomeGrupo := "GRUPO NAO CADASTRADO!"
			if SBM->(DBSeek(xFilial("SBM")+QRY->D1_GRUPO))
				cNomeGrupo := SBM->BM_DESC
			endif
			
			RecLock("REL",.T.)
			REL->GRUPO     := QRY->D1_GRUPO
			REL->NOMEGRUPO := cNomeGrupo
			REL->CODIGOFOR := QRY->D1_FORNECE
			REL->LOJAFOR   := QRY->D1_LOJA
			REL->NOMEFOR   := cNomeFor
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Calcula a quantidade de pedidos distintos o fornecedor possui.           �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			cQuery := ""
			cQuery += "SELECT COUNT(DISTINCT SD1.D1_PEDIDO) AS TOTREGS "
			cQuery += "FROM "+RetSQLName("SD1")+" SD1 "
			cQuery += "WHERE "
			cQuery += "     SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
			cQuery += "     SD1.D1_DTDIGIT BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND "
			cQuery += "     SUBSTRING(SD1.D1_PEDIDO,1,1) = 'P' AND "
			cQuery += "     SD1.D1_FORNECE = '"+REL->CODIGOFOR+"' AND "
			cQuery += "     SD1.D1_LOJA = '"+REL->LOJAFOR+"' AND "
			cQuery += "     SD1.D1_GRUPO = '"+REL->GRUPO+"' AND "			
			cQuery += "     SD1.D_E_L_E_T_ = '' "
			TCQuery cQuery Alias "X" New
			REL->TOTPEDS := X->TOTREGS
			X->(DbCloseArea())
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Calcula a quantidade de autorizacoes de entrega distintas o fornecedor ..�
			//� possui.                                                                  �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			cQuery := ""
			cQuery += "SELECT COUNT(DISTINCT SD1.D1_PEDIDO) AS TOTREGS "
			cQuery += "FROM "+RetSQLName("SD1")+" SD1 "
			cQuery += "WHERE "
			cQuery += "     SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
			cQuery += "     SD1.D1_DTDIGIT BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND "
			cQuery += "     SUBSTRING(SD1.D1_PEDIDO,1,1) = 'A' AND "
			cQuery += "     SD1.D1_FORNECE = '"+REL->CODIGOFOR+"' AND "
			cQuery += "     SD1.D1_LOJA = '"+REL->LOJAFOR+"' AND "
			cQuery += "     SD1.D1_GRUPO = '"+REL->GRUPO+"' AND "
			cQuery += "     SD1.D_E_L_E_T_ = '' "
			TCQuery cQuery Alias "X" New
			REL->TOTAES := X->TOTREGS
			X->(DbCloseArea())
			
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//� Calcula a quantidade de itens dos pedidos distintos que o fornecedor...  �
			//� possui.                                                                  �
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			cQuery := ""
			cQuery += "SELECT COUNT(SD1.D1_COD) AS TOTREGS "
			cQuery += "FROM "+RetSQLName("SD1")+" SD1 "
			cQuery += "WHERE "
			cQuery += "     SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
			cQuery += "     SD1.D1_DTDIGIT BETWEEN '"+dtos(MV_PAR03)+"' AND '"+dtos(MV_PAR04)+"' AND "			
			cQuery += "     SUBSTRING(SD1.D1_PEDIDO,1,1) IN ('A','P') AND "
			cQuery += "     SD1.D1_FORNECE = '"+REL->CODIGOFOR+"' AND "
			cQuery += "     SD1.D1_LOJA = '"+REL->LOJAFOR+"' AND "
			cQuery += "     SD1.D1_GRUPO = '"+REL->GRUPO+"' AND "
			cQuery += "     SD1.D_E_L_E_T_ = '' "
			TCQuery cQuery Alias "X" New
			REL->TOTITENS := X->TOTREGS
			X->(DbCloseArea())						
		else
			RecLock("REL",.F.)
		endif
		
		REL->VALORAC += QRY->D1_TOTAL
		REL->(DBUnlock())
		
		QRY->(DBSkip())
	enddo
	QRY->(DBCloseArea())
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Determina a posicao no Ranking de cada fornecedor coletado.              �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	REL->(DBCloseArea())
	DbUseArea(.T.,,cArqTemp1,"REL")
	REL->(DbCreateInd(cArqTemp1+".002","descend(str(VALORAC))+CODIGOFOR+LOJAFOR", {||descend(str(VALORAC))+CODIGOFOR+LOJAFOR}))
	
	nI := 0
	ProcRegua(REL->(LastRec()))
	REL->(DbGoTop())
	do while !REL->(EOF())
		
		IncProc("Determinando o Ranking...")
		
		nI := nI + 1
		
		RecLock("REL",.F.)
		if nI > MV_PAR05
			DBDelete()
		else
			REL->RANKING := nI
			REL->(DBUnlock())
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
굇쿑uncao	 � fImprime  � Autor � WLADIMIR ILLIUSHENKO					  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Imprime os dados da tabela temporaria. 					  낢�
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
	case MV_PAR06 == 1 // Por Ranking
		REL->(DbCreateInd(cArqTemp1+".003","str(RANKING)", {||str(RANKING)}))
		
	case MV_PAR06 == 2 // Por Fornecedor
		REL->(DbCreateInd(cArqTemp1+".004","CODIGOFOR+LOJAFOR+str(RANKING)", {||CODIGOFOR+LOJAFOR+str(RANKING)}))
endcase
REL->(DbGoTop())

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Inicializa variaveis necessarias a impressao.                            �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
cGrupoAtual := "NULL"
nSubTotVAC  := 0
nSubTotPED  := 0
nSubTotAE   := 0
nSubTotIT   := 0
nTotGerVAC  := 0
nTotGerPED  := 0
nTotGerAE   := 0
nTotGerIT   := 0
nTotFil     := 0

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Impressao do relatorio.                                                  �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
REL->(DBGoTop())
Procregua( REL->(LastRec()))
do while !REL->(EOF())
	
	Incproc("Imprimindo...")
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Imprime parametros.                                                      �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if m_pag == 1
	   U_ImpPar(cNomeProg,cTitulo,cTamanho,nCrcControl,nCbCont,cCbtxt,@nL)
	endif	
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Impressao do cabecalho.         												     �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if nL >= 65
		nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 1
	endif
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Imprime o subtotalizador do grupo caso a ordem de impressao seja por ... �
	//� Fornecedor.                                                              �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if MV_PAR06 == 2
		if REL->CODIGOFOR <> cGrupoAtual
			if cGrupoAtual <> "NULL"
				nL++
				if nTotFil > 1					
					cLinDeImp := ""+space(06)
					cLinDeImp += "TOTAL DAS FILIAIS PARA ESSE FORNECEDOR .........."+space(02)
					cLinDeImp += u_rtoc(nSubTotVAC) + space(03)
					cLinDeImp += u_rtoc(nSubTotPED,"@E 999,999,999") + space(03)
					cLinDeImp += u_rtoc(nSubTotAE,"@E 999,999,999")  + space(03)
					cLinDeImp += u_rtoc(nSubTotIT,"@E 999,999,999")
					@ nL,000 PSay cLinDeImp
					nL += 3
				endif
				
				nSubTotVAC := 0
				nSubTotPED := 0
				nSubTotAE  := 0
				nSubTotIT  := 0
				nTotFil    := 0
			endif
			
			cGrupoAtual := REL->CODIGOFOR			
		endif
	endif
	
	cLinDeImp := ""
	cLinDeImp += trans(REL->RANKING,"@R 999o") + space(02)
	cLinDeImp += REL->CODIGOFOR+"-"+REL->LOJAFOR+" - "+padr(REL->NOMEFOR,37) + space(02)
	cLinDeImp += u_rtoc(REL->VALORAC) + space(03)
	cLinDeImp += u_rtoc(REL->TOTPEDS,"@E 999,999,999") + space(03)
	cLinDeImp += u_rtoc(REL->TOTAES,"@E 999,999,999") + space(03)
	cLinDeImp += u_rtoc(REL->TOTITENS,"@E 999,999,999")
	@ nL,000 PSay cLinDeImp
	nL++
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Alimenta totais parciais.   										                 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	nSubTotVAC += REL->VALORAC
	nSubTotPED += REL->TOTPEDS
	nSubTotAE  += REL->TOTAES
	nSubTotIT  += REL->TOTITENS
	nTotFil    += 1
	nRanking++
	
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Alimenta totais gerais.     										                 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	nTotGerVAC += REL->VALORAC 
	nTotGerPED += REL->TOTPEDS
	nTotGerAE  += REL->TOTAES
	nTotGerIT  += REL->TOTITENS	
		
	REL->(DBSkip())
enddo

if MV_PAR06 == 2
	nL++
	if nTotFil > 1
		cLinDeImp := ""+space(06)
		cLinDeImp += "TOTAL DAS FILIAIS PARA ESSE FORNECEDOR .........."+space(02)
		cLinDeImp += u_rtoc(nSubTotVAC)  + space(03)
		cLinDeImp += u_rtoc(nSubTotPED,"@E 999,999,999") + space(03)
		cLinDeImp += u_rtoc(nSubTotAE,"@E 999,999,999")  + space(03)
		cLinDeImp += u_rtoc(nSubTotIT,"@E 999,999,999")		
		@ nL,000 PSay cLinDeImp
		nL += 4
	endif
endif

nL++
cLinDeImp := ""
cLinDeImp += "TOTAL GERAL ..........................................."+space(02)
cLinDeImp += u_rtoc(nTotGerVAC) + space(03)
cLinDeImp += u_rtoc(nTotGerPED,"@E 999,999,999") + space(03)
cLinDeImp += u_rtoc(nTotGerAE,"@E 999,999,999")  + space(03)
cLinDeImp += u_rtoc(nTotGerIT,"@E 999,999,999")
@ nL,000 PSay cLinDeImp

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
REL->(DbCloseArea()); FErase(cArqTemp1+".*")
return
