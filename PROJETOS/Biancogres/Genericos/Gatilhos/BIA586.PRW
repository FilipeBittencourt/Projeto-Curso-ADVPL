#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
|-----------------------------------------------------------|
| Funcao: 	| BIA586										|
| Autor:	| Luana Marin Ribeiro							|
| Data:		| 01/08/16										|
|-----------------------------------------------------------|
| Desc.:	| Valida alteração do campo CATEGORIA (A1_YCAT) |
|  			| Cadastro de cliente - Bloqueio de permissão 	|
|-----------------------------------------------------------|
| OS:		| 2081-16										|
|-----------------------------------------------------------|
*/

User Function BIA586()
Local lRet := .T.

	If (ALTERA .AND. U_VALOPER("031", .F.))
		lRet := .F.
	EndIf
	
Return(lRet)