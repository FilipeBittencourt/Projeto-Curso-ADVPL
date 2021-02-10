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
			Processa({ || fProcessa(cFilAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, oPerg:dDataFech, @cMsg) }, "Aguarde...", "Processando dados...", .F.)
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

Static Function fProcessa(msFil, cVersao, cRevisa, cAnoRef, dDataFech, cMsg)

	Local nQINI := 0
	Local nVINI := 0
	Local nkr

	Local lRet	:= .T.

	Default cMsg := ""

	ZOB->(DBSetOrder(2))

	ZOA->(DBSetOrder(2))

	ProcRegua(0)
	ZOB->(DbSeek(xFilial("ZOB") + cVersao + cRevisa + cAnoRef))
	While !ZOB->(EOF()) .And. ZOB->(ZOB_FILIAL + ZOB_VERSAO + ZOB_REVISA + ZOB_ANOREF) == xFilial("ZOB") + cVersao + cRevisa + cAnoRef

		IncProc("Processando Registros encontrados na base...")

		nQINI := 0
		nVINI := 0

		If Month(ZOB->ZOB_DTREF) == 1

			msIniRef := Strzero(Val(cAnoRef) - 1, 4) + "1231"
			If ZOA->(DbSeek(xFilial("ZOA") + cVersao + cRevisa + cAnoRef + msIniRef + ZOB->ZOB_PRODUT))

				nQINI := ZOA->ZOA_QINI
				nVINI := ZOA->ZOA_VINI

			EndIf

		Else

			msRegZOB := ZOB->(Recno())
			msProdut := ZOB->ZOB_PRODUT

			msIniRef := dtos(UltimoDia(stod(Substr(dtos(ZOB->ZOB_DTREF), 1, 4) + StrZero(Val(Substr(dtos(ZOB->ZOB_DTREF), 5, 2)) - 1, 2) + "01"))) 
			If ZOB->(DbSeek(xFilial("ZOB") + cVersao + cRevisa + cAnoRef + msIniRef + msProdut))

				nQINI := ZOB->ZOB_QSALDO
				nVINI := ZOB->ZOB_VSALDO

			EndIf

			ZOB->(dbGoto(msRegZOB))

		EndIf

		Reclock("ZOB", .F.)
		ZOB->ZOB_QINI := nQINI
		ZOB->ZOB_VINI := nVINI
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

	//Transporta produtos sem movimento no período
	ProcRegua(0)
	For nkr := 1 to 12

		IncProc("Processando Registros encontrados na base...")

		msIniRef := dtos(UltimoDia(stod(cAnoRef + StrZero(nkr,2) + "01")))
		ProcRegua(0)
		ZOA->(DbSeek(xFilial("ZOA") + cVersao + cRevisa + cAnoRef))
		While !ZOA->(EOF()) .And. ZOA->(ZOA_FILIAL + ZOA_VERSAO + ZOA_REVISA + ZOA_ANOREF) == xFilial("ZOA") + cVersao + cRevisa + cAnoRef

			IncProc("Processando Registros encontrados na base...")

			If !ZOB->(DbSeek(xFilial("ZOB") + cVersao + cRevisa + cAnoRef + msIniRef + ZOA->ZOA_PRODUT))

				Reclock("ZOB", .T.)
				ZOB->ZOB_FILIAL  := xFilial("ZOB")
				ZOB->ZOB_VERSAO  := cVersao
				ZOB->ZOB_REVISA  := cRevisa
				ZOB->ZOB_ANOREF  := cAnoRef
				ZOB->ZOB_DTREF   := stod(msIniRef)
				ZOB->ZOB_PRODUT  := ZOA->ZOA_PRODUT
				ZOB->ZOB_QINI    := ZOA->ZOA_QINI
				ZOB->ZOB_VINI    := ZOA->ZOA_VINI
				ZOB->ZOB_QSALDO  := ZOA->ZOA_QINI
				ZOB->ZOB_VSALDO  := ZOA->ZOA_VINI
				ZOB->(MsUnlock())

			EndIf

			ZOA->(DBSkip())

		End

	Next nkr

	xVerRet := lRet 

Return(lRet)
