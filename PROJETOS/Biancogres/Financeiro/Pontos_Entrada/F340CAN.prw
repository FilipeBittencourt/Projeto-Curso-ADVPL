#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F340CAN
@author Tiago Rossini Coradini
@since 17/08/2016
@version 1.0
@description Ponto de entrada para validar o estorno da compensação do contas a pagar. 
@obs OS: 2058-16 - Margareth Sartorio
@type function
/*/

User Function F340CAN()
Local aArea := GetArea()
Local lOk := .T.
Local nCount := 1

	While nCount <= Len(aTitulos) .And. lOk
		
		// Verifica se o titulo foi marcado
		If aTitulos[nCount, 10]
		
			// Verifica se a data de baixa é diferente da Database 
			If cToD(aTitulos[nCount, 5]) <> dDataBase
				
				lOk := .F.
				
				aEval(aTitulos, {|x| x[10] := .F.})
				
				Alert("Ateção, não é permitido efetuar estorno / exclusão de Títulos com a Data de Baixa diferente da Data Base.")							
				
			EndIf
		
		EndIf
		
		nCount++
		
	EndDo()	
	
	RestArea(aArea)
	
Return()