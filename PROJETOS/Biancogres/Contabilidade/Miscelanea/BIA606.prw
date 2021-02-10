#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA606
@author Wlysses Cerqueira (Facile)
@since 25/11/2020
@version 1.0
@description Processamento - RAC Orçada - Desdobra Mix de produção.
@type function
@Obs Projeto A-35
/*/

User Function BIA606()

	cCadastro := Upper(Alltrim("RAC Orçada - Desdobra Mix de produção"))
	aRotina   := { {"Pesquisar"       ,"AxPesqui"	    				,0,1},;
	{               "Visualizar"      ,"AxVisual"	    				,0,2},;
	{               "Processar"       ,'ExecBlock("BIA606A",.F.,.F.)'   ,0,3}}

	dbSelectArea("ZO5")
	dbSetOrder(1)
	dbGoTop()

	mBrowse(06,01,22,75,"ZO5")

Return

User Function BIA606A()

	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "RAC Orçada - Desdobra Mix de produção"
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

			MsgSTOP("Erro no processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA606")

		Else

			MsgINFO("Fim do processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA606")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "BIA606")

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

		cSql := " SELECT ZO5_FILIAL = '" + xFilial("ZO5") + "', "
		cSql += "        ZO5_VERSAO = " + ValToSql(cVersao) + ", "
		cSql += "        ZO5_REVISA = " + ValToSql(cRevisa) + ", "
		cSql += "        ZO5_ANOREF = " + ValToSql(cAnoRef) + ", "
		cSql += "        ZO5_DATARF = " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + ", "
		cSql += "        ZO5_COD    = B1_COD,  "
		cSql += "        ZO5_CONTA  = Z50_CONTA,  "
		cSql += "        ZO5_ITCUS  = Z50_ITCUS,  "
		cSql += "        ZO5_CSTUNT = Z50_M" + Alltrim(StrZero(nW,2)) + " "
		cSql += " FROM " + RetSqlName("Z50") + " Z50  "
		cSql += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON  "
		cSql += " ( "
		cSql += "   B1_FILIAL = '" + xFilial("SB1") + "' "
		cSql += "   AND SUBSTRING(B1_COD, 1, 7) = SUBSTRING(Z50_COD, 1, 7) "
		cSql += "   AND B1_YCLASSE IN(' ', '1') "
		cSql += "   AND SB1.D_E_L_E_T_ = ' ' "
		cSql += " ) "
		cSql += " INNER JOIN " + RetSqlName("Z29") + " Z29 ON   "
		cSql += " ( "
		cSql += "   Z29.Z29_FILIAL = '" + xFilial("Z29") + "' "
		cSql += "   AND Z29.Z29_COD_IT = Z50.Z50_ITCUS "
		cSql += "   AND Z29.Z29_APLIC = SB1.B1_TIPO "
		cSql += "   AND Z29.D_E_L_E_T_ = ' ' "
		cSql += " ) "
		cSql += " WHERE Z50.Z50_FILIAL = '" + xFilial("Z50") + "' "
		cSql += "       AND Z50_VERSAO = " + ValToSql(cVersao)
		cSql += "       AND Z50_REVISA = " + ValToSql(cRevisa)
		cSql += "       AND Z50_ANOREF = " + ValToSql(cAnoRef)
		cSql += "       AND Z50.D_E_L_E_T_ = ' ' "
		cSql += " ORDER BY B1_COD,  "
		cSql += "         Z50_ITCUS "

		TcQuery cSQL New Alias (cQry)

		ProcRegua(0)
		While !(cQry)->(Eof())

			IncProc("Processando Registros encontrados na base...")

			Reclock("ZO5", .T.)
			ZO5->ZO5_FILIAL := (cQry)->ZO5_FILIAL
			ZO5->ZO5_VERSAO := (cQry)->ZO5_VERSAO
			ZO5->ZO5_REVISA := (cQry)->ZO5_REVISA
			ZO5->ZO5_ANOREF := (cQry)->ZO5_ANOREF
			ZO5->ZO5_COD    := (cQry)->ZO5_COD   
			ZO5->ZO5_CONTA  := (cQry)->ZO5_CONTA 
			ZO5->ZO5_ITCUS  := (cQry)->ZO5_ITCUS 
			ZO5->ZO5_CSTUNT := (cQry)->ZO5_CSTUNT
			ZO5->ZO5_DATARF := STOD((cQry)->ZO5_DATARF)
			ZO5->(MsUnlock())

			(cQry)->(DbSkip())

		End

		(cQry)->(DbCloseArea())

		If !lRet

			Exit

		EndIf

	Next nW

	xVerRet := lRet 

Return ( lRet )

Static Function ExistThenD(msFil, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL  := ""
	Local cQry  := ""
	Local lPerg := .T.
	Local lRet  := .T.

	Default cMsg := ""

	cQry := GetNextAlias()

	cSql := " SELECT R_E_C_N_O_ RECNO "
	cSql += " FROM " + RetFullName("ZO5", cEmpAnt) + " ZO5 (NOLOCK) "
	cSql += " WHERE ZO5_FILIAL = '" + xFilial("ZO5") + "' "
	cSql += "       AND ZO5_VERSAO = " + ValToSql(cVersao)
	cSql += "       AND ZO5_REVISA = " + ValToSql(cRevisa)
	cSql += "       AND ZO5_ANOREF = " + ValToSql(cAnoRef)
	cSql += "       AND ZO5.D_E_L_E_T_ = ' ' "

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

		ZO5->(DBGoTo((cQry)->RECNO))
		If !ZO5->(EOF())

			Reclock("ZO5", .F.)
			ZO5->(DBDelete())
			ZO5->(MsUnlock())

		EndIf

		(cQry)->(DbSkip())

	End

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return ( lRet )
