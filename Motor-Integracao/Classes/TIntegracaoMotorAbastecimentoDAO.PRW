#include "protheus.ch"

CLASS TIntegracaoMotorAbastecimentoDAO From LongClassName
    
    Data oJSon

    Method New() CONSTRUCTOR
    Method ExecAutoPedidoCompra()
    Method ExecAutoPedidoVenda()
    

ENDCLASS

METHOD NEW() CLASS TIntegracaoMotorAbastecimentoDAO
    ::oJSon := JsonObject():New() 
Return self


Method ExecAutoPedidoCompra(oJson) Class TIntegracaoMotorAbastecimentoDAO
Return ::oJson

Method ExecAutoPedidoVenda(oJson) Class TIntegracaoMotorAbastecimentoDAO
Return ::oJson

 
 
