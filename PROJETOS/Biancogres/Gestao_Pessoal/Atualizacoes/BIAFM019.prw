#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"

/*/{Protheus.doc} BIAFM019
@author Marcelo Sousa Correa
@since 16/05/19
@version 1.0
@description Cadastro dos Motivos de Fato relevante utilizado no cadastro dos fatos 
@type function
/*/

User Function BIAFM019()

	cCadastro := "Cadastro Motivo Fato [Fatos Relevantes]"
	aRotina   := { {"Pesquisar"     ,"AxPesqui"	  ,0,1},;
	{               "Visualizar"    ,"AxVisual"	  ,0,2},;
	{               "Incluir"       ,"AxInclui"	  ,0,3},;
	{               "Alterar"       ,"AxAltera"	  ,0,4},;
	{               "Excluir"       ,"AxDeleta"	  ,0,5} }

	dbSelectArea("ZR5")
	dbSetOrder(1)
	dbGoTop()

	ZR5->(mBrowse(06,01,22,75,"ZR5"))

	dbSelectArea("ZR5")

Return
