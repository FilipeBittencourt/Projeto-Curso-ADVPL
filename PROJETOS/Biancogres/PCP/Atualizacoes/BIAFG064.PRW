#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG064
@author Gabriel Rossi Mafioletti
@since 17/09/2018
@version 1.0
@description Tela de Cadastro de Cálibres
@type function
/*/

User Function BIAFG064()

	Private oDlgCLB		:=	Nil		//Dialog
	Private oGpCLB1		:=	Nil		//Grupo
	Private oGpCLB1GR	:=	Nil		//Grupo Grafico
	Private oPnNotas	:=	Nil		//Painel Onde Ficarão as Notas da Revisão
	Private oSyDsRev	:=	Nil
	Private cSyDsRev	:=	SPACE(250)
	Private	oFntCLB		:=	TFont():New("Arial",,022,,.T.,,,,,.F.,.F.)

	Private oGdRevisao	:=	Nil		//GetDados de Revisões
	Private oGdFormato	:=	Nil		//GetDados de Formatos
	Private oGdCalibre	:=	Nil		//Getdados de Calibres
	Private	oGdNotas	:=	Nil		//Getdados de Notas

	Private aSize := MsAdvSize(.F.) //Sem Enchoice

	Private _cRevAtu	:=	fGetRev()

	aObjects := {}

	AAdd( aObjects, { 100, 025, .T., .F. } )
	AAdd( aObjects, { 100, 185, .T., .T. } )
	AAdd( aObjects, { 100, 215, .T., .T. } )

	aInfo1   := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }

	aPosObj1 := MsObjSize( aInfo1, aObjects, .T. )

	//Subdivide o Segundo Objeto em 2
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )

	aSize2 := aClone( aPosObj1[2] )
	aInfo2   := { aSize2[2], aSize2[1], aSize2[4], aSize2[3], 3, 3 }
	aPosObj2 := MsObjSize( aInfo2, aObjects, ,.T. )

	//Subdivide o Terceiro Objeto em 2
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )

	aSize3 := aClone( aPosObj1[3] )
	aInfo3   := { aSize3[2], aSize3[1], aSize3[4], aSize3[3], 3, 3 }
	aPosObj3 := MsObjSize( aInfo3, aObjects, ,.T. )


	//Montagem da Tela

	DEFINE MSDIALOG oDlgCLB TITLE "Controle de Cálibres" FROM aSize[7], aSize[7] TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL


	// Painel de Botões(Cabeçalho)
	@ aPosObj1[1][1], aPosObj1[1][2] GROUP oGpCLB1 TO aPosObj1[1][3], aPosObj1[1][4] PROMPT "Ações..." OF oDlgCLB COLOR 0, 16777215 PIXEL
	@ aPosObj1[1][1]+10, aPosObj1[1][2]+05 SAY oSyDsRev PROMPT cSyDsRev SIZE 446, 011 OF oDlgCLB FONT oFntCLB COLORS 0, 16777215 PIXEL

	// Painel de Revisão
	@ aPosObj2[1][1], aPosObj2[1][2] GROUP oGpCLB1GR TO aPosObj2[1][3], aPosObj2[1][4] PROMPT "Revisões..." OF oDlgCLB COLOR 0, 16777215 PIXEL
	U_BIAMsgRun("Aguarde... Carregando dados (Quadro Revisões)",,{|| fGeraRev() })

	// Painel de Formatos
	@ aPosObj2[2][1], aPosObj2[2][2] GROUP oGpCLB1GR TO aPosObj2[2][3], aPosObj2[2][4] PROMPT "Formatos..." OF oDlgCLB COLOR 0, 16777215 PIXEL
	U_BIAMsgRun("Aguarde... Carregando dados (Quadro Formatos)",,{|| fGeraForm() })


	// Painel de Notas
	@ aPosObj3[2][1], aPosObj3[2][2] GROUP oGpCLB1GR TO aPosObj3[2][3], aPosObj3[2][4] PROMPT "Notas..." OF oDlgCLB COLOR 0, 16777215 PIXEL	
	U_BIAMsgRun("Aguarde... Carregando dados (Quadro Notas)",,{|| fGeraNot() })


	// Painel de Cálibres
	@ aPosObj3[1][1], aPosObj3[1][2] GROUP oGpCLB1GR TO aPosObj3[1][3], aPosObj3[1][4] PROMPT "Cálibres..." OF oDlgCLB COLOR 0, 16777215 PIXEL
	U_BIAMsgRun("Aguarde... Carregando dados (Quadro Cálibres)",,{|| fGeraCalib() })

	@ aPosObj1[1][1] + 08, aPosObj1[1][1] + 008 BUTTON oBtRev PROMPT "Criar Revisão" SIZE 060, 012 OF oDlgCLB ACTION fCriaRev() PIXEL
	@ aPosObj1[1][1] + 08, aPosObj1[1][1] + 080 BUTTON oBtRev PROMPT "Integrar MES"  SIZE 060, 012 OF oDlgCLB ACTION fIntgMES() PIXEL
	@ aPosObj1[1][1] + 08, aPosObj1[1][1] + 152 BUTTON oBtRev PROMPT "Sair"          SIZE 060, 012 OF oDlgCLB ACTION oDlgCLB:End() PIXEL

	ACTIVATE MSDIALOG oDlgCLB CENTERED

Return

Static Function fGeraRev()

	Local _aHeader	:=	{}
	Local _aCols	:=	{}

	Local _cAlias	:=	GetNextAlias()

	BEGINSQL ALIAS _cAlias

	SELECT DISTINCT ZCJ_REVISA, ZCJ_DATREV
	FROM %TABLE:ZCJ% ZCJ
	WHERE ZCJ_FILIAL = %xFILIAL:ZCJ%
	AND %NotDel%
	ORDER BY ZCJ_REVISA

	EndSql

	Aadd(_aHeader,{" "		         	 ,"CSTATUS" ,"@BMP"             , 2, 0, ".F." ,""    , "C", "", "V" ,"" , "","","V"})
	aAdd(_aHeader,{"Revisão"             ,"REVISAO" ,"@!"               , 3, 0     ,      ,    , "C",, })      	// 1
	aAdd(_aHeader,{"Dt. Revisão"         ,"DTREV"   ,"@!"               , 8, 0,    ,      , "D",    , })      	// 2

	If (_cAlias)->(!EOF())
		While (_cAlias)->(!EOF())
			aAdd(_aCols,{Iif((_cAlias)->ZCJ_REVISA == _cRevAtu,"BR_VERDE","BR_VERMELHO"),(_cAlias)->ZCJ_REVISA,StoD((_cAlias)->ZCJ_DATREV),.F.})
			(_cAlias)->(DbSkip())
		EndDo
	Else
		aAdd(_aCols,{"BR_VERDE",'003',Stod("20180629"),.F.})
	EndIf

	oGdRevisao	:=	MsNewGetDados():New( aPosObj2[1][1] + 10, aPosObj2[1][2] + 5, aPosObj2[1][3] - 5, aPosObj2[1][4] - 5, 0, "AllwaysTrue", "AllwaysTrue", "", {},, 999, '', "", "AllwaysTrue", oDlgCLB, _aHeader, _aCols, { || fAltRev() } )

	(_cAlias)->(DbCloseArea())

Return

Static Function fGeraForm()

	Local _aHeader	:=	{}
	Local _aCols	:=	{}

	aAdd(_aHeader,{"Formato"         ,"FORMATO" ,"@!"               , 2   , 0,"ExistCpo('ZZ6')",, "C","ZZ6", })      	// 1
	aAdd(_aHeader,{"Descrição"         ,"DESCRI" ,"@!"               , TAMSX3("ZZ6_DESC")[1]   , 0,"",, "C","", })      	// 1


	oGdFormato	:=	MsNewGetDados():New( aPosObj2[2][1] + 10, aPosObj2[2][2] + 5, aPosObj2[2][3] - 5, aPosObj2[2][4] - 5, GD_INSERT+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", {"FORMATO"},, 999, 'U_BG64FFOK()', "", "AllwaysTrue", oDlgCLB, _aHeader, _aCols, { || fAltForm() } )

Return


Static Function fAltForm()


	Local _aCols	:=	{}

	Local _cAlias	:=	GetNextAlias()

	Local _cRevisa	:=	GdFieldGet("REVISAO",oGdRevisao:nAt,,oGdRevisao:aHeader,oGdRevisao:aCols)

	Local _cFormat	:=	GdFieldGet("FORMATO",oGdFormato:nAt,,oGdFormato:aHeader,oGdFormato:aCols)

	Local _dDtRev	:=	GdFieldGet("DTREV",oGdRevisao:nAt,,oGdRevisao:aHeader,oGdRevisao:aCols)

	Local _nI

	Local _nPosdel	:=	Len(oGdFormato:aHeader) + 1

	BeginSql Alias _cAlias

	SELECT *
	FROM %TABLE:ZCJ% ZCJ
	WHERE ZCJ_FILIAL = %XFILIAL:ZCJ%
	AND ZCJ_REVISA = %Exp:_cRevisa%
	AND ZCJ_FORMAT = %Exp:_cFormat%
	AND %NotDel%
	ORDER BY ZCJ_IDCALI

	EndSql

	If (_cAlias)->(!EOF())
		While (_cAlias)->(!EOF())
			aAdd(_aCols,{(_cAlias)->ZCJ_IDCALI,(_cAlias)->ZCJ_CALIBR,(_cAlias)->ZCJ_FAIXA,(_cAlias)->ZCJ_COMPRI,(_cAlias)->ZCJ_LARGUR,(_cAlias)->ZCJ_VARIAC,.F.})
			(_cAlias)->(DbSkip())
		EndDo
	ElseIf !Empty(_cFormat) 
		_aCols	:= fNewCalib(_cRevisa,_cFormat,_dDtRev)
	EndIf

	For _nI	:= 1 to Len(oGdFormato:aCols)

		If _nI == oGdFormato:nAt
			oGdFormato:aCols[_nI,_nPosDel]	:=	.T.
		Else
			oGdFormato:aCols[_nI,_nPosDel]	:=	.F.
		EndIf

	Next

	oGdCalibre:aCols	:=	_aCols

	oGdCalibre:Refresh()
	oGdFormato:Refresh()
	oGdRevisao:Refresh()

Return


Static Function fAltRev()

	Local _aCols	:=	{}

	Local _cAlias	:=	GetNextAlias()

	Local _cRevisa	:=	GdFieldGet("REVISAO",oGdRevisao:nAt,,oGdRevisao:aHeader,oGdRevisao:aCols)

	Local _nI
	Local _nPosDel	:=	Len(oGdRevisao:aHeader) + 1

	BeginSql Alias _cAlias

	SELECT DISTINCT ZCJ_FORMAT
	FROM %TABLE:ZCJ% ZCJ
	WHERE ZCJ_FILIAL = %XFILIAL:ZCJ%
	AND ZCJ_REVISA = %Exp:_cRevisa%
	AND %NotDel%

	EndSql

	If (_cAlias)->(!EOF())
		While (_cAlias)->(!EOF())
			aAdd(_aCols,{(_cAlias)->ZCJ_FORMAT,Posicione("ZZ6",1,xFilial("ZZ6")+(_cAlias)->ZCJ_FORMAT,"ZZ6_DESC"),.F.})
			(_cAlias)->(DbSkip())
		EndDo
	Else
		aAdd(_aCols,{SPACE(2),SPACE(TamSx3("ZZ6_DESC")[1]),.F.})
	EndIf

	oGdFormato:aCols	:=	_aCols

	For _nI	:= 1 to Len(oGdRevisao:aCols)

		If _nI == oGdRevisao:nAt
			oGdRevisao:aCols[_nI,_nPosDel]	:=	.T.
		Else
			oGdRevisao:aCols[_nI,_nPosDel]	:=	.F.
		EndIf

	Next
	oGdFormato:Goto(1)
	oGdFormato:Refresh()

	fAltForm()

	fAltNot(_cRevisa)

	(_cAlias)->(DbCloseArea())

Return

Static Function fGeraNot()

	Local _aHeader	:=	{}
	Local _aCols	:=	{}

	aAdd(_aHeader,{"ID"         ,"ID" ,"@!"               , 2   , 0,"",, "C","", })      	// 1
	aAdd(_aHeader,{"Nota"         ,"NOTA" ,"@!"               , TAMSX3("ZCK_NOTA")[1]   , 0,"",, "C","", })      	// 1

	oGdNotas	:=	MsNewGetDados():New( aPosObj3[2][1] + 10, aPosObj3[2][2] + 5, aPosObj3[2][3] - 5, aPosObj3[2][4] - 5, GD_INSERT+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+ID", {"NOTA"},, 999, 'U_BG64NFOK', "", "AllwaysTrue", oDlgCLB, _aHeader, _aCols, )


Return

Static Function fAltNot(_cRevisa)

	Local _cAlias	:=	GetNextAlias()
	Local _aCols	:=	{}

	BeginSql Alias _cAlias

	SELECT *
	FROM %TABLE:ZCK% ZCK
	WHERE ZCK_FILIAL = %XFILIAL:ZCK%
	AND ZCK_REVISA = %Exp:_cRevisa%
	AND %NotDel%

	EndSql

	If (_cAlias)->(!EOF())
		While (_cAlias)->(!EOF())
			aAdd(_aCols,{(_cAlias)->ZCK_IDNOTA, (_cAlias)->ZCK_NOTA, .F.})
			(_cAlias)->(DbSkip())
		EndDo
	Else
		aAdd(_aCols,{"01",SPACE(TAMSX3("ZCK_NOTA")[1]),.F.})
	EndIf

	oGdNotas:aCols	:=	_aCols
	oGdNotas:Refresh()

Return

Static Function fGeraCalib()

	Local _aHeader	:=	{}
	Local _aCols	:=	{}

	aAdd(_aHeader,{"ID"         ,"ZCJ_IDCALI" ,"@!"               , 2   , 0,"",, "C","", })      	// 1
	aAdd(_aHeader,{"Cálibre"         ,"ZCJ_CALIBR" ,"@!"               , 1   , 0,"",, "C","", })      	// 1
	aAdd(_aHeader,{"Faixa"         ,"ZCJ_FAIXA" ,"@!"               , 1   , 0,"",, "C",,, "1=Ideal;2=Aceitável;3=Fora" })      	// 1	
	aAdd(_aHeader,{"Compr."         ,"ZCJ_COMPRI" ,PesqPict("ZCJ","ZCJ_COMPRI")               , TAMSX3("ZCJ_COMPRI")[1]   , TAMSX3("ZCJ_COMPRI")[2],"",, "N","", })      	// 1
	aAdd(_aHeader,{"Larg."         ,"ZCJ_LARGUR" ,PesqPict("ZCJ","ZCJ_LARGUR")               , TAMSX3("ZCJ_LARGUR")[1]   , TAMSX3("ZCJ_LARGUR")[2],"",, "N","", })      	// 1
	aAdd(_aHeader,{"Variac."         ,"ZCJ_VARIAC" ,PesqPict("ZCJ","ZCJ_VARIAC")               , TAMSX3("ZCJ_VARIAC")[1]   , TAMSX3("ZCJ_VARIAC")[2],"",, "N","", })      	// 1

	oGdCalibre	:=	MsNewGetDados():New( aPosObj3[1][1] + 10, aPosObj3[1][2] + 5, aPosObj3[1][3] - 5, aPosObj3[1][4] - 5, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", {"ZCJ_FAIXA","ZCJ_COMPRI","ZCJ_LARGUR","ZCJ_VARIAC"},, 999, 'U_BG64CFOK()', "", "AllwaysTrue", oDlgCLB, _aHeader, _aCols, )
	oGdCalibre:oBrowse:lUseDefaultColors := .F.
	oGdCalibre:oBrowse:SetBlkBackColor({|| fCorCalib(oGdCalibre:aCols,oGdCalibre:nAt,oGdCalibre:aHeader)})
Return



Static Function fGetRev()

	Local _cAlias	:=	GetNextAlias()
	Local _cRev	:= ""

	BeginSql Alias _cAlias

	SELECT ISNULL(MAX(ZCJ_REVISA),'001') REV
	FROM %TABLE:ZCJ% ZCJ
	WHERE ZCJ_FILIAL = %XFILIAL:ZCJ%
	AND %NotDel%

	EndSql

	_cRev	:=	(_cAlias)->REV

	(_cAlias)->(DbCloseArea())

Return _cRev


Static Function fNewCalib(_cRevisa,_cFormat,_dDtRev)

	Local _aCols	:=	{}
	Local _nIdCalib	:=	1
	Local _nCalib	:=	0

	For _nIdCalib := 1 to 16

		aAdd(_aCols,{PADL(Alltrim(Str(_nIdCalib)),2,'0'),PADL(Alltrim(Str(_nCalib)),1,'0'),' ',0,0,0,.F.})

		RecLock("ZCJ",.T.)
		ZCJ->ZCJ_FILIAL :=	xFilial("ZCJ")
		ZCJ->ZCJ_REVISA	:=	_cRevisa
		ZCJ->ZCJ_DATREV	:=	_dDtRev
		ZCJ->ZCJ_FORMAT	:=	_cFormat
		ZCJ->ZCJ_IDCALI	:=	PADL(Alltrim(Str(_nIdCalib)),2,'0')
		ZCJ->ZCJ_CALIBR	:=	PADL(Alltrim(Str(_nCalib)),1,'0')
		ZCJ->(MsUnlock())

		_nCalib	:=	Iif(_nCalib == 9,0,_nCalib+1)

	Next

Return _aCols

User Function BG64FFOK()

	Local _cCampo	:=	ReadVar()
	Local _aCols	:=	{}
	Local _nI

	Local _cRevisa	:=	GdFieldGet("REVISAO",oGdRevisao:nAt,,oGdRevisao:aHeader,oGdRevisao:aCols)

	Local _dDtRev	:=	GdFieldGet("DTREV",oGdRevisao:nAt,,oGdRevisao:aHeader,oGdRevisao:aCols)

	If oGdRevisao:aCols[oGdRevisao:nAt,1] == "BR_VERMELHO"
		MsgInfo("Não será possível editar revisões anteriores!")
		Return .F.
	EndIf

	If !Empty(&_cCampo) 
		If Empty(GdFieldGet("FORMATO",oGdFormato:nAt,,oGdFormato:aHeader,oGdFormato:aCols))
			_aCols	:=	fNewCalib(_cRevisa,M->FORMATO,_dDtRev)
			oGdCalibre:aCols	:=	_aCols			
		Else
			TcSqlExec("UPDATE " + RetSqlName("ZCJ") + " SET ZCJ_FORMAT = " + ValtoSql(M->FORMATO) + " WHERE ZCJ_FILIAL = " + ValtoSql(xFilial("ZCJ"))+ ;
			" AND ZCJ_REVISA = " + ValtoSql(_cRevisa) + " AND ZCJ_FORMAT = " + ValtoSql(GdFieldGet("FORMATO",oGdFormato:nAt,,oGdFormato:aHeader,oGdFormato:aCols)) )


		EndIf
	EndIf

	GdFieldPut("DESCRI",Posicione("ZZ6",1,xFilial("ZZ6")+M->FORMATO,"ZZ6_DESC"),oGdFormato:nAt,oGdFormato:aHeader,oGdFormato:aCols)

	oGdCalibre:Refresh()

Return .T.


User Function BG64CFOK()

	Local _cCampo	:=	ReadVar()

	Local _cRevisa	:=	GdFieldGet("REVISAO",oGdRevisao:nAt,,oGdRevisao:aHeader,oGdRevisao:aCols)
	Local _dDtRev	:=	GdFieldGet("DTREV",oGdRevisao:nAt,,oGdRevisao:aHeader,oGdRevisao:aCols)
	Local _cFormat	:=	GdFieldGet("FORMATO",oGdFormato:nAt,,oGdFormato:aHeader,oGdFormato:aCols)

	If oGdRevisao:aCols[oGdRevisao:nAt,1] == "BR_VERMELHO"
		MsgInfo("Não será possível editar revisões anteriores!")
		Return .F.
	EndIf

	TcSqlExec("UPDATE " + RetSqlName("ZCJ") + " SET " + Replace(_cCampo,"M->","") + " = " + ValtoSql(&_cCampo) + " WHERE ZCJ_FILIAL = " + ValtoSql(xFilial("ZCJ")) + ;
	" AND ZCJ_REVISA = " + ValtoSql(_cRevisa) + " AND ZCJ_FORMAT = " + ValtoSql(_cFormat) + ;
	" AND ZCJ_IDCALI = " + ValtoSql(GdFieldGet("ZCJ_IDCALI",oGdCalibre:nAt,,oGdCalibre:aHeader,oGdCalibre:aCols)) +  ;
	" AND ZCJ_CALIBR = " + ValtoSql(GdFieldGet("ZCJ_CALIBR",oGdCalibre:nAt,,oGdCalibre:aHeader,oGdCalibre:aCols)) )
Return .T.

Static Function fCorCalib(aLinha,nLinha,aHeader)
	Local _nPosDel	:=	Len(aHeader) + 1

	If oGdCalibre:aCols[nLinha,_nPosDel]
		nRet	:=	12632256
	Else
		Do Case
			Case aLinha[nLinha,3] == "1"
			nRet	:= 16777113
			Case aLinha[nLinha,3] == "2"
			nRet	:= 9621584
			Case aLinha[nLinha,3] == "3"
			nRet	:= 45296
			OtherWise 
			nRet	:=	16777215
		EndCase
	EndIf
Return nRet

Static Function fCriaRev()

	Local _cAlias

	If !ValidPerg()
		Return
	EndIf

	aEval(oGdRevisao:aCols,{|x| x[1] := "BR_VERMELHO"})

	aAdd(oGdRevisao:aCols,{"BR_VERDE",MV_PAR01,MV_PAR02,.F.})

	fCopyRev(MV_PAR01)

	oGdRevisao:Goto(Len(oGdRevisao:aCols))

	fAltRev()

	fAltForm()

	oGdRevisao:Refresh()

Return


Static Function ValidPerg()

	local cLoad	    := "BIAFG064" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(3)
	MV_PAR02 := STOD('')


	aAdd( aPergs ,{1,"Nova Revisão" 		  	,MV_PAR01 ,""  ,"NAOVAZIO() .And. EXISTCHAV('ZCJ')",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Nova Data " 		  		,MV_PAR02 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})	

	If ParamBox(aPergs ,"Cadastro de Cálibres",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)

	EndIf
Return lRet

Static Function fCopyRev(_cPara)

	Local _cAlias	:=	GetNextAlias()
	Local _nI


	BeginSql Alias _cAlias

	SELECT *
	FROM %TABLE:ZCJ% ZCJ
	WHERE ZCJ_FILIAL = %XFILIAL:ZCJ%
	AND ZCJ_REVISA = (SELECT MAX(ZCJREV.ZCJ_REVISA)
	FROM %TABLE:ZCJ% ZCJREV
	WHERE ZCJREV.ZCJ_FILIAL = %XFILIAL:ZCJ%
	AND ZCJREV.%NotDel%
	)
	AND ZCJ.%NotDel%
	ORDER BY ZCJ_IDCALI		

	EndSql

	While (_cAlias)->(!EOF())

		RecLock("ZCJ",.T.)
		ZCJ->ZCJ_FILIAL :=	xFilial("ZCJ")
		ZCJ->ZCJ_REVISA	:=	MV_PAR01
		ZCJ->ZCJ_DATREV	:=	MV_PAR02
		ZCJ->ZCJ_FORMAT	:=	(_cAlias)->ZCJ_FORMAT
		ZCJ->ZCJ_IDCALI	:=	(_cAlias)->ZCJ_IDCALI
		ZCJ->ZCJ_CALIBR	:=	(_cAlias)->ZCJ_CALIBR
		ZCJ->ZCJ_FAIXA	:=	(_cAlias)->ZCJ_FAIXA
		ZCJ->ZCJ_COMPRI	:=	(_cAlias)->ZCJ_COMPRI
		ZCJ->ZCJ_LARGUR	:=	(_cAlias)->ZCJ_LARGUR
		ZCJ->ZCJ_VARIAC	:=	(_cAlias)->ZCJ_VARIAC
		ZCJ->(MsUnlock())

		(_cAlias)->(DbSkip())
	EndDO

	(_cAlias)->(DbCloseArea())

Return

User Function BG64NFOK()

	If oGdRevisao:aCols[oGdRevisao:nAt,1] == "BR_VERMELHO"
		MsgInfo("Não será possível editar revisões anteriores!")
		Return .F.
	EndIf

	If ZCK->(DbSeek(xFilial("ZCK")+ GdFieldGet("REVISAO",oGdRevisao:nAt,,oGdRevisao:aHeader,oGdRevisao:aCols) + GdFieldGet("ID",oGdNotas:nAt,,oGdNotas:aHeader,oGdNotas:aCols) ))
		Reclock("ZCK",.F.)
	Else
		Reclock("ZCK",.T.)
	EndIF
	ZCK->ZCK_FILIAL :=	xFilial("ZCK")
	ZCK->ZCK_REVISA :=	GdFieldGet("REVISAO",oGdRevisao:nAt,,oGdRevisao:aHeader,oGdRevisao:aCols)
	ZCK->ZCK_IDNOTA	:=	GdFieldGet("ID",oGdNotas:nAt,,oGdNotas:aHeader,oGdNotas:aCols)
	ZCK->ZCK_NOTA	:=	M->NOTA

	ZCK->(MsUnlock())

Return .T.

Static Function fIntgMES()

	quAreaAtu := GetArea()
	If !MsgNOYES("Ao confimar você estará aceitando que a integração da versão ainda não integrada com a tabela cTblTamanho seja integrada. Deseja prosseguir?")
		Return
	EndIf

	QU007 := " INSERT INTO PCF4.[dbo].ctblTamanho "
	QU007 += " ( "
	QU007 += "  [Familia], "
	QU007 += "  [Sequencia], "
	QU007 += "  [Calibre], "
	QU007 += "  [Comprimento], "
	QU007 += "  [Largura], "
	QU007 += "  [Integrated], "
	QU007 += "  [DtIntegrated], "
	QU007 += "  [DtLastUpdate], "
	QU007 += "  [User], "
	QU007 += "  [ID] "
	QU007 += " ) "
	QU007 += " SELECT B.IDProductFamily Familia, "
	QU007 += "        ZCJ_IDCALI Sequencia, "
	QU007 += "        ZCJ_CALIBR Calibre, "
	QU007 += "        ZCJ_COMPRI Comprimento, "
	QU007 += "        ZCJ_LARGUR Largura, "
	QU007 += "        ' ' 'Integrated', "
	QU007 += "        convert(smalldatetime, ZCJ_DATREV) DtIntegrated, "
	QU007 += "        convert(smalldatetime, GETDATE()) DtLastUpdate, "
	QU007 += "        '" + cUserName + "' 'User', "
	QU007 += "        (SELECT ISNULL(MAX(ID),0) FROM PCF4.[dbo].ctblTamanho) + ROW_NUMBER() OVER(ORDER BY A.R_E_C_N_O_) AS ID "
	QU007 += "   FROM " + RetSqlName("ZCJ") + " A "
	QU007 += "  INNER JOIN PCF4.[dbo].TBLProductFamily B ON B.Code = ZCJ_FORMAT collate Latin1_General_BIN "
	QU007 += "  WHERE ZCJ_ITGMES <> '1' "
	QU007 += "    AND D_E_L_E_T_ = ' ' "
	TCSQLExec(QU007)

	quIntgMES := 0 
	QU002 := " SELECT COUNT(*) CONTAD "
	QU002 += "    FROM " + RetSqlName("ZCJ") + " A "
	QU002 += "   INNER JOIN PCF4.[dbo].TBLProductFamily B ON B.Code = ZCJ_FORMAT collate Latin1_General_BIN "
	QU002 += "   WHERE ZCJ_ITGMES <> '1' "
	QU002 += "     AND D_E_L_E_T_ = ' ' "
	QUSIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QU002),'QU02',.T.,.T.)
	dbSelectArea("QU02")
	QU02->(dbGoTop())
	If QU02->(!Eof())	
		quIntgMES := QU02->CONTAD
	EndIf
	QU02->(dbCloseArea())
	Ferase(QUSIndex+GetDBExtension())
	Ferase(QUSIndex+OrdBagExt())	

	QU008 := " UPDATE " + RetSqlName("ZCJ") + " SET ZCJ_ITGMES = '1' "
	QU008 += "   FROM " + RetSqlName("ZCJ") + " A "
	QU008 += "  INNER JOIN PCF4.[dbo].TBLProductFamily B ON B.Code = ZCJ_FORMAT collate Latin1_General_BIN "
	QU008 += "  WHERE ZCJ_ITGMES <> '1' "
	QU008 += "    AND D_E_L_E_T_ = ' ' "
	TCSQLExec(QU008)

	MsgINFO("Fim do Processamento: " + Alltrim(Str(quIntgMES)) + " registros foram afetados neste processamento!!! Caso alguma Família/Formato não exista no Totvs MES, este processamento poderá ser repedido assim que sejam cadastradas(os)...")

	RestArea(quAreaAtu)
	oGdRevisao:Refresh()

Return
