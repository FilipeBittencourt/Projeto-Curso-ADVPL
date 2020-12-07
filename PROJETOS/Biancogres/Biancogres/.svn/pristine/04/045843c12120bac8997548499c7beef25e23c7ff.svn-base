#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} SE5FI70E
@author Wlysses Cerqueira (Facile)
@since 31/03/2020
@version 1.0
@description Chamado antes da gravação dos dados do SE5 referentes ao cancelamento da baixa,
esta dentro de uma transacao.
@type class
/*/

User Function SE5FI70E()

    Local oObjDepId := TAFProrrogacaoBoletoReceber():New(.F.)

    oObjDepId:EstBxDepAntJR()

Return()