#include "rwmake.ch"
#include "relato.ch"
#include "topconn.ch"

User Function Bia122()

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
±±³Funcao	 ³ BIA122	³ Autor ³ WLADIMIR ILLIUSHENKO  ³ Data ³22/06/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio Ranking dos Maiores Fornecedores                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFAT													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis.													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT.									 ³
//³ Verifica Posicao do Formulario na Impressora.							 ³
//³                                          								 ³
//³ Pega os valores passados como parametro: 								 ³
//³ MV_PAR01 -> Do Grupo ?                   								 ³
//³ MV_PAR02 -> Ate o Grupo ?                								 ³
//³ MV_PAR03 -> Da Data ?                    								 ³
//³ MV_PAR04 -> Ate a Data ?                                                 ³
//³ MV_PAR05 -> Tot. de Fornecedores ?                                       ³
//³ MV_PAR06 -> Ordenar por ?                                                ³
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
cCabec1	   :="RANK  FORNECEDOR                                          VAL.ACUMULADO          QTD.          QTD.          QTD."
cCabec2	   :="                                                                              PEDIDOS          A.E.         ITENS"
             //XXXX  XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX..XXX,XXX,XXX.XX..XXX,XXX,XXXX..XXX,XXX,XXXX..XXX,XXX,XXXX

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
±±³Funcao	 ³ fCriaTemp³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reconfigura os indices das tabelas auxiliares.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA2->(DbSetOrder(1))
SBM->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula quantidade de registros a serem analizados.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao de indice temporario.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula a quantidade de pedidos distintos o fornecedor possui.           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula a quantidade de autorizacoes de entrega distintas o fornecedor ..³
			//³ possui.                                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula a quantidade de itens dos pedidos distintos que o fornecedor...  ³
			//³ possui.                                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Determina a posicao no Ranking de cada fornecedor coletado.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fImprime  ³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprime os dados da tabela temporaria. 					  ³±±
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
	case MV_PAR06 == 1 // Por Ranking
		REL->(DbCreateInd(cArqTemp1+".003","str(RANKING)", {||str(RANKING)}))
		
	case MV_PAR06 == 2 // Por Fornecedor
		REL->(DbCreateInd(cArqTemp1+".004","CODIGOFOR+LOJAFOR+str(RANKING)", {||CODIGOFOR+LOJAFOR+str(RANKING)}))
endcase
REL->(DbGoTop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis necessarias a impressao.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do relatorio.                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
REL->(DBGoTop())
Procregua( REL->(LastRec()))
do while !REL->(EOF())
	
	Incproc("Imprimindo...")
	
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime o subtotalizador do grupo caso a ordem de impressao seja por ... ³
	//³ Fornecedor.                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimenta totais parciais.   										                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSubTotVAC += REL->VALORAC
	nSubTotPED += REL->TOTPEDS
	nSubTotAE  += REL->TOTAES
	nSubTotIT  += REL->TOTITENS
	nTotFil    += 1
	nRanking++
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimenta totais gerais.     										                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
REL->(DbCloseArea()); FErase(cArqTemp1+".*")
return
