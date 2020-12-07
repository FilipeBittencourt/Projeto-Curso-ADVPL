User Function Sched004()

	Local cMyEmp   := "01"
	Local cMyFil   := "0101"
	Local aUsu     := {}
	Local cBanco   := ""
	Local cAgencia := ""
	Local cConta   := "" //033 - 3442-8 - 13002487-6
	Local nVlrTot  := 0.00
	Local oBolSan
	Local dEmissao
	Local nW, F2RECNO

	ConOut("" )
	ConOut("--------------------------------------------------------------------------------------------------------------------------" )
	ConOut("[SCHED004]  [Emp.: "+cMyEmp+"] [Fil.: "+cMyFil+"] "+dtoc(date())+" "+time()+" Inicio do Job ..." )

	RPCSetType(3)
	RPCSetEnv(cMyEmp,cMyFil)

	cBanco   := PadR("033", TamSX3("A6_COD")[1])
	cAgencia := PadR("3442", TamSX3("A6_AGENCIA")[1])
	cConta   := PadR("13000408", TamSX3("A6_NUMCON")[1])

	dEmissao := IIF( GetEnvServer() == "TESTE", StoD('20180401'), dDataBase )

	CHKFILE("SA6")
	CHKFILE("SEE")
	CHKFILE("SA1")
	CHKFILE("SE1")
	CHKFILE("SF2")

	SA6->(DbSetOrder(1))
	SEE->(DbSetOrder(1)) // EE_FILIAL, EE_CODIGO, EE_AGENCIA, EE_CONTA, EE_SUBCTA, R_E_C_N_O_, D_E_L_E_T_
	SA1->(DbSetOrder(1))
	SE1->(DbSetOrder(2))
	SF2->(DbSetOrder(1))

	//	SF2->(DbSetFilter({|| F2_FILIAL == cMyFil }, "F2_FILIAL==" + cMyFil))

	BEGINSQL ALIAS "SF2UNION"

		COLUMN F2_RECNO AS NUMERIC(10,0)

		SELECT
		SF2.R_E_C_N_O_ F2_RECNO
		FROM
		%table:SF2% SF2,
		%table:SE1% SE1
		WHERE
		SF2.D_E_L_E_T_ 	=  '' 				AND
		SE1.D_E_L_E_T_ 	=  '' 				AND
		//		F2_EMISSAO	>= %Exp:(dEmissao)% 	AND
		F2_FILIAL 	=  %xFilial:SF2% 	AND
		F2_TIPO 	=  'N' 				And
		F2_PREFIXO 	=  'DEB' 			And
		F2_DUPL 	<> '' 				And
		F2_YSCHDEB 	=  'S' 				And
		F2_YDEBENV 	<> 'S' 				AND
		F2_FILIAL 	= E1_FILIAL 		AND
		F2_PREFIXO	= E1_PREFIXO		AND
		F2_DUPL		= E1_NUM			AND
		F2_CLIENTE	= E1_CLIENTE		AND
		F2_LOJA		= E1_LOJA			AND
		E1_TIPO		= 'NF'			AND
		E1_SALDO 	> 0

		UNION ALL

		SELECT
		SF2.R_E_C_N_O_ F2_RECNO
		FROM
		%table:SF2% SF2,
		%table:SE1% SE1
		WHERE
		SF2.D_E_L_E_T_ 	=  '' 				AND
		SE1.D_E_L_E_T_ 	=  '' 				AND
		//		F2_EMISSAO	>= %Exp:(dEmissao)% 		AND
		F2_FILIAL 	=  %xFilial:SF2% 	AND
		F2_TIPO		= 'N'				AND
		F2_CHVNFE	<> ''				AND
		F2_CHVCLE 	=  ''				AND
		F2_DUPL		<> ''				AND
		F2_YSCHBOL	=  'S'				AND
		F2_YBOLENV	<> 'S'				AND
		F2_FILIAL 	= E1_FILIAL 		AND
		F2_PREFIXO	= E1_PREFIXO		AND
		F2_DUPL		= E1_NUM			AND
		F2_CLIENTE	= E1_CLIENTE		AND
		F2_LOJA		= E1_LOJA			AND
		E1_TIPO		= 'NF'				AND
		E1_SALDO 	> 0

		UNION ALL

		SELECT
		SF2.R_E_C_N_O_ F2_RECNO
		FROM
		%table:SF2% SF2,
		%table:SE1% SE1
		WHERE
		SF2.D_E_L_E_T_ 	=  '' 				AND
		SE1.D_E_L_E_T_ 	=  '' 				AND
		//		F2_EMISSAO	>= %Exp:(dEmissao)% 		AND
		F2_TIPO		= 'N'				AND
		F2_PREFIXO  = 'DEB'				AND
		F2_FILIAL 	=  %xFilial:SF2% 	AND
		F2_CHVNFE	=  ''				AND
		F2_CHVCLE 	=  ''				AND
		F2_DUPL		<> ''				AND
		F2_YSCHBOL	=  'S'				AND
		F2_YBOLENV	<> 'S'				AND
		F2_FILIAL 	= E1_FILIAL 		AND
		F2_PREFIXO	= E1_PREFIXO		AND
		F2_DUPL		= E1_NUM			AND
		F2_CLIENTE	= E1_CLIENTE		AND
		F2_LOJA		= E1_LOJA			AND
		E1_TIPO		= 'NF'			AND
		E1_SALDO 	> 0

	ENDSQL

	dbSelectArea( "SF2UNION" )

	If SA6->(DbSeek(xFilial("SA6") + cBanco + cAgencia + cConta))
		if SEE->(DbSeek(xFilial("SEE") + SA6->(A6_COD + A6_AGENCIA + A6_NUMCON + "101") ))
			SF2->(DbGoTop())

			While SF2UNION->(!Eof())

				F2RECNO := SF2UNION->F2_RECNO
				SF2-> ( dbGoTo( F2RECNO  ) )

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
								oFormDEB:cJob            := "SCHED004"
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
									If AllTrim(SE1->E1_ORIGEM) == "MATA460" //.And. Empty(SE1->E1_PORTADO)
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

				SF2UNION-> ( DbSkip() )

			End
		End If
	End If

	ConOut("")
	ConOut("[SCHED004]  [Emp.: "+cMyEmp+"] [Fil.: "+cMyFil+"] "+dtoc(date())+" "+time()+" Fim do Job." )
	ConOut("--------------------------------------------------------------------------------------------------------------------------" )
	ConOut("")

	RpcClearEnv()
Return
/*
*/