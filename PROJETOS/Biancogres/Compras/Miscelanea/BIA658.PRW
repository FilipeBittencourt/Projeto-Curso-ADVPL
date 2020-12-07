#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA658
@author Luana Marin Ribeiro
@since 07/05/2019
@version 1.0
@description Tela de follow-up de pedido de compra
@type function
/*/

User Function BIA658()

	If !ValidPerg()
		Return
	EndIf

	Private msReabre    := .F.
	Private _cTabTemp	:=	'##TMP_ARQTRABTMP_BIA658' + cEmpAnt + __cUserID + strzero(seconds()*3500,10)

	Private aSize := MsAdvSize(.F.) //Sem Enchoice

	Private oDlgPed		:=	Nil		//Dialog
	Private oGpPed		:=	Nil		//Grupo

	aObjects := {}

	Private oGdFoll		:=	Nil		//GetDados Follow-up
	Private oGdHist		:=	Nil		//GetDados Histórico
	Private	oGdPed		:=	Nil		//Getdados de Pedidos

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
	DEFINE MSDIALOG oDlgPed TITLE "Pedidos Follow-up" FROM aSize[7], aSize[7] TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL OF oMainWnd

	// Painel Histórico de Pedidos do Fornecedor
	@ aPosObj2[2][1], aPosObj2[2][2] GROUP oGpPed TO aPosObj2[2][3], aPosObj2[2][4] PROMPT "Histórico de Pedidos do Fornecedor" OF oDlgPed COLOR 0, 16777215 PIXEL

	// Painel Follow-up
	@ aPosObj2[1][1], aPosObj2[1][2] GROUP oGpPed TO aPosObj2[1][3], aPosObj2[1][4] PROMPT "Follow-up" OF oDlgPed COLOR 0, 16777215 PIXEL

	// Painel de Pedidos
	@ aPosObj1[1][1], aPosObj1[1][2] GROUP oGpPed TO aPosObj1[1][3], aPosObj1[1][4] PROMPT "Pedidos..." OF oDlgPed COLOR 0, 16777215 PIXEL
	U_BIAMsgRun("Aguarde... Carregando dados (Pedidos)",,{|| fGeraPed() })

	@ aPosObj1[3][1]+08, aPosObj1[3][4]-340 BUTTON oBt1CockSim PROMPT "Parâmetros"        SIZE 050, 012 OF oDlgPed ACTION (msReabre := .T., cj_Fecha := .F., fh_Esc := .T., oDlgPed:End()) PIXEL
	@ aPosObj1[3][1]+08, aPosObj1[3][4]-280 BUTTON oBt2CockSim PROMPT "Pesquisar"         SIZE 050, 012 OF oDlgPed ACTION btnPesq()  PIXEL
	@ aPosObj1[3][1]+08, aPosObj1[3][4]-220 BUTTON oBt2CockSim PROMPT "E-mail Geral"      SIZE 050, 012 OF oDlgPed ACTION Processa({|| btnEvGr()})  PIXEL
	@ aPosObj1[3][1]+08, aPosObj1[3][4]-160 BUTTON oBt2CockSim PROMPT "E-mail Individual" SIZE 050, 012 OF oDlgPed ACTION btnEvEm()  PIXEL
	@ aPosObj1[3][1]+08, aPosObj1[3][4]-100 BUTTON oBt2CockSim PROMPT "Elimina Residuo"   SIZE 050, 012 OF oDlgPed ACTION ElimRes()  PIXEL
	@ aPosObj1[3][1]+08, aPosObj1[3][4]-040 BUTTON oBt1CockSim PROMPT "Cancelar"          SIZE 037, 012 OF oDlgPed ACTION (cj_Fecha := .F., fh_Esc := .T., oDlgPed:End()) PIXEL

	ACTIVATE MSDIALOG oDlgPed CENTERED

	If msReabre
		msReabre    := .F.
		ExecBlock("BIA658",.F.,.F.)
	EndIf

Return	

Static Function ValidPerg()

	local cLoad	    := "BIA658" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(400)
	MV_PAR02 := Space(250)
	MV_PAR03 := Space(006)
	MV_PAR04 := Space(006)
	MV_PAR05 := Space(015)
	MV_PAR06 := Space(015)
	MV_PAR07 := ctod("  /  /  ")
	MV_PAR08 := ctod("  /  /  ")
	MV_PAR09 := Space(006)
	MV_PAR10 := Space(002)
	MV_PAR11 := Space(006)
	MV_PAR12 := Space(002)
	MV_PAR13 := Space(250)

	aAdd( aPergs ,{1,"Grupo(s)       ", MV_PAR01, "", "U_pesqGrup()"   , ''   , '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Armazém(s)     ", MV_PAR02, "", "U_B773Loc()"    , ''   , '.T.', 50, .F.})
	aAdd( aPergs ,{1,"De Pedido      ", MV_PAR03, "", ""               , ''   , '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Até Pedido     ", MV_PAR04, "", "NAOVAZIO()"     , ''   , '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Do Produto     ", MV_PAR05, "", ""               , 'SB1', '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Até Produto    ", MV_PAR06, "", "NAOVAZIO()"     , 'SB1', '.T.', 50, .F.})
	aAdd( aPergs ,{1,"De Dt Chegada  ", MV_PAR07, "", ""               , ''   , '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Até Dt Chegada ", MV_PAR08, "", "NAOVAZIO()"     , ''   , '.T.', 50, .F.})
	aAdd( aPergs ,{1,"De Fornecedor  ", MV_PAR09, "", ""               , 'SA2', '.T.', 50, .F.})
	aAdd( aPergs ,{1,"De Loja        ", MV_PAR10, "", ""               , ''   , '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Até Fornecedor ", MV_PAR11, "", "NAOVAZIO()"     , 'SA2', '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Até Loja       ", MV_PAR12, "", "NAOVAZIO()"     , ''   , '.T.', 50, .F.})
	aAdd( aPergs ,{1,"Comprador(s)   ", MV_PAR13, "", "U_xSelUsrCom()" , ''   , '.T.', 50, .F.})

	If ParamBox(aPergs ,"Pedidos - Follow Up",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,, 1,MV_PAR01)
		MV_PAR02 := ParamLoad(cFileName,, 2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,, 3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,, 4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,, 5,MV_PAR05)
		MV_PAR06 := ParamLoad(cFileName,, 6,MV_PAR06)
		MV_PAR07 := ParamLoad(cFileName,, 7,MV_PAR07)
		MV_PAR08 := ParamLoad(cFileName,, 8,MV_PAR08)
		MV_PAR09 := ParamLoad(cFileName,, 9,MV_PAR09)
		MV_PAR10 := ParamLoad(cFileName,,10,MV_PAR10)
		MV_PAR11 := ParamLoad(cFileName,,11,MV_PAR11)
		MV_PAR12 := ParamLoad(cFileName,,12,MV_PAR12)
		MV_PAR13 := ParamLoad(cFileName,,13,MV_PAR13)

	EndIf

Return lRet

User Function pesqGrup()

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
		If Len(Alltrim(SBM->BM_GRUPO)) == 4
			If aScan(_aGrupos,{|x| x == Alltrim(SBM->BM_GRUPO) + ' - ' + Alltrim(SBM->BM_DESC)}) == 0
				aAdd(_aGrupos,Alltrim(SBM->BM_GRUPO) + ' - ' + Alltrim(SBM->BM_DESC))
				MvParDef	+=	SBM->BM_GRUPO
				_nElemen++
			EndIf
		EndIf
		SBM->(DbSkip())
	EndDo

	_nTamKey	:=	Len(MvParDef)

	If f_Opcoes(@MvPar,"Seleção de Grupos",_aGrupos,MvParDef,,,.F.,4,_nElemen)
		lRet	:= .T.
		&MvRet := mvpar 	
	EndIf
	RestArea(_aArea)

Return lRet

//Cria o MsNewgetdados do Quadro Pedidos
Static Function fGeraPed()

	Local aHeader := {}
	Local aCols := {}
	Local _cAlias := GetNextAlias()
	Local _cQry := ""
	Local _nI
	Local _cInGrp := ""
	Local _cInLocal := ""
	Local _cUsrComp := ""

	//Arruma filtro de grupo
	For _nI	:=	1 to Len(MV_PAR01) STEP 4
		If Substr(MV_PAR01,_nI,4) <> '****'
			_cInGrp +=	"'" + Substr(MV_PAR01,_nI,4) + "',"
		EndIf
	Next
	If Empty(_cInGrp)
		_cInGrp	:=	"('')"
	Else
		_cInGrp	:=	"(" + Substr(_cInGrp,1,Len(_cInGrp)-1) + ")"
	End

	//Arruma filtro de local
	For _nI	:=	1 to Len(MV_PAR02) STEP 2
		If Substr(MV_PAR02,_nI,2) <> '**'
			_cInLocal +=	"'" + Substr(MV_PAR02,_nI,2) + "',"
		EndIf
	Next
	If Empty(_cInLocal)
		_cInLocal	:=	"('')"
	Else
		_cInLocal	:=	"(" + Substr(_cInLocal,1,Len(_cInLocal)-1) + ")"
	End

	//Arruma filtro de Comprador
	For _nI	:=	1 to Len(MV_PAR13) STEP 6
		If Substr(MV_PAR13,_nI,6) <> '******'
			_cUsrComp +=	"'" + Substr(MV_PAR13,_nI,6) + "',"
		EndIf
	Next
	If Empty(_cUsrComp)
		_cUsrComp	:=	"('')"
	Else
		_cUsrComp	:=	"(" + Substr(_cUsrComp,1,Len(_cUsrComp)-1) + ")"
	End

	_cQry := "SELECT SC7.C7_FILIAL AS FILIAL " + CRLF
	_cQry += "	, SC7.C7_YEMAIL AS YEMAIL" + CRLF
	_cQry += "	, SC7.C7_NUM AS PED_NUM" + CRLF
	_cQry += "	, SC7.C7_ITEM AS PED_ITEM" + CRLF
	_cQry += "	, SA2.A2_COD AS FORN_COD" + CRLF
	_cQry += "	, SA2.A2_LOJA AS FORN_LOJA" + CRLF
	_cQry += "	, SA2.A2_NOME AS FORN_NOME" + CRLF
	_cQry += "	, SA2.A2_TEL AS FORN_TEL" + CRLF
	_cQry += "	, SA2.A2_EMAIL AS FORN_EMAIL" + CRLF
	_cQry += "	, SC7.C7_PRODUTO AS PROD_COD" + CRLF
	_cQry += "	, SC7.C7_DESCRI AS PROD_DESC" + CRLF //Ticket 22894 Pablo S. Nascimento
	_cQry += "	, SC7.C7_QUANT AS QTD_PED" + CRLF
	_cQry += "	, SC7.C7_QUJE AS QTD_ENT" + CRLF
	_cQry += "	, SC7.C7_QTDACLA AS QTD_CLAS" + CRLF
	_cQry += "	, SC7.C7_EMISSAO AS DT_EMISSAO" + CRLF
	_cQry += "	, SC7.C7_DATPRF AS DT_ENTREGA" + CRLF
	_cQry += "	, SC7.C7_YDATCHE AS DT_CHEGADA" + CRLF
	_cQry += "	, SC7.C7_YFOLLOW AS FOLLOWUP" + CRLF
	_cQry += "	, SC7.C7_YFOLLOW AS FOLLOWUPT" + CRLF	
	_cQry += "	, SC7.C7_YOBSCOM AS OBS" + CRLF
	_cQry += "	, SC1.C1_SOLICIT AS SOLIC" + CRLF
	_cQry += "	, SY1.Y1_NOME AS COMPRADOR" + CRLF
	_cQry += "FROM " + RETSQLNAME("SC7") + " SC7 WITH(NOLOCK)" + CRLF
	_cQry += "	INNER JOIN " + RETSQLNAME("SA2") + " SA2 WITH(NOLOCK) ON SA2.A2_FILIAL = " + ValtoSql(xFilial("SA2")) + CRLF
	_cQry += "		AND SC7.C7_FORNECE = SA2.A2_COD" + CRLF
	_cQry += "		AND SC7.C7_LOJA = SA2.A2_LOJA" + CRLF
	_cQry += "		AND SA2.D_E_L_E_T_ = ''" + CRLF
	_cQry += "	INNER JOIN " + RETSQLNAME("SB1") + " SB1 WITH(NOLOCK) ON SB1.B1_COD = SC7.C7_PRODUTO" + CRLF
	_cQry += "		AND SB1.B1_GRUPO IN " + _cInGrp + CRLF
	_cQry += "		AND SB1.B1_MSBLQL <> '1'" + CRLF
	_cQry += "		AND SB1.D_E_L_E_T_ = ''" + CRLF
	_cQry += "	LEFT JOIN " + RETSQLNAME("SY1") + " SY1 WITH(NOLOCK) ON Y1_FILIAL = " + ValtoSql(xFilial("SY1")) + CRLF
	_cQry += "		AND SC7.C7_USER = SY1.Y1_USER" + CRLF
	_cQry += "		AND SY1.D_E_L_E_T_ = ''" + CRLF
	_cQry += "	LEFT JOIN " + RETSQLNAME("SC1") + " SC1 WITH(NOLOCK) ON SC1.C1_FILIAL = " + ValtoSql(xFilial("SC1")) + CRLF
	_cQry += "		AND SC1.C1_NUM = SC7.C7_NUMSC" + CRLF
	_cQry += "		AND SC1.C1_ITEM = SC7.C7_ITEMSC" + CRLF
	_cQry += "		AND SC1.D_E_L_E_T_ = ' '" + CRLF
	_cQry += "WHERE SC7.C7_FILIAL = " + ValtoSql(xFilial("SC7")) + CRLF
	_cQry += "	AND SC7.C7_NUM BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' " + CRLF
	_cQry += "	AND SC7.C7_PRODUTO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' " + CRLF
	_cQry += "	AND SC7.C7_YDATCHE BETWEEN '" + dtos(MV_PAR07) + "' AND '" + dtos(MV_PAR08) + "' " + CRLF
	_cQry += "	AND SC7.C7_FORNECE + SC7.C7_LOJA BETWEEN '" + MV_PAR09 + MV_PAR10 + "' AND '" + MV_PAR11 + MV_PAR12 + "' " + CRLF
	_cQry += "	AND SC7.C7_RESIDUO = ''" + CRLF
	_cQry += "	AND SC7.C7_ENCER <> 'E'" + CRLF
	_cQry += "	AND SC7.C7_QUANT - SC7.C7_QUJE > 0" + CRLF
	//_cQry += "	AND SC7.C7_QTDACLA = 0" + CRLF
	_cQry += "	AND SC7.C7_CONAPRO = 'L'" + CRLF
	_cQry += "	AND SC7.D_E_L_E_T_ = ''" + CRLF
	_cQry += "	AND SC7.C7_LOCAL IN " + _cInLocal + CRLF
	_cQry += "	AND SC7.C7_USER IN " + _cUsrComp + CRLF
	_cQry += "ORDER BY SC7.C7_YDATCHE, SA2.A2_COD, SC7.C7_NUM, SC7.C7_ITEM" + CRLF

	IndPed := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.F.,.T.)

	Aadd(aHeader,{" "				,"CSTATUS"		,"@BMP"					,02,0,".F.",""	,"C","","V","","","","V"})
	aAdd(aHeader,{"Fil."			,"FILIAL"		,"@!"					,02,0,,			,"C",,}) //1
	aAdd(aHeader,{"E-mail"			,"YEMAIL"		,"@!"					,01,0,,			,"C",,}) //1X
	aAdd(aHeader,{"Num.Ped."		,"PED_NUM"		,"@!"					,06,0,,			,"C",,}) //2
	aAdd(aHeader,{"Item"			,"PED_ITEM"		,"@!"					,04,0,,			,"C",,}) //3
	aAdd(aHeader,{"Cód.Fornec."		,"FORN_COD"		,"@!"					,06,0,,			,"C",,}) //4
	aAdd(aHeader,{"Loja"			,"FORN_LOJA"	,"@!"					,02,0,,			,"C",,}) //5
	aAdd(aHeader,{"Fornecedor"		,"FORN_NOME"	,"@!"					,40,0,,			,"C",,}) //6
	aAdd(aHeader,{"Telefone"		,"FORN_TEL"		,"@!"					,15,0,,			,"C",,}) //7
	aAdd(aHeader,{"E-mail"			,"FORN_EMAIL"	,"@!"					,30,0,,			,"C",,}) //8
	aAdd(aHeader,{"Cód.Prod."		,"PROD_COD"		,"@!"					,10,0,,			,"C",,}) //9
	aAdd(aHeader,{"Produto"			,"PROD_DESC"	,"@!"					,150,0,,		,"C",,}) //10
	aAdd(aHeader,{"Qtd."			,"QTD_PED"		,"@E 999,999,999.99"	,14,2,,			,"N",,}) //11
	aAdd(aHeader,{"Qtd.Entregue"	,"QTD_ENT"		,"@E 999,999,999.99"	,14,2,,			,"N",,}) //12
	aAdd(aHeader,{"Qtd.Classif."	,"QTD_CLAS"		,"@E 999,999,999.99"	,14,2,,			,"N",,}) //13	
	aAdd(aHeader,{"Dt.Emissão"		,"DT_EMISSAO"	,"@!"					,10,0,,			,"D",,}) //14
	aAdd(aHeader,{"Dt.Entrega"		,"DT_ENTREGA"	,"@!"					,10,0,,			,"D",,}) //15
	aAdd(aHeader,{"Dt.Chegada"		,"DT_CHEGADA"	,"@!"					,10,0,,			,"D",,}) //16
	aAdd(aHeader,{"Follow-up"		,"FOLLOWUP"		,"@!"					,50,0,,			,"C",,}) //17
	aAdd(aHeader,{"Follow-up Todos"	,"FOLLOWUPT"	,"@!"					,50,0,,			,"C",,}) //17X	
	aAdd(aHeader,{"Obs."			,"OBS"			,"@!"					,50,0,,			,"C",,}) //18
	aAdd(aHeader,{"Solicitante"		,"SOLIC"		,"@!"					,20,0,,			,"C",,}) //19
	aAdd(aHeader,{"Comprador"		,"COMPRADOR"	,"@!"					,20,0,,			,"C",,}) //20

	While (_cAlias)->(!EOF())

		aAdd(aCols,{If ((_cAlias)->QTD_ENT == 0, "BR_VERDE", "BR_AMARELO"),;	
		(_cAlias)->FILIAL,;	
		"S" /*(_cAlias)->YEMAIL*/ ,;
		(_cAlias)->PED_NUM,;
		(_cAlias)->PED_ITEM,;	
		(_cAlias)->FORN_COD,;	
		(_cAlias)->FORN_LOJA,;
		(_cAlias)->FORN_NOME,;	
		(_cAlias)->FORN_TEL,;
		(_cAlias)->FORN_EMAIL,;	
		(_cAlias)->PROD_COD,;
		(_cAlias)->PROD_DESC,;	
		(_cAlias)->QTD_PED,;
		(_cAlias)->QTD_ENT,;
		(_cAlias)->QTD_CLAS,;
		Stod((_cAlias)->DT_EMISSAO),;
		Stod((_cAlias)->DT_ENTREGA),;
		Stod((_cAlias)->DT_CHEGADA),;
		(_cAlias)->FOLLOWUP,;
		(_cAlias)->FOLLOWUPT,;
		(_cAlias)->OBS,;
		(_cAlias)->SOLIC,;
		(_cAlias)->COMPRADOR,;
		.F.	})
		(_cAlias)->(DbSkip())

	EndDo

	Ferase(IndPed+GetDBExtension())     //arquivo de trabalho
	Ferase(IndPed+OrdBagExt())          //indice gerado
	(_cAlias)->(DbCloseArea())

	oGdPed := MsNewGetDados():New(aPosObj1[1][1] + 10, aPosObj1[1][2] + 5, aPosObj1[1][3] - 5, aPosObj1[1][4] - 5, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", {"YEMAIL","DT_ENTREGA","DT_CHEGADA","FOLLOWUP", "FOLLOWUPT", "OBS"},, 999, "U_B658POK()", "", "AllwaysTrue", oDlgPed, aHeader, aCols, { || fAltPed() } )

	oGdPed:oBrowse:bLDblClick := {|| oGdPed:EditCell(), fDblPed()}	

Return

Static Function fAltPed()

	LOCAL _nI

	For _nI	:=	1 to Len(oGdPed:aCols)

		If _nI == oGdPed:nAt
			oGdPed:aCols[_nI,Len(oGdPed:aHeader) + 1]	:=	.T.
		Else
			oGdPed:aCols[_nI,Len(oGdPed:aHeader) + 1]	:=	.F.
		End

	Next

	oGdPed:Refresh()	

	fGeraFoll()	
	oGdFoll:Show()
	fPopFoll()

	fGeraHist()	
	oGdHist:Show()
	fPopHist()

Return

Static Function fGeraFoll()

	Local	aHeader	:=	{}
	Local	aCols	:=	{}

	aAdd(aHeader,{"Item"		,"FOLL_ITEM"	,"@!",04,0,,,"C",, })      	// 1
	aAdd(aHeader,{"Data"		,"FOLL_DATA"	,"@!",10,0,,,"D",, })     	// 2
	aAdd(aHeader,{"Item Ped."	,"PED_ITEM"		,"@!",04,0,,,"C",, })    	// 3
	aAdd(aHeader,{"Follow-up"	,"FOLL_DESC"	,"@!",50,0,,,"C",, })      	// 4

	oGdFoll	:=	MsNewGetDados():New( aPosObj2[1][1] + 10, aPosObj2[1][2] + 5, aPosObj2[1][3] - 5, aPosObj2[1][4] - 5, GD_INSERT+GD_UPDATE, pedLinOk(), "AllwaysTrue", "+FOLL_ITEM", {"FOLL_DESC"},, 999, "U_B658HOK()", "", "AllwaysTrue", oDlgPed, aHeader, aCols )

	oGdFoll:lInsert := .F.
	oGdFoll:lUpdate := .F.
	oGdFoll:lDelete := .F.

Return

Static Function pedLinOk()
	//MsgInfo("Histórico não pode ser em branco!")
Return()

Static Function fPopFoll()

	Local _cAlias   := GetNextAlias()
	Local _nPosFoll := aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="PED_NUM"})
	Local _cFoll    := oGdPed:Acols[oGdPed:nAt,_nPosFoll]
	Local _nPosFil  := aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="FILIAL"})
	Local _cFollFi  := oGdPed:Acols[oGdPed:nAt,_nPosFil]
	Local aCols     := {}

	BeginSql Alias _cAlias
		SELECT ZAZ_ITEM AS FOLL_ITEM
		, ZAZ_DATA AS FOLL_DATA
		, ZAZ_ITEMPE AS PED_ITEM
		, ZAZ_HIST AS FOLL_DESC
		FROM %TABLE:ZAZ% ZAZ
		WHERE ZAZ.ZAZ_FILIAL = %Exp:_cFollFi%
		AND ZAZ.ZAZ_PEDIDO = %Exp:_cFoll%
		AND ZAZ.%NotDel%
		ORDER BY ZAZ_ITEM, ZAZ_DATA, ZAZ_ITEMPE
	EndSql

	If (_cAlias)->(!EOF())

		While (_cAlias)->(!EOF())
			aAdd(aCols,{ (_cAlias)->FOLL_ITEM,;
			Stod((_cAlias)->FOLL_DATA),;
			(_cAlias)->PED_ITEM,;
			(_cAlias)->FOLL_DESC,;
			.F.	})
			(_cAlias)->(DbSkip())
		EndDo

		oGdFoll:GoTop()
		oGdFoll:aCols	:=	aCols

	Else

		oGdFoll:aCols	:=	aCols
		oGdFoll:AddLine( .T. , .T., .T. )
	EndIf	

	oGdFoll:Refresh()

	(_cAlias)->(DbCloseArea())

