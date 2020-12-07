#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Ranisses Antonio Corona
Programa  := BIA855
Empresa   := Biancogres Cerêmicas S/A
Data      := 21/05/13
Uso       := Contabilidade
Aplicação := Rotina para geracao dos expurgos na empresa 90 - Consolidado
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

USER FUNCTION BIA855()

	If cEmpAnt <> "90"
		Msgbox("Esta rotina poderá ser utilizada somente na empresa 90 - Grupo Consolidado.","BIA855","STOP")
		Return()
	EndIf

	@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "PPC Empresas Coligadas"
	@ 8,10 TO 84,222

	@ 16,12 SAY "Esta rotina tem por finalidade:                        		"
	@ 24,12 SAY " 1-Calcular e gravar as planilhas PPC's das empresas Coligadas;"
	@ 32,12 SAY " 2-Consolidar as informações das planilhas;					"
	@ 40,12 SAY " 3-Contabilizar as informações consolidadas;					"
	@ 48,12 SAY " 4-Contabilizar os expurgos do CPV;							"
	@ 57,12 SAY " 5-Imprimir as planilhas PPC's.								"

	@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
	@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
	@ 91,137 BMPBUTTON TYPE 5 ACTION Pergunte("BIA855", .T.)

	ACTIVATE DIALOG oDlg5 CENTERED

	//Fecha arquivo temporario
	//definir tabelas para fechar


Return()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama rotina que realiza a transferencia³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function OkProc()
	Processa( {|| RunProc() } )
	Close(oDlg5)
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina que rateia e grava os investimentos
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function RunProc()
	Private cSql		:= ""
	Private Enter		:= CHR(13)
	Private nQtdReg		:= 0
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}

	//Abre Perguntas
	Pergunte("BIA855", .F.)
	//MV_PAR01 - 1-PPC / 2-CONSOLIDACAO / 3-CONTABILIZAÇÃO / 4-CONTABILIZACAO CPV / 5-IMPRESSÃO
	//MV_PAR02 - Periodo Inicial
	//MV_PAR03 - Periodo Final

	//Grava parametro do Periodo
	nMesAnoD := Substr(Dtos(MV_PAR02),1,6)
	nMesAnoA := Substr(Dtos(MV_PAR03),1,6)

	//GERA PLANILHAS PPC
	If MV_PAR01 == 1

		Processa( {|| CalculaPPC() } )

		//MONTA CONSOLIDAÇÃO
	ElseIf MV_PAR01 == 2

		Processa( {|| ConsolidaPPC() } )

		//REALIZA A CONTABILIZAÇÃO EXPURGOS
	ElseIf MV_PAR01 == 3

		Processa( {|| ContExpurgos() } )

		//REALIZA A CONTABILIZAÇÃO INVESTIMENTO
	ElseIf MV_PAR01 == 4

		MsgSTOP("Opção retirada de uso em 10/06/16", "Atenção")
		// Retirado em 10/06/16 por Marcos Alberto Soprani e acompanhado por Jean
		//	Processa( {|| ContINV() } )

	Else

		cSQL := ""
		cSQL += "ALTER VIEW VW_RAC_PPC AS 	" + Enter
		cSQL += "SELECT *					" + Enter
		cSQL += "FROM						" + Enter
		cSQL += "(SELECT EMP_ORI, EMP_DES, TP_PROD, TP_VLR " + Enter
		cSQL += "		,MES01 = ISNULL(SUM(CASE WHEN SUBSTRING(MES_ANO,5,2) = '01' THEN VLR END),0) " + Enter
		cSQL += "		,MES02 = ISNULL(SUM(CASE WHEN SUBSTRING(MES_ANO,5,2) = '02' THEN VLR END),0) " + Enter
		cSQL += "		,MES03 = ISNULL(SUM(CASE WHEN SUBSTRING(MES_ANO,5,2) = '03' THEN VLR END),0) " + Enter
		cSQL += "		,MES04 = ISNULL(SUM(CASE WHEN SUBSTRING(MES_ANO,5,2) = '04' THEN VLR END),0) " + Enter
		cSQL += "		,MES05 = ISNULL(SUM(CASE WHEN SUBSTRING(MES_ANO,5,2) = '05' THEN VLR END),0) " + Enter
		cSQL += "		,MES06 = ISNULL(SUM(CASE WHEN SUBSTRING(MES_ANO,5,2) = '06' THEN VLR END),0) " + Enter
		cSQL += "		,MES07 = ISNULL(SUM(CASE WHEN SUBSTRING(MES_ANO,5,2) = '07' THEN VLR END),0) " + Enter
		cSQL += "		,MES08 = ISNULL(SUM(CASE WHEN SUBSTRING(MES_ANO,5,2) = '08' THEN VLR END),0) " + Enter
		cSQL += "		,MES09 = ISNULL(SUM(CASE WHEN SUBSTRING(MES_ANO,5,2) = '09' THEN VLR END),0) " + Enter
		cSQL += "		,MES10 = ISNULL(SUM(CASE WHEN SUBSTRING(MES_ANO,5,2) = '10' THEN VLR END),0) " + Enter
		cSQL += "		,MES11 = ISNULL(SUM(CASE WHEN SUBSTRING(MES_ANO,5,2) = '11' THEN VLR END),0) " + Enter
		cSQL += "		,MES12 = ISNULL(SUM(CASE WHEN SUBSTRING(MES_ANO,5,2) = '12' THEN VLR END),0) " + Enter
		cSQL += "		,TOTAL  = ISNULL(SUM(CASE WHEN SUBSTRING(MES_ANO,1,4) = '2013' THEN VLR END),0) " + Enter
		cSQL += "FROM RAC_PPC  " + Enter
		cSQL += "WHERE MES_ANO >= '"+nMesAnoD+"' AND MES_ANO <= '"+nMesAnoA+"' " + Enter
		cSQL += "GROUP BY EMP_ORI, EMP_DES, TP_PROD, TP_VLR ) TMP " + Enter
		TcSQLExec(cSQL)

		//cOpcao:="4;0;1;PPC"	//EXCEL
		//cOpcao:="6;0;1;PPC"	//PDF
		//Callcrys("BIA855",+DTOC(MV_PAR02)+";"+DTOC(MV_PAR03),cOpcao, .T., .T., .T., .F. ) //ATIVANDO FUNÇÃO PARA GERAÇÃO DO RELATORIO NO SERVIDOR

		// aReturn[5]==1
		//Parametros Crystal Em Disco
		//cOpcao:="1;0;1;PPC"
		//se
		//Direto Impressora
		//Opcao:="3;0;1;PPC"
		//Endif

		cOpcao:="1;0;1;PPC"	//CRYSTAL
		//Chama Relatorio em Crystal
		Callcrys("BIA855",+DTOC(MV_PAR02)+";"+DTOC(MV_PAR03),cOpcao)

	EndIf

Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao para Contabilizar
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function fContResul(cEmp,cFil,fgLanPad,fgLotCtb,fgVetCtb,dData)

	RPCSetType(3)
	RPCSETENV(cEmp,cFil,,,"CTB")

	dDataBase  := dData//fgVetCtb[1][6]

	U_fRACCtbAV(fgLanPad, fgLotCtb, fgVetCtb)

	RpcClearEnv()

