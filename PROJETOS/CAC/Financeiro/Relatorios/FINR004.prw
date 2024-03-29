#Include "Totvs.ch"
#Include "TopConn.ch"

//////////////////////////////////////////////////////////
// Empresa: Facile Sistemas								//
// Desenv.: Paulo Cesar Camata Jr						//
// Data:	12/02/2015									//
// Relatorio de Custo por Centro de Custo e Natureza	//
//////////////////////////////////////////////////////////
User Function FINR004()

	Private _cNomRel := "FINR004"
	Private _cTitRel := "Relat�rio Compras por Centro de Custo e Natureza"
	
	AjustaSX1(_cNomRel)
	oReport := ReportDef()
	oReport :PrintDialog()
Return Nil

Static Function ReportDef()
	
	oReport := TReport():New(_cNomRel, _cTitRel, _cNomRel, {|oReport| ReportPrint(oReport)}, _cTitRel)
	oReport:SetPortrait() // Retrato 
	oReport:SetTotalInLine(.F.)
	oReport:SetLineHeight(40)
	oReport:SetColSpace(1)
	oReport:SetLeftMargin(1)
	oReport:oPage:SetPageNumber(1)
	oReport:nFontBody := 6 // Tamanho Fonte
	oReport:lBold := .T.
	oReport:lUnderLine := .F.
	oReport:lHeaderVisible := .T.
	oReport:lFooterVisible := .F.
	
	Pergunte(_cNomRel, .F.)
	
	oSection1 := TRSection():New(oReport, "Centro de Custo", {"CTT"}) // Titulos
	oSection1:SetTotalInLine(.T.)
	TRCell():New(oSection1, "CODIGO", , "Centro de Custo", , 50, .F.)
	oSection1:SetNoFilter({"CTT"})
	
	oSection2 := TRSection():New(oSection1, "Natureza", {"SED"}) // Titulos
	oSection2:SetTotalInLine(.T.)
	TRCell():New(oSection2, "CODIGO", , "Natureza", , 50, .F.)
	oSection2:SetNoFilter({"SED"})
	
	oSection3 := TRSection():New(oSection2, "Notas", {"SED"}) // Titulos
	oSection3:SetTotalInLine(.F.)
	
	TRCell():New(oSection3, "DOCUMENT", , "Nota",,         17, .F.)
	TRCell():New(oSection3, "EMISSAO" , , "Emiss�o",,      15, .F.)
	TRCell():New(oSection3, "FORNECE" , , "Fornecedor",,   20, .F.)
	TRCell():New(oSection3, "NOMFORN" , , "Nome Fornec",,  40, .F.)
	TRCell():New(oSection3, "PRODUTO" , , "Cod. Produto",, 20, .F.)
	TRCell():New(oSection3, "DESPROD" , , "Descri��o",,    40, .F.)
	TRCell():New(oSection3, "QUANT"   , , "Quantidade",,   15, , , "RIGHT", , "RIGHT")
	TRCell():New(oSection3, "VUNIT"   , , "Valor Unit",,   20, , , "RIGHT", , "RIGHT")
	TRCell():New(oSection3, "TOTAL"   , , "Valor Total",,  20, , , "RIGHT", , "RIGHT")
	
	oSection3:SetNoFilter({"SED"})
	
	// Total por Centro de Custo
	oBreak1 := TRBreak():New(oSection1, oSection1:Cell("CODIGO"), "Total Centro de Custo", .F.)
	TRFunction():New(oSection3:Cell("TOTAL"), "Total Centro de Custo", "SUM", oBreak1, , "@E 999,999,999.99", , .F., .F.)
	
	// Total Por Natureza
	oBreak2 := TRBreak():New(oSection2, oSection2:Cell("CODIGO"), "Total Natureza", .F.)
	TRFunction():New(oSection3:Cell("TOTAL"), "Total Natureza", "SUM", oBreak2, , "@E 999,999,999.99", , .F., .F.)
	
	// Total Geral
	TRFunction():New(oSection3:Cell("TOTAL"), "Total Geral", "SUM", , , "@E 999,999,999.99", , .F., .T.)
