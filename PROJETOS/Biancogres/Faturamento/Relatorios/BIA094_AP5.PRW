#include "rwmake.ch"
#include "relato.ch"
#include "topconn.ch"

User Function Bia094()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetPrvt("CDESC1,CDESC2,CDESC3,CALIAS,CNOMEPROG,CNOMEARQ,COLDAREA")
	SetPrvt("CTITULO,CCABEC1,CCABEC2,CTAMANHO,CLINDEIMP,CARQTEMP1,CARQTEMP2")
	SetPrvt("LGRAVPARAM,LTEMDIC,LPODECOMP,LABORTPRINT")
	SetPrvt("ARETURN,ACAMPOS,AORD,AFA03MTOT,ATGFA03M,ATPFA03M")
	SetPrvt("NCRCCONTROL,NL,NFA12MTOT,NFA12MMED,NFA12MQUN,NTOTREGS")
	SetPrvt("NTGFA12MT,NMGFA12MM,NTGFA12MQ,NPARTACU")
	SetPrvt("NTPFA12MT,NMPFA12MM,NTPFA12MQ")
	SetPrvt("I,NRANK")
	SetPrvt("DDATAINIC,DDATAFINA")
	SetPrvt("CQUERY,CWHERE,CGRUPO,CVARIAVEL,CMESPESQ,CANOPESQ,")

	/*/
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Funcao	 ³ BIA094	³ Autor ³ WLADIMIR ILLIUSHENKO  ³ Data ³19/06/2001³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descricao ³ Relatorio de Curva ABC de Representantes.                  ³±±
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
	cDesc2	   := "curva ABC por representante baseando-se na Data-Base do  "
	cDesc3	   := "sistema.                                                 "
	cTamanho    := "G"
	cAlias	   := "SD2"
	cTitulo	   := "CURVA ABC DOS REPRESENTANTES"
	aReturn	   := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	cNomeProg   := "BIA094"
	aOrd	      := {}
	lGravParam  := .F.
	lPodeComp   := .F.
	lTemDic	   := .F.
	lGravParam  := .F.
	nTGFA12MT   := 0         // TotalGeral do Faturamento Acumulado nos ultimos 12 meses.
	nMGFA12MM   := 0         // MediaGeral do Faturamento Acumulado nos ultimos 12 meses.
	nTGFA12MQ   := 0         // TotalGeral da Quantidade Faturada nos ultimos 12 meses.
	aTGFA03M    := {0,0,0}  // TotalGeral do Faturamento Acumulado nos ultimos 3 meses.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT.									        ³
	//³ Verifica Posicao do Formulario na Impressora.							        ³
	//³                                          								        ³
	//³ Pega os valores passados como parametro: 								        ³
	//³ MV_PAR01 -> De Representante  ?          								        ³
	//³ MV_PAR02 -> Ate o Representante ?        								        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNomeArq := SetPrint(cAlias, cNomeProg, cNomeProg, @cTitulo, cDesc1, cDesc2, cDesc3, lTemDic, aOrd, lPodeComp, cTamanho,, .T.)
	if lastkey()==27
		Return
	endif

	Pergunte(cNomeProg,lGravParam)
	if lastkey()==27
		Return
	endif

	SetDefault(aReturn,cAlias)
	if lastkey()==27
		Return
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa variaveis usadas no relatorio.                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nTotRegs    := 0
	nCbcont	   := 0
	cCbtxt 	   := space(10)
	m_pag 	   := 1
	nCrcControl := iif(aReturn[4]==1,15,18)
	nL     	   := 80
	cCabec1	   :=" RANK  CLIENTE-------------------------  CIDADE------------  UF  -FAT. ACUMULADOS NOS ULTIMOS 12 MESES-     ------------FATU. NOS ULTIMOS 3 MESES EM R$  ------PART. EM R$"
	cCabec2	   :="                                                                      VAL.TOTAL  PRC.MED.      QUANT.M2     .........."+u_mesr(ctod("01/"+U_MesAno(DDATABASE,,-1)))+"  .........."+u_mesr(ctod("01/"+U_MesAno(DDATABASE,,-2)))+"  .........."+u_mesr(ctod("01/"+U_MesAno(DDATABASE,,-3)))+"  INDIVID.   %ACUML. "
	//cCabec2	   :="XXXXX  XXXXXX-XX - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXX  XX	XX.XXX.XXX,XX	X.XXX,XX  XX.XXX.XXX,XX   XX.XXX.XXX,XX  XX.XXX.XXX,XX  XX.XXX.XXX,XX  X.XXX,XX  X.XXX,XX

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
			DBCommitAll()
			set printer to
			OurSpool(cNomeArq)
		endif
		MS_Flush()
	endif
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
	AADD(aCampos,{ "CODREP  ", "C", 06, 0 }) // Codigo do representante.
	AADD(aCampos,{ "NOMREP  ", "C", 40, 0 }) // Nome do representante.
	AADD(aCampos,{ "RANK    ", "C", 05, 0 }) // Posicao no Ranking.
	AADD(aCampos,{ "CODCLI  ", "C", 06, 0 }) // Codigo do Cliente.
	AADD(aCampos,{ "LOJCLI  ", "C", 02, 0 }) // Loja do Cliente.
	AADD(aCampos,{ "NOMCLI  ", "C", 20, 0 }) // Nome do Cliente.
	AADD(aCampos,{ "CIDADE  ", "C", 16, 0 }) // Cidade do Cliente.
	AADD(aCampos,{ "UF      ", "C", 02, 0 }) // UF do Cliente.
	AADD(aCampos,{ "FATAC12M", "N", 15, 2 }) // Faturamento acumulado nos ultimos 12 meses.
	AADD(aCampos,{ "PRCMEDIO", "N", 09, 2 }) // Preco medio.
	AADD(aCampos,{ "AC12MM2 ", "N", 15, 2 }) // Acumulado nos ultimos 12 meses em m2.
	AADD(aCampos,{ "FATUL3M1", "N", 15, 2 }) // Faturamento nos ultimos 3 meses em R$ (DDATABASE-1).
	AADD(aCampos,{ "FATUL3M2", "N", 15, 2 }) // Faturamento nos ultimos 3 meses em R$ (DDATABASE-2).
	AADD(aCampos,{ "FATUL3M3", "N", 15, 2 }) // Faturamento nos ultimos 3 meses em R$ (DDATABASE-3).
	AADD(aCampos,{ "PRTINDIV", "N", 09, 2 }) // Paricipacao em R$ (percentual individual).
	AADD(aCampos,{ "PRTPERAC", "N", 09, 2 }) // Paricipacao em R$ (percentual acumulado).
	cArqTemp1 := CriaTrab(aCampos, .T.)
	DbUseArea(.T.,,cArqTemp1,"REL")
return

Static Function fAcumula()

	Local i

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reconfigura os indices das tabelas auxiliares.                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SA1->(DbSetOrder(1)) // Cliente.
	SA3->(DbSetOrder(1)) // Representante.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula quantidade de registros a serem analizados.      				     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery  := ""
	cWhere  := ""
	cQuery  += "SELECT COUNT(DISTINCT SA3.A3_COD) AS TOTREGS "
	cWhere  += "FROM "+RetSqlName("SA3")+" SA3, "+RetSqlName("SF2")+" SF2, "+RetSqlName("SF3")+" SF3, "+RetSqlName("SA1")+" SA1 "
	cWhere  += "WHERE "
	cWhere  += "     (SA3.A3_COD     >= '"+MV_PAR01+"') "
	cWhere  += " AND (SA3.A3_COD     <= '"+MV_PAR02+"') "
	cWhere  += " AND (SA3.D_E_L_E_T_ <> '*') "

	cWhere  += " AND (SF2.F2_VEND1   = SA3.A3_COD) "
	cWhere  += " AND (SF2.F2_FILIAL  =  '"+xFilial("SF2")+"')  "
	cWhere  += " AND (SF2.F2_EMISSAO >= '"+dtos(ctod("01/"+U_MesAno(DDATABASE,,-11)))+"') "
	cWhere  += " AND (SF2.F2_EMISSAO <= '"+dtos(U_UltDiaM(DDATABASE))+"') "
	cWhere  += " AND (SF2.F2_TIPO    =  'N') "									// Somente Notas Fiscais.
	cWhere  += " AND (SF2.D_E_L_E_T_ <> '*') "

	cWhere  += " AND (SF3.F3_NFISCAL =  SF2.F2_DOC) "
	cWhere  += " AND (SF3.F3_SERIE   =  SF2.F2_SERIE) "
	cWhere  += " AND (SF3.F3_FILIAL  = '"+xFilial("SF3")+"') "
	cWhere  += " AND (SF3.F3_CFO     IN ('511','512','611','711')) "	// Somente: (511) Venda no Estado; (512) Sucata; (611) Fora do Estado; (711) Exportacao.
	cWhere  += " AND (SF3.F3_NFISCAL+SF3.F3_SERIE NOT IN (SELECT SF1.F1_DOC+SF1.F1_SERIE "
	cWhere  +=                                  " FROM "+RetSqlName("SF1")+" SF1 "
	cWhere  +=                                  " WHERE "
	cWhere  +=                                  "      (SF1.F1_DOC   = SF2.F2_DOC) "
	cWhere  +=                                  "  AND (SF1.F1_SERIE = SF2.F2_SERIE) "
	cWhere  +=                                  "  AND (SF2.D_E_L_E_T_ <> '*') )) " // Exceto Nf devolvidas.
	cWhere  += " AND (SF3.D_E_L_E_T_ <> '*') "						// Exceto NF deletadas.

	cWhere  += " AND (SA1.A1_COD     = SF2.F2_CLIENTE) "
	cWhere  += " AND (SA1.A1_LOJA    = SF2.F2_LOJA) "
	cWhere  += " AND (SA1.D_E_L_E_T_ <> '*') "						// Exceto Clientes deletados.

	cQuery  += cWhere
	TCQuery cQuery Alias "X" New
	nTotRegs := X->TOTREGS
	X->(DbCloseArea())

	if nTotRegs > 0
		cGrupo  := ""
		cQuery  := ""
		cQuery  += "SELECT "
		cQuery  += "       SA3.A3_COD,     "
		cQuery  += "       SA3.A3_NOME,    "
		cQuery  += "       SA1.A1_COD,     "
		cQuery  += "       SA1.A1_LOJA,    "
		cQuery  += "       SA1.A1_NREDUZ,  "
		cQuery  += "       SA1.A1_MUN,     "
		cQuery  += "       SA1.A1_EST      "
		cQuery  += cWhere
		cQuery  += "GROUP BY SA3.A3_COD, SA3.A3_NOME, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NREDUZ, SA1.A1_MUN, SA1.A1_EST "
		cQuery  += "ORDER BY SA3.A3_COD, SA1.A1_COD, SA1.A1_LOJA "
		TCQuery cQuery Alias "QRY" New

		ProcRegua(nTotRegs)
		do while QRY->(!EOF())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Incrementa a regua somente a cada novo representante.                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if cGrupo <> QRY->A3_COD+" - "+QRY->A3_NOME
				IncProc("Analizando NFs faturadas por representante ...")
				cGrupo := QRY->A3_COD+" - "+QRY->A3_NOME
			endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o Faturado Acumulado nos ultimos 12 meses.                       ³
			//³ Calcula o Preco Medio  nos ultimos 12 meses.                             ³
			//³ Calcula a Quantidade faturada nos ultimos 12 meses.                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery  := ""
			cQuery  += "SELECT "
			cQuery  +=       " SUM(SD2.D2_TOTAL)  AS TOTAL, "
			cQuery  +=       " SUM(SD2.D2_QUANT)  AS QUANT  "
			cQuery  += "FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SF3")+" SF3, "+RetSqlName("SD2")+" SD2 "
			cQuery  += "WHERE "
			cQuery  += "     (SF2.F2_VEND1   = '"+QRY->A3_COD+"') "
			cQuery  += " AND (SF2.F2_FILIAL  =  '"+xFilial("SF2")+"')  "
			cQuery  += " AND (SF2.F2_CLIENTE = '"+QRY->A1_COD+"') "
			cQuery  += " AND (SF2.F2_LOJA    = '"+QRY->A1_LOJA+"') "
			cQuery  += " AND (SF2.F2_EMISSAO >= '"+dtos(ctod("01/"+U_MesAno(DDATABASE,,-11)))+"') "
			cQuery  += " AND (SF2.F2_EMISSAO <= '"+dtos(U_UltDiaM(DDATABASE))+"') "
			cQuery  += " AND (SF2.F2_TIPO    =  'N') "									// Somente Notas Fiscais.
			cQuery  += " AND (SF2.D_E_L_E_T_ <> '*') "
			cQuery  += " AND (SF3.F3_NFISCAL =  SF2.F2_DOC) "
			cQuery  += " AND (SF3.F3_SERIE   =  SF2.F2_SERIE) "
			cQuery  += " AND (SF3.F3_FILIAL  = '"+xFilial("SF3")+"') "
			cQuery  += " AND (SF3.F3_CFO     IN ('511','512','611','711')) "	// Somente: (511) Venda no Estado; (512) Sucata; (611) Fora do Estado; (711) Exportacao.
			cQuery  += " AND (SF3.F3_NFISCAL+SF3.F3_SERIE NOT IN (SELECT SF1.F1_DOC+F1_SERIE "
			cQuery  +=                                  " FROM "+RetSqlName("SF1")+" SF1 "
			cQuery  +=                                  " WHERE "
			cQuery  +=                                  "      (SF1.F1_DOC   = SF2.F2_DOC) "
			cQuery  +=                                  "  AND (SF1.F1_SERIE = SF2.F2_SERIE) "
			cQuery  +=                                  "  AND (SF2.D_E_L_E_T_ <> '*') )) " // Exceto Nf devolvidas.
			cQuery  += " AND (SF3.D_E_L_E_T_ <> '*') "  					  // Exceto NF deletadas.
			cQuery  += " AND (SD2.D2_DOC    =  SF2.F2_DOC) "
			cQuery  += " AND (SD2.D2_SERIE  =  SF2.F2_SERIE) "
			cQuery  += " AND (SD2.D2_FILIAL = '"+xFilial("SD2")+"') "
			cQuery  += " AND (SD2.D_E_L_E_T_ <> '*') "
			TCQuery cQuery Alias "X" New
			nFA12MTot := X->TOTAL
			nFA12MQun := X->QUANT
			X->(DbCloseArea())

			cMesPesq  := iif(month(DDATABASE) == 1,"12",strzero(month(DDATABASE)-1,2))
			cAnoPesq  := iif(month(DDATABASE) == 1,strzero(year(DDATABASE)-1,4),strzero(year(DDATABASE),4))
			aFA03MTot := {0,0,0}
			for i:=1 to 3
				dDataInic := ctod("01/"+cMesPesq+"/"+cAnoPesq)
				dDataFina := U_UltDiaM(dDataInic)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o Faturado Acumulado nos mes indicado pelo periodo acima.        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cQuery  := ""
				cQuery  += "SELECT SUM(SD2.D2_TOTAL) AS TOTAL "
				cQuery  += "FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SF3")+" SF3, "+RetSqlName("SD2")+" SD2 "
				cQuery  += "WHERE "
				cQuery  += "     (SF2.F2_VEND1   = '"+QRY->A3_COD+"') "
				cQuery  += " AND (SF2.F2_FILIAL  =  '"+xFilial("SF2")+"')  "
				cQuery  += " AND (SF2.F2_CLIENTE = '"+QRY->A1_COD+"') "
				cQuery  += " AND (SF2.F2_LOJA    = '"+QRY->A1_LOJA+"') "
				cQuery  += " AND (SF2.F2_EMISSAO >= '"+dtos(dDataInic)+"') "
				cQuery  += " AND (SF2.F2_EMISSAO <= '"+dtos(dDataFina)+"') "
				cQuery  += " AND (SF2.F2_TIPO    =  'N') "									// Somente Notas Fiscais.
				cQuery  += " AND (SF2.D_E_L_E_T_ <> '*') "
				cQuery  += " AND (SF3.F3_NFISCAL =  SF2.F2_DOC) "
				cQuery  += " AND (SF3.F3_SERIE   =  SF2.F2_SERIE) "
				cQuery  += " AND (SF3.F3_FILIAL  = '"+xFilial("SF3")+"') "
				cQuery  += " AND (SF3.F3_CFO     IN ('511','512','611','711')) "	// Somente: (511) Venda no Estado; (512) Sucata; (611) Fora do Estado; (711) Exportacao.
				cQuery  += " AND (SF3.F3_NFISCAL+SF3.F3_SERIE NOT IN (SELECT SF1.F1_DOC+SF1.F1_SERIE "
				cQuery  +=                                  " FROM "+RetSqlName("SF1")+" SF1 "
				cQuery  +=                                  " WHERE "
				cQuery  +=                                  "      (SF1.F1_DOC   = SF2.F2_DOC) "
				cQuery  +=                                  "  AND (SF1.F1_SERIE = SF2.F2_SERIE) "
				cQuery  +=                                  "  AND (SF2.D_E_L_E_T_ <> '*') )) " // Exceto Nf devolvidas.
				cQuery  += " AND (SF3.D_E_L_E_T_ <> '*') "  					  // Exceto NF deletadas.
				cQuery  += " AND (SD2.D2_DOC    =  SF2.F2_DOC) "
				cQuery  += " AND (SD2.D2_SERIE  =  SF2.F2_SERIE) "
				cQuery  += " AND (SD2.D2_FILIAL = '"+xFilial("SD2")+"') "
				cQuery  += " AND (SD2.D_E_L_E_T_ <> '*') "
				TCQuery cQuery Alias "X" New
				aFA03MTot[i] := X->TOTAL
				X->(DbCloseArea())

				cMesPesq := iif(cMesPesq == "01","12",strzero(val(cMesPesq)-1,2))
				cAnoPesq := iif(cMesPesq == "01",strzero(val(cAnoPesq)-1,2),cAnoPesq)
			next

			RecLock("REL",.T.)
			REL->CODREP    := QRY->A3_COD
			REL->NOMREP    := QRY->A3_NOME
			REL->CODCLI    := QRY->A1_COD
			REL->LOJCLI    := QRY->A1_LOJA
			REL->NOMCLI    := QRY->A1_NREDUZ
			REL->CIDADE    := QRY->A1_MUN
			REL->UF        := QRY->A1_EST
			REL->FATAC12M  := nFA12MTot
			REL->PRCMEDIO  := (nFA12MTot / nFA12MQun)
			REL->AC12MM2   := nFA12MQun
			REL->FATUL3M1  := aFA03MTot[1]
			REL->FATUL3M2  := aFA03MTot[2]
			REL->FATUL3M3  := aFA03MTot[3]
			REL->(DBUnlock())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula totais gerais.                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTGFA12MT   := nTGFA12MT + nFA12MTot
			nTGFA12MQ   := nTGFA12MQ + nFA12MQun
			aTGFA03M[1]	:= aTGFA03M[1] + aFA03MTot[1]
			aTGFA03M[2]	:= aTGFA03M[1] + aFA03MTot[2]
			aTGFA03M[3]	:= aTGFA03M[1] + aFA03MTot[3]

			QRY->(DBSkip())
		enddo
		QRY->(DBCloseArea())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula Participacao Individual e Acumulada.                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPartAcu  := 0
		nMGFA12MM := nTGFA12MT / nTGFA12MQ
		cGrupo    := ""

		REL->(DBCloseArea())
		DbUseArea(.T.,,cArqTemp1,"REL")
		REL->(DbCreateInd(cArqTemp1+".001","CODREP+descend(str(FATAC12M))", {||CODREP+descend(str(FATAC12M))}))

		ProcRegua(REL->(LastRec()))
		REL->(DBGoTop())
		do while REL->(!EOF())

			IncProc("Calculando a participacao individual dos clientes ...")

			if cGrupo <> REL->CODREP
				cGrupo := REL->CODREP
				nRank  := 1
			endif

			RecLock("REL",.F.)
			REL->RANK     := transform(nRank,"9999o")
			REL->PRTINDIV := (REL->FATAC12M * 100) / nTGFA12MT
			nPartAcu       := nPartAcu + (REL->FATAC12M * 100) / nTGFA12MT
			REL->PRTPERAC := nPartAcu
			REL->(DBUnlock())

			nRank++
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
	//³ Inicializa variaveis necessarias a impressao.                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cGrupo     := ""
	nTPFA12MT   := 0
	nMPFA12MM   := 0
	nTPFA12MQ   := 0
	aTPFA03M  	:= {0,0,0}

	ProcRegua(REL->(LastRec()))
	REL->(DBGoTop())
	do while !REL->(EOF())

		IncProc("Imprimindo ...")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o cancelamento pelo usuario...                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Interrupcao(@lAbortPrint)
			Return
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime parametros.                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if m_pag == 1
			cOldArea := Alias()
			DBSelectArea("SX1")
			DBSetOrder(1)

			if SX1->(DBSeek(cNomeProg+"01"))
				do while SX1->X1_GRUPO == cNomeProg
					if nL >= 65
						nL := Cabec("Parametros - "+cTitulo,"","",cNomeProg,cTamanho,nCrcControl) + 2
					endif

					cLinDeImp := ""
					cLinDeImp += "Pergunta "+SX1->X1_ORDEM+": "+SX1->X1_PERGUNT+"  "+SX1->X1_CNT01
					@ nL,000 PSay cLinDeImp
					nL+=2
					SX1->(DBSkip())
				enddo
				Roda(nCbCont, cCbtxt, cTamanho)
			endif
			DBSelectArea(cOldArea)
			nL := 99
		endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho.												     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if nL >= 65
			nL := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCrcControl) + 1
		endif

		if cGrupo <> REL->CODREP
			if cGrupo <> ""
				nL++
				cLinDeImp := ""
				cLinDeImp += "Total do Repres.:"+space(48)
				cLinDeImp += u_rtoc(nTPFA12MT) + space(2)
				cLinDeImp += u_rtoc(nMPFA12MM,"@E 9,999.99") + space(1)
				cLinDeImp += u_rtoc(nTPFA12MQ) + space(3)
				cLinDeImp += u_rtoc(aTPFA03M[1]) + space(1)
				cLinDeImp += u_rtoc(aTPFA03M[2]) + space(1)
				cLinDeImp += u_rtoc(aTPFA03M[3])
				@ nL,000 PSay cLinDeImp
				nL++

				nTPFA12MT   := 0
				nMPFA12MM   := 0
				nTPFA12MQ   := 0
				aTPFA03M  	:= {0,0,0}

				nL++
				cLinDeImp := ""
				cLinDeImp += REPL("-",171)
				@ nL,000 PSay cLinDeImp
				nL++
			endif

			cLinDeImp := ""
			cLinDeImp += "REPRESENTANTE: " + REL->CODREP + " - " +	REL->NOMREP
			@ nL,000 PSay cLinDeImp
			nL++
			nL++

			cGrupo := REL->CODREP
		endif

		cLinDeImp := ""
		cLinDeImp += REL->RANK + space(2)
		cLinDeImp += REL->CODCLI+"-"+REL->LOJCLI+" - "+REL->NOMCLI + space(2)
		cLinDeImp += REL->CIDADE + space(4)
		cLinDeImp += REL->UF + space(2)
		cLinDeImp += u_rtoc(REL->FATAC12M) + space(2)
		cLinDeImp += u_rtoc(REL->PRCMEDIO,"@E 9,999.99") + space(1)
		cLinDeImp += u_rtoc(REL->AC12MM2 ) + space(3)
		cLinDeImp += u_rtoc(REL->FATUL3M1) + space(1)
		cLinDeImp += u_rtoc(REL->FATUL3M2) + space(1)
		cLinDeImp += u_rtoc(REL->FATUL3M3) + space(2)
		cLinDeImp += u_rtoc(REL->PRTINDIV,"@E 9,999.99") + space(2)
		cLinDeImp += u_rtoc(REL->PRTPERAC,"@E 9,999.99")
		@ nL,000 PSay cLinDeImp
		nL++

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alimenta totais parciais.   										     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTPFA12MT   := nTPFA12MT + REL->FATAC12M
		nTPFA12MQ   := nTPFA12MQ + REL->AC12MM2
		nMPFA12MM   := nTPFA12MT / nTPFA12MQ
		aTPFA03M[1]	:= aTPFA03M[1] + REL->FATUL3M1
		aTPFA03M[2]	:= aTPFA03M[2] + REL->FATUL3M2
		aTPFA03M[3]	:= aTPFA03M[3] + REL->FATUL3M3

		REL->(DBSkip())
	enddo

	nL++
	cLinDeImp := ""
	cLinDeImp += "Total do Repres.:"+space(48)
	cLinDeImp += u_rtoc(nTPFA12MT) + space(2)
	cLinDeImp += u_rtoc(nMPFA12MM,"@E 9,999.99") + space(1)
	cLinDeImp += u_rtoc(nTPFA12MQ) + space(3)
	cLinDeImp += u_rtoc(aTPFA03M[1]) + space(1)
	cLinDeImp += u_rtoc(aTPFA03M[2]) + space(1)
	cLinDeImp += u_rtoc(aTPFA03M[3])
	@ nL,000 PSay cLinDeImp
	nL++

	nL++
	cLinDeImp := ""
	cLinDeImp += REPL("-",171)
	@ nL,000 PSay cLinDeImp
	nL++

	cLinDeImp := ""
	cLinDeImp += "TOTAL GERAL:"+space(54)
	cLinDeImp += u_rtoc(nTGFA12MT,"@E 99,999,999.99") + space(2)
	cLinDeImp += u_rtoc(nMGFA12MM,"@E 9,999.99") + space(2)
	cLinDeImp += u_rtoc(nTGFA12MQ,"@E 99,999,999.99") + space(4)
	cLinDeImp += u_rtoc(aTGFA03M[1],"@E 99,999,999.99") + space(2)
	cLinDeImp += u_rtoc(aTGFA03M[2],"@E 99,999,999.99") + space(2)
	cLinDeImp += u_rtoc(aTGFA03M[3],"@E 99,999,999.99")
	@ nL,000 PSay cLinDeImp

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime rodape.													 	     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Roda(nCbCont, cCbtxt, cTamanho)
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
