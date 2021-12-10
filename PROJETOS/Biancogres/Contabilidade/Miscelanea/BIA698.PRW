#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA698
@author Marcos Alberto Soprani
@since 08/07/21
@version 1.0
@description Kardex Ajustado para RAC
@type function
@Obs Projeto A-62 - Custeio Jazidas. poderá ser aproveitado pelo Biancogres para efeito de C1
/*/

User Function BIA698()

	Local aArea := ZN9->(GetArea())
	Private oBrowse
	Private cChaveAux := ""
	Private cCadastro := "Kardex Ajustado para RAC"
	Private msEnter   := CHR(13) + CHR(10)

	aRotina   := { {"Pesquisar"       ,"AxPesqui"                          ,0,1},;
	{               "Visualizar"      ,"AxVisual"                          ,0,2},;
	{               "Incluir"         ,"AxInclui"                          ,0,3},;
	{               "Alterar"         ,"AxAltera"                          ,0,4},;
	{               "Excluir"         ,"AxDeleta"                          ,0,5},;
	{               "Processar"       ,'ExecBlock("BIA698P",.F.,.F.)'      ,0,3} }

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("ZN9")

	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cCadastro)

	//Adiciona um filtro ao browse
	//oBrowse:SetFilterDefault( "" )

	//Ativamos a classe
	oBrowse:Activate()
	RestArea(aArea)

Return

User Function BIA698P()

	Processa({|| RptPDet()})

Return

Static Function RptPDet()

	Local msErroQuery := ""
	Local msStaExcQy  := 0

	xdAnoMes := space(006)
	If !fPergHotB()
		MsgSTOP("Processo Abortado!!!")
		Return
	EndIf

	kfDataAnt := stod(MV_PAR01 + "01") - 1
	kfDataDe  := stod(MV_PAR01 + "01")
	kfDataAte := Ultimodia(kfDataDe)

	If !U_BiaULRAC(kfDataDe)
		Return
	EndIf

	//                               Zera Valores para que não ocorra erros em caso se reprocessamento
	**************************************************************************************************
	ZP003 := " DELETE ZN9 "
	ZP003 += "   FROM " + RetSqlName("ZN9") + " ZN9 (NOLOCK) "
	ZP003 += "  WHERE ZN9_FILIAL = '" + xFilial("ZN9") + "' "
	ZP003 += "    AND ZN9_DTREF = '" + dtos(kfDataAte) + "' "
	ZP003 += "    AND ZN9.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Zerando valores...",,{|| TCSQLExec(ZP003)})

	//                               Zera Valores para que não ocorra erros em caso se reprocessamento
	**************************************************************************************************
	ZP004 := " DELETE ZN8 "
	ZP004 += "   FROM " + RetSqlName("ZN8") + " ZN8 (NOLOCK) "
	ZP004 += "  WHERE ZN8_FILIAL = '" + xFilial("ZN8") + "' "
	ZP004 += "    AND ZN8_DTREF = '" + dtos(kfDataAte) + "' "
	ZP004 += "    AND ZN8_KARDEX = 'S' "
	ZP004 += "    AND ZN8.D_E_L_E_T_ = ' ' "
	U_BIAMsgRun("Aguarde... Zerando valores...",,{|| TCSQLExec(ZP004)})

	//                                                            Apanha produto que serão processados
	**************************************************************************************************
	GR003 := Alltrim(" WITH PRODREF                                                                                                                                    ") + msEnter
	GR003 += Alltrim("      AS (SELECT PRODUTO = ZN9_PRODUT                                                                                                            ") + msEnter
	GR003 += Alltrim("          FROM " + RetSqlName("ZN9") + " ZN9(NOLOCK)                                                                                             ") + msEnter
	GR003 += Alltrim("          WHERE ZN9_FILIAL = '" + xFilial("ZN9") + "'                                                                                            ") + msEnter
	GR003 += Alltrim("                AND ZN9_DTREF = '" + dtos(kfDataAnt) + "'                                                                                        ") + msEnter
	GR003 += Alltrim("                AND ZN9.D_E_L_E_T_ = ' '                                                                                                         ") + msEnter
	GR003 += Alltrim("          GROUP BY ZN9_PRODUT                                                                                                                    ") + msEnter
	GR003 += Alltrim("          UNION                                                                                                                                  ") + msEnter
	GR003 += Alltrim("          SELECT ZN8_PRODUT                                                                                                                      ") + msEnter
	GR003 += Alltrim("          FROM " + RetSqlName("ZN8") + " ZN8(NOLOCK)                                                                                             ") + msEnter
	GR003 += Alltrim("          WHERE ZN8_FILIAL = '" + xFilial("ZN8") + "'                                                                                            ") + msEnter
	GR003 += Alltrim("                AND ZN8_DTREF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                     ") + msEnter
	GR003 += Alltrim("                AND ZN8.D_E_L_E_T_ = ' '                                                                                                         ") + msEnter
	GR003 += Alltrim("          GROUP BY ZN8_PRODUT)                                                                                                                   ") + msEnter
	GR003 += Alltrim("      SELECT '" + dtos(kfDataAte) + "' DATREF,                                                                                                   ") + msEnter
	GR003 += Alltrim("             PRODUTO,                                                                                                                            ") + msEnter
	GR003 += Alltrim("             TPPROD = B1_TIPO                                                                                                                    ") + msEnter
	GR003 += Alltrim("      FROM PRODREF                                                                                                                               ") + msEnter
	GR003 += Alltrim("           INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "'                                              ") + msEnter
	GR003 += Alltrim("                                            AND B1_COD = PRODUTO                                                                                 ") + msEnter
	GR003 += Alltrim("                                            AND SB1.D_E_L_E_T_ = ' '                                                                             ") + msEnter
	G3Index := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,GR003),'GR03',.T.,.T.)
	dbSelectArea("GR03")
	dbGoTop()
	ProcRegua(0)
	cvChq   := 0
	While GR03->(!Eof())

		tdProdt  := GR03->PRODUTO
		tdTpProd := GR03->TPPROD + "  "

		cvChq  ++
		IncProc("Tipo: " + tdTpProd + " Prod.: " + Alltrim(tdProdt) + " " + Alltrim(Str(cvChq)))

		//                                                              Saldo anterior do produto corrente 
		**************************************************************************************************
		BN007 := Alltrim(" SELECT PRODUTO = ZN9_PRODUT,                                                                                                                    ") + msEnter
		BN007 += Alltrim("        QTDSLD = ZN9_QTSLD,                                                                                                                      ") + msEnter
		BN007 += Alltrim("        VLRSLD = ZN9_VLSLD                                                                                                                        ") + msEnter
		BN007 += Alltrim(" FROM " + RetSqlName("ZN9") + " ZN9(NOLOCK)                                                                                                      ") + msEnter
		BN007 += Alltrim(" WHERE ZN9_FILIAL = '" + xFilial("ZN9") + "'                                                                                                     ") + msEnter
		BN007 += Alltrim("       AND ZN9_DTREF = '" + dtos(kfDataAnt) + "'                                                                                                 ") + msEnter
		BN007 += Alltrim("       AND ZN9_PRODUT = '" + tdProdt + "'                                                                                                        ") + msEnter
		BN007 += Alltrim("       AND ZN9.D_E_L_E_T_ = ' '                                                                                                                  ") + msEnter
		BNIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,BN007),'BN07',.T.,.T.)
		dbSelectArea("BN07")
		dbGoTop()
		If BN07->(!Eof())

			dbSelectArea("ZN9")
			dbSetOrder(1)
			If !dbSeek(xFilial("ZN9") + dtos(kfDataAte) + BN07->PRODUTO)
				Reclock("ZN9",.T.)
				ZN9->ZN9_FILIAL := xFilial("ZN8")
				ZN9->ZN9_DTREF  := kfDataAte
				ZN9->ZN9_PRODUT := BN07->PRODUTO
			Else
				Reclock("ZN9",.F.)
			EndIf
			ZN9->ZN9_QTINI += BN07->QTDSLD
			ZN9->ZN9_VLINI += BN07->VLRSLD
			ZN9->(MsUnlock())

		EndIf
		BN07->(dbCloseArea())
		Ferase(BNIndex+GetDBExtension())
		Ferase(BNIndex+OrdBagExt())

		SB1->( dbSetOrder(1) )
		SB1->( dbSeek(xFilial("SB1") + tdProdt) )
		msTipo  := SB1->B1_TIPO
		msGrupo := SB1->B1_GRUPO

		//   Registra Saída no Kardex para o Componente e Valoria o Custo Ajustado para o produto corrente
		**************************************************************************************************
		RF005 := Alltrim(" WITH COMPONENTE                                                                                                                                 ") + msEnter
		RF005 += Alltrim("      AS (SELECT COMP = G1_COMP,                                                                                                                 ") + msEnter
		RF005 += Alltrim("                 ITCUS = CASE                                                                                                                    ") + msEnter
		RF005 += Alltrim("                             WHEN SUBSTRING(G1_COMP, 4, 2) = '00'                                                                                ") + msEnter
		RF005 += Alltrim("                             THEN '003'                                                                                                          ") + msEnter
		RF005 += Alltrim("                             WHEN SUBSTRING(G1_COMP, 4, 2) = '50'                                                                                ") + msEnter
		RF005 += Alltrim("                             THEN '006'                                                                                                          ") + msEnter
		RF005 += Alltrim("                             WHEN SUBSTRING(G1_COMP, 4, 2) = '80'                                                                                ") + msEnter
		RF005 += Alltrim("                             THEN '007'                                                                                                          ") + msEnter
		RF005 += Alltrim("                         END,                                                                                                                    ") + msEnter
		RF005 += Alltrim("                 QTDESTR = G1_QUANT                                                                                                              ") + msEnter
		RF005 += Alltrim("          FROM " + RetSqlName("SG1") + " SG1(NOLOCK)                                                                                             ") + msEnter
		RF005 += Alltrim("          WHERE G1_FILIAL = '" + xFilial("SG1") + "'                                                                                             ") + msEnter
		RF005 += Alltrim("                AND G1_COD = '" + tdProdt + "'                                                                                                   ") + msEnter
		RF005 += Alltrim("                AND SUBSTRING(G1_COMP, 1, 3) = '108'                                                                                             ") + msEnter
		RF005 += Alltrim("                AND SG1.D_E_L_E_T_ = ' '),                                                                                                       ") + msEnter
		RF005 += Alltrim("      UMIDADE                                                                                                                                    ") + msEnter
		RF005 += Alltrim("      AS (SELECT UMID = ISNULL((100 - SUM(Z02_UMIDAD) / SUM(Z02_QTDCRG)) / 100, 1)                                                               ") + msEnter
		RF005 += Alltrim("          FROM " + RetSqlName("Z02") + " Z02(NOLOCK)                                                                                             ") + msEnter
		RF005 += Alltrim("               INNER JOIN COMPONENTE CMP ON CMP.COMP = Z02_PRODUT                                                                                ") + msEnter
		RF005 += Alltrim("          WHERE Z02_FILIAL = '" + xFilial("Z02") + "'                                                                                            ") + msEnter
		If msTipo == "PA"
			RF005 += Alltrim("                AND 1 = 2                                                                                                                        ") + msEnter
		EndIf
		RF005 += Alltrim("                AND SUBSTRING(Z02_DATREF, 1, 6) IN                                                                                               ") + msEnter
		RF005 += Alltrim("          (                                                                                                                                      ") + msEnter
		RF005 += Alltrim("              SELECT SUBSTRING(MAX(Z02_DATREF), 1, 6)                                                                                            ") + msEnter
		RF005 += Alltrim("              FROM " + RetSqlName("Z02") + " Z02(NOLOCK)                                                                                         ") + msEnter
		RF005 += Alltrim("                   INNER JOIN COMPONENTE CMP ON CMP.COMP = Z02_PRODUT                                                                            ") + msEnter
		RF005 += Alltrim("              WHERE Z02_FILIAL = '" + xFilial("Z02") + "'                                                                                        ") + msEnter
		RF005 += Alltrim("                    AND Z02_DATREF <= '" + dtos(kfDataAte) + "'                                                                                  ") + msEnter
		RF005 += Alltrim("                    AND D_E_L_E_T_ = ' '                                                                                                         ") + msEnter
		RF005 += Alltrim("          )                                                                                                                                      ") + msEnter
		RF005 += Alltrim("              AND D_E_L_E_T_ = ' '),                                                                                                             ") + msEnter
		RF005 += Alltrim("      QTDPROD                                                                                                                                    ") + msEnter
		RF005 += Alltrim("      AS (SELECT PRODUTO = ZN8_PRODUT,                                                                                                           ") + msEnter
		RF005 += Alltrim("                 QTDENT = ZN8_CUS223                                                                                                             ") + msEnter
		RF005 += Alltrim("          FROM " + RetSqlName("ZN8") + " ZN8(NOLOCK)                                                                                             ") + msEnter
		RF005 += Alltrim("          WHERE ZN8_FILIAL = '" + xFilial("ZN8") + "'                                                                                            ") + msEnter
		RF005 += Alltrim("                AND ZN8_DTREF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                     ") + msEnter
		RF005 += Alltrim("                AND ZN8_PRODUT = '" + tdProdt + "'                                                                                               ") + msEnter
		RF005 += Alltrim("                AND ZN8.D_E_L_E_T_ = ' '                                                                                                         ") + msEnter
		RF005 += Alltrim("          GROUP BY ZN8_PRODUT,                                                                                                                   ") + msEnter
		RF005 += Alltrim("                   ZN8_CUS223),                                                                                                                  ") + msEnter
		RF005 += Alltrim("      CSTMED                                                                                                                                     ") + msEnter
		RF005 += Alltrim("      AS (SELECT PRODUTO = ZN8_PRODUT,                                                                                                           ") + msEnter
		RF005 += Alltrim("                 ITCUS,                                                                                                                          ") + msEnter
		RF005 += Alltrim("                 QTD = ZN8_CUS223,                                                                                                               ") + msEnter
		RF005 += Alltrim("                 VLR = SUM(ZN8_CUS224)                                                                                                           ") + msEnter
		RF005 += Alltrim("          FROM " + RetSqlName("ZN8") + " ZN8(NOLOCK)                                                                                             ") + msEnter
		RF005 += Alltrim("               INNER JOIN COMPONENTE CMP ON CMP.COMP = ZN8_PRODUT                                                                                ") + msEnter
		RF005 += Alltrim("          WHERE ZN8_FILIAL = '" + xFilial("ZN8") + "'                                                                                            ") + msEnter
		RF005 += Alltrim("                AND ZN8_DTREF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                     ") + msEnter
		RF005 += Alltrim("                AND ZN8.D_E_L_E_T_ = ' '                                                                                                         ") + msEnter
		RF005 += Alltrim("          GROUP BY ZN8_PRODUT,                                                                                                                   ") + msEnter
		RF005 += Alltrim("                   ITCUS,                                                                                                                        ") + msEnter
		RF005 += Alltrim("                   ZN8_CUS223                                                                                                                    ") + msEnter
		RF005 += Alltrim("          UNION ALL                                                                                                                              ") + msEnter
		RF005 += Alltrim("          SELECT PRODUTO = ZN9_PRODUT,                                                                                                           ") + msEnter
		RF005 += Alltrim("                 ITCUS,                                                                                                                          ") + msEnter
		RF005 += Alltrim("                 QTD = ZN9_QTSLD,                                                                                                                ") + msEnter
		RF005 += Alltrim("                 VLR = ZN9_VLSLD                                                                                                                 ") + msEnter
		RF005 += Alltrim("          FROM " + RetSqlName("ZN9") + " ZN9(NOLOCK)                                                                                             ") + msEnter
		RF005 += Alltrim("               INNER JOIN COMPONENTE CMP ON CMP.COMP = ZN9_PRODUT                                                                                ") + msEnter
		RF005 += Alltrim("          WHERE ZN9_FILIAL = '" + xFilial("ZN9") + "'                                                                                            ") + msEnter
		RF005 += Alltrim("                AND ZN9_DTREF = '" + dtos(kfDataAnt) + "'                                                                                        ") + msEnter
		RF005 += Alltrim("                AND ZN9.D_E_L_E_T_ = ' '),                                                                                                       ") + msEnter
		RF005 += Alltrim("      CUSTOTOT                                                                                                                                   ") + msEnter
		RF005 += Alltrim("      AS (SELECT PRODUTO,                                                                                                                        ") + msEnter
		RF005 += Alltrim("                 ITCUS,                                                                                                                          ") + msEnter
		RF005 += Alltrim("                 QTD = ISNULL(SUM(QTD), 0),                                                                                                      ") + msEnter
		RF005 += Alltrim("                 VLR = ISNULL(SUM(VLR), 0)                                                                                                       ") + msEnter
		RF005 += Alltrim("          FROM CSTMED MED                                                                                                                        ") + msEnter
		RF005 += Alltrim("          GROUP BY PRODUTO,                                                                                                                      ") + msEnter
		RF005 += Alltrim("                   ITCUS)                                                                                                                        ") + msEnter
		RF005 += Alltrim("      SELECT CTD.PRODUTO,                                                                                                                        ") + msEnter
		RF005 += Alltrim("             TPPROD = SB1.B1_TIPO,                                                                                                               ") + msEnter
		RF005 += Alltrim("             CTD.ITCUS,                                                                                                                          ") + msEnter
		RF005 += Alltrim("             QTDENT = (ISNULL(QPD.QTDENT, 0) / UMD.UMID),                                                                                        ") + msEnter
		RF005 += Alltrim("             MEDIO = CASE                                                                                                                        ") + msEnter
		RF005 += Alltrim("                         WHEN CTD.QTD <> 0                                                                                                       ") + msEnter
		RF005 += Alltrim("                         THEN CTD.VLR / CTD.QTD                                                                                                  ") + msEnter
		RF005 += Alltrim("                         ELSE 0                                                                                                                  ") + msEnter
		RF005 += Alltrim("                     END,                                                                                                                        ") + msEnter
		RF005 += Alltrim("             TOTAL = (ISNULL(QPD.QTDENT, 0) / UMD.UMID) * (CASE                                                                                  ") + msEnter
		RF005 += Alltrim("                                                    WHEN CTD.QTD <> 0                                                                            ") + msEnter
		RF005 += Alltrim("                                                    THEN CTD.VLR / CTD.QTD                                                                       ") + msEnter
		RF005 += Alltrim("                                                    ELSE 0                                                                                       ") + msEnter
		RF005 += Alltrim("                                                END)                                                                                             ") + msEnter
		RF005 += Alltrim("      FROM CUSTOTOT CTD                                                                                                                          ") + msEnter
		RF005 += Alltrim("           INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "'                                              ") + msEnter
		RF005 += Alltrim("                                            AND B1_COD = PRODUTO                                                                                 ") + msEnter
		RF005 += Alltrim("                                            AND SB1.D_E_L_E_T_ = ' '                                                                             ") + msEnter
		RF005 += Alltrim("           LEFT JOIN QTDPROD QPD ON 1 = 1                                                                                                        ") + msEnter
		RF005 += Alltrim("           LEFT JOIN UMIDADE UMD ON 1 = 1                                                                                                        ") + msEnter
		RFIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,RF005),'RF05',.T.,.T.)
		dbSelectArea("RF05")
		dbGoTop()
		If RF05->(!Eof())

			// Saída no Kardex para o Componente...
			dbSelectArea("ZN9")
			dbSetOrder(1)
			If !dbSeek(xFilial("ZN9") + dtos(kfDataAte) + RF05->PRODUTO)
				Reclock("ZN9",.T.)
				ZN9->ZN9_FILIAL := xFilial("ZN8")
				ZN9->ZN9_DTREF  := kfDataAte
				ZN9->ZN9_PRODUT := RF05->PRODUTO
			Else
				Reclock("ZN9",.F.)
			EndIf
			ZN9->ZN9_QTSAI += RF05->QTDENT
			ZN9->ZN9_VLSAI += RF05->TOTAL
			ZN9->(MsUnlock())

			//Valoria o Custo Ajustado do produto corrente...
			dbSelectArea("ZN8")
			dbSetOrder(2)
			If !dbSeek(xFilial("ZN8") + dtos(kfDataAte) + tdTpProd + tdProdt + RF05->ITCUS)
				Reclock("ZN8",.T.)
				ZN8->ZN8_FILIAL := xFilial("ZN8")
				ZN8->ZN8_DTREF  := kfDataAte
				ZN8->ZN8_TPPROD := tdTpProd
				ZN8->ZN8_PRODUT := tdProdt
				ZN8->ZN8_ITCUS  := RF05->ITCUS
				ZN8->ZN8_TPCUS  := 'CV'
				ZN8->ZN8_CUS200 := RF05->QTDENT
				ZN8->ZN8_CUS223 := RF05->QTDENT
			Else
				Reclock("ZN8",.F.)
			EndIf
			ZN8->ZN8_CUS224 += RF05->TOTAL
			ZN8->ZN8_KARDEX := "S"
			ZN8->(MsUnlock())

		EndIf
		RF05->(dbCloseArea())
		Ferase(RFIndex+GetDBExtension())
		Ferase(RFIndex+OrdBagExt())

		//                                              Registra Entrada no Kardex para o produto corrente
		**************************************************************************************************
		LZ009 := Alltrim(" SELECT PRODUTO = ZN8_PRODUT,                                                                                                                        ") + msEnter
		LZ009 += Alltrim("        QTDENT = ZN8_CUS223,                                                                                                                         ") + msEnter
		LZ009 += Alltrim("        VLRENT = SUM(ZN8_CUS224)                                                                                                                     ") + msEnter
		LZ009 += Alltrim(" FROM " + RetSqlName("ZN8") + " ZN8(NOLOCK)                                                                                                          ") + msEnter
		LZ009 += Alltrim(" WHERE ZN8_FILIAL = '" + xFilial("ZN8") + "'                                                                                                         ") + msEnter
		LZ009 += Alltrim("       AND ZN8_DTREF BETWEEN '" + dtos(kfDataDe) + "' AND '" + dtos(kfDataAte) + "'                                                                  ") + msEnter
		LZ009 += Alltrim("       AND ZN8_PRODUT = '" + tdProdt + "'                                                                                                            ") + msEnter
		LZ009 += Alltrim("       AND ZN8.D_E_L_E_T_ = ' '                                                                                                                      ") + msEnter
		LZ009 += Alltrim(" GROUP BY ZN8_PRODUT,                                                                                                                                ") + msEnter
		LZ009 += Alltrim("          ZN8_CUS223                                                                                                                                 ") + msEnter
		LZIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,LZ009),'LZ09',.T.,.T.)
		dbSelectArea("LZ09")
		dbGoTop()
		If LZ09->(!Eof())

			dbSelectArea("ZN9")
			dbSetOrder(1)
			If !dbSeek(xFilial("ZN9") + dtos(kfDataAte) + LZ09->PRODUTO)
				Reclock("ZN9",.T.)
				ZN9->ZN9_FILIAL := xFilial("ZN8")
				ZN9->ZN9_DTREF  := kfDataAte
				ZN9->ZN9_PRODUT := LZ09->PRODUTO
			Else
				Reclock("ZN9",.F.)
			EndIf
			ZN9->ZN9_QTENT += LZ09->QTDENT
			ZN9->ZN9_VLENT += LZ09->VLRENT
			ZN9->(MsUnlock())

		EndIf
		LZ09->(dbCloseArea())
		Ferase(LZIndex+GetDBExtension())
		Ferase(LZIndex+OrdBagExt())

		dbSelectArea("GR03")
		GR03->(dbSkip())

	End

	GR03->(dbCloseArea())
	Ferase(G3Index+GetDBExtension())
	Ferase(G3Index+OrdBagExt())

	//                                                   Processar Saída de PA do período para kardex
	**************************************************************************************************
	UK001 := Alltrim(" UPDATE ZN9 SET                                                                                                                         ") + msEnter
	UK001 += Alltrim("        ZN9_QTSAI = ZN9_QTENT,                                                                                              ") + msEnter
	UK001 += Alltrim("        ZN9_VLSAI = ZN9_VLENT                                                                                               ") + msEnter
	UK001 += Alltrim(" FROM " + RetSqlName("ZN9") + " ZN9(NOLOCK)                                                                                             ") + msEnter
	UK001 += Alltrim("      INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON B1_FILIAL = '" + xFilial("SB1") + "'                                          ") + msEnter
	UK001 += Alltrim("                                       AND B1_COD = ZN9_PRODUT                                                                          ") + msEnter
	UK001 += Alltrim("                                       AND B1_TIPO = 'PA'                                                                               ") + msEnter
	UK001 += Alltrim("                                       AND SB1.D_E_L_E_T_ = ' '                                                                         ") + msEnter
	UK001 += Alltrim(" WHERE ZN9_FILIAL = '" + xFilial("ZN9") + "'                                                                                            ") + msEnter
	UK001 += Alltrim("       AND ZN9_DTREF = '" + dtos(kfDataAte) + "'                                                                                        ") + msEnter
	UK001 += Alltrim("       AND ZN9.D_E_L_E_T_ = ' '                                                                                                         ") + msEnter
	U_BIAMsgRun("Aguarde... Atualizando Saída de PA do Kardex",,{|| TCSQLExec(UK001)})

	If msStaExcQy < 0

		msErroQuery := TCSQLError()
		Aviso('Erro na Query', "Erro na execução do processamento: " + msEnter + msEnter + msEnter + msErroQuery,{'Ok'},3) 

	Else

		//                                                          Processar saldo do período para kardex
		**************************************************************************************************
		UK002 := Alltrim(" UPDATE ZN9 SET                                                                                                                         ") + msEnter
		UK002 += Alltrim("        ZN9_QTSLD = ZN9_QTINI + ZN9_QTENT - ZN9_QTSAI,                                                                                  ") + msEnter
		UK002 += Alltrim("        ZN9_VLSLD = ZN9_VLINI + ZN9_VLENT - ZN9_VLSAI                                                                                   ") + msEnter
		UK002 += Alltrim(" FROM " + RetSqlName("ZN9") + " ZN9(NOLOCK)                                                                                             ") + msEnter
		UK002 += Alltrim(" WHERE ZN9_FILIAL = '" + xFilial("ZN9") + "'                                                                                            ") + msEnter
		UK002 += Alltrim("       AND ZN9_DTREF = '" + dtos(kfDataAte) + "'                                                                                        ") + msEnter
		UK002 += Alltrim("       AND ZN9.D_E_L_E_T_ = ' '                                                                                                         ") + msEnter
		U_BIAMsgRun("Aguarde... Atualizando Saldos do Kardex",,{|| TCSQLExec(UK002)})

		If msStaExcQy < 0

			msErroQuery := TCSQLError()
			Aviso('Erro na Query', "Erro na execução do processamento: " + msEnter + msEnter + msEnter + msErroQuery,{'Ok'},3) 

		Else

			Aviso('BIA698P','Fim do Processamento...',{'Ok'})

		EndIf

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ fPergHotB ¦ Autor ¦ Marcos Alberto S     ¦ Data ¦ 12/12/17 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function fPergHotB()

	Local bProcOk  := .T.
	Local aPergs 	:= {}
	Local cLoad	    := 'BIA503A' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	xdAnoMes        := space(006)

	aAdd( aPergs ,{1,"Ano/Mes:"                      ,xdAnoMes    ,"@!","NAOVAZIO()",,'.T.',015,.F.})	

	If ParamBox(aPergs ,"Parâmetros",,,,,,,,cLoad,.T.,.T.)      
		xdAnoMes    := ParamLoad(cFileName,,1,xdAnoMes)
	Else
		bProcOk := .F.
	Endif

Return ( bProcOk ) 
