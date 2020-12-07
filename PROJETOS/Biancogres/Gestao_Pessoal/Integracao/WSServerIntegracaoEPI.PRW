#include "TOTVS.CH"
#include "TOPCONN.CH"
#INCLUDE "APWEBSRV.CH"


/*/{Protheus.doc} WSServerIntegracaoEPI
@description WEB SERVICE  DE REQUISIÇÕES DE EPI
@author Gabriel Mafioletti
@since 22/04/2020
@version 1.0
@type Function
/*/

WsStruct WSIEPI_PRODUTO

	WsData cProduto As String
	WsData cAlmox As String
	WsData nQuantidade AS Float

EndWsStruct

WsStruct WSIEPI_REQUISICAO_REQUEST
	WsData cMatricula As String
	WsData aProdutos As Array Of WSIEPI_PRODUTO

EndWsStruct

WsStruct WSIEPI_REQUISICAO_RESPONSE

	WsData lOk AS Boolean
	WsData cErro as String

EndWsStruct


WsService WSServerIntegracaoEPI Description "Realiza Integrações referentes aos EPI's"
	
	WsData oReqPrq As WSIEPI_REQUISICAO_REQUEST 
	WsData oRespPrq As WSIEPI_REQUISICAO_RESPONSE	
	
	WsMethod GeraPreRequisicao
	
EndWsService

WsMethod GeraPreRequisicao WsReceive oReqPrq WsSend oRespPrq WsService WSServerIntegracaoEPI

Local _aProds	:=	{}
Local _nI

If Len(oReqPrq:aProdutos) > 0
	For _nI	:= 1 to Len(oReqPrq:Aprodutos)
		aAdd(_aProds,{oReqPrq:Aprodutos[_nI]:cProduto,oReqPrq:Aprodutos[_nI]:nQuantidade,oReqPrq:Aprodutos[_nI]:cAlmox})
	Next
	U_BIAFG122(_aProds,oReqPrq:cMatricula,.T.)
Else
	oRespPrq:lOk	:=	.F.
	oRespPrq:cErro	:=	"Não Foram Selecionados Produtos"
EndIf

Return .T.