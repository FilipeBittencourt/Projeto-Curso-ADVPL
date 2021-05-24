#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVinilicoBuscaPedidos
Classe para sincronizar os clientes com o portal vinilico
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 12/08/2020
/*/
Class PTVinilicoBuscaPedidos From PTVinilicoAbstractAPI

  Data cMsgProc

  Method New() Constructor

  Method Process()
  Method Get()
  Method Analyze()
  Method Save()
  Method AdjustValue()
  Method InsertCabec()
  Method InsertItem()

EndClass


/*/{Protheus.doc} PTVinilicoBuscaPedidos::New
Método construtor da classe
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method New() Class PTVinilicoBuscaPedidos

  _Super:New()

  ::cMsgProc    := ""

Return


/*/{Protheus.doc} PTVinilicoBuscaPedidos::Process
Método para buscar os pedidos no portal vinilico
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method Process() Class PTVinilicoBuscaPedidos

  Local oDados        := Nil
  Local oError        := Nil
  Local aArea         := GetArea()
  Local cError        := ""
  Local nI            := 0
  Local bError        := ErrorBlock({|oError| cError := oError:Description})

  Begin Sequence

    //|Busca os pedidos no portal |
    ::Get()

    For nI := 1 To ::oLst:GetCount()

      oDados  := ::oLst:GetItem(nI)

      ::cMsgProc  += Replicate("-", 69) + CRLF
      ::cMsgProc  += "Importando pedido id: " + cValtoChar( oDados["id"] ) + " - GUID: " + cValtoChar( oDados["uuid"] ) + CRLF

      //|Analisa se o pedido esta apto a ser importado |
      ::Analyze( @oDados )

      If oDados["valido"]

        //|Grava o pedido e os itens |
        ::Save( oDados )

      EndIf

    Next nI

  End Sequence

  ErrorBlock(bError)

  If (!Empty(cError))
    _Super:Comunica( "Houve um erro no processamento: " + CRLF + CRLF + cError, .T. )
    ::cMsgProc  += "### ERRO - Houve um erro no processamento: " + CRLF + CRLF + cError
  EndIf

  FreeObj(oError)
  FreeObj(oDados)

  RestArea(aArea)

Return


/*/{Protheus.doc} PTVinilicoBuscaPedidos::Get
Método responsável por buscar os pedidos
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@return object, dados do cliente
/*/
Method Get() Class PTVinilicoBuscaPedidos

  Local oEnvio        := PTVinilicoTransmissaoAPI():New()
  Local jRemessa      := JsonObject():New()
  Local jJsonResp     := JsonObject():New()
  Local jPedido       := JsonObject():New()
  Local jRetorno      := JsonObject():New()
  Local nZ            := 0
  Local cQuery        := ""

  ::oLst:Clear()

  //|Monta Query Params de consulta |
  cQuery  += "status_code=1"
  cQuery  += "&for_integration=true"

  //|Transmite o titulo para o portal vinilico |
  oEnvio:cEndPoint    := "/orders?" + cQuery 
  oEnvio:cToken       := ::cToken
  oEnvio:jBody        := jRemessa

  jRetorno  := oEnvio:Get()

  //Transmite para o Portal Vinilico |
  If jRetorno["status"] == "OK"

    //|Pega a resposta |
    jJsonResp     := JsonObject():New()
    jJsonResp:FromJson( jRetorno["message"] )

    //|Processa cada registro retornado |
    For nZ := 1 To Len( jJsonResp["data"] )

      jPedido  := JsonObject():New()
      jPedido  := jJsonResp["data"][nZ]

      ::oLst:Add( jPedido )

    Next nZ

  Else

    If ::lBlind
      _Super:Comunica( "### ERRO: " + jRetorno["message"] )
    Else
      Aviso( "Portal Vinilico", jRetorno["message"], {"OK"}, 3 )
    EndIf

  EndIf

  FreeObj(oEnvio)
  FreeObj(jRemessa)
  FreeObj(jJsonResp)
  FreeObj(jRetorno)
  
Return 


/*/{Protheus.doc} PTVinilicoBuscaPedidos::Analyze
Validação de regras de negócio para permitir sincronizar o cliente
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param oObj, object, JsonObject do cliente
/*/
Method Analyze( oObj ) Class PTVinilicoBuscaPedidos

  Local cQuery    := ""

  oObj["valido"]  := .T.

  //|Verifica se já existe na stage area |
  cQuery += " SELECT COUNT(*) AS QTD "
  cQuery += " FROM VNINTEGRACAO_PEDIDO_CABEC VPC "
  cQuery += " WHERE VPC.uuid = " + ValToSql( oObj["uuid"] )

  If Select("__PED")
    __PED->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "__PED"

  __PED->( dbGoTop() )

  If !__PED->( EoF() ) .And. __PED->QTD > 0

    oObj["valido"]  := .F.

    ::cMsgProc  += "---> Pedido ja existe na stage area <---" + CRLF

  EndIf

Return


/*/{Protheus.doc} PTVinilicoBuscaPedidos::Save
Método responsável por salvar os pedidos na stage area
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param oDados, object, JsonObject com dados do cliente
/*/
Method Save( oDados ) Class PTVinilicoBuscaPedidos

  Local cQuery  := ""
  Local nI      := 0
  Local lOk     := .F.
  Local oItem   := Nil
  

  Begin Transaction
    
    cQuery  := ::InsertCabec(oDados)

    If TcSqlExec(cQuery) < 0

      ConOut(TCSqlError())
      ::cMsgProc  += TCSqlError() + CRLF

      DisarmTransaction()
      lOk := .F.

    Else
      ::cMsgProc  += "CABEÇALHO DO PEDIDO IMPORTADO PARA A STAGE AREA COM SUCESSO!!" + CRLF
      lOk := .T.
    EndIf

    //|Cabeçalho incluido com sucesso |
    If lOk

      For nI := 1 To Len( oDados["order_items"] )

        oItem   := oDados["order_items"][nI]

        cQuery  := ::InsertItem(oItem)

        If TcSqlExec(cQuery) < 0

          ConOut(TCSqlError())
          ::cMsgProc  += TCSqlError() + CRLF

          DisarmTransaction()
          Exit

        Else
          ::cMsgProc  += "ITEM ID: " + cValToChar( oItem["id"] ) + " - " + cValToChar( oItem["product"]["legacy_code"] ) + " IMPORTADO PARA A STAGE AREA COM SUCESSO!!" + CRLF
        EndIf

        FreeObj(oItem)

      Next nI


    EndIf

  End Transaction

Return


/*/{Protheus.doc} PTVinilicoBuscaPedidos::AdjustValue
Ajusta o valor recebido do Portal
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 11/01/2021
/*/
Method AdjustValue( xValor, cTipoRet ) Class PTVinilicoBuscaPedidos

  Default cTipoRet := "C"

  If ValType(xValor) == "U"

    If cTipoRet == "C"
      xValor  := ""
    ElseIf cTipoRet == "N"
      xValor  := 0
    EndIf

  EndIf

  If ValType(xValor) == "L"
    xValor  := IIf(xValor, "S", "N")
  EndIf
  
  xValor  := ValToSql(xValor)

Return xValor


/*/{Protheus.doc} PTVinilicoBuscaPedidos::InsertCabec
Monta a string de insert do cabeçalho do pedido
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 12/01/2021
@param oDados, object, objeto com os dados do pedido
@return character, String de insert
/*/
Method InsertCabec( oDados ) Class PTVinilicoBuscaPedidos

  Local cQuery  := ""

  cQuery += " INSERT INTO [dbo].[VNINTEGRACAO_PEDIDO_CABEC] "
  cQuery += "         ([emp_fil] "
  cQuery += "         ,[id] "
  cQuery += "         ,[uuid] "
  cQuery += "         ,[req_id] "
  cQuery += "         ,[legacy_code] "
  cQuery += "         ,[customer_uuid] "
  cQuery += "         ,[customer_code] "
  cQuery += "         ,[customer_store] "
  cQuery += "         ,[payment_method_uuid] "
  cQuery += "         ,[payment_code] "
  cQuery += "         ,[total_sale_value] "
  cQuery += "         ,[freight_type] "
  cQuery += "         ,[ipi_value] "
  cQuery += "         ,[gross_value] "
  cQuery += "         ,[net_value] "
  cQuery += "         ,[discount_value] "
  cQuery += "         ,[discount_percentage] "
  cQuery += "         ,[interest_value] "
  cQuery += "         ,[interest_percentage] "
  cQuery += "         ,[gross_weight] "
  cQuery += "         ,[net_weight] "
  cQuery += "         ,[observation] "
  cQuery += "         ,[deadline] "
  cQuery += "         ,[status_code] "
  cQuery += "         ,[created_at] "
  cQuery += "         ,[freight_value] "
  cQuery += "         ,[freight_table_uuid] "
  cQuery += "         ,[timestamp_import] "
  cQuery += "         ,[timestamp_integrated] "
  cQuery += "         ,[status_integrated] "
  cQuery += "         ,[pedido_protheus]) "
  cQuery += "   VALUES "
  cQuery += "         ( '' "                                                                             //<emp_fil, varchar(4),>
  cQuery += "         , " + ::AdjustValue( oDados["id"], "N" )                                          //<id, int,>
  cQuery += "         , " + ::AdjustValue( oDados["uuid"] )                                             //<uuid, varchar(36),>
  cQuery += "         , " + ::AdjustValue( oDados["req_id"] )                                           //<req_id, varchar(255),>
  cQuery += "         , " + ::AdjustValue( oDados["legacy_code"] )                                      //<legacy_code, varchar(255),>
  cQuery += "         , " + ::AdjustValue( oDados["customer_uuid"] )                                    //<customer_uuid, varchar(36),>
  cQuery += "         , " + ::AdjustValue( SubStr(oDados["customer"]["legacy_code"], 1, 6) )            //<customer_code, varchar(6),>
  cQuery += "         , " + ::AdjustValue( SubStr(oDados["customer"]["legacy_code"], 7, 2) )            //<customer_store, varchar(2),>
  cQuery += "         , " + ::AdjustValue( oDados["payment_method"]["uuid"] )                           //<payment_method_uuid, varchar(36),>
  cQuery += "         , " + ::AdjustValue( oDados["payment_method"]["legacy_code"] )                    //<payment_code, varchar(3),>
  cQuery += "         , " + ::AdjustValue( oDados["total_sale_value"], "N" )                            //<total_sale_value, float,>
  cQuery += "         , " + ::AdjustValue( oDados["freight_type"] )                                     //<freight_type, varchar(10),>
  cQuery += "         , " + ::AdjustValue( oDados["ipi_value"], "N" )                                   //<ipi_value, float,>
  cQuery += "         , " + ::AdjustValue( oDados["gross_value"], "N" )                                 //<gross_value, float,>
  cQuery += "         , " + ::AdjustValue( oDados["net_value"], "N" )                                   //<net_value, float,>
  cQuery += "         , " + ::AdjustValue( oDados["discount_value"], "N" )                              //<discount_value, float,>
  cQuery += "         , " + ::AdjustValue( oDados["discount_percentage"], "N" )                         //<discount_percentage, float,>
  cQuery += "         , " + ::AdjustValue( oDados["interest_value"], "N" )                              //<interest_value, float,>
  cQuery += "         , " + ::AdjustValue( oDados["interest_percentage"], "N" )                         //<interest_percentage, float,>
  cQuery += "         , " + ::AdjustValue( oDados["gross_weight"], "N" )                                //<gross_weight, float,>
  cQuery += "         , " + ::AdjustValue( oDados["net_weight"], "N" )                                  //<net_weight, float,>
  cQuery += "         , " + ::AdjustValue( oDados["observation"] )                                      //<observation, varchar(255),>
  cQuery += "         , " + ::AdjustValue( oDados["deadline"], "N" )                                    //<deadline, int,>
  cQuery += "         , " + ::AdjustValue( oDados["status_code"], "N" )                                 //<status_code, int,>
  cQuery += "         , " + ::AdjustValue( oDados["created_at"] )                                       //<created_at, datetime,>
  cQuery += "         , " + ::AdjustValue( oDados["freight_value"], "N" )                               //<freight_value, float,>
  cQuery += "         , " + ::AdjustValue( oDados["freight_table_uuid"] )                               //<freight_table_uuid, varchar(36),>
  cQuery += "         , " + ::AdjustValue( FwTimeStamp(3) )                                             //<timestamp_import, datetime,>
  cQuery += "         , ''"                                                                             //<timestamp_integrated, datetime,>
  cQuery += "         , 'A'"                                                                            //<status_integrated, varchar(1),>
  cQuery += "         , '')"                                                                            //<pedido_protheus, varchar(6),>

Return cQuery


/*/{Protheus.doc} PTVinilicoBuscaPedidos::InsertItem
Monta a string de insert do item do pedido
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 12/01/2021
@param oItem, object, objeto com os dados do item do pedido
@return character, String de insert
/*/
Method InsertItem( oItem ) Class PTVinilicoBuscaPedidos

  Local cQuery  := ""

  cQuery += " INSERT INTO [dbo].[VNINTEGRACAO_PEDIDO_ITENS] "
  cQuery += "          ([emp_fil] "
  cQuery += "          ,[id] "
  cQuery += "          ,[uuid] "
  cQuery += "          ,[req_id] "
  cQuery += "          ,[legacy_code] "
  cQuery += "          ,[order_uuid] "
  cQuery += "          ,[product_uuid] "
  cQuery += "          ,[product_code] "
  cQuery += "          ,[price_list_uuid] "
  cQuery += "          ,[quantity] "
  cQuery += "          ,[unitary_gross_value] "
  cQuery += "          ,[unitary_net_value] "
  cQuery += "          ,[unitary_ipi_value] "
  cQuery += "          ,[unitary_discount_value] "
  cQuery += "          ,[unitary_gross_weight] "
  cQuery += "          ,[unitary_net_weight] "
  cQuery += "          ,[total_gross_value] "
  cQuery += "          ,[total_net_value] "
  cQuery += "          ,[total_discount_value] "
  cQuery += "          ,[total_gross_weight] "
  cQuery += "          ,[total_ipi_value] "
  cQuery += "          ,[total_net_weight] "
  cQuery += "          ,[ipi_percentage] "
  cQuery += "          ,[discount_percentage] "
  cQuery += "          ,[deadline] "
  cQuery += "          ,[created_at] "
  cQuery += "          ,[is_pallet]) "
  cQuery += "    VALUES "
  cQuery += "          ('' "                                                              //<emp_fil, varchar(4),>
  cQuery += "          , " + ::AdjustValue( oItem["id"], "N" )                            //<id, int,>
  cQuery += "          , " + ::AdjustValue( oItem["uuid"] )                               //<uuid, varchar(36),>
  cQuery += "          , " + ::AdjustValue( oItem["req_id"] )                             //<req_id, varchar(255),>
  cQuery += "          , " + ::AdjustValue( oItem["legacy_code"] )                        //<legacy_code, varchar(255),>
  cQuery += "          , " + ::AdjustValue( oItem["order_uuid"] )                         //<order_uuid, varchar(36),>
  cQuery += "          , " + ::AdjustValue( oItem["product_uuid"] )                       //<product_uuid, varchar(36),>
  cQuery += "          , " + ::AdjustValue( oItem["product"]["legacy_code"] )             //<product_code, varchar(15),>
  cQuery += "          , " + ::AdjustValue( oItem["price_list_uuid"] )                    //<price_list_uuid, varchar(36),>
  cQuery += "          , " + ::AdjustValue( oItem["quantity"], "N" )                      //<quantity, float,>
  cQuery += "          , " + ::AdjustValue( oItem["unitary_gross_value"], "N" )           //<unitary_gross_value, float,>
  cQuery += "          , " + ::AdjustValue( oItem["unitary_net_value"], "N" )             //<unitary_net_value, float,>
  cQuery += "          , " + ::AdjustValue( oItem["unitary_ipi_value"], "N" )             //<unitary_ipi_value, float,>
  cQuery += "          , " + ::AdjustValue( oItem["unitary_discount_value"], "N" )        //<unitary_discount_value, float,>
  cQuery += "          , " + ::AdjustValue( oItem["unitary_gross_weight"], "N" )          //<unitary_gross_weight, float,>
  cQuery += "          , " + ::AdjustValue( oItem["unitary_net_weight"], "N" )            //<unitary_net_weight, float,>
  cQuery += "          , " + ::AdjustValue( oItem["total_gross_value"], "N" )             //<total_gross_value, float,>
  cQuery += "          , " + ::AdjustValue( oItem["total_net_value"], "N" )               //<total_net_value, float,>
  cQuery += "          , " + ::AdjustValue( oItem["total_discount_value"], "N" )          //<total_discount_value, float,>
  cQuery += "          , " + ::AdjustValue( oItem["total_gross_weight"], "N" )            //<total_gross_weight, float,>
  cQuery += "          , " + ::AdjustValue( oItem["total_ipi_value"], "N" )               //<total_ipi_value, float,>
  cQuery += "          , " + ::AdjustValue( oItem["total_net_weight"], "N" )              //<total_net_weight, float,>
  cQuery += "          , " + ::AdjustValue( oItem["ipi_percentage"], "N" )                //<ipi_percentage, float,>
  cQuery += "          , " + ::AdjustValue( oItem["discount_percentage"], "N" )           //<discount_percentage, float,>
  cQuery += "          , " + ::AdjustValue( oItem["deadline"], "N" )                      //<deadline, int,>
  cQuery += "          , " + ::AdjustValue( oItem["created_at"] )                         //<created_at, datetime,>
  cQuery += "          , " + ::AdjustValue( oItem["is_pallet"] )                          //<is_pallet, varchar(1),>)
  cQuery += "         )" 

Return cQuery
