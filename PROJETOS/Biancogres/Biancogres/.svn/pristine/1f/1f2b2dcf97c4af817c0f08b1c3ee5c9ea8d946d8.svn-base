#include "PROTHEUS.CH"

User Function BIAFPH09()

	Local cMat		:= ""
	Local aArea		:= GetArea()
	Local aAllUsers := FWSFALLUSERS({__cUserID}, {'USR_CODFUNC'})
	
	If (Len(aAllUsers) > 0)
		If (Len(aAllUsers[1]) > 0)
			cMat := aAllUsers[1][3]
		EndIf
	EndIf
	
	If (!Empty(cMat))
		DbSelectArea("ZZY")
		ZZY->(DbSetOrder(3))
		If ZZY->(DbSeek(xFilial("ZZY")+cEmpAnt+cValTochar(cMat)))
			cMat := ZZY->ZZY_MATRIC
		EndIf
	EndIf
	
	RestArea(aArea)
	
Return cMat