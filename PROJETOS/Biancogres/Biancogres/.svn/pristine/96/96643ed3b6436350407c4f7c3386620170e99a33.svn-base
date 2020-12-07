#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"



/*/{Protheus.doc} BIAFG065
@author Gabriel Rossi Mafioletti
@since 24/09/2018
@version 1.0
@description Relatório Excel de Funcionários
@type function
/*/


User Function BIAFG065()

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

	local cLoad	    := "BIAFG065" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	
	MV_PAR01 := SPACE(6)
	MV_PAR02 := SPACE(6)
	MV_PAR03 := space(100)

	aAdd( aPergs ,{1,"Matrícula de? " 	   		,MV_PAR01 ,""  ,"",'SRA'  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Matrícula Até?" 	   		,MV_PAR02 ,""  ,"NAOVAZIO()",'SRA'  ,'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino?"  		,MV_PAR03 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório de Funcionários",,,,,,,,cLoad,.T.,.T.)

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
	local nRegAtu   := 0
	Local _aNome	:=	{}
	Local _cNome1
	Local _cNome2
	Local _cNome3
	Local _nI

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

	local cArqXML   := "BIAFG065_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))

	BeginSql Alias _cAlias

		SELECT RA_MAT 
			,RA_CIC
			,CASE 
				WHEN RA_SITFOLH = 'A'
					THEN 'Afastado'
				WHEN RA_SITFOLH = 'F'
					THEN 'Férias'
				WHEN RA_SITFOLH = ''
					THEN 'Normal'
				ELSE 'Outra'
				END SITFOLH
			,RA_NOME
			,'' CLOGIN
			,RA_EMAIL
			,RA_TELEFON
			,RA_NUMCELU
			,RA_ENDEREC
			,RA_MUNICIP
			,RA_ESTADO
			,RA_CEP
			,X5PAIS.X5_DESCRI NACIONA
			,'Funcionário' STTS
			,'Funcionário' STTSFUN
			,RJ_DESC CARGO
			,RA_CODFUNC CDCARGO
			,RA_CODFUNC CDPOSIC
			,CASE 
				WHEN RA_SEXO = 'F'
					THEN 'Feminino'
				WHEN RA_SEXO = 'M'
					THEN 'Masculino'
				ELSE 'N/A'
				END SEXO
			,CASE 
				WHEN RA_RACACOR = '1'
					THEN 'Indígena'
				WHEN RA_RACACOR = '2'
					THEN 'Branca'
				WHEN RA_RACACOR = '4'
					THEN 'Negra'
				WHEN RA_RACACOR = '6'
					THEN 'Amarela'
				WHEN RA_RACACOR = '8'
					THEN 'Parda'
				ELSE 'Não Informada'
				END RACA
			,X5ECIV.X5_DESCRI ECIV
			,QB_DESCRIC AS DEPTO
			,'Mensalmente' FREQPGT
			,'' NIVSAL
			,RA_SALARIO
			,RA_ADMISSA
			,RA_ADMISSA
			,RA_YSEMAIL
		FROM %TABLE:SRA% SRA
		LEFT JOIN %TABLE:SX5% X5PAIS ON X5PAIS.X5_TABELA = '34'
			AND SRA.RA_NACIONA = X5PAIS.X5_CHAVE
			AND X5PAIS.%NotDel%
		LEFT JOIN %TABLE:SRJ% SRJ ON SRJ.RJ_FUNCAO = SRA.RA_CODFUNC
			AND SRJ.%NotDel%
		LEFT JOIN %TABLE:SX5% X5ECIV ON X5ECIV.X5_TABELA = '33'
			AND SRA.RA_ESTCIVI = X5ECIV.X5_CHAVE
			AND X5ECIV.%NotDel%
		LEFT JOIN %TABLE:SQB% SQB ON SQB.QB_DEPTO = SRA.RA_DEPTO
			AND SQB.%NotDel%
		WHERE SRA.RA_FILIAL = %XFILIAL:SRA%
			AND SRA.%NotDel%
			AND SRA.RA_SITFOLH <> 'D'
			AND SRA.RA_MAT BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
			AND SRA.RA_PROCES = '00001'
		ORDER BY RA_NOME



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

	oExcel:AddPlanilha("Relatorio",{21,35,58,35,60,96,64,32,210,80,47,160,110,30,40,55,45,56,165,50,45,40,35,55,160,60,60,40,50,40,150,55},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,30) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,30) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório de Funcionários ",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,30)  

	oExcel:AddLinha(20)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("Matrícula"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CPF"								,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Situação"							,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome"								,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome do Meio"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Sobrenome"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Usuário"							,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("E-Mail"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Num. Telef."						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Num. Celul."						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Endereço"							,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cidade"					 		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Estado"				 		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CEP"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nacionalidade"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Status"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Status do Func."				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cargo"		 				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cod. Posição"		 				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cod. Cargo"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Sexo"		 				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Raça"		 						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Estado Civil"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Departamento"			 					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Freq. de Pagto."		 					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nível de Salário"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Salário"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dt. Contrat."		 					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dt. Inicial"		 					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("E-Mail Superv."		 					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Admissão"		 					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	While (_cAlias)->(!EOF())

		nRegAtu++

		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		_aNome	:=	StrToKArr(Alltrim((_cAlias)->RA_NOME)," ")
		
		Do Case
			Case Len(_aNome) == 1
				_cNome1	:=	_aNome[1]
				_cNome2	:=	""
				_cNome3	:=	""
			Case Len(_aNome) == 2
				_cNome1	:=	_aNome[1]
				_cNome2	:=	""
				_cNome3	:= _aNome[2]
			Case Len(_aNome) >= 3
				_cNome1	:=	""
				_cNome2	:=	""
				_cNome3	:=	""
				For _nI	:= 1 to Len(_aNome)
					If _nI	== 1
						_cNome1	:=	_aNome[_nI]
					ElseIf  _nI == Len(_aNome)
						_cNome3	:= _aNome[_nI]
					Else
						_cNome2	+=	_aNome[_nI] + Iif(_nI == (Len(_aNome) -1),'',' ')
					EndIf
				Next
		End Case

		oExcel:AddLinha(14) 
		oExcel:AddCelula()

		oExcel:AddCelula((_cAlias)->RA_MAT					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->RA_CIC					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->SITFOLH					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(_cNome1							,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(_cNome2							,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(_cNome3							,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CLOGIN					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->RA_EMAIL				,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->RA_TELEFON				,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->RA_NUMCELU				,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->RA_ENDEREC				,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->RA_MUNICIP				,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->RA_ESTADO				,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->RA_CEP					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->NACIONA					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->STTS					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->STTSFUN					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CARGO					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CDPOSIC					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CDCARGO					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->SEXO					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->RACA					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->ECIV					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->DEPTO					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->FREQPGT					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->NIVSAL					,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->RA_SALARIO				,2		 						,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->RA_ADMISSA				,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->RA_ADMISSA				,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->RA_YSEMAIL				,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(Stod((_cAlias)->RA_ADMISSA)				,0		 						,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)

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

	aPergs[1,3] := MV_PAR01
	aPergs[2,3] := MV_PAR02  
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