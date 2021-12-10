#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF003
@author Tiago Rossini Coradini
@since 02/09/2018
@project Automação Financeira
@version 1.0
@description Processa remessa de titulos a receber 
@type function
/*/

User Function BAF003()
Local oObj := Nil
Local nCount := 0

	U_GravaPZ2(0,"SE1","BAF003","INICIO","EMP:"+CEMPANT,"MNT",CUSERNAME)

	ConOut("TAF => BAF003 - [REGISTRO ON-LINE NORMAL] - INICIO do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())
			
	// Envio Normal
	oObj := TAFRemessaReceber():New()
	oObj:Send()

	ConOut("TAF => BAF003 - [REGISTRO ON-LINE NORMAL] - FIM do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())

	ConOut("TAF => BAF003 - [REGISTRO ON-LINE NORMAL - REENVIO/QUEDA] - INICIO do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())
	
	// Reenvio caso aconteca queda de sistema e etc
	oObj := TAFRemessaReceber():New()
	oObj:oMrr:lReproc	:= .T.
	oObj:oMrr:lFIDC		:= .F.	
	oObj:oMrr:dEmissaoAte := dDataBase
	oObj:Send()
							
	ConOut("TAF => BAF003 - [REGISTRO ON-LINE NORMAL - REENVIO/QUEDA] - FIM do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())	
			
	U_GravaPZ2(0,"SE1","BAF003","FIM","EMP:"+CEMPANT,"MNT",CUSERNAME)

Return()
