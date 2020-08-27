#Include 'Protheus.ch'


//----------------------------------------------------------------------
/*/{Protheus.doc}XmlMDFeSef 

Regras para chamada do método remessa

@author Natalia Sartori
@since 25/02/2014
@version P11 

@param 		cFilCC0 		- Filial
			cSerie  		- Série do MDFe
			cNumMDF 		- Número do MDFe
			cAmbiente		- 1- Produção; 2- Homologação
			cVersao 		- Versão do MDFe
			cModalidade	- 1- Normal; 2- Contingência
			cTipo			- Tipo do XML a Ser montado 1- MDFe; 
							  2-Cancelamento; 3- Encerramento		

@return	cChvMDFe		- Chave do MDFe
			cString		- String com XML Encodado
/*/
//-----------------------------------------------------------------------

User Function XmlMDFeSef(cFil)
	Local cString		:= ""
	Local cChvMDFe		:= ""
	Local aNota			:= {}
	Local lRespTec  	:= iif(findFunction("getRespTec"),getRespTec("2"),.T.) //0-Todos, 1-NFe, 2-MDFe
	Local lTagProduc	:= date() > CTOD("15/06/2019") 
	Local lPosterior	:= Type("cPoster") == "C" .And. SubStr(cPoster,1,1) == "1"
	
	Private aUF		:= {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenchimento do Array de UF                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aUF,{"RO","11"})
	aadd(aUF,{"AC","12"})
	aadd(aUF,{"AM","13"})
	aadd(aUF,{"RR","14"})
	aadd(aUF,{"PA","15"})
	aadd(aUF,{"AP","16"})
	aadd(aUF,{"TO","17"})
	aadd(aUF,{"MA","21"})
	aadd(aUF,{"PI","22"})
	aadd(aUF,{"CE","23"})
	aadd(aUF,{"RN","24"})
	aadd(aUF,{"PB","25"})
	aadd(aUF,{"PE","26"})
	aadd(aUF,{"AL","27"})
	aadd(aUF,{"MG","31"})
	aadd(aUF,{"ES","32"})
	aadd(aUF,{"RJ","33"})
	aadd(aUF,{"SP","35"})
	aadd(aUF,{"PR","41"}) 
	aadd(aUF,{"SC","42"})
	aadd(aUF,{"RS","43"})
	aadd(aUF,{"MS","50"})
	aadd(aUF,{"MT","51"})
	aadd(aUF,{"GO","52"})
	aadd(aUF,{"DF","53"})
	aadd(aUF,{"SE","28"})
	aadd(aUF,{"BA","29"})
	aadd(aUF,{"EX","99"})

	aadd(aNota,cSerie)
	aadd(aNota,IIF(Len(cNumero)==6,"000","")+cNumero)
	aadd(aNota,dDataEmi)
	aadd(aNota,cTime)
	aadd(aNota,cUFCarr)
	aadd(aNota,cUFDesc)
	aadd(aNota,alltrim(TRB->TRB_CODMUN))
	aadd(aNota,alltrim(TRB->TRB_NOMMUN))
	aadd(aNota,alltrim(TRB->TRB_EST))
	aadd(aNota,alltrim(iif( lPosterior,"1","0")))

	If !Empty(aNota)
		cString := ""
		cString += MDFeIde(@cChvMDFe,aNota,cVeiculo)
		cString += MDFeEmit()
		cString += MDFeModal(cVeiculo,aNota)
		cString += MDFeInfDoc(aNota)
		cString += MDFeTotais()
		cString += MDFeLacres()
		cString += MDFeAutoriz()
		cString += MDFeInfAdic()
		if lRespTec .and. lTagProduc .and. existFunc("NfeRespTec")
			cString += NfeRespTec(,58) //Responsavel Tecnico
		endif
			
		cString += '</infMDFe>'
		cString += MDFeInfMDFeSupl()
		cString += '</MDFe>'
	EndIf

Return ({cChvMDFe, EncodeUTF8(cString)})

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeIde 

Montagem do elemento ide do XML

@author Natalia Sartori
@since 25/02/2014
@version P11

@param      
@Return	cString
/*/
//-----------------------------------------------------------------------
Static Function MDFeIde(cChave,aNota,cVeiculo)

Local cString		:= ""
Local cTpEmis		:= ""
Local cDV			:= ""
Local cDhEmi		:= "" 
Local lEndFis 	:= GetNewPar("MV_SPEDEND",.F.)
Local lVeic		:= .F. 

Default cVeiculo := ""

If !Empty(cVeiculo)
	//Posiciona da DA3
	lVeic := PocDA3(cVeiculo)
EndIf

cDV := cTpEmis + Inverte(StrZero( val(aNota[02]),8))
cChave := MDFeChave( aUF[aScan(aUF,{|x| x[1] == IIF(!lEndFis,ConvType(SM0->M0_ESTCOB),ConvType(SM0->M0_ESTENT)) })][02],;
						FsDateConv(aNota[03],"YYMM"),AllTrim(SM0->M0_CGC),'58',;
						StrZero(Val(aNota[01]),3),;
						StrZero(Val(aNota[02]),9),;
						cDV )

cDhEmi := SubStr(DToS(aNota[3]), 1, 4) + "-" + SubStr(DToS(aNota[3]), 5, 2) + "-" + SubStr(DToS(aNota[3]), 7, 2) + "T" + aNota[4]

cString += '<MDFe xmlns="http://www.portalfiscal.inf.br/mdfe">'
cString += '<infMDFe Id="MDFe' + AllTrim(cChave) + '" versao="' /*+ cVersao */+ '">'
cString += '<ide>'
cString += '<cUF>'+ ConvType(aUF[aScan(aUF,{|x| x[1] == IIF(!lEndFis,ConvType(SM0->M0_ESTCOB),ConvType(SM0->M0_ESTENT)) })][02],02)+ '</cUF>'
cString += '<tpAmb>' /*+ cAmbiente*/ + '</tpAmb>'      
/* Se tipo emitente informado for igual a Prestador de Serviço de Transporte (tpEmit=1), não poderão ser informados os grupos de documentos NF e/ou chaves de acesso de NF-e. 
Portanto, deverá incluir apenas chaves de acesso de CT-e. 
Sendo assim, Tag <tpEmit> sempre será 2 para NFe
*/    		
cString += '<tpEmit>2</tpEmit>'  //2 - Transportador de Carga Própria OBS: Para emitentes de NF-e e pelas transportadoras quando estiverem fazendo transporte de carga própria 
If lVeic // Terceiro ou Agredado
	cString += '<tpTransp>2</tpTransp>' // 1-ETC  2-TAC  3-CTC 
