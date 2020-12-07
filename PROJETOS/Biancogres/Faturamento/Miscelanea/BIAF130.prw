#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF130
@author Tiago Rossini Coradini
@since 08/08/2019
@version 1.0
@description Workflow de limite de credito
@obs Ticket: 16502
@type class
/*/

User Function BIAF130()
Local oParam := TParBIAF130():New()
			
	If oParam:Box()
					
		U_BIAMsgRun("Enviando Workflow de Limite de Crédito...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
		
Return()


// Chamada via Schedule
User Function BIAF130A()
Local oParam := Nil
			
	RpcSetType(3)
	RpcSetEnv("01", "01")
	
		oParam := TParBIAF130():New()
	
		fProcess(oParam)
	
	RpcClearEnv()
		
Return()


Static Function fProcess(oParam)
Local oObj := Nil
		
	// Workflow de Limite de Credito
	oObj := TWorkflowLimiteCreditoCliente():New(oParam)
	oObj:Process()
	
Return()