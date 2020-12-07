#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF060
@author Tiago Rossini Coradini
@since 27/12/2016
@version 1.0
@description Rotina para tratamento do preenchimento automático do código do fornecedor. 
@obs OS: 4324-16 - Claudia Carvalho
@type function
/*/

User Function BIAF060()
Local cRet := ""
Local cCod := ""
Local cMay := ""
Local aArea := GetArea()

	// Retorna proximo codigo, levando em consideracao as lacunas existentes entre '000001' e '999999'  
	cCod := AllTrim(fCodSeq())

	// Caso não tenha mais lacunas entre os codigos, busca maior codigo + 1
	If Empty(cCod)

		cCod := AllTrim(fMaxSeq())

	EndIf
	
	DbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	
	cMay := "SA2" + Alltrim(xFilial("SA2"))
	
	While (DbSeek(xFilial("SA2") + cCod) .Or. !MayIUseCode(cMay + cCod))
		
		cCod := Soma1(cCod)
		
	EndDo
	
	cRet := cCod
	
	RestArea(aArea)

Return(cRet)


Static Function fCodSeq()
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT TOP 1 REPLICATE('0', 6 - LEN(CONVERT(INT, L.A2_COD) + 1)) + CONVERT(VARCHAR(6), CONVERT(INT, L.A2_COD) + 1) AS A2_COD "
	cSQL += " FROM "
	cSQL += " ( "
	cSQL += " 	SELECT A2_COD, A2_LOJA "
	cSQL += " 	FROM "+ RetSQLName("SA2") 
	cSQL += " 	WHERE A2_FILIAL = "+ ValToSQL(xFilial("SA2"))
	cSQL += " 	AND A2_COD BETWEEN '000000' AND '999999' "
	cSQL += " 	AND D_E_L_E_T_ = '' "	
	cSQL += " 	GROUP BY A2_COD, A2_LOJA "
	cSQL += " ) L "
	cSQL += " LEFT OUTER JOIN " 
	cSQL += " ( "
	cSQL += " 	SELECT A2_COD, A2_LOJA "
	cSQL += " 	FROM "+ RetSQLName("SA2")
	cSQL += " 	WHERE A2_FILIAL = "+ ValToSQL(xFilial("SA2"))
	cSQL += " 	AND A2_COD BETWEEN '000000' AND '999999' "
	cSQL += " 	AND D_E_L_E_T_ = '' "	
	cSQL += " 	GROUP BY A2_COD, A2_LOJA "
	cSQL += " ) R "
	cSQL += " ON CONVERT(INT, L.A2_COD) + 1 = CONVERT(INT, R.A2_COD) "
	cSQL += " WHERE R.A2_COD IS NULL "
	cSQL += " AND R.A2_LOJA IS NULL "
	cSQL += " ORDER BY L.A2_COD "

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->A2_COD)

		cRet := (cQry)->A2_COD

	EndIf

	(cQry)->(DbCloseArea())

Return(cRet)


Static Function fMaxSeq()
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(MAX(A2_COD), '') AS A2_COD "
	cSQL += " FROM "+ RetSQLName("SA2")
	cSQL += " WHERE A2_FILIAL = "+ ValToSQL(xFilial("SA2"))
	cSQL += " AND A2_COD BETWEEN '000000' AND '999999' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	cRet := Soma1((cQry)->A2_COD)

	(cQry)->(DbCloseArea())

	RestArea(aArea)

Return(cRet)
