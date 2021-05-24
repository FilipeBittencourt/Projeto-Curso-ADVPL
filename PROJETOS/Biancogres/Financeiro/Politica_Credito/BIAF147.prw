#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF147
@author Tiago Rossini Coradini
@since 02/03/2020
@version 1.0
@description Funcao atualizacao de processosda de Politica de Credito
@type class
/*/

// Chamada via Schedule
User Function BIAF147()
Local oObj := Nil
Local _oSemaforo	:=	tBiaSemaforo():New()

	RpcSetType(3)
	RpcSetEnv("01", "01")

	ConOut("BIAF147 => [Atualiza Processos Rocket] - INICIO do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())

	_oSemaforo:cGrupo	:=	"BIAF147"

	If _oSemaforo:GeraSemaforo("JOB - BIAF147")	
		
		oObj := TPoliticaCredito():New()
			
		oObj:UpdProcess()
			
		FreeObj(oObj)
		
		_oSemaforo:LiberaSemaforo()
	
	EndIf

	ConOut("BIAF147 => [Atualiza Processos Rocket] - FIM do Processo - DATE: "+DTOC(Date())+" TIME: "+Time())

	RpcClearEnv()
			
Return()


// Chamada via Tela
User Function BIAF147A()
Local oObj := Nil
	
	oObj := TPoliticaCredito():New()
	
	oObj:UpdProcess()
	
	FreeObj(oObj)
				
Return()
