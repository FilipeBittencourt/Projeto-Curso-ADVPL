#Include 'TOTVS.CH'
#Include "TopConn.ch"

User Function ParBox()

  Local aParamBox := {}
  Local oJSObj    := JsonObject():New()
  Local cSQL      := ""
  Local cQry      := GetNextAlias()
  Local nSoma     := 0
  Local aRet      := {}
  Local aFINA100  := {}
  Local cError    := ""
  Local oError    := ErrorBlock({|e| cError := e:Description})

  Private lMsErroAuto    := .F.

  If Select("SX6") <= 0
    RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  if U_UDiaUtil()

    aAdd(aParamBox,{1,"Banco",SPACE(TamSX3("A6_COD")[01]),"","","SA6","",0,.T.}) // Tipo caractere
    aAdd(aParamBox,{1,"Agencia",SPACE(TamSX3("A6_AGENCIA")[01]),"","","",".F.",0,.T.}) // Tipo caractere
    aAdd(aParamBox,{1,"Conta",SPACE(10),"","","",".F.",0,.T.}) // Tipo caractere
    aAdd(aParamBox,{1,"Data Inicio"  ,Ctod(Space(8)),"","","","",50,.T.}) // Tipo data
    aAdd(aParamBox,{1,"Data Fim"  ,Ctod(Space(8)),"","","","",50,.T.}) // Tipo data

    If ParamBox(aParamBox,"Dados para criar tarifas manuais",@aRet)

      oJSObj["Banco"]    := AllTrim(aRet[1])
      oJSObj["Agencia"]  := AllTrim(aRet[2])
      oJSObj["Conta"]    := AllTrim(aRet[3])
      oJSObj["DtInicio"] := AllTrim(DTOS(aRet[4]))
      oJSObj["DtFim"]    := AllTrim(DTOS(aRet[5]))


      //Realiza a baixa de tarifa diaria quando for banco do brasil

      cSQL := "SELECT top 5 ZK4_VLTAR , ZK4_BANCO,  ZK4_AGENCI, ZK4_CONTA, R_E_C_N_O_ "
      cSQL += " FROM " + RetSQLName("ZK4")
      cSQL += " WHERE ZK4_FILIAL = " + ValToSQL(xFilial("ZK4"))
      cSQL += " AND ZK4_EMP = " + ValToSQL(cEmpAnt)
      cSQL += " AND ZK4_FIL = " + ValToSQL(cFilAnt)
      cSQL += " AND ZK4_TIPO = 'R' "
      cSQL += " AND ZK4_STATUS = '1' " // Integrado
      cSQL += " AND D_E_L_E_T_ = ''	"
      cSQL += " AND ZK4_BANCO  = "+ValToSQL(oJSObj["Banco"])
      cSQL += " AND ZK4_AGENCI = "+ValToSQL(oJSObj["Agencia"])
      cSQL += " AND ZK4_CONTA = "+ValToSQL(oJSObj["Conta"])
      cSQL += " AND ZK4_DATA BETWEEN "+ValToSQL(oJSObj["DtInicio"])+" AND "+ValToSQL(oJSObj["DtFim"])

      TcQuery cSQL New Alias (cQry)

      While !(cQry)->(Eof())
        nSoma := nSoma + (cQry)->ZK4_VLTAR
        (cQry)->(DbSkip())
      EndDo

      (cQry)->(DbGoTop())

      If  nSoma > 0

        aFINA100 := {;
          {"E5_DATA"      , dDataBase                   ,Nil},;
          {"E5_MOEDA"     , "M1"                        ,Nil},;
          {"E5_VALOR"     , nSoma                       ,Nil},;
          {"E5_NATUREZ"   , "2915"                      ,Nil},;
          {"E5_BANCO"     , (cQry)->ZK4_BANCO           ,Nil},;
          {"E5_AGENCIA"   , (cQry)->ZK4_AGENCI          ,Nil},;
          {"E5_CONTA"     , (cQry)->ZK4_CONTA           ,Nil},;
          {"E5_BENEF"     , ""                          ,Nil},;
          {"E5_HISTOR"    , "TAR. ENVIO COBRANCA DO PERIODO "+CVALTOCHAR(oJSObj["DtInicio"])+" a "+CVALTOCHAR(oJSObj["DtFim"]) ,Nil}}

        MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3)


        If !lMsErroAuto

          While !(cQry)->(Eof())

            RecLock('ZK4', .F.)
            ZK4_STATUS := '2' // Processado
            ZK4->(MsUnlock())
            (cQry)->(DbSkip())

          EndDo

          FwAlertSuccess('Tarifas geradas com sucesso.','SUCESSO - BAF004')

        Else

          ErrorBlock(oError)
          cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
          FwAlertError(cError,'Error')

        EndIf

      EndIf

      (cQry)->(DbCloseArea())

    Endif

    FreeObj(oJSObj)

  EndIf

RETURN



//U_ParBox2
User Function ParBox2()


  Local oJSObj    := JsonObject():New()
  Local aRet      := {}
  Private cTT     := ""
  Private aParamBox := {}

  If Select("SX6") <= 0
    RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  aAdd(aParamBox,{1,"Cod Vend.",SPACE(TamSX3("A3_COD")[01]),"","U_TPARBOX2('01')","SA3","",0,.T.}) // Tipo caractere
  aAdd(aParamBox,{1,"CGC Vend",SPACE(TamSX3("A3_CGC")[01]),"","","",".F.",0,.T.}) // Tipo caractere
  //aAdd(aParamBox,{1,"Conta",SPACE(10),"","","",".F.",0,.T.}) // Tipo caractere
  //aAdd(aParamBox,{1,"Data Inicio"  ,Ctod(Space(8)),"","","","",50,.T.}) // Tipo data
  //aAdd(aParamBox,{1,"Data Fim"  ,Ctod(Space(8)),"","","","",50,.T.}) // Tipo data
  //aAdd(::aParam, {1, "Natureza", ::cNatureza, "@!", "U_BAF031A('06')", "SED", ".T.", 50, .T.})
  If ParamBox(aParamBox,"Dados para criar tarifas manuais",@aRet)

    oJSObj["Banco"]    := AllTrim(aRet[1])
    oJSObj["Agencia"]  := AllTrim(aRet[2])
    oJSObj["Conta"]    := AllTrim(aRet[3])
    //oJSObj["DtInicio"] := AllTrim(DTOS(aRet[4]))
    //oJSObj["DtFim"]    := AllTrim(DTOS(aRet[5]))
  ENDIF

Return

User Function TPARBOX2(cPar)

  Local lRet    := .T.
  &("MV_PAR02") := "0123456"

RETURN lRet





User Function ParBox2()

  Local oJSObj    := JsonObject():New()
  Local aRet      := {}
  Private cTT     := ""
  Private aParamBox := {}

  If Select("SX6") <= 0
    RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  aAdd(aParamBox,{1,"Cod Vend.",SPACE(TamSX3("A3_COD")[01]),"","U_TPARBOX2('01')","SA3","",0,.T.}) // Tipo caractere
  aAdd(aParamBox,{1,"CGC Vend",SPACE(TamSX3("A3_CGC")[01]),"","","",".F.",0,.T.}) // Tipo caractere

  If ParamBox(aParamBox,"Dados para criar tarifas manuais",@aRet)

    oJSObj["CodVend"]  := AllTrim(aRet[1])
    oJSObj["CGCVend"]  := AllTrim(aRet[2])

  ENDIF

Return

User Function TPARBOX2(cPar)

  Local lRet    := .T.
  &("MV_PAR02") := "0123456"

RETURN lRet


