#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"

/*/{Protheus.doc} FMO4TE02
@description O 4.0 Cadastro de Valores a serem Rateados
@author Fernando Rocha
@since 18/04/2020
@version 1.0
@type function
/*/
User Function FMO4TE02()

	Local aArea       := GetArea()
	Local oBrowse     := nil

	private aRotina   := fMenuDef()
	private cCadastro := "MO 4.0 Valores a serem Rateados no mês"

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZFC')
	oBrowse:SetDescription(cCadastro)
	oBrowse:Activate()

	RestArea(aArea)

Return

Static Function fMenuDef()

	local aRotina := {}
	aRotina := {{"Pesquisar"   	,"AxPesqui"   	, 0, 1},;
		{        "Visualizar"  	,"AxVisual" 	, 0, 2},;
		{        "Incluir"		,"AxInclui" 	, 0, 3},;
		{        "Alterar"		,"AxAltera" 	, 0, 4},;
		{        "Excluir"		,"AxDeleta" 	, 0, 5},;
		{        "Vlr.Real Mês"	,"U_FMO4VREA" 	, 0, 3},;
		{        "Vlr.Orcamento Ano"	,"U_FMO4VORC" 	, 0, 3}}

return aRotina


User Function FMO4VREA()

	Local oObj

	oObj := TMO40RateiosAuxiliares():New()
	oObj:ShowReal()

Return


User Function FMO4VORC()

	Local oObj

	oObj := TMO40RateiosAuxiliares():New()
	oObj:ShowOrc()

Return