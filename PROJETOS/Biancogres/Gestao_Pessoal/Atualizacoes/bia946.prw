#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"

/*/{Protheus.doc} BIA946
@author Marcos Alberto Soprani
@since 08/02/18
@version 1.0
@description Fatos Relevantes - Originalmente GPEA922 - retirado pela totvs do padrão na versão 12
@type function
/*/

User Function BIA946()

	cCadastro := "Fatos Relevantes [Medidas Disciplinares]"
	aRotina   := { {"Pesquisar"     ,"AxPesqui"	  ,0,1},;
	{               "Visualizar"    ,"AxVisual"	  ,0,2},;
	{               "Incluir"       ,"AxInclui"	  ,0,3},;
	{               "Alterar"       ,"AxAltera"	  ,0,4},;
	{               "Excluir"       ,"AxDeleta"	  ,0,5},; 
	{               "Motivo Fato"   ,"U_BIAFM020"	  ,0,6} }

	dbSelectArea("RAE")
	dbSetOrder(1)
	dbGoTop()

	RAE->(mBrowse(06,01,22,75,"RAE"))

	dbSelectArea("RAE")

Return
