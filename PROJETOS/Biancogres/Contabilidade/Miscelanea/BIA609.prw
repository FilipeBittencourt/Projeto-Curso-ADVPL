#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA609
@author Wlysses Cerqueira (Facile)
@since 25/11/2020
@version 1.0
@description Processamento - RAC Orçada - Desdobra capacidade produtiva.
@type function
@Obs Projeto A-35
/*/

User Function BIA609()

	cCadastro := Upper(Alltrim("RAC Orçada - Proc. Custo Unitário Variável"))
	aRotina   := { {"Pesquisar"       ,"AxPesqui"	    				,0,1},;
	{               "Visualizar"      ,"AxVisual"	    				,0,2},;
	{               "Processar"       ,'ExecBlock("BIA609A",.F.,.F.)'   ,0,3}}

	_bCondicao := {|| ZO8_TPCUS = 'CV' }
	_cCondicao := "ZO8_TPCUS = 'CV'"
	DbSelectArea("ZO8")
	DbSetOrder(1)
	DbSetFilter(_bCondicao, _cCondicao)	

	mBrowse(06,01,22,75,"ZO8")

Return

User Function BIA609A()

	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "RAC Orçada - Proc. Custo Unitário Variável"
	Private msCanPrc  := .F.

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte()

		Begin Transaction

			xVerRet := .F.
			Processa({ || ExistThenD(cFilAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Deletando dados...", .F.)
			If xVerRet

				Processa({ || fProcessa(cFilAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Processando dados...", .F.)
				lRet := xVerRet 

				If xVerRet

					Processa({ || fProcC1(cFilAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Processando dados...", .F.)
					lRet := xVerRet 

				Else

					msCanPrc  := .T.

				EndIf

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

			MsgSTOP("Erro no processamento!" + CRLF + CRLF + cMsg, "Empresa: [" + cEmpAnt + "]  - ATENÇÃO")

		Else

			MsgINFO("Fim do processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "BIA609")

	EndIf

Return

Static Function fProcessa(msFil, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL := ""
	Local nW   := 0
	Local cQry := ""

	Local lRet	:= .T.

	Default cMsg    := ""

	ProcRegua(0)
	For nW := 1 To 12

		IncProc("Processando Registros encontrados na base...")

		cQry := GetNextAlias()

		cSql := " WITH CVPROCESS01 "
		cSql += "     AS (SELECT ZO5.ZO5_VERSAO VERSAO,  "
		cSql += "                ZO5.ZO5_REVISA REVISA,  "
		cSql += "                ZO5.ZO5_ANOREF ANOREF,  "
		cSql += "                ZO5.ZO5_DATARF DTREF,  "
		cSql += "                ZO5.ZO5_COD PRODUT,  "
		cSql += "                ZO5.ZO5_ITCUS ITCUS,  "
		cSql += "                SUM(ZO5.ZO5_CSTUNT) CUS218 "
		cSql += "         FROM " + RetFullName("ZO5", cEmpAnt) + " ZO5  "
		cSql += "         WHERE ZO5.ZO5_FILIAL = '" + xFilial("ZO5") + "' "
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
		cSql += "             FROM " + RetFullName("ZO4", cEmpAnt) + " ZO4  "
		cSql += "             WHERE ZO4.ZO4_FILIAL = '" + xFilial("ZO4") + "' "
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
		cSql += "          INNER JOIN " + RetFullName("Z29", cEmpAnt) + " Z29 ON Z29_FILIAL = '" + xFilial("Z29") + "' "
		cSql += "                                   AND Z29_COD_IT = ITCUS "
		cSql += "                                   AND Z29.D_E_L_E_T_ = ' ' "
		cSql += "     ORDER BY DTREF,  "
		cSql += "              PRODUT,  "
		cSql += "              ITCUS "

		TcQuery cSQL New Alias (cQry)

		ProcRegua(0)
		While !(cQry)->(Eof())

			IncProc("Processando Registros encontrados na base...")

			Reclock("ZO8", .T.)
			ZO8->ZO8_FILIAL  := xFilial("ZO8")
			ZO8->ZO8_VERSAO  := cVersao
			ZO8->ZO8_REVISA  := cRevisa
			ZO8->ZO8_ANOREF  := cAnoRef
			ZO8->ZO8_TPCUS	 := (cQry)->Z29_TIPO
			ZO8->ZO8_ITCUS   := (cQry)->ITCUS
			ZO8->ZO8_PRODUT  := (cQry)->PRODUT
			ZO8->ZO8_DTREF   := STOD((cQry)->DTREF)
			ZO8->ZO8_CUS218  := (cQry)->CUS218
			ZO8->ZO8_CUS221  := (cQry)->CUS221
			ZO8->ZO8_CUS220  := (cQry)->CUS220
			ZO8->ZO8_CUS223  := (cQry)->CUS223
			ZO8->ZO8_CUS224  := (cQry)->CUS224
			ZO8->(MsUnlock())

			(cQry)->(DbSkip())

		End

		(cQry)->(DbCloseArea())

	Next nW

	xVerRet := lRet 

Return(lRet)

Static Function fProcC1(msFil, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL := ""
	Local nW   := 0
	Local cQry := ""

	Local lRet	:= .T.

	Default cMsg    := ""

	ProcRegua(0)
	For nW := 1 To 12

		IncProc("Processando Registros encontrados na base...")

		cQry := GetNextAlias()

		cSql := " WITH PROCESSC1 "
		cSql += "      AS (SELECT Z47_PRODUT PRODUT, "
		cSql += "                 Z47_QTDM" + StrZero(nW, 2) + " QTDMES, "
		cSql += "                 GG_COMP COMP, "
		cSql += "                 GG_FIM DTFIM "
		cSql += "          FROM " + RetFullName("Z47", cEmpAnt) + " Z47(NOLOCK) "
		cSql += "               INNER JOIN " + RetFullName("SGG", cEmpAnt) + " SGG(NOLOCK) ON GG_FILIAL = '" + xFilial("SGG") + "' "
		cSql += "                                                AND GG_COD = Z47_PRODUT "
		cSql += "                                                AND SUBSTRING(GG_COMP, 1, 2) = 'C1' "
		cSql += "                                                AND SUBSTRING(GG_FIM, 1, 4) = Z47_ANOREF "
		cSql += "                                                AND SUBSTRING(GG_FIM, 5, 2) = '01' "
		cSql += "                                                AND SUBSTRING(GG_FIM, 5, 4) <> '0101' "
		cSql += "                                                AND SGG.D_E_L_E_T_ = ' ' "
		cSql += "          WHERE Z47_FILIAL = '" + xFilial("Z47") + "' "
		cSql += "                AND Z47_VERSAO = " + ValToSql(cVersao)
		cSql += "                AND Z47_REVISA = " + ValToSql(cRevisa)
		cSql += "                AND Z47_ANOREF = " + ValToSql(cAnoRef)
		cSql += "                AND SUBSTRING(Z47_PRODUT, 1, 2) IN('B9', 'BO', 'C6') "
		cSql += "                AND Z47.D_E_L_E_T_ = ' ') "
		cSql += "      SELECT ZO8_FILIAL, "
		cSql += "             ZO8_VERSAO, "
		cSql += "             ZO8_REVISA, "
		cSql += "             ZO8_ANOREF, "
		cSql += "             TPPROD = 'PP', "
		cSql += "             ZO8_TPCUS, "
		cSql += "             ZO8_ITCUS, "
		cSql += "             PRODUTO = SUBSTRING(PRODUT, 1, 7) + '        ', "
		cSql += "             ZO8_DTREF, "
		cSql += "             ZO8_CUS223 = QTDMES, "
		cSql += "             ZO8_CUS224 = QTDMES * (ZO8_CUS224 / ZO8_CUS223) "
		cSql += "      FROM " + RetFullName("ZO8", cEmpAnt) + " ZO8(NOLOCK) "
		cSql += "           INNER JOIN PROCESSC1 PC1 ON SUBSTRING(PC1.COMP, 1, 7) = SUBSTRING(ZO8.ZO8_PRODUT, 1, 7) "
		cSql += "                                       AND PC1.DTFIM = ZO8.ZO8_DTREF "
		cSql += "      WHERE ZO8_FILIAL = '" + xFilial("ZO8") + "' "
		cSql += "            AND ZO8_VERSAO = " + ValToSql(cVersao)
		cSql += "            AND ZO8_REVISA = " + ValToSql(cRevisa)
		cSql += "            AND ZO8_ANOREF = " + ValToSql(cAnoRef)
		cSql += "            AND ZO8_DTREF = " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef)))
		cSql += "            AND ZO8_TPCUS = 'CV' "
		cSql += "            AND ZO8.D_E_L_E_T_ = ' ' "

		TcQuery cSQL New Alias (cQry)

		ProcRegua(0)
		While !(cQry)->(Eof())

			IncProc("Processando Registros encontrados na base...")

			Reclock("ZO8", .T.)
			ZO8->ZO8_FILIAL  := xFilial("ZO8")
			ZO8->ZO8_VERSAO  := cVersao
			ZO8->ZO8_REVISA  := cRevisa
			ZO8->ZO8_ANOREF  := cAnoRef
			ZO8->ZO8_TPPROD	 := (cQry)->TPPROD
			ZO8->ZO8_TPCUS	 := (cQry)->ZO8_TPCUS
			ZO8->ZO8_ITCUS   := (cQry)->ZO8_ITCUS
			ZO8->ZO8_PRODUT  := (cQry)->PRODUTO
			ZO8->ZO8_DTREF   := STOD((cQry)->ZO8_DTREF)
			ZO8->ZO8_CUS223  := (cQry)->ZO8_CUS223
			ZO8->ZO8_CUS224  := (cQry)->ZO8_CUS224
			ZO8->(MsUnlock())

			(cQry)->(DbSkip())

		End

		(cQry)->(DbCloseArea())

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
	cSql += " FROM " + RetFullName("ZO8", cEmpAnt) + " ZO8 (NOLOCK) "
	cSql += " WHERE ZO8_FILIAL = '" + xFilial("ZO8") + "' "
	cSql += "       AND ZO8_VERSAO = " + ValToSql(cVersao)
	cSql += "       AND ZO8_REVISA = " + ValToSql(cRevisa)
	cSql += "       AND ZO8_ANOREF = " + ValToSql(cAnoRef)
	cSql += "       AND ZO8_TPCUS = 'CV' "
	cSql += "       AND ZO8.D_E_L_E_T_ = ' ' "

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

		ZO8->(DBGoTo((cQry)->RECNO))

		If !ZO8->(EOF())

			Reclock("ZO8", .F.)
			ZO8->(DBDelete())
			ZO8->(MsUnlock())

		EndIf

		(cQry)->(DbSkip())

	End

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return(lRet)
