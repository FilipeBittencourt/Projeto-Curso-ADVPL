User Function Sched002()
	Local cMyEmp   := "01"
	Local cMyFil   := "0101"
	Local aUsu     := {}
	Local cBanco   := ""
	Local cAgencia := ""
	Local cConta   := ""
	Local nVlrTot  := 0.00
	Local oFormDEB
	Local cListField := "" 
	Local nW, F2RECNO                                                              

	ConOut("Iniciando U_Sched002(" + cMyEmp + "," + cMyFil + ")")	

	RPCSetType(3)
	RPCSetEnv(cMyEmp,cMyFil)

	//If .T. // PadL(Day(Date()),2,"0") $ GetNewPar("MV_SCHED02", "01_")
	cBanco   := PadR("021", TamSX3("A6_COD")[1])
	cAgencia := PadR("087", TamSX3("A6_AGENCIA")[1])
	cConta   := PadR("20644894", TamSX3("A6_NUMCON")[1])

//	cBanco   := PadR("033", TamSX3("A6_COD")[1])
//	cAgencia := PadR("3442", TamSX3("A6_AGENCIA")[1])
//	cConta   := PadR("13000408", TamSX3("A6_NUMCON")[1])

	SA6->(DbSetOrder(1))
	If !SA6->(DbSeek(xFilial("SA6") + cBanco + cAgencia + cConta))
		Return
	End If

	SA1->(DbSetOrder(1))
	SE1->(DbSetOrder(2))
	SF2->(DbSetOrder(1))	    
	SF2->(DbGoTop())

	SF2->(DbSetFilter({|| F2_FILIAL == cMyFil }, "F2_FILIAL==" + cMyFil))

	//	SX3-> ( dbSetOrder( 1  ) )
	//	SX3-> ( dbSeek( "SF2" ) )
	//	SX3-> ( dbEval( { || cListField += IIF( ! Empty(cListField), ",", "" ) + AllTrim( X3_CAMPO ) }, {|| X3_CONTEXT <> 'V' }, { || ! EOF() .AND. X3_ARQUIVO == 'SF2' .AND. ! DELETED() }  ) )

	//	cListField := "%" + cListField + "%"

	//	SF2->( dbCloseArea() )

	BEGINSQL ALIAS "SF2UNION"

		COLUMN F2_RECNO AS NUMERIC(10,0)

		SELECT  
		R_E_C_N_O_ F2_RECNO
		FROM 
		%table:SF2% 
		WHERE 
		D_E_L_E_T_ 	=  '' 				AND 
		F2_EMISSAO	>= %Exp:(dDataBase-3)% 		AND
		F2_FILIAL 	=  %xFilial:SF2% 	AND 
		F2_TIPO 	=  'N' 				And 
		F2_PREFIXO 	=  'DEB' 			And 
		F2_DUPL 	<> '' 				And
		F2_YSCHDEB 	=  'S' 				And 
		F2_YDEBENV 	<> 'S'

		UNION ALL

		SELECT  
		R_E_C_N_O_ F2_RECNO
		FROM 
		%table:SF2% 
		WHERE 
		D_E_L_E_T_ 	=  '' 				AND 
		F2_EMISSAO	>= %Exp:(dDataBase-3)% 		AND
		F2_FILIAL 	=  %xFilial:SF2% 	AND 
		F2_TIPO		= 'N'				AND
		F2_CHVNFE	<> ''				AND
		F2_CHVCLE 	=  ''				AND
		F2_DUPL		<> ''				AND
		F2_YSCHBOL	=  'S'				AND
		F2_YBOLENV	<> 'S'

		UNION ALL

		SELECT  
		R_E_C_N_O_ F2_RECNO
		FROM 
		%table:SF2% 
		WHERE 
		D_E_L_E_T_ 	=  '' 				AND 
		F2_EMISSAO	>= %Exp:(dDataBase-3)% 		AND
		F2_TIPO		= 'N'				AND
		F2_PREFIXO  = 'DEB'				AND
		F2_FILIAL 	=  %xFilial:SF2% 	AND 
		F2_CHVNFE	=  ''				AND
		F2_CHVCLE 	=  ''				AND
		F2_DUPL		<> ''				AND
		F2_YSCHBOL	=  'S'				AND
		F2_YBOLENV	<> 'S'

	ENDSQL

	DBSELECTAREA( "SF2UNION" )

	While SF2UNION->( ! Eof() )

		F2RECNO := SF2UNION->F2_RECNO

		SF2-> ( dbGoTo( F2RECNO  ) )

		//nf DEB
		If SF2->F2_TIPO == "N" .And. SF2->F2_PREFIXO == "DEB" .And. !Empty(SF2->F2_DUPL) .And. SF2->F2_YSCHDEB == "S" .And. SF2->F2_YDEBENV != "S"
			If SA1->(DbSeek(xFilial("SA1") + SF2->(F2_CLIENTE + F2_LOJA)))			
				If !Empty(SA1->A1_EMAIL)
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


		If (SF2->F2_TIPO  == "N" .And. !Empty(SF2->F2_CHVNFE) .And. Empty(SF2->F2_CHVCLE)     .And. !Empty(SF2->F2_DUPL) .And. SF2->F2_YSCHBOL == "S" .And. SF2->F2_YBOLENV <> "S") .Or.;
		(SF2->F2_TIPO  == "N" .And.	SF2->F2_PREFIXO  == "DEB" .And. Empty(SF2->F2_CHVCLE) .And. !Empty(SF2->F2_DUPL) .And. SF2->F2_YSCHBOL == "S" .And. SF2->F2_YBOLENV <> "S")

			If SA1->(DbSeek(xFilial("SA1") + SF2->(F2_CLIENTE + F2_LOJA)))
				If !Empty(SA1->A1_EMAIL)
					If SE1->(DbSeek(xFilial("SE1") + SF2->(F2_CLIENTE+F2_LOJA+F2_PREFIXO+F2_DUPL)))
						While SE1->(!Eof()) .And. xFilial("SE1") + SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == xFilial("SF2") + SF2->(F2_CLIENTE+F2_LOJA+F2_PREFIXO+F2_DUPL)
							If AllTrim(SE1->E1_ORIGEM) == "MATA460"
								ProcessaNN()
								SalvaPDF(@aUsu)
								RecLock("SF2")
								SF2->F2_YBOLENV := "S"
								MsUnlock()
							End If
							SE1->(DbSkip())
						End 
					End If
				End If
			End If
		End If

		SF2UNION-> ( DbSkip() )

	End

	IF Len(aUsu) > 0 
		U_EnvEmail(aUsu)
		ConOut("Registro processado...:" + Alltrim( Str( Len(aUsu) ) ) )
	ELSE
		ConOut("Nenhuma registro processado...")	
	ENDIF	
	
	//End If	

	//	IF SELECT( "SF2" ) > 0
	//		SF2-> ( dbCloseArea() )
	//		ChkFile( "SF2" )
	//	ENDIF

	ConOut("Fechando U_Sched002(" + cMyEmp + "," + cMyFil + ")")	
	RpcClearEnv()

Return
/*
*/
Static Function ProcessaNN()
	Local cNossoNumero := SE1->E1_IDCNAB

	If Empty(SE1->E1_IDCNAB) .OR. (SE1->E1_PORTADO <> "021")
		cNossoNumero :=  U_TCnabNsN("021")
	EndIf

	RecLock("SE1",.F.)
	SE1->E1_PORTADO := SA6->A6_COD
	SE1->E1_AGEDEP  := SA6->A6_AGENCIA
	SE1->E1_CONTA 	:= SA6->A6_NUMCON
	SE1->E1_PORCJUR := 2
	SE1->E1_VALJUR  := SE1->E1_VALOR * (0.2/100) 
	SE1->E1_NUMBCO 	:= cNossoNumero 		
	MsUnLock()
