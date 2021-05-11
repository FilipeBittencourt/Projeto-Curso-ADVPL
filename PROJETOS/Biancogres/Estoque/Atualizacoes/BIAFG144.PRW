#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG144
@author Gabriel Rossi Mafioletti
@since 15/04/2020
@version 1.0
@description Correção de Movimentos de saída sem vínculo	
@type function
/*/

User Function BIAFG144()

		
	Local _cSql	
	Local _nI
	Local _nRecId
	Local _cDocSeq
	Private _aRecs	:=	{}
	Private _oMd	:=	TBiaControleMD():New()
	
	If !Validperg()
		Return
	EndIf

	Begin Transaction
	
		If Len(_aRecs) > 0 
	
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
				ZCZ->ZCZ_TM         :=	"005"
				ZCZ->ZCZ_SOLICI     :=	MV_PAR01
				ZCZ->ZCZ_MATORI		:=	MV_PAR01
				ZCZ->ZCZ_USER       :=	cUsername
				ZCZ->ZCZ_ROTINA     :=	"BIAFG144"
				ZCZ->ZCZ_DTDIGI     :=	dDataBase
				ZCZ->ZCZ_DHMOV      :=	Substr(dTOS(Date()),1,4) + '-' + Substr(dTOS(Date()),5,2) + '-' + Substr(dTOS(Date()),7,2) + ' ' + Time() + ".000"
				ZCZ->ZCZ_DOCSEQ     :=	_oMd:NextNum()
				ZCZ->ZCZ_TBORIG     :=	'ZCZ'
				ZCZ->ZCZ_OBS		:=	MV_PAR05
				ZCZ->ZCZ_RECID      :=	0		
			ZCZ->(MsUnlock())
				
			_nRecId		:=	ZCZ->(Recno())
			_cDocSeq	:=	ZCZ->ZCZ_DOCSEQ
	
			For _nI	:= 1 To Len(_aRecs)
				ZCZ->(DbGoTo(_aRecs[_nI]))
				If ZCZ->(!EOF())
					Reclock("ZCZ",.F.)
					ZCZ->ZCZ_DOCSEQ	:=	_cDocSeq
					ZCZ->ZCZ_RECID	:= _nRecId
					ZCZ->(MsUnlock())
				EndIF
			Next
	
			MsgInfo("Registro gerado com número de movimentação " + ZCZ->ZCZ_DOCSEQ,"BIAFG144")
		Else
			MsgInfo("Não haviam registros a serem alterados","BIAFG144")
		EndIf
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

	aAdd( aPergs ,{1,"Solicit." 	   			,MV_PAR01 ,""  ,"ExistCpo('ZZY',,3) .And. U_BFG144SL()",'ZZY'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Produto" 	   			,MV_PAR02 ,""  ,"ExistCpo('SB1') .And. U_BFG144SL()",'SB1'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Almoxarif." 	   			,MV_PAR03 ,""  ,"U_BFG144SL()",''  ,'.T.',20,.F.})
	aAdd( aPergs ,{1,"Quantidade" 	   		,MV_PAR04 ,"@E 9,999,999.99999999"  ,"",''  ,'.F.',50,.T.})
	aAdd( aPergs ,{11,'Motivo'				,MV_PAR05,"",".T.",.T.})

	If ParamBox(aPergs ,"Movimentos sem Vínculo",,,,,,,,,.F.,.F.)

		lRet := .T.

	EndIf

Return lRet

User Function BFG144SL()

	Local _nSaldo	:=	0
	Local _aArea	:=	GetArea()
	Local _cAlias	:=	GetNextAlias()

	_aRecs	:=	{}

	If !Empty(MV_PAR01) .And. !Empty(MV_PAR02) .And. !Empty(MV_PAR03)	

		If !_oMd:CheckMd(MV_PAR02,MV_PAR03)
			MsgInfo("O Produto não é MD para o Almoxarifado selecionado!")
			Return .F.
		EndIf	
		

		BeginSql Alias _cAlias
		%NoParser%
			SELECT R_E_C_N_O_ REC, ZCZ_QUANT
			FROM %TABLE:ZCZ% ZCZ
			WHERE ZCZ_FILIAL = %XFILIAL:ZCZ%
				AND ZCZ_SOLICI = %Exp:MV_PAR01%
				AND ZCZ_DOCSEQ = 'XXXXXX'
				AND ZCZ_COD = %Exp:MV_PAR02%
				AND ZCZ_LOCAL = %Exp:MV_PAR03%
				AND %NotDel%
	
		EndSql
		
		While (_cAlias)->(!EOF())
			_nSaldo +=	(_cAlias)->ZCZ_QUANT
			aAdd(_aRecs,(_cAlias)->REC)
			(_cAlias)->(DbSkip())
		Enddo
	
		MV_PAR04	:=	_nSaldo

		(_cAlias)->(DbCloseArea())

	EndIf 

	RestArea(_aArea)

Return .T.
