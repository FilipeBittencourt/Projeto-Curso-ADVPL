#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINClienteController
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINClienteController From LongClassName
 
	Data oCliente

	Method New() Constructor	
	Method CriarFacIN()
	Method EditarFacIN()		
	Method CriarPTH()

EndClass

Method New() Class TFacINClienteController 
 
	::oCliente := ""		

Return Self
 
Method CriarFacIN() Class TFacINClienteController

	Local oCliente := TFacINClienteDAO():New() 
	::oCliente := oCliente:CriarFacIN()	

Return ::oCliente


Method EditarFacIN() Class TFacINClienteController

	Local oCliente := TFacINClienteDAO():New() 
	::oCliente := oCliente:EditarFacIN()	

Return ::oCliente



Method CriarPTH() Class TFacINClienteController

	Local oCliente := TFacINClienteDAO():New() 
	::oCliente := oCliente:CriarPTH()	

Return ::oCliente
 

