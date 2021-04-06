#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} MT250SAL
@author Marcos Alberto Soprani
@since 11/07/18
@version 1.0
@description  O ponto de entrada MT250SAl é executado no final da função A250TudoOk()
.            que é responsável por validar as informações digitadas no apontamento de
.            produção. Com este ponto de entrada o usuário poderá manipular os valores
.            de saldos dos produtos a serem requisitados pelo apontamento em questão.
.             Inicialmente utilizada para corrigir a posição 4 do vetor, que por algum,
.            desconhecido, retorna sempre igual à quantidade a ser baixada, porém nega-
.            tiva. Pelas avaliações esta posição corresponde ao saldo por lote. Sendo
.            assim, eu corrijo o valor da posição com o valor da posição 2
@type function
/*/

User Function MT250SAL()

	Local zpt
	Local aSaldos := ParamIxb[1]
	Local mmjArea := GetArea()
	Local _dMesAnt
	Local _cDtIni
	Local _cDtFim
	Local _cAlias	:=	GetNextAlias()

	Local _nPerUmid	:=	0
	Local _nQtdAdic	:=	0
	Local _npos		:=	0

	Local _cTeste	:=	""

	If GetMV('MV_RASTRO') == "S"

		For zpt := 1 To Len(aSaldos)

			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1") + aSaldos[zpt][1]) )
			If SB1->B1_RASTRO == "L"

				MS004 := " WITH BAIXAPA AS (SELECT D4_COD, D4_LOCAL, D4_LOTECTL, D4_QTDEORI / C2_QUANT * " + Alltrim(Str(M->D3_QUANT)) + " QTDBX "
				MS004 += "                    FROM " + RetSqlName("SD4") + " SD4 "
				MS004 += "                   INNER JOIN " + RetSqlName("SC2") + " SC2 ON C2_NUM = SUBSTRING(D4_OP,1,6) "
				MS004 += "                                        AND C2_ITEM = SUBSTRING(D4_OP,7,2) "
				MS004 += "                                        AND C2_SEQUEN = SUBSTRING(D4_OP,9,3) "
				MS004 += "                                        AND SC2.D_E_L_E_T_ = ' ' "
				MS004 += "                   WHERE D4_OP = '" + M->D3_OP +  "' "
				MS004 += "                     AND D4_COD = '" + aSaldos[zpt][1] + "' "
				MS004 += "                     AND D4_LOCAL = '" + aSaldos[zpt][2] + "' "
				MS004 += "                     AND D4_LOTECTL = '" + aSaldos[zpt][7] + "' "
				MS004 += "                     AND SD4.D_E_L_E_T_ = ' ') "
				MS004 += " SELECT B8_SALDO - QTDBX SLOTE "
				MS004 += "   FROM BAIXAPA BXPA "
				MS004 += "  INNER JOIN " + RetSqlName("SB8") + " SB8 ON B8_PRODUTO = D4_COD "
				MS004 += "    AND B8_LOCAL = D4_LOCAL "
				MS004 += "    AND B8_LOTECTL = D4_LOTECTL "
				MS004 += "    AND D_E_L_E_T_ = ' ' "
				MSIndex := CriaTrab(Nil,.f.)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,MS004),'MS04',.T.,.T.)
				dbSelectArea("MS04")
				dbGoTop()
				mmSalLot := MS04->SLOTE
				MS04->(dbCloseArea())
				Ferase(MSIndex+GetDBExtension())
				Ferase(MSIndex+OrdBagExt())

				aSaldos[zpt][4] := mmSalLot

				SBZ->(dbSetOrder(1))
				SBZ->(dbSeek(xFilial("SBZ") + aSaldos[zpt][1]) )
				If SBZ->BZ_LOCALIZ == "S"

					MX005 := " WITH BAIXAPA AS (SELECT D4_COD, D4_LOCAL, D4_LOTECTL, D4_QTDEORI / C2_QUANT * " + Alltrim(Str(M->D3_QUANT)) + " QTDBX "
					MX005 += "                    FROM " + RetSqlName("SD4") + " SD4 "
					MX005 += "                   INNER JOIN " + RetSqlName("SC2") + " SC2 ON C2_NUM = SUBSTRING(D4_OP,1,6) "
					MX005 += "                                        AND C2_ITEM = SUBSTRING(D4_OP,7,2) "
					MX005 += "                                        AND C2_SEQUEN = SUBSTRING(D4_OP,9,3) "
					MX005 += "                                        AND SC2.D_E_L_E_T_ = ' ' "
					MX005 += "                   WHERE D4_OP = '" + M->D3_OP +  "' "
					MX005 += "                     AND D4_COD = '" + aSaldos[zpt][1] + "' "
					MX005 += "                     AND D4_LOCAL = '" + aSaldos[zpt][2] + "' "
					MX005 += "                     AND D4_LOTECTL = '" + aSaldos[zpt][7] + "' "
					MX005 += "                     AND SD4.D_E_L_E_T_ = ' ') "
					MX005 += " SELECT BF_QUANT - QTDBX SENDE "
					MX005 += "   FROM BAIXAPA BXPA "
					MX005 += "  INNER JOIN " + RetSqlName("SBF") + " SBF ON BF_PRODUTO = D4_COD "
					MX005 += "    AND BF_LOCAL = D4_LOCAL "
					MX005 += "    AND BF_LOTECTL = D4_LOTECTL "
					MX005 += "    AND D_E_L_E_T_ = ' ' "
					MXIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,MX005),'MX05',.T.,.T.)
					dbSelectArea("MX05")
					dbGoTop()
					mmSalEnd := MX05->SENDE
					MX05->(dbCloseArea())
					Ferase(MXIndex+GetDBExtension())
					Ferase(MXIndex+OrdBagExt())

					aSaldos[zpt][5] := mmSalEnd

				EndIf

				//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				//| Tratamento implementado em 08/04/19 por Marcos Alberto Soprani para tentar resolver  |
				//|  problema de saldo de estoque negativo do produto C1 que vive dando erro             |
				//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
				If Substr(aSaldos[zpt][1], 1, 2) == "C1" .and. 1 == 2

					MI009 := " WITH BAIXAPA AS (SELECT D4_COD, D4_LOCAL, D4_LOTECTL, D4_QTDEORI / C2_QUANT * " + Alltrim(Str(M->D3_QUANT)) + " QTDBX "
					MI009 += "                    FROM " + RetSqlName("SD4") + " SD4 "
					MI009 += "                   INNER JOIN " + RetSqlName("SC2") + " SC2 ON C2_NUM = SUBSTRING(D4_OP,1,6) "
					MI009 += "                                        AND C2_ITEM = SUBSTRING(D4_OP,7,2) "
					MI009 += "                                        AND C2_SEQUEN = SUBSTRING(D4_OP,9,3) "
					MI009 += "                                        AND SC2.D_E_L_E_T_ = ' ' "
					MI009 += "                   WHERE D4_OP = '" + M->D3_OP +  "' "
					MI009 += "                     AND D4_COD = '" + aSaldos[zpt][1] + "' "
					MI009 += "                     AND D4_LOCAL = '" + aSaldos[zpt][2] + "' "
					MI009 += "                     AND SD4.D_E_L_E_T_ = ' ') "
					MI009 += " SELECT QTDBX SALEST "
					MI009 += "   FROM BAIXAPA BXPA "
					MIIndex := CriaTrab(Nil,.f.)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,MI009),'MI09',.T.,.T.)
					dbSelectArea("MI09")
					dbGoTop()
					mmSalEst := MI09->SALEST
					MI09->(dbCloseArea())
					Ferase(MIIndex+GetDBExtension())
					Ferase(MIIndex+OrdBagExt())

					_mSaldos	:=	CalcEst( aSaldos[zpt][1], aSaldos[zpt][2], DaySum(Date(),1) )
					aSaldos[zpt][3] := _mSaldos[1] - mmSalEst

				EndIf

			EndIf

			//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			//| Tratamento implementado em 19/01/15 por Marcos Alberto Soprani para resolver         |
			//|  problema de arredondamento durante apontamento de produção de PA com consumo de PP  |
			//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			If SB1->B1_TIPO == "PP"
				aSaldos[zpt][3]  := Round(aSaldos[zpt][3],2)
			EndIf

		Next zpt

	EndIf

	If cEmpAnt <> "06"

		dbSelectArea("SB1")
		SB1->(DbSetOrder(1))

		If SB1->(DbSeek(xFilial("SB1")+M->D3_COD))	.And. SB1->B1_TIPO = 'PI' .And. SB1->B1_GRUPO == 'PI01'

			_dMesAnt	:=	stod(Substr(dtos(dDataBase),1,6)+"01")-1
			_cDtIni		:=	Substr(dtos(_dMesAnt),1,6) + "01"
			_cDtFim		:=	dtos(Ultimodia(_dMesAnt))	

			If SB1->B1_GRUPO = 'PI01'	//MASSA
				BeginSql Alias _cAlias
					SELECT D4_COD, 
					D4_OP, 
					D4_LOCAL, 
					C2_QUANT,
					%Exp:M->D3_QUANT% D3_QUANT,
					ISNULL((SELECT SUM(Z02_UMIDAD * Z02_QTDCRG) / SUM(Z02_QTDCRG)
					FROM %TABLE:Z02%
					WHERE Z02_FILIAL = %XFILIAL:Z02%
					AND Z02_DATREF BETWEEN %Exp:_cDtIni% AND %Exp:_cDtFim%
					AND Z02_PRODUT = D4_COD
					AND Z02_QTDCRG <> 0
					AND Z02_ORGCLT = '2'
					AND %NotDel%), 0) UMIDADE,
					ISNULL((SELECT BZ_YUMIDAD
					FROM %TABLE:SBZ%
					WHERE BZ_FILIAL = ''
					AND BZ_COD = D4_COD
					AND %NotDel%), 0) UMIDAD2,
					D4_TRT,
					D4_QTDEORI
					FROM %TABLE:SD4% SD4
					INNER JOIN %TABLE:SC2% SC2 ON C2_FILIAL = %XFILIAL:SC2%
					AND C2_NUM + C2_ITEM + C2_SEQUEN + '  ' = D4_OP
					AND SC2.D_E_L_E_T_ = ' '
					WHERE D4_FILIAL = %XFILIAL:SD4%
					AND D4_OP = %Exp:M->D3_OP%
					AND SD4.%NotDel%

				EndSql

			EndIf

			While (_cAlias)->(!EOF())

				_nPerUmid	:=	Iif((_cAlias)->UMIDADE == 0,(_cAlias)->UMIDAD2,(_cAlias)->UMIDADE)

				_nQtdCalc	:=	(_cAlias)->D3_QUANT / (_cAlias)->C2_QUANT * (_cAlias)->D4_QTDEORI

				_nQtdAdic	:=	Round((_nQtdCalc / ((100-_nPerUmid)/100)) - _nQtdCalc, 2)

				If (_nPos	:=	aScan(aSaldos,{|x| Alltrim(x[1]) == Alltrim((_cAlias)->D4_COD)})) > 0

					aSaldos[_nPos,3]	-=	_nQtdAdic

					_cTeste	+=	(_cAlias)->D4_COD + '-' + Str(_nQtdAdic) + CRLF

				EndIf

				(_cAlias)->(DbSkip())

			EndDo

			(_cAlias)->(DbCloseArea())

		EndIf

	Else 

		// Todos este tratamento foi implementado em 29/03/21, trazendo a PI01 os scripts originais

		dbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1") + M->D3_COD))

		If SB1->B1_TIPO = 'PI' .And. SB1->B1_GRUPO == '108B'

			_dMesAnt	:=	dDataBase
			_cDtIni		:=	dtos(_dMesAnt)
			_cDtFim		:=	dtos(_dMesAnt)	

			BeginSql Alias _cAlias
				SELECT D4_COD, 
				D4_OP, 
				D4_LOCAL, 
				C2_QUANT,
				%Exp:M->D3_QUANT% D3_QUANT,
				ISNULL((SELECT SUM(Z02_UMIDAD * Z02_QTDCRG) / SUM(Z02_QTDCRG)
				FROM %TABLE:Z02%
				WHERE Z02_FILIAL = %XFILIAL:Z02%
				AND Z02_DATREF BETWEEN %Exp:_cDtIni% AND %Exp:_cDtFim%
				AND Z02_PRODUT = D4_COD
				AND Z02_QTDCRG <> 0
				AND Z02_ORGCLT = '2'
				AND %NotDel%), 0) UMIDADE,
				ISNULL((SELECT BZ_YUMIDAD
				FROM %TABLE:SBZ%
				WHERE BZ_FILIAL = %XFILIAL:SBZ%
				AND BZ_COD = D4_COD
				AND %NotDel%), 0) UMIDAD2,
				D4_TRT,
				D4_QTDEORI
				FROM %TABLE:SD4% SD4
				INNER JOIN %TABLE:SC2% SC2 ON C2_FILIAL = %XFILIAL:SC2%
				AND C2_NUM + C2_ITEM + C2_SEQUEN + '  ' = D4_OP
				AND SC2.D_E_L_E_T_ = ' '
				WHERE D4_FILIAL = %XFILIAL:SD4%
				AND D4_OP = %Exp:M->D3_OP%
				AND SD4.%NotDel%

			EndSql

			While (_cAlias)->(!EOF())

				_nPerUmid	:=	Iif((_cAlias)->UMIDADE == 0,(_cAlias)->UMIDAD2,(_cAlias)->UMIDADE)

				_nQtdCalc	:=	(_cAlias)->D3_QUANT / (_cAlias)->C2_QUANT * (_cAlias)->D4_QTDEORI

				_nQtdAdic	:=	Round((_nQtdCalc / ((100-_nPerUmid)/100)) - _nQtdCalc, 2)

				If (_nPos	:=	aScan(aSaldos,{|x| Alltrim(x[1]) == Alltrim((_cAlias)->D4_COD)})) > 0

					aSaldos[_nPos,3]	-=	_nQtdAdic

					_cTeste	+=	(_cAlias)->D4_COD + '-' + Str(_nQtdAdic) + CRLF

				EndIf

				(_cAlias)->(DbSkip())
				
			EndDo

			(_cAlias)->(DbCloseArea())

		EndIf

	EndIf

	RestArea(mmjArea)

Return(aSaldos)
