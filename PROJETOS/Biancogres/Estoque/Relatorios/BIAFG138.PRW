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

	RpcSetEnv('01','01')

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
	aAdd( aPergs ,{1,"Solicitante De?" 	   			,MV_PAR03 ,""  ,"",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Solicitante Até?" 	   		,MV_PAR04 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino?"  				,MV_PAR05 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório de Pseudo Apontamento",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03) 
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)

		if empty(MV_PAR03) 
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
		FROM %TABLE:ZCZ% ZCZ
		LEFT JOIN %TABLE:ZZY% ZZY ON ZCZ.ZCZ_SOLICI = ZZY.ZZY_MATRIC
			AND ZZY.ZZY_MATRIC <> ''
			AND ZZY.%NotDel%
		LEFT JOIN %TABLE:ZZY% ZZYORI ON ZCZ.ZCZ_SOLICI = ZZYORI.ZZY_MATRIC
			AND ZZYORI.ZZY_MATRIC <> ''
			AND ZZYORI.%NotDel%
		LEFT JOIN %TABLE:SA2% SA2 ON SA2.A2_COD = ZCZ.ZCZ_FORNEC
			AND SA2.A2_LOJA = ZCZ.ZCZ_LOJA
			AND SA2.%NotDel%
		JOIN %TABLE:SB1% SB1 ON SB1.B1_COD = ZCZ.ZCZ_COD
			AND SB1.%NotDel%
		LEFT JOIN %TABLE:ZDI% ZDI ON ZDI.ZDI_CODIGO = ZCZ.ZCZ_TM
		WHERE	ZCZ_DTDIGI BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
		 	AND ZCZ.ZCZ_MATORI BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			AND ZCZ.%NotDel%		
		ORDER BY 
			ZCZ_MATORI
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

	oExcel:AddPlanilha("Movimentos",{20,40,193,30,43,43,21,30,45,25,45,21,267,75,50,50,50,50,50,45},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,19)
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,19)
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Kardex MD",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,19)

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
	oExcel:AddCelula("Dt.Digit."				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Dt. Mov."					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	_cMat		:=	(_cAlias)->ZCZ_SOLICI
	_cMatOri	:=	(_cAlias)->ZCZ_MATORI
	_cNome		:=	(_cAlias)->NOME
	_cNomeOri	:=	(_cAlias)->NOMEORI
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
			oExcel:AddCelula( _cMatOri		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( _cNomeOri		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
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
	oExcel:AddCelula( _cMatOri		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( _cNomeOri		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
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

	(_cAlias)->(dbCloseArea())
/*
	_cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias
		%NoParser%
		WITH XSFT
		AS (
		SELECT 'SFT' TABL
		,FT_CHVNFE CHAVE
		,CASE WHEN F1_ESPECIE = 'CTE' THEN '    ' ELSE FT_ITEM END ITEM
		,FT_ESPECIE ESPECIE
		,FT_EMISSAO EMISSAO
		,FT_ENTRADA DTDIGIT
		,F1_TIPO TIPO
		,FT_ESTADO EST
		,FT_NFISCAL DOC
		,FT_SERIE SERIE
		,FT_CLIEFOR FORNECE
		,FT_LOJA LOJA
		,NOME = CASE 
		WHEN FT_TIPO IN (
		'B'
		,'D'
		)
		THEN A1_NOME
		ELSE A2_NOME
	END
	,FT_PRODUTO PRODUTO
	,FT_TOTAL TOTAL
	,FT_CFOP CFOP
	FROM %TABLE:SFT% SFT(NOLOCK)
	INNER JOIN %TABLE:SF1% SF1(NOLOCK) ON F1_FILIAL = FT_FILIAL
	AND F1_DOC = FT_NFISCAL
	AND F1_SERIE = FT_SERIE
	AND F1_FORNECE = FT_CLIEFOR
	AND F1_LOJA = FT_LOJA
	AND F1_EMISSAO = FT_EMISSAO
	AND SF1.%Notdel%
	LEFT JOIN %TABLE:SA2% SA2 ON A2_COD = FT_CLIEFOR
	AND A2_LOJA = FT_LOJA
	AND SA2.%NotDel%
	LEFT JOIN %TABLE:SA1% SA1 ON A1_COD = FT_CLIEFOR
	AND A1_LOJA = FT_LOJA
	AND SA1.%NotDel%
	WHERE FT_ENTRADA BETWEEN %Exp:MV_PAR01%
	AND %Exp:MV_PAR02%
	AND FT_CFOP < '5000'
	AND FT_ESPECIE IN (
	'CTE  '
	,'SPED '
	)
	AND SFT.%NotDel%
	)
	,XZAB
	AS (
	SELECT 'ZAB' TABL
	,ZAB_CHAVE CHAVE
	,CASE WHEN ZAA_ESPECI = 'CTE' THEN '    ' ELSE ZAB_ITEM END ITEM
	,ZAA_DTEMIS EMISSAO
	,ZAA_DTCRIA DTDIGIT
	,ZAA_TIPOEN TIPO
	,ZAA_EST EST
	,ZAA_DOC DOC
	,ZAA_SERIE SERIE
	,ZAA_CODEMI FORNECE
	,ZAA_LOJEMI LOJA
	,NOME = CASE 
	WHEN ZAA_TIPOEN IN (
	'B'
	,'D'
	)
	THEN A1_NOME
	ELSE A2_NOME
	END
	,'' ZAB_COD
	,ZAB_TOTAL
	,ZAB_CF CFOP
	FROM %TABLE:ZAB% ZAB(NOLOCK)
	INNER JOIN %TABLE:ZAA% ZAA(NOLOCK) ON ZAA_FILIAL = ZAB_FILIAL
	AND ZAA_CHAVE = ZAB_CHAVE
	AND ZAA_DTCRIA BETWEEN %Exp:MV_PAR01-60% AND %Exp:MV_PAR02+30%
	AND ZAA.%NotDel%
	LEFT JOIN %TABLE:SA2% SA2 ON A2_COD = ZAA_CODEMI
	AND A2_LOJA = ZAA_LOJEMI
	AND SA2.%NotDel%
	LEFT JOIN %TABLE:SA1% SA1 ON A1_COD = ZAA_CODEMI
	AND A1_LOJA = ZAA_LOJEMI
	AND SA1.%NotDel%
	)
	SELECT TABL
	,CHAVE
	,ITEM
	,ESPECIE
	,CONVERT(CHAR(10), CONVERT(DATETIME, EMISSAO), 103) EMISSAO
	,CONVERT(CHAR(10), CONVERT(DATETIME, DTDIGIT), 103) DTDIGIT
	,TIPO
	,EST
	,DOC
	,SERIE
	,FORNECE
	,LOJA
	,NOME
	,PRODUTO
	,TOTAL
	,NF_CFOP
	,CN_CFOP
	,B1_GRUPO GRUPO
	,BM_DESC DESCRIC
	,RTRIM(B1_DESC) DPRODUTO
	,CASE WHEN (SELECT COUNT(*) FROM %TABLE:ZAB% ZAB WHERE ZAB_CHAVE = CHAVE ) > 0 THEN 'Sim' ELSE 'Não' END CHVITM
	,CASE WHEN (SELECT COUNT(*) FROM %TABLE:ZAA% ZAA WHERE ZAA_CHAVE = CHAVE ) > 0 THEN 'Sim' ELSE 'Não' END CHVCAB			
	FROM (
	SELECT (SFT.TABL) TABL
	,SFT.CHAVE
	,SFT.ITEM
	,SFT.ESPECIE
	,SFT.EMISSAO
	,SFT.DTDIGIT
	,SFT.TIPO
	,SFT.EST
	,SFT.DOC
	,SFT.SERIE
	,SFT.FORNECE
	,SFT.LOJA
	,SFT.NOME
	,(SFT.PRODUTO) PRODUTO
	,TOTAL
	,(SFT.CFOP) NF_CFOP
	,(ZAB.CFOP) CN_CFOP
	,ZAB.CHAVE VVC
	FROM XSFT SFT
	LEFT JOIN XZAB ZAB ON ZAB.CHAVE = SFT.CHAVE
	AND (ZAB.ITEM = SFT.ITEM OR 
		 ZAB.ITEM = REPLACE(STR(SFT.ITEM, 4), SPACE(1), '0')) //estava dando problema, pois 0001 = 1 é falso
	AND ZAB.EMISSAO = SFT.EMISSAO
	AND ZAB.EST = SFT.EST
	AND ZAB.DOC = SFT.DOC
	AND ZAB.SERIE = SFT.SERIE
	AND ZAB.FORNECE = SFT.FORNECE
	AND ZAB.LOJA = SFT.LOJA
	AND ZAB.NOME = SFT.NOME
	) AS TAB2
	INNER JOIN %TABLE:SB1% SB1 ON B1_COD = PRODUTO
	AND SB1.%NotDel%
	INNER JOIN %TABLE:SBM% SBM ON BM_GRUPO = B1_GRUPO
	AND SBM.%NotDel%
	ORDER BY 2
	,1
	,3
	,4
	,5

	EndSql

	nRegAtu	:=	0
	nTotReg	:= 0
	(_cAlias)->(DbGoTop())
	Count To nTotReg

	(_cAlias)->(dbGoTop())
	ProcRegua(nTotReg + 2)

	nRegAtu++
	IncProc("Gerando Relatorio(Itens) - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

	oExcel:AddPlanilha("Itens",{20,30,215,25,30,50,50,21,30,50,25,50,21,267,50,300,50,35,41,35,158,85,85},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,21)
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,21)
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório de Conferência de Entrada de Notas Fiscais",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,21)

	oExcel:AddLinha(20)
	oExcel:AddLinha(12)
	oExcel:AddCelula()
	oExcel:AddCelula("Tabela"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Chave"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Item"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Espécie"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Emissão"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Digitação"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Tipo"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Estado"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Documento"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Série"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Fornecedor"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Loja"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Produto"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("DescProduto"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Total"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CFOP NF"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("CFOP XML"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Grupo"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Descrição"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Chave XML Item?"	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Chave XML Cabec?"	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	

	While (_cAlias)->(!EOF())

		nRegAtu++

		if MOD(nRegAtu,2) > 0
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14)
		oExcel:AddCelula()

		oExcel:AddCelula( (_cAlias)->TABL			,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CHAVE			,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ITEM			,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->ESPECIE		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->EMISSAO		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->DTDIGIT		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->TIPO			,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->EST			,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->DOC			,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->SERIE			,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->FORNECE		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->LOJA			,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->NOME			,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->PRODUTO		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->DPRODUTO		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->TOTAL			,TamSx3("F1_VALBRUT")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->NF_CFOP		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CN_CFOP		,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->GRUPO		    ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->DESCRIC		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CHVITM  		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CHVCAB  		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)

		IncProc("Gerando Relatorio(Itens) - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(dbCloseArea())		
*/
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
