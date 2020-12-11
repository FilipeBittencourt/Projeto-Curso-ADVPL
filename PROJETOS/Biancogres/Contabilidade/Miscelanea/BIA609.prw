#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA609
@author Wlysses Cerqueira (Facile)
@since 25/11/2020
@version 1.0
@Projet A-35
@description Processamento - RAC Orçada - Desdobra capacidade produtiva.
@type function
/*/

User Function BIA609()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "RAC Orçada - Proc. Custo Unitário Variável"

	//RpcSetEnv("01", "01")

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

	//RpcClearEnv()

Return()

Static Function Processa(cEmp, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL := ""
	Local nW   := 0
	Local cQry := ""

	Local lRet	:= .T.
	Local cModo //Modo de acesso do arquivo aberto //"E" ou "C"
	Local cZO8	:= ""

	Default cMsg    := ""

	For nW := 1 To 12

		cQry := GetNextAlias()

		cSql := " WITH CVPROCESS01 "
		cSql += "     AS (SELECT ZO5.ZO5_VERSAO VERSAO,  "
		cSql += "                ZO5.ZO5_REVISA REVISA,  "
		cSql += "                ZO5.ZO5_ANOREF ANOREF,  "
		cSql += "                ZO5.ZO5_DATARF DTREF,  "
		cSql += "                ZO5.ZO5_COD PRODUT,  "
		cSql += "                ZO5.ZO5_ITCUS ITCUS,  "
		cSql += "                SUM(ZO5.ZO5_CSTUNT) CUS218 "
		cSql += "         FROM " + RetFullName("ZO5", cEmp) + " ZO5  "
		cSql += "         WHERE ZO5.ZO5_FILIAL     = " + ValToSql(cEmp)
		cSql += "               AND ZO5.ZO5_VERSAO = " + ValToSql(cVersao)
		cSql += "               AND ZO5.ZO5_REVISA = " + ValToSql(cRevisa)
		cSql += "               AND ZO5.ZO5_ANOREF = " + ValToSql(cAnoRef)
		cSql += "               AND ZO5.ZO5_DATARF = " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef)))
		cSql += "               AND ZO5.D_E_L_E_T_ = ' ' "
		cSql += "         GROUP BY ZO5.ZO5_VERSAO,  "
		cSql += "                  ZO5.ZO5_REVISA,  "
		cSql += "                  ZO5.ZO5_ANOREF,  "
		cSql += "                  ZO5.ZO5_DATARF,  "
		cSql += "                  ZO5.ZO5_COD,  "
		cSql += "                  ZO5.ZO5_ITCUS), "
		cSql += "     CVPROCESS02 "
		cSql += "     AS (SELECT *,  "
		cSql += "                CUS221 = "
		cSql += "         ( "
		cSql += "             SELECT SUM(ZO4.ZO4_QTDRAC) "
		cSql += "             FROM " + RetFullName("ZO4", cEmp) + " ZO4  "
		cSql += "             WHERE ZO4.ZO4_FILIAL     = " + ValToSql(cEmp)
		cSql += "                   AND ZO4.ZO4_VERSAO = CVP01.VERSAO "
		cSql += "                   AND ZO4.ZO4_REVISA = CVP01.REVISA "
		cSql += "                   AND ZO4.ZO4_ANOREF = CVP01.ANOREF "
		cSql += "                   AND ZO4.ZO4_DATARF = CVP01.DTREF "
		cSql += "                   AND ZO4.ZO4_PRODUT = CVP01.PRODUT "
		cSql += "                   AND ZO4.D_E_L_E_T_ = ' ' "
		cSql += "         ) "
		cSql += "         FROM CVPROCESS01 CVP01), "
		cSql += "     CVPROCESS03 "
		cSql += "     AS (SELECT *,  "
		cSql += "                CUS220 = CUS218 * CUS221 "
		cSql += "         FROM CVPROCESS02) "
		cSql += "     SELECT Z29.Z29_TIPO,  "
		cSql += "            Z29.Z29_DESCR,  "
		cSql += "            CVPR03.*,  "
		cSql += "            CUS223 = CUS221, "
		cSql += "            CUS224 = CUS220 "
		cSql += "     FROM CVPROCESS03 CVPR03 "
		cSql += "          INNER JOIN " + RetFullName("Z29", cEmp) + " Z29 ON Z29_FILIAL = '  ' "
		cSql += "                                   AND Z29_COD_IT = ITCUS "
		cSql += "                                   AND Z29.D_E_L_E_T_ = ' ' "
		cSql += "     ORDER BY DTREF,  "
		cSql += "              PRODUT,  "
		cSql += "              ITCUS "

		TcQuery cSQL New Alias (cQry)

		cZO8 := GetNextAlias()

		While !(cQry)->(Eof())

			IF EmpOpenFile(cZO8, "ZO8", 1, .T., cEmp, @cModo)

				Reclock(cZO8, .T.)
				(cZO8)->ZO8_FILIAL  := cEmp
				(cZO8)->ZO8_VERSAO  := cVersao
				(cZO8)->ZO8_REVISA  := cRevisa
				(cZO8)->ZO8_ANOREF  := cAnoRef
				(cZO8)->ZO8_TPCUS	:= (cQry)->Z29_TIPO
				(cZO8)->ZO8_ITCUS   := (cQry)->ITCUS
				(cZO8)->ZO8_PRODUT  := (cQry)->PRODUT
				// (cZO8)->ZO8_DESCR   := (cQry)->Z29_DESCR
				(cZO8)->ZO8_DTREF   := STOD((cQry)->DTREF)
				(cZO8)->ZO8_CUS218  := (cQry)->CUS218
				(cZO8)->ZO8_CUS221  := (cQry)->CUS221
				(cZO8)->ZO8_CUS220  := (cQry)->CUS220
				(cZO8)->ZO8_CUS223  := (cQry)->CUS223
				(cZO8)->ZO8_CUS224  := (cQry)->CUS224
				(cZO8)->(MsUnlock())

			Else

				lRet := .F.

				cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

				Exit

			EndIf

			If Select(cZO8) > 0

				(cZO8)->(DbCloseArea())

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
	Local cZO8	:= GetNextAlias()

	Default cMsg := ""

	cQry := GetNextAlias()

	cSql := " SELECT R_E_C_N_O_ RECNO "
	cSql += " FROM " + RetFullName("ZO8", cEmp) + " ZO8 (NOLOCK) "
	cSql += " WHERE ZO8_FILIAL      = " + ValToSql(cEmp)
	cSql += " AND ZO8_VERSAO        = " + ValToSql(cVersao)
	cSql += " AND ZO8_REVISA        = " + ValToSql(cRevisa)
	cSql += " AND ZO8_ANOREF        = " + ValToSql(cAnoRef)
	cSql += " AND ZO8_TPCUS         = 'CV' "
	cSql += " AND ZO8.D_E_L_E_T_    = ' ' "

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

		If EmpOpenFile(cZO8, "ZO8", 1, .T., cEmp, @cModo)

			(cZO8)->(DBGoTo((cQry)->RECNO))

			If !(cZO8)->(EOF())

				Reclock(cZO8, .F.)
				(cZO8)->(DBDelete())
				(cZO8)->(MsUnlock())

			EndIf

		Else

			lRet := .F.

			cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

		EndIf

		If Select(cZO8) > 0

			(cZO8)->(DbCloseArea())

		EndIf

		(cQry)->(DbSkip())

	EndDo

	(cQry)->(DbCloseArea())

Return(lRet)
