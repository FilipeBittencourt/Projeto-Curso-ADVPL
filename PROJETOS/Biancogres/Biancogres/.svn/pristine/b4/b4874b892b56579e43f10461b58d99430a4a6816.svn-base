#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIAF092
@author Tiago Rossini Coradini
@since 04/01/2018
@version 1.0
@description Função para recebimento do pedido de compra por e-mail. 
@obs Ticket: 1146 - Projeto Demandas Compras - Item 2 - Complemento 1
@type Function
/*/

User Function BIAF092()
Local aArea := GetArea() 
Local oObj := Nil
	
	RpcSetType(3)
	RpcSetEnv("01", "01")
	
	oObj := TPedidoCompraEmail():New()
	
	oObj:Recebe()
		
	RestArea(aArea)
	
	RpcClearEnv()
Return()