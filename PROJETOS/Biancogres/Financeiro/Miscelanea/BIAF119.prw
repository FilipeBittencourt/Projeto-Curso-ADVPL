#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF119
@author Tiago Rossini Coradini
@since 27/08/2018
@version 1.0
@description Valida arquivo de configuração na remessa de CNAB a receber 
@obs Ticket: 5870
@type function
/*/

User Function BIAF119()
Local lRet := .T.

	If cEmpAnt == "07" .And. AllTrim(MV_PAR05) == "237"
	
		MV_PAR03 := PadR("T:\COB\BRADLM.2RE", 50)
		
	EndIf
	
Return(lRet)