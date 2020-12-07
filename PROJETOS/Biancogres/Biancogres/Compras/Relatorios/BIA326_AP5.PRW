#include "rwmake.ch"
#include "relato.ch"
#include "topconn.ch"

User Function Bia326()

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
SetPrvt("NCRCCONTROL,NL,NI,NTOTFIL,NTOTREGS")
SetPrvt("CQUERY,CCONDQRY,CCHAVE")
SetPrvt("CNOMEFOR,NSUBTOTVAC,NTOTGERVAC,NRANKING")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ BIA326	³ Autor ³ WLADIMIR ILLIUSHENKO  ³ Data ³22/06/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio Ranking dos Maiores Fornecedores                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFAT													              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis.													              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT.									        ³
//³ Verifica Posicao do Formulario na Impressora.							        ³
//³                                          								        ³
//³ Pega os valores passados como parametro: 								        ³
//³ MV_PAR01 -> Do Produto ?                 								        ³
//³ MV_PAR02 -> Ate o Produto ?              								        ³
//³ MV_PAR03 -> Do Grupo   ?                 								        ³
//³ MV_PAR04 -> Ate o Grupo   ?              								        ³
//³ MV_PAR05 -> Da Data ?                    								        ³
//³ MV_PAR06 -> Ate a Data ?                                                 ³
//³ MV_PAR07 -> Tot. de Produtos     ?                                       ³
//³ MV_PAR08 -> Ordenado por         ?                                       ³
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
cTitulo	   += " NO PERIODO DE "+dtoc(MV_PAR05)+" A "+dtoc(MV_PAR06)
cCabec1	   :="RANK  PRODUTO  DESCRICAO                 PRC UNITARIO     QTD TOTAL       VLR TOTAL   VLR ACUMULADO  % IMPACTO   % IMP.ACUM."
cCabec2	   :="                                                                                "

Processa({|| fCriaTemp() })
Processa({|| fAcumula()  })
if nTotRegs > 0
	Processa({|| fImprime()  })
endif
Processa({|| fApagaTemp()})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera impressao.												                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if aReturn[5] == 1 .and. nTotRegs > 0
	set printer to
	OurSpool(cNomeArq)
endif
Ft_PFlush()
return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fCriaTemp³ Autor ³ WLADIMIR ILLIUSHENKO					     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria tabela temporaria.                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reconfigura os indices das tabelas auxiliares.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SB1->(DbSetOrder(1))
SBM->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula quantidade de registros a serem analizados.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao de indice temporario.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula a quantidade total que o produto possui.                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Determina a posicao no Ranking de cada fornecedor coletado.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fImprime  ³ Autor ³ WLADIMIR ILLIUSHENKO					     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprime os dados da tabela temporaria. 					     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fImprime()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a order de impressao do relatorio.                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis necessarias a impressao.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cGrupoAtual := "NULL"
cNomeGrupo  := ""
wsFlag      := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do relatorio.                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
REL->(DBGoTop())
Procregua( REL->(LastRec()))
do while !REL->(EOF())
	
	Incproc("Imprimindo Curva ABC.....")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime parametros.                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if m_pag == 1
		U_ImpPar(cNomeProg,cTitulo,cTamanho,nCrcControl,nCbCont,cCbtxt,@nL)
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho.         												     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if wsFlag
		cNomeGrupo := REL->NOMEGRUPO
		wsFlag := .F.
	endif
	
	if nL >= 65
		nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 1
	endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime o subtotalizador do grupo caso a ordem de impressao seja por ... ³
	//³ produto.                                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimenta totais parciais.   										                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSubTotPro += REL->VALORTOT
	nRanking++
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimenta totais gerais.     										                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fApagaTemp³ Autor ³ CESAR MAGNAGO                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclui a tabela temporaria.							           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> FUNCTION fApagaTemp
Static function fApagaTemp()
REL->(DbCloseArea()); FErase(cArqTemp1+".*")
return
