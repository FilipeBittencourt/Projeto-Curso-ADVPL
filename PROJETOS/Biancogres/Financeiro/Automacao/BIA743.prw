#include "protheus.ch"
#Include "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA743
@description JOB que Envia EMAIL para Aprovadores de descontos financeiro via limites estabelecidos.
@author Filipe Bittencourt
@since 31/03/2021
@version 1.0
@type function
/*/ 

User Function BIA743()

  Local cSQL      := ""
  Local cQry      := ""
  Local dDtIni    := ""
  Local aAuxJS    := {}
  Local oJSZL0    := JsonObject():New()

  RpcClearEnv()
  If Select("SX6") <= 0
    RPCSetEnv("99", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  cQry   := GetNextAlias()
  dDtIni := "20201210"//FirstDate(Date()-1) //CToD("01/01/19")

  /*  
  cSQL := " SELECT *  " + CRLF
    cSQL += " FROM  ZL0010 " + CRLF
    cSQL += " WHERE ZL0_DESCON >   0 " + CRLF
    cSQL += " AND   ZL0_CLVLDB <> '' " + CRLF
    cSQL += " AND   D_E_L_E_T_ =  '' " + CRLF
    cSQL += " AND   ZL0_EMISSA = " + ValToSQL(dDtIni)  + CRLF

    TcQuery cSQL New Alias (cQry)

  While (cQry)->(!Eof())
  
    AADD(aAuxJS,   JsonObject():New())
    aAuxJS[Len(aAuxJS)]["ZL0_CODEMP"] := "9999"//(cQry)->ZL0_CODEMP
    aAuxJS[Len(aAuxJS)]["ZL0_CODFIL"] := "9999"//(cQry)->ZL0_CODFIL

    aAuxJS[Len(aAuxJS)]["ZL0_CLVLDB"] := "2150" //(cQry)->ZL0_CLVLDB
    aAuxJS[Len(aAuxJS)]["ZL0_DEBITO"] := ""     //(cQry)->ZL0_DEBITO
    aAuxJS[Len(aAuxJS)]["ZL0_DESCON"] := 4444   //(cQry)->ZL0_DESCON

    aAuxJS[Len(aAuxJS)]["ZL0_CLIFOR"] := "9999"//(cQry)->ZL0_CLIFOR
    aAuxJS[Len(aAuxJS)]["ZL0_LOJA"]   := "9999"//(cQry)->ZL0_LOJA
    aAuxJS[Len(aAuxJS)]["ZL0_EMISSA"] := "9999"//(cQry)->ZL0_EMISSA

    aAuxJS[Len(aAuxJS)]["EMAIL"] := Regras(aAuxJS[Len(aAuxJS)])

      (cQry)->(DbSkip())

  EndDo
  */

  AADD(aAuxJS,   JsonObject():New())
  aAuxJS[Len(aAuxJS)]["ZL0_CLVLDB"] := "3333" //(cQry)->ZL0_CLVLDB
  aAuxJS[Len(aAuxJS)]["ZL0_DESCON"] := 4444   //(cQry)->ZL0_DESCON
  aAuxJS[Len(aAuxJS)]["EMAIL"]      := "zzz@gmail.com"

  AADD(aAuxJS,   JsonObject():New())
  aAuxJS[Len(aAuxJS)]["ZL0_CLVLDB"] := "5555" //(cQry)->ZL0_CLVLDB
  aAuxJS[Len(aAuxJS)]["ZL0_DESCON"] := 4444   //(cQry)->ZL0_DESCON
  aAuxJS[Len(aAuxJS)]["EMAIL"]      := "aaa@gmail.com"

  AADD(aAuxJS,   JsonObject():New())
  aAuxJS[Len(aAuxJS)]["ZL0_CLVLDB"] := "1111" //(cQry)->ZL0_CLVLDB
  aAuxJS[Len(aAuxJS)]["ZL0_DESCON"] := 4444   //(cQry)->ZL0_DESCON
  aAuxJS[Len(aAuxJS)]["EMAIL"]      := ""

  AADD(aAuxJS,   JsonObject():New())
  aAuxJS[Len(aAuxJS)]["ZL0_CLVLDB"] := "4444" //(cQry)->ZL0_CLVLDB
  aAuxJS[Len(aAuxJS)]["ZL0_DESCON"] := 4444   //(cQry)->ZL0_DESCON
  aAuxJS[Len(aAuxJS)]["EMAIL"]      := "filipe.bittencourt@facilesistemas.com.br"

  AADD(aAuxJS,   JsonObject():New())
  aAuxJS[Len(aAuxJS)]["ZL0_CLVLDB"] := "7777" //(cQry)->ZL0_CLVLDB
  aAuxJS[Len(aAuxJS)]["ZL0_DESCON"] := 4444   //(cQry)->ZL0_DESCON
  aAuxJS[Len(aAuxJS)]["EMAIL"]      := "filipe.bittencourt@facilesistemas.com.br"

  AADD(aAuxJS,   JsonObject():New())
  aAuxJS[Len(aAuxJS)]["ZL0_CLVLDB"] := "8888" //(cQry)->ZL0_CLVLDB
  aAuxJS[Len(aAuxJS)]["ZL0_DESCON"] := 4444   //(cQry)->ZL0_DESCON
  aAuxJS[Len(aAuxJS)]["EMAIL"]      := ""

  AADD(aAuxJS,   JsonObject():New())
  aAuxJS[Len(aAuxJS)]["ZL0_CLVLDB"] := "2222" //(cQry)->ZL0_CLVLDB
  aAuxJS[Len(aAuxJS)]["ZL0_DESCON"] := 4444   //(cQry)->ZL0_DESCON
  aAuxJS[Len(aAuxJS)]["EMAIL"]      := "filipe.bittencourt@facilesistemas.com.br"

  oJSZL0["ZL0"] := aAuxJS

  //(cQry)->(DbCloseArea())

  EmailSend(oJSZL0)


