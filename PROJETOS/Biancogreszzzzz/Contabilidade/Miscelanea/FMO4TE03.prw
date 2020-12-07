#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} FMO4TE03
@description O 4.0 Cadastro de Valores Auxiliares RAC
@author Fernando Rocha
@since 18/04/2020
@version 1.0
@type function
/*/
User Function FMO4TE03()

	Local aArea       := GetArea()
	Local oBrowse     := nil

	private aRotina   := fMenuDef()
	private cCadastro := "MO 4.0 Valores Auxiliares que virão da RAC"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZFE')
	oBrowse:SetDescription(cCadastro)
	oBrowse:Activate()

	RestArea(aArea)

Return   

Static Function fMenuDef()

	local aRotina := {} 
	aRotina := {{"Pesquisar"   	,"AxPesqui"   , 0, 1},;     
	{            "Visualizar"  	,"AxVisual" , 0, 2},; 
	{            "Incluir"		,"AxInclui" , 0, 3},;
	{            "Alterar"		,"AxAltera" , 0, 4},;
	{            "Excluir"		,"AxDeleta" , 0, 5}}	

return aRotina