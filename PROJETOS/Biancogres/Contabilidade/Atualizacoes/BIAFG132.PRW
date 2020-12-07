#include 'protheus.ch'

/*/{Protheus.doc} BIAFG132
@author Gabriel Rossi Mafioletti
@since 31/08/20
@version 1.0
@description Tela de Cadastro de Empresas Coligadas 
@type function
/*/


User Function BIAFG132()


	Local oBrowse := NIL
	Local _cTab	:=	"ZN1"

	
	PRIVATE cCadastro	:=	"Empresas Coligadas"

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
	aAdd( aRotina, { 'Incluir', 	'AxInclui', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar'   , 'AxAltera', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir'   , 'AxDeleta', 0, 5, 0, NIL } )


Return aRotina


User Function BFG132CF()

	Local _lret	:=	.T.
	
	If M->ZN1_CODCLI == M->ZN1_CODFOR .And. !Empty(M->ZN1_CODCLI) .And. !Empty(M->ZN1_CODFOR)
		MsgAlert("Os Códigos de Cliente e Fornecedor devem ser diferentes!","BIAFG132")
		_lret	:=	.F.
	EndIf
Return _lRet