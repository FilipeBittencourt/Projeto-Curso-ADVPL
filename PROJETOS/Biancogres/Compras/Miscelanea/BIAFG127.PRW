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
	Local msAlias	:=	GetNextAlias()
	Local _cRecno	:= "%'%" + Alltrim(Str(_nRecno)) + "%'%"
	Local _lRet		:=	.T.	
	Local msEnter   := CHR(13) + CHR(10)

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

			BEGINSQL Alias msAlias

				%NoParser%

				SELECT PROCESSO_BIZAGI NUMPROC
				FROM BZINTEGRACAO(NOLOCK)
				WHERE PROCESSO_NOME = 'RM'
				AND RECNO_RETORNO LIKE %Exp:_cRecno%			

			ENDSQL

			_lRet	:=	.F.
			msMsgInf := "A Nota Fiscal está com o processo de RECEBIMENTO DE MERCADORIA em aberto no BIZAGI." + msEnter 
			msMsgInf += msEnter 
			msMsgInf += "Para prosseguir com a exclusão, será necessário:" + msEnter 
			msMsgInf += "1) Alinhar com o Almoxarifado se o processo já foi recebido;" + msEnter 
			msMsgInf += "2) Se a etiqueta já foi impressa e se 30 minutos se passaram desde a impressão da etiqueta;" + msEnter 
			msMsgInf += "3) Ainda com o Almoxarifado poderá ser verificado se o processo deveria ter sido cancelado e ainda porque ainda não o foi;" + msEnter 
			msMsgInf += msEnter 
			msMsgInf += "Somente depois destas conferências, a nota poderá ser excluída!" + msEnter 
			msMsgInf += msEnter 
			msMsgInf += "O número do processo gerado é:       " + Alltrim((msAlias)->NUMPROC) + msEnter 
			msMsgInf += msEnter 
			msMsgInf += "Se preferir, poderá rastrear o processo acessando o BIZAGI e informando o número código acima." + msEnter 
			msMsgInf += msEnter 
			msMsgInf += "Se após executar as etapas acima ainda não for possível excluir a nota, favor abrir ticket, informando o múmero do processo e o status do BIZAGI. " + msEnter 

			MsgInfo(msMsgInf, "BIAFG127")

			(msAlias)->(DbCloseArea())

		EndIf

	EndIf

	(_cAlias)->(DbCloseArea())

Return _lRet
