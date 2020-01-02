#Include 'Protheus.ch'
#Include "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH  "
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"

/*/{Protheus.doc} PTX0013
Função para impressão da DANFE
@type Function
@author Pontin
@since 14/06/2016
@version 1.0
/*/
User Function PTX0013(cNomeArq)

    Default cNomeArq := ""

	If ZZZ->ZZZ_TIPO == "2"
		MsgStop("Chave selecionada pertence a um CT-e!!"+ CRLF + CRLF +;
				"A rotina de impressão de DANFE está homologada apenas para NF-e.","XML-e")
		Return .F.
	EndIf

	//|Valida o status da NF |
	If !U_VldStatus()
		Return
	EndIf

	U_PTX0007(.F.,.T.)

	If !Empty(ZZZ->ZZZ_XML)

		//|Chama funcao de imprimir a danfe |
		SFP001(cNomeArq)

	Else
		MsgStop("Não foi possível salvar o XML da nota fiscal selecionada!!"+ CRLF + CRLF +;
				"Tente novamente mais tarde!","XML-e")
	EndIf

Return


Static Function SFP001(cNomeArq)

    
	Local oSetupDanf
    Local cLocal     := LOWER(SuperGetMV("ZZ_DIRDANF",.F.,"C:\temp\"))    //"C:\TOTVS\danfe\")
    Default cNomeArq := LOWER(cNomeArq)

    If Empty(cNomeArq)
        cNomeArq   := "NewSetupDanfe"
	    oSetupDanf := FwMSPrinter():New(cNomeArq, IMP_SPOOL , .F. , , .F. )        
    Else
        FERASE(cLocal+cNomeArq+".pdf")                 
        oSetupDanf := FWMSPrinter():New(cNomeArq, IMP_PDF,.F.,cLocal,.T.,/*lTReport */ ,/*oPrintSetup*/ ,/*cPrinter*/ , .T., /*lPDFAsPNG*/,/*lRaw*/, .F.)
        oSetupDanf:cPathPDF := cLocal
    EndIf
    
	
    If oSetupDanf:nModalResult == 2
		oSetupDanf:lCanceled := .T.
	EndIf

	If !oSetupDanf:lCanceled //.AND. ( oSetupDanf:IsPrinterActive() )
		Processa( {|| CarDanfe(@oSetupDanf, @cNomeArq) }, "Gerando Danfe..." )
	EndIf

Return

static function CarDanfe(oSetupDanf, cNomeArq)

	
	Local cError 			:= ""
	Local cWarning 		:= ""
	Local oXml 			:= nil
	Local oDanfe 			:= nil
	Local aTotais 		:= {"","","","","","","","","","",""}
	Local nAuxH 			:= 0
	Local aAux 			:= {}
	Local totpagina 		:= 1
	Local npagina 		:= 1
	Local nitensini 		:= 0
	Local CstCsons  		:= "CST"
	Local nFaturas 		:= 0
	Local textfat 		:= ''
	Local ctransp 		:= ''
	Local cModFrete 		:= ''
	Local cVeicTrans 		:= ''
	Local cvolume 		:= ''
	Local aTamCol 		:= ''
	Local citens 			:= {}
	Local citens 			:= {}
	Local aSitTrib 		:= {"00","10","20","30","40","41","50","51","60","70","90"}
	Local aSitSN 			:= {"101","102","201","202","500","900"}
	Local nValICM 		:= "0,00"
	Local nBaseICM	 	:= "0,00"
	Local nPICM 			:= "0,00"
	Local cSitTrib 		:= ''
	Local nValIPI 		:= "0,00"
	Local nPIPI 			:= "0,00"
	Local oimposto 		:= ''
	Local oimpostsn 		:= ''
	Local nitens 			:= 0
	Local nlimite 		:= 0
	Local nLinha 			:= 0
	Local cdaEmi 			:= ''
	Local ncontrole 		:= 0
	Local cdescprod 		:= 8
	Local oFont04    		:= TFont():New("Times New Roman",,04,.T.) // 4
	Local oFont06    		:= TFont():New("Times New Roman",,06,.T.) // 6
	Local oFont06N   		:= TFont():New("Times New Roman",,06,.T.,.T.) // 6N
	Local oFont07    		:= TFont():New("Times New Roman",,07,.T.) // 7
	Local oFont07N   		:= TFont():New("Times New Roman",,07,.T.,.T.) // 7N
	Local oFont08    		:= TFont():New("Times New Roman",,08,.T.) // 8
	Local oFont08N   		:= TFont():New("Times New Roman",,08,.T.,.T.) // 8N
	Local oFont09    		:= TFont():New("Times New Roman",,09,.T.) // 9
	Local oFont09N   		:= TFont():New("Times New Roman",,09,.T.,.T.) // 9N
	Local oFont10    		:= TFont():New("Times New Roman",,10,.T.) // 10
	Local oFont10N   		:= TFont():New("Times New Roman",,10,.T.,.T.) // 10N
	Local oFont11    		:= TFont():New("Times New Roman",,11,.T.) // 11
	Local oFont11N  		:= TFont():New("Times New Roman",,11,.T.,.T.) // 11N
	Local oFont12    		:= TFont():New("Times New Roman",,12,.T.) // 12
	Local OFONT12N   		:= TFont():New("Times New Roman",,12,.T.,.T.) // 12N
	Local oFont14    		:= TFont():New("Times New Roman",,14,.T.) // 12
	Local OFONT14N   		:= TFont():New("Times New Roman",,14,.T.,.T.) // 12N
	Local oFont15N   		:= TFont():New("Times New Roman",,15,.T.,.T.) // 15N
	Local oFont16    		:= TFont():New("Times New Roman",,16,.T.) // 16
	Local oFont16N   		:= TFont():New("Times New Roman",,16,.T.,.T.) // 16N
	Local oFont18N   		:= TFont():New("Times New Roman",,18,.T.,.T.) // 18N

	Local nX, nY, cont := 0

	oXml := XmlParser(ZZZ->ZZZ_XML,"_",@cError,@cWarning)

	if cError <> ""
		MsgInfo("Ocorreu o seguinte erro durante a leitura: " + cError)
		return .f.
	endif

	//Tratamento caso o xml possua a tag NFEPROC
	if XmlChildEx(oXml, "_NFEPROC") <> nil
		oXml := XmlChildEx(oXml, "_NFEPROC")
	endif

	if XmlChildEx(oXml, "_NFE") == nil
	   Msginfo("O arquivo selecionado não é uma Nota Fiscal eletronica, selecione outro arquivo")
	   return
	endif

	//forca _det como array
	If ValType(oXml:_NFE:_INFNFE:_DET) <> "A"
		XmlNode2Arr(oXml:_NFE:_INFNFE:_DET,"_DET")
	EndIf
 
    If cNomeArq == "NewSetupDanfe"        
	    cNomeArq := AllTrim("Danfe_N"+Alltrim(STR(val(oXml:_NFE:_INFNFE:_IDE:_NNF:TEXT)))+'h'+ALLTrim(StrTran( time(),':','')) )
        oDanfe  := FwMSPrinter():New( cNomeArq, oSetupDanf:nDevice , .F. , , .T. )  
    Else
        oDanfe := oSetupDanf
    EndIf     
	
    oDanfe:cPrinter := oSetupDanf:cPrinter
	oDanfe:SetResolution(79)
	oDanfe:SetPortrait()
	oDanfe:SetPaperSize(9)
	oDanfe:SetMargin(65,60,65,60)
	oDanfe:cPathPDF := oSetupDanf:cPathPDF
	iif(AttIsMemberOf(oSetupDanf,"NQTDCOPIES"), oDanfe:NQTDCOPIES:=oSetupDanf:NQTDCOPIES,"")

	oDanfe:StartPage()

	// Recibo de entrega
	oDanfe:Box(000,000,010,501)
	oDanfe:Say(006, 002, "RECEBEMOS DE "+UPPER(oXml:_NFE:_INFNFE:_EMIT:_XNOME:TEXT)+" OS PRODUTOS CONSTANTES DA NOTA FISCAL INDICADA AO LADO", oFont06)
	oDanfe:Box(009,000,037,101)
	oDanfe:Say(017, 002, "DATA DE RECEBIMENTO", oFont07N)
	oDanfe:Box(009,100,037,500)
	oDanfe:Say(017, 102, "IDENTIFICAÇÃO E ASSINATURA DO RECEBEDOR", oFont07N)
	oDanfe:Box(000,500,037,603)
	oDanfe:Say(007, 542, "NF-e", oFont08N)
	oDanfe:Say(017, 510, "N. "+STRZERO(val(oXml:_NFE:_INFNFE:_IDE:_NNF:TEXT),9), oFont08)
	oDanfe:Say(027, 510, "SÉRIE "+oXml:_NFE:_INFNFE:_IDE:_SERIE:TEXT, oFont08)

	//Quadro 1 IDENTIFICACAO DO EMITENTE
	oDanfe:Box(042,000,137,250)
	oDanfe:Say(052,003,"Identificação do emitente",oFont10N)
	nAuxH := 052
	oDanfe:SayAlign(nAuxH,002,UPPER(oXml:_NFE:_INFNFE:_EMIT:_XNOME:TEXT),oFont15N,246,40,,2,1)//Nome emitente
	nAuxH += 35
	oDanfe:SayAlign(nAuxH,000,UPPER(oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XLGR:TEXT);
	+", "+oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_NRO:TEXT,oFont10,250,9,,2,1)	//logradouro
	nAuxH += 9
	oDanfe:SayAlign(nAuxH,000,UPPER(oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT),oFont10,250,9,,2,1) // bairro
	nAuxH += 9
	oDanfe:SayAlign(nAuxH,000,UPPER(oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XMUN:TEXT);
	+" - "+oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT,oFont10,250,9,,2,1)// municipio
	nAuxH += 9
	oDanfe:SayAlign(nAuxH,000,"CEP "+TransForm(oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CEP:TEXT,"@r 99999-999"),oFont10,250,9,,2,1)// cep
	nAuxH += 9
	if XmlChildEx(oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT, "_FONE") <> nil
		oDanfe:SayAlign(nAuxH,000,"FONE: "+Convfone(oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_FONE:TEXT),oFont10,250,9,,2,1)// telefone
	endif

	// quadro 2 - entrada / saida
	oDanfe:Box(042,248,137,351)
	oDanfe:Say(055,275, "DANFE",oFont15N)
	oDanfe:Say(065,251, "DOCUMENTO AUXILIAR DA",oFont07)
	oDanfe:Say(075,251, "NOTA FISCAL ELETRÔNICA",oFont07)
	oDanfe:Say(085,266, "0-ENTRADA",oFont08)
	oDanfe:Say(095,266, "1-SAÍDA"  ,oFont08)
	oDanfe:Box(078,315,095,325)
	oDanfe:Say(089,318, oXml:_NFE:_INFNFE:_IDE:_TPNF:TEXT,oFont08N)
	oDanfe:Say(110,255,"N. "+STRZERO(val(oXml:_NFE:_INFNFE:_IDE:_NNF:TEXT),9),oFont10N)
	oDanfe:Say(120,255,"SÉRIE "+oXml:_NFE:_INFNFE:_IDE:_SERIE:TEXT,oFont10N)

	//quadro 3 - codigo de barras
	oDanfe:Box(042,350,088,603)
	oDanfe:Box(075,350,110,603)
	oDanfe:Box(105,350,137,603)
	oDanfe:Say(095,355,TransForm(SubStr(oXml:_NFE:_INFNFE:_ID:TEXT,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont11N)
	oDanfe:Say(083,355,"CHAVE DE ACESSO DA NF-E",oFont08N)
	oDanfe:Code128C(072,370,SubStr(oXml:_NFE:_INFNFE:_ID:TEXT,4), 28 )
	oDanfe:Say(117,355,"Consulta de autenticidade no portal nacional da NF-e",oFont11)
	oDanfe:Say(127,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont11)

	//quadro 4 - natureza
	oDanfe:Box(139,000,162,603)
	oDanfe:Box(139,000,162,350)
	oDanfe:Say(145,002,"NATUREZA DA OPERAÇÃO",oFont06N)
	oDanfe:Say(158,002,UPPER(oXml:_NFE:_INFNFE:_IDE:_NATOP:TEXT),oFont11)
	oDanfe:Say(145,352,"PROTOCOLO DE AUTORIZAÇÃO DE USO",oFont06N)
	if XmlChildEx(oXml, "_PROTNFE") <> nil
		if XmlChildEx(oXml:_PROTNFE:_INFPROT, "_NPROT") <> nil
			cdaEmi := oXml:_PROTNFE:_INFPROT:_DHRECBTO:TEXT
	  		cdaEmi := Substr(cdaEmi,9,2)+"/"+Substr(cdaEmi,6,2)+"/"+Substr(cdaEmi,3,2)+" "+Substr(cdaEmi,12,8)
	    	oDanfe:Say(158,354,oXml:_PROTNFE:_INFPROT:_NPROT:TEXT+" "+cdaEmi,oFont08)
		endif
	endif

	// Quadro 5 - IE e CNPJ
	oDanfe:Box(164,000,187,603)
	oDanfe:Box(164,000,187,200)
	oDanfe:Box(164,200,187,400)
	oDanfe:Box(164,400,187,603)
	oDanfe:Say(170,002,"INSCRIÇÃO ESTADUAL",oFont06N)
	oDanfe:Say(180,002,IIf(XmlChildEx(oXml:_NFE:_INFNFE:_EMIT, "_IE") <> nil,oXml:_NFE:_INFNFE:_EMIT:_IE:TEXT,""),oFont11)
	oDanfe:Say(170,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont06N)
	oDanfe:Say(180,205,IIf(XmlChildEx(oXml:_NFE:_INFNFE:_EMIT, "_IEST") <> nil,oXml:_NFE:_INFNFE:_EMIT:_IEST:TEXT,""),oFont11)
	oDanfe:Say(170,405,"CNPJ",oFont06N)
	oDanfe:Say(180,405,TransForm(oXml:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT,IIf(Len(oXml:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont11)

	// Quadro 6 destinatário/remetente
	oDanfe:Say(195,002,"DESTINATARIO/REMETENTE",oFont06N)
	oDanfe:Box(197,000,217,450)
	oDanfe:Say(203,002, "NOME/RAZÃO SOCIAL",oFont06N)
	oDanfe:Say(215,002,Substr(UPPER(oXml:_NFE:_INFNFE:_DEST:_XNOME:TEXT),1,50),oFont11)
	oDanfe:Box(197,280,217,500)
	oDanfe:Say(203,283,"CNPJ/CPF",oFont06N)
	oDanfe:Say(215,283,IIf(XmlChildEx(oXml:_NFE:_INFNFE:_DEST, "_CNPJ")<>nil,TransForm(oXml:_NFE:_INFNFE:_DEST:_CNPJ:TEXT,"@r 99.999.999/9999-99"),TransForm(oXml:_NFE:_INFNFE:_DEST:_CPF:TEXT,"@r 999.999.999-99")),oFont11)

	oDanfe:Box(217,000,237,500)
	oDanfe:Box(217,000,237,260)
	oDanfe:Say(223,002,"ENDEREÇO",oFont06N)
	oDanfe:Say(234,002,iif(XmlChildEx(oXml:_NFE:_INFNFE:_DEST:_ENDERDEST, "_XLGR")<>nil,UPPER(oXml:_NFE:_INFNFE:_DEST:_ENDERDEST:_XLGR:TEXT),""),oFont11)
	oDanfe:Box(217,230,237,380)
	oDanfe:Say(223,232,"BAIRRO/DISTRITO",oFont06N)
	oDanfe:Say(234,232,iif(XmlChildEx(oXml:_NFE:_INFNFE:_DEST:_ENDERDEST, "_XBAIRRO")<>nil,UPPER(oXml:_NFE:_INFNFE:_DEST:_ENDERDEST:_XBAIRRO:TEXT),""),oFont11)
	oDanfe:Box(217,380,237,500)
	oDanfe:Say(223,382,"CEP",oFont06N)
	oDanfe:Say(234,382,iif(XmlChildEx(oXml:_NFE:_INFNFE:_DEST:_ENDERDEST, "_CEP")<>nil,TransForm(oXml:_NFE:_INFNFE:_DEST:_ENDERDEST:_CEP:TEXT,"@r 99999-999"),""),oFont11)

	oDanfe:Box(236,000,257,500)
	oDanfe:Box(236,000,257,180)
	oDanfe:Say(242,002,"MUNICIPIO",oFont06N)
	oDanfe:Say(255,002,iif(XmlChildEx(oXml:_NFE:_INFNFE:_DEST:_ENDERDEST, "_XMUN")<>nil,UPPER(oXml:_NFE:_INFNFE:_DEST:_ENDERDEST:_XMUN:TEXT),""),oFont11)
	oDanfe:Box(236,150,257,256)
	oDanfe:Say(242,152,"FONE/FAX",oFont06N)
	oDanfe:Say(255,152,iif(XmlChildEx(oXml:_NFE:_INFNFE:_DEST:_ENDERDEST, "_FONE")<>nil,Convfone(oXml:_NFE:_INFNFE:_DEST:_ENDERDEST:_FONE:TEXT),""),oFont11)

	oDanfe:Box(236,255,257,341)
	oDanfe:Say(242,257,"UF",oFont06N)
	oDanfe:Say(255,257,iif(XmlChildEx(oXml:_NFE:_INFNFE:_DEST:_ENDERDEST, "_UF")<>nil,oXml:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:TEXT,""),oFont11)
	oDanfe:Box(236,340,257,500)
	oDanfe:Say(242,342,"INSCRIÇÃO ESTADUAL",oFont06N)
	oDanfe:Say(255,342,iif(XmlChildEx(oXml:_NFE:_INFNFE:_DEST, "_IE")<>nil,oXml:_NFE:_INFNFE:_DEST:_IE:TEXT,""),oFont11)

	oDanfe:Box(197,502,217,603)
	oDanfe:Say(203,504,"DATA DE EMISSÃO",oFont06N)
	oDanfe:Say(215,504,iif(XmlChildEx(oXml:_NFE:_INFNFE:_IDE, "_DHEMI")<>nil,ConvDate(oXml:_NFE:_INFNFE:_IDE:_DHEMI:TEXT),""),oFont11)
	oDanfe:Box(217,502,237,603)
	oDanfe:Say(223,504,"DATA ENTRADA/SAÍDA",oFont06N)
	oDanfe:Say(233,504,iif(XmlChildEx(oXml:_NFE:_INFNFE:_IDE, "_DHSAIENT")<>nil,ConvDate(oXml:_NFE:_INFNFE:_IDE:_DHSAIENT:TEXT),""),oFont11)
	oDanfe:Box(236,502,257,603)
	oDanfe:Say(242,503,"HORA ENTRADA/SAÍDA",oFont06N)
	oDanfe:Say(252,503,iif(XmlChildEx(oXml:_NFE:_INFNFE:_IDE, "_HSAIENT")<>nil,oXml:_NFE:_INFNFE:_IDE:_HSAIENT:TEXT,""),oFont11)

	//³Quadro 7 Faturas
	oDanfe:Say(263,002,"FATURA",oFont06N)
	oDanfe:Box(265,000,296,603)
	Private clenfat := {}
	Private alenlinha := {"","","",""}
	if XmlChildEx(oXml:_NFE:_INFNFE, "_COBR")<>nil
		if XmlChildEx(oXml:_NFE:_INFNFE:_COBR, "_DUP")<>nil                                                      ³
			nFaturas := IIf(ValType(oXml:_NFE:_INFNFE:_COBR:_DUP)=="A",Len(oXml:_NFE:_INFNFE:_COBR:_DUP),1)
			if nFaturas == 1
	    	   //	textfat += "N."+oXml:_NFE:_INFNFE:_COBR:_DUP:_NDUP:TEXT+;
			    //       "-VENC-"+ConvDate(oXml:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT)+;
			    //       "-VAL-R$"+ConvValDec(oXml:_NFE:_INFNFE:_COBR:_DUP:_VDUP:TEXT)
			    AADD(clenfat, "N." + StrTran(AllTrim(oXml:_NFE:_INFNFE:_COBR:_DUP:_NDUP:TEXT)," ","") +;
		        "-VENC="+AllTrim(ConvDate(oXml:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT))+;
	            "-VAL=R$" + AllTrim(ConvValDec(oXml:_NFE:_INFNFE:_COBR:_DUP:_VDUP:TEXT)) + "  ||  ")
			else
				For nX := 1 To nFaturas
			 	   //	textfat += "N."+oXml:_NFE:_INFNFE:_COBR:_DUP[nX]:_NDUP:TEXT+;
			  	   //      "-VENC-"+ConvDate(oXml:_NFE:_INFNFE:_COBR:_DUP[nX]:_DVENC:TEXT)+;
			       //   	 "-VAL-R$"+ConvValDec(oXml:_NFE:_INFNFE:_COBR:_DUP[nX]:_VDUP:TEXT)+"  ||  "

		   			AADD(clenfat, "N." + StrTran(AllTrim(oXml:_NFE:_INFNFE:_COBR:_DUP[nX]:_NDUP:TEXT)," ","") +;
		  	        "-VENC="+AllTrim(ConvDate(oXml:_NFE:_INFNFE:_COBR:_DUP[nX]:_DVENC:TEXT))+;
	     		    "-VAL=R$" + AllTrim(ConvValDec(oXml:_NFE:_INFNFE:_COBR:_DUP[nX]:_VDUP:TEXT)) + "  ||  ")
				next nX
			endif

		    iif(nFaturas==1,alenlinha[1]+= clenfat[1],"")
		    iif(nFaturas>1,alenlinha[1]+= clenfat[1]+clenfat[2],"")
		    iif(nFaturas>2,alenlinha[1]+= clenfat[3],"")
		    iif(nFaturas>3,alenlinha[1]+= clenfat[4],"")
		    iif(nFaturas>4,alenlinha[2]+= clenfat[5],"")
		    iif(nFaturas>5,alenlinha[2]+= clenfat[6],"")
		    iif(nFaturas>6,alenlinha[2]+= clenfat[7],"")
		    iif(nFaturas>7,alenlinha[2]+= clenfat[8],"")
		    iif(nFaturas>8,alenlinha[3]+= clenfat[9],"")
		    iif(nFaturas>9,alenlinha[3]+= clenfat[10],"")
		    iif(nFaturas>10,alenlinha[3]+= clenfat[11],"")
		    iif(nFaturas>11,alenlinha[3]+= clenfat[12],"")
		    iif(nFaturas>12,alenlinha[4]+= clenfat[13],"")
		    iif(nFaturas>13,alenlinha[4]+= clenfat[14],"")
		    iif(nFaturas>14,alenlinha[4]+= clenfat[15],"")
		    iif(nFaturas>15,alenlinha[4]+= clenfat[16],"")

		    oDanfe:Box(265,000,296,603)
		    //oDanfe:Say(263,002,"FATURA",oFont08N)
		    oDanfe:Say(272,002,alenlinha[1],oFont07)
		    oDanfe:Say(279,002,alenlinha[2],oFont07)
		    oDanfe:Say(286,002,alenlinha[3],oFont07)
		    oDanfe:Say(293,002,alenlinha[4],oFont07)

		endif
	endif
	//if nFaturas < 4
	//	oDanfe:SayAlign(267,002,textfat,oFont08,599,27,,0,0)
	//elseif nFaturas < 17
	//	oDanfe:SayAlign(267,002,textfat,oFont06,599,27,,0,0)
	//elseif nFaturas > 16
	//	oDanfe:SayAlign(267,002,textfat,oFont04,599,27,,0,0)
	//endif

	// QUADRO 8 Calculo do imposto
	aTotais[01] := iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT, "_VBC")<>nil ,ConvValDec(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBC:TEXT)," ")
	aTotais[02] := iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT, "_VICMS")<>nil ,ConvValDec(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT)," ")
	aTotais[03] := iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT, "_VBCST")<>nil ,ConvValDec(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBCST:TEXT)," ")
	aTotais[04] := iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT, "_VST")<>nil ,ConvValDec(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT)," ")
	aTotais[05] := iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT, "_VPROD")<>nil ,ConvValDec(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:TEXT)," ")
	aTotais[06] := iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT, "_VFRETE")<>nil ,ConvValDec(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VFRETE:TEXT)," ")
	aTotais[07] := iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT, "_VSEG")<>nil ,ConvValDec(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VSEG:TEXT)," ")
	aTotais[08] := iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT, "_VDESC")<>nil ,ConvValDec(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VDESC:TEXT)," ")
	aTotais[09] := iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT, "_VOUTRO")<>nil ,ConvValDec(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VOUTRO:TEXT)," ")
	aTotais[10] := iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT, "_VIPI")<>nil ,ConvValDec(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VIPI:TEXT)," ")
	aTotais[11] := iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT, "_VNF")<>nil ,ConvValDec(oXml:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT)," ")

	oDanfe:Say(305,002,"CALCULO DO IMPOSTO",oFont06N)
	oDanfe:Box(307,000,330,121)
	oDanfe:Say(313,002,"BASE DE CALCULO DO ICMS",oFont06N)
	oDanfe:SayAlign(317, 002,aTotais[01],oFont08,117,21,,2,2)
	oDanfe:Box(307,120,330,200)
	oDanfe:Say(313,125,"VALOR DO ICMS",oFont06N)
	oDanfe:SayAlign(317,122,aTotais[02],oFont08,76,21,,2,2)
	oDanfe:Box(307,199,330,360)
	oDanfe:Say(313,200,"BASE DE CALCULO DO ICMS SUBSTITUIÇÃO",oFont06N)
	oDanfe:SayAlign(317,201,aTotais[03],oFont08,157,21,,2,2)
	oDanfe:Box(307,360,330,490)
	oDanfe:Say(313,363,"VALOR DO ICMS SUBSTITUIÇÃO",oFont06N)
	oDanfe:SayAlign(317,362,aTotais[04],oFont08,126,21,,2,2)
	oDanfe:Box(307,490,330,603)
	oDanfe:Say(313,491,"VALOR TOTAL DOS PRODUTOS",oFont06N)
	oDanfe:SayAlign(317,492,aTotais[05],oFont08,109,21,,2,2)
	oDanfe:Box(330,000,353,110)
	oDanfe:Say(336,002,"VALOR DO FRETE",oFont06N)
	oDanfe:SayAlign(340,002,aTotais[06],oFont08,106,21,,2,2)
	oDanfe:Box(330,100,353,190)
	oDanfe:Say(336,102,"VALOR DO SEGURO",oFont06N)
	oDanfe:SayAlign(340,102,aTotais[07],oFont08,86,21,,2,2)
	oDanfe:Box(330,190,353,290)
	oDanfe:Say(336,194,"DESCONTO",oFont06N)
	oDanfe:SayAlign(340,192,aTotais[08],oFont08,96,21,,2,2)
	oDanfe:Box(330,290,353,415)
	oDanfe:Say(336,295,"OUTRAS DESPESAS ACESSÓRIAS",oFont06N)
	oDanfe:SayAlign(340,292,aTotais[09],oFont08,121,21,,2,2)
	oDanfe:Box(330,414,353,500)
	oDanfe:Say(336,420,"VALOR DO IPI",oFont06N)
	oDanfe:SayAlign(340,416,aTotais[10],oFont08,82,21,,2,2)
	oDanfe:Box(330,500,353,603)
	oDanfe:Say(336,506,"VALOR TOTAL DA NOTA",oFont06N)
	oDanfe:SayAlign(340,502,aTotais[11],oFont08,99,21,,2,2)

	// Quadro 9 Transportador/Volumes transportados
	ctransp := XmlChildEx(oXml:_NFE:_INFNFE:_TRANSP, "_TRANSPORTA")
	if XmlChildEx(oXml:_NFE:_INFNFE:_TRANSP, "_MODFRETE") <> nil
		cModFrete := oXml:_NFE:_INFNFE:_TRANSP:_MODFRETE:TEXT
	endif
	oDanfe:Say(361,002,"TRANSPORTADOR/VOLUMES TRANSPORTADOS",oFont06N)
	oDanfe:Box(363,000,386,603)
	oDanfe:Say(369,002,"RAZÃO SOCIAL",oFont06N)
	oDanfe:Say(382,002,iif(ctransp<>nil .AND. cModFrete<>"9", (iif(XmlChildEx(ctransp, "_XNOME")<>nil,UPPER(Substr(ctransp:_XNOME:TEXT,1,50)),"") ),""),oFont08)
	oDanfe:Box(363,245,386,315)
	oDanfe:Say(369,247,"FRETE POR CONTA",oFont06N)
	If cModFrete =="0"
		oDanfe:Say(382,247,"0-EMITENTE",oFont08)
	ElseIf cModFrete =="1"
		oDanfe:Say(382,247,"1-DESTINATARIO",oFont08)
	ElseIf cModFrete =="2"
		oDanfe:Say(382,247,"2-TERCEIROS",oFont08)
	ElseIf cModFrete =="9"
		oDanfe:Say(382,247,"9-SEM FRETE",oFont08)
	Else
		oDanfe:Say(382,247,"",oFont08)
	Endif
	cVeicTrans := XmlChildEx(oXml:_NFE:_INFNFE:_TRANSP, "_VEICTRANS")
	oDanfe:Box(363,315,386,370)
	oDanfe:Say(369,317,"CÓDIGO ANTT",oFont06N)
	oDanfe:Say(382,319,iif(cVeicTrans<>nil .AND. cModFrete<>"9" .and. XmlChildEx(cVeicTrans, "_RNTC")<>nil,cVeicTrans:_RNTC:TEXT,""),oFont08)
	oDanfe:Box(363,370,386,490)
	oDanfe:Say(369,375,"PLACA DO VEÍCULO",oFont06N)
	oDanfe:Say(382,375,iif(cVeicTrans<>nil .AND. cModFrete<>"9" .and. XmlChildEx(cVeicTrans, "_PLACA")<>nil,cVeicTrans:_PLACA:TEXT,""),oFont08)
	oDanfe:Box(363,450,386,510)
	oDanfe:Say(369,452,"UF",oFont06N)
	oDanfe:Say(382,452,iif(cVeicTrans<>nil .AND. cModFrete<>"9" .and. XmlChildEx(cVeicTrans, "_UF")<>nil,cVeicTrans:_UF:TEXT,""),oFont08)
	oDanfe:Box(363,510,386,603)
	oDanfe:Say(369,512,"CNPJ/CPF",oFont06N)
	oDanfe:Say(382,512,iif(ctransp<>nil .AND. cModFrete<>"9" .and. XmlChildEx(ctransp, "_CNPJ")<>nil,Transform(ctransp:_CNPJ:TEXT,"@r 99.999.999/9999-99"),""),oFont08)
	oDanfe:Say(382,512,iif(ctransp<>nil .AND. cModFrete<>"9" .and. XmlChildEx(ctransp, "_CPF")<>nil,Transform(ctransp:_CPF:TEXT,"@r 999.999.999-99"),""),oFont08)

	oDanfe:Box(385,000,409,603)
	oDanfe:Box(385,000,409,241)
	oDanfe:Say(391,002,"ENDEREÇO",oFont06N)
	oDanfe:Say(404,002,iif(ctransp<>nil .AND. cModFrete<>"9" .and. XmlChildEx(ctransp, "_XENDER")<>nil,UPPER(Substr(ctransp:_XENDER:TEXT,1,50)),""),oFont08)
	oDanfe:Box(385,240,409,341)
	oDanfe:Say(391,242,"MUNICIPIO",oFont06N)
	oDanfe:Say(404,242,iif(ctransp<>nil .AND. cModFrete<>"9" .and. XmlChildEx(ctransp, "_XMUN")<>nil,UPPER(ctransp:_XMUN:TEXT),""),oFont08)
	oDanfe:Box(385,340,409,440)
	oDanfe:Say(391,342,"UF",oFont06N)
	oDanfe:Say(404,342,iif(ctransp<>nil .AND. cModFrete<>"9" .and. XmlChildEx(ctransp, "_UF")<>nil,ctransp:_UF:TEXT,""),oFont08)
	oDanfe:Box(385,440,409,603)
	oDanfe:Say(391,442,"INSCRIÇÃO ESTADUAL",oFont06N)
	oDanfe:Say(404,442,iif(ctransp<>nil .AND. cModFrete<>"9" .and. XmlChildEx(ctransp, "_IE")<>nil,ctransp:_IE:TEXT,""),oFont08) //XmlChildEx(ctransp, "_IE")<>nil

	cvolume := XmlChildEx(oXml:_NFE:_INFNFE:_TRANSP, "_VOL")
	oDanfe:Box(408,000,432,603)
	oDanfe:Box(408,000,432,101)
	oDanfe:Say(414,002,"QUANTIDADE",oFont06N)
	oDanfe:Say(428,002,iif(cvolume<>nil .AND. XmlChildEx(cvolume, "_QVOL")<>nil,cvolume:_QVOL:TEXT,""),oFont08)
	oDanfe:Box(408,100,432,200)
	oDanfe:Say(414,102,"ESPECIE",oFont06N)
	oDanfe:Say(428,102,iif(cvolume<>nil .AND. XmlChildEx(cvolume, "_ESP")<>nil,cvolume:_ESP:TEXT,""),oFont08)
	oDanfe:Box(408,200,432,301)
	oDanfe:Say(414,202,"MARCA",oFont06N)
	oDanfe:Say(428,202,iif(cvolume<>nil .AND. XmlChildEx(cvolume, "_MARCA")<>nil,cvolume:_MARCA:TEXT,""),oFont08)
	oDanfe:Box(408,300,432,400)
	oDanfe:Say(414,302,"NUMERAÇÃO",oFont06N)
	oDanfe:Say(428,302,iif(cvolume<>nil .AND. XmlChildEx(cvolume, "_NVOL")<>nil,cvolume:_NVOL:TEXT,""),oFont08)
	oDanfe:Box(408,400,432,501)
	oDanfe:Say(414,402,"PESO BRUTO",oFont06N)
	oDanfe:Say(428,402,iif(cvolume<>nil .AND. XmlChildEx(cvolume, "_PESOL")<>nil,Transform(Val(cvolume:_PESOL:TEXT),"@E 999999.999"),""),oFont08)
	oDanfe:Box(408,500,432,603)
	oDanfe:Say(414,502,"PESO LIQUIDO",oFont06N)
	oDanfe:Say(428,502,iif(cvolume<>nil .AND. XmlChildEx(cvolume, "_PESOB")<>nil,Transform(Val(cvolume:_PESOB:TEXT),"@E 999999.999"),""),oFont08)

	//QUADRO 9 Calculo do ISSQN
	oDanfe:Say(686,000,"CALCULO DO ISSQN",oFont06N)
	oDanfe:Box(688,000,711,151)
	oDanfe:Say(694,002,"INSCRIÇÃO MUNICIPAL",oFont06N)
	oDanfe:Say(706,002,iif(XmlChildEx(oXml:_NFE:_INFNFE:_EMIT, "_IM")<>NIL,oXml:_NFE:_INFNFE:_EMIT:_IM:TEXT,""),oFont08)
	oDanfe:Box(688,150,711,301)
	oDanfe:Say(694,152,"VALOR TOTAL DOS SERVIÇOS",oFont06N)
	oDanfe:Say(706,152,iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL, "_ISSQNTOT")<>NIL,(iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL:_ISSQNTOT, "_VSERV")<>NIL,ConvValDec(oXml:_NFE:_INFNFE:_TOTAL:_ISSQNTOT:_VSERV:TEXT),"")),""),oFont08)
	oDanfe:Box(688,300,711,451)
	oDanfe:Say(694,302,"BASE DE CÁLCULO DO ISSQN",oFont06N)
	oDanfe:Say(706,302,iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL, "_ISSQNTOT")<>NIL,(iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL:_ISSQNTOT, "_VBC")<>NIL,ConvValDec(oXml:_NFE:_INFNFE:_TOTAL:_ISSQNTOT:_VBC:TEXT),"")),""),oFont08)
	oDanfe:Box(688,450,711,603)
	oDanfe:Say(694,452,"VALOR DO ISSQN",oFont06N)
	oDanfe:Say(706,452,iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL, "_ISSQNTOT")<>NIL,(iif(XmlChildEx(oXml:_NFE:_INFNFE:_TOTAL:_ISSQNTOT, "_VISS")<>NIL,ConvValDec(oXml:_NFE:_INFNFE:_TOTAL:_ISSQNTOT:_VISS:TEXT),"")),""),oFont08)

	//³Dados Adicionais
	oDanfe:Say(719,000,"DADOS ADICIONAIS",oFont06N)
	oDanfe:Box(721,000,865,351)
	oDanfe:Say(727,002,"INFORMAÇÕES COMPLEMENTARES",oFont06N)
	oDanfe:Box(721,351,865,603)
	oDanfe:Say(727,353,"RESERVADO AO FISCO",oFont06N)
	Private cinfcomp := ''
	if XmlChildEx(oXml:_NFE:_INFNFE, "_INFADIC")<>NIL
		if XmlChildEx(oXml:_NFE:_INFNFE:_INFADIC, "_INFADFISCO")<>NIL
	   		cinfcomp += oXml:_NFE:_INFNFE:_INFADIC:_INFADFISCO:TEXT +"  "
		endif
		if XmlChildEx(oXml:_NFE:_INFNFE:_INFADIC, "_INFCPL")<>NIL
			cinfcomp += oXml:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT
		endif
	   //	if XmlChildEx(oXml:_NFE:_INFNFE:_INFADIC, "_INFADFISCO")<>NIL
	   //		oDanfe:SayAlign(737,353,oXml:_NFE:_INFNFE:_INFADIC:_INFADFISCO:TEXT,oFont07,250,128,,0,0)
	   //	endif
	endif
	oDanfe:SayAlign(737,004,UPPER(cinfcomp),oFont07,343,128,,0,0)

	//³Dados do produto ou servico
	if XmlChildEx(oXml:_NFE:_InfNfe:_emit, "_CRT")<>NIL
		CstCsons  := IIf(oXml:_NFE:_InfNfe:_emit:_CRT:TEXT  == "1",CstCsons:="CSOSN",CstCsons:="CST")
	endif

	aTamCol := {65,130,35,25,25,20,30,35,50,50,45,30,35,28}

	oDanfe:Say(440,002,"DADOS DO PRODUTO / SERVIÇO",oFont06N)
	oDanfe:Box(442,000,678,603)
	nAuxH := 0
	oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[1])
	oDanfe:Say(450, nAuxH + 2, "COD. PROD",oFont06N)
	nAuxH += aTamCol[1]
	oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[2])
	oDanfe:Say(450, nAuxH + 2, "DESCRIÇÃO DO PROD./SERV.", oFont06N)
	nAuxH += aTamCol[2]
	oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[3])
	oDanfe:Say(450, nAuxH + 2, "NCM/SH", oFont06N)
	nAuxH += aTamCol[3]
	oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[4])
	oDanfe:Say(450, nAuxH + 2, CstCsons, oFont06N)
	nAuxH += aTamCol[4]
	oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[5])
	oDanfe:Say(450, nAuxH + 2, "CFOP", oFont06N)
	nAuxH += aTamCol[5]
	oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[6])
	oDanfe:Say(450, nAuxH + 2, "UN", oFont06N)
	nAuxH += aTamCol[6]
	oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[7])
	oDanfe:Say(450, nAuxH + 2, "QUANT.", oFont06N)
	nAuxH += aTamCol[7]
	oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[8])
	oDanfe:Say(450, nAuxH + 2, "V.UNIT.", oFont06N)
	nAuxH += aTamCol[8]
	oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[9])
	oDanfe:Say(450, nAuxH + 2, "V.TOTAL", oFont06N)
	nAuxH += aTamCol[9]
	oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[10])
	oDanfe:Say(450, nAuxH + 2, "BC.ICMS", oFont06N)
	nAuxH += aTamCol[10]
	oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[11])
	oDanfe:Say(450, nAuxH + 2, "V.ICMS", oFont06N)
	nAuxH += aTamCol[11]
	oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[12])
	oDanfe:Say(450, nAuxH + 2, "V.IPI", oFont06N)
	nAuxH += aTamCol[12]
	oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[13])
	oDanfe:Say(450, nAuxH + 2, "A.ICMS", oFont06N)
	nAuxH += aTamCol[13]
	oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[14])
	oDanfe:Say(450, nAuxH + 2, "A.IPI",oFont06N)

	//montando array dos itens com informações do xml

	for cont := 1 to len(oXml:_NFE:_INFNFE:_DET)
		citens := {}
		AADD(citens,substr(oXml:_NFE:_INFNFE:_DET[cont]:_PROD:_CPROD:TEXT,1,19) ) //1
		AADD(citens,ALLTrim(UPPER(oXml:_NFE:_INFNFE:_DET[cont]:_PROD:_XPROD:TEXT))) //2
		AADD(citens,iif(XmlChildEx(oXml:_NFE:_INFNFE:_DET[cont]:_PROD,"_NCM")<>nil,ALLTrim(oXml:_NFE:_INFNFE:_DET[cont]:_PROD:_NCM:TEXT),"") ) //3
	    //impostos
		If XmlChildEx(oXml:_NFE:_INFNFE:_DET[cont], "_IMPOSTO") <> NIL
			If XmlChildEx(oXml:_NFE:_INFNFE:_DET[cont]:_IMPOSTO, "_ICMS") <> NIL
				if CstCsons == "CST"
					For nY := 1 To Len(aSitTrib)
						If XmlChildEx(oXml:_NFE:_INFNFE:_DET[cont]:_IMPOSTO:_ICMS, "_ICMS"+aSitTrib[nY]) <> NIL
						  	oimposto := XmlChildEx(oXml:_NFE:_INFNFE:_DET[cont]:_IMPOSTO:_ICMS, "_ICMS"+aSitTrib[nY])
							If XmlChildEx(oimposto, "_VBC") <> NIL
						   		nBaseICM := oimposto:_VBC:TEXT
						   		nValICM  := oimposto:_vICMS:TEXT
						   		nPICM    := oimposto:_PICMS:TEXT
							EndIf
						  	cSitTrib := oimposto:_ORIG:TEXT
						  	cSitTrib += oimposto:_CST:TEXT
						EndIf
					Next nY
				endif
				if CstCsons == "CSOSN"
					For nY := 1 To Len(aSitSN)
						If XmlChildEx(oXml:_NFE:_INFNFE:_DET[cont]:_IMPOSTO:_ICMS, "_ICMSSN"+aSitSN[nY]) <> NIL
							oimpostsn := XmlChildEx(oXml:_NFE:_INFNFE:_DET[cont]:_IMPOSTO:_ICMS, "_ICMSSN"+aSitSN[nY])
							If XmlChildEx(oimpostsn, "_VBC") <> NIL
								nBaseICM := oimpostsn:_VBC:TEXT
								nValICM  := oimpostsn:_vICMS:TEXT
								nPICM    := oimpostsn:_PICMS:TEXT
							EndIf
							cSitTrib := oimpostsn:_ORIG:TEXT
							cSitTrib += oimpostsn:_CSOSN:TEXT
						EndIf
					Next nY
				endif
			endif
		ENDIF
		AADD(citens,ALLTrim(cSitTrib) ) //4
		AADD(citens,ALLTrim(oXml:_NFE:_INFNFE:_DET[cont]:_PROD:_CFOP:TEXT) ) //5
		AADD(citens,ALLTrim(oXml:_NFE:_INFNFE:_DET[cont]:_PROD:_UTRIB:TEXT) ) //6
		If XmlChildEx(oXml:_NFE:_INFNFE:_DET[cont]:_PROD, "_QCOM") <> NIL
			AADD(citens,ConvValDec(oXml:_NFE:_INFNFE:_DET[cont]:_PROD:_QCOM:TEXT) ) //7
		else
	    	AADD(citens,"0,00")
		endif
		If XmlChildEx(oXml:_NFE:_INFNFE:_DET[cont]:_PROD, "_VUNCOM") <> NIL
			AADD(citens,ConvValDec(oXml:_NFE:_INFNFE:_DET[cont]:_PROD:_VUNCOM:TEXT) ) //8
		else
	    	AADD(citens,"0,00")
		endif
		If XmlChildEx(oXml:_NFE:_INFNFE:_DET[cont]:_PROD, "_VPROD") <> NIL
			AADD(citens,ConvValDec(oXml:_NFE:_INFNFE:_DET[cont]:_PROD:_VPROD:TEXT) ) //9
		else
	    	AADD(citens,"0,00")
		endif
	    AADD(citens,ConvValDec(nBaseICM)) // 10
	    AADD(citens,ConvValDec(nValICM)) // 11
		if XmlChildEx(oXml:_NFE:_INFNFE:_DET[cont]:_IMPOSTO,  "_IPI") <> nil
			if XmlChildEx(oXml:_NFE:_INFNFE:_DET[cont]:_IMPOSTO:_IPI ,  "_IPITRIB") <> nil
				if XmlChildEx(oXml:_NFE:_INFNFE:_DET[cont]:_IMPOSTO:_IPI:_IPITRIB, "_VBC") <> nil
					if val(oXml:_NFE:_INFNFE:_DET[cont]:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT ) > 0 .and. val(oXml:_NFE:_INFNFE:_DET[cont]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT) > 0
			  	    	nValIPI := oXml:_NFE:_INFNFE:_DET[cont]:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT
	 			   		nPIPI := oXml:_NFE:_INFNFE:_DET[cont]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT
					endif
				ENDIF
			endif
		endif
	    AADD(citens,ConvValDec(nValIPI)) // 12
	    AADD(citens,ConvValDec(nPICM))// 13
	    AADD(citens,ConvValDec(nPIPI)) // 14

	    AADD(aAux,citens)
	next cont

	//Calculo do total de paginas --------------------------------------------------------
	nitens := len(oXml:_NFE:_INFNFE:_DET)
	nLinha := 455
	nlimite := nLinha + 207
	nitensini := 1
	while nLinha <= nlimite .AND. nitensini <= nitens
		if len(aAux[nitensini,2]) > 35
	  		cdescpro:= INT(len(aAux[nitensini,2])/35)
			if MOD(len(aAux[nitensini,2]),35) > 0
	  			cdescpro++
			endif
			nLinha += (cdescpro*8)
		else
			nLinha += 8
		endif
		nitensini ++
	enddo
	totpagina := 1
	If nitensini <= nitens
		while nitensini <= nitens
	   		nLinha := 170
			nlimite := nLinha + 660
		    totpagina ++
			while nLinha <= nlimite .AND. nitensini <= nitens
				if len(aAux[nitensini,2]) > 35
	  				cdescpro:= INT(len(aAux[nitensini,2])/35)
					if MOD(len(aAux[nitensini,2]),35) > 0
	  		 			cdescpro++
					endif
					nLinha += cdescpro*8
				else
		   			nLinha += 8
				endif
				nitensini ++
			enddo
		enddo
	endif
	oDanfe:Say(130,255,"FOLHA "+StrZero(npagina,2)+"/"+StrZero(totpagina,2),oFont10N)
	//----fim do calculo do total de paginas----------------------------------

	nitens := len(oXml:_NFE:_INFNFE:_DET)
	nLinha := 455
	nlimite := nLinha + 207
	nitensini := 1
	while nLinha <= nlimite .AND. nitensini <= nitens

		    nAuxH := 0
		   	oDanfe:SayAlign(nLinha, nAuxH + 2,aAux[nitensini,1],oFont06,aTamCol[1] - 3,8,,0,1) // codigo 1
			nAuxH += aTamCol[1]

		if len(aAux[nitensini,2]) > 35
	  			cdescpro:= INT(len(aAux[nitensini,2])/35)
			if MOD(len(aAux[nitensini,2]),35) > 0
	  				cdescpro++
			endif
	  			Private ncontrol := 1
	  			Private nlincont := 0
			for cont:=1 to cdescpro
	  		    	oDanfe:SayAlign(nLinha+nlincont, nAuxH + 2,substr(aAux[nitensini,2],ncontrol,35),oFont06,aTamCol[2] - 3,8,,0,1)
	  		        ncontrol += 35
	  				nlincont += 8
			next cont
		else
				oDanfe:SayAlign(nLinha, nAuxH + 2,aAux[nitensini,2],oFont06,aTamCol[2] - 3,8,,0,1) // DESCRICAO DO PRODUTO 2
		endif

	  		nAuxH += aTamCol[2]
			oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,3],oFont06,aTamCol[3],8,,2,1) // NCM 3
			nAuxH += aTamCol[3]
			oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,4],oFont06,aTamCol[4],8,,2,1)  // CST 4
			nAuxH += aTamCol[4]
			oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,5],oFont06,aTamCol[5],8,,2,1)  // CFOP 5
			nAuxH += aTamCol[5]
			oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,6],oFont06,aTamCol[6],8,,2,1)  // UN 6
			nAuxH += aTamCol[6]
		    oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,7],oFont06,aTamCol[7] - 4,8,,1,1) // QUANT 7
			nAuxH += aTamCol[7]
			oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,8],oFont06,aTamCol[8] - 4,8,,1,1) // V UNITARIO 8
		   	nAuxH += aTamCol[8]
			oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,9],oFont06,aTamCol[9] - 4,8,,1,1) // V. TOTAL  9
			nAuxH += aTamCol[9]
			oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,10],oFont06,aTamCol[10] - 4,8,,1,1) // BC. ICMS 10
			nAuxH += aTamCol[10]
			oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,11],oFont06,aTamCol[11] - 4,8,,1,1) // V. ICMS  11
			nAuxH += aTamCol[11]
			oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,12],oFont06,aTamCol[12] - 4,8,,1,1) // V.IPI 12
			nAuxH += aTamCol[12]
			oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,13],oFont06,aTamCol[13] - 4,8,,1,1) // A.ICMS 13
			nAuxH += aTamCol[13]
			oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,14],oFont06,aTamCol[14] - 4,8,,1,1) // A.IPI  14
			iif(len(aAux[nitensini,2]) > 35,nLinha += (cdescpro*8),	nLinha += 8)
			nitensini ++
	enddo

	Iif( nitensini <= nitens, oDanfe:SayAlign(nLinha, aTamCol[1],"-----CONTINUA NO VERSO------",oFont06,aTamCol[2],10,,2,1),"")

	// INICIANDO INFORMAÇÕES PARA O CABEÇALHO DA PAGINA 2 em diante

	If nitensini <= nitens
		while nitensini <= nitens
			Iif( nitensini <= nitens,oDanfe:Say(875,497,"-----CONTINUA NO VERSO------"),"")
			oDanfe:EndPage()
			oDanfe:StartPage()
			//Quadro 1 IDENTIFICACAO DO EMITENTE
			oDanfe:Box(002,000,097,250)
			oDanfe:Say(012,003,"Identificação do emitente",oFont10N)
			nAuxH := 014
			oDanfe:SayAlign(nAuxH,002,UPPER(oXml:_NFE:_INFNFE:_EMIT:_XNOME:TEXT),oFont15N,246,30,,2,1)//Nome emitente
			nAuxH += 30
			oDanfe:SayAlign(nAuxH,000,UPPER(oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XLGR:TEXT);
			+", "+oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_NRO:TEXT,oFont10,250,9,,2,1)	//logradouro
			nAuxH += 9
			oDanfe:SayAlign(nAuxH,000,UPPER(oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XBAIRRO:TEXT),oFont10,250,9,,2,1)	// bairro
			nAuxH += 9
			oDanfe:SayAlign(nAuxH,000,UPPER(oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XMUN:TEXT);
			+" - "+oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT,oFont10,250,9,,2,1)	// municipio
			nAuxH += 9
			oDanfe:SayAlign(nAuxH,000,"CEP "+TransForm(oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CEP:TEXT,"@r 99999-999"),oFont10,250,9,,2,1)	// cep
			nAuxH += 9
			if XmlChildEx(oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT, "_FONE") <> nil
	 			oDanfe:SayAlign(nAuxH,000,"FONE: "+Convfone(oXml:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_FONE:TEXT),oFont10,250,9,,2,1) // telefone
			endif

			// quadro 2 - entrada / saida
			oDanfe:Box(002,248,097,351)
			oDanfe:Say(015,275, "DANFE",oFont15N)
			oDanfe:Say(025,251, "DOCUMENTO AUXILIAR DA",oFont07)
			oDanfe:Say(035,251, "NOTA FISCAL ELETRÔNICA",oFont07)
			oDanfe:Say(045,266, "0-ENTRADA",oFont08)
			oDanfe:Say(055,266, "1-SAÍDA"  ,oFont08)
			oDanfe:Box(038,315,055,325)
			oDanfe:Say(049,318, oXml:_NFE:_INFNFE:_IDE:_TPNF:TEXT,oFont08N)
			oDanfe:Say(070,255,"N. "+STRZERO(val(oXml:_NFE:_INFNFE:_IDE:_NNF:TEXT),9),oFont10N)
			oDanfe:Say(080,255,"SÉRIE "+oXml:_NFE:_INFNFE:_IDE:_SERIE:TEXT,oFont10N)
			npagina ++
			oDanfe:Say(090,255,"FOLHA "+StrZero(npagina,2)+"/"+StrZero(totpagina,2),oFont10N)

			//quadro 3 - codigo de barras
			oDanfe:Box(002,350,048,603)
			oDanfe:Box(035,350,070,603)
			oDanfe:Box(065,350,097,603)
			oDanfe:Say(055,355,TransForm(SubStr(oXml:_NFE:_INFNFE:_ID:TEXT,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont11N)
			oDanfe:Say(043,355,"CHAVE DE ACESSO DA NF-E",oFont08N)
			oDanfe:Code128C(032,370,SubStr(oXml:_NFE:_INFNFE:_ID:TEXT,4), 28 )
			oDanfe:Say(077,355,"Consulta de autenticidade no portal nacional da NF-e",oFont11)
			oDanfe:Say(087,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont11)

			//quadro 4 - natureza
			oDanfe:Box(099,000,122,603)
			oDanfe:Box(099,000,122,350)
			oDanfe:Say(105,002,"NATUREZA DA OPERAÇÃO",oFont06N)
			oDanfe:Say(118,002,UPPER(oXml:_NFE:_INFNFE:_IDE:_NATOP:TEXT),oFont11)
			oDanfe:Say(105,352,"PROTOCOLO DE AUTORIZAÇÃO DE USO",oFont06N)
			if XmlChildEx(oXml, "_PROTNFE") <> nil
				if XmlChildEx(oXml:_PROTNFE:_INFPROT, "_NPROT") <> nil
	   				cdaEmi := oXml:_PROTNFE:_INFPROT:_DHRECBTO:TEXT
	   				cdaEmi := Substr(cdaEmi,9,2)+"/"+Substr(cdaEmi,6,2)+"/"+Substr(cdaEmi,3,2)+" "+Substr(cdaEmi,12,8)
	    			oDanfe:Say(118,354,oXml:_PROTNFE:_INFPROT:_NPROT:TEXT+" "+cdaEmi,oFont08)
				endif
			endif

			// Quadro 5 - IE e CNPJ
			oDanfe:Box(124,000,147,603)
			oDanfe:Box(124,000,147,200)
			oDanfe:Box(124,200,147,400)
			oDanfe:Box(124,400,147,603)
			oDanfe:Say(130,002,"INSCRIÇÃO ESTADUAL",oFont06N)
			oDanfe:Say(140,002,IIf(XmlChildEx(oXml:_NFE:_INFNFE:_EMIT, "_IE") <> nil,oXml:_NFE:_INFNFE:_EMIT:_IE:TEXT,""),oFont11)
			oDanfe:Say(130,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont06N)
			oDanfe:Say(140,205,IIf(XmlChildEx(oXml:_NFE:_INFNFE:_EMIT, "_IEST") <> nil,oXml:_NFE:_INFNFE:_EMIT:_IEST:TEXT,""),oFont11)
			oDanfe:Say(130,405,"CNPJ",oFont06N)
			oDanfe:Say(140,405,TransForm(oXml:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT,IIf(Len(oXml:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont11)

	        // Quadro 6 - DADOS DO PRODUTO / SERVIÇO
			oDanfe:Say(155,002,"DADOS DO PRODUTO / SERVIÇO",oFont06N)
			oDanfe:Box(157,000,865,603)
			nAuxH := 0
			oDanfe:Box(157, nAuxH, 865, nAuxH + aTamCol[1])
			oDanfe:Say(165, nAuxH + 2, "COD. PROD",oFont06N)
			nAuxH += aTamCol[1]
			oDanfe:Box(157, nAuxH, 865, nAuxH + aTamCol[2])
			oDanfe:Say(165, nAuxH + 2, "DESCRIÇÃO DO PROD./SERV.", oFont06N)
			nAuxH += aTamCol[2]
			oDanfe:Box(157, nAuxH, 865, nAuxH + aTamCol[3])
			oDanfe:Say(165, nAuxH + 2, "NCM/SH", oFont06N)
			nAuxH += aTamCol[3]
			oDanfe:Box(157, nAuxH, 865, nAuxH + aTamCol[4])
			oDanfe:Say(165, nAuxH + 2, CstCsons, oFont06N)
			nAuxH += aTamCol[4]
			oDanfe:Box(157, nAuxH, 865, nAuxH + aTamCol[5])
			oDanfe:Say(165, nAuxH + 2, "CFOP", oFont06N)
			nAuxH += aTamCol[5]
			oDanfe:Box(157, nAuxH, 865, nAuxH + aTamCol[6])
			oDanfe:Say(165, nAuxH + 2, "UN", oFont06N)
			nAuxH += aTamCol[6]
			oDanfe:Box(157, nAuxH, 865, nAuxH + aTamCol[7])
			oDanfe:Say(165, nAuxH + 2, "QUANT.", oFont06N)
			nAuxH += aTamCol[7]
			oDanfe:Box(157, nAuxH, 865, nAuxH + aTamCol[8])
			oDanfe:Say(165, nAuxH + 2, "V.UNIT.", oFont06N)
			nAuxH += aTamCol[8]
			oDanfe:Box(157, nAuxH, 865, nAuxH + aTamCol[9])
			oDanfe:Say(165, nAuxH + 2, "V.TOTAL", oFont06N)
			nAuxH += aTamCol[9]
			oDanfe:Box(157, nAuxH, 865, nAuxH + aTamCol[10])
			oDanfe:Say(165, nAuxH + 2, "BC.ICMS", oFont06N)
			nAuxH += aTamCol[10]
			oDanfe:Box(157, nAuxH, 865, nAuxH + aTamCol[11])
			oDanfe:Say(165, nAuxH + 2, "V.ICMS", oFont06N)
			nAuxH += aTamCol[11]
			oDanfe:Box(157, nAuxH, 865, nAuxH + aTamCol[12])
			oDanfe:Say(165, nAuxH + 2, "V.IPI", oFont06N)
			nAuxH += aTamCol[12]
			oDanfe:Box(157, nAuxH, 865, nAuxH + aTamCol[13])
			oDanfe:Say(165, nAuxH + 2, "A.ICMS", oFont06N)
			nAuxH += aTamCol[13]
			oDanfe:Box(157, nAuxH, 865, nAuxH + aTamCol[14])
			oDanfe:Say(165, nAuxH + 2, "A.IPI",oFont06N)
	        nLinha := 170
			nlimite := nLinha + 660

			while nLinha <= nlimite .AND. nitensini <= nitens

	  		    nAuxH := 0
			   	oDanfe:SayAlign(nLinha, nAuxH + 2,aAux[nitensini,1],oFont06,aTamCol[1] - 3,8,,0,1) // codigo 1
				nAuxH += aTamCol[1]

				if len(aAux[nitensini,2]) > 35
		  			cdescpro:= INT(len(aAux[nitensini,2])/35)
					if MOD(len(aAux[nitensini,2]),35) > 0
		  				cdescpro++
					endif
		  				oDanfe:SayAlign(nLinha, nAuxH + 2,aAux[nitensini,2],oFont06,aTamCol[2] - 3,(cdescpro*8),,0,1) // DESCRICAO DO PRODUTO 2
				else
					oDanfe:SayAlign(nLinha, nAuxH + 2,aAux[nitensini,2],oFont06,aTamCol[2] - 3,8,,0,1) // DESCRICAO DO PRODUTO 2
				endif

		   		nAuxH += aTamCol[2]
				oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,3],oFont06,aTamCol[3],8,,2,1) // NCM 3
				nAuxH += aTamCol[3]
				oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,4],oFont06,aTamCol[4],8,,2,1)  // CST 4
				nAuxH += aTamCol[4]
				oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,5],oFont06,aTamCol[5],8,,2,1)  // CFOP 5
				nAuxH += aTamCol[5]
				oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,6],oFont06,aTamCol[6],8,,2,1)  // UN 6
				nAuxH += aTamCol[6]
			    oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,7],oFont06,aTamCol[7] - 4,8,,1,1) // QUANT 7
				nAuxH += aTamCol[7]
				oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,8],oFont06,aTamCol[8] - 4,8,,1,1) // V UNITARIO 8
			   	nAuxH += aTamCol[8]
				oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,9],oFont06,aTamCol[9] - 4,8,,1,1) // V. TOTAL  9
	   			nAuxH += aTamCol[9]
				oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,10],oFont06,aTamCol[10] - 4,8,,1,1) // BC. ICMS 10
				nAuxH += aTamCol[10]
				oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,11],oFont06,aTamCol[11] - 4,8,,1,1) // V. ICMS  11
				nAuxH += aTamCol[11]
				oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,12],oFont06,aTamCol[12] - 4,8,,1,1) // V.IPI 12
				nAuxH += aTamCol[12]
				oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,13],oFont06,aTamCol[13] - 4,8,,1,1) // A.ICMS 13
				nAuxH += aTamCol[13]
				oDanfe:SayAlign(nLinha, nAuxH,aAux[nitensini,14],oFont06,aTamCol[14] - 4,8,,1,1) // A.IPI  14
				iif(len(aAux[nitensini,2]) > 35,nLinha += (cdescpro*8),	nLinha += 8)
				nitensini ++
			enddo
			iif(nitensini <= nitens, (oDanfe:SayAlign(nLinha, aTamCol[1] + 2,"-----CONTINUA NO VERSO------",oFont06,aTamCol[2] - 3,10,,0,1),oDanfe:Say(875,497,"-----CONTINUA NO VERSO------")),"")
		enddo
	Endif

	//oDanfe:Preview()
	//oDanfe:cPathPDF := "C:\"
	oDanfe:EndPage()
	oDanfe:Print()

