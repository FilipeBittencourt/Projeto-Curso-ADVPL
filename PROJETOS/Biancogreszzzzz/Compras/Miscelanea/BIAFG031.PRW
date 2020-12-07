#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG031
@author Gabriel Rossi Mafioletti
@since 30/01/2018
@version 1.0
@description MRP - Montagem de Cargas
@type function
/*/

User Function BIAFG031()

	Local _bKeys	:=	Setkey(VK_F5,{|| U_BFG31KF5()})
	Local _lRet		:=	.T.

	If !ValidPerg()
		Return
	EndIf

	Private oDlgMRP		:=	Nil		//Dialog
	Private oGpMRP1		:=	Nil		//Grupo
	Private oGpMRP1GR	:=	Nil		//Grupo Grafico
	
	Private oSyDsCar	:=	Nil
	Private cSyDsCar	:=	SPACE(250)
	Private	oFntMRP		:=	TFont():New("Arial",,022,,.T.,,,,,.F.,.F.)

	
	Private oGdEst		:=	Nil		//GetDados Estados
	Private oGdTran		:=	Nil		//Getdados de Transportadoras
	Private	oGdCar		:=	Nil		//Getdados de Cargas
	Private oGdPed		:=	Nil		//Getdados de Pedidos
	
	Private aSize := MsAdvSize(.F.) //Sem Enchoice
	
	Private _cTabTemp	:=	'##TMP_ARQTRABTMP_MRP_CARGA_' + cEmpAnt + __cUserID + strzero(seconds()*3500,10)

	Private _cVarTab	:=	"%" + _cTabTemp + "%"

	DbSelectArea("SX6")
	If !ExisteSX6("ES_CDCARGA")
		CriarSX6("ES_CDCARGA", 'C', 'Controle de numeração de cargas MRP', "000000" )
	EndIf

	//Objeto Geral
	aObjects := {}

	AAdd( aObjects, { 100, 185, .T., .T. } )
	AAdd( aObjects, { 100, 215, .T., .T. } )
	AAdd( aObjects, { 100, 025, .T., .F. } )
	
	aInfo1   := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }

	aPosObj1 := MsObjSize( aInfo1, aObjects, .T. )

	//Objeto 2
	aObjects := {}
	
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aSize2 := aClone( aPosObj1[1] )
	aInfo2   := { aSize2[2], aSize2[1], aSize2[4], aSize2[3], 3, 3 }
	aPosObj2 := MsObjSize( aInfo2, aObjects, ,.T. )	
	
	//Gera Arquivo De Trabalho
	fGeraTab()
	
	DEFINE MSDIALOG oDlgMRP TITLE "MRP - Cargas" FROM aSize[7], aSize[7] TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL
	
		// Painel Pedidos
		@ aPosObj1[2][1], aPosObj1[2][2] GROUP oGpMRP1 TO aPosObj1[2][3], aPosObj1[2][4] PROMPT "Pedidos..." OF oDlgMRP COLOR 0, 16777215 PIXEL
		U_BIAMsgRun("Aguarde... Carregando dados (Pedidos)",,{|| fGeraPed() })

		// Painel Cargas

		@ aPosObj2[3][1], aPosObj2[3][2] GROUP oGpMRP12 TO aPosObj2[3][3], aPosObj2[3][4] PROMPT "Cargas..." OF oDlgMRP COLOR 0, 16777215 PIXEL
		U_BIAMsgRun("Aguarde... Carregando dados (Cargas)",,{|| fGeraCar() })

		// Painel Transportadoras
		@ aPosObj2[2][1], aPosObj2[2][2] GROUP oGpMRP1 TO aPosObj2[2][3], aPosObj2[2][4] PROMPT "Transportadoras..." OF oDlgMRP COLOR 0, 16777215 PIXEL
		U_BIAMsgRun("Aguarde... Carregando dados (Transportadoras)",,{|| fGeraTran() })
		
		// Painel Estados
		@ aPosObj2[1][1], aPosObj2[1][2] GROUP oGpMRP1 TO aPosObj2[1][3], aPosObj2[1][4] PROMPT "Estados..." OF oDlgMRP COLOR 0, 16777215 PIXEL
		U_BIAMsgRun("Aguarde... Carregando dados (Estado)",,{|| fGeraEst(@_lRet) })
		
		If !_lRet
			MsgInfo("Não Existem dados para os parâmetros passados!")
			Setkey(VK_F5,_bKeys)
			Return
		EndIf
		

		@ aPosObj1[3][1], aPosObj1[3][2] GROUP oGpMRP1 TO aPosObj1[3][3], aPosObj1[3][4] PROMPT "Informações da Carga" OF oDlgMRP COLOR 0, 16777215 PIXEL
		@ aPosObj1[3][1]+10, aPosObj1[3][2]+05 SAY oSyDsCar PROMPT cSyDsCar SIZE 446, 011 OF oDlgMRP FONT oFntMRP COLORS 0, 16777215 PIXEL
		
		@ aPosObj1[3][1]+08, aPosObj1[3][4]-040 BUTTON oBt1CockSim PROMPT "Cancelar" SIZE 037, 012 OF oDlgMRP ACTION (cj_Fecha := .F., fh_Esc := .T., oDlgMRP:End()) PIXEL
		@ aPosObj1[3][1]+08, aPosObj1[3][4]-103 BUTTON oBt2CockSim PROMPT "Gravar Cargas"   SIZE 060, 012 OF oDlgMRP ACTION Processa({|| fGrava() }) PIXEL

	
	ACTIVATE MSDIALOG oDlgMRP CENTERED

	Setkey(VK_F5,_bKeys)

Return

Static Function fGeraTab()

	Local _cSql	:=	""

	Local _nI
	
	Local cInGrp	:= ""
	Local _cInLocal	:=	""
	
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
	
	For _nI	:=	1 to Len(MV_PAR04) STEP 2
		If Substr(MV_PAR04,_nI,2) <> '**'
			_cInLocal +=	"'" + Substr(MV_PAR04,_nI,2) + "',"
		EndIf
	Next
	If Empty(_cInLocal)
		_cInLocal	:=	"()"
	Else
		_cInLocal	:=	"(" + Substr(_cInLocal,1,Len(_cInLocal)-1) + ")"
	End
	

	_cSql	:=	"	SELECT SC7.R_E_C_N_O_ ID	" +CRLF 
	_cSql	+=	"		,C7_NUM	PEDIDO" +CRLF 
	_cSql	+=	"		,C7_DATPRF	ENTREGA" +CRLF 
	_cSql	+=	"		,A2_EST	 UF	" +CRLF 
	_cSql	+=	"		,X5_DESCRI	DESUF	" +CRLF 
	_cSql	+=	"		,C7_YTRANSP	 TRANSP " +CRLF 
	_cSql	+=	"		,A4_NOME	 NMTRAN " +CRLF 
	_cSql	+=	"		,C7_FORNECE	FORNECE" +CRLF 
	_cSql	+=	"		,C7_LOJA	LOJA 	" +CRLF 
	_cSql	+=	"		,A2_NOME	NOMFOR " +CRLF 
	_cSql	+=	"		,C7_ITEM	ITEM " +CRLF 
	_cSql	+=	"		,C7_PRODUTO	 PRODUTO " +CRLF 
	_cSql	+=	"		,C7_LOCAL	 LOCAL " +CRLF
	_cSql	+=	"		,B1_DESC	 DESPRO " +CRLF 
	_cSql	+=	"		,C7_QUANT	 QUANT " +CRLF 
	_cSql	+=	"		,CAST('' AS VARCHAR(6)) AS CARGA	" +CRLF 
	_cSql	+=	"		,CAST('' AS VARCHAR(8)) AS DTCARGA	" +CRLF 
	_cSql	+=	"		INTO " + _cTabTemp +CRLF
	_cSql	+=	"	FROM "+RETSQLNAME("SC7")+" SC7 WITH (NOLOCK)	" +CRLF 
	_cSql	+=	"	JOIN "+RETSQLNAME("SB1")+" SB1 WITH (NOLOCK) ON SB1.B1_COD = SC7.C7_PRODUTO	" +CRLF 
	_cSql	+=	"		AND SB1.B1_GRUPO IN " + cInGrp + "	" + CRLF
	_cSql	+=	"		AND SB1.B1_MSBLQL <> '1'	" +CRLF 
	_cSql	+=	"		AND SB1.D_E_L_E_T_ = ''	" +CRLF 
	_cSql	+=	"	JOIN "+RETSQLNAME("SBZ")+" SBZ WITH (NOLOCK) ON SBZ.BZ_FILIAL = " +	ValtoSql(xFilial("SBZ")) +	" " +CRLF 
	_cSql	+=	"		AND SBZ.BZ_COD = SB1.B1_COD	" +CRLF 
	_cSql	+=	"		AND SBZ.BZ_YBLSCPC <> '1'	" +CRLF 
	_cSql	+=	"		AND SBZ.BZ_YPOLIT = '2'	" +CRLF 
	_cSql	+=	"		AND SBZ.D_E_L_E_T_ = ' '	" +CRLF 
	_cSql	+=	"	JOIN "+RETSQLNAME("SA2")+" SA2 WITH (NOLOCK) ON SA2.A2_COD = SC7.C7_FORNECE	" +CRLF 
	_cSql	+=	"		AND SA2.A2_LOJA = SC7.C7_LOJA	" +CRLF 
	_cSql	+=	"		AND SA2.A2_MSBLQL <> '1'	" +CRLF 
	_cSql	+=	"		AND SA2.D_E_L_E_T_ = ''	" +CRLF 
	_cSql	+=	"	JOIN "+RETSQLNAME("SA4")+" SA4 WITH (NOLOCK) ON SA4.A4_COD = SC7.C7_YTRANSP	" +CRLF 
	_cSql	+=	"		AND SA4.A4_MSBLQL <> '1'	" +CRLF 
	_cSql	+=	"		AND SA4.D_E_L_E_T_ = ''	" +CRLF 
	_cSql	+=	"	JOIN "+RETSQLNAME("SX5")+" SX5 WITH (NOLOCK) ON SX5.X5_TABELA = '12'	" +CRLF 
	_cSql	+=	"		AND SA2.A2_EST = SX5.X5_CHAVE	" +CRLF 
	_cSql	+=	"		AND SX5.D_E_L_E_T_ = ''	" +CRLF 
	_cSql	+=	"	WHERE SC7.C7_DATPRF BETWEEN " + ValtoSql(MV_PAR02) + " AND " + ValtoSql(MV_PAR03) + "	" + CRLF
	_cSql	+=	"		AND SC7.C7_FILIAL =	" +	ValtoSql(xFilial("SC7")) +" 	" + CRLF
	_cSql	+=	"		AND SC7.C7_YTOTEST NOT IN (	" +CRLF 
	_cSql	+=	"			'T'	" +CRLF 
	_cSql	+=	"			,'P'	" +CRLF 
	_cSql	+=	"			)	" +CRLF 
	_cSql	+=	"		AND SC7.C7_QUANT - C7_QUJE <> 0	" +CRLF 
	_cSql	+=	"		AND SC7.C7_RESIDUO = ' '	" +CRLF 
	_cSql	+=	"		AND SC7.C7_CONAPRO = 'L'	" +CRLF 
	_cSql	+=	"		AND SC7.C7_YTRANSP <> ''	" +CRLF 
	_cSql	+=	"		AND SC7.C7_YCARGA = ''	" +CRLF 
	_cSql	+=	"		AND SC7.C7_LOCAL IN "+_cInLocal+"	" +CRLF
	_cSql	+=	"		AND SC7.D_E_L_E_T_ = ''	" +CRLF 
	_cSql	+=	"		ORDER BY C7_DATPRF, A2_NOME"

	TcSqlExec(_cSql)

Return


Static Function ValidPerg()

	local cLoad	    := "BIAFG031" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}
	
	
	MV_PAR01 :=	Space(200)
	MV_PAR02 := STOD('') 
	MV_PAR03 := STOD('') 
	MV_PAR04 :=	Space(200)
	
	aAdd( aPergs ,{1,"Grupo(s) " 		  	,MV_PAR01 ,""  ,"U_BIAFG31G()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Data De " 		   		,MV_PAR02 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Data Ate " 		   		,MV_PAR03 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Armazém(s) " 		  	,MV_PAR04 ,""  ,"U_B773Loc()",''  ,'.T.',50,.F.})		
	
	If ParamBox(aPergs ,"MRP - Cargas",,,,,,,,cLoad,.T.,.T.)
	
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
	
	EndIf
	
Return lRet


User Function BIAFG31G()

	Local _aArea	:=	GetArea()
	Local _aGrupos	:=	{}
	Local MvPar
	Local MvParDef	:=	""
	Local lRet		:= .F.
	Local _nTamKey	:= 0
	Local _nElemen	:= 0
	
	DbSelectArea("SBM")
	SBM->(DbSetOrder(1))
	SBM->(DbGoTop())

	MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

	While SBM->(!EOF())
//		If SUBSTR(SBM->BM_GRUPO,1,3) $ "102/104"
			If aScan(_aGrupos,{|x| x == Alltrim(SBM->BM_GRUPO) + ' - ' + Alltrim(SBM->BM_DESC)}) == 0
				aAdd(_aGrupos,Alltrim(SBM->BM_GRUPO) + ' - ' + Alltrim(SBM->BM_DESC))
				MvParDef	+=	SBM->BM_GRUPO
				_nElemen++
			EndIf
//		EndIf
		SBM->(DbSkip())
	EndDo

	_nTamKey	:=	Len(MVPARDEF)
	

	If f_Opcoes(@MvPar,"Seleção de Grupos",_aGrupos,MvParDef,,,.F.,4,_nElemen)
		lRet	:= .T.
		&MvRet := mvpar 	
	EndIf
	RestArea(_aArea)
Return lRet

Static Function fGeraEst(_lRet)

	Local	aHeader	:=	{}
	Local	aCols	:=	{}
	Local 	_cAlias	:=	GetNextAlias()
	Local _lRet	:=	.T.

	aAdd(aHeader,{"UF"       		,"UF" ,"@!"               , 2   , 0,,, "C",, })      	// 2
	aAdd(aHeader,{"Descrição"       		,"DESCRI" ,"@S25"               , 40   , 0,,, "C",, })      	// 3
	

	BeginSql Alias _cAlias
		SELECT DISTINCT UF, DESUF
			FROM %Exp:_cVarTab%
	EndSql
	
	If (_cAlias)->(!EOF())
		While (_cAlias)->(!EOF())
			aAdd(aCols,{(_cAlias)->UF,(_cAlias)->DESUF,.F.})
			(_cAlias)->(DbSkip())
		EndDo
	Else
		_lRet	:=	.F.
		Return 
	EndIF
	
	oGdEst	:=	MsNewGetDados():New( aPosObj2[1][1] + 10, aPosObj2[1][2] + 5, aPosObj2[1][3] - 5, aPosObj2[1][4] - 5, 0, "AllwaysTrue", "AllwaysTrue", "", {},, 999, /*'U_BG028FOK()'*/, "AllWaysTrue", "", oDlgMRP, aHeader, aCols, { || fChgEst() } )

	(_cAlias)->(DbCloseArea())
