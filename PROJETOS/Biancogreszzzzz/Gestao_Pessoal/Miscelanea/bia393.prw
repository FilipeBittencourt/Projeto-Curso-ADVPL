#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIA393
@author Marcos Alberto Soprani
@since 25/09/17
@version 1.0
@description Integração com Excel para diversas telas de ORÇAMENTO
@type function
/*/

User Function BIA393(xMsOrig)

	Processa({ || cMsg := Rpt393Detail(xMsOrig) }, "Aguarde...", "Carregando dados...",.F.)

Return

Static Function Rpt393Detail(xMsOrig)

	Local _cAlias   := GetNextAlias()
	Local nRegAtu   := 0
	Local _daduser
	Local _mNomeUsr

	Local msVetDados := _oGetDados:aCols
	Local msVetColun := _oGetDados:aHeader
	Local msVetPlan  := {}
	Local msNomeFunc := _oGetDados:OWND:cCaption
	Local zpM, pmZ

	local cCab1Fon   := 'Calibri' 
	local cCab1TamF  := 8   
	local cCab1CorF  := '#FFFFFF'
	local cCab1Fun   := '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'
	Local nConsumo	 :=	0

	local cEmpresa   := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML    := UPPER(Alltrim(FunName())) + "_" + ALLTrim( DTOS(DATE()) + "_" + StrTran( time(),':',''))
	private cDirDest := "c:\temp\"

	oExcel := ARSexcel():New()

	msQtdLinhas := Len(_oGetDados:aCols) 
	ProcRegua(msQtdLinhas)

	If xMsOrig == "A" // Origem aCols

		AADD(msVetPlan, Array(1 + Len(msVetColun) + 1) )
		msVetPlan[Len(msVetPlan), 1] := 20 
		For zpM := 1 to Len(msVetColun)
			msVetPlan[Len(msVetPlan), zpM+1] := msVetColun[zpM][4] * 5
			If msVetPlan[Len(msVetPlan), zpM+1] < 60
				msVetPlan[Len(msVetPlan), zpM+1] := 60
			EndIf
			If msVetPlan[Len(msVetPlan), zpM+1] > 150
				msVetPlan[Len(msVetPlan), zpM+1] := 150
			EndIf
		Next zpM
		msVetPlan[Len(msVetPlan), 1 + Len(msVetColun) + 1] := 10

		oExcel:AddPlanilha("Relatorio", msVetPlan[Len(msVetPlan)], 6)

		oExcel:AddLinha(20)
		oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2, (1 + Len(msVetColun) + 1) - 3 ) 
		oExcel:AddLinha(15)
		oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2, (1 + Len(msVetColun) + 1) - 3 ) 
		oExcel:AddLinha(15)
		oExcel:AddLinha(20)
		oExcel:AddCelula("Orçamento - " + msNomeFunc, 0, 'L', cFonte1, nTamFont1, cCorFont1, .T., , cCorFun1, , , , , .T., 2, (1 + Len(msVetColun) + 1) - 3 )  

		oExcel:AddLinha(20)
		oExcel:AddLinha(12) 
		oExcel:AddCelula()
		For zpM := 1 to Len(msVetColun)
			msAlinh   := IIF(msVetColun[zpM][8] == "N", "R", IIF(msVetColun[zpM][8] == "C", "L", "C"))
			oExcel:AddCelula(Alltrim(msVetColun[zpM][1]), 2, msAlinh, cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		Next zpM

		For pmZ := 1 to Len(msVetDados)

			IncProc("Carregando dados " + AllTrim(Str(pmZ)) + " de " + AllTrim(Str(msQtdLinhas)))

			nRegAtu++
			if MOD(nRegAtu,2) > 0 
				cCorFun2 := '#DCE6F1'
			else
				cCorFun2 := '#B8CCE4'
			endif

			oExcel:AddLinha(14) 
			oExcel:AddCelula()
			For zpM := 1 to Len(msVetColun)
				msAlinh   := IIF(msVetColun[zpM][8] == "N", "R", IIF(msVetColun[zpM][8] == "C", "L", "C"))
				oExcel:AddCelula( msVetDados[pmZ][zpM], TamSx3(Alltrim(msVetColun[1][2]))[2] , msAlinh, cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			Next zpM

		Next pmZ

	ElseIf xMsOrig == "Q"  // Query

		oExcel:AddPlanilha("Relatorio", {20, 70, 70, 70, 70, 150, 50, 150, 60, 60}, 6)

		oExcel:AddLinha(20)
		oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2, (1 + Len(msVetColun) + 1) - 3 ) 
		oExcel:AddLinha(15)
		oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2, (1 + Len(msVetColun) + 1) - 3 ) 
		oExcel:AddLinha(15)
		oExcel:AddLinha(20)
		oExcel:AddCelula("Orçamento - " + msNomeFunc, 0, 'L', cFonte1, nTamFont1, cCorFont1, .T., , cCorFun1, , , , , .T., 2, (1 + Len(msVetColun) + 1) - 3 )  

		oExcel:AddLinha(20)
		oExcel:AddLinha(12) 
		oExcel:AddCelula()
		oExcel:AddCelula("Versão"          , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("Revisão"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("Ano.Ref"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("Usuário"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("Nome"            , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("Classe Valor"    , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("Descrição"       , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("Digita?"         , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		oExcel:AddCelula("Visualiza"       , 0, "L", cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)

		BeginSql Alias _cAlias

			SELECT *
			FROM %TABLE:ZB9% ZB9
			WHERE ZB9_FILIAL = %xFilial:ZB9%
			AND ZB9_VERSAO = %Exp:_cVersao%
			AND ZB9_REVISA = %Exp:_cRevisa%
			AND ZB9_ANOREF = %Exp:_cAnoRef%
			AND ZB9_TPORCT = %Exp:_cTpOrc%
			AND ZB9.%NotDel%
		EndSql

		If (_cAlias)->(!Eof())

			While (_cAlias)->(!Eof())

				IncProc("Carregando dados " + AllTrim(Str((_cAlias)->(Recno()))) + " de " + AllTrim(Str(msQtdLinhas)))

				psworder(1)                          // Pesquisa por Nome
				If  pswseek((_cAlias)->ZB9_USER,.t.) // Nome do usuario, Pesquisa usuarios
					_daduser  := pswret(1)           // Numero do registro
					_mNomeUsr := _daduser[1][4]
				EndIf
				nRegAtu++
				if MOD(nRegAtu,2) > 0 
					cCorFun2 := '#DCE6F1'
				else
					cCorFun2 := '#B8CCE4'
				endif

				CTH->(dbSetOrder(1))
				CTH->(dbSeek( xFilial("CTH") + (_cAlias)->ZB9_CLVL ) )
				oExcel:AddLinha(14) 
				oExcel:AddCelula()
				oExcel:AddCelula( (_cAlias)->ZB9_VERSAO                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( (_cAlias)->ZB9_REVISA                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( (_cAlias)->ZB9_ANOREF                            , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( (_cAlias)->ZB9_USER                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( _mNomeUsr                                        , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( (_cAlias)->ZB9_CLVL                              , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( CTH->CTH_DESC01                                  , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( IIF((_cAlias)->ZB9_DIGIT = '1', "Sim", "Não")    , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
				oExcel:AddCelula( IIF((_cAlias)->ZB9_VISUAL = '1', "Sim", "Não")   , 0 , "L", cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)

				(_cAlias)->(dbSkip())

			EndDo

			(_cAlias)->(dbCloseArea())

		EndIf

	ElseIf xMsOrig == "E"  // Estrutura

		AADD(msVetPlan, Array(1 + Len(msVetColun) + 1) )
		msVetPlan[Len(msVetPlan), 1] := 20 
		For zpM := 1 to Len(msVetColun)
			msVetPlan[Len(msVetPlan), zpM+1] := msVetColun[zpM][4] * 5
			If msVetPlan[Len(msVetPlan), zpM+1] < 60
				msVetPlan[Len(msVetPlan), zpM+1] := 60
			EndIf
			If msVetPlan[Len(msVetPlan), zpM+1] > 150
				msVetPlan[Len(msVetPlan), zpM+1] := 150
			EndIf
		Next zpM
		msVetPlan[Len(msVetPlan), 1 + Len(msVetColun) + 1] := 10

		oExcel:AddPlanilha("Relatorio", msVetPlan[Len(msVetPlan)], 0)

		oExcel:AddLinha(20)
		oExcel:AddCelula()
		For zpM := 1 to Len(msVetColun)
			msAlinh   := IIF(msVetColun[zpM][8] == "N", "R", IIF(msVetColun[zpM][8] == "C", "L", "C"))
			oExcel:AddCelula(Alltrim(msVetColun[zpM][2]), 2, msAlinh, cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		Next zpM

		For pmZ := 1 to Len(msVetDados)

			IncProc("Carregando dados " + AllTrim(Str(pmZ)) + " de " + AllTrim(Str(msQtdLinhas)))

			nRegAtu++
			if MOD(nRegAtu,2) > 0 
				cCorFun2 := '#DCE6F1'
			else
				cCorFun2 := '#B8CCE4'
			endif

			oExcel:AddLinha(14) 
			oExcel:AddCelula()
			For zpM := 1 to Len(msVetColun)
				msAlinh   := IIF(msVetColun[zpM][8] == "N", "R", IIF(msVetColun[zpM][8] == "C", "L", "C"))
				oExcel:AddCelula( msVetDados[pmZ][zpM], TamSx3(Alltrim(msVetColun[1][2]))[2] , msAlinh, cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			Next zpM

		Next pmZ

	ElseIf xMsOrig == "R"  // RELATORIO

		AADD(msVetPlan, Array(1 + Len(msVetColun) + 1) )
		msVetPlan[Len(msVetPlan), 1] := 20 
		For zpM := 1 to Len(msVetColun)
			msVetPlan[Len(msVetPlan), zpM+1] := msVetColun[zpM][4] * 5
			If msVetPlan[Len(msVetPlan), zpM+1] < 60
				msVetPlan[Len(msVetPlan), zpM+1] := 60
			EndIf
			If msVetPlan[Len(msVetPlan), zpM+1] > 150
				msVetPlan[Len(msVetPlan), zpM+1] := 150
			EndIf
		Next zpM
		msVetPlan[Len(msVetPlan), 1 + Len(msVetColun) + 1] := 10

		oExcel:AddPlanilha("Relatorio", msVetPlan[Len(msVetPlan)], 0)

		oExcel:AddLinha(20)
		oExcel:AddCelula()
		For zpM := 1 to Len(msVetColun)
			msAlinh   := IIF(msVetColun[zpM][8] == "N", "R", IIF(msVetColun[zpM][8] == "C", "L", "C"))
			oExcel:AddCelula(Alltrim(msVetColun[zpM][1]), 2, msAlinh, cCab1Fon, cCab1TamF, cCab1CorF, .T., .T., cCab1Fun, .T., .T., .T., .T.)
		Next zpM

		For pmZ := 1 to Len(msVetDados)

			IncProc("Carregando dados " + AllTrim(Str(pmZ)) + " de " + AllTrim(Str(msQtdLinhas)))

			nRegAtu++
			if MOD(nRegAtu,2) > 0 
				cCorFun2 := '#DCE6F1'
			else
				cCorFun2 := '#B8CCE4'
			endif

			oExcel:AddLinha(14) 
			oExcel:AddCelula()
			For zpM := 1 to Len(msVetColun)
				msAlinh   := IIF(msVetColun[zpM][8] == "N", "R", IIF(msVetColun[zpM][8] == "C", "L", "C"))
				oExcel:AddCelula( msVetDados[pmZ][zpM], TamSx3(Alltrim(msVetColun[1][2]))[2] , msAlinh, cFonte2, nTamFont2, cCorFont2, , , cCorFun2, .T., .T., .T., .T.)
			Next zpM

		Next pmZ

	EndIf

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 

Return
