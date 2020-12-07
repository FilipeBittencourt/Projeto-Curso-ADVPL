#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFR005
@author Tiago Rossini Coradini
@since 18/01/2016
@version 2.0
@description Rotina para impressao do relatorio de controle de advertencias
@obs OS: 0687-14 - Francine Araujo
@obs OS: 3983-16 - Claudia Mara
@type Class
/*/

User Function BIAFR005()

	Local oReport
	Private oParam := TParBIAFR005():New()

	If oParam:Box()

		oReport := ReportDef()
		oReport:PrintDialog()

	EndIf

Return()

Static Function ReportDef()
	Local oReport
	Local oSecFun
	Local cQry := GetNextAlias()
	Local cTitRel := "Relatório de Fatos Relevantes"

	oReport := TReport():New("BIAFR005", cTitRel, {|| oParam:Box()}, {|oReport| PrintReport(oReport, cQry)}, cTitRel)


	// Default empressao em paisagem
	oReport:SetLandScape(.T.)

	// Aumenta o tamanho da fonte

	// Imprime cabecalho customizado da secao
	oReport:OnPageBreak({|| fPrintHeader(oReport, oSecFun) })


	oSecFun := TRSection():New(oReport, "Funcionário", cQry)

	// Desabilita impressao padrao do cabecalho da secao
	oSecFun:lHeaderPage := .T.

	// Aumenta o espaco entre as linhas - Salto de linha
	oSecFun:OnPrintLine({|| oReport:SkipLine() })

	TRCell():New(oSecFun, "RA_CLVL", cQry, "CV",, 8)
	TRCell():New(oSecFun, "RAE_MAT", cQry, "Mat.",, 15)
	TRCell():New(oSecFun, "RA_NOME", cQry, "Colaborador",, 45)
	TRCell():New(oSecFun, "RAE_DATA", cQry, "Data",, 15,, {|| sToD((cQry)->RAE_DATA) })
	TRCell():New(oSecFun, "RA_YSEMAIL", cQry, "E-mail Sup.",, 30,, {|| Lower(SubStr((cQry)->RA_YSEMAIL, 1, At("@", (cQry)->RA_YSEMAIL) - 1)) })
	TRCell():New(oSecFun, "FTRELEV", cQry, "Fato Relev.",, 20)
	TRCell():New(oSecFun, "TPADV", cQry, "Tipo Adv.",,18)
	TRCell():New(oSecFun, "RAE_YMOT", cQry, "Motivo",,60)
	TRCell():New(oSecFun, "RAE_DESC", cQry, "Desc. Fato")

Return(oReport)


Static Function PrintReport(oReport, cQry)
	Local oSecFun := oReport:Section(1)
	Local cSQL := ""

	cSQL := " SELECT RA_CLVL, RAE_MAT, RA_NOME, RAE_DATA, RA_YSEMAIL, RAE_SEQ, "
	cSQL += " SUBSTRING(RCC.RCC_CONTEU,3,12) FTRELEV,"  
	cSQL += " CASE RAE_YTPADV        " 
	cSQL += " 	WHEN 'E' THEN 'ESCRITA'" 
	cSQL += "   WHEN 'V' THEN 'VERBAL'"  
	cSQL += "   ELSE RAE_YTPADV"  
	cSQL += " END TPADV," 
	cSQL += " REPLACE(ISNULL(CONVERT(VARCHAR(1024), CONVERT(VARBINARY(1024), RAE_DESC)),''), CHAR(13) + Char(10), '') AS RAE_DESC, "
	cSQL += " RAE_YMOT "
	cSQL += " FROM "+ RetSqlName("RAE") +" RAE "
	cSQL += " INNER JOIN "+ RetSqlName("SRA") +" SRA "
	cSQL += " ON RAE_FILIAL = RA_FILIAL "
	cSQL += " AND RAE_MAT = RA_MAT "
	cSQL += " AND RAE_MAT BETWEEN "+ ValToSQL(oParam:cMatDe) +" AND "+ ValToSQL(oParam:cMatAte)
	cSQL += " AND RAE_DATA BETWEEN "+ ValToSQL(oParam:dDatDe) +" AND "+ ValToSQL(oParam:dDatAte)	
	cSQL += " AND RAE.D_E_L_E_T_ = '' "
	cSQL += " AND RA_CLVL BETWEEN "+ ValToSQL(oParam:cClvlDe) +" AND "+ ValToSQL(oParam:cClvlAte)  
	cSQL += " AND RA_YSEMAIL LIKE "+ ValToSQL("%" + Lower(AllTrim(oParam:cMailSup)) +"%")	
	cSQL += " AND SRA.D_E_L_E_T_ = '' "
	cSQL += " INNER JOIN "+ RetSqlName("RCC") +" RCC "
	cSQL += " 	 ON (RCC_CODIGO = 'S051'" 
	cSQL += " 	AND SUBSTRING(RCC_CONTEU,1,2) = RAE_COD"
	cSQL += " 	AND RCC.D_E_L_E_T_ = '') "
	cSQL += " ORDER BY RA_NOME, RAE_DATA "

	TcQuery cSQL New Alias (cQry)

	// Altera configuracoes da fonte do cabecalho do relatorio
	oReport:oFontHeader:Bold := .T.
	oReport:oFontHeader:nHeight := -12

	oReport:oParamPage := TRParamBoxPage():New(oReport, oParam)

	oSecFun:Print()

	(cQry)->(DbCloseArea())

Return()


// Imprime cabecalho customizado da secao
Static Function fPrintHeader(oReport, oSecFun)

	oReport:SkipLine()
	oReport:FatLine()	
	oReport:SkipLine()

	oSecFun:PrintHeader()

	oReport:SkipLine()
	oReport:FatLine()

	oReport:SkipLine()

Return()