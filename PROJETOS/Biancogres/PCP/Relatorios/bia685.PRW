#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA685
@author Marcos Alberto Soprani
@since 13/06/16
@version 1.0
@description Movimentação sintética de Estoque para avaliação do setor de
.            Manutenção 
@type function
/*/

User Function BIA685()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local _cArqCsv	:=	""

	Local _cLinha	:=	""

	fPerg := "BIA685"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf
	HpEnter := CHR(13)+CHR(10)

	If DateDiffDay(MV_PAR01,MV_PAR02) > 90

		If MsgYesNo("A quantidade de dias é superior a 90 e o relatório em excel pode não suportar o volume de dados. Deseja que seja gerado um arquivo de texto com delimitador automaticamente ?")

			MV_PAR11	:=	1
			MV_PAR12	:=	"|"

		Else
			Return
		EndIf

	EndIf

	xArqTemp := "movimento-estoque - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)


	If MV_PAR11 == 2
		oExcel := FWMSEXCEL():New()

		nxPlan := "Planilha 01"
		nxTabl := "Movimentação sintética de Estoque"

		oExcel:AddworkSheet(nxPlan)
		oExcel:AddTable (nxPlan, nxTabl)
		oExcel:AddColumn(nxPlan, nxTabl, "EMPR        "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "TABL        "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PERIODO     "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DATREF      "       ,1,4)
		oExcel:AddColumn(nxPlan, nxTabl, "TES         "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CF          "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DOC         "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PRODUT      "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DESCR       "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "GRUPO       "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DGRUPO      "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "UM          "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "LOC         "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "MATRIC_FUNC "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "NOME_FUNC   "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CLVL_FUNC   "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "SETOR       "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "TAG         "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DTAG        "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "AREA        "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "APLIC       "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "APLICACAO   "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CLVL        "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DCLVL       "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CONTA       "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DCONTA      "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "QUANT       "       ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "CUSTO       "       ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "ICONTA      "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DICONTA     "       ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "DESCR_PC    "       ,1,1)

	EndIf

	PK008 := Alltrim(" WITH MOVIMENT AS (SELECT '"+cEmpAnt+"' EMPR,                                                  ") + HpEnter
	PK008 += Alltrim("                          'NF_ENT' TABL,                                                       ") + HpEnter
	PK008 += Alltrim("                          D1_DTDIGIT DATREF,                                                   ") + HpEnter
	PK008 += Alltrim("                          D1_TES TES,                                                          ") + HpEnter
	PK008 += Alltrim("                          D1_CF CF,                                                            ") + HpEnter
	PK008 += Alltrim("                          D1_DOC DOC,                                                          ") + HpEnter
	PK008 += Alltrim("                          D1_COD PRODUT,                                                       ") + HpEnter
	PK008 += Alltrim("                          D1_LOCAL LOC,                                                        ") + HpEnter
	PK008 += Alltrim("                          '"+cEmpAnt+"'+C7_YMAT MATRIC,                                        ") + HpEnter
	PK008 += Alltrim("                          RTRIM(C7_DESCRI) DESCRPC,                                            ") + HpEnter
	PK008 += Alltrim("                          D1_YTAG TAG,                                                         ") + HpEnter
	PK008 += Alltrim("                          D1_YAPLIC APLIC,                                                     ") + HpEnter
	PK008 += Alltrim("                          D1_CLVL CLVL,                                                        ") + HpEnter
	PK008 += Alltrim("                          D1_CONTA CONTA,                                                      ") + HpEnter
	PK008 += Alltrim("                          D1_QUANT QUANT,                                                      ") + HpEnter
	PK008 += Alltrim("                          D1_CUSTO CUSTO                                                       ") + HpEnter
	PK008 += Alltrim("                     FROM "+RetSqlName("SD1")+" SD1                                            ") + HpEnter
	PK008 += Alltrim("                    INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'   ") + HpEnter
	PK008 += Alltrim("                                         AND F4_CODIGO = D1_TES                                ") + HpEnter
	//PK008 += Alltrim("                                         AND F4_ESTOQUE = 'S'                                  ") + HpEnter
	PK008 += Alltrim("                                         AND SF4.D_E_L_E_T_ = ' '                              ") + HpEnter
	PK008 += Alltrim("                     LEFT JOIN "+RetSqlName("SC7")+" SC7 ON C7_FILIAL = '"+xFilial("SC7")+"'   ") + HpEnter
	PK008 += Alltrim("                                         AND C7_NUM = D1_PEDIDO                                ") + HpEnter
	PK008 += Alltrim("                                         AND C7_ITEM = D1_ITEMPC                               ") + HpEnter
	PK008 += Alltrim("                                         AND SC7.D_E_L_E_T_ = ' '                              ") + HpEnter
	PK008 += Alltrim("                    WHERE D1_FILIAL = '"+xFilial("SD1")+"'                                     ") + HpEnter
	PK008 += Alltrim("                      AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'     ") + HpEnter
	PK008 += Alltrim("                      AND D1_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                   ") + HpEnter
	PK008 += Alltrim("                      AND D1_CLVL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                    ") + HpEnter
	PK008 += Alltrim("                      AND D1_CONTA BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'                   ") + HpEnter
	PK008 += Alltrim("                      AND D1_YTAG BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                    ") + HpEnter
	PK008 += Alltrim("                      AND SD1.D_E_L_E_T_ = ' '                                                 ") + HpEnter
	PK008 += Alltrim("                    UNION ALL                                                                  ") + HpEnter
	PK008 += Alltrim("                   SELECT '"+cEmpAnt+"' EMPR,                                                  ") + HpEnter
	PK008 += Alltrim("                          'SERVIC' TABL,                                                       ") + HpEnter
	PK008 += Alltrim("                          D1_DTDIGIT DATREF,                                                   ") + HpEnter
	PK008 += Alltrim("                          D1_TES TES,                                                          ") + HpEnter
	PK008 += Alltrim("                          D1_CF CF,                                                            ") + HpEnter
	PK008 += Alltrim("                          D1_DOC DOC,                                                          ") + HpEnter
	PK008 += Alltrim("                          D1_COD PRODUT,                                                       ") + HpEnter
	PK008 += Alltrim("                          D1_LOCAL LOC,                                                        ") + HpEnter
	PK008 += Alltrim("                          '"+cEmpAnt+"'+C7_YMAT MATRIC,                                        ") + HpEnter
	PK008 += Alltrim("                          RTRIM(C7_DESCRI) DESCRPC,                                            ") + HpEnter
	PK008 += Alltrim("                          D1_YTAG TAG,                                                         ") + HpEnter
	PK008 += Alltrim("                          D1_YAPLIC APLIC,                                                     ") + HpEnter
	PK008 += Alltrim("                          D1_CLVL CLVL,                                                        ") + HpEnter
	PK008 += Alltrim("                          D1_CONTA CONTA,                                                      ") + HpEnter
	PK008 += Alltrim("                          D1_QUANT QUANT,                                                      ") + HpEnter
	PK008 += Alltrim("                          D1_CUSTO CUSTO                                                       ") + HpEnter
	PK008 += Alltrim("                     FROM "+RetSqlName("SD1")+" SD1                                            ") + HpEnter
	PK008 += Alltrim("                    INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'   ") + HpEnter
	PK008 += Alltrim("                                         AND F4_CODIGO = D1_TES                                ") + HpEnter
	PK008 += Alltrim("                                         AND SF4.D_E_L_E_T_ = ' '                              ") + HpEnter
	PK008 += Alltrim("                     LEFT JOIN "+RetSqlName("SC7")+" SC7 ON C7_FILIAL = '"+xFilial("SC7")+"'   ") + HpEnter
	PK008 += Alltrim("                                         AND C7_NUM = D1_PEDIDO                                ") + HpEnter
	PK008 += Alltrim("                                         AND C7_ITEM = D1_ITEMPC                               ") + HpEnter
	PK008 += Alltrim("                                         AND SC7.D_E_L_E_T_ = ' '                              ") + HpEnter
	PK008 += Alltrim("                    WHERE D1_FILIAL = '"+xFilial("SD1")+"'                                     ") + HpEnter
	PK008 += Alltrim("                      AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'     ") + HpEnter
	PK008 += Alltrim("                      AND D1_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                   ") + HpEnter
	PK008 += Alltrim("                      AND D1_CLVL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                    ") + HpEnter
	PK008 += Alltrim("                      AND D1_CONTA BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'                   ") + HpEnter
	PK008 += Alltrim("                      AND D1_YTAG BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                    ") + HpEnter
	PK008 += Alltrim("                      AND D1_COD Like '306%'                                                   ") + HpEnter
	PK008 += Alltrim("                      AND SD1.D_E_L_E_T_ = ' '                                                 ") + HpEnter
	PK008 += Alltrim("                    UNION ALL                                                                  ") + HpEnter
	PK008 += Alltrim("                   SELECT '01' EMPR,                                                           ") + HpEnter
	PK008 += Alltrim("                          'MI_SAI' TABL,                                                       ") + HpEnter
	PK008 += Alltrim("                          D3_EMISSAO DTREF,                                                    ") + HpEnter
	PK008 += Alltrim("                          D3_TM TES,                                                           ") + HpEnter
	PK008 += Alltrim("                          D3_CF CF,                                                            ") + HpEnter
	PK008 += Alltrim("                          D3_DOC DOC,                                                          ") + HpEnter
	PK008 += Alltrim("                          D3_COD PRODUT,                                                       ") + HpEnter
	PK008 += Alltrim("                          D3_LOCAL LOC,                                                        ") + HpEnter
	PK008 += Alltrim("                          D3_YMATRIC MATRIC,                                                   ") + HpEnter
	PK008 += Alltrim("                          '' DESCRPC,                                                          ") + HpEnter
	PK008 += Alltrim("                          D3_YTAG TAG,                                                         ") + HpEnter
	PK008 += Alltrim("                          D3_YAPLIC APLIC,                                                     ") + HpEnter
	PK008 += Alltrim("                          D3_CLVL CLVL,                                                        ") + HpEnter
	PK008 += Alltrim("                          D3_CONTA CONTA,                                                      ") + HpEnter
	PK008 += Alltrim("                          D3_QUANT * (-1) QUANT,                                               ") + HpEnter
	PK008 += Alltrim("                          D3_CUSTO1 * (-1) CUSTO                                               ") + HpEnter
	PK008 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3                                            ") + HpEnter
	PK008 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                     ") + HpEnter
	PK008 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'     ") + HpEnter
	PK008 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                   ") + HpEnter
	PK008 += Alltrim("                      AND D3_CLVL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                    ") + HpEnter
	PK008 += Alltrim("                      AND D3_CONTA BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'                   ") + HpEnter
	PK008 += Alltrim("                      AND D3_YTAG BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                    ") + HpEnter
	PK008 += Alltrim("                      AND D3_TM > '500'                                                        ") + HpEnter
	PK008 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                    ") + HpEnter
	PK008 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' '                                                 ") + HpEnter
	PK008 += Alltrim("                    UNION ALL                                                                  ") + HpEnter
	PK008 += Alltrim("                   SELECT '01' EMPR,                                                           ") + HpEnter
	PK008 += Alltrim("                          'MI_SAI' TABL,                                                       ") + HpEnter
	PK008 += Alltrim("                          D3_EMISSAO DATREF,                                                   ") + HpEnter
	PK008 += Alltrim("                          D3_TM TES,                                                           ") + HpEnter
	PK008 += Alltrim("                          D3_CF CF,                                                            ") + HpEnter
	PK008 += Alltrim("                          D3_DOC DOC,                                                          ") + HpEnter
	PK008 += Alltrim("                          D3_COD PRODUT,                                                       ") + HpEnter
	PK008 += Alltrim("                          '99' LOC,                                                            ") + HpEnter
	PK008 += Alltrim("                          D3_YMATRIC MATRIC,                                                   ") + HpEnter
	PK008 += Alltrim("                          '' DESCRPC,                                                          ") + HpEnter
	PK008 += Alltrim("                          D3_YTAG TAG,                                                         ") + HpEnter
	PK008 += Alltrim("                          D3_YAPLIC APLIC,                                                     ") + HpEnter
	PK008 += Alltrim("                          D3_CLVL CLVL,                                                        ") + HpEnter
	PK008 += Alltrim("                          D3_CONTA CONTA,                                                      ") + HpEnter
	PK008 += Alltrim("                          D3_QUANT * (-1) QUANT,                                               ") + HpEnter
	PK008 += Alltrim("                          D3_CUSTO1 * (-1) CUSTO                                               ") + HpEnter
	PK008 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3                                            ") + HpEnter
	PK008 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                     ") + HpEnter
	PK008 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'     ") + HpEnter
	PK008 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                   ") + HpEnter
	PK008 += Alltrim("                      AND D3_CLVL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                    ") + HpEnter
	PK008 += Alltrim("                      AND D3_CONTA BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'                   ") + HpEnter
	PK008 += Alltrim("                      AND D3_YTAG BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                    ") + HpEnter
	PK008 += Alltrim("                      AND D3_CF = 'DE3'                                                        ") + HpEnter
	PK008 += Alltrim("                      AND D3_LOCAL NOT IN ('99')                                               ") + HpEnter
	PK008 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                    ") + HpEnter
	PK008 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' '                                                 ") + HpEnter
	PK008 += Alltrim("                    UNION ALL                                                                  ") + HpEnter
	PK008 += Alltrim("                   SELECT '01' EMPR,                                                           ") + HpEnter
	PK008 += Alltrim("                          'MI_ENT' TABL,                                                       ") + HpEnter
	PK008 += Alltrim("                          D3_EMISSAO DATREF,                                                   ") + HpEnter
	PK008 += Alltrim("                          D3_TM TES,                                                           ") + HpEnter
	PK008 += Alltrim("                          D3_CF CF,                                                            ") + HpEnter
	PK008 += Alltrim("                          D3_DOC DOC,                                                          ") + HpEnter
	PK008 += Alltrim("                          D3_COD PRODUT,                                                       ") + HpEnter
	PK008 += Alltrim("                          D3_LOCAL LOC,                                                        ") + HpEnter
	PK008 += Alltrim("                          D3_YMATRIC MATRIC,                                                   ") + HpEnter
	PK008 += Alltrim("                          '' DESCRPC,                                                          ") + HpEnter
	PK008 += Alltrim("                          D3_YTAG TAG,                                                         ") + HpEnter
	PK008 += Alltrim("                          D3_YAPLIC APLIC,                                                     ") + HpEnter
	PK008 += Alltrim("                          D3_CLVL CLVL,                                                        ") + HpEnter
	PK008 += Alltrim("                          D3_CONTA CONTA,                                                      ") + HpEnter
	PK008 += Alltrim("                          D3_QUANT QUANT,                                                      ") + HpEnter
	PK008 += Alltrim("                          D3_CUSTO1 CUSTO                                                      ") + HpEnter
	PK008 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3                                            ") + HpEnter
	PK008 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                     ") + HpEnter
	PK008 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'     ") + HpEnter
	PK008 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                   ") + HpEnter
	PK008 += Alltrim("                      AND D3_CLVL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                    ") + HpEnter
	PK008 += Alltrim("                      AND D3_CONTA BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'                   ") + HpEnter
	PK008 += Alltrim("                      AND D3_YTAG BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                    ") + HpEnter
	PK008 += Alltrim("                      AND D3_TM <= '500'                                                       ") + HpEnter
	PK008 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                    ") + HpEnter
	PK008 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' '                                                 ") + HpEnter
	PK008 += Alltrim("                    UNION ALL                                                                  ") + HpEnter
	PK008 += Alltrim("                   SELECT '01' EMPR,                                                           ") + HpEnter
	PK008 += Alltrim("                          'MI_ENT' TABL,                                                       ") + HpEnter
	PK008 += Alltrim("                          D3_EMISSAO DATREF,                                                   ") + HpEnter
	PK008 += Alltrim("                          D3_TM TES,                                                           ") + HpEnter
	PK008 += Alltrim("                          D3_CF CF,                                                            ") + HpEnter
	PK008 += Alltrim("                          D3_DOC DOC,                                                          ") + HpEnter
	PK008 += Alltrim("                          D3_COD PRODUT,                                                       ") + HpEnter
	PK008 += Alltrim("                          '99' LOC,                                                            ") + HpEnter
	PK008 += Alltrim("                          D3_YMATRIC MATRIC,                                                   ") + HpEnter
	PK008 += Alltrim("                          '' DESCRPC,                                                          ") + HpEnter
	PK008 += Alltrim("                          D3_YTAG TAG,                                                         ") + HpEnter
	PK008 += Alltrim("                          D3_YAPLIC APLIC,                                                     ") + HpEnter
	PK008 += Alltrim("                          D3_CLVL CLVL,                                                        ") + HpEnter
	PK008 += Alltrim("                          D3_CONTA CONTA,                                                      ") + HpEnter
	PK008 += Alltrim("                          D3_QUANT QUANT,                                                      ") + HpEnter
	PK008 += Alltrim("                          D3_CUSTO1 CUSTO                                                      ") + HpEnter
	PK008 += Alltrim("                     FROM "+RetSqlName("SD3")+" SD3                                            ") + HpEnter
	PK008 += Alltrim("                    WHERE D3_FILIAL = '"+xFilial("SD3")+"'                                     ") + HpEnter
	PK008 += Alltrim("                      AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'     ") + HpEnter
	PK008 += Alltrim("                      AND D3_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                   ") + HpEnter
	PK008 += Alltrim("                      AND D3_CLVL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                    ") + HpEnter
	PK008 += Alltrim("                      AND D3_CONTA BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'                   ") + HpEnter
	PK008 += Alltrim("                      AND D3_YTAG BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                    ") + HpEnter
	PK008 += Alltrim("                      AND D3_CF = 'RE3'                                                        ") + HpEnter
	PK008 += Alltrim("                      AND D3_LOCAL NOT IN ('99')                                               ") + HpEnter
	PK008 += Alltrim("                      AND D3_ESTORNO <> 'S'                                                    ") + HpEnter
	PK008 += Alltrim("                      AND SD3.D_E_L_E_T_ = ' ')                                                ") + HpEnter
	PK008 += Alltrim(" SELECT *                                                                                      ") + HpEnter
	PK008 += Alltrim("   FROM (SELECT EMPR,                                                                          ") + HpEnter
	PK008 += Alltrim("                TABL,                                                                          ") + HpEnter
	PK008 += Alltrim("                SUBSTRING(DATREF,1,6) PERIODO,                                                 ") + HpEnter
	PK008 += Alltrim("                DATREF,                                                                        ") + HpEnter
	PK008 += Alltrim("                TES,                                                                           ") + HpEnter
	PK008 += Alltrim("                CF,                                                                            ") + HpEnter
	PK008 += Alltrim("                DOC,                                                                           ") + HpEnter
	PK008 += Alltrim("                PRODUT,                                                                        ") + HpEnter
	PK008 += Alltrim("                SUBSTRING(B1_DESC,1,70) DESCR,                                                 ") + HpEnter
	PK008 += Alltrim("                B1_GRUPO GRUPO,                                                                ") + HpEnter
	PK008 += Alltrim("                BM_DESC DGRUPO,                                                                ") + HpEnter
	PK008 += Alltrim("                B1_UM UM,                                                                      ") + HpEnter
	PK008 += Alltrim("                LOC LOC,                                                                       ") + HpEnter
	PK008 += Alltrim("                MATRIC MATRIC_FUNC,                                                            ") + HpEnter
	PK008 += Alltrim("                RA_NOME NOME_FUNC,                                                             ") + HpEnter
	PK008 += Alltrim("                RA_CLVL CLVL_FUNC,                                                             ") + HpEnter
	PK008 += Alltrim("                RA_YSEMAIL SETOR,                                                              ") + HpEnter
	PK008 += Alltrim("                TAG,                                                                           ") + HpEnter
	PK008 += Alltrim("                ZC_DESC DTAG,                                                                  ") + HpEnter
	PK008 += Alltrim("                ZC_AREA AREA,                                                                  ") + HpEnter
	PK008 += Alltrim("                APLIC,                                                                         ") + HpEnter
	PK008 += Alltrim("                CASE                                                                           ") + HpEnter
	PK008 += Alltrim("                  WHEN APLIC = '0' THEN 'NENHUM'                                               ") + HpEnter
	PK008 += Alltrim("                  WHEN APLIC = '1' THEN 'PRODUCAO'                                             ") + HpEnter
	PK008 += Alltrim("                  WHEN APLIC = '2' THEN 'MANUTENCAO'                                           ") + HpEnter
	PK008 += Alltrim("                  WHEN APLIC = '3' THEN 'MELHORIA_MANUT'                                       ") + HpEnter
	PK008 += Alltrim("                  WHEN APLIC = '4' THEN 'SEGURANCA'                                            ") + HpEnter
	PK008 += Alltrim("                  WHEN APLIC = '5' THEN 'CALIBRACAO'                                           ") + HpEnter
	PK008 += Alltrim("                  WHEN APLIC = '6' THEN 'MELHORIA_PROD'                                        ") + HpEnter
	PK008 += Alltrim("                 ELSE 'VERIFICAR'                                                              ") + HpEnter
	PK008 += Alltrim("                END APLICACAO,                                                                 ") + HpEnter
	PK008 += Alltrim("                CLVL,                                                                          ") + HpEnter
	PK008 += Alltrim("                CTH_DESC01 DCLVL,                                                              ") + HpEnter
	PK008 += Alltrim("                CONTA,                                                                         ") + HpEnter
	PK008 += Alltrim("                CT1_DESC01 DCONTA,                                                             ") + HpEnter
	PK008 += Alltrim("                QUANT,                                                                         ") + HpEnter
	PK008 += Alltrim("                CUSTO,                                                                         ") + HpEnter
	PK008 += Alltrim("                B1_YCTRIND ICONTA,                                                             ") + HpEnter
	PK008 += Alltrim("                (SELECT CT1_DESC01 FROM "+ RetSqlName("CT1") +" WHERE CT1_FILIAL = '' AND CT1_CONTA = B1_YCTRIND AND D_E_L_E_T_ = '') AS DICONTA, ") + HpEnter
	PK008 += Alltrim("                DESCRPC                                                                        ") + HpEnter
	PK008 += Alltrim("           FROM MOVIMENT MOV                                                                   ") + HpEnter
	PK008 += Alltrim("          INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'             ") + HpEnter
	PK008 += Alltrim("                               AND B1_COD = MOV.PRODUT                                         ") + HpEnter
	PK008 += Alltrim("                               AND SB1.D_E_L_E_T_ = ' '                                        ") + HpEnter
	PK008 += Alltrim("          INNER JOIN "+RetSqlName("SBM")+" SBM ON BM_FILIAL = '"+xFilial("SBM")+"'             ") + HpEnter
	PK008 += Alltrim("                               AND BM_GRUPO = B1_GRUPO                                         ") + HpEnter
	PK008 += Alltrim("                               AND SB1.D_E_L_E_T_ = ' '                                        ") + HpEnter
	PK008 += Alltrim("          INNER JOIN "+RetSqlName("CT1")+" CT1 ON CT1_FILIAL = '"+xFilial("CT1")+"'            ") + HpEnter
	PK008 += Alltrim("                               AND CT1_CONTA = CONTA                                           ") + HpEnter
	PK008 += Alltrim("                               AND CT1.D_E_L_E_T_ = ' '                                        ") + HpEnter
	PK008 += Alltrim("          INNER JOIN "+RetSqlName("CTH")+" CTH ON CTH_FILIAL = '"+xFilial("CTH")+"'            ") + HpEnter
	PK008 += Alltrim("                               AND CTH_CLVL = CLVL                                             ") + HpEnter
	PK008 += Alltrim("                               AND CTH.D_E_L_E_T_ = ' '                                        ") + HpEnter
	PK008 += Alltrim("           LEFT JOIN "+RetSqlName("SRA")+" SRA ON RA_FILIAL = '"+xFilial("SRA")+"'             ") + HpEnter
	PK008 += Alltrim("                               AND RA_MAT = SUBSTRING(MATRIC,3,6)                              ") + HpEnter
	PK008 += Alltrim("                               AND SRA.D_E_L_E_T_ = ' '                                        ") + HpEnter
	PK008 += Alltrim("           LEFT JOIN "+RetSqlName("SZC")+" SZC ON ZC_FILIAL = '"+xFilial("SZC")+"'             ") + HpEnter
	PK008 += Alltrim("                               AND ZC_NUM = TAG                                                ") + HpEnter
	PK008 += Alltrim("                               AND SZC.D_E_L_E_T_ = ' ') AS TABR                               ") + HpEnter
	PKcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,PK008),'PK08',.F.,.T.)
	dbSelectArea("PK08")
	dbGoTop()
	ProcRegua(RecCount())
	ckContad := 0

	IF MV_PAR11 == 1
		_cArqCsv	:=	"C:\Temp\"+xArqTemp+Alltrim(Str(Seconds()))+".txt"

		nHdl := fCreate(_cArqCsv)

		If nHdl	== -1
			MsgInfo("Falha ao Criar o arquivo csv!")
			PK08->(dbCloseArea())
			Ferase(PKcIndex+GetDBExtension())     //arquivo de trabalho
			Ferase(PKcIndex+OrdBagExt())          //indice gerado
			Return
		EndIf

		_cLinha	:=	"EM" 					+ MV_PAR12
		_cLinha	+=	"TABL" + Space(2)		+ MV_PAR12 
		_cLinha	+=	"PERIOD" 				+ MV_PAR12
		_cLinha	+=	"DATREF" + Space(2)		+ MV_PAR12
		_cLinha	+=	"TES"					+ MV_PAR12
		_cLinha	+=	"CF" + Space(3)			+ MV_PAR12
		_cLinha	+=	"DOC" + Space(6)		+ MV_PAR12
		_cLinha	+=	"PRODUT" + Space(9)		+ MV_PAR12
		_cLinha	+=	"DESCR" + Space(65)		+ MV_PAR12
		_cLinha	+=	"GRUP"					+ MV_PAR12
		_cLinha	+=	"DGRUPO" + Space(24)	+ MV_PAR12
		_cLinha	+=	"UM"					+ MV_PAR12
		_cLinha	+=	"LO"					+ MV_PAR12
		_cLinha	+=	"MATRIC_F"				+ MV_PAR12
		_cLinha	+=	"NOME_FUNC" + Space(21)	+ MV_PAR12
		_cLinha	+=	"CLVL_FUNC"				+ MV_PAR12
		_cLinha	+=	"SETOR" + Space(95)		+ MV_PAR12
		_cLinha	+=	"TAG" + Space(9)		+ MV_PAR12
		_cLinha	+=	"DTAG" + Space(196)		+ MV_PAR12
		_cLinha	+=	"AREA" + Space(26)		+ MV_PAR12
		_cLinha	+=	"A"						+ MV_PAR12
		_cLinha	+=	"APLICACAO" + Space(5)	+ MV_PAR12
		_cLinha	+=	"CLVL" + Space(5)		+ MV_PAR12
		_cLinha	+=	"DCLVL" + Space(35)		+ MV_PAR12
		_cLinha	+=	"CONTA" + Space(15)		+ MV_PAR12
		_cLinha	+=	"DCONTA" + Space(34)	+ MV_PAR12
		_cLinha	+=	"QUANT" + Space(10)		+ MV_PAR12
		_cLinha	+=	"CUSTO" + Space(15)		+ MV_PAR12
		_cLinha	+=	"ICONTA" + Space(9)		+ MV_PAR12
		_cLinha	+=	"DICONTA" + Space(33)	+ MV_PAR12
		_cLinha	+=	"DESCR_PC" + Space(142)	+ MV_PAR12

		fWrite(nHdl,_cLinha+HpEnter)

	EndIf

	While !Eof()

		ckContad ++
		IncProc("Processamento1: " + Alltrim(Str(ckContad)))

		If MV_PAR11 == 2

			oExcel:AddRow(nxPlan, nxTabl, { PK08->EMPR          ,;
			PK08->TABL                                          ,;
			PK08->PERIODO                                       ,;
			stod(PK08->DATREF)                                  ,;
			PK08->TES                                           ,;
			PK08->CF                                            ,;
			PK08->DOC                                           ,;
			PK08->PRODUT                                        ,;
			PK08->DESCR                                         ,;
			PK08->GRUPO                                         ,;
			PK08->DGRUPO                                        ,;
			PK08->UM                                            ,;
			PK08->LOC                                           ,;
			PK08->MATRIC_FUNC                                   ,;
			PK08->NOME_FUNC                                     ,;
			PK08->CLVL_FUNC                                     ,;
			PK08->SETOR                                         ,;
			PK08->TAG                                           ,;
			PK08->DTAG                                          ,;
			PK08->AREA                                          ,;
			PK08->APLIC                                         ,;
			PK08->APLICACAO                                     ,;
			PK08->CLVL                                          ,;
			PK08->DCLVL                                         ,;
			PK08->CONTA                                         ,;
			PK08->DCONTA                                        ,;
			PK08->QUANT                                         ,;
			PK08->CUSTO                                         ,;
			PK08->ICONTA                                        ,;
			PK08->DICONTA                                       ,;
			PK08->DESCRPC                                       })

		Else

			_cLinha	:=	Iif(Len(PK08->EMPR) > 2, SubStr(PK08->EMPR,1,2), Iif(Len(PK08->EMPR) == 2, PK08->EMPR, PK08->EMPR + Space(2 - Len(PK08->EMPR)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->TABL) > 6, SubStr(PK08->TABL,1,6), Iif(Len(PK08->TABL) == 6, PK08->TABL, PK08->TABL + Space(6 - Len(PK08->TABL)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->PERIODO) > 6, SubStr(PK08->PERIODO,1,6), Iif(Len(PK08->PERIODO) == 6, PK08->PERIODO, PK08->PERIODO + Space(6 - Len(PK08->PERIODO)))) + MV_PAR12
			_cLinha	+=	Iif(Len(Dtoc(stod(PK08->DATREF))) > 8, SubStr(Dtoc(stod(PK08->DATREF)),1,8), Iif(Len(Dtoc(stod(PK08->DATREF))) == 8, Dtoc(stod(PK08->DATREF)), Dtoc(stod(PK08->DATREF)) + Space(8 - Len(Dtoc(stod(PK08->DATREF)))))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->TES) > 3, SubStr(PK08->TES,1,3), Iif(Len(PK08->TES) == 3, PK08->TES, PK08->TES + Space(3 - Len(PK08->TES)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->CF) > 5, SubStr(PK08->CF,1,5), Iif(Len(PK08->CF) == 5, PK08->CF, PK08->CF + Space(5 - Len(PK08->CF)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->DOC) > 9, SubStr(PK08->DOC,1,9), Iif(Len(PK08->DOC) == 9, PK08->DOC, PK08->DOC + Space(9 - Len(PK08->DOC)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->PRODUT) > 15, SubStr(PK08->PRODUT,1,15), Iif(Len(PK08->PRODUT) == 15, PK08->PRODUT, PK08->PRODUT + Space(15 - Len(PK08->PRODUT)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->DESCR) > 70, SubStr(PK08->DESCR,1,70), Iif(Len(PK08->DESCR) == 70, PK08->DESCR, PK08->DESCR + Space(70 - Len(PK08->DESCR)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->GRUPO) > 4, SubStr(PK08->GRUPO,1,4), Iif(Len(PK08->GRUPO) == 4, PK08->GRUPO, PK08->GRUPO + Space(4 - Len(PK08->GRUPO)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->DGRUPO) > 30, SubStr(PK08->DGRUPO,1,30), Iif(Len(PK08->DGRUPO) == 30, PK08->DGRUPO, PK08->DGRUPO + Space(30 - Len(PK08->DGRUPO)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->UM) > 2, SubStr(PK08->UM,1,2), Iif(Len(PK08->UM) == 2, PK08->UM, PK08->UM + Space(2 - Len(PK08->UM)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->LOC) > 2, SubStr(PK08->LOC,1,2), Iif(Len(PK08->LOC) == 2, PK08->LOC, PK08->LOC + Space(2 - Len(PK08->LOC)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->MATRIC_FUNC) > 8, SubStr(PK08->MATRIC_FUNC,1,8), Iif(Len(PK08->MATRIC_FUNC) == 8, PK08->MATRIC_FUNC, PK08->MATRIC_FUNC + Space(8 - Len(PK08->MATRIC_FUNC)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->NOME_FUNC) > 30, SubStr(PK08->NOME_FUNC,1,30), Iif(Len(PK08->NOME_FUNC) == 30, PK08->NOME_FUNC, PK08->NOME_FUNC + Space(30 - Len(PK08->NOME_FUNC)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->CLVL_FUNC) > 9, SubStr(PK08->CLVL_FUNC,1,9), Iif(Len(PK08->CLVL_FUNC) == 9, PK08->CLVL_FUNC, PK08->CLVL_FUNC + Space(9 - Len(PK08->CLVL_FUNC)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->SETOR) > 100, SubStr(PK08->SETOR,1,100), Iif(Len(PK08->SETOR) == 100, PK08->SETOR, PK08->SETOR + Space(100 - Len(PK08->SETOR)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->TAG) > 12, SubStr(PK08->TAG,1,12), Iif(Len(PK08->TAG) == 12, PK08->TAG, PK08->TAG + Space(12 - Len(PK08->TAG)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->DTAG) > 200, SubStr(PK08->DTAG,1,200), Iif(Len(PK08->DTAG) == 200, PK08->DTAG, PK08->DTAG + Space(200 - Len(PK08->DTAG)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->AREA) > 30, SubStr(PK08->AREA,1,30), Iif(Len(PK08->AREA) == 30, PK08->AREA, PK08->AREA + Space(30 - Len(PK08->AREA)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->APLIC) > 1, SubStr(PK08->APLIC,1,1), Iif(Len(PK08->APLIC) == 1, PK08->APLIC, PK08->APLIC + Space(1 - Len(PK08->APLIC)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->APLICACAO) > 14, SubStr(PK08->APLICACAO,1,14), Iif(Len(PK08->APLICACAO) == 14, PK08->APLICACAO, PK08->APLICACAO + Space(14 - Len(PK08->APLICACAO)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->CLVL) > 9, SubStr(PK08->CLVL,1,9), Iif(Len(PK08->CLVL) == 9, PK08->CLVL, PK08->CLVL + Space(9 - Len(PK08->CLVL)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->DCLVL) > 40, SubStr(PK08->DCLVL,1,40), Iif(Len(PK08->DCLVL) == 40, PK08->DCLVL, PK08->DCLVL + Space(40 - Len(PK08->DCLVL)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->CONTA) > 20, SubStr(PK08->CONTA,1,20), Iif(Len(PK08->CONTA) == 20, PK08->CONTA, PK08->CONTA + Space(20 - Len(PK08->CONTA)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->DCONTA) > 40, SubStr(PK08->DCONTA,1,40), Iif(Len(PK08->DCONTA) == 40, PK08->DCONTA, PK08->DCONTA + Space(40 - Len(PK08->DCONTA)))) + MV_PAR12
			_cLinha	+=	Iif(Len(AllTrim(StrTran(Str(PK08->QUANT),".",","))) > 15, SubStr(AllTrim(StrTran(Str(PK08->QUANT),".",",")),1,15), Iif(Len(AllTrim(StrTran(Str(PK08->QUANT),".",","))) == 15, AllTrim(StrTran(Str(PK08->QUANT),".",",")), Space(15 - Len(AllTrim(StrTran(Str(PK08->QUANT),".",",")))) + AllTrim(StrTran(Str(PK08->QUANT),".",",")))) + MV_PAR12
			_cLinha	+=	Iif(Len(AllTrim(StrTran(Str(PK08->CUSTO),".",","))) > 20, SubStr(AllTrim(StrTran(Str(PK08->CUSTO),".",",")),1,20), Iif(Len(AllTrim(StrTran(Str(PK08->CUSTO),".",","))) == 20, AllTrim(StrTran(Str(PK08->CUSTO),".",",")), Space(20 - Len(AllTrim(StrTran(Str(PK08->CUSTO),".",",")))) + AllTrim(StrTran(Str(PK08->CUSTO),".",",")))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->ICONTA) > 15, SubStr(PK08->ICONTA,1,15), Iif(Len(PK08->ICONTA) == 15, PK08->ICONTA, PK08->ICONTA + Space(15 - Len(PK08->ICONTA)))) + MV_PAR12
			_cLinha	+=	Iif(Len(PK08->DICONTA) > 40, SubStr(PK08->DICONTA,1,40), Iif(Len(PK08->DICONTA) == 40, PK08->DICONTA, PK08->DICONTA + Space(40 - Len(PK08->DICONTA)))) + MV_PAR12
			_cLinha	+=	Iif(Len(StrTran(StrTran(AllTrim(PK08->DESCRPC),CHR(13),""),CHR(10),"")) > 150, SubStr(StrTran(StrTran(AllTrim(PK08->DESCRPC),CHR(13),""),CHR(10),""),1,150), Iif(Len(StrTran(StrTran(AllTrim(PK08->DESCRPC),CHR(13),""),CHR(10),"")) == 150, StrTran(StrTran(AllTrim(PK08->DESCRPC),CHR(13),""),CHR(10),""), StrTran(StrTran(AllTrim(PK08->DESCRPC),CHR(13),""),CHR(10),"") + Space(150 - Len(StrTran(StrTran(AllTrim(PK08->DESCRPC),CHR(13),""),CHR(10),""))))) + MV_PAR12

			fWrite(nHdl,_cLinha+HpEnter)

		EndIf

		dbSelectArea("PK08")
		dbSkip()

	End


	PK08->(dbCloseArea())
	Ferase(PKcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(PKcIndex+OrdBagExt())          //indice gerado

	If File("C:\TEMP\"+xArqTemp+".xml")
		If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
		EndIf
	EndIf

	If MV_PAR11 == 2

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
	Else
		fClose(nHdl)
		MsgInfo(_cArqCsv + " Criado com Sucesso!")
		WinExec("NOTEPAD " + _cArqCsv)
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
	aAdd(aRegs,{cPerg,"03","De Grupo                 ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
	aAdd(aRegs,{cPerg,"04","Até Grupo                ?","","","mv_ch4","C",04,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
	aAdd(aRegs,{cPerg,"05","De Classe de Valor       ?","","","mv_ch5","C",09,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","CTH"})
	aAdd(aRegs,{cPerg,"06","Até Classe de Valor      ?","","","mv_ch6","C",09,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","CTH"})
	aAdd(aRegs,{cPerg,"07","De Conta Contábil        ?","","","mv_ch7","C",20,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","CT1"})
	aAdd(aRegs,{cPerg,"08","Até Conta Contábil       ?","","","mv_ch8","C",20,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","CT1"})
	aAdd(aRegs,{cPerg,"09","De TAG                   ?","","","mv_ch9","C",08,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SZC"})
	aAdd(aRegs,{cPerg,"10","Até TAG                  ?","","","mv_cha","C",08,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SZC"})
	aAdd(aRegs,{cPerg,"11","Gerar Txt            	 ?","","","mv_chb","N",01,0,0,"C","","mv_par11","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Caracter Delimitador     ?","","","mv_chc","C",01,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
