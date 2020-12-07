#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG071
@author Gabriel Rossi Mafioletti
@since 09/10/2018
@version 1.0
@description Relatório Excel de Inconsistências de Fechamento
@type function
/*/


User Function BIAFG071()

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

	local cLoad	    := "BIAFG071" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.

	MV_PAR01 := StoD('')
	MV_PAR02 := StoD('')
	MV_PAR03 := space(100)
	MV_PAR04 := "1"	

	aAdd( aPergs ,{1,"Data de?      ",MV_PAR01 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Data Até?     ",MV_PAR02 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino?",MV_PAR03 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )
	aAdd( aPergs ,{2,"Momento?      ",MV_PAR04 ,{"1=Antes Fechamento","2=Após Fechamento"},100,"NAOVAZIO()",.T.})

	If ParamBox(aPergs ,"Relatório de  Inconsistências de Fechamento",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)

		if empty(MV_PAR03) 
			MV_PAR03 := AllTrim(GetTempPath()) 	
		endif

		cDirDest	:=	MV_PAR03

	EndIf

Return lRet

Static Function fQryDados()

	Local _cAlias	:=	GetNextAlias()
	Local nTotReg	:=	0
	local nRegAtu   := 0

	Local _cDataDe	:=	DtoS(MV_PAR01)
	Local _cDataAte	:=	DtoS(MV_PAR02)

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


	local cEmpresa  := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML   := "BIAFG071_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))

	if MV_PAR04 = '2'

		BeginSql Alias _cAlias

			SELECT B9_DATA DT
			,B9_LOCAL LC
			,B9_COD COD
			,B1_TIPO TP
			,B1_UM  UM
			,RTRIM(B1_DESC) DESCRIC
			,B9_QINI QT
			,B9_VINI1 VL
			,CASE 
			WHEN B9_QINI = 0
			AND B9_VINI1 = 0
			THEN 'CORRETO: QUANT igual a 0 CUSTO igual a 0'
			WHEN B9_QINI > 0
			AND B9_VINI1 > 0
			THEN '==> QUANT maior que 0 CUSTO maior que 0'
			WHEN B9_QINI < 0
			AND B9_VINI1 < 0
			THEN 'QUANT menor que 0 CUSTO menor que 0'
			WHEN B9_QINI > 0
			AND B9_VINI1 <= 0
			THEN 'QUANT maior que 0 CUSTO menor que ou igual a 0'
			WHEN B9_QINI < 0
			AND B9_VINI1 >= 0
			THEN 'QUANT menor que 0 CUSTO maior que ou igual a 0'
			WHEN B9_QINI = 0
			AND B9_VINI1 <> 0
			THEN 'QUANT igual a 0 CUSTO diferente de 0'
			WHEN B9_QINI <> 0
			AND B9_VINI1 = 0
			THEN 'QUANT diferente de 0 CUSTO igual a 0'
			ELSE 'Estudar situação'
		END SITUACAO
		FROM %TABLE:SB9% SB9
		INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %Exp:xFilial("SB1")%
		AND B1_COD = B9_COD
		AND SB1.%NotDel%
		WHERE B9_FILIAL = %Exp:xFilial("SB9")%
		AND B9_DATA BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
		AND NOT (
		B9_QINI = 0
		AND B9_VINI1 = 0
		)
		AND NOT (
		B9_QINI > 0
		AND B9_VINI1 > 0
		)
		AND SB9.%NotDel%
		ORDER BY B9_DATA
		,B9_COD
		,B9_LOCAL

	EndSql

	else 

		if MV_PAR04 = '1'

			BeginSql Alias _cAlias

				SELECT %Exp:_cDataAte% DT
				,B2_LOCAL LC
				,B2_COD COD
				,B1_TIPO TP
				,B1_UM UM
				,RTRIM(B1_DESC) DESCRIC
				,B2_QFIM QT
				,B2_VFIM1 VL
				,CASE 
				WHEN B2_QFIM = 0
				AND B2_VFIM1 = 0
				THEN 'CORRETO: QUANT igual a 0 CUSTO igual a 0'
				WHEN B2_QFIM > 0
				AND B2_VFIM1 > 0
				THEN '==> QUANT maior que 0 CUSTO maior que 0'
				WHEN B2_QFIM < 0
				AND B2_VFIM1 < 0
				THEN 'QUANT menor que 0 CUSTO menor que 0'
				WHEN B2_QFIM > 0
				AND B2_VFIM1 <= 0
				THEN 'QUANT maior que 0 CUSTO menor que ou igual a 0'
				WHEN B2_QFIM < 0
				AND B2_VFIM1 >= 0
				THEN 'QUANT menor que 0 CUSTO maior que ou igual a 0'
				WHEN B2_QFIM = 0
				AND B2_VFIM1 <> 0
				THEN 'QUANT igual a 0 CUSTO diferente de 0'
				WHEN B2_QFIM <> 0
				AND B2_VFIM1 = 0
				THEN 'QUANT diferente de 0 CUSTO igual a 0'
				ELSE 'Estudar situação'
			END SITUACAO
			FROM %TABLE:SB2% SB2
			INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %Exp:xFilial("SB1")%
			AND B1_COD = B2_COD
			AND SB1.%NotDel%
			WHERE B2_FILIAL = %Exp:xFilial("SB2")%
			AND NOT (
			B2_QFIM = 0
			AND B2_VFIM1 = 0
			)
			AND NOT (
			B2_QFIM > 0
			AND B2_VFIM1 > 0
			)
			AND SB2.%NotDel%
			ORDER BY B2_USAI
			,B2_COD
			,B2_LOCAL

		EndSql

	endif

	endif 

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

	oExcel:AddPlanilha("Relatorio",{21,35,15,45,21,20,500,60,65,200},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,8) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,8) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório de Inconsistências de Fechamento ",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,8)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("Data"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("LC"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Código"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Tipo"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("UM"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Descrição"	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Quantidade"	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Situação"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	While (_cAlias)->(!EOF())

		nRegAtu++

		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14) 
		oExcel:AddCelula()

		oExcel:AddCelula(DtoC(Stod((_cAlias)->DT))	,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->LC				,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->COD				,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->TP				,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->UM				,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->DESCRIC			,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->QT				,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->VL				,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->SITUACAO		,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)		

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

	aPergs[1,3] := DtoC(MV_PAR01)
	aPergs[2,3] := dToc(MV_PAR02)  
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