Endif
cString += '<mod>58</mod>'
If Empty(aNota[01])
	cString += '<serie>'+ "000" +'</serie>'
Else
	cString += '<serie>'+ ConvType(Val(aNota[01]),3) +'</serie>'
Endif                  
cString += '<nMDF>' + ConvType(Val(aNota[02]),9) + '</nMDF>'
cString += '<cMDF>'+ NoAcento(cDV) + '</cMDF>'
cString += '<cDV>' + SubStr( AllTrim(cChave), Len( AllTrim(cChave) ), 1) + '</cDV>'
cString += '<modal>1</modal>'  //Modal Rodoviário
cString += '<dhEmi>' + cDhEmi + '</dhEmi>'
cString += '<tpEmis>' + cTpEmis + '</tpEmis>'
cString += '<procEmi>0</procEmi>'
cString += '<verProc>' + GetlabelTSS() + '</verProc>'
cString += '<UFIni>' + aNota[05] + '</UFIni>'
cString += '<UFFim>' + aNota[06] + '</UFFim>'

//InfMunCarrega
cString += MDFeCarrega() 

If len(aNota) >= 10 .And. aNota[10] == "1"
	cString +=	"<indCarregaPosterior>1</indCarregaPosterior>"
EndIf
//InfPercurso
cString += MDFePercu(aNota) 

cString += '</ide>'

Return cString

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeEmit 

Montagem do elemento emit do XML

@author Natalia Sartori
@since 25/02/2014
@version P11

@param      
@Return	cString
/*/
//-----------------------------------------------------------------------
Static Function MDFeEmit()

Local aTelDest		:= {}
Local cFoneDest	:= ""

Local cString 		:= ""
Local cEndEmit		:= ""

Local lEndFis 		:= GetNewPar("MV_SPEDEND",.F.)
Local lUsaGesEmp	:= IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)

cString := '<emit>'
If Len(AllTrim(SM0->M0_CGC))==14
	cString += '<CNPJ>'+SM0->M0_CGC+'</CNPJ>'
ElseIf Len(AllTrim(SM0->M0_CGC))<>0
	cString += '<CPF>'+AllTrim(SM0->M0_CGC)+'</CPF>'
Else
	cString += '<CNPJ></CNPJ>'
EndIf  
	
cString += '<IE>'+ConvType(VldIE(SM0->M0_INSC))+'</IE>'      
cString += '<xNome>' + alltrim(NoAcento(SubStr(SM0->M0_NOMECOM,1,60))) + '</xNome>'
If lUsaGesEmp
	cString += NfeTag('<xFant>',ConvType(FWFilialName()))
Else
	cString += NfeTag('<xFant>',ConvType(SM0->M0_NOME))
EndIf
cString += '<enderEmit>'
cString += '<xLgr>'+IIF(!lEndFis,ConvType(FisGetEnd(SM0->M0_ENDCOB,SM0->M0_ESTCOB)[1]),ConvType(FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[1]))+'</xLgr>'

If !lEndFis
	If FisGetEnd(SM0->M0_ENDCOB,SM0->M0_ESTCOB)[2]<>0
		cString += '<nro>'+FisGetEnd(SM0->M0_ENDCOB,SM0->M0_ESTCOB)[3]+'</nro>'  
	Else
		cString += '<nro>'+"SN"+'</nro>' 
	EndIf
Else
	If FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[2]<>0
		cString += '<nro>'+FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[3]+'</nro>' 
	Else
		cString += '<nro>'+"SN"+'</nro>'
	EndIf
EndIf

cEndEmit :=  IIF(!lEndFis,Iif(!Empty(SM0->M0_COMPCOB),SM0->M0_COMPCOB,ConvType(FisGetEnd(SM0->M0_ENDCOB,SM0->M0_ESTCOB)[4]) ) ,;
						  Iif(!Empty(SM0->M0_COMPENT),SM0->M0_COMPENT,ConvType(FisGetEnd(SM0->M0_ENDENT,SM0->M0_ESTENT)[4]) ) )

cString += NfeTag('<xCpl>',cEndEmit)
cString += '<xBairro>'+IIF(!lEndFis,ConvType(SM0->M0_BAIRCOB),ConvType(SM0->M0_BAIRENT))+'</xBairro>'
cString += '<cMun>'+ConvType(SM0->M0_CODMUN)+'</cMun>'
cString += '<xMun>'+IIF(!lEndFis,ConvType(SM0->M0_CIDCOB),ConvType(SM0->M0_CIDENT))+'</xMun>'
cString += NfeTag('<CEP>',IIF(!lEndFis,ConvType(SM0->M0_CEPCOB),ConvType(SM0->M0_CEPENT)))
cString += '<UF>'+IIF(!lEndFis,ConvType(SM0->M0_ESTCOB),ConvType(SM0->M0_ESTENT))+'</UF>'

aTelDest := FisGetTel(SM0->M0_TEL)
cFoneDest := IIF(aTelDest[2] > 0,ConvType(aTelDest[2],3),"") // Código da Área
cFoneDest += IIF(aTelDest[3] > 0,ConvType(aTelDest[3],9),"") // Código do Telefone

cString += NfeTag('<fone>',cFoneDest)
//cString += NfeTag('<email>',)
cString += '</enderEmit>'
cString += '</emit>'				  

Return cString

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeCarrega
Tags InfMunCarrega

@author Natalia Sartori
@since 26/02/2014
@version P11

@param      
@Return	cString
/*/
//-----------------------------------------------------------------------
Static Function MDFeCarrega()
	Local cString := ""
	Local nI := 0
	Local aMunicipios := aClone(oGetDMun:aCols)
	Local cUfCode := ""
	
	For nI := 1 to len(aMunicipios)
	    If !aMunicipios[nI,len(aMunicipios[nI])]			//Linha nao deletada
			cUfCode := GetUfCode(aMunicipios[nI,2])
		
			cString += '<infMunCarrega>'
			cString += '<cMunCarrega>' + alltrim(cUfCode) + alltrim(aMunicipios[nI,1]) + '</cMunCarrega>'
			cString += '<xMunCarrega>' + alltrim(aMunicipios[nI,3]) + '</xMunCarrega>'
			cString += '</infMunCarrega>'
		EndIf
	Next nI
	
