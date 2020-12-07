#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFR009
@author Tiago Rossini Coradini
@since 05/12/2016
@version 2.0
@description Rotina para impressão de pedidos de venda, cancelados por eliminação de residuo 
@obs OS: 3753-16 - Claudeir Fadini
@type function
/*/

User Function BIAFR009()
Local oReport
Local oParam := TParBIAFR009():New()

	If cEmpAnt $ '01_05'
	
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

	oReport := TReport():New("BIAFR009", "Pedidos Cancelados por Resíduo", {|| oParam:Box() }, {|oReport| PrintReport(oReport, cQry, oParam)}, "Pedidos Cancelados por Resíduo")

	// Default empressao em paisagem
	oReport:SetLandScape(.T.)
		
	oSecPed := TRSection():New(oReport, "Pedidos", {cQry})
	
	TRCell():New(oSecPed, "C5_NUM", cQry, "Pedido",, 8)
	TRCell():New(oSecPed, "C5_YLINHA", cQry, "Linha",,10,, {|| NGRetSX3Box("C5_YLINHA", (cQry)->C5_YLINHA) })
	TRCell():New(oSecPed, "C5_VEND1", cQry, "Repres",, 10)
	TRCell():New(oSecPed, "A3_NREDUZ", cQry, "Nome",, 20)
	TRCell():New(oSecPed, "A1_COD", cQry, "Cliente")
	TRCell():New(oSecPed, "A1_NOME",cQry, "Nome",, 45)
	TRCell():New(oSecPed, "A1_EST", cQry)
	TRCell():New(oSecPed, "A1_YTPSEG", cQry)
	TRCell():New(oSecPed, "B1_COD", cQry, "Produto")
	TRCell():New(oSecPed, "B1_DESC", cQry,,, 45)
	TRCell():New(oSecPed, "B1_YPCGMR3", cQry)
	TRCell():New(oSecPed, "ZZ6_DESC", cQry)                                                                                      
	TRCell():New(oSecPed, "C6_QTDVEN", cQry, "Saldo Canc.")
	TRCell():New(oSecPed, "C5_EMISSAO", cQry,,,,,{|| sToD((cQry)->C5_EMISSAO) })		                                                                                               
	TRCell():New(oSecPed, "C6_YDTRESI", cQry,,,,,{|| sToD((cQry)->C6_YDTRESI) })		                                                                                               
	TRCell():New(oSecPed, "X5_DESCRI", cQry, "Motivo")
	TRCell():New(oSecPed, "C6_YOBSMOT", cQry)
	
	TRFunction():New(oSecPed:Cell("C6_QTDVEN"), NIL, "SUM", TRBreak():New(oSecPed, ".T.", ""), NIL, NIL, NIL, .F., .F.)	
			
Return(oReport)


Static Function PrintReport(oReport, cQry, oParam)
Local oSecPed	:= oReport:Section(1)
Local cSQL		:= ""
LOCAL ENTER		:= CHR(13)+CHR(10)
	
	cSQL := " SELECT CASE WHEN C5_YPEDORI = '' THEN C5_NUM ELSE C5_YPEDORI END AS C5_NUM, C5_YLINHA, " + ENTER
	cSQL += " ISNULL(SA1.A1_COD, SA1_LM.A1_COD) AS A1_COD, RTRIM(ISNULL(SA1.A1_NOME, SA1_LM.A1_NOME)) AS A1_NOME, " + ENTER 
	cSQL += " ISNULL(SA1.A1_EST, SA1_LM.A1_EST) AS A1_EST, " + ENTER
	cSQL += " (SELECT Z41_DESCR FROM Z41010 WHERE Z41_FILIAL = '' AND Z41_TPSEG = ISNULL(SA1.A1_YTPSEG, SA1_LM.A1_YTPSEG) AND D_E_L_E_T_ = '') AS A1_YTPSEG, " + ENTER
	cSQL += " B1_COD, RTRIM(B1_DESC) AS B1_DESC, " + ENTER
	cSQL += " (SELECT X5_DESCRI FROM "+ RetSQLName("SX5") +" WHERE X5_FILIAL = "+ ValToSQL(xFilial("SX5")) +" AND X5_TABELA = 'ZH' AND X5_CHAVE = B1_YPCGMR3 AND D_E_L_E_T_ = '') AS B1_YPCGMR3, " + ENTER
	cSQL += " (SELECT ZZ6_DESC FROM ZZ6010 WHERE ZZ6_FILIAL = '' AND ZZ6_COD = B1_YFORMAT AND D_E_L_E_T_ = '') AS ZZ6_DESC, " + ENTER
	cSQL += " (C6_QTDVEN - C6_QTDENT) AS C6_QTDVEN, C5_EMISSAO, C6_YDTRESI, " + ENTER
	cSQL += " RTRIM(ISNULL( " + ENTER
	cSQL += " CASE " + ENTER
	cSQL += "	WHEN C6_YMOTIVO = '001' THEN 'SUBSTITUIÇÃO DE PEDIDO' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '002' THEN 'REPROVADO PELO FINANCEIRO' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '003' THEN 'SOLICITADO PELO REPRESENTANTE/CLIENTE' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '004' THEN 'PEDIDOS PARADOS EM CARTEIRA' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '005' THEN 'PRODUTO SEM ESTOQUE / FORA DE LINHA' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '006' THEN 'PEDIDO EM DUPLICIDADE' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '007' THEN 'ORÇAMENTO ENVIADO ERRADO' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '008' THEN 'ALTERAÇÃO ST' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '009' THEN 'ORÇAMENTO RECUSADO' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '010' THEN 'PEDIDO DUPLICADO LM' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '011' THEN 'SALDO DE PEDIDO À INDUSTRIALIZAR' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '012' THEN 'CANCELAMENTO DE SALDO SOLICITADO PELO REPRESENTANTE' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '013' THEN 'CANCELAMENTO DE SALDO REALIZADO PELO ATENDENTE' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '014' THEN 'CLIENTE DESISTIU DA MERCADORIA' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '015' THEN 'PEDIDO ENVIADO ERRADO POR PARTE DO REPRESENTANTE' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '016' THEN 'SALDO DE ITEM DE PEDIDO' " + ENTER
	cSQL += "	WHEN C6_YMOTIVO = '017' THEN 'PRODUTO NÃO LOCALIZADO NO ESTOQUE' " + ENTER
	cSQL += "	WHEN C6_YMOTIVO = '018' THEN 'NAO INCLUIR A NORMA' " + ENTER
	cSQL += " 	WHEN C6_YMOTIVO = '019' THEN 'PRODUTO REMANEJADO' " + ENTER
	cSQL += " 	ELSE SX5.X5_DESCRI " + ENTER
	cSQL += " END " + ENTER
	cSQL += " , '-')) AS X5_DESCRI, C6_YOBSMOT, " + ENTER
	cSQL += " CASE WHEN C5_VEND1 = '999999' THEN " + ENTER
	cSQL += " ( " + ENTER
	cSQL += " 	SELECT C5_VEND1 " + ENTER 
	cSQL += " 	FROM SC5070 " + ENTER
	cSQL += " 	WHERE C5_YPEDORI = CASE WHEN SC5.C5_YPEDORI = '' THEN SC5.C5_NUM ELSE SC5.C5_YPEDORI END " + ENTER
	cSQL += " 	AND C5_YEMPPED = "+ ValToSQL(cEmpAnt)+" " + ENTER
	cSQL += " 	AND D_E_L_E_T_ = '' " + ENTER
	cSQL += " ) " + ENTER
	cSQL += " ELSE C5_VEND1 END AS C5_VEND1, " + ENTER
	cSQL += " ( " + ENTER
	cSQL += " 	SELECT A3_NREDUZ " + ENTER 
	cSQL += " 	FROM " + RetSQLName("SA3")+ " " + ENTER
	cSQL += " 	WHERE A3_COD = CASE WHEN C5_VEND1 = '999999' THEN " + ENTER
	cSQL += " 					( " + ENTER
	cSQL += " 						SELECT C5_VEND1 " + ENTER 
	cSQL += " 						FROM SC5070 " + ENTER
	cSQL += " 						WHERE C5_YPEDORI = CASE WHEN SC5.C5_YPEDORI = '' THEN SC5.C5_NUM ELSE SC5.C5_YPEDORI END " + ENTER
	cSQL += " 						AND C5_YEMPPED = "+ ValToSQL(cEmpAnt)+" " + ENTER
	cSQL += " 						AND D_E_L_E_T_ = '' " + ENTER
	cSQL += " 					) " + ENTER
	cSQL += " 					ELSE C5_VEND1 END " + ENTER
	cSQL += " 	AND D_E_L_E_T_ = '' " + ENTER
	cSQL += " ) AS A3_NREDUZ " + ENTER
	cSQL += " FROM VW_SC5 SC5 "  + ENTER
	cSQL += " INNER JOIN VW_SC6 SC6 " + ENTER
	cSQL += " ON C5_NUM = C6_NUM " + ENTER
	cSQL += " AND C5_CLIENTE = C6_CLI " + ENTER
	cSQL += " AND C5_LOJACLI = C6_LOJA " + ENTER
	cSQL += " AND C5_YEMP = C6_YEMP " + ENTER
	cSQL += " AND C5_YEMPORI = C6_YEMPORI " + ENTER
	cSQL += " INNER JOIN "+ RetSQLName("SB1") +" SB1 " + ENTER
	cSQL += " ON C6_PRODUTO = B1_COD " + ENTER
	cSQL += " AND SB1.D_E_L_E_T_ = '' " + ENTER
	cSQL += " LEFT JOIN "+ RetSQLName("SA1") +" SA1 " + ENTER
	cSQL += " ON SA1.A1_COD = C5_CLIENTE " + ENTER
	cSQL += " AND C5_CLIENTE <> '010064' " + ENTER
	cSQL += " AND SA1.D_E_L_E_T_ = '' " + ENTER
	cSQL += " LEFT JOIN "+ RetSQLName("SA1") +" SA1_LM " + ENTER
	cSQL += " ON SA1_LM.A1_COD = C5_YCLIORI " + ENTER
	cSQL += " AND C5_CLIENTE = '010064' " + ENTER
	cSQL += " AND SA1_LM.D_E_L_E_T_ = '' " + ENTER
	cSQL += " LEFT JOIN "+ RetSQLName("SX5") +" SX5 " + ENTER
	cSQL += " ON X5_TABELA = 'ZZ' " + ENTER
	cSQL += " AND X5_CHAVE = C6_YMOTIVO " + ENTER
	cSQL += " AND SX5.D_E_L_E_T_ = '' " + ENTER
	cSQL += " WHERE C5_FILIAL = "+ ValToSQL(xFilial("SC5"))+" " + ENTER
	cSQL += " AND C6_FILIAL = "+ ValToSQL(xFilial("SC6"))+" " + ENTER
	cSQL += " AND SUBSTRING(C5_YEMP, 1, 2) = "+ ValToSQL(cEmpAnt)+" " + ENTER
	cSQL += " AND C5_TIPO = 'N' " + ENTER
	cSQL += " AND C6_BLQ = 'R' " + ENTER
	cSQL += " AND C6_YDTRESI BETWEEN "+ ValToSQL(oParam:dDatDe) + " AND "+ ValToSQL(oParam:dDatAte)+" " + ENTER
	cSQL += " AND B1_TIPO = 'PA'"  + ENTER
	cSQL += " AND B1_COD BETWEEN "+ ValToSQL(oParam:cPrdDe) +" AND "+ ValToSQL(oParam:cPrdAte)+" " + ENTER
	cSQL += " AND SUBSTRING(B1_COD, 1, 1) >= 'A'"  + ENTER
	cSQL += " AND SUBSTRING(B1_COD, 1, 2) NOT IN ('AB', 'AC', 'AD', 'AE', 'AF')"  + ENTER
	cSQL += " AND ISNULL(SA1.A1_COD, SA1_LM.A1_COD) BETWEEN "+ ValToSQL(oParam:cCliDe) +" AND "+ ValToSQL(oParam:cCliAte)+" " + ENTER
	cSQL += " AND CASE WHEN C5_VEND1 = '999999' THEN"  + ENTER 
	cSQL += " ("  + ENTER
	cSQL += " 	SELECT C5_VEND1"  + ENTER 
	cSQL += " 	FROM SC5070 " + ENTER
	cSQL += " 	WHERE C5_YPEDORI = CASE WHEN SC5.C5_YPEDORI = '' THEN SC5.C5_NUM ELSE SC5.C5_YPEDORI END"  + ENTER
	cSQL += " 	AND C5_YEMPPED = "+ ValToSQL(cEmpAnt)+" AND D_E_L_E_T_ = ''" + ENTER
	cSQL += " ) " + ENTER
	cSQL += " ELSE C5_VEND1 END BETWEEN "+ ValToSQL(oParam:cVenDe) +" AND "+ ValToSQL(oParam:cVenAte)+" " + ENTER
	cSQL += " AND F4_DUPLIC = CASE WHEN "+ ValToSQL(SubStr(oParam:cDupl, 1, 1)) +" = '2' THEN 'S' WHEN "+ ValToSQL(SubStr(oParam:cDupl, 1, 1)) +" = '3' THEN 'N' ELSE F4_DUPLIC END " + ENTER
	
	IF alltrim(cRepAtu) <> ""
		cSQL += "		AND	C5_VEND1 = '"+cRepAtu+"'  " 	 + ENTER
	END IF
	cSQL += " ORDER BY C6_YDTRESI, A1_NOME, B1_DESC "  + ENTER
	TcQuery cSQL New Alias (cQry)
	
	// Impressão dos parametros na primeira pagina
	oReport:oParamPage := TRParamBoxPage():New(oReport, oParam)	
	
	oSecPed:Print()
									
	(cQry)->(DbCloseArea())
	
Return()