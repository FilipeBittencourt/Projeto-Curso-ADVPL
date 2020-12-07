#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TPedidoVendaRegras
@author Fernando Soares Rocha
@since 22/10/2018
@version 1.0
@description Classe para regras de inclusao e replicacao de pedidos de venda - projeto consolidacao 
@type class
/*/

//DEFINE TITULO PARA MENSAGENS
#DEFINE TIT_MSG "Regras de Pedido de Venda [TPedidoVendaRegras]"

Class TPedidoVendaItemRegras From LongClassName	

//propriedades do item de pedido
Data Item
Data Quantidade
Data Lote

Data EmpEst //Empresa do Estoque escolhida apos a digitacao da quantidade
Data Armazem //Armazem do Estoque escolhida apos a digitacao da quantidade

Data CodProduto
Data oProduto

//Posicoes do aHeader
Data nP_Item
Data nP_Produto	
Data nP_Quantidade
Data nP_Lote
Data nP_EmpEst
Data nP_Armazem

Method New() Constructor
Method FromACols()

EndClass


Method New() Class TPedidoVendaItemRegras

	::Item			:= ""
	::Quantidade	:= ""
	::Lote			:= ""
	::EmpEst		:= ""
	::Armazem		:= ""

	::CodProduto	:= ""
	::oProduto		:= Nil

	::nP_Item			:= AScan(AHEADER,{|x| AllTrim(x[2]) == "C6_ITEM"})
	::nP_Produto		:= AScan(AHEADER,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
	::nP_Quantidade		:= AScan(AHEADER,{|x| AllTrim(x[2]) == "C6_QTDVEN"})
	::nP_Lote			:= AScan(AHEADER,{|x| AllTrim(x[2]) == "C6_LOTECTL"})
	::nP_EmpEst			:= AScan(AHEADER,{|x| AllTrim(x[2]) == "C6_YEMPPED"})
	::nP_Armazem		:= AScan(AHEADER,{|x| AllTrim(x[2]) == "C6_LOCAL"})

Return()


Method FromACols(_ACOL) Class TPedidoVendaItemRegras

	::Item			:= _ACOL[::nP_Item]
	::Quantidade	:= _ACOL[::nP_Quantidade]
	::Lote			:= _ACOL[::nP_Lote]
	::EmpEst		:= _ACOL[::nP_EmpEst]
	::Armazem		:= _ACOL[::nP_Armazem]

	If ( AllTrim(ReadVar()) == "M->C6_PRODUTO" )
		::CodProduto :=  M->C6_PRODUTO
	Else
		::CodProduto := _ACOL[::nP_Produto]
	EndIf

	::oProduto		:= TPedidoVendaProdutoRegras():FromCodigo(::CodProduto)

Return