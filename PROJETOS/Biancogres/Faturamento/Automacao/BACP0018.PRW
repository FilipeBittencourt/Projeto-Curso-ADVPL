#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BACP0018
@author Gabriel Rossi Mafioletti
@since 06/11/2019
@version 1.0
@description Verificação de Concorrência de Rotinas
@type function
/*/


User Function BACP18

	RpcSetType(3)
	RpcSetEnv("01","01")

	U_BACP0018()

	RpcClearEnv()
Return


User Function BACP0018()

	Local oMonitor
	Local _aRotinas	:=	{}
	Local _oSrv
	Local _lRet		:=	.T.
	Local _nI
	Local _aServers	:=	fGetServer()

	

	oMonitor	:=	tBiaMonitor():New()
	
	oMonitor:cGrupo	:=	"000003"
	
	
	
	For _nI	:= 1 to Len(_aServers)

		_oSrv	:=	tBiaServidor():New()
		
		_oSrv:cIp		:=	_aServers[_nI,1]
		_oSrv:nPorta	:=	_aServers[_nI,2]
		_oSrv:cAmbiente	:=	_aServers[_nI,3]
		
		aAdd(oMonitor:aServidores,_oSrv)	
		
	Next
	
	
	If oMonitor:Load()
		_aRotinas := oMonitor:GetProcGrupo()
	EndIF
	
	For _nI	:=	1 to Len(_aRotinas)
	
		If _aRotinas[_nI,3] <> threadid()
			_lRet	:=	.F.
			Exit
		EndIf
			
	Next
	
Return _lRet


Static Function fGetServer()

	Local _aServer	:=	{}

	aAdd(_aServer,{'192.168.20.7',4191,"AUTOJOB-FIN"})
	aAdd(_aServer,{'192.168.20.7',4192,"AUTOJOB-ALMOX"})
	aAdd(_aServer,{'192.168.20.7',4193,"AUTOJOB-BIZ"})
	aAdd(_aServer,{'192.168.20.7',4194,"AUTOJOB-COMERCIAL"})
	//aAdd(_aServer,{'192.168.20.7',4189,"PRODUCAO"})
	//aAdd(_aServer,{'192.168.20.7',9899,"COMP-GABRIEL-TESTE-FACILE"})

Return _aServer