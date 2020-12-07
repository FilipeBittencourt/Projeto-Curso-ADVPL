#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFG068
@author Gabriel Rossi Mafioletti
@since 03/10/2018
@version 1.0
@description Tela de Cadastro de Armazém x Produto
@type function
/*/

User Function BIAFG068()

	AxCadastro("ZCN","Produto x Armazém",, "U_BFG68IN()")
Return


User Function BFG68IN()

	Local _lRet	:=	.T.
	Local _cAlias	:=	GetNextALias()
	Local _nRec	:=	ZCN->(Recno())
	
	If Inclui
		BEGINSQL Alias _cAlias
		
			SELECT COUNT(*) QTD
				FROM %TABLE:ZCN%
				WHERE ZCN_FILIAL = %XFILIAL:ZCN%
					AND ZCN_COD = %EXP:M->ZCN_COD%
					AND ZCN_SEQUEN = %Exp:M->ZCN_SEQUEN%
					AND %NotDel%
		
		EndSql
		
	ElseIf Altera
		
		BEGINSQL Alias _cAlias
		
			SELECT COUNT(*) QTD
				FROM %TABLE:ZCN%
				WHERE ZCN_FILIAL = %XFILIAL:ZCN%
					AND ZCN_COD = %EXP:M->ZCN_COD%
					AND ZCN_SEQUEN = %Exp:M->ZCN_SEQUEN%
					AND R_E_C_N_O_ <> %Exp:_nRec%
					AND %NotDel%
		
		EndSql

	EndIf

	_lRet	:=	(_cAlias)->QTD == 0
	
	If !_lRet
		MsgInfo("Registro já Cadastrado (Produto/Sequência)!")
	EndIf
	
	(_cAlias)->(DbCloseArea())

Return _lRet