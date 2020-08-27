#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function Pa0R01()
Local oReport

	oReport := ReportDef()
	oReport:PrintDialog()
Return(.T.)


Static Function ReportDef()

Local oReport, oSection1, oSection2, oBreak1
Local cReport := "PA0R01"
Local cTitulo := "Comissão Contratos NET"
Local cDescri := "Entrada de produtos referentes a contratos NET"

	Pergunte("PA0R01", .F.)

	oReport  := TReport():New(cReport, cTitulo, "PA0R01", {|oReport| ReportPrint(oReport, "TRBREL" )}, cDescri)

	//oSecCabec := TRSection():New(oReport,"PFW", cAlias)
	oSection1 := TRSection():New(oReport, "PA0", "TRBREL")
	oSection1:SetTotalInLine(.T.)
	oReport:SetTotalInLine(.F.)
	oReport:SetLandScape()   
	
	oSection1:SetHeaderPage()	

	TRCell():New(oSection1, "PA0_CODFOR" ,"TRBREL", Titulo("PA0_CODFOR"),, TamSX3("PA0_CODFOR")[1])
	//TRCell():New(oSection1, "PA0_LOJFOR" ,"TRBREL", "Loja",, TamSX3("PA0_LOJFOR")[1])
	TRCell():New(oSection1, "PA0_NOMFOR" ,"TRBREL", Titulo("PA0_NOMFOR"),, TamSX3("PA0_NOMFOR")[1])
	TRCell():New(oSection1, "PA0_COD" ,"TRBREL", Titulo("PA0_COD"),, TamSX3("PA0_COD")[1])	
	
	TRCell():New(oSection1, "PA0_DTVIGI" ,"TRBREL", Titulo("PA0_DTVIGI"),,,, {|| Stod(TRBREL->PA0_DTVIGI)})
	TRCell():New(oSection1, "PA0_DTVIGF" ,"TRBREL", Titulo("PA0_DTVIGF"),,,, {|| Stod(TRBREL->PA0_DTVIGF)})

	Trposition():New(oSection1, "PA0", 1, {|| xFilial("PA0") + TRBREL->PA0_COD})  
	Trposition():New(oSection1, "SA2", 1, {|| xFilial("SA2") + TRBREL->(D1_FORNECE + D1_LOJA)})  	
	
	oBreak1 := TRBreak():New(oSection1, {|| TRBREL->D1_FORNECE }, {|| "SUB-TOTAL FORNECEDOR: " + SA2->A2_COD})
	oBreak1:OnPrintTotal({|| oReport:EndPage()}) // Finaliza pagina atual

	oSection2 := TRSection():New(oSection1, "TRBREL2", "TRBREL")

	TRCell():New(oSection2, "D1_DTDIGIT" ,"TRBREL", Titulo("D1_DTDIGIT"),,,, {|| Stod(TRBREL->D1_DTDIGIT)})
	TRCell():New(oSection2, "D1_FILIAL" ,"TRBREL", Titulo("D1_FILIAL"),, TamSX3("D1_FILIAL")[1])
	TRCell():New(oSection2, "D1_LOJA" ,"TRBREL", Titulo("D1_LOJA"),, TamSX3("D1_LOJA")[1])	
	TRCell():New(oSection2, "D1_SERIE" ,"TRBREL", Titulo("D1_SERIE"),, TamSX3("D1_SERIE")[1])
	TRCell():New(oSection2, "D1_DOC" ,"TRBREL", Titulo("D1_DOC"),, TamSX3("D1_DOC")[1])
	TRCell():New(oSection2, "D1_ITEM" ,"TRBREL", Titulo("D1_ITEM"),, TamSX3("D1_ITEM")[1])	
	TRCell():New(oSection2, "PA1_CODPRO" ,"TRBREL", Titulo("PA1_CODPRO"),, TamSX3("PA1_CODPRO")[1])
	TRCell():New(oSection2, "PA1_DESPRO" ,"TRBREL", Titulo("PA1_DESPRO"),, 50)
	TRCell():New(oSection2, "PA1_UMPRO" ,"TRBREL", Titulo("PA1_UMPRO"),, TamSX3("PA1_UMPRO")[1])	
	TRCell():New(oSection2, "D1_QUANT" ,"TRBREL", Titulo("D1_QUANT"), X3Picture("D1_QUANT"), TamSX3("D1_QUANT")[1])		
	TRCell():New(oSection2, "D1_VUNIT" ,"TRBREL", Titulo("D1_VUNIT"), X3Picture("D1_VUNIT"), TamSX3("D1_VUNIT")[1])		
	TRCell():New(oSection2, "D1_TOTAL" ,"TRBREL", Titulo("D1_TOTAL"), X3Picture("D1_TOTAL"), TamSX3("D1_TOTAL")[1])	
	TRCell():New(oSection2, "PA1_VLRNET" ,"TRBREL", Titulo("PA1_VLRNET"), X3Picture("PA1_VLRNET"), TamSX3("PA1_VLRNET")[1])		
	TRCell():New(oSection2, "TOTALNET" ,"TRBREL", "Total Net", X3Picture("D1_TOTAL"), TamSX3("D1_TOTAL")[1])	
	TRCell():New(oSection2, "PA1_PERCOM" ,"TRBREL", Titulo("PA1_PERCOM"), X3Picture("PA1_PERCOM"), TamSX3("PA1_PERCOM")[1])	
	TRCell():New(oSection2, "COMISSAO" ,"TRBREL", "Vlr Comissão", X3Picture("PA1_VLRNET"), TamSX3("PA1_VLRNET")[1])	

	oSection2:Cell("D1_TOTAL"):SetHeaderAlign("RIGHT")  
	oSection2:Cell("TOTALNET"):SetHeaderAlign("RIGHT")  
	oSection2:Cell("PA1_PERCOM"):SetHeaderAlign("RIGHT")  
	oSection2:Cell("COMISSAO"):SetHeaderAlign("RIGHT")  	

	oSection2:SetParentFilter({|cParam| TRBREL->(D1_FORNECE) == cParam}, {|| TRBREL->(D1_FORNECE)})
                                                                                      
	TRFunction():New(oSection2:Cell("D1_TOTAL"),,"SUM" , oBreak1,,,,.F. ,)
	TRFunction():New(oSection2:Cell("TOTALNET"),,"SUM" , oBreak1,,,,.F. ,)
	TRFunction():New(oSection2:Cell("COMISSAO"),,"SUM" , oBreak1,,,,.F. ,)
