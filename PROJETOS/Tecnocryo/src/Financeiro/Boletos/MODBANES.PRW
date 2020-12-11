#Include "Protheus.ch"

User Function ModBanes()
Local cRet

	Do Case
		Case SEA->EA_MODELO == "21"
			cRet:= "CCS"		
		Case SEA->EA_MODELO == "30"
			cRet:= "COB"		
		Case SEA->EA_MODELO == "31"
			cRet:= "COB"		
		Case SEA->EA_MODELO == "18"
			cRet:= "DAS"    		
		Case SEA->EA_MODELO == "32"
			cRet:= "DUD"
		OtherWise
			cRet :="FGT"	
	End Case
Return (cRet)