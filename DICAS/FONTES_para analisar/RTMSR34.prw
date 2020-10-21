#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"


//----------------------------------------------------------------------------------
/*{Protheus.doc } RTMSR34
Impressão Manifesto 3.00a
@author Leandro Paulino
@since  28/06/2019     
/*/
//----------------------------------------------------------------------------------

User Function RTMSR34()

//--Variáveis do layout de impressão
Local aCab				:= {}
Local ofont12N			:= TFont():New("ARIAL",12,12,,.T.,,,,.T.,.F.)
Local oFont13			:= TFont():New("ARIAL",13,13,,.T.,,,,.T.,.F.)
Local oFont13N			:= TFont():New("ARIAL",13,13,,.T.,,,,.T.,.F.)
Local oFont10			:= TFont():New("ARIAL",10,10,,.F.,,,,.T.,.F.)
Local oFont10N			:= TFont():New("ARIAL",10,10,,.T.,,,,.T.,.F.)
Local oFont11			:= TFont():New("ARIAL",11,11,,.F.,,,,.T.,.F.)
Local oFont14N			:= TFont():New("ARIAL",14,14,,.T.,,,,.T.,.F.)
Local cPerg				:= Iif(__lPyme,'RTMSR32P', 'RTMSR32')
Local nCont				:= 0
Local lSeqDes			:= .F.
Local cAmbiente			:= ""
//-- Buscar dados XML
Local aNotas			:= {}
Local aXML				:= {}
Local cAviso			:= ""
Local cErro				:= ""
Local cAutoriza			:= ""
Local cModalidade		:= ""
Local cIdEnt			:= ""
Local nX				:= 0
Local cStartPath
Local cSerie			:= Padr(0,Len(DT6->DT6_SERIE))
Local cModelo			:= "58"
Local nLinha			:= 0
Local nCount			:= 0
Local cFilePrint		:= ""
Local nQCTE				:= 0
Local cHoraBase     	:= ""
Local cRNTRC			:= ""
Local cAliasDA3			:= ""
Local lDTX_SERMAN		:= DTX->(FieldPos("DTX_SERMAN")) > 0
Local nContChv			:= 0
Local nLinCTe			:= 0
Local nColTipo			:= 0
Local nColChave   		:= 0
Local cChaveCTe			:= ""
Local lXmlCont			:= .F. //--Impressao em contingência
Local nLinReb			:= 0
Local nCntFor			:= 0
Local lImp				:= .F.
Local lMDFEAUT    		:= SuperGetMv('MV_MDFEAUT',,.F.) .And. ExistFunc("TmsMDFeAut") //--MDFe Automático
Local lTercRbq    		:= DTR->(ColumnPos("DTR_CODRB3")) > 0
Local oBrush1			:= Nil
Local oBrush2			:= Nil
Local nPosSyCtge		:= 0 //Indica a coordenada vertical em pixels ou caracteres quando a impressão for por contingência, já que deixaremos a observação mais a baixo.
Local nPosIniCtg		:= 0 //Indica a coordenada vertical em pixels ou caracteres quando a impressão for por contingência, já que deixaremos a impressão mais alta.
Local cIdEnt			:= ""
Local cError     		:= ""
Local oWS
Local cURL

//--Variáveis de controle

Local cPlacaVeic 		:= '' 	//--Placa do Cavalo
Local cPlacaRb1			:= ''	//--Placa do Reboque1
Local cPlacaRb2			:= ''	//--Placa do Reboque2
Local cPlacaRb3			:= ''	//--Placa do Reboque3

//-- Variaveis Private
Private cAliasMDF		:= GetNextAlias()
Private oDamdfe
Private nFolhas			:= 0
Private nFolhAtu		:= 1
Private PixelX			:= nil
Private PixelY			:= nil
Private nMM		   		:= 0
Private lXml			:= .T.
Private lUsaColab		:= UsaColaboracao("5")
Private oNfe

//Verifica se o arquivo sera gerado em Remote Linux
cStartPath := GetTempPath(.T.)

	cIdEnt := getCfgEntidade(@cError)
	If !Empty(cIdEnt)
		cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)
		oWS :=  WsSpedCfgNFe():New()
		oWS:cUSERTOKEN      := "TOTVS"
		oWS:cID_ENT         := cIdEnt
		oWS:nAmbienteMDFE   := 0 
		oWS:cVersaoMDFE     := "0.00"
		oWS:nModalidadeMDFE := 0
		oWS:cVERMDFELAYOUT  := "0.00"
		oWS:cVERMDFELAYEVEN := "0.00"
		oWS:nSEQLOTEMDFE    := 0
		oWS:cHORAVERAOMDFE  := '0'
		oWS:cHORARIOMDFE    := '0'
		oWS:_URL            := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		oWS:cModelo         := '58'
		oWS:CFGMDFE()
				
		cVersMdfe := oWS:OWSCFGMDFERESULT:CVERSAOMDFE
		cAmbiente  := oWS:OWSCFGMDFERESULT:CAMBIENTEMDFE
	EndIf

If lMDFEAUT .And. IsInCallStack("TmsMDFeAut") .And. (Len(PARAMIXB[1]) = 8)

	Pergunte(cPerg,.F.)	

	For nCntFor := 1 To Len(PARAMIXB)	
		mv_par01 := PARAMIXB[nCntFor][8]
		mv_par04 := PARAMIXB[nCntFor][1]  
		mv_par05 := PARAMIXB[nCntFor][1]  		
		mv_par06 := PARAMIXB[1][2] 
		mv_par07 := PARAMIXB[nCntFor][3]  
		mv_par08 := PARAMIXB[nCntFor][4]  	
		mv_par09 := PARAMIXB[nCntFor][4]  
		mv_par02 := PARAMIXB[nCntFor][5] 
		mv_par03 := PARAMIXB[nCntFor][5] 
		lImp     := PARAMIXB[nCntFor][7]	
		
	Next nCntFor
	
ElseIf !Pergunte(cPerg,.T.) 

 	Return()
 	
EndIf

If	!lUsaColab .And. !TMSSpedNFe(@cIdEnt,@cModalidade,,lUsaColab,cModelo)
	Return()
EndIf

//Se for contingencia nao busca do XML
If SubStr(cModalidade,1,1) == '2'
	lXmlCont := .T.
	nPosSyCtge := 075	
	nPosIniCtg := 045
EndIf


// Cria Arquivo de Trabalho - Documentos de Transporte
// Cria Arquivo de Trabalho - Documentos de Transporte
cAliasMDF := DataSource( 'DTX' )

cFilePrint:= "DAMDFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")

oDamdfe:=FWMSPrinter():New(cFilePrint,IMP_PDF,.F./*lAdjustToLegacy*/,/*cStartPath*/, lImp /*lDisabeSetup*/,/*lTReport*/,@oDamdfe,/*cPrinter*/,.F./*lServer*/,/*lPDFAsPNG*/,/*lRaw*/,.T./*lViewPDF*/,/*nQtdCopy*/)
oDamdfe:SetResolution(72)
oDamdfe:SetLandscape()
oDamdfe:SetPaperSize(DMPAPER_A4)
oDamdfe:SetMargin(60,60,60,60)

//--Salvar arquivo na pasta temporaria deverá seleciona no TOTVSPrinter Servidor,
//--Caso contrário salvará na pasta selecionada.
If oDamdfe:LSERVER == .T. 
	oDamdfe:cPathPDF := cStartPath //--Pasta Temp.
EndIf

