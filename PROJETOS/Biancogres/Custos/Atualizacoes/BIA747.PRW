#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA747
@author Marcos Alberto Soprani
@since 12/02/14
@version 1.0
@description Contabilização do CPV
@obs Em 06/03/17... Ajuste na linha R09
@type function
/*/

User Function BIA747()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Private dtRefEmi := dDataBase

	cHInicio := Time()
	fPerg := "BIA747"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA747 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase <> GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.","BIA747 - Data de Fechamento!!!")
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA747",fPerg)

	// Em 03/10/19, durante o fechamento do estoque de set/19 foi identificado o primeiro problema que levou ao ajuste no programa
	// Tratamento implementado porque a JK passou a movimentar um volume maior de registros de entrada e saída e com isso os problema corriqueiro começaram a ocorre
	If cEmpAnt <> "06" .or. 1 == 1

		kjDtINI := MV_PAR01
		kjDtFIM := MV_PAR02
		kjTipoP := MV_PAR03

		msKernelCt := U_BIA185( kjDtINI, kjDtFIM )
		msNomeTMP  := "##TMPBIA747" + cEmpAnt + cFilAnt + __cUserID + strzero(seconds() * 3500,10)
		msMontaSql := msKernelCt + "SELECT * INTO " + msNomeTMP + " FROM TABFINAL "
		U_BIAMsgRun("Aguarde... Gerando Base...",,{|| TcSQLExec(msMontaSql)})

		xValidCt := 0
		RF003 := U_B185CHKF( kjDtINI, kjDtFIM, kjTipoP )
		cIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,RF003),'RF03',.T.,.T.)
		aStru1 := ("RF03")->(dbStruct())
		dbSelectArea("RF03")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()
			IncProc()
			xValidCt += Round(RF03->CUSTO,2)
			dbSelectArea("RF03")
			dbSkip()
		End
		RF03->(dbCloseArea())

		cfContinua := .T.
		If xValidCt <> 0
			cfContinua := MsgNOYES("Os valores do Custo Contábil não estão totalmente apropriados ao Kardex: "+Alltrim(Str(xValidCt))+"!!!","Atenção - BIA747")
		EndIf

		If cfContinua
			fgLanPad := "D01"
			fgLotCtb := "009009"
			fgVetCtb := {}
			fgVetEXC := {}
			fgPermDg := .T.

			msCtaPA := ""
			If cEmpAnt == "01"

				msCtaPA := "11306001"

			ElseIf cEmpAnt == "06"

				msCtaPA := "11306005"

			Else

				MsgINFO("Conta Contábil de PA não configurada para esta empresa. Necessário especificar e ajustar o programa", "BIA747")
				Return

			EndIf

			// Saidas Normais
			CT007 := " SELECT ORIGEM, 
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
			CT007 += "                '" + msCtaPA + "' CREDIT, 
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
			CT007 += "                  X5_DESCRI, 
			CT007 += "                  D2_CCUSTO, 
			CT007 += "                  D2_CLVL, 
			CT007 += "                  C5_YITEMCT, 
			CT007 += "                  C5_YSI, 
			CT007 += "                  RTRIM(ISNULL(CONVERT(VARCHAR(8000), CONVERT(VARBINARY(8000), C5_YOBS)), '')) ) AS TAGRPD
			CT007 += " GROUP BY ORIGEM, 
			CT007 += "          DEBITO, 
			CT007 += "          CREDIT, 
			CT007 += "          HIST, 
			//CT007 += "          HIST2, 
			CT007 += "          CCUSTO, 
			CT007 += "          ITEMCTA, 
			CT007 += "          CLVL, 
			CT007 += "          C5_YSUBTP, 
			CT007 += "          C5_YSI
			CT007 += "  UNION ALL

			// Remessa para industrialização - PA
			CT007 += " SELECT 'SD2:2' ORIGEM,
			CT007 += "        '11306003' DEBITO,
			CT007 += "        '" + msCtaPA + "' CREDIT,
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
			CT007 += "           X5_DESCRI,
			CT007 += "           D2_CCUSTO,
			CT007 += "           D2_CLVL,
			CT007 += "           C5_YSI
			CT007 += "  UNION ALL

			// Remessa para industrialização - Embalagem
			CT007 += " SELECT 'SD2:3' ORIGEM,
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
			CT007 += "           D2_CONTA,
			CT007 += "           X5_DESCRI,
			CT007 += "           D2_CCUSTO,
			CT007 += "           D2_CLVL,
			CT007 += "           C5_YSI
			CT007 += "  UNION ALL

			// Quebras
			CT007 += " SELECT 'SD3:1' ORIGEM,		
			CT007 += "        '41301001' DEBITO,
			CT007 += "        '" + msCtaPA + "' CREDIT,
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
			CT007 += "    AND D3_ESTORNO = ' '
			CT007 += "    AND SD3.D_E_L_E_T_ = ' '
			CT007 += "  GROUP BY D3_CC,
			CT007 += "           D3_ITEMCTA,
			CT007 += "           D3_CLVL
			CT007 += "  UNION ALL

			// Inventário Saida
			CT007 += " SELECT 'SD3:2' ORIGEM,
			CT007 += "        '41301001' DEBITO,
			CT007 += "        '" + msCtaPA + "' CREDIT,
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
			CT007 += "    AND D3_ESTORNO = ' '
			CT007 += "    AND SD3.D_E_L_E_T_ = ' '
			CT007 += "  GROUP BY D3_CC,
			CT007 += "           D3_ITEMCTA,
			CT007 += "           D3_CLVL
			CT007 += "  UNION ALL

			// Inventário Entrada
			CT007 += " SELECT 'SD3:3' ORIGEM,
			CT007 += "        '" + msCtaPA + "' DEBITO,
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
			CT007 += "    AND D3_ESTORNO = ' '			
			CT007 += "    AND SD3.D_E_L_E_T_ = ' '
			CT007 += "  GROUP BY D3_CC,
			CT007 += "           D3_ITEMCTA,
			CT007 += "           D3_CLVL
			CT007 += "  UNION ALL

			// Quebras para uso interno
			CT007 += " SELECT 'SD3:4' ORIGEM,
			CT007 += "        '41301001' DEBITO,
			CT007 += "        '" + msCtaPA + "' CREDIT,
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
			CT007 += "    AND D3_ESTORNO = ' '
			CT007 += "    AND SD3.D_E_L_E_T_ = ' '
			CT007 += "  GROUP BY D3_CC,
			CT007 += "           D3_ITEMCTA,
			CT007 += "           D3_CLVL
			CT007 += "  UNION ALL

			// Devolução de Vendas
			CT007 += " SELECT 'SD1:1' ORIGEM,
			CT007 += "        '" + msCtaPA + "' DEBITO,
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
			CT007 += "           D2_CCUSTO,
			CT007 += "           D2_CLVL,
			CT007 += "           C5_YSUBTP,
			CT007 += "           C5_YITEMCT,
			CT007 += "           C5_YSI
			CT007 += "  UNION ALL

			// Retorno de Poder de Terceiros - PA
			CT007 += " SELECT 'SD1:2' ORIGEM,
			CT007 += "        '" + msCtaPA + "' DEBITO,
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
			CT007 += "           D2_CCUSTO,
			CT007 += "           D2_CLVL,
			CT007 += "           C5_YSUBTP,
			CT007 += "           C5_YSI
			CT007 += "  UNION ALL

			// Retorno de Poder de Terceiros - Embalagem
			CT007 += " SELECT 'SD1:3' ORIGEM,
			CT007 += "        '" + msCtaPA + "' DEBITO,
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
			CT007 += "           X5_DESCRI,
			CT007 += "           D2_CCUSTO,
			CT007 += "           D2_CLVL,
			CT007 += "           C5_YSUBTP,
			CT007 += "           C5_YSI
			CT007 += "  UNION ALL

			// Retorno Poder de Terceiros sem Industrialização - PA
			CT007 += " SELECT 'SD1:4' ORIGEM,
			CT007 += "        '" + msCtaPA + "' DEBITO,
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
			CT007 += "           D1_CLVL
			CT007 += "  UNION ALL

			// Retorno Poder de Terceiros sem Industrialização - Embalagem
			CT007 += " SELECT 'SD1:5' ORIGEM,
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
			CT007 += "           D1_CC,
			CT007 += "           D1_CLVL
			cIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,CT007),'CT07',.T.,.T.)
			aStru1 := ("CT07")->(dbStruct())
			dbSelectArea("CT07")
			dbGoTop()
			ProcRegua(RecCount())
			While !Eof()

				IncProc()

				hjCLVL   := IIF(CT07->C5_YSUBTP $ "N /E /IM/FE", "", CT07->CLVL)
				hjCCUSTO := IIF(CT07->C5_YSUBTP $ "N /E /IM/FE", "", CT07->CCUSTO)
				hjCliAiD := IIF(Substr(CT07->DEBITO,1,1) $ "3/4/6", CT07->C5_YSI, "")
				hjCliAiC := IIF(Substr(CT07->CREDIT,1,1) $ "3/4/6", CT07->C5_YSI, "")

				// Vetor ==>>          Debito,      Credito,     ClVl_D,     ClVl_C, Item_Contab_D, Item_Contab_C,       Valor,  Histórico,     CCUSTO_D,     CCUSTO_C,       ORIGEM,  CT2_ATIVDE, CT2_ATIVCR
				Aadd(fgVetCtb, { CT07->DEBITO, CT07->CREDIT, hjCLVL, hjCLVL, CT07->ITEMCTA, CT07->ITEMCTA, CT07->CUSTO, CT07->HIST, hjCCUSTO, hjCCUSTO, CT07->ORIGEM, hjCliAiD, hjCliAiC })

				Aadd(fgVetEXC, { CT07->DEBITO, CT07->CREDIT, hjCLVL, hjCLVL, CT07->ITEMCTA, CT07->ITEMCTA, Transform(CT07->QUANT,"@E 999,999,999.99"), Transform(CT07->CUSTO,"@E 999,999,999.99"), CT07->HIST, hjCCUSTO, hjCCUSTO, CT07->ORIGEM, hjCliAiD, hjCliAiC })

				dbSelectArea("CT07")
				dbSkip()

			End
			CT07->(dbCloseArea())

			//                                     Contabilização
			*****************************************************

			U_BiaCtbAV(fgLanPad, fgLotCtb, fgVetCtb, fgPermDg)

			//                                              Excel
			*****************************************************

			xCamp := {}
			AADD(xCamp,{ "DEBITO"     ,"C",20,0 } )
			AADD(xCamp,{ "CREDITO"    ,"C",20,0 } )
			AADD(xCamp,{ "CLVLD"      ,"C",09,0 } )
			AADD(xCamp,{ "CVVLC"      ,"C",09,0 } )
			AADD(xCamp,{ "ITEMD"      ,"C",09,0 } )
			AADD(xCamp,{ "ITEMC"      ,"C",09,0 } )
			AADD(xCamp,{ "QUANT"      ,"N",18,8 } )
			AADD(xCamp,{ "CUSTO"      ,"N",18,2 } )
			AADD(xCamp,{ "HISTOR"     ,"C",40,0 } )
			AADD(xCamp,{ "CCUSTOD"    ,"C",09,0 } )
			AADD(xCamp,{ "CCUSTOC"    ,"C",09,0 } )
			AADD(xCamp,{ "ORIGEM"     ,"C",90,0 } )
			AADD(xCamp,{ "CLI_AID"    ,"C",06,0 } )
			AADD(xCamp,{ "CLI_AIC"    ,"C",06,0 } )

			U_BIAxExcel(fgVetEXC, xCamp, "BIA747"+strzero(seconds()%3500,5) )

		Else

			MsgSTOP("Os valores do Custo Contábil não estão totalmente apropriados ao Kardex: "+Alltrim(Str(xValidCt))+"!!!","Atenção - BIA747")

		EndIf

	Else 

		fgLanPad := "D01"
		fgLotCtb := "009000"
		fgVetCtb := {}
		fgVetEXC := {}
		fgPermDg := .T.

		CT007 := " SELECT 'SD1:6' ORIGEM,
		CT007 += "        '11301001' DEBITO,
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
		CT007 += "           D2_CCUSTO,
		CT007 += "           D2_CLVL,
		CT007 += "           C5_YSUBTP,
		CT007 += "           C5_YITEMCT,
		CT007 += "           C5_YSI
		cIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,CT007),'CT07',.T.,.T.)
		aStru1 := ("CT07")->(dbStruct())
		dbSelectArea("CT07")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			hjCLVL   := IIF(CT07->C5_YSUBTP $ "N /E /IM/FE", "", CT07->CLVL)
			hjCCUSTO := IIF(CT07->C5_YSUBTP $ "N /E /IM/FE", "", CT07->CCUSTO)
			hjCliAiD := IIF(Substr(CT07->DEBITO,1,1) $ "3/4/6", CT07->C5_YSI, "")
			hjCliAiC := IIF(Substr(CT07->CREDIT,1,1) $ "3/4/6", CT07->C5_YSI, "")

			// Vetor ==>>          Debito,      Credito,     ClVl_D,     ClVl_C, Item_Contab_D, Item_Contab_C,       Valor,  Histórico,     CCUSTO_D,     CCUSTO_C,       ORIGEM,  CT2_ATIVDE, CT2_ATIVCR
			Aadd(fgVetCtb, { CT07->DEBITO, CT07->CREDIT, hjCLVL, hjCLVL, CT07->ITEMCTA, CT07->ITEMCTA, CT07->CUSTO, CT07->HIST, hjCCUSTO, hjCCUSTO, CT07->ORIGEM, hjCliAiD, hjCliAiC })

			Aadd(fgVetEXC, { CT07->DEBITO, CT07->CREDIT, hjCLVL, hjCLVL, CT07->ITEMCTA, CT07->ITEMCTA, Transform(CT07->QUANT,"@E 999,999,999.99"), Transform(CT07->CUSTO,"@E 999,999,999.99"), CT07->HIST, hjCCUSTO, hjCCUSTO, CT07->ORIGEM, hjCliAiD, hjCliAiC })

			dbSelectArea("CT07")
			dbSkip()

		End
		CT07->(dbCloseArea())

		//                                     Contabilização
		*****************************************************

		U_BiaCtbAV(fgLanPad, fgLotCtb, fgVetCtb, fgPermDg)

		//                                              Excel
		*****************************************************

		xCamp := {}
		AADD(xCamp,{ "DEBITO"     ,"C",20,0 } )
		AADD(xCamp,{ "CREDITO"    ,"C",20,0 } )
		AADD(xCamp,{ "CLVLD"      ,"C",09,0 } )
		AADD(xCamp,{ "CVVLC"      ,"C",09,0 } )
		AADD(xCamp,{ "ITEMD"      ,"C",09,0 } )
		AADD(xCamp,{ "ITEMC"      ,"C",09,0 } )
		AADD(xCamp,{ "QUANT"      ,"N",18,8 } )
		AADD(xCamp,{ "CUSTO"      ,"N",18,2 } )
		AADD(xCamp,{ "HISTOR"     ,"C",40,0 } )
		AADD(xCamp,{ "CCUSTOD"    ,"C",09,0 } )
		AADD(xCamp,{ "CCUSTOC"    ,"C",09,0 } )
		AADD(xCamp,{ "ORIGEM"     ,"C",90,0 } )
		AADD(xCamp,{ "CLI_AID"    ,"C",06,0 } )
		AADD(xCamp,{ "CLI_AIC"    ,"C",06,0 } )

		U_BIAxExcel(fgVetEXC, xCamp, "BIA747"+strzero(seconds()%3500,5) )

	EndIf

	oLogProc:LogFimProc()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 25.01.13 ¦¦¦
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
	aAdd(aRegs,{cPerg,"01","De Data                ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data               ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Tipo de Produto        ?","","","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","02"})

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
