#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE IMP_SPOOL     2				
#DEFINE MAXMENLIN   200				// Máximo de caracteres por linha de dados adicionais
#DEFINE MAXLINOBS   018             // Máximo de linhas nas observaçoes.
#DEFINE MAXLINREP	550				// Máximo de linhas relatório.	
#DEFINE HALFLINREP	(MAXLINREP/2)	// Metade de linhas do relatório.						

User Function DAMDFE(cIdEnt,oDamdfe,oSetup,cFilePrint)

Local aArea     	:= GetArea()
Local lExistMDfe 	:= .F. 

Private nPosSyCtge	:= 005 //Indica a coordenada vertical em pixels ou caracteres quando a impressão for por contingência, já que deixaremos a observação mais a baixo.
Private nPosIniCtg	:= 010 //Indica a coordenada vertical em pixels ou caracteres quando a impressão for por contingência, já que deixaremos a impressão mais alta.
Private nConsNeg 	:= 0.4 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
Private nConsTex 	:= 0.5 // Constante para concertar o cálculo retornado pelo GetTextWidth.

	oDamdfe:SetResolution(72) //Tamanho estipulado para a DamDfe
	oDamdfe:SetLandscape()
	oDamdfe:SetPaperSize(DMPAPER_A4)
	oDamdfe:SetMargin(60,60,60,60)
	oDamdfe:lServer := oSetup:GetProperty(PD_DESTINATION) == AMB_SERVER
	// ----------------------------------------------
	// Define saida de impressão
	// ----------------------------------------------
	If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
		oDamdfe:nDevice := IMP_SPOOL
		// ----------------------------------------------
		// Salva impressora selecionada
		// ----------------------------------------------
		fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
		oDamdfe:cPrinter := oSetup:aOptions[PD_VALUETYPE]
	ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
		oDamdfe:nDevice := IMP_PDF
		// ----------------------------------------------
		// Define para salvar o PDF
		// ----------------------------------------------
		oDamdfe:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
	Endif

	Private PixelX := oDamdfe:nLogPixelX()
	Private PixelY := oDamdfe:nLogPixelY()

	RptStatus({|lEnd| DamdfeProc(@oDamdfe,@lEnd,cIdEnt,@lExistMDfe)},"Imprimindo Danfe...")
	
	IIF(lExistMDfe, oDamdfe:Preview(), Aviso("DAMDFE","Nenhum MDF-e a ser impresso nos parametros utilizados.",{"OK"},3))//Visualiza antes de imprimir

	FreeObj(oDamdfe)
	oDamdfe := Nil
	RestArea(aArea)
Return(.T.)


Static Function DamdfeProc(oDamdfe,lEnd,cIdEnt,lExistMDfe) 

Local aArea			:= GetArea()
Local cAliasMDF		:= GetNextAlias()
Local aAreaCC0		:= {}
Local aNotas		:= {}
Local aXML			:= {}
Local cNaoAut		:= ""
Local cAviso     	:= ""
Local cErro      	:= ""
Local cAutoriza  	:= ""
Local cModalidade	:= ""
Local cIndex	 	:= ""
Local cWhere		:= ""
Local nLenNotas		:= 0
Local nX			:= 0
Local lQuery		:= .F.
Local lUsaColab		:= UsaColaboracao("5")
Local oNfe

	If Pergunte("DAMDFE",.T.) 
		
		dbSelectArea("CC0")
		dbSetOrder(1)	
		
		#IFDEF TOP
					
			lQuery		:= .T.			
			cWhere	  	:= '%'			
			cWhere		+= " CC0_SERMDF = '" + MV_PAR01 + "' " 
			cWhere		+= " AND CC0_NUMMDF >= '" + MV_PAR02 + "' AND CC0_NUMMDF <= '" + MV_PAR03	+ "' "
			cWhere		+= " AND (CC0_STATUS = '3' OR SUBSTRING(CC0_CHVMDF, 35, 1) = '2' ) "//Somente MDF-e Autorizados
			cWhere		+= ' %' 
			
			BeginSql Alias cAliasMDF
								
				SELECT	CC0_FILIAL,CC0_DTEMIS,CC0_SERMDF,CC0_NUMMDF,CC0_PROTOC
				FROM %Table:CC0% CC0
				WHERE
				CC0.CC0_FILIAL = %xFilial:CC0% AND			
				%Exp:cWhere% AND
				CC0.%notdel%
			EndSql
								
		#ELSE
			cIndex		:= CriaTrab(NIL, .F.)
			cChave		:= IndexKey(1)
			cWhere 		:= 'CC0_FILIAL == "' + xFilial("CC0") + '" .And. '
			cWhere 		+= 'CC0->CC0_SERMDF == "'+ MV_PAR01+'" .And. '
			cWhere 		+= 'CC0->C00_NUMMDF >="'+ MV_PAR02+'" .And. CC0->C00_NUMMDF <="'+ MV_PAR03+'" .And. '
			cWhere		+= 'CC0->C00_STATUS == 3'		
			IndRegua(cAliasMDF, cIndex, cChave, , cWhere)
			DBSetIndex(cIndex + OrdBagExt())
			DBSetOrder( RetIndex(cAliasMDF) + 1)
			DBGoTop()		
		#ENDIF
		
		While !Eof() .And. xFilial("SF3") == (cAliasMDF)->CC0_FILIAL .And. (cAliasMDF)->CC0_SERMDF == MV_PAR01 .And.;
			(cAliasMDF)->CC0_NUMMDF >= MV_PAR02 .And. (cAliasMDF)->CC0_NUMMDF <= MV_PAR03						
					
			aadd(aNotas,{})
			aadd(Atail(aNotas),(cAliasMDF)->CC0_SERMDF)
			aadd(Atail(aNotas),(cAliasMDF)->CC0_NUMMDF)
						
			dbSelectArea(cAliasMDF)
			dbSkip()
			
			If lEnd
				Exit
			EndIf
		EndDo	
			
		If Len(aNotas) > 0
			aAreaCC0 := CC0->(GetArea())
			if lUsaColab //Tratamento do TOTVS Colaboração				
				aXml := GetXMLColab(aNotas,lUsaColab)
			else
				aXml := GetXML(cIdEnt,aNotas)			
			endif
			
			nLenNotas := Len(aNotas)
			For nX := 1 To nLenNotas 
				If !Empty(aXML[nX][2])
					If !Empty(aXml[nX])
						cAutoriza   := aXML[nX][1]
						cModalidade := aXML[nX][4]
					Else
						cAutoriza   := ""		
						cModalidade := "1"			
					EndIf
					If (!Empty(cAutoriza) .Or. Alltrim(aXML[nX][4]) $ "2")					
						cAviso 	:= ""
						cErro  	:= ""
						oNfe 	:= XmlParser(aXML[nX][2],"_",@cAviso,@cErro)					
						
						If Empty(cAviso) .And. Empty(cErro)
							ImpDet(@oDamdfe,oNfe,cAutoriza,cModalidade,aXML[nX][5],aXML[nX][6])																	
							lExistMDfe := .T.
						EndIf

						oNfe     := nil
						oNfeDPEC := nil
					Else
						cNaoAut += aNotas[nX][01]+aNotas[nX][02]+CRLF
					EndIf
				EndIf
			Next nX
			
			aNotas := {}
			
			RestArea(aAreaCC0)
			DelClassIntF()
		EndIf
		If !lQuery
			DBClearFilter()
			Ferase(cIndex+OrdBagExt())
		EndIf
		If !Empty(cNaoAut)
			Aviso("SPED","As seguintes notas não foram autorizadas: "+CRLF+CRLF+cNaoAut,{"Ok"},3)
		EndIf

	EndIF
	RestArea(aArea)

