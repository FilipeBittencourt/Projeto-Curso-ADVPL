#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------|
| Função: | F060SITUAC									    |
| Autor:  | Tiago Rossini Coradini - Facile Sistemas	    |
| Data:	  | 05/05/15									    |
|-----------------------------------------------------------|
| Desc.:  | Ponto de entrada para adicionar novas carteiras |
|		  | de cobrança. 									|
| Desc.:  | Referência tabela 07 - Situações de Cobranças 	|
|-----------------------------------------------------------|
| OS:	  |	1307-15, 1308-15 - Usuário: Vagner Salles		|
|-----------------------------------------------------------|
*/

User Function F060SITUAC()
Local aSituacoes := ParamIxb

//	Add(aSituacoes, "L Creditos Incobraveis")
	
Return(aSituacoes)