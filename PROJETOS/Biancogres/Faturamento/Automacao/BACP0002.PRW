#Include "Protheus.CH"
#Include "TOPCONN.CH"

User Function BACP0002() 
	
	Local oObj			:= Nil
	Local cEmp			:= '01'
	Local cFil			:= '01'
	
	RPCSetType(3)
	RPCSetEnv(cEmp, cFil)
		
		oObj := TAprovacaoCargaEmail():New()
		oObj:Receber()
		
	RpcClearEnv()	
	
	
Return()