Return(.T.)

//----------------------------------------------------------------------
/*/{Protheus.doc} ImpDet
Controle do Fluxo do relatorio.

@author Rafael Iaquinto
@since 27/02/2014
@version 1.0 

@param	oDamdfe 		 Objeto gráfico da FWMSPrinter 
		oNFe 		 	Objeto XML do MDF-e
		cAutoriza	 	Numero de autorização do MDF-e
		cModalidade	Modalidade que o MDF-e foi autorizado.

@return .T.
/*/
//-----------------------------------------------------------------------
Static Function ImpDet(oDamdfe,oMdfe,cAutoriza,cModalidade,cRecDthora,cRecDt)

PRIVATE oFont08		:= TFont():New("ARIAL", 8, 8,,.F.,,,,.T.,.F.)
PRIVATE oFont10		:= TFont():New("ARIAL",10,10,,.F.,,,,.T.,.F.)
PRIVATE oFont10N	:= TFont():New("ARIAL",10,10,,.T.,,,,.T.,.F.)
PRIVATE oFont11		:= TFont():New("ARIAL",11,11,,.F.,,,,.T.,.F.)
PRIVATE oFont11N	:= TFont():New("ARIAL",11,11,,.T.,,,,.T.,.F.)
PRIVATE oFont12		:= TFont():New("ARIAL",12,12,,.F.,,,,.T.,.F.)
PRIVATE oFont12N	:= TFont():New("ARIAL",12,12,,.T.,,,,.T.,.F.)
PRIVATE oFont13		:= TFont():New("ARIAL",13,13,,.F.,,,,.T.,.F.)
PRIVATE oFont13N	:= TFont():New("ARIAL",13,13,,.T.,,,,.T.,.F.)
PRIVATE oFont14N	:= TFont():New("ARIAL",14,14,,.T.,,,,.T.,.F.)  
PRIVATE oFont15N	:= TFont():New("ARIAL",15,15,,.T.,,,,.T.,.F.)  
PRIVATE oBrush1 	:= TBrush():New( , CLR_GRAY)
PRIVATE lUsaColab	:= UsaColaboracao("5")
PRIVATE oNfe		:= oMdfe
PRIVATE nFolhas		:= 1
PRIVATE nFolhAtu	:= 1

	PrtDamdfe(@oDamdfe,cAutoriza,cModalidade,cRecDthora,cRecDt)
Return(.T.)


//-----------------------------------------------------------------------
/*/{Protheus.doc} PrtDamdfe
Impressao do formulario DANFE grafico conforme laytout no formato retrato

@author Rafael Iaquinto
@since 27/02/2014
@version 1.0 

@param	oDamdfe 		 Objeto gráfico da FWMSPrinter 
		oNFe 		 	Objeto XML do MDF-e
		cAutoriza	 	Numero de autorização do MDF-e
		cModalidade	Modalidade que o MDF-e foi autorizado.

@return .T.
/*/
//-----------------------------------------------------------------------
Static Function PrtDamdfe(oDamdfe,cAutoriza,cModalidade,cRecDthora,cRecDt)

Local nCont	:= 1
Local nLin	:= 0
Local aCab	:= {}

	aAdd(aCab, {;
				AllTrim(oNfe:_MDFE:_INFMDFE:_IDE:_nMDF:TEXT),;
				AllTrim(oNfe:_MDFE:_INFMDFE:_IDE:_SERIE:TEXT),;
				AllTrim(STRTRAN( SUBSTR( oNfe:_MDFE:_INFMDFE:_IDE:_dhEmi:TEXT, 1, AT('T', oNfe:_MDFE:_INFMDFE:_IDE:_dhEmi:TEXT) - 1) , '-', '')),;
				AllTrim(STRTRAN( SUBSTR( oNfe:_MDFE:_INFMDFE:_IDE:_dhEmi:TEXT, AT('T', oNfe:_MDFE:_INFMDFE:_IDE:_dhEmi:TEXT) + 1, 5) , ':', '')),;
				AllTrim(STRTRAN(  UPPER( oNFE:_MDFE:_INFMDFE:_ID:TEXT),'MDFE','')),;
				AllTrim(cAutoriza),;
				AllTrim(cModalidade),;
				cRecDt,;
				cRecDthora,;
				AllTrim(oNfe:_MDFE:_INFMDFE:_EMIT:_XNOME:TEXT),;
				AllTrim(oNfe:_MDFE:_INFMDFE:_EMIT:_XFANT:TEXT);
			   })

	oDamdfe:StartPage()
		DamdfeCab( @oDamdfe, aCab[nCont], @nLin ) //Cabeçalho
		DamdfeVCP( @oDamdfe, @nLin ) 			  //Veiculo - Condutor - Pedagio
		DamdfeCCar(@oDamdfe, @nLin ) 			  //Informações da Composição da Carga
		DamdfeObs( @oDamdfe, @nLin ) 			  //Observação
		fPrintCObs(oDamdfe, @nLin)
	oDamdfe:EndPage()

Return(.T.)

//-----------------------------------------------------------------------
/*/{Protheus.doc} DamdfeCab
Impressao do Cabeçalho da DANFE

@author Thiago Yoshiaki Miyabara Nascimento - Shiny
@since 03/09/2019
@version 1.0 

@param	oDamdfe 		Objeto gráfico da FWMSPrinter 
		aCab 		 	Array dados do cabeçalho
		nLin	 		Linha referencia para impressão
@return Nil
/*/
//-----------------------------------------------------------------------
Static Function DamdfeCab(oDamdfe, aCab, nLin)

