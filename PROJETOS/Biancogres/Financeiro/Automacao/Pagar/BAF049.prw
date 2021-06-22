#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF049
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Retorna Código de Barras - Cnab Banestes 
@type function
/*/

User Function BAF049()
Local cRet := ""

	If AllTrim(SE2->E2_CODBAR) <> ""
	
		cRet := AllTrim(SE2->E2_CODBAR) + Space(-(Len(AllTrim(SE2->E2_CODBAR)) -49))
		
	ElseIf AllTrim(SE2->E2_YLINDIG) <> ""
	
		cRet := AllTrim(SE2->E2_YLINDIG) + Space(-(Len(AllTrim(SE2->E2_YLINDIG)) -49))
		
	Else
		
		cRet := Space(49)
		
	EndIf
	
Return(cRet)	
