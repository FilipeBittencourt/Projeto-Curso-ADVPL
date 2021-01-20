#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA599
@author Wlysses Cerqueira (Facile)
@since 26/10/2020
@version 1.0
@description Consolidação empresas grupo para filial 90. 
@type function
@Obs Projeto A-35
/*/

User Function BIA599()

	Local oEmp 	:= Nil
	Local oPerg	:= Nil

	Private cTitulo := "Excel ZBZ x DRE"

	oEmp := TLoadEmpresa():New()

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte()

		oEmp:GetSelEmp()

		If Len(oEmp:aEmpSel) > 0

			FWMsgRun(, {|| RunExcel(oEmp:aEmpSel, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef) }, "Processando", "Gerando excel...")

		Else

			Alert("Nenhuma empresa foi selecionada!")

		EndIf

	EndIf

Return()

Static Function RunExcel(aEmp, cVersao, cRevisa, cAnoRef)

	Local lRet  := .F.
	Local nW    := 0
	Local cSQL  := ""
	Local cQry  := GetNextAlias()

	Local cSheet	:= ""
	Local cTitSheet	:= ""

	Local oFWExcel	:= FWMsExcel():New()
	Local cDir		:= GetSrvProfString("Startpath", "")
	Local cDirTemp	:= AllTrim(GetTempPath())
	Local cFile		:= "ZBZ X DRE - " + __cUserID + "-" + dToS(Date()) + "-" + StrTran(Time(), ":", "") + ".xml"

	cSheet := "Relatorio" //"Empresa: " + aEmp[nW][1]
	cTitSheet := "Extrato ZBZ x DRE(Visão)" //"Extrato ZBZ x DRE - Empresa: " + aEmp[nW][1]
	oFWExcel:AddWorkSheet(cSheet)
	oFWExcel:AddTable(cSheet, cTitSheet)

	//4 - Alinhamento da coluna ( 1-Left	,2-Center,3-Right )
	//5 - Codigo de formatação  ( 1-General	,2-Number,3-Monetário,4-DateTime )

	oFWExcel:AddColumn(cSheet, cTitSheet, "EMPRESA"	, 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "FILIAL"	, 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "CODPLA"	, 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "ORDEM"	, 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "CONTAG"	, 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "CTASUP"	, 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "DESCCG"	, 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "LINHA"	, 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "ORIG"	, 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "ORIPRC"	, 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "DTREF"	, 1, 4)
	oFWExcel:AddColumn(cSheet, cTitSheet, "ZBZ_DC"	, 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "CONTA"	, 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "CLVL"	, 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "VALOR"	, 3, 2)
	oFWExcel:AddColumn(cSheet, cTitSheet, "REGZBZ"	, 1)

	For nW := 1 To Len(aEmp)

		xVerRet := .F.
		Processa({ || fExistTabl(RetFullName("ZBZ", aEmp[nW][1])) }, "Aguarde...", "Verificando OrcaFinal na empresa: " + aEmp[nW][1], .F.)
		If xVerRet

			cSQL := " WITH RESULTADO "
			cSQL += " AS ( "
			cSQL += "         SELECT " + ValToSql(aEmp[nW][1]) + " EMPRESA,  "
			cSQL += "               ZBZ_FILIAL FILIAL,  "
			cSQL += "               'D' ORIG,  "
			cSQL += "               ZBZ_ORIPRC ORIPRC,  "
			cSQL += "               ZBZ_DATA DTREF,  "
			cSQL += "               ZBZ_DC,  "
			cSQL += "               ZBZ_DEBITO CONTA,  "
			cSQL += "               ZBZ_CLVLDB CLVL,  "
			cSQL += "               ZBZ_VALOR VALOR,  "
			cSQL += "               R_E_C_N_O_ REGZBZ "
			cSQL += "         FROM " + RetFullName("ZBZ", aEmp[nW][1]) + " A "
			cSQL += "         WHERE ZBZ_FILIAL BETWEEN '  ' AND 'ZZ' "
			cSQL += "               AND ZBZ_VERSAO	= " + ValToSQL(cVersao)
			cSQL += "               AND ZBZ_REVISA	= " + ValToSQL(cRevisa)
			cSQL += "               AND ZBZ_ANOREF	= " + ValToSQL(cAnoRef)
			cSQL += "               AND SUBSTRING(ZBZ_DEBITO, 1, 1) IN('3', '6') "
			cSQL += "               AND ZBZ_CLVLDB <> '' "
			cSQL += "               AND D_E_L_E_T_ = ' ' "

			cSQL += "         UNION ALL "

			cSQL += "         SELECT " + ValToSql(aEmp[nW][1]) + " EMPRESA,  "
			cSQL += "               ZBZ_FILIAL FILIAL,  "
			cSQL += "               'C' ORIG,  "
			cSQL += "               ZBZ_ORIPRC ORIPRC,  "
			cSQL += "               ZBZ_DATA DTREF,  "
			cSQL += "               ZBZ_DC,  "
			cSQL += "               ZBZ_CREDIT CONTA,  "
			cSQL += "               ZBZ_CLVLCR CLVL,  "
			cSQL += "               ZBZ_VALOR * (-1) VALOR,  "
			cSQL += "               R_E_C_N_O_ REGZBZ "
			cSQL += "         FROM " + RetFullName("ZBZ", aEmp[nW][1]) + " A "
			cSQL += "         WHERE ZBZ_FILIAL BETWEEN '  ' AND 'ZZ' "
			cSQL += "               AND ZBZ_VERSAO	= " + ValToSQL(cVersao)
			cSQL += "               AND ZBZ_REVISA	= " + ValToSQL(cRevisa)
			cSQL += "               AND ZBZ_ANOREF	= " + ValToSQL(cAnoRef)
			cSQL += "               AND SUBSTRING(ZBZ_CREDIT, 1, 1) IN('3', '6') "
			cSQL += "               AND ZBZ_CLVLCR <> '' "
			cSQL += "               AND D_E_L_E_T_ = ' ' "
			cSQL += "     ), "
			cSQL += " RECEITA "
			cSQL += " AS  ( "
			cSQL += "         SELECT " + ValToSql(aEmp[nW][1]) + " EMPRESA,  "
			cSQL += "               ZBZ_FILIAL FILIAL,  "
			cSQL += "               'D' ORIG,  "
			cSQL += "               ZBZ_ORIPRC ORIPRC,  "
			cSQL += "               ZBZ_DATA DTREF,  "
			cSQL += "               ZBZ_DC,  "
			cSQL += "               ZBZ_DEBITO CONTA,  "
			cSQL += "               ZBZ_CLVLDB CLVL,  "
			cSQL += "               ZBZ_VALOR VALOR,  "
			cSQL += "               R_E_C_N_O_ REGZBZ "
			cSQL += "         FROM " + RetFullName("ZBZ", aEmp[nW][1]) + " A "
			cSQL += "         WHERE ZBZ_FILIAL BETWEEN '  ' AND 'ZZ' "
			cSQL += "               AND ZBZ_VERSAO	= " + ValToSQL(cVersao)
			cSQL += "               AND ZBZ_REVISA	= " + ValToSQL(cRevisa)
			cSQL += "               AND ZBZ_ANOREF	= " + ValToSQL(cAnoRef)
			cSQL += "               AND SUBSTRING(ZBZ_DEBITO, 1, 1) IN('4') "
			cSQL += "               AND D_E_L_E_T_ = ' ' "

			cSQL += "         UNION ALL "

			cSQL += "         SELECT " + ValToSql(aEmp[nW][1]) + " EMPRESA,  "
			cSQL += "               ZBZ_FILIAL FILIAL,  "
			cSQL += "               'C' ORIG,  "
			cSQL += "               ZBZ_ORIPRC ORIPRC,  "
			cSQL += "               ZBZ_DATA DTREF,  "
			cSQL += "               ZBZ_DC,  "
			cSQL += "               ZBZ_CREDIT CONTA,  "
			cSQL += "               ZBZ_CLVLCR CLVL,  "
			cSQL += "               ZBZ_VALOR * (-1) VALOR,  "
			cSQL += "               R_E_C_N_O_ REGZBZ "
			cSQL += "         FROM " + RetFullName("ZBZ", aEmp[nW][1]) + " A "
			cSQL += "         WHERE ZBZ_FILIAL BETWEEN '  ' AND 'ZZ' "
			cSQL += "               AND ZBZ_VERSAO	= " + ValToSQL(cVersao)
			cSQL += "               AND ZBZ_REVISA	= " + ValToSQL(cRevisa)
			cSQL += "               AND ZBZ_ANOREF	= " + ValToSQL(cAnoRef)
			cSQL += "               AND SUBSTRING(ZBZ_CREDIT, 1, 1) IN('4') "
			cSQL += "               AND D_E_L_E_T_ = ' ' "
			cSQL += "     ), "
			cSQL += " VISAOX "
			cSQL += " AS  ( "
			cSQL += "         SELECT CTS_CODPLA,  "
			cSQL += "               CTS_ORDEM,  "
			cSQL += "               CTS_CONTAG,  "
			cSQL += "               CTS_CTASUP,  "
			cSQL += "               CTS_DESCCG,  "
			cSQL += "               CTS_LINHA,  "
			cSQL += "               CTS_CT1INI,  "
			cSQL += "               CTS_CT1FIM,  "
			cSQL += "               CTS_IDENT,  "
			cSQL += "               CTS_YNOCT1,  "
			cSQL += "               CTS_YINCVG,  "
			cSQL += "               CTS_YNOCVG "
			cSQL += "         FROM " + RetSqlName("CTS") + " (NOLOCK) "
			cSQL += "         WHERE CTS_FILIAL BETWEEN '  ' AND 'ZZ' "
			cSQL += "               AND CTS_CODPLA = '500' "
			cSQL += "               AND D_E_L_E_T_ = '' "
			cSQL += "     ) "

			cSQL += " SELECT EMPRESA,  "
			cSQL += "         FILIAL,  "
			cSQL += "         CTH_YCLVLG,  "
			cSQL += "         CTH_YENTID,  "
			cSQL += "         CT1_YPCT20,  "
			cSQL += "         CTS_CODPLA,  "
			cSQL += "         CTS_ORDEM,  "
			cSQL += "         CTS_CONTAG,  "
			cSQL += "         CTS_CTASUP,  "
			cSQL += "         CTS_DESCCG,  "
			cSQL += "         CTS_LINHA,  "
			cSQL += "         ORIG,  "
			cSQL += "         ORIPRC,  "
			cSQL += "         DTREF,  "
			cSQL += "         ZBZ_DC,  "
			cSQL += "         CONTA,  "
			cSQL += "         CLVL,  "
			cSQL += "         VALOR,  "
			cSQL += "         REGZBZ "
			cSQL += "  FROM   RESULTADO A "
			cSQL += "         INNER JOIN " + RetSqlName("CT1") + " B ON  "
			cSQL += "         ( "
			cSQL += "             B.CT1_FILIAL BETWEEN '  ' AND 'ZZ' "
			cSQL += "             AND B.CT1_CONTA = A.CONTA "
			cSQL += "             AND B.D_E_L_E_T_ = ' ' "
			cSQL += "         ) "
			cSQL += "         INNER JOIN " + RetSqlName("CTH") + " C ON  "
			cSQL += "         ( "
			cSQL += "             C.CTH_FILIAL BETWEEN '  ' AND 'ZZ' "
			cSQL += "             AND C.CTH_CLVL = A.CLVL "
			cSQL += "             AND C.D_E_L_E_T_ = ' ' "
			cSQL += "         ) "
			cSQL += "         INNER JOIN VISAOX D ON  "
			cSQL += "         ( "
			cSQL += "             A.CONTA BETWEEN D.CTS_CT1INI AND D.CTS_CT1FIM "
			cSQL += "             AND D.CTS_YNOCT1 NOT LIKE '%' + RTRIM(A.CONTA) + '%' "
			cSQL += "             AND D.CTS_YNOCVG NOT LIKE '%' + RTRIM(C.CTH_YCLVLG) + '%' "
			cSQL += "             AND ( D.CTS_YINCVG = '' OR D.CTS_YINCVG LIKE '%' + RTRIM(C.CTH_YCLVLG) + '%' ) "
			cSQL += "         ) "

			cSQL += " UNION ALL "

			cSQL += " SELECT  EMPRESA,  "
			cSQL += "         FILIAL,  "
			cSQL += "         '' CTH_YCLVLG,  "
			cSQL += "         '' CTH_YENTID,  "
			cSQL += "         CT1_YPCT20,  "
			cSQL += "         CTS_CODPLA,  "
			cSQL += "         CTS_ORDEM,  "
			cSQL += "         CTS_CONTAG,  "
			cSQL += "         CTS_CTASUP,  "
			cSQL += "         CTS_DESCCG,  "
			cSQL += "         CTS_LINHA,  "
			cSQL += "         ORIG,  "
			cSQL += "         ORIPRC,  "
			cSQL += "         DTREF,  "
			cSQL += "         ZBZ_DC,  "
			cSQL += "         CONTA,  "
			cSQL += "         CLVL,  "
			cSQL += "         VALOR,  "
			cSQL += "         REGZBZ "
			cSQL += " FROM    RECEITA A "
			cSQL += "         INNER JOIN " + RetSqlName("CT1") + " B ON  "
			cSQL += "         ( "
			cSQL += "             B.CT1_FILIAL BETWEEN '  ' AND 'ZZ' "
			cSQL += "             AND B.CT1_CONTA = A.CONTA "
			cSQL += "             AND B.D_E_L_E_T_ = ' ' "
			cSQL += "         ) "
			cSQL += "       INNER JOIN VISAOX D ON  "
			cSQL += "         ( "
			cSQL += "             A.CONTA BETWEEN D.CTS_CT1INI AND D.CTS_CT1FIM "
			cSQL += "             AND D.CTS_YNOCT1 NOT LIKE '%' + RTRIM(A.CONTA) + '%' "
			cSQL += "         ) "
			cSQL += "  ORDER BY 1, 2, 4, 5 "

			TcQuery cSQL New Alias (cQry)

			While !(cQry)->(Eof())

				oFWExcel:AddRow(cSheet, cTitSheet,;
				{;
				(cQry)->EMPRESA,;
				(cQry)->FILIAL,;
				(cQry)->CTS_CODPLA,;
				(cQry)->CTS_ORDEM,;
				(cQry)->CTS_CONTAG,;
				(cQry)->CTS_CTASUP,;
				(cQry)->CTS_DESCCG,;
				(cQry)->CTS_LINHA,;
				(cQry)->ORIG,;
				(cQry)->ORIPRC,;
				stod((cQry)->DTREF),;
				(cQry)->ZBZ_DC,;
				(cQry)->CONTA,;
				(cQry)->CLVL,;
				(cQry)->VALOR,;
				(cQry)->REGZBZ;
				})

				lRet := .T.

				(cQry)->(DbSkip())

			EndDo

			(cQry)->(DbCloseArea())

		EndIf

	Next nW

	If lRet

		oFWExcel:Activate()
		oFWExcel:GetXMLFile(cFile)
		oFWExcel:DeActivate()

		If Right(cDir,1) <> "\"

			cDir := cDir + "\"

		EndIf

		If CpyS2T(cDir + cFile, cDirTemp, .T.)

			If ApOleClient('MsExcel')

				oMSExcel := MsExcel():New()
				oMSExcel:WorkBooks:Close()
				oMSExcel:WorkBooks:Open(cDirTemp + cFile)
				oMSExcel:SetVisible(.T.)
				oMSExcel:Destroy()

			EndIf

		Else

			MsgInfo("Arquivo não copiado para a pasta temporária do usuário!")

		EndIf

	Else

		MsgInfo("Não foi encontrado dados!")

	EndIf

Return(lRet)

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
