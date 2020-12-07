#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF034
@author Tiago Rossini Coradini
@since 15/05/2019
@project Automação Financeira
@version 1.0
@description Prorrogacao de boletos a receber
@type function
/*/

User Function BAF034()
Local oParam := TParBAF034():New()
			
	If oParam:Box()
					
		U_BIAMsgRun("Selecionando boletos...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
Return()


Static Function fProcess(oParam)
Local oObj := Nil
		
	oObj := TWAFProrrogacaoBoletoReceber():New(oParam)

	oObj:Activate()

Return()