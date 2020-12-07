#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BAF036
@author Tiago Rossini Coradini
@since 01/07/2019
@project Automação Financeira
@version 1.0
@description Processa desconciliacao de extrato e movimento bancario
@type function
/*/

User Function BAF036()
Local oParam := TParBAF036():New()

	If oParam:Box()
					
		U_BIAMsgRun("Desconciliando Extrato e Movimento Bancário...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
Return()


Static Function fProcess(oParam)
Local oObj := Nil
		
	oObj := TAFDesconciliacaoBancaria():New(oParam)

	oObj:Process()

Return()