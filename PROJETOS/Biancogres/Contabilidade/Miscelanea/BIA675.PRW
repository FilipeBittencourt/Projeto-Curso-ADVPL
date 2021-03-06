#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA675
@author Marcos Alberto Soprani
@since 03/03/21
@version 1.0
@description Cadastro de Totalizadores para Vis�o Gerencial
@type function
/*/

User Function BIA675()

	Local aArea := ZN5->(GetArea())
	Private oBrowse
	Private cChaveAux := ""
	Private cCadastro := "Totalizadores para Vis�o Gerencial"

	aRotina   := { {"Pesquisar"       ,"AxPesqui"	                        ,0,1},;
	{               "Visualizar"      ,"AxVisual"	                        ,0,2},;
	{               "Incluir"         ,"AxInclui"	                        ,0,3},;
	{               "Alterar"         ,"AxAltera"	                        ,0,4},;
	{               "Excluir"         ,"AxDeleta"	                        ,0,5} }

	//Iniciamos a constru��o b�sica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
	oBrowse:SetAlias("ZN5")

	//Definimos o t�tulo que ser� exibido como m�todo SetDescription
	oBrowse:SetDescription(cCadastro)

	//Adiciona um filtro ao browse
	//oBrowse:SetFilterDefault( "1 == 1" )

	//Ativamos a classe
	oBrowse:Activate()
	RestArea(aArea)

Return
