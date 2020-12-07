#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFR014
@author Tiago Rossini Coradini
@since 02/05/2018
@version 1.0
@description Relatorio de Pedidos com Sugestão de Lote Recusada 
@obs Ticket: 3598
@type function
/*/

User Function BIAFR014()
Local oReport
Local oParam := TParBIAFR014():New()

	If oParam:Box()

		oReport := ReportDef(oParam)
		oReport:PrintDialog()
		
	EndIf
		
Return()


Static Function ReportDef(oParam)
Local oReport
Local oSecPedVen
Local cQry := GetNextAlias()    

	oReport := TReport():New("BIAFR014", "Pedidos com Sugestão de Lote Recusada", {|| oParam:Box() }, {|oReport| PrintReport(oReport, cQry, oParam)}, "Pedidos com Sugestão de Lote Recusada")
		
	oReport:SetDevice(4)
	
	// Altera tipo de impressao para paisagem
	oReport:SetLandScape(.T.)
	
	oSecPedVen := TRSection():New(oReport, "Pedidos", cQry)
	
	TRCell():New(oSecPedVen, "DES_MARCA", cQry, "Marca",, 10)
	TRCell():New(oSecPedVen, "C5_EMISSAO", cQry, "Emissão",,,,{|| sToD((cQry)->C5_EMISSAO) })
	TRCell():New(oSecPedVen, "A3_NREDUZ", cQry, "Atendente",, 20,,{|| AllTrim(UsrFullName((cQry)->ZZI_ATENDE)) })
	TRCell():New(oSecPedVen, "A3_NREDUZ", cQry, "Representante",, 20,,{|| AllTrim(Posicione("SA3", 1, xFilial("SA3") + (cQry)->C5_VEND1, "A3_NREDUZ")) })
	TRCell():New(oSecPedVen, "A1_NOME", cQry, "Cliente",, 45,,{|| fRetCli((cQry)->C5_CLIENTE, (cQry)->C5_LOJACLI) })
	TRCell():New(oSecPedVen, "C6_NUM", cQry, "Pedido")
	TRCell():New(oSecPedVen, "C6_ITEM", cQry, "Item")
	TRCell():New(oSecPedVen, "C6_NUM", cQry, "Pedido LM",,,,{|| (cQry)->PEDIDO_LM })
	TRCell():New(oSecPedVen, "B1_DESC", cQry, "Produto",, 55,,{|| AllTrim((cQry)->C6_PRODUTO) + "-" + AllTrim((cQry)->B1_DESC) })
	TRCell():New(oSecPedVen, "C6_QTDVEN", cQry, "Quantidade")
	TRCell():New(oSecPedVen, "PZ0_OPNUM", cQry, "Num. OP")
	TRCell():New(oSecPedVen, "C6_YLOTSUG", cQry, "Lote Sugerido")
	TRCell():New(oSecPedVen, "C6_YQTDSUG", cQry, "Qtd. Lt. Sugerido")
						
Return(oReport)


Static Function PrintReport(oReport, cQry, oParam)
Local oSecPedVen := oReport:Section(1)
Local cSQL := ""
	
	cSQL := " SELECT DES_MARCA, C5_EMISSAO, ZZI_ATENDE, C5_VEND1, C5_CLIENTE, C5_LOJACLI, C6_NUM, C6_ITEM, PEDIDO_LM, C6_PRODUTO, B1_DESC, C6_QTDVEN, PZ0_OPNUM, C6_YLOTSUG, C6_YQTDSUG "
	cSQL += " FROM "
	cSQL += " ( "
	
	If SubStr(oParam:cMarca, 1, 1) == "1"
	
		cSQL += fRetSQL("BIA", oParam)
		
	ElseIf SubStr(oParam:cMarca, 1, 1) == "1"
	
		cSQL += fRetSQL("INC", oParam)
	
	ElseIf SubStr(oParam:cMarca, 1, 1) == "3"
	
		cSQL += fRetSQL("BIA", oParam)
		
		cSQL += " UNION ALL "
		
		cSQL += fRetSQL("INC", oParam)
		
	EndIf
	
	cSQL += " ) AS PEDVEN "
	cSQL += " INNER JOIN " + RetSQLName("SA1")
	cSQL += " ON C5_CLIENTE = A1_COD "
	cSQL += " AND C5_LOJACLI = A1_LOJA "
	cSQL += " LEFT JOIN VW_SAP_ZZI "
	cSQL += " ON ZZ7_EMP = MARCA "
	cSQL += " AND C5_VEND1 = ZZI_VEND "
	cSQL += " AND A1_YTPSEG = ZZI_TPSEG "
	cSQL += " ORDER BY ZZI_ATENDE, DES_MARCA, C5_EMISSAO, C6_NUM, C6_ITEM "
	
	TcQuery cSQL New Alias (cQry)
		
	// Impressão dos parametros na primeira pagina
	oReport:oParamPage := TRParamBoxPage():New(oReport, oParam)	
					
	oSecPedVen:Print()
									
	(cQry)->(DbCloseArea())
	
Return()


Static Function fRetSQL(cMarca, oParam)
Local cSQL := ""
Local cDesMar := If (cMarca == "BIA", "Biancogres", "Incesa")
Local cEmpPed := If (cMarca == "BIA", "01", "05")
Local cSC5 := RetFullName("SC5", If (cMarca == "BIA", "01", "05"))
Local cSC6 := RetFullName("SC6", If (cMarca == "BIA", "01", "05"))
Local cPZ0 := RetFullName("PZ0", If (cMarca == "BIA", "01", "05"))
	
	cSQL := " 	SELECT "+ ValToSQL(cDesMar) +" AS DES_MARCA, C5_EMISSAO, "
	cSQL += " 	C5_VEND1 = CASE WHEN C5_CLIENTE <> '010064' THEN C5_VEND1 ELSE (SELECT TOP 1 LM.C5_VEND1 FROM SC5070 LM WHERE LM.C5_YPEDORI = SC5.C5_NUM AND LM.C5_YEMPPED = "+ ValToSQL(cEmpPed) +" AND LM.D_E_L_E_T_ = '') END, "
	cSQL += " 	C5_CLIENTE = CASE WHEN C5_YCLIORI <> '' THEN C5_YCLIORI ELSE C5_CLIENTE END, "
	cSQL += " 	C5_LOJACLI = CASE WHEN C5_YLOJORI <> '' THEN C5_YLOJORI ELSE C5_LOJACLI END, "
	cSQL += " 	C6_NUM, C6_ITEM, "
	cSQL += " 	PEDIDO_LM = CASE WHEN C5_CLIENTE <> '010064' THEN '' ELSE (SELECT TOP 1 LM.C5_NUM FROM SC5070 LM WHERE LM.C5_YPEDORI = SC5.C5_NUM AND LM.C5_YEMPPED = "+ ValToSQL(cEmpPed) +" AND LM.D_E_L_E_T_ = '') END, "
	cSQL += " 	C6_PRODUTO, B1_DESC, C6_QTDVEN, PZ0_OPNUM, C6_YLOTSUG, C6_YQTDSUG, ZZ7_EMP "
	cSQL += " 	FROM " + cSC5 + " SC5 "
	cSQL += " 	INNER JOIN " + cSC6 + " SC6 "
	cSQL += " 	ON C5_FILIAL = SC6.C6_FILIAL "
	cSQL += " 	AND C5_NUM = SC6.C6_NUM "
	cSQL += " 	INNER JOIN " + cPZ0 + " PZ0 "
	cSQL += " 	ON C6_FILIAL = PZ0_FILIAL "
	cSQL += " 	AND C6_NUM = PZ0_PEDIDO "
	cSQL += " 	AND C6_ITEM = PZ0_ITEMPV "
	cSQL += " 	AND C6_PRODUTO = PZ0_CODPRO "
	cSQL += " 	INNER JOIN " + RetSQLName("SB1") + " SB1 "
	cSQL += " 	ON C6_PRODUTO = B1_COD "
	cSQL += " 	INNER JOIN " + RetSQLName("ZZ7") + " ZZ7 "
	cSQL += " 	ON B1_YLINHA = ZZ7_COD "
	cSQL += " 	AND B1_YLINSEQ = ZZ7_LINSEQ "
	cSQL += " 	WHERE C5_FILIAL = " + ValToSQL(xFilial("SC5"))
	cSQL += " 	AND C5_EMISSAO BETWEEN "+ ValToSQL(oParam:dDtEmiDe) +" AND "+ ValToSQL(oParam:dDtEmiAte) 
	cSQL += " 	AND SC5.D_E_L_E_T_ = '' "
	cSQL += " 	AND C6_YLOTSUG <> '' "
	cSQL += " 	AND SC6.D_E_L_E_T_ = '' "
	cSQL += " 	AND PZ0.D_E_L_E_T_ = '' "
	cSQL += " 	AND SB1.D_E_L_E_T_ = '' "
	cSQL += " 	AND ZZ7.D_E_L_E_T_ = ''	"	

Return(cSQL)


Static Function fRetCli(cCliente, cLoja)
Local cRet := ""

	cRet := cCliente + "-" + cLoja + "-" + AllTrim(Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_NOME"))

Return(cRet)