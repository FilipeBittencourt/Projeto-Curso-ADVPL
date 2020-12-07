#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} THistoricoPrecoProduto
@author Tiago Rossini Coradini
@since 22/09/2014
@version 1.1
@description Classe para vizualização do historico de precos de produtos
@obs OS: 1818-14 - Claudia Carvalho
@obs OS: 1615-17 - Claudia Carvalho
@type class
/*/

Class THistoricoPrecoProduto From LongClassName

	Data oInterface
	Data oLst
	
	Method New() Constructor
	Method GetNfe(cPrd)
	Method GetPedC(cPrd)

EndClass


Method New() Class THistoricoPrecoProduto

	::oInterface := Nil
	::oLst := Nil
	
Return()


Method GetNfe(cPrd) Class THistoricoPrecoProduto
Local cSQL := ""
Local Qry := GetNextAlias()
	        	
	::oLst := ArrayList():New()
	        
	cSQL := "EXEC SP_HISTORICO_PRECO_PRODUTO_NFE "+ ValToSQL(cPrd)
			
	TcQuery cSQL New Alias (Qry)
	  		
	While (Qry)->(!EOF())
			
	 	::oInterface := TIHistoricoPrecoProdutoNfe():New()
	 	
		::oInterface:cEmp := (Qry)->EMPRESA
		::oInterface:cDtEntrada := sToD((Qry)->D1_DTDIGIT)
		::oInterface:cTipoNF := (Qry)->D1_TIPO
		::oInterface:cDoc := (Qry)->D1_DOC
		::oInterface:cSerie := (Qry)->D1_SERIE
		::oInterface:cFornece := (Qry)->D1_FORNECE
		::oInterface:cLoja := (Qry)->D1_LOJA
		::oInterface:nQtd := (Qry)->D1_QUANT
		::oInterface:nVlrUnit := (Qry)->D1_VUNIT
		::oInterface:cDtEmissao := sToD((Qry)->D1_EMISSAO)
			 	
		::oLst:Add(::oInterface)
						
		(Qry)->(dbSkip())
		                                                           
	EndDo
		
	(Qry)->(dbCloseArea())	 	
	 		 		
Return(::oLst)


Method GetPedC(cPrd) Class THistoricoPrecoProduto
Local cSQL := ""
Local Qry := GetNextAlias()
	        	
	::oLst := ArrayList():New()
	        
	cSQL := "EXEC SP_HISTORICO_PRECO_PRODUTO_PEDC "+ ValToSQL(cPrd)
			
	TcQuery cSQL New Alias (Qry)
	  		
	While (Qry)->(!EOF())
			
	 	::oInterface := TIHistoricoPrecoProdutoPedC():New()
	 	
		::oInterface:cEmp := (Qry)->EMPRESA
		::oInterface:cDtEmissao := sToD((Qry)->C7_EMISSAO)
		::oInterface:cNumero := (Qry)->C7_NUM
		::oInterface:cCondPag := (Qry)->C7_COND
		::oInterface:cDesc := (Qry)->E4_DESCRI
		::oInterface:cFornece := (Qry)->C7_FORNECE
		::oInterface:cLoja := (Qry)->C7_LOJA
		::oInterface:nQtd := (Qry)->C7_QUANT
		::oInterface:nVlrUnit := (Qry)->C7_PRECO
			 	
		::oLst:Add(::oInterface)
						
		(Qry)->(dbSkip())
		                                                           
	EndDo
		
	(Qry)->(dbCloseArea())	 	
	 		 		
Return(::oLst)