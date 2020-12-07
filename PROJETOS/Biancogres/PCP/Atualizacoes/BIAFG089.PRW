#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG089
@author Gabriel Rossi Mafioletti
@since 13/05/2019
@version 1.0
@description Manutenção de Formato x Baia
@type function
/*/

User Function BIAFG089

	Local _cSql

	If !ValidPerg()
		Return
	EndIf

	If !Empty(MV_PAR02)
		DbSelectArea("ZE3")
		ZE3->(DbSetOrder(1))
		If ZE3->(DbSeek(xFilial("ZE3")+MV_PAR01+MV_PAR02+Dtos(MV_PAR03)+Dtos(MV_PAR04)))
			Reclock("ZE3",.F.)
			ZE3->ZE3_FIM := MV_PAR06 -1
			ZE3->(MsUnLock())
		EndIf
	EndIf 
	
	_cSql	:=	" UPDATE " + RetSqlName("ZE3") + " SET D_E_L_E_T_ = '*',R_E_C_D_E_L_ = R_E_C_N_O_ WHERE ZE3_FILIAL = " + ValtoSql(xFilial("ZE3"))
	_cSql	+=	"	AND  ZE3_FORMAT = " + ValtoSql(MV_PAR01) + " AND ZE3_INICIO > " + ValtoSql(MV_PAR03) + " AND D_E_L_E_T_ = ''"
	
	TcSqlExec(_cSql)
	
	Reclock("ZE3",.T.)
	ZE3->ZE3_FILIAL	:=	xFilial("ZE3")
	ZE3->ZE3_FORMAT	:=	MV_PAR01
	ZE3->ZE3_BAIA	:=	MV_PAR05
	ZE3->ZE3_INICIO	:=	MV_PAR06
	ZE3->ZE3_FIM	:=	YearSum(MV_PAR06,50)
	ZE3->(MsUnlock())

Return

Static Function ValidPerg()

	local lRet		:= .F.
	Local _cBaias	:=	fRetCBox("ZE3_BAIA")
	local aBaias 	:= StrToKArr(_cBaias,';')
	Local aPergs	:=	{}

	aSize(aBaias,Len(aBaias)+1)

	aIns(aBaias,1)
	
	aBaias[1]	:=	Space(3)

	MV_PAR01	:=	SPACE(2)
	MV_PAR02	:=	SPACE(3)
	MV_PAR03	:=	Stod("")
	MV_PAR04	:=	Stod("")
	MV_PAR05	:=	SPACE(3)
	MV_PAR06	:=	Stod("")
	MV_PAR07	:=	Stod("")
	

	aAdd( aPergs ,{1,"Formato Atual " 		  	,MV_PAR01 ,"@N!"  ,"Existcpo('ZZ6') .And. U_BFG89VFR()",'ZZ6'  ,'.T.',50,.F.})
	aAdd( aPergs ,{2,"Baia Atual" 	,MV_PAR02 ,aBaias,50,'.F.',.F.,.F.})
	aAdd( aPergs ,{1,"Inicio Atual " 		   		,MV_PAR03 ,""  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"Fim Atual " 		   		,MV_PAR04 ,""  ,"",''  ,'.F.',50,.F.})

	aAdd( aPergs ,{2,"Nova Baia" 	,MV_PAR05 ,aBaias,50,'U_BFG89VBA()',.T.})
	aAdd( aPergs ,{1,"Novo Inicio  " 		   		,MV_PAR06 ,""  ,"U_BFG89VIN()",''  ,'.T.',50,.T.})

	
	If ParamBox(aPergs ,"Cadastro de Formato x Baia",,,,,,,,,.F.,.F.)

		lRet := .T.

	EndIf
Return lRet

Static Function fRetCBox(_cCampo)

	Local _cCBox	:=	""
	Local _aArea	:=	GetArea()
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	
	If SX3->(DbSeek(PADR(_cCampo,10)))
	
		_cCBox	:=	X3Cbox()
	
	EndIf
	RestArea(_aArea)
Return _cCBox

User Function BFG89VFR()

	Local _cAlias	:=	GetNextAlias()
	Local _cDtAtu	:=	Dtos(Date())

	BeginSql Alias _cAlias
	
		SELECT TOP 1 *
		FROM %TABLE:ZE3%
		WHERE ZE3_FILIAL = %XFILIAL:ZE3%
			AND ZE3_FORMAT = %Exp:MV_PAR01%
			AND %Exp:_cDtAtu% BETWEEN ZE3_INICIO
				AND ZE3_FIM
			AND %NotDel%
	
	EndSql

	If (_cAlias)->(!EOF())
		MV_PAR02	:=	(_cAlias)->ZE3_BAIA
		MV_PAR03	:=	Stod((_cAlias)->ZE3_INICIO)
		MV_PAR04	:=	Stod((_cAlias)->ZE3_FIM)
	Else
		MV_PAR02	:=	SPACE(3)
		MV_PAR03	:=	Stod("")
		MV_PAR04	:=	Stod("")
	EndIf

	(_cAlias)->(DbCloseArea())
Return .T.

User Function BFG89VBA()

	Local _lret	:=	.T.

	IF Empty(MV_PAR05)
		MsgAlert("A Nova Baia não poderá ser Vazia")
		_lret	:=	.F.
	ElseIf MV_PAR02 == MV_PAR05
		MsgAlert("A Nova Baia não poderá ser Igual à Atual")
		_lret	:=	.F.
	EndIf
Return _lRet

User Function BFG89VIN()

	Local _lRet	:=	.T.

	If MV_PAR06 <= MV_PAR03 
		MsgAlert("A nova data de início não poderá ser menor ou igual à data de início atual!")
		_lRet	:=	.F.
	EndIf
	
Return _lRet