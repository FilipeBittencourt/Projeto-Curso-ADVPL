#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"



/*/{Protheus.doc} BIAFG009
@author Gabriel Rossi Mafioletti
@since 19/06/2017
@version 1.0
@description Relatório Excel de Produção de Caco
@type function
/*/


User Function BIAFG009()



	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	private aPergs := {}
	Private oExcel      := nil 
	private cDirDest    := space(170)

	If !ValidPerg()
		Return
	EndIf

	fQryDados()

return


Static Function ValidPerg()

	local cLoad	    := "BIAFG009" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local _nPeso	:=	0

	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	MV_PAR03 := space(100)

	aAdd( aPergs ,{1,"Data de? " 	   		,MV_PAR01 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Data Até?" 	   		,MV_PAR02 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino?"  		,MV_PAR03 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório de Caco Diário",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)

		cDirDest	:=	MV_PAR03

		if empty(MV_PAR03) 
			MV_PAR03 := AllTrim(GetTempPath()) 	
		endif

	EndIf

Return lRet


Static Function fQryDados()

	Local _cAlias	:=	GetNextAlias()
	Local nTotReg	:=	0
	Local _cDataDe	:=	DtoS(MV_PAR01)
	Local _cDataAte	:=	DtoS(MV_PAR02)
	local nRegAtu   := 0
	Local _cBaia	:=	""

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

	local cArqXML   := "BIAFG009_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))

	BeginSql Alias _cAlias
	SELECT  Z94_BAIA ,
	Z94_DTREF ,
	Z94_FORMAT ,
	Z94_FORNO ,
	Z94_ESCOLH ,
	Z94_EQUIPE,
	Z94_TURNO,
	Z94_CACO ,
	Z94_PRODUC ,
	Z94_CACOAJ ,
	Z94_META ,
	Z94_PRCACO
	FROM    %TABLE:Z94%
	WHERE   Z94_FILIAL = %XFILIAL:Z94%
	AND Z94_DTREF BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
	AND %NotDel%
	ORDER BY Z94_DTREF,
	Z94_BAIA 

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

	oExcel:AddPlanilha("Relatorio",{20,37,33,39,51,38,38,38,45,35,69,56,60,48,35,48,35},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,12) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,12) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório de Caco - Realizado ",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,12)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("Dia"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Baia"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Formato"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Descrição"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Forno"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)			
	oExcel:AddCelula("Escolha"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Equipe"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Turno"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Caco"			 		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Procução"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Peso Formato"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Produção TON"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Caco Ajust."			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Meta"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Meta Prod."			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("% Caco"		 		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	While (_cAlias)->(!EOF())

		nRegAtu++

		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14) 
		oExcel:AddCelula()

		oExcel:AddCelula( DtoC(Stod((_cAlias)->Z94_DTREF))											,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( "Baia " + Right(Alltrim((_cAlias)->Z94_BAIA),2)							,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z94_FORMAT														,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( POSICIONE("ZZ6",1,xFilial("ZZ6")+ (_cAlias)->Z94_FORMAT,"ZZ6_DESC")		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z94_FORNO														,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z94_ESCOLH														,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z94_EQUIPE														,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z94_TURNO														,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z94_CACO														,TamSx3("Z94_CACO")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z94_PRODUC														,TamSx3("Z94_PRODUC")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		_nPeso	:=	fCalcPes((_cAlias)->Z94_FORMAT, (_cAlias)->Z94_TURNO, (_cAlias)->Z94_EQUIPE,(_cAlias)->Z94_DTREF)	
		oExcel:AddCelula( _nPeso																	,TamSx3("ZZ6_PESO")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z94_PRODUC * _nPeso/ 1000										,TamSx3("Z94_PRODUC")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z94_CACOAJ														,TamSx3("Z94_CACOAJ")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z94_META														,TamSx3("Z94_META")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z94_META * (_cAlias)->Z94_PRODUC * _nPeso/ 1000				,TamSx3("Z94_META")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z94_PRCACO														,TamSx3("Z94_PRCACO")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)

		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		(_cAlias)->(DbSkip())

	EndDo
	fGeraParametros()
	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 

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

	aPergs[1,3] := DtoC(MV_PAR01) 
	aPergs[2,3] := DtoC(MV_PAR02)  
	aPergs[3,3] := cDirDest     


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


Static Function fCalcPes(cFormat, cTurno, cEquipe, cData)

	Local _nPeso		:=	0
	Local _cAliasPes	:=	GetNextALias()
	Local _cData		:= cData	
	Local _aArea		:=	GetArea()
	BeginSql Alias _cAliasPes

	SELECT  
	CASE
	WHEN SB1.B1_YFORMAT NOT IN ( 'B9', 'BO', 'C6' ) THEN ( CASE 
	WHEN ISNULL(SUM(Z75_QUANT),0) > 0 THEN ISNULL(SUM(Z75_QUANT * B1_PESO), 0)/ ISNULL(SUM(Z75_QUANT),0) 
	ELSE 0
	END)
	WHEN SB1.B1_YFORMAT IN ( 'B9', 'BO', 'C6' ) THEN ( CASE 
	WHEN ISNULL(SUM(Z75_BKQTD),0) > 0 THEN ISNULL(SUM(Z75_BKQTD * B1_PESO), 0)/ ISNULL(SUM(Z75_BKQTD),0) 
	ELSE 0
	END)
	ELSE 0 
	END PESO
	FROM    %TABLE:Z75% Z75
	INNER JOIN %TABLE:SB1% SB1 ON B1_COD = Z75_PRODUT
	AND B1_YFORMAT = %Exp:cFormat%
	AND SB1.D_E_L_E_T_ = ' '
	WHERE   Z75_FILIAL = %XFILIAL:Z75%
	AND Z75_DATARF = %Exp:_cData%
	AND Z75_TPMOV IN ('ETQ','RET')
	AND ( ( B1_YFORMAT IN('BM', 'BF', 'BD', 'BE') AND Z75_TPPROD = 'PP') OR ( B1_YFORMAT NOT IN('BM', 'BF', 'BD', 'BE') AND Z75_TPPROD <> 'PP') )
	AND ( ( SB1.B1_YFORMAT IN ( 'B9', 'BO', 'C6' )
	AND Z75.Z75_EQUIPE = '1'
	AND Z75.Z75_BKEQUI = %Exp:cEquipe%
	)
	OR ( SB1.B1_YFORMAT NOT IN ( 'B9', 'BO', 'C6' )
	AND Z75.Z75_EQUIPE = %Exp:cEquipe%
	)
	)
	AND Z75.%NotDel%
	GROUP BY SB1.B1_YFORMAT

	EndSql

	_nPeso	:=	(_cAliasPes)->PESO

	(_cAliasPes)->(DbCloseArea())

	RestArea(_aArea)

Return _nPeso
