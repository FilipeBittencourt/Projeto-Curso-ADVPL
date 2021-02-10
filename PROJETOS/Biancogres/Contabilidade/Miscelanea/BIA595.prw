#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA595
@author Wlysses Cerqueira (Facile)
@since 26/10/2020
@version 1.0
@description Consolidação das empresas na empresa Consolidada 90 e filial 90. 
@type function
@Obs Projeto A-35
/*/

User Function BIA595()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local oPerg	:= Nil

	Private cTitulo := "Consolidação Orçamento Grupo"

	oEmp := TLoadEmpresa():New()

	oPerg := TWPCOFiltroPeriodo():New()

	If cEmpAnt == "90" .and. cFilAnt == "90"

		If oPerg:Pergunte()

			oEmp:GetSelEmp({"90"})

			If Len(oEmp:aEmpSel) > 0

				For nW := 1 To Len(oEmp:aEmpSel)

					Begin Transaction

						If oEmp:aEmpSel[nW][1] <> "90"

							Processa(oEmp:aEmpSel[nW][1], oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef)

						EndIf

					End Transaction

				Next nW

			Else

				Alert("Nenhuma empresa foi selecionada!")

			EndIf

		EndIf

	Else

		Alert("Rotina exclusiva para Empresa 90 e na Filial 90!")

	EndIf

Return

Static Function Processa(cEmp, cVersao, cRevisa, cAnoRef)

	Local lRet := .F.
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT * "
	cSQL += " FROM " + RetFullName("ZBZ", cEmp) + " ZBZ "
	cSQL += " WHERE ZBZ.ZBZ_FILIAL 	= " + ValToSQL(xFilial("ZBZ"))
	cSQL += " AND ZBZ.ZBZ_VERSAO	= " + ValToSQL(cVersao)
	cSQL += " AND ZBZ.ZBZ_REVISA	= " + ValToSQL(cRevisa)
	cSQL += " AND ZBZ.ZBZ_ANOREF	= " + ValToSQL(cAnoRef)
	cSQL += " AND NOT EXISTS "
	cSQL += " ( "
	cSQL += "     SELECT NULL "
	cSQL += "     FROM " + RetSQLName("ZBZ") + " A "
	cSQL += "     WHERE A.ZBZ_FILIAL = " + ValToSQL(cEmp)
	cSQL += "	  AND A.ZBZ_VERSAO 	 = ZBZ.ZBZ_VERSAO "
	cSQL += " 	  AND A.ZBZ_REVISA 	 = ZBZ.ZBZ_REVISA "
	cSQL += " 	  AND A.ZBZ_ANOREF 	 = ZBZ.ZBZ_ANOREF "
	cSQL += "     AND A.D_E_L_E_T_ 	 = '' "
	cSQL += " ) "
	cSQL += " AND ZBZ.D_E_L_E_T_ 	= '' "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		Reclock("ZBZ",.T.)
		ZBZ->ZBZ_FILIAL := cEmp
		ZBZ->ZBZ_VERSAO := (cQry)->ZBZ_VERSAO
		ZBZ->ZBZ_REVISA := (cQry)->ZBZ_REVISA
		ZBZ->ZBZ_ANOREF := (cQry)->ZBZ_ANOREF
		ZBZ->ZBZ_ORIPRC := (cQry)->ZBZ_ORIPRC
		ZBZ->ZBZ_ORGLAN := (cQry)->ZBZ_ORGLAN
		ZBZ->ZBZ_DATA   := STOD((cQry)->ZBZ_DATA)
		ZBZ->ZBZ_LOTE   := (cQry)->ZBZ_LOTE
		ZBZ->ZBZ_SBLOTE := (cQry)->ZBZ_SBLOTE
		ZBZ->ZBZ_DOC    := (cQry)->ZBZ_DOC
		ZBZ->ZBZ_LINHA  := (cQry)->ZBZ_LINHA
		ZBZ->ZBZ_DC     := (cQry)->ZBZ_DC
		ZBZ->ZBZ_DEBITO := (cQry)->ZBZ_DEBITO
		ZBZ->ZBZ_CREDIT := (cQry)->ZBZ_CREDIT
		ZBZ->ZBZ_CLVLDB := (cQry)->ZBZ_CLVLDB
		ZBZ->ZBZ_CLVLCR := (cQry)->ZBZ_CLVLCR
		ZBZ->ZBZ_ITEMD  := (cQry)->ZBZ_ITEMD
		ZBZ->ZBZ_ITEMC  := (cQry)->ZBZ_ITEMC
		ZBZ->ZBZ_VALOR  := (cQry)->ZBZ_VALOR
		ZBZ->ZBZ_HIST   := (cQry)->ZBZ_HIST
		ZBZ->ZBZ_YHIST  := (cQry)->ZBZ_YHIST
		ZBZ->ZBZ_SI     := (cQry)->ZBZ_SI
		ZBZ->ZBZ_YDELTA := STOD((cQry)->ZBZ_YDELTA)
		ZBZ->(MsUnlock())

		(cQry)->(DbSkip())

		lRet := .T.

	EndDo

	(cQry)->(DbCloseArea())

Return(lRet)
