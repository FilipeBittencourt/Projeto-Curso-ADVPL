#INCLUDE "PROTHEUS.CH"

User Function F040URET()
	Local aRet 	:= {}                      
	
	If FunName()=="FINA050"	
		aAdd(aRet,{"E2_YANTTX > 0 .AND. E2_YANTDES > 0","BR_VIOLETA"})
	EndIf
	
Return aRet
