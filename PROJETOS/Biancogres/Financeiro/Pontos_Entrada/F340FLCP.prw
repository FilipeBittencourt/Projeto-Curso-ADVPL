#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F340FLCP
@author Tiago Rossini Coradini
@since 06/12/2017
@version 1.0
@description Ponto de entrada que permite implementar uma expressão complementar no filtro de titulos na compensação a pagar 
@obs Ticket: 465 - Mikaelly Gentil
@type function
/*/

User Function F340FLCP()
Local cRet := ""

	If AllTrim(SE2->E2_TIPO) == "PA"
	
		cRet := " AND E2_NUMBOR = '' "
	
	Else
		
		If !Empty(SE2->E2_NUMBOR)
	
			cRet := " AND 0 = 1 "
			
		EndIf
	
	EndIf

Return(cRet)