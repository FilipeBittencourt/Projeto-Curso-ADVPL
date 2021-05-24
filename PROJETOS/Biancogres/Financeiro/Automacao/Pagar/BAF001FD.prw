#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"


User Function BAF001FD()
	
	Local _oSemaforo	:= Nil	
	
	_oSemaforo	:= tBiaSemaforo():New()	
	
	_oSemaforo:cGrupo	:=	"FIN_BORDERO"
	
	If _oSemaforo:GeraSemaforo("JOB - BAF001FD")

		ConOut("TAF => BAF001FD - [Processa Remessa de titulos a pagar FIDC] - INICIO do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())
	
		oObj 				:= TAFRemessaPagar():New()
		oObj:oMrr:nDia 		:= 60
		oObj:oMrr:lFIDC		:= .T.
		oObj:Send()
	
		ConOut("TAF => BAF001FD - [Processa Remessa de titulos a pagar FIDC] - FIM do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())
		
		_oSemaforo:LiberaSemaforo()
	
		If (oObj:oMrr:aListBor != Nil .And. Len(oObj:oMrr:aListBor) > 0)
			U_FIDCXMLP(oObj:oMrr:aListBor)
		EndIf
		
	EndIf
						
Return()

