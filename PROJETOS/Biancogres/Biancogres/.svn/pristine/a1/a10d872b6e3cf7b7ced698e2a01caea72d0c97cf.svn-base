#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT131FIL
@author Luana Marin Ribeiro
@version 1.0
@description Ponto de Entrada que realiza filtro para exibição das SCs no Gera Cotação
@type function
/*/


User Function MT131FIL()

	Local FilSc1 := ""
	Local FilQue :=	""
	Local Filtro := {}	

	FilQue := " ((C1_PRODUTO NOT IN (SELECT AIB_CODPRO "
	FilQue += "		FROM " + RetSqlName("AIB") + " B "
	FilQue += "		INNER JOIN " + RetSqlName("AIA") + " A ON A.AIA_CODFOR = B.AIB_CODFOR "
	FilQue += "			AND A.AIA_LOJFOR = B.AIB_LOJFOR "
	FilQue += "			AND A.AIA_CODTAB = B.AIB_CODTAB "
	FilQue += "			AND '" + dtos(dDataBase) + "' BETWEEN A.AIA_DATDE AND A.AIA_DATATE "
	FilQue += "			AND B.AIB_DATVIG >= '" + dtos(dDataBase) + "' "
	FilQue += "			AND C1_PRODUTO = B.AIB_CODPRO "
	FilQue += "			AND A.D_E_L_E_T_ = '' "
	FilQue += "			AND B.D_E_L_E_T_ = '')) "
	FilQue += "	OR (C1_YATSERV = 'T' "
	FilQue += " 	AND C1_PRODUTO IN (SELECT AIB_CODPRO "
	FilQue += "			FROM " + RetSqlName("AIB") + " B "
	FilQue += "			INNER JOIN " + RetSqlName("AIA") + " A ON A.AIA_CODFOR = B.AIB_CODFOR "
	FilQue += "				AND A.AIA_LOJFOR = B.AIB_LOJFOR "
	FilQue += "				AND A.AIA_CODTAB = B.AIB_CODTAB "
	FilQue += "				AND '" + dtos(dDataBase) + "' BETWEEN A.AIA_DATDE AND A.AIA_DATATE "
	FilQue += "				AND B.AIB_DATVIG >= '" + dtos(dDataBase) + "' "
	FilQue += "				AND C1_PRODUTO = B.AIB_CODPRO "
	FilQue += "				AND A.D_E_L_E_T_ = '' "
	FilQue += "				AND B.D_E_L_E_T_ = ''))) "

	aadd(Filtro, FilSc1)
	aadd(Filtro, FilQue)

Return Filtro
