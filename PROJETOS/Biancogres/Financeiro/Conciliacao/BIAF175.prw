#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF175
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Conciliacao Extrato x Contabilidade
@obs Projeto: A-54
@type Function
/*/

User Function BIAF175()
Local oParam := TParBIAF175():New()
			
	If oParam:Box()
					
		U_BIAMsgRun("Exportando Conciliacao de Extrato x Contabilidade...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
Return()


Static Function fProcess(oParam)
Local oObj := Nil
		
	oObj := TConciliacaoExtratoContabilidade():New(oParam)

	oObj:Export()

Return()