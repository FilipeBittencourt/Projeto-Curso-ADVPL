#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TIHistoricoPrecoProdutoNfe
@author Tiago Rossini Coradini
@since 22/09/2014
@version 1.1
@description Classe de Interface de historico de precos de produto em Notas de Entrada	
@obs OS: 1818-14 - Claudia Carvalho
@obs OS: 1615-17 - Claudia Carvalho
@type class
/*/

Class TIHistoricoPrecoProdutoNfe From LongClassName

	Data cEmp
	Data cDtEntrada
	Data cTipoNF
	Data cDoc
	Data cSerie
	Data cFornece
	Data cLoja
	Data nQtd
	Data nVlrUnit
	Data cDtEmissao
	
	Method New() Constructor
	
EndClass


Method New() Class TIHistoricoPrecoProdutoNfe

	::cEmp := ""
	::cDtEntrada := dDataBase
	::cTipoNF := ""
	::cDoc := ""
	::cSerie := ""
	::cFornece := ""
	::cLoja := ""
	::nQtd := 0
	::nVlrUnit := 0
	::cDtEmissao := dDatabase
		
Return()


/*/{Protheus.doc} TIHistoricoPrecoProdutoPedC
@author Tiago Rossini Coradini
@since 22/09/2014
@version 1.1
@description Classe de Interface de historico de precos de produto em Pedidos de Compra
@obs OS: 1818-14 - Claudia Carvalho
@obs OS: 1615-17 - Claudia Carvalho
@type class
/*/

Class TIHistoricoPrecoProdutoPedC From LongClassName

	Data cEmp
	Data cDtEmissao
	Data cNumero
	Data cCondPag
	Data cDesc
	Data cFornece
	Data cLoja
	Data nQtd
	Data nVlrUnit	
	
	Method New() Constructor
	
EndClass


Method New() Class TIHistoricoPrecoProdutoPedC

	::cEmp := ""
	::cDtEmissao := dDataBase
	::cNumero := ""
	::cCondPag := ""
	::cDesc := ""
	::cFornece := ""
	::cLoja := ""
	::nQtd := 0
	::nVlrUnit := 0
		
Return()