#include 'protheus.ch'

/*/{Protheus.doc} BIAFG131
@author Gabriel Rossi Mafioletti
@since 31/08/20
@version 1.0
@description Tela de Cadastro de Roteiro Consolidação/Expurgos
@type function
/*/

User Function BIAFG131()

	Local oBrowse := NIL
	Local _cTab	:=	"ZN0"

	PRIVATE cCadastro	:=	"Roteiro Consolidação/Expurgos"

	DbSelectArea(_cTab)

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias(_cTab)
	oBrowse:SetDescription(cCadastro)

	oBrowse:Activate()

Return

Static Function Menudef()

	Local aRotina := {}
	aAdd( aRotina, { 'Pesquisar' , 'PesqBrw'     , 0, 1, 0, NIL } )
	aAdd( aRotina, { 'Visualizar', 'AxVisual'    , 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir'   , 'U_BFG131IN()', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar'   , 'U_BFG131AL()', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir'   , 'AxDeleta'    , 0, 5, 0, NIL } )

Return aRotina

User Function BFG131IN()

	AxInclui("ZN0",ZN0->(Recno()),3,,,,"U_BFG131UN()")

Return

User Function BFG131AL()

	AxAltera("ZN0",ZN0->(Recno()),4,,,,,"U_BFG131UN()")

Return

User Function BFG131UN()

	Local _cAlias	:=	GetNextAlias()
	Local _nRecno	:=	ZN0->(Recno())
	Local _lret		:=	.T.

	If INCLUI

		BeginSql Alias _cAlias

			SELECT COUNT(*) QTD
			FROM %TABLE:ZN0%
			WHERE ZN0_FILIAL = %XFILIAL:ZN0%
			AND ZN0_CONTA = %Exp:M->ZN0_CONTA%
			AND ZN0_TIPO = %Exp:M->ZN0_TIPO%
			AND ZN0_TPPROD = %Exp:M->ZN0_TPPROD%
			AND %NotDel%

		EndSql

	ElseIf Altera

		BeginSql Alias _cAlias

			SELECT COUNT(*) QTD
			FROM %TABLE:ZN0%
			WHERE ZN0_FILIAL = %XFILIAL:ZN0%
			AND ZN0_CONTA = %Exp:M->ZN0_CONTA%
			AND ZN0_TIPO = %Exp:M->ZN0_TIPO%
			AND ZN0_TPPROD = %Exp:M->ZN0_TPPROD%
			AND R_E_C_N_O_ <> %Exp:_nrecno%
			AND %NotDel%

		EndSql

	EndIf

	If (_cAlias)->QTD > 0
		MsgInfo("Já existe um registro igual a esse gravado! Não será possível prosseguir!")
		_lret	:=	.F.
	EndIf

	(_cAlias)->(DbCloseArea())

Return _lret

User Function BFG131SQ()

	Local _cRet	:=	""
	Local _aArea	:=	GetArea()
	Local _cAlias	:=	GetNextAlias()

	BeginSql Alias _cAlias

		SELECT ISNULL(MAX(ZN0_SEQUEN),"000") SEQ
		FROM %TABLE:ZN0010%
		WHERE %NotDel%

	EndSql

	_cRet	:=	Soma1((_cAlias)->SEQ)

	(_cAlias)->(DbCloseArea())

	RestArea(_aArea)

Return _cRet
