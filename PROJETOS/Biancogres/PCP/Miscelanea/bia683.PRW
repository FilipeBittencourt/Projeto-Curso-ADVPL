#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

User Function BIA683()

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA683
Empresa   := Biancogres Cerâmica S/A
Data      := 10/06/16
Uso       := PCP
Aplicação := Movimentação sitética de Estoque
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

#IFDEF WINDOWS
	Processa({|| RptDetail()})
	Return
	Static Function RptDetail()
#ENDIF

fPerg := "BIA683"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
fValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf
HyEnter := CHR(13)+CHR(10)

oExcel := FWMSEXCEL():New()

nxPlan := "Planilha 01"
nxTabl := "Movimentação sitética de Estoque"

oExcel:AddworkSheet(nxPlan)
oExcel:AddTable (nxPlan, nxTabl)
oExcel:AddColumn(nxPlan, nxTabl, "EMPR    "          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "TABL    "          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "PERIODO "          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "PRODUT  "          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DESCR   "          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "GRUPO   "          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DGRUPO  "          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "UM      "          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CLVL    "          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DCLVL   "          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "CONTA   "          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "DCONTA  "          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "TIPO    "          ,1,1)
oExcel:AddColumn(nxPlan, nxTabl, "REFERENCIA"        ,3,2)
oExcel:AddColumn(nxPlan, nxTabl, "QUANT   "          ,3,2)
oExcel:AddColumn(nxPlan, nxTabl, "CUSTO   "          ,3,2)

