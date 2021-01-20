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
			Processa({ || fProcessa(cEmpAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Processando dados...", .F.)
			If xVerRet

				Processa({ || fProcesZBZ(cEmpAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Gravando ZBZ dados...", .F.)
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

			MsgSTOP("Erro no processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA619")

		Else

			MsgINFO("Fim do processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA619")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "BIA619")

	EndIf

Return

Static Function fProcessa(cEmp, cVersao, cRevisa, cAnoRef, cMsg)

	Local lRet	:= .T.

	Default cMsg := ""

	ZOB->(DBSetOrder(2))

	If ZOB->(DbSeek(cEmp + cVersao + cRevisa + cAnoRef))

		ProcRegua(0)
		While !ZOB->(EOF()) .And. ZOB->(ZOB_FILIAL + ZOB_VERSAO + ZOB_REVISA + ZOB_ANOREF) == cEmp + cVersao + cRevisa + cAnoRef

			IncProc("Processando Registros encontrados na base...")

			Reclock("ZOB", .F.)
			ZOB->ZOB_VAREST	:= ZOB->ZOB_VPROD - ZOB->ZOB_VVENDAS
			ZOB->ZOB_VEQTDA	:= (ZOB->ZOB_QPROD-ZOB->ZOB_QVENDAS) * (ZOB->ZOB_VVENDAS/ZOB->ZOB_QVENDAS)
			// ZOB->ZOB_VECST	:= ( ( (ZOB->ZOB_VVENDAS/ZOB->ZOB_QVENDAS)-(ZOB->ZOB_VPROD-ZOB->ZOB_QPROD) ) * (-1) ) * ZOB->ZOB_QPROD
			ZOB->ZOB_VECHEC	:= ZOB->ZOB_VAREST - ZOB->ZOB_VEQTDA - ZOB->ZOB_VECST
			ZOB->(MsUnlock())

			ZOB->(DBSkip())

		End

	EndIf

	xVerRet := lRet 

Return(lRet)

Static Function fProcesZBZ(cEmp, cVersao, cRevisa, cAnoRef, cMsg)

	Local lRet  := .T.
	Local cSQL  := ""
	Local cQry  := GetNextAlias()

	Default cMsg    := ""

	cSql := " SELECT ZOB_FILIAL, ZOB_VERSAO, ZOB_REVISA, ZOB_ANOREF, SUBSTRING(ZOB_DTREF, 1, 6) ANOMES, SUM(ZOB_VEQTDA) ZOB_VEQTDA, SUM(ZOB_VECST) ZOB_VECST "
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

		// Variação Qtde
		Reclock("ZBZ",.T.)
		ZBZ->ZBZ_FILIAL := cEmp
		ZBZ->ZBZ_VERSAO := cVersao
		ZBZ->ZBZ_REVISA := cRevisa
		ZBZ->ZBZ_ANOREF := cAnoRef
		ZBZ->ZBZ_DATA   := LastDay(STOD((cQry)->ANOMES + "01"))
		ZBZ->ZBZ_DEBITO := "41399001"
		ZBZ->ZBZ_HIST   := "VARIAÇÃO DE ESTOQUE – QTDE"

		If (cQry)->ZOB_VEQTDA > 0

			ZBZ->ZBZ_DC	   := "C"
			ZBZ->ZBZ_VALOR  := (cQry)->ZOB_VEQTDA

		Else

			ZBZ->ZBZ_DC	   := "D"
			ZBZ->ZBZ_VALOR  := ABS( (cQry)->ZOB_VEQTDA )

		EndIf

		ZBZ->(MsUnlock())

		// Variação Custo
		Reclock("ZBZ",.T.)
		ZBZ->ZBZ_FILIAL := cEmp
		ZBZ->ZBZ_VERSAO := cVersao
		ZBZ->ZBZ_REVISA := cRevisa
		ZBZ->ZBZ_ANOREF := cAnoRef
		ZBZ->ZBZ_DATA   := LastDay(STOD((cQry)->ANOMES + "01"))
		ZBZ->ZBZ_DEBITO := "41399002"
		ZBZ->ZBZ_HIST   := "VARIAÇÃO DE ESTOQUE – CUSTOS"

		If (cQry)->ZOB_VECST > 0

			ZBZ->ZBZ_DC	   := "C"
			ZBZ->ZBZ_VALOR  := (cQry)->ZOB_VECST

		Else

			ZBZ->ZBZ_DC	   := "D"
			ZBZ->ZBZ_VALOR  := ABS( (cQry)->ZOB_VECST )

		EndIf

		ZBZ->(MsUnlock())

		(cQry)->(DbSkip())

	End

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return(lRet)
