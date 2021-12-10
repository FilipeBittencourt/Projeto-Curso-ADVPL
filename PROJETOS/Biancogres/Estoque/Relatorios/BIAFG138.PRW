#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG138
@author Gabriel Rossi Mafioletti
@since 02/03/2020
@version 1.0
@description Kardex MD
@type function
/*/

User Function BIAFG138()

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

	local cLoad	    := "BIAFG138" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.

	MV_PAR01 :=	Stod("")
	MV_PAR02 :=	Stod("")
	MV_PAR03 := '        '
	MV_PAR04 := '        '
	MV_PAR05 := space(100)

	aAdd( aPergs ,{1,"Dt. Movto. De?" 	   			,MV_PAR01 ,""  ,"",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Dt. Movto. Até?" 	   			,MV_PAR02 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Solicitante De?" 	   			,MV_PAR03 ,""  ,"",'ZZY'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Solicitante Até?" 	   		,MV_PAR04 ,""  ,"NAOVAZIO()",'ZZY'  ,'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino?"  				,MV_PAR05 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório de Pseudo Apontamento",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03) 
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)

		if empty(MV_PAR05) 
			MV_PAR05 := AllTrim(GetTempPath()) 	
		endif

		cDirDest	:=	MV_PAR05

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

	local cArqXML   := "BIAFG138_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))

	Local _cChave	:=	""
	Local _cMat		:=	""
	Local _cMatOri	:=	""
	Local _cNome		:=	""
	Local _cNomeOri	:=	""
	Local _nTotDoc	:=	0

	Local _cDataDe	:=	DtoS(MV_PAR01)
	Local _cDataAte	:=	DtoS(MV_PAR02)

	Local _cTpMov	:=	""

	BeginSql Alias _cAlias
		%NoParser%
		SELECT ZCZ_SOLICI
			,ZZY.ZZY_NOME NOME
			,ZCZ_MATORI
			,ZZYORI.ZZY_NOME NOMEORI
			,ZCZ_DOCSEQ
			,ZCZ_DOC
			,ZCZ_SERIE
			,ZCZ_FORNEC
			,ZCZ_LOJA
			,A2_NOME
			,ZCZ_ITEM
			,ZCZ_COD
			,B1_DESC
			,ZCZ_LOCAL
			,ZCZ_QUANT
			,ZCZ_TM
			,ZDI_DESCRI
			,ZCZ_DTDIGI
			,ZCZ_DHMOV
			,ZCZ.R_E_C_N_O_ REC
		FROM %TABLE:ZCZ% ZCZ
		LEFT JOIN %TABLE:ZZY% ZZY ON ZZY.ZZY_FILIAL = ZCZ.ZCZ_FILIAL
			AND ZCZ.ZCZ_SOLICI = ZZY.ZZY_MATRIC
			AND ZZY.ZZY_MATRIC <> ''
			AND ZZY.%NotDel%
		LEFT JOIN %TABLE:ZZY% ZZYORI ON ZZYORI.ZZY_FILIAL = ZCZ.ZCZ_FILIAL
			AND ZCZ.ZCZ_MATORI = ZZYORI.ZZY_MATRIC
			AND ZZYORI.ZZY_MATRIC <> ''
			AND ZZYORI.%NotDel%
		LEFT JOIN %TABLE:SA2% SA2 ON SA2.A2_COD = ZCZ.ZCZ_FORNEC
			AND SA2.A2_LOJA = ZCZ.ZCZ_LOJA
			AND SA2.%NotDel%
		JOIN %TABLE:SB1% SB1 ON SB1.B1_COD = ZCZ.ZCZ_COD
			AND SB1.%NotDel%
		LEFT JOIN %TABLE:ZDI% ZDI ON ZDI.ZDI_CODIGO = ZCZ.ZCZ_TM
		WHERE	ZCZ_DTDIGI BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
		 	AND ZCZ.ZCZ_SOLICI BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			AND ZCZ.%NotDel%		
		ORDER BY 
			ZCZ_SOLICI
			,ZCZ_DOCSEQ
			,ZCZ_DHMOV

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
	IncProc("Gerando Relatorio(Movimentos) - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Movimentos",{20,40,40,120,45,120,35,45,24,30,22,130,25,35,315,30,57,19,90,300,40,95},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,20)
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,20)
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Kardex MD",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,20)

	oExcel:AddLinha(20)
	oExcel:AddLinha(12)
	oExcel:AddCelula()
	oExcel:AddCelula("Tp. Mov"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Solic. Orig."				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Solic. Retira"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("DOCSEQ"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Documento"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Série"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Fornec."					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Loja"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Item"				 		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Cod."						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Descrição"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Almox."					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Quant."					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("TM"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Descrição"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Observação"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dt.Digit."				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dt. Mov."					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	_cMat		:=	(_cAlias)->ZCZ_SOLICI
	_cNome		:=	(_cAlias)->NOME
	_cChave	:=	(_cAlias)->(ZCZ_DOCSEQ)
	_nTotDoc	:=	0

	While (_cAlias)->(!EOF())

		nRegAtu++

		If _cChave <> (_cAlias)->(ZCZ_DOCSEQ)

			_cTpMov	:=	'Total Item'
			
			cCorFun2	:=	"#D0CECE"
	
			oExcel:AddLinha(14)
			oExcel:AddCelula()
	
			oExcel:AddCelula( _cTpMov					,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( _cMat		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( _cNome		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( (_cAlias)->ZCZ_MATORI		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( (_cAlias)->NOMEORI		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( _nTotDoc		,TamSx3("ZCZ_QUANT")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		
			_nTotDoc	:=	0
			_cChave	:=	(_cAlias)->(ZCZ_DOCSEQ)
			
		EndIf

		oExcel:AddLinha(14)
		oExcel:AddCelula()
			
		if (_cAlias)->ZCZ_TM > "500"
			cCorFun2 := '#FF9999'
			_cTpMov	:=	"Saída"
			_nTotDoc	-= (_cAlias)->ZCZ_QUANT
		else
			cCorFun2 := '#8EA9DB'
			_cTpMov	:=	"Entrada"
			_nTotDoc	+= (_cAlias)->ZCZ_QUANT
		endif
		ZCZ->(DbGoto((_cAlias)->REC))

		oExcel:AddCelula( _cTpMov					,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_SOLICI		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->NOME		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_MATORI		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->NOMEORI		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_DOCSEQ		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_DOC		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_SERIE		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_FORNEC			,0		 				,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_LOJA			,0		 				,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->A2_NOME			,0		 				,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_ITEM			,0		 				,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_COD		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->B1_DESC			,0		 				,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_LOCAL			,0		 				,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_QUANT		,TamSx3("ZCZ_QUANT")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_TM			,0							,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZDI_DESCRI		,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( ZCZ->ZCZ_OBS		,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_DTDIGI		,0							,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ZCZ_DHMOV		,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)

		IncProc("Gerando Relatorio(Cabeçalho) - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		(_cAlias)->(DbSkip())

	EndDo

	_cTpMov	:=	'Total Item'

	cCorFun2	:=	"#D0CECE"


	oExcel:AddLinha(14)
	oExcel:AddCelula()

	oExcel:AddCelula( _cTpMov					,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( _cMat		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( _cNome		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( _cMat		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( _cNome		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( _nTotDoc		,TamSx3("ZCZ_QUANT")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( ""		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)


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
	
	
	aPergs[1,3] := DtoC(MV_PAR01)
	aPergs[2,3] := DtoC(MV_PAR02) 
	aPergs[3,3] := DtoC(MV_PAR01)
	aPergs[4,3] := DtoC(MV_PAR02) 

	aPergs[5,3] := cDirDest     
	         
	

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
