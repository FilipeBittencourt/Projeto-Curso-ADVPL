#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} DARFVAL
@author Wlysses Cerqueira (Facile)
@since 28/01/2020
@version 1.0
@description Chamado no momento da impressao da DARF - FINA373
@type class
/*/

User Function _DARFVAL() // Nao usar

	Local aInfo := PARAMIXB[1]
	Local oObj := TFaturaPagarDarf():New()
	
	If Len(aInfo) > 0

		//If MsgYesNo("Deseja gerar a fatura agora?")
		
			U_BIAMsgRun("Aguarde... Gerando fatura",,{|| oObj:IncluirFatura(aInfo)})

		//EndIf

	EndIf

Return(aInfo)