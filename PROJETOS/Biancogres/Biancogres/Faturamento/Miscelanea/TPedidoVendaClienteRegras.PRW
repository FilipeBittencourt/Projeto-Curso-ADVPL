#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TPedidoVendaClienteRegras
@author Fernando Soares Rocha
@since 22/10/2018
@version 1.0
@description Classe para regras de validacao - CLIENTE - no pedido de vendas
@type class
/*/

//DEFINE TITULO PARA MENSAGENS
#DEFINE TIT_MSG "Regras de Pedido de Venda [TPedidoVendaClienteRegras]"

Class TPedidoVendaClienteRegras From LongClassName	

//propriedades do item de pedido
Data Codigo
Data Loja
Data Nome
Data Segmento

Data lEspecial

Method FromCodLin(cCodLojSA1, cLinhaPed) Constructor

EndClass


Method FromCodLin(cCodLojSA1, cLinhaPed) Class TPedidoVendaClienteRegras

	Local aAreaA1 := SA1->(GetArea())
	Local _aDadCli

	::Codigo 	:= SubStr(cCodLojSA1,1,6)
	::Loja 		:= SubStr(cCodLojSA1,7,2)

	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(XFilial("SA1")+::Codigo+::Loja))
		::Nome		:= SA1->A1_NOME
	EndIf

	_aDadCli := U_fInfCliente(cLinhaPed, ::Codigo, ::Loja)

	::Segmento 	:= _aDadCli[3]
	::lEspecial	:= ( _aDadCli[1] == "1" )

	RestArea(aAreaA1)

Return