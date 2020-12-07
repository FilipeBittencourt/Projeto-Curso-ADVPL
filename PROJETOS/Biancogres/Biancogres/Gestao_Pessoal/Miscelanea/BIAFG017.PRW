#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG017
@author Gabriel Rossi Mafioletti
@since 14/08/2017
@version 1.0
@description Relatório de Entrega de Crachás
@type function
/*/

User Function BIAFG017()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	private aPergs := {}
	Private oExcel      := nil 

	If !ValidPerg()
		Return
	EndIf

	fQryDados()

return

Static Function ValidPerg()

	local cLoad	    := "BIAFG017" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local _nPeso	:=	0

	MV_PAR01 := SPACE(TAMSX3("ZC0_NUMERO")[1])
	MV_PAR02 := SPACE(TAMSX3("ZC0_NUMERO")[1])
	MV_PAR03 := STOD('')
	MV_PAR04 := STOD('')
	MV_PAR05 := space(100)

	aAdd( aPergs ,{1,"Crachá De? " 	   		,MV_PAR01 ,""  ,"",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Crachá Até?" 	   		,MV_PAR02 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Data de? " 	   		,MV_PAR03 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Data Até?" 	   		,MV_PAR04 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino?"  		,MV_PAR05 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório de Entrega de Crachás",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)

		if empty(MV_PAR05) 
			MV_PAR05 := AllTrim(GetTempPath()) 	
		endif

	EndIf

Return lRet

Static Function fQryDados()

	Local _cAlias	:=	GetNextAlias()
	Local nTotReg	:=	0
	Local _cDataDe	:=	DtoS(MV_PAR03)
	Local _cDataAte	:=	DtoS(MV_PAR04)
	local nRegAtu   := 0

	local cCab1Fon	:= 'Calibri' 
	local cCab1TamF	:= 8   
	local cCab1CorF := '#FFFFFF'
	local cCab1Fun	:= '#4F81BD'

	local cFonte1	 := 'Arial'
	local nTamFont1	 := 12   
	local cCorFont1  := '#FFFFFF'
	local cCorFun1	 := '#4F81BD'

	local cFonte2	 := 'Arial'
	local nTamFont2	 := 8   
	local cCorFont2  := '#000000'
	local cCorFun2	 := '#B8CCE4'
	Local nConsumo	 :=	0

	local cEmpresa  := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML   := "BIAFG017_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))

	BeginSql Alias _cAlias
	SELECT  ZC0.ZC0_NUMERO ,
	ZC0.ZC0_EMPR ,
	ZC0.ZC0_MAT ,
	ZC0.ZC0_SOLICI ,
	ZC0.ZC0_CLVL ,
	CTH.CTH_DESC01 ,
	ZC0.ZC0_BENEFI ,
	ZC0.ZC0_DATREC ,
	ZC0.ZC0_DATDEV
	FROM    %TABLE:ZC0% ZC0
	JOIN %TABLE:CTH% CTH ON ZC0_CLVL = CTH.CTH_CLVL
	AND CTH.%NotDel%
	AND ZC0.%NotDel%
	AND ZC0.ZC0_DATREC BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
	AND ZC0.ZC0_NUMERO BETWEEN %Exp:MV_PAR01% AND %EXP:MV_PAR02%
	ORDER BY ZC0.ZC0_DATREC ,
	ZC0.ZC0_NUMERO

	EndSql

	(_cAlias)->(DbGoTop())
	Count To nTotReg 
	if nTotReg < 1
		MsgStop('Não existem registros para essa consulta, favor verificar os parâmetros!')
		return
	endif
	(_cAlias)->(dbGoTop())
	ProcRegua(nTotReg + 2)

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Relatorio",{33,60,40,50,160,240,170,75,75},7)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,7) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,7) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório de Entrega de Crachás ",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,7)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("Crachá"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Empresa"		     		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Matrícula"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Solicitante"		    	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Classe de Valor"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)			
	oExcel:AddCelula("Beneficiário"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Data de Retirada"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Data de Devolução"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	

	While (_cAlias)->(!EOF())

		nRegAtu++

		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14) 
		oExcel:AddCelula()

		oExcel:AddCelula( (_cAlias)->ZC0_NUMERO														,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZC0_EMPR														,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZC0_MAT														,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZC0_SOLICI														,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( Alltrim((_cAlias)->ZC0_CLVL) + '-' + Alltrim((_cAlias)->CTH_DESC01) 		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZC0_BENEFI														,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( Dtoc(Stod((_cAlias)->ZC0_DATREC))											,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( Dtoc(Stod((_cAlias)->ZC0_DATDEV))											,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)

		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		(_cAlias)->(DbSkip())

	EndDo

	fGeraParametros()
	oExcel:SaveXml(Alltrim(MV_PAR05),cArqXML,.T.) 

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")

	(_cAlias)->(dbCloseArea())

Return

//Gera parametros
Static Function fGeraParametros()

	local nCont		 := 0 
	local cCorFundo  := ""
	local cTitulo	 := 'Parametros'

	local cFonte1    := 'Calibri' 
	local nTamFont1  := 9
	local cCorFont1  := '#FFFFFF'
	local cCorFund1  := '#4F81BD'

	local cFonte2    := 'Arial' 
	local nTamFont2  := 9
	local cCorFont2  := '#000000'

	local cCorFundo  := ''

	aPergs[1,3] := MV_PAR01 
	aPergs[2,3] := MV_PAR02  
	aPergs[3,3] := DtoC(MV_PAR03) 
	aPergs[4,3] := DtoC(MV_PAR04)
	aPergs[5,3] := MV_PAR05     

	oExcel:AddPlanilha('Parametros',{30,80,120,270})
	oExcel:AddLinha(18)
	oExcel:AddCelula(cTitulo,0,'C','Arial',12,'#FFFFFF',,,'#4F81BD',,,,,.T.,2,2) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula( "Sequencia" ,0,'C',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( "Pergunta"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( "Conteudo"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 

	for nCont := 1 to Len(aPergs)	

		if MOD(nCont,2) > 0 
			cCorFundo := '#DCE6F1'	
		else
			cCorFundo := '#B8CCE4'	
		endif	  

		oExcel:AddLinha(16) 
		oExcel:AddCelula()
		oExcel:AddCelula( strzero(nCont,2) ,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
		oExcel:AddCelula( aPergs[nCont,2]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
		oExcel:AddCelula( aPergs[nCont,3]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.) // Conteudo 

	next aPergs

Return 
