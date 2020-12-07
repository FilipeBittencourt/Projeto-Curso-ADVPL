#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIAF093
@author Tiago Rossini Coradini
@since 09/01/2018
@version 1.0
@description Função para recebimento do pedido de compra por e-mail. 
@obs Ticket: 1155 - Projeto Demandas Compras - Item 2 - Complemento 2
@type Function
/*/

User Function BIAF093(cNumPed, dDatInc, dDatLib)
Local aArea := GetArea()
Local nDia := 0
	
	If !Empty(dDatInc) .And. dDatInc < dDatLib
	
		nDia := DateDiffDay(dDatInc, dDatLib)
		
		DbSelectArea("SC7")
		DbSetOrder(1)
		If SC7->(DbSeek(xFilial("SC7") + cNumPed))		
		
			While !SC7->(Eof()) .And. SC7->C7_NUM == cNumPed
			
				RecLock("SC7")
					
					SC7->C7_DATPRF := DaySum(SC7->C7_DATPRF, nDia)
					SC7->C7_YDATCHE := DaySum(SC7->C7_YDATCHE, nDia)
								
				SC7->(MsUnLock())
				
				SC7->(DbSkip())
			
			EndDo()
		
		EndIf
		
	EndIf
	
	RestArea(aArea)
	
Return()