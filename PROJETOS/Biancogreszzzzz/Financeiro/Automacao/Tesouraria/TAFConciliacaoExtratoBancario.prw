#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFConciliacaoExtratoBancario
@author Tiago Rossini Coradini
@since 04/04/2019
@project Automação Financeira
@version 1.0
@description Classe para efetuar conciliacao de extratos bancarios
@type class
/*/

Class TAFConciliacaoExtratoBancario From TAFAbstractClass
	
	Method New() Constructor

EndClass


Method New() Class TAFConciliacaoExtratoBancario
	
	_Super:New()

Return()