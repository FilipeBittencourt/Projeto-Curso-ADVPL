#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIAF120
@author Tiago Rossini Coradini
@since 07/06/2018
@version 1.0
@description Rotina de composicao de saldo financeiro por empresa 
@obs Ticket: 1937
@type Function
/*/

User Function BIAF120()
Local aArea := GetArea()
Local oParam := TParBIAF120():New()
	
	If oParam:Box() .And. oParam:lConfirm
					
		U_BIAMsgRun("Compondo saldo financeiro por empresa...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
	RestArea(aArea)

Return()


Static Function fProcess(oParam)
Local oWObj := Nil 
	
	oWObj := TWComposicaoSaldoFinanceiroEmpresa():New(oParam)
	oWObj:Activate()
	
Return()