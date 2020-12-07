#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFAbstractClass
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Classe base para as demais classes
@type class
/*/

Class TAFAbstractClass From LongClassName
	
	Data oPro // Objeto Gestor de Processos
	Data oLog // Objeto de Log
	Data oLst // Objeto com a lista titulos a Processar	
	
	Method New() Constructor
	
EndClass


Method New() Class TAFAbstractClass

	::oPro := TAFProcess():New()
	::oLog := TAFLog():New()
	::oLst := ArrayList():New()
	
Return()