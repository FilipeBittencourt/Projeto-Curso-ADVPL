#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA360
@author Marcos Alberto Soprani
@since 20/12/17
@version 1.0
@description Listagem para conferência do cálculo do plano de saúde
@type function
/*/

User Function BIA360()

	cHInicio := Time()
	fPerg := "BIA360"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	Processa({ || fProcConfer() },"Aguarde...","Carregando Arquivo...",.F.)

Return

//Processa listagem para conferência
Static Function fProcConfer()

	Local _cAlias   := GetNextAlias()
	Local nRegAtu   := 0

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
	Local nConsumo	 :=	0

	local cEmpresa   := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML    := UPPER(Alltrim(FunName())) + "_" + ALLTrim( DTOS(DATE()) + "_" + StrTran( time(),':',''))
	private cDirDest := "c:\temp\"

	oExcel := ARSexcel():New()

	ProcRegua(100000)

	oExcel:AddPlanilha("Relatorio", {20, 40, 33, 155, 26, 57, 36, 157, 70, 75, 37, 202, 61, 33, 101, 46, 94, 36, 52, 105, 38, 35}, 6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2, (1 + 21 + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2, (1 + 21 + 1) - 3 ) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Plano de Saúde", 0, 'L', cFonte1, nTamFont1, cCorFont1, .T., , cCorFun1, , , , , .T., 2, (1 + 21 + 1) - 3 )  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("COMPPG   "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("MATR     "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("NOME     "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CLVL     "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DORIGEM  "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DEPEND   "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("NOMEDEP  "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DTPLAN   "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("TIPOPLANO"          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("CODFOR   "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DFORNEC  "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	
	IF !(cValtochar(533,568,569,570,571,572,573,574,576,577) $ Alltrim(MV_PAR09))
	
		oExcel:AddCelula("CRITERIO "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("PLANO    "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)	
		oExcel:AddCelula("DPLANO   "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	
	ENDIF
	

	
	oExcel:AddCelula("VERBAFUN "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("DPDFUN   "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	oExcel:AddCelula("VLRFUN   "          , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)

	IF !(cValtochar(533,568,569,570,571,572,573,574,576,577) $ Alltrim(MV_PAR09))
	
		oExcel:AddCelula("VERBAEMPR"          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("DPDEMP   "          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("VLREMP   "          , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
	
	ENDIF
	
	oExcel:AddCelula("VLRTOT   "          , 2, "R", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)

	IF cValtochar(533,568,569,570,571,572,573,574,576,577) $ Alltrim(MV_PAR09)  

		HJ002 := " SELECT DISTINCT RHO_COMPPG COMPPG, "
		HJ002 += "        RHO_MAT MATR, "
		HJ002 += "        RA_NOME NOME, "
		HJ002 += "        ISNULL((SELECT MAX(RE_CLVLP) "
		HJ002 += "                  FROM " + RetSqlName("SRE") + " "
		HJ002 += "                 WHERE RE_FILIAL = '" + xFilial("SRE") + "' "
		HJ002 += "                   AND RE_MATP = RA_MAT "
		HJ002 += "                   AND RE_DATA IN (SELECT MAX(RE_DATA) "
		HJ002 += "                                     FROM " + RetSqlName("SRE") + " "
		HJ002 += "                                    WHERE RE_FILIAL = '" + xFilial("SRE") + "' "
		HJ002 += "                                      AND RE_MATP = RA_MAT "
		HJ002 += "                                      AND SUBSTRING(RE_DATA,1,6) <= RHO_COMPPG "
		HJ002 += "                                      AND RE_EMPP = '" + cEmpAnt + "' "
		HJ002 += "                                      AND D_E_L_E_T_  = ' ') "
		HJ002 += "                   AND RE_EMPP = '" + xFilial("SRE") + "' "
		HJ002 += "                   AND D_E_L_E_T_ = ' '), RA_CLVL) CLVL, "
		HJ002 += "        RHO_CODIGO DEPEND, "
		HJ002 += "        RTRIM(ISNULL(RB_NOME,'')) NOMEDEP, "
		HJ002 += "        CASE "
		HJ002 += "          WHEN RHO_TPLAN = '1' THEN '1-Plano' "
		HJ002 += "          WHEN RHO_TPLAN = '2' THEN '2-Co-participacao' "
		HJ002 += "          WHEN RHO_TPLAN = '3' THEN '3-Reembolso' "
		HJ002 += "        END DTPLAN, "
		HJ002 += "        CASE "
		HJ002 += "          WHEN RHO_TPFORN = '1' THEN '1-Ass.Medica' "
		HJ002 += "          WHEN RHO_TPFORN = '2' THEN '2-Ass.Odontoligica' "
		HJ002 += "        END TIPOPLANO, "
		HJ002 += "        RHO_CODFOR CODFOR, "
		HJ002 += "        CASE "
		HJ002 += "          WHEN RHO_TPFORN = '1' THEN RTRIM((SELECT TOP 1 SUBSTRING(RCCM.RCC_CONTEU,4,150) "
		HJ002 += "                                              FROM " + RetSqlName("RCC") + " RCCM  "
		HJ002 += "                                             WHERE RCCM.RCC_CODIGO = 'S016' "
		HJ002 += "                                               AND SUBSTRING(RCCM.RCC_CONTEU,1,3) = RHO_CODFOR "
		HJ002 += "                                               AND RCCM.D_E_L_E_T_ = ' ')) "
		HJ002 += "          WHEN RHO_TPFORN = '2' THEN RTRIM((SELECT TOP 1 SUBSTRING(RCCM.RCC_CONTEU,4,150) "
		HJ002 += "                                              FROM " + RetSqlName("RCC") + " RCCM  "
		HJ002 += "                                             WHERE RCCM.RCC_CODIGO = 'S017' "
		HJ002 += "                                               AND SUBSTRING(RCCM.RCC_CONTEU,1,3) = RHO_CODFOR "
		HJ002 += "                                               AND RCCM.D_E_L_E_T_ = ' ')) "
		HJ002 += "        END DFORNEC, "
		HJ002 += "        CASE "
		HJ002 += "          WHEN RHO_TPLAN IN('2','3') THEN '' "
		HJ002 += "          WHEN RHO_TPFORN = '1' THEN RTRIM((SELECT TOP 1 SUBSTRING(RCCM.RCC_CONTEU,3,20) "
		HJ002 += "                                              FROM " + RetSqlName("RCC") + " RCCM  "
		HJ002 += "                                             WHERE RCCM.RCC_CODIGO = 'S008' "
		HJ002 += "                                               AND RCCM.D_E_L_E_T_ = ' ')) "
		HJ002 += "          WHEN RHO_TPFORN = '2' THEN RTRIM((SELECT TOP 1 SUBSTRING(RCCM.RCC_CONTEU,3,20) "
		HJ002 += "                                              FROM " + RetSqlName("RCC") + " RCCM  "
		HJ002 += "                                             WHERE RCCM.RCC_CODIGO = 'S013' "
		HJ002 += "                                               AND RCCM.D_E_L_E_T_ = ' ')) "
		HJ002 += "        END DPLANO, "
		HJ002 += "        RHO_PD VERBAFUN, "
		HJ002 += "        SRVF.RV_DESC DPDFUN, "
		HJ002 += "        RHO_VLRFUN VLRFUN, "
		HJ002 += "        CASE "
		HJ002 += "          WHEN RHO_PD = '531' THEN '876' "
		HJ002 += "          WHEN RHO_PD = '532' THEN '877' "
		HJ002 += "          WHEN RHO_PD = '543' THEN '882' "
		HJ002 += "          WHEN RHO_PD = '560' THEN '' "
		HJ002 += "          WHEN RHO_PD = '535' THEN '876' "
		HJ002 += "          ELSE 'ERR' "
		HJ002 += "        END VERBAEMPR, "
		HJ002 += "        CASE "
		HJ002 += "          WHEN RHO_PD = '531' THEN RTRIM((SELECT RV_DESC "
		HJ002 += "                                            FROM " + RetSqlName("SRV") + " SRVE "
		HJ002 += "                                           WHERE SRVE.RV_FILIAL = '" + xFilial("SRV") + "' "
		HJ002 += "                                             AND SRVE.RV_COD = '876' "
		HJ002 += "                                             AND SRVE.D_E_L_E_T_ = ' ')) "
		HJ002 += "          WHEN RHO_PD = '532' THEN RTRIM((SELECT RV_DESC "
		HJ002 += "                                            FROM " + RetSqlName("SRV") + " SRVE "
		HJ002 += "                                           WHERE SRVE.RV_FILIAL = '" + xFilial("SRV") + "' "
		HJ002 += "                                             AND SRVE.RV_COD = '877' "
		HJ002 += "                                             AND SRVE.D_E_L_E_T_ = ' ')) "
		HJ002 += "          WHEN RHO_PD = '543' THEN RTRIM((SELECT RV_DESC "
		HJ002 += "                                            FROM " + RetSqlName("SRV") + " SRVE "
		HJ002 += "                                           WHERE SRVE.RV_FILIAL = '" + xFilial("SRV") + "' "
		HJ002 += "                                             AND SRVE.RV_COD = '882' "
		HJ002 += "                                             AND SRVE.D_E_L_E_T_ = ' ')) "
		HJ002 += "          WHEN RHO_PD = '560' THEN '' "
		HJ002 += "          WHEN RHO_PD = '535' THEN RTRIM((SELECT RV_DESC "
		HJ002 += "                                            FROM " + RetSqlName("SRV") + " SRVE "
		HJ002 += "                                           WHERE SRVE.RV_FILIAL = '" + xFilial("SRV") + "' "
		HJ002 += "                                             AND SRVE.RV_COD = '876' "
		HJ002 += "                                             AND SRVE.D_E_L_E_T_ = ' ')) "
		HJ002 += "          ELSE 'ERRO - FAVOR VERIFICAR' "
		HJ002 += "        END DPDEMP, "
		HJ002 += "        CASE WHEN RHO_ORIGEM = '1' THEN '1-Titular' WHEN RHO_ORIGEM = '2' THEN '2-Dependente' WHEN RHO_ORIGEM = '3' THEN '3-Agregado' END DORIGEM, "
		HJ002 += "        RHO_VLREMP VLREMP, "
		HJ002 += "        RHO_VLRFUN + RHO_VLREMP VLRTOT "
		HJ002 += "   FROM " + RetSqlName("RHO") + " RHO "
		HJ002 += "  INNER JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_FILIAL = RHO.RHO_FILIAL "
		HJ002 += "                       AND SRA.RA_MAT = RHO.RHO_MAT "
		HJ002 += "                       AND SRA.D_E_L_E_T_ = ' ' "
		HJ002 += "   LEFT JOIN " + RetSqlName("SRB") + " SRB ON SRB.RB_FILIAL = RHO.RHO_FILIAL "
		HJ002 += "                       AND SRB.RB_MAT = RHO.RHO_MAT "
		HJ002 += "                       AND SRB.RB_COD = RHO.RHO_CODIGO "
		HJ002 += "                       AND SRB.D_E_L_E_T_ = ' ' "
		HJ002 += "   LEFT JOIN " + RetSqlName("SRV") + " SRVF ON SRVF.RV_FILIAL = '" + xFilial("SRV") + "' "
		HJ002 += "                        AND SRVF.RV_COD = RHO.RHO_PD "
		HJ002 += "                        AND SRVF.D_E_L_E_T_ = ' ' "
		HJ002 += "   LEFT JOIN " + RetSqlName("RHR") + " RHR ON RHR.RHR_MAT = RHO.RHO_MAT "
	    HJ002 += "                        AND RHR_FILIAL = RHO.RHO_FILIAL  "
	    HJ002 += "                        AND RHR.D_E_L_E_T_ = '' "
		HJ002 += "  WHERE RHO.RHO_FILIAL = '" + xFilial("RHO") + "' "
		HJ002 += "    AND RHO.RHO_COMPPG BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
		HJ002 += "    AND RHO.RHO_MAT BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
		HJ002 += "    AND RHO.RHO_TPFORN BETWEEN '" + Alltrim(Str(MV_PAR05)) + "' AND '" + Alltrim(Str(MV_PAR06)) + "' "
		HJ002 += "    AND RHO.D_E_L_E_T_ = ' ' "
		
		If Alltrim(Str(MV_PAR05)) == "1" 
			IF Alltrim(Str(MV_PAR06)) == "2"
				HJ002 += "    AND ((RHR.RHR_PLANO IN" + FormatIn(trim(MV_PAR10),"",2) + " AND RHR_TPFORN = '1') OR RHR_TPFORN = '2') "
			Else
				HJ002 += "    AND RHR.RHR_PLANO IN" + FormatIn(trim(MV_PAR10),"",2)  "
			EndIf
		EndIf
		
//		HJ002 += "  ORDER BY RHO_COMPPG, RHO_MAT, RHO_CODIGO, RHO_TPLAN, RHO_TPFORN "

	ELSE
		HJ002 := " SELECT RHR_COMPPG COMPPG, "
		HJ002 += "        RHR_MAT MATR, "
		HJ002 += "        RA_NOME NOME, "
		HJ002 += "        ISNULL((SELECT MAX(RE_CLVLP) "
		HJ002 += "                  FROM " + RetSqlName("SRE") + " "
		HJ002 += "                 WHERE RE_FILIAL = '" + xFilial("SRE") + "' "
		HJ002 += "                   AND RE_MATP = RA_MAT "
		HJ002 += "                   AND RE_DATA IN (SELECT MAX(RE_DATA) "
		HJ002 += "                                     FROM " + RetSqlName("SRE") + " "
		HJ002 += "                                    WHERE RE_FILIAL = '" + xFilial("SRE") + "' "
		HJ002 += "                                      AND RE_MATP = RA_MAT "
		HJ002 += "                                      AND SUBSTRING(RE_DATA,1,6) <= RHR_COMPPG "
		HJ002 += "                                      AND RE_EMPP = '" + cEmpAnt + "' "
		HJ002 += "                                      AND D_E_L_E_T_  = ' ') "
		HJ002 += "                   AND RE_EMPP = '" + xFilial("SRE") + "' "
		HJ002 += "                   AND D_E_L_E_T_ = ' '), RA_CLVL) CLVL, "
		HJ002 += "        CASE "
		HJ002 += "          WHEN RHR_ORIGEM = '1' THEN '1-Titular' "
		HJ002 += "          WHEN RHR_ORIGEM = '2' THEN '2-Dependente' "
		HJ002 += "          WHEN RHR_ORIGEM = '3' THEN '3-Agregado' "
		HJ002 += "        END DORIGEM, "
		HJ002 += "        RHR_CODIGO DEPEND, "
		HJ002 += "        RTRIM(ISNULL(RB_NOME,'')) NOMEDEP, "
		HJ002 += "        CASE "
		HJ002 += "          WHEN RHR_TPLAN = '1' THEN '1-Plano' "
		HJ002 += "          WHEN RHR_TPLAN = '2' THEN '2-Co-participacao' "
		HJ002 += "          WHEN RHR_TPLAN = '3' THEN '3-Reembolso' "
		HJ002 += "        END DTPLAN, "
		HJ002 += "        CASE "
		HJ002 += "          WHEN RHR_TPFORN = '1' THEN '1-Ass.Medica' "
		HJ002 += "          WHEN RHR_TPFORN = '2' THEN '2-Ass.Odontoligica' "
		HJ002 += "        END TIPOPLANO, "
		HJ002 += "        RHR_CODFOR CODFOR, "
		HJ002 += "        CASE "
		HJ002 += "          WHEN RHR_TPFORN = '1' THEN RTRIM((SELECT TOP 1 SUBSTRING(RCCM.RCC_CONTEU,4,150) "
		HJ002 += "                                              FROM " + RetSqlName("RCC") + " RCCM  "
		HJ002 += "                                             WHERE RCCM.RCC_CODIGO = 'S016' "
		HJ002 += "                                               AND SUBSTRING(RCCM.RCC_CONTEU,1,3) = RHR_CODFOR "
		HJ002 += "                                               AND RCCM.D_E_L_E_T_ = ' ')) "
		HJ002 += "          WHEN RHR_TPFORN = '2' THEN RTRIM((SELECT TOP 1 SUBSTRING(RCCM.RCC_CONTEU,4,150) "
		HJ002 += "                                              FROM " + RetSqlName("RCC") + " RCCM  "
		HJ002 += "                                             WHERE RCCM.RCC_CODIGO = 'S017' "
		HJ002 += "                                               AND SUBSTRING(RCCM.RCC_CONTEU,1,3) = RHR_CODFOR "
		HJ002 += "                                               AND RCCM.D_E_L_E_T_ = ' ')) "
		HJ002 += "        END DFORNEC, "
		HJ002 += "        CASE "
		HJ002 += "          WHEN RHR_TPLAN IN('2','3') THEN '' "
		HJ002 += "          WHEN RHR_TPPLAN = '1' THEN '1-Faixa Salarial' "
		HJ002 += "          WHEN RHR_TPPLAN = '2' THEN '2-Faixa Etaria' "
		HJ002 += "          WHEN RHR_TPPLAN = '3' THEN '3-Valor Fixo' "
		HJ002 += "          WHEN RHR_TPPLAN = '4' THEN '4-% s/ Salario' "
		HJ002 += "          WHEN RHR_TPPLAN = '5' THEN '5-Salarial/Etaria' "
		HJ002 += "        END CRITERIO, "
		HJ002 += "        RHR_PLANO PLANO, "
		HJ002 += "        CASE "
		HJ002 += "          WHEN RHR_TPLAN IN('2','3') THEN '' "
		HJ002 += "          WHEN RHR_TPFORN = '1' THEN RTRIM((SELECT TOP 1 SUBSTRING(RCCM.RCC_CONTEU,3,20) "
		HJ002 += "                                              FROM " + RetSqlName("RCC") + " RCCM  "
		HJ002 += "                                             WHERE RCCM.RCC_CODIGO = 'S008' "
		HJ002 += "                                               AND SUBSTRING(RCCM.RCC_CONTEU,1,2) = RHR_PLANO "
		HJ002 += "                                               AND RCCM.D_E_L_E_T_ = ' ')) "
		HJ002 += "          WHEN RHR_TPFORN = '2' THEN RTRIM((SELECT TOP 1 SUBSTRING(RCCM.RCC_CONTEU,3,20) "
		HJ002 += "                                              FROM " + RetSqlName("RCC") + " RCCM  "
		HJ002 += "                                             WHERE RCCM.RCC_CODIGO = 'S013' "
		HJ002 += "                                               AND SUBSTRING(RCCM.RCC_CONTEU,1,2) = RHR_PLANO "
		HJ002 += "                                               AND RCCM.D_E_L_E_T_ = ' ')) "
		HJ002 += "        END DPLANO, "
		HJ002 += "        RHR_PD VERBAFUN, "
		HJ002 += "        SRVF.RV_DESC DPDFUN, "
		HJ002 += "        RHR_VLRFUN VLRFUN, "
		HJ002 += "        CASE "
		HJ002 += "          WHEN RHR_PD = '531' THEN '876' "
		HJ002 += "          WHEN RHR_PD = '532' THEN '877' "
		HJ002 += "          WHEN RHR_PD = '543' THEN '882' "
		HJ002 += "          WHEN RHR_PD = '560' THEN '' "
		HJ002 += "          WHEN RHR_PD = '535' THEN '876' "
		HJ002 += "          ELSE 'ERR' "
		HJ002 += "        END VERBAEMPR, "
		HJ002 += "        CASE "
		HJ002 += "          WHEN RHR_PD = '531' THEN RTRIM((SELECT RV_DESC "
		HJ002 += "                                            FROM " + RetSqlName("SRV") + " SRVE "
		HJ002 += "                                           WHERE SRVE.RV_FILIAL = '" + xFilial("SRV") + "' "
		HJ002 += "                                             AND SRVE.RV_COD = '876' "
		HJ002 += "                                             AND SRVE.D_E_L_E_T_ = ' ')) "
		HJ002 += "          WHEN RHR_PD = '532' THEN RTRIM((SELECT RV_DESC "
		HJ002 += "                                            FROM " + RetSqlName("SRV") + " SRVE "
		HJ002 += "                                           WHERE SRVE.RV_FILIAL = '" + xFilial("SRV") + "' "
		HJ002 += "                                             AND SRVE.RV_COD = '877' "
		HJ002 += "                                             AND SRVE.D_E_L_E_T_ = ' ')) "
		HJ002 += "          WHEN RHR_PD = '543' THEN RTRIM((SELECT RV_DESC "
		HJ002 += "                                            FROM " + RetSqlName("SRV") + " SRVE "
		HJ002 += "                                           WHERE SRVE.RV_FILIAL = '" + xFilial("SRV") + "' "
		HJ002 += "                                             AND SRVE.RV_COD = '882' "
		HJ002 += "                                             AND SRVE.D_E_L_E_T_ = ' ')) "
		HJ002 += "          WHEN RHR_PD = '560' THEN '' "
		HJ002 += "          WHEN RHR_PD = '535' THEN RTRIM((SELECT RV_DESC "
		HJ002 += "                                            FROM " + RetSqlName("SRV") + " SRVE "
		HJ002 += "                                           WHERE SRVE.RV_FILIAL = '" + xFilial("SRV") + "' "
		HJ002 += "                                             AND SRVE.RV_COD = '876' "
		HJ002 += "                                             AND SRVE.D_E_L_E_T_ = ' ')) "
		HJ002 += "          ELSE 'ERRO - FAVOR VERIFICAR' "
		HJ002 += "        END DPDEMP, "
		HJ002 += "        RHR_VLREMP VLREMP, "
		HJ002 += "        RHR_VLRFUN + RHR_VLREMP VLRTOT "
		HJ002 += "   FROM " + RetSqlName("RHR") + " RHR "
		HJ002 += "  INNER JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_FILIAL = RHR.RHR_FILIAL "
		HJ002 += "                       AND SRA.RA_MAT = RHR.RHR_MAT "
		HJ002 += "                       AND SRA.D_E_L_E_T_ = ' ' "
		HJ002 += "   LEFT JOIN " + RetSqlName("SRB") + " SRB ON SRB.RB_FILIAL = RHR.RHR_FILIAL "
		HJ002 += "                       AND SRB.RB_MAT = RHR.RHR_MAT "
		HJ002 += "                       AND SRB.RB_COD = RHR.RHR_CODIGO "
		HJ002 += "                       AND SRB.D_E_L_E_T_ = ' ' "
		HJ002 += "   LEFT JOIN " + RetSqlName("SRV") + " SRVF ON SRVF.RV_FILIAL = '" + xFilial("SRV") + "' "
		HJ002 += "                        AND SRVF.RV_COD = RHR.RHR_PD "
		HJ002 += "                        AND SRVF.D_E_L_E_T_ = ' ' "
		HJ002 += "  WHERE RHR.RHR_FILIAL = '" + xFilial("RHR") + "' "
		HJ002 += "    AND RHR.RHR_COMPPG BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
		HJ002 += "    AND RHR.RHR_MAT BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
		HJ002 += "    AND RHR.RHR_TPFORN BETWEEN '" + Alltrim(Str(MV_PAR05)) + "' AND '" + Alltrim(Str(MV_PAR06)) + "' "
		HJ002 += "    AND RHR.RHR_PLANO BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
		If Alltrim(Str(MV_PAR05)) == "1" 
			IF Alltrim(Str(MV_PAR06)) == "2"
				HJ002 += "    AND ((RHR.RHR_PLANO IN" + FormatIn(trim(MV_PAR10),"",2) + " AND RHR_TPFORN = '1') OR RHR_TPFORN = '2') "
			Else
				HJ002 += "    AND RHR.RHR_PLANO IN" + FormatIn(trim(MV_PAR10),"",2)  "
			EndIf
		EndIf
			
		HJ002 += "    AND RHR.D_E_L_E_T_ = ' ' "
		HJ002 += "  ORDER BY RHR_COMPPG, RHR_MAT, RHR_CODIGO, RHR_TPLAN, RHR_TPFORN, RHR_PLANO "

	
	ENDIF
		
	HJIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,HJ002),'HJ02',.T.,.T.)
	dbSelectArea("HJ02")
	HJ02->(dbGoTop())

	If HJ02->(!Eof())

		ProcRegua(RecCount())

		While HJ02->(!Eof())

			IncProc("Carregando dados " + AllTrim(Str(HJ02->(Recno()))) )

			If Empty(MV_PAR09) .or. HJ02->VERBAFUN $ Alltrim(MV_PAR09) .or. HJ02->VERBAEMPR $ Alltrim(MV_PAR09) 

				nRegAtu++
				if MOD(nRegAtu,2) > 0 
					cCorFun2 := '#DCE6F1'
				else
					cCorFun2 := '#B8CCE4'
				endif

				oExcel:AddLinha(14) 
				oExcel:AddCelula()
				oExcel:AddCelula( HJ02->COMPPG                         , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( HJ02->MATR                           , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( HJ02->NOME                           , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( HJ02->CLVL                           , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( HJ02->DORIGEM                        , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( HJ02->DEPEND                         , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( HJ02->NOMEDEP                        , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( HJ02->DTPLAN                         , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( HJ02->TIPOPLANO                      , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( HJ02->CODFOR                         , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( HJ02->DFORNEC                        , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)

				IF !(cValtochar(533,568,569,570,571,572,573,574,576,577) $ Alltrim(MV_PAR09))
					
					oExcel:AddCelula( HJ02->CRITERIO                       , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
					oExcel:AddCelula( HJ02->PLANO                          , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
					oExcel:AddCelula( HJ02->DPLANO                         , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)				
				
				ENDIF	


				oExcel:AddCelula( HJ02->VERBAFUN                       , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( HJ02->DPDFUN                         , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( HJ02->VLRFUN                         , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				
				IF !(cValtochar(533,568,569,570,571,572,573,574,576,577) $ Alltrim(MV_PAR09))
				
					oExcel:AddCelula( HJ02->VERBAEMPR                      , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
					oExcel:AddCelula( HJ02->DPDEMP                         , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
					oExcel:AddCelula( HJ02->VLREMP                         , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)				
			
				ENDIF
				

				oExcel:AddCelula( HJ02->VLRTOT                         , 2 , "R", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)

			EndIf

			HJ02->(dbSkip())

		EndDo

	EndIf

	HJ02->(dbCloseArea())
	Ferase(HJIndex+GetDBExtension())
	Ferase(HJIndex+OrdBagExt())

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.05.06 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	Local i,j

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Perído (Ano/Mes)             ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Período (Ano/Mes)           ?","","","mv_ch2","C",06,0,0,"C","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","De Matrícula                    ?","","","mv_ch3","C",06,0,0,"C","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
	aAdd(aRegs,{cPerg,"04","Atá Matrícula                   ?","","","mv_ch4","C",06,0,0,"C","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SRA"})
	aAdd(aRegs,{cPerg,"05","Do Tipo de Plano                ?","","","mv_ch5","N",01,0,0,"C","","mv_par05","Ass.Médica","","","","","Ass.Odontológica","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Até Tipo de Plano               ?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Ass.Médica","","","","","Ass.Odontológica","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Do Plano                        ?","","","mv_ch7","C",02,0,0,"C","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Até Plano                       ?","","","mv_ch8","C",02,0,0,"C","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Verbas a Listar(branco, todas)  ?","","","mv_ch9","C",60,0,0,"G","fVerbas(NIL,,20)","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","AsMedic a Listar                ?","","","mv_cha","C",20,0,0,"G","u_fAsMedicB()","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
