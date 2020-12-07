#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF001
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Processa remessa de titulos a pagar 
@type function
/*/

User Function BAF001()

	Local aAreaSE2 := SE2->(GetArea())
	Local aAreaSEA := SEA->(GetArea())
	Local _oSemaforo	:=	tBiaSemaforo():New()	
	
	_oSemaforo:cGrupo	:=	"FIN_BORDERO"
	
	If _oSemaforo:GeraSemaforo("JOB - BAF001")

		ConOut("TAF => BAF001 - [Processa Remessa de titulos a pagar] - INICIO do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())
	
		oObj := TAFRemessaPagar():New()
		oObj:oMrr:nDia := If(TYPE("PARAMIXB") == "A", PARAMIXB[1], 0)
		oObj:Send()
	
		ConOut("TAF => BAF001 - [Processa Remessa de titulos a pagar] - FIM do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())
	
		_oSemaforo:LiberaSemaforo()
	
	EndIf
	
	RestArea(aAreaSE2)
	RestArea(aAreaSEA)
						
Return()