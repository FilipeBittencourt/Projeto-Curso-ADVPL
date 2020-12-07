#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA749
@author Marcos Alberto Soprani
@since 04/01/20
@version 1.0
@description Contabilização do RCM - OFF LINE DO OFF LINE
@obs A ROTINA MATA330 E MATA331 logo após a migraçao da verção 12.1.25 apresentou problema de performance.
@type function
/*/

User Function BIA749()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Private dtRefEmi := dDataBase
	Private nHdlPrv

	fgLotCtb := "008840"
	fgVetCtb := {}
	fgPermDg := .F.

	cHInicio := Time()
	fPerg := "BIA749"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA749 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase <> GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.","BIA749 - Data de Fechamento!!!")
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA749",fPerg)

	TL003 := " WITH MOVESTCTB "
	TL003 += "      AS (SELECT SD3.R_E_C_N_O_ REGSD3, "
	TL003 += "                 D3_OP, "
	TL003 += "                 ISNULL(C2_NUM, '      ') C2_NUM, "
	TL003 += "                 ISNULL(B1_TIPO, '  ') B1_TIPO "
	TL003 += "          FROM " + RetSqlName("SD3") + " SD3(NOLOCK) "
	TL003 += "               LEFT JOIN " + RetSqlName("SC2") + " SC2 ON C2_FILIAL = '" + xFilial("SC2") + "' "
	TL003 += "                                       AND C2_NUM = SUBSTRING(D3_OP, 1, 6) "
	TL003 += "                                       AND C2_ITEM = SUBSTRING(D3_OP, 7, 2) "
	TL003 += "                                       AND C2_SEQUEN = SUBSTRING(D3_OP, 9, 3) "
	TL003 += "                                       AND SC2.D_E_L_E_T_ = ' ' "
	TL003 += "               LEFT JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
	TL003 += "                                       AND B1_COD = C2_PRODUTO "
	TL003 += "                                       AND SB1.D_E_L_E_T_ = ' ' "
	TL003 += "          WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	TL003 += "                AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	TL003 += "                AND D3_CF NOT IN('DE2', 'RE2', 'DE3', 'RE3', 'DE4', 'RE4', 'DE7', 'RE7', 'PR0') "
	TL003 += "                AND SUBSTRING(D3_COD, 1, 3) <> 'MOD' "
	TL003 += "                AND D3_ESTORNO = ' ' "
	TL003 += "                AND D3_TIPO NOT IN('PP', 'PA') "
	TL003 += "                AND SD3.D_E_L_E_T_ = ' '), "
	TL003 += "     CTBCORRETO "
	TL003 += "     AS (SELECT CASE "
	TL003 += "                    WHEN CT2_LP = '668' "
	TL003 += "                    THEN SUBSTRING(CT2_ORIGEM, 51, 8) "
	TL003 += "                    WHEN CT2_LP = '666' "
	TL003 += "                    THEN SUBSTRING(CT2_ORIGEM, 51, 8) "
	TL003 += "                    ELSE CT2_ORIGEM "
	TL003 += "                END LINKSD3 "
	TL003 += "         FROM " + RetSqlName("CT2") + "(NOLOCK) "
	TL003 += "         WHERE CT2_FILIAL = '" + xFilial("CT2") + "' "
	TL003 += "               AND CT2_DATA = '" + dtos(MV_PAR02) + "' "
	TL003 += "               AND CT2_LOTE = '008840' "
	TL003 += "               AND CT2_LP NOT IN('66Z', '66W') "
	TL003 += "               AND D_E_L_E_T_ = ' ') "
	TL003 += "     SELECT * "
	TL003 += "     FROM MOVESTCTB A "
	TL003 += "     WHERE B1_TIPO <> 'PI' "
	TL003 += "           AND NOT EXISTS "
	TL003 += "     ( "
	TL003 += "         SELECT * "
	TL003 += "         FROM CTBCORRETO B "
	TL003 += "         WHERE B.LINKSD3 = A.REGSD3 "
	TL003 += "     ) "
	TL003 += "       ORDER BY REGSD3 "
	TLcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,TL003),'TL03',.F.,.T.)

	U_B749GRVCT()

	TL03->(dbCloseArea())
	Ferase(TLcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(TLcIndex+OrdBagExt())          //indice gerado

Return

User Function B749GRVCT()

	Private LCABECALHO, CPADRAO, LPADRAO, NTOTAL, CLOTE, LDIGITA
	Private LAGLUT, CARQUIVO, AROTINA, NHDLPRV, aFlagCTB
	Private cdeb, ccred, chis, nval, cult, msUltReg

	lCabecalho := .F.
	lPadrao    := .F.
	nTotal     := 0
	clote      := fgLotCtb
	lDigita    := .F.
	lAglut     := .F.
	cArquivo   := ""
	aRotina    := {}

	msUltReg   := 0
	c_contad   := 0
	dbSelectArea("TL03")
	dbGoTop()
	ProcRegua(RecCount())
	While TL03->(!Eof())

		IncProc("Processando... " + Alltrim(TL03->REGSD3))

		dbSelectArea("SD3")
		dbSetOrder(1)
		dbGoTo(TL03->REGSD3)
		msUltReg := TL03->REGSD3
		cPadrao := IIF(SD3->D3_TM > "500", "666", "668")

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + SD3->D3_COD))

		c_contad ++
		lPadrao := VerPadrao( cPadrao )

		If lPadrao

			If !lCabecalho
				a370Cabecalho(@nHdlPrv,@cArquivo)
			Endif

			nTotal  := nTotal + DetProva(nHdlPrv, cPadrao, "MATA330", cLote )
			cult := .F.

		EndIf

		If c_contad == 997

			c_contad := 0
			//c := 2

			**********************************************************
			If lCabecalho
				RodaProva(nHdlPrv,nTotal)
			Endif

			If lPadrao
				cA100Incl(cArquivo, nHdlPrv, 3, cLote, lDigita, lAglut  )
			End

			If cult == .F.
				fbCont()
			EndIf

		EndIf

		TL03->(dbSkip())

	End

	dbSelectArea("SD3")
	dbSetOrder(1)
	dbGoTo(msUltReg)

	If lCabecalho
		RodaProva(nHdlPrv,nTotal)
	Endif

	If lPadrao
		cA100Incl(cArquivo, nHdlPrv, 3, cLote, lDigita, lAglut  )
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
		cA100Incl(cArquivo, nHdlPrv, 3, cLote, lDigita, lAglut  )
	End

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 25.01.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	local i,j

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data               ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return
