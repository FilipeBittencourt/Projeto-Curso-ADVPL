#Include "Protheus.CH"
#Include "TOPCONN.CH"

User Function BACP0001() 

	Local oPesagemIntegracao	:= Nil
	Local cEmp					:= '01'
	Local cFil					:= '01'
	
	RPCSetType(3)
	RPCSetEnv(cEmp, cFil)

		oPesagemIntegracao := TPesagemIntegracao():New(cEmpAnt, cFilAnt)
		oPesagemIntegracao:ProcessaGuardiam()
		
	RpcClearEnv()	
		
Return()