Local cStartPath	:= GetSrvProfString("Startpath","")
Local cLogoTp		:= cStartPath + cEmpAnt + cFilAnt + "logodamdfe.bmp"				//Insira o caminho do Logo da empresa, na variavel cLogoTp.
Local cCodEst       := ""
Local cUFDescarr	:= ""
Local cAux			:= ""
Local cQrCode		:= ""
Local cDateTime		:= ""
Local nPos 			:= 0
Local nQCTE			:= 0
Local nQNFE			:= 0
Local nQCarga		:= 0
Local nLinQrChav	:= 0

	If IsSrvUnix() .And. GetRemoteType() == 1
		cLogoTp := StrTran(cLogoTp,"/","\")
	Endif

	//BOX: Logo
	nLin := 0080
	oDamdfe:SayBitmap(nLin-nPosIniCtg, 0005,cLogoTp,0100,0060 ) //Logo

	//BOX: Controle do Fisco QRCode e Codigo de barras-- Lado Direito do relatorio esta com estes dados com nLin Fixos
	If Type( 'oNFE:_MDFE:_INFMDFESUPL:_QRCODMDFE:TEXT') != 'U' .And. !Empty(oNFE:_MDFE:_INFMDFESUPL:_QRCODMDFE:TEXT)
		cQrCode := oNFE:_MDFE:_INFMDFESUPL:_QRCODMDFE:TEXT 
		nPos 	:= At("tpAmb=", cQrCode) + Len("tpAmb=")
		cQrCode := Substr(cQrCode, 1, nPos)	
	EndIf		
	nLinQrChav := 210
	oDamdfe:QRCode(nLinQrChav-nPosIniCtg, 530, cQrCode, 100)

	nLinQrChav += 5
	oDamdfe:Say(nLinQrChav-nPosIniCtg, 0332, 'CONTROLE DO FISCO', oFont12) 
	nLinQrChav += 57 //0272
	oDamdfe:Code128C(nLinQrChav-nPosIniCtg, 0332, aCab[5], 60)

	nLinQrChav += 18 //0290

	oDamdfe:Say( nLinQrChav-nPosIniCtg, 0332, "Chave de Acesso", oFont12N)
	nLinQrChav += 10
	oDamdfe:Say( nLinQrChav-nPosIniCtg, 0332, Transform(AllTrim(aCab[5]),"@r 99.9999.99.999.999/9999-99-99-999-999.999.999.999.999.999.9"), oFont11)
	nLinQrChav += 10
	oDamdfe:Say( nLinQrChav-nPosIniCtg, 0332, "Consulte em ", oFont11)
	oDamdfe:Say( nLinQrChav-nPosIniCtg, 0382, "https://dfe-portal.sefazvirtual.rs.gov.br/MDFe/consulta ", oFont11N)

	Do Case
		Case Type("oNfe:_MDFE:_INFMDFE:_EMIT:_CNPJ") == "O"
			cAux := TransForm(oNfe:_MDFE:_INFMDFE:_EMIT:_CNPJ:TEXT, "@r 99.999.999/9999-99")
		Case Type("oNfe:_MDFE:_INFMDFE:_EMIT:_CPF") == "O"
			cAux := TransForm(oNfe:_MDFE:_INFMDFE:_EMIT:_CPF:TEXT, "@r 999.999.999-99")
		OtherWise
			cAux := Space(14)
	EndCase


	oDamdfe:Say(nLin-nPosIniCtg, 0190, aCab[10] + " - " + aCab[11], oFont15N)	//Razao Social
	//nLin += 20
	nLin += 10
	oDamdfe:Say(nLin-nPosIniCtg, 0190, oNfe:_MDFE:_INFMDFE:_EMIT:_ENDEREMIT:_XLGR:TEXT+","+oNfe:_MDFE:_INFMDFE:_EMIT:_ENDEREMIT:_NRO:TEXT, oFont10)	//Endereco

	nLin += 10
	oDamdfe:Say(nLin-nPosIniCtg, 0190, oNfe:_MDFE:_INFMDFE:_EMIT:_ENDEREMIT:_UF:TEXT + ' - ' + oNfe:_MDFE:_INFMDFE:_EMIT:_ENDEREMIT:_XMUN:TEXT + '  -  ' + oNfe:_MDFE:_INFMDFE:_EMIT:_ENDEREMIT:_CEP:TEXT, oFont10)	//Cidade, UF, CEP
	
	nLin += 10
	oDamdfe:Say(nLin-nPosIniCtg, 0190, 'CNPJ/CPF:', oFont10N)
	oDamdfe:Say(nLin-nPosIniCtg, 0235, cAux, oFont10) 
	oDamdfe:Say(nLin-nPosIniCtg, 0313, 'IE: ', oFont10N)
	oDamdfe:Say(nLin-nPosIniCtg, 0325, oNfe:_MDFE:_INFMDFE:_EMIT:_IE:TEXT, oFont10)
	oDamdfe:Say(nLin-nPosIniCtg, 0380, 'RNTRC: ' , oFont10N) 
	oDamdfe:Say(nLin-nPosIniCtg, 0415, AllTrim(  IIF(Type("oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_INFANTT:_RNTRC") <> "U", oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_INFANTT:_RNTRC:TEXT,"")), oFont10)	//RNTRC da Empresa

	//BOX: DAMDFE
	nLin += 30
	oDamdfe:Say(nLin-nPosIniCtg, 0005, "DAMDFE - ", oFont14N)
	oDamdfe:Say(nLin-nPosIniCtg, 0065, "Documento Auxiliar de Manifesto Eletrônico de Documentos Fiscais", oFont13N)

	nLin += 10

	// Box  Modelo / Serie / Numero / FL / Data e Hora de Emissão / UF Carregamento / UF Descarregamento
	oDamdfe:Box(nLin-nPosIniCtg, 0005, 0195-nPosIniCtg, 0140) //Box Modelo / Serie / Numero
	oDamdfe:Box(nLin-nPosIniCtg, 0148, 0195-nPosIniCtg, 0180)  //Box FL
	oDamdfe:Box(nLin-nPosIniCtg, 0188, 0195-nPosIniCtg, 0308)  //Box DATA E HORA DE EMISSÃO
	cCodEst		:= oNfe:_MDFE:_INFMDFE:_IDE:_UFINI:TEXT					
	oDamdfe:Box(nLin-nPosIniCtg, 0316, 0195-nPosIniCtg, 0370)  //Box UF CARREGAMENTO
	cUFDescarr	:= oNfe:_MDFE:_INFMDFE:_IDE:_UFFIM:TEXT
	oDamdfe:Box(nLin-nPosIniCtg, 0380, 0195-nPosIniCtg, 0450)  //Box UF DESCARREGAMENTO
	////////////////////////////////////////////////////////////////////////////////////////////////////
	nLin += 15

	// Titles  Modelo / Serie / Numero / FL / Data e Hora de Emissão / UF Carregamento / UF Descarregamento
	oDamdfe:Say(nLin-nPosIniCtg, 0007, "Modelo", oFont13)	//Modelo
	oDamdfe:Say(nLin-nPosIniCtg, 0047, "Serie" , oFont13)	//Serie
	oDamdfe:Say(nLin-nPosIniCtg, 0090, "Número", oFont13)	//Numero
	oDamdfe:Say(nLin-nPosIniCtg, 0150, "FL"  , oFont13)		//Folha
	oDamdfe:Say(nLin-nPosIniCtg, 0190, "Data e Hora de Emissão", oFont13)//Emissao
	oDamdfe:Say(nLin-nPosIniCtg, 0318, "UF Carreg." , oFont13) //UF Carregamento
	oDamdfe:Say(nLin-nPosIniCtg, 0382, "UF Descarreg.", oFont13) //UF Descarregamento
	////////////////////////////////////////////////////////////////////////////////////////////////////
	nLin += 10

	// Dados  Modelo / Serie / Numero / FL / Data e Hora de Emissão / UF Carregamento / UF Descarregamento
	oDamdfe:Say(nLin-nPosIniCtg, 0007, "58", oFont13) //Modelo
	oDamdfe:Say(nLin-nPosIniCtg, 0047, cValtoChar( Val(aCab[2]) ), oFont13) //Serie
	oDamdfe:Say(nLin-nPosIniCtg, 0090, cValtoChar( Val(aCab[1]) ), oFont13) //Numero
	oDamdfe:Say(nLin-nPosIniCtg, 0150, AllTrim(Str(nFolhAtu)) + "/" + AllTrim(Str(nFolhas)), oFont13) //FL
	nFolhAtu++
	oDamdfe:Say(nLin-nPosIniCtg, 0190, SubStr(AllTrim(aCab[3]), 7, 2) + '/'   +;
							SubStr(AllTrim(aCab[3]), 5, 2) + "/"   +;
							SubStr(AllTrim(aCab[3]), 1, 4) + " - " +;
							SubStr(AllTrim(aCab[4]), 1, 2) + ":"   +;
							SubStr(AllTrim(aCab[4]), 3, 2) + ":00", oFont13N) //Emissao
	oDamdfe:Say(nLin-nPosIniCtg, 0318, cCodEst, oFont13N) //UF Carregamento
	oDamdfe:Say(nLin-nPosIniCtg, 0382, cUFDescarr, oFont13N) //UF Descarregamento
	////////////////////////////////////////////////////////////////////////////////////////////////////
	nLin += 30
	
	oDamdfe:Say(nLin-nPosIniCtg, 0005, "Modelo Rodoviário de Carga", oFont14N) //Title Modelo Rodoviário de Carga
	nLin += 10
			
	// Box  Qtd.Cte / Qtd.NFe / Peso Total (Kg) 
	If Type("oNfe:_MDFE:_INFMDFE:_TOT:_QCTE") <> "U"
		nQCTE	:= oNfe:_MDFE:_INFMDFE:_TOT:_QCTE:TEXT	
	EndIf
	oDamdfe:Box(nLin-nPosIniCtg, 0005, 0260-nPosIniCtg, 0070) //Qtd.Cte

	If Type("oNfe:_MDFE:_INFMDFE:_TOT:_QNFE") <> "U"
		nQNFE 	:= 	oNfe:_MDFE:_INFMDFE:_TOT:_QNFE:TEXT
	EndIf
	oDamdfe:Box(nLin-nPosIniCtg, 0078, 0260-nPosIniCtg, 0143) //Qtd.NFe

	nQCarga		:= oNfe:_MDFE:_INFMDFE:_TOT:_QCARGA:TEXT
	oDamdfe:Box(nLin-nPosIniCtg, 0151, 0260-nPosIniCtg, 0300) //Peso Total (Kg)
	////////////////////////////////////////////////////////////////////////////////////////////////////
	nLin += 15

	// Titles  Qtd.Cte / Qtd.NFe / Peso Total (Kg) 
	oDamdfe:Say(nLin-nPosIniCtg, 0007, "Qtd. CT-e", oFont13)  //Qtd.Cte	
	oDamdfe:Say(nLin-nPosIniCtg, 0080, "Qtd. NF-e", oFont13)  //Qtd.NFe
	oDamdfe:Say(nLin-nPosIniCtg, 0153, "Peso Total (Kg)", oFont13) //Peso Total (Kg)
	////////////////////////////////////////////////////////////////////////////////////////////////////
	nLin += 10 //250

	// Dados  Qtd.Cte / Qtd.NFe / Peso Total (Kg) 
	oDamdfe:Say(nLin-nPosIniCtg, 0007, cValtoChar( nQCTE ), oFont13N) //Qtd.Cte	
	oDamdfe:Say(nLin-nPosIniCtg, 0080, cValtoChar( nQNFE ), oFont13N) //Qtd.NFe
	oDamdfe:Say(nLin-nPosIniCtg, 0153, cValtoChar(nQCarga), oFont13N) //Peso Total (Kg)
	////////////////////////////////////////////////////////////////////////////////////////////////////
	nLin += 35 //285

	//BOX: PROTOCOLO
	oDamdfe:Say(nLin-nPosIniCtg, 0005,"Protocolo de autorização", oFont12N)
	If ( aCab[7] <> "2" )  //Modalidade
		nLin += 10 //295
		oDamdfe:Say(nLin-nPosIniCtg, 0005,aCab[6], oFont12N)
		oDamdfe:Say(nLin-nPosIniCtg, 0105,cValToChar(aCab[8]) + '-', oFont12)
		oDamdfe:Say(nLin-nPosIniCtg, 0165,cValToChar(aCab[9]), oFont12)
	Else
		nLin += 3//288
		oBrushBlck	:= TBrush():New( , CLR_BLACK)
		oDamdfe:FillRect({nLin-nPosIniCtg,0005, (nLin + 27)-nPosIniCtg,0300}, oBrushBlck)
		nLin += 10
		oDamdfe:Say(nLin-nPosIniCtg, 0008,'EMISSÃO EM CONTINGÊNCIA. Obrigatória a autorização em', oFont12N, , CLR_WHITE)
		nLin += 10 //308
		cDateTime	:= " (" + SubStr(AllTrim(aCab[3]), 7, 2) + '/' + SubStr(AllTrim(aCab[3]), 5, 2) + "/" + SubStr(AllTrim(aCab[3]), 1, 4) + " - " + SubStr(AllTrim(aCab[4]), 1, 2) + ":" + SubStr(AllTrim(aCab[4]), 3, 2) + ")"
		oDamdfe:Say(nLin-nPosIniCtg, 0008,'168 horas após esta emissão.' + cDateTime, oFont12N, , CLR_WHITE)
	EndIf

	nLin := nLinQrChav + 25 //Ultima linha utilizada  + espaço de 35 para começar nova parte referente a Dados do Veiculo e Dados do Condutor
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} DamdfeVCP
Impressao de Dados do Veiculo e Dados do Condutor

