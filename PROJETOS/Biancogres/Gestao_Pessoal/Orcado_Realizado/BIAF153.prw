#include "rwmake.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF153
@author Tiago Rossini Coradini
@since 02/03/2020
@version 1.0
@description Funcao para Calculo de Rubricas de Custo Funcionario
@type class
/*/

User Function BIAF153()

	Private aRotina := {}
	Private cCadastro := "Calculo de Rubricas de Custo Funcionario"
	Private cAlias := "ZBO"

	aAdd(aRotina, {"Pesquisar"     , "PesqBrw"   , 0, 1})
	aAdd(aRotina, {"Visualizar"    , "AxVisual"  , 0, 2})
	aAdd(aRotina, {"Processar"     , "U_BIAF153A", 0, 3})
	aAdd(aRotina, {"FiltraEvento"  , "U_BIAF153F", 0, 4})
	aAdd(aRotina, {"Relatorio"     , "U_BIAF153B", 0, 5})

	DbSelectArea(cAlias)
	DbSetOrder(1)

	mBrowse(,,,,cAlias)

Return()

User Function BIAF153A()

	Local oParam        := TParBIAF153():New()

	Private msEnter     := CHR(13) + CHR(10)
	Private msTblTemp   := '##TMP_ARQ_BIAF153' + cEmpAnt + __cUserID + strzero(seconds()*3500,10)
	Private ms2TbTemp   := '##TMP_AR2_BIAF153' + cEmpAnt + __cUserID + strzero(seconds()*3500,10)
	Private ms3TbTemp   := '##TMP_AR3_BIAF153' + cEmpAnt + __cUserID + strzero(seconds()*3500,10)
	Private msVersao    := Space(10)
	Private msRevisa    := Space(03)
	Private msAnoRef    := Space(04)	
	Private msPeriod    := Space(02)
	Private msStaExcQy  := 0
	Private mslOk       := .T.
	Private msGravaErr  := ""
	Private msPivotCmp  := ""
	Private mskQry07

	If oParam:Box() .And. oParam:lConfirm

		FWMsgRun(, {|| fProcess(oParam) }, "Aguarde!", "Processando Custo de Funcionarios...")

	EndIf	

Return()

Static Function fProcess(oParam)

	Local oObj := Nil

	oObj := TCalculoRubricasCustoFuncionario():New()

	oObj:cVersao  := oParam:cVersao //"ORCA_" + SubStr(oParam:cAno, 3, 2)
	oObj:cRevisao := oParam:cRevisao
	oObj:cAno     := oParam:cAno	
	oObj:cPeriodo := oParam:cPeriodo
	msVersao      := oParam:cVersao
	msRevisa      := oParam:cRevisao
	msAnoref      := oParam:cAno	
	msPeriod      := oParam:cPeriodo

	oObj:Process()

	FreeObj(oObj)

	If msAnoref + msPeriod >= "202006"

		msScriptGr()
		If mslOk

			msChkAtrbR()
			If mslOk

				msCmpPivot()
				If mslOk

					msGrvEvent() 

				EndIf

			EndIf

		EndIf

		If !mslOk

			Aviso('Problema de Processamento', "Erro na execução do processamento: " + msEnter + msEnter + msEnter + msGravaErr + msEnter + msEnter + msEnter + msEnter + "Processo Cancelado!!!" + msEnter + msEnter + msEnter, {'Fecha'}, 3 )

		EndIf

	EndIf

Return()

User Function BIAF153B()

	Local oParam := TParBIAF153():New()

	If oParam:Box() .And. oParam:lConfirm

		FWMsgRun(, {|| fReport(oParam) }, "Aguarde!", "Processando Relatório de Custo de Funcionarios...")

	EndIf	

Return()

Static Function fReport(oParam)

	Local oObj := Nil

	oObj := TCalculoRubricasCustoFuncionario():New()

	oObj:cVersao := "ORCA_" + SubStr(oParam:cAno, 3, 2)
	oObj:cRevisao := oParam:cRevisao
	oObj:cAno := oParam:cAno	
	oObj:cPeriodo := oParam:cPeriodo

	oObj:Report()

	FreeObj(oObj)

Return()

Static Function msScriptGr()

	Begin Transaction

		TM004 := Alltrim(" WITH CUSTOFUNC                                                                                                        ") + msEnter
		TM004 += Alltrim("      AS (SELECT a.numemp,                                                                                             ") + msEnter
		TM004 += Alltrim("                 e.codfil,                                                                                             ") + msEnter
		TM004 += Alltrim("                 a.tipcol,                                                                                             ") + msEnter
		TM004 += Alltrim("                 a.numcad,                                                                                             ") + msEnter
		TM004 += Alltrim("                 a.codeve,                                                                                             ") + msEnter
		TM004 += Alltrim("                 mesano = EOMONTH(c.perref),                                                                           ") + msEnter
		TM004 += Alltrim("                 tabcus = 'FOL',                                                                                       ") + msEnter
		TM004 += Alltrim("                 b.tipeve,                                                                                             ") + msEnter
		TM004 += Alltrim("                 destpe = CASE                                                                                         ") + msEnter
		TM004 += Alltrim("                              WHEN b.tipeve = 1                                                                        ") + msEnter
		TM004 += Alltrim("                              THEN 'Proventos' + ' / ' + b.deseve                                                      ") + msEnter
		TM004 += Alltrim("                              WHEN b.tipeve = 2                                                                        ") + msEnter
		TM004 += Alltrim("                              THEN 'Vantagens' + ' / ' + b.deseve                                                      ") + msEnter
		TM004 += Alltrim("                              WHEN b.tipeve = 3                                                                        ") + msEnter
		TM004 += Alltrim("                              THEN 'Descontos' + ' / ' + b.deseve                                                      ") + msEnter
		TM004 += Alltrim("                              WHEN b.tipeve = 4                                                                        ") + msEnter
		TM004 += Alltrim("                              THEN 'Outros' + ' / ' + b.deseve                                                         ") + msEnter
		TM004 += Alltrim("                              WHEN b.tipeve = 5                                                                        ") + msEnter
		TM004 += Alltrim("                              THEN 'Outros Env Proventos' + ' / ' + b.deseve                                           ") + msEnter
		TM004 += Alltrim("                              WHEN b.tipeve = 6                                                                        ") + msEnter
		TM004 += Alltrim("                              THEN 'Outros Env Descontos' + ' / ' + b.deseve                                           ") + msEnter
		TM004 += Alltrim("                          END,                                                                                         ") + msEnter
		TM004 += Alltrim("                 insemp = 0,                                                                                           ") + msEnter
		TM004 += Alltrim("                 perter = 0,                                                                                           ") + msEnter
		TM004 += Alltrim("                 ratfap = 0,                                                                                           ") + msEnter
		TM004 += Alltrim("                 basins = 0,                                                                                           ") + msEnter
		TM004 += Alltrim("                 valor = CASE                                                                                          ") + msEnter
		TM004 += Alltrim("                             WHEN b.tipeve IN(1, 2, 4, 5)                                                              ") + msEnter
		TM004 += Alltrim("                             THEN a.valeve                                                                             ") + msEnter
		TM004 += Alltrim("                             ELSE a.valeve * (-1)                                                                      ") + msEnter
		TM004 += Alltrim("                         END                                                                                           ") + msEnter
		TM004 += Alltrim("          FROM VETORH.dbo.r046ver a(NOLOCK)                                                                            ") + msEnter
		TM004 += Alltrim("               INNER JOIN VETORH.dbo.r008evc b(NOLOCK) ON b.codeve = a.codeve                                          ") + msEnter
		TM004 += Alltrim("                                                          AND b.codtab = a.tabeve                                      ") + msEnter
		TM004 += Alltrim("               INNER JOIN VETORH.dbo.r044cal c(NOLOCK) ON c.numemp = a.numemp                                          ") + msEnter
		TM004 += Alltrim("                                                          AND c.codcal = a.codcal                                      ") + msEnter
		TM004 += Alltrim("               INNER JOIN VETORH.dbo.r038hfi e(NOLOCK) ON e.numemp = a.numemp                                          ") + msEnter
		TM004 += Alltrim("                                                          AND e.tipcol = a.tipcol                                      ") + msEnter
		TM004 += Alltrim("                                                          AND e.numcad = a.numcad                                      ") + msEnter
		TM004 += Alltrim("                                                          AND e.datalt =                                               ") + msEnter
		TM004 += Alltrim("          (                                                                                                            ") + msEnter
		TM004 += Alltrim("              SELECT MAX(qq.datalt)                                                                                    ") + msEnter
		TM004 += Alltrim("              FROM VETORH.dbo.r038hfi qq(NOLOCK)                                                                       ") + msEnter
		TM004 += Alltrim("              WHERE qq.datalt < EOMONTH(c.perref)                                                                      ") + msEnter
		TM004 += Alltrim("                    AND qq.numemp = a.numemp                                                                           ") + msEnter
		TM004 += Alltrim("                    AND qq.tipcol = a.tipcol                                                                           ") + msEnter
		TM004 += Alltrim("                    AND qq.numcad = a.numcad                                                                           ") + msEnter
		TM004 += Alltrim("          )                                                                                                            ") + msEnter
		TM004 += Alltrim("          WHERE a.tipcol = 1                                                                                           ") + msEnter
		TM004 += Alltrim("                AND ((b.tipeve IN(1, 2, 4, 5)                                                                          ") + msEnter
		TM004 += Alltrim("                AND a.codeve NOT IN(230, 206, 1650))                                                                   ") + msEnter
		TM004 += Alltrim("          OR (b.tipeve IN(3)                                                                                           ") + msEnter
		TM004 += Alltrim("          AND a.codeve = 2061))                                                                                        ") + msEnter
		TM004 += Alltrim("          UNION ALL                                                                                                    ") + msEnter
		TM004 += Alltrim("          SELECT a.numemp,                                                                                             ") + msEnter
		TM004 += Alltrim("                 e.codfil,                                                                                             ") + msEnter
		TM004 += Alltrim("                 a.tipcol,                                                                                             ") + msEnter
		TM004 += Alltrim("                 a.numcad,                                                                                             ") + msEnter
		TM004 += Alltrim("                 codeve = CONVERT(VARCHAR, a.tipprv) + RIGHT('000' + CONVERT(VARCHAR, a.tipval), 3),                   ") + msEnter
		TM004 += Alltrim("                 mesano = EOMONTH(a.mesano),                                                                           ") + msEnter
		TM004 += Alltrim("                 tabcus = 'PRV',                                                                                       ") + msEnter
		TM004 += Alltrim("                 tipeve = a.tipprv,                                                                                    ") + msEnter
		TM004 += Alltrim("                 destpe = CASE                                                                                         ") + msEnter
		TM004 += Alltrim("                              WHEN a.tipprv = 1                                                                        ") + msEnter
		TM004 += Alltrim("                              THEN 'Férias' + ' / ' + h.desval                                                         ") + msEnter
		TM004 += Alltrim("                              WHEN a.tipprv = 2                                                                        ") + msEnter
		TM004 += Alltrim("                              THEN '13o Salário' + ' / ' + h.desval                                                    ") + msEnter
		TM004 += Alltrim("                              ELSE 'Verificar'                                                                         ") + msEnter
		TM004 += Alltrim("                          END,                                                                                         ") + msEnter
		TM004 += Alltrim("                 insemp = 0,                                                                                           ") + msEnter
		TM004 += Alltrim("                 perter = 0,                                                                                           ") + msEnter
		TM004 += Alltrim("                 ratfap = 0,                                                                                           ") + msEnter
		TM004 += Alltrim("                 basins = 0,                                                                                           ") + msEnter
		TM004 += Alltrim("                 valor = a.ajuprv + a.prvmes                                                                           ") + msEnter
		TM004 += Alltrim("          FROM VETORH.dbo.r146prv a(NOLOCK)                                                                            ") + msEnter
		TM004 += Alltrim("               LEFT JOIN VETORH.dbo.r146det h(NOLOCK) ON h.tipprv = a.tipprv                                           ") + msEnter
		TM004 += Alltrim("                                                         AND h.tipval = a.tipval                                       ") + msEnter
		TM004 += Alltrim("               INNER JOIN VETORH.dbo.r038hfi e(NOLOCK) ON e.numemp = a.numemp                                          ") + msEnter
		TM004 += Alltrim("                                                          AND e.tipcol = a.tipcol                                      ") + msEnter
		TM004 += Alltrim("                                                          AND e.numcad = a.numcad                                      ") + msEnter
		TM004 += Alltrim("                                                          AND e.datalt =                                               ") + msEnter
		TM004 += Alltrim("          (                                                                                                            ") + msEnter
		TM004 += Alltrim("              SELECT MAX(qq.datalt)                                                                                    ") + msEnter
		TM004 += Alltrim("              FROM VETORH.dbo.r038hfi qq(NOLOCK)                                                                       ") + msEnter
		TM004 += Alltrim("              WHERE qq.datalt < EOMONTH(a.mesano)                                                                      ") + msEnter
		TM004 += Alltrim("                    AND qq.numemp = a.numemp                                                                           ") + msEnter
		TM004 += Alltrim("                    AND qq.tipcol = a.tipcol                                                                           ") + msEnter
		TM004 += Alltrim("                    AND qq.numcad = a.numcad                                                                           ") + msEnter
		TM004 += Alltrim("          )                                                                                                            ") + msEnter
		TM004 += Alltrim("          WHERE a.tipcol = 1),                                                                                         ") + msEnter
		TM004 += Alltrim("      BaseInss                                                                                                         ") + msEnter
		TM004 += Alltrim("      AS (SELECT a.numemp,                                                                                             ") + msEnter
		TM004 += Alltrim("                 e.codfil,                                                                                             ") + msEnter
		TM004 += Alltrim("                 a.tipcol,                                                                                             ") + msEnter
		TM004 += Alltrim("                 a.numcad,                                                                                             ") + msEnter
		TM004 += Alltrim("                 mesano = EOMONTH(c.perref),                                                                           ") + msEnter
		TM004 += Alltrim("                 tabcus = 'INS',                                                                                       ") + msEnter
		TM004 += Alltrim("                 b.tipeve,                                                                                             ") + msEnter
		TM004 += Alltrim("                 destpe = CASE                                                                                         ") + msEnter
		TM004 += Alltrim("                              WHEN b.tipeve = 1                                                                        ") + msEnter
		TM004 += Alltrim("                              THEN 'Proventos'                                                                         ") + msEnter
		TM004 += Alltrim("                              WHEN b.tipeve = 2                                                                        ") + msEnter
		TM004 += Alltrim("                              THEN 'Vantagens'                                                                         ") + msEnter
		TM004 += Alltrim("                              WHEN b.tipeve = 3                                                                        ") + msEnter
		TM004 += Alltrim("                              THEN 'Descontos'                                                                         ") + msEnter
		TM004 += Alltrim("                              WHEN b.tipeve = 4                                                                        ") + msEnter
		TM004 += Alltrim("                              THEN 'Outros'                                                                            ") + msEnter
		TM004 += Alltrim("                              WHEN b.tipeve = 5                                                                        ") + msEnter
		TM004 += Alltrim("                              THEN 'Outros Env Proventos'                                                              ") + msEnter
		TM004 += Alltrim("                              WHEN b.tipeve = 6                                                                        ") + msEnter
		TM004 += Alltrim("                              THEN 'Outros Env Descontos'                                                              ") + msEnter
		TM004 += Alltrim("                          END,                                                                                         ") + msEnter
		TM004 += Alltrim("                 valor = CASE                                                                                          ") + msEnter
		TM004 += Alltrim("                             WHEN d.incinm = '+'                                                                       ") + msEnter
		TM004 += Alltrim("                             THEN a.valeve                                                                             ") + msEnter
		TM004 += Alltrim("                             ELSE a.valeve * (-1)                                                                      ") + msEnter
		TM004 += Alltrim("                         END,                                                                                          ") + msEnter
		TM004 += Alltrim("                 d.incinm                                                                                              ") + msEnter
		TM004 += Alltrim("          FROM VETORH.dbo.r046ver a                                                                                    ") + msEnter
		TM004 += Alltrim("               INNER JOIN VETORH.dbo.r008evc b ON b.codeve = a.codeve                                                  ") + msEnter
		TM004 += Alltrim("                                                  AND b.codtab = a.tabeve                                              ") + msEnter
		TM004 += Alltrim("               INNER JOIN VETORH.dbo.r044cal c ON c.numemp = a.numemp                                                  ") + msEnter
		TM004 += Alltrim("                                                  AND c.codcal = a.codcal                                              ") + msEnter
		TM004 += Alltrim("               INNER JOIN VETORH.dbo.r008inc d ON d.codeve = a.codeve                                                  ") + msEnter
		TM004 += Alltrim("                                                  AND d.codtab = a.tabeve                                              ") + msEnter
		TM004 += Alltrim("               INNER JOIN VETORH.dbo.r038hfi e ON e.numemp = a.numemp                                                  ") + msEnter
		TM004 += Alltrim("                                                  AND e.tipcol = a.tipcol                                              ") + msEnter
		TM004 += Alltrim("                                                  AND e.numcad = a.numcad                                              ") + msEnter
		TM004 += Alltrim("                                                  AND e.datalt =                                                       ") + msEnter
		TM004 += Alltrim("          (                                                                                                            ") + msEnter
		TM004 += Alltrim("              SELECT MAX(qq.datalt)                                                                                    ") + msEnter
		TM004 += Alltrim("              FROM VETORH.dbo.r038hfi qq                                                                               ") + msEnter
		TM004 += Alltrim("              WHERE qq.datalt < EOMONTH(c.perref)                                                                      ") + msEnter
		TM004 += Alltrim("                    AND qq.numemp = a.numemp                                                                           ") + msEnter
		TM004 += Alltrim("                    AND qq.tipcol = a.tipcol                                                                           ") + msEnter
		TM004 += Alltrim("                    AND qq.numcad = a.numcad                                                                           ") + msEnter
		TM004 += Alltrim("          )                                                                                                            ") + msEnter
		TM004 += Alltrim("          WHERE b.tipeve <> 5                                                                                          ") + msEnter
		TM004 += Alltrim("                AND d.incinm IN('+', '-')),                                                                            ") + msEnter
		TM004 += Alltrim("      AgrupaCustototal                                                                                                 ") + msEnter
		TM004 += Alltrim("      AS (SELECT x.numemp,                                                                                             ") + msEnter
		TM004 += Alltrim("                 x.codfil,                                                                                             ") + msEnter
		TM004 += Alltrim("                 x.tipcol,                                                                                             ") + msEnter
		TM004 += Alltrim("                 x.numcad,                                                                                             ") + msEnter
		TM004 += Alltrim("                 x.mesano,                                                                                             ") + msEnter
		TM004 += Alltrim("                 x.tabcus,                                                                                             ") + msEnter
		TM004 += Alltrim("                 basins = SUM(valor)                                                                                   ") + msEnter
		TM004 += Alltrim("          FROM BaseInss x                                                                                              ") + msEnter
		TM004 += Alltrim("          GROUP BY x.numemp,                                                                                           ") + msEnter
		TM004 += Alltrim("                   x.codfil,                                                                                           ") + msEnter
		TM004 += Alltrim("                   x.tipcol,                                                                                           ") + msEnter
		TM004 += Alltrim("                   x.numcad,                                                                                           ") + msEnter
		TM004 += Alltrim("                   x.mesano,                                                                                           ") + msEnter
		TM004 += Alltrim("                   x.tabcus),                                                                                          ") + msEnter
		TM004 += Alltrim("      sFinal                                                                                                           ") + msEnter
		TM004 += Alltrim("      AS (SELECT x.numemp,                                                                                             ") + msEnter
		TM004 += Alltrim("                 x.codfil,                                                                                             ") + msEnter
		TM004 += Alltrim("                 tipcol,                                                                                               ") + msEnter
		TM004 += Alltrim("                 numcad,                                                                                               ") + msEnter
		TM004 += Alltrim("                 mesano,                                                                                               ") + msEnter
		TM004 += Alltrim("                 tabcus,                                                                                               ") + msEnter
		TM004 += Alltrim("                 insemp = g.peraut,                                                                                    ") + msEnter
		TM004 += Alltrim("                 perter = g.perter,                                                                                    ") + msEnter
		TM004 += Alltrim("                 ratfap = ISNULL(ratnae, 0) * ISNULL(fatfap, 0),                                                       ") + msEnter
		TM004 += Alltrim("                 basins = basins                                                                                       ") + msEnter
		TM004 += Alltrim("          FROM AgrupaCustototal x                                                                                      ") + msEnter
		TM004 += Alltrim("               LEFT JOIN VETORH.dbo.r030grp f ON f.numemp = x.numemp                                                   ") + msEnter
		TM004 += Alltrim("                                                 AND f.codfil = x.codfil                                               ") + msEnter
		TM004 += Alltrim("                                                 AND f.datgrp =                                                        ") + msEnter
		TM004 += Alltrim("          (                                                                                                            ") + msEnter
		TM004 += Alltrim("              SELECT MAX(qq.datgrp)                                                                                    ") + msEnter
		TM004 += Alltrim("              FROM VETORH.dbo.r030grp qq                                                                               ") + msEnter
		TM004 += Alltrim("              WHERE qq.datgrp < mesano                                                                                 ") + msEnter
		TM004 += Alltrim("                    AND qq.numemp = x.numemp                                                                           ") + msEnter
		TM004 += Alltrim("                    AND qq.codfil = x.codfil                                                                           ") + msEnter
		TM004 += Alltrim("          )                                                                                                            ") + msEnter
		TM004 += Alltrim("               LEFT JOIN VETORH.dbo.r026fpv g ON g.codfpa = 507                                                        ") + msEnter
		TM004 += Alltrim("                                                 AND g.tipgrp = 1                                                      ") + msEnter
		TM004 += Alltrim("                                                 AND g.datfpa =                                                        ") + msEnter
		TM004 += Alltrim("          (                                                                                                            ") + msEnter
		TM004 += Alltrim("              SELECT MAX(qq.datfpa)                                                                                    ") + msEnter
		TM004 += Alltrim("              FROM VETORH.dbo.r026fpv qq                                                                               ") + msEnter
		TM004 += Alltrim("              WHERE qq.datfpa < mesano                                                                                 ") + msEnter
		TM004 += Alltrim("          )                                                                                                            ") + msEnter
		TM004 += Alltrim("          WHERE x.tipcol = 1),                                                                                         ") + msEnter
		TM004 += Alltrim("      RUBRICAS                                                                                                         ") + msEnter
		TM004 += Alltrim("      AS (SELECT rtabcus = CASE                                                                                        ") + msEnter
		TM004 += Alltrim("                               WHEN ZBW_TABELA = 5                                                                     ") + msEnter
		TM004 += Alltrim("                               THEN 'FOL'                                                                              ") + msEnter
		TM004 += Alltrim("                               WHEN ZBW_TABELA = 6                                                                     ") + msEnter
		TM004 += Alltrim("                               THEN 'PRV'                                                                              ") + msEnter
		TM004 += Alltrim("                               WHEN ZBW_TABELA = 7                                                                     ") + msEnter
		TM004 += Alltrim("                               THEN 'INS'                                                                              ") + msEnter
		TM004 += Alltrim("                           END,                                                                                        ") + msEnter
		TM004 += Alltrim("                 rcodeve = ZBW_EVENTO,                                                                                 ") + msEnter
		TM004 += Alltrim("                 rrubric = ZBW_RUBRIC                                                                                  ") + msEnter
		TM004 += Alltrim("          FROM " + RetSqlName("ZBW") + " ZBW(NOLOCK)                                                                   ") + msEnter
		TM004 += Alltrim("          WHERE ZBW_FILIAL = '" + xFilial("ZBW") + "'                                                                  ") + msEnter
		TM004 += Alltrim("                AND ZBW_VERSAO = '" + msVersao + "'                                                                    ") + msEnter
		TM004 += Alltrim("                AND ZBW_REVISA = '" + msRevisa + "'                                                                    ") + msEnter
		TM004 += Alltrim("                AND ZBW_ANOREF = '" + msAnoRef + "'                                                                    ") + msEnter
		TM004 += Alltrim("                AND ZBW_TABELA IN('5', '6', '7')                                                                       ") + msEnter
		TM004 += Alltrim("                AND ZBW.D_E_L_E_T_ = ' ')                                                                              ") + msEnter
		TM004 += Alltrim("      SELECT *                                                                                                         ") + msEnter
		TM004 += Alltrim("      INTO " + msTblTemp + "                                                                                           ") + msEnter
		TM004 += Alltrim("      FROM                                                                                                             ") + msEnter
		TM004 += Alltrim("      (                                                                                                                ") + msEnter
		TM004 += Alltrim("          SELECT numemp,                                                                                               ") + msEnter
		TM004 += Alltrim("                 codfil,                                                                                               ") + msEnter
		TM004 += Alltrim("                 tipcol,                                                                                               ") + msEnter
		TM004 += Alltrim("                 numcad,                                                                                               ") + msEnter
		TM004 += Alltrim("                 codeve,                                                                                               ") + msEnter
		TM004 += Alltrim("                 mesano,                                                                                               ") + msEnter
		TM004 += Alltrim("                 tabcus,                                                                                               ") + msEnter
		TM004 += Alltrim("                 tipeve,                                                                                               ") + msEnter
		TM004 += Alltrim("                 destpe,                                                                                               ") + msEnter
		TM004 += Alltrim("                 insemp = SUM(insemp),                                                                                 ") + msEnter
		TM004 += Alltrim("                 perter = SUM(perter),                                                                                 ") + msEnter
		TM004 += Alltrim("                 ratfap = SUM(ratfap),                                                                                 ") + msEnter
		TM004 += Alltrim("                 basins = SUM(basins),                                                                                 ") + msEnter
		TM004 += Alltrim("                 cusfun = SUM(valor),                                                                                  ") + msEnter
		TM004 += Alltrim("                 b.rrubric                                                                                             ") + msEnter
		TM004 += Alltrim("          FROM CUSTOFUNC a                                                                                             ") + msEnter
		TM004 += Alltrim("               LEFT JOIN RUBRICAS b ON b.rtabcus = a.tabcus                                                            ") + msEnter
		TM004 += Alltrim("                                       AND b.rcodeve = a.codeve                                                        ") + msEnter
		TM004 += Alltrim("          WHERE 1 = 1                                                                                                  ") + msEnter
		TM004 += Alltrim("                AND numemp = " + Str(Val(cEmpAnt)) + "                                                                 ") + msEnter
		TM004 += Alltrim("                AND codfil = " + Str(Val(cFilAnt)) + "                                                                 ") + msEnter
		TM004 += Alltrim("                AND mesano = EOMONTH('" + msAnoRef + "-" + msPeriod + "-01 00:00:00.000')                              ") + msEnter
		TM004 += Alltrim("          GROUP BY numemp,                                                                                             ") + msEnter
		TM004 += Alltrim("                   codfil,                                                                                             ") + msEnter
		TM004 += Alltrim("                   tipcol,                                                                                             ") + msEnter
		TM004 += Alltrim("                   numcad,                                                                                             ") + msEnter
		TM004 += Alltrim("                   codeve,                                                                                             ") + msEnter
		TM004 += Alltrim("                   mesano,                                                                                             ") + msEnter
		TM004 += Alltrim("                   tabcus,                                                                                             ") + msEnter
		TM004 += Alltrim("                   tipeve,                                                                                             ") + msEnter
		TM004 += Alltrim("                   destpe,                                                                                             ") + msEnter
		TM004 += Alltrim("                   b.rrubric                                                                                           ") + msEnter
		TM004 += Alltrim("          UNION ALL                                                                                                    ") + msEnter
		TM004 += Alltrim("          SELECT numemp,                                                                                               ") + msEnter
		TM004 += Alltrim("                 codfil,                                                                                               ") + msEnter
		TM004 += Alltrim("                 tipcol,                                                                                               ") + msEnter
		TM004 += Alltrim("                 numcad,                                                                                               ") + msEnter
		TM004 += Alltrim("                 1 codeve,                                                                                             ") + msEnter
		TM004 += Alltrim("                 mesano,                                                                                               ") + msEnter
		TM004 += Alltrim("                 tabcus,                                                                                               ") + msEnter
		TM004 += Alltrim("                 tipeve = '9',                                                                                         ") + msEnter
		TM004 += Alltrim("                 destpe = 'Inss parte Empresa',                                                                        ") + msEnter
		TM004 += Alltrim("                 insemp = insemp,                                                                                      ") + msEnter
		TM004 += Alltrim("                 perter = perter,                                                                                      ") + msEnter
		TM004 += Alltrim("                 ratfap = ratfap,                                                                                      ") + msEnter
		TM004 += Alltrim("                 basins = basins,                                                                                      ") + msEnter
		TM004 += Alltrim("                 cusfun = (insemp * basins / 100) + (perter * basins / 100) + (ratfap * basins / 100),                 ") + msEnter
		TM004 += Alltrim("                 b.rrubric                                                                                             ") + msEnter
		TM004 += Alltrim("          FROM sFinal a                                                                                                ") + msEnter
		TM004 += Alltrim("               LEFT JOIN RUBRICAS b ON b.rtabcus = a.tabcus                                                            ") + msEnter
		TM004 += Alltrim("                                       AND b.rcodeve = 1                                                               ") + msEnter
		TM004 += Alltrim("          WHERE 1 = 1                                                                                                  ") + msEnter
		TM004 += Alltrim("                AND numemp = " + Str(Val(cEmpAnt)) + "                                                                 ") + msEnter
		TM004 += Alltrim("                AND codfil = " + Str(Val(cFilAnt)) + "                                                                 ") + msEnter
		TM004 += Alltrim("                AND mesano = EOMONTH('" + msAnoRef + "-" + msPeriod + "-01 00:00:00.000')                              ") + msEnter
		TM004 += Alltrim("      ) AS TEMP1                                                                                                       ") + msEnter
		TM004 += Alltrim("      ORDER BY numemp,                                                                                                 ") + msEnter
		TM004 += Alltrim("               tipcol,                                                                                                 ") + msEnter
		TM004 += Alltrim("               numcad,                                                                                                 ") + msEnter
		TM004 += Alltrim("               mesano,                                                                                                 ") + msEnter
		TM004 += Alltrim("               tabcus,                                                                                                 ") + msEnter
		TM004 += Alltrim("               codeve,                                                                                                 ") + msEnter
		TM004 += Alltrim("               rrubric                                                                                                 ") + msEnter
		U_BIAMsgRun("Aguarde... Criando arquivo de Trabalho... ",,{|| msStaExcQy := TcSQLExec(TM004) })
		If msStaExcQy < 0
			mslOk := .F.
		EndIf

		If !mslOk

			msGravaErr := TCSQLError()
			DisarmTransaction()

		EndIf

	End Transaction 

Return

Static Function msChkAtrbR()

	msGravaErr := "Eventos sem associação a Rubricas: " + msEnter + msEnter
	CK003 := Alltrim(" SELECT DISTINCT                                    ") + msEnter
	CK003 += Alltrim("        codeve,                                     ") + msEnter
	CK003 += Alltrim("        destpe,                                     ") + msEnter
	CK003 += Alltrim("        tabcus,                                     ") + msEnter
	CK003 += Alltrim("        tabref = CASE                               ") + msEnter
	CK003 += Alltrim("                     WHEN tabcus = 'FOL'            ") + msEnter
	CK003 += Alltrim("                     THEN '5-seniorFOL'             ") + msEnter
	CK003 += Alltrim("                     WHEN tabcus = 'PRV'            ") + msEnter
	CK003 += Alltrim("                     THEN '6-seniorPRV'             ") + msEnter
	CK003 += Alltrim("                     WHEN tabcus = 'INS'            ") + msEnter
	CK003 += Alltrim("                     THEN '7-seniorINS'             ") + msEnter
	CK003 += Alltrim("                 END                                ") + msEnter
	CK003 += Alltrim(" FROM " + msTblTemp + "                             ") + msEnter
	CK003 += Alltrim(" WHERE rrubric IS NULL                              ") + msEnter
	CKIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,CK003),'CK03',.T.,.T.)
	dbSelectArea("CK03")
	CK03->(dbGoTop())
	While !CK03->(Eof())

		If !Alltrim(Str(CK03->codeve)) $ Alltrim(GETMV("MV_YEVEFIL")) 
			mslOk := .F.
			msGravaErr += CK03->tabref + " - " + Alltrim(Str(CK03->codeve)) + " - " + CK03->destpe + msEnter
		EndIf 
		CK03->(dbSkip())

	End
	CK03->(dbCloseArea())
	Ferase(CKIndex+GetDBExtension())
	Ferase(CKIndex+OrdBagExt())

Return

Static Function msCmpPivot()

	CP007 := Alltrim(" SELECT *                                                                     ") + msEnter
	CP007 += Alltrim(" FROM                                                                         ") + msEnter
	CP007 += Alltrim(" (                                                                            ") + msEnter
	CP007 += Alltrim("     SELECT DISTINCT                                                          ") + msEnter
	CP007 += Alltrim("            ',' + QUOTENAME(RTRIM(CONVERT(VARCHAR, ZBC_RUBRIC))) CAMPOS       ") + msEnter
	CP007 += Alltrim("     FROM " + RetSqlName("ZBC") + " ZBC(NOLOCK)                               ") + msEnter
	CP007 += Alltrim("     WHERE ZBC_FILIAL = '" + xFilial("ZBC") + "'                              ") + msEnter
	CP007 += Alltrim("            AND ZBC_VERSAO = '" + msVersao + "'                               ") + msEnter
	CP007 += Alltrim("            AND ZBC_REVISA = '" + msRevisa + "'                               ") + msEnter
	CP007 += Alltrim("            AND ZBC_ANOREF = '" + msAnoRef + "'                               ") + msEnter
	CP007 += Alltrim("            AND ZBC.D_E_L_E_T_ = ' '                                          ") + msEnter
	CP007 += Alltrim(" ) AS TEMP1                                                                   ") + msEnter
	CPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,CP007),'CP07',.T.,.T.)
	dbSelectArea("CP07")
	CP07->(dbGoTop())
	While !CP07->(Eof())

		msPivotCmp += Alltrim(CP07->CAMPOS)
		CP07->(dbSkip())

	End
	CP07->(dbCloseArea())
	Ferase(CPIndex+GetDBExtension())
	Ferase(CPIndex+OrdBagExt())

	If !Empty(msPivotCmp)

		msPivotCmp := Substr(Alltrim(msPivotCmp), 2, Len(Alltrim(msPivotCmp)) - 1 )

	Else

		mslOk := .F.
		msGravaErr := "Erro na montagem dos campos para PIVOT..."

	EndIf

Return

Static Function msGrvEvent()

	SQ007 := Alltrim(" SELECT ZBC_RUBRIC LEITURA,                                                        ") + msEnter
	SQ007 += Alltrim("        REPLACE(ZBC_RUBRIC, 'ZBA', 'ZBO') GRAVACAO                                 ") + msEnter
	SQ007 += Alltrim(" FROM " + RetSqlName("ZBC") + " ZBC(NOLOCK)                                        ") + msEnter
	SQ007 += Alltrim(" WHERE ZBC_FILIAL = '" + xFilial("ZBC") + "'                                       ") + msEnter
	SQ007 += Alltrim("       AND ZBC_VERSAO = '" + msVersao + "'                                         ") + msEnter
	SQ007 += Alltrim("       AND ZBC_REVISA = '" + msRevisa + "'                                         ") + msEnter
	SQ007 += Alltrim("       AND ZBC_ANOREF = '" + msAnoRef + "'                                         ") + msEnter
	SQ007 += Alltrim("       AND ZBC.D_E_L_E_T_ = ' '                                                    ") + msEnter
	SQ007 += Alltrim(" ORDER BY ZBC_ORDEM                                                                ") + msEnter
	SQIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SQ007),'SQ07',.T.,.T.)
	dbSelectArea("SQ07")

	TP009 := Alltrim(" SELECT *                                                                          ") + msEnter
	TP009 += Alltrim(" INTO " + ms2TbTemp + "                                                            ") + msEnter
	TP009 += Alltrim(" FROM                                                                              ") + msEnter
	TP009 += Alltrim(" (                                                                                 ") + msEnter
	TP009 += Alltrim("     SELECT numemp,                                                                ") + msEnter
	TP009 += Alltrim("            codfil,                                                                ") + msEnter
	TP009 += Alltrim("            tipcol,                                                                ") + msEnter
	TP009 += Alltrim("            numcad,                                                                ") + msEnter
	TP009 += Alltrim("            cusfun,                                                                ") + msEnter
	TP009 += Alltrim("            rrubric                                                                ") + msEnter
	TP009 += Alltrim("     FROM " + msTblTemp + "                                                        ") + msEnter
	TP009 += Alltrim("     WHERE NOT rrubric IS NULL                                                     ") + msEnter
	TP009 += Alltrim(" ) AS TEMP1 PIVOT(SUM(cusfun) FOR rrubric IN( " +msPivotCmp + " )) em_colunas      ") + msEnter
	TP009 += Alltrim(" ORDER BY 1                                                                        ") + msEnter
	U_BIAMsgRun("Aguarde... Criando Segundo arquivo de Trabalho... ",,{|| msStaExcQy := TcSQLExec(TP009) })
	If msStaExcQy < 0
		mslOk := .F.
	EndIf

	If mslOk

		U_BIAMsgRun("Aguarde... Criando Terceiro arquivo de Trabalho... ",,{|| msStaExcQy := TcSQLExec(mskQry07) })
		If msStaExcQy < 0
			mslOk := .F.
		EndIf

		If mslOk

			msDiaRef := substr(dtos(UltimoDia(stod(msAnoRef + msPeriod + "01"))), 7, 2)
			GV002 := Alltrim(" SELECT *,                                                                                                       ") + msEnter
			GV002 += Alltrim("        CLVL =                                                                                                   ") + msEnter
			GV002 += Alltrim(" (                                                                                                               ") + msEnter
			GV002 += Alltrim("     SELECT codccu                                                                                               ") + msEnter
			GV002 += Alltrim("     FROM VETORH.dbo.r038hcc a                                                                                   ") + msEnter
			GV002 += Alltrim("     WHERE a.numemp = tmp.numemp                                                                                 ") + msEnter
			GV002 += Alltrim("           AND a.tipcol = tmp.tipcol                                                                             ") + msEnter
			GV002 += Alltrim("           AND a.numcad = tmp.numcad                                                                             ") + msEnter
			GV002 += Alltrim("           AND a.datalt IN                                                                                       ") + msEnter
			GV002 += Alltrim("     (                                                                                                           ") + msEnter
			GV002 += Alltrim("         SELECT MAX(datalt)                                                                                      ") + msEnter
			GV002 += Alltrim("         FROM VETORH.dbo.r038hcc b                                                                               ") + msEnter
			GV002 += Alltrim("         WHERE b.numemp = a.numemp                                                                               ") + msEnter
			GV002 += Alltrim("               AND b.tipcol = a.tipcol                                                                           ") + msEnter
			GV002 += Alltrim("               AND b.numcad = a.numcad                                                                           ") + msEnter
			GV002 += Alltrim("               AND EOMONTH('" + msAnoRef + "-" + msPeriod + "-" + msDiaRef + " 00:00:00.000') >= b.datalt        ") + msEnter
			GV002 += Alltrim("     )                                                                                                           ") + msEnter
			GV002 += Alltrim(" ),                                                                                                              ") + msEnter
			GV002 += Alltrim("        [dbo].[FNC_BI_GETDEPART](numemp, numcad, '" + msAnoRef + msPeriod + msDiaRef + "') DPTOSR,               ") + msEnter 
			GV002 += Alltrim("        [dbo].FNC_BI_GETCARGO(numemp, numcad, '" + msAnoRef + msPeriod + msDiaRef + "') CARGO,                   ") + msEnter
			GV002 += Alltrim("        NOME =                                                                                                   ") + msEnter
			GV002 += Alltrim(" (                                                                                                               ") + msEnter
			GV002 += Alltrim("     SELECT nomfun                                                                                               ") + msEnter
			GV002 += Alltrim("     FROM VETORH.dbo.r034fun FUN                                                                                 ") + msEnter
			GV002 += Alltrim("     WHERE FUN.tipcol = 1                                                                                        ") + msEnter
			GV002 += Alltrim("           AND FUN.numemp = tmp.numemp                                                                           ") + msEnter
			GV002 += Alltrim("           AND FUN.numcad = tmp.numcad                                                                           ") + msEnter
			GV002 += Alltrim(" ),                                                                                                              ") + msEnter
			GV002 += Alltrim("        XXX.*                                                                                                    ") + msEnter
			GV002 += Alltrim(" FROM " + ms2TbTemp + " tmp                                                                                      ") + msEnter	
			GV002 += Alltrim("      LEFT JOIN " + ms3TbTemp + " XXX ON D3_YMATRIC = NUMCAD                                                     ") + msEnter	
			GVIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,GV002),'GV02',.T.,.T.)
			dbSelectArea("GV02")

			Begin Transaction

				ET001 := Alltrim(" DELETE ZBO                                               ") + msEnter
				ET001 += Alltrim(" FROM " + RetSqlName("ZBO") + " ZBO                       ") + msEnter
				ET001 += Alltrim(" WHERE ZBO_FILIAL = '" + xFilial("ZBO") + "'              ") + msEnter
				ET001 += Alltrim("       AND ZBO_VERSAO = '" + msVersao + "'                ") + msEnter
				ET001 += Alltrim("       AND ZBO_REVISA = '" + msRevisa + "'                ") + msEnter
				ET001 += Alltrim("       AND ZBO_ANOREF = '" + msAnoRef + "'                ") + msEnter
				ET001 += Alltrim("       AND ZBO_PERIOD = '" + msPeriod + "'                ") + msEnter
				ET001 += Alltrim("       AND ZBO.D_E_L_E_T_ = ' '                           ") + msEnter
				U_BIAMsgRun("Aguarde... Zerando processsamento anterior... ",,{|| msStaExcQy := TcSQLExec(ET001) })
				If msStaExcQy < 0
					mslOk := .F.
				EndIf

				If mslOk

					GV02->(dbGoTop())
					While !GV02->(Eof())

						Reclock("ZBO",.T.)
						ZBO->ZBO_FILIAL  := xFilial("ZBO")  
						ZBO->ZBO_VERSAO  := msVersao
						ZBO->ZBO_REVISA  := msRevisa
						ZBO->ZBO_ANOREF  := msAnoRef
						ZBO->ZBO_PERIOD  := msPeriod
						ZBO->ZBO_CLVL    := GV02->CLVL
						ZBO->ZBO_MATR    := StrZero(GV02->numcad,6)
						ZBO->ZBO_DPTOSR  := GV02->DPTOSR
						ZBO->ZBO_FUNCAO  := GV02->CARGO
						ZBO->ZBO_NOME    := GV02->NOME

						SQ07->(dbGoTop())
						While !SQ07->(Eof())

							If "VLREPI" $ Alltrim(SQ07->GRAVACAO) 

								&("ZBO->" + SQ07->GRAVACAO) := GV02->D3_VLREPI

							ElseIf "VLRUNI" $ Alltrim(SQ07->GRAVACAO)

								&("ZBO->" + SQ07->GRAVACAO) := GV02->D3_VLRUNI

							Else

								&("ZBO->" + SQ07->GRAVACAO) := &("GV02->" + SQ07->LEITURA)

							EndIf
							SQ07->(dbSkip())

						End
						ZBO->(MsUnlock())

						GV02->(dbSkip())

					End

				Else

					msGravaErr := TCSQLError()
					DisarmTransaction()

				EndIf

				GV02->(dbCloseArea())
				Ferase(GVIndex+GetDBExtension())
				Ferase(GVIndex+OrdBagExt())

			End Transaction 	

		Else

			msGravaErr := TCSQLError()

		EndIf

	Else

		msGravaErr := TCSQLError()

	EndIf

	SQ07->(dbCloseArea())
	Ferase(SQIndex+GetDBExtension())
	Ferase(SQIndex+OrdBagExt())

Return

User FUNCTION BIAF153F()

	Local oGroup1
	Local oSay1
	Local oSButton1
	Local oSButton2
	Private oEntra
	Private msFecha := .F.
	Private msAltReg := .F.

	Private obEveFil
	Private msEveFil := Space(250)

	msEveFil := Alltrim(GETMV("MV_YEVEFIL")) + Space(250 - Len(Alltrim(GETMV("MV_YEVEFIL")))) 

	DEFINE MSDIALOG oEntra TITLE " Parâmetro " FROM 000, 000  TO 160, 800 COLORS 0, 16777215 PIXEL

	@ 009, 010 GROUP oGroup1 TO 071, 386 PROMPT "Parâmentros" OF oEntra COLOR 0, 16777215 PIXEL
	@ 028, 019 SAY oSay1 PROMPT "Informe os Eventos para Filtro de Processamento: " SIZE 125, 007 OF oEntra COLORS 0, 16777215 PIXEL
	@ 026, 141 MSGET obEveFil VAR msEveFil SIZE 234, 010 OF oEntra COLORS 0, 16777215 PIXEL
	DEFINE SBUTTON oSButton1 FROM 053, 347 TYPE 01 OF oEntra ENABLE ACTION fGrava()
	DEFINE SBUTTON oSButton2 FROM 053, 314 TYPE 02 OF oEntra ENABLE ACTION fAborta()

	ACTIVATE MSDIALOG oEntra CENTERED VALID msFecha

	If msAltReg

		MsgINFO("Alteração Realizada com SUCESSO.....", "Parâmetros")

	Else

		MsgAlert("Alteração Cancelada.....", "Parâmetros")

	EndIf

Return

Static Function fGrava()

	PutMV("MV_YEVEFIL", msEveFil )

	msFecha := .T.
	msAltReg := .T.
	Close(oEntra)

Return

Static Function fAborta()

	msFecha := .T.
	Close( oEntra )

Return

//Static Function fGrvNwSD3()

//	frd := mskQry07
//	fgsdgs := 1

//Return