Return ()

Static Function fGeraHist()

	Local	aHeader	:=	{}
	Local	aCols	:=	{}

	aAdd(aHeader,{"Fornecedor"	,"HIST_FORN"	,"@!",04,0,,,"C",, })      	// 1
	aAdd(aHeader,{"Loja"		,"HIST_LOJA"	,"@!",02,0,,,"C",, })     	// 2
	aAdd(aHeader,{"Pedido"		,"HIST_PED"		,"@!",06,0,,,"C",, })     	// 3
	aAdd(aHeader,{"Item Ped."	,"HIST_ITEM"	,"@!",04,0,,,"C",, })    	// 4
	aAdd(aHeader,{"NF"			,"HIST_DOC"		,"@!",09,0,,,"C",, })      	// 5
	aAdd(aHeader,{"Série"		,"HIST_SERIE"	,"@!",03,0,,,"C",, })      	// 6
	aAdd(aHeader,{"Dt Cheg PC"	,"HIST_DTCHE"	,"@!",10,0,,,"D",, })    	// 7
	aAdd(aHeader,{"Dt Dig NF"	,"HIST_DIG"		,"@!",10,0,,,"D",, })      	// 8

	oGdHist	:=	MsNewGetDados():New( aPosObj2[2][1] + 10, aPosObj2[2][2] + 5, aPosObj2[2][3] - 5, aPosObj2[2][4] - 5, 0, "AllwaysTrue", "AllwaysTrue", "", {},, 999, , "", "AllwaysTrue", oDlgPed, aHeader, aCols )

	oGdHist:lInsert := .F.
	oGdHist:lUpdate := .F.
	oGdHist:lDelete := .F.

