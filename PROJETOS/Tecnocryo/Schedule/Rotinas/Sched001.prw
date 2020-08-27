User Function Sched001()
Local cMyEmp := "01"
Local cMyFil := "0101"
LocaL aUsu    := {}

	ConOut("Iniciando U_Sched001(" + cMyEmp + "," + cMyFil + ")")	

	RPCSetType(3)
	RPCSetEnv(cMyEmp,cMyFil)

	If PadL(Day(Date()),2,"0") $ GetNewPar("MV_SCHED01", "01_")
		U_YMATR480()
		U_YMATR780()
		aAdd(aUsu, {"tecnocryo@tecnocryo.com.br;contato@tecnocryo.com.br", "Relatorio MATR480", "Relatorio MATR480.PDF", "schedule\matr480.pdf"})
		aAdd(aUsu, {"tecnocryo@tecnocryo.com.br;contato@tecnocryo.com.br", "Relatorio MATR780", "Relatorio MATR780.PDF", "schedule\matr780.pdf"})		
		U_EnvEmail(aUsu)	
	End If		

	ConOut("Fechando U_Sched001(" + cMyEmp + "," + cMyFil + ")")	
	RpcClearEnv()	
Return