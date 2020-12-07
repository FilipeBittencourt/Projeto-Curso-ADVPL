#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "APWEBSRV.CH"

/*/{Protheus.doc} WSServerPoliticaCredito
@author Tiago Rossini Coradini
@since 20/01/2020
@version 1.0
@description Web Service Server para Consulta de Informacoes de Politica de Credito
@type class
/*/

#DEFINE _KEY "0101AA"
#DEFINE _USER "FACILE"
#DEFINE _PASS "TESTE01"


// Estrutura de autenticação de Requisicao
WsStruct WsSAuthentication

	WsData cKey As String
	WsData cUser As String
	WsData cPass As String

EndWsStruct

WsStruct WsSRequest_JoinCustomerVariables

	WsData cProcess	As String
	WsData cCNPJ 	As String
	WsData oAuth 	As WsSAuthentication

EndWsStruct


// Estrutura de Requisicao
WsStruct WsSRequest_CustomerVariables

	WsData cProcess As String
	WsData oAuth As WsSAuthentication

EndWsStruct


WsStruct WsSResponse_CustomerVariables

	WsData cCodPro As String
	WsData cCodigo As String
	WsData cData As String
	WsData cCliente As String
	WsData cLoja As String
	WsData cTipo As String
	WsData cSegmento As String
	WsData cGrpVen As String
	WsData nOriGrp As String
	WsData cPorte As String
	WsData cCnpj As String
	WsData cDatPriCom As String
	WsData nLimCreAtu As String
	WsData nLimCreSol As String
	WsData nVlrObr As String
	WsData nQtd_07 As String
	WsData nVlr_08 As String
	WsData nQtd_09 As String
	WsData nVlr_10 As String
	WsData nQtd_11 As String
	WsData nVlr_12 As String
	WsData nQtd_13 As String
	WsData nVlr_14 As String
	WsData nQtd_15 As String
	WsData nVlr_16 As String
	WsData nQtd_17 As String
	WsData nVlr_18 As String
	WsData nVlr_19 As String
	WsData nQtd_20 As String
	WsData nVlr_21 As String
	WsData nQtd_22 As String
	WsData nVlr_23 As String
	WsData nVlrC_01 As String
	WsData nVlrC_02 As String
	WsData nVlrC_03 As String
	WsData nVlrC_04 As String
	WsData nVlrC_05 As String
	WsData nVlrC_06 As String
	WsData nVlrC_07 As String
	WsData nVlrC_08 As String
	WsData nVlrC_09 As String
	WsData nVlrC_10 As String
	WsData nVlrC_11 As String

EndWsStruct


WsService WSServerPoliticaCredito Description "Consulta de Informacoes de Politica de Credito"
	
	WsData oRequest As WsSRequest_CustomerVariables
	WsData oResponse As Array Of WsSResponse_CustomerVariables	
	WsData oRequestCNPJ As WsSRequest_JoinCustomerVariables
	WsData oResponseCNPJ As WsSResponse_CustomerVariables	
	
	WsMethod CustomerVariables
	WsMethod CNPJCustomerVariables
	
EndWsService


