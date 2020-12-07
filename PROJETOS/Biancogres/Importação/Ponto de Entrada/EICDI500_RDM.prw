#include 'protheus.ch'
#include "rwmake.ch"


User Function EICDI500_RDM()
Local aArea := GetArea()
Local cContrato := ""
Local cClvl := ""
Local cItemCta := ""
Local cSubItem := ""
	
	If SWD->(FieldPos("WD_YCONTR")) > 0 .And. SWD->(FieldPos("WD_YCLVL")) > 0 .And. SWD->(FieldPos("WD_YITEMCT")) > 0 .And. SWD->(FieldPos("WD_YSUBITE")) > 0
	
		If ParamIXB == "DESPESA_OK"
	
			cContrato := M->WD_YCONTR
			cClvl := M->WD_YCLVL
			cItemCta := M->WD_YITEMCT
			cSubItem := M->WD_YSUBITE
	
			If SubStr(cCLVL, 1, 1) == '8' .And. Empty(cContrato)
				
				MsgBox("O campo contrato deverá ser preenchido quando a classe de valor iniciar com 8.", "EICDI500", "ALERT")
				
				lRdmake := .F.
				
			EndIf
			
			// Valida Subitem de projeto
			If !U_BIAF160(cClvl, cItemCta, cSubItem)
	
				MsgBox("A classe de valor e o item de selecionados, exige o preenchimento do Subitem de Projeto!", "EICDI500", "STOP")
	
				lRdmake := .F.
	
			EndIf
		
		EndIf
		
	EndIf

	RestArea(aArea)
		
return()