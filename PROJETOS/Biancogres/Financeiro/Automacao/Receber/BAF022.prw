#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF022
@author Wlysses Cerqueira
@since 20/05/2019
@project Automação Financeira
@version 1.0
@description Processa titulos RA para compensacao automatica
@type function
/*/

User Function BAF022()

	Local oObj := Nil
	
	ConOut("TAF => BAF022 - COMPENSACAO AUTOMATICA DE TITULOS RA - INICIO: " + DTOC(Date()) + " TIME: " + Time())
	
	oObj := TCompensacaoReceber():New()
	
	oObj:RecebAntecipado()
	
	ConOut("TAF => BAF022 - COMPENSACAO AUTOMATICA DE TITULOS RA - FIM: " + DTOC(Date()) + " TIME: " + Time())
	
Return()