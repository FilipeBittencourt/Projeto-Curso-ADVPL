#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF014
@author Tiago Rossini Coradini
@since 11/10/2018
@project Automação Financeira
@version 1.0
@description Teste remessa a receber - Geracao de bordero e envio de boletos para a API 
@type function
/*/

User Function BAF014()

	Local aArea := Nil
	Local oParam := Nil
	Local lJob := !(Select("SX2") > 0)
	
	If lJob
			
		RpcSetEnv("01", "01")
		
	EndIf
	
	aArea := GetArea()
	oParam := TParBAF014():New()
			
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
	
	If dDataBase == oParam:dVencReDe
	
		oObj:oMrr:lScreen := .T.
		
		oObj:oMrr:dVencReDe := oParam:dVencReDe
		//oObj:oMrr:dVencReAte := oParam:dVencReAte
		//oObj:oMrr:cNum := oParam:cNum
		//oObj:oMrr:cPrefixo := oParam:cPrefixo
		//oObj:oMrr:cTipo := oParam:cTipo
		oObj:oMrr:cForneceDe := oParam:cForneceDe
		oObj:oMrr:cLojaDe := oParam:cLojaDe
		
		oObj:oMrr:cForneceAte := oParam:cForneceAte
		oObj:oMrr:cLojaAte := oParam:cLojaAte
		
		oObj:Send()
	
	Else
	
		MsgAlert("A database está diferente do vencimento informado!", "ATENCAO")
	
	EndIf

	RestArea(aAreaSE2)
	RestArea(aAreaSEA)
		
Return()