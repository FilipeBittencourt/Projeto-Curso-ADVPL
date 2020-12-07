#include "TOTVS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} TIntegracaoBizagi
@description Rotina que retorna rotinas concorrentes de um grupo
@author Gabriel Mafioletti
@since 04/11/2019
@version 1.0
@type function
/*/

User Function TBFG115(_cGrupo)

	Default _cGrupo	:=	""

	RpcSetType(3)
	RpcSetEnv("01","01")
	
		_aTeste	:=	U_BIAFG115(_cGrupo)
	
	RpcClearEnv()

Return _aTeste

User Function BIAFG115(_cGrupo)

	Local oMonitor
	Local _aRotinas	:=	{}
	Local _oSrv
	Local _aServers	:=	{}
	Local _nI
	Local _aRet	:=	{{},{}}

	Default _cGrupo	:=	""

	oMonitor	:=	tBiaMonitor():New()
	
	oMonitor:cGrupo	:=	_cGrupo
	
	_aServers := oMonitor:GetAllServers()
	
	For _nI	:= 1 to Len(_aServers)

		_oSrv	:=	tBiaServidor():New()

		_oSrv:cIp		:=	_aServers[_nI,1]
		_oSrv:nPorta	:=	_aServers[_nI,2]
		_oSrv:cAmbiente	:=	_aServers[_nI,3]

		aAdd(oMonitor:aServidores,_oSrv)	

	Next	
	
	
	If oMonitor:Load()
		_aRet[1]	:=	oMonitor:aServidores
		_aRet[2]	:=	oMonitor:GetProcGrupo()
	EndIF
	
Return _aRet
