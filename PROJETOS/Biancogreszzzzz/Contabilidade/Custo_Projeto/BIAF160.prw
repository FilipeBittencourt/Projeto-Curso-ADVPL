#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF160
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Ferramenta para controlar os custos dos projetos - Tabela de cadastro de Subitem de Projeto 
@obs Projeto: D-01 - Custos dos Projetos
@type Function
/*/

User Function BIAF160(cClvl, cItemCta, cSubItem)
Local lRet := .T.
Local oObj := TSubitemProjeto():New()

	Default cClvl := ""
	Default cItemCta := ""
	Default cSubItem := ""

	oObj:cClvl := cClvl
	oObj:cItemCta := cItemCta
	oObj:cSubItem := cSubItem
	
	lRet := oObj:Validate()
	
Return(lRet)