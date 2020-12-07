#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0020; Return()

/*
|-----------------------------------------------------------|
| Classe: | TConsumoProdutoComum														|
| Autor:	| Tiago Rossini Coradini - Facile Sistemas			  |
| Data:		| 27/04/15																			  |
|-----------------------------------------------------------|
| Desc.:	|	Interface de historico consumo de produto comum |
|-----------------------------------------------------------|
| OS:			|	N/A - Usuário: Wanisay William 									|
|-----------------------------------------------------------|
*/


Class TIConsumoProdutoComum From LongClassName
	
	Data cEmp
	Data cData
	Data cPrd
	Data nQtdCon
	
	Method New() Constructor
	
EndClass


Method New() Class TIConsumoProdutoComum

	::cEmp := cEmpAnt
	::cData := dToS(dDataBase)
	::cPrd := Space(15)
	::nQtdCon := 0
		
Return()