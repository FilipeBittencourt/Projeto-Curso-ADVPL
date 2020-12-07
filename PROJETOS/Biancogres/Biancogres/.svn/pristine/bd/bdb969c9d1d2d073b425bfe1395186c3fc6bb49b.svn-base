#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BHC0001
@author Gabriel Rossi Mafioletti
@since 15/01/2019
@version 1.0
@description Job para  geração das conferências do Headcount
@type function
/*/

User Function BHC0001()

	RpcSetType(3)
	RpcSetEnv('01','01')

	U_BHC01PRC()

Return

User Function BHC01PRC()

	Local _cAliasZLC	:=	GetNextAlias()
	Local _dDataRef		
	Local _cTipo	
	Local _cMatRes	    := ""	
	Local msCtlRot      := IsInCallStack("U_BHC0002")    
	Local msMatDe       := "        "    
	Local msMatAte      := "ZZZZZZZZ"    

	DbSelectArea("SX6")
	If !ExisteSX6("MV_YHCTIPO")
		CriarSX6("MV_YHCTIPO", 'C', 'Indica o tipo de aferição: 1-Mensal;2-Semanal,3-Diário', "1" )
	EndIf

	_cTipo	 :=	GetMv("MV_YHCTIPO")

	Do Case

		Case msCtlRot
		_dDataRef	:=	mscGet1
		msMatDe       := _cMatricula    
		msMatAte      := _cMatricula   

		Case _cTipo == "1"
		_dDataRef	:=	LastDate(Date())
		If LastDate(Date()) - Date() > 10 
			Return
		EndIf

		Case _cTipo	== "2"
		_dDataRef	:=	fLastDW()

		OtherWise
		_dDataRef	:=	Date()

	EndCase

	BeginSql Alias _cAliasZLC

		SELECT ZLB_FILIAL
		,ZLB_CODIGO
		,ZLB_MATRES
		FROM %TABLE:ZLB% ZLB
		WHERE ZLB.ZLB_FILIAL = %xFilial:ZLB%
		AND ZLB_MATRES BETWEEN %Exp:msMatDe% AND %Exp:msMatAte%
		AND (
		(
		%Exp:_dDataRef% BETWEEN ZLB_DTINI
		AND ZLB_DTFIM
		)
		OR (
		%Exp:_dDataRef% >= ZLB.ZLB_DTINI
		AND ZLB.ZLB_DTFIM = ''
		)
		)
		AND (
		(ZLB_TIPO = 'T')
		OR (
		ZLB_TIPO = 'P'
		AND NOT EXISTS (
		SELECT 1
		FROM %TABLE:ZLB% ZLBSUB
		WHERE ZLB.ZLB_FILIAL = ZLBSUB.ZLB_FILIAL
		AND ZLB_MATRES BETWEEN %Exp:msMatDe% AND %Exp:msMatAte%
		AND ZLB.ZLB_CODIGO = ZLBSUB.ZLB_CODIGO
		AND (
		(
		%Exp:_dDataRef% BETWEEN ZLBSUB.ZLB_DTINI
		AND ZLBSUB.ZLB_DTFIM
		)
		OR (
		%Exp:_dDataRef% >= ZLBSUB.ZLB_DTINI
		AND ZLBSUB.ZLB_DTFIM = ''
		)

		)
		AND ZLBSUB.ZLB_TIPO = 'T'	
		AND ZLBSUB.%NotDel%
		)
		)
		)
		AND ZLB.%NotDel%
		AND NOT EXISTS( SELECT 1 
		FROM %TABLE:ZLC% ZLC
		JOIN %TABLE:ZLD% ZLD ON ZLC.ZLC_FILIAL = ZLD.ZLD_FILIAL
		AND ZLC.ZLC_CODIGO = ZLD.ZLD_CODIGO
		AND ZLD.ZLD_CODPOS = ZLB.ZLB_CODIGO
		AND ZLC.%NotDel%
		AND ZLD.%NotDel%
		WHERE ZLC_FILIAL = %xFilial:ZLC%
		AND ZLC_MAT BETWEEN %Exp:msMatDe% AND %Exp:msMatAte%
		AND ZLC_TIPO = %Exp:_cTipo%
		AND ZLC_DATREF = %Exp:_dDataRef%
		)
		ORDER BY ZLB_MATRES

	EndSql

	BEGIN TRANSACTION

		While (_cAliasZLC)->(!EOF())

			If _cMatRes	<> (_cAliasZLC)->ZLB_MATRES

				Reclock("ZLC",.T.)
				ZLC->ZLC_FILIAL	:=	xFilial("ZLC")
				ZLC->ZLC_CODIGO	:=	GetSxEnum("ZLC","ZLC_CODIGO")
				ZLC->ZLC_MAT	:=	(_cAliasZlC)->ZLB_MATRES
				ZLC->ZLC_TIPO	:=	_cTipo
				ZLC->ZLC_DATREF	:=	_dDataRef
				ZLC->ZLC_STATUS	:=	"A"
				ZLC->(MsUnlock())

				ConfirmSX8()
				_cMatRes	:=	(_cAliasZLC)->ZLB_MATRES

			EndIf

			Reclock("ZLD",.T.)
			ZLD->ZLD_FILIAL	:=	xFilial("ZLD")
			ZLD->ZLD_CODIGO	:=	ZLC->ZLC_CODIGO
			ZLD->ZLD_CODPOS	:=	(_cAliasZLC)->ZLB_CODIGO
			ZLD->ZLD_TIPO	:=	"1"
			ZLD->(MsUnlock())

			(_cAliasZLC)->(DbSkip())

		EndDo 

	END TRANSACTION

Return

Static Function fLastDW()

	Local _dDtRet
	Local _nDias	:=	DOW(Date())

	_dDtRet	:=	DaySum(Date(),7-_nDias)

Return _dDtRet

User Function JBHC0001()

	cEmpAnt := "01"
	cFilAnt := "01"
	STARTJOB("U_BHC0001",GetEnvServer(),.F.,cEmpAnt,cFilAnt)

Return
