#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TIPDMTransferencia
@author Wlysses Cerqueira (Facile)
@since 22/10/2018
@project PDM
@version 1.0
@description Classe com as regras para transferencia de estoque dos produtos Origems para os Destinos
@type class
/*/
Class TIPDMTransferencia From LongClassName
	
	Data cFil
	Data cProdOrigem    
	Data cLocalOrigem   
	Data nQatuOrigem    
	Data nReservaOrigem 
	Data nQaclasOrigem  
	                    
	Data cProdDestino      
	Data cLocalDestino     
	Data nQatuDestino      
	Data nReservaDestino   
	Data nQaclasDestino    
	
	Method New() Constructor

EndClass

Method New() Class TIPDMTransferencia	

	::cFil				:= ""
	::cProdOrigem       := ""
	::cLocalOrigem      := ""
	::nQatuOrigem       := ""
	::nReservaOrigem    := ""
	::nQaclasOrigem     := ""
	                    
	::cProdDestino         := ""
	::cLocalDestino        := ""
	::nQatuDestino         := ""
	::nReservaDestino      := ""
	::nQaclasDestino       := ""
	
Return(Self)