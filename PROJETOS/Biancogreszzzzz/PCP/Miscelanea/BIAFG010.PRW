#include 'protheus.ch'

/*/{Protheus.doc} BIAFG010
@author Gabriel Rossi Mafioletti
@since 19/06/17
@version 1.0
@description Função para geração da tabela de Pseudo Apontamento
@type function
/*/

User Function BIAFG010()

	Local nHandle

	cHInicio := Time()
	fPerg := "BIAFG010"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf
	If !U_VALOPER("049",.F.)

		If ( MV_PAR01 <= GetMV("MV_YULRAC") .or. MV_PAR02 <= GetMV("MV_YULRAC") )
			MsgSTOP("Favor verificar o intervalo de datas informado, pois está fora do período de fechamento de estoque.", "OP 049 - Data de Fechamento!!!")
			Return
		EndIf

	EndIf

	nHandle := fCreate('BIAFG010.$$$')

	If(nHandle == -1)

		MsgInfo("Processo sendo executado por outro usuário!","BIAFG010")
		Return

	Endif 

	Processa({|| fProces()})

	fClose(nHandle)

	MsgINFO("Fim do Processamento...")

Return

Static Function fProces()

	Local _cAliasSD3	:= GetNextAlias()	//Alias Referente ao SD3
	Local _cAliasSGG	:= Nil				//Alias Referente ao SGG
	Local _cAliasFAN	:= Nil				//Alias Referente ao Produto Fantasma
	Local _cAliasZ97	:= Nil
	Local _cCodPai		:= ""
	Local _lFantPai		:= .F.
	Local _nTotPai		:= 0
	Local _lSkip		:= .F.
	Local _cDoc			:= fNextDoc()
	Local _cRec			:= fNextReg()
	Local _nUmid		:= 0
	Local _nQtdUmid		:= 0
	Local _cQuery		:= "" 
	Local _nI

	Local _nPercDil		:= 0
	Local _nQtdDil		:= 0
	Local _aFants		:=	{}

	Private _cDataDe    := MV_PAR01
	Private _cDataAte   := UltimoDia(MV_PAR02)

	_cQuery := " DELETE FROM " + RetSqlName("Z97") + " "
	_cQuery += "  WHERE Z97_FILIAL = " + ValtoSql(xFilial("Z97")) + " "
	_cQuery += "    AND Z97_ORITAB = 'SGG' "
	_cQuery += "    AND Z97_EMISSA BETWEEN " + ValtoSql(_cDataDe) + " AND " + ValtoSql(_cDataAte)
	_cQuery += "    AND D_E_L_E_T_ = ' ' "
	tcSqlExec(_cQuery)

	fQrySD3(_cAliasSD3)

	If (_cAliasSD3)->(!EOF())

		ProcRegua(0)

		While (_cAliasSD3)->(!EOF())

			_cAliasSGG	:=	GetNextAlias()

			fQrySGG(_cAliasSGG, (_cAliasSD3)->D3_COD )

			_cCodPai		:=	""
			_lFantPai		:=	.F.
			_nTotPai		:=	0
			While (_cAliasSGG)->(!EOF())

				IncProc("Processando... " + _cCodPai)

				If !fVerPrPaI((_cAliasSGG)->IDPAI)

					If _cCodPai	<> (_cAliasSGG)->IDPAI

						If !Empty(_cCodPai) 

							If !fVerPrPaI(_cCodPai) .And. !(_lFantPai) //Verifica Se já não existe um produto Pai com TM 010. Se já existir, Não Produzir

								//Insere a Produção(TM 010 e CF PR0) para o Produto Pai
								Reclock("Z97",.T.)
								Z97->Z97_FILIAL	:=	xFilial("Z97")	
								Z97->Z97_ORITAB	:=	"SGG"	
								Z97->Z97_TM		:=	"010"
								Z97->Z97_CF		:=	"PR0"
								Z97->Z97_COD	:=	_cCodPai
								Z97->Z97_CONTA	:=	Posicione("SB1",1,xFilial("SB1")+Z97->Z97_COD,"B1_YCTRIND")
								Z97->Z97_QUANT	:=	1
								Z97->Z97_DOC	:=	_cDoc
								Z97->Z97_EMISSA	:=	_cDataAte
								Z97->Z97_CUSTO1	:=	_nTotPai
								Z97->Z97_OP		:=	""
								Z97->Z97_SEQREG	:=	_cRec	
								Z97->Z97_USER	:=	cUsername
								Z97->Z97_TRT	:=	""
								Z97->(MsUnLock())

								fGeraBD()


							EndIf

							_cDoc		:=	fNextDoc()
							_cRec		:=	fNextReg()
							_nTotPai	:=	0

						EndIf

						_cCodPai	:=	(_cAliasSGG)->IDPAI
						_lFantPai	:=	((_cAliasSGG)->FANTPAI == "S")
						_nPercDil	:=	fPercDil((_cAliasSGG)->IDPAI)

					EndIf

					If _lFantPai
						(_cAliasSGG)->(DbSkip())
						Loop
					EndIf

					If (_cAliasSGG)->FANTFIL	==	'S'

						_cAliasFan	:=	GetNextAlias()
						MSIndex := CriaTrab(Nil,.f.)
						_aFants	:=	fQryFan(_cAliasFan,(_cAliasSGG)->ID)
						If (_cAliasFan)->(!EOF())
							For _nI	:= 1 to Len(_aFants)

								//Para cada Item Filho do Fantasma insere uma Requisição RE1

								_nUmid	:=	fCalcUmid(_aFants[_nI,1])
								If _nPercDil > 0
									_nQtdDil	:= (((_cAliasSGG)->MISTURA / _nPercDil) * 100) * (_cAliasSGG)->QUANTBX / (_cAliasSGG)->MISTURA
									_nQtdUmid := _nQtdDil/(-(((_nUmid/100)/1)-1))
								Else
									_nQtdUmid := _aFants[_nI,2] * (_cAliasSGG)->QUANTBX/(-(((_nUmid/100)/1)-1))
								EndIf


								Reclock("Z97",.T.)
								Z97->Z97_FILIAL	:=	xFilial("Z97")	
								Z97->Z97_ORITAB	:=	"SGG"	
								Z97->Z97_TM		:=	"999"
								Z97->Z97_CF		:=	"RE1"
								Z97->Z97_COD	:=	_aFants[_nI,1]
								Z97->Z97_CONTA	:=	Posicione("SB1",1,xFilial("SB1")+Z97->Z97_COD,"B1_YCTRIND")
								Z97->Z97_QUANT	:=	_nQtdUmid
								Z97->Z97_DOC	:=	_cDoc
								Z97->Z97_EMISSA	:=	_cDataAte
								Z97->Z97_CUSTO1	:=	_nQtdUmid * _aFants[_nI,3] 
								Z97->Z97_OP		:=	""
								Z97->Z97_SEQREG	:=	_cRec	
								Z97->Z97_USER	:=	cUsername
								Z97->Z97_TRT	:=	(_cAliasSGG)->GG_TRT
								Z97->(MsUnLock())						
								_nTotPai	+=	Z97->Z97_CUSTO1	

							Next
						Else

							_nUmid	:=	fCalcUmid((_cAliasSGG)->ID)
							If _nPercDil > 0
								_nQtdDil	:= (((_cAliasSGG)->MISTURA / _nPercDil) * 100) * (_cAliasSGG)->QUANTBX / (_cAliasSGG)->MISTURA
								_nQtdUmid := _nQtdDil/(-(((_nUmid/100)/1)-1))
							Else
								_nQtdUmid := (_cAliasSGG)->QUANTBX/(-(((_nUmid/100)/1)-1))
							EndIf

							Reclock("Z97",.T.)
							Z97->Z97_FILIAL	:=	xFilial("Z97")	
							Z97->Z97_ORITAB	:=	"SGG"	
							Z97->Z97_TM		:=	"999"
							Z97->Z97_CF		:=	"RE1"
							Z97->Z97_COD	:=	(_cAliasSGG)->ID
							Z97->Z97_CONTA	:=	Posicione("SB1",1,xFilial("SB1")+Z97->Z97_COD,"B1_YCTRIND")
							Z97->Z97_QUANT	:=	_nQtdUmid
							Z97->Z97_DOC	:=	_cDoc
							Z97->Z97_EMISSA	:=	_cDataAte
							Z97->Z97_CUSTO1	:=	(_cAliasSGG)->CUSTTOT / (_cAliasSGG)->QUANTBX * _nQtdUmid
							Z97->Z97_OP		:=	""
							Z97->Z97_SEQREG	:=	_cRec	
							Z97->Z97_USER	:=	cUsername
							Z97->Z97_TRT	:=	(_cAliasSGG)->GG_TRT
							Z97->(MsUnLock())						
							_nTotPai	+=	Z97->Z97_CUSTO1	
						EndIf

						(_cAliasFan)->(DbCloseArea())
						Ferase(MSIndex+GetDBExtension())
						Ferase(MSIndex+OrdBagExt())

					Else

						_nUmid	:=	fCalcUmid((_cAliasSGG)->ID)
						If _nPercDil > 0
							_nQtdDil	:= (((_cAliasSGG)->MISTURA / _nPercDil) * 100) * (_cAliasSGG)->QUANTBX / (_cAliasSGG)->MISTURA
							_nQtdUmid := _nQtdDil/(-(((_nUmid/100)/1)-1))
						Else
							_nQtdUmid := (_cAliasSGG)->QUANTBX/(-(((_nUmid/100)/1)-1))
						EndIf

						Reclock("Z97",.T.)
						Z97->Z97_FILIAL	:=	xFilial("Z97")	
						Z97->Z97_ORITAB	:=	"SGG"	
						Z97->Z97_TM		:=	"999"
						Z97->Z97_CF		:=	"RE1"
						Z97->Z97_COD	:=	(_cAliasSGG)->ID
						Z97->Z97_CONTA	:=	Posicione("SB1",1,xFilial("SB1")+Z97->Z97_COD,"B1_YCTRIND")
						Z97->Z97_QUANT	:=	_nQtdUmid
						Z97->Z97_DOC	:=	_cDoc
						Z97->Z97_EMISSA	:=	_cDataAte
						Z97->Z97_CUSTO1	:=	Iif((_cAliasSGG)->CUSTTOT == 0, fVerCusPr((_cAliasSGG)->ID )* _nQtdUmid,(_cAliasSGG)->CUSTTOT/(_cAliasSGG)->QUANTBX * _nQtdUmid)  
						Z97->Z97_OP		:=	""
						Z97->Z97_SEQREG	:=	_cRec	
						Z97->Z97_USER	:=	cUsername
						Z97->Z97_TRT	:=	(_cAliasSGG)->GG_TRT
						Z97->(MsUnLock())						
						_nTotPai	+=	Z97->Z97_CUSTO1					

					EndIf

				EndIf

				(_cAliasSGG)->(DbSkip())

			EndDo

			If !fVerPrPaI(_cCodPai) .And. !(_lFantPai) //Verifica Se já não existe um produto Pai com TM 010. Se já existir, Não Produzir

				//Insere a Produção(TM 010 e CF PR0) para o Produto Pai
				Reclock("Z97",.T.)
				Z97->Z97_FILIAL	:=	xFilial("Z97")	
				Z97->Z97_ORITAB	:=	"SGG"	
				Z97->Z97_TM		:=	"010"
				Z97->Z97_CF		:=	"PR0"
				Z97->Z97_COD	:=	_cCodPai
				Z97->Z97_CONTA	:=	Posicione("SB1",1,xFilial("SB1")+Z97->Z97_COD,"B1_YCTRIND")
				Z97->Z97_QUANT	:=	1
				Z97->Z97_DOC	:=	_cDoc
				Z97->Z97_EMISSA	:=	_cDataAte
				Z97->Z97_CUSTO1	:=	_nTotPai
				Z97->Z97_OP		:=	""
				Z97->Z97_SEQREG	:=	_cRec	
				Z97->Z97_USER	:=	cUsername
				Z97->Z97_TRT	:=	""
				Z97->(MsUnLock())

				fGeraBD()

				_cDoc		:=	fNextDoc()
				_cRec		:=	fNextReg()
				_nTotPai	:=	0

			EndIf

			(_cAliasSGG)->(DbCloseArea())
			(_cAliasSD3)->(DbSkip())

		Enddo

		(_cAliasSD3)->(DbCloseArea())

	Else

		Aviso('SD3', 'Não Foram Encontrados Registros para Procesamento!',{'Ok'})

	EndIf
