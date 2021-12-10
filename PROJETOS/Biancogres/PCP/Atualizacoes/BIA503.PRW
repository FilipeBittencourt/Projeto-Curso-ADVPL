#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA503
@author Marcos Alberto Soprani
@since 06/08/14
@version 1.0
@description Browser para acompanhamento da Produção Prevista Ajustada
@type function
/*/

/*/{Protheus.doc} BIA503
@author Artur Antunes
@since 19/04/17
@version 1.1
@description Inclusão de controle de processamento via SX6 (MV_YULRAC) 
@obs OS 2304-16
@type function
/*/

User Function BIA503()

	Private msEnter   := CHR(13) + CHR(10)

	dbSelectArea("SX2")
	dbSeek("Z44")

	cCadastro := Upper(Alltrim(SX2->X2_NOME))
	aRotina   := { {"Pesquisar"           ,"AxPesqui"	                         ,0,1},;
	{               "Visualizar"          ,"AxVisual"	                         ,0,2},;
	{               "1.Atualiza Itcus"    ,'ExecBlock("BIA503C",.F.,.F.)'        ,0,3},;
	{               "2.Qtd p/ RAC"        ,'ExecBlock("BIA505",.F.,.F.)'         ,0,3},;
	{               "3.Itcus s/ Qtd"      ,'ExecBlock("BIA503B",.F.,.F.)'        ,0,3},;
	{               "4.Etq Canc p/RAC"    ,'ExecBlock("BIA503T",.F.,.F.)'        ,0,3},;
	{               "5.Redutor de C1"     ,'ExecBlock("BIA503D",.F.,.F.)'        ,0,3},;
	{               "6.Preencher Lacunas" ,'ExecBlock("BIA503P",.F.,.F.)'        ,0,3},;
	{               "7.Atu.Delta SAP"     ,'ExecBlock("BIA503S",.F.,.F.)'        ,0,3} }

	dbSelectArea(SX2->X2_CHAVE)
	dbSetOrder(1)
	dbGoTop()

	mBrowse(06,01,22,75,SX2->X2_CHAVE)

	dbSelectArea(SX2->X2_CHAVE)

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA503C  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.09.14 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Atualiza D3_YITCUS  - PRIMEIRO PROCESSAMENTO               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA503C()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	cHInicio := Time()

	xdAnoMes := space(006)
	If !fPergHotB()
		MsgSTOP("Processo Abortado!!!")
		Return
	EndIf
	MV_PAR01 := xdAnoMes

	kfDataDe  := stod(MV_PAR01+"01")
	kfDataAte := Ultimodia(kfDataDe)

	if !U_BiaULRAC(kfDataDe)
		Return
	endif

	//                               Zera Valores para que não ocorra erros em caso se reprocessamento
	**************************************************************************************************
	ZP003 := " UPDATE " + RetSqlName("SD3") + " SET D3_YITCUS = '   ' "
	ZP003 += "   FROM " + RetSqlName("SD3") + " WITH (NOLOCK) "
	ZP003 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	ZP003 += "    AND D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "' "
	ZP003 += "    AND D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Zerando Item de Custo nas movimentações internas",,{|| TCSQLExec(ZP003)})

	//                                 Necessário para resolver questão da Venda Intragrupo / Produção
	**************************************************************************************************
	If cEmpAnt == "05"
		SX003 := " WITH PDEMAND AS (SELECT D3_OP NUMOP "
		SX003 += "                    FROM " + RetSqlName("SD3") + " "
		SX003 += "                   WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
		SX003 += "                     AND D3_EMISSAO BETWEEN '"+dtos(kfDataDe)+"' AND '"+dtos(kfDataAte)+"' "
		SX003 += "                     AND D3_TM = '010' "
		SX003 += "                     AND D3_TIPO = 'PA' "
		SX003 += "                     AND D3_YRFCUST = 'PRODUCTION ON DEMAND' "
		SX003 += "                     AND D_E_L_E_T_ = ' ') "
		SX003 += " UPDATE " + RetSqlName("SD3") + " SET D3_YRFCUST = 'PRODUCTION ON DEMAND' "
		SX003 += "   FROM " + RetSqlName("SD3") + " SD3 "
		SX003 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
		SX003 += "    AND D3_EMISSAO BETWEEN '"+dtos(kfDataDe)+"' AND '"+dtos(kfDataAte)+"' "
		SX003 += "    AND D3_TM <> '010' "
		SX003 += "    AND SD3.D_E_L_E_T_ = ' ' "
		SX003 += "    AND SD3.D3_OP IN(SELECT NUMOP "
		SX003 += "                       FROM PDEMAND) "
	EndIf

	US002 := " UPDATE " + RetSqlName("SD3") + " SET D3_YITCUS = "
	US002 += "        CASE "
	US002 += "          WHEN D3_CLVL = '3180' THEN CTH_YITCUS "
	US002 += "          WHEN SB1.B1_YITCUS <> '   ' THEN SB1.B1_YITCUS "
	US002 += "          WHEN ZB1.B1_YITCUS <> '   ' THEN ZB1.B1_YITCUS "
	US002 += "          WHEN D3_TM = '010'      THEN '001' "
	US002 += "          WHEN D3_TM = '999' AND D3_TIPO IN('PA','PS') THEN '065' "
	If cEmpAnt == "06"
		US002 += "          WHEN D3_TIPO IN('MP') AND SUBSTRING(D3_COD, 4, 2) = '00' THEN '003' "
		US002 += "          WHEN D3_TIPO IN('PI') AND SUBSTRING(D3_COD, 4, 2) = '50' THEN '006' "
		US002 += "          WHEN D3_TIPO IN('PI') AND SUBSTRING(D3_COD, 4, 2) = '80' THEN '007' "
	EndIf
	US002 += "          ELSE CT1_YITCUS "
	US002 += "        END "
	US002 += "   FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK) "
	US002 += "  INNER JOIN " + RetSqlName("SC2") + " SC2 ON C2_FILIAL = '" + xFilial("SC2") + "' "
	US002 += "                       AND C2_NUM = SUBSTRING(D3_OP,1,6) "
	US002 += "                       AND C2_ITEM = SUBSTRING(D3_OP,7,2) "
	US002 += "                       AND C2_SEQUEN = SUBSTRING(D3_OP,9,3) "
	US002 += "                       AND SC2.D_E_L_E_T_ = ' ' "
	US002 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	US002 += "                       AND SB1.B1_COD = C2_PRODUTO "
	If cEmpAnt $ "01"
		US002 += "                       AND SB1.B1_TIPO IN('PP','PA','PS') "
	ElseIf cEmpAnt == "06"
		US002 += "                       AND SB1.B1_TIPO IN('MP','PI','PA') "
	EndIf
	US002 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	US002 += "   LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH_FILIAL = '" + xFilial("CTH") + "' "
	US002 += "                       AND CTH_CLVL = D3_CLVL "
	US002 += "                       AND CTH.D_E_L_E_T_ = ' ' "
	US002 += "   LEFT JOIN " + RetSqlName("CT1") + " CT1 ON CT1_FILIAL = '" + xFilial("CT1") + "' "
	US002 += "                       AND CT1_CONTA = D3_CONTA "
	US002 += "                       AND CT1.D_E_L_E_T_ = ' ' "
	US002 += "  INNER JOIN " + RetSqlName("SB1") + " ZB1 ON ZB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	US002 += "                       AND ZB1.B1_COD = D3_COD "
	US002 += "                       AND ZB1.D_E_L_E_T_ = ' ' "
	US002 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	US002 += "    AND D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "' "
	US002 += "    AND D3_OP <> '             ' "
	US002 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	US002 += "    AND SD3.D_E_L_E_T_ = ' ' "

	U_BIAMsgRun("Aguarde... Atualizando Item de Custo nas movimentações internas",,{|| TcSQLExec(US002)})

	lsxControl := 0
	LS002 := " SELECT COUNT(*) CONTAD "
	LS002 += "   FROM " + RetSqlName("SD3") + " SD3 " 
	LS002 += "  INNER JOIN " + RetSqlName("SC2") + " SC2 ON C2_FILIAL = '" + xFilial("SC2") + "'
	LS002 += "                       AND C2_NUM = SUBSTRING(D3_OP,1,6) "
	LS002 += "                       AND C2_ITEM = SUBSTRING(D3_OP,7,2) "
	LS002 += "                       AND C2_SEQUEN = SUBSTRING(D3_OP,9,3) "
	LS002 += "                       AND SC2.D_E_L_E_T_ = ' ' "
	LS002 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	LS002 += "                       AND SB1.B1_COD = C2_PRODUTO "
	If cEmpAnt $ "01"
		LS002 += "                       AND SB1.B1_TIPO IN('PP','PA','PS') "
	ElseIf cEmpAnt == "06"
		LS002 += "                       AND SB1.B1_TIPO IN('MP','PI','PA') "
	EndIf
	LS002 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	LS002 += "   LEFT JOIN " + RetSqlName("CTH") + " CTH ON CTH_FILIAL = '" + xFilial("CTH") + "' "
	LS002 += "                       AND CTH_CLVL = D3_CLVL "
	LS002 += "                       AND CTH.D_E_L_E_T_ = ' ' "
	LS002 += "   LEFT JOIN " + RetSqlName("CT1") + " CT1 ON CT1_FILIAL = '" + xFilial("CT1") + "' "
	LS002 += "                       AND CT1_CONTA = D3_CONTA "
	LS002 += "                       AND CT1.D_E_L_E_T_ = ' ' "
	LS002 += "  INNER JOIN " + RetSqlName("SB1") + " ZB1 ON ZB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	LS002 += "                       AND ZB1.B1_COD = D3_COD "
	LS002 += "                       AND ZB1.D_E_L_E_T_ = ' ' "
	LS002 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	LS002 += "    AND D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "' "
	LS002 += "    AND D3_OP <> '             ' "
	LS002 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	LS002 += "    AND D3_YITCUS = '   ' "
	LS002 += "    AND SD3.D_E_L_E_T_ = ' ' "
	LSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,LS002),'LS02',.T.,.T.)
	dbSelectArea("LS02")
	dbGoTop()
	If !Eof()
		lsxControl := LS02->CONTAD
	End

	LS02->(dbCloseArea())
	Ferase(LSIndex+GetDBExtension())
	Ferase(LSIndex+OrdBagExt())

	If lsxControl > 0

		MsgINFO("Foram identificados registros no SD3 que não receberam ItCus. Portanto, será necessário verificar antes de continuar!!!")
		Return

	EndIf

	US003 := " UPDATE " + RetSqlName("SD3") + " SET D3_YITCUS = "
	US003 += "        CASE "
	US003 += "          WHEN F5_YITCUS <> '   ' THEN F5_YITCUS "
	US003 += "          ELSE '   ' "
	US003 += "        END "
	US003 += "   FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK) "
	US003 += "  INNER JOIN " + RetSqlName("SF5") + " SF5 ON F5_FILIAL = '" + xFilial("SF5") + "' "
	US003 += "                       AND F5_CODIGO = D3_TM "
	US003 += "                       AND F5_QTDZERO = '1' "
	US003 += "                       AND F5_VAL = 'S' "
	US003 += "                       AND SF5.D_E_L_E_T_ = ' ' "
	US003 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	US003 += "    AND D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "' "
	US003 += "    AND D3_OP = '             ' "
	US003 += "    AND D3_TM IN('352','353') "
	US003 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	US003 += "    AND SD3.D_E_L_E_T_ = ' ' "

	U_BIAMsgRun("Aguarde... Atualizando Item de Custo nas movimentações internas - Valorizadas",,{|| TcSQLExec(US003)})

	Aviso('BIA503C','Fim do PRIMEIRO Processamento...',{'Ok'})

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA503B  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 02.09.14 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Processamento para gravação da quantidade produzida para   ¦¦¦
¦¦¦          ¦ Itens de Custo que não receberam custo no decorrer do mês  ¦¦¦
¦¦¦          ¦ QUARTO PROCESSAMENTO                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA503B()

	Processa({|| zRptDetail()})

Return

Static Function zRptDetail()

	Private msEnter := CHR(13) + CHR(10)

	Public kfDataDe
	Public kfDataAte

	cHInicio := Time()

	xdAnoMes := space(006)
	If !fPergHotB()
		MsgSTOP("Processo Abortado!!!")
		Return
	EndIf
	MV_PAR01 := xdAnoMes

	kfDataDe  := stod(MV_PAR01+"01")
	kfDataAte := Ultimodia(kfDataDe)

	If !U_BiaULRAC(kfDataDe)
		Return
	EndIf

	//                               Zera Valores para que não ocorra erros em caso se reprocessamento
	**************************************************************************************************
	ZP003 := " DELETE " + RetSqlName("Z44")
	ZP003 += "   FROM " + RetSqlName("Z44") + " WITH (NOLOCK)
	ZP003 += "  WHERE Z44_FILIAL = '" + xFilial("Z44") + "'
	ZP003 += "    AND Z44_DATARF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'
	ZP003 += "    AND D_E_L_E_T_ = ' '
	U_BIAMsgRun("Aguarde... Zerando valores...",,{|| TCSQLExec(ZP003)})

	If 1 == 2 // Tratamento para saltar estas lacunas - apresentou problema no mês de outubro de 2021...

		//                                               Completa lacunas para os itens de custo sem custo
		**************************************************************************************************
		GR001 := " WITH ETQCANC AS (SELECT D3_COD PROD, SUM(D3_QUANT) * (-1) QTDCAN
		GR001 += "                    FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)
		GR001 += "                   WHERE D3_FILIAL = '" + xFilial("SD3") + "'
		GR001 += "                     AND D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'
		GR001 += "                     AND D3_TIPO IN('PP','PA')
		GR001 += "                     AND D3_TM = '711'
		GR001 += "                     AND D3_ESTORNO = ' '
		GR001 += "                     AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
		GR001 += "                     AND D_E_L_E_T_ = ' '
		GR001 += "                   GROUP BY D3_COD),
		GR001 += "      RACREF AS (SELECT A.REFERENCIA, 
		GR001 += "                        A.ITCUS, 
		GR001 += "                        QUANT = SUM(A.QUANT)
		GR001 += "                 FROM VW_BI_F_RACFULL A
		GR001 += "                 WHERE DATAREF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'
		GR001 += "                       AND VERSAO = '001'
		GR001 += "                 GROUP BY A.REFERENCIA, 
		GR001 += "                          A.ITCUS)
		GR001 += " SELECT D3_COD,
		GR001 += "        D3_TIPO,
		GR001 += "        D3_YITCUS,
		GR001 += "        ISNULL(DATAREF, '        ') DATAREF,
		GR001 += "        ISNULL(TPPROD, '  ') TPPROD,
		GR001 += "        ISNULL(COD, '               ') COD,
		GR001 += "        ISNULL(ITCUS, '   ') ITCUS,
		GR001 += "        ISNULL(CUSTO1, 0) CUSTO1,
		GR001 += "        ISNULL(QUANT, 0) QUANT
		GR001 += "   FROM (SELECT DISTINCT D3_COD,
		GR001 += "                D3_TIPO,
		GR001 += "                D3_YITCUS
		GR001 += "           FROM (SELECT D3_YITCUS,
		GR001 += "                        B1_TIPO
		GR001 += "                   FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)
		GR001 += "                  INNER JOIN " + RetSqlName("Z29") + " Z29 WITH (NOLOCK) ON Z29_COD_IT = SD3.D3_YITCUS
		GR001 += "                                                     AND Z29_TIPO IN('CV','Q ')
		GR001 += "                                                     AND Z29.D_E_L_E_T_ = ' '
		GR001 += "                  INNER JOIN " + RetSqlName("SC2") + " SC2 WITH (NOLOCK) ON C2_FILIAL = '" + xFilial("SC2") + "'
		GR001 += "                                                     AND C2_NUM = SUBSTRING(D3_OP,1,6)
		GR001 += "                                                     AND C2_ITEM = SUBSTRING(D3_OP,7,2)
		GR001 += "                                                     AND C2_SEQUEN = SUBSTRING(D3_OP,9,3)
		GR001 += "                                                     AND SC2.D_E_L_E_T_ = ' '
		GR001 += "                  INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON B1_COD = C2_PRODUTO
		If cEmpAnt $ "01"
			GR001 += "                                                     AND B1_TIPO IN('PA','PS','PP')
		ElseIf cEmpAnt == "06"
			GR001 += "                                                     AND B1_TIPO IN('MP','PI','PA')
		EndIf
		GR001 += "                                                     AND SB1.D_E_L_E_T_ = ' '
		GR001 += "                  WHERE D3_FILIAL = '" + xFilial("SD3") + "'
		GR001 += "                    AND D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'
		GR001 += "                    AND D3_YITCUS <> '   '
		GR001 += "                    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
		GR001 += "                    AND SD3.D_E_L_E_T_ = ' '
		GR001 += "                  GROUP BY D3_YITCUS, B1_TIPO) AS TABL
		GR001 += "          INNER JOIN (SELECT D3_COD,
		GR001 += "                             D3_TIPO
		GR001 += "                        FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)
		GR001 += "                       WHERE D3_FILIAL = '" + xFilial("SD3") + "'
		GR001 += "                         AND D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'
		GR001 += "                         AND D3_TM = '010'
		If cEmpAnt $ "01"
			GR001 += "                         AND D3_TIPO IN('PA','PS','PP')
		ElseIf cEmpAnt == "06"
			GR001 += "                         AND D3_TIPO IN('MP','PI','PA')
		EndIf
		GR001 += "                         AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
		GR001 += "                         AND SD3.D_E_L_E_T_ = ' '
		GR001 += "                       GROUP BY D3_COD, D3_TIPO) TAB2L ON D3_TIPO = B1_TIPO) AS TAB3X
		GR001 += "   LEFT JOIN (SELECT DATAREF,
		GR001 += "                     TPPROD,
		GR001 += "                     COD,
		GR001 += "                     ITCUS,
		GR001 += "                     CUSTO1,
		GR001 += "                     QUANT + ISNULL(QTDCAN, 0) QUANT
		GR001 += "                FROM (SELECT SUBSTRING(D3_EMISSAO,1,6)+'01' DATAREF,
		GR001 += "                             B1_TIPO TPPROD,
		GR001 += "                             C2_PRODUTO COD,
		GR001 += "                             D3_YITCUS ITCUS,
		GR001 += "                             SUM(D3_CUSTO1) CUSTO1,
		GR001 += "                             SUM(D3_YQTDPAC) QUANT
		GR001 += "                        FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)
		GR001 += "                       INNER JOIN " + RetSqlName("SC2") + " SC2 WITH (NOLOCK) ON C2_FILIAL = '" + xFilial("SC2") + "'
		GR001 += "                                                          AND C2_NUM = SUBSTRING(D3_OP,1,6)
		GR001 += "                                                          AND C2_ITEM = SUBSTRING(D3_OP,7,2)
		GR001 += "                                                          AND C2_SEQUEN = SUBSTRING(D3_OP,9,3)
		GR001 += "                                                          AND SC2.D_E_L_E_T_ = ' '
		GR001 += "                       INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON B1_COD = C2_PRODUTO
		If cEmpAnt $ "01"
			GR001 += "                                                          AND B1_TIPO IN('PA','PS','PP')
		ElseIf cEmpAnt == "06"
			GR001 += "                                                          AND B1_TIPO IN('MP','PI','PA')
		EndIf
		GR001 += "                                                          AND SB1.D_E_L_E_T_ = ' '
		GR001 += "                       WHERE D3_FILIAL = '" + xFilial("SD3") + "'
		GR001 += "                         AND D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'
		GR001 += "                         AND D3_OP BETWEEN '0000000000000' AND 'ZZZZZZZZZZZZZ'
		GR001 += "                         AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
		GR001 += "                         AND SD3.D_E_L_E_T_ = ' '
		GR001 += "                       GROUP BY SUBSTRING(D3_EMISSAO,1,6),
		GR001 += "                                B1_TIPO,
		GR001 += "                                C2_PRODUTO,
		GR001 += "                                D3_YITCUS) AS TABLT
		GR001 += "                LEFT JOIN ETQCANC ECA WITH (NOLOCK) ON ECA.PROD = COD) CRZT ON ITCUS = D3_YITCUS
		GR001 += "                                                                           AND COD = D3_COD
		GR001 += "                                                                           AND TPPROD = D3_TIPO
		GR001 += "      WHERE NOT EXISTS
		GR001 += "      (
		GR001 += "          SELECT 0
		GR001 += "          FROM RACREF
		GR001 += "          WHERE REFERENCIA = D3_COD
		GR001 += "                AND ITCUS = D3_YITCUS
		GR001 += "      )
		GR001 += "  ORDER BY D3_COD, D3_TIPO, D3_YITCUS
		GRIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,GR001),'GR02',.T.,.T.)
		dbSelectArea("GR02")
		dbGoTop()
		ProcRegua(0)
		While GR02->(!Eof())

			gtProdt := GR02->D3_COD
			gtTpPro := GR02->D3_TIPO
			gtQtdPr := GR02->QUANT
			cvChq   := 0

			dbSelectArea("GR02")
			While GR02->(!Eof()) .and. GR02->D3_COD == gtProdt .and. GR02->D3_TIPO == gtTpPro

				cvChq  ++
				IncProc("R-Tipo: " + gtTpPro + " Prod.: " + Alltrim(gtProdt) + " " + Alltrim(Str(cvChq)))
				klRegTmp := GR02->(Recno())

				If gtQtdPr <> 0 .and. GR02->D3_YITCUS <> "001"

					dbSelectArea("Z44")
					dbSetOrder(2)
					If !dbSeek(xFilial("Z44") + dtos(kfDataAte) + gtProdt + GR02->D3_YITCUS + "999")
						RecLock("Z44",.T.)
						Z44->Z44_FILIAL := xFilial("Z44")
						Z44->Z44_DATARF := kfDataAte
						Z44->Z44_COD    := gtProdt
						Z44->Z44_ITCUS  := GR02->D3_YITCUS
						Z44->Z44_TM     := "999"
						Z44->Z44_CF     := "RQ"
						Z44->Z44_CONTA  := ""
						Z44->Z44_RFPROD := gtProdt
						Z44->Z44_TPPROD := gtTpPro
						Z44->Z44_QUANT  := gtQtdPr
						Z44->Z44_CUSTO1 := 0
						Z44->Z44_FLAG   := "X"
						MsUnLockAll()
					EndIf

				EndIf

				dbSelectArea("GR02")
				dbGoTo(klRegTmp)
				GR02->(dbSkip())

			End

			dbSelectArea("GR02")

		End

		GR02->(dbCloseArea())
		Ferase(GRIndex+GetDBExtension())
		Ferase(GRIndex+OrdBagExt())

		//                           Completa lacunas para os itens de custo sem custo - Segunda tratativa
		**************************************************************************************************
		GR003 := Alltrim(" WITH ITEMCUSTO                                                                                                                                                    ") + msEnter
		GR003 += Alltrim("      AS (SELECT TPCUS = Z29_TIPO,                                                                                                                                 ") + msEnter
		GR003 += Alltrim("                 TPPROD = Z29_APLTPP,                                                                                                                              ") + msEnter
		GR003 += Alltrim("                 ITCUS = Z29_COD_IT,                                                                                                                               ") + msEnter
		GR003 += Alltrim("                 DITCUS = Z29_DESCR,                                                                                                                               ") + msEnter
		GR003 += Alltrim("                 RESUM = Z29_DRESUM                                                                                                                                ") + msEnter
		GR003 += Alltrim("          FROM " + RetSqlName("Z29") + " Z29(NOLOCK)                                                                                                               ") + msEnter
		GR003 += Alltrim("          WHERE Z29_FILIAL = '" + xFilial("Z29") + "'                                                                                                              ") + msEnter
		GR003 += Alltrim("                AND Z29_EMPUSO LIKE '%" + cEmpAnt + "%'                                                                                                            ") + msEnter
		GR003 += Alltrim("                AND Z29_ATIVO = 'S'                                                                                                                                ") + msEnter
		GR003 += Alltrim("                AND Z29_TIPO <> 'Q '                                                                                                                               ") + msEnter
		GR003 += Alltrim("                AND Z29_APLTPP <> 'XX'                                                                                                                             ") + msEnter
		GR003 += Alltrim("                AND Z29.D_E_L_E_T_ = ' '                                                                                                                           ") + msEnter
		GR003 += Alltrim("          UNION ALL                                                                                                                                                ") + msEnter
		GR003 += Alltrim("          SELECT TPCUS = Z29_TIPO,                                                                                                                                 ") + msEnter
		GR003 += Alltrim("                 TPPROD = 'PP',                                                                                                                                    ") + msEnter
		GR003 += Alltrim("                 ITCUS = Z29_COD_IT,                                                                                                                               ") + msEnter
		GR003 += Alltrim("                 DITCUS = Z29_DESCR,                                                                                                                               ") + msEnter
		GR003 += Alltrim("                 RESUM = Z29_DRESUM                                                                                                                                ") + msEnter
		GR003 += Alltrim("          FROM " + RetSqlName("Z29") + " Z29(NOLOCK)                                                                                                               ") + msEnter
		GR003 += Alltrim("          WHERE Z29_FILIAL = '" + xFilial("Z29") + "'                                                                                                              ") + msEnter
		GR003 += Alltrim("                AND Z29_EMPUSO LIKE '%" + cEmpAnt + "%'                                                                                                            ") + msEnter
		GR003 += Alltrim("                AND Z29_ATIVO = 'S'                                                                                                                                ") + msEnter
		GR003 += Alltrim("                AND Z29_TIPO <> 'Q '                                                                                                                               ") + msEnter
		GR003 += Alltrim("                AND Z29_APLTPP = 'XX'                                                                                                                              ") + msEnter
		GR003 += Alltrim("                AND Z29.D_E_L_E_T_ = ' '                                                                                                                           ") + msEnter
		GR003 += Alltrim("          UNION ALL                                                                                                                                                ") + msEnter
		GR003 += Alltrim("          SELECT TPCUS = Z29_TIPO,                                                                                                                                 ") + msEnter
		GR003 += Alltrim("                 TPPROD = 'PA',                                                                                                                                    ") + msEnter
		GR003 += Alltrim("                 ITCUS = Z29_COD_IT,                                                                                                                               ") + msEnter
		GR003 += Alltrim("                 DITCUS = Z29_DESCR,                                                                                                                               ") + msEnter
		GR003 += Alltrim("                 RESUM = Z29_DRESUM                                                                                                                                ") + msEnter
		GR003 += Alltrim("          FROM " + RetSqlName("Z29") + " Z29(NOLOCK)                                                                                                               ") + msEnter
		GR003 += Alltrim("          WHERE Z29_FILIAL = '" + xFilial("Z29") + "'                                                                                                              ") + msEnter
		GR003 += Alltrim("                AND Z29_EMPUSO LIKE '%" + cEmpAnt + "%'                                                                                                            ") + msEnter
		GR003 += Alltrim("                AND Z29_ATIVO = 'S'                                                                                                                                ") + msEnter
		GR003 += Alltrim("                AND Z29_TIPO <> 'Q '                                                                                                                               ") + msEnter
		GR003 += Alltrim("                AND Z29_APLTPP = 'XX'                                                                                                                              ") + msEnter
		GR003 += Alltrim("                AND Z29.D_E_L_E_T_ = ' '),                                                                                                                         ") + msEnter
		GR003 += Alltrim("      PRODUCAO                                                                                                                                                     ") + msEnter
		GR003 += Alltrim("      AS (SELECT PRODUTO,                                                                                                                                          ") + msEnter
		GR003 += Alltrim("                 TPPROD                                                                                                                                            ") + msEnter
		GR003 += Alltrim("          FROM                                                                                                                                                     ") + msEnter
		GR003 += Alltrim("          (                                                                                                                                                        ") + msEnter
		GR003 += Alltrim("              SELECT PRODUTO = SC2.C2_PRODUTO,                                                                                                                     ") + msEnter
		GR003 += Alltrim("                     TPPROD = SB1.B1_TIPO                                                                                                                          ") + msEnter
		GR003 += Alltrim("              FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK)                                                                                                      ") + msEnter
		GR003 += Alltrim("                   INNER JOIN " + RetSqlName("SC2") + " SC2 WITH(NOLOCK) ON SC2.C2_FILIAL = SD3.D3_FILIAL                                                          ") + msEnter
		GR003 += Alltrim("                                                         AND SC2.C2_NUM = SUBSTRING(SD3.D3_OP, 1, 6)                                                               ") + msEnter
		GR003 += Alltrim("                                                         AND SC2.C2_ITEM = SUBSTRING(SD3.D3_OP, 7, 2)                                                              ") + msEnter
		GR003 += Alltrim("                                                         AND SC2.C2_SEQUEN = SUBSTRING(SD3.D3_OP, 9, 3)                                                            ") + msEnter
		GR003 += Alltrim("                                                         AND SC2.D_E_L_E_T_ = ' '                                                                                  ") + msEnter
		GR003 += Alltrim("                   INNER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'                                               ") + msEnter
		GR003 += Alltrim("                                                         AND SB1.B1_COD = SC2.C2_PRODUTO                                                                           ") + msEnter
		GR003 += Alltrim("                                                         AND SB1.B1_TIPO IN('PP', 'PA', 'PS')                                                                      ") + msEnter
		GR003 += Alltrim("                                                         AND SB1.D_E_L_E_T_ = ' '                                                                                  ") + msEnter
		GR003 += Alltrim("              WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                                                       ") + msEnter
		GR003 += Alltrim("                    AND SD3.D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                              ") + msEnter
		GR003 += Alltrim("                    AND NOT(SD3.D3_TM IN('010', '999')                                                                                                             ") + msEnter
		GR003 += Alltrim("              AND SD3.D3_TIPO = 'PP')                                                                                                                              ") + msEnter
		GR003 += Alltrim("                   AND SD3.D_E_L_E_T_ = ' '                                                                                                                        ") + msEnter
		GR003 += Alltrim("              GROUP BY SC2.C2_PRODUTO,                                                                                                                             ") + msEnter
		GR003 += Alltrim("                       SB1.B1_TIPO                                                                                                                                 ") + msEnter
		GR003 += Alltrim("              UNION ALL                                                                                                                                            ") + msEnter
		GR003 += Alltrim("              SELECT PRODUTO = Z44.Z44_RFPROD,                                                                                                                     ") + msEnter
		GR003 += Alltrim("                     TPPROD = Z44.Z44_TPPROD                                                                                                                       ") + msEnter
		GR003 += Alltrim("              FROM " + RetSqlName("Z44") + " Z44 WITH(NOLOCK)                                                                                                      ") + msEnter
		GR003 += Alltrim("              WHERE Z44.Z44_FILIAL = '" + xFilial("Z44") + "'                                                                                                      ") + msEnter
		GR003 += Alltrim("                    AND Z44.Z44_DATARF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                              ") + msEnter
		GR003 += Alltrim("                    AND Z44.D_E_L_E_T_ = ' '                                                                                                                       ") + msEnter
		GR003 += Alltrim("              GROUP BY Z44.Z44_RFPROD,                                                                                                                             ") + msEnter
		GR003 += Alltrim("                       Z44.Z44_TPPROD                                                                                                                              ") + msEnter
		GR003 += Alltrim("          ) AS TEMP1                                                                                                                                               ") + msEnter
		GR003 += Alltrim("          GROUP BY PRODUTO,                                                                                                                                        ") + msEnter
		GR003 += Alltrim("                   TPPROD),                                                                                                                                        ") + msEnter
		GR003 += Alltrim("      PRODITC                                                                                                                                                      ") + msEnter
		GR003 += Alltrim("      AS (SELECT PRODUTO,                                                                                                                                          ") + msEnter
		GR003 += Alltrim("                 TPPROD,                                                                                                                                           ") + msEnter
		GR003 += Alltrim("                 TPCUS,                                                                                                                                            ") + msEnter
		GR003 += Alltrim("                 QUANT = MIN(QUANT)                                                                                                                                ") + msEnter
		GR003 += Alltrim("          FROM                                                                                                                                                     ") + msEnter
		GR003 += Alltrim("          (                                                                                                                                                        ") + msEnter
		GR003 += Alltrim("              SELECT PRODUTO = SC2.C2_PRODUTO,                                                                                                                     ") + msEnter
		GR003 += Alltrim("                     TPPROD = SB1.B1_TIPO,                                                                                                                         ") + msEnter
		GR003 += Alltrim("                     TPCUS = Z29.Z29_TIPO,                                                                                                                         ") + msEnter
		GR003 += Alltrim("                     ITCUS = SD3.D3_YITCUS,                                                                                                                        ") + msEnter
		GR003 += Alltrim("                     QUANT = SUM(SD3.D3_YQTDPAC)                                                                                                                   ") + msEnter
		GR003 += Alltrim("              FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK)                                                                                                      ") + msEnter
		GR003 += Alltrim("                   INNER JOIN " + RetSqlName("SC2") + " SC2 WITH(NOLOCK) ON SC2.C2_FILIAL = SD3.D3_FILIAL                                                          ") + msEnter
		GR003 += Alltrim("                                                         AND SC2.C2_NUM = SUBSTRING(SD3.D3_OP, 1, 6)                                                               ") + msEnter
		GR003 += Alltrim("                                                         AND SC2.C2_ITEM = SUBSTRING(SD3.D3_OP, 7, 2)                                                              ") + msEnter
		GR003 += Alltrim("                                                         AND SC2.C2_SEQUEN = SUBSTRING(SD3.D3_OP, 9, 3)                                                            ") + msEnter
		GR003 += Alltrim("                                                         AND SC2.D_E_L_E_T_ = ' '                                                                                  ") + msEnter
		GR003 += Alltrim("                   INNER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'                                               ") + msEnter
		GR003 += Alltrim("                                                         AND SB1.B1_COD = SC2.C2_PRODUTO                                                                           ") + msEnter
		GR003 += Alltrim("                                                         AND SB1.B1_TIPO IN('PP', 'PA', 'PS')                                                                      ") + msEnter
		GR003 += Alltrim("                                                         AND SB1.D_E_L_E_T_ = ' '                                                                                  ") + msEnter
		GR003 += Alltrim("                   INNER JOIN " + RetSqlName("Z29") + " Z29 WITH(NOLOCK) ON Z29.Z29_FILIAL = '" + xFilial("Z29") + "'                                              ") + msEnter
		GR003 += Alltrim("                                                         AND Z29.Z29_COD_IT = SD3.D3_YITCUS                                                                        ") + msEnter
		GR003 += Alltrim("                                                         AND Z29.D_E_L_E_T_ = ' '                                                                                  ") + msEnter
		GR003 += Alltrim("              WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                                                       ") + msEnter
		GR003 += Alltrim("                    AND SD3.D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                              ") + msEnter
		GR003 += Alltrim("                    AND SD3.D3_YITCUS <> '001'                                                                                                                     ") + msEnter
		GR003 += Alltrim("                    AND SD3.D_E_L_E_T_ = ' '                                                                                                                       ") + msEnter
		GR003 += Alltrim("              GROUP BY SC2.C2_PRODUTO,                                                                                                                             ") + msEnter
		GR003 += Alltrim("                       SB1.B1_TIPO,                                                                                                                                ") + msEnter
		GR003 += Alltrim("                       Z29.Z29_TIPO,                                                                                                                               ") + msEnter
		GR003 += Alltrim("                       SD3.D3_YITCUS                                                                                                                               ") + msEnter
		GR003 += Alltrim("              UNION ALL                                                                                                                                            ") + msEnter
		GR003 += Alltrim("              SELECT PRODUTO = Z44.Z44_RFPROD,                                                                                                                     ") + msEnter
		GR003 += Alltrim("                     TPPROD = Z44.Z44_TPPROD,                                                                                                                      ") + msEnter
		GR003 += Alltrim("                     TPCUS = Z29.Z29_TIPO,                                                                                                                         ") + msEnter
		GR003 += Alltrim("                     ITCUS = Z44.Z44_ITCUS,                                                                                                                        ") + msEnter
		GR003 += Alltrim("                     QUANT = Z44.Z44_QUANT                                                                                                                         ") + msEnter
		GR003 += Alltrim("              FROM " + RetSqlName("Z44") + " Z44 WITH(NOLOCK)                                                                                                      ") + msEnter
		GR003 += Alltrim("                   INNER JOIN " + RetSqlName("Z29") + " Z29(NOLOCK) ON Z29.Z29_FILIAL = '" + xFilial("Z29") + "'                                                   ") + msEnter
		GR003 += Alltrim("                                                    AND Z29.Z29_COD_IT = Z44.Z44_ITCUS                                                                             ") + msEnter
		GR003 += Alltrim("                                                    AND Z29.D_E_L_E_T_ = ' '                                                                                       ") + msEnter
		GR003 += Alltrim("              WHERE Z44.Z44_FILIAL = '" + xFilial("Z44") + "'                                                                                                      ") + msEnter
		GR003 += Alltrim("                    AND Z44.Z44_DATARF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                              ") + msEnter
		GR003 += Alltrim("                    AND Z44.D_E_L_E_T_ = ' '                                                                                                                       ") + msEnter
		GR003 += Alltrim("              GROUP BY Z44.Z44_RFPROD,                                                                                                                             ") + msEnter
		GR003 += Alltrim("                       Z44.Z44_TPPROD,                                                                                                                             ") + msEnter
		GR003 += Alltrim("                       Z29.Z29_TIPO,                                                                                                                               ") + msEnter
		GR003 += Alltrim("                       Z44.Z44_ITCUS,                                                                                                                              ") + msEnter
		GR003 += Alltrim("                       Z44.Z44_QUANT                                                                                                                               ") + msEnter
		GR003 += Alltrim("          ) AS TEMP1                                                                                                                                               ") + msEnter
		GR003 += Alltrim("          GROUP BY PRODUTO,                                                                                                                                        ") + msEnter
		GR003 += Alltrim("                   TPPROD,                                                                                                                                         ") + msEnter
		GR003 += Alltrim("                   TPCUS)                                                                                                                                          ") + msEnter
		GR003 += Alltrim("      SELECT PRC.PRODUTO,                                                                                                                                          ") + msEnter
		GR003 += Alltrim("             ITC.*,                                                                                                                                                ") + msEnter
		GR003 += Alltrim("             QUANT = ISNULL(PIT.QUANT,                                                                                                                             ") + msEnter
		GR003 += Alltrim("      (                                                                                                                                                            ") + msEnter
		GR003 += Alltrim("          SELECT MAX(XXX.QUANT)                                                                                                                                    ") + msEnter
		GR003 += Alltrim("          FROM PRODITC XXX                                                                                                                                         ") + msEnter
		GR003 += Alltrim("          WHERE XXX.PRODUTO = PRC.PRODUTO                                                                                                                          ") + msEnter
		GR003 += Alltrim("      ))                                                                                                                                                           ") + msEnter
		GR003 += Alltrim("      FROM ITEMCUSTO ITC                                                                                                                                           ") + msEnter
		GR003 += Alltrim("           INNER JOIN PRODUCAO PRC ON PRC.TPPROD = ITC.TPPROD                                                                                                      ") + msEnter
		GR003 += Alltrim("           LEFT JOIN PRODITC PIT ON PIT.PRODUTO = PRC.PRODUTO                                                                                                      ") + msEnter
		GR003 += Alltrim("                                    AND PIT.TPCUS = ITC.TPCUS                                                                                                      ") + msEnter
		GR003 += Alltrim("                                    AND PIT.TPPROD = ITC.TPPROD                                                                                                    ") + msEnter
		GR003 += Alltrim("      WHERE PIT.QUANT IS NULL                                                                                                                                      ") + msEnter
		GR003 += Alltrim("      ORDER BY PRC.PRODUTO,                                                                                                                                        ") + msEnter
		GR003 += Alltrim("               ITCUS                                                                                                                                               ") + msEnter
		G3Index := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,GR003),'GR03',.T.,.T.)
		dbSelectArea("GR03")
		dbGoTop()
		ProcRegua(0)
		While GR03->(!Eof())

			gtProdt := GR03->PRODUTO
			gtTpPro := GR03->TPPROD
			gtQtdPr := GR03->QUANT
			cvChq   := 0

			dbSelectArea("GR03")
			While GR03->(!Eof()) .and. GR03->PRODUTO == gtProdt .and. GR03->TPPROD == gtTpPro

				cvChq  ++
				IncProc("R-Tipo: " + gtTpPro + " Prod.: " + Alltrim(gtProdt) + " " + Alltrim(Str(cvChq)))
				klRegTmp := GR03->(Recno())

				If gtQtdPr <> 0

					dbSelectArea("Z44")
					dbSetOrder(2)
					If !dbSeek(xFilial("Z44") + dtos(kfDataAte) + gtProdt + GR03->ITCUS + "999")
						RecLock("Z44",.T.)
						Z44->Z44_FILIAL := xFilial("Z44")
						Z44->Z44_DATARF := kfDataAte
						Z44->Z44_COD    := gtProdt
						Z44->Z44_ITCUS  := GR03->ITCUS
						Z44->Z44_TM     := "999"
						Z44->Z44_CF     := "RQ"
						Z44->Z44_CONTA  := ""
						Z44->Z44_RFPROD := gtProdt
						Z44->Z44_TPPROD := gtTpPro
						Z44->Z44_QUANT  := gtQtdPr
						Z44->Z44_CUSTO1 := 0
						Z44->Z44_FLAG   := "Y"
						MsUnLockAll()
					EndIf

				EndIf

				dbSelectArea("GR03")
				dbGoTo(klRegTmp)
				GR03->(dbSkip())

			End

			dbSelectArea("GR03")

		End

		GR03->(dbCloseArea())
		Ferase(GRIndex+GetDBExtension())
		Ferase(GRIndex+OrdBagExt())

	EndIf

	Aviso('BIA503B','Fim do TERCEIRO Processamento...',{'Ok'})

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA503D  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 07.11.14 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Efetua a gravação de registros com quantidades e custos ne-¦¦¦
¦¦¦          ¦ gativos que servirão de redutores para a RAC/SAP           ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA503D()

	Processa({|| zRptZDet()})

Return

Static Function zRptZDet()

	If cEmpAnt <> "01"
		MsgSTOP("Rotina não configurada para empresa diferente de Biancogres!!!")
		Return
	EndIf

	cHInicio := Time()

	xdAnoMes := space(006)
	If !fPergHotB()
		MsgSTOP("Processo Abortado!!!")
		Return
	EndIf
	MV_PAR01 := xdAnoMes

	kfDataDe  := stod(MV_PAR01+"01")
	kfDataAte := Ultimodia(kfDataDe)

	if !U_BiaULRAC(kfDataDe)
		Return
	endif

	//                               Zera Valores para que não ocorra erros em caso se reprocessamento
	**************************************************************************************************
	ZP009 := " DELETE " + RetSqlName("Z44")
	ZP009 += "   FROM " + RetSqlName("Z44") + " WITH (NOLOCK)
	ZP009 += "  WHERE Z44_FILIAL = '" + xFilial("Z44") + "'
	ZP009 += "    AND Z44_DATARF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'
	ZP009 += "    AND Z44_COD = 'Z1000071       '
	ZP009 += "    AND D_E_L_E_T_ = ' '
	U_BIAMsgRun("Aguarde... Zerando valores produto: Z1000071 ...",,{|| TCSQLExec(ZP009)})

	RT004 := " WITH REQPA "
	RT004 += "      AS (SELECT '071' ITCUS, "
	RT004 += "                 SUM(D3_QUANT) QUANT, "
	RT004 += "                 SUM(D3_CUSTO1) CUSTO1 "
	RT004 += "          FROM " + RetSqlName("SD3") + " WITH(NOLOCK) "
	RT004 += "          WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	RT004 += "                AND D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "' "
	RT004 += "                AND D3_TM = '517' "
	RT004 += "                AND D3_TIPO = 'PA' "
	RT004 += "                AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	RT004 += "                AND D_E_L_E_T_ = ' ' "
	RT004 += "          UNION ALL "
	RT004 += "          SELECT '065' ITCUS, "
	RT004 += "                 SUM(D3_QUANT) QUANT, "
	RT004 += "                 SUM(D3_CUSTO1) CUSTO1 "
	RT004 += "          FROM " + RetSqlName("SD3") + " WITH(NOLOCK) "
	RT004 += "          WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	RT004 += "                AND D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "' "
	RT004 += "                AND D3_TM = '999' "
	RT004 += "                AND D3_TIPO = 'PA' "
	RT004 += "                AND D3_CF = 'RE1' "
	RT004 += "                AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	RT004 += "                AND D3_NUMSEQ NOT IN('AGEEGY', 'AGEEH0', 'AGEEH2', 'AGEEH4', 'AGEEIB') "
	RT004 += "          AND D_E_L_E_T_ = ' '), "
	RT004 += "      TOTPA "
	RT004 += "      AS (SELECT ITCUS, "
	RT004 += "                 SUM(QUANT) QUANT, "
	RT004 += "                 SUM(CUSTO1) CUSTO "
	RT004 += "          FROM REQPA "
	RT004 += "          GROUP BY ITCUS) "
	RT004 += "      SELECT ITCUS, "
	RT004 += "             QUANT = "
	RT004 += "      ( "
	RT004 += "          SELECT SUM(QUANT) "
	RT004 += "          FROM TOTPA "
	RT004 += "      ), "
	RT004 += "             CUSTO "
	RT004 += "      FROM TOTPA "
	RT7Index := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT004),'RT04',.T.,.T.)
	dbSelectArea("RT04")
	dbGoTop()
	ProcRegua(0)
	While !Eof()

		IncProc("Processando...")

		dbSelectArea("Z44")
		dbSetOrder(2)
		If !dbSeek(xFilial("Z44") + dtos(kfDataAte) + "Z1000071       " + "001" + "010")
			RecLock("Z44",.T.)
			Z44->Z44_FILIAL := xFilial("Z44")
			Z44->Z44_DATARF := kfDataAte
			Z44->Z44_COD    := "Z1000071       "
			Z44->Z44_ITCUS  := "001"
			Z44->Z44_TM     := "010"
			Z44->Z44_CF     := "PR"
			Z44->Z44_CONTA  := ""
			Z44->Z44_RFPROD := "Z1000071       "
			Z44->Z44_TPPROD := "PA"
			Z44->Z44_CUSTO1 := 0
			Z44->Z44_OP     := 'Z1000101001  '
		Else
			RecLock("Z44",.F.)
		EndIf
		Z44->Z44_QUANT  := RT04->QUANT * (-1)
		MsUnLock()

		dbSelectArea("Z44")
		dbSetOrder(2)
		If !dbSeek(xFilial("Z44") + dtos(kfDataAte) + "Z1000071       " + RT04->ITCUS + "999")
			RecLock("Z44",.T.)
			Z44->Z44_FILIAL := xFilial("Z44")
			Z44->Z44_DATARF := kfDataAte
			Z44->Z44_COD    := "Z1000071       "
			Z44->Z44_ITCUS  := RT04->ITCUS
			Z44->Z44_TM     := "999"
			Z44->Z44_CF     := "RQ"
			Z44->Z44_CONTA  := ""
			Z44->Z44_RFPROD := "Z1000071       "
			Z44->Z44_TPPROD := "PA"
			Z44->Z44_OP     := 'Z1000101001  '
		Else
			RecLock("Z44",.F.)
		EndIf
		Z44->Z44_QUANT  := RT04->QUANT * (-1)
		Z44->Z44_CUSTO1 := RT04->CUSTO * (-1)
		MsUnLock()

		dbSelectArea("RT04")
		dbSkip()

	End
	RT04->(dbCloseArea())
	Ferase(RT7Index+GetDBExtension())
	Ferase(RT7Index+OrdBagExt())

	Aviso('BIA503D','Fim do QUINTO Processamento...',{'Ok'})

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA503T  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 11.05.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦  Gera registros na tabela auxiliar (Z44) a partir dos movi-¦¦¦
¦¦¦          ¦ mentos gerados no SD3 provenientes do cancelamento de eti- ¦¦¦
¦¦¦          ¦ quetas no Ecosis.                                          ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA503T()

	Processa({|| RptTDet()})

Return

Static Function RptTDet()

	Local jkl

	If cEmpAnt <> "01"
		MsgSTOP("Rotina não configurada para empresa diferente de Biancogres!!!")
		Return
	EndIf

	cHInicio := Time()

	xdAnoMes := space(006)
	If !fPergHotB()
		MsgSTOP("Processo Abortado!!!")
		Return
	EndIf
	MV_PAR01 := xdAnoMes

	kfDataDe  := stod(MV_PAR01+"01")
	kfDataAte := Ultimodia(kfDataDe)

	if !U_BiaULRAC(kfDataDe)
		Return
	endif

	//                                                       Etiquetas Canceladas
	*****************************************************************************
	For jkl := 1 to 2

		kgTipoPd := ""
		If jkl == 1
			kgTipoPd := "PA"
		ElseIf jkl == 2
			kgTipoPd := "PP"
		EndIf

		GP007 := " SELECT PERIODO,
		GP007 += "        REFERENCIA,
		GP007 += "        CT1_YITCUS,
		GP007 += "        D3_TM,
		GP007 += "        SUM(D3_QUANT) D3_QUANT,
		GP007 += "        SUM(D3_CUSTO1) D3_CUSTO1
		GP007 += "   FROM (SELECT SUBSTRING(D3_EMISSAO,1,6) PERIODO,
		GP007 += "                D3_YRFCUST D3_NUMSEQ,
		GP007 += "                ISNULL(CT1_DESC01,'RATEIO '+SUBSTRING(D3_COD,4,12)) DESCR,
		GP007 += "                CASE
		GP007 += "                  WHEN B1_TIPO = 'PP' THEN SUBSTRING(Z18_COD,1,7) + '        '
		GP007 += "                  ELSE Z18_COD
		GP007 += "                END REFERENCIA,
		GP007 += "                D3_COD,
		GP007 += "                CASE
		GP007 += "                  WHEN D3_TM = '711' THEN '010'
		GP007 += "                  WHEN D3_TM = '211' THEN '999'
		GP007 += "                END D3_TM,
		GP007 += "                D3_CONTA,
		GP007 += "                D3_QUANT * (-1) D3_QUANT,
		GP007 += "                D3_CUSTO1 * (-1) D3_CUSTO1,
		GP007 += "                CASE
		GP007 += "                  WHEN D3_TM = '711' THEN '001'
		GP007 += "                  ELSE CT1_YITCUS
		GP007 += "                END CT1_YITCUS
		GP007 += "           FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)
		GP007 += "           LEFT JOIN " + RetSqlName("CT1") + " CT1 WITH (NOLOCK) ON CT1_FILIAL = '" + xFilial("CT1") + "'
		GP007 += "                                             AND CT1_CONTA = D3_CONTA
		GP007 += "                                             AND CT1.D_E_L_E_T_ = ' '
		GP007 += "          INNER JOIN " + RetSqlName("Z18") + " Z18 WITH (NOLOCK) ON Z18_FILIAL = '" + xFilial("Z18") + "'
		GP007 += "                                             AND Z18_DATA BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'
		If kgTipoPd == "PA"
			GP007 += "                                             AND Z18_NSQSD3 = D3_YRFCUST
			GP007 += "                                             AND Z18_NSQSD3 <> '         '
		ElseIf kgTipoPd == "PP"
			GP007 += "                                             AND Z18_SQD3PP = D3_YRFCUST
			GP007 += "                                             AND Z18_SQD3PP <> '         '
		EndIf
		GP007 += "                                             AND Z18.Z18_DOCSD3 <> 'XDOCECANC'
		GP007 += "                                             AND Z18.D_E_L_E_T_ = ' '
		GP007 += "          INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "'
		If kgTipoPd == "PA"
			GP007 += "                                             AND B1_COD = Z18_COD
			GP007 += "                                             AND B1_TIPO = 'PA'
		ElseIf kgTipoPd == "PP"
			GP007 += "                                             AND SUBSTRING(B1_COD,1,7) = SUBSTRING(Z18_COD,1,7)
			GP007 += "                                             AND B1_TIPO = 'PP'
		EndIf
		GP007 += "                                             AND SB1.D_E_L_E_T_ = ' '
		GP007 += "          WHERE D3_FILIAL = '" + xFilial("SD3") + "'
		GP007 += "            AND D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'
		GP007 += "            AND (D3_TM = '711' OR ( D3_TM = '211' AND D3_TIPO NOT IN('PA','PP') ) )
		GP007 += "            AND D3_ESTORNO = ' '
		GP007 += "            AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
		GP007 += "            AND SD3.D_E_L_E_T_ = ' ') AS TABL
		GP007 += "   GROUP BY PERIODO,
		GP007 += "            REFERENCIA,
		GP007 += "            CT1_YITCUS,
		GP007 += "            D3_TM
		GP007 += "  OPTION (FORCE ORDER)
		GPIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,GP007),'GP07',.T.,.T.)
		dbSelectArea("GP07")
		dbGoTop()
		ProcRegua(0)
		gxQtdPrd := 0
		While !Eof()

			IncProc("Processando...")

			If GP07->CT1_YITCUS == "001"
				gxQtdPrd := GP07->D3_QUANT
			EndIf

			dbSelectArea("Z44")
			dbSetOrder(2)
			If !dbSeek(xFilial("Z44") + dtos(kfDataAte) + GP07->REFERENCIA + GP07->CT1_YITCUS + GP07->D3_TM)
				RecLock("Z44",.T.)
				Z44->Z44_FILIAL := xFilial("Z44")
				Z44->Z44_DATARF := kfDataAte
				Z44->Z44_COD    := GP07->REFERENCIA
				Z44->Z44_ITCUS  := GP07->CT1_YITCUS
				Z44->Z44_TM     := GP07->D3_TM
				Z44->Z44_CF     := "RQ"
				Z44->Z44_CONTA  := ""
				Z44->Z44_RFPROD := GP07->REFERENCIA
				Z44->Z44_TPPROD := kgTipoPd
				Z44->Z44_QUANT  := gxQtdPrd
				Z44->Z44_CUSTO1 := GP07->D3_CUSTO1
				Z44->Z44_FLAG   := "T"
				Z44->Z44_OP     := '71717717171  '
				MsUnLockAll()
			EndIf

			dbSelectArea("GP07")
			dbSkip()

		End
		GP07->(dbCloseArea())
		Ferase(GPIndex+GetDBExtension())
		Ferase(GPIndex+OrdBagExt())

	Next jkl

	//                                               Preenchendo lacunas de ItCus
	*****************************************************************************
	RY004 := " SELECT TAB3X.Z44_COD,
	RY004 += "        TAB3X.Z44_TPPROD,
	RY004 += "        TAB3X.Z44_ITCUS,
	RY004 += "        ISNULL(DATAREF, '        ') DATAREF,
	RY004 += "        ISNULL(TPPROD, '  ') TPPROD,
	RY004 += "        ISNULL(COD, '               ') COD,
	RY004 += "        ISNULL(ITCUS, '  ') ITCUS,
	RY004 += "        ISNULL(CUSTO1, 0) CUSTO1,
	RY004 += "        ISNULL(QUANT, 0) QUANT,
	RY004 += "        (SELECT SUM(D3_QUANT) * (-1)
	RY004 += "           FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)
	RY004 += "          WHERE D3_FILIAL = '" + xFilial("SD3") + "'
	RY004 += "            AND D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'
	RY004 += "            AND D3_COD = TAB3X.Z44_COD
	RY004 += "            AND D3_TM = '711'
	RY004 += "            AND D3_ESTORNO = ' '
	RY004 += "            AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	RY004 += "            AND D_E_L_E_T_ = ' ') D3_QUANT
	RY004 += "   FROM (SELECT DISTINCT
	RY004 += "                TAB2L.Z44_COD,
	RY004 += "                TAB2L.Z44_TPPROD,
	RY004 += "                Z44_ITCUS
	RY004 += "           FROM (SELECT Z29_COD_IT Z44_ITCUS,
	RY004 += "                        Z29_APLIC Z44_TPPROD
	RY004 += "                   FROM " + RetSqlName("Z29") + " Z29
	RY004 += "                  WHERE Z29_TIPO IN('CV','Q ')
	If cEmpAnt $ "01"
		RY004 += "                    AND Z29_APLIC IN('PP','PA')
	ElseIf cEmpAnt == "06"
		RY004 += "                    AND Z29_APLIC IN('MP','PI','PA')
	EndIf
	RY004 += "                    AND Z29.D_E_L_E_T_ = ' '
	RY004 += "                  GROUP BY Z29_COD_IT, Z29_APLIC) AS TABL
	RY004 += "          INNER JOIN (SELECT Z44_COD,
	RY004 += "                             Z44_TPPROD
	RY004 += "                        FROM " + RetSqlName("Z44") + " Z44 WITH (NOLOCK)
	RY004 += "                       WHERE Z44_FILIAL = '" + xFilial("Z44") + "'
	RY004 += "                         AND Z44_DATARF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'
	RY004 += "                         AND Z44_TM = '010'
	If cEmpAnt $ "01"
		RY004 += "                         AND Z44_TPPROD IN('PA','PS','PP')
	ElseIf cEmpAnt == "06"
		RY004 += "                         AND Z44_TPPROD IN('MP','PI','PA')
	EndIf
	RY004 += "                         AND Z44_ITCUS NOT IN('   ','999')
	RY004 += "                         AND Z44.D_E_L_E_T_ = ' '
	RY004 += "                       GROUP BY Z44_COD, Z44_TPPROD) TAB2L ON TABL.Z44_TPPROD = TAB2L.Z44_TPPROD) AS TAB3X
	RY004 += "   LEFT JOIN (SELECT Z44_DATARF DATAREF,
	RY004 += "                     Z44_TPPROD TPPROD,
	RY004 += "                     Z44_COD COD,
	RY004 += "                     Z44_ITCUS ITCUS,
	RY004 += "                     SUM(Z44_CUSTO1) CUSTO1,
	RY004 += "                     SUM(Z44_QUANT) QUANT
	RY004 += "                FROM " + RetSqlName("Z44") + " Z44 WITH (NOLOCK)
	RY004 += "               WHERE Z44_FILIAL = '" + xFilial("Z44") + "'
	RY004 += "                 AND Z44_DATARF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'
	RY004 += "                 AND Z44_ITCUS NOT IN('   ','999')
	RY004 += "                 AND Z44.D_E_L_E_T_ = ' '
	RY004 += "               GROUP BY Z44_DATARF,
	RY004 += "                        Z44_TPPROD,
	RY004 += "                        Z44_COD,
	RY004 += "                        Z44_ITCUS) CRZT ON ITCUS = TAB3X.Z44_ITCUS
	RY004 += "                                       AND COD = TAB3X.Z44_COD
	RY004 += "                                       AND TPPROD = TAB3X.Z44_TPPROD
	RY004 += "  ORDER BY TAB3X.Z44_COD, TAB3X.Z44_TPPROD, TAB3X.Z44_ITCUS
	RYIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RY004),'RY04',.T.,.T.)
	dbSelectArea("RY04")
	dbGoTop()
	ProcRegua(0)
	While !Eof()

		IncProc("Processando...")

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+RY04->Z44_COD))

		dbSelectArea("Z44")
		dbSetOrder(2)
		If !dbSeek(xFilial("Z44") + dtos(kfDataAte) + RY04->Z44_COD + RY04->Z44_ITCUS + "999")
			RecLock("Z44",.T.)
			Z44->Z44_FILIAL := xFilial("Z44")
			Z44->Z44_DATARF := kfDataAte
			Z44->Z44_COD    := RY04->Z44_COD
			Z44->Z44_ITCUS  := RY04->Z44_ITCUS
			Z44->Z44_TM     := "999"
			Z44->Z44_CF     := "RQ"
			Z44->Z44_CONTA  := ""
			Z44->Z44_RFPROD := RY04->Z44_COD
			Z44->Z44_TPPROD := SB1->B1_TIPO
			Z44->Z44_QUANT  := RY04->D3_QUANT
			Z44->Z44_FLAG   := "T"
			Z44->Z44_OP     := '72727727272  '
			MsUnLockAll()
		EndIf

		dbSelectArea("RY04")
		dbSkip()

	End
	RY04->(dbCloseArea())
	Ferase(RYIndex+GetDBExtension())
	Ferase(RYIndex+OrdBagExt())

	Aviso('BIA503T','Fim do QUARTO Processamento...',{'Ok'})

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA503P  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 04/11/21 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Preenche as Lacunas faltantes de forma que nova RAC - PwBI ¦¦¦
¦¦¦          ¦ consiga efetuar o cálculo dos médio sem grandes esforços   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA503P()

	Processa({|| RptPDet()})

Return

Static Function RptPDet()

	Local msErroQuery := ""
	Local msStaExcQy  := 0

	xdAnoMes := space(006)
	If !fPergHotB()
		MsgSTOP("Processo Abortado!!!")
		Return
	EndIf

	kfDataDe  := stod(MV_PAR01+"01")
	kfDataAte := Ultimodia(kfDataDe)

	If !U_BiaULRAC(kfDataDe)
		Return
	EndIf

	//                               Zera Valores para que não ocorra erros em caso se reprocessamento
	**************************************************************************************************
	ZP003 := " DELETE Z44 "
	ZP003 += "   FROM " + RetSqlName("Z44") + " Z44 "
	ZP003 += "  WHERE Z44_FILIAL = '" + xFilial("Z44") + "' "
	ZP003 += "    AND Z44_DATARF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "' "
	ZP003 += "    AND Z44_QUANT = 0 "
	ZP003 += "    AND Z44_CUSTO1 = 0 "
	ZP003 += "    AND D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Apagando registros com quantidade zerada...",,{|| TCSQLExec(ZP003)})

	//                               Zera Valores para que não ocorra erros em caso se reprocessamento
	**************************************************************************************************
	ZP007 := " DELETE Z44 "
	ZP007 += "   FROM " + RetSqlName("Z44") + " Z44 "
	ZP007 += "  WHERE Z44_FILIAL = '" + xFilial("Z44") + "' "
	ZP007 += "    AND Z44_DATARF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "' "
	ZP007 += "    AND Z44_FLAG IN('2', '3', '4', '5') "
	ZP007 += "    AND D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Apagando registros com quantidade zerada...",,{|| TCSQLExec(ZP007)})

	//                           Completa lacunas para os itens de custo sem custo - Segunda tratativa
	**************************************************************************************************
	GR003 := Alltrim(" WITH ITEMCUSTO                                                                                                                                                    ") + msEnter
	GR003 += Alltrim("      AS (SELECT TPCUS = Z29_TIPO,                                                                                                                                 ") + msEnter
	GR003 += Alltrim("                 TPPROD = Z29_APLTPP,                                                                                                                              ") + msEnter
	GR003 += Alltrim("                 ITCUS = Z29_COD_IT,                                                                                                                               ") + msEnter
	GR003 += Alltrim("                 DITCUS = Z29_DESCR,                                                                                                                               ") + msEnter
	GR003 += Alltrim("                 RESUM = Z29_DRESUM                                                                                                                                ") + msEnter
	GR003 += Alltrim("          FROM " + RetSqlName("Z29") + " Z29(NOLOCK)                                                                                                               ") + msEnter
	GR003 += Alltrim("          WHERE Z29_FILIAL = '" + xFilial("Z29") + "'                                                                                                              ") + msEnter
	GR003 += Alltrim("                AND Z29_EMPUSO LIKE '%" + cEmpAnt + "%'                                                                                                            ") + msEnter
	GR003 += Alltrim("                AND Z29_ATIVO = 'S'                                                                                                                                ") + msEnter
	GR003 += Alltrim("                AND Z29_TIPO <> 'Q '                                                                                                                               ") + msEnter
	GR003 += Alltrim("                AND Z29_APLTPP <> 'XX'                                                                                                                             ") + msEnter
	GR003 += Alltrim("                AND Z29.D_E_L_E_T_ = ' '                                                                                                                           ") + msEnter
	GR003 += Alltrim("          UNION ALL                                                                                                                                                ") + msEnter
	GR003 += Alltrim("          SELECT TPCUS = Z29_TIPO,                                                                                                                                 ") + msEnter
	GR003 += Alltrim("                 TPPROD = 'PP',                                                                                                                                    ") + msEnter
	GR003 += Alltrim("                 ITCUS = Z29_COD_IT,                                                                                                                               ") + msEnter
	GR003 += Alltrim("                 DITCUS = Z29_DESCR,                                                                                                                               ") + msEnter
	GR003 += Alltrim("                 RESUM = Z29_DRESUM                                                                                                                                ") + msEnter
	GR003 += Alltrim("          FROM " + RetSqlName("Z29") + " Z29(NOLOCK)                                                                                                               ") + msEnter
	GR003 += Alltrim("          WHERE Z29_FILIAL = '" + xFilial("Z29") + "'                                                                                                              ") + msEnter
	GR003 += Alltrim("                AND Z29_EMPUSO LIKE '%" + cEmpAnt + "%'                                                                                                            ") + msEnter
	GR003 += Alltrim("                AND Z29_ATIVO = 'S'                                                                                                                                ") + msEnter
	GR003 += Alltrim("                AND Z29_TIPO <> 'Q '                                                                                                                               ") + msEnter
	GR003 += Alltrim("                AND Z29_APLTPP = 'XX'                                                                                                                              ") + msEnter
	GR003 += Alltrim("                AND Z29.D_E_L_E_T_ = ' '                                                                                                                           ") + msEnter
	GR003 += Alltrim("          UNION ALL                                                                                                                                                ") + msEnter
	GR003 += Alltrim("          SELECT TPCUS = Z29_TIPO,                                                                                                                                 ") + msEnter
	GR003 += Alltrim("                 TPPROD = 'PA',                                                                                                                                    ") + msEnter
	GR003 += Alltrim("                 ITCUS = Z29_COD_IT,                                                                                                                               ") + msEnter
	GR003 += Alltrim("                 DITCUS = Z29_DESCR,                                                                                                                               ") + msEnter
	GR003 += Alltrim("                 RESUM = Z29_DRESUM                                                                                                                                ") + msEnter
	GR003 += Alltrim("          FROM " + RetSqlName("Z29") + " Z29(NOLOCK)                                                                                                               ") + msEnter
	GR003 += Alltrim("          WHERE Z29_FILIAL = '" + xFilial("Z29") + "'                                                                                                              ") + msEnter
	GR003 += Alltrim("                AND Z29_EMPUSO LIKE '%" + cEmpAnt + "%'                                                                                                            ") + msEnter
	GR003 += Alltrim("                AND Z29_ATIVO = 'S'                                                                                                                                ") + msEnter
	GR003 += Alltrim("                AND Z29_TIPO <> 'Q '                                                                                                                               ") + msEnter
	GR003 += Alltrim("                AND Z29_APLTPP = 'XX'                                                                                                                              ") + msEnter
	GR003 += Alltrim("                AND Z29.D_E_L_E_T_ = ' '),                                                                                                                         ") + msEnter
	GR003 += Alltrim("      PRODUCAO                                                                                                                                                     ") + msEnter
	GR003 += Alltrim("      AS (SELECT PRODUTO,                                                                                                                                          ") + msEnter
	GR003 += Alltrim("                 TPPROD                                                                                                                                            ") + msEnter
	GR003 += Alltrim("          FROM                                                                                                                                                     ") + msEnter
	GR003 += Alltrim("          (                                                                                                                                                        ") + msEnter
	GR003 += Alltrim("              SELECT PRODUTO = SC2.C2_PRODUTO,                                                                                                                     ") + msEnter
	GR003 += Alltrim("                     TPPROD = SB1.B1_TIPO                                                                                                                          ") + msEnter
	GR003 += Alltrim("              FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK)                                                                                                      ") + msEnter
	GR003 += Alltrim("                   INNER JOIN " + RetSqlName("SC2") + " SC2 WITH(NOLOCK) ON SC2.C2_FILIAL = SD3.D3_FILIAL                                                          ") + msEnter
	GR003 += Alltrim("                                                         AND SC2.C2_NUM = SUBSTRING(SD3.D3_OP, 1, 6)                                                               ") + msEnter
	GR003 += Alltrim("                                                         AND SC2.C2_ITEM = SUBSTRING(SD3.D3_OP, 7, 2)                                                              ") + msEnter
	GR003 += Alltrim("                                                         AND SC2.C2_SEQUEN = SUBSTRING(SD3.D3_OP, 9, 3)                                                            ") + msEnter
	GR003 += Alltrim("                                                         AND SC2.D_E_L_E_T_ = ' '                                                                                  ") + msEnter
	GR003 += Alltrim("                   INNER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'                                               ") + msEnter
	GR003 += Alltrim("                                                         AND SB1.B1_COD = SC2.C2_PRODUTO                                                                           ") + msEnter
	GR003 += Alltrim("                                                         AND SB1.B1_TIPO IN('PP', 'PA', 'PS')                                                                      ") + msEnter
	GR003 += Alltrim("                                                         AND SB1.D_E_L_E_T_ = ' '                                                                                  ") + msEnter
	GR003 += Alltrim("              WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                                                       ") + msEnter
	GR003 += Alltrim("                    AND SD3.D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                              ") + msEnter
	GR003 += Alltrim("                    AND NOT(SD3.D3_TM IN('010', '999')                                                                                                             ") + msEnter
	GR003 += Alltrim("              AND SD3.D3_TIPO = 'PP')                                                                                                                              ") + msEnter
	GR003 += Alltrim("                   AND SD3.D_E_L_E_T_ = ' '                                                                                                                        ") + msEnter
	GR003 += Alltrim("              GROUP BY SC2.C2_PRODUTO,                                                                                                                             ") + msEnter
	GR003 += Alltrim("                       SB1.B1_TIPO                                                                                                                                 ") + msEnter
	GR003 += Alltrim("              UNION ALL                                                                                                                                            ") + msEnter
	GR003 += Alltrim("              SELECT PRODUTO = Z44.Z44_RFPROD,                                                                                                                     ") + msEnter
	GR003 += Alltrim("                     TPPROD = Z44.Z44_TPPROD                                                                                                                       ") + msEnter
	GR003 += Alltrim("              FROM " + RetSqlName("Z44") + " Z44 WITH(NOLOCK)                                                                                                      ") + msEnter
	GR003 += Alltrim("              WHERE Z44.Z44_FILIAL = '" + xFilial("Z44") + "'                                                                                                      ") + msEnter
	GR003 += Alltrim("                    AND Z44.Z44_DATARF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                              ") + msEnter
	GR003 += Alltrim("                    AND Z44.D_E_L_E_T_ = ' '                                                                                                                       ") + msEnter
	GR003 += Alltrim("              GROUP BY Z44.Z44_RFPROD,                                                                                                                             ") + msEnter
	GR003 += Alltrim("                       Z44.Z44_TPPROD                                                                                                                              ") + msEnter
	GR003 += Alltrim("          ) AS TEMP1                                                                                                                                               ") + msEnter
	GR003 += Alltrim("          GROUP BY PRODUTO,                                                                                                                                        ") + msEnter
	GR003 += Alltrim("                   TPPROD),                                                                                                                                        ") + msEnter
	GR003 += Alltrim("      PRODUCAO2                                                                                                                                                    ") + msEnter
	GR003 += Alltrim("      AS (SELECT PRODUTO,                                                                                                                                          ") + msEnter
	GR003 += Alltrim("                 TPPROD                                                                                                                                            ") + msEnter
	GR003 += Alltrim("          FROM PRODUCAO                                                                                                                                            ") + msEnter
	GR003 += Alltrim("          UNION ALL                                                                                                                                                ") + msEnter
	GR003 += Alltrim("          SELECT PRODUTO = SUBSTRING(PRODUTO, 1, 7) + SPACE(8),                                                                                                    ") + msEnter
	GR003 += Alltrim("                 TPPROD = 'PP'                                                                                                                                     ") + msEnter
	GR003 += Alltrim("          FROM PRODUCAO                                                                                                                                            ") + msEnter
	GR003 += Alltrim("          WHERE SUBSTRING(PRODUTO, 1, 2) IN('B9', 'BO', 'C6', 'Z1')                                                                                                ") + msEnter
	GR003 += Alltrim("          GROUP BY SUBSTRING(PRODUTO, 1, 7)),                                                                                                                      ") + msEnter
	GR003 += Alltrim("      REALIZADO                                                                                                                                                    ") + msEnter
	GR003 += Alltrim("      AS (SELECT PRODUTO,                                                                                                                                          ") + msEnter
	GR003 += Alltrim("                 TPPROD,                                                                                                                                           ") + msEnter
	GR003 += Alltrim("                 ITCUS                                                                                                                                             ") + msEnter
	GR003 += Alltrim("          FROM                                                                                                                                                     ") + msEnter
	GR003 += Alltrim("          (                                                                                                                                                        ") + msEnter
	GR003 += Alltrim("              SELECT PRODUTO = SC2.C2_PRODUTO,                                                                                                                     ") + msEnter
	GR003 += Alltrim("                     TPPROD = SB1.B1_TIPO,                                                                                                                         ") + msEnter
	GR003 += Alltrim("                     ITCUS = SD3.D3_YITCUS                                                                                                                         ") + msEnter
	GR003 += Alltrim("              FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK)                                                                                                      ") + msEnter
	GR003 += Alltrim("                   INNER JOIN " + RetSqlName("SC2") + " SC2 WITH(NOLOCK) ON SC2.C2_FILIAL = SD3.D3_FILIAL                                                          ") + msEnter
	GR003 += Alltrim("                                                         AND SC2.C2_NUM = SUBSTRING(SD3.D3_OP, 1, 6)                                                               ") + msEnter
	GR003 += Alltrim("                                                         AND SC2.C2_ITEM = SUBSTRING(SD3.D3_OP, 7, 2)                                                              ") + msEnter
	GR003 += Alltrim("                                                         AND SC2.C2_SEQUEN = SUBSTRING(SD3.D3_OP, 9, 3)                                                            ") + msEnter
	GR003 += Alltrim("                                                         AND SC2.D_E_L_E_T_ = ' '                                                                                  ") + msEnter
	GR003 += Alltrim("                   INNER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'                                               ") + msEnter
	GR003 += Alltrim("                                                         AND SB1.B1_COD = SC2.C2_PRODUTO                                                                           ") + msEnter
	GR003 += Alltrim("                                                         AND SB1.B1_TIPO IN('PP', 'PA', 'PS')                                                                      ") + msEnter
	GR003 += Alltrim("                                                         AND SB1.D_E_L_E_T_ = ' '                                                                                  ") + msEnter
	GR003 += Alltrim("              WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                                                       ") + msEnter
	GR003 += Alltrim("                    AND SD3.D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                              ") + msEnter
	GR003 += Alltrim("                    AND NOT(SD3.D3_TM IN('010', '999')                                                                                                             ") + msEnter
	GR003 += Alltrim("              AND SD3.D3_TIPO = 'PP')                                                                                                                              ") + msEnter
	GR003 += Alltrim("                   AND SD3.D_E_L_E_T_ = ' '                                                                                                                        ") + msEnter
	GR003 += Alltrim("              GROUP BY SC2.C2_PRODUTO,                                                                                                                             ") + msEnter
	GR003 += Alltrim("                       SB1.B1_TIPO,                                                                                                                                ") + msEnter
	GR003 += Alltrim("                       SD3.D3_YITCUS                                                                                                                               ") + msEnter
	GR003 += Alltrim("              UNION ALL                                                                                                                                            ") + msEnter
	GR003 += Alltrim("              SELECT PRODUTO = Z44.Z44_RFPROD,                                                                                                                     ") + msEnter
	GR003 += Alltrim("                     TPPROD = Z44.Z44_TPPROD,                                                                                                                      ") + msEnter
	GR003 += Alltrim("                     ITCUS = Z44.Z44_ITCUS                                                                                                                         ") + msEnter
	GR003 += Alltrim("              FROM " + RetSqlName("Z44") + " Z44 WITH(NOLOCK)                                                                                                      ") + msEnter
	GR003 += Alltrim("              WHERE Z44.Z44_FILIAL = '" + xFilial("Z44") + "'                                                                                                      ") + msEnter
	GR003 += Alltrim("                    AND Z44.Z44_DATARF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                              ") + msEnter
	GR003 += Alltrim("                    AND Z44.D_E_L_E_T_ = ' '                                                                                                                       ") + msEnter
	GR003 += Alltrim("              GROUP BY Z44.Z44_RFPROD,                                                                                                                             ") + msEnter
	GR003 += Alltrim("                       Z44.Z44_TPPROD,                                                                                                                             ") + msEnter
	GR003 += Alltrim("                       Z44.Z44_ITCUS                                                                                                                               ") + msEnter
	GR003 += Alltrim("          ) AS TEMP1                                                                                                                                               ") + msEnter
	GR003 += Alltrim("          GROUP BY PRODUTO,                                                                                                                                        ") + msEnter
	GR003 += Alltrim("                   TPPROD,                                                                                                                                         ") + msEnter
	GR003 += Alltrim("                   ITCUS),                                                                                                                                         ") + msEnter
	GR003 += Alltrim("      PRODITC                                                                                                                                                      ") + msEnter
	GR003 += Alltrim("      AS (SELECT PRODUTO,                                                                                                                                          ") + msEnter
	GR003 += Alltrim("                 TPPROD,                                                                                                                                           ") + msEnter
	GR003 += Alltrim("                 TPCUS,                                                                                                                                            ") + msEnter
	GR003 += Alltrim("                 QUANT = MIN(QUANT)                                                                                                                                ") + msEnter
	GR003 += Alltrim("          FROM                                                                                                                                                     ") + msEnter
	GR003 += Alltrim("          (                                                                                                                                                        ") + msEnter
	GR003 += Alltrim("              SELECT PRODUTO = SC2.C2_PRODUTO,                                                                                                                     ") + msEnter
	GR003 += Alltrim("                     TPPROD = SB1.B1_TIPO,                                                                                                                         ") + msEnter
	GR003 += Alltrim("                     TPCUS = Z29.Z29_TIPO,                                                                                                                         ") + msEnter
	GR003 += Alltrim("                     ITCUS = SD3.D3_YITCUS,                                                                                                                        ") + msEnter
	GR003 += Alltrim("                     QUANT = SUM(SD3.D3_YQTDPAC)                                                                                                                   ") + msEnter
	GR003 += Alltrim("              FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK)                                                                                                      ") + msEnter
	GR003 += Alltrim("                   INNER JOIN " + RetSqlName("SC2") + " SC2 WITH(NOLOCK) ON SC2.C2_FILIAL = SD3.D3_FILIAL                                                          ") + msEnter
	GR003 += Alltrim("                                                         AND SC2.C2_NUM = SUBSTRING(SD3.D3_OP, 1, 6)                                                               ") + msEnter
	GR003 += Alltrim("                                                         AND SC2.C2_ITEM = SUBSTRING(SD3.D3_OP, 7, 2)                                                              ") + msEnter
	GR003 += Alltrim("                                                         AND SC2.C2_SEQUEN = SUBSTRING(SD3.D3_OP, 9, 3)                                                            ") + msEnter
	GR003 += Alltrim("                                                         AND SC2.D_E_L_E_T_ = ' '                                                                                  ") + msEnter
	GR003 += Alltrim("                   INNER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'                                               ") + msEnter
	GR003 += Alltrim("                                                         AND SB1.B1_COD = SC2.C2_PRODUTO                                                                           ") + msEnter
	GR003 += Alltrim("                                                         AND SB1.B1_TIPO IN('PP', 'PA', 'PS')                                                                      ") + msEnter
	GR003 += Alltrim("                                                         AND SB1.D_E_L_E_T_ = ' '                                                                                  ") + msEnter
	GR003 += Alltrim("                   INNER JOIN " + RetSqlName("Z29") + " Z29 WITH(NOLOCK) ON Z29.Z29_FILIAL = '" + xFilial("Z29") + "'                                              ") + msEnter
	GR003 += Alltrim("                                                         AND Z29.Z29_COD_IT = SD3.D3_YITCUS                                                                        ") + msEnter
	GR003 += Alltrim("                                                         AND Z29.D_E_L_E_T_ = ' '                                                                                  ") + msEnter
	GR003 += Alltrim("              WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                                                       ") + msEnter
	GR003 += Alltrim("                    AND SD3.D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                              ") + msEnter
	GR003 += Alltrim("                    AND SD3.D3_YITCUS <> '001'                                                                                                                     ") + msEnter
	GR003 += Alltrim("                    AND SD3.D_E_L_E_T_ = ' '                                                                                                                       ") + msEnter
	GR003 += Alltrim("              GROUP BY SC2.C2_PRODUTO,                                                                                                                             ") + msEnter
	GR003 += Alltrim("                       SB1.B1_TIPO,                                                                                                                                ") + msEnter
	GR003 += Alltrim("                       Z29.Z29_TIPO,                                                                                                                               ") + msEnter
	GR003 += Alltrim("                       SD3.D3_YITCUS                                                                                                                               ") + msEnter
	GR003 += Alltrim("              UNION ALL                                                                                                                                            ") + msEnter
	GR003 += Alltrim("              SELECT PRODUTO = Z44.Z44_RFPROD,                                                                                                                     ") + msEnter
	GR003 += Alltrim("                     TPPROD = Z44.Z44_TPPROD,                                                                                                                      ") + msEnter
	GR003 += Alltrim("                     TPCUS = Z29.Z29_TIPO,                                                                                                                         ") + msEnter
	GR003 += Alltrim("                     ITCUS = Z44.Z44_ITCUS,                                                                                                                        ") + msEnter
	GR003 += Alltrim("                     QUANT = Z44.Z44_QUANT                                                                                                                         ") + msEnter
	GR003 += Alltrim("              FROM " + RetSqlName("Z44") + " Z44 WITH(NOLOCK)                                                                                                      ") + msEnter
	GR003 += Alltrim("                   INNER JOIN " + RetSqlName("Z29") + " Z29(NOLOCK) ON Z29.Z29_FILIAL = '" + xFilial("Z29") + "'                                                   ") + msEnter
	GR003 += Alltrim("                                                    AND Z29.Z29_COD_IT = Z44.Z44_ITCUS                                                                             ") + msEnter
	GR003 += Alltrim("                                                    AND Z29.D_E_L_E_T_ = ' '                                                                                       ") + msEnter
	GR003 += Alltrim("              WHERE Z44.Z44_FILIAL = '" + xFilial("Z44") + "'                                                                                                      ") + msEnter
	GR003 += Alltrim("                    AND Z44.Z44_DATARF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                              ") + msEnter
	GR003 += Alltrim("                    AND Z44.D_E_L_E_T_ = ' '                                                                                                                       ") + msEnter
	GR003 += Alltrim("              GROUP BY Z44.Z44_RFPROD,                                                                                                                             ") + msEnter
	GR003 += Alltrim("                       Z44.Z44_TPPROD,                                                                                                                             ") + msEnter
	GR003 += Alltrim("                       Z29.Z29_TIPO,                                                                                                                               ") + msEnter
	GR003 += Alltrim("                       Z44.Z44_ITCUS,                                                                                                                              ") + msEnter
	GR003 += Alltrim("                       Z44.Z44_QUANT                                                                                                                               ") + msEnter
	GR003 += Alltrim("          ) AS TEMP1                                                                                                                                               ") + msEnter
	GR003 += Alltrim("          GROUP BY PRODUTO,                                                                                                                                        ") + msEnter
	GR003 += Alltrim("                   TPPROD,                                                                                                                                         ") + msEnter
	GR003 += Alltrim("                   TPCUS),                                                                                                                                         ") + msEnter
	GR003 += Alltrim("      PRODITC2                                                                                                                                                     ") + msEnter
	GR003 += Alltrim("      AS (SELECT PRODUTO,                                                                                                                                          ") + msEnter
	GR003 += Alltrim("                 TPPROD,                                                                                                                                           ") + msEnter
	GR003 += Alltrim("                 TPCUS,                                                                                                                                            ") + msEnter
	GR003 += Alltrim("                 QUANT                                                                                                                                             ") + msEnter
	GR003 += Alltrim("          FROM PRODITC                                                                                                                                             ") + msEnter
	GR003 += Alltrim("          UNION ALL                                                                                                                                                ") + msEnter
	GR003 += Alltrim("          SELECT PRODUTO = SUBSTRING(PRODUTO, 1, 7) + SPACE(8),                                                                                                    ") + msEnter
	GR003 += Alltrim("                 TPPROD = 'PP',                                                                                                                                    ") + msEnter
	GR003 += Alltrim("                 TPCUS,                                                                                                                                            ") + msEnter
	GR003 += Alltrim("                 QUANT = SUM(QUANT)                                                                                                                                ") + msEnter
	GR003 += Alltrim("          FROM PRODITC                                                                                                                                             ") + msEnter
	GR003 += Alltrim("          WHERE SUBSTRING(PRODUTO, 1, 2) IN('B9', 'BO', 'C6', 'Z1')                                                                                                ") + msEnter
	GR003 += Alltrim("          GROUP BY SUBSTRING(PRODUTO, 1, 7),                                                                                                                       ") + msEnter
	GR003 += Alltrim("                   TPCUS)                                                                                                                                          ") + msEnter
	GR003 += Alltrim("      SELECT PRC.PRODUTO,                                                                                                                                          ") + msEnter
	GR003 += Alltrim("             ITC.*,                                                                                                                                                ") + msEnter
	GR003 += Alltrim("             QUANT = ISNULL(PIT.QUANT,                                                                                                                             ") + msEnter
	GR003 += Alltrim("      (                                                                                                                                                            ") + msEnter
	GR003 += Alltrim("          SELECT MAX(XXX.QUANT)                                                                                                                                    ") + msEnter
	GR003 += Alltrim("          FROM PRODITC XXX                                                                                                                                         ") + msEnter
	GR003 += Alltrim("          WHERE XXX.PRODUTO = PRC.PRODUTO                                                                                                                          ") + msEnter
	GR003 += Alltrim("      ))                                                                                                                                                           ") + msEnter
	GR003 += Alltrim("      FROM ITEMCUSTO ITC                                                                                                                                           ") + msEnter
	GR003 += Alltrim("           INNER JOIN PRODUCAO2 PRC ON PRC.TPPROD = ITC.TPPROD                                                                                                     ") + msEnter
	GR003 += Alltrim("           LEFT JOIN PRODITC2 PIT ON PIT.PRODUTO = PRC.PRODUTO                                                                                                     ") + msEnter
	GR003 += Alltrim("                                     AND PIT.TPCUS = ITC.TPCUS                                                                                                     ") + msEnter
	GR003 += Alltrim("                                     AND PIT.TPPROD = ITC.TPPROD                                                                                                   ") + msEnter
	GR003 += Alltrim("      WHERE NOT EXISTS                                                                                                                                             ") + msEnter
	GR003 += Alltrim("      (                                                                                                                                                            ") + msEnter
	GR003 += Alltrim("          SELECT 0                                                                                                                                                 ") + msEnter
	GR003 += Alltrim("          FROM REALIZADO JJJ(NOLOCK)                                                                                                                               ") + msEnter
	GR003 += Alltrim("          WHERE JJJ.PRODUTO = PRC.PRODUTO                                                                                                                          ") + msEnter
	GR003 += Alltrim("                AND JJJ.ITCUS = ITC.ITCUS                                                                                                                          ") + msEnter
	GR003 += Alltrim("      )                                                                                                                                                            ") + msEnter
	GR003 += Alltrim("            AND NOT(ITCUS = '070' AND SUBSTRING(PRC.PRODUTO, 1, 2) IN('B9', 'BO', 'C6'))                                                                           ") + msEnter
	GR003 += Alltrim("      ORDER BY PRC.PRODUTO,                                                                                                                                        ") + msEnter
	GR003 += Alltrim("               ITCUS                                                                                                                                               ") + msEnter
	G3Index := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,GR003),'GR03',.T.,.T.)
	dbSelectArea("GR03")
	dbGoTop()
	ProcRegua(0)
	cvChq   := 0
	While GR03->(!Eof())

		gtProdt := GR03->PRODUTO
		gtTpPro := GR03->TPPROD
		gtQtdPr := GR03->QUANT

		cvChq  ++
		IncProc("R-Tipo: " + gtTpPro + " Prod.: " + Alltrim(gtProdt) + " " + Alltrim(Str(cvChq)))
		klRegTmp := GR03->(Recno())

		If gtQtdPr <> 0

			dbSelectArea("Z44")
			dbSetOrder(2)
			If !dbSeek(xFilial("Z44") + dtos(kfDataAte) + gtProdt + GR03->ITCUS + "999")
				RecLock("Z44",.T.)
				Z44->Z44_FILIAL := xFilial("Z44")
				Z44->Z44_DATARF := kfDataAte
				Z44->Z44_COD    := gtProdt
				Z44->Z44_ITCUS  := GR03->ITCUS
				Z44->Z44_TM     := "999"
				Z44->Z44_CF     := "RQ"
				Z44->Z44_CONTA  := ""
				Z44->Z44_RFPROD := gtProdt
				Z44->Z44_TPPROD := gtTpPro
				Z44->Z44_QUANT  := gtQtdPr
				Z44->Z44_CUSTO1 := 0
				Z44->Z44_FLAG   := "2"
				MsUnLockAll()
			EndIf

		EndIf

		dbSelectArea("GR03")
		GR03->(dbSkip())

	End

	GR03->(dbCloseArea())
	Ferase(G3Index+GetDBExtension())
	Ferase(G3Index+OrdBagExt())

	//   Completa lacunas para os itens de custo sem custo - Terceira tratativa - Etiquetas Canceladas
	**************************************************************************************************
	RP005 := Alltrim(" WITH PRODUTOCANC                                                                                                                                         ") + msEnter
	RP005 += Alltrim("      AS (SELECT PRODUTO = D3_COD,                                                                                                                        ") + msEnter
	RP005 += Alltrim("                 TPPROD = D3_TIPO,                                                                                                                        ") + msEnter
	RP005 += Alltrim("                 QTDCANC = SUM(SD3.D3_QUANT)                                                                                                              ") + msEnter
	RP005 += Alltrim("          FROM " + RetSqlName("SD3") + " SD3(NOLOCK)                                                                                                      ") + msEnter
	RP005 += Alltrim("          WHERE D3_FILIAL = '" + xFilial("SD3") + "'                                                                                                      ") + msEnter
	RP005 += Alltrim("                AND D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                             ") + msEnter
	RP005 += Alltrim("                AND D3_TM = '711'                                                                                                                         ") + msEnter
	RP005 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                                      ") + msEnter
	RP005 += Alltrim("          GROUP BY D3_COD,                                                                                                                                ") + msEnter
	RP005 += Alltrim("                   D3_TIPO),                                                                                                                              ") + msEnter
	RP005 += Alltrim("      PRODUTOPROD                                                                                                                                         ") + msEnter
	RP005 += Alltrim("      AS (SELECT PRODUTO = SD3.D3_COD,                                                                                                                    ") + msEnter
	RP005 += Alltrim("                 TPPROD = SD3.D3_TIPO,                                                                                                                    ") + msEnter
	RP005 += Alltrim("                 QTDPROD = SUM(SD3.D3_QUANT)                                                                                                              ") + msEnter
	RP005 += Alltrim("          FROM " + RetSqlName("SD3") + " SD3(NOLOCK)                                                                                                      ") + msEnter
	RP005 += Alltrim("               INNER JOIN PRODUTOCANC PRDC ON SUBSTRING(PRDC.PRODUTO, 1, 7) = SUBSTRING(SD3.D3_COD, 1, 7)                                                 ") + msEnter
	RP005 += Alltrim("                                              AND TPPROD = SD3.D3_TIPO                                                                                    ") + msEnter
	RP005 += Alltrim("          WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                                                  ") + msEnter
	RP005 += Alltrim("                AND SD3.D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                         ") + msEnter
	RP005 += Alltrim("                AND SD3.D3_TM = '010'                                                                                                                     ") + msEnter
	RP005 += Alltrim("                AND SD3.D_E_L_E_T_ = ' '                                                                                                                  ") + msEnter
	RP005 += Alltrim("          GROUP BY SD3.D3_COD,                                                                                                                            ") + msEnter
	RP005 += Alltrim("                   SD3.D3_TIPO),                                                                                                                          ") + msEnter
	RP005 += Alltrim("      PRODUCAOREF                                                                                                                                         ") + msEnter
	RP005 += Alltrim("      AS (SELECT PROD.PRODUTO,                                                                                                                            ") + msEnter
	RP005 += Alltrim("                 PROD.QTDPROD,                                                                                                                            ") + msEnter
	RP005 += Alltrim("                 PROD.TPPROD,                                                                                                                             ") + msEnter
	RP005 += Alltrim("                 QTDCANC = ISNULL(CANC.QTDCANC, 0),                                                                                                       ") + msEnter
	RP005 += Alltrim("                 QTDREF = PROD.QTDPROD - ISNULL(CANC.QTDCANC, 0)                                                                                          ") + msEnter
	RP005 += Alltrim("          FROM PRODUTOPROD PROD                                                                                                                           ") + msEnter
	RP005 += Alltrim("               LEFT JOIN PRODUTOCANC CANC ON CANC.PRODUTO = PROD.PRODUTO),                                                                                ") + msEnter
	RP005 += Alltrim("      PRODUCAORAC                                                                                                                                         ") + msEnter
	RP005 += Alltrim("      AS (SELECT REFERENCIA,                                                                                                                              ") + msEnter
	RP005 += Alltrim("                 TPPROD,                                                                                                                                  ") + msEnter
	RP005 += Alltrim("                 ITCUS,                                                                                                                                   ") + msEnter
	RP005 += Alltrim("                 QUANT = SUM(QUANT)                                                                                                                       ") + msEnter
	RP005 += Alltrim("          FROM                                                                                                                                            ") + msEnter
	RP005 += Alltrim("          (                                                                                                                                               ") + msEnter
	RP005 += Alltrim("              SELECT SC2.C2_PRODUTO REFERENCIA,                                                                                                           ") + msEnter
	RP005 += Alltrim("                     SB1.B1_TIPO TPPROD,                                                                                                                  ") + msEnter
	RP005 += Alltrim("                     SD3.D3_YITCUS ITCUS,                                                                                                                 ") + msEnter
	RP005 += Alltrim("                     SD3.D3_YQTDPAC QUANT                                                                                                                 ") + msEnter
	RP005 += Alltrim("              FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK)                                                                                             ") + msEnter
	RP005 += Alltrim("                   INNER JOIN " + RetSqlName("SC2") + " SC2 WITH(NOLOCK) ON SC2.C2_FILIAL = SD3.D3_FILIAL                                                 ") + msEnter
	RP005 += Alltrim("                                                         AND SC2.C2_NUM = SUBSTRING(SD3.D3_OP, 1, 6)                                                      ") + msEnter
	RP005 += Alltrim("                                                         AND SC2.C2_ITEM = SUBSTRING(SD3.D3_OP, 7, 2)                                                     ") + msEnter
	RP005 += Alltrim("                                                         AND SC2.C2_SEQUEN = SUBSTRING(SD3.D3_OP, 9, 3)                                                   ") + msEnter
	RP005 += Alltrim("                                                         AND SC2.D_E_L_E_T_ = ' '                                                                         ") + msEnter
	RP005 += Alltrim("                   INNER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = '  '                                                          ") + msEnter
	RP005 += Alltrim("                                                         AND SB1.B1_COD = SC2.C2_PRODUTO                                                                  ") + msEnter
	RP005 += Alltrim("                                                         AND SB1.B1_TIPO IN('PP', 'PA', 'PS')                                                             ") + msEnter
	RP005 += Alltrim("                                                         AND SB1.D_E_L_E_T_ = ' '                                                                         ") + msEnter
	RP005 += Alltrim("              WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'                                                                                              ") + msEnter
	RP005 += Alltrim("                    AND SD3.D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                     ") + msEnter
	RP005 += Alltrim("                    AND NOT(SD3.D3_TM IN('010', '999')                                                                                                    ") + msEnter
	RP005 += Alltrim("              AND SD3.D3_TIPO = 'PP')                                                                                                                     ") + msEnter
	RP005 += Alltrim("                   AND D3_YITCUS <> '001'                                                                                                                 ") + msEnter
	RP005 += Alltrim("                   AND SD3.D_E_L_E_T_ = ' '                                                                                                               ") + msEnter
	RP005 += Alltrim("              UNION ALL                                                                                                                                   ") + msEnter
	RP005 += Alltrim("              SELECT D3_COD REFERENCIA,                                                                                                                   ") + msEnter
	RP005 += Alltrim("                     SD3.D3_TIPO TPPROD,                                                                                                                  ") + msEnter
	RP005 += Alltrim("                     SD3.D3_YITCUS ITCUS,                                                                                                                 ") + msEnter
	RP005 += Alltrim("                     SD3.D3_YQTDPAC QUANT                                                                                                                 ") + msEnter
	RP005 += Alltrim("              FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK)                                                                                             ") + msEnter
	RP005 += Alltrim("                   INNER JOIN " + RetSqlName("SF5") + " SF5 WITH(NOLOCK) ON SF5.F5_FILIAL = SD3.D3_FILIAL                                                 ") + msEnter
	RP005 += Alltrim("                                                         AND SF5.F5_CODIGO = SD3.D3_TM                                                                    ") + msEnter
	RP005 += Alltrim("                                                         AND SF5.F5_VAL = 'S'                                                                             ") + msEnter
	RP005 += Alltrim("                                                         AND SF5.F5_QTDZERO <> '2'                                                                        ") + msEnter
	RP005 += Alltrim("                                                         AND SF5.D_E_L_E_T_ = ' '                                                                         ") + msEnter
	RP005 += Alltrim("              WHERE D3_FILIAL = '" + xFilial("SD3") + "'                                                                                                  ") + msEnter
	RP005 += Alltrim("                    AND SD3.D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                     ") + msEnter
	RP005 += Alltrim("                    AND D3_TIPO IN('PP', 'PA', 'PS')                                                                                                      ") + msEnter
	RP005 += Alltrim("                   AND RTRIM(D3_YRFCUST) NOT IN('BIA705', 'MANUAL')                                                                                       ") + msEnter
	RP005 += Alltrim("              AND D3_YITCUS <> '001'                                                                                                                      ") + msEnter
	RP005 += Alltrim("              AND SD3.D_E_L_E_T_ = ' '                                                                                                                    ") + msEnter
	RP005 += Alltrim("              UNION ALL                                                                                                                                   ") + msEnter
	RP005 += Alltrim("              SELECT Z44.Z44_RFPROD REFERENCIA,                                                                                                           ") + msEnter
	RP005 += Alltrim("                     Z44.Z44_TPPROD TPPROD,                                                                                                               ") + msEnter
	RP005 += Alltrim("                     Z44.Z44_ITCUS ITCUS,                                                                                                                 ") + msEnter
	RP005 += Alltrim("                     Z44.Z44_QUANT QUANT                                                                                                                  ") + msEnter
	RP005 += Alltrim("              FROM " + RetSqlName("Z44") + " Z44 WITH(NOLOCK)                                                                                             ") + msEnter
	RP005 += Alltrim("              WHERE Z44_FILIAL = '" + xFilial("Z44") + "'                                                                                                 ") + msEnter
	RP005 += Alltrim("                    AND Z44_DATARF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                         ") + msEnter
	RP005 += Alltrim("                    AND Z44_ITCUS <> '001'                                                                                                                ") + msEnter
	RP005 += Alltrim("                    AND Z44.D_E_L_E_T_ = ' '                                                                                                              ") + msEnter
	RP005 += Alltrim("          ) AS TEMP1                                                                                                                                      ") + msEnter
	RP005 += Alltrim("          GROUP BY REFERENCIA,                                                                                                                            ") + msEnter
	RP005 += Alltrim("                   TPPROD,                                                                                                                                ") + msEnter
	RP005 += Alltrim("                   ITCUS)                                                                                                                                 ") + msEnter
	RP005 += Alltrim("      SELECT PRAC.*,                                                                                                                                      ") + msEnter
	RP005 += Alltrim("             '' SEPARA,                                                                                                                                   ") + msEnter
	RP005 += Alltrim("             PREF.*,                                                                                                                                      ") + msEnter
	RP005 += Alltrim("             QTDAJS = ROUND(PREF.QTDREF, 2) - ROUND(PRAC.QUANT, 2)                                                                                        ") + msEnter
	RP005 += Alltrim("      FROM PRODUCAORAC PRAC                                                                                                                               ") + msEnter
	RP005 += Alltrim("           INNER JOIN PRODUCAOREF PREF ON PREF.PRODUTO = PRAC.REFERENCIA                                                                                  ") + msEnter
	RP005 += Alltrim("      WHERE ROUND(PREF.QTDREF, 2) - ROUND(PRAC.QUANT, 2) <> 0                                                                                             ") + msEnter
	R5Index := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RP005),'RP05',.T.,.T.)
	dbSelectArea("RP05")
	dbGoTop()
	ProcRegua(0)
	cvChq   := 0	
	While RP05->(!Eof())

		gtProdt := RP05->PRODUTO
		gtTpPro := RP05->TPPROD
		gtQtdPr := RP05->QTDAJS

		cvChq  ++
		IncProc("R-Tipo: " + gtTpPro + " Prod.: " + Alltrim(gtProdt) + " " + Alltrim(Str(cvChq)))

		If gtQtdPr <> 0

			dbSelectArea("Z44")
			dbSetOrder(2)
			RecLock("Z44",.T.)
			Z44->Z44_FILIAL := xFilial("Z44")
			Z44->Z44_DATARF := kfDataAte
			Z44->Z44_COD    := gtProdt
			Z44->Z44_ITCUS  := RP05->ITCUS
			Z44->Z44_TM     := "999"
			Z44->Z44_CF     := "RQ"
			Z44->Z44_CONTA  := ""
			Z44->Z44_RFPROD := gtProdt
			Z44->Z44_TPPROD := gtTpPro
			Z44->Z44_QUANT  := gtQtdPr
			Z44->Z44_CUSTO1 := 0
			Z44->Z44_FLAG   := "3"
			MsUnLockAll()

		EndIf
		dbSelectArea("RP05")
		RP05->(dbSkip())

	End

	RP05->(dbCloseArea())
	Ferase(R5Index+GetDBExtension())
	Ferase(R5Index+OrdBagExt())

	//   Completa lacunas para os itens de custo sem custo - Quarta tratativa - Qtd PP diferente de PA
	**************************************************************************************************
	GS007 := Alltrim(" WITH RACQTDE                                                                                                                                     ") + msEnter
	GS007 += Alltrim("      AS (SELECT REFERENCIA,                                                                                                                      ") + msEnter
	GS007 += Alltrim("                 QUANT = SUM(QTDGER)                                                                                                              ") + msEnter
	GS007 += Alltrim("          FROM VW_BI_F_RACQTDE                                                                                                                    ") + msEnter
	GS007 += Alltrim("          WHERE EMPRESA = '" + cEmpAnt + "'                                                                                                       ") + msEnter
	GS007 += Alltrim("                AND FILIAL = '" + cEmpAnt + cFilAnt + "'                                                                                          ") + msEnter
	GS007 += Alltrim("                AND VERSAO = '001'                                                                                                                ") + msEnter
	GS007 += Alltrim("                AND DATAREF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                        ") + msEnter
	GS007 += Alltrim("          GROUP BY REFERENCIA),                                                                                                                   ") + msEnter
	GS007 += Alltrim("      RACFULL                                                                                                                                     ") + msEnter
	GS007 += Alltrim("      AS (SELECT A.REFERENCIA,                                                                                                                    ") + msEnter
	GS007 += Alltrim("                 A.TPPROD,                                                                                                                        ") + msEnter
	GS007 += Alltrim("                 A.ITCUS,                                                                                                                         ") + msEnter
	GS007 += Alltrim("                 A.QUANT                                                                                                                          ") + msEnter
	GS007 += Alltrim("          FROM VW_BI_F_RACFULL A                                                                                                                  ") + msEnter
	GS007 += Alltrim("          WHERE A.EMPRESA = '" + cEmpAnt + "'                                                                                                     ") + msEnter
	GS007 += Alltrim("                AND A.FILIAL = '" + cEmpAnt + cFilAnt + "'                                                                                        ") + msEnter
	GS007 += Alltrim("                AND A.VERSAO = '001'                                                                                                              ") + msEnter
	GS007 += Alltrim("                AND A.DATAREF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                      ") + msEnter
	GS007 += Alltrim("                AND A.TPPROD = 'PP'                                                                                                               ") + msEnter
	GS007 += Alltrim("          GROUP BY A.REFERENCIA,                                                                                                                  ") + msEnter
	GS007 += Alltrim("                   A.TPPROD,                                                                                                                      ") + msEnter
	GS007 += Alltrim("                   A.ITCUS,                                                                                                                       ") + msEnter
	GS007 += Alltrim("                   A.QUANT)                                                                                                                       ") + msEnter
	GS007 += Alltrim("      SELECT PRODUTO = A.REFERENCIA,                                                                                                              ") + msEnter
	GS007 += Alltrim("             A.TPPROD,                                                                                                                            ") + msEnter
	GS007 += Alltrim("             A.ITCUS,                                                                                                                             ") + msEnter
	GS007 += Alltrim("             QTDREF = B.QUANT - A.QUANT                                                                                                           ") + msEnter
	GS007 += Alltrim("      FROM RACFULL A                                                                                                                              ") + msEnter
	GS007 += Alltrim("           INNER JOIN RACQTDE B ON B.REFERENCIA = A.REFERENCIA                                                                                    ") + msEnter
	GS007 += Alltrim("                                   AND A.QUANT <> B.QUANT                                                                                         ") + msEnter
	GS007 += Alltrim("      ORDER BY A.REFERENCIA,                                                                                                                      ") + msEnter
	GS007 += Alltrim("               A.ITCUS                                                                                                                            ") + msEnter
	GSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,GS007),'GS07',.T.,.T.)
	dbSelectArea("GS07")
	dbGoTop()
	ProcRegua(0)
	cvChq   := 0
	While GS07->(!Eof())

		gtProdt := GS07->PRODUTO
		gtTpPro := GS07->TPPROD
		gtQtdPr := GS07->QTDREF

		cvChq  ++
		IncProc("R-Tipo: " + gtTpPro + " Prod.: " + Alltrim(gtProdt) + " " + Alltrim(Str(cvChq)))

		If gtQtdPr <> 0

			dbSelectArea("Z44")
			dbSetOrder(2)
			RecLock("Z44",.T.)
			Z44->Z44_FILIAL := xFilial("Z44")
			Z44->Z44_DATARF := kfDataAte
			Z44->Z44_COD    := gtProdt
			Z44->Z44_ITCUS  := GS07->ITCUS
			Z44->Z44_TM     := "999"
			Z44->Z44_CF     := "RQ"
			Z44->Z44_CONTA  := ""
			Z44->Z44_RFPROD := gtProdt
			Z44->Z44_TPPROD := gtTpPro
			Z44->Z44_QUANT  := gtQtdPr
			Z44->Z44_CUSTO1 := 0
			Z44->Z44_FLAG   := "4"
			MsUnLockAll()

		EndIf

		dbSelectArea("GS07")
		GS07->(dbSkip())

	End

	GS07->(dbCloseArea())
	Ferase(GSIndex+GetDBExtension())
	Ferase(GSIndex+OrdBagExt())

	//                                                                   Preechimento de lacunas do Z1
	**************************************************************************************************
	HT004 := Alltrim(" WITH ITEMCUSTO                                                                                             ") + msEnter
	HT004 += Alltrim("      AS (SELECT TPCUS = Z29_TIPO,                                                                          ") + msEnter
	HT004 += Alltrim("                 TPPROD = Z29_APLTPP,                                                                       ") + msEnter
	HT004 += Alltrim("                 ITCUS = Z29_COD_IT,                                                                        ") + msEnter
	HT004 += Alltrim("                 DITCUS = Z29_DESCR,                                                                        ") + msEnter
	HT004 += Alltrim("                 RESUM = Z29_DRESUM                                                                         ") + msEnter
	HT004 += Alltrim("          FROM " + RetSqlName("Z29") + " Z29(NOLOCK)                                                        ") + msEnter
	HT004 += Alltrim("          WHERE Z29_FILIAL = '" + xFilial("Z29") + "'                                                       ") + msEnter
	HT004 += Alltrim("                AND Z29_EMPUSO LIKE '%" + cEmpAnt + "%'                                                     ") + msEnter
	HT004 += Alltrim("                AND Z29_ATIVO = 'S'                                                                         ") + msEnter
	HT004 += Alltrim("                AND Z29_TIPO <> 'Q '                                                                        ") + msEnter
	HT004 += Alltrim("                AND Z29_APLTPP <> 'XX'                                                                      ") + msEnter
	HT004 += Alltrim("                AND Z29.D_E_L_E_T_ = ' '                                                                    ") + msEnter
	HT004 += Alltrim("          UNION ALL                                                                                         ") + msEnter
	HT004 += Alltrim("          SELECT TPCUS = Z29_TIPO,                                                                          ") + msEnter
	HT004 += Alltrim("                 TPPROD = 'PP',                                                                             ") + msEnter
	HT004 += Alltrim("                 ITCUS = Z29_COD_IT,                                                                        ") + msEnter
	HT004 += Alltrim("                 DITCUS = Z29_DESCR,                                                                        ") + msEnter
	HT004 += Alltrim("                 RESUM = Z29_DRESUM                                                                         ") + msEnter
	HT004 += Alltrim("          FROM " + RetSqlName("Z29") + " Z29(NOLOCK)                                                        ") + msEnter
	HT004 += Alltrim("          WHERE Z29_FILIAL = '" + xFilial("Z29") + "'                                                       ") + msEnter
	HT004 += Alltrim("                AND Z29_EMPUSO LIKE '%" + cEmpAnt + "%'                                                     ") + msEnter
	HT004 += Alltrim("                AND Z29_ATIVO = 'S'                                                                         ") + msEnter
	HT004 += Alltrim("                AND Z29_TIPO <> 'Q '                                                                        ") + msEnter
	HT004 += Alltrim("                AND Z29_APLTPP = 'XX'                                                                       ") + msEnter
	HT004 += Alltrim("                AND Z29.D_E_L_E_T_ = ' '                                                                    ") + msEnter
	HT004 += Alltrim("          UNION ALL                                                                                         ") + msEnter
	HT004 += Alltrim("          SELECT TPCUS = Z29_TIPO,                                                                          ") + msEnter
	HT004 += Alltrim("                 TPPROD = 'PA',                                                                             ") + msEnter
	HT004 += Alltrim("                 ITCUS = Z29_COD_IT,                                                                        ") + msEnter
	HT004 += Alltrim("                 DITCUS = Z29_DESCR,                                                                        ") + msEnter
	HT004 += Alltrim("                 RESUM = Z29_DRESUM                                                                         ") + msEnter
	HT004 += Alltrim("          FROM " + RetSqlName("Z29") + " Z29(NOLOCK)                                                        ") + msEnter
	HT004 += Alltrim("          WHERE Z29_FILIAL = '" + xFilial("Z29") + "'                                                       ") + msEnter
	HT004 += Alltrim("                AND Z29_EMPUSO LIKE '%" + cEmpAnt + "%'                                                     ") + msEnter
	HT004 += Alltrim("                AND Z29_ATIVO = 'S'                                                                         ") + msEnter
	HT004 += Alltrim("                AND Z29_TIPO <> 'Q '                                                                        ") + msEnter
	HT004 += Alltrim("                AND Z29_APLTPP = 'XX'                                                                       ") + msEnter
	HT004 += Alltrim("                AND Z29.D_E_L_E_T_ = ' ')                                                                   ") + msEnter
	HT004 += Alltrim("      SELECT *                                                                                              ") + msEnter
	HT004 += Alltrim("      FROM ITEMCUSTO                                                                                        ") + msEnter
	HT004 += Alltrim("      WHERE '" + cEmpAnt + "' = '01'                                                                        ") + msEnter
	HT004 += Alltrim("      ORDER BY ITCUS                                                                                        ") + msEnter
	HTIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,HT004),'HT04',.T.,.T.)
	dbSelectArea("HT04")
	dbGoTop()
	ProcRegua(0)
	cvChq   := 0
	While HT04->(!Eof())

		gtProdt := IIF(HT04->TPPROD == "PP", "Z100007        ", "Z1000071       ")

		cvChq  ++
		IncProc("R-Tipo: " + HT04->TPPROD + " Prod.: " + Alltrim(gtProdt) + Alltrim(Str(cvChq)))

		dbSelectArea("Z44")
		dbSetOrder(2)
		If !dbSeek(xFilial("Z44") + dtos(kfDataAte) + gtProdt + HT04->ITCUS + "999")
			RecLock("Z44",.T.)
			Z44->Z44_FILIAL := xFilial("Z44")
			Z44->Z44_DATARF := kfDataAte
			Z44->Z44_COD    := gtProdt
			Z44->Z44_ITCUS  := HT04->ITCUS
			Z44->Z44_TM     := "999"
			Z44->Z44_CF     := "RQ"
			Z44->Z44_CONTA  := ""
			Z44->Z44_RFPROD := gtProdt
			Z44->Z44_TPPROD := HT04->TPPROD
			Z44->Z44_FLAG   := "5"
			MsUnLock()
		EndIf

		dbSelectArea("HT04")
		HT04->(dbSkip())

	End

	HT04->(dbCloseArea())
	Ferase(HTIndex+GetDBExtension())
	Ferase(HTIndex+OrdBagExt())

	//                                                            Acerta Quantidade do produto Redutor
	**************************************************************************************************
	XP011 := Alltrim(" UPDATE Z44 SET Z44_QUANT =                                                                                               ") + msEnter
	XP011 += Alltrim(" (                                                                                                                        ") + msEnter
	XP011 += Alltrim("     SELECT Z44_QUANT                                                                                                     ") + msEnter
	XP011 += Alltrim("     FROM " + RetSqlName("Z44") + " Z44                                                                                   ") + msEnter
	XP011 += Alltrim("     WHERE Z44_FILIAL = '" + xFilial("Z44") + "'                                                                          ") + msEnter
	XP011 += Alltrim("           AND Z44_DATARF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                  ") + msEnter
	XP011 += Alltrim("           AND Z44_ITCUS = '001'                                                                                          ") + msEnter
	XP011 += Alltrim("           AND SUBSTRING(Z44_COD, 1, 2) = 'Z1'                                                                            ") + msEnter
	XP011 += Alltrim("           AND '" + cEmpAnt + "' = '01'                                                                                   ") + msEnter
	XP011 += Alltrim("           AND Z44.D_E_L_E_T_ = ' '                                                                                       ") + msEnter
	XP011 += Alltrim(" )                                                                                                                        ") + msEnter
	XP011 += Alltrim(" FROM " + RetSqlName("Z44") + " Z44                                                                                       ") + msEnter
	XP011 += Alltrim(" WHERE Z44_FILIAL = '" + xFilial("Z44") + "'                                                                              ") + msEnter
	XP011 += Alltrim("       AND Z44_DATARF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                      ") + msEnter
	XP011 += Alltrim("       AND Z44_ITCUS <> '001'                                                                                             ") + msEnter
	XP011 += Alltrim("       AND SUBSTRING(Z44_COD, 1, 2) = 'Z1'                                                                                ") + msEnter
	XP011 += Alltrim("       AND '" + cEmpAnt + "' = '01'                                                                                       ") + msEnter
	XP011 += Alltrim("       AND Z44.D_E_L_E_T_ = ' '                                                                                           ") + msEnter
	U_BIAMsgRun("Aguarde... Gravando Registros CTB... ",,{|| msStaExcQy := TcSQLExec(XP011) })

	If msStaExcQy < 0

		msErroQuery := TCSQLError()
		Aviso('Erro na Query', "Erro na execução do processamento: " + msEnter + msEnter + msEnter + msErroQuery,{'Ok'},3) 

	Else

		Aviso('BIA503P','Fim do SEXTO Processamento...',{'Ok'})

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçao    ¦ BIA503S  ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 30.04.15 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Atualiza D3_YDELTA  - QUINTO PROCESSAMENTO                 ¦¦¦
¦¦¦          ¦ Liberada para importação SAP                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function BIA503S()

	Processa({|| RptSDet()})

Return

Static Function RptSDet()

	cHInicio := Time()

	xdAnoMes := space(006)
	If !fPergHotB()
		MsgSTOP("Processo Abortado!!!")
		Return
	EndIf
	MV_PAR01 := xdAnoMes

	kfDataDe  := stod(MV_PAR01+"01")
	kfDataAte := Ultimodia(kfDataDe)

	If !U_BiaULRAC(kfDataDe)
		Return
	EndIf

	//                                                        Atualiza DELTA para integração SAP - SD3
	**************************************************************************************************
	ZP003 := " UPDATE " + RetSqlName("SD3") + " SET D3_YDELTA = '" + dtos(date()-1) + "'
	ZP003 += "   FROM " + RetSqlName("SD3") + " WITH (NOLOCK)
	ZP003 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "'
	ZP003 += "    AND D3_EMISSAO BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'
	ZP003 += "    AND D_E_L_E_T_ = ' '

	U_BIAMsgRun("Aguarde... Atualizando DELTA para integração SAP - SD3",,{|| TCSQLExec(ZP003)})

	//                                                        Atualiza DELTA para integração SAP - Z44
	**************************************************************************************************
	ZP004 := " UPDATE " + RetSqlName("Z44") + " SET Z44_YDELTA = '" + dtos(date()-1) + "'
	ZP004 += "   FROM " + RetSqlName("Z44") + " WITH (NOLOCK)
	ZP004 += "  WHERE Z44_FILIAL = '" + xFilial("Z44") + "'
	ZP004 += "    AND Z44_DATARF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'
	ZP004 += "    AND D_E_L_E_T_ = ' '

	U_BIAMsgRun("Aguarde... Atualizando DELTA para integração SAP - Z44",,{|| TCSQLExec(ZP004)})

	If GetMV("MV_YULRAC") != NIL
		PutMV("MV_YULRAC",kfDataAte)
	EndIf

	Aviso('BIA503S','Fim do SÉTIMO Processamento...',{'Ok'})

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ BiaULRAC ¦ Autor ¦ Artur Antunes         ¦ Data ¦ 19/04/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User function BiaULRAC(dData)

	Local dDataMes := GetMv("MV_YULRAC")
	local aHlpP    := {}

	aHlpP  := {}
	aAdd(aHlpP, "Período Invalido!")
	aAdd(aHlpP, "Os cálculos de GMCD e RAC já foram ")
	aAdd(aHlpP, "processados! ")
	PutHelp("PMV_YULRAC", aHlpP, aHlpP, aHlpP, .T.)
	aHlpP  := {}
	aAdd(aHlpP, "Favor verificar o parâmetro MV_YULRAC " )
	PutHelp("SMV_YULRAC", aHlpP, aHlpP, aHlpP, .T.)

	If dDataMes < dData
		lRetorna := .T.
	Else
		lRetorna := .F.
		Help(" ",1,"MV_YULRAC")
	EndIf

Return lRetorna

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fPergHotB ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 12/12/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fPergHotB()

	Local bProcOk  := .T.
	Local aPergs 	:= {}
	Local cLoad	    := 'BIA503A' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	xdAnoMes        := space(006)

	aAdd( aPergs ,{1,"Ano/Mes:"                      ,xdAnoMes    ,"@!","NAOVAZIO()",,'.T.',015,.F.})	

	If ParamBox(aPergs ,"Parâmetros",,,,,,,,cLoad,.T.,.T.)      
		xdAnoMes    := ParamLoad(cFileName,,1,xdAnoMes)
	Else
		bProcOk := .F.
	Endif

Return ( bProcOk ) 
