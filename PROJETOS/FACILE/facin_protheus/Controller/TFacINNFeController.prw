#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINNFeController
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINNFeController From LongClassName
 
	Data oModel
	Data oDAO
	Method New() Constructor		
	Method EditarFacIN()	

EndClass

Method New() Class TFacINNFeController  
	
	::oModel   := ""
	::oDAO	   := ""	

Return Self

Method EditarFacIN() Class TFacINNFeController

	::oDAO := TFacINNFeDAO():New() 
	::oModel := ::oDAO:EditarFacIN()	

Return ::oModel