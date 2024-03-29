#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFG068
@author Gabriel Rossi Mafioletti
@since 03/10/2018
@version 1.0
@description Tela de Cadastro de Armaz�m x Produto
@type function
/*/

User Function BIAFG068()

	AxCadastro("ZCN","Produto x Armaz�m",, "U_BFG68IN()")
Return


User Function BFG68IN()

	Local _lRet	:=	.T.
	Local _cAlias	:=	GetNextALias()
	Local _nRec	:=	ZCN->(Recno())
	Local _oMd	:=	tBiaControleMD():New()
	
	
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
		MsgInfo("Registro j� Cadastrado (Produto/Sequ�ncia)!")
	EndIf
	
	(_cAlias)->(DbCloseArea())

	If ZCN->ZCN_POLIT == '4' .AND. M->ZCN_POLIT <> '4'
	
		_oMd:ZeraMd(M->ZCN_COD,M->ZCN_LOCAL)
	
	EndIf
Return _lRet