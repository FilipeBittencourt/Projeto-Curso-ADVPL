#INCLUDE "TOTVS.CH"

/*
|------------------------------------------------------------|
| Fun��o:	| MTA094RO														
| Autor:	|	Gabriel Rossi Mafioletti
| Data:		| 24/10/17																				 |
|------------------------------------------------------------|
| Desc.:	|	Ponto de entrada para adicionar rotinas no menu  |
| 				| de libera��o de Documentos
|------------------------------------------------------------|
|------------------------------------------------------------|
*/

User Function MTA094RO()
Local _aOpcs	:=	PARAMIXB[1]

	//aAdd(_aOpcs, {"Hist. Pre�o", "U_BIAF002('MATA094')", 0, 8, 0, .F.})
	aAdd(_aOpcs, {"E-Mail Informa��es", "U_BIAFG038()", 0, 8, 0, .F. })

Return(_aOpcs)