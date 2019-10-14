#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'
#INCLUDE "PROTHEUS.CH"


User Function OlaMundo()
	
	Local cNome  := "Filipe"
	RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1", "SB5"})
	Alert("Ola mundo!")
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())        
	If dbSeek(xFilial("SB1")+"000001")	        // verifica a existencia do registro    	   	            
		cNome := AllTrim(SB1->B1_DESC)
	EndIf
  

Return
 