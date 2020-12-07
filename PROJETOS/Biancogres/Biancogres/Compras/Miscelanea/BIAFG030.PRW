#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG030
@author Gabriel Rossi Mafioletti
@since 15/01/2018
@version 1.0
@description MRP - Tela de Geração de Pedidos de Compra
@type function
/*/

User Function BIAFG030()

	If !ValidPerg()
		Return
	EndIf

	Private aSize := MsAdvSize(.F.) //Sem Enchoice

	Private oDlgMRP		:=	Nil		//Dialog
	Private oGpMRP1		:=	Nil		//Grupo
	Private oSyDsProd	:=	Nil	
	Private cSyDsProd	:=	SPACE(250)
	Private	oFntMRP		:=	TFont():New("Arial",,022,,.T.,,,,,.F.,.F.)		

	Private _aPedidos	:=	{}	//Variável que conterá os dados para os pedidos

	aObjects := {}

	Private oGdProd		:=	Nil		//GetDados Produto x Fornecedor
	Private oGdEst		:=	Nil		//Getdados de Estado X  Transportadora
	Private	oGdSol		:=	Nil		//Getdados de Solicitações

	/*-------------------------------------------------------------------------+
	|Resolve as dimensoes dos objetos1                                         |
	+-------------------------------------------------------------------------*/
	AAdd( aObjects, { 100, 215, .T., .T. } )
	AAdd( aObjects, { 100, 185, .T., .T. } )
	AAdd( aObjects, { 100, 025, .T., .F. } )

	aInfo1   := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }

	aPosObj1 := MsObjSize( aInfo1, aObjects, .T. )

	/*-------------------------------------------------------------------------+
	|Resolve as dimensoes dos objetos2                                         |
	+-------------------------------------------------------------------------*/
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } ) 
	aSize2 := aClone( aPosObj1[2] )
	aInfo2   := { aSize2[2], aSize2[1], aSize2[4], aSize2[3], 3, 3 }
	aPosObj2 := MsObjSize( aInfo2, aObjects, ,.T. )

	//Monta tela
	DEFINE MSDIALOG oDlgMRP TITLE "Gera Pedidos" FROM aSize[7], aSize[7] TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL OF oMainWnd

	// Painel Estado X Transportadora
	@ aPosObj2[2][1], aPosObj2[2][2] GROUP oGpMRP1 TO aPosObj2[2][3], aPosObj2[2][4] PROMPT "Estado X Transportadora" OF oDlgMRP COLOR 0, 16777215 PIXEL
	U_BIAMsgRun("Aguarde... Carregando dados (Quadro Estado X Trasportadora)",,{|| fGeraEst() })

	// Painel Produto X Fornecedor
	@ aPosObj2[1][1], aPosObj2[1][2] GROUP oGpMRP1 TO aPosObj2[1][3], aPosObj2[1][4] PROMPT "Produto x Fornecedor..." OF oDlgMRP COLOR 0, 16777215 PIXEL
	U_BIAMsgRun("Aguarde... Carregando dados (Produto X Fornecedor)",,{|| fGeraPrd() })

	// Painel de Solicitações
	@ aPosObj1[1][1], aPosObj1[1][2] GROUP oGpMRP1 TO aPosObj1[1][3], aPosObj1[1][4] PROMPT "Solicitações..." OF oDlgMRP COLOR 0, 16777215 PIXEL
	U_BIAMsgRun("Aguarde... Carregando dados (Solicitações)",,{|| fGeraSol() })

	// Painel Produto(Rodapé)
	@ aPosObj1[3][1], aPosObj1[3][2] GROUP oGpMRP1 TO aPosObj1[3][3], aPosObj1[3][4] PROMPT "Produto" OF oDlgMRP COLOR 0, 16777215 PIXEL
	@ aPosObj1[3][1]+10, aPosObj1[3][2]+05 SAY oSyDsProd PROMPT cSyDsProd SIZE 446, 011 OF oDlgMRP FONT oFntMRP COLORS 0, 16777215 PIXEL

	@ aPosObj1[3][1]+08, aPosObj1[3][4]-040 BUTTON oBt1CockSim PROMPT "Cancelar" SIZE 037, 012 OF oDlgMRP ACTION (cj_Fecha := .F., fh_Esc := .T., oDlgMRP:End()) PIXEL
	@ aPosObj1[3][1]+08, aPosObj1[3][4]-103 BUTTON oBt2CockSim PROMPT "Gerar Pedidos"   SIZE 060, 012 OF oDlgMRP ACTION fGeraPed()  PIXEL

	ACTIVATE MSDIALOG oDlgMRP CENTERED

Return	

Static Function ValidPerg()

	local cLoad	    := "BIAFG030" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(100)
	MV_PAR02 := STOD('') 
	MV_PAR03 := STOD('') 
	MV_PAR04 := SPACE(200)
	MV_PAR05 := SPACE(1)

	aAdd( aPergs ,{1,"Grupo(s) ", MV_PAR01, "", "U_BIAFG30G()", '', '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Data De ", MV_PAR02, "", "NAOVAZIO()", '', '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Data Ate ", MV_PAR03, "", "NAOVAZIO()", '', '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Armazém(s) ", MV_PAR04, "", "U_B773Loc()", '', '.T.', 50, .F.})
	aAdd( aPergs ,{2,"Produtos ", MV_PAR05, {'P=MRP','O=MRO'}, 50, "", .T.})		

	If ParamBox(aPergs ,"MRP - Pedidos",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)

	EndIf

Return lRet

User Function BIAFG30G()

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

