#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG082
@author Gabriel Rossi Mafioletti
@since 22/03/2019
@version 1.0
@description Relatório Kardex Resumido - Novo
@type function
/*/

User Function BIAFG082()

	private aPergs := {}
	Private oExcel      := nil 
	private cDirDest    := space(170)
	
	If !ValidPerg()
		Return
	EndIf

	Processa({|| fExcel()})

RETURN


Static Function ValidPerg()

	local cLoad	    := "BIAFG082" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	
	MV_PAR01	:=	Space(4)
	MV_PAR02	:=	1
	MV_PAR03	:=	12
	MV_PAR04	:=	Space(2)
	MV_PAR05	:=	Space(2)
	MV_PAR06	:=	Space(4)
	MV_PAR07	:=	Space(4)
	MV_PAR08	:=	Space(15)
	MV_PAR09	:=	Space(15)
	MV_PAR10	:=	Space(170)
	
	
	aAdd( aPergs ,{1,"Ano?      ",MV_PAR01 ,"@E 9999"  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Mês De?     ",MV_PAR02 ,"@E 99"  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Mês Até?     ",MV_PAR03 ,"@E 99"  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Tipo De?     ",MV_PAR04 ,""  ,"",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Tipo Até?     ",MV_PAR05 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Grupo De?     ",MV_PAR06 ,""  ,"",'SBM'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Grupo Até?     ",MV_PAR07 ,""  ,"NAOVAZIO()",'SBM'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Produto De?     ",MV_PAR08 ,""  ,"",'SB1'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Produto Até?     ",MV_PAR09 ,""  ,"NAOVAZIO()",'SB1'  ,'.T.',50,.F.})
	aAdd( aPergs ,{6,"Pasta Destino?",MV_PAR10 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )
	

	If ParamBox(aPergs ,"Kardex Resumido",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 	:= ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 	:= ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 	:= ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 	:= ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 	:= ParamLoad(cFileName,,5,MV_PAR05)
		MV_PAR06 	:= ParamLoad(cFileName,,6,MV_PAR06)
		MV_PAR07 	:= ParamLoad(cFileName,,7,MV_PAR07)
		MV_PAR08 	:= ParamLoad(cFileName,,8,MV_PAR08)
		MV_PAR09 	:= ParamLoad(cFileName,,9,MV_PAR09)
		MV_PAR010 	:= ParamLoad(cFileName,,10,MV_PAR10)

		if empty(MV_PAR10) 
			MV_PAR10 := AllTrim(GetTempPath()) 	
		endif
		
		cDirDest	:=	MV_PAR10

	EndIf

Return lRet


Static Function fExcel()


	Local _nI
	Local _cParc
	local cArqXML   := "BIAFG082_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
	
	
	oExcel := ARSexcel():New()

	
	IF MV_PAR02 < 1
		MV_PAR02 := 1
	EndIf
	
	If MV_PAR03 > 12
		MV_PAR03	:=	12
	EndIf
	
	If MV_PAR03 < MV_PAR02
		_cParc	:=	MV_PAR02
		MV_PAR02	:=	MV_PAR03
		MV_PAR03	:=	_cParc
	EndIf
	
	For _nI	:=	MV_PAR02 TO MV_PAR03
	
		fQryDados(_nI)
	
	Next

	fGeraParametros()
	oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 


Return


Static Function fQryDados(_nMes)

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

    
   
    Local _cCompet	:=	MV_PAR01 + PADL(Alltrim(Str(_nMes)),2,"0")
   
    
 
	BeginSql Alias _cAlias

		%NoParser%
		EXEC SP_KARDEX_RESUMIDO %Exp:_cCompet%,%Exp:MV_PAR04%,%Exp:MV_PAR05%,%Exp:MV_PAR06%,%Exp:MV_PAR07%,%Exp:MV_PAR08%,%Exp:MV_PAR09%

	EndSql

	(_cAlias)->(DbGoTop())
	Count To nTotReg 
	if nTotReg < 1
		return
	endif
	(_cAlias)->(dbGoTop())
	ProcRegua(nTotReg + 2)

	nRegAtu++
	IncProc("Gerando Relatorio - Período: "+ Alltrim(_cCompet) +" - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	


	oExcel:AddPlanilha("Periodo - "+Alltrim(_cCompet),{21,35,450,21,27,68,68,68,68,68,68,68,68,68,68,68,68,68,68,68,68,68,68,68,68,68,68,68},6)

	oExcel:AddLinha(20)
	oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,33) 
	oExcel:AddLinha(15)
	oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,33) 
	oExcel:AddLinha(15)
	oExcel:AddLinha(20)
	oExcel:AddCelula("Kardex Resumido ",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,33)  

	oExcel:AddLinha(20)

	oExcel:AddLinha(20)
	oExcel:AddCelula("Dados do Produto ",0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,9)
	oExcel:AddCelula("Saldos Iniciais ",0,'C',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,12,2)
	oExcel:AddCelula("Notas Fiscais - Entradas ",0,'C',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,15,2)
	oExcel:AddCelula("Notas Fiscais - Saídas ",0,'C',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,18,2)
	oExcel:AddCelula("Produções ",0,'C',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,21,2)
	oExcel:AddCelula("Mov. Internos - Entradas ",0,'C',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,24,2)
	oExcel:AddCelula("Mov. Internos - Saídas ",0,'C',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,27,2)
	oExcel:AddCelula("Saldos Finais ",0,'C',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,30,2)
	oExcel:AddCelula("Saldos Fechamento ",0,'C',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,33,2)

	oExcel:AddLinha(12) 


	oExcel:AddCelula()
	oExcel:AddCelula("Período"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Produto"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Descrição"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Tipo"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Grupo"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Formato"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Descrição"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Acabamento"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Base"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Espessura"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Sald. Inic."			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo Inic."	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Unit. Inic."	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Saldo Entradas"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo Entradas"	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Unit. Entradas"	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Saldo Saídas"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo Saídas"	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Unit. Saídas"	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Saldo Prod."			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo Prod."	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Unit. Prod."	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Saldo Mv. Ent."			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo Mv. Ent."	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Unit. Mv. Ent."	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Saldo Mv. Sai."			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo Mv. Sai."	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Unit. Mv. Sai."	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)	
	oExcel:AddCelula("Saldo Final"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo Final"	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Unit. Final"	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Saldo Fecham."			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Custo Fecham."	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	oExcel:AddCelula("Unit. Fecham."	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

	While (_cAlias)->(!EOF())

		nRegAtu++

		if MOD(nRegAtu,2) > 0 
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif

		oExcel:AddLinha(14) 
		oExcel:AddCelula()


		oExcel:AddCelula(_cCompet		,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->B1_COD		,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(Alltrim((_cAlias)->B1_DESC),0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->B1_TIPO		,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->B1_GRUPO	,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->B1_YFORMAT	,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula(POSICIONE("ZZ6",1,xFilial("ZZ6")+(_cAlias)->B1_YFORMAT,"ZZ6_DESC")	,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->B1_YACABAM	,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->B1_YBASE	,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->B1_YESPESS	,0	,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->SINI		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CINI		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->UINI		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->SNFE		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CNFE		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->UNFE		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->SNFS		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CNFS		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->UNFS		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->SMOV_P		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CMOV_P		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->UMOV_P		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->SMOV_E		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CMOV_E		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->UMOV_E		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->SMOV_S		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CMOV_S		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->UMOV_S		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->SFIN		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CFIN		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->UFIN		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->SFECH		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->CFECH		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
		oExcel:AddCelula((_cAlias)->UFECH		,8	,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)			

		IncProc("Gerando Relatorio - Período "+ Alltrim(_cCompet) +" - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")

		(_cAlias)->(DbSkip())

	EndDo

	nRegAtu++
	IncProc("Gerando Relatorio - Período: "+Alltrim(_cCompet) +" - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")

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
	aPergs[3,3] := MV_PAR03
	aPergs[4,3] := MV_PAR04 
	aPergs[5,3] := MV_PAR05
	aPergs[6,3] := MV_PAR06
	aPergs[7,3] := MV_PAR07
	aPergs[8,3] := MV_PAR08
	aPergs[9,3] := MV_PAR09
	aPergs[10,3] := cDirDest     


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