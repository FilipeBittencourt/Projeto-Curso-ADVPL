#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIA220
@author Marcos Alberto Soprani
@since 07/01/13
@version 1.0
@description Responsável por listar a amarração entre notas fiscais da LM vs
.            Biancogres / Incesa / Mundi
.            A partir das notas fiscais da LM, com base da SubSet da relação
.            de titulos baixados por grupo de cliente numa determinada data
.            as Set superiores "amarram" as notas entre entre as empresas.
@type function
/*/

User Function BIA220()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local hhi
	Private hfEntr := CHR(13) + CHR(10)

	cHInicio := Time()
	fPerg := "BIA220"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If cEmpAnt <> "07"
		MsgINFO("Este relatório foi pensado orinalmente para LM!!!")
		Return
	EndIf

	If MV_PAR04 == 1

		aBitmap  := "LOGOPRI"+cEmpAnt+".BMP"
		fCabec   := "Amarração Notas Fiscais InterCompany"

		wnPag    := 0
		nRow1    := 0

		oFont7   := TFont():New("Lucida Console"    ,9,7 ,.T.,.F.,5,.T.,5,.T.,.F.)
		oFont14  := TFont():New("Lucida Console"    ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
		oFont8   := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
		oFont10  := TFont():New("Lucida Console"    ,9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)

		oPrint:= TMSPrinter():New( "...: "+fCabec+" :..." )
		oPrint:SetLandscape()
		oPrint:SetPaperSize(09)
		oPrint:Setup()
		fImpCabec()

		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		IncProc("Armazenando....   Tempo: "+cTempo)

		YT005 := " SELECT D2_DOC,
		YT005 += "        D2_SERIE,
		YT005 += "        D2_TIPO,
		YT005 += "        D2_EMISSAO,
		YT005 += "        D2_CLIENTE,
		YT005 += "        D2_LOJA,
		YT005 += "        A1_NOME,
		YT005 += "        VLR_ORI,
		YT005 += "        VLR_BX,
		YT005 += "        VLR_IMP,
		YT005 += "        C5_YEMPPED,
		YT005 += "        C5_YPEDORI,
		YT005 += "        REF_NF,
		YT005 += "        SUM(VLR_NF) VLR_NF
		YT005 += "        FROM (
		YT005 += " SELECT D2_DOC,
		YT005 += "        D2_SERIE,
		YT005 += "        D2_TIPO,
		YT005 += "        CONVERT(VARCHAR,CONVERT(DATETIME, D2_EMISSAO),103) AS D2_EMISSAO,
		YT005 += "        D2_CLIENTE,
		YT005 += "        D2_LOJA,
		YT005 += "        A1_NOME,
		YT005 += "        (SELECT SUM(E1_VALOR)
		YT005 += "           FROM "+RetSqlName("SE5")+" SE5
		YT005 += "          INNER JOIN "+RetSqlName("SE1")+" SE1 ON E1_FILIAL = '"+xFilial("SE1")+"'
		YT005 += "                               AND E1_NUM = E5_NUMERO
		YT005 += "                               AND E1_PREFIXO = E5_PREFIXO
		YT005 += "                               AND E1_CLIENTE = E5_CLIFOR
		YT005 += "                               AND E1_PARCELA = E5_PARCELA
		YT005 += "                               AND E1_LOJA = E5_LOJA
		YT005 += "                               AND E1_TIPO = E5_TIPO
		YT005 += "                               AND SE1.D_E_L_E_T_ = ' '
		YT005 += "          WHERE E5_FILIAL = '"+xFilial("SE5")+"'
		YT005 += "            AND E5_DATA = '"+dtos(MV_PAR02)+"'
		YT005 += "            AND E5_NUMERO = D2_DOC
		YT005 += "            AND E5_PREFIXO = D2_SERIE
		YT005 += "            AND E5_CLIFOR = D2_CLIENTE
		YT005 += "            AND E5_LOJA = D2_LOJA
		YT005 += "            AND E5_TIPO = 'NF '
		YT005 += "            AND SE5.D_E_L_E_T_ = ' ') VLR_ORI,
		YT005 += "        (SELECT SUM(E5_VALOR)
		YT005 += "           FROM "+RetSqlName("SE5")+" SE5
		YT005 += "          WHERE E5_FILIAL = '"+xFilial("SE5")+"'
		YT005 += "            AND E5_DATA = '"+dtos(MV_PAR02)+"'
		YT005 += "            AND E5_NUMERO = D2_DOC
		YT005 += "            AND E5_PREFIXO = D2_SERIE
		YT005 += "            AND E5_CLIFOR = D2_CLIENTE
		YT005 += "            AND E5_LOJA = D2_LOJA
		YT005 += "            AND E5_TIPO = 'NF '
		YT005 += "            AND E5_NATUREZ = '"+MV_PAR03+"'
		YT005 += "            AND SE5.D_E_L_E_T_ = ' ') VLR_BX,
		YT005 += "        (SELECT SUM(E5_VALOR)
		YT005 += "           FROM "+RetSqlName("SE5")+" SE5
		YT005 += "          WHERE E5_FILIAL = '"+xFilial("SE5")+"'
		YT005 += "            AND E5_DATA = '"+dtos(MV_PAR02)+"'
		YT005 += "            AND E5_NUMERO = D2_DOC
		YT005 += "            AND E5_PREFIXO = D2_SERIE
		YT005 += "            AND E5_CLIFOR = D2_CLIENTE
		YT005 += "            AND E5_LOJA = D2_LOJA
		YT005 += "            AND E5_TIPO = 'NF '
		YT005 += "            AND E5_NATUREZ <> '"+MV_PAR03+"'
		YT005 += "            AND SE5.D_E_L_E_T_ = ' ') VLR_IMP,
		YT005 += "        C5_YEMPPED,
		YT005 += "        C5_YPEDORI,
		YT005 += "        CASE
		YT005 += "          WHEN SC5.C5_YEMPPED = '01' THEN
		YT005 += "               (SELECT TOP 1 (XD2.D2_DOC)
		YT005 += "                  FROM SD2010 XD2
		YT005 += "                 INNER JOIN SC5010 XC5 ON XC5.C5_FILIAL = '01'
		YT005 += "                                      AND XC5.C5_NUM = D2_PEDIDO
		YT005 += "                                      AND XC5.C5_CLIENTE = D2_CLIENTE
		YT005 += "                                      AND XC5.C5_LOJACLI = D2_LOJA
		YT005 += "                                      AND XC5.D_E_L_E_T_ = ' '
		YT005 += "                 WHERE XD2.D2_FILIAL = '01'
		YT005 += "                   AND XD2.D2_EMISSAO = SD2.D2_EMISSAO
		YT005 += "                   AND XD2.D2_EMISSAO + XC5.C5_YCLIORI + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD + XD2.D2_ITEM + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) =
		YT005 += "                       SD2.D2_EMISSAO + SD2.D2_CLIENTE + SD2.D2_LOJA + SC5.C5_YPEDORI + SD2.D2_COD + SD2.D2_ITEM + SD2.D2_LOTECTL + CONVERT(VARCHAR, SD2.D2_QUANT)
		YT005 += "                   AND XD2.D_E_L_E_T_ = ' ')
		YT005 += "          WHEN SC5.C5_YEMPPED = '05' THEN
		YT005 += "               (SELECT TOP 1 (XD2.D2_DOC)
		YT005 += "                  FROM SD2050 XD2
		YT005 += "                 INNER JOIN SC5050 XC5 ON XC5.C5_FILIAL = '01'
		YT005 += "                                      AND XC5.C5_NUM = D2_PEDIDO
		YT005 += "                                      AND XC5.C5_CLIENTE = D2_CLIENTE
		YT005 += "                                      AND XC5.C5_LOJACLI = D2_LOJA
		YT005 += "                                      AND XC5.D_E_L_E_T_ = ' '
		YT005 += "                 WHERE XD2.D2_FILIAL = '01'
		YT005 += "                   AND XD2.D2_EMISSAO = SD2.D2_EMISSAO
		YT005 += "                   AND XD2.D2_EMISSAO + XC5.C5_YCLIORI + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) =
		YT005 += "                       SD2.D2_EMISSAO + SD2.D2_CLIENTE + SD2.D2_LOJA + SC5.C5_YPEDORI + SD2.D2_COD + SD2.D2_LOTECTL + CONVERT(VARCHAR, SD2.D2_QUANT)
		YT005 += "                   AND XD2.D_E_L_E_T_ = ' ')
		YT005 += "          WHEN SC5.C5_YEMPPED = '13' THEN
		YT005 += "               (SELECT TOP 1 (XD2.D2_DOC)
		YT005 += "                  FROM SD2130 XD2
		YT005 += "                 INNER JOIN SC5130 XC5 ON XC5.C5_FILIAL = '01'
		YT005 += "                                      AND XC5.C5_NUM = D2_PEDIDO
		YT005 += "                                      AND XC5.C5_CLIENTE = D2_CLIENTE
		YT005 += "                                      AND XC5.C5_LOJACLI = D2_LOJA
		YT005 += "                                      AND XC5.D_E_L_E_T_ = ' '
		YT005 += "                 WHERE XD2.D2_FILIAL = '01'
		YT005 += "                   AND XD2.D2_EMISSAO = SD2.D2_EMISSAO
		YT005 += "                   AND XD2.D2_EMISSAO + XC5.C5_YCLIORI + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) =
		YT005 += "                       SD2.D2_EMISSAO + SD2.D2_CLIENTE + SD2.D2_LOJA + SC5.C5_YPEDORI + SD2.D2_COD + SD2.D2_LOTECTL + CONVERT(VARCHAR, SD2.D2_QUANT)
		YT005 += "                   AND XD2.D_E_L_E_T_ = ' ')
		YT005 += "          END REF_NF,
		YT005 += "        CASE
		YT005 += "          WHEN SC5.C5_YEMPPED = '01' THEN
		YT005 += "               (SELECT SUM(D2_TOTAL)
		YT005 += "                  FROM SD2010 XD2
		YT005 += "                 INNER JOIN SC5010 XC5 ON XC5.C5_FILIAL = '01'
		YT005 += "                                      AND XC5.C5_NUM = D2_PEDIDO
		YT005 += "                                      AND XC5.C5_CLIENTE = D2_CLIENTE
		YT005 += "                                      AND XC5.C5_LOJACLI = D2_LOJA
		YT005 += "                                      AND XC5.D_E_L_E_T_ = ' '
		YT005 += "                 WHERE XD2.D2_FILIAL = '01'
		YT005 += "                   AND XD2.D2_EMISSAO = SD2.D2_EMISSAO
		YT005 += "                   AND XD2.D2_EMISSAO + XC5.C5_YCLIORI + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) =
		YT005 += "                       SD2.D2_EMISSAO + SD2.D2_CLIENTE + SD2.D2_LOJA + SC5.C5_YPEDORI + SD2.D2_COD + SD2.D2_LOTECTL + CONVERT(VARCHAR, SD2.D2_QUANT)
		YT005 += "                   AND XD2.D_E_L_E_T_ = ' ')
		YT005 += "          WHEN SC5.C5_YEMPPED = '05' THEN
		YT005 += "               (SELECT SUM(D2_TOTAL)
		YT005 += "                  FROM SD2050 XD2
		YT005 += "                 INNER JOIN SC5050 XC5 ON XC5.C5_FILIAL = '01'
		YT005 += "                                      AND XC5.C5_NUM = D2_PEDIDO
		YT005 += "                                      AND XC5.C5_CLIENTE = D2_CLIENTE
		YT005 += "                                      AND XC5.C5_LOJACLI = D2_LOJA
		YT005 += "                                      AND XC5.D_E_L_E_T_ = ' '
		YT005 += "                 WHERE XD2.D2_FILIAL = '01'
		YT005 += "                   AND XD2.D2_EMISSAO = SD2.D2_EMISSAO
		YT005 += "                   AND XD2.D2_EMISSAO + XC5.C5_YCLIORI + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) =
		YT005 += "                       SD2.D2_EMISSAO + SD2.D2_CLIENTE + SD2.D2_LOJA + SC5.C5_YPEDORI + SD2.D2_COD + SD2.D2_LOTECTL + CONVERT(VARCHAR, SD2.D2_QUANT)
		YT005 += "                   AND XD2.D_E_L_E_T_ = ' ')
		YT005 += "          WHEN SC5.C5_YEMPPED = '13' THEN
		YT005 += "               (SELECT SUM(D2_TOTAL)
		YT005 += "                  FROM SD2130 XD2
		YT005 += "                 INNER JOIN SC5130 XC5 ON XC5.C5_FILIAL = '01'
		YT005 += "                                      AND XC5.C5_NUM = D2_PEDIDO
		YT005 += "                                      AND XC5.C5_CLIENTE = D2_CLIENTE
		YT005 += "                                      AND XC5.C5_LOJACLI = D2_LOJA
		YT005 += "                                      AND XC5.D_E_L_E_T_ = ' '
		YT005 += "                 WHERE XD2.D2_FILIAL = '01'
		YT005 += "                   AND XD2.D2_EMISSAO = SD2.D2_EMISSAO
		YT005 += "                   AND XD2.D2_EMISSAO + XC5.C5_YCLIORI + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) =
		YT005 += "                       SD2.D2_EMISSAO + SD2.D2_CLIENTE + SD2.D2_LOJA + SC5.C5_YPEDORI + SD2.D2_COD + SD2.D2_LOTECTL + CONVERT(VARCHAR, SD2.D2_QUANT)
		YT005 += "                   AND XD2.D_E_L_E_T_ = ' ')
		YT005 += "          END VLR_NF
		YT005 += "   FROM "+RetSqlName("SD2")+" SD2
		YT005 += "  INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = '"+xFilial("SC5")+"'
		YT005 += "                       AND C5_NUM = D2_PEDIDO
		YT005 += "                       AND SC5.D_E_L_E_T_ = ' '
		YT005 += "  INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = '"+xFilial("SA1")+"'
		YT005 += "                       AND A1_COD = D2_CLIENTE
		YT005 += "                       AND A1_LOJA = D2_LOJA
		YT005 += "                       AND SA1.D_E_L_E_T_ = ' '
		YT005 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
		YT005 += "    AND D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA IN (SELECT E5_NUMERO+E5_PREFIXO+E5_CLIFOR+E5_LOJA
		YT005 += "                                                 FROM "+RetSqlName("SE5")+" SE5
		YT005 += "                                                INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = '"+xFilial("SA1")+"'
		YT005 += "                                                                     AND A1_COD = E5_CLIFOR
		YT005 += "                                                                     AND A1_LOJA = E5_LOJA
		YT005 += "                                                                     AND A1_GRPVEN = '"+MV_PAR01+"'
		YT005 += "                                                                     AND SA1.D_E_L_E_T_ = ' '
		YT005 += "                                                WHERE E5_FILIAL = '"+xFilial("SE5")+"'
		YT005 += "                                                  AND E5_DATA = '"+dtos(MV_PAR02)+"'
		YT005 += "                                                  AND E5_NATUREZ = '"+MV_PAR03+"'
		YT005 += "                                                  AND SE5.D_E_L_E_T_ = ' ')
		YT005 += "    AND SD2.D_E_L_E_T_ = ' '
		YT005 += " 	      ) AS TRTRWETW
		YT005 += "  GROUP BY D2_DOC,
		YT005 += "        D2_SERIE,
		YT005 += "        D2_TIPO,
		YT005 += "        D2_EMISSAO,
		YT005 += "        D2_CLIENTE,
		YT005 += "        D2_LOJA,
		YT005 += "        A1_NOME,
		YT005 += "        VLR_ORI,
		YT005 += "        VLR_BX,
		YT005 += "        VLR_IMP,
		YT005 += "        C5_YEMPPED,
		YT005 += "        C5_YPEDORI,
		YT005 += "        REF_NF
		YT005 += "  ORDER BY REF_NF

		TCQUERY YT005 New Alias "YT05"
		dbSelectArea("YT05")
		dbGoTop()
		ProcRegua(RecCount())
		efTtOri := 0
		efTtBx  := 0
		efTtImp := 0
		efTtNFP := 0
		While !Eof()

			cTempo := Alltrim(ElapTime(cHInicio, Time()))
			IncProc("Imprimindo....   Tempo: "+cTempo)

			If nRow1 > 2250
				fImpRoda()
				fImpCabec()
			EndIf

			cRelBGSub := "SELECT TOP 1 CONVERT(VARCHAR,CONVERT(DATETIME, SE1.E1_VENCREA),103) AS DATVENCNFR FROM SE1" + YT05->C5_YEMPPED + "0 SE1 WHERE SE1.E1_NUM = '" + YT05->REF_NF + "' ORDER BY SE1.E1_NUM, E1_PARCELA DESC"

			If chkfile("cRelBGSub")
				DbSelectArea("cRelBGSub")
				DbCloseArea()
			EndIf
			TcQuery cRelBGSub New Alias "cRelBGSub"

			DbSelectArea("cRelBGSub")
			DbGoTop()

			drEmpPdv := IIF(YT05->C5_YEMPPED == "01", "Biancogres", IIF(YT05->C5_YEMPPED == "05", "Incesa", IIF(YT05->C5_YEMPPED == "13", "Mundi", "??")))
			drPerct  := YT05->VLR_BX / (YT05->VLR_ORI - YT05->VLR_IMP) * 100
			gt_ListNf := +;
			Padr(YT05->D2_DOC                                     ,09)+"   "+;
			Padr(YT05->D2_SERIE                                   ,03)+"   "+;
			Padr(YT05->D2_TIPO                                    ,04)+"   "+;
			Padr(YT05->D2_EMISSAO 			                      ,10)+"   "+;
			Padr(YT05->D2_CLIENTE                                 ,06)+"   "+;
			Padr(YT05->D2_LOJA                                    ,02)+"   "+;
			Padr(YT05->A1_NOME                                    ,40)+"   "+;
			Padl(Transform(YT05->VLR_ORI, "@E 999,999,999.99")    ,14)+"   "+;
			Padl(Transform(YT05->VLR_BX, "@E 999,999,999.99")     ,14)+"   "+;
			Padl(Transform(YT05->VLR_IMP, "@E 999,999,999.99")    ,14)+"   "+;
			Padl(Transform(drPerct, "@E 99,999,999.99")+"%"       ,14)+"   "+;
			Padr(drEmpPdv                                         ,10)+"   "+;
			Padr(YT05->REF_NF                                     ,09)+"   "+;
			Padr(cRelBGSub->DATVENCNFR                            ,10)+"   "+;
			Padl(Transform(YT05->VLR_NF, "@E 999,999,999.99")     ,14)

			oPrint:Say  (nRow1 ,0050 ,gt_ListNf                               ,oFont7)
			oPrint:Line (nRow1+35, 050, nRow1+35, 3400)
			nRow1 += 075

			efTtOri += YT05->VLR_ORI
			efTtBx  += YT05->VLR_BX
			efTtImp += YT05->VLR_IMP
			efTtNFP += YT05->VLR_NF

			cRelBGSub->(dbCloseArea())

			dbSelectArea("YT05")
			dbSkip()

		End

		If nRow1 > 2250
			fImpRoda()
			fImpCabec()
		EndIf

		tt_ListNf := +;
		Padr("TOTAL ==>>"                                     ,09)+"   "+;
		Padr(""                                               ,03)+"   "+;
		Padr(""                                               ,04)+"   "+;
		Padr(""                                               ,10)+"   "+;
		Padr(""                                               ,06)+"   "+;
		Padr(""                                               ,02)+"   "+;
		Padr(""                                               ,40)+"   "+;
		Padl(Transform(efTtOri, "@E 999,999,999.99")          ,14)+"   "+;
		Padl(Transform(efTtBx, "@E 999,999,999.99")           ,14)+"   "+;
		Padl(Transform(efTtImp, "@E 999,999,999.99")          ,14)+"   "+;
		Padl(""                                               ,14)+"   "+;
		Padr(""                                               ,10)+"   "+;
		Padr(""                                               ,09)+"   "+;
		Padr(""                                               ,10)+"   "+;
		Padl(Transform(efTtNFP, "@E 999,999,999.99")          ,14)
		oPrint:Say  (nRow1 ,0050 ,tt_ListNf                               ,oFont7)
		oPrint:Line (nRow1+35, 050, nRow1+35, 3400)
		nRow1 += 075

		fImpRoda()

		YT05->(dbCloseArea())

		oPrint:EndPage()
		oPrint:Preview()

	Else

		oExcel := FWMSEXCEL():New()
		nxPlan := "Planilha 01"
		nxTabl := "Amarração Notas Fiscais InterCompany"

		oExcel:AddworkSheet(nxPlan)
		oExcel:AddTable (nxPlan, nxTabl)
		oExcel:AddColumn(nxPlan, nxTabl, "NATUREZ   "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PARC      "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "NUM       "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PRF       "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "FATURA    "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "CLI       "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "LJ        "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "EMPPED    "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "EMIS      "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "D2CLI     "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "D2LJ      "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PEDORI    "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "PROD      "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "ITEM      "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "LOTECTL   "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "D2QUANT   "             ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "D2TOTAL   "             ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "VLRTIT    "             ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "VLRBXA    "             ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "TOTALNF   "             ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "VTIT      "             ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "BXA       "             ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "CONTAREG  "             ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "REF_NF    "             ,1,1)
		oExcel:AddColumn(nxPlan, nxTabl, "VLR_NF    "             ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "PERC      "             ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "VALORNF   "             ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "DIFENCA   "             ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "PERC      "             ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "VALORBXA  "             ,3,2)
		oExcel:AddColumn(nxPlan, nxTabl, "VENCREATIT"             ,1,1)

		ST004 := Alltrim(" WITH CECBXLM AS (SELECT SE5.E5_NATUREZ NATUREZ,                                                                                                                                                                              ") + hfEntr
		ST004 += Alltrim("                         SE5.E5_PARCELA PARC,                                                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                         SE5.E5_NUMERO NUM,                                                                                                                                                                                   ") + hfEntr
		ST004 += Alltrim("                         SE5.E5_PREFIXO PRF,                                                                                                                                                                                  ") + hfEntr
		ST004 += Alltrim("                         SE5.E5_FATURA FATURA,                                                                                                                                                                                ") + hfEntr
		ST004 += Alltrim("                         SE5.E5_CLIFOR CLI,                                                                                                                                                                                   ") + hfEntr
		ST004 += Alltrim("                         SE5.E5_LOJA LJ,                                                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                         SC5.C5_YEMPPED EMPPED,                                                                                                                                                                               ") + hfEntr
		ST004 += Alltrim("                         SD2.D2_EMISSAO EMIS,                                                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                         SD2.D2_CLIENTE D2CLI,                                                                                                                                                                                ") + hfEntr
		ST004 += Alltrim("                         SD2.D2_LOJA D2LJ,                                                                                                                                                                                    ") + hfEntr
		ST004 += Alltrim("                         SC5.C5_YPEDORI PEDORI,                                                                                                                                                                               ") + hfEntr
		ST004 += Alltrim("                         SD2.D2_COD PROD,                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                         SD2.D2_ITEM ITEM,                                                                                                                                                                                    ") + hfEntr
		ST004 += Alltrim("                         SD2.D2_LOTECTL LOTECTL,                                                                                                                                                                              ") + hfEntr
		ST004 += Alltrim("                         SD2.D2_QUANT D2QUANT,                                                                                                                                                                                ") + hfEntr
		ST004 += Alltrim("                         SD2.D2_TOTAL D2TOTAL,                                                                                                                                                                                ") + hfEntr
		ST004 += Alltrim("                         SE1.E1_VALOR VLRTIT,                                                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                         SE5.E5_VALOR VLRBXA,                                                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                         (SELECT SUM(D2_TOTAL)                                                                                                                                                                                ") + hfEntr
		ST004 += Alltrim("                            FROM SD2070 XD2                                                                                                                                                                                   ") + hfEntr
		ST004 += Alltrim("                           WHERE XD2.D2_FILIAL = '01'                                                                                                                                                                         ") + hfEntr
		ST004 += Alltrim("                             AND XD2.D2_DOC = SD2.D2_DOC                                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                             AND XD2.D2_SERIE = SD2.D2_SERIE                                                                                                                                                                  ") + hfEntr
		ST004 += Alltrim("                             AND XD2.D2_CLIENTE = SD2.D2_CLIENTE                                                                                                                                                              ") + hfEntr
		ST004 += Alltrim("                             AND XD2.D2_LOJA = SD2.D2_LOJA                                                                                                                                                                    ") + hfEntr
		ST004 += Alltrim("                             AND XD2.D2_EMISSAO = SD2.D2_EMISSAO                                                                                                                                                              ") + hfEntr
		ST004 += Alltrim("                             AND XD2.D_E_L_E_T_ = ' ') TOTALNF                                                                                                                                                                ") + hfEntr
		ST004 += Alltrim("                    FROM SE5070 AS SE5                                                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                   INNER JOIN SA1070 AS SA1 ON SA1.A1_FILIAL = '  '                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                                           AND SA1.A1_COD = SE5.E5_CLIFOR                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                                           AND SA1.A1_LOJA = SE5.E5_LOJA                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                                           AND SA1.A1_GRPVEN = '"+MV_PAR01+"'                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                                           AND SA1.D_E_L_E_T_ = ' '                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                   INNER JOIN SD2070 AS SD2 ON SD2.D2_FILIAL = '01'                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                                           AND SD2.D2_DOC = SE5.E5_NUMERO                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                                           AND SD2.D2_SERIE = SE5.E5_PREFIXO                                                                                                                                                  ") + hfEntr
		ST004 += Alltrim("                                           AND SD2.D2_CLIENTE = SE5.E5_CLIFOR                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                                           AND SD2.D2_LOJA = SE5.E5_LOJA                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                                           AND SD2.D_E_L_E_T_ = ' '                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                   INNER JOIN SC5070 AS SC5 ON SC5.C5_FILIAL = '01'                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                                           AND SC5.C5_NUM = SD2.D2_PEDIDO                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                                           AND SC5.D_E_L_E_T_ = ' '                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                   INNER JOIN SE1070 AS SE1 ON SE1.E1_FILIAL = '01'                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                                           AND SE1.E1_NUM = SE5.E5_NUMERO                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                                           AND SE1.E1_PREFIXO = SE5.E5_PREFIXO                                                                                                                                                ") + hfEntr
		ST004 += Alltrim("                                           AND SE1.E1_CLIENTE = SE5.E5_CLIFOR                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                                           AND SE1.E1_PARCELA = SE5.E5_PARCELA                                                                                                                                                ") + hfEntr
		ST004 += Alltrim("                                           AND SE1.E1_LOJA = SE5.E5_LOJA                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                                           AND SE1.E1_TIPO = SE5.E5_TIPO                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                                           AND SE1.D_E_L_E_T_ = ' '                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                   WHERE SE5.E5_FILIAL = '01'                                                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                     AND SE5.E5_DATA = '"+dtos(MV_PAR02)+"'                                                                                                                                                                   ") + hfEntr
		ST004 += Alltrim("                     AND SE5.E5_NATUREZ = '"+MV_PAR03+"'                                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                     AND SE5.E5_TIPODOC IN('VL','BA')                                                                                                                                                                         ") + hfEntr
		ST004 += Alltrim("                     AND SE5.E5_TIPO = 'NF'                                                                                                                                                                                   ") + hfEntr
		ST004 += Alltrim("                     AND SE5.D_E_L_E_T_ = ' ')                                                                                                                                                                                ") + hfEntr
		ST004 += Alltrim(" SELECT *,                                                                                                                                                                                                                    ") + hfEntr
		ST004 += Alltrim("        BXA / VTIT PERC,                                                                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("        ROUND( ( VLR_NF / TOTALNF * VLRBXA ) / CONTAREG ,2 ) VALORNF,                                                                                                                                                         ") + hfEntr
		ST004 += Alltrim("        ROUND( ( VLR_NF / TOTALNF * VLRBXA  / CONTAREG ) - BXA ,2 ) DIFENCA,                                                                                                                                                  ") + hfEntr
		ST004 += Alltrim("        ABS( ROUND( ( ( VLR_NF / TOTALNF * VLRBXA / CONTAREG ) - BXA ) / BXA ,4 ) ) PERC,                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("        ROUND( ( VLR_NF / TOTALNF * VLRBXA / CONTAREG ) * (BXA / VTIT) ,2 ) VALORBXA,                                                                                                                                         ") + hfEntr
		ST004 += Alltrim("        CASE                                                                                                                                                                                                                  ") + hfEntr
		ST004 += Alltrim("          WHEN EMPPED = '01' THEN                                                                                                                                                                                             ") + hfEntr
		ST004 += Alltrim("            ( SELECT TOP 1 CONVERT(VARCHAR,CONVERT(DATETIME, SE1.E1_VENCREA),103) AS DATVENCNFR FROM SE1010 SE1 WHERE SE1.E1_NUM = REF_NF ORDER BY SE1.E1_NUM, E1_PARCELA DESC )                                              ") + hfEntr
		ST004 += Alltrim("          WHEN EMPPED = '05' THEN                                                                                                                                                                                             ") + hfEntr
		ST004 += Alltrim("            ( SELECT TOP 1 CONVERT(VARCHAR,CONVERT(DATETIME, SE1.E1_VENCREA),103) AS DATVENCNFR FROM SE1050 SE1 WHERE SE1.E1_NUM = REF_NF ORDER BY SE1.E1_NUM, E1_PARCELA DESC )                                              ") + hfEntr
		ST004 += Alltrim("          WHEN EMPPED = '13' THEN                                                                                                                                                                                             ") + hfEntr
		ST004 += Alltrim("            ( SELECT TOP 1 CONVERT(VARCHAR,CONVERT(DATETIME, SE1.E1_VENCREA),103) AS DATVENCNFR FROM SE1130 SE1 WHERE SE1.E1_NUM = REF_NF ORDER BY SE1.E1_NUM, E1_PARCELA DESC )                                              ") + hfEntr
		ST004 += Alltrim("        END VENCREATIT                                                                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("   FROM (SELECT *,                                                                                                                                                                                                            ") + hfEntr
		ST004 += Alltrim("                ( D2TOTAL / TOTALNF * VLRTIT ) VTIT,                                                                                                                                                                          ") + hfEntr
		ST004 += Alltrim("                ( D2TOTAL / TOTALNF * VLRBXA ) BXA,                                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                CASE                                                                                                                                                                                                          ") + hfEntr
		ST004 += Alltrim("                  WHEN EMPPED = '01' THEN                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                       (SELECT COUNT(XD2.D2_DOC)                                                                                                                                                                              ") + hfEntr
		ST004 += Alltrim("                          FROM SD2010 XD2                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                         INNER JOIN SC5010 XC5 ON XC5.C5_FILIAL = '01'                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_NUM = D2_PEDIDO                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_CLIENTE = D2_CLIENTE                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_LOJACLI = D2_LOJA                                                                                                                                                    ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.D_E_L_E_T_ = ' '                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                         WHERE XD2.D2_FILIAL = '01'                                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO = CBM.EMIS                                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO + XC5.C5_YCLIORI + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD + XD2.D2_ITEM + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) =                                                ") + hfEntr
		ST004 += Alltrim("                               CBM.EMIS + CBM.D2CLI + CBM.LJ + CBM.PEDORI + CBM.PROD + CBM.ITEM + CBM.LOTECTL + CONVERT(VARCHAR, CBM.D2QUANT)                                                                                 ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D_E_L_E_T_ = ' ')                                                                                                                                                                          ") + hfEntr
		ST004 += Alltrim("                  WHEN EMPPED = '05' THEN                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                       (SELECT COUNT(XD2.D2_DOC)                                                                                                                                                                              ") + hfEntr
		ST004 += Alltrim("                          FROM SD2050 XD2                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                         INNER JOIN SC5050 XC5 ON XC5.C5_FILIAL = '01'                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_NUM = D2_PEDIDO                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_CLIENTE = D2_CLIENTE                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_LOJACLI = D2_LOJA                                                                                                                                                    ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.D_E_L_E_T_ = ' '                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                         WHERE XD2.D2_FILIAL = '01'                                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO = CBM.EMIS                                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO + XC5.C5_YCLIORI + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD + XD2.D2_ITEM + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) =                                                ") + hfEntr
		ST004 += Alltrim("                               CBM.EMIS + CBM.D2CLI + CBM.LJ + CBM.PEDORI + CBM.PROD + CBM.ITEM + CBM.LOTECTL + CONVERT(VARCHAR, CBM.D2QUANT)                                                                                 ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D_E_L_E_T_ = ' ')                                                                                                                                                                          ") + hfEntr
		ST004 += Alltrim("                  WHEN EMPPED = '13' THEN                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                       (SELECT COUNT(XD2.D2_DOC)                                                                                                                                                                              ") + hfEntr
		ST004 += Alltrim("                          FROM SD2130 XD2                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                         INNER JOIN SC5130 XC5 ON XC5.C5_FILIAL = '01'                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_NUM = D2_PEDIDO                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_CLIENTE = D2_CLIENTE                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_LOJACLI = D2_LOJA                                                                                                                                                    ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.D_E_L_E_T_ = ' '                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                         WHERE XD2.D2_FILIAL = '01'                                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO = CBM.EMIS                                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO + XC5.C5_YCLIORI + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD + XD2.D2_ITEM + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) =                                                ") + hfEntr
		ST004 += Alltrim("                               CBM.EMIS + CBM.D2CLI + CBM.LJ + CBM.PEDORI + CBM.PROD + CBM.ITEM + CBM.LOTECTL + CONVERT(VARCHAR, CBM.D2QUANT)                                                                                 ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D_E_L_E_T_ = ' ')                                                                                                                                                                          ") + hfEntr
		ST004 += Alltrim("                END CONTAREG,                                                                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                CASE                                                                                                                                                                                                          ") + hfEntr
		ST004 += Alltrim("                  WHEN EMPPED = '01' THEN                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                       (SELECT TOP 1 XD2.D2_DOC                                                                                                                                                                               ") + hfEntr
		ST004 += Alltrim("                          FROM SD2010 XD2                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                         INNER JOIN SC5010 XC5 ON XC5.C5_FILIAL = '01'                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_NUM = D2_PEDIDO                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_CLIENTE = D2_CLIENTE                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_LOJACLI = D2_LOJA                                                                                                                                                    ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.D_E_L_E_T_ = ' '                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                         WHERE XD2.D2_FILIAL = '01'                                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO = CBM.EMIS                                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO + XC5.C5_YCLIORI + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD + XD2.D2_ITEM + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) =                                                ") + hfEntr
		ST004 += Alltrim("                               CBM.EMIS + CBM.D2CLI + CBM.LJ + CBM.PEDORI + CBM.PROD + CBM.ITEM + CBM.LOTECTL + CONVERT(VARCHAR, CBM.D2QUANT)                                                                                 ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D_E_L_E_T_ = ' ')                                                                                                                                                                          ") + hfEntr
		ST004 += Alltrim("                  WHEN EMPPED = '05' THEN                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                       (SELECT TOP 1 XD2.D2_DOC                                                                                                                                                                               ") + hfEntr
		ST004 += Alltrim("                          FROM SD2050 XD2                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                         INNER JOIN SC5050 XC5 ON XC5.C5_FILIAL = '01'                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_NUM = D2_PEDIDO                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_CLIENTE = D2_CLIENTE                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_LOJACLI = D2_LOJA                                                                                                                                                    ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.D_E_L_E_T_ = ' '                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                         WHERE XD2.D2_FILIAL = '01'                                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO = CBM.EMIS                                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO + XC5.C5_YCLIORI + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD + XD2.D2_ITEM + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) =                                                ") + hfEntr
		ST004 += Alltrim("                               CBM.EMIS + CBM.D2CLI + CBM.LJ + CBM.PEDORI + CBM.PROD + CBM.ITEM + CBM.LOTECTL + CONVERT(VARCHAR, CBM.D2QUANT)                                                                                 ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D_E_L_E_T_ = ' ')                                                                                                                                                                          ") + hfEntr
		ST004 += Alltrim("                  WHEN EMPPED = '13' THEN                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                       (SELECT TOP 1 XD2.D2_DOC                                                                                                                                                                               ") + hfEntr
		ST004 += Alltrim("                          FROM SD2130 XD2                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                         INNER JOIN SC5130 XC5 ON XC5.C5_FILIAL = '01'                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_NUM = D2_PEDIDO                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_CLIENTE = D2_CLIENTE                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_LOJACLI = D2_LOJA                                                                                                                                                    ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.D_E_L_E_T_ = ' '                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                         WHERE XD2.D2_FILIAL = '01'                                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO = CBM.EMIS                                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO + XC5.C5_YCLIORI + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD + XD2.D2_ITEM + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) =                                                ") + hfEntr
		ST004 += Alltrim("                               CBM.EMIS + CBM.D2CLI + CBM.LJ + CBM.PEDORI + CBM.PROD + CBM.ITEM + CBM.LOTECTL + CONVERT(VARCHAR, CBM.D2QUANT)                                                                                 ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D_E_L_E_T_ = ' ')                                                                                                                                                                          ") + hfEntr
		ST004 += Alltrim("                END REF_NF,                                                                                                                                                                                                   ") + hfEntr
		ST004 += Alltrim("                CASE                                                                                                                                                                                                          ") + hfEntr
		ST004 += Alltrim("                  WHEN EMPPED = '01' THEN                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                       (SELECT SUM(D2_TOTAL)                                                                                                                                                                                  ") + hfEntr
		ST004 += Alltrim("                          FROM SD2010 XD2                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                         INNER JOIN SC5010 XC5 ON XC5.C5_FILIAL = '01'                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_NUM = D2_PEDIDO                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_CLIENTE = D2_CLIENTE                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_LOJACLI = D2_LOJA                                                                                                                                                    ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.D_E_L_E_T_ = ' '                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                         WHERE XD2.D2_FILIAL = '01'                                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO = CBM.EMIS                                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO + XC5.C5_YCLIORI + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD + XD2.D2_ITEM + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) =                                                ") + hfEntr
		ST004 += Alltrim("                               CBM.EMIS + CBM.D2CLI + CBM.LJ + CBM.PEDORI + CBM.PROD + CBM.ITEM + CBM.LOTECTL + CONVERT(VARCHAR, CBM.D2QUANT)                                                                                 ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D_E_L_E_T_ = ' ')                                                                                                                                                                          ") + hfEntr
		ST004 += Alltrim("                  WHEN EMPPED = '05' THEN                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                       (SELECT SUM(D2_TOTAL)                                                                                                                                                                                  ") + hfEntr
		ST004 += Alltrim("                          FROM SD2050 XD2                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                         INNER JOIN SC5050 XC5 ON XC5.C5_FILIAL = '01'                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_NUM = D2_PEDIDO                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_CLIENTE = D2_CLIENTE                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_LOJACLI = D2_LOJA                                                                                                                                                    ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.D_E_L_E_T_ = ' '                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                         WHERE XD2.D2_FILIAL = '01'                                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO = CBM.EMIS                                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO + XC5.C5_YCLIORI + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD + XD2.D2_ITEM + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) =                                                ") + hfEntr
		ST004 += Alltrim("                               CBM.EMIS + CBM.D2CLI + CBM.LJ + CBM.PEDORI + CBM.PROD + CBM.ITEM + CBM.LOTECTL + CONVERT(VARCHAR, CBM.D2QUANT)                                                                                 ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D_E_L_E_T_ = ' ')                                                                                                                                                                          ") + hfEntr
		ST004 += Alltrim("                  WHEN EMPPED = '13' THEN                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                       (SELECT SUM(D2_TOTAL)                                                                                                                                                                                  ") + hfEntr
		ST004 += Alltrim("                          FROM SD2130 XD2                                                                                                                                                                                     ") + hfEntr
		ST004 += Alltrim("                         INNER JOIN SC5130 XC5 ON XC5.C5_FILIAL = '01'                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_NUM = D2_PEDIDO                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_CLIENTE = D2_CLIENTE                                                                                                                                                 ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.C5_LOJACLI = D2_LOJA                                                                                                                                                    ") + hfEntr
		ST004 += Alltrim("                                              AND XC5.D_E_L_E_T_ = ' '                                                                                                                                                        ") + hfEntr
		ST004 += Alltrim("                         WHERE XD2.D2_FILIAL = '01'                                                                                                                                                                           ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO = CBM.EMIS                                                                                                                                                                      ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D2_EMISSAO + XC5.C5_YCLIORI + XC5.C5_YLOJORI + XD2.D2_PEDIDO + XD2.D2_COD + XD2.D2_ITEM + XD2.D2_LOTECTL + CONVERT(VARCHAR, XD2.D2_QUANT) =                                                ") + hfEntr
		ST004 += Alltrim("                               CBM.EMIS + CBM.D2CLI + CBM.LJ + CBM.PEDORI + CBM.PROD + CBM.ITEM + CBM.LOTECTL + CONVERT(VARCHAR, CBM.D2QUANT)                                                                                 ") + hfEntr
		ST004 += Alltrim("                           AND XD2.D_E_L_E_T_ = ' ')                                                                                                                                                                          ") + hfEntr
		ST004 += Alltrim("                END VLR_NF                                                                                                                                                                                                    ") + hfEntr
		ST004 += Alltrim("   FROM CECBXLM CBM) AS TABL                                                                                                                                                                                                  ") + hfEntr
		STcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,ST004),'ST04',.F.,.T.)
		dbSelectArea("ST04")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc("Processamento1")

			oExcel:AddRow(nxPlan, nxTabl, { ST04->NATUREZ    ,;
			ST04->PARC                                       ,;
			ST04->NUM                                        ,;
			ST04->PRF                                        ,;
			ST04->FATURA                                     ,;
			ST04->CLI                                        ,;
			ST04->LJ                                         ,;
			ST04->EMPPED                                     ,;
			ST04->EMIS                                       ,;
			ST04->D2CLI                                      ,;
			ST04->D2LJ                                       ,;
			ST04->PEDORI                                     ,;
			ST04->PROD                                       ,;
			ST04->ITEM                                       ,;
			ST04->LOTECTL                                    ,;
			ST04->D2QUANT                                    ,;
			ST04->D2TOTAL                                    ,;
			ST04->VLRTIT                                     ,;
			ST04->VLRBXA                                     ,;
			ST04->TOTALNF                                    ,;
			ST04->VTIT                                       ,;
			ST04->BXA                                        ,;
			ST04->CONTAREG                                   ,;
			ST04->REF_NF                                     ,;
			ST04->VLR_NF                                     ,;
			ST04->PERC                                       ,;
			ST04->VALORNF                                    ,;
			ST04->DIFENCA                                    ,;
			ST04->PERC                                       ,;
			ST04->VALORBXA                                   ,;
			ST04->VENCREATIT                                 })

			dbSelectArea("ST04")
			dbSkip()

		End
		
		ST04->(dbCloseArea())
		Ferase(STcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(STcIndex+OrdBagExt())          //indice gerado

		xArqTemp := "nfintercompany - " + cEmpAnt

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


	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpCabec¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.01.13 ¦¦¦
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
	sw_Perid :=  "Data Ref: "+ dtoc(MV_PAR02) + " Grupo Cliente: " + MV_PAR01
	oPrint:Say  (nRow1    ,0050 ,Padc(fCabec,110)                                           ,oFont14)
	oPrint:Say  (nRow1+10 ,3000 ,"Página:"                                                  ,oFont7)
	oPrint:Say  (nRow1+05 ,3150 ,Transform(wnPag,"@E 99999999")                             ,oFont8)
	oPrint:Say  (nRow1+60 ,3000 ,"Emissão:"                                                 ,oFont7)
	oPrint:Say  (nRow1+65 ,3150 ,dtoc(dDataBase)                                            ,oFont8)
	oPrint:Say  (nRow1+75 ,0050 ,Padc(sw_Perid,190)                                         ,oFont10)
	nRow1 += 150
	oPrint:Line (nRow1, 050, nRow1, 3400)
	nRow1 += 050

	gt_ListCb := +;
	Padr("N.Fiscal"                                       ,09)+"   "+;
	Padr("Serie"                                          ,03)+"   "+;
	Padr("Tipo"                                           ,04)+"   "+;
	Padr("Emissao"                                        ,10)+"   "+;
	Padr("Cli."                                           ,06)+"   "+;
	Padr("Lj"                                             ,02)+"   "+;
	Padr("Nome"                                           ,40)+"   "+;
	Padl("Vlr_Ori"                                        ,14)+"   "+;
	Padl("Vlr_Baixa"                                      ,14)+"   "+;
	Padl("Vlr_Imp"                                        ,14)+"   "+;
	Padl("Percentual"                                     ,14)+"   "+;
	Padr("Emp_Ori"                                        ,10)+"   "+;
	Padr("Ref.Nf"                                         ,09)+"   "+;
	Padr("Vcto. NFR"                                      ,10)+"   "+;
	Padl("Vlr_NF_PGTO"                                    ,14)

	oPrint:Say  (nRow1 ,0050 ,gt_ListCb                               ,oFont7)
	oPrint:Line (nRow1+35, 050, nRow1+35, 3400)
	nRow1 += 065

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fImpRoda ¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 08.01.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fImpRoda()

	oPrint:Line (2300, 050, 2300, 3400)
	oPrint:Say  (2300+30 , 050,"Prog.: " + fPerg                                      ,oFont7)
	oPrint:Say  (2300+30 ,2850,"Impresso em:  "+dtoc(dDataBase)+"  "+TIME()           ,oFont7)
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
	aAdd(aRegs,{cPerg,"01","Grupo de Cliente    ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Da Data             ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Natureza            ?","","","mv_ch3","C",10,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SED"})
	aAdd(aRegs,{cPerg,"04","Extração dos dados  ?","","","mv_ch4","N",01,0,0,"C","","mv_par04","Até Fev/17","","","","","A Partir Mar/17","","","","","","","","","","","","","","","","","","",""})

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
