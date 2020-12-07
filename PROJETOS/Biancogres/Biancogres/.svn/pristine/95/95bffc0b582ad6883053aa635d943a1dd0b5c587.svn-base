#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG058
@author Gabriel Rossi Mafioletti
@since 20/087/2018
@version 1.0
@description Custo Unitário Orçamento
@type function
/*/

User Function BIAFG058()

	RptDetail()

Return

Static Function RptDetail()

	Private aPergs	:=	{}
	Private cDirDest	:= ""

	If !ValidPerg()
		Return
	EndIf

	Processa({|| fQryDados()})

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG058" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local _nPeso	:=	0

	MV_PAR01 :=	Space(200)
	MV_PAR02 := space(100)
	MV_PAR03 := .F.
	MV_PAR04 := SPACE(10)
	MV_PAR05 := SPACE(3)
	MV_PAR06 := SPACE(4)

	aAdd( aPergs ,{1,"Grupo(s) " 		  	,MV_PAR01 ,""  ,"U_BIAFG28G()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino?"  		,MV_PAR02 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )
	aAdd( aPergs ,{4,"Grava Info?" 			,MV_PAR03 ,""  ,50,""  ,.F.})
	aAdd( aPergs ,{1,"Orçamento " 		  	,MV_PAR04 ,""  ,"EXISTCPO('ZB5')",'ZB5'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Revisão " 		  	,MV_PAR05 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"Ano Ref. " 		  	,MV_PAR06 ,""  ,"",''  ,'.F.',50,.F.})

	If ParamBox(aPergs ,"Custo Unitário Orçamento",,{|| U_BFG058OK()},,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)
		MV_PAR06 := ParamLoad(cFileName,,6,MV_PAR06)

		if empty(MV_PAR02)
			MV_PAR02 := AllTrim(GetTempPath())
		endif

		cDirDest	:=	MV_PAR02

	EndIf

Return lRet

Static Function fQryDados()

	Local _cAlias	:=	GetNextAlias()
	Local nTotReg	:=	0
	Local _cData	:=	Dtos(Date())
	local nRegAtu   := 0

	Local _nUltCus	:=	0
	Local _dUltEnt	:=	Stod("")
	Local _nVBrut	:=	0
	Local _nVLiq	:=	0
	Local _nVFret	:=	0
	Local _aSaldos	:=	{}

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
	Local fk

	local cEmpresa  := CapitalAce(SM0->M0_NOMECOM)

	local cArqXML   := "BIAFG058_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))

	Local _nI
	Local cInGrp	:=	""

	For _nI	:=	1 to Len(MV_PAR01) STEP 4
		If Substr(MV_PAR01,_nI,4) <> '****'
			cInGrp +=	"'" + Substr(MV_PAR01,_nI,4) + "',"
		EndIf
	Next
	If Empty(cInGrp)
		cInGrp	:=	"()"
	Else
		cInGrp	:=	"(" + Substr(cInGrp,1,Len(cInGrp)-1) + ")"
	End

	cInGrp	:=	'%' + cInGrp + '%'

	msGGini := MV_PAR06 + "0101"      
	msGGfim := MV_PAR06 + "1231"

	BeginSql Alias _cAlias

		SELECT SB1.B1_COD,
		SB1.B1_DESC,
		SBZ.BZ_YCUSANT,
		SBZ.BZ_YCTREF,
		ESTRUT = ISNULL((SELECT COUNT(*) CONTAD
		FROM %TABLE:SGG% SGG
		WHERE GG_INI >= %Exp:msGGini%
		AND GG_FIM <= %Exp:msGGfim%
		AND GG_COMP = B1_COD
		AND SGG.%NotDel%), 0)		
		FROM %TABLE:SB1% SB1
		JOIN %TABLE:SBZ% SBZ
		ON SB1.B1_COD = SBZ.BZ_COD
		AND SBZ.%NotDel%
		WHERE B1_FILIAL = %XFILIAL:SB1%
		AND B1_GRUPO IN %Exp:cInGrp%
		AND SB1.B1_MSBLQL <> '1'
		AND SB1.B1_CONTRAT <> 'S'
		AND SB1.%NotDel%

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

	oExcel:AddPlanilha("Relatorio",{20,37,37,200,70,50,50,50,50,50,50,50},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,11)
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,11)
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Custo Unitário Orçamento",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,11)

	oExcel:AddLinha(20)
	oExcel:AddLinha(12)
	oExcel:AddCelula()
	oExcel:AddCelula("Código"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Grupo"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Descrição"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Estoque"			        ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo Médio"			    ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo UltCom"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Data UltCom"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Preço Mercad."			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Preço Frete" 				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Preço Total"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Custo Manual"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("AtivoEstrutura?"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	If MV_PAR03
		TcSqlExec("UPDATE " + RetSqlName("ZCH") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE ZCH_FILIAL = " + ValtoSql(xFilial("ZCH")) + ;
		" AND ZCH_VERSAO = " + ValtoSql(MV_PAR04) + " AND ZCH_REVISA = " + ValtoSql(MV_PAR05) + ;
		" AND ZCH_ANOREF = " + ValtoSql(MV_PAR06) +" AND D_E_L_E_T_ = '' ")
	EndIf

	While (_cAlias)->(!EOF())

		_nUltcus	:=	0
		_dUltEnt	:=	StoD("")
		_nVBrut		:=	0
		_nVLiq		:=	0
		_nVFret		:=	0

		fUltEnt(_cAlias, @_nUltCus,@_dUltEnt,@_nVbrut,@_nVLiq,@_nVFret)

		msLocEst := {'01','20'}
		msSalEst := 0
		msCstEst := 0
		For fk := 1 to Len(msLocEst)
			_aSaldos  := CalcEst( (_cAlias)->B1_COD, msLocEst[fk], DaySum(Date(),1) )
			msSalEst  += _aSaldos[1]
			msCstEst  += _aSaldos[2]
		Next fk
		nRegAtu++
		If msSalEst >= 1

			if MOD(nRegAtu,2) > 0
				cCorFun2 := '#DCE6F1'
			else
				cCorFun2 := '#B8CCE4'
			endif

			oExcel:AddLinha(14)
			oExcel:AddCelula()
			oExcel:AddCelula( (_cAlias)->B1_COD                              ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( SUBSTR((_cAlias)->B1_COD,1,3)                  ,0		 					,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( (_cAlias)->B1_DESC 	                         ,0		 					,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula(  msSalEst	                                     ,TAMSX3("B2_QATU")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( msCstEst/msSalEst 	                         ,TAMSX3("B9_CM1")[2]	 	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( _nUltCus 	                                     ,TAMSX3("B9_CM1")[2]	 	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( DtoC(_dUltEnt)	                             ,0	                        ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( _nVLiq 	                                     ,TAMSX3("D1_TOTAL")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( _nVFret 	                                     ,TAMSX3("D1_TOTAL")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( _nVBrut 	                                     ,TAMSX3("D1_TOTAL")[2]		,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( (_cAlias)->BZ_YCTREF 	                         ,5	 					    ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
			oExcel:AddCelula( iif( (_cAlias)->ESTRUT > 0, "Sim", "Não") 	 ,0	 					    ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)

			If MV_PAR03

				RecLock("ZCH",.T.)
				ZCH->ZCH_FILIAL := xFilial("ZCH")
				ZCH->ZCH_DATREF	:= Date()
				ZCH->ZCH_CODPRO	:= (_cAlias)->B1_COD
				ZCH->ZCH_GRPPRO	:= Substr((_cAlias)->B1_COD,1,3)
				ZCH->ZCH_DESPRO	:= (_cAlias)->B1_DESC
				ZCH->ZCH_QATU	:=	msSalEst
				ZCH->ZCH_CM1	:=	msCstEst/msSalEst
				ZCH->ZCH_DULENT	:=	_dUltEnt
				ZCH->ZCH_VULENT	:=	_nUltCus
				ZCH->ZCH_YCTREF	:=	(_cAlias)->BZ_YCTREF
				ZCH->ZCH_VERSAO :=	MV_PAR04
				ZCH->ZCH_REVISA	:=	MV_PAR05
				ZCH->ZCH_ANOREF	:=	MV_PAR06
				ZCH->ZCH_VLIQ	:=_nVLiq
				ZCH->ZCH_VFRET	:=_nVFret
				ZCH->ZCH_VBRUT	:=_nvBrut
				ZCH->(MsUnlock())

			EndIf

		EndIf

		IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		(_cAlias)->(DbSkip())

	EndDo

	fGeraParametros()
	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.)

	nRegAtu++
	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")

	(_cAlias)->(dbCloseArea())

Return

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
	aPergs[2,3] := cDirDest

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

Static Function fUltEnt(_cAlias,_cCusto,_cData,_cVBrut, _cVLiq, _cVFret)

	Local cNoCfCust := AllTrim(GetNewPar("MV_YCUSCFN","1911,2911,1910,2910"))

	A0001 := " SELECT ISNULL((SELECT SUM(SD1.D1_CUSTO) / SUM(SD1.D1_QUANT)
	A0001 += "                  FROM "+RetSqlName("SD1")+" SD1
	A0001 += "                 INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	A0001 += "                                      AND F4_CODIGO = D1_TES
	A0001 += "                                      AND F4_ESTOQUE = 'S'
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '
	A0001 += "                 INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = D1_FILIAL
	A0001 += "                                      AND F1_DOC = D1_DOC
	A0001 += "                                      AND F1_SERIE = D1_SERIE
	A0001 += "                                      AND F1_FORNECE = D1_FORNECE	
	A0001 += "                                      AND F1_LOJA = D1_LOJA
	A0001 += "                                      AND F1_EMISSAO = D1_EMISSAO
	A0001 += "                                      AND F1_STATUS <> 'B'
	A0001 += "                                      AND SF1.D_E_L_E_T_ = ' '
	A0001 += "                 WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'
	A0001 += "                   AND SD1.D1_COD = '"+(_cAlias)->B1_COD+"'
	A0001 += "                   AND SD1.D1_DTDIGIT <= '"+dtos(Date())+"'
	A0001 += "                   AND SD1.D1_TP <> 'PI'
	A0001 += "                   AND SD1.D1_TES NOT IN('3I7')
	A0001 += "                   AND SD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
	A0001 += "                   AND SD1.D1_DTDIGIT IN(SELECT MAX(XD1.D1_DTDIGIT)
	A0001 += "                                           FROM "+RetSqlName("SD1")+" XD1
	A0001 += "                                          INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	A0001 += "                                                               AND F4_CODIGO = D1_TES
	A0001 += "                                                               AND F4_ESTOQUE = 'S'
	A0001 += "                                                               AND SF4.D_E_L_E_T_ = ' '
	A0001 += "                                          INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = XD1.D1_FILIAL
	A0001 += "                                                               AND F1_DOC = XD1.D1_DOC
	A0001 += "                                                               AND F1_SERIE = XD1.D1_SERIE
	A0001 += "                                                               AND F1_FORNECE = XD1.D1_FORNECE	
	A0001 += "                                                               AND F1_LOJA = XD1.D1_LOJA
	A0001 += "                                                               AND F1_EMISSAO = XD1.D1_EMISSAO
	A0001 += "                                                               AND F1_STATUS <> 'B'
	A0001 += "                                                               AND SF1.D_E_L_E_T_ = ' '
	A0001 += "                                          WHERE XD1.D1_FILIAL = '"+xFilial("SD1")+"'
	A0001 += "                                            AND XD1.D1_COD = '"+(_cAlias)->B1_COD+"'
	A0001 += "                                            AND XD1.D1_TP <> 'PI'
	A0001 += "                                            AND XD1.D1_TES NOT IN('3I7')
	A0001 += "                                            AND XD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
	A0001 += "                                            AND XD1.D1_DTDIGIT <= '"+dtos(Date())+"'
	A0001 += "                                            AND XD1.D1_TIPO = 'N'
	A0001 += "                                            AND XD1.D1_QUANT <> 0
	A0001 += "                                            AND XD1.D_E_L_E_T_ = ' ')
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) EMP_ATU,
	A0001 += "         ISNULL((SELECT MAX(XD1.D1_DTDIGIT)
	A0001 += "                   FROM "+RetSqlName("SD1")+" XD1
	A0001 += "                  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	A0001 += "                                       AND F4_CODIGO = D1_TES
	A0001 += "                                       AND F4_ESTOQUE = 'S'
	A0001 += "                                       AND SF4.D_E_L_E_T_ = ' '
	A0001 += "                 INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = XD1.D1_FILIAL
	A0001 += "                                      AND F1_DOC = XD1.D1_DOC
	A0001 += "                                      AND F1_SERIE = XD1.D1_SERIE
	A0001 += "                                      AND F1_FORNECE = XD1.D1_FORNECE	
	A0001 += "                                      AND F1_LOJA = XD1.D1_LOJA
	A0001 += "                                      AND F1_EMISSAO = XD1.D1_EMISSAO
	A0001 += "                                      AND F1_STATUS <> 'B'
	A0001 += "                                      AND SF1.D_E_L_E_T_ = ' '
	A0001 += "                  WHERE XD1.D1_FILIAL = '"+xFilial("SD1")+"'
	A0001 += "                    AND XD1.D1_COD = '"+(_cAlias)->B1_COD+"'
	A0001 += "                    AND XD1.D1_DTDIGIT <= '"+dtos(Date())+"'
	A0001 += "                    AND XD1.D1_TP <> 'PI'
	A0001 += "                    AND XD1.D1_TES NOT IN('3I7')
	A0001 += "                    AND XD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
	A0001 += "                    AND XD1.D1_TIPO = 'N'
	A0001 += "                    AND XD1.D1_QUANT <> 0
	A0001 += "                    AND XD1.D_E_L_E_T_ = ' '), '        ') DT_E_ATU,
	A0001 += "			ISNULL((SELECT SUM(SD1.D1_TOTAL - SD1.D1_VALDESC) / SUM(SD1.D1_QUANT)
	A0001 += "                  FROM "+RetSqlName("SD1")+" SD1
	A0001 += "                 INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	A0001 += "                                      AND F4_CODIGO = D1_TES
	A0001 += "                                      AND F4_ESTOQUE = 'S'
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '
	A0001 += "                 INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = D1_FILIAL
	A0001 += "                                      AND F1_DOC = D1_DOC
	A0001 += "                                      AND F1_SERIE = D1_SERIE
	A0001 += "                                      AND F1_FORNECE = D1_FORNECE	
	A0001 += "                                      AND F1_LOJA = D1_LOJA
	A0001 += "                                      AND F1_EMISSAO = D1_EMISSAO
	A0001 += "                                      AND F1_STATUS <> 'B'
	A0001 += "                                      AND SF1.D_E_L_E_T_ = ' '
	A0001 += "                 WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'
	A0001 += "                   AND SD1.D1_COD = '"+(_cAlias)->B1_COD+"'
	A0001 += "                   AND SD1.D1_DTDIGIT <= '"+dtos(Date())+"'
	A0001 += "                   AND SD1.D1_TP <> 'PI'
	A0001 += "                   AND SD1.D1_TES NOT IN('3I7')
	A0001 += "                   AND SD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
	A0001 += "                   AND SD1.D1_DTDIGIT IN(SELECT MAX(XD1.D1_DTDIGIT)
	A0001 += "                                           FROM "+RetSqlName("SD1")+" XD1
	A0001 += "                                          INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	A0001 += "                                                               AND F4_CODIGO = D1_TES
	A0001 += "                                                               AND F4_ESTOQUE = 'S'
	A0001 += "                                                               AND SF4.D_E_L_E_T_ = ' '
	A0001 += "                                          INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = XD1.D1_FILIAL
	A0001 += "                                                               AND F1_DOC = XD1.D1_DOC
	A0001 += "                                                               AND F1_SERIE = XD1.D1_SERIE
	A0001 += "                                                               AND F1_FORNECE = XD1.D1_FORNECE	
	A0001 += "                                                               AND F1_LOJA = XD1.D1_LOJA
	A0001 += "                                                               AND F1_EMISSAO = XD1.D1_EMISSAO
	A0001 += "                                                               AND F1_STATUS <> 'B'
	A0001 += "                                                               AND SF1.D_E_L_E_T_ = ' '
	A0001 += "                                          WHERE XD1.D1_FILIAL = '"+xFilial("SD1")+"'
	A0001 += "                                            AND XD1.D1_COD = '"+(_cAlias)->B1_COD+"'
	A0001 += "                                            AND XD1.D1_TP <> 'PI'
	A0001 += "                                            AND XD1.D1_TES NOT IN('3I7')
	A0001 += "                                            AND XD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
	A0001 += "                                            AND XD1.D1_DTDIGIT <= '"+dtos(Date())+"'
	A0001 += "                                            AND XD1.D1_TIPO = 'N'
	A0001 += "                                            AND XD1.D1_QUANT <> 0
	A0001 += "                                            AND XD1.D_E_L_E_T_ = ' ')
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) VL_BRT,
	A0001 += "			ISNULL((SELECT SUM(SD1.D1_QUANT)
	A0001 += "                  FROM "+RetSqlName("SD1")+" SD1
	A0001 += "                 INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	A0001 += "                                      AND F4_CODIGO = D1_TES
	A0001 += "                                      AND F4_ESTOQUE = 'S'
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '
	A0001 += "                 INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = D1_FILIAL
	A0001 += "                                      AND F1_DOC = D1_DOC
	A0001 += "                                      AND F1_SERIE = D1_SERIE
	A0001 += "                                      AND F1_FORNECE = D1_FORNECE	
	A0001 += "                                      AND F1_LOJA = D1_LOJA
	A0001 += "                                      AND F1_EMISSAO = D1_EMISSAO
	A0001 += "                                      AND F1_STATUS <> 'B'
	A0001 += "                                      AND SF1.D_E_L_E_T_ = ' '
	A0001 += "                 WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'
	A0001 += "                   AND SD1.D1_COD = '"+(_cAlias)->B1_COD+"'
	A0001 += "                   AND SD1.D1_DTDIGIT <= '"+dtos(Date())+"'
	A0001 += "                   AND SD1.D1_TP <> 'PI'
	A0001 += "                   AND SD1.D1_TES NOT IN('3I7')
	A0001 += "                   AND SD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
	A0001 += "                   AND SD1.D1_DTDIGIT IN(SELECT MAX(XD1.D1_DTDIGIT)
	A0001 += "                                           FROM "+RetSqlName("SD1")+" XD1
	A0001 += "                                          INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	A0001 += "                                                               AND F4_CODIGO = D1_TES
	A0001 += "                                                               AND F4_ESTOQUE = 'S'
	A0001 += "                                                               AND SF4.D_E_L_E_T_ = ' '
	A0001 += "                                          INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = XD1.D1_FILIAL
	A0001 += "                                                               AND F1_DOC = XD1.D1_DOC
	A0001 += "                                                               AND F1_SERIE = XD1.D1_SERIE
	A0001 += "                                                               AND F1_FORNECE = XD1.D1_FORNECE	
	A0001 += "                                                               AND F1_LOJA = XD1.D1_LOJA
	A0001 += "                                                               AND F1_EMISSAO = XD1.D1_EMISSAO
	A0001 += "                                                               AND F1_STATUS <> 'B'
	A0001 += "                                                               AND SF1.D_E_L_E_T_ = ' '
	A0001 += "                                          WHERE XD1.D1_FILIAL = '"+xFilial("SD1")+"'
	A0001 += "                                            AND XD1.D1_COD = '"+(_cAlias)->B1_COD+"'
	A0001 += "                                            AND XD1.D1_TP <> 'PI'
	A0001 += "                                            AND XD1.D1_TES NOT IN('3I7')
	A0001 += "                                            AND XD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
	A0001 += "                                            AND XD1.D1_DTDIGIT <= '"+dtos(Date())+"'
	A0001 += "                                            AND XD1.D1_TIPO = 'N'
	A0001 += "                                            AND XD1.D1_QUANT <> 0
	A0001 += "                                            AND XD1.D_E_L_E_T_ = ' ')
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) QTD,
	A0001 += "			ISNULL((SELECT SUM(SD1.D1_TOTAL - SD1.D1_VALDESC) / SUM(SD1.D1_QUANT)
	A0001 += "                  FROM "+RetSqlName("SD1")+" SD1
	A0001 += "                 INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	A0001 += "                                      AND F4_CODIGO = D1_TES
	A0001 += "                                      AND F4_ESTOQUE = 'S'
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '
	A0001 += "                 INNER JOIN "+RetSqlName("SF1")+" SF1 ON F1_FILIAL = '"+xFilial("SF1")+"'
	A0001 += "                                      AND F1_DOC = D1_DOC
	A0001 += "                                      AND F1_SERIE = D1_SERIE
	A0001 += "                                      AND F1_FORNECE = D1_FORNECE
	A0001 += "                                      AND F1_LOJA = D1_LOJA
	A0001 += "                                      AND F1_ESPECIE <> 'CTE'
	A0001 += "                                      AND F1_STATUS <> 'B'
	A0001 += "                                      AND SF1.D_E_L_E_T_ = ''
	A0001 += "                 WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'
	A0001 += "                   AND SD1.D1_COD = '"+(_cAlias)->B1_COD+"'
	A0001 += "                   AND SD1.D1_DTDIGIT <= '"+dtos(Date())+"'
	A0001 += "                   AND SD1.D1_TP <> 'PI'
	A0001 += "                   AND SD1.D1_TES NOT IN('3I7')
	A0001 += "                   AND SD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
	A0001 += "                   AND SD1.D1_DTDIGIT IN(SELECT MAX(XD1.D1_DTDIGIT)
	A0001 += "                                           FROM "+RetSqlName("SD1")+" XD1
	A0001 += "                                          INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	A0001 += "                                                               AND F4_CODIGO = D1_TES
	A0001 += "                                                               AND F4_ESTOQUE = 'S'
	A0001 += "                                                               AND SF4.D_E_L_E_T_ = ' '
	A0001 += "                                          INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = XD1.D1_FILIAL
	A0001 += "                                                               AND F1_DOC = XD1.D1_DOC
	A0001 += "                                                               AND F1_SERIE = XD1.D1_SERIE
	A0001 += "                                                               AND F1_FORNECE = XD1.D1_FORNECE	
	A0001 += "                                                               AND F1_LOJA = XD1.D1_LOJA
	A0001 += "                                                               AND F1_EMISSAO = XD1.D1_EMISSAO
	A0001 += "                                                               AND F1_STATUS <> 'B'
	A0001 += "                                                               AND SF1.D_E_L_E_T_ = ' '
	A0001 += "                                          WHERE XD1.D1_FILIAL = '"+xFilial("SD1")+"'
	A0001 += "                                            AND XD1.D1_COD = '"+(_cAlias)->B1_COD+"'
	A0001 += "                                            AND XD1.D1_TP <> 'PI'
	A0001 += "                                            AND XD1.D1_TES NOT IN('3I7')
	A0001 += "                                            AND XD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
	A0001 += "                                            AND XD1.D1_DTDIGIT <= '"+dtos(Date())+"'
	A0001 += "                                            AND XD1.D1_TIPO = 'N'
	A0001 += "                                            AND XD1.D1_QUANT <> 0
	A0001 += "                                            AND XD1.D_E_L_E_T_ = ' ')
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) VL_LIQ,
	A0001 += "			ISNULL((SELECT SUM(SD1.D1_TOTAL - SD1.D1_VALDESC)
	A0001 += "                  FROM "+RetSqlName("SD1")+" SD1
	A0001 += "                 INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	A0001 += "                                      AND F4_CODIGO = D1_TES
	A0001 += "                                      AND F4_ESTOQUE = 'S'
	A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '
	A0001 += "                 INNER JOIN "+RetSqlName("SF1")+" SF1 ON F1_FILIAL = '"+xFilial("SF1")+"'
	A0001 += "                                      AND F1_DOC = D1_DOC
	A0001 += "                                      AND F1_SERIE = D1_SERIE
	A0001 += "                                      AND F1_FORNECE = D1_FORNECE
	A0001 += "                                      AND F1_LOJA = D1_LOJA
	A0001 += "                                      AND F1_ESPECIE = 'CTE'
	A0001 += "                                      AND F1_STATUS <> 'B'
	A0001 += "                                      AND SF1.D_E_L_E_T_ = ''
	A0001 += "                 WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'
	A0001 += "                   AND SD1.D1_COD = '"+(_cAlias)->B1_COD+"'
	A0001 += "                   AND SD1.D1_DTDIGIT <= '"+dtos(Date())+"'
	A0001 += "                   AND SD1.D1_TP <> 'PI'
	A0001 += "                   AND SD1.D1_TES NOT IN('3I7')
	A0001 += "                   AND SD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
	A0001 += "                   AND SD1.D1_DTDIGIT IN(SELECT MAX(XD1.D1_DTDIGIT)
	A0001 += "                                           FROM "+RetSqlName("SD1")+" XD1
	A0001 += "                                          INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
	A0001 += "                                                               AND F4_CODIGO = D1_TES
	A0001 += "                                                               AND F4_ESTOQUE = 'S'
	A0001 += "                                                               AND SF4.D_E_L_E_T_ = ' '
	A0001 += "                                          INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = XD1.D1_FILIAL
	A0001 += "                                                               AND F1_DOC = XD1.D1_DOC
	A0001 += "                                                               AND F1_SERIE = XD1.D1_SERIE
	A0001 += "                                                               AND F1_FORNECE = XD1.D1_FORNECE	
	A0001 += "                                                               AND F1_LOJA = XD1.D1_LOJA
	A0001 += "                                                               AND F1_EMISSAO = XD1.D1_EMISSAO
	A0001 += "                                                               AND F1_STATUS <> 'B'
	A0001 += "                                                               AND SF1.D_E_L_E_T_ = ' '
	A0001 += "                                          WHERE XD1.D1_FILIAL = '"+xFilial("SD1")+"'
	A0001 += "                                            AND XD1.D1_COD = '"+(_cAlias)->B1_COD+"'
	A0001 += "                                            AND XD1.D1_TP <> 'PI'
	A0001 += "                                            AND XD1.D1_TES NOT IN('3I7')
	A0001 += "                                            AND XD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
	A0001 += "                                            AND XD1.D1_DTDIGIT <= '"+dtos(Date())+"'
	A0001 += "                                            AND XD1.D1_TIPO = 'N'
	A0001 += "                                            AND XD1.D1_QUANT <> 0
	A0001 += "                                            AND XD1.D_E_L_E_T_ = ' ')
	A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) VL_FRET
	TcQuery A0001 ALIAS "A001" NEW
	dbSelectArea("A001")
	dbGoTop()
	_cCusto  := A001->EMP_ATU
	_cData := stod(A001->DT_E_ATU)
	_cVBrut	:=	A001->VL_BRT
	_cVLiq	:=	A001->VL_LIQ
	_cVFret	:=	Iif(A001->QTD > 0 ,A001->VL_FRET / A001->QTD,0)
	A001->(dbCloseArea())

Return

User Function BFG058OK()

	Local _lRet	:= .T.	
	Local msrhEnter := CHR(13) + CHR(10)

	Local _cAlias	:=	GetNextAlias()

	Local xfMensCompl := ""
	xfMensCompl += "Tipo Orçamento igual C.VARIAVEL" + msrhEnter
	xfMensCompl += "Status igual Aberto" + msrhEnter
	xfMensCompl += "Data Digitação diferente de branco" + msrhEnter
	xfMensCompl += "Data Encerramento igual branco"


	If MV_PAR03

		_lRet	:=	MSGYESNO("Atenção!"+CHR(13)+" Ao marcar esse parâmetro os dados referentes ao orçamento serão excluídos da base e reinseridos! "+CHR(13)+" Deseja Prosseguir?")

		If _lRet

			BEGINSQL Alias _cAlias
				SELECT COUNT(*) QTD
				FROM %TABLE:ZB5% ZB5
				WHERE ZB5.ZB5_FILIAL = %XFILIAL:ZB5%
				AND ZB5.ZB5_VERSAO = %EXP:MV_PAR04%
				AND ZB5.ZB5_REVISA = %Exp:MV_PAR05%
				AND ZB5.ZB5_ANOREF = %Exp:MV_PAR06%
				AND ZB5_STATUS = 'A'
				AND ZB5_DTDIGT <> ''
				AND ZB5.ZB5_TPORCT = 'C.VARIAVEL'
				AND ZB5.ZB5_DTENCR = ''
				AND ZB5_DTCONS <= %Exp:dDataBase%

			EndSql

			If (_cAlias)->QTD = 0
				MsgALERT("A versão informada não está ativa para execução deste processo." + msrhEnter + msrhEnter + "Favor verificar o preenchimento dos campos no tabela de controle de versão conforme abaixo:" + msrhEnter + msrhEnter + xfMensCompl + msrhEnter + msrhEnter + "Favor verificar com o responsável pelo processo Orçamentário!!!")
				_lRet	:=	.F.
			EndIf

			(_cAlias)->(DbCloseArea())
		EndIf
	EndIf

Return _lRet
