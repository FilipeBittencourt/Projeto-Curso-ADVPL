#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVPED02
Rotina responsável por gerar o pedido de venda no Protheus
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 15/12/2020
/*/
User Function PTVPED02(oSchd)

  Local oObj       := PTVinilicoIncluiPedidos():New()
  Local aArea      := GetArea()
  Local cQuery     := "" 
  Local cMsgLog    := ""
  Local lLog       := .F.

  Default oSchd    := Nil

  lLog  := Type("oSchd") != "U"
  
  //|Busca a query dos pedidos |
  cQuery := fGetQuery()
  
  If Select("__XPED") > 0
    __XPED->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "__XPED"

  __XPED->( dbGoTop() )

  While !__XPED->( EoF() )

    cMsgLog   := Replicate("-", 70) + CRLF
    cMsgLog   += "Processando pedido Guid: " + AllTrim(__XPED->uuid) + " - Cliente: " + AllTrim(__XPED->CLIENTE) + " - Loja: " + cValToChar(__XPED->LOJA)

    oObj:cGuidPedido := AllTrim(__XPED->uuid)
    oObj:cMsgProc    := ""
    
    oObj:Process()

    //|Erro no processamento? |
    If !Empty(oObj:cMsgProc)
      cMsgLog   += CRLF + oObj:cMsgProc
    Else
      cMsgLog   += CRLF + " -> Pedido incluido com sucesso."
    EndIf

    If lLog
      oSchd:LogMessage( cMsgLog + CRLF )
    EndIf

    ConOut(cMsgLog )

    __XPED->( dbSkip() )    

  EndDo

  If lLog
    oSchd:LogMessage( "FINALIZADO INCLUSAO PEDIDO DE VENDA" + CRLF )
  Else
    MsgInfo("Sincronização finalizada!")
  EndIf

  RestArea(aArea)

Return


/*/{Protheus.doc} fGetQuery
Monta a query para buscar os pedidos
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 22/12/2020
@return character, query montada
/*/
Static Function fGetQuery()

  Local cQuery     := ""

  cQuery += " SELECT VPC.uuid, 
  cQuery += " VPC.customer_code AS CLIENTE, "
  cQuery += " VPC.customer_store AS LOJA "
  cQuery += " FROM VNINTEGRACAO_PEDIDO_CABEC VPC "
  cQuery += " WHERE VPC.status_integrated = 'A' "

Return cQuery