Return

Static Function fNextReg()

	Local _cReg	:=	""
	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias
		SELECT ISNULL(MAX(Z97_SEQREG),'000000') AS SEQ
		FROM %TABLE:Z97% 
		WHERE Z97_FILIAL = %XFILIAL:Z97%
		AND %NotDel%
	EndSql

	_cReg	:=	SOMA1((_cAlias)->SEQ)

	(_cAlias)->(DbCloseArea())

Return _cReg

Static Function fNextDoc()

	Local _cDoc	:=	""
	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias
		SELECT ISNULL(MAX(Z97_DOC),'000000000') AS DOC
		FROM %TABLE:Z97% 
		WHERE Z97_FILIAL = %XFILIAL:Z97%
		AND %NotDel%
	EndSql

	_cDoc	:=	SOMA1((_cAlias)->DOC)

	(_cAlias)->(DbCloseArea())

Return _cDoc

Static Function fVerPrPaI(_cCodPai)

	Local _cAlias	:=	GetNextAlias()
	Local _lRet		:=	.F.

	BeginSql Alias _cAlias
		SELECT  ISNULL(MAX(Z97_CUSTO1),0) CUSTO, COUNT(*) QTD
		FROM    %TABLE:Z97%
		WHERE   Z97_FILIAL = %XFILIAL:Z97%
		AND Z97_EMISSA BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
		AND %NotDel%
		AND Z97_COD = %Exp:_cCodPai%
		AND Z97_TM = '010'
		AND Z97_ORITAB = 'SGG'
	EndSql

	If	(_cAlias)->QTD > 0
		_lRet	:=	.T.
	EndIF
	(_cAlias)->(DbCloseArea())