Return cString


//----------------------------------------------------------------------
/*/{Protheus.doc} MDFePercu
Tags InfMunPercurso

@author Natalia Sartori
@since 26/02/2014
@version P11

@param      
@Return	cString
/*/
//-----------------------------------------------------------------------
Static Function MDFePercu(aNota)
	Local cString := ""
	Local nI 	:= 0
	Local aUFs	:= aClone(oGetDPerc:aCols)
	
    For nI := 1 to len(aUFs)
   		If !aUFs[nI,len(aUFs[nI])] //Linha nao deletada
   	 		//Desconsidera as UFs ja informadas em UF Carregamento e UF Descarregamento. Orientacao do manual do contribuinte
	   		If alltrim(aUFs[nI,1]) != aNota[05] .and. alltrim(aUFs[nI,1]) != aNota[06] .and. !Empty(aUFs[nI,1])
		   		cString += "<infPercurso>"
			  	cString += "<UFPer>" + aUFs[nI,1] + "</UFPer>"
		   		cString += "</infPercurso>"
		   	EndIf
		EndIf
    Next nI
		
Return cString

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeModal

Montagem do elemento InfModal do XML

@author Natalia Sartori
@since 25/02/2014
@version P11

@param      
@Return	cString
/*/
//-----------------------------------------------------------------------
Static Function MDFeModal (cVeiculo,aNota)

Local aVeiSF2		:= {}
Local aVeiculo		:= {}
Local aMotorista	:= {}
Local aProp			:= {}
Local cString 		:= ""
Local ctpProp		:= ""
Local nCapcM3		:= 0
Local nX			:= 0
Local lPosterior	:= .F.

Default aNota		:= {}

lPosterior	:= Len(aNota) >= 10 .And. aNota[10] == "1"

cString += '<infModal versaoModal="'/*+cVersao*/+'">'
cString += '<rodo>'
cString += '<infANTT>'
cString += NfeTag('<RNTRC>',ConvType(SM0->M0_RNTRC))