Return


Static Function ConvDate(cData)

	Local dData

	cData  := StrTran(cData,"-","")
	dData  := Stod(cData)
	dData  := PadR(StrZero(Day(dData),2)+ "/" + StrZero(Month(dData),2)+ "/" + StrZero(Year(dData),4),15)

	Return ALLTrim(dData)

Static Function Convfone(ptel)

	Private ctel:= ''

	do case
	case len(ptel) == 8
			ctel:= TransForm(ptel,"@r 9999-9999")
	case len(ptel) == 10
			ctel:= TransForm(ptel,"@r 99-9999-9999")
	case len(ptel) == 11
			ctel:= TransForm(ptel,"@r 999-9999-9999")
	case len(ptel) == 13
			ctel:= TransForm(ptel,"@r 99-999-9999-9999")
	case len(ptel) == 12
			ctel:= TransForm(ptel,"@r 99-99-9999-9999")
	endcase

Return ctel


Static Function ConvValDec(pval)

	Private nvalor := "0,00"
	Private cdescimal := ""

	if Val(pval) > 0
	    cdescimal := ALLTrim(Substr(pval,RAT('.',pval)+1,4))
		if val(cdescimal) == 0  .or. len(cdescimal) == 2
	    	nvalor := ALLTrim(Transform(Val(pval),"@ze 9,999,999,999,999.99"))
		else
			if (len(cdescimal) == 3) .and. (val(Substr(cdescimal,3,1)) > 0)
	       		nvalor := ALLTrim(Transform(Val(pval),"@ze 9,999,999,999,999.999"))
			elseif len(cdescimal) == 4 .and. val(Substr(cdescimal,3,2)) > 0
	       		nvalor := ALLTrim(Transform(Val(pval),"@ze 9,999,999,999,999.9999"))
			else
				nvalor := ALLTrim(Transform(Val(pval),"@ze 9,999,999,999,999.99"))
			endif
		endif
	endif

return nvalor