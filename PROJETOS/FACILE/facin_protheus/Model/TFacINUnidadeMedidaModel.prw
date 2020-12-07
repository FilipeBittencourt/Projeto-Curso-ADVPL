#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINunidademedidaModel
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINunidademedidaModel From LongClassName
	
	Data nIdFacIN 
	Data cCodigo 
	Data cSigla
	Data cDescri 
	Data cStatus	 
	Data cDeleted
	
	Method New() Constructor		 

EndClass

Method New() Class TFacINunidademedidaModel 
 

	::nIdFacIN  := ""
	::cCodigo   := "" 
	::cSigla    := ""
	::cDescri   := ""
	::cStatus   := ""	 
	::cDeleted  := 0

Return Self
 