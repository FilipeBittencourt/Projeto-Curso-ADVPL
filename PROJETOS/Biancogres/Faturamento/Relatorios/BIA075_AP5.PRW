#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/
#include "relato.ch"
#include "topconn.ch"
#include "buttom.ch"

user function bia075()

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declaracao de variaveis utilizadas no programa atraves da funcao    Ё
	//Ё SetPrvt, que criara somente as variaveis definidas pelo usuario,    Ё
	//Ё identificando as variaveis publicas do sistema utilizadas no codigo Ё
	//Ё Incluido pelo assistente de conversao do AP5 IDE                    Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	SetPrvt("CNOMEPROG,CNOMEARQ,CTAMANHO,CTITULO,CDESC1,CDESC2,NLIMITEINF")
	SetPrvt("CDESC3,ARETURN,ALINHA,AORDEM,LPODECOMP,LTEMDIC")
	SetPrvt("LGRAVPARAM,NLASTKEY,CERRO,LERRO,NERRO,CCBTXT,NQUANT")
	SetPrvt("NCBCONT,CALIAS,NL,M_PAG,CCABEC1,CCABEC2,CLOCALIZ")
	SetPrvt("LSOMEMP,ACAMPOS")
	SetPrvt("CARQTEMP1,CARQTEMP2,CARQTEMP3,CNOMEPROD,CTIPO,CQUANT,NSUBTESTBRT,NSUBTFATNEB")
	SetPrvt("NSUBTEMPME,NSUBTEMPMI,NSUBTEMPNG,NSUBTESTLIQ,NSUBTDSPVND,NTOTESTBRT")
	SetPrvt("NTOTFATNEB,NTOTEMPME,NTOTEMPMI,NTOTEMPNG,NTOTESTLIQ,NTOTDSPVND,NLASTKEY")
	SetPrvt("APRODUTOS")
	SetPrvt("CAUX,CSTRING,COLDALIAS,CPERGUNTA,CMSG,CPRODATU")
	SetPrvt("CLINDIVISORIA,CPRODUTOS,CLOCATU,CPRODATU,CDADOS,CQUEREY,CNOMECLI,CCODCLI")
	SetPrvt("NTOTREGS,NI,NPOSC,LOK,")

	/*/
	╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
	╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
	╠╠ЁFun┤└o	 Ё BIA075	  Ё Autor Ё WLADIMIR ILLIUSHENKO  Ё Data Ё 06/12/00 Ё╠╠
	╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
	╠╠ЁDescri┤└o Ё RELATORIO DE POSICAO DETALHADA DA EXPEDICAO	   			    Ё╠╠
	╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
	╠╠Ё Uso		 Ё SIGAEST												        Ё╠╠
	╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
	╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
	ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
	/*/

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Declaracao de variaveis									                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cNomeProg   := "BIA075"
	cNomeArq    := cNomeProg
	cTitulo	   := "Posicao Detalhada da Expedicao "
	cDesc1	   := "Emite a Posicao Detalhada da Expedicao.                    "
	cDesc2	   := "                                                           "
	cDesc3	   := "                                                           "
	aReturn	   := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	aLinha	   := {}
	aOrdem	   := {}
	lPodeComp   := .T.
	lTemDic	   := .F.
	lGravParam  := .F.
	cAlias	   := "SF2"
	aProdutos   := {}
	nLastKey    := 0

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Envia controle para a funcao SETPRINT.								     Ё
	//Ё Verifica Posicao do Formulario na Impressora.				             Ё
	//Ё Solicita os parametros para a emissao do relatorio			             |
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cNomeArq := SetPrint(cAlias,cNomeProg,cNomeProg,@cTitulo,cDesc1,cDesc2,cDesc3,lTemDic,aOrdem,lPodeComp,cTamanho)
	if LastKey()==27 .OR. nLastKey==27
		Return
	endif

	Pergunte(cNomeProg,lGravParam)
	if LastKey()==27 .OR. nLastKey==27
		Return
	endif

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Pede que o usuario digite a selecao de produtos caso ele opte por este...Ё
	//Ё parametro.                                                               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	if MV_PAR08 == 1
		lOk       := .T.
		cProdutos := ""
		do while lOk
			@ 000,000 TO 150,350 DIALOG oDialog TITLE "Selecao"
			@ 005,005 SAY "Digite abaixo, separando por ';', cada produto que deseja pesquisar."
			@ 020,005 GET cProdutos SIZE 130,050 MEMO
			@ 060,140 BMPBUTTON TYPE BT_OK ACTION fFinaliza()
			ACTIVATE DIALOG oDialog CENTERED
		enddo
		if len(aProdutos) == 0
			cMsg := ""
			cMsg += "O parametro 'SELECIONAR PRODUTOS' esta configurado como 'SIM',"+chr(13)
			cMsg += "portanto se faz necessaria a digitacao dos produtos no quadro "+chr(13)
			cMsg += "anterior."
			alert(cMsg)
			return
		endif
	endif

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicio da geracao do relatorio.                                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SetDefault(aReturn,cAlias)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Aceita par┐metros e faz ajustes necess═rios.                           Ё
	//цддддддддддбддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
	//Ё mv_par01 Ё Do  Produto 												   Ё
	//Ё mv_par02 Ё Ate Produto 												   Ё
	//Ё mv_par03 Ё Da  Localizacao											   Ё
	//Ё mv_par04 Ё Ate Localizacao											   Ё
	//Ё mv_par05 Ё Filtragem      											   Ё
	//Ё mv_par06 Ё Incluir romaneio	                                           Ё
	//Ё mv_par07 Ё Tipo do relatorio (Analitico ou Sintetico) 				   Ё
	//Ё mv_par08 Ё Utilizar arq. de selecao de produtos (\SIGAADV\SELPROD.TXT) Ё
	//Ё mv_par09 Ё              											   Ё
	//Ё mv_par10 Ё               											   Ё
	//Ё mv_par11 Ё Do Lote      											   Ё
	//Ё mv_par12 Ё Ate Lote      											   Ё
	//юддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	do case
		case MV_PAR05 == 1; lEmp := .F.; lFNE := .F. && Filtra Nenhum
		case MV_PAR05 == 2; lEmp := .T.; lFNE := .F. && Filtra Somente Empenho
		case MV_PAR05 == 3; lEmp := .F.; lFNE := .T. && Filtra Somente Faturado Nao Embarcado
	endcase

	lImpRom := iif(MV_PAR06==1,.T.,.F.)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Variaveis utilizadas para impressao.                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	do case
		case MV_PAR07 == 1 && Relatorio Analitico por Rua
		lRelAnalitico  := .T.
		lRelSintetico  := .F.
		cTitulo	      := cTitulo + " (Analitico por Rua)"
		nCrcControl    := iif(aReturn[4]==1,15,18)
		cTamanho       := "G"
		cCbTxt	      := SPACE(10)
		nCbCont	      := 0
		nL 		      := 80
		m_pag 	      := 1
		cCabec1	      := "LOCALIZACAO      PRODUTO     DESCRICAO-RESUMIDA                                                 ESTOQUE         ESTOQUE 	   FATURADO N.  QTD EMPEN.(M2)        ESTOQUE      DISPONIVEL"
		cCabec2	      := "                                                                                             BRUTO (M2)      BRUTO (CX)   EMBARCADO (M2)  EM NEGOCIACAO     LIQUIDO (M2)   P/ VENDA (M2)"
		//XXXXXXX			 XXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXX.XXX.XXX,XX  XXX.XXX.XXX,XX	XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX	XXX.XXX.XXX,XX  XXX.XXX.XXX,XX

		case MV_PAR07 == 2 && Relatorio Analatico por Produto
		lRelAnalitico  := .T.
		lRelSintetico  := .F.
		cTitulo	      := cTitulo + " (Analitico por Produto)"
		cTamanho       := "G"
		nCrcControl    := iif(aReturn[4]==1,15,18)
		cCbTxt	      := SPACE(10)
		nCbCont	      := 0
		nL 		      := 80
		m_pag 	      := 1
		cCabec1	      := "PRODUTO     DESCRICAO-RESUMIDA                                                                  ESTOQUE     FATURADO N.  ---------- QUANTIDADE EMPENHADA (M2) ---------          ESTOQUE      DISPONIVEL"
		cCabec2	      := "            LOCALIZACAO                                                                      BRUTO (M2)  EMBARCADO (M2)    MERCADO EXT.    MERCADO INT.   EM NEGOCIACAO     LIQUIDO (M2)   P/ VENDA (M2)"
		//XXXXXXXXXXX..XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		//XXXXXXX.................................................. XXX.XXX.XXX,XX  XXX.XXX.XXX,XX	XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX	XXX.XXX.XXX,XX  XXX.XXX.XXX,XX

		case MV_PAR07 == 3 && Relatorio Sitentico por Romaneio
		lRelAnalitico  := .F.
		lRelSintetico  := .T.
		cTitulo	      := cTitulo + " (Sintetico - Somente Romaneios)"
		cTamanho       := "M"
		nCrcControl    := iif(aReturn[4]==1,15,18)
		cCbTxt	      := SPACE(10)
		nCbCont	      := 0
		nL 		      := 80
		m_pag 	      := 1
		cCabec1	      := "ROMANEIO  LOCALIZACAO      CLIENTE--------------------------  PRODUTO------------------------------------  QUANTIDADE---------------"
		cCabec2	      := "                           CODIGO     NOME                    CODIGO       DESCRICAO                               M2        PALETES"
		//XXXXXXXX..XXXXXXXXXXXXXXX..XXXXXX-XX..XXXXXXXXXXXXXXXXXXXXX..XXXXXXXXXXX..XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX...XXX.XXX,XX..XXXXXXXXXXXXX

		case MV_PAR07 == 4 && Relatorio Sitentico por Produto
		lRelAnalitico  := .F.
		lRelSintetico  := .T.
		cTitulo	      := "Pos.Det.Exp. (Sintetico por Produto)"
		cTamanho       := "P"
		nCrcControl    := iif(aReturn[4]==1,15,18)
		cCbTxt	      := SPACE(10)
		nCbCont	      := 0
		nL 		      := 80
		m_pag 	      := 1
		cCabec1	      := "PRODUTO                                                 "
		cCabec2	      := "TON/CAL  LOCALIZACAO----  -------ESTOQUE ---DISP.P/VENDA"
		//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		//XXXXX....XXXXXXXXXXXXXXX..XXX.XXX.XXX,XX..XXX.XXX.XXX,XX
	endcase

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Rotinas.                                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Processa({|| fCriaTemp()})
	Processa({|| fAcumula() })
	do case
		case MV_PAR07 <= 2; Processa({|| fImpAnalitico() })
		case MV_PAR07 >= 3; Processa({|| fImpSintetico() })
	endcase
	Processa({|| fApagaTemp()})

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se a impress└o for em Disco, chama SPOOL                               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	if aReturn[5]==1
		Set Printer to
		Commit
		OurSpool(cNomeArq)
	endif

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Libera relatorio para Spool da Rede                                    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Ft_PFlush()
Return

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбддддддддддддддддддддддддддддддддддддддддд©╠╠
╠╠ЁFuncao	 Ё fCriaTempЁ Autor Ё WLADIMIR ILLIUSHENKO                    Ё╠╠
╠╠цддддддддддеддддддддддадддддддаддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁDescricao Ё Cria uma tabela temporaria para preparacao do relatorio.   Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		 Ё BIA075                                                     Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function fCriaTemp()

	//**
	//***** TEMPORARIO 01
	//**
	aCampos := {}
	AADD(aCampos, {"PRODUTO   ", "C", 15, 0})
	AADD(aCampos, {"DESCRICAO ", "C", 30, 0})
	AADD(aCampos, {"TONCAL    ", "C", 10, 0})
	AADD(aCampos, {"LOCALIZ   ", "C", 15, 0})
	AADD(aCampos, {"QESTBRUTO ", "N", 12, 2})
	AADD(aCampos, {"QESTBRUCX ", "N", 12, 2})
	AADD(aCampos, {"QFATNEMB  ", "N", 12, 2})
	AADD(aCampos, {"QEMPME    ", "N", 12, 2})
	AADD(aCampos, {"QEMPMI    ", "N", 12, 2})
	AADD(aCampos, {"QEMPNG    ", "N", 12, 2})
	AADD(aCampos, {"QTOTEMP   ", "N", 12, 2})
	AADD(aCampos, {"QESTLIQ   ", "N", 12, 2})
	AADD(aCampos, {"QDISPVENDA", "N", 12, 2})

	cArqTemp1 := CriaTrab(aCampos, .T.)
	DbUseArea(.T.,,cArqTemp1,"REL")
	DbCreateInd(cArqTemp1+".001","PRODUTO+TONCAL+LOCALIZ",{||PRODUTO+TONCAL+LOCALIZ})
	OrdListClear()
	OrdListAdd(cArqTemp1+".001")

	//**
	//***** TEMPORARIO 02
	//**

	aCampos := {}
	AADD(aCampos, {"LOCALIZ   ", "C", 15, 0})
	AADD(aCampos, {"PRODUTO   ", "C", 15, 0}) 
	AADD(aCampos, {"TONCAL    ", "C", 10, 0})
	AADD(aCampos, {"ROMANEIO  ", "C", 08, 0})
	AADD(aCampos, {"DESCRICAO ", "C", 30, 0})
	AADD(aCampos, {"TOTAL     ", "N", 12, 2})
	AADD(aCampos, {"CODCLI    ", "C", 09, 0})
	AADD(aCampos, {"DESCLI    ", "C", 20, 0})

	cArqTemp2 := CriaTrab(aCampos, .T.)
	DbUseArea(.T.,,cArqTemp2,"RMN")
	DbCreateInd(cArqTemp2+".001","PRODUTO+TONCAL+LOCALIZ+ROMANEIO",{||PRODUTO+TONCAL+LOCALIZ+ROMANEIO})
	DbCreateInd(cArqTemp2+".002","ROMANEIO+LOCALIZ",{||ROMANEIO+LOCALIZ})
	OrdListClear()
	OrdListAdd(cArqTemp2+".001")
	OrdListAdd(cArqTemp2+".002")
