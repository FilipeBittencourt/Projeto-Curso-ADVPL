#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF115
@author Tiago Rossini Coradini
@since 16/07/2018
@version 1.0
@description Adiciona coluna de ultimo preco de compra na solicitacao de compra
@obs Ticket: 7051
@type Function
/*/

User Function BIAF115(cProduto)
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()
Local aArea := GetArea()	
	
	cSQL := " SELECT TOP 1 EMPRESA, D1_DTDIGIT, D1_FORNECE, D1_LOJA, A2_NREDUZ, D1_VUNIT "
	cSQL += " FROM ( "	
	
	cSQL += " 	SELECT 'BIANCO' AS EMPRESA, D1_DTDIGIT, D1_FORNECE, D1_LOJA, A2_NREDUZ, D1_VUNIT "
	cSQL += " 	FROM SD1010 SD1 "
	cSQL += " 	INNER JOIN SA2010 SA2 "
	cSQL += " 	ON D1_FORNECE = A2_COD "
	cSQL += " 	AND D1_LOJA = A2_LOJA "
	cSQL += " 	WHERE D1_FILIAL = '01' "
	cSQL += " 	AND D1_COD = " + ValToSQL(cProduto)
	cSQL += " 	AND D1_CUSTO > 0 "
	cSQL += " 	AND D1_TIPO = 'N' "
	cSQL += " 	AND SD1.D_E_L_E_T_ = '' "
	cSQL += " 	AND A2_FILIAL = '' "
	cSQL += " 	AND SA2.D_E_L_E_T_ = '' "	
	
	cSQL += " 	UNION ALL "
		
	cSQL += " 	SELECT 'INCESA' AS EMPRESA, D1_DTDIGIT, D1_FORNECE, D1_LOJA, A2_NREDUZ, D1_VUNIT "
	cSQL += " 	FROM SD1050 SD1 "
	cSQL += " 	INNER JOIN SA2010 SA2 "
	cSQL += " 	ON D1_FORNECE = A2_COD "
	cSQL += " 	AND D1_LOJA = A2_LOJA "
	cSQL += " 	WHERE D1_FILIAL = '01' "
	cSQL += " 	AND D1_COD = " + ValToSQL(cProduto)
	cSQL += " 	AND D1_CUSTO > 0 "
	cSQL += " 	AND D1_TIPO = 'N' "	
	cSQL += " 	AND SD1.D_E_L_E_T_ = '' "
	cSQL += " 	AND A2_FILIAL = '' "
	cSQL += " 	AND SA2.D_E_L_E_T_ = '' "	
	
	cSQL += " 	UNION ALL "
		
	cSQL += " 	SELECT 'VITCER' AS EMPRESA, D1_DTDIGIT, D1_FORNECE, D1_LOJA, A2_NREDUZ, D1_VUNIT "
	cSQL += " 	FROM SD1140 SD1 "
	cSQL += " 	INNER JOIN SA2010 SA2 "
	cSQL += " 	ON D1_FORNECE = A2_COD "
	cSQL += " 	AND D1_LOJA = A2_LOJA "
	cSQL += " 	WHERE D1_FILIAL = '01' "
	cSQL += " 	AND D1_COD = " + ValToSQL(cProduto) 
	cSQL += " 	AND D1_CUSTO > 0 "
	cSQL += " 	AND D1_TIPO = 'N' "	
	cSQL += " 	AND SD1.D_E_L_E_T_ = '' "
	cSQL += " 	AND A2_FILIAL = '' "
	cSQL += " 	AND SA2.D_E_L_E_T_ = '' "

	cSQL += " 	UNION ALL "	
	
	cSQL += " 	SELECT 'BIANCO' AS EMPRESA, C7_EMISSAO, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_PRECO "
	cSQL += " 	FROM SC7010 SC7 "
	cSQL += " 	INNER JOIN SA2010 SA2 "
	cSQL += " 	ON C7_FORNECE = A2_COD "
	cSQL += " 	AND C7_LOJA = A2_LOJA "
	cSQL += " 	WHERE C7_FILIAL = '01' "
	cSQL += " 	AND C7_PRODUTO = " + ValToSQL(cProduto)
	cSQL += " 	AND C7_RESIDUO = '' "
	cSQL += " 	AND SC7.D_E_L_E_T_ = '' "
	cSQL += " 	AND A2_FILIAL = '' "
	cSQL += " 	AND SA2.D_E_L_E_T_ = '' "
	
	cSQL += " 	UNION ALL "
	
	cSQL += " 	SELECT 'INCESA' AS EMPRESA, C7_EMISSAO, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_PRECO "
	cSQL += " 	FROM SC7050 SC7 "
	cSQL += " 	INNER JOIN SA2010 SA2 "
	cSQL += " 	ON C7_FORNECE = A2_COD "
	cSQL += " 	AND C7_LOJA = A2_LOJA "
	cSQL += " 	WHERE C7_FILIAL = '01' "
	cSQL += " 	AND C7_PRODUTO = " + ValToSQL(cProduto)
	cSQL += " 	AND C7_RESIDUO = '' "
	cSQL += " 	AND SC7.D_E_L_E_T_ = '' "
	cSQL += " 	AND A2_FILIAL = '' "
	cSQL += " 	AND SA2.D_E_L_E_T_ = '' "

	cSQL += " 	UNION ALL "

	cSQL += " 	SELECT 'VITCER' AS EMPRESA, C7_EMISSAO, C7_FORNECE, C7_LOJA, A2_NREDUZ, C7_PRECO "
	cSQL += " 	FROM SC7140 SC7 "
	cSQL += " 	INNER JOIN SA2010 SA2 "
	cSQL += " 	ON C7_FORNECE = A2_COD "
	cSQL += " 	AND C7_LOJA = A2_LOJA "
	cSQL += " 	WHERE C7_FILIAL = '01' "
	cSQL += " 	AND C7_PRODUTO = " + ValToSQL(cProduto)
	cSQL += " 	AND C7_RESIDUO = '' "
	cSQL += " 	AND SC7.D_E_L_E_T_ = '' "
	cSQL += " 	AND A2_FILIAL = '' "
	cSQL += " 	AND SA2.D_E_L_E_T_ = '' "			
	
	cSQL += " ) AS TMP "
	cSQL += " ORDER BY D1_DTDIGIT DESC "
	
	TcQuery cSQL New Alias (cQry)		  			
	
	If !Empty((cQry)->EMPRESA)
	
		cRet := Capital((cQry)->EMPRESA) + " - Data: " + dToC(sToD((cQry)->D1_DTDIGIT)) + " - Fornecedor: " + (cQry)->D1_FORNECE + "-" + (cQry)->D1_LOJA + "-" +;
						AllTrim((cQry)->A2_NREDUZ) + " - Preço: " + AllTrim(Transform((cQry)->D1_VUNIT, PesqPict("SD1", "D1_VUNIT")))
		
	EndIf
	
	(cQry)->(DbCloseArea())
	
	RestArea(aArea)
	
Return(cRet)