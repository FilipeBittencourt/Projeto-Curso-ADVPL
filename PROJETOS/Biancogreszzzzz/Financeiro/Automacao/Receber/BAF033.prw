#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF033
@author Tiago Rossini Coradini
@since 25/04/2019
@project Automação Financeira
@version 1.0
@description Processa depositos identificados
@type function
/*/

User Function BAF033()
Local oObj := Nil
	
	RpcSetEnv("07", "01")
		
		// Retorno de pagamentos
		oObj := TAFRetornoPagar():New()
		oObj:Receive()
		
	RpcClearEnv()
				
Return()