PixelX  := oDamdfe:nLogPixelX()
PixelY  := oDamdfe:nLogPixelY()
nMM     := 0

While !(cAliasMDF)->(Eof())
	nCount:= 1
	oDamdfe:StartPage()

	If lDTX_SERMAN .And. !Empty((cAliasMDF)->DTX_SERMAN)
		cSerie := (cAliasMDF)->DTX_SERMAN
	EndIf

	//-- Buscar XML do WebService
	If lXml
		aNotas := {}
		aadd(aNotas,{})
		aAdd(Atail(aNotas),.F.)

		aadd(Atail(aNotas),"")
		aAdd(Atail(aNotas),"")
		If lUsaColab
			aAdd(Atail(aNotas),cSerie)
		Else
			aAdd(Atail(aNotas),'58'+cSerie)
		EndIf
		aAdd(Atail(aNotas),(cAliasMDF)->DTX_MANIFE) //Documento
		aadd(Atail(aNotas),"")
		aadd(Atail(aNotas),"")

		nX   := 1
		aXml := {}
		If lUsaColab
			//-- TOTVS Colaboracao 2.0
			aXml := TMSColXML(aNotas,@cModalidade,lUsaColab,"58")
		Else
			aXml := TMSGetXML(cIdEnt,aNotas,@cModalidade,cModelo)
		EndIf
		If !Empty(aXML[nX][2])
			If !Empty(aXml[nX])
				cAutoriza   := aXML[nX][1]
				cCodAutDPEC := aXML[nX][5]
			Else
				cAutoriza   := ""
				cCodAutDPEC := ""
			EndIf
			cAviso := ""
			cErro  := ""
			oNfe := XmlParser(aXML[nX][2],"_",@cAviso,@cErro)			
		EndIf
	EndIf

	nFolhas := 1

	If Type( 'oNfe:_MDFE:_INFMDFE:_IDE:_SERIE:TEXT' ) == 'U'
		lXml := .F. //Restricao de errorlog devido ao xml retornado
	EndIf

	cHoraBase:= StrTran(Left(Time(),5),':','')
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controla o documento a ser enviado para montagem do cabecalho.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nCont += 1
	If lXml
		aAdd(aCab, {;
		AllTrim((cAliasMDF)->DTX_MANIFE),;
		AllTrim(oNfe:_MDFE:_INFMDFE:_IDE:_SERIE:TEXT),;
		AllTrim(STRTRAN( SUBSTR( oNfe:_MDFE:_INFMDFE:_IDE:_dhEmi:TEXT, 1, AT('T', oNfe:_MDFE:_INFMDFE:_IDE:_dhEmi:TEXT) - 1) , '-', '')),;
		AllTrim(STRTRAN( SUBSTR( oNfe:_MDFE:_INFMDFE:_IDE:_dhEmi:TEXT, AT('T', oNfe:_MDFE:_INFMDFE:_IDE:_dhEmi:TEXT) + 1, 5) , ':', '')),;
		AllTrim(STRTRAN(UPPER(oNFE:_MDFE:_INFMDFE:_ID:TEXT),'MDFE','')),;
		AllTrim(aXML[nX][1]),;
		AllTrim((cAliasMDF)->DTX_CTGMDF),;
		aXML[nX][7],;
		aXML[nX][6] })
	Else
		aAdd(aCab, {;
		AllTrim((cAliasMDF)->DTX_MANIFE),;
		cSerie,;
		AllTrim((cAliasMDF)->DTX_DATMAN),;
		AllTrim((cAliasMDF)->DTX_HORMAN),;
		AllTrim((cAliasMDF)->DTX_CHVMDF),;
				(cAliasMDF)->DTX_PRIMDF,;
		AllTrim((cAliasMDF)->DTX_CTGMDF),;
		Iif((cAliasMDF)->DTX_FIMP == StrZero(1, Len(DTX->DTX_FIMP)), (cAliasMDF)->DTX_DATIMP, DtoS(dDataBase)),;
		Iif((cAliasMDF)->DTX_FIMP == StrZero(1, Len(DTX->DTX_FIMP)), (cAliasMDF)->DTX_HORIMP, cHoraBase) })
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Funcao responsavel por montar o cabecalho do relatorio                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nFolhAtu := 1
	lSeqDes  :=.F.
	TMSR34Cab(aCab[nCont],lXml, cAmbiente, nPosIniCtg,lXmlCont)

	oDamdfe:Say(0208-nPosIniCtg, 0005, "Modelo Rodoviário de Carga", ofont14N)
	
	If lXml
		If Type("oNfe:_MDFE:_INFMDFE:_TOT:_QCTE") <> "U"
			nQCTE:= oNfe:_MDFE:_INFMDFE:_TOT:_QCTE:TEXT
		EndIf
	Else
		nQCTE:= (cAliasMDF)->DTX_QTDCTE
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ BOX: QTDE CTE ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	oDamdfe:Box(0218-nPosIniCtg, 0005, 0258-nPosIniCtg, 0070)
	oDamdfe:Say(0233-nPosIniCtg, 0007, "Qtd. CT-e", ofont13)
	oDamdfe:Say(0243-nPosIniCtg, 0007, cValtoChar( nQCTE ), ofont13N)	

	oDamdfe:Box(0218-nPosIniCtg, 0078, 0258-nPosIniCtg, 0143)
	oDamdfe:Say(0233-nPosIniCtg, 0080, "Qtd. NF-e", ofont13)
	oDamdfe:Say(0243-nPosIniCtg, 0080, '0', ofont13N)	

	If lXML
		nQCarga:= oNfe:_MDFE:_INFMDFE:_TOT:_QCARGA:TEXT
	Else
		nQCarga:= (cAliasMDF)->DTX_PESO
	EndIf
	oDamdfe:Box(0218-nPosIniCtg, 0151, 0258-nPosIniCtg, 0300)
	oDamdfe:Say(0233-nPosIniCtg, 0153, "Peso Total (Kg)", ofont13)
	oDamdfe:Say(0243-nPosIniCtg, 0153, cValtoChar(nQCarga), oFont10)

	oDamdfe:Say(0330-nPosIniCtg, 0005, "Veículo"	, ofont14N)
	oDamdfe:Say(0345-nPosIniCtg, 0005, "Placa"		, ofont11)
	oDamdfe:Say(0345-nPosIniCtg, 0085, "RNTRC"		, ofont11)
	
	oBrush1 := TBrush():New( , CLR_GRAY)
	
	oDamdfe:FillRect({0350-nPosIniCtg,0005,0355-nPosIniCtg,0300},oBrush1)
		
	oDamdfe:Say(0330-nPosIniCtg, 0332, "Condutor"	, ofont14N)
	oDamdfe:Say(0345-nPosIniCtg, 0332, "CPF"		, ofont11)
	oDamdfe:Say(0345-nPosIniCtg, 0440, "Nome"		, ofont11)
	
	oDamdfe:FillRect({0350-nPosIniCtg,0332,0355-nPosIniCtg,800},oBrush1)

	//-- Dados da Placa
	If lXml
		oDamdfe:Say(0360-nPosIniCtg, 0005, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_PLACA:TEXT), oFont13N)
		If Type("oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE") <> "U"
			If Type( "oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE" ) <> "A"
				oDamdfe:Say(0370-nPosIniCtg, 0005, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE:_PLACA:TEXT), ofont13N)
			Else
				nLinReb	:= 370-nPosIniCtg
				For nCount := 1 To Len (oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE)
					oDamdfe:Say(nLinReb, 0005, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE[nCount]:_PLACA:TEXT), ofont13N)
					nLinReb += 10
				Next nCount
			EndIf
		EndIf
	Else
		//--- Veiculo
		If __lPyme
			cCodVei := (cAliasMDF)->DYB_CODVEI
			cAliasDA3 := DataSource( 'DA3' )
			cRNTRC  := AllTrim((cAliasDA3)->A2_RNTRC)
			cPlacaVeic := AllTrim((cAliasDA3)->DA3_PLACA)
			(cAliasDA3)->(dbCloseArea())
			
			//--- Reboque 1
			cCodVei := (cAliasMDF)->DYB_CODRB1
			cAliasDA3 := DataSource( 'DA3' )
			cPlacaRb1 := AllTrim((cAliasDA3)->DA3_PLACA)
			(cAliasDA3)->(dbCloseArea())
			
			//--- Reboque 2
			cCodVei := (cAliasMDF)->DYB_CODRB2
			cAliasDA3 := DataSource( 'DA3' )
			cPlacaRb2 := AllTrim((cAliasDA3)->DA3_PLACA)
			(cAliasDA3)->(dbCloseArea())
			
			//--- Reboque 3 
			cCodVei := (cAliasMDF)->DYB_CODRB3
			cAliasDA3 := DataSource( 'DA3' )
			cPlacaRb3 := AllTrim((cAliasDA3)->DA3_PLACA)			
			(cAliasDA3)->(dbCloseArea())
			
		Else
			
			cCodVei := (cAliasMDF)->DTR_CODVEI
			cAliasDA3 := DataSource( 'DA3' )
			cRNTRC  := AllTrim((cAliasDA3)->A2_RNTRC)
			cPlacaVeic := AllTrim((cAliasDA3)->DA3_PLACA)
			(cAliasDA3)->(dbCloseArea())
		
			//--- Reboque 1
			cCodVei := (cAliasMDF)->DTR_CODRB1
			cAliasDA3 := DataSource( 'DA3' )
			cPlacaRb1 := AllTrim((cAliasDA3)->DA3_PLACA)
			(cAliasDA3)->(dbCloseArea())
		
			//--- Reboque 2
			cCodVei := (cAliasMDF)->DTR_CODRB2
			cAliasDA3 := DataSource( 'DA3' )
			cPlacaRb2 := AllTrim((cAliasDA3)->DA3_PLACA)
			(cAliasDA3)->(dbCloseArea())
		
			//--- Reboque 3 
			cCodVei := (cAliasMDF)->DTR_CODRB3
			cAliasDA3 := DataSource( 'DA3' )
			cPlacaRb3 := AllTrim((cAliasDA3)->DA3_PLACA)
			(cAliasDA3)->(dbCloseArea())
			
		EndIf

		oDamdfe:Say(0360-nPosIniCtg, 0005, cPlacaVeic, ofont13N)
		oDamdfe:Say(0370-nPosIniCtg, 0005, cPlacaRb1 , ofont13N)
		oDamdfe:Say(0380-nPosIniCtg, 0005, cPlacaRb2 , ofont13N)
		oDamdfe:Say(0390-nPosIniCtg, 0005, cPlacaRb3 , ofont13N)

	EndIf

	//--- Dados do RNTRC

	If lXml
		If Type('oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_PROP:_RNTRC') <> 'U'
			oDamdfe:Say(0360-nPosIniCtg, 0085, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_PROP:_RNTRC:TEXT), oFont13N)
		EndIf
		If Type("oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE:_PROP:_RNTRC") <> "U"
			If Type( "oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE" ) <> "A"
				oDamdfe:Say(0370-nPosIniCtg, 0085, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE:_PROP:_RNTRC:TEXT), oFont13N)
			Else
				nLinReb	:= 0370-nPosIniCtg
				For nCount := 1 To Len (oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE)
					oDamdfe:Say(nLinReb, 0085, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICREBOQUE[nCount]:_PROP:_RNTRC:TEXT), ofont13N)
					nLinReb += 10
				Next nCount
			EndIf
		EndIf

		If Type('oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_PROP:_RNTRC') = 'U'
			If Type('oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_infANTT:_RNTRC') <> 'U'
				oDamdfe:Say(0360-nPosIniCtg, 0085, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_infANTT:_RNTRC:TEXT), oFont13N)
			EndIf
		EndIf

	Else
		oDamdfe:Say(0360-nPosIniCtg, 0085, AllTrim(cRNTRC), oFont13N)
	EndIf
	

	//--Dados do Condutor
	If lXML
		If Type( "oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_CONDUTOR" ) <> "A"
			oDamdfe:Say(0360-nPosIniCtg, 0332, Transform(AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_CONDUTOR:_CPF:TEXT),"@r 999.999.999-99"), oFont13N)
			oDamdfe:Say(0360-nPosIniCtg, 0440, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_CONDUTOR:_XNOME:TEXT), oFont13N)
		Else
			nLinha:= 360-nPosIniCtg
			For nCount := 1 To Len( oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_CONDUTOR )
				oDamdfe:Say(nLinha, 0332, Transform(AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_CONDUTOR[nCount]:_CPF:TEXT),"@r 999.999.999-99"), oFont13N)
				oDamdfe:Say(nLinha, 0440, AllTrim(oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_VEICTRACAO:_CONDUTOR[nCount]:_XNOME:TEXT), oFont13N)
				nLinha+= 10
			Next nCount
		EndIf
	Else
		nLinha:= 360-nPosIniCtg
		DUP->(DbSetOrder(1))
		If DUP->(MsSeek(xFilial('DUP')+(cAliasMDF)->DTX_FILORI+(cAliasMDF)->DTX_VIAGEM))
			While DUP->(!Eof()) .And. (DUP->DUP_FILORI == (cAliasMDF)->DTX_FILORI .AND. DUP->DUP_VIAGEM == (cAliasMDF)->DTX_VIAGEM)
				cCodMoto := DUP->DUP_CODMOT
				oDamdfe:Say(nLinha, 0332, Transform(AllTrim(Posicione("DA4",1,xFilial('DA4')+cCodMoto,'DA4_CGC')),"@r 999.999.999-99"), oFont13N)
				oDamdfe:Say(nLinha, 0440, AllTrim(Posicione("DA4",1,xFilial('DA4')+cCodMoto,'DA4_NOME')), oFont13N)
				nLinha+= 10
				DUP->(DbSkip())
			EndDo
		EndIf
	EndIf

	//--- Vale Pedagio
	oDamdfe:Say(0410-nPosIniCtg, 0005, "Vale Pedágio", ofont14N)

	oDamdfe:Say(0430-nPosIniCtg, 0005, "Responsável CNPJ", ofont12N)
	oDamdfe:Say(0430-nPosIniCtg, 0105, "Fornecedora CNPJ", ofont13N)
	oDamdfe:Say(0430-nPosIniCtg, 0205, "Nro Comprovante", ofont13N)
	oDamdfe:FillRect({0435-nPosIniCtg,0005,0438-nPosIniCtg,300},oBrush1)
	If lXML
		If Type('oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_INFANTT:_VALEPED:_DISP:_CNPJPG') <> 'U'
			oDamdfe:Say(0445-nPosIniCtg, 0005, oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_INFANTT:_VALEPED:_DISP:_CNPJPG:TEXT, oFont10)
		EndIf
		
		
		If Type('oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_INFANTT:_VALEPED:_DISP:_CNPJFORN') <> 'U'
			oDamdfe:Say(0445-nPosIniCtg, 0130, oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_INFANTT:_VALEPED:_DISP:_CNPJFORN:TEXT, oFont10)
		EndIf	
		
		
		If Type('oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_INFANTT:_VALEPED:_DISP:_NCOMPRA') <> 'U'
			oDamdfe:Say(0445-nPosIniCtg, 0230, oNfe:_MDFE:_INFMDFE:_INFMODAL:_RODO:_INFANTT:_VALEPED:_DISP:_NCOMPRA:TEXT, oFont10)
		EndIf
	Else

		DTR->(DbSetOrder(1))
		If DTR->(MsSeek(xFilial('DTR')+(cAliasMDF)->DTX_FILORI+(cAliasMDF)->DTX_VIAGEM)) .And. DTR->(ColumnPos('DTR_CNPJPG')) > 0
			nLinha := 0445-nPosIniCtg
			While DTR->(!Eof()) .And. (DTR->DTR_FILORI == (cAliasMDF)->DTX_FILORI .And. DTR->DTR_VIAGEM == (cAliasMDF)->DTX_VIAGEM)
				oDamdfe:Say(nLinha, 0005, Transform(AllTrim(DTR->DTR_CNPJPG),"@r 99.999.999/9999-99"), oFont11)
				oDamdfe:Say(nLinha, 0105, Transform(AllTrim(DTR->DTR_CNPJOP),"@r 99.999.999/9999-99"), oFont11)
				oDamdfe:Say(nLinha, 0205, AllTrim(DTR->DTR_CIOT), oFont11)
				nLinha+= 10
				DTR->(DbSkip())
			EndDo
		EndIf				

	EndIf		

	//--- Observacoes  	
 	oDamdfe:Say(0520+nPosSyCtge, 0005, "Observações", ofont12N)
 	oDamdfe:FillRect({0525+nposSyCtge,0005,0528+nposSyCtge,800},oBrush1)
 	If (lXML .And. oNfe:_MDFE:_INFMDFE:_IDE:_TPAMB:TEXT == '2') .Or. ((cAliasMDF)->DTX_AMBIEN == 2)
  		oDamdfe:Say(0535+nposSyCtge, 0005, "MANIFESTO GERADO EM AMBIENTE DE HOMOLOGAÇÃO", oFont10)
	EndIf
	
	If Type("oNfe:_MDFE:_INFMDFE:_infAdic:_infAdFisco:TEXT") != "U"
		cObs := oNfe:_MDFE:_INFMDFE:_infAdic:_infAdFisco:TEXT
		oDamdfe:Say(0545+nposSyCtge, 0005,Substr(cObs,1,110), oFont10N)
		oDamdfe:Say(0555+nposSyCtge, 0005,Substr(cObs,111,110), oFont10N)
		oDamdfe:Say(0565+nposSyCtge, 0005,Substr(cObs,221,100), oFont10N)
	EndIf
	
	If lXmlCont
		//--- Somente apresenta esse box quando for contingencia	  	
		oDamdfe:Say(0480-nPosIniCtg, 0005, "Informações da Composição da Carga", ofont13N)
	  	oDamdfe:FillRect({0485-nPosIniCtg,0005,0488-nPosIniCtg,800},oBrush1)
		
		oDamdfe:Say(0500-nPosIniCtg, 0005, "Informações dos Documentos Fiscais vinculados ao Manifesto", ofont13N)
		oDamdfe:FillRect({0505-nPosIniCtg,0005,0506-nPosIniCtg,0350},oBrush1)
		
	  	oDamdfe:Say(0500-nPosIniCtg, 0355, "Identificação de Unidade de Transporte", ofont13N)	  	
	  	oDamdfe:FillRect({0505-nPosIniCtg,0355,0506-nPosIniCtg,0600},oBrush1)
	  	
	  	oDamdfe:Say(0500-nPosIniCtg, 0605, "Identificação de Unidade de Carga", ofont13N)
	  	oDamdfe:FillRect({0505-nPosIniCtg,0605,0506-nPosIniCtg,0800},oBrush1)
	  
	    //Tag INFCTE
		If (Type( "oNFe:_MDFE:_INFMDFE:_INFDOC:_INFMUNDESCARGA:_INFCTE") <> 'U')
			If (ValType(oNFe:_MDFE:_INFMDFE:_INFDOC:_INFMUNDESCARGA:_INFCTE)  =='A')
			   nLinCTe			:= 0515-nPosIniCtg
			   nColTipo			:= 0005
			   nColChave    	:= 0030
	           For nContChv 	:= 1 to len(oNFe:_MDFE:_INFMDFE:_INFDOC:_INFMUNDESCARGA:_INFCTE)
					cChaveCTe 	:= oNFe:_MDFE:_INFMDFE:_INFDOC:_INFMUNDESCARGA:_INFCTE[nContChv]:_CHCTE:TEXT
					oDamdfe:Say(nLinCTE, nColTipo , "CTe"    , ofont13)
					oDamdfe:Say(nLinCTE, nColChave, cChaveCTe, ofont13)
					nLinCTe += 10
					If nLinCTe		== 0615-nPosIniCtg
						nColTipo	:= 0250
						nColChave	:= 0280
					EndIf
			   Next
			Else
	            cChaveCTe := oNFe:_MDFE:_INFMDFE:_INFDOC:_INFMUNDESCARGA:_INFCTE:_CHCTE:TEXT
	            oDamdfe:Say(0515-nPosIniCtg, 0005, "CTe"    , ofont13)
	  	        oDamdfe:Say(0515-nPosIniCtg, 0030, cChaveCTe, ofont13)
			EndIf
		ElseIf (Type( "oNFe:_MDFE:_INFMDFE:_INFDOC:_INFMUNDESCARGA") <> 'U')
			If (ValType(oNFe:_MDFE:_INFMDFE:_INFDOC:_INFMUNDESCARGA)  =='A')
			   nLinCTe		:= 0515-nPosIniCtg
			   nColTipo		:= 0005
			   nColChave    	:= 0030
	           For nContChv 	:= 1 to len(oNFe:_MDFE:_INFMDFE:_INFDOC:_INFMUNDESCARGA)
					//If ValType( oNFe:_MDFE:_INFMDFE:_INFDOC:_INFMUNDESCARGA[nContChv]:_INFCTE ) == "A" 
					cChaveCTe 	:= oNFe:_MDFE:_INFMDFE:_INFDOC:_INFMUNDESCARGA[nContChv]:_INFCTE:_CHCTE:TEXT
					oDamdfe:Say(nLinCTE-nPosIniCtg, nColTipo , "CTe"    , ofont13)
					oDamdfe:Say(nLinCTE-nPosIniCtg, nColChave, cChaveCTe, ofont13)
					nLinCTe += 10
					If nLinCTe		== 0615-nPosIniCtg
						nColTipo	:= 0250
						nColChave	:= 0280
					EndIf
			   Next
			Else
	            cChaveCTe := oNFe:_MDFE:_INFMDFE:_INFDOC:_INFMUNDESCARGA:_INFCTE:_CHCTE:TEXT
	            oDamdfe:Say(0515-nPosIniCtg, 0005, "CTe"    , ofont13)
	  	        oDamdfe:Say(0515-nPosIniCtg, 0030, cChaveCTe, ofont13)
			EndIf
		EndIf
		
		If Type("oNfe:_MDFE:_INFMDFE:_infAdic:_infAdFisco:TEXT") != "U"
		 	cObs := oNfe:_MDFE:_INFMDFE:_infAdic:_infAdFisco:TEXT
			oDamdfe:Say(0535, 0005,Substr(cObs,1,110), oFont10N)
			oDamdfe:Say(0565, 0005,Substr(cObs,111,110), oFont10N)
			oDamdfe:Say(0575, 0005,Substr(cObs,221,100), oFont10N)
		EndIf
	Else  	
		If Type("oNfe:_MDFE:_INFMDFE:_infAdic:_infAdFisco:TEXT") != "U"
			cObs := oNfe:_MDFE:_INFMDFE:_infAdic:_infAdFisco:TEXT
			oDamdfe:Say(0535, 0005,Substr(cObs,1,110), oFont10N)
			oDamdfe:Say(0555, 0005,Substr(cObs,111,110), oFont10N)
			oDamdfe:Say(0575, 0005,Substr(cObs,221,100), oFont10N)
		EndIf
	EndIf

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualizar o Status de Impressao no DAMDFE                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DTX->(dbSetOrder(1))
	If	DTX->(MsSeek(xFilial('DTX')+(cAliasMDF)->DTX_MANIFE+(cAliasMDF)->DTX_SERMAN)) .And. DTX->DTX_FIMP <> StrZero(1, Len(DTX->DTX_FIMP))
		RecLock('DTX',.F.)
		DTX->DTX_FIMP  := StrZero(1, Len(DTX->DTX_FIMP))
		DTX->DTX_DATIMP:= dDataBase
		DTX->DTX_HORIMP:= cHoraBase
		MsUnLock()
	EndIf

	oDamdfe:EndPage()

	(cAliasMDF)->(DbSkip())
