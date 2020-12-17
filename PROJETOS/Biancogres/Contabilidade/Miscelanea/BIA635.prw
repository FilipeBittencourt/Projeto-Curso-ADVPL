#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA628
@author Wlysses Cerqueira (Facile)
@since 14/12/2020
@version 1.0
@Projet A-35
@description DRE - Calculo de Resultado para DRE - Proc IR e CSSL. 
@type Program
/*/

User Function BIA635()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	//RpcSetEnv("01", "01")

	Private cTitulo := "DRE - Calculo de Resultado para DRE - Proc IR e CSSL"

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

		cSql := "SELECT *,  "
		cSql += "	ISNULL(CASE WHEN LAIR - INVEST > 0 THEN ( ( (LAIR - INVEST) * IR01 / 100) + ( ( (LAIR - INVEST) - REDUZ_IR ) * IR02 / 100 ) ) ELSE 0 END, 0) IR, "
		cSql += "	ISNULL(( ( LAIR - INVEST ) * PER_CSSL / 100 ), 0) CSSL "
		cSql += "FROM "
		cSql += "( "
		cSql += "	SELECT PERIODO, SUM(VALOR) LAIR, "
		cSql += "	( "
		cSql += "		SELECT ZBZ_VALOR "
		cSql += "		FROM " + RetFullName("ZBZ", cEmp) + " "
		cSql += "		WHERE ZBZ_FILIAL = '01' "
        cSQL += "       AND ZBZ_VERSAO = " + ValToSql(cVersao)
		cSql += "		AND ZBZ_REVISA	 = " + ValToSql(cRevisa)
		cSql += "		AND ZBZ_ANOREF	 = " + ValToSql(cAnoRef)
		cSql += "		AND ZBZ_CREDIT	 = '41501010' "
		cSql += " 		AND ZBZ_DATA 	 BETWEEN " + ValToSql(FirstDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " AND " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " "
		cSql += "		AND D_E_L_E_T_	 = '' "
		cSql += "	) INVEST, "
		cSql += "	(  "
		cSql += "		SELECT ISNULL(ZOC_M01, 0) ZOC_M01 "
		cSql += "		FROM " + RetFullName("ZOC", cEmp) + "  "
		cSql += "		WHERE ZOC_FILIAL = ''  "
		cSql += "		AND ZOC_VERSAO	 = " + ValToSql(cVersao)
		cSql += "		AND ZOC_REVISA	 = " + ValToSql(cRevisa)
		cSql += "		AND ZOC_ANOREF	 = " + ValToSql(cAnoRef)
		cSql += "		AND ZOC_TIPO	 = '4' "
		// cSql += "		AND ZOC_LINHA	 = '001' "
		cSql += "		AND D_E_L_E_T_ = '' "
		cSql += "	) IR01, "
		cSql += "	(  "
		cSql += "		SELECT ISNULL(ZOC_M01, 0) ZOC_M01 "
		cSql += "		FROM " + RetFullName("ZOC", cEmp) + "  "
		cSql += "		WHERE ZOC_FILIAL = ''  "
		cSql += "		AND ZOC_VERSAO	 = " + ValToSql(cVersao)
		cSql += "		AND ZOC_REVISA	 = " + ValToSql(cRevisa)
		cSql += "		AND ZOC_ANOREF	 = " + ValToSql(cAnoRef)
		cSql += "		AND ZOC_TIPO	 = '5' "
		// cSql += "		AND ZOC_LINHA	 = '001' "
		cSql += "		AND D_E_L_E_T_ = '' "
		cSql += "	) IR02, "
		cSql += "	(  "
		cSql += "		SELECT ISNULL(ZOC_M01, 0) ZOC_M01 "
		cSql += "		FROM " + RetFullName("ZOC", cEmp) + "  "
		cSql += "		WHERE ZOC_FILIAL = ''  "
		cSql += "		AND ZOC_VERSAO	 = " + ValToSql(cVersao)
		cSql += "		AND ZOC_REVISA	 = " + ValToSql(cRevisa)
		cSql += "		AND ZOC_ANOREF	 = " + ValToSql(cAnoRef)
		cSql += "		AND ZOC_TIPO	 = '6' "
		// cSql += "		AND ZOC_LINHA	 = '001' "
		cSql += "		AND D_E_L_E_T_ = '' "
		cSql += "	) REDUZ_IR, "
		cSql += "	(  "
		cSql += "		SELECT ISNULL(ZOC_M01, 0) ZOC_M01 "
		cSql += "		FROM " + RetFullName("ZOC", cEmp) + "  "
		cSql += "		WHERE ZOC_FILIAL = ''  "
		cSql += "		AND ZOC_VERSAO	 = " + ValToSql(cVersao)
		cSql += "		AND ZOC_REVISA	 = " + ValToSql(cRevisa)
		cSql += "		AND ZOC_ANOREF	 = " + ValToSql(cAnoRef)
		cSql += "		AND ZOC_TIPO	 = '7' "
		// cSql += "		AND ZOC_LINHA	 = '001' "
		cSql += "		AND D_E_L_E_T_ = '' "
		cSql += "	) PER_CSSL "
		cSql += "	FROM  "
		cSql += "	( "
		cSql += "		SELECT 'D' DC,  "
		cSql += "			ZBZ_DEBITO CONTA,  "
		cSql += "			SUBSTRING(ZBZ_DATA, 1, 6) PERIODO,  "
		cSql += "			ZBZ_ORIPRC,  "
		cSql += "			ZBZ_DEBITO,  "
		cSql += "			SUM(ZBZ_VALOR) VALOR "
		cSql += "		FROM " + RetFullName("ZBZ", cEmp) + " "
		cSql += "		WHERE ZBZ_FILIAL = '01' "
        cSQL += "           AND ZBZ_VERSAO = " + ValToSql(cVersao)
		cSql += "			AND ZBZ_REVISA = " + ValToSql(cRevisa)
		cSql += "			AND ZBZ_ANOREF = " + ValToSql(cAnoRef)
		cSql += "			AND ZBZ_DEBITO <> '' "
		cSql += "			AND ZBZ_DEBITO NOT IN('31701004', '31701005') "
		cSql += " 			AND ZBZ_DATA 	BETWEEN " + ValToSql(FirstDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " AND " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " "
		cSql += "		AND D_E_L_E_T_ = '' "
		cSql += "		GROUP BY SUBSTRING(ZBZ_DATA, 1, 6),  "
		cSql += "				ZBZ_ORIPRC,  "
		cSql += "				ZBZ_DEBITO "
		cSql += "		UNION ALL "
		cSql += "		SELECT 'C' DC,  "
		cSql += "			ZBZ_CREDIT CONTA,  "
		cSql += "			SUBSTRING(ZBZ_DATA, 1, 6) PERIODO,  "
		cSql += "			ZBZ_ORIPRC,  "
		cSql += "			ZBZ_CREDIT,  "
		cSql += "			SUM(ZBZ_VALOR) * (-1) VALOR "
		cSql += "		FROM " + RetFullName("ZBZ", cEmp) + " "
		cSql += "		WHERE ZBZ_FILIAL = '01' "
        cSQL += "           AND ZBZ_VERSAO = " + ValToSql(cVersao)
		cSql += "			AND ZBZ_REVISA = " + ValToSql(cRevisa)
		cSql += "			AND ZBZ_ANOREF = " + ValToSql(cAnoRef)
		cSql += "			AND ZBZ_CREDIT <> '' "
		cSql += "			AND ZBZ_CREDIT NOT IN('31701004', '31701005') "
		cSql += " 			AND ZBZ_DATA 	BETWEEN " + ValToSql(FirstDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " AND " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " "
		cSql += "		AND D_E_L_E_T_ = '' "
		cSql += "		GROUP BY SUBSTRING(ZBZ_DATA, 1, 6),  "
		cSql += "				ZBZ_ORIPRC,  "
		cSql += "				ZBZ_CREDIT "
		cSql += "	) LAIR "
		cSql += "	GROUP BY PERIODO "
		cSql += ") TAB1 "

		TcQuery cSQL New Alias (cQry)

		If !(cQry)->(EOF())

			If EmpOpenFile(cZBZ, "ZBZ", 1, .T., cEmp, @cModo)

				If (cQry)->IR > 0

					Reclock(cZBZ,.T.)
					(cZBZ)->ZBZ_FILIAL := cEmp
					(cZBZ)->ZBZ_VERSAO := cVersao
					(cZBZ)->ZBZ_REVISA := cRevisa
					(cZBZ)->ZBZ_ANOREF := cAnoRef
					(cZBZ)->ZBZ_DATA   := LastDay(STOD((cQry)->PERIODO + "01"))
					(cZBZ)->ZBZ_VALOR  := (cQry)->IR
					(cZBZ)->ZBZ_DC	   := "D"
					(cZBZ)->ZBZ_DEBITO := "31701004"
					(cZBZ)->ZBZ_HIST   := "IMPOSTO DE RENDA RETIDO NA FONTE"
					(cZBZ)->(MsUnlock())

				EndIf

				If (cQry)->CSSL > 0

					Reclock(cZBZ,.T.)
					(cZBZ)->ZBZ_FILIAL := cEmp
					(cZBZ)->ZBZ_VERSAO := cVersao
					(cZBZ)->ZBZ_REVISA := cRevisa
					(cZBZ)->ZBZ_ANOREF := cAnoRef
					(cZBZ)->ZBZ_DATA   := LastDay(STOD((cQry)->PERIODO + "01"))
					(cZBZ)->ZBZ_VALOR  := (cQry)->CSSL
					(cZBZ)->ZBZ_DC	   := "D"
					(cZBZ)->ZBZ_DEBITO := "31701005"
					(cZBZ)->ZBZ_HIST   := "CONTRIBUICAO SOCIAL S/ LUCRO"
					(cZBZ)->(MsUnlock())

				EndIf

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
