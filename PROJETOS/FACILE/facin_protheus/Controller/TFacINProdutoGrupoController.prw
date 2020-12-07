#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINProdutoGrupoController
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINProdutoGrupoController From LongClassName
 
	Data oClass
	Data oDAO
	Method New() Constructor	
	Method CriarFacIN()
	Method EditarFacIN()	

EndClass

Method New() Class TFacINProdutoGrupoController 
 
	::oClass := ""		
	::oDAO := ""	

Return Self
 
Method CriarFacIN() Class TFacINProdutoGrupoController

	::oDAO := TFacINProdutoGrupoDAO():New() 
	::oClass := ::oDAO:CriarFacIN()	

Return ::oClass


Method EditarFacIN() Class TFacINProdutoGrupoController

	Local oDAO := TFacINProdutoGrupoDAO():New() 
	::oClass := ::oDAO:EditarFacIN()	

Return ::oClass