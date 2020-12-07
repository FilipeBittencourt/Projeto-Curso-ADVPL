#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF131
@author Tiago Rossini Coradini
@since 08/08/2019
@version 1.0
@description Workflow de titulos vencidos
@obs Ticket: 16502
@type class
/*/

User Function BIAF131()
Local oParam := TParBIAF131():New()
			
	If oParam:Box()
					
		U_BIAMsgRun("Enviando Workflow de Títulos Vencidos...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
Return()


// Chamada via Schedule
User Function BIAF131A()
Local oParam := Nil
			
	RpcSetType(3)
	RpcSetEnv("01", "01")
	
		oParam := TParBIAF131():New()
	
		fProcess(oParam)
	
	RpcClearEnv()
		
Return()


Static Function fProcess(oParam)
Local oObj := Nil
		
	// Workflow de Titulos Vencidos
	oObj := TWorkflowtTituloVencidoCliente():New(oParam)
	oObj:Process()

Return()