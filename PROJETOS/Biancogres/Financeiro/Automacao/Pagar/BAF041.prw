#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF041
@author Tiago Rossini Coradini
@since 22/10/2019
@project Automação Financeira
@version 1.0
@description Define CNPJ da empresa matriz nas remessas de pagamento
@type function
/*/

User Function BAF041(cCnpj)
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT TOP 1 ISNULL(Z35_CNPJ, '') AS Z35_CNPJ "
	cSQL += " FROM " + RetSQLName("Z35")
	cSQL += " WHERE Z35_FILIAL = " + ValToSQL(xFilial("Z35"))
	cSQL += " AND SUBSTRING(Z35_CNPJ, 1, 8) = " + ValToSQL(SubStr(cCnpj, 1, 8))
	cSQL += " AND D_E_L_E_T_ = ''
	cSQL += " ORDER BY Z35_EMP, Z35_FIL "

	TcQuery cSQL New Alias (cQry)

	If !Empty((cQry)->Z35_CNPJ)
		
		cRet := (cQry)->Z35_CNPJ
		
	Else
	
		cRet := cCnpj
		
	EndIf

	(cQry)->(DbCloseArea())	
		
Return(cRet)