EndDo

(cAliasMDF)->(dbCloseArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TERMINO ROTINA DE IMPRESSAO                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If File(cStartPath+cFilePrint+".REL")
	//-- Caso necessario, converte para .PDF para arquivo gerado com extensao .REL (impressao via Server)
	//-- File2Printer(cStartPath+cFilePrint+".REL", "PDF")
//EndIf*/
oDamdfe:Preview()

Return(.T.)

//----------------------------------------------------------------------------------
/*{Protheus.doc } TMSR34Cab
Funcao responsavel por montar o cabecalho do relatorio
@author Leandro Paulino
@since  28/06/2019     
/*/
//----------------------------------------------------------------------------------

Static Function TMSR34Cab(aCab,lXML, cAmbiente, nPosIniCtg,lXmlCont)
Local oFont07		:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)	//Fonte Arial 07
Local oFont08		:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)	//Fonte Arial 08
Local oFont10		:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)	//Fonte Arial 10
Local oFont10N		:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)	//Fonte Arial 10 Negrito
Local oFont11		:= TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)	//Fonte Arial 11
Local oFont11N		:= TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)	//Fonte Arial 11 Negrito
Local ofont13		:= TFont():New("Arial",13,13,,.F.,,,,.T.,.F.)
Local ofont13N		:= TFont():New("Arial",13,13,,.T.,,,,.T.,.F.)
Local oFont14N		:= TFont():New("ARIAL",14,14,,.T.,,,,.T.,.F.)
//Local oFont07    	:= TFont():New("Times New Roman",07,07,,.F.,,,,.T.,.F.)	//Fonte Times New Roman 07
Local cStartPath	:= GetSrvProfString("Startpath","")
Local cTmsAntt		:= SuperGetMv( "MV_TMSANTT", .F., .F. )	//Numero do registro na ANTT com 14 dígitos
Local cLogoTp	   	:= cStartPath + "logoDAMDFE" + cEmpAnt + ".BMP" //Insira o caminho do Logo da empresa logada, na variavel cLogoTp.
Local cUF        	:= ""
Local cUFDesc    	:= ""
Local cCodEst    	:= ""
Local aUF        	:= {}
Local aAreaSM0   	:= {}
Local cRota      	:= ""
Local cEndereco  	:= ""
Local cQrCode		:= ""
Local cSertms    	:= ''
Local cQryCab    	:= ''
Local cAliasDUD  	:= ''
Local oBrushBlck	:= Nil
Local nPosSign      := 0

