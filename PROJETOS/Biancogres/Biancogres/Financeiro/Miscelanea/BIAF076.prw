#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF076
@author Tiago Rossini Coradini
@since 17/05/2017
@version 1.0
@description Rotina para bloquei de pagamento a fornecedores que possuam nota de debito no contas a receber.
@obs OS: 0345-17 - Mikaelly Gentil
@type function
/*/

User Function BIAF076()
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()
Local cMsg := ""
              
	cSQL := " SELECT A1_COD, A1_LOJA, A1_GRPVEN, A1_YTIPOLC " 
	cSQL += " FROM " + RetSQLName("SA1")
	cSQL += " WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
	cSQL += " AND A1_CGC IN "
	cSQL += " ( "
	cSQL += " 	SELECT A2_CGC "
	cSQL += " 	FROM " + RetSQLName("SA2")
	cSQL += " 	WHERE A2_FILIAL = " + ValToSQL(xFilial("SA2")) 
	cSQL += "		AND A2_COD = " + ValToSQL(SE2->E2_FORNECE)
	cSQL += " 	AND A2_LOJA = " + ValToSQL(SE2->E2_LOJA)
	cSQL += " 	AND SUBSTRING(A2_CGC,1,8) NOT IN ('02077546', '04917232', '04548187', '10524837', '13231737', '14086214', '08930868', '28129165', '27060390') "
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " ) "
	cSQL += " AND D_E_L_E_T_ = '' "	
	
	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->A1_COD)
		
		If fExistNDC((cQry)->A1_COD, (cQry)->A1_LOJA, (cQry)->A1_GRPVEN, (cQry)->A1_YTIPOLC)
		
			lRet := .T.
			
			fUpdCP()
			
			cMsg := "Atenção, o título abaixo se encontra bloqueado, pois o fornecedor possui nota(s) de débito em aberto no contas a receber." + Chr(13) + Chr(13)
			
			cMsg += "Título: " + AllTrim(SE2->E2_NUM) + Chr(13)
			cMsg += "Fornecedor: " + SE2->E2_FORNECE + " - Loja: " + SE2->E2_LOJA + Chr(13)
			cMsg += "Nome: " + AllTrim(SE2->E2_NOMFOR) + Chr(13) + Chr(13)
			
			If FunName() == "FINA240"				
				cMsg += "O título será relacionado ao borderô após liberação."
			Else							
				cMsg += "A baixa será realizada após liberação."	
			EndIf
			
			MsgAlert(cMsg, "Bloqueio de título - [BIAF076]")
		
		EndIf
		
	EndIf
	
	(cQry)->(DbCloseArea())

Return(lRet)


Static Function fExistNDC(cCodCli, cLojCli, cGrpVen, cTipLc)
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT COUNT(E1_NUM) AS COUNT "
	cSQL += " FROM " + RetSQLName("SE1")
	cSQL += " WHERE E1_FILIAL = " + ValToSQL(xFilial("SE1"))
	cSQL += " AND E1_PREFIXO = 'NDC' "
	cSQL += " AND E1_TIPO = 'NDC' "
	cSQL += " AND E1_SALDO > 0 "
	
	If Empty(cGrpVen) .And. cTipLc == "G"
	
		cSQL += " AND E1_CLIENTE IN " 
		cSQL += " ( "
		cSQL += " 	SELECT A1_COD
		cSQL += " 	FROM " + RetSQLName("SA1")
		cSQL += " 	WHERE A1_FILIAL = " + ValToSQL(xFilial("SA1"))
		cSQL += " 	AND A1_GRPVEN = " + ValToSQL(cGrpVen)
		cSQL += " 	AND A1_YTIPOLC = " + ValToSQL(cTipLc)
		cSQL += " 	AND D_E_L_E_T_ = '' "
		cSQL += " ) "
		
	Else
		
		cSQL += " AND E1_CLIENTE = " + ValToSQL(cCodCli)
		cSQL += " AND E1_LOJA = " + ValToSQL(cLojCli)
	
	EndIf
	
	cSQL += " AND D_E_L_E_T_ = '' "
              
	TcQuery cSQL New Alias (cQry)

	lRet := (cQry)->COUNT > 0
	
	(cQry)->(DbCloseArea())

Return(lRet)



Static Function fUpdCP()
Local cSQL := ""

	cSQL := " UPDATE " + RetSQLName("SE2")
	cSQL += " SET E2_YBLQ = '01' " 
	cSQL += " WHERE R_E_C_N_O_ = " + ValToSQL(SE2->(RecNo()))
	
	TCSQLExec(cSQL)

Return()