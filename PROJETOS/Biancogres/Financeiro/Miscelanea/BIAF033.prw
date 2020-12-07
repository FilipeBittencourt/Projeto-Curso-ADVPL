#INCLUDE "TOTVS.CH"

/*
|-----------------------------------------------------------|
| Funcao: | BIAF033											|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas		|
| Data:		| 02/05/16										|
|-----------------------------------------------------------|
| Desc.:	| Consulta de credito do cliente via site do ccb|
|-----------------------------------------------------------|
| OS:			|	4647-15 - Vagner Amaro					|
|-----------------------------------------------------------|
*/

User Function BIAF033(cCodigo, cLoja)
Local oWObj := Nil

	// Tiago Rossini Coradini - 24/05/16 - OS: 1872-16 - Elimonda Moura - Liberar acesso a Consulta CCB somente para os usuario do financeiro
	If U_ValOper("029", .T.)

		// Cria consulta de cliente via CCB
		oWObj := TWConsultaClienteCCB():New(cCodigo, cLoja)
		
		oWObj:Activate()
		
	EndIf
		
Return()