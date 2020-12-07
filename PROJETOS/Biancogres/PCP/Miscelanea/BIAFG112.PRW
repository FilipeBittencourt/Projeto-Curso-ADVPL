#include 'protheus.ch'

/*/{Protheus.doc} BIAFG112
@author Gabriel Rossi Mafioletti
@since 21/10/19
@version 1.0
@description Função para geração da tabela de Pseudo Apontamento Projetado - SGG
@type function
/*/

User Function BIAFG112()

	Local nHandle
	Local _nMesDe	:=	0
	Local _nMesAte	:=	0
	Local _nI

	Local dDataRef

	Private _nMesAtu	:=	0

	nHandle := fCreate('BIAFG112.$$$')

	If(nHandle == -1)

		MsgInfo("Processo sendo executado por outro usuário!","BIAFG112")
		Return

	Endif 

	cHInicio := Time()
	If !ValidPerg()
		Return
	EndIf

	/*
	If !U_VALOPER("049",.F.)

	If ( MV_PAR01 <= GetMV("MV_YULRAC") .or. MV_PAR02 <= GetMV("MV_YULRAC") )
	MsgSTOP("Favor verificar o intervalo de datas informado, pois está fora do período de fechamento de estoque.", "OP 049 - Data de Fechamento!!!")
	Return
	EndIf

	EndIf
	*/

	_nMesDe		:=	1
	_nMesAte	:=	12

	For _nI	:=	_nMesDe	to _nMesAte

		_nMesAtu	:=	Iif(_nI == 13,1,_nI)

		dDataRef	:=	Stod(MV_PAR03+PADL(Alltrim(Str(_nMesAtu)),2,"0")+"01")
		If _nI	<> 13
			dDataRef	:=	UltimoDia(dDataRef)
		EndIf

		Processa({|| fProces(dDataRef)})

	Next

	fClose(nHandle)

	MsgINFO("Fim do Processamento...")

Return

