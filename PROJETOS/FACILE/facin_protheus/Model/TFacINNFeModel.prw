#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINNFeModel
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINNFeModel From LongClassName
	

	Data nIdFacIN  
	Data cCodCli      //C5_CLIENTE
	Data cLojaCli     //C5_LOJACLI
	Data cNFeDoc    
	Data cNumPed    
	Data cSync      

	Data cStatus	 
	Data cDeleted
	
	Method New() Constructor		 

EndClass

Method New() Class TFacINNFeModel  

	::nIdFacIN  := 0
	::cCodCli   := ""  //C5_CLIENTE
	::cLojaCli  := ""  //C5_LOJACLI
	::cNFeDoc   := "" 
	::cNumPed   := ""
	::cSync     := ""

	::cStatus   := ""	 
	::cDeleted  := 0

Return Self
 
 