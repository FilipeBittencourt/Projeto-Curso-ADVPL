#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------|
| Fun��o: 	| MATA061										|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas		|
| Data:		| 30/07/15										|
|-----------------------------------------------------------|
| Desc.:	|	Ponto de entrada padrao MVC na tabela SA5 	|
|			|	Amarra��o Produto X Fornecedor				|
|			|	utilizado para atualizar as informa��es da  |
|			|	tabela de preco 							|
|-----------------------------------------------------------|
| OS:		|	2859-15 - Usu�rio: Claudia Carvalho			|
|-----------------------------------------------------------|

|-----------------------------------------------------------|
| Fun��o: 	| MATA061										|
| Autor:	| Thiago Haagensen  							|
| Data:		| 10/01/19										|
|-----------------------------------------------------------|
| Desc.:	| Ponto de entrada ap�s a grava��o dos dadosna	|
|			| tabela SA5 - Amarra��o Produto X Fornecedor	|
|			| utilizado para manipular as  informa��es		|
|			| ap�s a grava��o dos dados.					|
|-----------------------------------------------------------|
| TICKET:	| 21335 - Solicitante: Tiago Fagundes da Silva	|
|-----------------------------------------------------------|
*/

User Function MATA061()
Local aArea := GetArea()
Local xRet := .T.
Local aParam := ParamIxb
Local oObj := Nil
Local cIdPonto := Nil
Local cIdModel := Nil

	If aParam <> NIL	
		
		oObj := aParam[1]
	  	cIdPonto := aParam[2]
	   	cIdModel := aParam[3]   	
		
	   	If cIdPonto $ 'MODELCANCEL|FORMCOMMITTTSPRE'
			
	   		// Tiago Rossini Coradini - 14/12/2016 - OS: 2859-16 - Claudia Carvalho
	   		U_BIAF057(SA5->A5_PRODUTO)
	   		
	   		// Tiago Rossini Coradini - 19/12/2016 - OS: 4540-16 - Jesebel Brandao
	   		U_BIAF058(SA5->A5_PRODUTO)
	   		
	   	ElseIf cIdPonto $ 'FORMCOMMITTTSPOS'
	   		// Thiago Haagensen - 10/01/2020 - 21335 - Solicitante: Tiago Fagundes da Silva
	   		U_BIATH001()
	   	  	  	
					
		EndIf
		
	EndIf
		
	RestArea(aArea)
	
Return(xRet)