#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA948
@author Marcos Alberto Soprani
@since 09/10/17
@version 1.0
@description Extração do OrcaFinal para excel com Item de Custo conforme RAC   
@type function
/*/

User Function BIA948()

	Processa({|| Rpt948Det()})

Return

Static Function Rpt948Det()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F.
	Local msEnter       := CHR(13) + CHR(10)

	local nRegAtu    := 0
	local cCab1Fon   := 'Calibri' 
	local cCab1TamF  := 8   
	local cCab1CorF  := '#FFFFFF'
	local cCab1Fun   := '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'

	local cEmpresa   := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML    := UPPER(Alltrim(FunName())) + "_" + ALLTrim( DTOS(DATE()) + "_" + StrTran( time(),':',''))
	Local nx

	private cDirDest := "c:\temp\"

	Private idVersao    := space(010)
	Private idRevisa    := space(003) 
	Private idAnoRef    := space(004) 
	Private msrhEnter   := CHR(13) + CHR(10)
	Private xkContinua  := .T.

	AADD(aSays, OemToAnsi("Rotina para Extração do OrcaFinal para excel com Item de Custo conforme RAC!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
	AADD(aSays, OemToAnsi(""))   
	AADD(aSays, OemToAnsi("Deseja Continuar?"))   

	AADD(aButtons, { 5,.T.,{|| BIA948B() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Extração OrcaFinal c/ ItCus'), aSays, aButtons ,,,500)

	If lConfirm

		oExcel := ARSexcel():New()

		oExcel:AddPlanilha("Relatorio", {20, 35, 70, 70, 70, 70, 55, 70, 100, 35, 70, 70, 70, 70, 70, 70, 70, 70, 170, 170, 70, 70, 70, 70, 170}, 6)

		oExcel:AddLinha(20)
		oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2, 23 ) 
		oExcel:AddLinha(15)
		oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2, 23 ) 
		oExcel:AddLinha(15)
		oExcel:AddLinha(20)
		oExcel:AddCelula("OrcaFinal Consolidado", 0, 'L', cFonte1, nTamFont1, cCorFont1, .T., , cCorFun1, , , , , .T., 2, 23 )  

		oExcel:AddLinha(20)
		oExcel:AddLinha(12) 
		oExcel:AddCelula()
		oExcel:AddCelula("EMPR      "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("VERSAO    "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("REVISA    "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("ANOREF    "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("ORIPRC    "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("ORGLAN    "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("DTREF     "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("KEYREG    "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("DC        "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("CONTA     "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("CLVL      "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("ITCTA     "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("APLICACAO "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("DAPLIC    "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("DRIVER    "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("DDRIVER   "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("VALOR     "         , 0, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("HIST      "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("YHIST     "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("SI        "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("MODS      "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("CONTRAP   "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("ITCUS     "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("DITCUS    "         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)

		msCompany := {}

		RZ004 := " SELECT Z35_EMP "
		RZ004 += "   FROM " + RetSqlName("Z35") + " "
		RZ004 += "  WHERE D_E_L_E_T_ = ' ' "
		RZ004 += "    AND Z35_TIPO = '01' "
		RZ004 += "    AND Z35_FIL = '01' "		
		RZcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,RZ004),'RZ04',.F.,.T.)
		dbSelectArea("RZ04")
		dbGoTop()
		While !Eof()

			AAdd(msCompany, RZ04->Z35_EMP)

			dbSelectArea("RZ04")
			dbSkip()

		End

		RZ04->(dbCloseArea())
		Ferase(RZcIndex+GetDBExtension())
		Ferase(RZcIndex+OrdBagExt())

		For nx := 1 to Len (msCompany)

			MY001 := Alltrim(" WITH ORCAFINAL AS (SELECT ZBZ_VERSAO VERSAO, ") + msEnter
			MY001 += Alltrim("                           ZBZ_REVISA REVISA, ") + msEnter
			MY001 += Alltrim("                           ZBZ_ANOREF ANOREF, ") + msEnter
			MY001 += Alltrim("                           ZBZ_ORIPRC ORIPRC, ") + msEnter
			MY001 += Alltrim("                           ZBZ_ORGLAN ORGLAN, ") + msEnter
			MY001 += Alltrim("                           ZBZ_DATA DTREF, ") + msEnter
			MY001 += Alltrim("                           ZBZ_LOTE + ZBZ_SBLOTE + ZBZ_DOC + ZBZ_LINHA KEYREG, ") + msEnter
			MY001 += Alltrim("                           ZBZ_DC DC, ") + msEnter
			MY001 += Alltrim("                           ZBZ_DEBITO CONTA, ") + msEnter
			MY001 += Alltrim("                           ZBZ_CLVLDB CLVL, ") + msEnter
			MY001 += Alltrim("                           ZBZ_ITEMD ITCTA, ") + msEnter
			MY001 += Alltrim("                           ZBZ_APLIC APLICACAO, ") + msEnter
			MY001 += Alltrim("                           DAPLIC = CASE ") + msEnter
			MY001 += Alltrim("                                        WHEN ZBZ_APLIC = '0' THEN 'NENHUM' ") + msEnter
			MY001 += Alltrim("                                        WHEN ZBZ_APLIC = '1' THEN 'PRODUCAO' ") + msEnter
			MY001 += Alltrim("                                        WHEN ZBZ_APLIC = '2' THEN 'MANUTENCAO' ") + msEnter
			MY001 += Alltrim("                                        WHEN ZBZ_APLIC = '3' THEN 'MELHORIA_MANUT' ") + msEnter
			MY001 += Alltrim("                                        WHEN ZBZ_APLIC = '4' THEN 'SEGURANCA' ") + msEnter
			MY001 += Alltrim("                                        WHEN ZBZ_APLIC = '5' THEN 'CALIBRACAO' ") + msEnter
			MY001 += Alltrim("                                        WHEN ZBZ_APLIC = '6' THEN 'MELHORIA_PROD' ") + msEnter
			MY001 += Alltrim("                                        ELSE '' ") + msEnter
			MY001 += Alltrim("                                    END, ") + msEnter
			MY001 += Alltrim("                           ZBZ_DRVDB DRIVER, ") + msEnter
			MY001 += Alltrim("                           ZBZ_VALOR VALOR, ") + msEnter
			MY001 += Alltrim("                           RTRIM(ZBZ_HIST) HIST, ") + msEnter
			MY001 += Alltrim("                           RTRIM(ZBZ_YHIST) YHIST, ") + msEnter
			MY001 += Alltrim("                           ZBZ_SI SI, ") + msEnter
			MY001 += Alltrim("                           CASE ") + msEnter
			MY001 += Alltrim("                             WHEN RTRIM(ZBZ_CLVLDB) IN ( '3180', '3181', '3183', '3184', '3280', '3299')  THEN CTH_YITCUS ") + msEnter
			MY001 += Alltrim("                             ELSE CT1_YITCUS ") + msEnter
			MY001 += Alltrim("                           END ITCUS ") + msEnter
			MY001 += Alltrim("                      FROM ZBZ" + msCompany[nx] + "0 ZBZ ") + msEnter
			MY001 += Alltrim("                     INNER JOIN " + RetSqlName("CT1") + " CT1 ON CT1_CONTA = ZBZ_DEBITO ") + msEnter
			MY001 += Alltrim("                                          AND CT1.D_E_L_E_T_ = ' ' ") + msEnter
			MY001 += Alltrim("                      LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = ZBZ_CLVLDB ") + msEnter
			MY001 += Alltrim("                                          AND CTH.D_E_L_E_T_ = ' ' ") + msEnter
			MY001 += Alltrim("                     WHERE ZBZ_VERSAO = '" + idVersao + "' ") + msEnter
			MY001 += Alltrim("                       AND ZBZ_REVISA = '" + idRevisa + "' ") + msEnter
			MY001 += Alltrim("                       AND ZBZ_ANOREF = '" + idAnoRef + "' ") + msEnter
			MY001 += Alltrim("                       AND ZBZ_DEBITO <> '' ") + msEnter
			MY001 += Alltrim("                       AND ZBZ.D_E_L_E_T_ = ' ' ") + msEnter
			MY001 += Alltrim("                     UNION ALL ") + msEnter
			MY001 += Alltrim("                    SELECT ZBZ_VERSAO VERSAO, ") + msEnter
			MY001 += Alltrim("                           ZBZ_REVISA REVISA, ") + msEnter
			MY001 += Alltrim("                           ZBZ_ANOREF ANOREF, ") + msEnter
			MY001 += Alltrim("                           ZBZ_ORIPRC ORIPRC, ") + msEnter
			MY001 += Alltrim("                           ZBZ_ORGLAN ORGLAN, ") + msEnter
			MY001 += Alltrim("                           ZBZ_DATA DTREF, ") + msEnter
			MY001 += Alltrim("                           ZBZ_LOTE + ZBZ_SBLOTE + ZBZ_DOC + ZBZ_LINHA KEYREG, ") + msEnter
			MY001 += Alltrim("                           ZBZ_DC DC, ") + msEnter
			MY001 += Alltrim("                           ZBZ_CREDIT CONTA, ") + msEnter
			MY001 += Alltrim("                           ZBZ_CLVLCR CLVL, ") + msEnter
			MY001 += Alltrim("                           ZBZ_ITEMC ITCTA, ") + msEnter
			MY001 += Alltrim("                           ZBZ_APLIC APLICACAO, ") + msEnter
			MY001 += Alltrim("                           DAPLIC = CASE ") + msEnter
			MY001 += Alltrim("                                        WHEN ZBZ_APLIC = '0' THEN 'NENHUM' ") + msEnter
			MY001 += Alltrim("                                        WHEN ZBZ_APLIC = '1' THEN 'PRODUCAO' ") + msEnter
			MY001 += Alltrim("                                        WHEN ZBZ_APLIC = '2' THEN 'MANUTENCAO' ") + msEnter
			MY001 += Alltrim("                                        WHEN ZBZ_APLIC = '3' THEN 'MELHORIA_MANUT' ") + msEnter
			MY001 += Alltrim("                                        WHEN ZBZ_APLIC = '4' THEN 'SEGURANCA' ") + msEnter
			MY001 += Alltrim("                                        WHEN ZBZ_APLIC = '5' THEN 'CALIBRACAO' ") + msEnter
			MY001 += Alltrim("                                        WHEN ZBZ_APLIC = '6' THEN 'MELHORIA_PROD' ") + msEnter
			MY001 += Alltrim("                                        ELSE 'OUTROS' ") + msEnter
			MY001 += Alltrim("                                    END, ") + msEnter
			MY001 += Alltrim("                           ZBZ_DRVCR DRIVER, ") + msEnter
			MY001 += Alltrim("                           ZBZ_VALOR VALOR, ") + msEnter
			MY001 += Alltrim("                           RTRIM(ZBZ_HIST) HIST, ") + msEnter
			MY001 += Alltrim("                           RTRIM(ZBZ_YHIST) YHIST, ") + msEnter
			MY001 += Alltrim("                           ZBZ_SI SI, ") + msEnter
			MY001 += Alltrim("                           CASE ") + msEnter
			MY001 += Alltrim("                             WHEN RTRIM(ZBZ_CLVLCR) IN ( '3180', '3181', '3183', '3184', '3280', '3299')  THEN CTH_YITCUS ") + msEnter
			MY001 += Alltrim("                             ELSE CT1_YITCUS ") + msEnter
			MY001 += Alltrim("                           END ITCUS ") + msEnter
			MY001 += Alltrim("                      FROM ZBZ" + msCompany[nx] + "0 ZBZ ") + msEnter
			MY001 += Alltrim("                     INNER JOIN " + RetSqlName("CT1") + " CT1 ON CT1_CONTA = ZBZ_CREDIT ") + msEnter
			MY001 += Alltrim("                                          AND CT1.D_E_L_E_T_ = ' ' ") + msEnter
			MY001 += Alltrim("                      LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = ZBZ_CLVLCR ") + msEnter
			MY001 += Alltrim("                                          AND CTH.D_E_L_E_T_ = ' ' ") + msEnter
			MY001 += Alltrim("                     WHERE ZBZ_VERSAO = '" + idVersao + "' ") + msEnter
			MY001 += Alltrim("                       AND ZBZ_REVISA = '" + idRevisa + "' ") + msEnter
			MY001 += Alltrim("                       AND ZBZ_ANOREF = '" + idAnoRef + "' ") + msEnter
			MY001 += Alltrim("                       AND ZBZ_CREDIT <> '' ") + msEnter
			MY001 += Alltrim("                       AND ZBZ.D_E_L_E_T_ = ' ') ") + msEnter
			MY001 += Alltrim(" SELECT '" + msCompany[nx] + "' EMPR, ") + msEnter
			MY001 += Alltrim("        VERSAO, ") + msEnter
			MY001 += Alltrim("        REVISA, ") + msEnter
			MY001 += Alltrim("        ANOREF, ") + msEnter
			MY001 += Alltrim("        ORIPRC, ") + msEnter
			MY001 += Alltrim("        ORGLAN, ") + msEnter
			MY001 += Alltrim("        DTREF, ") + msEnter
			MY001 += Alltrim("        KEYREG, ") + msEnter
			MY001 += Alltrim("        DC, ") + msEnter
			MY001 += Alltrim("        CONTA, ") + msEnter
			MY001 += Alltrim("        CLVL, ") + msEnter
			MY001 += Alltrim("        ITCTA, ") + msEnter
			MY001 += Alltrim("        APLICACAO, ") + msEnter
			MY001 += Alltrim("        DAPLIC, ") + msEnter
			MY001 += Alltrim("        DRIVER, ") + msEnter
			MY001 += Alltrim("        ISNULL(ZBE_DESCRI, '') DDRIVER, ") + msEnter
			MY001 += Alltrim("        VALOR, ") + msEnter
			MY001 += Alltrim("        HIST, ") + msEnter
			MY001 += Alltrim("        YHIST, ") + msEnter
			MY001 += Alltrim("        SI, ") + msEnter
			MY001 += Alltrim("        CASE ") + msEnter
			MY001 += Alltrim("          WHEN SUBSTRING(CLVL,1,1) <> 3 THEN '' ") + msEnter
			MY001 += Alltrim("          WHEN RTRIM(CLVL) IN('6112','6208') THEN 'MOD' + SUBSTRING(CLVL,2,1) + SUBSTRING(CTH_YCRIT,1,3) + SPACE(7) ") + msEnter
			MY001 += Alltrim("          WHEN CONTA IN('61601022') THEN 'MOD' + SUBSTRING(CLVL,2,1) + RTRIM(SUBSTRING(CT1_YAGRUP, 1, 10)) + SUBSTRING(CTH_YCRIT, 1, 3) ") + msEnter
			MY001 += Alltrim("          WHEN RTRIM(CLVL) IN ( '3180', '3181', '3183', '3184', '3280' ) THEN 'MOD' + SUBSTRING(CLVL,2,1) + SUBSTRING(CTH_YCRIT, 1, 3) ") + msEnter
			MY001 += Alltrim("          WHEN RTRIM(CLVL) IN ( '3299' ) AND DTREF <= '20210930' THEN 'MOD' + SUBSTRING(CLVL,2,1) + SUBSTRING(CTH_YCRIT, 1, 3) ") + msEnter
			MY001 += Alltrim("          WHEN RTRIM(SUBSTRING(CT1_YAGRUP, 1, 10)) IN ( '612', '613', '614' ) THEN 'MOD' + SUBSTRING(CLVL,2,1) + RTRIM(SUBSTRING(CT1_YAGRUP, 1, 10)) + SUBSTRING(CTH_YCRIT, 1, 3) ") + msEnter
			MY001 += Alltrim("          ELSE 'MOD' + SUBSTRING(CLVL,2,1) + RTRIM(SUBSTRING(CT1_YAGRUP, 1, 10)) ") + msEnter
			MY001 += Alltrim("        END MODS , ") + msEnter
			MY001 += Alltrim("        CASE ") + msEnter
			MY001 += Alltrim("          WHEN SUBSTRING(CLVL,1,1) <> 3 THEN '' ") + msEnter
			MY001 += Alltrim("          WHEN RTRIM(SUBSTRING(CT1_YAGRUP, 1, 10)) NOT IN ( '615', '616', '617' ) AND SUBSTRING(CTH_YCRIT, 1, 3) IN ( 'E03', 'E04', 'R01', 'R02', 'R09' ) THEN 'PA' ") + msEnter
			MY001 += Alltrim("          WHEN SUBSTRING(CONTA, 1, 5) IN ( '61104', '61110' ) THEN 'PA' ") + msEnter
			MY001 += Alltrim("          ELSE 'PP' ") + msEnter
			MY001 += Alltrim("        END CONTRAP, ") + msEnter
			MY001 += Alltrim("        ITCUS, ") + msEnter
			MY001 += Alltrim("        ISNULL(Z29_DRESUM, '') DITCUS ") + msEnter
			MY001 += Alltrim("   FROM ORCAFINAL ORF ") + msEnter
			MY001 += Alltrim("  INNER JOIN " + RetSqlName("CT1") + " CT1 ON CT1_CONTA = CONTA ") + msEnter
			MY001 += Alltrim("                       AND CT1.D_E_L_E_T_ = ' ' ") + msEnter
			MY001 += Alltrim("  INNER JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = CLVL ") + msEnter
			MY001 += Alltrim("                       AND CTH.D_E_L_E_T_ = ' ' ") + msEnter
			MY001 += Alltrim("   LEFT JOIN " + RetSqlName("Z29") + " Z29 ON Z29_COD_IT = ITCUS ") + msEnter
			MY001 += Alltrim("                       AND Z29.D_E_L_E_T_ = ' ' ") + msEnter
			MY001 += Alltrim("   LEFT JOIN " + RetSqlName("ZBE") + " ZBE ON ZBE_DRIVER = DRIVER ") + msEnter
			MY001 += Alltrim("                       AND ZBE.D_E_L_E_T_ = ' ' ") + msEnter
			MY001 += Alltrim("  ORDER BY DTREF, ") + msEnter
			MY001 += Alltrim("           ORIPRC ") + msEnter
			MYcIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,MY001),'MY01',.F.,.T.)
			dbSelectArea("MY01")
			dbGoTop()
			Count To msQtdLinhas
			ProcRegua(msQtdLinhas + 2)
			dbSelectArea("MY01")
			dbGoTop()
			While !Eof()

				IncProc("Carregando... Empresa: " + MY01->EMPR + ", " + AllTrim(Str(MY01->(Recno()))) + " de " + AllTrim(Str(msQtdLinhas)))

				nRegAtu++
				if MOD(nRegAtu,2) > 0 
					cCorFun2 := '#DCE6F1'
				else
					cCorFun2 := '#B8CCE4'
				endif

				oExcel:AddLinha(14) 
				oExcel:AddCelula()
				oExcel:AddCelula( MY01->EMPR                                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->VERSAO                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->REVISA                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->ANOREF                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->ORIPRC                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->ORGLAN                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( stod(MY01->DTREF)                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->KEYREG                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->DC                                       , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->CONTA                                    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->CLVL                                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->ITCTA                                    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->APLICACAO                                , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->DAPLIC                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->DRIVER                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->DDRIVER                                  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->VALOR                                    , 0 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->HIST                                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->YHIST                                    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->SI                                       , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->MODS                                     , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->CONTRAP                                  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->ITCUS                                    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( MY01->DITCUS                                   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)

				dbSelectArea("MY01")
				dbSkip()

			End

			MY01->(dbCloseArea())
			Ferase(MYcIndex+GetDBExtension())     //arquivo de trabalho
			Ferase(MYcIndex+OrdBagExt())          //indice gerado

		Next nx

		oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 

	Else

		MsgStop('Processo Abortado!!!')

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Parametros                                                            ¦¦¦
¦¦+-----------------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function BIA948B()

	Local aPergs 	:= {}
	Local cLoad	    := 'BIA948B' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	idVersao        := space(010)
	idRevisa        := space(003) 
	idAnoRef		:= space(004) 

	aAdd( aPergs ,{1,"Versão:"                      ,idVersao    ,"@!","NAOVAZIO()",'ZB5','.T.',070,.F.})	
	aAdd( aPergs ,{1,"Revisão:"                     ,idRevisa    ,"@!","NAOVAZIO()",''   ,'.T.', 03,.F.})	
	aAdd( aPergs ,{1,"Ano Orçamentário: "           ,idAnoRef    ,"@!","NAOVAZIO()",''   ,'.T.', 04,.F.})	

	If ParamBox(aPergs ,"Extração OrcaFinal c/ ItCus",,,,,,,,cLoad,.T.,.T.)      
		idVersao    := ParamLoad(cFileName,,1,idVersao) 
		idRevisa    := ParamLoad(cFileName,,2,idRevisa) 
		idAnoRef    := ParamLoad(cFileName,,3,idAnoRef) 
	Endif

Return 
