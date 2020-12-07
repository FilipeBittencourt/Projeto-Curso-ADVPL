#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Marcos Alberto Soprani
Programa  := CTBGRV
Empresa   := Biancogres Cerêmicas S/A
Data      := 04/05/16
Uso       := CTB
Aplicação :=  O ponto de entrada CTBGRV executa o procedimento de usuário
.            após a gravação de inclusão, alteração ou estorno do lançamento
.            contábil
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Autor     := Artur Antunes
Data      := 02/03/17
Ajuste	  := Inclusão de ajuste automatico de conta e classe valor nas tabelas 
SD1 e SD3 quando acontecer alteração manual no lançamento
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

User Function CTBGRV()

	Local zpOpcLct    := Alltrim(Str(ParamIxb[1]))
	Local zpPrgLct 	  := ParamIxb[2]
	Local xtrArea  	  := GetArea()
	Local aAreaCTL	  := CTL->(GetArea())
	Local aAreaSE5	  := SE5->(GetArea())
	Local aAreaSA1	  := SA1->(GetArea())
	Local aAreaSA2	  := SA2->(GetArea())
	Local aAreaSB1	  := SB1->(GetArea())
	Local aAreaSN1	  := SN1->(GetArea())
	Local aAreaSC5	  := SC5->(GetArea())
	Local xtrHistDeth := ""
	local cClv := ""
	local cConta := ""
	Local cItem := ""
	Local cCliAI := ""
	local xtrAplic    := ""
	Local xtrDriver	:=	""

	Local cAplic := ""
	Local cDrive := ""
	Local cSubItem := ""

	If cEmpAnt <> "02"

		If !Empty(Alltrim(CT2->CT2_KEY)) .and. zpOpcLct $ "3/4"

			CTL->( dbSetOrder(1) )
			If CTL->( dbSeek( xFilial("CTL") + CT2->CT2_LP ) )

				xtrAlias := CTL->CTL_ALIAS
				xtrOrder := Val(Alltrim(CTL->CTL_ORDER))
				xtrKey   := CTL->CTL_KEY

				&(xtrAlias)->( dbSetOrder(xtrOrder) )
				If &(xtrAlias)->( dbSeek( Alltrim(CT2->CT2_KEY) ) )

					xtrNomeCF := ""

					//***********************************************************************
					If xtrAlias == "SD1"
						If SD1->D1_TIPO $ "B/D"
							SA1->( dbSetOrder(1) )
							SA1->( dbSeek(xFilial("SA1") + SD1->D1_FORNECE + SD1->D1_LOJA ) )
							xtrNomeCF := Alltrim(SA1->A1_NOME)
						Else
							SA2->( dbSetOrder(1) )
							SA2->( dbSeek(xFilial("SA2") + SD1->D1_FORNECE + SD1->D1_LOJA ) )
							xtrNomeCF := Alltrim(SA2->A2_NOME)
						EndIf
						SB1->( dbSetOrder(1) )
						SB1->( dbSeek(xFilial("SB1") + SD1->D1_COD ) )
						xtrHistDeth := "DOC: " + SD1->D1_DOC + " SERIE: " + SD1->D1_SERIE + " FORNECEDOR: " + SD1->D1_FORNECE + " - " + SD1->D1_LOJA + ": " + xtrNomeCF + " PRODUTO: " + Alltrim(SD1->D1_COD) + ": " + Alltrim(SB1->B1_DESC)
						xtrAplic    := SD1->D1_YAPLIC
						xtrDriver	:=	SD1->D1_YDRIVER

						cAplic := CT2->CT2_YAPLIC

						if zpOpcLct == '4'

							cClv := ""
							cConta := ""					
							cItem := ""
							cCliAI := ""

							if !Empty(CT2->CT2_CLVLDB) .and. ( SubStr(CT2->CT2_DEBITO,1,1) $ '3/6' .or. Alltrim(CT2->CT2_DEBITO) == '41301001' )

								cClv := CT2->CT2_CLVLDB
								cConta := CT2->CT2_DEBITO
								cItem := CT2->CT2_ITEMD
								cCliAI := CT2->CT2_ATIVDE	
								cDrive := CT2->CT2_YDRVDB
								cSubItem := CT2->CT2_YSUBDB

							elseif !Empty(CT2->CT2_CLVLCR) .and. ( SubStr(CT2->CT2_CREDIT,1,1) $ '3/6' .or. Alltrim(CT2->CT2_CREDIT) == '41301001' )

								cConta	:= CT2->CT2_CREDIT
								cClv	:= CT2->CT2_CLVLCR
								cDrive  := CT2->CT2_YDRVCR
								cSubItem := CT2->CT2_YSUBCR

							endif

							If SD1->D1_YAPLIC <> cAplic .Or. SD1->D1_YDRIVER <> cDrive .Or. SD1->D1_YSUBITE <> cSubItem 
								
								SD1->(RecLock("SD1", .F.))
								SD1->D1_YAPLIC := cAplic
								SD1->D1_YDRIVER := cDrive
								SD1->D1_YSUBITE := cSubItem
								SD1->(MsUnlock())

							endif

							If !Empty(cConta) .or. !Empty(cClv)

								If Alltrim(SD1->D1_CONTA) <> Alltrim(cConta)

									SD1->(RecLock("SD1", .F.))

									SD1->D1_CONTA := cConta
									SD1->D1_ITEMCTA := cItem
									SD1->D1_YSI := cCliAI										

									SD1->(MsUnlock())

								endif

								if !Empty(cClv) .and. Alltrim(SD1->D1_CLVL) <> Alltrim(cClv)
									SD1->(RecLock("SD1",.F.))
									SD1->D1_CLVL := cClv
									SD1->(MsUnlock())
								endif

							endif	
						endif
					EndIf

					//***********************************************************************
					If xtrAlias == "SF1"
						If SF1->F1_TIPO $ "B/D"
							SA1->( dbSetOrder(1) )
							SA1->( dbSeek(xFilial("SA1") + SF1->F1_FORNECE + SF1->F1_LOJA ) )
							xtrNomeCF := Alltrim(SA1->A1_NOME)
						Else
							SA2->( dbSetOrder(1) )
							SA2->( dbSeek(xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA ) )
							xtrNomeCF := Alltrim(SA2->A2_NOME)
						EndIf
						xtrHistDeth := "DOC: " + SF1->F1_DOC + " SERIE: " + SF1->F1_SERIE + " FORNECEDOR: " + SF1->F1_FORNECE + " - " + SF1->F1_LOJA + ": " + xtrNomeCF
						If !(FwIsInCallStack('CTBA102') .or. FwIsInCallStack('CTBANFE'))
							If !Empty(c_cNumRpv)
								xtrHistDeth	+= " RPV: " + Alltrim(c_cNumRpv)
							EndIf
						EndIf
					EndIf

					//***********************************************************************
					If xtrAlias == "SD2"
						If !SD2->D2_TIPO $ "B/D"
							SA1->( dbSetOrder(1) )
							SA1->( dbSeek(xFilial("SA1") + SD2->D2_CLIENTE + SD2->D2_LOJA ) )
							xtrNomeCF := Alltrim(SA1->A1_NOME)
						Else
							SA2->( dbSetOrder(1) )
							SA2->( dbSeek(xFilial("SA2") + SD2->D2_CLIENTE + SD2->D2_LOJA ) )
							xtrNomeCF := Alltrim(SA2->A2_NOME)
						EndIf
						SB1->( dbSetOrder(1) )
						SB1->( dbSeek(xFilial("SB1") + SD2->D2_COD ) )
						xtrHistDeth := "DOC: " + SD2->D2_DOC + " SERIE: " + SD2->D2_SERIE + " CLIENTE...: " + SD2->D2_CLIENTE + " - " + SD2->D2_LOJA + ": " + xtrNomeCF + " PRODUTO: " + Alltrim(SD2->D2_COD) + ": " + Alltrim(SB1->B1_DESC)
						If SUBSTR(Alltrim(CT2->CT2_ORIGEM),1,6) $"610005/610015"
							DbSelectArea("SC5")
							SC5->(DbSetOrder(1))
							If SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
								xtrHistDeth	+=	" RPV: " + Alltrim(SC5->C5_YOBS)
							EndIf
						EndIf
					EndIf

					//***********************************************************************
					If xtrAlias == "SF2"
						If !SF2->F2_TIPO $ "B/D"
							SA1->( dbSetOrder(1) )
							SA1->( dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
							xtrNomeCF := Alltrim(SA1->A1_NOME)
						Else
							SA2->( dbSetOrder(1) )
							SA2->( dbSeek(xFilial("SA2") + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
							xtrNomeCF := Alltrim(SA2->A2_NOME)
						EndIf
						xtrHistDeth := "DOC: " + SF2->F2_DOC + " SERIE: " + SF2->F2_SERIE + " CLIENTE...: " + SF2->F2_CLIENTE + " - " + SF2->F2_LOJA + ": " + xtrNomeCF
					EndIf

					//***********************************************************************
					If xtrAlias == "SD3"
						SB1->( dbSetOrder(1) )
						SB1->( dbSeek(xFilial("SB1") + SD3->D3_COD ) )
						xtrHistDeth := "DOC: " + SD3->D3_DOC + " CF...: " + SD3->D3_CF + " PRODUTO: " + Alltrim(SD3->D3_COD) + ": " + Alltrim(SB1->B1_DESC)
						xtrAplic    := SD3->D3_YAPLIC
						xtrDriver	:=	SD3->D3_YDRIVER

						cAplic := CT2->CT2_YAPLIC

						if zpOpcLct == '4'

							cConta	:= ''
							cClv	:= ''				
							if !Empty(CT2->CT2_CLVLDB) .and. ( SubStr(CT2->CT2_DEBITO,1,1) $ '3/6' .or. Alltrim(CT2->CT2_DEBITO) == '41301001' )
								cConta	:= CT2->CT2_DEBITO
								cClv	:= CT2->CT2_CLVLDB	
								cDrive := CT2->CT2_YDRVDB
								cSubItem := CT2->CT2_YSUBDB
							elseif !Empty(CT2->CT2_CLVLCR) .and. ( SubStr(CT2->CT2_CREDIT,1,1) $ '3/6' .or. Alltrim(CT2->CT2_CREDIT) == '41301001' )
								cConta	:= CT2->CT2_CREDIT
								cClv	:= CT2->CT2_CLVLCR	
								cDrive  := CT2->CT2_YDRVCR
								cSubItem := CT2->CT2_YSUBCR				
							endif

							If SD3->D3_YAPLIC <> cAplic .Or. SD3->D3_YDRIVER <> cDrive .Or. SD3->D3_YSUBITE <> cSubItem
								
								SD3->(RecLock("SD3",.F.))
								SD3->D3_YAPLIC := cAplic
								SD3->D3_YDRIVER := cDrive
								SD3->D3_YSUBITE := cSubItem
								SD3->(MsUnlock())

							EndIf

							if !Empty(cConta) .or. !Empty(cClv) 

								if Alltrim(SD3->D3_CONTA) <> Alltrim(cConta)
									SD3->(RecLock("SD3",.F.))
									SD3->D3_CONTA := cConta
									SD3->(MsUnlock())
								endif
								if !Empty(cClv) .and. Alltrim(SD3->D3_CLVL) <> Alltrim(cClv)
									SD3->(RecLock("SD3",.F.))
									SD3->D3_CLVL := cClv
									SD3->(MsUnlock())
								endif
							endif	
						endif
					EndIf

					//***********************************************************************
					If xtrAlias == "SE1"
						SA1->( dbSetOrder(1) )
						SA1->( dbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA ) )
						xtrNomeCF := Alltrim(SA1->A1_NOME)
						xtrHistDeth := "TIT: " + SE1->E1_NUM + " PREF.:" + SE1->E1_PREFIXO + " PARCELA: " + SE1->E1_PARCELA + " TIPO: " + SE1->E1_TIPO + " CLIENTE...: " + SE1->E1_CLIENTE + " - " + SE1->E1_LOJA + ": " + xtrNomeCF
					EndIf

					//***********************************************************************
					If xtrAlias == "SE2"
						SA2->( dbSetOrder(1) )
						SA2->( dbSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA ) )
						xtrNomeCF := Alltrim(SA2->A2_NOME)
						xtrHistDeth := "TIT: " + SE2->E2_NUM + " PREF.:" + SE2->E2_PREFIXO + " PARCELA: " + SE2->E2_PARCELA + " TIPO: " + SE2->E2_TIPO + " FORNECEDOR: " + SE2->E2_FORNECE + " - " + SE2->E2_LOJA + ": " + xtrNomeCF
					EndIf

					//***********************************************************************
					If xtrAlias == "SE5"
						_xtrHist := ""

						// Incluída exceção por natureza em 13/06/16, para os pagamentos de tarifas sobre cobrança de cliente.
						If SE5->E5_RECPAG == "R" .or. Alltrim(SE5->E5_NATUREZ) $ "2915/2916/2917/2938"

							SA1->( dbSetOrder(1) )
							SA1->( dbSeek(xFilial("SA1") + SE5->E5_CLIFOR + SE5->E5_LOJA ) )
							xtrNomeCF := Alltrim(SA1->A1_NOME)

							_xtrHist := " CLIEFOR...: " + SE5->E5_CLIFOR + " - " + SE5->E5_LOJA + ": " + xtrNomeCF

						Else

							If !Empty(SE5->E5_CLIFOR)

								SA2->( dbSetOrder(1) )
								SA2->( dbSeek(xFilial("SA2") + SE5->E5_CLIFOR + SE5->E5_LOJA ) )
								xtrNomeCF := Alltrim(SA2->A2_NOME)

								_xtrHist := " CLIEFOR...: " + SE5->E5_CLIFOR + " - " + SE5->E5_LOJA + ": " + xtrNomeCF

								//Baixa automatica - incluindo tarifa a partir de retorno do CNAB
							Else

								If ( SE5->E5_TIPODOC = "DB" .And. SE5->E5_MOTBX = "NOR" .And. SE5->E5_RECPAG = "P" )

									SE1->(DbSetOrder(1))
									If SE1->(DbSeek(SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)))

										SA1->( dbSetOrder(1) )
										SA1->( dbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA ) )
										xtrNomeCF := Alltrim(SA1->A1_NOME)

										_xtrHist := " CLIEFOR...: " + SE1->E1_CLIENTE + " - " + SE1->E1_LOJA + ": " + xtrNomeCF
									EndIf

								Else

									SE2->(DbSetOrder(1))
									If SE2->(DbSeek(SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)))

										SA2->( dbSetOrder(1) )
										SA2->( dbSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA ) )
										xtrNomeCF := Alltrim(SA2->A2_NOME)

										_xtrHist := " CLIEFOR...: " + SE2->E2_FORNECE + " - " + SE2->E2_LOJA + ": " + xtrNomeCF

									EndIf

								EndIf

							EndIf
						EndIf
						xtrHistDeth := "TIT: " + SE5->E5_NUMERO + " PREF.:" + SE5->E5_PREFIXO + " PARCELA: " + SE5->E5_PARCELA + " TIPO: " + SE5->E5_TIPO + _xtrHist

						If SE5->E5_RECPAG == "R" .And. SUBSTR(Alltrim(CT2->CT2_ORIGEM),1,6) $"520005/521005"
							xtrHistDeth	+=	" RPV: " + Alltrim(SE1->E1_YOBSLIB)
						EndIf
					EndIf

					//***********************************************************************
					If xtrAlias == "SEF"
						SA2->( dbSetOrder(1) )
						SA2->( dbSeek(xFilial("SA2") + SEF->EF_FORNECE + SEF->EF_LOJA ) )
						xtrNomeCF := Alltrim(SA2->A2_NOME)
						xtrHistDeth := "TIT: " + SEF->EF_TITULO + " PREF.:" + SEF->EF_PREFIXO + " PARCELA: " + SEF->EF_PARCELA + " TIPO: " + SEF->EF_TIPO + " CHEQUE: " + SEF->EF_NUM + " FORNECEDOR: " + SEF->EF_FORNECE + " - " + SEF->EF_LOJA + ": " + xtrNomeCF
					EndIf

					//***********************************************************************
					If xtrAlias == "SN3"
						SN1->( dbSetOrder(1) )
						SN1->( dbSeek(xFilial("SN1") + SN3->N3_CBASE + SN3->N3_ITEM ) )
						xtrDescBn := Alltrim(SN1->N1_DESCRIC)
						SA2->( dbSetOrder(1) )
						SA2->( dbSeek(xFilial("SA2") + SN1->N1_FORNEC + SN1->N1_LOJA ) )
						xtrNomeCF := Alltrim(SA2->A2_NOME)
						xtrHistDeth := "DOC: " + SN1->N1_NFISCAL + " SERIE: " + SN1->N1_NSERIE + " FORNECEDOR: " + SN1->N1_FORNEC + " - " + SN1->N1_LOJA + ": " + xtrNomeCF + " BEM: " + SN3->N3_CBASE + " ITEM: " + SN3->N3_ITEM + " DESCRICAO: " + xtrDescBn
					EndIf

					If Empty(xtrHistDeth)
						xtrHistDeth := "*3 " + CT2->CT2_HIST
					EndIf

				Else

					// Por Marcos Alberto Soprani em 06/06/16
					// Para os casos em que o lançamento se tratar de uma EXCLUSÃO....
					xtrNomeCF := ""

					//***********************************************************************
					If xtrAlias == "SD1"

						TMPTAB := " SELECT *
						TMPTAB += "   FROM " + RetSqlName(xtrAlias)
						TMPTAB += "  WHERE " + Alltrim(xtrKey) + " = '" + Alltrim(CT2->CT2_KEY) + "'
						TMPTAB += "    AND D_E_L_E_T_ = '*'
						TBcIndex := CriaTrab(Nil,.f.)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,TMPTAB),'TTAB1',.F.,.T.)
						dbSelectArea("TTAB1")
						dbGoTop()
						If TTAB1->D1_TIPO $ "B/D"
							SA1->( dbSetOrder(1) )
							SA1->( dbSeek(xFilial("SA1") + TTAB1->D1_FORNECE + TTAB1->D1_LOJA ) )
							xtrNomeCF := Alltrim(SA1->A1_NOME)
						Else
							SA2->( dbSetOrder(1) )
							SA2->( dbSeek(xFilial("SA2") + TTAB1->D1_FORNECE + TTAB1->D1_LOJA ) )
							xtrNomeCF := Alltrim(SA2->A2_NOME)
						EndIf
						SB1->( dbSetOrder(1) )
						SB1->( dbSeek(xFilial("SB1") + TTAB1->D1_COD ) )
						xtrHistDeth := "DOC: " + TTAB1->D1_DOC + " SERIE: " + TTAB1->D1_SERIE + " FORNECEDOR: " + TTAB1->D1_FORNECE + " - " + TTAB1->D1_LOJA + ": " + xtrNomeCF + " PRODUTO: " + Alltrim(TTAB1->D1_COD) + ": " + Alltrim(SB1->B1_DESC)

						TTAB1->(dbCloseArea())
						Ferase(TBcIndex+GetDBExtension())     //arquivo de trabalho
						Ferase(TBcIndex+OrdBagExt())          //indice gerado

					EndIf

					//***********************************************************************
					If xtrAlias == "SD2"

						TMPTAB := " SELECT *
						TMPTAB += "   FROM " + RetSqlName(xtrAlias)
						TMPTAB += "  WHERE " + Alltrim(xtrKey) + " = '" + Alltrim(CT2->CT2_KEY) + "'
						TMPTAB += "    AND D_E_L_E_T_ = '*'
						TBcIndex := CriaTrab(Nil,.f.)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,TMPTAB),'TTAB1',.F.,.T.)
						dbSelectArea("TTAB1")
						dbGoTop()
						If !TTAB1->D2_TIPO $ "B/D"
							SA1->( dbSetOrder(1) )
							SA1->( dbSeek(xFilial("SA1") + TTAB1->D2_CLIENTE + TTAB1->D2_LOJA ) )
							xtrNomeCF := Alltrim(SA1->A1_NOME)
						Else
							SA2->( dbSetOrder(1) )
							SA2->( dbSeek(xFilial("SA2") + TTAB1->D2_CLIENTE + TTAB1->D2_LOJA ) )
							xtrNomeCF := Alltrim(SA2->A2_NOME)
						EndIf
						SB1->( dbSetOrder(1) )
						SB1->( dbSeek(xFilial("SB1") + TTAB1->D2_COD ) )
						xtrHistDeth := "DOC: " + TTAB1->D2_DOC + " SERIE: " + TTAB1->D2_SERIE + " CLIENTE...: " + TTAB1->D2_CLIENTE + " - " + TTAB1->D2_LOJA + ": " + xtrNomeCF + " PRODUTO: " + Alltrim(TTAB1->D2_COD) + ": " + Alltrim(SB1->B1_DESC)

						TTAB1->(dbCloseArea())
						Ferase(TBcIndex+GetDBExtension())     //arquivo de trabalho
						Ferase(TBcIndex+OrdBagExt())          //indice gerado

					EndIf

					//***********************************************************************
					If xtrAlias == "SE2"

						TMPTAB := " SELECT *
						TMPTAB += "   FROM " + RetSqlName(xtrAlias)
						TMPTAB += "  WHERE " + Alltrim(xtrKey) + " = '" + Alltrim(CT2->CT2_KEY) + "'
						TMPTAB += "    AND D_E_L_E_T_ = '*'
						TBcIndex := CriaTrab(Nil,.f.)
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,TMPTAB),'TTAB1',.F.,.T.)
						dbSelectArea("TTAB1")
						dbGoTop()
						SA2->( dbSetOrder(1) )
						SA2->( dbSeek(xFilial("SA2") + TTAB1->E2_FORNECE + TTAB1->E2_LOJA ) )
						xtrNomeCF := Alltrim(SA2->A2_NOME)
						xtrHistDeth := "TIT: " + TTAB1->E2_NUM + " PREF.:" + TTAB1->E2_PREFIXO + " PARCELA: " + TTAB1->E2_PARCELA + " TIPO: " + TTAB1->E2_TIPO + " FORNECEDOR: " + TTAB1->E2_FORNECE + " - " + TTAB1->E2_LOJA + ": " + xtrNomeCF

						TTAB1->(dbCloseArea())
						Ferase(TBcIndex+GetDBExtension())     //arquivo de trabalho
						Ferase(TBcIndex+OrdBagExt())          //indice gerado

					EndIf

					If Empty(xtrHistDeth)
						xtrHistDeth := "*4 " + CT2->CT2_HIST
					EndIf

				EndIf

			Else

				xtrHistDeth := "*2 " + CT2->CT2_HIST

			EndIf

		Else

			xtrHistDeth := "*1 " + CT2->CT2_HIST

		EndIf

		RecLock("CT2",.F.)
		CT2->CT2_YHIST    := xtrHistDeth
		MsUnLock()

		//---------------------------------------------- 
		// -------  CONTROLE DE NÃO GERENCIÁVEL -------
		//---------------------------------------------- 
		msGerencGMCD := .T.

		If !Empty(CT2->CT2_CLVLDB)
			cClv	:= CT2->CT2_CLVLDB
			cConta	:= CT2->CT2_DEBITO
		ElseIf !Empty(CT2->CT2_CLVLCR)
			cConta	:= CT2->CT2_CREDIT
			cClv	:= CT2->CT2_CLVLCR
		Endif

		CT1->(dbSetOrder(1))
		If CT1->(dbSeek(xFilial("CT1") + cConta))
			If !Empty(CT1->CT1_YPCT20)
				ZC8->(dbSetOrder(1))
				If ZC8->(dbSeek(xFilial("ZC8") + CT1->CT1_YPCT20))
					If ZC8->ZC8_GERENC == "N"
						msGerencGMCD := .F.
					EndIf
				EndIf
			EndIf
		EndIf

		If Alltrim(cConta) $ "31104005/61204005"
			msGerencGMCD := .F.
		EndIf

		If Substr(cClv,1,1) $ "4/7"
			If !Alltrim(cClv) $ "4011/4050/4053/4080/4083"
				msGerencGMCD := .F.
			EndIf
		EndIf

		If !msGerencGMCD

			caAnoRef := Substr( dtos(CT2->CT2_DATA) , 1, 4)
			If ZCI->(dbSeek(xFilial("ZCI") + caAnoRef + cClv + cConta)) 
				Reclock("ZCI",.F.)
			Else
				Reclock("ZCI",.T.)
			EndIf
			ZCI->ZCI_FILIAL	:= xFilial("ZCI")
			ZCI->ZCI_ANOREF	:= caAnoRef
			ZCI->ZCI_CLVL	:= cClv
			ZCI->ZCI_DSCLVL	:= Posicione("CTH", 1, xFilial("CTH") + cClv, "CTH_DESC01")
			ZCI->ZCI_CONTA	:= cConta
			ZCI->ZCI_DSCONT	:= Posicione("CT1", 1, xFilial("CT1") + cConta, "CT1_DESC01")
			ZCI->ZCI_GERENC	:= "2"
			ZCI->(MsUnlock())

		EndIf

	EndIf

	RestArea(aAreaCTL)	
	RestArea(aAreaSE5)	
	RestArea(aAreaSA1)	
	RestArea(aAreaSA2)	
	RestArea(aAreaSB1)	
	RestArea(aAreaSN1)	
	RestArea(aAreaSC5)
	RestArea ( xtrArea )

Return