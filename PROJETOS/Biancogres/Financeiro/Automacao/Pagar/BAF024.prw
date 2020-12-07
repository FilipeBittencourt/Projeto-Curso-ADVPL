#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF024
@author Wlysses Cerqueira
@since 21/05/2019
@project Automação Financeira
@version 1.0
@description Gera compranvantes diariamente e salva em pasta definida
@type function
/*/

User Function BAF024()

	Local oObj := Nil

	ConOut("TAF => BAF024 - GERAR COMPROVANTES - INICIO: " + DTOC(Date()) + " TIME: " + Time())
	
	oObj := TAFComprovantePagamento():New()
	
	oObj:cCaminho := If(Type("PARAMIXB") == "A", PARAMIXB[1], "\P10\CNAB\COMPROVANTES\")

	oObj:ImprimeTodos()
	
	ConOut("TAF => BAF024 - GERAR COMPROVANTES - FIM: " + DTOC(Date()) + " TIME: " + Time())
	
Return()