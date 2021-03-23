#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TSubitemProjeto
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Classe com regras de negocio
@obs Projeto: D-01 - Custos dos Projetos
@type Class
/*/

Class TSubitemProjeto From LongClassName

	Data cClvl // Classe de valor
	Data cItemCta // Item contabil
	Data cSubItem // Subitem Projeto
	
	Method New() Constructor
	Method Validate()
	Method Exist()
	Method GetCod()
	Method GetDesc()	
	
EndClass


Method New() Class TSubitemProjeto
		
	::cClvl := Space(TamSx3("ZMA_CLVL")[1])	
	::cItemCta := Space(TamSx3("ZMA_ITEMCT")[1])
	::cSubItem := Space(TamSx3("ZMB_SUBITE")[1])
	
Return()


Method Validate() Class TSubitemProjeto
Local lRet := .T.
	
	If SubStr(::cClvl, 1, 1) == "8"
	
		lRet := ::Exist()
		
	EndIf
	
Return(lRet)


Method Exist() Class TSubitemProjeto
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL := " SELECT COUNT(ZMB_SUBITE) AS COUNT " 
	cSQL += " FROM "+ RetSQLName("ZMA") + " ZMA "
	cSQL += " INNER JOIN "+ RetSQLName("ZMB") + " ZMB "
	cSQL += " ON ZMA_CODIGO = ZMB_CODREF
	cSQL += " WHERE ZMA_FILIAL = "+ ValToSQL(xFilial("ZMA"))
	cSQL += " AND ZMA_CLVL = "+ ValToSQL(::cClvl)
	cSQL += " AND ZMA_ITEMCT = "+ ValToSQL(::cItemCta)
	cSQL += " AND ZMA.D_E_L_E_T_ = '' "
	cSQL += " AND ZMB_FILIAL = "+ ValToSQL(xFilial("ZMB"))
	cSQL += " AND ZMB_SUBITE = "+ ValToSQL(::cSubItem)
	cSQL += " AND ZMB.D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)
	
	lRet := (cQry)->COUNT > 0
			
	(cQry)->(DbCloseArea())	
		
Return(lRet)


Method GetCod() Class TSubitemProjeto
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()	

	cSQL := " SELECT ISNULL(ZMA_CODIGO, '') AS ZMA_CODIGO " 
	cSQL += " FROM "+ RetSQLName("ZMA") + " ZMA "
	cSQL += " WHERE ZMA_FILIAL = "+ ValToSQL(xFilial("ZMA"))
	cSQL += " AND ZMA_CLVL = "+ ValToSQL(::cClvl)
	cSQL += " AND ZMA_ITEMCT = "+ ValToSQL(::cItemCta)
	cSQL += " AND ZMA.D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)
	
	cRet := (cQry)->ZMA_CODIGO
			
	(cQry)->(DbCloseArea())	
		
Return(cRet)


Method GetDesc() Class TSubitemProjeto
Local cRet := ""
Local cSQL := ""
Local cQry := GetNextAlias()	

	cSQL := " SELECT ZMB_DESC " 
	cSQL += " FROM "+ RetSQLName("ZMA") + " ZMA "
	cSQL += " INNER JOIN "+ RetSQLName("ZMB") + " ZMB "
	cSQL += " ON ZMA_CODIGO = ZMB_CODREF
	cSQL += " WHERE ZMA_FILIAL = "+ ValToSQL(xFilial("ZMA"))
	cSQL += " AND ZMA_CLVL = "+ ValToSQL(::cClvl)
	cSQL += " AND ZMA_ITEMCT = "+ ValToSQL(::cItemCta)
	cSQL += " AND ZMA.D_E_L_E_T_ = '' "
	cSQL += " AND ZMB_FILIAL = "+ ValToSQL(xFilial("ZMB"))
	cSQL += " AND ZMB_SUBITE = "+ ValToSQL(::cSubItem)
	cSQL += " AND ZMB.D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)
	
	cRet := (cQry)->ZMB_DESC
			
	(cQry)->(DbCloseArea())	
		
Return(cRet)