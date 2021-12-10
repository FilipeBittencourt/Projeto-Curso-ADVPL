#Include 'Protheus.ch'
#Include 'Topconn.ch'

/*/{Protheus.doc} AAPOFI58
Relatório para analise de produtos removidos no checkout
@type function
@author Pontin
@since 29.05.19
@version 1.0
/*/

User Function AAPOFI58()

	Local oReport

	//|variaveis para seleção de filiais |
	Private aSit		:= {}
	Private aFiliais	:= {}

	Private cPerg		:= "AAPOFI58"
	Private cMsg		:= "Analise de produtos removidos no checkout"

	//|Cria perguntas |
	SFP001(cPerg)

	Pergunte(cPerg,.T.)

    If TRepInUse()
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf

Return()


Static Function ReportDef()

	Local oReport
	Local oSecCE
	Local oBreak

	oReport := TReport():New(cPerg,cMsg,cPerg,{|oReport| PrintReport(oReport)},cMsg)

	oReport:oPage:nPaperSize	:= 9  //Papel A4
	oReport:nFontBody			:= 9
	oReport:nLineHeight			:= 40
	oReport:cFontBody 			:= "Courier New"
	oReport:lBold 				:= .F.
	oReport:lUnderLine 			:= .F.
	oReport:lHeaderVisible 		:= .T.
	oReport:lFooterVisible 		:= .F.
	oReport:lParamPage 	   		:= .F.
	oReport:SetLandScape()
	oReport:SetTotalInLine(.T.)
	oReport:oPage:SetPageNumber(1)
	oReport:SetColSpace(0)
	oReport:SetTotalPageBreak(.T.)

	oSecCE := TRSection():New(oReport,"CE")
	oSecCE:SetHeaderBreak(.T.)
	oSecCE:SetHeaderSection(.T.)
    oSecCE:PageBreak(.T.)

	TRCell():New(oSecCE,"VS3_FILIAL","VS3",,,10)
	TRCell():New(oSecCE,"VS1_NUMORC","VS1",,,10)
	TRCell():New(oSecCE,"TIPO","","Tipo",,2)
	TRCell():New(oSecCE,"ZZ_COD","SZZ",,,6)
	TRCell():New(oSecCE,"ZZ_CODITE","SZZ",,,15)
	TRCell():New(oSecCE,"ZZ_NOMFAB","SZZ",,,13)
	TRCell():New(oSecCE,"ZZ_APLIC","SZZ",,,40)
	TRCell():New(oSecCE,"ZZ_LOCALIZ","SZZ",,,17)
	TRCell():New(oSecCE,"CONFERENTE","","Conferente",,15)
	TRCell():New(oSecCE,"STATUS","","Status",,10)
	TRCell():New(oSecCE,"VENDIDO","","Vendido",,6)
	TRCell():New(oSecCE,"REMOVIDO","","Removido",,6)
	TRCell():New(oSecCE,"ESTOQUE","","Estoque",,6)

	//oSecCE:SetLineStyle()

Return oReport



