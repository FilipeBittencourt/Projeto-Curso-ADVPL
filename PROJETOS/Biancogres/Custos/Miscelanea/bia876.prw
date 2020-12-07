#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA876
@author Marcos Alberto Soprani
@since 26/08/16
@version 1.0
@description Análise sintética da fotografia da estrutura para fins orçamentários
@obs OS: 3370-16 - Jecimar Ferreira
@type function
/*/

User Function BIA876()

	fPerg  := "BIA876"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	nxEnter  := CHR(13) + CHR(10)

	U_BIAMsgRun("Processando...                          ",, {|| BIA876PRC() })

Return

Static Function BIA876PRC()

	IncProc("Processamento....")

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha01"
	nxTabl := "Análise sintética da fotografia da estrutura para fins orçamentários" 
	nxCont := 0 

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "DATAREF            " ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "FORMATO            " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DFORMATO           " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CHV_FORMT          " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "BASE               " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DBASE              " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ACABAM             " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "AACABAM            " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ESPESS             " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESPESS            " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO            " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DPRODUTO           " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ITCUST             " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DITCUST            " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA              " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DCONTA             " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CHV_CTA            " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CTOTAL             " ,3,2)

	QG009 := Alltrim(" WITH VWPRODT AS (SELECT B1_FILIAL,                                                                            ") + nxEnter
	QG009 += Alltrim("                         B1_COD,                                                                               ") + nxEnter
	QG009 += Alltrim("                         B1_DESC,                                                                              ") + nxEnter
	QG009 += Alltrim("                         B1_YFORMAT,                                                                           ") + nxEnter
	QG009 += Alltrim("                         B1_YBASE,                                                                             ") + nxEnter
	QG009 += Alltrim("                         B1_YACABAM,                                                                           ") + nxEnter
	QG009 += Alltrim("                         B1_YESPESS,                                                                           ") + nxEnter
	QG009 += Alltrim("                         D_E_L_E_T_                                                                            ") + nxEnter
	QG009 += Alltrim("                    FROM " + RetSqlName("SB1") + "                                                             ") + nxEnter
	QG009 += Alltrim("                   WHERE B1_FILIAL = '" + xFilial("SB1") + "'                                                  ") + nxEnter
	QG009 += Alltrim("                     AND D_E_L_E_T_ = ' '                                                                      ") + nxEnter
	QG009 += Alltrim("                   UNION ALL                                                                                   ") + nxEnter
	QG009 += Alltrim("                  SELECT B1_FILIAL,                                                                            ") + nxEnter
	QG009 += Alltrim("                         Z51_CODNEW B1_COD,                                                                    ") + nxEnter
	QG009 += Alltrim("                         RTRIM(Z51_DESCR)+' ('+RTRIM(Z51_CODNEW)+')' B1_DESC,                                  ") + nxEnter
	QG009 += Alltrim("                         B1_YFORMAT,                                                                           ") + nxEnter
	QG009 += Alltrim("                         B1_YBASE,                                                                             ") + nxEnter
	QG009 += Alltrim("                         B1_YACABAM,                                                                           ") + nxEnter
	QG009 += Alltrim("                         B1_YESPESS,                                                                           ") + nxEnter
	QG009 += Alltrim("                         SB1.D_E_L_E_T_                                                                        ") + nxEnter
	QG009 += Alltrim("                    FROM " + RetSqlName("Z51") + " Z51                                                         ") + nxEnter
	QG009 += Alltrim("                   INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "'            ") + nxEnter
	QG009 += Alltrim("                                                         AND B1_COD = Z51_CODREF                               ") + nxEnter
	QG009 += Alltrim("                                                         AND SB1.D_E_L_E_T_ = ' '                              ") + nxEnter
	QG009 += Alltrim("                   WHERE Z51.D_E_L_E_T_ = ' ')                                                                 ") + nxEnter

	QG004 := QG009
	QG004 += Alltrim(" SELECT Z46_DATARF DATAREF,                                                                                    ") + nxEnter
	QG004 += Alltrim("        SB1.B1_YFORMAT FORMATO,                                                                                ") + nxEnter
	QG004 += Alltrim("        ZZ6_DESC DFORMATO,                                                                                     ") + nxEnter
	QG004 += Alltrim("        SUBSTRING(RTRIM(SB1.B1_YFORMAT)+'-'+RTRIM(ZZ6_DESC),1,15) CHV_FORMT,                                   ") + nxEnter
	QG004 += Alltrim("        SB1.B1_YBASE BASE,                                                                                     ") + nxEnter
	QG004 += Alltrim("        Z32_DESCR DBASE,                                                                                       ") + nxEnter
	QG004 += Alltrim("        SB1.B1_YACABAM ACABAM,                                                                                 ") + nxEnter
	QG004 += Alltrim("        Z33_DESCR AACABAM,                                                                                     ") + nxEnter
	QG004 += Alltrim("        SB1.B1_YESPESS ESPESS,                                                                                 ") + nxEnter
	QG004 += Alltrim("        Z34_DESCR DESPESS,                                                                                     ") + nxEnter
	QG004 += Alltrim("        Z46_COD PRODUTO,                                                                                       ") + nxEnter
	QG004 += Alltrim("        SUBSTRING(SB1.B1_DESC,1,50) DPRODUTO,                                                                  ") + nxEnter
	QG004 += Alltrim("        Z46_ITCUS ITCUST,                                                                                      ") + nxEnter
	QG004 += Alltrim("        Z29_DESCR DITCUST,                                                                                     ") + nxEnter
	QG004 += Alltrim("        Z46_CONTA CONTA,                                                                                       ") + nxEnter
	QG004 += Alltrim("        CT1_DESC01 DCONTA,                                                                                     ") + nxEnter
	QG004 += Alltrim("        SUBSTRING(RTRIM(Z46_CONTA)+'-'+RTRIM(CT1_DESC01),1,25) CHV_CTA,                                        ") + nxEnter
	QG004 += Alltrim("        SUM(Z46_CTOTAL) CTOTAL                                                                                 ") + nxEnter
	QG004 += Alltrim("   FROM " + RetSqlName("Z46") + " Z46 WITH (NOLOCK)                                                            ") + nxEnter
	QG004 += Alltrim("  INNER JOIN " + RetSqlName("CT1") + " CT1 WITH (NOLOCK) ON CT1_FILIAL = '" + xFilial("CT1") + "'              ") + nxEnter
	QG004 += Alltrim("                       AND CT1_CONTA = Z46_CONTA                                                               ") + nxEnter
	QG004 += Alltrim("                       AND CT1.D_E_L_E_T_ = ' '                                                                ") + nxEnter
	QG004 += Alltrim("  INNER JOIN VWPRODT SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'                             ") + nxEnter
	QG004 += Alltrim("                       AND SB1.B1_COD = Z46_COD                                                                ") + nxEnter
	QG004 += Alltrim("                       AND SB1.D_E_L_E_T_ = ' '                                                                ") + nxEnter
	QG004 += Alltrim("  INNER JOIN " + RetSqlName("ZZ6") + " ZZ6 WITH (NOLOCK) ON ZZ6_FILIAL = '" + xFilial("ZZ6") + "'              ") + nxEnter
	QG004 += Alltrim("                       AND ZZ6.ZZ6_COD = SB1.B1_YFORMAT                                                        ") + nxEnter
	QG004 += Alltrim("                       AND ZZ6.D_E_L_E_T_ = ' '                                                                ") + nxEnter
	QG004 += Alltrim("  INNER JOIN VWPRODT XB1 WITH (NOLOCK) ON XB1.B1_FILIAL = '" + xFilial("SB1") + "'                             ") + nxEnter
	QG004 += Alltrim("                       AND XB1.B1_COD = Z46_COMP                                                               ") + nxEnter
	QG004 += Alltrim("                       AND XB1.D_E_L_E_T_ = ' '                                                                ") + nxEnter
	QG004 += Alltrim("  INNER JOIN " + RetSqlName("Z32") + " Z32 WITH (NOLOCK) ON Z32_FILIAL = '" + xFilial("Z32") + "'              ") + nxEnter
	QG004 += Alltrim("                       AND Z32.Z32_CODIGO = SB1.B1_YBASE                                                       ") + nxEnter
	QG004 += Alltrim("                       AND Z32.D_E_L_E_T_ = ' '                                                                ") + nxEnter
	QG004 += Alltrim("  INNER JOIN " + RetSqlName("Z33") + " Z33 WITH (NOLOCK) ON Z33_FILIAL = '" + xFilial("Z33") + "'              ") + nxEnter
	QG004 += Alltrim("                       AND Z33.Z33_CODIGO = SB1.B1_YACABAM                                                     ") + nxEnter
	QG004 += Alltrim("                       AND Z33.D_E_L_E_T_ = ' '                                                                ") + nxEnter
	QG004 += Alltrim("  INNER JOIN " + RetSqlName("Z34") + " Z34 WITH (NOLOCK) ON Z34_FILIAL = '" + xFilial("Z34") + "'              ") + nxEnter
	QG004 += Alltrim("                       AND Z34.Z34_CODIGO = SB1.B1_YESPESS                                                     ") + nxEnter
	QG004 += Alltrim("                       AND Z34.D_E_L_E_T_ = ' '                                                                ") + nxEnter
	QG004 += Alltrim("   LEFT JOIN " + RetSqlName("Z29") + " Z29 WITH (NOLOCK) ON Z29_FILIAL = '" + xFilial("Z29") + "'              ") + nxEnter
	QG004 += Alltrim("                                     AND Z29_COD_IT = CT1_YITCUS                                               ") + nxEnter
	QG004 += Alltrim("                                     AND Z29.D_E_L_E_T_ = ' '                                                  ") + nxEnter
	QG004 += Alltrim("  WHERE Z46_FILIAL = '" + xFilial("Z46") + "'                                                                  ") + nxEnter
	QG004 += Alltrim("    AND Z46_DATARF IN('" + dtos(MV_PAR02) + "')                                                                ") + nxEnter
	QG004 += Alltrim("    AND Z46_CTOTAL <> 0                                                                                        ") + nxEnter
	QG004 += Alltrim("    AND Z46.D_E_L_E_T_ = ' '                                                                                   ") + nxEnter
	QG004 += Alltrim("  GROUP BY Z46_DATARF,                                                                                         ") + nxEnter
	QG004 += Alltrim("           SB1.B1_YFORMAT,                                                                                     ") + nxEnter
	QG004 += Alltrim("           ZZ6_DESC,                                                                                           ") + nxEnter
	QG004 += Alltrim("           SB1.B1_YBASE,                                                                                       ") + nxEnter
	QG004 += Alltrim("           Z32_DESCR,                                                                                          ") + nxEnter
	QG004 += Alltrim("           SB1.B1_YACABAM,                                                                                     ") + nxEnter
	QG004 += Alltrim("           Z33_DESCR,                                                                                          ") + nxEnter
	QG004 += Alltrim("           SB1.B1_YESPESS,                                                                                     ") + nxEnter
	QG004 += Alltrim("           Z34_DESCR,                                                                                          ") + nxEnter
	QG004 += Alltrim("           Z46_COD,                                                                                            ") + nxEnter
	QG004 += Alltrim("           SUBSTRING(SB1.B1_DESC,1,50),                                                                        ") + nxEnter
	QG004 += Alltrim("           Z46_CONTA,                                                                                          ") + nxEnter
	QG004 += Alltrim("           CT1_DESC01,                                                                                         ") + nxEnter
	QG004 += Alltrim("           Z46_ITCUS,                                                                                          ") + nxEnter
	QG004 += Alltrim("           Z29_DESCR                                                                                           ") + nxEnter
	QGcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QG004),'QG04',.F.,.T.)
	dbSelectArea("QG04")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		nxCont ++
		IncProc("Processamento(1)... " + Alltrim(Str(nxCont)))

		oExcel:AddRow(nxPlan, nxTabl, { stod(QG04->DATAREF)           ,;
		QG04->FORMATO                                                 ,;
		QG04->DFORMATO                                                ,;
		QG04->CHV_FORMT                                               ,;
		QG04->BASE                                                    ,;
		QG04->DBASE                                                   ,;
		QG04->ACABAM                                                  ,;
		QG04->AACABAM                                                 ,;
		QG04->ESPESS                                                  ,;
		QG04->DESPESS                                                 ,;
		QG04->PRODUTO                                                 ,;
		QG04->DPRODUTO                                                ,;
		QG04->ITCUST                                                  ,;
		QG04->DITCUST                                                 ,;
		QG04->CONTA                                                   ,;
		QG04->DCONTA                                                  ,;
		QG04->CHV_CTA                                                 ,;
		QG04->CTOTAL                                                  })

		dbSelectArea("QG04")
		dbSkip()

	End

	QG04->(dbCloseArea())
	Ferase(QGcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(QGcIndex+OrdBagExt())          //indice gerado

	nxPlan := "Planilha02"
	nxTabl := "Análise analítica da fotografia da estrutura para fins orçamentários" 
	nxCont := 0 

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "DATAREF            " ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "FORMATO            " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DFORMATO           " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CHV_FORMT          " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "BASE               " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DBASE              " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ACABAM             " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DACABAM            " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ESPESS             " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESPESS            " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO            " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DPRODUTO           " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ITCUST             " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DITCUST            " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA              " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DCONTA             " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CHV_CTA            " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CTOTAL             " ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "SEQGRV             " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "COMP               " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NIVEL              " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "REVISAO            " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TRT                " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT              " ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUNIT              " ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "RF                 " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DTCUSTO            " ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "UMIDAD             " ,1,1)

	QG004 := QG009
	QG004 += Alltrim(" SELECT Z46_DATARF DATAREF,                                                                                    ") + nxEnter
	QG004 += Alltrim("        SB1.B1_YFORMAT FORMATO,                                                                                ") + nxEnter
	QG004 += Alltrim("        ZZ6_DESC DFORMATO,                                                                                     ") + nxEnter
	QG004 += Alltrim("        SUBSTRING(RTRIM(SB1.B1_YFORMAT)+'-'+RTRIM(ZZ6_DESC),1,15) CHV_FORMT,                                   ") + nxEnter
	QG004 += Alltrim("        SB1.B1_YBASE BASE,                                                                                     ") + nxEnter
	QG004 += Alltrim("        Z32_DESCR DBASE,                                                                                       ") + nxEnter
	QG004 += Alltrim("        SB1.B1_YACABAM ACABAM,                                                                                 ") + nxEnter
	QG004 += Alltrim("        Z33_DESCR AACABAM,                                                                                     ") + nxEnter
	QG004 += Alltrim("        SB1.B1_YESPESS ESPESS,                                                                                 ") + nxEnter
	QG004 += Alltrim("        Z34_DESCR DESPESS,                                                                                     ") + nxEnter
	QG004 += Alltrim("        Z46_COD PRODUTO,                                                                                       ") + nxEnter
	QG004 += Alltrim("        SUBSTRING(SB1.B1_DESC,1,50) DPRODUTO,                                                                  ") + nxEnter
	QG004 += Alltrim("        Z46_ITCUS ITCUST,                                                                                      ") + nxEnter
	QG004 += Alltrim("        Z29_DESCR DITCUST,                                                                                     ") + nxEnter
	QG004 += Alltrim("        Z46_CONTA CONTA,                                                                                       ") + nxEnter
	QG004 += Alltrim("        CT1_DESC01 DCONTA,                                                                                     ") + nxEnter
	QG004 += Alltrim("        SUBSTRING(RTRIM(Z46_CONTA)+'-'+RTRIM(CT1_DESC01),1,25) CHV_CTA,                                        ") + nxEnter
	QG004 += Alltrim("        Z46_CTOTAL CTOTAL,                                                                                     ") + nxEnter
	QG004 += Alltrim("        Z46_SEQGRV SEQGRV,                                                                                     ") + nxEnter
	QG004 += Alltrim("        Z46_COMP COMP,                                                                                         ") + nxEnter
	QG004 += Alltrim("        Z46_NIVEL NIVEL,                                                                                       ") + nxEnter
	QG004 += Alltrim("        Z46_REVATU REVISAO,                                                                                    ") + nxEnter
	QG004 += Alltrim("        Z46_TRT TRT,                                                                                           ") + nxEnter
	QG004 += Alltrim("        Z46_QUANT QUANT,                                                                                       ") + nxEnter
	QG004 += Alltrim("        Z46_CUNIT CUNIT,                                                                                       ") + nxEnter
	QG004 += Alltrim("        Z46_RF RF,                                                                                             ") + nxEnter
	QG004 += Alltrim("        Z46_DTCSTO DTCUSTO,                                                                                    ") + nxEnter
	QG004 += Alltrim("        Z46_UMIDAD UMIDAD                                                                                      ") + nxEnter
	QG004 += Alltrim("   FROM " + RetSqlName("Z46") + " Z46 WITH (NOLOCK)                                                            ") + nxEnter
	QG004 += Alltrim("  INNER JOIN " + RetSqlName("CT1") + " CT1 WITH (NOLOCK) ON CT1_FILIAL = '" + xFilial("CT1") + "'              ") + nxEnter
	QG004 += Alltrim("                       AND CT1_CONTA = Z46_CONTA                                                               ") + nxEnter
	QG004 += Alltrim("                       AND CT1.D_E_L_E_T_ = ' '                                                                ") + nxEnter
	QG004 += Alltrim("  INNER JOIN VWPRODT SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'                             ") + nxEnter
	QG004 += Alltrim("                       AND SB1.B1_COD = Z46_COD                                                                ") + nxEnter
	QG004 += Alltrim("                       AND SB1.D_E_L_E_T_ = ' '                                                                ") + nxEnter
	QG004 += Alltrim("  INNER JOIN " + RetSqlName("ZZ6") + " ZZ6 WITH (NOLOCK) ON ZZ6_FILIAL = '" + xFilial("ZZ6") + "'              ") + nxEnter
	QG004 += Alltrim("                       AND ZZ6.ZZ6_COD = SB1.B1_YFORMAT                                                        ") + nxEnter
	QG004 += Alltrim("                       AND ZZ6.D_E_L_E_T_ = ' '                                                                ") + nxEnter
	QG004 += Alltrim("  INNER JOIN VWPRODT XB1 WITH (NOLOCK) ON XB1.B1_FILIAL = '" + xFilial("SB1") + "'                             ") + nxEnter
	QG004 += Alltrim("                       AND XB1.B1_COD = Z46_COMP                                                               ") + nxEnter
	QG004 += Alltrim("                       AND XB1.D_E_L_E_T_ = ' '                                                                ") + nxEnter
	QG004 += Alltrim("  INNER JOIN " + RetSqlName("Z32") + " Z32 WITH (NOLOCK) ON Z32_FILIAL = '" + xFilial("Z32") + "'              ") + nxEnter
	QG004 += Alltrim("                       AND Z32.Z32_CODIGO = SB1.B1_YBASE                                                       ") + nxEnter
	QG004 += Alltrim("                       AND Z32.D_E_L_E_T_ = ' '                                                                ") + nxEnter
	QG004 += Alltrim("  INNER JOIN " + RetSqlName("Z33") + " Z33 WITH (NOLOCK) ON Z33_FILIAL = '" + xFilial("Z33") + "'              ") + nxEnter
	QG004 += Alltrim("                       AND Z33.Z33_CODIGO = SB1.B1_YACABAM                                                     ") + nxEnter
	QG004 += Alltrim("                       AND Z33.D_E_L_E_T_ = ' '                                                                ") + nxEnter
	QG004 += Alltrim("  INNER JOIN " + RetSqlName("Z34") + " Z34 WITH (NOLOCK) ON Z34_FILIAL = '" + xFilial("Z34") + "'              ") + nxEnter
	QG004 += Alltrim("                       AND Z34.Z34_CODIGO = SB1.B1_YESPESS                                                     ") + nxEnter
	QG004 += Alltrim("                       AND Z34.D_E_L_E_T_ = ' '                                                                ") + nxEnter
	QG004 += Alltrim("   LEFT JOIN " + RetSqlName("Z29") + " Z29 WITH (NOLOCK) ON Z29_FILIAL = '" + xFilial("Z29") + "'              ") + nxEnter
	QG004 += Alltrim("                                     AND Z29_COD_IT = CT1_YITCUS                                               ") + nxEnter
	QG004 += Alltrim("                                     AND Z29.D_E_L_E_T_ = ' '                                                  ") + nxEnter
	QG004 += Alltrim("  WHERE Z46_FILIAL = '" + xFilial("Z46") + "'                                                                  ") + nxEnter
	QG004 += Alltrim("    AND Z46_DATARF IN('" + dtos(MV_PAR02) + "')                                                                ") + nxEnter
	QG004 += Alltrim("    AND Z46_CTOTAL <> 0                                                                                        ") + nxEnter
	QG004 += Alltrim("    AND Z46.D_E_L_E_T_ = ' '                                                                                   ") + nxEnter
	QGcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QG004),'QG04',.F.,.T.)
	dbSelectArea("QG04")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		nxCont ++
		IncProc("Processamento(2)... " + Alltrim(Str(nxCont)))

		oExcel:AddRow(nxPlan, nxTabl, { stod(QG04->DATAREF)           ,;
		QG04->FORMATO                                                 ,;
		QG04->DFORMATO                                                ,;
		QG04->CHV_FORMT                                               ,;
		QG04->BASE                                                    ,;
		QG04->DBASE                                                   ,;
		QG04->ACABAM                                                  ,;
		QG04->AACABAM                                                 ,;
		QG04->ESPESS                                                  ,;
		QG04->DESPESS                                                 ,;
		QG04->PRODUTO                                                 ,;
		QG04->DPRODUTO                                                ,;
		QG04->ITCUST                                                  ,;
		QG04->DITCUST                                                 ,;
		QG04->CONTA                                                   ,;
		QG04->DCONTA                                                  ,;
		QG04->CHV_CTA                                                 ,;
		QG04->CTOTAL                                                  ,;
		QG04->SEQGRV                                                  ,;
		QG04->COMP                                                    ,;
		QG04->NIVEL                                                   ,;
		QG04->REVISAO                                                 ,;
		QG04->TRT                                                     ,;
		QG04->QUANT                                                   ,;
		QG04->CUNIT                                                   ,;
		QG04->RF                                                      ,;
		stod(QG04->DTCUSTO)                                           ,;
		QG04->UMIDAD                                                  })

		dbSelectArea("QG04")
		dbSkip()

	End

	QG04->(dbCloseArea())
	Ferase(QGcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(QGcIndex+OrdBagExt())          //indice gerado


	xArqTemp := IIF(Empty(MV_PAR01), "BIA876", Alltrim(MV_PAR01) )

	If File("C:\TEMP\"+xArqTemp+".xml")
		If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
		EndIf
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

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 04/08/16 ¦¦¦
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
	aAdd(aRegs,{cPerg,"01","Nome do Arquivo        ?","","","mv_ch1","C",80,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Data Ref. da Fotografia?","","","mv_ch2","D",08,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return