/*Elemento CIOT não gerado*/
If !Empty(cVeiculo)

	dbSelectArea('TRB')
	TRB->(dbGoToP())
	While TRB->(!Eof())
		If !Empty(TRB->TRB_MARCA)
			If Len(aVeiSF2) == 0
				If TRB->TRB_VEICU1 == cVeiculo
					aadd(aVeiSF2,TRB->TRB_VEICU1)
				ElseIf TRB->TRB_VEICU2 == cVeiculo
					aadd(aVeiSF2,TRB->TRB_VEICU2)
				ElseIf TRB->TRB_VEICU3 == cVeiculo
					aadd(aVeiSF2,TRB->TRB_VEICU3)
				EndIf
			EndIf

			If !Empty(TRB->TRB_VEICU1) .And. TRB->TRB_VEICU1 <> cVeiculo .And. Len(aVeiSF2) < 4
				If (aScan(aVeiSF2,{|x| x == TRB->TRB_VEICU1 })) == 0
					aadd(aVeiSF2,TRB->TRB_VEICU1)
				EndIf
			EndIf
			If !Empty(TRB->TRB_VEICU2) .And. TRB->TRB_VEICU2 <> cVeiculo .And. Len(aVeiSF2) < 4
				If (aScan(aVeiSF2,{|x| x == TRB->TRB_VEICU2 })) == 0
					aadd(aVeiSF2,TRB->TRB_VEICU2)
				EndIf
			EndIf
			If !Empty(TRB->TRB_VEICU3) .And. TRB->TRB_VEICU3 <> cVeiculo .And. Len(aVeiSF2) < 4
				If (aScan(aVeiSF2,{|x| x == TRB->TRB_VEICU3 })) == 0
					aadd(aVeiSF2,TRB->TRB_VEICU3)
				EndIf
			EndIf

			If Len(aVeiSF2) >= 4
				Exit
			EndIf
		EndIf	
		
		TRB->(dbSkip())
	EndDo

	If Type("cPoster") == "C" .And. SubStr(cPoster,1,1) == "1" .and. Len(aVeiSF2) == 0 //"1-Sim" Vincula posterior
		aadd(aVeiSF2,cVeiculo)
	EndIf

	For nX := 1 To Len(aVeiSF2)
		If HasTemplate("DCLEST")	//ExistTemplate("OMSA200P")
			dbSelectArea("SA4")
			dbSetOrder(1)
			dbSelectArea("LBW")
			dbSetOrder(1)

			If MsSeek(xFilial("LBW")+PADR(aVeiSF2[nX],Len(LBW->LBW_PLACA)))
				aadd(aVeiculo,{})
				aadd( aVeiculo[Len(aVeiculo)] , Iif(LBW->(ColumnPos("LBW_PLACA")) > 0 ,LBW->LBW_PLACA,""))
				aadd( aVeiculo[Len(aVeiculo)] , Iif(LBW->(ColumnPos("LBW_PLACA")) > 0 ,LBW->LBW_PLACA,""))				
				aadd( aVeiculo[Len(aVeiculo)] , Iif(LBW->(ColumnPos("LBW_UF")) > 0 ,LBW->LBW_UF,""))					
				aadd( aVeiculo[Len(aVeiculo)] , Iif(LBW->(ColumnPos("LBW_TARA")) > 0 ,LBW->LBW_TARA,""))				
				aadd( aVeiculo[Len(aVeiculo)],"")
				aadd( aVeiculo[Len(aVeiculo)] , Iif(LBW->(ColumnPos("LBW_TRANSP")) > 0 ,LBW->LBW_TRANSP,""))
				aadd( aVeiculo[Len(aVeiculo)],"")
				aadd( aVeiculo[Len(aVeiculo)] , Iif(LBW->(ColumnPos("LBW_FROVEI")) > 0 ,LBW->LBW_FROVEI,""))	//Frota 1-Própria;2-Terceiro;3-Agregado
				aadd( aVeiculo[Len(aVeiculo)] , Iif(LBW->(ColumnPos("LBW_CAPTOT")) > 0 ,LBW->LBW_CAPTOT,""))	//Capacidade Máxima
				aadd( aVeiculo[Len(aVeiculo)] , Iif(LBW->(ColumnPos("LBW_ALTINT")) > 0 ,LBW->LBW_ALTINT,""))	//Altura Interna
				aadd( aVeiculo[Len(aVeiculo)] , Iif(LBW->(ColumnPos("LBW_LARINT")) > 0 ,LBW->LBW_LARINT,""))	//Largura Interna
				aadd( aVeiculo[Len(aVeiculo)] , Iif(LBW->(ColumnPos("LBW_COMINT")) > 0 ,LBW->LBW_COMINT,""))	//Comprimento Interno
				aadd( aVeiculo[Len(aVeiculo)] , Iif(LBW->(ColumnPos("LBW_TIPROD")) > 0 ,LBW->LBW_TIPROD,""))	//Tipo de Rodado
				aadd( aVeiculo[Len(aVeiculo)] , Iif(LBW->(ColumnPos("LBW_TIPCAR")) > 0 ,LBW->LBW_TIPCAR,""))	//Tipo de Carroceria
				aadd( aVeiculo[Len(aVeiculo)] , Iif(LBW->(ColumnPos("LBW_RENAVA")) > 0 ,LBW->LBW_RENAVA,""))	//Renavam
														 
				aadd(aProp,{})
				If !Empty(aVeiculo[Len(aVeiculo)][6])
					dbSelectArea("SA4")
					dbSetOrder(1)
					MsSeek(xFilial("SA4")+aVeiculo[Len(aVeiculo)][6])
					
					aadd(aProp[Len(aProp)],SA4->A4_COD)
					aadd(aProp[Len(aProp)],SA4->A4_CGC)
					aadd(aProp[Len(aProp)],SA4->A4_RNTRC)
					aadd(aProp[Len(aProp)],SA4->A4_NOME)
					aadd(aProp[Len(aProp)],SA4->A4_INSEST)
					aadd(aProp[Len(aProp)],SA4->A4_EST)	
				EndIf

				If nX == 1
					aadd(aMotorista,{})
					aadd(aMotorista[Len(aMotorista)],"")
					aadd(aMotorista[Len(aMotorista)],Iif(LBW->(ColumnPos("LBW_NOMMOT")) > 0 ,LBW->LBW_NOMMOT,""))
					aadd(aMotorista[Len(aMotorista)],Iif(LBW->(ColumnPos("LBW_CPFMOT")) > 0 ,LBW->LBW_CPFMOT,""))
				EndIf
			Else
				dbSelectArea("DA3")
				dbSetOrder(1)
				dbSelectArea("DUT")
				dbSetOrder(1)
				DA3->(MsSeek(xFilial("DA3")+aVeiSF2[nX]))
			
				aadd(aVeiculo,{})
				aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_COD)					
				aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_PLACA) 
				aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_ESTPLA)
				aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_TARA)
				aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_LOJFOR)
				aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_CODFOR)
				aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_MOTORI)
				aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_FROVEI) //Frota 1-Própria;2-Terceiro;3-Agregado
				aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_CAPACM) //Capacidade Máxima
				aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_ALTINT) //Altura Interna
				aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_LARINT) //Largura Interna
				aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_COMINT) //Comprimento Interno
				
				If DUT->( msSeek( xFilial( "DUT" ) + DA3->DA3_TIPVEI ) )
					aadd( aVeiculo[Len(aVeiculo)] , DUT->DUT_TIPROD ) 	//Tipo de Rodado
					aadd( aVeiculo[Len(aVeiculo)] , DUT->DUT_TIPCAR ) 	//Tipo de Carroceria
				Else
					aadd( aVeiculo[Len(aVeiculo)] , "" ) 	//Tipo de Rodado
					aadd( aVeiculo[Len(aVeiculo)] , "" ) 	//Tipo de Carroceria
				Endif
				aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_RENAVA) //Renavam
				
				aadd(aProp,{})
				If !Empty(aVeiculo[Len(aVeiculo)][5]) .and. !Empty(aVeiculo[Len(aVeiculo)][6])
					dbSelectArea("SA2")
					dbSetOrder(1)
					MsSeek(xFilial("SA2")+aVeiculo[Len(aVeiculo)][6]+aVeiculo[Len(aVeiculo)][5])
					
					aadd(aProp[Len(aProp)],SA2->A2_COD)
					aadd(aProp[Len(aProp)],SA2->A2_CGC)
					aadd(aProp[Len(aProp)],SA2->A2_RNTRC)
					aadd(aProp[Len(aProp)],SA2->A2_NOME)
					aadd(aProp[Len(aProp)],SA2->A2_INSCR)
					aadd(aProp[Len(aProp)],SA2->A2_EST)	
				EndIf
				
				If nX == 1
					aadd(aMotorista,{})
					If !Empty(aVeiculo[Len(aVeiculo)][7])
						dbSelectArea("DA4")
						dbSetOrder(1)
						MsSeek(xFilial("DA4")+aVeiculo[Len(aVeiculo)][7])
						
						aadd(aMotorista[Len(aMotorista)],DA4->DA4_COD)
						aadd(aMotorista[Len(aMotorista)],DA4->DA4_NOME)
						aadd(aMotorista[Len(aMotorista)],DA4->DA4_CGC)
					EndIf
				EndIf
			EndIf
		Else
			dbSelectArea("DA3")
			dbSetOrder(1)
			dbSelectArea("DUT")
			dbSetOrder(1)
			DA3->(MsSeek(xFilial("DA3")+aVeiSF2[nX]))

			aadd(aVeiculo,{})
			aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_COD)					
			aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_PLACA) 
			aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_ESTPLA)
			aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_TARA)
			aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_LOJFOR)
			aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_CODFOR)
			aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_MOTORI)
			aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_FROVEI) //Frota 1-Própria;2-Terceiro;3-Agregado
			aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_CAPACM) //Capacidade Máxima
			aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_ALTINT) //Altura Interna
			aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_LARINT) //Largura Interna
			aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_COMINT) //Comprimento Interno
			
			If DUT->( msSeek( xFilial( "DUT" ) + DA3->DA3_TIPVEI ) )
				aadd( aVeiculo[Len(aVeiculo)] , DUT->DUT_TIPROD ) 	//Tipo de Rodado
				aadd( aVeiculo[Len(aVeiculo)] , DUT->DUT_TIPCAR ) 	//Tipo de Carroceria
			Else
				aadd( aVeiculo[Len(aVeiculo)] , "" ) 	//Tipo de Rodado
				aadd( aVeiculo[Len(aVeiculo)] , "" ) 	//Tipo de Carroceria
			Endif
			//Retirada validação dos campos abaixo por já existirem em outro tabela
			//aadd(aVeiculo[Len(aVeiculo)],Iif(DA3->(FieldPos("DA3_TPROD")) > 0 ,DA3->DA3_TPROD,"")) 	//Tipo de Rodado
			//aadd(aVeiculo[Len(aVeiculo)],Iif(DA3->(FieldPos("DA3_TPCAR")) > 0, DA3->DA3_TPCAR,"")) 	//Tipo de Carroceria
			aadd(aVeiculo[Len(aVeiculo)],DA3->DA3_RENAVA) //Renavam
			
			aadd(aProp,{})
			If !Empty(aVeiculo[Len(aVeiculo)][5]) .and. !Empty(aVeiculo[Len(aVeiculo)][6])
				dbSelectArea("SA2")
				dbSetOrder(1)
				MsSeek(xFilial("SA2")+aVeiculo[Len(aVeiculo)][6]+aVeiculo[Len(aVeiculo)][5])
				
				aadd(aProp[Len(aProp)],SA2->A2_COD)
				aadd(aProp[Len(aProp)],SA2->A2_CGC)
				aadd(aProp[Len(aProp)],SA2->A2_RNTRC)
				aadd(aProp[Len(aProp)],SA2->A2_NOME)
				aadd(aProp[Len(aProp)],SA2->A2_INSCR)
				aadd(aProp[Len(aProp)],SA2->A2_EST)	
			EndIf
			
			If nX == 1
				aadd(aMotorista,{})
				If !Empty(aVeiculo[Len(aVeiculo)][7])
					dbSelectArea("DA4")
					dbSetOrder(1)
					MsSeek(xFilial("DA4")+aVeiculo[Len(aVeiculo)][7])
					
					aadd(aMotorista[Len(aMotorista)],DA4->DA4_COD)
					aadd(aMotorista[Len(aMotorista)],DA4->DA4_NOME)
					aadd(aMotorista[Len(aMotorista)],DA4->DA4_CGC)
				EndIf
			EndIf
		EndIf
	Next	