Return _lRet

Static Function fVerCusPr(_cCod)

	Local _cAlias	:=	GetNextAlias()
	Local _nCusto	:=	0


	BeginSql Alias _cAlias
		SELECT  ISNULL(MAX(Z97_CUSTO1),0) CUSTO
		FROM    %TABLE:Z97%
		WHERE   Z97_FILIAL = %XFILIAL:Z97%
		AND Z97_EMISSA BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
		AND %NotDel%
		AND Z97_COD = %Exp:_cCod%
		AND Z97_TM = '010'
		AND Z97_ORITAB = 'SGG'
	EndSql

	_nCusto	:=	(_cALias)->CUSTO
	(_cAlias)->(DbCloseArea())

Return _nCusto

Static Function fQrySD3(_cALiasSD3)

	BeginSql Alias _cAliasSD3

		SELECT DISTINCT D3_COD
		FROM (
		SELECT SUBSTRING(D3_COD,1,7) + '1       ' D3_COD
		FROM %TABLE:SD3% SD3 ( NOLOCK )
		INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
		AND B1_COD = D3_COD
		AND SB1.%NotDel%
		WHERE D3_FILIAL = %XFILIAL:SD3%
		AND D3_EMISSAO BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
		AND D3_TM = '010'
		AND B1_TIPO = 'PA'
		AND D3_ESTORNO <> 'S'
		AND SD3.%NotDel%
		UNION ALL
		SELECT D3_COD
		FROM %TABLE:SD3% SD3 ( NOLOCK )
		INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
		AND B1_COD = D3_COD
		AND SB1.%NotDel%
		WHERE D3_FILIAL = %XFILIAL:SD3%
		AND D3_EMISSAO BETWEEN %Exp:_cDataDe% AND %Exp:_cDataAte%
		AND D3_TM = '010'
		AND B1_TIPO = 'PI'
		AND D3_ESTORNO <> 'S'
		AND SD3.%NotDel%
		) PRODS
		GROUP BY D3_COD

	EndSql