Return

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбддддддддддддддддддддддддддддддддддддддддд©╠╠
╠╠ЁFuncao	 Ё fAcumula Ё Autor Ё WLADIMIR ILLIUSHENKO					  Ё╠╠
╠╠цддддддддддеддддддддддадддддддаддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁDescricao Ё 														      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		 Ё BIA075													  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function fAcumula()
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Reconfigura os indices das tabelas necessarias.                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	SB1->(DbSetOrder(1))
	SF1->(DbSetOrder(1))
	SF2->(DbSetOrder(9)) 
	//SF2->(DbSetOrder(10))
	SD1->(DbSetOrder(11))
	SD2->(DbSetOrder(3))
	SC6->(DbSetOrder(1))
	SZ9->(DbSetOrder(1))
	SZ7->(DbSetOrder(2))
	RMN->(DBSetOrder(1))

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Analiza as reservar dos produtos indicados nos parametros.             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	fSelSBF()

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Analiza os produtos encontrados em busca de produtos Faturados e Nao.. Ё
	//Ё Embarcados.		TEM 3 QUERY  										   |
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	fSelSF2()

Return


/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддддддддддддддддддд©╠╠
╠╠ЁFuncao	 	 ЁfSelecionaSBFЁ Autor Ё WLADIMIR ILLIUSHENKO 			      Ё╠╠
╠╠цддддддддддедддддддддддддадддддддадддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁDescricao Ё Seleciona os registro no SBF que satisfacam os parametros. Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		   Ё BIA075													  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function fSelSBF()
	cQuery  := ""
	cQuery  := cQuery + "SELECT COUNT(SBF.BF_PRODUTO) AS TOTREGS "
	cQuery  := cQuery + "FROM "+RetSqlName("SBF")+" SBF "
	cQuery  := cQuery + "WHERE (RTRIM(SBF.BF_FILIAL)  =  RTRIM('"+xFilial("SBF")+"')) AND "
	cQuery  := cQuery + "      (RTRIM(SBF.BF_PRODUTO) >= RTRIM('"+MV_PAR01+"')) AND "
	cQuery  := cQuery + "      (RTRIM(SBF.BF_PRODUTO) <= RTRIM('"+MV_PAR02+"')) AND "
	if MV_PAR08 == 1
		cQuery := cQuery + "      (RTRIM(SBF.BF_PRODUTO) IN ("+cProdutos+")) AND "
	endif
	cQuery  := cQuery + "      (RTRIM(SBF.BF_LOCALIZ) >= RTRIM('"+MV_PAR03+"')) AND "
	cQuery  := cQuery + "      (RTRIM(SBF.BF_LOCALIZ) <= RTRIM('"+MV_PAR04+"')) AND "
	cQuery  := cQuery + "      (RTRIM(SBF.BF_LOTECTL) >= RTRIM('"+MV_PAR11+"')) AND "
	cQuery  := cQuery + "      (RTRIM(SBF.BF_LOTECTL) <= RTRIM('"+MV_PAR12+"')) AND "
	cQuery  := cQuery + iif(lEmp," (SBF.BF_EMPENHO > 0) AND ","")
	cQuery  := cQuery + "      (SBF.D_E_L_E_T_ <> '*')"
	TCQuery cQuery Alias "X" New
	nTotRegs := X->TOTREGS
	X->(DbCloseArea())

	if nTotRegs > 0
		cQuery  := ""
		cQuery  := cQuery + "SELECT "
		cQuery  := cQuery + "       SBF.BF_PRODUTO, " 
		cQuery  := cQuery + "       SBF.BF_LOTECTL, "	
		cQuery  := cQuery + "       SBF.BF_LOCALIZ, "
		cQuery  := cQuery + "       SBF.BF_QUANT,   "
		cQuery  := cQuery + "       SBF.BF_EMPENHO  "
		cQuery  := cQuery + "FROM "+RetSqlName("SBF")+" SBF "
		cQuery  := cQuery + "WHERE (RTRIM(SBF.BF_FILIAL)  =  RTRIM('"+xFilial("SBF")+"')) AND "
		cQuery  := cQuery + "      (RTRIM(SBF.BF_PRODUTO) >= RTRIM('"+MV_PAR01+"')) AND "
		cQuery  := cQuery + "      (RTRIM(SBF.BF_PRODUTO) <= RTRIM('"+MV_PAR02+"')) AND "
		if MV_PAR08 == 1
			cQuery := cQuery + "      (RTRIM(SBF.BF_PRODUTO) IN ("+cProdutos+")) AND "
		endif
		cQuery  := cQuery + "      (RTRIM(SBF.BF_LOCALIZ) >= RTRIM('"+MV_PAR03+"')) AND "
		cQuery  := cQuery + "      (RTRIM(SBF.BF_LOCALIZ) <= RTRIM('"+MV_PAR04+"')) AND "
		cQuery  := cQuery + "      (RTRIM(SBF.BF_LOTECTL) >= RTRIM('"+MV_PAR11+"')) AND "
		cQuery  := cQuery + "      (RTRIM(SBF.BF_LOTECTL) <= RTRIM('"+MV_PAR12+"')) AND "	
		cQuery  := cQuery + iif(lEmp," (SBF.BF_EMPENHO > 0) AND ","")
		cQuery  := cQuery + "      (SBF.D_E_L_E_T_ <> '*')"
		TCQuery cQuery Alias "QRY" New

		ProcRegua(nTotRegs)
		do while !QRY->(EOF())

			IncProc("Localizando reservas...")

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se o produto existe na descricao generica de produtos.		   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			SB1->(DbSeek(xFilial("SB1")+QRY->BF_PRODUTO,.T.))
			cNomeProd := SB1->B1_DESC
			if SB1->B1_COD#QRY->BF_PRODUTO
				cNomeProd := "PRODUTO INEXISTENTE NO SB1!..."
			else
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica se o produto encontrado e um produto acabado.         		   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				if SB1->B1_TIPO # 'PA'
					QRY->(DBSkip())
					Loop
				endif
			endif

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se o produto ja existe na tabela temporaria.                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if !REL->(DbSeek(QRY->BF_PRODUTO+QRY->BF_LOTECTL+QRY->BF_LOCALIZ,.T.))
				RecLock("REL",.T.)
				REL->PRODUTO	:= QRY->BF_PRODUTO
				REL->DESCRICAO  := cNomeProd
				REL->TONCAL     := QRY->BF_LOTECTL
				REL->LOCALIZ	:= QRY->BF_LOCALIZ
				REL->QESTLIQ	:= QRY->BF_QUANT

				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Calcula o Saldo Disponivel e o Estoque Bruto.                            Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+REL->PRODUTO,.F.)
				REL->QESTBRUTO   := REL->QESTLIQ + REL->QFATNEMB
				REL->QESTBRUCX   := REL->QESTBRUTO/SB1->B1_CONV
				REL->QDISPVENDA  := REL->QESTLIQ - REL->QTOTEMP
				REL->(DbUnlock())
			endif

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se existem reservas para este produto. Se sim analisa cada ...Ё
			//Ё uma delas. 															   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if QRY->BF_EMPENHO > 0
				cQuery  := ""
				cQuery  := cQuery + "SELECT "
				cQuery  := cQuery + "       SC0.C0_PRODUTO, "
				cQuery  := cQuery + "       SC0.C0_TIPO,    "
				cQuery  := cQuery + "       SC0.C0_SOLICIT, "
				cQuery  := cQuery + "       SC0.C0_QUANT    "
				cQuery  := cQuery + "FROM "+RetSqlName("SC0")+" SC0 "
				cQuery  := cQuery + "WHERE (RTRIM(SC0.C0_FILIAL)  = RTRIM('"+xFilial("SC0")+"'))  AND "
				cQuery  := cQuery + "      (RTRIM(SC0.C0_PRODUTO) = RTRIM('"+QRY->BF_PRODUTO+"')) AND "
				cQuery  := cQuery + "      (RTRIM(SC0.C0_LOCALIZ) = RTRIM('"+QRY->BF_LOCALIZ+"')) AND "
				cQuery  := cQuery + "      (SC0.D_E_L_E_T_ <> '*')"
				TCQuery cQuery Alias "QRY2" New

				do while !QRY2->(EOF())
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Determina o tipo do empenho. 							     		   Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cTipo := "MI"
					if (QRY2->C0_TIPO == "CL") .AND. (SubStr(QRY2->C0_SOLICIT,1,2) == "EX")
						cTipo := "ME"
					else
						if QRY2->C0_TIPO == "VD"
							cTipo := "NG"
						endif
					endif

					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Grava os dados obtidos no arquivo temporario.                          Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					DbSelectArea("REL")
					DbSetOrder(1)
					if REL->(DbSeek(QRY->BF_PRODUTO+QRY->BF_LOTECTL+QRY->BF_LOCALIZ,.T.))
						RecLock("REL",.F.)
						REL->QEMPMI  := REL->QEMPMI  + iif(cTipo=="MI",QRY2->C0_QUANT,0)
						REL->QEMPME  := REL->QEMPME  + iif(cTipo=="ME",QRY2->C0_QUANT,0)
						REL->QEMPNG  := REL->QEMPNG  + iif(cTipo=="NG",QRY2->C0_QUANT,0)
						REL->QTOTEMP := REL->QTOTEMP + QRY2->C0_QUANT

						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Calcula o Saldo Disponivel e o Estoque Bruto.                            Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						DbSelectArea("SB1")
						DbSetOrder(1)
						DbSeek(xFilial("SB1")+REL->PRODUTO,.F.)
						REL->QESTBRUTO  := REL->QESTLIQ + REL->QFATNEMB
						REL->QESTBRUCX := REL->QESTBRUTO/SB1->B1_CONV
						REL->QDISPVENDA := REL->QESTLIQ - REL->QTOTEMP
						REL->(DbUnlock())
					endif

					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Posiciona-se na proxima reserva.                                       Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					QRY2->(DbSkip())
				enddo
				QRY2->(DBCloseArea())
			endif

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Posiciona-se no proximo empenho.                                       Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			QRY->(DbSkip())
		enddo
		QRY->(DbCloseArea())
	endif
