#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA392
@author Marcos Alberto Soprani
@since 21/09/17
@version 1.0
@description Rotina de processamento e gravação da Fotografia dos dados para Orçamento de RH  
@type function
/*/

User Function BIA392()

	Local M001      := GetNextAlias()
	Local M002      := GetNextAlias()
	Local M003      := GetNextAlias()
	Local M004      := GetNextAlias()
	Local entEnter  := CHR(13) + CHR(10)
	Private msrhEnter := CHR(13) + CHR(10)

	fPerg := "BIA392"
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

		msdConfirm := MsgNOYES("A Versão / Revisão / AnoRef informados já possui >>> " + Alltrim(Str((M002)->CONTAD)) + " <<< registros associados. Caso CONFIRME a continuação do processo os registros associados serão todos apagados." + entEnter + entEnter + " As inclusões de NOVOS FUNCIONÁRIOS, as declarações de DEMISSÕES e PROMOÇÕES EVENTUAIS serão mantidas!!!" + entEnter + entEnter + "Deseja prosseguir???")
		If !msdConfirm

			(M002)->(dbCloseArea())
			Return .F.

		Else

			KS001 := " DELETE " + RetSqlName("ZBA")
			KS001 += "  WHERE ZBA_FILIAL = '" + xFilial("ZBA") + "'
			KS001 += "    AND ZBA_VERSAO = '" + _cVersao + "'
			KS001 += "    AND ZBA_REVISA = '" + _cRevisa + "'
			KS001 += "    AND ZBA_ANOREF = '" + _cAnoRef + "'
			KS001 += "    AND ZBA_PERIOD <> '00'
			KS001 += "    AND D_E_L_E_T_ = ' '
			U_BIAMsgRun("Aguarde... Apagando registros ZBA - DESDOBRAMENTO... ",,{|| TcSQLExec(KS001) })

			KS002 := " DELETE " + RetSqlName("ZBA")
			KS002 += "  WHERE ZBA_FILIAL = '" + xFilial("ZBA") + "'
			KS002 += "    AND ZBA_VERSAO = '" + _cVersao + "'
			KS002 += "    AND ZBA_REVISA = '" + _cRevisa + "'
			KS002 += "    AND ZBA_ANOREF = '" + _cAnoRef + "'
			KS002 += "    AND ZBA_MESDEM = '  '
			KS002 += "    AND ZBA_MATR NOT LIKE '%NOVO%'
			KS002 += "    AND ZBA_DMTDAA <> '1'
			KS002 += "    AND D_E_L_E_T_ = ' '
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

	U_BIAMsgRun("Aguarde... Efetuando gravação dos dados... ",,{|| BIA392A() })

Return

Static Function BIA392A()

	Local msrhEnter := CHR(13) + CHR(10)
	Local msCustFun := ""
	Local msCstFuQr := ""

	MP007 := " SELECT ZBC_RUBRIC "
	MP007 += "   FROM " + RetSqlName("ZBC") + " "
	MP007 += "  WHERE ZBC_VERSAO = '" + _cVersao + "' "
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

	HR007 := Alltrim("WITH VLRTRANS AS (SELECT RD_MAT, ROUND(AVG(SRD.RD_VALOR),2) MEDADC                                                   ") + msrhEnter
	HR007 += Alltrim("                    FROM " + RetSqlName("SRD") + " SRD                                                               ") + msrhEnter
	HR007 += Alltrim("                   WHERE SRD.RD_DATARQ BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'                             ") + msrhEnter
	HR007 += Alltrim("                     AND SRD.RD_PD IN('847','310')                                                                   ") + msrhEnter
	HR007 += Alltrim("                     AND SRD.D_E_L_E_T_ = ' '                                                                        ") + msrhEnter
	HR007 += Alltrim("                   GROUP BY RD_MAT)                                                                                  ") + msrhEnter
	HR007 += Alltrim(",    MNTCVIDA AS (SELECT RHK.RHK_MAT MATRIC,                                                                         ") + msrhEnter
	HR007 += Alltrim("                         RHK_TPFORN TPFORN,                                                                          ") + msrhEnter
	HR007 += Alltrim("                         RHK.RHK_TPPLAN TPPLAN,                                                                      ") + msrhEnter
	HR007 += Alltrim("                         RHK.RHK_PLANO PLANO,                                                                        ") + msrhEnter
	HR007 += Alltrim("                         QTDTIT = 1,                                                                                 ") + msrhEnter
	HR007 += Alltrim("                         ZB1.ZB1_VLRTIT VLRTIT,                                                                      ") + msrhEnter
	HR007 += Alltrim("                         ZB1.ZB1_DSCTIT PRCTIT,                                                                      ") + msrhEnter
	HR007 += Alltrim("                         QTDDEP = (SELECT COUNT(*)                                                                   ") + msrhEnter
	HR007 += Alltrim("                                     FROM " + RetSqlName("RHL") + " RHL                                              ") + msrhEnter
	HR007 += Alltrim("                                    WHERE RHL.RHL_MAT = RHK.RHK_MAT                                                  ") + msrhEnter
	HR007 += Alltrim("                                      AND RHL.RHL_PLANO = RHK.RHK_PLANO                                              ") + msrhEnter
	HR007 += Alltrim("                                      AND RHL.RHL_PERFIM = '      '                                                  ") + msrhEnter
	HR007 += Alltrim("                                      AND RHL.D_E_L_E_T_ = ' '),                                                     ") + msrhEnter
	HR007 += Alltrim("                         ZB1.ZB1_VLRDEP VLRDEP,                                                                      ") + msrhEnter
	HR007 += Alltrim("                         ZB1.ZB1_DSCDEP PRCDEP,                                                                      ") + msrhEnter
	HR007 += Alltrim("                         QTDAGR = (SELECT COUNT(*)                                                                   ") + msrhEnter
	HR007 += Alltrim("                                     FROM " + RetSqlName("RHM") + " RHM                                              ") + msrhEnter
	HR007 += Alltrim("                                    WHERE RHM.RHM_MAT = RHK.RHK_MAT                                                  ") + msrhEnter
	HR007 += Alltrim("                                      AND RHM.RHM_PLANO = RHK.RHK_PLANO                                              ") + msrhEnter
	HR007 += Alltrim("                                      AND RHM.RHM_PERFIM = '      '                                                  ") + msrhEnter
	HR007 += Alltrim("                                      AND RHM.D_E_L_E_T_ = ' '),                                                     ") + msrhEnter
	HR007 += Alltrim("                         ZB1.ZB1_VLRAGR VLRAGR,                                                                      ") + msrhEnter
	HR007 += Alltrim("                         ZB1.ZB1_DSCAGR PRCAGR                                                                       ") + msrhEnter
	HR007 += Alltrim("                    FROM " + RetSqlName("RHK") + " RHK                                                               ") + msrhEnter
	HR007 += Alltrim("                   INNER JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_FILIAL = RHK.RHK_FILIAL                        ") + msrhEnter
	HR007 += Alltrim("                                        AND SRA.RA_MAT = RHK.RHK_MAT                                                 ") + msrhEnter
	HR007 += Alltrim("                                        AND RA_SITFOLH <> 'D'                                                        ") + msrhEnter
	HR007 += Alltrim("                                        AND SRA.D_E_L_E_T_ = ' '                                                     ") + msrhEnter
	HR007 += Alltrim("                    LEFT JOIN " + RetSqlName("ZB1") + " ZB1 ON ZB1.ZB1_CODPLS = RHK.RHK_PLANO                        ") + msrhEnter
	HR007 += Alltrim("                                        AND ZB1.ZB1_VERSAO = '" + _cVersao + "'                                      ") + msrhEnter
	HR007 += Alltrim("                                        AND ZB1.ZB1_REVISA = '" + _cRevisa + "'                                      ") + msrhEnter
	HR007 += Alltrim("                                        AND ZB1.ZB1_ANOREF = '" + _cAnoRef + "'                                      ") + msrhEnter
	HR007 += Alltrim("                                        AND ZB1.ZB1_TIPPLS = RHK.RHK_TPPLAN                                          ") + msrhEnter
	HR007 += Alltrim("                                        AND ( ( ZB1.ZB1_TIPPLS = '1' AND RA_SALARIO BETWEEN ZB1.ZB1_DEFAIX AND ZB1.ZB1_ATFAIX ) OR ( ZB1.ZB1_TIPPLS = '2' AND Convert(numeric(18,0), Round(convert(numeric, convert(datetime, '" + _cAnoRef + "1231') - convert(datetime, SRA.RA_NASC))/365,0) ) BETWEEN ZB1.ZB1_DEFAIX AND ZB1.ZB1_ATFAIX ) )   ") + msrhEnter
	HR007 += Alltrim("                                        AND '01' BETWEEN ZB1.ZB1_DOMES AND ZB1.ZB1_ATMES                             ") + msrhEnter
	HR007 += Alltrim("                                        AND ZB1.D_E_L_E_T_ = ' '                                                     ") + msrhEnter
	HR007 += Alltrim("                   WHERE RHK.RHK_PERFIM = '      '                                                                   ") + msrhEnter
	HR007 += Alltrim("                     AND RHK.D_E_L_E_T_ = ' ')                                                                       ") + msrhEnter
	HR007 += Alltrim(",    MNTVIDAX AS (SELECT *                                                                                           ") + msrhEnter
	HR007 += Alltrim("                    FROM (SELECT MATRIC,                                                                             ") + msrhEnter
	HR007 += Alltrim("                                 CASE                                                                                ") + msrhEnter
	HR007 += Alltrim("                                   WHEN TPFORN = '1' THEN 'MEDICA'                                                   ") + msrhEnter
	HR007 += Alltrim("                                   WHEN TPFORN = '2' THEN 'ODONTO'                                                   ") + msrhEnter
	HR007 += Alltrim("                                   ELSE 'ERROR'                                                                      ") + msrhEnter
	HR007 += Alltrim("                                 END TPFORN,                                                                         ") + msrhEnter
	HR007 += Alltrim("                                 (QTDTIT * VLRTIT * PRCTIT / 100) + (QTDDEP * VLRDEP * PRCDEP / 100) + (QTDAGR * VLRAGR * PRCAGR / 100) VLMNVD                                                                                                                                         ") + msrhEnter
	HR007 += Alltrim("                            FROM MNTCVIDA) AS TBGR                                                                   ") + msrhEnter
	HR007 += Alltrim("                  PIVOT (SUM(VLMNVD)                                                                                 ") + msrhEnter
	HR007 += Alltrim("                         FOR TPFORN IN(MEDICA, ODONTO, ERROR)) FIM)                                                  ") + msrhEnter
	HR007 += Alltrim(",    VLRSESMT AS (SELECT ZB0_MATR, ZB0_VEXAME, ZB0_VUNIFO, ZB0_VEPI                                                  ") + msrhEnter
	HR007 += Alltrim("                    FROM " + RetSqlName("ZB0") + " ZB0                                                               ") + msrhEnter
	HR007 += Alltrim("                   WHERE ZB0.ZB0_VERSAO = '" + _cVersao + "'                                                         ") + msrhEnter
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
	HR007 += Alltrim("                           WHERE ZB2.ZB2_VERSAO = '" + _cVersao + "'                                                 ") + msrhEnter
	HR007 += Alltrim("                             AND ZB2.ZB2_REVISA = '" + _cRevisa + "'                                                 ") + msrhEnter
	HR007 += Alltrim("                             AND ZB2.ZB2_ANOREF = '" + _cAnoRef + "'                                                 ") + msrhEnter
	HR007 += Alltrim("                             AND ZB2.D_E_L_E_T_ = ' ') AS TARE                                                       ") + msrhEnter
	HR007 += Alltrim("                   PIVOT (SUM(ZB2_PRCTOT)                                                                            ") + msrhEnter
	HR007 += Alltrim("                          FOR ZB2_ENCARG IN([1], [2], [3], [4]) ) AS FIM )                                           ") + msrhEnter
	HR007 += Alltrim(",    XVARIAVS AS (SELECT '1' CHVVRS, *                                                                               ") + msrhEnter
	HR007 += Alltrim("                    FROM (SELECT ZB3_VARIAV, ZB3_VCHEIO                                                              ") + msrhEnter
	HR007 += Alltrim("                            FROM " + RetSqlName("ZB3") + " ZB3                                                       ") + msrhEnter
	HR007 += Alltrim("                           WHERE ZB3.ZB3_VERSAO = '" + _cVersao + "'                                                 ") + msrhEnter
	HR007 += Alltrim("                             AND ZB3.ZB3_REVISA = '" + _cRevisa + "'                                                 ") + msrhEnter
	HR007 += Alltrim("                             AND ZB3.ZB3_ANOREF = '" + _cAnoRef + "'                                                 ") + msrhEnter
	HR007 += Alltrim("                             AND ZB3.D_E_L_E_T_ = ' ') AS TARE                                                       ") + msrhEnter
	HR007 += Alltrim("                   PIVOT (SUM(ZB3_VCHEIO)                                                                            ") + msrhEnter
	HR007 += Alltrim("                          FOR ZB3_VARIAV IN(zmSalMin, zmPrmPrd, zmValTrs, zmRefeic, zmDesejm, zmCrtAlm, zmCJanTr, zmCJanNo, zmCrtCom, zmAjdCBd, zmCfccCh) ) AS FIM )                                                                                                                                       ") + msrhEnter
	HR007 += Alltrim(",    DTEXAMES AS (SELECT TM5_MAT, MAX(TM5_DTRESU) DTRESU                                                             ") + msrhEnter
	HR007 += Alltrim("                    FROM " + RetSqlName("TM5") + " TM5                                                               ") + msrhEnter
	HR007 += Alltrim("                   WHERE TM5_EXAME = 'NR7'                                                                           ") + msrhEnter
	HR007 += Alltrim("                     AND D_E_L_E_T_ = ' '                                                                            ") + msrhEnter
	HR007 += Alltrim("                   GROUP BY TM5_MAT)                                                                                 ") + msrhEnter
	HR007 += Alltrim("SELECT SRA.RA_MAT MATR,                                                                                              ") + msrhEnter
	HR007 += Alltrim("       SRA.RA_NOME NOME,                                                                                             ") + msrhEnter
	HR007 += Alltrim("       Convert(numeric(18,0), Round(DATEDIFF(dd,SRA.RA_NASC,'" + _cAnoRef + "1231')/365,0) ) IDADETT,                ") + msrhEnter
	HR007 += Alltrim("       SRA.RA_YCLVL CLVL,                                                                                            ") + msrhEnter
	HR007 += Alltrim("       TUR.TURNO TNOTRAB,                                                                                            ") + msrhEnter
	HR007 += Alltrim("       SRA.RA_CODFUNC FUNCAO,                                                                                        ") + msrhEnter
	HR007 += Alltrim("       SRJ.RJ_DESC DFUNCAO,                                                                                          ") + msrhEnter
	HR007 += Alltrim("       MESANI = CASE                                                                                                 ") + msrhEnter
	HR007 += Alltrim("                  WHEN DTRESU <> '        ' THEN SUBSTRING( Convert(Char(10), DATEADD(month, 10, convert(datetime, DTRESU)) , 112), 5,2)        ") + msrhEnter
	HR007 += Alltrim("                  ELSE SUBSTRING( Convert(Char(10), DATEADD(month, -2, convert(datetime, RA_NASC)) , 112), 5,2)      ") + msrhEnter
	HR007 += Alltrim("                END,                                                                                                 ") + msrhEnter
	HR007 += Alltrim("       MESADM = SUBSTRING( Convert(Char(10), convert(datetime, RA_ADMISSA) , 112), 5,2),                             ") + msrhEnter
	HR007 += Alltrim("       SRA.RA_YSEMAIL SEMAIL,                                                                                        ") + msrhEnter
	HR007 += Alltrim("       SRA.RA_YCTGFU CATEGFUN,                                                                                       ") + msrhEnter
	HR007 += Alltrim("       ZB4.ZB4_DESCRI DCTGFU,                                                                                        ") + msrhEnter
	HR007 += Alltrim("       SRA.RA_SALARIO SALARIO,                                                                                       ") + msrhEnter
	HR007 += Alltrim("       SRA.RA_YTXINST TXINST,                                                                                        ") + msrhEnter
	HR007 += Alltrim("       PRCPERI = CASE                                                                                                ") + msrhEnter
	HR007 += Alltrim("                   WHEN SRA.RA_ADCPERI = '2' THEN 0.3                                                                ") + msrhEnter
	HR007 += Alltrim("                   ELSE 0                                                                                            ") + msrhEnter
	HR007 += Alltrim("                 END,                                                                                                ") + msrhEnter
	HR007 += Alltrim("       PERICUL = CASE                                                                                                ") + msrhEnter
	HR007 += Alltrim("                   WHEN SRA.RA_ADCPERI = '2' THEN SRA.RA_SALARIO * 0.3                                               ") + msrhEnter
	HR007 += Alltrim("                   ELSE 0                                                                                            ") + msrhEnter
	HR007 += Alltrim("                 END,                                                                                                ") + msrhEnter
	HR007 += Alltrim("       PRCINSA = CASE                                                                                                ") + msrhEnter
	HR007 += Alltrim("                   WHEN SRA.RA_ADCINS = '4' THEN 0.4                                                                 ") + msrhEnter
	HR007 += Alltrim("                   WHEN SRA.RA_ADCINS = '3' THEN 0.2                                                                 ") + msrhEnter
	HR007 += Alltrim("                   ELSE 0                                                                                            ") + msrhEnter
	HR007 += Alltrim("                 END,                                                                                                ") + msrhEnter
	HR007 += Alltrim("       INSALUB = CASE                                                                                                ") + msrhEnter
	HR007 += Alltrim("                   WHEN SRA.RA_ADCINS = '4' THEN zmSalMin * 0.4                                                      ") + msrhEnter
	HR007 += Alltrim("                   WHEN SRA.RA_ADCINS = '3' THEN zmSalMin * 0.2                                                      ") + msrhEnter
	HR007 += Alltrim("                   ELSE 0                                                                                            ") + msrhEnter
	HR007 += Alltrim("                 END,                                                                                                ") + msrhEnter
	HR007 += Alltrim("       QTHEPRG = CASE                                                                                                ") + msrhEnter
	HR007 += Alltrim("                   WHEN TUR.TURNO = '047' THEN 7.3333                                                                ") + msrhEnter
	HR007 += Alltrim("                   WHEN SUBSTRING(TUR.TURNO,1,2) = 'E1' THEN 7.3333                                                  ") + msrhEnter
	HR007 += Alltrim("                   WHEN SUBSTRING(TUR.TURNO,1,2) = 'E2' THEN 7.3333                                                  ") + msrhEnter
	HR007 += Alltrim("                   WHEN SUBSTRING(TUR.TURNO,1,2) = 'E3' THEN 7.3333                                                  ") + msrhEnter
	HR007 += Alltrim("                   ELSE 0                                                                                            ") + msrhEnter
	HR007 += Alltrim("                 END,                                                                                                ") + msrhEnter
	HR007 += Alltrim("       HEPROG  = (SRA.RA_SALARIO + CASE                                                                              ") + msrhEnter
	HR007 += Alltrim("                                     WHEN SRA.RA_ADCPERI = '2' THEN SRA.RA_SALARIO * 0.3                             ") + msrhEnter
	HR007 += Alltrim("                                     ELSE 0                                                                          ") + msrhEnter
	HR007 += Alltrim("                                   END + CASE                                                                        ") + msrhEnter
	HR007 += Alltrim("                                           WHEN SRA.RA_ADCINS = '4' THEN zmSalMin * 0.4                              ") + msrhEnter
	HR007 += Alltrim("                                           WHEN SRA.RA_ADCINS = '3' THEN zmSalMin * 0.2                              ") + msrhEnter
	HR007 += Alltrim("                                           ELSE 0                                                                    ") + msrhEnter
	HR007 += Alltrim("                                         END) / 220 * 2.0 * CASE                                                     ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN TUR.TURNO = '047' THEN 7.3333                     ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN SUBSTRING(TUR.TURNO,1,2) = 'E1' THEN 7.3333       ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN SUBSTRING(TUR.TURNO,1,2) = 'E2' THEN 7.3333       ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN SUBSTRING(TUR.TURNO,1,2) = 'E3' THEN 7.3333       ") + msrhEnter
	HR007 += Alltrim("                                                              ELSE 0                                                 ") + msrhEnter
	HR007 += Alltrim("                                                            END,                                                     ") + msrhEnter
	HR007 += Alltrim("       DSRPRG  = (SRA.RA_SALARIO + CASE                                                                              ") + msrhEnter
	HR007 += Alltrim("                                     WHEN SRA.RA_ADCPERI = '2' THEN SRA.RA_SALARIO * 0.3                             ") + msrhEnter
	HR007 += Alltrim("                                     ELSE 0                                                                          ") + msrhEnter
	HR007 += Alltrim("                                   END + CASE                                                                        ") + msrhEnter
	HR007 += Alltrim("                                           WHEN SRA.RA_ADCINS = '4' THEN zmSalMin * 0.4                              ") + msrhEnter
	HR007 += Alltrim("                                           WHEN SRA.RA_ADCINS = '3' THEN zmSalMin * 0.2                              ") + msrhEnter
	HR007 += Alltrim("                                           ELSE 0                                                                    ") + msrhEnter
	HR007 += Alltrim("                                         END) / 220 * 2.0 * CASE                                                     ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN TUR.TURNO = '047' THEN 7.3333                     ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN SUBSTRING(TUR.TURNO,1,2) = 'E1' THEN 7.3333       ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN SUBSTRING(TUR.TURNO,1,2) = 'E2' THEN 7.3333       ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN SUBSTRING(TUR.TURNO,1,2) = 'E3' THEN 7.3333       ") + msrhEnter
	HR007 += Alltrim("                                                              ELSE 0                                                 ") + msrhEnter
	HR007 += Alltrim("                                                            END / 25 * 5,                                            ") + msrhEnter
	HR007 += Alltrim("       QTADNOT = CASE                                                                                                ") + msrhEnter
	HR007 += Alltrim("                   WHEN TUR.TURNO = '047' THEN 64                                                                    ") + msrhEnter
	HR007 += Alltrim("                   WHEN SUBSTRING(TUR.TURNO,1,2) = 'E2' THEN 4                                                       ") + msrhEnter
	HR007 += Alltrim("                   WHEN SUBSTRING(TUR.TURNO,1,2) = 'E3' THEN 192                                                     ") + msrhEnter
	HR007 += Alltrim("                   ELSE 0                                                                                            ") + msrhEnter
	HR007 += Alltrim("                 END,                                                                                                ") + msrhEnter
	HR007 += Alltrim("       ADCNOTU = (SRA.RA_SALARIO + CASE                                                                              ") + msrhEnter
	HR007 += Alltrim("                                     WHEN SRA.RA_ADCPERI = '2' THEN SRA.RA_SALARIO * 0.3                             ") + msrhEnter
	HR007 += Alltrim("                                     ELSE 0                                                                          ") + msrhEnter
	HR007 += Alltrim("                                   END + CASE                                                                        ") + msrhEnter
	HR007 += Alltrim("                                           WHEN SRA.RA_ADCINS = '4' THEN zmSalMin * 0.4                              ") + msrhEnter
	HR007 += Alltrim("                                           WHEN SRA.RA_ADCINS = '3' THEN zmSalMin * 0.2                              ") + msrhEnter
	HR007 += Alltrim("                                           ELSE 0                                                                    ") + msrhEnter
	HR007 += Alltrim("                                         END) / 220 * 0.2 * CASE                                                     ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN TUR.TURNO = '047' THEN 64                         ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN SUBSTRING(TUR.TURNO,1,2) = 'E2' THEN 4            ") + msrhEnter
	HR007 += Alltrim("                                                              WHEN SUBSTRING(TUR.TURNO,1,2) = 'E3' THEN 192          ") + msrhEnter
	HR007 += Alltrim("                                                              ELSE 0                                                 ") + msrhEnter
	HR007 += Alltrim("                                                            END,                                                     ") + msrhEnter
	HR007 += Alltrim("       PREMPROD = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN SRA.RA_YBNADC LIKE '%002%' THEN zmPrmPrd                                                    ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       QVLTRANS = RA_YQVLTRT,                                                                                        ") + msrhEnter
	HR007 += Alltrim("       VLRVTUNI = zmValTrs,                                                                                          ") + msrhEnter
	HR007 += Alltrim("       PRCABTVT = ZB4.ZB4_PRCAVT,                                                                                    ") + msrhEnter
	HR007 += Alltrim("       VLRTRANS = ISNULL((SELECT MEDADC                                                                              ") + msrhEnter
	HR007 += Alltrim("                            FROM VLRTRANS SRD                                                                        ") + msrhEnter
	HR007 += Alltrim("                           WHERE SRD.RD_MAT = SRA.RA_MAT), 0 ),                                                      ") + msrhEnter
	HR007 += Alltrim("       REFEICAO = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN SRA.RA_YBNADC LIKE '%B05%' THEN SRA.RA_YQTREFC * zmRefeic * ZB4.ZB4_PRCPAT / 100            ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       DESEJUM  = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN SRA.RA_YBNADC LIKE '%B10%' THEN SRA.RA_YQTREFC * zmDesejm                                   ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       CARTALM  = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN SRA.RA_YBNADC LIKE '%B15%' THEN zmCrtAlm                                                    ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       CJANTUR  = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN SRA.RA_YBNADC LIKE '%B20%' THEN zmCJanTr                                                    ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       CJANNOI  = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN SRA.RA_YBNADC LIKE '%B25%' THEN zmCJanNo                                                    ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       CARTCOM  = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN SRA.RA_YBNADC LIKE '%B30%' THEN zmCrtCom                                                    ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       AJDCTBD  = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN SRA.RA_YBNADC LIKE '%B35%' THEN zmAjdCBd                                                    ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       CFCCCRH  = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN SRA.RA_YBNADC LIKE '%B40%' THEN 0                                                           ") + msrhEnter
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
	HR007 += Alltrim("       QSALPPR  = SRA.RA_YQSLPPR,                                                                                    ") + msrhEnter
	HR007 += Alltrim("       FMULTFER = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN SRA.RA_YBNADC LIKE '%C05%' THEN 1                                                           ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       FMULT13O = CASE                                                                                               ") + msrhEnter
	HR007 += Alltrim("                    WHEN SRA.RA_YBNADC LIKE '%C10%' THEN 1                                                           ") + msrhEnter
	HR007 += Alltrim("                    ELSE 0                                                                                           ") + msrhEnter
	HR007 += Alltrim("                  END,                                                                                               ") + msrhEnter
	HR007 += Alltrim("       RA_YBNADC,                                                                                                    ") + msrhEnter
	HR007 += Alltrim("       TMPCASA = DATEDIFF ( year , convert(datetime, RA_ADMISSA) , SYSDATETIME() ),                                  ") + msrhEnter
	HR007 += Alltrim("       DPRVFR = ISNULL((SELECT MIN(RF_DATAINI)                                                                       ") + msrhEnter
	HR007 += Alltrim("                          FROM " + RetSqlName("SRF") + " SRF                                                         ") + msrhEnter
	HR007 += Alltrim("                         WHERE RF_MAT = RA_MAT                                                                       ") + msrhEnter
	HR007 += Alltrim("                           AND RF_DATAINI BETWEEN '" + _cAnoRef + "' + '0101' AND '" + _cAnoRef + "' + '1231'        ") + msrhEnter
	HR007 += Alltrim("                           AND SRF.D_E_L_E_T_ = ' '), '') ,                                                          ") + msrhEnter
	HR007 += Alltrim("       MESFER = SUBSTRING(ISNULL((SELECT MIN(RF_DATAINI)                                                             ") + msrhEnter
	HR007 += Alltrim("                                    FROM " + RetSqlName("SRF") + " SRF                                               ") + msrhEnter
	HR007 += Alltrim("                                   WHERE RF_MAT = RA_MAT                                                             ") + msrhEnter
	HR007 += Alltrim("                                     AND RF_DATAINI BETWEEN '" + _cAnoRef + "' + '0101' AND '" + _cAnoRef + "' + '1231'           ") + msrhEnter
	HR007 += Alltrim(" 	                                    AND SRF.D_E_L_E_T_ = ' '), '    ' + CASE                                                     ") + msrhEnter
	HR007 += Alltrim("                                                                           WHEN SUBSTRING(RA_ADMISSA,5,2) = '12' THEN '01'                                                                                                                                                             ") + msrhEnter
	HR007 += Alltrim("                                                                           ELSE REPLICATE('0', 2 - LEN(CONVERT(CHAR, CONVERT(NUMERIC, SUBSTRING(RA_ADMISSA,5,2)) + 1))) + CONVERT(CHAR, CONVERT(NUMERIC, SUBSTRING(RA_ADMISSA,5,2)) + 1)                                               ") + msrhEnter
	HR007 += Alltrim("                                                                         END + '  '), 5, 2)                          ") + msrhEnter
	HR007 += Alltrim("  FROM " + RetSqlName("SRA") + " SRA                                                                                 ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN VW_BG_TURNO_FUNC TUR ON TUR.MATRIC = RA_MAT                                                              ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN " + RetSqlName("SR6") + " SR6 ON SR6.R6_TURNO = SRA.RA_TNOTRAB                                           ") + msrhEnter
	HR007 += Alltrim("                      AND SR6.D_E_L_E_T_ = ' '                                                                       ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN " + RetSqlName("ZB4") + " ZB4 ON ZB4.ZB4_CATEGF = SRA.RA_YCTGFU                                          ") + msrhEnter
	HR007 += Alltrim("                      AND ZB4.D_E_L_E_T_ = ' '                                                                       ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN " + RetSqlName("SRJ") + " SRJ ON SRJ.RJ_FUNCAO = SRA.RA_CODFUNC                                          ") + msrhEnter
	HR007 += Alltrim("                      AND SRJ.D_E_L_E_T_ = ' '                                                                       ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN XVARIAVS XVS ON XVS.CHVVRS = '1'                                                                         ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN MNTVIDAX RHK ON RHK.MATRIC = SRA.RA_MAT                                                                  ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN VLRSESMT ZB0 ON ZB0.ZB0_MATR = SRA.RA_MAT                                                                ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN ENCTRABA ZB2 ON ZB2.CATGFU = SRA.RA_YCTGFU                                                               ") + msrhEnter
	HR007 += Alltrim("  LEFT JOIN DTEXAMES DTE ON DTE.TM5_MAT = SRA.RA_MAT                                                                 ") + msrhEnter
	HR007 += Alltrim(" WHERE SRA.RA_MAT < '2'                                                                                              ") + msrhEnter
	HR007 += Alltrim("   AND ( ( SRA.RA_ADMISSA <= '" + dtos(MV_PAR06) + "' AND SRA.RA_SITFOLH <> 'D' ) OR ( SRA.RA_SITFOLH = 'D' AND SRA.RA_DEMISSA >= '" + dtos(MV_PAR06) + "' ) )                                                                                                                         ") + msrhEnter
	HR007 += Alltrim("   AND SRA.D_E_L_E_T_ = ' '                                                                                          ") + msrhEnter
	HR007 += Alltrim(" ORDER BY SRA.RA_MAT                                                                                                 ") + msrhEnter
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

			msSalarioAdc := HR07->SALARIO + HR07->PERICUL + HR07->INSALUB

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
			ZBA->ZBA_BNADC   := HR07->RA_YBNADC
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

		UP009 := " WITH PROGFER "
		UP009 += "      AS (SELECT SRF.RF_MAT, "
		UP009 += "                 SUM(SRF.RF_DFERVAT) - SUM(SRF.RF_DFERANT) VENCIDO, "
		UP009 += "                 SUM(SRF.RF_DFERAAT) AVENC, "
		UP009 += "                 (12 - " + Alltrim(Str(Val(Substr(MV_PAR02,5,2)))) + ") * 2.5 RESTYEAR, "
		UP009 += "                 SRF.RF_DATAINI, "
		UP009 += "                 CONVERT(CHAR(10), DATEADD(MONTH, -1, CONVERT(DATETIME, SRF.RF_DATAFIM)), 112) RF_DATAFIM "
		UP009 += "          FROM " + RetSqlName("SRF") + " SRF "
		UP009 += "          WHERE SRF.RF_FILIAL = '" + xFilial("SRF") + "' "
		UP009 += "                AND SRF.RF_STATUS = '1' "
		UP009 += "                AND SRF.D_E_L_E_T_ = ' ' "
		UP009 += "          GROUP BY SRF.RF_MAT, "
		UP009 += "                   SRF.RF_DATAINI, "
		UP009 += "                   SRF.RF_DATAFIM) "
		UP009 += "      UPDATE XXX SET "
		UP009 += "            ZBA_SALFER = ROUND(CASE "
		UP009 += "                                   WHEN RF_DATAINI BETWEEN '" + xdtIni + "' AND '" + xdtFim + "' AND VENCIDO + AVENC + RESTYEAR > 30 "
		UP009 += "                                   THEN VENCIDO + AVENC + RESTYEAR - 30 "
		UP009 += "                                   WHEN RF_DATAINI BETWEEN '" + xdtIni + "' AND '" + xdtFim + "' "
		UP009 += "                                   THEN 0 "
		UP009 += "                                   ELSE VENCIDO + AVENC + RESTYEAR "
		UP009 += "                               END * (SALBASE / 30), 2), "
		UP009 += "            ZBA_FERVEN = CASE "
		UP009 += "                             WHEN RF_DATAINI BETWEEN '" + xdtIni + "' AND '" + xdtFim + "' "
		UP009 += "                             THEN 0 "
		UP009 += "                             ELSE VENCIDO "
		UP009 += "                         END, "
		UP009 += "            ZBA_FAVENC = AVENC, "
		UP009 += "            ZBA_RTYEAR = RESTYEAR, "
		UP009 += "            ZBA_DTINIF = RF_DATAINI "
		UP009 += "      FROM "
		UP009 += "      ( "
		UP009 += "          SELECT ZBA_MATR, "
		UP009 += "                 ZBA.R_E_C_N_O_ REGZBA, "
		UP009 += "                 SALBASE = AVG(ROUND((ZBA.ZBA_SALARI + ZBA.ZBA_PERICU + ZBA.ZBA_INSALU + ZBA.ZBA_VHEPRG + ZBA.ZBA_DSRPRG + ZBA.ZBA_VADCNO + ZBA.ZBA_PREMPR), 2)), "
		UP009 += "                 VENCIDO = SUM(VENCIDO), "
		UP009 += "                 AVENC = SUM(AVENC), "
		UP009 += "                 RESTYEAR = AVG(RESTYEAR), "
		UP009 += "                 RF_DATAINI = CASE "
		UP009 += "                                  WHEN MIN(RF_DATAINI) = '' "
		UP009 += "                                       AND MAX(RF_DATAINI) = '' "
		UP009 += "                                  THEN MIN(RF_DATAFIM) "
		UP009 += "                                  WHEN MIN(RF_DATAINI) <> '' "
		UP009 += "                                       AND MIN(RF_DATAINI) <= MAX(RF_DATAINI) "
		UP009 += "                                  THEN MIN(RF_DATAINI) "
		UP009 += "                                  ELSE MAX(RF_DATAINI) "
		UP009 += "                              END "
		UP009 += "          FROM " + RetSqlName("ZBA") + " ZBA "
		UP009 += "               INNER JOIN PROGFER PRG ON PRG.RF_MAT = ZBA.ZBA_MATR "
		UP009 += "               INNER JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_FILIAL = '" + xFilial("ZBA") + "' "
		UP009 += "                                        AND SRA.RA_MAT = ZBA.ZBA_MATR "
		UP009 += "                                        AND SRA.RA_YBNADC LIKE '%C05%' "
		UP009 += "                                        AND SRA.D_E_L_E_T_ = ' ' "
		UP009 += "          WHERE ZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "' "
		UP009 += "                AND ZBA.ZBA_VERSAO = '" + _cVersao + "' "
		UP009 += "                AND ZBA.ZBA_REVISA = '" + _cRevisa + "' "
		UP009 += "                AND ZBA.ZBA_ANOREF = '" + _cAnoRef + "' "
		UP009 += "                AND ZBA.ZBA_PERIOD = '00' "
		UP009 += "                AND ZBA.D_E_L_E_T_ = ' ' "
		UP009 += "          GROUP BY ZBA_MATR, "
		UP009 += "                   ZBA.R_E_C_N_O_ "
		UP009 += "      ) AS TABELAX "	
		UP009 += "      INNER JOIN " + RetSqlName("ZBA") + " XXX ON XXX.R_E_C_N_O_ = TABELAX.REGZBA "
		U_BIAMsgRun("Aguarde... Atualizando Saldo de Férias ... ",,{|| TcSQLExec(UP009)  })

		UP008 := " WITH AFAST
		UP008 += "      AS (SELECT R8_MAT MATR, 
		UP008 += "                 MAX(R8_DATAFIM) DATAFIM
		UP008 += "          FROM " + RetSqlName("SR8") + ""
		UP008 += "          WHERE D_E_L_E_T_ = ' '
		UP008 += "          GROUP BY R8_MAT
		UP008 += "          UNION ALL
		UP008 += "          SELECT R8_MAT MATR, 
		UP008 += "                 MAX(R8_DATAFIM) DATAFIM
		UP008 += "          FROM " + RetSqlName("SR8") + ""
		UP008 += "          WHERE D_E_L_E_T_ = ' '
		UP008 += "                AND R8_DATAFIM = ''
		UP008 += "          GROUP BY R8_MAT)
		UP008 += "      UPDATE ZBA SET "		
		UP008 += "             ZBA_SALFER = 0, 
		UP008 += "             ZBA_FERVEN = 0, 
		UP008 += "             ZBA_FAVENC = 0, 
		UP008 += "             ZBA_RTYEAR = 0, 
		UP008 += "             ZBA_DTINIF = ''
		UP008 += "      FROM " + RetSqlName("SR8") + " SR8
		UP008 += "           INNER JOIN AFAST AFT ON MATR = R8_MAT
		UP008 += "                                   AND DATAFIM = R8_DATAFIM
		UP008 += "           INNER JOIN " + RetSqlName("ZBA") + " ZBA ON ZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "'
		UP008 += "                                    AND ZBA.ZBA_VERSAO = '" + _cVersao + "'
		UP008 += "                                    AND ZBA.ZBA_REVISA = '" + _cRevisa + "'
		UP008 += "                                    AND ZBA.ZBA_ANOREF = '" + _cAnoRef + "'
		UP008 += "                                    AND ZBA.ZBA_PERIOD = '00'
		UP008 += "                                    AND ZBA.ZBA_MATR = R8_MAT
		UP008 += "                                    AND ZBA.D_E_L_E_T_ = ' '
		UP008 += "      WHERE R8_TIPOAFA = '017'
		U_BIAMsgRun("Aguarde... Atualizando Saldo de Férias ... ",,{|| TcSQLExec(UP008)  })

		UP006 := " WITH SEMELHANTE "
		UP006 += "      AS (SELECT ZBA.* "
		UP006 += "          FROM " + RetSqlName("ZBA") + " ZBA "
		UP006 += "          WHERE ZBA_VERSAO = '" + _cVersao + "' "
		UP006 += "                AND ZBA_REVISA = '" + _cRevisa + "' "
		UP006 += "                AND ZBA_ANOREF = '" + _cAnoRef + "' "
		UP006 += "                AND ZBA_MATR IN (SELECT ZBA_SEMELH "
		UP006 += "                                   FROM " + RetSqlName("ZBA") + " ZBA "
		UP006 += "                                  WHERE ZBA_VERSAO = '" + _cVersao + "' "
		UP006 += "                                    AND ZBA_REVISA = '" + _cRevisa + "' "
		UP006 += "                                    AND ZBA_ANOREF = '" + _cAnoRef + "' "
		UP006 += "                                    AND ZBA_SEMELH <> '' "
		UP006 += "                                    AND ZBA.D_E_L_E_T_ = ' ' ) "
		UP006 += "                AND ZBA.D_E_L_E_T_ = ' ') "
		UP006 += "      UPDATE ZBA SET " 
		UP006 += "             ZBA_TNOTRA = SMT.ZBA_TNOTRA, "
		UP006 += "             ZBA_CATGFU = SMT.ZBA_CATGFU, "
		UP006 += "             ZBA_SALARI = SMT.ZBA_SALARI, "
		UP006 += "             ZBA_PPERIC = SMT.ZBA_PPERIC, "
		UP006 += "             ZBA_PERICU = SMT.ZBA_PERICU, "
		UP006 += "             ZBA_PINSAL = SMT.ZBA_PINSAL, "
		UP006 += "             ZBA_INSALU = SMT.ZBA_INSALU, "
		UP006 += "             ZBA_QTHEPR = SMT.ZBA_QTHEPR, "
		UP006 += "             ZBA_VHEPRG = SMT.ZBA_VHEPRG, "
		UP006 += "             ZBA_DSRPRG = SMT.ZBA_DSRPRG, "
		UP006 += "             ZBA_QHADNO = SMT.ZBA_QHADNO, "
		UP006 += "             ZBA_VADCNO = SMT.ZBA_VADCNO, "
		UP006 += "             ZBA_PREMPR = SMT.ZBA_PREMPR, "
		UP006 += "             ZBA_QVLTRT = SMT.ZBA_QVLTRT, "
		UP006 += "             ZBA_VVLTRT = SMT.ZBA_VVLTRT, "
		UP006 += "             ZBA_REFEIC = SMT.ZBA_REFEIC, "
		UP006 += "             ZBA_DESEJU = SMT.ZBA_DESEJU, "
		UP006 += "             ZBA_CALIME = SMT.ZBA_CALIME, "
		UP006 += "             ZBA_CJTURN = SMT.ZBA_CJTURN, "
		UP006 += "             ZBA_CJNOIT = SMT.ZBA_CJNOIT, "
		UP006 += "             ZBA_CCOMBU = SMT.ZBA_CCOMBU, "
		UP006 += "             ZBA_PLSMED = SMT.ZBA_PLSMED, "
		UP006 += "             ZBA_PLSODO = SMT.ZBA_PLSODO, "
		UP006 += "             ZBA_VLREXA = SMT.ZBA_VLREXA, "
		UP006 += "             ZBA_VLRUNI = SMT.ZBA_VLRUNI, "
		UP006 += "             ZBA_VLREPI = SMT.ZBA_VLREPI, "
		UP006 += "             ZBA_PRCINS = SMT.ZBA_PRCINS, "
		UP006 += "             ZBA_PRCFGT = SMT.ZBA_PRCFGT, "
		UP006 += "             ZBA_PRCSEN = SMT.ZBA_PRCSEN, "
		UP006 += "             ZBA_PRCSES = SMT.ZBA_PRCSES, "
		UP006 += "             ZBA_QSLPPR = SMT.ZBA_QSLPPR, "
		UP006 += "             ZBA_SALFER = 0, "
		UP006 += "             ZBA_FERVEN = 0, "
		UP006 += "             ZBA_FAVENC = 0, "		
		UP006 += "             ZBA_FERIAS = SMT.ZBA_FERIAS, "
		UP006 += "             ZBA_ABONOF = SMT.ZBA_ABONOF, "
		UP006 += "             ZBA_INSFER = SMT.ZBA_INSFER, "
		UP006 += "             ZBA_FGTFER = SMT.ZBA_FGTFER, "
		UP006 += "             ZBA_13OSAL = SMT.ZBA_13OSAL, "
		UP006 += "             ZBA_INS13O = SMT.ZBA_INS13O, "
		UP006 += "             ZBA_FGT13O = SMT.ZBA_FGT13O, "
		UP006 += "             ZBA_VRINSF = SMT.ZBA_VRINSF, "
		UP006 += "             ZBA_VRFGTF = SMT.ZBA_VRFGTF, "
		UP006 += "             ZBA_VRSENF = SMT.ZBA_VRSENF, "
		UP006 += "             ZBA_VRSESF = SMT.ZBA_VRSESF, "
		UP006 += "             ZBA_VVTUNI = SMT.ZBA_VVTUNI, "
		UP006 += "             ZBA_PRCAVT = SMT.ZBA_PRCAVT, "
		UP006 += "             ZBA_RTYEAR = 0,  "
		UP006 += "             ZBA_DTINIF = '', "
		UP006 += "             ZBA_VLRPPR = SMT.ZBA_VLRPPR, "
		UP006 += "             ZBA_TXINST = SMT.ZBA_TXINST, "
		UP006 += "             ZBA_SENFER = SMT.ZBA_SENFER, "
		UP006 += "             ZBA_SESFER = SMT.ZBA_SESFER, "
		UP006 += "             ZBA_SEN13O = SMT.ZBA_SEN13O, "
		UP006 += "             ZBA_SES13O = SMT.ZBA_SES13O, "
		UP006 += "             ZBA_FMULTF = SMT.ZBA_FMULTF, "
		UP006 += "             ZBA_FMUL13 = SMT.ZBA_FMUL13, "
		UP006 += "             ZBA_RTUNIF = SMT.ZBA_RTUNIF, "
		UP006 += "             ZBA_DAVISO = SMT.ZBA_DAVISO, "
		UP006 += "             ZBA_VRAVIS = SMT.ZBA_VRAVIS, "
		UP006 += "             ZBA_FGTAVI = SMT.ZBA_FGTAVI, "
		UP006 += "             ZBA_FERAVI = SMT.ZBA_FERAVI, "
		UP006 += "             ZBA_13OAVI = SMT.ZBA_13OAVI, "
		UP006 += "             ZBA_13FGTA = SMT.ZBA_13FGTA, "
		UP006 += "             ZBA_13INSA = SMT.ZBA_13INSA, "
		UP006 += "             ZBA_13SENA = SMT.ZBA_13SENA, "
		UP006 += "             ZBA_13SESA = SMT.ZBA_13SESA, "
		UP006 += "             ZBA_BNADC = SMT.ZBA_BNADC, "
		UP006 += "             ZBA_TMPCAS = SMT.ZBA_TMPCAS, "
		UP006 += "             ZBA_MULTAF = SMT.ZBA_MULTAF, "
		UP006 += "             ZBA_DMTDAA = ' ', "
		UP006 += "             ZBA_SALMEN = SMT.ZBA_SALMEN, "
		UP006 += "             ZBA_HONORA = SMT.ZBA_HONORA, "
		UP006 += "             ZBA_BOLSAE = SMT.ZBA_BOLSAE, "
		UP006 += "             ZBA_DPRVFR = '', "
		UP006 += "             ZBA_MESFER = '', "
		UP006 += "             ZBA_AJDCBD = SMT.ZBA_AJDCBD, "
		UP006 += "             ZBA_CFCCCH = SMT.ZBA_CFCCCH, "
		UP006 += "             ZBA_CSTFUN = " + msCstFuQr + " "
		UP006 += "      FROM " + RetSqlName("ZBA") + " ZBA "
		UP006 += "           INNER JOIN SEMELHANTE SMT ON SMT.ZBA_MATR = ZBA.ZBA_SEMELH "
		UP006 += "      WHERE ZBA.ZBA_VERSAO = '" + _cVersao + "' "
		UP006 += "            AND ZBA.ZBA_REVISA = '" + _cRevisa + "' "
		UP006 += "            AND ZBA.ZBA_ANOREF = '" + _cAnoRef + "' "
		UP006 += "            AND SUBSTRING(ZBA.ZBA_MATR, 1, 4) = 'NOVO' "
		UP006 += "            AND ZBA.D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Aguarde... Atualizando Turno de Trabalho ... ",,{|| TcSQLExec(UP006)  })

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
	aAdd(aRegs,{cPerg,"06","Data Limite das Admissões?","","","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
