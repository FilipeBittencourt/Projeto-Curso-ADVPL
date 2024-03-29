#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF167
@author Filipe Bittencourt
@since 02/12/2020
@project Automacao Financeira
@version 1.0
@description Processa os titulos a receber do banco do brasil para n�o gerar diariamente
@type function
/*/
//{{'01','01'},{'05','01'},{'07','01'}}      

User Function BIAF167()


  Local cSQL      := ""
  Local cQry      := ""
  Local nSoma     := 0
  Local aFINA100  := {}
  Local cError    := ""
  Local oError    := ""
  Local cTime     := ""
  Local cNatFin   := ""
  Local cClasVlr  := ""  //1215 - BIANCO | 1219 - LM
  Local dDtIni    := ""
  Local dDtFin    := ""

  Private lMsErroAuto    := .F.

  If Select("SX6") <= 0
    RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  cQry   := GetNextAlias()
  oError := ErrorBlock({|e| cError := e:Description})
  dDtIni := FirstDate(Date()) //CToD("01/01/19")
  dDtFin := LastDate(Date()) //CToD("31/01/19")

  if UDiaUtil() //Pegando e comparando ultimo dia util do mes

    // PEGANDO TODAS AS CONTAS DO BANCO DO BRASIL PARA EXECUTAR EM QUAIS DELEAS POSSUI TARIFAS
    cSQL := " SELECT  ZK4_BANCO,  ZK4_AGENCI, ZK4_CONTA, SUM(ZK4_VLTAR) as ZK4_VLTAR " + CRLF
    cSQL += " FROM " + RetSQLName("ZK4")  + CRLF
    cSQL += " WHERE ZK4_FILIAL = '"+FWxFilial('ZK4')+"' " + CRLF
    cSQL += " AND ZK4_EMP      = '"+cEmpAnt+"'  " + CRLF
    cSQL += " AND ZK4_FIL      = '"+cFilAnt+"'  " + CRLF
    cSQL += " AND ZK4_TIPO     = 'R'  " + CRLF
    cSQL += " AND ZK4_STATUS   = '1' " + CRLF
    cSQL += " AND ZK4_BANCO    = '001' " + CRLF
    cSQL += " AND ZK4_VLTAR  > 0 " + CRLF
    cSQL += " AND D_E_L_E_T_   =  '' " + CRLF
    cSQL += " AND ZK4_DTLIQ BETWEEN " + ValToSQL(dDtIni) + " AND " + ValToSQL(dDtFin) + CRLF
    cSQL += "group by ZK4_BANCO,  ZK4_AGENCI, ZK4_CONTA"  + CRLF
    cSQL += "ORDER BY  ZK4_BANCO,  ZK4_AGENCI, ZK4_CONTA" + CRLF

    TcQuery cSQL New Alias (cQry)

    While (cQry)->(!Eof())

      Begin Transaction

        cNatFin   := "2915"
        cClasVlr  := U_BIA478G("ZJ0_CLVLDB", cNatFin, "P")

        cTime := FwTimeStamp()
        cTime := SubStr(cTime,1,4)+'-'+SubStr(cTime,5,2)+'-'+SubStr(cTime,7,2)+'__'+SubStr(cTime,9,2)+'h'+SubStr(cTime,11,2)+'m'+SubStr(cTime,13,2)+'s'
        aFINA100 := {;
          {"E5_DATA"      , dDataBase                   ,Nil},;
          {"E5_MOEDA"     , "M1"                        ,Nil},;
          {"E5_TIPO"      , "NF"                        ,Nil},;
          {"E5_PREFIXO"   , "1"                         ,Nil},;
          {"E5_NUMERO"    , DTOS(dDataBase)             ,Nil},;
          {"E5_PARCELA"   , "A"                         ,Nil},;
          {"E5_DTDISPO"   , dDataBase                   ,Nil},;
          {"E5_CCD"       , "1000"                      ,Nil},;
          {"E5_TIPODOC"   , "DB"                        ,Nil},;
          {"E5_CLVLDB"    , cClasVlr                    ,Nil},;
          {"E5_VALOR"     , (cQry)->ZK4_VLTAR           ,Nil},;
          {"E5_NATUREZ"   , cNatFin                     ,Nil},;
          {"E5_BANCO"     , (cQry)->ZK4_BANCO           ,Nil},;
          {"E5_AGENCIA"   , (cQry)->ZK4_AGENCI          ,Nil},;
          {"E5_CONTA"     , (cQry)->ZK4_CONTA           ,Nil},;
          {"E5_BENEF"     , ""                          ,Nil},;
          {"E5_HISTOR"    , "JOB BIAF167.PRW "+cTime ,Nil}}


        MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3)


        If !lMsErroAuto


          cSQL := " UPDATE " + RetSQLName("ZK4") + " SET  ZK4_STATUS = '2' " + CRLF
          cSQL += " WHERE ZK4_FILIAL = '"+FWxFilial('ZK4')+"' " + CRLF
          cSQL += " AND ZK4_EMP      = '"+cEmpAnt+"'  " + CRLF
          cSQL += " AND ZK4_FIL      = '"+cFilAnt+"'  " + CRLF
          cSQL += " AND ZK4_TIPO     = 'R'  " + CRLF
          cSQL += " AND ZK4_STATUS   = '1' " + CRLF
          cSQL += " AND ZK4_BANCO    = '001' " + CRLF
          cSQL += " AND ZK4_VLTAR  > 0 " + CRLF
          cSQL += " AND D_E_L_E_T_   =  '' " + CRLF
          // cSQL += " AND ZK4_DTLIQ BETWEEN " + ValToSQL(dDtIni) + " AND " + ValToSQL(dDtFin) + CRLF

          TCSqlExec(cSQL)


        Else

          ErrorBlock(oError)
          cError := MostraErro("/dirdoc", "error.log") //ARMAZENA A MENSAGEM DE ERRO
          //FwAlertError(cError,'Error')
          U_BIAEnvMail(,cMail,'Error Subject - BIAF167',cErro)

        EndIf


      End Transaction

      (cQry)->(DbSkip())

    EndDo

    (cQry)->(DbCloseArea())

  Endif


Return



Static Function UDiaUtil()

  Local aArea    := GetArea()
  Local lDiaD    := .F.
  Local dDtValid := sToD("")
  Local dDtAtu   := sToD("")
  Default dDtIni := FirstDate(Date()) //CToD("01/01/19")
  Default dDtFin := LastDate(Date()) //CToD("31/01/19")

  //Enquanto a data atual for menor ou igual a data final
  dDtAtu := dDtIni
  While dDtAtu <= dDtFin
    //Se a data atual for uma data V�lida
    If dDtAtu == DataValida(dDtAtu)

      dDtValid :=  dDtAtu

    EndIf

    dDtAtu := DaySum(dDtAtu, 1)

  EndDo

  if dDtValid == dDataBase
    lDiaD := .T.
  EndIf

  RestArea(aArea)

Return lDiaD
