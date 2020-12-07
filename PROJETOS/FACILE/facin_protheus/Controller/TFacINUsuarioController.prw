#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINUsuarioController
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINUsuarioController From LongClassName
 
	Data oObjM	
	Method New() Constructor	
	Method Login()

EndClass

Method New() Class TFacINUsuarioController 
 
	::oUsuario := ""		

Return Self

// POST  LOGIN
Method Login() Class TFacINUsuarioController

	Local oObjC := TFacINUsuarioDAO():New()	 
	    ::oObjM := oObjC:Login() 

Return ::oObjM
 