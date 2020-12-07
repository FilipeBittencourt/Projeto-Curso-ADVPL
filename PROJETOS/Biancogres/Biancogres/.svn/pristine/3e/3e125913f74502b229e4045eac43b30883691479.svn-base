#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA519
@author Marcos Alberto Soprani
@since 09/09/11
@version 1.0
@description Cálculo da Capacidade produtiva para RAC no mês
@obs Em 08/03/17... Por Marcos Alberto Soprani... Revisado
@type function
/*/

/*/{Protheus.doc} BIA519
@author Artur Antunes
@since 19/04/17
@version 1.1
@description Inclusão de controle de processamento via SX6 (MV_YULRAC) 
@obs OS 2304-16
@type function
/*/

User Function BIA519()

	private bOpcao3 := {|| fOpcoes("Z57",0,3)} 
	private bOpcao4 := {|| fOpcoes("Z57",Recno(),4)} 

	dbSelectArea("SX2")
	dbSeek("Z57")

	cCadastro := Upper(Alltrim(SX2->X2_NOME))
	aRotina   := { {"Pesquisar"        ,"AxPesqui"	      				,0,1},;
	{               "Visualizar"       ,"AxVisual"	      				,0,2},;
	{               "Incluir"          ,"EVAL(bOpcao3)"   				,0,3},;
	{               "Cálculo"          ,'EVAL(bOpcao4)'   				,0,4},;
	{               "Verificar"        ,'ExecBlock("BIA519V",.F.,.F.)'  ,0,5} }

	dbSelectArea(SX2->X2_CHAVE)
	dbSetOrder(1)
	dbGoTop()

	mBrowse(06,01,22,75,SX2->X2_CHAVE)

	dbSelectArea(SX2->X2_CHAVE)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA519C  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 16.03.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Efetua processamento da capaciadade produtiva              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA519C()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	dbSelectArea("Z57")

	cHInicio := Time()
	fPerg := "BIA519C"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	if !U_BiaULRAC(MV_PAR01)
		Return
	endif	

	msSequenc := ""
	XP001 := " SELECT ISNULL(MAX(Z57_SEQUEN), '   ') SEQUENCIA "
	XP001 += " FROM " + RetSqlName("Z57") + " Z57 "
	XP001 += " WHERE Z57_DATARF BETWEEN '" + Substr(dtos(MV_PAR01),1,4) + "0101' AND '" + Substr(dtos(MV_PAR01),1,4) + "1231' "
	XP001 += "       AND Z57.D_E_L_E_T_ = ' ' "
	XPIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XP001),'XP01',.T.,.T.)
	dbSelectArea("XP01")
	dbGoTop()
	msSequenc := XP01->SEQUENCIA
	XP01->(dbCloseArea())
	Ferase(XPIndex+GetDBExtension())
	Ferase(XPIndex+OrdBagExt())

	//                               Zera Valores para que não ocorra erros em caso se reprocessamento
	**************************************************************************************************
	ZP003 := " DELETE " + RetSqlName("Z57") + " "
	ZP003 += "   FROM " + RetSqlName("Z57") + " WITH (NOLOCK) " 
	ZP003 += "  WHERE Z57_FILIAL = '" + xFilial("Z57") + "' "
	ZP003 += "    AND Z57_DATARF BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	ZP003 += "    AND D_E_L_E_T_ = ' ' "
	TCSQLExec(ZP003)

	QY004 := " WITH ETQCANC AS (SELECT D3_COD PROD, SUM(D3_QUANT) * (-1) QTDCAN "
	QY004 += "                    FROM " + RetSqlName("SD3") + " SD3(NOLOCK) "
	QY004 += "                   WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	QY004 += "                     AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	QY004 += "                     AND D3_TIPO IN('PP','PA') "
	QY004 += "                     AND D3_TM = '711' "
	QY004 += "                     AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	QY004 += "                     AND D3_ESTORNO = ' ' "
	QY004 += "                     AND D_E_L_E_T_ = ' ' "
	QY004 += "                   GROUP BY D3_COD) "
	QY004 += " SELECT PRODUT, "
	QY004 += "        LINHA, "
	QY004 += "        CAPACID * AVG(DISTRI) CAPACID, "
	QY004 += "        PSECO, "
	QY004 += "        (SUM(QTDRAC) + ISNULL(SUM(QTDCAN), 0)) QTDRAC "
	QY004 += "   FROM (SELECT D3_COD PRODUT, "
	QY004 += "                Z42_LINHA LINHA, "
	QY004 += "                Z42_CAPACI CAPACID, "
	QY004 += "                Z42_PSECO PSECO, "
	QY004 += "                SUM(D3_QUANT) QTDRAC, "
	QY004 += "                CASE "
	QY004 += "                  WHEN AVG(Z42_DISTRI) = 0 THEN 1 "
	QY004 += "                  ELSE AVG(Z42_DISTRI) "
	QY004 += "                END DISTRI "
	QY004 += "           FROM " + RetSqlName("SB1") + " SB1(NOLOCK) "
	QY004 += "          INNER JOIN " + RetSqlName("Z42") + " Z42(NOLOCK) ON Z42_FILIAL = '" + xFilial("Z42") + "' "
	QY004 += "                               AND Z42_FORMAT = B1_YFORMAT "
	QY004 += "                               AND Z42_BASE = B1_YBASE "
	QY004 += "                               AND Z42_ACABAM LIKE  '%' + B1_YACABAM + '%' "
	QY004 += "                               AND Z42_ESPESS LIKE  '%' + B1_YESPESS + '%' "
	QY004 += "                               AND Z42_TPPROD LIKE  '%' + B1_TIPO + '%' "
	QY004 += "                               AND '" + dtos(MV_PAR01) + "' >= Z42_DTINI "
	QY004 += "                               AND '" + dtos(MV_PAR02) + "' <= Z42_DTFIM "
	QY004 += "                               AND Z42_VERSAO = '" + MV_PAR03 + "' "
	QY004 += "                               AND Z42_REVISA = '" + MV_PAR04 + "' "
	QY004 += "                               AND Z42_ANOREF = '" + MV_PAR05 + "' "
	QY004 += "                               AND Z42_FINALI = 'R' "
	QY004 += "                               AND Z42.D_E_L_E_T_ = ' ' "
	QY004 += "          INNER JOIN " + RetSqlName("SD3") + " SD3(NOLOCK) ON D3_FILIAL = '" + xFilial("SD3") + "' "
	QY004 += "                               AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	QY004 += "                               AND D3_COD = B1_COD "
	QY004 += "                               AND D3_TM = '010' "
	QY004 += "                               AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	QY004 += "                               AND D3_TIPO = B1_TIPO "
	QY004 += "                               AND D3_ESTORNO = ' ' "
	If cEmpAnt == "01"
	ElseIf cEmpAnt == "06"
		QY004 += "                               AND SUBSTRING(D3_CLVL,4,1) = SUBSTRING(Z42_LINHA,3,1) "
	EndIf
	QY004 += "                               AND SD3.D_E_L_E_T_ = ' ' "
	QY004 += "          WHERE B1_FILIAL = '  ' "
	If cEmpAnt == "01"
		QY004 += "            AND B1_TIPO IN('PA','PP') "
	ElseIf cEmpAnt == "06"
		QY004 += "            AND B1_TIPO IN('MP','PI','PA') "
	EndIf
	QY004 += "            AND SB1.D_E_L_E_T_ = ' ' "
	QY004 += "          GROUP BY D3_COD, "
	QY004 += "                   B1_TIPO, "
	QY004 += "                   Z42_LINHA, "
	QY004 += "                   Z42_CAPACI, "
	QY004 += "                   Z42_PSECO) AS TABRBR "
	QY004 += "   LEFT JOIN ETQCANC ECA WITH (NOLOCK) ON ECA.PROD = PRODUT "
	QY004 += "  GROUP BY PRODUT, "
	QY004 += "           LINHA, "
	QY004 += "           CAPACID, "
	QY004 += "           PSECO "
	QYIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QY004),'QY04',.T.,.T.)
	dbSelectArea("QY04")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		// Tratamento implementado em 05/02/16 durante carga de dados da RAC e GMCD janeiro de 2016.
		yfGrvOk := .T.
		If cEmpAnt == "05" .and. Substr(QY04->PRODUT,1,2) == "AL"

			KD008 := " SELECT SUM(LINHA1) LINHA1, SUM(LINHA2) LINHA2, SUM(LINHAV) LINHAV "
			KD008 += "   FROM (SELECT ISNULL(CASE "
			KD008 += "                         WHEN CE_FORNO IN(1,9) THEN SUM(Z18_QUANT) "
			KD008 += "                       END, 0) LINHA1, "
			KD008 += "                ISNULL(CASE "
			KD008 += "                         WHEN CE_FORNO IN(2,7) THEN SUM(Z18_QUANT) "
			KD008 += "                       END, 0) LINHA2, "
			KD008 += "                ISNULL(CASE "
			KD008 += "                         WHEN CE_FORNO NOT IN(1,9,2,7) THEN SUM(Z18_QUANT) "
			KD008 += "                       END, 0) LINHAV "
			KD008 += "           FROM " + RetSqlName("Z18") + " Z18(NOLOCK) "
			KD008 += "           LEFT JOIN DADOS_05_EOS..CEP_MOVIMENTO_PRODUTO A(NOLOCK) ON CE_NUMERO_DOCTO = Z18_NUMETQ "
			KD008 += "                                                          AND COD_TRANSACAO IN('1','20') "
			KD008 += "                                                          AND CE_DOCTO <> 'SA' "
			KD008 += "          INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' "
			KD008 += "                               AND B1_COD = Z18_COD "
			KD008 += "                               AND SB1.D_E_L_E_T_ = ' ' "
			KD008 += "          WHERE Z18_FILIAL = '" + xFilial("Z18") + "' "
			KD008 += "            AND Z18_DATA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
			KD008 += "            AND SUBSTRING(Z18_COD,1,7) = '" + Substr(QY04->PRODUT,1,7) + "' "
			KD008 += "            AND Z18_TM <> 'REP' "
			KD008 += "            AND Z18.D_E_L_E_T_ = ' ' "
			KD008 += "          GROUP BY CE_FORNO "
			KD008 += "        ) AS TEAVF "
			KDIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,KD008),'KD08',.T.,.T.)
			dbSelectArea("KD08")
			dbGoTop()
			If KD08->LINHAV <> 0
				Aviso('BIA519 - Outras Linhas', 'O produto ' + Alltrim(QY04->PRODUT) + ' foi produzido numa linha sem definição para rateio de custo... Não irá gerar dados, será necessário verificar!!!', {'Ok'})
				yfGrvOk := .F.
			Else
				If QY04->LINHA == "L01"
					If KD08->LINHA1 < KD08->LINHA2
						yfGrvOk := .F.
					EndIf
				ElseIf QY04->LINHA == "L02"
					If KD08->LINHA2 < KD08->LINHA1
						yfGrvOk := .F.
					EndIf
				EndIf
			EndIf
			KD08->(dbCloseArea())
			Ferase(KDIndex+GetDBExtension())
			Ferase(KDIndex+OrdBagExt())

		EndIf

		If yfGrvOk

			// Melhoria implementada em 18/02/16
			xhPseco := QY04->PSECO
			xhCapac := QY04->CAPACID
			If cEmpAnt == "14"
				xhPseco := Posicione("SB1", 1, xFilial("SB1")+QY04->PRODUT, "B1_PESO")
			EndIf

			dbSelectArea("Z57")
			dbSetOrder(1)
			If !dbSeek(xFilial("Z57") + dtos(MV_PAR02) + QY04->PRODUT + QY04->LINHA)
				Reclock("Z57",.T.)
				Z57->Z57_FILIAL := xFilial("Z57")
			Else
				Reclock("Z57",.F.)
			EndIf
			Z57->Z57_DATARF  := MV_PAR02
			Z57->Z57_PRODUT  := QY04->PRODUT
			Z57->Z57_LINHA   := QY04->LINHA
			Z57->Z57_CAPACI  := xhCapac
			Z57->Z57_PSECO   := xhPseco
			Z57->Z57_QTDRAC  := QY04->QTDRAC
			Z57->Z57_GMCD    := "S"
			Z57->Z57_SEQUEN  := msSequenc
			MsUnlock()
		EndIf

		dbSelectArea("QY04")
		dbSkip()

	End

	QY04->(dbCloseArea())
	Ferase(QYIndex+GetDBExtension())
	Ferase(QYIndex+OrdBagExt())

	// Melhoria implementada em 18/02/16
	If cEmpAnt == "14"
		xhDiasMes := Val(Substr(dtoc(UltimoDia(MV_PAR02)),1,2))
		// Tratativa implementada em 16/03/2016 porque a área de custo identificou que o valor ficou diferente no SAP porque neste ultimo foi fixado 28 dias para cálculo.
		If Substr(dtos(MV_PAR02), 5, 2) == "02" .and. xhDiasMes == 29
			xhDiasMes := 28
		EndIf
		UX009 := " UPDATE " + RetSqlName("Z57") + " "
		UX009 += "    SET Z57_CAPACI = (SELECT SUM(XZ57.Z57_QTDRAC) "
		UX009 += "                        FROM " + RetSqlName("Z57") + " XZ57 "
		UX009 += "                       WHERE XZ57.Z57_FILIAL = '" + xFilial("Z57") + "' "
		UX009 += "                         AND XZ57.Z57_DATARF = '" + dtos(MV_PAR02) + "' "
		UX009 += "                         AND XZ57.Z57_LINHA = Z57.Z57_LINHA "
		UX009 += "                         AND XZ57.D_E_L_E_T_ = ' ') / " + Alltrim(Str(xhDiasMes)) + " "
		UX009 += "   FROM " + RetSqlName("Z57") + " Z57 "
		UX009 += "  WHERE Z57_FILIAL = '" + xFilial("Z57") + "' "
		UX009 += "    AND Z57_DATARF = '" + dtos(MV_PAR02) + "' "
		UX009 += "    AND D_E_L_E_T_ = ' ' "
		U_BIAMsgRun("Capacidade produtiva Vitcer...",,{|| TcSQLExec(UX009)})
	EndIf

	// Em 08/03/17... Por Marcos Alberto Soprani... para atender a fabricação de RODAPE na Biancogres
	xhDiasMes := Val(Substr(dtoc(UltimoDia(MV_PAR02)),1,2))
	If Substr(dtos(MV_PAR02), 5, 2) == "02" .and. xhDiasMes == 29
		xhDiasMes := 28
	EndIf
	UY009 := " UPDATE " + RetSqlName("Z57") + " "
	UY009 += "    SET Z57_CAPACI = (SELECT SUM(XZ57.Z57_QTDRAC) "
	UY009 += "                        FROM " + RetSqlName("Z57") + " XZ57 "
	UY009 += "                       INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
	UY009 += "                                            AND B1_COD = Z57_PRODUT "
	UY009 += "                                            AND B1_YTPPROD = 'RP' "
	UY009 += "                                            AND SB1.D_E_L_E_T_ = ' ' "
	UY009 += "                       WHERE XZ57.Z57_FILIAL = '" + xFilial("Z57") + "' "
	UY009 += "                         AND XZ57.Z57_DATARF = '" + dtos(MV_PAR02) + "' "
	UY009 += "                         AND XZ57.Z57_LINHA = Z57.Z57_LINHA "
	UY009 += "                         AND XZ57.D_E_L_E_T_ = ' ') / " + Alltrim(Str(xhDiasMes)) + " "
	UY009 += "   FROM " + RetSqlName("Z57") + " Z57 "
	UY009 += "   INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
	UY009 += "                        AND B1_COD = Z57_PRODUT "
	UY009 += "                        AND B1_YTPPROD = 'RP' "
	UY009 += "                        AND SB1.D_E_L_E_T_ = ' ' "
	UY009 += "  WHERE Z57_FILIAL = '" + xFilial("Z57") + "' "
	UY009 += "    AND Z57_DATARF = '" + dtos(MV_PAR02) + "' "
	UY009 += "    AND Z57.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Capacidade produtiva RODAPE...",,{|| TcSQLExec(UY009)})

	U_BIA519V()

	Aviso('BIA519', 'Processamento executado com sucesso (1)', {'Ok'} )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA519V  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 07.07.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Verifica se a apropriação do realizado foi feito correto   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA519V()

	Processa({|| RptvDetail()})

Return

Static Function RptvDetail()

	dbSelectArea("Z57")

	cHInicio := Time()
	fPerg := "BIA519C"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Problema com a gravação do realizado para Ajustado"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANTIDADE"      ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCRIC"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FORMATO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "BASE"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ACABAM"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ESPESS"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TIPO"            ,1,1)

	RT006 := " SELECT TBARC.*, "
	RT006 += "        SUBSTRING(B1_DESC,1,50) DESCR, "
	RT006 += "        B1_YFORMAT, "
	RT006 += "        B1_YBASE, "
	RT006 += "        B1_YACABAM, "
	RT006 += "        B1_YESPESS, "
	RT006 += "        B1_TIPO "
	RT006 += "   FROM (SELECT PRODUT, "
	RT006 += "                ROUND(SUM(QTD),2) QTD "
	RT006 += "           FROM (SELECT Z57_PRODUT PRODUT, "
	RT006 += "                        SUM(Z57_QTDRAC) * (-1) QTD "
	RT006 += "                   FROM " + RetSqlName("Z57") + " Z57(NOLOCK) "
	RT006 += "                  WHERE Z57_FILIAL = '" + xFilial("Z57") + "' "
	RT006 += "                    AND Z57_DATARF BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	RT006 += "                    AND Z57.D_E_L_E_T_ = ' ' "
	RT006 += "                  GROUP BY Z57_PRODUT "
	RT006 += "                  UNION ALL "
	RT006 += "                 SELECT D3COD PRODUT, "
	RT006 += "                        SUM(D3QUANT) QTD "
	RT006 += "                   FROM (SELECT D3_COD D3COD, "
	RT006 += "                                D3_TM D3TM, "
	RT006 += "                                CASE "
	RT006 += "                                  WHEN D3_TM > '500' THEN SUM(D3_QUANT) * (-1) "
	RT006 += "                                  ELSE SUM(D3_QUANT) "
	RT006 += "                                END D3QUANT "
	RT006 += "                           FROM " + RetSqlName("SD3") + " SD3(NOLOCK) "
	RT006 += "                          WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	RT006 += "                            AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	If cEmpAnt == "01"
		RT006 += "                            AND D3_TIPO IN('PA','PP') "
	ElseIf cEmpAnt == "06"
		RT006 += "                            AND D3_TIPO IN('MP','PI','PA') "
	EndIf
	RT006 += "                            AND D3_TM IN('010','711') "
	RT006 += "                            AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	RT006 += "                            AND D3_ESTORNO = ' ' "
	RT006 += "                            AND D_E_L_E_T_ = ' ' "
	RT006 += "                          GROUP BY D3_COD, "
	RT006 += "                                   D3_TM) AS TABCF "
	RT006 += "                   GROUP BY D3COD "
	RT006 += "                 ) AS TRACR "
	RT006 += "         GROUP BY PRODUT "
	RT006 += "         ) AS TBARC "
	RT006 += " INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
	RT006 += "                       AND B1_COD = PRODUT "
	RT006 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	RT006 += "   WHERE QTD <> 0 "
	RTcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT006),'RT06',.F.,.T.)
	dbSelectArea("RT06")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento1")

		oExcel:AddRow(nxPlan, nxTabl, { RT06->PRODUT,;
		RT06->QTD                                   ,;
		RT06->DESCR                                 ,;
		RT06->B1_YFORMAT                            ,;
		RT06->B1_YBASE                              ,;
		RT06->B1_YACABAM                            ,;
		RT06->B1_YESPESS                            ,;
		RT06->B1_TIPO                               })

		dbSelectArea("RT06")
		dbSkip()

	End

	RT06->(dbCloseArea())
	Ferase(RTcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(RTcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "fechamento - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)

	If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
		Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

	cCrLf := Chr(13) + Chr(10)
	If ! ApOleClient( 'MsExcel' )
		MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
	Else
		oExcel:= MsExcel():New()
		oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
		oExcel:SetVisible(.T.)
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Dt Ini                   ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Dt Fim                   ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
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

	dbSelectArea(_sAlias)

Return

static function fOpcoes(cAlias,nReg,nOpc)

	private cAliasX	:= cAlias
	private nRegX	:= nReg
	private nOpcX	:= nOpc
	private bTudoOK := {|| fTuudoOK(cAliasX,nRegX,nOpcX)} 

	do case
		case nOpc == 3
		AxInclui(cAlias,nReg,nOpc,Nil,Nil,Nil,"EVAL(bTudoOK)")
		case nOpc == 4
		ExecBlock("BIA519C",.F.,.F.)
	endcase

return

static function fTuudoOK(cAlias,nReg,nOpc)

	local lRet	:= .T.

	if lRet
		lRet := U_BiaULRAC(M->Z57_DATARF)
	endif

return lRet
