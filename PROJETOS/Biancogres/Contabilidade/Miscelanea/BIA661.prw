#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA661
@author Wlysses Cerqueira (Facile)
@since 28/12/2020
@version 1.0
@Projet A-35
@description BP Consolidado - Previsão de contas a receber.
@type function
/*/

User Function BIA661()

	Local oEmp 	:= Nil
	Local nW	:= 0
	Local lRet  := .F.
	Local oPerg := Nil
	Local cMsg  := ""

	Private oTable  := FWTemporaryTable():New( /*cAlias*/, /*aFields*/)

	Private cTitulo := "Consolidado - Previsão de contas a receber"

	RpcSetEnv("01", "01")

	oEmp := TLoadEmpresa():New()

	oPerg := TWPCOFiltroPeriodo():New(,,.T.)

	If oPerg:Pergunte()

		oEmp:GetSelEmp()

		If Len(oEmp:aEmpSel) > 0

			Begin Transaction

				For nW := 1 To Len(oEmp:aEmpSel)

					lRet := Processa(oEmp:aEmpSel[nW][1], oPerg:cVersao, oPerg:cRevisa, oPerg:cAnoRef, oPerg:cTipoRef, @cMsg)

					If !lRet

						Exit

					EndIf

				Next nW

				If !lRet

					DisarmTransaction()

				EndIf

				If Select(oTable:GetAlias()) > 0

					oTable:Delete()

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

Static Function Processa(cEmp, cVersao, cRevisa, cAnoRef, cTipoRef, cMsg) as caracter

	Local lRet      := .T.
	Local cAliasTmp := ""
	Local nTot      := 0
	Local cZOD      := GetNextAlias()
	Local cZOE      := GetNextAlias()

	Default cMsg    := ""

	GetMatriz()

	If Select(oTable:GetAlias()) > 0

		cAliasTmp := oTable:GetAlias()

		(cAliasTmp)->(DBSetOrder(1)) // ORDEM
		(cAliasTmp)->(DBGoTop())

		While (cAliasTmp)->(!EOF())

			If (cAliasTmp)->ORDEM == "01"

				lRet := GetVAL01(cEmp, cVersao, cRevisa, cAnoRef, cTipoRef, @nTot, cMsg)

				If EmpOpenFile(cZOE, "ZOE", 1, .T., cEmp, @cModo)

					(cZOE)->(DBSetOrder(2)) // ZOE_FILIAL, ZOE_VERSAO, ZOE_REVISA, ZOE_ANOREF, ZOE_VARIAV, ZOE_SEQUEN, R_E_C_N_O_, D_E_L_E_T_

					If (cZOE)->(DbSeek(cEmp + cVersao + cRevisa + cAnoRef + "ySomaSaldoAntRec"))

                        nTot += (cZOE)->ZOE_MES01

					EndIf

				Else

					lRet := .F.

				EndIf

				(cAliasTmp)->VALORES := nTot

			ElseIf (cAliasTmp)->ORDEM == "02"



			ElseIf (cAliasTmp)->ORDEM == "03"



			ElseIf (cAliasTmp)->ORDEM == "04"



			ElseIf (cAliasTmp)->ORDEM == "05"



			ElseIf (cAliasTmp)->ORDEM == "06"



			ElseIf (cAliasTmp)->ORDEM == "07"



			ElseIf (cAliasTmp)->ORDEM == "08"



			ElseIf (cAliasTmp)->ORDEM == "09"



			ElseIf (cAliasTmp)->ORDEM == "10"



			ElseIf (cAliasTmp)->ORDEM == "11"



			ElseIf (cAliasTmp)->ORDEM == "12"



			ElseIf (cAliasTmp)->ORDEM == "13"



			EndIf

			If !lRet

				Exit

			EndIf

			(cAliasTmp)->(DBSkip())

		EndDo

	Else

		lRet := .F.

	EndIf

Return(lRet)