Return

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддддддддддддддддддд©╠╠
╠╠ЁFuncao	 ЁfSelecionaSF2Ё Autor Ё WLADIMIR ILLIUSHENKO                 Ё╠╠
╠╠цддддддддддедддддддддддддадддддддадддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁDescricao Ё Analiza os produtos encontrados em busca de produtos ...   Ё╠╠
╠╠Ё          Ё faturados e nao embarcados.                                Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		 Ё BIA075                                                     Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function fSelSF2()
	cQuery  := ""
	cQuery  := cQuery + "SELECT COUNT(SF2.F2_DOC) AS TOTREGS "
	cQuery  := cQuery + "FROM "+RetSqlName("SF2")+" SF2 "
	cQuery  := cQuery + "WHERE (RTRIM(SF2.F2_FILIAL) = RTRIM('"+xFilial("SF2")+"')) AND "
	cQuery  := cQuery + "      (RTRIM(SF2.F2_YDES)   = '')                           AND "
	cQuery  := cQuery + "      (RTRIM(SF2.F2_SERIE)  >= RTRIM('"+MV_PAR09+"')   )    AND " && Somente faturas com numero de pedido.
	cQuery  := cQuery + "      (RTRIM(SF2.F2_SERIE)  <= RTRIM('"+MV_PAR10+"')   )    AND " && Somente faturas com numero de pedido.
	cQuery  := cQuery + ""
	cQuery  := cQuery + "      (SF2.F2_DOC+SF2.F2_SERIE NOT IN ( " && Somente NFs que nao foram devolvidas.
	cQuery  := cQuery + "      SELECT SD1.D1_NFORI+SD1.D1_SERIORI "
	cQuery  := cQuery + "      FROM "+RetSqlName("SD1")+" SD1 "                          
	cQuery  := cQuery + "      WHERE                                "
	cQuery  := cQuery + "           (SD1.D1_NFORI   = SF2.F2_DOC  ) AND "
	cQuery  := cQuery + "           (SD1.D1_SERIORI = SF2.F2_SERIE) AND "
	cQuery  := cQuery + "           (SD1.D_E_L_E_T_ <> '*' )        )) AND "
	cQuery  := cQuery + ""
	cQuery  := cQuery + "      (SF2.F2_DOC+SF2.F2_SERIE IN (  " && Somente NFs de produtos informados nos parametros.
	cQuery  := cQuery + "      SELECT SD2.D2_DOC+SD2.D2_SERIE "
	cQuery  := cQuery + "      FROM "+RetSqlName("SD2")+" SD2 "
	cQuery  := cQuery + "      WHERE                                "
	cQuery  := cQuery + "           (SD2.D2_FILIAL  = RTRIM('"+xFilial("SD2")+"') ) AND "
	cQuery  := cQuery + "           (SD2.D2_DOC     = SF2.F2_DOC                ) AND "
	cQuery  := cQuery + "           (SD2.D2_SERIE   = SF2.F2_SERIE              ) AND "
	cQuery  := cQuery + "           (RTRIM(SD2.D2_COD) >= RTRIM('"+MV_PAR01+"')   ) AND "
	cQuery  := cQuery + "           (RTRIM(SD2.D2_COD) <= RTRIM('"+MV_PAR02+"')   ) AND "
	cQuery  := cQuery + "           (RTRIM(SD2.D2_LOTECTL) >= RTRIM('"+MV_PAR11+"')   ) AND "
	cQuery  := cQuery + "           (RTRIM(SD2.D2_LOTECTL) <= RTRIM('"+MV_PAR12+"')   ) AND "
	if MV_PAR08 == 1
		cQuery := cQuery + "      (RTRIM(SD2.D2_COD) IN ("+cProdutos+")) AND "
	endif
	cQuery  := cQuery + "           (SD2.D_E_L_E_T_ <> '*' )        ))               AND "
	cQuery  := cQuery + ""
	cQuery  := cQuery + "      ((  "                                 && Somente NFs que nao sejam de complemento.
	cQuery  := cQuery + "      SELECT SUM(SD2.D2_QUANT) "
	cQuery  := cQuery + "      FROM "+RetSqlName("SD2")+" SD2 "
	cQuery  := cQuery + "      WHERE                                "
	cQuery  := cQuery + "           (SD2.D2_FILIAL  = RTRIM('"+xFilial("SD2")+"') ) AND "
	cQuery  := cQuery + "           (SD2.D2_DOC     = SF2.F2_DOC                ) AND "
	cQuery  := cQuery + "           (SD2.D2_SERIE   = SF2.F2_SERIE              ) AND "
	cQuery  := cQuery + "           (SD2.D_E_L_E_T_ <> '*' ))   > 0)                 AND "
	cQuery  := cQuery + ""
	cQuery  := cQuery + "      (SF2.D_E_L_E_T_ <> '*')"
	TCQuery cQuery Alias "X" New
	nTotRegs := X->TOTREGS
	X->(DbCloseArea())

	if nTotRegs > 0
		cQuery  := ""
		cQuery  := cQuery + "SELECT "
		cQuery  := cQuery + "     SF2.F2_DOC,     "
		cQuery  := cQuery + "     SF2.F2_SERIE,   "
		cQuery  := cQuery + "     SF2.F2_CLIENTE, "
		cQuery  := cQuery + "     SF2.F2_LOJA,    "
		cQuery  := cQuery + "     SF2.F2_YAGREG,   " 
		cQuery  := cQuery + "     SF2.F2_YSUBTP   "	
		cQuery  := cQuery + "FROM "+RetSqlName("SF2")+" SF2 "
		cQuery  := cQuery + "WHERE (RTRIM(SF2.F2_FILIAL) = RTRIM('"+xFilial("SF2")+"')) AND "
		cQuery  := cQuery + "      (RTRIM(SF2.F2_YDES)   = '')                           AND "
		cQuery  := cQuery + "      (RTRIM(SF2.F2_SERIE)   >= RTRIM('"+MV_PAR09+"')   )   AND " && Somente faturas com numero de pedido.
		cQuery  := cQuery + "      (RTRIM(SF2.F2_SERIE)   <= RTRIM('"+MV_PAR10+"')   )   AND " && Somente faturas com numero de pedido.
		cQuery  := cQuery + ""
		cQuery  := cQuery + "      (SF2.F2_DOC+SF2.F2_SERIE NOT IN ( " && Somente NFs que nao foram devolvidas.
		cQuery  := cQuery + "      SELECT SD1.D1_NFORI+SD1.D1_SERIORI "
		cQuery  := cQuery + "      FROM "+RetSqlName("SD1")+" SD1 "
		cQuery  := cQuery + "      WHERE                                "
		cQuery  := cQuery + "           (SD1.D1_NFORI   = SF2.F2_DOC  ) AND "
		cQuery  := cQuery + "           (SD1.D1_SERIORI = SF2.F2_SERIE) AND "
		cQuery  := cQuery + "           (SD1.D_E_L_E_T_ <> '*' )        )) AND "
		cQuery  := cQuery + ""
		cQuery  := cQuery + "      (SF2.F2_DOC+SF2.F2_SERIE IN (  " && Somente NFs de produtos informados nos parametros.
		cQuery  := cQuery + "      SELECT SD2.D2_DOC+SD2.D2_SERIE "
		cQuery  := cQuery + "      FROM "+RetSqlName("SD2")+" SD2 "
		cQuery  := cQuery + "      WHERE                                "
		cQuery  := cQuery + "           (SD2.D2_FILIAL  = RTRIM('"+xFilial("SD2")+"') ) AND "
		cQuery  := cQuery + "           (SD2.D2_DOC     = SF2.F2_DOC                ) AND "
		cQuery  := cQuery + "           (SD2.D2_SERIE   = SF2.F2_SERIE              ) AND "
		cQuery  := cQuery + "           (RTRIM(SD2.D2_COD) >= RTRIM('"+MV_PAR01+"')   ) AND "
		cQuery  := cQuery + "           (RTRIM(SD2.D2_COD) <= RTRIM('"+MV_PAR02+"')   ) AND "
		cQuery  := cQuery + "           (RTRIM(SD2.D2_LOTECTL) >= RTRIM('"+MV_PAR11+"')   ) AND "
		cQuery  := cQuery + "           (RTRIM(SD2.D2_LOTECTL) <= RTRIM('"+MV_PAR12+"')   ) AND "
		if MV_PAR08 == 1
			cQuery := cQuery + "      (RTRIM(SD2.D2_COD) IN ("+cProdutos+")) AND "
		endif
		cQuery  := cQuery + "           (SD2.D_E_L_E_T_ <> '*' )        ))               AND "
		cQuery  := cQuery + ""
		cQuery  := cQuery + "      ((  "                                 && Somente NFs que nao sejam de complemento.
		cQuery  := cQuery + "      SELECT SUM(SD2.D2_QUANT) "
		cQuery  := cQuery + "      FROM "+RetSqlName("SD2")+" SD2 "
		cQuery  := cQuery + "      WHERE                                "
		cQuery  := cQuery + "           (SD2.D2_FILIAL  = RTRIM('"+xFilial("SD2")+"') ) AND "
		cQuery  := cQuery + "           (SD2.D2_DOC     = SF2.F2_DOC                ) AND "
		cQuery  := cQuery + "           (SD2.D2_SERIE   = SF2.F2_SERIE              ) AND "
		cQuery  := cQuery + "           (SD2.D_E_L_E_T_ <> '*' ))   > 0)                 AND "
		cQuery  := cQuery + ""
		cQuery  := cQuery + "      (SF2.D_E_L_E_T_ <> '*') "
		cQuery  := cQuery + ""
		cQuery  := cQuery + "ORDER BY SF2.F2_DOC "
		TCQuery cQuery Alias "QRY" New

		ProcRegua(nTotRegs)
		do while !QRY->(EOF())

			IncProc("Localizando produtos faturados e nao embarcados...")

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Localiza o nome do cliente.                                    		   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if SA1->(DbSeek(xFilial("SA1")+QRY->F2_CLIENTE+QRY->F2_LOJA))
				cNomeCli := SUBS(SA1->A1_NOME,1,20)
			else
				cNomeCli := "CLIENTE NAO LOCALIZADO!"
			endif

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Localiza os produtos da NF atual.                              		   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cQuery  := ""
			cQuery  := cQuery + "SELECT "
			cQuery  := cQuery + "       SD2.D2_COD,                      "
			cQuery  := cQuery + "       MIN(SD2.D2_PEDIDO) AS D2_PEDIDO, "
			cQuery  := cQuery + "       MIN(SD2.D2_ITEMPV) AS D2_ITEMPV  "
			cQuery  := cQuery + "FROM "+RetSqlName("SD2")+" SD2 "
			cQuery  := cQuery + "WHERE (RTRIM(SD2.D2_FILIAL)  =  RTRIM('"+xFilial("SD2")+"')) AND "
			cQuery  := cQuery + "      (RTRIM(SD2.D2_DOC)     =  RTRIM('"+QRY->F2_DOC+"')   ) AND "
			cQuery  := cQuery + "      (RTRIM(SD2.D2_SERIE)   <= RTRIM('"+QRY->F2_SERIE+"') ) AND "
			cQuery  := cQuery + "      (RTRIM(SD2.D2_COD)     >= RTRIM('"+MV_PAR01+"')       ) AND "
			cQuery  := cQuery + "      (RTRIM(SD2.D2_COD)     <= RTRIM('"+MV_PAR02+"')       ) AND "
			cQuery  := cQuery + "      (RTRIM(SD2.D2_LOTECTL) >= RTRIM('"+MV_PAR11+"')       ) AND "
			cQuery  := cQuery + "      (RTRIM(SD2.D2_LOTECTL) <= RTRIM('"+MV_PAR12+"')       ) AND "
			if MV_PAR08 == 1
				cQuery := cQuery + "      (RTRIM(SD2.D2_COD) IN ("+cProdutos+")) AND "
			endif
			cQuery  := cQuery + "      (SD2.D_E_L_E_T_ <> '*') "
			cQuery  := cQuery + "GROUP BY SD2.D2_COD "
			TCQuery cQuery Alias "QRY2" New

			do while !QRY2->(EOF())

				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verifica se o produto existe na descricao generica de produtos.		   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				if SB1->(DbSeek(xFilial("SB1")+QRY2->D2_COD,.T.))
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verifica se o produto encontrado e um produto acabado.         		   Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					if SB1->B1_TIPO # 'PA'
						QRY2->(DBSkip())
						Loop
					else
						cNomeProd := SB1->B1_DESC
					endif
				else
					cNomeProd := "PRODUTO INEXISTENTE NO SB1!..."
				endif

				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Verfica se existe pedido para este produto.	                   Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				DbSelectArea("REL")
				DbSetOrder(1)
				if SC6->(DbSeek(xFilial("SC6")+QRY2->D2_PEDIDO+QRY2->D2_ITEMPV+QRY2->D2_COD))
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Verifica se o produto em questao e um produto de amostra. Se ..Ё
					//Ё for, grava no relatorio a localizacao dada no pedido.          Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					//if substr(QRY2->D2_COD,1,4) == '0000' 
					//Alterado por Wanisay em 14/11/12
					if ALLTRIM(QRY->F2_YSUBTP) == 'A'				
						if REL->(DbSeek(QRY2->D2_COD+SC6->C6_LOTECTL+SC6->C6_LOCALIZ,.T.))
							RecLock("REL",.F.)
							REL->QFATNEMB := REL->QFATNEMB+SC6->C6_QTDLIB
						else
							RecLock("REL",.T.)
							REL->PRODUTO    := QRY2->D2_COD
							REL->DESCRICAO  := cNomeProd
							REL->TONCAL     := SC6->C6_LOTECTL
							REL->LOCALIZ    := SC6->C6_LOCALIZ
							REL->QFATNEMB   := SC6->C6_QTDLIB
						endif

						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Calcula o Saldo Disponivel e o Estoque Bruto.                            Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						DbSelectArea("SB1")
						DbSetOrder(1)
						DbSeek(xFilial("SB1")+REL->PRODUTO,.F.)
						REL->QESTBRUTO  := REL->QESTLIQ + REL->QFATNEMB
						REL->QESTBRUCX  := REL->QESTBRUTO/SB1->B1_CONV
						REL->QDISPVENDA := REL->QESTLIQ - REL->QTOTEMP
						REL->(DbUnLock())

					else
						//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						//Ё Verifica se existe o romaneio descrito no cabecalho da NF.  .. Ё
						//Ё Se sim grava no relatorio todas a localizacoes relativas ao .. Ё
						//Ё romaneio da NF atual.                                          Ё
						//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						cQuery  := ""
						cQuery  := cQuery + "SELECT "
						cQuery  := cQuery + "       SZ9.Z9_NUMERO,  "
						cQuery  := cQuery + "       SZ9.Z9_LOCALIZ, " 
						cQuery  := cQuery + "       SZ9.Z9_LOTECTL, "					
						cQuery  := cQuery + "       SZ9.Z9_QTDLIB   "
						cQuery  := cQuery + "FROM "+RetSqlName("SZ9")+" SZ9 "
						cQuery  := cQuery + "WHERE (RTRIM(SZ9.Z9_FILIAL)  =  RTRIM('"+xFilial("SZ9")+"')) AND "
						cQuery  := cQuery + "      (RTRIM(SZ9.Z9_NUMERO)  =  RTRIM('"+QRY->F2_YAGREG+"')) AND "
						cQuery  := cQuery + "      (RTRIM(SZ9.Z9_PEDIDO)  <= RTRIM('"+QRY2->D2_PEDIDO+"')) AND "
						cQuery  := cQuery + "      (RTRIM(SZ9.Z9_PRODUTO) =  RTRIM('"+QRY2->D2_COD+"')   ) AND "
						cQuery  := cQuery + "      (RTRIM(SZ9.Z9_LOCALIZ) >= RTRIM('"+MV_PAR03+"')       ) AND "
						cQuery  := cQuery + "      (RTRIM(SZ9.Z9_LOCALIZ) <= RTRIM('"+MV_PAR04+"')       ) AND "
						cQuery  := cQuery + "      (RTRIM(SZ9.Z9_LOTECTL) >= RTRIM('"+MV_PAR11+"')       ) AND "
						cQuery  := cQuery + "      (RTRIM(SZ9.Z9_LOTECTL) <= RTRIM('"+MV_PAR12+"')       ) AND "
						cQuery  := cQuery + "      (SZ9.D_E_L_E_T_ <> '*')"
						TCQuery cQuery Alias "QRY3" New
						do while !QRY3->(EOF())

							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Grava dados referentes ao romaneio atual.                              Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							if !RMN->(DBSeek(QRY2->D2_COD+QRY3->Z9_LOTECTL+QRY3->Z9_LOCALIZ+QRY3->Z9_NUMERO,.T.))
								RecLock("RMN",.T.)
								RMN->ROMANEIO  := QRY3->Z9_NUMERO
								RMN->PRODUTO   := QRY2->D2_COD
								RMN->DESCRICAO := cNomeProd
								RMN->LOCALIZ   := QRY3->Z9_LOCALIZ 
								RMN->TONCAL    := QRY3->Z9_LOTECTL							
								RMN->CODCLI    := QRY->F2_CLIENTE+"-"+QRY->F2_LOJA
								RMN->DESCLI    := cNomeCli
								RMN->TOTAL     := QRY3->Z9_QTDLIB
								RMN->(DbUnLock())
							else
								RecLock("RMN",.F.)
								RMN->TOTAL     := RMN->TOTAL + QRY3->Z9_QTDLIB
								RMN->(DbUnLock())
							endif

							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Atualiza no relatorio a quantidade de Produto Faturado e Nao Embarc.   Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							if REL->(DbSeek(QRY2->D2_COD+QRY3->Z9_LOTECTL+QRY3->Z9_LOCALIZ,.T.))
								RecLock("REL",.F.)
								REL->QFATNEMB := REL->QFATNEMB + QRY3->Z9_QTDLIB
							else
								RecLock("REL",.T.)
								REL->PRODUTO   := QRY2->D2_COD
								REL->DESCRICAO := cNomeProd
								REL->TONCAL    := QRY3->Z9_LOTECTL
								REL->LOCALIZ   := QRY3->Z9_LOCALIZ
								REL->QFATNEMB  := QRY3->Z9_QTDLIB
							endif

							//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							//Ё Calcula o Saldo Disponivel e o Estoque Bruto.                            Ё
							//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							DbSelectArea("SB1")
							DbSetOrder(1)
							DbSeek(xFilial("SB1")+REL->PRODUTO,.F.)
							REL->QESTBRUTO  := REL->QESTLIQ + REL->QFATNEMB
							REL->QESTBRUCX := REL->QESTBRUTO/SB1->B1_CONV
							REL->QDISPVENDA := REL->QESTLIQ - REL->QTOTEMP
							REL->(DbUnLock())

							QRY3->(DBSkip())
						enddo
						QRY3->(DbCloseArea())

					endif
				endif

				QRY2->(DbSkip())
			enddo
			QRY2->(DbCloseArea())

			QRY->(DbSkip())
		enddo
		QRY->(DBCloseArea())
	endif
