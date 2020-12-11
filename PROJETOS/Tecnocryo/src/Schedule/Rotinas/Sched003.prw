
#Include "Colors.ch"
#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "Tbiconn.ch"
#Include "TopConn.ch"
#Include "Totvs.ch"

#Define CR chr(13)

User Function SCHED003()

	Local cMyEmp   := "01"
	Local cMyFil   := "0201"
	Local aUsu     := {}
	Local cBanco   := ""
	Local cAgencia := ""
	Local cConta   := "" //033 - 3442-8 - 13002487-6
	Local nVlrTot  := 0.00
	Local nW       := 0
	Local _cQuery  := ""
	Local _cAlsQry := GetNextAlias()
	Local oBolSan

	ConOut("" )
	ConOut("--------------------------------------------------------------------------------------------------------------------------" )
	ConOut("[SCHED003]  [Emp.: "+cMyEmp+"] [Fil.: "+cMyFil+"] "+dtoc(date())+" "+time()+" Inicio do Job ..." )

	RPCSetType(3)
	RPCSetEnv(cMyEmp,cMyFil)

	cBanco   := PadR("033", TamSX3("A6_COD")[1])
	cAgencia := PadR("3442", TamSX3("A6_AGENCIA")[1])
	cConta   := PadR("13002487", TamSX3("A6_NUMCON")[1])

	SA6->(DbSetOrder(1))
	SEE->(DbSetOrder(1))
	SA1->(DbSetOrder(1))
	SE1->(DbSetOrder(2))
	SF2->(DbSetOrder(1))

	_cQuery := "SELECT SF2_REG = R_E_C_N_O_ "
	_cQuery += CR
	_cQuery += CR + "FROM "+RetSQLName("SF2")+" SF2 WITH (NOLOCK)"
	_cQuery += CR
	_cQuery += CR + "WHERE"
	_cQuery += CR + "    SF2.F2_FILIAL  = '"+cMyFil+"'"
	_cQuery += CR + "AND ("
	_cQuery += CR + "        (SF2.F2_TIPO    = 'N'"
	_cQuery += CR + "     AND SF2.F2_PREFIXO = 'DEB'"
	_cQuery += CR + "     AND SF2.F2_DUPL    <> ''"
	_cQuery += CR + "     AND SF2.F2_YSCHDEB = 'S'"
	_cQuery += CR + "     AND SF2.F2_YDEBENV <> 'S')"
	_cQuery += CR
	_cQuery += CR + "     OR"
	_cQuery += CR
	_cQuery += CR + "        (SF2.F2_TIPO    = 'N'"
	_cQuery += CR + "     AND SF2.F2_CHVNFE  <> ''"
	_cQuery += CR + "     AND SF2.F2_CHVCLE  = ''"
	_cQuery += CR + "     AND SF2.F2_DUPL    <> ''"
	_cQuery += CR + "     AND SF2.F2_YSCHBOL = 'S'"
	_cQuery += CR + "     AND SF2.F2_YBOLENV <> 'S')"
	_cQuery += CR
	_cQuery += CR + "     OR"
	_cQuery += CR
	_cQuery += CR + "        (SF2.F2_TIPO    = 'N'"
	_cQuery += CR + "     AND SF2.F2_PREFIXO = 'DEB'"
	_cQuery += CR + "     AND SF2.F2_CHVCLE  = ''"
	_cQuery += CR + "     AND SF2.F2_DUPL    <> ''"
	_cQuery += CR + "     AND SF2.F2_YSCHBOL = 'S'"
	_cQuery += CR + "     AND SF2.F2_YBOLENV <> 'S')"
	_cQuery += CR + "    )"
	_cQuery += CR + "AND SF2.D_E_L_E_T_ = ''"
	DBUseArea(.T.,"TOPCONN",TcGenQry(,,strtran(_cQuery,CR," ")),_cAlsQry,.T.,.T.)

	If  SA6->(DbSeek(xFilial("SA6") + cBanco + cAgencia + cConta))
		if SEE->(DbSeek(xFilial("SEE") + SA6->(A6_COD + A6_AGENCIA + A6_NUMCON + "101") ))

			do while !(_cAlsQry)->(eof())

			    SF2->(DBGoTo( (_cAlsQry)->SF2_REG ))

				//nf DEB
				If SF2->F2_TIPO == "N" .And. SF2->F2_PREFIXO == "DEB" .And. !Empty(SF2->F2_DUPL) .And. SF2->F2_YSCHDEB == "S" .And. SF2->F2_YDEBENV != "S"
					If SA1->(DbSeek(xFilial("SA1") + SF2->(F2_CLIENTE + F2_LOJA)))
						If !Empty(SA1->A1_EMAIL) .AND. (alltrim(SA1->A1_EMAIL) <> "@")
							If SE1->(DbSeek(xFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DUPL)))
								oFormDEB := TWFormularioDEB():New()
								aAdd(oFormDEB:aRecSE1, SE1->(Recno()))
								oFormDEB:PopDest()
								oFormDEB:cFile           := SF2->(AllTrim(F2_SERIE) + "_" + AllTrim(F2_DOC))
								oFormDEB:oPrint          := FWMSPrinter():New (oFormDEB:cFile + ".rel", 6, .F., "\spool", .T.,,,, .T.,,, .F.)
								oFormDEB:oPrint:lInJob   := .T.
								oFormDEB:cPathPDF        := "schedule\"
								oFormDEB:oPrint:cPathPDF := oFormDEB:cPathPDF
								oFormDEB:oPrint:SetPortrait()  // ou SetLandscape()
								oFormDEB:cJob            := "SCHED003"
								oFormDEB:cFil            := cMyFil

								For nW := 1 To Len(oFormDEB:aDestinatario)
									oFormDEB:nAnt := nW
									oFormDEB:cDocumento := oFormDEB:aDestinatario[nW][2]

									aEval( oFormDEB:aDestinatario[nW][3], {|x| nVlrTot := nVlrTot + x[5]} )

									oFormDEB:nValorTotal := nVlrTot
									nVlrTot := 0

									oFormDEB:ConfigLayoutCabecalho()
									oFormDEB:ImprimeItens()

									If oFormDEB:lLimitePorPagina
										oFormDEB:ImprimeProdutosPendentes()
									End If
								Next nW

								oFormDEB:AcionaImpressao()

								If oFormDEB:Enviar()
									RecLock("SF2", .F.)
									SF2->F2_YDEBENV := "S"
									SF2->(MsUnLock())
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf

				If (SF2->F2_TIPO == "N" .And. !Empty(SF2->F2_CHVNFE) .And. Empty(SF2->F2_CHVCLE) .And. !Empty(SF2->F2_DUPL) .And. SF2->F2_YSCHBOL == "S" .And. SF2->F2_YBOLENV <> "S") .Or. ;
				(SF2->F2_TIPO  == "N" .And.	SF2->F2_PREFIXO  == "DEB" .And. Empty(SF2->F2_CHVCLE) .And. !Empty(SF2->F2_DUPL) .And. SF2->F2_YSCHBOL == "S" .And. SF2->F2_YBOLENV <> "S")
					If SA1->(DbSeek(xFilial("SA1") + SF2->(F2_CLIENTE + F2_LOJA)))
						If !Empty(SA1->A1_EMAIL) .AND. (alltrim(SA1->A1_EMAIL) <> "@")
							If SE1->(DbSeek(xFilial("SE1") + SF2->(F2_CLIENTE+F2_LOJA+F2_PREFIXO+F2_DUPL)))
								While SE1->(!Eof()) .And. xFilial("SE1") + SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == xFilial("SF2") + SF2->(F2_CLIENTE+F2_LOJA+F2_PREFIXO+F2_DUPL)
									If AllTrim(SE1->E1_ORIGEM) == "MATA460" .And. Empty(SE1->E1_PORTADO)
										oBolSan := TWBolSantan():New()
										oBolSan:PrepTit()//Grava banco agencia conta e gera nosso numero
										oBolSan:Preparar()
										oBolSan:Montar()
										oBolSan:SalvarPDF()
										If oBolSan:Enviar()
											If SF2->F2_YBOLENV != "S"
												RecLock("SF2",.F.)
												SF2->F2_YBOLENV := "S"
												SF2->(MsUnlock())
											End If
										End If
									End If
									SE1->(DbSkip())
								End
							End If
						End If
					End If
				End If

				(_cAlsQry)->(DbSkip())
			End
		End If
	End If

	(_cAlsQry)->(DBCloseArea())

	ConOut("")
	ConOut("[SCHED003]  [Emp.: "+cMyEmp+"] [Fil.: "+cMyFil+"] "+dtoc(date())+" "+time()+" Fim do Job." )
	ConOut("--------------------------------------------------------------------------------------------------------------------------" )
	ConOut("")

	RpcClearEnv()
Return