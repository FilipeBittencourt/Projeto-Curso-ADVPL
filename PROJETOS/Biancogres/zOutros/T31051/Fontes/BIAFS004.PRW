#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} BIAFS004
Cadastro UF x % Seguro
@author Emerson Salvador
@since  26/07/2021
@version 1.0
@type function
/*/
User Function BIAFS004()

	Local aArea       := GetArea()
	Local oBrowse

	private aRotina   := FMenuDef()
	private cCadastro := "Cadastro UF x % Seguro Fabrica"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZG8')
	oBrowse:SetDescription(cCadastro)
	oBrowse:Activate()

	RestArea(aArea)

Return

//--------------------------
Static Function FMenuDef()
//--------------------------

	Local aRotina := {}

	aRotina := {{"Pesquisar"   	,"AxPesqui"   , 0, 1},;
		{            "Visualizar"  	,"AxVisual" , 0, 2},;
		{            "Incluir"		,"AxInclui" , 0, 3},;
		{            "Alterar"		,"AxAltera" , 0, 4},;
		{            "Excluir"		,"AxDeleta" , 0, 5}}

return aRotina