Return

Static Function fQrySGG(_cAliasSGG,_cCodPro)

	BeginSql Alias _cAliasSGG
		%NoParser%
		WITH NIVEIS AS (
		SELECT SGG.GG_COMP     ID,
		SGG.GG_COD      IDPAI,
		SGG.GG_INI      DTINI,
		SGG.GG_FIM      DTFIM,
		SGG.R_E_C_N_O_  REGSGG,
		SGG.GG_YMISTUR	MISTURA,
		0           NIVEL
		FROM %TABLE:SGG% SGG (NOLOCK)
		WHERE SGG.GG_FILIAL = %XFILIAL:SGG%
		AND %Exp:_cDataAte% <= SGG.GG_INI
		AND %Exp:_cDataAte% >= SGG.GG_FIM
		AND SGG.GG_COD = %Exp:_cCodPro%
		AND SGG.%NotDel%
		UNION ALL
		SELECT T1.GG_COMP     ID,
		T1.GG_COD      IDPAI,
		T1.GG_INI      DTINI,
		T1.GG_FIM      DTFIM,
		T1.R_E_C_N_O_  REGSGG,
		T1.GG_YMISTUR MISTURA,
		NIVEL + 1      NIVEL
		FROM %TABLE:SGG% T1 (NOLOCK)
		INNER JOIN NIVEIS ON T1.GG_COD = NIVEIS.ID
		WHERE T1.GG_FILIAL = %XFILIAL:SGG%
		AND T1.GG_INI = NIVEIS.DTINI
		AND T1.GG_FIM = NIVEIS.DTFIM
		AND T1.%NotDel%
		)
		SELECT TABRD.*,
		CASE
		WHEN UNITC <> 0 THEN QUANTBX * UNITC
	END CUSTTOT
	FROM (SELECT ROW_NUMBER() OVER(ORDER BY NIV.NIVEL, NIV.IDPAI, NIV.ID, NIV.REGSGG) AS SEQ,
	IDPAI,
	ID,
	DTINI,
	DTFIM,
	REGSGG,
	NIVEL,
	GG_TRT,
	GG_QUANT,
	GG_PERDA,
	CONVERT(NUMERIC(18,8),ROUND(GG_QUANT / ( 100 - GG_PERDA ) * 100, 8)) QUANTBX,
	SBZFIL.BZ_FANTASM FANTFIL,
	SBZPAI.BZ_FANTASM FANTPAI,
	MISTURA,
	ISNULL((SELECT MAX(Z87_CUSTO1)
	FROM %TABLE:Z87% Z87
	WHERE Z87.Z87_FILIAL = %XFILIAL:Z87%
	AND Z87.Z87_DATARF = NIV.DTFIM
	AND Z87.Z87_PRODUT = NIV.ID
	AND Z87.D_E_L_E_T_ = ' '), 0) UNITC
	FROM NIVEIS NIV
	INNER JOIN %TABLE:SGG% SGG (NOLOCK) ON SGG.R_E_C_N_O_ = NIV.REGSGG
	INNER JOIN %TABLE:SB1% SB1 (NOLOCK) ON SB1.B1_FILIAL = %XFILIAL:SB1%
	AND SB1.B1_COD = NIV.ID
	AND SB1.%NotDel%
	LEFT JOIN %TABLE:SBZ% SBZFIL (NOLOCK) ON SBZFIL.BZ_FILIAL = %XFILIAL:SBZ%
	AND SBZFIL.BZ_COD = NIV.ID
	AND SBZFIL.%NotDel%
	LEFT JOIN %TABLE:SBZ% SBZPAI (NOLOCK) ON SBZPAI.BZ_FILIAL = %XFILIAL:SBZ%
	AND SBZPAI.BZ_COD = NIV.IDPAI
	AND SBZPAI.%NotDel% 
	GROUP BY IDPAI
	,ID
	,DTINI
	,DTFIM
	,REGSGG
	,NIVEL
	,GG_TRT
	,GG_QUANT
	,GG_PERDA
	,SBZFIL.BZ_FANTASM
	,SBZPAI.BZ_FANTASM
	,MISTURA
	) AS TABRD
	ORDER BY SEQ DESC			
	EndSql

