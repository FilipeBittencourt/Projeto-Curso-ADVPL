#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF096
@author Tiago Rossini Coradini
@since 07/02/2018
@version 1.0
@description Rotina para validar motivos de cancelamento dos pedidos de venda 
@obs Ticket: 2123
@type Function
/*/

User Function BIAF096(cMot)
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT X5_DESCRI "
	cSQL += " FROM " + RetSqlName("SX5")
	cSQL += " WHERE X5_FILIAL = " + ValToSQL(xFilial("SX5"))
	cSQL += " AND X5_TABELA = 'ZZ' "
	cSQL += " AND X5_CHAVE = " + ValToSQL(cMot)
	cSQL += " AND D_E_L_E_T_ = '' " 

	TcQuery cSQL New Alias (cQry)

	lRet := (cQry)->(!Eof())

	If !lRet
		MsgAlert("Favor informar um código valido!")
	EndIf

	(cQry)->(DbCloseArea())

Return(lRet)