#include 'protheus.ch'

/*/{Protheus.doc} BIAFG133
@author Gabriel Rossi Mafioletti
@since 31/08/20
@version 1.0
@description Tela de Cadastro de Operações das Empresas Coligadas 
@type function
/*/


User Function BIAFG133()


	Local oBrowse := NIL
	Local _cTab	:=	"ZN2"

	
	PRIVATE cCadastro	:=	"Operações das Empresas Coligadas"

	DbSelectArea(_cTab)

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias(_cTab)
	oBrowse:SetDescription(cCadastro)


	oBrowse:Activate()


Return


Static Function Menudef()

	Local aRotina := {}
	aAdd( aRotina, { 'Pesquisar' , 'PesqBrw'         , 0, 1, 0, NIL } )
	aAdd( aRotina, { 'Visualizar', 'AxVisual', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir', 	'U_BFG133IN()', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar'   , 'U_BFG133AL()', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir'   , 'AxDeleta', 0, 5, 0, NIL } )


Return aRotina

User Function BFG133IN()

AxInclui("ZN2",ZN2->(Recno()),3,,,,"U_BFG133UN()")

Return


User Function BFG133AL()

AxAltera("ZN2",ZN2->(Recno()),4,,,,,"U_BFG133UN()")

Return


User Function BFG133UN()

	Local _cteste	:=	""
	Local _cAlias	:=	GetNextAlias()
	Local _nRecno	:=	ZN2->(Recno())
	Local _lret		:=	.T.
	
	If INCLUI
		BeginSql Alias _cAlias
			
			SELECT COUNT(*) QTD
			FROM %TABLE:ZN2%
			WHERE ZN2_FILIAL = %XFILIAL:ZN2%
				AND ZN2_EMPORI = %Exp:M->ZN2_EMPORI%
				AND ZN2_EMPDES = %Exp:M->ZN2_EMPDES%
				AND ZN2_TPPROD = %Exp:M->ZN2_TPPROD%
				AND %NotDel%
		
		EndSql
	ElseIf Altera
	
		BeginSql Alias _cAlias
			SELECT COUNT(*) QTD
			FROM %TABLE:ZN2%
			WHERE ZN2_FILIAL = %XFILIAL:ZN2%
				AND ZN2_EMPORI = %Exp:M->ZN2_EMPORI%
				AND ZN2_EMPDES = %Exp:M->ZN2_EMPDES%
				AND ZN2_TPPROD = %Exp:M->ZN2_TPPROD%
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
