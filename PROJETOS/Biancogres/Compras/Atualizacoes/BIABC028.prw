#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
/*/{Protheus.doc} BIABC028
@author Barbara Luan Gomes Coelho
@since 31/05/21
@version 1.1
@description Consulta na tabela de produto por registros que utilizem a conta contábil
@type function
/*/                                                                                               
User Function BIABC028(cCtCtbl)
Local cSQL := ""
Local cQrySB1 := GetNextAlias()
Local _aArea   := GetArea()
Local QtdProd := 0

	cSQL := " SELECT COUNT(1) QTD"
	cSQL += "   FROM " + RetSQLName("SB1")
	cSQL += "  WHERE (B1_CONTA = " + ValToSQL(cCtCtbl)
	cSQL += "     OR B1_YCTARES = " + ValToSQL(cCtCtbl)
	cSQL += "     OR B1_YCTRADM = " + ValToSQL(cCtCtbl)
	cSQL += "     OR B1_YCTRIND = " + ValToSQL(cCtCtbl)
	cSQL += ")    AND B1_MSBLQL <> '1' "
	cSQL += "    AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQrySB1)
	
	QtdProd :=  (cQrySB1)->QTD

	(cQrySB1)->(DbCloseArea())
	
	RestArea(_aArea)	
	
Return(QtdProd)