#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFR013
@author Tiago Rossini Coradini
@since 09/03/2018
@version 1.0
@description Rotina para impressão do relatório anual de funcionarios com alterações em exames ocupacionais 
@obs Ticket: 2049
@type function
/*/

User Function BIAFR013()
Local oReport
Local oParam := TParBIAFR013():New()

	If oParam:Box()

		oReport := ReportDef(oParam)
		oReport:PrintDialog()
		
	EndIf
		
Return()


Static Function ReportDef(oParam)
Local oReport
Local oSecFun
Local cQry := GetNextAlias()    

	oReport := TReport():New("BIAFR013", "Funcionários com alterações em exames ocupacionais", {|| oParam:Box() }, {|oReport| PrintReport(oReport, cQry, oParam)}, "Funcionários com alterações em exames ocupacionais")
		
	oSecFun := TRSection():New(oReport, "Funcionarios", cQry)
		
	TRCell():New(oSecFun, "TM4_EXAME", cQry)
	TRCell():New(oSecFun, "TM4_NOMEXA", cQry)
	TRCell():New(oSecFun, "TM5_DTRESU", cQry,,,,,{|| sToD((cQry)->TM5_DTRESU) })
	TRCell():New(oSecFun, "RA_MAT", cQry)
	TRCell():New(oSecFun, "RA_NOME", cQry)
					
Return(oReport)


Static Function PrintReport(oReport, cQry, oParam)
Local oSecFun := oReport:Section(1)
Local cSQL := ""
	
	cSQL := " SELECT TM4_EXAME, TM4_NOMEXA, TM5_DTRESU, RA_MAT, RA_NOME "
	cSQL += " FROM "+ RetSQLName("TM5") + " TM5 "
	cSQL += " INNER JOIN "+ RetSQLName("TM4") + " TM4 "
	cSQL += " ON TM5_EXAME = TM4_EXAME
	cSQL += " INNER JOIN "+ RetSQLName("SRA") + " SRA "
	cSQL += " ON TM5_MAT = RA_MAT "
	cSQL += " WHERE TM5.TM5_FILIAL = "+ ValToSQL(xFilial("TM5"))
	cSQL += " AND TM5_DTRESU BETWEEN "+ ValToSQL(oParam:dDatDe) + " AND " + ValToSQL(oParam:dDatAte)
	cSQL += " AND TM5_INDRES = '2' "
	cSQL += " AND TM5.D_E_L_E_T_ = '' "
	cSQL += " AND TM4_FILIAL = "+ ValToSQL(xFilial("TM4"))
	cSQL += " AND TM4.D_E_L_E_T_ = '' "
	cSQL += " AND SRA.RA_FILIAL = "+ ValToSQL(xFilial("SRA"))
	cSQL += " AND SRA.D_E_L_E_T_ = '' "
	cSQL += " ORDER BY RA_NOME, TM5_DTRESU, TM4_NOMEXA "

	TcQuery cSQL New Alias (cQry)
		
	// Impressão dos parametros na primeira pagina
	oReport:oParamPage := TRParamBoxPage():New(oReport, oParam)	
					
	oSecFun:Print()
									
	(cQry)->(DbCloseArea())
	
Return()