#include "TOTVS.CH"

/*/{Protheus.doc} TItemNotaEntrada
@description Classe para automatocoes de processos referente a documento de entrada
@author Fernando Rocha
@since 10/06/2019
@version 1.0
@type class
/*/
Class TItemNotaEntrada from LongClassName

	Data cItem
	Data cProduto
	Data nQuantidade
	Data nVUnit
	Data cTES
	Data cTESPN
	Data cPedido
	Data cItemPC
	Data cLocal
	Data nPIcms

	Method New() Constructor

EndClass

Method New() Class TItemNotaEntrada

	::cItem			:= ""
	::cProduto		:= ""
	::nQuantidade	:= 0
	::nVUnit		:= 0
	::cTES			:= ""
	::cTESPN		:= ""
	::cPedido		:= ""
	::cItemPC		:= ""
	::cLocal		:= ""
	::nPIcms		:= 0

Return