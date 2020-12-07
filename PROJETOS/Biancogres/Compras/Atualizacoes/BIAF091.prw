#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIAF091
@author Tiago Rossini Coradini
@since 28/12/2017
@version 1.0
@description Função para envio do pedido de compra por e-mail. 
@obs Ticket: 829 - Projeto Demandas Compras - Item 2
@type Function
/*/

User Function BIAF091(cNumPed, cTipEnv)
Local aArea := GetArea() 
Local oObj := Nil 

	DbSelectArea("SC7")
	DbSetOrder(1)
	If SC7->(DbSeek(xFilial("SC7") + cNumPed))

		oObj := TEnviaPedidoCompraEmail():New()
		
		oObj:cNumPed := cNumPed
		oObj:cTipEnv := cTipEnv
		oObj:cCodFor := SC7->C7_FORNECE
		oObj:cLojFor := SC7->C7_LOJA
			
		oObj:Envia()
		
	EndIf
				
	RestArea(aArea)

Return()