//Cria o MsNewgetdados do Quadro Solicitações
Static Function fGeraSol()

	Local	aHeader	:=	{}
	Local	aCols	:=	{}
	Local 	_cAlias	:=	GetNextAlias()
	Local	_cQry	:=	""
	Local _nI
	Local cInGrp	:= ""
	Local _cInLocal	:= ""

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

	_cQry += "SELECT SC1.C1_NUM," + CRLF
	_cQry += "	SC1.C1_ITEM," + CRLF
	_cQry += "	(CASE WHEN SC1.C1_YATSERV IN ('T','S') THEN 'SIM' ELSE 'NAO' END) C1_YATSERV," + CRLF
	_cQry += "	SC1.C1_EMISSAO," + CRLF
	_cQry += "	SC1.C1_DATPRF," + CRLF
	_cQry += "	SC1.C1_PRODUTO," + CRLF
	_cQry += "	SC1.C1_LOCAL," + CRLF
	_cQry += "	SC1.C1_QUANT," + CRLF
	_cQry += "	SC1.C1_YOBS," + CRLF
	_cQry += "	SC1.C1_YOBS2" + CRLF
	_cQry += "FROM " + RETSQLNAME("SC1") + " SC1" + CRLF
	_cQry += "JOIN " + RETSQLNAME("SB1") + " SB1" + CRLF
	_cQry += "	ON SB1.B1_COD = SC1.C1_PRODUTO" + CRLF
	_cQry += "		AND SB1.B1_GRUPO IN " + cInGrp + CRLF
	_cQry += "		AND SB1.B1_MSBLQL <> '1'" + CRLF
	_cQry += "		AND SB1.D_E_L_E_T_ = ''" + CRLF
	_cQry += "JOIN " + RETSQLNAME("SBZ") + " SBZ" + CRLF
	_cQry += "	ON SBZ.BZ_FILIAL = " + ValtoSql(xFilial("SBZ")) + CRLF
	_cQry += "		AND SBZ.BZ_COD = SB1.B1_COD" + CRLF
	_cQry += "		AND SBZ.BZ_YBLSCPC <> '1'" + CRLF
	If MV_PAR05 == "P"
		_cQry += "		AND SBZ.BZ_YPOLIT = '2'" + CRLF
	Else
		_cQry += "		AND SBZ.BZ_YPOLIT <> '2' " + CRLF 
		//Correção Ticket 22865 - Pablo S. Nascimento 
		//[Anuplio informou que o filtro estava incorreto e orientou que fosse repassado todos diferentes de 2 nessa condição]
	EndIf
	_cQry += "		AND SBZ.D_E_L_E_T_ = ' '" + CRLF
	_cQry += "WHERE SC1.C1_FILIAL = " + ValtoSql(xFilial("SC1")) + CRLF
	_cQry += "	AND SC1.C1_DATPRF BETWEEN " + ValtoSql(MV_PAR02) + " AND " + ValtoSql(MV_PAR03) + CRLF
	_cQry += "	AND SC1.C1_YTOTEST NOT IN ( 'T', 'P' )" + CRLF
	_cQry += "	AND SC1.C1_QUANT - C1_QUJE <> 0" + CRLF
	_cQry += "	AND SC1.C1_PEDIDO = '      '" + CRLF
	_cQry += "	AND SC1.C1_RESIDUO = ' '" + CRLF
	_cQry += "	AND SC1.C1_LOCAL IN " + _cInLocal + CRLF
	_cQry += "	AND SC1.C1_APROV NOT IN ( 'B', 'R' )" + CRLF
	If MV_PAR05 == "O"
		_cQry += "	AND SC1.C1_COTACAO = ''" + CRLF
		_cQry += "	AND EXISTS(SELECT *" + CRLF
		_cQry += "		FROM " + RETSQLNAME("AIB") + " AIB" + CRLF
		_cQry += "			JOIN " + RETSQLNAME("AIA") + " AIA ON AIA.AIA_FILIAL = " + ValtoSql(xFilial("AIA")) + CRLF
		_cQry += "				AND AIB.AIB_CODFOR = AIA.AIA_CODFOR" + CRLF
		_cQry += "				AND AIB.AIB_LOJFOR = AIA.AIA_LOJFOR" + CRLF
		_cQry += "				AND AIB.AIB_CODTAB = AIA.AIA_CODTAB" + CRLF
		_cQry += "				AND SC1.C1_EMISSAO BETWEEN AIA.AIA_DATDE AND AIA.AIA_DATATE" + CRLF
		_cQry += "				AND AIA.D_E_L_E_T_ = ''" + CRLF
		_cQry += "		WHERE AIB.AIB_FILIAL = " + ValtoSql(xFilial("AIA")) + CRLF
		_cQry += "			AND AIB.AIB_CODPRO = SC1.C1_PRODUTO" + CRLF
		_cQry += "			AND AIB.AIB_DATVIG >= SC1.C1_EMISSAO" + CRLF
		_cQry += "			AND AIB.D_E_L_E_T_ = '')" + CRLF
	EndIf
	_cQry += "	AND SC1.D_E_L_E_T_ = ''" + CRLF

	IndSol := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.F.,.T.)

	If MV_PAR05 == "O"
		Aadd(aHeader,{" "				,"CSTATUS"	,"@BMP", 2, 0, ".F." ,""   , "C", "", "V" ,"" , "","","V"})
		aAdd(aHeader,{"Num. SC"         ,"SOLIC" 	,"@!"               , 06   , 0,,, "C",, })      	// 1
		aAdd(aHeader,{"Item"         	,"ITSOL" 	,"@!"               , 04   , 0,,, "C",, })      	// 2
		aAdd(aHeader,{"At Servic"       ,"ATSERV" 	,"@!"               , 03   , 0,,, "C",, })      	// 3
		aAdd(aHeader,{"Emissão"        	,"DTEMIS" 	,"@!"               , 08   , 0,,, "D",, })      	// 4
		aAdd(aHeader,{"Neces. SC" 		,"DTPRF" 	,"@!"               , 08   , 0,,, "D",, })      	// 5
		aAdd(aHeader,{"Cd. Produto"    	,"CODPRO" 	,"@!"               , 15   , 0,,, "C",, })      	// 6
		aAdd(aHeader,{"Local"  		  	,"LOCPRD" 	,"@!"               , 02   , 0,,, "C",, })      	// 7
		aAdd(aHeader,{"Qt. Solic."    	,"QTDSOL" 	,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      	// 8
		aAdd(aHeader,{"Obs 1"       	,"OBS1" 	,"@!"               , 254  , 0,,, "C",, })      	// 9
		aAdd(aHeader,{"Obs 2"    	    ,"OBS2" 	,"@!"               , 150  , 0,,, "C",, })      	// 10
	Else
		Aadd(aHeader,{" "				,"CSTATUS"	,"@BMP", 2, 0, ".F." ,""   , "C", "", "V" ,"" , "","","V"})
		aAdd(aHeader,{"Num. SC"         ,"SOLIC" 	,"@!"               , 06   , 0,,, "C",, })      	// 1
		aAdd(aHeader,{"Item"         	,"ITSOL" 	,"@!"               , 04   , 0,,, "C",, })      	// 2
		aAdd(aHeader,{"Emissão"        	,"DTEMIS" 	,"@!"               , 08   , 0,,, "D",, })      	// 3
		aAdd(aHeader,{"Previs. Chegada" ,"DTPRF" 	,"@!"               , 08   , 0,,, "D",, })      	// 4
		aAdd(aHeader,{"Cd. Produto"    	,"CODPRO" 	,"@!"               , 15   , 0,,, "C",, })      	// 5
		aAdd(aHeader,{"Local"  		  	,"LOCPRD" 	,"@!"               , 02   , 0,,, "C",, })      	// 6
		aAdd(aHeader,{"Qt. Solic."    	,"QTDSOL" 	,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      	// 7
		aAdd(aHeader,{"Obs 1"       	,"OBS1" 	,"@!"               , 254  , 0,,, "C",, })      	// 8
		aAdd(aHeader,{"Obs 2"    	    ,"OBS2" 	,"@!"               , 150  , 0,,, "C",, })      	// 9
	EndIf

	While (_cAlias)->(!EOF())
		If MV_PAR05 == "O"
			aAdd(aCols,{"BR_VERMELHO"	,;	
			(_cAlias)->C1_NUM			,;
			(_cAlias)->C1_ITEM			,;
			(_cAlias)->C1_YATSERV		,;
			Stod((_cAlias)->C1_EMISSAO)	,;
			Stod((_cAlias)->C1_DATPRF)	,;
			(_cAlias)->C1_PRODUTO		,;
			(_cAlias)->C1_LOCAL			,;
			(_cAlias)->C1_QUANT			,;
			(_cAlias)->C1_YOBS			,;
			(_cAlias)->C1_YOBS2			,;
			.F.	})
		Else
			aAdd(aCols,{"BR_VERMELHO"	,;	
			(_cAlias)->C1_NUM			,;
			(_cAlias)->C1_ITEM			,;
			Stod((_cAlias)->C1_EMISSAO)	,;
			Stod((_cAlias)->C1_DATPRF)	,;
			(_cAlias)->C1_PRODUTO		,;
			(_cAlias)->C1_LOCAL			,;
			(_cAlias)->C1_QUANT			,;
			(_cAlias)->C1_YOBS			,;
			(_cAlias)->C1_YOBS2			,;
			.F.	})
		EndIf

		aAdd(_aPedidos,{{"BR_VERMELHO",;
		(_cAlias)->C1_NUM,;
		(_cAlias)->C1_ITEM,;
		Stod((_cAlias)->C1_DATPRF),;
		(_cAlias)->C1_PRODUTO,;
		(_cAlias)->C1_LOCAL	,;
		(_cAlias)->C1_QUANT,;
		(_cAlias)->C1_YOBS,;
		(_cAlias)->C1_YOBS2},;
		{"BR_VERMELHO",;
		"",; 						//Fornecedor
		"",; 						//Loja
		"",;						//Tabela de Preço
		0,;							//Moeda
		0},;						//Preço
		{"BR_VERMELHO",;
		"",;						//Fornecedor
		"",;						//Loja
		"";							//TransPortadora
		}})

		(_cAlias)->(DbSkip())
	EndDo

	Ferase(IndSol+GetDBExtension())     //arquivo de trabalho
	Ferase(IndSol+OrdBagExt())          //indice gerado
	(_cAlias)->(DbCloseArea())

	oGdSol	:=	MsNewGetDados():New( aPosObj1[1][1] + 10, aPosObj1[1][2] + 5, aPosObj1[1][3] - 5, aPosObj1[1][4] - 5, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", {},, 999, '', "", "AllwaysTrue", oDlgMRP, aHeader, aCols, { || fAltSol() } )

Return

Static Function fAltSol()

	Local _nPosPrd	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2]) == "CODPRO"})
	Local _nI
	Local _nPosDel	:=	Len(oGdSol:aHeader) + 1	
	Local _lContinua

	oGdProd:Show()
	oGdEst:Show()

	cSyDsProd := ""
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + oGdSol:Acols[oGdSol:nAt][_nPosPrd] ))
	cSyDsProd := Alltrim(SB1->B1_DESC)
	oSyDsProd:Refresh()

	For _nI	:=	1 to Len(oGdSol:aCols)

		If _nI == oGdSol:nAt
			oGdSol:aCols[_nI,_nPosDel]	:=	.T.
		Else
			oGdSol:aCols[_nI,_nPosDel]	:=	.F.
		End

	Next

	oGdSol:Refresh()

	_lContinua	:=	fPopPrd()
	If _lContinua
		fPopEst()
	Else
		oGdEst:Hide()
	EndIf

