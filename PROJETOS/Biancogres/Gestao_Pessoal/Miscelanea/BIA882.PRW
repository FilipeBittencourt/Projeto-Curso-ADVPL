#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA882
@author Marcos Alberto Soprani
@since 12/08/2019
@version 1.0
@description Rotina de processamento e gravação do desdobramento da Prévia de Orçamento de RH em meses  
@type function
/*/

User Function BIA882()

	Local M001        := GetNextAlias()
	Private msrhEnter := CHR(13) + CHR(10)
	Private _cSequen	:=	""
	Private _oAcessos	:=	tAcessosOrcamento():New()

	fPerg := "BIA882"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cVersao   := MV_PAR01   
	_cRevisa   := MV_PAR02
	_cAnoRef   := MV_PAR03

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!")
		Return .F.
	EndIf

	xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual RH" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
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
		AND ZB5.ZB5_DTDIGT <> ''
		AND ZB5.ZB5_DTCONS = ''
		AND ZB5.ZB5_DTCONS <= %Exp:dtos(Date())%
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

	_oAcessos:GetAcessos(MV_PAR01,MV_PAR02,MV_PAR03,"RH",__cUserId)

	If aScan(_oAcessos:aAcessos,{|x| x[3] }) == 0
		MsgAlert("Usuário sem acesso à Rotina para o período em questão","BIA882")
		Return
	EndIf

	_cSequen	:=	fGetSeq()

	U_BIAMsgRun("Aguarde... Efetuando gravação dos dados... ",,{|| BIA882A() })

Return

Static Function BIA882A()

	Local mxFx

	Local msCustFun := ""
	Local qyCustFun := ""
	Local _cClVlIn	:=	""
	Local _nI

	Local msNmTMPII := "##TBIA882II" + cEmpAnt + cFilAnt + __cUserID + strzero(seconds() * 3500,10)

	//                                                 Acerta campo de benefícios 
	//***************************************************************************
	UP006 := Alltrim(" WITH SEMELHANTE                                                                                                ") + msrhEnter
	UP006 += Alltrim("      AS (SELECT ZBA.ZBA_MATR, ZBA.ZBA_BNADC                                                                    ") + msrhEnter
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
	UP006 += Alltrim("             ZBA_BNADC  = SMT.ZBA_BNADC                                                                         ") + msrhEnter
	UP006 += Alltrim("      FROM " + RetSqlName("ZBA") + " ZBA                                                                        ") + msrhEnter
	UP006 += Alltrim("           INNER JOIN SEMELHANTE SMT ON SMT.ZBA_MATR = ZBA.ZBA_SEMELH                                           ") + msrhEnter
	UP006 += Alltrim("      WHERE ZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "'                                                           ") + msrhEnter
	UP006 += Alltrim("            AND ZBA.ZBA_VERSAO = '" + _cVersao + "'                                                             ") + msrhEnter
	UP006 += Alltrim("            AND ZBA.ZBA_REVISA = '" + _cRevisa + "'                                                             ") + msrhEnter
	UP006 += Alltrim("            AND ZBA.ZBA_ANOREF = '" + _cAnoRef + "'                                                             ") + msrhEnter
	UP006 += Alltrim("            AND SUBSTRING(ZBA.ZBA_MATR, 1, 4) = 'NOVO'                                                          ") + msrhEnter
	UP006 += Alltrim("            AND ZBA.D_E_L_E_T_ = ' '                                                                            ") + msrhEnter
	U_BIAMsgRun("Aguarde... Atualizando dados do Semelhante ... ",,{|| TcSQLExec(UP006)  })

	//                                                    Apura campos para pivot 
	//***************************************************************************
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
		msCustFun += "ZBG->" + REPLACE(MP07->ZBC_RUBRIC,"ZBA","ZBG")
		qyCustFun += REPLACE(MP07->ZBC_RUBRIC,"ZBA","ZBG")
		MP07->(dbSkip())
		If MP07->(!Eof())
			msCustFun += " + "
			qyCustFun += " + "
		EndIf
	End
	MP07->(dbCloseArea())
	Ferase(MPIndex+GetDBExtension())
	Ferase(MPIndex+OrdBagExt())

	//                                               Flutuação de Feriados no ano 
	//***************************************************************************
	RF004 := " WITH QFERIADOS AS (SELECT 'M' + SUBSTRING(ZB7_ANOMES,5,2) MES, ZB7_NRFERI NRFERI "
	RF004 += "                      FROM " + RetSqlName("ZB7") + " ZB7 "
	RF004 += "                     WHERE ZB7_VERSAO = '" + _cVersao + "' "
	RF004 += "                       AND ZB7_REVISA = '" + _cRevisa + "' "
	RF004 += "                       AND ZB7_ANOREF = '" + _cAnoRef + "' "
	RF004 += "                       AND D_E_L_E_T_ = ' ') "
	RF004 += " SELECT * "
	RF004 += "   FROM QFERIADOS "
	RF004 += "  PIVOT (SUM(NRFERI) "
	RF004 += "    FOR MES IN([M01], [M02], [M03], [M04], [M05], [M06], [M07], [M08], [M09], [M10], [M11], [M12])) AS FIM "
	RFIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RF004),'RF04',.T.,.T.)
	dbSelectArea("RF04")
	RF04->(dbGoTop())

	//                       Valor considerado para Crachas de novos funcionários 
	//***************************************************************************
	RF009 := " SELECT ZB3_VCHEIO VALOR "
	RF009 += "   FROM " + RetSqlName("ZB3") + " ZB3 "
	RF009 += "  WHERE ZB3.ZB3_VERSAO = '" + _cVersao + "' "
	RF009 += "    AND ZB3.ZB3_REVISA = '" + _cRevisa + "' "
	RF009 += "    AND ZB3.ZB3_ANOREF = '" + _cAnoRef + "' "
	RF009 += "    AND ZB3.ZB3_VARIAV = 'zmCfccCh       ' "
	RF009 += "    AND ZB3.D_E_L_E_T_ = ' ' "	
	R9Index := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RF009),'RF09',.T.,.T.)
	dbSelectArea("RF09")
	RF09->(dbGoTop())
	zmCfccCh := RF09->VALOR
	RF09->(dbCloseArea())
	Ferase(R9Index+GetDBExtension())
	Ferase(R9Index+OrdBagExt())

	For _nI := 1 to Len(_oAcessos:aAcessos)
		If _oAcessos:aAcessos[_nI,3]
			_cClvlIn	+= "'" + _oAcessos:aAcessos[_nI,1] + "'" + Iif(_nI <> Len(_oAcessos:aAcessos),",","")
		EndIf	
	Next
	If Empty(_cClVlIn)
		_cClVlIn	:=	"''"
	EndIf

	_cClvlIn := "(" + _cClvlIn + ")"	

	//                                                               Orçamento RH 
	//***************************************************************************
	MQ007 := " SELECT ZBA.*, ZB4_REAJDI, ZB4_MIN050, ZB4_MIM100
	MQ007 += "   FROM " + RetSqlName("ZBA") + " ZBA "
	MQ007 += "   LEFT JOIN " + RetSqlName("ZB4") + " ZB4 ON ZB4.ZB4_FILIAL = '" + xFilial("ZB4") + "' "
	MQ007 += "                       AND ZB4.ZB4_CATEGF = ZBA.ZBA_CATGFU "
	MQ007 += "                       AND ZB4.D_E_L_E_T_ = ' ' "
	MQ007 += "  WHERE ZBA.ZBA_FILIAL = '" + xFilial("ZBA") + "' "
	MQ007 += "    AND ZBA.ZBA_VERSAO = '" + _cVersao + "' "
	MQ007 += "    AND ZBA.ZBA_REVISA = '" + _cRevisa + "' "
	MQ007 += "    AND ZBA.ZBA_ANOREF = '" + _cAnoRef + "' "
	MQ007 += "    AND ZBA.ZBA_PERIOD = '00' "
	MQ007 += "    AND ZBA.ZBA_CLVL IN " + _cClvlIn
	MQ007 += "    AND ZBA.ZBA_DMTDAA <> '1' "
	MQ007 += "    AND ZBA.D_E_L_E_T_ = ' ' "
	MQ007 += "  ORDER BY ZBA.ZBA_MATR "
	MQIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,MQ007),'MQ07',.T.,.T.)
	dbSelectArea("MQ07")
	MQ07->(dbGoTop())

	If MQ07->(!Eof())

		//                                                             Salário Mínimo
		//***************************************************************************
		JF002 := " SELECT ZB3_VCHEIO VALOR "
		JF002 += "   FROM " + RetSqlName("ZB3") + " ZB3 "
		JF002 += "  WHERE ZB3.ZB3_FILIAL = '" + xFilial("ZB3") + "' "
		JF002 += "    AND ZB3.ZB3_VERSAO = '" + _cVersao + "' "
		JF002 += "    AND ZB3.ZB3_REVISA = '" + _cRevisa + "' "
		JF002 += "    AND ZB3.ZB3_ANOREF = '" + _cAnoRef + "' "
		JF002 += "    AND ZB3.ZB3_VARIAV = 'zmSalMin       ' "
		JF002 += "    AND ZB3.D_E_L_E_T_ = ' ' "
		JFIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,JF002),'JF02',.T.,.T.)
		dbSelectArea("JF02")
		JF02->(dbGoTop())
		zmSalMin := JF02->VALOR
		JF02->(dbCloseArea())
		Ferase(JFIndex+GetDBExtension())
		Ferase(JFIndex+OrdBagExt())

		While MQ07->(!Eof())

			//                                                        Reajustes Eventuais
			//***************************************************************************
			MP002 := " SELECT * "
			MP002 += "   FROM " + RetSqlName("ZB8") + " ZB8 "
			MP002 += "  WHERE ZB8.ZB8_FILIAL = '" + xFilial("ZB8") + "' "
			MP002 += "    AND ZB8.ZB8_VERSAO = '" + _cVersao + "' "
			MP002 += "    AND ZB8.ZB8_REVISA = '" + _cRevisa + "' "
			MP002 += "    AND ZB8.ZB8_ANOREF = '" + _cAnoRef + "' "
			MP002 += "    AND ZB8.ZB8_MATR = '" + MQ07->ZBA_MATR + "' "
			MP002 += "    AND ZB8.ZB8_CLVL = '" + MQ07->ZBA_CLVL + "' "
			MP002 += "    AND ZB8.D_E_L_E_T_ = ' ' "
			MPIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,MP002),'MP02',.T.,.T.)
			dbSelectArea("MP02")
			MP02->(dbGoTop())

			msFerAculVlProv := 0
			ms13oAculVlProv := 0
			msGravouCfccCh  := .F.
			For mxFx := 1 to 12

				//                                                        Reajustes Previstos
				//***************************************************************************
				PV004 := " WITH REAJUST AS (SELECT REPLACE(ZBB_RUBRIC,'ZBA_','ZBG_') ZBB_RUBRIC, ZBB_M" + StrZero(mxFx,2) + " REAJMES "
				PV004 += "                    FROM " + RetSqlName("ZBB") + " ZBB "
				PV004 += "                   WHERE ZBB.ZBB_FILIAL = '" + xFilial("ZBB") + "' "
				PV004 += "                     AND ZBB.ZBB_VERSAO = '" + _cVersao + "' "
				PV004 += "                     AND ZBB.ZBB_REVISA = '" + _cRevisa + "' "
				PV004 += "                     AND ZBB.ZBB_ANOREF = '" + _cAnoRef + "' "
				PV004 += "                     AND ZBB.D_E_L_E_T_ = ' ') "
				PV004 += " SELECT * "
				PV004 += "   FROM REAJUST "
				PV004 += "  PIVOT (SUM(REAJMES) "
				PV004 += "    FOR ZBB_RUBRIC IN([ZBG_SALARI], [ZBG_CALIME], [ZBG_CJTURN], [ZBG_CJNOIT], [ZBG_CCOMBU], [ZBG_PLSMED], [ZBG_PLSODO])) AS FIM "
				PVIndex := CriaTrab(Nil,.f.)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,PV004),'PV04',.T.,.T.)
				dbSelectArea("PV04")
				PV04->(dbGoTop())

				//                          Salário = ( SalárioBase + RemuneraçãoEventual ) * % Reajuste Previsto
				//***********************************************************************************************

				//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>para aqueles funcionários que recebem apenas 50% do Salário Mínimo
				//***********************************************************************************************
				If MQ07->ZB4_MIN050 == "1"
					msSalario := zmSalMin * 50 / 100
				Else
					msSalario := MQ07->ZBA_SALARI
				EndIf 

				//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Reajuste Eventual, definido pelo Gestor
				//***********************************************************************************************
				msSalario +=  &("MP02->ZB8_M" + StrZero(mxFx,2))

				//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Reajuste Previsto, controlado por categoria
				//***********************************************************************************************
				If MQ07->ZB4_REAJDI == "1"
					msSalario += msSalario * PV04->ZBG_SALARI / 100
				EndIf

				//>>>>>>>>>>>>>>>>>>>>para aqueles funcionários que possuem como piso salarial o o Salário Mínimo
				//***********************************************************************************************
				If MQ07->ZB4_MIM100 == "1"
					If msSalario < zmSalMin
						msSalario := zmSalMin
					EndIf
				Else
					msSalario := msSalario
				EndIf 

				//                                                          Reajuste de Faixa para Plano de Saúde
				//***********************************************************************************************
				bnMEDICA := 0
				bnODONTO := 0
				bnMatRef := IIf( Substr(MQ07->ZBA_MATR,1,4) == "NOVO", MQ07->ZBA_SEMELH, MQ07->ZBA_MATR )

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
				CT002 += Alltrim("                                             AND " + Alltrim(Str(msSalario)) + " BETWEEN ZB1.ZB1_DEFAIX AND ZB1.ZB1_ATFAIX)       ") + msrhEnter
				CT002 += Alltrim("                                            OR (ZB1.ZB1_TIPPLS = '2'                                             ") + msrhEnter
				CT002 += Alltrim("                                                AND CONVERT(NUMERIC(18, 0), ROUND(CONVERT(NUMERIC, CONVERT(DATETIME, '" + _cAnoRef + StrZero(mxFx,2) + "01') - CONVERT(DATETIME, ZO0.ZO0_DATNAS)) / 365, 0)) BETWEEN ZB1.ZB1_DEFAIX AND ZB1.ZB1_ATFAIX))   ") + msrhEnter
				CT002 += Alltrim("                                       AND '" + StrZero(mxFx,2) + "' BETWEEN ZB1.ZB1_DOMES AND ZB1.ZB1_ATMES     ") + msrhEnter
				CT002 += Alltrim("                                       AND ZB1.D_E_L_E_T_ = ' '                                                  ") + msrhEnter
				CT002 += Alltrim("          WHERE ass.tipcol = 1                                                                                   ") + msrhEnter
				CT002 += Alltrim("                AND ass.numcad = '" + Alltrim(Str(Val(bnMatRef))) + "'                                           ") + msrhEnter
				CT002 += Alltrim("                AND ((ass.mesexc = '1900-12-31 00:00:00.000')                                                    ") + msrhEnter
				CT002 += Alltrim("                     OR ('" + _cAnoRef + "-12-31 00:00:00.000' BETWEEN ass.mesinc AND ass.mesexc)))              ") + msrhEnter
				CT002 += Alltrim("      SELECT * INTO " + msNmTMPII + "                                                                            ") + msrhEnter
				CT002 += Alltrim("      FROM PLNSAUDE                                                                                              ") + msrhEnter
				U_BIAMsgRun("Aguarde... Plano de Saude...",,{|| TcSQLExec(CT002)})

				PV005 := Alltrim(" WITH MNTCVIDA AS (SELECT * FROM " + msNmTMPII + ")                                                                   ") + msrhEnter
				PV005 += Alltrim(" ,    MNTVIDAX AS (SELECT *                                                                                           ") + msrhEnter
				PV005 += Alltrim("                     FROM (SELECT NUMCAD,                                                                             ") + msrhEnter
				PV005 += Alltrim("                                  CASE                                                                                ") + msrhEnter
				PV005 += Alltrim("                                    WHEN TPFORN = '1' THEN 'MEDICA'                                                   ") + msrhEnter
				PV005 += Alltrim("                                    WHEN TPFORN = '2' THEN 'ODONTO'                                                   ") + msrhEnter
				PV005 += Alltrim("                                    ELSE 'ERROR'                                                                      ") + msrhEnter
				PV005 += Alltrim("                                  END TPFORN,                                                                         ") + msrhEnter
				PV005 += Alltrim("                                  (QTDTIT * VLRTIT * PRCTIT / 100) + (QTDDEP * VLRDEP * PRCDEP / 100) + (QTDAGR * VLRAGR * PRCAGR / 100) VLMNVD   ") + msrhEnter
				PV005 += Alltrim("                             FROM MNTCVIDA                                                                            ") + msrhEnter
				PV005 += Alltrim("                             WHERE NUMEMP = " + cEmpAnt + "                                                           ") + msrhEnter
				PV005 += Alltrim("                          ) AS TBGR PIVOT (SUM(VLMNVD)                                                                ") + msrhEnter
				PV005 += Alltrim("                          FOR TPFORN IN(MEDICA, ODONTO, ERROR)) FIM)                                                  ") + msrhEnter
				PV005 += Alltrim(" SELECT *                                                                                                             ") + msrhEnter
				PV005 += Alltrim("   FROM MNTVIDAX                                                                                                      ") + msrhEnter	
				P5Index := CriaTrab(Nil,.f.)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,PV005),'PV05',.T.,.T.)
				dbSelectArea("PV05")
				PV05->(dbGoTop())
				bnMEDICA := PV05->MEDICA
				bnODONTO := PV05->ODONTO
				PV05->(dbCloseArea())
				Ferase(P5Index+GetDBExtension())
				Ferase(P5Index+OrdBagExt())

				DT001 := Alltrim(" DROP TABLE " + msNmTMPII + "                                                                            ") + msrhEnter
				U_BIAMsgRun("Aguarde... Limpa ##TEMP...",,{|| TcSQLExec(DT001)})				

				//        Os índices seguintes, em sua maioria, são dependentes do salário para serem calculados
				//***********************************************************************************************
				msPericul := msSalario * MQ07->ZBA_PPERIC
				msInsalub := MQ07->ZBA_INSALU
				msHorProg := 0
				msDSRProg := 0
				msAdcNotr := 0
				If MQ07->ZBA_MESFER <> StrZero(mxFx,2)
					msHorProg := ( msSalario + msPericul + msInsalub ) / 220 * 2.0 * MQ07->ZBA_QTHEPR * &("RF04->M" + StrZero(mxFx,2))
					msDSRProg := msHorProg / 25 * 5
					msAdcNotr := ( msSalario + msPericul + msInsalub ) / 220 * 0.2 * MQ07->ZBA_QHADNO
				EndIf
				msPremPrd := MQ07->ZBA_PREMPR

				//                                                                              Remuneração Total
				//***********************************************************************************************
				msRemunerTot := msSalario + msPericul + msInsalub
				msRemunerTot += msHorProg + msDSRProg + msAdcNotr + msPremPrd

				//msSalarioAdc := msSalario + msPericul + msInsalub + msPremPrd
				msSalarioAdc := msSalario + msPremPrd

				//                                                                Tratamento para Vale Transporte
				//***********************************************************************************************
				msVlrVT := 0
				If MQ07->ZBA_CATGFU == "035"
					msVlrVT := MQ07->ZBA_VVLTRT
				Else
					msVlrVT := (MQ07->ZBA_QVLTRT * MQ07->ZBA_VVTUNI ) - (msSalario * MQ07->ZBA_PRCAVT /100)
					If msVlrVT < 0
						msVlrVT := 0 
					EndIf
				EndIf

				//                                                               Provisão de INSS/FGTS/Senai/Sesi
				//***********************************************************************************************
				msFolINSS     := msRemunerTot * MQ07->ZBA_PRCINS / 100
				msFolFGTS     := msRemunerTot * MQ07->ZBA_PRCFGT / 100
				msFolSenai    := msRemunerTot * MQ07->ZBA_PRCSEN / 100
				msFolSesi     := msRemunerTot * MQ07->ZBA_PRCSES / 100

				//                                        Férias / Abono de Férias /Reflexos INSS/FGTS/Senai/Sesi
				//***********************************************************************************************
				msAdcSaldFer  := 0
				msProvFerias  := ( ( MQ07->ZBA_FMULTF * ( msRemunerTot + ( msRemunerTot / 3 ) ) / 12 ) * mxFx ) - msFerAculVlProv
				msSalFerPAnt  := IIF(Substr(MQ07->ZBA_MATR,1,4) <> "NOVO", MQ07->ZBA_SALFER, 0)
				If mxFx == 5
					msAdcSaldFer  := msSalFerPAnt * PV04->ZBG_SALARI / 100 * 1.33333333
					msProvFerias  += msAdcSaldFer 
				EndIf
				msAbonoFerias := MQ07->ZBA_FMULTF * 0
				msPrvFerINSS  := MQ07->ZBA_FMULTF * msProvFerias * MQ07->ZBA_PRCINS / 100
				msPrvFerFGTS  := MQ07->ZBA_FMULTF * msProvFerias * MQ07->ZBA_PRCFGT / 100
				msPrvFerSENAI := MQ07->ZBA_FMULTF * msProvFerias * MQ07->ZBA_PRCSEN / 100
				msPrvFerSESI  := MQ07->ZBA_FMULTF * msProvFerias * MQ07->ZBA_PRCSES / 100
				msFerAculVlProv += msProvFerias - msAdcSaldFer

				//                                                 Decimo Terceiro /Reflexos INSS/FGTS/Senai/Sesi
				//***********************************************************************************************
				msPrv13       := ( ( MQ07->ZBA_FMUL13 * msRemunerTot / 12 ) * mxFx ) - ms13oAculVlProv
				msPrv13INSS   := MQ07->ZBA_FMUL13 * msPrv13 * MQ07->ZBA_PRCINS / 100
				msPrv13FGTS   := MQ07->ZBA_FMUL13 * msPrv13 * MQ07->ZBA_PRCFGT / 100
				msPrv13SENAI  := MQ07->ZBA_FMUL13 * msPrv13 * MQ07->ZBA_PRCSEN / 100
				msPrv13SESI   := MQ07->ZBA_FMUL13 * msPrv13 * MQ07->ZBA_PRCSES / 100
				ms13oAculVlProv += msPrv13

				//                                                                           Demissões e Reflexos
				//***********************************************************************************************
				msDsAvs  := 0
				msVrAvs  := 0
				msFerAvs := 0
				msFerFgA := 0
				ms13oAvs := 0
				ms13oInA := 0
				ms13oFgA := 0
				ms13oSnA := 0
				ms13oSsA := 0
				msVrMult := 0
				If !Empty(MQ07->ZBA_MESDEM) .and. MQ07->ZBA_MESDEM == StrZero(mxFx,2)

					msDsAvs  := 30 + (MQ07->ZBA_TMPCAS * 3)
					If msDsAvs > 60
						msDsAvs  := 60
					EndIf
					msVrAvs  := msRemunerTot / 30 * msDsAvs
					msFerAvs := MQ07->ZBA_FMULTF * ( ( msRemunerTot + ( msRemunerTot / 3) ) / 12 ) + (msSalFerPAnt / 3)
					msFerFgA := MQ07->ZBA_FMULTF * msVrAvs * MQ07->ZBA_PRCFGT / 100
					ms13oAvs := MQ07->ZBA_FMUL13 * msRemunerTot / 12
					ms13oInA := MQ07->ZBA_FMUL13 * ms13oAvs * MQ07->ZBA_PRCINS / 100
					ms13oFgA := MQ07->ZBA_FMUL13 * ms13oAvs * MQ07->ZBA_PRCFGT / 100
					ms13oSnA := MQ07->ZBA_FMUL13 * ms13oAvs * MQ07->ZBA_PRCSEN / 100
					ms13oSsA := MQ07->ZBA_FMUL13 * ms13oAvs * MQ07->ZBA_PRCSES / 100
					msVrMult := ( ( msRemunerTot * 8 / 100 ) * MQ07->ZBA_TMPCAS * 12 ) * 50 / 100

				EndIf

				If ( Substr(MQ07->ZBA_MATR,1,4) == "NOVO" .and. StrZero(mxFx,2) >= MQ07->ZBA_MADMNW ) .or. ( Substr(MQ07->ZBA_MATR,1,4) <> "NOVO" .and. ( StrZero(mxFx,2) <= MQ07->ZBA_MESDEM .or. Empty(MQ07->ZBA_MESDEM) ) )

					Reclock("ZBG",.T.)
					ZBG->ZBG_FILIAL  := xFilial("ZBG")
					ZBG->ZBG_SEQUEN	 :=	_cSequen	
					ZBG->ZBG_VERSAO  := _cVersao
					ZBG->ZBG_REVISA  := _cRevisa
					ZBG->ZBG_ANOREF  := _cAnoRef
					ZBG->ZBG_PERIOD  := StrZero(mxFx,2)
					ZBG->ZBG_CLVL    := MQ07->ZBA_CLVL
					ZBG->ZBG_MATR    := MQ07->ZBA_MATR
					ZBG->ZBG_NOME    := MQ07->ZBA_NOME
					ZBG->ZBG_SEMELH  := MQ07->ZBA_SEMELH
					ZBG->ZBG_IDADET  := MQ07->ZBA_IDADET
					ZBG->ZBG_TNOTRA  := MQ07->ZBA_TNOTRA
					ZBG->ZBG_FUNCAO  := MQ07->ZBA_FUNCAO
					ZBG->ZBG_MESANI  := MQ07->ZBA_MESANI
					ZBG->ZBG_MESADM  := MQ07->ZBA_MESADM
					ZBG->ZBG_MADMNW  := MQ07->ZBA_MADMNW
					ZBG->ZBG_DMTDAA  := MQ07->ZBA_DMTDAA
					ZBG->ZBG_MESDEM  := MQ07->ZBA_MESDEM
					ZBG->ZBG_SEMAIL  := MQ07->ZBA_SEMAIL
					ZBG->ZBG_CATGFU  := MQ07->ZBA_CATGFU

					If MQ07->ZBA_MESFER <> StrZero(mxFx,2) .or. MQ07->ZBA_FMULTF == 0
						ZBG->ZBG_SALARI  := msSalario
						ZBG->ZBG_PPERIC  := MQ07->ZBA_PPERIC
						ZBG->ZBG_PERICU  := msPericul
						ZBG->ZBG_PINSAL  := MQ07->ZBA_PINSAL
						ZBG->ZBG_INSALU  := msInsalub
						ZBG->ZBG_QTHEPR  := MQ07->ZBA_QTHEPR* &("RF04->M" + StrZero(mxFx,2))
						ZBG->ZBG_VHEPRG  := msHorProg
						ZBG->ZBG_DSRPRG  := msDSRProg
						ZBG->ZBG_QHADNO  := MQ07->ZBA_QHADNO
						ZBG->ZBG_VADCNO  := msAdcNotr
					EndIf

					ZBG->ZBG_PREMPR  := msPremPrd

					ZBG->ZBG_TXINST  := MQ07->ZBA_TXINST
					ZBG->ZBG_QVLTRT  := MQ07->ZBA_QVLTRT
					ZBG->ZBG_VVTUNI  := MQ07->ZBA_VVTUNI
					ZBG->ZBG_PRCAVT  := MQ07->ZBA_PRCAVT
					If MQ07->ZBA_MESFER <> StrZero(mxFx,2) .or. MQ07->ZBA_FMULTF == 0
						ZBG->ZBG_VVLTRT  := msVlrVT
						ZBG->ZBG_REFEIC  := MQ07->ZBA_REFEIC
						ZBG->ZBG_DESEJU  := MQ07->ZBA_DESEJU
					EndIf
					ZBG->ZBG_CALIME  := MQ07->ZBA_CALIME + ( MQ07->ZBA_CALIME * PV04->ZBG_CALIME / 100 )
					If MQ07->ZBA_MESFER <> StrZero(mxFx,2)
						ZBG->ZBG_CJTURN  := MQ07->ZBA_CJTURN + ( MQ07->ZBA_CJTURN * PV04->ZBG_CJTURN / 100 )
						ZBG->ZBG_CJNOIT  := MQ07->ZBA_CJNOIT + ( MQ07->ZBA_CJNOIT * PV04->ZBG_CJNOIT / 100 )
					EndIf
					ZBG->ZBG_CCOMBU  := MQ07->ZBA_CCOMBU + ( MQ07->ZBA_CCOMBU * PV04->ZBG_CCOMBU / 100 )
					ZBG->ZBG_AJDCBD  := MQ07->ZBA_AJDCBD

					If Substr(MQ07->ZBA_MATR,1,4) == "NOVO" .and. !msGravouCfccCh

						ZBG->ZBG_CFCCCH  := zmCfccCh
						msGravouCfccCh   := .T.

					EndIf

					If bnMEDICA <> 0
						ZBG->ZBG_PLSMED  := bnMEDICA + ( bnMEDICA * PV04->ZBG_PLSMED / 100 )
					Else
						ZBG->ZBG_PLSMED  := MQ07->ZBA_PLSMED + ( MQ07->ZBA_PLSMED * PV04->ZBG_PLSMED / 100 )
					EndIf
					If bnODONTO <> 0
						ZBG->ZBG_PLSODO  := bnODONTO + ( bnODONTO * PV04->ZBG_PLSODO / 100 )
					Else
						ZBG->ZBG_PLSODO  := MQ07->ZBA_PLSODO + ( MQ07->ZBA_PLSODO * PV04->ZBG_PLSODO / 100 )
					EndIf

					If ( Substr(MQ07->ZBA_MATR,1,4) == "NOVO" .and. StrZero(mxFx,2) == MQ07->ZBA_MADMNW ) .or. ( Substr(MQ07->ZBA_MATR,1,4) <> "NOVO" .and. StrZero(mxFx,2) == MQ07->ZBA_MESANI ) .or. ( MQ07->ZBA_MESDEM == StrZero(mxFx,2 ) )
						ZBG->ZBG_VLREXA  := MQ07->ZBA_VLREXA
					EndIf
					//If MQ07->ZBA_RTUNIF == "1" // Corrigido em 19/10/18 conforme alinhado com Claudia e Diego
					If StrZero(mxFx,2) == MQ07->ZBA_MESADM .or. StrZero(mxFx,2) == MQ07->ZBA_MADMNW
						ZBG->ZBG_VLRUNI  := MQ07->ZBA_VLRUNI
					EndIf
					//Else
					//	ZBG->ZBG_VLRUNI  := MQ07->ZBA_VLRUNI
					//EndIf
					ZBG->ZBG_VLREPI  := MQ07->ZBA_VLREPI / 12 // Corrigido em 19/10/18 conforme alinhado com Claudia e Diego 

					If MQ07->ZBA_MESFER <> StrZero(mxFx,2) .or. MQ07->ZBA_FMULTF == 0
						ZBG->ZBG_PRCINS  := MQ07->ZBA_PRCINS
						ZBG->ZBG_PRCFGT  := MQ07->ZBA_PRCFGT
						ZBG->ZBG_PRCSEN  := MQ07->ZBA_PRCSEN
						ZBG->ZBG_PRCSES  := MQ07->ZBA_PRCSES
						ZBG->ZBG_VRINSF  := msFolINSS
						ZBG->ZBG_VRFGTF  := msFolFGTS
						ZBG->ZBG_VRSENF  := msFolSenai
						ZBG->ZBG_VRSESF  := msFolSesi
					EndIf

					ZBG->ZBG_FERIAS  := msProvFerias
					ZBG->ZBG_ABONOF  := msAbonoFerias
					ZBG->ZBG_INSFER  := msPrvFerINSS
					ZBG->ZBG_FGTFER  := msPrvFerFGTS
					ZBG->ZBG_SENFER  := msPrvFerSENAI
					ZBG->ZBG_SESFER  := msPrvFerSESI
					ZBG->ZBG_13OSAL  := msPrv13
					ZBG->ZBG_INS13O  := msPrv13INSS
					ZBG->ZBG_FGT13O  := msPrv13FGTS
					ZBG->ZBG_SEN13O  := msPrvFerSENAI
					ZBG->ZBG_SES13O  := msPrvFerSESI

					ZBG->ZBG_QSLPPR  := MQ07->ZBA_QSLPPR
					ZBG->ZBG_VLRPPR  := MQ07->ZBA_QSLPPR * msSalarioAdc * 80 / 100
					ZBG->ZBG_FMULTF  := MQ07->ZBA_FMULTF
					ZBG->ZBG_FMUL13  := MQ07->ZBA_FMUL13
					ZBG->ZBG_BNADC   := MQ07->ZBA_BNADC
					ZBG->ZBG_TMPCAS  := MQ07->ZBA_TMPCAS

					ZBG->ZBG_SALFER  := msSalFerPAnt 
					ZBG->ZBG_DAVISO  := msDsAvs 
					ZBG->ZBG_VRAVIS  := msVrAvs 
					ZBG->ZBG_FERAVI  := msFerAvs
					ZBG->ZBG_FGTAVI  := msFerFgA
					ZBG->ZBG_13OAVI  := ms13oAvs
					ZBG->ZBG_13FGTA  := ms13oFgA
					ZBG->ZBG_13INSA  := ms13oInA
					ZBG->ZBG_13SENA  := ms13oSnA
					ZBG->ZBG_13SESA  := ms13oSsA
					ZBG->ZBG_MULTAF  := msVrMult

					// Diferenciação necessária para direcionamento da contabilização
					If MQ07->ZBA_MESFER <> StrZero(mxFx,2) .or. MQ07->ZBA_FMULTF == 0
						If MQ07->ZBA_CATGFU == "005"
							ZBG->ZBG_HONORA  := msSalario
						ElseIf MQ07->ZBA_CATGFU == "020"
							ZBG->ZBG_BOLSAE  := msSalario
						Else
							ZBG->ZBG_SALMEN  := msSalario
						EndIf
					EndIf

					ZBG->ZBG_DPRVFR  := stod(MQ07->ZBA_DPRVFR)
					ZBG->ZBG_MESFER  := MQ07->ZBA_MESFER
					ZBG->ZBG_CSTFUN  := &(msCustFun)

					ZBG->(MsUnlock())

					If StrZero(mxFx,2) == "12" .or. ( !Empty(MQ07->ZBA_MESDEM) .and. MQ07->ZBA_MESDEM == StrZero(mxFx,2) )

						msPPRrecalc := MQ07->ZBA_QSLPPR * msSalarioAdc * 80 / 100 / 12
						//                                                       Recalcula PPR para todos os meses do ano
						//***********************************************************************************************
						UL009 := " UPDATE " + RetSqlName("ZBG") + " SET ZBG_VLRPPR = " + Alltrim(Str(msPPRrecalc))
						UL009 += "   FROM " + RetSqlName("ZBG") + " ZBG "
						UL009 += "  WHERE ZBG.ZBG_FILIAL = '" + xFilial("ZBG") + "' "
						UL009 += "    AND ZBG.ZBG_VERSAO = '" + _cVersao + "' "
						UL009 += "    AND ZBG.ZBG_REVISA = '" + _cRevisa + "' "
						UL009 += "    AND ZBG.ZBG_ANOREF = '" + _cAnoRef + "' "
						UL009 += "    AND ZBG.ZBG_SEQUEN = '" + _cSequen + "' "
						UL009 += "    AND ZBG.ZBG_PERIOD <> '00' "
						UL009 += "    AND ZBG.ZBG_MATR = '" + MQ07->ZBA_MATR + "' "
						UL009 += "    AND ZBG.ZBG_CLVL = '" + MQ07->ZBA_CLVL + "' "
						UL009 += "    AND ZBG.ZBG_SEMELH = '" + MQ07->ZBA_SEMELH + "' "
						UL009 += "    AND ZBG.ZBG_BNADC LIKE '%010%' "
						UL009 += "    AND ZBG.D_E_L_E_T_ = ' ' "					
						U_BIAMsgRun("Aguarde... Atualizando PPR Anual... ",,{|| TcSQLExec(UL009) })

					EndIf

				Else

					// Necessário verificar quais verbas serão calculadas no mes de rescisão 

				EndIf

				PV04->(dbCloseArea())
				Ferase(PVIndex+GetDBExtension())
				Ferase(PVIndex+OrdBagExt())

			Next mxFx

			MP02->(dbCloseArea())
			Ferase(MPIndex+GetDBExtension())
			Ferase(MPIndex+OrdBagExt())

			MQ07->(dbSkip())

		End

	EndIf	

	MQ07->(dbCloseArea())
	Ferase(MQIndex+GetDBExtension())
	Ferase(MQIndex+OrdBagExt())

	RF04->(dbCloseArea())
	Ferase(RFIndex+GetDBExtension())
	Ferase(RFIndex+OrdBagExt())

	UL017 := " UPDATE " + RetSqlName("ZBG") + " SET ZBG_CSTFUN = " + qyCustFun
	UL017 += "   FROM " + RetSqlName("ZBG") + " ZBG "
	UL017 += "  WHERE ZBG.ZBG_FILIAL = '" + xFilial("ZBG") + "' "
	UL017 += "    AND ZBG.ZBG_VERSAO = '" + _cVersao + "' "
	UL017 += "    AND ZBG.ZBG_REVISA = '" + _cRevisa + "' "
	UL017 += "    AND ZBG.ZBG_ANOREF = '" + _cAnoRef + "' "
	UL017 += "    AND ZBG.ZBG_SEQUEN = '" + _cSequen + "' "
	UL017 += "    AND ZBG.ZBG_PERIOD <> '00' "
	UL017 += "    AND ZBG.D_E_L_E_T_ = ' ' "					
	U_BIAMsgRun("Aguarde... Atualizando Custo Total por Funcionário... ",,{|| TcSQLExec(UL017) })

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
	aAdd(aRegs,{cPerg,"01","Versão Orçamentária      ?","","","mv_ch1","C",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"02","Revisão Ativa            ?","","","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Ano de Referência        ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
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

Static Function fGetSeq()

	Local _cAlias	:=	GetNextAlias()
	Local _cSeq


	BeginSql Alias _cAlias

		SELECT ISNULL(MAX(ZBG_SEQUEN),'000000') SEQ
		FROM %TABLE:ZBG% ZBG
		WHERE ZBG.ZBG_FILIAL = %XFILIAL:ZBG%	
		AND ZBG.ZBG_VERSAO = %Exp:_cVersao%
		AND ZBG.ZBG_REVISA = %Exp:_cRevisa%
		AND ZBG.ZBG_ANOREF = %Exp:_cAnoRef%
		AND ZBG.%NotDel%
	EndSql

	_cSeq	:=	Soma1((_cAlias)->SEQ)

	(_cAlias)->(DbCloseArea())

Return _cSeq
