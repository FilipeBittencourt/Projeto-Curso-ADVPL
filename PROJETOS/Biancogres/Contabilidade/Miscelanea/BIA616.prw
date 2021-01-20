#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA616
@author Wlysses Cerqueira (Facile)
@since 09/12/2020
@version 1.0
@description Processamento - Kardex Orçado - Processamento.
@type function
@Obs Projeto A-35
/*/

User Function BIA616()

	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "Kardex Orçado - Processamento"
	Private msCanPrc  := .F.

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte()

		Begin Transaction

			xVerRet := .F.
			Processa({ || fProcessa(cEmpAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, oPerg:dDataFech, @cMsg) }, "Aguarde...", "Processando dados...", .F.)
			lRet := xVerRet 

			If !lRet

				DisarmTransaction()

			EndIf

		End Transaction

	Else

		msCanPrc  := .T.

	EndIf

	If !msCanPrc

		If !lRet

			MsgSTOP("Erro no processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA616")

		Else

			MsgINFO("Fim do processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA616")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "BIA616")

	EndIf

Return

Static Function fProcessa(cEmp, cVersao, cRevisa, cAnoRef, dDataFech, cMsg)

	Local nQINIJan := 0
	Local nVINIJan := 0

	Local lRet	:= .T.

	Default cMsg := ""

	ZOB->(DBSetOrder(2))

	ZOA->(DBSetOrder(2))

	ProcRegua(0)
	While !ZOB->(EOF()) .And. ZOB->(ZOB_FILIAL + ZOB_VERSAO + ZOB_REVISA + ZOB_ANOREF) == cEmp + cVersao + cRevisa + cAnoRef

		IncProc("Processando Registros encontrados na base...")

		If ZOA->(DbSeek(cEmp + cVersao + cRevisa + cAnoRef + DTOS(ZOB->ZOB_DTREF) + ZOB->ZOB_PRODUT))

			If Month(ZOA->ZOA_DTREF) == 1

				Reclock("ZOB", .F.)
				ZOB->ZOB_QINI := ZOA->ZOA_QINI
				ZOB->ZOB_VINI := ZOA->ZOA_VINI
				ZOB->(MsUnlock())

				nQINIJan := ZOB->ZOB_QINI
				nVINIJan := ZOB->ZOB_VINI

			EndIf

		EndIf

		// Tenho que buscar de JANEIRO
		Reclock("ZOB", .F.)
		ZOB->ZOB_QINI := nQINIJan
		ZOB->ZOB_VINI := nVINIJan
		ZOB->(MsUnlock())

		ZO6->(DBSetOrder(1))

		If ZO6->(DbSeek(xFilial("ZO6") + cVersao + cRevisa + cAnoRef + ZOB->ZOB_PRODUT))

			Reclock("ZOB", .F.)
			ZOB->ZOB_QVENDA := &("ZO6->ZO6_RECM" + StrZero(Month(ZOB->ZOB_DTREF), 2))
			ZOB->(MsUnlock())

		EndIf

		Reclock("ZOB", .F.)
		ZOB->ZOB_VVENDA := ZOB->ZOB_QVENDA * ( (ZOB->ZOB_VINI + ZOB->ZOB_VPROD) / (ZOB->ZOB_QINI + ZOB->ZOB_QPROD) )
		ZOB->(MsUnlock())

		Reclock("ZOB", .F.)
		ZOB->ZOB_QSALDO := ZOB->ZOB_QINI + ZOB->ZOB_QPROD - ZOB->ZOB_QVENDA
		ZOB->ZOB_VSALDO := ZOB->ZOB_VINI + ZOB->ZOB_VPROD - ZOB->ZOB_VVENDA
		ZOB->(MsUnlock())

		ZOB->(DBSkip())

	End

	xVerRet := lRet 

Return(lRet)
