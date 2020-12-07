#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA129
@author Marcos Alberto Soprani
@since 06/12/16
@version 1.0
@description Contabilização extraordinária para desdobramento do custo de produção em CPV
@obs OS: 4504-16 - Jecimar Ferreira
@type function
/*/

User Function BIA129()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local xrEnter   := CHR(13) + CHR(10)
	Local hr
	Private dtRefEmi := dDataBase
	Private fgVetCtb

	cHInicio := Time()
	fPerg := "BIA129"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA788 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase <> GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.","BIA788 - Data de Fechamento!!!")
		Return
	EndIf

	fgLanPad := "D01"
	fgLotCtb := "009007"
	fgVetCtb := {}
	fgVetEXC := {}
	fgPermDg := .T.
	fg_clvl  := IIF(cEmpAnt == "01", "3100", IIF(cEmpAnt == "05", "3200", ""))

	kjDtINI := MV_PAR01
	kjDtFIM := MV_PAR02

	msKernelCt := U_BIA185( kjDtINI, kjDtFIM )
	msNomeTMP  := "##TMPBIA129" + cEmpAnt + cFilAnt + __cUserID + strzero(seconds() * 3500,10)
	msMontaSql := msKernelCt + "SELECT * INTO " + msNomeTMP + " FROM TABFINAL "
	U_BIAMsgRun("Aguarde... Gerando Base...",,{|| TcSQLExec(msMontaSql)})

	TY004 := Alltrim("  SELECT CRIT,                                           ") + xrEnter
	TY004 += Alltrim("         CTA DEBITO,                                     ") + xrEnter
	TY004 += Alltrim("         CTA CREDIT,                                     ") + xrEnter
	TY004 += Alltrim("         '6104' CVLVLDEB,                                ") + xrEnter
	TY004 += Alltrim("         CLVL CVLVLCRE,                                  ") + xrEnter
	TY004 += Alltrim("         '' ITEMCTA,                                     ") + xrEnter
	TY004 += Alltrim("         SUM(VALOR) CUSTO,                               ") + xrEnter
	TY004 += Alltrim("         'LCTO PARADA DE LINHA N/MES' HIST,              ") + xrEnter
	TY004 += Alltrim("         '3000' CCUSTO,                                  ") + xrEnter
	TY004 += Alltrim("         '3000' CCUSTO,                                  ") + xrEnter
	TY004 += Alltrim("         'CT2' ORIGEM                                    ") + xrEnter
	TY004 += Alltrim("   FROM " + msNomeTMP + " TMP                            ") + xrEnter
	TY004 += Alltrim("   GROUP BY CRIT, CTA, CLVL                              ") + xrEnter
	TY004 += Alltrim("   ORDER BY CRIT, CTA, CLVL                              ") + xrEnter
	TYcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,TY004),'TY04',.T.,.T.)
	dbSelectArea("TY04")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		cwCusto := TY04->CUSTO
		If dtos(MV_PAR01) == "20161101" .and. 1 == 2

			If TY04->CRIT == "L01"
				cwCusto := cwCusto * 0.433451979 
			ElseIf TY04->CRIT == "TOT"
				cwCusto := cwCusto * 0.228774308
			EndIf

			// Vetor ==>>          Debito,      Credito,     ClVl_D,     ClVl_C, Item_Contab_D, Item_Contab_C,       Valor,  Histórico,     CCUSTO_D,     CCUSTO_C,       ORIGEM
			If cwCusto > 0
				Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, TY04->CVLVLDEB, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
			ElseIf cwCusto < 0
				Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, TY04->CVLVLDEB, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
			EndIf

		ElseIf dtos(MV_PAR01) == "20161201" 

			If TY04->CRIT == "L01" .and. !Substr(TY04->CTA,1,3) $ "615/617" 
				cwCusto := cwCusto * 0.055900877
				cwClvlD := "6104"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				EndIf

			ElseIf TY04->CRIT $ "L03/E03/E04" .and. !Substr(TY04->CTA,1,3) $ "615/617" 
				cwCusto := cwCusto * 0.290322581 
				cwClvlD := "6105"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				EndIf

			ElseIf TY04->CRIT == "TOT" .or. Substr(TY04->CTA,1,3) $ "615/617"
				// ----------------- Eq. Parada ** Esp. Linha
				cwBkpCt := cwCusto
				cwCusto := cwCusto * 0.165167694 * 0.180693908
				cwClvlD := "6104"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				EndIf
				// ----------------- Eq. Parada ** Esp. Linha
				cwCusto := cwBkpCt
				cwCusto := cwCusto * 0.165167694 * 0.819306092
				cwClvlD := "6105"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				EndIf

			EndIf

		ElseIf dtos(MV_PAR01) == "20170101" 

			If Alltrim(TY04->CVLVLCRE) $ "3136/3196/3137" .and. !( Substr(TY04->DEBITO,1,3) $ "611" .or. Substr(TY04->CREDIT,1,3) $ "611" ) .and. 1 = 2

				cwCusto := cwCusto *  0.11187336
				cwClvlD := IIF(Alltrim(TY04->CVLVLCRE) == "3136", "3135", IIF(Alltrim(TY04->CVLVLCRE) == "3196", "3195", IIF(Alltrim(TY04->CVLVLCRE) == "3137", "3139","")))
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				EndIf

			EndIf

			If cEmpAnt == "01"

				If TY04->CRIT == "L03" .and. ( Substr(TY04->DEBITO,1,3) $ "612" .or. Substr(TY04->CREDIT,1,3) $ "612" ) 
					cwCusto := cwCusto * 0.51612903
					cwClvlD := "6105"
					If cwCusto > 0
						Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					ElseIf cwCusto < 0
						Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					EndIf

				ElseIf ( TY04->CRIT == "TOT" .and. ( Substr(TY04->DEBITO,1,3) $ "612" .or. Substr(TY04->CREDIT,1,3) $ "612" ) ) .or. ( (Substr(TY04->DEBITO,1,3) $ "615/617" .or. Substr(TY04->CREDIT,1,3) $ "615/617") .and. TY04->CRIT <> "COG" )  
					cwCusto := cwCusto * 0.25631630
					cwClvlD := "6105"
					If cwCusto > 0
						Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					ElseIf cwCusto < 0
						Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					EndIf

				ElseIf TY04->CRIT == "E03" .and. ( Substr(TY04->DEBITO,1,3) $ "612" .or. Substr(TY04->CREDIT,1,3) $ "612" ) 
					cwCusto := cwCusto * 0.38709677
					cwClvlD := "6105"
					If cwCusto > 0
						Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					ElseIf cwCusto < 0
						Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					EndIf

				ElseIf TY04->CRIT == "E04" .and. ( Substr(TY04->DEBITO,1,3) $ "612" .or. Substr(TY04->CREDIT,1,3) $ "612" ) 
					cwCusto := cwCusto * 0.12903226
					cwClvlD := "6105"
					If cwCusto > 0
						Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					ElseIf cwCusto < 0
						Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					EndIf

				EndIf

			ElseIf cEmpAnt == "05"

				If ( TY04->CRIT == "TOT" .and. ( Substr(TY04->DEBITO,1,3) $ "612" .or. Substr(TY04->CREDIT,1,3) $ "612" ) ) .or. ( (Substr(TY04->DEBITO,1,3) $ "615/617" .or. Substr(TY04->CREDIT,1,3) $ "615/617") .and. TY04->CRIT <> "COG" ) 
					cwCusto := cwCusto * 0.19969869
					cwClvlD := "6204"
					If cwCusto > 0
						Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					ElseIf cwCusto < 0
						Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					EndIf	

				EndIf

			EndIf

		ElseIf dtos(MV_PAR01) == "20170201" 

			If cEmpAnt == "01"

				If Alltrim(TY04->CVLVLCRE) $ "3136/3196/3137" .and. !( Substr(TY04->DEBITO,1,3) $ "611/615/617" .or. Substr(TY04->CREDIT,1,3) $ "611/615/617" )

					cwCusto := cwCusto * 0.27504643
					cwClvlD := IIF(Alltrim(TY04->CVLVLCRE) == "3136", "3135", IIF(Alltrim(TY04->CVLVLCRE) == "3196", "3195", IIF(Alltrim(TY04->CVLVLCRE) == "3137", "3139","")))
					If cwCusto > 0
						Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					ElseIf cwCusto < 0
						Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					EndIf

				EndIf

			EndIf

			If cEmpAnt == "05"

				If ( TY04->CRIT == "TOT" .and. ( Substr(TY04->DEBITO,1,3) $ "612" .or. Substr(TY04->CREDIT,1,3) $ "612" ) ) .or. ( (Substr(TY04->DEBITO,1,3) $ "615/617" .or. Substr(TY04->CREDIT,1,3) $ "615/617") .and. TY04->CRIT <> "COG" ) 
					cwCusto := cwCusto * 0.22919186
					cwClvlD := "6204"
					If cwCusto > 0
						Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					ElseIf cwCusto < 0
						Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					EndIf	

				EndIf

			EndIf

		ElseIf dtos(MV_PAR01) == "20170301" 

			If cEmpAnt == "01"

				If Alltrim(TY04->CVLVLCRE) $ "3136/3196/3137" .and. !( Substr(TY04->DEBITO,1,3) $ "611/615/617" .or. Substr(TY04->CREDIT,1,3) $ "611/615/617" )

					cwHistr := "LCTO TRANSF.CUSTO LINHA 3 P LINHA 4"
					cwCusto := cwCusto *  0.18482966
					cwClvlD := IIF(Alltrim(TY04->CVLVLCRE) == "3136", "3135", IIF(Alltrim(TY04->CVLVLCRE) == "3196", "3195", IIF(Alltrim(TY04->CVLVLCRE) == "3137", "3139","")))
					If cwCusto > 0
						Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), cwHistr, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					ElseIf cwCusto < 0
						Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), cwHistr, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					EndIf

				EndIf

			EndIf

		ElseIf dtos(MV_PAR01) == "20170401" 

			If cEmpAnt == "01"

				If Alltrim(TY04->CVLVLCRE) $ "3136/3196/3137" .and. !( Substr(TY04->DEBITO,1,3) $ "611/615/617" .or. Substr(TY04->CREDIT,1,3) $ "611/615/617" )

					cwHistr := "LCTO TRANSF.CUSTO LINHA 3 P LINHA 4"
					cwCusto := cwCusto * 0.87594799
					cwClvlD := IIF(Alltrim(TY04->CVLVLCRE) == "3136", "3135", IIF(Alltrim(TY04->CVLVLCRE) == "3196", "3195", IIF(Alltrim(TY04->CVLVLCRE) == "3137", "3139","")))
					If cwCusto > 0
						Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), cwHistr, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					ElseIf cwCusto < 0
						Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), cwHistr, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					EndIf

				EndIf

			EndIf

		ElseIf dtos(MV_PAR01) == "20170501" 

			If cEmpAnt == "01"

				If Alltrim(TY04->CVLVLCRE) $ "3136/3196/3137/3140" .and. !( Substr(TY04->DEBITO,1,3) $ "611/615/617" .or. Substr(TY04->CREDIT,1,3) $ "611/615/617" )

					cwHistr := "LCTO TRANSF.CUSTO LINHA 3 P LINHA 4"
					cwCusto := cwCusto * 0.06546360
					cwClvlD := IIF(Alltrim(TY04->CVLVLCRE) $ "3136/3140", "3135", IIF(Alltrim(TY04->CVLVLCRE) == "3196", "3195", IIF(Alltrim(TY04->CVLVLCRE) == "3137", "3139","")))
					If cwCusto > 0
						Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), cwHistr, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					ElseIf cwCusto < 0
						Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), cwHistr, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					EndIf

				EndIf


			EndIf

		ElseIf dtos(MV_PAR01) == "20170601" 

			If cEmpAnt == "01"

				If Alltrim(TY04->CVLVLCRE) $ "3136/3196/3137/3140" .and. !( Substr(TY04->DEBITO,1,3) $ "611/615/617" .or. Substr(TY04->CREDIT,1,3) $ "611/615/617" )

					cwHistr := "LCTO TRANSF.CUSTO LINHA 3 P LINHA 4"
					cwCusto := cwCusto * 0.03241048
					cwClvlD := IIF(Alltrim(TY04->CVLVLCRE) $ "3136/3140", "3135", IIF(Alltrim(TY04->CVLVLCRE) == "3196", "3195", IIF(Alltrim(TY04->CVLVLCRE) == "3137", "3139","")))
					If cwCusto > 0
						Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), cwHistr, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					ElseIf cwCusto < 0
						Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), cwHistr, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					EndIf

				EndIf


			EndIf

		ElseIf dtos(MV_PAR01) == "20171201" 

			If cEmpAnt == "01"

				If Alltrim(TY04->CVLVLCRE) $ "3136/3196/3137/3140" .and. !( Substr(TY04->DEBITO,1,3) $ "611/615/617" .or. Substr(TY04->CREDIT,1,3) $ "611/615/617" )

					cwHistr := "LCTO TRANSF.CUSTO LINHA 4 P LINHA 3"
					cwCusto := cwCusto * 1
					cwClvlD := IIF(Alltrim(TY04->CVLVLCRE) $ "3136/3140", "3135", IIF(Alltrim(TY04->CVLVLCRE) == "3196", "3195", IIF(Alltrim(TY04->CVLVLCRE) == "3137", "3139","")))
					If cwCusto > 0
						Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), cwHistr, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					ElseIf cwCusto < 0
						Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), cwHistr, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
					EndIf

				EndIf

			EndIf

		ElseIf dtos(MV_PAR01) == "20180801" 

			If cEmpAnt == "05"

				If ( TY04->CRIT == "TOT" .and. ( Substr(TY04->DEBITO,1,3) $ "612" .or. Substr(TY04->CREDIT,1,3) $ "612" ) ) .or. ( (Substr(TY04->DEBITO,1,3) $ "615/617" .or. Substr(TY04->CREDIT,1,3) $ "615/617") .and. TY04->CRIT <> "COG" )
					cwPerRat := 0.32258065 
					cwCusto  := cwCusto * 0.32258065
					cwClvlD  := "6205"
					If cwCusto > 0
						Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") + " PerRat: " + Alltrim(Str(cwPerRat)), "", "" })
					ElseIf cwCusto < 0
						Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") + " PerRat: " + Alltrim(Str(cwPerRat)), "", "" })
					EndIf	

				EndIf

			EndIf

		ElseIf dtos(MV_PAR01) == "20180901" 

			If cEmpAnt == "05"

				If ( TY04->CRIT == "TOT" .and. ( Substr(TY04->DEBITO,1,3) $ "612" .or. Substr(TY04->CREDIT,1,3) $ "612" ) ) .or. ( (Substr(TY04->DEBITO,1,3) $ "615/617" .or. Substr(TY04->CREDIT,1,3) $ "615/617") .and. TY04->CRIT <> "COG" )
					cwPerRat := 0.2833 
					cwCusto  := cwCusto * 0.2833
					cwClvlD  := "6205"
					If cwCusto > 0
						Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") + " PerRat: " + Alltrim(Str(cwPerRat)), "", "" })
					ElseIf cwCusto < 0
						Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") + " PerRat: " + Alltrim(Str(cwPerRat)), "", "" })
					EndIf	

				EndIf

			EndIf

		ElseIf dtos(MV_PAR01) == "20190701" 

			//If Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. ( Substr(TY04->DEBITO,1,3) $ "615/617" .or. Substr(TY04->CREDIT,1,3) $ "615/617" ) .and. TY04->CRIT <> "COG"

			//	cwCusto := cwCusto * 0.282933206
			//	cwClvlD := "6107"
			//	If cwCusto > 0
			//		Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
			//	ElseIf cwCusto < 0
			//		Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
			//	EndIf

			//EndIf

			/* Por Ausência de Produção puramente */
			/*------------------------------------*/

			// Retífica a Seco
			// C.Contábil: ALL
			// CLVL: 3117
			If Alltrim(TY04->CVLVLCRE) $ "3117"

				cwCusto := cwCusto * 1
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			/*      Por parada não programada     */
			/*------------------------------------*/

			// Gastos Gerias de Fabricação
			// C.Contábil: BAS(613,614,616)
			// CLVL: CRIT(L01), exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "613,614,616" .or. Substr(TY04->CREDIT,1,3) $ "613,614,616" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT == "L01" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.55
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// D`Pessoal
			// C.Contábil: BAS(612)
			// CLVL: CRIT(L01), exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "612" .or. Substr(TY04->CREDIT,1,3) $ "612" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT == "L01" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.53
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Depreciação
			// C.Contábil: BAS(615)
			// CLVL: TODAS fábrica 1, !CRIT(COG) e exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "615" .or. Substr(TY04->CREDIT,1,3) $ "615" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT <> "COG" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.29
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Aluguel
			// C.Contábil: BAS(617)
			// CLVL: TODAS fábrica 1, !CRIT(COG) e exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "617" .or. Substr(TY04->CREDIT,1,3) $ "617" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT <> "COG" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.29
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf


		ElseIf dtos(MV_PAR01) == "20190801" 

			/* Por Ausência de Produção puramente */
			/*------------------------------------*/

			// Retífica a Seco
			// C.Contábil: ALL
			// CLVL: 3117
			If Alltrim(TY04->CVLVLCRE) $ "3117"

				cwCusto := cwCusto * 1
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			/*      Por parada não programada     */
			/*------------------------------------*/

			// Gastos Gerias de Fabricação
			// C.Contábil: BAS(613,614,616)
			// CLVL: CRIT(L01), exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "613,614,616" .or. Substr(TY04->CREDIT,1,3) $ "613,614,616" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT == "L01" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.63560863
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// D`Pessoal
			// C.Contábil: BAS(612)
			// CLVL: CRIT(L01), exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "612" .or. Substr(TY04->CREDIT,1,3) $ "612" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT == "L01" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.61124482
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Depreciação
			// C.Contábil: BAS(615)
			// CLVL: TODAS fábrica 1, !CRIT(COG) e exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "615" .or. Substr(TY04->CREDIT,1,3) $ "615" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT <> "COG" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.33545892
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Aluguel
			// C.Contábil: BAS(617)
			// CLVL: TODAS fábrica 1, !CRIT(COG) e exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "617" .or. Substr(TY04->CREDIT,1,3) $ "617" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT <> "COG" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.33546018
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

		ElseIf dtos(MV_PAR01) == "20190901" 

			/* Por Ausência de Produção puramente */
			/*------------------------------------*/

			// Retífica a Seco
			// C.Contábil: ALL
			// CLVL: 3117
			If Alltrim(TY04->CVLVLCRE) $ "3117" .and. !( Substr(TY04->DEBITO,1,3) $ "611" .or. Substr(TY04->CREDIT,1,3) $ "611" )

				If !( Substr(TY04->DEBITO,1,3) $ "615" .or. Substr(TY04->CREDIT,1,3) $ "615" )
					cwCusto := cwCusto * 0.36666667
				Else
					cwCusto := cwCusto * 0.13260928
				EndIf
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			/*      Por parada não programada     */
			/*------------------------------------*/

			// Gastos Gerias de Fabricação
			// C.Contábil: BAS(613,614,616)
			// CLVL: CRIT(L01), exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "613,614,616" .or. Substr(TY04->CREDIT,1,3) $ "613,614,616" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT == "L01" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.22935100
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// D`Pessoal
			// C.Contábil: BAS(612)
			// CLVL: CRIT(L01), exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "612" .or. Substr(TY04->CREDIT,1,3) $ "612" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT == "L01" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.22935100
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Depreciação
			// C.Contábil: BAS(615)
			// CLVL: TODAS fábrica 1, !CRIT(COG) e exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "615" .or. Substr(TY04->CREDIT,1,3) $ "615" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT <> "COG" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.13260928
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Aluguel
			// C.Contábil: BAS(617)
			// CLVL: TODAS fábrica 1, !CRIT(COG) e exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "617" .or. Substr(TY04->CREDIT,1,3) $ "617" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT <> "COG" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.13260928
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

		ElseIf dtos(MV_PAR01) == "20200301" 

			// Retífica a Seco
			// C.Contábil: ALL
			// CLVL: 3117
			If Alltrim(TY04->CVLVLCRE) $ "3117" .and. !( Substr(TY04->DEBITO,1,3) $ "611" .or. Substr(TY04->CREDIT,1,3) $ "611" )

				If !( Substr(TY04->DEBITO,1,3) $ "615" .or. Substr(TY04->CREDIT,1,3) $ "615" )
					cwCusto := cwCusto * 0.03225806
				Else
					cwCusto := cwCusto * 0.00754976
				EndIf
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Gastos Gerias de Fabricação
			// C.Contábil: BAS(613,614,616)
			// CLVL: CRIT(L01), exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "613,614,616" .or. Substr(TY04->CREDIT,1,3) $ "613,614,616" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT == "L01" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.01073712
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// D`Pessoal
			// C.Contábil: BAS(612)
			// CLVL: CRIT(L01), exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "612" .or. Substr(TY04->CREDIT,1,3) $ "612" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT == "L01" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.01073712
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Depreciação
			// C.Contábil: BAS(615)
			// CLVL: TODAS fábrica 1, !CRIT(COG) e exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "615" .or. Substr(TY04->CREDIT,1,3) $ "615" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT <> "COG" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.00754976
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Aluguel
			// C.Contábil: BAS(617)
			// CLVL: TODAS fábrica 1, !CRIT(COG) e exceto 3117, 6107
			If ( Substr(TY04->DEBITO,1,3) $ "617" .or. Substr(TY04->CREDIT,1,3) $ "617" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" .and. TY04->CRIT <> "COG" .and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.00754976
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// GGF, D`Pessoal, Depreciação, Aluguel
			// C.Contábil: BAS(612,613,614,615,616,617)
			// CLVL: TODAS fábrica 2, !CRIT(COG) e exceto 6204
			If ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "32,62" .and. TY04->CRIT <> "COG" .and. TY04->CRIT <> "R02" .and. !Alltrim(TY04->CVLVLCRE) $ "6204"

				cwCusto := cwCusto * 0.01485990
				cwClvlD := "6204"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				EndIf	

			EndIf

			// Depreciação, Aluguel
			// C.Contábil: BAS(615,617)
			// CLVL: TODAS fábrica 1 e 2 e exceto 6001
			If ( Substr(TY04->DEBITO,1,3) $ "615,617" .or. Substr(TY04->CREDIT,1,3) $ "615,617" ) .and. Substr(TY04->CVLVLCRE, 1, 2) $ "30,60" .and. !Alltrim(TY04->CVLVLCRE) $ "6001"

				cwCusto := cwCusto * 0.01045339
				cwClvlD := "6204"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				EndIf	

			EndIf

			// -------------------------- 
			//  Fechamento Abril de 2020
			// -------------------------- 

		ElseIf dtos(MV_PAR01) == "20200401" 

			// Crit R01, Fab 01 ==> F1_R01
			If TY04->CRIT $ "R01" ;
			.and. ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" );
			.and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" ;
			.and. !Alltrim(TY04->CVLVLCRE) $ "6107" 

				cwCusto := cwCusto * 1
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Crit TOT/GCS, Fab 01 ==> F1_TOTGCS
			If TY04->CRIT $ "TOT/GCS" ;
			.and. ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" );
			.and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" ;
			.and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.64
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Crit L01, Fab 01  ==> F1_L01
			If TY04->CRIT $ "L01" ;
			.and. ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" );
			.and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" ;
			.and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.73
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Crit L03/E03/E04, Fab 01 ==> F1_L03E03E04
			If TY04->CRIT $ "L03/E03/E04" ;
			.and. ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" );
			.and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" ;
			.and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.47
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Crit TOT/MOP/GCS, Fab 02  ==> F2_TOTMOPGCS
			If TY04->CRIT $ "TOT/MOP/GCS" ;
			.and. ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" ) ;
			.and. Substr(TY04->CVLVLCRE, 1, 2) $ "32,62" ;
			.and. !Alltrim(TY04->CVLVLCRE) $ "6204"

				cwCusto := cwCusto * 0.73
				cwClvlD := "6204"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				EndIf	

			EndIf

			// Crit R02, Fab 02  ==> F2_R02
			If TY04->CRIT $ "R02" ;
			.and. ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" ) ;
			.and. Substr(TY04->CVLVLCRE, 1, 2) $ "32,62" ;
			.and. !Alltrim(TY04->CVLVLCRE) $ "6204"

				cwCusto := cwCusto * 0.47
				cwClvlD := "6204"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				EndIf	

			EndIf

			// Crit TOT, Fab GR ==> F0_TOT
			If TY04->CRIT $ "TOT" ;
			.and. ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" ) ;
			.and. Substr(TY04->CVLVLCRE, 1, 2) $ "30,60" ;
			.and. !Alltrim(TY04->CVLVLCRE) $ "6001"

				cwCusto := cwCusto * 0.68
				cwClvlD := "6204"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				EndIf	

			EndIf

			// -------------------------- 
			//  Fechamento maio de 2020
			// -------------------------- 

		ElseIf dtos(MV_PAR01) == "20200501" 

			// Crit R01, Fab 01 ==> F1_R01
			If TY04->CRIT $ "R01" ;
			.and. ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" );
			.and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" ;
			.and. !Alltrim(TY04->CVLVLCRE) $ "6107" 

				cwCusto := cwCusto * 0.55
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Crit TOT/GCS, Fab 01 ==> F1_TOTGCS
			If TY04->CRIT $ "TOT/GCS" ;
			.and. ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" );
			.and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" ;
			.and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.65
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Crit L01, Fab 01  ==> F1_L01
			If TY04->CRIT $ "L01" ;
			.and. ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" );
			.and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" ;
			.and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.66
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Crit L03/E04, Fab 01 ==> F1_L03E04
			If TY04->CRIT $ "L03/E04" ;
			.and. ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" );
			.and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" ;
			.and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.61
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Crit E03, Fab 01 ==> F1_E03
			If TY04->CRIT $ "E03" ;
			.and. ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" );
			.and. Substr(TY04->CVLVLCRE, 1, 2) $ "31,61" ;
			.and. !Alltrim(TY04->CVLVLCRE) $ "3117/6107"

				cwCusto := cwCusto * 0.68
				cwClvlD := "6107"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99", '', ''), "", "" })
				EndIf

			EndIf

			// Crit TOT/MOP/GCS, Fab 02  ==> F2_TOTMOPGCS
			If TY04->CRIT $ "TOT/MOP/GCS" ;
			.and. ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" ) ;
			.and. Substr(TY04->CVLVLCRE, 1, 2) $ "32,62" ;
			.and. !Alltrim(TY04->CVLVLCRE) $ "6204"

				cwCusto := cwCusto * 0.35
				cwClvlD := "6204"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				EndIf	

			EndIf

			// Crit R02, Fab 02  ==> F2_R02
			If TY04->CRIT $ "R02" ;
			.and. ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" ) ;
			.and. Substr(TY04->CVLVLCRE, 1, 2) $ "32,62" ;
			.and. !Alltrim(TY04->CVLVLCRE) $ "6204"

				cwCusto := cwCusto * 0.39
				cwClvlD := "6204"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				EndIf	

			EndIf

			// Crit TOT, Fab GR ==> F0_TOT
			If TY04->CRIT $ "TOT" ;
			.and. ( Substr(TY04->DEBITO,1,3) $ "612,613,614,615,616,617" .or. Substr(TY04->CREDIT,1,3) $ "612,613,614,615,616,617" ) ;
			.and. Substr(TY04->CVLVLCRE, 1, 2) $ "30,60" ;
			.and. !Alltrim(TY04->CVLVLCRE) $ "6001"

				cwCusto := cwCusto * 0.53
				cwClvlD := "6204"
				If cwCusto > 0
					Aadd(fgVetCtb, { TY04->DEBITO, TY04->CREDIT, cwClvlD, TY04->CVLVLCRE, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				ElseIf cwCusto < 0
					Aadd(fgVetCtb, { TY04->CREDIT, TY04->DEBITO, TY04->CVLVLCRE, cwClvlD, TY04->ITEMCTA, TY04->ITEMCTA, ABS(cwCusto), TY04->HIST, TY04->CCUSTO, TY04->CCUSTO, TY04->ORIGEM + " " + TY04->CRIT + " " + Transform(TY04->CUSTO, "@E 999,999,999.99") })
				EndIf	

			EndIf

		EndIf

		dbSelectArea("TY04")
		dbSkip()

	End

	TY04->(dbCloseArea())
	Ferase(TYcIndex+GetDBExtension())
	Ferase(TYcIndex+OrdBagExt())

	U_BiaCtbAV(fgLanPad, fgLotCtb, fgVetCtb, fgPermDg)

	MsgINFO("... Fim do Processamento ...")

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 25.01.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()
	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data                ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data               ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return
