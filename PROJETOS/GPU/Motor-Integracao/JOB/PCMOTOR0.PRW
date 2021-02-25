#Include 'TOTVS.CH'
#Include "TopConn.ch"

/*
------------------------------------------------------------------------------------------------------------
Função   	: PCMOTOR0
Tipo		  : MAIN job
Descrição	: função para CHAMAR TODOS OS JOBS
Autor     : Filipe Bittencourt - Facile
*/


//U_PCMOTOR0
User Function  PCMOTOR0(xParam1,xParam2)

  Local cSQL    := ""
  Local cBKPEmp := ""
  Local cBKPFil := ""
  Local aFils   := {}
  Local cEnv    := GetEnvServer()
  Local nI      := 0

  If Select("SX6") <= 0
    RPCSetEnv("08", "01", NIL, NIL, "COM", NIL, {"SB1","SF2","SF1"})
  EndIf

  cSQL += " SELECT DISTINCT Z58_EMPORI, Z58_FILORI "
  cSQL += " FROM Z58080 "
  cSQL += " WHERE Z58_SYCSC7 = 'N' or  Z58_SYCELE <> 'S' " //PEGA TODOS OS PEDIDOS NÃO SICRONIZADOS ou Não finalizados 100%
  cSQL += " AND D_E_L_E_T_ = '' "
  cSQL += " ORDER BY Z58_EMPORI, Z58_FILORI "

  If Select("__TRZ") > 0
    __TRZ->(dbCloseArea())
  EndIf

  TcQuery cSQL New Alias "__TRZ"
  __TRZ->(dbGoTop())

  If !Empty(__TRZ->Z58_EMPORI) .and. !Empty(__TRZ->Z58_FILORI)

    // pego todas a Filiais
    While __TRZ->(!Eof())

      AADD(aFils,{__TRZ->Z58_EMPORI,__TRZ->Z58_FILORI})
      __TRZ->(DbSkip())

    EndDo

    RpcClearEnv()

    For nI := 1 to Len(aFils)

      If cBKPEmp+cBKPFil != aFils[nI,1]+aFils[nI,2]

        cBKPEmp := aFils[nI,1]
        cBKPFil := aFils[nI,2]

        StartJob( "U_PCMOTOR1", cEnv, .F.,  aFils[nI,1] , aFils[nI,2]  )
        StartJob( "U_PCMOTOR2", cEnv, .F.,  aFils[nI,1] , aFils[nI,2]  )
        //StartJob( "U_PCMOTOR3", cEnv, .F.,  aFils[nI,1] , aFils[nI,2]  )

      EndIf

    Next nI

  EndIf

Return
