#INCLUDE "TOTVS.CH"
#INCLUDE "TopConn.ch"  


/*/{Protheus.doc} FROPRE04
@description Relatorio de Analises e Projecoes - Novo Projeto Consolidacao
@author Fernando Rocha
@since 21/01/2019
@version undefined
@type function
/*/
User Function FROPRE04

	Local lEnd			:= .F.
	Local aPergs		:= {}
	Local cRefPer	  	:= 'FROPRE04' + cEmpAnt
	Local cFileName    	:= __cUserID +"_"+ cRefPer

	Private oExcel
	private cArqXML    	:= "REL_ANALISE_PROJECOES_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	private cTitulo		:= "Relatório de Análises e Projeções"

	private cEmpresa   	:= StrTran(AllTrim(CapitalAce(SM0->M0_NOMECOM)),"S.a.","S.A.") 

	private cFonte1	 	:= 'Calibri'
	private nTamFont1	:= 12   
	private cCorFont1  	:= '#FFFFFF'
	private cCorFun1	:= '#000066'

	private cFonte2	 	:= 'Calibri' 
	private nTamFont2	:= 12   
	private cCorFont2  	:= '#FFFFFF'
	private cCorFun2	:= '#3333FF'

	private cFonte3	 	:= 'Calibri'
	private nTamFont3	:= 8   
	private cCorFont3  	:= '#000000'
	private cCorFun3	:= '#FFFFFF'

	private cWhite		:= '#FFFFFF'
	private cLGray		:= '#9494E7'

	private aColsAnt	:= {}
	private aColsProx	:= {}

	//Privates para ParamBox
	private aRetPerg   := {"","",ctod(" "),0,0,0,"","","","","","","","",.F.,""}
	
	Private cEmpresas	:= Space(20)
	Private cAlmox		:= Space(20)
	Private dEntrAte	:= STOD('')
	Private nMesesAnt	:= 7
	Private nMesesProx	:= 2
	Private nMesesMed	:= 5
	private	aStatus	    := {"Todos", "Ativos", "Descontinuado", "Obsoleto", "Descont/Obsoleto"}
	Private nStatus		:= 1
	Private cMarcaDe	:= Space(11)//Space(4)
	Private cMarcaAte	:= Space(11)//Space(4)
	Private cFormatoDe	:= Space(2)
	Private cFormatoAte	:= Space(2)
	Private cFornoDe	:= Space(3)
	Private cFornoAte	:= Space(3)
	Private cClasseDe	:= Space(1)
	Private cClasseAte	:= Space(1)
	Private lSomaCAnt	:= .F.
	Private cDirDest	:= Space(200)
	Private aFornoP		:= {Space(3), 'F01','F02','F03','F04','F05','IMP','INA', 'ZZZ'}                                      
	Private aMarca		:= {Space(11), 'Biancogres','Incesa','Bellacasa','Mundi', 'Pegasus', 'Vinilico', 'ZZZZZZZZZZZ'}
	Private aCodMarca	:= {Space(4), '0101','0501','0599','1399', '0199','1302','ZZZZ'}                                      
	
		
	aAdd( aPergs ,{1,"Empresas:"				, cEmpresas  ,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Almoxarifados:"			, cAlmox  	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"DT Entrega até: " 		, dEntrAte  ,"","",'','.T.',50,.F.})
	aAdd( aPergs ,{1,"No.Meses Anteriores"		, nMesesAnt  ,"99",,"",'.T.',20,.F.})
	aAdd( aPergs ,{1,"No.Meses Próximos"		, nMesesProx  ,"99",,"",'.T.',20,.F.})
	aAdd( aPergs ,{1,"No.Meses p/Média"			, nMesesMed  ,"99",,"",'.T.',20,.F.})
	aAdd( aPergs ,{2,"Status: "					, aStatus[1], aStatus,100,".T.",.T.})
	
	aAdd( aPergs ,{2,"Marca de:"					, cMarcaDe, aMarca, 100, ".T.",.F.})
	aAdd( aPergs ,{2,"Marca Ate:"					, cMarcaAte, aMarca, 100, ".T.",.F.})
	
	//aAdd( aPergs ,{1,"Marca de:"	   			, cMarcaDe  ,"",,"",'.T.',50,.F.})
	//aAdd( aPergs ,{1,"Marca Ate: "     			, cMarcaAte ,"",,"",'.T.',50,.F.})
	
	aAdd( aPergs ,{1,"Formato de:"	   			, cFormatoDe  ,"",,"ZZ6",'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Formato Ate: "     		, cFormatoAte ,"",,"ZZ6",'.T.',50,.F.})
	
	aAdd( aPergs ,{2,"Forno de:"					, cFornoDe, aFornoP, 100, ".T.",.F.})
	aAdd( aPergs ,{2,"Forno de:"					, cFornoAte, aFornoP, 100, ".T.",.F.})
	
	//aAdd( aPergs ,{2,"Forno de:"	   			, cFornoDe  ,"",, "",'.T.',50,.F.})	
	//aAdd( aPergs ,{2,"Forno Ate: "     			, cFornoAte ,"",, "",'.T.',50,.F.})
	
	aAdd( aPergs ,{1,"Classe de:"	   			, cClasseDe  ,"", ,"ZZ8",'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Classe Ate: "     		, cClasseAte ,"", ,"ZZ8",'.T.',50,.F.})	
	
	aAdd( aPergs ,{2,"Somar Cod.Anterior?: "	, 1, {"Não","Sim"},100,".T.",.T.})
	aAdd( aPergs ,{6,"Pasta Destino: " 	,cDirDest  ,"","","", 75 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE} )

	//If !ParamBox(aPergs ,cTitulo,,,,,,,,cRefPer,.T.,.T.)
	If !ParamBox(aPergs ,"Análise e Projeções",aRetPerg,,,,,,,cRefPer,.T.,.T.)
		Return
	EndIf

	cEmpresas			:= ParamLoad(cFileName,,1 	, cEmpresas)
	cAlmox   			:= ParamLoad(cFileName,,2 	, cAlmox)
	dEntrAte   			:= ParamLoad(cFileName,,3	, dEntrAte)
	nMesesAnt			:= ParamLoad(cFileName,,4	, nMesesAnt)
	nMesesProx			:= ParamLoad(cFileName,,5	, nMesesProx)
	nMesesMed			:= ParamLoad(cFileName,,6	, nMesesMed)
	nStatus		   		:= aScan(aStatus, {|x| AllTrim(x) == AllTrim(ParamLoad(cFileName,,7 , Space(30))) })
	cMarcaDe  			:= aCodMarca[aScan(aMarca, {|x| AllTrim(x) == AllTrim(ParamLoad(cFileName,,8 , Space(30))) })]//aRetPerg[8]
	cMarcaAte  			:= aCodMarca[aScan(aMarca, {|x| AllTrim(x) == AllTrim(ParamLoad(cFileName,,9 , Space(30))) })]//aRetPerg[9]
	cFormatoDe  		:= aRetPerg[10]
	cFormatoAte  		:= aRetPerg[11]
	cFornoDe  			:= aRetPerg[12]
	cFornoAte  			:= aRetPerg[13]
	cClasseDe  			:= aRetPerg[14]
	cClasseAte  		:= aRetPerg[15]
	lSomaCAnt  			:= AllTrim("Sim") == AllTrim(ParamLoad(cFileName,,16 , Space(3)))
	cDirDest			:= AllTrim(aRetPerg[17])


	oProcess := MsNewProcess():New( {|lEnd| fImprime(@lEnd)},"Por favor aguarde, processando...","Carregando Informações",.T.)
	oProcess:Activate()

Return


Static Function fImprime(lEnd)

	oExcel := ARSexcel():New()

	if empty(cDirDest) .or. !ExistDir(cDirDest)	
		cDirDest := Alltrim(GetTempPath()) 
	endif

	MontaCabecalho()
	MontaLinhas()
	MontaAbaPar()

	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.)

Return


Static Function MontaCabecalho()

	Local aMeses := {"Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"}
	Local nX
	
	Local aColLen := {100,100,200,50,20,100,100}
	Local cDescTi := ""
	
	For nX := 1 To nMesesAnt
		aAdd(aColLen, 50)
	Next nx
	
	aAdd(aColLen, 50)
	aAdd(aColLen, 50)
	aAdd(aColLen, 50)
	
	For nX := 1 To nMesesProx
		aAdd(aColLen, 50)
	Next nx
	
	aAdd(aColLen, 50)
	aAdd(aColLen, 50)
	aAdd(aColLen, 50)
	aAdd(aColLen, 50)
	aAdd(aColLen, 50)

	oExcel:AddPlanilha('Analise_Projecoes',aColLen)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,1,Len(aColLen)-1) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,1,Len(aColLen)-1) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula(cTitulo,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,1,Len(aColLen)-1)  

	oExcel:AddLinha(30)
	oExcel:AddLinha(12) 

	//Forno	Cod. Form.	Desc.Formato	Marca	Status	Cod. Produto	Desc.Produto	jun/18	jul/18	ago/18	set/18	out/18	nov/18	dez/18	jan/19	Média 5 meses	Estoque Atual	Cart. Ped. Até Jan/19	Cart. Ped. Em Fev/19	Cart. Ped. A Partir Mar/19	Reserva	Saldo Dispon.	Cobertura (Mês)	Saldo OP	Cod. Anterior

	oExcel:AddCelula("Forno"				,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Cod.Formato"			,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Desc.Formato"			,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Marca" 			 	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Status"			   	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Cod.Produto"   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Desc.Produto"	   	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 


	For nX := 1 To nMesesAnt	

		_nMes := Month(dDataBase) - (nMesesAnt - (nX - 1))
		_nAno := Year(dDataBase)

		If (_nMes < 1)
			_nMes := _nMes + 12
			_nAno = _nAno - 1
		EndIf

		_cMes := aMeses[_nMes]+"/"+StrZero(_nAno,4)
		_cCol := "M"+StrZero(_nAno,4)+StrZero(_nMes,2)

		aAdd(aColsAnt, _cCol)

		oExcel:AddCelula(_cMes,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)	

	Next nX

	oExcel:AddCelula("Mês Atual"	    	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Média Meses Ant."	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Estoque Atual" 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)

	oExcel:AddCelula("Carteira Até "+ aMeses[Month(dDataBase)]+"/"+StrZero(Year(dDataBase),4) 	    ,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)


	For nX := 1 To nMesesProx	

		_nMes := Month(dDataBase) + nX
		_nAno := Year(dDataBase)

		If (_nMes > 12)
			_nMes := _nMes - 12
			_nAno = _nAno + 1
		EndIf

		_cMes := aMeses[_nMes]+"/"+StrZero(_nAno,4)
		_cCol := "M"+StrZero(_nAno,4)+StrZero(_nMes,2)

		aAdd(aColsProx, _cCol)
		
		cDescTi := " "
		If (nX == nMesesProx)
			cDescTi := "Cart. Ped. a partir de "
		EndIf
		
		oExcel:AddCelula(cDescTi+_cMes,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)	

	Next nX

	oExcel:AddCelula("Reserva" 	    	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Saldo Dispo." 	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cobertura(Mês)" 	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Saldo OP" 		,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Código Anterior"	,0,'C',cFonte2,nTamFont2,cCorFont2,.T.,.T.,cCorFun2  ,.T.,.T.,.T.,.T.)

Return


Static Function MontaLinhas()

	Local cAliasTmp
	Local aMeses := {"Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"}
	Local cCorF := cWhite
	Local cSPName
	Local _cSQL
	Local nX

	
	cSPName := "SP_REL_ANALISE_PROJECOES"

	cAliasTmp := GetNextAlias()

	_cSQL := "EXEC "+cSpName+" '"+cEmpresas+"', '"+cAlmox+"' , '"+DTOS(dEntrAte)+"', "+AllTrim(Str(nMesesAnt))+", "+AllTrim(Str(nMesesProx))+", "+AllTrim(Str(nMesesMed))+", "+AllTrim(Str(nStatus))+", '"+cMarcaDe+"', '"+cMarcaAte+"', '"+cFormatoDe+"', '"+cFormatoAte+"', '"+cFornoDe+"', '"+cFornoAte+"', '"+cClasseDe+"', '"+cClasseAte+"', "+IIF(lSomaCAnt,AllTrim(Str(1)),AllTrim(Str(0)))+""

	TCQuery _cSQL Alias (cAliasTmp) New

	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof())

		oExcel:AddLinha(12)
		
		oExcel:AddCelula((cAliasTmp)->FORNO										,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.) 
		oExcel:AddCelula((cAliasTmp)->FORMATO									,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->DESCR_FORMATO								,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->DESC_MARCA								,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->DESC_STATUS								,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->COD										,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->DESCR										,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		
		
		For nX := 1 To Len(aColsAnt)
		
			oExcel:AddCelula(&(""+cAliasTmp+"->"+aColsAnt[nX])	,2,'R',cFonte3,nTamFont3,cCorFont3,,,cCorF,.T.,.T.,.T.,.T.)
			
		Next nX
		
		oExcel:AddCelula((cAliasTmp)->VENDAS_ATU		,2,'R',cFonte3,nTamFont3,cCorFont3,,,cCorF,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->MEDIA_ANT			,2,'R',cFonte3,nTamFont3,cCorFont3,,,cCorF,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->ESTOQUE_ATUAL		,2,'R',cFonte3,nTamFont3,cCorFont3,,,cCorF,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->CARTEIRA_ATU			,2,'R',cFonte3,nTamFont3,cCorFont3,,,cCorF,.T.,.T.,.T.,.T.)
				

		For nX := 1 To Len(aColsProx)
		
			oExcel:AddCelula(&(""+cAliasTmp+"->"+aColsProx[nX])	,2,'R',cFonte3,nTamFont3,cCorFont3,,,cCorF,.T.,.T.,.T.,.T.)
			
		Next nX
		
		oExcel:AddCelula((cAliasTmp)->RESERVA			,2,'R',cFonte3,nTamFont3,cCorFont3,,,cCorF,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->SALDO_DISP		,2,'R',cFonte3,nTamFont3,cCorFont3,,,cCorF,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->COBERTURA			,2,'R',cFonte3,nTamFont3,cCorFont3,,,cCorF,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->SALDO_OP			,2,'R',cFonte3,nTamFont3,cCorFont3,,,cCorF,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((cAliasTmp)->COD_ANT			,0,'L',cFonte3,nTamFont3,cCorFont3,.T.,.T.,cCorF  ,.T.,.T.,.T.,.T.)
		

		(cAliasTmp)->(DbSkip())
	EndDo
	(cAliasTmp)->(DbCloseArea())

Return

Static Function MontaAbaPar()

	oExcel:AddPlanilha('Parametros',{100})
	oExcel:AddLinha(12)
	
	oExcel:AddCelula("Empresas: "+cEmpresas)
	oExcel:AddLinha(12)		
	oExcel:AddCelula("Almoxarifados: "+cAlmox)
	oExcel:AddLinha(12)	
	oExcel:AddCelula("DT Entrega até: "+DTOC(dEntrAte))
	oExcel:AddLinha(12)   		
	oExcel:AddCelula("No.Meses Anteriores: "+Str(nMesesAnt))
	oExcel:AddLinha(12)		
	oExcel:AddCelula("No.Meses Próximos: "+Str(nMesesProx))
	oExcel:AddLinha(12)		
	oExcel:AddCelula("No.Meses p/Média: "+Str(nMesesMed))
	oExcel:AddLinha(12)	
	oExcel:AddCelula("Status: "+Str(nStatus))
	oExcel:AddLinha(12)	
	oExcel:AddCelula("Marca de: "+cMarcaDe)
	oExcel:AddLinha(12) 		
	oExcel:AddCelula("Marca Ate: "+cMarcaAte)
	oExcel:AddLinha(12) 		
	oExcel:AddCelula("Formato de: "+cFormatoDe)
	oExcel:AddLinha(12) 	
	oExcel:AddCelula("Formato Ate: "+cFormatoAte)
	oExcel:AddLinha(12) 	
	oExcel:AddCelula("Forno de: "+cFornoDe)
	oExcel:AddLinha(12) 		
	oExcel:AddCelula("Forno Ate: "+cFornoAte)
	oExcel:AddLinha(12) 		
	oExcel:AddCelula("Classe de: "+cClasseDe)
	oExcel:AddLinha(12) 		
	oExcel:AddCelula("Classe Ate: "+cClasseAte)
	oExcel:AddLinha(12) 	
	oExcel:AddCelula("Somar Cod.Anterior?: "+IIF(lSomaCAnt,"Sim","Não"))
	oExcel:AddLinha(12) 		
	oExcel:AddCelula("Pasta Destino: "+cDirDest)
	oExcel:AddLinha(12)	

Return