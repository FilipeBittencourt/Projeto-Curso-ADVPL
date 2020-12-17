#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF167
@author Filipe Bittencourt
@since 02/09/2018
@project Automacao Financeira
@version 1.0
@description Processa os titulos a receber do banco do brasil para não gerar diariamente
@type function
/*/

User Function BIAF167()


  Local cSQL      := ""
  Local cSQLFIL   := ""
  Local cSQLGrp   := ""
  Local cSQLOrd   := ""
  Local cQry      := GetNextAlias()
  Local nSoma     := 0
  Local aFINA100  := {}
  Local cError    := ""
  Local oError    := ErrorBlock({|e| cError := e:Description})
  Local cTime     := ""
  Local cClasVlr  := "1215" //1215 - BIANCO | 1219 - LM

  Private lMsErroAuto    := .F.

  If Select("SX6") <= 0
    RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  if UDiaUtil() //Pegando e comparando ultimo dia util do mes

    // PEGANDO TODAS AS CONTAS DO BANCO DO BRASIL PARA EXECUTAR EM QUAIS DELEAS POSSUI TARIFAS
    cSQL := " SELECT  ZK4_BANCO,  ZK4_AGENCI, ZK4_CONTA, SUM(ZK4_VLTAR) as ZK4_VLTAR " + CRLF
    cSQL += " FROM " + RetSQLName("ZK4")  + CRLF
    cSQLFIL := " WHERE ZK4_FILIAL = '"+FWxFilial('ZK4')+"' " + CRLF
    cSQLFIL += " AND ZK4_EMP      = '"+cEmpAnt+"'  " + CRLF
    cSQLFIL += " AND ZK4_FIL      = '"+cFilAnt+"'  " + CRLF
    cSQLFIL += " AND ZK4_TIPO     = 'R'  " + CRLF
    cSQLFIL += " AND ZK4_STATUS   = '1' " + CRLF
    cSQLFIL += " AND ZK4_BANCO    = '001' " + CRLF
    cSQLFIL += " AND ZK4_VLTAR  > 0 " + CRLF
    cSQLFIL += " AND D_E_L_E_T_   =  '' " + CRLF
    cSQLGrp := "group by ZK4_BANCO,  ZK4_AGENCI, ZK4_CONTA"  + CRLF
    cSQLOrd := "ORDER BY  ZK4_BANCO,  ZK4_AGENCI, ZK4_CONTA" + CRLF

    cSQL := cSQL+cSQLFIL+cSQLGrp+cSQLOrd

    TcQuery cSQL New Alias (cQry)

    While (cQry)->(!Eof())

      Begin Transaction

        //Classe de valor
        if (cEmpAnt+cFilAnt) == '0701'
          cClasVlr  := "1219" //1215 - BIANCO | 1219 - LM
        EndIf

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
          {"E5_NATUREZ"   , "2915"                      ,Nil},;
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

          TCSqlExec(cSQL)


        Else

          ErrorBlock(oError)
          cError := MostraErro("/dirdoc", "error.log") //ARMAZENA A MENSAGEM DE ERRO
          FwAlertError(cError,'Error')

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
    //Se a data atual for uma data Válida
    If dDtAtu == DataValida(dDtAtu)

      dDtValid :=  dDtAtu

    EndIf

    dDtAtu := DaySum(dDtAtu, 1)

  EndDo

  if dDtValid == dDataBase
    lDiaD := .T.
  EndIf

  RestArea(aArea)

Return .T. //lDiaD