Return

Static Function fGeraPrd()

	Local	aHeader	:=	{}
	Local	aCols	:=	{}
	Local	cCboFrt	:=	"C=CIF;F=FOB;A=Ambos"

	Aadd(aHeader,{" "				,"CSTATUS"	,"@BMP", 2, 0, ".F." ,""   , "C", "", "V" ,"" , "","","V"})
	aAdd(aHeader,{"Cd. Forn."       ,"CODFOR" 	,"@!"               , 06   , 0,,, "C",, })      	// 1
	aAdd(aHeader,{"Loja"         	,"LJFOR" 	,"@!"               , 02   , 0,,, "C",, })      	// 2
	aAdd(aHeader,{"Nome"        	,"NMFOR" 	,"@S40"             , 80   , 0,,, "C",, })      	// 3
	aAdd(aHeader,{"Preço Sug."    	,"PRECOS" 	,"@E 999,999.9999"  , 12   , 4,,, "N",, })      	// 4
	aAdd(aHeader,{"Preço Dig."    	,"PRECOD" 	,"@E 999,999.9999"  , 12   , 4,,, "N",, })      	// 5
	aAdd(aHeader,{"PE"    			,"QTDPE" 	,"@E 999"     		, 03   , 0,,, "N",, })      	// 6
	aAdd(aHeader,{"Tab. Preço"    	,"TABPRC" 	,"@!"     			, 03   , 0,,, "C",, })      	// 7
	aAdd(aHeader,{"Tp. Frete"    	,"TPFRET" 	,"@!"               , 01   , 0,,, "C",,,cCboFrt }) 	// 8
	aAdd(aHeader,{"Moeda"        	,"MOEDA" 	,"@!"               , 01   , 0,,, "N",, })      	// 9

	oGdProd	:=	MsNewGetDados():New( aPosObj2[1][1] + 10, aPosObj2[1][2] + 5, aPosObj2[1][3] - 5, aPosObj2[1][4] - 5, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", {"MOEDA","PRECOD"},, 999, "U_BFG30FOK()", "", "AllwaysTrue", oDlgMRP, aHeader, aCols, { || fAltPrd() } )
	oGdProd:oBrowse:bLDblClick := {|| oGdProd:EditCell(),fDblProd()}

Return

Static Function fAltPrd()

	Local _nPosDel	:=	Len(oGdProd:aHeader) + 1	
	Local _nI		

	For _nI	:=	1 to Len(oGdProd:aCols)

		If _nI == oGdProd:nAt
			oGdProd:aCols[_nI,_nPosDel]	:=	.T.
		Else
			oGdProd:aCols[_nI,_nPosDel]	:=	.F.
		End

	Next
	oGdProd:Refresh()
	fPopEst()

Return

Static Function fPopPrd()

	Local _cAlias	:=	GetNextAlias()
	Local _nPosPrd	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2])=="CODPRO"})
	Local _cProd	:=	oGdSol:Acols[oGdSol:nAt,_nPosPrd]
	Local aCols		:=	{}
	Local _lPos	
	Local _lRet		:=	.T.
	Local _nPosDel	:=	Len(oGdProd:aHeader) + 1
	Local _cDtRef	:=	dDataBase
	
	If !Empty(_cProd)
	
		U_BIAF057(_cProd)
		
	EndIf

	BeginSql Alias _cAlias
		SELECT DISTINCT A5_FORNECE, 
		A5_LOJA, 
		A5_NOMEFOR, 
		A5_PE,
		A5_YPRECO, 
		A2_YTPFRET,
		A5_CODTAB,
		CASE WHEN A5_MOE_US = '' THEN 1 ELSE SYF.YF_MOEFAT END AS MOEDA
		FROM %TABLE:SA5% SA5
		JOIN %TABLE:SA2% SA2
		ON 	SA5.A5_FILIAL = %XFILIAL:SA5%
		AND SA2.A2_FILIAL = %XFILIAL:SA2%
		AND SA5.A5_FORNECE = SA2.A2_COD
		AND SA5.A5_LOJA = SA2.A2_LOJA
		AND SA2.A2_MSBLQL <> '1'
		AND SA5.A5_CODTAB <> ''
		AND SA5.%NotDel%
		AND SA2.%NotDel%
		AND SA5.A5_PRODUTO = %Exp:_cProd%
		JOIN %TABLE:AIA% AIA
		ON AIA.AIA_FILIAL = %XFILIAL:AIA%
		AND %Exp:_cDtRef% BETWEEN AIA.AIA_DATDE AND AIA.AIA_DATATE
		AND AIA.AIA_CODFOR = SA2.A2_COD
		AND AIA.AIA_LOJFOR = SA2.A2_LOJA
		AND AIA.AIA_CODTAB = SA5.A5_CODTAB
		AND AIA.%NotDel% 
		JOIN %TABLE:AIB% AIB
		ON AIB.AIB_FILIAL = %XFILIAL:AIB%
		AND AIB.AIB_CODFOR = SA2.A2_COD
		AND AIB.AIB_LOJFOR = SA2.A2_LOJA
		AND AIB.AIB_CODTAB = SA5.A5_CODTAB
		AND AIB.AIB_DATVIG >= %Exp:_cDtRef%
		AND AIB.AIB_CODPRO = SA5.A5_PRODUTO
		AND AIB.%NotDel% 
		LEFT JOIN %TABLE:SYF% SYF ON SYF.YF_FILIAL = %XFILIAL:SYF%
		AND YF_MOEDA = A5_MOE_US
		AND YF_MOEDA <> ''
		AND YF_MOEFAT BETWEEN 1 AND 5
		AND SYF.%NotDel%

	EndSql

	If (_cAlias)->(!EOF())
		While (_cAlias)->(!EOF())
			_lPos	:=	_aPedidos[oGdSol:nAt,2,1] == "BR_VERDE" .And. _aPedidos[oGdSol:nAt,2,2] == (_cAlias)->A5_FORNECE .And. _aPedidos[oGdSol:nAt,2,3] == (_cAlias)->A5_LOJA

			aAdd(aCols,{	If(_lPos,"BR_VERDE","BR_VERMELHO")					,;	
			(_cAlias)->A5_FORNECE			,;
			(_cAlias)->A5_LOJA			,;
			(_cAlias)->A5_NOMEFOR	,;
			(_cAlias)->A5_YPRECO	,;
			Iif(_aPedidos[oGdSol:nAt,2,6]== 0,(_cAlias)->A5_YPRECO,_aPedidos[oGdSol:nAt,2,6])	,;
			(_cAlias)->A5_PE		,;
			(_cAlias)->A5_CODTAB	,;
			(_cAlias)->A2_YTPFRET	,;
			Iif(_aPedidos[oGdSol:nAt,2,5]== 0,(_cAlias)->MOEDA,_aPedidos[oGdSol:nAt,2,5])		,;
			.F.	})
			(_cAlias)->(DbSkip())
		EndDo
		aCols[1,_nPosDel]	:=	.T.
		oGdProd:GoTop()
	Else
		_lRet	:= .F.
		oGdProd:Hide()	
	EndIf

	oGdProd:aCols	:=	aCols

	oGdProd:Refresh()

	(_cAlias)->(DbCloseArea())

