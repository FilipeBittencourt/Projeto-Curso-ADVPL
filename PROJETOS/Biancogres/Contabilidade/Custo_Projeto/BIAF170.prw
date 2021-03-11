#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF170
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Ferramenta para Importar Orcamento de Clvl via Planilha Excel 
@obs Projeto: D-01 - Custos dos Projetos
@type Function
/*/

User Function BIAF170()
Local oObj := Nil
		
	oObj := TWImportOrcamentoClvl():New()

	oObj:Activate()
		
Return()