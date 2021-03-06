#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} BIA676
@author Marcos Alberto Soprani
@since 23/04/21
@version 1.0
@description Tela de Manuten��o Aliquotas extraordin�rias para c�lculo de Rubricas - GMT
@Obs Projeto A-59
@type function
/*/

User Function BIA676()

	Local aArea := ZN7->(GetArea())
	Private oBrowse
	Private cChaveAux := ""
	Private cCadastro := "Aliquotas para Gest�o Matricial de Tributos"
	Private msEnter   := CHR(13) + CHR(10)

	aRotina   := { {"Pesquisar"       ,"AxPesqui"	                        ,0,1},;
	{               "Visualizar"      ,"AxVisual"	                        ,0,2},;
	{               "Incluir"         ,"AxInclui"	                        ,0,3},;
	{               "Alterar"         ,"AxAltera"	                        ,0,4},;
	{               "Excluir"         ,"AxDeleta"	                        ,0,5} }

	//Iniciamos a constru��o b�sica de um Browse.
	oBrowse := FWMBrowse():New()

	//Definimos a tabela que ser� exibida na Browse utilizando o m�todo SetAlias
	oBrowse:SetAlias("ZN7")

	//Definimos o t�tulo que ser� exibido como m�todo SetDescription
	oBrowse:SetDescription(cCadastro)

	//Adiciona um filtro ao browse
	//oBrowse:SetFilterDefault( " informe o filtro aqui" )

	//Ativamos a classe
	oBrowse:Activate()
	RestArea(aArea)

Return