Default aCab 		:= {}
Default lXml		:= .F.
Default cAmbiente	:= ''
Default nPosIniCtg	:= 0
Default lXmlCont    := .F.

If IsSrvUnix() .And. GetRemoteType() == 1
	cLogoTp := StrTran(cLogoTp,"/","\")
Endif

If  !File(cLogoTp)
	cLogoTp    := cStartPath + "DAMDFE.bmp"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenchimento do Array de UF                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aUF,{"RO","11"})
aAdd(aUF,{"AC","12"})
aAdd(aUF,{"AM","13"})
aAdd(aUF,{"RR","14"})
aAdd(aUF,{"PA","15"})
aAdd(aUF,{"AP","16"})
aAdd(aUF,{"TO","17"})
aAdd(aUF,{"MA","21"})
aAdd(aUF,{"PI","22"})
aAdd(aUF,{"CE","23"})
aAdd(aUF,{"RN","24"})
aAdd(aUF,{"PB","25"})
aAdd(aUF,{"PE","26"})
aAdd(aUF,{"AL","27"})
aAdd(aUF,{"MG","31"})
aAdd(aUF,{"ES","32"})
aAdd(aUF,{"RJ","33"})
aAdd(aUF,{"SP","35"})
aAdd(aUF,{"PR","41"})
aAdd(aUF,{"SC","42"})
aAdd(aUF,{"RS","43"})
aAdd(aUF,{"MS","50"})
aAdd(aUF,{"MT","51"})
aAdd(aUF,{"GO","52"})
aAdd(aUF,{"DF","53"})
aAdd(aUF,{"SE","28"})
aAdd(aUF,{"BA","29"})
aAdd(aUF,{"EX","99"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOX: Empresa                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oDamdfe:Box(0036, 0000, 0140, 0400)
oDamdfe:SayBitmap(0090-nPosIniCtg, 0005,cLogoTp,0150-nPosIniCtg,0040 )
oDamdfe:Say(0090-nPosIniCtg, 0190, Iif(lXML,oNfe:_MDFE:_INFMDFE:_EMIT:_XNOME:TEXT,AllTrim(SM0->M0_NOMECOM))    , oFont10N)

If lXML
    cEndereco := oNfe:_MDFE:_INFMDFE:_EMIT:_ENDEREMIT:_XLGR:TEXT
    cEndereco += ", " + oNfe:_MDFE:_INFMDFE:_EMIT:_ENDEREMIT:_NRO:TEXT

    If Type( "oNfe:_MDFE:_INFMDFE:_EMIT:_ENDEREMIT:_XCPL:TEXT" ) != "U"
        cEndereco += ", " + oNfe:_MDFE:_INFMDFE:_EMIT:_ENDEREMIT:_XCPL:TEXT
    EndIf

Else
    cEndereco := AllTrim(SM0->M0_ENDCOB)
EndIf

oDamdfe:Say(0100-nPosIniCtg, 0190, cEndereco, ofont10)	//Endereco
oDamdfe:Say(0110-nPosIniCtg, 0190, Iif(lXML, + oNfe:_MDFE:_INFMDFE:_EMIT:_ENDEREMIT:_XMUN:TEXT + '  -  ' + oNfe:_MDFE:_INFMDFE:_EMIT:_ENDEREMIT:_UF:TEXT + ' - ' + oNfe:_MDFE:_INFMDFE:_EMIT:_ENDEREMIT:_CEP:TEXT,;
                            + AllTrim(SM0->M0_CIDCOB) + ' - ' + AllTrim(SM0->M0_ESTCOB) + ' - ' + '  CEP.:  ' + AllTrim(SM0->M0_CEPCOB)) ,ofont10)	//Cidade, UF, CEP

oDamdfe:Say(0120-nPosIniCtg, 0190, 'CNPJ: ', ofont10N)
oDamdfe:Say(0120-nPosIniCtg, 0220, Iif(lXML,(Transform(oNfe:_MDFE:_INFMDFE:_EMIT:_CNPJ:TEXT,"@r 99.999.999/9999-99")), Transform(AllTrim(SM0->M0_CGC),"@r 99.999.999/9999-99") ),oFont10) 
oDamdfe:Say(0120-nPosIniCtg, 0298, 'IE: ', ofont10N)
oDamdfe:Say(0120-nPosIniCtg, 0310, Iif(lXML,oNfe:_MDFE:_INFMDFE:_EMIT:_IE:TEXT,AllTrim(SM0->M0_INSC)), ofont10)
oDamdfe:Say(0120-nPosIniCtg, 0365, 'RNTRC: ' , ofont10N) 
oDamdfe:Say(0120-nPosIniCtg, 0400, AllTrim( cTmsAntt),ofont10)	//RNTRC da Empresa


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOX: DACTE                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDamdfe:Say(0140-nPosIniCtg, 0005, "DAMDFE - ", oFont14N)
oDamdfe:Say(0140-nPosIniCtg, 0065, "Documento Auxiliar de Manifesto Eletrônico de Documentos Fiscais",oFont13)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³BOX: Modelo / Serie / Numero ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

oDamdfe:Box(0150-nPosIniCtg, 0005, 0185-nPosIniCtg, 0140)
oDamdfe:Say(0165-nPosIniCtg, 0007, "Modelo" , oFont13)	//Modelo
oDamdfe:Say(0175-nPosIniCtg, 0007, "58",ofont13)

oDamdfe:Say(0165-nPosIniCtg, 0047, "Serie"  , oFont13)	//Serie
oDamdfe:Say(0175-nPosIniCtg, 0047, cValtoChar( Val(aCab[2]) ), ofont13)

oDamdfe:Say(0165-nPosIniCtg, 0090, "Número" , ofont13)	//Numero
oDamdfe:Say(0175-nPosIniCtg, 0090, cValtoChar( Val(aCab[1]) ), ofont13)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³BOX: FL ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

oDamdfe:Box(0150-nPosIniCtg, 0148, 0185-nPosIniCtg, 0180)                        
oDamdfe:Say(0165-nPosIniCtg, 0150, "FL"  , ofont13N)	//Folha
oDamdfe:Say(0175-nPosIniCtg, 0150, AllTrim(Str(nFolhAtu)) + "/" + AllTrim(Str(nFolhas)), ofont13N)
nFolhAtu ++

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³BOX: DATA E HORA DE EMISSÃO 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

oDamdfe:Box(0150-nPosIniCtg, 0188, 0185-nPosIniCtg, 0308)     
oDamdfe:Say(0165-nPosIniCtg, 0190, "Data e Hora de Emissão", ofont13)//Emissao
oDamdfe:Say(0175-nPosIniCtg, 0190, SubStr(AllTrim(aCab[3]), 7, 2) + '/'   +;
						SubStr(AllTrim(aCab[3]), 5, 2) + "/"   +;
						SubStr(AllTrim(aCab[3]), 1, 4) + " - " +;
						SubStr(AllTrim(aCab[4]), 1, 2) + ":"   +;
						SubStr(AllTrim(aCab[4]), 3, 2) + ":00", ofont13N)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³QRCODE ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ	

If lXml
	If Type( 'oNFE:_MDFE:_INFMDFESUPL:_QRCODMDFE:TEXT' ) != 'U' .And. !Empty(oNFE:_MDFE:_INFMDFESUPL:_QRCODMDFE:TEXT  )
		If lXmlCont //Contingencia
			nPosSign:= At("&sign",oNFE:_MDFE:_INFMDFESUPL:_QRCODMDFE:TEXT)
		EndIf

		If nPosSign > 0 
			cQrCode := Substr(oNFE:_MDFE:_INFMDFESUPL:_QRCODMDFE:TEXT, 1, nPosSign - 1)
		Else
			cQrCode := oNFE:_MDFE:_INFMDFESUPL:_QRCODMDFE:TEXT  
		EndIf	
	EndIf	
Else
	cQrCode := 'http://dfe-portal.svrs.rs.gov.br/mdfe/QRCode?chMDFe='+aCab[5]+'&tpAmb=' + Substr(cAmbiente,1,1) 
EndIf		
oDamdfe:QRCODE(200-nPosIniCtg,550,cQrCode, 120)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOX: Controle do Fisco                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDamdfe:Say(0208-nPosIniCtg, 0332, "CONTROLE DO FISCO", ofont11)

oDamdfe:Code128C(0265-nPosIniCtg,0332,aCab[5], 60)

If lXml

	If (ValType(oNFe:_MDFE:_INFMDFE:_IDE:_INFMUNCARREGA)  =='A')
		cCodEst:= Substr(oNfe:_MDFE:_INFMDFE:_IDE:_INFMUNCARREGA[1]:_CMUNCARREGA:TEXT,1,2)
	Else
		cCodEst:= Substr(oNfe:_MDFE:_INFMDFE:_IDE:_INFMUNCARREGA:_CMUNCARREGA:TEXT,1,2)
	EndIf

	If aScan(aUF,{|x| x[2] ==  AllTrim(cCodEst) }) != 0
		cUF := aUF[ aScan(aUF,{|x| x[2] == AllTrim(cCodEst) }), 1]
	EndIf
	
Else
    If AliasInDic("DL0")
        dbSelectArea("DL0")
        DL0->(dbSetOrder(2))
    EndIf

    If AliasInDic("DL0") .AND.  DL0->(MsSeek( FWxFilial("DL0")+ DTX->DTX_FILORI + DTX->DTX_VIAGEM ))
        DL0->(MsSeek( FWxFilial("DL0") + DTX->DTX_FILORI + DTX->DTX_VIAGEM + Replicate("Z",Len(DL0->DL0_PERCUR)),.T.))
        DL0->(DbSkip(-1))

        dbSelectArea("DL1")
        DL1->(dbSetOrder(2))
        If DL1->(dbSeek( FWxFilial("DL1") + DL0->DL0_PERCUR + DTX->DTX_FILMAN + DTX->DTX_MANIFE + DTX->DTX_SERMAN))
            cUF  :=   DL1->DL1_UFORIG
        EndIf
    Else
        cRota := Posicione("DTQ",2,xFilial("DTQ")+(cAliasMDF)->DTX_FILMAN+(cAliasMDF)->DTX_VIAGEM,"DTQ_ROTA")
        DA8->(DbSetOrder(1))
        If DA8->(MsSeek(xFilial("DA8")+cRota))
            DUY->(DbSetOrder(1))
            If 	!Empty(DA8->DA8_CDOMDF) .And. DUY->(MsSeek(xFilial("DUY")+DA8->DA8_CDOMDF))
                cUF := DUY->DUY_EST
            EndIf
        EndIf
        If Empty(cUF)
            aAreaSM0:= SM0->(GetArea())
            cUF:= Posicione("SM0",1,cEmpAnt+(cAliasMDF)->DTX_FILMAN,"M0_ESTENT")
            RestArea(aAreaSM0)
        EndIf
    EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³BOX: UF CARREGAMENTO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ						
oDamdfe:Box(0150-nPosIniCtg, 0316, 0185-nPosIniCtg, 0370		)						
oDamdfe:Say(0165-nPosIniCtg, 0318, "UF Carreg." , ofont13	)
oDamdfe:Say(0175-nPosIniCtg, 0318, cUF , ofont13N	)

If lXml
	If (ValType(oNFe:_MDFE:_INFMDFE:_INFDOC:_INFMUNDESCARGA)  =='A')
		cCodEst:= Substr(oNfe:_MDFE:_INFMDFE:_INFDOC:_INFMUNDESCARGA[1]:_CMUNDESCARGA:TEXT,1,2)
	Else
		cCodEst:= Substr(oNfe:_MDFE:_INFMDFE:_INFDOC:_INFMUNDESCARGA:_CMUNDESCARGA:TEXT,1,2)
	EndIf

	If aScan(aUF,{|x| x[2] ==  AllTrim(cCodEst) }) != 0
		cUFDesc := aUF[ aScan(aUF,{|x| x[2] == AllTrim(cCodEst) }), 1]
	EndIf
Else

    // Verifica na tabela de Percurso.
    If AliasInDic("DL0")
		dbSelectArea("DL0")
		DL0->(dbSetOrder(2))
	EndIf
    If AliasInDic("DL0") .AND.  DL0->(MsSeek( FWxFilial("DL0")+ (cAliasMDF)->DTX_FILORI + (cAliasMDF)->DTX_VIAGEM ))
        DL0->(MsSeek( FWxFilial("DL0") + (cAliasMDF)->DTX_FILORI + (cAliasMDF)->DTX_VIAGEM + Replicate("Z",Len(DL0->DL0_PERCUR)),.T.))
        DL0->(DbSkip(-1))

        dbSelectArea("DL1")
        DL1->(dbSetOrder(2))
        If DL1->(dbSeek( FWxFilial("DL1") + DL0->DL0_PERCUR + (cAliasMDF)->DTX_FILMAN + (cAliasMDF)->DTX_MANIFE + (cAliasMDF)->DTX_SERMAN))
            cUFDesc    := DL1->DL1_UF
        EndIf
    Else
        // Verifica se é viagem de Entrega
    	cSertms  := Posicione("DTQ",2,xFilial("DTQ")+(cAliasMDF)->DTX_FILORI+(cAliasMDF)->DTX_VIAGEM,"DTQ_SERTMS")
        If cSertms = '3' .Or. (cSertms = '2' .And. (cAliasMDF)->DTX_FILDCA = cFilAnt) .Or. __lPyme

            // Busca ultimo doc sequenciado do manifesto posicionado
            // Para este tratamento é necessario que o manifesto tenha sido gerado por ESTADO.
            cAliasDUD := GetNextAlias()
            cQryCab += " SELECT Max(DUD_SEQUEN) MAX_SEQUEN, DUD_CDRCAL "
            cQryCab += "   FROM " + RetSQLName("DUD") + " DUD "
            cQryCab += "  WHERE DUD.DUD_FILIAL  = '"+xFilial("DUD")+"'"
            cQryCab += "	 AND DUD.DUD_FILORI  = '"+(cAliasMDF)->DTX_FILORI+"'"
            If __lPyme
                cQryCab += " AND DUD.DUD_NUMROM  = '" + (cAliasMDF)->DTX_NUMROM + "'"
            EndIf
            cQryCab += "	 AND DUD.DUD_FILMAN  = '" + (cAliasMDF)->DTX_FILMAN + "'"
            cQryCab += "	 AND DUD.DUD_MANIFE  = '" + (cAliasMDF)->DTX_MANIFE + "'"
            cQryCab += "	 AND DUD.D_E_L_E_T_  = ' '"
            cQryCab += "  GROUP BY DUD_CDRCAL"

            cQryCab := ChangeQuery(cQryCab)
            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCab),cAliasDUD)

            If !(cAliasDUD)->(Eof())
                // Em viagem de Entrega a UF Fim vem da regiao de Calculo
                cUFDesc   := Posicione("DUY",1, xFilial('DUY')+(cAliasDUD)->DUD_CDRCAL ,"DUY_EST")
            EndIf
            (cAliasDUD)->(dbCloseArea())
        EndIf
    EndIf
	If Empty(cUFDesc)
		aAreaSM0:= SM0->(GetArea())
		cUFDesc:= Posicione("SM0",1,cEmpAnt+(cAliasMDF)->DTX_FILDCA,"M0_ESTENT")
		RestArea(aAreaSM0)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³BOX: UF DESCARREGAMENTO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
