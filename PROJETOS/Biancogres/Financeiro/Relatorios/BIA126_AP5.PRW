#include "rwmake.ch"
#include "relato.ch"
#include "topconn.ch"

User Function Bia126()

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
±±³Funcao	 ³ BIA126	³ Autor ³ WLADIMIR ILLIUSHENKO  ³ Data ³30/08/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio Ranking das Maiores Transportadoras              ³±±
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
cDesc2	   := "Ranking das maiores transportadoras.                     "
cDesc3	   := "                                                         "
cTamanho    := "M"
cAlias	   := "SF8"
cTitulo	   := "RANKING DAS MAIORES TRANSPORTADORAS"
aReturn	   := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
cNomeProg   := "BIA126"
aOrd	      := { }
lGravParam  := .F.
lPodeComp   := .T.
lTemDic	   := .F.
lGravParam  := .F.
nTotRegs1   := 0
nTotRegs2   := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT.									 ³
//³ Verifica Posicao do Formulario na Impressora.							 ³
//³                                          								 ³
//³ Pega os valores passados como parametro: 								 ³
//³ MV_PAR01 -> Da Data ?                    								 ³
//³ MV_PAR02 -> Ate a Data ?                                                 ³
//³ MV_PAR03 -> Tot. de Transportadoras ?                                    ³
//³ MV_PAR04 -> Ordenar por ?                                                ³
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
cTitulo	   += " NO PERIODO DE "+dtoc(MV_PAR01)+" A "+dtoc(MV_PAR02)
cCabec1	   := "RANK  TRANSPORTADORA                                      VAL.ACUMULADO"
cCabec2	   := "                                                                       "
//cCabec2	   := "XXXX  XXXXXX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX..XXX,XXX,XXX.XX

Processa({|| fCriaTemp() })
Processa({|| fAcumula()  })
if nTotRegs1+nTotRegs2 > 0
	Processa({|| fImprime()  })
endif
Processa({|| fApagaTemp()})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera impressao.												         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if aReturn[5] == 1 .and. (nTotRegs1+nTotRegs2) > 0
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
AADD(aCampos,{ "CODIGOTRAN", "C", 06, 0 })
AADD(aCampos,{ "LOJATRAN  ", "C", 02, 0 })
AADD(aCampos,{ "NOMETRAN  ", "C", 37, 0 })
AADD(aCampos,{ "VALORAC   ", "N", 15, 2 })
cArqTemp1 := CriaTrab(aCampos, .T.)
DbUseArea(.T.,, cArqTemp1, "REL")
return

Static Function fAcumula()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Reconfigura os indices das tabelas auxiliares.                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA2->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula quantidade de registros existentes no cadastro de fretes.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery  := ""
cQuery  += "SELECT COUNT(DISTINCT SF8.F8_TRANSP+SF8.F8_LOJTRAN) AS TOTREGS "
cQuery  += "FROM "+RetSqlName("SF8")+" SF8,"+RetSqlName("SF1")+" SF1 "
cQuery  += "WHERE "
cQuery  += "SF8.F8_FILIAL = '"+xFilial("SF8")+"' AND "
cQuery  += "SF8.D_E_L_E_T_ = '' AND "
cQuery  += "SF1.F1_FILIAL = '"+xFilial("SF1")+"' AND "
cQuery  += "SF1.F1_DOC = SF8.F8_NFDIFRE AND "
cQuery  += "SF1.F1_SERIE = SF8.F8_SEDIFRE AND "
cQuery  += "SF1.F1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND "
cQuery  += "SF1.D_E_L_E_T_ = '' "
TCQuery cQuery Alias "X" New
nTotRegs1 := X->TOTREGS
X->(DbCloseArea())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula quantidade de registros existentes nas NF de entrada.            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery  := ""
cQuery  += "SELECT COUNT(DISTINCT SD1.D1_FORNECE+SD1.D1_LOJA) AS TOTREGS "
cQuery  += "FROM "+RetSqlName("SD1")+" SD1 "
cQuery  += "WHERE "
cQuery  += "SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
cQuery  += "SD1.D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND "
cQuery  += "SD1.D1_TIPO = 'C' AND "
cQuery  += "SD1.D1_CF IN ('262','162') AND "
cQuery  += "SD1.D_E_L_E_T_ = '' "
TCQuery cQuery Alias "X" New
nTotRegs2 := X->TOTREGS
X->(DbCloseArea())

