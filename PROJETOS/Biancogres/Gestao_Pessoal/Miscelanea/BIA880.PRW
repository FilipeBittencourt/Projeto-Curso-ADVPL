#include "rwmake.ch"

/*/{Protheus.doc} BIA880
@author Marcos Alberto Soprani
@since 17/09/20
@version 1.1
@description Tela de cadastro de Premissas Cadastrais Func. para orçamento  
@type function
/*/                                                                                               

User Function BIA880()

	Private aRotina   := {}
	Private cCadastro := "Premissas Cadastrais Func."
	Private cAlias    := "ZO0"
	Private msrhEnter := CHR(13) + CHR(10)

	aAdd(aRotina, {"Pesquisar"       , "PesqBrw"   , 0, 1})
	aAdd(aRotina, {"Visualizar"      , "AxVisual"  , 0, 2})
	aAdd(aRotina, {"Incluir"         , "AxInclui"  , 0, 3})
	aAdd(aRotina, {"Alterar"         , "AxAltera"  , 0, 4})
	aAdd(aRotina, {"Excluir"         , "AxDeleta"  , 0, 5})
	aAdd(aRotina, {"Premissas Func"  , "U_BIA880A" , 0, 3})
	aAdd(aRotina, {"Atrib Benef"     , "U_BIA880B" , 0, 7})

	DbSelectArea(cAlias)
	DbSetOrder(1)

	mBrowse(,,,,cAlias)

Return()

User Function BIA880A()

	Local M001        := GetNextAlias()

	fPerg := "BIA880"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cVersao   := MV_PAR01   
	_cRevisa   := MV_PAR02
	_cAnoRef   := MV_PAR03
	_cDataRef  := MV_PAR04

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!", "Atenção!!!")
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
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!", "Atenção!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	Processa({ || cMsg := fBIA880A() }, "Aguarde...", "Carregando dados...",.F.)

Return

