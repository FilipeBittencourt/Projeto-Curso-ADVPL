#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

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

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "RAC Orçada - Desdobra Mix de produção"
	Private msCanPrc  := .F.

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

					Else

						msCanPrc  := .T.

					EndIf

				Next nW

				If !lRet

					DisarmTransaction()

				EndIf

			End Transaction

		Else

			Alert("Nenhuma empresa foi selecionada!")
			msCanPrc  := .T.

		EndIf


	Else

		msCanPrc  := .T.

	EndIf

	If !msCanPrc

		If !lRet

			MsgSTOP("Erro no processamento!" + CRLF + CRLF + cMsg, "Empresa: [" + cEmp + "]  - ATENÇÃO")

		Else

			MsgINFO("Fim do processamento!" + CRLF + CRLF + cMsg, "Empresa: [" + cEmp + "]  - ATENÇÃO")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "BIA606")

	EndIf


Return

Static Function Processa(cEmp, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL := ""
	Local nW   := 0
	Local cQry := ""

	Local lRet	:= .T.
	Local cModo //Modo de acesso do arquivo aberto //"E" ou "C"
	Local cZO5	:= GetNextAlias()

	Default cMsg := ""

	For nW := 1 To 12

		cQry := GetNextAlias()

		cSql := " SELECT ZO5_FILIAL = " + ValToSql(cEmp) + ", "
		cSql += "        ZO5_VERSAO = " + ValToSql(cVersao) + ", "
		cSql += "        ZO5_REVISA = " + ValToSql(cRevisa) + ", "
		cSql += "        ZO5_ANOREF = " + ValToSql(cAnoRef) + ", "
		cSql += "        ZO5_DATARF = " + ValToSql(LastDay(CToD("01" + "/" + StrZero(nW, 2) + "/" + cAnoRef))) + ", "
		cSql += "        ZO5_COD    = B1_COD,  "
		cSql += "        ZO5_CONTA  = Z50_CONTA,  "
		cSql += "        ZO5_ITCUS  = Z50_ITCUS,  "
		cSql += "        ZO5_CSTUNT = Z50_M01 "
		cSql += " FROM " + RetSqlName("Z50") + " Z50  "
		cSql += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON  "
		cSql += " ( "
		cSql += "   B1_FILIAL = '  ' "
		cSql += "   AND SUBSTRING(B1_COD, 1, 7) = SUBSTRING(Z50_COD, 1, 7) "
		cSql += "   AND B1_YCLASSE IN(' ', '1') "
		cSql += "   AND SB1.D_E_L_E_T_ = ' ' "
		cSql += " ) "
		cSql += " INNER JOIN " + RetSqlName("Z29") + " Z29 ON   "
		cSql += " ( "
		cSql += "   Z29.Z29_FILIAL = '  ' "
		cSql += "   AND Z29.Z29_COD_IT = Z50.Z50_ITCUS "
		cSql += "   AND Z29.D_E_L_E_T_ = ' ' "
		cSql += " ) "
		cSql += " WHERE Z50.Z50_FILIAL = ' ' "
		cSql += "       AND Z50_VERSAO = " + ValToSql(cVersao)
		cSql += "       AND Z50_REVISA = " + ValToSql(cRevisa)
		cSql += "       AND Z50_ANOREF = " + ValToSql(cAnoRef)
		cSql += "       AND Z50.D_E_L_E_T_ = ' ' "
		cSql += " ORDER BY B1_COD,  "
		cSql += "         Z50_ITCUS "

		TcQuery cSQL New Alias (cQry)

		While !(cQry)->(Eof())

			IF EmpOpenFile(cZO5, "ZO5", 1, .T., cEmp, @cModo)

				Reclock(cZO5, .T.)
				(cZO5)->ZO5_FILIAL := (cQry)->ZO5_FILIAL
				(cZO5)->ZO5_VERSAO := (cQry)->ZO5_VERSAO
				(cZO5)->ZO5_REVISA := (cQry)->ZO5_REVISA
				(cZO5)->ZO5_ANOREF := (cQry)->ZO5_ANOREF
				(cZO5)->ZO5_COD    := (cQry)->ZO5_COD   
				(cZO5)->ZO5_CONTA  := (cQry)->ZO5_CONTA 
				(cZO5)->ZO5_ITCUS  := (cQry)->ZO5_ITCUS 
				(cZO5)->ZO5_CSTUNT := (cQry)->ZO5_CSTUNT
				(cZO5)->ZO5_DATARF := STOD((cQry)->ZO5_DATARF)
				(cZO5)->(MsUnlock())

			Else

				lRet := .F.

				cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

				Exit

			EndIf

			If Select(cZO5) > 0

				(cZO5)->(DbCloseArea())

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
	Local cZO5	:= GetNextAlias()

	Default cMsg := ""

	cQry := GetNextAlias()

	cSql := " SELECT R_E_C_N_O_ RECNO "
	cSql += " FROM " + RetFullName("ZO5", cEmp) + " ZO5 (NOLOCK) "
	cSql += " WHERE ZO5_FILIAL      = " + ValToSql(cEmp)
	cSql += " AND ZO5_VERSAO        = " + ValToSql(cVersao)
	cSql += " AND ZO5_REVISA        = " + ValToSql(cRevisa)
	cSql += " AND ZO5_ANOREF        = " + ValToSql(cAnoRef)
	cSql += " AND ZO5.D_E_L_E_T_    = ' ' "

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

		If EmpOpenFile(cZO5, "ZO5", 1, .T., cEmp, @cModo)

			(cZO5)->(DBGoTo((cQry)->RECNO))

			If !(cZO5)->(EOF())

				Reclock(cZO5, .F.)
				(cZO5)->(DBDelete())
				(cZO5)->(MsUnlock())

			EndIf

		Else

			lRet := .F.

			cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

		EndIf

		If Select(cZO5) > 0

			(cZO5)->(DbCloseArea())

		EndIf

		(cQry)->(DbSkip())

	EndDo

	(cQry)->(DbCloseArea())

Return(lRet)
