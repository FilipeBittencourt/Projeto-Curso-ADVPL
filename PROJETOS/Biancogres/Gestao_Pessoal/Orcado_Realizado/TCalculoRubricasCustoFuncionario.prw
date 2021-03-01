#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TCalculoRubricasCustoFuncionario
@author Tiago Rossini Coradini
@since 02/03/2020
@version 1.0
@description Classe para Calculo de Rubricas de Custo Funcionario
@type class
/*/

Class TCalculoRubricasCustoFuncionario From LongClassName

	Data cVersao
	Data cRevisao
	Data cAno
	Data cPeriodo
	Data oLstField
	Data cSQLSRD
	Data cSQLSRT
	Data cSQLSD3
	Data cSQLSZS
	Data cSQLQuery

	Method New() Constructor
	Method Process()
	Method ExistZBA()
	Method ExistZBC()
	Method ExistZBW()
	Method ExistZBO()
	Method GetField()
	Method Insert()	
	Method Delete()
	Method Validate()
	Method BuildSQL()
	Method BuildSRD(cTable)
	Method BuildSRT(cTable)
	Method BuildSD3(cTable)
	Method BuildSZS(cTable)
	Method BuildQuery()
	Method GetCaseFilter(cTable, cOperation, cField)
	Method GetWhereFilter(cTable, cField)
	Method Report()	

EndClass

Method New() Class TCalculoRubricasCustoFuncionario

	::cVersao := ""
	::cRevisao := ""
	::cAno := ""
	::cPeriodo := ""
	::oLstField := ArrayList():New()
	::cSQLSRD := ""
	::cSQLSRT := ""
	::cSQLSD3 := ""
	::cSQLSZS := ""
	::cSQLQuery := ""

Return()

Method Process() Class TCalculoRubricasCustoFuncionario

	If ::Validate()

		Begin Transaction

			::BuildSQL()

		End Transaction

	EndIf	

Return()

Method ExistZBA() Class TCalculoRubricasCustoFuncionario

	Local lRet := .T.
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT COUNT(ZBA_MATR) AS COUNT "
	cSQL += " FROM "+ RetSQLName("ZBA")
	cSQL += " WHERE ZBA_FILIAL = "+ ValToSQL(xFilial("ZBA")) 
	cSQL += " AND ZBA_VERSAO = "+ ValToSQL(::cVersao)
	cSQL += " AND ZBA_REVISA = "+ ValToSQL(::cRevisao)
	cSQL += " AND ZBA_ANOREF = "+ ValToSQL(::cAno)
	cSQL += " AND ZBA_PERIOD = "+ ValToSQL(::cPeriodo)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	lRet := (cQry)->COUNT > 0

	(cQry)->(DbCloseArea())

Return(lRet)

Method ExistZBC() Class TCalculoRubricasCustoFuncionario

	Local lRet := .T.
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT COUNT(ZBC_VERSAO) AS COUNT "
	cSQL += " FROM "+ RetSQLName("ZBC")
	cSQL += " WHERE ZBC_FILIAL = "+ ValToSQL(xFilial("ZBC")) 
	cSQL += " AND ZBC_VERSAO = "+ ValToSQL(::cVersao)
	cSQL += " AND ZBC_REVISA = "+ ValToSQL(::cRevisao)
	cSQL += " AND ZBC_ANOREF = "+ ValToSQL(::cAno)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	lRet := (cQry)->COUNT > 0

	(cQry)->(DbCloseArea())

Return(lRet)

Method ExistZBW() Class TCalculoRubricasCustoFuncionario

	Local lRet := .T.
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT COUNT(ZBW_TABELA) AS COUNT "
	cSQL += " FROM "+ RetSQLName("ZBW")
	cSQL += " WHERE ZBW_FILIAL = "+ ValToSQL(xFilial("ZBW")) 
	cSQL += " AND ZBW_VERSAO = "+ ValToSQL(::cVersao)
	cSQL += " AND ZBW_REVISA = "+ ValToSQL(::cRevisao)
	cSQL += " AND ZBW_ANOREF = "+ ValToSQL(::cAno)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	lRet := (cQry)->COUNT > 0

	(cQry)->(DbCloseArea())

Return(lRet)

Method ExistZBO() Class TCalculoRubricasCustoFuncionario

	Local lRet := .T.
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT COUNT(ZBO_MATR) AS COUNT "
	cSQL += " FROM "+ RetSQLName("ZBO")
	cSQL += " WHERE ZBO_FILIAL = "+ ValToSQL(xFilial("ZBO")) 
	cSQL += " AND ZBO_VERSAO = "+ ValToSQL(::cVersao)
	cSQL += " AND ZBO_REVISA = "+ ValToSQL(::cRevisao)
	cSQL += " AND ZBO_ANOREF = "+ ValToSQL(::cAno)
	cSQL += " AND ZBO_PERIOD = "+ ValToSQL(::cPeriodo)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	lRet := (cQry)->COUNT > 0

	(cQry)->(DbCloseArea())

Return(lRet)

Method GetField() Class TCalculoRubricasCustoFuncionario

	Local cSQL := ""
	Local cQry := GetNextAlias()

	::oLstField:Clear()

	cSQL := " SELECT ZBC_RUBRIC, "
	cSQL += "        ZBC_DRUBRI "
	cSQL += " FROM " + RetSQLName("ZBC") + " ZBC "
	cSQL += " WHERE ZBC_FILIAL = " + ValToSQL(xFilial("ZBC"))
	cSQL += "       AND ZBC_VERSAO = "+ ValToSQL(::cVersao)
	cSQL += "       AND ZBC_REVISA = "+ ValToSQL(::cRevisao)
	cSQL += "       AND ZBC_ANOREF = "+ ValToSQL(::cAno)
	cSQL += "       AND D_E_L_E_T_ = ' ' "
	cSQL += " ORDER BY ZBC_ORDEM "	
	TcQuery cSQL New Alias (cQry)	

	While !(cQry)->(Eof())

		oObj := TICampoRubruca():New()

		oObj:cNome := (cQry)->ZBC_RUBRIC
		oObj:cDesc := (cQry)->ZBC_DRUBRI

		::oLstField:Add(oObj)

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return()

Method Insert() Class TCalculoRubricasCustoFuncionario

	TcSQLExec(::cSQLQuery)

	TcRefresh(RetSQLName("ZBO"))

Return()

Method Delete() Class TCalculoRubricasCustoFuncionario

	Local cSQL := ""

	cSQL := " DELETE FROM "+ RetSQLName("ZBO")
	cSQL += " WHERE ZBO_FILIAL = "+ ValToSQL(xFilial("ZBO")) 
	cSQL += " AND ZBO_VERSAO = "+ ValToSQL(::cVersao)
	cSQL += " AND ZBO_REVISA = "+ ValToSQL(::cRevisao)
	cSQL += " AND ZBO_ANOREF = "+ ValToSQL(::cAno)
	cSQL += " AND ZBO_PERIOD = "+ ValToSQL(::cPeriodo)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcSQLExec(cSQL)

	TcRefresh(RetSQLName("ZBO"))	

Return()

Method Validate() Class TCalculoRubricasCustoFuncionario

	Local lRet := .T.

	If ::ExistZBA() .And. ::ExistZBC()

		If ::ExistZBW()

			If ::ExistZBO() .And. ::ExistZBO()

				If (lRet := MsgYesNo("Já existem dados Calculados de Custos de Funcionarios, deseja reprocessar o período?"))

					::Delete()

				EndIf

			EndIf

		Else

			lRet := .F.

			MsgStop("Não existem dados de Rubricas de Custos de Funcionarios")		

		EndIf

	Else

		lRet := .F.

		MsgStop("Não existem dados de Previsão de Custos de Funcionarios")

	EndIf

Return(lRet)

Method BuildSQL() Class TCalculoRubricasCustoFuncionario

	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT TABELA"
	cSQL += " FROM FNC_TABELA_RUBRICA("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +") "

	TcQuery cSQL New Alias (cQry)	

	While !(cQry)->(Eof())

		If (cQry)->TABELA == "1"

			::BuildSRD((cQry)->TABELA)

		ElseIf (cQry)->TABELA == "2"

			::BuildSRT((cQry)->TABELA)

		ElseIf (cQry)->TABELA == "3"

			::BuildSD3((cQry)->TABELA)

		ElseIf (cQry)->TABELA == "4"

			::BuildSZS((cQry)->TABELA)

		EndIf

		(cQry)->(DbSkip())

	EndDo()

	::BuildQuery()

	::Insert()

	(cQry)->(DbCloseArea())

Return()

Method BuildSRD(cTable) Class TCalculoRubricasCustoFuncionario

	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cSep := ","
	Local cFields := "RD_MAT, RD_CLVL"
	Local cSum := ""
	Local cCase := ""

	cSQL := " SELECT CAMPO "
	cSQL += " FROM FNC_CAMPO_RUBRICA("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +") "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		cSum += cSep + Space(1) +"SUM("+ (cQry)->CAMPO +") AS "+ (cQry)->CAMPO

		cCase += cSep + Space(1) +"CASE "
		cCase += " WHEN RD_PD IN (SELECT VERBA FROM FNC_VERBA_RUBRICA_SOMA("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +", "+ ValToSQL((cQry)->CAMPO) +")) THEN RD_VALOR "
		cCase += " WHEN RD_PD IN (SELECT VERBA FROM FNC_VERBA_RUBRICA_SUBTRAI("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +", "+ ValToSQL((cQry)->CAMPO) +")) THEN RD_VALOR * -1 ""
		cCase += " ELSE 0 END AS "+ (cQry)->CAMPO 

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

	::cSQLSRD := " SELECT " + cFields
	::cSQLSRD += cSum
	::cSQLSRD += " FROM "
	::cSQLSRD += " ( "
	::cSQLSRD += " SELECT " + cFields
	::cSQLSRD += cCase
	::cSQLSRD += " FROM " + RetSQLName("SRD")
	::cSQLSRD += " WHERE RD_FILIAL = " + ValToSQL(xFilial("SRD"))
	::cSQLSRD += " AND RD_DATARQ = " + ValToSQL(::cAno + ::cPeriodo)
	::cSQLSRD += " AND RD_MAT <= '199999' "
	::cSQLSRD += " AND D_E_L_E_T_ = '' "
	::cSQLSRD += " ) AS SRD "
	::cSQLSRD += " GROUP BY " + cFields

Return()

Method BuildSRT(cTable) Class TCalculoRubricasCustoFuncionario

	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cSep := ","
	Local cFields := "RT_MAT, RT_CLVL"
	Local cSum := ""
	Local cCase := ""

	cSQL := " SELECT CAMPO "
	cSQL += " FROM FNC_CAMPO_RUBRICA("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +") "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		cSum += cSep + Space(1) +"SUM("+ (cQry)->CAMPO +") AS "+ (cQry)->CAMPO

		cCase += cSep + Space(1) +"CASE "
		cCase += " WHEN SUBSTRING(RT_DATACAL, 1, 6) = "+ ValToSQL(::cAno + ::cPeriodo) +" AND RT_VERBA IN (SELECT VERBA FROM FNC_VERBA_RUBRICA_SOMA("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +", "+ ValToSQL((cQry)->CAMPO) +")) THEN RT_VALOR "
		cCase += " WHEN SUBSTRING(RT_DATACAL, 1, 6) = "+ ValToSQL(AnoMes(MonthSub(sToD(::cAno + ::cPeriodo + "01"), 1))) +" AND RT_VERBA IN (SELECT VERBA FROM FNC_VERBA_RUBRICA_SUBTRAI("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +", "+ ValToSQL((cQry)->CAMPO) +")) THEN RT_VALOR * -1 " 
		cCase += " WHEN SUBSTRING(RT_DATACAL, 1, 6) = "+ ValToSQL(::cAno + ::cPeriodo) +" AND RT_VERBA IN (SELECT VERBA FROM FNC_VERBA_RUBRICA_SOMA_TRANSFERENCIA("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +", "+ ValToSQL((cQry)->CAMPO) +")) THEN RT_VALOR "
		cCase += " WHEN SUBSTRING(RT_DATACAL, 1, 6) = "+ ValToSQL(::cAno + ::cPeriodo) +" AND RT_VERBA IN (SELECT VERBA FROM FNC_VERBA_RUBRICA_SUBTRAI_TRANSFERENCIA("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +", "+ ValToSQL((cQry)->CAMPO) +")) THEN RT_VALOR * -1 "
		cCase += " WHEN SUBSTRING(RT_DATACAL, 1, 6) = "+ ValToSQL(::cAno + ::cPeriodo) +" AND RT_VERBA IN (SELECT VERBA FROM FNC_VERBA_RUBRICA_SOMA_BAIXA_01("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +", "+ ValToSQL((cQry)->CAMPO) +")) THEN RT_VALOR "
		cCase += " WHEN SUBSTRING(RT_DATACAL, 1, 6) = "+ ValToSQL(::cAno + ::cPeriodo) +" AND RT_VERBA IN (SELECT VERBA FROM FNC_VERBA_RUBRICA_SUBTRAI_BAIXA_01("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +", "+ ValToSQL((cQry)->CAMPO) +")) THEN RT_VALOR * -1 "
		cCase += " WHEN SUBSTRING(RT_DATACAL, 1, 6) = "+ ValToSQL(::cAno + ::cPeriodo) +" AND RT_VERBA IN (SELECT VERBA FROM FNC_VERBA_RUBRICA_SOMA_BAIXA_02("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +", "+ ValToSQL((cQry)->CAMPO) +")) THEN RT_VALOR "
		cCase += " WHEN SUBSTRING(RT_DATACAL, 1, 6) = "+ ValToSQL(::cAno + ::cPeriodo) +" AND RT_VERBA IN (SELECT VERBA FROM FNC_VERBA_RUBRICA_SUBTRAI_BAIXA_02("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +", "+ ValToSQL((cQry)->CAMPO) +")) THEN RT_VALOR * -1 " 
		cCase += " ELSE 0 END AS "+ (cQry)->CAMPO

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

	::cSQLSRT := " SELECT " + cFields
	::cSQLSRT += cSum
	::cSQLSRT += " FROM "
	::cSQLSRT += " ( "
	::cSQLSRT += " SELECT " + cFields
	::cSQLSRT += cCase
	::cSQLSRT += " FROM " + RetSQLName("SRT")
	::cSQLSRT += " WHERE RT_FILIAL = " + ValToSQL(xFilial("SRT"))
	::cSQLSRT += " AND SUBSTRING(RT_DATACAL, 1, 6) BETWEEN "+ ValToSQL(AnoMes(MonthSub(sToD(::cAno + ::cPeriodo + "01"), 1))) + " AND " + ValToSQL(::cAno + ::cPeriodo)
	::cSQLSRT += " AND D_E_L_E_T_ = '' "	
	::cSQLSRT += " ) AS SRT "
	::cSQLSRT += " GROUP BY " + cFields

Return()

Method BuildSD3(cTable) Class TCalculoRubricasCustoFuncionario

	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cSep := ","
	Local cFields := "D3_YMATRIC"
	Local cSum := ""
	Local cCase := ""
	Local cWhere := ""

	cSQL := " SELECT CAMPO "
	cSQL += " FROM FNC_CAMPO_RUBRICA("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +") "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		cSum += cSep + Space(1) +"SUM("+ (cQry)->CAMPO +") AS "+ (cQry)->CAMPO

		cCase += cSep + Space(1) +"CASE "
		cCase += " WHEN "+ ::GetCaseFilter(cTable, "1", (cQry)->CAMPO) +" THEN D3_CUSTO1 "
		cCase += " WHEN "+ ::GetCaseFilter(cTable, "2", (cQry)->CAMPO) +" THEN D3_CUSTO1 * -1 "
		cCase += " ELSE 0 END AS "+ (cQry)->CAMPO

		cWhere += If (!Empty(cWhere), " OR ", "") + ::GetWhereFilter(cTable, (cQry)->CAMPO)

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

	::cSQLSD3 := " SELECT " + cFields
	::cSQLSD3 += cSum
	::cSQLSD3 += " FROM "
	::cSQLSD3 += " ( "
	::cSQLSD3 += " SELECT SUBSTRING("+ cFields +", 3, 6) AS " + cFields
	::cSQLSD3 += cCase
	::cSQLSD3 += " FROM " + RetSQLName("SD3")
	::cSQLSD3 += " WHERE D3_FILIAL = " + ValToSQL(xFilial("SD3"))
	::cSQLSD3 += " AND SUBSTRING(D3_EMISSAO, 1, 6) = " + ValToSQL(::cAno + ::cPeriodo)
	::cSQLSD3 += " AND D3_YMATRIC <> '' "
	::cSQLSD3 += " AND (" + cWhere + ")"
	::cSQLSD3 += " AND D_E_L_E_T_ = '' "
	::cSQLSD3 += " ) AS SD3 "
	::cSQLSD3 += " GROUP BY " + cFields

Return()

Method BuildSZS(cTable) Class TCalculoRubricasCustoFuncionario

	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cSep := ","
	Local cFields := "ZS_MAT"
	Local cSum := ""
	Local cCase := ""
	Local cWhere := ""

	cSQL := " SELECT CAMPO "
	cSQL += " FROM FNC_CAMPO_RUBRICA("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +") "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		cSum += cSep + Space(1) +"SUM("+ (cQry)->CAMPO +") AS "+ (cQry)->CAMPO

		cCase += cSep + Space(1) +"CASE "
		cCase += " WHEN "+ ::GetCaseFilter(cTable, "1", (cQry)->CAMPO) +" THEN ZS_VALOR "
		cCase += " WHEN "+ ::GetCaseFilter(cTable, "2", (cQry)->CAMPO) +" THEN ZS_VALOR * -1 "
		cCase += " ELSE 0 END AS "+ (cQry)->CAMPO

		cWhere += If (!Empty(cWhere), " OR ", "") + ::GetWhereFilter(cTable, (cQry)->CAMPO)

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

	::cSQLSZS := " SELECT " + cFields
	::cSQLSZS += cSum
	::cSQLSZS += " FROM "
	::cSQLSZS += " ( "
	::cSQLSZS += " SELECT " + cFields
	::cSQLSZS += cCase
	::cSQLSZS += " FROM " + RetSQLName("SZS")
	::cSQLSZS += " WHERE ZS_FILIAL = " + ValToSQL(xFilial("SZS"))
	::cSQLSZS += " AND ZS_MESANO = " + ValToSQL(::cAno + ::cPeriodo)
	::cSQLSZS += " AND ZS_MAT <> '' "
	::cSQLSZS += " AND ZS_VALOR <> 0 "
	::cSQLSZS += " AND (" + cWhere + ")"
	::cSQLSZS += " AND D_E_L_E_T_ = '' "	
	::cSQLSZS += " ) AS SZS "
	::cSQLSZS += " GROUP BY " + cFields

Return()

Method GetCaseFilter(cTable, cOperation, cField) Class TCalculoRubricasCustoFuncionario

	Local cRet := ""
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT FILTRO "
	cSQL += " FROM FNC_FILTRO_RUBRICA_"+ If (cOperation == "1", "SOMA", "SUBTRAI") +"("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +", "+ ValToSQL(cField) +") "

	TcQuery cSQL New Alias (cQry)

	cRet := AllTrim(If (Empty((cQry)->FILTRO), "0=1", (cQry)->FILTRO))

	(cQry)->(DbCloseArea())

Return(cRet)

Method GetWhereFilter(cTable, cField) Class TCalculoRubricasCustoFuncionario

	Local cRet := ""
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT FILTRO "
	cSQL += " FROM FNC_FILTRO_RUBRICA("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +", "+ ValToSQL(cTable) +", "+ ValToSQL(cField) +") "

	TcQuery cSQL New Alias (cQry)

	cRet := AllTrim((cQry)->FILTRO)

	(cQry)->(DbCloseArea())

Return(cRet)

Method BuildQuery() Class TCalculoRubricasCustoFuncionario

	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cSep := ","
	Local cFldIns := "ZBO_FILIAL, ZBO_VERSAO, ZBO_REVISA, ZBO_ANOREF, ZBO_PERIOD, ZBO_MATR, ZBO_CLVL"
	Local cInsert := ""
	Local cFldDef := "D_E_L_E_T_, R_E_C_N_O_, R_E_C_D_E_L_"
	Local cFldSel := "RD_MAT, RD_CLVL"
	Local cSum := ""

	cSQL := " SELECT CAMPO "
	cSQL += " FROM FNC_RUBRICA("+ ValToSQL(::cVersao) +", "+ ValToSQL(::cRevisao) +", "+ ValToSQL(::cAno) +") "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		cInsert += cSep + Space(1) + (cQry)->CAMPO

		cSum += cSep + Space(1) +"ROUND(SUM(ISNULL("+ If ((cQry)->CAMPO == "ZBA_FERIAS", "SRD." + (cQry)->CAMPO + " + " + "SRT." + (cQry)->CAMPO, (cQry)->CAMPO) + ", 0)), 2) AS "+ (cQry)->CAMPO

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

	::cSQLQuery := " DECLARE @MAXRECNO INT " 
	::cSQLQuery += " SET @MAXRECNO = ISNULL((SELECT MAX(R_E_C_N_O_) FROM "+ RetSQLName("ZBO") + "(NOLOCK)), 0) "
	::cSQLQuery += " INSERT INTO "+ RetSQLName("ZBO") + "(" + cFldIns + StrTran(cInsert, "ZBA_", "ZBO_") + cSep + Space(1) + cFldDef + ")"

	::cSQLQuery += " SELECT " + ValToSQL(xFilial("ZBO")) + cSep + Space(1) + ValToSQL(::cVersao) + cSep + Space(1) + ValToSQL(::cRevisao) + cSep + Space(1) + ValToSQL(::cAno) + cSep + Space(1) + ValToSQL(::cPeriodo)
	::cSQLQuery += cSep + Space(1) + cFldSel
	::cSQLQuery += cSum + cSep + Space(1)	
	::cSQLQuery += " '' " + cSep + Space(1) + "@MAXRECNO + ROW_NUMBER() OVER (ORDER BY RD_MAT) AS R_E_C_N_O_" + cSep + Space(1) + "0"	
	::cSQLQuery += " FROM "
	::cSQLQuery += " ( "
	::cSQLQuery += ::cSQLSRD
	::cSQLQuery += " ) AS SRD "

	::cSQLQuery += " LEFT JOIN "
	::cSQLQuery += " ( "
	::cSQLQuery += ::cSQLSRT
	::cSQLQuery += " ) AS SRT "
	::cSQLQuery += " ON SRD.RD_MAT = SRT.RT_MAT "
	::cSQLQuery += " AND SRD.RD_CLVL = SRT.RT_CLVL "

	::cSQLQuery += " LEFT JOIN "
	::cSQLQuery += " ( "
	::cSQLQuery += ::cSQLSD3
	::cSQLQuery += " ) AS SD3 "
	::cSQLQuery += " ON SRD.RD_MAT = SD3.D3_YMATRIC "

	::cSQLQuery += " LEFT JOIN "
	::cSQLQuery += " ( "
	::cSQLQuery += ::cSQLSZS
	::cSQLQuery += " ) AS SZS "
	::cSQLQuery += " ON SRD.RD_MAT = SZS.ZS_MAT "
	::cSQLQuery += " GROUP BY " + cFldSel
	::cSQLQuery += " ORDER BY " + cFldSel

Return()

Method Report() Class TCalculoRubricasCustoFuncionario

	Local aArea := GetArea()
	Local oFWExcel := Nil
	Local oMsExcel := Nil
	Local cDir := GetSrvProfString("Startpath", "")
	Local cFile := "BIAF153B" +"-"+ cEmpAnt +"-"+ __cUserID +"-"+ dToS(Date()) + "-" + StrTran(Time(), ":", "") + ".XML"
	Local cWork := "Planilha 01"
	Local cTable := "Realizado RH"
	Local cDirTmp := AllTrim(GetTempPath())
	Local nCount := 1
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local cSep := ","
	Local cFields := ValToSQl(cEmpAnt) + " AS EMPRESA, ZBO_FILIAL AS FILIAL, ZBO_ANOREF AS ANO, ZBO_REVISA AS REVISAO, ZBO_PERIOD AS PERIODO, ZBO_MATR AS MATRICULA, RA_NOME AS NOME, ZBO_CLVL AS CLVL"
	Local cSelect := ""
	Local aLine := {}

	oFWExcel := FWMsExcel():New()

	oFWExcel:AddWorkSheet(cWork)	
	oFWExcel:AddTable(cWork, cTable)

	oFWExcel:AddColumn(cWork, cTable, "ORIGEM",    1, 1)
	oFWExcel:AddColumn(cWork, cTable, "EMPRESA",   1, 1)
	oFWExcel:AddColumn(cWork, cTable, "FILIAL",    1, 1)
	oFWExcel:AddColumn(cWork, cTable, "ANO",       1, 1)		
	oFWExcel:AddColumn(cWork, cTable, "REVISAO",   1, 1)
	oFWExcel:AddColumn(cWork, cTable, "PERIODO",   1, 1)
	oFWExcel:AddColumn(cWork, cTable, "MATRICULA", 1, 1)
	oFWExcel:AddColumn(cWork, cTable, "NOME",      1, 1)
	oFWExcel:AddColumn(cWork, cTable, "CLVL",      1, 1)		

	::GetField()

	If ::oLstField:GetCount() > 0

		While nCount <= ::oLstField:GetCount() 

			oFWExcel:AddColumn(cWork, cTable, Upper(::oLstField:GetItem(nCount):cDesc), 3, 2, .T.)

			cSelect += cSep + Space(1) + ::oLstField:GetItem(nCount):cNome

			nCount++

		EndDo()

	EndIf

	// Orçado

	cSQL := " SELECT 'Orçado' ORIGEM, " + StrTran(cFields, "ZBO_", "ZBA_") + cSelect
	cSQL += "   FROM " + RetSQLName("ZBA") + " ZBA(NOLOCK) "
	cSQL += "   LEFT JOIN " + RetSQLName("SRA") + " SRA(NOLOCK) ON RA_FILIAL = " + ValToSQL(xFilial("SRA"))
	cSQL += "                                 AND SRA.RA_MAT = ZBA.ZBA_MATR "
	cSQL += "                                 AND SRA.D_E_L_E_T_ = '' "
	cSQL += "  WHERE ZBA_FILIAL = " + ValToSQL(xFilial("ZBA"))
	cSQL += "    AND ZBA_VERSAO = " + ValToSQL(::cVersao)
	cSQL += "    AND ZBA_REVISA = " + ValToSQL(::cRevisao)
	cSQL += "    AND ZBA_ANOREF = " + ValToSQL(::cAno)
	cSQL += "    AND ZBA_PERIOD = " + ValToSQL(::cPeriodo)
	cSQL += "    AND ZBA.D_E_L_E_T_ = '' "	
	cSQL += " ORDER BY ZBA_MATR, ZBA_CLVL "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		aLine := {}

		aAdd(aLine, (cQry)->ORIGEM)
		aAdd(aLine, (cQry)->EMPRESA)
		aAdd(aLine, (cQry)->FILIAL)
		aAdd(aLine, (cQry)->ANO)
		aAdd(aLine, (cQry)->REVISAO)
		aAdd(aLine, (cQry)->PERIODO)
		aAdd(aLine, (cQry)->MATRICULA)
		aAdd(aLine, (cQry)->NOME)
		aAdd(aLine, (cQry)->CLVL)

		nCount := 1

		While nCount <= ::oLstField:GetCount() 

			aAdd(aLine, &((cQry)->(::oLstField:GetItem(nCount):cNome)))

			nCount++

		EndDo()

		oFWExcel:AddRow(cWork, cTable, aLine)

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

	// Realizado

	cSQL := " SELECT 'Realizado' ORIGEM, " + cFields + StrTran(cSelect, "ZBA_", "ZBO_")
	cSQL += "   FROM " + RetSQLName("ZBO") + " ZBO(NOLOCK) "
	cSQL += "  LEFT JOIN " + RetSQLName("SRA") + " SRA(NOLOCK) ON RA_FILIAL = " + ValToSQL(xFilial("SRA"))
	cSQL += "                                 AND SRA.RA_MAT = ZBO.ZBO_MATR "
	cSQL += "                                 AND SRA.D_E_L_E_T_ = '' "
	cSQL += "  WHERE ZBO_FILIAL = " + ValToSQL(xFilial("ZBO"))
	cSQL += "    AND ZBO_VERSAO = " + ValToSQL(::cVersao)
	cSQL += "    AND ZBO_REVISA = " + ValToSQL(::cRevisao)
	cSQL += "    AND ZBO_ANOREF = " + ValToSQL(::cAno)
	cSQL += "    AND ZBO_PERIOD = " + ValToSQL(::cPeriodo)
	cSQL += "    AND ZBO.D_E_L_E_T_ = '' "	
	cSQL += " ORDER BY ZBO_MATR, ZBO_CLVL "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		aLine := {}

		aAdd(aLine, (cQry)->ORIGEM)
		aAdd(aLine, (cQry)->EMPRESA)
		aAdd(aLine, (cQry)->FILIAL)
		aAdd(aLine, (cQry)->ANO)
		aAdd(aLine, (cQry)->REVISAO)
		aAdd(aLine, (cQry)->PERIODO)
		aAdd(aLine, (cQry)->MATRICULA)
		aAdd(aLine, (cQry)->NOME)
		aAdd(aLine, (cQry)->CLVL)

		nCount := 1

		While nCount <= ::oLstField:GetCount() 

			aAdd(aLine, &((cQry)->(StrTran(::oLstField:GetItem(nCount):cNome, "ZBA_", "ZBO_"))))

			nCount++

		EndDo()

		oFWExcel:AddRow(cWork, cTable, aLine)

		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

	oFWExcel:Activate()			
	oFWExcel:GetXMLFile(cFile)
	oFWExcel:DeActivate()		

	If CpyS2T(cDir + cFile, cDirTmp, .T.)

		fErase(cDir + cFile) 

		If ApOleClient('MsExcel')

			oMSExcel := MsExcel():New()
			oMSExcel:WorkBooks:Close()
			oMSExcel:WorkBooks:Open(cDirTmp + cFile)
			oMSExcel:SetVisible(.T.)
			oMSExcel:Destroy()

		EndIf

	Else

		MsgInfo("Arquivo não copiado para a pasta temporária do usuário.")

	Endif

	RestArea(aArea)

Return()
