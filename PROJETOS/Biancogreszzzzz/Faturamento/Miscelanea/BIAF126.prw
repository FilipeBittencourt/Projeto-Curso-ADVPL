#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF125
@author Tiago RossinPos CoradinPos
@since 23/01/2019
@version 1.0
@description Geração em arquivo(PDF) do termo de responsabilidade do motorista e notas relacionadas
@obs Ticket: 8329
@type Function
/*/

User Function BIAF126(cNumCar)
Local aArea := GetArea()

	// Executa chamada do Termo
	// U_BIAEC003
	
	// Executa chamda da Danfe
	// U_PrtNfeSef()
	
	RestArea(aArea)
	
Return()