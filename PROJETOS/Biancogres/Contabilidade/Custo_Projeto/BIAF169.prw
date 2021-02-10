#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF169
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Ferramenta para controlar Orçamento Clvl 
@obs Projeto: D-01 - Custos dos Projetos
@type Function
/*/

User Function BIAF169()
Private aRotina := {}
Private cCadastro := "Orçamento Clvl"
Private cAlias := "ZMC"

	aAdd(aRotina, {"Pesquisar" , "PesqBrw", 0, 1})
	aAdd(aRotina, {"Visualizar", "U_BIAF169A", 0, 2})
	aAdd(aRotina, {"Incluir", "U_BIAF169A", 0, 3})
	aAdd(aRotina, {"Alterar", "U_BIAF169A", 0, 4})
	aAdd(aRotina, {"Excluir", "U_BIAF169A", 0, 5})		
	                                               
	DbSelectArea(cAlias)
	DbSetOrder(1)

	mBrowse(,,,,cAlias)

Return()


User Function BIAF169A(cAlias, nRecno, nOpc)
Local oObj := TWOrcamentoClvl():New()
		
	If nOpc == 2 .Or. nOpc == 4 .Or. nOpc == 5 

		oObj:cCodigo := ZMA->ZMA_CODIGO
		oObj:cClvl := ZMA->ZMA_CLVL
		oObj:cItemCta := ZMA->ZMA_ITEMCT
			
	EndIf
	
	oObj:nFDOpc := nOpc
	
	oObj:Activate()
		
Return()