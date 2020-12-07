#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} LP610012
@author Marcos Alberto Soprani
@since 02/08/2016
@version 1.0
@description Contas de ICMS ST de Faturamento
@obs OS: 2190-16 - Tania
@type function
/*/

User Function LP610012()

	Local blwCta := ""
	Local blwArea := GetArea()

	If Substr(SD2->D2_CLVL,1,1) == "3"
		blwCta := "61601022"
	Else
		SC5->(dbSetOrder(1))
		If SC5->(dbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
			If Alltrim(SC5->C5_YSUBTP) == "G"
				blwCta := "31401019"
			Else
				blwCta := "31701002"
			EndIf
		EndIf
	EndIf 
	
	//|Pontin / Facile - OS 1771-17 - Tratamento para contabilizar notas de garantia (RPV) |
	If (cEmpAnt == "01" .And. AllTrim(SD2->D2_TES) $ "650/651/550/968") .Or. ;	//|Biancogrês |
		 (cEmpAnt $ "05/07" .And. AllTrim(SD2->D2_TES) $ "6F0/5F0/6F1/9G8")		//|Incesa e LM |
		
		If Substr(SD2->D2_CLVL,1,1) == "3"
			blwCta := "61601022"
		Else
			blwCta := "31401019"
		EndIf
	
	EndIf

	RestArea(blwArea)

Return(blwCta)
