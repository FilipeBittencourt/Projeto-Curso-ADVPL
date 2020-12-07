#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TICampoRubruca
@author Tiago Rossini Coradini
@since 20/01/2020
@version 1.0
@description Classe de Interface para tratamento dos campos referentes as Rubricas
@type class
/*/

Class TICampoRubruca From LongClassName

	Data cNome
	Data cDesc
	
	Method New() Constructor

EndClass


Method New() Class TICampoRubruca
	
	::cNome := ""
	::cDesc := ""
	
Return()