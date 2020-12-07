

User Function FIXRELAC()
	Local _aEmps	:=	{'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','90','91'}
	Local _nI
	
	For _nI	:= 1 to Len(_aEmps)
		RPCSetType(3)
		RPCSetEnv(_aEmps[_nI], "01")
	
			_cAliasPrz := GetNextAlias ()
			_cCaminho := "\P11_X3\SX3P11.DBF"
			dbUseArea(.T.,"DBFCDXADS",_cCaminho,_cAliasPrz,.F.)
		
			(_cAliasPrz)->(DbGoTop())
			SX3->(DbSetOrder(2))
			While (_cAliasPrz)->(!EOF())
				If SX3->(DbSeek((_cAliasPrz)->X3_CAMPO)) .And. SX3->X3_RELACAO <> (_cAliasPrz)->X3_RELACAO
					TcSqlExec("Insert into GABRIEL_RELACOES_SX3 SELECT " + ValtoSql(SX3->X3_CAMPO) + "," + ValtoSql() )
				EndIf
				(_cAliasPrz)->(DbSkip())
			EndDo
			(_cAliasPrz)->(DbCloseArea())
		RpcClearEnv()
	Next
Return