#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF072
@author Tiago Rossini Coradini
@since 20/08/2018
@version 1.1
@description Rotina para chamada da tela de atualização de informações da solicitação de compra 
@obs Ticket: 7663
@type function
/*/

User Function BIAF072()
Local oObj := Nil 
	
	If U_VALOPER("051")
		
		If fPedLib()
	
			oObj := TWAtualizaSolicitacaoCompra():New()
		
			oObj:Activate()
			
		Else
		
			MsgInfo("Somente é permitido atualizar solicitações de compra em aberto.")
			
		EndIf
		
	EndIf
	
Return()


Static Function fPedLib()
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()	
	
	cSQL := " SELECT COUNT(C1_PRODUTO) AS COUNT " 
	cSQL += " FROM "+ RetSQLName("SC1")
	cSQL += " WHERE C1_FILIAL = "+ ValToSQL(xFilial("SC1"))
	cSQL += " AND C1_NUM = "+ ValToSQL(SC1->C1_NUM)
	cSQL += " AND C1_QUJE = 0 "
	cSQL += " AND C1_COTACAO = '' "
	cSQL += " AND C1_APROV IN ('', 'L') "
	cSQL += " AND D_E_L_E_T_ = '' " 

	TcQuery cSQL New Alias (cQry)
	
	lRet := (cQry)->COUNT > 0
	
(cQry)->(DbCloseArea())
			
Return(lRet)