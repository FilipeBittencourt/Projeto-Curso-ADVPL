#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF164
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Conciliacao Contabil - Clientes 
@obs Projeto: A-54
@type Function
/*/

User Function BIAF164()
Local oParam := TParBIAF164():New()
			
	If oParam:Box()
					
		U_BIAMsgRun("Exportando Conciliacao Contabil de Clientes...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
Return()


Static Function fProcess(oParam)
Local oObj := Nil
		
	oObj := TConciliacaoContabilCliente():New(oParam)

	oObj:Export()

Return()