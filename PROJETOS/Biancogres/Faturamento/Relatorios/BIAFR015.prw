#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFR015
@author Tiago Rossini Coradini
@since 04/06/2018
@version 1.0
@description Rotina para impressão do relatório de companhamento de movimentaçao de amostra 
Ticket: 2626
@type function
/*/

User Function BIAFR015()
Local oReport
Local oParam := TParBIAFR015():New()

	If cEmpAnt $ "01/05"
	
		If oParam:Box()
	
			oReport := ReportDef(oParam)
			oReport:PrintDialog()
			
		EndIf
		
	Else
	
		MsgStop("Empresa não autorizada para impressão do relatorio.", "Bloqueio de Acesso")
	
	EndIf
		
Return()


Static Function ReportDef(oParam)
Local oReport
Local oSecPed
Local cQry := GetNextAlias()    

	oReport := TReport():New("BIAFR015", "Acompanhamento de movimentação de amostra", {|| oParam:Box() }, {|oReport| PrintReport(oReport, cQry, oParam)}, "Acompanhamento de movimentação de amostra")
		
	oSecPed := TRSection():New(oReport, "Pedidos", cQry)
		
	TRCell():New(oSecPed, "C5_NUM", cQry, "Pedido")
	TRCell():New(oSecPed, "C5_EMISSAO", cQry, "Emissão",,,,{|| sToD((cQry)->C5_EMISSAO) })	
	TRCell():New(oSecPed, "C5_CLIENTE", cQry)
	TRCell():New(oSecPed, "C5_LOJACLI", cQry)
	TRCell():New(oSecPed, "A1_NOME", cQry)
	TRCell():New(oSecPed, "C5_VEND1", cQry, "Vendedor")
	TRCell():New(oSecPed, "A3_NREDUZ", cQry, "Nome")
	TRCell():New(oSecPed, "DT_INTEGRA", cQry, "Integração",,,,{|| sToD((cQry)->DT_INTEGRA) })	
	TRCell():New(oSecPed, "DT_SEPARA", cQry, "Separação",,,,{|| sToD((cQry)->DT_SEPARA) })
	TRCell():New(oSecPed, "C6_DATFAT", cQry, "Faturamento",,,,{|| sToD((cQry)->C6_DATFAT) })
					
Return(oReport)


Static Function PrintReport(oReport, cQry, oParam)
Local oSecPed := oReport:Section(1)
Local cSQL := ""
	
	cSQL := " SELECT C5_NUM, C5_EMISSAO, "
	cSQL += " C5_CLIENTE, C5_LOJACLI, (SELECT A1_NOME FROM "+ RetSQLName("SA1") +" WHERE A1_FILIAL = '' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND D_E_L_E_T_ = '') AS A1_NOME, "
	cSQL += " C5_VEND1, (SELECT A3_NREDUZ FROM "+ RetSQLName("SA3") +" WHERE A3_FILIAL = '' AND A3_COD = C5_VEND1 AND D_E_L_E_T_ = '') AS A3_NREDUZ, "
	cSQL += " ISNULL(CONVERT(VARCHAR(8), MIN(cca_data_emissao), 112), '') AS DT_INTEGRA, ISNULL(CONVERT(VARCHAR(8), MAX(cca_data_pronta), 112), '') AS DT_SEPARA, " 
	cSQL += " MAX(C6_DATFAT) AS C6_DATFAT "
	cSQL += " FROM "+ RetSQLName("SC5") +" SC5 "
	cSQL += " INNER JOIN "+ RetSQLName("SC6") +" SC6 "
	cSQL += " ON C5_FILIAL = C6_FILIAL "
	cSQL += " AND C5_NUM = C6_NUM "
	cSQL += " INNER JOIN " + If (cEmpAnt == "01", "DADOSEOS", "DADOS_05_EOS") + ".dbo.cep_ctrl_amostra "
	cSQL += " ON C6_YECONAM = cca_codigo COLLATE Latin1_General_BIN "
	cSQL += " WHERE C5_FILIAL = "+ ValToSQL(xFilial("SC5"))
	cSQL += " AND C5_EMISSAO BETWEEN "+ ValToSQL(oParam:dDatDe) + " AND " + ValToSQL(oParam:dDatAte)
	cSQL += " AND C5_NUM BETWEEN "+ ValToSQL(oParam:cPedDe) + " AND " + ValToSQL(oParam:cPedAte)
	cSQL += " AND C5_YAPROV <> '' "
	cSQL += " AND C5_YSUBTP IN('A ', 'F ','M ') "
	cSQL += " AND C5_YCONF = 'S' "
	cSQL += " AND SC5.D_E_L_E_T_ = '' "
	cSQL += " AND C6_YECONAM <> '' "
	cSQL += " AND C6_YSTTSAM NOT IN ('F','R') "
	cSQL += " AND SC6.D_E_L_E_T_ = '' "
	cSQL += " AND (cca_data_cancelamento = '' OR cca_data_cancelamento IS NULL) "
	cSQL += " AND cca_codigo IS NOT NULL "
	cSQL += " GROUP BY C5_NUM, C5_EMISSAO, C5_CLIENTE, C5_LOJACLI, C5_VEND1 "
	cSQL += " ORDER BY C5_EMISSAO, C5_NUM "

	TcQuery cSQL New Alias (cQry)
		
	// Impressão dos parametros na primeira pagina
	oReport:oParamPage := TRParamBoxPage():New(oReport, oParam)	
					
	oSecPed:Print()
									
	(cQry)->(DbCloseArea())
	
Return()