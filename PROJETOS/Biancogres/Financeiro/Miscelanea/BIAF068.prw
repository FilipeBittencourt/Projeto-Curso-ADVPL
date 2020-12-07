#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF068
@author Tiago Rossini Coradini
@since 10/02/2017
@version 1.0
@description Retorna conta corrente do Bradesco por empresa 
@obs OS: 3663-16 - Vagner Amaro
@type function
/*/

User Function BIAF068()
Local aArea := GetArea()
Local cRet := ""

	If SM0->M0_CODIGO == "01"
	
		cRet := "0010599"
	
	ElseIf SM0->M0_CODIGO == "05"
	
		cRet := "0010835"
		
	ElseIf SM0->M0_CODIGO == "07"
	
		cRet := "0000955"
			
	EndIf
		
	RestArea(aArea)
		
Return(cRet)