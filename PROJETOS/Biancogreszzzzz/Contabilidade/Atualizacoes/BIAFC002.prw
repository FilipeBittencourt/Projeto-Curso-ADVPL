#INCLUDE "TOTVS.CH"

/*
|-----------------------------------------------------------|
| Função: | BIAFR003																			  |
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 18/11/14																			  |
|-----------------------------------------------------------|
| Desc.:	| Cadastro de parametros fiscais  			  				|	
|-----------------------------------------------------------|
| OS:			|	1747-12 - Usuário: Fabiana Aparecida Corona			|
| OS:			|	1743-14 - Usuário: Tania de Fatima Monico	 			|
| OS:			|	2138-12 - Usuário: Antonio Marcio   		 			  |
|-----------------------------------------------------------|
*/

User Function BIAFC002()
Private cCadastro := "Parametros Fiscais"
Private cDelFunc := ".T."
Private aRotina := {{"Pesquisar","AxPesqui",0,1},;
			             {"Visualizar","AxVisual",0,2},;
			             {"Incluir","AxInclui",0,3},;
			             {"Alterar","AxAltera",0,4},;
			             {"Excluir","AxDeleta",0,5}}
			             
										
	dbSelectArea("Z53")
	dbSetOrder(1)	

	mBrowse(6, 1, 22, 75, "Z53")
		
Return()