if nTotRegs1+nTotRegs2 > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao de indice temporario.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	REL->(DBCloseArea())
	DbUseArea(.T.,,cArqTemp1,"REL")
	REL->(DbCreateInd(cArqTemp1+".001","CODIGOTRAN+LOJATRAN", {||CODIGOTRAN+LOJATRAN}))	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Analizando Conhecimentos de Frete ...                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*	cQuery  := ""
	cQuery  += "SELECT "
	cQuery  += "SF8.F8_TRANSP, "
	cQuery  += "SF8.F8_LOJTRAN, "
	cQuery  += "SUM(SF1.F1_VALMERC) AS F1_VALMERC "
	//cQuery  += "SUM(SF1.F1_FRETE) AS F1_VALMERC "
	cQuery  += "FROM "+RetSqlName("SF8")+" SF8, "+RetSqlName("SF1")+" SF1 "
	cQuery  += "WHERE "
	cQuery  += "SF8.F8_FILIAL = '"+xFilial("SF8")+"' AND "
	cQuery  += "SF8.D_E_L_E_T_ = '' AND "
	cQuery  += "SF1.F1_FILIAL = '"+xFilial("SF1")+"' AND "
	cQuery  += "SF1.F1_DOC = SF8.F8_NFDIFRE AND "
	cQuery  += "SF1.F1_SERIE = SF8.F8_SEDIFRE AND "

	cQuery  += "SF1.F1_FORNECE = SF8.F8_TRANSP AND 	"  // ALTERADO PELO MADALENO

	cQuery  += "SF1.F1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND "
	cQuery  += "SF1.D_E_L_E_T_ = '' "
	cQuery  += "GROUP BY "
	cQuery  += "SF8.F8_TRANSP, "
	cQuery  += "SF8.F8_LOJTRAN "
	TCQuery cQuery Alias "QRY" New
	
	ProcRegua(nTotRegs1)
	do while QRY->(!EOF())
		
		IncProc("Analizando Conhecimentos de Frete ...")
		
		cNomeTrans := "TRANSPORTADORA NAO CADASTRADA!"
		if SA2->(DBSeek(xFilial("SA2")+QRY->F8_TRANSP+QRY->F8_LOJTRAN))
			cNomeTrans := SA2->A2_NOME
		endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acumula o valor das mercadorias para a transportadora.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("REL",.T.)
		REL->CODIGOTRAN := QRY->F8_TRANSP
		REL->LOJATRAN   := QRY->F8_LOJTRAN
		REL->NOMETRAN   := cNomeTrans
		REL->VALORAC    := QRY->F1_VALMERC //F1_FRETE
		REL->(DBUnlock())
		
		QRY->(DBSkip())
	enddo
	QRY->(DBCloseArea())