@author Thiago Yoshiaki Miyabara Nascimento - Shiny
@since 03/09/2019
@version 1.0 

@param	oDamdfe 		Objeto gráfico da FWMSPrinter 
		nLin	 		Linha referencia para impressão
@return Nil
/*/
//-----------------------------------------------------------------------
Static Function DamdfeVCP(oDamdfe, nLin )

	Local nCount	:= 0
	Local nLinTit	:= nLin
	Local nLinSTit	:= nLinTit + 15
	Local nLinSep	:= nLinSTit + 5

	Local nLinVeic	:= 0
	Local nLinCond	:= 0

	oDamdfe:Say(nLinTit-nPosIniCtg, 0005, "Veículo", oFont14N)
	oDamdfe:Say(nLinSTit-nPosIniCtg, 0005, "Placa", oFont11)
	oDamdfe:Say(nLinSTit-nPosIniCtg, 0085, "RNTRC", oFont11)
		
	oDamdfe:FillRect({nLinSep-nPosIniCtg,0005,(nLinSep + 5)-nPosIniCtg,0300},oBrush1)
			
	oDamdfe:Say(nLinTit-nPosIniCtg, 0332, "Condutor", oFont14N)
	oDamdfe:Say(nLinSTit-nPosIniCtg, 0332, "CPF", oFont11)
	oDamdfe:Say(nLinSTit-nPosIniCtg, 0440, "Nome", oFont11)
		
	oDamdfe:FillRect({nLinSep-nPosIniCtg,0332,(nLinSep + 5)-nPosIniCtg,800}, oBrush1)

	//-- Dados do Veiculo
	nLin := nLinSep + 10 //0380	
	If Type( "oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO" ) <> "A"
		
		oDamdfe:Say(nLin-nPosIniCtg, 0005, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_PLACA:TEXT), oFont10N)

		If Type('oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_PROP:_RNTRC') <> 'U'
			oDamdfe:Say(nLin-nPosIniCtg, 0085, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_PROP:_RNTRC:TEXT), oFont10N)
		EndIf
	Else
		nLinVeic   := nLin
		For nCount := 1 To Len( oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO )
			oDamdfe:Say(nLinVeic-nPosIniCtg, 0005, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO[nCount]:_PLACA:TEXT), oFont10N)

			If ValAtrib("oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO[" + Alltrim(Str(nCount)) + "]:_PROP:_RNTRC") <> 'U'
				oDamdfe:Say(nLinVeic-nPosIniCtg, 0085, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO[nCount]:_PROP:_RNTRC:TEXT), oFont10N)
			EndIf

			nLinVeic += 10
		Next nCount
	EndIf

	//--- Dados Condutor CPF  e Nome
	If Type( "oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_CONDUTOR" ) <> "A"
		
		oDamdfe:Say(nLin-nPosIniCtg, 0332, Transform(AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_CONDUTOR:_CPF:TEXT),"@r 999.999.999-99"), oFont10N)
		oDamdfe:Say(nLin-nPosIniCtg, 0440, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_CONDUTOR:_XNOME:TEXT), oFont10N)
	Else	
		nLinCond   := nLin
		For nCount := 1 To Len( oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_CONDUTOR )
			oDamdfe:Say(nLinCond-nPosIniCtg, 0332, Transform(AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_CONDUTOR[nCount]:_CPF:TEXT),"@r 999.999.999-99"), oFont10N)
			oDamdfe:Say(nLinCond-nPosIniCtg, 0440, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_CONDUTOR[nCount]:_XNOME:TEXT), oFont10N)

			nLinCond += 10
		Next nCount
	EndIf

	nLin :=	IIF( (nLinVeic + nLinCond) > 0, Max(nLinVeic, nLinCond), nLin)

	//-- Dados do Reboque
	nLinVeic := 0
	If Type( "oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE" ) <> "A"

		nLin += 10

		If Type( "oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE:_PLACA" ) <> "U"
			oDamdfe:Say(nLin-nPosIniCtg, 0005, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE:_PLACA:TEXT), oFont10N)
		EndIf

		If Type( "oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE:_PROP:_RNTRC" ) <> "U"
			oDamdfe:Say(nLin-nPosIniCtg, 0085,AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE:_PROP:_RNTRC:TEXT), oFont10N)
		EndIf
	Else
		nLinVeic   := nLin + 10
		For nCount := 1 To Len( oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE )
			If Type( "oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE[" + Alltrim(Str(nCount)) + "]:_PLACA" ) <> "U"
				oDamdfe:Say(nLinVeic-nPosIniCtg, 0005,  AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE[nCount]:_PLACA:TEXT), oFont10N)
			EndIf

			If Type( "oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE[" + Alltrim(Str(nCount)) + "]:_PROP:_RNTRC" ) <> "U"
				oDamdfe:Say(nLinVeic-nPosIniCtg, 0085, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE[nCount]:_PROP:_RNTRC:TEXT), oFont10N)
			EndIf

			nLinVeic += 10
		Next nCount
		nLin := nLinVeic
	EndIf

	nLin += 25

	//--- Vale Pedagio
	oDamdfe:Say(nLin-nPosIniCtg, 0005, "Vale Pedágio", oFont14N)
	nLin += 12
	oDamdfe:Say(nLin-nPosIniCtg, 0005, "Responsável CNPJ", oFont11N)
	oDamdfe:Say(nLin-nPosIniCtg, 0105, "Fornecedor CNPJ", oFont11N)
	oDamdfe:Say(nLin-nPosIniCtg, 0205, "Nro Comprovante", oFont11N)
	nLin += 5
	oDamdfe:FillRect({nLin-nPosIniCtg, 0005, (nLin + 3) - nPosIniCtg, 300}, oBrush1)

	nLin += 20
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} DamdfeCCar
Impressao de Informações da Composição da Carga

@author Thiago Yoshiaki Miyabara Nascimento - Shiny
@since 03/09/2019
@version 1.0 

@param	oDamdfe 		Objeto gráfico da FWMSPrinter 
		nLin	 		Linha referencia para impressão
@return Nil
/*/
//-----------------------------------------------------------------------
Static Function DamdfeCCar(oDamdfe, nLin )

