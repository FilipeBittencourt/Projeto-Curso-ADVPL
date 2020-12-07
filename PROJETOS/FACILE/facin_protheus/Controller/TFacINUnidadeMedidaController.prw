#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINUnidadeMedidaController
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINUnidadeMedidaController From LongClassName
 
	Data oOBJ

	Method New() Constructor	
	Method CriarFacIN()
	Method EditarFacIN()	

EndClass

Method New() Class TFacINUnidadeMedidaController 
 
	::oOBJ := ""		

Return Self
 
Method CriarFacIN() Class TFacINUnidadeMedidaController

	Local oOBJAux := TFacINUnidadeMedidaDAO():New() 
	::oOBJ := oOBJAux:CriarFacIN()	

Return ::oOBJ


Method EditarFacIN() Class TFacINUnidadeMedidaController

	Local oOBJAux := TFacINUnidadeMedidaDAO():New() 
	::oOBJ := oOBJAux:EditarFacIN()	

Return ::oOBJ