WsMethod CNPJCustomerVariables WsReceive oRequestCNPJ WsSend oResponseCNPJ WsService WSServerPoliticaCredito
Local lRet := .T.
Local nCount := 1
Local oLst := ArrayList():New()
Local oVariavel	:= Nil
Local oTCnpjPC := Nil
Local oTStructCPCResult	:= Nil
	
	RpcSetType(3)
	RpcSetEnv("01", "01")
		
	If (::oRequestCNPJ:oAuth:cKey == _KEY)
	
		If (::oRequestCNPJ:oAuth:cUser == _USER .And. ::oRequestCNPJ:oAuth:cPass == _PASS)
		
			oVariavel	:= TVariavelCliente():New()
			
			oTCnpjPC := TCNPJPoliticaCredito():New(::oRequestCNPJ:cProcess, ::oRequestCNPJ:cCNPJ)
			
			oTStructCPCResult	:= oTCnpjPC:Execute()
			
			If (oTStructCPCResult:lOk)
				
				oVariavel:cCodPro := ::oRequestCNPJ:cProcess
			
				oLst := oVariavel:Get(, 'R')
				
				If oLst:GetCount() > 0
				
					nCount := 1
					
					::oResponseCNPJ:cCodPro := oLst:GetItem(nCount):cCodPro
					::oResponseCNPJ:cCodigo := oLst:GetItem(nCount):cCodigo
					::oResponseCNPJ:cData := dToS(oLst:GetItem(nCount):dData)
					::oResponseCNPJ:cCliente := oLst:GetItem(nCount):cCliente
					::oResponseCNPJ:cLoja := oLst:GetItem(nCount):cLoja
					::oResponseCNPJ:cTipo := oLst:GetItem(nCount):cTipo
					::oResponseCNPJ:cSegmento := oLst:GetItem(nCount):cSegmento
					::oResponseCNPJ:cGrpVen := oLst:GetItem(nCount):cGrpVen
					::oResponseCNPJ:nOriGrp := cValToChar(oLst:GetItem(nCount):nOriGrp)
					::oResponseCNPJ:cPorte := oLst:GetItem(nCount):cPorte
					::oResponseCNPJ:cCnpj := oLst:GetItem(nCount):cCnpj
					::oResponseCNPJ:cDatPriCom := dToS(oLst:GetItem(nCount):dDatPriCom)
					::oResponseCNPJ:nLimCreAtu := cValToChar(oLst:GetItem(nCount):nLimCreAtu)
					::oResponseCNPJ:nLimCreSol := cValToChar(oLst:GetItem(nCount):nLimCreSol)
					::oResponseCNPJ:nVlrObr := cValToChar(oLst:GetItem(nCount):nVlrObr)
					::oResponseCNPJ:nQtd_07 := cValToChar(oLst:GetItem(nCount):nQtd_07)
					::oResponseCNPJ:nVlr_08 := cValToChar(oLst:GetItem(nCount):nVlr_08)
					::oResponseCNPJ:nQtd_09 := cValToChar(oLst:GetItem(nCount):nQtd_09)
					::oResponseCNPJ:nVlr_10 := cValToChar(oLst:GetItem(nCount):nVlr_10)
					::oResponseCNPJ:nQtd_11 := cValToChar(oLst:GetItem(nCount):nQtd_11)
					::oResponseCNPJ:nVlr_12 := cValToChar(oLst:GetItem(nCount):nVlr_12)
					::oResponseCNPJ:nQtd_13 := cValToChar(oLst:GetItem(nCount):nQtd_13)
					::oResponseCNPJ:nVlr_14 := cValToChar(oLst:GetItem(nCount):nVlr_14)
					::oResponseCNPJ:nQtd_15 := cValToChar(oLst:GetItem(nCount):nQtd_15)
					::oResponseCNPJ:nVlr_16 := cValToChar(oLst:GetItem(nCount):nVlr_16)
					::oResponseCNPJ:nQtd_17 := cValToChar(oLst:GetItem(nCount):nQtd_17)
					::oResponseCNPJ:nVlr_18 := cValToChar(oLst:GetItem(nCount):nVlr_18)
					::oResponseCNPJ:nVlr_19 := cValToChar(oLst:GetItem(nCount):nVlr_19)
					::oResponseCNPJ:nQtd_20 := cValToChar(oLst:GetItem(nCount):nQtd_20)
					::oResponseCNPJ:nVlr_21 := cValToChar(oLst:GetItem(nCount):nVlr_21)
					::oResponseCNPJ:nQtd_22 := cValToChar(oLst:GetItem(nCount):nQtd_22)
					::oResponseCNPJ:nVlr_23 := cValToChar(oLst:GetItem(nCount):nVlr_23)
					::oResponseCNPJ:nVlrC_01 := cValToChar(oLst:GetItem(nCount):nVlrC_01)
					::oResponseCNPJ:nVlrC_02 := cValToChar(oLst:GetItem(nCount):nVlrC_02)
					::oResponseCNPJ:nVlrC_03 := cValToChar(oLst:GetItem(nCount):nVlrC_03)
					::oResponseCNPJ:nVlrC_04 := cValToChar(oLst:GetItem(nCount):nVlrC_04)
					::oResponseCNPJ:nVlrC_05 := cValToChar(oLst:GetItem(nCount):nVlrC_05)
					::oResponseCNPJ:nVlrC_06 := cValToChar(oLst:GetItem(nCount):nVlrC_06)
					::oResponseCNPJ:nVlrC_07 := cValToChar(oLst:GetItem(nCount):nVlrC_07)
					::oResponseCNPJ:nVlrC_08 := cValToChar(oLst:GetItem(nCount):nVlrC_08)
					::oResponseCNPJ:nVlrC_09 := cValToChar(oLst:GetItem(nCount):nVlrC_09)
					::oResponseCNPJ:nVlrC_10 := cValToChar(oLst:GetItem(nCount):nVlrC_10)
					::oResponseCNPJ:nVlrC_11 := cValToChar(oLst:GetItem(nCount):nVlrC_11)		
				
				EndIf
			
			Else
				
				lRet := .F.
			
				SetSoapFault("CNPJCustomerVariables", oTStructCPCResult:cMensagem)
							
			EndIf
					
		Else
		
			lRet := .F.
			
			SetSoapFault("CNPJCustomerVariables", "Usuário ou senha inválidos.")
		
		EndIf
		
	Else
	
		lRet := .F.
		
		SetSoapFault("CNPJCustomerVariables", "Chave de acesso ao Web Service inválida.")
		
	EndIf
	
	RpcClearEnv()	
	
