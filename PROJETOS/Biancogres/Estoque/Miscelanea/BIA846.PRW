#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA846
@author Ranisses A. Corona
@since 30/09/11
@version 1.0
@description Cadastro de Colaboradores PreRequisicao
@type function
/*/

User Function BIA846()

	AxCadastro("ZZY", "Colaboradores Pre-Requisição", "U_BIA846EX()", "U_BIA846IN()")

Return

User Function BIA846XX()

	Local _aArea	:=	GetArea()
	Local _cAlias	:=	GetNextAlias()
	Local _cMat		:=	""

	BeginSql Alias _cAlias

		SELECT ISNULL(SUBSTRING(MAX(ZZY_MATRIC), 3, 6), '000000') MAT
		FROM %TABLE:ZZY%
		WHERE ZZY_MATRIC LIKE 'XX%'
		AND ZZY_FILIAL = %XFILIAL:ZZY%
		AND %NOTDEL%

	EndSql

	_cMat	:=	'XX' + SOMA1((_cAlias)->MAT)

	(_cAlias)->(DbCloseArea())

	RestArea(_aArea)

Return _cMat

User Function BIA846EX()

	Local _lRet	:=	.T.

	If SUBSTR(ZZY->ZZY_MATRIC,1,2) == 'XX'

		_lRet	:=	.F.
		MsgInfo("Matrículas iniciadas com XX não poderão ser Excluídas!", "BIA846")

	EndIf

Return _lRet

User Function BIA846IN()

	Local _lRet	:=	.T.

	If INCLUI .AND. !SUBSTR(M->ZZY_MATRIC,1,2) == 'XX'

		_lRet	:=	.F.
		MsgInfo("Somente poderão ser incluídas matrículas que iniciem com XX!", "BIA846")

	EndIf

Return _lRet
