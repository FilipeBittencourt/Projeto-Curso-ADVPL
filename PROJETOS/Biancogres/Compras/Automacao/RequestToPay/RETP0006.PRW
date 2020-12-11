#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function RETP0006(_cNum)
	
	Local aArea 		:= GetArea()
	Local lOk			:= .T.
	
	Begin Transaction
		
		lOk := U_RETP0004(_cNum)
		If (lOk)
			lOk := U_RETP0005(_cNum)
			If (!lOk)
				DisarmTransaction()
			EndIf
		Else
			DisarmTransaction()
		EndIf

	End Transaction 
	
	RestArea(aArea)
	
Return lOk