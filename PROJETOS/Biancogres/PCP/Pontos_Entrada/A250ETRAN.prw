#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} A250ETRAN
@author Marcos Alberto Soprani
@since 24/10/11
@version 1.0
@description O ponto de entrada 'A250ETRAN' é executado após gravação total
.            dos movimentos, na inclusão do apontamento de produção simples
.            usado inicialmente para "setar" o conteudo de uma tread usada
.            pelo ponto de entrada A250FSD4
.            24/04/12 - Implementação para apuração do custo
.             Grava Informações Adcionais para rateio dos valores extras
.            para apuração do custo real
@type function
/*/

User Function A250ETRAN()

	Local xsRecn   := GetArea()
	Local _aAreaSB1	:=	GetArea()
	Local bxUmid   := .F.

	// Implementado por Marcos Alberto em 04/07/12 para baixar as quantidades de MPM referente a UMIDADE média, com base de mês anterior.
	If cEmpAnt <> "06" .and. az_GrpPr == "PI01"

		jh_MesA := stod(Substr(dtos(dDataBase),1,6)+"01")-1
		jh_PriD := Substr(dtos(jh_MesA),1,6) + "01"
		jh_UltD := dtos(Ultimodia(jh_MesA))

		TK001 := " SELECT D4_COD, "
		TK001 += "        D4_OP, "
		TK001 += "        D4_LOCAL, "		
		TK001 += "        C2_QUANT,
		TK001 += "        "+Alltrim(Str(az_QtdPd))+" D3_QUANT,
		TK001 += "        ISNULL((SELECT SUM(Z02_UMIDAD * Z02_QTDCRG) / SUM(Z02_QTDCRG)
		TK001 += "                  FROM " + RetSqlName("Z02")
		TK001 += "                 WHERE Z02_FILIAL = '"+xFilial("Z02")+"'
		TK001 += "                   AND Z02_DATREF BETWEEN '"+jh_PriD+"' AND '"+jh_UltD+"'
		TK001 += "                   AND Z02_PRODUT = D4_COD
		TK001 += "                   AND Z02_QTDCRG <> 0
		TK001 += "                   AND Z02_ORGCLT = '2'
		TK001 += "                   AND D_E_L_E_T_ = ' '), 0) UMIDADE,
		TK001 += "        ISNULL((SELECT BZ_YUMIDAD
		TK001 += "                  FROM " + RetSqlName("SBZ")
		TK001 += "                 WHERE BZ_FILIAL = '"+xFilial("SBZ")+"'
		TK001 += "                   AND BZ_COD = D4_COD
		TK001 += "                   AND D_E_L_E_T_ = ' '), 0) UMIDAD2,
		TK001 += "        D4_TRT,
		TK001 += "        D4_QTDEORI
		TK001 += "   FROM "+RetSqlName("SD4")+" SD4
		TK001 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 ON C2_FILIAL = '"+xFilial("SC2")+"'
		TK001 += "                       AND C2_NUM + C2_ITEM + C2_SEQUEN + '  ' = D4_OP
		TK001 += "                       AND SC2.D_E_L_E_T_ = ' '
		TK001 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"'
		TK001 += "    AND D4_OP = '"+SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN+"'
		TK001 += "    AND SD4.D_E_L_E_T_ = ' '
		TKcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,TK001),'TK01',.F.,.T.)
		dbSelectArea("TK01")
		dbGoTop()
		While !Eof()

			// Tratamento implementado em 17/12/13.
			xrUmidad := TK01->UMIDADE
			If xrUmidad == 0
				xrUmidad := TK01->UMIDAD2
			EndIf

			// Requisição da proporção da UMIDADE para Apropriação de custo da MASSA
			If xrUmidad > 0

				bxUmid   := .T.

				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+TK01->D4_COD))
				jh_Quant := TK01->D3_QUANT / TK01->C2_QUANT * TK01->D4_QTDEORI
				jh_Adici := Round((jh_Quant / ((100-xrUmidad)/100)) - jh_Quant, 2)

				RecLock("SD3",.T.)
				SD3->D3_FILIAL   :=  xFilial("SD3")
				SD3->D3_TM       :=  "999"
				SD3->D3_OP       :=  SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
				SD3->D3_COD      :=  TK01->D4_COD
				SD3->D3_QUANT    :=  jh_Adici
				SD3->D3_QTSEGUM  :=  ConvUm(SD3->D3_COD, SD3->D3_QUANT, 0, 2)
				SD3->D3_UM       :=  SB1->B1_UM
				SD3->D3_SEGUM    :=  SB1->B1_SEGUM
				SD3->D3_GRUPO    :=  SB1->B1_GRUPO
				SD3->D3_LOCAL    :=  TK01->D4_LOCAL
				SD3->D3_TRT      :=  TK01->D4_TRT
				SD3->D3_CC       :=  "3000"
				SD3->D3_CLVL     :=  az_clvl
				SD3->D3_CONTA    :=  SB1->B1_YCTRIND
				SD3->D3_TIPO     :=  SB1->B1_TIPO
				SD3->D3_EMISSAO  :=  az_DtEms
				SD3->D3_DOC      :=  az_NmDoc
				SD3->D3_NIVEL    :=  SC2->C2_NIVEL
				SD3->D3_YOBS     :=  "Umid: " + Transform(xrUmidad, "@E 999.99999")
				MsUnlock()
				nRegD3 := Recno()

				SB2->(DbSetOrder(1))

				If SB2->(DbSeek(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL))
					Reclock("SB2",.F.)
					SB2->B2_QATU	:=	B2_QATU - jh_Adici
					SB2->B2_QTSEGUM :=  ConvUM(SB2->B2_COD, SB2->B2_QATU, 0, 8)
					SB2->(MsUnlock())
				EndIf

				dbSelectArea("SD3")
				dbGoto(nRegD3)
				RecLock("SD3",.F.)
				Replace D3_CF      With "RE1"
				Replace D3_NUMSEQ  With az_NmSeq
				Replace D3_IDENT   With az_Ident
				Replace D3_CONTA   With za_CtaPI
				Replace D3_YAPLIC  With az_Aplic
				Replace D3_YDRIVER  With az_Driver
				Replace D3_YTAG    With az_Tag
				Replace D3_YMATRIC With az_Matrc
				Replace D3_YEMPR   With az_Emprx
				MsUnlock()

				If SB2->B2_QATU < 0
					Aviso('A250ETRAN(1)', 'A baixa complementar da umidade deixou o estoque do produto: ' + TK01->D4_COD + ' negativo em: ' + Transform(SB2->B2_QATU, "@E 999,999,999.99999") + ' Favor alinhar o setor de custos!!!',{'Ok'})
				EndIf

			Else

				bxUmid   := .F.

			EndIf

			dbSelectArea("TK01")
			dbSkip()

		End
		TK01->(dbCloseArea())
		Ferase(TKcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(TKcIndex+OrdBagExt())          //indice gerado

		// Tratamento efetuado em 29/04/14 por Marcos Alberto Soprani.
		If !bxUmid

			Aviso('A250ETRAN','Problema ao efetuar a baixa complementar de MPM proveniente da UMIDADE. Este apontamento de produção deverá ser excluído: documento '+az_NmDoc+'; em seguinda, verificar qual (ou quais) MPMs estão sem UMIDADE cadastrada - efetuar o cadastro; por fim, efetuar o apontamento de produção do PI-MASSA novamente.',{'Ok'})

		Else

			Aviso('A250ETRAN','Baixa da umidade referentes as MPMs efetuada com sucesso!',{'Ok'})

		EndIf


	ElseIf cEmpAnt <> "06" .and. az_TipPr == "PI" .and. !Alltrim(az_GrpPr) $ "PI01"

		qiProdSeca := 0
		QI002 := " WITH CTRLUMID AS ( "
		QI002 += "                   SELECT D3_TM TM, "
		QI002 += "                          D3_COD COD, "
		QI002 += "                          D3_OP OP, "
		QI002 += "                          D3_QUANT QUANT, "
		QI002 += "                          ISNULL((SELECT SUM(Z02_UMIDAD * Z02_QTDCRG) / SUM(Z02_QTDCRG) "
		QI002 += "                                    FROM " + RetSqlName("Z02") + " WITH (NOLOCK) "
		QI002 += "                                   WHERE Z02_FILIAL = '" + xFilial("Z02") + "' "
		QI002 += "                                     AND Z02_PRODUT = D3_COD "
		QI002 += "                                     AND Z02_DATREF >= '" + dtos(az_DtEms-30) + "' "
		QI002 += "                                     AND Z02_QTDCRG <> 0 "
		QI002 += "                                     AND Z02_LOCAL = D3_LOCAL "
		QI002 += "                                     AND Z02_ORGCLT = '2' "
		QI002 += "                                     AND D_E_L_E_T_ = ' '), -9999) UMIDLAB, "
		QI002 += "                          ISNULL((SELECT SUM(Z02_UMIDAD * Z02_QTDCRG) / SUM(Z02_QTDCRG) "
		QI002 += "                                    FROM (	"
		QI002 += "                                    SELECT TOP 3 *	"
		QI002 += "                                    FROM " + RetSqlName("Z02") + " WITH (NOLOCK) "
		QI002 += "                                   WHERE Z02_FILIAL = '" + xFilial("Z02") + "' "
		QI002 += "                                     AND Z02_PRODUT = D3_COD "
		QI002 += "                                     AND Z02_DATREF >= '" + dtos(az_DtEms-360) + "' "
		QI002 += "                                     AND Z02_QTDCRG <> 0 "
		QI002 += "                                     AND Z02_LOCAL = D3_LOCAL "
		QI002 += "                                     AND Z02_ORGCLT = '2' "
		QI002 += "                                     AND D_E_L_E_T_ = ' ' "
		QI002 += "                                     ORDER BY Z02_DATREF) A), -9999) UMIDHST, "		
		QI002 += "                          ISNULL((SELECT BZ_YUMIDAD "
		QI002 += "                                    FROM " + RetSqlName("SBZ") + " WITH (NOLOCK) "
		QI002 += "                                   WHERE BZ_FILIAL = '" + xFilial("SBZ") + "' "
		QI002 += "                                     AND BZ_COD = D3_COD "
		QI002 += "                                     AND D_E_L_E_T_ = ' '), 0) UMIDPAD, "
		QI002 += "                          R_E_C_N_O_ REGSD3 "
		QI002 += "                     FROM " + RetSqlName("SD3") + " SD3 WITH (NOLOCK) "
		QI002 += "                    WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
		QI002 += "                      AND D3_NUMSEQ = '" + az_NmSeq + "' "
		QI002 += "                      AND SD3.D_E_L_E_T_ = ' ' "
		QI002 += "                  ) "
		QI002 += " SELECT *, "
		QI002 += "        CASE "
		QI002 += "          WHEN UMIDLAB >= 0 THEN 'LAB' "
		QI002 += "          WHEN UMIDHST >= 0 THEN 'HST' "
		QI002 += "          ELSE 'PAD' "
		QI002 += "        END TPUMID, "
		QI002 += "        CASE "
		QI002 += "          WHEN UMIDLAB >= 0 THEN UMIDLAB "
		QI002 += "          WHEN UMIDHST >= 0 THEN UMIDHST "
		QI002 += "          ELSE UMIDPAD "
		QI002 += "        END PERCUMID, "
		QI002 += "        CASE "
		QI002 += "          WHEN UMIDLAB >= 0 THEN QUANT * (100-UMIDLAB) / 100 "
		QI002 += "          WHEN UMIDHST >= 0 THEN QUANT * (100-UMIDHST) / 100 "
		QI002 += "          ELSE QUANT * (100-UMIDPAD) / 100 "
		QI002 += "        END QTDSECA "
		QI002 += "   FROM CTRLUMID "
		QI002 += "  ORDER BY TM DESC, REGSD3 "
		QIcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QI002),'QI02',.F.,.T.)
		dbSelectArea("QI02")
		dbGoTop()
		While !Eof()

			If QI02->TM == "999"

				dbSelectArea("SD3")
				dbGoto(QI02->REGSD3)
				RecLock("SD3",.F.)
				Replace D3_YTPUMID With QI02->TPUMID
				Replace D3_YPRUMID With QI02->PERCUMID
				Replace D3_YQTSECA With QI02->QTDSECA
				MsUnlock()

				qiProdSeca += QI02->QTDSECA

			Else

				dbSelectArea("SD3")
				dbGoto(QI02->REGSD3)
				RecLock("SD3",.F.)
				Replace D3_YQTUMID With QI02->QUANT
				Replace D3_QUANT   With qiProdSeca
				Replace D3_QTSEGUM With ConvUM(QI02->COD, qiProdSeca, 0, 8)
				Replace D3_YMEDUMI With ( QI02->QUANT - qiProdSeca ) / QI02->QUANT
				MsUnlock()
				//A240Atu()

				SB2->(DbSetOrder(1))

				If SB2->(DbSeek(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL))
					Reclock("SB2",.F.)
					SB2->B2_QATU	:=	B2_QATU - SD3->D3_YQTUMID + SD3->D3_QUANT
					SB2->B2_QTSEGUM :=  ConvUM(SB2->B2_COD, SB2->B2_QATU, 0, 8)
					SB2->(MsUnlock())
				EndIf
				dbSelectArea("SD3")
				dbGoto(QI02->REGSD3)
				RecLock("SD3",.F.)
				Replace D3_CF      With "PR0"
				Replace D3_NUMSEQ  With az_NmSeq
				MsUnlock()

			EndIf

			dbSelectArea("QI02")
			dbSkip()

		End
		QI02->(dbCloseArea())
		Ferase(QIcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(QIcIndex+OrdBagExt())          //indice gerado

	ElseIf cEmpAnt == "06" .and. az_TipPr == "PI" .and. az_GrpPr == "108B"

		// Todos este tratamento foi implementado em 29/03/21, trazendo a PI01 os scripts originais

		jh_MesA := dDataBase
		jh_PriD := dtos(jh_MesA)
		jh_UltD := dtos(jh_MesA)

		TK001 := " SELECT D4_COD, "
		TK001 += "        D4_OP, "
		TK001 += "        D4_LOCAL, "		
		TK001 += "        C2_QUANT,
		TK001 += "        " + Alltrim(Str(az_QtdPd)) + " D3_QUANT,
		TK001 += "        ISNULL((SELECT SUM(Z02_UMIDAD * Z02_QTDCRG) / SUM(Z02_QTDCRG)
		TK001 += "                  FROM " + RetSqlName("Z02") + " Z02(NOLOCK)
		TK001 += "                 WHERE Z02_FILIAL = '" + xFilial("Z02") + "'
		TK001 += "                   AND Z02_DATREF BETWEEN '" + jh_PriD + "' AND '" + jh_UltD + "'
		TK001 += "                   AND Z02_PRODUT = D4_COD
		TK001 += "                   AND Z02_QTDCRG <> 0
		TK001 += "                   AND Z02_ORGCLT = '2'
		TK001 += "                   AND D_E_L_E_T_ = ' '), 0) UMIDADE,
		TK001 += "        ISNULL((SELECT BZ_YUMIDAD
		TK001 += "                  FROM " + RetSqlName("SBZ") + " SBZ(NOLOCK)
		TK001 += "                 WHERE BZ_FILIAL = '" + xFilial("SBZ") + "'
		TK001 += "                   AND BZ_COD = D4_COD
		TK001 += "                   AND D_E_L_E_T_ = ' '), 0) UMIDAD2,
		TK001 += "        D4_TRT,
		TK001 += "        D4_QTDEORI
		TK001 += "   FROM " + RetSqlName("SD4") + " SD4(NOLOCK)
		TK001 += "  INNER JOIN " + RetSqlName("SC2") + " SC2(NOLOCK) ON C2_FILIAL = '" + xFilial("SC2") + "'
		TK001 += "                       AND C2_NUM + C2_ITEM + C2_SEQUEN + '  ' = D4_OP
		TK001 += "                       AND SC2.D_E_L_E_T_ = ' '
		TK001 += "  WHERE D4_FILIAL = '" + xFilial("SD4") + "'
		TK001 += "    AND D4_OP = '" + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + "'
		TK001 += "    AND SD4.D_E_L_E_T_ = ' '
		TKcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,TK001),'TK01',.F.,.T.)
		dbSelectArea("TK01")
		dbGoTop()
		While !Eof()

			// Tratamento implementado em 17/12/13.
			xrUmidad := TK01->UMIDADE
			If xrUmidad == 0
				xrUmidad := TK01->UMIDAD2
			EndIf

			// Requisição da proporção da UMIDADE para Apropriação de custo da MASSA
			If xrUmidad > 0

				bxUmid   := .T.

				SB1->(dbSetOrder(1))
				SB1->(dbSeek(xFilial("SB1")+TK01->D4_COD))
				jh_Quant := TK01->D3_QUANT / TK01->C2_QUANT * TK01->D4_QTDEORI
				jh_Adici := Round((jh_Quant / ((100-xrUmidad)/100)) - jh_Quant, 2)

				RecLock("SD3",.T.)
				SD3->D3_FILIAL   :=  xFilial("SD3")
				SD3->D3_TM       :=  "999"
				SD3->D3_OP       :=  SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
				SD3->D3_COD      :=  TK01->D4_COD
				SD3->D3_QUANT    :=  jh_Adici
				SD3->D3_QTSEGUM  :=  ConvUm(SD3->D3_COD, SD3->D3_QUANT, 0, 2)
				SD3->D3_UM       :=  SB1->B1_UM
				SD3->D3_SEGUM    :=  SB1->B1_SEGUM
				SD3->D3_GRUPO    :=  SB1->B1_GRUPO
				SD3->D3_LOCAL    :=  TK01->D4_LOCAL
				SD3->D3_TRT      :=  TK01->D4_TRT
				SD3->D3_CC       :=  "3000"
				SD3->D3_CLVL     :=  az_clvl
				SD3->D3_CONTA    :=  SB1->B1_YCTRIND
				SD3->D3_TIPO     :=  SB1->B1_TIPO
				SD3->D3_EMISSAO  :=  az_DtEms
				SD3->D3_DOC      :=  az_NmDoc
				SD3->D3_NIVEL    :=  SC2->C2_NIVEL
				SD3->D3_YOBS     :=  "Umid: " + Transform(xrUmidad, "@E 999.99999")
				MsUnlock()
				nRegD3 := Recno()

				SB2->(DbSetOrder(1))

				If SB2->(DbSeek(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL))
					Reclock("SB2",.F.)
					SB2->B2_QATU	:=	B2_QATU - jh_Adici
					SB2->B2_QTSEGUM :=  ConvUM(SB2->B2_COD, SB2->B2_QATU, 0, 8)
					SB2->(MsUnlock())
				EndIf

				dbSelectArea("SD3")
				dbGoto(nRegD3)
				RecLock("SD3",.F.)
				Replace D3_CF      With "RE1"
				Replace D3_NUMSEQ  With az_NmSeq
				Replace D3_IDENT   With az_Ident
				Replace D3_CONTA   With za_CtaPI
				Replace D3_YAPLIC  With az_Aplic
				Replace D3_YDRIVER  With az_Driver
				Replace D3_YTAG    With az_Tag
				Replace D3_YMATRIC With az_Matrc
				Replace D3_YEMPR   With az_Emprx
				MsUnlock()

				If SB2->B2_QATU < 0
					Aviso('A250ETRAN(1)', 'A baixa complementar da umidade deixou o estoque do produto: ' + TK01->D4_COD + ' negativo em: ' + Transform(SB2->B2_QATU, "@E 999,999,999.99999") + ' Favor alinhar o setor de custos!!!',{'Ok'})
				EndIf

			Else

				bxUmid   := .F.

			EndIf

			dbSelectArea("TK01")
			dbSkip()

		End
		TK01->(dbCloseArea())
		Ferase(TKcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(TKcIndex+OrdBagExt())          //indice gerado

		// Tratamento efetuado em 29/04/14 por Marcos Alberto Soprani.
		If !bxUmid

			Aviso('A250ETRAN','Problema ao efetuar a baixa complementar de MPM proveniente da UMIDADE. Este apontamento de produção deverá ser excluído: documento '+az_NmDoc+'; em seguinda, verificar qual (ou quais) MPMs estão sem UMIDADE cadastrada - efetuar o cadastro; por fim, efetuar o apontamento de produção do PI-MASSA novamente.',{'Ok'})

		Else

			Aviso('A250ETRAN','Baixa da umidade referentes as MPMs efetuada com sucesso!',{'Ok'})

		EndIf

	EndIf

	//===================================================================================================
	//+   Tratamento implementado em 21/08/15 para atender ao RI 0140-15                                +
	//===================================================================================================
	UP002 := " UPDATE "+RetSqlName("SD4")+" SET D4_QUANT = (C2_QUANT - C2_QUJE) * (D4_QTDEORI / C2_QUANT)
	UP002 += "   FROM "+RetSqlName("SD4")+" SD4
	UP002 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 ON C2_FILIAL = '"+xFilial("SC2")+"'
	UP002 += "                       AND C2_NUM = SUBSTRING(D4_OP,1,6)
	UP002 += "                       AND C2_ITEM = SUBSTRING(D4_OP,7,2)
	UP002 += "                       AND C2_SEQUEN = SUBSTRING(D4_OP,9,3)
	UP002 += "                       AND C2_DATRF = '        '
	UP002 += "                       AND SC2.D_E_L_E_T_ = ' '
	UP002 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"'
	UP002 += "    AND D4_QUANT = 0
	UP002 += "    AND D4_OP = '"+az_OpNum+"'
	UP002 += "    AND SD4.D_E_L_E_T_ = ' '
	TCSQLExec(UP002)

	RestArea(xsRecn)

	RestArea(_aAreaSB1)

Return
