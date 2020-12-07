#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA686
@author Marcos Alberto Soprani
@since 23/06/2016
@version 1.0
@description Converte a quantidade de Massa (e/ou Esmalte) UMIDA em SECA
@type function
/*/

/*/{Protheus.doc} BIA686
@author Artur Antunes
@since 11/05/2017
@version 1.1
@description alimentação do campo umidade media
@obs OS 1437-17 
@type function
/*/

User Function BIA686()

	Local plmArea    := GetArea()
	Local plmQtdSeca := 0
	Local plmQtdDigt := 0
	Local plmCodProd := Space(15)
	Local plmNumOp   := Space(13)
	Local plmDtEmis  := ("  /  /  ")
	Local plmPChqUmd := .T.
	Local plmPSemUmd := "Produtos Sem Umidade de estoquecagem para o dia em questão: " + CHR(13) + CHR(10) + CHR(13) + CHR(10)
	Local nMedUmi	 := 0 

	If Alltrim(UPPER(FunName())) == "MATA250"
		plmQtdSeca := M->D3_QUANT
		plmQtdDigt := M->D3_QUANT
		plmCodProd := M->D3_COD
		plmNumOp   := M->D3_OP
		plmDtEmis  := M->D3_EMISSAO
	ElseIf IsInCallStack("U_BIA785")
	
		Return(SC2->C2_QUANT)
		RestArea(plmArea)
	
	Else
		RestArea(plmArea)
		Return ( 0 )

	EndIf

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+plmCodProd))

	SC2->(dbSetOrder(1))
	SC2->(dbSeek(xFilial("SC2")+plmNumOp))

	plmDtRef := DataValida(plmDtEmis, .F.)

	If Alltrim(UPPER(FunName())) == "MATA250" /*.and. cEmpAnt == "01"*/ .and. SB1->B1_GRUPO == "PI01"

		TG007 := " WITH UMIDADE AS (SELECT G1_COD COD, "
		TG007 += "                          G1_COMP COMP, "
		TG007 += "                          ISNULL((SELECT TOP 1 Z02_UMIDAD "
		TG007 += "                                    FROM "+RetSqlName("Z02")+" "
		TG007 += "                                   WHERE Z02_FILIAL = '"+xFilial("Z02")+"' "
		TG007 += "                                     AND Z02_PRODUT = G1_COMP "
		TG007 += "                                     AND Z02_DATREF = '"+dtos(plmDtRef)+"' "
		TG007 += "                                     AND Z02_ORGCLT = '1' "
		TG007 += "                                     AND D_E_L_E_T_ = ' '), 0) UNID "
		TG007 += "                     FROM "+RetSqlName("SG1")+" "
		TG007 += "                    WHERE G1_FILIAL = '"+xFilial("SG1")+"' "
		TG007 += "                      AND G1_COD = '"+plmCodProd+"' "
		TG007 += "                      AND G1_REVINI >= '"+SC2->C2_REVISAO+"' "
		TG007 += "                      AND G1_REVFIM <= '"+SC2->C2_REVISAO+"' "
		TG007 += "                      AND D_E_L_E_T_ = ' ') "
		TG007 += "  SELECT * "
		TG007 += "    FROM UMIDADE "
		TG007 += "   WHERE UNID = 0 "
		TGcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,TG007),'TG07',.F.,.T.)
		dbSelectArea("TG07")
		dbGoTop()
		While !Eof()

			plmPSemUmd += TG07->COMP + CHR(13) + CHR(10)
			plmPChqUmd := .F.

			dbSkip()

		End

		TG07->(dbCloseArea())
		Ferase(TGcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(TGcIndex+OrdBagExt())          //indice gerado

		If plmPChqUmd

			RF004 := " WITH COMPOSIC AS (SELECT G1_COD COD, "
			RF004 += "                          G1_COMP COMP, "
			RF004 += "                          ISNULL((SELECT TOP 1 Z02_UMIDAD "
			RF004 += "                                    FROM "+RetSqlName("Z02")+" "
			RF004 += "                                   WHERE Z02_FILIAL = '"+xFilial("Z02")+"' "
			RF004 += "                                     AND Z02_PRODUT = G1_COMP "
			RF004 += "                                     AND Z02_DATREF = '"+dtos(plmDtRef)+"' "
			RF004 += "                                     AND Z02_ORGCLT = '1' "
			RF004 += "                                     AND D_E_L_E_T_ = ' '), 0) UMIDADE, "
			RF004 += "                          G1_YMISTUR MISTURA, "
			RF004 += "                          "+Alltrim(Str(plmQtdDigt))+" QTD "
			RF004 += "                     FROM "+RetSqlName("SG1")+" "
			RF004 += "                    WHERE G1_FILIAL = '"+xFilial("SG1")+"' "
			RF004 += "                      AND G1_COD = '"+plmCodProd+"' "
			RF004 += "                      AND G1_REVINI >= '"+SC2->C2_REVISAO+"' "
			RF004 += "                      AND G1_REVFIM <= '"+SC2->C2_REVISAO+"' "
			RF004 += "                      AND D_E_L_E_T_ = ' ' "
			RF004 += "                    UNION ALL "
			RF004 += "                   SELECT '"+plmCodProd+"' COD, "
			RF004 += "                          '' COMP, "
			RF004 += "                          10 UMIDADE, "
			RF004 += "                          (SELECT 100 - SUM(G1_YMISTUR) "
			RF004 += "                             FROM "+RetSqlName("SG1")+" "
			RF004 += "                            WHERE G1_FILIAL = '"+xFilial("SG1")+"' "
			RF004 += "                              AND G1_COD = '"+plmCodProd+"' "
			RF004 += "                              AND G1_REVINI >= '"+SC2->C2_REVISAO+"' "
			RF004 += "                              AND G1_REVFIM <= '"+SC2->C2_REVISAO+"' "
			RF004 += "                              AND D_E_L_E_T_ = ' ') MISTURA, "
			RF004 += "                              "+Alltrim(Str(plmQtdDigt))+" QTD) "
			RF004 += " SELECT SUM(QTD_SEM_UMID) QTDSECA, AVG(UMIDADE) MEDIA_UMID "
			RF004 += "   FROM (SELECT *, "
			RF004 += "                QTD * FATOR / TOT QTD_UMID, "
			RF004 += "                (QTD * FATOR / TOT) * (100 - UMIDADE) / 100 QTD_SEM_UMID "
			RF004 += "           FROM (SELECT *, "
			RF004 += "                        (MISTURA/(100-UMIDADE) * 100) FATOR, "
			RF004 += "                        (SELECT SUM((MISTURA/(100-UMIDADE) * 100)) "
			RF004 += "                           FROM COMPOSIC) TOT "
			RF004 += "                   FROM COMPOSIC) AS TABG) AS TRDD "
			RFcIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,RF004),'RF04',.F.,.T.)
			dbSelectArea("RF04")
			dbGoTop()

			plmQtdSeca := Round(RF04->QTDSECA,2)
			nMedUmi	   := RF04->MEDIA_UMID

			RF04->(dbCloseArea())
			Ferase(RFcIndex+GetDBExtension())     //arquivo de trabalho
			Ferase(RFcIndex+OrdBagExt())          //indice gerado

		Else

			plmQtdDigt := 0
			nMedUmi	   := 0
			MsgInfo(plmPSemUmd)

		EndIf

		M->D3_YQTUMID := plmQtdDigt
		M->D3_QTSEGUM := ConvUM(plmCodProd, plmQtdSeca, 0, 2)
		M->D3_YMEDUMI := nMedUmi 

		// Em 31/01/18... foi reestabelecido o filtro para efetuar este tratamento apenas para a empresa 01 até segunda ordem
	ElseIf Alltrim(UPPER(FunName())) $ "MATA250/BIA785" .and. SB1->B1_GRUPO <> "PI01" .and. SB1->B1_TIPO = 'PI' .and. cEmpAnt == "01"

		// Incluída tratativa por Marcos Alberto Soprani em 25/07/16

		RF004 := " WITH COMPOSIC AS (SELECT G1_COD COD, "
		RF004 += "                          G1_COMP COMP, "
		RF004 += "                          ISNULL((SELECT SUM(Z02_UMIDAD * Z02_QTDCRG) / SUM(Z02_QTDCRG) "
		RF004 += "                                    FROM " + RetSqlName("Z02") + " "
		RF004 += "                                   WHERE Z02_FILIAL = '" + xFilial("Z02") + "' "
		RF004 += "                                     AND Z02_PRODUT = G1_COMP "
		RF004 += "                                     AND Z02_DATREF >= '" + dtos(plmDtRef-30) + "' "
		RF004 += "                                     AND Z02_QTDCRG <> 0 "
		RF004 += "                                     AND Z02_ORGCLT = '2' "
		RF004 += "                                     AND D_E_L_E_T_ = ' '), BZ_YUMIDAD) UMIDADE, "
		RF004 += "                          G1_QUANT QUANT, "
		RF004 += "                          " + Alltrim(Str(plmQtdDigt)) + " QTD "
		RF004 += "                     FROM " + RetSqlName("SG1") + " SG1 "
		RF004 += "                    INNER JOIN " + RetSqlName("SBZ") + " SBZ ON BZ_FILIAL = '" + xFilial("SBZ") + "'
		RF004 += "                                         AND BZ_COD = G1_COMP
		RF004 += "                                         AND SBZ.D_E_L_E_T_ = ' '
		RF004 += "                    WHERE G1_FILIAL = '" + xFilial("SG1") + "' "
		RF004 += "                      AND G1_COD = '" + plmCodProd + "' "
		RF004 += "                      AND G1_REVINI >= '" + SC2->C2_REVISAO + "' "
		RF004 += "                      AND G1_REVFIM <= '" + SC2->C2_REVISAO + "' "
		RF004 += "                      AND SG1.D_E_L_E_T_ = ' ') "
		RF004 += " SELECT SUM(QTD_SEM_UMID) QTDSECA "
		RF004 += "   FROM (SELECT *, "
		RF004 += "                QTD * FATOR / TOT QTD_UMID, "
		RF004 += "                (QTD * FATOR / TOT) * (100 - UMIDADE) / 100 QTD_SEM_UMID "
		RF004 += "           FROM (SELECT *, "
		RF004 += "                        (QUANT/(100-UMIDADE) * 100) FATOR, "
		RF004 += "                        (SELECT SUM((QUANT/(100-UMIDADE) * 100)) "
		RF004 += "                           FROM COMPOSIC) TOT "
		RF004 += "                   FROM COMPOSIC) AS TABG) AS TRDD "
		RFcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,RF004),'RF04',.F.,.T.)
		dbSelectArea("RF04")
		dbGoTop()

		plmQtdSeca := Round(RF04->QTDSECA,2)

		RF04->(dbCloseArea())
		Ferase(RFcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(RFcIndex+OrdBagExt())          //indice gerado

		If Alltrim(UPPER(FunName())) <> "BIA785"
			M->D3_YQTUMID := plmQtdDigt
			M->D3_QTSEGUM := ConvUM(plmCodProd, plmQtdSeca, 0, 2)
		EndIf

	EndIf

	RestArea(plmArea)

Return ( plmQtdSeca )
