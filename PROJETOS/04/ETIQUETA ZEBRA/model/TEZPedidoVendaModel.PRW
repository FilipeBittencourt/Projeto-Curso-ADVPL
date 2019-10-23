#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TEZPedidoVendaModel
@author  Filipe Vieira
@since 18/01/2019
@version 1.0
/*/


Class TEZPedidoVendaModel From LongClassName

	//Dados parametros

	Data cFilialx // coloquei um x no final, pois FILIAL É variavel padrão TOTVS
	Data cPedNum
	Data lAchouPed
	Data cPedStatus
	Data cPedAPI
	Data cPedWEB
	Data dPedEmissao
	Data cPedNF
	Data cPedSerie
	Data cTransp

	Method New() Constructor

EndClass

Method New() Class TEZPedidoVendaModel

	::cFilialx		:= ""
	::lAchouPed		:= .F.
	::cPedNum		:= ""
	::cPedStatus	:= ""
	::cPedAPI		:= ""
	::cPedWEB		:= ""
	::dPedEmissao	:= CtoD("")
	::cPedNF		:= ""
	::cPedSerie		:= ""
	::cTransp		:= ""

Return Self
