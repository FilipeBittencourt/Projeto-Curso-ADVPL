#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF106
@author Tiago Rossini Coradini
@since 10/05/2018
@version 1.0
@description Rotina para exibir o historico de alteracoes de reserva de estoque 
@obs Ticket: 319
@type function
/*/

User Function BIAF106(cProduto, cDescProd, cLote)
Local aArea := GetArea()
Local oObj := Nil
	
	oObj := TWHistoricoReservaEstoque():New(cProduto, cDescProd, cLote)
					
	oObj:Activate()
				
	RestArea(aArea)
		
Return()