#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG090
@author Gabriel Rossi Mafioletti
@since 21/05/2019
@version 1.0
@description Função para Recálculo do Caco
@type function
/*/

User Function BIAFG090(_dDataDe,_dDataAte)

	Local _cDataDe	:=	DtoS(_dDataDe)
	Local _cDataAte	:=	DtoS(_dDataAte)

	fCalcCaco(_cDataDe,_cDataAte)

	fRecCaco(_cDataDe,_cDataAte)

Return

Static Function fRecCaco(_cDataDe,_cDataAte)

	Local _cAlias	:=	GetNextAlias()
	Local _nProduc	:=	0
	Local _nProdB	:=	0
	Local _nPrdTon	:=	0
	Local _nCacoAj	:=	0
	Local _nPerCaco	:=	0

	BeginSql Alias _cAlias

		SELECT  Z94_DTREF  DTREF,
		Z94_FORMAT FORMAT,
		Z94_BAIA  BAIA,
		Z94_FORNO FORNO,
		Z94_EQUIPE EQUIPE,
		Z94_TURNO TURNO,
		Z94_CACO CACO,
		R_E_C_N_O_ REG
		FROM    %TABLE:Z94%
		WHERE   Z94_FILIAL = %XFILIAL:Z94%
		AND Z94_DTREF BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
		AND %NotDel%
		ORDER BY Z94_DTREF

	EndSql

	While (_cAlias)->(!EOF())

		xa2Linha    := "('L" + Substr((_cAlias)->FORNO,2,2) + "')"
		If (_cAlias)->FORMAT $ "CE/B9/BO/C6"
			xa2Linha := "('E03','E04')"
		EndIf
		_nProduc	:=	fCalcPrd((_cAlias)->FORMAT, (_cAlias)->DTREF, (_cAlias)->TURNO, (_cAlias)->EQUIPE, xa2Linha)
		_nProdB		:=	fPrdBaia((_cAlias)->DTREF,(_cAlias)->BAIA,(_cAlias)->TURNO)
		_nPeso		:=	fCalcPes((_cAlias)->FORMAT,(_cAlias)->DTREF,(_cAlias)->TURNO,(_cAlias)->EQUIPE)
		_nPrdTon	:=	_nProduc * _nPeso / 1000
		_nCacoAj	:=	(_cAlias)->CACO * _nPrdTon / _nProdB
		_nPerCaco	:=	_nCacoAj / (_nCacoAj + _nPrdTon)
		_nMeta		:=	fGetMeta((_cAlias)->FORMAT,(_cAlias)->DTREF)

		Z94->(DbGoTo((_cAlias)->REG)) 

		If (_cAlias)->FORMAT $ "B9/BO/C6" .And. _nProduc == 0
			_nCacoAj	:=	(_cAlias)->CACO
			_nPerCaco	:=	1	
		EndIf

		Reclock("Z94",.F.)
		Z94->Z94_PRODUC	:=	_nProduc
		Z94->Z94_CACOAJ	:=	_nCacoAj
		Z94->Z94_PRCACO	:=	_nPerCaco
		Z94->Z94_META	:=	_nMeta
		Z94->(MsUnlock())
		(_cAlias)->(DbSkip())

	EndDo

Return

Static Function fPrdBaia(_cDtRef, _cBaia, _cTurno)

	Local _cAlias	:=	GetNextAlias()
	Local _nProd	:= 0

	BeginSql Alias _cAlias

		SELECT Z94_FORMAT, Z94_TURNO, Z94_EQUIPE, Z94_FORNO
		FROM %TABLE:Z94%
		WHERE Z94_FILIAL = %Xfilial:Z94%
		AND Z94_DTREF	= %Exp:_cDtRef%
		AND Z94_BAIA	= %Exp:_cBaia%
		AND Z94_TURNO	= %Exp:_cTurno%
		AND %NotDel%

	EndSql

	While (_cAlias)->(!EOF())

		xa2Linha    := "('L" + Substr((_cAlias)->Z94_FORNO,2,2) + "')"
		If (_cAlias)->Z94_FORMAT $ "CE/B9/BO/C6"
			xa2Linha := "('E03','E04')"
		EndIf

		_nProd	+=	fCalcPrd( (_cAlias)->Z94_FORMAT, _cDtRef, (_cAlias)->Z94_TURNO, (_cAlias)->Z94_EQUIPE, xa2Linha ) * fCalcPes( (_cAlias)->Z94_FORMAT, _cDtRef, (_cAlias)->Z94_TURNO, (_cAlias)->Z94_EQUIPE) / 1000

		(_cAlias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

Return _nProd

Static Function fCalcPrd(cFormat, _cData, _cTurno, _cEquipe, _cLinha)

	Local _nProd	:=	0
	Local _cAlias	:=	GetNextALias()
	Local _cIN      := "%" + _cLinha + "%"

	BeginSql Alias _cAlias

		SELECT  ISNULL(SUM(CASE WHEN SB1.B1_YFORMAT IN ('B9', 'BO', 'C6') THEN Z75.Z75_BKQTD ELSE Z75_QUANT	END), 0) QUANT
		FROM %TABLE:Z75% Z75
		INNER JOIN %TABLE:SB1% SB1 ON B1_COD = Z75_PRODUT
		AND B1_YFORMAT = %Exp:cFormat%
		AND SB1.%NotDel%
		WHERE Z75_FILIAL = %XFILIAL:Z75%
		AND Z75_DATARF = %Exp:_cData%
		AND Z75.Z75_TURNO = %EXP:_cTurno%
		AND Z75.Z75_LINHA IN %Exp:_cIN%
		AND Z75_TPMOV IN ('ETQ','RET')
		AND ( ( B1_YFORMAT IN('BM', 'BF', 'BD', 'BE', 'BV', 'BW', 'CC', 'CD') AND Z75_TPPROD = 'PP' ) OR ( B1_YFORMAT NOT IN('BM', 'BF', 'BD', 'BE', 'BV', 'BW', 'CC', 'CD') AND Z75_TPPROD <> 'PP' ) OR ( B1_YFORMAT IN('CE') AND Z75_TPPROD = 'PA' ) )
		AND ( ( SB1.B1_YFORMAT IN ('B9', 'BO', 'C6') AND Z75.Z75_EQUIPE = '1' AND Z75.Z75_BKEQUI = %Exp:_cEquipe% ) OR ( SB1.B1_YFORMAT NOT IN ('B9', 'BO', 'C6') AND Z75.Z75_EQUIPE = %Exp:_cEquipe% )	)
		AND Z75.%NotDel%

	EndSql

	_nProd	:=	(_cAlias)->QUANT

	(_cAlias)->(DbCloseArea())

Return _nProd

Static Function fCalcPes(cFormat,_cData, _cTurno, _cEquipe)

	Local _nPeso		:=	0
	Local _cAliasPes	:=	GetNextALias()

	Local _aArea		:=	GetArea()
	BeginSql Alias _cAliasPes

		SELECT
		CASE 
		WHEN SB1.B1_YFORMAT NOT IN ('B9', 'BO', 'C6') THEN ( CASE WHEN ISNULL(SUM(Z75_QUANT),0) > 0 THEN ISNULL(SUM(Z75_QUANT * B1_PESO), 0)/ ISNULL(SUM(Z75_QUANT),0) ELSE 0 END)
		WHEN SB1.B1_YFORMAT IN ('B9', 'BO', 'C6') THEN ( CASE WHEN ISNULL(SUM(Z75_BKQTD),0) > 0 THEN ISNULL(SUM(Z75_BKQTD * B1_PESO), 0)/ ISNULL(SUM(Z75_BKQTD),0) ELSE 0 END)
		ELSE 0 
	END PESO
	FROM  %TABLE:Z75% Z75
	INNER JOIN %TABLE:SB1% SB1 ON B1_COD = Z75_PRODUT
	AND B1_YFORMAT = %Exp:cFormat%
	AND SB1.%NotDel%
	WHERE   Z75_FILIAL = %XFILIAL:Z75%
	AND Z75_DATARF = %Exp:_cData%
	AND Z75.Z75_TURNO = %EXP:_cTurno%
	AND Z75_TPMOV IN ('ETQ','RET')
	AND ( ( B1_YFORMAT IN('BM', 'BF', 'BD', 'BE', 'BV', 'BW', 'CC', 'CD') AND Z75_TPPROD = 'PP' ) OR ( B1_YFORMAT NOT IN('BM', 'BF', 'BD', 'BE', 'BV', 'BW', 'CC', 'CD') AND Z75_TPPROD <> 'PP' ) OR ( B1_YFORMAT IN('CE') AND Z75_TPPROD = 'PA' ) )
	AND ( ( SB1.B1_YFORMAT IN ('B9', 'BO', 'C6') AND Z75.Z75_EQUIPE = '1' AND Z75.Z75_BKEQUI = %Exp:_cEquipe% ) OR ( SB1.B1_YFORMAT NOT IN ('B9', 'BO', 'C6') AND Z75.Z75_EQUIPE = %Exp:_cEquipe% ) )
	AND Z75.%NotDel%
	GROUP BY SB1.B1_YFORMAT

	EndSql

	_nPeso	:=	(_cAliasPes)->PESO

	(_cAliasPes)->(DbCloseArea())

	RestArea(_aArea)

Return _nPeso

Static Function fCalcCaco(_cDataDe,_cDataAte)

	Local _cAlias	:= GetNextAlias()

	BeginSql Alias _cAlias

		SELECT DTREF
		,FORMATO
		,EQUIPE
		,TURNO
		,FORNO
		,BAIA
		,MAX(META) META
		FROM (
		SELECT Z75_DATARF DTREF
		,SUBSTRING(Z75_PRODUT, 1, 2) FORMATO
		,CASE 
		WHEN SB1.B1_YFORMAT IN ('B9', 'BO', 'C6')
		THEN Z75.Z75_BKEQUI
		ELSE Z75.Z75_EQUIPE
	END EQUIPE
	,Z75_TURNO TURNO
	,CASE 
	WHEN SUBSTRING(Z75_PRODUT, 1, 2) IN ('B9', 'BO', 'C6', 'CE') AND Z75_LINHA IN ('E03', 'E04') THEN 'F02'
	WHEN SUBSTRING(Z75_PRODUT, 1, 2) NOT IN ('B9', 'BO', 'C6', 'CE') AND Z75_LINHA IN ('E03', 'E04') THEN 'F03'
	WHEN Z75_LINHA IN ('L01', 'L02', 'L03', 'L04', 'L05') THEN 'F' + SUBSTRING(Z75_LINHA, 2, 2)
	ELSE 'IND'
	END FORNO
	,ZE3_BAIA BAIA
	,ISNULL(Z93_PERMET,0) META
	FROM %TABLE:Z75% Z75
	INNER JOIN %TABLE:SB1% SB1 ON B1_COD = Z75_PRODUT
	AND SB1.%NotDel%
	JOIN %TABLE:ZE3% ZE3 ON SB1.B1_YFORMAT = ZE3.ZE3_FORMAT
	AND Z75.Z75_DATARF BETWEEN ZE3.ZE3_INICIO
	AND ZE3.ZE3_FIM
	AND ZE3.%NotDel%
	JOIN %TABLE:Z93% Z93 ON Z93_FILIAL = %XFILIAL:Z93%
	AND Z75.Z75_DATARF BETWEEN Z93_DATADE AND Z93_DATAAT
	AND Z93_FORMAT = SB1.B1_YFORMAT
	AND Z93.%NotDel%
	WHERE Z75_FILIAL = %XFILIAL:Z75%
	AND Z75_DATARF BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
	AND Z75_TPMOV IN ('ETQ', 'RET')
	AND ( ( B1_YFORMAT IN('BM', 'BF', 'BD', 'BE', 'BW', 'BV', 'CC', 'CD') AND Z75_TPPROD = 'PP' ) OR ( B1_YFORMAT NOT IN ('BM', 'BF', 'BD', 'BE', 'BW', 'BV', 'CC', 'CD') AND Z75_TPPROD <> 'PP' ) OR ( B1_YFORMAT IN('CE') AND Z75_TPPROD = 'PA' ) )
	AND ( ( SB1.B1_YFORMAT IN ('B9', 'BO', 'C6') AND Z75.Z75_EQUIPE = '1' ) OR ( SB1.B1_YFORMAT NOT IN ('B9', 'BO', 'C6') ) )
	AND Z75.%NotDel%
	) DADOS
	WHERE NOT EXISTS (
	SELECT 1
	FROM %TABLE:Z94% Z94
	WHERE Z94_FILIAL = %XFILIAL:Z94%
	AND Z94.Z94_DTREF = DADOS.DTREF
	AND Z94.Z94_FORMAT = DADOS.FORMATO
	AND Z94.Z94_EQUIPE = DADOS.EQUIPE
	AND Z94.Z94_FORNO = DADOS.FORNO
	AND Z94.Z94_TURNO = DADOS.TURNO
	AND Z94.Z94_BAIA = DADOS.BAIA
	AND Z94.%NotDel%
	)
	GROUP BY DTREF
	,FORMATO
	,EQUIPE
	,TURNO
	,FORNO
	,BAIA
	ORDER BY 1
	,2

	EndSql

	While (_cAlias)->(!EOF())

		RecLock("Z94",.T.)
		Z94->Z94_FILIAL	:=	xFilial("Z94")
		Z94->Z94_DTREF	:=	Stod((_cAlias)->DTREF)
		Z94->Z94_FORMAT	:=	(_cAlias)->FORMATO
		Z94->Z94_EQUIPE	:=	(_cAlias)->EQUIPE
		Z94->Z94_FORNO	:=	(_cAlias)->FORNO
		Z94->Z94_TURNO	:=	(_cAlias)->TURNO
		Z94->Z94_BAIA	:=	(_cAlias)->BAIA
		Z94->Z94_META	:=	(_cAlias)->META
		Z94->(MsUnlock())
		(_cALias)->(DbSkip())

	EndDo

	(_cAlias)->(DbCloseArea())

Return

Static Function fGetMeta(_cForm,_cDtRef)

	Local _nMeta	:=	0
	Local _cAlias	:= GetNextAlias()

	BeginSql Alias _cAlias

		SELECT MAX(ISNULL(Z93_PERMET,0)) META
		FROM %TABLE:Z93% Z93 
		WHERE Z93_FILIAL = %XFILIAL:Z93%
		AND %Exp:_cDtRef% BETWEEN Z93_DATADE AND Z93_DATAAT
		AND Z93_FORMAT = %Exp:_cForm%
		AND Z93.%NotDel%

	EndSql

	_nMeta	:=	(_cAlias)->META

	(_cAlias)->(DbCloseArea())

Return _nMeta

User Function BFG090prc()

	RpcSetType(3)
	RpcSetEnv('01','01')

	U_BIAFG090(STOD('20200101'), stod('20200131'))

	RpcClearEnv()

Return
