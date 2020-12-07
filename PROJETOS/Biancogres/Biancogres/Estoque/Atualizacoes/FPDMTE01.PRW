#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FPDMTE01
@description Tela de Cadastro do PDM
@author Fernando Rocha
@since 07/08/2018
@version 1.0
@type function
/*/
User function FPDMTE01()

	Local aArea       := GetArea()
	Local oBrowse     := nil

	private aRotina   := fMenuDef()
	private cCadastro := "PDM - Padrão de Descrição de Materiais"    

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZD0')
	oBrowse:SetDescription(cCadastro)
	oBrowse:Activate()

	RestArea(aArea)

Return   

Static Function fMenuDef()

	local aRotina := {} 
	aRotina := {{"Pesquisar"   	,"AxPesqui"   , 0, 1},;     
	{            "Visualizar"  	,"U_PDMT01MN" , 0, 2},; 
	{            "Incluir"		,"U_PDMT01MN" , 0, 3},;
	{            "Alterar"		,"U_PDMT01MN" , 0, 4},;
	{            "Excluir"		,"U_PDMT01MN" , 0, 5}}	

return aRotina

Public __oTELA_PDM

User Function PDMT01MN(cAlias,nReg,nOpc)

	__oTELA_PDM := TPDMCadastro():New()

	__oTELA_PDM:Show(nOpc)

Return