oDamdfe:Box(0150-nPosIniCtg, 0380, 0185-nPosIniCtg			, 0450		)							
oDamdfe:Say(0165-nPosIniCtg, 0382, "UF Descarreg." , ofont13	)
oDamdfe:Say(0175-nPosIniCtg, 0382, cUFDesc 		, ofont13N	)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³BOX: PROTOCOLO                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDamdfe:Say(0290-nPosIniCtg, 0005, "Protocolo de autorização"  , ofont11N)
If Empty(aCab[7])  //Chave Contingencia
	oDamdfe:Say(0300-nPosIniCtg, 0005,aCab[6], ofont13)
	If lXml
		oDamdfe:Say(0300-nPosIniCtg, 0105,cValToChar(aCab[8]) + '-', ofont13)
		oDamdfe:Say(0300-nPosIniCtg, 0165,cValToChar(aCab[9]), ofont13)
	Else
		oDamdfe:Say(0300-nPosIniCtg, 0105, SubStr(AllTrim(aCab[8]), 7, 2) + '/'   +;
                               SubStr(AllTrim(aCab[8]), 5, 2) + "/"   +;
                               SubStr(AllTrim(aCab[8]), 1, 4) + "   " +;
                               SubStr(AllTrim(aCab[9]), 1, 2) + ":"   +;
                               SubStr(AllTrim(aCab[9]), 3, 2), ofont13)
	EndIf
