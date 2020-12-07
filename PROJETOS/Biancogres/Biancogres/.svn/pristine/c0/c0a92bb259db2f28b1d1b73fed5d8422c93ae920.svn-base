#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} BIA937
@author Luana Marin Ribeiro
@since 05/07/2019
@version 1.0
@description Verificação Pós RCM
@obs Estoque e Custos
@type function
/*/

User Function BIA937()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local xt
	Local _cAlias
	Local _cDataDe
	Local _cDataAte

	fPerg := "BIA937"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	fValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA937 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase < GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser maior ou igual a data de fechamento do mês.","BIA937 - Data de Fechamento!!!")
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA937",fPerg)

	oExcel := FWMSEXCEL():New()

	//                                                                      Planilha 01
	//=================================================================================
	nxPlan := "Planilha 01"
	nxTabl := "Vendas em duplicidade"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "FILIAL",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DATA",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOTE",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SUB-LOTE",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LINHA",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DEBITO",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CREDITO",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CV DEB",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CV CRE",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "VALOR",3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "HIST",1,1)
	
	ZP001 := "WITH TAB_AUX AS (SELECT CT2.CT2_FILIAL FIL" + CRLF
	ZP001 += "		, CT2.CT2_DATA DT" + CRLF
	ZP001 += "		, CT2.CT2_DEBITO DEB" + CRLF
	ZP001 += "		, CT2.CT2_CREDIT CRE" + CRLF
	ZP001 += "		, CT2.CT2_CLVLDB CLVDB" + CRLF
	ZP001 += "		, CT2.CT2_CLVLCR CLVCR" + CRLF
	ZP001 += "		, CT2.CT2_VALOR VLR" + CRLF
	ZP001 += "		, CT2.CT2_HIST HIST" + CRLF
	ZP001 += "		, COUNT(*) CONTAD" + CRLF
	ZP001 += "	FROM " + RetSqlName("CT2") + " CT2 WITH(NOLOCK)" + CRLF
	ZP001 += "	WHERE CT2.CT2_FILIAL = '" + xFilial("CT2") + "'" + CRLF
	ZP001 += "		AND CT2.CT2_DATA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'" + CRLF
	ZP001 += "		AND CT2.CT2_DC <> '4'" + CRLF
	ZP001 += "		AND CT2.D_E_L_E_T_ = ' '" + CRLF
	ZP001 += "	GROUP BY CT2.CT2_FILIAL" + CRLF
	ZP001 += "		, CT2.CT2_DATA" + CRLF
	ZP001 += "		, CT2.CT2_DEBITO" + CRLF
	ZP001 += "		, CT2.CT2_CREDIT" + CRLF
	ZP001 += "		, CT2.CT2_CLVLDB" + CRLF
	ZP001 += "		, CT2.CT2_CLVLCR" + CRLF
	ZP001 += "		, CT2.CT2_VALOR" + CRLF
	ZP001 += "		, CT2.CT2_HIST" + CRLF
	ZP001 += "	HAVING COUNT(*) > 1)" + CRLF
	ZP001 += "" + CRLF
	ZP001 += "SELECT CT2.CT2_FILIAL FILIAL" + CRLF
	ZP001 += "	, CT2.CT2_DATA DAT" + CRLF
	ZP001 += "	, CT2.CT2_LOTE LOTE" + CRLF
	ZP001 += "	, CT2.CT2_SBLOTE SBLOTE" + CRLF
	ZP001 += "	, CT2.CT2_DOC DOC" + CRLF
	ZP001 += "	, CT2.CT2_LINHA LINHA" + CRLF
	ZP001 += "	, CT2.CT2_DEBITO DEBITO" + CRLF
	ZP001 += "	, CT2.CT2_CREDIT CREDITO" + CRLF
	ZP001 += "	, CT2.CT2_CLVLDB CV_DEB" + CRLF
	ZP001 += "	, CT2.CT2_CLVLCR CV_CRE" + CRLF
	ZP001 += "	, CT2.CT2_VALOR VALOR" + CRLF
	ZP001 += "	, CT2.CT2_HIST HISTOR" + CRLF
	ZP001 += "FROM " + RetSqlName("CT2") + " CT2 WITH(NOLOCK)" + CRLF
	ZP001 += "	INNER JOIN TAB_AUX AUX ON CT2.CT2_FILIAL = AUX.FIL" + CRLF
	ZP001 += "		AND CT2.CT2_DATA = AUX.DT" + CRLF
	ZP001 += "		AND CT2.CT2_DEBITO = AUX.DEB" + CRLF
	ZP001 += "		AND CT2.CT2_CREDIT = AUX.CRE" + CRLF
	ZP001 += "		AND CT2.CT2_CLVLDB = AUX.CLVDB" + CRLF
	ZP001 += "		AND CT2.CT2_CLVLCR = AUX.CLVCR" + CRLF
	ZP001 += "		AND CT2.CT2_VALOR = AUX.VLR" + CRLF
	ZP001 += "		AND CT2.CT2_HIST = AUX.HIST" + CRLF
	ZP001 += "WHERE CT2.D_E_L_E_T_ = ''" + CRLF
	ZP001 += "ORDER BY CT2.CT2_FILIAL" + CRLF
	ZP001 += "	, CT2.CT2_DATA" + CRLF
	ZP001 += "	, CT2.CT2_DEBITO" + CRLF
	ZP001 += "	, CT2.CT2_CREDIT" + CRLF
	ZP001 += "	, CT2.CT2_CLVLDB" + CRLF
	ZP001 += "	, CT2.CT2_CLVLCR" + CRLF
	ZP001 += "	, CT2.CT2_VALOR" + CRLF
	ZP001 += "	, CT2.CT2_HIST" + CRLF
	
	ZPcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP001),'ZP01',.F.,.T.)
	dbSelectArea("ZP01")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento01")

		oExcel:AddRow(nxPlan, nxTabl, { ZP01->FILIAL, ZP01->DAT, ZP01->LOTE, ZP01->SBLOTE, ZP01->DOC, ZP01->LINHA, ZP01->DEBITO, ZP01->CREDITO, ZP01->CV_DEB, ZP01->CV_CRE, ZP01->VALOR, ZP01->HISTOR })

		dbSelectArea("ZP01")
		dbSkip()

	End
	ZP01->(dbCloseArea())
	Ferase(ZPcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ZPcIndex+OrdBagExt())          //indice gerado

	//                                                                      Planilha 02
	//=================================================================================
	nxPlan := "Planilha 02"
	nxTabl := "Lançamentos devolução com débito e crédito na mesma conta"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "FILIAL",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DATA",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TP LANÇ",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOTE",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SUB LOTE",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LINHA",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DEBITO",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CREDITO",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CV DEB",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CV CRE",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "VALOR",3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "HIST",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "MOTIVO",1,1)
	
	ZP002 := "SELECT CT2.CT2_FILIAL FIL" + CRLF
	ZP002 += "	, CT2.CT2_DATA DT" + CRLF
	ZP002 += "	, (CASE CT2.CT2_DC WHEN 1 THEN '1 - DEBITO' WHEN 2 THEN '2 - CREDITO' WHEN 3 THEN '3 - PARTIDA DOBRADA' ELSE '' END) TP_LANC" + CRLF
	ZP002 += "	, CT2.CT2_LOTE LOTE" + CRLF
	ZP002 += "	, CT2.CT2_SBLOTE SBLOTE" + CRLF
	ZP002 += "	, CT2.CT2_DOC DOC" + CRLF
	ZP002 += "	, CT2.CT2_LINHA LINHA" + CRLF
	ZP002 += "	, CT2.CT2_DEBITO DEB" + CRLF
	ZP002 += "	, CT2.CT2_CREDIT CRE" + CRLF
	ZP002 += "	, CT2.CT2_CLVLDB CLVDB" + CRLF
	ZP002 += "	, CT2.CT2_CLVLCR CLVCR" + CRLF
	ZP002 += "	, CT2.CT2_VALOR VLR" + CRLF
	ZP002 += "	, CT2.CT2_HIST HIST" + CRLF
	ZP002 += "	, (CASE CT2.CT2_DC WHEN 1 THEN" + CRLF
	ZP002 += "			(CASE WHEN CT2.CT2_DEBITO = '' THEN 'DEBITO VAZIO'" + CRLF
	ZP002 += "				WHEN CT2.CT2_CREDIT <> '' THEN 'CREDITO PREENCHIDO'" + CRLF
	ZP002 += "				ELSE '' END)" + CRLF
	ZP002 += "		WHEN 2 THEN" + CRLF
	ZP002 += "			(CASE WHEN CT2.CT2_DEBITO <> '' THEN 'DEBITO PREENCHIDO'" + CRLF
	ZP002 += "				WHEN CT2.CT2_CREDIT = '' THEN 'CREDITO VAZIO'" + CRLF
	ZP002 += "				ELSE '' END)" + CRLF
	ZP002 += "		WHEN 3 THEN" + CRLF
	ZP002 += "			(CASE WHEN CT2.CT2_DEBITO = '' THEN 'DEBITO VAZIO'" + CRLF
	ZP002 += "				WHEN CT2.CT2_CREDIT = '' THEN 'CREDITO VAZIO'" + CRLF
	ZP002 += "				WHEN CT2.CT2_DEBITO + CT2.CT2_CLVLDB = CT2.CT2_CREDIT + CT2.CT2_CLVLCR THEN 'CREDITO E DEBITO COM VALORES E CLASSES DE VALOR IGUAIS'" + CRLF
	ZP002 += "				ELSE '' END)" + CRLF
	ZP002 += "		ELSE" + CRLF
	ZP002 += "			''" + CRLF
	ZP002 += "		END) MOTIVO" + CRLF
	ZP002 += "FROM " + RetSqlName("CT2") + " CT2 WITH(NOLOCK)" + CRLF
	ZP002 += "WHERE CT2.CT2_FILIAL = '" + xFilial("CT2") + "'" + CRLF
	ZP002 += "	AND CT2.CT2_DATA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'" + CRLF
	ZP002 += "	AND CT2.CT2_DC IN ('1','2','3')" + CRLF
	ZP002 += "	AND ((CT2.CT2_DC = 1 AND (CT2.CT2_DEBITO = '' OR CT2.CT2_CREDIT <> ''))" + CRLF
	ZP002 += "		OR (CT2.CT2_DC = 2 AND (CT2.CT2_DEBITO <> '' OR CT2.CT2_CREDIT = ''))" + CRLF
	ZP002 += "		OR (CT2.CT2_DC = 3 AND ((CT2.CT2_DEBITO = '' OR CT2.CT2_CREDIT = '') OR (CT2.CT2_DEBITO + CT2.CT2_CLVLDB = CT2.CT2_CREDIT + CT2.CT2_CLVLCR))))" + CRLF
	ZP002 += "	AND CT2.D_E_L_E_T_ = ' '" + CRLF
	
	ZPcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP002),'ZP02',.F.,.T.)
	dbSelectArea("ZP02")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento02")

		oExcel:AddRow(nxPlan, nxTabl, { ZP02->FIL, ZP02->DT, ZP02->TP_LANC, ZP02->LOTE, ZP02->SBLOTE, ZP02->DOC, ZP02->LINHA, ZP02->DEB, ZP02->CRE, ZP02->CLVDB, ZP02->CLVCR, ZP02->VLR, ZP02->HIST, ZP02->MOTIVO })

		dbSelectArea("ZP02")
		dbSkip()

	End
	ZP02->(dbCloseArea())
	Ferase(ZPcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ZPcIndex+OrdBagExt())          //indice gerado

	//                                                                      Planilha 03
	//=================================================================================
	nxPlan := "Planilha 03"
	nxTabl := "Movimentos não contabilizados"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "TAB",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "FILIAL",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "SERIE",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLIFOR",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "LOJA",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "COD",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "ITEM",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TES",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DATMOV",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "GRUPO",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CONTA",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "QUANT",3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "CUSTO",3,2)
	oExcel:AddColumn(nxPlan, nxTabl, "ALMOX",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CF",1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CLVL",1,1)
	
	ZP003 := "WITH MOVIM AS (SELECT 'SD1' TAB" + CRLF
	ZP003 += "			, SD1.D1_FILIAL FILIAL" + CRLF
	ZP003 += "			, SD1.D1_DOC DOC" + CRLF
	ZP003 += "			, SD1.D1_SERIE SERIE" + CRLF
	ZP003 += "			, SD1.D1_FORNECE CLIFOR" + CRLF
	ZP003 += "			, SD1.D1_LOJA LOJA" + CRLF
	ZP003 += "			, SD1.D1_COD COD" + CRLF
	ZP003 += "			, SD1.D1_ITEM ITEM" + CRLF
	ZP003 += "			, SD1.D1_TES TES" + CRLF
	ZP003 += "			, SD1.D1_DTDIGIT DATMOV" + CRLF
	ZP003 += "			, SD1.D1_GRUPO GRUPO" + CRLF
	ZP003 += "			, SD1.D1_CONTA CONTA" + CRLF
	ZP003 += "			, SD1.D1_QUANT QUANT" + CRLF
	ZP003 += "			, SD1.D1_CUSTO CUSTO" + CRLF
	ZP003 += "			, SD1.D1_LOCAL ALMOX" + CRLF
	ZP003 += "			, SD1.D1_CF CF" + CRLF
	ZP003 += "			, SD1.D1_CLVL CLVL" + CRLF
	ZP003 += "			, SD1.R_E_C_N_O_ RECNO" + CRLF
	ZP003 += "		FROM " + RetSqlName("SD1") + " SD1 WITH(NOLOCK)" + CRLF
	ZP003 += "			INNER JOIN " + RetSqlName("SF4") + " SF4 WITH(NOLOCK) ON SD1.D1_FILIAL = SF4.F4_FILIAL" + CRLF
	ZP003 += "				AND SD1.D1_TES = SF4.F4_CODIGO" + CRLF
	ZP003 += "				AND SF4.F4_ESTOQUE = 'S'" + CRLF
	ZP003 += "				AND SF4.D_E_L_E_T_ = ' '" + CRLF
	ZP003 += "		WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "'" + CRLF
	ZP003 += "			AND SD1.D1_DTDIGIT BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'" + CRLF
	ZP003 += "			AND SD1.D_E_L_E_T_ = ' '" + CRLF
	ZP003 += "	UNION ALL" + CRLF
	ZP003 += "		SELECT 'SD2' TAB" + CRLF
	ZP003 += "			, SD2.D2_FILIAL FILIAL" + CRLF
	ZP003 += "			, SD2.D2_DOC DOC" + CRLF
	ZP003 += "			, SD2.D2_SERIE SERIE" + CRLF
	ZP003 += "			, SD2.D2_CLIENTE CLIFOR" + CRLF
	ZP003 += "			, SD2.D2_LOJA LOJA" + CRLF
	ZP003 += "			, SD2.D2_COD COD" + CRLF
	ZP003 += "			, SD2.D2_ITEM ITEM" + CRLF
	ZP003 += "			, SD2.D2_TES TES" + CRLF
	ZP003 += "			, SD2.D2_DTDIGIT DATMOV" + CRLF
	ZP003 += "			, SD2.D2_GRUPO GRUPO" + CRLF
	ZP003 += "			, SD2.D2_CONTA CONTA" + CRLF
	ZP003 += "			, SD2.D2_QUANT QUANT" + CRLF
	ZP003 += "			, SD2.D2_CUSTO1 CUSTO" + CRLF
	ZP003 += "			, SD2.D2_LOCAL ALMOX" + CRLF
	ZP003 += "			, SD2.D2_CF CF" + CRLF
	ZP003 += "			, SD2.D2_CLVL CLVL" + CRLF
	ZP003 += "			, SD2.R_E_C_N_O_ RECNO" + CRLF
	ZP003 += "		FROM " + RetSqlName("SD2") + " SD2 WITH(NOLOCK)" + CRLF
	ZP003 += "			INNER JOIN " + RetSqlName("SF4") + " SF4 WITH(NOLOCK) ON SD2.D2_FILIAL = SF4.F4_FILIAL" + CRLF
	ZP003 += "				AND SD2.D2_TES = SF4.F4_CODIGO" + CRLF
	ZP003 += "				AND SF4.F4_ESTOQUE = 'S'" + CRLF
	ZP003 += "				AND SF4.D_E_L_E_T_ = ' '" + CRLF
	ZP003 += "		WHERE SD2.D2_FILIAL = '" + xFilial("SD2") + "'" + CRLF
	ZP003 += "			AND SD2.D2_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'" + CRLF
	ZP003 += "			AND SD2.D_E_L_E_T_ = ' '" + CRLF
	ZP003 += "	UNION ALL" + CRLF
	ZP003 += "		SELECT 'SD3' TAB" + CRLF
	ZP003 += "			, SD3.D3_FILIAL FILIAL" + CRLF
	ZP003 += "			, SD3.D3_DOC DOC" + CRLF
	ZP003 += "			, SD3.D3_YSERIE SERIE" + CRLF
	ZP003 += "			, '' CLIFOR" + CRLF
	ZP003 += "			, '' LOJA" + CRLF
	ZP003 += "			, SD3.D3_COD COD" + CRLF
	ZP003 += "			, SD3.D3_ITEM ITEM" + CRLF
	ZP003 += "			, SD3.D3_TM TES" + CRLF
	ZP003 += "			, SD3.D3_EMISSAO DATMOV" + CRLF
	ZP003 += "			, SD3.D3_GRUPO GRUPO" + CRLF
	ZP003 += "			, SD3.D3_CONTA CONTA" + CRLF
	ZP003 += "			, SD3.D3_QUANT QUANT" + CRLF
	ZP003 += "			, SD3.D3_CUSTO1 CUSTO" + CRLF
	ZP003 += "			, SD3.D3_LOCAL ALMOX" + CRLF
	ZP003 += "			, SD3.D3_CF CF" + CRLF
	ZP003 += "			, SD3.D3_CLVL CLVL" + CRLF
	ZP003 += "			, SD3.R_E_C_N_O_ RECNO" + CRLF
	ZP003 += "		FROM " + RetSqlName("SD3") + " SD3 WITH(NOLOCK)" + CRLF
	ZP003 += "		WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'" + CRLF
	ZP003 += "			AND SD3.D3_EMISSAO BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'" + CRLF
	ZP003 += "			AND SD3.D3_CF NOT IN ('DE3','RE3','DE7','RE7','PR0')" + CRLF
	ZP003 += "			AND SD3.D3_TIPO NOT IN ('MO','PA','PP')" + CRLF
	ZP003 += "			AND SD3.D3_TM NOT IN ('352')" + CRLF
	ZP003 += "			AND (CASE WHEN SD3.D3_OP = '' AND SD3.D3_CF IN ('DE4','RE4') THEN 0 ELSE 1 END) = 1" + CRLF
	ZP003 += "			AND SD3.D3_CUSTO1 <> 0" + CRLF
	ZP003 += "			AND SD3.D_E_L_E_T_ = ' '" + CRLF
	ZP003 += "	)" + CRLF
	ZP003 += "" + CRLF
	ZP003 += "" + CRLF
	ZP003 += "	SELECT MOVIM.TAB" + CRLF
	ZP003 += "		, MOVIM.FILIAL" + CRLF
	ZP003 += "		, MOVIM.DOC" + CRLF
	ZP003 += "		, MOVIM.SERIE" + CRLF
	ZP003 += "		, MOVIM.CLIFOR" + CRLF
	ZP003 += "		, MOVIM.LOJA" + CRLF
	ZP003 += "		, MOVIM.COD" + CRLF
	ZP003 += "		, MOVIM.ITEM" + CRLF
	ZP003 += "		, MOVIM.TES" + CRLF
	ZP003 += "		, MOVIM.DATMOV" + CRLF
	ZP003 += "		, MOVIM.GRUPO" + CRLF
	ZP003 += "		, MOVIM.CONTA" + CRLF
	ZP003 += "		, MOVIM.QUANT" + CRLF
	ZP003 += "		, MOVIM.CUSTO" + CRLF
	ZP003 += "		, MOVIM.ALMOX" + CRLF
	ZP003 += "		, MOVIM.CF" + CRLF
	ZP003 += "		, MOVIM.CLVL" + CRLF
	ZP003 += "	FROM MOVIM" + CRLF
	ZP003 += "		LEFT JOIN " + RetSqlName("CT2") + " CT2 WITH(NOLOCK) ON MOVIM.FILIAL = CT2.CT2_FILIAL" + CRLF
	ZP003 += "			AND CT2.CT2_DATA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'" + CRLF
	ZP003 += "			AND MOVIM.FILIAL + MOVIM.DOC + MOVIM.SERIE + MOVIM.CLIFOR + MOVIM.LOJA = SUBSTRING(CT2.CT2_KEY,1,22)" + CRLF //NÃO FOI CONSIDERADO CÓDIGO E ITEM PELOS CASOS ONDE HÁ AGRUPAMENTO DA CONTABILIZAÇÃO
	ZP003 += "			AND CT2.D_E_L_E_T_ = ''" + CRLF
	ZP003 += "	WHERE MOVIM.TAB = 'SD1'" + CRLF
	ZP003 += "		AND CT2.CT2_KEY IS NULL" + CRLF
	ZP003 += "		AND CT2.CT2_FILIAL IS NULL" + CRLF
	ZP003 += "" + CRLF
	ZP003 += "UNION ALL" + CRLF
	ZP003 += "" + CRLF
	ZP003 += "	SELECT MOVIM.TAB" + CRLF
	ZP003 += "		, MOVIM.FILIAL" + CRLF
	ZP003 += "		, MOVIM.DOC" + CRLF
	ZP003 += "		, MOVIM.SERIE" + CRLF
	ZP003 += "		, MOVIM.CLIFOR" + CRLF
	ZP003 += "		, MOVIM.LOJA" + CRLF
	ZP003 += "		, MOVIM.COD" + CRLF
	ZP003 += "		, MOVIM.ITEM" + CRLF
	ZP003 += "		, MOVIM.TES" + CRLF
	ZP003 += "		, MOVIM.DATMOV" + CRLF
	ZP003 += "		, MOVIM.GRUPO" + CRLF
	ZP003 += "		, MOVIM.CONTA" + CRLF
	ZP003 += "		, MOVIM.QUANT" + CRLF
	ZP003 += "		, MOVIM.CUSTO" + CRLF
	ZP003 += "		, MOVIM.ALMOX" + CRLF
	ZP003 += "		, MOVIM.CF" + CRLF
	ZP003 += "		, MOVIM.CLVL" + CRLF
	ZP003 += "	FROM MOVIM" + CRLF
	ZP003 += "		LEFT JOIN " + RetSqlName("CT2") + " CT2 WITH(NOLOCK) ON MOVIM.FILIAL = CT2.CT2_FILIAL" + CRLF
	ZP003 += "			AND CT2.CT2_DATA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'" + CRLF
	ZP003 += "			AND MOVIM.FILIAL + MOVIM.DOC + MOVIM.SERIE + MOVIM.CLIFOR + MOVIM.LOJA = SUBSTRING(CT2.CT2_KEY,1,22)" + CRLF //NÃO FOI CONSIDERADO CÓDIGO E ITEM PELOS CASOS ONDE HÁ AGRUPAMENTO DA CONTABILIZAÇÃO
	ZP003 += "			AND CT2.D_E_L_E_T_ = ''" + CRLF
	ZP003 += "	WHERE MOVIM.TAB = 'SD2'" + CRLF
	ZP003 += "		AND MOVIM.GRUPO <> 'PA'" + CRLF
	ZP003 += "		AND CT2.CT2_KEY IS NULL" + CRLF
	ZP003 += "		AND CT2.CT2_FILIAL IS NULL" + CRLF
	ZP003 += "" + CRLF
	ZP003 += "UNION ALL" + CRLF
	ZP003 += "" + CRLF
	ZP003 += "	SELECT MOVIM.TAB" + CRLF
	ZP003 += "		, MOVIM.FILIAL" + CRLF
	ZP003 += "		, MOVIM.DOC" + CRLF
	ZP003 += "		, MOVIM.SERIE" + CRLF
	ZP003 += "		, MOVIM.CLIFOR" + CRLF
	ZP003 += "		, MOVIM.LOJA" + CRLF
	ZP003 += "		, MOVIM.COD" + CRLF
	ZP003 += "		, MOVIM.ITEM" + CRLF
	ZP003 += "		, MOVIM.TES" + CRLF
	ZP003 += "		, MOVIM.DATMOV" + CRLF
	ZP003 += "		, MOVIM.GRUPO" + CRLF
	ZP003 += "		, MOVIM.CONTA" + CRLF
	ZP003 += "		, MOVIM.QUANT" + CRLF
	ZP003 += "		, MOVIM.CUSTO" + CRLF
	ZP003 += "		, MOVIM.ALMOX" + CRLF
	ZP003 += "		, MOVIM.CF" + CRLF
	ZP003 += "		, MOVIM.CLVL" + CRLF
	ZP003 += "	FROM MOVIM" + CRLF
	ZP003 += "		LEFT JOIN " + RetSqlName("CT2") + " CT2 WITH(NOLOCK) ON MOVIM.FILIAL = CT2.CT2_FILIAL" + CRLF
	ZP003 += "			AND CT2.CT2_DATA BETWEEN '" + dtos(MV_PAR01) + "' AND '" + dtos(MV_PAR02) + "'" + CRLF
	ZP003 += "			AND LTRIM(RTRIM(MOVIM.RECNO)) = LTRIM(RTRIM(REVERSE(SUBSTRING(LTRIM(RTRIM(REVERSE(CT2.CT2_ORIGEM))),1,CHARINDEX(' ',LTRIM(RTRIM(REVERSE(CT2.CT2_ORIGEM))))))))" + CRLF
	ZP003 += "			AND CT2.D_E_L_E_T_ = ''" + CRLF
	ZP003 += "	WHERE MOVIM.TAB = 'SD3'" + CRLF
	ZP003 += "		AND CT2.CT2_ORIGEM IS NULL" + CRLF
	ZP003 += "		AND CT2.CT2_FILIAL IS NULL" + CRLF
	ZP003 += "ORDER BY TAB, FILIAL, DATMOV, DOC, SERIE, CLIFOR, LOJA, ITEM" + CRLF
	
	ZPcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,ZP003),'ZP03',.F.,.T.)
	dbSelectArea("ZP03")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento03")

		oExcel:AddRow(nxPlan, nxTabl, { ZP03->TAB, ZP03->FILIAL, ZP03->DOC, ZP03->SERIE, ZP03->CLIFOR, ZP03->LOJA, ZP03->COD, ZP03->ITEM, ZP03->TES, ZP03->DATMOV, ZP03->GRUPO, ZP03->CONTA, ZP03->QUANT, ZP03->CUSTO, ZP03->ALMOX, ZP03->CF, ZP03->CLVL })

		dbSelectArea("ZP03")
		dbSkip()

	End
	ZP03->(dbCloseArea())
	Ferase(ZPcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(ZPcIndex+OrdBagExt())          //indice gerado

	// -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	// -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

	xArqTemp := "verificacaoposrcm - "+cEmpAnt+" - "+dtos(MV_PAR01)+" - "+dtos(MV_PAR02)

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

	oLogProc:LogFimProc()

Return

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