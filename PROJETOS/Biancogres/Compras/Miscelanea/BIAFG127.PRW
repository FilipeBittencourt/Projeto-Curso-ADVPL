#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG127
@author Gabriel Rossi Mafioletti
@since 02/06/2020
@version 1.0
@description Validação de Processo de compra - Retorna .T. se permite exclusão  
@type function
/*/

User Function BIAFG127(_nRecno)

	Local _cAlias	:=	GetNextAlias()
	Local _cRecno	:= "%'%" + Alltrim(Str(_nRecno)) + "%'%"
	Local _lRet		:=	.T.	

	BEGINSQL Alias _cAlias
		%NoParser%
		SELECT COUNT(*) QTD
		FROM BZINTEGRACAO (NOLOCK)
		WHERE PROCESSO_NOME = 'RM'
		AND RECNO_RETORNO LIKE %Exp:_cRecno%
	ENDSQL

	If (_cAlias)->QTD > 0

		(_cAlias)->(DbCloseArea())
		_cAlias	:=	GetNextAlias()

		BEGINSQL Alias _cAlias

			%NoParser%

			WITH PRMCANC
			     AS (SELECT COUNT(*) QTD
			         FROM BZINTEGRACAO (NOLOCK)
			         WHERE PROCESSO_NOME = 'RM'
			               AND RECNO_RETORNO LIKE %Exp:_cRecno%
			               AND STATUS = 'CN'
			         UNION ALL
			         SELECT COUNT(*) QTD
			         FROM BZINTEGRACAO (NOLOCK)
			         WHERE PROCESSO_NOME = 'RM'
			               AND PROCESSO_BIZAGI IN
			         (
			             SELECT PROCESSO_BIZAGI
			             FROM BZINTEGRACAO (NOLOCK)
			             WHERE PROCESSO_NOME = 'RM'
			                   AND RECNO_RETORNO LIKE %Exp:_cRecno%
			         )
			               AND STATUS = 'IB'
			               AND RTRIM(DADOS_RETORNO) IN('NÃO PROCESSADO', 'ERRO CLASSIFICACAO')
			         UNION ALL
			         SELECT COUNT(*) QTD
			         FROM BZINTEGRACAO  (NOLOCK)
			         WHERE PROCESSO_NOME = 'RM'
			               AND RECNO_RETORNO LIKE %Exp:_cRecno%
			               AND STATUS = 'IM'
			               AND DADOS_RETORNO = 'PROCESSADO COM SUCESSO'
			               AND GETDATE() - CONVERT(DATETIME, DATA_INTEGRACAO_PROTHEUS) > '1900-01-01 00:30:00.00')
			     SELECT SUM(QTD) QTD
			     FROM PRMCANC			

		ENDSQL

		If (_cAlias)->QTD == 0
			_lRet	:=	.F.
			MsgInfo("A Nota Fiscal possui processo em aberto no BIZAGI. Para prosseguir com a operação o mesmo deverá ser cancelado!","BIAFG127")

		EndIf

	EndIf

	(_cAlias)->(DbCloseArea())

Return _lRet
