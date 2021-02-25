
//U_PCMOTOR0
User Function  PCMOTOR0(xParam1,xParam2)

  Local cSQL    := ""
  Local cBKPEmp := ""
  Local cBKPFil := ""
  Local cINI   := GETADV97()
  Local cENV := GetEnvServer()
  Local cDataBsae := GetPvProfString( cENV, "TopDataBase", "nao achei" ,cINI)
  Local cTopAlias := GetPvProfString( cENV, "TopAlias", "nao achei" ,cINI)
  Local cCOnn   := cDataBsae+"/"+cTopAlias
  Local nPort :=  val(GetPvProfString( cENV, "TopPort", "nao achei" ,cINI ))
  Local cServer := GetPvProfString( cENV, "TopServer", "nao achei" ,cINI)
  Local nTcLink


  nTcLink:=TCLink("@!!@"+cCOnn,cServer,nPort )


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

    While __TRZ->(!Eof())

      If cBKPEmp+cBKPFil != __TRZ->Z58_EMPORI+__TRZ->Z58_FILORI

        cBKPEmp := __TRZ->Z58_EMPORI
        cBKPFil := __TRZ->Z58_FILORI

        StartJob( "U_PCMOTOR1", cENV, .F.,  __TRZ->Z58_EMPORI , __TRZ->Z58_FILORI  )

        // StartJob( "U_PCMOTOR2", cENV, .F.,  __TRZ->Z58_EMPORI , __TRZ->Z58_FILORI  )
        //StartJob( "U_PCMOTOR3", cENV, .F.,  __TRZ->Z58_EMPORI , __TRZ->Z58_FILORI  )

      EndIf

      __TRZ->(DbSkip())

    EndDo

  EndIf

  TCUNLink(nTcLink)

Return
