#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF015
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automação Financeira
@version 1.0
@description Teste remessa a receber - Geracao de bordero e envio de boletos para a API 
@type function
/*/

User Function BAF015()

	Local aArea := Nil
	Local oParam := Nil
	Local lJob := !(Select("SX2") > 0)
	
	If lJob
	
		RpcSetEnv("01", "01")
		
	EndIf
	
	aArea := GetArea()
	oParam := TParBAF015():New()
			
	If oParam:Box()
					
		U_BIAMsgRun("Processando remessa a pagar de títulos...", "Aguarde!", {|| fProcess(oParam) })
				
	EndIf
	
	RestArea(aArea)
	
	If lJob
	
		RpcClearEnv()
	
	EndIf
	
Return()


Static Function fProcess(oParam)

	Local oObj := Nil
	Local aAreaSE2 := SE2->(GetArea())
	Local aAreaSEA := SEA->(GetArea())
			
	oObj := TAFRemessaPagar():New()
	
	oObj:oMrr:lScreen := .T.
	
	oObj:oMrr:cBorDe := oParam:cBorDe
	oObj:oMrr:cBorAte := oParam:cBorAte

	oObj:Send()

	RestArea(aAreaSE2)
	RestArea(aAreaSEA)
	
Return()