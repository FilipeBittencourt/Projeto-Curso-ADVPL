#INCLUDE "PROTHEUS.CH"

User Function PFAF0002()

	Processa( {|| StartJob("U_PFAF0001", GetEnvServer(), .T.)}, "Antecipação", "Processando antecipações...", .T.)
	
Return()