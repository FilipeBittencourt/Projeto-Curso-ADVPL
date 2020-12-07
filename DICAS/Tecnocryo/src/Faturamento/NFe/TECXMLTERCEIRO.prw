//OBSERVACAO: É necessário compilar o fonte VldPVFrete.prw para que esta rotina funcione corretamente

#include 'protheus.ch'
#include 'parmtype.ch'

user function XMLTERC()
	Processa( {|| ProcXMLTerc() }, "Processando XML...")
RETURN

Static Function ProcXMLTerc()

	Local aLogErro := {}
	Local aFileXml := {}
	Local lLoadXml := .T.
	Local cStatus  := ""
	Local nI
	Local lXmlNfe
	Local nQtdImport
	Local aTes

	Private nQtdP3	:= 0
	Private oEmitente  
	Private oIdent    
	Private oDestino  
	Private oTotal    
	Private oTransp   
	Private oDet 
	Private oNF     
	Private nHdl    
	Private oNfe
	Private aDePara  := {}
	Private cChaveNFE := ""
	Private nOperacao := 0

	LoadDePara() //Carrega lista de conversão de çodigo de produto antigo para código novo

	U_SetSX1(/*cGrupo*/ "XMLTERC", /*cOrdem*/ "01", /*cPergunt*/ "Local do XML?        ", /*cPerSpa*/ "", /*cPerEng*/ "", /*cVar*/ "mv_ch0", /*cTipo*/ "C", /*nTamanho*/ 60, /*nDecimal*/ 00, /*nPresel*/ 00, /*cGSC*/ "G", /*cValid*/           "", /*cF3*/    "DIR", /*cGrpSxg*/ "", /*cPyme*/ "", /*cVar01*/ "MV_PAR01", /*cDef01*/    ""		, /*cDefSpa1*/ "", /*cDefEng1*/ "", /*cCnt01*/ "", /*cDef02*/    ""				, /*cDefSpa2*/ "", /*cDefEng2*/ "", /*cDef03*/ "", /*cDefSpa3*/ "", /*cDefEng3*/ "", /*cDef04*/ "", /*cDefSpa4*/ "", /*cDefEng4*/ "", /*cDef05*/ "", /*cDefSpa5*/ "", /*cDefEng5*/"", /*aHelpPor*/ {"Informe a pasta onde se encontra os ar-","aquivos XML."}, /*aHelpEng*/ {}, /*aHelpSpa*/ {}, /*cHelp*/ "")
	U_SetSX1(/*cGrupo*/ "XMLTERC", /*cOrdem*/ "02", /*cPergunt*/ "TES dentro do estado?", /*cPerSpa*/ "", /*cPerEng*/ "", /*cVar*/ "mv_ch1", /*cTipo*/ "C", /*nTamanho*/ 03, /*nDecimal*/ 00, /*nPresel*/ 00, /*cGSC*/ "G", /*cValid*/           "", /*cF3*/    "SF4", /*cGrpSxg*/ "", /*cPyme*/ "", /*cVar01*/ "MV_PAR02", /*cDef01*/    ""		, /*cDefSpa1*/ "", /*cDefEng1*/ "", /*cCnt01*/ "", /*cDef02*/    ""				, /*cDefSpa2*/ "", /*cDefEng2*/ "", /*cDef03*/ "", /*cDefSpa3*/ "", /*cDefEng3*/ "", /*cDef04*/ "", /*cDefSpa4*/ "", /*cDefEng4*/ "", /*cDef05*/ "", /*cDefSpa5*/ "", /*cDefEng5*/"", /*aHelpPor*/ {"Informe o código da TES a ser utilizada", "em operações DENTRO do estado"}, /*aHelpEng*/ {}, /*aHelpSpa*/ {}, /*cHelp*/ "")
	U_SetSX1(/*cGrupo*/ "XMLTERC", /*cOrdem*/ "03", /*cPergunt*/ "TES fora do estado?  ", /*cPerSpa*/ "", /*cPerEng*/ "", /*cVar*/ "mv_ch2", /*cTipo*/ "C", /*nTamanho*/ 03, /*nDecimal*/ 00, /*nPresel*/ 00, /*cGSC*/ "G", /*cValid*/           "", /*cF3*/    "SF4", /*cGrpSxg*/ "", /*cPyme*/ "", /*cVar01*/ "MV_PAR03", /*cDef01*/    ""		, /*cDefSpa1*/ "", /*cDefEng1*/ "", /*cCnt01*/ "", /*cDef02*/    ""				, /*cDefSpa2*/ "", /*cDefEng2*/ "", /*cDef03*/ "", /*cDefSpa3*/ "", /*cDefEng3*/ "", /*cDef04*/ "", /*cDefSpa4*/ "", /*cDefEng4*/ "", /*cDef05*/ "", /*cDefSpa5*/ "", /*cDefEng5*/"", /*aHelpPor*/ {"Informe o código da TES a ser utilizada", "em operações FORA do estado"}, /*aHelpEng*/ {}, /*aHelpSpa*/ {}, /*cHelp*/ "")
	U_SetSX1(/*cGrupo*/ "XMLTERC", /*cOrdem*/ "04", /*cPergunt*/ "Operação?  "			, /*cPerSpa*/ "", /*cPerEng*/ "", /*cVar*/ "mv_ch3", /*cTipo*/ "N", /*nTamanho*/ 01, /*nDecimal*/ 00, /*nPresel*/ 00, /*cGSC*/ "C", /*cValid*/           "", /*cF3*/    ""   , /*cGrpSxg*/ "", /*cPyme*/ "", /*cVar01*/ "MV_PAR04", /*cDef01*/"Importar XML", /*cDefSpa1*/ "", /*cDefEng1*/ "", /*cCnt01*/ "1", /*cDef02*/"Corrigir CHAVE"	, /*cDefSpa2*/ "", /*cDefEng2*/ "", /*cDef03*/ "", /*cDefSpa3*/ "", /*cDefEng3*/ "", /*cDef04*/ "", /*cDefSpa4*/ "", /*cDefEng4*/ "", /*cDef05*/ "", /*cDefSpa5*/ "", /*cDefEng5*/"", /*aHelpPor*/ {"Informe o código da TES a ser utilizada", "em operações FORA do estado"}, /*aHelpEng*/ {}, /*aHelpSpa*/ {}, /*cHelp*/ "")

	WHILE lLoadXml

		IF ( lLoadXml := Pergunte( "XMLTERC", .T.) ) 

			IF Rat("\",MV_PAR01) > 0
				MV_PAR01 := SubStr( MV_PAR01, 1, Rat("\",MV_PAR01) )
			ELSE
				Aviso( "DIRXMLINVALIDO", "Formato ou diretório inválidos. Tente outra vez... ", { "Ok" })
				LOOP
			ENDIF

			nOperacao := MV_PAR04
			
			CreateFolder()

			IF ! Empty(MV_PAR02)
				aTes := {MV_PAR02, MV_PAR03}
			ENDIF

			IF ! Empty( LoadFile( alltrim( M->MV_PAR01 ), @aFileXml ) )

				ProcRegua( Len(aFileXml) )

				lLoadXml := Aviso( "FILEXMLFOUND", "Encontrado(s) " + Alltrim( Str( Len( aFileXml ), 5, 0 ) ) + " arquivos XML, para importação. ", { "Cancelar", "Confirmar" }) == 2

				IF lLoadXml

					FOR nI := 1 To Len( aFileXml )

						IncProc( 1 )

						IF ! ( lXmlNfe := GetXmlNfe( aFileXml[ nI ], @cStatus, aTes ) ) //Carrega XML na memória
							aAdd( aLogErro, { aFileXml[ nI ], cStatus } )
						ENDIF

						fClose(nHdl)

						IF lXmlNfe .AND. __CopyFile( aFileXml[ nI ], "C:\temp\XML\lidos"+ SubStr( aFileXml[ nI ], Rat("\",aFileXml[ nI ] ) ) )
							fErase(  aFileXml[ nI ] )
						ENDIF

					NEXT

					nQtdImport := nQtdP3 //Len( aFileXml ) - Len( aLogErro )
					Aviso( "FILEIMPORTADO", "Foram importados " + Alltrim( Str( nQtdImport, 5, 0 ) ) + " de " + Alltrim( Str( Len( aFileXml ), 5, 0 ) ) , { "Ok" })
					nQtdP3 := 0
					
				ENDIF

			ELSE

				lLoadXml := Aviso( "FILENOTFOUND", "Não existe arquivos com extensão XML, no local indicado.", { "Abortar", "Repetir" }) == 2

			ENDIF

		ENDIF

	ENDDO

return

Static Function CreateFolder()

	IF ! ExistDir( MV_PAR01 + "lidos")
		MakeDir(  MV_PAR01 + "lidos" )
	ENDIF

Return

//FUNÇÃO	:  GetXmlNfe()
//AUTOR		: ACO - PSS
//DATA 		: 25/04/2018
//OBJETIVO	: Acessar arquivo XML na pasta  indicada pelo usuário
//PREMISSAS
//=========
//1) Para os CTE's que não tiverem a nota original informada;
//2) Se a função stgeracte estiver na pilha de chamada
//3) Se for INCLUSÃO
//4) Se for CTE e tipo normal
Static Function GetXmlNfe( cFile, cStatus, aTes )

	//	Local aNotaFiscal := {}
	Local nI, cCFOP

	nHdl    := fOpen(cFile,0)

	If nHdl == -1
		Aviso("FileNotOpen", "O arquivo de nome "+cFile+" nao pode ser aberto! Verifique.",{"Ok"})
		Return .F.
	Endif

	nTamFile := Int( fSeek( nHdl, 0, 2 ) * 1.2 ) 
	fSeek(nHdl, 0, 0 )

	cBuffer  	:= Space( nTamFile )                	// Variavel para criacao da linha do registro para leitura
	//	nBtLidos 	:= fRead( nHdl, @cBuffer, nTamFile )  	// Leitura  do arquivo XML
	fRead( nHdl, @cBuffer, nTamFile )  	// Leitura  do arquivo XML

	fClose(nHdl)

	cErro  	:= ""
	//	cBuffer := EncodeUTF8(cBuffer)
	oNfe 	:= XmlParser( cBuffer, "_", @cStatus, @cErro) //carrega xml

	//	IF Type( "oNFe:_NFeProc:_NFe:_INFNFE" ) == "U"
	//		cAchei := .T.
	//	ENDIF

	IF Type( "oNFe:_NFe:_INFNFE" ) == "O"

		oNF	:= oNFe:_NFe:_INFNFE	

		oEmitente  := oNF:_Emit
		oIdent     := oNF:_IDE
		oDestino   := oNF:_Dest
		oTotal     := oNF:_Total
		oTransp    := oNF:_Transp
		oDet       := oNF:_Det

		cChaveNFE := oNFe:_NFe:_INFNFE:_ID:TEXT

	ELSEIF IIF( Type( "oNfe:_NFEPROC:_VERSAO" ) == 'O', oNfe:_NFEPROC:_VERSAO:TEXT $ "2.00, 3.10", .F. )

		oNF	:= oNFe:_NFeProc:_NFe:_InfNfe

		oEmitente  := oNF:_Emit
		oIdent     := oNF:_IDE
		oDestino   := oNF:_Dest
		oTotal     := oNF:_Total
		oTransp    := oNF:_Transp
		oDet       := oNF:_Det

		cChaveNFE := StrTran( upper( oNFe:_NFeProc:_NFe:_InfNfe:_id:text ), 'NFE', '' ) //oNFe:_NFeProc:_PROTNFE:_INFPROT:_CHNFE:TEXT

	ELSEIF "CANC" $ UPPER( cFile )

		Return .F.

	ELSE

		Aviso( "IMPOR.FALHOU", "Falha na importação do arquivo: " + cFile, { "Ok" })
		Return .F.

	ENDIF

	oDet := IIf( ValType( oDet ) == "O", { ( oDet ) }, oDet )

	cCFOP:= oDet[1]:_Prod:_CFOP:Text

	IF Right( cCFOP, 3 ) == '949' //VALTYPE( oNfe:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT ) == "C" //TRATA QUANDO QUANDO FOR UMA NOTA ORIGINAL PRA UM CTE

		nQtdP3 += 1 
		Return MountOrder( cFile, aTes )

	ENDIF

	//	dbSelectArea("SF2XML")

	//CARREGA CÓDIGO DAS NOTA ORIGINAIS ENCONTRADAS
	//	WHILE ! SF2XML-> ( EOF() )
	//		aAdd( aNotaFiscal, { SF2XML->F2_DOC, SF2XML->F2_SERIE })
	//		SF2XML-> ( dbSKip() )
	//	ENDDO

	//ATRIBUI A NF ORIGINAL AO ACOLS DO CTE
	//	SF2XML-> ( dbCloseArea() )
	//	FOR nI := 1 TO Len( aCols )
	//		aCols[nI][ _nPosNFOri  ] := aNotaFiscal[nI][1]
	//		aCols[nI][ _nPosSerOri ] := aNotaFiscal[nI][2]
	//		//		aCols[nI][ _nPosItmOri ] := StrZero( nI, TamSx3("D2_ITEM")[1] )
	//	NEXT

Return .T.

Static Function MountOrder( cFile, aTes )

	Local nI		:= 0
	Local aAux 		:= {}
	Local aCabPV 	:= {}
	Local aItemPV	:= {}
	Local cProduto  := ""
	Local cUfDest	:= oDestino:_EnderDest:_UF:Text
	Local cCNPJForn	
	Local cCliente	:= ""
	Local cLoja		:= ""
	//	Local dDataBase	:= ctod("")
	Local cProdDesc := ""
	Local cTes
	Local cMenNota
	Local cSerieNf	:= PadR( oIdent:_SERIE:TEXT, TamSx3("FT_SERIE")[1] ) 
	Local cNumNf	:= PadL(oIdent:_NNF:TEXT, TamSx3("FT_NFISCAL")[1], "0" )	

	IF TYPE( "oDestino:_CNPJ" ) <> "O" 
		cCNPJForn	:= oDestino:_CPF:Text
	ELSE
		cCNPJForn	:= oDestino:_CNPJ:Text
	ENDIF

	cMenNota	:= "Serie: " + oIdent:_SERIE:TEXT + " Nota: "+ oIdent:_NNF:TEXT + " - Originada de XML, poder de 3o" + " - Chave: " + cChaveNFE + " - CNPJ: " + cCNPJForn

	Default aTes	:= { '757', '760' } // 1) Dentro do estado: 757; 2) Fora do estado: 760

	cTes			:= IIF( cUfDest == GETMV("MV_ESTADO"), aTes[1], aTes[2] ) 

	IF cCNPJForn ==  ALLTRIM( SM0->M0_CGC )
		Return .F.
	ENDIF

	IF ! Posicione( "SA1", 3, xFilial( "SA1" ) + cCNPJForn, "FOUND()")
		cCliente := '000001'
		cLoja	 := '01'
	ELSE
		cCliente := SA1->A1_COD
		cLoja	 := SA1->A1_LOJA
	ENDIF

	IF Type( "oNfe:_nfeproc:_protnfe:_infprot:_dhrecbto" ) == "O"
		dDataBase := StoD( StrTran( Left( oNfe:_nfeproc:_protnfe:_infprot:_dhrecbto:text, 10 ), '-', '') )
	ELSEIF Type( "oNfe:_NFE:_INFNFE:_IDE:_DEMI" ) == "O"
		dDataBase := StoD( StrTran( Left( oNfe:_NFE:_INFNFE:_IDE:_DEMI:text, 10 ), '-', '') )
	ELSEIF Type( "oNfe:_nfeproc:_protnfe:_infprot:_dhrecbto" ) == "O"
		dDataBase := StoD( StrTran( Left( oNfe:_nfeproc:_protnfe:_infprot:_dhrecbto:text, 10 ), '-', '') )
	ELSE
		dDataBase := StoD( StrTran( oNFe:_NFeProc:_NFe:_InfNfe:_IDE:_DEMI:TEXT, '-', '') )
	ENDIF

	Aadd(aCabPV,  { "C5_TIPO"   	, "N"    			, Nil })
	Aadd(aCabPV,  { "C5_EMISSAO"	, dDataBase			, Nil })
	Aadd(aCabPV,  { "C5_CLIENTE"	, cCliente		   	, Nil })
	Aadd(aCabPV,  { "C5_LOJACLI"	, cLoja		     	, Nil })
	Aadd(aCabPV,  { "C5_CONDPAG"	, "001"   			, Nil })
	Aadd(aCabPV,  { "C5_TIPLIB" 	, "2"         		, Nil })
	Aadd(aCabPV,  { "C5_ORIGEM"  	, 'XMLNF3o'			, Nil })
	Aadd(aCabPV,  { "C5_DTLANC"  	, dDataBase			, Nil })
	Aadd(aCabPV,  { "C5_TRANSP"  	, "000001"			, Nil })
	Aadd(aCabPV,  { "C5_MENNOTA"  	, cMenNota 			, Nil })
	Aadd(aCabPV,  { "C5_TABELA"  	, "003" 			, Nil })
	Aadd(aCabPV,  { "C5_TPFRETE"  	, "S" 			, Nil })

	lMsErroAuto := .F.

	FOR nI := 1 TO Len( oDet )

		cProduto := PadR( oDet[ nI ]:_PROD:_CPROD:Text, TamSx3("B1_COD")[1] )
		cProdDesc:= oDet[ nI ]:_PROD:_XPROD:Text

		IF ! Posicione( "SB1", 1, xFilial("SB1") + cProduto, "FOUND()")

			cProduto := DeParaPrd( cProduto  )

			IF ! Posicione( "SB1", 1, xFilial("SB1") + cProduto, "FOUND()")
				cProduto := "0002000001     "
			ENDIF

		ENDIF

		//		IF  cProduto == PadR( '0002000001', TamSx3("B1_COD")[1] )
		//			Aviso("TAPETE", "O produto " + ALLTRIM( cProduto ) + ". Tapete de novo kkkk. Arquivo: " + cFile, { "Ok"})
		//			LOOP
		//		ENDIF

		//		IF SB1->( FOUND() )

		aAux := {}

		M->C6_QTDVEN := Val( oDet[ nI ]:_PROD:_QCOM:Text ) 
		M->C6_PRCVEN := Val( oDet[ nI ]:_PROD:_VUNCOM:Text )
		M->C6_VALOR := M->C6_QTDVEN * M->C6_PRCVEN

		Aadd(aAux,{ "C6_ITEM"    , StrZero( nI, TamSx3( "C6_ITEM")[1], 0 )	, Nil}) // Numero do Item no Pedido
		Aadd(aAux,{ "C6_PRODUTO" , cProduto									, Nil}) // Codigo do Produto
		Aadd(aAux,{ "C6_DESCRI"	 , cProdDesc								, Nil}) // Descrição do Produto
		Aadd(aAux,{ "C6_TES" 	 , cTes										, Nil}) // 1) Dentro do estado: 757; 2) Fora do estado: 760
		Aadd(aAux,{ "C6_QTDVEN"  , M->C6_QTDVEN								, Nil}) // Quantidade Vendida
		Aadd(aAux,{ "C6_PRCVEN"  , M->C6_PRCVEN								, Nil}) // Preco Unitario Liquido
		Aadd(aAux,{ "C6_VALOR"   , M->C6_VALOR								, Nil}) // Preco Unitario Liquido
		//		Aadd(aAux,{ "C6_QTDLIB"  , Val( oDet[ nI ]:_PROD:_QCOM:Text )		, Nil}) // Quantidade Liberada

		Aadd( aItemPV, aAux )

		//		ENDIF

	NEXT

	IF LEN( aItemPV ) > 0

		IF nOperacao == 1
		
			MsExecAuto({ |x,y,z| Mata410(x,y,z)}, aCabPV, aItemPV, 3 )

			If lMsErroAuto

				//nTam := ( rAt( ".", cFile ) - 1 ) - rAt( "\", cFile )  
				//MostraErro( "nota", GETMV("MV_RELT") + "NOTA_" + substr( cFile, rAt( "\", cFile ) + 1, nTam) +  "_ERRO_"  + ".txt")
				Mostraerro()
				Return .F.

			EndIf

		ELSEIF nOperacao == 2
			/*
			sp_helpindex SF2010; --1) F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO, R_E_C_N_O_, D_E_L_E_T_
			sp_helpindex SF3010; --5) F3_FILIAL, F3_SERIE, F3_NFISCAL, F3_CLIEFOR, F3_LOJA, F3_IDENTFT, R_E_C_N_O_, D_E_L_E_T_
			sp_helpindex SFT010; --1) FT_FILIAL, FT_TIPOMOV, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA, FT_ITEM, FT_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
			sp_helpindex CDD010; --1) CDD_FILIAL, CDD_TPMOV, CDD_DOC, CDD_SERIE, CDD_CLIFOR, CDD_LOJA, CDD_DOCREF, CDD_SERREF, CDD_PARREF, CDD_LOJREF, R_E_C_N_O_, D_E_L_E_T_
			*/		
			IF Posicione( "SF2", 1, xFilial("SF2") + cNumNf  + cSerieNf +  SA1->A1_COD + SA1->A1_LOJA, "FOUND()" )
				cKeyGroup := xFilial("SF2") + cNumNf  + cSerieNf +  SA1->A1_COD + SA1->A1_LOJA
				SFT-> ( dbEval( {|| RecLock(), SFT->FT_CHVNFE := cChaveNFE, msUnLock() },,{ || ! eof() .and. cKeyGroup == SF2-> ( F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )} ) )
			ENDIF

			IF Posicione( "SF3", 5, xFilial("SF3") + cSerieNf + cNumNf +  SA1->A1_COD + SA1->A1_LOJA, "FOUND()" )
				cKeyGroup := xFilial("SF3") + cSerieNf + cNumNf +  SA1->A1_COD + SA1->A1_LOJA
				SFT-> ( dbEval( {|| RecLock(), SFT->FT_CHVNFE := cChaveNFE, msUnLock() },,{ || ! eof() .and. cKeyGroup == SF3-> ( F3_FILIAL + F3_SERIE + F3_NFISCAL + F3_CLIEFOR, F3_LOJA )} ) )
			ENDIF

			IF Posicione( "SFT", 1, xFilial("SFT") + "E" + cSerieNf + cNumNf +  SA1->A1_COD + SA1->A1_LOJA, "FOUND()" )
				cKeyGroup := xFilial("SFT") + "E" + cSerieNf + cNumNf +  SA1->A1_COD + SA1->A1_LOJA
				SFT-> ( dbEval( {|| RecLock(), SFT->FT_CHVNFE := cChaveNFE, msUnLock() },,{ || ! eof() .and. cKeyGroup == SFT-> ( FT_FILIAL + FT_TIPOMOV + FT_SERIE + FT_NFISCAL + FT_CLIEFOR + FT_LOJA )} ) )
			ENDIF

			IF Posicione( "SFT", 1, xFilial("SFT") + "E" +  cNumNf + cSerieNf + SA1->A1_COD + SA1->A1_LOJA, "FOUND()" )
				cKeyGroup := xFilial("CDD") + "E" +  cNumNf + cSerieNf + SA1->A1_COD + SA1->A1_LOJA
				CDD-> ( dbEval( {|| RecLock(), CDD->CDD_CHVNFE := cChaveNFE, msUnLock() },,{ || ! eof() .and. cKeyGroup == CDD-> ( CDD_FILIAL + CDD_TPMOV + CDD_DOC + CDD_SERIE + CDD_CLIFOR + CDD_LOJA )} ) )
			ENDIF

		ENDIF

	ELSE

		Aviso( "PRODNOTFOUND", "O produto " + allTrim( cProduto ) + " não encontrado na base", { "Ok" } )
		Return .F.

	ENDIF


Return .t.

Static Function  LoadDePara()

	aAdd( aDePara, { '256576'		, '0050000009' } )
	aAdd( aDePara, { '256575'		, '0050000011' } )
	aAdd( aDePara, { '2011564'		, '0050000001' } )
	aAdd( aDePara, { '256636'		, '0050000014' } )
	aAdd( aDePara, { '256637'		, '0050000014' } )
	aAdd( aDePara, { '256675'		, '0050000016' } )
	aAdd( aDePara, { '256679'		, '0050000022' } )
	aAdd( aDePara, { '256676'		, '0050000023' } )
	aAdd( aDePara, { '256574'		, '0050000025' } )
	aAdd( aDePara, { '196513'		, '0050000025' } )
	aAdd( aDePara, { '256616'		, '0050000032' } )
	aAdd( aDePara, { '2566171'		, '0050000026' } )
	aAdd( aDePara, { '256546'		, '0050000033' } )
	aAdd( aDePara, { '23546'		, '0050000050' } )
	aAdd( aDePara, { '179473'		, '0050000036' } )
	aAdd( aDePara, { '256000'		, '0050000054' } )
	aAdd( aDePara, { '256548'		, '0050000045' } )
	aAdd( aDePara, { '2566549'		, '0050000049' } )
	aAdd( aDePara, { '260100'		, '0050000057' } )
	aAdd( aDePara, { '256555'		, '0050000059' } )
	aAdd( aDePara, { '260067'		, '0050000060' } )
	aAdd( aDePara, { '256558'		, '0050000124' } )
	aAdd( aDePara, { '261696'		, '0050000129' } )
	aAdd( aDePara, { '257801'		, '0050000068' } )
	aAdd( aDePara, { '2578001'		, '0050000066' } )
	aAdd( aDePara, { '257800'		, '0050000067' } )
	aAdd( aDePara, { '257802'		, '0050000129' } )
	aAdd( aDePara, { '2565611'		, '0050000069' } )
	aAdd( aDePara, { '256561'		, '0050000087' } )
	aAdd( aDePara, { '256562'		, '0050000075' } )
	aAdd( aDePara, { '256563'		, '0050000076' } )
	aAdd( aDePara, { '1142'			, '0050000089' } )
	aAdd( aDePara, { '256565'		, '0050000091' } )
	aAdd( aDePara, { '256456'		, '0050000091' } )
	aAdd( aDePara, { '2566573'		, '0050000103' } )
	aAdd( aDePara, { '2566572'		, '0050000103' } )
	aAdd( aDePara, { '256460'		, '0050000098' } )
	aAdd( aDePara, { '256569'		, '0050000100' } )
	aAdd( aDePara, { '1105'			, '0050000107' } )
	aAdd( aDePara, { '256568'		, '0050000109' } )
	aAdd( aDePara, { '256571'		, '0050000101' } )
	aAdd( aDePara, { '256570'		, '0050000111' } )
	aAdd( aDePara, { '260000'		, '0050000036' } )

Return

Static Function DeParaPrd( cProdOld )

	Local cProdNew := cProdOld
	Local aDePara  := {}
	Local nPos	   := 0

	nPos := aScan( aDePara, { | x | x[1] == cProdOld } )

	IF nPos > 0

		cProdNew := PadR( aDePara[ nPos ][ 2 ], TamSx3("B1_COD")[1] )

	ENDIF

Return cProdNew

//FUNÇÃO	: AchaFile(cCodBar)
//AUTOR		: ACO - Brasoft
//DATA 		: 25/04/2018
//OBJETIVO	: verifica se existe um arquivo XML correspondente à chave eletrônica do CT-E
Static Function LoadFile( cDirectory, aFileXml )

	Local aFiles := Directory( cDirectory + "*.xml","",, .F., 2 ) //Directory( < cDirEsp >, [ cAtributos ], [ uParam1 ], [ lCaseSensitive ], [ nTypeOrder ] )

	IF Len( aFiles ) > 0

		aSort( aFiles,,, { | x, y | x[4] < y[4]            } )
		aEval( aFiles,   { | x    | aAdd( aFileXml, allTrim(cDirectory) + x[1] ) } )

	ENDIF

Return aFileXml