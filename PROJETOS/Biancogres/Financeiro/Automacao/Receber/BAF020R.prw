#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF020R
@author Tiago Rossini Coradini
@since 01/04/2019
@project Automação Financeira
@version 1.0
@description Rotina de impressao de deposito identificado
@type function
/*/

User Function BAF020R()
Local oReport
Local oParam := TParBAF020R():New()

	If oParam:Box()

		oReport := ReportDef(oParam)
		oReport:PrintDialog()
		
	EndIf
		
Return()


Static Function ReportDef(oParam)
Local oReport
Local oSecDep
Local oSecTit
Local cQry := GetNextAlias()

	oReport := TReport():New("BAF020R", "Depóstio Identificado", {|| oParam:Box() }, {|oReport| PrintReport(oReport, cQry, oParam)}, "Depóstio Identificado")
		
	oSecDep := TRSection():New(oReport, "Deposito", cQry)
	TRCell():New(oSecDep, "ZK8_NUMERO", cQry)
	TRCell():New(oSecDep, "ZK8_GRPVEN", cQry)
	TRCell():New(oSecDep, "ZK8_CODCLI", cQry)
	TRCell():New(oSecDep, "ZK8_VENCDE", cQry,,,,,{|| sToD((cQry)->ZK8_VENCDE) })
	TRCell():New(oSecDep, "ZK8_VENCAT", cQry,,,,,{|| sToD((cQry)->ZK8_VENCAT) })
	TRCell():New(oSecDep, "ZK8_DATDPI", cQry,,,,,{|| sToD((cQry)->ZK8_DATDPI) })
	TRCell():New(oSecDep, "ZK8_DATA", cQry,,,,,{|| sToD((cQry)->ZK8_DATA) })
	TRCell():New(oSecDep, "ZK8_HORA", cQry)
	TRCell():New(oSecDep, "ZK8_USER", cQry)
	TRCell():New(oSecDep, "ZK8_STATUS", cQry)

	oSecTit := TRSection():New(oSecDep, "Titulo", cQry)
	TRCell():New(oSecTit, "E1_PREFIXO", cQry)
	TRCell():New(oSecTit, "E1_NUM", cQry)
	TRCell():New(oSecTit, "E1_PARCELA", cQry)
	TRCell():New(oSecTit, "E1_PREFIXO", cQry)
	TRCell():New(oSecTit, "E1_TIPO", cQry)
	TRCell():New(oSecTit, "E1_CLIENTE", cQry)
	TRCell():New(oSecTit, "E1_LOJA", cQry)
	TRCell():New(oSecTit, "E1_NOMCLI", cQry)
	TRCell():New(oSecTit, "E1_VENCTO", cQry,,,,,{|| sToD((cQry)->E1_VENCTO) })	
	TRCell():New(oSecTit, "E1_SALDO", cQry)
	
	oBreak := TRBreak():New(oSecDep, oSecDep:Cell("ZK8_NUMERO"))//, "Totais")

	oTot := TRFunction():New(oSecTit:Cell("E1_SALDO"),NIL,"SUM",oBreak,NIL,NIL,NIL,.F.,.F.)
	oTot:SetTotalInLine(.F.)	

	TRFunction():New(oSecTit:Cell("E1_NUM"),NIL,"COUNT",oBreak,NIL,NIL,NIL,.F.,.F.)
	TRFunction():New(oSecTit:Cell("E1_SALDO"),NIL,"SUM",oBreak,NIL,NIL,NIL,.F.,.F.)	
	
Return(oReport)


Static Function PrintReport(oReport, cQry, oParam)
Local oSecDep := oReport:Section(1)
Local oSecTit := oReport:Section(1):Section(1)
Local cSQL := ""

	cSQL := " SELECT ZK8_NUMERO, ZK8_GRPVEN, ZK8_CODCLI, ZK8_VENCDE, ZK8_VENCAT, ZK8_DATDPI, ZK8_DATA, ZK8_HORA, ZK8_USER, ZK8_STATUS, "
	cSQL += " E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_VENCTO, E1_SALDO "
	cSQL += " FROM "+ RetSQLName("ZK8") + " ZK8 "
	cSQL += " INNER JOIN "+ RetSQLName("SE1") + " SE1 "
	cSQL += " ON ZK8_NUMERO = E1_YNUMDPI "
	cSQL += " INNER JOIN "+ RetSQLName("SA1") + " SA1 "
	cSQL += " ON SE1.E1_CLIENTE = A1_COD "
	cSQL += " AND E1_LOJA = A1_LOJA "
	cSQL += " WHERE ZK8_FILIAL = "+ ValToSQL(xFilial("ZK8"))
	cSQL += " AND ZK8_NUMERO BETWEEN "+ ValToSQL(oParam:cNumeroDe) +" AND "+ ValToSQL(oParam:cNumeroAte)
	cSQL += " AND ZK8_GRPVEN BETWEEN "+ ValToSQL(oParam:cGrpCliDe) +" AND "+ ValToSQL(oParam:cGrpCliAte)
	cSQL += " AND ZK8_CODCLI BETWEEN "+ ValToSQL(oParam:cCodCliDe) +" AND "+ ValToSQL(oParam:cCodCliAte)
	cSQL += " AND ZK8_VENCDE >= "+ ValToSQL(oParam:dVenctoDe)
	cSQL += " AND ZK8_VENCAT <= "+ ValToSQL(oParam:dVenctoAte)
	cSQL += " AND ZK8_DATDPI BETWEEN "+ ValToSQL(oParam:dDepDe) +" AND "+ ValToSQL(oParam:dDepiAte)
	cSQL += " AND ZK8.D_E_L_E_T_ = '' "
	cSQL += " AND E1_FILIAL = "+ ValToSQL(xFilial("SE1"))
	cSQL += " AND SE1.D_E_L_E_T_ = '' "
	cSQL += " AND A1_FILIAL = "+ ValToSQL(xFilial("SA1"))
	cSQL += " AND SA1.D_E_L_E_T_ = '' "
	cSQL += " ORDER BY ZK8_NUMERO, E1_CLIENTE, E1_LOJA, E1_VENCTO, E1_PREFIXO, E1_NUM, E1_PARCELA "

	TcQuery cSQL New Alias (cQry)
		
	oSecTit:SetParentQuery()
	oSecTit:SetParentFilter({|cParam| (cQry)->ZK8_NUMERO >= cParam .And. (cQry)->ZK8_NUMERO <= cParam}, {|| (cQry)->ZK8_NUMERO})

	oReport:oParamPage := TRParamBoxPage():New(oReport, oParam)	
					
	oSecDep:Print()
									
	(cQry)->(DbCloseArea())
	
Return()