Return

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддддддддддддддддддддд©╠╠
╠╠ЁFuncao	 ЁfImpAnaliticoЁ Autor Ё WLADIMIR ILLIUSHENKO                   Ё╠╠
╠╠цддддддддддедддддддддддддадддддддадддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁDescricao Ё Imprime os dados da tabela temporaria.                       Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function fImpAnalitico()

	Local nI

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicializa variaveis usadas na impressao.                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nSubTEstBrt   := 0
	nSubTEstBCx := 0
	nSubTFatNEB   := 0
	nSubTEmpNG	  := 0
	nSubTEstLiq   := 0
	nSubTDspVnd   := 0
	nTotEstBrt	  := 0
	nTotEstBCx  := 0
	nTotFatNEB	  := 0
	nTotEmpNG	  := 0
	nTotEstLiq	  := 0
	nTotDspVnd	  := 0
	nLimiteInf    := iif(lImpRom,59,66)
	cLinDivisoria := Replicate("-",139)
	cLocAtu		  := "##XX##"
	cProdAtu      := "##XX##" 
	cTonCal       := "##XX##"

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Abre a tabela temporaria.                                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	REL->(DbCloseArea())
	DbUseArea(.T.,,cArqTemp1,"REL")
	if MV_PAR07 == 1
		REL->(DbCreateInd(cArqTemp1+".002","LOCALIZ+PRODUTO+TONCAL",{||LOCALIZ+PRODUTO+RONCAL}))
	else
		REL->(DbCreateInd(cArqTemp1+".001","PRODUTO+TONCAL+LOCALIZ",{||PRODUTO+TONCAL+LOCALIZ}))
	endif
	REL->(DbGoTop())
	ProcRegua(REL->(LastRec()))

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprime parametros.                                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cOldAlias := Alias()
	DBSelectArea("SX1")
	DBSetOrder(1)

	if SX1->(DBSeek(cNomeProg+"01"))
		do while SX1->X1_GRUPO == cNomeProg
			if nL >= 65
				nL := Cabec("Parametros - "+cTitulo,"","",cNomeProg,cTamanho,nCrcControl) + 2
			endif

			cPergunta := ""
			do case
				case SX1->X1_GSC == "C"
				do case
					case SX1->X1_PRESEL == 1; cPergunta := SX1->X1_DEF01
					case SX1->X1_PRESEL == 2; cPergunta := SX1->X1_DEF02
					case SX1->X1_PRESEL == 3; cPergunta := SX1->X1_DEF03
					case SX1->X1_PRESEL == 4; cPergunta := SX1->X1_DEF04
					case SX1->X1_PRESEL == 5; cPergunta := SX1->X1_DEF05
				endcase

				case SX1->X1_GSC == "G"; cPergunta := SX1->X1_CNT01
			endcase

			cLinDeImp := ""
			cLinDeImp += "Pergunta "+SX1->X1_ORDEM+": "+SX1->X1_PERGUNT+"  "+cPergunta
			@ nL,000 PSay cLinDeImp
			nL+=2

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Imprime a relacao dos produtos desejados.                                Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if (MV_PAR08 == 1) .AND. (SX1->X1_ORDEM == "08")
				cPergunta := ""
				for nI := 1 to len(aProdutos)+1
					if (len(cPergunta) < 80) .AND. (nI <= len(aProdutos))
						cPergunta := cPergunta + iif(!empty(cPergunta),"; ","") + aProdutos[nI]
					else
						if nI < len(aProdutos)
							cPergunta := cPergunta + ";"
						endif
						cLinDeImp := ""
						cLinDeImp += space(35) + cPergunta
						@ nL,000 PSay cLinDeImp
						nL++
						cPergunta := ""
					endif
				next
				nL++
			endif
			SX1->(DBSkip())
		enddo
		//Roda(nCbCont, cCbtxt, cTamanho)
	endif
	DBSelectArea(cOldAlias)
	nL := 99

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprime relatorio.                                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	do while !REL->(EOF())

		IncProc("Imprimindo ...")

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se considera somente produtos empenhados.					   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		if lEmp
			if REL->QTOTEMP <= 0
				REL->(DbSkip())
				Loop
			endif
		endif

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se considera somente produtos faturado e nao embarcados       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		if lFNE
			if REL->QFATNEMB <= 0
				REL->(DbSkip())
				Loop
			endif
		endif

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verifica se existe estoque para imprimir.                                Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		if REL->QESTBRUTO == 0
			REL->(DbSkip())
			Loop
		endif

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Impressao do cabecalho.                                                  Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		if nL >= nLimiteInf
			nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 1
		endif

		if MV_PAR07 == 1
			if REL->LOCALIZ # cLocAtu
				if cLocAtu # "##XX##"
					cDados	:= ""
					cDados	:= cDados + space(32) + "SUBTOTAL DA LOCALIZACAO "+replicate("-",32)+">"
					cDados	:= cDados + iif(nSubTEstBrt==0,"           -  ",Transform(nSubTEstBrt,"@E 999,999,999.99")) + space(2)
					cDados	:= cDados + iif(nSubTEstBCx==0,"           -  ",Transform(nSubTEstBCx,"@E 999,999,999.99")) + space(2)
					cDados	:= cDados + iif(nSubTFatNEB==0,"           -  ",Transform(nSubTFatNEB,"@E 999,999,999.99")) + space(2)
					cDados	:= cDados + iif(nSubTEmpNG ==0,"           -  ",Transform(nSubTEmpNG ,"@E 999,999,999.99")) + space(2)
					cDados	:= cDados + iif(nSubTEstLiq==0,"           -  ",Transform(nSubTEstLiq,"@E 999,999,999.99")) + space(2)
					cDados	:= cDados + iif(nSubTDspVnd==0,"           -  ",Transform(nSubTDspVnd,"@E 999,999,999.99"))
					@nL,000 Psay cDados
					nL := nL + 2
				endif

				nSubTEstBrt  := 0
				nSubTEstBCx:= 0
				nSubTFatNEB  := 0
				nSubTEmpNG	 := 0
				nSubTEstLiq  := 0
				nSubTDspVnd  := 0
				cLocAtu	     := REL->LOCALIZ

				if nl > nLimiteInf
					nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 1
				endif

				cDados := ""
				cDados := cDados + Padr(REL->LOCALIZ,15," ")
				@nL,000 Psay cDados
				nL := nL + 1
			endif

			//VERIFICA SE LOTE DO PRODUTO POSSUI RESTRICAO	
			nRestr	:= ""		
			cAliasTmp := GetNextAlias()
			BeginSql Alias cAliasTmp
				SELECT ZZ9_RESTRI FROM %Table:ZZ9% WHERE ZZ9_PRODUT = %Exp:Alltrim(REL->PRODUTO)% AND ZZ9_LOTE = %Exp:Alltrim(REL->TONCAL)% AND ZZ9_RESTRI = '*' AND %NOTDEL%
			EndSql
			If !(cAliasTmp)->(EOF()) 
				nRestr :=(cAliasTmp)->ZZ9_RESTRI
			EndIf
			(cAliasTmp)->(dbCloseArea())

			cDados := ""
			cDados := cDados + space(17)
			cDados := cDados + Padr(REL->PRODUTO,9," ") + space(1) 
			cDados := cDados + Padr(Alltrim(REL->TONCAL)+nRestr,7," ") + space(1)		
			cDados := cDados + Padr(REL->DESCRICAO,30," ") + space(25)
			cDados := cDados + iif(REL->QESTBRUTO ==0,"           -  ",Transform(REL->QESTBRUTO ,"@E 999,999,999.99")) + space(2)
			cDados := cDados + iif(REL->QESTBRUCX ==0,"           -  ",Transform(REL->QESTBRUCX ,"@E 999,999,999.99")) + space(2)		
			cDados := cDados + iif(REL->QFATNEMB  ==0,"           -  ",Transform(REL->QFATNEMB  ,"@E 999,999,999.99")) + space(2)
			cDados := cDados + iif(REL->QEMPNG	   ==0,"           -  ",Transform(REL->QEMPNG	  ,"@E 999,999,999.99")) + space(2)
			cDados := cDados + iif(REL->QESTLIQ   ==0,"           -  ",Transform(REL->QESTLIQ   ,"@E 999,999,999.99")) + space(2)
			cDados := cDados + iif(REL->QDISPVENDA==0,"           -  ",Transform(REL->QDISPVENDA,"@E 999,999,999.99"))
			@nL,000 Psay cDados
			nL := nL + 1
		else
			if REL->PRODUTO+REL->TONCAL # cProdAtu+cTonCal
				if cProdAtu # "##XX##" .OR. cTonCal # "##XX##"
					cDados	:= ""
					cDados	:= cDados + space(12) + "SUBTOTAL DO PRODUTO "+replicate("-",56)+">"
					cDados	:= cDados + iif(nSubTEstBrt==0,"           -  ",Transform(nSubTEstBrt,"@E 999,999,999.99")) + space(2)
					cDados	:= cDados + iif(nSubTEstBCx==0,"           -  ",Transform(nSubTEstBCx,"@E 999,999,999.99")) + space(2)
					cDados	:= cDados + iif(nSubTFatNEB==0,"           -  ",Transform(nSubTFatNEB,"@E 999,999,999.99")) + space(2)
					cDados	:= cDados + iif(nSubTEmpNG ==0,"           -  ",Transform(nSubTEmpNG ,"@E 999,999,999.99")) + space(2)
					cDados	:= cDados + iif(nSubTEstLiq==0,"           -  ",Transform(nSubTEstLiq,"@E 999,999,999.99")) + space(2)
					cDados	:= cDados + iif(nSubTDspVnd==0,"           -  ",Transform(nSubTDspVnd,"@E 999,999,999.99"))
					@nL,000 Psay cDados
					nL := nL + 2
				endif

				nSubTEstBrt  := 0
				nSubTEstBCx:= 0
				nSubTFatNEB  := 0
				nSubTEmpNG	 := 0
				nSubTEstLiq  := 0
				nSubTDspVnd  := 0
				cProdAtu	 := REL->PRODUTO
				cTonCal      := REL->TONCAL

				if nl > nLimiteInf
					nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 1
				endif

				//VERIFICA SE LOTE DO PRODUTO POSSUI RESTRICAO	
				nRestr	:= ""		
				cAliasTmp := GetNextAlias()
				BeginSql Alias cAliasTmp
					SELECT ZZ9_RESTRI FROM %Table:ZZ9% WHERE ZZ9_PRODUT = %Exp:Alltrim(REL->PRODUTO)% AND ZZ9_LOTE = %Exp:Alltrim(REL->TONCAL)% AND ZZ9_RESTRI = '*' AND %NOTDEL%
				EndSql
				If !(cAliasTmp)->(EOF()) 
					nRestr :=(cAliasTmp)->ZZ9_RESTRI
				EndIf
				(cAliasTmp)->(dbCloseArea())

				cDados := ""
				cDados := cDados + Padr(REL->PRODUTO  ,9," ")+space(01)
				cDados := cDados + Padr(Alltrim(REL->TONCAL)+nRestr,7," ")+space(01)			
				cDados := cDados + Padr(REL->DESCRICAO,30," ")
				@nL,000 Psay cDados
				nL := nL + 1
			endif

			cDados := ""
			cDados := cDados + space(12)
			cDados := cDados + Padr(REL->LOCALIZ,76," ")                      + space(1)
			cDados := cDados + iif(REL->QESTBRUTO ==0,"           -  ",Transform(REL->QESTBRUTO ,"@E 999,999,999.99")) + space(2)
			cDados := cDados + iif(REL->QESTBRUCX ==0,"           -  ",Transform(REL->QESTBRUCX ,"@E 999,999,999.99")) + space(2)
			cDados := cDados + iif(REL->QFATNEMB  ==0,"           -  ",Transform(REL->QFATNEMB  ,"@E 999,999,999.99")) + space(2)
			cDados := cDados + iif(REL->QEMPNG	   ==0,"           -  ",Transform(REL->QEMPNG	  ,"@E 999,999,999.99")) + space(2)
			cDados := cDados + iif(REL->QESTLIQ   ==0,"           -  ",Transform(REL->QESTLIQ   ,"@E 999,999,999.99")) + space(2)
			cDados := cDados + iif(REL->QDISPVENDA==0,"           -  ",Transform(REL->QDISPVENDA,"@E 999,999,999.99"))
			@nL,000 Psay cDados
			nL := nL + 1
		endif

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Imprime a descricao do romaneio para este produto           			     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		if lImpRom
			RMN->(DBSeek(REL->PRODUTO+REL->TONCAL+REL->LOCALIZ,.T.) )

			if (RMN->LOCALIZ == REL->LOCALIZ) .AND. (RMN->PRODUTO == REL->PRODUTO) .AND. (RMN->TONCLA == REL->TONCAL)
				cDados := space(17)
				cDados := cDados + "------------------------------------------------------------------------"
				@nL,000 Psay cDados
				nL := nL + 1

				cDados := space(17)
				cDados := cDados + "ROMANEIO    CLIENTE                         QUANT(M2)            PALETES"
				@nL,000 Psay cDados
				nL := nL + 1

				cDados := space(17)
				cDados := cDados + "------------------------------------------------------------------------"
				@nL,000 Psay cDados
				nL := nL + 1

				do while (RMN->LOCALIZ == REL->LOCALIZ ) .AND. (RMN->PRODUTO == REL->PRODUTO ) .AND. (RMN->TONCAL == REL->TONCAL ) .AND. !RMN->(EOF())
					cDados := space(17)
					cDados := cDados + RMN->ROMANEIO + space(04)
					cDados := cDados + RMN->CODCLI   + space(01)
					cDados := cDados + RMN->DESCLI   + space(01)
					cDados := cDados + iif(RMN->TOTAL == 0,"       -  ",Transform(RMN->TOTAL ,"@E 999,999.99")) + space(06)
					cDados := cDados + iif(RMN->TOTAL == 0,"       -  ",U_PALETES(RMN->PRODUTO,RMN->TOTAL,RMN->TONCAL))               

					@nL,000 Psay cDados
					nL := nL + 1

					RMN->(DbSkip())
				enddo

				cDados := space(17)
				cDados := cDados + "------------------------------------------------------------------------"
				@nL,000 Psay cDados
				nL := nL + 2
			endif
		endif

		nSubTEstBrt := nSubTEstBrt + REL->QESTBRUTO
		nSubTEstBCx := nSubTEstBCx + REL->QESTBRUCX
		nSubTFatNEB := nSubTFatNEB + REL->QFATNEMB
		nSubTEmpNG	:= nSubTEmpNG	+ REL->QEMPNG
		nSubTEstLiq := nSubTEstLiq + REL->QESTLIQ
		nSubTDspVnd := nSubTDspVnd + REL->QDISPVENDA
		nTotEstBrt	:= nTotEstBrt	+ REL->QESTBRUTO
		nTotEstBCx  := nTotEstBCx	+ REL->QESTBRUCX
		nTotFatNEB	:= nTotFatNEB	+ REL->QFATNEMB
		nTotEmpNG	:= nTotEmpNG	+ REL->QEMPNG
		nTotEstLiq	:= nTotEstLiq	+ REL->QESTLIQ
		nTotDspVnd	:= nTotDspVnd	+ REL->QDISPVENDA

		REL->(DbSkip())
	enddo

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Impressao do cabecalho.                                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	if nL >= nLimiteInf
		nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 1
	endif

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprime o subtotal do ultimo produto, caso ele exista.                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	if (nSubTEstBrt+nSubTEstBCx+nSubTFatNEB+nSubTEmpNG+nSubTEstLiq+nSubTDspVnd) > 0
		cDados	:= ""
		if MV_PAR07 == 1
			cDados	:= cDados + space(32) + "SUBTOTAL DA LOCALIZACAO "+replicate("-",32)+">"
		else
			cDados	:= cDados + space(12) + "SUBTOTAL DO PRODUTO "+replicate("-",56)+">"
		endif
		cDados	:= cDados + iif(nSubTEstBrt==0,"           -  ",Transform(nSubTEstBrt,"@E 999,999,999.99")) + space(2)
		cDados	:= cDados + iif(nSubTEstBCx==0,"           -  ",Transform(nSubTEstBCx,"@E 999,999,999.99")) + space(2)
		cDados	:= cDados + iif(nSubTFatNEB==0,"           -  ",Transform(nSubTFatNEB,"@E 999,999,999.99")) + space(2)
		cDados	:= cDados + iif(nSubTEmpNG ==0,"           -  ",Transform(nSubTEmpNG ,"@E 999,999,999.99")) + space(2)
		cDados	:= cDados + iif(nSubTEstLiq==0,"           -  ",Transform(nSubTEstLiq,"@E 999,999,999.99")) + space(2)
		cDados	:= cDados + iif(nSubTDspVnd==0,"           -  ",Transform(nSubTDspVnd,"@E 999,999,999.99"))
		@nL,000 Psay cDados
		nL := nL + 1
	endif
	nL := nL + 1

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprime o total geral dos produtos listados.                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@ nL,036 PSAY cLinDivisoria
	nL := nL + 1
	cDados := ""
	if MV_PAR07 == 1
		cDados := cDados + space(36) + "TOTAL GERAL "+replicate(".",40)+">"
	else
		cDados := cDados + space(12) + "TOTAL GERAL "+replicate(".",64)+">"
	endif
	cDados := cDados + iif(nTotEstBrt==0,"           -  ",Transform(nTotEstBrt,"@E 999,999,999.99")) + space(2)
	cDados := cDados + iif(nTotEstBCx==0,"           -  ",Transform(nTotEstBCx,"@E 999,999,999.99")) + space(2)
	cDados := cDados + iif(nTotFatNEB==0,"           -  ",Transform(nTotFatNEB,"@E 999,999,999.99")) + space(2)
	cDados := cDados + iif(nTotEmpNG ==0,"           -  ",Transform(nTotEmpNG ,"@E 999,999,999.99")) + space(2)
	cDados := cDados + iif(nTotEstLiq==0,"           -  ",Transform(nTotEstLiq,"@E 999,999,999.99")) + space(2)
	cDados := cDados + iif(nTotDspVnd==0,"           -  ",Transform(nTotDspVnd,"@E 999,999,999.99"))
	@nL,000 Psay cDados
	nL := nL + 1
	@ nL,036 PSAY cLinDivisoria
	nL := nL + 1
	@ Prow()+2,1 Psay "Caso haja saldo negativo, rode a rotina Ref. Data Romaneio"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprime rodape.                                                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	//Roda(nCbCont, cCbtxt, cTamanho)
