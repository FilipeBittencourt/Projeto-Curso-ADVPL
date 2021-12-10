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

	Private cTitulo := "Excel ZBZ (e/ou CT2) x DRE"

	oEmp := TLoadEmpresa():New()

	If xValidPerg()

		xcVersao := MV_PAR01
		xcRevisa := MV_PAR02
		xcAnoRef := MV_PAR03
		xcTipRel := MV_PAR04
		xcDatIni := MV_PAR05
		xcDatFin := MV_PAR06

		If !xcTipRel $ "1/2"

			MsgSTOP("Origem dos Dados - não configurado!!! Processamento cancelado...", "BIA599")
			Return

		EndIf

		oEmp:GetSelEmp()

		If Len(oEmp:aEmpSel) > 0

			FWMsgRun(, {|| RunExcel(oEmp:aEmpSel, xcVersao, xcRevisa, xcAnoRef, xcTipRel, xcDatIni, xcDatFin) }, "Processando", "Gerando excel...")

		Else

			Alert("Nenhuma empresa foi selecionada!")

		EndIf

	EndIf

Return()

Static Function RunExcel(aEmp, cVersao, cRevisa, cAnoRef, cTipRel, cDatIni, cDatFin)

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

	oFWExcel:AddColumn(cSheet, cTitSheet, "EMPRESA"             , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "FILIAL"              , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "CODPLA"              , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "ORDEM"               , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "CTASUP"              , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "DESCSUP"             , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "CONTAG"              , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "DESCCG"              , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "LINHA"               , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "ORIG"                , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "ORIPRC"              , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "DTREF"               , 1, 4)
	oFWExcel:AddColumn(cSheet, cTitSheet, "DC"                  , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "CONTA"               , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "DESC_CTA"            , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "PACOTE"              , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "DESC_PCT"            , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "CLVL"                , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "DESC_CLVL"           , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "CLVG"                , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "DESC_CLVG"           , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "ENTIDADE"            , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "DESC_ENT"            , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "SETOR"               , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "DESC_SETOR"          , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "DRIVER"              , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "DESC_DRV"            , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "APLIC"               , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "DESC_APL"            , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "CENARIO"             , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "VALOR"               , 3, 2)
	oFWExcel:AddColumn(cSheet, cTitSheet, "TABELA"              , 1)
	oFWExcel:AddColumn(cSheet, cTitSheet, "REGTBL"              , 1)

	For nW := 1 To Len(aEmp)

		xVerRet := .F.
		Processa({ || fExistTabl(RetFullName("ZBZ", aEmp[nW][1])) }, "Aguarde...", "Verificando OrcaFinal na empresa: " + aEmp[nW][1], .F.)
		If xVerRet

			If cTipRel == "1"

				cSQL := U_B599ORC(aEmp, cVersao, cRevisa, cAnoRef, nW)

			ElseIf cTipRel == "2"

				cSQL := U_B599REA(aEmp, cDatIni, cDatFin, nW)

			End

			TcQuery cSQL New Alias (cQry)

			While !(cQry)->(Eof())

				ffDCTASUP := Posicione("CTS", 2, xFilial("CTS") + "500" + (cQry)->CTS_CTASUP, "CTS_DESCCG")

				oFWExcel:AddRow(cSheet, cTitSheet,;
				{;
				(cQry)->EMPRESA,;
				(cQry)->FILIAL,;
				(cQry)->CTS_CODPLA,;
				(cQry)->CTS_ORDEM,;
				(cQry)->CTS_CTASUP,;
				ffDCTASUP,;
				(cQry)->CTS_CONTAG,;
				(cQry)->CTS_DESCCG,;
				(cQry)->CTS_LINHA,;
				(cQry)->ORIG,;
				(cQry)->ORIPRC,;
				stod((cQry)->DTREF),;
				(cQry)->DC,;
				(cQry)->CONTA,;
				(cQry)->DESC_CTA,;
				(cQry)->PACOTE,;
				(cQry)->DESC_PCT,;
				(cQry)->CLVL,;
				(cQry)->DESC_CLVL,;
				(cQry)->CLVG,;
				(cQry)->DESC_CLVG,;
				(cQry)->ENTIDADE,;
				(cQry)->DESC_ENT,;
				(cQry)->SETOR,;
				(cQry)->DESC_SETOR,;
				(cQry)->DRIVER,;
				(cQry)->DESC_DRV,;
				(cQry)->APLIC,;
				(cQry)->DESC_APL,;
				(cQry)->CENARIO,;
				(cQry)->VALOR,;
				(cQry)->TABELA,;
				(cQry)->REGTBL;
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

Static Function xValidPerg()

	local cLoad	    := "BIA599" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}
	Local aTipos    := {"1=Orçado", "2=Realizado"} 

	MV_PAR01 :=	Space(10)
	MV_PAR02 :=	Space(03)
	MV_PAR03 :=	Space(04)
	MV_PAR04 :=	Space(01)
	MV_PAR05 :=	ctod("  /  /  ")
	MV_PAR06 :=	ctod("  /  /  ")

	aAdd( aPergs, {1, "Versão"              , MV_PAR01	, "@!", ".T.", "ZB5", "AllWaysTrue()", , .T. })	
	aAdd( aPergs, {1, "Revisão"             , MV_PAR02	, "@!", ".T.", ""	, "AllWaysTrue()", , .T. })
	aAdd( aPergs, {1, "Ano Ref."            , MV_PAR03	, "@!", ".T.", ""	, "AllWaysTrue()", , .T. })
	aAdd( aPergs ,{2, "Origem dos Dados?"   , MV_PAR04  ,aTipos,60,'.T.',.F.})
	aAdd( aPergs, {1, "REAL? - De Data:"    , MV_PAR05	, "@!", ".T.", ""	, "AllWaysTrue()", , .T. })
	aAdd( aPergs, {1, "REAL? - Até Data:"   , MV_PAR06	, "@!", ".T.", ""	, "AllWaysTrue()", , .T. })

	If ParamBox(aPergs ,"Parâmetros",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02) 
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04) 
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05) 
		MV_PAR06 := ParamLoad(cFileName,,6,MV_PAR05) 

	EndIf

