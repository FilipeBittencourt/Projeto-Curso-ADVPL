#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA626
@author Marcos Alberto Soprani
@since 31/03/16
@version 1.0
@description Controle de Ajuste Diário de Produção
@obs Projeto Template INDUSTRIAL - SAP/BO 
@type function
/*/

User Function BIA626()

	dbSelectArea("Z76")
	dbGoTop()

	n := 1
	cCadastro := " ....: Ajuste Diário de Produção :.... "

	aRotina   := {  {"Pesquisar"   ,'AxPesqui'                             ,0, 1},;
	{                "Visualizar"  ,'AxVisual'                             ,0, 2},;
	{                "Incluir"     ,'AxInclui'                             ,0, 3},;
	{                "Alterar"     ,'AxAltera'                             ,0, 4},;
	{                "Excluir"     ,'AxDeleta'                             ,0, 5} }

	mBrowse(6,1,22,75, "Z76", , , , , ,)

Return