*/	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Analizando NF de MPM (Materia-Prima de Massa).                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery  := ""
	cQuery  += "SELECT "
	cQuery  += "SD1.D1_FORNECE, "
	cQuery  += "SD1.D1_LOJA, "
	//cQuery  += "SUM(SF1.F1_VALMERC) AS F1_VALMERC "
	cQuery  += "SUM(SD1.D1_TOTAL) AS F1_VALMERC "
	cQuery  += "FROM "+RetSqlName("SD1")+" SD1, "+RetSqlName("SF1")+" SF1 "
	cQuery  += "WHERE "
	cQuery  += "SD1.D1_FILIAL = '"+xFilial("SD1")+"' AND "
	cQuery  += "SD1.D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' AND "
	cQuery  += "SD1.D1_TIPO = 'C' AND "
	cQuery  += "SD1.D1_CF IN ('262','162','1352','2352') AND "
	cQuery  += "SD1.D_E_L_E_T_ = '' AND "
	cQuery  += "SF1.D_E_L_E_T_ = '' AND "
	cQuery  += "SF1.F1_FILIAL = '"+xFilial("SF1")+"' AND "
	cQuery  += "SF1.F1_DOC = SD1.D1_DOC AND "
	cQuery  += "SF1.F1_SERIE = SD1.D1_SERIE AND "

	cQuery  += "SF1.F1_FORNECE = SD1.D1_FORNECE  " // ALTERADO PELO MADALENO
	
	cQuery  += "GROUP BY "
	cQuery  += "SD1.D1_FORNECE, "
	cQuery  += "SD1.D1_LOJA "
	TCQuery cQuery Alias "QRY" New
	
	ProcRegua(nTotRegs2)
	do while QRY->(!EOF())
		
		IncProc("Analizando NFs de MPM ...")
		
		if !REL->(DBSeek(QRY->D1_FORNECE+QRY->D1_LOJA))
			cNomeTrans := "TRANSPORTADORA NAO CADASTRADA!"
			if SA2->(DBSeek(xFilial("SA2")+QRY->D1_FORNECE+QRY->D1_LOJA))
				cNomeTrans := SA2->A2_NOME
			endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acumula o valor das mercadorias para a transportadora.                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("REL",.T.)
			REL->CODIGOTRAN := QRY->D1_FORNECE
			REL->LOJATRAN   := QRY->D1_LOJA
			REL->NOMETRAN   := cNomeTrans
			REL->VALORAC    := QRY->F1_VALMERC
		else
			RecLock("REL",.F.)
			REL->VALORAC += QRY->F1_VALMERC
		endif
		REL->(DBUnlock())
		
		QRY->(DBSkip())
	enddo
	QRY->(DBCloseArea())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Determina a posicao no Ranking de cada transportadora.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	REL->(DBCloseArea())
	DbUseArea(.T.,,cArqTemp1,"REL")
	REL->(DbCreateInd(cArqTemp1+".002","descend(str(VALORAC))+CODIGOTRAN+LOJATRAN", {||descend(str(VALORAC))+CODIGOTRAN+LOJATRAN}))
	
	nI := 0
	ProcRegua(REL->(LastRec()))
	REL->(DbGoTop())
	do while !REL->(EOF())
		
		IncProc("Determinando o Ranking...")
		
		nI := nI + 1
		
		RecLock("REL",.F.)
		if nI > MV_PAR03
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
	case MV_PAR04 == 1 // Por Ranking
		REL->(DbCreateInd(cArqTemp1+".003","str(RANKING)", {||str(RANKING)}))
		
	case MV_PAR04 == 2 // Por Transportadora
		REL->(DbCreateInd(cArqTemp1+".004","CODIGOTRAN+LOJATRAN+str(RANKING)", {||CODIGOTRAN+LOJATRAN+str(RANKING)}))
endcase
REL->(DbGoTop())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis necessarias a impressao.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cGrupoAtual := "NULL"
nSubTotVAC  := 0
nTotGerVAC  := 0
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
	//³ Transportadora.                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if MV_PAR04 == 2
		if REL->CODIGOTRAN <> cGrupoAtual
			if cGrupoAtual <> "NULL"
				nL++
				if nTotFil > 1
					cLinDeImp := ""+space(06)
					cLinDeImp += "TOTAL DAS FILIAIS PARA ESSA TRANSPORTADORA ......"+space(02)
					cLinDeImp += u_rtoc(nSubTotVAC)
					@ nL,000 PSay cLinDeImp
					nL += 3
				endif
				
				nSubTotVAC := 0
				nTotFil    := 0
			endif
			
			cGrupoAtual := REL->CODIGOTRAN
		endif
	endif
	
	cLinDeImp := ""
	cLinDeImp += trans(REL->RANKING,"@R 999o") + space(2)
	cLinDeImp += REL->CODIGOTRAN+"-"+REL->LOJATRAN+" - "+padr(REL->NOMETRAN,37) + space(2)
	cLinDeImp += u_rtoc(REL->VALORAC)
	@ nL,000 PSay cLinDeImp
	nL++
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimenta totais parciais.   										                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSubTotVAC += REL->VALORAC
	nTotFil    += 1
	nRanking++
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alimenta totais gerais.     										                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotGerVAC += REL->VALORAC
	
	REL->(DBSkip())
enddo

if MV_PAR04 == 2
	nL++
	if nTotFil > 1
		cLinDeImp := ""+space(06)
		cLinDeImp += "TOTAL DAS FILIAIS PARA ESSA TRANSPORTADORA ......"+space(02)
		cLinDeImp += u_rtoc(nSubTotVAC)
		@ nL,000 PSay cLinDeImp
		nL += 4
	endif
endif

nL++
cLinDeImp := ""
cLinDeImp += "TOTAL GERAL ..........................................."+space(02)
cLinDeImp += u_rtoc(nTotGerVAC)
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