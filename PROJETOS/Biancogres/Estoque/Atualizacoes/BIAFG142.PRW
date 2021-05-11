#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG142
@author Gabriel Rossi Mafioletti
@since 15/04/2020
@version 1.0
@description Inventário de Entrada MD por Solicitante	
@type function
/*/

User Function BIAFG142()

	Private _oMd	:=	TBiaControleMD():New()	
	
	If !Validperg()
		Return
	EndIf

	ZCN->(DbSetOrder(2))
	If !ZCN->(DbSeek(xFilial("ZCN")+MV_PAR02+MV_PAR03))
		MsgStop("O Produto e o Almoxarifado não estão cadastrados no cadastro de Produto x Almoxarifado!")
		Return
	EndIf
	
	Begin Transaction
	
		Reclock("ZCZ",.T.)
			ZCZ->ZCZ_FILIAL		:=	xFilial("ZCZ")
			ZCZ->ZCZ_DOC        :=	""
			ZCZ->ZCZ_SERIE      :=	""
			ZCZ->ZCZ_FORNEC     :=	""
			ZCZ->ZCZ_LOJA       :=	""
			ZCZ->ZCZ_ITEM       :=	""
			ZCZ->ZCZ_COD        :=	MV_PAR02
			ZCZ->ZCZ_QUANT      :=	MV_PAR04
			ZCZ->ZCZ_LOCAL      :=	MV_PAR03
			ZCZ->ZCZ_TM         :=	"004"
			ZCZ->ZCZ_SOLICI     :=	MV_PAR01
			ZCZ->ZCZ_MATORI		:=	MV_PAR01
			ZCZ->ZCZ_USER       :=	cUsername
			ZCZ->ZCZ_ROTINA     :=	"BIAFG142"
			ZCZ->ZCZ_DTDIGI     :=	dDataBase
			ZCZ->ZCZ_DHMOV      :=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"
			ZCZ->ZCZ_DOCSEQ     :=	_oMd:NextNum()
			ZCZ->ZCZ_TBORIG     :=	'ZCZ'
			ZCZ->ZCZ_OBS		:=	MV_PAR05
			ZCZ->ZCZ_RECID      :=	0		
		ZCZ->(MsUnlock())
	
		MsgInfo("Registro gerado com número de movimentação " + ZCZ->ZCZ_DOCSEQ,"BIAFG142")
	
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
	MV_PAR05 := SPACE(300)

	aAdd( aPergs ,{1,"Solicit." 	   			,MV_PAR01 ,""  ,"ExistCpo('ZZY',,3) .And. U_BFG142MD()",'ZZY'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Produto" 	   			,MV_PAR02 ,""  ,"ExistCpo('SB1') .And. U_BFG142MD()",'SB1'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Almoxarif." 	   			,MV_PAR03 ,""  ,"U_BFG142MD()",''  ,'.T.',20,.F.})
	aAdd( aPergs ,{1,"Quantidade" 	   		,MV_PAR04 ,"@E 9,999,999.99999999"  ,"",''  ,'.T.',50,.T.})
	aAdd( aPergs ,{11,'Motivo'				,MV_PAR05,"",".T.",.T.})

	If ParamBox(aPergs ,"Entrada de MD",,,,,,,,,.F.,.F.)

		lRet := .T.

	EndIf

Return lRet

User Function BFG142MD()

	Local _lRet := .T.

	If !Empty(MV_PAR01) .And. !Empty(MV_PAR02) .And. !Empty(MV_PAR03) 
		If !_oMd:CheckMd(MV_PAR02,MV_PAR03)
			MsgInfo("O Produto não é MD para o Almoxarifado selecionado!")
			_lRet	:=	.F.
		EndIf
	EndIf
	
Return _lRet