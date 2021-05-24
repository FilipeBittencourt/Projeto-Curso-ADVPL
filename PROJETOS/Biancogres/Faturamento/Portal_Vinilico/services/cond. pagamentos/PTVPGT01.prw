#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVPGT01
Rotina responsável por padronizar a integração da condição de pagamento
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 15/12/2020
/*/
User Function PTVPGT01(oSchd)

  Local oPagto     := PTVinilicoCondPagamentos():New()
  Local aArea      := GetArea()
  Local aAreaSE4   := SE4->( GetArea() )
  Local nRecno     := 0
  Local cQuery     := ""
  Local cMsgLog    := ""
  Local cUltUpdate := U_PTVSTAMP( "GET", "SE4" )
  Local lLog       := .F.

  Default oSchd    := Nil

  lLog  := Type("oSchd") != "U"

  dbSelectArea("SE4")
  SE4->( dbSetOrder(1) )

  cQuery += " SELECT SE4.R_E_C_N_O_ AS SE4RECNO, E4_CODIGO, E4_DESCRI "
  cQuery += " FROM " + RetSqlName("SE4") + " SE4 "
  cQuery += " WHERE SE4.E4_FILIAL = " + ValToSql( xFilial("SE4") )
  cQuery += "       AND SE4.E4_YVINILI = 'S' "
  // cQuery += "       AND SE4.E4_YATIVO = '1' "
  cQuery += "       AND (SE4.E4_YDELTBI = '' OR CONVERT(VARCHAR(23), SE4.E4_YDELTBI, 21) >= " + ValToSql(cUltUpdate) + ") "
  cQuery += "       AND SE4.D_E_L_E_T_ = '' "

  If Select("__SE4") > 0
    __SE4->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "__SE4"

  __SE4->( dbGoTop() )

  While !__SE4->( EoF() )

    nRecno    := __SE4->SE4RECNO

    cMsgLog   := "Integrando Cond. Pagto: " + __SE4->E4_CODIGO + " - " + AllTrim(__SE4->E4_DESCRI)

    If lLog
      oSchd:LogMessage( cMsgLog + CRLF )
    EndIf

    ConOut(cMsgLog )

    oPagto:Process( nRecno )

    __SE4->( dbSkip() )    

  EndDo

  //|Atualiza o Stamp |
  U_PTVSTAMP( "PUT", "SE4" )

  If lLog
    oSchd:LogMessage( "FINALIZADO COND. PAGAMENTO" + CRLF )
  Else
    MsgInfo("Sincronização finalizada!")
  EndIf

  RestArea(aAreaSE4)
  RestArea(aArea)

Return