Return
/*
*/
Static Function SalvaPDF(aUsu)
	Local nVlrAbat    := 0
	Local cNroDocRea  := ""
	Local cFile       := "Bol" + AllTrim(SE1->E1_IDCNAB)
	Local cPathServer := "schedule\"
	Local cPathLocal  := GetSrvProfString("RootPath", "") + cPathServer
	Local cNomeBanco  := "BANCO BANESTES"
	local cNroDoc     := Transform(SE1->E1_IDCNAB,"@R 99999999-99")
	local cEspecie    := "DM"
	Local cMsg        := ""
	Local cAssunto    := ""
	Local cCodCar     := 'C.ESCRI'//"11"
	Local cTipo       := "3"
	Local aBolTextEXC := {"Após o vencimento cobrar juros de 1% am","Após Vencimento Cobrar Multa de 2% ","PROTESTAR APOS 3 DIAS DO VENCIMENTO"}
	Local aBolText1   := {"MORA DIARIA DE 0,33%","PROTESTO AUTOMATICO APOS 05 DIAS DE VENCIMENTO"}
	Local aDadosBanco := {SA6->A6_COD,cNomeBanco,SA6->A6_AGENCIA,SA6->A6_NUMCON,SA6->A6_DVCTA,cCodCar}
	Local aDadosEmp   := {}
	Local aBolText    := {}
	Local aDatSacado  := {}
	Local oPrint

	Private _cLinDig  := ""
	Private _cCodBar  := ""
	Private ASBACE    := ""

	If File(cPathServer + cFile + ".pdf")
		FErase(cPathServer + cFile + ".pdf",,.F.)
	End If

	aAdd(aDadosEmp,SM0->M0_NOMECOM)
	aAdd(aDadosEmp,SM0->M0_ENDCOB)
	aAdd(aDadosEmp,AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB)
	aAdd(aDadosEmp,"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3))
	aAdd(aDadosEmp,"PABX/FAX: "+SM0->M0_TEL)
	aAdd(aDadosEmp,"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+Subs(SM0->M0_CGC,13,2))
	aAdd(aDadosEmp,"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3))

	aAdd(aBolText,"APOS O VENCIMENTO COBRAR JUROS DE R$ ")
	aAdd(aBolText,"APOS O VENCIMENTO COBRAR MULTA DE R$ ")
	aAdd(aBolText,"SUJEITO A PROTESTO APOS 05 (CINCO) DIAS DO VENCIMENTO")
	aAdd(aBolText,"NFe: ")

	aAdd(aDatSacado,AllTrim(SA1->A1_NOME))
	aAdd(aDatSacado,AllTrim(SA1->A1_COD)+"-"+SA1->A1_LOJA)

	If Empty(SA1->A1_ENDCOB)
		aAdd(aDatSacado,AllTrim(SA1->A1_END)+"-"+AllTrim(SA1->A1_BAIRRO))
		aAdd(aDatSacado,AllTrim(SA1->A1_MUN))
		aAdd(aDatSacado,SA1->A1_EST)
		aAdd(aDatSacado,SA1->A1_CEP)
	Else
		aAdd(aDatSacado,AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC))
		aAdd(aDatSacado,AllTrim(SA1->A1_MUNC))
		aAdd(aDatSacado,SA1->A1_ESTC)
		aAdd(aDatSacado,SA1->A1_CEPC)
	Endif

	aAdd(aDatSacado,SA1->A1_CGC)
	aAdd(aDatSacado,SA1->A1_PESSOA)

	nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

	fCodBarBane(aDadosBanco[1]+cTipo,aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],"",(SE1->E1_VALOR-nVlrAbat),SE1->E1_VENCTO)

	aDadosTit	:= {SE1->E1_NUM+SE1->E1_PARCELA,;  				// [1] Número do título
	SE1->E1_EMISSAO,;  				// [2] Data da emissão do título
	dDataBase,;  					// [3] Data da emissão do boleto
	SE1->E1_VENCTO,;  				// [4] Data do vencimento
	(SE1->E1_SALDO - nVlrAbat),; 	// [5] Valor do título
	cNroDoc,;  						// [6] Nosso número (Ver fórmula para calculo)
	SE1->E1_PREFIXO,;  				// [7] Prefixo da NF
	cEspecie,;  					// [8] Tipo do Titulo
	SE1->E1_PORCJUR}   				// [9] Juros ao dia

	oPrint          := FWMsPrinter():New (cFile+".rel",6,.T.,cPathServer,.T.,,,,.T.,,,.F.)
	oPrint:cPathPDF := cPathServer

	oPrint:SetPortrait() // ou SetLandscape()
	oPrint:SetPaperSize(2) //A4
	//oPrint:SetMargin(60,60,60,60)

	fPrintBol(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aBolText1,aBolTextEXC,_cLinDig,_cCodBar,cNroDocRea, SE1->E1_VALJUR,SE1->E1_PORCJUR, SE1->E1_ACRESC ,SE1->E1_DECRESC)

	oPrint:Print()

	cAssunto := "Boleto Ref. NF " + AllTrim(SF2->F2_DOC) + " - Parcela: " + AllTrim(SE1->E1_PARCELA)

	cMsg := "A<br/>"
	cMsg += AllTrim(SA1->A1_NOME) + "<br/><br/>"
	cMsg += "Prezado, segue boleto referente a NF " + AllTrim(SF2->F2_DOC)
	cMsg += " com vencimento em " + DToC(SE1->E1_VENCTO) + ".<br/><br/>"
	cMsg += "Estamos a disposição para maiores esclarecimentos.<br/><br/>"
	cMsg += "Atenciosamente,<br/>"

	aAdd(aUsu, {"contato@tecnocryo.com.br ; " + AllTrim(SA1->A1_EMAIL), cAssunto, cMsg, cPathServer + cFile + ".pdf"})
Return

Static Function fPrintBol(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aBolText1,aBolTextEXC,_cLinDig,_cCodBar,cNroDocRea,nVlJuros,nPorJuros,nAcres,nDeducao)
	Local nI           := 0
	//Local cLogo        := GetSrvProfString("RootPath", "") + "Logo\Banestes.bmp"
	Local cLogo        := "Logo\Banestes.bmp"

	Private oFont8
	Private oFont11c
	Private oFont11n
	Private oFont10
	Private oFont14
	Private oFont16n
	Private oFont15
	Private oFont14n
	Private oFont24
	Private aRelaNotas := {}

	oFont8  		:= TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont11c 		:= TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont11n 		:= TFont():New("Arial",9,11,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont10  		:= TFont():New("Arial",9,8,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12n  		:= TFont():New("Arial",9,12,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont12  		:= TFont():New("Arial",9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont13  		:= TFont():New("Arial",9,13,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14  		:= TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14n 		:= TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont15  		:= TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont15n 		:= TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont16n 		:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont20  		:= TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont20n  		:= TFont():New("Arial",9,20,.T.,.F.,5,.T.,5,.T.,.F.)	
	oFont21  		:= TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont24  		:= TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont24n  		:= TFont():New("Arial",9,24,.T.,.F.,5,.T.,5,.T.,.F.)	

	cNomeBanco := aDadosBanco[2]	

	oPrint:StartPage()   // Inicia uma nova página

	/******************/
	/* PRIMEIRA PARTE */
	/******************/
	nRow1 := 060
	nCol1 := 100

	oPrint:SayBitmap(nRow1 - 0010, nCol1, cLogo, 340, 090) //logo
	oPrint:Line(nRow1, nCol1 + 0400, nRow1 + 0080, nCol1 + 0400) //v 
	oPrint:Say(nRow1 + 0070, nCol1 + 0415, aDadosBanco[1] + "-3", oFont24)		// [1]Numero do Banco		
	oPrint:Line(nRow1, nCol1 + 0610, nRow1 + 0080, nCol1 + 0610) //v 
	oPrint:Say(nRow1 + 0070, nCol1 + 1800, "Comprovante de Entrega", oFont12)  //	

	//Linhs verticias do quadro 01
	oPrint:Line(nRow1 + 0080, nCol1, nRow1 + 0400, nCol1)        //v borda esquerda 01
	oPrint:Line(nRow1 + 0080, nCol1 + 0950, nRow1 + 0400, nCol1 + 0950) //v 02
	oPrint:Line(nRow1 + 0240, nCol1 + 1300, nRow1 + 0400, nCol1 + 1300) //v 03	
	oPrint:Line(nRow1 + 0080, nCol1 + 1400, nRow1 + 0240, nCol1 + 1400) //v 04
	oPrint:Line(nRow1 + 0080, nCol1 + 1800, nRow1 + 0400, nCol1 + 1800) //v 05
	oPrint:Line(nRow1 + 0080, nCol1 + 2200, nRow1 + 0400, nCol1 + 2200)  //v borda direita

	//Linhs horizontais do quadro 01
	oPrint:Line(nRow1 + 0080, nCol1, nRow1 + 0080, nCol1 + 2200) //h 01
	oPrint:Line(nRow1 + 0160, nCol1, nRow1 + 0160, nCol1 + 1800) //h 02
	oPrint:Line(nRow1 + 0240, nCol1, nRow1 + 0240, nCol1 + 1800) //h 03
	oPrint:Line(nRow1 + 0320, nCol1 + 0950, nRow1 + 0320, nCol1 + 1800) //h 04
	oPrint:Line(nRow1 + 0400, nCol1, nRow1 + 0400, nCol1 + 2200) //h 05
	//
	oPrint:Say(nRow1 + 0110, nCol1 + 0010, "Cedente", oFont12n)
	oPrint:Say(nRow1 + 0145, nCol1 + 0010 ,aDadosEmp[1], oFont12)				//Nome + CNPJ

	oPrint:Say(nRow1 + 0110, nCol1 + 0960, "Agência/Código Cedente", oFont12n)
	cString := AllTrim(aDadosBanco[3]) + "/" + Transform(aDadosBanco[4],"@R 99.999.999")
	oPrint:Say(nRow1 + 0145, nCol1 + 0960, cString, oFont12) //Ag, cod cedente

	oPrint:Say(nRow1 + 0110, nCol1 + 1410, "Nro.Documento", oFont12n)
	oPrint:Say(nRow1 + 0145, nCol1 + 1410, aDadosTit[7] + aDadosTit[1], oFont12)//Prefixo +Numero+Parcela
	//
	oPrint:Say(nRow1 + 0190, nCol1 + 0010, "Sacado", oFont12n)
	oPrint:Say(nRow1 + 0225, nCol1 + 0010, aDatSacado[1], oFont12)			//Nome

	oPrint:Say(nRow1 + 0190, nCol1 + 0960, "Vencimento", oFont12n)
	oPrint:Say(nRow1 + 0225, nCol1 + 0960, StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4), oFont12)

	oPrint:Say(nRow1 + 0190, nCol1 + 1410, "(=)Valor do Documento", oFont12n)
	oPrint:Say(nRow1 + 0225, nCol1 + 1410, AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")), oFont12)
	//
	oPrint:Say(nRow1 + 0270, nCol1 + 0010, "Recebi(emos) o bloqueto/título", oFont12)
	oPrint:Say(nRow1 + 0320, nCol1 + 0010, "com as características acima.", oFont12)
	//
	oPrint:Say(nRow1 + 0270, nCol1 + 0960, "Data", oFont12n)
	oPrint:Say(nRow1 + 0270, nCol1 + 1310, "Assinatura", oFont12n)
	//
	oPrint:Say(nRow1 + 0350, nCol1 + 0960, "Data", oFont12n)
	oPrint:Say(nRow1 + 0350, nCol1 + 1310, "Entregador", oFont12n)
	//	
	oPrint:Say(nRow1 + 0110, nCol1 + 1810, "(  )Mudou-se", oFont12n)
	oPrint:Say(nRow1 + 0145, nCol1 + 1810, "(  )Ausente", oFont12n)
	oPrint:Say(nRow1 + 0180, nCol1 + 1810, "(  )Não existe nº indicado", oFont12n)
	oPrint:Say(nRow1 + 0215, nCol1 + 1810, "(  )Recusado", oFont12n)
	oPrint:Say(nRow1 + 0250, nCol1 + 1810, "(  )Não procurado", oFont12n)
	oPrint:Say(nRow1 + 0285, nCol1 + 1810, "(  )Endereço insuficiente", oFont12n)
	oPrint:Say(nRow1 + 0320, nCol1 + 1810, "(  )Desconhecido", oFont12n)
	oPrint:Say(nRow1 + 0355, nCol1 + 1810, "(  )Falecido", oFont12n)
	oPrint:Say(nRow1 + 0390, nCol1 + 1810, "(  )Outros(anotar no verso)", oFont12n)

	/*****************/
	/* SEGUNDA PARTE */
	/*****************/
	nRow2 := 0480

	oPrint:SayBitmap(nRow2 - 0010, nCol1, cLogo, 340, 090) //logo
	oPrint:Line(nRow2, nCol1 + 0400, nRow2 + 0080, nCol1 + 0400) //v 
	oPrint:Say(nRow2 + 0070, nCol1 + 0415, aDadosBanco[1] + "-3", oFont24)		// [1]Numero do Banco		
	oPrint:Line(nRow2, nCol1 + 0610, nRow2 + 0080, nCol1 + 0610) //v 
	oPrint:Say(nRow2 + 0070, nCol1 + 0620, _cLinDig, oFont20n)
	oPrint:Say(nRow2 + 0020, nCol1 + 1800, "Recibo do Sacado", oFont12)  //	

	oPrint:Line(nRow2 + 0080, nCol1, nRow2 + 0910, nCol1)        //v borda esquerda 01
	oPrint:Line(nRow2 + 0240, nCol1 + 0395, nRow2 + 0380, nCol1 + 0395) //v 02
	oPrint:Line(nRow2 + 0310, nCol1 + 0645, nRow2 + 0380, nCol1 + 0645) //v 03
	oPrint:Line(nRow2 + 0240, nCol1 + 0895, nRow2 + 0380, nCol1 + 0895) //v 04
	oPrint:Line(nRow2 + 0240, nCol1 + 1195, nRow2 + 0310, nCol1 + 1195) //v 05 ACEITE
	oPrint:Line(nRow2 + 0240, nCol1 + 1375, nRow2 + 0380, nCol1 + 1375) //v 06 DATA PROCESSAMENTO	
	oPrint:Line(nRow2 + 0080, nCol1 + 1700, nRow2 + 0730, nCol1 + 1700) //v 07	VENCIMENTO
	oPrint:Line(nRow2 + 0080, nCol1 + 2200, nRow2 + 0910, nCol1 + 2200) //v borda esquerda 01	

	//Linhs horizontais do quadro 02
	oPrint:Line(nRow2 + 0080, nCol1, nRow2 + 0080, nCol1 + 2200) //h 01
	oPrint:Line(nRow2 + 0160, nCol1, nRow2 + 0160, nCol1 + 2200) //h 02
	oPrint:Line(nRow2 + 0240, nCol1, nRow2 + 0240, nCol1 + 2200) //h 03
	oPrint:Line(nRow2 + 0310, nCol1, nRow2 + 0310, nCol1 + 2200) //h 04
	oPrint:Line(nRow2 + 0380, nCol1, nRow2 + 0380, nCol1 + 2200) //h 05

	oPrint:Line(nRow2 + 0450, nCol1 + 1700, nRow2 + 0450, nCol1 + 2200) //h 06
	oPrint:Line(nRow2 + 0520, nCol1 + 1700, nRow2 + 0520, nCol1 + 2200) //h 07
	oPrint:Line(nRow2 + 0590, nCol1 + 1700, nRow2 + 0590, nCol1 + 2200) //h 08
	oPrint:Line(nRow2 + 0660, nCol1 + 1700, nRow2 + 0660, nCol1 + 2200) //h 09

	oPrint:Line(nRow2 + 0730, nCol1, nRow2 + 0730, nCol1 + 2200) //h 10
	oPrint:Line(nRow2 + 0910, nCol1, nRow2 + 0910, nCol1 + 2200) //h 11					
	//
	oPrint:Say(nRow2 + 0110, nCol1 + 0010, "Local de Pagamento", oFont12n)
	oPrint:Say(nRow2 + 0145, nCol1 + 0010, "PREFERENCIALMENTE NA REDE BANESTES", oFont12)	

	oPrint:Say(nRow2 + 0110, nCol1 + 1710, "Vencimento", oFont12n)
	cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
	nCol    := 1880+(374-(len(cString)*22))
	oPrint:Say(nRow2 + 0145, nCol, cString, oFont12)
	//
	oPrint:Say(nRow2 + 0190, nCol1 + 0010, "Cedente", oFont12n)
	oPrint:Say(nRow2 + 0225, nCol1 + 0010, aDadosEmp[1]+" - "+aDadosEmp[6], oFont12) //Nome + CNPJ

	oPrint:Say(nRow2 + 0190, nCol1 + 1710, "Agência/Código Cedente", oFont12n)
	cString := AllTrim(aDadosBanco[3])+"/"+Transform(aDadosBanco[4],"@R 99.999.999")
	nCol    := 1880+(374-(len(cString)*22))
	oPrint:Say(nRow2 + 0225, nCol, cString, oFont12)    
	//
	oPrint:Say(nRow2 + 0270, nCol1 + 0010, "Data do Documento", oFont12n)
	oPrint:Say(nRow2 + 0305, nCol1 + 0010, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont12)

	oPrint:Say(nRow2 + 0270, nCol1 + 0405, "Nro.Documento", oFont12n)
	oPrint:Say(nRow2 + 0305, nCol1 + 0505, IIF(!Empty(aDadosTit[7]),aDadosTit[7]+"-","")+Alltrim(Substr(aDadosTit[1],1,9))+IIF(!Empty(Substr(aDadosTit[1],10,1)),"-"+Substr(aDadosTit[1],10,1),""), oFont12) //Prefixo +Numero+Parcela

	oPrint:Say(nRow2 + 0270, nCol1 + 0905, "Espécie Doc.", oFont12n)
	oPrint:Say(nRow2 + 0305, nCol1 + 0905, aDadosTit[8], oFont12) //Tipo do Titulo

	oPrint:Say(nRow2 + 0270, nCol1 + 1205, "Aceite", oFont12n)
	oPrint:Say(nRow2 + 0305, nCol1 + 1300, "N", oFont12)

	oPrint:Say(nRow2 + 0270, nCol1 + 1385, "Data do Processamento", oFont12n)
	oPrint:Say(nRow2 + 0305, nCol1 + 1450 ,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +;
	"/"+ Right(Str(Year(aDadosTit[3])),4),oFont12) // Data impressao

	oPrint:Say(nRow2 + 0270, nCol1 + 1710, "Nosso Número", oFont12n)
	cString := aDadosTit[6]
	nCol    := 1880+(374-(len(cString)*22))
	oPrint:Say(nRow2 + 0305, nCol, cString, oFont12)
	//     
	oPrint:Say(nRow2 + 0340, nCol1 + 0010, "Uso do Banco", oFont12n)
	oPrint:Say(nRow2 + 0340, nCol1 + 0405, "Carteira", oFont12n)
	oPrint:Say(nRow2 + 0375, nCol1 + 0455, aDadosBanco[6], oFont12)
	oPrint:Say(nRow2 + 0340, nCol1 + 0655, "Espécie", oFont12n)
	oPrint:Say(nRow2 + 0375, nCol1 + 0705, "R$", oFont12)
	oPrint:Say(nRow2 + 0340, nCol1 + 0905, "Quantidade", oFont12n)
	oPrint:Say(nRow2 + 0340, nCol1 + 1385, "Valor", oFont12n)
	oPrint:Say(nRow2 + 0340, nCol1 + 1710, "(=)Valor do Documento", oFont12n)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
	nCol := 1880+(374-(len(cString)*22))
	oPrint:Say(nRow2 + 0375, nCol, cString, oFont12)
	//
	oPrint:Say(nRow2 + 0410, nCol1 + 0010, "INSTRUÇÕES (DE RESPONSABILIDADE DO CEDENTE)", oFont12n)
	oPrint:Say(nRow2 + 0480, nCol1 + 0010, aBolText1[1], oFont12)
	oPrint:Say(nRow2 + 0515, nCol1 + 0010, aBolText1[2], oFont12)
	oPrint:Say(nRow2 + 0725, nCol1 + 0010, 'CHAVE ASBACE:' + Transform(M->ASBACE, '@R 9999.9999.9999.9999.9999.9999') + '  R.V.A.', oFont12)
	//
	oPrint:Say(nRow2 + 0410, nCol1 + 1710, "(-)Desconto/Abatimento", oFont12n)
	oPrint:Say(nRow2 + 0480, nCol1 + 1710, "(-)Outras Deduções", oFont12n)
	oPrint:Say(nRow2 + 0550, nCol1 + 1710, "(+)Mora/Multa", oFont12n)
	oPrint:Say(nRow2 + 0620, nCol1 + 1710, "(+)Outros Acréscimos", oFont12n)
	oPrint:Say(nRow2 + 0690, nCol1 + 1710, "(=)Valor Cobrado", oFont12n)
	//
	oPrint:Say(nRow2 + 0760, nCol1 + 0010, "Sacado", oFont12n)
	cCNPJ_CPF := ""
	If aDatSacado[8] = "J"
		cCNPJ_CPF := SPACE(10)+"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99") // CGC
	Else
		cCNPJ_CPF :=SPACE(10)+"CPF.: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99") 	// CPF
	EndIf
	oPrint:Say(nRow2 + 0795, nCol1 + 0010, aDatSacado[1] + " (" + aDatSacado[2] + ")" + cCNPJ_CPF, oFont12) // RAZAO+CODIGO+CNPJ
	oPrint:Say(nRow2 + 0830, nCol1 + 0010 ,aDatSacado[3], oFont12)

	oPrint:Say(nRow2 + 0865, nCol1 + 0010, "CEP.: " + aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont12) // CEP+Cidade+Estado
	oPrint:Say(nRow2 + 0865, nCol1 + 0600, aDadosTit[6], oFont12)

	oPrint:Say(nRow2 + 0900, nCol1 + 0010 , "Sacador/Avalista", oFont12n)
	oPrint:Say(nRow2 + 0900, nCol1 + 1710, "Código de baixa", oFont12n)

	oPrint:Say(nRow2 + 0940, nCol1 + 1400, "Autenticação Mecânica", oFont12n)    
	//     FWMsBar(cTypeBar,nRow,nCol,cCode   ,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)-->	    
	//oPrint:FWMsBar("INT25" ,0036,0002,_cCodBar,oPrint,.F.   ,     ,.T.  ,0.025 ,1.2    ,.F.    ,     ,     ,.F.   ,1       ,1        ,)
	//MSBAR3("INT25",15.85,1,_cCodBar,oPrint,.F.,Nil,.T.,0.028,1.02,Nil,Nil,Nil,.F.) //Impressora Laser

	/******************/
	/* TERCEIRA PARTE */
	/******************/
	nRow3 := 1620

	//Imprime linha de corte da ficha de compensacao
	For nI := 100 to 2300 step 50
		oPrint:Line(nRow3 - 0020, nI, nRow3 - 00020, nI + 30)
	Next nI

	oPrint:SayBitmap(nRow3 - 0010, nCol1, cLogo, 340, 090) //logo
	oPrint:Line(nRow3, nCol1 + 0400, nRow3 + 0080, nCol1 + 0400) //v 
	oPrint:Say(nRow3 + 0070, nCol1 + 0415, aDadosBanco[1] + "-3", oFont24)		// [1]Numero do Banco		
	oPrint:Line(nRow3, nCol1 + 0610, nRow3 + 0080, nCol1 + 0610) //v 
	oPrint:Say(nRow3 + 0070, nCol1 + 0620, _cLinDig, oFont20n)
	//oPrint:Say(nRow3 + 0020, nCol1 + 1800, "Recibo do Sacado", oFont12)  //	

	oPrint:Line(nRow3 + 0080, nCol1, nRow3 + 0945, nCol1)        //v borda esquerda 01
	oPrint:Line(nRow3 + 0240, nCol1 + 0395, nRow3 + 0380, nCol1 + 0395) //v 02
	oPrint:Line(nRow3 + 0310, nCol1 + 0645, nRow3 + 0380, nCol1 + 0645) //v 03
	oPrint:Line(nRow3 + 0240, nCol1 + 0895, nRow3 + 0380, nCol1 + 0895) //v 04
	oPrint:Line(nRow3 + 0240, nCol1 + 1195, nRow3 + 0310, nCol1 + 1195) //v 05 ACEITE
	oPrint:Line(nRow3 + 0240, nCol1 + 1375, nRow3 + 0380, nCol1 + 1375) //v 06 DATA PROCESSAMENTO	
	oPrint:Line(nRow3 + 0080, nCol1 + 1700, nRow3 + 0730, nCol1 + 1700) //v 07	VENCIMENTO
	oPrint:Line(nRow3 + 0080, nCol1 + 2200, nRow3 + 0945, nCol1 + 2200) //v borda esquerda 01	

	//Linhs horizontais do quadro 02
	oPrint:Line(nRow3 + 0080, nCol1, nRow3 + 0080, nCol1 + 2200) //h 01
	oPrint:Line(nRow3 + 0160, nCol1, nRow3 + 0160, nCol1 + 2200) //h 02
	oPrint:Line(nRow3 + 0240, nCol1, nRow3 + 0240, nCol1 + 2200) //h 03
	oPrint:Line(nRow3 + 0310, nCol1, nRow3 + 0310, nCol1 + 2200) //h 04
	oPrint:Line(nRow3 + 0380, nCol1, nRow3 + 0380, nCol1 + 2200) //h 05

	oPrint:Line(nRow3 + 0450, nCol1 + 1700, nRow3 + 0450, nCol1 + 2200) //h 06
	oPrint:Line(nRow3 + 0520, nCol1 + 1700, nRow3 + 0520, nCol1 + 2200) //h 07
	oPrint:Line(nRow3 + 0590, nCol1 + 1700, nRow3 + 0590, nCol1 + 2200) //h 08
	oPrint:Line(nRow3 + 0660, nCol1 + 1700, nRow3 + 0660, nCol1 + 2200) //h 09

	oPrint:Line(nRow3 + 0730, nCol1, nRow3 + 0730, nCol1 + 2200) //h 10
	oPrint:Line(nRow3 + 0945, nCol1, nRow3 + 0945, nCol1 + 2200) //h 11					
	//
	oPrint:Say(nRow3 + 0110, nCol1 + 0010, "Local de Pagamento", oFont12n)
	oPrint:Say(nRow3 + 0145, nCol1 + 0010, "PREFERENCIALMENTE NA REDE BANESTES", oFont12)	

	oPrint:Say(nRow3 + 0110, nCol1 + 1710, "Vencimento", oFont12n)
	cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
	nCol    := 1880+(374-(len(cString)*22))
	oPrint:Say(nRow3 + 0145, nCol, cString, oFont12)
	//
	oPrint:Say(nRow3 + 0190, nCol1 + 0010, "Cedente", oFont12n)
	oPrint:Say(nRow3 + 0225, nCol1 + 0010, aDadosEmp[1]+" - "+aDadosEmp[6], oFont12) //Nome + CNPJ

	oPrint:Say(nRow3 + 0190, nCol1 + 1710, "Agência/Código Cedente", oFont12n)
	cString := AllTrim(aDadosBanco[3])+"/"+Transform(aDadosBanco[4],"@R 99.999.999")
	nCol    := 1880+(374-(len(cString)*22))
	oPrint:Say(nRow3 + 0225, nCol, cString, oFont12)    
	//
	oPrint:Say(nRow3 + 0270, nCol1 + 0010, "Data do Documento", oFont12n)
	oPrint:Say(nRow3 + 0305, nCol1 + 0010, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont12)

	oPrint:Say(nRow3 + 0270, nCol1 + 0405, "Nro.Documento", oFont12n)
	oPrint:Say(nRow3 + 0305, nCol1 + 0505, IIF(!Empty(aDadosTit[7]),aDadosTit[7]+"-","")+Alltrim(Substr(aDadosTit[1],1,9))+IIF(!Empty(Substr(aDadosTit[1],10,1)),"-"+Substr(aDadosTit[1],10,1),""), oFont12) //Prefixo +Numero+Parcela

	oPrint:Say(nRow3 + 0270, nCol1 + 0905, "Espécie Doc.", oFont12n)
	oPrint:Say(nRow3 + 0305, nCol1 + 0905, aDadosTit[8], oFont12) //Tipo do Titulo

	oPrint:Say(nRow3 + 0270, nCol1 + 1205, "Aceite", oFont12n)
	oPrint:Say(nRow3 + 0305, nCol1 + 1300, "N", oFont12)

	oPrint:Say(nRow3 + 0270, nCol1 + 1385, "Data do Processamento", oFont12n)
	oPrint:Say(nRow3 + 0305, nCol1 + 1450 ,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +;
	"/"+ Right(Str(Year(aDadosTit[3])),4),oFont12) // Data impressao

	oPrint:Say(nRow3 + 0270, nCol1 + 1710, "Nosso Número", oFont12n)
	cString := aDadosTit[6]
	nCol    := 1880+(374-(len(cString)*22))
	oPrint:Say(nRow3 + 0305, nCol, cString, oFont12)
	//     
	oPrint:Say(nRow3 + 0340, nCol1 + 0010, "Uso do Banco", oFont12n)
	oPrint:Say(nRow3 + 0340, nCol1 + 0405, "Carteira", oFont12n)
	oPrint:Say(nRow3 + 0375, nCol1 + 0455, aDadosBanco[6], oFont12)
	oPrint:Say(nRow3 + 0340, nCol1 + 0655, "Espécie", oFont12n)
	oPrint:Say(nRow3 + 0375, nCol1 + 0705, "R$", oFont12)
	oPrint:Say(nRow3 + 0340, nCol1 + 0905, "Quantidade", oFont12n)
	oPrint:Say(nRow3 + 0340, nCol1 + 1385, "Valor", oFont12n)
	oPrint:Say(nRow3 + 0340, nCol1 + 1710, "(=)Valor do Documento", oFont12n)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
	nCol := 1880+(374-(len(cString)*22))
	oPrint:Say(nRow3 + 0375, nCol, cString, oFont12)
	//
	oPrint:Say(nRow3 + 0410, nCol1 + 0010, "INSTRUÇÕES (DE RESPONSABILIDADE DO CEDENTE)", oFont12n)
	oPrint:Say(nRow3 + 0480, nCol1 + 0010, aBolText1[1], oFont12)
	oPrint:Say(nRow3 + 0515, nCol1 + 0010, aBolText1[2], oFont12)
	oPrint:Say(nRow3 + 0725, nCol1 + 0010, 'CHAVE ASBACE:' + Transform(M->ASBACE, '@R 9999.9999.9999.9999.9999.9999') + '  R.V.A.', oFont12)
	//
	oPrint:Say(nRow3 + 0410, nCol1 + 1710, "(-)Desconto/Abatimento", oFont12n)
	oPrint:Say(nRow3 + 0480, nCol1 + 1710, "(-)Outras Deduções", oFont12n)
	oPrint:Say(nRow3 + 0550, nCol1 + 1710, "(+)Mora/Multa", oFont12n)
	oPrint:Say(nRow3 + 0620, nCol1 + 1710, "(+)Outros Acréscimos", oFont12n)
	oPrint:Say(nRow3 + 0690, nCol1 + 1710, "(=)Valor Cobrado", oFont12n)
	//
	oPrint:Say(nRow3 + 0760, nCol1 + 0010, "Sacado", oFont12n)
	cCNPJ_CPF := ""
	If aDatSacado[8] = "J"
		cCNPJ_CPF := SPACE(10)+"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99") // CGC
	Else
		cCNPJ_CPF :=SPACE(10)+"CPF.: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99") 	// CPF
	EndIf
	oPrint:Say(nRow3 + 0795, nCol1 + 0010, aDatSacado[1] + " (" + aDatSacado[2] + ")" + cCNPJ_CPF, oFont12) // RAZAO+CODIGO+CNPJ
	oPrint:Say(nRow3 + 0830, nCol1 + 0010 ,aDatSacado[3], oFont12)

	oPrint:Say(nRow3 + 0865, nCol1 + 0010, "CEP.: " + aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont12) // CEP+Cidade+Estado
	oPrint:Say(nRow3 + 0865, nCol1 + 0600, aDadosTit[6], oFont12)

	oPrint:Say(nRow3 + 0935, nCol1 + 0010 , "Sacador/Avalista", oFont12n)
	oPrint:Say(nRow3 + 0935, nCol1 + 1710, "Código de baixa", oFont12n)

	oPrint:Say(nRow3 + 0970, nCol1 + 1400, "Autenticação Mecânica/Ficha de Compensação", oFont12n)    
	//     FWMsBar(cTypeBar,nRow,nCol,cCode   ,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)-->	    
	oPrint:FWMsBar("INT25" ,0061,0002,_cCodBar,oPrint,.F.   ,     ,.T.  ,0.025 ,1.2    ,.F.    ,     ,     ,.F.   ,1       ,1        ,)
	//MSBAR3("INT25",15.85,1,_cCodBar,oPrint,.F.,Nil,.T.,0.028,1.02,Nil,Nil,Nil,.F.) //Impressora Laser

	oPrint:EndPage() // Finaliza a página 
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo10 ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASE DO ITAU COM CODIGO DE BARRAS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo10(cData)
	Local L,D,P := 0
	Local B     := .F.
	L := Len(cData)
	B := .T.
	D := 0
	While L > 0
		P := Val(SubStr(cData, L, 1))
		If (B)
			P := P * 2
			If P > 9
				P := P - 9
			End
		End
		D := D + P
		L := L - 1
		B := !B
	End
	D := 10 - (Mod(D,10))
	If D = 10
		D := 0
	End
Return(D)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo11 ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER DO ITAU COM CODIGO DE BARRAS     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo11(cData)
	LOCAL L, D, P := 0          

	L := Len(cdata)
	D := 0
	P := 1
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		End
		L := L - 1
	End

	D := 11 - (mod(D,11))
	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	End
Return(D)
/*
*/
Static Function MontaLinha()
	M->LineDig := ""
	M->nDigito := ""
	M->Pedaco  := ""
	M->LineDig := ""
	M->nDigito := ""
	M->Pedaco  := ""
	//Primeiro Campo
	//Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras
	M->Pedaco := Substr(M->CodBarras,01,03) + Substr(M->CodBarras,04,01) + Substr(M->CodBarras,20,5)
	DV_LINHA()
	M->LineDig := Substr(M->CodBarras,01,03)+Substr(M->CodBarras,04,01)+Substr(M->CodBarras,20,1)+"."+;
	Substr(M->CodBarras,21,04) + M->nDigito + Space(2)
	//???? Duas Vezes???   M->LineDig := Substr(M->CodBarras,01,03)+Substr(M->CodBarras,04,01)+Substr(M->CodBarras,20,01)+"."+ Substr(M->CodBarras,21,4) + M->nDigito + Space(2)
	//Segundo Campo
	M->Pedaco  := Substr(M->CodBarras,25,10)
	DV_LINHA()
	M->LineDig := M->LineDig+Substr(M->Pedaco,1,5)+"."+Substr(M->Pedaco,6,5)+;
	M->nDigito+Space(2)
	//??? Duas Vezes???    M->LineDig := M->LineDig+Substr(M->Pedaco,1,5)+"."+Substr(M->Pedaco,6,5)+ M->nDigito+Space(2)
	//Terceiro Campo
	M->Pedaco  := Substr(M->CodBarras,35,10)
	DV_LINHA()
	M->LineDig := M->LineDig + Substr(M->Pedaco,1,5)+"."+Substr(M->Pedaco,6,5)+;
	M->nDigito+Space(2)
	//Quarto Campo
	M->LineDig := M->LineDig + DV_BARRA + Space(2)
	//Quinto Campo
	//M->LineDig  := M->LineDig + M->FatorVcto + StrZero(Int(SE1->E1_Valor*100),10)
	M->LineDig  := M->LineDig + M->FatorVcto + StrZero((SE1->E1_Valor*100),10)
Return

Static Function BarraDV()

	Local i

	M->nCont := 0
	M->cPeso := 2
	For i := 43 To 1 Step -1
		M->nCont := M->nCont + ( Val( SUBSTR( M->B_Campo,i,1 )) * M->cPeso )
		M->cPeso := M->cPeso + 1
		If M->cPeso >  9
			M->cPeso := 2
		Endif
	Next
	M->Resto  := ( M->nCont % 11 )
	M->Result := ( 11 - M->Resto )
	Do Case
		Case M->Result == 10 .or. M->Result == 11
		M->DV_BARRA := "1"
		OtherWise
		M->DV_BARRA := Str(M->Result,1)
	EndCase
Return

Static Function DV_LINHA()

	Local i
	nCont  := 0
	Peso   := 2

	For i := Len(M->Pedaco) to 1 Step -1

		If M->Peso == 3
			M->Peso := 1
		Endif

		If Val(SUBSTR(M->Pedaco,i,1))*M->Peso >= 10
			nVal  := Val(SUBSTR(M->Pedaco,i,1)) * M->Peso
			nCont := nCont+(Val(SUBSTR(Str(nVal,2),1,1))+Val(SUBSTR(Str(nVal,2),2,1)))
		Else
			nCont:=nCont+(Val(SUBSTR(M->Pedaco,i,1))* M->Peso)
		Endif

		M->Peso := M->Peso + 1
	Next

	M->Dezena  := Substr(Str(nCont,2),1,1)
	M->Resto   := ( (Val(Dezena)+1) * 10) - nCont
	If M->Resto   == 10
		M->nDigito := "0"
	Else
		M->nDigito := Str(M->Resto,1)
	Endif
Return
/*
*/
Static Function fCodBarBane(cBanco,cAgencia,cConta,cDacCC,cNroDoc,nValor,dVencto)
	Local cValorFinal := strzero(int(nValor*100),10)
	Local _nX, nI, _nY
	Private numboleta,fatorvcto,b_campo,codbarras,dv_barra,linedig,nDigito,dv_nnum,cbarra,pedaco,esc
	Private nPos	 := 0

	M->DV_NNUM   := SPACE(1)
	M->DV_BARRA  := SPACE(1)
	M->cBARRA    := ""
	M->ASBACE    := ""
	M->LineDig   := ""
	M->NumBoleta := ""
	M->nDigito   := ""
	M->Pedaco    := ""
	esc := CHR(27)
	* Preparacao Inicio
	height    := 2.5
	small_bar := 3.8                               && number of points per bar  3

	wide_bar := ROUND(small_bar * 2.25,0)          && 2.25 x small_bar

	//height    := 2.5  && 2
	//small_bar := 4.2                               && number of points per bar  3
	//wide_bar := ROUND(small_bar * 2.25,0)          && 2.25 x small_bar
	dpl := 60   //50                                 && dots per line 300dpi/6lpi = 50dpl
	nb := esc+"*c"+TRANSFORM(small_bar,'99')+"a"+Alltrim(STR(height*dpl))+"b0P"+esc+"*p+"+TRANSFORM(small_bar,'99')+"X"
	// Barra estreita
	wb := esc+"*c"+TRANSFORM(wide_bar,'99')+"a"+Alltrim(STR(height*dpl))+"b0P"+esc+"*p+"+TRANSFORM(wide_bar,'99')+"X"
	// Barra larga
	ns := esc+"*p+"+TRANSFORM(small_bar,'99')+"X"
	// Espaco estreito
	ws := esc+"*p+"+TRANSFORM(wide_bar,'99')+"X"
	// Espaco largo
	_TpBar := "25"
	If _TpBar == "25"
		// Representacao binaria dos numeros 1-Barras/Espacos largas (os)
		// 0-Barras/Espacos estreitas (os)
		char25 := {}
		AADD(char25,"10001")       && "1"
		AADD(char25,"01001")       && "2"
		AADD(char25,"11000")       && "3"
		AADD(char25,"00101")       && "4"
		AADD(char25,"10100")       && "5"
		AADD(char25,"01100")       && "6"
		AADD(char25,"00011")       && "7"
		AADD(char25,"10010")       && "8"
		AADD(char25,"01010")       && "9"
		AADD(char25,"00110")       && "0"
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Layout para o Banco Brasil  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cFixo1   := "4329876543298765432987654329876543298765432"
	_cFixo2   := "21212121212121212121212"
	_cFixo3   := "765432765432765432765432"
	_cFixo4   := "212121212"
	_cFixo5   := "1212121212"
	** Montagem do Codigo de Barras
	_ValBol  := QtdComp(SE1->E1_VALOR)
	_fatvenc := Alltrim(Str(SE1->E1_VENCTO-CTOD("07/10/1997")))
	_Desc1 := 0.00
	_Desc2 := 0.00
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Formar a linha digitavel e o código de barras³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	M->NumBoleta := SE1->E1_IDCNAB
	M->FatorVcto := Str( ( SE1->E1_VENCTO - Ctod("07/10/1997") ),4 )
	M->ASBACE := Substr(M->NumBoleta,1,8) + PADL(Alltrim(cConta),11,"0") + "4" + "021"`

	nTotal := 0
	nTotalGer := 0

	For nI:=1 To Len(M->ASBACE)
		nTotal := Val(Substr(M->ASBACE,nI,1)) * Val(Substr(_cFixo2,nI,1))
		If nTotal > 9
			nTotal := nTotal - 9
		EndIf
		nTotalGer += nTotal
	Next

	nResto := Mod(nTotalGer,10)

	If nResto = 0
		cDigito1 := "0"
	Else
		cDigito1 := Alltrim(Str(10 - nResto))
	EndIf

	M->ASBACE := M->ASBACE + cDigito1
	nTotal := 0
	nTotalGer := 0

	For nI:=1 To Len(M->ASBACE)
		nTotal := Val(Substr(M->ASBACE,nI,1)) * Val(Substr(_cFixo3,nI,1))
		nTotalGer += nTotal
	Next

	nResto := 1

	While nResto = 1

		nResto := Mod(nTotalGer,11)

		If nResto = 0
			cDigito2 := "0"
		ElseIf nResto = 1
			cDigito1 := Alltrim(Str(Val(cDigito1) + 1))
			If cDigito1 = "10"
				cDigito1 = "0"
			EndIf

			M->ASBACE := Substr(M->ASBACE,1,23)

			M->ASBACE := M->ASBACE + cDigito1

			nTotal := 0
			nTotalGer := 0

			For nI:=1 To Len(M->ASBACE)
				nTotal := Val(Substr(M->ASBACE,nI,1)) * Val(Substr(_cFixo3,nI,1))
				nTotalGer += nTotal
			Next
		ElseIf nResto > 1
			cDigito2 := Alltrim(Str(11 - nResto))
		EndIf
	EndDo

	M->ASBACE := M->ASBACE + cDigito2

	M->cBARRA    := "0219" + M->FatorVcto + cValorFinal + M->ASBACE

	nTotal := 0
	nTotalGer := 0

	For nI:=1 To Len(M->cBARRA)
		nTotal := Val(Substr(M->cBARRA,nI,1)) * Val(Substr(_cFixo1,nI,1))
		nTotalGer += nTotal
	Next

	nResto := Mod(nTotalGer,11)

	If nResto = 0 .Or. nResto = 1 .Or. nResto = 10
		_cDigCodBar := "1"
	Else
		_cDigCodBar := Alltrim(Str(11 - nResto))
	EndIf

	M->cBARRA := Substr(M->cBARRA,1,4) + _cDigCodBar + Substr(M->cBARRA,5,40)

	_cCodBar := M->cBARRA

	M->LineDig := "021" + "9" + Substr(M->ASBACE,1,5)

	nTotal := 0
	nTotalGer := 0

	For nI:=1 To Len(M->LineDig)
		nTotal := Val(Substr(M->LineDig,nI,1)) * Val(Substr(_cFixo4,nI,1))
		If nTotal > 9
			nTotal := nTotal - 9
		Else
			nTotal := nTotal
		EndIf
		nTotalGer += nTotal
	Next

	If nTotalGer < 10
		nResto := nTotalGer
	Else
		nResto := Mod(nTotalGer,10)
	EndIf

	If nResto = 0
		_cDigLnDig := "0"
	Else
		_cDigLnDig := Alltrim(Str(10 - nResto))
	EndIf
	M->LineDig := M->LineDig + _cDigLnDig

	M->LineDig := Substr(M->LineDig,1,5) + "." + Substr(M->LineDig,6,5)

	_cCampo2 := Substr(M->ASBACE,6,10)

	nTotal := 0
	nTotalGer := 0

	For nI:=1 To Len(_cCampo2)
		nTotal := Val(Substr(_cCampo2,nI,1)) * Val(Substr(_cFixo5,nI,1))
		If nTotal > 9
			nTotal := nTotal - 9
		Else
			nTotal := nTotal
		EndIf
		nTotalGer += nTotal
	Next

	If nTotalGer < 10
		nResto := nTotalGer
	Else
		nResto := Mod(nTotalGer,10)
	EndIf

	If nResto = 0
		_cDigLnDig := "0"
	Else
		_cDigLnDig := Alltrim(Str(10 - nResto))
	EndIf

	_cCampo2 := _cCampo2 + _cDigLnDig

	_cCampo2 := Substr(_cCampo2,1,5) + "." + Substr(_cCampo2,6,6)

	_cCampo3 := Substr(M->ASBACE,16,10)

	nTotal := 0
	nTotalGer := 0

	For nI:=1 To Len(_cCampo3)
		nTotal := Val(Substr(_cCampo3,nI,1)) * Val(Substr(_cFixo5,nI,1))
		If nTotal > 9
			nTotal := nTotal - 9
		Else
			nTotal := nTotal
		EndIf
		nTotalGer += nTotal
	Next

	If nTotalGer < 10
		nResto := nTotalGer
	Else
		nResto := Mod(nTotalGer,10)
	EndIf

	If nResto = 0
		_cDigLnDig := "0"
	Else
		_cDigLnDig := Alltrim(Str(10 - nResto))
	EndIf

	_cCampo3 := _cCampo3 + _cDigLnDig
	_cCampo3 := Substr(_cCampo3,1,5) + "." + Substr(_cCampo3,6,6)

	_cCampo4 := Substr(M->cBARRA,5,1)

	_cCampo5 := M->FatorVcto + cValorFinal

	M->LineDig := M->LineDig + Space(2) + _cCampo2 + Space(2) + _cCampo3 + Space(2) + _cCampo4 + Space(2) + _cCampo5

	_cLinDig := M->LineDig

	_code := ""
	If _TpBar == "25"
		_cBar := _cCodBar
		For _nX := 1 to 43 Step 2 && 44 porque o meu cod.possue 44 numeros
			_nNro := VAl(Substr(_cBar,_nx,1))
			If _nNro == 0
				_nNro := 10
			EndIf
			_cBarx := char25[_nNro]
			_nNro := VAl(Substr(_cBar,_nx+1,1))
			If _nNro == 0
				_nNro := 10
			EndIf
			_cBarx := _cBarx + char25[_nNro]

			For _nY := 1 to 5
				If Substr(_cBarx,_nY,1) == "0"
					// Uso Barra estreita
					_code := _code + nb
				Else
					// Uso Barra larga
					_code := _code + wb
				EndIf
				If Substr(_cBarx,_nY+5,1) == "0"
					// Uso Espaco estreito
					_code := _code + ns
				Else
					// Uso Espaco Largo
					_code := _code + ws
				EndIf
			Next
		Next
		_code := nb+ns+nb+ns+_code+wb+ns+nb
	EndIf
Return

Static Function DigConta(_cParam)
	Local _cRet, nI
	Local _cFixo := "121212121212121212121212"

	nTotal := 0
	nTotalGer := 0

	For nI:=1 To Len(_cParam)
		nTotal := Val(Substr(_cParam,nI,1)) * Val(Substr(_cFixo,nI,1))
		If nTotal > 9
			nTotal := Val(Substr(Alltrim(Str(nTotal)),1,1)) * Val(Substr(Alltrim(Str(nTotal)),1,2))
		Else
			nTotal := nTotal
		EndIf
		nTotalGer += nTotal
	Next

	nResto := Mod(nTotalGer,10)

	If nResto > 9
		_cRet := "0"
	Else
		_cRet := Alltrim(Str(10 - nResto))
	EndIf

Return(_cRet)

//----------------------------------------------------------------------------
Static Function RepNumer(cBanco, cMoeda, cCarteira, cNNumero, cSNumero, dDtVenc, ;
	cAgencia, cCCorrente, cDacCC, cCodCli, cValor)
	local cSeq1
	local cSeq2
	local cSeq3
	local cSeq4
	local cSeq5
	local cSeq6
	local cFatorVenc
	local cNossoNum 
	local cCCorrCmp

	cNossoNum  := SubStr(cNNumero, 1, 8)

	cCodCli    := padL(allTrim(cCodCli)		, 05, "0")
	cCCorrCmp  := cCCorrente 	
	cCCorrente := padL(allTrim(cCCorrente)	, 05, "0")
	cValor     := padL(allTrim(cValor)		, 10, "0") 

	cFatorVenc := FatorVenc( dDtVenc )  

	CSEQ1 := AllTrim(CBANCO + CMOEDA + CCARTEIRA + SUBSTR(cNossoNum, 1, 2))
	CSEQ1 += AllTrim(CODDAC(nTipoRNumerica, CSEQ1))

	CSEQ5 := AllTrim(FatorVenc(dDtVenc )) + AllTrim(cValor)

	If cCarteira == '198' .Or. cCarteira == '107' .Or. cCarteira == '122' .Or.;
	cCarteira == '142' .Or. cCarteira == '143' .Or. cCarteira == '196' .Or. cCarteira == "174" 

		cSeq2 := AllTrim(SubStr(cNossoNum, 3, 6) + SubStr(cSNumero, 1, 4))
		cSeq2 += AllTrim(CodDac(nTipoRNumerica, cSeq2))

		cSeq3 := SubStr(cSNumero, 5, 3)+;
		AllTrim(cCodCli)+CodDac(nTipoRNumerica, cCarteira + cNossoNum + cSNumero + cCodCli)+;
		"0"                            
		cSeq3 += CodDac(nTipoRNumerica, cSeq3)

	Else  
		cSeq2 := SubStr(cNossoNum, 3, 6);                                          
		+ CodDac(nTipoRNumerica, cAgencia + cCCorrCmp + cCarteira + cNossoNum);
		+ SubStr(cAgencia, 1, 3)		
		cSeq2 += CodDac(nTipoRNumerica, cSeq2) 		  
		cSeq3 := SubStr(cAgencia, 4, 1)+cCCorrente+CodDac(nTipoRNumerica,cAgencia+ cCCorrente)+"000"
		cSeq3 += CodDac(nTipoRNumerica, cSeq3)
	EndIf           

	cSeq4 := cDacBarra 

	cSeq1 := SubStr(cSeq1, 1, 5) + "." + SubStr(cSeq1, 6, 5) 
	cSeq2 := SubStr(cSeq2, 1, 5) + "." + SubStr(cSeq2, 6, 6)
	cSeq3 := SubStr(cSeq3, 1, 5) + "." + SubStr(cSeq3, 6, 6)

Return cSeq1 + "  " + cSeq2 + "  " + cSeq3 + "  " + cSeq4 + "  " + cSeq5 
//----------------------------------------------------------------------------
static function CodDac(nTipo, cNumero) 
	local aNumero
	local nI
	local nDgSoma 
	local nTotal  := 0
	local nDigito
	local nMult                
	local cSoma

	if nTipo == nTipoBarra
		nDgSoma := 2       

		for nI := len(cNumero) to 1 Step -1
			nTotal += Val( SubStr(cNumero, nI, 1) ) * nDgSoma 
			nDgSoma += 1

			If nDgSoma == 10 
				nDgSoma := 2
			EndIf

		Next 

		nDigito := nTotal % 11

		nDigito := 11 - nDigito
		//OBS.: Se o resultado desta for igual a 0, 1, 10 ou 11, considere DAC = 1.
		If nDigito = 0 .Or. nDigito = 10 .Or. nDigito = 11 
			nDigito := 1
		EndIf

	ElseIf nTipo == nTipoNNumero .Or. nTipo == nTipoRNumerica

		nDgSoma := 2 
		For nI := len(cNumero) to 1 Step -1

			nMult = Val( SubStr(cNumero, nI, 1) ) * nDgSoma
			If nMult >=10                                                              
				cSoma := AllTrim(Str(nMult))
				nMult := Val(SubStr(cSoma, 1, 1)) + Val(Substr(cSoma, 2, 1)) 
			EndIf 

			nTotal  += nMult

			If nDgSoma = 1 
				nDgSoma := 2
			Else
				nDgSoma := 1
			EndIf

		Next 		  

		nDigito := nTotal % 10
		nDigito := 10 - nDigito	 

		If nDigito = 10
			nDigito := 0
		EndIf

	EndIf

Return AllTrim(Str(nDigito))

//-------------------------------------------------------------------------
Static Function FatorVenc(dDtVenc)
	local cFator := "0000"

	cFator := strzero(dDtVenc - ctod("07/10/97"),4)

Return cFator    

//-------------------------------------------------------------------------
Static Function RelaNotas() 
	Local cNota 	:= ""
	Local cAlias 	:= GetNextAlias() 
	Local nContador := 0

	If AllTrim(SE1->E1_TIPO) == 'FT' .AND. SE1->E1_FATURA != ""
		BeginSql alias cAlias
			SELECT E1_NUM, E1_VALOR, E1_EMISSAO, E1_VENCREA, A1_NOME
			FROM %table:SE1% SE1
			JOIN %table:SA1% SA1 ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA 
			WHERE SE1.%notDel%
			AND E1_FILIAL = %xfilial:SE1% 
			AND E1_FATURA = %EXP:SE1->E1_NUM%
			AND E1_FATPREF = %EXP:SE1->E1_PREFIXO%

		EndSql   
		aRelaNotas := {}

		(cAlias)->(DbGoTop())
		While !(cAlias)->(Eof())
			If cNota != ""
				cNota += ", "
			EndIf	

			cNota += (cAlias)->E1_NUM 
			aAdd(aRelaNotas, {(cAlias)->E1_NUM, (cAlias)->E1_VALOR ;
			, (cAlias)->E1_EMISSAO, (cAlias)->E1_VENCREA;
			, (cAlias)->A1_NOME})

			(cAlias)->(DbSkip())
			nContador := 1
		EndDo
	Else
		cNota += "   "+SE1->E1_NUM
	EndIf
Return cNota