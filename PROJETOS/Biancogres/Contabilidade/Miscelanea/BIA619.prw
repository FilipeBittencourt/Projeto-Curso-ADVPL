#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA619
@author Wlysses Cerqueira (Facile)
@since 14/12/2020
@version 1.0
@description Processamento - Variação de Estoque de Quant. e Custo
@type function
@Obs Projeto A-35
/*/

User Function BIA619()

	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "DRE - Variação de Estoque de Quant. e Custo"
	Private msCanPrc  := .F.

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte()

		Begin Transaction

			xVerRet := .F.
			Processa({ || ExistThenD(cFilAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Deletando dados...", .F.)
			If xVerRet

				Processa({ || fProcessa(cFilAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Processando dados...", .F.)
				If xVerRet

					Processa({ || fProcesZBZ(cFilAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Gravando ZBZ dados...", .F.)
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

			MsgSTOP("Erro no processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA619")

		Else

			MsgINFO("Fim do processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA619")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "BIA619")

	EndIf

Return

Static Function fProcessa(msFil, cVersao, cRevisa, cAnoRef, cMsg)

	Local lRet	:= .T.

	Default cMsg := ""

	ZOB->(DBSetOrder(2))

	If ZOB->(DbSeek(xFilial("ZOB") + cVersao + cRevisa + cAnoRef))

		ProcRegua(0)
		While !ZOB->(EOF()) .And. ZOB->(ZOB_FILIAL + ZOB_VERSAO + ZOB_REVISA + ZOB_ANOREF) == xFilial("ZOB") + cVersao + cRevisa + cAnoRef

			IncProc("Processando Registros encontrados na base...")

			Reclock("ZOB", .F.)
			ZOB->ZOB_VAREST	:= ZOB->ZOB_VPROD - ZOB->ZOB_VVENDA
			ZOB->ZOB_VEQTDA	:= (ZOB->ZOB_QPROD-ZOB->ZOB_QVENDA) * (ZOB->ZOB_VVENDA/ZOB->ZOB_QVENDA)
			ZOB->ZOB_VECST	:= ( ( (ZOB->ZOB_VVENDA / ZOB->ZOB_QVENDA) - (ZOB->ZOB_VPROD / ZOB->ZOB_QPROD) ) * (-1) ) * ZOB->ZOB_QPROD
			ZOB->ZOB_VECHEC	:= ZOB->ZOB_VAREST - ZOB->ZOB_VEQTDA - ZOB->ZOB_VECST
			ZOB->(MsUnlock())

			ZOB->(DBSkip())

		End

	EndIf

	xVerRet := lRet 

Return(lRet)

Static Function fProcesZBZ(msFil, cVersao, cRevisa, cAnoRef, cMsg)

	Local lRet  := .T.
	Local cSQL  := ""
	Local cQry  := GetNextAlias()

	Default cMsg    := ""

	cSql := " SELECT ZOB_FILIAL, "
	cSql += "        ZOB_VERSAO, "
	cSql += "        ZOB_REVISA, "
	cSql += "        ZOB_ANOREF, "
	cSql += "        SUBSTRING(ZOB_DTREF, 1, 6) ANOMES, "
	cSql += "        SUM(ZOB_VEQTDA) ZOB_VEQTDA, "
	cSql += "        SUM(ZOB_VECST) ZOB_VECST "
	cSql += " FROM " + RetFullName("ZOB", cEmpAnt) + " ZOB (NOLOCK) "
	cSql += " WHERE ZOB.D_E_L_E_T_  = ' ' "
	cSql += "       AND ZOB.ZOB_FILIAL = '" + xFilial("ZOB") + "' "
	cSql += "       AND ZOB.ZOB_VERSAO = " + ValToSql(cVersao)
	cSql += "       AND ZOB.ZOB_REVISA = " + ValToSql(cRevisa)
	cSql += "       AND ZOB.ZOB_ANOREF = " + ValToSql(cAnoRef)
	cSql += " GROUP BY ZOB_FILIAL, ZOB_VERSAO, ZOB_REVISA, ZOB_ANOREF, SUBSTRING(ZOB_DTREF, 1, 6) "

	TcQuery cSQL New Alias (cQry)

	ProcRegua(0)
	While !(cQry)->(Eof())

		IncProc("Processando Registros encontrados na base...")

		// Variação Qtde
		If (cQry)->ZOB_VEQTDA <> 0

			Reclock("ZBZ",.T.)
			ZBZ->ZBZ_FILIAL := xFilial("ZBZ")
			ZBZ->ZBZ_VERSAO := cVersao
			ZBZ->ZBZ_REVISA := cRevisa
			ZBZ->ZBZ_ANOREF := cAnoRef
			ZBZ->ZBZ_ORIPRC := "VARESTOQUE"
			ZBZ->ZBZ_DATA   := LastDay(STOD((cQry)->ANOMES + "01"))
			ZBZ->ZBZ_HIST   := "VARIAÇÃO DE ESTOQUE – QTDE"

			If (cQry)->ZOB_VEQTDA > 0

				ZBZ->ZBZ_DC	    := "C"
				ZBZ->ZBZ_CREDIT := "41399001"
				ZBZ->ZBZ_VALOR  := (cQry)->ZOB_VEQTDA

			Else

				ZBZ->ZBZ_DC	    := "D"
				ZBZ->ZBZ_DEBITO := "41399001"
				ZBZ->ZBZ_VALOR  := ABS( (cQry)->ZOB_VEQTDA )

			EndIf

			ZBZ->(MsUnlock())

		EndIf

		// Variação Custo
		If (cQry)->ZOB_VECST <> 0

			Reclock("ZBZ",.T.)
			ZBZ->ZBZ_FILIAL := xFilial("ZBZ")
			ZBZ->ZBZ_VERSAO := cVersao
			ZBZ->ZBZ_REVISA := cRevisa
			ZBZ->ZBZ_ANOREF := cAnoRef
			ZBZ->ZBZ_ORIPRC := "VARESTOQUE"
			ZBZ->ZBZ_DATA   := LastDay(STOD((cQry)->ANOMES + "01"))
			ZBZ->ZBZ_HIST   := "VARIAÇÃO DE ESTOQUE – CUSTOS"

			If (cQry)->ZOB_VECST > 0

				ZBZ->ZBZ_DC	    := "C"
				ZBZ->ZBZ_CREDIT := "41399002"
				ZBZ->ZBZ_VALOR  := (cQry)->ZOB_VECST

			Else

				ZBZ->ZBZ_DC	   := "D"
				ZBZ->ZBZ_DEBITO := "41399002"
				ZBZ->ZBZ_VALOR  := ABS( (cQry)->ZOB_VECST )

			EndIf

			ZBZ->(MsUnlock())

		EndIf

		(cQry)->(DbSkip())

	End

	(cQry)->(DbCloseArea())

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
	cSql += " FROM " + RetFullName("ZBZ", cEmpAnt) + " ZBZ (NOLOCK) "
	cSql += " WHERE ZBZ_FILIAL = '" + xFilial("ZBZ") + "' "
	cSql += "       AND ZBZ_VERSAO = " + ValToSql(cVersao)
	cSql += "       AND ZBZ_REVISA = " + ValToSql(cRevisa)
	cSql += "       AND ZBZ_ANOREF = " + ValToSql(cAnoRef)
	cSql += "       AND ZBZ_ORIPRC = 'VARESTOQUE' "
	cSql += "       AND ZBZ.D_E_L_E_T_ = ' ' "

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

		ZBZ->(DBGoTo((cQry)->RECNO))
		If !ZBZ->(EOF())

			Reclock("ZBZ", .F.)
			ZBZ->(DBDelete())
			ZBZ->(MsUnlock())

		EndIf

		(cQry)->(DbSkip())

	End

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return ( lRet )