Return(lRet)


WsMethod CustomerVariables WsReceive oRequest WsSend oResponse WsService WSServerPoliticaCredito
Local lRet := .T.
Local nCount := 1
Local oLst := ArrayList():New()
Local oVariavel := Nil

	RpcSetType(3)
	RpcSetEnv("01", "01")
	
	If ::oRequest:oAuth:cKey == _KEY
	
		If ::oRequest:oAuth:cUser == _USER .And. ::oRequest:oAuth:cPass == _PASS
		
			oVariavel := TVariavelCliente():New()
			
			oVariavel:cCodPro := ::oRequest:cProcess
			
			oLst := oVariavel:Get(.T.)
		
			If oLst:GetCount() > 0
		
				While nCount <= oLst:GetCount()
	
					aAdd(::oResponse, WSClassNew("WsSResponse_CustomerVariables"))

					::oResponse[nCount]:cCodPro := oLst:GetItem(nCount):cCodPro
					::oResponse[nCount]:cCodigo := oLst:GetItem(nCount):cCodigo
					::oResponse[nCount]:cData := dToS(oLst:GetItem(nCount):dData)
					::oResponse[nCount]:cCliente := oLst:GetItem(nCount):cCliente
					::oResponse[nCount]:cLoja := oLst:GetItem(nCount):cLoja
					::oResponse[nCount]:cTipo := oLst:GetItem(nCount):cTipo
					::oResponse[nCount]:cSegmento := oLst:GetItem(nCount):cSegmento
					::oResponse[nCount]:cGrpVen := oLst:GetItem(nCount):cGrpVen
					::oResponse[nCount]:nOriGrp := cValToChar(oLst:GetItem(nCount):nOriGrp)
					::oResponse[nCount]:cPorte := oLst:GetItem(nCount):cPorte
					::oResponse[nCount]:cCnpj := oLst:GetItem(nCount):cCnpj
					::oResponse[nCount]:cDatPriCom := dToS(oLst:GetItem(nCount):dDatPriCom)
					::oResponse[nCount]:nLimCreAtu := cValToChar(oLst:GetItem(nCount):nLimCreAtu)
					::oResponse[nCount]:nLimCreSol := cValToChar(oLst:GetItem(nCount):nLimCreSol)
					::oResponse[nCount]:nVlrObr := cValToChar(oLst:GetItem(nCount):nVlrObr)
					::oResponse[nCount]:nQtd_07 := cValToChar(oLst:GetItem(nCount):nQtd_07)
					::oResponse[nCount]:nVlr_08 := cValToChar(oLst:GetItem(nCount):nVlr_08)
					::oResponse[nCount]:nQtd_09 := cValToChar(oLst:GetItem(nCount):nQtd_09)
					::oResponse[nCount]:nVlr_10 := cValToChar(oLst:GetItem(nCount):nVlr_10)
					::oResponse[nCount]:nQtd_11 := cValToChar(oLst:GetItem(nCount):nQtd_11)
					::oResponse[nCount]:nVlr_12 := cValToChar(oLst:GetItem(nCount):nVlr_12)
					::oResponse[nCount]:nQtd_13 := cValToChar(oLst:GetItem(nCount):nQtd_13)
					::oResponse[nCount]:nVlr_14 := cValToChar(oLst:GetItem(nCount):nVlr_14)
					::oResponse[nCount]:nQtd_15 := cValToChar(oLst:GetItem(nCount):nQtd_15)
					::oResponse[nCount]:nVlr_16 := cValToChar(oLst:GetItem(nCount):nVlr_16)
					::oResponse[nCount]:nQtd_17 := cValToChar(oLst:GetItem(nCount):nQtd_17)
					::oResponse[nCount]:nVlr_18 := cValToChar(oLst:GetItem(nCount):nVlr_18)
					::oResponse[nCount]:nVlr_19 := cValToChar(oLst:GetItem(nCount):nVlr_19)
					::oResponse[nCount]:nQtd_20 := cValToChar(oLst:GetItem(nCount):nQtd_20)
					::oResponse[nCount]:nVlr_21 := cValToChar(oLst:GetItem(nCount):nVlr_21)
					::oResponse[nCount]:nQtd_22 := cValToChar(oLst:GetItem(nCount):nQtd_22)
					::oResponse[nCount]:nVlr_23 := cValToChar(oLst:GetItem(nCount):nVlr_23)
					::oResponse[nCount]:nVlrC_01 := cValToChar(oLst:GetItem(nCount):nVlrC_01)
					::oResponse[nCount]:nVlrC_02 := cValToChar(oLst:GetItem(nCount):nVlrC_02)
					::oResponse[nCount]:nVlrC_03 := cValToChar(oLst:GetItem(nCount):nVlrC_03)
					::oResponse[nCount]:nVlrC_04 := cValToChar(oLst:GetItem(nCount):nVlrC_04)
					::oResponse[nCount]:nVlrC_05 := cValToChar(oLst:GetItem(nCount):nVlrC_05)
					::oResponse[nCount]:nVlrC_06 := cValToChar(oLst:GetItem(nCount):nVlrC_06)
					::oResponse[nCount]:nVlrC_07 := cValToChar(oLst:GetItem(nCount):nVlrC_07)
					::oResponse[nCount]:nVlrC_08 := cValToChar(oLst:GetItem(nCount):nVlrC_08)
					::oResponse[nCount]:nVlrC_09 := cValToChar(oLst:GetItem(nCount):nVlrC_09)
					::oResponse[nCount]:nVlrC_10 := cValToChar(oLst:GetItem(nCount):nVlrC_10)
					::oResponse[nCount]:nVlrC_11 := cValToChar(oLst:GetItem(nCount):nVlrC_11)					
											
					nCount++
					
				EndDo()
				
			Else
		
				lRet := .F.
			
				SetSoapFault("CustomerVariables", "Não existem variaveis disponíveis para o processo informado.")
			
			EndIf
		
		Else
		
			lRet := .F.
			
			SetSoapFault("CustomerVariables", "Usuário ou senha inválidos.")
		
		EndIf
		
	Else
	
		lRet := .F.
		
		SetSoapFault("CustomerVariables", "Chave de acesso ao Web Service inválida.")
		
	EndIf
	
	RpcClearEnv()

Return(lRet)