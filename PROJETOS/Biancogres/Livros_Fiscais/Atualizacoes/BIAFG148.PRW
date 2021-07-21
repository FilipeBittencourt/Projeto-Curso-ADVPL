#include "rwmake.ch"

/*/{Protheus.doc} BIAFG148
@author Gabriel Rossi Mafioletti
@since 21/06/21
@version 1.1
@description IMPORTACAO DA TABELA IBPT POR ENTE TRIBUTAÇÃO   
@type function
/*/                                                                                               

User Function BIAFG148()

Local	oBrw := FWmBrowse():New()

	oBrw := FWMBrowse():New()
	oBrw:SetAlias("CLK")
	oBrw:SetMenuDef('BIAFG148')
	oBrw:SetDescription("Cadastro da Tabela IBPT") //Cadastro da Tabela IBPT
	oBrw:Activate()


Return()

Static Function Menudef()

	Local aRotina	:=	{}

	aAdd(aRotina, {"Pesquisar"       , "PesqBrw"   , 0, 1})
	aAdd(aRotina, {"Visualizar"      , "AxVisual"  , 0, 2})
	aAdd(aRotina, {"Incluir"         , "AxInclui"  , 0, 3})
	aAdd(aRotina, {"Alterar"         , "AxAltera"  , 0, 4})
	aAdd(aRotina, {"Excluir"         , "AxDeleta"  , 0, 5})
	aAdd(aRotina, {"Importar"  , "U_BFG148A" , 0, 3})


Return aRotina



User Function BFG148A()

	ImpIBPT()
	
	U_BIAFG146()

Return