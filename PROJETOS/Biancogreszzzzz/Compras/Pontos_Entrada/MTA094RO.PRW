#INCLUDE "TOTVS.CH"

/*
|------------------------------------------------------------|
| Função:	| MTA094RO														
| Autor:	|	Gabriel Rossi Mafioletti
| Data:		| 24/10/17																				 |
|------------------------------------------------------------|
| Desc.:	|	Ponto de entrada para adicionar rotinas no menu  |
| 				| de liberação de Documentos
|------------------------------------------------------------|
|------------------------------------------------------------|
*/

User Function MTA094RO()
Local _aOpcs	:=	PARAMIXB[1]

	//aAdd(_aOpcs, {"Hist. Preço", "U_BIAF002('MATA094')", 0, 8, 0, .F.})
	aAdd(_aOpcs, {"E-Mail Informações", "U_BIAFG038()", 0, 8, 0, .F. })

Return(_aOpcs)