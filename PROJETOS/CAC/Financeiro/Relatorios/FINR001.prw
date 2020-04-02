#Include "Totvs.ch"
#Include "TopConn.ch"

//////////////////////////////////////////////
// Empresa: Facile Sistemas					//
// Desenv.: Paulo Cesar Camata Jr			//
// Data:	07/05/2015						//
// Relatorio de Demonstrativo de Comissoes	//
//////////////////////////////////////////////
User Function FINR001()
	oReport := ReportDef()
	oReport:PrintDialog()
Return Nil
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------
///////////////////////////////
// Funcao Montagem Relatorio //
///////////////////////////////
Static Function ReportDef()
	
	Local nTamData := Len(DTOC(MsDate())) + 2
	
	Private oReport
	Private oVendedores, oDetalhe, oGeral
	
	oReport := TReport():New("FINR001", "Relatorio de Comissoes", "FINR001", {|oReport| ReportPrint(oReport)}, "Emissao do relatorio de Comissoes.")
	oReport:SetLandscape() 
	oReport:SetTotalInLine(.F.)

	AjustaSX1("FINR001")
	Pergunte("FINR001",.F.)
	
	// Secao Vendedores
	oVendedores := TRSection():New(oReport,"Vendedores",{"SE3","SA3"},{},/*Campos do SX3*/,/*Campos do SIX*/)
	oVendedores:SetTotalInLine(.F.)
	
	TRCell():New(oVendedores, "E3_VEND", "SE3", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/)
	TRCell():New(oVendedores, "A3_NOME", "SA3", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/)
	
	// Secao com os Titulos
	oDetalhe := TRSection():New(oVendedores, "Comissoes", {"SE3","SA3","SA1"},/*{Array com as ordens do relatorio}*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oDetalhe:SetTotalInLine(.F.)
	oDetalhe:SetHeaderBreak(.T.)
	
	TRCell():New(oDetalhe,"E3_PREFIXO", "COMISS", "Prefixo"      , /*Picture*/               , /*Tamanho*/          , /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oDetalhe,"E3_NUM"	  , "COMISS", "Titulo"       , /*Picture*/               , /*Tamanho*/          , /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oDetalhe,"E3_PARCELA", "COMISS", "Parcela"      , /*Picture*/               , /*Tamanho*/          , /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oDetalhe,"E3_CODCLI" , "COMISS", "Cliente"      , /*Picture*/               , /*Tamanho*/          , /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oDetalhe,"A1_NREDUZ" , "COMISS", "Nome Fantasia", /*Picture*/               , 40			        , /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oDetalhe,"F2_EMISSAO", "COMISS", "Emissao NF"   , /*Picture*/               , /*Tamanho*/          , /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oDetalhe,"E3_EMISSAO", "COMISS", "Data Comissao", /*Picture*/               , nTamData             , /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oDetalhe,"E3_VENCTO" , "COMISS", "Vencto"       , /*Picture*/               , nTamData             , /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oDetalhe,"E3_DATA"   , "COMISS", "Pagto"        , /*Picture*/               , nTamData             , /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oDetalhe,"E3_PEDIDO" , "COMISS", "Pedido"       , /*Picture*/               , /*Tamanho*/          , /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oDetalhe,"E3_BASE"	  , "COMISS", "Vlr Base"     , PesqPict('SE3','E3_BASE') , TamSx3("E3_BASE"	)[1], /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oDetalhe,"E3_PORC"	  , "COMISS", "%"            , tm(SE3->E3_PORC,6)        , /*Tamanho*/          , /*lPixel*/, /*{|| code-block de impressao }*/)
	TRCell():New(oDetalhe,"E3_COMIS"  , "COMISS", "Comissao"     , PesqPict('SE3','E3_COMIS'), TamSx3("E3_COMIS")[1], /*lPixel*/, /*{|| code-block de impressao }*/)
	
	oGeral := TRSection():New(oReport,"",{},/*{Array com as ordens do relatorio}*/, /*Campos do SX3*/,/*Campos do SIX*/)
	TRCell():New(oGeral, "TXTTOTAL", "", "Total Geral",                           , 126                  , /*lPixel*/, { || "" } )    
	TRCell():New(oGeral, "BASE"	   , "", "Base"       , PesqPict('SE3','E3_COMIS'), TamSX3("E3_COMIS")[1], /*lPixel*/, /*CodeBlock*/)
	TRCell():New(oGeral, "PERCENT" , "", "Perc."      , PesqPict("SE3","E3_PORC" ), TamSX3("E3_PORC" )[1], /*lPixel*/, /*CodeBlock*/)
	TRCell():New(oGeral, "COMIS"   , "", "Comissão"   , PesqPict('SE3','E3_COMIS'), TamSX3("E3_COMIS")[1], /*lPixel*/, /*CodeBlock*/)
	
	// Alinhamentos
	oDetalhe:Cell("E3_COMIS"):SetHeaderAlign("RIGHT")
	oDetalhe:Cell("E3_BASE"):SetHeaderAlign("RIGHT")
	oDetalhe:Cell("E3_COMIS"):SetHeaderAlign("RIGHT")
	oDetalhe:nLeftMargin := 5
	
	oGeral:Cell("BASE"):SetHeaderAlign("RIGHT")
	oGeral:Cell("PERCENT"):SetHeaderAlign("RIGHT")
	oGeral:Cell("COMIS"):SetHeaderAlign("RIGHT")
	
