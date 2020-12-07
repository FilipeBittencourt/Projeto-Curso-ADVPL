#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0033; Return()

/*
|-----------------------------------------------------------|
| Classe: | TIMovimentoInternoEPI														|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 25/05/16																			  |
|-----------------------------------------------------------|
| Desc.:	|	Interface com as infromacoes da movimentação 		|
| 				|	interna (SD3) de EPI 														|
|-----------------------------------------------------------|
| OS:			|	1130-16 - Carlos Junqueira											|
|-----------------------------------------------------------|
*/


Class TIMovimentoInternoEPI From LongClassName
	
	Data cCodEPI // Codigo do EPI
	Data nQtdEnt // Quantidade Entregue
	Data nCusMed // Custo Medio
	Data cNumSeq // Numero sequencial do SD3
	Data lRegUtl // Verifica se registro ja foi utilizado
	
	Method New() Constructor
	
EndClass


Method New() Class TIMovimentoInternoEPI

	::cCodEPI := ""
	::nQtdEnt := 0
	::nCusMed := 0
	::cNumSeq := ""
	::lRegUtl := .F.
		
Return()