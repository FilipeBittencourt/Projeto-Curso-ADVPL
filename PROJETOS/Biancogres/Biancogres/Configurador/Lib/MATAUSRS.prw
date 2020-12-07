#include "totvs.ch"
#include "tbiconn.ch"
#include "apwebex.ch"

User Function MATAUSRS
	Local cServer := "protheus_master"
	Local nPort1  := 6001
	Local cEnv    := "RANISSES"
	Local aUsers  := {}
	Local cHTML   := ""

	oSrv1 := RpcConnect(cServer, nPort1, cEnv, "01", "01")

	If ValType(oSrv1) == "O"
		oSrv1:CallProc("RPCSetType", 3 )		
		
		aUsers1 := oSrv1:CallProc("GetUserInfoArray")
		
		WEB EXTENDED INIT cHtml                      
			HttpSession->aUsers := aUsers1
			cHtml += EXECINPAGE("KILLUSERS")

		WEB EXTENDED END
		oSrv1:CallProc("RpcClearEnv")
		RpcDisconnect(oSrv1)
	Else 
		Return "Falhou ao obter a lista de usuarios"
	EndIf
Return cHTML

User Function Kill
	Local cServer := "protheus_master"
	Local nPort   := 2007
	Local cEnv    := "RANISSES"
	
	Local cUserKill := HttpGet->p1
	Local cComputer := HttpGet->p2
	Local nThread   := Val(HttpGet->p3)
	Local cSlave    := HttpGet->p4

	oSrv := RpcConnect(cServer, nPort, cEnv, "01", "01")
	oSrv:CallProc("RPCSetType", 3 )
	CONOUT(GETSERVERIP())
	oSrv:CallProc("KillUser",cUserKill,cComputer,nThread,cSlave)
	
Return RedirPage("http://"+ALLTRIM(GETSERVERIP())+":9393/monitor")