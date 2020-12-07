#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA689
@author Marcos Alberto Soprani
@since 10/08/16
@version 1.0
@description Relação de estoque
@obs OS: 3008-16 - MARCELO VALIATI GUIZZARDI
@type function
/*/

User Function BIA689()

	fPerg  := "BIA689"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	hkjUlMes := GetMV("MV_ULMES")
	nxEnter  := CHR(13) + CHR(10)

	U_BIAMsgRun("Processando...                          ",, {|| BIA689PRC() })

Return

Static Function BIA689PRC()

	IncProc("Processamento....")

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha01"
	nxTabl := "Saldo em Estoque - Último Fechamento: " + dtoc(hkjUlMes) + ", Data de Referência para Saldo Atual: " + dtoc(dDataBase) 
	nxCont := 0 

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "Empresa      "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Produto      "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Descricao    "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Tipo         "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Descr Tipo   "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Grupo        "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Descr Grupo  "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Unidade      "               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Qtd Ult Compra"              ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Vlr Ult Compra"              ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Custo Ult Compra"            ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Data Ult Compra"             ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "Qtd Atual    "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Vlr Atual    "               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Data Ult Req "               ,1,4)
	oExcel:AddColumn(nxPlan, nxTabl, "Qtd Req ULMES"               ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Custo Req ULMES"             ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Qtd Req Acumulado"           ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Custo Req Acumulado"         ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Qtd Virada Estoque"          ,3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "Custo Virada Estoq"          ,3,2)

	TR007 := Alltrim(" WITH RFCOMPRAS AS (SELECT B1_COD PRODUT, D1_DTDIGIT DTDIGIT, SUM(D1_QUANT) QUANT, SUM(D1_TOTAL) TOTAL, SUM(D1_CUSTO) CUSTO         ") + nxEnter
	TR007 += Alltrim("                      FROM " + RetSqlName("SB1") + " SB1                                                                            ") + nxEnter
	TR007 += Alltrim("                     INNER JOIN " + RetSqlName("SD1") + " SD1 ON D1_FILIAL = '" + xFilial("SD1") + "'                               ") + nxEnter
	TR007 += Alltrim("                                          AND D1_COD = B1_COD                                                                       ") + nxEnter
	TR007 += Alltrim("                                          AND D1_DTDIGIT IN(SELECT MAX(D1_DTDIGIT) DTDIGIT                                          ") + nxEnter
	TR007 += Alltrim("                                                              FROM " + RetSqlName("SD1") + " ZD1                                    ") + nxEnter
	TR007 += Alltrim("                                                             INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_CODIGO = ZD1.D1_TES     ") + nxEnter
	TR007 += Alltrim("                                                                                  AND F4_DUPLIC = 'S'                               ") + nxEnter
	TR007 += Alltrim("                                                                                  AND SF4.D_E_L_E_T_ = ' '                          ") + nxEnter
	TR007 += Alltrim("                                                             WHERE ZD1.D1_FILIAL = '" + xFilial("SD1") + "'                         ") + nxEnter
	TR007 += Alltrim("                                                               AND ZD1.D1_COD = SB1.B1_COD                                          ") + nxEnter
	TR007 += Alltrim("                                                               AND ZD1.D_E_L_E_T_ = ' ')                                            ") + nxEnter
	TR007 += Alltrim("                                          AND SD1.D_E_L_E_T_ = ' '                                                                  ") + nxEnter
	TR007 += Alltrim("                     INNER JOIN " + RetSqlName("SF4") + " SF4 ON F4_CODIGO = D1_TES                                                 ") + nxEnter
	TR007 += Alltrim("                                          AND F4_DUPLIC = 'S'                                                                       ") + nxEnter
	TR007 += Alltrim("                                          AND SF4.D_E_L_E_T_ = ' '                                                                  ") + nxEnter
	TR007 += Alltrim("                     WHERE B1_FILIAL = '" + xFilial("SB1") + "'                                                                     ") + nxEnter
	TR007 += Alltrim("                       AND B1_COD BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'                                                 ") + nxEnter
	TR007 += Alltrim("                       AND SB1.D_E_L_E_T_ = ' '                                                                                     ") + nxEnter
	TR007 += Alltrim("                     GROUP BY B1_COD, D1_DTDIGIT)                                                                                   ") + nxEnter
	TR007 += Alltrim(" ,    RFSALDEST AS (SELECT B1_COD PRODUT, SUM(B2_QATU) QATU, SUM(B2_VATU1) VATU1                                                    ") + nxEnter
	TR007 += Alltrim("                      FROM " + RetSqlName("SB1") + " SB1                                                                            ") + nxEnter
	TR007 += Alltrim("                     INNER JOIN " + RetSqlName("SB2") + " SB2 ON B2_FILIAL = '" + xFilial("SB2") + "'                               ") + nxEnter
	TR007 += Alltrim("                                          AND B2_COD = B1_COD                                                                       ") + nxEnter
	TR007 += Alltrim("                                          AND SB2.D_E_L_E_T_ = ' '                                                                  ") + nxEnter
	TR007 += Alltrim("                     WHERE B1_FILIAL = '" + xFilial("SB1") + "'                                                                     ") + nxEnter
	TR007 += Alltrim("                       AND B1_COD BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'                                                 ") + nxEnter
	TR007 += Alltrim("                       AND SB1.D_E_L_E_T_ = ' '                                                                                     ") + nxEnter
	TR007 += Alltrim("                     GROUP BY B1_COD)                                                                                               ") + nxEnter
	TR007 += Alltrim(" ,    RFULTMOVE AS (SELECT D3_COD PRODUT,                                                                                           ") + nxEnter
	TR007 += Alltrim("                           MAX(D3_EMISSAO) EMISSAO                                                                                  ") + nxEnter
	TR007 += Alltrim("                      FROM " + RetSqlName("SD3") + " SD3                                                                            ") + nxEnter
	TR007 += Alltrim("                     WHERE D3_FILIAL = '" + xFilial("SD3") + "'                                                                     ") + nxEnter
	TR007 += Alltrim("                       AND D3_EMISSAO BETWEEN '" + Substr(dtos(hkjUlMes),1,6) + "01" + "' AND '" + dtos(hkjUlMes) + "'              ") + nxEnter
	TR007 += Alltrim("                       AND D3_COD BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'                                                 ") + nxEnter
	TR007 += Alltrim("                       AND SD3.D_E_L_E_T_ = ' '                                                                                     ") + nxEnter
	TR007 += Alltrim("                     GROUP BY D3_COD)                                                                                               ") + nxEnter
	TR007 += Alltrim(" ,    RFCONSMES AS (SELECT PRODUT,                                                                                                  ") + nxEnter
	TR007 += Alltrim("                           SUM(QUANT) QUANT,                                                                                        ") + nxEnter
	TR007 += Alltrim("                           SUM(CUSTO1) CUSTO1                                                                                       ") + nxEnter
	TR007 += Alltrim("                       FROM (SELECT D3_COD PRODUT,                                                                                  ") + nxEnter
	TR007 += Alltrim("                                    SUM(D3_QUANT) QUANT,                                                                            ") + nxEnter
	TR007 += Alltrim("                                    SUM(D3_CUSTO1) CUSTO1                                                                           ") + nxEnter
	TR007 += Alltrim("                               FROM " + RetSqlName("SD3") + " SD3                                                                   ") + nxEnter
	TR007 += Alltrim("                              WHERE D3_FILIAL = '" + xFilial("SD3") + "'                                                            ") + nxEnter
	TR007 += Alltrim("                                AND D3_EMISSAO BETWEEN '" + Substr(dtos(hkjUlMes),1,6) + "01" + "' AND '" + dtos(hkjUlMes) + "'     ") + nxEnter
	TR007 += Alltrim("                                AND D3_COD BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'                                        ") + nxEnter
	TR007 += Alltrim("                                AND D3_TM > '500'                                                                                   ") + nxEnter
	TR007 += Alltrim("                                AND SD3.D_E_L_E_T_ = ' '                                                                            ") + nxEnter
	TR007 += Alltrim("                              GROUP BY D3_COD                                                                                       ") + nxEnter
	TR007 += Alltrim("                              UNION ALL                                                                                             ") + nxEnter
	TR007 += Alltrim("                             SELECT D3_COD PRODUT,                                                                                  ") + nxEnter
	TR007 += Alltrim("                                    SUM(D3_QUANT)*(-1) QUANT,                                                                       ") + nxEnter
	TR007 += Alltrim("                                    SUM(D3_CUSTO1)*(-1) CUSTO1                                                                      ") + nxEnter
	TR007 += Alltrim("                               FROM " + RetSqlName("SD3") + " SD3                                                                   ") + nxEnter
	TR007 += Alltrim("                              WHERE D3_FILIAL = '" + xFilial("SD3") + "'                                                            ") + nxEnter
	TR007 += Alltrim("                                AND D3_EMISSAO BETWEEN '" + Substr(dtos(hkjUlMes),1,6) + "01" + "' AND '" + dtos(hkjUlMes) + "'     ") + nxEnter
	TR007 += Alltrim("                                AND D3_COD BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'                                        ") + nxEnter
	TR007 += Alltrim("                                AND D3_TM <= '500'                                                                                  ") + nxEnter
	TR007 += Alltrim("                                AND SD3.D_E_L_E_T_ = ' '                                                                            ") + nxEnter
	TR007 += Alltrim("                              GROUP BY D3_COD) AS TAB1 GROUP BY PRODUT)                                                             ") + nxEnter
	TR007 += Alltrim(" ,    RFCONSACM AS (SELECT PRODUT,                                                                                                  ") + nxEnter
	TR007 += Alltrim("                           SUM(QUANT) QUANT,                                                                                        ") + nxEnter
	TR007 += Alltrim("                           SUM(CUSTO1) CUSTO1                                                                                       ") + nxEnter
	TR007 += Alltrim("                       FROM (SELECT D3_COD PRODUT,                                                                                  ") + nxEnter
	TR007 += Alltrim("                                    SUM(D3_QUANT) QUANT,                                                                            ") + nxEnter
	TR007 += Alltrim("                                    SUM(D3_CUSTO1) CUSTO1                                                                           ") + nxEnter
	TR007 += Alltrim("                               FROM " + RetSqlName("SD3") + " SD3                                                                   ") + nxEnter
	TR007 += Alltrim("                              WHERE D3_FILIAL = '" + xFilial("SD3") + "'                                                            ") + nxEnter
	TR007 += Alltrim("                                AND D3_EMISSAO BETWEEN '" + Substr(dtos(hkjUlMes-180),1,6) + "01" + "' AND '" + dtos(hkjUlMes) + "' ") + nxEnter
	TR007 += Alltrim("                                AND D3_COD BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'                                        ") + nxEnter
	TR007 += Alltrim("                                AND D3_TM > '500'                                                                                   ") + nxEnter
	TR007 += Alltrim("                                AND SD3.D_E_L_E_T_ = ' '                                                                            ") + nxEnter
	TR007 += Alltrim("                              GROUP BY D3_COD                                                                                       ") + nxEnter
	TR007 += Alltrim("                              UNION ALL                                                                                             ") + nxEnter
	TR007 += Alltrim("                             SELECT D3_COD PRODUT,                                                                                  ") + nxEnter
	TR007 += Alltrim("                                    SUM(D3_QUANT)*(-1) QUANT,                                                                       ") + nxEnter
	TR007 += Alltrim("                                    SUM(D3_CUSTO1)*(-1) CUSTO1                                                                      ") + nxEnter
	TR007 += Alltrim("                               FROM " + RetSqlName("SD3") + " SD3                                                                   ") + nxEnter
	TR007 += Alltrim("                              WHERE D3_FILIAL = '" + xFilial("SD3") + "'                                                            ") + nxEnter
	TR007 += Alltrim("                                AND D3_EMISSAO BETWEEN '" + Substr(dtos(hkjUlMes-180),1,6) + "01" + "' AND '" + dtos(hkjUlMes) + "' ") + nxEnter
	TR007 += Alltrim("                                AND D3_COD BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'                                        ") + nxEnter
	TR007 += Alltrim("                                AND D3_TM <= '500'                                                                                  ") + nxEnter
	TR007 += Alltrim("                                AND SD3.D_E_L_E_T_ = ' '                                                                            ") + nxEnter
	TR007 += Alltrim("                              GROUP BY D3_COD) AS TAB1 GROUP BY PRODUT)                                                             ") + nxEnter
	TR007 += Alltrim(" ,    VIRADAEST AS (SELECT B9_COD PRODUT,                                                                                           ") + nxEnter
	TR007 += Alltrim("                           SUM(B9_QINI) QINI,                                                                                       ") + nxEnter
	TR007 += Alltrim("                           SUM(B9_VINI1) VINI1                                                                                      ") + nxEnter
	TR007 += Alltrim("                      FROM " + RetSqlName("SB9") + " SB9                                                                            ") + nxEnter
	TR007 += Alltrim("                     WHERE B9_FILIAL = '" + xFilial("SB9") + "'                                                                     ") + nxEnter
	TR007 += Alltrim("                       AND B9_DATA = '" + dtos(hkjUlMes) + "'                                                                       ") + nxEnter
	TR007 += Alltrim("                       AND B9_COD BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'                                                 ") + nxEnter
	TR007 += Alltrim("                       AND ( B9_QINI <> 0 OR B9_VINI1 <> 0 )                                                                        ") + nxEnter
	TR007 += Alltrim("                       AND SB9.D_E_L_E_T_ = ' '                                                                                     ") + nxEnter
	TR007 += Alltrim("                     GROUP BY B9_COD)                                                                                               ") + nxEnter
	TR007 += Alltrim(" SELECT *                                                                                                                           ") + nxEnter
	TR007 += Alltrim("   FROM (SELECT '" + cEmpAnt+ "' EMPR,                                                                                              ") + nxEnter
	TR007 += Alltrim("                B1_COD PRODUTO,                                                                                                     ") + nxEnter
	TR007 += Alltrim("                SUBSTRING(B1_DESC,1,50) DPRODUTO,                                                                                   ") + nxEnter
	TR007 += Alltrim("                B1_TIPO TIPO,                                                                                                       ") + nxEnter
	TR007 += Alltrim("                X5_DESCRI DTIPO,                                                                                                    ") + nxEnter
	TR007 += Alltrim("                B1_GRUPO GRUPO,                                                                                                     ") + nxEnter
	TR007 += Alltrim("                BM_DESC DGRUPO,                                                                                                     ") + nxEnter
	TR007 += Alltrim("                B1_UM UNIDADE,                                                                                                      ") + nxEnter
	TR007 += Alltrim("                ISNULL(RFC.QUANT, 0) QTDUCOM,                                                                                       ") + nxEnter
	TR007 += Alltrim("                ISNULL(RFC.TOTAL, 0) VLRUCOM,                                                                                       ") + nxEnter
	TR007 += Alltrim("                ISNULL(RFC.CUSTO, 0) CSTUCOM,                                                                                       ") + nxEnter
	TR007 += Alltrim("                ISNULL(RFC.DTDIGIT, '') DATUCOM,                                                                                    ") + nxEnter
	TR007 += Alltrim("                ISNULL(RFS.QATU, 0) QATU,                                                                                           ") + nxEnter
	TR007 += Alltrim("                ISNULL(RFS.VATU1, 0) VATU,                                                                                          ") + nxEnter
	TR007 += Alltrim("                ISNULL(RFE.EMISSAO, '') DTULTREQ,                                                                                   ") + nxEnter
	TR007 += Alltrim("                ISNULL(RFM.QUANT, 0) RQUM,                                                                                          ") + nxEnter
	TR007 += Alltrim("                ISNULL(RFM.CUSTO1, 0) RVUM,                                                                                         ") + nxEnter
	TR007 += Alltrim("                ISNULL(RFA.QUANT, 0) RQUA,                                                                                          ") + nxEnter
	TR007 += Alltrim("                ISNULL(RFA.CUSTO1, 0) RVUA,                                                                                         ") + nxEnter
	TR007 += Alltrim("                ISNULL(VRE.QINI, 0) QINI,                                                                                           ") + nxEnter
	TR007 += Alltrim("                ISNULL(VRE.VINI1, 0) VINI1                                                                                          ") + nxEnter
	TR007 += Alltrim("           FROM " + RetSqlName("SB1") + " SB1                                                                                       ") + nxEnter
	TR007 += Alltrim("          INNER JOIN " + RetSqlName("SBM") + " SBM ON BM_FILIAL = '" + xFilial("SBM") + "'                                          ") + nxEnter
	TR007 += Alltrim("                               AND BM_GRUPO = B1_GRUPO                                                                              ") + nxEnter
	TR007 += Alltrim("                               AND SBM.D_E_L_E_T_ = ' '                                                                             ") + nxEnter
	TR007 += Alltrim("          INNER JOIN " + RetSqlName("SX5") + " SX5 ON X5_TABELA = '02'                                                              ") + nxEnter
	TR007 += Alltrim("                               AND X5_CHAVE = B1_TIPO                                                                               ") + nxEnter
	TR007 += Alltrim("                               AND SX5.D_E_L_E_T_ = ' '                                                                             ") + nxEnter
	TR007 += Alltrim("           LEFT JOIN RFCOMPRAS RFC ON RFC.PRODUT = B1_COD                                                                           ") + nxEnter
	TR007 += Alltrim("           LEFT JOIN RFSALDEST RFS ON RFS.PRODUT = B1_COD                                                                           ") + nxEnter
	TR007 += Alltrim("           LEFT JOIN RFULTMOVE RFE ON RFE.PRODUT = B1_COD                                                                           ") + nxEnter
	TR007 += Alltrim("           LEFT JOIN RFCONSMES RFM ON RFM.PRODUT = B1_COD                                                                           ") + nxEnter
	TR007 += Alltrim("           LEFT JOIN RFCONSACM RFA ON RFA.PRODUT = B1_COD                                                                           ") + nxEnter
	TR007 += Alltrim("           LEFT JOIN VIRADAEST VRE ON VRE.PRODUT = B1_COD                                                                           ") + nxEnter
	TR007 += Alltrim("          WHERE B1_FILIAL = '" + xFilial("SB1") + "'                                                                                ") + nxEnter
	TR007 += Alltrim("            AND B1_COD BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "'                                                            ") + nxEnter
	TR007 += Alltrim("            AND B1_TIPO NOT IN('MO')                                                                                                ") + nxEnter
	TR007 += Alltrim("            AND SB1.D_E_L_E_T_ = ' ') AS TABGRF                                                                                     ") + nxEnter
	TR007 += Alltrim("  WHERE QATU + VATU + QINI + VINI1 <> 0                                                                                             ") + nxEnter
	TR007 += Alltrim("  ORDER BY PRODUTO                                                                                                                  ") + nxEnter
	TRcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,TR007),'TR07',.F.,.T.)
	dbSelectArea("TR07")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		nxCont ++
		IncProc("Processamento... " + Alltrim(Str(nxCont)))

		oExcel:AddRow(nxPlan, nxTabl, { TR07->EMPR  ,;
		TR07->PRODUTO                               ,;
		TR07->DPRODUTO                              ,;
		TR07->TIPO                                  ,;
		TR07->DTIPO                                 ,;
		TR07->GRUPO                                 ,;
		TR07->DGRUPO                                ,;
		TR07->UNIDADE                               ,;
		TR07->QTDUCOM                               ,;
		TR07->VLRUCOM                               ,;
		TR07->CSTUCOM                               ,;
		stod(TR07->DATUCOM)                         ,;
		TR07->QATU                                  ,;
		TR07->VATU                                  ,;
		stod(TR07->DTULTREQ)                        ,;
		TR07->RQUM                                  ,;
		TR07->RVUM                                  ,;
		TR07->RQUA                                  ,;
		TR07->RVUA                                  ,;
		TR07->QINI                                  ,;
		TR07->VINI1                                 })

		dbSelectArea("TR07")
		dbSkip()

	End

	TR07->(dbCloseArea())
	Ferase(TRcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(TRcIndex+OrdBagExt())          //indice gerado

	xArqTemp := IIF(Empty(MV_PAR01), "BIA689", Alltrim(MV_PAR01) )

	If File("C:\TEMP\"+xArqTemp+".xml")
		If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
		EndIf
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
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 04/08/16 ¦¦¦
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
	aAdd(aRegs,{cPerg,"01","Nome do Arquivo       ?","","","mv_ch1","C",80,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","De Produto            ?","","","mv_ch2","C",15,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"03","Ate Produto           ?","","","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SB1"})
	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return
