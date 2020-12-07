#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF021
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Processa remessa de titulos a pagar do tipo GNR-e.
@type function
/*/

User Function BAF021()

	Local aAreaSE2 := SE2->(GetArea())
	Local aAreaSEA := SEA->(GetArea())

	oObj := TAFRemessaPagar():New()
	oObj:oMrr:lGnre := .T.
	oObj:Send()

	RestArea(aAreaSE2)
	RestArea(aAreaSEA)
						
Return()