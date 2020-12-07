#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT150ROT
@author Tiago Rossini Coradini
@since 04/04/2018
@version 1.0
@description Ponto de entrada para adicionar rotinas ao menu de atualizacao de cotacoes(MATA150)
@obs Ticket: 3750
@type Function
/*/

User Function MT150ROT()

	U_BIAF102(@aRotina)
	     
Return(aRotina)