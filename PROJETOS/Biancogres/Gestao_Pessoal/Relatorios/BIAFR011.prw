#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFR011
@author Tiago Rossini Coradini
@since 03/05/2017
@version 1.0
@description Rotina para impressão de beneficiários por funcionário 
@obs OS: 0066-17 - Jessica Alvarenga
@type function
/*/

User Function BIAFR011()
Local oReport
Local oParam := TParBIAFR011():New()

	If oParam:Box()

		oReport := ReportDef(oParam)
		oReport:PrintDialog()
		
	EndIf
		
Return()


Static Function ReportDef(oParam)
Local oReport
Local oSecFun
Local cQry := GetNextAlias()    

	oReport := TReport():New("BIAFR011", "Pensionistas", {|| oParam:Box() }, {|oReport| PrintReport(oReport, cQry, oParam)}, "Pensionistas")
		
	oSecFun := TRSection():New(oReport, "Funcionário", cQry)
	TRCell():New(oSecFun, "RA_MAT", cQry)
	TRCell():New(oSecFun, "RA_NOME", cQry)					
	TRCell():New(oSecFun, "RQ_NOME", cQry)
	TRCell():New(oSecFun, "RQ_NASC", cQry,,,,,{|| sToD((cQry)->RQ_NASC) })
	TRCell():New(oSecFun, "RQ_CIC", cQry)
	TRCell():New(oSecFun, "RQ_YTIPCON", cQry)
	TRCell():New(oSecFun, "RQ_BCDEPBE", cQry)
	TRCell():New(oSecFun, "RQ_CTDEPBE", cQry)	
	TRCell():New(oSecFun, "RQ_DTINI", cQry,,,,,{|| sToD((cQry)->RQ_DTINI) })
	TRCell():New(oSecFun, "RQ_DTFIM", cQry,,,,,{|| sToD((cQry)->RQ_DTFIM) })
	
	// Default empressao em paisagem
	oReport:SetLandScape(.T.)

	// Aumenta o tamanho da fonte
	oReport:nFontBody := 8.5	
			
Return(oReport)


Static Function PrintReport(oReport, cQry, oParam)
Local oSecFun := oReport:Section(1)
Local cSQL := ""
	
	cSQL := " SELECT RA_MAT, RA_NOME, RQ_NOME, RQ_NASC, RQ_CIC, RQ_YTIPCON, RQ_BCDEPBE, RQ_CTDEPBE, RQ_DTINI, RQ_DTFIM "
	cSQL += " FROM "+ RetSQLName("SRQ") + " SRQ "	
	cSQL += " INNER JOIN "+ RetSQLName("SRA") + " SRA "
	cSQL += " ON RQ_MAT = RA_MAT "
	cSQL += " WHERE RQ_FILIAL = "+ ValToSQL(xFilial("SRQ"))
	cSQL += " AND RQ_DTINI <> '' "
	cSQL += " AND SRQ.D_E_L_E_T_ = '' "
	cSQL += " AND RA_FILIAL = "+ ValToSQL(xFilial("SRA"))
	cSQL += " AND RA_SITFOLH <> 'D' "
	cSQL += " AND RA_MAT BETWEEN "+ ValToSQL(oParam:cMatDe) +" AND "+ ValToSQL(oParam:cMatAte)	
	
	If SubStr(oParam:cSitBen, 1, 1) == "1"
		
		cSQL += " AND RQ_DTFIM = '' "
		
	ElseIf SubStr(oParam:cSitBen, 1, 1) == "2"
	
		cSQL += " AND RQ_DTFIM <> '' "
	
	EndIf
		
	cSQL += " AND SRA.D_E_L_E_T_ = '' "	
	cSQL += " ORDER BY RA_MAT, RA_NOME, RQ_ORDEM, RQ_DTINI "

	TcQuery cSQL New Alias (cQry)
		
	// Impressão dos parametros na primeira pagina
	oReport:oParamPage := TRParamBoxPage():New(oReport, oParam)	
					
	oSecFun:Print()
									
	(cQry)->(DbCloseArea())
	
Return()