Return

Static Function Regras(aJS)

  Local cEmail    := ""
  Local cQry      := GetNextAlias()
  Local cSQL      := ""

  cSQL := " select * "+  CRLF
  cSQL += " from ZDK990 "+  CRLF
  cSQL += " where LTRIM(RTRIM(ZDK_CLVLR)) = " + ValToSQL(AllTrim(aJS["ZL0_CLVLDB"]))  + CRLF
  cSQL += " AND LTRIM(RTRIM(ZDK_CCONTA))  = " + ValToSQL(AllTrim(aJS["ZL0_DEBITO"]))  + CRLF
  cSQL += " AND   "+cValTochar(aJS["ZL0_DESCON"])+"  BETWEEN  ZDK_VLAPIN AND ZDK_VLAPFI  "+  CRLF
  cSQL += " AND   ZDK_STATUS =  'A' " + CRLF
  cSQL += " AND   D_E_L_E_T_ =  '' " + CRLF
  cSQL += " ORDER BY ZDK_VLAPIN, ZDK_VLAPFI "+  CRLF

  TcQuery cSQL New Alias (cQry)

  While (cQry)->(!Eof())


    //Regra 1 - ATÉ 8000 DE desconte

    If aJS["ZL0_DESCON"] <= 8000 .AND. !EMPTY(AllTrim(aJS["ZL0_DEBITO"]))

      cEmail := UsrRetMail(AllTrim((cQry)->ZDK_APROV1)) //MANDA PARA O GESTOR PRINCIPAL

      If !EMPTY((cQry)->ZDK_APROVT) .AND. !EMPTY((cQry)->ZDK_DTATIN) .AND. !EMPTY((cQry)->ZDK_VLAPFI)

        IF (cQry)->ZDK_VLAPFI >= dDataBase

          cEmail := UsrRetMail(AllTrim((cQry)->ZDK_APROV1)) //MANDA PARA O APROVADOR TEMPORARIO

        EndIf

      EndIf

      //Regra 2 - acima de 8000.01 e classe de valor começando com 2
    ElseIf aJS["ZL0_DESCON"] >= 8000.01 .AND. SUBSTR(AllTrim((cQry)->ZDK_CLVLR), 0, 1) == "2" .AND. !EMPTY(AllTrim(aJS["ZL0_DEBITO"]))

      cEmail := UsrRetMail(AllTrim((cQry)->ZDK_APROV1)) //MANDA PARA O GESTOR PRINCIPAL

      If !EMPTY((cQry)->ZDK_APROVT) .AND. !EMPTY((cQry)->ZDK_DTATIN) .AND. !EMPTY((cQry)->ZDK_VLAPFI)

        IF (cQry)->ZDK_VLAPFI >= dDataBase

          cEmail := UsrRetMail(AllTrim((cQry)->ZDK_APROV1)) //MANDA PARA O APROVADOR TEMPORARIO

        EndIf

      EndIf

      //Regra 3 - acima de 8000.01 e classe de valor começando com 3
    ElseIf aJS["ZL0_DESCON"] >= 8000.01 .AND. SUBSTR(AllTrim((cQry)->ZDK_CLVLR), 0, 1) == "3" .AND. !EMPTY(AllTrim(aJS["ZL0_DEBITO"]))

      cEmail := UsrRetMail(AllTrim((cQry)->ZDK_APROV1)) //MANDA PARA O GESTOR PRINCIPAL

      If !EMPTY((cQry)->ZDK_APROVT) .AND. !EMPTY((cQry)->ZDK_DTATIN) .AND. !EMPTY((cQry)->ZDK_VLAPFI)

        IF (cQry)->ZDK_VLAPFI >= dDataBase

          cEmail := UsrRetMail(AllTrim((cQry)->ZDK_APROV1)) //MANDA PARA O APROVADOR TEMPORARIO

        EndIf

      EndIf

      //Regra 4 - INDEPENDETE DO VALOR, POREM SEM CONTA CONTABIL
    ELSE

      cEmail := UsrRetMail(AllTrim((cQry)->ZDK_APROV1)) //MANDA PARA O GESTOR PRINCIPAL

      If !EMPTY((cQry)->ZDK_APROVT) .AND. !EMPTY((cQry)->ZDK_DTATIN) .AND. !EMPTY((cQry)->ZDK_VLAPFI)

        IF (cQry)->ZDK_VLAPFI >= dDataBase

          cEmail := UsrRetMail(AllTrim((cQry)->ZDK_APROV1)) //MANDA PARA O APROVADOR TEMPORARIO

        EndIf

      EndIf

    EndIf

    (cQry)->(DbSkip())

  EndDo