Static Function PrintReport(oReport)

	Local oSecCE 		:= oReport:Section(1)
	Local cQuery		:= ""
	Local nQtd			:= 0

	oSecCE:Init()

	cQuery += " SELECT VS3.VS3_FILIAL, "
	cQuery += " 	VS1.VS1_NUMORC, "
	cQuery += " 	CASE WHEN VS1.VS1_TIPORC = '1' THEN 'V' ELSE 'T' END AS TIPO, "
	cQuery += " 	SZZ.ZZ_COD, "
	cQuery += " 	SZZ.ZZ_CODITE, "
	cQuery += " 	SZZ.ZZ_NOMFAB, "
	cQuery += " 	SUBSTRING(SZZ.ZZ_APLIC,1,40) AS ZZ_APLIC, "
	cQuery += " 	SZZ.ZZ_LOCALIZ, "
	cQuery += " 	ISNULL(LEFT(SRA.RA_NOME, charindex(' ', SRA.RA_NOME)-1), '') AS CONFERENTE, "
	cQuery += " 	(CASE WHEN VS1.VS1_STATUS = 'X' THEN 'FATURADO' "
	cQuery += " 			WHEN VS1.VS1_STATUS = 'F' THEN 'SEPARADO' "
	cQuery += " 			ELSE '' END) AS STATUS_PED, "
	cQuery += " 	VS3.VS3_QTDINI AS VENDIDO, "
	cQuery += " 	(VS3.VS3_QTDINI - VS3.VS3_QTDCON) AS REMOVIDO, "
	cQuery += " 	SB2.B2_QATU AS SALDO_EST "
	cQuery += " FROM " + RetSqlName("VS1") + " VS1 "
	cQuery += " 	JOIN " + RetSqlName("VS3") + " VS3 "
	cQuery += " 		ON VS3.VS3_FILIAL = VS1.VS1_FILIAL "
	cQuery += " 		AND VS3.VS3_NUMORC = VS1.VS1_NUMORC "
	cQuery += " 		AND (VS3.VS3_QTDINI - VS3.VS3_QTDCON) > 0 "
	cQuery += " 		AND VS3.VS3_YCOD BETWEEN " + ValToSql(MV_PAR02) + " AND " + ValToSql(MV_PAR03)
	cQuery += " 		AND VS3.D_E_L_E_T_ = '' "
	cQuery += " 	JOIN " + RetSqlName("SZZ") + " SZZ "
	cQuery += " 		ON SZZ.ZZ_FILIAL = VS3.VS3_FILIAL "
	cQuery += " 		AND SZZ.ZZ_COD = VS3.VS3_YCOD "
	cQuery += " 		AND SZZ.ZZ_FABRIC BETWEEN " + ValToSql(MV_PAR04) + " AND " + ValToSql(MV_PAR05)
	cQuery += " 		AND SZZ.D_E_L_E_T_ = '' "
	cQuery += " 	LEFT JOIN " + RetSqlName("SRA") + " SRA "
	cQuery += " 		ON SRA.RA_YSEPAR = VS3.VS3_FILIAL "
	cQuery += " 		AND SRA.RA_MAT = VS3.VS3_YCHECA "
	cQuery += " 		AND SRA.D_E_L_E_T_ = '' "
	cQuery += " 	JOIN " + RetSqlName("SB2") + " SB2 "
	cQuery += " 		ON SB2.B2_FILIAL = VS3.VS3_FILIAL "
	cQuery += " 		AND SB2.B2_COD = VS3.VS3_YCOD "
	cQuery += " 		AND SB2.B2_LOCAL = VS3.VS3_LOCAL "
	cQuery += " 		AND SB2.D_E_L_E_T_ = '' "
	cQuery += " WHERE VS1.VS1_FILIAL = " + ValToSql(MV_PAR01)
	cQuery += " 	AND VS1.VS1_DATORC BETWEEN " + ValToSql(MV_PAR06) + " AND " + ValToSql(MV_PAR07)
	cQuery += " 	AND VS1.VS1_STATUS IN ( 'F', 'X' ) "
	//cQuery += " 	AND VS1.VS1_TIPORC = '1' "
	cQuery += " 	AND VS1.D_E_L_E_T_ = '' "
	//cQuery += " ORDER BY VS3.VS3_FILIAL,VS3.VS3_NUMORC,SZZ.ZZ_NOMFAB,SZZ.ZZ_COD "
	cQuery += " ORDER BY SZZ.ZZ_LOCALIZ "

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TcQuery cQuery New Alias "QRY"

	Count To nQtd

	QRY->(dbGoTop())

	oReport:SetMeter(nQtd)

	While !oReport:Cancel() .And. !QRY->(EoF())

		oReport:IncMeter()

		If oReport:Cancel()
			Exit
		EndIf

		oSecCE:Cell("VS3_FILIAL"):SetValue(QRY->VS3_FILIAL)
		oSecCE:Cell("VS1_NUMORC"):SetValue(QRY->VS1_NUMORC)
		oSecCE:Cell("TIPO"):SetValue(QRY->TIPO)
		oSecCE:Cell("ZZ_COD"):SetValue(QRY->ZZ_COD)
		oSecCE:Cell("ZZ_CODITE"):SetValue(QRY->ZZ_CODITE)
		oSecCE:Cell("ZZ_NOMFAB"):SetValue(QRY->ZZ_NOMFAB)
		oSecCE:Cell("ZZ_APLIC"):SetValue(QRY->ZZ_APLIC)
		oSecCE:Cell("ZZ_LOCALIZ"):SetValue(QRY->ZZ_LOCALIZ)
		oSecCE:Cell("CONFERENTE"):SetValue(QRY->CONFERENTE)
		oSecCE:Cell("STATUS"):SetValue(QRY->STATUS_PED)
		oSecCE:Cell("VENDIDO"):SetValue(QRY->VENDIDO)
		oSecCE:Cell("REMOVIDO"):SetValue(QRY->REMOVIDO)
		oSecCE:Cell("ESTOQUE"):SetValue(QRY->SALDO_EST)

		oSecCE:PrintLine()

		//oReport:ThinLine()

		QRY->(dbSkip())

	EndDo

	oSecCE:Finish()

