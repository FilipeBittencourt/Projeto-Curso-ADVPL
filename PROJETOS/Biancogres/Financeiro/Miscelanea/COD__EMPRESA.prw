#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} COD__EMPRESA
@author Tiago Rossini Coradini
@since 10/02/2017
@version 2.0
@description Retorna identificador do cliente no Bradesco por empresa, especifico para recebimento 
@obs OS: 3663-16 - Vagner Amaro
@type function
/*/

User Function COD__EMPRESA()
Local cRet := ""

	If SM0->M0_CODIGO == "01"
		
		cRet := "00000000000000225935
		
	ElseIf SM0->M0_CODIGO == "05" 
		
		cRet := "00000000000004155892"
		
	ElseIf SM0->M0_CODIGO == "07"
				
		cRet := "00000000000007810633"
		
	EndIf

Return(cRet)