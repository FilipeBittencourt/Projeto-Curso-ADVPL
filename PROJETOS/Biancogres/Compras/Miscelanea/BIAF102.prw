#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF102
@author Tiago Rossini Coradini
@since 04/04/2018
@version 1.0
@description Adiciona rotinas ao menu de atualizacao de cotacoes(MATA150)
@obs Ticket: 3750
@type Function
/*/

User Function BIAF102(aRotina)
	
	aAdd(aRotina, {"Analisa Cotação", U_BIAF102A(), 0, 6})	
	
Return()

 
User Function BIAF102A()

	cRet := "U_BIAMsgRun('Analisando cotação: ' + SC8->C8_NUM + '...', 'Aguarde!', {|| U_BIAF102B(Recno()) })"
	
Return(cRet)


User Function BIAF102B(nRec)

	l150Inclui := .F. 
	l150Propost := .F. 
	l150Deleta := .F.
		
	//MATA161(Nil, 6, .T.)
	MATA161('SC8',SC8->(RecNo()),4)

Return()