Return

Static Function fPopHist()

	Local _cAlias := GetNextAlias()
	Local _pHisFor := aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="FORN_COD"})
	Local _cHisFor := oGdPed:Acols[oGdPed:nAt,_pHisFor]
	Local _pHisLoj := aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="FORN_LOJA"})
	Local _cHisLoj := oGdPed:Acols[oGdPed:nAt,_pHisLoj]
	Local _pHisFil := aScan(oGdPed:aHeader,{|x| Alltrim(x[2])=="FILIAL"})
	Local _cHisFil := oGdPed:Acols[oGdPed:nAt,_pHisFil]
	Local aCols := {}

	BeginSql Alias _cAlias
		SELECT TOP 10 SC7.C7_FORNECE HIST_FORN
		, SC7.C7_LOJA	HIST_LOJA
		, SC7.C7_NUM HIST_PED
		, SC7.C7_ITEM HIST_ITEM
		, SD1.D1_DOC HIST_DOC
		, SD1.D1_SERIE HIST_SERIE
		, SC7.C7_YDATCHE HIST_DTCHE
		, SD1.D1_DTDIGIT HIST_DIG
		FROM %TABLE:SC7% SC7
		INNER JOIN %TABLE:SD1% SD1 ON SC7.C7_FILIAL = SD1.D1_FILIAL
		AND SC7.C7_FORNECE = SD1.D1_FORNECE
		AND SC7.C7_LOJA = SD1.D1_LOJA
		AND SC7.C7_NUM = SD1.D1_PEDIDO
		AND SC7.C7_ITEM = SD1.D1_ITEMPC
		AND SC7.C7_PRODUTO = SD1.D1_COD
		AND SD1.%NotDel%
		WHERE SC7.C7_FILIAL = %Exp:_cHisFil%
		AND SC7.C7_RESIDUO = ''
		AND SC7.C7_ENCER <> 'E'
		AND SC7.C7_FORNECE = %Exp:_cHisFor%
		AND SC7.C7_LOJA = %Exp:_cHisLoj%
		AND SC7.%NotDel%
		ORDER BY SC7.C7_YDATCHE DESC, SD1.D1_DTDIGIT, SC7.C7_NUM, SC7.C7_ITEM
	EndSql

	If (_cAlias)->(!EOF())
		While (_cAlias)->(!EOF())
			aAdd(aCols,{ (_cAlias)->HIST_FORN,;
			(_cAlias)->HIST_LOJA,;
			(_cAlias)->HIST_PED,;
			(_cAlias)->HIST_ITEM,;
			(_cAlias)->HIST_DOC,;
			(_cAlias)->HIST_SERIE,;
			Stod((_cAlias)->HIST_DTCHE),;
			Stod((_cAlias)->HIST_DIG),;
			.F.	})
			(_cAlias)->(DbSkip())
		EndDo

		oGdHist:GoTop()
		oGdHist:aCols := aCols
	Else
		oGdHist:aCols := aCols
		oGdHist:AddLine( .T. , .T. )
	EndIf

	oGdHist:Refresh()

	(_cAlias)->(DbCloseArea())