Return 

Static Function fGeraTran()

	Local	aHeader	:=	{}
	Local	aCols	:=	{}


	aAdd(aHeader,{"Transp."       		,"CODIGO" ,"@!"               , 6   , 0,,, "C",, })      	// 2
	aAdd(aHeader,{"Descrição"       		,"DESCRI" ,"@S25"               , 40   , 0,,, "C",, })      	// 3
	

	oGdTran	:=	MsNewGetDados():New( aPosObj2[2][1] + 10, aPosObj2[2][2] + 5, aPosObj2[2][3] - 5, aPosObj2[2][4] - 5, 0, "AllwaysTrue", "AllwaysTrue", "", {},, 999, /*'U_BG028FOK()'*/, "AllWaysTrue", "", oDlgMRP, aHeader, aCols, { || fChgTran() } )

	
Return

Static Function fGeraCar()

	Local	aHeader	:=	{}
	Local	aCols	:=	{}

	Aadd(aHeader,{" "			 ,"STATUS","@BMP", 2, 0, ".F." ,""    , "C", "", "V" ,"" , "","","V"})
	aAdd(aHeader,{"Carga"       		,"CODIGO" ,"@!"               , 6   , 0,,, "C",,,, })      	// 2
	aAdd(aHeader,{"Quant."    	 	 ,"QUANT" ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      	// 6
	aAdd(aHeader,{"Dt. Entr."        ,"DATPRF" ,"@!"               , 8   , 0,,, "D",,,,Stod("") })      	// 3

	oGdCar	:=	MsNewGetDados():New( aPosObj2[3][1] + 10, aPosObj2[3][2] + 5, aPosObj2[3][3] , aPosObj2[3][4] , GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", {"DATPRF"},, 999, 'U_BFG31FOK()', "AllWaysTrue", "", oDlgMRP, aHeader, aCols, { || fChgCrg() } )

	oGdCar:oBrowse:bLDblClick	:=	{|| oGdCar:EditCell(),U_BFG31RCR()}
	
Return

Static Function fGeraPed()

	Local	aHeader	:=	{}
	Local	aCols	:=	{}


	Aadd(aHeader,{" "			 ,"STATUS","@BMP", 2, 0, ".F." ,""    , "C", "", "V" ,"" , "","","V"})
	aAdd(aHeader,{"Entrega"    	 	,"ENTREG" , "@!" , 8   , 0,,, "D",, })  
	aAdd(aHeader,{"UF"    	 	 	,"UF" , "@!" , 2   , 0,,, "C",, })  
	aAdd(aHeader,{"Descricão"    	,"DESUF" , "@S25" , 40   , 0,,, "C",, })  
	aAdd(aHeader,{"Fornec."       	,"CDFOR" ,"@!"               , 6   , 0,,, "C",, }) 
	aAdd(aHeader,{"Loja"       		,"LJFOR" ,"@!"               , 6   , 0,,, "C",, }) 
	aAdd(aHeader,{"Descrição"       ,"DESFOR" ,"@S25"               , 40   , 0,,, "C",, })
	aAdd(aHeader,{"Pedido"       ,"PEDIDO" ,"@!"               , 6  , 0,,, "C",, })
	aAdd(aHeader,{"Item"       		,"ITEM" ,"@!"               , 4   , 0,,, "C",, })
	aAdd(aHeader,{"Produto"       	,"CDPRO" ,"@!"               , 15   , 0,,, "C",, })
	aAdd(aHeader,{"Descrição"       ,"DESPRO" ,"@S25"               , 40   , 0,,, "C",, })
	aAdd(aHeader,{"Local"       	,"LOCPRD" ,"@!"               , 2   , 0,,, "C",, })
	aAdd(aHeader,{"Quant."       	,"QUANT" ,"@E 999,999.99"               , 9   , 2,,, "N",, })
	aAdd(aHeader,{"Carga"       	,"CARGA" ,"@!"               , 6   , 0,,, "C",, })
	aAdd(aHeader,{"Dt. Carga"    	 	,"DTCARGA" , "@!" , 8   , 0,,, "D",, })  
	aAdd(aHeader,{"ID"       		,"ID" ,"@!"               , 10   , 0,,, "N",,,, })      	// 2
	
	
	oGdPed	:=	MsNewGetDados():New( aPosObj1[2][1] + 10, aPosObj1[2][2] + 5, aPosObj1[2][3] , aPosObj1[2][4] , 0, "AllwaysTrue", "AllwaysTrue", "", {},, 999, /*'U_BG028FOK()'*/, "AllWaysTrue", "", oDlgMRP, aHeader, aCols, { ||  } )

	oGdPed:oBrowse:bLDblClick	:=	{|| U_BFG31PED()}
	
Return

Static Function fPopPed()

	Local 	aCols		:=	{}
	Local 	_cAlias		:=	GetNextAlias()
	Local	_nPosUF		:=	aScan(oGdEst:aHeader,{|x| Alltrim(x[2] == "UF")})
	Local	_cUf		:=	oGdEst:aCols[oGdEst:nAt,_nPosUF]
	Local 	_nPosTrans	:=	aScan(oGdTran:aHeader,{|x| Alltrim(x[2] == "CODIGO")})
	Local	_cTrans		:=	oGdTran:aCols[oGdTran:nAt,_nPosTrans]
	Local 	_nPosCar	:=	aScan(oGdCar:aHeader,{|x| Alltrim(x[2] == "CODIGO")})
	Local	_cCarga		:=	oGdCar:aCols[oGdCar:nAt,_nPosCar]	
	Local	_nqtdCar	:=	0
	
	BeginSql Alias _cAlias
		SELECT *
			FROM %Exp:_cVarTab%
			WHERE UF = %Exp:_cUf%
				AND TRANSP = %Exp:_cTrans%
	EndSql
	
	If (_cAlias)->(!EOF())
		oGdPed:Show()
		While (_cAlias)->(!EOF())
			aAdd(aCols,{;
				Iif(Empty((_cAlias)->CARGA),"BR_VERMELHO",Iif((_cAlias)->CARGA == _cCarga,"BR_VERDE","BR_AMARELO")),;
				Stod((_cAlias)->ENTREGA),;
				(_cAlias)->UF,;
				(_cAlias)->DESUF,;
				(_cAlias)->FORNECE,;
				(_cAlias)->LOJA,;
				(_cAlias)->NOMFOR,;
				(_cAlias)->PEDIDO,;
				(_cAlias)->ITEM,;
				(_cAlias)->PRODUTO,;
				(_cAlias)->DESPRO,;
				(_cAlias)->LOCAL,;
				(_cAlias)->QUANT,;
				(_cAlias)->CARGA,;
				Stod((_cAlias)->DTCARGA),;
				(_cAlias)->ID,;
				.F.})
			If (_cAlias)->CARGA == _cCarga
				_nqtdCar += (_cAlias)->QUANT
			EndIf
			(_cAlias)->(DbSkip())
		EndDo
	Else
		oGdPed:Hide()
	EndIf
	
	(_cAlias)->(DbCloseArea())
	
	oGdPed:aCols	:=	aCols
	
	cSyDsCar	:=	"CARGA: " + _cCarga + " PESO: " + Alltrim(Str(_nQtdCar))
	
	oSyDsCar:Refresh()
	
	oGdPed:Refresh()
		
Return


Static Function fPopCar()

	Local aCols	:=	{}
	Local 	_cAlias	:=	GetNextAlias()
	Local	_nPosUF	:=	aScan(oGdEst:aHeader,{|x| Alltrim(x[2] == "UF")})
	Local	_cUf	:=	oGdEst:aCols[oGdEst:nAt,_nPosUF]
	Local 	_nPosTrans	:=	aScan(oGdTran:aHeader,{|x| Alltrim(x[2] == "CODIGO")})
	Local	_cTrans	:=	oGdTran:aCols[oGdTran:nAt,_nPosTrans]
	Local	_nPosDel	:=	Len(oGdCar:aHeader) + 1
	
	BeginSql Alias _cAlias
		SELECT CARGA,SUM(QUANT) QUANT, MAX(DTCARGA) DTCARGA
			FROM %Exp:_cVarTab%
			WHERE UF = %Exp:_cUf%
				AND TRANSP = %Exp:_cTrans%
				AND CARGA <> ''
		GROUP BY CARGA
	EndSql
	
	If (_cAlias)->(!EOF())
		oGdCar:Show()
		While (_cAlias)->(!EOF())
			aAdd(aCols,{"BR_VERMELHO",(_cAlias)->CARGA,(_cAlias)->QUANT,Stod((_cAlias)->DTCARGA),.F.})
			(_cAlias)->(DbSkip())
		EndDo
		aCols[1,1]	:=	"BR_VERDE"
		
		oGdCar:aCols	:=	aCols
		
		oGdCar:Refresh()
		
		fPopPed()
	Else
		oGdCar:aCols	:=	aCols
		oGdCar:Hide()
		oGdPed:Hide()
	EndIf
	
	(_cAlias)->(DbCloseArea())
	
				
Return

Static Function fPopTran()

	Local aCols	:=	{}
	Local 	_cAlias	:=	GetNextAlias()
	Local	_nPosUF	:=	aScan(oGdEst:aHeader,{|x| Alltrim(x[2] == "UF")})
	Local	_cUf	:=	oGdEst:aCols[oGdEst:nAt,_nPosUF]
	Local	_nPosDel	:=	Len(oGdTran:aHeader) + 1

	BeginSql Alias _cAlias
		SELECT DISTINCT TRANSP, NMTRAN
			FROM %Exp:_cVarTab%
			WHERE UF = %Exp:_cUf%
	EndSql

	If (_cAlias)->(!EOF())
		While (_cAlias)->(!EOF())
			aAdd(aCols,{(_cAlias)->TRANSP,(_cAlias)->NMTRAN,.F.})
			(_cAlias)->(DbSkip())
		EndDo
		aCols[1,_nPosDel]	:=	.T.
	EndIf

	(_cAlias)->(DbCloseArea())

	oGdTran:aCols	:=	aCols
	
	If Len(aCols) > 0
		oGdTran:Show()
	Else
		oGdTran:Hide()
	EndIf

	oGdTran:Refresh()

Return


Static Function fChgEst()

	Local _nI
	Local _nPosDel	:=	Len(oGdEst:aHeader) + 1

	For _nI	:=	1 to Len(oGdEst:aCols)
	
		If _nI == oGdEst:nAt
			oGdEst:aCols[_nI,_nPosDel]	:=	.T.
		Else
			oGdEst:aCols[_nI,_nPosDel]	:=	.F.
		End
	
	Next

	oGdEst:Refresh()

	fPopTran()
	
	fPopCar()


Return

Static Function fChgTran()

	Local _nI
	Local _nPosDel	:=	Len(oGdTran:aHeader) + 1

	For _nI	:=	1 to Len(oGdTran:aCols)
	
		If _nI == oGdTran:nAt
			oGdTran:aCols[_nI,_nPosDel]	:=	.T.
		Else
			oGdTran:aCols[_nI,_nPosDel]	:=	.F.
		End
	
	Next

	oGdTran:Refresh()

	fPopCar()


Return

Static Function fChgCrg()
	
	Local _nI
	Local _nPosDel	:=	Len(oGdCar:aHeader) + 1

	For _nI	:=	1 to Len(oGdCar:aCols)
	
		If _nI == oGdCar:nAt
			oGdCar:aCols[_nI,1]	:=	"BR_VERDE"
		Else
			oGdCar:aCols[_nI,1]	:=	"BR_VERMELHO"
		End
	
	Next

	oGdCar:Refresh()

	fPopPed()

Return

Static Function fGetCodCar()

	Local _cCarga	:=	Alltrim(GetMV("ES_CDCARGA"))

	_cCarga	:=	Soma1(_cCarga)
	
	PUTMV("ES_CDCARGA",_cCarga)

Return _cCarga

User Function BFG31KF5()

	Local aCols := oGdCar:aCols
	Local	_nPosDel	:=	Len(oGdCar:aHeader) + 1

	aEval(aCols,{|x| x[1] := "BR_VERMELHO"})

	aAdd(aCols,{"BR_VERDE",fGetCodCar(),0,Stod(""),.F.})
	
	oGdCar:aCols	:=	aCols
	
	oGdCar:Goto(Len(oGdCar:aCols))	
	
	oGdCar:Show()
	
	oGdCar:Refresh()
	
	fPopPed()

Return

User Function BFG31RCR()

	Local _nPosQtd	:=	aScan(oGdCar:aHeader,{|x| Alltrim(x[2]) == "QUANT"})
	Local _nPosCar	:=	aScan(oGdCar:aHeader,{|x| Alltrim(x[2]) == "CODIGO"})
	Local _nPosDtPrf := aScan(oGdCar:aHeader,{|x| Alltrim(x[2]) == "DATPRF"})
	
	If oGdCar:oBrowSe:nColPos == _nPosDtPrf
		Return
	EndIf
	
	oGdCar:aCols[oGdCar:nAt,_nPosQtd]:= 0
	
	TcSqlExec("UPDATE " + _cTabTemp + " SET CARGA = '', DTCARGA = '' WHERE CARGA = " + ValtoSql(oGdCar:aCols[oGdCar:nAt,_nPosCar]))
	
	fPopPed()

Return

User Function BFG31PED()

	Local _nPosCarC	:=	aScan(oGdCar:aHeader,{|x| Alltrim(x[2]) == "CODIGO"})
	Local _nPosCarP	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2]) == "CARGA"})
	Local _nPosQtdC	:=	aScan(oGdCar:aHeader,{|x| Alltrim(x[2]) == "QUANT"})
	Local _nPosQtdP	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2]) == "QUANT"})
	Local _nPosCAnt	:=	0
	Local _cCarAnt	:=	oGdPed:aCols[oGdPed:nAt,_nPosCarP]
	Local _nPosId	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2]) == "ID"})
	Local _cQryUpdt	:=	""

	Local _nPosDatC	:=	aScan(oGdCar:aHeader,{|x| Alltrim(x[2]) == "DATPRF"})
	Local _nPosDatP	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2]) == "DTCARGA"})
	
	If oGdPed:aCols[oGdPed:nAt,1] == "BR_VERDE"
		oGdPed:aCols[oGdPed:nAt,1]	:=	"BR_VERMELHO"
		oGdCar:aCols[oGdCar:nAt,_nPosQtdC]	-= oGdPed:aCols[oGdPed:nAt,_nPosQtdP]
		oGdPed:aCols[oGdPed:nAt,_nPosCarP]	:=	""
		oGdPed:aCols[oGdPed:nAt,_nPosDatP]	:=	Stod("")
		_cQryUpdt	:=	"UPDATE "+ _cTabTemp + " SET CARGA = '', DTCARGA = '' WHERE ID = " + ValtoSql(oGdPed:aCols[oGdPed:nAt,_nPosId])
	ElseIf oGdPed:aCols[oGdPed:nAt,1] == "BR_VERMELHO"
		oGdPed:aCols[oGdPed:nAt,1]	:=	"BR_VERDE"
		oGdCar:aCols[oGdCar:nAt,_nPosQtdC]	+= oGdPed:aCols[oGdPed:nAt,_nPosQtdP]
		oGdPed:aCols[oGdPed:nAt,_nPosCarP]	:=	oGdCar:aCols[oGdCar:nAt,_nPosCarC]
		oGdPed:aCols[oGdPed:nAt,_nPosDatP]	:=	oGdCar:aCols[oGdCar:nAt,_nPosDatC]
		_cQryUpdt	:=	"UPDATE "+ _cTabTemp + " SET CARGA = "+ ValtoSql(oGdCar:aCols[oGdCar:nAt,_nPosCarC])+", DTCARGA = "+ValtoSql(oGdCar:aCols[oGdCar:nAt,_nPosDatC])+" WHERE ID = " + ValtoSql(oGdPed:aCols[oGdPed:nAt,_nPosId])
	ElseIf oGdPed:aCols[oGdPed:nAt,1] == "BR_AMARELO"
		oGdPed:aCols[oGdPed:nAt,1]	:=	"BR_VERDE"
		oGdCar:aCols[oGdCar:nAt,_nPosQtdC]	+= oGdPed:aCols[oGdPed:nAt,_nPosQtdP]
		oGdPed:aCols[oGdPed:nAt,_nPosDatP]	:=	oGdCar:aCols[oGdCar:nAt,_nPosDatC]
		oGdPed:aCols[oGdPed:nAt,_nPosCarP]	:=	oGdCar:aCols[oGdCar:nAt,_nPosCarC]
		If (_nPosCAnt := aScan(oGdCar:aCols,{|x| x[_nPosCarC] ==  _cCarAnt})) > 0
			oGdCar:aCols[_nPosCAnt,_nPosQtdC]	-= oGdPed:aCols[oGdPed:nAt,_nPosQtdP]
			_cQryUpdt	:=	"UPDATE "+ _cTabTemp + " SET CARGA = "+ ValtoSql(oGdCar:aCols[oGdCar:nAt,_nPosCarC])+ ", DTCARGA = "+ValtoSql(oGdCar:aCols[oGdCar:nAt,_nPosDatC])+" WHERE ID = " + ValtoSql(oGdPed:aCols[oGdPed:nAt,_nPosId])
		EndIf
	EndIf
	
	TcSqlExec(_cQryUpdt)
	
	cSyDsCar	:=	"CARGA: " + oGdCar:aCols[oGdCar:nAt,_nPosCarC] + " PESO: " + Alltrim(Str(oGdCar:aCols[oGdCar:nAt,_nPosQtdC]))
	
	oSyDsCar:Refresh()
	
	oGdPed:Refresh()
	oGdCar:Refresh()	