EndIf

cString += '</infANTT>'

For nX := 1 To Len(aVeiculo)
	If nX == 1
		cString += '<veicTracao>'
		cString += '<cInt>' + ConvType(aVeiculo[nX][1]) + '</cInt>'
		cString += '<placa>' + ConvType(aVeiculo[nX][2]) + '</placa>'
		cString += NfeTag('<RENAVAM>',ConvType((aVeiculo[nX][15]),11,0))
		cString += '<tara>' + ConvType((aVeiculo[nX][4]),6,0) + '</tara>'
		cString += NfeTag('<capKG>',ConvType((aVeiculo[nX][9]),6,0))

		//Converte Valor da capacidade KG para M3
		If !Empty(aVeiculo[nX][10]) .and. !Empty(aVeiculo[nX][11]) .and. !Empty(aVeiculo[nX][12])
			nCapcM3 := Round(aVeiculo[nX][10] * aVeiculo[nX][11] * aVeiculo[nX][12],0)
			cString += NfeTag('<capM3>',ConvType((nCapcM3),3,0))
		EndIf

		//TAG: Prop - Se o veiculo for de terceiros, preencher tags com informações do proprietário
		If !Empty(aVeiculo[nX][08]) .and. aVeiculo[nX][08] <> '1'
			If Len(aProp[nX]) > 0
				cString += '<prop>'

				If Len(Alltrim(aProp[nX][2])) > 11
					cString += '<CNPJ>' + Alltrim(aProp[nX][2]) + '</CNPJ>'
				Else
					cString += '<CPF>' + Alltrim(aProp[nX][2]) + '</CPF>'
				EndIf

				cString += '<RNTRC>' + StrZero(Val(AllTrim(aProp[nX][3])),8) + '</RNTRC>'	
				cString += '<xNome>' + ConvType(aProp[nX][4]) + '</xNome>'
				
				cString += '<IE>'+ ConvType(VldIE(aProp[nX][5],.F.)) + '</IE>'  
				cString += '<UF>'+ ConvType(aProp[nX][6]) + '</UF>'

				If aVeiculo[nX][08] == '3'  
					ctpProp := "0" //TAC Agregado
				ElseIf aVeiculo[nX][08] == '2'
					ctpProp	:= "1" //TAC Independente
				Else
					ctpProp	:= "2" //Outros
				EndIf

				cString += '<tpProp>' + ctpProp + '</tpProp>'

				cString += '</prop>'
			EndIf
		EndIf

		If Len(aMotorista[nX]) > 0
			cString += '<condutor>'
			cString +=   '<xNome>' + ConvType(aMotorista[nX][2]) +'</xNome>'
			cString +=   '<CPF>'   + AllTrim(aMotorista[nX][3]) +'</CPF>'
			cString += '</condutor>'
		EndIf
		cString +=   '<tpRod>' + alltrim(aVeiculo[nX][13]) + '</tpRod>'
		cString +=   '<tpCar>' + alltrim(aVeiculo[nX][14]) + '</tpCar>'
		cString +=   '<UF>' + ConvType(aVeiculo[nX][3]) + '</UF>'
		cString += '</veicTracao>'
	Else
		cString += '<veicReboque>'
		cString += '<cInt>' + ConvType(aVeiculo[nX][1]) + '</cInt>'
		cString += '<placa>' + ConvType(aVeiculo[nX][2]) + '</placa>'
		//Inclusão do renavam NT2014/003
		cString += NfeTag('<RENAVAM>',ConvType((aVeiculo[nX][15]),11,0))
		cString += '<tara>' + ConvType((aVeiculo[nX][4]),6,0) + '</tara>'
		cString += NfeTag('<capKG>',ConvType((aVeiculo[nX][9]),6,0))

		//Converte Valor da capacidade KG para M3
		If !Empty(aVeiculo[nX][10]) .and. !Empty(aVeiculo[nX][11]) .and. !Empty(aVeiculo[nX][12])
			nCapcM3 := Round(aVeiculo[nX][10] * aVeiculo[nX][11] * aVeiculo[nX][12],0)
			cString += NfeTag('<capM3>',ConvType((nCapcM3),3,0))
		EndIf

		//TAG: Prop - Se o veiculo for de terceiros, preencher tags com informações do proprietário
		If !Empty(aVeiculo[nX][08]) .and. aVeiculo[nX][08] <> '1'
			If Len(aProp[nX]) > 0
				cString += '<prop>'

				If Len(Alltrim(aProp[nX][2])) > 11
					cString += '<CNPJ>' + Alltrim(aProp[nX][2]) + '</CNPJ>'
				Else
					cString += '<CPF>' + Alltrim(aProp[nX][2]) + '</CPF>'
				EndIf

				cString += '<RNTRC>' + StrZero(Val(AllTrim(aProp[nX][3])),8) + '</RNTRC>'	
				cString += '<xNome>' + ConvType(aProp[nX][4]) + '</xNome>'
				
				cString += '<IE>'+ ConvType(VldIE(aProp[nX][5],.F.)) + '</IE>'  
				cString += '<UF>'+ ConvType(aProp[nX][6]) + '</UF>'

				If aVeiculo[nX][08] == '3'  
					ctpProp := "0" //TAC Agregado
				ElseIf aVeiculo[nX][08] == '2'
					ctpProp	:= "1" //TAC Independente
				Else
					ctpProp	:= "2" //Outros
				EndIf

				cString += '<tpProp>' + ctpProp + '</tpProp>'

				cString += '</prop>'
			EndIf
		EndIf

		cString +=   '<tpCar>' + alltrim(aVeiculo[nX][14]) + '</tpCar>'
		cString +=   '<UF>' + ConvType(aVeiculo[nX][3]) + '</UF>'
		cString += '</veicReboque>'
	EndIf
