#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT121BRW
@author Tiago Rossini Coradini
@since 10/01/2017
@version 1.0
@description Adiciona opções no menu da rotina de pedido de compra 
@obs Ponto de entrada
@type function
/*/

User Function MT121BRW() 

	aAdd(aRotina, {"Envia E-mail", "U_BIAF091(SC7->C7_NUM, 'M')", 0, 1, 0, .F. })
	aAdd(aRotina, {"Confirma Manual", "U_BIAF094()", 0, 1, 0, .F. })
	aAdd(aRotina, {"Imp Ped Confirm", "U_BIAFR012()", 0, 1, 0, .F. })
	aAdd(aRotina, {"E-mail Follow Up", "U_ATRA_FORN()", 0, 1, 0, .F. })	
	aAdd(aRotina, {"Altera Fornecedor", "U_BIAF098()", 0, 1, 0, .F. })
	aAdd(aRotina, {"Pedido Auditoria", "U_BIAFR016()", 0, 1, 0, .F. })
	aAdd(aRotina, {"Altera Comprador", "U_BIABC010()", 0, 1, 0, .F. })
	
Return()