Return

User Function BFG31FOK()

	Local cMenVar	:=	ReadVar()
	Local _nPosCarC	:=	aScan(oGdCar:aHeader,{|x| Alltrim(x[2]) == "CODIGO"})
	Local _nPosCarP	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2]) == "CARGA"})
	Local _nPosDatP	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2]) == "DTCARGA"})
	Local _nPosId	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2]) == "ID"})
	
	Local _nI

	If cMenVar == "M->DATPRF"
		For _nI	:= 1 to Len(oGdPed:aCols)
			If oGdPed:aCols[_nI,_nPosCarP] == oGdCar:aCols[oGdCar:nAt,_nPosCarC]
				oGdPed:aCols[_nI,_nPosDatP]	:=	M->DATPRF
			EndIf
		Next
		TcSqlExec("UPDATE "+ _cTabTemp + " SET DTCARGA = "+ValtoSql(M->DATPRF)+" WHERE CARGA = " + ValtoSql(oGdCar:aCols[oGdCar:nAt,_nPosCarC]))
	EndIf

	oGdPed:Refresh()

Return .T.

Static Function fGrava()

	Local _cAlias	:=	GetNextAlias()
	Local _cCod		:=	fGetCod()
	
	BeginSql Alias _cAlias
		SELECT *
			FROM %Exp:_cVarTab%
	EndSql
	
	While (_cAlias)->(!EOF())
	
		Reclock("ZC6",.T.)
			ZC6->ZC6_FILIAL		:=	xFilial("ZC6")
			ZC6->ZC6_CODIGO		:=	_cCod
			ZC6->ZC6_DATA		:=	date()
			ZC6->ZC6_ID			:=	(_cAlias)->ID
			ZC6->ZC6_PEDIDO		:=	(_cAlias)->PEDIDO
			ZC6->ZC6_DATPRF		:=	Stod((_cAlias)->ENTREGA)
			ZC6->ZC6_UF			:=	(_cAlias)->UF
			ZC6->ZC6_DESUF		:=	(_cAlias)->DESUF
			ZC6->ZC6_TRANSP		:=	(_cAlias)->TRANSP
			ZC6->ZC6_DSTRAN		:=	(_cAlias)->NMTRAN
			ZC6->ZC6_CODFOR		:=	(_cAlias)->FORNECE
			ZC6->ZC6_LOJFOR		:=	(_cAlias)->LOJA
			ZC6->ZC6_DESFOR		:=	(_cAlias)->NOMFOR
			ZC6->ZC6_ITEM		:=	(_cAlias)->ITEM
			ZC6->ZC6_CODPRO		:=	(_cAlias)->PRODUTO
			ZC6->ZC6_DESPRO		:=	(_cAlias)->DESPRO
			ZC6->ZC6_LOCAL		:=	(_cAlias)->LOCAL
			ZC6->ZC6_QUANT		:=	(_cAlias)->QUANT
			ZC6->ZC6_CARGA		:=	(_cAlias)->CARGA
			ZC6->ZC6_DATCAR		:=	StoD((_cAlias)->DTCARGA)
			ZC6->ZC6_USER		:=	__cUserID
		ZC6->(MsUnlock())
		
		If !Empty((_cAlias)->DTCARGA) .And. !Empty((_cAlias)->CARGA)
			SC7->(DbGoTo((_cAlias)->ID))
			If SC7->(!EOF())
				Reclock("SC7",.F.)
					SC7->C7_YCARGA	:=	ZC6->ZC6_CARGA
					SC7->C7_YDATCAR	:=	ZC6->ZC6_DATCAR
				SC7->(MsUnlock())
			EndIf
		EndIf
		
		(_cAlias)->(DbSkip())
	EndDo
	
	(_cAlias)->(DbCloseArea())
	
	MsgInfo("Cargas Inseridas com Sucesso!")
	
	oDlgMRP:End()
	
Return

Static Function fGetCod()

	Local _cAlias	:=	GetNextAlias()
	Local _cCod		:=	""

	BeginSql Alias _cAlias

	SELECT ISNULL(MAX(ZC6_CODIGO),'000000') COD
	FROM %TABLE:ZC6% ZC6
	WHERE ZC6_FILIAL = %XFILIAL:ZC6%
	AND %NotDel%
	EndSql

	_cCod	:=	Soma1((_cAlias)->COD)

	(_cAlias)->(DbCloseArea())

Return _cCod