Else
	oBrushBlck := TBrush():New( , CLR_BLACK)
	oDamdfe:FillRect({0292-nPosIniCtg,0005,0315-nPosIniCtg,0300},oBrushBlck)
	oDamdfe:Say(0300-nPosIniCtg, 0008,'Impressão em contingência. Obrigatória a autorização ', oFont13,,CLR_WHITE)
	oDamdfe:Say(0311-nPosIniCtg, 0008,'em 168 horas após esta impressão.', ofont13,,CLR_WHITE)
   	If lXml
   		oDamdfe:Say(0312-nPosIniCtg, 0175, "(" + AllTrim(Dtoc(aCab[8])) + ' '   +;
										  SubStr(AllTrim(aCab[9]), 1, 5) + ")", ofont13)
   	Else
		oDamdfe:Say(0312-nPosIniCtg, 0175, "(" + SubStr(AllTrim(aCab[8]), 7, 2) + '/'   +;
										  SubStr(AllTrim(aCab[8]), 5, 2) + "/"   +;
										  SubStr(AllTrim(aCab[8]), 1, 4) + " - " +;
										  SubStr(AllTrim(aCab[9]), 1, 2) + ":"   +;
										  SubStr(AllTrim(aCab[9]), 3, 2) + ")", ofont13)
	EndIf
