#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} A120PIDF
@author Tiago Rossini Coradini
@since 19/01/2018
@version 1.0
@description Ponto de entrada para filtrar solicitacoes de compra no F4 da tela do pedido de compra
@obs OS: 1428-17 - Claudia Carvalho
@obs Ticket: 1449 - Projeto Demandas Compras - Item 3
@type function
/*/

User Function A120PIDF()
Local aArea := GetArea()
Local aFil := {}
Local oParam := TParA120PIDF():New()

	aAdd(aFil, fGetFilPad()) 

	If oParam:Box() .And. Upper(SubStr(oParam:cFilSC, 1, 1)) $ "C/S"
		
		aFil[Len(aFil)] += " .And. C1_PRODUTO $ '" + fGetFilPrd(oParam) + "'"
		
	EndIf		
		
	RestArea(aArea)
		
Return(aFil)


Static Function fGetFilPad()
Local cRet := ""

	cRet := " C1_FILIAL == " + ValToSQL(xFilial("SC1"))
	cRet += " .And. C1_QUJE < C1_QUANT "
	cRet += " .And. C1_TPOP <> 'P' "
	cRet += " .And. C1_APROV $' ,L' "
	cRet += " .And. (C1_COTACAO == "+ ValToSQL(Space(Len(SC1->C1_COTACAO))) + " .Or. C1_COTACAO == "+ ValToSQL(Replicate("X", Len(SC1->C1_COTACAO))) + ")"
	cRet += " .And. C1_FLAGGCT <> '1' "
	cRet += " .And. C1_ACCPROC <> '1' "
	cRet += " .And. C1_TPSC <> '2' " 
	cRet += " .And. Empty(C1_RESIDUO) "
	
Return(cRet)


Static Function fGetFilPrd(oParam)
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()
		
	cSQL := " SELECT C1_PRODUTO "
	cSQL += " FROM " + RetSQLName("SC1")
	cSQL += " WHERE C1_FILIAL = " + ValToSQL(xFilial("SC1"))
	cSQL += " AND C1_ACCPROC <> '1' "
	cSQL += " AND C1_TPSC <> '2' "
	cSQL += " AND C1_QUJE < C1_QUANT "
	cSQL += " AND C1_TPOP <> 'P' "
	cSQL += " AND C1_APROV IN (' ', 'L') "
	cSQL += " AND (C1_COTACAO = "+ ValToSQL(Space(Len(SC1->C1_COTACAO))) + " OR C1_COTACAO = "+ ValToSQL(Replicate("X", Len(SC1->C1_COTACAO))) + ")"
	cSQL += " AND C1_FLAGGCT <> '1' "
	cSQL += " AND C1_RESIDUO = ''	"
	cSQL += " AND C1_PRODUTO "
	
	If Upper(SubStr(oParam:cFilSC, 1, 1)) == "C"
		cSQL += " IN "
	Else
		cSQL += " NOT IN "
	EndIf
	
	cSQL += " ( "
	cSQL += " 	SELECT AIB_CODPRO " 
	cSQL += " 	FROM " + RetSQLName("AIB")
	cSQL += " 	WHERE AIB_FILIAL = " + ValToSQL(xFilial("AIB"))
	cSQL += " 	AND AIB_DATVIG >= " + ValToSQL(dDataBase)
	cSQL += " 	AND D_E_L_E_T_ = '' "		
	cSQL += " 	GROUP BY AIB_CODPRO "	
	cSQL += " ) "
	cSQL += " AND D_E_L_E_T_ = '' "
	cSQL += " GROUP BY C1_PRODUTO "	

	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())
		
		cRet += ((cQry)->C1_PRODUTO) + "/"		
		
		(cQry)->(DbSkip())
		
	EndDo()	
	
	(cQry)->(DbCloseArea())

Return(cRet)