#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} BIA380
@author Marcos Alberto Soprani
@since 09/07/13
@version 1.0
@description Orçamento de RH
@type function
/*/

/*/{Protheus.doc} BIA380
@author Marcos Alberto Soprani
@since 11/09/17
@version 2.0
@description Orçamento de RH
@type function
/*/

User Function BIA380()

	fPerg := "BIA380FIL"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidFilPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	n := 1
	cCadastro := " ....: Orçamento RH :.... "

	aRotina   := {  {"Pesquisar"    ,'AxPesqui'                             ,0, 1},;
	{                "Visualizar"   ,'AxVisual'                             ,0, 2},;
	{                "Processar"    ,'Execblock("BIA380A" ,.F.,.F.)'        ,0, 3},;
	{                "Imprimir"     ,'Execblock("BIA380I" ,.F.,.F.)'        ,0, 4},;
	{                "Replica CLVL" ,'Execblock("BIA380R" ,.F.,.F.)'        ,0, 5},;
	{                "Delta SAP"    ,'Execblock("BIA380D" ,.F.,.F.)'        ,0, 6} }

	dbSelectArea("Z45")
	dbSetOrder(1)
	dbGoTop()

	Set filter to Z45->Z45_ANOREF == MV_PAR01

	Z45->(mBrowse(06,01,22,75,"Z45"))

	dbSelectArea("Z45")
	dbClearFilter()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA380A  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 23/08/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Montagem da Tela de Visualização, Inclusao e Alteração     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA380A()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()
	
	Local xt

	fPerg := "BIA380"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	dbSelectArea("Z45")

	//
	//
	//
	//
	//
	// aqui incluir o prepare environment para loop de empresas....
	//
	//
	//
	//

	//***************************************************************
	//**     Variáveis Diversas seguindo o padrão da Planilha      **
	//***************************************************************
	bfHorasMes := 220
	bfHExtr50  := 1.5
	bfHExtr100 := 2.0
	//***************************************************************

	YR004 := " SELECT DATEDIFF(MONTH, '"+GravaData(Stod(MV_PAR01+"01"), .F., 8)+"', '"+GravaData(Stod(MV_PAR02+"01"), .F., 8)+"') + 1 MESES
	TcQuery YR004 New Alias "YR04"
	dbSelectArea("YR04")
	dbGoTop()
	yrQtdMes := YR04->MESES
	YR04->(dbCloseArea())

	akVetOrcRH := {}

	ProcRegua(10000)
	IncProc("Preparando dados...")

	HY004 += Alltrim(" SELECT RA_TNOTRAB,                                                                                                                                        ")+HyEnter
	HY004 += Alltrim("        R6_DESC,                                                                                                                                           ")+HyEnter
	HY004 += Alltrim("        RA_CLVL,                                                                                                                                           ")+HyEnter
	HY004 += Alltrim("        RA_CATFUNC,                                                                                                                                        ")+HyEnter
	HY004 += Alltrim("        RA_CATEG,                                                                                                                                          ")+HyEnter
	HY004 += Alltrim("        RA_SEXO,                                                                                                                                           ")+HyEnter
	HY004 += Alltrim("        RA_MAT,                                                                                                                                            ")+HyEnter
	HY004 += Alltrim("        RA_NOME,                                                                                                                                           ")+HyEnter
	HY004 += Alltrim("        RA_CC,                                                                                                                                             ")+HyEnter
	HY004 += Alltrim("        RA_ADMISSA,                                                                                                                                        ")+HyEnter
	HY004 += Alltrim("        RA_CODFUNC,                                                                                                                                        ")+HyEnter
	HY004 += Alltrim("        RJ_DESC,                                                                                                                                           ")+HyEnter
	HY004 += Alltrim("        RA_SALARIO,                                                                                                                                        ")+HyEnter
	HY004 += Alltrim("        CASE                                                                                                                                               ")+HyEnter
	HY004 += Alltrim("          WHEN RA_PERICUL <> 0 THEN 0.3                                                                                                                    ")+HyEnter
	HY004 += Alltrim("          ELSE 0                                                                                                                                           ")+HyEnter
	HY004 += Alltrim("        END * RA_SALARIO PERICUL,                                                                                                                          ")+HyEnter
	HY004 += Alltrim("        CASE                                                                                                                                               ")+HyEnter
	HY004 += Alltrim("          WHEN RA_INSMAX <> 0 THEN 0.4                                                                                                                     ")+HyEnter
	HY004 += Alltrim("          WHEN RA_INSMED <> 0 THEN 0.2                                                                                                                     ")+HyEnter
	HY004 += Alltrim("          WHEN RA_INSMIN <> 0 THEN 0.1                                                                                                                     ")+HyEnter
	HY004 += Alltrim("          ELSE 0                                                                                                                                           ")+HyEnter
	HY004 += Alltrim("        END * '" + Alltrim(Str(MV_PAR03)) + "' INSALUB,                                                                                                    ")+HyEnter
	HY004 += Alltrim("        CASE                                                                                                                                               ")+HyEnter
	HY004 += Alltrim("          WHEN RA_TNOTRAB = '047' THEN 6                                                                                                                   ")+HyEnter
	HY004 += Alltrim("          ELSE 0                                                                                                                                           ")+HyEnter
	HY004 += Alltrim("        END HREXTPROG,                                                                                                                                     ")+HyEnter
	HY004 += Alltrim("        ISNULL((SELECT SUM(RD_VALOR)                                                                                                                       ")+HyEnter
	HY004 += Alltrim("                  FROM " + RetSqlName("SRD") + "                                                                                                           ")+HyEnter
	HY004 += Alltrim("                 WHERE RD_DATARQ BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'                                                                                 ")+HyEnter
	HY004 += Alltrim("                   AND RD_MAT = RA_MAT                                                                                                                     ")+HyEnter
	HY004 += Alltrim("                   AND RD_PD IN('115','307')                                                                                                               ")+HyEnter
	HY004 += Alltrim("                   AND D_E_L_E_T_ = ' '), 0)/"+Alltrim(Str(yrQtdMes))+" VLADNOTR,                                                                          ")+HyEnter
	HY004 += Alltrim("        CASE                                                                                                                                               ")+HyEnter
	HY004 += Alltrim("          WHEN RA_CLVL IN('2115','2116','2215','2216') THEN (ISNULL((SELECT SUM(RD_VALOR)                                                                  ")+HyEnter
	HY004 += Alltrim("                                                                       FROM " + RetSqlName("SRD") + "                                                      ")+HyEnter
	HY004 += Alltrim("                                                                      WHERE RD_DATARQ BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'                            ")+HyEnter
	HY004 += Alltrim("                                                                        AND RD_MAT = RA_MAT                                                                ")+HyEnter
	HY004 += Alltrim("                                                                        AND RD_PD IN('847','310')                                                          ")+HyEnter
	HY004 += Alltrim("                                                                        AND D_E_L_E_T_ = ' '), 0)/"+Alltrim(Str(yrQtdMes))+")                              ")+HyEnter
	HY004 += Alltrim("          ELSE 0                                                                                                                                           ")+HyEnter
	HY004 += Alltrim("        END VLTRANSP,                                                                                                                                      ")+HyEnter
	HY004 += Alltrim("        CASE                                                                                                                                               ")+HyEnter
	HY004 += Alltrim("          WHEN RA_CLVL IN('2115','2116','2215','2216') THEN 0                                                                                              ")+HyEnter
	HY004 += Alltrim("          WHEN RA_TNOTRAB IN('047','048') THEN 16                                                                                                          ")+HyEnter
	HY004 += Alltrim("          ELSE 22                                                                                                                                          ")+HyEnter
	HY004 += Alltrim("        END QVALETRAN,                                                                                                                                     ")+HyEnter
	HY004 += Alltrim("        ISNULL((SELECT COUNT(*)                                                                                                                            ")+HyEnter
	HY004 += Alltrim("                  FROM " + RetSqlName("SR0") + "                                                                                                           ")+HyEnter
	HY004 += Alltrim("                 WHERE R0_MAT = RA_MAT                                                                                                                     ")+HyEnter
	HY004 += Alltrim("                   AND R0_CODIGO IN('01','03')                                                                                                             ")+HyEnter
	HY004 += Alltrim("                   AND D_E_L_E_T_ = ' '), 0) VTRANSFOL,                                                                                                    ")+HyEnter
	HY004 += Alltrim("        CASE                                                                                                                                               ")+HyEnter
	HY004 += Alltrim("          WHEN RA_TNOTRAB = '047' THEN 8                                                                                                                   ")+HyEnter
	HY004 += Alltrim("          WHEN RA_TNOTRAB = '048' THEN 16                                                                                                                  ")+HyEnter
	HY004 += Alltrim("          WHEN RA_CLVL IN('2115','2116','2215','2216') AND RA_MAT <> '001137' THEN 0                                                                       ")+HyEnter
	HY004 += Alltrim("          ELSE 22                                                                                                                                          ")+HyEnter
	HY004 += Alltrim("        END QTREFEIC,                                                                                                                                      ")+HyEnter
	HY004 += Alltrim("        RA_YVALCOM VALCOM,                                                                                                                                 ")+HyEnter
	HY004 += Alltrim("        ISNULL((SELECT COUNT(*) + 1                                                                                                                        ")+HyEnter
	HY004 += Alltrim("                  FROM " + RetSqlName("RHL") + "                                                                                                           ")+HyEnter
	HY004 += Alltrim("                 WHERE RHL_MAT = RA_MAT                                                                                                                    ")+HyEnter
	HY004 += Alltrim("                   AND RHL_TPFORN = '1'                                                                                                                    ")+HyEnter
	HY004 += Alltrim("       		     AND RHL_PERFIM = '      '                                                                                                               ")+HyEnter
	HY004 += Alltrim("                   AND D_E_L_E_T_ = ' '), 0) QTPLS,                                                                                                        ")+HyEnter
	HY004 += Alltrim("        ISNULL((SELECT TOP 1 RHK_PLANO                                                                                                                     ")+HyEnter
	HY004 += Alltrim("                  FROM " + RetSqlName("RHK") + "                                                                                                           ")+HyEnter
	HY004 += Alltrim("                 WHERE RHK_MAT = RA_MAT                                                                                                                    ")+HyEnter
	HY004 += Alltrim("                   AND RHK_TPFORN = '1'                                                                                                                    ")+HyEnter
	HY004 += Alltrim("       		     AND RHK_PERFIM = '      '                                                                                                               ")+HyEnter
	HY004 += Alltrim("                   AND D_E_L_E_T_ = ' '), 0) TIPOPLS,                                                                                                      ")+HyEnter
	HY004 += Alltrim("        ISNULL((SELECT COUNT(*)                                                                                                                            ")+HyEnter
	HY004 += Alltrim("                  FROM " + RetSqlName("RHK") + "                                                                                                           ")+HyEnter
	HY004 += Alltrim("                 WHERE RHK_MAT = RA_MAT                                                                                                                    ")+HyEnter
	HY004 += Alltrim("                   AND RHK_TPFORN = '2'                                                                                                                    ")+HyEnter
	HY004 += Alltrim("       		     AND RHK_PERFIM = '      '                                                                                                               ")+HyEnter
	HY004 += Alltrim("                   AND D_E_L_E_T_ = ' '), 0) QTODOTT,                                                                                                      ")+HyEnter
	HY004 += Alltrim("        ISNULL((SELECT TOP 1 RHK_PLANO                                                                                                                     ")+HyEnter
	HY004 += Alltrim("                  FROM " + RetSqlName("RHK") + "                                                                                                           ")+HyEnter
	HY004 += Alltrim("                 WHERE RHK_MAT = RA_MAT                                                                                                                    ")+HyEnter
	HY004 += Alltrim("                   AND RHK_TPFORN = '2'                                                                                                                    ")+HyEnter
	HY004 += Alltrim("       		     AND RHK_PERFIM = '      '                                                                                                               ")+HyEnter
	HY004 += Alltrim("                   AND D_E_L_E_T_ = ' '), 0) TIPOODN,                                                                                                      ")+HyEnter
	HY004 += Alltrim("        CASE                                                                                                                                               ")+HyEnter
	HY004 += Alltrim("          WHEN RA_CLVL IN('2115','2215','2116','2216') THEN 295                                                                                            ")+HyEnter
	HY004 += Alltrim("          ELSE 0                                                                                                                                           ")+HyEnter
	HY004 += Alltrim("        END VLGRATIF,                                                                                                                                      ")+HyEnter
	HY004 += Alltrim("        CASE                                                                                                                                               ")+HyEnter
	HY004 += Alltrim("          WHEN RA_CATFUNC = 'E' THEN " + Alltrim(Str(MV_PAR04)) + "                                                                                        ")+HyEnter
	HY004 += Alltrim("          WHEN RA_CATFUNC = 'M' AND RA_CATEG = '07' THEN " + Alltrim(Str(MV_PAR05)) + "                                                                    ")+HyEnter
	HY004 += Alltrim("          ELSE 0                                                                                                                                           ")+HyEnter
	HY004 += Alltrim("        END COEPCIEE,                                                                                                                                      ")+HyEnter
	HY004 += Alltrim("        RA_YPCD PCD                                                                                                                                        ")+HyEnter
	HY004 += Alltrim("    FROM " + RetSqlName("SRA") + " SRA                                                                                                                     ")+HyEnter
	HY004 += Alltrim("    LEFT JOIN " + RetSqlName("SR6") + " SR6 ON R6_TURNO = RA_TNOTRAB                                                                                       ")+HyEnter
	HY004 += Alltrim("                        AND SR6.D_E_L_E_T_ = ' '                                                                                                           ")+HyEnter
	HY004 += Alltrim("    LEFT JOIN " + RetSqlName("SRJ") + " SRJ ON RJ_FUNCAO = RA_CODFUNC                                                                                      ")+HyEnter
	HY004 += Alltrim("                        AND SRJ.D_E_L_E_T_ = ' '                                                                                                           ")+HyEnter
	HY004 += Alltrim("   WHERE ( RA_DEMISSA = '        ' OR  RA_DEMISSA > '"+dtos(MV_PAR21)+"' )                                                                                 ")+HyEnter
	HY004 += Alltrim("     AND RA_MAT <= '199999'                                                                                                                                ")+HyEnter
	HY004 += Alltrim("     AND RA_ADMISSA <= '"+dtos(MV_PAR21)+"'                                                                                                                ")+HyEnter
	HY004 += Alltrim("     AND SRA.D_E_L_E_T_ = ' '                                                                                                                              ")+HyEnter
	HYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,HY004),'HY04',.F.,.T.)
	dbSelectArea("HY04")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		//                                                                        Salário / Bolsa_Estágio
		//***********************************************************************************************
		bdSalarioRef := HY04->RA_SALARIO
		bdBolsaEsRef := 0
		If bdSalarioRef < MV_PAR03
			bdSalarioRef := MV_PAR03
			If HY04->RA_CATFUNC = 'M' .and. HY04->RA_CATEG = '07'
				bdSalarioRef := bdSalarioRef / 2
			EndIf
		EndIf
		If HY04->RA_CATFUNC = 'E'
			bdSalarioRef := 0
			bdBolsaEsRef := HY04->RA_SALARIO
		EndIf

		//                                                                               Rendimento_Total
		//***********************************************************************************************
		bfRendimentos := bdSalarioRef + bdBolsaEsRef + HY04->PERICUL + HY04->INSALUB

		//      HrExtraProg / HE50 / HE 100 / Adc_Noturno / DSR_Eventual / DSR_Programado / Gratificações
		//***********************************************************************************************
		bfVlrHrExtPrg := (bfRendimentos / bfHorasMes) * bfHExtr100 * HY04->HREXTPROG
		bfVlrHE50     := (bfRendimentos / bfHorasMes) * bfHExtr50 * HY04->QTHE50
		bfVlrHE100    := (bfRendimentos / bfHorasMes) * bfHExtr100 * HY04->QTHE100

		bfVlrAdcNotur := HY04->VLADNOTR
		bfVDSRev      := (bfVlrHE50 + bfVlrHE100) / 25 * 5
		bfVDSRpr      := (bfVlrHrExtPrg) / 25 * 5
		bfVlrGratific := HY04->VLGRATIF

		//                                                             Extras_Mensais / Remuneração_Total
		//***********************************************************************************************
		bfRemunerTot  := bfRendimentos + bfVlrHrExtPrg + bfVlrHE50 + bfVlrHE100 + bfVlrAdcNotur + bfVDSRev + bfVDSRpr + bfVlrGratific

		//                         >>> TABELA 10 <<<                                    Exames Periódicos
		//***********************************************************************************************
		bfExamPeriod  := 0
		If !HY04->RA_CATFUNC == "P"

			If     Alltrim(HY04->RA_CLVL) $ "2115/2215"
				bfExamPeriod  := 0
			ElseIf Alltrim(HY04->RA_CLVL) $ "2100"
				bfExamPeriod  :=  14
			ElseIf Alltrim(HY04->RA_CLVL) $ "2200"
				bfExamPeriod  :=  17.18
			ElseIf Alltrim(HY04->RA_CLVL) $ "5000"
				bfExamPeriod  :=  19.68
			ElseIf Alltrim(HY04->RA_CLVL) $ "5003"
				bfExamPeriod  :=  20.75
			ElseIf Alltrim(HY04->RA_CLVL) $ "4050"
				bfExamPeriod  :=  28.50
			ElseIf Alltrim(HY04->RA_CLVL) $ "1000/4000/4003/4008/1055"
				bfExamPeriod  :=  35.06
			ElseIf Alltrim(HY04->RA_CLVL) $ "2111"
				bfExamPeriod  :=  41.00
			ElseIf Alltrim(HY04->RA_CLVL) $ "1003"
				bfExamPeriod  :=  51.17
			ElseIf Alltrim(HY04->RA_CLVL) $ "3136"
				bfExamPeriod  :=  55.18
			ElseIf Alltrim(HY04->RA_CLVL) $ "3113/3213/3133"
				bfExamPeriod  :=  56.00
			ElseIf Alltrim(HY04->RA_CLVL) $ "3135"
				bfExamPeriod  :=  58.29
			ElseIf Alltrim(HY04->RA_CLVL) $ "3117"
				bfExamPeriod  :=  59.20
			ElseIf Alltrim(HY04->RA_CLVL) $ "3100"
				bfExamPeriod  :=  66.13
			ElseIf Alltrim(HY04->RA_CLVL) $ "2220"
				bfExamPeriod  :=  66.67
			ElseIf Alltrim(HY04->RA_CLVL) $ "2120"
				bfExamPeriod  :=  67.96
			ElseIf Alltrim(HY04->RA_CLVL) $ "4080"
				bfExamPeriod  :=  68.00
			ElseIf Alltrim(HY04->RA_CLVL) $ "3130"
				bfExamPeriod  :=  85.45
			ElseIf Alltrim(HY04->RA_CLVL) $ "3207/3210/3107"
				bfExamPeriod  :=  88.00
			ElseIf Alltrim(HY04->RA_CLVL) $ "3215"
				bfExamPeriod  :=  90.50
			ElseIf Alltrim(HY04->RA_CLVL) $ "3110"
				bfExamPeriod  :=  91.22
			ElseIf Alltrim(HY04->RA_CLVL) $ "3102"
				bfExamPeriod  :=  91.33
			ElseIf Alltrim(HY04->RA_CLVL) $ "3138/3204/3186/3115/3131/3111/3211"
				bfExamPeriod  :=  95.00
			ElseIf Alltrim(HY04->RA_CLVL) $ "3500"
				bfExamPeriod  :=  95.75
			ElseIf Alltrim(HY04->RA_CLVL) $ "3104"
				bfExamPeriod  :=  96.18
			ElseIf Alltrim(HY04->RA_CLVL) $ "3216"
				bfExamPeriod  :=  101.77
			ElseIf Alltrim(HY04->RA_CLVL) $ "3202"
				bfExamPeriod  :=  104.73
			ElseIf Alltrim(HY04->RA_CLVL) $ "3200"
				bfExamPeriod  :=  106.00
			ElseIf Alltrim(HY04->RA_CLVL) $ "3105"
				bfExamPeriod  :=  107.75
			ElseIf Alltrim(HY04->RA_CLVL) $ "3139"
				bfExamPeriod  :=  109.58
			ElseIf Alltrim(HY04->RA_CLVL) $ "3116"
				bfExamPeriod  :=  110.17
			ElseIf Alltrim(HY04->RA_CLVL) $ "3137"
				bfExamPeriod  :=  111.50
			ElseIf Alltrim(HY04->RA_CLVL) $ "3290"
				bfExamPeriod  :=  113.55
			ElseIf Alltrim(HY04->RA_CLVL) $ "3190"
				bfExamPeriod  :=  114.25
			ElseIf Alltrim(HY04->RA_CLVL) $ "3103"
				bfExamPeriod  :=  117.39
			ElseIf Alltrim(HY04->RA_CLVL) $ "3193/3191/3196/3203/3195/3101"
				bfExamPeriod  :=  122.00
			Else
				MsgINFO("Favor verificar por a Classe de Valor: " + HY04->RA_CLVL + " não tem valor de Exame Periódico orçado...")
			EndIf

		EndIf

		bfExamPeriod := bfExamPeriod / 12

		//                         >>> tabela 06 / 07 <<<                    Refeição (almoço na Empresa)
		//***********************************************************************************************
		xfPartEmpr := 0.90
		If HY04->RA_CATFUNC == "P" .or. HY04->RA_CATFUNC = 'E'  //Prolabores e acionistas e Estagiários 
			xfPartEmpr := 1
		EndIf
		If Alltrim(HY04->RA_TNOTRAB) == "067"                 // Menores que trabalham depois do almoço
			xfPartEmpr := 0
		EndIf
		bfQtdeRefeic  := HY04->QTREFEIC
		bfValorRefei  := HY04->QTREFEIC * MV_PAR06 * xfPartEmpr
		If Alltrim(HY04->PCD) $ "2/3/4"   // Menores estudantes de SENAI e Promotores externos /PCD ext
			bfQtdeRefeic  := 0
			bfValorRefei  := 0
		EndIf
		If StrZero(HY04->EMPR, 2) = "06"
			bfQtdeRefeic  := 0
			bfValorRefei  := 0
		EndIf

		//                         >>> tabela 06 / 07 <<<                                        Desjejum
		//***********************************************************************************************
		If Alltrim(HY04->RA_TNOTRAB) $ "047/048"
			If StrZero(HY04->EMPR, 2) $ "01/05"
				bfValorRefei += HY04->QTREFEIC * MV_PAR28 
			ElseIf StrZero(HY04->EMPR, 2) $ "14"
				bfValorRefei += HY04->QTREFEIC * MV_PAR29
			EndIf			
		EndIf

		//                         >>> tabela 06 / 07 <<<                    Vale Refeição (Supermercado)
		//***********************************************************************************************
		bfValeAlimen  := 0
		If     StrZero(HY04->EMPR, 2) = "01"
			bfValeAlimen  := MV_PAR07
		ElseIf StrZero(HY04->EMPR, 2) = "05"
			bfValeAlimen  := MV_PAR07
		ElseIf StrZero(HY04->EMPR, 2) = "13"
			bfValeAlimen  := MV_PAR09
		ElseIf StrZero(HY04->EMPR, 2) = "14"
			bfValeAlimen  := MV_PAR13
		EndIf
		If HY04->PCD == "2"
			bfValeAlimen  := 0
		EndIf

		//                         >>> tabela 06 / 07 <<<                          Vale Refeição (Jantar)
		//***********************************************************************************************
		bfValeRefeic  := 0
		If StrZero(HY04->EMPR, 2) $ "01/05"
			If Alltrim(HY04->RA_TNOTRAB) $ "003,005,012,013,019,020,023,028,045,046,065,075,082,084,086,088,089,090,123"
				bfValeRefeic += MV_PAR08
			ElseIf Alltrim(HY04->RA_TNOTRAB) $ "047"
				bfValeRefeic += MV_PAR22
			EndIf
		ElseIf StrZero(HY04->EMPR, 2) = "13"
			bfValeRefeic  := 0
		ElseIf StrZero(HY04->EMPR, 2) = "14"
			If Alltrim(HY04->RA_TNOTRAB) $ "095"
				bfValeRefeic  := MV_PAR14
			EndIf
		EndIf

		//                         >>> tabela 06 / 07 <<<                                Vale Combustível
		//***********************************************************************************************
		bfValeCombus  := 0
		If HY04->VALCOM == "S"
			If !HY04->RA_MAT $ "001813"
				bfValeCombus  := MV_PAR11
			Else
				bfValeCombus  := MV_PAR30
			EndIf
		EndIf

		//                            >>> TABELA 08 <<<                                          Uniforme
		//***********************************************************************************************
		bfUniforme    := 0
		If HY04->RA_SEXO == "F"
			bfUniforme := 267.00 / 12
		Else
			If !Substr(HY04->RA_CLVL,1,1) $ "3"
				bfUniforme := 122.82 / 12
			Else
				If 1 == 2    // supervisor foi necessário fazer média
					bfUniforme := 195.44  // 163.94 / 12   // 132.43 / 12
				Else
					bfUniforme := 195.44  // 163.94 / 12   // 195.44 / 12
				EndIf
			EndIf
		EndIf
		// Promotor e Especificador
		If Alltrim(HY04->RA_CLVL) $ "2115/2116/2215/2216"
			bfUniforme := 500.00 / 12
		EndIf

		//              >>> TABELA 05 <<<        Faixa Salarial vs Enquadramento regressivo para desconto
		//***********************************************************************************************
		bfVMedPls := 1021.56
		bfVMaxPls := 1407.09
		bfVPrcMin := 80
		bfVPrcMed := 70
		bfVPrcMax := 60

		//              >>> TABELA 01 / 02 / 03 <<<                                        Plano de saúde
		//***********************************************************************************************
		bfQtPLS  := HY04->QTPLS
		bf1VlPLS := 0
		bf2VlPLS := 0

		bfxValPls := 0
		If HY04->RA_SALARIO < bfVMedPls
			bfxValPls := bfVPrcMin/100
		ElseIf HY04->RA_SALARIO >= bfVMedPls .and. HY04->RA_SALARIO < bfVMaxPls
			bfxValPls := bfVPrcMed/100
		ElseIf HY04->RA_SALARIO >= bfVMaxPls
			bfxValPls := bfVPrcMax/100
		EndIf

		If StrZero(HY04->EMPR, 2) == "01"
			If     Alltrim(HY04->TIPOPLS) == 'E4'
				bf1VlPLS  := 132.08 * bfxValPls * bfQtPLS
			ElseIf Alltrim(HY04->TIPOPLS) == 'E9'
				bf1VlPLS  := 173.71 * bfxValPls * bfQtPLS
			ElseIf Alltrim(HY04->TIPOPLS) == 'E5'
				bf1VlPLS  := 237.38 * bfxValPls * bfQtPLS
			ElseIf Alltrim(HY04->TIPOPLS) == 'E8'
				bf2VlPLS  := 127.24 * bfxValPls * bfQtPLS
			ElseIf Alltrim(HY04->TIPOPLS) == 'E6' // Promotoras
				bf2VlPLS  := xyzVPlnProm(StrZero(HY04->EMPR, 2), HY04->RA_MAT)
			EndIf

		ElseIf StrZero(HY04->EMPR, 2) == "05"
			If     Alltrim(HY04->TIPOPLS) == 'E4'
				bf1VlPLS  := 132.08 * bfxValPls * bfQtPLS
			ElseIf Alltrim(HY04->TIPOPLS) == 'E9'
				bf1VlPLS  := 173.71 * bfxValPls * bfQtPLS
			ElseIf Alltrim(HY04->TIPOPLS) == 'E5'
				bf1VlPLS  := 237.38 * bfxValPls * bfQtPLS
			ElseIf Alltrim(HY04->TIPOPLS) == 'E8'
				bf2VlPLS  := 127.24 * bfxValPls * bfQtPLS
			ElseIf Alltrim(HY04->TIPOPLS) == 'E6' // Promotoras
				bf2VlPLS  := xyzVPlnProm(StrZero(HY04->EMPR, 2), HY04->RA_MAT)
			EndIf

		ElseIf StrZero(HY04->EMPR, 2) == "13"
			If Alltrim(HY04->TIPOPLS) == '01'
				bf1VlPLS  := 132.08 * bfxValPls * bfQtPLS
			ElseIf Alltrim(HY04->TIPOPLS) == '02'
				bf2VlPLS  := 237.38 * bfxValPls * bfQtPLS
			EndIf

		ElseIf StrZero(HY04->EMPR, 2) == "14"

			// Faixa Etária vs Valor do Plano
			bfVIddMin := 43
			bfVIddMed := 58
			bfVVlrMin := 134.90
			bfVVlrMed := 329.11
			bfVVlrMax := 801.38

			FT007 := " SELECT RHL_MAT,
			FT007 += "        Round(DATEDIFF(dd,RB_DTNASC,'"+MV_PAR24+"1231')/365,0) IDADEDP,
			FT007 += "        Round(DATEDIFF(dd,RA_NASC  ,'"+MV_PAR24+"1231')/365,0) IDADETT,
			FT007 += "   FROM RHL140 RHL
			FT007 += "  INNER JOIN SRB140 SRB ON SRB.RB_FILIAL = RHL_FILIAL
			FT007 += "                       AND SRB.RB_MAT = RHL.RHL_MAT
			FT007 += "                       AND SRB.RB_COD = RHL.RHL_CODIGO
			FT007 += "                       AND SRB.D_E_L_E_T_ = ' '
			FT007 += "  INNER JOIN SRA140 SRA ON SRA.RA_FILIAL = RHL_FILIAL
			FT007 += "                       AND SRA.RA_MAT = RHL.RHL_MAT
			FT007 += "                       AND SRA.D_E_L_E_T_ = ' '
			FT007 += "  WHERE RHL_MAT = '"+HY04->RA_MAT+"'
			FT007 += "    AND RHL_TPFORN = '1'
			FT007 += "    AND RHL.D_E_L_E_T_ = ' '
			FTIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,FT007),'FT07',.F.,.T.)
			dbSelectArea("FT07")

			// Titular
			bfQtPLS   := 1
			bf1VlPLS  := 0
			If FT07->IDADETT < bfVIddMin
				bf1VlPLS := bfVVlrMin
			ElseIf FT07->IDADETT >= bfVIddMin .and. FT07->IDADETT <= bfVIddMed
				bf1VlPLS := bfVVlrMed
			ElseIf FT07->IDADETT > bfVIddMed
				bf1VlPLS := bfVVlrMax
			EndIf

			While !Eof()

				// Dependente
				bfQtPLS   ++
				If     FT07->IDADEDP < bfVIddMin
					bf1VlPLS += bfVVlrMin * 50 / 100
				ElseIf FT07->IDADEDP >= bfVIddMin .and. FT07->IDADEDP <= bfVIddMed
					bf1VlPLS += bfVVlrMed * 50 / 100
				ElseIf FT07->IDADEDP > bfVIddMed
					bf1VlPLS += bfVVlrMax * 50 / 100
				EndIf

				dbSelectArea("FT07")
				dbSkip()
			End
			FT07->(dbCloseArea())
			Ferase(FTIndex+GetDBExtension())     //arquivo de trabalho
			Ferase(FTIndex+OrdBagExt())          //indice gerado

		EndIf

		//             >>> TABELA 04 <<<                                               Plano Odontológico
		//***********************************************************************************************
		bfQtODO  := 0
		bfVlODO  := 0
		bf2VlODO := 0
		If HY04->QTODOTT > 0
			If     Alltrim(HY04->TIPOODN) $ "02"
				bfVlODO  += MV_PAR18 * (090/100)
				bfQtODO  += 1
			EndIf
		EndIf

		//          >>> TABELA 09 <<<                                                  Percentual de INSS
		//***********************************************************************************************
		bfPercINSS    := 0
		If HY04->RA_CATFUNC == "P"
			bfPercINSS := MV_PAR27/100                              // % de INSS Prolabore         ? 
		Else
			If StrZero(HY04->EMPR, 2) == "01"
				bfPercINSS := MV_PAR10/100                          // % de INSS Biancogres        ? 
			ElseIf StrZero(HY04->EMPR, 2) == "05"
				bfPercINSS := MV_PAR15/100                          // % de INSS Incesa            ? 
			ElseIf StrZero(HY04->EMPR, 2) == "06"
				bfPercINSS := MV_PAR23/100                          // % de INSS JK                ? 
			ElseIf StrZero(HY04->EMPR, 2) == "13"
				bfPercINSS := MV_PAR16/100                          // % de INSS Mundi             ? 
			ElseIf StrZero(HY04->EMPR, 2) == "14"
				bfPercINSS := MV_PAR17/100                          // % de INSS Vitcer            ? 
			Else
				bfPercINSS := 0
			EndIf
			If StrZero(HY04->EMPR, 2) == "01" .and. HY04->PERICUL + HY04->INSALUB <> 0
				bfPercINSS    := MV_PAR19/100                       // % de INSS Bianco Fabrica    ? 
			EndIf
			If StrZero(HY04->EMPR, 2) == "05" .and. HY04->PERICUL + HY04->INSALUB <> 0
				bfPercINSS    := MV_PAR26/100                       // % de INSS Incesa Fabrica    ? 
			EndIf
		EndIf

		//                                                                             Percentual de FGTS
		//***********************************************************************************************
		bfPercFGTS    := 0.0800
		If HY04->RA_CATFUNC == 'M' .and. HY04->RA_CATEG == '07'       // Tratamento para Menor aprendiz
			bfPercFGTS    := 0.0200
		ElseIf HY04->RA_CATFUNC $ 'P/E'                       // Tratamento para Prolabore e Estagiario
			bfPercFGTS    := 0
		EndIf

		//                                                                 Percentual de Encargos Sociais
		//***********************************************************************************************
		bfPercESol    := 0
		If StrZero(HY04->EMPR, 2) == "01"
			bfPercESol    := ( 95 + 20 ) / 100
		ElseIf StrZero(HY04->EMPR, 2) $ "05/14"
			bfPercESol    := 0
		EndIf

		//                                                                   Provisão de INSS/FGTS/EncSol
		//***********************************************************************************************
		bfFolINSS     := bfRemunerTot * bfPercINSS
		bfFolFGTS     := bfRemunerTot * bfPercFGTS
		bfFolEncSol   := (bfRemunerTot * 1 / 100) * bfPercESol

		//                                                   Férias / Abono de Férias /Reflexos INSS/FGTS
		//***********************************************************************************************
		bfProvFerias  := ( bfRemunerTot + ( bfRemunerTot / 3 )) / 12
		bfAbonoFerias := 0
		bfPrvFerINSS  := bfProvFerias * bfPercINSS
		bfPrvFerFGTS  := bfProvFerias * bfPercFGTS

		//                                                            Decimo Terceiro /Reflexos INSS/FGTS
		//***********************************************************************************************
		bfPrv13       := bfRemunerTot / 12
		bfPrv13INSS   := bfPrv13 * bfPercINSS
		bfPrv13FGTS   := bfPrv13 * bfPercFGTS

		//                                                                                            PPR
		//***********************************************************************************************
		bfPrvPPR := 0
		If     StrZero(HY04->EMPR, 2) == "06"
			bfPrvPPR := 0
		ElseIf StrZero(HY04->EMPR, 2) == "13"
			bfPrvPPR := 0
		ElseIf StrZero(HY04->EMPR, 2) == "01" .and. HY04->RA_MAT $ "001813/000414/002076"
			bfPrvPPR := (bfRendimentos * 3 * 0.8) / 12
		ElseIf StrZero(HY04->EMPR, 2) == "05" .and. HY04->RA_MAT $ "000624"
			bfPrvPPR := (bfRendimentos * 3 * 0.8) / 12
		ElseIf HY04->RA_CATFUNC <> "P" 
			bfPrvPPR := (bfRendimentos * 2 * 0.8) / 12
		EndIf

		//                                                    Tratamento para Estagiários e PCD = Externo
		//***********************************************************************************************
		If HY04->RA_CATFUNC == "E" //.or. HY04->PCD == "2"
			bfValeAlimen  := 0
			bfValeRefeic  := 0
			bfValeCombus  := 0
			bfQtPLS       := 0
			bf1VlPLS      := 0
			bf2VlPLS      := 0
			bfQtODO       := 0
			bfVlODO       := 0
			bf2VlODO      := 0
			bfFolINSS     := 0
			bfFolFGTS     := 0
			bfFolEncSol   := 0
			bfProvFerias  := 0
			bfAbonoFerias := 0
			bfPrvFerINSS  := 0
			bfPrvFerFGTS  := 0
			bfPrv13       := 0
			bfPrv13INSS   := 0
			bfPrv13FGTS   := 0
			bfPrvPPR      := 0
		EndIf

		//                                                                 Tratamento para Menor aprendiz
		//***********************************************************************************************
		If HY04->RA_CATFUNC == 'M' .and. HY04->RA_CATEG == '07'
			bfValeAlimen  := 0
			bfValeRefeic  := 0
			bfValeCombus  := 0
			bfQtPLS       := 0
			bf1VlPLS      := 0
			bf2VlPLS      := 0
			bfQtODO       := 0
			bfVlODO       := 0
			bf2VlODO      := 0
			bfUniforme    := 0
			bfPrvPPR      := 0
		EndIf

		//                                                                      Tratamento para Prolabore
		//***********************************************************************************************
		If HY04->RA_CATFUNC == "P"
			bfValeAlimen  := 0
			bfProvFerias  := 0
			bfAbonoFerias := 0
			bfPrvFerINSS  := 0
			bfPrvFerFGTS  := 0
			bfPrv13       := 0
			bfPrv13FGTS   := 0
			//bfPrvPPR      := 0 // Foi retirado porque o Al
			bfExamPeriod  := 0
			bfFolFGTS     := 0
			//bfQtODO       := 0
			//bfVlODO       := 0
			//bf2VlODO      := 0
			bfPrv13INSS   := 0
			bfFolEncSol   := 0
		EndIf

		//                                                                                 Seguro de Vida
		//***********************************************************************************************
		bfSegVida    := 0

		//                                                                                Vale Transporte
		//***********************************************************************************************
		//  ( 22 * 2 )   // 22 dias corresponde ao padrão determinado pela empresa para apurar o custo
		// previsto total mes/funcionário. 2 corresponde a quantidade de tickets por dia
		If HY04->VTRANSFOL > 0

			bfQtdTransp := HY04->QVALETRAN
			bfValTransp := HY04->VLTRANSP
			bfVlrPadTrn := MV_PAR20
			If bfValTransp == 0
				If HY04->RA_CATFUNC <> "E"
					bfValTransp := ( bfVlrPadTrn * ( bfQtdTransp * 2 ) ) - (bdSalarioRef * 6 / 100)
				Else
					bfValTransp := ( bfVlrPadTrn * ( bfQtdTransp * 2 ) )
				EndIf
				If bfValTransp < 0
					bfValTransp := 0
					bfQtdTransp := 0
				EndIf
			Else
				bfQtdTransp := 0
			EndIf

		Else

			bfValTransp := 0
			bfQtdTransp := 0

		EndIf

		//                                                                                      COEP/CIEE
		//***********************************************************************************************
		bfCoepCiee := HY04->COEPCIEE
		If HY04->PCD == "3"                                            // Estagiário que estudam SENAI
			bfCoepCiee := 0
		EndIf                                                                     

		bfTotalBenef  := bfValTransp + bfValorRefei + bfValeAlimen + bfValeRefeic + bfValeCombus + bf1VlPLS + bf2VlPLS + bfVlODO + bf2VlODO + bfExamPeriod + bfUniforme + bfCoepCiee

		Aadd( akVetOrcRH, {StrZero(HY04->EMPR, 2)           ,;
		HY04->RA_MAT                                        ,;
		bdSalarioRef                                        ,;
		HY04->PERICUL                                       ,;
		HY04->INSALUB                                       ,;
		HY04->HREXTPROG                                     ,;
		bfVlrHrExtPrg                                       ,;
		HY04->QTHE50                                        ,;
		bfVlrHE50                                           ,;
		HY04->QTHE100                                       ,;
		bfVlrHE100                                          ,;
		HY04->QTADNOTR                                      ,;
		bfVlrAdcNotur                                       ,;
		HY04->QTDSREVN                                      ,;
		bfVDSRev                                            ,;
		HY04->QTGRATIF                                      ,;
		bfVlrGratific                                       ,;
		0                                                   ,;
		bfRemunerTot                                        ,;
		bfValTransp                                         ,;
		bfQtdeRefeic                                        ,;
		bfValorRefei                                        ,;
		bfValeAlimen                                        ,;
		bfQtPLS                                             ,;
		bf1VlPLS                                            ,;
		bfQtODO                                             ,;
		bfVlODO                                             ,;
		bfExamPeriod                                        ,;
		bfCoepCiee                                          ,;
		bfTotalBenef                                        ,;
		bfFolINSS                                           ,;
		bfFolFGTS                                           ,;
		bfFolEncSol                                         ,;
		bfProvFerias                                        ,;
		bfAbonoFerias                                       ,;
		bfPrvFerINSS                                        ,;
		bfPrvFerFGTS                                        ,;
		bfPrv13                                             ,;
		bfPrv13INSS                                         ,;
		bfPrv13FGTS                                         ,;
		bfValeRefeic                                        ,;
		bfValeCombus                                        ,;
		bfUniforme                                          ,;
		bfPrvPPR                                            ,;
		HY04->QTDSRPRG                                      ,;
		bfVDSRpr                                            ,;
		bfQtdTransp * 2                                     ,;
		bdBolsaEsRef                                        ,;
		bfPercFGTS * 100                                    ,;
		bfPercINSS * 100                                    ,;
		bfPercESol * 100                                    ,;
		IIF(bfQtdTransp <> 0, bfVlrPadTrn, 0)               ,;
		bf2VlPLS                                            ,;
		bf2VlODO                                            ,;
		bfSegVida                                           ,;
		HY04->RA_CC                                         ,;
		HY04->RA_CLVL                                       })

		dbSelectArea("HY04")
		dbSkip()

	End

	If MV_PAR12 == 1

		For xt := 1 to Len(xv_Emps)

			StartJob( "U_BIA380B", GetEnvServer(), .T., xv_Emps[xt], '01', akVetOrcRH, MV_PAR02, dDataBase)

		Next xt

	EndIf

	HY04->(dbCloseArea())
	Ferase(HYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(HYcIndex+OrdBagExt())          //indice gerado

	Aviso('Arquivo','Os arquivos gerados encontram-se em: ' + zdNPath + ' São aqueles com extensão xml',{'Ok'})

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BIA380B    ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 13/08/14 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA380B(zEmp, zFil, zVetORH, zAnoMes, zDtBs)
	
	Local zp

	RPCSetType(3)
	RPCSETENV(zEmp, zFil, , , "FOL")

	ConOut("BIA380 - Orçamento RH --->>> Emp: " + zEmp + " Início....")

	JH006 := " DELETE " + RetSqlName("Z45")
	JH006 += "  WHERE Z45_FILIAL = '"+xFilial("Z45")+"'
	JH006 += "    AND Z45_ANOMES = '"+zAnoMes+"'
	JH006 += "    AND D_E_L_E_T_ = ' '
	TCSQLExec(JH006)

	xRegAtu := 0
	For zp := 1 to Len(zVetORH)

		If zVetORH[zp][1] == zEmp

			dbSelectArea("Z45")
			dbGoTop()
			If !dbSeek(xFilial("Z45") + zAnoMes + dtos(zDtBs) + zVetORH[zp][2])
				xRegAtu ++
				RecLock("Z45",.T.)
				Z45_FILIAL := xFilial("Z45")
				Z45_ANOMES := zAnoMes
				Z45_DTPROC := zDtBs
				Z45_MATRIC := zVetORH[zp][2]
				Z45_SALREF := zVetORH[zp][3]
				Z45_PERIC  := zVetORH[zp][4]
				Z45_INSAL  := zVetORH[zp][5]
				Z45_HRFERD := zVetORH[zp][6]
				Z45_VLFERD := zVetORH[zp][7]
				Z45_QTHE50 := zVetORH[zp][8]
				Z45_VLHE50 := zVetORH[zp][9]
				Z45_QTHEA0 := zVetORH[zp][10]
				Z45_VLHEA0 := zVetORH[zp][11]
				Z45_QTADNT := zVetORH[zp][12]
				Z45_VLADNT := zVetORH[zp][13]
				Z45_QTDSR  := zVetORH[zp][14]
				Z45_VLDSR  := zVetORH[zp][15]
				Z45_QTGRAT := zVetORH[zp][16]
				Z45_VLGRAT := zVetORH[zp][17]
				Z45_MEDMEN := zVetORH[zp][18]
				Z45_RMUNTT := zVetORH[zp][19]
				Z45_VLTRAN := zVetORH[zp][20]
				Z45_QTREFE := zVetORH[zp][21]
				Z45_VLREFE := zVetORH[zp][22]
				Z45_TKTALM := zVetORH[zp][23]  // Separou Vale Alimentação de Alimentação noturna
				Z45_TCKTRF := zVetORH[zp][41]  // Novo - Alimentação noturna
				Z45_TKTCBT := zVetORH[zp][42]  // Novo - Vale Combustível
				Z45_QTPLS  := zVetORH[zp][24]
				Z45_VLPLS  := zVetORH[zp][25]
				Z45_QTODON := zVetORH[zp][26]
				Z45_VLODON := zVetORH[zp][27]
				Z45_EXMPER := zVetORH[zp][28]
				Z45_UNIFOR := zVetORH[zp][43]  // Novo - Uniforme
				Z45_COEPCI := zVetORH[zp][29]
				Z45_TTBENE := zVetORH[zp][30]
				Z45_FOLINS := zVetORH[zp][31]
				Z45_FOLFGT := zVetORH[zp][32]
				Z45_FOLENC := zVetORH[zp][33]
				Z45_PRVFER := zVetORH[zp][34]
				Z45_ABNFER := zVetORH[zp][35]
				Z45_PVFRIN := zVetORH[zp][36]
				Z45_PVFRFG := zVetORH[zp][37]
				Z45_PRV13  := zVetORH[zp][38]
				Z45_PV13IN := zVetORH[zp][39]
				Z45_PV13FG := zVetORH[zp][40]
				Z45_PPR    := zVetORH[zp][44]  // Novo - PPR
				Z45_QDSRPG := zVetORH[zp][45]
				Z45_VDSRPG := zVetORH[zp][46]
				Z45_QTTRAN := zVetORH[zp][47]
				Z45_BOLSAE := zVetORH[zp][48]
				Z45_PFGTS  := zVetORH[zp][49]
				Z45_PINSS  := zVetORH[zp][50]
				Z45_ENCSOL := zVetORH[zp][51]
				Z45_VLUNVT := zVetORH[zp][52]
				Z45_VLPLS2 := zVetORH[zp][53]
				Z45_VLODO2 := zVetORH[zp][54]
				Z45_SEGVID := zVetORH[zp][55]
				Z45_CC     := zVetORH[zp][56]
				Z45_CLVL   := zVetORH[zp][57]
				MsUnLock()
			EndIf

			ConOut("Emp: " + zVetORH[zp][1] + " Matric: " + zVetORH[zp][2])

		EndIf

	Next zp

	ConOut("BIA380 - Orçamento RH --->>> Emp: " + zEmp + " - Registros Processados: " + Alltrim(Str(xRegAtu)) + " Fim....")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ xyzVPlnProm ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 23/08/16 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function xyzVPlnProm(vfgEmpr, vfgMatr)

	Local tmpVlPLS := 0

	// Faixa Etária vs Valor do Plano
	ckfx01    := 18
	ckfx02    := 23
	ckfx03    := 28
	ckfx04    := 33
	ckfx05    := 38
	ckfx06    := 43
	ckfx07    := 48
	ckfx08    := 53
	ckfx09    := 58
	ckfx10    := 150
	ckvl01    := 135.74
	ckvl02    := 169.68
	ckvl03    := 212.10
	ckvl04    := 233.31
	ckvl05    := 244.98
	ckvl06    := 269.48
	ckvl07    := 336.85
	ckvl08    := 370.54
	ckvl09    := 463.18
	ckvl10    := 810.57
	ckPercnt  := 0.40

	FT007 := " SELECT RHL_MAT, "
	FT007 += "        Round(convert(numeric, convert(datetime, '"+MV_PAR24+"1231') - convert(datetime, RA_NASC))/365,0) IDADETT "
	FT007 += "   FROM RHL" + vfgEmpr + "0 RHL "
	FT007 += "  INNER JOIN SRA" + vfgEmpr + "0 SRA ON SRA.RA_FILIAL = RHL_FILIAL "
	FT007 += "                       AND SRA.RA_MAT = RHL.RHL_MAT "
	FT007 += "                       AND SRA.D_E_L_E_T_ = ' ' "
	FT007 += "  WHERE RHL_MAT = '" + vfgMatr + "' "
	FT007 += "    AND RHL_TPFORN = '1' "
	FT007 += "    AND RHL.D_E_L_E_T_ = ' ' "
	FTIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,FT007),'FT07',.F.,.T.)
	dbSelectArea("FT07")

	If FT07->IDADETT <= ckfx01
		tmpVlPLS := ckvl01 * ckPercnt
	ElseIf FT07->IDADETT > ckfx01 .and. FT07->IDADETT <= ckfx02
		tmpVlPLS := ckvl02 * ckPercnt
	ElseIf FT07->IDADETT > ckfx02 .and. FT07->IDADETT <= ckfx03
		tmpVlPLS := ckvl03 * ckPercnt
	ElseIf FT07->IDADETT > ckfx03 .and. FT07->IDADETT <= ckfx04
		tmpVlPLS := ckvl04 * ckPercnt
	ElseIf FT07->IDADETT > ckfx04 .and. FT07->IDADETT <= ckfx05
		tmpVlPLS := ckvl05 * ckPercnt
	ElseIf FT07->IDADETT > ckfx05 .and. FT07->IDADETT <= ckfx06
		tmpVlPLS := ckvl06 * ckPercnt
	ElseIf FT07->IDADETT > ckfx06 .and. FT07->IDADETT <= ckfx07
		tmpVlPLS := ckvl07 * ckPercnt
	ElseIf FT07->IDADETT > ckfx07 .and. FT07->IDADETT <= ckfx08
		tmpVlPLS := ckvl08 * ckPercnt
	ElseIf FT07->IDADETT > ckfx08 .and. FT07->IDADETT <= ckfx09
		tmpVlPLS := ckvl09 * ckPercnt
	ElseIf FT07->IDADETT > ckfx09 .and. FT07->IDADETT <= ckfx10
		tmpVlPLS := ckvl10 * ckPercnt
	EndIf

	FT07->(dbCloseArea())
	Ferase(FTIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(FTIndex+OrdBagExt())          //indice gerado

Return ( tmpVlPLS )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA380A  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 23/08/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Impressao                                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA380I()

	MsgINFO("Em construção...")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA380D  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 23/08/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Montagem da Tela de Visualização, Inclusao e Alteração     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA380D()
	
	Local qa

	fPerg := "BIA380D"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidDPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	qaEmps    := {"01", "05", "06", "13", "14"}

	For qa := 1 to Len(qaEmps)

		ZP002 := " UPDATE Z45" + qaEmps[qa] + "0 SET Z45_ANOREF = '" + MV_PAR02 + "', Z45_FLAG = 'S' "
		ZP002 += "   FROM Z45" + qaEmps[qa] + "0 "
		ZP002 += "  WHERE Z45_ANOREF = '    ' "
		ZP002 += "    AND Z45_DTPROC = '" + dtos(MV_PAR01) + "' "
		ZP002 += "    AND D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Processando... " + qaEmps[qa] + "                 ",, {|| TcSqlExec(ZP002) })		

	Next qa

	MsgINFO("Processamento concluído...")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA380R  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 31/08/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Replica RA_CLVL para RA_YCLVL                              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA380R()

	Local qa

	If MsgNOYES("Esta rotina irá atualizar as Classes Valor Ativas para versão Orçamentária (prevendo possíveis alterações durante este processo). Deseja continuar?")

		qaEmps    := {"01", "05", "06", "13", "14"}

		For qa := 1 to Len(qaEmps)

			ZP002 := " UPDATE SRA" + qaEmps[qa] + "0 SET RA_YCLVL = RA_CLVL "
			ZP002 += "   FROM SRA" + qaEmps[qa] + "0 "
			ZP002 += "  WHERE RA_CLVL <> '         ' "
			ZP002 += "    AND D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Processando... " + qaEmps[qa] + "                 ",, {|| TcSqlExec(ZP002) })		

		Next qa

		MsgINFO("Processamento concluído...")

	Else

		MsgINFO("Processamento cancelado...")

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 23/08/16 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Ano/Mes De                  ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ano/Mes Até                 ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Valor do Salário Mínimo     ?","","","mv_ch3","N",14,2,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Taxa CIEE                   ?","","","mv_ch4","N",14,2,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Taxa Coep                   ?","","","mv_ch5","N",14,2,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Valor Refeição/Almoço(Grupo)?","","","mv_ch6","N",14,2,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Valor - Alimentação(BG/IN)  ?","","","mv_ch7","N",14,2,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Valor - Ticket(BG/IN)       ?","","","mv_ch8","N",14,2,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Valor - Alimentação(Mundi)  ?","","","mv_ch9","N",14,2,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","% de INSS Biancogres        ?","","","mv_cha","N",14,2,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"11","Valor Vale Combustível      ?","","","mv_chb","N",14,2,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Atualizar Orçamento - SAP   ?","","","mv_chc","N",01,0,0,"C","","mv_par12","Sim","","","","","Não","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"13","Valor - Alimentação(Vitcer) ?","","","mv_chd","N",14,2,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"14","Valor - Ticket(Vitcer)      ?","","","mv_che","N",14,2,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"15","% de INSS Incesa            ?","","","mv_chf","N",14,2,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"16","% de INSS Mundi             ?","","","mv_chg","N",14,2,0,"G","","mv_par16","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"17","% de INSS Vitcer            ?","","","mv_chh","N",14,2,0,"G","","mv_par17","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"18","Valor Plano Odontologico    ?","","","mv_chi","N",14,2,0,"G","","mv_par18","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"19","% de INSS Bianco Fabrica    ?","","","mv_chj","N",14,2,0,"G","","mv_par19","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"20","Vale Transporte             ?","","","mv_chk","N",14,2,0,"G","","mv_par20","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"21","Data de Admissão Limite     ?","","","mv_chl","D",08,0,0,"G","","mv_par21","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"22","Valor - Ticket(BG/IN)(Turno)?","","","mv_chm","N",14,2,0,"G","","mv_par22","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"23","% de INSS JK                ?","","","mv_chn","N",14,2,0,"G","","mv_par23","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"24","Ano Ref. p/ Orçamento       ?","","","mv_cho","C",04,0,0,"G","","mv_par24","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"25","Valor Plano Odonto(Promotor)?","","","mv_chp","N",14,2,0,"G","","mv_par25","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"26","% de INSS Incesa Fabrica    ?","","","mv_chq","N",14,2,0,"G","","mv_par26","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"27","% de INSS Prolabore         ?","","","mv_chr","N",14,2,0,"G","","mv_par27","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"28","Valor Desjejum(BG/IN)       ?","","","mv_chs","N",14,2,0,"G","","mv_par28","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"29","Valor Desjejum(Vitcer)      ?","","","mv_cht","N",14,2,0,"G","","mv_par29","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"30","Combustivel Diretor Adm     ?","","","mv_chu","N",14,2,0,"G","","mv_par30","","","","","","","","","","","","","","","","","","","","","","","","",""})
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

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidDPerg ¦ Autor ¦ Marcos Alberto S   ¦ Data ¦ 23/08/16 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidDPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Data Ref. Fotografia        ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ano Ref. p/ Orçamento       ?","","","mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
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

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ValidFilPerg ¦ Autor ¦ Marcos Alberto S  ¦ Data ¦ 11/09/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidFilPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Ano Ref. p/ Orçamento       ?","","","mv_ch1","C",04,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
