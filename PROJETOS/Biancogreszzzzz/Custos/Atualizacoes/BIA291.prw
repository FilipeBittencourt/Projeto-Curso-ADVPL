#include "rwmake.ch"
#include "ap5mail.ch"
#include "TOTVS.CH"
#include "topconn.ch"
#Include "PROTHEUS.CH"

/*/{Protheus.doc} BIA291
@author Marcos Alberto Soprani
@since 11/04/12
@version 1.0
@description Diversas Rotina para extração de dados para custos
.            A rotina BIA299 derivou destas definições. É necessário ficar
.            atento a alterações futuras com ambas a rotinas - 16/07/12
@type function
/*/

User Function BIA291()

	Private oDlgApCt
	Private oGroup1
	Private oRadMenu1
	Private nRadMenu1 := 1
	Private aDados2   := {}
	Private lNegEstr  := GETMV("MV_NEGESTR")

	DEFINE MSDIALOG oDlgApCt TITLE "Apuração de Custo" FROM 000, 000  TO 400, 500 COLORS 0, 16777215 PIXEL

	@ 004, 006 GROUP oGroup1 TO 175, 190 PROMPT " Apuração de Custo " OF oDlgApCt COLOR 0, 16777215 PIXEL
	@ 016, 012 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "Requisições (MATR230)","Est. Simplif. (MATR225)","Produção (BIA060)","Mov. C.Custo (CTB280X)","Balancete (CTBR040)","Peso Ticket Produto (Wy)","Estoque por Grupo (Wy)","Gastos c/ Mao de Obra(Ms)","Custo por TAG (Wy)","Receita Liquida (Wy)","Receita Liquida - p/ Empresa (Wy)","Vendas Mundi (Rc)","Mov. CLVL New(Ms)","Peso Ticket c/ Custo (Ms)", "Mov. CLVL em Linha (Ms)", "Mvto de Estoque (Ms)" SIZE 177, 073 OF oDlgApCt COLOR 0, 16777215 PIXEL
	@ 007, 210 BUTTON oButton1 PROMPT "Gerar" SIZE 037, 012 OF oDlgApCt ACTION Processa({|| fGrPlan() }) PIXEL
	@ 027, 210 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlgApCt ACTION oDlgApCt:End() PIXEL

	ACTIVATE MSDIALOG oDlgApCt

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fGrPlan   ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 11/04/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          ¦ Responsável pela Processamento dos dados                   ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fGrPlan()

	Local xxn

	aDados2 := {}

	// Liberado a pedido do Vagner com ciencia do Jecimar em substituição ao MATR230 que o Vagner tinha acesso e estava muito lento. Por Marcos Alberto Soprani 10/04/15
	// Em 26/04/16, incluído Wadson (000778) em atendimento a OS effettivo 1454-16.
	If __cUserID $ "000749"

		If nRadMenu1 <> 1

			MsgINFO("Opção não disponível para você. Favor Verificar!!!")
			Return

		EndIf

	Else

		If !U_VALOPER("045") .and. nRadMenu1 <> 6
			MsgINFO("Opção não disponível para você. Favor Verificar!!!", "OP 045")
			Return
		EndIf		

	EndIf

	//If __cUserID $ "000605" .and. !(nRadMenu1 == 1 .or. nRadMenu1 == 2 .or. nRadMenu1 == 3 .or. nRadMenu1 == 4 .or. nRadMenu1 == 7 .or. nRadMenu1 == 9)
	//	MsgINFO("Opção não disponível para você. Favor Verificar!!!")
	//	Return
	//EndIf

	zsAlias := Alias()

	If nRadMenu1 == 1                                                 //Requisições
		***************************************************************************

		fPerg := "BIA29107"
		ktNomArq := "requisicao"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		Vld01Prg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		A0001 := " SELECT PERIODO,
		A0001 += "        ROW_NUMBER() OVER(ORDER BY CC+CODIGO) SEQ,
		A0001 += "        LINHA,
		A0001 += "        CC,
		A0001 += "        GRUPO,
		A0001 += "        COD,
		A0001 += "        CODIGO,
		A0001 += "        DESCR,
		A0001 += "        SUM(QUANT) QUANT,
		A0001 += "        SUM(PU) PU,
		A0001 += "        SUM(TOTAL) TOTAL,
		A0001 += "        B1_CONV FATOR,
		A0001 += "        D3_CONTA CCONTABIL
		A0001 += "   FROM (SELECT SUBSTRING(D3_EMISSAO,1,6) PERIODO,
		A0001 += "                0 SEQ,
		A0001 += "                ' ' LINHA,
		A0001 += "                D3_CLVL CC,
		A0001 += "                D3_GRUPO GRUPO,
		A0001 += "                SUBSTRING(D3_COD, 4, 4) COD,
		A0001 += "                D3_COD CODIGO,
		A0001 += "                B1_DESC DESCR,
		A0001 += "                CASE
		A0001 += "                  WHEN D3_TM <= '500' THEN D3_QUANT * ( -1 )
		A0001 += "                  ELSE D3_QUANT
		A0001 += "                END QUANT,
		A0001 += "                0 PU,
		A0001 += "                CASE
		A0001 += "                  WHEN D3_TM <= '500' THEN D3_CUSTO1 * ( -1 )
		A0001 += "                  ELSE D3_CUSTO1
		A0001 += "                END TOTAL,
		A0001 += "                B1_CONV,
		A0001 += "                D3_CONTA
		A0001 += "           FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
		A0001 += "          INNER JOIN "+RetSqlName("SB1")+" SB1 WITH (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"'
		A0001 += "                               AND B1_COD = D3_COD
		A0001 += "                               AND SB1.D_E_L_E_T_ = ' '
		A0001 += "          WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		A0001 += "            AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "            AND D3_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
		A0001 += "            AND D3_CLVL BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
		A0001 += "            AND SUBSTRING(D3_CF, 2, 1) = 'E'
		A0001 += "            AND SUBSTRING(D3_CF, 3, 1) <> '3'
		A0001 += "            AND D3_ESTORNO = ' '
		A0001 += "            AND SD3.D_E_L_E_T_ = ' ') AS REQUIS
		A0001 += "  GROUP BY PERIODO,
		A0001 += "           SEQ,
		A0001 += "           LINHA,
		A0001 += "           CC,
		A0001 += "           GRUPO,
		A0001 += "           COD,
		A0001 += "           CODIGO,
		A0001 += "           DESCR,
		A0001 += "           B1_CONV,
		A0001 += "           D3_CONTA
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			kg_Medio := 0
			If A001->QUANT == 0
				kg_Medio := A001->TOTAL
			Else
				kg_Medio := A001->TOTAL/A001->QUANT
			EndIf

			If A001->QUANT <> 0 .or. A001->TOTAL <> 0
				aAdd(aDados2, { A001->PERIODO,;
				A001->SEQ,;
				A001->LINHA,;
				A001->CC,;
				A001->GRUPO,;
				A001->COD,;
				A001->CODIGO,;
				StrTran( Substr(A001->DESCR,1,50) ,";","-"),;
				Transform(A001->QUANT  ,"@E 999,999,999.9999"),;
				Transform(kg_Medio     ,"@E 999,999,999.9999"),;
				Transform(A001->TOTAL  ,"@E 999,999,999.9999"),;
				Transform(A001->FATOR  ,"@E 999,999,999.9999"),;
				A001->CCONTABIL})
			EndIf

			dbSelectArea("A001")
			dbSkip()
		End
		aStru1 := ("A001")->(dbStruct())
		A001->(dbCloseArea())

	ElseIf nRadMenu1 == 2                                               //Estrutura
		***************************************************************************

		aStru1   := { {"SEQ"      , "C", 10, 0},;
		{              "FORMATO"  , "C", 15, 0},;
		{              "PRODUTO"  , "C", 15, 0},;
		{              "DESCRPA"  , "C", 25, 0},;
		{              "PRODUCAO" , "N", 18, 8},;
		{              "NIVEL"    , "C", 02, 0},;
		{              "MATERIAL" , "C", 15, 0},;
		{              "DESCRIC"  , "C", 50, 0},;
		{              "PERCENT"  , "N", 18, 8},;
		{              "QUANT"    , "N", 18, 8} }

		dgtSeq := 0
		fPerg := "BIA29103"
		ktNomArq := "estrutura"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		Vld03Prg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		A0001 := " SELECT *
		A0001 += "   FROM (SELECT CODIGO,
		A0001 += "                SUM(QUANT) QUANT
		A0001 += "           FROM (SELECT SUBSTRING(D3_COD, 1, 7) CODIGO,
		A0001 += "                        CASE
		A0001 += "                          WHEN D3_TM > '500' THEN D3_QUANT * ( -1 )
		A0001 += "                          ELSE D3_QUANT
		A0001 += "                        END QUANT
		A0001 += "                   FROM "+RetSqlName("SD3")+" SD3
		A0001 += "                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		A0001 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "                    AND ( D3_TM IN( '001', '500', '501' ) OR D3_YORIMOV = 'PR0' OR (D3_EMISSAO >= '20140101' AND D3_TIPO = 'PA' AND D3_TM = '010') )
		A0001 += "                    AND D3_ESTORNO = ' '
		A0001 += "                    AND SD3.D_E_L_E_T_ = ' '
		A0001 += "                  UNION ALL
		A0001 += "                 SELECT SUBSTRING(D3_COD, 1, 7) CODIGO,
		A0001 += "                        CASE
		A0001 += "                          WHEN D3_TM > '500' THEN D3_QUANT * ( -1 )
		A0001 += "                          ELSE D3_QUANT
		A0001 += "                        END QUANT
		A0001 += "                   FROM "+RetSqlName("SD3")+" SD3
		A0001 += "                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		A0001 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "                    AND D3_TM = '711'
		A0001 += "                    AND D3_TIPO = 'PA'
		A0001 += "                    AND D3_ESTORNO = ' '
		A0001 += "                    AND SD3.D_E_L_E_T_ = ' '
		A0001 += "                    ) AS REQUIS
		A0001 += "          GROUP BY CODIGO) AS REQFIM
		A0001 += "  WHERE QUANT <> 0 AND RIGHT(CODIGO,4) <> '000C'
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			If A001->QUANT > 0

				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+A001->CODIGO)

				zTemEstr   := .F.
				nEstru     := 0
				wProduto   := A001->CODIGO
				wQtd       := IIF(SB1->B1_QB == 0, 1, SB1->B1_QB)
				wpRevAtu   := SB1->B1_REVATU
				wpNiv      := 2
				cArqTmp    := ""
				cAliasTRB  := cArqTRB := "Estrut"

				cNome      := Processa({|| StrutBia(wProduto, wQtd, cAliasTRB, cArqTRB, .F., wpRevAtu, wpNiv) })
				cArqTRB    := cArqTmp
				ESTRUT->(dbGoTop())
				While ESTRUT->(!Eof())

					IncProc()
					zTemEstr := .T.
					dgtSeq ++

					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+wProduto))
					kD_WProd := SB1->B1_DESC
					kD_WForm := SB1->B1_YFORMAT

					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+ESTRUT->COMP))
					kD_COMP := SB1->B1_DESC
					kTp_Tipo := SB1->B1_TIPO

					kQtdOri := ESTRUT->QTDORI
					If ESTRUT->NIVEL <= 2 .and. kTp_Tipo == "PI"
						kQtdOri := 0
					ElseIf ESTRUT->NIVEL <= 2 .and. kTp_Tipo <> "PI"
						kQtdOri := 1
					Else
						If ESTRUT->CODIGO == wProduto
							kQtdOri := 1
						EndIf
					EndIf

					ZZ6->(dbSetOrder(1))
					ZZ6->(dbSeek(xFilial("ZZ6") + kD_WForm))

					aAdd(aDados2, { Str(dgtSeq),;
					ZZ6->ZZ6_DESC,;
					wProduto,;
					Substr(kD_WProd,1,25),;
					Transform(A001->QUANT    ,"@E 999,999.99999999"),;
					ESTRUT->NIVEL,;
					ESTRUT->COMP,;
					Substr(kD_COMP,1,25),;
					Transform(kQtdOri        ,"@E 999,999.99999999"),;
					Transform(ESTRUT->QUANT  ,"@E 999,999.99999999")})

					ESTRUT->(dbSkip())
				End
				U_BIAFimStru(cAliasTRB,cArqTRB)

				// Gera uma linha em branco que será muito util na integração com as planilhas gerencias
				If zTemEstr
					dgtSeq ++
					aAdd(aDados2, { StrTran( Str(dgtSeq + 0.5) ,".",",") ,;
					"",;
					wProduto,;
					"",;
					Transform(A001->QUANT    ,"@E 999,999.99999999"),;
					"0",;
					"0",;
					"",;
					Transform(0 ,"@E 999,999.99999999"),;
					Transform(0  ,"@E 999,999.99999999")})
				EndIf

			EndIf

			dbSelectArea("A001")
			dbSkip()
		End
		A001->(dbCloseArea())

	ElseIf nRadMenu1 == 3                                                //Produção
		***************************************************************************

		fPerg := "BIA29103"
		ktNomArq := "producao"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		Vld03Prg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf
		dtEmis := .F.
		If MV_PAR01 <> MV_PAR02
			dtEmis := MsgNOYES("Deseja detalhar por data?")
		EndIf

		A0001 := " SELECT SUBSTRING(B1_DESC,1, 50) DESCR,
		A0001 += "        B1_YFORMAT FORMAT,
		A0001 += "        REQFIM.*
		A0001 += "   FROM (SELECT CODIGO,
		If dtEmis
			A0001 += "                D3_EMISSAO,
		EndIf
		A0001 += "                SUM(QUANT) QUANT
		A0001 += "           FROM (SELECT D3_COD CODIGO,
		If dtEmis
			A0001 += "                        D3_EMISSAO,
		EndIf
		A0001 += "                        CASE
		A0001 += "                          WHEN D3_TM > '500' THEN D3_QUANT * ( -1 )
		A0001 += "                          ELSE D3_QUANT
		A0001 += "                        END QUANT
		A0001 += "                   FROM "+RetSqlName("SD3")+" SD3
		A0001 += "                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		A0001 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "                    AND ( D3_TM IN( '001', '500', '501' ) OR D3_YORIMOV = 'PR0' OR (D3_EMISSAO >= '20140101' AND D3_TIPO = 'PA' AND D3_TM = '010') )
		A0001 += "                    AND D3_ESTORNO = ' '
		A0001 += "                    AND SD3.D_E_L_E_T_ = ' '
		A0001 += "                  UNION ALL
		A0001 += "                 SELECT D3_COD CODIGO,
		If dtEmis
			A0001 += "                        D3_EMISSAO,
		EndIf
		A0001 += "                        CASE
		A0001 += "                          WHEN D3_TM > '500' THEN D3_QUANT * ( -1 )
		A0001 += "                          ELSE D3_QUANT
		A0001 += "                        END QUANT
		A0001 += "                   FROM "+RetSqlName("SD3")+" SD3
		A0001 += "                  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
		A0001 += "                    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "                    AND D3_TM = '711'
		A0001 += "                    AND D3_TIPO = 'PA'
		A0001 += "                    AND D3_ESTORNO = ' '
		A0001 += "                    AND SD3.D_E_L_E_T_ = ' '
		A0001 += "                    ) AS REQUIS
		If !dtEmis
			A0001 += "          GROUP BY CODIGO) AS REQFIM
		Else
			A0001 += "          GROUP BY CODIGO, D3_EMISSAO) AS REQFIM
		EndIf
		A0001 += "   LEFT JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
		A0001 += "                       AND B1_COD = CODIGO
		A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
		A0001 += "  WHERE QUANT <> 0
		A0001 += "    AND RIGHT(CODIGO,4) <> '000C'
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			If A001->QUANT <> 0

				If !dtEmis
					aAdd(aDados2, { A001->DESCR, A001->FORMAT, A001->CODIGO, Transform(A001->QUANT  ,"@E 999,999,999.9999") })
				Else
					aAdd(aDados2, { A001->DESCR, A001->FORMAT, A001->CODIGO, stod(A001->D3_EMISSAO), Transform(A001->QUANT  ,"@E 999,999,999.9999") })
				EndIf

			EndIf

			dbSelectArea("A001")
			dbSkip()
		End
		aStru1 := ("A001")->(dbStruct())
		A001->(dbCloseArea())

	ElseIf nRadMenu1 == 4                                               //Mov. ClVl
		***************************************************************************

		fPerg := "BIA29103"
		ktNomArq := "mov_clvl"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		Vld03Prg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		aStru1   := { {"CODIGO"    , "C", 20, 0},;
		{              "DESCRICAO" , "C", 30, 0} }

		// Acumulador
		T0001 := " SELECT CLVL
		T0001 += "   FROM (SELECT ISNULL(CTH_YCLVLG, 'X'+CQ6_CLVL) CLVL
		T0001 += "           FROM "+RetSqlName("CQ6")+" CQ6
		// Alterada a condição JOIN para LETF em 08/03/13 por Marcos Alberto Soprani, porque com a mudança de CLVL em 01/03/13 acabou não listando.
		//T0001 += "           LEFT JOIN DADOSGMCD..CLASSE_VALOR CTH ON CTH.CODIGO COLLATE DATABASE_DEFAULT = CQ6_CLVL COLLATE DATABASE_DEFAULT
		// Retirado LEFT acima e incluida LEFT que segue para alinhar os controles gerenciais - BW - SAP
		T0001 += "           LEFT JOIN "+RetSqlName("CTH")+" CTH ON CTH_FILIAL = '"+xFilial("CTH")+"'
		T0001 += "                               AND CTH_CLVL = CQ6_CLVL
		T0001 += "                               AND CTH.D_E_L_E_T_ = ' '
		T0001 += "          WHERE CQ6_FILIAL = '"+xFilial("CQ6")+"'
		T0001 += "            AND CQ6_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		T0001 += "            AND SUBSTRING(CQ6_CONTA,1,1) IN('3', '4', '6')
		T0001 += "            AND CQ6.D_E_L_E_T_ = ' '
		T0001 += "          GROUP BY CTH_YCLVLG, CQ6_CLVL) AS DADOS
		T0001 += "  GROUP BY CLVL
		T0001 += "  ORDER BY CLVL
		TCQUERY T0001 New Alias "T001"
		dbSelectArea("T001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			aAdd(aStru1, { T001->CLVL  , "C", 18, 0 })

			dbSelectArea("T001")
			dbSkip()
		End
		T001->(dbCloseArea())

		// Conteúdo
		A0001 := " SELECT CQ6_CONTA, CT1_DESC01, CLVL, SUM(SALDO) SALDO
		A0001 += "   FROM (SELECT CQ6_CONTA,
		A0001 += "                CT1_DESC01,
		A0001 += "                ISNULL(CTH_YCLVLG, 'X' + CQ6_CLVL) CLVL,
		A0001 += "                SUM(CQ6_DEBITO - CQ6_CREDIT) * ( -1 )        SALDO
		A0001 += "           FROM "+RetSqlName("CQ6")+" CQ6
		A0001 += "          INNER JOIN "+RetSqlName("CT1")+" CT1 ON CT1_FILIAL = '"+xFilial("CT1")+"'
		A0001 += "                               AND CT1_CONTA = CQ6_CONTA
		A0001 += "                               AND CT1.D_E_L_E_T_ = ' '
		//A0001 += "          INNER JOIN DADOSGMCD..CLASSE_VALOR CTH ON CTH.CODIGO COLLATE DATABASE_DEFAULT = CQ6_CLVL COLLATE DATABASE_DEFAULT
		// Retirado LEFT acima e incluida LEFT que segue para alinhar os controles gerenciais - BW - SAP
		A0001 += "           LEFT JOIN "+RetSqlName("CTH")+" CTH ON CTH_FILIAL = '"+xFilial("CTH")+"'
		A0001 += "                               AND CTH_CLVL = CQ6_CLVL
		A0001 += "                               AND CTH.D_E_L_E_T_ = ' '
		A0001 += "          WHERE CQ6_FILIAL = '"+xFilial("CQ6")+"'
		A0001 += "            AND CQ6_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "            AND SUBSTRING(CQ6_CONTA, 1, 1) IN( '3', '4', '6' )
		A0001 += "            AND CQ6.D_E_L_E_T_ = ' '
		A0001 += "          GROUP BY CQ6_CONTA,
		A0001 += "                   CT1_DESC01,
		A0001 += "                   CTH_YCLVLG,
		A0001 += "                   CQ6_CLVL) AS VALORES
		A0001 += "  GROUP BY CQ6_CONTA,
		A0001 += "           CT1_DESC01,
		A0001 += "           CLVL
		A0001 += "  ORDER BY CQ6_CONTA,
		A0001 += "           CT1_DESC01,
		A0001 += "           CLVL
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			Aadd(aDados2, Array( Len(aStru1) ) )
			sfPosic := Len(aDados2)
			aDados2[sfPosic][1] := A001->CQ6_CONTA
			aDados2[sfPosic][2] := A001->CT1_DESC01

			swConta := A001->CQ6_CONTA
			While !Eof() .and. A001->CQ6_CONTA == swConta

				vsValor := 0
				vsPsRef := 1
				For xxn := 1 to Len(aStru1)
					xcCampo := Trim(aStru1[xxn][1])
					If Alltrim(xcCampo) == Alltrim(A001->CLVL)
						vsValor := A001->SALDO
						vsPsRef := xxn
					Endif
				Next

				aDados2[sfPosic][vsPsRef] := Transform(vsValor  ,"@E 999,999,999.9999")

				dbSelectArea("A001")
				dbSkip()
			End
		End
		A001->(dbCloseArea())

	ElseIf nRadMenu1 == 5                                               //Balancete
		***************************************************************************

		fPerg := "BIA29103"
		ktNomArq := "balancete"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		Vld03Prg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		A0001 := " SELECT BALANC.CT7_CONTA CONTA,
		A0001 += "        CT1.CT1_DESC01 DESCR,
		A0001 += "        (SELECT SUM(XCT7. CT7_ANTDEB - XCT7. CT7_ANTCRD)
		A0001 += "           FROM "+RetSqlName("CT7")+" XCT7
		A0001 += "          WHERE XCT7.CT7_FILIAL = '"+xFilial("CT7")+"'
		A0001 += "            AND XCT7.CT7_DATA = BALANC.DTINI
		A0001 += "            AND XCT7.CT7_CONTA = BALANC.CT7_CONTA
		A0001 += "            AND XCT7.D_E_L_E_T_ = ' '
		A0001 += "          GROUP BY XCT7.CT7_CONTA) * ( -1 ) ANTERIOR,
		A0001 += "          BALANC.MOVIMENT * ( -1 ) VARIACAO,
		A0001 += "        (SELECT SUM(XCT7. CT7_ATUDEB - XCT7.CT7_ATUCRD)
		A0001 += "           FROM "+RetSqlName("CT7")+" XCT7
		A0001 += "          WHERE XCT7.CT7_FILIAL = '"+xFilial("CT7")+"'
		A0001 += "            AND XCT7.CT7_DATA = BALANC.DTFIM
		A0001 += "            AND XCT7.CT7_CONTA = BALANC.CT7_CONTA
		A0001 += "            AND XCT7.D_E_L_E_T_ = ' '
		A0001 += "          GROUP BY XCT7.CT7_CONTA) * ( -1 ) ATUAL
		A0001 += "   FROM (SELECT CT7.CT7_CONTA,
		A0001 += "                MIN(CT7.CT7_DATA) DTINI,
		A0001 += "                MAX(CT7.CT7_DATA) DTFIM,
		A0001 += "                SUM(CT7.CT7_DEBITO - CT7.CT7_CREDIT) MOVIMENT
		A0001 += "           FROM "+RetSqlName("CT7")+" CT7
		A0001 += "          WHERE CT7.CT7_FILIAL = '"+xFilial("CT7")+"'
		A0001 += "            AND CT7.CT7_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "            AND SUBSTRING(CT7.CT7_CONTA, 1, 1) IN( '3', '4', '6' )
		A0001 += "            AND CT7.D_E_L_E_T_ = ' '
		A0001 += "          GROUP BY CT7.CT7_CONTA) AS BALANC
		A0001 += "  INNER JOIN "+RetSqlName("CT1")+" CT1 ON CT1_FILIAL = '"+xFilial("CT1")+"'
		A0001 += "                       AND CT1_CONTA = CT7_CONTA
		A0001 += "                       AND CT1.D_E_L_E_T_ = ' '
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			aAdd(aDados2, { A001->CONTA,;
			A001->DESCR,;
			Transform(A001->ANTERIOR  ,"@E 999,999,999,999.9999"),;
			Transform(A001->VARIACAO  ,"@E 999,999,999,999.9999"),;
			Transform(A001->ATUAL     ,"@E 999,999,999,999.9999")})

			dbSelectArea("A001")
			dbSkip()
		End
		aStru1 := ("A001")->(dbStruct())
		A001->(dbCloseArea())

	ElseIf nRadMenu1 == 6                                             //Peso Ticket
		***************************************************************************

		fPerg := "BIA29106"
		ktNomArq := "pesoticket"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		Vld06Prg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		A0001 := " SELECT D1_COD,
		A0001 += "        SUBSTRING(B1_DESC,1,70) DESCRIC,
		A0001 += "        D1_DOC,
		A0001 += "        D1_FORNECE,
		A0001 += "        D1_LOJA,
		A0001 += "        D1_UM,
		A0001 += "        D1_QUANT,
		A0001 += "        D1_YTICKET,
		A0001 += "        D1_TOTAL
		A0001 += "   FROM " + RetSqlName("SD1") + " SD1
		A0001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
		A0001 += "                       AND B1_COD = D1_COD
		A0001 += "                       AND SUBSTRING(B1_GRUPO,1,3) = '101'
		A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
		A0001 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"'
		A0001 += "                       AND SF4.F4_CODIGO = SD1.D1_TES
		A0001 += "                       AND SF4.F4_ESTOQUE = 'S'
		A0001 += "                       AND SF4.D_E_L_E_T_ = ' '
		A0001 += "  WHERE D1_FILIAL = '"+xFilial("SD1")+"'
		A0001 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND D1_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
		A0001 += "    AND D1_FORNECE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
		A0001 += "    AND D1_QUANT <> 0
		A0001 += "    AND SD1.D_E_L_E_T_ = ' '
		A0001 += "  ORDER BY D1_COD,
		A0001 += "           D1_DOC
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			aAdd(aDados2, { A001->D1_COD,;
			StrTran(A001->DESCRIC ,";","-") ,;
			A001->D1_DOC,;
			A001->D1_FORNECE,;
			A001->D1_LOJA,;
			A001->D1_UM,;
			Transform(A001->D1_QUANT    ,"@E 999,999,999.9999"),;
			Transform(A001->D1_YTICKET  ,"@E 999,999,999.9999"),;
			Transform(A001->D1_TOTAL    ,"@E 999,999,999.9999")})

			dbSelectArea("A001")
			dbSkip()
		End
		aStru1 := ("A001")->(dbStruct())
		A001->(dbCloseArea())

	ElseIf nRadMenu1 == 7                                       //Estoque por Grupo
		***************************************************************************

		ktNomArq := "estoque_grupo"

		/*Grupos 101-102-103-104*/
		A0001 := " SELECT SUBSTRING(B9_DATA, 1, 6) PERIODO,
		A0001 += "        B1_GRUPO,
		A0001 += "        BM_DESC,
		A0001 += "        SUM(B9_VINI1) AS VALOR
		A0001 += "   FROM "+RetSqlName("SB9")+" SB9,
		A0001 += "        "+RetSqlName("SB1")+" SB1,
		A0001 += "        "+RetSqlName("SBM")+" SBM
		A0001 += "  WHERE B9_COD = B1_COD
		A0001 += "    AND B9_LOCAL = B1_LOCPAD
		A0001 += "    AND B9_LOCAL = '01'
		A0001 += "    AND B1_GRUPO = BM_GRUPO
		A0001 += "    AND B9_DATA >= '20100101'
		A0001 += "    AND B9_DATA <> '20110302'
		A0001 += "    AND SUBSTRING(B9_DATA, 7, 2) NOT IN ( '10', '20' )
		A0001 += "    AND B9_VINI1 <> 0
		A0001 += "    AND SUBSTRING(B1_GRUPO,1,3) <= '104'
		A0001 += "    AND B1_GRUPO <> ''
		A0001 += "    AND SB9.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY SUBSTRING(B9_DATA, 1, 6),
		A0001 += "           B1_GRUPO,
		A0001 += "           BM_DESC
		A0001 += " UNION ALL
		/*Grupo 105 (Esfera de Alta Alumina / Seixos)*/
		A0001 += " SELECT SUBSTRING(B9_DATA, 1, 6) PERIODO,
		A0001 += "        B1_GRUPO,
		A0001 += "        'BOLAS DE ALTA ALUMINA' BM_DESC,
		A0001 += "        SUM(B9_VINI1) AS VALOR
		A0001 += "   FROM "+RetSqlName("SB9")+" SB9,
		A0001 += "        "+RetSqlName("SB1")+" SB1,
		A0001 += "        "+RetSqlName("SBM")+" SBM
		A0001 += "  WHERE B9_COD = B1_COD
		A0001 += "    AND B9_LOCAL = B1_LOCPAD
		A0001 += "    AND B9_LOCAL = '01'
		A0001 += "    AND B1_GRUPO = BM_GRUPO
		A0001 += "    AND B9_DATA >= '20100101'
		A0001 += "    AND B9_DATA <> '20110302'
		A0001 += "    AND SUBSTRING(B9_DATA, 7, 2) NOT IN ( '10', '20' )
		A0001 += "    AND B9_VINI1 <> 0
		A0001 += "    AND SUBSTRING(B1_GRUPO,1,3) = '105'
		A0001 += "    AND B1_GRUPO <> ''
		A0001 += "    AND SB9.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY SUBSTRING(B9_DATA, 1, 6),
		A0001 += "           B1_GRUPO,
		A0001 += "           BM_DESC
		A0001 += " UNION ALL
		/*Grupos Maiores ou iguais do que 105 e Menores do que 300.*/
		A0001 += " SELECT SUBSTRING(B9_DATA, 1, 6) PERIODO,
		A0001 += "        'ALM' B1_GRUPO,
		A0001 += "        'ALMOXARIFADO' BM_DESC,
		A0001 += "        SUM(B9_VINI1) AS VALOR
		A0001 += "   FROM "+RetSqlName("SB9")+" SB9,
		A0001 += "        "+RetSqlName("SB1")+" SB1,
		A0001 += "        "+RetSqlName("SBM")+" SBM
		A0001 += "  WHERE B9_COD = B1_COD
		A0001 += "    AND B9_LOCAL = B1_LOCPAD
		A0001 += "    AND B9_LOCAL = '01'
		A0001 += "    AND B1_GRUPO = BM_GRUPO
		A0001 += "    AND B9_DATA >= '20100101'
		A0001 += "    AND B9_DATA <> '20110302'
		A0001 += "    AND SUBSTRING(B9_DATA, 7, 2) NOT IN ( '10', '20' )
		A0001 += "    AND B9_VINI1 <> 0
		A0001 += "    AND SUBSTRING(B1_GRUPO,1,3) > '105'
		A0001 += "    AND SUBSTRING(B1_GRUPO,1,3) < '300'
		A0001 += "    AND B1_GRUPO <> ''
		A0001 += "    AND SB9.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY SUBSTRING(B9_DATA, 1, 6)
		A0001 += "  ORDER BY SUBSTRING(B9_DATA, 1, 6),
		A0001 += "           B1_GRUPO,
		A0001 += "           BM_DESC
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			aAdd(aDados2, { A001->PERIODO,;
			A001->B1_GRUPO,;
			A001->BM_DESC,;
			Transform(A001->VALOR  ,"@E 999,999,999.9999")})

			dbSelectArea("A001")
			dbSkip()
		End
		aStru1 := ("A001")->(dbStruct())
		A001->(dbCloseArea())

	ElseIf nRadMenu1 == 8                                   //Gastos c/ Mão de Obra
		***************************************************************************

		fPerg := "BIA29103"
		ktNomArq := "gtmaoobra"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		Vld03Prg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		yd_CodFor := "'000314','001648','004015','004500','004576','004691','004909','005176','005727','006039','006554','006755','007240','007776','008214','008252','008607','004911','007010','007240','008600'"

		A0001 := " SELECT CT2_DEBITO DEBITO,
		A0001 += "        CT2_CREDIT CREDIT,
		A0001 += "        CT2_CLVLDB CLVLDB,
		A0001 += "        CT2_CLVLCR CLVLCR,
		A0001 += "        CASE
		A0001 += " 	     WHEN CT2_DEBITO <> ' ' THEN CT2_VALOR
		A0001 += " 	     ELSE 0
		A0001 += " 	   END VLR_DEBITO,
		A0001 += "        CASE
		A0001 += " 	     WHEN CT2_CREDIT <> ' ' THEN CT2_VALOR
		A0001 += " 	     ELSE 0
		A0001 += " 	   END VLR_CREDIT,
		A0001 += "        CT2_HIST HIST
		A0001 += "   FROM CT2010 CT2
		A0001 += "  WHERE CT2_FILIAL = '01'
		A0001 += "    AND CT2_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND ( SUBSTRING(CT2_KEY, 12, 6) IN("+yd_CodFor+") OR SUBSTRING(CT2_KEY, 15, 6) IN("+yd_CodFor+") )
		A0001 += "    AND ( SUBSTRING(CT2_DEBITO,1,1) IN('3','6') OR SUBSTRING(CT2_CREDIT,1,1) IN('3','6') )
		A0001 += "    AND CT2.D_E_L_E_T_ = ' '
		A0001 += " UNION ALL
		A0001 += " SELECT CT2_DEBITO DEBITO,
		A0001 += "        CT2_CREDIT CREDIT,
		A0001 += "        CT2_CLVLDB CLVLDB,
		A0001 += "        CT2_CLVLCR CLVLCR,
		A0001 += "        CASE
		A0001 += " 	     WHEN CT2_DEBITO <> ' ' THEN CT2_VALOR
		A0001 += " 	     ELSE 0
		A0001 += " 	   END VLR_DEBITO,
		A0001 += "        CASE
		A0001 += " 	     WHEN CT2_CREDIT <> ' ' THEN CT2_VALOR
		A0001 += " 	     ELSE 0
		A0001 += " 	   END VLR_CREDIT,
		A0001 += "        CT2_HIST HIST
		A0001 += "   FROM CT2050 CT2
		A0001 += "  WHERE CT2_FILIAL = '01'
		A0001 += "    AND CT2_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND ( SUBSTRING(CT2_KEY, 12, 6) IN("+yd_CodFor+") OR SUBSTRING(CT2_KEY, 15, 6) IN("+yd_CodFor+") )
		A0001 += "    AND ( SUBSTRING(CT2_DEBITO,1,1) IN('3','6') OR SUBSTRING(CT2_CREDIT,1,1) IN('3','6') )
		A0001 += "    AND CT2.D_E_L_E_T_ = ' '
		A0001 += " UNION ALL
		A0001 += " SELECT CT2_DEBITO DEBITO,
		A0001 += "        CT2_CREDIT CREDIT,
		A0001 += "        CT2_CLVLDB CLVLDB,
		A0001 += "        CT2_CLVLCR CLVLCR,
		A0001 += "        CASE
		A0001 += " 	     WHEN CT2_DEBITO <> ' ' THEN CT2_VALOR
		A0001 += " 	     ELSE 0
		A0001 += " 	   END VLR_DEBITO,
		A0001 += "        CASE
		A0001 += " 	     WHEN CT2_CREDIT <> ' ' THEN CT2_VALOR
		A0001 += " 	     ELSE 0
		A0001 += " 	   END VLR_CREDIT,
		A0001 += "        CT2_HIST HIST
		A0001 += "   FROM CT2070 CT2
		A0001 += "  WHERE CT2_FILIAL = '01'
		A0001 += "    AND CT2_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND ( SUBSTRING(CT2_KEY, 12, 6) IN("+yd_CodFor+") OR SUBSTRING(CT2_KEY, 15, 6) IN("+yd_CodFor+") )
		A0001 += "    AND ( SUBSTRING(CT2_DEBITO,1,1) IN('3','6') OR SUBSTRING(CT2_CREDIT,1,1) IN('3','6') )
		A0001 += "    AND CT2.D_E_L_E_T_ = ' '
		A0001 += " UNION ALL
		A0001 += " SELECT D1_CONTA DEBITO,
		A0001 += "        ' ' CREDIT,
		A0001 += "        D1_CLVL CLVLDB,
		A0001 += "        ' ' CLVLCR,
		A0001 += "        D1_TOTAL VLR_DEBITO,
		A0001 += "        0 VLR_CREDIT,
		A0001 += "        '* NECESSARIO VERIFICAR * VLR REF NFS '+RTRIM(D1_DOC)+' '+A2_NOME HIST
		A0001 += "   FROM SD1010 SD1
		A0001 += "  INNER JOIN SA2010 SA2 ON A2_FILIAL = '  '
		A0001 += "                       AND A2_COD = D1_FORNECE
		A0001 += "                       AND A2_LOJA = D1_LOJA
		A0001 += "                       AND SA2.D_E_L_E_T_ = ' '
		A0001 += "  WHERE D1_FILIAL = '01'
		A0001 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND D1_FORNECE IN("+yd_CodFor+")
		A0001 += "    AND RTRIM(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM) NOT IN (SELECT RTRIM(CT2_KEY)
		A0001 += "                                                                                     FROM CT2010 CT2
		A0001 += "                                                                                    WHERE CT2_FILIAL = '01'
		A0001 += "                                                                                      AND CT2_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "                                                                                      AND ( SUBSTRING(CT2_KEY, 12, 6) IN("+yd_CodFor+") OR SUBSTRING(CT2_KEY, 15, 6) IN("+yd_CodFor+") )
		A0001 += "                                                                                      AND ( SUBSTRING(CT2_DEBITO,1,1) IN('3','6') OR SUBSTRING(CT2_CREDIT,1,1) IN('3','6') )
		A0001 += "                                                                                      AND CT2.D_E_L_E_T_ = ' '
		A0001 += "                                                                                    UNION ALL
		A0001 += "                                                                                    SELECT RTRIM(CT2_KEY)
		A0001 += "                                                                                     FROM CT2050 CT2
		A0001 += "                                                                                    WHERE CT2_FILIAL = '01'
		A0001 += "                                                                                      AND CT2_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "                                                                                      AND ( SUBSTRING(CT2_KEY, 12, 6) IN("+yd_CodFor+") OR SUBSTRING(CT2_KEY, 15, 6) IN("+yd_CodFor+") )
		A0001 += "                                                                                      AND ( SUBSTRING(CT2_DEBITO,1,1) IN('3','6') OR SUBSTRING(CT2_CREDIT,1,1) IN('3','6') )
		A0001 += "                                                                                      AND CT2.D_E_L_E_T_ = ' '
		A0001 += "                                                                                    UNION ALL
		A0001 += "                                                                                    SELECT RTRIM(CT2_KEY)
		A0001 += "                                                                                     FROM CT2070 CT2
		A0001 += "                                                                                    WHERE CT2_FILIAL = '01'
		A0001 += "                                                                                      AND CT2_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "                                                                                      AND ( SUBSTRING(CT2_KEY, 12, 6) IN("+yd_CodFor+") OR SUBSTRING(CT2_KEY, 15, 6) IN("+yd_CodFor+") )
		A0001 += "                                                                                      AND ( SUBSTRING(CT2_DEBITO,1,1) IN('3','6') OR SUBSTRING(CT2_CREDIT,1,1) IN('3','6') )
		A0001 += "                                                                                      AND CT2.D_E_L_E_T_ = ' ')
		A0001 += "    AND SD1.D_E_L_E_T_ = ' '
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			aAdd(aDados2, { A001->DEBITO,;
			A001->CREDIT,;
			A001->CLVLDB,;
			A001->CLVLCR,;
			Transform(A001->VLR_DEBITO  ,"@E 999,999,999.9999"),;
			Transform(A001->VLR_CREDIT  ,"@E 999,999,999.9999"),;
			A001->HIST})

			dbSelectArea("A001")
			dbSkip()
		End
		aStru1 := ("A001")->(dbStruct())
		A001->(dbCloseArea())

	ElseIf nRadMenu1 == 9                                           //Custo por TAG
		***************************************************************************

		fPerg := "BIA29103"
		ktNomArq := "custotag"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		Vld03Prg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		// Biancogres
		A0001 := " SELECT D3_COD,
		A0001 += "        B1_DESC,
		A0001 += "        B1_UM,
		A0001 += "        D3_QUANT,
		A0001 += "        CASE
		A0001 += "          WHEN D3_TM < '500' THEN D3_CUSTO1 * (-1)
		A0001 += "          ELSE D3_CUSTO1
		A0001 += " 	      END D3_CUSTO1,
		A0001 += "        D3_YTAG,
		A0001 += "        D3_EMISSAO,
		A0001 += "        D3_CLVL CLVL
		A0001 += "   FROM SD3010 SD3,
		A0001 += "        SB1010 SB1
		A0001 += "  WHERE D3_COD = B1_COD
		A0001 += "    AND D3_YAPLIC >= '      '
		A0001 += "    AND D3_YAPLIC <= 'ZZZZZZ'
		A0001 += "    AND D3_GRUPO >= '      '
		A0001 += "    AND D3_GRUPO <= 'ZZZZZZ'
		//A0001 += "    AND D3_YTAG >= '1     '
		//A0001 += "    AND D3_YTAG <= 'ZZZZZZ'
		A0001 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND D3_CC >= '      '
		A0001 += "    AND D3_CC <= 'ZZZZZZ'
		A0001 += "    AND D3_YAPLIC <> ''
		A0001 += "    AND D3_QUANT > 0
		A0001 += "    AND D3_CUSTO1 > 0
		A0001 += "    AND D3_ESTORNO = ' '
		A0001 += "    AND SD3.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += " UNION ALL
		A0001 += " SELECT D1_COD,
		A0001 += "        B1_DESC,
		A0001 += "        B1_UM,
		A0001 += "        D1_QUANT,
		A0001 += "        D1_CUSTO,
		A0001 += "        D1_YTAG,
		A0001 += "        D1_DTDIGIT,
		A0001 += "        D1_CLVL CLVL
		A0001 += "   FROM SD1010 SD1,
		A0001 += "        SF4010 SF4,
		A0001 += "        SB1010 SB1
		A0001 += "  WHERE D1_COD = B1_COD
		A0001 += "    AND SD1.D1_YAPLIC >= '      '
		A0001 += "    AND SD1.D1_YAPLIC <= 'ZZZZZZ'
		A0001 += "    AND SD1.D1_GRUPO >= '      '
		A0001 += "    AND SD1.D1_GRUPO <= 'ZZZZZZ'
		//A0001 += "    AND SD1.D1_YTAG >= '1     '
		//A0001 += "    AND SD1.D1_YTAG <= 'ZZZZZZ'
		A0001 += "    AND SD1.D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SD1.D1_CC >= '      '
		A0001 += "    AND SD1.D1_CC <= 'ZZZZZZ'
		A0001 += "    AND SD1.D1_CF NOT IN ( '1551', '2551', '3551' )
		A0001 += "    AND SD1.D1_YAPLIC <> ''
		A0001 += "    AND SD1.D1_QUANT > 0
		A0001 += "    AND SD1.D1_CUSTO > 0
		A0001 += "    AND SD1.D1_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_ESTOQUE <> 'S'
		A0001 += "    AND SF4.F4_FILIAL = SD1.D1_FILIAL
		A0001 += "    AND SD1.D_E_L_E_T_ = ''
		A0001 += "    AND SF4.D_E_L_E_T_ = ' '

		// Incesa
		A0001 += " UNION ALL
		A0001 += " SELECT D3_COD,
		A0001 += "        B1_DESC,
		A0001 += "        B1_UM,
		A0001 += "        D3_QUANT,
		A0001 += "        CASE
		A0001 += "          WHEN D3_TM < '500' THEN D3_CUSTO1 * (-1)
		A0001 += "          ELSE D3_CUSTO1
		A0001 += " 	      END D3_CUSTO1,
		A0001 += "        D3_YTAG,
		A0001 += "        D3_EMISSAO,
		A0001 += "        D3_CLVL CLVL
		A0001 += "   FROM SD3050 SD3,
		A0001 += "        SB1010 SB1
		A0001 += "  WHERE D3_COD = B1_COD
		A0001 += "    AND D3_YAPLIC >= '      '
		A0001 += "    AND D3_YAPLIC <= 'ZZZZZZ'
		A0001 += "    AND D3_GRUPO >= '      '
		A0001 += "    AND D3_GRUPO <= 'ZZZZZZ'
		//A0001 += "    AND D3_YTAG >= '1     '
		//A0001 += "    AND D3_YTAG <= 'ZZZZZZ'
		A0001 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND D3_CC >= '      '
		A0001 += "    AND D3_CC <= 'ZZZZZZ'
		A0001 += "    AND D3_YAPLIC <> ''
		A0001 += "    AND D3_QUANT > 0
		A0001 += "    AND D3_CUSTO1 > 0
		A0001 += "    AND D3_ESTORNO = ' '
		A0001 += "    AND SD3.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += " UNION ALL
		A0001 += " SELECT D1_COD,
		A0001 += "        B1_DESC,
		A0001 += "        B1_UM,
		A0001 += "        D1_QUANT,
		A0001 += "        D1_CUSTO,
		A0001 += "        D1_YTAG,
		A0001 += "        D1_DTDIGIT,
		A0001 += "        D1_CLVL CLVL
		A0001 += "   FROM SD1050 SD1,
		A0001 += "        SF4050 SF4,
		A0001 += "        SB1010 SB1
		A0001 += "  WHERE D1_COD = B1_COD
		A0001 += "    AND SD1.D1_YAPLIC >= '      '
		A0001 += "    AND SD1.D1_YAPLIC <= 'ZZZZZZ'
		A0001 += "    AND SD1.D1_GRUPO >= '      '
		A0001 += "    AND SD1.D1_GRUPO <= 'ZZZZZZ'
		//A0001 += "    AND SD1.D1_YTAG >= '1     '
		//A0001 += "    AND SD1.D1_YTAG <= 'ZZZZZZ'
		A0001 += "    AND SD1.D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SD1.D1_CC >= '      '
		A0001 += "    AND SD1.D1_CC <= 'ZZZZZZ'
		A0001 += "    AND SD1.D1_CF NOT IN ( '1551', '2551', '3551' )
		A0001 += "    AND SD1.D1_YAPLIC <> ''
		A0001 += "    AND SD1.D1_QUANT > 0
		A0001 += "    AND SD1.D1_CUSTO > 0
		A0001 += "    AND SD1.D1_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_ESTOQUE <> 'S'
		A0001 += "    AND SF4.F4_FILIAL = SD1.D1_FILIAL
		A0001 += "    AND SD1.D_E_L_E_T_ = ''
		A0001 += "    AND SF4.D_E_L_E_T_ = ' '

		// Mundi
		A0001 += " UNION ALL
		A0001 += " SELECT D3_COD,
		A0001 += "        B1_DESC,
		A0001 += "        B1_UM,
		A0001 += "        D3_QUANT,
		A0001 += "        CASE
		A0001 += "          WHEN D3_TM < '500' THEN D3_CUSTO1 * (-1)
		A0001 += "          ELSE D3_CUSTO1
		A0001 += " 	      END D3_CUSTO1,
		A0001 += "        D3_YTAG,
		A0001 += "        D3_EMISSAO,
		A0001 += "        D3_CLVL CLVL
		A0001 += "   FROM SD3130 SD3,
		A0001 += "        SB1010 SB1
		A0001 += "  WHERE D3_COD = B1_COD
		A0001 += "    AND D3_YAPLIC >= '      '
		A0001 += "    AND D3_YAPLIC <= 'ZZZZZZ'
		A0001 += "    AND D3_GRUPO >= '      '
		A0001 += "    AND D3_GRUPO <= 'ZZZZZZ'
		//A0001 += "    AND D3_YTAG >= '1     '
		//A0001 += "    AND D3_YTAG <= 'ZZZZZZ'
		A0001 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND D3_CC >= '      '
		A0001 += "    AND D3_CC <= 'ZZZZZZ'
		A0001 += "    AND D3_YAPLIC <> ''
		A0001 += "    AND D3_QUANT > 0
		A0001 += "    AND D3_CUSTO1 > 0
		A0001 += "    AND D3_ESTORNO = ' '
		A0001 += "    AND SD3.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += " UNION ALL
		A0001 += " SELECT D1_COD,
		A0001 += "        B1_DESC,
		A0001 += "        B1_UM,
		A0001 += "        D1_QUANT,
		A0001 += "        D1_CUSTO,
		A0001 += "        D1_YTAG,
		A0001 += "        D1_DTDIGIT,
		A0001 += "        D1_CLVL CLVL
		A0001 += "   FROM SD1130 SD1,
		A0001 += "        SF4130 SF4,
		A0001 += "        SB1010 SB1
		A0001 += "  WHERE D1_COD = B1_COD
		A0001 += "    AND SD1.D1_YAPLIC >= '      '
		A0001 += "    AND SD1.D1_YAPLIC <= 'ZZZZZZ'
		A0001 += "    AND SD1.D1_GRUPO >= '      '
		A0001 += "    AND SD1.D1_GRUPO <= 'ZZZZZZ'
		//A0001 += "    AND SD1.D1_YTAG >= '1     '
		//A0001 += "    AND SD1.D1_YTAG <= 'ZZZZZZ'
		A0001 += "    AND SD1.D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SD1.D1_CC >= '      '
		A0001 += "    AND SD1.D1_CC <= 'ZZZZZZ'
		A0001 += "    AND SD1.D1_CF NOT IN ( '1551', '2551', '3551' )
		A0001 += "    AND SD1.D1_YAPLIC <> ''
		A0001 += "    AND SD1.D1_QUANT > 0
		A0001 += "    AND SD1.D1_CUSTO > 0
		A0001 += "    AND SD1.D1_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_ESTOQUE <> 'S'
		A0001 += "    AND SF4.F4_FILIAL = SD1.D1_FILIAL
		A0001 += "    AND SD1.D_E_L_E_T_ = ''
		A0001 += "    AND SF4.D_E_L_E_T_ = ' '

		// Vitcer
		A0001 += " UNION ALL
		A0001 += " SELECT D3_COD,
		A0001 += "        B1_DESC,
		A0001 += "        B1_UM,
		A0001 += "        D3_QUANT,
		A0001 += "        CASE
		A0001 += "          WHEN D3_TM < '500' THEN D3_CUSTO1 * (-1)
		A0001 += "          ELSE D3_CUSTO1
		A0001 += " 	      END D3_CUSTO1,
		A0001 += "        D3_YTAG,
		A0001 += "        D3_EMISSAO,
		A0001 += "        D3_CLVL CLVL
		A0001 += "   FROM SD3140 SD3,
		A0001 += "        SB1010 SB1
		A0001 += "  WHERE D3_COD = B1_COD
		A0001 += "    AND D3_YAPLIC >= '      '
		A0001 += "    AND D3_YAPLIC <= 'ZZZZZZ'
		A0001 += "    AND D3_GRUPO >= '      '
		A0001 += "    AND D3_GRUPO <= 'ZZZZZZ'
		//A0001 += "    AND D3_YTAG >= '1     '
		//A0001 += "    AND D3_YTAG <= 'ZZZZZZ'
		A0001 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND D3_CC >= '      '
		A0001 += "    AND D3_CC <= 'ZZZZZZ'
		A0001 += "    AND D3_YAPLIC <> ''
		A0001 += "    AND D3_QUANT > 0
		A0001 += "    AND D3_CUSTO1 > 0
		A0001 += "    AND D3_ESTORNO = ' '
		A0001 += "    AND SD3.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += " UNION ALL
		A0001 += " SELECT D1_COD,
		A0001 += "        B1_DESC,
		A0001 += "        B1_UM,
		A0001 += "        D1_QUANT,
		A0001 += "        D1_CUSTO,
		A0001 += "        D1_YTAG,
		A0001 += "        D1_DTDIGIT,
		A0001 += "        D1_CLVL CLVL
		A0001 += "   FROM SD1140 SD1,
		A0001 += "        SF4140 SF4,
		A0001 += "        SB1010 SB1
		A0001 += "  WHERE D1_COD = B1_COD
		A0001 += "    AND SD1.D1_YAPLIC >= '      '
		A0001 += "    AND SD1.D1_YAPLIC <= 'ZZZZZZ'
		A0001 += "    AND SD1.D1_GRUPO >= '      '
		A0001 += "    AND SD1.D1_GRUPO <= 'ZZZZZZ'
		//A0001 += "    AND SD1.D1_YTAG >= '1     '
		//A0001 += "    AND SD1.D1_YTAG <= 'ZZZZZZ'
		A0001 += "    AND SD1.D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SD1.D1_CC >= '      '
		A0001 += "    AND SD1.D1_CC <= 'ZZZZZZ'
		A0001 += "    AND SD1.D1_CF NOT IN ( '1551', '2551', '3551' )
		A0001 += "    AND SD1.D1_YAPLIC <> ''
		A0001 += "    AND SD1.D1_QUANT > 0
		A0001 += "    AND SD1.D1_CUSTO > 0
		A0001 += "    AND SD1.D1_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_ESTOQUE <> 'S'
		A0001 += "    AND SF4.F4_FILIAL = SD1.D1_FILIAL
		A0001 += "    AND SD1.D_E_L_E_T_ = ''
		A0001 += "    AND SF4.D_E_L_E_T_ = ' '

		A0001 += "  ORDER BY D3_YTAG,
		A0001 += "           D3_EMISSAO
		A0001 := ChangeQuery(A0001)
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			aAdd(aDados2, { A001->D3_COD,;
			StrTran( Substr(A001->B1_DESC,1,50) ,";","-") ,;
			A001->B1_UM,;
			Transform(A001->D3_QUANT   ,"@E 999,999,999.9999"),;
			Transform(A001->D3_CUSTO1  ,"@E 999,999,999.9999"),;
			A001->D3_YTAG,;
			dtoc(stod(A001->D3_EMISSAO)),;
			A001->CLVL})

			dbSelectArea("A001")
			dbSkip()
		End
		aStru1 := ("A001")->(dbStruct())
		A001->(dbCloseArea())

	ElseIf nRadMenu1 == 10                                        //Receita Liquida
		***************************************************************************

		If cEmpAnt <> "01"
			MsgSTOP("Esta opção somente poderá ser executada na empresa Biancogres","Atenção")
			Return
		EndIf

		fPerg := "BIA29103"
		ktNomArq := "rec_liqu"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		Vld03Prg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		//A) Faturamento da Biancogres sem LM
		A0001 := " SELECT 'A'             QUADRO,
		A0001 += "        B1_YTPPROD,
		A0001 += "        SUM(D2_QUANT)   AS QUANT1,
		A0001 += "        SUM(D2_QTSEGUM) AS QUANT2,
		A0001 += "        SUM(D2_TOTAL)   AS TOTAL,
		A0001 += "        SUM(D2_VALIPI)  AS VALIPI,
		A0001 += "        SUM(D2_VALICM)  AS VALICM,
		A0001 += "        SUM(D2_VALIMP6) AS PIS,
		A0001 += "        SUM(D2_VALIMP5) AS COFINS
		A0001 += "   FROM SD2010 SD2,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF2010 SF2,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SF4010 SF4
		A0001 += "  WHERE SD2.D2_FILIAL = '01'
		A0001 += "    AND SD2.D2_GRUPO = 'PA'
		A0001 += "    AND SD2.D2_COD BETWEEN 'A' AND 'ZZZZZZZZZZZZZZZ'
		A0001 += "    AND SD2.D2_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_DUPLIC = 'S'
		A0001 += "    AND SF4.D_E_L_E_T_ = ''
		A0001 += "    AND SF2.F2_CLIENTE <> '010064'
		A0001 += "    AND SF2.F2_YEMP IN ( '0101' )
		A0001 += "    AND SF2.F2_FILIAL = '01'
		A0001 += "    AND SF2.F2_DOC = SD2.D2_DOC
		A0001 += "    AND SF2.F2_SERIE = SD2.D2_SERIE
		A0001 += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
		A0001 += "    AND SF2.F2_LOJA = SD2.D2_LOJA
		A0001 += "    AND SF2.F2_SERIE BETWEEN '   ' AND 'ZZZ'
		A0001 += "    AND SF2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SF2.F2_CLIENTE BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_VEND1 BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_YFORMAT = ZZ6_COD
		A0001 += "    AND SD2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_FILIAL = '  '
		A0001 += "    AND SB1.B1_COD = SD2.D2_COD
		A0001 += "    AND SB1.B1_TIPO = 'PA'
		A0001 += "    AND SB1.B1_YCLASSE BETWEEN '1' AND '5'
		A0001 += "    AND SB1.B1_UM = 'M2'
		A0001 += "    AND SUBSTRING(SB1.B1_COD, 1, 1) >= 'A'
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY B1_YTPPROD
		A0001 += " UNION ALL
		//B) Faturamento da LM de produtos da Biancogres
		A0001 += " SELECT 'B'             QUADRO,
		A0001 += "        B1_YTPPROD,
		A0001 += "        SUM(D2_QUANT)   AS QUANT1,
		A0001 += "        SUM(D2_QTSEGUM) AS QUANT2,
		A0001 += "        SUM(D2_TOTAL)   AS TOTAL,
		A0001 += "        SUM(D2_VALIPI)  AS VALIPI,
		A0001 += "        SUM(D2_VALICM)  AS VALICM,
		A0001 += "        SUM(D2_VALIMP6) AS PIS,
		A0001 += "        SUM(D2_VALIMP5) AS COFINS
		A0001 += "   FROM SD2070 SD2,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF2070 SF2,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SF4070 SF4
		A0001 += "  WHERE SD2.D2_FILIAL = '01'
		A0001 += "    AND SD2.D2_GRUPO = 'PA'
		A0001 += "    AND SD2.D2_COD BETWEEN 'A' AND 'ZZZZZZZZZZZZZZZ'
		A0001 += "    AND SD2.D2_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_DUPLIC = 'S'
		A0001 += "    AND SF4.D_E_L_E_T_ = ''
		A0001 += "    AND SF2.F2_YEMP IN ( '0101' )
		A0001 += "    AND SF2.F2_FILIAL = '01'
		A0001 += "    AND SF2.F2_DOC = SD2.D2_DOC
		A0001 += "    AND SF2.F2_SERIE = SD2.D2_SERIE
		A0001 += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
		A0001 += "    AND SF2.F2_LOJA = SD2.D2_LOJA
		A0001 += "    AND SF2.F2_SERIE BETWEEN '   ' AND 'ZZZ'
		A0001 += "    AND SF2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SF2.F2_CLIENTE BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_VEND1 BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_YFORMAT = ZZ6_COD
		A0001 += "    AND SD2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_FILIAL = '  '
		A0001 += "    AND SB1.B1_COD = SD2.D2_COD
		A0001 += "    AND SB1.B1_TIPO = 'PA'
		A0001 += "    AND SB1.B1_YCLASSE BETWEEN '1' AND '5'
		A0001 += "    AND SB1.B1_UM = 'M2'
		A0001 += "    AND SUBSTRING(SB1.B1_COD, 1, 1) >= 'A'
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY B1_YTPPROD
		A0001 += " UNION ALL
		//C) Faturamento da Biancogres para LM
		A0001 += " SELECT 'C'             QUADRO,
		A0001 += "        B1_YTPPROD,
		A0001 += "        SUM(D2_QUANT)   AS QUANT1,
		A0001 += "        SUM(D2_QTSEGUM) AS QUANT2,
		A0001 += "        SUM(D2_TOTAL)   AS TOTAL,
		A0001 += "        SUM(D2_VALIPI)  AS VALIPI,
		A0001 += "        SUM(D2_VALICM)  AS VALICM,
		A0001 += "        SUM(D2_VALIMP6) AS PIS,
		A0001 += "        SUM(D2_VALIMP5) AS COFINS
		A0001 += "   FROM SD2010 SD2,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF2010 SF2,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SF4010 SF4
		A0001 += "  WHERE SD2.D2_FILIAL = '01'
		A0001 += "    AND SD2.D2_GRUPO = 'PA'
		A0001 += "    AND SD2.D2_COD BETWEEN 'A' AND 'ZZZZZZZZZZZZZZZ'
		A0001 += "    AND SD2.D2_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_DUPLIC = 'S'
		A0001 += "    AND SF4.D_E_L_E_T_ = ''
		A0001 += "    AND SF2.F2_CLIENTE = '010064'
		A0001 += "    AND SF2.F2_YEMP IN ( '0101' )
		A0001 += "    AND SF2.F2_FILIAL = '01'
		A0001 += "    AND SF2.F2_DOC = SD2.D2_DOC
		A0001 += "    AND SF2.F2_SERIE = SD2.D2_SERIE
		A0001 += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
		A0001 += "    AND SF2.F2_LOJA = SD2.D2_LOJA
		A0001 += "    AND SF2.F2_SERIE BETWEEN '   ' AND 'ZZZ'
		A0001 += "    AND SF2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SF2.F2_CLIENTE BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_VEND1 BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_YFORMAT = ZZ6_COD
		A0001 += "    AND SD2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_FILIAL = '  '
		A0001 += "    AND SB1.B1_COD = SD2.D2_COD
		A0001 += "    AND SB1.B1_TIPO = 'PA'
		A0001 += "    AND SB1.B1_YCLASSE BETWEEN '1' AND '5'
		A0001 += "    AND SB1.B1_UM = 'M2'
		A0001 += "    AND SUBSTRING(SB1.B1_COD, 1, 1) >= 'A'
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY B1_YTPPROD
		A0001 += " UNION ALL
		//D) Faturamento da Incesa para Bincogres
		A0001 += " SELECT 'D'             QUADRO,
		A0001 += "        B1_YTPPROD,
		A0001 += "        SUM(D2_QUANT)   AS QUANT1,
		A0001 += "        SUM(D2_QTSEGUM) AS QUANT2,
		A0001 += "        SUM(D2_TOTAL)   AS TOTAL,
		A0001 += "        SUM(D2_VALIPI)  AS VALIPI,
		A0001 += "        SUM(D2_VALICM)  AS VALICM,
		A0001 += "        SUM(D2_VALIMP6) AS PIS,
		A0001 += "        SUM(D2_VALIMP5) AS COFINS
		A0001 += "   FROM SD2050 SD2,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF2050 SF2,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SF4050 SF4
		A0001 += "  WHERE SD2.D2_FILIAL = '01'
		A0001 += "    AND SD2.D2_GRUPO = 'PA'
		A0001 += "    AND SD2.D2_COD BETWEEN 'A' AND 'ZZZZZZZZZZZZZZZ'
		A0001 += "    AND SD2.D2_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_DUPLIC = 'S'
		A0001 += "    AND SF4.D_E_L_E_T_ = ''
		A0001 += "    AND SF2.F2_CLIENTE = '000481'
		A0001 += "    AND SF2.F2_YEMP IN ( '0501', '0599' )
		A0001 += "    AND SF2.F2_FILIAL = '01'
		A0001 += "    AND SF2.F2_DOC = SD2.D2_DOC
		A0001 += "    AND SF2.F2_SERIE = SD2.D2_SERIE
		A0001 += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
		A0001 += "    AND SF2.F2_LOJA = SD2.D2_LOJA
		A0001 += "    AND SF2.F2_SERIE BETWEEN '   ' AND 'ZZZ'
		A0001 += "    AND SF2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SF2.F2_CLIENTE BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_VEND1 BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_YFORMAT = ZZ6_COD
		A0001 += "    AND SD2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_FILIAL = '  '
		A0001 += "    AND SB1.B1_COD = SD2.D2_COD
		A0001 += "    AND SB1.B1_TIPO = 'PA'
		A0001 += "    AND SB1.B1_YCLASSE BETWEEN '1' AND '5'
		A0001 += "    AND SB1.B1_UM = 'M2'
		A0001 += "    AND SUBSTRING(SB1.B1_COD, 1, 1) >= 'A'
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY B1_YTPPROD
		A0001 += " UNION ALL
		//E) Faturamento da Biancogres para LM de produtos Incesa
		A0001 += " SELECT 'E'             QUADRO,
		A0001 += "        B1_YTPPROD,
		A0001 += "        SUM(D2_QUANT)   AS QUANT1,
		A0001 += "        SUM(D2_QTSEGUM) AS QUANT2,
		A0001 += "        SUM(D2_TOTAL)   AS TOTAL,
		A0001 += "        SUM(D2_VALIPI)  AS VALIPI,
		A0001 += "        SUM(D2_VALICM)  AS VALICM,
		A0001 += "        SUM(D2_VALIMP6) AS PIS,
		A0001 += "        SUM(D2_VALIMP5) AS COFINS
		A0001 += "   FROM SD2050 SD2,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF2050 SF2,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SF4050 SF4
		A0001 += "  WHERE SD2.D2_FILIAL = '01'
		A0001 += "    AND SD2.D2_GRUPO = 'PA'
		A0001 += "    AND SD2.D2_COD BETWEEN 'A' AND 'ZZZZZZZZZZZZZZZ'
		A0001 += "    AND SD2.D2_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_DUPLIC = 'S'
		A0001 += "    AND SF4.D_E_L_E_T_ = ''
		A0001 += "    AND SF2.F2_CLIENTE = '010064'
		A0001 += "    AND SF2.F2_YEMP IN ( '0501', '0599' )
		A0001 += "    AND SF2.F2_FILIAL = '01'
		A0001 += "    AND SF2.F2_DOC = SD2.D2_DOC
		A0001 += "    AND SF2.F2_SERIE = SD2.D2_SERIE
		A0001 += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
		A0001 += "    AND SF2.F2_LOJA = SD2.D2_LOJA
		A0001 += "    AND SF2.F2_SERIE BETWEEN '   ' AND 'ZZZ'
		A0001 += "    AND SF2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SF2.F2_CLIENTE BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_VEND1 BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_YFORMAT = ZZ6_COD
		A0001 += "    AND SD2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_FILIAL = '  '
		A0001 += "    AND SB1.B1_COD = SD2.D2_COD
		A0001 += "    AND SB1.B1_TIPO = 'PA'
		A0001 += "    AND SB1.B1_YCLASSE BETWEEN '1' AND '5'
		A0001 += "    AND SB1.B1_UM = 'M2'
		A0001 += "    AND SUBSTRING(SB1.B1_COD, 1, 1) >= 'A'
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY B1_YTPPROD
		A0001 += " UNION ALL
		//F) Faturamento da LM de produtos Incesa
		A0001 += " SELECT 'F'             QUADRO,
		A0001 += "        B1_YTPPROD,
		A0001 += "        SUM(D2_QUANT)   AS QUANT1,
		A0001 += "        SUM(D2_QTSEGUM) AS QUANT2,
		A0001 += "        SUM(D2_TOTAL)   AS TOTAL,
		A0001 += "        SUM(D2_VALIPI)  AS VALIPI,
		A0001 += "        SUM(D2_VALICM)  AS VALICM,
		A0001 += "        SUM(D2_VALIMP6) AS PIS,
		A0001 += "        SUM(D2_VALIMP5) AS COFINS
		A0001 += "   FROM SD2070 SD2,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF2070 SF2,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SF4070 SF4
		A0001 += "  WHERE SD2.D2_FILIAL = '01'
		A0001 += "    AND SD2.D2_GRUPO = 'PA'
		A0001 += "    AND SD2.D2_COD BETWEEN 'A' AND 'ZZZZZZZZZZZZZZZ'
		A0001 += "    AND SD2.D2_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_DUPLIC = 'S'
		A0001 += "    AND SF4.D_E_L_E_T_ = ''
		A0001 += "    AND SF2.F2_CLIENTE <> '000481'
		A0001 += "    AND SF2.F2_YEMP IN ( '0501', '0599' )
		A0001 += "    AND SF2.F2_FILIAL = '01'
		A0001 += "    AND SF2.F2_DOC = SD2.D2_DOC
		A0001 += "    AND SF2.F2_SERIE = SD2.D2_SERIE
		A0001 += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
		A0001 += "    AND SF2.F2_LOJA = SD2.D2_LOJA
		A0001 += "    AND SF2.F2_SERIE BETWEEN '   ' AND 'ZZZ'
		A0001 += "    AND SF2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SF2.F2_CLIENTE BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_VEND1 BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_YFORMAT = ZZ6_COD
		A0001 += "    AND SD2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_FILIAL = '  '
		A0001 += "    AND SB1.B1_COD = SD2.D2_COD
		A0001 += "    AND SB1.B1_TIPO = 'PA'
		A0001 += "    AND SB1.B1_YCLASSE BETWEEN '1' AND '5'
		A0001 += "    AND SB1.B1_UM = 'M2'
		A0001 += "    AND SUBSTRING(SB1.B1_COD, 1, 1) >= 'A'
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY B1_YTPPROD
		A0001 += " UNION ALL
		//G) Devolução de vendas, mercado interno
		A0001 += " SELECT 'G'             QUADRO,
		A0001 += "        '  '            B1_YTPPTOD,
		A0001 += "        SUM(D1_QUANT)   AS QUANT1,
		A0001 += "        0               QUANT2,
		A0001 += "        0               TOTAL,
		A0001 += "        0               VALIPI,
		A0001 += "        SUM(D1_VALICM)  AS VALICM,
		A0001 += "        SUM(D1_VALIMP6) AS PIS,
		A0001 += "        SUM(D1_VALIMP5) AS COFINS
		A0001 += "   FROM SD1010 SD1,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SB1010 SB1,
		A0001 += "        ZZ7010 ZZ7,
		A0001 += "        SD2010 SD2
		A0001 += "  WHERE D1_FILIAL = '01'
		A0001 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND D1_COD >= 'A'
		A0001 += "    AND B1_YFORMAT = ZZ6_COD
		A0001 += "    AND ( ZZ6_EMP IN ( 'B', 'A' )
		A0001 += "           OR B1_YFORMAT = 'BA' )
		A0001 += "    AND D1_FORNECE <> '010064'
		A0001 += "    AND B1_UM = 'M2'
		A0001 += "    AND D1_COD = B1_COD
		A0001 += "    AND D1_CF IN ( '1201', '2201', '1202', '2202',
		A0001 += "                   '1203', '2203', '1410', '2410' )
		A0001 += "    AND B1_YLINHA + B1_YLINSEQ = ZZ7_COD + ZZ7_LINSEQ
		A0001 += "    AND ZZ7_TIPO NOT IN ( 'B' )
		A0001 += "    AND D1_NFORI = D2_DOC
		A0001 += "    AND D1_ITEMORI = D2_ITEM
		A0001 += "    AND D1_SERIORI = D2_SERIE
		A0001 += "    AND D1_FORNECE = D2_CLIENTE
		A0001 += "    AND D1_LOJA = D2_LOJA
		A0001 += "    AND D1_TES IN (SELECT F4_CODIGO
		A0001 += "                     FROM SF4010
		A0001 += "                    WHERE F4_ESTOQUE = 'S'
		A0001 += "                      AND D_E_L_E_T_ = '')
		A0001 += "    AND D2_TES IN (SELECT F4_CODIGO
		A0001 += "                     FROM SF4010
		A0001 += "                    WHERE F4_DUPLIC = 'S'
		A0001 += "                      AND D_E_L_E_T_ = '')
		A0001 += "    AND SD2.D_E_L_E_T_ = ' '
		A0001 += "    AND SD1.D_E_L_E_T_ = ' '
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ' '
		A0001 += "    AND SB1.D_E_L_E_T_ = ' '
		A0001 += " UNION ALL
		//H) Apenas Impostos do mercado interno para a empresa LM
		A0001 += " SELECT 'H'             QUADRO,
		A0001 += "        '  '            B1_YTPPTOD,
		A0001 += "        0               QUANT1,
		A0001 += "        0               QUANT2,
		A0001 += "        0               TOTAL,
		A0001 += "        0               VALIPI,
		A0001 += "        0               VALICM,
		A0001 += "        SUM(D1_VALIMP6) AS PIS,
		A0001 += "        SUM(D1_VALIMP5) AS COFINS
		A0001 += "   FROM SD1010 SD1,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF4010 SF4,
		A0001 += "        ZZ7010 ZZ7
		A0001 += "  WHERE D1_FILIAL = '01'
		A0001 += "    AND D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND D1_COD >= 'A'
		A0001 += "    AND B1_YFORMAT = ZZ6_COD
		A0001 += "    AND ( ZZ6_EMP IN ( 'B', 'A' )
		A0001 += "           OR B1_YFORMAT = 'BA' )
		A0001 += "    AND D1_FORNECE = '010064'
		A0001 += "    AND B1_UM = 'M2'
		A0001 += "    AND D1_COD = B1_COD
		A0001 += "    AND D1_TES = F4_CODIGO
		A0001 += "    AND D1_CF IN ( '1201', '2201', '1202', '2202',
		A0001 += "                   '1203', '2203', '1410', '2410' )
		A0001 += "    AND B1_YLINHA + B1_YLINSEQ = ZZ7_COD + ZZ7_LINSEQ
		A0001 += "    AND ZZ7_TIPO NOT IN ( 'B' )
		A0001 += "    AND F4_ESTOQUE = 'S'
		A0001 += "    AND SD1.D_E_L_E_T_ = ' '
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ' '
		A0001 += "    AND ZZ7.D_E_L_E_T_ = ' '
		A0001 += "    AND SF4.D_E_L_E_T_ = ' '
		A0001 += "    AND SB1.D_E_L_E_T_ = ' '
		A0001 += " UNION ALL
		//Exportação
		A0001 += " SELECT 'X'             QUADRO,
		A0001 += "        B1_YTPPROD,
		A0001 += "        SUM(D2_QUANT)   AS QUANT1,
		A0001 += "        SUM(D2_QTSEGUM) AS QUANT2,
		A0001 += "        SUM(D2_TOTAL)   AS TOTAL,
		A0001 += "        SUM(D2_VALIPI)  AS VALIPI,
		A0001 += "        SUM(D2_VALICM)  AS VALICM,
		A0001 += "        0               AS PIS,
		A0001 += "        0               AS COFINS
		A0001 += "   FROM SD2010 SD2,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF2010 SF2,
		A0001 += "        ZZ6010 ZZ6
		A0001 += "  WHERE SD2.D2_FILIAL = '01'
		A0001 += "    AND SD2.D2_GRUPO = 'PA'
		A0001 += "    AND SD2.D2_COD BETWEEN 'A' AND 'ZZZZZZZZZZZZZZZ'
		A0001 += "    AND SD2.D2_CF IN ( '7101', '5501', '6501', '7501' )
		A0001 += "    AND ( ZZ6_EMP IN ( 'B', 'A' )
		A0001 += "           OR B1_YFORMAT = 'BA' )
		A0001 += "    AND SF2.F2_FILIAL = '01'
		A0001 += "    AND SF2.F2_DOC = SD2.D2_DOC
		A0001 += "    AND SF2.F2_SERIE = SD2.D2_SERIE
		A0001 += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
		A0001 += "    AND SF2.F2_LOJA = SD2.D2_LOJA
		A0001 += "    AND SF2.F2_SERIE BETWEEN '   ' AND 'ZZZ'
		A0001 += "    AND SF2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SF2.F2_CLIENTE BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_VEND1 BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_YEMP IN ( '0101' )
		A0001 += "    AND SF2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_YFORMAT = ZZ6_COD
		A0001 += "    AND SD2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_FILIAL = '  '
		A0001 += "    AND SB1.B1_COD = SD2.D2_COD
		A0001 += "    AND SB1.B1_TIPO = 'PA'
		A0001 += "    AND SB1.B1_UM = 'M2'
		A0001 += "    AND SB1.B1_YCLASSE BETWEEN '1' AND '5'
		A0001 += "    AND SUBSTRING(SB1.B1_COD, 1, 1) >= 'A'
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY B1_YTPPROD
		A0001 += "  ORDER BY QUADRO, B1_YTPPROD
		A0001 := ChangeQuery(A0001)
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			aAdd(aDados2, { A001->QUADRO,;
			A001->B1_YTPPROD,;
			Transform(A001->QUANT1     ,"@E 999,999,999.9999"),;
			Transform(A001->QUANT2     ,"@E 999,999,999.9999"),;
			Transform(A001->TOTAL      ,"@E 999,999,999.9999"),;
			Transform(A001->VALIPI     ,"@E 999,999,999.9999"),;
			Transform(A001->VALICM     ,"@E 999,999,999.9999"),;
			Transform(A001->PIS        ,"@E 999,999,999.9999"),;
			Transform(A001->COFINS     ,"@E 999,999,999.9999")})

			dbSelectArea("A001")
			dbSkip()
		End
		aStru1 := ("A001")->(dbStruct())
		A001->(dbCloseArea())

	ElseIf nRadMenu1 == 11                            //Receita Liquida por Empresa
		***************************************************************************

		If cEmpAnt <> "01"
			MsgSTOP("Esta opção somente poderá ser executada na empresa Biancogres","Atenção")
			Return
		EndIf

		fPerg := "BIA29103"
		ktNomArq := "rec_lq_emp"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		Vld03Prg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		//Faturamento da empresa Biancogres considerando Biancogres sem LM e depois faturamento da Biancogres na LM por produto.
		A0001 := " SELECT D2_COD,
		A0001 += "        SUM(D2_QUANT) AS QUANT1,
		A0001 += "        SUM(D2_QTSEGUM) AS QUANT2,
		A0001 += "        SUM(D2_TOTAL) AS TOTAL,
		A0001 += "        SUM(D2_VALIPI) AS VALIPI,
		A0001 += "        SUM(D2_VALICM) AS VALICM,
		A0001 += "        SUM(D2_VALIMP6) AS PIS,
		A0001 += "        SUM(D2_VALIMP5) AS COFINS,
		A0001 += "        'Faturamento da empresa Biancogres considerando Biancogres sem LM e depois faturamento da Biancogres na LM por produto' SITUACAO
		A0001 += "   FROM SD2010 SD2,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF2010 SF2,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SF4010 SF4
		A0001 += "  WHERE SD2.D2_FILIAL = '01'
		A0001 += "    AND SD2.D2_GRUPO = 'PA'
		A0001 += "    AND SD2.D2_COD BETWEEN 'A' AND 'ZZZZZZZZZZZZZZZ'
		A0001 += "    AND SD2.D2_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_DUPLIC = 'S'
		A0001 += "    AND SF4.D_E_L_E_T_ = ''
		A0001 += "    AND SF2.F2_CLIENTE <> '010064'
		A0001 += "    AND SF2.F2_YEMP IN ( '0101' )
		A0001 += "    AND SF2.F2_FILIAL = '01'
		A0001 += "    AND SF2.F2_DOC = SD2.D2_DOC
		A0001 += "    AND SF2.F2_SERIE = SD2.D2_SERIE
		A0001 += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
		A0001 += "    AND SF2.F2_LOJA = SD2.D2_LOJA
		A0001 += "    AND SF2.F2_SERIE BETWEEN '   ' AND 'ZZZ'
		A0001 += "    AND SF2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SF2.F2_CLIENTE BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_VEND1 BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_YFORMAT = ZZ6_COD
		A0001 += "    AND SD2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_FILIAL = '  '
		A0001 += "    AND SB1.B1_COD = SD2.D2_COD
		A0001 += "    AND SB1.B1_TIPO = 'PA'
		A0001 += "    AND SB1.B1_YCLASSE BETWEEN '1' AND '5'
		A0001 += "    AND SB1.B1_UM = 'M2'
		A0001 += "    AND SUBSTRING(SB1.B1_COD, 1, 1) >= 'A'
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY D2_COD
		A0001 += " UNION ALL
		A0001 += " SELECT D2_COD,
		A0001 += "        SUM(D2_QUANT) AS QUANT1,
		A0001 += "        SUM(D2_QTSEGUM) AS QUANT2,
		A0001 += "        SUM(D2_TOTAL) AS TOTAL,
		A0001 += "        SUM(D2_VALIPI) AS VALIPI,
		A0001 += "        SUM(D2_VALICM) AS VALICM,
		A0001 += "        SUM(D2_VALIMP6) AS PIS,
		A0001 += "        SUM(D2_VALIMP5) AS COFINS,
		A0001 += "        'Faturamento da empresa Biancogres considerando Biancogres sem LM e depois faturamento da Biancogres na LM por produto' SITUACAO
		A0001 += "   FROM SD2070 SD2,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF2070 SF2,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SF4070 SF4
		A0001 += "  WHERE SD2.D2_FILIAL = '01'
		A0001 += "    AND SD2.D2_GRUPO = 'PA'
		A0001 += "    AND SD2.D2_COD BETWEEN 'A' AND 'ZZZZZZZZZZZZZZZ'
		A0001 += "    AND SD2.D2_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_DUPLIC = 'S'
		A0001 += "    AND SF4.D_E_L_E_T_ = ''
		A0001 += "    AND SF2.F2_YEMP IN ( '0101' )
		A0001 += "    AND SF2.F2_FILIAL = '01'
		A0001 += "    AND SF2.F2_DOC = SD2.D2_DOC
		A0001 += "    AND SF2.F2_SERIE = SD2.D2_SERIE
		A0001 += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
		A0001 += "    AND SF2.F2_LOJA = SD2.D2_LOJA
		A0001 += "    AND SF2.F2_SERIE BETWEEN '   ' AND 'ZZZ'
		A0001 += "    AND SF2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SF2.F2_CLIENTE BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_VEND1 BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_YFORMAT = ZZ6_COD
		A0001 += "    AND SD2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_FILIAL = '  '
		A0001 += "    AND SB1.B1_COD = SD2.D2_COD
		A0001 += "    AND SB1.B1_TIPO = 'PA'
		A0001 += "    AND SB1.B1_YCLASSE BETWEEN '1' AND '5'
		A0001 += "    AND SB1.B1_UM = 'M2'
		A0001 += "    AND SUBSTRING(SB1.B1_COD, 1, 1) >= 'A'
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY D2_COD
		A0001 += " UNION ALL
		//Faturamento da empresa Incesa considerando Incesa sem LM e depois faturamento da Incesa na LM por produto.
		A0001 += " SELECT D2_COD,
		A0001 += "        SUM(D2_QUANT) AS QUANT1,
		A0001 += "        SUM(D2_QTSEGUM) AS QUANT2,
		A0001 += "        SUM(D2_TOTAL) AS TOTAL,
		A0001 += "        SUM(D2_VALIPI) AS VALIPI,
		A0001 += "        SUM(D2_VALICM) AS VALICM,
		A0001 += "        SUM(D2_VALIMP6) AS PIS,
		A0001 += "        SUM(D2_VALIMP5) AS COFINS,
		A0001 += "        'Faturamento da empresa Incesa considerando Incesa sem LM e depois faturamento da Incesa na LM por produto' SITUACAO
		A0001 += "   FROM SD2050 SD2,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF2050 SF2,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SF4050 SF4
		A0001 += "  WHERE SD2.D2_FILIAL = '01'
		A0001 += "    AND SD2.D2_GRUPO = 'PA'
		A0001 += "    AND SD2.D2_COD BETWEEN 'A' AND 'ZZZZZZZZZZZZZZZ'
		A0001 += "    AND SD2.D2_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_DUPLIC = 'S'
		A0001 += "    AND SF4.D_E_L_E_T_ = ''
		A0001 += "    AND SF2.F2_CLIENTE <> '010064'
		A0001 += "    AND SF2.F2_CLIENTE <> '000481'
		A0001 += "    AND SF2.F2_YEMP IN ( '0501', '0599' )
		A0001 += "    AND SF2.F2_FILIAL = '01'
		A0001 += "    AND SF2.F2_DOC = SD2.D2_DOC
		A0001 += "    AND SF2.F2_SERIE = SD2.D2_SERIE
		A0001 += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
		A0001 += "    AND SF2.F2_LOJA = SD2.D2_LOJA
		A0001 += "    AND SF2.F2_SERIE BETWEEN '   ' AND 'ZZZ'
		A0001 += "    AND SF2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SF2.F2_CLIENTE BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_VEND1 BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_YFORMAT = ZZ6_COD
		A0001 += "    AND SD2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_FILIAL = '  '
		A0001 += "    AND SB1.B1_COD = SD2.D2_COD
		A0001 += "    AND SB1.B1_TIPO = 'PA'
		A0001 += "    AND SB1.B1_YCLASSE BETWEEN '1' AND '5'
		A0001 += "    AND SB1.B1_UM = 'M2'
		A0001 += "    AND SUBSTRING(SB1.B1_COD, 1, 1) >= 'A'
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY D2_COD
		A0001 += " UNION ALL
		A0001 += " SELECT D2_COD,
		A0001 += "        SUM(D2_QUANT) AS QUANT1,
		A0001 += "        SUM(D2_QTSEGUM) AS QUANT2,
		A0001 += "        SUM(D2_TOTAL) AS TOTAL,
		A0001 += "        SUM(D2_VALIPI) AS VALIPI,
		A0001 += "        SUM(D2_VALICM) AS VALICM,
		A0001 += "        SUM(D2_VALIMP6) AS PIS,
		A0001 += "        SUM(D2_VALIMP5) AS COFINS,
		A0001 += "        'Faturamento da empresa Incesa considerando Incesa sem LM e depois faturamento da Incesa na LM por produto' SITUACAO
		A0001 += "   FROM SD2070 SD2,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF2070 SF2,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SF4070 SF4
		A0001 += "  WHERE SD2.D2_FILIAL = '01'
		A0001 += "    AND SD2.D2_GRUPO = 'PA'
		A0001 += "    AND SD2.D2_COD BETWEEN 'A' AND 'ZZZZZZZZZZZZZZZ'
		A0001 += "    AND SD2.D2_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_DUPLIC = 'S'
		A0001 += "    AND SF4.D_E_L_E_T_ = ''
		A0001 += "    AND SF2.F2_YEMP IN ( '0501', '0599' )
		A0001 += "    AND SF2.F2_FILIAL = '01'
		A0001 += "    AND SF2.F2_DOC = SD2.D2_DOC
		A0001 += "    AND SF2.F2_SERIE = SD2.D2_SERIE
		A0001 += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
		A0001 += "    AND SF2.F2_LOJA = SD2.D2_LOJA
		A0001 += "    AND SF2.F2_SERIE BETWEEN '   ' AND 'ZZZ'
		A0001 += "    AND SF2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SF2.F2_CLIENTE BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_VEND1 BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_YFORMAT = ZZ6_COD
		A0001 += "    AND SD2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_FILIAL = '  '
		A0001 += "    AND SB1.B1_COD = SD2.D2_COD
		A0001 += "    AND SB1.B1_TIPO = 'PA'
		A0001 += "    AND SB1.B1_YCLASSE BETWEEN '1' AND '5'
		A0001 += "    AND SB1.B1_UM = 'M2'
		A0001 += "    AND SUBSTRING(SB1.B1_COD, 1, 1) >= 'A'
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY D2_COD
		A0001 += " UNION ALL
		//Faturamento TOTAL da empresa Biancogres para todos os clientes inclusive LM por produto.
		A0001 += " SELECT D2_COD,
		A0001 += "        SUM(D2_QUANT) AS QUANT1,
		A0001 += "        SUM(D2_QTSEGUM) AS QUANT2,
		A0001 += "        SUM(D2_TOTAL) AS TOTAL,
		A0001 += "        SUM(D2_VALIPI) AS VALIPI,
		A0001 += "        SUM(D2_VALICM) AS VALICM,
		A0001 += "        SUM(D2_VALIMP6) AS PIS,
		A0001 += "        SUM(D2_VALIMP5) AS COFINS,
		A0001 += "        'Faturamento TOTAL da empresa Biancogres para todos os clientes inclusive LM por produto' SITUACAO
		A0001 += "   FROM SD2010 SD2,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF2010 SF2,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SF4010 SF4
		A0001 += "  WHERE SD2.D2_FILIAL = '01'
		A0001 += "    AND SD2.D2_GRUPO = 'PA'
		A0001 += "    AND SD2.D2_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_DUPLIC = 'S'
		A0001 += "    AND SF4.D_E_L_E_T_ = ''
		A0001 += "    AND SF2.F2_FILIAL = '01'
		A0001 += "    AND SF2.F2_DOC = SD2.D2_DOC
		A0001 += "    AND SF2.F2_SERIE = SD2.D2_SERIE
		A0001 += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
		A0001 += "    AND SF2.F2_LOJA = SD2.D2_LOJA
		A0001 += "    AND SF2.F2_SERIE BETWEEN '   ' AND 'ZZZ'
		A0001 += "    AND SF2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SF2.F2_CLIENTE BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_VEND1 BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_YFORMAT = ZZ6_COD
		A0001 += "    AND SD2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_FILIAL = '  '
		A0001 += "    AND SB1.B1_COD = SD2.D2_COD
		A0001 += "    AND SB1.B1_UM = 'M2'
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY D2_COD
		A0001 += " UNION ALL
		//Faturamento TOTAL da empresa Incesa para todos os clientes inclusive LM por produto.
		A0001 += " SELECT D2_COD,
		A0001 += "        SUM(D2_QUANT) AS QUANT1,
		A0001 += "        SUM(D2_QTSEGUM) AS QUANT2,
		A0001 += "        SUM(D2_TOTAL) AS TOTAL,
		A0001 += "        SUM(D2_VALIPI) AS VALIPI,
		A0001 += "        SUM(D2_VALICM) AS VALICM,
		A0001 += "        SUM(D2_VALIMP6) AS PIS,
		A0001 += "        SUM(D2_VALIMP5) AS COFINS,
		A0001 += "        'Faturamento TOTAL da empresa Incesa para todos os clientes inclusive LM por produto' SITUACAO
		A0001 += "   FROM SD2050 SD2,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF2050 SF2,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SF4050 SF4
		A0001 += "  WHERE SD2.D2_FILIAL = '01'
		A0001 += "    AND SD2.D2_GRUPO = 'PA'
		A0001 += "    AND SD2.D2_COD BETWEEN 'A' AND 'ZZZZZZZZZZZZZZZ'
		A0001 += "    AND SD2.D2_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_DUPLIC = 'S'
		A0001 += "    AND SF4.D_E_L_E_T_ = ''
		A0001 += "    AND SF2.F2_FILIAL = '01'
		A0001 += "    AND SF2.F2_DOC = SD2.D2_DOC
		A0001 += "    AND SF2.F2_SERIE = SD2.D2_SERIE
		A0001 += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
		A0001 += "    AND SF2.F2_LOJA = SD2.D2_LOJA
		A0001 += "    AND SF2.F2_SERIE BETWEEN '   ' AND 'ZZZ'
		A0001 += "    AND SF2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SF2.F2_CLIENTE BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_VEND1 BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_YFORMAT = ZZ6_COD
		A0001 += "    AND SD2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_FILIAL = '  '
		A0001 += "    AND SB1.B1_COD = SD2.D2_COD
		A0001 += "    AND SB1.B1_TIPO = 'PA'
		A0001 += "    AND SB1.B1_YCLASSE BETWEEN '1' AND '5'
		A0001 += "    AND SB1.B1_UM = 'M2'
		A0001 += "    AND SUBSTRING(SB1.B1_COD, 1, 1) >= 'A'
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY D2_COD
		A0001 += " UNION ALL
		//Faturamento TOTAL da empresa LM para todos os clientes por produto.
		A0001 += " SELECT D2_COD,
		A0001 += "        SUM(D2_QUANT) AS QUANT1,
		A0001 += "        SUM(D2_QTSEGUM) AS QUANT2,
		A0001 += "        SUM(D2_TOTAL) AS TOTAL,
		A0001 += "        SUM(D2_VALIPI) AS VALIPI,
		A0001 += "        SUM(D2_VALICM) AS VALICM,
		A0001 += "        SUM(D2_VALIMP6) AS PIS,
		A0001 += "        SUM(D2_VALIMP5) AS COFINS,
		A0001 += "        'Faturamento TOTAL da empresa LM para todos os clientes por produto' SITUACAO
		A0001 += "   FROM SD2070 SD2,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF2070 SF2,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SF4070 SF4
		A0001 += "  WHERE SD2.D2_FILIAL = '01'
		A0001 += "    AND SD2.D2_GRUPO = 'PA'
		A0001 += "    AND SD2.D2_COD BETWEEN 'A' AND 'ZZZZZZZZZZZZZZZ'
		A0001 += "    AND SD2.D2_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_DUPLIC = 'S'
		A0001 += "    AND SD2.D2_TIPO <> 'D'
		A0001 += "    AND SF4.D_E_L_E_T_ = ''
		A0001 += "    AND SF2.F2_YEMP IN ( '0101', '0501', '0599' )
		A0001 += "    AND SF2.F2_FILIAL = '01'
		A0001 += "    AND SF2.F2_DOC = SD2.D2_DOC
		A0001 += "    AND SF2.F2_SERIE = SD2.D2_SERIE
		A0001 += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
		A0001 += "    AND SF2.F2_LOJA = SD2.D2_LOJA
		A0001 += "    AND SF2.F2_SERIE BETWEEN '   ' AND 'ZZZ'
		A0001 += "    AND SF2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SF2.F2_CLIENTE BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_VEND1 BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_YFORMAT = ZZ6_COD
		A0001 += "    AND SD2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_FILIAL = '  '
		A0001 += "    AND SB1.B1_COD = SD2.D2_COD
		A0001 += "    AND SB1.B1_TIPO = 'PA'
		A0001 += "    AND SB1.B1_YCLASSE BETWEEN '1' AND '5'
		A0001 += "    AND SB1.B1_UM = 'M2'
		A0001 += "    AND SUBSTRING(SB1.B1_COD, 1, 1) >= 'A'
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY D2_COD
		A0001 += " UNION ALL
		//Faturamento TOTAL da empresa Mundi para todos os clientes por produto.
		A0001 += " SELECT D2_COD,
		A0001 += "        SUM(D2_QUANT) AS QUANT1,
		A0001 += "        SUM(D2_QTSEGUM) AS QUANT2,
		A0001 += "        SUM(D2_TOTAL) AS TOTAL,
		A0001 += "        SUM(D2_VALIPI) AS VALIPI,
		A0001 += "        SUM(D2_VALICM) AS VALICM,
		A0001 += "        SUM(D2_VALIMP6) AS PIS,
		A0001 += "        SUM(D2_VALIMP5) AS COFINS,
		A0001 += "        'Faturamento TOTAL da empresa Mundi para todos os clientes por produto' SITUACAO
		A0001 += "   FROM SD2130 SD2,
		A0001 += "        SB1010 SB1,
		A0001 += "        SF2130 SF2,
		A0001 += "        ZZ6010 ZZ6,
		A0001 += "        SF4130 SF4
		A0001 += "  WHERE SD2.D2_FILIAL = '01'
		A0001 += "    AND SD2.D2_GRUPO = 'PA'
		A0001 += "    AND SD2.D2_COD BETWEEN 'A' AND 'ZZZZZZZZZZZZZZZ'
		A0001 += "    AND SD2.D2_TES = SF4.F4_CODIGO
		A0001 += "    AND SF4.F4_DUPLIC = 'S'
		A0001 += "    AND SF4.D_E_L_E_T_ = ''
		A0001 += "    AND SF2.F2_FILIAL = '01'
		A0001 += "    AND SF2.F2_DOC = SD2.D2_DOC
		A0001 += "    AND SF2.F2_SERIE = SD2.D2_SERIE
		A0001 += "    AND SF2.F2_CLIENTE = SD2.D2_CLIENTE
		A0001 += "    AND SF2.F2_LOJA = SD2.D2_LOJA
		A0001 += "    AND SF2.F2_SERIE BETWEEN '   ' AND 'ZZZ'
		A0001 += "    AND SF2.F2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SF2.F2_CLIENTE BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.F2_VEND1 BETWEEN '      ' AND 'ZZZZZZ'
		A0001 += "    AND SF2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_YFORMAT = ZZ6_COD
		A0001 += "    AND SD2.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.B1_FILIAL = '  '
		A0001 += "    AND SB1.B1_COD = SD2.D2_COD
		A0001 += "    AND SB1.B1_TIPO = 'PA'
		A0001 += "    AND SB1.B1_YCLASSE BETWEEN '1' AND '5'
		A0001 += "    AND SB1.B1_UM = 'M2'
		A0001 += "    AND SUBSTRING(SB1.B1_COD, 1, 1) >= 'A'
		A0001 += "    AND ZZ6.D_E_L_E_T_ = ''
		A0001 += "    AND SB1.D_E_L_E_T_ = ''
		A0001 += "  GROUP BY D2_COD
		A0001 := ChangeQuery(A0001)
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			aAdd(aDados2, { A001->D2_COD,;
			Transform(A001->QUANT1     ,"@E 999,999,999.9999"),;
			Transform(A001->QUANT2     ,"@E 999,999,999.9999"),;
			Transform(A001->TOTAL      ,"@E 999,999,999.9999"),;
			Transform(A001->VALIPI     ,"@E 999,999,999.9999"),;
			Transform(A001->VALICM     ,"@E 999,999,999.9999"),;
			Transform(A001->PIS        ,"@E 999,999,999.9999"),;
			Transform(A001->COFINS     ,"@E 999,999,999.9999"),;
			A001->SITUACAO})

			dbSelectArea("A001")
			dbSkip()
		End
		aStru1 := ("A001")->(dbStruct())
		A001->(dbCloseArea())

	ElseIf nRadMenu1 == 12                                          // Vendas Mundi
		***************************************************************************

		fPerg := "BIA29103"
		ktNomArq := "vendasmundi"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		Vld03Prg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		A0001 := " SELECT D2_DOC,
		A0001 += "        D2_SERIE,
		A0001 += "        D2_COD,
		A0001 += "        D2_QUANT,
		A0001 += "        D2_PRCVEN,
		A0001 += "        D2_TOTAL,
		A0001 += "        ROUND(( D2_TOTAL * D2_COMIS1 ) / 100, 2) COMIS,
		A0001 += "        D2_VALICM ICMS,
		A0001 += "        D2_VALIMP6 PIS,
		A0001 += "        D2_VALIMP5 COFINS
		A0001 += "   FROM SD2070
		A0001 += "  WHERE D2_FILIAL = '01'
		A0001 += "    AND D2_PEDIDO IN (SELECT C5_NUM
		A0001 += "                        FROM SC5070
		A0001 += "                       WHERE C5_FILIAL = '01'
		A0001 += "                         AND SUBSTRING(C5_YPEDORI, 1, 1) = 'M'
		A0001 += "                         AND D_E_L_E_T_ = '')
		A0001 += "    AND D2_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND D_E_L_E_T_ = ' '
		A0001 := ChangeQuery(A0001)
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			aAdd(aDados2, { A001->D2_DOC,;
			A001->D2_SERIE,;
			A001->D2_COD,;
			Transform(A001->D2_QUANT   ,"@E 999,999,999.9999"),;
			Transform(A001->D2_PRCVEN  ,"@E 999,999,999.9999"),;
			Transform(A001->D2_TOTAL   ,"@E 999,999,999.9999"),;
			Transform(A001->COMIS      ,"@E 999,999,999.9999"),;
			Transform(A001->ICMS       ,"@E 999,999,999.9999"),;
			Transform(A001->PIS        ,"@E 999,999,999.9999"),;
			Transform(A001->COFINS     ,"@E 999,999,999.9999")})

			dbSelectArea("A001")
			dbSkip()
		End
		aStru1 := ("A001")->(dbStruct())
		A001->(dbCloseArea())

	ElseIf nRadMenu1 == 13                                          //Mov. CLVL New
		//            Criado em 26/04/13 para atender nova forma de rateio de custo
		***************************************************************************

		fPerg := "BIA29103"
		ktNomArq := "mov_clvl"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		Vld03Prg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		aStru1   := { {"CODIGO"    , "C", 20, 0},;
		{              "DESCRICAO" , "C", 30, 0} }

		// Acumulador
		T0001 := " SELECT CLVL
		T0001 += "   FROM (SELECT CQ6_CLVL CLVL
		T0001 += "           FROM "+RetSqlName("CQ6")+" CQ6
		T0001 += "          WHERE CQ6_FILIAL = '"+xFilial("CQ6")+"'
		T0001 += "            AND CQ6_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		T0001 += "            AND SUBSTRING(CQ6_CONTA,1,1) IN('3','6')
		T0001 += "            AND CQ6.D_E_L_E_T_ = ' '
		T0001 += "          GROUP BY CQ6_CLVL) AS DADOS
		T0001 += "  GROUP BY CLVL
		T0001 += "  ORDER BY CLVL
		TCQUERY T0001 New Alias "T001"
		dbSelectArea("T001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			aAdd(aStru1, { T001->CLVL  , "C", 18, 0 })

			dbSelectArea("T001")
			dbSkip()
		End
		T001->(dbCloseArea())

		// Conteúdo
		A0001 := " SELECT CQ6_CONTA, CT1_DESC01, CLVL, SUM(SALDO) SALDO
		A0001 += "   FROM (SELECT CQ6_CONTA,
		A0001 += "                CT1_DESC01,
		A0001 += "                CQ6_CLVL CLVL,
		A0001 += "                SUM(CQ6_DEBITO - CQ6_CREDIT) * ( -1 )        SALDO
		A0001 += "           FROM "+RetSqlName("CQ6")+" CQ6
		A0001 += "          INNER JOIN "+RetSqlName("CT1")+" CT1 ON CT1_FILIAL = '"+xFilial("CT1")+"'
		A0001 += "                               AND CT1_CONTA = CQ6_CONTA
		A0001 += "                               AND CT1.D_E_L_E_T_ = ' '
		A0001 += "          WHERE CQ6_FILIAL = '"+xFilial("CQ6")+"'
		A0001 += "            AND CQ6_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "            AND SUBSTRING(CQ6_CONTA, 1, 1) IN( '3', '6' )
		A0001 += "            AND CQ6.D_E_L_E_T_ = ' '
		A0001 += "          GROUP BY CQ6_CONTA,
		A0001 += "                   CT1_DESC01,
		A0001 += "                   CQ6_CLVL) AS VALORES
		A0001 += "  GROUP BY CQ6_CONTA,
		A0001 += "           CT1_DESC01,
		A0001 += "           CLVL
		A0001 += "  ORDER BY CQ6_CONTA,
		A0001 += "           CT1_DESC01,
		A0001 += "           CLVL
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			Aadd(aDados2, Array( Len(aStru1) ) )
			sfPosic := Len(aDados2)
			aDados2[sfPosic][1] := A001->CQ6_CONTA
			aDados2[sfPosic][2] := A001->CT1_DESC01

			swConta := A001->CQ6_CONTA
			While !Eof() .and. A001->CQ6_CONTA == swConta

				vsValor := 0
				vsPsRef := 1
				For xxn := 1 to Len(aStru1)
					xcCampo := Trim(aStru1[xxn][1])
					If Alltrim(xcCampo) == Alltrim(A001->CLVL)
						vsValor := A001->SALDO
						vsPsRef := xxn
					Endif
				Next

				aDados2[sfPosic][vsPsRef] := Transform(vsValor  ,"@E 999,999,999.9999")

				dbSelectArea("A001")
				dbSkip()
			End
		End
		A001->(dbCloseArea())

	ElseIf nRadMenu1 == 14                                   //Peso Ticket c/ Custo
		***************************************************************************

		fPerg := "BIA29106"
		ktNomArq := "pesoticketcusto"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		Vld06Prg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		A0001 := " SELECT SD1.D1_DTDIGIT,
		A0001 += "        SF1.F1_ESPECIE,
		A0001 += "        SD1.D1_COD,
		A0001 += "        SUBSTRING(SB1.B1_DESC,1,70) DESCRIC,
		A0001 += "        SD1.D1_DOC,
		A0001 += "        SD1.D1_ITEM,
		A0001 += "        SD1.D1_FORNECE,
		A0001 += "        SD1.D1_LOJA,
		A0001 += "        SD1.D1_UM,
		A0001 += "        SD1.D1_QUANT,
		A0001 += "        SD1.D1_YTICKET,
		A0001 += "        SD1.D1_CUSTO
		A0001 += "   FROM "+RetSqlName("SD1")+" SD1
		A0001 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'
		A0001 += "                       AND SB1.B1_COD = SD1.D1_COD
		A0001 += "                       AND SUBSTRING(SB1.B1_GRUPO,1,3) = '101'
		A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
		A0001 += "  INNER JOIN "+RetSqlName("SF1")+" SF1 ON SF1.F1_FILIAL = '"+xFilial("SF1")+"'
		A0001 += "                       AND SF1.F1_DOC = SD1.D1_DOC
		A0001 += "                       AND SF1.F1_SERIE = SD1.D1_SERIE
		A0001 += "                       AND SF1.F1_FORNECE = SD1.D1_FORNECE
		A0001 += "                       AND SF1.F1_LOJA = SD1.D1_LOJA
		A0001 += "                       AND SF1.F1_DTDIGIT = SD1.D1_DTDIGIT
		A0001 += "                       AND SF1.D_E_L_E_T_ = ' '
		A0001 += "  INNER JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL = '"+xFilial("SF4")+"'
		A0001 += "                       AND SF4.F4_CODIGO = SD1.D1_TES
		A0001 += "                       AND SF4.F4_ESTOQUE = 'S'
		A0001 += "                       AND SF4.D_E_L_E_T_ = ' '
		A0001 += "  WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'
		A0001 += "    AND SD1.D1_DTDIGIT BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SD1.D1_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
		A0001 += "    AND SD1.D1_FORNECE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'
		A0001 += "    AND SD1.D_E_L_E_T_ = ' '
		A0001 += "  ORDER BY SD1.D1_COD,
		A0001 += "           SD1.D1_DTDIGIT,
		A0001 += "           SD1.R_E_C_N_O_,
		A0001 += "           SD1.D1_DOC
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			aAdd(aDados2, { dtoc(stod(A001->D1_DTDIGIT)),;
			A001->F1_ESPECIE,;
			A001->D1_COD,;
			StrTran(A001->DESCRIC ,";","-") ,;
			A001->D1_DOC,;
			A001->D1_ITEM,;
			A001->D1_FORNECE,;
			A001->D1_LOJA,;
			A001->D1_UM,;
			Transform(A001->D1_QUANT    ,"@E 999,999,999.9999"),;
			Transform(A001->D1_YTICKET  ,"@E 999,999,999.9999"),;
			Transform(A001->D1_CUSTO    ,"@E 999,999,999.9999")})

			dbSelectArea("A001")
			dbSkip()
		End
		aStru1 := ("A001")->(dbStruct())
		A001->(dbCloseArea())

	ElseIf nRadMenu1 == 15                                //Mov. CLVL em Linha (Ms)
		***************************************************************************

		fPerg := "BIA29103"
		ktNomArq := "mov_clvl"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		Vld03Prg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		A0001 := " SELECT PERIODO, CQ6_CONTA, CT1_DESC01, CLVL, SUM(SALDO) SALDO
		A0001 += "   FROM (SELECT SUBSTRING(CQ6_DATA, 1, 6) PERIODO,
		A0001 += "                CQ6_CONTA,
		A0001 += "                CT1_DESC01,
		A0001 += "                CQ6_CLVL CLVL,
		A0001 += "                SUM(CQ6_DEBITO - CQ6_CREDIT) * ( -1 )        SALDO
		A0001 += "           FROM "+RetSqlName("CQ6")+" CQ6
		A0001 += "          INNER JOIN "+RetSqlName("CT1")+" CT1 ON CT1_FILIAL = '"+xFilial("CT1")+"'
		A0001 += "                               AND CT1_CONTA = CQ6_CONTA
		A0001 += "                               AND CT1.D_E_L_E_T_ = ' '
		A0001 += "          WHERE CQ6_FILIAL = '"+xFilial("CQ6")+"'
		A0001 += "            AND CQ6_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "            AND SUBSTRING(CQ6_CONTA, 1, 1) IN( '3', '6' )
		A0001 += "            AND CQ6.D_E_L_E_T_ = ' '
		A0001 += "          GROUP BY SUBSTRING(CQ6_DATA, 1, 6),
		A0001 += "                   CQ6_CONTA,
		A0001 += "                   CT1_DESC01,
		A0001 += "                   CQ6_CLVL) AS VALORES
		A0001 += "  GROUP BY PERIODO,
		A0001 += "           CQ6_CONTA,
		A0001 += "           CT1_DESC01,
		A0001 += "           CLVL
		A0001 += "  ORDER BY PERIODO,
		A0001 += "           CQ6_CONTA,
		A0001 += "           CT1_DESC01,
		A0001 += "           CLVL
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			aAdd(aDados2, { A001->PERIODO,;
			A001->CQ6_CONTA,;
			A001->CT1_DESC01,;
			A001->CLVL,;
			Transform(A001->SALDO    ,"@E 999,999,999.9999")})

			dbSelectArea("A001")
			dbSkip()
		End
		aStru1 := ("A001")->(dbStruct())
		A001->(dbCloseArea())

	ElseIf nRadMenu1 == 16                                   //Mvto de Estoque (Ms)
		***************************************************************************

		fPerg := "BIA29103"
		ktNomArq := "mov_clvl"
		fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
		Vld03Prg()
		If !Pergunte(fPerg,.T.)
			Return
		EndIf

		A0001 := " SELECT 'BIANCOGRES' EMPR,
		A0001 += "        D3_EMISSAO,
		A0001 += "        D3_DOC,
		A0001 += "        D3_TM,
		A0001 += "        F5_TEXTO,
		A0001 += "        D3_COD,
		A0001 += "        SUBSTRING(B1_DESC,1,70) B1_DESC,
		A0001 += "        D3_UM,
		A0001 += "        D3_TIPO,
		A0001 += "        D3_GRUPO,
		A0001 += "        D3_QUANT,
		A0001 += "        D3_CUSTO1,
		A0001 += "        D3_YOBS
		A0001 += "   FROM SD3010 SD3 WITH (NOLOCK)
		A0001 += "  INNER JOIN SB1010 SB1 WITH (NOLOCK) ON B1_FILIAL = '  '
		A0001 += "                       AND B1_COD = D3_COD
		A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
		A0001 += "  INNER JOIN SF5010 SF5 WITH (NOLOCK) ON F5_FILIAL = '01'
		A0001 += "                       AND F5_CODIGO = D3_TM
		A0001 += "                       AND SF5.D_E_L_E_T_ = ' '
		A0001 += "  WHERE D3_FILIAL = '01'
		A0001 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND D3_OP = '             '
		A0001 += "    AND D3_CF NOT IN('DE4','RE4','DE3','RE3','DE7','RE7')
		A0001 += "    AND D3_TIPO NOT IN('PI','PP')
		A0001 += "    AND D3_TM NOT IN('352','015','353')
		A0001 += "    AND D3_ESTORNO = '  '
		// Retirada em 08/09/15 por solicitação do Jecimar. implementado Marcos Alberto Soprani
		//A0001 += "    AND D3_USUARIO <> ' '
		A0001 += "    AND SD3.D_E_L_E_T_ = ' '
		// Incluído em 08/06/16 por Marcos Alberto Soprani
		A0001 += "  UNION ALL
		A0001 := " SELECT 'BIANCOGRES' EMPR,
		A0001 += "        D3_EMISSAO,
		A0001 += "        D3_DOC,
		A0001 += "        D3_TM,
		A0001 += "        'REQUISICAO AUTOMATICA' F5_TEXTO,
		A0001 += "        D3_COD,
		A0001 += "        SUBSTRING(B1_DESC,1,70) B1_DESC,
		A0001 += "        D3_UM,
		A0001 += "        D3_TIPO,
		A0001 += "        D3_GRUPO,
		A0001 += "        D3_QUANT,
		A0001 += "        D3_CUSTO1,
		A0001 += "        D3_YOBS
		A0001 += "   FROM SD3010 SD3 WITH (NOLOCK)
		A0001 += "  INNER JOIN SB1010 SB1 WITH (NOLOCK) ON B1_FILIAL = '  '
		A0001 += "                       AND B1_COD = D3_COD
		A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
		A0001 += "  WHERE D3_FILIAL = '01'
		A0001 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND SUBSTRING(D3_COD,1,2) = 'C1'
		A0001 += "    AND D3_OP <> '             '
		A0001 += "    AND D3_CF NOT IN('DE4','RE4','DE3','RE3','DE7','RE7')
		A0001 += "    AND D3_TIPO NOT IN('PI','PP')
		A0001 += "    AND D3_TM NOT IN('352', '015', '353', '010')
		A0001 += "    AND D3_ESTORNO = '  '
		A0001 += "    AND SD3.D_E_L_E_T_ = ' '
		A0001 += "  UNION ALL
		A0001 += " SELECT 'INCESA' EMPR,
		A0001 += "        D3_EMISSAO,
		A0001 += "        D3_DOC,
		A0001 += "        D3_TM,
		A0001 += "        F5_TEXTO,
		A0001 += "        D3_COD,
		A0001 += "        SUBSTRING(B1_DESC,1,70) B1_DESC,
		A0001 += "        D3_UM,
		A0001 += "        D3_TIPO,
		A0001 += "        D3_GRUPO,
		A0001 += "        D3_QUANT,
		A0001 += "        D3_CUSTO1,
		A0001 += "        D3_YOBS
		A0001 += "   FROM SD3050 SD3 WITH (NOLOCK)
		A0001 += "  INNER JOIN SB1010 SB1 WITH (NOLOCK) ON B1_FILIAL = '  '
		A0001 += "                       AND B1_COD = D3_COD
		A0001 += "                       AND SB1.D_E_L_E_T_ = ' '
		A0001 += "  INNER JOIN SF5010 SF5 WITH (NOLOCK) ON F5_FILIAL = '01'
		A0001 += "                       AND F5_CODIGO = D3_TM
		A0001 += "                       AND SF5.D_E_L_E_T_ = ' '
		A0001 += "  WHERE D3_FILIAL = '01'
		A0001 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
		A0001 += "    AND D3_OP = '             '
		A0001 += "    AND D3_CF NOT IN('DE4','RE4','DE3','RE3','DE7','RE7')
		A0001 += "    AND D3_TIPO NOT IN('PI','PP')
		A0001 += "    AND D3_ESTORNO = '  '
		// Retirada em 08/09/15 por solicitação do Jecimar. implementado Marcos Alberto Soprani
		//A0001 += "    AND D3_USUARIO <> ' '
		A0001 += "    AND SD3.D_E_L_E_T_ = ' '
		TCQUERY A0001 New Alias "A001"
		dbSelectArea("A001")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc()

			aAdd(aDados2, { A001->EMPR                             ,;
			dtoc(stod(A001->D3_EMISSAO))                           ,;
			A001->D3_DOC                                           ,;
			A001->D3_TM                                            ,;
			A001->F5_TEXTO                                         ,;
			A001->D3_COD                                           ,;
			StrTran(A001->B1_DESC ,";","-")                        ,;
			A001->D3_UM                                            ,;
			A001->D3_TIPO                                          ,;
			A001->D3_GRUPO                                         ,;
			Transform(A001->D3_QUANT     ,"@E 999,999,999.9999")   ,;
			Transform(A001->D3_CUSTO1    ,"@E 999,999,999.9999")   ,;
			A001->D3_YOBS                                          })

			dbSelectArea("A001")
			dbSkip()
		End
		aStru1 := ("A001")->(dbStruct())
		A001->(dbCloseArea())

	EndIf

	dbSelectArea(zsAlias)

	U_BIAxExcel(aDados2, aStru1, ktNomArq+strzero(seconds()%3500,5) )

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Vld01Prg ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 11/04/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Vld01Prg()
	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data             ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data            ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","De Grupo            ?","","","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
	aAdd(aRegs,{cPerg,"04","Ate Grupo           ?","","","mv_ch4","C",04,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SBM"})
	aAdd(aRegs,{cPerg,"05","De Classe de Valor  ?","","","mv_ch5","C",09,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","CTH"})
	aAdd(aRegs,{cPerg,"06","Ate Classe de Valor ?","","","mv_ch6","C",09,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","CTH"})
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

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Vld03Prg ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 11/04/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Vld03Prg()
	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data             ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data            ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
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

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Vld06Prg ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 11/04/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function Vld06Prg()
	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data             ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data            ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","De Produto          ?","","","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"04","Ate Produto         ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"05","De Fornecedor       ?","","","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
	aAdd(aRegs,{cPerg,"06","Ate Fornecedor      ?","","","mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
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

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Função   ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 11/04/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦ Ação     ¦ Navega Estrutura de Produto para Acumular quantidades que  ¦¦¦
¦¦¦          ¦ servirão de base para custo variável                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function StrutBia(cProduto, nQuant, cAliasEstru, cArqTrab, lAsShow, cRevisao, xNivel)

	LOCAL nRegi   := 0, nQuantItem := 0
	LOCAL aCampos := {}, aTamSX3:={}, lAdd :=.F.
	LOCAL nRecno
	cAliasEstru   := IIF(cAliasEstru == NIL,"ESTRUT",cAliasEstru)
	nQuant        := IIF(nQuant == NIL,1,nQuant)
	lAsShow       := IIF(lAsShow==NIL,.F.,lAsShow)
	xNivel        := IIF(xNivel == NIL, 1, xNivel)
	nEstru++
	If nEstru == 1
		xk_Ordem := 0
		aTamSX3:=TamSX3("G1_COD")
		AADD(aCampos,{"PRODPAI","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_TRT")
		AADD(aCampos,{"ORDEM","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_COD")
		AADD(aCampos,{"CODIGO","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_COMP")
		AADD(aCampos,{"COMP","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_TRT")
		AADD(aCampos,{"TRT","C",aTamSX3[1],0})
		aTamSX3:=TamSX3("G1_QUANT")
		AADD(aCampos,{"QUANT","N",Max(aTamSX3[1],18),aTamSX3[2]})
		aTamSX3:=TamSX3("G1_QUANT")
		AADD(aCampos,{"QTDORI","N",Max(aTamSX3[1],18),aTamSX3[2]})
		aTamSX3:=TamSX3("G1_NIV")
		AADD(aCampos,{"NIVEL","N",Max(aTamSX3[1],18),aTamSX3[2]})
		cArqTrab := CriaTrab(aCampos)
		If Select(cAliasEstru) > 0
			dbSelectArea(cAliasEstru)
			dbCloseArea()
		EndIf
		Use &cArqTrab NEW Exclusive Alias &(cAliasEstru)
		IndRegua(cAliasEstru,cArqTrab,"ORDEM",,,"Selecionando Registros...")
		dbSetIndex(cArqtrab+OrdBagExt())
	EndIf

	dbSelectArea("SG1")
	dbSetOrder(1)
	dbSeek(xFilial("SG1")+cProduto)

	While !Eof() .and. Alltrim(SG1->G1_FILIAL+SG1->G1_COD) == Alltrim(xFilial("SG1")+cProduto)
		nRegi:=Recno()
		If SG1->G1_COD != SG1->G1_COMP
			lAdd:=.F.
			If dDataBase >= SG1->G1_INI .and. dDataBase <= SG1->G1_FIM

				// Cálculo padrão do sistema para perda
				// nQuantItem := ((nQuant * nG1Quant) / (100 - G1_PERDA)) * 100
				// nQuant = Quantidade Pai
				// nG1Quanto = Quantidade Corrente do Componente
				nQuantItem := ExplEstr(nQuant,,,cRevisao)

				If (lNegEstr .Or. (!lNegEstr .And. QtdComp(nQuantItem,.T.) > QtdComp(0) )) .And. (QtdComp(nQuantItem,.T.) # QtdComp(0,.T.))

					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+SG1->G1_COD))
					ht_CodGr := SB1->B1_GRUPO
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+SG1->G1_COMP))
					ht_CompG := SB1->B1_GRUPO
					If Substr(ht_CodGr,1,3) $ "102" .or. ht_CodGr $ "PI02/PI03/PI04/PI05/PI06/PI07" .or. Substr(ht_CompG,1,3) $ "102" .or. ht_CompG $ "PI02/PI03/PI04/PI05/PI06/PI07"
						dbSelectArea(cAliasEstru)
						xk_Ordem ++
						RecLock(cAliasEstru,.T.)
						ESTRUT->ORDEM  := StrZero(xk_Ordem,3)
						ESTRUT->PRODPAI:= wProduto
						ESTRUT->CODIGO := SG1->G1_COD
						ESTRUT->COMP   := SG1->G1_COMP
						ESTRUT->TRT    := SG1->G1_TRT
						ESTRUT->QUANT  := nQuantItem
						ESTRUT->QTDORI := SG1->G1_QUANT
						ESTRUT->NIVEL  := xNivel
						MsUnlock()
						lAdd:=.T.
					EndIf

				EndIf
				dbSelectArea("SG1")

				// Verifica se existe sub-estrutura
				nRecno:=Recno()
				IF dbSeek(xFilial("SG1")+SG1->G1_COMP)
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+SG1->G1_COD))
					StrutBia(SG1->G1_COD, nQuantItem, cAliasEstru, cArqTrab, lAsShow, SB1->B1_REVATU, xNivel+1)
					nEstru --
				Endif
			EndIf
		EndIf
		dbGoto(nRegi)
		dbSkip()
	End
	cArqTmp := cArqTrab

Return cArqTrab
