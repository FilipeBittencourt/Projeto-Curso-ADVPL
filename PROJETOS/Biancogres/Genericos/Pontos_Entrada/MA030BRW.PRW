#include "rwMake.ch"
#include "Topconn.ch"


User Function MA030BRW()

	Local oAceTela 	:= TAcessoTelemarketing():New()
	Local cFiltro	:= ""
	
	If (oAceTela:UserTelemaketing())
		cFiltro := oAceTela:FiltroSA1()	
	EndIf	

Return cFiltro