Return ()

Static Function fDblPed()

	oGdPed:Refresh()
	oGdFoll:Refresh()

Return

User Function B658POK()

	Local _cCampo   := ReadVar()
	Local _lRet     := .T.
	Local okPedFil  := GdFieldGet("FILIAL",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local okPedNum  := GdFieldGet("PED_NUM",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local okPedIte  := GdFieldGet("PED_ITEM",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local okPedFol  := GdFieldGet("FOLLOWUP",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local okPedObs  := GdFieldGet("OBS",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local okDado    := ""
	Local msColPC   := aScan(oGdPed:aHeader,{|x| AllTrim(x[2]) == "PED_NUM"})
	Local msFollIt  := aScan(oGdPed:aHeader,{|x| AllTrim(x[2]) == "FOLLOWUP"})
	Local msFollTd  := aScan(oGdPed:aHeader,{|x| AllTrim(x[2]) == "FOLLOWUPT"})
	Local _nI

	If Alltrim(_cCampo)	== "M->DT_ENTREGA"

		If Empty(M->DT_ENTREGA)
			MsgInfo("Data Inválida!")
			_lRet	:=	.F.
		Else
			okDado:= dtos(M->DT_ENTREGA)
			GrvDd658(okPedFil, okPedNum, okPedIte, okDado, "A DATA DE ENTREGA FOI ALTERADA PARA: ", "DE", .T.)
		EndIf

	ElseIf Alltrim(_cCampo)	== "M->DT_CHEGADA"

		If Empty(M->DT_CHEGADA)
			MsgInfo("Data Inválida!")
			_lRet	:=	.F.
		Else
			okDado:= dtos(M->DT_CHEGADA)
			GrvDd658(okPedFil, okPedNum, okPedIte, okDado, "A DATA DE CHEGADA FOI ALTERADA PARA: ", "DC", .T.)
		EndIf

	ElseIf Alltrim(_cCampo)	== "M->FOLLOWUP"

		If Empty(M->FOLLOWUP)

			MsgInfo("Follow-up Inválido!!")
			_lRet	:= .F.

		Else

			okDado:= M->FOLLOWUP
			GrvDd658(okPedFil, okPedNum, okPedIte, okDado, "FOLLOW-UP ANTIGO: " + AllTrim(okPedFol), "FU", .T.)

		EndIf

	ElseIf Alltrim(_cCampo)	== "M->FOLLOWUPT"

		If Empty(M->FOLLOWUPT)

			MsgInfo("Follow-up Todos os Itens Inválido!!")
			_lRet	:= .F.

		Else

			okDado := M->FOLLOWUPT

			GrvDd658(okPedFil, okPedNum, okPedIte, okDado, "FOLLOW-UP ANTIGO: " + AllTrim(okPedFol), "FU", .T.)

			// Replica descrição para todos os itens da Grid
			For _nI	:= 1 to Len(oGdPed:aCols)

				If oGdPed:aCols[_nI, msColPC] == okPedNum

					oGdPed:aCols[_nI, msFollIt] := Alltrim(okDado)
					oGdPed:aCols[_nI, msFollTd] := Alltrim(okDado)

					If _nI <> oGdPed:nAt
						msPedIte := GdFieldGet("PED_ITEM",_nI,,oGdPed:aHeader,oGdPed:aCols)
						GrvDd658(okPedFil, okPedNum, msPedIte, okDado, "FOLLOW-UP ANTIGO: " + AllTrim(okPedFol), "FU", .T.)
					EndIf

				EndIf 

			Next

		EndIf		

	ElseIf Alltrim(_cCampo)	== "M->OBS"

		If !Empty(M->OBS)
			okDado:= M->OBS
			GrvDd658(okPedFil, okPedNum, okPedIte, okDado, "OBS ANTIGA: " + AllTrim(okPedObs), "OB", .T.)
		EndIf

	EndIf

Return _lRet

Static Function GrvDd658(pedFil, pedNum, pedItem, histDado, dadoDesc, nomCampo, gravPed)

	Local proxItem := ""
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL := " SELECT ISNULL(MAX(ZAZ_ITEM), '0000') AS ZAZ_ITEM "
	cSQL += "   FROM "+ RetSQLName("ZAZ")
	cSQL += "  WHERE ZAZ_FILIAL  = "+ ValToSQL(pedFil)
	cSQL += "    AND ZAZ_PEDIDO = " + ValToSQL(pedNum)
	cSQL += "    AND D_E_L_E_T_ = ' ' "
	TcQuery cSQL New Alias (cQry)
	proxItem := Soma1((cQry)->ZAZ_ITEM)

	Reclock("ZAZ", .T.)
	ZAZ->ZAZ_FILIAL  := pedFil
	ZAZ->ZAZ_ITEM    := proxItem
	ZAZ->ZAZ_PEDIDO  := pedNum
	ZAZ->ZAZ_ITEMPE  := pedItem
	ZAZ->ZAZ_DATA    := dDataBase
	ZAZ->ZAZ_HIST    := Iif(Substr(nomCampo,1,1) == "D", dadoDesc + Substr(histDado,7,2) + "/" + Substr(histDado,5,2) + "/" + Substr(histDado,1,4), dadoDesc)
	ZAZ->(MsUnlock())

	DbSelectArea("SC7")
	DbSetOrder(1)	
	If DbSeek(xFilial("SC7") + pedNum + pedItem)

		Reclock("SC7", .F.)

		If nomCampo == "DE"

			SC7->C7_DATPRF := stod(histDado)

		ElseIf nomCampo == "DC"

			SC7->C7_YDATCHE := stod(histDado)

		ElseIf nomCampo == "FU"

			SC7->C7_YFOLLOW := histDado

		ElseIf nomCampo == "OB"

			SC7->C7_YOBSCOM := histDado

		ElseIf nomCampo == "EM"

			SC7->C7_YEMAIL := "S"

		EndIf

		MsUnlock()

	EndIf

	fPopFoll()

	oGdFoll:Refresh()

Return

User Function B658HOK()

	Local _cCampo	:= ReadVar()
	Local okPedFil  := GdFieldGet("FILIAL",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local okFollIte := GdFieldGet("FOLL_ITEM",oGdFoll:nAt,,oGdFoll:aHeader,oGdFoll:aCols)
	Local okPedNum  := GdFieldGet("PED_NUM",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local okDado    := ""
	Local _lRet	    := .T.

	If oGdFoll:aCols[oGdFoll:nAt,Len(oGdFoll:aHeader) + 1]	==	.F.	
		_lRet := .F.
	Else
		If Alltrim(_cCampo)	== "M->HIST_DESC"	
			If Empty(M->FOLL_DESC)
				MsgInfo("Descrição não pode ser em branco!")
				_lRet	:=	.F.
			Else
				okDado := M->FOLL_DESC
				GrvDdFoll(okPedFil,okFollIte,okPedNum,okDado)
			EndIf
		EndIf
	EndIf

Return _lRet

Static Function GrvDdFoll(pedFil, follNum, pedNum, follDesc)

	Reclock("ZAZ",.T.)
	ZAZ->ZAZ_FILIAL := pedFil
	ZAZ->ZAZ_ITEM := follNum
	ZAZ->ZAZ_PEDIDO := pedNum
	ZAZ->ZAZ_ITEMPE := ""
	ZAZ->ZAZ_DATA := dDataBase
	ZAZ->ZAZ_HIST := follDesc
	ZAZ->(MsUnlock())

	fPopFoll()
	oGdFoll:Refresh()

Return

Static Function ElimRes()

	Local okPedFil := GdFieldGet("FILIAL",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local okPedNum := GdFieldGet("PED_NUM",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local okPedItem := GdFieldGet("PED_ITEM",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local okPedObs := GdFieldGet("OBS",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local iLinha := oGdPed:nAt

	If AllTrim(okPedObs) == ""
		MsgInfo("NÃO ELIMINADO! Favor preencher o campo observação com o motivo da eliminição por resíduo!")
	Else	
		dbSelectArea("SC7")
		dbSetOrder(1)
		If dbSeek(okPedFil+okPedNum+okPedItem)
			While !SC7->(Eof()) .And. SC7->C7_FILIAL == okPedFil .And. SC7->C7_NUM == okPedNum .And. SC7->C7_ITEM == okPedItem
				While !Reclock("SC7",.F.);EndDo		
				SC7->C7_RESIDUO := "S"
				SC7->C7_ENCER := "E"
				SC7->(MsUnlock())
				SC7->(DbSkip())
			EndDo
		EndIf

		fGeraPed()
		oGdPed:GoTo(iLinha)

		MsgInfo("Item do pedido eliminado com sucesso!")	
	EndIf

Return

Static Function btnEvEm()

	Local okPedFil := GdFieldGet("FILIAL",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local okPedNum := GdFieldGet("PED_NUM",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local okForn   := GdFieldGet("FORN_COD",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local okLoja   := GdFieldGet("FORN_LOJA",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local okNome   := GdFieldGet("FORN_NOME",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Local okEmail  := GdFieldGet("FORN_EMAIL",oGdPed:nAt,,oGdPed:aHeader,oGdPed:aCols)
	Private AAREA  := GetArea()
	Private sMens  := PADR("Saudações," + CRLF + CRLF + "O pedido de compra " + okPedNum + " encontra-se em atraso." + CRLF + "Gentileza justificar o atraso e informar nova data de entrega." + CRLF + CRLF + "Sds, Comprador." + CRLF + CRLF + CRLF + "Favor responder para todos",255)
	Private sAssu  := "Follow-up: Pedido de compra " + okPedNum + " em atraso."

	DEFINE MSDIALOG oDlg TITLE "Envio de e-mail para o fornecedor" FROM 200,500 TO 800,1200 PIXEL

	@ 005,005 TO 296,348 LABEL "Pedido: " + okPedNum + " Fornecedor: " + okForn + " Loja: " + okLoja + " Razão Social: " + okNome OF oDlg PIXEL

	@ 020, 010 SAY oSay1 PROMPT "Assunto: " SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 020, 283 Button "Assunto Original" Size 060,010 PIXEL OF oDlg Action(btnAssuOr(okPedNum))
	@ 020, 050 GET oGet1 VAR sAssu OF oDlg SIZE 150, 007 COLORS 0, 16777215 PIXEL

	@ 040, 010 SAY oSay2 PROMPT "Mensagem: " SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 037, 283 Button "Msg. Original" Size 060,010 PIXEL OF oDlg Action(btnMsgOr(okPedNum))
	@ 050, 010 GET oGet2 VAR sMens OF oDlg MULTILINE SIZE 334, 220 COLORS 0, 16777215 HSCROLL PIXEL

	@ 280,120 Button "Env. E-mail Forn." Size 060,010 PIXEL OF oDlg Action(Iif(btnEnviar(okEmail, okPedFil, okPedNum),oDlg:End(),.F.))
	@ 280,190 Button "Fechar" Size 060,010 PIXEL OF oDlg Action(cj_Fecha := .F., fh_Esc := .T., oDlg:End())

	ACTIVATE MSDIALOG ODLG CENTERED

	RESTAREA(AAREA)

Return

Static Function btnEnviar(okEmail, okPedFil, okPedNum)

	Local cMail := okEmail + ";" + UsrRetMail(__cUserId)
	Local lRet  := U_BIAEnvMail(,cMail, AllTrim(sAssu), AllTrim(sMens))

	If lRet == .T.
		GrvDd658(okPedFil, okPedNum, "", "", "E-MAIL ENVIADO COM SUCESSO PARA FORNECEDOR", "EM", .T.)

	Else
		GrvDd658(okPedFil, okPedNum, "", "", "ERRO AO ENVIAR E-MAIL PARA O FORNECEDOR", "", .T.)

	EndIf

Return lRet

Static Function btnEvGr()

	Local aArea  := GetArea()
	Local okPedFil 
	Local okyEmail 
	Local okPedNum 
	Local okForn   
	Local okLoja   
	Local okNome   
	Local okEmail  
	Local _nI 
	Local OldNumPed
	Local cMail
	Local lRet

	Private sMens  
	Private sAssu

	If MsgNOYES("Confirma envio de e-mail para TODOS OS FORNECEDORES listados na tela?.", "ATENÇÃO!!!")


		For _nI	:= 1 to Len(oGdPed:aCols)

			okPedFil := GdFieldGet("FILIAL",_nI,,oGdPed:aHeader,oGdPed:aCols)
			okyEmail := GdFieldGet("YEMAIL",_nI,,oGdPed:aHeader,oGdPed:aCols)
			okPedNum := GdFieldGet("PED_NUM",_nI,,oGdPed:aHeader,oGdPed:aCols)
			okForn   := GdFieldGet("FORN_COD",_nI,,oGdPed:aHeader,oGdPed:aCols)
			okLoja   := GdFieldGet("FORN_LOJA",_nI,,oGdPed:aHeader,oGdPed:aCols)
			okNome   := GdFieldGet("FORN_NOME",_nI,,oGdPed:aHeader,oGdPed:aCols)
			okEmail  := GdFieldGet("FORN_EMAIL",_nI,,oGdPed:aHeader,oGdPed:aCols)
			sMens    := PADR("Saudações," + CRLF + CRLF + "O pedido de compra " + okPedNum + " encontra-se em atraso." + CRLF + "Gentileza justificar o atraso e informar nova data de entrega." + CRLF + CRLF + "Sds, Comprador." + CRLF + CRLF + CRLF + "Favor responder para todos",255)
			sAssu    := "Follow-up: Pedido de compra " + okPedNum + " em atraso."

			If okyEmail == "S"

				If  okPedNum <> OldNumPed

					OldNumPed := okPedNum
					cMail := okEmail + ";" + UsrRetMail(__cUserId)
					lRet  := U_BIAEnvMail(,cMail, AllTrim(sAssu), AllTrim(sMens))

				EndIf

				If lRet == .T.
					GrvDd658(okPedFil, okPedNum, "", "", "E-MAIL ENVIADO COM SUCESSO PARA FORNECEDOR", "EM", .T.)

				Else
					GrvDd658(okPedFil, okPedNum, "", "", "ERRO AO ENVIAR E-MAIL PARA O FORNECEDOR", "", .T.)

				EndIf

			EndIf 

		Next

		MsgInfo("Fim do envio de e-mails...", "Notificação!!!")

	Else

		MsgAlert("Processo cancelado...", "Notificação!!!")

	EndIf

	RestArea(aArea)

Return

Static Function btnMsgOr(okPedNum)

	sMens := PADR("Saudações," + CRLF + CRLF + "O pedido de compra " + okPedNum + " encontra-se em atraso." + CRLF + "Gentileza justificar o atraso e informar nova data de entrega." + CRLF + CRLF + "Sds, Comprador." + CRLF + CRLF + CRLF + "Favor responder para todos",255)	

Return

Static Function btnAssuOr(okPedNum)

	sAssu := "Follow-up: Pedido de compra " + okPedNum + " em atraso."	

Return

/*---------------------------------------*
| Func.: btnPesq                         |
| Desc.: Função que procura o registro   |
*---------------------------------------*/
Static Function btnPesq()

	Private nPosPesq   := aScan(oGdPed:aHeader,{|x| AllTrim(x[2]) == "PROD_COD"})

	fProcura()

Return

Static Function fProcura()

	//Variáveis da tela
	Private oDlgPesq
	Private oGrpPesq
	Private oGetPesq
	Private cGetPesq := Space(TamSX3('B1_COD')[01])
	Private oBtnExec
	//Tamanho da Janela
	Private nJanLarg := 500
	Private nJanAltu := 135

	Private _oComboBox1
	Private _nComboBox1 := ""	
	Private _ItCombBox  := {"Num.Ped.", "Cód.Fornec.", "Cód.Prod."}

	//Criando a janela
	DEFINE MSDIALOG oDlgPesq TITLE "Pesquisa" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Grupo Fórmula com o Get
	@ 003, 003  GROUP oGrpPesq TO (nJanAltu/2)-3, (nJanLarg/2)-1        PROMPT "" OF oDlgPesq COLOR 0, 16777215 PIXEL

	@ 010, 006 MSCOMBOBOX _oComboBox1 VAR _nComboBox1 ITEMS _ItCombBox SIZE (nJanLarg/2)-29, 013 OF oDlgPesq COLORS 0, 16777215 VALID  (fBIA658A()) PIXEL
	@ 030, 006 MSGET      oGetPesq    VAR cGetPesq                     SIZE (nJanLarg/2)-29, 013 OF oDlgPesq COLORS 0, 16777215 VALID (fConfirma()) PIXEL
	@ 030, (nJanLarg/2)-21 BUTTON oBtnExec PROMPT "OK" SIZE 016, 015 OF oDlgPesq ACTION(fConfirma()) PIXEL

	ACTIVATE MSDIALOG oDlgPesq CENTERED

Return

Static Function fBIA658A()

	If Alltrim(_nComboBox1) == "Num.Ped."
		cGetPesq := Space(TamSX3('C7_NUM')[01])
		nPosPesq   := aScan(oGdPed:aHeader,{|x| AllTrim(x[2]) == "PED_NUM"})

	ElseIf Alltrim(_nComboBox1) == "Cód.Fornec."
		cGetPesq := Space(TamSX3('C7_FORNECE')[01])
		nPosPesq   := aScan(oGdPed:aHeader,{|x| AllTrim(x[2]) == "FORN_COD"})

	ElseIf Alltrim(_nComboBox1) == "Cód.Prod."
		cGetPesq := Space(TamSX3('C7_PRODUTO')[01])
		nPosPesq   := aScan(oGdPed:aHeader,{|x| AllTrim(x[2]) == "PROD_COD"})

	EndIf

Return

Static Function fConfirma()

	Local nLinNov   := 0
	Local cPesquisa := Alltrim(cGetPesq)

	nLinNov := aScan(oGdPed:aCols, {|x| AllTrim(x[nPosPesq]) == cPesquisa})

	If nLinNov == 0
		nLinNov := aScan(oGdPed:aCols, {|x| cPesquisa $ AllTrim(x[nPosPesq])})
	Endif

	If nLinNov == 0

		MsgStop("Trecho '" + cPesquisa + "' não foi encontrado!", "Atenção")

	Else

		oGdPed:aCols[oGdPed:nAt, Len(oGdPed:aHeader) + 1]	:=	.F.
		oGdPed:aCols[nLinNov,    Len(oGdPed:aHeader) + 1]	:=	.T.
		oGdPed:oBrowse:nAt := nLinNov
		oGdPed:oBrowse:Refresh()
		oGdPed:oBrowse:SetFocus()

		oDlgPesq:End()

		fGeraFoll()	
		oGdFoll:Show()
		fPopFoll()

		fGeraHist()	
		oGdHist:Show()
		fPopHist()

	EndIf

Return

User Function xSelUsrCom()

	Local _aArea	:=	GetArea()
	Local _aGrupos	:=	{}
	Local MvPar
	Local MvParDef	:=	""
	Local lRet		:= .F.
	Local _nTamKey	:= 0
	Local _nElemen	:= 0

	DbSelectArea("SY1")
	SY1->(DbSetOrder(1))
	SY1->(DbGoTop())

	MvPar := &(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet := Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

	While SY1->(!EOF())
		If SY1->Y1_MSBLQL <> "1"
			If aScan(_aGrupos,{|x| x == Alltrim(SY1->Y1_USER) + ' - ' + Alltrim(SY1->Y1_COD) + ' - ' + Alltrim(SY1->Y1_NOME)}) == 0
				aAdd(_aGrupos, Alltrim(SY1->Y1_USER) + ' - ' + Alltrim(SY1->Y1_COD) + ' - ' + Alltrim(SY1->Y1_NOME))
				MvParDef += SY1->Y1_USER
				_nElemen++
			EndIf
		EndIf
		SY1->(DbSkip())
	EndDo

	_nTamKey	:=	Len(MvParDef)

	If f_Opcoes(@MvPar, "Seleção de Compradores", _aGrupos, MvParDef, , , .F., 6, _nElemen)
		lRet	:= .T.
		&MvRet := mvpar
	EndIf
	RestArea(_aArea)

Return lRet