Return _lRet

Static Function fGeraEst()

	Local	aHeader	:=	{}
	Local	aCols	:=	{}

	Aadd(aHeader,{" "				,"CSTATUS"	,"@BMP", 2, 0, ".F." ,""  , "C", "", "V" ,"" , "","","V"})
	aAdd(aHeader,{"Estado"	      	,"ESTADO" 	,"@!"               , 02  , 0,,, "C",, })      	// 1
	aAdd(aHeader,{"Transp," 		,"CDTRAN" 	,"@!"               , 06  , 0,,, "C",, })      	// 2
	aAdd(aHeader,{"Nome"        	,"NMTRAN" 	,"@!"               , 40  , 0,,, "C",, })      	// 3
	aAdd(aHeader,{"Tmp. Coleta"     ,"TCRGFC" 	,"@999"             , 3   , 0,,, "N",, })      	// 4
	aAdd(aHeader,{"Tmp. Fracionado" ,"TCRGFR" 	,"@999"             , 3   , 0,,, "N",, })      	// 5	

	oGdEst	:=	MsNewGetDados():New( aPosObj2[2][1] + 10, aPosObj2[2][2] + 5, aPosObj2[2][3] - 5, aPosObj2[2][4] - 5, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", {},, 999, '', "", "AllwaysTrue", oDlgMRP, aHeader, aCols, { || fAltEst() } )
	oGdEst:oBrowse:bLDblClick := {|| fDblEst()}

Return

Static Function fPopEst()

	Local 	_cAlias	:=	GetNextAlias()
	Local	_nPosFor	:=	aScan(oGdProd:aHeader,{|x| Alltrim(x[2])=="CODFOR"})
	Local	_nPosLj		:=	aScan(oGdProd:aHeader,{|x| Alltrim(x[2])=="LJFOR"})
	Local	aCols	:=	{}
	Local	_lPos	

	Local _cFor		:=	oGdProd:aCols[oGdProd:nAt,_nPosFor]
	Local _cLoja	:=	oGdProd:aCols[oGdProd:nAt,_nPosLj]

	Local _nPosDel	:=	Len(oGdEst:aHeader) + 1

	BeginSql Alias _cAlias
		SELECT ZC4_ESTADO,
		ZC4_TRANSP,
		ZC4_TCRGFC,
		ZC4_TCRGFR
		FROM %TABLE:SA2% SA2
		JOIN %TABLE:ZC4% ZC4
		ON 	ZC4.ZC4_FILIAL = %XFILIAL:ZC4%
		AND SA2.A2_FILIAL = %XFILIAL:SA2%
		AND ZC4.ZC4_ESTADO = SA2.A2_EST
		AND SA2.A2_COD = %Exp:_cFor%
		AND SA2.A2_LOJA = %Exp:_cLoja%
		AND SA2.A2_MSBLQL <> '1'
		AND SA2.A2_YTPFRET <> 'C'
		AND ZC4.%NotDel%
		AND SA2.%NotDel%
		JOIN %TABLE:SA4% SA4
		ON	SA4.A4_FILIAL = %XFILIAL:SA4%
		AND SA4.A4_COD = ZC4.ZC4_TRANSP
		AND SA4.A4_MSBLQL <> '1'
		AND SA4.%NotDel%

	EndSql

	If (_cAlias)->(!EOF())
		oGdEst:Show()
		While (_cAlias)->(!EOF())
			_lPos	:=	_aPedidos[oGdSol:nAt,3,1] == "BR_VERDE" .And. _aPedidos[oGdSol:nAt,3,2] == oGdProd:aCols[oGdProd:nAt,_nPosFor] .And. _aPedidos[oGdSol:nAt,3,3] == oGdProd:aCols[oGdProd:nAt,_nPosLj] .And. _aPedidos[oGdSol:nAt,3,4] == (_cAlias)->ZC4_TRANSP 

			aAdd(aCols,{	If(_lPos,"BR_VERDE","BR_VERMELHO")					,;	
			(_cAlias)->ZC4_ESTADO			,;
			(_cAlias)->ZC4_TRANSP			,;
			Posicione("SA4",1,xFilial("SA4") + (_cAlias)->ZC4_TRANSP,"A4_NOME")	,;
			(_cAlias)->ZC4_TCRGFC			,;
			(_cAlias)->ZC4_TCRGFR			,;
			.F.	})
			(_cAlias)->(DbSkip())
		EndDo
		aCols[1,_nPosDel]	:=	.T.
		oGdEst:GoTop()

	Else

		oGdEst:Hide()

	EndIf
	oGdEst:aCols	:=	aCols

	oGdEst:Refresh()

	(_cAlias)->(DbCloseArea())

Return

Static Function fDblProd()

	Local _nI

	Local _nPosFor	:=	aScan(oGdProd:aHeader,{|x| Alltrim(x[2])=="CODFOR"})
	Local _nPosLj	:=	aScan(oGdProd:aHeader,{|x| Alltrim(x[2])=="LJFOR"})
	Local _nPosFrt	:=	aScan(oGdProd:aHeader,{|x| Alltrim(x[2])=="TPFRET"})
	Local _nPosTab	:=	aScan(oGdProd:aHeader,{|x| Alltrim(x[2])=="TABPRC"})
	Local _nPosPrc	:=	aScan(oGdProd:aHeader,{|x| Alltrim(x[2])=="PRECOD"})
	Local _nPosMoed	:=	aScan(oGdProd:aHeader,{|x| Alltrim(x[2])=="MOEDA"})
	Local _nSolDtP	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2])=="DTPRF"})
	Local _TmpPro
	Local _TmpTra

	If !(oGdProd:oBrowse:nColpos == _nPosMoed .Or. oGdProd:oBrowse:nColpos == _nPosPrc)
		For _nI	:=	1 to Len(oGdProd:aCols)

			oGdProd:aCols[_nI,1] := Iif(_nI == oGdProd:nAt .And. oGdProd:aCols[oGdProd:nAt,1] == "BR_VERMELHO","BR_VERDE","BR_VERMELHO")

		Next

		For _nI	:=	1 to Len(oGdEst:aCols)

			oGdEst:aCols[_nI,1] := "BR_VERMELHO"

		Next	

		If oGdProd:aCols[oGdProd:nAt,1] == "BR_VERDE"
			If oGdProd:aCols[oGdProd:nAt,_nPosFrt] == "F"
				If aScan(oGdEst:aCols,{|x| x[1] == "BR_VERDE"})>0
					oGdSol:aCols[oGdSol:nAt,1]	:=	"BR_VERDE"
				Else
					oGdSol:aCols[oGdSol:nAt,1]	:=	"BR_AMARELO"
				EndIf
			Else
				oGdSol:aCols[oGdSol:nAt,1]	:=	"BR_VERDE"
			EndIf
		Else
			oGdSol:aCols[oGdSol:nAt,1]	:=	"BR_VERMELHO"
		EndIF

		_aPedidos[oGdSol:nAt,1,1]	:=	oGdSol:aCols[oGdSol:nAt,1]
		_aPedidos[oGdSol:nAt,2,1]	:=	oGdProd:aCols[oGdProd:nAt,1]

		If oGdProd:aCols[oGdProd:nAt,1] == "BR_VERDE"
			_aPedidos[oGdSol:nAt,2,2]	:=	oGdProd:aCols[oGdprod:nAt,_nPosFor]
			_aPedidos[oGdSol:nAt,2,3]	:=	oGdProd:aCols[oGdprod:nAt,_nPosLj]
			_aPedidos[oGdSol:nAt,2,4]	:=	oGdProd:aCols[oGdprod:nAt,_nPosTab]
			_aPedidos[oGdSol:nAt,2,5]	:=	oGdProd:aCols[oGdprod:nAt,_nPosMoed]
			_aPedidos[oGdSol:nAt,2,6]	:=	oGdProd:aCols[oGdprod:nAt,_nPosPrc]
			_aPedidos[oGdSol:nAt,3,1]	:=	"BR_VERMELHO"
			_aPedidos[oGdSol:nAt,3,2]	:=	""
			_aPedidos[oGdSol:nAt,3,3]	:=	""
			_aPedidos[oGdSol:nAt,3,4]	:=	""
			If oGdProd:aCols[oGdProd:nAt,_nPosFrt] == "C" .Or. oGdProd:aCols[oGdProd:nAt,_nPosFrt] == "A"
				_TmpPro := Posicione("SA2",1,xFilial("SA2")+oGdProd:aCols[oGdprod:nAt,_nPosFor]+oGdProd:aCols[oGdprod:nAt,_nPosLj],"A2_YTMPPRC")
				_TmpTra := Posicione("SA2",1,xFilial("SA2")+oGdProd:aCols[oGdprod:nAt,_nPosFor]+oGdProd:aCols[oGdprod:nAt,_nPosLj],"A2_YTMPTRN")

				_aPedidos[oGdSol:nAt,1,4] := Iif(DaySum(dDataBase,_TmpPro+_TmpTra) <= oGdSol:aCols[oGdSol:nAt,_nSolDtP], oGdSol:aCols[oGdSol:nAt,_nSolDtP], DaySum(dDataBase,_TmpPro+_TmpTra))

			Else
				_aPedidos[oGdSol:nAt,1,4] := oGdSol:aCols[oGdSol:nAt,_nSolDtP]
			EndIf
		ELSE
			_aPedidos[oGdSol:nAt,2,2]	:=	""
			_aPedidos[oGdSol:nAt,2,3]	:=	""
			_aPedidos[oGdSol:nAt,2,4]	:=	""
			_aPedidos[oGdSol:nAt,2,5]	:=	0
			_aPedidos[oGdSol:nAt,2,6]	:=	0
			_aPedidos[oGdSol:nAt,3,1]	:=	"BR_VERMELHO"
			_aPedidos[oGdSol:nAt,3,2]	:=	""
			_aPedidos[oGdSol:nAt,3,3]	:=	""
			_aPedidos[oGdSol:nAt,3,4]	:=	""
			_aPedidos[oGdSol:nAt,1,4]	:=	oGdSol:aCols[oGdSol:nAt,_nSolDtP]
		EndIf
	ElseIf oGdProd:aCols[oGdProd:nAt,1] == "BR_VERDE"
		_aPedidos[oGdSol:nAt,2,5]	:=	oGdProd:aCols[oGdprod:nAt,_nPosMoed]
		_aPedidos[oGdSol:nAt,2,6]	:=	oGdProd:aCols[oGdprod:nAt,_nPosPrc]	
	EndIf
	oGdSol:Refresh()
	oGdProd:Refresh()
	oGdEst:Refresh()