Return

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддддддддддддддддддддд©╠╠
╠╠ЁFuncao	 ЁfImpSinteticoЁ Autor Ё WLADIMIR ILLIUSHENKO			        Ё╠╠
╠╠цддддддддддедддддддддддддадддддддадддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁDescricao Ё Imprime os dados da tabela temporaria. 		  	    		Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function fImpSintetico()

	Local nI

	do case
		case MV_PAR07 == 3 && Relatorio Sitentico por Romaneio
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicializa variaveis usadas na impressao.                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nTotQuant := 0
		cRomAtu   := "##XX##"

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Abre a tabela temporaria.                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		RMN->(DBCloseArea())
		DbUseArea(.T.,,cArqTemp2,"RMN")
		RMN->(DbCreateInd(cArqTemp2+".002","ROMANEIO+LOCALIZ",{||ROMANEIO+LOCALIZ}))
		RMN->(DbGoTop())
		ProcRegua(RMN->(LastRec()))

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Imprime parametros.                                                      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cOldAlias := Alias()
		DBSelectArea("SX1")
		DBSetOrder(1)

		if SX1->(DBSeek(cNomeProg+"01"))
			do while SX1->X1_GRUPO == cNomeProg
				if nL >= 65
					nL := Cabec("Parametros - "+cTitulo,"","",cNomeProg,cTamanho,nCrcControl) + 2
				endif

				cPergunta := ""
				do case
					case SX1->X1_GSC == "C"
					do case
						case SX1->X1_PRESEL == 1; cPergunta := SX1->X1_DEF01
						case SX1->X1_PRESEL == 2; cPergunta := SX1->X1_DEF02
						case SX1->X1_PRESEL == 3; cPergunta := SX1->X1_DEF03
						case SX1->X1_PRESEL == 4; cPergunta := SX1->X1_DEF04
						case SX1->X1_PRESEL == 5; cPergunta := SX1->X1_DEF05
					endcase

					case SX1->X1_GSC == "G"; cPergunta := SX1->X1_CNT01
				endcase

				cLinDeImp := ""
				cLinDeImp += "Pergunta "+SX1->X1_ORDEM+": "+SX1->X1_PERGUNT+"  "+cPergunta
				@ nL,000 PSay cLinDeImp
				nL+=2

				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Imprime a relacao dos produtos desejados.                                Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				if (MV_PAR08 == 1) .AND. (SX1->X1_ORDEM == "08")
					cPergunta := ""
					for nI := 1 to len(aProdutos)+1
						if (len(cPergunta) < 80) .AND. (nI <= len(aProdutos))
							cPergunta := cPergunta + iif(!empty(cPergunta),"; ","") + aProdutos[nI]
						else
							if nI < len(aProdutos)
								cPergunta := cPergunta + ";"
							endif
							cLinDeImp := ""
							cLinDeImp += space(35) + cPergunta
							@ nL,000 PSay cLinDeImp
							nL++
							cPergunta := ""
						endif
					next
					nL++
				endif
				SX1->(DBSkip())
			enddo
			//	Roda(nCbCont, cCbtxt, cTamanho)
		endif
		DBSelectArea(cOldAlias)
		nL := 99

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Imprime relatorio.                                                       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		do while !RMN->(EOF())

			IncProc("Imprimindo ...")

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Impressao do cabecalho.                                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if nL >= 65
				nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 1
			endif

			if RMN->ROMANEIO # cRomAtu
				if nl > 65
					nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 1
				endif

				cRomAtu	  := RMN->ROMANEIO
				cRomaneio := cRomAtu
			endif
			If RMN->TOTAL <> 0
				cDados := ""
				cDados := cDados + cRomaneio      + space(2)
				cDados := cDados + RMN->LOCALIZ   + space(2)
				cDados := cDados + RMN->CODCLI    + space(2)
				cDados := cDados + RMN->DESCLI    + space(4)
				cDados := cDados + RMN->PRODUTO   + space(2)
				cDados := cDados + RMN->DESCRICAO + space(2)
				cDados := cDados + iif(RMN->TOTAL == 0,"       -  ",Transform(RMN->TOTAL ,"@E 999,999.99")) + space(02)
				cDados := cDados + iif(RMN->TOTAL == 0,"       -  ",U_PALETES(RMN->PRODUTO,RMN->TOTAL,RMN->TONCAL)) + space(02)
				@ nL,000 Psay cDados
				nL := nL + 1
			EndIf	

			cRomaneio := space(08)
			nTotQuant := nTotQuant + RMN->TOTAL

			RMN->(DbSkip())
		enddo

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Impressao do cabecalho.                                                  Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		if nL >= 65
			nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 1
		endif
		nL := nL + 1

		cDados := ""
		cDados := cDados + "TOTAL GERAL "+replicate("-",92)+">" + space(02)
		cDados := cDados + iif(nTotQuant == 0,"       -  ",Transform(nTotQuant,"@E 999,999.99"))
		@nL,000 Psay cDados
		nL := nL + 1

		case MV_PAR07 == 4 && Relatorio Sitentico por Produto
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicializa variaveis usadas na impressao.                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nTotQuant := 0
		cProdAtu  := "##XX##"

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Abre a tabela temporaria.                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		REL->(DBCloseArea())
		DbUseArea(.T.,,cArqTemp1,"REL")
		DbCreateInd(cArqTemp1+".003","DESCRICAO+TONCAL+LOCALIZ",{||DESCRICAO+TONCAL+LOCALIZ})
		REL->(DbGoTop())
		ProcRegua(REL->(LastRec()))

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Imprime parametros.                                                      Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nL := fImpPar(nL)

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Imprime relatorio.                                                       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		do while !REL->(EOF())

			IncProc("Imprimindo ...")

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Impressao do cabecalho.                                                  Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if nL >= 60
				nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
				nL := nL + 1
				cDados   := ""
				cDados   := cDados + REL->DESCRICAO
				cProdAtu := REL->DESCRICAO
				@nL,000 Psay cDados
				nL := nL + 2
			endif

			if ALLTRIM(cProdAtu) # ALLTRIM(REL->DESCRICAO)
				if nL >= 58
					nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
				endif

				nL := nL + 1
				cDados   := ""
				cDados   := cDados + REL->DESCRICAO
				cProdAtu := REL->DESCRICAO
				@nL,000 Psay cDados
				nL := nL + 2
			endif

			if nL >= 60
				nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho)
				nL := nL + 1
				cDados   := ""
				cDados   := cDados + REL->DESCRICAO
				cProdAtu := REL->DESCRICAO
				@nL,000 Psay cDados
				nL := nL + 2
			endif
			If REL->QESTBRUTO <> 0 .or.  REL->QDISPVENDA <> 0

				//VERIFICA SE LOTE DO PRODUTO POSSUI RESTRICAO	
				nRestr	:= ""		
				cAliasTmp := GetNextAlias()
				BeginSql Alias cAliasTmp
					SELECT ZZ9_RESTRI FROM %Table:ZZ9% WHERE ZZ9_PRODUT = %Exp:Alltrim(REL->PRODUTO)% AND ZZ9_LOTE = %Exp:Alltrim(REL->TONCAL)% AND ZZ9_RESTRI = '*' AND %NOTDEL%
				EndSql
				If !(cAliasTmp)->(EOF()) 
					nRestr :=(cAliasTmp)->ZZ9_RESTRI
				EndIf
				(cAliasTmp)->(dbCloseArea())

				cDados := ""
				cDados := cDados + padr(Alltrim(REL->TONCAL)+nRestr,7)   + space(4)
				cDados := cDados + padr(REL->LOCALIZ,15) + space(3)
				cDados := cDados + iif(REL->QESTBRUTO  == 0,"          - ",u_paletes(REL->PRODUTO,REL->QESTBRUTO,REL->TONCAL)) + space(3)
				cDados := cDados + iif(REL->QDISPVENDA == 0,"          -  ",u_paletes(REL->PRODUTO,REL->QDISPVENDA,REL->TONCAL))						
				@ nL,000 Psay cDados
				nL++
			EndIf	

			REL->(DbSkip())
		enddo
	endcase                       
	@ Prow()+2,1 Psay "Caso haja saldo negativo, rode a rotina Ref. Data Romaneio"
