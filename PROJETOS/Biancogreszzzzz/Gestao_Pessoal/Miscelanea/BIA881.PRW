#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA881
@author Marcos Alberto Soprani
@since 21/09/17
@version 1.0
@description Rotina de processamento e gravação da Fotografia dos dados para Orçamento de RH  
@type function
/*/

User Function BIA881()

	Local M001      := GetNextAlias()
	Local M002      := GetNextAlias()
	Local M003      := GetNextAlias()
	Local M004      := GetNextAlias()

	Private msrhEnter := CHR(13) + CHR(10)

	fPerg := "BIA881"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cVersao   := MV_PAR03   
	_cRevisa   := MV_PAR04
	_cAnoRef   := MV_PAR05

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual RH" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação igual a branco" + msrhEnter
	xfMensCompl += "Data Conciliação igual a branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual a branco" + msrhEnter

	BeginSql Alias M001
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZB5% ZB5
		WHERE ZB5_FILIAL = %xFilial:ZB5%
		AND ZB5.ZB5_VERSAO = %Exp:_cVersao%
		AND ZB5.ZB5_REVISA = %Exp:_cRevisa%
		AND ZB5.ZB5_ANOREF = %Exp:_cAnoRef%
		AND RTRIM(ZB5.ZB5_TPORCT) = 'RH'
		AND ZB5.ZB5_STATUS = 'A'
		AND ZB5.ZB5_DTDIGT = ''
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTENCR = ''
		AND ZB5.%NotDel%
	EndSql
	(M001)->(dbGoTop())
	If (M001)->CONTAD <> 1
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	BeginSql Alias M002
		SELECT COUNT(*) CONTAD
		FROM %TABLE:ZBA% ZBA
		WHERE ZBA_FILIAL = %xFilial:ZBA%
		AND ZBA.ZBA_VERSAO = %Exp:_cVersao%
		AND ZBA.ZBA_REVISA = %Exp:_cRevisa%
		AND ZBA.ZBA_ANOREF = %Exp:_cAnoRef%
		AND ZBA.%NotDel%
	EndSql
	(M002)->(dbGoTop())
	If (M002)->CONTAD <> 0

		msdConfirm := MsgNOYES("A Versão / Revisão / AnoRef informados já possui >>> " + Alltrim(Str((M002)->CONTAD)) + " <<< registros associados. Caso CONFIRME a continuação do processo os registros associados serão todos apagados." + msrhEnter + msrhEnter + " As inclusões de NOVOS FUNCIONÁRIOS, as declarações de DEMISSÕES e PROMOÇÕES EVENTUAIS serão mantidas!!!" + msrhEnter + msrhEnter + "Deseja prosseguir???")
		If !msdConfirm

			(M002)->(dbCloseArea())
			Return .F.

		Else

			KS001 := " DELETE " + RetSqlName("ZBA") + " "
			KS001 += "  WHERE ZBA_FILIAL = '" + xFilial("ZBA") + "' "
			KS001 += "    AND ZBA_VERSAO = '" + _cVersao + "' "
			KS001 += "    AND ZBA_REVISA = '" + _cRevisa + "' "
			KS001 += "    AND ZBA_ANOREF = '" + _cAnoRef + "' "
			KS001 += "    AND ZBA_PERIOD <> '00' "
			KS001 += "    AND D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros ZBA - DESDOBRAMENTO... ",,{|| TcSQLExec(KS001) })

			KS002 := " DELETE " + RetSqlName("ZBA") + " "
			KS002 += "  WHERE ZBA_FILIAL = '" + xFilial("ZBA") + "' "
			KS002 += "    AND ZBA_VERSAO = '" + _cVersao + "' "
			KS002 += "    AND ZBA_REVISA = '" + _cRevisa + "' "
			KS002 += "    AND ZBA_ANOREF = '" + _cAnoRef + "' "
			KS002 += "    AND ZBA_MESDEM = '  ' "
			KS002 += "    AND ZBA_MATR NOT LIKE '%NOVO%' "
			KS002 += "    AND ZBA_DMTDAA <> '1' "
			KS002 += "    AND D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros ZBA... ",,{|| TcSQLExec(KS002) })

			msRubEven := 0
			BeginSql Alias M003
				SELECT COUNT(*) CONTAD
				FROM %TABLE:ZB8% ZB8
				WHERE ZB8_FILIAL = %xFilial:ZB8%
				AND ZB8.ZB8_VERSAO = %Exp:_cVersao%
				AND ZB8.ZB8_REVISA = %Exp:_cRevisa%
				AND ZB8.ZB8_ANOREF = %Exp:_cAnoRef%
				AND ZB8.%NotDel%
			EndSql
			(M003)->(dbGoTop())
			If (M003)->CONTAD <> 0
				msRubEven := (M003)->CONTAD 
			EndIf
			(M003)->(dbCloseArea())

			msFuncDem := 0
			BeginSql Alias M004
				SELECT COUNT(*) CONTAD
				FROM %TABLE:ZBA% ZBA
				WHERE ZBA_FILIAL = %xFilial:ZBA%
				AND ZBA.ZBA_VERSAO = %Exp:_cVersao%
				AND ZBA.ZBA_REVISA = %Exp:_cRevisa%
				AND ZBA.ZBA_ANOREF = %Exp:_cAnoRef%
				AND ZBA.%NotDel%
			EndSql
			(M004)->(dbGoTop())
			If (M004)->CONTAD <> 0
				msFuncDem := (M004)->CONTAD 
			EndIf
			(M004)->(dbCloseArea())

			MsgALERT("Após limpeza da Base de dados para a versão informada, restaram " + Alltrim(Str(msRubEven)) + " rubricas eventuais registradas e " + Alltrim(Str(msFuncDem)) + " funcionários já previstos de demissão e NOVOS." + msrhEnter + msrhEnter + "Favor comunitar aos gestores que revisem seus quadros de pessoal para o orçamento!!")

		EndIf

	EndIf	
	(M002)->(dbCloseArea())

	U_BIAMsgRun("Aguarde... Efetuando gravação dos dados... ",,{|| BIA881A() })

Return

Static Function BIA881A()

	Local msrhEnter := CHR(13) + CHR(10)
	Local msCustFun := ""
	Local msCstFuQr := ""
	Local msNomeTMP := "##TMPBIA881" + cEmpAnt + cFilAnt + __cUserID + strzero(seconds() * 3500,10)
	Local msNmTMPII := "##TBIA881II" + cEmpAnt + cFilAnt + __cUserID + strzero(seconds() * 3500,10)
	Local msNmTMP03 := "##TBIA88103" + cEmpAnt + cFilAnt + __cUserID + strzero(seconds() * 3500,10)
	Local msNmTMP04 := "##TBIA88104" + cEmpAnt + cFilAnt + __cUserID + strzero(seconds() * 3500,10)

	MP007 := " SELECT ZBC_RUBRIC "
	MP007 += "   FROM " + RetSqlName("ZBC") + " "
	MP007 += "  WHERE ZBC_FILIAL = '" + xFilial("ZBC") + "' "
	MP007 += "    AND ZBC_VERSAO = '" + _cVersao + "' "
	MP007 += "    AND ZBC_REVISA = '" + _cRevisa + "' "
	MP007 += "    AND ZBC_ANOREF = '" + _cAnoRef + "' "
	MP007 += "    AND D_E_L_E_T_ = ' ' "
	MPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,MP007),'MP07',.T.,.T.)
	dbSelectArea("MP07")
	MP07->(dbGoTop())
	While MP07->(!Eof())
		msCustFun += "ZBA->" + MP07->ZBC_RUBRIC
		msCstFuQr += "SMT." + MP07->ZBC_RUBRIC
		MP07->(dbSkip())
		If MP07->(!Eof())
			msCustFun += " + "
			msCstFuQr += " + "
		EndIf
	End
	MP07->(dbCloseArea())
	Ferase(MPIndex+GetDBExtension())
	Ferase(MPIndex+OrdBagExt())

	CT001 := Alltrim(" WITH VLRVLTRANS                                                                                                 ") + msrhEnter
	CT001 += Alltrim("      AS (SELECT a.numemp,                                                                                       ") + msrhEnter
	CT001 += Alltrim("                 e.codfil,                                                                                       ") + msrhEnter
	CT001 += Alltrim("                 a.tipcol,                                                                                       ") + msrhEnter
	CT001 += Alltrim("                 a.numcad,                                                                                       ") + msrhEnter
	CT001 += Alltrim("                 a.codeve,                                                                                       ") + msrhEnter
	CT001 += Alltrim("                 mesano = CONVERT(CHAR(10), EOMONTH(c.perref), 112),                                             ") + msrhEnter
	CT001 += Alltrim("                 valor = a.valeve                                                                                ") + msrhEnter
	CT001 += Alltrim("          FROM VETORH.dbo.r046ver a(NOLOCK)                                                                      ") + msrhEnter
	CT001 += Alltrim("               INNER JOIN VETORH.dbo.r008evc b(NOLOCK) ON b.codeve = a.codeve                                    ") + msrhEnter
	CT001 += Alltrim("                                                          AND b.codtab = a.tabeve                                ") + msrhEnter
	CT001 += Alltrim("               INNER JOIN VETORH.dbo.r044cal c(NOLOCK) ON c.numemp = a.numemp                                    ") + msrhEnter
	CT001 += Alltrim("                                                          AND c.codcal = a.codcal                                ") + msrhEnter
	CT001 += Alltrim("               INNER JOIN VETORH.dbo.r038hfi e(NOLOCK) ON e.numemp = a.numemp                                    ") + msrhEnter
	CT001 += Alltrim("                                                          AND e.tipcol = a.tipcol                                ") + msrhEnter
	CT001 += Alltrim("                                                          AND e.numcad = a.numcad                                ") + msrhEnter
	CT001 += Alltrim("                                                          AND e.datalt =                                         ") + msrhEnter
	CT001 += Alltrim("          (                                                                                                      ") + msrhEnter
	CT001 += Alltrim("              SELECT MAX(qq.datalt)                                                                              ") + msrhEnter
	CT001 += Alltrim("              FROM VETORH.dbo.r038hfi qq(NOLOCK)                                                                 ") + msrhEnter
	CT001 += Alltrim("              WHERE qq.datalt < EOMONTH(c.perref)                                                                ") + msrhEnter
	CT001 += Alltrim("                    AND qq.numemp = a.numemp                                                                     ") + msrhEnter
	CT001 += Alltrim("                    AND qq.tipcol = a.tipcol                                                                     ") + msrhEnter
	CT001 += Alltrim("                    AND qq.numcad = a.numcad                                                                     ") + msrhEnter
	CT001 += Alltrim("          )                                                                                                      ") + msrhEnter
	CT001 += Alltrim("          WHERE a.tipcol = 1                                                                                     ") + msrhEnter
	CT001 += Alltrim("                AND a.codeve IN(2306, 2380))                                                                     ") + msrhEnter
	CT001 += Alltrim("      SELECT * INTO " + msNomeTMP + "                                                                            ") + msrhEnter
	CT001 += Alltrim("      FROM VLRVLTRANS                                                                                            ") + msrhEnter
	U_BIAMsgRun("Aguarde... Vale Transporte...",,{|| TcSQLExec(CT001)})

	CT002 := Alltrim(" WITH PLNSAUDE                                                                                                   ") + msrhEnter
	CT002 += Alltrim("      AS (SELECT NUMEMP = ass.numemp,                                                                            ") + msrhEnter
	CT002 += Alltrim("                 NUMCAD = ass.numcad,                                                                            ") + msrhEnter
	CT002 += Alltrim("                 TPFORN = CASE                                                                                   ") + msrhEnter
	CT002 += Alltrim("                              WHEN ass.codoem = 2                                                                ") + msrhEnter
	CT002 += Alltrim("                              THEN '1'                                                                           ") + msrhEnter
	CT002 += Alltrim("                              WHEN ass.codoem = 3                                                                ") + msrhEnter
	CT002 += Alltrim("                              THEN '2'                                                                           ") + msrhEnter
	CT002 += Alltrim("                              ELSE ''                                                                            ") + msrhEnter
	CT002 += Alltrim("                          END,                                                                                   ") + msrhEnter
	CT002 += Alltrim("                 CODOEM = ass.codoem,                                                                            ") + msrhEnter
	CT002 += Alltrim("                 CODPLA = ass.codpla,                                                                            ") + msrhEnter
	CT002 += Alltrim("                 QTDTIT = 1,                                                                                     ") + msrhEnter
	CT002 += Alltrim("                 VLRTIT = ISNULL(ZB1.ZB1_VLRTIT, 0),                                                             ") + msrhEnter
	CT002 += Alltrim("                 PRCTIT = ISNULL(ZB1.ZB1_DSCTIT, 0),                                                             ") + msrhEnter
	CT002 += Alltrim("                 QTDDEP = ISNULL(                                                                                ") + msrhEnter
	CT002 += Alltrim("          (                                                                                                      ") + msrhEnter
	CT002 += Alltrim("              SELECT COUNT(*)                                                                                    ") + msrhEnter
	CT002 += Alltrim("              FROM VETORH.dbo.r164dep dep(NOLOCK)                                                                ") + msrhEnter
	CT002 += Alltrim("              WHERE dep.numemp = ass.numemp                                                                      ") + msrhEnter
	CT002 += Alltrim("                    AND dep.tipcol = ass.tipcol                                                                  ") + msrhEnter
	CT002 += Alltrim("                    AND dep.numcad = ass.numcad                                                                  ") + msrhEnter
	CT002 += Alltrim("                    AND dep.codoem = ass.codoem                                                                  ") + msrhEnter
	CT002 += Alltrim("                    AND dep.codpla = ass.codpla                                                                  ") + msrhEnter
	CT002 += Alltrim("                    AND ((dep.mesexc = '1900-12-31 00:00:00.000')                                                ") + msrhEnter
	CT002 += Alltrim("                         OR ('" + _cAnoRef + "-12-31 00:00:00.000' BETWEEN dep.mesinc AND dep.mesexc))           ") + msrhEnter
	CT002 += Alltrim("          ), 0),                                                                                                 ") + msrhEnter
	CT002 += Alltrim("                 VLRDEP = ISNULL(ZB1.ZB1_VLRDEP, 0),                                                             ") + msrhEnter
	CT002 += Alltrim("                 PRCDEP = ISNULL(ZB1.ZB1_DSCDEP, 0),                                                             ") + msrhEnter
	CT002 += Alltrim("                 QTDAGR = 0,                                                                                     ") + msrhEnter
	CT002 += Alltrim("                 VLRAGR = ISNULL(ZB1.ZB1_VLRAGR, 0),                                                             ") + msrhEnter
	CT002 += Alltrim("                 PRCAGR = ISNULL(ZB1.ZB1_DSCAGR, 0)                                                              ") + msrhEnter
	CT002 += Alltrim("          FROM VETORH.dbo.r164ass ass(NOLOCK)                                                                    ") + msrhEnter
	CT002 += Alltrim("               INNER JOIN " + RetSqlName("ZO0") + " ZO0(NOLOCK) ON ZO0.ZO0_FILIAL = '" + xFilial("ZO0") + "'     ") + msrhEnter
	CT002 += Alltrim("                                        AND ZO0.ZO0_VERSAO = '" + _cVersao + "'                                  ") + msrhEnter
	CT002 += Alltrim("                                        AND ZO0.ZO0_REVISA = '" + _cRevisa + "'                                  ") + msrhEnter
	CT002 += Alltrim("                                        AND ZO0.ZO0_ANOREF = '" + _cAnoRef + "'                                  ") + msrhEnter
	CT002 += Alltrim("                                        AND CONVERT(NUMERIC, ZO0.ZO0_MAT) = ass.numcad                           ") + msrhEnter
	CT002 += Alltrim("                                        AND ZO0.D_E_L_E_T_ = ' '                                                 ") + msrhEnter
	CT002 += Alltrim("               LEFT JOIN " + RetSqlName("ZB1") + " ZB1(NOLOCK) ON ZB1.ZB1_FILIAL = '" + xFilial("ZB1") + "'      ") + msrhEnter
	CT002 += Alltrim("                                       AND CONVERT(NUMERIC, ZB1.ZB1_CODOEM) = ass.codoem                         ") + msrhEnter
	CT002 += Alltrim("                                       AND CONVERT(NUMERIC, ZB1.ZB1_CODPLA) = ass.codpla                         ") + msrhEnter
	CT002 += Alltrim("                                       AND ZB1.ZB1_VERSAO = ZO0.ZO0_VERSAO                                       ") + msrhEnter
	CT002 += Alltrim("                                       AND ZB1.ZB1_REVISA = ZO0.ZO0_REVISA                                       ") + msrhEnter
	CT002 += Alltrim("                                       AND ZB1.ZB1_ANOREF = ZO0.ZO0_ANOREF                                       ") + msrhEnter
	CT002 += Alltrim("                                       AND ((ZB1.ZB1_TIPPLS = '1'                                                ") + msrhEnter
	CT002 += Alltrim("                                             AND ZO0.ZO0_SALREF BETWEEN ZB1.ZB1_DEFAIX AND ZB1.ZB1_ATFAIX)       ") + msrhEnter
	CT002 += Alltrim("                                            OR (ZB1.ZB1_TIPPLS = '2'                                             ") + msrhEnter
	CT002 += Alltrim("                                                AND CONVERT(NUMERIC(18, 0), ROUND(CONVERT(NUMERIC, CONVERT(DATETIME, '" + _cAnoRef + "1231') - CONVERT(DATETIME, ZO0.ZO0_DATNAS)) / 365, 0)) BETWEEN ZB1.ZB1_DEFAIX AND ZB1.ZB1_ATFAIX))   ") + msrhEnter
	CT002 += Alltrim("                                       AND '01' BETWEEN ZB1.ZB1_DOMES AND ZB1.ZB1_ATMES                          ") + msrhEnter
	CT002 += Alltrim("                                       AND ZB1.D_E_L_E_T_ = ' '                                                  ") + msrhEnter
	CT002 += Alltrim("          WHERE ass.numemp = " + cEmpAnt + "                                                                     ") + msrhEnter
	CT002 += Alltrim("                AND ass.tipcol = 1                                                                               ") + msrhEnter
	CT002 += Alltrim("                AND ((ass.mesexc = '1900-12-31 00:00:00.000')                                                    ") + msrhEnter
	CT002 += Alltrim("                     OR ('" + _cAnoRef + "-12-31 00:00:00.000' BETWEEN ass.mesinc AND ass.mesexc)))              ") + msrhEnter
	CT002 += Alltrim("      SELECT * INTO " + msNmTMPII + "                                                                            ") + msrhEnter
	CT002 += Alltrim("      FROM PLNSAUDE                                                                                              ") + msrhEnter
	U_BIAMsgRun("Aguarde... Plano de Saude...",,{|| TcSQLExec(CT002)})

	CT003 := Alltrim(" WITH CTRLASO                                                                                                    ") + msrhEnter
	CT003 += Alltrim("      AS (SELECT NUMCAD = numcad,                                                                                ") + msrhEnter
	CT003 += Alltrim("                 DATARF = CONVERT(VARCHAR, MAX(datate), 112)                                                     ") + msrhEnter
	CT003 += Alltrim("          FROM VETORH.dbo.r110fic a                                                                              ") + msrhEnter
	CT003 += Alltrim("               INNER JOIN VETORH.dbo.r110mam b ON b.numemp = a.numemp                                            ") + msrhEnter
	CT003 += Alltrim("                                                  AND b.codfic = a.codfic                                        ") + msrhEnter
	CT003 += Alltrim("                                                  AND b.tipaso <> 0                                              ") + msrhEnter
	CT003 += Alltrim("          WHERE a.numemp = " + cEmpAnt + "                                                                       ") + msrhEnter
	CT003 += Alltrim("                AND a.tipcol = 1                                                                                 ") + msrhEnter
	CT003 += Alltrim("          GROUP BY numcad)                                                                                       ") + msrhEnter
	CT003 += Alltrim("      SELECT * INTO " + msNmTMP03 + "                                                                            ") + msrhEnter
	CT003 += Alltrim("      FROM CTRLASO                                                                                               ") + msrhEnter
	U_BIAMsgRun("Aguarde... Controle de ASO...",,{|| TcSQLExec(CT003)})

	msAnoAnt := StrZero(Val(_cAnoRef) - 1, 4)
	CT004 := Alltrim(" WITH PRGFER1                                                                                                              ") + msrhEnter
	CT004 += Alltrim("      AS (SELECT NUMEMP = numemp,                                                                                          ") + msrhEnter
	CT004 += Alltrim("                 NUMCAD = numcad,                                                                                          ") + msrhEnter
	CT004 += Alltrim("                 DATFER = CONVERT(VARCHAR, MIN(prgdat), 112)                                                               ") + msrhEnter
	CT004 += Alltrim("          FROM VETORH.dbo.r040prg a(NOLOCK)                                                                                ") + msrhEnter
	CT004 += Alltrim("          WHERE numemp = " + cEmpAnt + "                                                                                   ") + msrhEnter
	CT004 += Alltrim("                AND tipcol = 1                                                                                             ") + msrhEnter
	CT004 += Alltrim("                AND prgdat BETWEEN '" + _cAnoRef + "-01-01 00:00:00.000' AND '" + _cAnoRef + "-12-31 00:00:00.000'         ") + msrhEnter
	CT004 += Alltrim("          GROUP BY numemp,                                                                                                 ") + msrhEnter
	CT004 += Alltrim("                   numcad)                                                                                                 ") + msrhEnter
	CT004 += Alltrim("      SELECT NUMEMP = a.numemp,                                                                                            ") + msrhEnter
	CT004 += Alltrim("             NUMCAD = a.numcad,                                                                                            ") + msrhEnter
	CT004 += Alltrim("             DATFER = CASE                                                                                                 ") + msrhEnter
	CT004 += Alltrim("                          WHEN b.DATFER <> ''                                                                              ") + msrhEnter
	CT004 += Alltrim("                          THEN b.DATFER                                                                                    ") + msrhEnter
	CT004 += Alltrim("                          ELSE ''                                                                                          ") + msrhEnter
	CT004 += Alltrim("                      END INTO " + msNmTMP04 + "                                                                           ") + msrhEnter
	CT004 += Alltrim("      FROM VETORH.dbo.r034fun a(NOLOCK)                                                                                    ") + msrhEnter
	CT004 += Alltrim("           LEFT JOIN PRGFER1 b ON b.NUMEMP = a.numemp                                                                      ") + msrhEnter
	CT004 += Alltrim("                                  AND b.NUMCAD = a.numcad                                                                  ") + msrhEnter
	CT004 += Alltrim("      WHERE a.numemp = " + cEmpAnt + "                                                                                     ") + msrhEnter
	CT004 += Alltrim("            AND a.tipcol = 1                                                                                               ") + msrhEnter
	U_BIAMsgRun("Aguarde... Programação de Férias...",,{|| TcSQLExec(CT004)})

	HR007 := Alltrim("WITH VLRTRANS AS (SELECT NUMCAD = numcad,                                                                            ") + msrhEnter
	HR007 += Alltrim("                         VLRVTR = ROUND(AVG(valor), 2)                                                               ") + msrhEnter
	HR007 += Alltrim("                  FROM " + msNomeTMP + "                                                                             ") + msrhEnter
	HR007 += Alltrim("                  WHERE numemp = " + cEmpAnt + "                                                                     ") + msrhEnter
	HR007 += Alltrim("                        AND codfil = " + cFilAnt + "                                                                 ") + msrhEnter
	HR007 += Alltrim("                        AND SUBSTRING(mesano,1,6) BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                  ") + msrhEnter
	HR007 += Alltrim("                  GROUP BY numcad)                                                                                   ") + msrhEnter
	HR007 += Alltrim(",    MNTCVIDA AS (SELECT * FROM " + msNmTMPII + ")                                                                   ") + msrhEnter
	HR007 += Alltrim(",    MNTVIDAX AS (SELECT *                                                                                           ") + msrhEnter
	HR007 += Alltrim("                    FROM (SELECT NUMCAD,                                                                             ") + msrhEnter
	HR007 += Alltrim("                                 CASE                                                                                ") + msrhEnter
	HR007 += Alltrim("                                   WHEN TPFORN = '1' THEN 'MEDICA'                                                   ") + msrhEnter
	HR007 += Alltrim("                                   WHEN TPFORN = '2' THEN 'ODONTO'                                                   ") + msrhEnter
	HR007 += Alltrim("                                   ELSE 'ERROR'                                                                      ") + msrhEnter
	HR007 += Alltrim("                                 END TPFORN,                                                                         ") + msrhEnter
	HR007 += Alltrim("                                 (QTDTIT * VLRTIT * PRCTIT / 100) + (QTDDEP * VLRDEP * PRCDEP / 100) + (QTDAGR * VLRAGR * PRCAGR / 100) VLMNVD                                                                                             ") + msrhEnter
	HR007 += Alltrim("                            FROM MNTCVIDA) AS TBGR                                                                   ") + msrhEnter
	HR007 += Alltrim("                  PIVOT (SUM(VLMNVD)                                                                                 ") + msrhEnter
	HR007 += Alltrim("                         FOR TPFORN IN(MEDICA, ODONTO, ERROR)) FIM)                                                  ") + msrhEnter
	HR007 += Alltrim(",    VLRSESMT AS (SELECT ZB0_MATR, ZB0_VEXAME, ZB0_VUNIFO, ZB0_VEPI                                                  ") + msrhEnter
	HR007 += Alltrim("                    FROM " + RetSqlName("ZB0") + " ZB0                                                               ") + msrhEnter
	HR007 += Alltrim("                   WHERE ZB0.ZB0_FILIAL = '" + xFilial("ZB0") + "'                                                   ") + msrhEnter
	HR007 += Alltrim("                     AND ZB0.ZB0_VERSAO = '" + _cVersao + "'                                                         ") + msrhEnter
	HR007 += Alltrim("                     AND ZB0.ZB0_REVISA = '" + _cRevisa + "'                                                         ") + msrhEnter
	HR007 += Alltrim("                     AND ZB0.ZB0_ANOREF = '" + _cAnoRef + "'                                                         ") + msrhEnter
	HR007 += Alltrim("                     AND ZB0.D_E_L_E_T_ = ' ')                                                                       ") + msrhEnter
	HR007 += Alltrim(",    ENCTRABA AS (SELECT ZB2_CATGFU CATGFU,                                                                          ") + msrhEnter
	HR007 += Alltrim("                         [1] INSS,                                                                                   ") + msrhEnter
	HR007 += Alltrim("                         [2] FGTS,                                                                                   ") + msrhEnter
	HR007 += Alltrim("                         [3] SENAI,                                                                                  ") + msrhEnter
	HR007 += Alltrim("                         [4] SESI                                                                                    ") + msrhEnter
	HR007 += Alltrim("                    FROM (SELECT ZB2_ENCARG, ZB2_CATGFU, ZB2_PRCTOT                                                  ") + msrhEnter
	HR007 += Alltrim("                            FROM " + RetSqlName("ZB2") + " ZB2                                                       ") + msrhEnter
	HR007 += Alltrim("                           WHERE ZB2.ZB2_FILIAL = '" + xFilial("ZB2") + "'                                           ") + msrhEnter
	HR007 += Alltrim("                             AND ZB2.ZB2_VERSAO = '" + _cVersao + "'                                                 ") + msrhEnter
	HR007 += Alltrim("                             AND ZB2.ZB2_REVISA = '" + _cRevisa + "'                                                 ") + msrhEnter
	HR007 += Alltrim("                             AND ZB2.ZB2_ANOREF = '" + _cAnoRef + "'                                                 ") + msrhEnter
	HR007 += Alltrim("                             AND ZB2.D_E_L_E_T_ = ' ') AS TARE                                                       ") + msrhEnter
	HR007 += Alltrim("                   PIVOT (SUM(ZB2_PRCTOT)                                                                            ") + msrhEnter
	HR007 += Alltrim("                          FOR ZB2_ENCARG IN([1], [2], [3], [4]) ) AS FIM )                                           ") + msrhEnter
	HR007 += Alltrim(",    XVARIAVS AS (SELECT '1' CHVVRS, *                                                                               ") + msrhEnter
	HR007 += Alltrim("                    FROM (SELECT ZB3_VARIAV, ZB3_VCHEIO                                                              ") + msrhEnter
	HR007 += Alltrim("                            FROM " + RetSqlName("ZB3") + " ZB3                                                       ") + msrhEnter
	HR007 += Alltrim("                           WHERE ZB3.ZB3_FILIAL = '" + xFilial("ZB3") + "'                                           ") + msrhEnter
	HR007 += Alltrim("                             AND ZB3.ZB3_VERSAO = '" + _cVersao + "'                                                 ") + msrhEnter
	HR007 += Alltrim("                             AND ZB3.ZB3_REVISA = '" + _cRevisa + "'                                                 ") + msrhEnter
	HR007 += Alltrim("                             AND ZB3.ZB3_ANOREF = '" + _cAnoRef + "'                                                 ") + msrhEnter
	HR007 += Alltrim("                             AND ZB3.D_E_L_E_T_ = ' ') AS TARE                                                       ") + msrhEnter
	HR007 += Alltrim("                   PIVOT (SUM(ZB3_VCHEIO)                                                                            ") + msrhEnter
	HR007 += Alltrim("                          FOR ZB3_VARIAV IN(zmSalMin, zmPrmPrd, zmValTrs, zmRefeic, zmDesejm, zmCrtAlm, zmCJanTr, zmCJanNo, zmCrtCom, zmAjdCBd, zmCfccCh) ) AS FIM )                                                                       ") + msrhEnter
	HR007 += Alltrim(",    DTEXAMES AS (SELECT * FROM " + msNmTMP03 + ")                                                                   ") + msrhEnter
	HR007 += Alltrim("SELECT ZO0.ZO0_MAT MATR,                                                                                             ") + msrhEnter
	HR007 += Alltrim("       ZO0.ZO0_NOME NOME,                                                                                            ") + msrhEnter
	HR007 += Alltrim("       Convert(numeric(18,0), Round(DATEDIFF(dd,ZO0.ZO0_DATNAS,'" + _cAnoRef + "1231')/365,0) ) IDADETT,             ") + msrhEnter
	HR007 += Alltrim("       ZO0.ZO0_CLVL CLVL,                                                                                            ") + msrhEnter
	HR007 += Alltrim("       ZO0.ZO0_CODESC TNOTRAB,                                                                                       ") + msrhEnter
	HR007 += Alltrim("       ZO0.ZO0_CARGO FUNCAO,                                                                                         ") + msrhEnter
	HR007 += Alltrim("       CAR.titcar DFUNCAO,                                                                                           ") + msrhEnter
	HR007 += Alltrim("       MESANI = CASE                                                                                                 ") + msrhEnter
	HR007 += Alltrim("                  WHEN DATARF <> '        ' THEN SUBSTRING( Convert(Char(10), DATEADD(month, 10, convert(datetime, DATARF)) , 112), 5,2)                                                                                                   ") + msrhEnter
	HR007 += Alltrim("                  ELSE SUBSTRING( Convert(Char(10), DATEADD(month, -2, convert(datetime, ZO0_DATNAS)) , 112), 5,2)   ") + msrhEnter
	HR007 += Alltrim("                END,                                                                                                 ") + msrhEnter
	HR007 += Alltrim("       MESADM = SUBSTRING( Convert(Char(10), convert(datetime, ZO0_ADMISS) , 112), 5,2),                             ") + msrhEnter
	HR007 += Alltrim("       ZO0.ZO0_SEMAIL SEMAIL,                                                                                        ") + msrhEnter
	HR007 += Alltrim("       ZO0.ZO0_CTGFUN CATEGFUN,                                                                                      ") + msrhEnter
	HR007 += Alltrim("       ZB4.ZB4_DESCRI DCTGFU,                                                                                        ") + msrhEnter
	HR007 += Alltrim("       ZO0.ZO0_SALREF SALARIO,                                                                                       ") + msrhEnter
	HR007 += Alltrim("       ZO0.ZO0_TXINST TXINST,                                                                                        ") + msrhEnter
	HR007 += Alltrim("       PRCPERI = CASE                                                                                                ") + msrhEnter
	HR007 += Alltrim("                   WHEN ZO0.ZO0_ADCPER = '1' THEN 0.3                                                                ") + msrhEnter
	HR007 += Alltrim("                   ELSE 0                                                                                            ") + msrhEnter
	HR007 += Alltrim("                 END,                                                                                                ") + msrhEnter
	HR007 += Alltrim("       PERICUL = CASE                                                                                                ") + msrhEnter
	HR007 += Alltrim("                   WHEN ZO0.ZO0_ADCPER = '1' THEN ZO0.ZO0_SALREF * 0.3                                               ") + msrhEnter
	HR007 += Alltrim("                   ELSE 0                                                                                            ") + msrhEnter
	HR007 += Alltrim("                 END,                                                                                                ") + msrhEnter
	HR007 += Alltrim("       PRCINSA = CASE                                                                                                ") + msrhEnter
	HR007 += Alltrim("                   WHEN ZO0.ZO0_ADCINS = '4' THEN 0.4                                                                ") + msrhEnter
	HR007 += Alltrim("                   WHEN ZO0.ZO0_ADCINS = '3' THEN 0.2                                                                ") + msrhEnter
	HR007 += Alltrim("                   ELSE 0                                                                                            ") + msrhEnter
	HR007 += Alltrim("                 END,                                                                                                ") + msrhEnter
	HR007 += Alltrim("       INSALUB = CASE                                                                                                ") + msrhEnter
	HR007 += Alltrim("                   WHEN ZO0.ZO0_ADCINS = '4' THEN zmSalMin * 0.4                                                     ") + msrhEnter
	HR007 += Alltrim("                   WHEN ZO0.ZO0_ADCINS = '3' THEN zmSalMin * 0.2                                                     ") + msrhEnter
	HR007 += Alltrim("                   ELSE 0                                                                                            ") + msrhEnter
	HR007 += Alltrim("                 END,                                                                                                ") + msrhEnter
	HR007 += Alltrim("       QTHEPRG = CASE                                                                                                ") + msrhEnter
	HR007 += Alltrim("                   WHEN ZO0.ZO0_CODESC = 246 THEN 7.3333                                                             ") + msrhEnter
	HR007 += Alltrim("                   WHEN ZO0.ZO0_CODESC = 247 THEN 7.3333                                                             ") + msrhEnter
	HR007 += Alltrim("                   WHEN ZO0.ZO0_CODESC = 248 THEN 7.3333                                                             ") + msrhEnter
	HR007 += Alltrim("                   ELSE 0                                                                                            ") + msrhEnter
	HR007 += Alltrim("                 END,                                                                                                ") + msrhEnter
	HR007 += Alltrim("       HEPROG  = (ZO0.ZO0_SALREF + CASE                                                                              ") + msrhEnter
	HR007 += Alltrim("                                     WHEN ZO0.ZO0_ADCPER = '1' THEN ZO0.ZO0_SALREF * 0.3                             ") + msrhEnter
	HR007 += Alltrim("                                     ELSE 0                                                                          ") + msrhEnter
	HR007 += Alltrim("                                   END + CASE                                                                        ") + msrhEnter
	HR007 += Alltrim("                                           WHEN ZO0.ZO0_ADCINS = '4' THEN zmSalMin * 0.4                             ") + msrhEnter
	HR007 += Alltrim("                                           WHEN ZO0.ZO0_ADCINS = '3' THEN zmSalMin * 0.2                             ") + msrhEnter
	HR007 += Alltrim("                                           ELSE 0                                                                    ") + msrhEnter
	HR007 += Alltrim("                                         END) / 220 * 2.0 * CASE                                                     ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN ZO0.ZO0_CODESC = 246 THEN 7.3333                  ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN ZO0.ZO0_CODESC = 247 THEN 7.3333                  ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN ZO0.ZO0_CODESC = 248 THEN 7.3333                  ") + msrhEnter
	HR007 += Alltrim("                                                              ELSE 0                                                 ") + msrhEnter
	HR007 += Alltrim("                                                            END,                                                     ") + msrhEnter
	HR007 += Alltrim("       DSRPRG  = (ZO0.ZO0_SALREF + CASE                                                                              ") + msrhEnter
	HR007 += Alltrim("                                     WHEN ZO0.ZO0_ADCPER = '1' THEN ZO0.ZO0_SALREF * 0.3                             ") + msrhEnter
	HR007 += Alltrim("                                     ELSE 0                                                                          ") + msrhEnter
	HR007 += Alltrim("                                   END + CASE                                                                        ") + msrhEnter
	HR007 += Alltrim("                                           WHEN ZO0.ZO0_ADCINS = '4' THEN zmSalMin * 0.4                             ") + msrhEnter
	HR007 += Alltrim("                                           WHEN ZO0.ZO0_ADCINS = '3' THEN zmSalMin * 0.2                             ") + msrhEnter
	HR007 += Alltrim("                                           ELSE 0                                                                    ") + msrhEnter
	HR007 += Alltrim("                                         END) / 220 * 2.0 * CASE                                                     ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN ZO0.ZO0_CODESC = 246 THEN 7.3333                  ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN ZO0.ZO0_CODESC = 247 THEN 7.3333                  ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN ZO0.ZO0_CODESC = 248 THEN 7.3333                  ") + msrhEnter
	HR007 += Alltrim("                                                              ELSE 0                                                 ") + msrhEnter
	HR007 += Alltrim("                                                            END / 25 * 5,                                            ") + msrhEnter
	HR007 += Alltrim("       QTADNOT = CASE                                                                                                ") + msrhEnter
	HR007 += Alltrim("                   WHEN ZO0.ZO0_CODESC = 247 THEN 4                                                                  ") + msrhEnter
	HR007 += Alltrim("                   WHEN ZO0.ZO0_CODESC = 248 THEN 192                                                                ") + msrhEnter
	HR007 += Alltrim("                   ELSE 0                                                                                            ") + msrhEnter
	HR007 += Alltrim("                 END,                                                                                                ") + msrhEnter
	HR007 += Alltrim("       ADCNOTU = (ZO0.ZO0_SALREF + CASE                                                                              ") + msrhEnter
	HR007 += Alltrim("                                     WHEN ZO0.ZO0_ADCPER = '1' THEN ZO0.ZO0_SALREF * 0.3                             ") + msrhEnter
	HR007 += Alltrim("                                     ELSE 0                                                                          ") + msrhEnter
	HR007 += Alltrim("                                   END + CASE                                                                        ") + msrhEnter
	HR007 += Alltrim("                                           WHEN ZO0.ZO0_ADCINS = '4' THEN zmSalMin * 0.4                             ") + msrhEnter
	HR007 += Alltrim("                                           WHEN ZO0.ZO0_ADCINS = '3' THEN zmSalMin * 0.2                             ") + msrhEnter
	HR007 += Alltrim("                                           ELSE 0                                                                    ") + msrhEnter
	HR007 += Alltrim("                                         END) / 220 * 0.2 * CASE                                                     ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN ZO0.ZO0_CODESC = 247 THEN 4                       ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN ZO0.ZO0_CODESC = 248 THEN 192                     ") + msrhEnter
	HR007 += Alltrim("                                                              ELSE 0                                                 ") + msrhEnter
	HR007 += Alltrim("                                                            END,                                                     ") + msrhEnter
	HR007 += Alltrim("       PREMPROD = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN ZO0.ZO0_BNADC LIKE '%002%' THEN zmPrmPrd                                                    ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       QVLTRANS = ZO0_QVLTRT,                                                                                        ") + msrhEnter
	HR007 += Alltrim("       VLRVTUNI = zmValTrs,                                                                                          ") + msrhEnter
	HR007 += Alltrim("       PRCABTVT = ZB4.ZB4_PRCAVT,                                                                                    ") + msrhEnter
	HR007 += Alltrim("       VLRTRANS = ISNULL((SELECT VLRVTR                                                                              ") + msrhEnter
	HR007 += Alltrim("                            FROM VLRTRANS VTR                                                                        ") + msrhEnter
	HR007 += Alltrim("                           WHERE CONVERT(NUMERIC,NUMCAD) = ZO0.ZO0_MAT), 0 ),                                        ") + msrhEnter
	HR007 += Alltrim("       REFEICAO = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN ZO0.ZO0_BNADC LIKE '%B05%' THEN ZO0.ZO0_QTREFC * zmRefeic * ZB4.ZB4_PRCPAT / 100            ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       DESEJUM  = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN ZO0.ZO0_BNADC LIKE '%B10%' THEN ZO0.ZO0_QTREFC * zmDesejm                                   ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       CARTALM  = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN ZO0.ZO0_BNADC LIKE '%B15%' THEN zmCrtAlm                                                    ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       CJANTUR  = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN ZO0.ZO0_BNADC LIKE '%B20%' THEN zmCJanTr                                                    ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       CJANNOI  = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN ZO0.ZO0_BNADC LIKE '%B25%' THEN zmCJanNo                                                    ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       CARTCOM  = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN ZO0.ZO0_BNADC LIKE '%B30%' THEN zmCrtCom                                                    ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       AJDCTBD  = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN ZO0.ZO0_BNADC LIKE '%B35%' THEN zmAjdCBd                                                    ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       CFCCCRH  = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN ZO0.ZO0_BNADC LIKE '%B40%' THEN 0                                                           ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       PLSMEDIC = ISNULL(RHK.MEDICA,0),                                                                              ") + msrhEnter
	HR007 += Alltrim("       PLSODONT = ISNULL(RHK.ODONTO,0),                                                                              ") + msrhEnter
	HR007 += Alltrim("       VLREXAM  = ZB0.ZB0_VEXAME,                                                                                    ") + msrhEnter
	HR007 += Alltrim("       VLRUNIF  = ZB0.ZB0_VUNIFO,                                                                                    ") + msrhEnter
	HR007 += Alltrim("       VLREPIS  = ZB0.ZB0_VEPI,                                                                                      ") + msrhEnter
	HR007 += Alltrim("       PRCINSS  = ZB2.INSS,                                                                                          ") + msrhEnter
	HR007 += Alltrim("       PRCFGTS  = ZB2.FGTS,                                                                                          ") + msrhEnter
	HR007 += Alltrim("       PRCSENAI = ZB2.SENAI,                                                                                         ") + msrhEnter
	HR007 += Alltrim("       PRCSESI  = ZB2.SESI,                                                                                          ") + msrhEnter
	HR007 += Alltrim("       QSALPPR  = ZO0.ZO0_QSLPPR,                                                                                    ") + msrhEnter
	HR007 += Alltrim("       FMULTFER = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN ZO0.ZO0_BNADC LIKE '%C05%' THEN 1                                                           ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       FMULT13O = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN ZO0.ZO0_BNADC LIKE '%C10%' THEN 1                                                           ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       ZO0_BNADC,                                                                                                    ") + msrhEnter
	HR007 += Alltrim("       TMPCASA = DATEDIFF ( year , convert(datetime, ZO0_ADMISS) , SYSDATETIME() ),                                  ") + msrhEnter
	HR007 += Alltrim("       DPRVFR = ISNULL((SELECT MIN(DATFER)                                                                           ") + msrhEnter
	HR007 += Alltrim("                          FROM " + msNmTMP04 + " A                                                                   ") + msrhEnter
	HR007 += Alltrim("                         WHERE NUMCAD = CONVERT(NUMERIC, ZO0_MAT)), ''),                                             ") + msrhEnter
	HR007 += Alltrim("       MESFER = SUBSTRING(ISNULL((SELECT MIN(DATFER)                                                                 ") + msrhEnter
	HR007 += Alltrim("                                    FROM " + msNmTMP04 + " A                                                         ") + msrhEnter
	HR007 += Alltrim("                                   WHERE NUMCAD = CONVERT(NUMERIC, ZO0_MAT)), '    ' + CASE                          ") + msrhEnter
	HR007 += Alltrim("                                                                           WHEN SUBSTRING(ZO0_ADMISS,5,2) = '12' THEN '01'                                                                                                                 ") + msrhEnter
	HR007 += Alltrim("                                                                           ELSE REPLICATE('0', 2 - LEN(CONVERT(CHAR, CONVERT(NUMERIC, SUBSTRING(ZO0_ADMISS,5,2)) + 1))) + CONVERT(CHAR, CONVERT(NUMERIC, SUBSTRING(ZO0_ADMISS,5,2)) + 1)   ") + msrhEnter
	HR007 += Alltrim("                                                                         END + '  '), 5, 2)                          ") + msrhEnter
	HR007 += Alltrim("  FROM " + RetSqlName("ZO0") + " ZO0                                                                                 ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN " + RetSqlName("ZB4") + " ZB4 ON ZB4.ZB4_FILIAL = '" + xFilial("ZB4") + "'                               ") + msrhEnter
	HR007 += Alltrim("                      AND ZB4.ZB4_CATEGF = ZO0.ZO0_CTGFUN                                                            ") + msrhEnter
	HR007 += Alltrim("                      AND ZB4.D_E_L_E_T_ = ' '                                                                       ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN VETORH.dbo.r024car CAR ON CAR.codcar = CONVERT(NUMERIC, ZO0.ZO0_CARGO)                                   ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN XVARIAVS XVS ON XVS.CHVVRS = '1'                                                                         ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN MNTVIDAX RHK ON RHK.NUMCAD = ZO0.ZO0_MAT                                                                 ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN VLRSESMT ZB0 ON ZB0.ZB0_MATR = ZO0.ZO0_MAT                                                               ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN ENCTRABA ZB2 ON ZB2.CATGFU = ZO0.ZO0_CTGFUN                                                              ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN DTEXAMES DTE ON DTE.NUMCAD = ZO0.ZO0_MAT                                                                 ") + msrhEnter
	HR007 += Alltrim(" WHERE ZO0.ZO0_FILIAL = '" + xFilial("ZO0") + "'                                                                     ") + msrhEnter
	HR007 += Alltrim("       AND ZO0.ZO0_VERSAO = '" + _cVersao + "'                                                                       ") + msrhEnter
	HR007 += Alltrim("       AND ZO0.ZO0_REVISA = '" + _cRevisa + "'                                                                       ") + msrhEnter
	HR007 += Alltrim("       AND ZO0.ZO0_ANOREF = '" + _cAnoRef + "'                                                                       ") + msrhEnter
	HR007 += Alltrim("       AND ZO0.D_E_L_E_T_ = ' '                                                                                      ") + msrhEnter
	HR007 += Alltrim(" ORDER BY ZO0.ZO0_MAT                                                                                                ") + msrhEnter
	HRIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,HR007),'HR07',.T.,.T.)
	dbSelectArea("HR07")
	HR07->(dbGoTop())
	If HR07->(!Eof())

		While HR07->(!Eof())

			//                                                                              Remuneração Total
			//***********************************************************************************************
			msRemunerTot := HR07->SALARIO + HR07->PERICUL + HR07->INSALUB
			msRemunerTot += HR07->HEPROG + HR07->DSRPRG + HR07->ADCNOTU + HR07->PREMPROD

			//msSalarioAdc := HR07->SALARIO + HR07->PERICUL + HR07->INSALUB
			msSalarioAdc := HR07->SALARIO + HR07->PREMPROD

			//                                                                Tratamento para Vale Transporte
			//***********************************************************************************************
			If HR07->CATEGFUN == "035"
				msVlrVT := HR07->VLRTRANS
			Else
				msVlrVT := (HR07->QVLTRANS * HR07->VLRVTUNI ) - (HR07->SALARIO * HR07->PRCABTVT /100)
				If msVlrVT < 0
					msVlrVT := 0 
				EndIf
			EndIf

			//                                                               Provisão de INSS/FGTS/Senai/Sesi
			//***********************************************************************************************
			msFolINSS     := msRemunerTot * HR07->PRCINSS / 100
			msFolFGTS     := msRemunerTot * HR07->PRCFGTS / 100
			msFolSenai    := msRemunerTot * HR07->PRCSENAI / 100
			msFolSesi     := msRemunerTot * HR07->PRCSESI / 100

			//                                        Férias / Abono de Férias /Reflexos INSS/FGTS/Senai/Sesi
			//***********************************************************************************************
			msProvFerias  := HR07->FMULTFER * ( msRemunerTot + ( msRemunerTot / 3 )) / 12
			msAbonoFerias := HR07->FMULTFER * 0
			msPrvFerINSS  := HR07->FMULTFER * msProvFerias * HR07->PRCINSS / 100
			msPrvFerFGTS  := HR07->FMULTFER * msProvFerias * HR07->PRCFGTS / 100
			msPrvFerSENAI := HR07->FMULTFER * msProvFerias * HR07->PRCSENAI / 100
			msPrvFerSESI  := HR07->FMULTFER * msProvFerias * HR07->PRCSESI / 100

			//                                                 Decimo Terceiro /Reflexos INSS/FGTS/Senai/Sesi
			//***********************************************************************************************
			msPrv13       := HR07->FMULT13O * msRemunerTot / 12
			msPrv13INSS   := HR07->FMULT13O * msPrv13 * HR07->PRCINSS / 100
			msPrv13FGTS   := HR07->FMULT13O * msPrv13 * HR07->PRCFGTS / 100
			msPrv13SENAI  := HR07->FMULT13O * msPrv13 * HR07->PRCSENAI / 100
			msPrv13SESI   := HR07->FMULT13O * msPrv13 * HR07->PRCSESI / 100

			msMESDEM := Space(02)
			msDMTDAA := Space(01)

			ZBA->(dbSetOrder(2))
			If ZBA->(dbSeek(xFilial("ZBA") + _cVersao + _cRevisa + _cAnoRef + "00" + HR07->MATR))
				msMESDEM := ZBA->ZBA_MESDEM
				msDMTDAA := ZBA->ZBA_DMTDAA
				Reclock("ZBA",.F.)
				ZBA->(dbDelete())
				ZBA->(MsUnlock())				
			EndIf

			Reclock("ZBA",.T.)
			ZBA->ZBA_FILIAL  := xFilial("ZBA")
			ZBA->ZBA_VERSAO  := _cVersao
			ZBA->ZBA_REVISA  := _cRevisa
			ZBA->ZBA_ANOREF  := _cAnoRef
			ZBA->ZBA_PERIOD  := "00"
			ZBA->ZBA_CLVL    := HR07->CLVL
			ZBA->ZBA_MATR    := HR07->MATR
			ZBA->ZBA_NOME    := HR07->NOME
			ZBA->ZBA_SEMELH  := ""
			ZBA->ZBA_IDADET  := HR07->IDADETT
			ZBA->ZBA_TNOTRA  := HR07->TNOTRAB
			ZBA->ZBA_FUNCAO  := HR07->FUNCAO
			ZBA->ZBA_MESANI  := HR07->MESANI
			ZBA->ZBA_MESADM  := HR07->MESADM
			ZBA->ZBA_MADMNW  := ""
			ZBA->ZBA_MESDEM  := msMESDEM
			ZBA->ZBA_DMTDAA  := msDMTDAA
			ZBA->ZBA_SEMAIL  := HR07->SEMAIL
			ZBA->ZBA_CATGFU  := HR07->CATEGFUN
			ZBA->ZBA_SALARI  := HR07->SALARIO
			ZBA->ZBA_PPERIC  := HR07->PRCPERI
			ZBA->ZBA_PERICU  := HR07->PERICUL
			ZBA->ZBA_PINSAL  := HR07->PRCINSA
			ZBA->ZBA_INSALU  := HR07->INSALUB
			ZBA->ZBA_QTHEPR  := HR07->QTHEPRG
			ZBA->ZBA_VHEPRG  := HR07->HEPROG
			ZBA->ZBA_DSRPRG  := HR07->DSRPRG
			ZBA->ZBA_QHADNO  := HR07->QTADNOT
			ZBA->ZBA_VADCNO  := HR07->ADCNOTU
			ZBA->ZBA_PREMPR  := HR07->PREMPROD
			ZBA->ZBA_TXINST  := HR07->TXINST
			ZBA->ZBA_QVLTRT  := HR07->QVLTRANS
			ZBA->ZBA_VVTUNI  := HR07->VLRVTUNI
			ZBA->ZBA_PRCAVT  := HR07->PRCABTVT
			ZBA->ZBA_VVLTRT  := msVlrVT
			ZBA->ZBA_REFEIC  := HR07->REFEICAO
			ZBA->ZBA_DESEJU  := HR07->DESEJUM
			ZBA->ZBA_CALIME  := HR07->CARTALM
			ZBA->ZBA_CJTURN  := HR07->CJANTUR
			ZBA->ZBA_CJNOIT  := HR07->CJANNOI
			ZBA->ZBA_CCOMBU  := HR07->CARTCOM
			ZBA->ZBA_AJDCBD  := HR07->AJDCTBD
			ZBA->ZBA_CFCCCH  := HR07->CFCCCRH
			ZBA->ZBA_PLSMED  := HR07->PLSMEDIC
			ZBA->ZBA_PLSODO  := HR07->PLSODONT
			ZBA->ZBA_VLREXA  := HR07->VLREXAM
			ZBA->ZBA_VLRUNI  := HR07->VLRUNIF
			ZBA->ZBA_VLREPI  := HR07->VLREPIS
			ZBA->ZBA_PRCINS  := HR07->PRCINSS
			ZBA->ZBA_PRCFGT  := HR07->PRCFGTS
			ZBA->ZBA_PRCSEN  := HR07->PRCSENAI
			ZBA->ZBA_PRCSES  := HR07->PRCSESI
			ZBA->ZBA_VRINSF  := msFolINSS
			ZBA->ZBA_VRFGTF  := msFolFGTS
			ZBA->ZBA_VRSENF  := msFolSenai
			ZBA->ZBA_VRSESF  := msFolSesi
			ZBA->ZBA_FERIAS  := msProvFerias
			ZBA->ZBA_ABONOF  := msAbonoFerias
			ZBA->ZBA_INSFER  := msPrvFerINSS
			ZBA->ZBA_FGTFER  := msPrvFerFGTS
			ZBA->ZBA_SENFER  := msPrvFerSENAI
			ZBA->ZBA_SESFER  := msPrvFerSESI
			ZBA->ZBA_13OSAL  := msPrv13
			ZBA->ZBA_INS13O  := msPrv13INSS
			ZBA->ZBA_FGT13O  := msPrv13FGTS
			ZBA->ZBA_SEN13O  := msPrvFerSENAI
			ZBA->ZBA_SES13O  := msPrvFerSESI
			ZBA->ZBA_QSLPPR  := HR07->QSALPPR
			ZBA->ZBA_VLRPPR  := HR07->QSALPPR * msSalarioAdc * 80 / 100
			ZBA->ZBA_FMULTF  := HR07->FMULTFER
			ZBA->ZBA_FMUL13  := HR07->FMULT13O
			ZBA->ZBA_BNADC   := HR07->ZO0_BNADC
			ZBA->ZBA_TMPCAS  := HR07->TMPCASA
			ZBA->ZBA_DPRVFR  := stod(HR07->DPRVFR)
			ZBA->ZBA_MESFER  := HR07->MESFER
			ZBA->ZBA_CSTFUN  := &(msCustFun)
			ZBA->(MsUnlock())

			HR07->(dbSkip())

		End

		If cEmpAnt <> "07"
			xdtIni := dtos(UltimoDia( stod(MV_PAR02 + "01") ) + 1)
			xdtFim := MV_PAR05 + "0430"
		Else
			xdtIni := dtos(UltimoDia( stod(MV_PAR02 + "01") ) + 1)
			xdtFim := MV_PAR05 + "1031"
		EndIf

		UP009 := Alltrim(" WITH PROGFER                                                                                                                                                               ") + msrhEnter
		UP009 += Alltrim("      AS (SELECT NUMCAD = numcad,                                                                                                                                           ") + msrhEnter
		UP009 += Alltrim("                 VENCIDO = CASE                                                                                                                                             ") + msrhEnter
		UP009 += Alltrim("                               WHEN avofer = 12                                                                                                                             ") + msrhEnter
		UP009 += Alltrim("                               THEN qtdsld                                                                                                                                  ") + msrhEnter
		UP009 += Alltrim("                               ELSE 0                                                                                                                                       ") + msrhEnter
		UP009 += Alltrim("                           END,                                                                                                                                             ") + msrhEnter
		UP009 += Alltrim("                 AVENC = CASE                                                                                                                                               ") + msrhEnter
		UP009 += Alltrim("                             WHEN avofer <> 12                                                                                                                              ") + msrhEnter
		UP009 += Alltrim("                             THEN qtdsld                                                                                                                                    ") + msrhEnter
		UP009 += Alltrim("                             ELSE 0                                                                                                                                         ") + msrhEnter
		UP009 += Alltrim("                         END,                                                                                                                                               ") + msrhEnter
		UP009 += Alltrim("                 (12 - " + Alltrim(Str(Val(Substr(MV_PAR02,5,2)))) + ") * 2.5 RESTYEAR,                                                                                     ") + msrhEnter
		UP009 += Alltrim("                 DATINI = CONVERT(VARCHAR,                                                                                                                                  ") + msrhEnter
		UP009 += Alltrim("          (                                                                                                                                                                 ") + msrhEnter
		UP009 += Alltrim("              SELECT MIN(prgdat)                                                                                                                                            ") + msrhEnter
		UP009 += Alltrim("              FROM VETORH.dbo.r040prg r                                                                                                                                     ") + msrhEnter
		UP009 += Alltrim("              WHERE r.numemp = a.numemp                                                                                                                                     ") + msrhEnter
		UP009 += Alltrim("                    AND r.tipcol = a.tipcol                                                                                                                                 ") + msrhEnter
		UP009 += Alltrim("                    AND r.numcad = a.numcad                                                                                                                                 ") + msrhEnter
		UP009 += Alltrim("          ), 112),                                                                                                                                                          ") + msrhEnter
		UP009 += Alltrim("                 DATFIM = CONVERT(VARCHAR,                                                                                                                                  ") + msrhEnter
		UP009 += Alltrim("          (                                                                                                                                                                 ") + msrhEnter
		UP009 += Alltrim("              SELECT MIN(fimper)                                                                                                                                            ") + msrhEnter
		UP009 += Alltrim("              FROM VETORH.dbo.r040per r                                                                                                                                     ") + msrhEnter
		UP009 += Alltrim("              WHERE r.numemp = a.numemp                                                                                                                                     ") + msrhEnter
		UP009 += Alltrim("                    AND r.tipcol = a.tipcol                                                                                                                                 ") + msrhEnter
		UP009 += Alltrim("                    AND r.numcad = a.numcad                                                                                                                                 ") + msrhEnter
		UP009 += Alltrim("                    AND sitper <> 1                                                                                                                                         ") + msrhEnter
		UP009 += Alltrim("                    AND qtdsld <> 0                                                                                                                                         ") + msrhEnter
		UP009 += Alltrim("          ), 112)                                                                                                                                                           ") + msrhEnter
		UP009 += Alltrim("          FROM VETORH.dbo.r040per a                                                                                                                                         ") + msrhEnter
		UP009 += Alltrim("          WHERE tipcol = 1                                                                                                                                                  ") + msrhEnter
		UP009 += Alltrim("                AND numemp = " + cEmpAnt + "                                                                                                                                ") + msrhEnter
		UP009 += Alltrim("                AND sitper <> 1                                                                                                                                             ") + msrhEnter
		UP009 += Alltrim("                AND qtdsld <> 0),                                                                                                                                           ") + msrhEnter
		UP009 += Alltrim("      PROGFERAGP                                                                                                                                                            ") + msrhEnter
		UP009 += Alltrim("      AS (SELECT NUMCAD,                                                                                                                                                    ") + msrhEnter
		UP009 += Alltrim("                 VENCIDO = SUM(VENCIDO),                                                                                                                                    ") + msrhEnter
		UP009 += Alltrim("                 AVENC = SUM(AVENC),                                                                                                                                        ") + msrhEnter
		UP009 += Alltrim("                 RESTYEAR = AVG(RESTYEAR),                                                                                                                                  ") + msrhEnter
		UP009 += Alltrim("                 DATINI,                                                                                                                                                    ") + msrhEnter
		UP009 += Alltrim("                 DATFIM                                                                                                                                                     ") + msrhEnter
		UP009 += Alltrim("          FROM PROGFER                                                                                                                                                      ") + msrhEnter
		UP009 += Alltrim("          GROUP BY NUMCAD,                                                                                                                                                  ") + msrhEnter
		UP009 += Alltrim("                   DATINI,                                                                                                                                                  ") + msrhEnter
		UP009 += Alltrim("                   DATFIM)                                                                                                                                                  ") + msrhEnter
		UP009 += Alltrim("      UPDATE XXX                                                                                                                                                            ") + msrhEnter
		UP009 += Alltrim("        SET                                                                                                                                                                 ") + msrhEnter
		UP009 += Alltrim("            ZBA_SALFER = ISNULL(ROUND(CASE                                                                                                                                  ") + msrhEnter
		UP009 += Alltrim("                                          WHEN DATINI BETWEEN '" + xdtIni + "' AND '" + xdtFim + "'                                                                         ") + msrhEnter
		UP009 += Alltrim("                                               AND VENCIDO + AVENC + RESTYEAR > 30                                                                                          ") + msrhEnter
		UP009 += Alltrim("                                          THEN VENCIDO + AVENC + RESTYEAR - 30                                                                                              ") + msrhEnter
		UP009 += Alltrim("                                          WHEN DATINI BETWEEN '" + xdtIni + "' AND '" + xdtFim + "'                                                                         ") + msrhEnter
		UP009 += Alltrim("                                          THEN 0                                                                                                                            ") + msrhEnter
		UP009 += Alltrim("                                          ELSE VENCIDO + AVENC + RESTYEAR                                                                                                   ") + msrhEnter
		UP009 += Alltrim("                                      END * (SALBASE / 30), 2), 0),                                                                                                         ") + msrhEnter
		UP009 += Alltrim("            ZBA_FERVEN = ISNULL(CASE                                                                                                                                        ") + msrhEnter
		UP009 += Alltrim("                                    WHEN DATINI BETWEEN '" + xdtIni + "' AND '" + xdtFim + "'                                                                               ") + msrhEnter
		UP009 += Alltrim("                                    THEN 0                                                                                                                                  ") + msrhEnter
		UP009 += Alltrim("                                    ELSE VENCIDO                                                                                                                            ") + msrhEnter
		UP009 += Alltrim("                                END, 0),                                                                                                                                    ") + msrhEnter
		UP009 += Alltrim("            ZBA_FAVENC = ISNULL(AVENC, 0),                                                                                                                                  ") + msrhEnter
		UP009 += Alltrim("            ZBA_RTYEAR = ISNULL(RESTYEAR, 0),                                                                                                                               ") + msrhEnter
		UP009 += Alltrim("            ZBA_DTINIF = ISNULL(DATINI, '')                                                                                                                                 ") + msrhEnter
		UP009 += Alltrim("      FROM                                                                                                                                                                  ") + msrhEnter
		UP009 += Alltrim("      (                                                                                                                                                                     ") + msrhEnter
		UP009 += Alltrim("          SELECT ZBA_MATR,                                                                                                                                                  ") + msrhEnter
		UP009 += Alltrim("                 ZBA.R_E_C_N_O_ REGZBA,                                                                                                                                     ") + msrhEnter
		UP009 += Alltrim("                 SALBASE = AVG(ROUND((ZBA.ZBA_SALARI + ZBA.ZBA_PERICU + ZBA.ZBA_INSALU + ZBA.ZBA_VHEPRG + ZBA.ZBA_DSRPRG + ZBA.ZBA_VADCNO + ZBA.ZBA_PREMPR), 2)),           ") + msrhEnter
		UP009 += Alltrim("                 VENCIDO = SUM(VENCIDO),                                                                                                                                    ") + msrhEnter
		UP009 += Alltrim("                 AVENC = SUM(AVENC),                                                                                                                                        ") + msrhEnter
		UP009 += Alltrim("                 RESTYEAR = AVG(RESTYEAR),                                                                                                                                  ") + msrhEnter
		UP009 += Alltrim("                 DATINI = CASE                                                                                                                                              ") + msrhEnter
		UP009 += Alltrim("                              WHEN MIN(DATINI) = ''                                                                                                                         ") + msrhEnter
		UP009 += Alltrim("                                   AND MAX(DATINI) = ''                                                                                                                     ") + msrhEnter
		UP009 += Alltrim("                              THEN MIN(DATFIM)                                                                                                                              ") + msrhEnter
		UP009 += Alltrim("                              WHEN MIN(DATINI) <> ''                                                                                                                        ") + msrhEnter
		UP009 += Alltrim("                                   AND MIN(DATINI) <= MAX(DATINI)                                                                                                           ") + msrhEnter
		UP009 += Alltrim("                              THEN MIN(DATINI)                                                                                                                              ") + msrhEnter
		UP009 += Alltrim("                              ELSE MAX(DATINI)                                                                                                                              ") + msrhEnter
		UP009 += Alltrim("                          END                                                                                                                                               ") + msrhEnter
		UP009 += Alltrim("          FROM " + RetSqlName("ZBA") + " ZBA                                                                                                                                ") + msrhEnter
		UP009 += Alltrim("               INNER JOIN PROGFERAGP PRG ON PRG.NUMCAD = ZBA.ZBA_MATR                                                                                                       ") + msrhEnter
		UP009 += Alltrim("               INNER JOIN " + RetSqlName("ZO0") + " ZO0 ON ZO0.ZO0_FILIAL = '" + xFilial("ZO0") + "'                                                                        ") + msrhEnter
		UP009 += Alltrim("                                        AND ZO0.ZO0_VERSAO = '" + _cVersao + "'                                                                                             ") + msrhEnter
		UP009 += Alltrim("                                        AND ZO0.ZO0_REVISA = '" + _cRevisa + "'                                                                                             ") + msrhEnter
		UP009 += Alltrim("                                        AND ZO0.ZO0_ANOREF = '" + _cAnoRef + "'                                                                                             ") + msrhEnter
		UP009 += Alltrim("                                        AND ZO0.ZO0_MAT = ZBA.ZBA_MATR                                                                                                      ") + msrhEnter
		UP009 += Alltrim("                                        AND ZO0.ZO0_BNADC LIKE '%C05%'                                                                                                      ") + msrhEnter
		UP009 += Alltrim("                                        AND ZO0.D_E_L_E_T_ = ' '                                                                                                            ") + msrhEnter
		UP009 += Alltrim("          WHERE ZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "'                                                                                                                   ") + msrhEnter
		UP009 += Alltrim("                AND ZBA.ZBA_VERSAO = '" + _cVersao + "'                                                                                                                     ") + msrhEnter
		UP009 += Alltrim("                AND ZBA.ZBA_REVISA = '" + _cRevisa + "'                                                                                                                     ") + msrhEnter
		UP009 += Alltrim("                AND ZBA.ZBA_ANOREF = '" + _cAnoRef + "'                                                                                                                     ") + msrhEnter
		UP009 += Alltrim("                AND ZBA.ZBA_PERIOD = '00'                                                                                                                                   ") + msrhEnter
		UP009 += Alltrim("                AND ZBA.D_E_L_E_T_ = ' '                                                                                                                                    ") + msrhEnter
		UP009 += Alltrim("          GROUP BY ZBA_MATR,                                                                                                                                                ") + msrhEnter
		UP009 += Alltrim("                   ZBA.R_E_C_N_O_                                                                                                                                           ") + msrhEnter
		UP009 += Alltrim("      ) AS TABELAX                                                                                                                                                          ") + msrhEnter
		UP009 += Alltrim("      INNER JOIN " + RetSqlName("ZBA") + " XXX ON XXX.R_E_C_N_O_ = TABELAX.REGZBA                                                                                           ") + msrhEnter
		U_BIAMsgRun("Aguarde... Atualizando Saldo de Férias ... ",,{|| TcSQLExec(UP009)  })

		UP008 := Alltrim(" WITH AFAST                                                                                                     ") + msrhEnter
		UP008 += Alltrim("      AS (SELECT NUMCAD = numcad                                                                                ") + msrhEnter
		UP008 += Alltrim("          FROM VETORH.dbo.r038afa                                                                               ") + msrhEnter
		UP008 += Alltrim("          WHERE tipcol = 1                                                                                      ") + msrhEnter
		UP008 += Alltrim("                AND numemp = " + cEmpAnt + "                                                                    ") + msrhEnter
		UP008 += Alltrim("                AND sitafa = 32                                                                                 ") + msrhEnter
		UP008 += Alltrim("                AND datter = '1900-12-31 00:00:00.000'                                                          ") + msrhEnter
		UP008 += Alltrim("          GROUP BY numcad)                                                                                      ") + msrhEnter
		UP008 += Alltrim("      UPDATE ZBA                                                                                                ") + msrhEnter
		UP008 += Alltrim("        SET                                                                                                     ") + msrhEnter
		UP008 += Alltrim("            ZBA_SALFER = 0,                                                                                     ") + msrhEnter
		UP008 += Alltrim("            ZBA_FERVEN = 0,                                                                                     ") + msrhEnter
		UP008 += Alltrim("            ZBA_FAVENC = 0,                                                                                     ") + msrhEnter
		UP008 += Alltrim("            ZBA_RTYEAR = 0,                                                                                     ") + msrhEnter
		UP008 += Alltrim("            ZBA_DTINIF = ''                                                                                     ") + msrhEnter
		UP008 += Alltrim("      FROM " + RetSqlName("ZBA") + " ZBA                                                                         ") + msrhEnter
		UP008 += Alltrim("           INNER JOIN AFAST AFT ON AFT.NUMCAD = CONVERT(NUMERIC, ZBA.ZBA_MATR)                                  ") + msrhEnter
		UP008 += Alltrim("      WHERE ZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "'                                                           ") + msrhEnter
		UP008 += Alltrim("            AND ZBA.ZBA_VERSAO = '" + _cVersao + "'                                                             ") + msrhEnter
		UP008 += Alltrim("            AND ZBA.ZBA_REVISA = '" + _cRevisa + "'                                                             ") + msrhEnter
		UP008 += Alltrim("            AND ZBA.ZBA_ANOREF = '" + _cAnoRef + "'                                                             ") + msrhEnter
		UP008 += Alltrim("            AND ZBA.ZBA_PERIOD = '00'                                                                           ") + msrhEnter
		UP008 += Alltrim("            AND ZBA.D_E_L_E_T_ = ' '                                                                            ") + msrhEnter
		U_BIAMsgRun("Aguarde... Atualizando Saldo de Férias ... ",,{|| TcSQLExec(UP008)  })

		UP006 := Alltrim(" WITH SEMELHANTE                                                                                                ") + msrhEnter
		UP006 += Alltrim("      AS (SELECT ZBA.*                                                                                          ") + msrhEnter
		UP006 += Alltrim("          FROM " + RetSqlName("ZBA") + " ZBA                                                                    ") + msrhEnter
		UP006 += Alltrim("          WHERE ZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "'                                                       ") + msrhEnter
		UP006 += Alltrim("                AND ZBA_VERSAO = '" + _cVersao + "'                                                             ") + msrhEnter
		UP006 += Alltrim("                AND ZBA_REVISA = '" + _cRevisa + "'                                                             ") + msrhEnter
		UP006 += Alltrim("                AND ZBA_ANOREF = '" + _cAnoRef + "'                                                             ") + msrhEnter
		UP006 += Alltrim("                AND ZBA_MATR IN (SELECT ZBA_SEMELH                                                              ") + msrhEnter
		UP006 += Alltrim("                                   FROM " + RetSqlName("ZBA") + " ZBA                                           ") + msrhEnter
		UP006 += Alltrim("                                  WHERE ZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "'                               ") + msrhEnter
		UP006 += Alltrim("                                    AND ZBA_VERSAO = '" + _cVersao + "'                                         ") + msrhEnter
		UP006 += Alltrim("                                    AND ZBA_REVISA = '" + _cRevisa + "'                                         ") + msrhEnter
		UP006 += Alltrim("                                    AND ZBA_ANOREF = '" + _cAnoRef + "'                                         ") + msrhEnter
		UP006 += Alltrim("                                    AND ZBA_SEMELH <> ''                                                        ") + msrhEnter
		UP006 += Alltrim("                                    AND ZBA.D_E_L_E_T_ = ' ' )                                                  ") + msrhEnter
		UP006 += Alltrim("                AND ZBA.D_E_L_E_T_ = ' ')                                                                       ") + msrhEnter
		UP006 += Alltrim("      UPDATE ZBA SET                                                                                            ") + msrhEnter
		UP006 += Alltrim("             ZBA_TNOTRA = SMT.ZBA_TNOTRA,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_CATGFU = SMT.ZBA_CATGFU,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_SALARI = SMT.ZBA_SALARI,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_PPERIC = SMT.ZBA_PPERIC,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_PERICU = SMT.ZBA_PERICU,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_PINSAL = SMT.ZBA_PINSAL,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_INSALU = SMT.ZBA_INSALU,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_QTHEPR = SMT.ZBA_QTHEPR,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_VHEPRG = SMT.ZBA_VHEPRG,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_DSRPRG = SMT.ZBA_DSRPRG,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_QHADNO = SMT.ZBA_QHADNO,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_VADCNO = SMT.ZBA_VADCNO,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_PREMPR = SMT.ZBA_PREMPR,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_QVLTRT = SMT.ZBA_QVLTRT,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_VVLTRT = SMT.ZBA_VVLTRT,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_REFEIC = SMT.ZBA_REFEIC,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_DESEJU = SMT.ZBA_DESEJU,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_CALIME = SMT.ZBA_CALIME,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_CJTURN = SMT.ZBA_CJTURN,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_CJNOIT = SMT.ZBA_CJNOIT,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_CCOMBU = SMT.ZBA_CCOMBU,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_PLSMED = SMT.ZBA_PLSMED,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_PLSODO = SMT.ZBA_PLSODO,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_VLREXA = SMT.ZBA_VLREXA,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_VLRUNI = SMT.ZBA_VLRUNI,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_VLREPI = SMT.ZBA_VLREPI,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_PRCINS = SMT.ZBA_PRCINS,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_PRCFGT = SMT.ZBA_PRCFGT,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_PRCSEN = SMT.ZBA_PRCSEN,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_PRCSES = SMT.ZBA_PRCSES,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_QSLPPR = SMT.ZBA_QSLPPR,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_SALFER = 0,                                                                                    ") + msrhEnter
		UP006 += Alltrim("             ZBA_FERVEN = 0,                                                                                    ") + msrhEnter
		UP006 += Alltrim("             ZBA_FAVENC = 0,                                                                                    ") + msrhEnter
		UP006 += Alltrim("             ZBA_FERIAS = SMT.ZBA_FERIAS,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_ABONOF = SMT.ZBA_ABONOF,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_INSFER = SMT.ZBA_INSFER,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_FGTFER = SMT.ZBA_FGTFER,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_13OSAL = SMT.ZBA_13OSAL,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_INS13O = SMT.ZBA_INS13O,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_FGT13O = SMT.ZBA_FGT13O,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_VRINSF = SMT.ZBA_VRINSF,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_VRFGTF = SMT.ZBA_VRFGTF,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_VRSENF = SMT.ZBA_VRSENF,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_VRSESF = SMT.ZBA_VRSESF,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_VVTUNI = SMT.ZBA_VVTUNI,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_PRCAVT = SMT.ZBA_PRCAVT,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_RTYEAR = 0,                                                                                    ") + msrhEnter
		UP006 += Alltrim("             ZBA_DTINIF = '',                                                                                   ") + msrhEnter
		UP006 += Alltrim("             ZBA_VLRPPR = SMT.ZBA_VLRPPR,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_TXINST = SMT.ZBA_TXINST,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_SENFER = SMT.ZBA_SENFER,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_SESFER = SMT.ZBA_SESFER,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_SEN13O = SMT.ZBA_SEN13O,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_SES13O = SMT.ZBA_SES13O,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_FMULTF = SMT.ZBA_FMULTF,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_FMUL13 = SMT.ZBA_FMUL13,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_RTUNIF = SMT.ZBA_RTUNIF,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_DAVISO = SMT.ZBA_DAVISO,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_VRAVIS = SMT.ZBA_VRAVIS,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_FGTAVI = SMT.ZBA_FGTAVI,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_FERAVI = SMT.ZBA_FERAVI,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_13OAVI = SMT.ZBA_13OAVI,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_13FGTA = SMT.ZBA_13FGTA,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_13INSA = SMT.ZBA_13INSA,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_13SENA = SMT.ZBA_13SENA,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_13SESA = SMT.ZBA_13SESA,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_BNADC  = SMT.ZBA_BNADC,                                                                         ") + msrhEnter
		UP006 += Alltrim("             ZBA_TMPCAS = SMT.ZBA_TMPCAS,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_MULTAF = SMT.ZBA_MULTAF,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_DMTDAA = ' ',                                                                                  ") + msrhEnter
		UP006 += Alltrim("             ZBA_SALMEN = SMT.ZBA_SALMEN,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_HONORA = SMT.ZBA_HONORA,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_BOLSAE = SMT.ZBA_BOLSAE,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_DPRVFR = '',                                                                                   ") + msrhEnter
		UP006 += Alltrim("             ZBA_MESFER = '',                                                                                   ") + msrhEnter
		UP006 += Alltrim("             ZBA_AJDCBD = SMT.ZBA_AJDCBD,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_CFCCCH = SMT.ZBA_CFCCCH,                                                                       ") + msrhEnter
		UP006 += Alltrim("             ZBA_CSTFUN = " + msCstFuQr + "                                                                     ") + msrhEnter
		UP006 += Alltrim("      FROM " + RetSqlName("ZBA") + " ZBA                                                                        ") + msrhEnter
		UP006 += Alltrim("           INNER JOIN SEMELHANTE SMT ON SMT.ZBA_MATR = ZBA.ZBA_SEMELH                                           ") + msrhEnter
		UP006 += Alltrim("      WHERE ZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "'                                                           ") + msrhEnter
		UP006 += Alltrim("            AND ZBA.ZBA_VERSAO = '" + _cVersao + "'                                                             ") + msrhEnter
		UP006 += Alltrim("            AND ZBA.ZBA_REVISA = '" + _cRevisa + "'                                                             ") + msrhEnter
		UP006 += Alltrim("            AND ZBA.ZBA_ANOREF = '" + _cAnoRef + "'                                                             ") + msrhEnter
		UP006 += Alltrim("            AND SUBSTRING(ZBA.ZBA_MATR, 1, 4) = 'NOVO'                                                          ") + msrhEnter
		UP006 += Alltrim("            AND ZBA.D_E_L_E_T_ = ' '                                                                            ") + msrhEnter
		U_BIAMsgRun("Aguarde... Atualizando dados do Semelhante ... ",,{|| TcSQLExec(UP006)  })

	EndIf	

	HR07->(dbCloseArea())
	Ferase(HRIndex+GetDBExtension())
	Ferase(HRIndex+OrdBagExt())

	MsgINFO("... Fim do Processamento ...")

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
	aAdd(aRegs,{cPerg,"01","De Ano Mês               ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Ano Mês              ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Versão Orçamentária      ?","","","mv_ch3","C",10,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"04","Revisão Ativa            ?","","","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Ano de Referência        ?","","","mv_ch5","C",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