Static Function fProces(dDataRef)

	Local _nI
	Local _cAliasZ47	:= GetNextAlias()	//Alias Referente ao Z47
	Local _cAliasSGG	:= Nil				//Alias Referente ao SGG
	Local _cAliasFAN	:= Nil				//Alias Referente ao Produto Fantasma
	Local _cAliasZBP	:= Nil
	Local _cCodPai		:= ""
	Local _lFantPai		:= .F.
	Local _nTotPai		:= 0
	Local _lSkip		:= .F.
	Local _cDoc			:= fNextDoc()
	Local _cRec			:= fNextReg()
	Local _nUmid		:= 0
	Local _nQtdUmid		:= 0
	Local _cQuery		:= "" 

	Local _nPercDil		:= 0
	Local _nQtdDil		:= 0
	Local _aFants		:=	{}

	Private _cDataRef    := DtoS(dDataRef)

	Private _cVersao	:=	MV_PAR01
	Private _cRevisa	:=	MV_PAR02
	Private _cAnoRef	:=	MV_PAR03

	_cQuery := " DELETE FROM " + RetSqlName("ZBP") + " "
	_cQuery += "  WHERE ZBP_FILIAL = " + ValtoSql(xFilial("ZBP")) + " "
	_cQuery += "    AND ZBP_VERSAO = " + ValtoSql(_cVersao)
	_cQuery += "    AND ZBP_REVISA = " + ValtoSql(_cRevisa)
	_cQuery += "    AND ZBP_ANOREF = " + ValtoSql(_cAnoRef)	
	_cQuery += "    AND ZBP_EMISSA = " + ValtoSql(_cDataRef)
	_cQuery += "    AND ZBP_ORITAB = 'SGG' "
	_cQuery += "    AND D_E_L_E_T_ = ' ' "
	tcSqlExec(_cQuery)

	fQryZ47(_cAliasZ47)

	If (_cAliasZ47)->(!EOF())

		ProcRegua(0)

		While (_cAliasZ47)->(!EOF())

			_cAliasSGG	:=	GetNextAlias()

			fQrySGG(_cAliasSGG, (_cAliasZ47)->Z47_PRODUT )

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
								Reclock("ZBP",.T.)
								ZBP->ZBP_FILIAL	:=	xFilial("ZBP")	
								ZBP->ZBP_VERSAO	:=	_cVersao
								ZBP->ZBP_REVISA	:=	_cRevisa
								ZBP->ZBP_ANOREF	:=	_cAnoRef								
								ZBP->ZBP_ORITAB	:=	"SGG"	
								ZBP->ZBP_TM		:=	"010"
								ZBP->ZBP_CF		:=	"PR0"
								ZBP->ZBP_COD	:=	_cCodPai
								ZBP->ZBP_CONTA	:=	Posicione("SB1",1,xFilial("SB1")+ZBP->ZBP_COD,"B1_YCTRIND")
								ZBP->ZBP_QUANT	:=	1
								ZBP->ZBP_DOC	:=	_cDoc
								ZBP->ZBP_EMISSA	:=	StoD(_cDataRef)
								ZBP->ZBP_CUSTO1	:=	_nTotPai
								ZBP->ZBP_OP		:=	""
								ZBP->ZBP_SEQREG	:=	_cRec	
								ZBP->ZBP_USER	:=	cUsername
								ZBP->ZBP_TRT	:=	""
								ZBP->(MsUnLock())

								//fGeraBD()

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

								Reclock("ZBP",.T.)
								ZBP->ZBP_FILIAL	:=	xFilial("ZBP")	
								ZBP->ZBP_VERSAO	:=	_cVersao	
								ZBP->ZBP_REVISA	:=	_cRevisa
								ZBP->ZBP_ANOREF	:=	_cAnoRef									
								ZBP->ZBP_ORITAB	:=	"SGG"	
								ZBP->ZBP_TM		:=	"999"
								ZBP->ZBP_CF		:=	"RE1"
								ZBP->ZBP_COD	:=	_aFants[_nI,1]
								ZBP->ZBP_CONTA	:=	Posicione("SB1",1,xFilial("SB1")+ZBP->ZBP_COD,"B1_YCTRIND")
								ZBP->ZBP_QUANT	:=	_nQtdUmid
								ZBP->ZBP_DOC	:=	_cDoc
								ZBP->ZBP_EMISSA	:=	StoD(_cDataRef)
								ZBP->ZBP_CUSTO1	:=	_nQtdUmid * _aFants[_nI,3] 
								ZBP->ZBP_OP		:=	""
								ZBP->ZBP_SEQREG	:=	_cRec	
								ZBP->ZBP_USER	:=	cUsername
								ZBP->ZBP_TRT	:=	(_cAliasSGG)->GG_TRT
								ZBP->(MsUnLock())						
								_nTotPai	+=	ZBP->ZBP_CUSTO1	

							Next

						Else

							_nUmid	:=	fCalcUmid((_cAliasSGG)->ID)
							If _nPercDil > 0
								_nQtdDil	:= (((_cAliasSGG)->MISTURA / _nPercDil) * 100) * (_cAliasSGG)->QUANTBX / (_cAliasSGG)->MISTURA
								_nQtdUmid := _nQtdDil/(-(((_nUmid/100)/1)-1))
							Else
								_nQtdUmid := (_cAliasSGG)->QUANTBX/(-(((_nUmid/100)/1)-1))
							EndIf

							Reclock("ZBP",.T.)
							ZBP->ZBP_FILIAL	:=	xFilial("ZBP")	
							ZBP->ZBP_VERSAO	:=	_cVersao
							ZBP->ZBP_REVISA	:=	_cRevisa
							ZBP->ZBP_ANOREF	:=	_cAnoRef
							ZBP->ZBP_ORITAB	:=	"SGG"	
							ZBP->ZBP_TM		:=	"999"
							ZBP->ZBP_CF		:=	"RE1"
							ZBP->ZBP_COD	:=	(_cAliasSGG)->ID
							ZBP->ZBP_CONTA	:=	Posicione("SB1",1,xFilial("SB1")+ZBP->ZBP_COD,"B1_YCTRIND")
							ZBP->ZBP_QUANT	:=	_nQtdUmid
							ZBP->ZBP_DOC	:=	_cDoc
							ZBP->ZBP_EMISSA	:=	Stod(_cDataRef)
							ZBP->ZBP_CUSTO1	:=	(_cAliasSGG)->CUSTTOT / (_cAliasSGG)->QUANTBX * _nQtdUmid
							ZBP->ZBP_OP		:=	""
							ZBP->ZBP_SEQREG	:=	_cRec	
							ZBP->ZBP_USER	:=	cUsername
							ZBP->ZBP_TRT	:=	(_cAliasSGG)->GG_TRT
							ZBP->(MsUnLock())						
							_nTotPai	+=	ZBP->ZBP_CUSTO1	

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

						Reclock("ZBP",.T.)
						ZBP->ZBP_FILIAL	:=	xFilial("ZBP")	
						ZBP->ZBP_VERSAO	:=	_cVersao
						ZBP->ZBP_REVISA	:=	_cRevisa
						ZBP->ZBP_ANOREF	:=	_cAnoRef						
						ZBP->ZBP_ORITAB	:=	"SGG"	
						ZBP->ZBP_TM		:=	"999"
						ZBP->ZBP_CF		:=	"RE1"
						ZBP->ZBP_COD	:=	(_cAliasSGG)->ID
						ZBP->ZBP_CONTA	:=	Posicione("SB1",1,xFilial("SB1")+ZBP->ZBP_COD,"B1_YCTRIND")
						ZBP->ZBP_QUANT	:=	_nQtdUmid
						ZBP->ZBP_DOC	:=	_cDoc
						ZBP->ZBP_EMISSA	:=	Stod(_cDataRef)
						ZBP->ZBP_CUSTO1	:=	Iif((_cAliasSGG)->CUSTTOT == 0, fVerCusPr((_cAliasSGG)->ID )* _nQtdUmid,(_cAliasSGG)->CUSTTOT/(_cAliasSGG)->QUANTBX * _nQtdUmid)  
						ZBP->ZBP_OP		:=	""
						ZBP->ZBP_SEQREG	:=	_cRec	
						ZBP->ZBP_USER	:=	cUsername
						ZBP->ZBP_TRT	:=	(_cAliasSGG)->GG_TRT
						ZBP->(MsUnLock())						
						_nTotPai	+=	ZBP->ZBP_CUSTO1					

					EndIf

				EndIf

				(_cAliasSGG)->(DbSkip())

			EndDo

			If !fVerPrPaI(_cCodPai) .And. !(_lFantPai) //Verifica Se já não existe um produto Pai com TM 010. Se já existir, Não Produzir

				//Insere a Produção(TM 010 e CF PR0) para o Produto Pai
				Reclock("ZBP",.T.)
				ZBP->ZBP_FILIAL	:=	xFilial("ZBP")	
				ZBP->ZBP_VERSAO	:=	_cVersao
				ZBP->ZBP_REVISA	:=	_cRevisa
				ZBP->ZBP_ANOREF	:=	_cAnoRef				
				ZBP->ZBP_ORITAB	:=	"SGG"	
				ZBP->ZBP_TM		:=	"010"
				ZBP->ZBP_CF		:=	"PR0"
				ZBP->ZBP_COD	:=	_cCodPai
				ZBP->ZBP_CONTA	:=	Posicione("SB1",1,xFilial("SB1")+ZBP->ZBP_COD,"B1_YCTRIND")
				ZBP->ZBP_QUANT	:=	1
				ZBP->ZBP_DOC	:=	_cDoc
				ZBP->ZBP_EMISSA	:=	Stod(_cDataRef)
				ZBP->ZBP_CUSTO1	:=	_nTotPai
				ZBP->ZBP_OP		:=	""
				ZBP->ZBP_SEQREG	:=	_cRec	
				ZBP->ZBP_USER	:=	cUsername
				ZBP->ZBP_TRT	:=	""
				ZBP->(MsUnLock())

				//fGeraBD()

				_cDoc		:=	fNextDoc()
				_cRec		:=	fNextReg()
				_nTotPai	:=	0

			EndIf

			(_cAliasSGG)->(DbCloseArea())
			(_cAliasZ47)->(DbSkip())

		Enddo

		(_cAliasZ47)->(DbCloseArea())

	Else

		Aviso('Z47', 'Não Foram Encontrados Registros para Procesamento!',{'Ok'})

	EndIf

