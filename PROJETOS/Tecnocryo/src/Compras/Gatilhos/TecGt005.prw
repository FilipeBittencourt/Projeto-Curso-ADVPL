#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function TecGt005
Local aArea  := GetArea()
Local cSql   := ""
Local cAlias := "TBLTMP"
Local cRet   := ""
Local cGrupo := M->B1_GRUPO
Local cMax   := Padl("1", 6, "0")

	If Empty(cGrupo)
		cGrupo := "ZZZZ"
	End If 

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	cSql := "SELECT MAX(SUBSTRING(B1_COD, 5, 6)) MAX "
	cSql += "  FROM " + RetSqlName("SB1")
	cSql += " WHERE B1_FILIAL = '" + xFilial("SB1") + "' "
	cSql += "   AND SUBSTRING(B1_COD , 1, 4) = '" + cGrupo + "' "
	cSql += "   AND LEN(RTRIM(B1_COD)) = 10 "
	cSql += "   AND D_E_L_E_T_ != '*'"

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAlias,.T.,.T.)
		
	If (cAlias)->(!Eof())
		cMax := Soma1((cAlias)->MAX)
	End If
	
	(cAlias)->(DbCloseArea())
	
	cRet := PadR(cGrupo + cMax, TamSX3("B1_COD")[1], " ")
	
	RestArea(aArea)
Return(cRet)