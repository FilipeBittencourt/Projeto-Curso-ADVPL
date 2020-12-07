#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF019
@author Tiago Rossini Coradini
@since 13/03/2019
@project Automação Financeira
@version 1.0
@description Processa retorno, baixas e conciliação de DDA de titulos a pagar manualmente
@type function
/*/

User Function BAF019(cPar)

	If cPar == "A"
	
		If MsgYesNo("Deseja realmente processar os retornos bancários?", "Automação Financeira")
			
			U_BIAMsgRun("Processando retornos bancários...", "Aguarde!", {|| fRetornoPagar() })
			
		EndIf
		
	ElseIf cPar == "B"
		
		If MsgYesNo("Deseja realmente baixar automaticamente os títulos a pagar?", "Automação Financeira")
	
			U_BIAMsgRun("Baixando automaticamente os títulos...", "Aguarde!", {|| fBaixaPagar() })
			
		EndIf
	
	ElseIf cPar == "C"
		
		If MsgYesNo("Deseja realmente conciliar os títulos de DDA?", "Automação Financeira")
	
			U_BIAMsgRun("Conciliando títulos de DDA...", "Aguarde!", {|| fConciliacaoDDA() })
			
		EndIf
		
	ElseIf cPar == "D"
		
		If MsgYesNo("Deseja realmente processar os retornos de conciliação bancária?", "Automação Financeira")
			
			U_BIAMsgRun("Processando retornos de conciliação bancária...", "Aguarde!", {|| fRetornoConciliacao() })
			
		EndIf
		
	EndIf
					
Return()


Static Function fRetornoPagar()
Local oObj := Nil

	// Retorno de pagamentos
	oObj := TAFRetornoPagar():New()
	oObj:Receive()

Return()


Static Function fBaixaPagar()
Local oObj := Nil
		
	// Baixas a pagar
	oObj := TAFBaixaPagar():New()
	oObj:Process()

Return()


Static Function fConciliacaoDDA()
Local oObj := Nil

	// Conciliacao de DDA
	oObj := TAFConciliacaoDDA():New()			
	oObj:Process()	

Return()


Static Function fRetornoConciliacao()
Local oObj := Nil

	// Retorno de Conciliacao Bancaria
	oObj := TAFRetornoConciliacao():New()
	oObj:Receive()
	
	// Conciliacao Bancaria
	oObj := TAFConciliacaoBancaria():New()
	oObj:Process()
	
	// Deposito Identificado
	oObj := TAFDepositoIdentificado():New()
	oObj:Process()

Return()