Return oReport
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------
///////////////////////////
// Funcao Para Impressao //
///////////////////////////
Static Function ReportPrint(oReport)
	
	oVendedores := oReport:Section(1)
	oDetalhe    := oReport:Section(1):Section(1)
	oGeral      := oReport:Section(2)
	
	_cEoL := Chr(13) + Chr(10)
	
	// Select
	_cSelect := "SELECT E3_VEND, A3_NOME, E3_PREFIXO, E3_NUM, E3_PARCELA, E3_CODCLI, SA1.A1_NREDUZ CLICOM, E3_EMISSAO, " + _cEoL
	_cSelect += "       E3_DATA, E3_VENCTO, E3_PEDIDO, E3_COMIS, E3_BASE, E3_PORC, E3_COMIS, F2_EMISSAO, " + _cEoL
	_cSelect += "       F2_CLIENTE, SA1N.A1_NREDUZ CLINOTA " + _cEoL
	
	_cSelect += "  FROM " + RetSqlName("SE3") + " SE3 " + _cEoL
	
	_cSelect += "  JOIN " + RetSqlName("SA1") + " SA1 " + _cEoL
	_cSelect += "    ON SA1.A1_FILIAL = " + ValToSql(xFilial("SA1")) + _cEoL
	_cSelect += "   AND SA1.A1_COD = E3_CODCLI " + _cEoL
	_cSelect += "   AND SA1.A1_LOJA = E3_LOJA " + _cEoL
	_cSelect += "   AND SA1.D_E_L_E_T_ = '' " + _cEoL
	
	_cSelect += "  JOIN " + RetSqlName("SA3") + " SA3 " + _cEoL
	_cSelect += "    ON A3_FILIAL = " + ValToSql(xFilial("SA3")) + _cEoL
	_cSelect += "   AND A3_COD = E3_VEND " + _cEoL
	_cSelect += "   AND SA3.D_E_L_E_T_ = '' " + _cEoL
	
	_cSelect += "  JOIN " + RetSqlName("SF2") + " SF2 " + _cEoL
	_cSelect += "    ON F2_FILIAL = " + ValToSql(xFilial("SF2")) + _cEoL
	_cSelect += "   AND F2_DOC = E3_NUM " + _cEoL
	_cSelect += "   AND F2_SERIE = E3_SERIE " + _cEoL
	_cSelect += "   AND SF2.D_E_L_E_T_ = '' " + _cEoL
	
	// JOIN COM O CLIENTE DA NOTA CASO SEJA VENDEDOR ATLAS
	_cSelect += "  JOIN " + RetSqlName("SA1") + " SA1N " + _cEoL
	_cSelect += "    ON SA1N.A1_FILIAL = " + ValToSql(xFilial("SA1")) + _cEoL
	_cSelect += "   AND SA1N.A1_COD = F2_CLIENTE " + _cEoL
	_cSelect += "   AND SA1N.A1_LOJA = F2_LOJA " + _cEoL
	_cSelect += "   AND SA1N.D_E_L_E_T_ = '' " + _cEoL

	If Mv_Par01 == 3
		_cSelect += "   AND F2_EMISSAO BETWEEN " + ValToSql(Mv_Par02) + " AND " + ValToSql(Mv_Par03) + _cEoL
	EndIf
	
	_cSelect += " WHERE E3_FILIAL = " + ValToSql(xFilial("SE3")) + _cEoL
	_cSelect += "   AND E3_VEND BETWEEN " + ValToSql(Mv_Par04) + " AND " + ValToSql(Mv_Par05) + _cEoL
	_cSelect += "   AND SE3.D_E_L_E_T_ = '' " + _cEoL
	
	// Data Comissao
	If Mv_Par01 == 1
		_cSelect += " AND E3_EMISSAO BETWEEN " + ValToSql(Mv_Par02) + " AND " + ValToSql(Mv_Par03) + _cEoL
		
	// Data Vencimento
	ElseIf Mv_Par01 == 2
		_cSelect += " AND E3_VENCTO BETWEEN " + ValToSql(Mv_Par02) + " AND " + ValToSql(Mv_Par03) + _cEoL
	EndIf
	
	TcQuery _cSelect Alias "COMISS" New
	
	_cVendAnt := ""
	_nTotBase := 0
	_nTotComi := 0
	_nBasVend := 0
	_nComVend := 0
		
	oVendedores:Init()
	
	While !COMISS->(EoF()) .And. !oReport:Cancel()
		
		// Impressao Quebra por Vendedor
		If _cVendAnt <> COMISS->E3_VEND
			
			oDetalhe:Finish()
			oVendedores:Finish()
			
			If !Empty(_cVendAnt)
				oGeral:Cell("TXTTOTAL"):SetSize(126)
				oGeral:Cell("TXTTOTAL"):SetTitle("Total do Vendedor")
				oGeral:Cell("BASE"    ):SetBlock({|| _nBasVend})
				oGeral:Cell("PERCENT" ):SetBlock({|| Round((_nComVend/_nBasVend) * 100, 2)})
				oGeral:Cell("COMIS"   ):SetBlock({|| _nComVend})
				oGeral:Init()
				oGeral:PrintLine()
				oGeral:Finish()
			EndIf
			
			oVendedores:Init()
				oVendedores:Cell("E3_VEND"):SetValue(COMISS->E3_VEND)
				oVendedores:Cell("A3_NOME"):SetValue(COMISS->A3_NOME)
			oVendedores:PrintLine()
			
			oDetalhe:Init()
			
			_nBasVend := 0
			_nComVend := 0
		EndIf
		
		// Impressao da Detalhe
		oDetalhe:Cell("E3_PREFIXO"):SetValue(COMISS->E3_PREFIXO)
		oDetalhe:Cell("E3_NUM"	  ):SetValue(COMISS->E3_NUM)
		oDetalhe:Cell("E3_PARCELA"):SetValue(COMISS->E3_PARCELA)
		
		// Vendedor Normal
		If Left(COMISS->E3_VEND, 1) <> "9"
			oDetalhe:Cell("E3_CODCLI"):SetValue(COMISS->E3_CODCLI)
			oDetalhe:Cell("A1_NREDUZ"):SetValue(COMISS->CLICOM)
		Else // ATLAS
			oDetalhe:Cell("E3_CODCLI"):SetValue(COMISS->F2_CLIENTE)
			oDetalhe:Cell("A1_NREDUZ"):SetValue(COMISS->CLINOTA)
		EndIf
		
		oDetalhe:Cell("F2_EMISSAO"):SetValue(DTOC(STOD(COMISS->F2_EMISSAO)))
		oDetalhe:Cell("E3_EMISSAO"):SetValue(DTOC(STOD(COMISS->E3_EMISSAO)))
		oDetalhe:Cell("E3_VENCTO" ):SetValue(DTOC(STOD(COMISS->E3_VENCTO)))
		oDetalhe:Cell("E3_DATA"	  ):SetValue(DTOC(STOD(COMISS->E3_DATA)))
		oDetalhe:Cell("E3_PEDIDO" ):SetValue(COMISS->E3_PEDIDO)
		oDetalhe:Cell("E3_BASE"	  ):SetValue(COMISS->E3_BASE)
		oDetalhe:Cell("E3_PORC"	  ):SetValue(COMISS->E3_PORC)
		oDetalhe:Cell("E3_COMIS"  ):SetValue(COMISS->E3_COMIS)
		
		oDetalhe:PrintLine()
		
		// Vendedor Anterior
		_cVendAnt := COMISS->E3_VEND
		
		// Variaveis Total Vendedor
		_nBasVend += COMISS->E3_BASE
		_nComVend += COMISS->E3_COMIS
		
		// Variaveis do Total Geral
		_nTotBase += COMISS->E3_BASE
		_nTotComi += COMISS->E3_COMIS
		
		COMISS->(DbSkip())
	EndDo
	COMISS->(DbCloseArea())
	
	oDetalhe:Finish()
	oVendedores:Finish()
	
	oGeral:Cell("TXTTOTAL"):SetSize(126)
	oGeral:Cell("TXTTOTAL"):SetTitle("Total do Vendedor")
	oGeral:Cell("BASE"    ):SetBlock({|| _nBasVend})
	oGeral:Cell("PERCENT" ):SetBlock({|| Round((_nComVend/_nBasVend) * 100, 2)})
	oGeral:Cell("COMIS"   ):SetBlock({|| _nComVend})
	oGeral:Init()
	oGeral:PrintLine()
	oGeral:Finish()
	
	// Secao Totalizadora
	oGeral:SetPageBreak(.F.)
	oGeral:Init()
	oGeral:Cell("TXTTOTAL"):SetSize(126)
	oGeral:Cell("TXTTOTAL"):SetTitle("Total Geral")
	oGeral:Cell("BASE"    ):SetBlock({|| _nTotBase})
	oGeral:Cell("PERCENT" ):SetBlock({|| Round((_nTotComi/_nTotBase) * 100, 2)})
	oGeral:Cell("COMIS"   ):SetBlock({|| _nTotComi})
	oGeral:PrintLine()
	oGeral:Finish()
	
Return Nil
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////
// Funcao para Ajustar as Perguntas conforme necessidade do Relatorio //
////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
	PutSx1(cPerg, "01", "Tipo Filt Dt", "", "", "mv_ch1", "N", 01, 00, 0, "C", "NaoVazio()", ""    ,"", " ", "Mv_Par01", "Dt Comissao    ", "", "", "", "Dt Vencto      ", "", "", "Dt Emissao NF  ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "02", "Data  De    ", "", "", "mv_ch2", "D", 08, 00, 0, "G", "NaoVazio()", ""    ,"", " ", "Mv_Par02", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "03", "Data Ate    ", "", "", "mv_ch3", "D", 08, 00, 0, "G", "NaoVazio()", ""    ,"", " ", "Mv_Par03", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "04", "Vendedor  De", "", "", "mv_ch4", "C", 06, 00, 0, "G", "NaoVazio()", "SA3" ,"", " ", "Mv_Par04", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "05", "Vendedor Ate", "", "", "mv_ch5", "C", 06, 00, 0, "G", "NaoVazio()", "SA3" ,"", " ", "Mv_Par05", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
Return Nil
*----------------------------------------------------------------------------------------------------------------------------------------------------------------------