Return

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддддддддд©╠╠
╠╠ЁFuncao	 Ё fApagaTemp Ё Autor Ё WLADIMIR ILLIUSHENKO 			      Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁDescricao Ё Apaga a tabela temporaria. 								  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		 Ё BIA075													  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function fApagaTemp()
	REL->(DbCloseArea("REL")); aeval(directory(cArqTemp1+".*"),{ |aFile| FErase(aFile[1])})
	RMN->(DbCloseArea("RMN")); aeval(directory(cArqTemp2+".*"),{ |aFile| FErase(aFile[1])})
Return

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддддддддд©╠╠
╠╠ЁFuncao	 Ё fFinaliza  Ё Autor Ё WLADIMIR ILLIUSHENKO 			      Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁDescricao Ё Finaliza digitacao da Selecao de Produtos                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		 Ё BIA075													  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function fFinaliza()

	Local nI

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Repassa os codigos digitados para uma array.                             Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aProdutos := {}
	do while len(cProdutos) > 0
		nPosC := at(";",cProdutos)
		if nPosC > 0
			cString := substr(cProdutos,1,nPosC-1)
		else
			cString := substr(cProdutos,1)
		endif

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Remove carcteres especiais do codigo.                                    Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cProd := cString
		nI    := 1
		do while .T.
			cAux := substr(cProd,nI,1)
			if ((Asc(cAux) < 32) .OR. (Asc(cAux) > 126)) .AND. (len(cProd) > 0)
				cProd := strtran(cProd,cAux,"")
				Loop
			else
				nI := nI + 1
			endif
			if nI >= len(cProd)
				Exit
			endif
		enddo
		cProd := Upper(Alltrim(cProd))

		if !empty(cProd) .AND. (ASCAN(aProdutos,cProd) == 0)
			AADD(aProdutos,cProd)
		endif

		cProdutos := substr(cProdutos,len(cString)+2)
	enddo

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Repassa os codigos da array para uma variavel texto.                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	asort(aProdutos)
	cProdutos := ""
	for nI := 1 to len(aProdutos)
		cProdutos := cProdutos + "'" + aProdutos[nI] + "'" + iif(nI<len(aProdutos),",","")
	next

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fecha a caixa de dialogo.                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	lOk := .F.
	Close(oDialog)