Return

Static Function fQryFan(_cAliasFAN, _cID)

	Local _cSql	:=	""
	Local _aFants	:=	{}
	Local _aPais	:=	{}
	Local _nNivAtu	:=	0
	Local _nPos		:=	0


	_cSql	+=	"	WITH    NIVEIS                                                                                                  "
	_cSql	+=	"		          AS (                                                                                              "
	_cSql	+=	"		               SELECT   SGG.GG_COMP ID ,                                                                    "
	_cSql	+=	"		                        SGG.GG_COD IDPAI ,                                                                  "
	_cSql	+=	"		                        SGG.GG_INI DTINI ,                                                                  "
	_cSql	+=	"		                        SGG.GG_FIM DTFIM ,                                                                  "
	_cSql	+=	"		                        SGG.R_E_C_N_O_ REGSGG ,                                                             "
	_cSql	+=	"		                        0 NIVEL                                                                             "
	_cSql	+=	"		               FROM " + RETSQLNAME("SGG") + " SGG ( NOLOCK )                                                "
	_cSql	+=	"		               WHERE    SGG.GG_FILIAL = " + ValtoSql(xFilial("SGG")) + "                                                                "
	_cSql	+=	"		                        AND " +ValToSql(_cDataAte) + " <= SGG.GG_INI                                                        "
	_cSql	+=	"		                        AND " +ValToSql(_cDataAte) + " >= SGG.GG_FIM                                                        "
	_cSql	+=	"		                        AND SGG.GG_COD = "+ ValtoSql(_cId) +"                                                  "
	_cSql	+=	"		                        AND SGG.D_E_L_E_T_ = ''                                                             "
	_cSql	+=	"		               UNION ALL                                                                                    "
	_cSql	+=	"		               SELECT   T1.GG_COMP ID ,                                                                     "
	_cSql	+=	"		                        T1.GG_COD IDPAI ,                                                                   "
	_cSql	+=	"		                        T1.GG_INI DTINI ,                                                                   "
	_cSql	+=	"		                        T1.GG_FIM DTFIM ,                                                                   "
	_cSql	+=	"		                        T1.R_E_C_N_O_ REGSGG ,                                                              "
	_cSql	+=	"		                        NIVEL + 1 NIVEL                                                                     "
	_cSql	+=	"		               FROM     " + RETSQLNAME("SGG") + "  T1 ( NOLOCK )                                                                "
	_cSql	+=	"		                        INNER JOIN NIVEIS ON T1.GG_COD = NIVEIS.ID                                          "
	_cSql	+=	"		               WHERE    T1.GG_FILIAL = " + ValtoSql(xFilial("SGG")) + "                                                                 "
	_cSql	+=	"		                        AND T1.GG_INI = NIVEIS.DTINI                                                        "
	_cSql	+=	"		                        AND T1.GG_FIM = NIVEIS.DTFIM                                                        "
	_cSql	+=	"		                        AND T1.D_E_L_E_T_ = ''                                                              "
	_cSql	+=	"		             )                                                                                              "
	_cSql	+=	"		    SELECT  TABRD.* ,                                                                                       "
	_cSql	+=	"		            CASE WHEN UNITC <> 0 THEN QUANTBX * UNITC	                                                    "
	_cSql	+=	"		            END CUSTTOT                                                                                     "
	_cSql	+=	"		    FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY NIV.NIVEL, NIV.IDPAI, NIV.ID, NIV.REGSGG ) AS SEQ ,	"
	_cSql	+=	"		                        IDPAI ,                                                                         	"
	_cSql	+=	"		                        ID ,                                                                            	"
	_cSql	+=	"		                        DTINI ,                                                                         	"
	_cSql	+=	"		                        DTFIM ,                                                                         	"
	_cSql	+=	"		                        REGSGG ,                                                                        	"
	_cSql	+=	"		                        NIVEL ,                                                                         	"
	_cSql	+=	"		                        GG_TRT ,                                                                        	"
	_cSql	+=	"		                        CONVERT(NUMERIC(18, 8), GG_QUANT) GG_QUANT ,                                    	"
	_cSql	+=	"		                        GG_PERDA ,                                                                      	"
	_cSql	+=	"		                        CONVERT(NUMERIC(18, 8), ROUND(GG_QUANT / ( 100                                  	"
	_cSql	+=	"		                                                              - GG_PERDA )                              	"
	_cSql	+=	"		                                                      * 100, 8)) QUANTBX ,                              	"
	_cSql	+=	"		                        BZ_FANTASM FANTASM ,                                                            	"
	_cSql	+=	"		                        ISNULL(( SELECT MAX(Z87_CUSTO1)                                                 	"
	_cSql	+=	"		                                 FROM  " + RETSQLNAME("Z87") + " Z87                                        "
	_cSql	+=	"		                                 WHERE  Z87.Z87_FILIAL = " + VALTOSQL(xFILIAL("Z87")) + "                                           	"
	_cSql	+=	"		                                        AND Z87.Z87_DATARF = NIV.DTFIM                                  	"
	_cSql	+=	"		                                        AND Z87.Z87_PRODUT = NIV.ID                                     	"
	_cSql	+=	"		                                        AND Z87.D_E_L_E_T_ = ''                                         	"
	_cSql	+=	"		                               ), 0) UNITC,                                                              	"
	_cSql	+=	"		                        B1_TIPO                                                                         	"
	_cSql	+=	"		              FROM      NIVEIS NIV                                                                      	"
	_cSql	+=	"		                        INNER JOIN " + RETSQLNAME("SGG") + " SGG ( NOLOCK ) ON SGG.R_E_C_N_O_ = NIV.REGSGG  "
	_cSql	+=	"		                        INNER JOIN " + RETSQLNAME("SB1") + " SB1 ( NOLOCK ) ON SB1.B1_FILIAL = " + VALTOSQL(xFILIAL("SB1")) + "                          	"
	_cSql	+=	"		                                                            AND SB1.B1_COD = NIV.ID                     	"
	_cSql	+=	"		                                                            AND SB1.D_E_L_E_T_ = ''                     	"
	_cSql	+=	"		                        LEFT JOIN " + RETSQLNAME("SBZ") + " SBZ ( NOLOCK ) ON SBZ.BZ_FILIAL = " + VALTOSQL(xFILIAL("SBZ")) + "                         	"
	_cSql	+=	"		                                                           AND SBZ.BZ_COD = NIV.ID                      	"
	_cSql	+=	"		                                                           AND SBZ.D_E_L_E_T_ = ''                      	"
	_cSql	+=	"		            ) AS TABRD                                                                                  	"
	_cSql	+=	"		    ORDER BY SEQ DESC                                                                                   	"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSql),(_cAliasFAN),.T.,.T.)
	(_cAliasFan)->(dbGoTop())


	If (_cAliasFan)->(!EOF())
		_nNivAtu	:=	(_cAliasFan)->NIVEL
		While (_cAliasFan)->(!EOF())
			If (_nPos := aScan(_aPais,{|x| x[1] == (_cAliasFAN)->ID .And. x[2] == (_cAliasFan)->NIVEL + 1 })) > 0
				aAdd(_aPais,{(_cAliasFAN)->IDPAI,(_cAliasFan)->NIVEL,_aPais[_nPos,3]})
				If (_cAliasFan)->NIVEL == 0
					aAdd(_aFants,{(_cAliasFan)->ID,(_cAliasFan)->QUANTBX,_aPais[_nPos,3]})
				EndIf
			Else
				If (_nPos := aScan(_aPais,{|x| x[1] == (_cAliasFAN)->IDPAI .And. x[2] == (_cAliasFan)->NIVEL })) > 0
					_aPais[_nPos,3]	+= (_cAliasFan)->CUSTTOT
				Else
					aAdd(_aPais,{(_cAliasFAN)->IDPAI,(_cAliasFan)->NIVEL,(_cAliasFan)->CUSTTOT})
				EndIf
				If (_cAliasFan)->NIVEL == 0
					aAdd(_aFants,{(_cAliasFan)->ID,(_cAliasFan)->QUANTBX,(_cAliasFan)->UNITC})
				EndIf

			EndIf			
			(_cAliasFan)->(DbSkip())

		EndDo

	EndIf

	(_cAliasFan)->(DbGoTop())

