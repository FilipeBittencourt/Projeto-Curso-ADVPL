#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FONT.CH'
#INCLUDE "TOTVS.CH"
#Include "PROTHEUS.CH"

User Function MT103NFE()

	Local aInfOri	:= {}
	Local _lIntrag	:=	.F.
	Local _cTpProd
	Local _Grupo
	Local _aAreaF1 := SF1->(GetArea())
	Local _aAreaD1 := SD1->(GetArea())
	Local i

	Local sNota 	:= ""
	Local sSerie 	:= ""
	Local sForn 	:= ""
	Local sLoja 	:= ""
	Local _cCodProd	:= ""
	

	Private vvvArea := GetArea()
	Private __CCOND := ""

	Public __Distri  	:= .F.     // Incluido em 16/01/15 por Marcos Alberto Soprani para atender integração Totvs Colaboração
	Public __LocDis  	:= "ZZZZ"  // Incluido em 16/01/15 por Marcos Alberto Soprani para atender integração Totvs Colaboração
	Public ktcGravei 	:= .F.     // Tratativa para controle de cancelamento do processo de classificação - Por Marcos Alberto Soprani em 28/12/15.

	If PARAMIXB == 3 .Or. PARAMIXB  == 4 .Or. L103CLASS

		If FwIsInCallStack('U_GATI001') .And. !FwIsInCallStack("ClassDoc")
			If aScan(aAutoItens[1],{|x| Alltrim(x[1]) == "D1_ITEM" }) <= 0 //NÃO EXISTE A COLUNA ITEM NO VETOR aAutoItens, SENDO UMA NOTA DE RETORNO, NÃO PRECISA DAS VALIDAÇÕES
				Return
			EndIf

			If AllTrim(aAutoCab[aScan(aAutoCab, {|x| Alltrim(x[1]) == "F1_ESPECIE" })][2]) == "CTE"
				Return
			EndIf

			//PREENCHE SDS E SDT
			PreencSD()
			sNota := ZAA->ZAA_DOC
			sSerie := ZAA->ZAA_SERIE
			sForn := ZAA->ZAA_CODEMI
			sLoja := ZAA->ZAA_LOJEMI
			M->cLoja := ZAA->ZAA_LOJEMI

			_xTipoNf := AllTrim(aAutoCab[aScan(aAutoCab, {|x| Alltrim(x[1]) == "F1_TIPO" })][2])

			If !(sForn $ "003721/007602/002912/000534/004695" .Or. (cEmpAnt == "14" .and. sForn == "000481" .and. _xTipoNf == "B"))
				For i := 1 to Len(aAutoItens)
					//REGRA
					If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_YREGRA" }) <= 0 .And. AllTrim(aAutoCab[aScan(aAutoCab, {|x| Alltrim(x[1]) == "F1_ESPECIE" })][2]) != "CTE"
						Aadd(aAutoItens[i],{"D1_YREGRA","N ",nil})
					EndIf
					//CFOP
					If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_YCFFORN" }) <= 0
						Aadd(aAutoItens[i],{"D1_YCFFORN",nil,nil})
					EndIf
					//CST
					If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_YCSTFOR" }) <= 0
						Aadd(aAutoItens[i],{"D1_YCSTFOR",nil,nil})
					EndIf
					
					
					If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" }) > 0
					
						_cCodProd := aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_COD" })][2]
						
						If _xTipoNf == "B"
							aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := "07" //SD1->D1_LOCAL
						ElseIf (U_CAMTMUND(sForn, sNota, sSerie, _cCodProd)) //Amostra Mundi
							aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] 	:= "05" 
					//		aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOTECTL" })][2] := "AMT" 
						Else
							If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_PEDIDO" }) > 0 .And. aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_ITEMPC" }) > 0
								SC7->(DbSetOrder(1))
								If SC7->(DbSeek(XFilial("SC7") + aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_PEDIDO" })][2] + aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_ITEMPC" })][2])) .And. !Empty(SC7->C7_LOCAL)
									aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := SC7->C7_LOCAL //SD1->D1_LOCAL
								Else
									SBZ->(DbSetOrder(1))
									If SBZ->(DbSeek(XFilial("SBZ")+ aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_COD" })][2])) .And. !Empty(SBZ->BZ_LOCPAD)
										aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := SBZ->BZ_LOCPAD //SD1->D1_LOCAL
									Else
										aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := SB1->B1_LOCPAD //SD1->D1_LOCAL
									EndIf
								EndIf
							Else
								SBZ->(DbSetOrder(1))
								If SBZ->(DbSeek(XFilial("SBZ")+ aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_COD" })][2])) .And. !Empty(SBZ->BZ_LOCPAD)
									aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := SBZ->BZ_LOCPAD //SD1->D1_LOCAL
								Else
									aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := SB1->B1_LOCPAD //SD1->D1_LOCAL
								EndIf
							EndIf
						EndIf
					EndIf

					SDT->(DbSetOrder(3))
					If SDT->(DbSeek(XFilial("SDT")+sForn+sLoja+sNota+sSerie+ aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_COD" })][2]))
						aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_YCFFORN" })][2] := Iif(Empty(SDT->DT_CODCFOP),"",SDT->DT_CODCFOP) //SD1->D1_YCFFORN
						aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_YCSTFOR" })][2] := Iif(Empty(SDT->DT_YCSTFOR),"",SDT->DT_YCSTFOR) //SD1->D1_YCSTFOR
					EndIf

					// Tratativa para controle de cancelamento do processo de classificação - Por Marcos Alberto Soprani em 28/12/15.
					ktcGravei := .T.
				Next

				If Len(aNFEDanfe) > 0

					If !Empty(OTPFRETE) .And. Empty(aNFEDanfe[14])
						aNFEDanfe[14] := RetTipoFrete(OTPFRETE)
					EndIf

				EndIf

				Return
			EndIf

			For i := 1 to Len(aAutoItens)
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_YREGRA" }) <= 0
					Aadd(aAutoItens[i],{"D1_YREGRA",nil,nil})
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_PEDIDO" }) <= 0
					Aadd(aAutoItens[i],{"D1_PEDIDO",nil,nil})
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOTECTL" }) <= 0
					Aadd(aAutoItens[i],{"D1_LOTECTL",nil,nil})
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_DTVALID" }) <= 0
					Aadd(aAutoItens[i],{"D1_DTVALID",nil,nil})
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_OP" }) <= 0
					Aadd(aAutoItens[i],{"D1_OP",nil,nil})
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_YFORIND" }) <= 0
					Aadd(aAutoItens[i],{"D1_YFORIND",nil,nil})
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_YCODREF" }) <= 0
					Aadd(aAutoItens[i],{"D1_YCODREF",nil,nil})
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_NFORI" }) <= 0
					Aadd(aAutoItens[i],{"D1_NFORI",nil,nil})
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_SERIORI" }) <= 0
					Aadd(aAutoItens[i],{"D1_SERIORI",nil,nil})
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_ITEMORI" }) <= 0
					Aadd(aAutoItens[i],{"D1_ITEMORI",nil,nil})
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_IDENTB6" }) <= 0
					Aadd(aAutoItens[i],{"D1_IDENTB6",nil,nil})
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_VLSLXML" }) <= 0
					Aadd(aAutoItens[i],{"D1_VLSLXML",nil,nil})
				EndIf
				//CFOP
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_YCFFORN" }) <= 0
					Aadd(aAutoItens[i],{"D1_YCFFORN",nil,nil})
				EndIf
				//CST
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_YCSTFOR" }) <= 0
					Aadd(aAutoItens[i],{"D1_YCSTFOR",nil,nil})
				EndIf
			Next
		Else
			Return
		EndIf

		QT001 := " SELECT DT_ITEM,
		QT001 += "        DT_PRODFOR,
		QT001 += "        DT_COD,
		QT001 += "        DT_DESCFOR,
		QT001 += "        DT_QUANT,
		QT001 += "        DT_VUNIT,
		QT001 += "        DT_TOTAL,
		QT001 += "        DT_YCFOP,
		QT001 += "        DT_PEDIDO,
		QT001 += "        DT_ITEMPC,
		QT001 += "        DT_YUNID,
		QT001 += "        DT_YCLVL,
		QT001 += "        DT_YTES,
		QT001 += "        DT_YREGRA,
		QT001 += "        DT_YNFORI,
		QT001 += "        DT_YSRORI,
		QT001 += "        DT_YITORI,
		QT001 += "        DT_YIDTB6,
		QT001 += "        DT_DOC,
		QT001 += "        DT_LOTE,
		QT001 += "        DT_DTVALID,
		QT001 += "        DT_XMLICST,
		QT001 += "        DT_YXMLBST,
		QT001 += "		  DT_XALICST,
		QT001 += "        DS_TIPO
		QT001 += "   FROM " + RetSqlName("SDT") + " SDT
		QT001 += "  INNER JOIN " + RetSqlName("SDS") + " SDS ON DS_FILIAL = '"+xFilial("SDS")+"'
		QT001 += "                   AND DS_DOC = DT_DOC
		QT001 += "                   AND DS_SERIE = DT_SERIE
		QT001 += "                   AND DS_FORNEC = DT_FORNEC
		QT001 += "                   AND DS_LOJA = DT_LOJA
		QT001 += "                   AND SDS.D_E_L_E_T_ = ' '
		QT001 += "  WHERE DT_FILIAL = '" + xFilial("SDT") + "'
		QT001 += "    AND DT_FORNEC = '" + sForn + "'
		QT001 += "    AND DT_LOJA = '" + sLoja + "'
		QT001 += "    AND DT_DOC = '" + sNota + "'
		QT001 += "    AND DT_SERIE = '" + sSerie + "'
		QT001 += "    AND SDT.D_E_L_E_T_ = ' '
		QTlIndex := CriaTrab(Nil,.f.)
		QT001 := ChangeQuery(QT001)
		cIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,QT001),'QT01',.T.,.T.)
		dbSelectArea("QT01")
		dbGoTop()
		While !Eof()

			kjCod     := QT01->DT_COD
			kjTES     := QT01->DT_YTES
			kjRegra   := QT01->DT_YREGRA
			kjNfOri   := QT01->DT_YNFORI
			kjSrOri   := QT01->DT_YSRORI
			kjItOri   := QT01->DT_YITORI
			kjIdtB6   := QT01->DT_YIDTB6
			kjPedid   := QT01->DT_PEDIDO
			kjItPed   := QT01->DT_ITEMPC
			kjFormt   := Space(2)
			kjLoteC   := Space(10)
			kjCodRf   := Space(15)
			kjAlmox	  := Space(2)
			_xTipoNf  := QT01->DS_TIPO

			If sForn == "003721"

				kjCod   := QT01->DT_PRODFOR

				If Substr(QT01->DT_YCFOP,2,3) $ "902/903"

					kxNfRet  := .T.

					// Busca os dados de lote na Vitcer
					zp_Empr := "14"

					BK005 := " SELECT D2_LOTECTL, D2_YCODREF, D2_NFORI
					BK005 += "   FROM SD2"+zp_Empr+"0
					BK005 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
					BK005 += "    AND D2_DOC = '"+QT01->DT_DOC+"'
					BK005 += "    AND D2_ITEM = '"+Substr(QT01->DT_ITEM,3,2)+"'
					BK005 += "    AND D2_QUANT = "+Alltrim(Str(QT01->DT_QUANT))
					BK005 += "    AND D_E_L_E_T_ = ' '
					BKlIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,BK005),'BK05',.T.,.T.)
					dbSelectArea("BK05")
					dbGoTop()
					kjLotOri := BK05->D2_LOTECTL
					kjCodRf  := BK05->D2_YCODREF
					kjNfOri  := BK05->D2_NFORI
					BK05->(dbCloseArea())
					Ferase(BKlIndex+GetDBExtension())     //arquivo de trabalho
					Ferase(BKlIndex+OrdBagExt())          //indice gerado

					kjLoteC  := kjLotOri
					RT004 := " SELECT D2_DOC, D2_SERIE, D2_ITEM, D2_IDENTB6
					RT004 += "   FROM " + RetSqlName("SD2")
					RT004 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
					RT004 += "    AND D2_DOC IN('"+kjNfOri+"','000"+kjNfOri+"')
					RT004 += "    AND D2_COD = '"+kjCod+"'
					RT004 += "    AND D2_LOTECTL = '"+kjLotOri+"'
					RT004 += "    AND D2_IDENTB6 IN(SELECT MIN(B6_IDENT)
					RT004 += "                        FROM " + RetSqlName("SB6")
					RT004 += "                       WHERE B6_FILIAL = '"+xFilial("SB6")+"'
					RT004 += "                         AND B6_DOC IN('"+kjNfOri+"','000"+kjNfOri+"')
					RT004 += "                         AND B6_PRODUTO = '"+kjCod+"'
					RT004 += "                         AND B6_PRUNIT BETWEEN "+Alltrim(Str(NoRound(QT01->DT_VUNIT,1)))+" AND "+Alltrim(Str(Round(QT01->DT_VUNIT+0.1,4)))
					RT004 += "                         AND B6_SALDO >= " + Alltrim(Str(QT01->DT_QUANT))
					RT004 += "                         AND D_E_L_E_T_ = ' ')
					RT004 += "    AND D_E_L_E_T_ = ' '
					TcQuery RT004 ALIAS "RT04" NEW
					dbSelectArea("RT04")
					dbGoTop()
					If !Empty(RT04->D2_DOC)
						kjNfOri := RT04->D2_DOC
					EndIf
					kjSrOri := RT04->D2_SERIE
					kjItOri := RT04->D2_ITEM
					kjIdtB6 := RT04->D2_IDENTB6
					RT04->(dbCloseArea())

					If Substr(QT01->DT_YCFOP,2,3) $ "902"                                    // Retorno de Industrialização
						***************************************************************************************************
						kjTES   := "057"
						kjRegra := "M "
					ElseIf Substr(QT01->DT_YCFOP,2,3) $ "903"                             // Ret. Ind. - Quebra no Processo
						***************************************************************************************************
						kjTES   := "089"
						kjRegra := "M "
					ElseIf Substr(QT01->DT_YCFOP,2,3) $ "903"                        // Ret. Ind. - Quebra Fora do Processo
						***************************************************************************************************
						kjTES   := ""
						kjRegra := ""
					ElseIf Substr(QT01->DT_YCFOP,2,3) $ "903"                               // Retorno Sem Industrialização
						***************************************************************************************************
						kjTES   := "175"
						kjRegra := "N "
					EndIf

				ElseIf Substr(QT01->DT_YCFOP,2,3) == "124"                                              // INDUSTRIALIZAÇÃO
					*******************************************************************************************************

					// Busca os dados de lote na Vitcer
					zp_Empr := "14"

					BK005 := " SELECT D2_LOTECTL, D2_YCODREF
					BK005 += "   FROM SD2"+zp_Empr+"0
					BK005 += "  WHERE D2_FILIAL = '"+xFilial("SD2")+"'
					BK005 += "    AND D2_DOC = '"+QT01->DT_DOC+"'
					BK005 += "    AND D2_ITEM = '"+Substr(QT01->DT_ITEM,3,2)+"'
					BK005 += "    AND D2_QUANT = "+Alltrim(Str(QT01->DT_QUANT))
					BK005 += "    AND D_E_L_E_T_ = ' '
					BKlIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,BK005),'BK05',.T.,.T.)
					dbSelectArea("BK05")
					dbGoTop()
					kjLotInd := BK05->D2_LOTECTL
					kjFormt  := BK05->D2_YCODREF
					BK05->(dbCloseArea())
					Ferase(BKlIndex+GetDBExtension())     //arquivo de trabalho
					Ferase(BKlIndex+OrdBagExt())          //indice gerado

					If Empty(kjPedid) .or. Empty(kjItPed)

						RT004 := " SELECT TOP 1 *
						RT004 += "   FROM (SELECT TOP 1 C7_NUM, C7_ITEM
						RT004 += "           FROM " + RetSqlName("SC7")
						RT004 += "          WHERE C7_FILIAL = '01'
						RT004 += "            AND C7_FORNECE = '003721'
						RT004 += "            AND C7_PRODUTO = '"+kjCod+"'
						RT004 += "            AND C7_QUANT - C7_QUJE = " + Alltrim(Str(QT01->DT_QUANT))
						RT004 += "            AND C7_LOTECTL = '"+kjLotInd+"'
						RT004 += "            AND C7_CONAPRO IN('L',' ')
						RT004 += "            AND C7_RESIDUO = ' '
						RT004 += "            AND D_E_L_E_T_ = ' '
						RT004 += "         UNION
						RT004 += "         SELECT TOP 1 C7_NUM, C7_ITEM
						RT004 += "           FROM " + RetSqlName("SC7")
						RT004 += "          WHERE C7_FILIAL = '"+xFilial("SC7")+"'
						RT004 += "            AND C7_FORNECE = '003721'
						RT004 += "            AND C7_PRODUTO = '"+kjCod+"'
						RT004 += "            AND C7_QUANT - C7_QUJE = " + Alltrim(Str(QT01->DT_QUANT))
						RT004 += "            AND C7_CONAPRO IN('L',' ')
						RT004 += "            AND C7_RESIDUO = ' '
						RT004 += "            AND D_E_L_E_T_ = ' ') PEDIDOS
						TcQuery RT004 ALIAS "RT04" NEW
						dbSelectArea("RT04")
						dbGoTop()
						kjPedid := RT04->C7_NUM
						kjItPed := RT04->C7_ITEM
						RT04->(dbCloseArea())

					End

					kjTES   := "178"
					kjRegra := "N "
					kjLoteC := kjLotInd

				EndIf

			ElseIf sForn $ "007602/002912/000534/004695" .or. (cEmpAnt == "14" .and. sForn == "000481" .and. _xTipoNf == "B")

				// Fornecedor      IntraGrupo -- Mundi(004695) / Incesa(002912) / Biancogres(000534) / LM(007602) / VITCER (003721)
				*************************************************************************************************
				// Cliente         IntraGrupo -- Mundi(014395) / Incesa(004536) / Biancogres(000481) / LM(010064) / VITCER (008615)
				*************************************************************************************************

				kjCod		:= QT01->DT_PRODFOR
				kjLotInd 	:= ""
				kjDtVlLot	:= ""
				kjLoteC 	:= kjLotInd
				_xIntrGrV	:= .T.

				//Preenche informações da Empresa Origem
				aInfOri	:= U_GetInfO2(sNota,sSerie,sForn,sLoja,"","",cEmpAnt)
				zp_Empr := aInfOri[1]
				zp_Fil	:= aInfOri[2]
				zp_Cli 	:= aInfOri[3]

				//Preenche informações sobre a Distribuicao dos Produtos
				If cEmpAnt == "01"
					__Distri  := .T.
					__LocDis  := "ZZZZ"
				ElseIf cEmpAnt == "05"
					__Distri  := .T.
					__LocDis  := "ZZZZ"
				ElseIf cEmpAnt == "07"
					__Distri  := .T.
					__LocDis  := "LM"
				ElseIf cEmpAnt == "13"
					__Distri  := .F.
					__LocDis  := "ZZZZ"
				ElseIf cEmpAnt == "14"
					__Distri  := .T.
					__LocDis  := "ZZZZ"
				EndIf

				//Tratamento para Condição de Pagamento do Tipo 9 //OS 4134-15
				SE4->(DbSetOrder(1))
				SE4->(DbSeek(xFilial("SE4")+aInfOri[16]))
				If Alltrim(SE4->E4_TIPO) <> '9'
					__CCOND  := aInfOri[16]
				Else
					__CCOND  := "056"
				EndIf

				//Grava o Peso Liquido
				__PLiqui := aInfOri[17]

				//Define o TES
				kjTES := "0A2"
				If Alltrim(aInfOri[15]) == 'B'
					kjTES := '0A5'
				Else
					If zp_Empr == '01' .or. zp_Empr == '05'
						kjTES := '0A2'
						If cEmpAnt = '05'
							kjTES := '2A3'
						EndIf
					ElseIf zp_Empr == '07'
						If cFilAnt == "01"
							kjTES := "001"
						ElseIf cFilAnt == "02"
							kjTES := "001"
						ElseIf cFilAnt == "03"
							kjTES := "001"
						ElseIf cFilAnt == "04"
							kjTES := "001"
						EndIf
					ElseIf zp_Empr == '13' .and. Alltrim(aInfOri[15]) <> 'A'
						//kjTES := '0A3'
						kjTES := '0A4'
					ElseIf zp_Empr == '13' .and. Alltrim(aInfOri[15]) == 'A'
						kjTES := '1C6'
					ElseIf cEmpAnt == '14' .and. zp_Empr == '01'
						kjTES := '001'
					EndIf
				EndIf

			EndIf

			_cTpProd	:=	""
			heRetLotOk := .F.
			If Alltrim(GetMv("MV_RASTRO")) == "S"
				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(xFilial("SB1")+QT01->DT_COD))
					_cTpProd	:=	SB1->B1_TIPO
					_Grupo := SB1->B1_GRUPO
					If SB1->B1_RASTRO == "L"
						SF4->(dbSetOrder(1))
						SF4->(dbSeek(xFilial("SF4")+kjTES))
						If SF4->F4_ESTOQUE == "S" .or. 1 == 1
							heRetLotOk := .T.
						EndIf
					EndIf
				EndIf
			EndIf

			For i := 1 to Len(aAutoItens)
				If aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_ITEM" })][2] == QT01->DT_ITEM
					Exit
				EndIf
			Next

			_lIntrag	:=	GetNewPar("MV_YFATGRP",.F.) .And.  cEmpAnt == "05"  .And. sForn == '000534' .And. Alltrim(_cTpProd) == "PA"

			//Busca Informações da Origem por Item / Totvs Colaboracao intragrupo
			aInfOri		:= U_GetInfO2(sNota,sSerie,sForn,sLoja,QT01->DT_COD,QT01->DT_ITEM,cEmpAnt)
			kjLotInd 	:= aInfOri[13]
			kjDtVlLot	:= aInfOri[14]
			kjLoteC 	:= kjLotInd
			kjAlmox		:= aInfOri[18]

			aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_TES" })][2] := Iif(Empty(kjTES), aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_TES" })][2], kjTES) //SD1->D1_TES
			aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_YREGRA" })][2] := IIF(Empty(kjRegra), "N ", kjRegra) //SD1->D1_YREGRA
			If Empty(kjPedid)
				aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_PEDIDO" })][2] := aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_PEDIDO" })][2] //SD1->D1_PEDIDO
			EndIf
			If AllTrim(aAutoCab[aScan(aAutoCab, {|x| Alltrim(x[1]) == "F1_TIPO" })][2]) != "D"
				If _lIntrag
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_COD" })][2] := SUBSTR(Alltrim(QT01->DT_COD),1,Len(Alltrim(QT01->DT_COD))-1) //SD1->D1_COD
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOTECTL" })][2] := "" //SD1->D1_LOTECTL
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_DTVALID" })][2] := STOD("") //SD1->D1_DTVALID
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_OP" })][2] := fSeekOp(QT01->DT_COD, aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_QUANT" })][2]) //SD1->D1_OP
				Else
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOTECTL" })][2] := IIF(heRetLotOk, kjLoteC, "") //SD1->D1_LOTECTL
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_DTVALID" })][2] := STOD(IIF(heRetLotOk, kjDtVlLot,"")) //SD1->D1_DTVALID
				EndIf
			EndIf
			aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_YFORIND" })][2] := kjFormt //SD1->D1_YFORIND
			aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_YCODREF" })][2] := kjCodRf //SD1->D1_YCODREF
			If AllTrim(aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_NFORI" })][2]) == ""
				aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_NFORI" })][2] := kjNfOri //SD1->D1_NFORI
				aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_SERIORI" })][2] := kjSrOri //SD1->D1_SERIORI
				aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_ITEMORI" })][2] := kjItOri //SD1->D1_ITEMORI
			EndIf
			aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_IDENTB6" })][2] := kjIdtB6 //SD1->D1_IDENTB6
			//Se a NF teve ICMS ST na Origem (SD2 - Saída), grava este valor também na Entrada (SD1)
			If QT01->DT_XMLICST > 0
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_BRICMS" }) > 0
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_BRICMS" })][2] := Iif(QT01->DT_YXMLBST == "" .Or. QT01->DT_YXMLBST == nil, 0, QT01->DT_YXMLBST) //Base ICMS ST //SD1->D1_BRICMS
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_ICMSRET" }) > 0
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_ICMSRET" })][2] := Iif(QT01->DT_XMLICST == "" .Or. QT01->DT_XMLICST == nil, 0, QT01->DT_XMLICST)	//Vl. ICMS ST //SD1->D1_ICMSRET
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_VLSLXML" }) > 0
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_VLSLXML" })][2] := Iif(QT01->DT_XMLICST == "" .Or. QT01->DT_XMLICST == nil, 0, QT01->DT_XMLICST) //Vl. ICMS ST //SD1->D1_VLSLXML
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_ALIQSOL" }) > 0
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_ALIQSOL" })][2] := Iif(QT01->DT_XALICST == "" .Or. QT01->DT_XALICST == nil, 0, QT01->DT_XALICST) //Aliq. ICMS ST //SD1->D1_ALIQSOL
				EndIf
			Else
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_BRICMS" }) > 0
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_BRICMS" })][2] := 0 //Base ICMS ST //SD1->D1_BRICMS
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_ICMSRET" }) > 0
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_ICMSRET" })][2] := 0	//Vl. ICMS ST //SD1->D1_ICMSRET
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_VLSLXML" }) > 0
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_VLSLXML" })][2] := 0 //Vl. ICMS ST //SD1->D1_VLSLXML
				EndIf
				If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_ALIQSOL" }) > 0
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_ALIQSOL" })][2] := 0 //Aliq. ICMS ST //SD1->D1_ALIQSOL
				EndIf
			EndIf

			If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" }) > 0
				
				_cCodProd := aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_COD" })][2]
					
				
				If _xTipoNf == "B"
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := "07" //SD1->D1_LOCAL
				ElseIf (U_CAMTMUND(sForn, sNota, sSerie, _cCodProd)) //Amostra Mundi
					aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := "05" 		
					//aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOTECTL" })][2] := "AMT" 	
				Else
					If cEmpAnt == "14" .And. kjTES == "004" .And. sForn $ "000534/007602"  // Tratamento implementado em 15/05/14 por Marcos Alberto Soprani para atender ao emquadramento de almoxarifados da Vitcer
						aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := "01" //SD1->D1_LOCAL
					ElseIf cEmpAnt == "07" .And. sForn $ "000534/002912"
						aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := kjAlmox
					Else
						If aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_PEDIDO" }) > 0 .And. aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_ITEMPC" }) > 0
							SC7->(DbSetOrder(1))
							IF SC7->(DbSeek(XFilial("SC7") + aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_PEDIDO" })][2] + aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_ITEMPC" })][2])) .And. !Empty(SC7->C7_LOCAL)
								aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := SC7->C7_LOCAL //SD1->D1_LOCAL
							Else
								SBZ->(DbSetOrder(1))
								If SBZ->(DbSeek(XFilial("SBZ")+ aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_COD" })][2])) .And. !Empty(SBZ->BZ_LOCPAD)
									aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := SBZ->BZ_LOCPAD //SD1->D1_LOCAL
								Else
									aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := SB1->B1_LOCPAD //SD1->D1_LOCAL
								EndIf
							EndIf
						Else
							SBZ->(DbSetOrder(1))
							If SBZ->(DbSeek(XFilial("SBZ")+ aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_COD" })][2])) .And. !Empty(SBZ->BZ_LOCPAD)
								aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := SBZ->BZ_LOCPAD //SD1->D1_LOCAL
							Else
								aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_LOCAL" })][2] := SB1->B1_LOCPAD //SD1->D1_LOCAL
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf			
			SDT->(DbSetOrder(3))
			If SDT->(DbSeek(XFilial("SDT")+sForn+sLoja+sNota+sSerie+ aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_COD" })][2]))
				aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_YCFFORN" })][2] := Iif(Empty(SDT->DT_CODCFOP),"",SDT->DT_CODCFOP) //SD1->D1_YCFFORN
				aAutoItens[i][aScan(aAutoItens[i],{|x| Alltrim(x[1]) == "D1_YCSTFOR" })][2] := Iif(Empty(SDT->DT_YCSTFOR),"",SDT->DT_YCSTFOR) //SD1->D1_YCSTFOR
			EndIf

			// Tratativa para controle de cancelamento do processo de classificação - Por Marcos Alberto Soprani em 28/12/15.
			ktcGravei := .T.

			dbSelectArea("QT01")
			dbSkip()

		EndDo
		QT01->(dbCloseArea())
		Ferase(QTlIndex+GetDBExtension())	//arquivo de trabalho
		Ferase(QTlIndex+OrdBagExt())		//indice gerado

		If FwIsInCallStack("U_GATI001")
			If !Empty(__CCOND)
				aAutoCab[5][2] := __CCOND
				cCondicao := __CCOND
				M->ZAA_CONDPG := __CCOND
			EndIf

			RestArea(vvvArea)

			If Len(aNFEDanfe) > 0

				If !Empty(OTPFRETE) .And. Empty(aNFEDanfe[14])
					aNFEDanfe[14] := RetTipoFrete(OTPFRETE)
				EndIf

			EndIf
		Else
			If !Empty(__CCOND)
				dbSelectArea("SF1")
				RecLock("SF1",.F.)
				SF1->F1_COND  := __CCOND // POSICAO 5 - CCONPGTO
				cCondicao     := __CCOND
				MsUnlock()
			EndIf

			RestArea(vvvArea)

			If FieldPos("F1_TPFRETE") > 0 .And. Len(aNFEDanfe) > 0

				If !Empty(SF1->F1_TPFRETE) .And. Empty(aNFEDanfe[14])

					aNFEDanfe[14] := RetTipoFrete(SF1->F1_TPFRETE)
				EndIf

			EndIf
		EndIf

		RestArea(_aAreaF1)
		RestArea(_aAreaD1)
		//EndIf

	EndIf

Return

Static Function fSeekOp(_cCod,_nQuant)

	Local _cOp	:=	""
	Local _cAlias	:=	GetNextAlias()
	Local somaVetor := 0
	Local z

	If FwIsInCallStack('U_GATI001') .And. !FwIsInCallStack("ClassDoc")

		BeginSql Alias _cAlias
			SELECT ISNULL(C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD, '') OP, ROUND(C2_QUANT - C2_QUJE, 2) SALDO
			FROM    %TABLE:SC2% SC2
			WHERE   C2_PRODUTO = %Exp:_cCod%
			AND SC2.%Notdel%
			AND C2_DATRF = ''
			AND C2_LINHA IN ('003','L03','E3A')
			ORDER BY SC2.C2_EMISSAO
		EndSql

		While !(_cAlias)->(EOF())
			For z := 1 to Len(aAutoItens)
				If aAutoItens[z][aScan(aAutoItens[z],{|x| Alltrim(x[1]) == "D1_OP" })][2] =  (_cAlias)->OP
					somaVetor = somaVetor + aAutoItens[z][aScan(aAutoItens[z],{|x| Alltrim(x[1]) == "D1_QUANT" })][2]
				EndIf
			Next

			If (_cAlias)->SALDO - somaVetor >= _nQuant
				_cOp	:=	(_cAlias)->OP
				Exit
			EndIf

			somaVetor := 0
			(_cAlias)->(dbSkip())
		End
	Else
		BeginSql Alias _cAlias

			SELECT TOP 1
			ISNULL(C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD, '') OP
			FROM    %TABLE:SC2% SC2
			WHERE   C2_PRODUTO = %Exp:_cCod%
			AND SC2.%Notdel%
			AND C2_DATRF = ''
			AND C2_LINHA IN ('003','L03','E3A')
			AND C2_QUANT - C2_QUJE
			- ( SELECT  ISNULL(SUM(D1_QUANT),0)
			FROM    %TABLE:SD1% SD1
			WHERE   D1_FILIAL = %xFilial:SD1%
			AND D1_DOC = %EXP:SF1->F1_DOC%
			AND D1_SERIE = %Exp:SF1->F1_SERIE%
			AND D1_FORNECE = %Exp:SF1->F1_FORNECE%
			AND D1_LOJA = %Exp:SF1->F1_LOJA%
			AND D1_COD = C2_PRODUTO
			AND D1_OP = C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD
			) >= %Exp:_nQuant%
			ORDER BY SC2.C2_EMISSAO
		EndSql
	EndIf

	_cOp	:=	(_cAlias)->OP

	(_cAlias)->(DbCloseArea())

Return _cOp

Static Function PreencSD()

	U_BIA657(ZAA->ZAA_XML, .F.,"M")
Return


Static Function fGetLoc(cNF, cSer, cProd, cItOri)
	Local cLoc := ""
	Default cItOri := ""

	//CTE de entrada
	cSQL := " SELECT SD1.D1_LOCAL ARMAZEM"
	cSQL += " FROM " + RetSQLName("SD1") + " SD1 "
	cSQL += " WHERE D1_DOC = '" + ALLTRIM(cNF) + "' "
	cSQL += " AND D1_SERIE = '" + ALLTRIM(cSer) + "' "
	cSQL += " AND D1_COD = '" + ALLTRIM(cProd) + "' "

	if  cItOri != ""
		cSQL += " AND D1_ITEM = '" + ALLTRIM(cItOri) + "' "
	endif

	If chkfile("DOC_ENT")
		dbSelectArea("DOC_ENT")
		dbCloseArea()
	EndIf

	TcQuery cSql New Alias "DOC_ENT"

	While !DOC_ENT->(Eof())
		cLoc = ALLTRIM(DOC_ENT->ARMAZEM)
		DOC_ENT->(DbSkip())
	EndDo
	DOC_ENT->(DbCloseArea())
Return cLoc
