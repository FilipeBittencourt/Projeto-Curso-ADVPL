#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BFHCTE01
@author Gabriel Rossi Mafioletti
@since 11/11/2019
@version 1.0
@project Headcount
@description Tela para cadastro de Posições
@type function
/*/
User Function BFHCTE01()

	AXCADASTRO("ZLA", "Cadastro de Posições")

Return

User Function BHCTE1CD()

	Local _aArea	:=	GetArea()
	Local _cCodigo	:=	""
	Local _cAlias	:=	GetNextAlias()
	
	BeginSql Alias _cAlias
	
		SELECT ISNULL(MAX(SUBSTRING(ZLA_CODIGO,5,4)),'0000') CODIGO
		FROM %TABLE:ZLA%
		WHERE ZLA_FILIAL = %XFILIAL:ZLA%
			AND ZLA_CLVL = %Exp:M->ZLA_CLVL%
			AND %NotDel%
	EndSql

	_cCodigo	:=	ALLTRIM(M->ZLA_CLVL) + SOMA1((_cAlias)->CODIGO)

	(_cAlias)->(DbCloseArea())

	RestArea(_aArea)

Return _cCodigo