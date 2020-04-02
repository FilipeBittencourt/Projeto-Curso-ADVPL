#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TEZPedidoVendaController
@author  Filipe Vieira
@since 18/01/2019
@version 1.0
/*/

Class TEZPedidoVendaController From LongClassName

    Data oPedVendM 
	Method New() Constructor
	Method Get(cChave, nIndex) 

EndClass

Method New() Class TEZPedidoVendaController

	::oPedVendM	:= Nil

Return  Self

 
Method Get(cChave, nIndex) Class TEZPedidoVendaController

    Local oPedVendD := TEZPedidoVendaDAO():New()		 
	::oPedVendM := oPedVendD:Get(cChave, nIndex)		 

Return  ::oPedVendM			