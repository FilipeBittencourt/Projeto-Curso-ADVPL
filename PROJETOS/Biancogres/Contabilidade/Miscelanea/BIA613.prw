#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA613
@author Wlysses Cerqueira (Facile)
@since 04/12/2020
@version 1.0
@description Processamento - Kardex Orçado - (Qtd/Custo) E/S Projetadas a partir de DataRef.
@type function
@Obs Projeto A-35
/*/

User Function BIA613()

	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "Kardex Orçado - (Qtd/Custo) E/S Projetadas a partir de DataRef"
	Private msCanPrc  := .F.

	MsgINFO("Rotina em desenvolvimento!!!", "BIA613")
	Return


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

			MsgSTOP("Erro no processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA613")

		Else

			MsgINFO("Fim do processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA613")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "BIA613")

	EndIf

Return

Static Function fProcessa(cEmp, cVersao, cRevisa, cAnoRef, dDataFech, cMsg)

	Local lRet  := .T.
	Local cSQL  := ""
	Local cQry  := GetNextAlias()

	Default cMsg    := ""

	cSql := " * "

	TcQuery cSQL New Alias (cQry)

	ProcRegua(0)
	While !(cQry)->(Eof())

		IncProc("Processando Registros encontrados na base...")

		Reclock("ZOA", .T.)
		ZOA->ZOA_FILIAL  := cEmp
		ZOA->ZOA_VERSAO  := cVersao
		ZOA->ZOA_REVISA  := cRevisa
		ZOA->ZOA_ANOREF  := cAnoRef
		ZOA->ZOA_DTVIRA  := dDataFech
		ZOA->ZOA_DTREF   := STOD((cQry)->ZO8_DTREF)
		ZOA->ZOA_PRODUT  := (cQry)->B9_COD
		ZOA->ZOA_LOCAL   := (cQry)->B9_LOCAL

		ZOA->ZOA_QEPROJ  := 0
		ZOA->ZOA_VEPROJ  := 0

		ZOA->ZOA_QSPROJ  := 0
		ZOA->ZOA_VSPROJ  := 0

		ZOA->(MsUnlock())

		(cQry)->(DbSkip())

	End

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return(lRet)
