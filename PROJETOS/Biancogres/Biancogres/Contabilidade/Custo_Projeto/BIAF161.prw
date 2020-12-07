#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF161
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Relatorio de Custos dos Projetos - Analítico / Sintético
@obs Projeto: D-01 - Custos dos Projetos
@type Function
/*/

User Function BIAF161()
Local oParam := TParBIAF161():New()
			
	If oParam:Box()
					
		U_BIAMsgRun("Selecionando Contratos...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
Return()


Static Function fProcess(oParam)
Local oObj := Nil
		
	oObj := TWCustoProjeto():New(oParam)

	oObj:Activate()

Return()