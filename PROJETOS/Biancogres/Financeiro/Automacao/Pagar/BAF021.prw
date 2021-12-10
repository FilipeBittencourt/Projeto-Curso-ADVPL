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

	Local aAreaSE2 := {}
	Local aAreaSEA := {}

	/*
	If Select("SX6") == 0
		RPCSetEnv("07", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
	EndIf
  */

	aAreaSE2 := SE2->(GetArea())
	aAreaSEA := SEA->(GetArea())

	oObj := TAFRemessaPagar():New()
	oObj:oMrr:lGnre := .T.
	oObj:Send()

	RestArea(aAreaSE2)
	RestArea(aAreaSEA)

Return()