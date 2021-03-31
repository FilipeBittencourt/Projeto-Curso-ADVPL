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

  Local cMail     := "filipe.bittencourt@facilesistemas.com.br"
  Local cSQL      := ""
  Local cQry      := ""
  Local dDtIni    := ""
  Local aAuxJS    := {}
  Local oJSZL0    := JsonObject():New()

  RpcClearEnv()
  If Select("SX6") <= 0
    RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  cQry   := GetNextAlias()
  dDtIni := "20201215"//FirstDate(Date()-1) //CToD("01/01/19")

  cSQL := " SELECT *  " + CRLF
  cSQL += " FROM  ZL0010 " + CRLF
  cSQL += " WHERE ZL0_DESCON >   0 " + CRLF
  cSQL += " AND   ZL0_CLVLDB <> '' " + CRLF
  cSQL += " AND   D_E_L_E_T_ =  '' " + CRLF
  cSQL += " AND   ZL0_EMISSA = " + ValToSQL(dDtIni)  + CRLF

  TcQuery cSQL New Alias (cQry)

  While (cQry)->(!Eof())

    AADD(aAuxJS,   JsonObject():New())
    aAuxJS[Len(aAuxJS)]["ZL0_CODEMP"] := (cQry)->ZL0_CODEMP
    aAuxJS[Len(aAuxJS)]["ZL0_CODFIL"] := (cQry)->ZL0_CODFIL
    aAuxJS[Len(aAuxJS)]["ZL0_CLVLDB"] := (cQry)->ZL0_CLVLDB
    aAuxJS[Len(aAuxJS)]["ZL0_DEBITO"] := (cQry)->ZL0_DEBITO

    aAuxJS[Len(aAuxJS)]["ZL0_CLIFOR"] := (cQry)->ZL0_CLIFOR
    aAuxJS[Len(aAuxJS)]["ZL0_LOJA"]   := (cQry)->ZL0_LOJA
    aAuxJS[Len(aAuxJS)]["ZL0_EMISSA"] := (cQry)->ZL0_EMISSA

    (cQry)->(DbSkip())

  EndDo

  oJSZL0["ZL0"] := aAuxJS

  (cQry)->(DbCloseArea())

  //U_BIAEnvMail(,cMail,'Error Subject - BIAF167',cErro)

Return