Return()

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fRACCtbAV     ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 30/01/13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Aplicação ¦  Rotina desenvolvida para contabilizações avulsas diversas ¦¦¦
¦¦¦          ¦ Ela recebe um vetor contendo as informações necessárias    ¦¦¦
¦¦¦          ¦ para a montagem do lançamento, como por exemplo conta deb. ¦¦¦
¦¦¦          ¦ conta cred., valor, centro de custo, histórico, etc.       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function fRACCtbAV(fgLanPad, fgLotCtb, fgVetCtb)

	Local nreg
	Local  hj

	Private LCABECALHO, CPADRAO, LPADRAO, NTOTAL, CLOTE, LDIGITA
	Private LAGLUT, CARQUIVO, AROTINA, NHDLPRV
	Private cdeb, ccred, chis, nval, cult

	Public msVthj01
	Public msVthj02
	Public msVthj03
	Public msVthj04
	Public msVthj05

	lCabecalho := .F.
	cPadrao    := fgLanPad
	lPadrao    := .F.
	nTotal     := 0
	clote      := fgLotCtb
	lDigita    := .T.
	lAglut     := .F.
	carquivo   := ""
	aRotina    := {}
	aArrayCt   := fgVetCtb

	c_contad := 0
	For hj := 1 to Len(aArrayCt)

		c_contad ++
		lPadrao := VerPadrao( cPadrao )
		If lPadrao

			If !lCabecalho
				a370Cabecalho(@nHdlPrv,@cArquivo)
			Endif

			msVthj01 := aArrayCt[hj][1]
			msVthj02 := aArrayCt[hj][2]
			msVthj03 := aArrayCt[hj][3]
			msVthj04 := aArrayCt[hj][4]
			msVthj05 := aArrayCt[hj][5]

			nTotal  := nTotal + DetProva(nHdlPrv, cPadrao, "fRACCtbAV", cLote)
			cult := .F.

		EndIf

		If c_contad == 900
			c := 2
			Exit
		EndIf

	Next hj

	If lCabecalho
		RodaProva(nHdlPrv,nTotal)
	Endif

	If lPadrao
		cA100Incl(cArquivo ,nHdlPrv ,3,cLote ,lDigita , lAglut  )
	End

	If cult == .F.
		fbCont()
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fbCont        ¦ Autor ¦ Marcos Alberto   ¦ Data ¦ 30/01/13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fbCont()

	If lCabecalho
		RodaProva(nHdlPrv,nTotal)
	Endif
	If lPadrao
		cA100Incl(cArquivo ,nHdlPrv ,3,cLote ,lDigita , lAglut  )
	End

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ xConvLog ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 17.04.12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Converter log de Erro em texto simples                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xCon1Log(aAutoErro)

	Local cRet := ""
	Local nX   := 1

	For nX := 1 to Len(aAutoErro)
		cRet += aAutoErro[nX] + CHR(13)+CHR(13)
	Next nX

Return cRet



