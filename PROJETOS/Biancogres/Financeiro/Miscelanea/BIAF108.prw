#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF108
@author Tiago Rossini Coradini
@since 16/05/2018
@version 1.0
@description Permite modificar o CNPJ obtido da leitura do arquivo de retorno DDA, de modo que a tabela SA2 seja posicionada através do CNPJ  
@obs Ticket: 936
@type Function
/*/

User Function BIAF108(cCNPJ, dVenc, nValor)
	
	DbSelectArea("SA2")
	SA2->(DbSetOrder(3))
	If !SA2->(MsSeek(xFilial("SA2") + cCNPJ))
		
		// Caso nao encontre o fornecedor pelo CNPJ do DDA, procura fornecedor pela raiz do CNJP		
		fRaiz(@cCNPJ, dVenc, nValor)
		
	EndIf
	
Return(cCNPJ)


Static Function fRaiz(cCNPJ, dVenc, nValor)
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT COUNT(A2_CGC) AS COUNT, A2_CGC "
	cSQL += " FROM " + RetSQLName("SA2")
	cSQL += " WHERE A2_FILIAL = " + ValToSQL(xFilial("SA2")) 
	cSQL += " AND A2_CGC LIKE " + ValToSQL(SubStr(cCNPJ, 1, Len(cCNPJ) -6) + "%")
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY A2_CGC "
	
	TcQuery cSQL New Alias (cQry)
	  			
	// Caso encontre somente um fornecedor com a mesma raiz, assume que é o correto
	If (cQry)->COUNT == 1
		
		cCNPJ := (cQry)->A2_CGC
		
	// Caso encontre mais de um fornecedor com a mesma raiz, analisa se existe algum titulo em aberto para atribuir qual é o correto  
	ElseIf (cQry)->COUNT > 1
	
		fRaizTitulo(@cCNPJ, dVenc, nValor)

	EndIf
	
	(cQry)->(dbCloseArea())
	
Return(cCNPJ)


Static Function fRaizTitulo(cCNPJ, dVenc, nValor)
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT DISTINCT A2_CGC "
	cSQL += " FROM " + RetSQLName("SA2")
	cSQL += " WHERE A2_FILIAL = " + ValToSQL(xFilial("SA2"))		
	cSQL += " AND A2_COD IN "
	cSQL += " ( "
	cSQL += " 	SELECT E2_FORNECE "
	cSQL += " 	FROM " + RetSQLName("SE2")
	cSQL += " 	WHERE E2_FILIAL = " + ValToSQL(xFilial("SE2"))
	cSQL += " 	AND (E2_VENCTO = " + ValToSQL(dVenc) + " OR E2_VENCREA = " + ValToSQL(dVenc) + ")"
	cSQL += " 	AND E2_SALDO > 0 "
	cSQL += " 	AND E2_VALOR = " + ValToSQL(nValor)
	cSQL += " 	AND E2_CODBAR = '' "
	cSQL += " 	AND E2_IDCNAB = '' "
	cSQL += " 	AND E2_FORNECE IN "
	cSQL += " 	( "
	cSQL += " 		SELECT A2_COD "
	cSQL += " 		FROM " + RetSQLName("SA2")
	cSQL += " 		WHERE A2_FILIAL = " + ValToSQL(xFilial("SA2")) 
	cSQL += " 		AND A2_CGC LIKE " + ValToSQL(SubStr(cCNPJ, 1, Len(cCNPJ) -6) + "%")
	cSQL += " 		AND D_E_L_E_T_ = '' "
	cSQL += " 	) "
	cSQL += " 	AND	 D_E_L_E_T_ = '' "
	cSQL += " ) "
	cSQL += " AND D_E_L_E_T_ = '' "
		
	TcQuery cSQL New Alias (cQry)
	  			
	If !Empty((cQry)->A2_CGC)
		
		cCNPJ := (cQry)->A2_CGC
			
	EndIf
	
	(cQry)->(dbCloseArea())
	
Return(cCNPJ)