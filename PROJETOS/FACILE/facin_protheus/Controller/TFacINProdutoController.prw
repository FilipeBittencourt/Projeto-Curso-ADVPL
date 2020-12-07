#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINProdutoController
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINProdutoController From LongClassName
 
	Data oProduto

	Method New() Constructor	
	Method CriarFacIN()
	Method EditarFacIN()	

EndClass

Method New() Class TFacINProdutoController 
 
	::oProduto := ""		

Return Self
 
Method CriarFacIN() Class TFacINProdutoController

	Local oProduto := TFacINProdutoDAO():New() 
	::oProduto := oProduto:CriarFacIN()	

Return ::oProduto


Method EditarFacIN() Class TFacINProdutoController

	Local oProduto := TFacINProdutoDAO():New() 
	::oProduto := oProduto:EditarFacIN()	

Return ::oProduto