Return(oReport)

Static Function ReportPrint(oReport)
	oSection1 := oReport:Section(1)
	oSection2 := oReport:Section(1):Section(1)
	oSection3 := oReport:Section(1):Section(1):Section(1)
	_cEoL     := Chr(13) + Chr(10)
	
	// Analitico/Sintetico
	If Mv_Par09 == 1
		oSection3:Show()
	Else
		oSection3:Hide()
	EndIf
	
	_cSelect := "SELECT * " + _cEoL
	
	_cSelect += "  FROM ( " + _cEoL
	
	// Titulos com NF e Sem Rateio
	_cSelect += "		SELECT D1_CC 'CC', " + _cEoL
	_cSelect += "       	(SELECT TOP 1 E2_NATUREZ " + _cEoL
	_cSelect += " 	       	   FROM " + RetSqlName("SE2") + " SE2 " + _cEoL
	_cSelect += "		  	  WHERE E2_FILIAL = D1_FILIAL " + _cEoL
	_cSelect += "		    	AND E2_NUM = D1_DOC " + _cEoL
	_cSelect += "		    	AND E2_PREFIXO = D1_SERIE " + _cEoL
	_cSelect += "		    	AND E2_TIPO = 'NF' " + _cEoL
	_cSelect += "		    	AND E2_FORNECE = D1_FORNECE " + _cEoL
	_cSelect += "		    	AND E2_LOJA = D1_LOJA " + _cEoL
	_cSelect += "		    	AND SE2.D_E_L_E_T_ = '') NATUREZ, " + _cEoL
	_cSelect += "		 	   D1_DOC DOC, D1_EMISSAO EMISSAO, D1_FORNECE FORNECE, D1_LOJA LOJA, D1_COD PROD, " + _cEoL
	_cSelect += "		 	   D1_QUANT QUANT, D1_VUNIT VUNIT, D1_TOTAL 'VALOR', A2_NOME NOMFOR, B1_DESC DESCPROD " + _cEoL
	
	_cSelect += "	 	 FROM " + RetSqlName("SD1") + " SD1 " + _cEoL
	
	_cSelect += "	  	 JOIN " + RetSqlName("SA2") + " SA2 " + _cEoL
	_cSelect += "	  	   ON A2_FILIAL = " + ValToSql(xFilial("SA2")) + _cEoL
	_cSelect += "	   	  AND A2_COD = D1_FORNECE " + _cEoL
	_cSelect += "	   	  AND A2_LOJA = D1_LOJA " + _cEoL
	_cSelect += "	   	  AND SA2.D_E_L_E_T_ = '' " + _cEoL
	
	_cSelect += "	  	JOIN " + RetSqlName("SB1") + " SB1 " + _cEoL
	_cSelect += "	  	  ON B1_FILIAL = " + ValToSql(xFilial("SB1")) + _cEoL
	_cSelect += "	   	 AND B1_COD = D1_COD " + _cEoL
	_cSelect += "	   	 AND SB1.D_E_L_E_T_ = '' " + _cEoL
	
	_cSelect += "	 	WHERE D1_FILIAL = " + ValToSql(xFilial("SD1")) + _cEoL
	_cSelect += "	  	  AND D1_EMISSAO BETWEEN " + ValToSql(Mv_Par01) + " AND " + ValToSql(Mv_Par02) + _cEoL
	_cSelect += "	 	  AND D1_GRUPO BETWEEN " + ValToSql(Mv_Par03) + " AND " + ValToSql(Mv_Par04) + _cEoL
	_cSelect += "	 	  AND D1_CC BETWEEN " + ValToSql(Mv_Par05) + " AND " + ValToSql(Mv_Par06) + _cEoL
	
	If Mv_Par10 == 2
		_cSelect += "	     AND D1_TIPO <> 'D' " + _cEoL
	EndIf
	
	If Mv_Par11 == 2
		_cSelect += "	     AND D1_TIPO <> 'B' " + _cEoL
	EndIf
	
	_cSelect += "	 	  AND D1_RATEIO = '2' " + _cEoL
	_cSelect += "	 	  AND SD1.D_E_L_E_T_ = '' " + _cEoL
	
	// Titutlos com NF e Com Rateio
	_cSelect += "	UNION " + _cEoL
	
	_cSelect += "	  SELECT DE_CC 'CC', " + _cEoL
	_cSelect += "	        (SELECT TOP 1 E2_NATUREZ " + _cEoL
	_cSelect += "		 	   FROM " + RetSqlName("SE2") + " SE2 " + _cEoL
	_cSelect += "		 	  WHERE E2_FILIAL = D1_FILIAL " + _cEoL
	_cSelect += "		  	    AND E2_NUM = D1_DOC " + _cEoL
	_cSelect += "		   	    AND E2_PREFIXO = D1_SERIE " + _cEoL
	_cSelect += "		 	    AND E2_TIPO = 'NF' " + _cEoL
	_cSelect += "		 	    AND E2_FORNECE = D1_FORNECE " + _cEoL
	_cSelect += "		 	    AND E2_LOJA = D1_LOJA " + _cEoL
	_cSelect += "		 	    AND SE2.D_E_L_E_T_ = '') NATUREZ, " + _cEoL
	_cSelect += "			 D1_DOC DOC, D1_EMISSAO EMISSAO, D1_FORNECE FORNECE, D1_LOJA LOJA, D1_COD PROD, " + _cEoL
	_cSelect += "			 D1_QUANT QUANT, D1_VUNIT VUNIT, DE_CUSTO1 'VALOR', A2_NOME NOMFOR, B1_DESC DESCPROD " + _cEoL
	
	_cSelect += "	  	FROM " + RetSqlName("SD1") + " SD1 " + _cEoL
	
	_cSelect += "	  	JOIN " + RetSqlName("SDE") + " SDE " + _cEoL
	_cSelect += "	  	  ON DE_FILIAL = D1_FILIAL " + _cEoL
	_cSelect += "	   	 AND DE_DOC = D1_DOC " + _cEoL
	_cSelect += "	     AND DE_FORNECE = D1_FORNECE " + _cEoL
	_cSelect += "	     AND DE_LOJA = D1_LOJA " + _cEoL
	_cSelect += "	     AND DE_SERIE = D1_SERIE " + _cEoL
	_cSelect += "	     AND DE_ITEMNF = D1_ITEM " + _cEoL
	_cSelect += "	     AND DE_CC BETWEEN " + ValToSql(Mv_Par05) + " AND " + ValToSql(Mv_Par06) + _cEoL
	_cSelect += "	     AND SDE.D_E_L_E_T_ = '' " + _cEoL
	
	_cSelect += "	  	JOIN " + RetSqlName("SA2") + " SA2 " + _cEoL
	_cSelect += "	  	  ON A2_FILIAL = " + ValToSql(xFilial("SA2")) + _cEoL
	_cSelect += "	   	 AND A2_COD = D1_FORNECE " + _cEoL
	_cSelect += "	   	 AND A2_LOJA = D1_LOJA " + _cEoL
	_cSelect += "	   	 AND SA2.D_E_L_E_T_ = '' " + _cEoL
	
	_cSelect += "	  	JOIN " + RetSqlName("SB1") + " SB1 " + _cEoL
	_cSelect += "	  	  ON B1_FILIAL = " + ValToSql(xFilial("SB1")) + _cEoL
	_cSelect += "	   	 AND B1_COD = D1_COD " + _cEoL
	_cSelect += "	   	 AND SB1.D_E_L_E_T_ = '' " + _cEoL
	
	_cSelect += "	   WHERE D1_FILIAL = " + ValToSql(xFilial("SD1")) + _cEoL
	_cSelect += "	     AND D1_EMISSAO BETWEEN " + ValToSql(Mv_Par01) + " AND " + ValToSql(Mv_Par02) + _cEoL
	_cSelect += "	     AND D1_GRUPO BETWEEN " + ValToSql(Mv_Par03) + " AND " + ValToSql(Mv_Par04) + _cEoL
	
	If Mv_Par10 == 2
		_cSelect += "	 AND D1_TIPO <> 'D' " + _cEoL
	EndIf
	
	If Mv_Par11 == 2
		_cSelect += "	 AND D1_TIPO <> 'B' " + _cEoL
	EndIf
	
	_cSelect += "	     AND D1_RATEIO = '1' " + _cEoL
	_cSelect += "	     AND SD1.D_E_L_E_T_ = '' " + _cEoL
	
	// Titulos que nao sao Notas Fiscais e nao possuem Rateio
	_cSelect += "	UNION " + _cEoL
	
	_cSelect += "	  SELECT E2_CCD 'CC', E2_NATUREZ NATUREZ, " + _cEoL
	_cSelect += "	  	     E2_NUM DOC, E2_EMISSAO EMISSAO, E2_FORNECE FORNECE, E2_LOJA LOJA, E2_TIPO PROD, " + _cEoL
	_cSelect += "			 '1' QUANT, E2_VALOR VUNIT, E2_VALOR 'VALOR', A2_NOME NOMFOR, X5_DESCRI DESCPROD " + _cEoL
	
	_cSelect += "	  	FROM " + RetSqlName("SE2") + " SE2 " + _cEoL
	
	_cSelect += "	  	JOIN " + RetSqlName("SA2") + " SA2 " + _cEoL
	_cSelect += "	  	  ON A2_FILIAL = " + ValToSql(xFilial("SA2")) + _cEoL
	_cSelect += "	   	 AND A2_COD = E2_FORNECE " + _cEoL
	_cSelect += "	   	 AND A2_LOJA = E2_LOJA " + _cEoL
	_cSelect += "	   	 AND SA2.D_E_L_E_T_ = '' " + _cEoL
	
	_cSelect += "	  	JOIN " + RetSqlName("SX5") + " SX5 " + _cEoL
	_cSelect += "	  	  ON X5_FILIAL = " + ValToSql(xFilial("SX5")) + _cEoL
	_cSelect += "	   	 AND X5_TABELA = '05'  " + _cEoL
	_cSelect += "	   	 AND X5_CHAVE = E2_TIPO " + _cEoL
	_cSelect += "	   	 AND SX5.D_E_L_E_T_ = '' " + _cEoL
	
	_cSelect += "	   WHERE E2_FILIAL = " + ValToSql(xFilial("SE2")) + _cEoL
	_cSelect += "	     AND E2_EMISSAO BETWEEN " + ValToSql(Mv_Par01) + " AND " + ValToSql(Mv_Par02) + _cEoL
	_cSelect += "	     AND E2_CCD BETWEEN " + ValToSql(Mv_Par05) + " AND " + ValToSql(Mv_Par06) + _cEoL
	_cSelect += "	     AND E2_TIPO <> 'NF' " + _cEoL
	_cSelect += "	     AND (SELECT COUNT(1) " + _cEoL
	_cSelect += "	            FROM " + RetSqlName("SEZ") + " SEZ " + _cEoL
	_cSelect += "	           WHERE EZ_FILIAL = " + ValToSql(xFilial("SEZ")) + _cEoL
	_cSelect += "	             AND EZ_PREFIXO = E2_PREFIXO " + _cEoL
	_cSelect += "	             AND EZ_NUM = E2_NUM " + _cEoL
	_cSelect += "	             AND EZ_PARCELA = E2_PARCELA " + _cEoL
	_cSelect += "	             AND EZ_CLIFOR = E2_FORNECE " + _cEoL
	_cSelect += "	             AND EZ_LOJA = E2_LOJA " + _cEoL
	_cSelect += "	             AND EZ_TIPO = E2_TIPO " + _cEoL
	_cSelect += "	             AND SEZ.D_E_L_E_T_ = '') = 0 " + _cEoL
	_cSelect += "	     AND SE2.D_E_L_E_T_ = '' " + _cEoL
	
	// Titulos que nao sao Notas Fiscais e possuem Rateio
	_cSelect += "	UNION " + _cEoL
	
	_cSelect += "	  SELECT EZ_CCUSTO 'CC', EZ_NATUREZ NATUREZ, " + _cEoL
	_cSelect += "	  	     E2_NUM DOC, E2_EMISSAO EMISSAO, E2_FORNECE FORNECE, E2_LOJA LOJA, E2_TIPO PROD, " + _cEoL
	_cSelect += "			 '1' QUANT, E2_VALOR VUNIT, EZ_VALOR 'VALOR', A2_NOME NOMFOR, X5_DESCRI DESCPROD " + _cEoL
	
	_cSelect += "	  	FROM " + RetSqlName("SE2") + " SE2 " + _cEoL
	
	_cSelect += "	  	JOIN " + RetSqlName("SA2") + " SA2 " + _cEoL
	_cSelect += "	  	  ON A2_FILIAL = " + ValToSql(xFilial("SA2")) + _cEoL
	_cSelect += "	   	 AND A2_COD = E2_FORNECE " + _cEoL
	_cSelect += "	   	 AND A2_LOJA = E2_LOJA " + _cEoL
	_cSelect += "	   	 AND SA2.D_E_L_E_T_ = '' " + _cEoL
	
	_cSelect += "	  	JOIN " + RetSqlName("SEZ") + " SEZ " + _cEoL
	_cSelect += "	      ON EZ_FILIAL = " + ValToSql(xFilial("SEZ")) + _cEoL
	_cSelect += "	     AND EZ_PREFIXO = E2_PREFIXO " + _cEoL
	_cSelect += "	     AND EZ_NUM = E2_NUM " + _cEoL
	_cSelect += "	     AND EZ_PARCELA = E2_PARCELA " + _cEoL
	_cSelect += "	     AND EZ_CLIFOR = E2_FORNECE " + _cEoL
	_cSelect += "	     AND EZ_LOJA = E2_LOJA " + _cEoL
	_cSelect += "	     AND EZ_TIPO = E2_TIPO " + _cEoL
	_cSelect += "	     AND EZ_CCUSTO BETWEEN " + ValToSql(Mv_Par05) + " AND " + ValToSql(Mv_Par06) + _cEoL
	_cSelect += "	     AND SEZ.D_E_L_E_T_ = '' " + _cEoL
	
	_cSelect += "	  	JOIN " + RetSqlName("SX5") + " SX5 " + _cEoL
	_cSelect += "	  	  ON X5_FILIAL = " + ValToSql(xFilial("SX5")) + _cEoL
	_cSelect += "	   	 AND X5_TABELA = '05'  " + _cEoL
	_cSelect += "	   	 AND X5_CHAVE = E2_TIPO " + _cEoL
	_cSelect += "	   	 AND SX5.D_E_L_E_T_ = '' " + _cEoL
	
	_cSelect += "	   WHERE E2_FILIAL = " + ValToSql(xFilial("SE2")) + _cEoL
	_cSelect += "	     AND E2_EMISSAO BETWEEN " + ValToSql(Mv_Par01) + " AND " + ValToSql(Mv_Par02) + _cEoL
	_cSelect += "	     AND E2_TIPO <> 'NF' " + _cEoL
	_cSelect += "	     AND SE2.D_E_L_E_T_ = '' " + _cEoL
	
	// Despesas com caixinha
	_cSelect += "	UNION " + _cEoL
	
	_cSelect += "	  SELECT EU_CCD 'CC', CASE WHEN EU_YNATURE = '' THEN EU_NATUREZ ELSE EU_YNATURE END NATUREZ, " + _cEoL
	_cSelect += "	         EU_NRCOMP DOC, EU_EMISSAO EMISSAO, EU_FORNECE FORNECE, EU_LOJA LOJA, " + _cEoL
	_cSelect += "			 'CAIXINHA' PROD, '1' QUANT, EU_VALOR VUNIT, EU_VALOR 'VALOR', EU_NOME NOMFOR, EU_HISTOR DESCPROD " + _cEoL
	
	
	_cSelect += "	  	FROM " + RetSqlName("SEU") + " SEU " + _cEoL
	
	_cSelect += "	   WHERE EU_FILIAL = " + ValToSql(xFilial("SEU")) + _cEoL
	_cSelect += "	     AND EU_EMISSAO BETWEEN " + ValToSql(Mv_Par01) + " AND " + ValToSql(Mv_Par02) + _cEoL
	_cSelect += "	     AND EU_CCD BETWEEN " + ValToSql(Mv_Par05) + " AND " + ValToSql(Mv_Par06) + _cEoL
	_cSelect += "	     AND EU_TIPO = '00' " + _cEoL
	_cSelect += "	     AND SEU.D_E_L_E_T_ = '' " + _cEoL
	
	_cSelect += ") TRB " + _cEoL
	
	_cSelect += "  WHERE NATUREZ BETWEEN " + ValToSql(Mv_Par07) + " AND " + ValToSql(Mv_Par08) + _cEoL
	
	_cSelect += " ORDER BY CC, NATUREZ, DOC, EMISSAO, FORNECE, LOJA, PROD, QUANT, VUNIT, VALOR " + _cEoL
	
	TcQuery _cSelect Alias "COMPRA" New
	
	cCCAnt  := ""
	cNatAnt := ""
	
	oSection2:nLeftMargin := 5
	oSection3:nLeftMargin := 10
	
	If !COMPRA->(EoF())
		// Secao Centro de Custo
		oSection1:Init()
		_cDesCC := Posicione("CTT", 1, xFilial("CTT") + COMPRA->CC, "CTT_DESC01")
		oSection1:Cell("CODIGO"):SetValue(AllTrim(COMPRA->CC) + " - " + AllTrim(_cDesCC))
		oSection1:PrintLine()
		
		oSection2:Init()
		_cDesNat := Posicione("SED", 1, xFilial("SED") + COMPRA->NATUREZ, "ED_DESCRIC")
		oSection2:Cell("CODIGO"):SetValue(AllTrim(COMPRA->NATUREZ) + " - " + AllTrim(_cDesNat))
		oSection2:PrintLine()
		oSection2:Finish()
		
		// Listando Secao
		oSection3:Init()
		
		// Controle de listagem das secoes
		cCCAnt  := AllTrim(COMPRA->CC)
		cNatAnt := AllTrim(COMPRA->NATUREZ)
	EndIf
	
	While !COMPRA->(EoF())
		
		// Impressao Secao Centro de Custo
		If AllTrim(COMPRA->CC) <> AllTrim(cCCAnt)
			oSection3:Finish()
			oSection2:Finish()
			oSection1:Finish()
			
			oSection1:Init()
			_cDesCC := Posicione("CTT", 1, xFilial("CTT") + COMPRA->CC, "CTT_DESC01")
			oSection1:Cell("CODIGO"):SetValue(AllTrim(COMPRA->CC) + " - " + AllTrim(_cDesCC))
			oSection1:PrintLine()
			
			oSection2:Init()
			_cDesNat := Posicione("SED", 1, xFilial("SED") + COMPRA->NATUREZ, "ED_DESCRIC")
			oSection2:Cell("CODIGO"):SetValue(AllTrim(COMPRA->NATUREZ) + " - " + AllTrim(_cDesNat))
			oSection2:PrintLine()
			
			oSection3:Init()
			
		ElseIf AllTrim(COMPRA->NATUREZ) <> AllTrim(cNatAnt)
			oSection3:Finish()
			oSection2:Finish()
			
			oSection2:Init()
			_cDesNat := Posicione("SED", 1, xFilial("SED") + COMPRA->NATUREZ, "ED_DESCRIC")
			oSection2:Cell("CODIGO"):SetValue(AllTrim(COMPRA->NATUREZ) + " - " + AllTrim(_cDesNat))
			oSection2:PrintLine()
			
			oSection3:Init()
		EndIf
		
		oSection3:Cell("DOCUMENT"):SetValue(COMPRA->DOC)
		oSection3:Cell("EMISSAO"):SetValue(DTOC(STOD(COMPRA->EMISSAO)))
		oSection3:Cell("FORNECE"):SetValue(COMPRA->FORNECE + "/" + COMPRA->LOJA)
		oSection3:Cell("NOMFORN"):SetValue(AllTrim(COMPRA->NOMFOR))
		oSection3:Cell("PRODUTO"):SetValue(COMPRA->PROD)
		oSection3:Cell("DESPROD"):SetValue(AllTrim(COMPRA->DESCPROD))
		oSection3:Cell("QUANT"):SetValue(COMPRA->QUANT)
		oSection3:Cell("VUNIT"):SetValue(COMPRA->VUNIT)
		oSection3:Cell("TOTAL"):SetValue(COMPRA->VALOR)
		
		oSection3:PrintLine()
		
		cNatAnt := COMPRA->NATUREZ
		cCCAnt  := COMPRA->CC
		
		COMPRA->(DbSkip())
	EndDo
	COMPRA->(DbCloseArea())
	
	// Terminando Secoes
	oSection3:Finish()
	oSection2:Finish()
	oSection1:Finish()
	
