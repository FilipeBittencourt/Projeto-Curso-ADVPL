#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA788
@author Marcos Alberto Soprani
@since 06/05/14
@version 1.0
@description Gera registros de MOD para cada uma das produção/estorno den-
.            tro de determinado período.
.            +-----+-------------+----------------+-----------------+-------+
.            |                  Originário do fonte BIA711                  |
.            |             Novo Custo a partir de abril de 2014             |
.            +-----+-------------+----------------+-----------------+-------+
@obs Em 06/03/17... Ajuste na linha R09
@type function
/*/

User Function BIA788()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local xrEnter   := CHR(13) + CHR(10)

	Private yjGrvModOk
	Private yjCustoItm

	cHInicio := Time()
	fPerg := "BIA788"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA788 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase <> GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.","BIA788 - Data de Fechamento!!!")
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA788",fPerg)

	kjDtINI := MV_PAR01
	kjDtFIM := MV_PAR02
	kjTpPrd := MV_PAR03
	kjPrdRf := MV_PAR04
	kjPRfAt := MV_PAR05 // Em 07/01/16

	frDtOld    := dDataBase
	//dDataBase  := Date()
	// Monta referência para diluir o retorno da Massa na formulação da massa. Usado apenas para PI MASSA
	AK007 := " SELECT G1_COD, G1_TRT, SUM(G1_YMISTUR) PERC "
	AK007 += "   FROM " + RetSqlName("SG1") + " SG1(NOLOCK) "
	AK007 += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
	AK007 += "                      AND B1_COD = G1_COD "
	AK007 += "                      AND B1_GRUPO = 'PI01' "
	AK007 += "                      AND SB1.D_E_L_E_T_ = ' ' "
	AK007 += "  WHERE G1_FILIAL = '" + xFilial("SG1") + "' "
	AK007 += "    AND '" + dtos(dDataBase) + "' >= G1_INI "
	AK007 += "    AND '" + dtos(dDataBase) + "' <= G1_FIM "
	AK007 += "    AND SG1.D_E_L_E_T_ = ' ' "
	AK007 += "  GROUP BY G1_COD, G1_TRT "
	AK007 := ChangeQuery(AK007)
	cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,AK007),'AK07',.T.,.T.)
	aStruX := ("AK07")->(dbStruct())
	/*----- Exporta os dados do resultado de uma Query para um arquivo temporário normal -----*/
	gh_IndX := "G1_COD"
	If !chkfile("AK08")
		AK08 := U_BIACrTMP(aStruX)
		dbUseArea( .T.,, AK08, "AK08", .F., .F. )
		dbCreateInd(AK08, gh_IndX,{ || gh_IndX })
	EndIf
	dbSelectArea("AK08")
	APPEND FROM ("AK07")
	If Select("AK07") > 0
		AK07->(dbCloseArea())
	Endif
	dDataBase  := frDtOld

	// Incluída melhoria me 05/10/15 durante fechamento de setembro de 2015, pois em agosto de 2015 com as mudanças para o orçamento de 2016 o fechamento do mês usou o peso seco errado.
	MZ001 := " SELECT COUNT(*) CONTAD "
	MZ001 += "   FROM (SELECT DISTINCT D3_COD, "
	MZ001 += "                ISNULL((SELECT DISTINCT Z42_PSECO "
	MZ001 += "                          FROM " + RetSqlName("Z42") + " Z42(NOLOCK) "
	MZ001 += "                         WHERE Z42_FILIAL = '" + xFilial("Z42") + "' "
	MZ001 += "                           AND Z42_FORMAT = B1_YFORMAT "
	MZ001 += "                           AND Z42_BASE = B1_YBASE "
	MZ001 += "                           AND Z42_ACABAM LIKE  '%' + B1_YACABAM + '%' "
	MZ001 += "                           AND Z42_ESPESS LIKE  '%' + B1_YESPESS + '%' "
	MZ001 += "                           AND Z42_TPPROD LIKE  '%' + B1_TIPO + '%' "
	MZ001 += "                           AND '" + dtos(kjDtINI) + "' >= Z42_DTINI "
	MZ001 += "                           AND '" + dtos(kjDtFIM) + "' <= Z42_DTFIM "
	MZ001 += "                           AND Z42_VERSAO = '" + MV_PAR07 + "' "
	MZ001 += "                           AND Z42_REVISA = '" + MV_PAR08 + "' "
	MZ001 += "                           AND Z42_ANOREF = '" + MV_PAR09 + "' "
	MZ001 += "                           AND Z42_FINALI = 'R' "
	MZ001 += "                           AND Z42.D_E_L_E_T_ = ' '),0) PSECO "
	MZ001 += "           FROM " + RetSqlName("SD3") + " SD3(NOLOCK) "
	MZ001 += "          INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
	MZ001 += "                               AND B1_COD = D3_COD "
	MZ001 += "                               AND SB1.D_E_L_E_T_ = ' ' "
	MZ001 += "          WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	MZ001 += "            AND D3_EMISSAO BETWEEN '" + dtos(kjDtINI) + "' AND '" + dtos(kjDtFIM) + "' "
	MZ001 += "            AND D3_TM = '010' "
	MZ001 += "            AND D3_ESTORNO = ' ' "
	MZ001 += "            AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	MZ001 += "            AND D3_TIPO = '" + kjTpPrd + "' "
	If !Empty(kjPrdRf) .and. !Empty(kjPRfAt)
		MZ001 += "            AND D3_COD BETWEEN '" + kjPrdRf + "' AND '" + kjPRfAt + "' "
	EndIf
	MZ001 += "            AND SD3.D_E_L_E_T_ = ' ') AS TABRD "
	MZ001 += "  WHERE PSECO = 0 "
	MZ1cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,MZ001),'MZ01',.T.,.T.)
	dbSelectArea("MZ01")
	dbGoTop()
	jyContadMZ := MZ01->CONTAD
	MZ01->(dbCloseArea())
	Ferase(MZ1cIndex+GetDBExtension())
	Ferase(MZ1cIndex+OrdBagExt())
	If jyContadMZ > 0

		Aviso('Peso Seco do Produto','Necessário verificar o cadastro de Capacidade Produtiva no que se refere a Peso Seco, pois um ou mais produtos estão com problema!',{'Ok'})

		oExcel := FWMSEXCEL():New()

		nxPlan := "Planilha 01"
		nxTabl := "Produtos sem peso seco"

		oExcel:AddworkSheet(nxPlan)
		oExcel:AddTable (nxPlan, nxTabl)
		oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"         ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DESCRIÇÃO"       ,1,1)
		MF007 := " SELECT B1_COD, SUBSTRING(B1_DESC,1,50) DESCR "
		MF007 += "   FROM (SELECT DISTINCT "
		MF007 += "                B1_COD, "
		MF007 += "                B1_DESC, "
		MF007 += "                ISNULL((SELECT DISTINCT Z42_PSECO "
		MF007 += "                          FROM " + RetSqlName("Z42") + " Z42(NOLOCK) "
		MF007 += "                         WHERE Z42_FILIAL = '" + xFilial("Z42") + "' "
		MF007 += "                           AND Z42_FORMAT = B1_YFORMAT "
		MF007 += "                           AND Z42_BASE = B1_YBASE "
		MF007 += "                           AND Z42_ACABAM LIKE  '%' + B1_YACABAM + '%' "
		MF007 += "                           AND Z42_ESPESS LIKE  '%' + B1_YESPESS + '%' "
		MF007 += "                           AND Z42_TPPROD LIKE  '%' + B1_TIPO + '%' "
		MF007 += "                           AND '" + dtos(kjDtINI) + "' >= Z42_DTINI "
		MF007 += "                           AND '" + dtos(kjDtFIM) + "' <= Z42_DTFIM "
		MF007 += "                           AND Z42_VERSAO = '" + MV_PAR07 + "' "
		MF007 += "                           AND Z42_REVISA = '" + MV_PAR08 + "' "
		MF007 += "                           AND Z42_ANOREF = '" + MV_PAR09 + "' "
		MF007 += "                           AND Z42_FINALI = 'R' "
		MF007 += "                           AND Z42.D_E_L_E_T_ = ' '),0) PSECO "
		MF007 += "           FROM " + RetSqlName("SD3") + " SD3(NOLOCK) "
		MF007 += "          INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
		MF007 += "                               AND B1_COD = D3_COD "
		MF007 += "                               AND SB1.D_E_L_E_T_ = ' ' "
		MF007 += "          WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
		MF007 += "            AND D3_EMISSAO BETWEEN '" + dtos(kjDtINI) + "' AND '" + dtos(kjDtFIM) + "' "
		MF007 += "            AND D3_TM = '010' "
		MF007 += "            AND D3_ESTORNO = ' ' "
		MF007 += "            AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
		MF007 += "            AND D3_TIPO = '" + kjTpPrd + "' "
		If !Empty(kjPrdRf) .and. !Empty(kjPRfAt)
			MF007 += "            AND D3_COD BETWEEN '" + kjPrdRf + "' AND '" + kjPRfAt + "' "
		EndIf
		MF007 += "            AND SD3.D_E_L_E_T_ = ' ') AS TABRD "
		MF007 += "  WHERE PSECO = 0 "
		MF1cIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,MF007),'MF07',.T.,.T.)
		dbSelectArea("MF07")
		dbGoTop()
		While !Eof()

			IncProc()

			oExcel:AddRow(nxPlan, nxTabl, { MF07->B1_COD, MF07->DESCR })

			dbSelectArea("MF07")
			dbSkip()
		End

		MF07->(dbCloseArea())
		Ferase(MF1cIndex+GetDBExtension())
		Ferase(MF1cIndex+OrdBagExt())

		xArqTemp := "produtos-sem-peso"

		If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
		EndIf

		oExcel:Activate()
		oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

		cCrLf := Chr(13) + Chr(10)
		If ! ApOleClient( 'MsExcel' )
			MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
		Else
			oExcel:= MsExcel():New()
			oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
			oExcel:SetVisible(.T.)
		EndIf

		Return

	EndIf

	msAplicMOD := ""

	msKernelCt := U_BIA185( kjDtINI, kjDtFIM )
	msNomeTMP  := "##TMPBIA788" + cEmpAnt + cFilAnt + __cUserID + strzero(seconds() * 3500,10)
	msMontaSql := msKernelCt + "SELECT * INTO " + msNomeTMP + " FROM TABFINAL "
	U_BIAMsgRun("Aguarde... Gerando Base...",,{|| TcSQLExec(msMontaSql)})

	MZ003 := Alltrim(" WITH BUSCAMOD AS (                                                                                                            ") + xrEnter
	MZ003 += Alltrim(" SELECT TBDADOS.* ,                                                                                                            ") + xrEnter
	MZ003 += Alltrim("        CASE                                                                                                                   ") + xrEnter 
	MZ003 += Alltrim("            WHEN CLVL IN ( '6112', '6208', '6500' ) THEN 'GASTOS COM SEGURANCA'                                                        ") + xrEnter
	MZ003 += Alltrim("            WHEN CLVL IN ( '3180', '3181', '3183', '3184', '3280' ) THEN 'COGERACAO'                                           ") + xrEnter
	MZ003 += Alltrim("            ELSE Z29.Z29_DESCR                                                                                                 ") + xrEnter
	MZ003 += Alltrim("        END DITCUS,                                                                                                            ") + xrEnter
	MZ003 += Alltrim("        CASE                                                                                                                   ") + xrEnter 
	MZ003 += Alltrim("            WHEN CLVL IN ( '6112', '6208', '6500' ) THEN 'CF'                                                                          ") + xrEnter
	MZ003 += Alltrim("            WHEN CLVL IN ( '3180', '3181', '3183', '3184', '3280' ) THEN 'CV'                                                  ") + xrEnter
	MZ003 += Alltrim("            WHEN ITCUS = '050' THEN 'CF'                                                                                       ") + xrEnter
	MZ003 += Alltrim("            ELSE Z29.Z29_TIPO                                                                                                  ") + xrEnter
	MZ003 += Alltrim("        END TPCUST,                                                                                                            ") + xrEnter
	MZ003 += Alltrim("        CASE                                                                                                                   ") + xrEnter 
	MZ003 += Alltrim("            WHEN RTRIM(CLVL) IN('3801') THEN 'MP'                                                                              ") + xrEnter
	MZ003 += Alltrim("            WHEN RTRIM(CLVL) IN('3802','3803') THEN 'PI'                                                                       ") + xrEnter
	MZ003 += Alltrim("            WHEN RTRIM(CLVL) IN('3804','3805') THEN 'PA'                                                                       ") + xrEnter
	MZ003 += Alltrim("            WHEN CLVL IN ( '6112', '6208' ) THEN 'PP'                                                                          ") + xrEnter
	MZ003 += Alltrim("            WHEN CLVL IN ( '3180', '3181', '3183', '3184', '3280' ) THEN 'PP'                                                  ") + xrEnter
	MZ003 += Alltrim("            WHEN RTRIM(CLVL) IN('3500', '3501', '3502', '6500') THEN 'PA'                                                      ") + xrEnter
	MZ003 += Alltrim("            WHEN MODS <> 'DIRETA' AND (SELECT COUNT(*) CONTAD                                                                  ") + xrEnter
	MZ003 += Alltrim("                                         FROM " + RetSqlName("SB1") + " XB1 (NOLOCK)                                           ") + xrEnter
	MZ003 += Alltrim("                                         JOIN (SELECT '%E03%' AS Pattern                                                       ") + xrEnter
	MZ003 += Alltrim("                                                UNION ALL SELECT '%E04%'                                                       ") + xrEnter
	MZ003 += Alltrim("                                                UNION ALL SELECT '%E6A%'                                                       ") + xrEnter
	MZ003 += Alltrim("                                                UNION ALL SELECT '%E6B%'                                                       ") + xrEnter
	MZ003 += Alltrim("                                                UNION ALL SELECT '%R01%'                                                       ") + xrEnter
	MZ003 += Alltrim("                                                UNION ALL SELECT '%R02%'                                                       ") + xrEnter
	MZ003 += Alltrim("                                                UNION ALL SELECT '%R09%') AS Patterns ON B1_COD LIKE Patterns.Pattern          ") + xrEnter
	MZ003 += Alltrim("                                        WHERE B1_COD = MODS) = 1 THEN 'PA'                                                     ") + xrEnter
	MZ003 += Alltrim("            WHEN RTRIM(SUBSTRING(AGRUP, 1, 10)) NOT IN('615', '616', '617')                                                    ") + xrEnter
	MZ003 += Alltrim("                 AND SUBSTRING(AGRUP, 1, 3) IN('E03', 'E04', 'R01', 'R02', 'R09', 'E6A', 'E6B')                                              ") + xrEnter
	MZ003 += Alltrim("            THEN 'PA'                                                                                                          ") + xrEnter
	MZ003 += Alltrim("            WHEN SUBSTRING(CTA, 1, 5) IN ( '61104', '61110' ) THEN 'PA'                                                        ") + xrEnter
	MZ003 += Alltrim("            WHEN SUBSTRING(CTA, 1, 5) NOT IN ( '61104', '61110' ) THEN 'PP'                                                    ") + xrEnter
	MZ003 += Alltrim("            ELSE 'PP'                                                                                                          ") + xrEnter
	MZ003 += Alltrim("        END APLIC                                                                                                              ") + xrEnter
	MZ003 += Alltrim(" FROM   " + msNomeTMP + " TBDADOS                                                                                              ") + xrEnter
	MZ003 += Alltrim("        LEFT JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'                                            ") + xrEnter
	MZ003 += Alltrim("                                AND B1_COD = MODS                                                                              ") + xrEnter
	MZ003 += Alltrim("                                AND SB1.D_E_L_E_T_ = ' '                                                                       ") + xrEnter
	MZ003 += Alltrim("        LEFT JOIN " + RetSqlName("Z29") + " Z29(NOLOCK) ON Z29.Z29_FILIAL = '"+xFilial("Z29")+"'                                       ") + xrEnter
	MZ003 += Alltrim("                                AND Z29.Z29_COD_IT = ITCUS                                                                     ") + xrEnter
	MZ003 += Alltrim("                                AND Z29.D_E_L_E_T_ = ' '                                                                       ") + xrEnter
	MZ003 += Alltrim("        LEFT JOIN " + RetSqlName("Z29") + " XZ29(NOLOCK) ON XZ29.Z29_FILIAL = '"+xFilial("Z29")+"'                                     ") + xrEnter
	MZ003 += Alltrim("                                AND XZ29.Z29_COD_IT = B1_YITCUS                                                                ") + xrEnter
	MZ003 += Alltrim("                                AND XZ29.D_E_L_E_T_ = ' ')                                                                     ") + xrEnter
	MZ003 += Alltrim(" SELECT SUBSTRING(RTRIM(MODS) + Space(15-Len(RTRIM(MODS))), 1, 15) MODS,                                                       ") + xrEnter
	MZ003 += Alltrim("        APLIC,                                                                                                                 ") + xrEnter
	MZ003 += Alltrim("        REGRAC,                                                                                                                ") + xrEnter
	MZ003 += Alltrim("        ' ' GRVOK,                                                                                                             ") + xrEnter
	MZ003 += Alltrim("        0 CT_ESTR                                                                                                              ") + xrEnter
	MZ003 += Alltrim(" FROM BUSCAMOD                                                                                                                 ") + xrEnter
	MZ003 += Alltrim(" WHERE RTRIM(MODS) <> 'DIRETA'                                                                                                 ") + xrEnter
	If !Empty(MV_PAR06)
		MZ003 += Alltrim("            AND RTRIM(MODS) = '" + Alltrim(MV_PAR06) + "'                                                                  ") + xrEnter
	EndIf
	MZ003 += Alltrim("            AND APLIC = '" + kjTpPrd + "'                                                                                      ") + xrEnter
	MZ003 += Alltrim("  GROUP BY MODS, APLIC, REGRAC                                                                                                 ") + xrEnter
	MZ003 += Alltrim(" HAVING SUM(VALOR) <> 0                                                                                                        ") + xrEnter
	MZ003 += Alltrim(" ORDER BY MODS                                                                                                                 ") + xrEnter
	MZ3cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,MZ003),'MZ03',.T.,.T.)
	aStru1 := ("MZ03")->(dbStruct())
	dbSelectArea("MZ03")
	dbGoTop()
	While !Eof()

		If Empty(MZ03->REGRAC)
			MZ03->(dbCloseArea())
			Ferase(MZ3cIndex+GetDBExtension())
			Ferase(MZ3cIndex+OrdBagExt())
			Aviso('Regra de Rateio','Necessário verificar pois existem MODs que estão sem regra de rateio!',{'Ok'})
			Return
		EndIf

		msAplicMOD += MZ03->MODS + ","

		dbSelectArea("MZ03")
		dbSkip()

	End
	dbSelectArea("MZ03")
	dbGoTop()

	// Tratamento incluído em 24/01/16 em atendimento a OS effettivo 0306-17
	msProbmAplic := .F.
	msModProblm  := "Lista de MODs com problema de aplicação no " + kjTpPrd + ":" + CHR(13) + CHR(10) + CHR(13) + CHR(10)
	XL009 := " WITH APLICMOD AS (SELECT B1_COD, "
	XL009 += "                          SUBSTRING(B1_DESC,1,50) DESCR, "
	XL009 += "                          B1_YITCUS, "
	XL009 += "                          Z29_DESCR, "
	XL009 += "                          CASE "
	XL009 += "                            WHEN SUBSTRING(B1_COD, 6, 4) IN('3801') "
	XL009 += "                            THEN 'MP' "
	XL009 += "                            WHEN SUBSTRING(B1_COD, 6, 4) IN('3802', '3803') "
	XL009 += "                            THEN 'PI' "
	XL009 += "                            WHEN SUBSTRING(B1_COD, 6, 4) IN('3804', '3805') "
	XL009 += "                            THEN 'PA' "
	XL009 += "                            WHEN Z29_APLTPP <> 'XX' "
	XL009 += "                            THEN Z29_APLTPP "
	XL009 += "                            WHEN Z29_APLTPP = 'XX' AND '" + kjTpPrd + "' IN('PP', 'PA') "
	XL009 += "                            THEN '" + kjTpPrd + "' "
	XL009 += "                            WHEN RIGHT(RTRIM(B1_COD),3) IN('E03', 'E04', 'R01', 'R02', 'R09', 'E6A', 'E6B') "
	XL009 += "                            THEN 'PA' "
	XL009 += "                            WHEN RIGHT(RTRIM(B1_COD),3) IN('L01', 'L03', 'L06', 'TOT') "
	XL009 += "                            THEN 'PP' "
	XL009 += "                            ELSE 'ER' "
	XL009 += "                          END APLIC "
	XL009 += "                     FROM " + RetSqlName("SB1") + " SB1(NOLOCK) "
	XL009 += "                     LEFT JOIN " + RetSqlName("Z29") + " Z29(NOLOCK) ON Z29_COD_IT = B1_YITCUS "
	XL009 += "                                         AND Z29.D_E_L_E_T_ = ' ' "
	XL009 += "                    WHERE B1_FILIAL = '  ' "
	XL009 += "                      AND B1_COD IN " + FormatIn(msAplicMOD, ",")
	XL009 += "                      AND SB1.D_E_L_E_T_ = ' ') "
	XL009 += " SELECT * "
	XL009 += "   FROM APLICMOD "
	If kjTpPrd == "PA"
		If cEmpAnt == "14"
			// 03/08/21... Até segunda ordem todas as MODs da empresa 14 serão aceitas para o TpProd == PA
			XL009 += "  WHERE 1 <> 1 "
		Else
			XL009 += "  WHERE APLIC <> '" + kjTpPrd + "' "
		EndIf
	Else
		XL009 += "  WHERE APLIC <> '" + kjTpPrd + "' "
	EndIf	
	XLIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XL009),'XL09',.T.,.T.)
	dbSelectArea("XL09")
	dbGoTop()
	While !Eof()
		msProbmAplic := .T.
		msModProblm += "MOD: " + XL09->B1_COD + " Descr.: " + XL09->DESCR + CHR(13) + CHR(10) + CHR(13) + CHR(10)
		dbSelectArea("XL09")
		dbSkip()
	End
	XL09->(dbCloseArea())
	Ferase(XLIndex+GetDBExtension())
	Ferase(XLIndex+OrdBagExt())

	If msProbmAplic
		Aviso('Aplicação de Custo', msModProblm,{'Ok'})
		Return
	EndIf

	MZ002 := " SELECT D3_COD, "
	MZ002 += "        D3_QUANT, "
	MZ002 += "        D3_TM, "
	MZ002 += "        D3_OP, "
	MZ002 += "        D3_DOC, "
	MZ002 += "        D3_EMISSAO, "
	MZ002 += "        D3_NUMSEQ, "
	MZ002 += "        D3_IDENT, "
	MZ002 += "        D3_USUARIO, "
	MZ002 += "        D3_CC, "
	MZ002 += "        D3_CLVL, "
	MZ002 += "        D3_YDRIVER, "
	MZ002 += "        (SELECT DISTINCT Z42_PSECO "
	MZ002 += "           FROM " + RetSqlName("Z42") + " Z42(NOLOCK) "
	MZ002 += "          WHERE Z42_FILIAL = '" + xFilial("Z42") + "' "
	MZ002 += "            AND Z42_FORMAT = B1_YFORMAT "
	MZ002 += "            AND Z42_BASE = B1_YBASE "
	MZ002 += "            AND Z42_ACABAM LIKE  '%' + B1_YACABAM + '%' "
	MZ002 += "            AND Z42_ESPESS LIKE  '%' + B1_YESPESS + '%' "
	MZ002 += "            AND Z42_TPPROD LIKE  '%' + B1_TIPO + '%' "
	MZ002 += "            AND '" + dtos(kjDtINI) + "' >= Z42_DTINI "
	MZ002 += "            AND '" + dtos(kjDtFIM) + "' <= Z42_DTFIM "
	MZ002 += "            AND Z42_VERSAO = '" + MV_PAR07 + "' "
	MZ002 += "            AND Z42_REVISA = '" + MV_PAR08 + "' "
	MZ002 += "            AND Z42_ANOREF = '" + MV_PAR09 + "' "
	MZ002 += "            AND Z42_FINALI = 'R' "
	MZ002 += "            AND Z42.D_E_L_E_T_ = ' ') PSECO "
	MZ002 += "   FROM " + RetSqlName("SD3") + " SD3(NOLOCK) "
	MZ002 += "  INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
	MZ002 += "                       AND B1_COD = D3_COD "
	MZ002 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	MZ002 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	MZ002 += "    AND D3_EMISSAO BETWEEN '" + dtos(kjDtINI) + "' AND '" + dtos(kjDtFIM) + "' "
	MZ002 += "    AND D3_TM = '010' "
	MZ002 += "    AND D3_ESTORNO = ' ' "
	MZ002 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	MZ002 += "    AND D3_TIPO = '" + kjTpPrd + "' "
	If !Empty(kjPrdRf) .and. !Empty(kjPRfAt)
		MZ002 += "    AND D3_COD BETWEEN '" + kjPrdRf + "' AND '" + kjPRfAt + "' "
	EndIf
	MZ002 += "    AND SD3.D_E_L_E_T_ = ' ' "
	MZ002 += "  ORDER BY D3_COD "
	MZ2cIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,MZ002),'MZ02',.T.,.T.)
	dbSelectArea("MZ02")
	dbGoTop()
	ProcRegua(0)
	kkjjCont := 0
	kAcuCont := 0
	While !Eof()

		jyCodProd := MZ02->D3_COD
		xxPlanFab := Substr(MZ02->D3_CLVL,2,1)
		kkjjCont  := 0
		IncProc("Processando... "+jyCodProd)

		dbSelectArea("MZ03")
		dbGoTop()
		/*   Exporta os dados do resultado de uma  |
		| Query para um arquivo temporário normal */
		If !chkfile("MZ04")
			MZ04 := U_BIACrTMP(aStru1)
			dbUseArea( .T.,, MZ04, "MZ04", .F., .F. )
			dbCreateInd(MZ04, "MODS", {|| MODS } )
		EndIf
		dbSelectArea("MZ04")
		APPEND FROM ("MZ03")

		// Início tratamento para gravação de MOD
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + jyCodProd))
		SBZ->(dbSetOrder(1))
		SBZ->(dbSeek(xFilial("SBZ") + jyCodProd))
		wxTpProd   := SB1->B1_YTPPROD
		nEstru     := 0
		wProduto   := jyCodProd
		wQtd       := 1
		cArqTmp    := ""
		cAliasTRB  := cArqTRB := "Estrut"
		wxRevAtu   := fncRvAtu(wProduto) //SB1->B1_REVATU
		frDtOld    := dDataBase
		//dDataBase  := Date()
		yjCustoItm := .T. 
		cNome      := Processa({|| Strut788Bia(wProduto, wQtd, cAliasTRB, cArqTRB, .F., wxRevAtu, xxPlanFab) })
		dDataBase  := frDtOld
		cArqTRB    := cArqTmp
		ESTRUT->(dbGoTop())
		U_BIAFimStru(cAliasTRB,cArqTRB)

		dbSelectArea("MZ04")
		dbGoTop()
		While !Eof()

			// Tratamento implementado durante o fechamento do custo de dezembro de 2018, após a unificação dos CNPJs - 20190104SAM
			//Em 03/12/21 - Tratamento específico para Linha6
			If Substr(MZ04->MODS,4,1) == "0" .or. Substr(MZ04->MODS,4,1) == xxPlanFab .or. (Alltrim(MZ04->MODS) $ "MOD761101/MOD7PM3" .and. Substr(jyCodProd, 1, 2) == "BP")

				If MZ04->GRVOK <> "S" .or. Substr(MZ04->MODS, 5, 11) $ "61108003   "

					//  Esta MOD's tem tratamento especial porque mesmo estando classificadas no grupo de contas contábeis
					// variáveis, não estão na estrutura de produto passando a custo fixo.
					If Substr(MZ04->MODS, 5, 11) $ "61103002   " .or. Substr(MZ04->MODS, 5, 11) $ "61103003   " .or. Substr(MZ04->MODS, 5, 11) $ "61108003   "
						RecLock("MZ04",.F.)
						MZ04->GRVOK   := "S"
						MZ04->CT_ESTR := 1
						MsUnLock()
					EndIf

					If Substr(MZ04->MODS, 5, 5) $ "61109"
						RecLock("MZ04",.F.)
						MZ04->GRVOK   := "S"
						MZ04->CT_ESTR := 1
						MsUnLock()
					EndIf

					If Substr(MZ04->MODS, 5, 3) $ "612/613/614/615/616/617"
						RecLock("MZ04",.F.)
						MZ04->GRVOK   := "S"
						MZ04->CT_ESTR := 1
						MsUnLock()
					EndIf

					// Por Marcos Alberto Soprani em em 05/02/18 em atendimento ao ticket 1535
					If cEmpAnt == "01" .and. dtos(MV_PAR01) >= "20180101"
						If Substr(MZ04->MODS, 5, 5) $ "61108"
							RecLock("MZ04",.F.)
							MZ04->GRVOK   := "S"
							MZ04->CT_ESTR := 1
							MsUnLock()
						EndIf
					EndIf

					If cEmpAnt == "14" .and. dtos(MV_PAR01) >= "20211001"
						If Substr(MZ04->MODS, 5, 5) $ "61108"
							RecLock("MZ04",.F.)
							MZ04->GRVOK   := "S"
							MZ04->CT_ESTR := 1
							MsUnLock()
						EndIf
					EndIf

					If Substr(MZ04->MODS, 5, 3) $ "GCS"
						RecLock("MZ04",.F.)
						MZ04->GRVOK   := "S"
						MZ04->CT_ESTR := 0.001
						MsUnLock()
					EndIf

					If Substr(MZ04->MODS, 5, 3) $ "MOP"
						RecLock("MZ04",.F.)
						MZ04->GRVOK   := "S"
						MZ04->CT_ESTR := 0.001
						MsUnLock()
					EndIf					

					// Projeto JK
					If Substr(MZ04->MODS, 4, 1) $ "8" .and. Alltrim(MZ02->D3_CLVL) $ MZ04->MODS
						RecLock("MZ04",.F.)
						MZ04->GRVOK   := "S"
						MZ04->CT_ESTR := 1
						MsUnLock()
					EndIf					

				EndIf

			Else

				RecLock("MZ04",.F.)
				MZ04->GRVOK   := "N"
				MZ04->CT_ESTR := 0
				MsUnLock()

			EndIf

			dbSelectArea("MZ04")
			dbSkip()

		End
		// Fim tratamento MOD

		dbSelectArea("MZ02")
		While !Eof() .and. MZ02->D3_COD == jyCodProd

			kkjjCont ++
			kAcuCont ++
			IncProc("Proc... " + Alltrim(jyCodProd) + " Ind: " + Alltrim(Str(kkjjCont))+ " Acu: " + Alltrim(Str(kAcuCont)))

			// Divisor por 1000 para atender ao plano de ação do Industrial que objetiva diminuir os valores finais do resto dos rateio. Em 03/04/14
			kj_Pesol := MZ02->PSECO / 1000
			If cEmpAnt == "06"
				kj_Pesol := MZ02->PSECO
			EndIf

			kj_PlBkp := kj_Pesol
			dfPerct  := 0
			kj_TM    := "999"
			kj_CF    := "RE1"

			dbSelectArea("MZ04")
			dbGoTop()
			While !Eof()

				If MZ04->GRVOK == "S"

					xMODsEspc := .T.

					// Observado que existem lançamentos contábeis de Custo na Incesa com Classe Valor da Biancogres
					If cEmpAnt == "01"
						If "L01" $ MZ04->MODS .and. !Alltrim(MZ02->D3_CLVL) $ "3110/3111/3112/3113/3115/3116/3191"   //"3110/3191" Alterado em 02/02/16
							xMODsEspc := .F.
						ElseIf "L03" $ MZ04->MODS .and. !Alltrim(MZ02->D3_CLVL) $ "3130/3131/3132/3133/3138/3193"   //"3130/3193" Alterado em 02/02/16
							xMODsEspc := .F.
						ElseIf "E03" $ MZ04->MODS .and. !Alltrim(MZ02->D3_CLVL) $ "3135/3139/3195"   //"3135/3195" Alterado em 02/02/16
							xMODsEspc := .F.
						ElseIf "E04" $ MZ04->MODS .and. !Alltrim(MZ02->D3_CLVL) $ "3136/3137/3196"   //"3136/3196" Alterado em 02/02/16
							xMODsEspc := .F.
						ElseIf "EA6" $ MZ04->MODS .and. !Alltrim(MZ02->D3_CLVL) $ "3735"   //"3735" Alterado em 05/11/21
							xMODsEspc := .F.
						ElseIf "R01" $ MZ04->MODS .and. !Alltrim(MZ02->D3_CLVL) $ "3117/3197/6101"   // Incluído em 03/03/16
							xMODsEspc := .F.
						ElseIf "R09" $ MZ04->MODS .and. !Alltrim(MZ02->D3_CLVL) $ "3155"   // Incluído em 06/03/17
							xMODsEspc := .F.
						EndIf
						If wxTpProd == "RP" .and. Substr(MZ04->MODS,1,9) == "MOD" + xxPlanFab + "61110" 
							xMODsEspc := .F.
						EndIf
						If "R02" $ MZ04->MODS .and. !Alltrim(MZ02->D3_CLVL) $ "3217/3297"   // Incluído em 02/10/18
							xMODsEspc := .F.
						EndIf
					EndIf

					If cEmpAnt == "05"
						If "R02" $ MZ04->MODS .and. !Alltrim(MZ02->D3_CLVL) $ "3217/3297"   // Incluído em 02/10/18
							xMODsEspc := .F.
						EndIf
					EndIf

					//Em 03/12/21 - Tratamento específico para Linha6
					If "MOD261101" $ MZ04->MODS .and. Substr(jyCodProd, 1, 2) == "BP"
						xMODsEspc := .F.
					EndIf

					If xMODsEspc

						htObsQtd := ""
						kj_Quant := 0
						If MZ04->REGRAC == "1"                        // Capacidade Produtiva
							*****************************************************************
							Aviso('Capacidade Produtiva','Necessário verificar as definições de rateio, pois a MOD '+Alltrim(MZ04->MODS)+' está definido para rateio pela capacidade produtiva!',{'Ok'})

						ElseIf MZ04->REGRAC == "2"                                    // PESO
							*****************************************************************
							// Tratamento para o peso implementado em 25/07/14 a pedido da diretoria
							// (identificado por Saulo e Jecimar durante as verificações do custo de junho de 2014)
							// Em 07/03/17... Por Marcos Alberto Soprani... estas contas SÃO VARIÁVEIS, portanto usam apenas o resultado da estrutra para compor a ponderação.
							If Substr(MZ04->MODS, 5, 11) $ "COG        /GCS        /61107      /61101004   /61103001   /61108      /61101      /61104003   /61105001   /61108L03   /61108L01   "
								kj_Pesol := 1
							Else
								kj_Pesol := kj_PlBkp
							EndIf
							kj_Quant := kj_Pesol * MZ02->D3_QUANT * MZ04->CT_ESTR
							htObsQtd := "Peso: " + Transform(kj_Pesol,"@E 999,999.99999999") + " M2: " + Transform(MZ02->D3_QUANT,"@E 999,999.99999999") + " Estrut: " + Transform(MZ04->CT_ESTR,"@E 999,999.99999999")

						ElseIf MZ04->REGRAC == "3"                           // Produção - M2
							*****************************************************************
							kj_Quant := MZ02->D3_QUANT * MZ04->CT_ESTR
							htObsQtd := "Peso: " + Transform(0,"@E 999,999.99999999")        + " M2: " + Transform(MZ02->D3_QUANT,"@E 999,999.99999999") + " Estrut: " + Transform(MZ04->CT_ESTR,"@E 999,999.99999999")

						EndIf

						If kj_Quant <> 0

							dbSelectArea("SB2")
							dbSetOrder(1)
							If !dbSeek(xFilial("SB2") + MZ04->MODS + "40")
								RecLock("SB2",.T.)
								SB2->B2_FILIAL := xFilial("SB2")
								SB2->B2_COD    := MZ04->MODS
								SB2->B2_LOCAL  := "40"
								MsUnlock()
							EndIf

							dbSelectArea("SB1")
							dbSetOrder(1)
							dbSeek(xFilial("SB1") + MZ04->MODS)

							// Tratamento feito para comtemplar as MOD's que estão amarradas às linhas de produção/total. Além da MOD específica da Cogeração (COG).
							xdContaC := Alltrim(Substr(MZ04->MODS, 5, 11))
							// Conforme ticket 30233
							If Alltrim(xdContaC) == "ATM"
								xdContaC := "61103004"
							EndIf
							CT1->(dbSetOrder(1))
							If !CT1->(dbSeek(xFilial("CT1")+xdContaC))
								CT1->(dbSetOrder(1))
								If CT1->(dbSeek(xFilial("CT1")+Substr(xdContaC,1,3)))
									xdContaC := Substr(xdContaC,1,3)
								EndIf
							EndIf

							// tratativa incluída para controle de custo de embalagem no formato C1 somente para 01/01/17
							jkConfirm := .T.

							If jkConfirm

								dbSelectArea("SD3")
								dbSetOrder(4)
								If !dbSeek(xFilial("SD3") + MZ02->D3_NUMSEQ + "E0" + MZ04->MODS)
									RecLock("SD3",.T.)
								Else
									RecLock("SD3",.F.)
								EndIf
								SD3->D3_FILIAL   := xFilial("SD3")
								SD3->D3_TM       := kj_TM
								SD3->D3_OP       := MZ02->D3_OP
								SD3->D3_COD      := MZ04->MODS
								SD3->D3_UM       := SB1->B1_UM
								SD3->D3_YAPLIC   := "1"
								SD3->D3_YDRIVER   := MZ02->D3_YDRIVER
								SD3->D3_QUANT    := kj_Quant
								SD3->D3_QTSEGUM  := ConvUm(SD3->D3_COD, SD3->D3_QUANT, 0, 2)
								SD3->D3_LOCAL    := SB1->B1_LOCPAD
								SD3->D3_CC       := "3000"
								SD3->D3_CLVL     := MZ02->D3_CLVL
								SD3->D3_CONTA    := xdContaC
								SD3->D3_TIPO     := SB1->B1_TIPO
								SD3->D3_GRUPO    := SB1->B1_GRUPO
								SD3->D3_EMISSAO  := stod(MZ02->D3_EMISSAO)
								SD3->D3_DOC      := MZ02->D3_DOC
								SD3->D3_USUARIO  := MZ02->D3_USUARIO
								SD3->D3_CHAVE    := "E0"
								SD3->D3_YRFCUST  := "BIA788"
								SD3->D3_YOBS     := "Grava rateio de MOD. " + htObsQtd
								SD3->D3_CF       := kj_CF
								SD3->D3_NUMSEQ   := MZ02->D3_NUMSEQ
								SD3->D3_IDENT    := MZ02->D3_IDENT
								MsUnlock()

							EndIf

						EndIf

					EndIf

				EndIf

				dbSelectArea("MZ04")
				dbSkip()

			End

			dbSelectArea("MZ02")
			dbSkip()

		End

		MZ04->(dbCloseArea())
		Ferase(MZ04+GetDBExtension())
		Ferase(MZ04+OrdBagExt())

	End

	MZ02->(dbCloseArea())
	Ferase(MZ2cIndex+GetDBExtension())
	Ferase(MZ2cIndex+OrdBagExt())

	MZ03->(dbCloseArea())
	Ferase(MZ3cIndex+GetDBExtension())
	Ferase(MZ3cIndex+OrdBagExt())

	//Gabriel Rossi Mafioletti - 20190716 - Tratativa para rateio do MOD de massa(MOD161101/MOD261101)
	ConOut("HORA: "+TIME()+" - RECALCULO MOD - MASSA - ROTINA BIA788ANALISE")
	fRecModMas()
	ConOut("HORA: "+TIME()+" - RECALCULO ESMALTE - MASSA - ROTINA BIA788ANALISE")
	fRecModEsm()
	ConOut("HORA: "+TIME()+" - RECALCULO MOD - TINTA - ROTINA BIA788ANALISE")
	fRecModTin()
	ConOut("HORA: "+TIME()+" - RECALCULO MOD - DEFLOCULANTE - ROTINA BIA788ANALISE")
	fRecModDef()
	ConOut("HORA: "+TIME()+" - RECALCULO MOD - OUTROS - ROTINA BIA788ANALISE")
	fCOutros()

	oLogProc:LogFimProc()

	MsgINFO("........: Fim do Processamento : ........")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ Strut788Bia ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 26.05.06 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Strut788Bia(cProduto, nQuant, cAliasEstru, cArqTrab, lAsShow, cRevisao, cPlanFab)

	LOCAL nRegi:=0,nQuantItem:=0
	LOCAL aCampos:={},aTamSX3:={},lAdd:=.F.
	LOCAL nRecno
	cAliasEstru:=IF(cAliasEstru == NIL,"ESTRUT",cAliasEstru)
	nQuant:=IF(nQuant == NIL,1,nQuant)
	lAsShow  := IF(lAsShow == NIL, .F., lAsShow)
	cPlanFab := IF(cPlanFab == NIL, "", cPlanFab)
	nEstru++
	If nEstru == 1
		// Cria arquivo de Trabalho
		aTamSX3:=TamSX3("G1_COD")
		AADD(aCampos,{"CODIGO","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_COMP")
		AADD(aCampos,{"COMP","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_TRT")
		AADD(aCampos,{"TRT","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_QUANT")
		AADD(aCampos,{"QUANT","N",Max(aTamSX3[1],18),aTamSX3[2]})
		cArqTrab := CriaTrab(aCampos)
		If Select(cAliasEstru) > 0
			dbSelectArea(cAliasEstru)
			dbCloseArea()
		EndIf
		Use &cArqTrab NEW Exclusive Alias &(cAliasEstru)
		IndRegua(cAliasEstru,cArqTrab,"CODIGO+COMP+TRT",,,"Selecionando Registros...")
		dbSetIndex(cArqtrab+OrdBagExt())
	EndIf

	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc(wProduto + " 1 Tempo: " + cTempo)

	dbSelectArea("SG1")
	dbSetOrder(1)
	dbSeek(xFilial("SG1")+cProduto)

	While !Eof() .and. Alltrim(SG1->G1_FILIAL+SG1->G1_COD) == Alltrim(xFilial("SG1")+cProduto)

		nRegi := Recno()

		If SG1->G1_COD != SG1->G1_COMP

			lAdd := .F.

			If dDataBase >= SG1->G1_INI .and. dDataBase <= SG1->G1_FIM

				// Retorno somado à Massa. Incluido em 30/09/11 para equiparação do programa ao que o Jecimar faz no excel
				sm_Perc := 0
				sm_QtdPlus := 0
				sm_QtdBkp := nQuant
				If AK08->(dbSeek(SG1->G1_COD)) .and. AK08->PERC < 100
					sm_Perc := (SG1->G1_YMISTUR / AK08->PERC) * 100
					sm_QtdPlus := sm_Perc * nQuant / SG1->G1_YMISTUR
					nQuant := sm_QtdPlus
				EndIf

				// Cálculo padrão do sistema para perda
				// nQuantItem := ((nQuant * nG1Quant) / (100 - G1_PERDA)) * 100
				// nQuant = Quantidade Pai
				// nG1Quanto = Quantidade Corrente do Componente
				nQuantItem := xBia788E(nQuant, dDataBase, dDataBase) //ExplEstr(nQuant,,,cRevisao)
				nQuant     := sm_QtdBkp

				// Necessário restaurar a quantidade origem
				//nQuantItem := ( nQuantItem * (100 - SG1->G1_PERDA) ) / 100

				fGrvBsCtRat(nQuantItem, cPlanFab)

				dbSelectArea("SG1")

				// Verifica se existe sub-estrutura
				nRecno:=Recno()
				If dbSeek(xFilial("SG1") + SG1->G1_COMP)
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1") + SG1->G1_COD))
					SBZ->(dbSetOrder(1))
					SBZ->(dbSeek(xFilial("SBZ") + SG1->G1_COD))
					Strut788Bia(SG1->G1_COD, nQuantItem, cAliasEstru, cArqTrab, lAsShow, fncRvAtu(SG1->G1_COD), cPlanFab)
					nEstru --
				EndIf

			EndIf

		EndIf

		dbGoto(nRegi)
		dbSkip()

	End
	cArqTmp := cArqTrab

Return cArqTrab

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fGrvBsCtRat¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 06.05.14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fGrvBsCtRat(xQuantIt, xPlanFab)

	Local grRetArea := GetArea()

	SBZ->(dbSetOrder(1))
	SBZ->(dbSeek(xFilial("SBZ") + SG1->G1_COMP))

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + SG1->G1_COMP))

	xk_Custo := 0
	If SBZ->BZ_YCTREF == 0

		A0001 := " SELECT ISNULL((SELECT SUM(SD1.D1_CUSTO) / SUM(SD1.D1_QUANT)
		A0001 += "                  FROM " + RetSqlName("SD1") + " SD1(NOLOCK)
		A0001 += "                 INNER JOIN " + RetSqlName("SF4") + " SF4(NOLOCK) ON F4_FILIAL = '" + xFilial("SF4") + "'
		A0001 += "                                      AND F4_CODIGO = D1_TES
		A0001 += "                                      AND F4_ESTOQUE = 'S'
		A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '
		A0001 += "                 INNER JOIN " + RetSqlName("SF1") + " SF1(NOLOCK) ON F1_FILIAL = D1_FILIAL
		A0001 += "                                      AND F1_DOC = D1_DOC
		A0001 += "                                      AND F1_SERIE = D1_SERIE
		A0001 += "                                      AND F1_FORNECE = D1_FORNECE	
		A0001 += "                                      AND F1_LOJA = D1_LOJA
		A0001 += "                                      AND F1_EMISSAO = D1_EMISSAO
		A0001 += "                                      AND F1_STATUS <> 'B'
		A0001 += "                                      AND SF1.D_E_L_E_T_ = ' '
		A0001 += "                 WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "'
		A0001 += "                   AND SD1.D1_COD = '" + SG1->G1_COMP + "'
		A0001 += "                   AND SD1.D1_DTDIGIT <= '" + dtos(dDataBase) + "'
		A0001 += "                   AND SD1.D1_TES NOT IN('3I7')
		A0001 += "                   AND SD1.D1_DTDIGIT IN(SELECT MAX(XD1.D1_DTDIGIT)
		A0001 += "                                           FROM " + RetSqlName("SD1") + " XD1(NOLOCK)
		A0001 += "                                          INNER JOIN " + RetSqlName("SF4") + " SF4(NOLOCK) ON F4_FILIAL = '" + xFilial("SF4") + "'
		A0001 += "                                                               AND F4_CODIGO = D1_TES
		A0001 += "                                                               AND F4_ESTOQUE = 'S'
		A0001 += "                                                               AND SF4.D_E_L_E_T_ = ' '
		A0001 += "                                          INNER JOIN " + RetSqlName("SF1") + " SF1(NOLOCK) ON F1_FILIAL = XD1.D1_FILIAL
		A0001 += "                                                               AND F1_DOC = XD1.D1_DOC
		A0001 += "                                                               AND F1_SERIE = XD1.D1_SERIE
		A0001 += "                                                               AND F1_FORNECE = XD1.D1_FORNECE	
		A0001 += "                                                               AND F1_LOJA = XD1.D1_LOJA
		A0001 += "                                                               AND F1_EMISSAO = XD1.D1_EMISSAO
		A0001 += "                                                               AND F1_STATUS <> 'B'
		A0001 += "                                                               AND SF1.D_E_L_E_T_ = ' '
		A0001 += "                                          WHERE XD1.D1_FILIAL = '" + xFilial("SD1") + "'
		A0001 += "                                            AND XD1.D1_COD = '" + SG1->G1_COMP + "'
		A0001 += "                                            AND XD1.D1_DTDIGIT <= '" + dtos(dDataBase) + "'
		A0001 += "                                            AND XD1.D1_TIPO = 'N'
		A0001 += "                                            AND XD1.D1_QUANT <> 0
		A0001 += "                                            AND XD1.D_E_L_E_T_ = ' ')
		A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) CTMEDIO
		TcQuery A0001 ALIAS "A001" NEW
		dbSelectArea("A001")
		dbGoTop()
		xk_Custo  := A001->CTMEDIO
		A001->(dbCloseArea())

	Else

		If SBZ->BZ_COD < "A"
			xk_Custo   := SBZ->BZ_YCTREF
		Else
			If !Substr(wProduto,1,7) $ "B90231B/B90218E/B90220I/B90219M/B90214C" .and. Posicione("SB1", 1, xFilial("SB1") + SG1->G1_COMP,"B1_TIPO") == "PA"
				xk_Custo   := SBZ->BZ_YCTREF
			EndIf
		EndIf

	EndIf

	// Tratamento para garantir que nenhum componente da estrutura fique sem custo unitário para penderação dos rateios. Por Marcos Alberto Soprani 05/11/14
	If xk_Custo == 0
		yjCustoItm := .F.
	EndIf

	// Novo tratamento para adicional de umidade
	If SBZ->BZ_YUMIDAD <> 0
		xQuantIt := xQuantIt/(-(((SBZ->BZ_YUMIDAD/100)/1)-1))
	EndIf

	// Gas TG
	If Alltrim(SG1->G1_COMP) == "1030019"
		dbSelectArea("MZ04")
		dbGoTop()
		If dbSeek(Padr("MOD" + xPlanFab + "COG", 15), .T.)
			RecLock("MZ04",.F.)
			MZ04->GRVOK   := "S"
			MZ04->CT_ESTR += Round( Round(xk_Custo,4) * xQuantIt ,4)
			MsUnLock()
		EndIf

	ElseIf Alltrim(SG1->G1_COMP) $ "1030027" //.and. cEmpAnt == "05" .and. Substr(dtos(MV_PAR02),1,6) >= "201508" // Incluido tratamento em 02/09/15 durante fechamento do custo de 08/2015.
		dbSelectArea("MZ04")
		dbGoTop()
		If dbSeek(Padr("MOD" + xPlanFab + "COG", 15), .T.)
			RecLock("MZ04",.F.)
			MZ04->GRVOK   := "S"
			MZ04->CT_ESTR += Round( Round(xk_Custo,4) * xQuantIt ,4)
			MsUnLock()
		EndIf

	ElseIf Alltrim(SG1->G1_COMP) $ "1030006/1030020"
		dbSelectArea("MZ04")
		dbGoTop()
		If dbSeek(Padr("MOD" + xPlanFab + Alltrim(SB1->B1_YCTRIND), 15), .T.)
			RecLock("MZ04",.F.)
			MZ04->GRVOK   := "S"
			MZ04->CT_ESTR += Round( Round(xk_Custo,4) * xQuantIt ,4)
			MsUnLock()
		EndIf

	ElseIf Alltrim(SG1->G1_COMP) $ "1030029"
		dbSelectArea("MZ04")
		dbGoTop()
		If dbSeek(Padr("MOD1ATM", 15), .T.)
			RecLock("MZ04",.F.)
			MZ04->GRVOK   := "S"
			MZ04->CT_ESTR += Round( Round(xk_Custo,4) * xQuantIt ,4)
			MsUnLock()
		EndIf

	Else

		dbSelectArea("MZ04")
		dbGoTop()
		If dbSeek(Padr("MOD" + xPlanFab + Alltrim(SB1->B1_YCTRIND), 15), .T.)
			RecLock("MZ04",.F.)
			MZ04->GRVOK   := "S"
			MZ04->CT_ESTR += Round( Round(xk_Custo,4) * xQuantIt ,4)
			MsUnLock()

		Else

			dbSelectArea("MZ04")
			dbGoTop()
			If dbSeek(Padr("MOD" + xPlanFab + Substr(Alltrim(SB1->B1_YCTRIND),1,5), 15), .T.)
				RecLock("MZ04",.F.)
				MZ04->GRVOK   := "S"
				MZ04->CT_ESTR += Round( Round(xk_Custo,4) * xQuantIt ,4)
				MsUnLock()

			ElseIf "L03" $ MZ04->MODS .and. Alltrim(MZ02->D3_CLVL) $ "3130/3131/3132/3133/3138/3193"      // Implementado em 07/03/17...
				dbSelectArea("MZ04")
				dbGoTop()
				If dbSeek(Padr("MOD" + xPlanFab + Substr(Alltrim(SB1->B1_YCTRIND),1,5) + "L03", 15), .T.)
					RecLock("MZ04",.F.)
					MZ04->GRVOK   := "S"
					MZ04->CT_ESTR += Round( Round(xk_Custo,4) * xQuantIt ,4)
					MsUnLock()
				EndIf

			ElseIf "L01" $ MZ04->MODS .and. Alltrim(MZ02->D3_CLVL) $ "3110/3191/3115/3111/3112/3113/3116"      // Implementado em 06/04/17...
				dbSelectArea("MZ04")
				dbGoTop()
				If dbSeek(Padr("MOD" + xPlanFab + Substr(Alltrim(SB1->B1_YCTRIND),1,5) + "L01", 15), .T.)
					RecLock("MZ04",.F.)
					MZ04->GRVOK   := "S"
					MZ04->CT_ESTR += Round( Round(xk_Custo,4) * xQuantIt ,4)
					MsUnLock()
				EndIf

			EndIf

		EndIf

	EndIf

	// Rateio de cogeração para a Classe de Valor 3280 - Incesa. Não haverá previsão para 2014. Os meses envolvidos serão nov/2014 e dez/2014. Por Marcos Alberto Soprani a pedido de Saulo - em 05/11/2014.
	If Alltrim(SG1->G1_COMP) == "1030018" .and. cEmpAnt == "05" .and. Substr(dtos(MV_PAR02),1,4) >= "2014" .and. Substr(dtos(MV_PAR02),1,6) >= "201507"
		dbSelectArea("MZ04")
		dbGoTop()
		If dbSeek(Padr("MOD" + xPlanFab + "COG", 15), .T.)
			RecLock("MZ04",.F.)
			MZ04->GRVOK   := "S"
			MZ04->CT_ESTR += Round( Round(xk_Custo,4) * xQuantIt ,4)
			MsUnLock()
		EndIf
	EndIf

	// Rateio de Energia para as duas fábricas 
	If MV_PAR03 == "PP" .and. "61105" $ Alltrim(SB1->B1_YCTRIND)
		dbSelectArea("MZ04")
		dbGoTop()
		If dbSeek(Padr("MOD" + "0" + "61105", 15), .T.)
			RecLock("MZ04",.F.)
			MZ04->GRVOK   := "S"
			MZ04->CT_ESTR += Round( Round(xk_Custo,4) * xQuantIt ,4)
			MsUnLock()
		EndIf
	EndIf

	//Em 03/12/21 - Tratamento específico para Linha6 - MASSA
	If Substr(Alltrim(SB1->B1_YCTRIND), 1, 5) == "61101" .and. Substr(jyCodProd, 1, 2) == "BP"
		dbSelectArea("MZ04")
		dbGoTop()
		If dbSeek(Padr("MOD" + "7" + Substr(Alltrim(SB1->B1_YCTRIND),1,5), 15), .T.)
			RecLock("MZ04",.F.)
			MZ04->GRVOK   := "S"
			MZ04->CT_ESTR += Round( Round(xk_Custo,4) * xQuantIt ,4)
			MsUnLock()
		EndIf
	EndIf

	//Em 03/12/21 - Tratamento específico para Linha6 - GAS NATURAL -->> PM2 e PM3 
	If Substr(Alltrim(SB1->B1_YCTRIND), 1, 8) == "61103001"
		If xPlanFab == "2" .and. Substr(jyCodProd, 1, 2) <> "BP" 
			dbSelectArea("MZ04")
			dbGoTop()
			If dbSeek(Padr("MOD" + "2" + "PM2", 15), .T.)
				RecLock("MZ04",.F.)
				MZ04->GRVOK   := "S"
				MZ04->CT_ESTR += Round( Round(xk_Custo,4) * xQuantIt ,4)
				MsUnLock()
			EndIf
		EndIf
		If xPlanFab == "7" .or. Substr(jyCodProd, 1, 2) == "BP"
			dbSelectArea("MZ04")
			dbGoTop()
			If dbSeek(Padr("MOD" + "7" + "PM3", 15), .T.)
				RecLock("MZ04",.F.)
				MZ04->GRVOK   := "S"
				MZ04->CT_ESTR += Round( Round(xk_Custo,4) * xQuantIt ,4)
				MsUnLock()
			EndIf
		EndIf
	EndIf

	RestArea(grRetArea)

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
	aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Tipo de Produto          ?","","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","02"})
	aAdd(aRegs,{cPerg,"04","Produto Especifico De    ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"05","Produto Especifico At    ?","","","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"06","Rodar MOD Específica     ?","","","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"07","Versão Orçamentária      ?","","","mv_ch7","C",10,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"08","Revisão Ativa            ?","","","mv_ch8","C",03,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Ano de Referência        ?","","","mv_ch9","C",04,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

Static Function fRecModMas()

	Local _cAlias	:=	GetNextAlias()
	Local _cAliasIt		
	Local _cDtIni	:=	DtoS(kjDtINI)
	Local _cDtFim	:=	DtoS(kjDtFIM)
	Local _nTotMod

	BeginSql Alias _cAlias
		%NoParser%
		WITH AJUSTE
		AS (
		SELECT CASE
		WHEN D3_LOCAL = '01'
		THEN 'MOD161101'
		WHEN D3_LOCAL = '20'
		AND SUBSTRING(D3_CLVL, 1, 2) = '32'
		THEN 'MOD261101'
		WHEN D3_LOCAL = '20'
		AND SUBSTRING(D3_CLVL, 1, 2) = '37'
		THEN 'MOD761101'
	END CODMOD
	,ABS(SUM(CASE 
	WHEN D3_TM >= '500'
	THEN D3_QUANT * (- 1)
	ELSE D3_QUANT
	END)) QTDAJUS
	FROM %TABLE:SD3% SD3(NOLOCK)
	WHERE D3_EMISSAO BETWEEN %Exp:_cDtIni%
	AND %Exp:_cDtFim%
	AND D3_OP = ''
	AND D3_CONTA = '61101020'
	AND D3_ESTORNO = ' '
	AND SD3.%NotDel%
	GROUP BY D3_LOCAL, SUBSTRING(D3_CLVL, 1, 2)
	)
	,MODS
	AS (
	SELECT D3_COD
	,ABS(SUM(CASE 
	WHEN D3_TM >= '500'
	THEN D3_QUANT * (- 1)
	ELSE D3_QUANT
	END)) TOTMOD
	FROM %TABLE:SD3% SD3(NOLOCK)
	WHERE D3_EMISSAO BETWEEN %Exp:_cDtIni%
	AND %Exp:_cDtFim%
	AND D3_COD IN (
	'MOD161101'
	,'MOD261101'
	,'MOD761101'
	)
	AND D3_ESTORNO = ' '
	AND SD3.%NotDel%
	GROUP BY D3_COD
	)
	SELECT CODMOD, QTDAJUS, TOTMOD
	FROM AJUSTE A
	JOIN MODS B ON A.CODMOD = B.D3_COD

	EndSql

	While (_cAlias)->(!EOF())

		_cAliasIt	:=	GetNextAlias()		

		BeginSql Alias _cAliasIt

			SELECT R_E_C_N_O_ REC
			FROM %TABLE:SD3% SD3(NOLOCK)
			WHERE D3_EMISSAO BETWEEN %Exp:_cDtIni%
			AND %Exp:_cDtFim%
			AND D3_COD = %Exp:(_cAlias)->CODMOD%
			AND D3_ESTORNO = ' '
			AND SD3.%NotDel%

		EndSql

		While (_cAliasIt)->(!EOF())

			SD3->(DbGoTo((_cAliasIt)->REC))
			If SD3->(!EOF())
				_nTotMod	:=	SD3->D3_QUANT/(_cAlias)->TOTMOD * (_cAlias)->QTDAJUS 
				Reclock("SD3",.F.)
				SD3->D3_QUANT	:=	_nTotMod
				SD3->D3_QTSEGUM	:=	_nTotMod
				SD3->(MsUnlock())
			EndIf
			(_cAliasIt)->(DbSkip())

		EndDo

		(_cAliasIt)->(DbCloseArea())

		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

Return

Static Function fRecModEsm()

	Local _cAlias	:=	GetNextAlias()
	Local _cAliasIt		
	Local _cDtIni	:=	DtoS(kjDtINI)
	Local _cDtFim	:=	DtoS(kjDtFIM)
	Local _nTotMod

	BeginSql Alias _cAlias
		%NoParser%

		WITH AJUSTE
		AS (
		SELECT CASE 
		WHEN D3_LOCAL = '01'
		THEN 'MOD161102'
		WHEN D3_LOCAL = '20'
		AND SUBSTRING(D3_CLVL, 1, 2) = '32'
		THEN 'MOD261102'
		WHEN D3_LOCAL = '20'
		AND SUBSTRING(D3_CLVL, 1, 2) = '37'
		THEN 'MOD761102'
	END CODMOD
	,ABS(SUM(CASE 
	WHEN D3_TM >= '500'
	THEN D3_QUANT * (- 1)
	ELSE D3_QUANT
	END)) QTDAJUS
	FROM %TABLE:SD3% SD3(NOLOCK)
	JOIN SB1010 SB1	ON SD3.D3_COD = SB1.B1_COD
	AND B1_GRUPO <> '102I'
	AND SB1.%NotDel%
	WHERE D3_EMISSAO BETWEEN %Exp:_cDtIni%
	AND %Exp:_cDtFim%
	AND D3_OP = ''
	AND D3_ESTORNO = ' '
	AND D3_COD LIKE '102%'
	AND D3_TM IN (
	'005'
	,'502'
	,'120'
	,'720'
	,'211'
	)
	AND SD3.%NotDel%
	GROUP BY D3_LOCAL, SUBSTRING(D3_CLVL, 1, 2)
	)
	,MODS
	AS (
	SELECT D3_COD
	,ABS(SUM(CASE 
	WHEN D3_TM >= '500'
	THEN D3_QUANT * (- 1)
	ELSE D3_QUANT
	END)) TOTMOD
	FROM %TABLE:SD3% SD3(NOLOCK)
	WHERE D3_EMISSAO BETWEEN %Exp:_cDtIni%
	AND %Exp:_cDtFim%
	AND D3_COD IN (
	'MOD161102'
	,'MOD261102'
	,'MOD761102'
	)
	AND D3_ESTORNO = ' '
	AND SD3.%NotDel%
	GROUP BY D3_COD
	)
	SELECT CODMOD, QTDAJUS, TOTMOD
	FROM AJUSTE A
	JOIN MODS B ON A.CODMOD = B.D3_COD

	EndSql

	While (_cAlias)->(!EOF())

		_cAliasIt	:=	GetNextAlias()		

		BeginSql Alias _cAliasIt

			SELECT R_E_C_N_O_ REC
			FROM %TABLE:SD3% SD3(NOLOCK)
			WHERE D3_EMISSAO BETWEEN %Exp:_cDtIni%
			AND %Exp:_cDtFim%
			AND D3_COD = %Exp:(_cAlias)->CODMOD%
			AND D3_ESTORNO = ' '
			AND SD3.%NotDel%

		EndSql

		While (_cAliasIt)->(!EOF())

			SD3->(DbGoTo((_cAliasIt)->REC))
			If SD3->(!EOF())
				_nTotMod	:=	SD3->D3_QUANT/(_cAlias)->TOTMOD * (_cAlias)->QTDAJUS 
				Reclock("SD3",.F.)
				SD3->D3_QUANT	:=	_nTotMod
				SD3->D3_QTSEGUM	:=	ConvUm(SD3->D3_COD, _nTotMod, 0, 2)
				SD3->(MsUnlock())
			EndIf
			(_cAliasIt)->(DbSkip())

		EndDo

		(_cAliasIt)->(DbCloseArea())

		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

Return

Static Function fRecModTin()

	Local _cAlias	:=	GetNextAlias()
	Local _cAliasIt		
	Local _cDtIni	:=	DtoS(kjDtINI)
	Local _cDtFim	:=	DtoS(kjDtFIM)
	Local _nTotMod

	BeginSql Alias _cAlias
		%NoParser%

		WITH AJUSTE
		AS (
		SELECT CODMOD, 
		ABS(SUM(QTDAJUS)) QTDAJUS
		FROM
		(
		SELECT CASE
		WHEN SUBSTRING(D3_CLVL, 1, 2) = '31'
		THEN 'MOD161102010'
		WHEN SUBSTRING(D3_CLVL, 1, 2) = '32'
		THEN 'MOD261102010'
		WHEN SUBSTRING(D3_CLVL, 1, 2) = '37'
		THEN 'MOD761102010'
	END CODMOD, 
	SUM(CASE
	WHEN D3_TM >= '500'
	THEN D3_QUANT * (-1)
	ELSE D3_QUANT
	END) QTDAJUS
	FROM %TABLE:SD3% SD3(NOLOCK)
	WHERE D3_EMISSAO BETWEEN %Exp:_cDtIni% AND %Exp:_cDtFim%
	AND D3_OP = ''
	AND D3_COD LIKE '102%'
	AND D3_TM IN('005', '502', '120', '720', '211')
	AND D3_LOCAL = '99'
	AND D3_GRUPO = '102I'
	AND D3_ESTORNO = ' '
	AND SD3.%NotDel%
	GROUP BY SUBSTRING(D3_CLVL, 1, 2)
	) AS TABLX
	GROUP BY CODMOD
	)
	,MODS
	AS (
	SELECT D3_COD
	,ABS(SUM(CASE 
	WHEN D3_TM >= '500'
	THEN D3_QUANT * (- 1)
	ELSE D3_QUANT
	END)) TOTMOD
	FROM %TABLE:SD3% SD3(NOLOCK)
	WHERE D3_EMISSAO BETWEEN %Exp:_cDtIni% AND %Exp:_cDtFim%
	AND D3_COD IN (
	'MOD161102010'
	,'MOD261102010'
	,'MOD761102010'
	)
	AND D3_ESTORNO = ' '
	AND SD3.%NotDel%
	GROUP BY D3_COD
	)
	SELECT CODMOD, QTDAJUS, TOTMOD
	FROM AJUSTE A
	JOIN MODS B ON A.CODMOD = B.D3_COD

	EndSql

	While (_cAlias)->(!EOF())

		_cAliasIt	:=	GetNextAlias()		

		BeginSql Alias _cAliasIt

			SELECT R_E_C_N_O_ REC
			FROM %TABLE:SD3% SD3(NOLOCK)
			WHERE D3_EMISSAO BETWEEN %Exp:_cDtIni%
			AND %Exp:_cDtFim%
			AND D3_COD = %Exp:(_cAlias)->CODMOD%
			AND D3_ESTORNO = ' '
			AND SD3.%NotDel%

		EndSql

		While (_cAliasIt)->(!EOF())

			SD3->(DbGoTo((_cAliasIt)->REC))
			If SD3->(!EOF())
				_nTotMod	:=	SD3->D3_QUANT / (_cAlias)->TOTMOD * (_cAlias)->QTDAJUS 
				Reclock("SD3",.F.)
				SD3->D3_QUANT	:=	_nTotMod
				SD3->D3_QTSEGUM	:=	ConvUm(SD3->D3_COD, _nTotMod, 0, 2)
				SD3->(MsUnlock())
			EndIf
			(_cAliasIt)->(DbSkip())

		EndDo

		(_cAliasIt)->(DbCloseArea())

		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

Return

Static Function fRecModDef()

	Local _cAlias	:=	GetNextAlias()
	Local _cAliasIt		
	Local _cDtIni	:=	DtoS(kjDtINI)
	Local _cDtFim	:=	DtoS(kjDtFIM)
	Local _nTotMod

	BeginSql Alias _cAlias

		%NoParser%

		WITH AJUSTE
		AS (
		SELECT CASE 
		WHEN SUBSTRING(D3_CLVL, 1, 2) = '31'
		THEN 'MOD161101004'
		WHEN SUBSTRING(D3_CLVL, 1, 2) = '32'
		THEN 'MOD261101004'
		WHEN SUBSTRING(D3_CLVL, 1, 2) = '37'
		THEN 'MOD761101004'
	END CODMOD
	,ABS(SUM(CASE 
	WHEN D3_TM >= '500'
	THEN D3_QUANT * (- 1)
	ELSE D3_QUANT
	END)) QTDAJUS
	FROM %TABLE:SD3% SD3(NOLOCK)
	WHERE D3_EMISSAO BETWEEN %Exp:_cDtIni%
	AND %Exp:_cDtFim%
	AND D3_OP = ''
	AND D3_CONTA = '61101004'
	AND D3_ESTORNO = ' '
	AND D3_CF NOT IN('DE4','RE4','DE3','RE3','DE7','RE7')
	AND SD3.%NotDel%
	GROUP BY SUBSTRING(D3_CLVL,1,2)
	)
	,MODS
	AS (
	SELECT D3_COD
	,ABS(SUM(CASE 
	WHEN D3_TM >= '500'
	THEN D3_QUANT * (- 1)
	ELSE D3_QUANT
	END)) TOTMOD
	FROM %TABLE:SD3% SD3(NOLOCK)
	WHERE D3_EMISSAO BETWEEN %Exp:_cDtIni%
	AND %Exp:_cDtFim%
	AND D3_COD IN (
	'MOD161101004'
	,'MOD261101004'
	,'MOD761101004'
	)
	AND D3_ESTORNO = ' '
	AND SD3.%NotDel%
	GROUP BY D3_COD
	)
	SELECT CODMOD, QTDAJUS, TOTMOD
	FROM AJUSTE A
	JOIN MODS B ON A.CODMOD = B.D3_COD

	EndSql

	While (_cAlias)->(!EOF())

		_cAliasIt	:=	GetNextAlias()		

		BeginSql Alias _cAliasIt

			SELECT R_E_C_N_O_ REC
			FROM %TABLE:SD3% SD3(NOLOCK)
			WHERE D3_EMISSAO BETWEEN %Exp:_cDtIni%
			AND %Exp:_cDtFim%
			AND D3_COD = %Exp:(_cAlias)->CODMOD%
			AND D3_ESTORNO = ' '
			AND SD3.%NotDel%

		EndSql

		While (_cAliasIt)->(!EOF())

			SD3->(DbGoTo((_cAliasIt)->REC))
			If SD3->(!EOF())
				_nTotMod	:=	SD3->D3_QUANT/(_cAlias)->TOTMOD * (_cAlias)->QTDAJUS 
				Reclock("SD3",.F.)
				SD3->D3_QUANT	:=	_nTotMod
				SD3->D3_QTSEGUM	:=	_nTotMod
				SD3->(MsUnlock())
			EndIf
			(_cAliasIt)->(DbSkip())

		EndDo

		(_cAliasIt)->(DbCloseArea())

		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

Return

Static Function fCOutros()

	Local _aMods	:= {}
	Local _nI

	aAdd(_aMods,{;
	"MOD161107",;
	"MOD261107",;
	"MOD761107",;
	"61107002";
	})

	aAdd(_aMods,{;
	"MOD161110003",;
	"MOD261110003",;
	"MOD761110003",;
	"61110003";
	})

	For _nI	:=	1 to Len(_aMods)

		fRecModGen(_aMods[_nI])

	Next _nI

Return

Static Function fRecModGen(_aMods)

	Local _cAlias	:=	GetNextAlias()
	Local _cAliasIt		
	Local _cDtIni	:=	DtoS(kjDtINI)
	Local _cDtFim	:=	DtoS(kjDtFIM)
	Local _nTotMod
	Local _cModFab1	:=	_aMods[1]
	Local _cModFab2	:=	_aMods[2]
	Local _cModFab7	:=	_aMods[3]
	Local _cConta	:=	_aMods[4]

	BeginSql Alias _cAlias
		%NoParser%
		WITH AJUSTE
		AS (
		SELECT CASE 
		WHEN D3_LOCAL = '01'
		AND SUBSTRING(D3_CLVL, 1, 2) = '31'
		THEN %Exp:_cModFab1%
		WHEN D3_LOCAL = '20'
		AND SUBSTRING(D3_CLVL, 1, 2) = '32'
		THEN %Exp:_cModFab2%
		WHEN D3_LOCAL = '20'
		AND SUBSTRING(D3_CLVL, 1, 2) = '37'
		THEN %Exp:_cModFab7%
	END CODMOD
	,ABS(SUM(CASE 
	WHEN D3_TM >= '500'
	THEN D3_QUANT * (- 1)
	ELSE D3_QUANT
	END)) QTDAJUS
	FROM %TABLE:SD3% SD3(NOLOCK)
	WHERE D3_EMISSAO BETWEEN %Exp:_cDtIni%
	AND %Exp:_cDtFim%
	AND D3_OP = ''
	AND D3_CONTA = %Exp:_cConta%
	AND D3_ESTORNO = ' '
	AND SD3.%NotDel%
	GROUP BY D3_LOCAL, SUBSTRING(D3_CLVL, 1, 2)
	)
	,MODS
	AS (
	SELECT D3_COD
	,ABS(SUM(CASE 
	WHEN D3_TM >= '500'
	THEN D3_QUANT * (- 1)
	ELSE D3_QUANT
	END)) TOTMOD
	FROM %TABLE:SD3% SD3(NOLOCK)
	WHERE D3_EMISSAO BETWEEN %Exp:_cDtIni%
	AND %Exp:_cDtFim%
	AND D3_COD IN (
	%Exp:_cModFab1%
	,%Exp:_cModFab2%
	,%Exp:_cModFab7%
	)
	AND D3_ESTORNO = ' '
	AND SD3.%NotDel%
	GROUP BY D3_COD
	)
	SELECT CODMOD, QTDAJUS, TOTMOD
	FROM AJUSTE A
	JOIN MODS B ON A.CODMOD = B.D3_COD

	EndSql

	While (_cAlias)->(!EOF())

		_cAliasIt	:=	GetNextAlias()		

		BeginSql Alias _cAliasIt

			SELECT R_E_C_N_O_ REC
			FROM %TABLE:SD3% SD3(NOLOCK)
			WHERE D3_EMISSAO BETWEEN %Exp:_cDtIni%
			AND %Exp:_cDtFim%
			AND D3_COD = %Exp:(_cAlias)->CODMOD%
			AND D3_ESTORNO = ' '
			AND SD3.%NotDel%

		EndSql

		While (_cAliasIt)->(!EOF())

			SD3->(DbGoTo((_cAliasIt)->REC))
			If SD3->(!EOF())
				_nTotMod	:=	SD3->D3_QUANT/(_cAlias)->TOTMOD * (_cAlias)->QTDAJUS 
				Reclock("SD3",.F.)
				SD3->D3_QUANT	:=	_nTotMod
				SD3->D3_QTSEGUM	:=	_nTotMod
				SD3->(MsUnlock())
			EndIf
			(_cAliasIt)->(DbSkip())
		EndDo
		(_cAliasIt)->(DbCloseArea())

		(_cAlias)->(DbSkip())
	EndDo

	(_cAlias)->(DbCloseArea())

Return

Static Function fncRvAtu(xCodProd)

	Local msRevAtu := Space(03)
	//Local _cDtIni	:=	DtoS(kjDtINI)
	Local _cDtFim	:=	DtoS(kjDtFIM)

	msAlias := GetNextAlias()		

	BeginSql Alias msAlias

		SELECT MIN(G1_TRT) TRT
		FROM %TABLE:SG1% SG1(NOLOCK)
		WHERE G1_FILIAL = %Exp:xFilial("SG1")%
		AND G1_COD = %Exp:xCodProd%
		AND %Exp:_cDtFim% BETWEEN G1_INI AND G1_FIM
		AND SG1.%NotDel%

	EndSql

	If (msAlias)->(!EOF())

		msRevAtu := (msAlias)->TRT

	EndIf

	(msAlias)->(DbCloseArea())

Return ( msRevAtu )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ xBia776E  ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 17.05.17 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Explode Estrutura de Produto para obter a quantidade       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xBia788E(nQuant, deDataStru, atDataStru)

	LOCAL nQuantItem:=0, cUnidMod, nG1Quant:=0, nQBase:=0, nDecimal:=0, nBack:=0
	LOCAL aTamSX3:={}
	LOCAL lOk:=.T.
	LOCAL nDecOrig:=Set(3,8)

	aTamSX3:=TamSX3("G1_QUANT")
	nDecimal:=aTamSX3[2]

	// Verifica a data de validade
	deDataStru := If((deDataStru == NIL), dDataBase, deDataStru)
	atDataStru := If((atDataStru == NIL), dDataBase, atDataStru)

	If deDataStru >= SG1->G1_INI .and. atDataStru <= SG1->G1_FIM .And. lOk

		cUnidMod := GetMv("MV_UNIDMOD")
		dbSelectArea("SB1")
		dbSeek(xFilial()+SG1->G1_COD)
		nQBase := B1_QB
		dbSeek(xFilial()+SG1->G1_COMP)
		dbSelectArea("SG1")
		nG1Quant := G1_QUANT
		If IsProdMod(G1_COMP)
			cTpHr := GetMv("MV_TPHR")
			If cTpHr == "N"
				nG1Quant := Int(nG1Quant)
				nG1Quant += ((G1_QUANT-nG1Quant)/60)*100
			EndIf
		EndIf
		If G1_FIXVAR $ " V"
			If IsProdMod(G1_COMP) .And. cUnidMOD != "H"
				nQuantItem := ((nQuant / nG1Quant) / (100 - G1_PERDA)) * 100
			Else
				nQuantItem := ((nQuant * nG1Quant) / (100 - G1_PERDA)) * 100
			EndIf
			nQuantItem := nQuantItem / Iif(nQBase <= 0,1,nQBase)
		Else
			If IsProdMod(G1_COMP) .And. cUnidMOD != "H"
				nQuantItem := (nG1Quant / (100 - G1_PERDA)) * 100
			Else
				nQuantItem := (nG1Quant / (100 - G1_PERDA)) * 100
			EndIf
		Endif
		nQuantItem:=Round(nQuantitem,nDecimal)
	EndIf

	Do Case
		Case (SB1->B1_TIPODEC == "A")
		nBack := Round( nQuantItem,0 )
		Case (SB1->B1_TIPODEC == "I")
		nBack := Int(nQuantItem)+If(((nQuantItem-Int(nQuantItem)) > 0),1,0)
		Case (SB1->B1_TIPODEC == "T")
		nBack := Int( nQuantItem )
		OtherWise
		nBack := nQuantItem
	EndCase

	Set(3,nDecOrig)

Return( nBack )
