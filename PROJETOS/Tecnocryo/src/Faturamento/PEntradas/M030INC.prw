#Include "Protheus.ch"
#Include "Totvs.ch"

User Function M030INC
	RecLock("SA1", .F.)
		SA1->A1_MSBLQL := "1"	
	SA1->(MsUnlock())
Return