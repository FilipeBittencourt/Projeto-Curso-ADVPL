#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} FMO4TE04
@description MO 4.0 Valores Auxiliares - Depreciação Realizada
@author Ranisses A. Corona
@since 31/01/2021
@version 1.0
@type function
/*/
User Function FMO4TE04()

	Local aArea       := GetArea()
	Local oBrowse     := nil

	private aRotina   := fMenuDef()
	private cCadastro := "MO 4.0 Valores Auxiliares - Depreciação Realizada"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZFF')
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