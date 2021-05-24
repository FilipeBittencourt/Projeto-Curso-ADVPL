#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVPED01
Rotina responsável por buscar os pedidos no portal e cadastrar na stage area
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 15/12/2020
/*/
User Function PTVPED01(oSchd)

  Local oObj       := PTVinilicoBuscaPedidos():New()
  Local aArea      := GetArea()
  Local cMsgLog    := ""
  Local lLog       := .F.

  Default oSchd    := Nil

  lLog  := Type("oSchd") != "U"
  
  cMsgLog := "INICIANDO BUSCA DE PEDIDOS NO PORTAL VINILICO"

  //|Busca os pedidos no portal vinilico |
  oObj:cMsgProc := ""
  oObj:Process()

  //|Log do processamento |
  If !Empty( oObj:cMsgProc )
    cMsgLog   += CRLF + oObj:cMsgProc
  EndIf

  If lLog
    oSchd:LogMessage( cMsgLog + CRLF )
  EndIf

  ConOut(cMsgLog )

  If lLog
    oSchd:LogMessage( "FINALIZADO BUSCA DE PEDIDOS" + CRLF )
  Else
    MsgInfo("Sincronização finalizada!")
  EndIf

  RestArea(aArea)

Return
