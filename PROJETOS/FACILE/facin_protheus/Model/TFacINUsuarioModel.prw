#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINUsuarioModel 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINUsuarioModel From LongClassName
	
	Data cNome
	Data cEmail
	Data cToken 	 
	
	Method New() Constructor		 

EndClass

Method New() Class TFacINUsuarioModel 

	::cNome  := ""
	::cEmail := ""
	::cToken := "" 	

Return Self
 