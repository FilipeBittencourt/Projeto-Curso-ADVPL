#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TVistoriaObraEngenharia
@author Tiago Rossini Coradini
@since 19/09/2019
@version 1.0
@description Classe para Inclusão de Vistorias em Obras de Engenharia
@obs Ticket: 19122
@type class
/*/

Class TVistoriaObraEngenharia From LongClassName 
	
	Data dEmiDe
	Data dEmiAte
	
	Data oTermo
	Data oWorkFlow
	
	Method New() Constructor
	Method Process()
	Method Exist(dEmissao, cCliente, cLoja, cNumObr, cDoc, cSerie, cProduto, cItem)
	Method GetNextNum()
	Method CreateTerm()
	Method SendWorkFlow()

EndClass


Method New() Class TVistoriaObraEngenharia
	
	::dEmiDe := dDataBase
	::dEmiAte := dDataBase
	
	::oTermo := TTermoVistoriaObraEngenharia():New()
	::oWorkflow := TWorkflowVistoriaObraEngenharia():New()
	
Return()


Method Process() Class TVistoriaObraEngenharia
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT D2_EMISSAO, D2_CLIENTE, D2_LOJA, F2_VEND1, D2_DOC, D2_SERIE, D2_COD, D2_ITEM, D2_LOTECTL, D2_QUANT,
	cSQL += " ISNULL(
	cSQL += " (
	cSQL += " 	SELECT ZZO_NUM
	cSQL += " 	FROM "+ RetFullName("ZZO", "01") +" AS ZZO
	cSQL += " 	INNER JOIN "+ RetFullName("Z68", "01") +" AS Z68
	cSQL += " 	ON ZZO_NUM = Z68_NUMZZO
	cSQL += " 	WHERE ZZO_FILIAL = " + ValToSQL(cFilAnt)
	cSQL += " 	AND ZZO.D_E_L_E_T_ = ''
	cSQL += " 	AND Z68_FILIAL = " + ValToSQL(cFilAnt)
	cSQL += " 	AND Z68_NUM + Z68_REV = 
	cSQL += " 	(
	cSQL += " 		SELECT C5_YNPRENG
	cSQL += " 		FROM "+ RetSQLName("SC5")
	cSQL += " 		WHERE C5_FILIAL = " + ValToSQL(xFilial("SC5"))
	cSQL += " 		AND C5_NUM = D2_PEDIDO
	cSQL += " 		AND D_E_L_E_T_ = ''
	cSQL += " 	)
	cSQL += " 	AND Z68.D_E_L_E_T_ = ''	
	cSQL += " ), '') AS ZZO_NUM
	cSQL += " FROM "+ RetSQLName("SD2") +" AS SD2
	cSQL += " INNER JOIN
	cSQL += " (
	cSQL += " 	SELECT D2_FILIAL AS FILIAL, D2_EMISSAO AS EMISSAO, D2_CLIENTE AS CLIENTE, D2_LOJA AS LOJA, D2_DOC AS DOC, D2_SERIE AS SERIE, D2_COD AS COD, D2_TIPO AS TIPO, D2_LOTECTL AS LOTECTL
	cSQL += " 	FROM "+ RetSQLName("SD2") +" AS SD2
	cSQL += " 	INNER JOIN "+ RetSQLName("SA1") +" AS SA1
	cSQL += " 	ON D2_CLIENTE = A1_COD
	cSQL += " 	AND A1_LOJA = A1_LOJA
	cSQL += " 	INNER JOIN "+ RetSQLName("SF4") +" AS SF4
	cSQL += " 	ON D2_TES = F4_CODIGO
	cSQL += " 	WHERE D2_FILIAL = " + ValToSQL(xFilial("SD2"))
	cSQL += " 	AND D2_TIPO = 'N'
	cSQL += " 	AND D2_EMISSAO BETWEEN " + ValToSQL(::dEmiDe) + " AND " + ValToSQL(::dEmiAte) 
	cSQL += " 	AND D2_YEMP = '0101'
	cSQL += " 	AND D2_GRUPO = 'PA'
	cSQL += " 	AND SD2.D_E_L_E_T_ = ''
	cSQL += " 	AND A1_FILIAL = " + ValToSQL(xFilial("SA1"))
	cSQL += " 	AND A1_YTPSEG = 'E'
	cSQL += " 	AND A1_MSBLQL <> '1'
	cSQL += " 	AND SA1.D_E_L_E_T_ = ''
	cSQL += " 	AND F4_FILIAL = " + ValToSQL(xFilial("SF4"))
	cSQL += " 	AND F4_DUPLIC = 'S'
	cSQL += " 	AND SF4.D_E_L_E_T_ = ''
	
	//Ticket 27390 - Correção para que os 1000m2 avaliados sejam considerados no item do pedido de venda, e não no faturamento
	cSQL += " 		  AND (SELECT SUM(C6_QTDVEN) FROM " + RetSQLName("SC6") + " SC6I "
	cSQL += " 		   		WHERE C6_NUM = D2_PEDIDO
	cSQL += " 		    	AND C6_FILIAL = D2_FILIAL
	cSQL += " 		    	AND C6_PRODUTO = D2_COD
	cSQL += " 				AND C6_ITEM = D2_ITEMPV
	cSQL += " 				AND SC6I.D_E_L_E_T_ = '') > 1000
	cSQL += " 	GROUP BY D2_FILIAL, D2_EMISSAO, D2_CLIENTE, D2_LOJA, D2_DOC, D2_SERIE, D2_COD, D2_TIPO, D2_LOTECTL
	
	//Ticket 26600: Solicitação Camila para alteração para acima de 1000m2
	//cSQL += " 	HAVING SUM(D2_QUANT) > 1000
	cSQL += " ) AS TMP
	cSQL += " ON D2_FILIAL = FILIAL 
	cSQL += " AND D2_DOC = DOC
	cSQL += " AND D2_SERIE = SERIE
	cSQL += " AND D2_CLIENTE = CLIENTE
	cSQL += " AND D2_LOJA = LOJA
	cSQL += " AND D2_COD = COD
	cSQL += " AND D2_TIPO = TIPO
	cSQL += " AND D2_LOTECTL = LOTECTL
	cSQL += " AND D2_EMISSAO = EMISSAO
	cSQL += " INNER JOIN "+ RetSQLName("SF2") +" AS SF2
	cSQL += " ON D2_FILIAL = F2_FILIAL
	cSQL += " AND D2_DOC = F2_DOC
	cSQL += " AND D2_SERIE = F2_SERIE
	cSQL += " AND D2_CLIENTE = F2_CLIENTE
	cSQL += " AND D2_LOJA = D2_LOJA
	cSQL += " AND D2_FORMUL = F2_FORMUL
	cSQL += " AND D2_TIPO = F2_TIPO
	cSQL += " WHERE SD2.D_E_L_E_T_ = ''
	cSQL += " AND F2_VEND1 <> '999999'
	cSQL += " AND SF2.D_E_L_E_T_ = ''
	
	TcQuery cSQL New Alias (cQry)		  			
	
	While (cQry)->(!Eof())
		
		If !::Exist((cQry)->D2_EMISSAO, (cQry)->D2_CLIENTE, (cQry)->D2_LOJA, (cQry)->ZZO_NUM, (cQry)->D2_DOC, (cQry)->D2_SERIE, (cQry)->D2_COD, (cQry)->D2_ITEM)
		
			RecLock("ZKS", .T.)
			
				ZKS->ZKS_FILIAL := xFilial("ZKS")
				ZKS->ZKS_NUMERO := ::GetNextNum()
				ZKS->ZKS_STATUS := "1"
				ZKS->ZKS_DATA := sToD((cQry)->D2_EMISSAO)
				ZKS->ZKS_CLIENT := (cQry)->D2_CLIENTE
				ZKS->ZKS_LOJA := (cQry)->D2_LOJA
				ZKS->ZKS_NUMOBR := (cQry)->ZZO_NUM				
				ZKS->ZKS_VEND := (cQry)->F2_VEND1
				ZKS->ZKS_DOC := (cQry)->D2_DOC
				ZKS->ZKS_SERIE := (cQry)->D2_SERIE
				ZKS->ZKS_PRODUT := (cQry)->D2_COD
				ZKS->ZKS_ITEM := (cQry)->D2_ITEM
				ZKS->ZKS_LOTE := (cQry)->D2_LOTECTL				
				ZKS->ZKS_QUANT := (cQry)->D2_QUANT
				ZKS->ZKS_DATPRE := DataValida(DaySum(sToD((cQry)->D2_EMISSAO), 14), .T.)
				
			ZKS->(MsUnLock())
		
		EndIf
		
		(cQry)->(DbSkip())
		
	EndDo()
	
	(cQry)->(DbCloseArea())
	
	::CreateTerm()
	
	::SendWorkFlow()

Return()


Method Exist(dEmissao, cCliente, cLoja, cNumObr, cDoc, cSerie, cProduto, cItem) Class TVistoriaObraEngenharia
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL += " SELECT COUNT(ZKS_NUMERO) AS COUNT
	cSQL += " FROM "+ RetSQLName("ZKS")
	cSQL += " WHERE ZKS_FILIAL = " + ValToSQL(xFilial("ZKS"))
	cSQL += " AND ZKS_DATA = " + ValToSQL(dEmissao)
	cSQL += " AND ZKS_CLIENT = " + ValToSQL(cCliente)
	cSQL += " AND ZKS_LOJA = " + ValToSQL(cLoja)
	cSQL += " AND ZKS_NUMOBR = " + ValToSQL(cNumObr)
	cSQL += " AND ZKS_DOC = " + ValToSQL(cDoc)
	cSQL += " AND ZKS_SERIE = " + ValToSQL(cSerie)
	cSQL += " AND ZKS_PRODUT = " + ValToSQL(cProduto)
	cSQL += " AND ZKS_ITEM = " + ValToSQL(cItem)	
	cSQL += " AND D_E_L_E_T_ = ''
	
	TcQuery cSQL New Alias (cQry)
	
	lRet := (cQry)->COUNT > 0
	
	(cQry)->(DbCloseArea())

Return(lRet)


Method GetNextNum() Class TVistoriaObraEngenharia
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(MAX(ZKS_NUMERO), '000000') AS ZKS_NUMERO "
	cSQL += " FROM " + RetSQLName("ZKS")
	cSQL += " WHERE ZKS_FILIAL = " + ValToSQL(xFilial("ZKS"))
	cSQL += " AND D_E_L_E_T_ = ''

	TcQuery cSQL New Alias (cQry)

	cRet := Soma1((cQry)->ZKS_NUMERO)

	(cQry)->(DbCloseArea())

Return(cRet)


Method CreateTerm() Class TVistoriaObraEngenharia

	::oTermo:dEmiDe := ::dEmiDe
	::oTermo:dEmiAte := ::dEmiAte 
	
	::oTermo:Process()

Return()


Method SendWorkFlow() Class TVistoriaObraEngenharia

	::oWorkflow:dEmiDe := ::dEmiDe
	::oWorkflow:dEmiAte := ::dEmiAte
	
	::oWorkflow:Process()

Return()