#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG037
@author Gabriel Rossi Mafioletti
@since 09/04/2018
@version 1.0
@description Relatório Excel de Consumo de EPI's
@type function
/*/

User Function BIAFG037()

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

	local cLoad	    := "BIAFG037" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local _nPeso	:=	0

	MV_PAR01 := STOD('')
	MV_PAR02 := STOD('')
	MV_PAR03 := SPACE(6)
	MV_PAR04 := SPACE(6)
	MV_PAR05 := SPACE(4)
	MV_PAR06 := SPACE(4)
	MV_PAR07 := space(100)
	

	aAdd( aPergs ,{1,"Data de? " 	   		,MV_PAR01 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Data Até?" 	   		,MV_PAR02 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Matr de? " 	   		,MV_PAR03 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Matr Até?" 	   		,MV_PAR04 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Cl Vl de?" 	   		,MV_PAR05 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Cl Vl Até?" 	   		,MV_PAR06 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
		
	aAdd( aPergs ,{6,"Pasta Destino?"  		,MV_PAR07 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Relatório de Consumo de EPI's' ",,,,,,,,cLoad,.T.,.T.)

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
	Local _cDataDe	:=	DtoS(MV_PAR01)
	Local _cDataAte	:=	DtoS(MV_PAR02)
	Local _cMatrDe	:=	'01'+MV_PAR03
	Local _cMatrAte	:=	'01'+MV_PAR04
	Local _cClVlDe	:=	MV_PAR05
	Local _cClVlAte	:=	MV_PAR06
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
	local nEmp	:=	Val(cempAnt)

	local cArqXML   := "BIAFG037_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	Local _cAliasSr		:=	U_fGetDbSr()
	Local _cAliasFun	:=	"%" + _cAliasSr + ".dbo.r034fun" + "%"
	Local _cAliasCar	:=	"%" + _cAliasSr + ".dbo.r024car" + "%"


	BeginSql Alias _cAlias
		%NoParser%
		SELECT SD3.D3_EMISSAO EMISSAO
			,SD3.D3_DOC DOC
			,SD3.D3_LOCAL ALMOX
			,SB1.B1_GRUPO GRUPO
			,SBM.BM_DESC DGRUPO
			,SD3.D3_COD PRODUTO
			,SUBSTRING(SB1.B1_DESC, 1, 70) DPRODUTO
			,SB1.B1_UM UM
			,SD3.D3_CONTA CONTA
			,CT1.CT1_DESC01 DCONTA
			,SD3.D3_CC CCUSTO
			,CTT.CTT_DESC01 DCCUSTO
			,SD3.D3_CLVL CLVL
			,CTH.CTH_DESC01 DCLVL
			,SD3.D3_YMATRIC MATRIC
			,ZZY.ZZY_NOME NOME
			,CARFUN.titcar FUNCAO
			, CASE WHEN SD3.D3_TM = '502' THEN SD3.D3_QUANT ELSE SD3.D3_QUANT*(-1) END QUANT
			,SD3.D3_CUSTO1 CUSTO
		FROM %Table:SD3% SD3(NOLOCK)
		INNER JOIN %Table:SB1% SB1(NOLOCK) ON SB1.B1_FILIAL = %xFilial:SB1%
			AND SB1.B1_COD = SD3.D3_COD
			AND SB1.%NotDel%
		INNER JOIN %Table:SBM% SBM(NOLOCK) ON SBM.BM_FILIAL = %xFilial:SBM%
			AND SBM.BM_GRUPO = SB1.B1_GRUPO
			AND SBM.BM_GRUPO BETWEEN '212 '	AND '212Z'		
			AND SBM.%NotDel%
		LEFT JOIN %Table:CT1% CT1(NOLOCK) ON CT1_FILIAL = %xFilial:CT1%
			AND CT1_CONTA = SD3.D3_CONTA
			AND CT1.%NotDel%
		LEFT JOIN %Table:CTT% CTT(NOLOCK) ON CTT_FILIAL = %xFilial:CTT%
			AND CTT_CUSTO = SD3.D3_CC
			AND CTT.%NotDel%
		LEFT JOIN %Table:CTH% CTH(NOLOCK) ON CTH_FILIAL = %xFilial:CTH%
			AND CTH_CLVL = SD3.D3_CLVL
			AND CTH.%NotDel%
		LEFT JOIN %Table:ZZY% ZZY(NOLOCK) ON ZZY.ZZY_FILIAL = %xFilial:ZZY%
			AND ZZY.ZZY_MATRIC = SD3.D3_YMATRIC
			AND ZZY.%Notdel%
		LEFT JOIN %Exp:_cAliasFun% CADFUN(NOLOCK) ON //SRA.SRA_FILIAL = %xFilial:SRA%
			 CAST(SUBSTRING(SD3.D3_YMATRIC,3,6) AS INT) = CADFUN.numCad
			 AND CADFUN.TIPCOL = 1
			 AND CADFUN.numemp = %Exp:nEmp% 
		LEFT JOIN %Exp:_cAliasCar% CARFUN(nolock) ON
		 	CADFUN.codcar = CARFUN.codcar
		WHERE SD3.D3_FILIAL = %xFilial:SD3%
			AND SD3.D3_EMISSAO BETWEEN %Exp:_cDataDe%
				AND %Exp:_cDataAte%
			AND SD3.%NotDel%
			AND SD3.D3_TM not in ('499', '999')
			AND	SD3.D3_YMATRIC BETWEEN %Exp:_cMatrDe%
			AND %Exp:_cMatrAte%	
			AND	SD3.D3_CLVL BETWEEN %Exp:_cClVlDe%
			AND %Exp:_cClVlAte%	
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

	oExcel:AddPlanilha("Relatorio",{21,35,45,55,51,27,134,34,346,18,38,157,33,76,33,191,39,155,100,30,28},6)

	oExcel:AddLinha(21)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,19) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,19) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(21)
	oExcel:AddCelula("Relatório de Consumo de EPI's' ",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,19)  

	oExcel:AddLinha(21)
	oExcel:AddLinha(12) 
	oExcel:AddCelula()
	oExcel:AddCelula("Empresa"								,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Emissão"								,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Doc"					                ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Almoxarifado"							,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Grupo"							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Desc."							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Produto"							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Desc."							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("UM"							        ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Conta"							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Desc."							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("C. Custo"							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Desc."							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("C. Valor"							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Desc."							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Matrícula"							,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Nome"							        ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Função"							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Quant."							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo"							    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	While (_cAlias)->(!EOF())

		nRegAtu++

		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14) 
		oExcel:AddCelula()

		oExcel:AddCelula(cEmpAnt					,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(StoD((_cAlias)->EMISSAO)	,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->DOC				,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->ALMOX			,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->GRUPO			,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->DGRUPO			,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->PRODUTO			,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->DPRODUTO		,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->UM				,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CONTA			,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->DCONTA			,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CCUSTO			,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->DCCUSTO			,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CLVL			,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->DCLVL			,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->MATRIC			,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->NOME			,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->FUNCAO			,0							,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->QUANT			,TamSx3("D3_QUANT")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CUSTO			,TamSx3("D3_CUSTO1")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)



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
