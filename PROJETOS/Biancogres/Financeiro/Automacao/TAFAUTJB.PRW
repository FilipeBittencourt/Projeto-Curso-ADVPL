#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TAFCRRET
@description Processar JOBS da Automacao Financeira
@author Fernando Rocha
@since 15/02/2019
@version 1.0
@type function
/*/
User Function TAFCRPRC(UPAR01, UPAR02, CROTINA)

	Local oSch := TAFScheduleTask():New()
	
	RpcSetEnv(UPAR01, UPAR02)	

	oSch:ChkJobExec(AllTrim(CROTINA))
	
	RpcClearEnv()

Return()