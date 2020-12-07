#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF062
@author Tiago Rossini Coradini
@since 29/12/2016
@version 1.0
@description Rotina para tratamento de duplicidade do código do fornecedor 
@obs OS: 4324-16 - Claudia Carvalho
@type function
/*/

User Function BIAF062()
Local aArea := GetArea()

	If Inclui
	
		DbSelectArea("SA2")
		DbSetOrder(1)
		While SA2->(DbSeek(xFilial("SA2") + M->A2_COD + M->A2_LOJA))
			
			U_BIAF061()
			
		EndDo()
			
	EndIf
	
	RestArea(aArea)
		
Return(.T.)