#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF166
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Conciliacao Contabil - Intercompany
@obs Projeto: A-54
@type Function
/*/

User Function BIAF166()
Local oParam := TParBIAF166():New()
			
	If oParam:Box()
					
		U_BIAMsgRun("Exportando Conciliacao Contabil Intercompany...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
Return()


Static Function fProcess(oParam)
Local oObj := Nil
		
	oObj := TConciliacaoContabilIntercompany():New(oParam)

	oObj:Export()

Return()