#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFR012
@author Tiago Rossini Coradini
@since 10/01/2018
@version 1.0
@description Rotina para impressão do relatório de Pedidos de compra com recebimento confirmado 
@obs Ticket: 1446 - Projeto Demandas Compras - Item 2 - Complemento 4
@type function
/*/

User Function BIAFR012()
Local oReport
Local oParam := TParBIAFR012():New()

	If oParam:Box()

		oReport := ReportDef(oParam)
		oReport:PrintDialog()
		
	EndIf
		
Return()


Static Function ReportDef(oParam)
Local oReport
Local oSecFun
Local cQry := GetNextAlias()    

	oReport := TReport():New("BIAFR012", "Pedidos de compra com recebimento confirmado", {|| oParam:Box() }, {|oReport| PrintReport(oReport, cQry, oParam)}, "Pedidos de compra com recebimento confirmado")
		
	oSecFun := TRSection():New(oReport, "Pedidos", cQry)
	TRCell():New(oSecFun, "C7_NUM", cQry, "Numero")
	TRCell():New(oSecFun, "C7_YTPCONF", cQry)
	TRCell():New(oSecFun, "A2_NOME", cQry, "Comprador",,,,{|| UsrFullName((cQry)->C7_USER) })
	TRCell():New(oSecFun, "C7_YDTENV", cQry,,,,,{|| sToD((cQry)->C7_YDTENV) })
	TRCell():New(oSecFun, "C7_YDATCON", cQry,,,,,{|| sToD((cQry)->C7_YDATCON) })
	TRCell():New(oSecFun, "A2_NOME", cQry, "Comprador Conf. Manual",,,,{|| UsrFullName((cQry)->C7_YCOMCON) })
					
Return(oReport)


Static Function PrintReport(oReport, cQry, oParam)
Local oSecFun := oReport:Section(1)
Local cSQL := ""
	
	cSQL := " SELECT C7_NUM, C7_YTPCONF, C7_USER, C7_YDTENV, C7_YDATCON, C7_YCOMCON "
	cSQL += " FROM "+ RetSQLName("SC7")	
	cSQL += " WHERE C7_FILIAL = "+ ValToSQL(xFilial("SC7"))
	cSQL += " AND C7_NUM BETWEEN "+ ValToSQL(oParam:cPedDe) +" AND "+ ValToSQL(oParam:cPedAte)
	cSQL += " AND C7_QUANT > C7_QUJE "
	cSQL += " AND C7_RESIDUO = '' "	
	
	If SubStr(oParam:cTpConf, 1, 1) == "1"
		
		cSQL += " AND C7_YTPCONF = 'A' "
		
	ElseIf SubStr(oParam:cTpConf, 1, 1) == "2"
	
		cSQL += " AND C7_YTPCONF = 'M' "
		
	Else
	
		cSQL += " AND C7_YTPCONF IN ('A', 'M', '') "
	
	EndIf	
	
	cSQL += " AND C7_YDTENV BETWEEN "+ ValToSQL(oParam:dDtEnvDe) +" AND "+ ValToSQL(oParam:dDtEnvAte)
	cSQL += " AND C7_USER BETWEEN "+ ValToSQL(oParam:cComDe) +" AND "+ ValToSQL(oParam:cComAte)			
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY C7_NUM, C7_YTPCONF, C7_USER, C7_YDTENV, C7_YCOMCON, C7_YDATCON "
	cSQL += " ORDER BY C7_NUM, C7_YTPCONF "	
	
	TcQuery cSQL New Alias (cQry)
		
	// Impressão dos parametros na primeira pagina
	oReport:oParamPage := TRParamBoxPage():New(oReport, oParam)	
					
	oSecFun:Print()
									
	(cQry)->(DbCloseArea())
	
Return()