#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF012
@author Tiago Rossini Coradini
@since 15/01/2019
@project Automação Financeira
@version 1.0
@description Renvio de boletos a receber
@type function
/*/

User Function BAF012()
Local oParam := TParBAF012():New()
			
	If oParam:Box()
					
		U_BIAMsgRun("Selecionando boletos...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
Return()


Static Function fProcess(oParam)
Local oWObj := Nil
		
	oWObj := TWAFReenvioRemessaReceber():New(oParam)

	oWObj:Activate()

Return()