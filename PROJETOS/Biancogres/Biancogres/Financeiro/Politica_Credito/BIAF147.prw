#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF147
@author Tiago Rossini Coradini
@since 02/03/2020
@version 1.0
@description Funcao atualizacao de processosda de Politica de Credito
@type class
/*/

// Chamada via Schedule
User Function BIAF147()
Local oObj := Nil

	RpcSetType(3)
	RpcSetEnv("01", "01")
		
	oObj := TPoliticaCredito():New()
		
	oObj:UpdProcess()
		
	FreeObj(oObj)
	
	RpcClearEnv()
			
Return()


// Chamada via Tela
User Function BIAF147A()
Local oObj := Nil

	oObj := TPoliticaCredito():New()
		
	oObj:UpdProcess()
		
	FreeObj(oObj)
				
Return()