Return

Static Function fNextReg()

	Local _cReg	:=	""
	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias
		SELECT ISNULL(MAX(ZBP_SEQREG),'000000') AS SEQ
		FROM %TABLE:ZBP% 
		WHERE ZBP_FILIAL = %XFILIAL:ZBP%
		AND %NotDel%
	EndSql

	_cReg	:=	SOMA1((_cAlias)->SEQ)

	(_cAlias)->(DbCloseArea())

Return _cReg

Static Function fNextDoc()

	Local _cDoc	:=	""
	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias
		SELECT ISNULL(MAX(ZBP_DOC),'000000000') AS DOC
		FROM %TABLE:ZBP% 
		WHERE ZBP_FILIAL = %XFILIAL:ZBP%
		AND %NotDel%
	EndSql

	_cDoc	:=	SOMA1((_cAlias)->DOC)

	(_cAlias)->(DbCloseArea())

Return _cDoc

Static Function fVerPrPaI(_cCodPai)

	Local _cAlias	:=	GetNextAlias()
	Local _lRet		:=	.F.

	BeginSql Alias _cAlias
		SELECT  ISNULL(MAX(ZBP_CUSTO1),0) CUSTO, COUNT(*) QTD
		FROM    %TABLE:ZBP%
		WHERE   ZBP_FILIAL = %XFILIAL:ZBP%
		AND ZBP_VERSAO = %Exp:_cVersao%
		AND ZBP_REVISA = %Exp:_cRevisa%
		AND ZBP_ANOREF = %Exp:_cAnoRef%
		AND ZBP_EMISSA = %Exp:_cDataRef%
		AND %NotDel%
		AND ZBP_COD = %Exp:_cCodPai%
		AND ZBP_TM = '010'
		AND ZBP_ORITAB = 'SGG'
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
		SELECT  ISNULL(MAX(ZBP_CUSTO1),0) CUSTO
		FROM    %TABLE:ZBP%
		WHERE   ZBP_FILIAL = %XFILIAL:ZBP%
		AND ZBP_VERSAO = %Exp:_cVersao%
		AND ZBP_REVISA = %Exp:_cRevisa%
		AND ZBP_ANOREF = %Exp:_cAnoRef%	
		AND ZBP_EMISSA = %Exp:_cDataRef%
		AND %NotDel%
		AND ZBP_COD = %Exp:_cCod%
		AND ZBP_TM = '010'
		AND ZBP_ORITAB = 'SGG'
	EndSql

	_nCusto	:=	(_cALias)->CUSTO
	(_cAlias)->(DbCloseArea())