Return

Static Function fDblEst()

	Local _nI

	Local _nPosTrans:=	aScan(oGdEst:aHeader,{|x| Alltrim(x[2])=="CDTRAN"})
	Local _nPosFrt	:=	aScan(oGdProd:aHeader,{|x| Alltrim(x[2])=="TPFRET"})
	Local _nPosFor	:=	aScan(oGdProd:aHeader,{|x| Alltrim(x[2])=="CODFOR"})
	Local _nPosLj	:=	aScan(oGdProd:aHeader,{|x| Alltrim(x[2])=="LJFOR"})
	Local _nPosTab	:=	aScan(oGdProd:aHeader,{|x| Alltrim(x[2])=="TABPRC"})
	Local _nPosPrc	:=	aScan(oGdProd:aHeader,{|x| Alltrim(x[2])=="PRECOD"})
	Local _nPosMoed	:=	aScan(oGdProd:aHeader,{|x| Alltrim(x[2])=="MOEDA"})
	Local _nSolDtP	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2])=="DTPRF"})
	Local _TmpEst
	Local _TmpPro
	Local _TmpTra

	If Len(oGdEst:aCols) > 0 

		For _nI	:=	1 to Len(oGdEst:aCols)

			oGdEst:aCols[_nI,1] := Iif(_nI == oGdEst:nAt .And. oGdEst:aCols[oGdEst:nAt,1] == "BR_VERMELHO","BR_VERDE","BR_VERMELHO")

		Next	

		For _nI	:=	1 to Len(oGdProd:aCols)

			oGdProd:aCols[_nI,1] := Iif(_nI == oGdProd:nAt ,"BR_VERDE","BR_VERMELHO")

		Next

		If oGdProd:aCols[oGdProd:nAt,1] == "BR_VERDE"
			If oGdProd:aCols[oGdProd:nAt,_nPosFrt] == "F"
				If aScan(oGdEst:aCols,{|x| x[1] == "BR_VERDE"})>0
					oGdSol:aCols[oGdSol:nAt,1]	:=	"BR_VERDE"
				Else
					oGdSol:aCols[oGdSol:nAt,1]	:=	"BR_AMARELO"
				EndIf
			Else
				oGdSol:aCols[oGdSol:nAt,1]	:=	"BR_VERDE"
			EndIf
		Else
			oGdSol:aCols[oGdSol:nAt,1]	:=	"BR_VERMELHO"
		EndIF

		_aPedidos[oGdSol:nAt,1,1]	:=	oGdSol:aCols[oGdSol:nAt,1]
		_aPedidos[oGdSol:nAt,2,1]	:=	oGdProd:aCols[oGdProd:nAt,1]
		_aPedidos[oGdSol:nAt,3,1]	:=	oGdEst:aCols[oGdEst:nAt,1]

		If oGdEst:aCols[oGdEst:nAt,1] == "BR_VERDE"
			_aPedidos[oGdSol:nAt,3,2]	:=	oGdProd:aCols[oGdProd:nAt,_nPosFor]
			_aPedidos[oGdSol:nAt,3,3]	:=	oGdProd:aCols[oGdProd:nAt,_nPosLj]
			_aPedidos[oGdSol:nAt,3,4]	:=	oGdEst:aCols[oGdEst:nAt,_nPosTrans]

			If oGdProd:aCols[oGdProd:nAt,_nPosFrt] == "F" .Or. oGdProd:aCols[oGdProd:nAt,_nPosFrt] == "A"
				_TmpPro := Posicione("SA2",1,xFilial("SA2")+oGdProd:aCols[oGdprod:nAt,_nPosFor]+oGdProd:aCols[oGdprod:nAt,_nPosLj],"A2_YTMPPRC")
				_TmpEst := Posicione("SA2",1,xFilial("SA2")+oGdProd:aCols[oGdprod:nAt,_nPosFor]+oGdProd:aCols[oGdprod:nAt,_nPosLj],"A2_EST")
				_TmpTra := Posicione("ZC4",1,xFilial("ZC4")+_TmpEst+oGdEst:aCols[oGdEst:nAt,_nPosTrans],"ZC4_TCRGFR")

				_aPedidos[oGdSol:nAt,1,4] := Iif(DaySum(dDataBase,_TmpPro+_TmpTra) <= oGdSol:aCols[oGdSol:nAt,_nSolDtP], oGdSol:aCols[oGdSol:nAt,_nSolDtP], DaySum(dDataBase,_TmpPro+_TmpTra))

			ElseIf oGdProd:aCols[oGdProd:nAt,_nPosFrt] <> "C"
				_aPedidos[oGdSol:nAt,1,4] := oGdSol:aCols[oGdSol:nAt,_nSolDtP]
			EndIf
		Else
			_aPedidos[oGdSol:nAt,3,1]	:=	""
			_aPedidos[oGdSol:nAt,3,2]	:=	""
			_aPedidos[oGdSol:nAt,3,3]	:=	""
			_aPedidos[oGdSol:nAt,3,4]	:=	""

			If oGdProd:aCols[oGdProd:nAt,_nPosFrt] == "C" .Or. oGdProd:aCols[oGdProd:nAt,_nPosFrt] == "A"
				_TmpPro := Posicione("SA2",1,xFilial("SA2")+oGdProd:aCols[oGdprod:nAt,_nPosFor]+oGdProd:aCols[oGdprod:nAt,_nPosLj],"A2_YTMPPRC")
				_TmpTra := Posicione("SA2",1,xFilial("SA2")+oGdProd:aCols[oGdprod:nAt,_nPosFor]+oGdProd:aCols[oGdprod:nAt,_nPosLj],"A2_YTMPTRN")

				_aPedidos[oGdSol:nAt,1,4] := Iif(DaySum(dDataBase,_TmpPro+_TmpTra) <= oGdSol:aCols[oGdSol:nAt,_nSolDtP], oGdSol:aCols[oGdSol:nAt,_nSolDtP], DaySum(dDataBase,_TmpPro+_TmpTra))

			Else
				_aPedidos[oGdSol:nAt,1,4] := oGdSol:aCols[oGdSol:nAt,_nSolDtP]
			EndIf

			//_aPedidos[oGdSol:nAt,1,4] := oGdSol:aCols[oGdSol:nAt,_nSolDtP]
		EndIf

		If oGdProd:aCols[oGdProd:nAt,1] == "BR_VERDE"
			_aPedidos[oGdSol:nAt,2,2]	:=	oGdProd:aCols[oGdprod:nAt,_nPosFor]
			_aPedidos[oGdSol:nAt,2,3]	:=	oGdProd:aCols[oGdprod:nAt,_nPosLj]
			_aPedidos[oGdSol:nAt,2,4]	:=	oGdProd:aCols[oGdprod:nAt,_nPosTab]
			_aPedidos[oGdSol:nAt,2,5]	:=	oGdProd:aCols[oGdprod:nAt,_nPosMoed]
			_aPedidos[oGdSol:nAt,2,6]	:=	oGdProd:aCols[oGdprod:nAt,_nPosPrc]
		Else
			_aPedidos[oGdSol:nAt,2,2]	:=	""
			_aPedidos[oGdSol:nAt,2,3]	:=	""
			_aPedidos[oGdSol:nAt,2,4]	:=	""
			_aPedidos[oGdSol:nAt,2,5]	:=	0
			_aPedidos[oGdSol:nAt,2,6]	:=	0
		EndIf

	Else
		_aPedidos[oGdSol:nAt,3,1]	:=	"BR_VERMELHO"
		_aPedidos[oGdSol:nAt,3,2]	:=	""
		_aPedidos[oGdSol:nAt,3,3]	:=	""
		_aPedidos[oGdSol:nAt,3,4]	:=	""

		oGdSol:aCols[oGdSol:nAt,1] :=	Iif(oGdProd:aCols[oGdProd:nAt,1] == "BR_VERDE",Iif(oGdProd:aCols[oGdProd:nAt,_nPosFrt] == "F","BR_AMARELO","BR_VERDE"),"BR_VERMELHO")

		_aPedidos[oGdSol:nAt,1,1]	:=	oGdSol:aCols[oGdSol:nAt,1]
		_aPedidos[oGdSol:nAt,2,1]	:=	oGdProd:aCols[oGdProd:nAt,1]

	EndIf
	oGdSol:Refresh()
	oGdProd:Refresh()
	oGdEst:Refresh()

