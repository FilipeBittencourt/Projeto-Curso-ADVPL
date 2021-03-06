#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFG127
@author Gabriel Rossi Mafioletti
@since 02/06/2020
@version 1.0
@description Valida��o de Processo de compra - Retorna .T. se permite exclus�o  
@type function
/*/

User Function BIAFG127(_nRecno)

	Local _cAlias	:=	GetNextAlias()
	Local msAlias	:=	GetNextAlias()
	Local _cRecnoF	:= "%'%F1%" + Alltrim(Str(_nRecno)) + "%'%"
	Local _cRecnoD	:= "%'%D1%" + Alltrim(Str(_nRecno)) + "%'%"
	Local _lRet		:=	.T.	
	Local msEnter   := CHR(13) + CHR(10)
	
	BEGINSQL Alias _cAlias
		%NoParser%
		SELECT COUNT(*) QTD
		FROM BZINTEGRACAO (NOLOCK)
		WHERE PROCESSO_NOME = 'RM'
		AND RECNO_RETORNO LIKE %Exp:_cRecnoF%
		AND RECNO_RETORNO NOT LIKE %Exp:_cRecnoD%
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
			AND RECNO_RETORNO LIKE %Exp:_cRecnoF%
			AND RECNO_RETORNO NOT LIKE %Exp:_cRecnoD%
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
			AND RECNO_RETORNO LIKE %Exp:_cRecnoF%
			AND RECNO_RETORNO NOT LIKE %Exp:_cRecnoD%
			)
			AND STATUS = 'IB'
			AND RTRIM(DADOS_RETORNO) IN('N�O PROCESSADO', 'ERRO CLASSIFICACAO')
			UNION ALL
			SELECT COUNT(*) QTD
			FROM BZINTEGRACAO  (NOLOCK)
			WHERE PROCESSO_NOME = 'RM'
			AND RECNO_RETORNO LIKE %Exp:_cRecnoF%
			AND RECNO_RETORNO NOT LIKE %Exp:_cRecnoD%
			AND STATUS = 'IM'
			AND DADOS_RETORNO = 'PROCESSADO COM SUCESSO'
			AND GETDATE() - CONVERT(DATETIME, DATA_INTEGRACAO_PROTHEUS) > '1900-01-01 00:30:00.00')
			SELECT SUM(QTD) QTD
			FROM PRMCANC			

		ENDSQL

		If (_cAlias)->QTD == 0

			BEGINSQL Alias msAlias

				%NoParser%

				SELECT PROCESSO_BIZAGI NUMPROC
				FROM BZINTEGRACAO(NOLOCK)
				WHERE PROCESSO_NOME = 'RM'
				AND RECNO_RETORNO LIKE %Exp:_cRecnoF%
				AND RECNO_RETORNO NOT LIKE %Exp:_cRecnoD%			

			ENDSQL

			_lRet	:=	.F.
			msMsgInf := "A Nota Fiscal est� com o processo de RECEBIMENTO DE MERCADORIA em aberto no BIZAGI." + msEnter 
			msMsgInf += msEnter 
			msMsgInf += "Para prosseguir com a exclus�o, ser� necess�rio:" + msEnter 
			msMsgInf += "1) Alinhar com o Almoxarifado se o processo j� foi recebido;" + msEnter 
			msMsgInf += "2) Se a etiqueta j� foi impressa e se 30 minutos se passaram desde a impress�o da etiqueta;" + msEnter 
			msMsgInf += "3) Ainda com o Almoxarifado poder� ser verificado se o processo deveria ter sido cancelado e ainda porque ainda n�o o foi;" + msEnter 
			msMsgInf += msEnter 
			msMsgInf += "Somente depois destas confer�ncias, a nota poder� ser exclu�da!" + msEnter 
			msMsgInf += msEnter 
			msMsgInf += "O n�mero do processo gerado �:       " + Alltrim((msAlias)->NUMPROC) + msEnter 
			msMsgInf += msEnter 
			msMsgInf += "Se preferir, poder� rastrear o processo acessando o BIZAGI e informando o n�mero c�digo acima." + msEnter 
			msMsgInf += msEnter 
			msMsgInf += "Se ap�s executar as etapas acima ainda n�o for poss�vel excluir a nota, favor abrir ticket, informando o m�mero do processo e o status do BIZAGI. " + msEnter 

			MsgInfo(msMsgInf, "BIAFG127")

			(msAlias)->(DbCloseArea())

		EndIf

	EndIf

	(_cAlias)->(DbCloseArea())

Return _lRet
