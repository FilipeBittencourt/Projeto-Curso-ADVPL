#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA615
@author Wlysses Cerqueira (Facile)
@since 04/12/2020
@version 1.0
@description Processamento - Kardex Orçado - Estoque (Qtd/Custo) Real em DataRF.
@type function
@Obs Projeto A-35
/*/

User Function BIA615()

	cCadastro := Upper(Alltrim("Kardex Orçado - Saldos Iniciais"))
	aRotina   := { {"Pesquisar"          ,"AxPesqui"                       ,0,1},;
	{               "Visualizar"         ,"AxVisual"                       ,0,2},;
	{               "Estoque Real/Atual" ,'ExecBlock("BIA615A",.F.,.F.)'   ,0,3},;
	{               "Mvtos. Projetado"   ,'ExecBlock("BIA613",.F.,.F.)'    ,0,3},;
	{               "Saldos Iniciais"    ,'ExecBlock("BIA614",.F.,.F.)'    ,0,3} }

	dbSelectArea("ZOA")
	dbSetOrder(1)
	dbGoTop()

	mBrowse(06,01,22,75,"ZOA")

Return

User Function BIA615A()

	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "Kardex Orçado - Estoque (Qtd/Custo) Real em DataRF"
	Private msCanPrc  := .F.

	oPerg := TWPCOFiltroPeriodo():New()

	If oPerg:Pergunte(, .T.)

		Begin Transaction

			xVerRet := .F.
			Processa({ || ExistThenD(cFilAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, @cMsg) }, "Aguarde...", "Deletando dados...", .F.)
			If xVerRet

				Processa({ || fProcessa(cFilAnt, oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, oPerg:dDataFech, @cMsg) }, "Aguarde...", "Processando dados...", .F.)
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

			MsgSTOP("Erro no processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA615")

		Else

			MsgINFO("Fim do processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO - BIA615")

		EndIf

	Else

		MsgALERT("Processamento Abortado", "BIA615")

	EndIf

Return

Static Function fProcessa(msFil, cVersao, cRevisa, cAnoRef, dDataFech, cMsg)

	Local lRet  := .T.
	Local cSQL  := ""
	Local cQry  := GetNextAlias()

	Default cMsg    := ""

	cSql := " SELECT B9_FILIAL, "
	cSql += "        SUBSTRING(B9_COD, 1, 7) + '1       ' B9_COD, "
	cSql += "        B9_DATA, "
	cSql += "        SUM(B9_QINI) B9_QINI, "
	cSql += "        SUM(B9_VINI1) B9_VINI1 "
	cSql += " FROM " + RetFullName("SB9", cEmpAnt) + " SB9 (NOLOCK) "
	cSql += " INNER JOIN " + RetFullName("SB1", cEmpAnt) + " SB1 (NOLOCK) ON "
	cSql += " ( "
	cSql += " 	SB1.B1_FILIAL   = '" + xFilial("SB1") +  "' AND "
	cSql += " 	SB1.B1_COD      = B9_COD AND "
	cSql += " 	SB1.B1_TIPO     = 'PA' AND "
	cSql += " 	SB1.D_E_L_E_T_  = '' "
	cSql += " ) "
	cSql += " WHERE SB9.B9_FILIAL   = '" + xFilial("SB9") + "' "
	cSql += " AND SB9.B9_DATA       = " + ValToSql(dDataFech)
	cSql += " AND SB9.B9_VINI1 <> 0 "
	cSql += " AND SB9.D_E_L_E_T_    = '' "
	cSql += " GROUP BY B9_FILIAL, "
	cSql += "          SUBSTRING(B9_COD, 1, 7), "
	cSql += "          B9_DATA "

	TcQuery cSQL New Alias (cQry)

	ProcRegua(0)
	While !(cQry)->(Eof())

		IncProc("Processando Registros encontrados na base...")

		Reclock("ZOA", .T.)
		ZOA->ZOA_FILIAL  := xFilial("ZOA")
		ZOA->ZOA_VERSAO  := cVersao
		ZOA->ZOA_REVISA  := cRevisa
		ZOA->ZOA_ANOREF  := cAnoRef
		ZOA->ZOA_DTVIRA  := dDataFech
		ZOA->ZOA_DTREF   := LastDay(STOD(cValToChar(Val(cAnoRef) - 1) + "12" + "01"))
		ZOA->ZOA_PRODUT  := (cQry)->B9_COD
		ZOA->ZOA_QATU    := (cQry)->B9_QINI
		ZOA->ZOA_VATU    := (cQry)->B9_VINI1
		ZOA->(MsUnlock())

		(cQry)->(DbSkip())

	End

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return(lRet)

Static Function ExistThenD(msFil, cVersao, cRevisa, cAnoRef, cMsg)

	Local cSQL  := ""
	Local cQry  := ""
	Local lPerg := .T.
	Local lRet  := .T.

	Default cMsg := ""

	cQry := GetNextAlias()

	cSql := " SELECT R_E_C_N_O_ RECNO "
	cSql += " FROM " + RetFullName("ZOA", cEmpAnt) + " ZOA (NOLOCK) "
	cSql += " WHERE ZOA_FILIAL = '" + xFilial("ZOA") + "'
	cSql += "       AND ZOA_VERSAO = " + ValToSql(cVersao)
	cSql += "       AND ZOA_REVISA = " + ValToSql(cRevisa)
	cSql += "       AND ZOA_ANOREF = " + ValToSql(cAnoRef)
	cSql += "       AND ZOA.D_E_L_E_T_ = ' ' "

	TcQuery cSQL New Alias (cQry)

	ProcRegua(0)
	While !(cQry)->(Eof())

		IncProc("Apagando Registros encontrados na base...")

		If lPerg

			If MsgYesNo("Já existem dados para o tempo orçamentário. Deseja continuar?" + CRLF + CRLF + "Caso clique em sim esses dados serão apagados e gerados novos!", "Empresa: [" + cEmpAnt + "]  - ATENÇÃO")

				lRet := .T.

			Else

				lRet := .F.

				Exit

			EndIf

			lPerg := .F.

		EndIf

		ZOA->(DBGoTo((cQry)->RECNO))
		If !ZOA->(EOF())

			Reclock("ZOA", .F.)
			ZOA->(DBDelete())
			ZOA->(MsUnlock())

		EndIf

		(cQry)->(DbSkip())

	End

	(cQry)->(DbCloseArea())

	xVerRet := lRet 

Return ( lRet )
