#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA603
@author Wlysses Cerqueira (Facile)
@since 25/11/2020
@version 1.0
@Projet A-35
@description Processamento - RAC Orçada - Desdobra capacidade produtiva.
@type function
/*/

User Function BIA603()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "RAC Orçada - Desdobra capacidade produtiva"

	oEmp := TLoadEmpresa():New()

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte()

		oEmp:GetSelEmp()

		If Len(oEmp:aEmpSel) > 0

			Begin Transaction

				For nW := 1 To Len(oEmp:aEmpSel)

					If ExistThenDelete(oEmp:aEmpSel[nW][1], oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg)

						lRet := Processa(oEmp:aEmpSel[nW][1], oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg)

						If !lRet

							Exit

						EndIf

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

Return()

Static Function Processa(cEmp, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL := ""
	Local nW   := 0
	Local cQry := ""

	Local lRet	:= .T.
	Local cModo //Modo de acesso do arquivo aberto //"E" ou "C"
	Local cZO4	:= GetNextAlias()

	Default cMsg := ""

	For nW := 1 To 12

		cQry := GetNextAlias()

		cSql := " SELECT ZO4_FILIAL = " + ValToSql(cEmp) + ", "
		cSql += "        ZO4_VERSAO = " + ValToSql(cVersao) + ", "
		cSql += "        ZO4_REVISA = " + ValToSql(cRevisa) + ", "
		cSql += "        ZO4_ANOREF = " + ValToSql(cAnoRef) + ", "
		cSql += "        ZO4_DATARF = " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + ", "
		cSql += "        ZO4_PRODUT = B1_COD,  "
		cSql += "        ZO4_LINHA  = Z42_LINHA,  "
		cSql += "        ZO4_CAPACI = Z42_CAPACI * CASE "
		cSql += "                                      WHEN Z42_DISTRI = 0 "
		cSql += "                                      THEN 1 "
		cSql += "                                      ELSE Z42_DISTRI "
		cSql += "                                  END,  "
		cSql += "        ZO4_PSECO = Z42_PSECO,  "
		cSql += "        ZO4_QTDRAC = Z47_QTDM" + StrZero(nW, 2)
		cSql += " FROM " + RetFullName("Z47", cEmp) + " Z47 (NOLOCK) "

		cSql += " INNER JOIN " + RetFullName("SB1", cEmp) + " SB1 (NOLOCK) ON "
		cSql += " ( "
		cSql += "   B1_FILIAL = '  ' "
		cSql += "   AND SUBSTRING(B1_COD, 1, 7) = SUBSTRING(Z47_PRODUT, 1, 7) "
		cSql += "   AND B1_YCLASSE              IN (' ', '1') "
		cSql += "   AND SB1.D_E_L_E_T_          = ' ' "
		cSql += " ) "

		cSql += " INNER JOIN " + RetFullName("Z42", cEmp) + " Z42 (NOLOCK) ON "
		cSql += " ( "
		cSql += "   Z42_FILIAL          = '  ' "
		cSql += "   AND Z42_FORMAT      = B1_YFORMAT "
		cSql += "   AND Z42_BASE        = B1_YBASE "
		cSql += "   AND Z42_ACABAM      LIKE '%' + B1_YACABAM + '%' "
		cSql += "   AND Z42_ESPESS      LIKE '%' + B1_YESPESS + '%' "
		cSql += "   AND Z42_TPPROD      LIKE '%' + B1_TIPO + '%' "
		cSql += "   AND " + ValToSql(FirstDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " >= Z42_DTINI "
		cSql += "   AND " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + " <= Z42_DTFIM "
		cSql += "   AND Z42_VERSAO      = Z47_VERSAO "
		cSql += "   AND Z42_REVISA      = Z47_REVISA "
		cSql += "   AND Z42_ANOREF      = Z47_ANOREF "
		cSql += "   AND Z42_FINALI      = 'O' "
		cSql += "   AND Z42.D_E_L_E_T_  = ' ' "
		cSql += " ) "

		cSql += " WHERE Z47_FILIAL      = ' ' "
		cSql += " AND Z47_VERSAO        = " + ValToSql(cVersao)
		cSql += " AND Z47_REVISA        = " + ValToSql(cRevisa)
		cSql += " AND Z47_ANOREF        = " + ValToSql(cAnoRef)
		cSql += " AND Z47_QTDM" + StrZero(nW, 2) + " <> 0 "
		cSql += " AND Z47.D_E_L_E_T_    = ' ' "
		cSql += " ORDER BY B1_COD "

		TcQuery cSQL New Alias (cQry)

		While !(cQry)->(Eof())

			IF EmpOpenFile(cZO4, "ZO4", 1, .T., cEmp, @cModo)

				Reclock(cZO4, .T.)
				(cZO4)->ZO4_FILIAL := (cQry)->ZO4_FILIAL
				(cZO4)->ZO4_VERSAO := (cQry)->ZO4_VERSAO
				(cZO4)->ZO4_REVISA := (cQry)->ZO4_REVISA
				(cZO4)->ZO4_ANOREF := (cQry)->ZO4_ANOREF
				(cZO4)->ZO4_PRODUT := (cQry)->ZO4_PRODUT
				(cZO4)->ZO4_LINHA  := (cQry)->ZO4_LINHA
				(cZO4)->ZO4_CAPACI := (cQry)->ZO4_CAPACI
				(cZO4)->ZO4_PSECO  := (cQry)->ZO4_PSECO
				(cZO4)->ZO4_QTDRAC := (cQry)->ZO4_QTDRAC
				(cZO4)->ZO4_DATARF := STOD((cQry)->ZO4_DATARF)
				(cZO4)->(MsUnlock())

			Else

				lRet := .F.

				cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

				Exit

			EndIf

			If Select(cZO4) > 0

				(cZO4)->(DbCloseArea())

			EndIf

			(cQry)->(DbSkip())

		EndDo

		(cQry)->(DbCloseArea())

		If !lRet

			Exit

		EndIf

	Next nW

Return(lRet)

Static Function ExistThenDelete(cEmp, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL  := ""
	Local cQry  := ""
	Local lPerg := .T.
	Local lRet  := .T.

	Local cModo //Modo de acesso do arquivo aberto //"E" ou "C"
	Local cZO4	:= GetNextAlias()

	Default cMsg := ""

	cQry := GetNextAlias()

	cSql := " SELECT R_E_C_N_O_ RECNO "
	cSql += " FROM " + RetFullName("ZO4", cEmp) + " ZO4 (NOLOCK) "
	cSql += " WHERE ZO4_FILIAL      = " + ValToSql(cEmp)
	cSql += " AND ZO4_VERSAO        = " + ValToSql(cVersao)
	cSql += " AND ZO4_REVISA        = " + ValToSql(cRevisa)
	cSql += " AND ZO4_ANOREF        = " + ValToSql(cAnoRef)
	cSql += " AND ZO4.D_E_L_E_T_    = ' ' "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		If lPerg

			If MsgYesNo("Já existem dados para o tempo orçamentário. Deseja continuar?" + CRLF + CRLF + "Caso clique em sim esses dados serão apagados e gerados novos!", "Empresa: [" + cEmp + "]  - ATENÇÃO")

				lRet := .T.

			Else

				lRet := .F.

				Exit

			EndIf

			lPerg := .F.

		EndIf

		If EmpOpenFile(cZO4, "ZO4", 1, .T., cEmp, @cModo)

			(cZO4)->(DBGoTo((cQry)->RECNO))

			If !(cZO4)->(EOF())

				Reclock(cZO4, .F.)
				(cZO4)->(DBDelete())
				(cZO4)->(MsUnlock())

			EndIf

		Else

			lRet := .F.

			cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

		EndIf

		If Select(cZO4) > 0

			(cZO4)->(DbCloseArea())

		EndIf

		(cQry)->(DbSkip())

	EndDo

	(cQry)->(DbCloseArea())

Return(lRet)
