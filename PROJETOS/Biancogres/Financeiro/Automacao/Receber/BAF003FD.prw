#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"


User Function BAF003FD()
Local oObj := Nil
Local nCount := 0

	U_GravaPZ2(0,"SE1","BAF003FD","INICIO","EMP:"+CEMPANT,"MNT",CUSERNAME)

	ConOut("TAF => BAF003FD - [REGISTRO ON-LINE NORMAL FIDC] - INICIO do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())
			
	// Envio Normal
	oObj 				:= TAFRemessaReceber():New()
	oObj:oMrr:lFIDC		:= .T.
	oObj:Send()

	ConOut("TAF => BAF003 - [REGISTRO ON-LINE NORMAL FIDC] - FIM do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())

	ConOut("TAF => BAF003 - [REGISTRO ON-LINE NORMAL FIDC - REENVIO/QUEDA] - INICIO do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())
	
	// Reenvio caso aconteca queda de sistema e etc
	oObj 					:= TAFRemessaReceber():New()
	oObj:oMrr:lReproc		:= .T.
	oObj:oMrr:lFIDC			:= .T.
	oObj:oMrr:dEmissaoAte	:= dDataBase
	oObj:Send()
	
	U_FIDCXML()
							
	ConOut("TAF => BAF003 - [REGISTRO ON-LINE NORMAL FIDC - REENVIO/QUEDA] - FIM do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())	
			
	U_GravaPZ2(0,"SE1","BAF003FD","FIM","EMP:"+CEMPANT,"MNT",CUSERNAME)

Return()