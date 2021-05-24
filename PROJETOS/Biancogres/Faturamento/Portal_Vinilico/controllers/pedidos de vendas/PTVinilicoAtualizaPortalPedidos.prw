#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVinilicoAtualizaPortalPedidos
Classe para atualizar os pedidos no Portal Vinilico
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 12/08/2020
/*/
Class PTVinilicoAtualizaPortalPedidos From PTVinilicoAbstractAPI

  Data cGuidPedido
  Data oPedido
  Data cMsgProc
  
  Method New() Constructor

  Method Process()
  Method GetPedido()
  Method Analyze()
  Method ParseJson()

  Method UpdatePortal()

EndClass


/*/{Protheus.doc} PTVinilicoAtualizaPortalPedidos::New
Método construtor da classe
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method New() Class PTVinilicoAtualizaPortalPedidos

  _Super:New()

  ::cGuidPedido := ""
  ::cMsgProc    := ""
  ::oPedido     := JsonObject():New()
  
Return


/*/{Protheus.doc} PTVinilicoAtualizaPortalPedidos::Process
Método para buscar os pedidos no portal vinilico
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method Process() Class PTVinilicoAtualizaPortalPedidos

  Local oError        := Nil
  Local aArea         := GetArea()
  Local cError        := ""
  Local bError        := ErrorBlock({|oError| cError := oError:Description})

  Begin Sequence

    //|Busca o pedido na stage area |
    ::GetPedido()

    //|Valida se encontrou dados |
    If ::oLst:GetCount() == 0
      ::cMsgProc    := "###ERRO -> NAO FOI POSSIVEL LOCALIZAR PEDIDO COM GUID: " + ::cGuidPedido + CRLF
      Return
    EndIf

    //|Analisa se o pedido esta apto a ser integrado |
    If ::Analyze()

      ::ParseJson()

      ::UpdatePortal()

    EndIf

  End Sequence

  ErrorBlock(bError)

  If !Empty(cError)
    _Super:Comunica( "Houve um erro no processamento: " + CRLF + CRLF + cError, .T. )
    ::cMsgProc  += "### ERRO - Houve um erro no processamento: " + CRLF + CRLF + cError
  EndIf

  FreeObj(oError)

  RestArea(aArea)

Return


/*/{Protheus.doc} PTVinilicoAtualizaPortalPedidos::GetPedido
Método responsável por buscar os dados do pedido na stage area
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@return object, dados do cliente
/*/
Method GetPedido() Class PTVinilicoAtualizaPortalPedidos

  Local cQuery    := ""
  Local oDados    := PTVinilicoPedidosCabecModel():New()

  ::oLst:Clear()

  cQuery += " SELECT "
  cQuery += "       emp_fil                 AS emp_fil "
  cQuery += "       , id                    AS id "
  cQuery += "       , uuid                  AS uuid "
  cQuery += "       , req_id                AS req_id "
  cQuery += "       , legacy_code           AS legacy_cod "
  cQuery += "       , customer_uuid         AS cust_uuid "
  cQuery += "       , customer_code         AS cust_code "
  cQuery += "       , customer_store        AS cust_store "
  cQuery += "       , payment_method_uuid   AS pay_uuid "
  cQuery += "       , payment_code          AS pay_code "
  cQuery += "       , total_sale_value      AS total_sale "
  cQuery += "       , freight_type          AS freight_ty "
  cQuery += "       , ipi_value             AS ipi_value "
  cQuery += "       , gross_value           AS gross_valu "
  cQuery += "       , net_value             AS net_value "
  cQuery += "       , discount_value        AS disc_value "
  cQuery += "       , discount_percentage   AS disc_perce "
  cQuery += "       , interest_value        AS inter_valu "
  cQuery += "       , interest_percentage   AS inter_perc "
  cQuery += "       , gross_weight          AS gross_weig "
  cQuery += "       , net_weight            AS net_weight "
  cQuery += "       , observation           AS observat "
  cQuery += "       , deadline              AS deadline "
  cQuery += "       , status_code           AS status_cod "
  cQuery += "       , created_at            AS created_at "
  cQuery += "       , freight_value         AS freight_va "
  cQuery += "       , freight_table_uuid    AS freight_ta "
  cQuery += "       , timestamp_import      AS time_impor "
  cQuery += "       , timestamp_integrated  AS time_integ "
  cQuery += "       , status_integrated     AS status_int "
  cQuery += "       , pedido_protheus       AS pedido "
  cQuery += "       , error_integrated      AS error_int "
  cQuery += " FROM VNINTEGRACAO_PEDIDO_CABEC VPC  "
  cQuery += " WHERE VPC.uuid = " + ValToSql( ::cGuidPedido )

  If Select("__CABEC") > 0
    __CABEC->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "__CABEC"

  __CABEC->( dbGoTop() )

  If !__CABEC->( EoF() )

    oDados:emp_fil            := __CABEC->emp_fil
    oDados:id                 := __CABEC->id
    oDados:uuid               := __CABEC->uuid
    oDados:req_id             := __CABEC->req_id
    oDados:legacy_code        := __CABEC->legacy_cod
    oDados:cust_uuid          := __CABEC->cust_uuid
    oDados:cust_code          := __CABEC->cust_code
    oDados:cust_store         := __CABEC->cust_store
    oDados:pay_uuid           := __CABEC->pay_uuid
    oDados:pay_code           := __CABEC->pay_code
    oDados:total_sale_value   := __CABEC->total_sale
    oDados:freight_type       := __CABEC->freight_ty
    oDados:ipi_value          := __CABEC->ipi_value
    oDados:gross_value        := __CABEC->gross_valu
    oDados:net_value          := __CABEC->net_value
    oDados:disc_value         := __CABEC->disc_value
    oDados:disc_percentage    := __CABEC->disc_perce
    oDados:inter_value        := __CABEC->inter_valu
    oDados:inter_percentage   := __CABEC->inter_perc
    oDados:gross_weight       := __CABEC->gross_weig
    oDados:net_weight         := __CABEC->net_weight
    oDados:observation        := __CABEC->observat
    oDados:deadline           := __CABEC->deadline
    oDados:status_code        := __CABEC->status_cod
    oDados:created_at         := __CABEC->created_at
    oDados:freight_value      := __CABEC->freight_va
    oDados:freight_table_uuid := __CABEC->freight_ta
    oDados:time_import        := __CABEC->time_impor
    oDados:time_integrated    := __CABEC->time_integ
    oDados:status_integrated  := __CABEC->status_int
    oDados:pedido_protheus    := __CABEC->pedido
    oDados:error_integrated   := __CABEC->error_int

    ::oLst:Add( oDados )

  EndIf
  
Return


/*/{Protheus.doc} PTVinilicoAtualizaPortalPedidos::Analyze
Validação de regras de negócio para permitir sincronizar o cliente
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param oObj, object, JsonObject do cliente
/*/
Method Analyze() Class PTVinilicoAtualizaPortalPedidos

  Local lValido   := .T.
  
Return lValido


/*/{Protheus.doc} PTVinilicoAtualizaPortalPedidos::ParseJson
Metodo responsável por montar o json de envio
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 15/01/2021
/*/
Method ParseJson() Class PTVinilicoAtualizaPortalPedidos

  Local cBranchKey := SuperGetMV( "ZZ_VNBRANC", .F., "08930868000100" )
  Local oDados     := ::oLst:GetItem(1)
  Local nStatus    := 1

  ::oPedido     := JsonObject():New()

  If oDados:status_integrated == "A"
    nStatus := 1
  ElseIf oDados:status_integrated == "P"
    nStatus := 2
  ElseIf oDados:status_integrated == "F"
    nStatus := 3
  EndIf

  ::oPedido["id"]          := oDados:id
  ::oPedido["uuid"]        := oDados:uuid
  ::oPedido["req_id"]      := oDados:req_id
  ::oPedido["legacy_code"] := oDados:pedido_protheus
  ::oPedido["company_key"] := SubStr(cBranchKey, 1, 8)
  ::oPedido["branch_key"]  := cBranchKey
  ::oPedido["status_code"] := nStatus

Return


/*/{Protheus.doc} PTVinilicoAtualizaPortalPedidos::UpdatePortal
Método responsável por atualizar o pedido no portal vinilico
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param oDados, object, JsonObject com dados do cliente
/*/
Method UpdatePortal() Class PTVinilicoAtualizaPortalPedidos

  Local oEnvio        := PTVinilicoTransmissaoAPI():New()
  Local jRemessa      := JsonObject():New()
  Local jJsonResp     := JsonObject():New()
  Local jPedido       := JsonObject():New()
  Local jRetorno      := JsonObject():New()
  Local nZ            := 0

  //|Monta o body para envio |
  jRemessa            := JsonObject():New()
  jRemessa["data"]    := JsonObject():New()
  jRemessa["data"]    := { ::oPedido }

  //|Transmite o titulo para o portal vinilico |
  oEnvio:cEndPoint    := "/orders"
  oEnvio:cToken       := ::cToken
  oEnvio:jBody        := jRemessa

  jRetorno  := oEnvio:Put()

  //Transmite para o Portal Vinilico |
  If jRetorno["status"] == "OK"

    //|Pega a resposta |
    jJsonResp     := JsonObject():New()
    jJsonResp:FromJson( jRetorno["message"] )

    //|Processa cada registro retornado |
    For nZ := 1 To Len( jJsonResp["data"] )

      jPedido  := JsonObject():New()
      jPedido  := jJsonResp["data"][nZ]

      //|Preço sincronizado com sucesso |
      If jPedido["status"] >= 200 .And. jPedido["status"]<= 299

         _Super:Comunica("Atualizado no portal GUID: " + AllTrim(::cGuidPedido) + " - Status: " + cValToChar(::oPedido["status_code"]) + " -> atualizado com sucesso.")

      Else

        ::cMsgProc   := _Super:ErroConvert( IIf( Empty( jPreco["error"]:ToJson() ), "", jPreco["error"]:ToJson() ) )

        If !Empty(::cMsgProc)

          _Super:Comunica(::cMsgProc)

        EndIf

      EndIf

    Next nZ

  Else

    ::cMsgProc   := jRetorno["message"]

    If ::lBlind
      _Super:Comunica( "### ERRO: " + ::cMsgProc )
    Else
      Aviso( "Portal Vinilico", ::cMsgProc, {"OK"}, 3 )
    EndIf

  EndIf

  FreeObj(oEnvio)
  FreeObj(jRemessa)
  FreeObj(jJsonResp)
  FreeObj(jRetorno)

Return
