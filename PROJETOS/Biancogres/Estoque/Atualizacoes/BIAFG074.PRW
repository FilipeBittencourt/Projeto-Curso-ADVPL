#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG074
@author Gabriel Rossi Mafioletti
@since 06/11/2018
@version 1.0
@description Processamento de necessidades de pré-requisição(Transferências)
@type function
/*/

User Function BIAFG074()

	If !Validperg()
		Return
	EndIf

	Processa({|| fProcessa()})

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG074" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}
	local aOpcs 	:= {"01","20"}
	
	MV_PAR01 := SPACE(TAMSX3("B1_COD")[1])
	MV_PAR02 := SPACE(TAMSX3("B1_COD")[1])
	MV_PAR03 := " "
	MV_PAR04 := "01"
	MV_PAR05 := "20"

	aAdd( aPergs ,{1,"Produto De " 	   			,MV_PAR01 ,""  ,"",'SB1'  ,'.T.',50,.F.})	
	aAdd( aPergs ,{1,"Produto Até " 	   		,MV_PAR02 ,""  ,"NAOVAZIO()",'SB1'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Política " 	   			,MV_PAR03 ,""  ,"NAOVAZIO()",'Y8'  ,'.T.',50,.F.})
	aAdd( aPergs ,{2,"Almox. Ori. " ,MV_PAR04 ,aOpcs,60,'.T.',.T.})	
	aAdd( aPergs ,{2,"Almox. Dest. " ,MV_PAR05 ,aOpcs,60,'.T.',.T.})

	If ParamBox(aPergs ,"Processamento de Pré-Transferências",,{|| U_BFG074OK()},,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)

	EndIf

Return lRet

Static Function fProcessa()

	Local _cAlias	:=	GetNextAlias()
	Local _nMes
	Local _nMedia	:=	0
	Local _nI
	Local _nSaldo	:=	0
	Local _lSZI	:=	.F.
	Local _cDoc	:=	""
	Local _lRet	:=	.F.
	Local _cCpo	:=	""
	Local _nSalOri	:=	0

	BEGIN TRANSACTION

		BeginSql Alias _cAlias

			SELECT ZCP.*
			FROM %TABLE:ZCP% ZCP
			JOIN %TABLE:SB1% SB1 ON ZCP.ZCP_COD = SB1.B1_COD
			AND SB1.B1_COD BETWEEN %EXP:MV_PAR01%
			AND %EXP:MV_PAR02%
			AND SB1.B1_MSBLQL <> '1'
			AND SB1.%NotDel%
			AND ZCP.%NotDel%	
			JOIN %TABLE:SBZ% SBZ ON SBZ.BZ_FILIAL = %XFILIAL:SBZ%
			AND SBZ.BZ_COD = SB1.B1_COD
			AND SBZ.%NotDel%
			JOIN %TABLE:ZCN% ZCN ON ZCP.ZCP_COD = ZCN.ZCN_COD
			AND ZCP.ZCP_LOCAL = ZCN.ZCN_LOCAL
			AND ZCN.ZCN_LOCAL = %Exp:MV_PAR05%
			AND ZCN.ZCN_POLIT = %EXP:MV_PAR03%
			AND NOT (ZCN.ZCN_POLIT = '4' AND SUBSTRING(ZCN.ZCN_COD,1,2) IN ('2','4'))
			AND ZCN.%NotDel%
		EndSql	

		_cDoc	:=	GetSxENum("SZI","ZI_DOC")
		SZI->(dbSetOrder(1))
		If SZI->(dbSeek(xFilial("SZI") + _cDoc))
			While .T.
				_cDoc	:=	GetSxENum("SZI","ZI_DOC")
				SZI->(dbSetOrder(1))
				If !SZI->(dbSeek(xFilial("SZI") + _cDoc))
					Exit
				EndIf
			End
		EndIf

		While (_cAlias)->(!EOF())
			_nMes	:=	Val(SUBSTR((_cAlias)->ZCP_MES,5,2))
			_nMedia	:=	0
			For _nI	:=	1 to 3

				_cCpo	:=	"(_cALias)->ZCP_Q"+PADL(Alltrim(Str(_nMes)),2,"0")
				_nMedia	+=	&_cCpo

				_nMes	:=	Iif(_nMes == 1, 12,_nMes - 1)

			Next

			_nMedia	:=	INT(_nMedia/3)

			_nSaldo	:= fCalcSal( (_cAlias)->ZCP_COD, (_cAlias)->ZCP_LOCAL)

			_nSaldo += fCalcTrans((_cAlias)->ZCP_COD,(_cAlias)->ZCP_LOCAL) 

			_nSalOri	:=	fSalOri( (_cAlias)->ZCP_COD, MV_PAR04)

			If _nMedia - _nSaldo > 0 .And. _nSalOri >= _nMedia - _nSaldo

				_nSaldo	:=	Min(_nMedia - _nSaldo,_nSalOri)

				_lRet :=	fCriaTrans((_cAlias)->ZCP_COD,(_cAlias)->ZCP_LOCAL,_nSaldo, _cDoc,MV_PAR04)

				If _lRet 
					_lSZI	:=	.T.
				EndIf

			EndIf

			(_cAlias)->(DbSkip())
		EndDo

		If _lSZI

			RecLock("SZI",.T.)
			SZI->ZI_FILIAL  := xFilial("SZI")
			SZI->ZI_DOC     := _cDoc
			SZI->ZI_EMPRESA := cEmpAnt //RAC
			SZI->ZI_EMISSAO := Date()
			SZI->ZI_MATRIC  := "TRANSFER"
			SZI->ZI_CLVL    := "1221"
			SZI->ZI_NOME    := "PRE-TRANSFERENCIA AUTOMATICA"
			SZI->ZI_TIPO    := "TR"
			SZI->ZI_BAIXA   := "N"
			SZI->ZI_YDOCORI	:= "TRANSAUTO"
			SZI->(MsUnLock())
			ConfirmSX8()
		Else
			RollbackSX8()
		EndIf
	End Transaction

	(_cAlias)->(DbCloseArea())

	MsgInfo("Processamento Finalizado!")

Return

Static Function fCriaTrans(_cCod,_cLocal,_nQtd,_cDoc,_cLocOri)

	Local _lRet	:=	.T.

	DbSelectArea("SZJ")
	RecLock("SZJ",.T.)
	SZJ->ZJ_FILIAL  := xFilial("SZJ")
	SZJ->ZJ_DOC     := _cDoc
	SZJ->ZJ_EMPRESA := cEmpAnt				//RAC
	SZJ->ZJ_LOCAL	:= _cLocOri
	SZJ->ZJ_COD     := _cCod
	SZJ->ZJ_YLOCORI   := _cLocal //RAC
	SZJ->ZJ_DESCRI  := POSICIONE("SB1",1,xFilial("SB1")+_cCod,'B1_DESC')
	SZJ->ZJ_UM      := POSICIONE("SB1",1,xFilial("SB1")+_cCod,'B1_UM')
	SZJ->ZJ_QUANT   := _nQtd
	SZJ->ZJ_EMPDEST := cEmpAnt
	SZJ->(MsUnLock())

Return _lRet

Static Function fCalcTrans(_cCod,_cLocal)

	Local _cAlias	:=	GetNextAlias()

	Local _nQtd	:=	0

	BeginSql Alias _cAlias

		SELECT ISNULL(SUM(ZJ_QUANT),0) QUANT
		FROM %TABLE:SZI% SZI
		JOIN %TABLE:SZJ% SZJ ON SZI.ZI_FILIAL = SZJ.ZJ_FILIAL
		AND SZI.ZI_FILIAL = %XFILIAL:SZI%
		AND SZI.ZI_DOC = SZJ.ZJ_DOC
		AND SZI.%NotDel%
		AND SZJ.%NotDel%
		AND SZI.ZI_TIPO = 'TR'
		AND SZJ.ZJ_BAIXA = ''
		AND SZJ.ZJ_YLOCORI = %Exp:_cLocal%
		AND SZJ.ZJ_COD = %Exp:_cCod%

	EndSql

	_nQtd	:=	(_cAlias)->QUANT

	(_cAlias)->(DbCloseArea())

Return _nQtd

Static Function fCalcSal(_cCod,_cLocal)

	Local _cAlias	:=	GetNextAlias()
	Local _nret	:=	0

	BeginSql Alias _cAlias

		SELECT ISNULL(B2_QATU - B2_RESERVA,0) SALDO
		FROM %TABLE:SB2%
		WHERE B2_FILIAL = %xFILIAL:SB2%
		AND B2_COD = %Exp:_cCod%
		AND B2_LOCAL = %Exp:_cLocal%
		AND %NotDel%
	EndSql

	_nret	:=	(_cAlias)->SALDO

	(_cAlias)->(DbCloseArea())

Return _nRet

Static Function fSalOri(_cCod,_cLocal)

	Local _cAlias	:=	GetNextAlias()
	Local _nret	:=	0

	BeginSql Alias _cAlias

		SELECT ISNULL(B2_QATU - B2_RESERVA - ZCN_PONPED,0) SALDO
		FROM %TABLE:SB2% SB2
		JOIN %TABLE:ZCN% ZCN ON SB2.B2_COD = ZCN.ZCN_COD
			AND SB2.B2_LOCAL = ZCN.ZCN_LOCAL
			AND ZCN.%NotDel%
		WHERE B2_FILIAL = %xFILIAL:SB2%
		AND B2_COD = %Exp:_cCod%
		AND B2_LOCAL = %Exp:_cLocal%
		AND SB2.%NotDel%
	EndSql

	_nret	:=	(_cAlias)->SALDO

	(_cAlias)->(DbCloseArea())

Return _nRet

User Function BFG074OK()

	Local _lRet	:=	.T.
	
	If Alltrim(MV_PAR03) == "4"
		MsgInfo("Não é possível selecionar a política 4 para esse processamento")
		_lRet	:=	.F.		
	EndIf

	If Alltrim(MV_PAR04) == Alltrim(MV_PAR05)
		MsgInfo("O armazém de origem não pode ser igual ao armazém de destino")
		_lRet	:=	.F.			
	EndIf

Return _lRet