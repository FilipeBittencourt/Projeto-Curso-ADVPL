#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF069
@author Tiago Rossini Coradini
@since 10/02/2017
@version 1.0
@description Retorna digito da conta corrente do Bradesco por empresa 
@obs OS: 3663-16 - Vagner Amaro
@type function
/*/

User Function BIAF069()
Local aArea := GetArea()
Local cRet := ""

	If SM0->M0_CODIGO == "01"
	
		cRet := "6"
	
	ElseIf SM0->M0_CODIGO == "05"
	
		cRet := "9"
	
	ElseIf SM0->M0_CODIGO == "07"
	
		cRet := "5"
	
	EndIf
		
	RestArea(aArea)
		
Return(cRet)