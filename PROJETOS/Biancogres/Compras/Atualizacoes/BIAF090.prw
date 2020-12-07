#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIAF090
@author Tiago Rossini Coradini
@since 18/12/2017
@version 1.0
@description Função para chamada da classe para associar o transportador ao pedido de compra. 
@obs Ticket: 829 - Projeto Demandas Compras - Item 2 
@type Function
/*/

User Function BIAF090(cNumPed)
Local aArea := GetArea() 
Local oObj := Nil 

	// Nao exibir a tela do transportador quando o pedido for gerdado automaticamente via MRP
	If !IsInCallStack("U_BIAFG030")
	
		DbSelectArea("SC7")
		DbSetOrder(1)
		If SC7->(DbSeek(xFilial("SC7") + cNumPed))
	
			oObj := TWTransportadorPedidoCompra():New()
			
			oObj:cNumPed := cNumPed
			
			oObj:Activate()
			
		EndIf
		
	EndIf
	
	RestArea(aArea)

Return()