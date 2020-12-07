#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINCondicaoPagamentoController
@description 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINCondicaoPagamentoController From LongClassName

	Data oModel
	Data oDAO

	Method New() Constructor
	Method CriarFacIN()
	Method EditarFacIN()
	Method CriarPTH()

EndClass

Method New() Class TFacINCondicaoPagamentoController

	::oModel := ""
	::oDAO   := ""

Return Self

Method CriarFacIN() Class TFacINCondicaoPagamentoController

	::oDAO := TFacINCondicaoPagamentoDAO():New()
	::oModel := ::oDAO:CriarFacIN()

Return ::oModel


Method EditarFacIN() Class TFacINCondicaoPagamentoController

	::oDAO := TFacINCondicaoPagamentoDAO():New()
	::oModel := ::oDAO:EditarFacIN()

Return ::oModel



Method CriarPTH() Class TFacINCondicaoPagamentoController

	::oModel := TFacINCondicaoPagamentoDAO():New()
	::oModel := ::oModel:CriarPTH()

Return ::oModel


