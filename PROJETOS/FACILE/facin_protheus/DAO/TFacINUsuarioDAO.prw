#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINUsuarioDAO
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Static cHostWS := "https://facinbackendx.azurewebsites.net"

Class TFacINUsuarioDAO From LongClassName

  
	Data oUserM
	
	Method New() Constructor	

EndClass

Method New() Class TFacINUsuarioDAO  

	::oUserM   := ""		

Return Self

