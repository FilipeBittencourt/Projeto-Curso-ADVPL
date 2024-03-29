#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF040
@author Marcos Alberto Soprani
@since 20/12/16
@version 1.0
@description Cadastro de Justificativa p/ Baixa Produ��o
@obs Projeto Template INDUSTRIAL - SAP/BO 
@type function
/*/

User Function BIA232()

	Local aArea     := GetArea()
	Local cCondicao := ""

	Private cCadastro 	:= "Justificativa p/ Baixa Produ��o"
	Private aRotina 	:= { {"Pesquisar"  			,"AxPesqui"     ,0,1},;
	{                         "Visualizar"			,"AxVisual"     ,0,2},;
	{                         "Incluir"   			,"U_B232INC"    ,0,3},;
	{                         "Alterar"   			,"U_B232ALT"    ,0,4},;
	{                         "Excluir"             ,"AxDeleta"     ,0,2} }

	dbSelectArea("Z83")
	dbSetOrder(1)

	mBrowse(6,1,22,75,"Z83",,,,,,)

Return

/*___________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun�ao    � B232INC  � Autor � Marcos Alberto S      � Data � 20/12/16 ���
��+----------+------------------------------------------------------------���
���Descri��o � Rotina de Inclus�o                                         ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function B232INC()

	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local nOpcao	:= 0
	Local cAlias	:= "Z83"

	nOpcao := AxInclui(cAlias)

	RestArea(aArea)

Return lRet

/*___________________________________________________________________________
�����������������������������������������������������������������������������
��+-----------------------------------------------------------------------+��
���Fun�ao    � B232ALT  � Autor � Marcos Alberto S      � Data � 20/12/16 ���
��+----------+------------------------------------------------------------���
���Descri��o � Rotina de Altera��o                                        ���
��+-----------------------------------------------------------------------+��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function B232ALT()

	Local lRet		 := .T.
	Local aArea		 := GetArea()
	Local nOpcao	 := 0

	nOpcao := AxAltera("Z83",Z83->(Recno()),4,,,,,,,,,,,,.T.,,,,,)

	RestArea(aArea)

Return lRet
