#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} TRateioComissao
@author Wlysses Cerqueira (Facile)
@since 05/05/2020
@project Ticket 21092
@version 1.0
@description 
@type class
/*/
Class TRateioComissao From LongClasName

	Data cModo
	Data cModoRot
	Data cMesAno
	Data dDtIni
	Data dDtFim

	Method New() Constructor
	Method Rateio(lMod1, aBase)
	Method GetRateio(cVendedor, cMarca, cEmissao, nComissao, nPorc)

	Method Pergunte()
	Method Load()
	Method Calc()
	Method Mod1() // F440LIQ - Caso utilize o padrão de campos
	Method Mod2() // F440ABAS - No momento das baixas
	Method Mod3() // Processo sera rodado todo mes, lê a tabela de comissão (SE3) x rateio e efetua o rateio na propria SE3
	Method Mod3Estorno()
	Method Processa()
	Method GetSeq(nSeq)

EndClass

Method New(cModoRot) Class TRateioComissao

	Default cModoRot := ""

	::cModoRot := cModoRot

	::cModo := AllTrim(GetNewPar("MV_YMODRCO", "3"))

	::cMesAno := Space(6)

	::dDtIni := STOD("  / /    ")

	::dDtFim := STOD("  / /    ")

Return()

Method Rateio(aBase) Class TRateioComissao

	Local aAreaSE1 := SE1->(GetArea())
	Local aAreaSA3 := SA3->(GetArea())
	Local aAreaPZ9 := PZ9->(GetArea())
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSC6 := SC6->(GetArea())
	Local aAreaSF2 := SF2->(GetArea())
	Local aAreaSD2 := SD2->(GetArea())
	Local aVendRat := {}

	Default aBase  := {}

	If ::cModo == ::cModoRot .And. ::cModoRot == "1"

		aVendRat := ::Load()

		aVendRat := ::Calc()

		::Mod1(aVendRat)

	EndIf

	If ::cModo == ::cModoRot .And. ::cModoRot == "2"

		aVendRat := ::Load()

		aVendRat := ::Calc()

		::Mod2(aVendRat, aBase)

	EndIf

	If ::cModo == ::cModoRot .And. ::cModoRot == "3"

		::Mod3()

	EndIf

	RestArea(aAreaPZ9)
	RestArea(aAreaSA3)
	RestArea(aAreaSE1)
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aAreaSF2)
	RestArea(aAreaSD2)

Return()

Method Load() Class TRateioComissao

	Local aAreaSE1 := SE1->(GetArea())
	Local aAreaSA3 := SA3->(GetArea())
	Local aAreaPZ9 := PZ9->(GetArea())
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSC6 := SC6->(GetArea())
	Local aAreaSF2 := SF2->(GetArea())
	Local aAreaSD2 := SD2->(GetArea())
	Local aVendRat := {}

	DBSelectArea("PZ9")
	PZ9->(DBSetOrder(1)) // PZ9_FILIAL, PZ9_VENDPA, PZ9_MARCA, PZ9_VEND, R_E_C_N_O_, D_E_L_E_T_

	DBSelectArea("SA3")
	SA3->(DBSetOrder(1)) // A3_FILIAL, A3_COD, R_E_C_N_O_, D_E_L_E_T_

	DBSelectArea("SC5")
	SC5->(DBSetOrder(1)) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_

	DBSelectArea("SC6")
	SC6->(DBSetOrder(1)) // C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_

	DBSelectArea("SF2")
	SF2->(DBSetOrder(1)) // F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO, R_E_C_N_O_, D_E_L_E_T_

	DBSelectArea("SD2")
	SD2->(DBSetOrder(3)) // D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, R_E_C_N_O_, D_E_L_E_T_

	If SC5->(DBSeek(xFilial("SC5") + SE1->E1_PEDIDO))

		If SA3->(DBSeek(xFilial("SA3") + SC5->C5_VEND1))

			If PZ9->(DBSeek(xFilial("PZ9") + SA3->A3_COD + SC5->C5_YEMP))

				While !PZ9->(EOF()) .And. PZ9->(PZ9_FILIAL + PZ9_VENDPA + PZ9_MARCA) == xFilial("PZ9") + SA3->A3_COD + SC5->C5_YEMP

					If Empty(SC5->C5_YVENPA)

						RecLock("SC5", .F.)
						SC5->C5_YVENPA := SC5->C5_VEND1
						SC5->(MSUnLock())

					EndIf

					PZ9->(DbSkip())

				EndDo

			EndIf

		EndIf

		If SA3->(DBSeek(xFilial("SA3") + SC5->C5_YVENPA))

			If PZ9->(DBSeek(xFilial("PZ9") + SA3->A3_COD + SC5->C5_YEMP))

				While !PZ9->(EOF()) .And. PZ9->(PZ9_FILIAL + PZ9_VENDPA + PZ9_MARCA) == xFilial("PZ9") + SA3->A3_COD + SC5->C5_YEMP

					If SA3->A3_COMIS > 0 .And. SE1->E1_COMIS1 > 0

						If (cQry)->E3_EMISSAO >= PZ9->PZ9_PERINI .And. (cQry)->E3_EMISSAO <= PZ9->PZ9_PERFIM

							aAdd(aVendRat, {PZ9->PZ9_VEND, PZ9->PZ9_PERCEN, SA3->A3_COMIS, 0})

						EndIf

					EndIf

					PZ9->(DbSkip())

				EndDo

			EndIf

		EndIf

	EndIf

	RestArea(aAreaPZ9)
	RestArea(aAreaSA3)
	RestArea(aAreaSE1)
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aAreaSF2)
	RestArea(aAreaSD2)

Return(aVendRat)

Method Calc(aVendRat) Class TRateioComissao

	Local nW       := 0
	Local nRest    := 0
	Local nComiss  := 0
	Local nTotal   := 0

	Default aVendRat := {}

	aSort( aVendRat,,, { |x,y| x[2] < y[2] } )

	For nW := 1 To Len(aVendRat)

		nComiss := Round(((aVendRat[nW][5] * aVendRat[nW][2]) / 100), 2)

		If nRest == 0

			nRest := aVendRat[nW][5]

			nRest -= nComiss

			nTotal += nComiss

		Else

			If nW == Len(aVendRat)

				nComiss := nRest

			ElseIf nW == Len(aVendRat) - 1

				nComiss := nComiss - ( ( ( Round(((aVendRat[nW][5] * aVendRat[nW][2]) / 100), 2) + Round(((aVendRat[nW+1][5] * aVendRat[nW+1][2]) / 100), 2) ) - (aVendRat[nW][5] - nTotal) ) / 2 )

				nComiss := Round(nComiss, 2)

				nRest -= nComiss

			Else

				nTotal += nComiss

				nRest -= nComiss

			EndIf

		EndIf

		aVendRat[nW][4] := Round(nComiss, 2)

	Next nW

Return(aVendRat)

Method Mod1(aVendRat) Class TRateioComissao

	Local nW := 0

	Default aVendRat := {}

	For nW := 1 To Len(aVendRat)

		RecLock("SE1", .F.)
		SE1->(&("E1_VEND"  + ::GetSeq(nW))) := aVendRat[nW][1]
		SE1->(&("E1_COMIS" + ::GetSeq(nW))) := aVendRat[nW][4]
		SE1->(MSUnLock())

		If SF2->(DBSeek(xFilial("SF2") + SE1->(E1_NUM + E1_PREFIXO + E1_CLIENTE + E1_LOJA)))

			RecLock("SF2", .F.)
			SF2->(&("F2_VEND"  + ::GetSeq(nW))) := aVendRat[nW][1]
			SF2->(MSUnLock())

		EndIf

		If SD2->(DBSeek(xFilial("SD2") + SE1->(E1_NUM + E1_PREFIXO + E1_CLIENTE + E1_LOJA)))

			While !SD2->(EOF()) .And. SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == xFilial("SD2") + SE1->(E1_NUM + E1_PREFIXO + E1_CLIENTE + E1_LOJA)

				RecLock("SD2", .F.)
				SD2->(&("D2_COMIS" + ::GetSeq(nW))) := aVendRat[nW][4]
				SD2->(MSUnLock())

				SD2->(DbSkip())

			EndDo

		EndIf

		If SC5->(DBSeek(xFilial("SC5") + SE1->E1_PEDIDO))

			RecLock("SC5", .F.)
			SC5->(&("C5_VEND"  + ::GetSeq(nW))) := aVendRat[nW][1]
			SC5->(&("C5_COMIS" + ::GetSeq(nW))) := aVendRat[nW][4]
			SC5->(MSUnLock())

		EndIf

		If SC6->(DBSeek(xFilial("SC6") + SE1->E1_PEDIDO))

			While !SC6->(EOF()) .And. SC6->(C6_FILIAL + C6_NUM) == xFilial("SC6") + SE1->E1_PEDIDO

				RecLock("SC6", .F.)
				SC6->(&("C6_COMIS" + ::GetSeq(nW))) := aVendRat[nW][4]
				SC6->(MSUnLock())

				SC6->(DbSkip())

			EndDo

		EndIf

	Next nW

Return()

Method Mod2(aVendRat, aBase) Class TRateioComissao

	Local nW := 0

	Default aVendRat := {}
	Default aBase := {} // 01 - Cod. Vendedor
	// 02 - BaseSE1         5000
	// 03 - BaseEmis
	// 04 - BaseBaix        5000
	// 05 - VlrEmis
	// 06 - VlrBaix         50
	// 07 - PerComis        1
	// 08 - Pis
	// 09 - Csll
	// 10 - Cofins
	// 11 - Irrf

	For nW := 1 To Len(aVendRat) - 1

		aAdd(aBase, aClone(aBase[nW]))

	Next nW

	For nW := 1 To Len(aBase)

		aBase[nW][1] := aVendRat[nW][1]

		aBase[nW][7] := aVendRat[nW][4]

		aBase[nW][6] := Round( ( aBase[nW][4] * aVendRat[nW][4] ) / 100, 2 )

	Next nW

Return(aBase)

Method Mod3() Class TRateioComissao

	Local aSays     := {}
	Local aButtons  := {}
	Local lConfirm  := .F.

	If ::Pergunte()

		AADD(aSays, OemToAnsi("Este programa tem como objetivo ratear as comissões"))
		AADD(aSays, OemToAnsi("dos vendedores conforme cadastro Rateio de comissão."))

		AADD(aButtons, { 5,.T.,{|| ::Pergunte() } } )
		AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
		AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

		FormBatch( OemToAnsi("Rateio de comissões"), aSays, aButtons ,,,500)

		If lConfirm

			Processa({ || ::Processa() },"Aguarde...", "Processando rateio das comissões...", .F.)

		EndIf

	EndIf

Return()

Method GetSeq(nSeq) Class TRateioComissao

	Local cRet := ""
	Local aOrdem := {}

	aAdd(aOrdem, "1")
	aAdd(aOrdem, "2")
	aAdd(aOrdem, "3")
	aAdd(aOrdem, "4")
	aAdd(aOrdem, "5")
	aAdd(aOrdem, "6")
	aAdd(aOrdem, "7")
	aAdd(aOrdem, "8")
	aAdd(aOrdem, "9")
	aAdd(aOrdem, "A") // Ticket TOTVS: 8959662
	aAdd(aOrdem, "B")
	aAdd(aOrdem, "C")
	aAdd(aOrdem, "D")
	aAdd(aOrdem, "E")
	aAdd(aOrdem, "F")
	aAdd(aOrdem, "G")
	aAdd(aOrdem, "H")
	aAdd(aOrdem, "I")
	aAdd(aOrdem, "J")
	aAdd(aOrdem, "K")
	aAdd(aOrdem, "L")
	aAdd(aOrdem, "M")
	aAdd(aOrdem, "N")
	aAdd(aOrdem, "O")
	aAdd(aOrdem, "P")
	aAdd(aOrdem, "Q")
	aAdd(aOrdem, "R")
	aAdd(aOrdem, "S")
	aAdd(aOrdem, "T")
	aAdd(aOrdem, "U") // 29
	aAdd(aOrdem, "V")
	aAdd(aOrdem, "W")
	aAdd(aOrdem, "X")
	aAdd(aOrdem, "Y")
	aAdd(aOrdem, "Z") // 34

	cRet := aOrdem[nSeq]

Return(cRet)

Method Pergunte() Class TRateioComissao

	Local lRet := .F.
	Local nTam := 1
	Local cName := "TRateioComissao"
	Local bConfirm := {|| .T. }
	Local aParam := {}
	Local aParRet := {}

	aAdd(aParam, {1, "Mes/Ano", ::cMesAno, "@R !!/!!!!", ".T.", "", ".T.",,.T.})

	If ParamBox(aParam, "Operações", aParRet, bConfirm,,,,,,cName, .T., .T.)

		lRet := .T.

		::cMesAno := aParRet[nTam++]

		::dDtIni := CTOD("01/" + SubStr(::cMesAno, 1, 2) + "/" + SubStr(::cMesAno, 3, 4))

		::dDtFim := LastDay(::dDtIni)

	EndIf

Return(lRet)

Method Processa() Class TRateioComissao

	Local aAreaPZ9 := PZ9->(GetArea())
	Local aAreaSA3 := SA3->(GetArea())
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSE1 := SE1->(GetArea())

	Local cSQL      := ""
	Local cQry      := ""
	Local cQryFat	:= ""
	Local nW        := 0
	Local nX        := 0
	Local lAchou    := .F.
	Local aVendRat  := {}

	If StaticCall(FCOMTE02, ValidPercent)

		Alert("O Rateio não foi processado!")

	Else

		//If ::dDtIni > GetMV("MV_DATAFIN") .And. ::dDtFim > GetMV("MV_DATAFIN") // Teoricamente não teria nescessidade de verificar esse parametro por se tratar de comissão. Deixarei por padrão.

			DBSelectArea("PZ9")
			PZ9->(DBSetOrder(1)) // PZ9_FILIAL, PZ9_VENDPA, PZ9_MARCA, PZ9_VEND, R_E_C_N_O_, D_E_L_E_T_

			DBSelectArea("SE1")
			SE1->(DBSetOrder(1)) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_

			DBSelectArea("SA3")
			SA3->(DBSetOrder(1)) // A3_FILIAL, A3_COD, R_E_C_N_O_, D_E_L_E_T_

			DBSelectArea("SC5")
			SC5->(DBSetOrder(1)) // C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_

			cQry := GetNextAlias()

			cSQL := " SELECT * "
			cSQL += " FROM " + RetSQLName("SE3") + " SE3 "
			cSQL += " LEFT JOIN " + RetSQLName("SC5") + " SC5 ON "
			cSQL += " ( "
			cSQL += "	C5_FILIAL  		= E3_FILIAL AND"
			cSQL += "	C5_NUM	 		= E3_PEDIDO AND"
			cSQL += " 	SC5.D_E_L_E_T_ 	= '' "
			cSQL += " ) "
			cSQL += " WHERE E3_FILIAL = " + ValToSQL(xFilial("SE3"))
			cSQL += " AND E3_EMISSAO BETWEEN " + ValToSQL(DTOS(::dDtIni)) + " AND " + ValToSQL(DTOS(::dDtFim)) + " "
			cSQL += " AND EXISTS "
			cSQL += " ( "
			cSQL += "	SELECT NULL "
			cSQL += "	FROM " + RetSQLName("PZ9") + " PZ9 "
			cSQL += "	WHERE PZ9_FILIAL = " + ValToSQL(xFilial("PZ9"))
			cSQL += "	AND E3_VEND = PZ9_VENDPA "
			cSQL += "	AND E3_EMISSAO BETWEEN PZ9_PERINI AND PZ9_PERFIM "
			// cSQL += "	AND EXISTS "
			// cSQL += "	( "
			// cSQL += "	    SELECT NULL "
			// cSQL += "	    FROM " + RetSQLName("SC5") + " SC5 "
			// cSQL += "	    WHERE C5_FILIAL = " + ValToSQL(xFilial("SC5"))
			// cSQL += "	    AND C5_NUM = E3_PEDIDO "
			// cSQL += "	    AND C5_YEMP = PZ9_MARCA "
			// cSQL += "	    AND SC5.D_E_L_E_T_ = '' "
			// cSQL += "	) "
			cSQL += "     AND PZ9.D_E_L_E_T_ = '' "
			cSQL += " ) "
			cSQL += " AND SE3.D_E_L_E_T_ = '' "
			// cSQL += " AND E3_NUM = '000201799' "

			TcQuery cSQL New Alias (cQry)

			Begin Transaction

				While !(cQry)->(Eof())

					aVendRat := {}

					If AllTrim((cQry)->E3_TIPO) == "FT"

						If .T. // Verificar se existe algum titulo da fatura do vendedor padrao que não encontrou amarracao.

							If SE1->(DBSeek(xFilial("SE1") + (cQry)->E3_PREFIXO + (cQry)->E3_NUM + (cQry)->E3_PARCELA + (cQry)->E3_TIPO))

								If Empty(SE1->E1_NUMLIQ) // Fatura modo antigo.

									cQryFat := GetNextAlias()

									cSQL := " SELECT DISTINCT E1_FILIAL, C5_YEMP "
									cSQL += " FROM " + RetSQLName("SE5") + " SE5 "
									cSQL += " INNER JOIN " + RetSQLName("SE1") + " SE1 ON "
									cSQL += " ( "
									cSQL += "	E5_FILIAL  		= E1_FILIAL AND"
									cSQL += "	E5_PREFIXO 		= E1_PREFIXO AND"
									cSQL += "	E5_NUMERO  		= E1_NUM AND"
									cSQL += "	E5_PARCELA 		= E1_PARCELA AND"
									cSQL += "	E5_TIPO    		= E1_TIPO AND"
									cSQL += "	E5_CLIFOR  		= E1_CLIENTE AND"
									cSQL += "	E5_LOJA    		= E1_LOJA AND"
									cSQL += "	E5_RECPAG  		= 'R' AND"
									cSQL += "	E5_SITUACA 		<>'C' AND"
									cSQL += "	E5_TIPODOC 		= 'BA' AND"
									cSQL += "	E1_FATURA 		= " + ValToSql(SE1->E1_NUM) + " AND"
									// cSQL += "	E5_MOTBX 		= 'LIQ' AND"
									cSQL += " 	SE1.D_E_L_E_T_ 	= '' "
									cSQL += " ) "
									cSQL += " INNER JOIN " + RetSQLName("SC5") + " SC5 ON "
									cSQL += " ( "
									cSQL += "	C5_FILIAL  		= E1_FILIAL AND"
									cSQL += "	C5_NUM	 		= E1_PEDIDO AND"
									cSQL += " 	SC5.D_E_L_E_T_ 	= '' "
									cSQL += " ) "
									cSQL += " WHERE E5_FILIAL = " + ValToSQL(xFilial("SE5"))
									cSQL += " AND SE5.D_E_L_E_T_ = '' "

								Else // Fatura feita pela liquidacao.

									cQryFat := GetNextAlias()

									cSQL := " SELECT DISTINCT E1_FILIAL, C5_YEMP "
									cSQL += " FROM " + RetSQLName("SE5") + " SE5 "
									cSQL += " INNER JOIN " + RetSQLName("SE1") + " SE1 ON "
									cSQL += " ( "
									cSQL += "	E5_FILIAL  		= E1_FILIAL AND"
									cSQL += "	E5_PREFIXO 		= E1_PREFIXO AND"
									cSQL += "	E5_NUMERO  		= E1_NUM AND"
									cSQL += "	E5_PARCELA 		= E1_PARCELA AND"
									cSQL += "	E5_TIPO    		= E1_TIPO AND"
									cSQL += "	E5_CLIFOR  		= E1_CLIENTE AND"
									cSQL += "	E5_LOJA    		= E1_LOJA AND"
									cSQL += "	E5_RECPAG  		= 'R' AND"
									cSQL += "	E5_SITUACA 		<>'C' AND"
									cSQL += "	E5_TIPODOC 		= 'BA' AND"
									cSQL += "	E5_DOCUMEN 		= '" + PADR(SE1->E1_NUMLIQ, F460TamLiq()) + "' AND"
									cSQL += "	E5_MOTBX 		= 'LIQ' AND"
									cSQL += " 	SE1.D_E_L_E_T_ 	= '' "
									cSQL += " ) "
									cSQL += " INNER JOIN " + RetSQLName("SC5") + " SC5 ON "
									cSQL += " ( "
									cSQL += "	C5_FILIAL  		= E1_FILIAL AND"
									cSQL += "	C5_NUM	 		= E1_PEDIDO AND"
									cSQL += " 	SC5.D_E_L_E_T_ 	= '' "
									cSQL += " ) "
									cSQL += " WHERE E5_FILIAL = " + ValToSQL(xFilial("SE5"))
									cSQL += " AND SE5.D_E_L_E_T_ = '' "

								EndIf

								TcQuery cSQL New Alias (cQryFat)

								While !(cQryFat)->(Eof())

									aRatFat := ::GetRateio((cQry)->E3_VEND, (cQryFat)->C5_YEMP, (cQry)->E3_EMISSAO, (cQry)->E3_COMIS, (cQry)->E3_PORC)

									For nW := 1 To Len(aRatFat)

										aAdd(aVendRat, aRatFat[nW])

									Next nW

									(cQryFat)->(DbSkip())

								EndDo

								(cQryFat)->(DbCloseArea())

							EndIf

						EndIf

					Else

						aVendRat := ::GetRateio((cQry)->E3_VEND, (cQry)->C5_YEMP, (cQry)->E3_EMISSAO, (cQry)->E3_COMIS, (cQry)->E3_PORC)

					EndIf

					aVendRat := ::Calc(aVendRat)

					If Len(aVendRat) > 0

						lAchou := .T.

						SE3->(DBGoTo((cQry)->R_E_C_N_O_))

						aSE3 := {}

						For nW := 1 To SE3->(FCount())

							aAdd(aSE3, { AllTrim(SE3->(FieldName(nW))), SE3->(FieldGet(FieldPos(SE3->(FieldName(nW))))) })

						Next nW

						RecLock("SE3", .F.)
						SE3->E3_YFILRAT := SE3->E3_FILIAL
						SE3->E3_FILIAL := "XX"
						SE3->(MSUnLock())

					EndIf

					For nX := 1 To Len(aVendRat)

						RecLock("SE3", .T.)

						For nW := 1 To Len(aSE3)

							If aSE3[nW][1] == "E3_VEND"

								SE3->(&(aSE3[nW][1])) := aVendRat[nX][1]

							ElseIf aSE3[nW][1] == "E3_BASE"

								SE3->(&(aSE3[nW][1])) := aVendRat[nX][5]

							ElseIf aSE3[nW][1] == "E3_PORC"

								SE3->(&(aSE3[nW][1])) := Round((( aVendRat[nX][3] ) * aVendRat[nX][2]) / 100, 2 )

							ElseIf aSE3[nW][1] == "E3_COMIS"

								SE3->(&(aSE3[nW][1])) := aVendRat[nX][4]

							ElseIf aSE3[nW][1] == "E3_YVENRAT"

								SE3->(&(aSE3[nW][1])) := aVendRat[nX][6]

							Else

								SE3->(&(aSE3[nW][1])) := aSE3[nW][2]

							EndIf

						Next nW

						SE3->(MSUnLock())

					Next nX

					(cQry)->(DbSkip())

				EndDo

			End Transaction

			(cQry)->(DbCloseArea())

			If lAchou

				MsgInfo("Processado com Sucesso!")

			Else

				Alert("Não foram encontradas comissões para o mês escolhido!")

			EndIf

		//Else

			//Alert("Parametro MV_DATAFIN [" + DTOC(GetMV("MV_DATAFIN")) + "] já está fechado para o mês escolhido!" + CRLF + "O Rateio não foi processado!")

		//EndIf

	EndIf

	RestArea(aAreaPZ9)
	RestArea(aAreaSA3)
	RestArea(aAreaSC5)
	RestArea(aAreaSE1)

Return()

Method GetRateio(cVendedor, cMarca, cEmissao, nComissao, nPorc) Class TRateioComissao

	Local aVendRat := {}

	Default cVendedor	:= ""
	Default cMarca		:= ""
	Default cEmissao 	:= ""
	Default nComissao	:= 0
	Default nPorc	 	:= 0

	If PZ9->(DBSeek(xFilial("PZ9") + cVendedor + cMarca))

		While !PZ9->(EOF()) .And. PZ9->(PZ9_FILIAL + PZ9_VENDPA + PZ9_MARCA) == xFilial("PZ9") + cVendedor + cMarca

			If nPorc > 0 // Utilizo o campo E3_PORC porque existe outro processo que incrementa percentual de comissao (tabela PZ8).

				If STOD(cEmissao) >= PZ9->PZ9_PERINI .And. STOD(cEmissao) <= PZ9->PZ9_PERFIM

					aAdd(aVendRat, {PZ9->PZ9_VEND, PZ9->PZ9_PERCEN, nPorc, 0, nComissao, PZ9->PZ9_VENDPA })

				EndIf

			EndIf

			PZ9->(DbSkip())

		EndDo

	EndIf

Return(aVendRat)

Method Mod3Estorno() Class TRateioComissao

	Local lRet := .T.
	Local cSQL := ""
	Local cQry := GetNextAlias()
	Local aAreaSE3 := SE3->(GetArea())

	cSQL := " SELECT * "
	cSQL += " FROM " + RetSQLName("SE3") + " SE3 "
	cSQL += " WHERE EXISTS "
	cSQL += " ( "
	cSQL += "     SELECT NULL "
	cSQL += "     FROM " + RetSQLName("SE3") + " A "
	cSQL += "     WHERE A.E3_YFILRAT = " + ValToSQL(xFilial("SE3"))
	cSQL += "     AND A.E3_EMISSAO = SE3.E3_EMISSAO "
	cSQL += "     AND A.E3_NUM = SE3.E3_NUM"
	cSQL += "     AND A.E3_PREFIXO = SE3.E3_PREFIXO"
	cSQL += "     AND A.E3_TIPO = SE3.E3_TIPO"
	cSQL += "     AND A.E3_PARCELA = SE3.E3_PARCELA"
	cSQL += "     AND A.E3_CODCLI = SE3.E3_CODCLI"
	cSQL += "     AND A.E3_LOJA = SE3.E3_LOJA"
	cSQL += "     AND A.E3_SEQ = SE3.E3_SEQ" // Estornos parciais

	cSQL += "     AND A.E3_NUM = " + ValToSQL(SE1->E1_NUM)
	cSQL += "     AND A.E3_PREFIXO = " + ValToSQL(SE1->E1_PREFIXO)
	cSQL += "     AND A.E3_TIPO = " + ValToSQL(SE1->E1_TIPO)
	cSQL += "     AND A.E3_PARCELA = " + ValToSQL(SE1->E1_PARCELA)
	cSQL += "     AND A.E3_CODCLI = " + ValToSQL(SE1->E1_CLIENTE)
	cSQL += "     AND A.E3_LOJA = " + ValToSQL(SE1->E1_LOJA)
	cSQL += "     AND A.E3_SEQ = " + ValToSQL(SE5->E5_SEQ)
	cSQL += "     AND A.D_E_L_E_T_ = '' "
	cSQL += " ) "
	cSQL += " AND SE3.D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	DBSelectArea("SE3")

	While !(cQry)->(Eof())

		SE3->(DBGoTo((cQry)->R_E_C_N_O_))

		If SE3->E3_FILIAL == "XX" // Volto o registro original para que a rotina padrão faça a exclusão.

			RecLock("SE3", .F.)
			SE3->E3_FILIAL := SE3->E3_YFILRAT
			SE3->E3_YFILRAT := ""
			SE3->(MSUnLock())

		Else

			RecLock("SE3", .F.)
			SE3->(DBDelete())
			SE3->(MSUnLock())

		EndIf

		(cQry)->(DbSkip())

	EndDo

	(cQry)->(DbCloseArea())

	RestArea(aAreaSE3)

Return(lRet)

User Function RATCOMIS()

	Local oObj := Nil

	Private cTitulo := "Rateio de comissões"

	//RpcSetEnv("07", "01")

	oObj := TRateioComissao():New("3")

	oObj:Rateio()

	//RpcClearEnv()

Return()