Return	_aFants

Static Function fCalcUmid(_cComp)

	Local cfdUmid := 0
	Local cfdArea := GetArea()

	jh_UltD := UltimoDia(MV_PAR02)

	dbSelectArea("Z87")
	dbSetOrder(1)
	If dbSeek(xFilial("Z87") + dtos(jh_UltD) + _cComp)
		cfdUmid := Z87->Z87_UMIDAD
	EndIf

	RestArea( cfdArea )

Return ( cfdUmid )

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 25.01.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data              ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data             ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return


Static Function fPercDil(_cCodPai)

	Local _nPercDil	:=	0
	Local _aAreaSB1	:=	SB1->(GetArea())
	Local _cAlias	:=	GetNextAlias()

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+_cCodPai)) .And. Alltrim(SB1->B1_GRUPO) == "PI01"

		BEGINSQL ALIAS _cAlias
			SELECT GG_COD
			,SUM(GG_YMISTUR) PERC
			FROM %TABLE:SGG% SGG
			INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
			AND B1_COD = GG_COD
			AND B1_GRUPO = 'PI01'
			AND SB1.%NotDel%
			WHERE GG_FILIAL = %XFILIAL:SGG%
			AND %Exp:_cDataAte% <= SGG.GG_INI
			AND %Exp:_cDataAte% >= SGG.GG_FIM
			AND GG_COD = %Exp:SB1->B1_COD%
			AND SGG.%NotDel%
			GROUP BY GG_COD

		EndSql



		/*
		BeginSql Alias _cAlias

		SELECT  GG_COD ,
		GG_TRT ,
		ISNULL(SUM(SGG.GG_YMISTUR),0) PERC
		FROM    %TABLE:SGG% SGG
		WHERE   GG_FILIAL = %XFILIAL:SGG%
		AND GG_INI <= %Exp:_cDataAte%
		AND GG_FIM >= %Exp:_cDataAte%
		AND GG_COD = %Exp:_cCodPai%
		AND SGG.%NotDel%
		GROUP BY GG_COD ,
		GG_TRT		
		EndSql
		*/
		_nPercDil	:=	Iif((_cAlias)->(PERC) >= 100,0,(_cAlias)->PERC)

	EndIf


	SB1->(RestArea(_aAreaSB1))

