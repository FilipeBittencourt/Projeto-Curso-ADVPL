#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TPedidoVendaProdutoRegras
@author Fernando Soares Rocha
@since 22/10/2018
@version 1.0
@description Classe para regras de inclusao pedido - PRODUTO 
@type class
/*/

//DEFINE TITULO PARA MENSAGENS
#DEFINE TIT_MSG "Regras de Pedido de Venda [TPedidoVendaProdutoRegras]"

Class TPedidoVendaProdutoRegras From LongClassName	

//propriedades do item de pedido
Data Codigo
Data Descricao
Data Pacote
Data Marca
Data Tipo
Data ClasseProd

Method FromCodigo(cCodSB1) Constructor

EndClass


Method FromCodigo(cCodSB1) Class TPedidoVendaProdutoRegras

	Local aAreaB1 := SB1->(GetArea())

	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(XFilial("SB1")+cCodSB1))

		::Codigo 	:= SB1->B1_COD
		::Descricao := SB1->B1_DESC
		::Pacote 	:= SB1->B1_YPCGMR3
		::Tipo		:= SB1->B1_TIPO
		::ClasseProd:= SB1->B1_YCLASSE
		
		ZZ7->(DbSetOrder(1))
		If ZZ7->(DbSeek(XFilial("ZZ7")+SB1->B1_YLINHA+SB1->B1_YLINSEQ))
		
			::Marca	:= ZZ7->ZZ7_EMP
		
		Else
		
			::Marca	:= ""
		
		EndIf

	EndIf
	
	RestArea(aAreaB1)

Return