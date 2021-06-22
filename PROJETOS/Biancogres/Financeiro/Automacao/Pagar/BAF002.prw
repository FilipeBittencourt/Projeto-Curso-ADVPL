#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BAF002
@author Tiago Rossini Coradini
@since 24/09/2018
@project Automação Financeira
@version 1.0
@description Processa retorno e baixas de titulos a pagar 
@type function
/*/

User Function BAF002()
Local oObj := Nil
Local _oSemaforo	:=	tBiaSemaforo():New()	
	
	U_GravaPZ2(0,"SE2","BAF002","INICIO","EMP:"+CEMPANT,"MNT",CUSERNAME)

	_oSemaforo:cGrupo	:=	"FIN_BAIXAS_CP"
	
	If _oSemaforo:GeraSemaforo("JOB - BAF002")
	
		U_GravaPZ2(0,"SE2","BAF002","PROCESSANDO","EMP:"+CEMPANT,"MNT",CUSERNAME)
	
		// Retorno de pagamentos
		oObj := TAFRetornoPagar():New()
		oObj:Receive()
		
		// Baixas a pagar
		oObj := TAFBaixaPagar():New()
		oObj:Process()

		_oSemaforo:LiberaSemaforo()
	
	EndIf

	U_GravaPZ2(0,"SE2","BAF002","FIM","EMP:"+CEMPANT,"MNT",CUSERNAME)
	
Return()
