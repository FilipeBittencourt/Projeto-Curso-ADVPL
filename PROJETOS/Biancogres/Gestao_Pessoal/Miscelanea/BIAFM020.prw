#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"

/*/{Protheus.doc} BIAFM020
@author Marcelo Sousa Correa
@since 21/05/2019
@version 1.0
@description Motivo Fatos Relevantes - Tela para cadastro de novos motivos
@type function
/*/

User Function BIAFM020()

	cCadastro := "Fatos Relevantes [Medidas Disciplinares]"
	aRotina   := { {"Pesquisar"     ,"AxPesqui"	  ,0,1},;
	{               "Visualizar"    ,"AxVisual"	  ,0,2},;
	{               "Incluir"       ,"AxInclui"	  ,0,3},;
	{               "Alterar"       ,"AxAltera"	  ,0,4},;
	{               "Excluir"       ,"AxDeleta"	  ,0,5}} 

	dbSelectArea("ZR5")
	dbSetOrder(1)
	dbGoTop()

	ZR5->(mBrowse(06,01,22,75,"ZR5"))

	dbSelectArea("ZR5")

Return
