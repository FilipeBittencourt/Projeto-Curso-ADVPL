#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF094
@author Tiago Rossini Coradini
@since 09/01/2018
@version 1.0
@description Função para recebimento do pedido de compra por e-mail. 
@obs Ticket: 1445 - Projeto Demandas Compras - Item 2 - Complemento 3
@type Function
/*/

User Function BIAF094()
Local aArea := GetArea()
Local oObj := Nil 

	oObj := TConfirmacaoManualPedidoCompra():New()
	
	oObj:cNumPed := SC7->C7_NUM
	oObj:cCodFor := SC7->C7_FORNECE
	oObj:cLojFor := SC7->C7_LOJA
	oObj:nRecNo := SC7->(RecNo())
		
	oObj:Confirma()
		
	RestArea(aArea)

Return()