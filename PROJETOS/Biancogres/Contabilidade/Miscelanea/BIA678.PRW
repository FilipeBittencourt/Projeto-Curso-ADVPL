#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA678
@author Marcos Alberto Soprani
@since 09/04/21
@version 1.0
@description Tela de Manutenção para Gestão Matricial de Tributos
@Obs Projeto A-59
@type function
/*/

User Function BIA678()

	Local aArea := ZN6->(GetArea())
	Private oBrowse
	Private cChaveAux := ""
	Private cCadastro := "Gestão Matricial de Tributos"
	Private msEnter   := CHR(13) + CHR(10)

	aRotina   := { {"Pesquisar"       ,"AxPesqui"                          ,0,1},;
	{               "Visualizar"      ,"AxVisual"                          ,0,2},;
	{               "Incluir"         ,"AxInclui"                          ,0,3},;
	{               "Alterar"         ,"AxAltera"                          ,0,4},;
	{               "Excluir"         ,"AxDeleta"                          ,0,5},;
	{               "Extrair"         ,"U_BIA694()"                        ,0,3} }

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("ZN6")

	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cCadastro)

	//Adiciona um filtro ao browse
	oBrowse:SetFilterDefault( "ZN6_TIPO1 = 'M'" )

	//Ativamos a classe
	oBrowse:Activate()
	RestArea(aArea)

Return
