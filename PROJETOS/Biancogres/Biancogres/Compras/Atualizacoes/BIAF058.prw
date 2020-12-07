#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF058
@author Tiago Rossini Coradini
@since 19/12/2016
@version 2.0
@description Atualização do codigo do produto no fornecedor nos pedidos de compra em aberto e itens do totvs colaboração, 
ao efetuar atualização no cadastro de produto x fornecedor. 
@obs OS: 4540-16 - Jesebel Brandao
@type function
/*/

User Function BIAF058(cCodPrd)
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT A5_FORNECE, A5_LOJA, A5_PRODUTO, A5_CODPRF "
	cSQL += " FROM " + RetSQLName("SA5") + " SA5 "
	cSQL += " INNER JOIN " + RetSQLName("SB1") + " SB1 "	
	cSQL += " ON A5_PRODUTO = B1_COD "
	cSQL += " WHERE A5_FILIAL = " + ValToSQL(xFilial("SA5"))
	cSQL += " AND A5_PRODUTO = " + ValToSQL(cCodPrd)
	cSQL += " AND A5_FABR IN " 
	cSQL += " ( "
	cSQL += " 	SELECT MAX(A5_FABR) AS A5_FABR " 
	cSQL += " 	FROM " + RetSQLName("SA5") 
	cSQL += " 	WHERE A5_FILIAL = '' "
	cSQL += " 	AND A5_FORNECE = SA5.A5_FORNECE " 
	cSQL += " 	AND A5_PRODUTO = SA5.A5_PRODUTO " 
	cSQL += " 	AND D_E_L_E_T_ = '' "
	cSQL += " ) "
	cSQL += " AND A5_CODPRF <> '' "	
	cSQL += " AND SA5.D_E_L_E_T_ = '' "	
	cSQL += " AND B1_FILIAL = '' "
	cSQL += " AND B1_MSBLQL <> '1' "
	cSQL += " AND SUBSTRING(B1_GRUPO, 1, 3) IN ('102', '104', '107') "
	cSQL += " AND SB1.D_E_L_E_T_ = '' "
	cSQL += " GROUP BY A5_FORNECE, A5_LOJA, A5_PRODUTO, A5_CODPRF	"
	
	TcQuery cSQL New Alias (cQry)
	
	While !(cQry)->(Eof())

		// Atualiza pedidos de compra		
		cSQL :=	" UPDATE " + RetSQLName("SC7")
		cSQL += " SET C7_YPRDFOR = " + ValToSQL((cQry)->A5_CODPRF)
		cSQL += " WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
		cSQL += " AND C7_FORNECE = "+ ValToSQL((cQry)->A5_FORNECE)
		cSQL += " AND C7_LOJA = "+ ValToSQL((cQry)->A5_LOJA)
		cSQL += " AND C7_PRODUTO = "+ ValToSQL((cQry)->A5_PRODUTO)
		cSQL += " AND C7_CONAPRO = 'L' "
		cSQL += " AND C7_QUJE = 0 "
		cSQL += " AND C7_QTDACLA = 0 "
		cSQL += " AND C7_RESIDUO = '' "
		cSQL += " AND D_E_L_E_T_ = '' "				
				
		TcSQLExec(cSQL)
		
		
		// Atualiza itens do Totvs colaboração que ainda não geraram nota 
		cSQL :=	" UPDATE " + RetSQLName("SDT")
		cSQL += " SET DT_PRODFOR = " + ValToSQL((cQry)->A5_CODPRF)
		cSQL += " WHERE DT_FILIAL = " + ValToSQL(xFilial("SDT"))
		cSQL += " AND DT_FORNEC = "+ ValToSQL((cQry)->A5_FORNECE)
		cSQL += " AND DT_LOJA = "+ ValToSQL((cQry)->A5_LOJA)
		cSQL += " AND DT_COD = "+ ValToSQL((cQry)->A5_PRODUTO)
		cSQL += " AND D_E_L_E_T_ = '' " 						
		cSQL += " AND EXISTS 
		cSQL += " ( "
		cSQL += " 	SELECT DS_STATUS "
		cSQL += " 	FROM " + RetSQLName("SDS")
		cSQL += " 	WHERE DS_FILIAL = DT_FILIAL "
		cSQL += " 	AND DS_DOC = DT_DOC "
		cSQL += " 	AND DS_SERIE = DT_SERIE "
		cSQL += " 	AND DS_FORNEC = DT_FORNEC "
		cSQL += " 	AND DS_LOJA = DT_LOJA "
		cSQL += " 	AND DS_STATUS = '' "
		cSQL += " 	AND D_E_L_E_T_ = '' "
		cSQL += " ) "
				
		TcSQLExec(cSQL)		
		
		(cQry)->(DbSkip())
		
	EndDo

	(cQry)->(DbCloseArea())	
	
Return()