Static Function fBIA880A()

	Local msStaExcQy    := 0
	Local lOk           := .T.

	Local msNumEmp    := Alltrim(Str(VAL(cEmpAnt)))
	Local msCodFil    := Alltrim(Str(VAL(cFilAnt)))
	Local msDatRef    := dtos(_cDataRef)
	Local msPrcAnt    := 0
	Local msCfgPrc    := .T.

	msDatRef := Substr(msDatRef, 1, 4) + "-" + Substr(msDatRef, 5, 2) + "-" + Substr(msDatRef, 7, 2)

	CS003 := Alltrim(" SELECT COUNT(*) CONTAD                                           ") + msrhEnter
	CS003 += Alltrim(" FROM " + RetSqlName("ZO0") + " ZO0(NOLOCK)                       ") + msrhEnter
	CS003 += Alltrim(" WHERE ZO0_FILIAL = '" + xFilial("ZO0") + "'                      ") + msrhEnter
	CS003 += Alltrim("       AND ZO0_VERSAO = '" + _cVersao + "'                        ") + msrhEnter
	CS003 += Alltrim("       AND ZO0_REVISA = '" + _cRevisa + "'                        ") + msrhEnter
	CS003 += Alltrim("       AND ZO0_ANOREF = '" + _cAnoRef + "'                        ") + msrhEnter
	CS003 += Alltrim("       AND D_E_L_E_T_ = ' '                                       ") + msrhEnter	
	CScIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,CS003),'CS03',.F.,.T.)
	dbSelectArea("CS03")
	dbGoTop()
	msPrcAnt := CS03->CONTAD
	CS03->(dbCloseArea())
	Ferase(CScIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(CScIndex+OrdBagExt())          //indice gerado

	If msPrcAnt > 0
		msCfgPrc := MsgNOYES("Encontrados registros para a versão orçamentária informada." + msrhEnter + msrhEnter + "Caso confirme, os registros serão deletados e inseridos novamente." + msrhEnter + msrhEnter + "É provável que sejam perdidas informações impoertantes", "Atenção!!!")
	EndIf

	If msCfgPrc 

		Begin Transaction

			msDelTb := " DELETE A "
			msDelTb += "   FROM " + RetSqlName("ZO0") + " A "
			msDelTb += "  WHERE ZO0_FILIAL = '" + xFilial("ZO0") + "' "
			msDelTb += "    AND ZO0_VERSAO = '" + _cVersao + "' "
			msDelTb += "    AND ZO0_REVISA = '" + _cRevisa + "' "
			msDelTb += "    AND ZO0_ANOREF = '" + _cAnoRef + "' "
			msDelTb += "    AND D_E_L_E_T_ = ' ' "
			U_BIAMsgRun("Aguarde... Apagando registros ZO0... ",,{|| msStaExcQy := TcSQLExec(msDelTb) })
			If msStaExcQy < 0
				lOk := .F.
			EndIf

			If lOk

				TG003 := Alltrim(" WITH RELFUNC                                                                                              ") + msrhEnter
				TG003 += Alltrim("      AS (SELECT a.tipcol TIPCOL,                                                                          ") + msrhEnter
				TG003 += Alltrim("                 a.numemp NUMEMP,                                                                          ") + msrhEnter
				TG003 += Alltrim("                 e.codfil CODFIL,                                                                          ") + msrhEnter
				TG003 += Alltrim("                 a.numcad NUMCAD,                                                                          ") + msrhEnter
				TG003 += Alltrim("                 a.codccu CODCCU,                                                                          ") + msrhEnter
				TG003 += Alltrim("                 CTGFUN = CASE                                                                             ") + msrhEnter
				TG003 += Alltrim("                              WHEN deffis <> 'S'                                                           ") + msrhEnter
				TG003 += Alltrim("                                   AND catsef = 11                                                         ") + msrhEnter
				TG003 += Alltrim("                                   AND cateso = 723  -- Prolabore - OK                                     ") + msrhEnter
				TG003 += Alltrim("                              THEN '005'                                                                   ") + msrhEnter
				TG003 += Alltrim("                              WHEN deffis <> 'S'                                                           ") + msrhEnter
				TG003 += Alltrim("                                   AND catsef = 7                                                          ") + msrhEnter
				TG003 += Alltrim("                                   AND cateso = 103  -- Menor Interno +-                                   ") + msrhEnter
				TG003 += Alltrim("                              THEN '010'                                                                   ") + msrhEnter
				TG003 += Alltrim("                              WHEN deffis <> 'S'                                                           ") + msrhEnter
				TG003 += Alltrim("                                   AND catsef = 99                                                         ") + msrhEnter
				TG003 += Alltrim("                                   AND cateso = 999  -- Menor externo                                      ") + msrhEnter
				TG003 += Alltrim("                              THEN '015'                                                                   ") + msrhEnter
				TG003 += Alltrim("                              WHEN deffis <> 'S'                                                           ") + msrhEnter
				TG003 += Alltrim("                                   AND catsef = 1                                                          ") + msrhEnter
				TG003 += Alltrim("                                   AND cateso = 901  -- Estagiário - OK                                    ") + msrhEnter
				TG003 += Alltrim("                              THEN '020'                                                                   ") + msrhEnter
				TG003 += Alltrim("                              WHEN deffis <> 'S'                                                           ") + msrhEnter
				TG003 += Alltrim("                                   AND catsef = 1                                                          ") + msrhEnter
				TG003 += Alltrim("                                   AND cateso = 101                                                        ") + msrhEnter
				TG003 += Alltrim("                                   AND (t.apoesp <> 25                                                     ") + msrhEnter
				TG003 += Alltrim("                                        OR t.apoesp IS NULL)                                               ") + msrhEnter
				TG003 += Alltrim("                                   AND a.codccu <> 2155  -- Mensalistas +-                                 ") + msrhEnter
				TG003 += Alltrim("                              THEN '025'                                                                   ") + msrhEnter
				TG003 += Alltrim("                              WHEN deffis <> 'S'                                                           ") + msrhEnter
				TG003 += Alltrim("                                   AND catsef = 1                                                          ") + msrhEnter
				TG003 += Alltrim("                                   AND cateso = 101                                                        ") + msrhEnter
				TG003 += Alltrim("                                   AND t.apoesp = 25                                                       ") + msrhEnter
				TG003 += Alltrim("                                   AND a.codccu <> 2155  -- Mens. Aposentadoria Especial                   ") + msrhEnter
				TG003 += Alltrim("                              THEN '030'                                                                   ") + msrhEnter
				TG003 += Alltrim("                              WHEN deffis <> 'S'                                                           ") + msrhEnter
				TG003 += Alltrim("                                   AND catsef = 1                                                          ") + msrhEnter
				TG003 += Alltrim("                                   AND cateso = 101                                                        ") + msrhEnter
				TG003 += Alltrim("                                   AND a.codccu = 2155  -- Promotoras - OK                                 ") + msrhEnter
				TG003 += Alltrim("                              THEN '035'                                                                   ") + msrhEnter
				TG003 += Alltrim("                              WHEN deffis = 'S'                                                            ") + msrhEnter
				TG003 += Alltrim("                                   AND catsef = 1                                                          ") + msrhEnter
				TG003 += Alltrim("                                   AND (t.apoesp <> 25                                                     ") + msrhEnter
				TG003 += Alltrim("                                        OR t.apoesp IS NULL)                                               ") + msrhEnter
				TG003 += Alltrim("                                   AND cateso = 101  -- PCD Interno +-                                     ") + msrhEnter
				TG003 += Alltrim("                              THEN '040'                                                                   ") + msrhEnter
				TG003 += Alltrim("                              WHEN deffis = 'S'                                                            ") + msrhEnter
				TG003 += Alltrim("                                   AND catsef = 1                                                          ") + msrhEnter
				TG003 += Alltrim("                                   AND (t.apoesp <> 25                                                     ") + msrhEnter
				TG003 += Alltrim("                                        OR t.apoesp IS NULL)                                               ") + msrhEnter
				TG003 += Alltrim("                                   AND cateso = 999  -- PCD Externo                                        ") + msrhEnter
				TG003 += Alltrim("                              THEN '045'                                                                   ") + msrhEnter
				TG003 += Alltrim("                              WHEN deffis = 'S'                                                            ") + msrhEnter
				TG003 += Alltrim("                                   AND catsef = 1                                                          ") + msrhEnter
				TG003 += Alltrim("                                   AND t.apoesp = 25                                                       ") + msrhEnter
				TG003 += Alltrim("                                   AND cateso = 101  -- PCD Aposentadoria Especial                         ") + msrhEnter
				TG003 += Alltrim("                              THEN '050'                                                                   ") + msrhEnter
				TG003 += Alltrim("                              WHEN deffis <> 'S'                                                           ") + msrhEnter
				TG003 += Alltrim("                                   AND catsef = 99                                                         ") + msrhEnter
				TG003 += Alltrim("                                   AND cateso = 999  -- SENAI Externo ???  (nao existe)                    ") + msrhEnter
				TG003 += Alltrim("                              THEN '???'                                                                   ") + msrhEnter
				TG003 += Alltrim("                              ELSE -- VERIFICAR                                                            ") + msrhEnter
				TG003 += Alltrim("                              '   '                                                                        ") + msrhEnter
				TG003 += Alltrim("                          END,                                                                             ") + msrhEnter
				TG003 += Alltrim("                 VALCOM = CASE                                                                             ") + msrhEnter
				TG003 += Alltrim("                              WHEN vlrval <> 0                                                             ") + msrhEnter
				TG003 += Alltrim("                              THEN 'S'                                                                     ") + msrhEnter
				TG003 += Alltrim("                              ELSE 'N'                                                                     ") + msrhEnter
				TG003 += Alltrim("                          END,                                                                             ") + msrhEnter
				TG003 += Alltrim("                 VALVTR = CASE                                                                             ") + msrhEnter
				TG003 += Alltrim("                              WHEN                                                                         ") + msrhEnter
				TG003 += Alltrim("          (                                                                                                ") + msrhEnter
				TG003 += Alltrim("              SELECT COUNT(*)                                                                              ") + msrhEnter
				TG003 += Alltrim("              FROM VETORH.DBO.r038evt h(NOLOCK)                                                            ") + msrhEnter
				TG003 += Alltrim("              WHERE h.numemp = a.numemp                                                                    ") + msrhEnter
				TG003 += Alltrim("                    AND h.tipcol = a.tipcol                                                                ") + msrhEnter
				TG003 += Alltrim("                    AND h.numcad = a.numcad                                                                ") + msrhEnter
				TG003 += Alltrim("                    AND (h.fimevt = '1900-12-31 00:00:00.000'                                              ") + msrhEnter
				TG003 += Alltrim("                         OR h.fimevt > '" + msDatRef + " 00:00:00.000')                                    ") + msrhEnter
				TG003 += Alltrim("          ) > 0                                                                                            ") + msrhEnter
				TG003 += Alltrim("                              THEN 'S'                                                                     ") + msrhEnter
				TG003 += Alltrim("                              ELSE 'N'                                                                     ") + msrhEnter
				TG003 += Alltrim("                          END,                                                                             ") + msrhEnter
				TG003 += Alltrim("                 TPJANT = CASE                                                                             ") + msrhEnter
				TG003 += Alltrim("                              WHEN c.claesc = 3                                                            ") + msrhEnter
				TG003 += Alltrim("                              THEN '1'                                                                     ") + msrhEnter
				TG003 += Alltrim("                              WHEN c.claesc = 4                                                            ") + msrhEnter
				TG003 += Alltrim("                              THEN '2'                                                                     ") + msrhEnter
				TG003 += Alltrim("                              ELSE ''                                                                      ") + msrhEnter
				TG003 += Alltrim("                          END,                                                                             ") + msrhEnter
				TG003 += Alltrim("                 DESJEJ = 'N',                                                                             ") + msrhEnter
				TG003 += Alltrim("                 CCARGO = a.codcar,                                                                        ") + msrhEnter
				TG003 += Alltrim("                 CODESC = CONVERT(VARCHAR, a.codesc),                                                      ") + msrhEnter
				TG003 += Alltrim("                 DATNAS = CONVERT(VARCHAR, a.datnas, 112),                                                 ") + msrhEnter
				TG003 += Alltrim("                 NOME = a.nomfun,                                                                          ") + msrhEnter
				TG003 += Alltrim("                 ADMISS = CONVERT(VARCHAR, a.datadm, 112),                                                 ") + msrhEnter
				TG003 += Alltrim("                 SEMAIL = v.EMASUP,                                                                        ") + msrhEnter
				TG003 += Alltrim("                 ADCPER = CASE                                                                             ") + msrhEnter
				TG003 += Alltrim("                             WHEN t.perper <> 0                                                            ") + msrhEnter
				TG003 += Alltrim("                              THEN '1'                                                                     ") + msrhEnter
				TG003 += Alltrim("                              ELSE '2'                                                                     ") + msrhEnter
				TG003 += Alltrim("                          END,                                                                             ") + msrhEnter
				TG003 += Alltrim("                 ADCINS = CASE                                                                             ") + msrhEnter
				TG003 += Alltrim("                              WHEN t.perins = 20                                                           ") + msrhEnter
				TG003 += Alltrim("                              THEN '3'                                                                     ") + msrhEnter
				TG003 += Alltrim("                              WHEN t.perins = 40                                                           ") + msrhEnter
				TG003 += Alltrim("                              THEN '4'                                                                     ") + msrhEnter
				TG003 += Alltrim("                              ELSE '1'                                                                     ") + msrhEnter
				TG003 += Alltrim("                           END,                                                                            ") + msrhEnter
				TG003 += Alltrim("                 DPTOSR = [dbo].[FNC_BI_GETDEPART](" + cEmpAnt + ", a.numcad, '" + dtos(MV_PAR04) + "')    ") + msrhEnter
				TG003 += Alltrim("          FROM VETORH.dbo.r034fun a(NOLOCK)                                                                ") + msrhEnter
				TG003 += Alltrim("               LEFT JOIN VW_BG_GESTOR_IMEDIATO v ON v.NUMEMP = a.numemp                                    ") + msrhEnter
				TG003 += Alltrim("                                                         AND v.TIPCOL = a.tipcol                           ") + msrhEnter
				TG003 += Alltrim("                                                         AND v.NUMCAD = a.numcad                           ") + msrhEnter
				TG003 += Alltrim("               LEFT JOIN VETORH.DBO.r162ass b(NOLOCK) ON b.numemp = a.numemp                               ") + msrhEnter
				TG003 += Alltrim("                                                         AND b.tipcol = a.tipcol                           ") + msrhEnter
				TG003 += Alltrim("                                                         AND b.numcad = a.numcad                           ") + msrhEnter
				TG003 += Alltrim("                                                         AND b.codval = 5                                  ") + msrhEnter
				TG003 += Alltrim("               LEFT JOIN VETORH.DBO.r006esc c(NOLOCK) ON c.codesc = a.codesc                               ") + msrhEnter
				TG003 += Alltrim("               LEFT JOIN VETORH.dbo.r017adi t ON t.estpos = a.estpos                                       ") + msrhEnter
				TG003 += Alltrim("                                                          AND t.postra = a.postra                          ") + msrhEnter
				TG003 += Alltrim("               INNER JOIN VETORH.dbo.r038hfi e(NOLOCK) ON e.numemp = a.numemp                              ") + msrhEnter
				TG003 += Alltrim("                                                          AND e.tipcol = a.tipcol                          ") + msrhEnter
				TG003 += Alltrim("                                                          AND e.numcad = a.numcad                          ") + msrhEnter
				TG003 += Alltrim("                                                          AND e.datalt =                                   ") + msrhEnter
				TG003 += Alltrim("          (                                                                                                ") + msrhEnter
				TG003 += Alltrim("              SELECT MAX(qq.datalt)                                                                        ") + msrhEnter
				TG003 += Alltrim("              FROM VETORH.dbo.r038hfi qq(NOLOCK)                                                           ") + msrhEnter
				TG003 += Alltrim("              WHERE qq.datalt < '" + msDatRef + "'                                                         ") + msrhEnter
				TG003 += Alltrim("                    AND qq.numemp = a.numemp                                                               ") + msrhEnter
				TG003 += Alltrim("                    AND qq.tipcol = a.tipcol                                                               ") + msrhEnter
				TG003 += Alltrim("                    AND qq.numcad = a.numcad                                                               ") + msrhEnter
				TG003 += Alltrim("          )                                                                                                ") + msrhEnter
				TG003 += Alltrim("          WHERE a.tipcol = 1                                                                               ") + msrhEnter
				TG003 += Alltrim("                AND a.numemp = " + msNumEmp + "                                                            ") + msrhEnter
				TG003 += Alltrim("                AND (a.sitafa <> 7                                                                         ") + msrhEnter
				TG003 += Alltrim("                     OR (a.sitafa = 7                                                                      ") + msrhEnter
				TG003 += Alltrim("                         AND a.datafa > '" + msDatRef + "')))                                              ") + msrhEnter
				TG003 += Alltrim("      SELECT *,                                                                                            ") + msrhEnter
				TG003 += Alltrim("             SALARIO =                                                                                     ") + msrhEnter
				TG003 += Alltrim("      (                                                                                                    ") + msrhEnter
				TG003 += Alltrim("          SELECT MAX(s.valsal)                                                                             ") + msrhEnter
				TG003 += Alltrim("          FROM VETORH.dbo.R038HSA s                                                                        ") + msrhEnter
				TG003 += Alltrim("          WHERE s.tipcol = A.TIPCOL                                                                        ") + msrhEnter
				TG003 += Alltrim("                AND s.numemp = A.NUMEMP                                                                    ") + msrhEnter
				TG003 += Alltrim("                AND s.numcad = A.NUMCAD                                                                    ") + msrhEnter
				TG003 += Alltrim("                AND s.datalt IN                                                                            ") + msrhEnter
				TG003 += Alltrim("          (                                                                                                ") + msrhEnter
				TG003 += Alltrim("              SELECT MAX(b.datalt)                                                                         ") + msrhEnter
				TG003 += Alltrim("              FROM VETORH.dbo.R038HSA b                                                                    ") + msrhEnter
				TG003 += Alltrim("              WHERE b.tipcol = s.tipcol                                                                    ") + msrhEnter
				TG003 += Alltrim("                    AND b.numemp = s.numemp                                                                ") + msrhEnter
				TG003 += Alltrim("                    AND b.numcad = s.numcad                                                                ") + msrhEnter
				TG003 += Alltrim("                    AND b.datalt <= '2020-09-30'                                                           ") + msrhEnter
				TG003 += Alltrim("          )                                                                                                ") + msrhEnter
				TG003 += Alltrim("      )                                                                                                    ") + msrhEnter
				TG003 += Alltrim("      FROM RELFUNC A                                                                                       ") + msrhEnter
				TG003 += Alltrim("      WHERE CODFIL = " + msCodFil + "                                                                      ") + msrhEnter
				TG003 += Alltrim("      ORDER BY TIPCOL,                                                                                     ") + msrhEnter
				TG003 += Alltrim("               NUMEMP,                                                                                     ") + msrhEnter
				TG003 += Alltrim("               CODFIL,                                                                                     ") + msrhEnter
				TG003 += Alltrim("               NUMCAD                                                                                      ") + msrhEnter
				TGcIndex := CriaTrab(Nil,.f.)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,TG003),'TG03',.F.,.T.)
				dbSelectArea("TG03")
				dbGoTop()
				ProcRegua(RecCount())
				While !Eof()

					IncProc("Processamento1")

					RecLock("ZO0",.T.)
					ZO0->ZO0_FILIAL := xFilial("ZO0") 
					ZO0->ZO0_VERSAO := _cVersao
					ZO0->ZO0_REVISA := _cRevisa
					ZO0->ZO0_ANOREF := _cAnoRef
					ZO0->ZO0_MAT    := StrZero(TG03->NUMCAD,6)
					ZO0->ZO0_CLVL   := TG03->CODCCU
					ZO0->ZO0_SALREF := TG03->SALARIO
					ZO0->ZO0_CTGFUN := TG03->CTGFUN
					ZO0->ZO0_VALCOM := TG03->VALCOM
					ZO0->ZO0_VALVTR := TG03->VALVTR
					ZO0->ZO0_TPJANT := TG03->TPJANT
					ZO0->ZO0_DESJEJ := TG03->DESJEJ
					ZO0->ZO0_CARGO  := TG03->CCARGO
					ZO0->ZO0_CODESC := TG03->CODESC
					ZO0->ZO0_DATNAS := stod(TG03->DATNAS)
					ZO0->ZO0_NOME   := TG03->NOME
					ZO0->ZO0_ADMISS := stod(TG03->ADMISS)
					ZO0->ZO0_SEMAIL := TG03->SEMAIL
					ZO0->ZO0_ADCPER := TG03->ADCPER
					ZO0->ZO0_ADCINS := TG03->ADCINS
					ZO0->ZO0_DPTOSR := TG03->DPTOSR
					MsUnLock()

					dbSelectArea("TG03")
					dbSkip()

				End

				TG03->(dbCloseArea())
				Ferase(TGcIndex+GetDBExtension())     //arquivo de trabalho
				Ferase(TGcIndex+OrdBagExt())          //indice gerado

			Else 

				msGravaErr := TCSQLError()
				DisarmTransaction()

			EndIf

		End Transaction

		If lOk

			MsgINFO("Processamento realizado com sucesso.", "")

		Else

			Aviso('Problema de Processamento', "Erro na execução do processamento: " + msrhEnter + msrhEnter + msrhEnter + msGravaErr + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo Cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )

		EndIf

	EndIf


