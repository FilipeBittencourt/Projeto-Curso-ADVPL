#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"



/*/{Protheus.doc} BIAFG008
@author Gabriel Rossi Mafioletti
@since 12/06/2017
@version 1.0
@description Relatório Excel de Consumo de Gás
@type function
/*/


User Function BIAFG008()



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

	local cLoad	    := "BIAFG008" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	
	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	MV_PAR03 := space(100)
	
	aAdd( aPergs ,{1,"Data de? " 	   		,MV_PAR01 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Data Até?" 	   		,MV_PAR02 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino?"  		,MV_PAR03 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório de Consumo de Gás",,,,,,,,cLoad,.T.,.T.)
	
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)

		cDirDest	:=	MV_PAR03
	
		if empty(MV_PAR05) 
			MV_PAR05 := AllTrim(GetTempPath()) 	
		endif
	
	EndIf
	
Return lRet


Static Function fQryDados()

	Local _cAlias	:=	GetNextAlias()
	Local nTotReg	:=	0
	Local _cDataDe	:=	DtoS(MV_PAR01)
	Local _cDataAte	:=	DtoS(MV_PAR02)
	local nRegAtu   := 0
	Local _cRecur	:=	""
	
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
	
	local cArqXML   := "BIAFG008_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	
	BeginSql Alias _cAlias
		SELECT Z91_RECURS ,
					Z91_RECDES,
		            Z91_DATA ,
		            Z91_FORMAT ,
		            Z91_FORDES ,
		            A.Z91_MEDIDO,
					A.Z91_MEDDES,
					SUM(Z91_QTOINI) AS Z91_QTOINI ,
		            SUM(Z91_QTOFIM) AS Z91_QTOFIM ,
		            SUM(Z91_PORDM2) AS Z91_PORDM2 ,
		            AVG(Z91_PRESTR) AS Z91_PRESTR ,
		            AVG(Z91_TEMPTR) AS Z91_TEMPTR ,
		            SUM(Z91_VAZM3) AS Z91_VAZM3 ,
		            Z91_FATCOR ,
		            SUM(Z91_VAZNM3) AS Z91_VAZNM3 ,
		            Z91_META FROM (
		    SELECT  Z91_RECURS ,
					Z91_RECDES,
		            Z91_DATA ,
		            Z91_FORMAT ,
		            Z91_FORDES ,
		            CASE WHEN Z91_RECURS = 'EST001' THEN Z91_MEDIDO ELSE '' END AS Z91_MEDIDO ,
		            CASE WHEN Z91_RECURS = 'EST001' THEN Z91_MEDDES ELSE '' END AS Z91_MEDDES ,
		            Z91_QTOINI AS Z91_QTOINI ,
		            Z91_QTOFIM AS Z91_QTOFIM ,
		            Z91_PORDM2 AS Z91_PORDM2 ,
		            Z91_PRESTR AS Z91_PRESTR ,
		            Z91_TEMPTR AS Z91_TEMPTR ,
		            Z91_VAZM3 AS Z91_VAZM3 ,
		            Z91_FATCOR ,
		            Z91_VAZNM3 AS Z91_VAZNM3 ,
		            Z91_META
		    FROM    %TABLE:Z91%
		    WHERE   %NotDel%
		            AND Z91_FILIAL = %XFILIAL:Z91%
		            AND Z91_DATA BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
					) A
					GROUP BY Z91_RECURS, Z91_RECDES, Z91_DATA, Z91_FORMAT,A.Z91_FORDES,  Z91_MEDIDO, Z91_MEDDES, A.Z91_FATCOR, A.Z91_META
					ORDER BY Z91_RECURS,Z91_DATA
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
	
	While (_cAlias)->(!EOF())
	
		nRegAtu++
		If Alltrim(_cRecur) <> Alltrim((_cAlias)->Z91_RECURS)
			_cRecur	:=	(_cAlias)->Z91_RECURS
			oExcel:AddPlanilha(_cRecur,{20,37,39,42,39,105,47,47,45,60,45,48,30,85,48,78,63,55},6)
			
			oExcel:AddLinha(20)
			oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,16) 
			oExcel:AddLinha(15)
			oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,16) 
			oExcel:AddLinha(15)
			oExcel:AddLinha(20)
			oExcel:AddCelula("Recurso " + (_cAlias)->(Z91_RECDES),0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,16)  
			    
			oExcel:AddLinha(20)
			oExcel:AddLinha(12) 
			oExcel:AddCelula()
			oExcel:AddCelula("Dia"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Formato"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Descrição"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Medidor"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)			
			oExcel:AddCelula("Descrição"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Quant. Ini"	 		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Quant. Fim"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Prod. (m2)"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Pressão (mbar)"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Temp. (oC)"	 		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Vazão (m3)"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("PCS"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Vazão (Nm3)"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Meta"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Consumo (Nm3/m2)"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Dentro da Meta"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Fora da Meta"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			
		EndIf
		
		if MOD(nRegAtu,2) > 0 
	        cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif
	
		oExcel:AddLinha(14) 
		oExcel:AddCelula()

		oExcel:AddCelula( DtoC(Stod((_cAlias)->Z91_DATA))		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z91_FORMAT					,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z91_FORDES					,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z91_MEDIDO					,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z91_MEDDES					,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z91_QTOINI					,TamSx3("Z91_QTOINI")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z91_QTOFIM					,TamSx3("Z91_QTOFIM")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z91_PORDM2					,TamSx3("Z91_PORDM2")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z91_PRESTR					,TamSx3("Z91_PRESTR")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z91_TEMPTR					,TamSx3("Z91_TEMPTR")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z91_VAZM3					,TamSx3("Z91_VAZM3")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z91_FATCOR					,TamSx3("Z91_FATCOR")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z91_VAZNM3					,TamSx3("Z91_VAZNM3")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->Z91_META					,TamSx3("Z91_META")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		nConsumo	:=	Iif((_cAlias)->Z91_PORDM2 <> 0,(_cAlias)->(Z91_VAZNM3 / Z91_PORDM2),0)
		oExcel:AddCelula( nConsumo								,TamSx3("Z91_META")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)		
		oExcel:AddCelula( Iif(nConsumo <= (_cAlias)->Z91_META,nConsumo,0)		,TamSx3("Z91_META")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)		
		oExcel:AddCelula( Iif(nConsumo > (_cAlias)->Z91_META,nConsumo,0)		,TamSx3("Z91_META")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	
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