Return


/*/{Protheus.doc} SFP001
Verifica a existencia das perguntas criando-as caso seja necessario (caso nao existam).

@author		Augusto Pontin
@since 		2019.05.29
/*/
Static Function SFP001(cPerg)

	Local aRegs		:= {}
	Local aHelp		:= {}

	aAdd(aRegs,{"Filial"	  		, "", "",  "MV_CH1", "C",TamSx3("ZZ_FILIAL")[1], TamSx3("ZZ_FILIAL")[2], 0, "G", ""/*10*/, "MV_PAR01", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "", "SM0", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
	aAdd(aRegs,{"Produto De"	  	, "", "",  "MV_CH2", "C",TamSx3("ZZ_COD")[1], TamSx3("ZZ_COD")[2]		, 0, "G", ""/*10*/, "MV_PAR02", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "", "SB1", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
	aAdd(aRegs,{"Produto Ate"	  	, "", "",  "MV_CH3", "C",TamSx3("ZZ_COD")[1], TamSx3("ZZ_COD")[2], 0, "G", ""/*10*/, "MV_PAR03", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "", "SB1", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
	aAdd(aRegs,{"Fabricante De"	  	, "", "",  "MV_CH4", "C",TamSx3("A2_COD")[1], TamSx3("A2_COD")[2], 0, "G", ""/*10*/, "MV_PAR04", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "", "SA2", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
	aAdd(aRegs,{"Fabricante Ate"  	, "", "",  "MV_CH5", "C",TamSx3("A2_COD")[1], TamSx3("A2_COD")[2], 0, "G", ""/*10*/, "MV_PAR05", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "", "SA2", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
	aAdd(aRegs,{"Data De"	  		, "", "",  "MV_CH6", "D",TamSx3("VS1_DATORC")[1], TamSx3("VS1_DATORC")[2], 0, "G", ""/*10*/, "MV_PAR06", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "", "", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })
	aAdd(aRegs,{"Data Ate"  		, "", "",  "MV_CH7", "D",TamSx3("VS1_DATORC")[1], TamSx3("VS1_DATORC")[2], 0, "G", ""/*10*/, "MV_PAR07", "", "", "", "", "", "", "", "", ""/*20*/, "", "", "", "", "", "", "", "", "", ""/*30*/, "", "", "", "", "", "", "", "", "", ""/*40*/, aHelp, aHelp, aHelp })

	oPTGENC01 := PTGENC01():New()
	oPTGENC01:AJUSTASX1( cPerg, aRegs )

Return( Nil )
