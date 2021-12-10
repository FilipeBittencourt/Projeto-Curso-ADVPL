#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA185
@author Marcos Alberto Soprani
@since 31/01/20
@version 1.0
@description Kernel do Rateio / Checagem do Custo de estoque para CPP 
@obs Em 31/01/20... Vários programas terão de migrar para este Kernel
.                  o Primeiro delete será o BIA788
@type function
/*/

User Function BIA185(deData, atData)

	Local xrEnter   := CHR(13) + CHR(10)
	Local xKer007

	xKer007 := Alltrim(" WITH TAB_A                                                                                                                                               ") + xrEnter
	xKer007 += Alltrim("      AS (SELECT 'GNA' APL,                                                                                                                               ") + xrEnter
	xKer007 += Alltrim("                 'LT_8840_DEB' QUADRO,                                                                                                                    ") + xrEnter
	xKer007 += Alltrim("                 CT2_DEBITO CTA,                                                                                                                          ") + xrEnter
	xKer007 += Alltrim("                 CT2_CLVLDB CLVL,                                                                                                                         ") + xrEnter
	xKer007 += Alltrim("                 PERIODO = LEFT(CT2_DATA, 6),                                                                                                             ") + xrEnter
	xKer007 += Alltrim("                 SUM(CT2_VALOR) VALOR                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("          FROM " + RetSqlName("CT2") + " (NOLOCK)                                                                                                         ") + xrEnter
	xKer007 += Alltrim("          WHERE CT2_FILIAL = '" + xFilial("CT2") + "'                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND CT2_DATA BETWEEN '" + dtos(deData) + "' AND '" + dtos(atData) + "'                                                                    ") + xrEnter
	xKer007 += Alltrim("                AND CT2_LOTE = '008840'                                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_ORIGEM, 14, 2) = '  '                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_DEBITO, 1, 1) = '6'                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_DEBITO, 1, 2) <> '62'                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                AND CT2_MOEDLC = '01'                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                                      ") + xrEnter
	xKer007 += Alltrim("          GROUP BY CT2_DEBITO,                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                   CT2_CLVLDB,                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                   LEFT(CT2_DATA, 6)                                                                                                                      ") + xrEnter
	xKer007 += Alltrim("          UNION ALL                                                                                                                                       ") + xrEnter
	xKer007 += Alltrim("          SELECT 'GNA' APL,                                                                                                                               ") + xrEnter
	xKer007 += Alltrim("                 'LT_8840_CRD' QUADRO,                                                                                                                    ") + xrEnter
	xKer007 += Alltrim("                 CT2_CREDIT CTA,                                                                                                                          ") + xrEnter
	xKer007 += Alltrim("                 CT2_CLVLCR CLVL,                                                                                                                         ") + xrEnter
	xKer007 += Alltrim("                 PERIODO = LEFT(CT2_DATA, 6),                                                                                                             ") + xrEnter
	xKer007 += Alltrim("                 SUM(CT2_VALOR) * (-1) VALOR                                                                                                              ") + xrEnter
	xKer007 += Alltrim("          FROM " + RetSqlName("CT2") + "(NOLOCK)                                                                                                          ") + xrEnter
	xKer007 += Alltrim("          WHERE CT2_FILIAL = '" + xFilial("CT2") + "'                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND CT2_DATA BETWEEN '" + dtos(deData) + "' AND '" + dtos(atData) + "'                                                                    ") + xrEnter
	xKer007 += Alltrim("                AND CT2_LOTE = '008840'                                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_ORIGEM, 14, 2) = '  '                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_CREDIT, 1, 1) = '6'                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_CREDIT, 1, 2) <> '62'                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                AND CT2_MOEDLC = '01'                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                                      ") + xrEnter
	xKer007 += Alltrim("          GROUP BY CT2_CREDIT,                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                   CT2_CLVLCR,                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                   LEFT(CT2_DATA, 6)                                                                                                                      ") + xrEnter
	xKer007 += Alltrim("          UNION ALL                                                                                                                                       ") + xrEnter
	xKer007 += Alltrim("          SELECT 'GNA' APL,                                                                                                                               ") + xrEnter
	xKer007 += Alltrim("                 'LT_OUTR_DEB' QUADRO,                                                                                                                    ") + xrEnter
	xKer007 += Alltrim("                 CT2_DEBITO CTA,                                                                                                                          ") + xrEnter
	xKer007 += Alltrim("                 CT2_CLVLDB CLVL,                                                                                                                         ") + xrEnter
	xKer007 += Alltrim("                 PERIODO = LEFT(CT2_DATA, 6),                                                                                                             ") + xrEnter
	xKer007 += Alltrim("                 SUM(CT2_VALOR) VALOR                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("          FROM " + RetSqlName("CT2") + "(NOLOCK)                                                                                                          ") + xrEnter
	xKer007 += Alltrim("          WHERE CT2_FILIAL = '" + xFilial("CT2") + "'                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND CT2_DATA BETWEEN '" + dtos(deData) + "' AND '" + dtos(atData) + "'                                                                    ") + xrEnter
	xKer007 += Alltrim("                AND CT2_LOTE <> '008840'                                                                                                                  ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_DEBITO, 1, 1) = '6'                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_DEBITO, 1, 2) <> '62'                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                AND CT2_MOEDLC = '01'                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                                      ") + xrEnter
	xKer007 += Alltrim("          GROUP BY CT2_DEBITO,                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                   CT2_CLVLDB,                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                   LEFT(CT2_DATA, 6)                                                                                                                      ") + xrEnter
	xKer007 += Alltrim("          UNION ALL                                                                                                                                       ") + xrEnter
	xKer007 += Alltrim("          SELECT 'GNA' APL,                                                                                                                               ") + xrEnter
	xKer007 += Alltrim("                 'LT_8840_CRD' QUADRO,                                                                                                                    ") + xrEnter
	xKer007 += Alltrim("                 CT2_CREDIT CTA,                                                                                                                          ") + xrEnter
	xKer007 += Alltrim("                 CT2_CLVLCR CLVL,                                                                                                                         ") + xrEnter
	xKer007 += Alltrim("                 PERIODO = LEFT(CT2_DATA, 6),                                                                                                             ") + xrEnter
	xKer007 += Alltrim("                 SUM(CT2_VALOR) * (-1) VALOR                                                                                                              ") + xrEnter
	xKer007 += Alltrim("          FROM " + RetSqlName("CT2") + "(NOLOCK)                                                                                                          ") + xrEnter
	xKer007 += Alltrim("          WHERE CT2_FILIAL = '" + xFilial("CT2") + "'                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND CT2_DATA BETWEEN '" + dtos(deData) + "' AND '" + dtos(atData) + "'                                                                    ") + xrEnter
	xKer007 += Alltrim("                AND CT2_LOTE <> '008840'                                                                                                                  ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_CREDIT, 1, 1) = '6'                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_CREDIT, 1, 2) <> '62'                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                AND CT2_MOEDLC = '01'                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                                      ") + xrEnter
	xKer007 += Alltrim("          GROUP BY CT2_CREDIT,                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                   CT2_CLVLCR,                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                   LEFT(CT2_DATA, 6)                                                                                                                      ") + xrEnter
	xKer007 += Alltrim("          UNION ALL                                                                                                                                       ") + xrEnter
	xKer007 += Alltrim("          SELECT 'GA' APL,                                                                                                                                ") + xrEnter
	xKer007 += Alltrim("                 'LT_8840_DEB' QUADRO,                                                                                                                    ") + xrEnter
	xKer007 += Alltrim("                 CT2_DEBITO CTA,                                                                                                                          ") + xrEnter
	xKer007 += Alltrim("                 CT2_CLVLDB CLVL,                                                                                                                         ") + xrEnter
	xKer007 += Alltrim("                 PERIODO = LEFT(CT2_DATA, 6),                                                                                                             ") + xrEnter
	xKer007 += Alltrim("                 SUM(CT2_VALOR) VALOR                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("          FROM " + RetSqlName("CT2") + "(NOLOCK)                                                                                                          ") + xrEnter
	xKer007 += Alltrim("          WHERE CT2_FILIAL = '" + xFilial("CT2") + "'                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND CT2_DATA BETWEEN '" + dtos(deData) + "' AND '" + dtos(atData) + "'                                                                    ") + xrEnter
	xKer007 += Alltrim("                AND CT2_LOTE = '008840'                                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_ORIGEM, 14, 2) <> '  '                                                                                                  ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_DEBITO, 1, 1) = '6'                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_DEBITO, 1, 2) <> '62'                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                AND CT2_MOEDLC = '01'                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                                      ") + xrEnter
	xKer007 += Alltrim("          GROUP BY CT2_DEBITO,                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                   CT2_CLVLDB,                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                   LEFT(CT2_DATA, 6)                                                                                                                      ") + xrEnter
	xKer007 += Alltrim("          UNION ALL                                                                                                                                       ") + xrEnter
	xKer007 += Alltrim("          SELECT 'GA' APL,                                                                                                                                ") + xrEnter
	xKer007 += Alltrim("                 'LT_8840_CRD' QUADRO,                                                                                                                    ") + xrEnter
	xKer007 += Alltrim("                 CT2_CREDIT CTA,                                                                                                                          ") + xrEnter
	xKer007 += Alltrim("                 CT2_CLVLCR CLVL,                                                                                                                         ") + xrEnter
	xKer007 += Alltrim("                 PERIODO = LEFT(CT2_DATA, 6),                                                                                                             ") + xrEnter
	xKer007 += Alltrim("                 SUM(CT2_VALOR) * (-1) VALOR                                                                                                              ") + xrEnter
	xKer007 += Alltrim("          FROM " + RetSqlName("CT2") + "(NOLOCK)                                                                                                          ") + xrEnter
	xKer007 += Alltrim("          WHERE CT2_FILIAL = '" + xFilial("CT2") + "'                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND CT2_DATA BETWEEN '" + dtos(deData) + "' AND '" + dtos(atData) + "'                                                                    ") + xrEnter
	xKer007 += Alltrim("                AND CT2_LOTE = '008840'                                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_ORIGEM, 14, 2) <> '  '                                                                                                  ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_CREDIT, 1, 1) = '6'                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND SUBSTRING(CT2_CREDIT, 1, 2) <> '62'                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                AND CT2_MOEDLC = '01'                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                                      ") + xrEnter
	xKer007 += Alltrim("          GROUP BY CT2_CREDIT,                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                   CT2_CLVLCR,                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                   LEFT(CT2_DATA, 6)),                                                                                                                    ") + xrEnter
	xKer007 += Alltrim("      TAB_A_ACUM                                                                                                                                          ") + xrEnter
	xKer007 += Alltrim("      AS (SELECT PERIODO,                                                                                                                                 ") + xrEnter
	xKer007 += Alltrim("                 APL,                                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                 CTA,                                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                 CLVL,                                                                                                                                    ") + xrEnter
	xKer007 += Alltrim("                 ROUND(SUM(VALOR), 2) VALOR                                                                                                               ") + xrEnter
	xKer007 += Alltrim("          FROM TAB_A                                                                                                                                      ") + xrEnter
	xKer007 += Alltrim("          GROUP BY PERIODO,                                                                                                                               ") + xrEnter
	xKer007 += Alltrim("                   APL,                                                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                   CTA,                                                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                   CLVL                                                                                                                                   ") + xrEnter
	xKer007 += Alltrim("          HAVING ROUND(SUM(VALOR), 2) <> 0),                                                                                                              ") + xrEnter
	xKer007 += Alltrim("      TAB_B                                                                                                                                               ") + xrEnter
	xKer007 += Alltrim("      AS (SELECT PERIODO,                                                                                                                                 ") + xrEnter
	xKer007 += Alltrim("                 APL,                                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                 CTA,                                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                 CT1_DESC01 DESC01,                                                                                                                       ") + xrEnter
	xKer007 += Alltrim("                 SUBSTRING(CT1_YAGRUP, 1, 10) AGRUP,                                                                                                      ") + xrEnter
	xKer007 += Alltrim("                 CASE                                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                     WHEN RTRIM(CLVL) IN('3180', '3181', '3183', '3184', '3280')                                                                          ") + xrEnter
	xKer007 += Alltrim("                     THEN CTH_YITCUS                                                                                                                      ") + xrEnter
	xKer007 += Alltrim("                     WHEN CTA IN('61103001')                                                                                                              ") + xrEnter
	xKer007 += Alltrim("                          AND RTRIM(CLVL) IN('3103')                                                                                                      ") + xrEnter
	xKer007 += Alltrim("                     THEN '026'                                                                                                                           ") + xrEnter
	xKer007 += Alltrim("                     ELSE CT1_YITCUS                                                                                                                      ") + xrEnter
	xKer007 += Alltrim("                 END ITCUS,                                                                                                                               ") + xrEnter
	xKer007 += Alltrim("                 CLVL,                                                                                                                                    ") + xrEnter
	xKer007 += Alltrim("                 SUBSTRING(CTH_YCRIT, 1, 3) CRIT,                                                                                                         ") + xrEnter
	xKer007 += Alltrim("                 SUM(VALOR) VALOR                                                                                                                         ") + xrEnter
	xKer007 += Alltrim("          FROM TAB_A_ACUM AS TAB                                                                                                                          ") + xrEnter
	xKer007 += Alltrim("               INNER JOIN " + RetSqlName("CT1") + " CT1 (NOLOCK) ON CT1_FILIAL = '" + xFilial("CT1") + "'                                                 ") + xrEnter
	xKer007 += Alltrim("                                        AND CT1_CONTA = CTA                                                                                               ") + xrEnter
	xKer007 += Alltrim("                                        AND CT1.D_E_L_E_T_ = ' '                                                                                          ") + xrEnter
	xKer007 += Alltrim("               INNER JOIN " + RetSqlName("CTH") + " CTH (NOLOCK) ON CTH_FILIAL = '" + xFilial("CTH") + "'                                                 ") + xrEnter
	xKer007 += Alltrim("                                        AND CTH_CLVL = CLVL                                                                                               ") + xrEnter
	xKer007 += Alltrim("                                        AND CTH_YAPLCT = 'S'                                                                                              ") + xrEnter
	xKer007 += Alltrim("                                        AND CTH.D_E_L_E_T_ = ' '                                                                                          ") + xrEnter
	xKer007 += Alltrim("          GROUP BY PERIODO,                                                                                                                               ") + xrEnter
	xKer007 += Alltrim("                   APL,                                                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                   CTA,                                                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                   CT1_DESC01,                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                   CT1_YITCUS,                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                   SUBSTRING(CT1_YAGRUP, 1, 10),                                                                                                          ") + xrEnter
	xKer007 += Alltrim("                   CLVL,                                                                                                                                  ") + xrEnter
	xKer007 += Alltrim("                   CTH_YITCUS,                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                   SUBSTRING(CTH_YCRIT, 1, 3)),                                                                                                           ") + xrEnter
	xKer007 += Alltrim("      TAB_C                                                                                                                                               ") + xrEnter
	xKer007 += Alltrim("      AS (SELECT PERIODO,                                                                                                                                 ") + xrEnter
	xKer007 += Alltrim("                 APL,                                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                 CTA,                                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                 DESC01,                                                                                                                                  ") + xrEnter
	xKer007 += Alltrim("                 AGRUP,                                                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                 ITCUS,                                                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                 Z29_TIPO,                                                                                                                                ") + xrEnter
	xKer007 += Alltrim("                 CLVL,                                                                                                                                    ") + xrEnter
	xKer007 += Alltrim("                 CRIT,                                                                                                                                    ") + xrEnter
	xKer007 += Alltrim("                 VALOR,                                                                                                                                   ") + xrEnter
	xKer007 += Alltrim("                 MODS = CASE                                                                                                                              ") + xrEnter
	xKer007 += Alltrim("                            WHEN RTRIM(APL) = 'GA'                                                                                                        ") + xrEnter
	xKer007 += Alltrim("                            THEN 'DIRETA'                                                                                                                 ") + xrEnter
	xKer007 += Alltrim("                            WHEN CTA IN('61103001')                                                                                                       ") + xrEnter
	xKer007 += Alltrim("                                 AND RTRIM(CLVL) IN('3103')                                                                                               ") + xrEnter
	xKer007 += Alltrim("                            THEN 'MOD1ATM'                                                                                                                ") + xrEnter
	xKer007 += Alltrim("                            WHEN CTA IN('61103001')                                                                                                       ") + xrEnter
	xKer007 += Alltrim("                                 AND RTRIM(CLVL) IN('3203')                                                                                               ") + xrEnter
	xKer007 += Alltrim("                            THEN 'MOD2PM2'                                                                                                                ") + xrEnter
	xKer007 += Alltrim("                            WHEN CTA IN('61103001')                                                                                                       ") + xrEnter
	xKer007 += Alltrim("                                 AND RTRIM(CLVL) IN('3703')                                                                                               ") + xrEnter
	xKer007 += Alltrim("                            THEN 'MOD7PM3'                                                                                                                ") + xrEnter
	xKer007 += Alltrim("                            WHEN SUBSTRING(CLVL, 2, 1) = '8'                                                                                              ") + xrEnter
	xKer007 += Alltrim("                                 AND Z29_TIPO = 'CV' AND Z29_COD_IT = '004'                                                                               ") + xrEnter
	xKer007 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + 'E' + RTRIM(CLVL) + SPACE(7)                                                             ") + xrEnter
	xKer007 += Alltrim("                            WHEN SUBSTRING(CLVL, 2, 1) = '8'                                                                                              ") + xrEnter
	xKer007 += Alltrim("                                 AND Z29_TIPO = 'CV' AND Z29_COD_IT <> '004'                                                                              ") + xrEnter
	xKer007 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + 'V' + RTRIM(CLVL) + SPACE(7)                                                             ") + xrEnter
	xKer007 += Alltrim("                            WHEN SUBSTRING(CLVL, 2, 1) = '8'                                                                                              ") + xrEnter
	xKer007 += Alltrim("                                 AND Z29_TIPO = 'CF'                                                                                                      ") + xrEnter
	xKer007 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + 'F' + RTRIM(CLVL) + RTRIM(SUBSTRING(AGRUP, 1, 6))                                        ") + xrEnter
	xKer007 += Alltrim("                            WHEN RTRIM(CLVL) IN('6112', '6208')                                                                                           ") + xrEnter
	xKer007 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + SUBSTRING(CRIT, 1, 3) + SPACE(7)                                                         ") + xrEnter
	xKer007 += Alltrim("                            WHEN CTA IN('61601022')                                                                                                       ") + xrEnter
	xKer007 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + RTRIM(SUBSTRING(AGRUP, 1, 10)) + SUBSTRING(CRIT, 1, 3)                                   ") + xrEnter
	xKer007 += Alltrim("                            WHEN RTRIM(CLVL) IN('3180', '3181', '3183', '3184', '3280')                                                                   ") + xrEnter
	xKer007 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + SUBSTRING(CRIT, 1, 3)                                                                    ") + xrEnter
	xKer007 += Alltrim("                            WHEN RTRIM(CLVL) IN('3299') AND PERIODO <= '202109'                                                                           ") + xrEnter
	xKer007 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + SUBSTRING(CRIT, 1, 3)                                                                    ") + xrEnter
	xKer007 += Alltrim("                            WHEN RTRIM(SUBSTRING(AGRUP, 1, 10)) IN('612', '613', '614')                                                                   ") + xrEnter
	xKer007 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + RTRIM(SUBSTRING(AGRUP, 1, 10)) + SUBSTRING(CRIT, 1, 3)                                   ") + xrEnter
	xKer007 += Alltrim("                            WHEN RTRIM(SUBSTRING(AGRUP, 1, 10)) IN('615', '617')                                                                          ") + xrEnter
	xKer007 += Alltrim("                            THEN 'MOD' + '0' + RTRIM(SUBSTRING(AGRUP, 1, 10))                                                                             ") + xrEnter
	xKer007 += Alltrim("                            ELSE 'MOD' + SUBSTRING(CLVL, 2, 1) + RTRIM(SUBSTRING(AGRUP, 1, 10))                                                           ") + xrEnter
	xKer007 += Alltrim("                        END,                                                                                                                              ") + xrEnter
	xKer007 += Alltrim("                 CONTRAP = CASE                                                                                                                           ") + xrEnter
	xKer007 += Alltrim("                               WHEN RTRIM(CLVL) IN('3801')                                                                                                ") + xrEnter
	xKer007 += Alltrim("                               THEN 'MP'                                                                                                                  ") + xrEnter
	xKer007 += Alltrim("                               WHEN RTRIM(CLVL) IN('3802', '3803')                                                                                        ") + xrEnter
	xKer007 += Alltrim("                               THEN 'PI'                                                                                                                  ") + xrEnter
	xKer007 += Alltrim("                               WHEN RTRIM(CLVL) IN('3804', '3805')                                                                                        ") + xrEnter
	xKer007 += Alltrim("                               THEN 'PA'                                                                                                                  ") + xrEnter
	xKer007 += Alltrim("                               WHEN RTRIM(SUBSTRING(AGRUP, 1, 10)) NOT IN('615', '616', '617')                                                            ") + xrEnter
	xKer007 += Alltrim("                                    AND SUBSTRING(CRIT, 1, 3) IN('E03', 'E04', 'R01', 'R02', 'R09', 'E6A', 'E6B')                                         ") + xrEnter
	xKer007 += Alltrim("                               THEN 'PA'                                                                                                                  ") + xrEnter
	xKer007 += Alltrim("                               WHEN SUBSTRING(CTA, 1, 5) IN('61104', '61110')                                                                             ") + xrEnter
	xKer007 += Alltrim("                               THEN 'PA'                                                                                                                  ") + xrEnter
	xKer007 += Alltrim("                               WHEN RTRIM(CLVL) IN('3500', '3501', '3502', '6500')                                                                        ") + xrEnter
	xKer007 += Alltrim("                               THEN 'PA'                                                                                                                  ") + xrEnter
	xKer007 += Alltrim("                               ELSE 'PP'                                                                                                                  ") + xrEnter
	xKer007 += Alltrim("                           END                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("          FROM TAB_B B                                                                                                                                    ") + xrEnter
	xKer007 += Alltrim("                LEFT JOIN " + RetSqlName("Z29") + " Z29 (NOLOCK) ON Z29_COD_IT = B.ITCUS                                                                  ") + xrEnter
	xKer007 += Alltrim("                                        AND Z29.D_E_L_E_T_ = ' '),                                                                                        ") + xrEnter
	xKer007 += Alltrim("      TABFINAL                                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("      AS (SELECT C.*,                                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                 ISNULL(SUBSTRING(B1_DESC, 1, 50), ' ') DESCR,                                                                                            ") + xrEnter
	xKer007 += Alltrim("                 ISNULL(B1_YREGRAC, ' ') REGRAC,                                                                                                          ") + xrEnter
	xKer007 += Alltrim("                 CASE                                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                     WHEN B1_YREGRAC = '1'                                                                                                                ") + xrEnter
	xKer007 += Alltrim("                     THEN 'CAP. PRODUTIVA'                                                                                                                ") + xrEnter
	xKer007 += Alltrim("                     WHEN B1_YREGRAC = '2'                                                                                                                ") + xrEnter
	xKer007 += Alltrim("                     THEN 'PESO SECO'                                                                                                                     ") + xrEnter
	xKer007 += Alltrim("                     WHEN B1_YREGRAC = '3'                                                                                                                ") + xrEnter
	xKer007 += Alltrim("                     THEN 'M2'                                                                                                                            ") + xrEnter
	xKer007 += Alltrim("                     ELSE 'INDEFINIDO'                                                                                                                    ") + xrEnter
	xKer007 += Alltrim("                 END RATEIO                                                                                                                               ") + xrEnter
	xKer007 += Alltrim("          FROM TAB_C C                                                                                                                                    ") + xrEnter
	xKer007 += Alltrim("               LEFT JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "'                                                    ") + xrEnter
	xKer007 += Alltrim("                                               AND B1_COD = MODS                                                                                          ") + xrEnter
	xKer007 += Alltrim("                                               AND SB1.D_E_L_E_T_ = ' ')                                                                                  ") + xrEnter

Return ( xKer007 )

User Function B185CHKF(MV_PAR01, MV_PAR02, MV_PAR03)

	Local xrEnter   := CHR(13) + CHR(10)
	Local xChk003 

	xRfBscEst := ""
	If MV_PAR03 == "PA"
		xRfBscEst := "Z18_NSQSD3"
	ElseIf MV_PAR03 == "PP"
		xRfBscEst := "Z18_SQD3PP"
	EndIf

	xValidCt := 0
	xChk003 := Alltrim(" SELECT 'AJT' REFER,                                                                                                        ") + xrEnter
	xChk003 += Alltrim("        ISNULL(SUM(CUSTO), 0) CUSTO                                                                                         ") + xrEnter
	xChk003 += Alltrim("   FROM (SELECT CASE                                                                                                        ") + xrEnter
	xChk003 += Alltrim("                  WHEN D3_TM > '500' THEN SUM(D3_CUSTO1)                                                                    ") + xrEnter
	xChk003 += Alltrim("                  ELSE SUM(D3_CUSTO1) * (-1)                                                                                ") + xrEnter
	xChk003 += Alltrim("                END CUSTO                                                                                                   ") + xrEnter
	xChk003 += Alltrim("          FROM " + RetSqlName("SD3") + " SD3 (NOLOCK)                                                                       ") + xrEnter
	xChk003 += Alltrim("         WHERE D3_FILIAL = '" + xFilial("SD3") + "'                                                                         ") + xrEnter
	xChk003 += Alltrim("           AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'                                     ") + xrEnter
	xChk003 += Alltrim("           AND D3_TM IN('350','850')                                                                                        ") + xrEnter
	xChk003 += Alltrim("           AND D3_TIPO = '" + MV_PAR03 + "'                                                                                 ") + xrEnter
	xChk003 += Alltrim("           AND D_E_L_E_T_ = ' '                                                                                             ") + xrEnter
	xChk003 += Alltrim("         GROUP BY D3_TM) AS ARRED                                                                                           ") + xrEnter
	If !Empty(xRfBscEst)
		xChk003 += Alltrim("  UNION ALL                                                                                                                 ") + xrEnter
		xChk003 += Alltrim(" SELECT 'EST' REFER,                                                                                                        ") + xrEnter
		xChk003 += Alltrim("        SUM(D3_CUSTO1) CUSTO                                                                                                ") + xrEnter
		xChk003 += Alltrim("   FROM " + RetSqlName("SD3") + " SD3 (NOLOCK)                                                                              ") + xrEnter
		xChk003 += Alltrim("  WHERE D3_FILIAL = '" + xFilial("SD3") + "'                                                                                ") + xrEnter
		xChk003 += Alltrim("    AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'                                            ") + xrEnter
		xChk003 += Alltrim("    AND D3_TM = '211'                                                                                                       ") + xrEnter
		xChk003 += Alltrim("    AND D3_TIPO NOT IN('PP','PA','PS')                                                                                      ") + xrEnter
		xChk003 += Alltrim("    AND D3_YRFCUST IN(SELECT " + xRfBscEst + "                                                                              ") + xrEnter
		xChk003 += Alltrim("                        FROM " + RetSqlName("Z18") + " Z18 (NOLOCK)                                                         ") + xrEnter
		xChk003 += Alltrim("                       WHERE Z18_FILIAL = '" + xFilial("Z18") + "'                                                          ") + xrEnter
		xChk003 += Alltrim("                         AND Z18_DATA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'                         ") + xrEnter
		xChk003 += Alltrim("                         AND Z18_TM = 'EST'                                                                                 ") + xrEnter
		xChk003 += Alltrim("                         AND " + xRfBscEst + " <> '      '                                                                  ") + xrEnter
		xChk003 += Alltrim("                         AND Z18.D_E_L_E_T_ = ' ')                                                                          ") + xrEnter
		xChk003 += Alltrim("    AND D_E_L_E_T_ = ' '                                                                                                    ") + xrEnter
	EndIf
	xChk003 += Alltrim("  UNION ALL                                                                                                                 ") + xrEnter
	xChk003 += Alltrim(" SELECT 'CTB' REFER, SUM(CUSTO)                                                                                             ") + xrEnter
	xChk003 += Alltrim("   FROM (SELECT 'ESTOQUE' TIPO, SUM(D3_CUSTO1)*(-1) CUSTO                                                                   ") + xrEnter
	xChk003 += Alltrim("           FROM " + RetSqlName("SD3") + " SD3 (NOLOCK)                                                                      ") + xrEnter
	xChk003 += Alltrim("          INNER JOIN " + RetSqlName("SC2") + " SC2 (NOLOCK) ON C2_FILIAL = '" + xFilial("SC2") + "'                         ") + xrEnter
	xChk003 += Alltrim("                               AND C2_NUM = SUBSTRING(D3_OP,1,6)                                                            ") + xrEnter
	xChk003 += Alltrim("                               AND C2_ITEM = SUBSTRING(D3_OP,7,2)                                                           ") + xrEnter
	xChk003 += Alltrim("                               AND C2_SEQUEN = SUBSTRING(D3_OP,9,3)                                                         ") + xrEnter
	xChk003 += Alltrim("                               AND SC2.D_E_L_E_T_ = ' '                                                                     ") + xrEnter
	xChk003 += Alltrim("          INNER JOIN " + RetSqlName("SB1") + " SB1 (NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "'                         ") + xrEnter
	xChk003 += Alltrim("                               AND B1_COD = C2_PRODUTO                                                                      ") + xrEnter
	xChk003 += Alltrim("                               AND B1_TIPO = '" + MV_PAR03 + "'                                                             ") + xrEnter
	xChk003 += Alltrim("                               AND SB1.D_E_L_E_T_ = ' '                                                                     ") + xrEnter
	xChk003 += Alltrim("          WHERE D3_FILIAL = '" + xFilial("SD3") + "'                                                                        ") + xrEnter
	xChk003 += Alltrim("            AND D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'                                    ") + xrEnter
	xChk003 += Alltrim("            AND D3_OP <> '             '                                                                                    ") + xrEnter
	xChk003 += Alltrim("            AND D3_TM <> '010'                                                                                              ") + xrEnter
	If cEmpAnt == "01"
		If MV_PAR03 == "PA"
			xChk003 += Alltrim("            AND D3_TIPO NOT IN('PP', 'PA')                                                                                   ") + xrEnter
		EndIf
	ElseIf cEmpAnt == "06"
		If MV_PAR03 == "PI"
			xChk003 += Alltrim("            AND D3_TIPO NOT IN('MP', 'PI')                                                                                        ") + xrEnter
		ElseIf MV_PAR03 == "PA"
			xChk003 += Alltrim("            AND D3_TIPO NOT IN('MP', 'PI')                                                                                   ") + xrEnter
		EndIf
	EndIf
	xChk003 += Alltrim("            AND SD3.D_E_L_E_T_ = ' '                                                                                        ") + xrEnter
	xChk003 += Alltrim("          UNION ALL                                                                                                         ") + xrEnter
	xChk003 += Alltrim("         SELECT 'CONTABI' TIPO, SUM(VALOR) CUSTO                                                                            ") + xrEnter
	xChk003 += Alltrim("           FROM " + msNomeTMP + "                                                                                           ") + xrEnter
	xChk003 += Alltrim("          WHERE CONTRAP = '"+MV_PAR03+"' ) AS TBRESUMID                                                                     ") + xrEnter

Return ( xChk003 )

User Function B185AJST(deData, atData, msVersao, msRevisa, msAnoRef)

	Local xrEnter   := CHR(13) + CHR(10)
	Local xKer009

	xKer009 := Alltrim(" WITH TAB_A                                                                                                                                  ") + xrEnter
	xKer009 += Alltrim("      AS (SELECT APL = 'GNA',                                                                                                                ") + xrEnter
	xKer009 += Alltrim("                 QUADRO = 'LT_8840_DEB',                                                                                                     ") + xrEnter
	xKer009 += Alltrim("                 CTA = ZBZ_DEBITO,                                                                                                           ") + xrEnter
	xKer009 += Alltrim("                 CLVL = ZBZ_CLVLDB,                                                                                                          ") + xrEnter
	xKer009 += Alltrim("                 PERIODO = LEFT(ZBZ_DATA, 6),                                                                                                ") + xrEnter
	xKer009 += Alltrim("                 VALOR = SUM(ZBZ_VALOR)                                                                                                      ") + xrEnter
	xKer009 += Alltrim("          FROM " + RetSqlName("ZBZ") + "(NOLOCK)                                                                                             ") + xrEnter
	xKer009 += Alltrim("          WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "'                                                                                        ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_VERSAO = '" + msVersao + "'                                                                                          ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_REVISA = '" + msRevisa + "'                                                                                          ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_ANOREF = " + msAnoRef + "                                                                                            ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_DATA BETWEEN '" + dtos(deData) + "' AND '" + dtos(atData) + "'                                                       ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_LOTE = '008840'                                                                                                      ") + xrEnter
	xKer009 += Alltrim("                AND SUBSTRING(ZBZ_DEBITO, 1, 1) = '6'                                                                                        ") + xrEnter
	xKer009 += Alltrim("                AND SUBSTRING(ZBZ_DEBITO, 1, 2) <> '62'                                                                                      ") + xrEnter
	xKer009 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                         ") + xrEnter
	xKer009 += Alltrim("          GROUP BY ZBZ_DEBITO,                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                   ZBZ_CLVLDB,                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                   LEFT(ZBZ_DATA, 6)                                                                                                         ") + xrEnter
	xKer009 += Alltrim("          UNION ALL                                                                                                                          ") + xrEnter
	xKer009 += Alltrim("          SELECT APL = 'GNA',                                                                                                                ") + xrEnter
	xKer009 += Alltrim("                 QUADRO = 'LT_8840_CRD',                                                                                                     ") + xrEnter
	xKer009 += Alltrim("                 CTA = ZBZ_CREDIT,                                                                                                           ") + xrEnter
	xKer009 += Alltrim("                 CLVL = ZBZ_CLVLCR,                                                                                                          ") + xrEnter
	xKer009 += Alltrim("                 PERIODO = LEFT(ZBZ_DATA, 6),                                                                                                ") + xrEnter
	xKer009 += Alltrim("                 VALOR = SUM(ZBZ_VALOR) * (-1)                                                                                               ") + xrEnter
	xKer009 += Alltrim("          FROM " + RetSqlName("ZBZ") + "(NOLOCK)                                                                                             ") + xrEnter
	xKer009 += Alltrim("          WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "'                                                                                        ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_VERSAO = '" + msVersao + "'                                                                                          ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_REVISA = '" + msRevisa + "'                                                                                          ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_ANOREF = " + msAnoRef + "                                                                                            ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_DATA BETWEEN '" + dtos(deData) + "' AND '" + dtos(atData) + "'                                                       ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_LOTE = '008840'                                                                                                      ") + xrEnter
	xKer009 += Alltrim("                AND SUBSTRING(ZBZ_CREDIT, 1, 1) = '6'                                                                                        ") + xrEnter
	xKer009 += Alltrim("                AND SUBSTRING(ZBZ_CREDIT, 1, 2) <> '62'                                                                                      ") + xrEnter
	xKer009 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                         ") + xrEnter
	xKer009 += Alltrim("          GROUP BY ZBZ_CREDIT,                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                   ZBZ_CLVLCR,                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                   LEFT(ZBZ_DATA, 6)                                                                                                         ") + xrEnter
	xKer009 += Alltrim("          UNION ALL                                                                                                                          ") + xrEnter
	xKer009 += Alltrim("          SELECT APL = 'GNA',                                                                                                                ") + xrEnter
	xKer009 += Alltrim("                 QUADRO = 'LT_OUTR_DEB',                                                                                                     ") + xrEnter
	xKer009 += Alltrim("                 CTA = ZBZ_DEBITO,                                                                                                           ") + xrEnter
	xKer009 += Alltrim("                 CLVL = ZBZ_CLVLDB,                                                                                                          ") + xrEnter
	xKer009 += Alltrim("                 PERIODO = LEFT(ZBZ_DATA, 6),                                                                                                ") + xrEnter
	xKer009 += Alltrim("                 VALOR = SUM(ZBZ_VALOR)                                                                                                      ") + xrEnter
	xKer009 += Alltrim("          FROM " + RetSqlName("ZBZ") + "(NOLOCK)                                                                                             ") + xrEnter
	xKer009 += Alltrim("          WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "'                                                                                        ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_VERSAO = '" + msVersao + "'                                                                                          ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_REVISA = '" + msRevisa + "'                                                                                          ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_ANOREF = " + msAnoRef + "                                                                                            ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_DATA BETWEEN '" + dtos(deData) + "' AND '" + dtos(atData) + "'                                                       ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_LOTE <> '008840'                                                                                                     ") + xrEnter
	xKer009 += Alltrim("                AND SUBSTRING(ZBZ_DEBITO, 1, 1) = '6'                                                                                        ") + xrEnter
	xKer009 += Alltrim("                AND SUBSTRING(ZBZ_DEBITO, 1, 2) <> '62'                                                                                      ") + xrEnter
	xKer009 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                         ") + xrEnter
	xKer009 += Alltrim("          GROUP BY ZBZ_DEBITO,                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                   ZBZ_CLVLDB,                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                   LEFT(ZBZ_DATA, 6)                                                                                                         ") + xrEnter
	xKer009 += Alltrim("          UNION ALL                                                                                                                          ") + xrEnter
	xKer009 += Alltrim("          SELECT APL = 'GNA',                                                                                                                ") + xrEnter
	xKer009 += Alltrim("                 QUADRO = 'LT_8840_CRD',                                                                                                     ") + xrEnter
	xKer009 += Alltrim("                 CTA = ZBZ_CREDIT,                                                                                                           ") + xrEnter
	xKer009 += Alltrim("                 CLVL = ZBZ_CLVLCR,                                                                                                          ") + xrEnter
	xKer009 += Alltrim("                 PERIODO = LEFT(ZBZ_DATA, 6),                                                                                                ") + xrEnter
	xKer009 += Alltrim("                 VALOR = SUM(ZBZ_VALOR) * (-1)                                                                                               ") + xrEnter
	xKer009 += Alltrim("          FROM " + RetSqlName("ZBZ") + "(NOLOCK)                                                                                             ") + xrEnter
	xKer009 += Alltrim("          WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "'                                                                                        ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_VERSAO = '" + msVersao + "'                                                                                          ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_REVISA = '" + msRevisa + "'                                                                                          ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_ANOREF = " + msAnoRef + "                                                                                            ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_DATA BETWEEN '" + dtos(deData) + "' AND '" + dtos(atData) + "'                                                       ") + xrEnter
	xKer009 += Alltrim("                AND ZBZ_LOTE <> '008840'                                                                                                     ") + xrEnter
	xKer009 += Alltrim("                AND SUBSTRING(ZBZ_CREDIT, 1, 1) = '6'                                                                                        ") + xrEnter
	xKer009 += Alltrim("                AND SUBSTRING(ZBZ_CREDIT, 1, 2) <> '62'                                                                                      ") + xrEnter
	xKer009 += Alltrim("                AND D_E_L_E_T_ = ' '                                                                                                         ") + xrEnter
	xKer009 += Alltrim("          GROUP BY ZBZ_CREDIT,                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                   ZBZ_CLVLCR,                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                   LEFT(ZBZ_DATA, 6)),                                                                                                       ") + xrEnter
	xKer009 += Alltrim("      TAB_A_ACUM                                                                                                                             ") + xrEnter
	xKer009 += Alltrim("      AS (SELECT PERIODO,                                                                                                                    ") + xrEnter
	xKer009 += Alltrim("                 APL,                                                                                                                        ") + xrEnter
	xKer009 += Alltrim("                 CTA,                                                                                                                        ") + xrEnter
	xKer009 += Alltrim("                 CLVL,                                                                                                                       ") + xrEnter
	xKer009 += Alltrim("                 VALOR = ROUND(SUM(VALOR), 2)                                                                                                ") + xrEnter
	xKer009 += Alltrim("          FROM TAB_A                                                                                                                         ") + xrEnter
	xKer009 += Alltrim("          GROUP BY PERIODO,                                                                                                                  ") + xrEnter
	xKer009 += Alltrim("                   APL,                                                                                                                      ") + xrEnter
	xKer009 += Alltrim("                   CTA,                                                                                                                      ") + xrEnter
	xKer009 += Alltrim("                   CLVL                                                                                                                      ") + xrEnter
	xKer009 += Alltrim("          HAVING ROUND(SUM(VALOR), 2) <> 0),                                                                                                 ") + xrEnter
	xKer009 += Alltrim("      TAB_B                                                                                                                                  ") + xrEnter
	xKer009 += Alltrim("      AS (SELECT PERIODO,                                                                                                                    ") + xrEnter
	xKer009 += Alltrim("                 APL,                                                                                                                        ") + xrEnter
	xKer009 += Alltrim("                 CTA,                                                                                                                        ") + xrEnter
	xKer009 += Alltrim("                 DESC01 = CT1_DESC01,                                                                                                        ") + xrEnter
	xKer009 += Alltrim("                 AGRUP = SUBSTRING(CT1_YAGRUP, 1, 10),                                                                                       ") + xrEnter
	xKer009 += Alltrim("                 ITCUS = CASE                                                                                                                ") + xrEnter
	xKer009 += Alltrim("                             WHEN SUBSTRING(CTH_YCRIT, 1, 3) = 'MOP'                                                                         ") + xrEnter
	xKer009 += Alltrim("                             THEN '146'                                                                                                      ") + xrEnter
	xKer009 += Alltrim("                             WHEN RTRIM(CLVL) IN('3180', '3181', '3183', '3184', '3280')                                                     ") + xrEnter
	xKer009 += Alltrim("                             THEN CTH_YITCUS                                                                                                 ") + xrEnter
	xKer009 += Alltrim("                             WHEN CTA IN('61103001')                                                                                         ") + xrEnter
	xKer009 += Alltrim("                                  AND RTRIM(CLVL) IN('3103')                                                                                 ") + xrEnter
	xKer009 += Alltrim("                             THEN '026'                                                                                                      ") + xrEnter
	xKer009 += Alltrim("                             ELSE CT1_YITCUS                                                                                                 ") + xrEnter
	xKer009 += Alltrim("                         END,                                                                                                                ") + xrEnter
	xKer009 += Alltrim("                 CLVL,                                                                                                                       ") + xrEnter
	xKer009 += Alltrim("                 AGGRAT = CASE                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                              WHEN((RTRIM(SUBSTRING(CTA, 1, 3)) IN('615', '617'))                                                            ") + xrEnter
	xKer009 += Alltrim("                                   OR (RTRIM(SUBSTRING(CTA, 1, 3)) IN('616')                                                                 ") + xrEnter
	xKer009 += Alltrim("                                       AND RTRIM(CTA) NOT IN('61601022')                                                                     ") + xrEnter
	xKer009 += Alltrim("                                       AND SUBSTRING(CTH_YCRIT, 1, 1) <> 'L'))                                                               ") + xrEnter
	xKer009 += Alltrim("                              THEN CASE                                                                                                      ") + xrEnter
	xKer009 += Alltrim("                                       WHEN RTRIM(SUBSTRING(CTA, 1, 3)) IN('615', '617')                                                     ") + xrEnter
	xKer009 += Alltrim("                                       THEN 'AC00'                                                                                           ") + xrEnter
	xKer009 += Alltrim("                                       WHEN CLVL = '3141'                                                                                    ") + xrEnter
	xKer009 += Alltrim("                                       THEN 'AC00'                                                                                           ") + xrEnter
	xKer009 += Alltrim("                                       WHEN SUBSTRING(CLVL, 2, 1) = '1'                                                                      ") + xrEnter
	xKer009 += Alltrim("                                       THEN 'AC01'                                                                                           ") + xrEnter
	xKer009 += Alltrim("                                       WHEN SUBSTRING(CLVL, 2, 1) = '2'                                                                      ") + xrEnter
	xKer009 += Alltrim("                                       THEN 'AC05'                                                                                           ") + xrEnter
	xKer009 += Alltrim("                                       ELSE 'AC00'                                                                                           ") + xrEnter
	xKer009 += Alltrim("                                   END                                                                                                       ") + xrEnter
	xKer009 += Alltrim("                              ELSE SUBSTRING(ZF2_AGGRAT, 1, 4)                                                                               ") + xrEnter
	xKer009 += Alltrim("                          END,                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                 CRIT = SUBSTRING(CTH_YCRIT, 1, 3),                                                                                          ") + xrEnter
	xKer009 += Alltrim("                 VALOR = SUM(VALOR)                                                                                                          ") + xrEnter
	xKer009 += Alltrim("          FROM TAB_A_ACUM AS TAB                                                                                                             ") + xrEnter
	xKer009 += Alltrim("               INNER JOIN " + RetSqlName("CT1") + " CT1(NOLOCK) ON CT1_FILIAL = '" + xFilial("CT1") + "'                                     ") + xrEnter
	xKer009 += Alltrim("                                                AND CT1_CONTA = CTA                                                                          ") + xrEnter
	xKer009 += Alltrim("                                                AND CT1.D_E_L_E_T_ = ' '                                                                     ") + xrEnter
	xKer009 += Alltrim("               INNER JOIN " + RetSqlName("CTH") + " CTH(NOLOCK) ON CTH_FILIAL = '" + xFilial("CTH") + "'                                     ") + xrEnter
	xKer009 += Alltrim("                                                AND CTH_CLVL = CLVL                                                                          ") + xrEnter
	xKer009 += Alltrim("                                                AND CTH_YAPLCT = 'S'                                                                         ") + xrEnter
	xKer009 += Alltrim("                                                AND CTH.D_E_L_E_T_ = ' '                                                                     ") + xrEnter
	xKer009 += Alltrim("               LEFT JOIN " + RetSqlName("ZF2") + " ZF2(NOLOCK) ON ZF2_FILIAL = '" + xFilial("ZF2") + "'                                      ") + xrEnter
	xKer009 += Alltrim("                                               AND ZF2_CODIGO = CTH_YAGRAT                                                                   ") + xrEnter
	xKer009 += Alltrim("                                               AND ZF2.D_E_L_E_T_ = ' '                                                                      ") + xrEnter
	xKer009 += Alltrim("          GROUP BY PERIODO,                                                                                                                  ") + xrEnter
	xKer009 += Alltrim("                   APL,                                                                                                                      ") + xrEnter
	xKer009 += Alltrim("                   CTA,                                                                                                                      ") + xrEnter
	xKer009 += Alltrim("                   CT1_DESC01,                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                   CT1_YITCUS,                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                   SUBSTRING(CT1_YAGRUP, 1, 10),                                                                                             ") + xrEnter
	xKer009 += Alltrim("                   CLVL,                                                                                                                     ") + xrEnter
	xKer009 += Alltrim("                   SUBSTRING(ZF2_AGGRAT, 1, 4),                                                                                              ") + xrEnter
	xKer009 += Alltrim("                   CTH_YITCUS,                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                   SUBSTRING(CTH_YCRIT, 1, 3),                                                                                               ") + xrEnter
	xKer009 += Alltrim("                   SUBSTRING(CTH_YCRIT, 1, 1)),                                                                                              ") + xrEnter
	xKer009 += Alltrim("      TAB_C                                                                                                                                  ") + xrEnter
	xKer009 += Alltrim("      AS (SELECT PERIODO,                                                                                                                    ") + xrEnter
	xKer009 += Alltrim("                 APL,                                                                                                                        ") + xrEnter
	xKer009 += Alltrim("                 CTA,                                                                                                                        ") + xrEnter
	xKer009 += Alltrim("                 DESC01,                                                                                                                     ") + xrEnter
	xKer009 += Alltrim("                 AGRUP,                                                                                                                      ") + xrEnter
	xKer009 += Alltrim("                 ITCUS,                                                                                                                      ") + xrEnter
	xKer009 += Alltrim("                 Z29_TIPO,                                                                                                                   ") + xrEnter
	xKer009 += Alltrim("                 CLVL,                                                                                                                       ") + xrEnter
	xKer009 += Alltrim("                 AGGRAT = CASE                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                              WHEN ITCUS IN('033')                                                                                           ") + xrEnter
	xKer009 += Alltrim("                                   AND RTRIM(AGGRAT) + '-' + RTRIM(CRIT) IN('E3-E03', 'E4-E04')                                              ") + xrEnter
	xKer009 += Alltrim("                              THEN 'AC01'                                                                                                    ") + xrEnter
	xKer009 += Alltrim("                              WHEN ITCUS IN('033')                                                                                           ") + xrEnter
	xKer009 += Alltrim("                                   AND RTRIM(AGGRAT) + '-' + RTRIM(CRIT) IN('L1L2-L01', 'L3-L03')                                            ") + xrEnter
	xKer009 += Alltrim("                              THEN 'AC01'                                                                                                    ") + xrEnter
	xKer009 += Alltrim("                              WHEN ITCUS IN('130')                                                                                           ") + xrEnter
	xKer009 += Alltrim("                                   AND CRIT IN('E03', 'E04')                                                                                 ") + xrEnter
	xKer009 += Alltrim("                              THEN SUBSTRING(CRIT, 1, 1) + SUBSTRING(CRIT, 3, 1)                                                             ") + xrEnter
	xKer009 += Alltrim("                              ELSE AGGRAT                                                                                                    ") + xrEnter
	xKer009 += Alltrim("                          END,                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                 CRIT = CASE                                                                                                                 ") + xrEnter
	xKer009 += Alltrim("                            WHEN ITCUS IN('033')                                                                                             ") + xrEnter
	xKer009 += Alltrim("                                 AND RTRIM(AGGRAT) + '-' + RTRIM(CRIT) IN('E3-E03', 'E4-E04')                                                ") + xrEnter
	xKer009 += Alltrim("                            THEN 'TOT'                                                                                                       ") + xrEnter
	xKer009 += Alltrim("                            WHEN ITCUS IN('033')                                                                                             ") + xrEnter
	xKer009 += Alltrim("                                 AND RTRIM(AGGRAT) + '-' + RTRIM(CRIT) IN('L1L2-L01', 'L3-L03')                                              ") + xrEnter
	xKer009 += Alltrim("                            THEN 'TOT'                                                                                                       ") + xrEnter
	xKer009 += Alltrim("                            ELSE CRIT                                                                                                        ") + xrEnter
	xKer009 += Alltrim("                        END,                                                                                                                 ") + xrEnter
	xKer009 += Alltrim("                 VALOR,                                                                                                                      ") + xrEnter
	xKer009 += Alltrim("                 MODS = CASE                                                                                                                 ") + xrEnter
	xKer009 += Alltrim("                            WHEN RTRIM(APL) = 'GA'                                                                                           ") + xrEnter
	xKer009 += Alltrim("                            THEN 'DIRETA'                                                                                                    ") + xrEnter
	xKer009 += Alltrim("                            WHEN CTA IN('61103001')                                                                                          ") + xrEnter
	xKer009 += Alltrim("                                 AND RTRIM(CLVL) IN('3103')                                                                                  ") + xrEnter
	xKer009 += Alltrim("                            THEN 'MOD1ATM'                                                                                                   ") + xrEnter
	xKer009 += Alltrim("                            WHEN SUBSTRING(CLVL, 2, 1) = '8'                                                                                 ") + xrEnter
	xKer009 += Alltrim("                                 AND Z29_TIPO = 'CV'                                                                                         ") + xrEnter
	xKer009 += Alltrim("                                 AND Z29_COD_IT = '004'                                                                                      ") + xrEnter
	xKer009 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + 'E' + RTRIM(CLVL) + SPACE(7)                                                ") + xrEnter
	xKer009 += Alltrim("                            WHEN SUBSTRING(CLVL, 2, 1) = '8'                                                                                 ") + xrEnter
	xKer009 += Alltrim("                                 AND Z29_TIPO = 'CV'                                                                                         ") + xrEnter
	xKer009 += Alltrim("                                 AND Z29_COD_IT <> '004'                                                                                     ") + xrEnter
	xKer009 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + 'V' + RTRIM(CLVL) + SPACE(7)                                                ") + xrEnter
	xKer009 += Alltrim("                            WHEN SUBSTRING(CLVL, 2, 1) = '8'                                                                                 ") + xrEnter
	xKer009 += Alltrim("                                 AND Z29_TIPO = 'CF'                                                                                         ") + xrEnter
	xKer009 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + 'F' + RTRIM(CLVL) + RTRIM(SUBSTRING(AGRUP, 1, 6))                           ") + xrEnter
	xKer009 += Alltrim("                            WHEN RTRIM(CLVL) IN('6112', '6208')                                                                              ") + xrEnter
	xKer009 += Alltrim("                                 AND NOT RTRIM(SUBSTRING(AGRUP, 1, 10)) IN('615', '617')                                                     ") + xrEnter
	xKer009 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + SUBSTRING(CRIT, 1, 3) + SPACE(7)                                            ") + xrEnter
	xKer009 += Alltrim("                            WHEN CTA IN('61601022')                                                                                          ") + xrEnter
	xKer009 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + RTRIM(SUBSTRING(AGRUP, 1, 10)) + SUBSTRING(CRIT, 1, 3)                      ") + xrEnter
	xKer009 += Alltrim("                            WHEN RTRIM(CLVL) IN('3180', '3181', '3183', '3184', '3280')                                                      ") + xrEnter
	xKer009 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + SUBSTRING(CRIT, 1, 3)                                                       ") + xrEnter
	xKer009 += Alltrim("                            WHEN RTRIM(CLVL) IN('3299')                                                                                      ") + xrEnter
	xKer009 += Alltrim("                                 AND PERIODO <= '202109'                                                                                     ") + xrEnter
	xKer009 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + SUBSTRING(CRIT, 1, 3)                                                       ") + xrEnter
	xKer009 += Alltrim("                            WHEN RTRIM(SUBSTRING(AGRUP, 1, 10)) IN('612', '613', '614')                                                      ") + xrEnter
	xKer009 += Alltrim("                            THEN 'MOD' + SUBSTRING(CLVL, 2, 1) + RTRIM(SUBSTRING(AGRUP, 1, 10)) + SUBSTRING(CRIT, 1, 3)                      ") + xrEnter
	xKer009 += Alltrim("                            WHEN SUBSTRING(CLVL, 2, 1) = '3'                                                                                 ") + xrEnter
	xKer009 += Alltrim("                            THEN 'MOD' + '0' + RTRIM(SUBSTRING(AGRUP, 1, 10))                                                                ") + xrEnter
	xKer009 += Alltrim("                            WHEN RTRIM(SUBSTRING(AGRUP, 1, 10)) IN('615', '617')                                                             ") + xrEnter
	xKer009 += Alltrim("                            THEN 'MOD' + '0' + RTRIM(SUBSTRING(AGRUP, 1, 10))                                                                ") + xrEnter
	xKer009 += Alltrim("                            ELSE 'MOD' + SUBSTRING(CLVL, 2, 1) + RTRIM(SUBSTRING(AGRUP, 1, 10))                                              ") + xrEnter
	xKer009 += Alltrim("                        END,                                                                                                                 ") + xrEnter
	xKer009 += Alltrim("                 CONTRAP = CASE                                                                                                              ") + xrEnter
	xKer009 += Alltrim("                               WHEN RTRIM(CLVL) IN('3801')                                                                                   ") + xrEnter
	xKer009 += Alltrim("                               THEN 'MP'                                                                                                     ") + xrEnter
	xKer009 += Alltrim("                               WHEN RTRIM(CLVL) IN('3802', '3803')                                                                           ") + xrEnter
	xKer009 += Alltrim("                               THEN 'PI'                                                                                                     ") + xrEnter
	xKer009 += Alltrim("                               WHEN RTRIM(CLVL) IN('3804', '3805')                                                                           ") + xrEnter
	xKer009 += Alltrim("                               THEN 'PA'                                                                                                     ") + xrEnter
	xKer009 += Alltrim("                               WHEN((RTRIM(SUBSTRING(AGRUP, 1, 10)) NOT IN('615', '616', '617')                                              ") + xrEnter
	xKer009 += Alltrim("                                     AND SUBSTRING(CRIT, 1, 3) IN('E03', 'E04', 'R01', 'R02', 'R09', 'E6A', 'E6B')                           ") + xrEnter
	xKer009 += Alltrim("                                     AND B.ITCUS NOT IN('033'))                                                                              ") + xrEnter
	xKer009 += Alltrim("                                    OR (B.ITCUS IN('130')                                                                                    ") + xrEnter
	xKer009 += Alltrim("                                        AND SUBSTRING(CRIT, 1, 3) IN('E03', 'E04', 'R01', 'R02', 'R09', 'E6A', 'E6B')))                      ") + xrEnter
	xKer009 += Alltrim("                               THEN 'PA'                                                                                                     ") + xrEnter
	xKer009 += Alltrim("                               WHEN SUBSTRING(CTA, 1, 5) IN('61104', '61110')                                                                ") + xrEnter
	xKer009 += Alltrim("                               THEN 'PA'                                                                                                     ") + xrEnter
	xKer009 += Alltrim("                               ELSE 'PP'                                                                                                     ") + xrEnter
	xKer009 += Alltrim("                           END                                                                                                               ") + xrEnter
	xKer009 += Alltrim("          FROM TAB_B B                                                                                                                       ") + xrEnter
	xKer009 += Alltrim("               LEFT JOIN " + RetSqlName("Z29") + " Z29(NOLOCK) ON Z29_COD_IT = B.ITCUS                                                       ") + xrEnter
	xKer009 += Alltrim("                                               AND Z29.D_E_L_E_T_ = ' '),                                                                    ") + xrEnter
	xKer009 += Alltrim("      TABFINAL                                                                                                                               ") + xrEnter
	xKer009 += Alltrim("      AS (SELECT C.*,                                                                                                                        ") + xrEnter
	xKer009 += Alltrim("                 DESCR = ISNULL(SUBSTRING(B1_DESC, 1, 50), ' '),                                                                             ") + xrEnter
	xKer009 += Alltrim("                 REGRAC = ISNULL(B1_YREGRAC, ' '),                                                                                           ") + xrEnter
	xKer009 += Alltrim("                 RATEIO = CASE                                                                                                               ") + xrEnter
	xKer009 += Alltrim("                              WHEN B1_YREGRAC = '1'                                                                                          ") + xrEnter
	xKer009 += Alltrim("                              THEN 'CAP. PRODUTIVA'                                                                                          ") + xrEnter
	xKer009 += Alltrim("                              WHEN B1_YREGRAC = '2'                                                                                          ") + xrEnter
	xKer009 += Alltrim("                              THEN 'PESO SECO'                                                                                               ") + xrEnter
	xKer009 += Alltrim("                              WHEN B1_YREGRAC = '3'                                                                                          ") + xrEnter
	xKer009 += Alltrim("                              THEN 'M2'                                                                                                      ") + xrEnter
	xKer009 += Alltrim("                              ELSE 'INDEFINIDO'                                                                                              ") + xrEnter
	xKer009 += Alltrim("                          END                                                                                                                ") + xrEnter
	xKer009 += Alltrim("          FROM TAB_C C                                                                                                                       ") + xrEnter
	xKer009 += Alltrim("               LEFT JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "'                                       ") + xrEnter
	xKer009 += Alltrim("                                               AND B1_COD = MODS                                                                             ") + xrEnter
	xKer009 += Alltrim("                                               AND SB1.D_E_L_E_T_ = ' '                                                                      ") + xrEnter
	xKer009 += Alltrim("          WHERE Z29_TIPO = 'CF')                                                                                                             ") + xrEnter

Return ( xKer009 )
