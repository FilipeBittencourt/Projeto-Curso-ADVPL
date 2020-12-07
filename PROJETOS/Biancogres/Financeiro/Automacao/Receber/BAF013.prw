#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF013
@author Tiago Rossini Coradini
@since 02/09/2018
@project Automação Financeira
@version 1.0
@description Processa baixas de titulos a receber
@type function
/*/

User Function BAF013()
Local oSch := Nil
Local oObj := Nil
Local nCount := 0

	oSch := TAFScheduleTask():New()
	
	oSch:cTipo := "R"
	oSch:Get()
	
	For nCount := 1 To oSch:oLst:GetCount()

		ConOut("TAF => BAF013 - Conectando na Empresa: "+oSch:oLst:GetItem(nCount):cEmp+" Filial: "+oSch:oLst:GetItem(nCount):cFil)

		RpcSetEnv(oSch:oLst:GetItem(nCount):cEmp, oSch:oLst:GetItem(nCount):cFil)

		ConOut("TAF => BAF013 - INICIO do Processo Empresa: "+oSch:oLst:GetItem(nCount):cEmp+" Filial: "+oSch:oLst:GetItem(nCount):cFil+" DATE: "+DTOC(Date())+" TIME: "+Time())

			oObj := TAFBaixaReceber():New()
			
			oObj:Process()
			
		ConOut("TAF => BAF013 - FIM do Processo Empresa: "+oSch:oLst:GetItem(nCount):cEmp+" Filial: "+oSch:oLst:GetItem(nCount):cFil+" DATE: "+DTOC(Date())+" TIME: "+Time())

		RpcClearEnv()
		
	Next
			
Return()