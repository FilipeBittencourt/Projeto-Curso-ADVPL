#include "rwmake.ch"     
#INCLUDE "TOPCONN.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	   ³ BIA112	    ³ Autor ³ WLADIMIR ILLIUSHENKO  ³ Data ³ 11/12/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Relatorio de Seguro de Cargas por Periodo 				            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		   ³ SIGAEST														                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function Bia112()

	SetPrvt("CNOMEPROG,CTAMANHO,CTITULO,CDESC1,CDESC2,CDESC3")
	SetPrvt("ARETURN,ALINHA,AORDEM,LPODECOMP,LTEMDIC,LGRAVPARAM")
	SetPrvt("NLASTKEY,CERRO,LERRO,CCBTXT,NCBCONT,CALIAS")
	SetPrvt("NL,M_PAG,CCABEC1,CCABEC2,CNOTAINI,CNOTAFIM")
	SetPrvt("CDATAINI,CDATAFIM,CCLIINI,CCLIFIM,NSALDOANT,ACAMPOS")
	SetPrvt("CARQTEMP,CNOMECLI,CDOC,CSERIE,CCLIENTE,CLOJA")
	SetPrvt("NQUANT,NSUBTQUANT,NSUBTVSEG,NTOTQUANT,NTOTVSEG,DEMISSAO")
	SetPrvt("LPRIMVEZ,CLINDIVISORIA,CDADOS,NTOTSACML,_CALIAS,CPERG")
	SetPrvt("AREGS,NI,NJ,")


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis													 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNomeProg		:= "BIA112"
	cTamanho  	:= "M"
	cTitulo	  	:= "Relatorio de Seguro de Cargas por Periodo"
	cDesc1	  	:= "Emite relatorio de Seguro de Cargas por Periodo            "
	cDesc2	  	:= "                                                           "
	cDesc3	  	:= "                                                           "
	aReturn	  	:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	aLinha	  	:= { }
	aOrdem	  	:= { }
	lPodeComp		:= .T.
	lTemDic			:= .F.
	lGravParam	:= .F.
	nLastKey		:= 0
	cErro				:= ""
	lErro				:= .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para impressao.								     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCbTxt	 := space(10)
	nCbCont	 := 0
	cAlias	 := "SF2"
	nL 		 := 80
	m_pag 	 := 1
	cCabec1	 := "NF.        CLIENTE--------------------      QUANTIDADE           VALOR           SALDO"
	cCabec2	 := "           CODIGO NOME                                       DO SEGURO       ACUMULADO"
	//XXXXXX  XXXXXX XXXXXXXXXXXXXXXXXXXX	XXX.XXX.XXX,XX  XXX.XXX.XXX,XX  XXX.XXX.XXX,XX
	//0					 17									  48					 57				71

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao dos parametros. Cria os parametros caso nao existam.			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//mv_par01 Da Nota				?
	//mv_par02 Ate a Nota			?
	//mv_par03 Da Emissao			?
	//mv_par04 Ate a Emissao		?
	//mv_par05 Do Cliente			?
	//mv_par06 Ate o Cliente		?
	//mv_par07 Saldo Anterior		!
	//fValidPerg()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT.											  ³
	//³ Verifica Posicao do Formulario na Impressora.									  ³
	//³ Solicita os parametros para a emissao do relatorio							  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNomeProg := SetPrint(cAlias,cNomeProg,cNomeProg,@cTitulo,cDesc1,cDesc2,cDesc3,lTemDic,aOrdem,lPodeComp,cTamanho)
	Pergunte(cNomeProg,lGravParam)
	if (nLastKey==27) .OR. (LastKey()==27)
		Return
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Aceita parƒmetros e faz ajustes necess rios 									  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNotaIni	:= MV_PAR01
	cNotaFim	:= MV_PAR02
	cDataIni	:= MV_PAR03
	cDataFim	:= MV_PAR04
	cCliIni		:= MV_PAR05
	cCliFim		:= MV_PAR06
	nSaldoAnt	:= MV_PAR07
	cTraIni		:= MV_PAR08
	cTraFim		:= MV_PAR09
	SetDefault(aReturn,cAlias)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rotinas.																					  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|| fCriaTemp()	})// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa({|| Execute(fCriaTemp)	})
	Processa({|| fAcumula()	})// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa({|| Execute(fAcumula)	})
	Processa({|| fImprime()	})// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa({|| Execute(fImprime)	})
	Processa({|| fApagaTemp() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa({|| Execute(fApagaTemp) })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se a impress„o for em Disco, chama SPOOL 										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if aReturn[5]==1
		Set Printer to
		Commit
		OurSpool(cNomeProg)
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Libera relatorio para Spool da Rede									   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Ft_PFlush()
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fCriaTemp³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria uma tabela temporaria para preparacao do relatorio.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ BIA112													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fCriaTemp
Static Function fCriaTemp()
	aCampos := {}
	AADD(aCampos, {"NOTA      ", "C", 09, 0})
	AADD(aCampos, {"EMISSAO   ", "D", 08, 0})
	AADD(aCampos, {"CLICODIGO ", "C", 06, 0})
	AADD(aCampos, {"CLINOME   ", "C", 20, 0})
	AADD(aCampos, {"QUANTIDADE", "N", 14, 2})
	AADD(aCampos, {"VALSEGURO ", "N", 14, 2})
	AADD(aCampos, {"SALDOACML ", "N", 14, 2})

	cArqTemp := CriaTrab(aCampos, .T.)

	DbUseArea(.T.,,cArqTemp,"TMP")
	cInd := CriaTrab(NIL,.F.)
	IndRegua("TMP",cInd,"DTOS(EMISSAO)+NOTA+CLICODIGO",,,"Selecionando Registros...")


	//	DbUseArea(.T.,,cArqTemp,"TMP")
	//	DbCreateInd(cArqTemp+".001","dtos(EMISSAO)+NOTA+CLICODIGO",{||dtos(EMISSAO)+NOTA+CLICODIGO})
	//	OrdListClear()
	//	OrdListAdd(cArqTemp+".001")
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fAcumula ³ Autor ³ WLADIMIR ILLIUSHENKO					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ BIA112													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fAcumula
Static Function fAcumula()
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Le o SF2 em calculando o valor do seguro.										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SF2")
	DbSetOrder(1)
	ProcRegua(SF2->(LastRec()))
	DbGoTop()
	do while !SF2->(EOF())

	IncProc("Consultando NF's ...")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o numero da NF pertence ao periodo informado nos parametros³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if (SF2->F2_DOC < cNotaIni) .OR. (SF2->F2_DOC > cNotaFim)
	SF2->(DbSkip())
	Loop
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a data de emissao da NF pertence ao periodo informado nos..³
	//³ parametros.																				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if (SF2->F2_EMISSAO < cDataIni) .OR. (SF2->F2_EMISSAO > cDataFim)
	SF2->(DbSkip())
	Loop
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o cliente da NF pertence ao periodo informado nos params.	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if (SF2->F2_CLIENTE < cCliIni) .OR. (SF2->F2_CLIENTE > cCliFim)
	SF2->(DbSkip())
	Loop
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o cliente existe na tabela SA1. 									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+SF2->F2_CLIENTE,.F.)
	cNomeCli := SA1->A1_NREDUZ
	if (SF2->F2_CLIENTE #SA1->A1_COD)
	cNomeCli := "CLIENTE INEXISTENTE!"
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe itens para esta NF na tabela SD2. 						³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Considera somente NF do Tipo PA
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	if Alltrim(SD2->D2_TP) <> "PA"
	SF2->(DbSkip())
	Loop
	endif

	cDoc		:= SD2->D2_DOC
	cSerie		:= SD2->D2_SERIE
	cCliente 	:= SD2->D2_CLIENTE
	cLoja 		:= SD2->D2_LOJA
	nQuant		:= 0

	if (cDoc 	 #SF2->F2_DOC 	) .OR.;
	(cSerie	 #SF2->F2_SERIE	) .OR.;
	(cCliente #SF2->F2_CLIENTE) .OR.;
	(cLoja	 #SF2->F2_LOJA	)
	cNomeCli := "CLIENTE SEM ITENS!!!"
	else
	do while (SD2->D2_DOC	  == cDoc	 ) .AND.;
	(SD2->D2_SERIE   == cSerie  ) .AND.;
	(SD2->D2_CLIENTE == cCliente) .AND.;
	(SD2->D2_LOJA	  == cLoja	 ) .AND.;
	!SD2->(EOF())
	nQuant := nQuant + SD2->D2_QUANT
	SD2->(DbSkip())
	enddo
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os dados obtidos no arquivo temporario.									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TMP")
	DbSetOrder(1)
	RecLock("TMP",.T.)
	TMP->NOTA		 := SF2->F2_DOC
	TMP->EMISSAO	 := SF2->F2_EMISSAO
	TMP->CLICODIGO  := SF2->F2_CLIENTE
	TMP->CLINOME	 := cNomeCli
	TMP->QUANTIDADE := nQuant
	TMP->VALSEGURO  := SF2->F2_YSEGURO
	MsUnlock()

	SF2->(DbSkip())
	enddo
	*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ MONTA BASE
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cSql := "SELECT F2_DOC, F2_EMISSAO, F2_CLIENTE, A1_NOME, F2_YSEGURO AS SEGURO, SUM(D2_QUANT) QUANT "
	cSql += "FROM "+RetSqlName("SF2")+" SF2 "
	cSql += "	INNER JOIN "+RetSqlName("SD2")+" SD2 ON  "
	cSql += "				F2_SERIE	= D2_SERIE	AND  "
	cSql += "				F2_DOC		= D2_DOC	AND  "
	cSql += "				F2_CLIENTE	= D2_CLIENTE AND "
	cSql += "				F2_LOJA		= D2_LOJA		 "
	cSql += "	INNER JOIN SA1010 SA1 ON				 "
	cSql += "				F2_CLIENTE	= A1_COD	AND  "
	cSql += "				F2_LOJA		= A1_LOJA		 "
	cSql += "WHERE F2_FILIAL = '"+xFilial("SF2")+"' AND  "
	cSql += "	  D2_FILIAL  = '"+xFilial("SD2")+"' AND  "
	cSql += "	  F2_EMISSAO >= '"+Dtos(cDataIni)+"' AND 		 "
	cSql += "     F2_EMISSAO <= '"+Dtos(cDataFim)+"' AND       "
	cSql += "	  F2_DOC >= '"+cNotaIni+"' AND 			 "
	cSql += "     F2_DOC <= '"+cNotaFim+"' AND 			 "
	cSql += "	  F2_CLIENTE >= '"+cCliIni+"' AND 		 "
	cSql += "     F2_CLIENTE <= '"+cCliFim+"' AND      	 "
	cSql += "	  F2_TRANSP >= '"+cTraIni+"' AND 		 "
	cSql += "     F2_TRANSP <= '"+cTraFim+"' AND      	 "
	cSql += "     SD2.D2_TP = 'PA' AND 					 "
	cSql += "	  SF2.D_E_L_E_T_ = '' AND   			 "
	cSql += "     SD2.D_E_L_E_T_ = '' AND				 "
	cSql += "     SA1.D_E_L_E_T_ = ''					 "
	cSql += "GROUP BY F2_DOC, F2_EMISSAO, F2_CLIENTE, A1_NOME, F2_YSEGURO "
	cSql += "ORDER BY F2_EMISSAO, F2_DOC, F2_CLIENTE, A1_NOME "
	If chkfile("R001")
		dbSelectArea("R001")
		dbCloseArea()
	EndIf                     
	TcQuery cSql ALIAS "R001" NEW	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os dados obtidos no arquivo temporario.									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While  !R001->(EOF())
		DbSelectArea("TMP")
		DbSetOrder(1)
		RecLock("TMP",.T.)
		TMP->NOTA		:= R001->F2_DOC
		TMP->EMISSAO	:= Stod(R001->F2_EMISSAO)
		TMP->CLICODIGO  := R001->F2_CLIENTE
		TMP->CLINOME	:= R001->A1_NOME
		TMP->QUANTIDADE	:= R001->QUANT
		TMP->VALSEGURO	:= R001->SEGURO
		MsUnlock()
		R001->(dbSkip())
	End

Return

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
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fImprime
Static Function fImprime()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa variaveis usadas na impressao.										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSubTQuant	  := 0
	nSubTVSeg	  := 0

	nTotQuant	  := 0
	nTotVSeg 	  := 0

	nTotSAcml     := 0

	dEmissao 	  := ctod(space(8))
	lPrimVez 	  := .T.
	cLinDivisoria := Replicate("-",64)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre a tabela temporaria. 															³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TMP")
	DbSetOrder(1)
	DbGoTop()

	ProcRegua(TMP->(LastRec()))

	dEmissao := TMP->EMISSAO

	nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 2

	cDados := "Emissao: "
	cDados := cDados + dtoc(dEmissao)
	@nL,000 Psay cDados
	nL := nL + 1

	do while !TMP->(EOF())

		IncProc("Imprimindo ...")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho.																  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if nL >= 60
			nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 2
		endif

		if dEmissao # TMP->EMISSAO
			cDados := space(40)
			cDados := cDados + Transform(nSubTQuant,iif(nSubTQuant==0,"           -  ","@E 999,999,999.99")) + space(2)
			cDados := cDados + Transform(nSubTVSeg ,iif(nSubTVSeg ==0,"           -  ","@E 999,999,999.99")) + space(2)

			@nL,000 Psay cDados
			nL 		   := nL + 2
			nSubTQuant := 0
			nSubTVSeg  := 0
			dEmissao   := TMP->EMISSAO

			cDados := "Emissao: "
			cDados := cDados + dtoc(dEmissao)
			@nL,000 Psay cDados
			nL := nL + 1
		endif

		cDados := ""
		cDados := cDados + padr(TMP->NOTA	  ,09," ") + space(2)
		cDados := cDados + padr(TMP->CLICODIGO,06," ") + space(1)
		cDados := cDados + padr(TMP->CLINOME  ,20," ") + space(2)
		cDados := cDados + Transform(TMP->QUANTIDADE,iif(TMP->QUANTIDADE==0,"           -  ","@E 999,999,999.99")) + space(2)
		cDados := cDados + Transform(TMP->VALSEGURO ,iif(TMP->VALSEGURO ==0,"           -  ","@E 999,999,999.99")) + space(2)

		@nL,000 Psay cDados
		nL := nL + 1

		nSubTQuant := nSubTQuant + TMP->QUANTIDADE
		nSubTVSeg  := nSubTVSeg  + TMP->VALSEGURO

		nTotQuant  := nTotQuant  + TMP->QUANTIDADE
		nTotVSeg   := nTotVSeg	 + TMP->VALSEGURO

		nTotSAcml  := nTotVSeg	 + nSaldoAnt

		TMP->(DbSkip())
	enddo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho.																  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nL >= 60
		nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 2
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime o subtotal dos itens listados.											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cDados := space(40)
	cDados := cDados + Transform(nSubTQuant,iif(nSubTQuant==0,"           -  ","@E 999,999,999.99")) + space(2)
	cDados := cDados + Transform(nSubTVSeg ,iif(nSubTVSeg ==0,"           -  ","@E 999,999,999.99")) + space(2)

	@nL,000 Psay cDados
	nL := nL + 2

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime o total dos itens listados.												  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ nL,000 PSAY space(22)+cLinDivisoria
	nL := nL + 1
	cDados := ""
	cDados := cDados + space(22) + "TOTAL GERAL --->" + space(02)
	cDados := cDados + Transform(nTotQuant,iif(nTotQuant==0,"           -  ","@E 999,999,999.99")) + space(02)
	cDados := cDados + Transform(nTotVSeg ,iif(nTotvSeg ==0,"           -  ","@E 999,999,999.99")) + space(02)
	cDados := cDados + Transform(nTotSAcml,iif(nTotSAcml==0,"           -  ","@E 999,999,999.99"))

	@nL,000 Psay cDados
	nL := nL + 1
	@ nL,000 PSAY space(22)+cLinDivisoria
	nL := nL + 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime rodape.																			  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Roda(nCbCont, cCbtxt, cTamanho)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ fApagaTemp ³ Autor ³ WLADIMIR ILLIUSHENKO 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Apaga a tabela temporaria. 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ BIA112																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fApagaTemp
Static Function fApagaTemp()
	DbSelectArea("TMP")
	DbCloseArea("TMP")
	FErase(cArqTemp+".*")
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³VALIDPERG ³ Autor ³ Joao Carlos de Andrade³ Data ³ 12/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica as perguntas incluindo-as caso nao existam		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Especifico - Incesa													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fValidPerg
Static Function fValidPerg()

	Local nJ, nI

	_cAlias := Alias()
	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PADR(cNomeProg,6)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRegs := {}
	AADD(aRegs,{cPerg,"01","Da Nota            ?","mv_ch1","C",09,0,0,"G",""        ,"mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Ate a Nota         ?","mv_ch2","C",09,0,0,"G",""        ,"mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Da Emissao         ?","mv_ch3","D",08,0,0,"G","NaoVazio","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Ate a Emissao      ?","mv_ch4","D",08,0,0,"G","NaoVazio","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Do Cliente         ?","mv_ch5","C",06,0,0,"G",""        ,"mv_par05","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"06","Ate o Cliente      ?","mv_ch6","C",06,0,0,"G",""        ,"mv_par06","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"07","Saldo Anterior     ?","mv_ch7","N",14,2,0,"G",""        ,"mv_par07","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"08","Da Transport.      ?","mv_ch8","C",06,0,0,"G",""        ,"mv_par08","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"09","Ate a Transport.   ?","mv_ch9","C",06,0,0,"G",""        ,"mv_par09","","","","","","","","","","","","","","",""})


	for nI:=1 to Len(aRegs)
		if !dbSeek(cPerg+aRegs[nI,2])
			RecLock("SX1",.T.)
			for nJ:=1 to FCount()
				FieldPut(nJ,aRegs[nI,nJ])
			next
			MsUnlock()
			DbCommit()
		endif
	next

	DbSelectArea(_cAlias)
Return
