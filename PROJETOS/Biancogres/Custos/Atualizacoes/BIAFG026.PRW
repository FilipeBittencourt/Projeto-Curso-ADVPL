#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} BIAFG026
@author Gabriel Rossi Mafioletti
@since 11/12/2017
@version 1.0
@description Rotina que realiza recálculo dos dados referentes ao consumo de gás.
@type function
/*/

User Function BIAFG026(_cAnoMes, _lTela)

	Local _cAlias	
	Local _aArea	:=	GetArea()
	Local _aDatas	:=	{}
	
	Default _lTela	:=	.F.
	If cEmpAnt	== "01"
		
		_cAlias	:=	GetNextAlias()

		_cAnoMes	:=	_cAnoMes + "%"

		BeginSql Alias _cAlias

			SELECT DISTINCT Z91_DATA
			FROM %TABLE:Z91% Z91
			WHERE Z91.Z91_FILIAL = %xFilial:Z91%
			AND Z91.Z91_DATA like %Exp:_cAnoMes%
			AND Z91.%NotDel%
		EndSql

		While (_cAlias)->(!EOF())

			If aScan(_aDatas,{|x| x == (_cAlias)->Z91_DATA}) == 0
				fWfPeso((_cAlias)->Z91_DATA)
				aAdd(_aDatas,(_cAlias)->Z91_DATA)
			EndIf
			//Recalcula a Produção
			fCalcProd((_cAlias)->Z91_DATA)
			
			fCalcMeta((_cAlias)->Z91_DATA)
			
			//Recalcular Vazão Ajustada, Percentual de Vazão
			fPondProd((_cAlias)->Z91_DATA)

			fCalcNm3((_cAlias)->Z91_DATA)

			fCalcPCI((_cAlias)->Z91_DATA)

			(_cAlias)->(DbSkip())
		EndDo

		(_cAlias)->(DbCloseArea())

	EndIf


	//Calcula o somatório do recurso ATM000
	fCalcATM(_cAnomes)

	
RestArea(_aArea)

Return

//Recalcula a Produção dia-a-dia
Static Function fCalcProd(_cData)

	Local _cAliasD		:=	GetNextAlias()
	Local _cFormat
	Local _cAlias	//Alias Para calculo da produção
	Local _nQuant
	Local _cAlias2	//Alias para calculo da produção


	BeginSql Alias _cAliasD

		SELECT  *
		FROM    %TABLE:Z91% Z91
		WHERE   Z91_FILIAL = %XFILIAL:Z91%
		AND Z91_DATA = %Exp:_cData%
		AND Z91.%NotDel%
		AND ( Z91_FORMAT <> ''
		OR Z91_RECURS IN ( 'ATM090', 'ATM140', 'FLS001','LB0001','LB0002','FLS002')
		)
		ORDER BY Z91_DATA

	EndSql

	While (_cAliasD)->(!EOF())
		_cFormat	:=	(_cAliasD)->Z91_FORMAT
		If _cFormat $ "C6/BO"
			_cFormat := "C1"
		EndIf

		If !Empty(_cFormat)
			do case
				case Alltrim((_cAliasD)->Z91_RECURS) $ "SEC003/FOR003"
				_cAlias	:=	GetNextAlias()

				BeginSql Alias _cAlias
					SELECT  ISNULL(SUM(Z75_QUANT),0) QUANT
					FROM    %TABLE:Z75% Z75
					INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %xFilial:SB1%
					AND B1_COD = Z75_PRODUT
					AND B1_YFORMAT =	%Exp:_cFormat%
					AND SB1.%NotDel%
					WHERE   Z75_FILIAL = %xFilial:Z75%
					AND Z75_DATARF = %Exp:(_cAliasD)->Z91_DATA%
					AND Z75_TPMOV IN ('ETQ','RET')
					AND Z75_TPPROD = 'PP'
					AND Z75.%NotDel%
				EndSql

				_nQuant	:=	(_cAlias)->QUANT
				(_cAlias)->(DbCloseArea())
				Z91->(DbGoTo((_cAliasD)->R_E_C_N_O_))
				Reclock("Z91",.F.)
				Z91->Z91_PORDM2	:=	_nQuant
				Z91->(MsUnlock())

				case Alltrim((_cAliasD)->Z91_RECURS) $ "SEC001/FOR001/SEC002/FOR002/SEC004/SEC005/FOR004/FOR005"
				_cAlias	:=	GetNextAlias()

				BeginSql Alias _cAlias
					SELECT  ISNULL(SUM(Z75_QUANT),0) QUANT
					FROM    %TABLE:Z75% Z75
					INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
					AND B1_COD = Z75_PRODUT
					AND B1_YFORMAT = %Exp:_cFormat%
					AND SB1.%NotDel%
					WHERE   Z75_FILIAL = %xFilial:Z75%
					AND Z75_DATARF = %Exp:(_cAliasD)->Z91_DATA%
					AND Z75_TPMOV IN ('ETQ','RET')
					AND Z75_TPPROD <> 'PP'
					AND Z75.%NotDel%
				EndSql

				_nQuant	:=	(_cAlias)->QUANT

				(_cAlias)->(DbCloseArea())

				Z91->(DbGoTo((_cAliasD)->R_E_C_N_O_))
				Reclock("Z91",.F.)
				Z91->Z91_PORDM2	:=	_nQuant
				Z91->(MsUnlock())

			endcase

		ElseIf Alltrim((_cAliasD)->Z91_RECURS) $ "ATM090/ATM140"
			_cAlias		:=	GetNextAlias()
			_cAlias2	:=	GetNextAlias()

			BeginSql Alias _cAlias
				%NoParser%
				WITH PORCELANATO
				AS (
					SELECT B1_COD PRODUT
						,B1_YFORMAT FORMATO
					FROM %TABLE:SB1% (NOLOCK)
					WHERE B1_FILIAL = %XFILIAL:SB1%
						AND B1_YSTATUS = '1'
						AND B1_YCLASSE = ' '
						AND B1_TIPO = 'PP'
						AND B1_YTPPROD <> 'RP'
						AND B1_YFORMAT NOT IN (
							'BN'
							,'BP'
							,'AL'
							)
						AND %NotDel%
					)
				SELECT 
					SUM(CASE 
						WHEN PERDA = 0
							THEN 0
						ELSE QTDM / (1+(PERDA/100))
						END)/SUM(QTDPRD)QUANT
				FROM (
					SELECT PRODUT
						,FORMATO
						,D3M.D3_COD
						,D3M.D3_QUANT QTDM
						,SD3.D3_QUANT QTDPRD
						,ISNULL(ZRX.ZRX_PERDA, 0) PERDA
					FROM PORCELANATO PRC
					INNER JOIN %TABLE:SD3% SD3 (NOLOCK) ON SD3.D3_FILIAL = %XFILIAL:SD3%
						AND SD3.D3_COD = PRODUT
						AND SD3.D3_TM = '010'
						AND SD3.D3_ESTORNO <> 'S'
						AND SD3.%NotDel%
						AND SD3.D3_EMISSAO = %Exp:(_cAliasD)->Z91_DATA%
					INNER JOIN %TABLE:SD3% D3M (NOLOCK) ON SD3.D3_FILIAL = D3M.D3_FILIAL
						AND SD3.D3_NUMSEQ = D3M.D3_NUMSEQ
					INNER JOIN %TABLE:SB1% B1FIL (NOLOCK) ON B1FIL.B1_FILIAL = %XFILIAL:SB1%
						AND B1FIL.B1_COD = D3M.D3_COD
						AND B1FIL.B1_GRUPO = 'PI01'
						AND B1FIL.%NotDel%
					LEFT JOIN %TABLE:ZRX% ZRX ON ZRX.ZRX_FORMAT = FORMATO
						AND SD3.D3_EMISSAO BETWEEN ZRX.ZRX_INI
							AND ZRX.ZRX_FIM
						AND ZRX.%NotDel%
					) A			
			EndSql

			If (_cAliasD)->Z91_DATA >= '20201023'
				BeginSql Alias _cAlias2
					SELECT  ISNULL(SUM(D3_QUANT),0) QUANT
					FROM    %TABLE:SD3% SD3
					INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
					AND B1_COD = D3_COD
					AND B1_DESC NOT LIKE 'PBI%'
					AND B1_GRUPO = 'PI01'
					AND SB1.%NotDel%
					WHERE   D3_FILIAL = %XFILIAL:SD3%
					AND D3_EMISSAO = %Exp:(_cAliasD)->Z91_DATA%
					AND D3_TM = '010'
					AND D3_YRECURS	= %Exp:(_cAliasD)->Z91_RECURS%
					AND D3_ESTORNO = ' '
					AND SD3.%NotDel%					
				EndSql
			Else
				BeginSql Alias _cAlias2
					SELECT  ISNULL(SUM(D3_QUANT),0) QUANT
					FROM    %TABLE:SD3% SD3
					INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
					AND B1_COD = D3_COD
					AND B1_DESC NOT LIKE 'PBI%'
					AND B1_GRUPO = 'PI01'
					AND SB1.%NotDel%
					WHERE   D3_FILIAL = %XFILIAL:SD3%
					AND D3_EMISSAO = %Exp:(_cAliasD)->Z91_DATA%
					AND D3_TM = '010'
					AND D3_ESTORNO = ' '
					AND SD3.%NotDel%					
				EndSql
			EndIf

			Z91->(DbGoTo((_cAliasD)->R_E_C_N_O_))

			_nQuant	:=	(_cAlias2)->QUANT / (_cAlias)->QUANT

			Reclock("Z91",.F.)
			Z91->Z91_PORDM2	:=	_nQuant
			Z91->Z91_INDCAL	:=	(_cAlias)->QUANT
			Z91->Z91_PRODUC	:=	(_cAlias2)->QUANT
			Z91->(MsUnlock())

			(_cAlias)->(DbCloseArea())
			(_cAlias2)->(DbCloseArea())

		ElseIf Alltrim((_cAliasD)->Z91_RECURS) $ "FLS001/LB0001/LB0002/FLS002"
			_cAlias		:=	GetNextAlias()
			_cAlias2	:=	GetNextAlias()

			BeginSql Alias _cAlias
				%NoParser%
				WITH PORCELANATO
				AS (
					SELECT B1_COD PRODUT
						,B1_YFORMAT FORMATO
					FROM %TABLE:SB1% (NOLOCK)
					WHERE B1_FILIAL = %XFILIAL:SB1%
						AND B1_YSTATUS = '1'
						AND B1_YCLASSE = ' '
						AND B1_TIPO = 'PP'
						AND B1_YTPPROD <> 'RP'
						AND B1_YFORMAT IN (
							'BN'
							,'BP'
							,'AL'
							)
						AND %NotDel%
					)
				SELECT 
					SUM(CASE 
						WHEN PERDA = 0
							THEN 0
						ELSE QTDM / (1+(PERDA/100))
						END)/SUM(QTDPRD)QUANT
				FROM (
					SELECT PRODUT
						,FORMATO
						,D3M.D3_COD
						,D3M.D3_QUANT QTDM
						,SD3.D3_QUANT QTDPRD
						,ISNULL(ZRX.ZRX_PERDA, 0) PERDA
					FROM PORCELANATO PRC
					INNER JOIN %TABLE:SD3% SD3 (NOLOCK) ON SD3.D3_FILIAL = %XFILIAL:SD3%
						AND SD3.D3_COD = PRODUT
						AND SD3.D3_TM = '010'
						AND SD3.D3_ESTORNO <> 'S'
						AND SD3.%NotDel%
						AND SD3.D3_EMISSAO = %Exp:(_cAliasD)->Z91_DATA%
					INNER JOIN %TABLE:SD3% D3M (NOLOCK) ON SD3.D3_FILIAL = D3M.D3_FILIAL
						AND SD3.D3_NUMSEQ = D3M.D3_NUMSEQ
					INNER JOIN %TABLE:SB1% B1FIL (NOLOCK) ON B1FIL.B1_FILIAL = %XFILIAL:SB1%
						AND B1FIL.B1_COD = D3M.D3_COD
						AND B1FIL.B1_GRUPO = 'PI01'
						AND B1FIL.%NotDel%
					LEFT JOIN %TABLE:ZRX% ZRX ON ZRX.ZRX_FORMAT = FORMATO
						AND SD3.D3_EMISSAO BETWEEN ZRX.ZRX_INI
							AND ZRX.ZRX_FIM
						AND ZRX.%NotDel%
					) A			
			EndSql

			BeginSql Alias _cAlias2
				SELECT  ISNULL(SUM(D3_YQTUMID),0) QUANTSM, ISNULL(SUM(D3_QUANT),0) QUANTLB
				FROM    %TABLE:SD3% SD3
				        INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
				                                 AND B1_COD = D3_COD
				                                 AND B1_GRUPO = 'PI01'
				                                 AND SB1.%NotDel%
				WHERE   D3_FILIAL = %XFILIAL:SD3%
				        AND D3_EMISSAO = %Exp:_cData%
				        AND D3_TM = '010'
				        AND D3_ESTORNO = ' '
				        AND D3_LOCAL = '20'
				        AND SD3.%NotDel%					
			EndSql
			
			Z91->(DbGoTo((_cAliasD)->R_E_C_N_O_))
		
			If Alltrim(Z91->Z91_RECURS) == "FLS001
				_nQuant	:=	(_cAlias2)->QUANTSM / (_cAlias)->QUANT
				
			ElseIf Alltrim(Z91->Z91_RECURS) <> 'LB0001'
				_nQuant := (_cAlias2)->QUANTLB /  (_cAlias)->QUANT
			Else
				_nQuant := (_cAliasD)->Z91_PRODUC / (_cAlias)->QUANT
			EndIf
				
				
			Reclock("Z91",.F.)
			Z91->Z91_PORDM2	:=	_nQuant
			Z91->Z91_INDCAL	:=	(_cAlias)->QUANT
			If Alltrim((_cAliasD)->Z91_RECURS) == "FLS001
				Z91->Z91_PRODUC	:=	(_cAlias2)->QUANTSM
			Elseif Alltrim((_cAliasD)->Z91_RECURS) <> 'LB0001'
				Z91->Z91_PRODUC	:=	(_cAlias2)->QUANTLB
			EndIf
			
			Z91->(MsUnlock())
			
			
			(_cAlias)->(DbCloseArea())
			(_cAlias2)->(DbCloseArea())					

			
		EndIf		

		(_cAliasD)->(DbSkip())
	EndDo

	(_cAliasD)->(DbCloseArea())

Return

Static Function fCalcATM(_cAnoMes)

	Local _cAlias		:=	GetNextAlias()
	Local _cAnomes		:=	Substr(_cAnomes,1,6) + "%"

	BeginSql Alias _cAlias

		SELECT  ISNULL(SUM(A.PRODM2),0) AS PRODM2 ,
		ISNULL(SUM(A.PRODTN),0) AS PRODTN ,
		ISNULL(SUM(A.VAZNM3),0) AS VAZNM3 ,
		ISNULL(AVG(A.META),0) AS META ,
		CASE WHEN ISNULL(SUM(A.PRODM2),0) = 0 THEN 0 ELSE ISNULL(SUM(A.VAZNM3),0) / ISNULL(SUM(A.PRODM2),0) END AS CONS ,
		ISNULL(AVG(A.METATN),0) AS METATN ,
		CASE WHEN ISNULL(SUM(A.PRODTN),0) = 0 THEN 0 ELSE ISNULL(SUM(A.VAZNM3),0) / ISNULL(SUM(A.PRODTN),0) END AS CONSTM
		FROM    ( SELECT    Z91_DATA ,
		AVG(Z91.Z91_PORDM2) PRODM2 ,
		AVG(Z91.Z91_PRODUC) PRODTN ,
		SUM(Z91.Z91_VAZNM3) VAZNM3 ,
		AVG(Z91.Z91_META) META ,
		AVG(Z91.Z91_METATN) METATN

		FROM %TABLE:Z91% Z91
		WHERE   Z91_DATA LIKE %Exp:_cAnoMes%
		AND Z91_RECURS IN ( 'ATM090', 'ATM140', 'FLS001', 'LB0001' )
		AND %NotDel%
		GROUP BY Z91_DATA) A

	EndSql

	If Z91->(DbSeek(xFilial("Z91")+ DTOS(FirstDate(Stod(Substr(_cAnoMes,1,6)+'01')))+PADR("",TamSx3("Z91_FORMAT")[1])+PADR("ATM000",TamSx3("Z91_RECURS")[1])))
		Reclock("Z91",.F.)
	Else
		Reclock("Z91",.T.)
	EndIf

	Z91->Z91_FILIAL :=	xFilial("Z91")
	Z91->Z91_DATA	:=	FirstDate(Stod(Substr(_cAnoMes,1,6)+'01'))
	Z91->Z91_RECURS	:=	"ATM000"
	Z91->Z91_RECDES	:=	Posicione("SH1", 1, xFilial("SH1") + Z91->Z91_RECURS, "H1_DESCRI")
	Z91->Z91_MEDIDO	:=	"MED001"
	Z91->Z91_MEDDES	:=	Posicione("SH4", 1, xFilial("SH4") + Z91->Z91_MEDIDO, "H4_DESCRI")
	Z91->Z91_PORDM2	:=	(_cAlias)->PRODM2
	Z91->Z91_PRODUC	:= 	(_cAlias)->PRODTN
	Z91->Z91_VAZNM3	:=	(_cAlias)->VAZNM3
	Z91->Z91_META	:=	(_cAlias)->META
	Z91->Z91_CONSUM	:=	ROUND((_cAlias)->CONS,TAMSX3("Z91_CONSUM")[2])
	Z91->Z91_METATN	:=	(_cAlias)->METATN
	Z91->Z91_CONNMT	:=	(_cAlias)->CONSTM

	Z91->(MsUnlock())

	(_cAlias)->(DbCloseArea())

Return

Static Function fPondProd(_cData)

	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias

		SELECT  Z91_DATA ,
		Z91_FORMAT ,
		Z91_RECURS ,
		Z91_MEDIDO ,
		Z91_PORDM2 ,
		Z91_VAZM3 ,
		Z91_PORDM2,
		( SELECT   SUM(Z91PRD.Z91_PORDM2)
		FROM     Z91010 Z91PRD
		WHERE    Z91PRD.Z91_FILIAL = Z91.Z91_FILIAL
		AND Z91PRD.Z91_RECURS = Z91.Z91_RECURS
		AND Z91PRD.Z91_MEDIDO = Z91.Z91_MEDIDO
		AND Z91PRD.Z91_DATA = Z91.Z91_DATA
		AND Z91PRD.D_E_L_E_T_ = ''
		) TOTPRD,
		Z91.R_E_C_N_O_ AS REG
		FROM    %TABLE:Z91% Z91
		WHERE   Z91.Z91_FILIAL = %xFilial:Z91%
		AND Z91_DATA = %Exp:_cData%
		AND Z91.%NotDel%
		AND ( Z91_FORMAT <> ''
		OR Z91_RECURS IN ( 'ATM090', 'ATM140' )
		)
		ORDER BY Z91_RECURS ,
		Z91_MEDIDO

	EndSql

	While (_cAlias)->(!EOF())
		Z91->(DbGoTo((_cAlias)->REG))

		Reclock("Z91",.F.)
		If (_cAlias)->Z91_RECURS $ "ATM090/ATM140"
			Z91->Z91_PERVAZ	:=	1
			Z91->Z91_VAZAJU	:=	Z91->Z91_VAZM3
		Else
			Z91->Z91_PERVAZ	:=	Z91->Z91_PORDM2 / (_cAlias)->TOTPRD
			Z91->Z91_VAZAJU	:=	Z91->Z91_PORDM2 / (_cAlias)->TOTPRD * Z91->Z91_VAZM3
		EndIf
		Z91->(MsUnlock())

		(_cAlias)->(DbSkip())
	EndDo

	(_cAlias)->(DbCloseArea())
Return

Static Function fCalcNm3(_cData)

	Local _cAlias	:=	GetNextAlias()
	Local _nVazNm3

	BeginSql Alias _cAlias

		SELECT  *
		FROM    %TABLE:Z91% Z91
		WHERE   Z91_FILIAL = %XFILIAL:Z91%
		AND Z91_DATA = %Exp:_cData%
		AND Z91.%NotDel%
		AND ( Z91_FORMAT <> ''
		OR Z91_RECURS IN ( 'ATM090', 'ATM140','LB0001', 'FLS001','LB0002','FLS002')
		)
		ORDER BY Z91_DATA

	EndSql

	While (_cAlias)->(!EOF())

		Z91->(DbGoTo((_cAlias)->R_E_C_N_O_))

		//Faço os Novos Cálculos antes de Gravar novamente para evitar que o registro fique travado
		_nVazNm3	:=	BgvVazNm3(Z91->Z91_VAZAJU,Z91->Z91_PRESTR,Z91->Z91_TEMPTR,Z91->Z91_FATCOR,Z91->Z91_RECURS,Z91->Z91_DENSID, DtoS(Z91->Z91_DATA))

		Reclock("Z91",.F.)
		Z91->Z91_VAZNM3	:=	_nVazNm3
		If Z91->Z91_RECURS $ "ATM090/ATM140"
			Z91->Z91_CONNMT	:=	Iif(_nVazNm3 <> 0 .And. Z91->Z91_PRODUC <> 0,_nVazNm3/Z91->Z91_PRODUC,0)
		EndIf

		Z91->Z91_CONSUM	:=	Round(Iif(_nVazNm3 <> 0 .And. Z91->Z91_PORDM2 <> 0,_nVazNm3/Z91->Z91_PORDM2 * Z91->Z91_PERVAZ,0),TAMSX3("Z91_CONSUM")[2])

		Z91->(MsUnlock())

		(_cAlias)->(DbSkip())
	EndDo

Static Function BgvVazNm3( vfVazaom3, vfPresTr, vfTempTr, vfFatCor, vfRecur, vfDensid, vfDtRef )

	RI008 := " WITH CONDIC1BR AS (SELECT '1' REF, Z90_CONDIC COD001 "
	RI008 += "                      FROM " + RetSqlName("Z90") + " (NOLOCK) "
	RI008 += "                     WHERE Z90_FILIAL = '" + xFilial("Z90") + "' "
	RI008 += "                       AND Z90_CODIGO = '000001' "
	RI008 += "                       AND '" + vfDtRef + "' >= Z90_DTDE "
	RI008 += "                       AND '" + vfDtRef + "' <= Z90_DTATE "
	RI008 += "                       AND D_E_L_E_T_ = ' '), "
	RI008 += "      CONDIC2BR AS (SELECT '1' REF, Z90_CONDIC COD002 "
	RI008 += "                      FROM " + RetSqlName("Z90") + " (NOLOCK) "
	RI008 += "                     WHERE Z90_FILIAL = '" + xFilial("Z90") + "' "
	RI008 += "                       AND Z90_CODIGO = '000002' "
	RI008 += "                       AND '" + vfDtRef + "' >= Z90_DTDE "
	RI008 += "                       AND '" + vfDtRef + "' <= Z90_DTATE "
	RI008 += "                       AND D_E_L_E_T_ = ' '), "
	RI008 += "      CONDIC3BR AS (SELECT '1' REF, Z90_CONDIC COD003 "
	RI008 += "                      FROM " + RetSqlName("Z90") + " (NOLOCK) "
	RI008 += "                     WHERE Z90_FILIAL = '" + xFilial("Z90") + "' "
	RI008 += "                       AND Z90_CODIGO = '000003' "
	RI008 += "                       AND '" + vfDtRef + "' >= Z90_DTDE "
	RI008 += "                       AND '" + vfDtRef + "' <= Z90_DTATE "
	RI008 += "                       AND D_E_L_E_T_ = ' ') "
	RI008 += " SELECT COD001, COD002, COD003 "
	RI008 += "   FROM CONDIC1BR C1B "
	RI008 += "   JOIN CONDIC2BR C2B ON C2B.REF = C1B.REF "
	RI008 += "   JOIN CONDIC3BR C3B ON C3B.REF = C1B.REF  "
	RIcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RI008),'RI08',.F.,.T.)
	dbSelectArea("RI08")
	dbGoTop()
	vfCod001 := RI08->COD001
	vfCod002 := RI08->COD002
	vfCod003 := RI08->COD003
	RI08->(dbCloseArea())
	Ferase(RIcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(RIcIndex+OrdBagExt())          //indice gerado

	lzVazNm3 := 0
	If vfPresTr <> 0 .and. vfTempTr <> 0 .and. vfFatCor <> 0

		lzVazNm3 := ( ( ( vfCod001 + (vfPresTr / 1000 * vfCod003) ) * vfVazaom3 * (273 + vfCod002) ) / ( (273 + vfTempTr) * vfCod001 ) ) * vfFatCor

	ElseIf vfPresTr = 0 .and. vfTempTr = 0

		lzVazNm3 := vfVazaom3 * vfFatCor

	EndIf

	If Alltrim(vfRecur) == 'ATM090'
		lzVazNm3	:= vfVazaom3 / vfDensid * vfFatCor
	EndIf

Return ( lzVazNm3 )

Static Function fCalcMeta(_cData)

	Local _cAliasD	:=	GetNextAlias()
	Local _cAliasM	
	Local _nMeta	:=	0
	Local _nMetaTn	:=	0

	BeginSql Alias _cAliasD
	
		SELECT  *
		FROM    %TABLE:Z91% Z91
		WHERE   Z91_FILIAL = %XFILIAL:Z91%
		AND Z91_DATA = %Exp:_cData%
		AND Z91.%NotDel%
		AND ( Z91_FORMAT <> ''
		OR Z91_RECURS IN ( 'ATM090', 'ATM140' )
		)
		ORDER BY Z91_DATA
	
	EndSql

	While (_cAliasD)->(!EOF())
	
		_cAliasM	:=	GetNextAlias()
		
		BeginSql Alias _cAliasM
		
			SELECT ISNULL(Z88_META,0) Z88_META, ISNULL(Z88_METATN,0) Z88_METATN
				FROM %TABLE:Z88% Z88
				WHERE Z88_FILIAL = %XFILIAL:Z88%
					AND Z88_FORMAT = %Exp:(_cAliasD)->Z91_FORMAT%
					AND Z88_RECURS = %Exp:(_cALiasD)->Z91_RECURS%
					AND %Exp:_cData% BETWEEN Z88_DTDE AND Z88_DTATE
					AND %NotDel%
		
		EndSql
	
		_nMeta		:=	(_cAliasM)->Z88_META
		_nMetaTn	:=	(_cAliasM)->Z88_METATN
	
		(_cAliasM)->(DbCloseArea())
	
		Z91->(DbGoTo((_cAliasD)->R_E_C_N_O_))
		
		Reclock("Z91",.F.)
		Z91->Z91_META	:=	_nMeta
		Z91->Z91_METATN	:=	_nMetaTn
		Z91->(MsUnlock())
	
		(_cAliasD)->(DbSkip())
	EndDo


	(_cAliasD)->(DbCloseArea())

Return

Static Function fCalcPci(_cData)


	Local _cAliasD	:=	GetNextAlias()
	Local vfkCalm2
	Local vfKgm2
	Local vfkCalkg
	
	
	BeginSql Alias _cAliasD
	
		SELECT  *
		FROM    %TABLE:Z91% Z91
		WHERE   Z91_FILIAL = %XFILIAL:Z91%
		AND Z91_DATA = %Exp:_cData%
		AND Z91.%NotDel%
		AND  Z91_FORMAT <> ''
		ORDER BY Z91_DATA
	
	EndSql

	While (_cAliasD)->(!EOF())
			vfkCalm2 := (_cAliasD)->Z91_CONSUM * (_cAliasD)->Z91_PCI
			vfKgm2   := fCalcPeso((_cAliasD)->Z91_FORMAT,_cData)  
			vfkCalkg := 0
			If vfKgm2 <> 0   
				vfkCalkg := vfkCalm2 / vfKgm2
			EndIf     
			Z91->(DbGoTo((_cAliasD)->R_E_C_N_O_))
			Reclock("Z91",.F.)
			Z91->Z91_PESO	:=	vfKgm2
			Z91->Z91_KCALM2	:=	vfkCalm2
			Z91->Z91_KCALKG	:=	vfkCalkg
			Z91->(MsUnlock())
		(_cAliasD)->(DbSkip())
	EndDo

Return

Static Function fCalcPeso(_cFormat,vfDtRef)

Local 	_nPeso	:=	0
Local	_cAlias
Local	_aLotes	:=	{}
Local 	_cProdut	:=	""
Local 	_nTotal	:=	0
Local 	_nLotes	:=	0
Local	_nPesoPad	:=	0
Local	_ntotGer	:=	0
Local	_nI

	If !Empty(_cFormat)
		_cAlias	:=	GetNextAlias()
	
		BeginSql Alias _cAlias
			%NoParser%
			WITH Z75
			AS (
				SELECT Z75_PRODUT
					,SUM(Z75_QUANT) Z75_QUANT
				FROM %TABLE:Z75% Z75
				INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = ''
					AND B1_COD = Z75_PRODUT
					AND B1_YFORMAT = %Exp:_cFormat%
					AND SB1.D_E_L_E_T_ = ''
				WHERE Z75_FILIAL = %XFILIAL:Z75%
					AND Z75_DATARF = %Exp:vfDtRef%
					AND Z75_TPMOV IN (
						'ETQ'
						,'RET'
						)
					AND Z75_TPPROD <> 'PP'
					AND Z75.%NotDel%
				GROUP BY Z75_PRODUT
					,SB1.B1_YFORMAT
					,SB1.B1_TIPO
				)
			SELECT Z75_PRODUT
				,ISNULL(D3_LOTECTL, '') LOTE
				,ISNULL(SUM(D3_QUANT), 0) QUANT
				,Z75_QUANT
				,ZZ9_PESO
			FROM Z75
			LEFT JOIN %TABLE:SD3% SD3 ON Z75.Z75_PRODUT = SD3.D3_COD
				AND D3_EMISSAO = %Exp:vfDtRef%
				AND SD3.D3_ESTORNO <> 'S'
				AND SD3.%NotDel%
				AND D3_TM = '010'
			LEFT JOIN %TABLE:ZZ9% ZZ9 ON ZZ9.ZZ9_FILIAL = %XFILIAL:ZZ9%
				AND ZZ9.ZZ9_LOTE = SD3.D3_LOTECTL
				AND ZZ9.ZZ9_PRODUT = SD3.D3_COD
				AND ZZ9.%NotDel%
			GROUP BY Z75_PRODUT
				,D3_LOTECTL
				,Z75_QUANT
				,ZZ9_PESO
			ORDER BY Z75_PRODUT			
		EndSql
			
		If (_cAlias)->(!EOF())
		
			_cProdut	:=	(_cAlias)->Z75_PRODUT	
			_ntotal		:=	(_cAlias)->Z75_QUANT
			_nLotes		:=	0
			_nPesoPad	:=	POSICIONE("SB1",1,xFilial("SB1")+_cProdut,"B1_PESO")
			While (_cAlias)->(!EOF())	
				
				If  _cProdut	<>	(_cAlias)->Z75_PRODUT 
					
					If _nTotal <> _nLotes
					
						aAdd(_aLotes,{;
							_cProdut,;
							_ntotal,;
							_nPesoPad,;
							"",;
							_ntotal - _nLotes;
						})
					
					EndIf
					_ntotGer	+=	_nTotal
					_cProdut	:=	(_cAlias)->Z75_PRODUT	
					_nPesoPad	:=	POSICIONE("SB1",1,xFilial("SB1")+_cProdut,"B1_PESO")
					_ntotal		:=	(_cAlias)->Z75_QUANT
					_nLotes		:=	0					
				
				EndIf
					
					(_cAlias)->(aAdd(_aLotes,{;
						(_cAlias)->Z75_PRODUT,;
						(_cAlias)->Z75_QUANT,;
						Iif((_cAlias)->ZZ9_PESO == 0, _nPesoPad, (_cAlias)->ZZ9_PESO),;
						(_cAlias)->LOTE,;
						(_cAlias)->QUANT;
					}))
				
					_nLotes	+=	(_cAlias)->QUANT
				
				(_cAlias)->(DbSkip())	
			EndDo

			_ntotGer	+=	_ntotal

			If _nTotal <> _nLotes
			
				aAdd(_aLotes,{;
					_cProdut,;
					_ntotal,;
					POSICIONE("SB1",1,xFilial("SB1")+_cProdut,"B1_PESO"),;
					"",;
					_ntotal - _nLotes;
				})
			
			EndIf

			For _nI	:=	1 to Len(_aLotes)
			
				_nPeso += _aLotes[_nI,3] * _aLotes[_nI,5]
			
			Next
		
			_nPeso	:=	_nPeso/_nTotGer

		Else
			(_cAlias)->(DbCloseArea())
			_cAlias	:=	GetNextAlias()
			
			BeginSql Alias _cAlias
				SELECT ISNULL(AVG(B1_PESO),0) PESO
				FROM %TABLE:SB1%
				WHERE B1_YFORMAT = %Exp:_cFormat%
					AND B1_YCLASSE = '1'
					AND B1_TIPO = 'PA'
					AND B1_YSTATUS = '1'
					AND %NotDel%
			EndSql

			_nPeso	:=	(_cAlias)->PESO
		
		endIf
		
		(_cAlias)->(DbCloseArea())
	ENDIF		
	
	
Return _nPeso

Static Function fWfPeso(_cDtRef)

	Local _cAlias	:=	GetNextAlias()
	Local _cHtml	:=	""
	Local df_Dest := U_EmailWF('INDCONTROLEPERDA', cEmpAnt)
	Local df_Assu := "Workflow de Controle de Cadastro de Perda por Formato"
	Local df_Erro := df_Assu + " não enviado. Favor verificar!!!"

	BeginSql Alias _cAlias
		%NoParser%
		WITH PORCELANATO
		AS (
			SELECT B1_COD PRODUT
				,B1_YFORMAT FORMATO
			FROM %TABLE:SB1% (NOLOCK)
			WHERE B1_FILIAL = %XFILIAL:SB1%
				AND B1_YSTATUS = '1'
				AND B1_TIPO = 'PP'
				AND B1_YCLASSE = ' '
				AND B1_YTPPROD <> 'RP'
				AND %NotDel%
			)
		SELECT DISTINCT FORMATO
			,PRODUT
			,D3_COD
		FROM (
			SELECT PRODUT
				,FORMATO
				,D3M.D3_COD
				,D3M.D3_QUANT QTDM
				,SD3.D3_QUANT QTDPRD
				,ISNULL(ZRX.ZRX_PERDA, 0) PERDA
			FROM PORCELANATO PRC
			INNER JOIN %TABLE:SD3% SD3 (NOLOCK) ON SD3.D3_FILIAL = %XFILIAL:SD3%
				AND SD3.D3_COD = PRODUT
				AND SD3.D3_TM = '010'
				AND SD3.D3_ESTORNO <> 'S'
				AND SD3.%NotDel%
				AND SD3.D3_EMISSAO = %Exp:_cDtRef%
			INNER JOIN %TABLE:SD3% D3M (NOLOCK) ON SD3.D3_FILIAL = D3M.D3_FILIAL
				AND SD3.D3_NUMSEQ = D3M.D3_NUMSEQ
			INNER JOIN %TABLE:SB1% B1FIL (NOLOCK) ON B1FIL.B1_FILIAL = %XFILIAL:SB1%
				AND B1FIL.B1_COD = D3M.D3_COD
				AND B1FIL.B1_GRUPO = 'PI01'
				AND B1FIL.%NotDel%
			LEFT JOIN %TABLE:ZRX% ZRX ON ZRX.ZRX_FORMAT = FORMATO
				AND SD3.D3_EMISSAO BETWEEN ZRX.ZRX_INI
					AND ZRX.ZRX_FIM
				AND ZRX.%NotDel%
			) A		
			WHERE A.PERDA = 0	
	EndSql
	
	If (_cAlias)->(!EOF())
		_cHtml	:=	'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">	'
		_cHtml	+=	'<html xmlns="http://www.w3.org/1999/xhtml">                                                                                '
		_cHtml	+=	'<head>                                                                                                                     '
		_cHtml	+=	'    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />                                                  '
		_cHtml	+=	'    <title>Untitled Document</title>                                                                                       '
		_cHtml	+=	'    <style type="text/css">                                                                                                '
		_cHtml 	+= '			<!--
		_cHtml 	+= '			.headClass {background-color: #D3D3D3;	color: #747474;	font: 12px Arial, Helvetica, sans-serif}
		_cHtml 	+= '			.headProd {background: #0c2c65;	color: #FFF; font: 12px Arial, Helvetica, sans-serif}
		_cHtml 	+= '			.headTexto {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif; font-weight: Bold;}
		_cHtml 	+= '			.headTexto1 {color: #1f3d71; font: 16px Arial, Helvetica, sans-serif}
		_cHtml 	+= '			.style12  {background: #f6f6f6;	color: #747474;	font: 11px Arial, Helvetica, sans-serif}
		_cHtml 	+= '			.style123 {font face="Arial"; font-size: 12px; background: #f6f6f6;}
		_cHtml 	+= '			.cabtab {background: #eff4ff;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif}
		_cHtml 	+= '			.cabtab1 {background: #eff4ff;	border-top: 2px solid #FFF; border-right: 1px solid #ced9ec;	color: #1f3d71; font: 12px Arial, Helvetica, sans-serif }
		_cHtml 	+= '			.tottab {border:1px solid #0c2c65; background-color: #D3D3D3;	color: #0c2c65;	font: 12px Arial, Helvetica, sans-serif }
		_cHtml 	+= '			-->
		_cHtml	+=	'    </style>                                                                                                               '
		_cHtml	+=	'</head>                                                                                                                    '
		_cHtml	+=	'<body>                                                                                                                     '
		_cHtml	+=	'    <p align="center"> Listagem de formatos sem perda cadastrada para o dia '+ DtoC(Stod(_cDtRef)) +' </p>                                                              '
		_cHtml 	+= 	'         <table align="center" width="100%" border="1" cellspacing="0" cellpadding="1">'
		_cHtml	+=	'        <tr>                                                                                                               '
		_cHtml	+=	'            <th class = "cabtab" scope="col"> Formato				 </th>        '
		_cHtml	+=	'            <th class = "cabtab" scope="col"> PP	 </th>        '
		_cHtml	+=	'            <th class = "cabtab" scope="col"> Massa			 </th>        '
		_cHtml	+=	'        </tr>																												'																												'
		
		While (_cAlias)->(!EOF())
			_cHtml	+=	'<tr>																												'
			_cHtml	+=	'	<td><div align="center">'+	Alltrim((_cAlias)->FORMATO)							+ '</div></td>'
			_cHtml	+=	'	<td><div align="center">'+	Alltrim((_cAlias)->PRODUT)							+ '</div></td>'
			_cHtml	+=	'	<td><div align="center">'+	Alltrim((_cAlias)->D3_COD)							+ '</div></td>'
			_cHtml	+=	'</tr>
		
			(_cAlias)->(DbSkip())
		EndDo
		_cHtml	+=	'	 </table>                                                                                                                     '
		_cHtml	+=	'	<p>by BIAFG026</p> '
		_cHtml	+=	'	</body>                                                                                                                       '
		_cHtml	+=	'	</html>
		
		U_BIAEnvMail(, df_Dest, df_Assu, _cHtml, df_Erro)
		
	EndIf

Return


User Function BFG026PR()

RpcSetType(3)
RpcSetEnv('01','01')

fWfPeso('20200401')
//U_BIAFG026("20201019")


RpcClearEnv()

Return