Return

Static Function fAltEst()

	Local _nPosDel	:=	Len(oGdEst:aHeader) + 1	
	Local _nI

	For _nI	:=	1 to Len(oGdEst:aCols)

		If _nI == oGdEst:nAt
			oGdEst:aCols[_nI,_nPosDel]	:=	.T.
		Else
			oGdEst:aCols[_nI,_nPosDel]	:=	.F.
		End

	Next

	oGdEst:Refresh()

Return

Static Function fGeraPed()

	Local _nI
	Local aCols	:=	{}
	Local aHeader	:= {}
	Local _nPosEmis	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2])=="DTEMIS"})
	Local cCboSN	:=	"S=Sim;N=Nao"

	Private oDlgPed		:=	Nil		//Dialog
	Private oGdPed		:=	Nil
	Private _cCod	:=	fGetCod()	//Codigo do Log

	For _nI	:= 1 To Len(_aPedidos)

		Reclock("ZC5",.T.)
		ZC5->ZC5_FILIAL	:=	xFilial("ZC5")
		ZC5->ZC5_CODIGO	:=	_cCod
		ZC5->ZC5_DATA	:=	Date()
		ZC5->ZC5_NUMSC	:=	_aPedidos[_nI,1,2]
		ZC5->ZC5_ITEMSC	:=	_aPedidos[_nI,1,3]
		ZC5->ZC5_EMISSC	:=	oGdSol:ACols[_nI,_nPosEmis]
		ZC5->ZC5_PRFSC	:=	_aPedidos[_nI,1,4]
		ZC5->ZC5_PRODUT	:=	_aPedidos[_nI,1,5]
		ZC5->ZC5_LOCAL	:=	_aPedidos[_nI,1,6]
		ZC5->ZC5_QTDSOL	:=	_aPedidos[_nI,1,7]
		ZC5->ZC5_OBSSC	:=	_aPedidos[_nI,1,8]
		ZC5->ZC5_OBSSC2	:=	_aPedidos[_nI,1,9]
		ZC5->ZC5_FORNEC	:=	_aPedidos[_nI,2,2]
		ZC5->ZC5_LOJA	:=	_aPedidos[_nI,2,3]
		ZC5->ZC5_CODTAB	:=	_aPedidos[_nI,2,4]
		ZC5->ZC5_MOEDA	:=	_aPedidos[_nI,2,5]
		ZC5->ZC5_PRECO	:=	_aPedidos[_nI,2,6]
		ZC5->ZC5_TRANSP	:=	_aPedidos[_nI,3,4]
		ZC5->(MsUnlock())

		If _aPedidos[_nI,1,1] == "BR_VERDE"

			aAdd(aCols,{;
			"BR_AZUL",;
			"",;   					//Pedido Gerado
			"",; 	 				//Erro Gerado
			_aPedidos[_nI,1,2],; 	//Solicitação
			_aPedidos[_nI,1,3],; 	//Item
			_aPedidos[_nI,1,4],; 	//Previsão de Chegada
			"S",; 					//Envia Transp
			"S",; 					//Envia E-mail Autom
			_aPedidos[_nI,1,5],; 	//Produto
			_aPedidos[_nI,1,6],; 	//Local
			_aPedidos[_nI,1,7],; 	//Quantidade
			_aPedidos[_nI,2,2],; 	//Fornecedor
			_aPedidos[_nI,2,3],; 	//Loja
			POSICIONE("SA2",1,xFilial("SA2")+_aPedidos[_nI,2,2]+_aPedidos[_nI,2,3],"A2_NOME"),; //Nome do Fornecedor
			_aPedidos[_nI,2,5],; 	//Moeda
			_aPedidos[_nI,2,6],; 	//Preço
			_aPedidos[_nI,2,4],; 	//Tabela de Preço
			_aPedidos[_nI,3,4],; 	//Transportadora
			Iif(!Empty(_aPedidos[_nI,3,4]),POSICIONE("SA4",1,xFilial("SA4") + _aPedidos[_nI,3,4], "A4_NOME"),""),; //Nome da Transportadora
			.F.	})

		EndIf

	Next
	If Len(aCols) == 0
		MsgInfo("Não existem pedidos para geração!")
		Return
	EndIf

	//Monta aHeader
	Aadd(aHeader,{" "				,"CSTATUS"	,"@BMP", 2, 0, ".F." 	,""    , "C", "", "V" ,"" , "","","V"})
	aAdd(aHeader,{"Pedido"        	,"PEDIDO" 	,"@!"               	, 6   	, 0,,, "C",, })      		// 1
	aAdd(aHeader,{"Erro"        	,"ERRO" 	,"@!"               	, 100   , 0,,, "M",, })      		// 2
	aAdd(aHeader,{"Num. SC"         ,"SOLIC" 	,"@!"               	, 06   	, 0,,, "C",, })      		// 3
	aAdd(aHeader,{"Item"         	,"ITSOL" 	,"@!"               	, 04   	, 0,,, "C",, })      		// 4
	aAdd(aHeader,{"Previs. Chegada" ,"DTPRF" 	,"@!"               	, 06   	, 0,,, "D",, })      		// 5
	aAdd(aHeader,{"Envia Transp" 	,"ENVTRA" 	,"@!"               	, 06   	, 0,,, "C",,,cCboSN })      // 6
	aAdd(aHeader,{"Env E-mail Aut" 	,"ENVAUT" 	,"@!"               	, 06   	, 0,,, "C",,,cCboSN })      // 7	
	aAdd(aHeader,{"Cd. Produto"    	,"CODPRO" 	,"@!"               	, 15   	, 0,,, "C",, })      		// 8
	aAdd(aHeader,{"Local"    		,"LOCPRD" 	,"@!"               	, 02   	, 0,,, "C",, })      		// 9
	aAdd(aHeader,{"Qt. Solic."    	,"QTDSOL" 	,"@E 9,999,999.99"  	, 12   	, 2,,, "N",, })      		// 10
	aAdd(aHeader,{"Cd. Forn."       ,"CODFOR" 	,"@!"               	, 06   	, 0,,, "C",, })      		// 11
	aAdd(aHeader,{"Loja"         	,"LJFOR" 	,"@!"               	, 02   	, 0,,, "C",, })      		// 12
	aAdd(aHeader,{"Nome"        	,"NMFOR" 	,"@!"               	, 80   	, 0,,, "C",, })      		// 13
	aAdd(aHeader,{"Moeda"        	,"MOEDA" 	,"@!"               	, 1   	, 0,,, "N",, })      		// 14
	aAdd(aHeader,{"Preço"    		,"PRECO" 	,"@E 999,999.9999"  	, 12   	, 4,,, "N",, })      		// 15
	aAdd(aHeader,{"Tab. Preço"    	,"TABPRC" 	,"@!"     				, 3   	, 0,,, "C",, })      		// 16
	aAdd(aHeader,{"Transp," 		,"CDTRAN" 	,"@!"               	, 06   	, 0,,, "C",, })      		// 17
	aAdd(aHeader,{"Nome"        	,"NMTRAN" 	,"@!"               	, 40   	, 0,,, "C",, })      		// 18

	aObjects := {}

	AAdd( aObjects, { 100, 215, .T., .T. } )
	AAdd( aObjects, { 100, 185, .T., .T. } )
	AAdd( aObjects, { 100, 025, .T., .F. } )


	aInfoP  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }

	aPosObjP := MsObjSize( aInfoP, aObjects, .T. )

	//Monta tela
	DEFINE MSDIALOG oDlgPed TITLE "Gera Pedidos" FROM aSize[7], aSize[7] TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL OF oMainWnd

	@ aPosObjP[1][1], aPosObjP[1][2] GROUP oGpMRP1 TO aPosObjP[2][3], aPosObjP[2][4] PROMPT "Geração de Pedidos..." OF oDlgPed COLOR 0, 16777215 PIXEL

	oGdPed	:=	MsNewGetDados():New( aPosObj1[1][1] + 10, aPosObj1[1][2] + 5, aPosObj1[2][3] - 5, aPosObj1[2][4] - 5, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", {"DTPRF","ENVTRA","ENVAUT"},, 999, "U_BFG30FOK()", "", "AllwaysTrue", oDlgPed, aHeader, aCols, { || } )

	@ aPosObjP[3][1]+08, aPosObjP[3][4]-040 BUTTON oBt1Ped PROMPT "Cancelar" SIZE 037, 012 OF oDlgPed ACTION (oDlgPed:End()) PIXEL
	@ aPosObjP[3][1]+08, aPosObjP[3][4]-103 BUTTON oBt2Ped PROMPT "Gravar Pedidos"   SIZE 060, 012 OF oDlgPed ACTION  Processa({|| fGrvPed()})  PIXEL

	ACTIVATE MSDIALOG oDlgPed CENTERED

Return

Static Function fGrvPed()

	Local _nI

	For _nI := 1 To Len(oGdPed:aCols)

		fAutoPed(_nI)

		oGdPed:ForceRefresh()

	Next

	oDlgMrp:End()

	oBt2Ped:Hide()

	oBt2Ped:Refresh()

Return

Static Function fAutoPed(_nI)

	Local _aCab		:=	{}
	Local _aItens	:=	{}
	Local _aLinha	:=	{}
	Local _nPosPed	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="PEDIDO"})
	Local _nPosErr	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="ERRO"})

	//Cabeçalho
	Local _nPosFor	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="CODFOR"})
	Local _nPosLj	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="LJFOR"})

	//Itens
	Local _nPosPrd	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="CODPRO"})
	Local _nPosLocal:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="LOCPRD"})
	Local _nPosQtd	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="QTDSOL"})	
	Local _nPosTab	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="TABPRC"})
	Local _nPosSol	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="SOLIC"})	
	Local _nPosIte	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="ITSOL"})
	Local _nPosDPrf	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="DTPRF"})
	Local _nPosTran	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="CDTRAN"})
	Local _nPosPrc	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="PRECO"})
	Local _nPosMoed	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="MOEDA"})
	Local _nPosETra	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="ENVTRA"})
	Local _nPosEAut	:=	aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="ENVAUT"})

	Local _nColeta	:=	fCalcCol(oGdPed:aCols[_nI,_nPosFor],oGdPed:aCols[_nI,_nPosLj],oGdPed:aCols[_nI,_nPosTran])

	If DaySub(oGdPed:aCols[_nI,_nPosDPrf],_nColeta) >= dDataBase

		aadd(_aCab,{"C7_NUM" ,GetNumSC7()})
		aadd(_aCab,{"C7_EMISSAO" ,dDataBase})
		aadd(_aCab,{"C7_FORNECE" ,oGdPed:aCols[_nI,_nPosFor]})
		aadd(_aCab,{"C7_LOJA" ,oGdPed:aCols[_nI,_nPosLj]})
		aadd(_aCab,{"C7_COND" ,fRetCondPg(oGdPed:aCols[_nI,_nPosFor],oGdPed:aCols[_nI,_nPosLj],oGdPed:aCols[_nI,_nPosTab])})		//Aguardar definição da condição
		aadd(_aCab,{"C7_TPFRETE" ,IIf(Empty(oGdPed:aCols[_nI,_nPosTran]),"C","F")})
		aadd(_aCab,{"C7_MOEDA" ,oGdPed:aCols[_nI,_nPosMoed] ,Nil})	

		aadd(_aLinha,{"C7_NUMSC" ,oGdPed:aCols[_nI,_nPosSol],Nil})
		aadd(_aLinha,{"C7_ITEMSC" ,oGdPed:aCols[_nI,_nPosIte],Nil})
		aadd(_aLinha,{"C7_QTDSOL" ,oGdPed:aCols[_nI,_nPosQtd] ,Nil})
		aadd(_aLinha,{"C7_CODTAB" ,oGdPed:aCols[_nI,_nPosTab],Nil})
		aadd(_aLinha,{"C7_PRODUTO" ,oGdPed:aCols[_nI,_nPosPrd],Nil})
		aadd(_aLinha,{"C7_LOCAL" ,oGdPed:aCols[_nI,_nPosLocal],Nil})
		aadd(_aLinha,{"C7_DESCRI" ,POSICIONE("SB1",1,xFilial("SB1") + oGdPed:aCols[_nI,_nPosPrd],"B1_DESC"),Nil})
		aadd(_aLinha,{"C7_QUANT" ,oGdPed:aCols[_nI,_nPosQtd] ,Nil})
		aadd(_aLinha,{"C7_PRECO" ,oGdPed:aCols[_nI,_nPosPrc],Nil})
		aadd(_aLinha,{"C7_TOTAL" ,oGdPed:aCols[_nI,_nPosQtd]*oGdPed:aCols[_nI,_nPosPrc],Nil})
		aadd(_aLinha,{"C7_YDATCHE" ,oGdPed:aCols[_nI,_nPosDPrf],Nil})
		aadd(_aLinha,{"C7_YDTNECE" ,oGdPed:aCols[_nI,_nPosDPrf],Nil})
		aadd(_aLinha,{"C7_DATPRF" ,DaySub(oGdPed:aCols[_nI,_nPosDPrf],_nColeta),Nil})
		aadd(_aLinha,{"C7_YTRANSP" ,IIf(Empty(oGdPed:aCols[_nI,_nPosTran]),"000052",oGdPed:aCols[_nI,_nPosTran]),Nil})
		aadd(_aLinha,{"C7_YENVAUT" ,oGdPed:aCols[_nI,_nPosEAut],Nil})
		aadd(_aLinha,{"C7_YENVTRA" ,oGdPed:aCols[_nI,_nPosETra],Nil})

		aadd(_aItens,_aLinha)

		lMsErroAuto	:=	.F.

		MATA120(1,_aCab,_aItens,3)

		If lMsErroAuto
			oGdPed:aCols[_nI,1] 		:= "BR_VERMELHO"
			oGdPed:aCols[_nI,_nPosPed]	:= "ERRO"
			oGdPed:aCols[_nI,_nPosErr]	:= MostraErro()
		Else
			oGdPed:aCols[_nI,1] 		:= "BR_VERDE"
			oGdPed:aCols[_nI,_nPosPed]	:= SC7->C7_NUM
			oGdPed:aCols[_nI,_nPosErr]	:= ""


		EndIf
	Else
		oGdPed:aCols[_nI,1] 		:= "BR_VERMELHO
		oGdPed:aCols[_nI,_nPosPed]	:= "ERRO"
		oGdPed:aCols[_nI,_nPosErr]	:= "Previsão de entrega do pedido menor que a data atual"
	EndIF
	DbSelectArea("ZC5")
	If ZC5->(DbSeek(xFilial("ZC5") + _cCod + oGdPed:aCols[_nI,_nPosSol] + oGdPed:aCols[_nI,_nPosIte] + oGdPed:aCols[_nI,_nPosPrd]))
		Reclock("ZC5",.F.)
		ZC5->ZC5_PEDIDO	:=	oGdPed:aCols[_nI,_nPosPed]
		ZC5->ZC5_ERRO	:=	oGdPed:aCols[_nI,_nPosErr]
		ZC5->(MsUnlock())
	EndIf

