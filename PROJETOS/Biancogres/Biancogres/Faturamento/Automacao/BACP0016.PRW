#Include "Protheus.CH"
#Include "TOTVS.CH"
#Include "TOPCONN.CH"
#Include "tbiconn.ch"

User Function BACP0016(_cCarga, lJob)

	Default lJob := .F.
	//Local _cCarga := 'Z008'


	If (lJob)

		//RpcSetEnv('01','01')

		oTDadosCarga	:= TDadosCarga():New(_cCarga)

		aList := oTDadosCarga:GetListaNF()

		//U_BACPMGNRE(_cCarga, cEmpAnt, cFilAnt, aList, lJob)

		StartJob("U_BACPMGNRE", GetEnvServer(), .T., _cCarga, cEmpAnt, cFilAnt, aList, lJob)

	EndIf	

Return()

User Function BACPMGNRE(_cCarga, _cEmpOri, _cFilOri, aList, lJob)

	Local cQuery		:= ""
	//Local cCarga		:= 'Z008'
	Local cAliasTrab	:= Nil
	Local oObjGnre		:= Nil
	Local lLoad			:= .T.
	Local lAchou		:= .F.
	Local lAchouAux		:= .F.
	Local nI

	For nI:=1 To Len (aList)

		cEmpGnre	:= aList[nI][1]
		cNumero		:= aList[nI][2]
		cSerie		:= aList[nI][3]
		cCliente	:= aList[nI][5]
		cLoja		:= aList[nI][6]

		If (nI == 1  .Or. cEmpAnt <> cEmpGnre)
			RpcClearEnv()

			RPCSetType(3)
			RPCSetEnv(cEmpGnre, "01")

			If lLoad

				oObjGnre := TAFComprovantePagamento():New()

				oObjGnre:cCaminho := "\P10\AUTOMACAO\MONITOR_IMPRESSAO\"

				oObjGnre:cFilePrint := Alltrim(_cCarga) + "_" + _cEmpOri + "_GNRE"

				oObjGnre:lPosicionado := .T.

				oObjGnre:lImpBoleto := .T.

				oObjGnre:Load()

				lLoad := .F.

			EndIf

		EndIf

		cQuery := "SELECT SE2.R_E_C_N_O_ AS RECNO_SE2, A.R_E_C_N_O_ AS RECNO_SF6 FROM "+RetSQLName("SE2")+" SE2							"

		cQuery += " JOIN (															"
		cQuery += " SELECT * FROM "+RetSQLName("SF6")+" 							"
		cQuery += " WHERE D_E_L_E_T_ 	= '' 				AND						"
		cQuery += " F6_DOC 		= '"+cNumero+"' 		AND							"
		cQuery += " F6_SERIE 	= '"+cSerie+"' 		AND								"
		cQuery += " F6_CLIFOR 	= '"+cCliente+"' 		AND							"
		cQuery += " F6_LOJA 	= '"+cLoja+"'										"
		cQuery += " ) A	ON E2_PREFIXO + E2_NUM = A.F6_NUMERO						"

		cQuery += " WHERE SE2.D_E_L_E_T_ 	= '' 									"

		cAliasTrab := GetNextAlias()

		TcQuery cQuery New Alias (cAliasTrab)	

		DBSelectArea("SE2")

		While !(cAliasTrab)->(EoF())
	
			SE2->(DBGoTo((cAliasTrab)->RECNO_SE2))

			SF6->(DBGoTo((cAliasTrab)->RECNO_SF6))

			lAchou := oObjGnre:Processa(, .F.)

			If lAchou

				lAchouAux := .T.

			EndIf

			(cAliasTrab)->(DbSkip())

		EndDo

		(cAliasTrab)->(DbCloseArea())

	Next nI

	If lAchouAux

		oObjGnre:oPrint:Print()

	Endif

	RpcClearEnv()

Return()