Return _nCusto

Static Function fQryZ47(_cAliasZ47)

	Local _cCampo	:=	"%Z47_QTDM" + PADL(Alltrim(Str(_nMesAtu)),2,"0")+ "%"

	BeginSql Alias _cAliasZ47

		SELECT DISTINCT Z47_PRODUT
		FROM (
		SELECT SUBSTRING(Z47_PRODUT,1,7) + '1       ' Z47_PRODUT
		FROM %TABLE:Z47% Z47 ( NOLOCK )
		INNER JOIN %TABLE:SB1% SB1 ON B1_FILIAL = %XFILIAL:SB1%
		AND B1_COD = Z47_PRODUT
		AND SB1.%NotDel%
		WHERE Z47_FILIAL = %XFILIAL:Z47%

		AND Z47_VERSAO = %Exp:_cVersao%
		AND Z47_REVISA = %Exp:_cRevisa%
		AND Z47_ANOREF = %Exp:_cAnoRef%
		AND B1_TIPO = 'PA'
		AND %Exp:_cCampo% > 0
		AND Z47.%NotDel%
		) PRODS
		GROUP BY Z47_PRODUT

	EndSql

	//AND Z47_PRODUT IN('B90721B1', 'BD2433I1', 'BN0709D1', 'BO0232N1', 'BP0209A1', 'BQ0041B1', 'BR0112I1', 'C10342N1', 'C61342N1', 'CC0593G1', 'CD0261U1')

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
		AND %Exp:_cDataRef% <= SGG.GG_INI
		AND %Exp:_cDataRef% >= SGG.GG_FIM
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
	_cSql	+=	"		               WHERE    SGG.GG_FILIAL = " + ValtoSql(xFilial("SGG")) + "                                    "
	_cSql	+=	"		                        AND " +ValToSql(_cDataRef) + " <= SGG.GG_INI                                        "
	_cSql	+=	"		                        AND " +ValToSql(_cDataRef) + " >= SGG.GG_FIM                                        "
	_cSql	+=	"		                        AND SGG.GG_COD = "+ ValtoSql(_cId) +"                                               "
	_cSql	+=	"		                        AND SGG.D_E_L_E_T_ = ''                                                             "
	_cSql	+=	"		               UNION ALL                                                                                    "
	_cSql	+=	"		               SELECT   T1.GG_COMP ID ,                                                                     "
	_cSql	+=	"		                        T1.GG_COD IDPAI ,                                                                   "
	_cSql	+=	"		                        T1.GG_INI DTINI ,                                                                   "
	_cSql	+=	"		                        T1.GG_FIM DTFIM ,                                                                   "
	_cSql	+=	"		                        T1.R_E_C_N_O_ REGSGG ,                                                              "
	_cSql	+=	"		                        NIVEL + 1 NIVEL                                                                     "
	_cSql	+=	"		               FROM     " + RETSQLNAME("SGG") + "  T1 ( NOLOCK )                                            "
	_cSql	+=	"		                        INNER JOIN NIVEIS ON T1.GG_COD = NIVEIS.ID                                          "
	_cSql	+=	"		               WHERE    T1.GG_FILIAL = " + ValtoSql(xFilial("SGG")) + "                                     "
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
	_cSql	+=	"		                                 WHERE  Z87.Z87_FILIAL = " + VALTOSQL(xFILIAL("Z87")) + "                   "
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

	dbSelectArea("Z87")
	dbSetOrder(1)
	If dbSeek(xFilial("Z87") + _cDataRef + _cComp)
		cfdUmid := Z87->Z87_UMIDAD
	EndIf

	RestArea( cfdArea )

