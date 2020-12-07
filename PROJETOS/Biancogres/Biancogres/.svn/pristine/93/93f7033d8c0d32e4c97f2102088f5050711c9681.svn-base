#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F090NLOTE
@author Tiago Rossini Coradini
@since 19/03/2018
@version 1.0
@description Permite modificar o numero do lote financeiro na rotina de baixa a pagar automática  
@obs Ticket: 3172
@type Function
/*/

User Function F090NLOTE()
Local aArea := GetArea()
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT MAX(E5_LOTE) AS E5_LOTE "
	cSQL += " FROM " + RetSQLName("SE5")
	cSQL += " WHERE E5_FILIAL = " + ValToSQL(xFilial("SE5"))
	cSQL += " AND E5_LOTE <> '' "
	cSQL += " AND E5_RECPAG = 'P' "	
	cSQL += " AND D_E_L_E_T_ = '' "
		
	TcQuery cSQL New Alias (cQry)
	  			
	If !Empty((cQry)->E5_LOTE)
		
		clotefin := Soma1((cQry)->E5_LOTE)
		
	Else
	
		clotefin := "0001"
	
	EndIf
	
	(cQry)->(dbCloseArea())		
	
	RestArea(aArea)

Return()