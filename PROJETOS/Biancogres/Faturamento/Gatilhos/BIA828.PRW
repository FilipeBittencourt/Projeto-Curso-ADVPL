#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

User Function BIA828()

	Local wRet 		:= M->C5_TABELA
	Local cUF		:= ""
	
	//Vinilico
	If (Alltrim(M->C5_YLINHA) == "6" .And. cEmpAnt == '07')
		
		If !(Empty(M->C5_CLIENTE))
			
			cUF := Posicione("SA1",1,XFILIAL("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_EST")
			
			If (cFilAnt <> '05')
				
				If (AllTrim(cUF) == "ES")
					wRet := Tabela("ZF","V01")
				Else
					wRet := Tabela("ZF","V02")
				EndIf
			
			Else
				
				wRet := Tabela("ZF","V03")
			
			EndIf
			
		EndIf
		
	ElseIf (Alltrim(M->C5_YLINHA) == "6" .And. cEmpAnt == '13') //tabela de replicação
	 	
	 	wRet := Tabela("ZF","VRP")
	 	
	EndIf
		
	        	
Return(wRet)
	