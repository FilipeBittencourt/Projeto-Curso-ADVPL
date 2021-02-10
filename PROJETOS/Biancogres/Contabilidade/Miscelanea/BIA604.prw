#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA604
@author Wlysses Cerqueira (Facile)
@since 25/11/2020
@version 1.0
@description Processamento - RAC Orçada - Desdobra capacidade produtiva.
@type function
@Obs Projeto A-35
/*/

User Function BIA604()

	cCadastro := Upper(Alltrim("RAC Orçada - Proc. Custo Unitário Fixo"))
	aRotina   := { {"Pesquisar"       ,"AxPesqui"	    				,0,1},;
	{               "Visualizar"      ,"AxVisual"	    				,0,2},;
	{               "Processar"       ,'ExecBlock("BIA604A",.F.,.F.)'   ,0,3}}

	_bCondicao := {|| ZO8_TPCUS = 'CF' }
	_cCondicao := "ZO8_TPCUS = 'CF'"
	DbSelectArea("ZO8")
	DbSetOrder(1)
	DbSetFilter(_bCondicao, _cCondicao)	

	mBrowse(06,01,22,75,"ZO8")

Return

User Function BIA604A()

	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "RAC Orçada - Proc. Custo Unitário Fixo"
	Private msCanPrc  := .F.

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte()

		Begin Transaction

			xVerRet := .F.
			Processa({ || ExistThenD(cFilAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Deletando dados...", .F.)
			If xVerRet

				Processa({ || fProcessa(cFilAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Processando dados...", .F.)
				lRet := xVerRet 

				If xVerRet

					Processa({ || fProcC1(cFilAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Processando dados...", .F.)
					lRet := xVerRet 

				Else

					msCanPrc  := .T.

				EndIf

			Else

				msCanPrc  := .T.

			EndIf

			If !lRet

				DisarmTransaction()

			EndIf

		End Transaction

	Else

		msCanPrc  := .T.

	EndIf

	If !msCanPrc

		If !lRet

			MsgSTOP("Erro no processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO")

		Else

			MsgINFO("Fim do processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "BIA604")

	EndIf

Return

Static Function fProcessa(msFil, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL := ""
	Local nW   := 0
	Local cQry := ""

	Local lRet	:= .T.

	Local aFields   := {}
	Local oTable    := Nil
	Local cAliasTmp := ""

	Default cMsg    := ""

	ProcRegua(0)
	For nW := 1 To 12

		IncProc("Processando Registros encontrados na base...")

		msUltDia := Substr( dtos( Ultimodia( stod( cAnoRef + Alltrim( StrZero( nW, 2 ) ) + "01" ) ) ), 7, 2 )

		cQry := GetNextAlias()

		oTable := FWTemporaryTable():New( /*cAlias*/, /*aFields*/)

		aFields := {}

		aAdd(aFields, { "FABRICA"       , "C", 01, 0 })
		aAdd(aFields, { "APLIC_CUST"    , "C", 05, 0 })
		aAdd(aFields, { "CONECT"	    , "C", 03, 0 })
		aAdd(aFields, { "PERIODO"	    , "C", 06, 0 })
		aAdd(aFields, { "APL"	        , "C", 03, 0 })
		aAdd(aFields, { "CTA"	        , "C", 20, 0 })
		aAdd(aFields, { "DESC01"	    , "C", 40, 0 })
		aAdd(aFields, { "AGRUP"	        , "C", 10, 0 })
		aAdd(aFields, { "ITCUS"	        , "C", 03, 0 })
		aAdd(aFields, { "Z29_TIPO"	    , "C", 02, 0 })
		aAdd(aFields, { "CLVL"	        , "C", 09, 0 })
		aAdd(aFields, { "AGGRAT"	    , "C", 04, 0 })
		aAdd(aFields, { "CRIT"	        , "C", 03, 0 })
		aAdd(aFields, { "VALOR"	        , "N", 16, 8 })
		aAdd(aFields, { "MODS"	        , "C", 21, 0 })
		aAdd(aFields, { "CONTRAP"	    , "C", 02, 0 })
		aAdd(aFields, { "DESCR"	        , "C", 50, 0 })
		aAdd(aFields, { "REGRAC"	    , "C", 01, 0 })
		aAdd(aFields, { "RATEIO"	    , "C", 14, 0 })

		oTable:SetFields(aFields)

		oTable:AddIndex("01", {"CTA", "PERIODO", "APLIC_CUST"} )

		oTable:Create()

		cSql := " WITH TAB_A "
		cSql += "     AS (SELECT APL = 'GNA',  "
		cSql += "                QUADRO = 'LT_8840_DEB',  "
		cSql += "                CTA = ZBZ_DEBITO,  "
		cSql += "                CLVL = ZBZ_CLVLDB,  "
		cSql += "                PERIODO = LEFT(ZBZ_DATA, 6),  "
		cSql += "                VALOR = SUM(ZBZ_VALOR) "
		cSql += "         FROM " + RetFullName("ZBZ", cEmpAnt)
		cSql += "         WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
		cSql += "               AND ZBZ_VERSAO = " + ValToSql(cVersao)
		cSql += "               AND ZBZ_REVISA = " + ValToSql(cRevisa)
		cSql += "               AND ZBZ_ANOREF = " + ValToSql(cAnoRef)
		cSql += "               AND ZBZ_DATA BETWEEN " + ValToSql(FirstDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " AND " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " "
		cSql += "               AND ZBZ_LOTE = '008840' "
		cSql += "               AND SUBSTRING(ZBZ_DEBITO, 1, 1) = '6' "
		cSql += "               AND SUBSTRING(ZBZ_DEBITO, 1, 2) <> '62' "
		cSql += "               AND D_E_L_E_T_ = ' ' "
		cSql += "         GROUP BY ZBZ_DEBITO,  "
		cSql += "                  ZBZ_CLVLDB,  "
		cSql += "                  LEFT(ZBZ_DATA, 6) "
		cSql += "         UNION ALL "
		cSql += "         SELECT APL = 'GNA',  "
		cSql += "                QUADRO = 'LT_8840_CRD',  "
		cSql += "                CTA = ZBZ_CREDIT,  "
		cSql += "                CLVL = ZBZ_CLVLCR,  "
		cSql += "                PERIODO = LEFT(ZBZ_DATA, 6),  "
		cSql += "                VALOR = SUM(ZBZ_VALOR) * (-1) "
		cSql += "         FROM " + RetFullName("ZBZ", cEmpAnt)
		cSql += "         WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
		cSql += "               AND ZBZ_VERSAO = " + ValToSql(cVersao)
		cSql += "               AND ZBZ_REVISA = " + ValToSql(cRevisa)
		cSql += "               AND ZBZ_ANOREF = " + ValToSql(cAnoRef)
		cSql += "               AND ZBZ_DATA BETWEEN " + ValToSql(FirstDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " AND " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " "
		cSql += "               AND ZBZ_LOTE = '008840' "
		cSql += "               AND SUBSTRING(ZBZ_CREDIT, 1, 1) = '6' "
		cSql += "               AND SUBSTRING(ZBZ_CREDIT, 1, 2) <> '62' "
		cSql += "               AND D_E_L_E_T_ = ' ' "
		cSql += "         GROUP BY ZBZ_CREDIT,  "
		cSql += "                  ZBZ_CLVLCR,  "
		cSql += "                  LEFT(ZBZ_DATA, 6) "
		cSql += "         UNION ALL "
		cSql += "         SELECT APL = 'GNA',  "
		cSql += "                QUADRO = 'LT_OUTR_DEB',  "
		cSql += "                CTA = ZBZ_DEBITO,  "
		cSql += "                CLVL = ZBZ_CLVLDB,  "
		cSql += "                PERIODO = LEFT(ZBZ_DATA, 6),  "
		cSql += "                VALOR = SUM(ZBZ_VALOR) "
		cSql += "         FROM " + RetFullName("ZBZ", cEmpAnt)
		cSql += "         WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
		cSql += "               AND ZBZ_VERSAO = " + ValToSql(cVersao)
		cSql += "               AND ZBZ_REVISA = " + ValToSql(cRevisa)
		cSql += "               AND ZBZ_ANOREF = " + ValToSql(cAnoRef)
		cSql += "               AND ZBZ_DATA BETWEEN " + ValToSql(FirstDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " AND " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " "
		cSql += "               AND ZBZ_LOTE <> '008840' "
		cSql += "               AND SUBSTRING(ZBZ_DEBITO, 1, 1) = '6' "
		cSql += "               AND SUBSTRING(ZBZ_DEBITO, 1, 2) <> '62' "
		cSql += "               AND D_E_L_E_T_ = ' ' "
		cSql += "         GROUP BY ZBZ_DEBITO,  "
		cSql += "                  ZBZ_CLVLDB,  "
		cSql += "                  LEFT(ZBZ_DATA, 6) "
		cSql += "         UNION ALL "
		cSql += "         SELECT APL = 'GNA',  "
		cSql += "                QUADRO = 'LT_8840_CRD',  "
		cSql += "                CTA = ZBZ_CREDIT,  "
		cSql += "                CLVL = ZBZ_CLVLCR,  "
		cSql += "                PERIODO = LEFT(ZBZ_DATA, 6),  "
		cSql += "                VALOR = SUM(ZBZ_VALOR) * (-1) "
		cSql += "         FROM " + RetFullName("ZBZ", cEmpAnt)
		cSql += "         WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
		cSql += "               AND ZBZ_VERSAO = " + ValToSql(cVersao)
		cSql += "               AND ZBZ_REVISA = " + ValToSql(cRevisa)
		cSql += "               AND ZBZ_ANOREF = " + ValToSql(cAnoRef)
		cSql += "               AND ZBZ_DATA BETWEEN " + ValToSql(FirstDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " AND " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " "
		cSql += "               AND ZBZ_LOTE <> '008840' "
		cSql += "               AND SUBSTRING(ZBZ_CREDIT, 1, 1) = '6' "
		cSql += "               AND SUBSTRING(ZBZ_CREDIT, 1, 2) <> '62' "
		cSql += "               AND D_E_L_E_T_ = ' ' "
		cSql += "         GROUP BY ZBZ_CREDIT,  "
		cSql += "                  ZBZ_CLVLCR,  "
		cSql += "                  LEFT(ZBZ_DATA, 6)), "
		cSql += "     TAB_A_ACUM "
		cSql += "     AS (SELECT PERIODO,  "
		cSql += "                APL,  "
		cSql += "                CTA,  "
		cSql += "                CLVL,  "
		cSql += "                VALOR = ROUND(SUM(VALOR), 2) "
		cSql += "         FROM TAB_A "
		cSql += "         GROUP BY PERIODO,  "
		cSql += "                  APL,  "
		cSql += "                  CTA,  "
		cSql += "                  CLVL "
		cSql += "         HAVING ROUND(SUM(VALOR), 2) <> 0), "
		cSql += "     TAB_B "
		cSql += "     AS (SELECT PERIODO,  "
		cSql += "                APL,  "
		cSql += "                CTA,  "
		cSql += "                DESC01 = CT1_DESC01,  "
		cSql += "                AGRUP = SUBSTRING(CT1_YAGRUP, 1, 10),  "
		cSql += "                ITCUS = CASE "
		cSql += "                            WHEN SUBSTRING(CTH_YCRIT, 1, 3) = 'GCS' "
		cSql += "                            THEN '133' "
		cSql += "                            WHEN SUBSTRING(CTH_YCRIT, 1, 3) = 'MOP' "
		cSql += "                            THEN '146' "
		cSql += "                            WHEN RTRIM(CLVL) IN('3180', '3181', '3183', '3184', '3280') "
		cSql += "                            THEN CTH_YITCUS "
		cSql += "                            WHEN CTA IN('61103001') "
		cSql += "                                 AND RTRIM(CLVL) IN('3103') "
		cSql += "                            THEN '026' "
		cSql += "                            ELSE CT1_YITCUS "
		cSql += "                        END,  "
		cSql += "                CLVL,  "
		cSql += "                AGGRAT = CASE "
		cSql += "                             WHEN RTRIM(SUBSTRING(CTA, 1, 3)) IN('615', '616', '617') "
		cSql += "                                  AND RTRIM(CTA) NOT IN('61601022') "
		cSql += "                             THEN CASE "
		cSql += "                                      WHEN CLVL = 3141 "
		cSql += "                                      THEN 'AC00' "
		cSql += "                                      WHEN SUBSTRING(CLVL, 2, 1) = '1' "
		cSql += "                                      THEN 'AC01' "
		cSql += "                                      WHEN SUBSTRING(CLVL, 2, 1) = '2' "
		cSql += "                                      THEN 'AC05' "
		cSql += "                                      ELSE 'AC00' "
		cSql += "                                  END "
		cSql += "                             ELSE SUBSTRING(CTH_DESC04, 1, 4) "
		cSql += "                         END,  "
		cSql += "                CRIT = SUBSTRING(CTH_YCRIT, 1, 3),  "
		cSql += "                VALOR = SUM(VALOR) "
		cSql += "         FROM TAB_A_ACUM AS TAB "
		cSql += "              INNER JOIN " + RetFullName("CT1", cEmpAnt) + " CT1 ON CT1_FILIAL = '" + xFilial("CT1") + "' "
		cSql += "                                               AND CT1_CONTA = CTA "
		cSql += "                                               AND CT1.D_E_L_E_T_ = ' ' "
		cSql += "              INNER JOIN " + RetFullName("CTH", cEmpAnt) + " CTH ON CTH_FILIAL = '" + xFilial("CTH") + "' "
		cSql += "                                               AND CTH_CLVL = CLVL "
		cSql += "                                               AND CTH_YAPLCT = 'S' "
		cSql += "                                               AND CTH.D_E_L_E_T_ = ' ' "
		cSql += "         GROUP BY PERIODO,  "
		cSql += "                  APL,  "
		cSql += "                  CTA,  "
		cSql += "                  CT1_DESC01,  "
		cSql += "                  CT1_YITCUS,  "
		cSql += "                  SUBSTRING(CT1_YAGRUP, 1, 10),  "
		cSql += "                  CLVL,  "
		cSql += "                  SUBSTRING(CTH_DESC04, 1, 4),  "
		cSql += "                  CTH_YITCUS,  "
		cSql += "                  SUBSTRING(CTH_YCRIT, 1, 3)), "
		cSql += "     TAB_C "
		cSql += "     AS (SELECT PERIODO,  "
		cSql += "                APL,  "
		cSql += "                CTA,  "
		cSql += "                DESC01,  "
		cSql += "                AGRUP,  "
		cSql += "                ITCUS,  "
		cSql += "                Z29_TIPO,  "
		cSql += "                CLVL,  "
		cSql += "                AGGRAT = CASE "
		cSql += "                             WHEN ITCUS IN('033') "
		cSql += "                                  AND AGGRAT IN('E3', 'E4') "
		cSql += "                                  AND CRIT IN('E03', 'E04') "
		cSql += "                             THEN 'AC01' "
		cSql += "                             WHEN ITCUS IN('130') "
		cSql += "                                  AND CRIT IN('E03', 'E04') "
		cSql += "                             THEN SUBSTRING(CRIT, 1, 1) + SUBSTRING(CRIT, 3, 1) "
		cSql += "                             ELSE AGGRAT "
		cSql += "                         END,  "
		cSql += "                CRIT = CASE "
		cSql += "                           WHEN ITCUS IN('033') "
		cSql += "                                AND AGGRAT IN('E3', 'E4') "
		cSql += "                                AND CRIT IN('E03', 'E04') "
		cSql += "                           THEN 'TOT' "
		cSql += "                           ELSE CRIT "
		cSql += "                       END,  "
		cSql += "                VALOR,  "
		cSql += "                MODS = CASE "
		cSql += "                           WHEN RTRIM(APL) = 'GA' "
		cSql += "                           THEN 'DIRETA' "
		cSql += "                           WHEN CTA IN('61103001') "
		cSql += "                                AND RTRIM(CLVL) IN('3103') "
		cSql += "                           THEN 'MOD1ATM' "
		cSql += "                           WHEN SUBSTRING(CLVL, 2, 1) = '8' "
		cSql += "                                AND Z29_TIPO = 'CV' "
		cSql += "                                AND Z29_COD_IT = '004' "
		cSql += "                           THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + 'E' + RTRIM(CLVL) + SPACE(7) "
		cSql += "                           WHEN SUBSTRING(CLVL, 2, 1) = '8' "
		cSql += "                                AND Z29_TIPO = 'CV' "
		cSql += "                                AND Z29_COD_IT <> '004' "
		cSql += "                           THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + 'V' + RTRIM(CLVL) + SPACE(7) "
		cSql += "                           WHEN SUBSTRING(CLVL, 2, 1) = '8' "
		cSql += "                                AND Z29_TIPO = 'CF' "
		cSql += "                           THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + 'F' + RTRIM(CLVL) + RTRIM(SUBSTRING(AGRUP, 1, 6)) "
		cSql += "                           WHEN RTRIM(CLVL) IN('6112', '6208') "
		cSql += "                           THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + SUBSTRING(CRIT, 1, 3) + SPACE(7) "
		cSql += "                           WHEN CTA IN('61601022') "
		cSql += "                           THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + RTRIM(SUBSTRING(AGRUP, 1, 10)) + SUBSTRING(CRIT, 1, 3) "
		cSql += "                           WHEN RTRIM(CLVL) IN('3180', '3181', '3183', '3184', '3280') "
		cSql += "                           THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + SUBSTRING(CRIT, 1, 3) "
		cSql += "                           WHEN RTRIM(CLVL) IN('3299') "
		cSql += "                           THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + SUBSTRING(CRIT, 1, 3) "
		cSql += "                           WHEN RTRIM(SUBSTRING(AGRUP, 1, 10)) IN('612', '613', '614') "
		cSql += "                           THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + RTRIM(SUBSTRING(AGRUP, 1, 10)) + SUBSTRING(CRIT, 1, 3) "
		cSql += "                           ELSE 'MOD' + SUBSTRING(CLVL, 2, 1) + RTRIM(SUBSTRING(AGRUP, 1, 10)) "
		cSql += "                       END,  "
		cSql += "                CONTRAP = CASE "
		cSql += "                              WHEN RTRIM(CLVL) IN('3801') "
		cSql += "                              THEN 'MP' "
		cSql += "                              WHEN RTRIM(CLVL) IN('3802', '3803') "
		cSql += "                              THEN 'PI' "
		cSql += "                              WHEN RTRIM(CLVL) IN('3804', '3805') "
		cSql += "                              THEN 'PA' "
		cSql += "                              WHEN((RTRIM(SUBSTRING(AGRUP, 1, 10)) NOT IN('615', '616', '617') "
		cSql += "                                    AND SUBSTRING(CRIT, 1, 3) IN('E03', 'E04', 'R01', 'R02', 'R09') "
		cSql += "                                    AND B.ITCUS NOT IN('033')) "
		cSql += "                                   OR (B.ITCUS IN('130') "
		cSql += "                                       AND SUBSTRING(CRIT, 1, 3) IN('E03', 'E04', 'R01', 'R02', 'R09'))) "
		cSql += "                              THEN 'PA' "
		cSql += "                              WHEN SUBSTRING(CTA, 1, 5) IN('61104', '61110') "
		cSql += "                              THEN 'PA' "
		cSql += "                              ELSE 'PP' "
		cSql += "                          END "
		cSql += "         FROM TAB_B B "
		cSql += "              LEFT JOIN " + RetFullName("Z29", cEmpAnt) + " Z29 ON Z29_COD_IT = B.ITCUS "
		cSql += "                                              AND Z29.D_E_L_E_T_ = ' '), "
		cSql += "     TABFINAL "
		cSql += "     AS (SELECT C.*,  "
		cSql += "                DESCR = ISNULL(SUBSTRING(B1_DESC, 1, 50), ' '),  "
		cSql += "                REGRAC = ISNULL(B1_YREGRAC, ' '),  "
		cSql += "                RATEIO = CASE "
		cSql += "                             WHEN B1_YREGRAC = '1' "
		cSql += "                             THEN 'CAP. PRODUTIVA' "
		cSql += "                             WHEN B1_YREGRAC = '2' "
		cSql += "                             THEN 'PESO SECO' "
		cSql += "                             WHEN B1_YREGRAC = '3' "
		cSql += "                             THEN 'M2' "
		cSql += "                             ELSE 'INDEFINIDO' "
		cSql += "                         END "
		cSql += "         FROM TAB_C C "
		cSql += "              LEFT JOIN " + RetFullName("SB1", cEmpAnt) + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
		cSql += "                                              AND B1_COD = MODS "
		cSql += "                                              AND SB1.D_E_L_E_T_ = ' ' "
		cSql += "         WHERE Z29_TIPO = 'CF') "
		cSql += "     SELECT FABRICA = SUBSTRING(MODS, 4, 1),  "
		cSql += "            APLIC_CUST = CASE "
		cSql += "                              WHEN CTA = '61601022' "
		cSql += "                              THEN 'RPV' "
		cSql += "                              WHEN CRIT = 'GCS' "
		cSql += "                              THEN 'GCS' "
		cSql += "                              WHEN CRIT = 'MOP' "
		cSql += "                              THEN 'MOP' "
		cSql += "                              WHEN ITCUS = '125' "
		cSql += "                              THEN 'DEPRE' "
		cSql += "                              WHEN ITCUS = '145' "
		cSql += "                              THEN 'ALUGU' "
		cSql += "                              WHEN ITCUS = '033' "
		cSql += "                              THEN 'COMBU' "
		cSql += "                              ELSE 'GERAL' "
		cSql += "                          END,  "
		cSql += "            CONECT = CASE "
		// exceção
		cSql += "                         WHEN CONTRAP = 'PP' "
		cSql += "                              AND RTRIM(AGGRAT) IN('AC01') "
		cSql += "                              AND RTRIM(CRIT) IN('L01') "
		cSql += "                              AND RTRIM(ITCUS) IN('130') "
		cSql += "                         THEN '209' "
		cSql += "                         WHEN CONTRAP = 'PP' "
		cSql += "                              AND RTRIM(AGGRAT) IN('L1L2', 'L3') "
		cSql += "                         THEN '209' "
		cSql += "                         WHEN CONTRAP = 'PP' "
		cSql += "                              AND RTRIM(AGGRAT) IN('AC01', 'AC05') "
		cSql += "                         THEN '222' "
		cSql += "                         WHEN CONTRAP = 'PP' "
		cSql += "                              AND RTRIM(AGGRAT) IN('AC00') "
		cSql += "                         THEN '233' "
		cSql += "                         WHEN CONTRAP = 'PA' "
		cSql += "                              AND RTRIM(AGGRAT) IN('E3', 'E4', 'R1', 'R2') "
		cSql += "                         THEN '209' "
		cSql += "                         ELSE '' "
		cSql += "                     END,  "
		cSql += "            PERIODO,  "
		cSql += "            APL,  "
		cSql += "            CTA,  "
		cSql += "            DESC01,  "
		cSql += "            AGRUP,  "
		cSql += "            ITCUS,  "
		cSql += "            Z29_TIPO,  "
		cSql += "            CLVL,  "
		cSql += "            AGGRAT = CASE "
		// exceção
		cSql += "                         WHEN CONTRAP = 'PP' "
		cSql += "                              AND RTRIM(AGGRAT) IN('AC01') "
		cSql += "                              AND RTRIM(CRIT) IN('L01') "
		cSql += "                              AND RTRIM(ITCUS) IN('130') "
		cSql += "                         THEN 'L1L2' "
		cSql += "                         ELSE AGGRAT "
		cSql += "                     END,  "
		cSql += "            CRIT,  "
		cSql += "            VALOR,  "
		cSql += "            MODS,  "
		cSql += "            CONTRAP,  "
		cSql += "            DESCR,  "
		cSql += "            REGRAC,  "
		cSql += "            RATEIO "
		cSql += "     FROM TABFINAL "

		TcQuery cSQL New Alias (cQry)

		ProcRegua(0)
		While !(cQry)->(Eof())

			IncProc("Processando Registros encontrados na base...")

			cAliasTmp := oTable:GetAlias()

			(cAliasTmp)->(DBAppend())
			(cAliasTmp)->FABRICA		:= (cQry)->FABRICA
			(cAliasTmp)->APLIC_CUST     := (cQry)->APLIC_CUST
			(cAliasTmp)->CONECT         := (cQry)->CONECT
			(cAliasTmp)->PERIODO        := (cQry)->PERIODO
			(cAliasTmp)->APL            := (cQry)->APL
			(cAliasTmp)->CTA            := (cQry)->CTA
			(cAliasTmp)->DESC01         := (cQry)->DESC01
			(cAliasTmp)->AGRUP          := (cQry)->AGRUP
			(cAliasTmp)->ITCUS          := (cQry)->ITCUS
			(cAliasTmp)->Z29_TIPO       := (cQry)->Z29_TIPO
			(cAliasTmp)->CLVL           := (cQry)->CLVL
			(cAliasTmp)->AGGRAT         := (cQry)->AGGRAT
			(cAliasTmp)->CRIT           := (cQry)->CRIT
			(cAliasTmp)->VALOR          := (cQry)->VALOR
			(cAliasTmp)->MODS           := (cQry)->MODS
			(cAliasTmp)->CONTRAP        := (cQry)->CONTRAP
			(cAliasTmp)->DESCR          := (cQry)->DESCR
			(cAliasTmp)->REGRAC         := (cQry)->REGRAC
			(cAliasTmp)->RATEIO         := (cQry)->RATEIO
			(cAliasTmp)->(DBCommit())

			(cQry)->(DbSkip())

		EndDo

		(cQry)->(DbCloseArea())

		cQry := GetNextAlias()

		cSql := " WITH ITCUSF "
		cSql += " AS (SELECT Z29_TIPO TIPO,  "
		cSql += "         Z29_COD_IT ITCUS,  "
		cSql += "         Z29_DRESUM DESCR "
		cSql += "     FROM " + RetFullName("Z29", cEmpAnt) + " Z29 "
		cSql += "     WHERE Z29_FILIAL = '" + xFilial("Z29") + "' "
		cSql += "         AND Z29_TIPO = 'CF' "
		cSql += "         AND D_E_L_E_T_ = ' '), "
		cSql += " CFPROCESS01 "
		cSql += " AS (SELECT DTREF = ZO4.ZO4_DATARF,  "
		cSql += "         TPPROD = SB1.B1_TIPO,  "
		cSql += "         PRODUT = ZO4.ZO4_PRODUT,  "
		cSql += "         LINHA = ZO4.ZO4_LINHA,  "
		cSql += "         LNH209 = CASE "
		cSql += "                         WHEN SB1.B1_TIPO = 'PP' "
		cSql += "                             AND ZO4.ZO4_LINHA IN('L01', 'L02') "
		cSql += "                         THEN 'L1L2' "
		cSql += "                         WHEN SB1.B1_TIPO = 'PP' "
		cSql += "                             AND ZO4.ZO4_LINHA IN('L03') "
		cSql += "                         THEN LEFT(ZO4.ZO4_LINHA, 1) + RIGHT(ZO4.ZO4_LINHA, 1) "
		cSql += "                         WHEN SB1.B1_TIPO = 'PA' "
		cSql += "                             AND ZO4.ZO4_LINHA IN('E03', 'E04', 'R01', 'R02', 'R09') "
		cSql += "                         THEN LEFT(ZO4.ZO4_LINHA, 1) + RIGHT(ZO4.ZO4_LINHA, 1) "
		cSql += "                         ELSE '' "
		cSql += "                     END,  "
		cSql += "         LNH222 = CASE "
		cSql += "                         WHEN SB1.B1_TIPO = 'PP' "
		cSql += "                             AND ZO4.ZO4_LINHA IN('L01', 'L02', 'L03') "
		cSql += "                         THEN 'AC01' "
		cSql += "                         WHEN SB1.B1_TIPO = 'PP' "
		cSql += "                             AND ZO4.ZO4_LINHA IN('L04', 'L05') "
		cSql += "                         THEN 'AC05' "
		cSql += "                         ELSE '' "
		cSql += "                     END,  "
		cSql += "         LNH233 = CASE "
		cSql += "                         WHEN SB1.B1_TIPO = 'PP' "
		cSql += "                             AND ZO4.ZO4_LINHA IN('L01', 'L02', 'L03', 'L04', 'L05') "
		cSql += "                         THEN 'AC00' "
		cSql += "                         ELSE '' "
		cSql += "                     END,  "
		cSql += "         PSECO = ZO4.ZO4_PSECO,  "
		cSql += "         CUS200 = ZO4.ZO4_QTDRAC,  "
		cSql += "         CUS201 = ZO4.ZO4_CAPACI,  "
		cSql += "         CUS202 = ZO4.ZO4_QTDRAC / ZO4.ZO4_CAPACI,  "
		cSql += "         CUS203 = "
		cSql += "     ( "
		cSql += "         SELECT SUM(XXX.ZO4_QTDRAC) "
		cSql += "         FROM " + RetFullName("ZO4", cEmpAnt) + " XXX "
		cSql += "             INNER JOIN " + RetFullName("SB1", cEmpAnt) + " QQQ ON QQQ.B1_COD = XXX.ZO4_PRODUT "
		cSql += "                                     AND QQQ.B1_TIPO = SB1.B1_TIPO "
		cSql += "                                     AND QQQ.D_E_L_E_T_ = ' ' "
		cSql += "         WHERE XXX.ZO4_FILIAL = ZO4.ZO4_FILIAL "
		cSql += "             AND XXX.ZO4_VERSAO = ZO4.ZO4_VERSAO "
		cSql += "             AND XXX.ZO4_REVISA = ZO4.ZO4_REVISA "
		cSql += "             AND XXX.ZO4_ANOREF = ZO4.ZO4_ANOREF "
		cSql += "             AND XXX.ZO4_DATARF = ZO4.ZO4_DATARF "
		cSql += "             AND XXX.ZO4_LINHA = ZO4.ZO4_LINHA "
		cSql += "             AND XXX.D_E_L_E_T_ = ' ' "
		cSql += "     ) "
		cSql += "     FROM " + RetFullName("ZO4", cEmpAnt) + " ZO4 "
		cSql += "         INNER JOIN " + RetFullName("SB1", cEmpAnt) + " SB1 ON SB1.B1_COD = ZO4.ZO4_PRODUT "
		cSql += "                                 AND SB1.D_E_L_E_T_ = ' ' "
		cSql += "     WHERE ZO4.ZO4_FILIAL = '" + xFilial("ZO4") + "' "
		cSql += "         AND ZO4_VERSAO = " + ValToSql(cVersao)
		cSql += "         AND ZO4_REVISA = " + ValToSql(cRevisa)
		cSql += "         AND ZO4_ANOREF = " + ValToSql(cAnoRef)
		cSql += "         AND ZO4.ZO4_DATARF = " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef)))
		cSql += "         AND ZO4.D_E_L_E_T_ = ' '), "
		cSql += " CFPROCESS02 "
		cSql += " AS (SELECT *,  "
		cSql += "         CUS204 = "
		cSql += "     ( "
		cSql += "         SELECT SUM(XXX.CUS202) "
		cSql += "         FROM CFPROCESS01 XXX "
		cSql += "         WHERE XXX.DTREF = PRC01.DTREF "
		cSql += "             AND XXX.LINHA = PRC01.LINHA "
		cSql += "             AND XXX.TPPROD = PRC01.TPPROD "
		cSql += "     ),  "
		cSql += "         CUS205 = " + msUltDia + " / "
		cSql += "     ( "
		cSql += "         SELECT SUM(XXX.CUS202) "
		cSql += "         FROM CFPROCESS01 XXX "
		cSql += "         WHERE XXX.DTREF = PRC01.DTREF "
		cSql += "             AND XXX.LINHA = PRC01.LINHA "
		cSql += "             AND XXX.TPPROD = PRC01.TPPROD "
		cSql += "     ) * CUS202,  "
		cSql += "         CUS206 = CUS201 * (" + msUltDia + " / "
		cSql += "     ( "
		cSql += "         SELECT SUM(XXX.CUS202) "
		cSql += "         FROM CFPROCESS01 XXX "
		cSql += "         WHERE XXX.DTREF = PRC01.DTREF "
		cSql += "             AND XXX.LINHA = PRC01.LINHA "
		cSql += "             AND XXX.TPPROD = PRC01.TPPROD "
		cSql += "     ) * CUS202),  "
		cSql += "         CUS207 = PSECO,  "
		cSql += "         CUS208 = (CUS201 * (" + msUltDia + " / "
		cSql += "     ( "
		cSql += "         SELECT SUM(XXX.CUS202) "
		cSql += "         FROM CFPROCESS01 XXX "
		cSql += "         WHERE XXX.DTREF = PRC01.DTREF "
		cSql += "             AND XXX.LINHA = PRC01.LINHA "
		cSql += "             AND XXX.TPPROD = PRC01.TPPROD "
		cSql += "     ) * CUS202)) * PSECO "
		cSql += "     FROM CFPROCESS01 PRC01), "
		cSql += " CFPROCESS03 "
		cSql += " AS (SELECT *,  "
		cSql += "         CUS209 = ISNULL( "
		cSql += "     ( "
		cSql += "         SELECT SUM(XXX.CUS208) "
		cSql += "         FROM CFPROCESS02 XXX "
		cSql += "         WHERE XXX.DTREF = PRC02.DTREF "
		cSql += "             AND XXX.LNH209 = PRC02.LNH209 "
		cSql += "             AND XXX.TPPROD = PRC02.TPPROD "
		cSql += "             AND XXX.LNH209 <> '' "
		cSql += "     ), 0) "
		cSql += "     FROM CFPROCESS02 PRC02), "
		cSql += " CFPROCESS04 "
		cSql += " AS (SELECT ITCF.*,  "
		cSql += "         PRC03.*,  "
		cSql += "         CUS222 = ISNULL( "
		cSql += "     ( "
		cSql += "         SELECT SUM(XXX.CUS208) "
		cSql += "         FROM CFPROCESS02 XXX "
		cSql += "         WHERE XXX.DTREF = PRC03.DTREF "
		cSql += "             AND XXX.LNH222 = PRC03.LNH222 "
		cSql += "             AND XXX.TPPROD = PRC03.TPPROD "
		cSql += "             AND XXX.LNH222 <> '' "
		cSql += "     ), 0),  "
		cSql += "         CUS233 = ISNULL( "
		cSql += "     ( "
		cSql += "         SELECT SUM(XXX.CUS208) "
		cSql += "         FROM CFPROCESS02 XXX "
		cSql += "         WHERE XXX.DTREF = PRC03.DTREF "
		cSql += "             AND XXX.LNH233 = PRC03.LNH233 "
		cSql += "             AND XXX.TPPROD = PRC03.TPPROD "
		cSql += "             AND XXX.LNH233 <> '' "
		cSql += "     ), 0),  "
		cSql += "         CUS210 = ISNULL( "
		cSql += "     ( "
		cSql += "         SELECT SUM(VALOR) "
		cSql += "         FROM " + oTable:GetRealName() + " JJJ "
		cSql += "         WHERE JJJ.CONECT = '209' "
		cSql += "             AND JJJ.CONTRAP = PRC03.TPPROD "
		cSql += "             AND JJJ.AGGRAT = PRC03.LNH209 "
		cSql += "             AND JJJ.ITCUS = ITCF.ITCUS "
		cSql += "     ), 0),  "
		cSql += "         CUS211 = ISNULL( "
		cSql += "     ( "
		cSql += "         SELECT SUM(VALOR) "
		cSql += "         FROM " + oTable:GetRealName() + " JJJ "
		cSql += "         WHERE JJJ.CONECT = '222' "
		cSql += "             AND JJJ.CONTRAP = PRC03.TPPROD "
		cSql += "             AND JJJ.AGGRAT = PRC03.LNH222 "
		cSql += "             AND JJJ.ITCUS = ITCF.ITCUS "
		cSql += "     ), 0),  "
		cSql += "         CUS234 = ISNULL( "
		cSql += "     ( "
		cSql += "         SELECT SUM(VALOR) "
		cSql += "         FROM " + oTable:GetRealName() + " JJJ "
		cSql += "         WHERE JJJ.CONECT = '233' "
		cSql += "             AND JJJ.CONTRAP = PRC03.TPPROD "
		cSql += "             AND JJJ.AGGRAT = PRC03.LNH233 "
		cSql += "             AND JJJ.ITCUS = ITCF.ITCUS "
		cSql += "     ), 0) "
		cSql += "     FROM CFPROCESS03 PRC03 "
		cSql += "         INNER JOIN ITCUSF ITCF ON 1 = 1), "
		cSql += " CFPROCESS05 "
		cSql += " AS (SELECT *,  "
		cSql += "         CUS212 = CASE "
		cSql += "                         WHEN CUS209 <> 0 "
		cSql += "                         THEN CUS208 / CUS209 * CUS210 "
		cSql += "                         ELSE 0 "
		cSql += "                     END,  "
		cSql += "         CUS213 = CASE "
		cSql += "                         WHEN CUS222 <> 0 "
		cSql += "                         THEN CUS208 / CUS222 * CUS211 "
		cSql += "                         ELSE 0 "
		cSql += "                     END,  "
		cSql += "         CUS235 = CASE "
		cSql += "                         WHEN CUS233 <> 0 "
		cSql += "                         THEN CUS208 / CUS233 * CUS234 "
		cSql += "                         ELSE 0 "
		cSql += "                     END "
		cSql += "     FROM CFPROCESS04), "
		cSql += " CFPROCESS06 "
		cSql += " AS (SELECT *,  "
		cSql += "         CUS214 = CUS212 / CUS206,  "
		cSql += "         CUS215 = CUS213 / CUS206,  "
		cSql += "         CUS236 = CUS235 / CUS206 "
		cSql += "     FROM CFPROCESS05), "
		cSql += " CFPROCESS07 "
		cSql += " AS (SELECT *,  "
		cSql += "         CUS216 = CUS214 + CUS215 + CUS236,  "
		cSql += "         CUS217 = CUS212 + CUS213 + CUS235 "
		cSql += "     FROM CFPROCESS06) "
		cSql += " SELECT *,  "
		cSql += "     CUS223 = CUS206,  "
		cSql += "     CUS224 = CUS217 "
		cSql += " FROM CFPROCESS07 "
		cSql += " WHERE CUS217 <> 0 "
		cSql += " ORDER BY LINHA,  "
		cSql += "         PRODUT,  "
		cSql += "         ITCUS "

		TcQuery cSQL New Alias (cQry)

		ProcRegua(0)
		While !(cQry)->(Eof())

			IncProc("Processando Registros encontrados na base...")

			Reclock("ZO8", .T.)
			ZO8->ZO8_FILIAL  := xFilial("ZO8")
			ZO8->ZO8_VERSAO  := cVersao
			ZO8->ZO8_REVISA  := cRevisa
			ZO8->ZO8_ANOREF  := cAnoRef
			ZO8->ZO8_TPCUS	 := (cQry)->TIPO	
			ZO8->ZO8_ITCUS   := (cQry)->ITCUS 
			ZO8->ZO8_DTREF   := STOD((cQry)->DTREF) 
			ZO8->ZO8_TPPROD  := (cQry)->TPPROD
			ZO8->ZO8_PRODUT  := (cQry)->PRODUT
			ZO8->ZO8_LINHA   := (cQry)->LINHA 
			ZO8->ZO8_LNH209  := (cQry)->LNH209
			ZO8->ZO8_LNH222  := (cQry)->LNH222
			ZO8->ZO8_LNH233  := (cQry)->LNH233
			ZO8->ZO8_PSECO   := (cQry)->PSECO 

			ZO8->ZO8_CUS200  := (cQry)->CUS200
			ZO8->ZO8_CUS201  := (cQry)->CUS201
			ZO8->ZO8_CUS202  := (cQry)->CUS202
			ZO8->ZO8_CUS203  := (cQry)->CUS203
			ZO8->ZO8_CUS204  := (cQry)->CUS204
			ZO8->ZO8_CUS205  := (cQry)->CUS205
			ZO8->ZO8_CUS206  := (cQry)->CUS206
			ZO8->ZO8_CUS207  := (cQry)->CUS207
			ZO8->ZO8_CUS208  := (cQry)->CUS208
			ZO8->ZO8_CUS210  := (cQry)->CUS210
			ZO8->ZO8_CUS211  := (cQry)->CUS211
			ZO8->ZO8_CUS234  := (cQry)->CUS234
			ZO8->ZO8_CUS212  := (cQry)->CUS212
			ZO8->ZO8_CUS213  := (cQry)->CUS213
			ZO8->ZO8_CUS235  := (cQry)->CUS235
			ZO8->ZO8_CUS214  := (cQry)->CUS214
			ZO8->ZO8_CUS215  := (cQry)->CUS215
			ZO8->ZO8_CUS236  := (cQry)->CUS236
			ZO8->ZO8_CUS216  := (cQry)->CUS216
			ZO8->ZO8_CUS217  := (cQry)->CUS217
			ZO8->ZO8_CUS223  := (cQry)->CUS223
			ZO8->ZO8_CUS224  := (cQry)->CUS224
			ZO8->(MsUnlock())

			(cQry)->(DbSkip())

		EndDo

		(cQry)->(DbCloseArea())

		oTable:Delete()

	Next nW

	xVerRet := lRet 

Return(lRet)

Static Function fProcC1(msFil, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL := ""
	Local nW   := 0
	Local cQry := ""

	Local lRet	:= .T.

	Default cMsg    := ""

	ProcRegua(0)
	For nW := 1 To 12

		IncProc("Processando Registros encontrados na base...")

		cQry := GetNextAlias()

		cSql := " WITH PROCESSC1 "
		cSql += "      AS (SELECT Z47_PRODUT PRODUT, "
		cSql += "                 Z47_QTDM" + StrZero(nW, 2) + " QTDMES, "
		cSql += "                 GG_COMP COMP, "
		cSql += "                 GG_FIM DTFIM "
		cSql += "          FROM " + RetFullName("Z47", cEmpAnt) + " Z47(NOLOCK) "
		cSql += "               INNER JOIN " + RetFullName("SGG", cEmpAnt) + " SGG(NOLOCK) ON GG_FILIAL = '" + xFilial("SGG") + "' "
		cSql += "                                                AND GG_COD = Z47_PRODUT "
		cSql += "                                                AND SUBSTRING(GG_COMP, 1, 2) = 'C1' "
		cSql += "                                                AND SUBSTRING(GG_FIM, 1, 4) = Z47_ANOREF "
		cSql += "                                                AND SUBSTRING(GG_FIM, 5, 2) = '01' "
		cSql += "                                                AND SUBSTRING(GG_FIM, 5, 4) <> '0101' "
		cSql += "                                                AND SGG.D_E_L_E_T_ = ' ' "
		cSql += "          WHERE Z47_FILIAL = '" + xFilial("Z47") + "' "
		cSql += "                AND Z47_VERSAO = " + ValToSql(cVersao)
		cSql += "                AND Z47_REVISA = " + ValToSql(cRevisa)
		cSql += "                AND Z47_ANOREF = " + ValToSql(cAnoRef)
		cSql += "                AND SUBSTRING(Z47_PRODUT, 1, 2) IN('B9', 'BO', 'C6') "
		cSql += "                AND Z47.D_E_L_E_T_ = ' ') "
		cSql += "      SELECT ZO8_FILIAL, "
		cSql += "             ZO8_VERSAO, "
		cSql += "             ZO8_REVISA, "
		cSql += "             ZO8_ANOREF, "
		cSql += "             TPPROD = 'PP', "
		cSql += "             ZO8_TPCUS, "
		cSql += "             ZO8_ITCUS, "
		cSql += "             PRODUTO = SUBSTRING(PRODUT, 1, 7) + '        ', "
		cSql += "             ZO8_DTREF, "
		cSql += "             ZO8_CUS223 = QTDMES, "
		cSql += "             ZO8_CUS224 = QTDMES * (ZO8_CUS224 / ZO8_CUS223) "
		cSql += "      FROM " + RetFullName("ZO8", cEmpAnt) + " ZO8(NOLOCK) "
		cSql += "           INNER JOIN PROCESSC1 PC1 ON SUBSTRING(PC1.COMP, 1, 7) = SUBSTRING(ZO8.ZO8_PRODUT, 1, 7) "
		cSql += "                                       AND PC1.DTFIM = ZO8.ZO8_DTREF "
		cSql += "      WHERE ZO8_FILIAL = '" + xFilial("ZO8") + "' "
		cSql += "            AND ZO8_VERSAO = " + ValToSql(cVersao)
		cSql += "            AND ZO8_REVISA = " + ValToSql(cRevisa)
		cSql += "            AND ZO8_ANOREF = " + ValToSql(cAnoRef)
		cSql += "            AND ZO8_DTREF = " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef)))
		cSql += "            AND ZO8_TPCUS = 'CF' "
		cSql += "            AND ZO8.D_E_L_E_T_ = ' ' "

		TcQuery cSQL New Alias (cQry)

		ProcRegua(0)
		While !(cQry)->(Eof())

			IncProc("Processando Registros encontrados na base...")

			Reclock("ZO8", .T.)
			ZO8->ZO8_FILIAL  := xFilial("ZO8")
			ZO8->ZO8_VERSAO  := cVersao
			ZO8->ZO8_REVISA  := cRevisa
			ZO8->ZO8_ANOREF  := cAnoRef
			ZO8->ZO8_TPPROD	 := (cQry)->TPPROD
			ZO8->ZO8_TPCUS	 := (cQry)->ZO8_TPCUS
			ZO8->ZO8_ITCUS   := (cQry)->ZO8_ITCUS
			ZO8->ZO8_PRODUT  := (cQry)->PRODUTO
			ZO8->ZO8_DTREF   := STOD((cQry)->ZO8_DTREF)
			ZO8->ZO8_CUS223  := (cQry)->ZO8_CUS223
			ZO8->ZO8_CUS224  := (cQry)->ZO8_CUS224
			ZO8->(MsUnlock())

			(cQry)->(DbSkip())

		End

		(cQry)->(DbCloseArea())

	Next nW

	xVerRet := lRet 

