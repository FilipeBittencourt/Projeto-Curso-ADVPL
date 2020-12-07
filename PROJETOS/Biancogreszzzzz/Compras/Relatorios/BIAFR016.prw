#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFR016
@author Tiago Rossini Coradini
@since 01/08/2018
@version 1.0
@description Rotina para impressão do relatório de pedidos de compra com auditoria 
@obs Ticket: 7049
@type function
/*/

User Function BIAFR016()
Local oReport
Local oParam := TParBIAFR016():New()

	If oParam:Box()

		oReport := ReportDef(oParam)
		oReport:PrintDialog()
		
	EndIf
		
Return()


Static Function ReportDef(oParam)
Local oReport
Local oSecPed
Local cQry := GetNextAlias()    

	oReport := TReport():New("BIAFR016", "Pedidos de compra com auditoria", {|| oParam:Box() }, {|oReport| PrintReport(oReport, cQry, oParam)}, "Pedidos de compra com auditoria")
		
	oSecPed := TRSection():New(oReport, "Pedidos", cQry)
	TRCell():New(oSecPed, "C7_EMISSAO", cQry, "Emissão",,,,{|| sToD((cQry)->C7_EMISSAO) })
	TRCell():New(oSecPed, "C7_NUM", cQry, "Pedido",, 10)
	TRCell():New(oSecPed, "C7_NUMCOT", cQry, "Cotação",, 10)
	TRCell():New(oSecPed, "C7_PRODUTO", cQry,,, 15)
	TRCell():New(oSecPed, "C7_DESCRI", cQry,,, 50)
	TRCell():New(oSecPed, "C7_QUANT", cQry)
	TRCell():New(oSecPed, "C7_UM", cQry)
	TRCell():New(oSecPed, "C7_DATPRF", cQry, "Entrega",,,,{|| sToD((cQry)->C7_DATPRF) })
	TRCell():New(oSecPed, "CE_MOTIVO", cQry)
	TRCell():New(oSecPed, "C7_YOBSCOM", cQry,,, 50)
	TRCell():New(oSecPed, "C8_YOBS", cQry,,, 50)
	
Return(oReport)


Static Function PrintReport(oReport, cQry, oParam)
Local oSecPed := oReport:Section(1)
Local cSQL := ""

	cSQL := " SELECT C7_EMISSAO, C7_NUM, C7_NUMCOT, LTRIM(C7_PRODUTO) AS C7_PRODUTO, LTRIM(C7_DESCRI) AS C7_DESCRI, C7_QUANT, C7_UM, C7_DATPRF, CE_MOTIVO, C7_YOBSCOM, C8_YOBS "
	cSQL += " FROM "+ RetSQLName("SC7") + " SC7 "
	cSQL += " INNER JOIN "+ RetSQLName("SC8") + " SC8 "
	cSQL += " ON C7_NUM = C8_NUMPED "
	cSQL += " AND C7_ITEM = C8_ITEMPED "
	cSQL += " INNER JOIN "+ RetSQLName("SCE") + " SCE "
	cSQL += " ON C8_NUM = CE_NUMCOT "
	cSQL += " AND C8_ITEM = CE_ITEMCOT "
	cSQL += " WHERE C7_FILIAL = "+ ValToSQL(xFilial("SC7"))
	cSQL += " AND C7_EMISSAO BETWEEN "+ ValToSQL(oParam:dEmiDe) +" AND "+ ValToSQL(oParam:dEmiAte)
	cSQL += " AND C7_NUM BETWEEN "+ ValToSQL(oParam:cPedDe) +" AND "+ ValToSQL(oParam:cPedAte)
	cSQL += " AND C7_NUMCOT BETWEEN "+ ValToSQL(oParam:cCotDe) +" AND "+ ValToSQL(oParam:cCotAte)
	cSQL += " AND SC7.D_E_L_E_T_ = '' "
	cSQL += " AND C8_FILIAL = "+ ValToSQL(xFilial("SC8"))
	cSQL += " AND SC8.D_E_L_E_T_ = '' "
	cSQL += " AND CE_FILIAL = "+ ValToSQL(xFilial("SCE"))
	cSQL += " AND SCE.D_E_L_E_T_ = '' "
	cSQL += " ORDER BY C7_EMISSAO, C7_NUM, C7_NUMCOT, C7_PRODUTO, C7_DESCRI, C7_DATPRF "
	
	TcQuery cSQL New Alias (cQry)
		
	// Impressão dos parametros na primeira pagina
	oReport:oParamPage := TRParamBoxPage():New(oReport, oParam)	
					
	oSecPed:Print()
									
	(cQry)->(DbCloseArea())
	
Return()