Next

cString += '</rodo>'
cString += '</infModal>'
	
Return cString

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeInfDoc
Montagem do elemento InfDoc do XML

@author Natalia Sartori
@since 26/02/2014
@version P11

@param      
@Return	cString
/*/
//-----------------------------------------------------------------------
Static Function MDFeInfDoc(aNota)
	Local cString	:= ""
	Local cCodMun	:= ""
	Local cUfCode 	:= ""
	Local cSerieNFe	:= ""
	Local cNumNFe	:= ""
	Local cXmlRet	:= ""
	Local cChvCTG	:= ""
	Local aXmlRet	:= {}

	Default aNota	:= {}

	Private oNFeRet
	
	dbSelectArea('TRB')
	TRBSetIndex(2)
	TRB->(dbGoToP())

	cString += '<infDoc>'	
	While TRB->(!Eof())
		cCodMun := TRB->TRB_CODMUN

		//Considera apenas documentos Marcados
		If !Empty(TRB->TRB_MARCA)
			cUfCode := GetUfCode(TRB->TRB_EST)
		
			cString += '<infMunDescarga>'
			cString += '<cMunDescarga>'+ alltrim(cUfCode) + alltrim(TRB->TRB_CODMUN) +'</cMunDescarga>'
			cString += '<xMunDescarga>'+ alltrim(TRB->TRB_NOMMUN) +'</xMunDescarga>'
	
			While TRB->(!Eof()) .and. cCodMun == TRB->TRB_CODMUN
				//Considera apenas documentos Marcados
				If !Empty(TRB->TRB_MARCA)
					cString += '<infNFe>'
					cString += '<chNFe>'+ TRB->TRB_CHVNFE +'</chNFe>'
					If substr(TRB->TRB_CHVNFE,35,1) $ '2-5' //Contingencia FS-IA/FS-DA
						cSerieNFe := substr(TRB->TRB_CHVNFE,23,3)
						cNumNFe := substr(TRB->TRB_CHVNFE,26,9)
						If FindFunction("RetXmlNFe")
							aXmlRet := RetXmlNFe(cSerieNFe,cNumNFe)
							
							If len(aXmlRet) > 0
								cXmlRet:= aXmlRet[1][1]
								cChvCTG:= RetCodBarra(cXmlRet)
								If !Empty(cChvCTG)
									cString += '<SegCodBarra>'+ cChvCTG +'</SegCodBarra>'
								Else
									cString += '<SegCodBarra>'+ SubStr(TRB->TRB_CHVNFE,1,36) +'</SegCodBarra>'
								EndIf
							Else
								cString += '<SegCodBarra>'+ SubStr(TRB->TRB_CHVNFE,1,36) +'</SegCodBarra>'
							Endif
						Else
							MsgInfo("Atualize o fonte SPEDMFE.prw para montagem da tag SegCodBarra")
						EndIf
					endif		
					cString += '</infNFe>'					
				EndIf
				TRB->(dbSkip())
			EndDo
			cString += '</infMunDescarga>'
		EndIf	
		
		If TRB->(!Eof()) .and. cCodMun == TRB->TRB_CODMUN
			TRB->(dbSkip())
		EndIf
	EndDo

	If Len(aNota) >= 10 .And. aNota[10] == "1"
		cUfCode := GetUfCode(aNota[9])
		cString += '<infMunDescarga>'
		cString += '<cMunDescarga>'+ alltrim(cUfCode) + alltrim(aNota[7]) +'</cMunDescarga>'   
		cString += '<xMunDescarga>'+ alltrim(aNota[8]) +'</xMunDescarga>'
		cString += '</infMunDescarga>'
	EndIF

	cString += '</infDoc>'
	
	TRBSetIndex(1)
Return cString

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeTotais
Tag Totais

@author Natalia Sartori
@since 26/02/2014
@version P11

@param      
@Return	cString
/*/
//-----------------------------------------------------------------------
Static Function MDFeTotais()
	Local cString := ""
	                   
	cString += "<tot>"
	cString += "<qNFe>" + ConvType(nQtNFe,0)   + "</qNFe>"
	cString += "<vCarga>" + ConvType(nVTotal,15,2) + "</vCarga>"
	cString += "<cUnid>01</cUnid>"
	cString += "<qCarga>" + ConvType(nPBruto,15,4) + "</qCarga>"
	cString += "</tot>"
	
