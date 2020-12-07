#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA739
@author Marcos Alberto Soprani
@since 02/10/13
@version 1.0
@description Fechamento Mensal de Estoque
@obs Estoque e Custos
@type function
/*/

User Function BIA739()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local _cAlias
	Local _cDataDe
	Local _cDataAte

	fPerg := "BIA739"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA739 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase < GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser maior ou igual a data de fechamento do mês.","BIA739 - Data de Fechamento!!!")
		Return
	EndIf

	/*If cEmpAnt <> "01"
	MsgSTOP("Esta rotina está configurada para ser processada apenas na empresa 01", "BIA739 - Configuração de Empresa!!!")
	Return
	EndIf*/

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA739",fPerg)

	oExcel := FWMSEXCEL():New()

	//                    Acerta a Conta contábil dos movimento de PP no mês até que seja ajustado o cadastro de produto. Qualquer data maior que 01/08/14
	//                                                                                                                                                e PA
	//****************************************************************************************************************************************************
	UX005 := " UPDATE "+RetSqlName("SD3")+" SET D3_CONTA = '11307001'
	UX005 += "   FROM "+RetSqlName("SD3")
	UX005 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	UX005 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	UX005 += "    AND D3_TIPO = 'PP'
	UX005 += "    AND D3_ESTORNO = ' '
	UX005 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	UX005 += "    AND D_E_L_E_T_ = ' '
	TCSQLExec(UX005)

	UX007 := " UPDATE "+RetSqlName("SD3")+" SET D3_CONTA = '11306001'
	UX007 += "   FROM "+RetSqlName("SD3")
	UX007 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	UX007 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	UX007 += "    AND D3_TIPO = 'PA'
	UX007 += "    AND D3_ESTORNO = ' '
	UX007 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	UX007 += "    AND D_E_L_E_T_ = ' '
	TCSQLExec(UX007)

	If cEmpAnt == "05"
		SX003 := " WITH PDEMAND AS (SELECT D3_OP NUMOP "
		SX003 += "                    FROM " + RetSqlName("SD3") + " "
		SX003 += "                   WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
		SX003 += "                     AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
		SX003 += "                     AND D3_TM = '010' "
		SX003 += "                     AND D3_TIPO = 'PA' "
		SX003 += "                     AND D3_YRFCUST = 'PRODUCTION ON DEMAND' "
		SX003 += "                     AND D_E_L_E_T_ = ' ') "
		SX003 += " UPDATE " + RetSqlName("SD3") + " SET "
		SX003 += "                   D3_YRFCUST = 'PRODUCTION ON DEMAND', "
		SX003 += "                   D3_CONTA = CASE "
		SX003 += "                                WHEN D3_TIPO = 'ME' THEN '11306001' "
		SX003 += "                                ELSE D3_CONTA "
		SX003 += "                              END "
		SX003 += "   FROM " + RetSqlName("SD3") + " SD3 "
		SX003 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
		SX003 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
		SX003 += "    AND D3_TM <> '010' "
		SX003 += "    AND SD3.D_E_L_E_T_ = ' ' "
		SX003 += "    AND SD3.D3_ESTORNO = ' ' "
		SX003 += "    AND SD3.D3_OP IN(SELECT NUMOP "
		SX003 += "                       FROM PDEMAND) "
		TCSQLExec(SX003)
	EndIf

	//****************************************************************************************************************************************************
	nxPlan := "Planilha 01"
	nxTabl := "Verificar contas contábeis dos itens baixados automaticamente para os apontamentos de Produção"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "TP_PROD_OP"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "GR_PROD_OP"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CT_PROD_OP"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CTA_REQ"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCRIC_CTA"     ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TIP_REQ"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "GRP_REQ"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTAD"          ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA_CAD_RE"    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "D_CONTA_CAD_RE"  ,1,1)

	XY001 := " SELECT SB1.B1_TIPO TP_PROD_OP,
	XY001 += "        SB1.B1_GRUPO GR_PROD_OP,
	XY001 += "        SB1.B1_CONTA CT_PROD_OP,
	XY001 += "        D3_CONTA CTA_REQ,
	XY001 += "        CT1.CT1_DESC01 DCTA_REQ,
	XY001 += "        D3_TIPO TIP_REQ,
	XY001 += "        D3_GRUPO GRP_REQ,
	XY001 += "        COUNT(*) CONTAD,
	XY001 += "        XB1.B1_CONTA B1_CONTA,
	XY001 += "        XCT1.CT1_DESC01 D_B1_CONTA
	XY001 += "   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	XY001 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 WITH (NOLOCK) ON C2_FILIAL = '"+xFilial("SC2")+"'
	XY001 += "                       AND C2_NUM = SUBSTRING(D3_OP,1,6)
	XY001 += "                       AND C2_ITEM = SUBSTRING(D3_OP,7,2)
	XY001 += "                       AND C2_SEQUEN = SUBSTRING(D3_OP,9,3)
	XY001 += "                       AND SC2.D_E_L_E_T_ = ' '
	XY001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'
	XY001 += "                       AND SB1.B1_COD = C2_PRODUTO
	XY001 += "                       AND SB1.B1_TIPO IN('PI','PP','PA')
	XY001 += "                       AND SB1.D_E_L_E_T_ = ' '
	XY001 += "  INNER JOIN "+RetSqlName("SB1")+" XB1 WITH (NOLOCK) ON XB1.B1_FILIAL = '"+xFilial("SB1")+"'
	XY001 += "                       AND XB1.B1_COD = D3_COD
	XY001 += "                       AND XB1.D_E_L_E_T_ = ' '
	XY001 += "  INNER JOIN "+RetSqlName("CT1")+" CT1 WITH (NOLOCK) ON CT1.CT1_FILIAL = '"+xFilial("CT1")+"'
	XY001 += "                       AND CT1.CT1_CONTA = D3_CONTA
	XY001 += "                       AND CT1.D_E_L_E_T_ = ' '
	XY001 += "  INNER JOIN "+RetSqlName("CT1")+" XCT1 WITH (NOLOCK) ON XCT1.CT1_FILIAL = '"+xFilial("CT1")+"'
	XY001 += "                       AND XCT1.CT1_CONTA = XB1.B1_CONTA
	XY001 += "                       AND XCT1.D_E_L_E_T_ = ' '
	XY001 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	XY001 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	XY001 += "    AND SUBSTRING(D3_COD,1,3) <> 'MOD'
	XY001 += "    AND D3_OP <> '             '
	XY001 += "    AND D3_TM <> '010'
	XY001 += "    AND D3_ESTORNO = ' '
	XY001 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY001 += "    AND SD3.D_E_L_E_T_ = ' '
	XY001 += "  GROUP BY SB1.B1_TIPO,
	XY001 += "           SB1.B1_GRUPO,
	XY001 += "           SB1.B1_CONTA,
	XY001 += "           CT1.CT1_DESC01,
	XY001 += "           D3_CONTA,
	XY001 += "           XCT1.CT1_DESC01,
	XY001 += "           D3_TIPO,
	XY001 += "           D3_GRUPO,
	XY001 += "           XB1.B1_CONTA
	XY001 += "  ORDER BY SB1.B1_TIPO,
	XY001 += "           SB1.B1_GRUPO,
	XY001 += "           SB1.B1_CONTA,
	XY001 += "           D3_CONTA,
	XY001 += "           D3_GRUPO
	XYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XY001),'XY01',.F.,.T.)
	dbSelectArea("XY01")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento1")

		oExcel:AddRow(nxPlan, nxTabl, { XY01->TP_PROD_OP, XY01->GR_PROD_OP, XY01->CT_PROD_OP, XY01->CTA_REQ, XY01->DCTA_REQ, XY01->TIP_REQ, XY01->GRP_REQ, XY01->CONTAD, XY01->B1_CONTA, XY01->D_B1_CONTA })

		dbSelectArea("XY01")
		dbSkip()

	End

	XY01->(dbCloseArea())
	Ferase(XYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(XYcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	nxPlan := "Planilha 02"
	nxTabl := "Verificar contas contábeis usadas nos movimentações de ajuste de estoque"

	UL003 := " UPDATE " + RetSqlName("SD3") + " SET D3_CONTA = B1_YCTRIND "
	UL003 += "   FROM " + RetSqlName("SD3") + " SD3 "
	UL003 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "' "
	UL003 += "                       AND B1_COD = D3_COD "
	UL003 += "                       AND B1_YCTRIND <> D3_CONTA "
	UL003 += "                       AND SB1.D_E_L_E_T_ = ' ' "
	UL003 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	UL003 += "    AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	UL003 += "    AND D3_TM IN('120','720') "
	UL003 += "    AND D3_ESTORNO = ' ' "
	UL003 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	UL003 += "    AND SD3.D_E_L_E_T_ = ' ' "
	TCSQLExec(UL003)

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "TM"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TIPO"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "GRUPO"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA_REQ"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CTRIND"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA_PROD"      ,1,1)

	XY002 := " SELECT D3_TM,
	XY002 += "        D3_TIPO,
	XY002 += "        D3_GRUPO,
	XY002 += "        D3_CONTA,
	XY002 += "        B1_YCTRIND,
	XY002 += "        B1_CONTA
	XY002 += "   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	XY002 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
	XY002 += "                       AND B1_COD = D3_COD
	XY002 += "                       AND SB1.D_E_L_E_T_ = ' '
	XY002 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	XY002 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	XY002 += "    AND D3_TM IN('120','720')
	XY002 += "    AND D3_ESTORNO = ' '
	XY002 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY002 += "    AND SD3.D_E_L_E_T_ = ' '
	XY002 += "  GROUP BY D3_TM,
	XY002 += "           D3_TIPO,
	XY002 += "           D3_GRUPO,
	XY002 += "           D3_CONTA,
	XY002 += "           B1_YCTRIND,
	XY002 += "           B1_CONTA
	XYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XY002),'XY02',.F.,.T.)
	dbSelectArea("XY02")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento2")

		oExcel:AddRow(nxPlan, nxTabl, { XY02->D3_TM, XY02->D3_TIPO, XY02->D3_GRUPO, XY02->D3_CONTA, XY02->B1_YCTRIND, XY02->B1_CONTA })

		dbSelectArea("XY02")
		dbSkip()

	End

	XY02->(dbCloseArea())
	Ferase(XYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(XYcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	nxPlan := "Planilha 03"
	nxTabl := "Verificar OPs usadas durante o período"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "QTD_OP_SD3"      ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "QTD_OP_SC2"      ,3,2)

	XY003 := " WITH OPSPROD AS (SELECT DISTINCT D3_OP
	XY003 += "                    FROM " + RetSqlName("SD3") + " WITH (NOLOCK)
	XY003 += "                   WHERE D3_FILIAL = '" + xFilial("SD3") + "'
	XY003 += "                     AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	XY003 += "                     AND D3_OP <> '             '
	XY003 += "                     AND D3_ESTORNO = ' '
	XY003 += "                     AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY003 += "                     AND D_E_L_E_T_ = ' ')
	XY003 += " SELECT (SELECT COUNT(*)
	XY003 += "           FROM (SELECT D3_OP
	XY003 += "                   FROM " + RetSqlName("SD3") + " WITH (NOLOCK)
	XY003 += "                  WHERE D3_FILIAL = '" + xFilial("SD3") + "'
	XY003 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	XY003 += "                    AND D3_OP <> '             '
	XY003 += "                    AND D3_ESTORNO = ' '
	XY003 += "                    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY003 += "                    AND D_E_L_E_T_ = ' '
	XY003 += "                  GROUP BY D3_OP) AS TAB) QTD_OP_SD3,
	XY003 += "        (SELECT COUNT(*)
	XY003 += "           FROM " + RetSqlName("SC2") + " WITH (NOLOCK)
	XY003 += "          INNER JOIN OPSPROD OPR ON D3_OP = C2_NUM + C2_ITEM + C2_SEQUEN + '  '
	XY003 += "          WHERE C2_FILIAL = '" + xFilial("SC2") + "'
	XY003 += "            AND D_E_L_E_T_ = ' ') QTD_OP_SC2
	XYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XY003),'XY03',.F.,.T.)
	dbSelectArea("XY03")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento3")

		oExcel:AddRow(nxPlan, nxTabl, { XY03->QTD_OP_SD3, XY03->QTD_OP_SC2 })

		dbSelectArea("XY03")
		dbSkip()

	End

	XY03->(dbCloseArea())
	Ferase(XYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(XYcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	nxPlan := "Planilha 04"
	nxTabl := "Verificar C.Custo e Classe Valor usadas mas bloqueadas no cadastro"

	// Atualiza a CLVL da SC2 a partir do roteiro de Fabricação para Custo
	UL007 := " WITH LISTOPS "
	UL007 += "      AS (SELECT SUBSTRING(D3_OP, 1, 6) OPMAE, "
	UL007 += "                 SUBSTRING(D3_EMISSAO, 1, 6) DTREF "
	UL007 += "          FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK) "
	UL007 += "          WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	UL007 += "                AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	UL007 += "                AND D3_TM <> '010' "
	UL007 += "                AND D3_CF NOT IN('DE4', 'RE4', 'DE7', 'RE7', 'DE3', 'RE3') "
	UL007 += "                AND D3_OP <> '             ' "
	UL007 += "                AND D3_ESTORNO = ' ' "
	UL007 += "                AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	UL007 += "                AND D3_TIPO IN('PA', 'PP') "
	UL007 += "                AND SD3.D_E_L_E_T_ = ' ' "
	UL007 += "          GROUP BY SUBSTRING(D3_OP, 1, 6), "
	UL007 += "                   SUBSTRING(D3_EMISSAO, 1, 6)) "
	UL007 += "    UPDATE SC2 SET "
	UL007 += "            C2_CC = '3000', "
	UL007 += "            C2_CLVL = ISNULL(ZCV_CLVL, C2_CLVL) "
	UL007 += "      FROM " + RetSqlName("SC2") + " SC2 "
	UL007 += "           INNER JOIN LISTOPS LTS ON OPMAE = C2_NUM "
	UL007 += "           INNER JOIN " + RetSqlName("SB1")+ " SB1 ON B1_FILIAL = '" + xFilial("SB1") + "' "
	UL007 += "                                    AND B1_COD = C2_PRODUTO "
	UL007 += "                                    AND B1_TIPO IN('PA', 'PP') "
	UL007 += "                                    AND SB1.D_E_L_E_T_ = ' ' "
	UL007 += "           LEFT JOIN " + RetSqlName("ZCV") + " ZCV ON ZCV_FILIAL = '" + xFilial("ZCV") + "' "
	UL007 += "                                   AND SUBSTRING(ZCV_DTREF, 1, 6) = DTREF "
	UL007 += "                                   AND ZCV_FORMAT = SUBSTRING(C2_PRODUTO, 1, 2) "
	UL007 += "                                   AND ZCV_TPPROD = B1_TIPO "
	UL007 += "                                   AND (((ZCV_APPROD = '' "
	UL007 += "                                          AND ZCV_EXPROD = '') "
	UL007 += "                                         OR (RTRIM(C2_PRODUTO) LIKE '%' + RTRIM(ZCV_APPROD) + '%')) "
	UL007 += "                                        OR (ZCV_APPROD = '' "
	UL007 += "                                            AND RTRIM(C2_PRODUTO) NOT LIKE '%' + RTRIM(ZCV_EXPROD) + '%')) "
	UL007 += "                                   AND ZCV.D_E_L_E_T_ = ' ' "
	UL007 += "      WHERE C2_FILIAL = '" + xFilial("SC2") + "' "
	UL007 += "            AND SC2.D_E_L_E_T_ = ' ' "
	TCSQLExec(UL007)

	// Atualiza a CLVL da SD3 TM 010 e 711 a partir do roteiro de Fabricação para Custo
	XY003 := " UPDATE SD3 SET "
	XY003 += "        D3_CC = '3000',  "
	XY003 += "        D3_CLVL = ISNULL(ZCV_CLVL, D3_CLVL) "
	XY003 += " FROM " + RetSqlName("SD3") + " SD3 "
	XY003 += "      LEFT JOIN " + RetSqlName("ZCV") + " ZCV ON ZCV_FILIAL = '" + xFilial("ZCV") + "' "
	XY003 += "                              AND SUBSTRING(ZCV_DTREF, 1, 6) = SUBSTRING(D3_EMISSAO, 1, 6) "
	XY003 += "                              AND ZCV_FORMAT = SUBSTRING(D3_COD, 1, 2) "
	XY003 += "                              AND ZCV_TPPROD = D3_TIPO "
	XY003 += "                              AND (((ZCV_APPROD = '' "
	XY003 += "                                     AND ZCV_EXPROD = '') "
	XY003 += "                                    OR (RTRIM(D3_COD) LIKE '%' + RTRIM(ZCV_APPROD) + '%')) "
	XY003 += "                                   OR (ZCV_APPROD = '' "
	XY003 += "                                       AND RTRIM(D3_COD) NOT LIKE '%' + RTRIM(ZCV_EXPROD) + '%')) "
	XY003 += "                              AND ZCV.D_E_L_E_T_ = ' ' "
	XY003 += " WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	XY003 += "       AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	XY003 += "       AND D3_TM IN('010', '711') "
	XY003 += "       AND D3_TIPO IN('PA', 'PP') "
	XY003 += "       AND D3_ESTORNO = ' ' "
	XY003 += "       AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	XY003 += "       AND SD3.D_E_L_E_T_ = ' ' "
	TCSQLExec(XY003)

	// Atualiza a CLVL da SD3 TM <> 010 a partir da Ordem de Produção
	UT006 := " UPDATE SD3 SET "
	UT006 += "        D3_CC = '3000', "
	UT006 += "        D3_CLVL = C2_CLVL "
	UT006 += "   FROM " + RetSqlName("SD3") + " SD3 "
	UT006 += "  INNER JOIN " + RetSqlName("SC2") + " SC2 ON C2_FILIAL = '" + xFilial("SC2") + "' "
	UT006 += "                       AND SC2.C2_NUM = SUBSTRING(D3_OP,1,6) "
	UT006 += "                       AND SC2.C2_ITEM = SUBSTRING(D3_OP,7,2) "
	UT006 += "                       AND SC2.C2_SEQUEN = SUBSTRING(D3_OP,9,3) "
	UT006 += "                       AND SC2.D_E_L_E_T_ = ' ' "
	UT006 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	UT006 += "    AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	UT006 += "    AND D3_TM <> '010' "
	UT006 += "    AND D3_CF NOT IN('DE4', 'RE4', 'DE7', 'RE7', 'DE3', 'RE3') "
	UT006 += "    AND D3_ESTORNO = ' ' "
	UT006 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	UT006 += "    AND SD3.D_E_L_E_T_ = ' ' "
	TCSQLExec(UT006)

	// Atualiza a CLVL da SD3 TM = 211 a partir da TM 711
	VR079 := " UPDATE SD3 SET 
	VR079 += "        D3_CLVL = (SELECT ZD3.D3_CLVL "
	VR079 += "                     FROM " + RetSqlName("SD3") + " ZD3 "
	VR079 += "                    WHERE ZD3.R_E_C_N_O_ = (SELECT MAX(XD3.R_E_C_N_O_) "
	VR079 += "                                              FROM " + RetSqlName("SD3") + " XD3 "
	VR079 += "                                             WHERE XD3.D3_FILIAL = SD3.D3_FILIAL "
	VR079 += "                                                   AND XD3.D3_EMISSAO = SD3.D3_EMISSAO "
	VR079 += "                                                   AND D3_TM = '711' "
	VR079 += "                                                   AND XD3.R_E_C_N_O_ <= SD3.R_E_C_N_O_ "
	VR079 += "                                                   AND XD3.D_E_L_E_T_ = ' ')) "
	VR079 += "   FROM " + RetSqlName("SD3") + " SD3 "
	VR079 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	VR079 += "    AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	VR079 += "    AND D3_TM = '211' "
	VR079 += "    AND D3_ESTORNO = ' ' "
	VR079 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	VR079 += "    AND D_E_L_E_T_ = ' ' "
	TCSQLExec(VR079)

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "QTD_CC_ERRO"     ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "QTD_CLVL_ERRO"   ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "QTD_CC_VAZIO"    ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "QTD_CLVL_VAZIO"  ,3,2)

	jyAjust := .F.

	XY004 := " SELECT (SELECT COUNT(*)
	XY004 += "           FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)
	XY004 += "          INNER JOIN " + RetSqlName("CTT") + " CTT WITH (NOLOCK) ON CTT_FILIAL = '" + xFilial("CTT") + "'
	XY004 += "                               AND CTT_CUSTO = D3_CC
	XY004 += "                               AND CTT_BLOQ <> '2'
	XY004 += "                               AND CTT.D_E_L_E_T_ = ' '
	XY004 += "          WHERE D3_FILIAL = '" + xFilial("SD3") + "'
	XY004 += "            AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'
	XY004 += "            AND D3_CC <> '         '
	XY004 += "            AND D3_ESTORNO = ' '
	XY004 += "            AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY004 += "            AND SD3.D_E_L_E_T_ = ' ') CC_ERRO,
	XY004 += "        (SELECT COUNT(*)
	XY004 += "           FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)
	XY004 += "          INNER JOIN " + RetSqlName("CTH") + " CTH WITH (NOLOCK) ON CTH_FILIAL = '" + xFilial("CTH") + "'
	XY004 += "                               AND CTH_CLVL = D3_CLVL
	XY004 += "                               AND CTH_BLOQ <> '2'
	XY004 += "                               AND CTH.D_E_L_E_T_ = ' '
	XY004 += "          WHERE D3_FILIAL = '" + xFilial("SD3") + "'
	XY004 += "            AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'
	XY004 += "            AND D3_CLVL <> '         '
	XY004 += "            AND D3_ESTORNO = ' '
	XY004 += "            AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY004 += "            AND SD3.D_E_L_E_T_ = ' ') CLVL_ERRO,
	XY004 += "        (SELECT COUNT(*)
	XY004 += "           FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)
	XY004 += "          WHERE D3_FILIAL = '" + xFilial("SD3") + "'
	XY004 += "            AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'
	XY004 += "            AND D3_TM <> '010'
	XY004 += "            AND D3_CF NOT IN('DE4', 'RE4', 'DE7', 'RE7', 'DE3', 'RE3')
	XY004 += "            AND D3_CC = '         '
	XY004 += "            AND D3_ESTORNO = ' '
	XY004 += "            AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY004 += "            AND SD3.D_E_L_E_T_ = ' ') CC_VAZIO,
	XY004 += "        (SELECT COUNT(*)
	XY004 += "           FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)
	XY004 += "          WHERE D3_FILIAL = '" + xFilial("SD3") + "'
	XY004 += "            AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'
	XY004 += "            AND D3_TM <> '010'
	XY004 += "            AND D3_CF NOT IN('DE4', 'RE4', 'DE7', 'RE7', 'DE3', 'RE3')
	XY004 += "            AND D3_CLVL = '         '
	XY004 += "            AND D3_ESTORNO = ' '
	XY004 += "            AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY004 += "            AND SD3.D_E_L_E_T_ = ' ') CLVL_VAZIO
	XYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XY004),'XY04',.F.,.T.)
	dbSelectArea("XY04")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento4")

		oExcel:AddRow(nxPlan, nxTabl, { XY04->CC_ERRO, XY04->CLVL_ERRO, XY04->CC_VAZIO, XY04->CLVL_VAZIO })
		jyAjust := .T.

		dbSelectArea("XY04")
		dbSkip()

	End

	XY04->(dbCloseArea())
	Ferase(XYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(XYcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	nxPlan := "Planilha 05"
	nxTabl := "Verificar se as Contas Contábeis usadas no período estão bloqueadas"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCRIÇÃO"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "BLOQUEIO"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DATA INICIO"     ,1,1)

	XY005 := " SELECT *
	XY005 += "   FROM (SELECT D3_CONTA,
	XY005 += "                CT1_DESC01,
	XY005 += "                CT1_BLOQ,
	XY005 += "                CT1_DTEXIS
	XY005 += "           FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	XY005 += "           LEFT JOIN "+RetSqlName("CT1")+" CT1 WITH (NOLOCK) ON CT1_FILIAL = '"+xFilial("CT1")+"'
	XY005 += "                               AND CT1_CONTA = D3_CONTA
	XY005 += "                               AND CT1.D_E_L_E_T_ = ' '
	XY005 += "          WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	XY005 += "            AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	XY005 += "            AND D3_CF NOT IN('DE4', 'RE4', 'PR0', 'DE7', 'RE7', 'DE3', 'RE3')
	XY005 += "            AND D3_ESTORNO = ' '
	XY005 += "            AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY005 += "            AND SD3.D_E_L_E_T_ = ' '
	XY005 += "          GROUP BY D3_CONTA,
	XY005 += "                   CT1_DESC01,
	XY005 += "                   CT1_BLOQ,
	XY005 += "                   CT1_DTEXIS) AS TAB
	XY005 += "  WHERE CT1_BLOQ <> '2' OR CT1_DTEXIS > '"+dtos(MV_PAR01)+"'
	XY005 += "  ORDER BY D3_CONTA,
	XY005 += "           CT1_DESC01,
	XY005 += "           CT1_BLOQ,
	XY005 += "           CT1_DTEXIS
	XYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XY005),'XY05',.F.,.T.)
	dbSelectArea("XY05")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento5")

		oExcel:AddRow(nxPlan, nxTabl, { XY05->D3_CONTA, XY05->CT1_DESC01, XY05->CT1_BLOQ, dtoc(stod(XY05->CT1_DTEXIS)) })

		dbSelectArea("XY05")
		dbSkip()

	End

	XY05->(dbCloseArea())
	Ferase(XYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(XYcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	nxPlan := "Planilha 06"
	nxTabl := "Verificar existencia de registros de movimentação sem C.Custo e/ou Clvl"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TM"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NUMSEQ"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"           ,3,2)

	XY006 := " SELECT D3_DOC, D3_COD, D3_TM, D3_EMISSAO, D3_NUMSEQ, D3_QUANT
	XY006 += "   FROM " + RetSqlName("SD3") + " WITH (NOLOCK)
	XY006 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	XY006 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	XY006 += "    AND ( D3_CC = ' ' OR D3_CLVL = ' ' )
	XY006 += "    AND D3_CF NOT IN('DE4', 'RE4', 'PR0', 'DE7', 'RE7', 'DE3', 'RE3')
	XY006 += "    AND D3_ESTORNO = ' '
	XY006 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY006 += "    AND D_E_L_E_T_ = ' '
	XYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XY006),'XY06',.F.,.T.)
	dbSelectArea("XY06")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento6")

		oExcel:AddRow(nxPlan, nxTabl, { XY06->D3_DOC, XY06->D3_COD, XY06->D3_TM, dtoc(stod(XY06->D3_EMISSAO)), XY06->D3_NUMSEQ, XY06->D3_QUANT })

		dbSelectArea("XY06")
		dbSkip()

	End

	XY06->(dbCloseArea())
	Ferase(XYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(XYcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	nxPlan := "Planilha 07"
	nxTabl := "Verificar se contas cadastradas no cadastro de produto existem no plano de contas"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCRIÇÃO"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCR01"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "BLOQ"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DATA INICIO"     ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "MSBLQL"          ,1,1)

	XY007 := " SELECT *
	XY007 += "   FROM (SELECT B1_COD,
	XY007 += "                SUBSTRING(B1_DESC,1,50) DESCR,
	XY007 += "                B1_CONTA,
	XY007 += "                CT1_DESC01,
	XY007 += "                CT1_BLOQ,
	XY007 += "                CT1_DTEXIS,
	XY007 += "                B1_MSBLQL
	XY007 += "           FROM "+RetSqlName("SB1")+" SB1 WITH (NOLOCK)
	XY007 += "           LEFT JOIN "+RetSqlName("CT1")+" CT1 WITH (NOLOCK) ON CT1_FILIAL = '"+xFilial("CT1")+"'
	XY007 += "                               AND CT1_CONTA = B1_CONTA
	XY007 += "                               AND CT1.D_E_L_E_T_ = ' '
	XY007 += "          WHERE B1_FILIAL = '"+xFilial("SB1")+"'
	XY007 += "            AND B1_COD IN(SELECT D3_COD
	XY007 += "                            FROM " + RetSqlName("SD3") + " WITH (NOLOCK)
	XY007 += "                           WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	XY007 += "                             AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	XY007 += "                             AND D3_CF NOT IN('DE4', 'RE4', 'PR0', 'DE7', 'RE7', 'DE3', 'RE3')
	XY007 += "                             AND D3_ESTORNO = ' '
	XY007 += "                             AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY007 += "                             AND D_E_L_E_T_ = ' '
	XY007 += "                            GROUP BY D3_COD)
	XY007 += "            AND SB1.D_E_L_E_T_ = ' '
	XY007 += "          GROUP BY B1_COD,
	XY007 += "                   SUBSTRING(B1_DESC,1,50),
	XY007 += "                   B1_CONTA,
	XY007 += "                   CT1_DESC01,
	XY007 += "                   CT1_BLOQ,
	XY007 += "                   CT1_DTEXIS,
	XY007 += "                   B1_MSBLQL) AS TAB
	XY007 += "  WHERE CT1_DESC01 IS NULL
	XY007 += "  ORDER BY B1_CONTA,
	XY007 += "           B1_COD,
	XY007 += "           CT1_DESC01,
	XY007 += "           CT1_BLOQ,
	XY007 += "           CT1_DTEXIS
	XYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XY007),'XY07',.F.,.T.)
	dbSelectArea("XY07")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento7")

		oExcel:AddRow(nxPlan, nxTabl, { XY07->B1_COD, XY07->DESCR, XY07->B1_CONTA, XY07->CT1_DESC01, XY07->CT1_BLOQ, XY07->CT1_DTEXIS, XY07->B1_MSBLQL })

		dbSelectArea("XY07")
		dbSkip()

	End

	XY07->(dbCloseArea())
	Ferase(XYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(XYcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	nxPlan := "Planilha 08"
	nxTabl := "Verificar TM 499 para movimentos de baixa automática"

	XY008 := " UPDATE "+RetSqlName("SD3")+" SET D3_TM = '999', D3_CF = 'RE1'
	XY008 += "   FROM " + RetSqlName("SD3")
	XY008 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	XY008 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	XY008 += "    AND D3_OP <> '             '
	XY008 += "    AND D3_TM = '499'
	XY008 += "    AND D3_ESTORNO = ' '
	XY008 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY008 += "    AND D_E_L_E_T_ = ' '
	TCSQLExec(XY008)

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TM"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NUMSEQ"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"           ,3,2)

	jyAjust := .F.

	XY008 := " SELECT D3_DOC, D3_COD, D3_TM, D3_EMISSAO, D3_NUMSEQ, D3_QUANT
	XY008 += "   FROM " + RetSqlName("SD3") + " WITH (NOLOCK)
	XY008 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	XY008 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	XY008 += "    AND D3_OP <> '             '
	XY008 += "    AND D3_TM = '499'
	XY008 += "    AND D3_ESTORNO = ' '
	XY008 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY008 += "    AND D_E_L_E_T_ = ' '
	XYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XY008),'XY08',.F.,.T.)
	dbSelectArea("XY08")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento8")

		oExcel:AddRow(nxPlan, nxTabl, { XY08->D3_DOC, XY08->D3_COD, XY08->D3_TM, dtoc(stod(XY08->D3_EMISSAO)), XY08->D3_NUMSEQ, XY08->D3_NUMSEQ })
		jyAjust := .T.

		dbSelectArea("XY08")
		dbSkip()

	End

	XY08->(dbCloseArea())
	Ferase(XYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(XYcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	nxPlan := "Planilha 09"
	nxTabl := "Listar registro da movimentação interna (SD3) que apresenta conta contábil inexistente."

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "C.CONTABIL"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TM"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NUMSEQ"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"           ,3,2)

	XY009 := " SELECT D3_DOC,
	XY009 += "        D3_COD,
	XY009 += "        D3_CONTA,
	XY009 += "        D3_TM,
	XY009 += "        D3_EMISSAO,
	XY009 += "        D3_NUMSEQ,
	XY009 += "        D3_QUANT
	XY009 += "   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	XY009 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	XY009 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	XY009 += "    AND D3_CONTA NOT IN(SELECT CT1_CONTA
	XY009 += "                          FROM "+RetSqlName("CT1") + " WITH (NOLOCK)
	XY009 += "                         WHERE CT1_FILIAL = '"+xFilial("CT1")+"'
	XY009 += "                           AND CT1_BLOQ <> '1'
	XY009 += "                           AND D_E_L_E_T_ = ' ')
	XY009 += "    AND D3_TM <> '010'
	XY009 += "    AND D3_CF NOT IN('DE4', 'RE4', 'DE7', 'RE7', 'DE3', 'RE3')
	XY009 += "    AND D3_TIPO NOT IN('PA','PP')
	XY009 += "    AND D3_ESTORNO = ' '
	XY009 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY009 += "    AND SUBSTRING(D3_COD,1,3) <> 'MOD'
	XY009 += "    AND SD3.D_E_L_E_T_ = ' '
	XYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XY009),'XY09',.F.,.T.)
	dbSelectArea("XY09")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento9")

		oExcel:AddRow(nxPlan, nxTabl, { XY09->D3_DOC, XY09->D3_COD, XY09->D3_CONTA, XY09->D3_TM, dtoc(stod(XY09->D3_EMISSAO)), XY09->D3_NUMSEQ, XY09->D3_QUANT })

		dbSelectArea("XY09")
		dbSkip()

	End

	XY09->(dbCloseArea())
	Ferase(XYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(XYcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	nxPlan := "Planilha 10"
	nxTabl := "Listar registro das produções e suas classe valores associadas."

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "TIPO"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FORMATO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"         ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCRICAO"       ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVL"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"           ,3,2)

	XY010 := " SELECT D3_TIPO,
	XY010 += "        B1_YFORMAT,
	XY010 += "        D3_COD,
	XY010 += "        SUBSTRING(B1_DESC,1,50) DESCR,
	XY010 += "        D3_CLVL,
	XY010 += "        SUM(D3_QUANT) QUANT
	XY010 += "   FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK)
	XY010 += "  INNER JOIN " + RetSqlName("SB1") + " SB1 WITH (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "'
	XY010 += "                       AND B1_COD = D3_COD
	XY010 += "                       AND SB1.D_E_L_E_T_ = ' '
	XY010 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "'
	XY010 += "    AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'
	XY010 += "    AND D3_TM = '010'
	XY010 += "    AND D3_TIPO IN('PP','PA')
	XY010 += "    AND D3_ESTORNO = ' '
	XY010 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY010 += "    AND SD3.D_E_L_E_T_ = ' '
	XY010 += "  GROUP BY D3_TIPO,
	XY010 += "           B1_YFORMAT,
	XY010 += "           D3_COD,
	XY010 += "           SUBSTRING(B1_DESC,1,50),
	XY010 += "           D3_CLVL
	XY010 += "  ORDER BY D3_TIPO,
	XY010 += "           B1_YFORMAT,
	XY010 += "           D3_COD,
	XY010 += "           SUBSTRING(B1_DESC,1,50),
	XY010 += "           D3_CLVL
	XYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XY010),'XY10',.F.,.T.)
	dbSelectArea("XY10")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento10")

		oExcel:AddRow(nxPlan, nxTabl, { XY10->D3_TIPO, XY10->B1_YFORMAT, XY10->D3_COD, XY10->DESCR, XY10->D3_CLVL, XY10->QUANT })

		dbSelectArea("XY10")
		dbSkip()

	End

	XY10->(dbCloseArea())
	Ferase(XYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(XYcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	nxPlan := "Planilha 11"
	nxTabl := "RETIRADO DE USO ATÉ SEGUNDA ORDEM - 20150803 - Lista o número dos documentos que apresentaram duplicidade na importação de etiquetas"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"             ,1,1)

	ZS005 := " SELECT D3_DOC
	ZS005 += "   FROM "+RetSqlName("SD3")+" WITH (NOLOCK)
	ZS005 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	ZS005 += "    AND D3_YIDECO IN(SELECT D3_YIDECO
	ZS005 += "                       FROM "+RetSqlName("SD3")+" WITH (NOLOCK)
	ZS005 += "                      WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	ZS005 += "                        AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	ZS005 += "                        AND D3_TM = '010'
	ZS005 += "                        AND D3_TIPO = 'PA'
	ZS005 += "                        AND D3_ESTORNO = ' '
	ZS005 += "                        AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	ZS005 += "                        AND D_E_L_E_T_ = ' '
	ZS005 += "                      GROUP BY D3_YIDECO
	ZS005 += "                      HAVING COUNT(*) > 1)
	ZS005 += "   AND D3_TM = '010'
	ZS005 += "   AND D3_TIPO = 'PA'
	ZS005 += "   AND 1 = 2
	ZS005 += "   AND D_E_L_E_T_ = ' '
	ZScIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZS005),'ZS05',.F.,.T.)
	dbSelectArea("ZS05")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento11")

		oExcel:AddRow(nxPlan, nxTabl, { ZS05->D3_DOC })

		dbSelectArea("ZS05")
		dbSkip()

	End

	ZS05->(dbCloseArea())
	Ferase(ZScIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ZScIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	nxPlan := "Planilha 12"
	nxTabl := "Contas contábeis registradas indevidamente no cadastro de produto"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCRICAO"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TIPO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CTAIND"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CTAADM"             ,1,1)

	SW003 := " SELECT B1_COD,
	SW003 += "        SUBSTRING(B1_DESC,1,70) DESCR,
	SW003 += "        B1_TIPO,
	SW003 += "        B1_CONTA,
	SW003 += "        B1_YCTRIND,
	SW003 += "        B1_YCTRADM
	SW003 += "   FROM " + RetSqlName("SB1") + " WITH (NOLOCK)
	SW003 += "  WHERE B1_COD < 'A'
	SW003 += "    AND ( B1_CONTA = B1_YCTRIND OR B1_CONTA = B1_YCTRADM )
	SW003 += "    AND D_E_L_E_T_ = ' '
	SW003 += "    AND EXISTS (SELECT *
	SW003 += "                  FROM " + RetSqlName("SD3") + " WITH (NOLOCK)
	SW003 += "                 WHERE D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	SW003 += "                   AND D3_COD = B1_COD
	SW003 += "                   AND D3_ESTORNO = ' '
	SW003 += "                   AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	SW003 += "                   AND D_E_L_E_T_ = ' ')
	SW003 += "  ORDER BY B1_COD
	SWcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,SW003),'SW03',.F.,.T.)
	dbSelectArea("SW03")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento12")

		oExcel:AddRow(nxPlan, nxTabl, { SW03->B1_COD, SW03->DESCR, SW03->B1_TIPO, SW03->B1_CONTA, SW03->B1_YCTRIND, SW03->B1_YCTRADM })

		dbSelectArea("SW03")
		dbSkip()

	End

	SW03->(dbCloseArea())
	Ferase(SWcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(SWcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	// Planilha incluída em 08/01/15 durante geração da RAC do mês 12 de 2014.
	nxPlan := "Planilha 13"
	nxTabl := "Produção de PA sem baixa de PP ou PS"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "COD"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCRICAO"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"              ,3,2)

	XY027 := " WITH
	XY027 += "      MOVPROD AS (SELECT D3_EMISSAO, D3_DOC, D3_COD, D3_QUANT, D3_NUMSEQ
	XY027 += "                    FROM " + RetSqlName("SD3") + " WITH (NOLOCK)
	XY027 += "                   WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	XY027 += "                     AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	XY027 += "                     AND D3_TIPO = 'PA'
	XY027 += "                     AND D3_TM = '010'
	XY027 += "                     AND D3_ESTORNO = ' '
	XY027 += "                     AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY027 += "                     AND D_E_L_E_T_ = ' ')
	XY027 += " ,
	XY027 += "      MOVREC1 AS (SELECT D3_NUMSEQ
	XY027 += "                    FROM " + RetSqlName("SD3") + " WITH (NOLOCK)
	XY027 += "                   WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	XY027 += "                     AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	XY027 += "                     AND D3_TIPO IN('PP','PA')
	XY027 += "                     AND D3_TM = '999'
	XY027 += "                     AND D3_CF = 'RE1'
	XY027 += "                     AND D3_ESTORNO = ' '
	XY027 += "                     AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	XY027 += "                     AND D_E_L_E_T_ = ' ')
	XY027 += " SELECT PROD.D3_EMISSAO,
	XY027 += "        PROD.D3_DOC,
	XY027 += "        PROD.D3_COD,
	//XY027 += "        SUBSTRING(B1_DESC,1,70) DESCR,
	XY027 += "        PROD.D3_QUANT
	XY027 += "   FROM MOVPROD PROD
	XY027 += "   FULL OUTER JOIN MOVREC1 REC1 ON REC1.D3_NUMSEQ = PROD.D3_NUMSEQ
	XY027 += "  WHERE REC1.D3_NUMSEQ IS NULL OR PROD.D3_NUMSEQ IS NULL
	XYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,XY027),'XY27',.F.,.T.)
	dbSelectArea("XY27")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento13")

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+XY27->D3_COD))

		oExcel:AddRow(nxPlan, nxTabl, { dtoc(stod(XY27->D3_EMISSAO)), XY27->D3_DOC, XY27->D3_COD, Substr(SB1->B1_DESC,1,70), XY27->D3_QUANT })

		dbSelectArea("XY27")
		dbSkip()

	End

	XY27->(dbCloseArea())
	Ferase(XYcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(XYcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	// Implantado em 02/07/15 durante o fechamento do custo de junho de 2015, pois pelo segundo mês notas foram lançados sem TES
	nxPlan := "Planilha 14"
	nxTabl := "Itens de nota fiscal sem TES"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"                   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SERIE"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FORNECE"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOJA"                  ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DTDIGIT"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "COD"                   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CF"                    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"                 ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "TOTAL"                 ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "VALICM"                ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "VALIMP5"               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "VALIMP6"               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUSTO"                 ,3,2)

	KH004 := " SELECT D1_DOC,
	KH004 += "        D1_SERIE,
	KH004 += "        D1_FORNECE,
	KH004 += "        D1_LOJA,
	KH004 += "        D1_DTDIGIT,
	KH004 += "        D1_EMISSAO,
	KH004 += "        D1_COD,
	KH004 += "        D1_CF,
	KH004 += "        D1_QUANT,
	KH004 += "        D1_TOTAL,
	KH004 += "        D1_VALICM,
	KH004 += "        D1_VALIMP5,
	KH004 += "        D1_VALIMP6,
	KH004 += "        D1_CUSTO
	KH004 += "   FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK)
	KH004 += "  INNER JOIN "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) ON F1_FILIAL = '"+xFilial("SF1")+"'
	KH004 += "                                     AND F1_DOC = D1_DOC
	KH004 += "                                     AND F1_SERIE = D1_SERIE
	KH004 += "                                     AND F1_FORNECE = D1_FORNECE
	KH004 += "                                     AND F1_LOJA = D1_LOJA
	KH004 += "                                     AND F1_DTDIGIT = D1_DTDIGIT
	KH004 += "                                     AND F1_STATUS <> ' '
	KH004 += "                                     AND SF1.D_E_L_E_T_ = ' '
	KH004 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
	KH004 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	KH004 += "    AND D1_TES = '   '
	KH004 += "    AND SD1.D_E_L_E_T_ = ' '
	KHcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,KH004),'KH04',.F.,.T.)
	dbSelectArea("KH04")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento14")

		oExcel:AddRow(nxPlan, nxTabl, { KH04->D1_DOC, KH04->D1_SERIE, KH04->D1_FORNECE, KH04->D1_LOJA, dtoc(stod(KH04->D1_DTDIGIT)), dtoc(stod(KH04->D1_EMISSAO)), KH04->D1_COD, KH04->D1_CF, KH04->D1_QUANT, KH04->D1_TOTAL, KH04->D1_VALICM, KH04->D1_VALIMP5, KH04->D1_VALIMP6, KH04->D1_CUSTO })

		dbSelectArea("KH04")
		dbSkip()

	End

	KH04->(dbCloseArea())
	Ferase(KHcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(KHcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	// Implantado em 07/07/15 durante o fechamento do custo de junho de 2015, pois mês sim, mês não dá diferença de PP e PA na Incesa...
	nxPlan := "Planilha 15"
	nxTabl := "Diferença entre PP e PA"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"                 ,3,2)

	HG003 := " SELECT *
	HG003 += "   FROM (SELECT PRODUT,
	HG003 += "                ROUND(SUM(QUANT),2) QUANT
	HG003 += "           FROM (SELECT D3_TIPO,
	HG003 += "                        PRODUT,
	HG003 += "                        CASE
	HG003 += "                          WHEN D3_TIPO = 'PP' THEN SUM(QUANT) * (-1)
	HG003 += "                          ELSE SUM(QUANT)
	HG003 += "                        END QUANT
	HG003 += "                   FROM (SELECT D3_TIPO,
	HG003 += "                                D3_TM,
	HG003 += "                                SUBSTRING(D3_COD,1,7) PRODUT,
	HG003 += "                                CASE
	HG003 += "                                  WHEN D3_TM > '500' THEN SUM(D3_QUANT) * (-1)
	HG003 += "                                  ELSE SUM(D3_QUANT)
	HG003 += "                                END QUANT
	HG003 += "                           FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	HG003 += "                          INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	HG003 += "                                               AND B1_COD = D3_COD
	HG003 += "                                               AND B1_YTPPROD <> 'RP'
	HG003 += "                                               AND SB1.D_E_L_E_T_ = ' '
	HG003 += "                          WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	HG003 += "                            AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	HG003 += "                            AND D3_TM IN('010','711')
	HG003 += "                            AND D3_TIPO IN('PA','PP')
	HG003 += "                            AND SUBSTRING(D3_COD,1,2) NOT IN('B9','BO','C6')
	HG003 += "                            AND D3_ESTORNO = ' '
	HG003 += "                            AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	HG003 += "                            AND SD3.D_E_L_E_T_ = ' '
	HG003 += "                          GROUP BY D3_TIPO,
	HG003 += "                                   D3_TM,
	HG003 += "                                   SUBSTRING(D3_COD,1,7)) AS TABLW
	HG003 += "                   GROUP BY D3_TIPO,
	HG003 += "                            PRODUT) AS TACJ
	HG003 += "           GROUP BY PRODUT) AS TABEL
	HG003 += "   WHERE QUANT <> 0
	HGcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,HG003),'HG03',.F.,.T.)
	dbSelectArea("HG03")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento15")

		oExcel:AddRow(nxPlan, nxTabl, { HG03->PRODUT, HG03->QUANT })

		dbSelectArea("HG03")
		dbSkip()

	End

	HG03->(dbCloseArea())
	Ferase(HGcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(HGcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	// Implantado em 06/08/15 durante o fechamento do custo de julho de 2015, que a quantidade de etiquetas produzidas foi totalmente cancela gerando problema para RAC
	nxPlan := "Planilha 16"
	nxTabl := "Produção totalmente cancelada no mês"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCRICAO"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"                 ,3,2)

	RT003 := " WITH CHQCANC AS (SELECT D3_COD, SUM(D3_QUANT) D3_QUANT
	RT003 += "                    FROM (SELECT D3_COD,
	RT003 += "                                 D3_TM,
	RT003 += "                                 CASE
	RT003 += "                                   WHEN D3_TM > '500' THEN D3_QUANT * (-1)
	RT003 += "                                   ELSE D3_QUANT
	RT003 += "                                 END D3_QUANT
	RT003 += "                            FROM "+RetSqlName("SD3")+" WITH (NOLOCK)
	RT003 += "                           WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	RT003 += "                             AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	RT003 += "                             AND D3_TM IN('010','711')
	RT003 += "                             AND D3_TIPO IN('PA','PP')
	RT003 += "                             AND D3_ESTORNO = ' '
	RT003 += "                             AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	RT003 += "                             AND D_E_L_E_T_ = ' ') AS TABLR
	RT003 += "                    GROUP BY D3_COD)
	RT003 += " SELECT D3_COD,
	RT003 += "        SUBSTRING(B1_DESC,1,50) DESCR,
	RT003 += "        D3_QUANT
	RT003 += "   FROM CHQCANC
	RT003 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	RT003 += "                       AND B1_COD = D3_COD
	RT003 += "                       AND SB1.D_E_L_E_T_ = ' '
	RT003 += "  WHERE D3_QUANT = 0
	RTcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT003),'RT03',.F.,.T.)
	dbSelectArea("RT03")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento16")

		oExcel:AddRow(nxPlan, nxTabl, { RT03->D3_COD, RT03->DESCR, RT03->D3_QUANT })

		dbSelectArea("RT03")
		dbSkip()

	End

	RT03->(dbCloseArea())
	Ferase(RTcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(RTcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	// Implantado em 06/08/15 durante o fechamento do custo de julho de 2015, que a quantidade de etiquetas produzidas foi totalmente cancela gerando problema para RAC
	nxPlan := "Planilha 17"
	nxTabl := "Verificação das Grandes contas - Embalagem, Esmalte, Massa"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"                   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TIPO"                  ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"                 ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "NUMSEQ"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EMBALAGEM"             ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "ESMALTE"               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "MASSA"                 ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CHQ_EMB"               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CHQ_ESM"               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CHQ_MAS"               ,3,2)

	QP002 := " WITH INSUMOS AS (SELECT EMISS,
	QP002 += "                         NUMSEQ,
	QP002 += "                         SUM(EMBALAGEM) EMB,
	QP002 += "                         SUM(ESMALTE) ESM,
	QP002 += "                         SUM(MASSA) MAS
	QP002 += "                    FROM (SELECT XD3.D3_EMISSAO EMISS,
	QP002 += "                                 XD3.D3_NUMSEQ NUMSEQ,
	QP002 += "                                 CASE
	QP002 += "                                   WHEN SUBSTRING(XD3.D3_CONTA,1,5) = '61104' THEN COUNT(*)
	QP002 += "                                   ELSE 0
	QP002 += "                                 END EMBALAGEM,
	QP002 += "                                 CASE
	QP002 += "                                   WHEN SUBSTRING(XD3.D3_CONTA,1,5) = '61102' THEN COUNT(*)
	QP002 += "                                   ELSE 0
	QP002 += "                                 END ESMALTE,
	QP002 += "                                 CASE
	QP002 += "                                   WHEN SUBSTRING(XD3.D3_CONTA,1,5) = '61101' THEN COUNT(*)
	QP002 += "                                   ELSE 0
	QP002 += "                                 END MASSA
	QP002 += "                            FROM "+RetSqlName("SD3")+" XD3
	QP002 += "                           INNER JOIN "+RetSqlName("SC2")+" SC2 ON C2_FILIAL = '"+xFilial("SC2")+"'
	QP002 += "                                                AND C2_NUM = SUBSTRING(D3_OP,1,6)
	QP002 += "                                                AND C2_ITEM = SUBSTRING(D3_OP,7,2)
	QP002 += "                                                AND C2_SEQUEN = SUBSTRING(D3_OP,9,3)
	QP002 += "                                                AND SC2.D_E_L_E_T_ = ' '
	QP002 += "                           INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	QP002 += "                                                AND B1_COD = C2_PRODUTO
	QP002 += "                                                AND B1_TIPO IN('PA','PP')
	QP002 += "                                                AND SC2.D_E_L_E_T_ = ' '
	QP002 += "                           WHERE XD3.D3_FILIAL = '"+xFilial("SD3")+"'
	QP002 += "                             AND XD3.D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	QP002 += "                             AND XD3.D3_TM <> '010'
	QP002 += "                             AND XD3.D3_ESTORNO = ' '
	QP002 += "                             AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	QP002 += "                             AND XD3.D_E_L_E_T_ = ' '
	QP002 += "                           GROUP BY XD3.D3_EMISSAO, XD3.D3_NUMSEQ, SUBSTRING(XD3.D3_CONTA,1,5) ) AS TABK
	QP002 += "                    GROUP BY EMISS,
	QP002 += "                             NUMSEQ)
	QP002 += " SELECT D3_EMISSAO,
	QP002 += "        D3_DOC,
	QP002 += "        D3_COD,
	QP002 += "        D3_TIPO,
	QP002 += "        D3_QUANT,
	QP002 += "        D3_NUMSEQ,
	QP002 += "        EMB,
	QP002 += "        ESM,
	QP002 += "        MAS
	QP002 += "   FROM "+RetSqlName("SD3")+" SD3
	QP002 += "   LEFT JOIN INSUMOS INSM ON INSM.EMISS = SD3.D3_EMISSAO
	QP002 += "                         AND INSM.NUMSEQ = SD3.D3_NUMSEQ
	QP002 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	QP002 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	QP002 += "    AND D3_TM = '010'
	QP002 += "    AND D3_TIPO IN('PA','PP')
	QP002 += "    AND D3_ESTORNO = ' '
	QP002 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	QP002 += "    AND SD3.D_E_L_E_T_ = ' '
	QPcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QP002),'QP02',.F.,.T.)
	dbSelectArea("QP02")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento17")

		xEmbOk := "Verdadeiro"
		If QP02->D3_TIPO == "PP" .and. QP02->EMB <> 0
			xEmbOk := "Falso"
		ElseIf QP02->D3_TIPO == "PA" .and. QP02->EMB == 0
			xEmbOk := "Falso"
		EndIf
		xEsmOk := "Verdadeiro"
		If QP02->D3_TIPO == "PP" .and. QP02->ESM == 0
			xEsmOk := "Falso"
		ElseIf QP02->D3_TIPO == "PA" .and. QP02->ESM <> 0
			xEsmOk := "Falso"
		EndIf
		xMasOk := "Verdadeiro"
		If QP02->D3_TIPO == "PP" .and. QP02->MAS == 0
			xMasOk := "Falso"
		ElseIf QP02->D3_TIPO == "PA" .and. QP02->MAS <> 0
			xMasOk := "Falso"
		EndIf

		oExcel:AddRow(nxPlan, nxTabl, { dtoc(stod(QP02->D3_EMISSAO))      ,;
		QP02->D3_DOC                                                      ,;
		QP02->D3_COD                                                      ,;
		QP02->D3_TIPO                                                     ,;
		QP02->D3_QUANT                                                    ,;
		QP02->D3_NUMSEQ                                                   ,;
		QP02->EMB                                                         ,;
		QP02->ESM                                                         ,;
		QP02->MAS                                                         ,;
		xEmbOk                                                            ,;
		xEsmOk                                                            ,;
		xMasOk                                                            })

		dbSelectArea("QP02")
		dbSkip()

	End

	QP02->(dbCloseArea())
	Ferase(QPcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(QPcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	nxPlan := "Planilha 18"
	nxTabl := "Amarração de NumSeq para Etiquetas canceladas sem estorno direto - TM 711 e TM 211"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "D3_TM      " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "D3_COD     " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "D3_QUANT   " ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "D3_DOC     " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "D3_EMISSAO " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "D3_NUMSEQ  " ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "D3_YRFCUST " ,1,1)

	VR009 := " UPDATE "+RetSqlName("SD3")+" SET D3_YRFCUST = (SELECT ZD3.D3_NUMSEQ "
	VR009 += "                                   FROM "+RetSqlName("SD3")+" ZD3 "
	VR009 += "                                  WHERE ZD3.R_E_C_N_O_ = (SELECT MAX(XD3.R_E_C_N_O_) "
	VR009 += "                                                            FROM "+RetSqlName("SD3")+" XD3 "
	VR009 += "                                                           WHERE XD3.D3_FILIAL = SD3.D3_FILIAL "
	VR009 += "                                                             AND XD3.D3_EMISSAO = SD3.D3_EMISSAO "
	VR009 += "                                                             AND D3_TM = '711' "
	VR009 += "                                                             AND XD3.R_E_C_N_O_ <= SD3.R_E_C_N_O_ "
	VR009 += "                                                             AND XD3.D_E_L_E_T_ = ' ')) "
	VR009 += "   FROM "+RetSqlName("SD3")+" SD3 "
	VR009 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
	VR009 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	VR009 += "    AND D3_TM IN('711', '211') "
	VR009 += "    AND D3_ESTORNO = ' ' "
	VR009 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	VR009 += "    AND D_E_L_E_T_ = ' ' "
	TCSQLExec(VR009)

	RV001 := " SELECT D3_TM, "
	RV001 += "        D3_COD, "
	RV001 += "        D3_QUANT, "
	RV001 += "        D3_DOC, "
	RV001 += "        D3_EMISSAO, "
	RV001 += "        D3_NUMSEQ, "
	RV001 += "        D3_YRFCUST "
	RV001 += "   FROM "+RetSqlName("SD3")+" SD3 "
	RV001 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
	RV001 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	RV001 += "    AND D3_TM IN('711', '211') "
	RV001 += "    AND D3_ESTORNO = ' ' "
	RV001 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	RV001 += "    AND D_E_L_E_T_ = ' ' "
	RV001 += "  ORDER BY R_E_C_N_O_ "
	RVcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RV001),'RV01',.F.,.T.)
	dbSelectArea("RV01")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento11")

		oExcel:AddRow(nxPlan, nxTabl, { RV01->D3_TM  ,;
		RV01->D3_COD                                 ,;
		RV01->D3_QUANT                               ,;
		RV01->D3_DOC                                 ,;
		RV01->D3_EMISSAO                             ,;
		RV01->D3_NUMSEQ                              ,;
		RV01->D3_YRFCUST                             })

		dbSelectArea("RV01")
		dbSkip()

	End

	RV01->(dbCloseArea())
	Ferase(RVcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(RVcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	// Implantado em 17/11/16 Por Marcos Alberto Soprani em atendimento a OS effettivo 3208-16
	nxPlan := "Planilha 19"
	nxTabl := "Cadastro de Produto PA sem PP correspondente cadastrado"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "REF_PA"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCR"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "REF_PP"                ,1,1)

	WQ004 := " SELECT * "
	WQ004 += "   FROM (SELECT B1_COD PRODUTO, "
	WQ004 += "                B1_YFORMAT+' '+B1_YBASE+' '+B1_YACABAM+' '+B1_YESPESS REF_PA, "
	WQ004 += "                RTRIM(B1_DESC) DESCR, "
	WQ004 += "                ISNULL((SELECT B1_YFORMAT+' '+B1_YBASE+' '+B1_YACABAM+' '+B1_YESPESS "
	WQ004 += "                          FROM " + RetSqlName("SB1") + " XB1 "
	WQ004 += "                         WHERE B1_FILIAL = '" + xFilial("SB1") + "' "
	WQ004 += "                           AND SUBSTRING(XB1.B1_COD, 1, 7) = SUBSTRING(SB1.B1_COD, 1, 7) "
	WQ004 += "                           AND B1_TIPO = 'PP' "
	WQ004 += "                           AND XB1.D_E_L_E_T_ = ' '), '') REF_PP "
	WQ004 += "           FROM " + RetSqlName("SB1") + " SB1 "
	WQ004 += "          WHERE B1_FILIAL = '" + xFilial("SB1") + "' "
	WQ004 += "                AND B1_TIPO = 'PA' "
	WQ004 += "                AND B1_MSBLQL <> '1' "
	WQ004 += "                AND B1_COD IN (SELECT DISTINCT D3_COD "
	WQ004 += "                                 FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK) "
	WQ004 += "                                WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	WQ004 += "                                  AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	WQ004 += "                                  AND D3_TM = '010' "
	WQ004 += "                                  AND D3_TIPO = 'PA' "
	WQ004 += "                                  AND D3_ESTORNO = ' ' "
	WQ004 += "                                  AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	WQ004 += "                                  AND SD3.D_E_L_E_T_ = ' ') "
	WQ004 += "                AND SB1.D_E_L_E_T_ = ' ' "
	WQ004 += "        ) AS TABERET "
	WQ004 += "  WHERE REF_PA <> REF_PP "
	WQcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,WQ004),'WQ04',.F.,.T.)
	dbSelectArea("WQ04")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento16")

		oExcel:AddRow(nxPlan, nxTabl, { WQ04->PRODUTO, WQ04->REF_PA, WQ04->DESCR, WQ04->REF_PP })

		dbSelectArea("WQ04")
		dbSkip()

	End

	WQ04->(dbCloseArea())
	Ferase(WQcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(WQcIndex+OrdBagExt())          //indice gerado
	//****************************************************************************************************************************************************

	// Implantado em 22/08/76 Por Gabriel Rossi Mafioletti
	nxPlan := "Planilha 20"
	nxTabl := "Conciliação de Estorno de Etiquetas"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCR"                 ,1,1)

	_cAlias	:=	GetNextAlias()

	_cDataDe	:=	DtoS(MV_PAR01)
	_cDataAte	:=	DtoS(MV_PAR02)

	BeginSql Alias _cAlias

		SELECT  D3_COD ,
		B1_DESC,
		ISNULL(SUM(CASE WHEN D3_TM = '711' THEN D3_QUANT * -1
		ELSE D3_QUANT
	END), 0) QTD
	FROM    %TABLE:SD3% SD3(NOLOCK)
	JOIN %TABLE:SB1% SB1 ON SD3.D3_COD = SB1.B1_COD
	AND SB1.D_E_L_E_T_ = ''
	WHERE   SD3.D3_FILIAL = %xFILIAL:SD3%
	AND SD3.D3_EMISSAO BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
	AND D3_ESTORNO = ' '
	AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	AND D3_TM IN ( '711', '010' )
	AND SD3.%NotDel%
	GROUP BY D3_COD,
	B1_DESC
	HAVING  ISNULL(SUM(CASE WHEN D3_TM = '711' THEN D3_QUANT * -1
	ELSE D3_QUANT
	END), 0) = 0

	EndSql

	While (_cAlias)->(!EOF())

		IncProc("Processamento16")

		oExcel:AddRow(nxPlan, nxTabl, { (_cAlias)->D3_COD, (_cAlias)->B1_DESC })	

		(_cAlias)->(DbSkip())
	EndDo
	(_cAlias)->(DbCloseArea())

	//                                                                      Planilha 21
	//=================================================================================
	nxPlan := "Planilha 21"
	nxTabl := "Etiquetas canceladas fora do prazo"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"                   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "COD"                   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"                 ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "ETIQUETA"              ,1,1)

	KD003 := " SELECT D3_EMISSAO EMISSAO, "
	KD003 += "        D3_DOC DOC, "
	KD003 += "        D3_COD COD, "
	KD003 += "        D3_QUANT QUANT, "
	KD003 += "        (SELECT Z18_NUMETQ "
	KD003 += "           FROM " + RetSqlName("Z18") + " Z18 "
	KD003 += "          WHERE Z18_FILIAL = '" + xFilial("Z18") + "' "
	KD003 += "            AND Z18_DOCSD3 = D3_DOC "
	KD003 += "            AND D_E_L_E_T_ = ' ') NUMETIQ "
	KD003 += "   FROM " + RetSqlName("SD3") + " SD3 "
	KD003 += "  WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	KD003 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"' "
	KD003 += "    AND D3_TM = '711' "
	KD003 += "    AND D3_TIPO = 'PA' "
	KD003 += "    AND D3_ESTORNO = ' ' "
	KD003 += "    AND D3_YRFCUST <> 'PRODUCTION ON DEMAND'
	KD003 += "    AND D_E_L_E_T_ = ' ' "
	KD003 += "  ORDER BY 1, 2, 3 "
	KDcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,KD003),'KD03',.F.,.T.)
	dbSelectArea("KD03")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento21")

		oExcel:AddRow(nxPlan, nxTabl, { dtoc(stod(KD03->EMISSAO)), KD03->DOC, KD03->COD, KD03->QUANT, KD03->NUMETIQ })

		dbSelectArea("KD03")
		dbSkip()

	End
	KD03->(dbCloseArea())
	Ferase(KDcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(KDcIndex+OrdBagExt())          //indice gerado

	//                                                                      Planilha 22
	//=================================================================================
	nxPlan := "Planilha 22"
	nxTabl := "Requisições alocadas em Fabricas trocadas"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "USUARIO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TM"                    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "COD"                   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"                 ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CF"                    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "YAPLIC"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "YTAG"                  ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "YMATRIC"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "OP"                    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOCAL"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"                   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CC"                    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NUMSEQ"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVL"                  ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "REGSD3"                ,1,1)

	QR005 := " SELECT D3_USUARIO,                                                        "
	QR005 += "        D3_TM,                                                             "
	QR005 += "        D3_COD,                                                            "
	QR005 += "        D3_QUANT,                                                          "
	QR005 += "        D3_CF,                                                             "
	QR005 += "        D3_YAPLIC,                                                         "
	QR005 += "        D3_YTAG,                                                           "
	QR005 += "        D3_YMATRIC,                                                        "
	QR005 += "        D3_CONTA,                                                          "
	QR005 += "        D3_OP,                                                             "
	QR005 += "        D3_LOCAL,                                                          "
	QR005 += "        D3_DOC,                                                            "
	QR005 += "        D3_EMISSAO,                                                        "
	QR005 += "        D3_CC,                                                             "
	QR005 += "        D3_NUMSEQ,                                                         "
	QR005 += "        D3_CLVL,                                                           "
	QR005 += "        R_E_C_N_O_ REGSD3                                                  "
	QR005 += " FROM " + RetSqlName("SD3") + "                                            "
	QR005 += " WHERE D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'    "
	QR005 += "       AND D3_CLVL = ''                                                    "
	QR005 += "       AND D3_CF NOT IN('DE4', 'RE4', 'DE7', 'RE7', 'DE3', 'RE3')          "
	QR005 += "       AND D3_ESTORNO = ''                                                 "
	QR005 += "       AND D_E_L_E_T_ = ' '                                                "
	QR005 += " UNION ALL                                                                 "
	QR005 += " SELECT D3_USUARIO,                                                        "
	QR005 += "        D3_TM,                                                             "
	QR005 += "        D3_COD,                                                            "
	QR005 += "        D3_QUANT,                                                          "
	QR005 += "        D3_CF,                                                             "
	QR005 += "        D3_YAPLIC,                                                         "
	QR005 += "        D3_YTAG,                                                           "
	QR005 += "        D3_YMATRIC,                                                        "
	QR005 += "        D3_CONTA,                                                          "
	QR005 += "        D3_OP,                                                             "
	QR005 += "        D3_LOCAL,                                                          "
	QR005 += "        D3_DOC,                                                            "
	QR005 += "        D3_EMISSAO,                                                        "
	QR005 += "        D3_CC,                                                             "
	QR005 += "        D3_NUMSEQ,                                                         "
	QR005 += "        D3_CLVL,                                                           "
	QR005 += "        R_E_C_N_O_ REGSD3                                                  "
	QR005 += " FROM " + RetSqlName("SD3") + "                                            "
	QR005 += " WHERE D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'    "
	QR005 += "       AND D3_LOCAL IN('20', '04')                                         "
	QR005 += "       AND SUBSTRING(D3_CLVL, 1, 2) <> '32'                                "
	QR005 += "       AND SUBSTRING(D3_CONTA, 1, 1) = '6'                                 "
	QR005 += "       AND D3_ESTORNO = ''                                                 "
	QR005 += "       AND D_E_L_E_T_ = ' '                                                "
	QR005 += " UNION ALL                                                                 "
	QR005 += " SELECT D3_USUARIO,                                                        "
	QR005 += "        D3_TM,                                                             "
	QR005 += "        D3_COD,                                                            "
	QR005 += "        D3_QUANT,                                                          "
	QR005 += "        D3_CF,                                                             "
	QR005 += "        D3_YAPLIC,                                                         "
	QR005 += "        D3_YTAG,                                                           "
	QR005 += "        D3_YMATRIC,                                                        "
	QR005 += "        D3_CONTA,                                                          "
	QR005 += "        D3_OP,                                                             "
	QR005 += "        D3_LOCAL,                                                          "
	QR005 += "        D3_DOC,                                                            "
	QR005 += "        D3_EMISSAO,                                                        "
	QR005 += "        D3_CC,                                                             "
	QR005 += "        D3_NUMSEQ,                                                         "
	QR005 += "        D3_CLVL,                                                           "
	QR005 += "        R_E_C_N_O_ REGSD3                                                  "
	QR005 += " FROM " + RetSqlName("SD3") + "                                            "
	QR005 += " WHERE D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'    "
	QR005 += "       AND D3_LOCAL IN('01', '02')                                         "
	QR005 += "       AND SUBSTRING(D3_CLVL, 1, 2) <> '31'                                "
	QR005 += "       AND SUBSTRING(D3_CONTA, 1, 1) = '6'                                 "
	QR005 += "       AND D3_ESTORNO = ''                                                 "
	QR005 += "       AND D_E_L_E_T_ = ' '                                                "
	QRcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR005),'QR05',.F.,.T.)
	dbSelectArea("QR05")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento22")

		oExcel:AddRow(nxPlan, nxTabl, { QR05->D3_USUARIO, QR05->D3_TM, QR05->D3_COD, QR05->D3_QUANT, QR05->D3_CF, QR05->D3_YAPLIC, QR05->D3_YTAG, QR05->D3_YMATRIC, QR05->D3_CONTA, QR05->D3_OP, QR05->D3_LOCAL, QR05->D3_DOC, stod(QR05->D3_EMISSAO), QR05->D3_CC, QR05->D3_NUMSEQ, QR05->D3_CLVL, QR05->REGSD3 })

		dbSelectArea("QR05")
		dbSkip()

	End
	QR05->(dbCloseArea())
	Ferase(QRcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(QRcIndex+OrdBagExt())          //indice gerado

	//                                                                      Planilha 23
	//=================================================================================
	nxPlan := "Planilha 23"
	nxTabl := "Movimentações Internas sem Aplicação Preenchida"

	ZY003 := " UPDATE A SET D3_YAPLIC = '1' "
	ZY003 += "   FROM " + RetSqlName("SD3") + " A "
	ZY003 += "  WHERE D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	ZY003 += "    AND D3_CF = 'RE5' "
	ZY003 += "    AND D3_ESTORNO = ' ' "
	ZY003 += "    AND D_E_L_E_T_ = ' ' "
	TCSQLExec(ZY003)	

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "FILIAL"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TM"                    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"                   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "COD"                   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CF"                    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "OP"                    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVL"                  ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "APLIC"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOC"                   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "UM"                    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"                 ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUSTO"                 ,3,2)

	ZP002 := " SELECT D3_FILIAL FILIAL, "
	ZP002 += "        D3_EMISSAO EMISSAO, "
	ZP002 += "        D3_TM TM, "
	ZP002 += "        D3_DOC DOC, "
	ZP002 += "        D3_COD COD, "
	ZP002 += "        D3_CF CF, "
	ZP002 += "        D3_OP OP, "
	ZP002 += "        D3_CONTA CONTA, "
	ZP002 += "        D3_CLVL CLVL, "
	ZP002 += "        D3_YAPLIC APLIC, "
	ZP002 += "        D3_LOCAL LOC, "
	ZP002 += "        D3_UM UM, "
	ZP002 += "        D3_QUANT QUANT, "
	ZP002 += "        D3_CUSTO1 CUSTO "
	ZP002 += " FROM " + RetSqlName("SD3") + " SD3(NOLOCK)"
	ZP002 += " WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	ZP002 += "       AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	ZP002 += "       AND D3_TM <> '010' "
	ZP002 += "       AND D3_CF NOT IN('DE3', 'RE3', 'DE4', 'RE4', 'DE7', 'RE7') "
	ZP002 += "       AND SUBSTRING(D3_CLVL, 1, 1) = '3' "
	ZP002 += "       AND D3_YAPLIC NOT BETWEEN '1' AND 'A' "
	ZP002 += "       AND SUBSTRING(D3_CONTA,1,3) <> '413' "
	ZP002 += "       AND D3_ESTORNO = ' ' "
	ZP002 += "       AND D_E_L_E_T_ = ' ' "
	ZP002 += " ORDER BY D3_FILIAL "
	ZPcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP002),'ZP02',.F.,.T.)
	dbSelectArea("ZP02")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento23")

		oExcel:AddRow(nxPlan, nxTabl, { ZP02->FILIAL, dtoc(stod(ZP02->EMISSAO)), ZP02->TM, ZP02->DOC, ZP02->COD, ZP02->CF, ZP02->OP, ZP02->CONTA, ZP02->CLVL, ZP02->APLIC, ZP02->LOC, ZP02->UM, ZP02->QUANT, ZP02->CUSTO })

		dbSelectArea("ZP02")
		dbSkip()

	End
	ZP02->(dbCloseArea())
	Ferase(ZPcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ZPcIndex+OrdBagExt())          //indice gerado

	//                                                                      Planilha 24
	//=================================================================================
	nxPlan := "Planilha 24"
	nxTabl := "Notas fiscais de matéria prima do grupo 101 e 102 (massa e esmalte) que foram lançadas sem conhecimento de frete"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "FILIAL",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SERIE",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FORNECEDOR",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOJA",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NOME",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DTDIGIT",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "VAL_PROD",3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "VAL_NOTA",3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "ITEM",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCRICAO",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CFOP",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESC_CFOP",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PEDIDO",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PED_ITEM",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TIPO_FRETE",1,1)

	ZP024 := "SELECT DISTINCT F1N.F1_FILIAL AS FILIAL" + CRLF
	ZP024 += "	, F1N.F1_DOC AS NF_DOC" + CRLF
	ZP024 += "	, F1N.F1_SERIE AS NF_SER" + CRLF
	ZP024 += "	, F1N.F1_FORNECE AS FOR_COD" + CRLF
	ZP024 += "	, F1N.F1_LOJA AS FOR_LOJ" + CRLF
	ZP024 += "	, SA2.A2_NOME AS FOR_NOM" + CRLF
	ZP024 += "	, F1N.F1_EMISSAO AS DT_EMIS" + CRLF
	ZP024 += "	, F1N.F1_DTDIGIT AS DT_LANC" + CRLF
	ZP024 += "	, F1N.F1_VALMERC AS VAL_PROD" + CRLF
	ZP024 += "	, F1N.F1_VALBRUT AS VAL_NOTA" + CRLF
	ZP024 += "	, D1N.D1_ITEM AS NF_ITEM" + CRLF
	ZP024 += "	, D1N.D1_COD AS PROD_COD" + CRLF
	ZP024 += "	, SB1.B1_DESC AS PROD_DESC" + CRLF
	ZP024 += "	, C0Y.C0Y_CODIGO AS CF_COD" + CRLF
	ZP024 += "	, C0Y.C0Y_DESCRI AS CF_DES" + CRLF
	ZP024 += "	, SC7.C7_NUM AS PED_NUM" + CRLF
	ZP024 += "	, SC7.C7_ITEM AS PED_ITE" + CRLF
	ZP024 += "	, SC7.C7_TPFRETE AS PED_FRT" + CRLF
	ZP024 += "FROM " + RetSqlName("SF1") + " F1N WITH(NOLOCK)" + CRLF
	ZP024 += "	INNER JOIN " + RetSqlName("SD1") + " D1N WITH(NOLOCK) ON F1N.F1_FILIAL = D1N.D1_FILIAL" + CRLF
	ZP024 += "		AND F1N.F1_DOC = D1N.D1_DOC" + CRLF
	ZP024 += "		AND F1N.F1_SERIE = D1N.D1_SERIE" + CRLF
	ZP024 += "		AND F1N.F1_FORNECE = D1N.D1_FORNECE" + CRLF
	ZP024 += "		AND F1N.F1_LOJA = D1N.D1_LOJA" + CRLF
	ZP024 += "		AND D1N.D_E_L_E_T_ = ''" + CRLF
	ZP024 += "	INNER JOIN " + RetSqlName("SB1") + " SB1 WITH(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'" + CRLF
	ZP024 += "		AND D1N.D1_COD = SB1.B1_COD" + CRLF
	ZP024 += "		AND SUBSTRING(SB1.B1_GRUPO,1,3) IN ('101','102')" + CRLF
	ZP024 += "		AND SB1.D_E_L_E_T_ = ''" + CRLF
	ZP024 += "	INNER JOIN " + RetSqlName("SA2") + " SA2 WITH(NOLOCK) ON SA2.A2_FILIAL = '" + xFilial("SA2") + "'" + CRLF
	ZP024 += "		AND F1N.F1_FORNECE = SA2.A2_COD" + CRLF
	ZP024 += "		AND F1N.F1_LOJA = SA2.A2_LOJA" + CRLF
	ZP024 += "		AND SA2.D_E_L_E_T_ = ''" + CRLF
	ZP024 += "	LEFT JOIN " + RetSqlName("SC7") + " SC7 WITH(NOLOCK) ON F1N.F1_FILIAL = SC7.C7_FILIAL" + CRLF
	ZP024 += "		AND D1N.D1_PEDIDO = SC7.C7_NUM" + CRLF
	ZP024 += "		AND D1N.D1_ITEMPC = SC7.C7_ITEM" + CRLF
	ZP024 += "		AND SC7.D_E_L_E_T_ = ''" + CRLF
	ZP024 += "	LEFT JOIN " + RetSqlName("SF8") + " SF8 WITH(NOLOCK) ON F1N.F1_FILIAL = SF8.F8_FILIAL" + CRLF
	ZP024 += "		AND F1N.F1_DOC = SF8.F8_NFORIG" + CRLF
	ZP024 += "		AND F1N.F1_SERIE = SF8.F8_SERORIG" + CRLF
	ZP024 += "		AND F1N.F1_FORNECE = SF8.F8_FORNECE" + CRLF
	ZP024 += "		AND F1N.F1_LOJA = SF8.F8_LOJA" + CRLF
	ZP024 += "		AND SF8.D_E_L_E_T_ = ''" + CRLF
	ZP024 += "	LEFT JOIN " + RetSqlName("C0Y") + " C0Y WITH(NOLOCK) ON C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "'" + CRLF
	ZP024 += "		AND D1N.D1_CF = C0Y.C0Y_CODIGO" + CRLF
	ZP024 += "		AND C0Y.D_E_L_E_T_ = ''" + CRLF
	ZP024 += "WHERE F1N.F1_FILIAL = '" + xFilial("SF1") + "'" + CRLF
	ZP024 += "	AND F1N.F1_TIPO = 'N'" + CRLF
	ZP024 += "	AND F1N.F1_ESPECIE = 'SPED'" + CRLF
	ZP024 += "	AND F1N.F1_DTDIGIT BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'" + CRLF
	ZP024 += "	AND F1N.D_E_L_E_T_ = ''" + CRLF
	ZP024 += "	AND SF8.F8_NFORIG IS NULL" + CRLF
	ZP024 += "	AND SF8.F8_SERORIG IS NULL" + CRLF
	ZP024 += "	AND SF8.F8_FORNECE IS NULL" + CRLF
	ZP024 += "	AND SF8.F8_LOJA IS NULL" + CRLF
	ZP024 += "	AND SA2.A2_COD NOT IN ('010098','012343','002307','008241','010081','010048')" + CRLF
	ZP024 += "	AND (SC7.C7_NUM IS NULL OR SC7.C7_TPFRETE = '' OR SC7.C7_TPFRETE = 'F')" + CRLF
	ZP024 += "ORDER BY FILIAL, DT_LANC, NF_DOC, NF_SER, FOR_COD, FOR_LOJ, NF_ITEM" + CRLF
	ZPcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP024),'ZP24',.F.,.T.)
	dbSelectArea("ZP24")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento24")

		oExcel:AddRow(nxPlan, nxTabl, { ZP24->FILIAL, ZP24->NF_DOC, ZP24->NF_SER, ZP24->FOR_COD, ZP24->FOR_LOJ, ZP24->FOR_NOM, dtoc(stod(ZP24->DT_EMIS)), dtoc(stod(ZP24->DT_LANC)), ZP24->VAL_PROD, ZP24->VAL_NOTA, ZP24->NF_ITEM, ZP24->PROD_COD, ZP24->PROD_DESC, ZP24->CF_COD, ZP24->CF_DES, ZP24->PED_NUM, ZP24->PED_ITE, ZP24->PED_FRT })

		dbSelectArea("ZP24")
		dbSkip()

	End
	ZP24->(dbCloseArea())
	Ferase(ZPcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ZPcIndex+OrdBagExt())          //indice gerado

	//                                                                      Planilha 25
	//=================================================================================
	If cEmpAnt == "01"
		nxPlan := "Planilha 25"
		nxTabl := "Fretes lançados em armazéns diferentes das NFes"

		oExcel:AddworkSheet(nxPlan)
		oExcel:AddTable (nxPlan, nxTabl)
		oExcel:AddColumn(nxPlan, nxTabl, "FILIAL",1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DOC",1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "SERIE",1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "FORNECEDOR",1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "LOJA",1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO",1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "ARMAZEM",1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DOC F.",1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "SERIE F.",1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "TRANSP.",1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "LOJA T.",1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "ARMAZEM T.",1,1)

		ZP025 := "EXEC SP_BIA739_PLAN25 '"+DTOS(MV_PAR01)+"','"+DTOS(MV_PAR02)+"'"

		ZPcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP025),'ZP25',.F.,.T.)
		dbSelectArea("ZP25")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc("Processamento25")

			oExcel:AddRow(nxPlan, nxTabl, { ZP25->NF_FILIAL, ZP25->NF_DOC, ZP25->NF_SER, ZP25->NF_FORN, ZP25->NF_LOJ, ZP25->NF_COD, ZP25->NF_LOC, ZP25->CT_D_DOC, ZP25->CT_D_SER, ZP25->CT_D_FORN, ZP25->CT_D_LOJ, ZP25->CT_D_LOC })

			dbSelectArea("ZP25")
			dbSkip()

		End
		ZP25->(dbCloseArea())
		Ferase(ZPcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(ZPcIndex+OrdBagExt())          //indice gerado
	EndIf

	//****************************************************************************************************************************************************

	nxPlan := "Planilha 26"
	nxTabl := "Verificar contas contábeis usadas nas movimentações versus cadastro de produto"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVL"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DCLVL"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ATRIB"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "APLICACAO"            ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "MELHORIA"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "USUARIO"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "GRUPO"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "NUMOP"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"                  ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ALMOX"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCR"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"                ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUSTO"                ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CTAEST"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CTAIND"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CTAADM"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CTAREQ"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CHECA"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "REGRA"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTAC"               ,1,1)

	KN004 := " SELECT D3_EMISSAO EMISSAO, "
	KN004 += "        D3_CLVL CLVL, "
	KN004 += "        CTH_DESC01 DCLVL, "
	KN004 += "        CTH_YATRIB ATRIB, "
	KN004 += "        D3_YAPLIC APLIC, "
	KN004 += "        D3_YMELHOR MELHOR, "
	KN004 += "        D3_USUARIO USUARIO, "
	KN004 += "        B1_GRUPO GRUPO, "
	KN004 += "        D3_OP NUMOP, "
	KN004 += "        D3_DOC DOC, "
	KN004 += "        D3_LOCAL ALMOX, "
	KN004 += "        D3_COD PRODUTO, "
	KN004 += "        RTRIM(B1_DESC) DESCR, "
	KN004 += "        D3_QUANT QUANT, "
	KN004 += "        D3_CUSTO1 CUSTO, "
	KN004 += "        B1_CONTA CTAEST, "
	KN004 += "        B1_YCTRIND CTAIND, "
	KN004 += "        B1_YCTRADM CTAADM, "
	KN004 += "        D3_CONTA CTAREQ, "
	KN004 += "        CHK = CASE "
	KN004 += "                  WHEN B1_GRUPO IN('107A', '107E') "
	KN004 += "                       AND D3_CLVL IN('3117', '3217', '3135') "
	KN004 += "                       AND D3_CONTA = '61110006' "
	KN004 += "                  THEN 'RET' "
	KN004 += "                  WHEN B1_GRUPO IN('107A', '107E') "
	KN004 += "                       AND D3_CLVL IN('3136') "
	KN004 += "                       AND D3_CONTA = '61110001' "
	KN004 += "                  THEN 'POL' "
	KN004 += "                  WHEN SD3.D3_YAPLIC = '4' "
	KN004 += "                       AND SD3.D3_YMELHOR <> '' "
	KN004 += "                       AND SUBSTRING(SD3.D3_CLVL, 1, 1) = '3' "
	KN004 += "                       AND D3_CONTA = '61301010' "
	KN004 += "                  THEN 'MELHORIA' "
	KN004 += "                  ELSE 'VER' "
	KN004 += "              END, "
	KN004 += "        REGRA = CASE "
	KN004 += "                    WHEN B1_GRUPO IN('107A', '107E') "
	KN004 += "                         AND D3_CLVL IN('3117', '3217', '3135') "
	KN004 += "                    THEN 'RET' "
	KN004 += "                    WHEN B1_GRUPO IN('107A', '107E') "
	KN004 += "                         AND D3_CLVL IN('3136') "
	KN004 += "                    THEN 'POL' "
	KN004 += "                    WHEN SD3.D3_YAPLIC = '4' "
	KN004 += "                         AND SD3.D3_YMELHOR <> '' "
	KN004 += "                         AND SUBSTRING(SD3.D3_CLVL, 1, 1) = '3' "
	KN004 += "                    THEN 'MELHORIA' "
	KN004 += "                    WHEN CTH_YATRIB = 'C' "
	KN004 += "                    THEN 'CUSTO-GERAL' "
	KN004 += "                    ELSE 'DESPESA-GERAL' "
	KN004 += "                END, "
	KN004 += "        D3_CONTA = CASE "
	KN004 += "                       WHEN B1_GRUPO IN('107A', '107E') "
	KN004 += "                            AND D3_CLVL IN('3117', '3217', '3135') "
	KN004 += "                       THEN '61110006' "
	KN004 += "                       WHEN B1_GRUPO IN('107A', '107E') "
	KN004 += "                            AND D3_CLVL IN('3136') "
	KN004 += "                       THEN '61110001' "
	KN004 += "                       WHEN SD3.D3_YAPLIC = '4' "
	KN004 += "                            AND SD3.D3_YMELHOR <> '' "
	KN004 += "                            AND SUBSTRING(SD3.D3_CLVL, 1, 1) = '3' "
	KN004 += "                       THEN '61301010' "
	KN004 += "                       WHEN CTH_YATRIB = 'C' "
	KN004 += "                       THEN SB1.B1_YCTRIND "
	KN004 += "                       ELSE SB1.B1_YCTRADM "
	KN004 += "                   END "
	KN004 += " FROM " + RetSqlName("SD3") + " SD3 "
	KN004 += "      INNER JOIN " + RetSqlName("CTH") + " CTH ON CTH_CLVL = SD3.D3_CLVL "
	KN004 += "                               AND CTH.D_E_L_E_T_ = ' ' "
	KN004 += "      INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD = SD3.D3_COD "
	KN004 += "                               AND ((B1_CONTA = D3_CONTA) "
	KN004 += "                                    OR (B1_YCTRIND <> D3_CONTA "
	KN004 += "                                        AND CTH_YATRIB = 'C' "
	KN004 += "                                        AND D3_CONTA NOT IN('11301020            ', '11302020            ')) "
	KN004 += "                                    OR (B1_YCTRADM <> D3_CONTA "
	KN004 += "                                        AND CTH_YATRIB = 'D')) "
	KN004 += "                               AND NOT(B1_GRUPO IN('107A', '107E') "
	KN004 += "                                       AND D3_CLVL IN('3117', '3217', '3135') "
	KN004 += "                                       AND D3_CONTA = '61110006') "
	KN004 += "                               AND NOT(B1_GRUPO IN('107A', '107E') "
	KN004 += "                                       AND D3_CLVL IN('3136') "
	KN004 += "                                       AND D3_CONTA = '61110001') "
	KN004 += "                               AND NOT(SD3.D3_YAPLIC = '4' "
	KN004 += "                                       AND SD3.D3_YMELHOR <> '' "
	KN004 += "                                       AND SUBSTRING(SD3.D3_CLVL, 1, 1) = '3' "
	KN004 += "                                       AND D3_CONTA = '61301010') "
	KN004 += "                               AND SB1.D_E_L_E_T_ = ' ' "
	KN004 += " WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
	KN004 += "       AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	KN004 += "       AND D3_ESTORNO = ' ' "
	KN004 += "       AND D3_YRFCUST <> 'PRODUCTION ON DEMAND' "
	KN004 += "       AND D3_TM <> '010' "
	KN004 += "       AND D3_CF NOT IN('DE3', 'RE3', 'DE4', 'RE4', 'DE7', 'RE7') "
	KN004 += "       AND D3_TIPO NOT IN('PA', 'PP', 'PI', 'MO') "
	KN004 += "       AND SD3.D_E_L_E_T_ = ' ' "
	KN004 += " ORDER BY SD3.D3_COD "
	KNcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,KN004),'KN04',.F.,.T.)
	dbSelectArea("KN04")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento26")

		oExcel:AddRow(nxPlan, nxTabl, { dtoc(stod(KN04->EMISSAO)), KN04->CLVL, KN04->DCLVL, KN04->ATRIB, KN04->APLIC, KN04->MELHOR, KN04->USUARIO, KN04->GRUPO, KN04->NUMOP, KN04->DOC, KN04->ALMOX, KN04->PRODUTO, KN04->DESCR, KN04->QUANT, KN04->CUSTO, KN04->CTAEST, KN04->CTAIND, KN04->CTAADM, KN04->CTAREQ, KN04->CHK, KN04->REGRA, KN04->D3_CONTA })

		dbSelectArea("KN04")
		dbSkip()

	End

	KN04->(dbCloseArea())
	Ferase(KNcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(KNcIndex+OrdBagExt())          //indice gerado

	//                                                                      Planilha 27
	//=================================================================================
	nxPlan := "Planilha 27"
	nxTabl := "Movimentações Internas de Investimento sem Item de Conta associado"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "FILIAL"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TM"                    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"                   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "COD"                   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CF"                    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "OP"                    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVL"                  ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ItemConta"             ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOC"                   ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "UM"                    ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"                 ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUSTO"                 ,3,2)

	ZP002 := " SELECT D3_FILIAL FILIAL, "
	ZP002 += "        D3_EMISSAO EMISSAO, "
	ZP002 += "        D3_TM TM, "
	ZP002 += "        D3_DOC DOC, "
	ZP002 += "        D3_COD COD, "
	ZP002 += "        D3_CF CF, "
	ZP002 += "        D3_OP OP, "
	ZP002 += "        D3_CONTA CONTA, "
	ZP002 += "        D3_CLVL CLVL, "
	ZP002 += "        D3_ITEMCTA ITEMCTA, "
	ZP002 += "        D3_LOCAL LOC, "
	ZP002 += "        D3_UM UM, "
	ZP002 += "        D3_QUANT QUANT, "
	ZP002 += "        D3_CUSTO1 CUSTO "
	ZP002 += " FROM " + RetSqlName("SD3") + " "
	ZP002 += " WHERE D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "' "
	ZP002 += "       AND D3_TM <> '010' "
	ZP002 += "       AND D3_CF NOT IN('DE3', 'RE3', 'DE4', 'RE4', 'DE7', 'RE7') "
	ZP002 += "       AND SUBSTRING(D3_CLVL, 1, 1) = '8' "
	ZP002 += "       AND D3_ITEMCTA = '' "
	ZP002 += "       AND D3_ESTORNO = ' '
	ZP002 += "       AND D_E_L_E_T_ = ' ' "
	ZP002 += " ORDER BY D3_FILIAL "
	ZPcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP002),'ZP02',.F.,.T.)
	dbSelectArea("ZP02")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento27")

		oExcel:AddRow(nxPlan, nxTabl, { ZP02->FILIAL, dtoc(stod(ZP02->EMISSAO)), ZP02->TM, ZP02->DOC, ZP02->COD, ZP02->CF, ZP02->OP, ZP02->CONTA, ZP02->CLVL, ZP02->ITEMCTA, ZP02->LOC, ZP02->UM, ZP02->QUANT, ZP02->CUSTO })

		dbSelectArea("ZP02")
		dbSkip()

	End
	ZP02->(dbCloseArea())
	Ferase(ZPcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ZPcIndex+OrdBagExt())          //indice gerado


	//                                                                      Planilha 28
	//=================================================================================
	nxPlan := "Planilha 28"
	nxTabl := "Conciliação antecipada da Contabilização do CPV - BIA747"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "DOCUMEN"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DTREF"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DEBITO"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CREDITO"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVLD"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CVVLC"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ITEMD"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ITEMC"                 ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT"                 ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUSTO"                 ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "HISTOR"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CCUSTOD"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CCUSTOC"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ORIGEM"                ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLI_AID"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLI_AIC"               ,1,1)

	// Saidas Normais
	CT007 := " SELECT ORIGEM, 
	CT007 += "        DOCUM, 
	CT007 += "        DTREF, 
	CT007 += "        DEBITO, 
	CT007 += "        CREDIT, 
	CT007 += "        SUM(QUANT) QUANT, 
	CT007 += "        SUM(CUSTO) CUSTO,
	CT007 += "        HIST,
	CT007 += "        CCUSTO, 
	CT007 += "        ITEMCTA, 
	CT007 += "        CLVL, 
	CT007 += "        C5_YSUBTP, 
	CT007 += "        C5_YSI
	CT007 += "   FROM (SELECT 'SD2:1' ORIGEM,
	CT007 += "                D2_DOC DOCUM, 
	CT007 += "                D2_EMISSAO DTREF, 
	CT007 += "                CASE
	CT007 += "                    WHEN C5_YSUBTP = 'RI'
	CT007 += "                    THEN '11306003'
	CT007 += "                    ELSE CASE C5_YITEMCT
	CT007 += "                             WHEN 'I0103' THEN '31406006' /*show room*/
	CT007 += "                             WHEN 'I0105' THEN '31406009' /*amostra*/
	CT007 += "                             WHEN 'I0107' THEN '31406020' /*feiras*/
	CT007 += "                             WHEN 'I0111' THEN '31406021' /*eventos*/
	CT007 += "                             WHEN 'I0201' THEN '31401020' /*descontos negociados*/
	CT007 += "                             WHEN 'I0202' THEN '31401020' /*descontos negociados*/
	CT007 += "                             WHEN 'I0206' THEN '31401020' /*descontos negociados*/
	CT007 += "                             WHEN 'I0205' THEN '31401019' /*RPV Extra Norma*/
	CT007 += "                             WHEN 'I0109' THEN '31401020' /*descontos negociados */
	CT007 += "                             ELSE '41301001'
	CT007 += "                         END
	CT007 += "                END DEBITO, 
	CT007 += "                '11306001' CREDIT, 
	CT007 += "                SUM(D2_QUANT) QUANT, 
	CT007 += "                SUM(D2_CUSTO1) CUSTO,
	CT007 += "                CASE
	CT007 += "                    WHEN SUM(D2_DESCON) > 0
	CT007 += "                    THEN 'VLR CUSTO DE ' + RTRIM(X5_DESCRI) + ' N/MES C/DESC.INC'
	CT007 += "                    ELSE 'VLR CUSTO DE ' + RTRIM(X5_DESCRI) + ' N/MES'
	CT007 += "                END HIST,
	CT007 += "                CASE
	CT007 += "                    WHEN SUM(D2_DESCON) = 0
	CT007 += "                         AND SUBSTRING(D2_CLVL, 1, 1) = '3'
	CT007 += "                    THEN 'VLR CUSTO DE ' + RTRIM(X5_DESCRI) + ' N/MES ' + RTRIM(ISNULL(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), C5_YOBS)), ''))
	CT007 += "                    ELSE ''
	CT007 += "                END HIST2,
	CT007 += "                CASE
	CT007 += "                    WHEN SUM(D2_DESCON) > 0
	CT007 += "                    THEN '         '
	CT007 += "                    ELSE D2_CCUSTO
	CT007 += "                END CCUSTO, 
	CT007 += "                C5_YITEMCT ITEMCTA,
	CT007 += "                CASE
	CT007 += "                    WHEN SUM(D2_DESCON) > 0
	CT007 += "                    THEN '         '
	CT007 += "                    ELSE D2_CLVL
	CT007 += "                END CLVL, 
	CT007 += "                C5_YSUBTP, 
	CT007 += "                C5_YSI
	CT007 += "         FROM "+RetSqlName("SD2")+" SD2 (NOLOCK)
	CT007 += "              INNER JOIN "+RetSqlName("SF4")+" SF4 (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"'
	CT007 += "                                       AND F4_CODIGO = D2_TES
	CT007 += "                                       AND F4_ESTOQUE = 'S'
	CT007 += "                                       AND F4_PODER3 = 'N'
	CT007 += "                                       AND SF4.D_E_L_E_T_ = ' '
	CT007 += "              INNER JOIN "+RetSqlName("SB1")+" SB1 (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
	CT007 += "                                       AND B1_COD = D2_COD
	CT007 += "                                       AND B1_TIPO = 'PA'
	CT007 += "                                       AND SB1.D_E_L_E_T_ = ' '
	CT007 += "              INNER JOIN "+RetSqlName("SC5")+" SC5 (NOLOCK) ON C5_FILIAL = '"+xFilial("SC5")+"'
	CT007 += "                                       AND C5_NUM = D2_PEDIDO
	CT007 += "                                       AND SC5.D_E_L_E_T_ = ' '
	CT007 += "              INNER JOIN "+RetSqlName("SX5")+" SX5 (NOLOCK) ON X5_FILIAL = '"+xFilial("SX5")+"'
	CT007 += "                                       AND X5_TABELA = 'DJ'
	CT007 += "                                       AND X5_CHAVE = C5_YSUBTP
	CT007 += "                                       AND SX5.D_E_L_E_T_ = ' '
	CT007 += "         WHERE D2_FILIAL = '"+xFilial("SD2")+"'
	CT007 += "               AND D2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	CT007 += "               AND D2_CF NOT IN('5202 ')
	CT007 += "               AND SD2.D_E_L_E_T_ = ' '
	CT007 += "         GROUP BY C5_YSUBTP,
	CT007 += "                  D2_DOC,
	CT007 += "                  D2_EMISSAO, 
	CT007 += "                  X5_DESCRI, 
	CT007 += "                  D2_CCUSTO, 
	CT007 += "                  D2_CLVL, 
	CT007 += "                  C5_YITEMCT, 
	CT007 += "                  C5_YSI, 
	CT007 += "                  RTRIM(ISNULL(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), C5_YOBS)), '')) ) AS TAGRPD
	CT007 += " GROUP BY ORIGEM, 
	CT007 += "          DOCUM, 
	CT007 += "          DTREF, 
	CT007 += "          DEBITO, 
	CT007 += "          CREDIT, 
	CT007 += "          HIST, 
	CT007 += "          CCUSTO, 
	CT007 += "          ITEMCTA, 
	CT007 += "          CLVL, 
	CT007 += "          C5_YSUBTP, 
	CT007 += "          C5_YSI
	CT007 += "  UNION ALL

	// Remessa para industrialização - PA
	CT007 += " SELECT 'SD2:2' ORIGEM,
	CT007 += "        D2_DOC DOCUM, 
	CT007 += "        D2_EMISSAO DTREF, 
	CT007 += "        '11306003' DEBITO,
	CT007 += "        '11306001' CREDIT,
	CT007 += "        SUM(D2_QUANT) QUANT,
	CT007 += "        SUM(D2_CUSTO1) CUSTO,
	CT007 += "        'VLR CUSTO DE '+RTRIM(X5_DESCRI)+' N/MES' HIST,
	CT007 += "        D2_CCUSTO CCUSTO,
	CT007 += "        ' ' ITEMCTA,
	CT007 += "        D2_CLVL CLVL,
	CT007 += "        C5_YSUBTP,
	CT007 += "        C5_YSI
	CT007 += "   FROM "+RetSqlName("SD2")+" SD2
	CT007 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	CT007 += "                       AND F4_CODIGO = D2_TES
	CT007 += "                       AND F4_ESTOQUE = 'S'
	CT007 += "                       AND F4_PODER3 = 'R'
	CT007 += "                       AND SF4.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	CT007 += "                       AND B1_COD = D2_COD
	CT007 += "                       AND B1_TIPO = 'PA'
	CT007 += "                       AND SB1.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = '"+xFilial("SC5")+"'
	CT007 += "                       AND C5_NUM = D2_PEDIDO
	CT007 += "                       AND SC5.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SX5")+" SX5 ON X5_FILIAL = '"+xFilial("SX5")+"'
	CT007 += "                       AND X5_TABELA = 'DJ'
	CT007 += "                       AND X5_CHAVE = C5_YSUBTP
	CT007 += "                       AND SX5.D_E_L_E_T_ = ' '
	CT007 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
	CT007 += "    AND D2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	CT007 += "    AND SD2.D_E_L_E_T_ = ' '
	CT007 += "  GROUP BY C5_YSUBTP,
	CT007 += "           D2_DOC, 
	CT007 += "           D2_EMISSAO, 
	CT007 += "           X5_DESCRI,
	CT007 += "           D2_CCUSTO,
	CT007 += "           D2_CLVL,
	CT007 += "           C5_YSI
	CT007 += "  UNION ALL

	// Remessa para industrialização - Embalagem
	CT007 += " SELECT 'SD2:3' ORIGEM,
	CT007 += "        D2_DOC DOCUM, 
	CT007 += "        D2_EMISSAO DTREF, 
	CT007 += "        CASE
	CT007 += "          WHEN D2_CONTA = '11303001            ' THEN '11303090            '
	CT007 += "          ELSE '11303091            '
	CT007 += "        END DEBITO,
	CT007 += "        D2_CONTA CREDIT,
	CT007 += "        SUM(D2_QUANT) QUANT,
	CT007 += "        SUM(D2_CUSTO1) CUSTO,
	CT007 += "        'VLR CUSTO DE '+RTRIM(X5_DESCRI)+' N/MES' HIST,
	CT007 += "        D2_CCUSTO CCUSTO,
	CT007 += "        ' ' ITEMCTA,
	CT007 += "        D2_CLVL CLVL,
	CT007 += "        C5_YSUBTP,
	CT007 += "        C5_YSI
	CT007 += "   FROM "+RetSqlName("SD2")+" SD2
	CT007 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	CT007 += "                       AND F4_CODIGO = D2_TES
	CT007 += "                       AND F4_ESTOQUE = 'S'
	CT007 += "                       AND F4_PODER3 = 'R'
	CT007 += "                       AND SF4.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	CT007 += "                       AND B1_COD = D2_COD
	CT007 += "                       AND B1_TIPO = 'ME'
	CT007 += "                       AND SB1.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = '"+xFilial("SC5")+"'
	CT007 += "                       AND C5_NUM = D2_PEDIDO
	CT007 += "                       AND SC5.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SX5")+" SX5 ON X5_FILIAL = '"+xFilial("SX5")+"'
	CT007 += "                       AND X5_TABELA = 'DJ'
	CT007 += "                       AND X5_CHAVE = C5_YSUBTP
	CT007 += "                       AND SX5.D_E_L_E_T_ = ' '
	CT007 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
	CT007 += "    AND D2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	CT007 += "    AND SD2.D_E_L_E_T_ = ' '
	CT007 += "  GROUP BY C5_YSUBTP,
	CT007 += "           D2_DOC, 
	CT007 += "           D2_EMISSAO, 
	CT007 += "           D2_CONTA,
	CT007 += "           X5_DESCRI,
	CT007 += "           D2_CCUSTO,
	CT007 += "           D2_CLVL,
	CT007 += "           C5_YSI
	CT007 += "  UNION ALL

	// Quebras
	CT007 += " SELECT 'SD3:1' ORIGEM,		
	CT007 += "        D3_DOC DOCUM, 
	CT007 += "        D3_EMISSAO DTREF, 
	CT007 += "        '41301001' DEBITO,
	CT007 += "        '11306001' CREDIT,
	CT007 += "        SUM(D3_QUANT) QUANT,
	CT007 += "        SUM(D3_CUSTO1) CUSTO,
	CT007 += "        'VLR QUEBRA DE ESTOQUE N/MES' HIST,
	CT007 += "        D3_CC CCUSTO,
	CT007 += "        D3_ITEMCTA ITEMCTA,
	CT007 += "        D3_CLVL CLVL,
	CT007 += "        ' ' C5_YSUBTP,
	CT007 += "        ' ' C5_YSI
	CT007 += "   FROM "+RetSqlName("SD3")+" SD3
	CT007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	CT007 += "                       AND B1_COD = D3_COD
	CT007 += "                       AND B1_TIPO = 'PA'
	CT007 += "                       AND SB1.D_E_L_E_T_ = ' '
	CT007 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	CT007 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	CT007 += "    AND D3_TM IN('503','512','533')
	CT007 += "    AND SD3.D_E_L_E_T_ = ' '
	CT007 += "  GROUP BY D3_CC,
	CT007 += "           D3_DOC, 
	CT007 += "           D3_EMISSAO, 
	CT007 += "           D3_ITEMCTA,
	CT007 += "           D3_CLVL
	CT007 += "  UNION ALL

	// Inventário Saida
	CT007 += " SELECT 'SD3:2' ORIGEM,
	CT007 += "        D3_DOC DOCUM, 
	CT007 += "        D3_EMISSAO DTREF, 
	CT007 += "        '41301001' DEBITO,
	CT007 += "        '11306001' CREDIT,
	CT007 += "        SUM(D3_QUANT) QUANT,
	CT007 += "        SUM(D3_CUSTO1) CUSTO,
	CT007 += "        'VLR REF INVENTARIO SAIDA N/MES' HIST,
	CT007 += "        D3_CC CCUSTO,
	CT007 += "        D3_ITEMCTA ITEMCTA,
	CT007 += "        D3_CLVL CLVL,
	CT007 += "        ' ' C5_YSUBTP,
	CT007 += "        ' ' C5_YSI
	CT007 += "   FROM "+RetSqlName("SD3")+" SD3
	CT007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	CT007 += "                       AND B1_COD = D3_COD
	CT007 += "                       AND B1_TIPO = 'PA'
	CT007 += "                       AND SB1.D_E_L_E_T_ = ' '
	CT007 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	CT007 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	CT007 += "    AND D3_TM IN('600')
	CT007 += "    AND SD3.D_E_L_E_T_ = ' '
	CT007 += "  GROUP BY D3_CC,
	CT007 += "           D3_DOC, 
	CT007 += "           D3_EMISSAO, 
	CT007 += "           D3_ITEMCTA,
	CT007 += "           D3_CLVL
	CT007 += "  UNION ALL

	// Inventário Entrada
	CT007 += " SELECT 'SD3:3' ORIGEM,
	CT007 += "        D3_DOC DOCUM, 
	CT007 += "        D3_EMISSAO DTREF, 
	CT007 += "        '11306001' DEBITO,
	CT007 += "        '41301001' CREDIT,
	CT007 += "        SUM(D3_QUANT) QUANT,
	CT007 += "        SUM(D3_CUSTO1) CUSTO,
	CT007 += "        'VLR REF INVENTARIO ENTRADA N/MES' HIST,
	CT007 += "        D3_CC CCUSTO,
	CT007 += "        D3_ITEMCTA ITEMCTA,
	CT007 += "        D3_CLVL CLVL,
	CT007 += "        ' ' C5_YSUBTP,
	CT007 += "        ' ' C5_YSI
	CT007 += "   FROM "+RetSqlName("SD3")+" SD3
	CT007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	CT007 += "                       AND B1_COD = D3_COD
	CT007 += "                       AND B1_TIPO = 'PA'
	CT007 += "                       AND SB1.D_E_L_E_T_ = ' '
	CT007 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	CT007 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	CT007 += "    AND D3_TM IN('300')
	CT007 += "    AND SD3.D_E_L_E_T_ = ' '
	CT007 += "  GROUP BY D3_CC,
	CT007 += "           D3_DOC, 
	CT007 += "           D3_EMISSAO, 
	CT007 += "           D3_ITEMCTA,
	CT007 += "           D3_CLVL
	CT007 += "  UNION ALL

	// Quebras para uso interno
	CT007 += " SELECT 'SD3:4' ORIGEM,
	CT007 += "        D3_DOC DOCUM, 
	CT007 += "        D3_EMISSAO DTREF, 
	CT007 += "        '41301001' DEBITO,
	CT007 += "        '11306001' CREDIT,
	CT007 += "        SUM(D3_QUANT) QUANT,
	CT007 += "        SUM(D3_CUSTO1) CUSTO,
	CT007 += "        'VLR QUEBRA ESTOQUE P/USO INTERNO N/MES' HIST,
	CT007 += "        D3_CC CCUSTO,
	CT007 += "        D3_ITEMCTA ITEMCTA,
	CT007 += "        D3_CLVL CLVL,
	CT007 += "        ' ' C5_YSUBTP,
	CT007 += "        ' ' C5_YSI
	CT007 += "   FROM "+RetSqlName("SD3")+" SD3
	CT007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	CT007 += "                       AND B1_COD = D3_COD
	CT007 += "                       AND B1_TIPO = 'PA'
	CT007 += "                       AND SB1.D_E_L_E_T_ = ' '
	CT007 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	CT007 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	CT007 += "    AND D3_TM IN('518')
	CT007 += "    AND SD3.D_E_L_E_T_ = ' '
	CT007 += "  GROUP BY D3_CC,
	CT007 += "           D3_DOC, 
	CT007 += "           D3_EMISSAO, 
	CT007 += "           D3_ITEMCTA,
	CT007 += "           D3_CLVL
	CT007 += "  UNION ALL

	// Devolução de Vendas
	CT007 += " SELECT 'SD1:1' ORIGEM,
	CT007 += "        D1_DOC DOCUM, 
	CT007 += "        D1_DTDIGIT DTREF, 
	CT007 += "        '11306001' DEBITO,
	CT007 += "        CASE C5_YITEMCT  
	CT007 += "            WHEN 'I0103' THEN '31406006'/*show room*/
	CT007 += "            WHEN 'I0105' THEN '31406009'/*amostra*/
	CT007 += "            WHEN 'I0107' THEN '31406020'/*feiras*/
	CT007 += "            WHEN 'I0111' THEN '31406021'/*eventos*/
	CT007 += "            WHEN 'I0201' THEN '31401020'/*descontos negociados*/
	CT007 += "            WHEN 'I0202' THEN '31401020'/*descontos negociados*/
	CT007 += "            WHEN 'I0206' THEN '31401020'/*descontos negociados*/
	CT007 += "            WHEN 'I0205' THEN '31401019'/*RPV Extra Norma*/
	CT007 += "            WHEN 'I0109' THEN '31401020'/*descontos negociados */
	CT007 += "        ELSE
	CT007 += "            '41301001'
	CT007 += "        END CREDIT,
	CT007 += "        SUM(D1_QUANT) QUANT,
	CT007 += "        SUM(D1_CUSTO) CUSTO,
	CT007 += "        'VLR CUSTO DEVOL. DE '+RTRIM(X5_DESCRI)+' N/MES' HIST,
	CT007 += "        D2_CCUSTO CCUSTO,
	CT007 += "        C5_YITEMCT ITEMCTA,
	CT007 += "        D2_CLVL CLVL,
	CT007 += "        C5_YSUBTP,
	CT007 += "        C5_YSI
	CT007 += "   FROM "+RetSqlName("SD1")+" SD1
	CT007 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	CT007 += "                       AND F4_CODIGO = D1_TES
	CT007 += "                       AND F4_ESTOQUE = 'S'
	CT007 += "                       AND SF4.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	CT007 += "                       AND B1_COD = D1_COD
	CT007 += "                       AND B1_TIPO = 'PA'
	CT007 += "                       AND SB1.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SD2")+" SD2 ON D2_FILIAL = '"+xFilial("SD2")+"'
	CT007 += "                       AND D2_DOC = D1_NFORI
	CT007 += "                       AND D2_SERIE = D1_SERIORI
	CT007 += "                       AND D2_ITEM = D1_ITEMORI
	CT007 += "                       AND D2_CLIENTE = D1_FORNECE
	CT007 += "                       AND D2_LOJA = D1_LOJA
	CT007 += "                       AND SD2.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = '"+xFilial("SC5")+"'
	CT007 += "                       AND C5_NUM = D2_PEDIDO
	CT007 += "                       AND SC5.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SX5")+" SX5 ON X5_FILIAL = '"+xFilial("SX5")+"'
	CT007 += "                       AND X5_TABELA = 'DJ'
	CT007 += "                       AND X5_CHAVE = C5_YSUBTP
	CT007 += "                       AND SX5.D_E_L_E_T_ = ' '
	CT007 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
	CT007 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	CT007 += "    AND D1_TIPO IN('D')
	CT007 += "    AND SD1.D_E_L_E_T_ = ' '
	CT007 += "  GROUP BY X5_DESCRI,
	CT007 += "           D1_DOC, 
	CT007 += "           D1_DTDIGIT, 
	CT007 += "           D2_CCUSTO,
	CT007 += "           D2_CLVL,
	CT007 += "           C5_YSUBTP,
	CT007 += "           C5_YITEMCT,
	CT007 += "           C5_YSI
	CT007 += "  UNION ALL

	// Retorno de Poder de Terceiros - PA
	CT007 += " SELECT 'SD1:2' ORIGEM,
	CT007 += "        D1_DOC DOCUM, 
	CT007 += "        D1_DTDIGIT DTREF, 
	CT007 += "        '11306001' DEBITO,
	CT007 += "        '11306003' CREDIT,
	CT007 += "        SUM(D1_QUANT) QUANT,
	CT007 += "        SUM(D1_CUSTO) CUSTO,
	CT007 += "        'VLR CUSTO DEVOL. DE '+RTRIM(X5_DESCRI)+' N/MES' HIST,
	CT007 += "        D2_CCUSTO CCUSTO,
	CT007 += "        ' ' ITEMCTA,
	CT007 += "        D2_CLVL CLVL,
	CT007 += "        C5_YSUBTP,
	CT007 += "        C5_YSI
	CT007 += "   FROM "+RetSqlName("SD1")+" SD1
	CT007 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	CT007 += "                       AND F4_CODIGO = D1_TES
	CT007 += "                       AND F4_ESTOQUE = 'N'
	CT007 += "                       AND F4_PODER3 = 'D'
	CT007 += "                       AND SF4.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	CT007 += "                       AND B1_COD = D1_COD
	CT007 += "                       AND B1_TIPO = 'PA'
	CT007 += "                       AND SB1.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SD2")+" SD2 ON D2_FILIAL = '"+xFilial("SD2")+"'
	CT007 += "                       AND D2_DOC = D1_NFORI
	CT007 += "                       AND D2_SERIE = D1_SERIORI
	CT007 += "                       AND D2_ITEM = D1_ITEMORI
	CT007 += "                       AND D2_CLIENTE = D1_FORNECE
	CT007 += "                       AND D2_LOJA = D1_LOJA
	CT007 += "                       AND SD2.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = '"+xFilial("SC5")+"'
	CT007 += "                       AND C5_NUM = D2_PEDIDO
	CT007 += "                       AND SC5.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SX5")+" SX5 ON X5_FILIAL = '"+xFilial("SX5")+"'
	CT007 += "                       AND X5_TABELA = 'DJ'
	CT007 += "                       AND X5_CHAVE = C5_YSUBTP
	CT007 += "                       AND SX5.D_E_L_E_T_ = ' '
	CT007 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
	CT007 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	CT007 += "    AND SD1.D_E_L_E_T_ = ' '
	CT007 += "  GROUP BY X5_DESCRI,
	CT007 += "           D1_DOC, 
	CT007 += "           D1_DTDIGIT, 
	CT007 += "           D2_CCUSTO,
	CT007 += "           D2_CLVL,
	CT007 += "           C5_YSUBTP,
	CT007 += "           C5_YSI
	CT007 += "  UNION ALL

	// Retorno de Poder de Terceiros - Embalagem
	CT007 += " SELECT 'SD1:3' ORIGEM,
	CT007 += "        D1_DOC DOCUM, 
	CT007 += "        D1_DTDIGIT DTREF, 
	CT007 += "        '11306001' DEBITO,
	CT007 += "        CASE
	CT007 += "          WHEN D1_CONTA = '11303001            ' THEN '11303090            '
	CT007 += "          ELSE '11303091            '
	CT007 += "        END CREDIT,
	CT007 += "        SUM(D1_QUANT) QUANT,
	CT007 += "        SUM(D1_CUSTO) CUSTO,
	CT007 += "        'VLR CUSTO DEVOL. DE '+RTRIM(X5_DESCRI)+' N/MES' HIST,
	CT007 += "        D2_CCUSTO CCUSTO,
	CT007 += "        ' ' ITEMCTA,
	CT007 += "        D2_CLVL CLVL,
	CT007 += "        C5_YSUBTP,
	CT007 += "        C5_YSI
	CT007 += "   FROM "+RetSqlName("SD1")+" SD1
	CT007 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	CT007 += "                       AND F4_CODIGO = D1_TES
	CT007 += "                       AND F4_ESTOQUE = 'N'
	CT007 += "                       AND F4_PODER3 = 'D'
	CT007 += "                       AND SF4.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	CT007 += "                       AND B1_COD = D1_COD
	CT007 += "                       AND B1_TIPO = 'ME'
	CT007 += "                       AND SB1.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SD2")+" SD2 ON D2_FILIAL = '"+xFilial("SD2")+"'
	CT007 += "                       AND D2_DOC = D1_NFORI
	CT007 += "                       AND D2_SERIE = D1_SERIORI
	CT007 += "                       AND D2_ITEM = D1_ITEMORI
	CT007 += "                       AND D2_CLIENTE = D1_FORNECE
	CT007 += "                       AND D2_LOJA = D1_LOJA
	CT007 += "                       AND SD2.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = '"+xFilial("SC5")+"'
	CT007 += "                       AND C5_NUM = D2_PEDIDO
	CT007 += "                       AND SC5.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SX5")+" SX5 ON X5_FILIAL = '"+xFilial("SX5")+"'
	CT007 += "                       AND X5_TABELA = 'DJ'
	CT007 += "                       AND X5_CHAVE = C5_YSUBTP
	CT007 += "                       AND SX5.D_E_L_E_T_ = ' '
	CT007 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
	CT007 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	CT007 += "    AND SD1.D_E_L_E_T_ = ' '
	CT007 += "  GROUP BY D1_CONTA,
	CT007 += "           D1_DOC, 
	CT007 += "           D1_DTDIGIT, 
	CT007 += "           X5_DESCRI,
	CT007 += "           D2_CCUSTO,
	CT007 += "           D2_CLVL,
	CT007 += "           C5_YSUBTP,
	CT007 += "           C5_YSI
	CT007 += "  UNION ALL

	// Retorno Poder de Terceiros sem Industrialização - PA
	CT007 += " SELECT 'SD1:4' ORIGEM,
	CT007 += "        D1_DOC DOCUM, 
	CT007 += "        D1_DTDIGIT DTREF, 
	CT007 += "        '11306001' DEBITO,
	CT007 += "        '11306003' CREDIT,
	CT007 += "        SUM(D1_QUANT) QUANT,
	CT007 += "        SUM(D1_CUSTO) CUSTO,
	CT007 += "        'VLR CUSTO DEVOL. SEM INDUSTRIALIZAO N/MES' HIST,
	CT007 += "        D1_CC CCUSTO,
	CT007 += "        ' ' ITEMCTA,
	CT007 += "        D1_CLVL CLVL,
	CT007 += "        ' ' C5_YSUBTP,
	CT007 += "        ' ' C5_YSI
	CT007 += "   FROM "+RetSqlName("SD1")+" SD1
	CT007 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	CT007 += "                       AND F4_CODIGO = D1_TES
	CT007 += "                       AND F4_ESTOQUE = 'S'
	CT007 += "                       AND F4_PODER3 = 'D'
	CT007 += "                       AND SF4.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	CT007 += "                       AND B1_COD = D1_COD
	CT007 += "                       AND B1_TIPO = 'PA'
	CT007 += "                       AND SB1.D_E_L_E_T_ = ' '
	CT007 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
	CT007 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	CT007 += "    AND SD1.D_E_L_E_T_ = ' '
	CT007 += "  GROUP BY D1_CC,
	CT007 += "           D1_DOC, 
	CT007 += "           D1_DTDIGIT, 
	CT007 += "           D1_CLVL
	CT007 += "  UNION ALL

	// Retorno Poder de Terceiros sem Industrialização - Embalagem
	CT007 += " SELECT 'SD1:5' ORIGEM,
	CT007 += "        D1_DOC DOCUM, 
	CT007 += "        D1_DTDIGIT DTREF, 
	CT007 += "        D1_CONTA DEBITO,
	CT007 += "        CASE
	CT007 += "          WHEN D1_CONTA = '11303001            ' THEN '11303090            '
	CT007 += "          ELSE '11303091            '
	CT007 += "        END CREDIT,
	CT007 += "        SUM(D1_QUANT) QUANT,
	CT007 += "        SUM(D1_CUSTO) CUSTO,
	CT007 += "        'VLR CUSTO DEVOL. SEM INDUSTRIALIZAO N/MES' HIST,
	CT007 += "        D1_CC CCUSTO,
	CT007 += "        ' ' ITEMCTA,
	CT007 += "        D1_CLVL CLVL,
	CT007 += "        ' ' C5_YSUBTP,
	CT007 += "        ' ' C5_YSI
	CT007 += "   FROM "+RetSqlName("SD1")+" SD1
	CT007 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	CT007 += "                       AND F4_CODIGO = D1_TES
	CT007 += "                       AND F4_ESTOQUE = 'S'
	CT007 += "                       AND F4_PODER3 = 'D'
	CT007 += "                       AND SF4.D_E_L_E_T_ = ' '
	CT007 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	CT007 += "                       AND B1_COD = D1_COD
	CT007 += "                       AND B1_TIPO = 'ME'
	CT007 += "                       AND SB1.D_E_L_E_T_ = ' '
	CT007 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
	CT007 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	CT007 += "    AND SD1.D_E_L_E_T_ = ' '
	CT007 += "  GROUP BY D1_CONTA,
	CT007 += "           D1_DOC, 
	CT007 += "           D1_DTDIGIT, 
	CT007 += "           D1_CC,
	CT007 += "           D1_CLVL
	CTcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,CT007),'CT07',.F.,.T.)
	dbSelectArea("CT07")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento28")

		hjCLVL   := IIF(CT07->C5_YSUBTP $ "N /E /IM/FE", "", CT07->CLVL)
		hjCCUSTO := IIF(CT07->C5_YSUBTP $ "N /E /IM/FE", "", CT07->CCUSTO)
		hjCliAiD := IIF(Substr(CT07->DEBITO,1,1) $ "3/4/6", CT07->C5_YSI, "")
		hjCliAiC := IIF(Substr(CT07->CREDIT,1,1) $ "3/4/6", CT07->C5_YSI, "")

		oExcel:AddRow(nxPlan, nxTabl, { CT07->DOCUM, dtoc(stod(CT07->DTREF)), CT07->DEBITO, CT07->CREDIT, hjCLVL, hjCLVL, CT07->ITEMCTA, CT07->ITEMCTA, CT07->QUANT, CT07->CUSTO, CT07->HIST, hjCCUSTO, hjCCUSTO, CT07->ORIGEM, hjCliAiD, hjCliAiC })

		dbSelectArea("CT07")
		dbSkip()

	End
	CT07->(dbCloseArea())
	Ferase(CTcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(CTcIndex+OrdBagExt())          //indice gerado

	// -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	// -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

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

	oLogProc:LogFimProc()

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
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