Return

Static Function fGetCod()

	Local _cAlias	:=	GetNextAlias()
	Local _cCod		:=	""

	BeginSql Alias _cAlias

		SELECT ISNULL(MAX(ZC5_CODIGO),'000000') COD
		FROM %TABLE:ZC5% ZC5
		WHERE ZC5_FILIAL = %XFILIAL:ZC5%
		AND %NotDel%
	EndSql

	_cCod	:=	Soma1((_cAlias)->COD)

	(_cAlias)->(DbCloseArea())

Return _cCod

Static Function fRetCondPg(_cForn, _cLoja, _cTab)

	Local _cAlias	:=	GetNextAlias()
	Local _cData	:=	Dtos(dDataBase)
	Local _cRet		:=	""

	BeginSql Alias _cAlias

		SELECT MAX(AIA_CONDPG) COND
		FROM %TABLE:AIA% AIA
		WHERE AIA.AIA_FILIAL = %XFILIAL:AIA%
		AND AIA.AIA_CODFOR = %Exp:_cForn%
		AND AIA.AIA_LOJFOR = %Exp:_cLoja%
		AND AIA.AIA_CODTAB = %Exp:_cTab%
		AND %Exp:_cData% BETWEEN AIA_DATDE AND AIA_DATATE
		AND %NOTDEL%

	ENDSQL

	If !Empty((_cAlias)->COND)
		_cRet	:=	(_caLias)->COND
	Else
		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		If SA2->(Dbseek(xFilial("SA2")+_cForn+_cLoja))
			_cRet	:=	SA2->A2_COND
		EndIf
	EndIF

	(_cAlias)->(DbCloseArea())