Return cEmail

Static Function EmailSend(oJSZL0)

  Local nI    := 1
  Local cHtml :=  ""
  Local cMailAux := "x"
  ASORT(oJSZL0["ZL0"],,, { |x, y| x["EMAIL"] >  y["EMAIL"]} )

  if Len(oJSZL0["ZL0"]) > 0

    cMailAux :=  oJSZL0["ZL0"][1]["EMAIL"]

    for nI := 1 To Len(oJSZL0["ZL0"])

      if !Empty(oJSZL0["ZL0"][nI]["EMAIL"])

        if (AllTrim(oJSZL0["ZL0"][nI]["EMAIL"]) == AllTrim(cMailAux)) .OR. (EMPTY(cMailAux))

          cHtml += "<h3>"+oJSZL0["ZL0"][nI]["ZL0_CLVLDB"]+"</h3>"

        Else

          //U_BIAEnvMail(,cMailAux,'Email TESTE',cHtml)
          cHtml := "<h3>"+oJSZL0["ZL0"][nI]["ZL0_CLVLDB"]+"</h3>"

        EndIf

      EndIf

      cMailAux := oJSZL0["ZL0"][nI]["EMAIL"]

    NEXT nI

  EndIf

  // U_BIAEnvMail(,cMail,'Error Subject - BIAF167',cErro)
RETURN