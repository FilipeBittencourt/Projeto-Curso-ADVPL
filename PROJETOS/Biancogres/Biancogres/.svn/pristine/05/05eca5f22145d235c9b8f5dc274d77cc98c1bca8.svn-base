#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF128
@author Tiago Rossini Coradini
@since 22/02/2019
@version 1.0
@description Funcao para Atualizacao de Historico de Classificacao de Cliente
@obs Ticket: 11376
@type class
/*/

User Function BIAF128()
Local oObj := Nil

	RpcSetType(3)
	RpcSetEnv("01", "01")

		oObj := THistoricoClassificacaoCliente():New()
		
		oObj:Process()
	
	RpcClearEnv()	
	
Return()