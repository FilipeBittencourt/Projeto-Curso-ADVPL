#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA617
@author Wlysses Cerqueira (Facile)
@since 09/12/2020
@version 1.0
@description CPV Orçado - Processamento.
@type function
@Obs Projeto A-35
/*/

User Function BIA617()

	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "CPV Orçado - Processamento"
	Private msCanPrc  := .F.

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte()

		Begin Transaction

			xVerRet := .F.
			Processa({ || ExistThenD(cEmpAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Deletando dados...", .F.)
			If xVerRet

				Processa({ || fProcessa(cEmpAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Processando dados...", .F.)
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

			MsgSTOP("Erro no processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA617")

		Else

			MsgINFO("Fim do processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA617")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "BIA617")

	EndIf


Return

Static Function fProcessa(cEmp, cVersao, cRevisa, cAnoRef, cMsg)

	Local lRet  := .T.
	Local cSQL  := ""
	Local cQry  := GetNextAlias()

	Default cMsg    := ""

	cSql := " SELECT ZOB_FILIAL, ZOB_VERSAO, ZOB_REVISA, ZOB_ANOREF, SUBSTRING(ZOB_DTREF, 1, 6) ANOMES, SUM(ZOB_VVENDA) ZOB_VVENDA "
	cSql += " FROM " + RetFullName("ZOB", cEmp) + " ZOB (NOLOCK) "
	cSql += " WHERE ZOB.D_E_L_E_T_  = '' "
	cSql += " AND ZOB.ZOB_FILIAL    = " + ValToSql(cEmp)
	cSql += " AND ZOB.ZOB_VERSAO    = " + ValToSql(cVersao)
	cSql += " AND ZOB.ZOB_REVISA    = " + ValToSql(cRevisa)
	cSql += " AND ZOB.ZOB_ANOREF    = " + ValToSql(cAnoRef)
	cSql += " GROUP BY ZOB_FILIAL, ZOB_VERSAO, ZOB_REVISA, ZOB_ANOREF, SUBSTRING(ZOB_DTREF, 1, 6) "

	TcQuery cSQL New Alias (cQry)

	ProcRegua(0)
	While !(cQry)->(Eof())

		IncProc("Processando Registros encontrados na base...")

		If (cQry)->ZOB_VVENDA <> 0

			Reclock("ZBZ",.T.)
			ZBZ->ZBZ_FILIAL := cEmp
			ZBZ->ZBZ_VERSAO := cVersao
			ZBZ->ZBZ_REVISA := cRevisa
			ZBZ->ZBZ_ANOREF := cAnoRef
			ZBZ->ZBZ_DATA   := LastDay(STOD((cQry)->ANOMES + "01"))
			ZBZ->ZBZ_VALOR  := (cQry)->ZOB_VVENDA
			ZBZ->ZBZ_DC	    := "D"
			ZBZ->ZBZ_DEBITO := "41301001"
			ZBZ->ZBZ_HIST   := "VLR CPV N/MÊS"
			ZBZ->ZBZ_ORIPRC := "CPV"
			ZBZ->(MsUnlock())

			/* -- Retirado até que seja definido o que será feito com o Ativo Fixo
			Reclock("ZBZ",.T.)
			ZBZ->ZBZ_FILIAL := cEmp
			ZBZ->ZBZ_VERSAO := cVersao
			ZBZ->ZBZ_REVISA := cRevisa
			ZBZ->ZBZ_ANOREF := cAnoRef
			ZBZ->ZBZ_DATA   := LastDay(STOD((cQry)->ANOMES + "01"))
			ZBZ->ZBZ_VALOR  := (cQry)->ZOB_VVENDA
			ZBZ->ZBZ_DC	    := "C"
			ZBZ->ZBZ_CREDIT := "11306001"
			ZBZ->ZBZ_HIST   := "VLR CPV N/MÊS"
			ZBZ->ZBZ_ORIPRC := "CPV"
			ZBZ->(MsUnlock())
			*/

		EndIf

		(cQry)->(DbSkip())

	EndDo

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return(lRet)

Static Function ExistThenD(cEmp, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL  := ""
	Local cQry  := ""
	Local lPerg := .T.
	Local lRet  := .T.

	Default cMsg := ""

	cQry := GetNextAlias()

	cSql := " SELECT R_E_C_N_O_ RECNO "
	cSql += " FROM " + RetFullName("ZBZ", cEmp) + " ZBZ (NOLOCK) "
	cSql += " WHERE ZBZ_FILIAL = " + ValToSql(cEmp)
	cSql += " AND ZBZ_VERSAO = " + ValToSql(cVersao)
	cSql += " AND ZBZ_REVISA = " + ValToSql(cRevisa)
	cSql += " AND ZBZ_ANOREF = " + ValToSql(cAnoRef)
	cSql += " AND ZBZ_ORIPRC = 'CPV' "
	cSql += " AND ZBZ.D_E_L_E_T_    = ' ' "

	TcQuery cSQL New Alias (cQry)

	ProcRegua(0)
	While !(cQry)->(Eof())

		IncProc("Apagando Registros encontrados na base...")

		If lPerg

			If MsgYesNo("Já existem dados para o tempo orçamentário. Deseja continuar?" + CRLF + CRLF + "Caso clique em sim esses dados serão apagados e gerados novos!", "Empresa: [" + cEmp + "]  - ATENÇÃO")

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