/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ContINV  ¦ Autor ¦ Ranisses A. Corona    ¦ Data ¦ 22.05.14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Contabiliza os estornos de investimentos.                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ContINV()
	Local nQtdReg := 0

	//Seleciona os registros para serem contabilizados
	cSql := "SELECT '01' EMP, 'BIANCOGRES' EMPRESA, CT2_DATA, CT2_DEBITO, CT2_CREDIT, CT2_CCD, CT2_CCC, CT2_ITEMD, CT2_ITEMC, CT2_VALOR, CT2_HIST "
	cSql += "FROM CT2010 "
	cSql += "WHERE CT2_FILIAL = '"+xFilial('CT2')+"' AND SUBSTRING(CT2_ITEMD,1,3) = 'I03' AND CT2_DATA >= '"+Dtos(MV_PAR02)+"' AND CT2_DATA <= '"+Dtos(MV_PAR03)+"' AND D_E_L_E_T_ = '' "
	cSql += "UNION ALL "
	cSql += "SELECT '05' EMP, 'INCESA' EMPRESA, CT2_DATA, CT2_DEBITO, CT2_CREDIT, CT2_CCD, CT2_CCC, CT2_ITEMD, CT2_ITEMC, CT2_VALOR, CT2_HIST "
	cSql += "FROM CT2050 "
	cSql += "WHERE CT2_FILIAL = '"+xFilial('CT2')+"' AND SUBSTRING(CT2_ITEMD,1,3) = 'I03' AND CT2_DATA >= '"+Dtos(MV_PAR02)+"' AND CT2_DATA <= '"+Dtos(MV_PAR03)+"' AND D_E_L_E_T_ = '' "
	cSql += "ORDER BY EMP, CT2_DATA "
	If chkfile("CPV")
		dbSelectArea("CPV")
		dbCloseArea()
	EndIf
	TcQuery cSql New Alias "CPV"

	fgLanPad := "P05"
	fgLotCtb := "002500"
	fgVetCtb := {}

	nFilEmp	 := CPV->EMP
	MesAno	 := CPV->CT2_DATA

	//Define a quantidade de registros
	cSql := "SELECT '01' EMP, 'BIANCOGRES' EMPRESA, CT2_DATA, CT2_DEBITO, CT2_CREDIT, CT2_CCD, CT2_CCC, CT2_ITEMD, CT2_ITEMC, CT2_VALOR, CT2_HIST, "
	cSql += "		ROW_NUMBER() OVER(ORDER BY CT2_DATA) AS ROW_ID															 "
	cSql += "FROM CT2010 "
	cSql += "WHERE CT2_FILIAL = '"+xFilial('CT2')+"' AND SUBSTRING(CT2_ITEMD,1,3) = 'I03' AND CT2_DATA >= '"+Dtos(MV_PAR02)+"' AND CT2_DATA <= '"+Dtos(MV_PAR03)+"' AND D_E_L_E_T_ = '' "
	cSql += "UNION ALL "
	cSql += "SELECT '05' EMP, 'INCESA' EMPRESA, CT2_DATA, CT2_DEBITO, CT2_CREDIT, CT2_CCD, CT2_CCC, CT2_ITEMD, CT2_ITEMC, CT2_VALOR, CT2_HIST, "
	cSql += "		ROW_NUMBER() OVER(ORDER BY CT2_DATA) AS ROW_ID															 "
	cSql += "FROM CT2050 "
	cSql += "WHERE CT2_FILIAL = '"+xFilial('CT2')+"' AND SUBSTRING(CT2_ITEMD,1,3) = 'I03' AND CT2_DATA >= '"+Dtos(MV_PAR02)+"' AND CT2_DATA <= '"+Dtos(MV_PAR03)+"' AND D_E_L_E_T_ = '' "
	cSql += "ORDER BY ROW_ID "
	If chkfile("QTD")
		dbSelectArea("QTD")
		dbCloseArea()
	EndIf
	TcQuery cSql New Alias "QTD"

	nQtdReg  := QTD->ROW_ID

	Procregua(nQtdReg)

	While !CPV->(EOF())

		IncProc("Contabilizando Expurgos de Investimentos... "+CPV->EMPRESA)

		If nFilEmp <> CPV->EMP .Or. MesAno <> CPV->CT2_DATA
			StartJob( "U_fContResul", GetEnvServer(),.T.,cEmpAnt,nFilEmp,fgLanPad, fgLotCtb, fgVetCtb,Lastday(STOD(SUBSTR(MesAno,1,6)+"01"),0))
			fgVetCtb := {}
		EndIf

		nFilEmp	:= CPV->EMP
		MesAno	:= CPV->CT2_DATA

		nCtaCrd := CPV->CT2_DEBITO
		If Alltrim(CPV->CT2_ITEMD) == "I0301" .Or. Alltrim(CPV->CT2_ITEMC) == "I0301"
			nCtaDeb	:= "31401009"
		ElseIf Alltrim(CPV->CT2_ITEMD) == "I0302" .Or. Alltrim(CPV->CT2_ITEMC) == "I0302"
			nCtaDeb	:= "31401004"
		ElseIf Alltrim(CPV->CT2_ITEMD) == "I0303" .Or. Alltrim(CPV->CT2_ITEMC) == "I0303"
			nCtaDeb	:= "31401019"
		ElseIf Alltrim(CPV->CT2_ITEMD) == "I0304" .Or. Alltrim(CPV->CT2_ITEMC) == "I0304"
			nCtaDeb	:= "31401004"
		Else
			nCtaDeb	:= "31401020"
		EndIf
		//                 1        2        3      4           5            6                   7                           8          9         10         11
		// Vetor ==>>   Debito,  Credito, ClVl_D, ClVl_C, Item_Contab_D, Item_Contab_C,        Valor,                      Histórico, CCUSTO_D, CCUSTO_C, ORIGEM
		Aadd(fgVetCtb, {nCtaDeb, nCtaCrd,     "",     "",            "",            "", Abs(CPV->CT2_VALOR), "VLR. REF. ESTORNO CPV",      "" ,      "", "P05001"})

		CPV->(dbSkip())
	End

	If nFilEmp <> CPV->EMP .Or. MesAno <> CPV->CT2_DATA
		StartJob( "U_fContResul", GetEnvServer(),.T.,cEmpAnt,nFilEmp,fgLanPad, fgLotCtb, fgVetCtb,Lastday(STOD(SUBSTR(MesAno,1,6)+"01"),0))
		fgVetCtb := {}
	EndIf

	Msgbox("Contabilização dos Expurgos de Investimentos finalizada com sucesso.","BIA855","INFO")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ContExpurgos ¦ Autor ¦ Ranisses Corona   ¦ Data ¦ 22.05.14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Contabiliza os estornos de investimentos.                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ContExpurgos()
	Local nQtdReg := 0

	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//LÊ CONSOLIDAÇÃO E EXECUTA CONTABILIZAÇÃO
	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cSql := "SELECT * 				"
	cSql += "FROM RAC_CONSOLIDACAO	"
	cSql += "WHERE 	VLR  <> 0 AND 	"
	cSql += "		MES_ANO >= '"+nMesAnoD+"' AND MES_ANO <= '"+nMesAnoA+"' AND  "
	cSql += "		FLAG = 'N'  	"
	//cSql += "ORDER BY MES_ANO, DT_LANC, EMP, TIPO 	"
	cSql += "ORDER BY EMP, DT_LANC, TIPO "
	If chkfile("CONSOL")
		dbSelectArea("CONSOL")
		dbCloseArea()
	EndIf
	TcQuery cSql New Alias "CONSOL"

	fgLanPad := "P04"
	fgLotCtb := "002400"
	fgVetCtb := {}

	nFilEmp	 := CONSOL->EMP
	//MesAno	 := CONSOL->MES_ANO
	DtLanc	:= CONSOL->DT_LANC

	cSql := "SELECT COUNT(*) AS ROW_ID "
	cSql += "FROM RAC_CONSOLIDACAO	   "
	cSql += "WHERE 	VLR  <> 0 AND 	   "
	cSql += "		MES_ANO >= '"+nMesAnoD+"' AND MES_ANO <= '"+nMesAnoA+"' AND  "
	cSql += "		FLAG = 'N'  	"
	If chkfile("QTD")
		dbSelectArea("QTD")
		dbCloseArea()
	EndIf
	TcQuery cSql New Alias "QTD"

	nQtdReg := QTD->ROW_ID
	dbSelectArea("QTD")
	dbCloseArea()

	ProcRegua(nQtdReg)

	While !CONSOL->(EOF())

		If CONSOL->EMP == "01"
			nEmpresa := "BIANCOGRES"
		ElseIf CONSOL->EMP == "05"
			nEmpresa := "INCESA"
		ElseIf CONSOL->EMP == "06"
			nEmpresa := "JK"
		ElseIf CONSOL->EMP == "07"
			nEmpresa := "LM"
		ElseIf CONSOL->EMP == "12"
			nEmpresa := "ST GESTÃO"
		ElseIf CONSOL->EMP == "13"
			nEmpresa := "MUNDI"
		ElseIf CONSOL->EMP == "14"
			nEmpresa := "VITCER"
		EndIf

		IncProc("Contabilizando Expurgos... "+nEmpresa)

		//If nFilEmp <> CONSOL->EMP .Or. MesAno <> CONSOL->MES_ANO
		If nFilEmp <> CONSOL->EMP .Or. 	DtLanc <> CONSOL->DT_LANC
			StartJob( "U_fContResul", GetEnvServer(),.T.,cEmpAnt,nFilEmp,fgLanPad, fgLotCtb, fgVetCtb,Stod(DtLanc))
			//U_fRACCtbAV(fgLanPad, fgLotCtb, fgVetCtb)
			fgVetCtb := {}
		EndIf

		nFilEmp	:= CONSOL->EMP
		//MesAno	:= CONSOL->MES_ANO
		DtLanc	:= CONSOL->DT_LANC

		//Define Tipo Lançamento
		//If CONSOL->VLR < 0
		//	If CONSOL->TP_LANC == "D"
		//		nTpLanc := "C"
		//	Else
		//		nTpLanc := "D"
		//	EndIf
		//Else
		//	nTpLanc := CONSOL->TP_LANC
		//EndIf

		// Vetor ==>> TIPO, CONTA, VALOR, HISTORICO, ORIGEM
		Aadd(fgVetCtb, {CONSOL->TP_LANC, CONSOL->CONTA, Abs(CONSOL->VLR), "VLR. REF. CONSOLIDACAO EMPRESA", "P04 "+CONSOL->TIPO+" "+CONSOL->TP_PROD})

		CONSOL->(dbSkip())
	End

	If nFilEmp <> CONSOL->EMP .Or. 	DtLanc <> CONSOL->DT_LANC
		//StartJob( "U_fContResul", GetEnvServer(),.T.,cEmpAnt,nFilEmp,fgLanPad, fgLotCtb, fgVetCtb, Lastday(STOD(MesAno+"01"),0))
		StartJob( "U_fContResul", GetEnvServer(),.T.,cEmpAnt,nFilEmp,fgLanPad, fgLotCtb, fgVetCtb, Stod(DtLanc))
		fgVetCtb := {}
	EndIf

	//Marca tabela RAC_CONSOLIDAÇÃO como já processada
	cSql := "UPDATE RAC_CONSOLIDACAO SET FLAG = 'S' 						    "
	cSql += "WHERE 															    "
	cSql += "		MES_ANO >= '"+nMesAnoD+"' AND MES_ANO <= '"+nMesAnoA+"' AND "
	cSql += "		FLAG = 'N'  	"
	TcSQLExec(cSql)

	Msgbox("Contabilização dos Expurgos finalizada com sucesso.","BIA855","INFO")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ CalculaPPC   ¦ Autor ¦ Ranisses Corona   ¦ Data ¦ 22.05.14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Calcula valores para montar planilhas PPC                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function CalculaPPC()
	Local nQtdReg := 06
	Local EmprOri := ""
	Local EmprDes := ""
	Local i
	Local n

	//Carrega Empresas Coligadas
	cAliasEMP_COL := GetNextAlias()
	BeginSql Alias cAliasEMP_COL
		SELECT * FROM RAC_EMPRESAS_COLIGADAS ORDER BY COD_EMP
	EndSql

	ProcRegua(1000)
	For i:= 1 to 1000
		IncProc("Iniciando Processo...")
	Next

	ProcRegua(nQtdReg)

	//Verifica todas as Empresas Coligadas
	While  !(cAliasEMP_COL)->(EOF())

		IncProc("Calculando Operações da Empresa -> "+(cAliasEMP_COL)->EMPRESA )

		//Verifica as operações entre as coligadas
		cSql := "SELECT EMP_ORI, EMP_DES, CODCLI, CUSTO_IMP, DIF_PIS, DIF_COFINS "
		cSql += "FROM RAC_EMPRESAS_COLIGADAS, RAC_OPERACOES_EMPRESAS_COLIGADAS	 "
		cSql += "WHERE EMP_ORI = COD_EMP 										 "
		cSql += "	AND EMP_ORI = '"+(cAliasEMP_COL)->COD_EMP+"' 				 "
		cSql += "GROUP BY EMP_ORI, EMP_DES, CODCLI, CUSTO_IMP, DIF_PIS, DIF_COFINS "
		cSql += "ORDER BY EMP_ORI , EMP_DES, CODCLI 							 "
		If chkfile("OPER_COL")
			dbSelectArea("OPER_COL")
			dbCloseArea()
		EndIf
		TcQuery cSql New Alias "OPER_COL"

		While  !OPER_COL->(EOF())

			If !Empty(Alltrim(OPER_COL->CODCLI))
				//Apura as informações do PPC - RECEITA
				cSql := "SELECT SUBSTRING(D2_EMISSAO,1,6) MESANO, B1_GRUPO GRUPO, SUM(VALOR) 'VLR_0101', SUM(D2_VALICM) 'VLR_0102', SUM(D2_VALIMP6) 'VLR_0103' , SUM(D2_VALIMP5) 'VLR_0104' " + Enter
				cSql += "FROM 	( 												" + Enter
				cSql += "		  SELECT QUANT  = CASE							" + Enter
				cSql += "							WHEN D2_TIPO = 'I' AND D2_ICMSRET > 0 THEN 0	" + Enter
				cSql += "							WHEN F4_CREDICM = 'S' AND F4_ICM = 'S' AND F4_LFICM = 'T' AND F4_DUPLIC = 'N' THEN 0 " + Enter
				cSql += "						ELSE D2_TOTAL END,				" + Enter
				cSql += "				 VALOR  = CASE							" + Enter
				cSql += "							WHEN D2_TIPO = 'I' AND D2_ICMSRET > 0 THEN 0	" + Enter
				cSql += "							WHEN F4_CREDICM = 'S' AND F4_ICM = 'S' AND F4_LFICM = 'T' AND F4_DUPLIC = 'N' THEN 0 " + Enter
				cSql += "						ELSE D2_TOTAL END,				" + Enter
				cSql += "				D2_CLIENTE, D2_VALICM, D2_VALIMP6, D2_VALIMP5, D2_DOC, D2_COD, D2_EMISSAO, D2_TIPO, D2_CF, F4_CREDICM, F4_ICM, F4_LFICM, F4_DUPLIC " + Enter
				cSql += "		FROM SD2"+OPER_COL->EMP_ORI+"0 D2, SF4"+OPER_COL->EMP_ORI+"0 F4	" + Enter
				cSql += "		WHERE D2.D2_FILIAL 	= '"+xFilial('SD2')+"'  AND " + Enter
				cSql += "		      D2.D2_TES    	= F4.F4_CODIGO			AND " + Enter
				cSql += "		      D2.D_E_L_E_T_	= ''					AND " + Enter
				cSql += "		      F4.D_E_L_E_T_	= ''   						" + Enter
				cSql += "					      ) 							" + Enter
				cSql += "	  SD2 INNER JOIN SB1010 SB1 ON 						" + Enter
				cSql += "	  SD2.D2_COD = SB1.B1_COD     						" + Enter
				cSql += "WHERE SD2.D2_EMISSAO	>= '"+Dtos(MV_PAR02)+"' AND		" + Enter
				cSql += "      SD2.D2_EMISSAO 	<= '"+Dtos(MV_PAR03)+"' AND		" + Enter
				cSql += "      SB1.B1_GRUPO 	IN (SELECT TP_PROD FROM RAC_OPERACOES_EMPRESAS_COLIGADAS WHERE EMP_ORI = '"+OPER_COL->EMP_ORI+"' ) AND  " + Enter
				If OPER_COL->EMP_ORI <> OPER_COL->EMP_DES
					cSql += "      SD2.D2_CLIENTE 	IN (SELECT CODCLI FROM RAC_OPERACOES_EMPRESAS_COLIGADAS, RAC_EMPRESAS_COLIGADAS WHERE EMP_DES = COD_EMP AND EMP_ORI = '"+OPER_COL->EMP_ORI+"' AND EMP_DES = '"+OPER_COL->EMP_DES+"') AND " + Enter
				EndIf
				cSql += "      SD2.D2_TIPO      <> 'D'  				AND	" + Enter
				cSql += "      (      										" + Enter
				cSql += "      (SD2.F4_CREDICM	= 'S'  					AND	" + Enter
				cSql += "	    SD2.F4_ICM		= 'S'  					AND	" + Enter
				cSql += "	    SD2.F4_LFICM	= 'T'  					AND	" + Enter
				cSql += "       SD2.F4_DUPLIC  	= 'N'  					AND	" + Enter
				cSql += "      ( SUBSTRING(SD2.D2_CF,2,1) IN ('1','4','2') OR SUBSTRING(SD2.D2_CF,2,3) = '923' )  ) OR SD2.F4_DUPLIC = 'S' " + Enter
				cSql += "      ) 	AND										" + Enter
				cSql += "      SB1.D_E_L_E_T_ 	= ''		  				" + Enter
				cSql += "GROUP BY SUBSTRING(D2_EMISSAO,1,6), B1_GRUPO		" + Enter
				cSql += "ORDER BY SUBSTRING(D2_EMISSAO,1,6), B1_GRUPO		" + Enter
				If chkfile("_PPC_R")
					dbSelectArea("_PPC_R")
					dbCloseArea()
				EndIf
				TcQuery cSql New Alias "_PPC_R"

				//Grava as informações do PPC - RECEITA
				While  !_PPC_R->(EOF())

					//Receita
					cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','01.01','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0101))+") "
					TcSQLExec(cSql)

					//ICMS
					cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','01.02','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0102))+") "
					TcSQLExec(cSql)

					//PIS
					cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','01.03','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0103))+") "
					TcSQLExec(cSql)

					//COFINS
					cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','01.04','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0104))+") "
					TcSQLExec(cSql)

					If OPER_COL->DIF_PIS > 0
						//PIS
						cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','01.05','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0101*OPER_COL->DIF_PIS))+") "
						TcSQLExec(cSql)
					EndIf

					If OPER_COL->DIF_COFINS > 0
						//COFINS
						cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','01.06','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0101*OPER_COL->DIF_COFINS))+") "
						TcSQLExec(cSql)
					EndIf

					_PPC_R->(dbSkip())
				End

				cSql := "SELECT SUBSTRING(D1_DTDIGIT,1,6) AS 'MESANO', B1_GRUPO AS 'GRUPO', SUM(D1_TOTAL-D1_VALDESC)*-1 'VLR_0201', SUM(D1_VALICM)*-1 'VLR_0202', SUM(D1_VALIMP6)*-1 'VLR_0203', SUM(D1_VALIMP5)*-1 'VLR_0204' " + Enter
				cSql += "FROM SD1"+OPER_COL->EMP_ORI+"0 SD1 INNER JOIN SD2"+OPER_COL->EMP_ORI+"0 SD2 ON	" + Enter
				cSql += "	SD1.D1_NFORI	= SD2.D2_DOC		AND	" + Enter
				cSql += "    SD1.D1_ITEMORI	= SD2.D2_ITEM		AND	" + Enter
				cSql += "    SD1.D1_SERIORI	= SD2.D2_SERIE		AND	" + Enter
				cSql += "    SD1.D1_FORNECE	= SD2.D2_CLIENTE	AND	" + Enter
				cSql += "    SD1.D1_LOJA		= SD2.D2_LOJA		" + Enter
				cSql += "	INNER JOIN SF4"+OPER_COL->EMP_ORI+"0 SF4 ON	" + Enter
				cSql += "    SD2.D2_TES      = SF4.F4_CODIGO		" + Enter

				//Teste Robert/Fabio
				cSql += "	INNER JOIN SF1"+OPER_COL->EMP_ORI+"0 SF1 ON	" + Enter
				cSql += "    SD1.D1_DOC		= SF1.F1_DOC		AND 	" + Enter
				cSql += "    SD1.D1_SERIE	= SF1.F1_SERIE		AND     " + Enter
				cSql += "    SD1.D1_FORNECE	= SF1.F1_FORNECE 			" + Enter

				cSql += "	INNER JOIN SB1010 SB1 ON      			" + Enter
				cSql += "    SD1.D1_COD      = SB1.B1_COD			" + Enter
				cSql += "WHERE SD1.D1_FILIAL	= '"+xFilial('SD1')+"' 	AND " + Enter
				cSql += "	   SD2.D2_FILIAL	= '"+xFilial('SD2')+"' 	AND " + Enter
				cSql += "	   SF4.F4_FILIAL	= '"+xFilial('SF4')+"'	AND " + Enter
				cSql += "	   SB1.B1_FILIAL	= '"+xFilial('SB1')+"'	AND " + Enter
				cSql += "	   SD1.D1_DTDIGIT	>= '"+Dtos(MV_PAR02)+"' AND " + Enter
				cSql += "      SD1.D1_DTDIGIT	<= '"+Dtos(MV_PAR03)+"' AND " + Enter
				cSql += "      SB1.B1_GRUPO IN (SELECT TP_PROD FROM RAC_OPERACOES_EMPRESAS_COLIGADAS WHERE EMP_ORI = '"+OPER_COL->EMP_ORI+"' ) AND  " + Enter
				If OPER_COL->EMP_ORI <> OPER_COL->EMP_DES
					cSql += "      SD1.D1_FORNECE 	IN (SELECT CODCLI FROM RAC_OPERACOES_EMPRESAS_COLIGADAS, RAC_EMPRESAS_COLIGADAS WHERE EMP_DES = COD_EMP AND EMP_ORI = '"+OPER_COL->EMP_ORI+"' AND EMP_DES = '"+OPER_COL->EMP_DES+"') AND " + Enter
				EndIf
				cSql += "      SD1.D1_TIPO		=  'D'  				AND	" + Enter

				//Alterado em 23/09/14 - A partir de 2014 este filro não será mais considerado.
				If 	Dtos(MV_PAR02) <= "20131231"
					//Teste Robert/Fabio
					cSql += "      SF1.F1_FORMUL	<> 'S'  				AND	" + Enter
				EndIf

				cSql += "      SF4.F4_DUPLIC	=  'S'  				AND " + Enter
				cSql += "      SF1.D_E_L_E_T_	=  ''   				AND " + Enter
				cSql += "      SD1.D_E_L_E_T_	=  ''   				AND " + Enter
				cSql += "      SD2.D_E_L_E_T_	=  ''   				AND " + Enter
				cSql += "      SF4.D_E_L_E_T_	=  ''   				AND " + Enter
				cSql += "      SB1.D_E_L_E_T_	=  ''  						" + Enter
				cSql += "GROUP BY SUBSTRING(D1_DTDIGIT,1,6), B1_GRUPO 		" + Enter
				If chkfile("_PPC_D")
					dbSelectArea("_PPC_D")
					dbCloseArea()
				EndIf
				TcQuery cSql New Alias "_PPC_D"

				//Grava as informações do PPC - DEDUCOES
				While  !_PPC_D->(EOF())

					//Devolucao
					cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','02.01','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0201))+") "
					TcSQLExec(cSql)

					//ICMS
					cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','02.02','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0202))+") "
					TcSQLExec(cSql)

					//PIS
					cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','02.03','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0203))+") "
					TcSQLExec(cSql)

					//COFINS
					cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','02.04','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0204))+") "
					TcSQLExec(cSql)

					If OPER_COL->DIF_PIS > 0
						//PIS
						cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','02.05','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0201*OPER_COL->DIF_PIS))+") "
						TcSQLExec(cSql)
					EndIf

					If OPER_COL->DIF_COFINS > 0
						//COFINS
						cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','02.06','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0201*OPER_COL->DIF_COFINS))+") "
						TcSQLExec(cSql)
					EndIf

					_PPC_D->(dbSkip())
				End

			Else
				If OPER_COL->EMP_ORI <> OPER_COL->EMP_DES
					For  n := 1 to 2

						If n == 1
							nTD := "C" //CUSTO
						Else
							nTD := "D" //DESPESA
						EndIf

						//Receitas
						cSql := "SELECT FIL, MESANO, GRUPO, SUM(VLR_0101) VLR_0101, SUM(VLR_0102) VLR_0102, SUM(VLR_0103) VLR_0103, SUM(VLR_0104) VLR_0104 " + Enter
						cSql += "FROM 																			" + Enter
						cSql += "(SELECT CT2_CREDIT, CT2_DEBITO, SUBSTRING(CT2_DATA,1,6) MESANO, 'SER' GRUPO 	" + Enter
						cSql += "	,FIL = CASE		" + Enter
						cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000001') OR CT2_DEBITO IN ('41201070000003','41201070000004','41201070000005') THEN '01' " + Enter
						cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000004') OR CT2_DEBITO IN ('41201070000013','41201070000014','41201070000015') THEN '02' " + Enter
						cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000005') OR CT2_DEBITO IN ('41201070000023','41201070000024','41201070000025') THEN '03' " + Enter
						cSql += "			ELSE ''	" + Enter
						cSql += "		 END 		" + Enter
						If OPER_COL->EMP_ORI == "06"
							cSql += "	  ,VLR_0101 = ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41101030000001','41101030000003','41101030000004','41101030000005') THEN CT2_VALOR END),0) " + Enter
							cSql += "	  ,VLR_0102 = ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR END),0) " + Enter
							cSql += "	  ,VLR_0103	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR END),0) " + Enter
							cSql += "	  ,VLR_0104	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR END),0) " + Enter
						Else
							cSql += "	  ,VLR_0101	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41101030000001') THEN CT2_VALOR END),0)									 " + Enter
							cSql += "	  ,VLR_0102	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR END),0) " + Enter
							cSql += "	  ,VLR_0103	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR END),0) " + Enter
							cSql += "	  ,VLR_0104	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR END),0) " + Enter
						EndIf
						cSql += "FROM CT2"+OPER_COL->EMP_ORI+"0											" + Enter
						cSql += "WHERE CT2_DATA BETWEEN '"+Dtos(MV_PAR02)+"' AND '"+Dtos(MV_PAR03)+"'	" + Enter
						If OPER_COL->EMP_ORI <> OPER_COL->EMP_DES
							cSql += "AND (CT2_ITEMC = 'EMP"+OPER_COL->EMP_DES+"01"+nTD+"' OR CT2_ITEMD = 'EMP"+OPER_COL->EMP_DES+"01"+nTD+"' )	" + Enter
						EndIf
						cSql += "AND CT2_LOTE <> '888888' 	" + Enter
						cSql += "AND D_E_L_E_T_ = ''		" + Enter
						cSql += "GROUP BY CT2_CREDIT, CT2_DEBITO, SUBSTRING(CT2_DATA,1,6)) TMP " + Enter
						cSql += "WHERE FIL <> ''			 " + Enter
						cSql += "GROUP BY FIL, MESANO, GRUPO " + Enter
						cSql += "ORDER BY FIL, MESANO, GRUPO " + Enter
						If chkfile("_PPC_R")
							dbSelectArea("_PPC_R")
							dbCloseArea()
						EndIf
						TcQuery cSql New Alias "_PPC_R"

						//Grava as informações do PPC - RECEITA
						While  !_PPC_R->(EOF())

							//Receita
							cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','"+_PPC_R->FIL+"','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','"+nTD+"','01.01','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0101))+") "
							TcSQLExec(cSql)

							//ICMS
							cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','"+_PPC_R->FIL+"','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','"+nTD+"','01.02','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0102))+") "
							TcSQLExec(cSql)

							//PIS
							cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','"+_PPC_R->FIL+"','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','"+nTD+"','01.03','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0103))+") "
							TcSQLExec(cSql)

							//COFINS
							cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','"+_PPC_R->FIL+"','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','"+nTD+"','01.04','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0104))+") "
							TcSQLExec(cSql)

							If OPER_COL->DIF_PIS > 0
								//PIS
								cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','"+_PPC_R->FIL+"','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','"+nTD+"','01.05','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0101*OPER_COL->DIF_PIS))+") "
								TcSQLExec(cSql)
							EndIf

							If OPER_COL->DIF_COFINS > 0
								//COFINS
								cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','"+_PPC_R->FIL+"','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','"+nTD+"','01.06','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0101*OPER_COL->DIF_COFINS))+") "
								TcSQLExec(cSql)
							EndIf

							_PPC_R->(dbSkip())
						End
					Next



					For  n := 1 to 2

						If n == 1
							nTD := "C" //CUSTO
						Else
							nTD := "D" //DESPESA
						EndIf

						//Deducoes
						cSql := "SELECT SUBSTRING(CT2_DATA,1,6) MESANO, 'SER' GRUPO " + Enter
						If OPER_COL->EMP_ORI == "06"
							cSql += "	  ,VLR_0201 = ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000011') THEN CT2_VALOR*-1 END),0)									" + Enter
							cSql += "	  ,VLR_0202 = ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR*-1 END),0)	" + Enter
							cSql += "	  ,VLR_0203	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR*-1 END),0)	" + Enter
							cSql += "	  ,VLR_0204	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR*-1 END),0)	" + Enter
						Else
							cSql += "	  ,VLR_0201	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000011') THEN CT2_VALOR END),0)										" + Enter
							cSql += "	  ,VLR_0202	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR*-1 END),0)	" + Enter
							cSql += "	  ,VLR_0203	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR*-1 END),0)	" + Enter
							cSql += "	  ,VLR_0204	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR*-1 END),0)	" + Enter
						EndIf
						cSql += "FROM CT2"+OPER_COL->EMP_ORI+"0 " + Enter
						cSql += "WHERE CT2_DATA BETWEEN '"+Dtos(MV_PAR02)+"' AND '"+Dtos(MV_PAR03)+"' " + Enter
						If OPER_COL->EMP_ORI <> OPER_COL->EMP_DES
							//cSql += "AND (CT2_ITEMC = 'EMP"+OPER_COL->EMP_DES+"01' OR CT2_ITEMD = 'EMP"+OPER_COL->EMP_DES+"01')	" + Enter
							cSql += "AND (CT2_ITEMC = 'EMP"+OPER_COL->EMP_DES+"01"+nTD+"' OR CT2_ITEMD = 'EMP"+OPER_COL->EMP_DES+"01"+nTD+"' )	" + Enter
						EndIf
						cSql += "AND CT2_LOTE <> '888888' 			" + Enter
						cSql += "AND D_E_L_E_T_ = ''				" + Enter
						cSql += "GROUP BY SUBSTRING(CT2_DATA,1,6) 	" + Enter
						If chkfile("_PPC_D")
							dbSelectArea("_PPC_D")
							dbCloseArea()
						EndIf
						TcQuery cSql New Alias "_PPC_D"

						//Grava as informações do PPC - DEDUCOES
						While  !_PPC_D->(EOF())

							//Devolucao
							cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','"+nTD+"','02.01','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0201))+") "
							TcSQLExec(cSql)

							//ICMS
							cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','"+nTD+"','02.02','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0202))+") "
							TcSQLExec(cSql)

							//PIS
							cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','"+nTD+"','02.03','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0203))+") "
							TcSQLExec(cSql)

							//COFINS
							cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','"+nTD+"','02.04','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0204))+") "
							TcSQLExec(cSql)

							If OPER_COL->DIF_PIS > 0
								//PIS
								cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','"+nTD+"','02.05','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0201*OPER_COL->DIF_PIS))+") "
								TcSQLExec(cSql)
							EndIf

							If OPER_COL->DIF_COFINS > 0
								//COFINS
								cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','"+nTD+"','02.06','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0201*OPER_COL->DIF_COFINS))+") "
								TcSQLExec(cSql)
							EndIf

							_PPC_D->(dbSkip())
						End
					Next
				Else

					nTD := ""
					//Receitas
					cSql := "SELECT FIL, MESANO, GRUPO, SUM(VLR_0101) VLR_0101, SUM(VLR_0102) VLR_0102, SUM(VLR_0103) VLR_0103, SUM(VLR_0104) VLR_0104 " + Enter
					cSql += "FROM 																			" + Enter
					cSql += "(SELECT CT2_CREDIT, CT2_DEBITO, SUBSTRING(CT2_DATA,1,6) MESANO, 'SER' GRUPO 	" + Enter
					cSql += "	,FIL = CASE		" + Enter
					cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000001') OR CT2_DEBITO IN ('41201070000003','41201070000004','41201070000005') THEN '01' " + Enter
					cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000004') OR CT2_DEBITO IN ('41201070000013','41201070000014','41201070000015') THEN '02' " + Enter
					cSql += "			WHEN CT2_CREDIT IN ('41101030000003','41101030000005') OR CT2_DEBITO IN ('41201070000023','41201070000024','41201070000025') THEN '03' " + Enter
					cSql += "			ELSE ''	" + Enter
					cSql += "		 END 		" + Enter
					If OPER_COL->EMP_ORI == "06"
						cSql += "	  ,VLR_0101 = ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41101030000001','41101030000003','41101030000004','41101030000005') THEN CT2_VALOR END),0) " + Enter
						cSql += "	  ,VLR_0102 = ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR END),0) " + Enter
						cSql += "	  ,VLR_0103	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR END),0) " + Enter
						cSql += "	  ,VLR_0104	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR END),0) " + Enter
					Else
						cSql += "	  ,VLR_0101	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41101030000001') THEN CT2_VALOR END),0)									 " + Enter
						cSql += "	  ,VLR_0102	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR END),0) " + Enter
						cSql += "	  ,VLR_0103	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR END),0) " + Enter
						cSql += "	  ,VLR_0104	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR END),0) " + Enter
					EndIf
					cSql += "FROM CT2"+OPER_COL->EMP_ORI+"0											" + Enter
					cSql += "WHERE CT2_DATA BETWEEN '"+Dtos(MV_PAR02)+"' AND '"+Dtos(MV_PAR03)+"'	" + Enter
					If OPER_COL->EMP_ORI <> OPER_COL->EMP_DES
						cSql += "AND (CT2_ITEMC = 'EMP"+OPER_COL->EMP_DES+"01"+nTD+"' OR CT2_ITEMD = 'EMP"+OPER_COL->EMP_DES+"01"+nTD+"' )	" + Enter
					EndIf
					cSql += "AND CT2_LOTE <> '888888' 	" + Enter
					cSql += "AND D_E_L_E_T_ = ''		" + Enter
					cSql += "GROUP BY CT2_CREDIT, CT2_DEBITO, SUBSTRING(CT2_DATA,1,6)) TMP " + Enter
					cSql += "WHERE FIL <> ''			 " + Enter
					cSql += "GROUP BY FIL, MESANO, GRUPO " + Enter
					cSql += "ORDER BY FIL, MESANO, GRUPO " + Enter
					If chkfile("_PPC_R")
						dbSelectArea("_PPC_R")
						dbCloseArea()
					EndIf
					TcQuery cSql New Alias "_PPC_R"

					//Grava as informações do PPC - RECEITA
					While  !_PPC_R->(EOF())

						//Receita
						cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','"+_PPC_R->FIL+"','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','"+nTD+"','01.01','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0101))+") "
						TcSQLExec(cSql)

						//ICMS
						cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','"+_PPC_R->FIL+"','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','"+nTD+"','01.02','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0102))+") "
						TcSQLExec(cSql)

						//PIS
						cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','"+_PPC_R->FIL+"','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','"+nTD+"','01.03','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0103))+") "
						TcSQLExec(cSql)

						//COFINS
						cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','"+_PPC_R->FIL+"','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','"+nTD+"','01.04','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0104))+") "
						TcSQLExec(cSql)

						If OPER_COL->DIF_PIS > 0
							//PIS
							cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','"+_PPC_R->FIL+"','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','"+nTD+"','01.05','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0101*OPER_COL->DIF_PIS))+") "
							TcSQLExec(cSql)
						EndIf

						If OPER_COL->DIF_COFINS > 0
							//COFINS
							cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','"+_PPC_R->FIL+"','"+OPER_COL->EMP_DES+"','"+_PPC_R->MESANO+"','"+_PPC_R->GRUPO+"','"+nTD+"','01.06','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_R->VLR_0101*OPER_COL->DIF_COFINS))+") "
							TcSQLExec(cSql)
						EndIf

						_PPC_R->(dbSkip())
					End

					nTD := ""
					//Deducoes
					cSql := "SELECT SUBSTRING(CT2_DATA,1,6) MESANO, 'SER' GRUPO " + Enter
					If OPER_COL->EMP_ORI == "06"
						cSql += "	  ,VLR_0201 = ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000011') THEN CT2_VALOR*-1 END),0)									" + Enter
						cSql += "	  ,VLR_0202 = ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR*-1 END),0)	" + Enter
						cSql += "	  ,VLR_0203	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR*-1 END),0)	" + Enter
						cSql += "	  ,VLR_0204	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR*-1 END),0)	" + Enter
					Else
						cSql += "	  ,VLR_0201	= ISNULL(SUM(CASE WHEN CT2_DEBITO IN ('41201070000011') THEN CT2_VALOR END),0)										" + Enter
						cSql += "	  ,VLR_0202	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000003','41201070000013','41201070000023') THEN CT2_VALOR*-1 END),0)	" + Enter
						cSql += "	  ,VLR_0203	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000004','41201070000014','41201070000024') THEN CT2_VALOR*-1 END),0)	" + Enter
						cSql += "	  ,VLR_0204	= ISNULL(SUM(CASE WHEN CT2_CREDIT IN ('41201070000005','41201070000015','41201070000025') THEN CT2_VALOR*-1 END),0)	" + Enter
					EndIf
					cSql += "FROM CT2"+OPER_COL->EMP_ORI+"0 " + Enter
					cSql += "WHERE CT2_DATA BETWEEN '"+Dtos(MV_PAR02)+"' AND '"+Dtos(MV_PAR03)+"' " + Enter
					If OPER_COL->EMP_ORI <> OPER_COL->EMP_DES
						//cSql += "AND (CT2_ITEMC = 'EMP"+OPER_COL->EMP_DES+"01' OR CT2_ITEMD = 'EMP"+OPER_COL->EMP_DES+"01')	" + Enter
						cSql += "AND (CT2_ITEMC = 'EMP"+OPER_COL->EMP_DES+"01"+nTD+"' OR CT2_ITEMD = 'EMP"+OPER_COL->EMP_DES+"01"+nTD+"' )	" + Enter
					EndIf
					cSql += "AND CT2_LOTE <> '888888' 			" + Enter
					cSql += "AND D_E_L_E_T_ = ''				" + Enter
					cSql += "GROUP BY SUBSTRING(CT2_DATA,1,6) 	" + Enter
					If chkfile("_PPC_D")
						dbSelectArea("_PPC_D")
						dbCloseArea()
					EndIf
					TcQuery cSql New Alias "_PPC_D"

					//Grava as informações do PPC - DEDUCOES
					While  !_PPC_D->(EOF())

						//Devolucao
						cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','"+nTD+"','02.01','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0201))+") "
						TcSQLExec(cSql)

						//ICMS
						cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','"+nTD+"','02.02','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0202))+") "
						TcSQLExec(cSql)

						//PIS
						cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','"+nTD+"','02.03','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0203))+") "
						TcSQLExec(cSql)

						//COFINS
						cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','"+nTD+"','02.04','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0204))+") "
						TcSQLExec(cSql)

						If OPER_COL->DIF_PIS > 0
							//PIS
							cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','"+nTD+"','02.05','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0201*OPER_COL->DIF_PIS))+") "
							TcSQLExec(cSql)
						EndIf

						If OPER_COL->DIF_COFINS > 0
							//COFINS
							cSql := "INSERT INTO RAC_PPC (EMP_ORI, FIL, EMP_DES, MES_ANO, TP_PROD, TP_CTB, TP_VLR, CUSTO_IMP, VLR) VALUES ('"+OPER_COL->EMP_ORI+"','01','"+OPER_COL->EMP_DES+"','"+_PPC_D->MESANO+"','"+_PPC_D->GRUPO+"','"+nTD+"','02.06','"+OPER_COL->CUSTO_IMP+"',"+Alltrim(Str(_PPC_D->VLR_0201*OPER_COL->DIF_COFINS))+") "
							TcSQLExec(cSql)
						EndIf

						_PPC_D->(dbSkip())
					End

				EndIf
			EndIf

			OPER_COL->(dbSkip())
		End

		(cAliasEMP_COL)->(dbSkip())
	End

	(cAliasEMP_COL)->(dbCloseArea())
	OPER_COL->(dbCloseArea())

	Msgbox("CÁLCULO das planilhas finalizadas com sucesso.","BIA855","INFO")

