#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA610
@author Wlysses Cerqueira (Facile)
@since 03/12/2020
@version 1.0
@description Processamento - Kardex Orçado - Custo das produções Orçadas.
@type function
@Obs Projeto A-35
/*/

User Function BIA610()

	cCadastro := Upper(Alltrim("Kardex Orçado"))
	aRotina   := { {"Pesquisar"               ,"AxPesqui"                      ,0,1},;
	{               "Visualizar"              ,"AxVisual"                      ,0,2},;
	{               "Produção Orçada"         ,'ExecBlock("BIA610A",.F.,.F.)'  ,0,3},;
	{               "Kardex Orçado"           ,'ExecBlock("BIA616",.F.,.F.)'   ,0,3},;
	{               "Variação de Estoque"     ,'ExecBlock("BIA619",.F.,.F.)'   ,0,3},;
	{               "Gera Excel Kardex"       ,'ExecBlock("BIA639",.F.,.F.)'   ,0,3} }

	dbSelectArea("ZOB")
	dbSetOrder(1)
	dbGoTop()

	mBrowse(06,01,22,75,"ZOB")

Return

User Function BIA610A()

	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "Kardex Orçado - Custo das produções Orçadas"
	Private msCanPrc  := .F.

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte()

		Begin Transaction

			xVerRet := .F.
			Processa({ || ExistThenD(cEmpAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Deletando dados...", .F.)
			If xVerRet

				Processa({ || fProcessa(cEmpAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Processando dados...", .F.)
				lRet := xVerRet 

			Else

				msCanPrc  := .T.

			EndIf

			If !lRet

				DisarmTransaction()

			EndIf

		End Transaction

	Else

		msCanPrc  := .T.

	EndIf

	If !msCanPrc

		If !lRet

			MsgSTOP("Erro no processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA610")

		Else

			MsgINFO("Fim do processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA610")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "BIA610")

	EndIf

Return

Static Function fProcessa(cEmp, cVersao, cRevisa, cAnoRef, cMsg)

	Local lRet  := .T.
	Local cSQL  := ""
	Local cQry  := GetNextAlias()

	Default cMsg    := ""

	cSql += " SELECT ZO8_FILIAL, "
	cSql += " 	     ZO8_VERSAO, "
	cSql += " 	     ZO8_REVISA, "
	cSql += " 	     ZO8_ANOREF, "
	cSql += " 	     ZO8_PRODUT, "
	cSql += " 	     ZO8_DTREF, "
	cSql += " 	     Z47_QTDM01, "
	cSql += " 	     Z47_QTDM02, "
	cSql += " 	     Z47_QTDM03, "
	cSql += " 	     Z47_QTDM04, "
	cSql += " 	     Z47_QTDM05, "
	cSql += " 	     Z47_QTDM06, "
	cSql += "        Z47_QTDM07, "
	cSql += " 	     Z47_QTDM08, "
	cSql += " 	     Z47_QTDM09, "
	cSql += " 	     Z47_QTDM10, "
	cSql += " 	     Z47_QTDM11, "
	cSql += " 	     Z47_QTDM12, "
	cSql += "        SUM(ZO8_CUS224) CUSTO_TOTAL "
	cSql += " FROM " + RetFullName("ZO8", cEmp) + " ZO8 (NOLOCK) "
	cSql += " JOIN " + RetFullName("Z47", cEmp) + " Z47 (NOLOCK) ON "
	cSql += " ( "
	cSql += " 	Z47.Z47_FILIAL = '" + xFilial("Z47") +  "' AND "
	cSql += " 	Z47.Z47_VERSAO = ZO8.ZO8_VERSAO AND "
	cSql += " 	Z47.Z47_REVISA = ZO8.ZO8_REVISA AND "
	cSql += " 	Z47.Z47_ANOREF = ZO8.ZO8_ANOREF AND "
	cSql += " 	Z47.Z47_PRODUT = ZO8.ZO8_PRODUT AND "
	cSql += " 	Z47.D_E_L_E_T_ = ' ' "
	cSql += " ) "
	cSql += " WHERE ZO8.D_E_L_E_T_  = ' ' "
	cSql += " AND ZO8.ZO8_FILIAL    = " + ValToSql(cEmp)
	cSql += " AND ZO8.ZO8_VERSAO    = " + ValToSql(cVersao)
	cSql += " AND ZO8.ZO8_REVISA    = " + ValToSql(cRevisa)
	cSql += " AND ZO8.ZO8_ANOREF    = " + ValToSql(cAnoRef)
	cSql += " GROUP BY ZO8_FILIAL, "
	cSql += "          ZO8_VERSAO, "
	cSql += "          ZO8_REVISA, "
	cSql += "          ZO8_ANOREF, "
	cSql += "          ZO8_PRODUT, "
	cSql += "          ZO8_DTREF, "
	cSql += "          Z47_QTDM01, "
	cSql += "          Z47_QTDM02, "
	cSql += "          Z47_QTDM03, "
	cSql += "          Z47_QTDM04, "
	cSql += "          Z47_QTDM05, "
	cSql += "          Z47_QTDM06, "
	cSql += "          Z47_QTDM07, "
	cSql += "          Z47_QTDM08, "
	cSql += "          Z47_QTDM09, "
	cSql += "          Z47_QTDM10, "
	cSql += "          Z47_QTDM11, "
	cSql += "          Z47_QTDM12 "

	TcQuery cSQL New Alias (cQry)

	ProcRegua(0)
	While !(cQry)->(Eof())

		IncProc("Processando Registros encontrados na base...")

		Reclock("ZOB", .T.)
		ZOB->ZOB_FILIAL  := cEmp
		ZOB->ZOB_VERSAO  := cVersao
		ZOB->ZOB_REVISA  := cRevisa
		ZOB->ZOB_ANOREF  := cAnoRef
		ZOB->ZOB_DTREF   := STOD((cQry)->ZO8_DTREF)
		ZOB->ZOB_PRODUT  := (cQry)->ZO8_PRODUT
		ZOB->ZOB_QPROD   := &("(cQry)->Z47_QTDM" + SubStr((cQry)->ZO8_DTREF, 5, 2))
		ZOB->ZOB_VPROD   := (cQry)->CUSTO_TOTAL
		ZOB->(MsUnlock())

		(cQry)->(DbSkip())

	End

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return(lRet)

Static Function ExistThenD(cEmp, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL  := ""
	Local cQry  := ""
	Local lPerg := .T.
	Local lRet  := .T.

	Default cMsg := ""

	cQry := GetNextAlias()

	cSql := " SELECT R_E_C_N_O_ RECNO "
	cSql += " FROM " + RetFullName("ZOB", cEmp) + " ZOB (NOLOCK) "
	cSql += " WHERE ZOB_FILIAL      = " + ValToSql(cEmp)
	cSql += " AND ZOB_VERSAO        = " + ValToSql(cVersao)
	cSql += " AND ZOB_REVISA        = " + ValToSql(cRevisa)
	cSql += " AND ZOB_ANOREF        = " + ValToSql(cAnoRef)
	cSql += " AND ZOB.D_E_L_E_T_    = ' ' "

	TcQuery cSQL New Alias (cQry)

	ProcRegua(0)
	While !(cQry)->(Eof())

		IncProc("Apagando Registros encontrados na base...")

		If lPerg

			If MsgYesNo("Já existem dados para o tempo orçamentário. Deseja continuar?" + CRLF + CRLF + "Caso clique em sim esses dados serão apagados e gerados novos!", "Empresa: [" + cEmp + "]  - ATENÇÃO")

				lRet := .T.

			Else

				lRet := .F.

				Exit

			EndIf

			lPerg := .F.

		EndIf

		ZOB->(DBGoTo((cQry)->RECNO))
		If !ZOB->(EOF())

			Reclock("ZOB", .F.)
			ZOB->(DBDelete())
			ZOB->(MsUnlock())

		EndIf

		(cQry)->(DbSkip())

	End

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return ( lRet )
