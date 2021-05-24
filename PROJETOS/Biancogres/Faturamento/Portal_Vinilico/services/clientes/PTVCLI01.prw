#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVCLI01
Rotina responsável por padronizar a integração de clientes
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 15/12/2020
/*/
User Function PTVCLI01(oSchd)

  Local oCliente   := PTVinilicoClientes():New()
  Local aArea      := GetArea()
  Local aAreaSA1   := SA1->( GetArea() )
  Local nRecno     := 0
  Local cQuery     := ""
  Local cMsgLog    := ""
  Local cUltUpdate := U_PTVSTAMP( "GET", "SA1" )
  Local lLog       := .F.

  Default oSchd    := Nil

  lLog  := Type("oSchd") != "U"

  dbSelectArea("SA1")
  SA1->( dbSetOrder(1) )

  cQuery += " SELECT SA1.R_E_C_N_O_ AS SA1RECNO, A1_CGC, A1_NOME "
  cQuery += " FROM " + RetSqlName("SA1") + " SA1 "
  cQuery += " WHERE SA1.A1_FILIAL = " + ValToSql( xFilial("SA1") )
  cQuery += "       AND SA1.A1_YVINILI = 'S' "
  cQuery += "       AND (SA1.A1_YDELTBI = '' OR CONVERT(VARCHAR(23), SA1.A1_YDELTBI, 21) >= " + ValToSql(cUltUpdate) + ") "
  cQuery += "       AND SA1.D_E_L_E_T_ = '' "

  If Select("__SA1") > 0
    __SA1->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "__SA1"

  __SA1->( dbGoTop() )

  While !__SA1->( EoF() )

    nRecno    := __SA1->SA1RECNO

    cMsgLog   := "Integrando cliente: " + __SA1->A1_CGC + " - " + AllTrim(__SA1->A1_NOME)

    If lLog
      oSchd:LogMessage( cMsgLog + CRLF )
    EndIf

    ConOut(cMsgLog )

    oCliente:Process( nRecno )

    __SA1->( dbSkip() )    

  EndDo

  //|Atualiza o Stamp |
  U_PTVSTAMP( "PUT", "SA1" )

  If lLog
    oSchd:LogMessage( "FINALIZADO CLIENTES" + CRLF )
  Else
    MsgInfo("Sincronização finalizada!")
  EndIf

  RestArea(aAreaSA1)
  RestArea(aArea)

Return

