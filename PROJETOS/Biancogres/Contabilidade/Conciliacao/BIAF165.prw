#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF165
@author Tiago Rossini Coradini
@since 09/01/2020
@version 1.0
@description Conciliacao Contabil - Fornecedores 
@obs Projeto: A-54
@type Function
/*/

User Function BIAF165()
Local oParam := TParBIAF165():New()
			
	If oParam:Box()
					
		U_BIAMsgRun("Exportando Conciliacao Contabil de Fornecedores...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
Return()


Static Function fProcess(oParam)
Local oObj := Nil
		
	oObj := TConciliacaoContabilFornecedor():New(oParam)

	oObj:Export()

Return()