Return _nPercDil


Static Function fGeraBD()

	Local _aArea	:=	GetArea()
	Local _cAliasB1	:=	GetNextAlias()

	Local _cAliasZ97	:=	GetNextAlias()

	Local _cCod	:=	Substr(Z97->Z97_COD,1,7)
	Local _cDoc
	Local _cRec


	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	If SB1->(DbSeek(xFilial("SB1")+Z97->Z97_COD)) .AND. SB1->B1_TIPO == 'PA'
		BEGINSQL ALIAS _cAliasB1
			SELECT B1_COD
			FROM %TABLE:SB1% SB1
			WHERE SB1.B1_FILIAL = %XFILIAL:SB1%
			AND SUBSTRING(SB1.B1_COD,1,7) = %Exp:_cCod%
			AND SUBSTRING(SB1.B1_COD,8,1) IN ('2','3')
			AND SB1.%NotDel%
		EndSql

		If (_cAliasB1)->(!EOF())
			BeginSql Alias _cAliasZ97
				SELECT *
				FROM %TABLE:Z97% Z97
				WHERE Z97.Z97_FILIAL = %XFILIAL:Z97% 
				AND Z97_DOC = %Exp:Z97->Z97_DOC%
				AND Z97_EMISSA = %Exp:Z97->Z97_EMISSA%
				AND %NotDel%
			EndSql		
			While (_cAliasB1)->(!EOF())
				(_cAliasZ97)->(DbGoTop())
				_cDoc		:=	fNextDoc()
				_cRec		:=	fNextReg()
				While (_cAliasZ97)->(!EOF())

					Reclock("Z97",.T.)
					Z97->Z97_FILIAL	:=	xFilial("Z97")	
					Z97->Z97_ORITAB	:=	(_cAliasZ97)->Z97_ORITAB
					Z97->Z97_TM		:=	(_cAliasZ97)->Z97_TM
					Z97->Z97_CF		:=	(_cAliasZ97)->Z97_CF
					Z97->Z97_COD	:=	Iif((_cAliasZ97)->Z97_TM = '010',(_cAliasB1)->B1_COD,(_cAliasZ97)->Z97_COD )
					Z97->Z97_CONTA	:=	(_cAliasZ97)->Z97_CONTA
					Z97->Z97_QUANT	:=	(_cAliasZ97)->Z97_QUANT
					Z97->Z97_DOC	:=	_cDoc
					Z97->Z97_EMISSA	:=	StoD((_cAliasZ97)->Z97_EMISSA)
					Z97->Z97_CUSTO1	:=	(_cAliasZ97)->Z97_CUSTO1
					Z97->Z97_OP		:=	(_cAliasZ97)->Z97_OP
					Z97->Z97_SEQREG	:=	_cRec	
					Z97->Z97_USER	:=	(_cAliasZ97)->Z97_USER
					Z97->Z97_TRT	:=	(_cAliasZ97)->Z97_TRT
					Z97->(MsUnLock())		
					(_cAliasZ97)->(DbSkip())
				EndDo
				(_cAliasB1)->(DbSkip())
			EndDo
		EndIF

	EndIf
	RestArea(_aArea)
Return
