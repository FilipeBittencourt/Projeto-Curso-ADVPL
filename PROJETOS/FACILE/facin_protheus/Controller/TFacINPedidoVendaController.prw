#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINPedidoVendaController
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINPedidoVendaController From LongClassName
 
	Data oModel
	Data oDAO

	Method New() Constructor	
	Method CriarPTH()	 

EndClass

Method New() Class TFacINPedidoVendaController 
 
	::oModel := ""		
	::oDAO   := ""

Return Self
 
Method CriarPTH() Class TFacINPedidoVendaController

	::oDAO := TFacINPedidoVendaDAO():New()
	::oModel := ::oDAO:CriarPTH()	

Return ::oModel