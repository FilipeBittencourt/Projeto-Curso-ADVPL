#INCLUDE "TOTVS.CH"

User Function FCLA0012; Return()

/*
|------------------------------------------------------------|
| Classe:	| TWPesquisaPrecoProduto													 |
| Autor:	|	Tiago Rossini Coradini - Facile Sistemas				 |
| Data:		| 12/08/15																				 |
|------------------------------------------------------------|
| Desc.:	|	Interface de pesquisa de precos de produtos			 |
|------------------------------------------------------------|
| OS:			|	0069-15 - Usuário: Claudia Carvalho   		 			 |
|------------------------------------------------------------|
*/

Class TIPesquisaPrecoProduto From LongClassName

	Data cCodPrd
	Data cDesPrd
	Data nPrcCom
	Data nVlrFrt
	Data dDtVig
	Data cCodFor
	Data cLojFor
	Data cNomFor
	Data cConPag
	
	Method New() Constructor
	
EndClass


Method New() Class TIPesquisaPrecoProduto

	::cCodPrd := ""
	::cDesPrd := ""
	::nPrcCom := 0
	::nVlrFrt := 0
	::dDtVig := dDataBase
	::cCodFor := ""
	::cLojFor := ""
	::cNomFor := ""
	::cConPag := ""
		
Return()