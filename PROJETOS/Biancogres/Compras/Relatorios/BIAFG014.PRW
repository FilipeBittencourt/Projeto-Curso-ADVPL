#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"



/*/{Protheus.doc} BIAFG014
@author Gabriel Rossi Mafioletti
@since 19/06/2017
@version 1.0
@description Relatório Excel de Entrada de Notas Unificadas
@type function
/*/


User Function BIAFG014()

	Local _aEmps	:=	{}
	Local _nI	:=	1
	Local _cEmps	:=	""

	Private aPergs	:=	{}
	
	If !Validperg()
		Return
	EndIf

	_cEmps	:=	Alltrim(MV_PAR01)
	
	For _nI	:=	1 to Len(_cEmps) STEP 2
		If Substr(_cEmps,_nI,2) <> '**'
			aAdd(_aEmps,Substr(_cEmps,_nI,2))
		EndIf
	Next

	If Len(_aEmps) > 0

		fQryDados(_aEmps)

	EndIf
Return



Static Function fQryDados(_aEmps)

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
	
	local cArqXML   := "BIAFG014_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))

	Local _nI
	local nRegAtu   := 0	

	Local _cFilBkp	:=	cFilAnt
	Local _cEmpBkp	:=	cEmpAnt
	Local nTotReg	:=	200
	Local _cTabSD1	:=	""	
	Local _cTabSF1	:=	""	

	
	PRIVATE _cEmps		:=	MV_PAR01
	PRIVATE _cDataDe	:=	DtoS(MV_PAR02)
	PRIVATE _cDataAte	:=	DtoS(MV_PAR03)
	PRIVATE _cDirDest		:=	MV_PAR04
	
	
	ProcRegua(nTotReg + 2)
	
	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

	oExcel := ARSexcel():New()
	
	oExcel:AddPlanilha("Relatorio",{20,38,49,49,37,43,205,44,727,60,46,27,24,48,24,205},6)
			
	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,14) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,14) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório Notas Unificadas ",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,14)  
	    
	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("Empresa"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Documento"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Espécie"			 		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Emissão"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Digitação"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Usuário"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Produto"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)			
	oExcel:AddCelula("Descrição"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Quant."				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Total"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("CFOP"			 		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Tipo"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Fornecedor"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Loja"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	
	For _nI	:= 1 to Len(_aEmps)
	
		_cAlias	:=	GetNextAlias()
		_cTabSD1	:= "%"+ "SD1" + _aEmps[_nI] + "0" + "%"
		_cTabSF1	:= "%"+ "SF1" + _aEmps[_nI] + "0" + "%"
		
		BeginSql Alias _cAlias	
			%NoParser%
			SELECT  %Exp:_aEmps[_nI] % EMPR ,
			        D1_DOC ,
			        F1_ESPECIE,
			        D1_EMISSAO ,
			        D1_DTDIGIT ,
			        CASE WHEN SF1.F1_YUSRLAN = '' THEN dbo.USERLG(SF1.F1_USERLGI) ELSE SF1.F1_YUSRLAN END CDUSER,
			        D1_COD ,
			        RTRIM(B1_DESC) DESCR ,
			        D1_QUANT ,
			        D1_TOTAL ,
			        D1_CF ,
			        D1_TIPO ,
			        D1_FORNECE ,
			        D1_LOJA ,
			        A2_NOME
			FROM    %Exp:_cTabSD1% SD1
			        LEFT JOIN SA2010 SA2 ON A2_FILIAL = %XFILIAL:SA2%
			                                AND A2_COD = D1_FORNECE
			                                AND A2_LOJA = D1_LOJA
			                                AND SA2.%NotDel%
			        LEFT JOIN SB1010 SB1 ON B1_FILIAL = %XFILIAL:SB1%
			                                AND B1_COD = D1_COD
			                                AND SB1.%NotDel%
			        JOIN %Exp:_cTabSF1% SF1 ON SD1.D1_FILIAL = SF1.F1_FILIAL
			        							AND SD1.D1_DOC = SF1.F1_DOC
			        							AND SD1.D1_SERIE = SF1.F1_SERIE
			        							AND SD1.D1_FORNECE = SF1.F1_FORNECE
			        							AND SD1.D1_LOJA = SF1.F1_LOJA
			        							AND SF1.%NotDel%
			        
			WHERE   D1_FILIAL BETWEEN '  ' AND 'ZZ'
			        AND D1_DTDIGIT BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
			        AND D1_TIPO NOT IN ( 'D', 'B' )
			        AND SD1.%NotDel%
		EndSql
		
		If (_cAlias)->(!EOF())

			While (_cAlias)->(!EOF())
			
				nRegAtu++
				
				if MOD(nRegAtu,2) > 0 
			        cCorFun2 := '#DCE6F1'
				else
					cCorFun2 := '#B8CCE4'
				endif
			
				oExcel:AddLinha(14) 
				oExcel:AddCelula()
		
				oExcel:AddCelula( (_cAlias)->EMPR											,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
				oExcel:AddCelula( (_cAlias)->D1_DOC							,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
				oExcel:AddCelula( (_cAlias)->F1_ESPECIE					,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
				oExcel:AddCelula( DToC(StoD((_cAlias)->D1_EMISSAO))							,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
				oExcel:AddCelula( DToC(StoD((_cAlias)->D1_DTDIGIT))														,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
				oExcel:AddCelula( IF(!Empty((_cAlias)->CDUSER),UsrFullName((_cAlias)->CDUSER),"")														,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
				oExcel:AddCelula( (_cAlias)->D1_COD		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
				oExcel:AddCelula( (_cAlias)->DESCR														,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
				oExcel:AddCelula( (_cAlias)->D1_QUANT																	,TamSx3("D1_QUANT")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)			
				oExcel:AddCelula( (_cAlias)->D1_TOTAL																	,TamSx3("D1_TOTAL")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)			
				oExcel:AddCelula( (_cAlias)->D1_CF														,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
				oExcel:AddCelula( (_cAlias)->D1_TIPO														,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
				oExcel:AddCelula( (_cAlias)->D1_FORNECE														,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
				oExcel:AddCelula( (_cAlias)->D1_LOJA														,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
				oExcel:AddCelula( (_cAlias)->A2_NOME														,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)			
					
				(_cAlias)->(DbSkip())
			
			EndDo
		EndIf
		(_cAlias)->(DbCloseArea())
		
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")
		
	Next

	fGeraParametros()
	oExcel:SaveXml(Alltrim(_cDirDest),cArqXML,.T.) 
	
	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")
	
Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG014" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local _nPeso	:=	0
	
	
	
	MV_PAR01 :=	Space(100)
	MV_PAR02 := STOD('')
	MV_PAR03 := STOD('')
	MV_PAR04 := space(100)
	
	aAdd( aPergs ,{1,"Empresa(s)? " 	  	,MV_PAR01 ,""  ,"U_BIAFG14E()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Data de? " 	   		,MV_PAR02 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Data Até?" 	   		,MV_PAR03 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino?"  		,MV_PAR04 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório de Entrada de Notas Unificadas",,,,,,,,cLoad,.T.,.T.)
	
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)

		if empty(MV_PAR04) 
			MV_PAR04 := AllTrim(GetTempPath()) 	
		endif
	
	EndIf
	
Return lRet


User Function BIAFG14E()

	Local _aArea	:=	GetArea()
	Local _aEmps	:=	{}
	Local MvPar
	Local MvParDef	:=	""
	Local lRet		:= .F.
	Local _nTamKey	:= 0
	Local _nElemen	:= 0
	
	DbSelectArea("SM0")
	SM0->(DbSetOrder(1))
	SM0->(DbGoTop())

	MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

	While SM0->(!EOF())
		If AllTrim(SM0->M0_CODIGO) <> '02' .And. aScan(_aEmps,{|x| x == Alltrim(SM0->M0_CODIGO) + ' - ' + Alltrim(SM0->M0_NOME)}) == 0
			aAdd(_aEmps,Alltrim(SM0->M0_CODIGO) + ' - ' + Alltrim(SM0->M0_NOME))
			MvParDef	+=	Alltrim(SM0->M0_CODIGO)
			_nElemen++
		EndIf
		SM0->(DbSkip())
	EndDo

	_nTamKey	:=	Len(MVPARDEF)
	

	If f_Opcoes(@MvPar,"Seleção de Empresas",_aEmps,MvParDef,,,.F.,2,_nElemen)
		lRet	:= .T.
		&MvRet := mvpar 	
	EndIf
	RestArea(_aArea)
Return lRet

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
	
	
	aPergs[1,3] := _cEmps
	aPergs[2,3] := DtoC(StoD(_cDataDe)) 
	aPergs[3,3] := DtoC(StoD(_cDataAte))  
	aPergs[4,3] := _cDirDest     
	         
	
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
