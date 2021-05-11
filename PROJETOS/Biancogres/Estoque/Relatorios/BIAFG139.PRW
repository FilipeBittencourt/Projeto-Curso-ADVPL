#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG139
@author Gabriel Rossi Mafioletti
@since 08/04/2020
@version 1.0
@description Saldo MD
@type function
/*/

User Function BIAFG139()

	RptDetail()

Return

Static Function RptDetail()

	private aPergs := {}
	Private oExcel      := nil 
	private cDirDest    := space(170)

	If !ValidPerg()
		Return
	EndIf

	Processa({|| fQryDados()})

return

Static Function ValidPerg()

	local cLoad	    := "BIAFG139" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.

	MV_PAR01 :=	SPACE(TAMSX3("B1_COD")[1])
	MV_PAR02 :=	SPACE(TAMSX3("B1_COD")[1])
	MV_PAR03 := SPACE(TAMSX3("B1_GRUPO")[1])
	MV_PAR04 := SPACE(TAMSX3("B1_GRUPO")[1])
	MV_PAR05 := Stod("")
	MV_PAR06 := Stod("")
	MV_PAR07 := space(100)

	aAdd( aPergs ,{1,"Produto De" 	   			,MV_PAR01 ,""  ,"",'SB1'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Produto Até" 	   			,MV_PAR02 ,""  ,"NAOVAZIO()",'SB1'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Grupo De" 	   			,MV_PAR03 ,""  ,"",'SBM'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Grupo Até" 	   		,MV_PAR04 ,""  ,"NAOVAZIO()",'SBM'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Dt. Ult. Com. De" 	   		,MV_PAR05 ,""  ,"",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Dt. Ult. Com. Até" 	   		,MV_PAR06 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{6,"Pasta Destino"  				,MV_PAR07 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório de Saldo MD",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03) 
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)
		MV_PAR06 := ParamLoad(cFileName,,6,MV_PAR06)
		MV_PAR07 := ParamLoad(cFileName,,7,MV_PAR07)


		if empty(MV_PAR07) 
			MV_PAR07 := AllTrim(GetTempPath()) 	
		endif

		cDirDest	:=	MV_PAR07

	EndIf

Return lRet

Static Function fQryDados()

	Local _cAlias	:=	GetNextAlias()
	Local nTotReg	:=	0
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

	local cEmpresa  := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML   := "BIAFG139_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))

	Local _nCusMEd	:=	0

	Local _cDataDe	:=	DtoS(MV_PAR05)
	
	Local _cDataAte	:=	DtoS(MV_PAR06)
	
	Local _dDtDiff

	BeginSql Alias _cAlias
		%NoParser%
		SELECT * 
		FROM (
		SELECT *
				,ISNULL((SELECT TOP 1 ZCZ_DTDIGI
							FROM %TABLE:ZCZ% ZCZDIG
							WHERE ZCZDIG.ZCZ_FILIAL = %xFilial:ZCZ%
								AND ZCZDIG.ZCZ_DOCSEQ = SALDO.ZCZ_DOCSEQ
								AND ZCZDIG.ZCZ_TM = '001'
								AND ZCZDIG.%NotDel%),'') DTDIG
		FROM (
		SELECT ZCZ_SOLICI
			,ZZY_NOME
			,ZCZ_COD
			,SB1.B1_TIPO
			,SB1.B1_GRUPO
			,SB1.B1_DESC
			,SB1.B1_UM
			,ZCZ_LOCAL
			,SUM(CASE 
					WHEN ZCZ_TM <= '500'
						THEN ZCZ_QUANT
					ELSE ZCZ_QUANT * - 1
					END) SALDO
			,ZCZ_DOCSEQ
		FROM %TABLE:ZCZ% ZCZ (NOLOCK)
		JOIN %TABLE:SB1% SB1 (NOLOCK) ON ZCZ.ZCZ_COD = SB1.B1_COD
			AND SB1.%NotDel%
		JOIN %TABLE:ZZY% ZZY (NOLOCK) ON ZCZ.ZCZ_SOLICI = ZZY.ZZY_MATRIC
			AND ZZY.%NotDel%
		WHERE ZCZ.ZCZ_FILIAL = %XFILIAL:ZCZ%
			AND ZCZ.ZCZ_DOCSEQ <> "XXXXXX"
			AND ZCZ.ZCZ_COD BETWEEN %EXP:MV_PAR01% AND %EXP:MV_PAR02%
			AND SB1.B1_GRUPO BETWEEN %Exp:MV_PAR03% AND %EXP:MV_PAR04%
			AND ZCZ.%NotDel%
		GROUP BY ZCZ.ZCZ_DOCSEQ
			,ZCZ.ZCZ_SOLICI
			,ZCZ.ZCZ_COD
			,SB1.B1_TIPO
			,SB1.B1_GRUPO
			,SB1.B1_DESC
			,SB1.B1_UM
			,ZCZ.ZCZ_LOCAL
			,ZZY_NOME
		)SALDO
		)SALDOFINAL
		WHERE DTDIG BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
			AND SALDO <> 0
		ORDER BY ZCZ_SOLICI
			,ZCZ_DOCSEQ
			,ZCZ_COD

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
	IncProc("Gerando Relatorio(Saldo) - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Saldos",{20,40,120,40,30,25,30,320,20,25,25,48,45,25,35},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,13)
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,13)
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Saldo MD",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,13)

	oExcel:AddLinha(20)
	oExcel:AddLinha(12)
	oExcel:AddCelula()
	oExcel:AddCelula("Matrícula"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Código"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Almox."				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Tipo"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Grupo"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Descrição"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("UM"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Saldo"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Valor"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dt. Chegada"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dt. Nec."						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dias"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("DOCSEQ"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	While (_cAlias)->(!EOF())

		_nCusMed	:=	fRetCm((_cAlias)->ZCZ_COD,(_cAlias)->ZCZ_LOCAL)

		_dDtNec		:=	fGetDtNec((_cAlias)->ZCZ_DOCSEQ)

		_dDtDiff	:=	Iif((_cAlias)->DTDIG > Dtos(_dDtNec),StoD((_cAlias)->DTDIG),_dDtNec)

		nRegAtu++
	
		oExcel:AddLinha(14)
		oExcel:AddCelula()

		oExcel:AddCelula( (_cAlias)->ZCZ_SOLICI		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( Alltrim((_cAlias)->ZZY_NOME)		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_COD		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_LOCAL			,0		 				,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->B1_TIPO		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->B1_GRUPO		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( Alltrim((_cAlias)->B1_DESC)		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->B1_UM		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->SALDO			,0		 				,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->SALDO * _nCusMed			,8		 				,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( Stod((_cAlias)->DTDIG)			,0		 				,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( _dDtNec		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( If(!Empty((_cAlias)->DTDIG),DateDiffDay(_dDtDiff,Date()),0)			,0		 				,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_DOCSEQ		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)


		IncProc("Gerando Relatorio(Cabeçalho) - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		(_cAlias)->(DbSkip())

	EndDo


	(_cAlias)->(dbCloseArea())

	fGeraParametros()
	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.)

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")

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
	aPergs[3,3] := MV_PAR03
	aPergs[4,3] := MV_PAR04 
	aPergs[5,3] := DtoC(MV_PAR05)
	aPergs[6,3] := DtoC(MV_PAR06) 
	aPergs[7,3] := cDirDest     

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

Static Function fRetCm(_cCod,_cLocal)

	Local _nCm		:=	0
	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias
		%NoParser%
		SELECT ISNULL(B2_CM1,0) B2_CM1
		FROM %TABLE:SB2% (NOLOCK)
		WHERE B2_FILIAL = %XFILIAL:SB2%
		AND B2_COD = %Exp:_cCod%
		AND B2_LOCAL = %Exp:_cLocal%
		AND %NotDel%
	EndSql

	_nCm	:=	(_cAlias)->B2_CM1

	(_cAlias)->(DbCloseArea())

Return _nCm

Static Function fGetDtNec(_cDocSeq)

	Local _dDtNec	:=	Stod("")
	Local _cAlias	:=	GetNextAlias()
	Local _cAlias2
	
	BeginSql Alias _cALias
	%NoParser%
	SELECT MAX(R_E_C_N_O_) REG
	FROM %TABLE:ZCZ% ZCZ (NOLOCK)
		WHERE ZCZ_DOCSEQ = %Exp:_cDocSeq%
			AND ZCZ_TM = '001'
			AND ZCZ.%NotDel%
	EndSql

	If (_cAlias)->(!EOF())
		_cAlias2 := GetNextAlias()	
		BeginSql Alias _cAlias2
			%NoParser%
			SELECT C1_DATPRF
			FROM %TABLE:SD1% SD1 (NOLOCK)
			JOIN %TABLE:SC7% SC7 (NOLOCK) ON SD1.D1_FILIAL = SC7.C7_FILIAL
				AND SD1.D1_PEDIDO = SC7.C7_NUM
				AND SD1.D1_ITEMPC = SC7.C7_ITEM
				AND SC7.%NotDel%
			JOIN %TABLE:SC1% SC1 (NOLOCK) ON SC7.C7_FILIAL = SC1.C1_FILIAL
				AND SC7.C7_NUMSC = SC1.C1_NUM
				AND SC7.C7_ITEMSC = SC1.C1_ITEM
				AND SC1.%NotDel%
			JOIN %TABLE:ZCZ% ZCZ (NOLOCK) ON ZCZ.ZCZ_FILIAL = SD1.D1_FILIAL
				AND ZCZ.ZCZ_DOC = SD1.D1_DOC
				AND ZCZ.ZCZ_SERIE = SD1.D1_SERIE
				AND ZCZ.ZCZ_FORNEC = SD1.D1_FORNECE
				AND ZCZ.ZCZ_LOJA = SD1.D1_LOJA
				AND ZCZ.ZCZ_ITEM = SD1.D1_ITEM
				AND ZCZ.%NotDel%
			WHERE ZCZ.ZCZ_FILIAL = %XFILIAL:ZCZ%
				AND ZCZ.R_E_C_N_O_ = %Exp:(_cAlias)->REG%
				AND SD1.%NotDel%
		EndSql
	
		If (_cAlias2)->(!EOF())
			_dDtNec	:=	Stod((_cAlias2)->C1_DATPRF)
		EndIF
		
		(_cAlias2)->(DbCloseArea())
	EndIf

	(_cAlias)->(DbCloseArea())
	
Return _dDtNec