Return cString 

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeLacres
Tag Lacres

@author Natalia Sartori
@since 26/02/2014
@version P11

@param      
@Return	cString
/*/
//-----------------------------------------------------------------------
Static Function MDFeLacres()
	Local cString := ""
	Local aLacres := aClone(oGetDLacre:aCols)
	Local nI := 1
	
	If Len (aLacres) > 0
		For nI := 1 to len(aLacres)		
			If !aLacres[nI,len(aLacres[nI])]	.and. !Empty(aLacres[nI,1]) 	//Linha nao deletada e nao vazio
				cString += "<lacres>"
				cString += "<nLacre>" + alltrim(aLacres[nI,1]) + "</nLacre>"
				cString += "</lacres>"
			EndIf
		Next nI
	EndIf
	
	
Return cString

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeAutoriz
Tag autXML

@author Natalia Sartori
@since 26/02/2014
@version P11

@param      
@Return	cString
/*/
//-----------------------------------------------------------------------
Static Function MDFeAutoriz()
	Local cString := ""
	Local aCNPJ := aClone(oGetDAut:aCols)
	Local nI := 1    

	If Len (aCNPJ) > 0
		For nI := 1 to len(aCNPJ)	

			If !aCNPJ[nI,len(aCNPJ[nI])] .and. !Empty(aCNPJ[nI,1]) //Linha nao deletada
				cString += "<autXML>"
				If Len(Alltrim(aCNPJ[nI,1])) > 11
					cString += "<CNPJ>"+ Alltrim(aCNPJ[nI,1])+"</CNPJ>"
				Else
					cString += "<CPF>"+ Alltrim(aCNPJ[nI,1])+ "</CPF>"
				EndIf			
				cString += "</autXML>"
			EndIf				
		Next nI
	EndIf	
	
Return cString

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeInfAdic
Tag autXML

@author Natalia Sartori
@since 26/02/2014
@version P11

@param      
@Return	cString
/*/
//-----------------------------------------------------------------------
Static Function MDFeInfAdic()
	Local cString := ""
	
	If !Empty(cInfFsc) .or. !Empty(cInfCpl)
		cString += "<infAdic>"
		If !Empty(cInfFsc)
			cString += NfeTag("<infAdFisco>",ConvType(cInfFsc,2000))
		EndIf
		If !Empty(cInfCpl)
			cString += NfeTag("<infCpl>",ConvType(cInfCpl,5000))
		EndIf		
		cString += "</infAdic>"
	EndIf
	
Return cString


//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeMDFeSupl
Tag MDFeSupl

@author Valter Da Silva
@since 17/07/2019
@version P12

@param      
@Return	cString
/*/
//-----------------------------------------------------------------------
Static Function MDFeInfMDFeSupl()
	Local cString := ""
	
	cString += '<infMDFeSupl>'
	cString += '<qrCodMDFe>'
	cString += 'https://dfe-portal.svrs.rs.gov.br/mdfe/QRCode?chMDFe='
	cString += '</qrCodMDFe>'
	cString += '</infMDFeSupl>'	
	
Return cString

//----------------------------------------------------------------------
/*/{Protheus.doc} GetUfCode
Retorna o nro do Estado de acordo com a sigla recebida como parametro

@author Natalia Sartori
@since 26/02/2014
@version P11

@param      
@Return	cString
/*/
//-----------------------------------------------------------------------
Static Function GetUfCode(cUf)
	Local nPos := 0	
	Local cNroUf := ""
	
	nPos := aScan(aUF,{|x| x[1] == Alltrim(cUf) })
	If nPos > 0
		cNroUf	:= aUf[nPos,2]
	EndIf
Return cNroUf

Static Function ConvType(xValor,nTam,nDec)

