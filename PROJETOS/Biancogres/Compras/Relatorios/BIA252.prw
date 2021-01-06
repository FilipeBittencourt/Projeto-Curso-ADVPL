#Include "Protheus.ch"
#include "topconn.ch"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := BIA252
Empresa   := Biancogres Cerâmica S/A
Data      := 13/07/11
Uso       := Compras / PCP / Suprimento
Aplicação := Analise MRP / PCP
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function BIA252()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	cHInicio := Time()
	fPerg := "BIA252"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"
	fCabec   := "Análise MRP"

	cBizagi	 := U_fGetBase("2")

	wnPag    := 0
	nRow1    := 0

	oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
	oPrint:SetPortrait()
	oPrint:SetPaperSize(09)
	oPrint:Setup()

	cTempo := Alltrim(ElapTime(cHInicio, Time()))
	IncProc("Armazenando....   Tempo: "+cTempo)

	A0001 := " WITH DADOSBIZAGI AS (SELECT *
	A0001 += "                        FROM "+cBizagi+".dbo.DADOS_RECEBIMENTO_MATERIAL
	A0001 += "                       WHERE Empresa = '"+cEmpAnt+"')
	A0001 += " SELECT B1_COD COD_COMP,
	A0001 += "        SUBSTRING(B1_DESC,1,100) DESC_COMP,
	A0001 += "        B1_UM UM_COMP,
	A0001 += "        ISNULL(SBZ.BZ_ESTSEG, 0) EST_SEG,
	A0001 += "        ISNULL(SB2.B2_QATU, 0) EST_01,
	A0001 += "        ISNULL((SELECT SUM(SC7.C7_QUANT - SC7.C7_QUJE)
	A0001 += "                  FROM "+RetSqlName("SC7")+" SC7
	A0001 += "                 WHERE SC7.C7_FILIAL = '"+xFilial("SC7")+"'
	A0001 += "                   AND SC7.C7_PRODUTO = SB1.B1_COD
	A0001 += "                   AND SC7.C7_YDTNECE BETWEEN '"+dtos(MV_PAR01-720)+"' AND '"+dtos(MV_PAR01-1)+"'
	A0001 += "                   AND SC7.C7_LOCAL = '01'
	A0001 += "                   AND SC7.C7_RESIDUO = ' '
	A0001 += "                   AND SC7.D_E_L_E_T_ = ' '), 0) PC_OLD_01,
	A0001 += "        ISNULL((SELECT SUM(SC7.C7_QUANT - SC7.C7_QUJE)
	A0001 += "                  FROM "+RetSqlName("SC7")+" SC7
	A0001 += "                 WHERE SC7.C7_FILIAL = '"+xFilial("SC7")+"'
	A0001 += "                   AND SC7.C7_PRODUTO = SB1.B1_COD
	A0001 += "                   AND SC7.C7_YDTNECE BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	A0001 += "                   AND SC7.C7_LOCAL = '01'
	A0001 += "                   AND SC7.C7_RESIDUO = ' '
	A0001 += "                   AND SC7.D_E_L_E_T_ = ' '), 0) PC_ATU_01,
	A0001 += "        CASE
	A0001 += "          WHEN B1_GRUPO LIKE '%104%' THEN
	A0001 += "                                          ISNULL((SELECT SUM(SD4.D4_QUANT)
	A0001 += "                                                    FROM "+RetSqlName("SD4")+" SD4
	A0001 += "                                                   INNER JOIN "+RetSqlName("SC2")+" SC2 ON C2_FILIAL = '"+xFilial("SC2")+"'
	A0001 += "                                                                        AND C2_NUM = SUBSTRING(D4_OP,1,6)
	A0001 += "                                                                        AND C2_ITEM = SUBSTRING(D4_OP,7,2)
	A0001 += "                                                                        AND C2_SEQUEN = '001'
	A0001 += "                                                                        AND SC2.D_E_L_E_T_ = ' '
	A0001 += "                                                    INNER JOIN "+RetSqlName("SB1")+" ZB1 ON ZB1.B1_FILIAL = '"+xFilial("SB1")+"'
	A0001 += "                                                                        AND ZB1.B1_COD = C2_PRODUTO
	A0001 += "                                                                        AND ZB1.B1_YCLASSE = '1'
	A0001 += "                                                                        AND ZB1.D_E_L_E_T_ = ' '
	A0001 += "                                                   WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'
	A0001 += "                                                         AND SD4.D4_DATA BETWEEN '"+dtos(MV_PAR01-720)+"' AND '"+dtos(MV_PAR01-1)+"'
	A0001 += "                                                         AND SD4.D4_COD = SB1.B1_COD
	A0001 += "                                                         AND D4_QUANT > 0
	A0001 += "                                                         AND SD4.D_E_L_E_T_ = ' '
	A0001 += "                                                   GROUP BY D4_COD), 0)
	A0001 += "          ELSE
	A0001 += "               ISNULL((SELECT SUM(SD4.D4_QUANT)
	A0001 += "                       FROM "+RetSqlName("SD4")+" SD4
	A0001 += "                      WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'
	A0001 += "                            AND SD4.D4_DATA BETWEEN '"+dtos(MV_PAR01-720)+"' AND '"+dtos(MV_PAR01-1)+"'
	A0001 += "                            AND SD4.D4_COD = SB1.B1_COD
	A0001 += "                            AND D4_QUANT > 0
	A0001 += "                            AND SD4.D_E_L_E_T_ = ' '
	A0001 += "                      GROUP BY D4_COD), 0)
	A0001 += "          END NC_OLD,
	A0001 += "        CASE
	A0001 += "          WHEN B1_GRUPO LIKE '%104%' THEN
	A0001 += "                                          ISNULL((SELECT SUM(SD4.D4_QUANT)
	A0001 += "                                                    FROM "+RetSqlName("SD4")+" SD4
	A0001 += "                                                   INNER JOIN "+RetSqlName("SC2")+" SC2 ON C2_FILIAL = '"+xFilial("SC2")+"'
	A0001 += "                                                                        AND C2_NUM = SUBSTRING(D4_OP,1,6)
	A0001 += "                                                                        AND C2_ITEM = SUBSTRING(D4_OP,7,2)
	A0001 += "                                                                        AND C2_SEQUEN = '001'
	A0001 += "                                                                        AND SC2.D_E_L_E_T_ = ' '
	A0001 += "                                                   INNER JOIN "+RetSqlName("SB1")+" ZB1 ON ZB1.B1_FILIAL = '"+xFilial("SB1")+"'
	A0001 += "                                                                        AND ZB1.B1_COD = C2_PRODUTO
	A0001 += "                                                                        AND ZB1.B1_YCLASSE = '1'
	A0001 += "                                                                        AND ZB1.D_E_L_E_T_ = ' '
	A0001 += "                                                   WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'
	A0001 += "                                                         AND SD4.D4_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	A0001 += "                                                         AND SD4.D4_COD = SB1.B1_COD
	A0001 += "                                                         AND D4_QUANT > 0
	A0001 += "                                                         AND SD4.D_E_L_E_T_ = ' '
	A0001 += "                                                   GROUP BY D4_COD), 0)
	A0001 += "          ELSE
	A0001 += "               ISNULL((SELECT SUM(SD4.D4_QUANT)
	A0001 += "                         FROM "+RetSqlName("SD4")+" SD4
	A0001 += "                        WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'
	A0001 += "                              AND SD4.D4_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	A0001 += "                              AND SD4.D4_COD = SB1.B1_COD
	A0001 += "                              AND D4_QUANT > 0
	A0001 += "                              AND SD4.D_E_L_E_T_ = ' '
	A0001 += "                        GROUP BY D4_COD), 0)
	A0001 += "          END NC_ATU,
	A0001 += "        ISNULL((SELECT SUM(B6_SALDO)
	A0001 += "                  FROM "+RetSqlName("SB6")+" SB6
	A0001 += "                 WHERE B6_FILIAL = '"+xFilial("SB6")+"'
	A0001 += "                   AND B6_PRODUTO = B1_COD
	A0001 += "                   AND B6_PODER3 = 'R'
	A0001 += "                   AND B6_SALDO <> 0
	A0001 += "                   AND SB6.D_E_L_E_T_ = ' '), 0) SALDOP3,
	A0001 += "        ISNULL((SELECT SUM(D1_QUANT) QUANT
	A0001 += "                  FROM DADOSBIZAGI DBZG
	A0001 += "                 INNER JOIN "+RetSqlName("SA2")+" SA2 ON A2_FILIAL = '"+xFilial("SA2")+"'
	A0001 += "                                      AND A2_CGC = CNPJ COLLATE Latin1_General_BIN
	A0001 += "                                      AND SA2.D_E_L_E_T_ = ' '
	A0001 += "                 INNER JOIN "+RetSqlName("SDT")+" SDT ON DT_FILIAL = '"+xFilial("SDT")+"'
	A0001 += "                                      AND DT_DOC = NumeroNF COLLATE Latin1_General_BIN
	A0001 += "                                      AND DT_FORNEC = A2_COD
	A0001 += "                                      AND DT_LOJA = A2_LOJA
	A0001 += "                                      AND CONVERT(INT, DT_SERIE) = CONVERT(INT, SerieNF COLLATE Latin1_General_BIN) 
	A0001 += "                                      AND DT_COD = CodigodoProduto COLLATE Latin1_General_BIN
	A0001 += "                                      AND SDT.D_E_L_E_T_ = ' '
	A0001 += "                 INNER JOIN "+RetSqlName("SD1")+" SD1 ON D1_FILIAL = '"+xFilial("SD1")+"'
	A0001 += "                                      AND D1_DOC = DT_DOC
	A0001 += "                                      AND D1_SERIE = D1_SERIE
	A0001 += "                                      AND D1_FORNECE = DT_FORNEC
	A0001 += "                                      AND D1_LOJA = DT_LOJA
	A0001 += "                                      AND D1_ITEM = DT_ITEM
	A0001 += "                                      AND D1_TES = '   '
	A0001 += "                                      AND SD1.D_E_L_E_T_ = ' '
	A0001 += "                 WHERE CodigodoProduto = B1_COD COLLATE Latin1_General_BIN
	A0001 += "                ), 0) TRANSIT_IN
	A0001 += "   FROM "+RetSqlName("SB1")+" SB1
	A0001 += "   LEFT JOIN "+RetSqlName("SB2")+" SB2 ON SB2.B2_FILIAL = '"+xFilial("SB2")+"'
	A0001 += "                       AND SB2.B2_COD = SB1.B1_COD
	A0001 += "                       AND SB2.B2_LOCAL = '01'
	A0001 += "                       AND SB2.D_E_L_E_T_ = ' '
	A0001 += "   LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial("SBZ")+"'
	A0001 += "                       AND SBZ.BZ_COD = SB1.B1_COD
	A0001 += "                       AND SBZ.D_E_L_E_T_ = ' '
	A0001 += "  WHERE B1_FILIAL = '"+xFilial("SB1")+"'
	A0001 += "    AND B1_TIPO <> 'PI'
	A0001 += "    AND B1_COD BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'
	A0001 += "    AND SB1.D_E_L_E_T_ = ' '
	A0001 += " ORDER BY B1_COD
	TCQUERY A0001 New Alias "A001"
	dbSelectArea("A001")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Imprimindo....    Tempo: "+cTempo)

		If A001->PC_OLD_01 + A001->PC_ATU_01 + A001->NC_OLD + A001->NC_ATU <> 0

			fImpCabec()

			oPrint:Say  (nRow1 ,0050 , "Estoque de Segurança:    " + Transform(A001->EST_SEG, "@E 999,999,999.99")                       ,oFont10)
			nRow1 += 075
			oPrint:Say  (nRow1 ,0050 , "Estoque Porder Terceiro: " + Transform(A001->SALDOP3, "@E 999,999,999.99")                       ,oFont10)
			nRow1 += 075
			oPrint:Say  (nRow1 ,0050 , "Trânsito Interno:        " + Transform(A001->TRANSIT_IN, "@E 999,999,999.99")                    ,oFont10)
			nRow1 += 075
			xkEstDispo := "Estoque Atual:           " + Transform(A001->EST_01, "@E 999,999,999.99") + "        --->>   Estoque Total: " + Transform(A001->SALDOP3 + A001->EST_01, "@E 999,999,999.99")
			oPrint:Say  (nRow1 ,0050 , xkEstDispo                                                                                        ,oFont10)
			nRow1 += 075
			oPrint:Say  (nRow1 ,0050 , "Pedido Compras Anterior: " + Transform(A001->PC_OLD_01, "@E 999,999,999.99")                     ,oFont10)
			nRow1 += 075
			oPrint:Say  (nRow1 ,0050 , "Pedido Compras Corrente: " + Transform(A001->PC_ATU_01, "@E 999,999,999.99")                     ,oFont10)
			nRow1 += 075
			oPrint:Say  (nRow1 ,0050 , "Necessidade Anterior:    " + Transform(A001->NC_OLD, "@E 999,999,999.99")                        ,oFont10)
			nRow1 += 075
			oPrint:Say  (nRow1 ,0050 , "Necessidade Corrente:    " + Transform(A001->NC_ATU, "@E 999,999,999.99")                        ,oFont10)
			nRow1 += 075
			xj_Saldo := ( ( A001->SALDOP3 + A001->EST_01 ) - A001->EST_SEG ) + ( A001->PC_OLD_01 ) + ( A001->PC_ATU_01 ) - ( A001->NC_OLD + A001->NC_ATU )
			oPrint:Say  (nRow1 ,0050 , "Saldo:                   " + Transform(xj_Saldo, "@E 999,999,999.99")                            ,oFont10)
			nRow1 += 075

			xf_Titu := +;
			Padl("Nec.Acumul"                                                               ,17)+"   "+;
			Padr("OP/PC"                                                                    ,11)+" "+;
			Padr("Material"                                                                 ,50)+" "+;
			Padc("Data"                                                                     ,08)+" "+;
			Padl("Necessidade"                                                              ,17)+" "+;
			Padl("Saldo.Acum"                                                               ,17)
			oPrint:Say  (nRow1 ,0050 ,xf_Titu                               ,oFont8)
			oPrint:Line (nRow1+35, 050, nRow1+35, 2400)
			nRow1 += 065

			xj_CodComp := A001->COD_COMP
			While !Eof() .and. A001->COD_COMP == xj_CodComp

				cTempo := Alltrim(ElapTime(cHInicio, Time()))
				IncProc("Imprimindo....    Tempo: "+cTempo)

				A0002 := " SELECT 'S' TIPO,
				A0002 += "        ' ' NUMOP,
				A0002 += "        'SAIDAS ACUMULADAS ANTERIORES' DESC_COD,
				A0002 += "        '"+dtos(MV_PAR01-1)+"' DTNEC,
				A0002 += "        ISNULL(SUM(D4_QUANT), 0) NECES
				A0002 += "   FROM "+RetSqlName("SD4")+" SD4
				A0002 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 ON SC2.C2_FILIAL = '"+xFilial("SC2")+"'
				A0002 += "                       AND SC2.C2_NUM = SUBSTRING(SD4.D4_OP,1,6)
				A0002 += "                       AND SC2.C2_ITEM = SUBSTRING(SD4.D4_OP,7,2)
				A0002 += "                       AND SC2.C2_SEQUEN = SUBSTRING(SD4.D4_OP,9,3)
				A0002 += "                       AND SC2.D_E_L_E_T_ = ' '
				A0002 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'
				A0002 += "                       AND SB1.B1_COD = SC2.C2_PRODUTO
				A0002 += "                       AND SB1.D_E_L_E_T_ = ' '
				If Substr(A001->COD_COMP,1,3) == "104"
					A0002 += "  INNER JOIN "+RetSqlName("SC2")+" XSC2 ON XSC2.C2_FILIAL = '"+xFilial("SC2")+"'
					A0002 += "                       AND XSC2.C2_NUM = SUBSTRING(SD4.D4_OP,1,6)
					A0002 += "                       AND XSC2.C2_ITEM = SUBSTRING(SD4.D4_OP,7,2)
					A0002 += "                       AND XSC2.C2_SEQUEN = '001'
					A0002 += "                       AND XSC2.D_E_L_E_T_ = ' '
					A0002 += "  INNER JOIN "+RetSqlName("SB1")+" XSB1 ON XSB1.B1_FILIAL = '"+xFilial("SB1")+"'
					A0002 += "                       AND XSB1.B1_COD = XSC2.C2_PRODUTO
					A0002 += "                       AND XSB1.B1_YCLASSE = '1'
					A0002 += "                       AND XSB1.D_E_L_E_T_ = ' '
				EndIf
				A0002 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"'
				A0002 += "    AND D4_COD = '"+A001->COD_COMP+"'
				A0002 += "    AND D4_DATA BETWEEN '"+dtos(MV_PAR01-720)+"' AND '"+dtos(MV_PAR01-1)+"'
				A0002 += "    AND SD4.D_E_L_E_T_ = ' '
				A0002 += "  UNION
				A0002 += " SELECT 'S' TIPO,
				A0002 += "        SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN NUMOP,
				A0002 += "        SUBSTRING(SB1.B1_DESC,1,100) DESC_COD,
				A0002 += "        D4_DATA DTNEC,
				A0002 += "        D4_QUANT NECES
				A0002 += "   FROM "+RetSqlName("SD4")+" SD4
				A0002 += "  INNER JOIN "+RetSqlName("SC2")+" SC2 ON SC2.C2_FILIAL = '"+xFilial("SC2")+"'
				A0002 += "                       AND SC2.C2_NUM = SUBSTRING(SD4.D4_OP,1,6)
				A0002 += "                       AND SC2.C2_ITEM = SUBSTRING(SD4.D4_OP,7,2)
				A0002 += "                       AND SC2.C2_SEQUEN = SUBSTRING(SD4.D4_OP,9,3)
				A0002 += "                       AND SC2.D_E_L_E_T_ = ' '
				A0002 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'
				A0002 += "                       AND SB1.B1_COD = SC2.C2_PRODUTO
				A0002 += "                       AND SB1.D_E_L_E_T_ = ' '
				If Substr(A001->COD_COMP,1,3) == "104"
					A0002 += "  INNER JOIN "+RetSqlName("SC2")+" XSC2 ON XSC2.C2_FILIAL = '"+xFilial("SC2")+"'
					A0002 += "                       AND XSC2.C2_NUM = SUBSTRING(SD4.D4_OP,1,6)
					A0002 += "                       AND XSC2.C2_ITEM = SUBSTRING(SD4.D4_OP,7,2)
					A0002 += "                       AND XSC2.C2_SEQUEN = '001'
					A0002 += "                       AND XSC2.D_E_L_E_T_ = ' '
					A0002 += "  INNER JOIN "+RetSqlName("SB1")+" XSB1 ON XSB1.B1_FILIAL = '"+xFilial("SB1")+"'
					A0002 += "                       AND XSB1.B1_COD = XSC2.C2_PRODUTO
					A0002 += "                       AND XSB1.B1_YCLASSE = '1'
					A0002 += "                       AND XSB1.D_E_L_E_T_ = ' '
				EndIf
				A0002 += "  WHERE D4_FILIAL = '"+xFilial("SD4")+"'
				A0002 += "    AND D4_COD = '"+A001->COD_COMP+"'
				A0002 += "    AND D4_DATA BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
				A0002 += "    AND SD4.D_E_L_E_T_ = ' '
				A0002 += " UNION
				A0002 += " SELECT 'E' TIPO,
				A0002 += "        ' ' C7_NUM,
				A0002 += "        'ENTRADAS ACUMULADAS ANTERIORES1' DESC_COD,
				A0002 += "        '"+dtos(MV_PAR01-1)+"' DTNEC,
				A0002 += "        ISNULL(SUM(SC7.C7_QUANT - SC7.C7_QUJE), 0) QUANT
				A0002 += "   FROM "+RetSqlName("SC7")+" SC7
				A0002 += "  WHERE SC7.C7_FILIAL = '"+xFilial("SC7")+"'
				A0002 += "    AND SC7.C7_PRODUTO = '"+A001->COD_COMP+"'
				A0002 += "    AND SC7.C7_YDTNECE BETWEEN '"+dtos(MV_PAR01-720)+"' AND '"+dtos(MV_PAR01-1)+"'
				A0002 += "    AND SC7.C7_LOCAL = '01'
				A0002 += "    AND SC7.C7_QUANT - SC7.C7_QUJE > 0
				A0002 += "    AND SC7.C7_RESIDUO = ' '
				A0002 += "    AND SC7.D_E_L_E_T_ = ' '
				A0002 += " UNION
				A0002 += " SELECT 'E' TIPO,
				A0002 += "        SC7.C7_NUM,
				A0002 += "        'ENTRADAS CORRENTES1' DESC_COD,
				A0002 += "        SC7.C7_YDTNECE DTNEC,
				A0002 += "        ISNULL(SUM(SC7.C7_QUANT - SC7.C7_QUJE), 0) QUANT
				A0002 += "   FROM "+RetSqlName("SC7")+" SC7
				A0002 += "  WHERE SC7.C7_FILIAL = '"+xFilial("SC7")+"'
				A0002 += "    AND SC7.C7_PRODUTO = '"+A001->COD_COMP+"'
				A0002 += "    AND SC7.C7_YDTNECE BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
				A0002 += "    AND SC7.C7_LOCAL = '01'
				A0002 += "    AND SC7.C7_QUANT - SC7.C7_QUJE > 0
				A0002 += "    AND SC7.C7_RESIDUO = ' '
				A0002 += "    AND SC7.D_E_L_E_T_ = ' '
				A0002 += "  GROUP BY SC7.C7_NUM, SC7.C7_YDTNECE
				A0002 += " ORDER BY DTNEC, TIPO
				TCQUERY A0002 New Alias "A002"
				dbSelectArea("A002")
				dbGoTop()
				xj_NecAcul := 0
				xj_SalProg := ( A001->SALDOP3 + A001->EST_01 ) - A001->EST_SEG
				While !Eof()

					If nRow1 > 3350
						fImpRoda()
						fImpCabec()
					EndIf

					If A002->NECES <> 0

						xj_NecAcul += IIF(A002->TIPO == "S", A002->NECES, 0)
						xj_SalProg -= IIF(A002->TIPO == "S", A002->NECES, A002->NECES*(-1))

						xf_Item := +;
						Padl(Transform(xj_NecAcul,"@E 9999,999.99")                                     ,17)+"   "+;
						Padr(A002->NUMOP                                                                ,11)+" "+;
						Padr(A002->DESC_COD                                                             ,50)+" "+;
						Padc(dtoc(stod(A002->DTNEC))                                                    ,08)+" "+;
						Padl(Transform(A002->NECES,"@E 9999,999.99")                                    ,17)+" "+;
						Padl(Transform(xj_SalProg,"@E 9999,999.99")                                     ,17)
						oPrint:Say  (nRow1 ,0050 ,xf_Item                               ,oFont8)
						oPrint:Line (nRow1+35, 050, nRow1+35, 2400)
						nRow1 += 065

					EndIf

					dbSelectArea("A002")
					dbSkip()
				End
				A002->(dbCloseArea())

				If nRow1 + 450 > 3350
					fImpRoda()
					fImpCabec()
				EndIf

				oPrint:Say  (nRow1+100 , 1525, "Comprar:"             , oFont14)
				oPrint:Line (nRow1+155 , 1525, nRow1+155, 2375)
				oPrint:Say  (nRow1+220 , 1525, "Para:"                , oFont14)
				oPrint:Line (nRow1+275 , 1525, nRow1+275, 2375)
				oPrint:Say  (nRow1+340 , 1525, "Embalagem:"           , oFont14)
				oPrint:Line (nRow1+395 , 1525, nRow1+395, 2375)
				oPrint:Say  (nRow1+460 , 1525, ""                     , oFont14)
				oPrint:Line (nRow1+515 , 1525, nRow1+515, 2375)

				oPrint:Line (nRow1+000 , 1500, nRow1+000, 2400)
				oPrint:Line (nRow1+550 , 1500, nRow1+550, 2400)
				oPrint:Line (nRow1+000 , 1500, nRow1+550, 1500)
				oPrint:Line (nRow1+000 , 2400, nRow1+550, 2400)

				nRow1 += 100
				xf_CbPc := +;
				Padr("Pedido"                                   ,06)+"  "+;
				Padc("Emissão"                                  ,08)+"  "+;
				Padc("Entrega"                                  ,08)+"  "+;
				Padc("Chegada"                                  ,08)+"  "+;
				Padl("Qtde"                                     ,11)+"  "+;
				Padl("Q.Ent"                                    ,11)+"  "+;
				Padl("Pendente"                                 ,11)
				oPrint:Say  (nRow1 ,0050 ,xf_CbPc                               ,oFont8)
				oPrint:Line (nRow1+35, 050, nRow1+35, 1400)
				nRow1 += 065

				A0003 := " SELECT SC7.C7_NUM,
				A0003 += "        SC7.C7_EMISSAO,
				A0003 += "        SC7.C7_DATPRF,
				A0003 += "        SC7.C7_YDATCHE,
				A0003 += "        ISNULL(SUM(SC7.C7_QUANT), 0) QUANT,
				A0003 += "        ISNULL(SUM(SC7.C7_QUJE), 0) QUJE,
				A0003 += "        ISNULL(SUM(SC7.C7_QUANT - SC7.C7_QUJE), 0) PENDENT
				A0003 += "   FROM "+RetSqlName("SC7")+" SC7
				A0003 += "  WHERE SC7.C7_FILIAL = '"+xFilial("SC7")+"'
				A0003 += "    AND SC7.C7_PRODUTO = '"+A001->COD_COMP+"'
				A0003 += "    AND SC7.C7_EMISSAO BETWEEN '"+dtos(MV_PAR05)+"' AND '"+dtos(MV_PAR06)+"'
				A0003 += "    AND SC7.C7_LOCAL = '01'
				A0003 += "    AND SC7.C7_RESIDUO = ' '
				A0003 += "    AND SC7.D_E_L_E_T_ = ' '
				A0003 += "  GROUP BY SC7.C7_NUM,
				A0003 += "           SC7.C7_EMISSAO,
				A0003 += "           SC7.C7_DATPRF,
				A0003 += "           SC7.C7_YDATCHE
				A0003 += " ORDER BY C7_EMISSAO
				TCQUERY A0003 New Alias "A003"
				dbSelectArea("A003")
				dbGoTop()
				While !Eof()

					If nRow1 > 3350
						fImpRoda()
						fImpCabec()
					EndIf

					xf_ItPc := +;
					Padr(A003->C7_NUM                                                               ,06)+"  "+;
					Padc(dtoc(stod(A003->C7_EMISSAO))                                               ,08)+"  "+;
					Padc(dtoc(stod(A003->C7_DATPRF))                                                ,08)+"  "+;
					Padc(dtoc(stod(A003->C7_YDATCHE))                                               ,08)+"  "+;
					Padl(Transform(A003->QUANT,"@E 9999,999.99")                                    ,11)+"  "+;
					Padl(Transform(A003->QUJE,"@E 9999,999.99")                                     ,11)+"  "+;
					Padl(Transform(A003->PENDENT,"@E 9999,999.99")                                  ,11)
					oPrint:Say  (nRow1 ,0050 ,xf_ItPc                               ,oFont8)
					oPrint:Line (nRow1+35, 050, nRow1+35, 1400)
					nRow1 += 065

					dbSelectArea("A003")
					dbSkip()
				End
				A003->(dbCloseArea())

			End


			fImpRoda()

		EndIf

		dbSelectArea("A001")
		dbSkip()

	End
	A001->(dbCloseArea())

	oPrint:EndPage()
	oPrint:Preview()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05.07.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpCabec()

	oPrint:StartPage()
	wnPag ++
	nRow1 := 050
	If File(aBitmap)
		oPrint:SayBitmap( nRow1+25, 050, aBitmap, 0600, 0125 )
	EndIf
	nRow1 += 025
	sw_Perid := "Periodo: "+ dtoc(MV_PAR01) +" até " + dtoc(MV_PAR02)
	oPrint:Say  (nRow1    ,0050 ,Padc(fCabec,80)                                            ,oFont14)
	oPrint:Say  (nRow1+10 ,2000 ,"Página:"                                                  ,oFont7)
	oPrint:Say  (nRow1+05 ,2150 ,Transform(wnPag,"@E 99999999")                             ,oFont8)
	oPrint:Say  (nRow1+60 ,2000 ,"Emissão:"                                                 ,oFont7)
	oPrint:Say  (nRow1+65 ,2150 ,dtoc(dDataBase)                                            ,oFont8)
	oPrint:Say  (nRow1+75 ,0050 ,Padc(sw_Perid,135)                                         ,oFont10)
	nRow1 += 150
	oPrint:Line (nRow1, 050, nRow1, 2400)
	nRow1 += 050

	oPrint:Say  (nRow1 ,0050 , "Material: " + A001->COD_COMP + " " + A001->DESC_COMP + " " + A001->UM_COMP                       ,oFont10)
	nRow1 += 075

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpRoda ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05.07.11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

	oPrint:Line (3400, 050, 3400, 2400)
	oPrint:Say  (3400+30 , 050,"Prog.: " + fPerg                                      ,oFont7)
	oPrint:Say  (3400+30 ,1850,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
	oPrint:EndPage()
	nRow1 := 4000

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
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
	aAdd(aRegs,{cPerg,"01","De Data(Produção)    ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data(Produção)   ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","De Produto           ?","","","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"04","Ate Produto          ?","","","mv_ch4","C",15,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"05","De Data(Ped.Compras) ?","","","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Ate Data(Ped.Compras)?","","","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