Return

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддддддддддддддддддддд©╠╠
╠╠ЁFuncao	 Ё fImpPar    Ё Autor Ё WLADIMIR ILLIUSHENKO 			      Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁDescricao Ё Imprime parametros.        								  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso		 Ё BIA075													  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function fImpPar(nL)

	Local nI

	cOldAlias := Alias()
	DBSelectArea("SX1")
	DBSetOrder(1)

	if SX1->(DBSeek(cNomeProg+"01"))
		do while SX1->X1_GRUPO == cNomeProg
			if nL >= 65
				nL := Cabec("Parametros - "+cTitulo,"","",cNomeProg,cTamanho,nCrcControl) + 2
			endif

			cPergunta := ""
			do case
				case SX1->X1_GSC == "C"
				do case
					case SX1->X1_PRESEL == 1; cPergunta := SX1->X1_DEF01
					case SX1->X1_PRESEL == 2; cPergunta := SX1->X1_DEF02
					case SX1->X1_PRESEL == 3; cPergunta := SX1->X1_DEF03
					case SX1->X1_PRESEL == 4; cPergunta := SX1->X1_DEF04
					case SX1->X1_PRESEL == 5; cPergunta := SX1->X1_DEF05
				endcase

				case SX1->X1_GSC == "G"; cPergunta := SX1->X1_CNT01
			endcase

			cLinDeImp := ""
			cLinDeImp += "Pergunta "+SX1->X1_ORDEM+": "+SX1->X1_PERGUNT+"  "+cPergunta
			@ nL,000 PSay cLinDeImp
			nL+=2

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Imprime a relacao dos produtos desejados.                                Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			if (MV_PAR08 == 1) .AND. (SX1->X1_ORDEM == "08")
				cPergunta := ""
				for nI := 1 to len(aProdutos)+1
					if (len(cPergunta) < 80) .AND. (nI <= len(aProdutos))
						cPergunta := cPergunta + iif(!empty(cPergunta),"; ","") + aProdutos[nI]
					else
						if nI < len(aProdutos)
							cPergunta := cPergunta + ";"
						endif
						cLinDeImp := ""
						cLinDeImp += space(35) + cPergunta
						@ nL,000 PSay cLinDeImp
						nL++
						cPergunta := ""
					endif
				next
				nL++
			endif
			SX1->(DBSkip())
		enddo
	endif
	DBSelectArea(cOldAlias)
Return 99