Local nY		:= 0
Local nP		:= 0
Local nLenChv	:= 0
Local aChNFe	:= {}

	If (oNfe:_MDFE:_INFMDFE:_IDE:_TPEMIS:TEXT == '2') //Emissão em Contingência - leiaute diferenciado

		fPrintCCar(@oDamdfe, @nLin ) //Cabeçalho Informações da Composição da carga
		
		If Type("oNfe:_MDfe:_InfMDfe:_infDoc:_infMunDescarga") <> "U"
			If ValType(oNfe:_MDfe:_InfMDfe:_infDoc:_infMunDescarga) == "A"
				For nY := 1 to len(oNfe:_MDfe:_InfMDfe:_infDoc:_infMunDescarga)
					If ValAtrType(oNfe:_MDfe:_InfMDfe:_infDoc:_infMunDescarga[nY]:_infNFe) == "A"
						For nP := 1 to Len(oNfe:_MD_infMunDescargafe:_InfMDfe:_infDoc:_infMunDescarga[nY]:_infNFe)
							aadd(aChNFe, oNfe:_MDfe:_InfMDfe:_infDoc:_infMunDescarga[nY]:_infNFe[nP])			
						Next nP
					Else
						aadd(aChNFe, oNfe:_MDfe:_InfMDfe:_infDoc:_infMunDescarga[nY]:_infNFe)			
					EndIf	
				Next nY
			Else
				If ValType(oNfe:_MDfe:_InfMDfe:_infDoc:_infMunDescarga:_infNFe) == "A"
					aChNFe := oNfe:_MDfe:_InfMDfe:_infDoc:_infMunDescarga:_infNFe
				Else
					aChNFe := {oNfe:_MDfe:_InfMDfe:_infDoc:_infMunDescarga:_infNFe}
				EndIf
			EndIf

			nLenChv := Len(aChNFe)
			For nY := 1 to nLenChv
				oDamdfe:Say(nLin-nPosIniCtg, 0005, "NFE - "+aChNFe[nY]:_CHNFE:text, oFont08)
				nLin += 10	

				If GetBrkNow( @oDamdfe, @nLin, nPosIniCtg, nY, nLenChv) //Valida Quebra de pagina
					fPrintCCar(@oDamdfe, @nLin ) //Cabeçalho Informações da Composição da carga	
				EndIf						
			Next nY

			nLin += 5
		EndIf
	EndIf

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} fPrintCCar
Impressao de Informações do Cabeçalho Informações da Composição da carga