Return Nil
*-----------------------------------------------------------------------------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////
// Funcao para Ajustar as Perguntas conforme necessidade do Relatorio //
////////////////////////////////////////////////////////////////////////
Static Function AjustaSX1(cPerg)
	PutSx1(cPerg, "01", "Emissao   De:         ", "", "", "mv_ch1", "D", 08, 00, 0, "G", "NaoVazio()", ""    ,"", " ", "mv_par01", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "02", "Emissao  Ate:         ", "", "", "mv_ch2", "D", 08, 00, 0, "G", "NaoVazio()", ""    ,"", " ", "mv_par02", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "03", "Grupo     De:         ", "", "", "mv_ch3", "C", 15, 00, 0, "G", ""          , "SBM" ,"", " ", "mv_par03", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "04", "Grupo    Ate:         ", "", "", "mv_ch4", "C", 15, 00, 0, "G", "NaoVazio()", "SBM" ,"", " ", "mv_par04", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "05", "Cent.Cus  De:         ", "", "", "mv_ch5", "C", 15, 00, 0, "G", ""          , "CTT" ,"", " ", "mv_par05", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "06", "Cent.Cus Ate:         ", "", "", "mv_ch6", "C", 15, 00, 0, "G", "NaoVazio()", "CTT" ,"", " ", "mv_par06", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "07", "Natureza  De:         ", "", "", "mv_ch7", "C", 15, 00, 0, "G", ""          , "SED" ,"", " ", "mv_par07", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "08", "Natureza Ate:         ", "", "", "mv_ch8", "C", 15, 00, 0, "G", "NaoVazio()", "SED" ,"", " ", "mv_par08", "               ", "", "", "", "               ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "09", "Tipo Relator:         ", "", "", "mv_ch9", "N", 01, 00, 0, "C", ""          , ""    ,"", " ", "mv_par09", "1=Analitico    ", "", "", "", "2=Sint�tico    ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "10", "NF Devolucao:         ", "", "", "mv_cha", "N", 01, 00, 0, "C", ""          , ""    ,"", " ", "mv_par10", "1=Sim          ", "", "", "", "2=Nao          ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
	PutSx1(cPerg, "11", "NF Benefici.:         ", "", "", "mv_chb", "N", 01, 00, 0, "C", ""          , ""    ,"", " ", "mv_par11", "1=Sim          ", "", "", "", "2=Nao          ", "", "", "               ", "", "", "               ", "", "", "               ", "", "", {},{},{},"")
Return Nil
*-----------------------------------------------------------------------------------------------------------------------------------------------