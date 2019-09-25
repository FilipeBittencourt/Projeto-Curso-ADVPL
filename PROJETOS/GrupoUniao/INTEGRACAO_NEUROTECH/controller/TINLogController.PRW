#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TINLogController
@description Classe de controle para gerar logs vindos da integração neurotech
@author Fernando Rocha / Filipe Vieira
@since 19/12/2018
@version 1.0
/*/


Class TINLogController From LongClassName
	
	Data oLog	
	Method New() Constructor
	Method Insert(oLog) 
	Method WorkFlow(oLog) 

EndClass

Method New() Class TINLogController 

	::oLog	:= ""

Return Self


Method Insert(oLog) Class TINLogController 		
 
    Local oLogDAO := TINLogDAO():New()	 

	If(oLogDAO:Insert(oLog)) 
		If (oLog:cErroNeu != "") 
			::WorkFlow(oLog) //Chama a classe de Email/Workflow		
		EndIf		

	EndIf

Return .T.


Method WorkFlow(oLog) Class TINLogController 

	Local oWorkFlow := TINAWorkFlow():New()

	oWorkFlow:cAssunto := "Erro de comunicação WS Neurotech"
	oWorkFlow:cEmail := GetNewPar("MV_YNEMERR","")
	oWorkFlow:cTitBody  := "Erro Neurotech"

	oWorkFlow:cBody :="<b>Pedido: </b>"+oLog:cNumPedido+"<br /><br />"
	oWorkFlow:cBody +="<b>Cod. Cliente: </b>"+oLog:cCodCli+"<br /><br />"
	oWorkFlow:cBody +="<b>Cliente: </b>"+oLog:cCliNome+"<br /><br />"
	oWorkFlow:cBody +="<b>Proposta: </b>"+oLog:cNumNeu+"<br /><br />"		
	oWorkFlow:cBody +="<b>Data Envio: </b>"+ cValToChar(oLog:dDtEnvNeu)+" "+cValToChar(oLog:cHrEnvNeu)+"<br /><br />"
	oWorkFlow:cBody +="<b>Data Retorno: </b>"+ cValToChar(oLog:dDtResNeu)+" "+cValToChar(oLog:cHrResNeu)+"<br /><br />"
	oWorkFlow:cBody +="<b>Erro Neurotech: </b>"+oLog:cErroNeu+"<br /><br />"
	

	oWorkFlow:WFMail()

Return .T.

