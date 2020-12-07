#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINCondicaoPagamentoModel 
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINCondicaoPagamentoModel From LongClassName 
	
	Data nId
	Data cE4CODIGO
	Data cE4TIPO
	Data cE4COND
	Data cE4DESCRI	
	Data cE4SUPER
	Data cE4MSBLQL

	Data cStatus
	Data cDeleted

	Method New() Constructor		 

EndClass

Method New() Class TFacINCondicaoPagamentoModel 

	::nId        := ""
	::cE4CODIGO    := ""
	::cE4TIPO    := ""
	::cE4COND    := ""
	::cE4DESCRI  := ""
	::cE4MSBLQL  := ""
	::cStatus    := ""
	::cDeleted   := ""

Return Self
 