YH003 := Alltrim(" WITH MOVIMENT AS (SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'NF_SAI' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D2_EMISSAO DATREF,                                                     ") + HyEnter
YH003 += Alltrim("                          D2_TES TES,                                                            ") + HyEnter
YH003 += Alltrim("                          D2_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D2_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D2_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          D2_LOCAL LOC,                                                          ") + HyEnter
YH003 += Alltrim("                          D2_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D2_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'Q' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          D2_QUANT * (-1) VALOR,                                                 ") + HyEnter
YH003 += Alltrim("                          0 * (-1) QUANT,                                                        ") + HyEnter
YH003 += Alltrim("                          0 * (-1) CUSTO                                                         ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    INNER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"'      ") + HyEnter
YH003 += Alltrim("                                         AND F4_CODIGO = D2_TES                                  ") + HyEnter
YH003 += Alltrim("                                         AND F4_ESTOQUE = 'S'                                    ") + HyEnter
YH003 += Alltrim("                                         AND SF4.D_E_L_E_T_ = ' '                                ") + HyEnter
YH003 += Alltrim("                    WHERE D2_FILIAL = '"+xFilial("SD2")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D2_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D2_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND SD2.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'NF_ENT' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D1_DTDIGIT DATREF,                                                     ") + HyEnter
YH003 += Alltrim("                          D1_TES TES,                                                            ") + HyEnter
YH003 += Alltrim("                          D1_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D1_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D1_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          D1_LOCAL LOC,                                                          ") + HyEnter
YH003 += Alltrim("                          D1_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D1_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'Q' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          D1_QUANT VALOR,                                                        ") + HyEnter
YH003 += Alltrim("                          0 QUANT,                                                               ") + HyEnter
YH003 += Alltrim("                          0 CUSTO                                                                ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    INNER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"'      ") + HyEnter
YH003 += Alltrim("                                         AND F4_CODIGO = D1_TES                                  ") + HyEnter
YH003 += Alltrim("                                         AND F4_ESTOQUE = 'S'                                    ") + HyEnter
YH003 += Alltrim("                                         AND SF4.D_E_L_E_T_ = ' '                                ") + HyEnter
YH003 += Alltrim("                    WHERE D1_FILIAL = '"+xFilial("SD1")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D1_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D1_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND SD1.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'MI_SAI' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_EMISSAO DTREF,                                                      ") + HyEnter
YH003 += Alltrim("                          D3_TM TES,                                                             ") + HyEnter
YH003 += Alltrim("                          D3_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D3_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_LOCAL LOC,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'Q' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_QUANT * (-1) VALOR,                                                 ") + HyEnter
YH003 += Alltrim("                          0 * (-1) QUANT,                                                        ") + HyEnter
YH003 += Alltrim("                          0 * (-1) CUSTO                                                         ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND D3_TM > '500'                                                          ") + HyEnter
YH003 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                      ") + HyEnter
YH003 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'MI_SAI' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_EMISSAO DATREF,                                                     ") + HyEnter
YH003 += Alltrim("                          D3_TM TES,                                                             ") + HyEnter
YH003 += Alltrim("                          D3_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D3_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          '99' LOC,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'Q' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_QUANT * (-1) VALOR,                                                 ") + HyEnter
YH003 += Alltrim("                          0 * (-1) QUANT,                                                        ") + HyEnter
YH003 += Alltrim("                          0 * (-1) CUSTO                                                         ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND D3_CF = 'DE3'                                                          ") + HyEnter
YH003 += Alltrim("                      AND D3_LOCAL NOT IN ('99')                                                 ") + HyEnter
YH003 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                      ") + HyEnter
YH003 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'MI_ENT' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_EMISSAO DATREF,                                                     ") + HyEnter
YH003 += Alltrim("                          D3_TM TES,                                                             ") + HyEnter
YH003 += Alltrim("                          D3_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D3_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_LOCAL LOC,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'Q' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_QUANT VALOR,                                                        ") + HyEnter
YH003 += Alltrim("                          0 QUANT,                                                               ") + HyEnter
YH003 += Alltrim("                          0 CUSTO                                                                ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND D3_TM <= '500'                                                         ") + HyEnter
YH003 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                      ") + HyEnter
YH003 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'MI_ENT' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_EMISSAO DATREF,                                                     ") + HyEnter
YH003 += Alltrim("                          D3_TM TES,                                                             ") + HyEnter
YH003 += Alltrim("                          D3_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D3_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          '99' LOC,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'Q' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_QUANT VALOR,                                                        ") + HyEnter
YH003 += Alltrim("                          0 QUANT,                                                               ") + HyEnter
YH003 += Alltrim("                          0 CUSTO                                                                ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND D3_CF = 'RE3'                                                          ") + HyEnter
YH003 += Alltrim("                      AND D3_LOCAL NOT IN ('99')                                                 ") + HyEnter
YH003 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                      ") + HyEnter
YH003 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'NF_SAI' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D2_EMISSAO DATREF,                                                     ") + HyEnter
YH003 += Alltrim("                          D2_TES TES,                                                            ") + HyEnter
YH003 += Alltrim("                          D2_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D2_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D2_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          D2_LOCAL LOC,                                                          ") + HyEnter
YH003 += Alltrim("                          D2_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D2_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'C' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          D2_CUSTO1 * (-1) VALOR,                                                ") + HyEnter
YH003 += Alltrim("                          0 * (-1) QUANT,                                                        ") + HyEnter
YH003 += Alltrim("                          0 * (-1) CUSTO                                                         ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    INNER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"'      ") + HyEnter
YH003 += Alltrim("                                         AND F4_CODIGO = D2_TES                                  ") + HyEnter
YH003 += Alltrim("                                         AND F4_ESTOQUE = 'S'                                    ") + HyEnter
YH003 += Alltrim("                                         AND SF4.D_E_L_E_T_ = ' '                                ") + HyEnter
YH003 += Alltrim("                    WHERE D2_FILIAL = '"+xFilial("SD2")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D2_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D2_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND SD2.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'NF_ENT' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D1_DTDIGIT DATREF,                                                     ") + HyEnter
YH003 += Alltrim("                          D1_TES TES,                                                            ") + HyEnter
YH003 += Alltrim("                          D1_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D1_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D1_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          D1_LOCAL LOC,                                                          ") + HyEnter
YH003 += Alltrim("                          D1_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D1_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'C' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          D1_CUSTO VALOR,                                                        ") + HyEnter
YH003 += Alltrim("                          0 QUANT,                                                               ") + HyEnter
YH003 += Alltrim("                          0 CUSTO                                                                ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    INNER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"'      ") + HyEnter
YH003 += Alltrim("                                         AND F4_CODIGO = D1_TES                                  ") + HyEnter
YH003 += Alltrim("                                         AND F4_ESTOQUE = 'S'                                    ") + HyEnter
YH003 += Alltrim("                                         AND SF4.D_E_L_E_T_ = ' '                                ") + HyEnter
YH003 += Alltrim("                    WHERE D1_FILIAL = '"+xFilial("SD1")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D1_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D1_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND SD1.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'MI_SAI' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_EMISSAO DTREF,                                                      ") + HyEnter
YH003 += Alltrim("                          D3_TM TES,                                                             ") + HyEnter
YH003 += Alltrim("                          D3_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D3_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_LOCAL LOC,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'C' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_CUSTO1 * (-1) VALOR,                                                ") + HyEnter
YH003 += Alltrim("                          0 * (-1) QUANT,                                                        ") + HyEnter
YH003 += Alltrim("                          0 * (-1) CUSTO                                                         ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND D3_TM > '500'                                                          ") + HyEnter
YH003 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                      ") + HyEnter
YH003 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'MI_SAI' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_EMISSAO DATREF,                                                     ") + HyEnter
YH003 += Alltrim("                          D3_TM TES,                                                             ") + HyEnter
YH003 += Alltrim("                          D3_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D3_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          '99' LOC,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'C' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_CUSTO1 * (-1) VALOR,                                                ") + HyEnter
YH003 += Alltrim("                          0 * (-1) QUANT,                                                        ") + HyEnter
YH003 += Alltrim("                          0 * (-1) CUSTO                                                         ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND D3_CF = 'DE3'                                                          ") + HyEnter
YH003 += Alltrim("                      AND D3_LOCAL NOT IN ('99')                                                 ") + HyEnter
YH003 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                      ") + HyEnter
YH003 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'MI_ENT' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_EMISSAO DATREF,                                                     ") + HyEnter
YH003 += Alltrim("                          D3_TM TES,                                                             ") + HyEnter
YH003 += Alltrim("                          D3_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D3_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_LOCAL LOC,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'C' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_CUSTO1 VALOR,                                                       ") + HyEnter
YH003 += Alltrim("                          0 QUANT,                                                               ") + HyEnter
YH003 += Alltrim("                          0 CUSTO                                                                ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND D3_TM <= '500'                                                         ") + HyEnter
YH003 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                      ") + HyEnter
YH003 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'MI_ENT' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_EMISSAO DATREF,                                                     ") + HyEnter
YH003 += Alltrim("                          D3_TM TES,                                                             ") + HyEnter
YH003 += Alltrim("                          D3_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D3_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          '99' LOC,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'C' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_CUSTO1 VALOR,                                                       ") + HyEnter
YH003 += Alltrim("                          0 QUANT,                                                               ") + HyEnter
YH003 += Alltrim("                          0 CUSTO                                                                ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND D3_CF = 'RE3'                                                          ") + HyEnter
YH003 += Alltrim("                      AND D3_LOCAL NOT IN ('99')                                                 ") + HyEnter
YH003 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                      ") + HyEnter
YH003 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'NF_SAI' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D2_EMISSAO DATREF,                                                     ") + HyEnter
YH003 += Alltrim("                          D2_TES TES,                                                            ") + HyEnter
YH003 += Alltrim("                          D2_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D2_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D2_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          D2_LOCAL LOC,                                                          ") + HyEnter
YH003 += Alltrim("                          D2_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D2_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'M' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          0 * (-1) VALOR,                                                        ") + HyEnter
YH003 += Alltrim("                          D2_QUANT * (-1) QUANT,                                                 ") + HyEnter
YH003 += Alltrim("                          D2_CUSTO1 * (-1) CUSTO                                                 ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD2")+" SD2 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    INNER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"'      ") + HyEnter
YH003 += Alltrim("                                         AND F4_CODIGO = D2_TES                                  ") + HyEnter
YH003 += Alltrim("                                         AND F4_ESTOQUE = 'S'                                    ") + HyEnter
YH003 += Alltrim("                                         AND SF4.D_E_L_E_T_ = ' '                                ") + HyEnter
YH003 += Alltrim("                    WHERE D2_FILIAL = '"+xFilial("SD2")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D2_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D2_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND SD2.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'NF_ENT' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D1_DTDIGIT DATREF,                                                     ") + HyEnter
YH003 += Alltrim("                          D1_TES TES,                                                            ") + HyEnter
YH003 += Alltrim("                          D1_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D1_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D1_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          D1_LOCAL LOC,                                                          ") + HyEnter
YH003 += Alltrim("                          D1_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D1_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'M' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          0 VALOR,                                                               ") + HyEnter
YH003 += Alltrim("                          D1_QUANT QUANT,                                                        ") + HyEnter
YH003 += Alltrim("                          D1_CUSTO CUSTO                                                         ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD1")+" SD1 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    INNER JOIN "+RetSqlName("SF4")+" SF4 WITH (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"'      ") + HyEnter
YH003 += Alltrim("                                         AND F4_CODIGO = D1_TES                                  ") + HyEnter
YH003 += Alltrim("                                         AND F4_ESTOQUE = 'S'                                    ") + HyEnter
YH003 += Alltrim("                                         AND SF4.D_E_L_E_T_ = ' '                                ") + HyEnter
YH003 += Alltrim("                    WHERE D1_FILIAL = '"+xFilial("SD1")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D1_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D1_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND SD1.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'MI_SAI' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_EMISSAO DTREF,                                                      ") + HyEnter
YH003 += Alltrim("                          D3_TM TES,                                                             ") + HyEnter
YH003 += Alltrim("                          D3_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D3_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_LOCAL LOC,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'M' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          0 * (-1) VALOR,                                                        ") + HyEnter
YH003 += Alltrim("                          D3_QUANT * (-1) QUANT,                                                 ") + HyEnter
YH003 += Alltrim("                          D3_CUSTO1 * (-1) CUSTO                                                 ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND D3_TM > '500'                                                          ") + HyEnter
YH003 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                      ") + HyEnter
YH003 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'MI_SAI' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_EMISSAO DATREF,                                                     ") + HyEnter
YH003 += Alltrim("                          D3_TM TES,                                                             ") + HyEnter
YH003 += Alltrim("                          D3_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D3_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          '99' LOC,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'M' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          0 * (-1) VALOR,                                                        ") + HyEnter
YH003 += Alltrim("                          D3_QUANT * (-1) QUANT,                                                 ") + HyEnter
YH003 += Alltrim("                          D3_CUSTO1 * (-1) CUSTO                                                 ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND D3_CF = 'DE3'                                                          ") + HyEnter
YH003 += Alltrim("                      AND D3_LOCAL NOT IN ('99')                                                 ") + HyEnter
YH003 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                      ") + HyEnter
YH003 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'MI_ENT' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_EMISSAO DATREF,                                                     ") + HyEnter
YH003 += Alltrim("                          D3_TM TES,                                                             ") + HyEnter
YH003 += Alltrim("                          D3_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D3_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_LOCAL LOC,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'M' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          0 VALOR,                                                               ") + HyEnter
YH003 += Alltrim("                          D3_QUANT QUANT,                                                        ") + HyEnter
YH003 += Alltrim("                          D3_CUSTO1 CUSTO                                                        ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND D3_TM <= '500'                                                         ") + HyEnter
YH003 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                      ") + HyEnter
YH003 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' '                                                   ") + HyEnter
YH003 += Alltrim("                    UNION ALL                                                                    ") + HyEnter
YH003 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                    ") + HyEnter
YH003 += Alltrim("                          'MI_ENT' TABL,                                                         ") + HyEnter
YH003 += Alltrim("                          D3_EMISSAO DATREF,                                                     ") + HyEnter
YH003 += Alltrim("                          D3_TM TES,                                                             ") + HyEnter
YH003 += Alltrim("                          D3_CF CF,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_DOC DOC,                                                            ") + HyEnter
YH003 += Alltrim("                          D3_COD PRODUT,                                                         ") + HyEnter
YH003 += Alltrim("                          '99' LOC,                                                              ") + HyEnter
YH003 += Alltrim("                          D3_CLVL CLVL,                                                          ") + HyEnter
YH003 += Alltrim("                          D3_CONTA CONTA,                                                        ") + HyEnter
YH003 += Alltrim("                          'M' TIPO,                                                              ") + HyEnter
YH003 += Alltrim("                          0 VALOR,                                                               ") + HyEnter
YH003 += Alltrim("                          D3_QUANT QUANT,                                                        ") + HyEnter
YH003 += Alltrim("                          D3_CUSTO1 CUSTO                                                        ") + HyEnter
YH003 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)                                ") + HyEnter
YH003 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                       ") + HyEnter
YH003 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'       ") + HyEnter
YH003 += Alltrim("                      AND D3_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                       ") + HyEnter
YH003 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                     ") + HyEnter
YH003 += Alltrim("                      AND D3_CF = 'RE3'                                                          ") + HyEnter
YH003 += Alltrim("                      AND D3_LOCAL NOT IN ('99')                                                 ") + HyEnter
YH003 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                      ") + HyEnter
YH003 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' ')                                                  ") + HyEnter
YH003 += Alltrim(" SELECT EMPR,                                                                                    ") + HyEnter
YH003 += Alltrim("        TABL,                                                                                    ") + HyEnter
YH003 += Alltrim("        SUBSTRING(DATREF,1,6) PERIODO,                                                           ") + HyEnter
YH003 += Alltrim("        PRODUT,                                                                                  ") + HyEnter
YH003 += Alltrim("        SUBSTRING(B1_DESC,1,70) DESCR,                                                           ") + HyEnter
YH003 += Alltrim("        B1_GRUPO,                                                                                ") + HyEnter
YH003 += Alltrim("        BM_DESC,                                                                                 ") + HyEnter
YH003 += Alltrim("        B1_UM,                                                                                   ") + HyEnter
YH003 += Alltrim("        CLVL,                                                                                    ") + HyEnter
YH003 += Alltrim("        CTH_DESC01,                                                                              ") + HyEnter
YH003 += Alltrim("        CONTA,                                                                                   ") + HyEnter
YH003 += Alltrim("        CT1_DESC01,                                                                              ") + HyEnter
YH003 += Alltrim("        TIPO,                                                                                    ") + HyEnter
YH003 += Alltrim("        SUM(VALOR) VALOR,                                                                        ") + HyEnter
YH003 += Alltrim("        SUM(QUANT) QUANT,                                                                        ") + HyEnter
YH003 += Alltrim("        SUM(CUSTO) CUSTO                                                                         ") + HyEnter
YH003 += Alltrim("   FROM MOVIMENT MOV                                                                             ") + HyEnter
YH003 += Alltrim("  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'                       ") + HyEnter
YH003 += Alltrim("                       AND B1_COD = MOV.PRODUT                                                   ") + HyEnter
YH003 += Alltrim("                       AND B1_TIPO BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'                     ") + HyEnter
YH003 += Alltrim("                       AND SB1.D_E_L_E_T_ = ' '                                                  ") + HyEnter
YH003 += Alltrim("  INNER JOIN "+RetSqlName("SBM")+" SBM ON BM_FILIAL = '"+xFilial("SBM")+"'                       ") + HyEnter
YH003 += Alltrim("                       AND BM_GRUPO = B1_GRUPO                                                   ") + HyEnter
YH003 += Alltrim("                       AND SB1.D_E_L_E_T_ = ' '                                                  ") + HyEnter
YH003 += Alltrim("  INNER JOIN "+RetSqlName("CT1")+" CT1 ON CT1_FILIAL = '"+xFilial("CT1")+"'                      ") + HyEnter
YH003 += Alltrim("                       AND CT1_CONTA = CONTA                                                     ") + HyEnter
YH003 += Alltrim("                       AND CT1.D_E_L_E_T_ = ' '                                                  ") + HyEnter
YH003 += Alltrim("  INNER JOIN "+RetSqlName("CTH")+" CTH ON CTH_FILIAL = '"+xFilial("CTH")+"'                      ") + HyEnter
YH003 += Alltrim("                       AND CTH_CLVL = CLVL                                                       ") + HyEnter
YH003 += Alltrim("                       AND CTH.D_E_L_E_T_ = ' '                                                  ") + HyEnter
YH003 += Alltrim("  GROUP BY EMPR,                                                                                 ") + HyEnter
YH003 += Alltrim("           TABL,                                                                                 ") + HyEnter
YH003 += Alltrim("           SUBSTRING(DATREF,1,6),                                                                ") + HyEnter
YH003 += Alltrim("           PRODUT,                                                                               ") + HyEnter
YH003 += Alltrim("           SUBSTRING(B1_DESC,1,70),                                                              ") + HyEnter
YH003 += Alltrim("           B1_GRUPO,                                                                             ") + HyEnter
YH003 += Alltrim("           BM_DESC,                                                                              ") + HyEnter
YH003 += Alltrim("           B1_UM,                                                                                ") + HyEnter
YH003 += Alltrim("           CLVL,                                                                                 ") + HyEnter
YH003 += Alltrim("           CTH_DESC01,                                                                           ") + HyEnter
YH003 += Alltrim("           CONTA,                                                                                ") + HyEnter
YH003 += Alltrim("           CT1_DESC01,                                                                           ") + HyEnter
YH003 += Alltrim("           TIPO                                                                                  ") + HyEnter
YHcIndex := CriaTrab(Nil,.f.)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,YH003),'YH03',.F.,.T.)
dbSelectArea("YH03")
dbGoTop()
ProcRegua(RecCount())
ckContad := 0
While !Eof()
	
	ckContad ++
	IncProc("Processamento1: " + Alltrim(Str(ckContad)))
	
	kfTipo := IIF(YH03->TIPO == "C", "CUSTO", IIF(YH03->TIPO == "M", "MEDIO", IIF(YH03->TIPO == "Q", "QUANTIDADE", "")))
	
	oExcel:AddRow(nxPlan, nxTabl, { YH03->EMPR        ,;
	YH03->TABL                                        ,;
	YH03->PERIODO                                     ,;
	YH03->PRODUT                                      ,;
	YH03->DESCR                                       ,;
	YH03->B1_GRUPO                                    ,;
	YH03->BM_DESC                                     ,;
	YH03->B1_UM                                       ,;
	YH03->CLVL                                        ,;
	YH03->CTH_DESC01                                  ,;
	YH03->CONTA                                       ,;
	YH03->CT1_DESC01                                  ,;
	kfTipo                                            ,;
	YH03->VALOR                                       ,;
	YH03->QUANT                                       ,;
	YH03->CUSTO                                       })
	
	dbSelectArea("YH03")
	dbSkip()
	
End

YH03->(dbCloseArea())
Ferase(YHcIndex+GetDBExtension())     //arquivo de trabalho
Ferase(YHcIndex+OrdBagExt())          //indice gerado

xArqTemp := "movimento-estoque - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)

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
aAdd(aRegs,{cPerg,"03","De Produto               ?","","","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"04","Até Produto              ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"05","De Grupo                 ?","","","mv_ch5","C",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
aAdd(aRegs,{cPerg,"06","Até Grupo                ?","","","mv_ch6","C",04,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
aAdd(aRegs,{cPerg,"07","De Tipo                  ?","","","mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","02"})
aAdd(aRegs,{cPerg,"08","Até Tipo                 ?","","","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","02"})
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
