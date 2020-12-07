#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BAF016
@author Wlysses Cerqueira (Facile)
@since 27/02/2019
@project Automação Financeira
@version 1.0
@description Processa remessa de titulos a pagar 
@type function
/*/

User Function BAF016()

	Local oObj := Nil

	Local lJob := !(Select("SX2") > 0)
	
	If lJob
	
		RpcSetEnv("07", "01")
		
	EndIf
	
	oObj := TAFComprovantePagamento():New()
	
	oObj:Comprovante()

	If lJob
	
		RpcClearEnv()
	
	EndIf
	
Return()