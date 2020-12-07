#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG119
@author Gabriel Rossi Mafioletti
@since 17/12/2019
@version 1.0
@description Relatório de Conferência de Entrada de Notas Fiscais
@type function
/*/

User Function BIAFG119()

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

	local cLoad	    := "BIAFG119" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.

	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	MV_PAR03 := space(100)

	aAdd( aPergs ,{1,"Data de? " 	   		,MV_PAR01 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Data Até?" 	   		,MV_PAR02 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino?"  		,MV_PAR03 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório de Conferência de Entrada de Notas Fiscais",,,,,,,,cLoad,.T.,.T.)

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

	local cArqXML   := "BIAFG119_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))

	BeginSql Alias _cAlias
		%NoParser%
		WITH XSF1
		AS (
		SELECT 'SF1' TABL
		,F1_CHVNFE CHAVE
		,F1_ESPECIE ESPECIE
		,F1_EMISSAO EMISSAO
		,F1_DTDIGIT DTDIGIT
		,F1_TIPO TIPO
		,F1_EST EST
		,F1_DOC DOC
		,F1_SERIE SERIE
		,F1_FORNECE FORNECE
		,F1_LOJA LOJA
		,NOME = CASE 
		WHEN F1_TIPO IN (
		'B'
		,'D'
		)
		THEN A1_NOME
		ELSE A2_NOME
	END
	,SIMPNAC = CASE 
	WHEN F1_TIPO IN (
	'B'
	,'D'
	)
	THEN ''
	ELSE A2_SIMPNAC
	END
	,F1_VALBRUT TOTAL
	,F1_BASEICM BASICM
	,F1_VALICM VALICM
	,F1_BASEIPI BASIPI
	,F1_VALIPI VALIPI
	FROM %TABLE:SF1% SF1(NOLOCK)
	LEFT JOIN %TABLE:SA2% SA2 ON A2_COD = F1_FORNECE
	AND A2_LOJA = F1_LOJA
	AND SA2.%NotDel%
	LEFT JOIN %TABLE:SA1% SA1 ON A1_COD = F1_FORNECE
	AND A1_LOJA = F1_LOJA
	AND SA1.%NotDel%
	WHERE F1_FILIAL = %XFILIAL:SF1%
	AND F1_DTDIGIT BETWEEN %Exp:MV_PAR01%
	AND %Exp:MV_PAR02%
	AND F1_CHVNFE <> ''
	AND F1_ESPECIE IN (
	'CTE  '
	,'SPED '
	)
	AND EXISTS (
	SELECT *
	FROM %TABLE:SD1% SD1(NOLOCK)
	WHERE D1_FILIAL = F1_FILIAL
	AND D1_DOC = F1_DOC
	AND D1_SERIE = F1_SERIE
	AND D1_FORNECE = F1_FORNECE
	AND D1_LOJA = F1_LOJA
	AND D1_EMISSAO = F1_EMISSAO
	AND D1_TES <> '   '
	AND SD1.%NotDel%
	)
	AND SF1.%NotDel%
	)
	,XZAA
	AS (
	SELECT 'ZAA' TABL
	,ZAA_CHAVE CHAVE
	,ZAA_ESPECI ESPECIE
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
	,SIMPNAC = CASE 
	WHEN ZAA_TIPOEN IN (
	'B'
	,'D'
	)
	THEN ''
	ELSE A2_SIMPNAC
	END
	,ZAA_TOTVAL TOTAL
	,ZAA_BASEIC BASEICM
	,ZAA_TOTICM VALICM
	,ZAA_BASEIP BASEIPI
	,ZAA_TOTIPI VALIPI
	FROM %TABLE:ZAA% ZAA(NOLOCK)
	LEFT JOIN %TABLE:SA2% SA2 ON A2_COD = ZAA_CODEMI
	AND A2_LOJA = ZAA_LOJEMI
	AND SA2.%NotDel%
	LEFT JOIN %TABLE:SA1% SA1 ON A1_COD = ZAA_CODEMI
	AND A1_LOJA = ZAA_LOJEMI
	AND SA1.%NotDel%
	WHERE ZAA_FILIAL = %XFILIAL:ZAA%
	AND ZAA_DTCRIA BETWEEN %Exp:MV_PAR01-60% AND %Exp:MV_PAR02+30%
	AND ZAA.%NotDel%
	)
	SELECT TABL
	,CHAVE
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
	,SIMPNAC
	,NF_TOTAL
	,NF_BASICM
	,NF_VALICM
	,NF_BASIPI
	,NF_VALIPI
	,CN_TOTAL
	,CN_BASICM
	,CN_VALICM
	,CN_BASIPI
	,CN_VALIPI
	,CHK_TOTAL = CASE 
	WHEN NF_TOTAL = CN_TOTAL
	THEN 'Ok'
	ELSE 'Erro'
	END
	,CHK_BASICM = CASE 
	WHEN NF_BASICM = CN_BASICM
	THEN 'Ok'
	ELSE 'Erro'
	END
	,CHK_VALICM = CASE 
	WHEN NF_VALICM = CN_VALICM
	THEN 'Ok'
	ELSE 'Erro'
	END
	,CHK_BASIPI = CASE 
	WHEN NF_BASIPI = CN_BASIPI
	THEN 'Ok'
	ELSE 'Erro'
	END
	,CHK_VALIPI = CASE 
	WHEN NF_VALIPI = CN_VALIPI
	THEN 'Ok'
	ELSE 'Erro'
	END
	,CASE WHEN (SELECT COUNT(*) FROM %TABLE:ZAA% ZAA WHERE ZAA_CHAVE = CHAVE ) > 0 THEN 'Sim' ELSE 'Não' END CHVXML
	FROM (
	SELECT COUNT(SF1.TABL) TABL
	,SF1.CHAVE
	,SF1.ESPECIE
	,SF1.EMISSAO
	,SF1.DTDIGIT
	,SF1.TIPO
	,SF1.EST
	,SF1.DOC
	,SF1.SERIE
	,SF1.FORNECE
	,SF1.LOJA
	,SF1.NOME
	,SF1.SIMPNAC
	,SUM(SF1.TOTAL) NF_TOTAL
	,SUM(SF1.BASICM) NF_BASICM
	,SUM(SF1.VALICM) NF_VALICM
	,SUM(SF1.BASIPI) NF_BASIPI
	,SUM(SF1.VALIPI) NF_VALIPI
	,SUM(ZAA.TOTAL) CN_TOTAL
	,SUM(ZAA.BASEICM) CN_BASICM
	,SUM(ZAA.VALICM) CN_VALICM
	,SUM(ZAA.BASEIPI) CN_BASIPI
	,SUM(ZAA.VALIPI) CN_VALIPI
	FROM XSF1 SF1
	LEFT JOIN XZAA ZAA ON ZAA.CHAVE = SF1.CHAVE
	AND ZAA.EMISSAO = SF1.EMISSAO
	AND ZAA.EST = SF1.EST
	AND ZAA.DOC = SF1.DOC
	AND ZAA.SERIE = SF1.SERIE
	AND ZAA.FORNECE = SF1.FORNECE
	AND ZAA.LOJA = SF1.LOJA
	AND ZAA.NOME = SF1.NOME
	GROUP BY SF1.CHAVE
	,SF1.ESPECIE
	,SF1.EMISSAO
	,SF1.DTDIGIT
	,SF1.TIPO
	,SF1.EST
	,SF1.DOC
	,SF1.SERIE
	,SF1.FORNECE
	,SF1.LOJA
	,SF1.NOME
	,SF1.SIMPNAC
	,ZAA.CHAVE
	,ZAA.ESPECIE
	,ZAA.EMISSAO
	,ZAA.DTDIGIT
	,ZAA.TIPO
	,ZAA.EST
	,ZAA.DOC
	,ZAA.SERIE
	,ZAA.FORNECE
	,ZAA.LOJA
	,ZAA.NOME
	) AS TAB2
	ORDER BY 2
	,1
	,3
	,4
	,5;


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
	IncProc("Gerando Relatorio(Cabeçalho) - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

	oExcel := ARSexcel():New()

	oExcel:AddPlanilha("Cabecalho",{20,40,193,30,43,43,21,30,45,25,45,21,267,75,50,50,50,45,45,45,55,55,50,55,50,60,63,55,60,85},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,28)
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,28)
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Relatório de Conferência de Entrada de Notas Fiscais",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,28)

	oExcel:AddLinha(20)
	oExcel:AddLinha(12)
	oExcel:AddCelula()
	oExcel:AddCelula("Qtd. Regs."				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Chave"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Espécie"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Emissão"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Digitação"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Tipo"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Estado"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Documento"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Série"			 		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Fornecedor"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Loja"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Simples Nacional"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	oExcel:AddCelula("Total NF"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Base ICM NF"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Valor ICM NF"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Base IPI NF"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Valor IPI NF"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	oExcel:AddCelula("Total XML"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Base ICM XML"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Valor ICM XML"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Base IPI XML"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Valor IPI XML"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	oExcel:AddCelula("Total Status"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Base ICM Status"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Valor ICM Status"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Base IPI Status"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Valor IPI Status"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Chave XML?"        		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	

	While (_cAlias)->(!EOF())

		nRegAtu++

		if MOD(nRegAtu,2) > 0
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14)
		oExcel:AddCelula()

		msSimpNac := IIF((_cAlias)->SIMPNAC == "1", "Sim", "Não")

		oExcel:AddCelula( (_cAlias)->TABL			,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CHAVE			,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
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
		oExcel:AddCelula( msSimpNac             	,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->NF_TOTAL		,TamSx3("F1_VALBRUT")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->NF_BASICM		,TamSx3("F1_BASEICM")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->NF_VALICM		,TamSx3("F1_VALICM")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->NF_BASIPI		,TamSx3("F1_BASEIPI")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->NF_VALIPI		,TamSx3("F1_VALIPI")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CN_TOTAL		,TamSx3("F1_VALBRUT")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CN_BASICM		,TamSx3("F1_BASEICM")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CN_VALICM		,TamSx3("F1_VALICM")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CN_BASIPI		,TamSx3("F1_BASEIPI")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CN_VALIPI		,TamSx3("F1_VALIPI")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CHK_TOTAL		,TamSx3("F1_VALBRUT")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CHK_BASICM		,TamSx3("F1_BASEICM")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CHK_VALICM		,TamSx3("F1_VALICM")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CHK_BASIPI		,TamSx3("F1_BASEIPI")[2]	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CHK_VALIPI		,TamSx3("F1_VALIPI")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula( (_cAlias)->CHVXML  		,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)

		IncProc("Gerando Relatorio(Cabeçalho) - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(dbCloseArea())

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

	aPergs[1,3] := DtoC(MV_PAR01)
	aPergs[2,3] := DtoC(MV_PAR02)
	aPergs[3,3] := cDirDest

	oExcel:AddPlanilha('Parametros',{30,80,120,370})
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

	oExcel:AddLinha(15)
	oExcel:AddLinha(15)
	nCont ++
	if MOD(nCont,2) > 0
		cCorFundo := '#DCE6F1'
	else
		cCorFundo := '#B8CCE4'
	endif

	msChaveCabec := "CHAVE, EMISSAO, EST, DOC, SERIE, FORNECE, LOJA, NOME"
	oExcel:AddLinha(16)
	oExcel:AddCelula()
	oExcel:AddCelula( "Índice:"        ,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( "Cabeçalho"      ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( msChaveCabec     ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.) // Conteudo

	nCont ++
	if MOD(nCont,2) > 0
		cCorFundo := '#DCE6F1'
	else
		cCorFundo := '#B8CCE4'
	endif

	msChaveCabec := "CHAVE, ITEM, EMISSAO, EST, DOC, SERIE, FORNECE, LOJA, NOME"
	oExcel:AddLinha(16)
	oExcel:AddCelula()
	oExcel:AddCelula( ""               ,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( "Item"           ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)
	oExcel:AddCelula( msChaveCabec     ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.) // Conteudo

Return
