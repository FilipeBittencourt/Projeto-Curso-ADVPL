#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF023
@author Wlysses Cerqueira
@since 21/05/2019
@project Automação Financeira
@version 1.0
@description Processa titulos NDF para compensacao automatica
@type function
/*/

User Function BAF023()

	Local oObj := Nil
	
	ConOut("TAF => BAF023 - COMPENSACAO AUTOMATICA DE TITULOS NDF - INICIO: " + DTOC(Date()) + " TIME: " + Time())
	
	oObj := TCompensacaoPagar():New()
	
	oObj:Devolucao()
	
	ConOut("TAF => BAF023 - COMPENSACAO AUTOMATICA DE TITULOS NDF - FIM: " + DTOC(Date()) + " TIME: " + Time())
	
Return()