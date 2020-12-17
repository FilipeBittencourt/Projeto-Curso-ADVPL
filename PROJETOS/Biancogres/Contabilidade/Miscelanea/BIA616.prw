#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA616
@author Wlysses Cerqueira (Facile)
@since 09/12/2020
@version 1.0
@Projet A-35
@description Processamento - Kardex Orçado - Processamento.
@type function
/*/

User Function BIA616()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "Kardex Orçado - Processamento"

	//RpcSetEnv("01", "01")

	oEmp := TLoadEmpresa():New()

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte()

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

		Alert("Erro no processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO")

	EndIf

	//RpcClearEnv()

Return()

Static Function Processa(cEmp, cVersao, cRevisa, cAnoRef, dDataFech, cMsg)

	Local nQINIJan := 0
	Local nVINIJan := 0

	Local lRet	:= .T.
	Local cModo := "" //Modo de acesso do arquivo aberto //"E" ou "C"
	Local cZOA  := GetNextAlias()
	Local cZOB  := GetNextAlias()
	Local cZO6  := GetNextAlias()

	Default cMsg := ""

	If EmpOpenFile(cZOB, "ZOB", 1, .T., cEmp, @cModo)

		(cZOB)->(DBSetOrder(2)) // ZOB_FILIAL, ZOB_VERSAO, ZOB_REVISA, ZOB_ANOREF, ZOB_DTREF, ZOB_PRODUT, R_E_C_N_O_, D_E_L_E_T_

		If EmpOpenFile(cZOA, "ZOA", 1, .T., cEmp, @cModo)

			(cZOA)->(DBSetOrder(2)) // ZOA_FILIAL, ZOA_VERSAO, ZOA_REVISA, ZOA_ANOREF, ZOA_DTREF, ZOA_PRODUT, R_E_C_N_O_, D_E_L_E_T_

			If (cZOB)->(DbSeek(cEmp + cVersao + cRevisa + cAnoRef))

				While !(cZOB)->(EOF()) .And. (cZOB)->(ZOB_FILIAL + ZOB_VERSAO + ZOB_REVISA + ZOB_ANOREF) == cEmp + cVersao + cRevisa + cAnoRef

					If (cZOA)->(DbSeek(cEmp + cVersao + cRevisa + cAnoRef + DTOS((cZOB)->ZOB_DTREF) + (cZOB)->ZOB_PRODUT))

						If Month((cZOA)->ZOA_DTREF) == 1

							Reclock(cZOB, .F.)
							(cZOB)->ZOB_QINI := (cZOA)->ZOA_QINI
							(cZOB)->ZOB_VINI := (cZOA)->ZOA_VINI
							(cZOB)->(MsUnlock())

							nQINIJan := (cZOB)->ZOB_QINI
							nVINIJan := (cZOB)->ZOB_VINI

						EndIf

					EndIf

					// Tenho que buscar de JANEIRO
					Reclock(cZOB, .F.)
					(cZOB)->ZOB_QINI := nQINIJan
					(cZOB)->ZOB_VINI := nVINIJan
					(cZOB)->(MsUnlock())

					If EmpOpenFile(cZO6, "ZO6", 1, .T., cEmp, @cModo)

						(cZO6)->(DBSetOrder(1)) // ZO6_FILIAL, ZO6_VERSAO, ZO6_REVISA, ZO6_ANOREF, ZO6_PRODUT, ZO6_LINHA, R_E_C_N_O_, D_E_L_E_T_

						If (cZO6)->(DbSeek(xFilial("ZO6") + cVersao + cRevisa + cAnoRef + (cZOB)->ZOB_PRODUT))

							Reclock(cZOB, .F.)
							(cZOB)->ZOB_QVENDA := &("(cZO6)->ZO6_RECM" + StrZero(Month((cZOB)->ZOB_DTREF), 2))
							(cZOB)->(MsUnlock())

						EndIf

					Else

						lRet := .F.

						cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

					EndIf

					Reclock(cZOB, .F.)
					(cZOB)->ZOB_VVENDA := (cZOB)->ZOB_QVENDA * ( ((cZOB)->ZOB_VINI + (cZOB)->ZOB_VPROD) / ((cZOB)->ZOB_QINI + (cZOB)->ZOB_QPROD) )
					(cZOB)->(MsUnlock())

					Reclock(cZOB, .F.)
					(cZOB)->ZOB_QSALDO := (cZOB)->ZOB_QINI + (cZOB)->ZOB_QPROD - (cZOB)->ZOB_QVENDA
					(cZOB)->ZOB_VSALDO := (cZOB)->ZOB_VINI + (cZOB)->ZOB_VPROD - (cZOB)->ZOB_VVENDA
					(cZOB)->(MsUnlock())

					(cZOB)->(DBSkip())

				EndDo

				// TODO: Chamar BIA610 AQUI??

			EndIf

		Else

			lRet := .F.

			cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

		EndIf

	Else

		lRet := .F.

		cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

	EndIf

	If Select(cZOA) > 0

		(cZOA)->(DbCloseArea())

	EndIf

	If Select(cZOB) > 0

		(cZOB)->(DbCloseArea())

	EndIf

	If Select(cZO6) > 0

		(cZO6)->(DbCloseArea())

	EndIf

Return(lRet)