Return oReport

Static Function ReportPrint(oReport)
Local oSection1 := oReport:Section(1)                           
Local oSection2 := oSection1:Section(1)
//Local nOrder	:= oReport:Section(1):GetOrder()
Local cSql      := ""

	cSql := "SELECT PA0_CODFOR,  PA0_NOMFOR, PA0_COD, PA0_DTVIGI, PA0_DTVIGF, "
	cSql += "       D1_DTDIGIT, D1_FILIAL, D1_SERIE, D1_DOC, D1_EMISSAO, D1_ITEM, D1_COD, D1_FORNECE, D1_LOJA,  "
	cSql += "       PA1_CODPRO, PA1_DESPRO, PA1_TIPPRO, PA1_UMPRO, "
	cSql += "       D1_QUANT, D1_VUNIT, D1_TOTAL, PA1_VLRNET, PA1_PERCOM, "
	cSql += "       (D1_QUANT * PA1_VLRNET) TOTALNET,  "
	cSql += "       (D1_QUANT * PA1_VLRNET * PA1_PERCOM / 100) COMISSAO "
	cSql += "  FROM SD1010 SD1 (NOLOCK) "
	cSql += "  JOIN PA0010 PA0 (NOLOCK) ON PA0_CODFOR = D1_FORNECE "
	//cSql += "                          AND PA0_LOJFOR = D1_LOJA "
	cSql += "                           AND D1_DTDIGIT BETWEEN PA0_DTVIGI AND PA0_DTVIGF "
	cSql += "                           AND PA0.D_E_L_E_T_ != '*' "
	cSql += "  JOIN PA1010 PA1 (NOLOCK) ON PA1_FILIAL = PA0_FILIAL "
	cSql += "                           AND PA1_COD = PA0_COD "
	cSql += "                           AND PA1_CODPRO = D1_COD "
	cSql += "                           AND PA1.D_E_L_E_T_ != '*' "
	cSql += " WHERE D1_FILIAL BETWEEN   '    ' AND 'ZZZZ' "
	cSql += "   AND D1_DTDIGIT BETWEEN  '" + dTos(MV_PAR01) + "' AND '" + dTos(MV_PAR02) + "' "
	cSql += "   AND D1_FORNECE BETWEEN  '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
	cSql += "   AND D1_TIPO NOT IN ('D') "
	cSql += "   AND SD1.D_E_L_E_T_ != '*' "
	cSql += "ORDER BY D1_FORNECE, D1_LOJA, D1_DTDIGIT, D1_FILIAL, D1_SERIE, D1_DOC, D1_ITEM, PA0_COD "

	If Select("TRBREL") > 0
		DbSelectArea("TRBREL")
		DbCloseArea()
	Endif                                   

	TcQuery cSql New Alias "TRBREL"
	
	DbSelectArea("TRBREL")
	DbGoTop()

	oSection1:Print()

	If Select("TRBREL") > 0
		dbSelectArea("TRBREL")
		dbCloseArea()
	Endif
Return Nil

Static Function Titulo(cCampo)
Local aArea   := GetArea()
Local aSx3    := SX3->(GetArea())
Local cTitulo := cCampo

	If AllTrim(SX3->X3_CAMPO) != AllTrim(cCampo)
		DbSelectArea("SX3")
		DbSetOrder(2)
		
		If DbSeek(cCampo)
			cTitulo := X3Titulo()		
		End If
	Else
		cTitulo := X3Titulo()	
	End If
	
    RestArea(aSx3)
	RestArea(aArea)
Return(cTitulo)