Static Function GetMatriz()

	Local cAliasTmp := ""
	Local aFields   := {}

	aAdd(aFields, { "ORDEM"         , "C", 02, 0 })
	aAdd(aFields, { "BASES"         , "C", 30, 0 })
	aAdd(aFields, { "VALORES"       , "N", 16, 8 })
	aAdd(aFields, { "JANEIRO"	    , "N", 16, 8 })
	aAdd(aFields, { "FEVEREIRO"	    , "N", 16, 8 })
	aAdd(aFields, { "MARCO"	        , "N", 16, 8 })
	aAdd(aFields, { "ABRIL"	        , "N", 16, 8 })
	aAdd(aFields, { "MAIO"  	    , "N", 16, 8 })
	aAdd(aFields, { "JUNHO"	        , "N", 16, 8 })
	aAdd(aFields, { "JULHO"	        , "N", 16, 8 })
	aAdd(aFields, { "AGOSTO"	    , "N", 16, 8 })
	aAdd(aFields, { "SETEMBRO"	    , "N", 16, 8 })
	aAdd(aFields, { "OUTUBRO"	    , "N", 16, 8 })
	aAdd(aFields, { "NOVEMBRO"      , "N", 16, 8 })
	aAdd(aFields, { "DEZEMBRO"      , "N", 16, 8 })

	oTable:SetFields(aFields)

	oTable:AddIndex("01", {"ORDEM"} )

	oTable:Create()

	cAliasTmp := oTable:GetAlias()

	(cAliasTmp)->(DBAppend())
	(cAliasTmp)->ORDEM  := "01"
	(cAliasTmp)->BASES  := "Saldo anterior a receber"
	(cAliasTmp)->(DBCommit())

	(cAliasTmp)->(DBAppend())
	(cAliasTmp)->ORDEM := "02"
	(cAliasTmp)->BASES  := "Contas a Receber JANEIRO"
	(cAliasTmp)->(DBCommit())

	(cAliasTmp)->(DBAppend())
	(cAliasTmp)->ORDEM := "03"
	(cAliasTmp)->BASES  := "Contas a Receber FEVEREIRO"
	(cAliasTmp)->(DBCommit())

	(cAliasTmp)->(DBAppend())
	(cAliasTmp)->ORDEM := "04"
	(cAliasTmp)->BASES  := "Contas a Receber MARCO"
	(cAliasTmp)->(DBCommit())

	(cAliasTmp)->(DBAppend())
	(cAliasTmp)->ORDEM := "05"
	(cAliasTmp)->BASES  := "Contas a Receber ABRIL"
	(cAliasTmp)->(DBCommit())

	(cAliasTmp)->(DBAppend())
	(cAliasTmp)->ORDEM := "06"
	(cAliasTmp)->BASES  := "Contas a Receber MAIO"
	(cAliasTmp)->(DBCommit())

	(cAliasTmp)->(DBAppend())
	(cAliasTmp)->ORDEM := "07"
	(cAliasTmp)->BASES  := "Contas a Receber JUNHO"
	(cAliasTmp)->(DBCommit())

	(cAliasTmp)->(DBAppend())
	(cAliasTmp)->ORDEM := "08"
	(cAliasTmp)->BASES  := "Contas a Receber JULHO"
	(cAliasTmp)->(DBCommit())

	(cAliasTmp)->(DBAppend())
	(cAliasTmp)->ORDEM := "09"
	(cAliasTmp)->BASES  := "Contas a Receber AGOSTO"
	(cAliasTmp)->(DBCommit())

	(cAliasTmp)->(DBAppend())
	(cAliasTmp)->ORDEM := "10"
	(cAliasTmp)->BASES  := "Contas a Receber SETEMBRO"
	(cAliasTmp)->(DBCommit())

	(cAliasTmp)->(DBAppend())
	(cAliasTmp)->ORDEM := "11"
	(cAliasTmp)->BASES  := "Contas a Receber OUTUBRO"
	(cAliasTmp)->(DBCommit())

	(cAliasTmp)->(DBAppend())
	(cAliasTmp)->ORDEM := "12"
	(cAliasTmp)->BASES  := "Contas a Receber NOVEMBRO"
	(cAliasTmp)->(DBCommit())

	(cAliasTmp)->(DBAppend())
	(cAliasTmp)->ORDEM := "13"
	(cAliasTmp)->BASES  := "Contas a Receber DEZEMBRO"
	(cAliasTmp)->(DBCommit())

Return()


Static Function GetVAL01(cEmp, cVersao, cRevisa, cAnoRef, cTipoRef, nTot, cMsg) as caracter

	Local lRet  := .T.
	Local cSQL  := ""
	Local cModo := "" //Modo de acesso do arquivo aberto //"E" ou "C"
	Local nTot  := 0
	Local cQry  := GetNextAlias()
	Local cZOD  := GetNextAlias()

	Default nTot    := 0
	Default cMsg    := ""

	cSql := " SELECT SUM(ZOD_SALCTA) ZOD_SALCTA "
	cSql += " FROM " + RetFullName("ZOD", cEmp) + " ZOD (NOLOCK) "
	cSql += " WHERE ZOD.D_E_L_E_T_  = '' "
	cSql += " AND ZOD.ZOD_FILIAL    = " + ValToSql(cEmp)
	cSql += " AND ZOD.ZOD_VERSAO    = " + ValToSql(cVersao)
	cSql += " AND ZOD.ZOD_REVISA    = " + ValToSql(cRevisa)
	cSql += " AND ZOD.ZOD_ANOREF    = " + ValToSql(cAnoRef)
	cSql += " AND ZOD.ZOD_TIPO      = " + ValToSql(cTipoRef)

	TcQuery cSQL New Alias (cQry)

	If !(cQry)->(Eof())

		If EmpOpenFile(cZOD, "ZOD", 1, .T., cEmp, @cModo)

			nTot := (cZOD)->ZOD_SALCTA

		Else

			lRet := .F.

			cMsg := "Não conseguiu abrir a empresa " + cEmp + " !"

		EndIf

		(cQry)->(DbSkip())

	EndIf

	If Select(cZOD) > 0

		(cZOD)->(DbCloseArea())

	EndIf

	(cQry)->(DbCloseArea())

Return(lRet)
