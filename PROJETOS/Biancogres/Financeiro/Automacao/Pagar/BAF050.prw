#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF049
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Retorna Tipo de Pagamento - Cnab Banestes 
@type function
/*/


User Function BAF050()
Local cMod := SEA->EA_MODELO
Local cTipPag := ""

	DO Case
	
	   Case cMod == "01"
	   		
	   		If SA2->A2_TIPCTA == "2"
	   			
	   			cTipPag	:= "CP"
	   			
	   		Else
	   			
	   			cTipPag	:= "CC"
	   			
	   		EndIf
	   		
	   Case cMod == "05"
	   
	   		cTipPag	:= "CP"
	   		
	   Case cMod == "11"
	   
	   		cTipPag	:= "CCS"
	   		
	   Case cMod == "13"
	   
	   		cTipPag	:= "CCS"
	   		
	   Case cMod == "30"
	   
	   		cTipPag	:= "COB"
	   		
	   Case cMod == "31"
	   
	   		cTipPag	:= "COB"
	   		
	   Case cMod == "03"
	   		
	   		cTipPag	:= "DOC"
	   		
	   Case cMod == "99"
	   		
	   		cTipPag	:= "DUD"
	   		
	   Case cMod == "41"
	   		
	   		cTipPag	:= "TED"
	   		   		
	   Case cMod == "42"
	   		
	   		cTipPag	:= "TED"
	   		   		   		
	EndCase   		

Return(cTipPag)