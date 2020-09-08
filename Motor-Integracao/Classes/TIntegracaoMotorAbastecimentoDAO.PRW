#include "protheus.ch"

CLASS TIntegracaoMotorAbastecimentoDAO From LongClassName
    
    Data oJSon

    Method New() CONSTRUCTOR
    Method ExecAutoPCompra(oJson)
    Method ExecAutoPVenda(oJson)
    

ENDCLASS

METHOD NEW() CLASS TIntegracaoMotorAbastecimentoDAO
    ::oJSon := JsonObject():New() 
Return self


Method ExecAutoPCompra(oJson) Class TIntegracaoMotorAbastecimentoDAO
Return ::oJson

Method ExecAutoPVenda(oJson) Class TIntegracaoMotorAbastecimentoDAO
Return ::oJson

 
 
