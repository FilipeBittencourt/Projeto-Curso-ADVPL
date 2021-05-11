#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG141
@author Gabriel Rossi Mafioletti
@since 15/04/2020
@version 1.0
@description Troca de Solicitante para ZZZZZZ	
@type function
/*/

User Function BIAFG141()

	Local _nSaldoMov	:=	0
	Local _cDocSeq		:=	""
	Local _nQuant		:=	0
	Local _cSolic		:=	""

	
	Private _oMd	:=	TBiaControleMD():New()	

	If !Validperg()
		Return
	EndIf

	Begin Transaction

		RecLock("ZCZ",.T.)
		ZCZ->ZCZ_FILIAL		:=	xFilial("ZCZ")
		ZCZ->ZCZ_DOC        :=	""
		ZCZ->ZCZ_SERIE      :=	""
		ZCZ->ZCZ_FORNEC     :=	""
		ZCZ->ZCZ_LOJA       :=	""
		ZCZ->ZCZ_ITEM       :=	""
		ZCZ->ZCZ_COD        :=	MV_PAR02
		ZCZ->ZCZ_QUANT      :=	MV_PAR05
		ZCZ->ZCZ_LOCAL      :=	MV_PAR03
		ZCZ->ZCZ_TM         :=	'006'
		ZCZ->ZCZ_SOLICI     :=	'ZZZZZZZZ'
		ZCZ->ZCZ_MATORI     :=	MV_PAR01
		ZCZ->ZCZ_USER       :=	cUserName
		ZCZ->ZCZ_ROTINA     :=	"BIAFG141"
		ZCZ->ZCZ_DTDIGI     :=	dDataBase
		ZCZ->ZCZ_DHMOV      :=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"
		ZCZ->ZCZ_DOCSEQ     :=	_oMd:NextNum()
		ZCZ->ZCZ_TBORIG     :=	"ZCZ"
		ZCZ->ZCZ_OBS		:=	MV_PAR06
		ZCZ->ZCZ_RECID      :=	0
		ZCZ->(MsUnlock())

		_nSaldoMov	:=	MV_PAR05

		While _nSaldoMov > 0 .And. _oMd:Saldo(MV_PAR02,MV_PAR03,MV_PAR01,.F.) >= 0
			_cDocSeq	:=	""
			_nQuant	:=	0
			_cSolic	:=	""

			_oMd:GetMovimentoEntrada(MV_PAR02,MV_PAR03,MV_PAR01,@_cDocSeq,@_nQuant,@_cSolic,.F.)

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
				ZCZ->ZCZ_TM         :=	'506'
				ZCZ->ZCZ_SOLICI     :=	MV_PAR01
				ZCZ->ZCZ_MATORI     :=	'ZZZZZZZZ'
				ZCZ->ZCZ_USER       :=	cUserName
				ZCZ->ZCZ_ROTINA     :=	"BIAFG141"
				ZCZ->ZCZ_DTDIGI     :=	dDataBase
				ZCZ->ZCZ_DHMOV      :=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"
				ZCZ->ZCZ_DOCSEQ     :=	_cDocSeq
				ZCZ->ZCZ_TBORIG     :=	"ZCZ"
				ZCZ->ZCZ_OBS		:=	MV_PAR06
				ZCZ->ZCZ_RECID      :=	0
				ZCZ->(MsUnlock())
			Else
				DisarmTransaction()
				MsgInfo("Não Foram Encontrados registros suficientes para atender a solicitação.","BIAFG141")
				Return
			EndIf
			_nSaldoMov := _nSaldoMov - _nQuant
		EndDo

		MsgInfo("Registro gerado com sucesso","BIAFG141")
	
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

	aAdd( aPergs ,{1,"Solicit." 	   			,MV_PAR01 ,""  ,"ExistCpo('ZZY',,3).And. U_BFG141SL()",'ZZY'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Produto" 	   			,MV_PAR02 ,""  ,"ExistCpo('SB1').And. U_BFG141SL()",'SB1'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Almoxarif." 	   			,MV_PAR03 ,""  ,"U_BFG141SL()",''  ,'.T.',20,.F.})
	aAdd( aPergs ,{1,"Saldo" 	   		,MV_PAR04 ,"@E 9,999,999.99999999"  ,"",''  ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"Quantidade" 	   		,MV_PAR05 ,"@E 9,999,999.99999999"  ,"U_BFG141QT()",''  ,'.T.',50,.T.})
	aAdd( aPergs ,{11,'Motivo'				,MV_PAR06,"",".T.",.T.})

	If ParamBox(aPergs ,"Troca para Solicitante Padrão",,,,,,,,,.F.,.F.)

		lRet := .T.

	EndIf

Return lRet

User Function BFG141SL()

	Local _nSaldo	:=	0
	Local _lRet		:=	.T.

	If !Empty(MV_PAR01) .And. !Empty(MV_PAR02) .And. !Empty(MV_PAR03)
		If _oMd:CheckMD(MV_PAR02,MV_PAR03)
			MV_PAR04	:=	_oMd:Saldo(MV_PAR02,MV_PAR03,MV_PAR01,.F.)
			MV_PAR05	:=	0
		Else
			MsgInfo("O Produto não é MD para o Almoxarifado selecionado!")
			_lRet	:=	.F.
		EndIf
	EndIf 

Return _lRet

User Function BFG141QT()

	Local _lRet	:=	.T.

	If MV_PAR05 > MV_PAR04
		MsgInfo("A Quantidade não poderá ser superior ao Saldo do Produto!")
		_lRet	:=	.F.
	EndIf
Return _lRet