EndIf

oDamdfe:Say( 0290-nPosIniCtg, 0332,"Chave de Acesso",oFont11N)
oDamdfe:Say( 0300-nPosIniCtg, 0332, Transform(AllTrim(aCab[5]),"@r 99.9999.99.999.999/9999-99-99-999-999.999.999.999.999.999.9"), oFont11)
oDamdfe:Say( 0310-nPosIniCtg, 0332, "Consulte em ", oFont11)
oDamdfe:Say( 0310-nPosIniCtg, 0382, "https://dfe-portal.sefazvirtual.rs.gov.br/MDFe/consulta ", oFont11N)


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RTMSR32   ³ Autor ³Katia               ³ Data ³07/05/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DataSource( cSource )
Local cNewArea	:= GetNextAlias()
Local cQuery	:= ""

cQuery := GetSQL( cSource )
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cNewArea, .F., .T.)

Return ( cNewArea )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RTMSR32   ³ Autor ³Katia               ³ Data ³07/05/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³  Cria DACTE sem utilizar o XML, utilizando tabela.         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetSQL( cSource )
Local cQuery := ""
Local lDTX_SERMAN := DTX->(FieldPos("DTX_SERMAN")) > 0
Local lTercRbq    := DTR->(ColumnPos("DTR_CODRB3")) > 0

