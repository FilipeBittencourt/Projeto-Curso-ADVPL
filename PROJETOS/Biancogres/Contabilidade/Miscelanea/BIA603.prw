#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA603
@author Wlysses Cerqueira (Facile)
@since 25/11/2020
@version 1.0
@description Processamento - RAC Orçada - Desdobra capacidade produtiva.
@type function
@Obs Projeto A-35
/*/

User Function BIA603()

	cCadastro := Upper(Alltrim("RAC Orçada - Desdobra capacidade produtiva"))
	aRotina   := { {"Pesquisar"       ,"AxPesqui"	    				,0,1},;
	{               "Visualizar"      ,"AxVisual"	    				,0,2},;
	{               "Processar"       ,'ExecBlock("BIA603A",.F.,.F.)'   ,0,3}}

	dbSelectArea("ZO4")
	dbSetOrder(1)
	dbGoTop()

	mBrowse(06,01,22,75,"ZO4")

Return

User Function BIA603A()

	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo   := "RAC Orçada - Desdobra capacidade produtiva"
	Private msCanPrc  := .F.

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte()

		Begin Transaction

			xVerRet := .F.
			Processa({ || ExistThenD(cFilAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Deletando dados...", .F.)
			If xVerRet

				Processa({ || fProcessa(cFilAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Processando dados...", .F.)
				lRet := xVerRet 

			Else

				msCanPrc  := .T.

			EndIf

			If !lRet

				DisarmTransaction()

			EndIf

		End Transaction

	Else

		msCanPrc  := .T.

	EndIf

	If !msCanPrc

		If !lRet

			MsgSTOP("Erro no processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA603")

		Else

			MsgINFO("Fim do processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA603")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "BIA603")

	EndIf

Return

Static Function fProcessa(msFil, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL := ""
	Local nW   := 0
	Local cQry := ""

	Local lRet	:= .T.

	Default cMsg := ""

	ProcRegua(0)
	For nW := 1 To 12

		IncProc("Processando Registros encontrados na base...")

		cQry := GetNextAlias()

		cSql := " SELECT ZO4_FILIAL = '" + xFilial("ZO4") + "', "
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
		cSql += " FROM " + RetFullName("Z47", cEmpAnt) + " Z47 (NOLOCK) "

		cSql += " INNER JOIN " + RetFullName("SB1", cEmpAnt) + " SB1 (NOLOCK) ON "
		cSql += " ( "
		cSql += "   B1_FILIAL = '" + xFilial("SB1") + "' " "
		cSql += "   AND SUBSTRING(B1_COD, 1, 7) = SUBSTRING(Z47_PRODUT, 1, 7) "
		cSql += "   AND B1_YCLASSE              IN (' ', '1') "
		cSql += "   AND SB1.D_E_L_E_T_          = ' ' "
		cSql += " ) "

		cSql += " INNER JOIN " + RetFullName("Z42", cEmpAnt) + " Z42 (NOLOCK) ON "
		cSql += " ( "
		cSql += "   Z42_FILIAL = '" + xFilial("Z42") + "' " "
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

		cSql += " WHERE Z47_FILIAL      = '" + xFilial("Z47") + "' "
		cSql += " AND Z47_VERSAO        = " + ValToSql(cVersao)
		cSql += " AND Z47_REVISA        = " + ValToSql(cRevisa)
		cSql += " AND Z47_ANOREF        = " + ValToSql(cAnoRef)
		cSql += " AND Z47_QTDM" + StrZero(nW, 2) + " <> 0 "
		cSql += " AND Z47.D_E_L_E_T_    = ' ' "
		cSql += " ORDER BY B1_COD "

		TcQuery cSQL New Alias (cQry)

		ProcRegua(0)
		While !(cQry)->(Eof())

			IncProc("Processando Registros encontrados na base...")

			Reclock("ZO4", .T.)
			ZO4->ZO4_FILIAL := (cQry)->ZO4_FILIAL
			ZO4->ZO4_VERSAO := (cQry)->ZO4_VERSAO
			ZO4->ZO4_REVISA := (cQry)->ZO4_REVISA
			ZO4->ZO4_ANOREF := (cQry)->ZO4_ANOREF
			ZO4->ZO4_PRODUT := (cQry)->ZO4_PRODUT
			ZO4->ZO4_LINHA  := (cQry)->ZO4_LINHA
			ZO4->ZO4_CAPACI := (cQry)->ZO4_CAPACI
			ZO4->ZO4_PSECO  := (cQry)->ZO4_PSECO
			ZO4->ZO4_QTDRAC := (cQry)->ZO4_QTDRAC
			ZO4->ZO4_DATARF := STOD((cQry)->ZO4_DATARF)
			ZO4->(MsUnlock())

			(cQry)->(DbSkip())

		EndDo

		(cQry)->(DbCloseArea())

		If !lRet

			Exit

		EndIf

	Next nW

	xVerRet := lRet 

Return(lRet)

Static Function ExistThenD(msFil, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL  := ""
	Local cQry  := ""
	Local lPerg := .T.
	Local lRet  := .T.

	Default cMsg := ""

	cQry := GetNextAlias()

	cSql := " SELECT R_E_C_N_O_ RECNO "
	cSql += " FROM " + RetFullName("ZO4", cEmpAnt) + " ZO4 (NOLOCK) "
	cSql += " WHERE ZO4_FILIAL = '" + xFilial("ZO4") + "' "
	cSql += "       AND ZO4_VERSAO = " + ValToSql(cVersao)
	cSql += "       AND ZO4_REVISA = " + ValToSql(cRevisa)
	cSql += "       AND ZO4_ANOREF = " + ValToSql(cAnoRef)
	cSql += "       AND ZO4.D_E_L_E_T_    = ' ' "

	TcQuery cSQL New Alias (cQry)

	ProcRegua(0)
	While !(cQry)->(Eof())

		IncProc("Apagando Registros encontrados na base...")

		If lPerg

			If MsgYesNo("Já existem dados para o tempo orçamentário. Deseja continuar?" + CRLF + CRLF + "Caso clique em sim esses dados serão apagados e gerados novos!", "Empresa: [" + cEmpAnt + "]  - ATENÇÃO")

				lRet := .T.

			Else

				lRet := .F.

				Exit

			EndIf

			lPerg := .F.

		EndIf

		ZO4->(DBGoTo((cQry)->RECNO))
		If !ZO4->(EOF())

			Reclock("ZO4", .F.)
			ZO4->(DBDelete())
			ZO4->(MsUnlock())

		EndIf

		(cQry)->(DbSkip())

	End

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return ( lRet )
