#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF030
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Processa retorno de extrato bancario / Conciliacao Extrato / Deposito Identificado
@type function
/*/

User Function BAF030()
Local oObj := Nil
Local _oSemaforo	:=	tBiaSemaforo():New()	
	
	U_GravaPZ2(0,"SE5","BAF030","INICIO","EMP:"+CEMPANT,"MNT",CUSERNAME)

	_oSemaforo:cGrupo	:=	"FIN_TESOURARIA"
	
	If _oSemaforo:GeraSemaforo("JOB - BAF030")

		// Retorno de Conciliacao Bancaria
		oObj := TAFRetornoConciliacao():New()
		oObj:Receive()
		
		// Conciliacao Bancaria
		oObj := TAFConciliacaoBancaria():New()
		oObj:Process()
		
		// Deposito Identificado
		oObj := TAFDepositoIdentificado():New()
		oObj:Process()
	
		_oSemaforo:LiberaSemaforo()
	
	EndIf

	U_GravaPZ2(0,"SE5","BAF030","FIM","EMP:"+CEMPANT,"MNT",CUSERNAME)
			
Return()