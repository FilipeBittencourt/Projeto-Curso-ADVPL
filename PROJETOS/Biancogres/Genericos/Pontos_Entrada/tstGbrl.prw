User Function tstGbrl()

	RpcSetType(3)
	RpcSetEnv('01','01')

	StartJob( "U_tstgbrl2", GetEnvServer(),.F.)
	StartJob( "U_tstgbrl2", GetEnvServer(),.F.)
	StartJob( "U_tstgbrl2", GetEnvServer(),.F.)
	StartJob( "U_tstgbrl2", GetEnvServer(),.F.)
	StartJob( "U_tstgbrl2", GetEnvServer(),.F.)
	StartJob( "U_tstgbrl2", GetEnvServer(),.F.)
	StartJob( "U_tstgbrl2", GetEnvServer(),.F.)
	StartJob( "U_tstgbrl2", GetEnvServer(),.F.)
	StartJob( "U_tstgbrl2", GetEnvServer(),.F.)
	StartJob( "U_tstgbrl2", GetEnvServer(),.F.)
	StartJob( "U_tstgbrl2", GetEnvServer(),.F.)
	StartJob( "U_tstgbrl2", GetEnvServer(),.F.)
	StartJob( "U_tstgbrl2", GetEnvServer(),.F.)
	StartJob( "U_tstgbrl2", GetEnvServer(),.F.)
	StartJob( "U_tstgbrl2", GetEnvServer(),.F.)

	RpcClearEnv()

Return


User Function TstGbrl2()

	Local _nI

	RpcSetType(3)
	RpcSetEnv('01','01')

	For _nI	:=	1 to 1000

		begin transaction

		_cVal :=	ProxNum()

		if  _nI % 20 == 0
			SLEEP( 500 )
		Endif

		TcSqlExec("INSERT INTO DOCSEQTST SELECT "+ ValtoSql(_cVal)+ " , getdate()")

		end transaction

	Next
	RpcClearEnv()
Return