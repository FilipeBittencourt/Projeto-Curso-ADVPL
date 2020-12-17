#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA619
@author Wlysses Cerqueira (Facile)
@since 14/12/2020
@version 1.0
@Projet A-35
@description Processamento - Variação de Estoque de Quant. e Custo
@type function
/*/

User Function BIA619()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "DRE - Variação de Estoque de Quant. e Custo"

	//RpcSetEnv("01", "01")

	oEmp := TLoadEmpresa():New()

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte()

		oEmp:GetSelEmp()

		If Len(oEmp:aEmpSel) > 0

			Begin Transaction

				For nW := 1 To Len(oEmp:aEmpSel)

					lRet := Processa(oEmp:aEmpSel[nW][1], oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg)

					If lRet

						lRet := ProcessaZBZ(oEmp:aEmpSel[nW][1], oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg)

					Else

						Exit

					EndIf

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

Static Function Processa(cEmp, cVersao, cRevisa, cAnoRef, cMsg)

	Local lRet	:= .T.
	Local cModo := "" //Modo de acesso do arquivo aberto //"E" ou "C"
	Local cZOB  := GetNextAlias()

	Default cMsg := ""

	If EmpOpenFile(cZOB, "ZOB", 1, .T., cEmp, @cModo)

		(cZOB)->(DBSetOrder(2)) // ZOB_FILIAL, ZOB_VERSAO, ZOB_REVISA, ZOB_ANOREF, ZOB_DTREF, ZOB_PRODUT, R_E_C_N_O_, D_E_L_E_T_

		If (cZOB)->(DbSeek(cEmp + cVersao + cRevisa + cAnoRef))

			While !(cZOB)->(EOF()) .And. (cZOB)->(ZOB_FILIAL + ZOB_VERSAO + ZOB_REVISA + ZOB_ANOREF) == cEmp + cVersao + cRevisa + cAnoRef

				Reclock(cZOB, .F.)
				(cZOB)->ZOB_VAREST	:= (cZOB)->ZOB_VPROD - (cZOB)->ZOB_VVENDAS
				(cZOB)->ZOB_VEQTDA	:= ((cZOB)->ZOB_QPROD-(cZOB)->ZOB_QVENDAS) * ((cZOB)->ZOB_VVENDAS/(cZOB)->ZOB_QVENDAS)
				// (cZOB)->ZOB_VECST	:= ( ( ((cZOB)->ZOB_VVENDAS/(cZOB)->ZOB_QVENDAS)-((cZOB)->ZOB_VPROD-(cZOB)->ZOB_QPROD) ) * (-1) ) * (cZOB)->ZOB_QPROD
				(cZOB)->ZOB_VECHEC	:= (cZOB)->ZOB_VAREST - (cZOB)->ZOB_VEQTDA - (cZOB)->ZOB_VECST
				(cZOB)->(MsUnlock())

				(cZOB)->(DBSkip())

				// 15.827.621.359990 

			EndDo

		EndIf

	Else

		lRet := .F.

		cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

	EndIf

	If Select(cZOB) > 0

		(cZOB)->(DbCloseArea())

	EndIf

Return(lRet)

Static Function ProcessaZBZ(cEmp, cVersao, cRevisa, cAnoRef, cMsg)

	Local lRet  := .T.
	Local cSQL  := ""
	Local cModo := "" //Modo de acesso do arquivo aberto //"E" ou "C"
	Local cQry  := GetNextAlias()
	Local cZBZ  := GetNextAlias()

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

	While !(cQry)->(Eof())

		If EmpOpenFile(cZBZ, "ZBZ", 1, .T., cEmp, @cModo)

			// Variação Qtde
			Reclock(cZBZ,.T.)
			(cZBZ)->ZBZ_FILIAL := cEmp
			(cZBZ)->ZBZ_VERSAO := cVersao
			(cZBZ)->ZBZ_REVISA := cRevisa
			(cZBZ)->ZBZ_ANOREF := cAnoRef
			(cZBZ)->ZBZ_DATA   := LastDay(STOD((cQry)->ANOMES + "01"))
			(cZBZ)->ZBZ_DEBITO := "41399001"
			(cZBZ)->ZBZ_HIST   := "VARIAÇÃO DE ESTOQUE – QTDE"

			If (cQry)->ZOB_VEQTDA > 0

				(cZBZ)->ZBZ_DC	   := "C"
				(cZBZ)->ZBZ_VALOR  := (cQry)->ZOB_VEQTDA

			Else

				(cZBZ)->ZBZ_DC	   := "D"
				(cZBZ)->ZBZ_VALOR  := (cQry)->ZOB_VEQTDA * -1

			EndIf

			(cZBZ)->(MsUnlock())

			// Variação Custo
			Reclock(cZBZ,.T.)
			(cZBZ)->ZBZ_FILIAL := cEmp
			(cZBZ)->ZBZ_VERSAO := cVersao
			(cZBZ)->ZBZ_REVISA := cRevisa
			(cZBZ)->ZBZ_ANOREF := cAnoRef
			(cZBZ)->ZBZ_DATA   := LastDay(STOD((cQry)->ANOMES + "01"))
			(cZBZ)->ZBZ_DEBITO := "41399002"
			(cZBZ)->ZBZ_HIST   := "VARIAÇÃO DE ESTOQUE – CUSTOS"

			If (cQry)->ZOB_VECST > 0

				(cZBZ)->ZBZ_DC	   := "C"
				(cZBZ)->ZBZ_VALOR  := (cQry)->ZOB_VECST

			Else

				(cZBZ)->ZBZ_DC	   := "D"
				(cZBZ)->ZBZ_VALOR  := (cQry)->ZOB_VECST * -1

			EndIf

			(cZBZ)->(MsUnlock())

		Else

			lRet := .F.

			cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

			Exit

		EndIf

		(cQry)->(DbSkip())

	EndDo

	If Select(cZBZ) > 0

		(cZBZ)->(DbCloseArea())

	EndIf

	(cQry)->(DbCloseArea())

Return(lRet)