Return

User Function BIA880B()

	Local M001        := GetNextAlias()

	fPerg := "BIA880"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	_cVersao   := MV_PAR01   
	_cRevisa   := MV_PAR02
	_cAnoRef   := MV_PAR03
	_cDataRef  := MV_PAR04

	If Empty(_cVersao) .or. Empty(_cRevisa) .or. Empty(_cAnoRef)
		MsgInfo("Favor verificar o preenchimento dos campos da capa do cadastro!!!", "Atenção!!!")
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
		MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!", "Atenção!!!")
		(M001)->(dbCloseArea())
		Return .F.
	EndIf	
	(M001)->(dbCloseArea())

	Processa({ || cMsg := fBIA880B() }, "Aguarde...", "Carregando dados...",.F.)

Return

Static Function fBIA880B()

	Local M002        := GetNextAlias()
	Local msChkErr    := .F.

	xfCompl := ""
	xfCompl += " Foram encontradas inconsistências no preenchimento" + msrhEnter
	xfCompl += "do campo Categoria do funcionário para as seguntes " + msrhEnter
	xfCompl += "matriculas: " + msrhEnter + msrhEnter

	BeginSql Alias M002

		SELECT ZO0_MAT MATRIC
		FROM %TABLE:ZO0% ZO0 
		WHERE ZO0_FILIAL = %xFilial:ZO0%
		AND ZO0_VERSAO = %Exp:_cVersao%
		AND ZO0_REVISA = %Exp:_cRevisa%
		AND ZO0_ANOREF = %Exp:_cAnoRef%
		AND ZO0_CTGFUN IN('   ', '???')
		AND ZO0.%NotDel%

	EndSql

	(M002)->(dbGoTop())
	While !(M002)->(Eof())
		xfCompl += (M002)->MATRIC + msrhEnter + msrhEnter 
		msChkErr    := .T.
		(M002)->(dbSkip())
	End	

	If msChkErr

		If !MsgYESNO(xfCompl + msrhEnter + msrhEnter + "Deseja prosseguir com o processamento?", "Problemas")
			(M002)->(dbCloseArea())
			Return .F.
		EndIf

	EndIf

	(M002)->(dbCloseArea())

	//                                                                  Desjejum
	//**************************************************************************
	UP001 := " UPDATE ZO0 "
	UP001 += "   SET "
	UP001 += "       ZO0_DESJEJ = CASE "
	UP001 += "                        WHEN ZO0.ZO0_CODESC IN(22, 47, 48, 55, 100, 179, 236, 246, 263) "
	UP001 += "                        THEN 'S' "
	UP001 += "                        ELSE 'N' "
	UP001 += "                    END "
	UP001 += " FROM " + RetSqlName("ZO0") + " ZO0 "
	UP001 += " WHERE ZO0_FILIAL = '" + xFilial("ZO0") + "' "
	UP001 += "       AND ZO0_VERSAO = '" + _cVersao + "' "
	UP001 += "       AND ZO0_REVISA = '" + _cRevisa + "' "
	UP001 += "       AND ZO0_ANOREF = '" + _cAnoRef + "' "
	UP001 += "       AND ZO0.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Preparando Bases [Desjejum]...",,{|| TcSQLExec(UP001)})	

	//                                                               Benef.Adic.
	//**************************************************************************
	UP003 := " UPDATE ZO0 "
	UP003 += "   SET "
	UP003 += "       ZO0_BNADC = ZBD_BNC002 + CASE "
	UP003 += "                                    WHEN ZO0_VALVTR = 'S' "
	UP003 += "                                    THEN ZBD_BNC005 "
	UP003 += "                                    ELSE '***' "
	UP003 += "                                END + ZBD_BNC010 + ZBD_BNCB05 + CASE "
	UP003 += "                                                                    WHEN ZO0_DESJEJ = 'S' "
	UP003 += "                                                                    THEN ZBD_BNCB10 "
	UP003 += "                                                                    ELSE '***' "
	UP003 += "                                                                END + ZBD_BNCB15 + CASE "
	UP003 += "                                                                                       WHEN ZO0_TPJANT = '2' "
	UP003 += "                                                                                       THEN ZBD_BNCB20 "
	UP003 += "                                                                                       ELSE '***' "
	UP003 += "                                                                                   END + CASE "
	UP003 += "                                                                                             WHEN ZO0_TPJANT = '1' "
	UP003 += "                                                                                             THEN ZBD_BNCB25 "
	UP003 += "                                                                                             ELSE '***' "
	UP003 += "                                                                                         END + CASE "
	UP003 += "                                                                                                   WHEN ZO0_VALCOM = 'S' "
	UP003 += "                                                                                                   THEN ZBD_BNCB30 "
	UP003 += "                                                                                                   ELSE '***' "
	UP003 += "                                                                                               END + ZBD_BNCB35 + ZBD_BNCC05 + ZBD_BNCC10 "
	UP003 += " FROM " + RetSqlName("ZO0") + " ZO0 "
	UP003 += "      INNER JOIN " + RetSqlName("ZBD") + " ZBD(NOLOCK) ON ZBD_VERSAO = ZO0_VERSAO "
	UP003 += "                                       AND ZBD_REVISA = ZO0_REVISA "
	UP003 += "                                       AND ZBD_ANOREF = ZO0_ANOREF "
	UP003 += "                                       AND ZBD_CATEGF = ZO0_CTGFUN "
	UP003 += "                                       AND ZBD.D_E_L_E_T_ = ' ' "
	UP003 += " WHERE ZO0_FILIAL = '" + xFilial("ZO0") + "' "
	UP003 += "       AND ZO0_VERSAO = '" + _cVersao + "' "
	UP003 += "       AND ZO0_REVISA = '" + _cRevisa + "' "
	UP003 += "       AND ZO0_ANOREF = '" + _cAnoRef + "' "
	UP003 += "       AND ZO0.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Preparando Bases [Benef.Adic.]...",,{|| TcSQLExec(UP003)})

	//                                                              Qtd. Sal.PPR
	//**************************************************************************
	UP004 := " UPDATE ZO0 "
	UP004 += "   SET "
	UP004 += "       ZO0_QSLPPR = CASE "
	// Diretores e Gerentes
	UP004 += "                        WHEN ZO0_BNADC LIKE '%010%' "
	UP004 += "                             AND c.codcar <> '8244' "
	UP004 += "                             AND (c.titcar LIKE 'DIR %' "
	UP004 += "                                  OR c.titcar LIKE 'DIR.%' "
	UP004 += "                                  OR c.titcar LIKE 'DIRETOR%' "
	UP004 += "                                  OR c.titcar LIKE 'GER %' "
	UP004 += "                                  OR c.titcar LIKE 'GER.%' "
	UP004 += "                                  OR c.titcar LIKE 'GERENTE%') "
	UP004 += "                        THEN 3 "
	// Mensalistas nao Promotores
	UP004 += "                        WHEN ZO0.ZO0_BNADC LIKE '%010%' "
	UP004 += "                             AND c.codcar <> '8244' "
	UP004 += "                        THEN 1 "
	// Promotores
	UP004 += "                        WHEN ZO0.ZO0_BNADC LIKE '%010%' "
	UP004 += "                             AND c.codcar = '8244' "
	UP004 += "                        THEN 1 "
	// Não habilitados
	UP004 += "                        ELSE 0 "
	UP004 += "                    END "
	UP004 += " FROM " + RetSqlName("ZO0") + " ZO0 "
	UP004 += "      INNER JOIN VETORH.dbo.r024car c ON c.codcar = CONVERT(NUMERIC, ZO0.ZO0_CARGO) "
	UP004 += " WHERE ZO0_FILIAL = '" + xFilial("ZO0") + "' "
	UP004 += "       AND ZO0_VERSAO = '" + _cVersao + "' "
	UP004 += "       AND ZO0_REVISA = '" + _cRevisa + "' "
	UP004 += "       AND ZO0_ANOREF = '" + _cAnoRef + "' "
	UP004 += "       AND ZO0.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Preparando Bases [Qtd. Sal.PPR]...",,{|| TcSQLExec(UP004)})

	//                                                               Qtd Vl.Tran
	//**************************************************************************
	UP005 := " UPDATE ZO0 "
	UP005 += "   SET "
	UP005 += "       ZO0_QVLTRT = CASE "
	UP005 += "                        WHEN ZO0_BNADC LIKE '%005%' "
	UP005 += "                             AND ZO0_CODESC IN(47) "
	UP005 += "                        THEN 30 "
	UP005 += "                        WHEN ZO0_BNADC LIKE '%005%' "
	UP005 += "                             AND ZO0_CODESC IN(48, 99) "
	UP005 += "                        THEN 36 "
	UP005 += "                        WHEN ZO0_BNADC LIKE '%005%' "
	UP005 += "                             AND ZO0_CODESC IN(1, 2, 3, 22, 24, 25, 29, 31, 43, 46, 56, 57, 62, 68, 75, 83, 100, 116, 129, 140, 151, 179, 196, 206, 208, 210, 211, 261, 263, 264, 265, 266, 267, 268) "
	UP005 += "                        THEN 42 "
	UP005 += "                        WHEN ZO0_BNADC LIKE '%005%' "
	UP005 += "                             AND ZO0_CODESC IN(11, 52, 55, 130, 236) "
	UP005 += "                        THEN 50 "
	UP005 += "                        WHEN ZO0_BNADC LIKE '%005%' "
	UP005 += "                             AND ZO0_CODESC IN(246, 247, 248) "
	UP005 += "                        THEN 48 "
	UP005 += "                        ELSE 0 "
	UP005 += "                    END "
	UP005 += " FROM " + RetSqlName("ZO0") + " ZO0 "
	UP005 += " WHERE ZO0_FILIAL = '" + xFilial("ZO0") + "' "
	UP005 += "       AND ZO0_VERSAO = '" + _cVersao + "' "
	UP005 += "       AND ZO0_REVISA = '" + _cRevisa + "' "
	UP005 += "       AND ZO0_ANOREF = '" + _cAnoRef + "' "
	UP005 += "       AND ZO0.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Preparando Bases [Qtd Vl.Tran]...",,{|| TcSQLExec(UP005)})

	//                                                              Qtd Refeição
	//**************************************************************************
	UP006 := " UPDATE ZO0 "
	UP006 += "   SET "
	UP006 += "       ZO0_QTREFC = CASE "
	UP006 += "                        WHEN ZO0_BNADC LIKE '%B05%' "
	UP006 += "                             AND ZO0_CODESC IN(3, 46, 116, 211, 247, 248, 267) "
	UP006 += "                        THEN 0 "
	UP006 += "                        WHEN ZO0_BNADC LIKE '%B05%' "
	UP006 += "                             AND ZO0_CODESC IN(130) "
	UP006 += "                        THEN 4 "
	UP006 += "                        WHEN ZO0_BNADC LIKE '%B05%' "
	UP006 += "                             AND ZO0_CODESC IN(62, 206) "
	UP006 += "                        THEN 12 "
	UP006 += "                        WHEN ZO0_BNADC LIKE '%B05%' "
	UP006 += "                             AND ZO0_CODESC IN(47, 48, 99) "
	UP006 += "                        THEN 15 "
	UP006 += "                        WHEN ZO0_BNADC LIKE '%B05%' "
	UP006 += "                             AND ZO0_CODESC IN(1, 2, 22, 24, 25, 29, 31, 43, 56, 57, 68, 75, 83, 100, 129, 140, 151, 179, 196, 208, 210, 261, 263, 264, 265, 266, 268) "
	UP006 += "                        THEN 22 "
	UP006 += "                        WHEN ZO0_BNADC LIKE '%B05%' "
	UP006 += "                             AND ZO0_CODESC IN(246) "
	UP006 += "                        THEN 23 "
	UP006 += "                        WHEN ZO0_BNADC LIKE '%B05%' "
	UP006 += "                             AND ZO0_CODESC IN(11, 52, 55, 236) "
	UP006 += "                        THEN 26 "
	UP006 += "                        ELSE 0 "
	UP006 += "                    END "
	UP006 += " FROM " + RetSqlName("ZO0") + " ZO0 "
	UP006 += " WHERE ZO0_FILIAL = '" + xFilial("ZO0") + "' "
	UP006 += "       AND ZO0_VERSAO = '" + _cVersao + "' "
	UP006 += "       AND ZO0_REVISA = '" + _cRevisa + "' "
	UP006 += "       AND ZO0_ANOREF = '" + _cAnoRef + "' "
	UP006 += "       AND ZO0.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Preparando Bases [Qtd Refeição]...",,{|| TcSQLExec(UP006)})

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
	aAdd(aRegs,{cPerg,"01","Versão Orçamentária         ?","","","mv_ch1","C",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","ZB5"})
	aAdd(aRegs,{cPerg,"02","Revisão Ativa               ?","","","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Ano de Referência           ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Data Referência para Foto   ?","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
