#Include "TOPCONN.CH"
#Include 'PROTHEUS.CH'
#Include 'RWMAKE.CH'

/*/{Protheus.doc} BIAFG012
@author Gabriel Rossi Mafioletti
@since 26/06/17
@version 1.0
@description Função para geração da tabela de Pseudo Apontamento - SG1
@type function
/*/

User Function BIAFG012()

	Local nHandle

	cHInicio := Time()
	fPerg := "BIAFG012"
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

	nHandle := fCreate('BIAFG012.$$$')

	If(nHandle == -1)

		MsgInfo("Processo sendo executado por outro usuário!","BIAFG012")
		Return

	Endif 

	Processa({|| fProces()})

	fClose(nHandle)

	MsgINFO("Fim do Processamento...")

Return

Static Function fProces()

	Local _cAliasSD3	:= GetNextAlias()	//Alias Referente ao SD3
	Local _cAliasSG1	:= Nil				//Alias Referente ao SG1
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
	Local _nCusto		:= 0
	Local _nPercDil		:= 0
	Local _nQtdDil		:= 0
	Local _nI
	Local _aFants		:=	{}

	Private _cDataDe	:= MV_PAR01
	Private _cDataAte	:= UltimoDia(MV_PAR02)
	Private cNoCfCust   := AllTrim(GetNewPar("MV_YCUSCFN","1911,2911,1910,2910")) 

	cNoCfCust := StrTran(cNoCfCust,"/",",") 
	cNoCfCust := StrTran(cNoCfCust,"\",",") 
	cNoCfCust := StrTran(cNoCfCust,"|",",") 
	cNoCfCust := StrTran(cNoCfCust,";",",")

	_cQuery := " DELETE FROM " + RetSqlName("Z97") + " "
	_cQuery += "  WHERE Z97_FILIAL = " + ValtoSql(xFilial("Z97")) + " "
	_cQuery += "    AND Z97_ORITAB = 'SG1' "
	_cQuery += "    AND Z97_EMISSA BETWEEN " + ValtoSql(_cDataDe) + " AND " + ValtoSql(_cDataAte)
	_cQuery += "    AND D_E_L_E_T_ = ' ' "
	tcSqlExec(_cQuery)

	fQrySD3(_cAliasSD3)

	If (_cAliasSD3)->(!EOF())

		ProcRegua(0)

		While (_cAliasSD3)->(!EOF())

			_cAliasSG1	:=	GetNextAlias()

			fQrySG1(_cAliasSG1, (_cAliasSD3)->D3_COD)

			_cCodPai		:=	""
			_lFantPai		:=	.F.
			_nTotPai		:=	0
			While (_cAliasSG1)->(!EOF())

				IncProc("Processando... " + _cCodPai)

				If !fVerPrPaI((_cAliasSG1)->IDPAI)

					If _cCodPai	<> (_cAliasSG1)->IDPAI

						If !Empty(_cCodPai) 

							If !fVerPrPaI(_cCodPai) .And. !(_lFantPai) //Verifica Se já não existe um produto Pai com TM 010. Se já existir, Não Produzir

								//Insere a Produção(TM 010 e CF PR0) para o Produto Pai
								Reclock("Z97",.T.)
								Z97->Z97_FILIAL	:=	xFilial("Z97")	
								Z97->Z97_ORITAB	:=	"SG1"	
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
							_cDoc			:=	fNextDoc()
							_cRec			:=	fNextReg()
							_nTotPai	:=	0

						EndIf
						_cCodPai	:=	(_cAliasSG1)->IDPAI
						_lFantPai	:=	((_cAliasSG1)->FANTPAI == "S")
						_nPercDil	:=	fPercDil((_cAliasSG1)->IDPAI)		

					EndIf

					If _lFantPai
						(_cAliasSG1)->(DbSkip())
						Loop
					EndIf

					If (_cAliasSG1)->FANTFIL	==	'S'

						_cAliasFan	:=	GetNextAlias()
						MSIndex := CriaTrab(Nil,.f.)
						_aFants := fQryFan(_cAliasFan,(_cAliasSG1)->ID)

						If (_cAliasFan)->(!EOF())

							For _nI	:= 1 to Len(_aFants)	//Para cada Item Filho do Fantasma insere uma Requisição RE1

								_nUmid	:=	fCalcUmid(_aFants[_nI,1])

								If _nPercDil > 0
									_nQtdDil	:= (((_cAliasFan)->MISTURA / _nPercDil) * 100) * (_cAliasFan)->QUANTBX * (_cAliasSG1)->QUANTBX / (_cAliasFan)->MISTURA 	
									_nQtdUmid := _nQtdDil/(-(((_nUmid/100)/1)-1))
								Else
									_nQtdUmid := _aFants[_nI,2] * (_cAliasSG1)->QUANTBX/(-(((_nUmid/100)/1)-1))
								EndIf

								Reclock("Z97",.T.)
								Z97->Z97_FILIAL	:=	xFilial("Z97")	
								Z97->Z97_ORITAB	:=	"SG1"	
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
								Z97->Z97_TRT	:=	(_cAliasSG1)->G1_TRT
								Z97->(MsUnLock())						
								_nTotPai	+=	Z97->Z97_CUSTO1	
							Next

						Else

							_nUmid	:=	fCalcUmid((_cAliasSG1)->ID)
							If _nPercDil > 0
								_nQtdDil	:= (((_cAliasSG1)->MISTURA / _nPercDil) * 100) * (_cAliasSG1)->QUANTBX / (_cAliasSG1)->MISTURA
								_nQtdUmid := _nQtdDil/(-(((_nUmid/100)/1)-1))
							Else
								_nQtdUmid := (_cAliasSG1)->QUANTBX /(-(((_nUmid/100)/1)-1))
							EndIf

							Reclock("Z97",.T.)
							Z97->Z97_FILIAL	:=	xFilial("Z97")	
							Z97->Z97_ORITAB	:=	"SG1"	
							Z97->Z97_TM		:=	"999"
							Z97->Z97_CF		:=	"RE1"
							Z97->Z97_COD	:=	(_cAliasSG1)->ID
							Z97->Z97_CONTA	:=	Posicione("SB1",1,xFilial("SB1")+Z97->Z97_COD,"B1_YCTRIND")
							Z97->Z97_QUANT	:=	_nQtdUmid
							Z97->Z97_DOC	:=	_cDoc
							Z97->Z97_EMISSA	:=	_cDataAte
							Z97->Z97_CUSTO1	:=	_nQtdUmid * fCalcCus((_cAliasSG1)->ID)
							Z97->Z97_OP		:=	""
							Z97->Z97_SEQREG	:=	_cRec	
							Z97->Z97_USER	:=	cUsername
							Z97->Z97_TRT	:=	(_cAliasSG1)->G1_TRT
							Z97->(MsUnLock())						
							_nTotPai	+=	Z97->Z97_CUSTO1	

						EndIf

						(_cAliasFan)->(DbCloseArea())
						Ferase(MSIndex+GetDBExtension())
						Ferase(MSIndex+OrdBagExt())

					Else

						_nUmid	:=	fCalcUmid((_cAliasSG1)->ID)
						If _nPercDil > 0
							_nQtdDil	:= (((_cAliasSG1)->MISTURA / _nPercDil) * 100) * (_cAliasSG1)->QUANTBX / (_cAliasSG1)->MISTURA
							_nQtdUmid := _nQtdDil/(-(((_nUmid/100)/1)-1))
						Else
							_nQtdUmid := (_cAliasSG1)->QUANTBX /(-(((_nUmid/100)/1)-1))
						EndIf
						Reclock("Z97",.T.)
						Z97->Z97_FILIAL	:=	xFilial("Z97")	
						Z97->Z97_ORITAB	:=	"SG1"	
						Z97->Z97_TM		:=	"999"
						Z97->Z97_CF		:=	"RE1"
						Z97->Z97_COD	:=	(_cAliasSG1)->ID
						Z97->Z97_CONTA	:=	Posicione("SB1",1,xFilial("SB1")+Z97->Z97_COD,"B1_YCTRIND")
						Z97->Z97_QUANT	:=	_nQtdUmid
						Z97->Z97_DOC	:=	_cDoc
						Z97->Z97_EMISSA	:=	_cDataAte
						Z97->Z97_CUSTO1	:=	_nQtdUmid * fCalcCus((_cAliasSG1)->ID)  
						Z97->Z97_OP		:=	""
						Z97->Z97_SEQREG	:=	_cRec	
						Z97->Z97_USER	:=	cUsername
						Z97->Z97_TRT	:=	(_cAliasSG1)->G1_TRT
						Z97->(MsUnLock())						
						_nTotPai	+=	Z97->Z97_CUSTO1					
					EndIf

				EndIf

				(_cAliasSG1)->(DbSkip())

			EndDo

			If !fVerPrPaI(_cCodPai) .And. !(_lFantPai) //Verifica Se já não existe um produto Pai com TM 010. Se já existir, Não Produzir

				//Insere a Produção(TM 010 e CF PR0) para o Produto Pai
				Reclock("Z97",.T.)
				Z97->Z97_FILIAL	:=	xFilial("Z97")	
				Z97->Z97_ORITAB	:=	"SG1"	
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

			(_cAliasSG1)->(DbCloseArea())
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
		AND Z97_ORITAB = 'SG1'
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
		AND Z97_ORITAB = 'SG1'
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

Static Function fQrySG1(_cAliasSG1,_cCodPro)

	BeginSql Alias _cAliasSG1
		%NoParser%
		WITH NIVEIS AS (
		SELECT SG1.G1_COMP     ID,
		SG1.G1_COD      IDPAI,
		SG1.G1_INI      DTINI,
		SG1.G1_FIM      DTFIM,
		SG1.R_E_C_N_O_  REGSG1,
		SG1.G1_YMISTUR MISTURA,
		0           NIVEL
		FROM %TABLE:SG1% SG1 (NOLOCK)
		WHERE SG1.G1_FILIAL = %XFILIAL:SG1%
		AND %Exp:_cDataAte% >= SG1.G1_INI
		AND %Exp:_cDataAte% <= SG1.G1_FIM
		AND SG1.G1_COD = %Exp:_cCodPro%
		AND SG1.%NotDel%
		UNION ALL
		SELECT T1.G1_COMP     ID,
		T1.G1_COD      IDPAI,
		T1.G1_INI      DTINI,
		T1.G1_FIM      DTFIM,
		T1.R_E_C_N_O_  REGSG1,
		T1.G1_YMISTUR  MISTURA,
		NIVEL + 1      NIVEL
		FROM %TABLE:SG1% T1 (NOLOCK)
		INNER JOIN NIVEIS ON T1.G1_COD = NIVEIS.ID
		WHERE T1.G1_FILIAL = %XFILIAL:SG1%
		AND %Exp:_cDataAte% >= T1.G1_INI
		AND %Exp:_cDataAte% <= T1.G1_FIM
		AND T1.%NotDel%
		)
		SELECT TABRD.*,
		CASE
		WHEN UNITC <> 0 THEN QUANTBX * UNITC
	END CUSTTOT
	FROM (SELECT ROW_NUMBER() OVER(ORDER BY NIV.NIVEL, NIV.IDPAI, NIV.ID, NIV.REGSG1) AS SEQ,
	IDPAI,
	ID,
	DTINI,
	DTFIM,
	REGSG1,
	NIVEL,
	G1_TRT,
	G1_QUANT,
	G1_PERDA,
	CONVERT(NUMERIC(18,8),ROUND(G1_QUANT / ( 100 - G1_PERDA ) * 100, 8)) QUANTBX,
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
	INNER JOIN %TABLE:SG1% SG1 (NOLOCK) ON SG1.R_E_C_N_O_ = NIV.REGSG1
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
	,REGSG1
	,NIVEL
	,G1_TRT
	,G1_QUANT
	,G1_PERDA
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
	_cSql	+=	"		               SELECT   SG1.G1_COMP ID ,                                                                    "
	_cSql	+=	"		                        SG1.G1_COD IDPAI ,                                                                  "
	_cSql	+=	"		                        SG1.G1_INI DTINI ,                                                                  "
	_cSql	+=	"		                        SG1.G1_FIM DTFIM ,                                                                  "
	_cSql	+=	"		                        SG1.R_E_C_N_O_ REGSG1 ,                                                             "
	_cSql	+=	"		                        SG1.G1_YMISTUR MISTURA ,                                                             "
	_cSql	+=	"		                        0 NIVEL                                                                             "
	_cSql	+=	"		               FROM " + RETSQLNAME("SG1") + " SG1 ( NOLOCK )                                                "
	_cSql	+=	"		               WHERE    SG1.G1_FILIAL = " + ValtoSql(xFilial("SG1")) + "                                                                "
	_cSql	+=	"		                        AND " +ValToSql(_cDataAte) + " >= SG1.G1_INI                                                        "
	_cSql	+=	"		                        AND " +ValToSql(_cDataAte) + " <= SG1.G1_FIM                                                        "
	_cSql	+=	"		                        AND SG1.G1_COD = "+ ValtoSql(_cId) +"                                                  "
	_cSql	+=	"		                        AND SG1.D_E_L_E_T_ = ''                                                             "
	_cSql	+=	"		               UNION ALL                                                                                    "
	_cSql	+=	"		               SELECT   T1.G1_COMP ID ,                                                                     "
	_cSql	+=	"		                        T1.G1_COD IDPAI ,                                                                   "
	_cSql	+=	"		                        T1.G1_INI DTINI ,                                                                   "
	_cSql	+=	"		                        T1.G1_FIM DTFIM ,                                                                   "
	_cSql	+=	"		                        T1.R_E_C_N_O_ REGSG1 ,                                                              "
	_cSql	+=	"		                        T1.G1_YMISTUR MISTURA ,                                                             "
	_cSql	+=	"		                        NIVEL + 1 NIVEL                                                                     "
	_cSql	+=	"		               FROM     " + RETSQLNAME("SG1") + "  T1 ( NOLOCK )                                                                "
	_cSql	+=	"		                        INNER JOIN NIVEIS ON T1.G1_COD = NIVEIS.ID                                          "
	_cSql	+=	"		               WHERE    T1.G1_FILIAL = " + ValtoSql(xFilial("SG1")) + "                                                                 "
	_cSql	+=	"		                        AND " +ValToSql(_cDataAte) + " >= T1.G1_INI                                                        "
	_cSql	+=	"		                        AND " +ValToSql(_cDataAte) + " <= T1.G1_FIM                                                        "
	_cSql	+=	"		                        AND T1.D_E_L_E_T_ = ''                                                              "
	_cSql	+=	"		             )                                                                                              "
	_cSql	+=	"		    SELECT  TABRD.* ,                                                                                       "
	_cSql	+=	"		            CASE WHEN UNITC <> 0 THEN QUANTBX * UNITC	                                                    "
	_cSql	+=	"		            END CUSTTOT                                                                                     "
	_cSql	+=	"		    FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY NIV.NIVEL, NIV.IDPAI, NIV.ID, NIV.REGSG1 ) AS SEQ ,	"
	_cSql	+=	"		                        IDPAI ,                                                                         	"
	_cSql	+=	"		                        ID ,                                                                            	"
	_cSql	+=	"		                        DTINI ,                                                                         	"
	_cSql	+=	"		                        DTFIM ,                                                                         	"
	_cSql	+=	"		                        REGSG1 ,                                                                        	"
	_cSql	+=	"		                        NIVEL ,                                                                         	"
	_cSql	+=	"		                        G1_TRT ,                                                                        	"
	_cSql	+=	"		                        CONVERT(NUMERIC(18, 8), G1_QUANT) G1_QUANT ,                                    	"
	_cSql	+=	"		                        G1_PERDA ,                                                                      	"
	_cSql	+=	"		                        CONVERT(NUMERIC(18, 8), ROUND(G1_QUANT / ( 100                                  	"
	_cSql	+=	"		                                                              - G1_PERDA )                              	"
	_cSql	+=	"		                                                      * 100, 8)) QUANTBX ,                              	"
	_cSql	+=	"		                        BZ_FANTASM FANTASM ,                                                            	"
	_cSql	+=	"		                        MISTURA ,                                                            	"
	_cSql	+=	"		                        ISNULL(( SELECT MAX(Z87_CUSTO1)                                                 	"
	_cSql	+=	"		                                 FROM  " + RETSQLNAME("Z87") + " Z87                                        "
	_cSql	+=	"		                                 WHERE  Z87.Z87_FILIAL = " + VALTOSQL(xFILIAL("Z87")) + "                                           	"
	_cSql	+=	"		                                        AND Z87.Z87_DATARF = NIV.DTFIM                                  	"
	_cSql	+=	"		                                        AND Z87.Z87_PRODUT = NIV.ID                                     	"
	_cSql	+=	"		                                        AND Z87.D_E_L_E_T_ = ''                                         	"
	_cSql	+=	"		                               ), 0) UNITC                                                              	"
	_cSql	+=	"		              FROM      NIVEIS NIV                                                                      	"
	_cSql	+=	"		                        INNER JOIN " + RETSQLNAME("SG1") + " SG1 ( NOLOCK ) ON SG1.R_E_C_N_O_ = NIV.REGSG1  "
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
					_aPais[_nPos,3]	+= fCalcCus((_cAliasFan)->ID) * (_cAliasFan)->QUANTBX
				Else
					aAdd(_aPais,{(_cAliasFAN)->IDPAI,(_cAliasFan)->NIVEL,fCalcCus((_cAliasFan)->ID) * (_cAliasFan)->QUANTBX})
				EndIf
				If (_cAliasFan)->NIVEL == 0
					aAdd(_aFants,{(_cAliasFan)->ID,(_cAliasFan)->QUANTBX,fCalcCus((_cAliasFan)->ID)})
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

	SBZ->(dbSetOrder(1))
	If SBZ->(dbSeek(xFilial("SBZ")+_cComp))
		cfdUmid := SBZ->BZ_YUMIDAD
	EndIf

	jh_MesA := MV_PAR02
	jh_PriD := Substr(dtos(jh_MesA),1,6) + "01"
	jh_UltD := dtos(Ultimodia(jh_MesA))

	GH009 := " SELECT ISNULL((SELECT ROUND(SUM(Z02_UMIDAD * Z02_QTDCRG) / SUM(Z02_QTDCRG),2)
	GH009 += "                  FROM " + RetSqlName("Z02")
	GH009 += "                 WHERE Z02_FILIAL = '"+xFilial("Z02")+"'
	GH009 += "                   AND Z02_DATREF BETWEEN '"+jh_PriD+"' AND '"+jh_UltD+"'
	GH009 += "                   AND Z02_PRODUT = '" + _cComp + "'
	GH009 += "                   AND Z02_QTDCRG <> 0
	GH009 += "                   AND Z02_ORGCLT = '2'
	GH009 += "                   AND D_E_L_E_T_ = ' '), 0) UMIDADE
	GHcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,GH009),'GH09',.F.,.T.)
	dbSelectArea("GH09")
	dbGoTop()
	If GH09->UMIDADE <> 0
		cfdUmid := GH09->UMIDADE
	EndIf

	GH09->(dbCloseArea())
	Ferase(GHcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(GHcIndex+OrdBagExt())          //indice gerado

	RestArea( cfdArea )

Return ( cfdUmid )

Static Function fCalcCus(_cComp)

	Local cfdCust:= 0
	Local cfdArea := GetArea()

	SBZ->(dbSetOrder(1))
	If SBZ->(dbSeek(xFilial("SBZ")+_cComp))
		cfdCust := SBZ->BZ_YCTREF
	EndIf

	If SBZ->BZ_YCTREF == 0
		A0001 := " SELECT ISNULL((SELECT SUM(SD1.D1_CUSTO) / SUM(SD1.D1_QUANT)
		A0001 += "                  FROM "+RetSqlName("SD1")+" SD1
		A0001 += "                 INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
		A0001 += "                                      AND F4_CODIGO = D1_TES
		A0001 += "                                      AND F4_ESTOQUE = 'S'
		A0001 += "                                      AND SF4.D_E_L_E_T_ = ' '
		A0001 += "                 INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = D1_FILIAL
		A0001 += "                                      AND F1_DOC = D1_DOC
		A0001 += "                                      AND F1_SERIE = D1_SERIE
		A0001 += "                                      AND F1_FORNECE = D1_FORNECE	
		A0001 += "                                      AND F1_LOJA = D1_LOJA
		A0001 += "                                      AND F1_EMISSAO = D1_EMISSAO
		A0001 += "                                      AND F1_STATUS <> 'B'
		A0001 += "                                      AND SF1.D_E_L_E_T_ = ' '
		A0001 += "                 WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'
		A0001 += "                   AND SD1.D1_COD = '"+_cComp+"'
		A0001 += "                   AND SD1.D1_DTDIGIT <= '"+dtos(MV_PAR02)+"'
		A0001 += "                   AND SD1.D1_LOCAL IN ('01','20')
		A0001 += "                   AND SD1.D1_TES NOT IN('3I7')
		A0001 += "                   AND SD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
		A0001 += "                   AND SD1.D1_DTDIGIT IN(SELECT MAX(XD1.D1_DTDIGIT)
		A0001 += "                                           FROM "+RetSqlName("SD1")+" XD1
		A0001 += "                                          INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
		A0001 += "                                                               AND F4_CODIGO = D1_TES
		A0001 += "                                                               AND F4_ESTOQUE = 'S'
		A0001 += "                                                               AND SF4.D_E_L_E_T_ = ' '
		A0001 += "                                          INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = XD1.D1_FILIAL
		A0001 += "                                                               AND F1_DOC = XD1.D1_DOC
		A0001 += "                                                               AND F1_SERIE = XD1.D1_SERIE
		A0001 += "                                                               AND F1_FORNECE = XD1.D1_FORNECE	
		A0001 += "                                                               AND F1_LOJA = XD1.D1_LOJA
		A0001 += "                                                               AND F1_EMISSAO = XD1.D1_EMISSAO
		A0001 += "                                                               AND F1_STATUS <> 'B'
		A0001 += "                                                               AND SF1.D_E_L_E_T_ = ' '
		A0001 += "                                          WHERE XD1.D1_FILIAL = '"+xFilial("SD1")+"'
		A0001 += "                                            AND XD1.D1_COD = '"+_cComp+"'
		A0001 += "                                            AND XD1.D1_LOCAL IN ('01','20')
		A0001 += "                                            AND XD1.D1_TES NOT IN('3I7')
		A0001 += "                                            AND XD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
		A0001 += "                                            AND XD1.D1_DTDIGIT <= '"+dtos(MV_PAR02)+"'
		A0001 += "                                            AND XD1.D1_TIPO = 'N'
		A0001 += "                                            AND XD1.D1_QUANT <> 0
		A0001 += "                                            AND XD1.D_E_L_E_T_ = ' ')
		A0001 += "                   AND SD1.D_E_L_E_T_ = ' '), 0) EMP_ATU,
		A0001 += "         ISNULL((SELECT MAX(XD1.D1_DTDIGIT)
		A0001 += "                   FROM "+RetSqlName("SD1")+" XD1
		A0001 += "                  INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'
		A0001 += "                                       AND F4_CODIGO = D1_TES
		A0001 += "                                       AND F4_ESTOQUE = 'S'
		A0001 += "                                       AND SF4.D_E_L_E_T_ = ' '
		A0001 += "                  INNER JOIN "+RetSqlName("SF1")+" SF1 (NOLOCK) ON F1_FILIAL = XD1.D1_FILIAL
		A0001 += "                                       AND F1_DOC = XD1.D1_DOC
		A0001 += "                                       AND F1_SERIE = XD1.D1_SERIE
		A0001 += "                                       AND F1_FORNECE = XD1.D1_FORNECE	
		A0001 += "                                       AND F1_LOJA = XD1.D1_LOJA
		A0001 += "                                       AND F1_EMISSAO = XD1.D1_EMISSAO
		A0001 += "                                       AND F1_STATUS <> 'B'
		A0001 += "                                       AND SF1.D_E_L_E_T_ = ' '
		A0001 += "                  WHERE XD1.D1_FILIAL = '"+xFilial("SD1")+"'
		A0001 += "                    AND XD1.D1_COD = '"+_cComp+"'
		A0001 += "                    AND XD1.D1_DTDIGIT <= '"+dtos(MV_PAR02)+"'
		A0001 += "                    AND XD1.D1_LOCAL IN ('01','20')
		A0001 += "                    AND XD1.D1_TES NOT IN('3I7')
		A0001 += "                    AND XD1.D1_CF NOT IN " + FormatIn(cNoCfCust,",")
		A0001 += "                    AND XD1.D1_TIPO = 'N'
		A0001 += "                    AND XD1.D1_QUANT <> 0
		A0001 += "                    AND XD1.D_E_L_E_T_ = ' '), '        ') DT_E_ATU
		TcQuery A0001 ALIAS "A001" NEW
		dbSelectArea("A001")
		dbGoTop()
		cfdCust  := A001->EMP_ATU
		A001->(dbCloseArea())
	EndIf

	If cFdCust == 0
		cFdCust := fVerCusPr(_cComp)
	EndIf

	RestArea( cfdArea )

Return ( cfdCust )

Static Function fPercDil(_cCodPai)

	Local _nPercDil	:=	0
	Local _aAreaSB1	:=	SB1->(GetArea())
	Local _cAlias	:=	GetNextAlias()

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial("SB1")+_cCodPai)) .And. Alltrim(SB1->B1_GRUPO) == "PI01"

		BeginSql Alias _cAlias

			SELECT  G1_COD ,
			G1_TRT ,
			ISNULL(SUM(SG1.G1_YMISTUR),0) PERC
			FROM    %TABLE:SG1% SG1
			WHERE   G1_FILIAL = %XFILIAL:SG1%
			AND G1_INI <= %Exp:_cDataAte%
			AND G1_FIM >= %Exp:_cDataAte%
			AND G1_COD = %Exp:_cCodPai%
			AND SG1.%NotDel%
			GROUP BY G1_COD ,
			G1_TRT		
		EndSql

		_nPercDil	:=	Iif((_cAlias)->(PERC) >= 100,0,(_cAlias)->PERC)

	EndIf


	SB1->(RestArea(_aAreaSB1))

Return _nPercDil

Static Function fCalcPerda(_nReg,_nQuant)

	Local nQuantItem	:=	0 

	If _nReg == 121473
		SG1->(DbGoTo(_nReg))

		nQuantItem	:= ExplEstr(_nQuant,,,)
	EndIf

Return nQuantItem

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
