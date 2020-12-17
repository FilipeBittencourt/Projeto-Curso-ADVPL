#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA617
@author Wlysses Cerqueira (Facile)
@since 09/12/2020
@version 1.0
@Projet A-35
@description CPV Orçado - Processamento.
@type function
/*/

User Function BIA617()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "CPV Orçado - Processamento"

	//RpcSetEnv("01", "01")

	oEmp := TLoadEmpresa():New()

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte()

		oEmp:GetSelEmp()

		If Len(oEmp:aEmpSel) > 0

			Begin Transaction

				For nW := 1 To Len(oEmp:aEmpSel)

					lRet := Processa(oEmp:aEmpSel[nW][1], oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg)

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

	Local lRet  := .T.
	Local cSQL  := ""
	Local cModo := "" //Modo de acesso do arquivo aberto //"E" ou "C"
	Local cQry  := GetNextAlias()
	Local cZBZ  := GetNextAlias()

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

	While !(cQry)->(Eof())

		If EmpOpenFile(cZBZ, "ZBZ", 1, .T., cEmp, @cModo)

			Reclock(cZBZ,.T.)
			(cZBZ)->ZBZ_FILIAL := cEmp
			(cZBZ)->ZBZ_VERSAO := cVersao
			(cZBZ)->ZBZ_REVISA := cRevisa
			(cZBZ)->ZBZ_ANOREF := cAnoRef
			(cZBZ)->ZBZ_DATA   := LastDay(STOD((cQry)->ANOMES + "01"))
			(cZBZ)->ZBZ_VALOR  := (cQry)->ZOB_VVENDA
			(cZBZ)->ZBZ_DC	   := "D"
			(cZBZ)->ZBZ_DEBITO := "41301001"
			(cZBZ)->ZBZ_HIST   := "VLR CPV N/MÊS"
			(cZBZ)->(MsUnlock())

			Reclock(cZBZ,.T.)
			(cZBZ)->ZBZ_FILIAL := cEmp
			(cZBZ)->ZBZ_VERSAO := cVersao
			(cZBZ)->ZBZ_REVISA := cRevisa
			(cZBZ)->ZBZ_ANOREF := cAnoRef
			(cZBZ)->ZBZ_DATA   := LastDay(STOD((cQry)->ANOMES + "01"))
			(cZBZ)->ZBZ_VALOR  := (cQry)->ZOB_VVENDA
			(cZBZ)->ZBZ_DC	   := "C"
			(cZBZ)->ZBZ_CREDIT := "11306001"
			(cZBZ)->ZBZ_HIST   := "VLR CPV N/MÊS"
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
