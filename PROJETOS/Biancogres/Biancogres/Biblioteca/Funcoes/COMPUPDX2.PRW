User Function COMPUPDX2()
	Local _aEmps	:=	{'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','90','91'}
	Local _nI

	RPCSetType(3)
	RPCSetEnv("01", "01")

	For _nI	:= 1 to Len(_aEmps)	
		TcSqlExec("UPDATE SX2"+_aEmps[_nI]+"0 SET D_E_L_E_T_ = '' WHERE D_E_L_E_T_ IS NULL" )
	Next

	RpcClearEnv()

Return