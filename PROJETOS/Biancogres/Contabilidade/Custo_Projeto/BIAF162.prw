#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF162
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Ferramenta para Importar Subitem via Planilha Excel 
@obs Projeto: D-01 - Custos dos Projetos
@type Function
/*/

User Function BIAF162()
Local oObj := Nil
		
	oObj := TWImportSubitemContrato():New()

	oObj:Activate()
		
Return()