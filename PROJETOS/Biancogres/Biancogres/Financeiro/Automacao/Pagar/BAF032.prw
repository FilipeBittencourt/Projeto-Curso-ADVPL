#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF031
@author Tiago Rossini Coradini
@since 23/04/2019
@project Automação Financeira
@version 1.0
@description Rotina para tratamento de código da camara centralizadora
@type function
/*/

User Function BAF032()
Local aArea := GetArea()
Local cRet := "000"

	If SEA->EA_MODELO == "03"
	
		If SE2->E2_VALOR >= 5000
		
			cRet := "018"
		
		Else
		
			cRet := "700"
			
		EndIf

	ElseIf SEA->EA_MODELO $ "41/43"

		cRet := "018"	
		
	EndIf	

	RestArea(aArea)
	
Return(cRet)