#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function BAF003FD()

    Local cMsg      as character

    local dDate     as date
    local dDateVld  as date

    local lDateVld  as logical

    dDate:=Date()
    dDateVld:=DataValida(dDate,.T.)
    lDateVld:=(dDate==dDateVld)


    if (lDateVld)
        BAF003FD()
    else
        cMsg := "TAF => BAF003FD - [PROCESSO FIDC NAO EXECUTADO (DATA 
        cMsg += DTOC(dDate)
        cMsg += " E FERIADO OU FINAL DE SEMANA. PROXIMA EXECUCAO PREVISTA PARA:"
        cMsg += DtoC(dDateVld)+")] - INICIO DO PROCESSO - DATE: "+DTOC(dDate)+" TIME: "+Time()
        ConOut(cMsg)
    endif

    return    

static Function BAF003FD()
	
	Local oObj		:= Nil
	
	Local cDataRef
	Local dDataRef

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
	
	U_FIDCXML(@cDataRef)

	ConOut("TAF => BAF003 - [MOVIMENTACAO BANCARIA FIDC] - Inicio do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())	

	dDataRef:=SToD(cDataRef)
	FIDC():movBcoFIDC(@dDataRef)

	ConOut("TAF => BAF003 - [MOVIMENTACAO BANCARIA FIDC] - Final do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())
							
	ConOut("TAF => BAF003 - [REGISTRO ON-LINE NORMAL FIDC - REENVIO/QUEDA] - FIM do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())	
			
	U_GravaPZ2(0,"SE1","BAF003FD","FIM","EMP:"+CEMPANT,"MNT",CUSERNAME)

Return()