Return ( cfdUmid )

Static Function ValidPerg()

	local cLoad	    := "BIAFG112" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local aPergs	:=	{}

	MV_PAR01 := SPACE(TAMSX3("Z98_VERSAO")[1])
	MV_PAR02 := SPACE(TAMSX3("Z98_REVISA")[1])
	MV_PAR03 := SPACE(TAMSX3("Z98_ANOREF")[1])

	aAdd( aPergs ,{1,"Versão " 	   		        ,MV_PAR01 ,""    ,"",'ZB5'  ,'.T.',50,.T.})
	aAdd( aPergs ,{1,"Revisão " 	   	        ,MV_PAR02 ,""    ,"",''     ,'.F.',50,.F.})
	aAdd( aPergs ,{1,"AnoRef " 	   		        ,MV_PAR03 ,""    ,"",''     ,'.F.',50,.F.})

	If ParamBox(aPergs ,"Pseudo Apontamento Projetado",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)

	EndIf

Return lRet

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
			AND %Exp:_cDataRef% <= SGG.GG_INI
			AND %Exp:_cDataRef% >= SGG.GG_FIM
			AND GG_COD = %Exp:SB1->B1_COD%
			AND SGG.%NotDel%
			GROUP BY GG_COD

		EndSql

		_nPercDil	:=	Iif((_cAlias)->(PERC) >= 100,0,(_cAlias)->PERC)

		(_cAlias)->(DbCloseArea())

	EndIf

	SB1->(RestArea(_aAreaSB1))

