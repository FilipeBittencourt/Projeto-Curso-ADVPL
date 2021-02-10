#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA614
@author Wlysses Cerqueira (Facile)
@since 04/12/2020
@version 1.0
@description Processamento - Kardex Orçado - Processamento dos Saldos Iniciais.
@type function
@Obs Projeto A-35
/*/

User Function BIA614()

	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "Kardex Orçado - Processamento dos Saldos Iniciais"
	Private msCanPrc  := .F.

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte(, .T.)

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

			MsgSTOP("Erro no processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA614")

		Else

			MsgINFO("Fim do processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA614")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "BIA614")

	EndIf

Return

Static Function fProcessa(msFil, cVersao, cRevisa, cAnoRef, dDataFech, cMsg)

	Local lRet  := .T.

	Default cMsg    := ""

	ZOA->(DBSetOrder(2))
	If ZOA->(DbSeek(xFilial("ZOA") + cVersao + cRevisa + cAnoRef))

		ProcRegua(0)
		While !ZOA->(Eof()) .And. ZOA->(ZOA_FILIAL + ZOA_VERSAO + ZOA_REVISA + ZOA_ANOREF) == xFilial("ZOA") + cVersao + cRevisa + cAnoRef

			IncProc("Processando Registros encontrados na base...")

			Reclock("ZOA", .F.)
			ZOA->ZOA_QINI := ( ( ZOA->ZOA_QATU + ZOA->ZOA_QEPROJ ) - ZOA->ZOA_QSPROJ )
			ZOA->ZOA_VINI := ( ( ZOA->ZOA_VATU + ZOA->ZOA_VEPROJ ) - ZOA->ZOA_VSPROJ )
			ZOA->(MsUnlock())

			ZOA->(DbSkip())

		End

	EndIf

	xVerRet := lRet 

Return(lRet)
