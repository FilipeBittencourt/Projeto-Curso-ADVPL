#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG032
@author Gabriel Rossi Mafioletti
@since 21/02/2018
@version 1.0
@description Função para Verificação se o pedido de amostra está no ECOSiS.
			Retornará Falso se Houverem Pedidos no Ecosis
@type function
/*/

User Function BIAFG032(_cPedido,_cItem)

	Local _cAlias	:=	GetNextAlias()
	Local kt_BsDad
	Local _lRet		:=	.T.
	Local _nItem	:=	0

	Default _cItem	:=	""


	IF cEmpAnt == "01"
		kt_BsDad	:= "%DADOSEOS%"
	ELSEIF cEmpAnt == "05"
		kt_BsDad	:= "%DADOS_05_EOS%"
	ELSE
		//Alterar quando houver outras emnpresas usando o Ecosis
		Return _lRet
	ENDIF
	
	If empty(_cItem)
		BeginSql Alias _cAlias
	
			SELECT COUNT(*) QTD
			FROM %TABLE:SC6% SC6
			JOIN %Exp:Kt_BsDad%..cep_ctrl_amostra B ON SC6.C6_YECONAM = B.cca_codigo COLLATE Latin1_General_BIN
				AND (B.cca_data_cancelamento = '' OR B.cca_data_cancelamento IS NULL)
			WHERE SC6.C6_YECONAM <> ''
				AND SC6.C6_FILIAL = %XFILIAL:SC6%
				AND SC6.C6_NUM = %Exp:_cPedido%
				AND SC6.%NotDel%
	
		EndSql	
	Else
	
		_nItem	:=	Val(_cItem)
	
		BEGINSQL ALIAS _cAlias

			SELECT COUNT(*) QTD
			FROM %Exp:Kt_BsDad%..cep_ctrl_amostra C
			INNER JOIN %Exp:Kt_BsDad%..cep_ctrl_amostra_itens I ON I.cca_codigo = C.cca_codigo
			AND I.id_itens = %Exp:_nItem%
			WHERE C.cca_seupedido = %Exp:_cPedido%
			AND cca_data_cancelamento IS NULL
	
		ENDSQL
	
	
	EndIf
	_lRet	:=  (_cAlias)->QTD == 0

	(_cAlias)->(DbCloseArea())
	
Return _lRet