If	cSource == 'DTX'
	cQuery += "    SELECT DTX_FILMAN, DTX_MANIFE, DTX_FILORI, DTX_VIAGEM, DTX_DATMAN, DTX_HORMAN, DTX_QTDDOC, DTX_PESO, " +CRLF
	cQuery += "           DTX_QTDCTE, DTX_PRIMDF, DTX_CHVMDF, DTX_CTGMDF, DTX_DATIMP, DTX_HORIMP, DTX_AMBIEN, DTX_FIMP, DTX_FILDCA, " +CRLF
	If __lPyme
		If lDTX_SERMAN
			cQuery += "  DYB_CODVEI, DYB_CODRB1 , DYB_CODRB2 ,  DTX_SERMAN " + CRLF
			If lTercRbq
				cQuery += ",DYB_CODRB3 " + CRLF 
			EndIf 
		EndIf
	Else
		If lDTX_SERMAN
			cQuery += "    DTX_SERMAN, " + CRLF
		EndIf

		cQuery += "    DTR_CODVEI, DTR_CODRB1, DTR_CODRB2 " + CRLF

		If lTercRbq
			cQuery += ",DTR_CODRB3 " + CRLF 
		EndIf 
	EndIf

	If __lPyme
		cQuery += "   FROM " + RetSqlName('DTX') + " DTX " + CRLF
		cQuery += "        INNER JOIN " + RetSqlName('DYB') + " DYB ON(DYB_FILIAL = '" + xFilial('DYB') + "' AND DYB_NUMROM = DTX_NUMROM AND DTX.D_E_L_E_T_ <>'*' AND DYB.D_E_L_E_T_ <>'*' ) " + CRLF
	Else
		cQuery += "   FROM " + RetSqlName('DTX') + " DTX " + CRLF
		cQuery += "        INNER JOIN " + RetSqlName('DTR') + " DTR ON(DTR_FILORI = DTX_FILORI AND DTR_VIAGEM = DTX_VIAGEM AND DTR_CODVEI = DTX_CODVEI AND DTX.D_E_L_E_T_='' ) " + CRLF
	EndIf

	cQuery += "  WHERE DTX_FILIAL = '" + xFilial('DTX') + "'" + CRLF
	If __lPyme
		cQuery += "    AND DTX_MANIFE  = '" + MV_PAR01 + "'" + CRLF
		If lDTX_SERMAN .And. Alltrim(MV_PAR02) <> '0'
			cQuery += "    AND DTX_SERMAN     = '" + MV_PAR02 + "'" + CRLF
		EndIF
		cQuery += "    AND DYB_NUMROM  = '" + MV_PAR03 + "'" + CRLF
	Else
		cQuery += "    AND DTX_FILORI = '" + MV_PAR01 + "'" + CRLF
		cQuery += "    AND DTX_VIAGEM >= '" + MV_PAR02 + "'" + CRLF
		cQuery += "    AND DTX_VIAGEM <= '" + MV_PAR03 + "'" + CRLF
		cQuery += "    AND DTX_FILMAN >= '" + MV_PAR04 + "'" + CRLF
		cQuery += "    AND DTX_FILMAN <= '" + MV_PAR05 + "'" + CRLF
		cQuery += "    AND DTX_MANIFE >= '" + MV_PAR06 + "'" + CRLF
		cQuery += "    AND DTX_MANIFE <= '" + MV_PAR07 + "'" + CRLF
		If lDTX_SERMAN .And. Alltrim(MV_PAR08) <> '0'
			cQuery += "    AND DTX_SERMAN    >= '" + MV_PAR08 + "'" + CRLF
			cQuery += "    AND DTX_SERMAN    <= '" + MV_PAR09 + "'" + CRLF
		EndIF
		cQuery += "  AND DTR_FILIAL = '" + xFilial('DTR') + "'" + CRLF
	EndIf
	cQuery += "    AND (DTX_IDIMDF  = '100' OR (DTX_CTGMDF  <> ' ' AND SUBSTRING(DTX_RTIMDF,1,3) = '004'))" + CRLF
	cQuery += "    AND DTX.D_E_L_E_T_  = ' ' " + CRLF
	If lDTX_SERMAN
		cQuery += "  ORDER BY DTX.DTX_FILIAL, DTX_FILORI, DTX_VIAGEM, DTX_FILMAN, DTX_MANIFE, DTX_SERMAN " + CRLF
	Else
		cQuery += "  ORDER BY DTX.DTX_FILIAL, DTX_FILORI, DTX_VIAGEM, DTX_FILMAN, DTX_MANIFE " + CRLF
	EndIf

ElseIf cSource == 'DA3'

	cQuery += " SELECT DA3_COD, DA3_PLACA, DA3_RENAVA, DA3_TARA, DA3_CAPACM, DA3_FROVEI, " + CRLF
	cQuery += "   DA3_ESTPLA, DA3_CODFOR, DA3_LOJFOR, DUT_DESCRI,DUT_TIPROD, DUT_TIPCAR, " + CRLF
	cQuery += "   DA3_ALTINT, DA3_LARINT, DA3_COMINT, " + CRLF
	cQuery += "   A2_CGC, A2_NOME, A2_INSCR, A2_EST, A2_TIPO, A2_RNTRC " + CRLF
	cQuery += " FROM " + RetSqlName("DA3") + " DA3 " + CRLF
	cQuery += "   INNER JOIN " + RetSqlName("DUT") + " DUT " + CRLF
	cQuery += "   ON DUT.DUT_TIPVEI = DA3.DA3_TIPVEI " + CRLF
	cQuery += "   AND DUT.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "   INNER JOIN " + RetSqlName("SA2") + " SA2 ON " + CRLF
	cQuery += "   SA2.A2_COD = DA3.DA3_CODFOR AND " + CRLF
	cQuery += "   SA2.A2_LOJA   = DA3.DA3_LOJFOR AND " + CRLF
	cQuery += "   SA2.D_E_L_E_T_= '' " + CRLF
	cQuery += " WHERE DA3.DA3_FILIAL = '"+xFilial("DA3")+"'" + CRLF
	cQuery += "   AND DA3.DA3_COD    = '"+cCodVei+"'" + CRLF
	cQuery += "   AND DA3.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "   AND DUT.DUT_FILIAL = '"+xFilial('DUT')+"'" + CRLF
	cQuery += "   AND SA2.A2_FILIAL  = '"+xFilial('SA2')+"'" + CRLF

EndIf

cQuery := ChangeQuery( cQuery )

Return ( cQuery )

static function UsaColaboracao(cModelo)
Local lUsa := .F.

If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
endif
return (lUsa)



