#Include "TOTVS.CH"
#Include "Protheus.CH"
#Include "topconn.ch"

User Function MT125APV()
	
	Local cGrupo	:= Nil
	
	If (IsInCallStack("U_RETP0004"))
		cGrupo	:= GetAprov()
	EndIf
	
Return cGrupo

Static Function GetAprov()
	
	Local cQuery			:= ""
	Local cAliasTrab		:= GetNextAlias()
	Local cAliasTemp		:= Nil
	Local cNumCont			:= SC3->C3_NUM
	
	cQuery := " SELECT C3_NUM															" + CRLF
	cQuery += "		, SUM(C3_TOTAL) AS C3_TOTAL											" + CRLF
	cQuery += "		, MAX(C3_YCLVL) AS C3_YCLVL											" + CRLF
	cQuery += "		, MAX(B1_TIPO) AS B1_TIPO											" + CRLF
	cQuery += "		, MAX(BZ_YMD) AS BZ_YMD												" + CRLF
	cQuery += " FROM " + RetSqlName("SC3") + " SC3																											" + CRLF
	cQuery += " JOIN " + RetSqlName("SB1") + " SB1 ON SC3.C3_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ = '' AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'		" + CRLF
	cQuery += " JOIN " + RetSqlName("SBZ") + " SBZ ON SC3.C3_PRODUTO = SBZ.BZ_COD AND SBZ.D_E_L_E_T_ = '' AND SBZ.BZ_FILIAL = '" + xFilial("SBZ") + "' 		" + CRLF
	cQuery += " WHERE 1=1																" + CRLF
	cQuery += "		AND SC3.D_E_L_E_T_ 	= ''											" + CRLF
	cQuery += "		AND SC3.C3_NUM 		= '" + cNumCont + "'							" + CRLF
	cQuery += "		AND SC3.C3_FILIAL	= '" + xFilial("SC3") + "'						" + CRLF
	cQuery += " GROUP BY C3_NUM															" + CRLF
	
	TcQuery cQuery New Alias (cAliasTrab)
	
	If (!(cAliasTrab)->(Eof()))
		
		If Alltrim((cAliasTrab)->B1_TIPO) $ ("MP_ME") .OR. (Alltrim((cAliasTrab)->BZ_YMD) <> 'S' .AND. Alltrim((cAliasTrab)->B1_TIPO) $ ("MD_MC_OI"))
			cGrupo := '000000'
		Else
			//SELECIONA GRUPO DE APROVAÇÃO
			cQuery := "SELECT TOP 1 ISNULL(AL_COD,'999999') AS GRUPO				" + CRLF
			cQuery += "FROM " + RetSQLName("SAL")+"									" + CRLF
			cQuery += "WHERE AL_FILIAL  = '" + xFilial("SAL") + "'					" + CRLF
			cQuery += "	 AND AL_YCLVL   = '" + Trim((cAliasTrab)->C3_YCLVL) + "'	" + CRLF
			cQuery += "	 AND D_E_L_E_T_ = ''										" + CRLF
			cQuery += "	 AND AL_MSBLQL 	<> '1'										" + CRLF
			
			cAliasTemp		:= GetNextAlias()
			TcQuery cQuery New Alias (cAliasTemp)
			If (!(cAliasTemp)->(Eof()))
				cGrupo 	:= (cAliasTemp)->GRUPO
			EndIf
			(cAliasTemp)->(DbCloseArea())
		EndIf
	
		cQuery := "UPDATE " + RetSQLName("SC3")+"									" + CRLF
		cQuery += "   SET C3_APROV   = '" + cGrupo + "'								" + CRLF 
		cQuery += "		, C3_GRUPCOM = ''											" + CRLF
		cQuery += " WHERE D_E_L_E_T_ = ''											" + CRLF
		cQuery += "	  AND C3_NUM     = '" + cNumCont + "'							" + CRLF
		cQuery += "	  AND C3_FILIAL  = '" + xFilial("SC3") + "'						" + CRLF
		
		conout(cQuery)
		TCSQLExec(cQuery)

	EndIf
	
	(cAliasTrab)->(DbCloseArea())

Return(cGrupo)