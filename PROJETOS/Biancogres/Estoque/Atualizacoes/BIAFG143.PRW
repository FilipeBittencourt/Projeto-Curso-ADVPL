#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG143
@author Gabriel Rossi Mafioletti
@since 15/04/2020
@version 1.0
@description Invent�rio de Sa�da MD por Solicitante	
@type function
/*/

User Function BFG143T()

	RpcSetEnv('01','01')
	U_BIAFG143()
	RpcClearEnv()

Return

User Function BIAFG143()

	Local _nSaldoMov	:=	0
	Local _cDocSeq		:=	""
	Local _nQuant		:=	0
	Local _cSolic		:=	""
	Local _dDtPrf		:=	Stod("")
	Local _dDtCheg		:=	Stod("")
	
	Private _oMd	:=	TBiaControleMD():New()	
	
	If !Validperg()
		Return
	EndIf

	Begin Transaction

		_nSaldoMov	:=	MV_PAR05

		While _nSaldoMov > 0 .And. _oMd:Saldo(MV_PAR02,MV_PAR03,MV_PAR01,.F.) >= 0
			_cDocSeq	:=	""
			_nQuant	:=	0
			_cSolic	:=	""
			_dDtPrf	:=	Stod("")
			_dDtCheg	:=	Stod("")

			_oMd:GetMovimentoEntrada(MV_PAR02,MV_PAR03,MV_PAR01,@_cDocSeq,@_nQuant,@_cSolic,.F.,@_dDtPrf,@_dDtCheg)

			If _nQuant > 0

				_nQuant	:= Min(_nSaldoMov,_nQuant)
				RecLock("ZCZ",.T.)
				ZCZ->ZCZ_FILIAL		:=	xFilial("ZCZ")
				ZCZ->ZCZ_DOC        :=	""
				ZCZ->ZCZ_SERIE      :=	""
				ZCZ->ZCZ_FORNEC     :=	""
				ZCZ->ZCZ_LOJA       :=	""
				ZCZ->ZCZ_ITEM       :=	""
				ZCZ->ZCZ_COD        :=	MV_PAR02
				ZCZ->ZCZ_QUANT      :=	_nQuant
				ZCZ->ZCZ_LOCAL      :=	MV_PAR03
				ZCZ->ZCZ_TM         :=	'504'
				ZCZ->ZCZ_SOLICI     :=	_cSolic
				ZCZ->ZCZ_MATORI     :=	MV_PAR01
				ZCZ->ZCZ_USER       :=	cUserName
				ZCZ->ZCZ_ROTINA     :=	"BIAFG143"
				ZCZ->ZCZ_DTDIGI     :=	dDataBase
				ZCZ->ZCZ_DHMOV      :=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"
				ZCZ->ZCZ_DOCSEQ     :=	_cDocSeq
				ZCZ->ZCZ_TBORIG     :=	"ZCZ"
				ZCZ->ZCZ_OBS		:=	MV_PAR06
				ZCZ->ZCZ_RECID      :=	0
				ZCZ->ZCZ_DATPRF		:=	_dDtPrf
				ZCZ->ZCZ_DTCHEG		:=	_dDtCheg
				ZCZ->(MsUnlock())
			Else
				Exit
			EndIf
			_nSaldoMov := _nSaldoMov - _nQuant
		EndDo

		MsgInfo("Registro gerado com sucesso","BIAFG143")
	
	End Transaction

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG142" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	local aPergs	:=	{}

	MV_PAR01 := Space(TamSX3("ZZY_MATRIC")[1])
	MV_PAR02 :=	Space(TamSX3("B1_COD")[1])
	MV_PAR03 := Space(TamSX3("ZCN_LOCAL")[1])
	MV_PAR04 :=	0
	MV_PAR05 :=	0		
	MV_PAR06 := SPACE(300)

	aAdd( aPergs ,{1,"Solicit." 	   			,MV_PAR01 ,""  ,"(MV_PAR01 == 'ZZZZZZZZ' .OR. U_BFG143ZY(MV_PAR01) ) .And. U_BFG143SL()",'ZZY'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Produto" 	   			,MV_PAR02 ,""  ,"ExistCpo('SB1').And. U_BFG143SL()",'SB1'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Almoxarif." 	   			,MV_PAR03 ,""  ,"U_BFG143SL()",''  ,'.T.',20,.F.})
	aAdd( aPergs ,{1,"Saldo" 	   		,MV_PAR04 ,"@E 9,999,999.99999999"  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"Quantidade" 	   		,MV_PAR05 ,"@E 9,999,999.99999999"  ,"U_BFG143QT()",''  ,'.T.',50,.T.})
	aAdd( aPergs ,{11,'Motivo'				,MV_PAR06,"",".T.",.T.})

	If ParamBox(aPergs ,"Sa�da de MD",,,,,,,,,.F.,.F.)

		lRet := .T.

	EndIf

Return lRet

User Function BFG143SL()

	Local _nSaldo	:=	0
	Local _lRet	:=	.T.
	If !Empty(MV_PAR01) .And. !Empty(MV_PAR02) .And. !Empty(MV_PAR03)

		If _oMd:CheckMD(MV_PAR02,MV_PAR03)
			MV_PAR04	:=	_oMd:Saldo(MV_PAR02,MV_PAR03,MV_PAR01,.F.)
			MV_PAR05	:=	0
		Else
			MsgInfo("O Produto n�o � MD para o Almoxarifado selecionado!")
			_lRet	:=	.F.
		EndIf

	EndIf 

Return .T.

User Function BFG143QT()

	Local _lRet	:=	.T.

	If MV_PAR05 > MV_PAR04
		MsgInfo("A Quantidade n�o poder� ser superior ao Saldo do Produto!")
		_lRet	:=	.F.
	EndIf
Return _lRet


User Function BFG143ZY(_cMat)

	Local _lRet	:=	.T.
	Local _aArea	:=	GetArea()

	ZZY->(dbSetOrder(3))
	If !ZZY->(Dbseek(xFilial("ZZY")+_cMat))
		MsgInfo("Funcion�rio Inexistente!")
		_lRet	:=	.F.
	EndIf
	RestArea(_aArea)
Return _lRet