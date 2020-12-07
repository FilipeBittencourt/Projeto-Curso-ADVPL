#Include "Protheus.CH"
#Include "TOPCONN.CH"

Class TTabelaTeste From LongClassName
	
	//metodos publicos	
	Method New() Constructor
	Method Teste() 
	
EndClass

Method New () Class TTabelaTeste
	
	U_fMargem3(SC5->C5_NUM, "2")
	
	
Return

Method Teste () Class TTabelaTeste
	
	Local cAliasZKI 	:= GetNextAlias()
		
	Local cDesc := Tabela("DJ", Alltrim(SC5->C5_YSUBTP))
		
Return


User Function BACP0003() 
	
	//Local cAliasZKI := Nil
	
	
	RPCSetType(3)
	RPCSetEnv("01", "01")
		
		U_BACP007('F08297', cEmpAnt, cFilAnt)
	
	RpcClearEnv()	
		
	/*RPCSetType(3)
	RPCSetEnv("01", "01")
		
	
		//cDesc := Tabela("DJ", "N")
		//DbSelectArea('SC5')
	//	SC5->(DbSetOrder(1))
	//	SC5->(DbSeek(xFilial('SC5')+"BA0050"))
	
		
	//	oBloqPedVenda := TTabelaTeste():New()
		//oBloqPedVenda:Teste()
		//conout(cDesc)
		oBloqPedVenda := TBloqueioPedidoVenda():New("BA0050")
		oBloqPedVenda:Check()
	RpcClearEnv()	
	*/
/*	Local cNextCod := ""
	
	RPCSetType(3)
	RPCSetEnv("01", "01")
		
	If (AllTrim(cEmpAnt) == '01')
		cNextCod := GetSxENum("SC5","C5_NUM", AllTrim(CEMPANT)+"SC5_REP_B") 
	EndIf
	
	Alert(cNextCod)
	
		
	RpcClearEnv()	
	*/
Return()