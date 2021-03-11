#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA675
@author Marcos Alberto Soprani
@since 03/03/21
@version 1.0
@description Cadastro de Totalizadores para Visão Gerencial
@type function
/*/

User Function BIA675()

	Local aArea := ZN5->(GetArea())
	Private oBrowse
	Private cChaveAux := ""
	Private cCadastro := "Totalizadores para Visão Gerencial"

	aRotina   := { {"Pesquisar"       ,"AxPesqui"	                        ,0,1},;
	{               "Visualizar"      ,"AxVisual"	                        ,0,2},;
	{               "Incluir"         ,"AxInclui"	                        ,0,3},;
	{               "Alterar"         ,"AxAltera"	                        ,0,4},;
	{               "Excluir"         ,"AxDeleta"	                        ,0,5} }

	//Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("ZN5")

	//Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription(cCadastro)

	//Adiciona um filtro ao browse
	oBrowse:SetFilterDefault( "1 == 1" )

	//Ativamos a classe
	oBrowse:Activate()
	RestArea(aArea)

Return
