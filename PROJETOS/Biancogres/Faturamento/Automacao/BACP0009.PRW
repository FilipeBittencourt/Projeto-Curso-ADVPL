#Include "TOTVS.CH"
#Include "Protheus.CH"

/*/{Protheus.doc} BACP0009
@description Menu para chaamar tela do monitor de Faturamento
@author Fernando Rocha / Ciclo do Pedido
@since 07/08/2019
@version 1.0
@type function
/*/
User Function BACP0009

	Local oTela

	oTela := TFaturamentoMonitor():New()
	oTela:Show()

Return