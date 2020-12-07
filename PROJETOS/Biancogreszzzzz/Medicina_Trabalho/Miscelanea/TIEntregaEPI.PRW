#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0032; Return()

/*
|-----------------------------------------------------------|
| Classe: | TIEntregaEPI																		|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 28/03/16																			  |
|-----------------------------------------------------------|
| Desc.:	|	Interface para geração automatica de entrega de |
| 				|	EPI ao efetuar baixa da pré-requisição  				|
|-----------------------------------------------------------|
| OS:			|	1130-16 - Carlos Junqueira											|
|-----------------------------------------------------------|
*/


Class TIEntregaEPI From LongClassName
	
	Data cMatFun // Matricula do Funcaionario
	Data cCodFun // Codigo da Funcao do Funcionario
	Data cCodEPI // Codido do EPI
	Data cCodFor // Codigo do Fornecedor
	Data cLojFor // Loja do Fornecedor
	Data nQtdEnt // Quantidade Entregue
	Data cNumLoc // Almoxarifado
	Data cNumCA // Numero do CA
	Data cMotEnt // Motivo de Entrega
	
	Method New() Constructor
	
EndClass


Method New() Class TIEntregaEPI

	::cMatFun := ""
	::cCodFun := ""
	::cCodEPI := ""
	::cCodFor := ""
	::cLojFor := ""
	::nQtdEnt := 0
	::cNumLoc := ""
	::cNumCA := ""
	::cMotEnt := ""
		
Return()