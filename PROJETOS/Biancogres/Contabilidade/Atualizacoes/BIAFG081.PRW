#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG081
@author Gabriel Rossi Mafioletti
@since 14/03/2019
@version 1.0
@description Validações referentes ao projeto Driver
@type function
/*/

/*Retorna se o Driver é obrigatório para a conta digitada*/
User Function BFG81VCO(_cConta)

	Local _lRet		:=	.F. //Indica se o driver é obrigatório
	Local _aArea	:=	GetArea()	

	CT1->(DbSetOrder(1))
	If CT1->(DbSeek(xFilial("CT1")+_cConta))
		If !Empty(CT1->CT1_YPCT20)
			_lRet	:=	.T.
		EndIF
	EndIf
	RestArea(_aArea)

Return _lRet

/*Retorna se o Driver é obrigatório para a classe digitada*/
User Function BFG81VCL(_cClVl)

	Local _lRet		:=	.F. //Indica se o driver é obrigatório
	Local _aArea	:=	GetArea()	

	CTH->(DbSetOrder(1))
	If CTH->(DbSeek(xFilial("CTH")+_cClVl))
		ZCA->(DbSetOrder(1))
		If ZCA->(DbSeek(xFilial("ZCA")+CTH->CTH_YENTID)) .And. ZCA->ZCA_DRIVER == '1'
			_lRet	:=	.T.
		EndIf
	EndIf
	RestArea(_aArea)

Return _lRet

/*Retorna o Driver Padrão dependendo da Operação*/
User Function BFG81DPD()

	Local _cDriver	:=	""
	Local _aArea	:=	GetArea()

	If IsInCallsTack("MATA250")	.And. INCLUI

		_cDriver := fGetDrvPad(M->D3_EMISSAO,"C.VARIAVEL")

	EndIf

	If IsInCallsTack("BIA556")

		_cDriver := fGetDrvPad(M->D3_EMISSAO,"C.VARIAVEL")

	EndIf

	IF IsInCallsTack("GPEM110") .or. (IsInCallStack('CTBA500') .and. CT5->CT5_LANPAD = "200")

		_cDriver := fGetDrvPad(dDataLanc,"RH")

	EndIf

	If IsInCallsTack("BIAFG122")

		_cDriver := fGetDrvPad(Date(),"RH")

	EndIf

	RestArea(_aArea)

Return _cDriver

Static Function fGetDrvPad(_dDtRef,_cTpOrc)

	Local _cDriver	:=	""
	Local _cAlias	:=	GetNextAlias()
	Local _cAnoRef	:=	SUBSTR(DtoS(_dDtRef),1,4)
	Local _cOrca	:=	"ORCA_" + SUBSTR(DtoS(_dDtRef),3,2) 

	BeginSql Alias _cAlias

		SELECT ISNULL(MAX(ZBE_DRIVER), '') ZBE_DRIVER
		FROM %TABLE:ZBE% ZBE
		WHERE ZBE.ZBE_FILIAL = %XFILIAL:ZBE%
		AND ZBE.ZBE_APLDEF = %Exp:_cTpOrc%
		AND ZBE.ZBE_ANOREF = %Exp:_cAnoRef%
		AND ZBE.ZBE_VERSAO = %Exp:_cOrca%
		AND ZBE.ZBE_REVISA = (
		SELECT MAX(ZBEREV.ZBE_REVISA)
		FROM %TABLE:ZBE% ZBEREV
		WHERE ZBEREV.ZBE_FILIAL = ZBE.ZBE_FILIAL
		AND ZBEREV.ZBE_ANOREF = ZBE.ZBE_ANOREF
		AND ZBEREV.ZBE_VERSAO = ZBE.ZBE_VERSAO
		AND ZBEREV.%NotDel%
		AND ZBEREV.ZBE_APLDEF = ZBE.ZBE_APLDEF
		)
		AND ZBE.%NotDel%
	EndSql

	_cDriver	:=	(_cAlias)->ZBE_DRIVER

	(_cAlias)->(DbCloseArea())

Return _cDriver
