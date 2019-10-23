#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TEZPedidoVendaDAO
@author  Filipe Vieira
@since 18/01/2019
@version 1.0
/*/

Class TEZPedidoVendaDAO From LongClassName

    Data oPedVendM

    Method New() Constructor
	Method Get(cChave, nIndice)

EndClass

Method New() Class TEZPedidoVendaDAO

	::oPedVendM := Nil

Return Self


Method Get(cChave, nIndice) Class TEZPedidoVendaDAO

	::oPedVendM := TEZPedidoVendaModel():New()

	SC5->(DbSetOrder(nIndice))
	If SC5->(DbSeek(cChave))
	    ::oPedVendM:cFilialx    	:= SC5->C5_FILIAL
		::oPedVendM:cPedNum			:= SC5->C5_NUM
		::oPedVendM:cPedStatus		:= SC5->C5_YSTATUS
		::oPedVendM:cPedAPI			:= SC5->C5_YAPI
		::oPedVendM:cPedWEB			:= SC5->C5_YPEDWEB
		::oPedVendM:dPedEmissao		:= SC5->C5_EMISSAO
		::oPedVendM:cPedNF			:= SC5->C5_NOTA
		::oPedVendM:cPedSerie		:= SC5->C5_SERIE
		::oPedVendM:cTransp			:= SC5->C5_TRANSP
		::oPedVendM:lAchouPed		:= .T.
	Else
		::oPedVendM:lAchouPed 		:= .F.
	EndIf

Return ::oPedVendM