Return


/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ConsolidaPPC ¦ Autor ¦ Ranisses Corona   ¦ Data ¦ 22.05.14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Consolida as informações do PPC                            ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ConsolidaPPC()

	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//LÊ ROTEIRO E EXECUTA CONTABILIZAÇÃO
	//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cSql := "SELECT * FROM RAC_ROTEIRO_CONSOLIDACAO ORDER BY SEQ "
	If chkfile("ROTEIRO")
		dbSelectArea("ROTEIRO")
		dbCloseArea()
	EndIf
	TcQuery cSql New Alias "ROTEIRO"

	While !ROTEIRO->(EOF())

		If SUBSTR(ROTEIRO->TIPO,1,1) <> "6"

			//Grupo de Produtos
			nGrupos := U_MontaSQLIN(ROTEIRO->TP_PROD,'_',3)

			//Define empresas para busca das informacoes
			cSql := "SELECT MES_ANO, EMP_DES AS EMP_ORI, FIL, ISNULL(TP_CTB,'') TP_CTB "
			cSql += "FROM RAC_PPC 				"
			cSql += "WHERE          			"
			If !Empty(Alltrim(ROTEIRO->FIL))
				cSql += "		FIL  = '"+Alltrim(ROTEIRO->FIL)+"' AND "
			EndIf
			If 	!Empty(Alltrim(nGrupos))
				cSql += "		TP_PROD IN ("+Alltrim(nGrupos)+") AND "
			EndIf
			If !Empty(Alltrim(ROTEIRO->EMP_DES))
				If SUBSTR(ROTEIRO->TIPO,1,1) == "1"
					cSql += "		EMP_DES = '"+Alltrim(ROTEIRO->EMP_DES)+"' AND "
				Else
					cSql += "		EMP_DES <> '"+Alltrim(ROTEIRO->EMP_DES)+"' AND "
				EndIf
			EndIf
			If Alltrim(ROTEIRO->CONTA) == "41301001"
				cSql += "		ISNULL(TP_CTB,'') IN ('C','') AND "
			ElseIf Alltrim(ROTEIRO->CONTA) == "31601003"
				cSql += "		ISNULL(TP_CTB,'') IN ('D')    AND "
			EndIf
			cSql += "		MES_ANO >= '"+nMesAnoD+"' AND MES_ANO <= '"+nMesAnoA+"' "
			cSql += "GROUP BY MES_ANO, EMP_DES, FIL, TP_CTB  "
			cSql += "ORDER BY MES_ANO, EMP_DES, FIL, TP_CTB  "
			If chkfile("EMP")
				dbSelectArea("EMP")
				dbCloseArea()
			EndIf
			TcQuery cSql New Alias "EMP"

			While !EMP->(EOF())
				//Se estiver vazio, EMPRESA ORIGEM E DESTINO SÃO IGUAIS

				If Empty(Alltrim(ROTEIRO->EMP_DES))
					nEmpDes := EMP->EMP_ORI
					nEmpOri := EMP->EMP_ORI
				Else
					nEmpDes := EMP->EMP_ORI
					nEmpOri := ROTEIRO->EMP_DES
				EndIf

				If Alltrim(ROTEIRO->CONTA) == "31601003"
					nEmpDes := nEmpOri
				EndIf

				//Define a Filial
				If Empty(Alltrim(ROTEIRO->FIL))
					nFil := EMP->FIL
				Else
					nFil := ROTEIRO->FIL
				EndIf

				//Define Tp Contabil
				If Empty(Alltrim(EMP->TP_CTB))
					nTpCTB := ""
				Else
					nTpCTB := Alltrim(EMP->TP_CTB)
				EndIf

				_aRet	:= {}
				U_BIAMsgRun("Aguarde... Gerando informações para Consolidação: "+ROTEIRO->TIPO ,,{|| _aRet := TCSPEXEC("SP_BIA855",ROTEIRO->CONTA,nEmpOri,nEmpDes,nFil,nTpCTB,EMP->MES_ANO,SUBSTR(ROTEIRO->TIPO,1,1),nGrupos) })

				If Len(_aRet) > 0
					//	If Alltrim(Str(_aRet[1])) <> "0"
					cSql := "INSERT INTO RAC_CONSOLIDACAO (CONTA,TIPO, TP_PROD, MES_ANO, DT_LANC, EMP, TP_LANC, FLAG, VLR) VALUES ('"+ROTEIRO->CONTA+"','"+ROTEIRO->TIPO+"','"+ROTEIRO->TP_PROD+"','"+EMP->MES_ANO+"','"+Dtos(LastDay(STOD(EMP->MES_ANO+"01"),0))+"','"+nEmpDes+"','"+ROTEIRO->TP_LANC+"','N',"+Alltrim(Str(_aRet[1]))+") "
					TcSQLExec(cSql)
					//	EndIf
				EndIf

				EMP->(dbSkip())
			End

		Else

			//Define empresas para busca das informacoes
			cSql := "SELECT MES_ANO, EMP_DES AS EMP_ORI "
			cSql += "FROM RAC_PPC 						"
			cSql += "WHERE	MES_ANO >= '"+nMesAnoD+"' AND MES_ANO <= '"+nMesAnoA+"' "
			cSql += "GROUP BY MES_ANO, EMP_DES "
			cSql += "ORDER BY MES_ANO, EMP_DES "
			If chkfile("EMP")
				dbSelectArea("EMP")
				dbCloseArea()
			EndIf
			TcQuery cSql New Alias "EMP"

			While !EMP->(EOF())

				_aRet	:= {}
				U_BIAMsgRun("Aguarde... Gerando informações para Consolidação: "+ROTEIRO->TIPO ,,{|| _aRet := TCSPEXEC("SP_BIA855",ROTEIRO->CONTA,EMP->EMP_ORI,EMP->EMP_ORI,"01","",EMP->MES_ANO,SUBSTR(ROTEIRO->TIPO,1,1),"") })

				If Len(_aRet) > 0
					//Grava o Lançamento de Estorno
					cSql := "INSERT INTO RAC_CONSOLIDACAO (CONTA,TIPO, TP_PROD, MES_ANO, DT_LANC, EMP, TP_LANC, FLAG, VLR) VALUES ('"+ROTEIRO->CONTA+"','"+ROTEIRO->TIPO+"','"+ROTEIRO->TP_PROD+"','"+EMP->MES_ANO+"','"+Dtos(LastDay(STOD(EMP->MES_ANO+"01"),0))+"','"+EMP->EMP_ORI+"','"+ROTEIRO->TP_LANC+"','N',"+Alltrim(Str(_aRet[1]))+") "
					TcSQLExec(cSql)

					//Estorna o Laçamento de Estono, no mes seguinte
					If ROTEIRO->TP_LANC == "C"
						nTpLanc := "D"
					Else
						nTpLanc := "C"
					EndIf
					cSql := "INSERT INTO RAC_CONSOLIDACAO (CONTA,TIPO, TP_PROD, MES_ANO, DT_LANC, EMP, TP_LANC, FLAG, VLR) VALUES ('"+ROTEIRO->CONTA+"','"+ROTEIRO->TIPO+"','"+ROTEIRO->TP_PROD+"','"+Substr(Dtos(MonthSum(STOD(EMP->MES_ANO+"01"),1)),1,6)+"','"+Dtos(MonthSum(STOD(EMP->MES_ANO+"01"),1))+"','"+EMP->EMP_ORI+"','"+nTpLanc+"','N',"+Alltrim(Str(_aRet[1]))+") "
					TcSQLExec(cSql)
				EndIf

				EMP->(dbSkip())
			End

		EndIf

		ROTEIRO->(dbSkip())
	End

	Msgbox("CONSOLIDAÇÃO das planilhas finalizadas com sucesso.","BIA855","INFO")

Return