Return lRet

User Function B599ORC(aEmp, cVersao, cRevisa, cAnoRef, nW)

	Local cSQL := ""

	cSQL := " WITH RESULTADO "
	cSQL += " AS ( "
	cSQL += "         SELECT " + ValToSql(aEmp[nW][1]) + " EMPRESA, "
	cSQL += "               ZBZ_FILIAL FILIAL, "
	cSQL += "               'D' ORIG, "
	cSQL += "               ZBZ_ORIPRC ORIPRC, "
	cSQL += "               ZBZ_DATA DTREF, "
	cSQL += "               ZBZ_DC DC, "
	cSQL += "               ZBZ_DEBITO CONTA, "
	cSQL += "               ZBZ_CLVLDB CLVL, "
	cSQL += "               ZBZ_DRVDB DRIVER, "
	cSQL += "               ZBZ_APLIC APLIC, "
	cSQL += "               ZBZ_CENARI CENARIO, "
	cSQL += "               ZBZ_VALOR VALOR, "
	cSQL += "               R_E_C_N_O_ REGTBL "
	cSQL += "         FROM " + RetFullName("ZBZ", aEmp[nW][1]) + " A(NOLOCK) "
	cSQL += "         WHERE ZBZ_FILIAL BETWEEN '  ' AND 'ZZ' "
	cSQL += "               AND ZBZ_VERSAO	= " + ValToSQL(cVersao)
	cSQL += "               AND ZBZ_REVISA	= " + ValToSQL(cRevisa)
	cSQL += "               AND ZBZ_ANOREF	= " + ValToSQL(cAnoRef)
	cSQL += "               AND SUBSTRING(ZBZ_DEBITO, 1, 1) IN('3', '6') "
	cSQL += "               AND ZBZ_CLVLDB <> '' "
	cSQL += "               AND D_E_L_E_T_ = ' ' "

	cSQL += "         UNION ALL "

	cSQL += "         SELECT " + ValToSql(aEmp[nW][1]) + " EMPRESA, "
	cSQL += "               ZBZ_FILIAL FILIAL, "
	cSQL += "               'C' ORIG, "
	cSQL += "               ZBZ_ORIPRC ORIPRC, "
	cSQL += "               ZBZ_DATA DTREF, "
	cSQL += "               ZBZ_DC DC, "
	cSQL += "               ZBZ_CREDIT CONTA, "
	cSQL += "               ZBZ_CLVLCR CLVL, "
	cSQL += "               ZBZ_DRVCR DRIVER, "
	cSQL += "               ZBZ_APLIC APLIC, "
	cSQL += "               ZBZ_CENARI CENARIO, "
	cSQL += "               ZBZ_VALOR * (-1) VALOR, "
	cSQL += "               R_E_C_N_O_ REGTBL "
	cSQL += "         FROM " + RetFullName("ZBZ", aEmp[nW][1]) + " A(NOLOCK) "
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
	cSQL += "         SELECT " + ValToSql(aEmp[nW][1]) + " EMPRESA, "
	cSQL += "               ZBZ_FILIAL FILIAL, "
	cSQL += "               'D' ORIG, "
	cSQL += "               ZBZ_ORIPRC ORIPRC, "
	cSQL += "               ZBZ_DATA DTREF, "
	cSQL += "               ZBZ_DC DC, "
	cSQL += "               ZBZ_DEBITO CONTA, "
	cSQL += "               ZBZ_CLVLDB CLVL, "
	cSQL += "               ZBZ_DRVDB DRIVER, "
	cSQL += "               ZBZ_APLIC APLIC, "
	cSQL += "               ZBZ_CENARI CENARIO, "
	cSQL += "               ZBZ_VALOR VALOR, "
	cSQL += "               R_E_C_N_O_ REGTBL "
	cSQL += "         FROM " + RetFullName("ZBZ", aEmp[nW][1]) + " A(NOLOCK) "
	cSQL += "         WHERE ZBZ_FILIAL BETWEEN '  ' AND 'ZZ' "
	cSQL += "               AND ZBZ_VERSAO	= " + ValToSQL(cVersao)
	cSQL += "               AND ZBZ_REVISA	= " + ValToSQL(cRevisa)
	cSQL += "               AND ZBZ_ANOREF	= " + ValToSQL(cAnoRef)
	cSQL += "               AND SUBSTRING(ZBZ_DEBITO, 1, 1) IN('4') "
	cSQL += "               AND D_E_L_E_T_ = ' ' "

	cSQL += "         UNION ALL "

	cSQL += "         SELECT " + ValToSql(aEmp[nW][1]) + " EMPRESA, "
	cSQL += "               ZBZ_FILIAL FILIAL, "
	cSQL += "               'C' ORIG, "
	cSQL += "               ZBZ_ORIPRC ORIPRC, "
	cSQL += "               ZBZ_DATA DTREF, "
	cSQL += "               ZBZ_DC DC, "
	cSQL += "               ZBZ_CREDIT CONTA, "
	cSQL += "               ZBZ_CLVLCR CLVL, "
	cSQL += "               ZBZ_DRVCR DRIVER, "
	cSQL += "               ZBZ_APLIC APLIC, "
	cSQL += "               ZBZ_CENARI CENARIO, "
	cSQL += "               ZBZ_VALOR * (-1) VALOR, "
	cSQL += "               R_E_C_N_O_ REGTBL "
	cSQL += "         FROM " + RetFullName("ZBZ", aEmp[nW][1]) + " A(NOLOCK) "
	cSQL += "         WHERE ZBZ_FILIAL BETWEEN '  ' AND 'ZZ' "
	cSQL += "               AND ZBZ_VERSAO	= " + ValToSQL(cVersao)
	cSQL += "               AND ZBZ_REVISA	= " + ValToSQL(cRevisa)
	cSQL += "               AND ZBZ_ANOREF	= " + ValToSQL(cAnoRef)
	cSQL += "               AND SUBSTRING(ZBZ_CREDIT, 1, 1) IN('4') "
	cSQL += "               AND D_E_L_E_T_ = ' ' "
	cSQL += "     ), "
	cSQL += " VISAOX "
	cSQL += " AS  ( "
	cSQL += "         SELECT CTS_CODPLA, "
	cSQL += "               CTS_ORDEM, "
	cSQL += "               CTS_CONTAG, "
	cSQL += "               CTS_CTASUP, "
	cSQL += "               CTS_DESCCG, "
	cSQL += "               CTS_LINHA, "
	cSQL += "               CTS_CT1INI, "
	cSQL += "               CTS_CT1FIM, "
	cSQL += "               CTS_IDENT, "
	cSQL += "               CTS_YNOCT1, "
	cSQL += "               CTS_YINCVG, "
	cSQL += "               CTS_YNOCVG "
	cSQL += "         FROM " + RetSqlName("CTS") + " CTS(NOLOCK) "
	cSQL += "         WHERE CTS_FILIAL = '" + xFilial("CTS") + "' "
	cSQL += "               AND CTS_CODPLA = '500' "
	cSQL += "               AND D_E_L_E_T_ = '' "
	cSQL += "     ) "

	cSQL += " SELECT EMPRESA, "
	cSQL += "         FILIAL, "
	cSQL += "         CTH_YCLVLG, "
	cSQL += "         CTH_YENTID, "
	cSQL += "         CT1_YPCT20, "
	cSQL += "         CTS_CODPLA, "
	cSQL += "         CTS_ORDEM, "
	cSQL += "         CTS_CONTAG, "
	cSQL += "         CTS_CTASUP, "
	cSQL += "         CTS_DESCCG, "
	cSQL += "         CTS_LINHA, "
	cSQL += "         ORIG, "
	cSQL += "         ORIPRC, "
	cSQL += "         DTREF, "
	cSQL += "         DC, "
	cSQL += "         CONTA, "
	cSQL += "         DESC_CTA = CT1_DESC01, "
	cSQL += "         PACOTE = CT1_YPCT20, "
	cSQL += "         DESC_PCT = ZC8_DESCRI, "
	cSQL += "         CLVL, "
	cSQL += "         DESC_CLVL = CTH_DESC01, "
	cSQL += "         CLVG = CTH_YCLVLG, "
	cSQL += "         DESC_CLVG = Z39_DESCR, "
	cSQL += "         ENTIDADE = CTH_YENTID, "
	cSQL += "         DESC_ENT = ZCA_DESCRI, "
	cSQL += "         DRIVER, "
	cSQL += "         DESC_DRV = ZBE_DESCRI, "
	cSQL += "         SETOR = CTH_YSETOR, "
	cSQL += "         DESC_SETOR = ZCB_DESCRI, "
	cSQL += "         APLIC, "
	cSQL += "         DESC_APL = CASE "
	cSQL += "                        WHEN APLIC = '0' "
	cSQL += "                        THEN 'Nenhum' "
	cSQL += "                        WHEN APLIC = '1' "
	cSQL += "                        THEN 'Producao' "
	cSQL += "                        WHEN APLIC = '2' "
	cSQL += "                        THEN 'Manutencao' "
	cSQL += "                        WHEN APLIC = '3' "
	cSQL += "                        THEN 'Melhoria_M' "
	cSQL += "                        WHEN APLIC = '4' "
	cSQL += "                        THEN 'Seguranca' "
	cSQL += "                        WHEN APLIC = '5' "
	cSQL += "                        THEN 'Calibracao' "
	cSQL += "                        WHEN APLIC = '6' "
	cSQL += "                        THEN 'Melhoria_Prod' "
	cSQL += "                        WHEN APLIC = '7' "
	cSQL += "                        THEN 'Administrativo' "
	cSQL += "                        WHEN APLIC = '8' "
	cSQL += "                        THEN 'Fiscal' "
	cSQL += "                        WHEN APLIC = '9' "
	cSQL += "                        THEN 'Patrimonial' "
	cSQL += "                        ELSE '' "
	cSQL += "                    END, "
	cSQL += "         CENARIO, "
	cSQL += "         VALOR, "
	cSQL += "         TABELA = 'ZBZ', "
	cSQL += "         REGTBL "
	cSQL += "  FROM   RESULTADO A "
	cSQL += "         INNER JOIN " + RetSqlName("CT1") + " B(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             B.CT1_FILIAL = '" + xFilial("CT1") + "' "
	cSQL += "             AND B.CT1_CONTA = A.CONTA "
	cSQL += "             AND B.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "         INNER JOIN " + RetSqlName("CTH") + " C(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             C.CTH_FILIAL = '" + xFilial("CTH") + "' "
	cSQL += "             AND C.CTH_CLVL = A.CLVL "
	cSQL += "             AND C.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN VISAOX D ON "
	cSQL += "         ( "
	cSQL += "             A.CONTA BETWEEN D.CTS_CT1INI AND D.CTS_CT1FIM "
	cSQL += "             AND D.CTS_YNOCT1 NOT LIKE '%' + RTRIM(A.CONTA) + '%' "
	cSQL += "             AND D.CTS_YNOCVG NOT LIKE '%' + RTRIM(C.CTH_YCLVLG) + '%' "
	cSQL += "             AND ( D.CTS_YINCVG = '' OR D.CTS_YINCVG LIKE '%' + RTRIM(C.CTH_YCLVLG) + '%' ) "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN " + RetSqlName("ZC8") + " E(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             E.ZC8_FILIAL = '" + xFilial("ZC8") + "' "
	cSQL += "             AND E.ZC8_PCT20 = CT1_YPCT20 "
	cSQL += "             AND E.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN " + RetSqlName("Z39") + " F(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             F.Z39_FILIAL = '" + xFilial("Z39") + "' "
	cSQL += "             AND F.Z39_CLVLG = CTH_YCLVLG "
	cSQL += "             AND F.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN " + RetSqlName("ZCA") + " G(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             G.ZCA_FILIAL = '" + xFilial("ZCA") + "' "
	cSQL += "             AND G.ZCA_ENTID = CTH_YENTID "
	cSQL += "             AND G.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN " + RetSqlName("ZBE") + " H(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             H.ZBE_FILIAL = '" + xFilial("ZBE") + "' "
	cSQL += "             AND H.ZBE_VERSAO	= " + ValToSQL(cVersao)
	cSQL += "             AND H.ZBE_REVISA	= " + ValToSQL(cRevisa)
	cSQL += "             AND H.ZBE_ANOREF	= " + ValToSQL(cAnoRef)
	cSQL += "             AND H.ZBE_DRIVER = DRIVER "
	cSQL += "             AND H.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN " + RetSqlName("ZCB") + " I(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             I.ZCB_FILIAL = '" + xFilial("ZCB") + "' "
	cSQL += "             AND I.ZCB_SETOR = CTH_YSETOR "
	cSQL += "             AND I.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "

	cSQL += " UNION ALL "

	cSQL += " SELECT  EMPRESA, "
	cSQL += "         FILIAL, "
	cSQL += "         '' CTH_YCLVLG, "
	cSQL += "         '' CTH_YENTID, "
	cSQL += "         CT1_YPCT20, "
	cSQL += "         CTS_CODPLA, "
	cSQL += "         CTS_ORDEM, "
	cSQL += "         CTS_CONTAG, "
	cSQL += "         CTS_CTASUP, "
	cSQL += "         CTS_DESCCG, "
	cSQL += "         CTS_LINHA, "
	cSQL += "         ORIG, "
	cSQL += "         ORIPRC, "
	cSQL += "         DTREF, "
	cSQL += "         DC, "
	cSQL += "         CONTA, "
	cSQL += "         DESC_CTA = CT1_DESC01, "
	cSQL += "         PACOTE = '', "
	cSQL += "         DESC_PCT = '', "
	cSQL += "         CLVL = '', "
	cSQL += "         DESC_CLVL = '', "
	cSQL += "         CLVG = '', "
	cSQL += "         DESC_CLVG = '', "
	cSQL += "         ENTIDADE = '', "
	cSQL += "         DESC_ENT = '', "
	cSQL += "         DRIVER, "
	cSQL += "         DESC_DRV = ZBE_DESCRI, "
	cSQL += "         SETOR = '', "
	cSQL += "         DESC_SETOR = '', "
	cSQL += "         APLIC, "
	cSQL += "         DESC_APL = CASE "
	cSQL += "                        WHEN APLIC = '0' "
	cSQL += "                        THEN 'Nenhum' "
	cSQL += "                        WHEN APLIC = '1' "
	cSQL += "                        THEN 'Producao' "
	cSQL += "                        WHEN APLIC = '2' "
	cSQL += "                        THEN 'Manutencao' "
	cSQL += "                        WHEN APLIC = '3' "
	cSQL += "                        THEN 'Melhoria_M' "
	cSQL += "                        WHEN APLIC = '4' "
	cSQL += "                        THEN 'Seguranca' "
	cSQL += "                        WHEN APLIC = '5' "
	cSQL += "                        THEN 'Calibracao' "
	cSQL += "                        WHEN APLIC = '6' "
	cSQL += "                        THEN 'Melhoria_Prod' "
	cSQL += "                        WHEN APLIC = '7' "
	cSQL += "                        THEN 'Administrativo' "
	cSQL += "                        WHEN APLIC = '8' "
	cSQL += "                        THEN 'Fiscal' "
	cSQL += "                        WHEN APLIC = '9' "
	cSQL += "                        THEN 'Patrimonial' "
	cSQL += "                        ELSE '' "
	cSQL += "                    END, "
	cSQL += "         CENARIO, "
	cSQL += "         VALOR, "
	cSQL += "         TABELA = 'ZBZ', "
	cSQL += "         REGTBL "
	cSQL += " FROM    RECEITA A "
	cSQL += "         INNER JOIN " + RetSqlName("CT1") + " B(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             B.CT1_FILIAL = '" + xFilial("CT1") + "' "
	cSQL += "             AND B.CT1_CONTA = A.CONTA "
	cSQL += "             AND B.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN VISAOX D ON "
	cSQL += "         ( "
	cSQL += "             A.CONTA BETWEEN D.CTS_CT1INI AND D.CTS_CT1FIM "
	cSQL += "             AND D.CTS_YNOCT1 NOT LIKE '%' + RTRIM(A.CONTA) + '%' "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN " + RetSqlName("ZBE") + " H(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             H.ZBE_FILIAL = '" + xFilial("ZBE") + "' "
	cSQL += "             AND H.ZBE_VERSAO	= " + ValToSQL(cVersao)
	cSQL += "             AND H.ZBE_REVISA	= " + ValToSQL(cRevisa)
	cSQL += "             AND H.ZBE_ANOREF	= " + ValToSQL(cAnoRef)
	cSQL += "             AND H.ZBE_DRIVER = DRIVER "
	cSQL += "             AND H.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "  ORDER BY 1, 2, 4, 5 "

Return ( cSQL )

User Function B599REA(aEmp, cDatIni, cDatFin, nW)

	Local cSQL := ""

	cSQL := " WITH RESULTADO "
	cSQL += " AS ( "
	cSQL += "         SELECT " + ValToSql(aEmp[nW][1]) + " EMPRESA, "
	cSQL += "               CT2_FILIAL FILIAL, "
	cSQL += "               'D' ORIG, "
	cSQL += "               'REAL' ORIPRC, "
	cSQL += "               CT2_DATA DTREF, "
	cSQL += "               CT2_DC DC, "
	cSQL += "               CT2_DEBITO CONTA, "
	cSQL += "               CT2_CLVLDB CLVL, "
	cSQL += "               CT2_YDRVDB DRIVER, "
	cSQL += "               CT2_YAPLIC APLIC, "
	cSQL += "               '' CENARIO, "
	cSQL += "               CT2_VALOR VALOR, "
	cSQL += "               R_E_C_N_O_ REGTBL "
	cSQL += "         FROM " + RetFullName("CT2", aEmp[nW][1]) + " A(NOLOCK) "
	cSQL += "         WHERE CT2_FILIAL BETWEEN '  ' AND 'ZZ' "
	cSQL += "               AND CT2_DATA BETWEEN '" + dtos(cDatIni) + "' AND '" + dtos(cDatFin) + "'
	cSQL += "               AND SUBSTRING(CT2_DEBITO, 1, 1) IN('3', '6') "
	cSQL += "               AND CT2_CLVLDB <> '' "
	cSQL += "               AND D_E_L_E_T_ = ' ' "

	cSQL += "         UNION ALL "

	cSQL += "         SELECT " + ValToSql(aEmp[nW][1]) + " EMPRESA, "
	cSQL += "               CT2_FILIAL FILIAL, "
	cSQL += "               'C' ORIG, "
	cSQL += "               'REAL' ORIPRC, "
	cSQL += "               CT2_DATA DTREF, "
	cSQL += "               CT2_DC DC, "
	cSQL += "               CT2_CREDIT CONTA, "
	cSQL += "               CT2_CLVLCR CLVL, "
	cSQL += "               CT2_YDRVCR DRIVER, "
	cSQL += "               CT2_YAPLIC APLIC, "
	cSQL += "               '' CENARIO, "
	cSQL += "               CT2_VALOR * (-1) VALOR, "
	cSQL += "               R_E_C_N_O_ REGTBL "
	cSQL += "         FROM " + RetFullName("CT2", aEmp[nW][1]) + " A(NOLOCK) "
	cSQL += "         WHERE CT2_FILIAL BETWEEN '  ' AND 'ZZ' "
	cSQL += "               AND CT2_DATA BETWEEN '" + dtos(cDatIni) + "' AND '" + dtos(cDatFin) + "'
	cSQL += "               AND SUBSTRING(CT2_CREDIT, 1, 1) IN('3', '6') "
	cSQL += "               AND CT2_CLVLCR <> '' "
	cSQL += "               AND D_E_L_E_T_ = ' ' "
	cSQL += "     ), "
	cSQL += " RECEITA "
	cSQL += " AS  ( "
	cSQL += "         SELECT " + ValToSql(aEmp[nW][1]) + " EMPRESA, "
	cSQL += "               CT2_FILIAL FILIAL, "
	cSQL += "               'D' ORIG, "
	cSQL += "               'REAL' ORIPRC, "
	cSQL += "               CT2_DATA DTREF, "
	cSQL += "               CT2_DC DC, "
	cSQL += "               CT2_DEBITO CONTA, "
	cSQL += "               CT2_CLVLDB CLVL, "
	cSQL += "               CT2_YDRVDB DRIVER, "
	cSQL += "               CT2_YAPLIC APLIC, "
	cSQL += "               '' CENARIO, "
	cSQL += "               CT2_VALOR VALOR, "
	cSQL += "               R_E_C_N_O_ REGTBL "
	cSQL += "         FROM " + RetFullName("CT2", aEmp[nW][1]) + " A(NOLOCK) "
	cSQL += "         WHERE CT2_FILIAL BETWEEN '  ' AND 'ZZ' "
	cSQL += "               AND CT2_DATA BETWEEN '" + dtos(cDatIni) + "' AND '" + dtos(cDatFin) + "'
	cSQL += "               AND SUBSTRING(CT2_DEBITO, 1, 1) IN('4') "
	cSQL += "               AND D_E_L_E_T_ = ' ' "

	cSQL += "         UNION ALL "

	cSQL += "         SELECT " + ValToSql(aEmp[nW][1]) + " EMPRESA, "
	cSQL += "               CT2_FILIAL FILIAL, "
	cSQL += "               'C' ORIG, "
	cSQL += "               'REAL' ORIPRC, "
	cSQL += "               CT2_DATA DTREF, "
	cSQL += "               CT2_DC DC, "
	cSQL += "               CT2_CREDIT CONTA, "
	cSQL += "               CT2_CLVLCR CLVL, "
	cSQL += "               CT2_YDRVCR DRIVER, "
	cSQL += "               CT2_YAPLIC APLIC, "
	cSQL += "               '' CENARIO, "
	cSQL += "               CT2_VALOR * (-1) VALOR, "
	cSQL += "               R_E_C_N_O_ REGTBL "
	cSQL += "         FROM " + RetFullName("CT2", aEmp[nW][1]) + " A(NOLOCK) "
	cSQL += "         WHERE CT2_FILIAL BETWEEN '  ' AND 'ZZ' "
	cSQL += "               AND CT2_DATA BETWEEN '" + dtos(cDatIni) + "' AND '" + dtos(cDatFin) + "'
	cSQL += "               AND SUBSTRING(CT2_CREDIT, 1, 1) IN('4') "
	cSQL += "               AND D_E_L_E_T_ = ' ' "
	cSQL += "     ), "
	cSQL += " VISAOX "
	cSQL += " AS  ( "
	cSQL += "         SELECT CTS_CODPLA, "
	cSQL += "               CTS_ORDEM, "
	cSQL += "               CTS_CONTAG, "
	cSQL += "               CTS_CTASUP, "
	cSQL += "               CTS_DESCCG, "
	cSQL += "               CTS_LINHA, "
	cSQL += "               CTS_CT1INI, "
	cSQL += "               CTS_CT1FIM, "
	cSQL += "               CTS_IDENT, "
	cSQL += "               CTS_YNOCT1, "
	cSQL += "               CTS_YINCVG, "
	cSQL += "               CTS_YNOCVG "
	cSQL += "         FROM " + RetSqlName("CTS") + " CTS(NOLOCK) "
	cSQL += "         WHERE CTS_FILIAL = '" + xFilial("CTS") + "' "
	cSQL += "               AND CTS_CODPLA = '500' "
	cSQL += "               AND D_E_L_E_T_ = '' "
	cSQL += "     ) "

	cSQL += " SELECT EMPRESA, "
	cSQL += "         FILIAL, "
	cSQL += "         CTH_YCLVLG, "
	cSQL += "         CTH_YENTID, "
	cSQL += "         CT1_YPCT20, "
	cSQL += "         CTS_CODPLA, "
	cSQL += "         CTS_ORDEM, "
	cSQL += "         CTS_CONTAG, "
	cSQL += "         CTS_CTASUP, "
	cSQL += "         CTS_DESCCG, "
	cSQL += "         CTS_LINHA, "
	cSQL += "         ORIG, "
	cSQL += "         ORIPRC, "
	cSQL += "         DTREF, "
	cSQL += "         DC, "
	cSQL += "         CONTA, "
	cSQL += "         DESC_CTA = CT1_DESC01, "
	cSQL += "         PACOTE = CT1_YPCT20, "
	cSQL += "         DESC_PCT = ZC8_DESCRI, "
	cSQL += "         CLVL, "
	cSQL += "         DESC_CLVL = CTH_DESC01, "
	cSQL += "         CLVG = CTH_YCLVLG, "
	cSQL += "         DESC_CLVG = Z39_DESCR, "
	cSQL += "         ENTIDADE = CTH_YENTID, "
	cSQL += "         DESC_ENT = ZCA_DESCRI, "
	cSQL += "         DRIVER, "
	cSQL += "         DESC_DRV = ZBE_DESCRI, "
	cSQL += "         SETOR = CTH_YSETOR, "
	cSQL += "         DESC_SETOR = ZCB_DESCRI, "
	cSQL += "         APLIC, "
	cSQL += "         DESC_APL = CASE "
	cSQL += "                        WHEN APLIC = '0' "
	cSQL += "                        THEN 'Nenhum' "
	cSQL += "                        WHEN APLIC = '1' "
	cSQL += "                        THEN 'Producao' "
	cSQL += "                        WHEN APLIC = '2' "
	cSQL += "                        THEN 'Manutencao' "
	cSQL += "                        WHEN APLIC = '3' "
	cSQL += "                        THEN 'Melhoria_M' "
	cSQL += "                        WHEN APLIC = '4' "
	cSQL += "                        THEN 'Seguranca' "
	cSQL += "                        WHEN APLIC = '5' "
	cSQL += "                        THEN 'Calibracao' "
	cSQL += "                        WHEN APLIC = '6' "
	cSQL += "                        THEN 'Melhoria_Prod' "
	cSQL += "                        WHEN APLIC = '7' "
	cSQL += "                        THEN 'Administrativo' "
	cSQL += "                        WHEN APLIC = '8' "
	cSQL += "                        THEN 'Fiscal' "
	cSQL += "                        WHEN APLIC = '9' "
	cSQL += "                        THEN 'Patrimonial' "
	cSQL += "                        ELSE '' "
	cSQL += "                    END, "
	cSQL += "         CENARIO, "
	cSQL += "         VALOR, "
	cSQL += "         TABELA = 'CT2', "
	cSQL += "         REGTBL "
	cSQL += "  FROM   RESULTADO A "
	cSQL += "         INNER JOIN " + RetSqlName("CT1") + " B(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             B.CT1_FILIAL = '" + xFilial("CT1") + "' "
	cSQL += "             AND B.CT1_CONTA = A.CONTA "
	cSQL += "             AND B.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "         INNER JOIN " + RetSqlName("CTH") + " C(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             C.CTH_FILIAL = '" + xFilial("CTH") + "' "
	cSQL += "             AND C.CTH_CLVL = A.CLVL "
	cSQL += "             AND C.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN VISAOX D ON "
	cSQL += "         ( "
	cSQL += "             A.CONTA BETWEEN D.CTS_CT1INI AND D.CTS_CT1FIM "
	cSQL += "             AND D.CTS_YNOCT1 NOT LIKE '%' + RTRIM(A.CONTA) + '%' "
	cSQL += "             AND D.CTS_YNOCVG NOT LIKE '%' + RTRIM(C.CTH_YCLVLG) + '%' "
	cSQL += "             AND ( D.CTS_YINCVG = '' OR D.CTS_YINCVG LIKE '%' + RTRIM(C.CTH_YCLVLG) + '%' ) "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN " + RetSqlName("ZC8") + " E(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             E.ZC8_FILIAL = '" + xFilial("ZC8") + "' "
	cSQL += "             AND E.ZC8_PCT20 = CT1_YPCT20 "
	cSQL += "             AND E.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN " + RetSqlName("Z39") + " F(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             F.Z39_FILIAL = '" + xFilial("Z39") + "' "
	cSQL += "             AND F.Z39_CLVLG = CTH_YCLVLG "
	cSQL += "             AND F.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN " + RetSqlName("ZCA") + " G(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             G.ZCA_FILIAL = '" + xFilial("ZCA") + "' "
	cSQL += "             AND G.ZCA_ENTID = CTH_YENTID "
	cSQL += "             AND G.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN " + RetSqlName("ZBE") + " H(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             H.ZBE_FILIAL = '" + xFilial("ZBE") + "' "
	cSQL += "             AND H.ZBE_DRIVER = DRIVER "
	cSQL += "             AND H.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN " + RetSqlName("ZCB") + " I(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             I.ZCB_FILIAL = '" + xFilial("ZCB") + "' "
	cSQL += "             AND I.ZCB_SETOR = CTH_YSETOR "
	cSQL += "             AND I.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "

	cSQL += " UNION ALL "

	cSQL += " SELECT  EMPRESA, "
	cSQL += "         FILIAL, "
	cSQL += "         '' CTH_YCLVLG, "
	cSQL += "         '' CTH_YENTID, "
	cSQL += "         CT1_YPCT20, "
	cSQL += "         CTS_CODPLA, "
	cSQL += "         CTS_ORDEM, "
	cSQL += "         CTS_CONTAG, "
	cSQL += "         CTS_CTASUP, "
	cSQL += "         CTS_DESCCG, "
	cSQL += "         CTS_LINHA, "
	cSQL += "         ORIG, "
	cSQL += "         ORIPRC, "
	cSQL += "         DTREF, "
	cSQL += "         DC, "
	cSQL += "         CONTA, "
	cSQL += "         DESC_CTA = CT1_DESC01, "
	cSQL += "         PACOTE = '', "
	cSQL += "         DESC_PCT = '', "
	cSQL += "         CLVL = '', "
	cSQL += "         DESC_CLVL = '', "
	cSQL += "         CLVG = '', "
	cSQL += "         DESC_CLVG = '', "
	cSQL += "         ENTIDADE = '', "
	cSQL += "         DESC_ENT = '', "
	cSQL += "         DRIVER, "
	cSQL += "         DESC_DRV = ZBE_DESCRI, "
	cSQL += "         SETOR = '', "
	cSQL += "         DESC_SETOR = '', "
	cSQL += "         APLIC, "
	cSQL += "         DESC_APL = CASE "
	cSQL += "                        WHEN APLIC = '0' "
	cSQL += "                        THEN 'Nenhum' "
	cSQL += "                        WHEN APLIC = '1' "
	cSQL += "                        THEN 'Producao' "
	cSQL += "                        WHEN APLIC = '2' "
	cSQL += "                        THEN 'Manutencao' "
	cSQL += "                        WHEN APLIC = '3' "
	cSQL += "                        THEN 'Melhoria_M' "
	cSQL += "                        WHEN APLIC = '4' "
	cSQL += "                        THEN 'Seguranca' "
	cSQL += "                        WHEN APLIC = '5' "
	cSQL += "                        THEN 'Calibracao' "
	cSQL += "                        WHEN APLIC = '6' "
	cSQL += "                        THEN 'Melhoria_Prod' "
	cSQL += "                        WHEN APLIC = '7' "
	cSQL += "                        THEN 'Administrativo' "
	cSQL += "                        WHEN APLIC = '8' "
	cSQL += "                        THEN 'Fiscal' "
	cSQL += "                        WHEN APLIC = '9' "
	cSQL += "                        THEN 'Patrimonial' "
	cSQL += "                        ELSE '' "
	cSQL += "                    END, "
	cSQL += "         CENARIO, "
	cSQL += "         VALOR, "
	cSQL += "         TABELA = 'CT2', "
	cSQL += "         REGTBL "
	cSQL += " FROM    RECEITA A "
	cSQL += "         INNER JOIN " + RetSqlName("CT1") + " B(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             B.CT1_FILIAL = '" + xFilial("CT1") + "' "
	cSQL += "             AND B.CT1_CONTA = A.CONTA "
	cSQL += "             AND B.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN VISAOX D ON "
	cSQL += "         ( "
	cSQL += "             A.CONTA BETWEEN D.CTS_CT1INI AND D.CTS_CT1FIM "
	cSQL += "             AND D.CTS_YNOCT1 NOT LIKE '%' + RTRIM(A.CONTA) + '%' "
	cSQL += "         ) "
	cSQL += "         LEFT JOIN " + RetSqlName("ZBE") + " H(NOLOCK) ON "
	cSQL += "         ( "
	cSQL += "             H.ZBE_FILIAL = '" + xFilial("ZBE") + "' "
	cSQL += "             AND H.ZBE_DRIVER = DRIVER "
	cSQL += "             AND H.D_E_L_E_T_ = ' ' "
	cSQL += "         ) "
	cSQL += "  ORDER BY 1, 2, 4, 5 "

Return ( cSQL )
