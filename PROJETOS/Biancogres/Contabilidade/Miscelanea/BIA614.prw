#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA614
@author Wlysses Cerqueira (Facile)
@since 04/12/2020
@version 1.0
@Projet A-35
@description Processamento - Kardex Orçado - Processamento dos Saldos Iniciais.
@type function
/*/

User Function BIA614()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "Kardex Orçado - Processamento dos Saldos Iniciais"

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
	Local cModo := "" //Modo de acesso do arquivo aberto //"E" ou "C"
	Local cZOA  := GetNextAlias()

	Default cMsg    := ""

	If EmpOpenFile(cZOA, "ZOA", 1, .T., cEmp, @cModo)

		(cZOA)->(DBSetOrder(2)) // ZOA_FILIAL, ZOA_VERSAO, ZOA_REVISA, ZOA_ANOREF, ZOA_DTREF, ZOA_PRODUT, R_E_C_N_O_, D_E_L_E_T_

		If (cZOA)->(DbSeek(cEmp + cVersao + cRevisa + cAnoRef))

			While !(cZOA)->(Eof()) .And. (cZOA)->(ZOA_FILIAL + ZOA_VERSAO + ZOA_REVISA + ZOA_ANOREF) == cEmp + cVersao + cRevisa + cAnoRef

				Reclock(cZOA, .F.)
				(cZOA)->ZOA_QINI := ( ( (cZOA)->ZOA_QATU + (cZOA)->ZOA_QEPROJ ) - (cZOA)->ZOA_QSPROJ )
				(cZOA)->ZOA_VINI := ( ( (cZOA)->ZOA_VATU + (cZOA)->ZOA_VEPROJ ) - (cZOA)->ZOA_VSPROJ )
				(cZOA)->(MsUnlock())

				(cZOA)->(DbSkip())

			EndDo

		EndIf

	Else

		lRet := .F.

		cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

	EndIf

	If Select(cZOA) > 0

		(cZOA)->(DbCloseArea())

	EndIf

Return(lRet)