Return _nPercDil

Static Function fGeraBD()

	Local _aArea	:=	GetArea()
	Local _cAliasB1	:=	GetNextAlias()

	Local _cAliasZBP	:=	GetNextAlias()

	Local _cCod	:=	Substr(ZBP->ZBP_COD,1,7)
	Local _cDoc
	Local _cRec

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	If SB1->(DbSeek(xFilial("SB1")+ZBP->ZBP_COD)) .AND. SB1->B1_TIPO == 'PA'
		BEGINSQL ALIAS _cAliasB1
			SELECT B1_COD
			FROM %TABLE:SB1% SB1
			WHERE SB1.B1_FILIAL = %XFILIAL:SB1%
			AND SUBSTRING(SB1.B1_COD,1,7) = %Exp:_cCod%
			AND SUBSTRING(SB1.B1_COD,8,1) IN ('2','3')
			AND SB1.%NotDel%
		EndSql

		If (_cAliasB1)->(!EOF())
			BeginSql Alias _cAliasZBP
				SELECT *
				FROM %TABLE:ZBP% ZBP
				WHERE ZBP.ZBP_FILIAL = %XFILIAL:ZBP% 
				AND ZBP_DOC = %Exp:ZBP->ZBP_DOC%
				AND ZBP_EMISSA = %Exp:ZBP->ZBP_EMISSA%
				AND %NotDel%
			EndSql		
			While (_cAliasB1)->(!EOF())
				(_cAliasZBP)->(DbGoTop())
				_cDoc		:=	fNextDoc()
				_cRec		:=	fNextReg()
				While (_cAliasZBP)->(!EOF())

					Reclock("ZBP",.T.)
					ZBP->ZBP_FILIAL	:=	xFilial("ZBP")	
					ZBP->ZBP_VERSAO	:=	_cVersao
					ZBP->ZBP_REVISA	:=	_cRevisa
					ZBP->ZBP_ANOREF	:=	_cAnoRef					
					ZBP->ZBP_ORITAB	:=	(_cAliasZBP)->ZBP_ORITAB
					ZBP->ZBP_TM		:=	(_cAliasZBP)->ZBP_TM
					ZBP->ZBP_CF		:=	(_cAliasZBP)->ZBP_CF
					ZBP->ZBP_COD	:=	Iif((_cAliasZBP)->ZBP_TM = '010',(_cAliasB1)->B1_COD,(_cAliasZBP)->ZBP_COD )
					ZBP->ZBP_CONTA	:=	(_cAliasZBP)->ZBP_CONTA
					ZBP->ZBP_QUANT	:=	(_cAliasZBP)->ZBP_QUANT
					ZBP->ZBP_DOC	:=	_cDoc
					ZBP->ZBP_EMISSA	:=	StoD((_cAliasZBP)->ZBP_EMISSA)
					ZBP->ZBP_CUSTO1	:=	(_cAliasZBP)->ZBP_CUSTO1
					ZBP->ZBP_OP		:=	(_cAliasZBP)->ZBP_OP
					ZBP->ZBP_SEQREG	:=	_cRec	
					ZBP->ZBP_USER	:=	(_cAliasZBP)->ZBP_USER
					ZBP->ZBP_TRT	:=	(_cAliasZBP)->ZBP_TRT
					ZBP->(MsUnLock())		
					(_cAliasZBP)->(DbSkip())
				EndDo
				(_cAliasB1)->(DbSkip())
			EndDo

			(_cAliasB1)->(DbCloseArea())
			(_cAliasZBP)->(DbCloseArea())

		EndIF

	EndIf
	RestArea(_aArea)

Return
