#Include 'TOTVS.CH'
#Include 'RESTFUL.CH'
#INCLUDE "PROTHEUS.CH"


User Function OlaMundo()
	
	Local cNome  := "Filipe"
	Local cDATA  := ""
	Local cValor  := 79
	RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1", "SB5"})
	Alert("Ola mundo!")
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())        
	If dbSeek(xFilial("SB1")+"000003")	        // verifica a existencia do registro    	   	            
		cNome := AllTrim(SB1->B1_DESC)
	 
		cDATA := Ctod(DtoC(SB1->B1_UCOM)) // dd/mm/yy

		cDATA := StoD(DtoC(SB1->B1_UCOM))
		cValor := cValor*100
		 

	EndIf
  

Return
 