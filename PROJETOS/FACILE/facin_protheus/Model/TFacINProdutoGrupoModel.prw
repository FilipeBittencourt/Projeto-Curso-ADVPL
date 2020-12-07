#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINProdutoGrupoModel
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINProdutoGrupoModel From LongClassName
	
	Data nId 
	Data cCodGrp 	
	Data cDescri 

	Data cStatus	 
	Data cDeleted
	
	Method New() Constructor		 

EndClass

Method New() Class TFacINProdutoGrupoModel 

	::nId := 0
	::cCodGrp  := ""
	::cDescri   := ""	  
	::cStatus  := ""
	::cDeleted := ""

Return Self
 