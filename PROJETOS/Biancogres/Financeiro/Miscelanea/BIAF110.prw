#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIAF110
@author Tiago Rossini Coradini
@since 22/05/2018
@version 1.0
@description Rotina de composicao de saldo financeiro 
@obs Ticket: 4615
@type Function
/*/

User Function BIAF110()
Local aArea := GetArea()
Local oParam := TParBIAF110():New()
	
	If oParam:Box() .And. oParam:lConfirm
					
		U_BIAMsgRun("Compondo saldo financeiro...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
	RestArea(aArea)

Return()


Static Function fProcess(oParam)
Local oWObj := Nil

	oWObj := TWComposicaoSaldoFinanceiro():New(oParam)
	oWObj:Activate()
		
Return()