Return(lRet)

Static Function ExistThenD(msFil, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL  := ""
	Local cQry  := ""
	Local lPerg := .T.
	Local lRet  := .T.

	Default cMsg := ""

	cQry := GetNextAlias()

	cSql := " SELECT R_E_C_N_O_ RECNO "
	cSql += " FROM " + RetFullName("ZO8", cEmpAnt) + " ZO8 (NOLOCK) "
	cSql += " WHERE ZO8_FILIAL = '" + xFilial("ZO8") + "' "
	cSql += "       AND ZO8_VERSAO = " + ValToSql(cVersao)
	cSql += "       AND ZO8_REVISA = " + ValToSql(cRevisa)
	cSql += "       AND ZO8_ANOREF = " + ValToSql(cAnoRef)
	cSql += "       AND ZO8_TPCUS = 'CF' "
	cSql += "       AND ZO8.D_E_L_E_T_ = ' ' "

	TcQuery cSQL New Alias (cQry)

	ProcRegua(0)
	While !(cQry)->(Eof())

		IncProc("Apagando Registros encontrados na base...")

		If lPerg

			If MsgYesNo("Já existem dados para o tempo orçamentário. Deseja continuar?" + CRLF + CRLF + "Caso clique em sim esses dados serão apagados e gerados novos!", "Empresa: [" + cEmpAnt + "]  - ATENÇÃO")

				lRet := .T.

			Else

				lRet := .F.

				Exit

			EndIf

			lPerg := .F.

		EndIf

		ZO8->(DBGoTo((cQry)->RECNO))

		If !ZO8->(EOF())

			Reclock("ZO8", .F.)
			ZO8->(DBDelete())
			ZO8->(MsUnlock())

		EndIf

		(cQry)->(DbSkip())

	End

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return(lRet)
