#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA736
@author Marcos Alberto Soprani
@since 06/11/18
@version 1.0
@description Rotina para gerar o Roteiro de Operações por Produto    
@type function
/*/

User Function BIA736()

	fPerg := "BIA736"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	U_BIA736Prc(MV_PAR01, MV_PAR02)

Return

User Function BIA736Prc(xProdDe, xProdAt)

	Local htAreaAtu  := GetArea()
	Local msStaExcQy 
	Local lOk        := .T.

	Local _cAlias	:=	GetNextAlias()

	Local entEnter  := CHR(13) + CHR(10)
	lOCAL msNewRot  := IIF(IsInCallStack("U_BIA352"), .T., .F.)

	Begin Transaction

		RC007 := " WITH ROTEIRO "
		RC007 += "      AS (SELECT ZCM_CTRAB, "
		RC007 += "                 HB_NOME, "
		RC007 += "                 ZCM_FORMAT, "
		RC007 += "                 ZCM_ROTEIR, "
		RC007 += "                 H1_YOPRPAD, "
		RC007 += "                 H1_CODIGO, "
		RC007 += "                 ZCL_DESCRI, "
		RC007 += "                 ZCM_SETUP, "
		RC007 += "                 ZCM_LOTPAD, "
		RC007 += "                 ZCM_TEMPAD, "
		RC007 += "                 ZCM_TPPROD "
		RC007 += "          FROM " + RetSqlName("ZCM") + " ZCM(NOLOCK) "
		RC007 += "               INNER JOIN " + RetSqlName("SH1") + " SH1(NOLOCK) ON SH1.H1_CTRAB = ZCM.ZCM_CTRAB "
		RC007 += "                                        AND SH1.D_E_L_E_T_ = ' ' "
		RC007 += "               INNER JOIN " + RetSqlName("SHB") + " SHB(NOLOCK) ON SHB.HB_COD = ZCM.ZCM_CTRAB "
		RC007 += "                                        AND SHB.D_E_L_E_T_ = ' ' "
		RC007 += "               INNER JOIN " + RetSqlName("ZCL") + " ZCL(NOLOCK) ON ZCL.ZCL_OPERAC = SH1.H1_YOPRPAD "
		RC007 += "                                        AND SH1.D_E_L_E_T_ = ' ' "
		RC007 += "          WHERE ZCM.D_E_L_E_T_ = ' ') "
		RC007 += "      UPDATE SG2 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = SG2.R_E_C_N_O_ "
		RC007 += "      FROM ROTEIRO RTR "
		RC007 += "           INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_YFORMAT = ZCM_FORMAT "
		RC007 += "                                    AND ((SB1.B1_TIPO = 'PA' "
		RC007 += "                                          AND SB1.B1_YCLASSE = '1' "
		RC007 += "                                          AND SB1.B1_YSTATUS = '1') "
		RC007 += "                                         OR (SB1.B1_TIPO = 'PP' "
		RC007 += "                                             AND SB1.B1_YCLASSE = ' ' "
		RC007 += "                                             AND SB1.B1_YSTATUS = '1')) "
		RC007 += "                                    AND SB1.B1_COD BETWEEN '" + xProdDe + "' AND '" + xProdAt + "' "
		RC007 += "                                    AND SB1.B1_TIPO = ZCM_TPPROD "
		RC007 += "                                    AND SB1.B1_MSBLQL <> '1' "
		RC007 += "                                    AND SB1.D_E_L_E_T_ = ' ' "
		RC007 += "           INNER JOIN " + RetSqlName("SG2") + " SG2 ON SG2.G2_CODIGO = ZCM_ROTEIR "
		RC007 += "                                    AND SG2.G2_PRODUTO = SB1.B1_COD "
		RC007 += "                                    AND SG2.G2_RECURSO <> H1_CODIGO "
		RC007 += "                                    AND SG2.G2_OPERAC = H1_YOPRPAD "
		RC007 += "                                    AND SG2.D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Apagando Roteiros incorretos... ", , {|| msStaExcQy := TcSqlExec(RC007) })

		If msStaExcQy < 0 .and. msStaExcQy <> -19 
			lOk := .F.
		EndIf

		If lOk

			UH003 := " WITH ROTEIRO "
			UH003 += "      AS (SELECT ZCM_FORMAT, "
			UH003 += "                 ZCM_ROTEIR, "
			UH003 += "                 H1_YOPRPAD, "
			UH003 += "                 H1_CODIGO "
			UH003 += "          FROM " + RetSqlName("ZCM") + " ZCM(NOLOCK) "
			UH003 += "               INNER JOIN " + RetSqlName("SH1") + " SH1(NOLOCK) ON SH1.H1_CTRAB = ZCM.ZCM_CTRAB "
			UH003 += "                                                AND SH1.D_E_L_E_T_ = ' ' "
			UH003 += "               INNER JOIN " + RetSqlName("SHB") + " SHB(NOLOCK) ON SHB.HB_COD = ZCM.ZCM_CTRAB "
			UH003 += "                                                AND SHB.D_E_L_E_T_ = ' ' "
			UH003 += "               INNER JOIN " + RetSqlName("ZCL") + " ZCL(NOLOCK) ON ZCL.ZCL_OPERAC = SH1.H1_YOPRPAD "
			UH003 += "                                                AND SH1.D_E_L_E_T_ = ' ' "
			UH003 += "          WHERE ZCM.D_E_L_E_T_ = ' ') "
			UH003 += "      UPDATE SG2 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = SG2.R_E_C_N_O_ "
			UH003 += "      FROM " + RetSqlName("SG2") + " SG2 "
			UH003 += "           LEFT JOIN ROTEIRO RTR ON ZCM_ROTEIR = SG2.G2_CODIGO "
			UH003 += "                                    AND H1_CODIGO = SG2.G2_RECURSO "
			UH003 += "                                    AND H1_YOPRPAD = SG2.G2_OPERAC "
			UH003 += "                                    AND ZCM_FORMAT = SUBSTRING(G2_PRODUTO, 1, 2) "
			UH003 += "      WHERE SG2.G2_PRODUTO BETWEEN '" + xProdDe + "' AND '" + xProdAt + "' "
			UH003 += "            AND ZCM_ROTEIR IS NULL "
			UH003 += "            AND D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando Roteiros incorretos... ", , {|| msStaExcQy := TcSqlExec(UH003) })

			If msStaExcQy < 0 .and. msStaExcQy <> -19 
				lOk := .F.
			EndIf

			If lOk

				RC003 := Alltrim(" WITH ROTEIRO AS (SELECT ZCM_CTRAB,                                                                                  ") + entEnter
				RC003 += Alltrim("                         HB_NOME,                                                                                    ") + entEnter
				RC003 += Alltrim("                         ZCM_FORMAT,                                                                                 ") + entEnter
				RC003 += Alltrim("                         ZCM_ROTEIR,                                                                                 ") + entEnter
				RC003 += Alltrim("                         H1_YOPRPAD,                                                                                 ") + entEnter
				RC003 += Alltrim("                         H1_CODIGO,                                                                                  ") + entEnter
				RC003 += Alltrim("                         ZCL_DESCRI,                                                                                 ") + entEnter
				RC003 += Alltrim("                         ZCM_SETUP,                                                                                  ") + entEnter
				RC003 += Alltrim("                         ZCM_LOTPAD,                                                                                 ") + entEnter
				RC003 += Alltrim("                         ZCM_TEMPAD,                                                                                 ") + entEnter
				RC003 += Alltrim("                         ZCM_TPPROD                                                                                  ") + entEnter
				RC003 += Alltrim("                    FROM " + RetSqlName("ZCM") + " ZCM                                                               ") + entEnter
				RC003 += Alltrim("                   INNER JOIN " + RetSqlName("SH1") + " SH1 ON SH1.H1_CTRAB = ZCM.ZCM_CTRAB                          ") + entEnter
				RC003 += Alltrim("                                        AND SH1.D_E_L_E_T_ = ' '                                                     ") + entEnter
				RC003 += Alltrim("                   INNER JOIN " + RetSqlName("SHB") + " SHB ON SHB.HB_COD = ZCM.ZCM_CTRAB                            ") + entEnter
				RC003 += Alltrim("                                        AND SHB.D_E_L_E_T_ = ' '                                                     ") + entEnter
				RC003 += Alltrim("                   INNER JOIN " + RetSqlName("ZCL") + " ZCL ON ZCL.ZCL_OPERAC = SH1.H1_YOPRPAD                       ") + entEnter
				RC003 += Alltrim("                                        AND SH1.D_E_L_E_T_ = ' '                                                     ") + entEnter
				RC003 += Alltrim("                   WHERE ZCM.D_E_L_E_T_ = ' ')                                                                       ") + entEnter
				RC003 += Alltrim(" INSERT INTO " + RetSqlName("SG2") + "                                                                               ") + entEnter
				RC003 += Alltrim(" (G2_FILIAL,                                                                                                         ") + entEnter
				RC003 += Alltrim("  G2_CODIGO,                                                                                                         ") + entEnter
				RC003 += Alltrim("  G2_OPERAC,                                                                                                         ") + entEnter
				RC003 += Alltrim("  G2_RECURSO,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_FERRAM,                                                                                                         ") + entEnter
				RC003 += Alltrim("  G2_LINHAPR,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_TPLINHA,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_DESCRI,                                                                                                         ") + entEnter
				RC003 += Alltrim("  G2_MAOOBRA,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_SETUP,                                                                                                          ") + entEnter
				RC003 += Alltrim("  G2_LOTEPAD,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_TEMPAD,                                                                                                         ") + entEnter
				RC003 += Alltrim("  G2_TPOPER,                                                                                                         ") + entEnter
				RC003 += Alltrim("  G2_TPSOBRE,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_TEMPSOB,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_TPDESD,                                                                                                         ") + entEnter
				RC003 += Alltrim("  G2_TEMPDES,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_DESPROP,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_CTRAB,                                                                                                          ") + entEnter
				RC003 += Alltrim("  G2_OPE_OBR,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_SEQ_OBR,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_LAU_OBR,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_REVIPRD,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_CHAVE,                                                                                                          ") + entEnter
				RC003 += Alltrim("  G2_ROTALT ,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_OPERGRP,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_FORMSTP,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_GRSETUP,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_GRUPREC,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_NIVMONT,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_CHAVMON,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_TMAXPRO,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_TPINTER,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_MAXINCR,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_FOLMIN,                                                                                                         ") + entEnter
				RC003 += Alltrim("  G2_HOROTIM,                                                                                                        ") + entEnter
				RC003 += Alltrim("  D_E_L_E_T_,                                                                                                        ") + entEnter
				RC003 += Alltrim("  R_E_C_N_O_,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_TPALOCF,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_TEMPEND,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_REFGRD,                                                                                                         ") + entEnter
				RC003 += Alltrim("  G2_DEPTO,                                                                                                          ") + entEnter
				RC003 += Alltrim("  R_E_C_D_E_L_,                                                                                                      ") + entEnter
				RC003 += Alltrim("  G2_PRODUTO,                                                                                                        ") + entEnter
				RC003 += Alltrim("  G2_DTINI,                                                                                                          ") + entEnter
				RC003 += Alltrim("  G2_DTFIM)                                                                                                          ") + entEnter
				RC003 += Alltrim(" SELECT '" + xFilial("SG2") + "' G2_FILIAL,                                                                          ") + entEnter
				RC003 += Alltrim("        ZCM_ROTEIR G2_CODIGO,                                                                                        ") + entEnter
				RC003 += Alltrim("        H1_YOPRPAD G2_OPERAC,                                                                                        ") + entEnter
				RC003 += Alltrim("        H1_CODIGO G2_RECURSO,                                                                                        ") + entEnter
				RC003 += Alltrim("        '' G2_FERRAM,                                                                                                ") + entEnter
				RC003 += Alltrim("        '' G2_LINHAPR,                                                                                               ") + entEnter
				RC003 += Alltrim("        '' G2_TPLINHA,                                                                                               ") + entEnter
				RC003 += Alltrim("        ZCL_DESCRI G2_DESCRI,                                                                                        ") + entEnter
				RC003 += Alltrim("        0 G2_MAOOBRA,                                                                                                ") + entEnter
				RC003 += Alltrim("        ZCM_SETUP G2_SETUP,                                                                                          ") + entEnter
				RC003 += Alltrim("        ZCM_LOTPAD G2_LOTEPAD,                                                                                       ") + entEnter
				RC003 += Alltrim("        ZCM_TEMPAD G2_TEMPAD,                                                                                        ") + entEnter
				RC003 += Alltrim("        '' G2_TPOPER,                                                                                                ") + entEnter
				RC003 += Alltrim("        '' G2_TPSOBRE,                                                                                               ") + entEnter
				RC003 += Alltrim("        0 G2_TEMPSOB,                                                                                                ") + entEnter
				RC003 += Alltrim("        '' G2_TPDESD,                                                                                                ") + entEnter
				RC003 += Alltrim("        0 G2_TEMPDES,                                                                                                ") + entEnter
				RC003 += Alltrim("        '' G2_DESPROP,                                                                                               ") + entEnter
				RC003 += Alltrim("        ZCM_CTRAB G2_CTRAB,                                                                                          ") + entEnter
				RC003 += Alltrim("        'S' G2_OPE_OBR,                                                                                              ") + entEnter
				RC003 += Alltrim("        'S' G2_SEQ_OBR,                                                                                              ") + entEnter
				RC003 += Alltrim("        'S' G2_LAU_OBR,                                                                                              ") + entEnter
				RC003 += Alltrim("        '' G2_REVIPRD,                                                                                               ") + entEnter
				RC003 += Alltrim("        '' G2_CHAVE,                                                                                                 ") + entEnter
				RC003 += Alltrim("        '' G2_ROTALT,                                                                                                ") + entEnter
				RC003 += Alltrim("        '' G2_OPERGRP,                                                                                               ") + entEnter
				RC003 += Alltrim("        '' G2_FORMSTP,                                                                                               ") + entEnter
				RC003 += Alltrim("        '' G2_GRSETUP,                                                                                               ") + entEnter
				RC003 += Alltrim("        '' G2_GRUPREC,                                                                                               ") + entEnter
				RC003 += Alltrim("        0 G2_NIVMONT,                                                                                                ") + entEnter
				RC003 += Alltrim("        0 G2_CHAVMON,                                                                                                ") + entEnter
				RC003 += Alltrim("        '' G2_TMAXPRO,                                                                                               ") + entEnter
				RC003 += Alltrim("        '' G2_TPINTER,                                                                                               ") + entEnter
				RC003 += Alltrim("        0 G2_MAXINCR,                                                                                                ") + entEnter
				RC003 += Alltrim("        '' G2_FOLMIN,                                                                                                ") + entEnter
				RC003 += Alltrim("        '' G2_HOROTIM,                                                                                               ") + entEnter
				RC003 += Alltrim("        '' D_E_L_E_T_,                                                                                               ") + entEnter
				RC003 += Alltrim("        ISNULL((SELECT MAX(R_E_C_N_O_) FROM " + RetSqlName("SG2") + "),0) + ROW_NUMBER() OVER(ORDER BY SB1.R_E_C_N_O_) AS R_E_C_N_O_,  ") + entEnter
				RC003 += Alltrim("        '' G2_TPALOCF,                                                                                               ") + entEnter
				RC003 += Alltrim("        0 G2_TEMPEND,                                                                                                ") + entEnter
				RC003 += Alltrim("        '' G2_REFGRD,                                                                                                ") + entEnter
				RC003 += Alltrim("        '' G2_DEPTO,                                                                                                 ") + entEnter
				RC003 += Alltrim("        0 R_E_C_D_E_L_,                                                                                              ") + entEnter
				RC003 += Alltrim("        B1_COD G2_PRODUTO,                                                                                           ") + entEnter
				RC003 += Alltrim("        '" + dtos( dDataBase - 30 ) + "' G2_DTINI,                                                                   ") + entEnter
				RC003 += Alltrim("        '20491231' G2_DTFIM                                                                                          ") + entEnter
				RC003 += Alltrim("   FROM ROTEIRO RTR                                                                                                  ") + entEnter
				RC003 += Alltrim("  INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_YFORMAT = ZCM_FORMAT                                            ") + entEnter
				RC003 += Alltrim("                       AND ( ( SB1.B1_TIPO = 'PA' AND SB1.B1_YCLASSE = '1' AND SB1.B1_YSTATUS = '1' )                ") + entEnter
				RC003 += Alltrim("                        OR   ( SB1.B1_TIPO = 'PP' AND SB1.B1_YCLASSE = ' ' AND SB1.B1_YSTATUS = '1' ) )              ") + entEnter
				RC003 += Alltrim("                       AND SB1.B1_COD BETWEEN '" + xProdDe + "' AND '" + xProdAt + "'                                ") + entEnter
				RC003 += Alltrim("                       AND SB1.B1_TIPO = ZCM_TPPROD                                                                  ") + entEnter
				RC003 += Alltrim("                       AND SB1.B1_MSBLQL <> '1'                                                                      ") + entEnter
				RC003 += Alltrim("                       AND SB1.D_E_L_E_T_ = ' '                                                                      ") + entEnter
				RC003 += Alltrim("  WHERE ZCM_ROTEIR NOT IN(SELECT G2_CODIGO                                                                           ") + entEnter
				RC003 += Alltrim("                            FROM " + RetSqlName("SG2") + "                                                           ") + entEnter
				RC003 += Alltrim("                           WHERE G2_PRODUTO = B1_COD                                                                 ") + entEnter
				RC003 += Alltrim("                             AND G2_CODIGO = ZCM_ROTEIR                                                              ") + entEnter
				RC003 += Alltrim("                             AND G2_OPERAC = H1_YOPRPAD                                                              ") + entEnter
				RC003 += Alltrim("                             AND D_E_L_E_T_ = ' ')                                                                   ") + entEnter

				U_BIAMsgRun("Aguarde... Efetuando geração dos Roteiros de Produção ", , {|| msStaExcQy := TcSqlExec(RC003) })

				If msStaExcQy < 0
					lOk := .F.
				EndIf

			EndIf

		EndIf

		If !lOk

			msGravaErr := TCSQLError()
			DisarmTransaction()

		EndIf

	End Transaction 

	If lOk

		BeginSql Alias _cAlias

			%NoParser%

			WITH ROTEIRO
			AS (
			SELECT ZCM_CTRAB
			,HB_NOME
			,ZCM_FORMAT
			,ZCM_ROTEIR
			,H1_YOPRPAD
			,H1_CODIGO
			,ZCL_DESCRI
			,ZCM_SETUP
			,ZCM_LOTPAD
			,ZCM_TEMPAD
			,ZCM_TPPROD
			FROM ZCM010 ZCM
			INNER JOIN %TABLE:SH1% SH1 ON SH1.H1_CTRAB = ZCM.ZCM_CTRAB
			AND SH1.%NotDel%
			INNER JOIN %TABLE:SHB% SHB ON SHB.HB_COD = ZCM.ZCM_CTRAB
			AND SHB.%NotDel%
			INNER JOIN %TABLE:ZCL% ZCL ON ZCL.ZCL_OPERAC = SH1.H1_YOPRPAD
			AND SH1.%NotDel%
			WHERE ZCM.%NotDel%
			)
			SELECT DISTINCT B1_COD,ZCM_ROTEIR
			FROM ROTEIRO RTR
			INNER JOIN %TABLE:SB1% SB1 ON SB1.B1_YFORMAT = ZCM_FORMAT
			AND (
			(
			SB1.B1_TIPO = 'PA'
			AND SB1.B1_YCLASSE = '1'
			AND SB1.B1_YSTATUS = '1'
			)
			OR (
			SB1.B1_TIPO = 'PP'
			AND SB1.B1_YCLASSE = ' '
			AND SB1.B1_YSTATUS = '1'
			)
			)
			AND SB1.B1_COD BETWEEN %Exp:xProdDe%
			AND %Exp:xProdAt%
			AND SB1.B1_TIPO = ZCM_TPPROD
			AND SB1.B1_MSBLQL <> '1'
			AND SB1.%NotDel%
			INNER JOIN SG2010 SG2 ON G2_PRODUTO = B1_COD
			AND G2_CODIGO = ZCM_ROTEIR
			AND G2_OPERAC = H1_YOPRPAD
			AND G2_LOTEPAD <> ZCM_LOTPAD
			AND SG2.%NotDel%	

		EndSql

		If (_cAlias)->(!EOF())

			BEGIN TRANSACTION

				RC008 := Alltrim(" WITH ROTEIRO                                                                                                   ") + entEnter
				RC008 += Alltrim("      AS (SELECT ZCM_CTRAB,                                                                                     ") + entEnter
				RC008 += Alltrim("                 HB_NOME,                                                                                       ") + entEnter
				RC008 += Alltrim("                 ZCM_FORMAT,                                                                                    ") + entEnter
				RC008 += Alltrim("                 ZCM_ROTEIR,                                                                                    ") + entEnter
				RC008 += Alltrim("                 H1_YOPRPAD,                                                                                    ") + entEnter
				RC008 += Alltrim("                 H1_CODIGO,                                                                                     ") + entEnter
				RC008 += Alltrim("                 ZCL_DESCRI,                                                                                    ") + entEnter
				RC008 += Alltrim("                 ZCM_SETUP,                                                                                     ") + entEnter
				RC008 += Alltrim("                 ZCM_LOTPAD,                                                                                    ") + entEnter
				RC008 += Alltrim("                 ZCM_TEMPAD,                                                                                    ") + entEnter
				RC008 += Alltrim("                 ZCM_TPPROD                                                                                     ") + entEnter
				RC008 += Alltrim("          FROM " + RetSqlName("ZCM") + " ZCM                                                                    ") + entEnter
				RC008 += Alltrim("               INNER JOIN " + RetSqlName("SH1") + " SH1(NOLOCK) ON SH1.H1_CTRAB = ZCM.ZCM_CTRAB                 ") + entEnter
				RC008 += Alltrim("                                        AND SH1.D_E_L_E_T_ = ' '                                                ") + entEnter
				RC008 += Alltrim("               INNER JOIN " + RetSqlName("SHB") + " SHB(NOLOCK) ON SHB.HB_COD = ZCM.ZCM_CTRAB                   ") + entEnter
				RC008 += Alltrim("                                        AND SHB.D_E_L_E_T_ = ' '                                                ") + entEnter
				RC008 += Alltrim("               INNER JOIN " + RetSqlName("ZCL") + " ZCL(NOLOCK) ON ZCL.ZCL_OPERAC = SH1.H1_YOPRPAD              ") + entEnter
				RC008 += Alltrim("                                        AND SH1.D_E_L_E_T_ = ' '                                                ") + entEnter
				RC008 += Alltrim("          WHERE ZCM.D_E_L_E_T_ = ' ')                                                                           ") + entEnter
				RC008 += Alltrim("      UPDATE SG2 SET G2_LOTEPAD = ZCM_LOTPAD                                                                    ") + entEnter
				RC008 += Alltrim("      FROM ROTEIRO RTR                                                                                          ") + entEnter
				RC008 += Alltrim("           INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_YFORMAT = ZCM_FORMAT                              ") + entEnter
				RC008 += Alltrim("                                    AND ((SB1.B1_TIPO = 'PA'                                                    ") + entEnter
				RC008 += Alltrim("                                          AND SB1.B1_YCLASSE = '1'                                              ") + entEnter
				RC008 += Alltrim("                                          AND SB1.B1_YSTATUS = '1')                                             ") + entEnter
				RC008 += Alltrim("                                         OR (SB1.B1_TIPO = 'PP'                                                 ") + entEnter
				RC008 += Alltrim("                                             AND SB1.B1_YCLASSE = ' '                                           ") + entEnter
				RC008 += Alltrim("                                             AND SB1.B1_YSTATUS = '1'))                                         ") + entEnter
				RC008 += Alltrim("                                    AND SB1.B1_COD BETWEEN '" + xProdDe + "' AND '" + xProdAt + "'              ") + entEnter
				RC008 += Alltrim("                                    AND SB1.B1_TIPO = ZCM_TPPROD                                                ") + entEnter
				RC008 += Alltrim("                                    AND SB1.B1_MSBLQL <> '1'                                                    ") + entEnter
				RC008 += Alltrim("                                    AND SB1.D_E_L_E_T_ = ' '                                                    ") + entEnter
				RC008 += Alltrim("           INNER JOIN " + RetSqlName("SG2") + " SG2 ON G2_PRODUTO = B1_COD                                      ") + entEnter
				RC008 += Alltrim("                                    AND G2_CODIGO = ZCM_ROTEIR                                                  ") + entEnter
				RC008 += Alltrim("                                    AND G2_OPERAC = H1_YOPRPAD                                                  ") + entEnter
				RC008 += Alltrim("                                    AND G2_LOTEPAD <> ZCM_LOTPAD                                                ") + entEnter
				RC008 += Alltrim("                                    AND SG2.D_E_L_E_T_ = ' '                                                    ") + entEnter

				U_BIAMsgRun("Aguarde... Efetuando atualização dos tempos dos Roteiros de Produção ", , {|| msStaExcQy := TcSqlExec(RC008) })

				If msStaExcQy < 0
					lOk := .F.
				EndIf

				If !msNewRot

					If lOk

						While (_cAlias)->(!EOF())

							U_BIAMsgRun("Aguarde... Atualizando OP's do roteiro " + (_cAlias)->ZCM_ROTEIR + " Produto: " + (_cAlias)->B1_COD , , {|| fAtuRot((_cAlias)->B1_COD,(_cAlias)->ZCM_ROTEIR) })	

							(_cAlias)->(DbSkip())

						EndDo

					EndIf

					If !lOk

						msGravaErr := TCSQLError()
						DisarmTransaction()

					EndIf

				EndIf

			END TRANSACTION

		EndIf

		// Revalidação Geral das Op's versus Roteiros
		U_BIAMsgRun("Aguarde... Revalidação Geral das Op's versus RoteiroS" , , {|| f02AtuRot( xProdDe, xProdAt) })	

		(_cAlias)->(DbCloseArea())

		If !msNewRot

			If lOk

				U_BIAMsgRun("Aguarde... Processando Integração com o TOTVS MES " , , {|| U_BIAFG097() })

				MsgINFO("Fim de processamento!!!")

			Else

				Aviso('Problema de Processamento', "Erro na execução do processamento: " + entEnter + entEnter + entEnter + msGravaErr + entEnter + entEnter + entEnter + entEnter + "Processo Cancelado!!!" + entEnter + entEnter + entEnter, {'Fecha'}, 3 )

			EndIf

		EndIf

	Else

		Aviso('Problema de Processamento', "Erro na execução do processamento: " + entEnter + entEnter + entEnter + msGravaErr + entEnter + entEnter + entEnter + entEnter + "Processo Cancelado!!!" + entEnter + entEnter + entEnter, {'Fecha'}, 3 )

	EndIf

	RestArea(htAreaAtu)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fValidPerg()

	local i,j
	_sAlias := GetArea()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Produto               ?","","","mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"02","Até Produto              ?","","","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
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

	RestArea(_sAlias)

Return

Static Function fAtuRot(_cCodPro,_cRoteiro)

	Local _cAlias	:=	GetNextAlias()
	Local lBkpInc
	Local lBkpAlt
	Local cFuncaoAux

	cFuncaoAux := FunName()

	SetFunName("MATA650")

	BeginSql Alias _cAlias

		SELECT R_E_C_N_O_ REC
		FROM %TABLE:SC2%
		WHERE C2_FILIAL = %XFILIAL:SC2%
		AND C2_DATRF = ''
		AND C2_PRODUTO = %Exp:_cCodPro%
		AND C2_ROTEIRO = %Exp:_cRoteiro%
		AND C2_QUJE = 0
		AND C2_SEQUEN = '001'
		AND C2_YITGMES = 'S'
		AND %NotDel%

	ENDSQL

	While (_cAlias)->(!EOF())

		SC2->(DbGoTo((_cAlias)->REC))
		If SC2->(!EOF())

			If Type("INCLUI") == "L"
				lBkpInc := INCLUI
			EndIf
			If Type("ALTERA") == "L"
				lBkpAlt := ALTERA
			EndIf
			INCLUI	:=	.F.
			ALTERA	:=	.T.
			If PCPIntgPPI()
				lProcessa := mata650PPI(,,.T.,.T.,.F.)
			EndIf
			INCLUI	:=	lBkpInc
			ALTERA	:=	lBkpAlt

		EndIf

		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

	SetFunName(cFuncaoAux)

Return

Static Function f02AtuRot(xProdDe, xProdAt)

	Local _cAlias	:=	GetNextAlias()
	Local lBkpInc
	Local lBkpAlt
	Local cFuncaoAux

	cFuncaoAux := FunName()

	BeginSql Alias _cAlias

		%NoParser%

		WITH ROTEIRO
		AS (SELECT ZCM_CTRAB, 
		HB_NOME, 
		ZCM_FORMAT, 
		ZCM_ROTEIR, 
		H1_YOPRPAD, 
		H1_CODIGO, 
		ZCL_DESCRI, 
		ZCM_SETUP, 
		ZCM_LOTPAD, 
		ZCM_TEMPAD, 
		ZCM_TPPROD
		FROM %TABLE:ZCM% ZCM
		INNER JOIN %TABLE:SH1% SH1 ON SH1.H1_CTRAB = ZCM.ZCM_CTRAB
		AND SH1.%NotDel%
		INNER JOIN %TABLE:SHB% SHB ON SHB.HB_COD = ZCM.ZCM_CTRAB
		AND SHB.%NotDel%
		INNER JOIN %TABLE:ZCL% ZCL ON ZCL.ZCL_OPERAC = SH1.H1_YOPRPAD
		AND SH1.%NotDel%
		WHERE ZCM.%NotDel%),
		APLICROTEIRO
		AS (SELECT DISTINCT 
		B1_COD, 
		ZCM_ROTEIR
		FROM ROTEIRO RTR
		INNER JOIN %TABLE:SB1% SB1 ON SB1.B1_YFORMAT = ZCM_FORMAT
		AND ((SB1.B1_TIPO = 'PA'
		AND SB1.B1_YCLASSE = '1'
		AND SB1.B1_YSTATUS = '1')
		OR (SB1.B1_TIPO = 'PP'
		AND SB1.B1_YCLASSE = ' '
		AND SB1.B1_YSTATUS = '1'))
		AND SB1.B1_COD BETWEEN %Exp:xProdDe% AND %Exp:xProdAt%
		AND SB1.B1_TIPO = ZCM_TPPROD
		AND SB1.B1_MSBLQL <> '1'
		AND SB1.%NotDel%
		INNER JOIN %TABLE:SG2% SG2 ON G2_PRODUTO = B1_COD
		AND G2_CODIGO = ZCM_ROTEIR
		AND G2_OPERAC = H1_YOPRPAD
		AND SG2.%NotDel%)
		SELECT R_E_C_N_O_ REC, ZCM_ROTEIR
		FROM %TABLE:SC2% SC2
		INNER JOIN APLICROTEIRO APR ON APR.B1_COD = SC2.C2_PRODUTO
		WHERE C2_FILIAL = %xFilial:SC2%
		AND C2_DATRF = '        '
		AND C2_QUJE = 0
		AND C2_SEQUEN = '001'
		AND C2_ROTEIRO <> ZCM_ROTEIR
		AND SC2.%NotDel%

	ENDSQL

	While (_cAlias)->(!EOF())

		SC2->(DbGoTo((_cAlias)->REC))
		If SC2->(!EOF())

			RecLock("SC2", .F.)
			SC2->C2_ROTEIRO := (_cAlias)->(ZCM_ROTEIR)
			SC2->C2_YITGMES := "S"
			MsUnlock()

			SetFunName("MATA650")

			If Type("INCLUI") == "L"
				lBkpInc := INCLUI
			EndIf
			If Type("ALTERA") == "L"
				lBkpAlt := ALTERA
			EndIf
			INCLUI	:=	.F.
			ALTERA	:=	.T.
			If PCPIntgPPI()
				lProcessa := mata650PPI(,,.T.,.T.,.F.)
			EndIf
			INCLUI	:=	lBkpInc
			ALTERA	:=	lBkpAlt

		EndIf

		SetFunName(cFuncaoAux)

		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

Return
