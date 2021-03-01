#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

function u_dummy637()
	if (.F.)
		BIA637()
	endif
	return

/*/{Protheus.doc} BIA637
@author Wlysses Cerqueira (Facile)
@since 18/12/2020
@version 1.0
@Projet A-35
@description BP Consolidado - BP Real (MesRef).
@type function
/*/

static Function BIA637()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .F.
	Local oPerg	:= Nil
	Local cMsg  := ""

	Private cTitulo := "Consolidado - BP Real (MesRef)"

	RpcSetEnv("01", "01")

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

	RpcClearEnv()

Return()

Static Function Processa(cEmp, cVersao, cRevisa, cAnoRef, cMsg) as caracter

	Local lRet  := .T.
	Local cSQL  := ""
	Local cModo := "" //Modo de acesso do arquivo aberto //"E" ou "C"
	Local cQry  := GetNextAlias()
	Local cZOD  := GetNextAlias()

	Default cMsg    := ""

	cSql := " SELECT * "
	cSql += " FROM " + RetFullName("ZOD", cEmp) + " ZOD (NOLOCK) "
	cSql += " WHERE ZOD.D_E_L_E_T_  = '' "
	cSql += " AND ZOD.ZOD_FILIAL    = " + ValToSql(cEmp)
	cSql += " AND ZOD.ZOD_VERSAO    = " + ValToSql(cVersao)
	cSql += " AND ZOD.ZOD_REVISA    = " + ValToSql(cRevisa)
	cSql += " AND ZOD.ZOD_ANOREF    = " + ValToSql(cAnoRef)
    cSql += " AND ZOD.ZOD_TIPO      = '2' " 
    cSQL += " AND ZOD.ZOD_DTREF     BETWEEN " + ValToSql(CTOD("01" + "/" + "01" + "/" + cValToChar(Val(cAnoRef) + 1))) + " AND " + ValToSql(LastDay(CTOD("01" + "/" + "01" + "/" + cValToChar(Val(cAnoRef) + 1))))
    
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		If EmpOpenFile(cZOD, "ZOD", 1, .T., cEmp, @cModo)

			Reclock(cZOD,.T.)
			(cZOD)->ZOD_FILIAL  := cEmp
			(cZOD)->ZOD_VERSAO  := cVersao
			(cZOD)->ZOD_REVISA  := cRevisa
			(cZOD)->ZOD_ANOREF  := cAnoRef
			(cZOD)->ZOD_DTREF   := STOD((cQry)->DATARF)
			(cZOD)->ZOD_TIPO    := "3"
			(cZOD)->ZOD_DTPROC	:= dDataBase
			(cZOD)->ZOD_CONTA   := (cQry)->ZOD_CONTA
			(cZOD)->ZOD_SALCTA  := (cQry)->ZOD_SALCTA
			(cZOD)->(MsUnlock())

		Else

			lRet := .F.

			cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

			Exit

		EndIf

		(cQry)->(DbSkip())

	EndDo

	If Select(cZOD) > 0

		(cZOD)->(DbCloseArea())

	EndIf

	(cQry)->(DbCloseArea())

Return(lRet)
