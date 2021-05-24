#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVPRD01
Rotina responsável por padronizar a integração do produto
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 15/12/2020
/*/
User Function PTVPRD01(oSchd)

  Local oProd      := PTVinilicoProdutos():New()
  Local aArea      := GetArea()
  Local aAreaSB1   := SB1->( GetArea() )
  Local nRecno     := 0
  Local cQuery     := ""
  Local cMsgLog    := ""
  Local cUltUpdate := U_PTVSTAMP( "GET", "SB1" )
  Local lLog       := .F.

  Default oSchd    := Nil

  lLog  := Type("oSchd") != "U"

  dbSelectArea("SB1")
  SB1->( dbSetOrder(1) )

  cQuery += " SELECT SB1.R_E_C_N_O_ AS SB1RECNO, B1_COD, B1_DESC "
  cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
  cQuery += " WHERE SB1.B1_FILIAL = " + ValToSql( xFilial("SB1") )
  cQuery += "       AND SUBSTRING(SB1.B1_COD, 1, 1) = 'V' "
  cQuery += "       AND SB1.B1_MSBLQL <> '1' "
  cQuery += "       AND (SB1.B1_YDELTBI = '' OR CONVERT(VARCHAR(23), SB1.B1_YDELTBI, 21) >= " + ValToSql(cUltUpdate) + ") "
  cQuery += "       AND SB1.D_E_L_E_T_ = '' "

  If Select("__SB1") > 0
    __SB1->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "__SB1"

  __SB1->( dbGoTop() )

  While !__SB1->( EoF() )

    nRecno    := __SB1->SB1RECNO

    cMsgLog   := "Integrando Produto: " + __SB1->B1_COD + " - " + AllTrim(__SB1->B1_DESC)

    If lLog
      oSchd:LogMessage( cMsgLog + CRLF )
    EndIf

    ConOut(cMsgLog )

    oProd:Process( nRecno )

    __SB1->( dbSkip() )    

  EndDo

  //|Atualiza o Stamp |
  U_PTVSTAMP( "PUT", "SB1" )

  If lLog
    oSchd:LogMessage( "FINALIZADO PRODUTO" + CRLF )
  Else
    MsgInfo("Sincronização finalizada!")
  EndIf

  RestArea(aAreaSB1)
  RestArea(aArea)

Return