@author Thiago Yoshiaki Miyabara Nascimento - Shiny
@since 03/09/2019
@version 1.0 

@param	oDamdfe 		Objeto gráfico da FWMSPrinter 
		nLin	 		Linha referencia para impressão
@return Nil
/*/
//-----------------------------------------------------------------------
Static Function fPrintCCar(oDamdfe, nLin )
		
	oDamdfe:Say(nLin-nPosIniCtg, 0005, "Informações da Composição da Carga", oFont14N)
	nLin += 5
	oDamdfe:FillRect({nLin-nPosIniCtg, 0005, (nLin + 3) - nPosIniCtg, 800}, oBrush1)	
	nLin += 15
	oDamdfe:Say(nLin-nPosIniCtg, 0005, "Informações dos documentos fiscais vinculados ao manifesto", oFont11N)	
	oDamdfe:Say(nLin-nPosIniCtg, 0330, "Informações da unidade de transporte", oFont11N)
	oDamdfe:Say(nLin-nPosIniCtg, 0585, "Informações da unidade de carga", oFont11N)
	nLin += 5
	oDamdfe:FillRect({nLin-nPosIniCtg, 0005, (nLin + 3) - nPosIniCtg, 800}, oBrush1)
	nLin += 15
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} DamdfeObs
Impressao da Seção de dados de Observações

@author Thiago Yoshiaki Miyabara Nascimento - Shiny
@since 03/09/2019
@version 1.0 

@param	oDamdfe 		Objeto gráfico da FWMSPrinter 
		nLin	 		Linha referencia para impressão
@return Nil
/*/
//-----------------------------------------------------------------------
Static Function DamdfeObs(oDamdfe, nLin )

