#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA613
@author Wlysses Cerqueira (Facile)
@since 04/12/2020
@version 1.0
@Projet A-35
@description Processamento - Kardex Orçado - (Qtd/Custo) E/S Projetadas a partir de DataRef.
@type function
/*/

User Function BIA613()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "Kardex Orçado - (Qtd/Custo) E/S Projetadas a partir de DataRef"

	//RpcSetEnv("01", "01")

	oEmp := TLoadEmpresa():New()

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte(, .T.)

		oEmp:GetSelEmp()

		If Len(oEmp:aEmpSel) > 0

			Begin Transaction

				For nW := 1 To Len(oEmp:aEmpSel)

					lRet := Processa(oEmp:aEmpSel[nW][1], oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, oPerg:dDataFech, @cMsg)

					If !lRet

						Exit

					EndIf

				Next nW

				If !lRet

					DisarmTransaction()

				EndIf

			End Transaction

		Else

			Alert("Nenhuma empresa foi selecionada!")

		EndIf

	EndIf

	If !lRet

		Alert("Erro no processamento!" + CRLF + CRLF + cMsg, "Empresa: [" + cEmp + "]  - ATENÇÃO")

	EndIf

	//RpcClearEnv()

Return()

Static Function Processa(cEmp, cVersao, cRevisa, cAnoRef, dDataFech, cMsg)

	Local lRet  := .T.
	Local cSQL  := ""
	Local cModo := "" //Modo de acesso do arquivo aberto //"E" ou "C"
	Local cQry  := GetNextAlias()
	Local cZOA  := GetNextAlias()

	Default cMsg    := ""

    cSql := " * "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		If EmpOpenFile(cZOA, "ZOA", 1, .T., cEmp, @cModo)

			Reclock(cZOA, .T.)
			(cZOA)->ZOA_FILIAL  := cEmp
			(cZOA)->ZOA_VERSAO  := cVersao
			(cZOA)->ZOA_REVISA  := cRevisa
			(cZOA)->ZOA_ANOREF  := cAnoRef
            (cZOA)->ZOA_DTVIRA  := dDataFech
			(cZOA)->ZOA_DTREF   := STOD((cQry)->ZO8_DTREF)
			(cZOA)->ZOA_PRODUT  := (cQry)->B9_COD
            (cZOA)->ZOA_LOCAL   := (cQry)->B9_LOCAL

            (cZOA)->ZOA_QEPROJ  := 0
            (cZOA)->ZOA_VEPROJ  := 0

            (cZOA)->ZOA_QSPROJ  := 0
            (cZOA)->ZOA_VSPROJ  := 0

			(cZOA)->(MsUnlock())

		Else

			lRet := .F.

			cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

			Exit

		EndIf

		If Select(cZOA) > 0

			(cZOA)->(DbCloseArea())

		EndIf

		(cQry)->(DbSkip())

	EndDo

	(cQry)->(DbCloseArea())

Return(lRet)
