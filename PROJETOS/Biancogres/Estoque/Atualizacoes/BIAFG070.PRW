#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFG070
@author Gabriel Rossi Mafioletti
@since 03/10/2018
@version 1.0
@description Recálculo de Consumo Mensal x Local
@type function
/*/

User Function BIAFG070()

	zjMens := 'Você está prestes a atualizar o CONSUMO MÉDIO.' + CRLF

	qwContinua := Aviso('BIAFG070',  zjMens, {'Confirma', 'Cancela'}, 3)

	If qwContinua == 1 

		If !ValidPerg()
			Return
		EndIf

		Processa({|| fProcessa()})

		MsgINFO("Processamento realizado com sucesso!!!")		

	Else

		MsgSTOP("Processamento abortado!!!")

	EndIf

Return

Static Function fProcessa()

	Local _cAlias	:=	GetNextAlias()
	Local _cDataDe	:=	DtoS(MV_PAR03)
	Local _cDataAte	:=	DtoS(MV_PAR04)

	DbSelectArea("ZCP")
	ZCP->(DbSetOrder(1))

	BeginSql Alias _cAlias

		%NoParser%

		WITH CONSUMO
		AS (
		SELECT ZCN_COD D3_COD
		,ZCN_LOCAL D3_LOCAL
		,ISNULL(SUM(CONSUMO), 0) QTD
		FROM (
		SELECT ZCN.ZCN_COD
		,ZCN.ZCN_LOCAL
		,CASE 
		WHEN D3_TM > '500'
		THEN ISNULL(D3_QUANT, 0)
		ELSE ISNULL(D3_QUANT, 0) * (- 1)
	END CONSUMO
	FROM %TABLE:SB1% SB1
	JOIN %TABLE:ZCN% ZCN ON SB1.B1_FILIAL = %XFILIAL:SB1%
	AND ZCN.ZCN_FILIAL = %XFILIAL:ZCN%
	AND SB1.B1_COD = ZCN.ZCN_COD
	AND SB1.B1_MSBLQL <> '1'
	AND B1_GRUPO BETWEEN %Exp:MV_PAR01%
	AND %Exp:MV_PAR02%
	AND SB1.%NotDel%
	AND ZCN.%NotDel%
	LEFT JOIN %TABLE:SD3% SD3 ON SD3.D3_FILIAL = ZCN.ZCN_FILIAL
	AND SD3.D3_COD = ZCN.ZCN_COD
	AND SD3.D3_LOCAL = ZCN.ZCN_LOCAL
	AND D3_EMISSAO BETWEEN %Exp:_cDataDe%
	AND %Exp:_cDataAte%
	AND D3_CF NOT IN (
	'DE4'
	,'RE4'
	,'DE3'
	,'RE3'
	,'DE7'
	,'RE7'
	)
	AND SD3.%NotDel%
	AND D3_YPARADA <> 'S'
	) TBL
	GROUP BY ZCN_COD
	,ZCN_LOCAL
	)
	SELECT *
	FROM CONSUMO

	EndSql

	ProcRegua(RecCount())
	While (_cAlias)->(!EOF())

		IncProc()

		If ZCP->(DbSeek(xFilial("ZCP")+(_cAlias)->(D3_COD + D3_LOCAL)))
			RecLock("ZCP",.F.)
		Else
			Reclock("ZCP",.T.)
			ZCP->ZCP_FILIAL	:=	xFilial("ZCP")
			ZCP->ZCP_COD	:=	(_cAlias)->D3_COD
			ZCP->ZCP_LOCAL	:=	(_cAlias)->D3_LOCAL
			ZCP->ZCP_Q01	:=	0
			ZCP->ZCP_Q02	:=	0
			ZCP->ZCP_Q03	:=	0
			ZCP->ZCP_Q04	:=	0
			ZCP->ZCP_Q05	:=	0
			ZCP->ZCP_Q06	:=	0
			ZCP->ZCP_Q07	:=	0
			ZCP->ZCP_Q08	:=	0
			ZCP->ZCP_Q09	:=	0
			ZCP->ZCP_Q10	:=	0
			ZCP->ZCP_Q11	:=	0
			ZCP->ZCP_Q12	:=	0
		EndIf

		&("ZCP->ZCP_Q" + MV_PAR05) := (_cAlias)->QTD

		ZCP->(MsUnlock())

		(_cAlias)->(DbSkip())

	EndDo

	fGeraCons()

	fUpdmes()

	(_cAlias)->(DbCloseArea())

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG070" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local _nPeso	:=	0
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(4)
	MV_PAR02 := space(4)
	MV_PAR03 := Stod("")
	MV_PAR04 := Stod("")
	MV_PAR05 := SPACE(2)

	aAdd( aPergs ,{1,"Grupo De " 		  	,MV_PAR01 ,""  ,"",'SBM'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Grupo Até " 		  	,MV_PAR02 ,""  ,"NAOVAZIO()",'SBM'  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Data De " 		  	,MV_PAR03 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Data Até " 		 	,MV_PAR04 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Mês de Referência " 	,MV_PAR05 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})

	If ParamBox(aPergs ,"Consumo Mensal x Local",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)

	EndIf

	MV_PAR05	:=	PADL(ALLTRIM(MV_PAR05),2,"0")

Return lRet

Static Function fUpdMes()

	Local _cMes	:=	Dtos(LastDay(StoD(SUBSTR(Dtos(MV_PAR03),1,4) + MV_PAR05 + '01')))

	_cSql := " UPDATE ZCP SET ZCP_MES = '" + _cMes + "' "
	_cSql += " FROM " + RetSqlName("ZCP") + " ZCP(NOLOCK) "
	_cSql += "      INNER JOIN " + RetSqlName("SB1") + " SB1(NOLOCK) ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	_cSql += "                                       AND SB1.B1_COD = ZCP.ZCP_COD "	
	_cSql += "                                       AND SB1.B1_GRUPO BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
	_cSql += "                                       AND SB1.D_E_L_E_T_ = ' ' "
	_cSql += " WHERE ZCP_FILIAL = '" + xFilial("ZCP") + "' "
	_cSql += "       AND ZCP.D_E_L_E_T_ = ' ' "	

	TcSqlExec(_cSql)

Return

Static Function fGeraCons()

	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias

		SELECT ZCP_FILIAL
		,ZCP_COD
		,SUM(ZCP_Q01) ZCP_Q01
		,SUM(ZCP_Q02) ZCP_Q02
		,SUM(ZCP_Q03) ZCP_Q03
		,SUM(ZCP_Q04) ZCP_Q04
		,SUM(ZCP_Q05) ZCP_Q05
		,SUM(ZCP_Q06) ZCP_Q06
		,SUM(ZCP_Q07) ZCP_Q07
		,SUM(ZCP_Q08) ZCP_Q08
		,SUM(ZCP_Q09) ZCP_Q09
		,SUM(ZCP_Q10) ZCP_Q10
		,SUM(ZCP_Q11) ZCP_Q11
		,SUM(ZCP_Q12) ZCP_Q12
		FROM %TABLE:ZCP% ZCP
		INNER JOIN %TABLE:SB1% SB1(NOLOCK) ON SB1.B1_FILIAL = %XFILIAL:SB1%
		AND SB1.B1_COD = ZCP.ZCP_COD
		AND SB1.B1_GRUPO BETWEEN %Exp:MV_PAR01%	AND %Exp:MV_PAR02%
		AND SB1.%NotDel%
		WHERE ZCP_FILIAL = %XFILIAL:ZCP%
		AND ZCP_LOCAL IN ('01','20')
		AND ZCP.%NotDel%
		GROUP BY ZCP_FILIAL
		,ZCP_COD

	EndSql

	ProcRegua(RecCount())
	While (_cAlias)->(!EOF())

		IncProc()

		If ZCP->(DbSeek(xFilial("ZCP")+(_cAlias)->ZCP_COD + 'ZZ'))

			Reclock("ZCP",.F.)

		Else

			Reclock("ZCP",.T.)
			ZCP->ZCP_FILIAL	:=	xFilial("ZCP")
			ZCP->ZCP_COD	:=	(_cAlias)->ZCP_COD
			ZCP->ZCP_LOCAL	:=	'ZZ'

		EndIf

		ZCP->ZCP_Q01	:=	(_cAlias)->ZCP_Q01
		ZCP->ZCP_Q02	:=	(_cAlias)->ZCP_Q02
		ZCP->ZCP_Q03	:=	(_cAlias)->ZCP_Q03
		ZCP->ZCP_Q04	:=	(_cAlias)->ZCP_Q04
		ZCP->ZCP_Q05	:=	(_cAlias)->ZCP_Q05
		ZCP->ZCP_Q06	:=	(_cAlias)->ZCP_Q06
		ZCP->ZCP_Q07	:=	(_cAlias)->ZCP_Q07
		ZCP->ZCP_Q08	:=	(_cAlias)->ZCP_Q08
		ZCP->ZCP_Q09	:=	(_cAlias)->ZCP_Q09
		ZCP->ZCP_Q10	:=	(_cAlias)->ZCP_Q10
		ZCP->ZCP_Q11	:=	(_cAlias)->ZCP_Q11
		ZCP->ZCP_Q12	:=	(_cAlias)->ZCP_Q12	

		ZCP->(MsUnlock())

		(_cAlias)->(DbSkip())

	EndDo

	(_cALias)->(DbCloseArea())

Return

User Function jBIAFG070()

	RpcSetType(3)
	RpcSetEnv('01','01')

	U_BIAFG070()

Return
