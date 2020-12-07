#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF011
@author Tiago Rossini Coradini
@since 10/12/2018
@project Automação Financeira
@version 1.0
@description Concilia titulos de DDA 
@type function
/*/

User Function BAF011()

	Local oObj := Nil
	Local nCount := 0
	
	ConOut("TAF => BAF011 - [Concilia titulos de DDA] - INICIO do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())

	oObj := TAFConciliacaoDDA():New()			
	oObj:Process()
	
	ConOut("TAF => BAF011 - [Concilia titulos de DDA] - fim do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())

Return()