Local cNovo	:= ""
DEFAULT nDec	:= 0
Do Case
	Case ValType(xValor)=="N"
		If xValor <> 0
			cNovo := AllTrim(Str(xValor,nTam,nDec))	
		Else
			cNovo := "0"
		EndIf
	Case ValType(xValor)=="D"
		cNovo := FsDateConv(xValor,"YYYYMMDD")
		cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7)
	Case ValType(xValor)=="C"
		If nTam==Nil
			xValor := AllTrim(xValor)
		EndIf
		DEFAULT nTam := 60
		cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
EndCase

Return(cNovo)



Static Function NoAcento(cString)

Local cChar	:= ""
Local cVogal	:= "aeiouAEIOU"
Local cAgudo	:= "áéíóú"+"ÁÉÍÓÚ"
Local cCircu	:= "âêîôû"+"ÂÊÎÔÛ"
Local cTrema	:= "äëïöü"+"ÄËÏÖÜ"
Local cCrase	:= "àèìòù"+"ÀÈÌÒÙ" 
Local cTio		:= "ãõÃÕ"
Local cCecid	:= "çÇ"
Local cMaior	:= "&lt;"
Local cMenor	:= "&gt;"
Local cEcom		:= "&"

Local nX		:= 0 
Local nY		:= 0

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase+cEcom
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0          
			cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
		nY:= At(cChar,cEcom)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("eE",nY,1))
		EndIf
	Endif
Next

If cMaior$ cString 
	cString := strTran( cString, cMaior, "" ) 
EndIf
If cMenor$ cString 
	cString := strTran( cString, cMenor, "" )
EndIf

cString := StrTran( cString, CRLF, " " )

For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ '|' 
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX

Return cString


Static Function Inverte(uCpo, nDig)

Local cRet		:= ""

Default nDig	:= 8

cRet	:=	GCifra(Val(uCpo),nDig)

Return(cRet)


Static Function NfeTag(cTag,cConteudo)

Local cRetorno		:= ""

If (!Empty(AllTrim(cConteudo)) .And. IsAlpha(AllTrim(cConteudo))) .Or. Val(AllTrim(cConteudo))<>0
	cRetorno := cTag+AllTrim(cConteudo)+SubStr(cTag,1,1)+"/"+SubStr(cTag,2)
EndIf

Return(cRetorno)

Static Function VldIE(cInsc,lContr)

Local cRet	:=	""
Local nI	:=	1
DEFAULT lContr  :=      .T.
For nI:=1 To Len(cInsc)
	If Isdigit(Subs(cInsc,nI,1)) .Or. IsAlpha(Subs(cInsc,nI,1))
		cRet+=Subs(cInsc,nI,1)
	Endif
Next
cRet := AllTrim(cRet)
If "ISENT"$Upper(cRet)
	cRet := ""
EndIf
If lContr .And. Empty(cRet)
	cRet := "ISENTO"
EndIf
If !lContr
	cRet := ""
EndIf
Return(cRet)

//----------------------------------------------------------------------
/*/{Protheus.doc} MDFeChave 

Função responsável em montar a Chave de Acesso e calcular 
o seu digito verIficador

@Natalia Sartori
@since 25.02.2014
@version 1.00

@param      	cUF...: Codigo da UF
				cAAMM.: Ano (2 Digitos) + Mes da Emissao do MDFe
				cCNPJ.: CNPJ do Emitente do MDFe
				cMod..: Modelo (58 = MDFe)
				cSerie: Serie do MDFe
				nCT...: Numero do MDFe
				cDV...: Numero do Lote de Envio a SEFAZ
@Return	cString
/*/
//-----------------------------------------------------------------------
Static Function MDFeChave(cUF, cAAMM, cCNPJ, cMod, cSerie, nMDF, cDV)

Local nCount      := 0
Local nSequenc    := 2
Local nPonderacao := 0
Local cResult     := ''

Local cChvAcesso  := cUF +  cAAMM +  PADL(ALLTRIM(cCNPJ),14,"0") + cMod + cSerie + nMDF + cDV

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³SEQUENCIA DE MULTIPLICADORES (nSequenc), SEGUE A SEGUINTE        ³
//³ORDENACAO NA SEQUENCIA: 2,3,4,5,6,7,8,9,2,3,4... E PRECISA SER   ³
//³GERADO DA DIREITA PARA ESQUERDA, SEGUINDO OS CARACTERES          ³
//³EXISTENTES NA CHAVE DE ACESSO INFORMADA (cChvAcesso)             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCount := Len( AllTrim(cChvAcesso) ) To 1 Step -1
	nPonderacao += ( Val( SubStr( AllTrim(cChvAcesso), nCount, 1) ) * nSequenc )
	nSequenc += 1
	If (nSequenc == 10)
		nSequenc := 2
	EndIf
Next nCount

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando o resto da divisão for 0 (zero) ou 1 (um), o DV devera   ³
//³ ser igual a 0 (zero).                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( mod(nPonderacao,11) > 1)
	cResult := (cChvAcesso + cValToChar( (11 - mod(nPonderacao,11) ) ) )
Else
	cResult := (cChvAcesso + '0')
EndIf

Return(cResult)
//----------------------------------------------------------------------
/*/{Protheus.doc} PocDA3 

Função responsável em posicionar na tabela DA3 


@Natalia Sartori
@since 25.02.2014
@version 1.00

@param      	
@Return	cString
/*/
//-----------------------------------------------------------------------
Static Function PocDA3(cVeiculo)

Local lVeic := .F. 

dbSelectArea("DA3")
dbSetOrder(1)
DA3->(MsSeek(xFilial("DA3")+cVeiculo))

If DA3->DA3_FROVEI <> '1' .And. !Empty(DA3->DA3_CODFOR)// 1- Carga Própria 2- Terceiro 3- Agregado
	If posicione("SA2",1,xfilial("SA2")+DA3->DA3_CODFOR+DA3->DA3_LOJFOR,"A2_TIPO") <> "F"
		lVeic := .T.
	EndIf
EndIf

Return lVeic