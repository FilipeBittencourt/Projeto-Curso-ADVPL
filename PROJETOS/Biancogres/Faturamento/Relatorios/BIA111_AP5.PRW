#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01
#IFNDEF WINDOWS
#DEFINE PSAY SAY
#ENDIF

User Function Bia111()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
	//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
	//� identificando as variaveis publicas do sistema utilizadas no codigo �
	//� Incluido pelo assistente de conversao do AP5 IDE                    �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

	Local nI

	SetPrvt("CNOMEPROG,CTAMANHO,CTITULO,CDESC1,CDESC2,CDESC3")
	SetPrvt("ARETURN,ALINHA,AORDEM,LPODECOMP,LTEMDIC,LGRAVPARAM")
	SetPrvt("NLASTKEY,CERRO,LERRO,CCBTXT,NCBCONT,CALIAS")
	SetPrvt("NL,M_PAG,CCABEC1,CCABEC2,CNUMINI,CNUMFIM")
	SetPrvt("CPRODINI,CPRODFIM,CLOCINI,CLOCFIM,CMASCARA,CCNTRMASC")
	SetPrvt("NI,ACAMPOS,CARQTEMP,NTOTQUANT,CLINDIVISORIA,CDADOS")
	SetPrvt("_CALIAS,CPERG,AREGS,NJ,")

	/*/
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
	굇쿑un뇙o	 � BIA111	  � Autor � WLADIMIR ILLIUSHENKO  � Data � 11/12/00 낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
	굇쿏escri뇙o � Relatorio de Movimentacao de Romaneio								 낢�
	굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
	굇� Uso		 � SIGAEST																		 낢�
	굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
	굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
	賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
	/*/
	#IFNDEF WINDOWS
	// Movido para o inicio do arquivo pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 		#DEFINE PSAY SAY
	#ENDIF

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Declaracao de variaveis																  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cNomeProg  := "BIA111"
	cTamanho   := "M"
	cTitulo	  := "Relatorio de Movimentacao de Romaneio"
	cDesc1	  := "Emite relatorio de Movimentacao de Romaneio                "
	cDesc2	  := "                                                           "
	cDesc3	  := "                                                           "
	aReturn	  := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	aLinha	  := { }
	aOrdem	  := { }
	lPodeComp  := .T.
	lTemDic	  := .F.
	lGravParam := .F.
	nLastKey   := 0
	cErro 	  := ""
	lErro 	  := .F.

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Variaveis utilizadas para impressao.												  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cCbTxt	 := space(10)
	nCbCont	 := 0
	cAlias	 := "SZ7"
	nL 		 := 80
	m_pag 	 := 1
	cCabec1	 := "NUMERO          PRODUTO      DESCRICAO                      LOCALIZACAO           QUANTIDADE  DOCUMENTO"
	cCabec2	 := "                                                                                                       "
	//XXXXXXXXXXXXXX	XXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXX   XXX.XXX.XXX,XX	XXXXXXXXXX
	//0					 17									  48					 57				71 			  85				 99				113

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Definicao dos parametros. Cria os parametros caso nao existam.			  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	//mv_par01 Do Numero 			?
	//mv_par02 Ate o Numero 		?
	//mv_par03 Do Produto			?
	//mv_par04 Ate o Produto		?
	//mv_par05 Da Localizacao		?
	//mv_par06 Ate a Localizacao	?
	//mv_par07 Mascara de Produtos?
	//fValidPerg()

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Envia controle para a funcao SETPRINT.											  �
	//� Verifica Posicao do Formulario na Impressora.									  �
	//� Solicita os parametros para a emissao do relatorio							  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cNomeProg := SetPrint(cAlias,cNomeProg,cNomeProg,@cTitulo,cDesc1,cDesc2,cDesc3,lTemDic,aOrdem,lPodeComp,cTamanho)
	Pergunte(cNomeProg,lGravParam)
	if (nLastKey==27) .OR. (LastKey()==27)
		Return
	endif

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Aceita par긩etros e faz ajustes necess쟲ios 									  �
	//� Gera mascar de contra-mascara de produtos.										  �
	//�		Ex.: "****B*E****" -> "****X*X****"                                 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	cNumIni	 := MV_PAR01
	cNumFim	 := MV_PAR02
	cProdIni  := MV_PAR03
	cProdFim  := MV_PAR04
	cLocIni	 := MV_PAR05
	cLocFim	 := MV_PAR06
	cMascara  := MV_PAR07
	cCntrMasc := ""
	for nI:=1 to len(cMascara)
		cCntrMasc := cCntrMasc + iif(SubStr(cMascara,nI,1)#"*","X","*")
	next
	SetDefault(aReturn,cAlias)

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Rotinas.																					  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	Processa({|| fCriaTemp()	})// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa({|| Execute(fCriaTemp)	})
	Processa({|| fAcumula()	})// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa({|| Execute(fAcumula)	})
	Processa({|| fImprime()	})// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa({|| Execute(fImprime)	})
	Processa({|| fApagaTemp() })// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	Processa({|| Execute(fApagaTemp) })

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Se a impress꼘 for em Disco, chama SPOOL 										�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if aReturn[5]==1
		Set Printer to
		Commit
		OurSpool(cNomeProg)
	endif

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Libera relatorio para Spool da Rede												�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	Ft_PFlush()
Return

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fCriaTemp� Autor � WLADIMIR ILLIUSHENKO						  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Cria uma tabela temporaria para preparacao do relatorio.   낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so		 � BIA111																	  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fCriaTemp
Static Function fCriaTemp()
	aCampos := {}
	AADD(aCampos, {"NUMERO    ", "C", 14, 0})
	AADD(aCampos, {"PRODUTO   ", "C", 11, 0})
	AADD(aCampos, {"DESCRICAO ", "C", 30, 0})
	AADD(aCampos, {"LOCALIZ   ", "C", 15, 0})
	AADD(aCampos, {"QUANTIDADE", "N", 14, 2})
	AADD(aCampos, {"DOCUMENTO ", "C", 06, 0})

	cArqTemp := CriaTrab(aCampos, .T.)
	DbUseArea(.T.,,cArqTemp,"TMP")
	DbCreateInd(cArqTemp+".001","NUMERO+PRODUTO+LOCALIZ",{||NUMERO+PRODUTO+LOCALIZ})
	OrdListClear()
	OrdListAdd(cArqTemp+".001")
Return


/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fAcumula � Autor � WLADIMIR ILLIUSHENKO						  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � 																			  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so		 � BIA111																	  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fAcumula
Static Function fAcumula()

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Le o SZ7 em busca das movimentacoes de romaneio.								�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	DbSelectArea("SZ7")
	DbSetOrder(1)
	ProcRegua(SZ7->(LastRec()))
	DbGoTop()
	do while !SZ7->(EOF())

		IncProc("Consultando romaneios ...")

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Verifica se o numero do romaneio pertence ao periodo informado nos ... �
		//� parametros.																				�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		if (SZ7->Z7_ROMAN < cNumIni) .OR. (SZ7->Z7_ROMAN > cNumFim)
			SZ7->(DbSkip())
			Loop
		endif

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Verifica se a localizacao do romaneio pertence ao periodo informado ...�
		//� nos parametros.																			�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		if (SZ7->Z7_LOCALIZ < cLocIni) .OR. (SZ7->Z7_LOCALIZ > cLocFim)
			SZ7->(DbSkip())
			Loop
		endif

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Verifica se o produto do romaneio pertence ao periodo informado nos ...�
		//� parametros.																				�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		if (SZ7->Z7_PRODUTO < cProdIni) .OR. (SZ7->Z7_PRODUTO > cProdFim)
			SZ7->(DbSkip())
			Loop
		endif

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Verifica se o produto pertence a mascara informada.							�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		if Transform(SZ7->Z7_PRODUTO,cCntrMasc) #cMascara
			SZ7->(DbSkip())
			Loop
		endif

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Grava os dados obtidos no arquivo temporario.									�
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		DbSelectArea("TMP")
		DbSetOrder(1)
		RecLock("TMP",.T.)
		TMP->NUMERO 	 := SZ7->Z7_ROMAN
		TMP->PRODUTO	 := SZ7->Z7_PRODUTO
		TMP->DESCRICAO  := SZ7->Z7_DESCRI
		TMP->LOCALIZ	 := SZ7->Z7_LOCALIZ
		TMP->QUANTIDADE := SZ7->Z7_QUANT
		TMP->DOCUMENTO  := SZ7->Z7_DOC
		MsUnlock()

		SZ7->(DbSkip())
	enddo
Return

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컫컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fImprime  � Autor � WLADIMIR ILLIUSHENKO						  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컨컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Imprime os dados da tabela temporaria. 						  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fImprime
Static Function fImprime()
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Inicializa variaveis usadas na impressao.										�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	nTotQuant	  := 0
	cLinDivisoria := Replicate("-",32)

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Abre a tabela temporaria. 															�
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	DbSelectArea("TMP")
	DbGoTop()
	ProcRegua(TMP->(LastRec()))
	do while !TMP->(EOF())

		IncProc("Imprimindo ...")

		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//� Impressao do cabecalho.																  �
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
		if nL >= 60
			nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 2
		endif

		cDados := ""
		cDados := cDados + padr(TMP->NUMERO   ,14," ") + space(02)
		cDados := cDados + padr(TMP->PRODUTO  ,11," ") + space(02)
		cDados := cDados + padr(TMP->DESCRICAO,30," ") + space(01)
		cDados := cDados + padr(TMP->LOCALIZ  ,15," ") + space(03)
		cDados := cDados + Transform(TMP->QUANTIDADE,iif(TMP->QUANTIDADE==0,"           -  ","@E 999,999,999.99")) + space(2)
		cDados := cDados + padr(TMP->DOCUMENTO,06," ") + space(02)
		@nL,000 Psay cDados
		nL 		 := nL + 1
		nTotQuant := nTotQuant + TMP->QUANTIDADE

		TMP->(DbSkip())
	enddo

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Impressao do cabecalho.																  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	if nL >= 60
		nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho) + 2
	endif

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Imprime o total geral dos produtos listados.									  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	@ nL,000 PSAY space(60)+cLinDivisoria
	nL := nL + 1
	cDados := ""
	cDados := cDados + space(60) + "TOTAL GERAL --->" + space(02)
	cDados := cDados + Transform(nTotQuant,iif(nTotQuant==0,"           -  ","@E 999,999,999.99"))
	@nL,000 Psay cDados
	nL := nL + 1
	@ nL,000 PSAY space(60)+cLinDivisoria
	nL := nL + 1

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//� Imprime rodape.																			  �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	Roda(nCbCont, cCbtxt, cTamanho)
Return

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴엽�
굇쿑uncao	 � fApagaTemp � Autor � WLADIMIR ILLIUSHENKO 					  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿏escricao � Apaga a tabela temporaria. 										  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so		 � BIA111																	  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fApagaTemp
Static Function fApagaTemp()
	DbSelectArea("TMP")
	DbCloseArea("TMP")
	FErase(cArqTemp+".*")
Return

/*/
複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複複�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑uncao	 쿣ALIDPERG � Autor � Joao Carlos de Andrade� Data � 12/09/00 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escricao � Verifica as perguntas incluindo-as caso nao existam		  낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇쿢so		 � Especifico - Incesa													  낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fValidPerg
Static Function fValidPerg()

	Local nI, nJ

	_cAlias := Alias()
	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PADR(cNomeProg,6)

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	//� Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05 �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
	aRegs := {}
	AADD(aRegs,{cPerg,"01","Do Numero          ?","mv_ch1","C",08,0,0,"G",""        ,"mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Ate o Numero       ?","mv_ch2","C",08,0,0,"G",""        ,"mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Do Produto         ?","mv_ch3","C",11,0,0,"G",""        ,"mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Ate o Produto      ?","mv_ch4","C",11,0,0,"G",""        ,"mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Da Localizacao     ?","mv_ch5","C",15,0,0,"G",""        ,"mv_par05","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"06","Ate a Localizacao  ?","mv_ch6","C",15,0,0,"G",""        ,"mv_par06","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"07","Mascara de Produtos?","mv_ch7","C",11,0,0,"G","NaoVazio","mv_par07","","","","","","","","","","","","","","",""})

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

