#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF084
@author Tiago Rossini Coradini
@since 20/07/2017
@version 1.0
@description Rotina para aprovação comercial do pedido de venda via e-mail
@obs OS: 4538-16 - Claudeir Fadini
@type function
/*/

User Function BIAF084()
Local aArea := Nil
Local oAprPed	:= Nil
	
	RpcSetType(3)
	RpcSetEnv("01", "01")
		
		aArea := GetArea()
		
		oAprPed := TAprovaPedidoVendaEMail():New()
		oAprPed:Recebe()
		
	RestArea(aArea)
	
	RpcClearEnv()
	
Return()