#include 'protheus.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA766
@author Marcos Alberto Soprani
@since 03/11/21
@version 1.0
@description Rotina para Geração da Planilha para Consolidação dos Expurgos - Novo Extrator
@type function
/*/

User Function BIA766()

	Local oProcess
	Local nW	:= 0
	Local oEmp 	:= Nil
	Local lRet           := .T.	

	Private smMsnPrc
	Private msrhEnter   := CHR(13) + CHR(10)

	Private xVerRet      := .T.
	Private msStaExcQy   := 0

	Private xStringFAT   := ""
	Private xStringCTB   := ""
	Private hhTmpINI

	Private msEmpAtu  := cEmpAnt
	Private msFilAtu  := cFilAnt
	Private msCanPrc  := .F.

	Private msErroQuery

	Private xoButton1
	Private xoMultiGe1
	Private xcMultiGe1 := ""
	Private xoSay1
	Private xoDlg

	If cEmpAnt <> "90"
		Msgbox("Esta rotina poderá ser utilizada somente na empresa 90 - Grupo Consolidado.", "BIA766", "STOP")
		Return
	EndIf

	If cEmpAnt == "90" .and. cFilAnt <> "90"
		Msgbox("Esta rotina poderá ser utilizada somente na empresa 90 - Grupo Consolidado, Filial 90, devido as amarrações com as tabelas origens.", "BIA766", "STOP")
		Return
	EndIf

	oEmp := TLoadEmpresa():New()

	If xValidPerg()

		dDataIni := stod(MV_PAR01 + '01')
		dDataFin := UltimoDia(stod(MV_PAR01 + '01'))

		//Chamada de tela para seleção da Empresa/Filial
		oEmp:GSEmpFil()		
		msArryEmp := oEmp:aEmpSel

		If Len(msArryEmp) > 0

			hhTmpINI  := TIME()

			RpcSetType(3)
			RpcSetEnv( cEmpAnt, cFilAnt )
			RpcClearEnv()

			RpcSetEnv( msEmpAtu, msFilAtu )
			oPrcZera := MsNewProcess():New({|lEnd| ExistThenD(@oPrcZera) }, "Deletando...", smMsnPrc, .T.)
			oPrcZera:Activate()
			lRet := xVerRet
			RpcClearEnv()

			If xVerRet

				For nW := 1 To Len(msArryEmp)

					RpcSetType(3)
					RpcSetEnv( msArryEmp[nW][1], Substr(msArryEmp[nW][2], 1, 2) )

					smMsnPrc := msArryEmp[nW][1] + "/" + Substr(msArryEmp[nW][2], 1, 2) + " - " + Alltrim(msArryEmp[nW][4])

					oProcess := MsNewProcess():New({|lEnd| aPrcG766(@oProcess) }, "Gravando...", smMsnPrc, .T.)
					oProcess:Activate()

					lRet := xVerRet

					If nW + 1 <= Len(msArryEmp)

						xStringFAT += Alltrim(" UNION ALL                                                                                                                                    ") + msrhEnter
						xStringCTB += Alltrim(" UNION ALL                                                                                                                                    ") + msrhEnter

					EndIf

					// processamento... implementar

					RpcClearEnv()

					If !xVerRet

						Exit

					EndIf


				Next nW

			Else

				msCanPrc  := .F.

			EndIf

		Else

			msCanPrc  := .T.

		EndIf

	Else

		msCanPrc  := .T.

	EndIf

	If !msCanPrc

		RpcSetEnv( msEmpAtu, msFilAtu )

		If Type("__cInternet") == "C"
			__cInternet := Nil
		EndIf

		If !lRet

			xcMultiGe1 := "Erro de Query: " + msrhEnter + msrhEnter + msErroQuery

			DEFINE MSDIALOG xoDlg TITLE "Atenção!!!" FROM 000, 000  TO 550, 490 COLORS 0, 16777215 PIXEL

			@ 019, 006 GET xoMultiGe1 VAR xcMultiGe1 OF xoDlg MULTILINE SIZE 236, 249 COLORS 0, 16777215 HSCROLL PIXEL
			@ 008, 008 SAY xoSay1 PROMPT "Log de Erro. Apanhe o erro e abra um ticket." SIZE 111, 007 OF xoDlg COLORS 0, 16777215 PIXEL
			@ 006, 205 BUTTON xoButton1 PROMPT "Fecha" SIZE 037, 012 OF xoDlg ACTION xoDlg:End() PIXEL

			ACTIVATE MSDIALOG xoDlg CENTERED

		Else

			MsgINFO("Processamento realizado com sucesso!!!", "BIA766")

		EndIf

	EndIf

Return

Static Function xValidPerg()

	local cLoad	    := "BIA766" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(06)

	aAdd( aPergs ,{1, "Ano/Mês"          ,MV_PAR01 ,"@R 9999/99"  ,"NAOVAZIO()"     ,''     ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Processa PPC",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 

	EndIf

Return lRet

Static Function ExistThenD(oPrcZera)

	Local cSQL  := ""
	Local cQry  := ""
	Local lRet  := .T.

	If fExistTabl(RetSqlName("ZNC"))

		cQry := GetNextAlias()

		cSql := " DELETE ZNC "
		cSql += " FROM " + RetSqlName("ZNC") + " ZNC (NOLOCK) "
		cSql += " WHERE ZNC_FILIAL = '" + xFilial("ZNC") + "' "
		cSql += "       AND ZNC_DATPRC = '" + dtos(dDataFin) + "' "
		cSql += "       AND ZNC.D_E_L_E_T_    = ' ' "
		U_BIAMsgRun("Aguarde... Deletando registros ZN8... ",,{|| msStaExcQy := TcSQLExec(cSql) })

		If msStaExcQy < 0
			lRet := .F.
		EndIf

		If !lRet

			msErroQuery := "Empresa: " + cEmpAnt + msrhEnter + msrhEnter
			msErroQuery += "Filial: " + cFilAnt + msrhEnter + msrhEnter
			msErroQuery += "DELETE ZN8" + msrhEnter + msrhEnter
			msErroQuery += TCSQLError()

		EndIf

	Else

		msErroQuery := "Empresa: " + cEmpAnt + msrhEnter + msrhEnter
		msErroQuery += "Filial: " + cFilAnt + msrhEnter + msrhEnter
		msErroQuery += "A tabela ZNC não está configurada para este empresa. Favor Verificar."
		lRet := .F.

	EndIf

	xVerRet := lRet 

Return ( lRet )

Static Function fExistTabl(cTabl)

	Local cSQL  := ""
	Local cQry  := ""
	Local lRet  := .F.

	cQry := GetNextAlias()

	cSql := " SELECT COUNT(*) CONTAD
	cSql += " FROM INFORMATION_SCHEMA.TABLES
	cSql += " WHERE TABLE_NAME = '" + cTabl + "';

	TcQuery cSQL New Alias (cQry)

	If (cQry)->CONTAD > 0
		lRet := .T.
	EndIf

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return ( lRet )

Static Function aPrcG766(oProcess)

	Local lRet := .T.

	oProcess:SetRegua1(1)
	oProcess:SetRegua2(1000)             

	oProcess:IncRegua1(smMsnPrc)
	oProcess:IncRegua2("Gravando a: " + Alltrim(ElapTime(hhTmpINI, TIME())) )

	// String para obtenção dos dados oriundos do FATURAMENTO
	QR007 := Alltrim(" SELECT '" + cEmpAnt + "' EMPORI,                                                                                                             ") + msrhEnter
	QR007 += Alltrim("        D2_FILIAL FILORI,                                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        Z35_EMP EMPDES,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        Z35_FIL FILDES,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        'SAI' ORIGMOV,                                                                                                                        ") + msrhEnter
	QR007 += Alltrim("        CLIENTE = D2_CLIENTE,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        LOJA = D2_LOJA,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        VALICM = D2_VALICM,                                                                                                                   ") + msrhEnter
	QR007 += Alltrim("        VALIPI = D2_VALIPI,                                                                                                                   ") + msrhEnter
	QR007 += Alltrim("        VALIMP6 = D2_VALIMP6,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        VALIMP5 = D2_VALIMP5,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        DOC = D2_DOC,                                                                                                                         ") + msrhEnter
	QR007 += Alltrim("        SERIE = D2_SERIE,                                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        COD = D2_COD,                                                                                                                         ") + msrhEnter
	QR007 += Alltrim("        GRUPO = B1_GRUPO,                                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        YTPPROD = B1_YTPPROD,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        EMISSAO = D2_EMISSAO,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        TIPO = D2_TIPO,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        CF = D2_CF,                                                                                                                           ") + msrhEnter
	QR007 += Alltrim("        CREDICM = F4_CREDICM,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        ICM = F4_ICM,                                                                                                                         ") + msrhEnter
	QR007 += Alltrim("        LFICM = F4_LFICM,                                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        DUPLIC = F4_DUPLIC,                                                                                                                   ") + msrhEnter
	QR007 += Alltrim("        QUANT = CASE                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("                    WHEN D2_TIPO = 'I'                                                                                                        ") + msrhEnter
	QR007 += Alltrim("                         AND D2_ICMSRET > 0                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    WHEN F4_CREDICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_ICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_LFICM = 'T'                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                         AND F4_DUPLIC = 'N'                                                                                                  ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    ELSE D2_QUANT                                                                                                             ") + msrhEnter
	QR007 += Alltrim("                END,                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("        VALOR = CASE                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("                    WHEN D2_TIPO = 'I'                                                                                                        ") + msrhEnter
	QR007 += Alltrim("                         AND D2_ICMSRET > 0                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    WHEN F4_CREDICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_ICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_LFICM = 'T'                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                         AND F4_DUPLIC = 'N'                                                                                                  ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    ELSE D2_TOTAL                                                                                                             ") + msrhEnter
	QR007 += Alltrim("                END,                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("        EST = D2_EST,                                                                                                                         ") + msrhEnter
	QR007 += Alltrim("        YCCONT = F4_YCCONT,                                                                                                                   ") + msrhEnter
	QR007 += Alltrim("        CTA_REC = CASE                                                                                                                        ") + msrhEnter
	QR007 += Alltrim("                      WHEN '" + cEmpAnt + "' = '06' AND '" + cFilAnt + "' = '07'                                                              ") + msrhEnter
	QR007 += Alltrim("                      THEN '41101010000011'                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                      WHEN D2_EST = 'EX'                                                                                                      ") + msrhEnter
	QR007 += Alltrim("                      THEN Z6_CTRSVDE                                                                                                         ") + msrhEnter
	QR007 += Alltrim("                      WHEN F4_YCCONT = '560'                                                                                                  ") + msrhEnter
	QR007 += Alltrim("                      THEN Z6_CTASERV                                                                                                         ") + msrhEnter
	QR007 += Alltrim("                      ELSE Z6_CTRSVDI                                                                                                         ") + msrhEnter
	QR007 += Alltrim("                  END,                                                                                                                        ") + msrhEnter
	QR007 += Alltrim("        CTA_IPI = Z6_CTAIPI,                                                                                                                  ") + msrhEnter
	QR007 += Alltrim("        CTA_ICM = Z6_CTAICMS,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        CTA_PIS = CASE                                                                                                                        ") + msrhEnter
	QR007 += Alltrim("                      WHEN '" + cEmpAnt + "' = '06' AND '" + cFilAnt + "' = '07'                                                              ") + msrhEnter
	QR007 += Alltrim("                      THEN '41201040000004'                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                      ELSE Z6_CTAPIS                                                                                                          ") + msrhEnter
	QR007 += Alltrim("                  END,                                                                                                                        ") + msrhEnter
	QR007 += Alltrim("        CTA_COF = CASE                                                                                                                        ") + msrhEnter
	QR007 += Alltrim("                      WHEN '" + cEmpAnt + "' = '06' AND '" + cFilAnt + "' = '07'                                                              ") + msrhEnter
	QR007 += Alltrim("                      THEN '41201040000005'                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                      ELSE Z6_CTACOF                                                                                                          ") + msrhEnter
	QR007 += Alltrim("                  END                                                                                                                         ") + msrhEnter
	QR007 += Alltrim(" FROM " + RetSqlName("SD2") + " SD2(NOLOCK)                                                                                                   ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("SF4") + " SF4(NOLOCK) ON SF4.F4_FILIAL = SD2.D2_FILIAL                                                       ") + msrhEnter
	QR007 += Alltrim("                                       AND SF4.F4_CODIGO = SD2.D2_TES                                                                         ") + msrhEnter
	QR007 += Alltrim("                                       AND ((SF4.F4_CREDICM = 'S'                                                                             ") + msrhEnter
	QR007 += Alltrim("                                             AND SF4.F4_ICM = 'S'                                                                             ") + msrhEnter
	QR007 += Alltrim("                                             AND SF4.F4_LFICM = 'T'                                                                           ") + msrhEnter
	QR007 += Alltrim("                                             AND SF4.F4_DUPLIC = 'N'                                                                          ") + msrhEnter
	QR007 += Alltrim("                                             AND (SUBSTRING(SD2.D2_CF, 2, 1) IN('1', '4', '2')                                                ") + msrhEnter
	QR007 += Alltrim("                                                  OR SUBSTRING(SD2.D2_CF, 2, 3) = '923'))                                                     ") + msrhEnter
	QR007 += Alltrim("                                            OR SF4.F4_DUPLIC = 'S')                                                                           ") + msrhEnter
	QR007 += Alltrim("                                       AND SF4.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'                                            ") + msrhEnter
	QR007 += Alltrim("                                       AND SB1.B1_COD = SD2.D2_COD                                                                            ") + msrhEnter
	QR007 += Alltrim("                                       AND SB1.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("Z35") + " Z35(NOLOCK) ON Z35_FILIAL = '" + xFilial("Z35") + "'                                               ") + msrhEnter
	QR007 += Alltrim("                                       AND Z35.Z35_CODCLI = SD2.D2_CLIENTE                                                                    ") + msrhEnter
	QR007 += Alltrim("                                       AND Z35.Z35_LOJCLI = SD2.D2_LOJA                                                                       ") + msrhEnter
	QR007 += Alltrim("                                       AND NOT Z35_TIPO IN('04', '05')                                                                        ") + msrhEnter
	QR007 += Alltrim("                                       AND Z35.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      LEFT JOIN " + RetSqlName("SZ6") + " SZ6(NOLOCK) ON SZ6.Z6_FILIAL = '" + xFilial("SZ6") + "'                                             ") + msrhEnter
	QR007 += Alltrim("                                       AND SZ6.Z6_TPPROD = SB1.B1_YTPPROD                                                                     ") + msrhEnter
	QR007 += Alltrim("                                       AND SZ6.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim(" WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "'                                                                                               ") + msrhEnter
	QR007 += Alltrim("       AND SD2.D2_EMISSAO BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "'                                                       ") + msrhEnter
	QR007 += Alltrim("       AND SD2.D2_TIPO <> 'D'                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("       AND SD2.D_E_L_E_T_ = ' '                                                                                                               ") + msrhEnter
	QR007 += Alltrim(" UNION ALL                                                                                                                                    ") + msrhEnter
	QR007 += Alltrim(" SELECT '" + cEmpAnt + "' EMPORI,                                                                                                             ") + msrhEnter
	QR007 += Alltrim("        D1_FILIAL FILORI,                                                                                                                     ") + msrhEnter	
	QR007 += Alltrim("        Z35_EMP EMPDES,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        Z35_FIL FILDES,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        'DEV' ORIGMOV,                                                                                                                        ") + msrhEnter
	QR007 += Alltrim("        CLIENTE = D1_FORNECE,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        LOJA = D1_LOJA,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        VALICM = D1_VALICM,                                                                                                                   ") + msrhEnter
	QR007 += Alltrim("        VALIPI = D1_VALIPI,                                                                                                                   ") + msrhEnter
	QR007 += Alltrim("        VALIMP6 = D1_VALIMP6,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        VALIMP5 = D1_VALIMP5,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        DOC = D1_DOC,                                                                                                                         ") + msrhEnter
	QR007 += Alltrim("        SERIE = D1_SERIE,                                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        COD = D1_COD,                                                                                                                         ") + msrhEnter
	QR007 += Alltrim("        GRUPO = B1_GRUPO,                                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        YTPPROD = B1_YTPPROD,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        EMISSAO = D1_EMISSAO,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        TIPO = D1_TIPO,                                                                                                                       ") + msrhEnter
	QR007 += Alltrim("        CF = D1_CF,                                                                                                                           ") + msrhEnter
	QR007 += Alltrim("        CREDICM = F4_CREDICM,                                                                                                                 ") + msrhEnter
	QR007 += Alltrim("        ICM = F4_ICM,                                                                                                                         ") + msrhEnter
	QR007 += Alltrim("        LFICM = F4_LFICM,                                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        DUPLIC = F4_DUPLIC,                                                                                                                   ") + msrhEnter
	QR007 += Alltrim("        QUANT = CASE                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("                    WHEN D1_TIPO = 'I'                                                                                                        ") + msrhEnter
	QR007 += Alltrim("                         AND D1_ICMSRET > 0                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    WHEN F4_CREDICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_ICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_LFICM = 'T'                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                         AND F4_DUPLIC = 'N'                                                                                                  ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    ELSE D1_QUANT                                                                                                             ") + msrhEnter
	QR007 += Alltrim("                END,                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("        VALOR = CASE                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("                    WHEN D1_TIPO = 'I'                                                                                                        ") + msrhEnter
	QR007 += Alltrim("                         AND D1_ICMSRET > 0                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    WHEN F4_CREDICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_ICM = 'S'                                                                                                     ") + msrhEnter
	QR007 += Alltrim("                         AND F4_LFICM = 'T'                                                                                                   ") + msrhEnter
	QR007 += Alltrim("                         AND F4_DUPLIC = 'N'                                                                                                  ") + msrhEnter
	QR007 += Alltrim("                    THEN 0                                                                                                                    ") + msrhEnter
	QR007 += Alltrim("                    ELSE D1_TOTAL                                                                                                             ") + msrhEnter
	QR007 += Alltrim("                END,                                                                                                                          ") + msrhEnter
	QR007 += Alltrim("        EST = D2_EST,                                                                                                                         ") + msrhEnter
	QR007 += Alltrim("        YCCONT = F4_YCCONT,                                                                                                                   ") + msrhEnter
	QR007 += Alltrim("        CTA_REC = ISNULL(Z6_CTARSDV, ''),                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        CTA_IPI = ISNULL(Z6_CTIPIDV, ''),                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        CTA_ICM = ISNULL(Z6_CTICMDV, ''),                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        CTA_PIS = ISNULL(Z6_CTPISDV, ''),                                                                                                     ") + msrhEnter
	QR007 += Alltrim("        CTA_COF = ISNULL(Z6_CTCOFDV, '')                                                                                                      ") + msrhEnter
	QR007 += Alltrim(" FROM " + RetSqlName("SD1") + " SD1(NOLOCK)                                                                                                   ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("SD2") + " SD2(NOLOCK) ON SD2.D2_FILIAL = SD1.D1_FILIAL                                                       ") + msrhEnter
	QR007 += Alltrim("                                       AND SD2.D2_DOC = SD1.D1_NFORI                                                                          ") + msrhEnter
	QR007 += Alltrim("                                       AND SD2.D2_ITEM = SD1.D1_ITEMORI                                                                       ") + msrhEnter
	QR007 += Alltrim("                                       AND SD2.D2_SERIE = SD1.D1_SERIORI                                                                      ") + msrhEnter
	QR007 += Alltrim("                                       AND SD2.D2_CLIENTE = SD1.D1_FORNECE                                                                    ") + msrhEnter
	QR007 += Alltrim("                                       AND SD2.D2_LOJA = SD1.D1_LOJA                                                                          ") + msrhEnter
	QR007 += Alltrim("                                       AND SD2.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("SF4") + " SF4(NOLOCK) ON SF4.F4_FILIAL = SD1.D1_FILIAL                                                       ") + msrhEnter
	QR007 += Alltrim("                                       AND SF4.F4_CODIGO = SD2.D2_TES                                                                         ") + msrhEnter
	QR007 += Alltrim("                                       AND SF4.F4_DUPLIC = 'S'                                                                                ") + msrhEnter
	QR007 += Alltrim("                                       AND SF4.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("SF1") + " SF1(NOLOCK) ON SF1.F1_FILIAL = SD1.D1_FILIAL                                                       ") + msrhEnter
	QR007 += Alltrim("                                       AND SF1.F1_DOC = SD1.D1_DOC                                                                            ") + msrhEnter
	QR007 += Alltrim("                                       AND SF1.F1_SERIE = SD1.D1_SERIE                                                                        ") + msrhEnter
	QR007 += Alltrim("                                       AND SF1.F1_FORNECE = SD1.D1_FORNECE                                                                    ") + msrhEnter
	QR007 += Alltrim("                                       AND SF1.F1_LOJA = SD1.D1_LOJA                                                                          ") + msrhEnter
	QR007 += Alltrim("                                       AND SF1.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'                                            ") + msrhEnter
	QR007 += Alltrim("                                       AND SB1.B1_COD = SD1.D1_COD                                                                            ") + msrhEnter
	QR007 += Alltrim("                                       AND SB1.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      INNER JOIN " + RetSqlName("Z35") + " Z35(NOLOCK) ON Z35_FILIAL = '" + xFilial("Z35") + "'                                               ") + msrhEnter
	QR007 += Alltrim("                                       AND Z35.Z35_CODCLI = SD2.D2_CLIENTE                                                                    ") + msrhEnter
	QR007 += Alltrim("                                       AND Z35.Z35_LOJCLI = SD2.D2_LOJA                                                                       ") + msrhEnter
	QR007 += Alltrim("                                       AND NOT Z35_TIPO IN('04', '05')                                                                        ") + msrhEnter
	QR007 += Alltrim("                                       AND Z35.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim("      LEFT JOIN " + RetSqlName("SZ6") + " SZ6(NOLOCK) ON SZ6.Z6_FILIAL = '" + xFilial("SZ6") + "'                                             ") + msrhEnter
	QR007 += Alltrim("                                       AND SZ6.Z6_TPPROD = SB1.B1_YTPPROD                                                                     ") + msrhEnter
	QR007 += Alltrim("                                       AND SZ6.D_E_L_E_T_ = ' '                                                                               ") + msrhEnter
	QR007 += Alltrim(" WHERE SD1.D1_FILIAL = '" + xFilial("SD1")+ "'                                                                                                ") + msrhEnter
	QR007 += Alltrim("       AND SD1.D1_DTDIGIT BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "'                                                       ") + msrhEnter
	QR007 += Alltrim("       AND SD1.D1_TIPO = 'D'                                                                                                                  ") + msrhEnter
	QR007 += Alltrim("       AND SD1.D_E_L_E_T_ = ' '                                                                                                               ") + msrhEnter

	xStringFAT += QR007

	// String para obtenção dos dados oriundos do CONTABIL
	QR004 := Alltrim(" SELECT EMPORI = '" + cEmpAnt + "',                                                                            ") + msrhEnter
	QR004 += Alltrim("        FILORI = CT2_FILIAL,                                                                                   ") + msrhEnter
	QR004 += Alltrim("        EMPDES = SUBSTRING(CT2_ITEMD, 4, 2),                                                                   ") + msrhEnter
	QR004 += Alltrim("        FILDES = SUBSTRING(CT2_ITEMD, 6, 2),                                                                   ") + msrhEnter
	QR004 += Alltrim("        DTREF = CT2_DATA,                                                                                      ") + msrhEnter
	QR004 += Alltrim("        DC = 'DEB',                                                                                            ") + msrhEnter
	QR004 += Alltrim("        CONTA = CT2_DEBITO,                                                                                    ") + msrhEnter
	QR004 += Alltrim("        ITCONTA = CT2_ITEMD,                                                                                   ") + msrhEnter
	QR004 += Alltrim("        VALOR = CT2_VALOR,                                                                                     ") + msrhEnter
	QR004 += Alltrim("        HISTORIC = CT2_HIST,                                                                                   ") + msrhEnter
	QR004 += Alltrim("        ROTINA = CT2_ROTINA                                                                                    ") + msrhEnter
	QR004 += Alltrim(" FROM " + RetSqlName("CT2") + " CT2(NOLOCK)                                                                    ") + msrhEnter
	QR004 += Alltrim(" WHERE CT2_FILIAL = '" + xFilial("CT2") + "'                                                                   ") + msrhEnter
	QR004 += Alltrim("       AND CT2_DATA BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "'                              ") + msrhEnter
	QR004 += Alltrim("       AND SUBSTRING(CT2_DEBITO, 1, 3) IN('411', '412')                                                        ") + msrhEnter
	QR004 += Alltrim(" AND NOT CT2_ROTINA IN('MATA460   ', 'MATA520   ', 'MATA103   ')                                               ") + msrhEnter
	QR004 += Alltrim(" AND CT2.D_E_L_E_T_ = ' '                                                                                      ") + msrhEnter
	QR004 += Alltrim(" UNION ALL                                                                                                     ") + msrhEnter
	QR004 += Alltrim(" SELECT EMPORI = '" + cEmpAnt + "',                                                                            ") + msrhEnter
	QR004 += Alltrim("        FILORI = CT2_FILIAL,                                                                                   ") + msrhEnter
	QR004 += Alltrim("        EMPDES = SUBSTRING(CT2_ITEMC, 4, 2),                                                                   ") + msrhEnter
	QR004 += Alltrim("        FILDES = SUBSTRING(CT2_ITEMC, 6, 2),                                                                   ") + msrhEnter
	QR004 += Alltrim("        DTREF = CT2_DATA,                                                                                      ") + msrhEnter
	QR004 += Alltrim("        DC = 'CRD',                                                                                            ") + msrhEnter
	QR004 += Alltrim("        CONTA = CT2_CREDIT,                                                                                    ") + msrhEnter
	QR004 += Alltrim("        ITCONTA = CT2_ITEMC,                                                                                   ") + msrhEnter
	QR004 += Alltrim("        VALOR = CT2_VALOR,                                                                                     ") + msrhEnter
	QR004 += Alltrim("        HISTORIC = CT2_HIST,                                                                                   ") + msrhEnter
	QR004 += Alltrim("        ROTINA = CT2_ROTINA                                                                                    ") + msrhEnter
	QR004 += Alltrim(" FROM " + RetSqlName("CT2") + " CT2(NOLOCK)                                                                    ") + msrhEnter
	QR004 += Alltrim(" WHERE CT2_FILIAL = '" + xFilial("CT2") + "'                                                                   ") + msrhEnter
	QR004 += Alltrim("       AND CT2_DATA BETWEEN '" + dtos(dDataIni) + "' AND '" + dtos(dDataFin) + "'                              ") + msrhEnter
	QR004 += Alltrim("       AND SUBSTRING(CT2_CREDIT, 1, 3) IN('411', '412')                                                        ") + msrhEnter
	QR004 += Alltrim(" AND NOT CT2_ROTINA IN('MATA460   ', 'MATA520   ', 'MATA103   ')                                               ") + msrhEnter
	QR004 += Alltrim(" AND CT2.D_E_L_E_T_ = ' '                                                                                      ") + msrhEnter

	xStringCTB += QR004

	// Carga de dados na nova tabela PPC - Por padrão o insert será realizado apenas na empresa 90.
	QR009 := Alltrim(" INSERT INTO ZNC900 (ZNC_FILIAL, ZNC_DATPRC, ZNC_EMPORI, ZNC_FILORI, ZNC_EMPDES, ZNC_FILDES, ZNC_TABMOV, ZNC_ORIMOV, ZNC_DATMOV, ZNC_DOC, ZNC_SERIE, ZNC_CODPRD, ZNC_TIPONF, ZNC_CFOP, ZNC_GRPPRD, ZNC_YTPPRO, ZNC_CRDICM, ZNC_CALICM, ZNC_LFICM, ZNC_DUPLIC, ZNC_YCCONT, ZNC_CLIENT, ZNC_LOJA, ZNC_ESTADO, ZNC_ITCTA, ZNC_HISLAN, ZNC_ROTINA, ZNC_QUANT, ZNC_CTACTB, ZNC_CTAREC, ZNC_CTAICM, ZNC_CTAPIS, ZNC_CTACOF, ZNC_CTAIPI, ZNC_VLRCTB, ZNC_VLRREC, ZNC_VLRICM, ZNC_VLRPIS, ZNC_VLRCOF, ZNC_VLRIPI, D_E_L_E_T_, R_E_C_N_O_, R_E_C_D_E_L_, ZNC_DC)   ") + msrhEnter
	QR009 += Alltrim(" SELECT ZNC_FILIAL = '  ',                                                                                                                                                                                            ") + msrhEnter
	QR009 += Alltrim("        ZNC_DATPRC = '" + dtos(dDataFin) + "',                                                                                                                                                                        ") + msrhEnter
	QR009 += Alltrim("        ZNC_EMPORI = EMPORI,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        ZNC_FILORI = FILORI,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        ZNC_EMPDES = EMPDES,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        ZNC_FILDES = FILDES,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        ZNC_TABMOV = 'FAT',                                                                                                                                                                                           ") + msrhEnter
	QR009 += Alltrim("        ZNC_ORIMOV = ORIGMOV,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_DATMOV = EMISSAO,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_DOC = DOC,                                                                                                                                                                                                ") + msrhEnter
	QR009 += Alltrim("        ZNC_SERIE = SERIE,                                                                                                                                                                                            ") + msrhEnter
	QR009 += Alltrim("        ZNC_CODPRD = COD,                                                                                                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        ZNC_TIPONF = TIPO,                                                                                                                                                                                            ") + msrhEnter
	QR009 += Alltrim("        ZNC_CFOP = CF,                                                                                                                                                                                                ") + msrhEnter
	QR009 += Alltrim("        ZNC_GRPPRD = GRUPO,                                                                                                                                                                                           ") + msrhEnter
	QR009 += Alltrim("        ZNC_YTPPRO = YTPPROD,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_CRDICM = CREDICM,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_CALICM = ICM,                                                                                                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        ZNC_LFICM = LFICM,                                                                                                                                                                                            ") + msrhEnter
	QR009 += Alltrim("        ZNC_DUPLIC = DUPLIC,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        ZNC_YCCONT = YCCONT,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        ZNC_CLIENT = CLIENTE,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_LOJA = LOJA,                                                                                                                                                                                              ") + msrhEnter
	QR009 += Alltrim("        ZNC_ESTADO = EST,                                                                                                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        ZNC_ITCTA = '',                                                                                                                                                                                               ") + msrhEnter
	QR009 += Alltrim("        ZNC_HISLAN = '',                                                                                                                                                                                              ") + msrhEnter
	QR009 += Alltrim("        ZNC_ROTINA = '',                                                                                                                                                                                              ") + msrhEnter
	QR009 += Alltrim("        ZNC_QUANT = QUANT,                                                                                                                                                                                            ") + msrhEnter
	QR009 += Alltrim("        ZNC_CTACTB = '',                                                                                                                                                                                              ") + msrhEnter
	QR009 += Alltrim("        ZNC_CTAREC = ISNULL(CTA_REC, ''),                                                                                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        ZNC_CTAICM = ISNULL(CTA_ICM, ''),                                                                                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        ZNC_CTAPIS = ISNULL(CTA_PIS, ''),                                                                                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        ZNC_CTACOF = ISNULL(CTA_COF, ''),                                                                                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        ZNC_CTAIPI = ISNULL(CTA_IPI, ''),                                                                                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        ZNC_VLRCTB = 0,                                                                                                                                                                                               ") + msrhEnter
	QR009 += Alltrim("        ZNC_VLRREC = VALOR,                                                                                                                                                                                           ") + msrhEnter
	QR009 += Alltrim("        ZNC_VLRICM = VALICM,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        ZNC_VLRPIS = VALIMP6,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_VLRCOF = VALIMP5,                                                                                                                                                                                         ") + msrhEnter
	QR009 += Alltrim("        ZNC_VLRIPI = VALIPI,                                                                                                                                                                                          ") + msrhEnter
	QR009 += Alltrim("        D_E_L_E_T_ = ' ',                                                                                                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        R_E_C_N_O_ = (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM ZNC900) + ROW_NUMBER() OVER(ORDER BY EMPORI),                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        R_E_C_D_E_L_ = 0,                                                                                                                                                                                             ") + msrhEnter
	QR009 += Alltrim("        ZNC_DC = ' '                                                                                                                                                                                                  ") + msrhEnter
	QR009 += Alltrim(" FROM                                                                                                                                                                                                                 ") + msrhEnter
	QR009 += Alltrim(" (                                                                                                                                                                                                                    ") + msrhEnter
	QR009 += QR007
	QR009 += Alltrim(" ) AS TEMP1                                                                                                                                                                                                           ") + msrhEnter
	U_BIAMsgRun("Aguarde... Gravando Registros FAT... ",,{|| msStaExcQy := TcSQLExec(QR009) })

	If msStaExcQy < 0
		lRet := .F.
	EndIf

	If !lRet

		msErroQuery := "Empresa: " + cEmpAnt + msrhEnter + msrhEnter
		msErroQuery += "Filial: " + cFilAnt + msrhEnter + msrhEnter
		msErroQuery += "ORIMOV FAT" + msrhEnter + msrhEnter
		msErroQuery += TCSQLError()

	Else

		QR009 := Alltrim(" INSERT INTO ZNC900 (ZNC_FILIAL, ZNC_DATPRC, ZNC_EMPORI, ZNC_FILORI, ZNC_EMPDES, ZNC_FILDES, ZNC_TABMOV, ZNC_ORIMOV, ZNC_DATMOV, ZNC_DOC, ZNC_SERIE, ZNC_CODPRD, ZNC_TIPONF, ZNC_CFOP, ZNC_GRPPRD, ZNC_YTPPRO, ZNC_CRDICM, ZNC_CALICM, ZNC_LFICM, ZNC_DUPLIC, ZNC_YCCONT, ZNC_CLIENT, ZNC_LOJA, ZNC_ESTADO, ZNC_ITCTA, ZNC_HISLAN, ZNC_ROTINA, ZNC_QUANT, ZNC_CTACTB, ZNC_CTAREC, ZNC_CTAICM, ZNC_CTAPIS, ZNC_CTACOF, ZNC_CTAIPI, ZNC_VLRCTB, ZNC_VLRREC, ZNC_VLRICM, ZNC_VLRPIS, ZNC_VLRCOF, ZNC_VLRIPI, D_E_L_E_T_, R_E_C_N_O_, R_E_C_D_E_L_, ZNC_DC)   ") + msrhEnter
		QR009 += Alltrim(" SELECT ZNC_FILIAL = '  ',                                                                                                                                                                                        ") + msrhEnter
		QR009 += Alltrim("        ZNC_DATPRC = '" + dtos(dDataFin) + "',                                                                                                                                                                    ") + msrhEnter
		QR009 += Alltrim("        ZNC_EMPORI = EMPORI,                                                                                                                                                                                      ") + msrhEnter
		QR009 += Alltrim("        ZNC_FILORI = FILORI,                                                                                                                                                                                      ") + msrhEnter
		QR009 += Alltrim("        ZNC_EMPDES = EMPDES,                                                                                                                                                                                      ") + msrhEnter
		QR009 += Alltrim("        ZNC_FILDES = FILDES,                                                                                                                                                                                      ") + msrhEnter
		QR009 += Alltrim("        ZNC_TABMOV = 'CTB',                                                                                                                                                                                       ") + msrhEnter
		QR009 += Alltrim("        ZNC_ORIMOV = DC,                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_DATMOV = DTREF,                                                                                                                                                                                       ") + msrhEnter
		QR009 += Alltrim("        ZNC_DOC = '',                                                                                                                                                                                             ") + msrhEnter
		QR009 += Alltrim("        ZNC_SERIE = '',                                                                                                                                                                                           ") + msrhEnter
		QR009 += Alltrim("        ZNC_CODPRD = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_TIPONF = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_CFOP = '',                                                                                                                                                                                            ") + msrhEnter
		QR009 += Alltrim("        ZNC_GRPPRD = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_YTPPRO = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_CRDICM = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_CALICM = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_LFICM = '',                                                                                                                                                                                           ") + msrhEnter
		QR009 += Alltrim("        ZNC_DUPLIC = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_YCCONT = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_CLIENT = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_LOJA = '',                                                                                                                                                                                            ") + msrhEnter
		QR009 += Alltrim("        ZNC_ESTADO = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_ITCTA = ITCONTA,                                                                                                                                                                                      ") + msrhEnter
		QR009 += Alltrim("        ZNC_HISLAN = HISTORIC,                                                                                                                                                                                    ") + msrhEnter
		QR009 += Alltrim("        ZNC_ROTINA = ROTINA,                                                                                                                                                                                      ") + msrhEnter
		QR009 += Alltrim("        ZNC_QUANT = 0,                                                                                                                                                                                            ") + msrhEnter
		QR009 += Alltrim("        ZNC_CTACTB = CONTA,                                                                                                                                                                                       ") + msrhEnter
		QR009 += Alltrim("        ZNC_CTAREC = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_CTAICM = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_CTAPIS = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_CTACOF = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_CTAIPI = '',                                                                                                                                                                                          ") + msrhEnter
		QR009 += Alltrim("        ZNC_VLRCTB = VALOR,                                                                                                                                                                                       ") + msrhEnter
		QR009 += Alltrim("        ZNC_VLRREC = 0,                                                                                                                                                                                           ") + msrhEnter
		QR009 += Alltrim("        ZNC_VLRICM = 0,                                                                                                                                                                                           ") + msrhEnter
		QR009 += Alltrim("        ZNC_VLRPIS = 0,                                                                                                                                                                                           ") + msrhEnter
		QR009 += Alltrim("        ZNC_VLRCOF = 0,                                                                                                                                                                                           ") + msrhEnter
		QR009 += Alltrim("        ZNC_VLRIPI = 0,                                                                                                                                                                                           ") + msrhEnter
		QR009 += Alltrim("        D_E_L_E_T_ = ' ',                                                                                                                                                                                         ") + msrhEnter
		QR009 += Alltrim("        R_E_C_N_O_ = (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM ZNC900) + ROW_NUMBER() OVER(ORDER BY EMPORI),                                                                                                         ") + msrhEnter
		QR009 += Alltrim("        R_E_C_D_E_L_ = 0,                                                                                                                                                                                         ") + msrhEnter
		QR009 += Alltrim("        ZNC_DC = ' '                                                                                                                                                                                              ") + msrhEnter
		QR009 += Alltrim(" FROM                                                                                                                                                                                                             ") + msrhEnter
		QR009 += Alltrim(" (                                                                                                                                                                                                                ") + msrhEnter
		QR009 += QR004
		QR009 += Alltrim(" ) AS TEMP1                                                                                                                                                                                                       ") + msrhEnter
		U_BIAMsgRun("Aguarde... Gravando Registros CTB... ",,{|| msStaExcQy := TcSQLExec(QR009) })

		If msStaExcQy < 0
			lRet := .F.
		EndIf

		If !lRet

			msErroQuery := "Empresa: " + cEmpAnt + msrhEnter + msrhEnter
			msErroQuery += "Filial: " + cFilAnt + msrhEnter + msrhEnter
			msErroQuery += "ORIMOV CTB" + msrhEnter + msrhEnter
			msErroQuery += TCSQLError()

		EndIf

	EndIf

	xVerRet := lRet 

Return ( lRet )
