#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA634
@author Wlysses Cerqueira (Facile)
@since 14/12/2020
@version 1.0
@Projet A-35
@description DRE - Calculo de Resultado para DRE - Outras Receitas Financeiras. 
@type Program
/*/

User Function BIA634()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	//RpcSetEnv("01", "01")

	Private cTitulo := "DRE - Calculo de Resultado para DRE - Outras Receitas Financeiras"

	oEmp := TLoadEmpresa():New()

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte()

		oEmp:GetSelEmp()

		If Len(oEmp:aEmpSel) > 0

			Begin Transaction

				For nW := 1 To Len(oEmp:aEmpSel)

					lRet := Processa(oEmp:aEmpSel[nW][1], oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg)

					If !lRet

						Exit

					EndIf

				Next nW

				If !lRet

					DisarmTransaction()

				EndIf

			End Transaction

		Else

			Alert("Nenhuma empresa foi selecionada!")

		EndIf

	EndIf

	If !lRet

		Alert("Erro no processamento!" + CRLF + CRLF + cMsg, "Empresa: [" + cEmp + "]  - ATENÇÃO")

	EndIf

	//RpcClearEnv()

Return()

Static Function Processa(cEmp, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL := ""
	Local nW   := 0
	Local cQry := ""

	Local lRet	:= .T.
	Local cModo := "" //Modo de acesso do arquivo aberto //"E" ou "C"
	Local cZBZ  := GetNextAlias()

	Default cMsg := ""

	For nW := 1 To 12

		cQry := GetNextAlias()

		cSql := " SELECT *, "
		cSql += " ( "
		cSql += " 	VALOR *  "
		cSql += " 	(  "
		cSql += " 		SELECT ISNULL(ZOC_M" + StrZero(nW, 2) + ", 0) ZOC_M" + StrZero(nW, 2)
		cSql += " 		FROM " + RetFullName("ZOC", cEmp) + "  "
		cSql += " 		WHERE ZOC_FILIAL = ''  "
		cSql += " 		AND ZOC_VERSAO	 = " + ValToSql(cVersao)
		cSql += " 		AND ZOC_REVISA	 = " + ValToSql(cRevisa)
		cSql += " 		AND ZOC_ANOREF	 = " + ValToSql(cAnoRef)
		cSql += " 		AND ZOC_TIPO	 = '1' "
		// cSql += " 		AND ZOC_LINHA	 = '001' "
		cSql += " 		AND D_E_L_E_T_ = '' "
		cSql += " 	) / 100 "
		cSql += " ) OUTRAS_REC_FIN "
		cSql += " FROM  "
		cSql += " ( "
		cSql += " 	SELECT PERIODO, SUM(VALOR) VALOR "
		cSql += " 	FROM  "
		cSql += " 	( "
		cSql += " 		SELECT SUBSTRING(ZBZ_DATA, 1, 6) PERIODO, "
		cSql += " 			SUM(ZBZ_VALOR) * (-1) VALOR "
		cSql += " 		FROM " + RetFullName("ZBZ", cEmp) + " "
		cSql += " 		WHERE ZBZ_VERSAO	= " + ValToSql(cVersao)
		cSql += " 		AND ZBZ_REVISA 		= " + ValToSql(cRevisa)
		cSql += " 		AND ZBZ_ANOREF 		= " + ValToSql(cAnoRef)
		cSql += " 		AND ZBZ_ORIPRC      = 'RECEITA' "
		cSql += " 		AND SUBSTRING(ZBZ_DEBITO, 1, 3) = '411' "
		cSql += " 		AND ZBZ_DATA 		BETWEEN " + ValToSql(FirstDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " AND " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " "
		cSql += " 		AND D_E_L_E_T_		= '' "
		cSql += " 		GROUP BY SUBSTRING(ZBZ_DATA, 1, 6) "
		cSql += " 		UNION ALL "
		cSql += " 		SELECT SUBSTRING(ZBZ_DATA, 1, 6) PERIODO, "
		cSql += " 			SUM(ZBZ_VALOR) VALOR "
		cSql += " 		FROM " + RetFullName("ZBZ", cEmp) + " "
		cSql += " 		WHERE ZBZ_VERSAO 	= " + ValToSql(cVersao)
		cSql += " 			AND ZBZ_REVISA 	= " + ValToSql(cRevisa)
		cSql += " 			AND ZBZ_ANOREF 	= " + ValToSql(cAnoRef)
		cSql += " 			AND ZBZ_ORIPRC  = 'RECEITA' "
		cSql += " 			AND SUBSTRING(ZBZ_CREDIT, 1, 3) = '411' "
		cSql += " 			AND ZBZ_DATA 	BETWEEN " + ValToSql(FirstDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " AND " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " "
		cSql += " 			AND D_E_L_E_T_ 	= '' "
		cSql += " 		GROUP BY SUBSTRING(ZBZ_DATA, 1, 6) "
		cSql += " 	) CVARIAVEL "
		cSql += " 	GROUP BY PERIODO "
		cSql += " ) TAB "

		TcQuery cSQL New Alias (cQry)

		If !(cQry)->(EOF())

			If EmpOpenFile(cZBZ, "ZBZ", 1, .T., cEmp, @cModo)

				Reclock(cZBZ,.T.)
				(cZBZ)->ZBZ_FILIAL := cEmp
				(cZBZ)->ZBZ_VERSAO := cVersao
				(cZBZ)->ZBZ_REVISA := cRevisa
				(cZBZ)->ZBZ_ANOREF := cAnoRef
				(cZBZ)->ZBZ_DATA   := LastDay(STOD((cQry)->PERIODO + "01"))
				(cZBZ)->ZBZ_VALOR  := (cQry)->OUTRAS_REC_FIN
				(cZBZ)->ZBZ_DC	   := "C"
				(cZBZ)->ZBZ_CREDIT := "41401001"
				(cZBZ)->ZBZ_HIST   := "OUTRAS RECEITAS FINANCEIRAS"
				(cZBZ)->(MsUnlock())

			Else

				lRet := .F.

				cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

			EndIf

		Else

			cMsg += "Dados para empresa " + cEmp + " mês: " + StrZero(nW, 2) + " não foram encontrados!"

			lRet := .F.

		EndIf

		(cQry)->(DbCloseArea())

	Next nW

	If Select(cZBZ) > 0

		(cZBZ)->(DbCloseArea())

	EndIf

Return(lRet)
