#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA698
@author Marcos Alberto Soprani
@since 08/07/21
@version 1.0
@description Kardex Ajustado para RAC
@type function
@Obs Projeto A-62 - Custeio Jazidas. poderá ser aproveitado pelo Biancogres para efeito de C1
/*/

User Function BIA698()

	Local aArea := ZN9->(GetArea())
	Private oBrowse
	Private cChaveAux := ""
	Private cCadastro := "Kardex Ajustado para RAC"
	Private msEnter   := CHR(13) + CHR(10)

	aRotina   := { {"Pesquisar"       ,"AxPesqui"                          ,0,1},;
	{               "Visualizar"      ,"AxVisual"                          ,0,2},;
	{               "Incluir"         ,"AxInclui"                          ,0,3},;
	{               "Alterar"         ,"AxAltera"                          ,0,4},;
	{               "Excluir"         ,"AxDeleta"                          ,0,5} }

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("ZN9")

	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cCadastro)

	//Adiciona um filtro ao browse
	//oBrowse:SetFilterDefault( "ZN6_TIPO1 = 'M'" )

	//Ativamos a classe
	oBrowse:Activate()
	RestArea(aArea)

Return
