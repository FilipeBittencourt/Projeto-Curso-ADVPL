#include "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

/*/{Protheus.doc} TFacINProdutoModel
@author Filipe Bittencourt / Facile Sistemas
@since 02/07/2019
@version 1.0
/*/

Class TFacINProdutoModel From LongClassName

	Data nId
	Data cCodigo
	Data cDescri
	Data nPreVen
	Data nPesBru
	Data nPesLiq
	Data nSalEst
	Data cUM
	Data cProdGru
	Data cFabric
	Data cCodSB1

	Data cStatus
	Data cDeleted

	Method New() Constructor

EndClass

Method New() Class TFacINProdutoModel

	::nId    		:= 0
	::cCodigo   := ""
	::cDescri   := ""
	::nPreVen   := 0
	::nPesBru   := 0
	::nPesLiq   := 0
	::nSalEst   := 0
	::cUM   		:= ""
	::cProdGru  := ""
	::cFabric   := ""
	::cCodSB1		:= ""

	::cStatus   := ""
	::cDeleted  := ""

Return Self
