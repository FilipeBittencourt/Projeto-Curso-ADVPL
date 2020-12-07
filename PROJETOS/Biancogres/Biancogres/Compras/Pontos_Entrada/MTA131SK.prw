#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MTA131SK
@author Tiago Rossini Coradini
@since 18/01/2018
@version 1.0
@description Ponto de entrada ao gerar cotações, utilizado para bloquer a geração cotações de produtos com tabela de preço vigente.
@obs OS: 1428-17 - Claudia Carvalho
@obs Ticket: 1449 - Projeto Demandas Compras - Item 3
@type function
/*/

User Function MTA131SK()
Local lRet := .T.

	If fTabPrc() .Or. fGrpPrd()
		
		lRet := .F.
		
	EndIf

Return(lRet)


Static Function fTabPrc()
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()
              
	cSQL := " SELECT COUNT(AIB_CODPRO) AS QUANT "
	cSQL += " FROM " + RetSQLName("AIB")
	cSQL += " WHERE AIB_FILIAL = " + ValToSQL(xFilial("SRA"))
	cSQL += " AND AIB_CODPRO = " + ValToSQL(SC1->C1_PRODUTO)
	cSQL += " AND AIB_DATVIG >= " + ValToSQL(dDataBase)
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If (cQry)->QUANT >= 1
		
		lRet := .T.
		
		MsgAlert("Atenção, o produto: " + AllTrim(SC1->C1_PRODUTO) + " - item: " + SC1->C1_ITEM + " da SC: " + SC1->C1_NUM +;
					 	 " possui tabela de preço vigente cadastrada e não poderá gerar cotações", "MTA131SK")
					 	 
	EndIf
	
	(cQry)->(DbCloseArea())

Return(lRet)


Static Function fGrpPrd()
Local lRet := .F.
Local cSQL := ""
Local cQry := GetNextAlias()
              
	cSQL := " SELECT B1_GRUPO "
	cSQL += " FROM " + RetSQLName("SB1")
	cSQL += " WHERE B1_FILIAL = " + ValToSQL(xFilial("SB1"))
	cSQL += " AND B1_COD = " + ValToSQL(SC1->C1_PRODUTO)
	cSQL += " AND SUBSTRING(B1_GRUPO, 1, 3) BETWEEN '100' AND '199' "
	cSQL += " AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->B1_GRUPO)
		
		lRet := .T.		
		
		MsgAlert("Atenção, o produto: " + AllTrim(SC1->C1_PRODUTO) + " - item: " + SC1->C1_ITEM + " da SC: " + SC1->C1_NUM +;
					 	 " não poderá gerar cotações, pois está associado ao grupo: "+ (cQry)->B1_GRUPO +".", "MTA131SK")
					 	 
	EndIf
	
	(cQry)->(DbCloseArea())

Return(lRet)