Local cAux		:= ""
Local nX		:= 0
Local aMessage	:= {}	

	If Type("oNfe:_MDfe:_InfMDfe:_infAdic:_infAdFisco:TEXT") <> "U"	
		cAux := oNfe:_MDfe:_InfMDfe:_infAdic:_infAdFisco:TEXT	
		While !Empty(cAux)
			aadd(aMessage, SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux, IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf

	If Type("oNfe:_MDfe:_InfMDfe:_infAdic:_infCpl:TEXT") <> "U"	
		cAux := oNfe:_MDfe:_InfMDfe:_infAdic:_infCpl:TEXT	
		While !Empty(cAux)
			aadd(aMessage, SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
			cAux := SubStr(cAux, IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
		EndDo
	EndIf

	nLenMensagens := Len(aMessage)

	If nLenMensagens > 0

		GetBrkNow( @oDamdfe, @nLin, nPosSyCtge+35)

		fPrintCObs(@oDamdfe, @nLin, .T. ) //Cabecalho Observações
		For nX := 1 To nLenMensagens		
			oDamdfe:Say(nLin+nposSyCtge,0005,aMessage[nX], oFont08)
			//nLin += 2 
			If GetBrkNow( @oDamdfe, @nLin, nPosSyCtge, nX, nLenMensagens)
				fPrintCObs(@oDamdfe, @nLin, .T.) //Cabecalho Observações	
			EndIf	

			nLin += 10
		Next
	EndIf	

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} fPrintCObs
Impressao da Seção de Observações

@author Thiago Yoshiaki Miyabara Nascimento - Shiny
@since 03/09/2019
@version 1.0 

@param	oDamdfe 		Objeto gráfico da FWMSPrinter 
		nLin	 		Linha referencia para impressão
@return Nil
/*/
//-----------------------------------------------------------------------
Static Function fPrintCObs(oDamdfe, nLin, lMensAdic)

Local cObs := ""

DEFAULT	lMensAdic := .F.

	cObs := IIF(!lMensAdic, "Observação", "Observações")
			
	//GetBrkNow( @oDamdfe, @nLin, nPosSyCtge)

	oDamdfe:Say(nLin+nPosSyCtge, 0005, cObs, oFont12N)
	nLin += 7
	oDamdfe:FillRect({nLin+nposSyCtge,0005,(nLin + 3)+nposSyCtge,800}, oBrush1)

	If !lMensAdic .And. (oNfe:_MDFE:_INFMDFE:_IDE:_TPAMB:TEXT == '2') 	
		nLin += 10
		oDamdfe:Say(nLin+nposSyCtge, 0005, "MANIFESTO GERADO EM AMBIENTE DE HOMOLOGAÇÃO", oFont10)
	EndIf

	nLin += 10
Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetBrkNow
Função responsável por validar regra de quebra de página

@author Thiago Yoshiaki Miyabara Nascimento - Shiny
@since 03/09/2019
@version 1.0 

@param	oDamdfe 	Obrigatoria		Objeto gráfico da FWMSPrinter 
		nLin		Obrigatoria	 	Linha referencia para impressão
		nPosAux		Obrigatoria	 	Variavel responsavel por permitir variancia da variavel nLin
		nX			Opcional 		Variavel caso especificada, responsavel por validar posição de registro atual impresso caso esteja em um "laço"
		nQtdReg		Opcional		Variavel caso especificada, responsavel por validar o maximo de registros a serem impressos caso esteja em um "laço"
@return Nil
/*/
//-----------------------------------------------------------------------
Static Function GetBrkNow( oDamdfe, nLin, nPosAux, nX, nQtdReg)

Local lRet		:= .F.	
Local nAuxLin	:= nLin-nPosAux
Local lFisrtP	:= nFolhas == 1 			//Primeira pagina
Local lFolhaPar	:= Mod( nFolhas, 2 ) == 0

Default nX 		:= 0
Default nQtdReg	:= 0
				
	If ((nX + nQtdReg) == 0 ) .Or. ((nX + 1) <= nQtdReg) //Verifico se ainda existe registro a ser impresso

		If lRet :=  (!lFisrtP .And. lFolhaPar .And. nAuxLin >= HALFLINREP ) .Or. (nAuxLin >= MAXLINREP)
	
			nLin += 10

			If !IsInCallStack("fPrintCObs")
				fPrintCObs(@oDamdfe, @nLin)
			EndIf	

			If !lFisrtP .And. lFolhaPar
				oDamdfe:Say(nLin+nPosSyCtge-5, 0675, "CONTINUA NA PRÓXIMA PÁGINA", oFont10)
			Else
				oDamdfe:Say(nLin+nPosSyCtge-5, 0705, "CONTINUA NO VERSO", oFont10)
			EndIf
			//nLin += 7	
			//oDamdfe:Say(nLin+nPosSyCtge+10, 0735 , "Pag : " + StrZero(nFolhas,3), oFont08 , 100 )
			oDamdfe:EndPage()
			oDamdfe:StartPage()
			nFolhas++ //Incremento pagina	

			nPosAux := 0		
			nLin 	:= 0065
		EndIf
	EndIf

Return lRet

//----------------------------------------------------------------------
/*/{Protheus.doc} GetXML
Busca o XML do MDF-e no TSS.

@author Rafael Iaquinto
@since 27/02/2014
@version 1.0 

@param	cIdEnt 		 	Entidade no TSS 
		aIdNFe 		 	aIdNFe - Array com os ID a serem consultados.				

@return .aRetorno		Retorno com os dados do MDF-e.
/*/
//-----------------------------------------------------------------------
Static Function GetXML(cIdEnt,aIdNFe)  

Local aRetorno		:= {}
Local aDados 		:= {}
Local nLenaIdNfe	:= Len(aIdNfe) 
Local nZ			:= 0
Local nCount 		:= 0
        
	oWs := nil

	For nZ := 1 To nLenaIdNfe

		nCount++
		aDados := executeRetorna( aIdNfe[nZ], cIdEnt )
		
		if ( nCount == 10 )
			delClassIntF()
			nCount := 0
		endif
		
		aAdd(aRetorno,aDados)		
	Next nZ

Return(aRetorno)

//-----------------------------------------------------------------------
/*/{Protheus.doc} executeRetorna
Executa o retorna de notas

@author Rafael Iaquinto
@since 27/02/2014
@version 1.0 

@param  aNFe 		 Numero e serie para montar o CID para solicitar o XML 

@return aRetorno   Array com os dados da nota
/*/
//-----------------------------------------------------------------------
Static Function executeRetorna( aNfe, cIdEnt, lUsacolab )

Local aRetorno		:= {}
Local aDados		:= {} 
Local aIdNfe		:= {}
Local cAviso		:= "" 
Local cErro			:= "" 
Local cModTrans		:= ""
Local cProtocolo	:= ""
Local cRetorno		:= ""
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local cDtHrRec1		:= ""
Local dDtRecib		:= CToD("")
Local nDtHrRec1		:= 0
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 1
Local nCount		:= 0
Local oWS

Private oNFeRet
Private oDHRecbto
Private oDoc

Default lUsacolab	:= .F.

	aAdd(aIdNfe,aNfe)
	if !lUsacolab
		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN        := "TOTVS"
		oWS:cID_ENT           := cIdEnt
		oWS:nDIASPARAEXCLUSAO := 0
		oWS:_URL 			  := AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:oWSNFEID          := NFESBRA_NFES2():New()
		oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()  
		
		aadd(aRetorno,{"","",aIdNfe[nZ][1]+aIdNfe[nZ][2],"","",""})
		
		aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
		Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aIdNfe[nZ][1]+aIdNfe[nZ][2]
		
		If oWS:RETORNANOTASNX()
			If Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0
				For nX := 1 To Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5)
					cRetorno        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXML
					cProtocolo      := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CPROTOCOLO
					cDHRecbto    	:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXMLPROT			
					oNFeRet			:= XmlParser(cRetorno,"_",@cAviso,@cErro)
					cModTrans		:= IIf(ValAtrib("oNFeRet:_MDFe:_infMDFe:_ide:_tpEmis:TEXT") <> "U",IIf (!Empty("oNFeRet:_MDFe:_infMDFe:_ide:_tpEmis:TEXT"),oNFeRet:_MDFe:_infMDFe:_ide:_tpEmis:TEXT,1),1)			
										
					nY := aScan(aIdNfe,{|x| x[1]+x[2] == SubStr(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:CID,1,Len(x[1]+x[2]))})
					
					If !Empty(cProtocolo)
						oDHRecbto := XmlParser(cDHRecbto,"","","")
						cDtHrRec  := IIf(ValAtrib("oDHRecbto:_ProtMDfe:_INFPROT:_DHRECBTO:TEXT") <> "U",oDHRecbto:_ProtMDfe:_INFPROT:_DHRECBTO:TEXT,"")
						nDtHrRec1 := RAT("T",cDtHrRec)
		
						If nDtHrRec1 <> 0
							cDtHrRec1 := SubStr(cDtHrRec,nDtHrRec1+1)
							dDtRecib  := SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
						EndIf
					Else				
						cDtHrRec  := IIf(ValAtrib("oNFeRet:_MDFe:_infMDFe:_ide:_dhEmi:TEXT") <> "U",oNFeRet:_MDFe:_infMDFe:_ide:_dhEmi:TEXT,"")
						nDtHrRec1 := RAT("T",cDtHrRec)
		
						If nDtHrRec1 <> 0
							cDtHrRec1 := SubStr(cDtHrRec,nDtHrRec1+1)
							dDtRecib  := SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
						EndIf						
					EndIf
					
					If nY > 0						
						aRetorno[nY][1] := cProtocolo 
						aRetorno[nY][2] := cRetorno
						aRetorno[nY][4] := cModTrans
						aRetorno[nY][5] := cDtHrRec1
						aRetorno[nY][6] := dDtRecib				
					EndIf			
				Next nX		
			EndIf
		Else			
			Aviso("DANFE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
		EndIf
	else
		oDoc 			:= ColaboracaoDocumentos():new()		
		oDoc:cModelo	:= "MDF"
		oDoc:cTipoMov	:= "1"									
		oDoc:cIDERP		:= "MDF"+aIdNfe[nZ][1]+aIdNfe[nZ][2]+FwGrpCompany()+FwCodFil()
		
		aadd(aRetorno,{"","",aIdNfe[nZ][1]+aIdNfe[nZ][2],"","",""})
		
		if oDoc:consultar()
			aDados := ColDadosNf(1)
			
			if !Empty(oDoc:cXMLRet)
				cRetorno	:= oDoc:cXMLRet 
			else
				cRetorno	:= oDoc:cXml
			endif
			
			aDadosXml := ColDadosXMl(cRetorno, aDados, @cErro, @cAviso)
									
			cProtocolo		:= aDadosXml[1]		
			cModTrans		:= aDadosXml[4]
			
			//Tratamento para gravar a hora da transmissao da NFe
			If !Empty(cProtocolo)
				cDtHrRec		:= aDadosXml[7]
				nDtHrRec1		:= RAT("T",cDtHrRec)
				
				If nDtHrRec1 <> 0
					cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
					dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
				EndIf				
			Else				
				cDtHrRec  := aDadosXml[8]
				nDtHrRec1 := RAT("T",cDtHrRec)

				If nDtHrRec1 <> 0
					cDtHrRec1 := SubStr(cDtHrRec,nDtHrRec1+1)
					dDtRecib  := SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
				EndIf						
			EndIf
			//Altero o cRetorno para o XML padrão que foi enviado.
			cRetorno := oDoc:cXml

			aRetorno[1][1] := cProtocolo 
			aRetorno[1][2] := cRetorno
			aRetorno[1][4] := cModTrans
			aRetorno[1][5] := cDtHrRec1
			aRetorno[1][6] := dDtRecib				
									
			cRetDPEC 	:= ""
			cProtDPEC	:= ""
		endif
	endif

	oWS       := Nil
	oNFeRet   := Nil

Return aRetorno[len(aRetorno)]

Static Function getXMLColab(aIdNFe,lUsaColab)

Local cIdEnt 	:= "000000"
Local nZ		:= 0
Local nCount 	:= 0
Local aDados	:= aRetorno := {}

	For nZ := 1 To len(aIdNfe) 

		nCount++
		aDados := executeRetorna( aIdNfe[nZ], cIdEnt, lUsaColab )
		
		If ( nCount == 10 )
			delClassIntF()
			nCount := 0
		EndIf
		
		aAdd(aRetorno,aDados)		
	Next nZ

Return(aRetorno)


//-----------------------------------------------------------------------
/*/{Protheus.doc} EspacoAt
Pega uma posição (nTam) na string cString, e retorna o 
caractere de espaço anterior. 

@author Rafael Iaquinto
@since 27/02/2014
@version 1.0 

@param	cString	String para ser verificada. 
		nTam		Posição da string.

@return aRetorno   Array com os dados da nota
/*/
//-----------------------------------------------------------------------
Static Function EspacoAt(cString, nTam)

Local nRetorno := 0
Local nX       := 0

	If nTam > Len(cString) .Or. nTam < 1 // Caso a posição (nTam) for maior que o tamanho da string, ou for um valor inválido, retorna 0.
		nRetorno := 0
		Return nRetorno
	EndIf

	// Procura pelo caractere de espaço anterior a posição e retorna a posição dele.
	nX := nTam
	While nX > 1
		If Substr(cString, nX, 1) == " "
			nRetorno := nX
			Return nRetorno
		EndIf	
		nX--
	EndDo

	nRetorno := 0 // Caso não encontre nenhum caractere de espaço, é retornado 0.

Return nRetorno
//-----------------------------------------------------------------------	
/*/{Protheus.doc} ColDadosNf
Devolve os dados com a informação desejada conforme parâmetro nInf.
 
@author 	Rafel Iaquinto
@since 		30/07/2014
@version 	11.9
 
@param	nInf, inteiro, Codigo da informação desejada:<br>1 - Normal<br>2 - Cancelametno<br>3 - Inutilização						

@return aRetorno Array com as posições do XML desejado, sempre deve retornar a mesma quantidade de posições.
/*/
//-----------------------------------------------------------------------
Static function ColDadosNf(nInf)

Local aDados:= {}

	If nInf == 1 //Informaçoes do MDF-e	
		aadd(aDados,"MDFEPROC|PROTMDFE|INFPROT|NPROT")	//1 - Protocolo de autorizacao 
		aadd(aDados,"MDFEPROC|PROTMDFE|INFPROT|TPAMB") 	//2 - Ambiente - XML AUTORIZADO
		aadd(aDados,"MDFE|INFMDFE|IDE|TPAMB")			 	//3 - Ambiente - XML ENVIO
		aadd(aDados,"MDFEPROC|MDFE|INFMDFE|IDE|TPEMIS")		//4 - Modalidade							
		aadd(aDados,"MDFEPROC|PROTMDFE|INFPROT|CSTAT")	//5 - Codigo de retorno do processamento SEFAZ 
		aadd(aDados,"MDFEPROC|PROTMDFE|INFPROT|XMOTIVO") //6 - Motivo do processamento da SEFAZ
		aadd(aDados,"MDFEPROC|PROTMDFE|INFPROT|DHRECBTO")//7 - Data e hora de recebimento. 
		aadd(aDados,"MDFE|INFMDFE|IDE|DHEMI") 				//8 - Data e hora da emissao.  		
	EndIf	
Return(aDados)

Static function UsaColaboracao(cModelo)
Return (IIF(FindFunction("ColUsaColab"), ColUsaColab(cModelo), .F.))

/*/{Protheus.doc} ValAtrib
Função utilizada para substituir o type onde não seja possível a sua retirada para não haver  
ocorrencia indevida pelo SonarQube.

@author 	valter Silva
@since 		09/01/2018
@version 	12
@return 	Nil
/*/
//-----------------------------------------------------------------------
Static Function ValAtrib(atributo)
Return (Type(atributo) )

/*/{Protheus.doc} ValAtrType
Função utilizada para substituir o type onde não seja possível a sua retirada para não haver  
ocorrencia indevida pelo SonarQube.

@author 	valter Silva
@since 		09/01/2018
@version 	12
@return 	Nil
/*/
//-----------------------------------------------------------------------
static Function ValAtrType(atributo)
Return (ValType(atributo) )
