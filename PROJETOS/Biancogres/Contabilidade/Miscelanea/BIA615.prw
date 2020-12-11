#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA615
@author Wlysses Cerqueira (Facile)
@since 04/12/2020
@version 1.0
@Projet A-35
@description Processamento - Kardex Orçado - Estoque (Qtd/Custo) Real em DataRF.
@type function
/*/

User Function BIA615()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "Kardex Orçado - Estoque (Qtd/Custo) Real em DataRF"

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

		Alert("Erro no processamento!" + CRLF + CRLF + cMsg, "ATENÇÃO")

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

    cSql := " SELECT B9_FILIAL, B9_COD, B9_LOCAL, B9_QINI, B9_VINI1 "
    cSql += " FROM " + RetFullName("SB9", cEmp) + " SB9 (NOLOCK) "
    cSql += " INNER JOIN " + RetFullName("SB1", cEmp) + " SB1 (NOLOCK) ON "
    cSql += " ( "
    cSql += " 	SB1.B1_FILIAL   = '' AND "
    cSql += " 	SB1.B1_COD      = B9_COD AND "
    cSql += " 	SB1.B1_TIPO     = 'PA' AND "
    cSql += " 	SB1.D_E_L_E_T_  = '' "
    cSql += " ) "
    cSql += " WHERE SB9.B9_FILIAL   = '01' "
    cSql += " AND SB9.B9_DATA       = " + ValToSql(dDataFech)
    cSql += " AND SB9.B9_QINI       <> 0 "
    cSql += " AND SB9.B9_LOCAL NOT IN ('05') "
    cSql += " AND SB9.D_E_L_E_T_    = '' "

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		If EmpOpenFile(cZOA, "ZOA", 1, .T., cEmp, @cModo)

			Reclock(cZOA, .T.)
			(cZOA)->ZOA_FILIAL  := cEmp
			(cZOA)->ZOA_VERSAO  := cVersao
			(cZOA)->ZOA_REVISA  := cRevisa
			(cZOA)->ZOA_ANOREF  := cAnoRef
            (cZOA)->ZOA_DTVIRA  := dDataFech
			(cZOA)->ZOA_DTREF   := dDataFech
			(cZOA)->ZOA_PRODUT  := (cQry)->B9_COD
            (cZOA)->ZOA_LOCAL   := (cQry)->B9_LOCAL
            (cZOA)->ZOA_QATU    := (cQry)->B9_QINI
            (cZOA)->ZOA_VATU    := (cQry)->B9_VINI1
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
