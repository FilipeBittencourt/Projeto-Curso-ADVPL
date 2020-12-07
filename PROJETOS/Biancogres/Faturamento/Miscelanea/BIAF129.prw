#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF129
@author Tiago Rossini Coradini
@since 03/06/2019
@version 1.0
@description Envia workflow de representes agrupado por empresa (Cnpj/Cpf)
@obs Ticket: 9998
@type class
/*/

User Function BIAF129()
Local oParam := TParBIAF129():New()
			
	If oParam:Box()
					
		U_BIAMsgRun("Enviando Comissões...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
Return()


Static Function fProcess(oParam)
Local oObj := Nil
		
	oObj := TWorkFlowComissaoRepresentante():New(oParam)

	oObj:Process()

Return()