Return _cRet

Static Function fCalcCol(_cForn,_cLoja,_cTrans)

	Local _nColeta	:=	0
	Local _aArea	:=	GetArea()
	Local _cAlias	:=	GetNextAlias()

	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	If SA2->(Dbseek(xFilial("SA2")+_cForn+_cLoja))
		_nColeta := Iif(Empty(_cTrans), SA2->A2_YTMPTRN, 0)

		If !Empty(_cTrans)
			BeginSql Alias _cAlias
				SELECT ISNULL(ZC4_TCRGFR,0) TMP
				FROM %TABLE:ZC4% ZC4
				WHERE ZC4.ZC4_FILIAL = %XFILIAL:ZC4%
				AND ZC4.ZC4_TRANSP = %Exp:_cTrans%
				AND ZC4.ZC4_ESTADO = %Exp:SA2->A2_EST%
				AND %NotDel%
			EndSql
			_nColeta := (_cAlias)->TMP
			(_cAlias)->(DbCloseArea())
		EndIf
	Endif

	RestArea(_aArea)

Return _nColeta


User Function BFG30FOK()

	Local _cCampo	:=	ReadVar()
	Local _lRet	:=	.T.
	Local	_nPosPrcS	:=	aScan(oGdProd:aHeader,{|x| Alltrim(x[2])=="PRECOS"})

	If Alltrim(_cCampo)	== "M->MOEDA"	
		If M->MOEDA < 1 .Or. M->MOEDA > 5
			MsgInfo("Moeda Inválida!")
			_lRet	:=	.F.
		EndIf
	Elseif Alltrim(_cCampo)	== "M->PRECOD"
		If M->PRECOD > oGdProd:aCols[oGdProd:nAt,_nPosPrcS]
			MsgInfo("O preço digitado não poderá ser maior que o preço de tabela")
			_lRet	:=	.F.
		EndIF
	ElseIf Alltrim(_cCampo)	== "M->DTPRF"
		If Empty(M->DTPRF)
			MsgInfo("Data prevista de chegada inválida!")
			_lRet	:=	.F.
		ElseIf M->DTPRF < dDataBase
			MsgInfo("Data prevista de chegada inválida!")
			_lRet	:=	.F.
		EndIf
	EndIf
Return _lRet