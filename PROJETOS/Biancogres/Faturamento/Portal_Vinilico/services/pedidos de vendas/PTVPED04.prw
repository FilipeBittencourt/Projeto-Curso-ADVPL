#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVPED04
Rotina responsável por gerar o pedido de venda no Protheus
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 15/12/2020
/*/
User Function PTVPED04(oSchd)

  Local oObj       := PTVinilicoAtualizaPortalPedidos():New()
  Local aArea      := GetArea()
  Local cQuery     := "" 
  Local cMsgLog    := ""
  Local lLog       := .F.

  Default oSchd    := Nil

  lLog  := Type("oSchd") != "U"
  
  //|Busca a query dos pedidos |
  cQuery := fGetQuery()
  
  If Select("__PED04") > 0
    __PED04->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "__PED04"

  __PED04->( dbGoTop() )

  While !__PED04->( EoF() )

    cMsgLog   := Replicate("-", 70) + CRLF
    cMsgLog   += "Processando pedido Guid: " + AllTrim(__PED04->uuid) + " - Cliente: " + AllTrim(__PED04->CLIENTE) + " - Loja: " + cValToChar(__PED04->LOJA)

    oObj:cGuidPedido := AllTrim(__PED04->uuid)
    oObj:cMsgProc    := ""
    
    oObj:Process()

    //|Erro no processamento? |
    If !Empty(oObj:cMsgProc)
      cMsgLog   += CRLF + oObj:cMsgProc
    Else
      cMsgLog   += CRLF + " -> Pedido atualizado com sucesso no portal vinilico."
    EndIf

    If lLog
      oSchd:LogMessage( cMsgLog + CRLF )
    EndIf

    ConOut(cMsgLog )

    __PED04->( dbSkip() )    

  EndDo

  If lLog
    oSchd:LogMessage( "FINALIZADO ATUALIZACAO PEDIDO PORTAL VINILICO" + CRLF )
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
  Local cDataIni   := fGetDate()

  cQuery += " SELECT VPC.uuid, 
  cQuery += " VPC.customer_code AS CLIENTE, "
  cQuery += " VPC.customer_store AS LOJA "
  cQuery += " FROM VNINTEGRACAO_PEDIDO_CABEC VPC "
  cQuery += " WHERE VPC.timestamp_integrated >= " + ValToSql( cDataIni )

Return cQuery


/*/{Protheus.doc} fGetDate
Busca a data de filtro e formata
@type function
@version 1.0
@author Pontin - Facile Sistemas
@since 15/01/2021
@return character, Data de filtro
/*/
Static Function fGetDate()

  Local cDate   := ""
  Local nDias   := 1

  //|Formato: aaaa-mm-dd  h:m:s.ms' |
  cDate   := DtoS( DaySub(dDataBase, nDias) )
  cDate   := SubStr(cDate, 1, 4) + "-" + SubStr(cDate, 5, 2) + "-" + SubStr(cDate, 7, 2)
  cDate   := cDate + " 01:00:00.000"

Return cDate
