#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA610
@author Wlysses Cerqueira (Facile)
@since 03/12/2020
@version 1.0
@Projet A-35
@description Processamento - Kardex Orçado - Custo das produções Orçadas.
@type function
/*/

User Function BIA610()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "Kardex Orçado - Custo das produções Orçadas"

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
	Local cZOB  := GetNextAlias()

	Default cMsg    := ""

	cSql += " SELECT ZO8_FILIAL, ZO8_VERSAO, ZO8_REVISA, ZO8_ANOREF, ZO8_TPPROD, ZO8_PRODUT, ZO8_DTREF, "
	cSql += " 	Z47_QTDM01, Z47_QTDM02, Z47_QTDM03, Z47_QTDM04, Z47_QTDM05, Z47_QTDM06, "
	cSql += "   Z47_QTDM07, Z47_QTDM08, Z47_QTDM09, Z47_QTDM10, Z47_QTDM11, Z47_QTDM12, "
    cSql += "   SUM ( CASE WHEN ISNULL(ZO8_CUS223, 0) > 0 THEN ( ISNULL(ZO8_CUS224, 0) / ZO8_CUS223 ) ELSE 0 END) CUSTO_TOTAL "
	cSql += " FROM " + RetFullName("ZO8", cEmp) + " ZO8 (NOLOCK) "
	cSql += " JOIN " + RetFullName("Z47", cEmp) + " Z47 (NOLOCK) ON "
	cSql += " ( "
	cSql += " 	Z47.Z47_FILIAL = '' AND "
	cSql += " 	Z47.Z47_VERSAO = ZO8.ZO8_VERSAO AND "
	cSql += " 	Z47.Z47_REVISA = ZO8.ZO8_REVISA AND "
	cSql += " 	Z47.Z47_ANOREF = ZO8.ZO8_ANOREF AND "
	cSql += " 	Z47.Z47_PRODUT = ZO8.ZO8_PRODUT AND "
	cSql += " 	Z47.D_E_L_E_T_ = '' "
	cSql += " ) "
	cSql += " WHERE ZO8.D_E_L_E_T_  = '' "
	cSql += " AND ZO8.ZO8_FILIAL    = " + ValToSql(cEmp)
	cSql += " AND ZO8.ZO8_VERSAO    = " + ValToSql(cVersao)
	cSql += " AND ZO8.ZO8_REVISA    = " + ValToSql(cRevisa)
	cSql += " AND ZO8.ZO8_ANOREF    = " + ValToSql(cAnoRef)
	cSql += " GROUP BY ZO8_FILIAL, ZO8_VERSAO, ZO8_REVISA, ZO8_ANOREF, ZO8_TPPROD, ZO8_PRODUT, ZO8_DTREF, "
	cSql += " Z47_QTDM01, Z47_QTDM02, Z47_QTDM03, Z47_QTDM04, Z47_QTDM05, Z47_QTDM06, "
	cSql += " Z47_QTDM07, Z47_QTDM08, Z47_QTDM09, Z47_QTDM10, Z47_QTDM11, Z47_QTDM12 "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		If EmpOpenFile(cZOB, "ZOB", 1, .T., cEmp, @cModo)

			Reclock(cZOB, .T.)
			(cZOB)->ZOB_FILIAL  := cEmp
			(cZOB)->ZOB_VERSAO  := cVersao
			(cZOB)->ZOB_REVISA  := cRevisa
			(cZOB)->ZOB_ANOREF  := cAnoRef
			(cZOB)->ZOB_DTREF   := STOD((cQry)->ZO8_DTREF)
			(cZOB)->ZOB_PRODUT  := (cQry)->ZO8_PRODUT
			(cZOB)->ZOB_QPROD   := &("(cQry)->Z47_QTDM" + SubStr((cQry)->ZO8_DTREF, 5, 2))
			(cZOB)->ZOB_VPROD   := &("(cQry)->Z47_QTDM" + SubStr((cQry)->ZO8_DTREF, 5, 2)) * (cQry)->CUSTO_TOTAL
			(cZOB)->(MsUnlock())

		Else

			lRet := .F.

			cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

			Exit

		EndIf

		If Select(cZOB) > 0

			(cZOB)->(DbCloseArea())

		EndIf

		(cQry)->(DbSkip())

	EndDo

	(cQry)->(DbCloseArea())

Return(lRet)
