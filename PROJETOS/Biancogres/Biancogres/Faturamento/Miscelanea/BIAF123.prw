#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BIAF123
@author Tiago RossinPos CoradinPos
@since 07/11/2018
@version 1.0
@description Rotina para atualizacao dos processos de pesagem e carga 
@obs Projeto PBI: Tickets: 7428, 7429
@type Function
/*/

User Function BIAF123()

	If cEmpAnt == "01"
	
		If MsgYesNo("Deseja realmente atualizar os processos de Pesagem/Carga?")
		
			FWMsgRun(, {|| fProcess() }, "Aguarde!", "Atualizando Processos de Pesagem/Carga...")
			
		EndIf
	
	Else
	
		MsgStop("Não é permitido executar a atualização dos processos de pesagem nesta empresa.")
	
	EndIf		

Return()


Static Function fProcess()
Local oObj := Nil

	oObj := TAtualizaProcessoPesagem():New()
		
	oObj:Execute()
		
Return()