#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PTVinilicoIncluiPedidos
Classe para sincronizar os clientes com o portal vinilico
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 12/08/2020
/*/
Class PTVinilicoIncluiPedidos From PTVinilicoAbstractAPI

  Data cGuidPedido
  Data cMsgProc
  Data cEmpDest
  Data cFilDest

  Data oLstCabec
  Data oLstItem

  Method New() Constructor

  Method Process()

  Method GetCabec()
  Method GetItem()
  Method AdjustValue()
  Method ChangeEmp()

  Method Analyze()
  Method GeraPedidoVenda()
  Method UpdStageArea()

EndClass


/*/{Protheus.doc} PTVinilicoIncluiPedidos::New
Método construtor da classe
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method New() Class PTVinilicoIncluiPedidos

  _Super:New()

  ::cGuidPedido := ""
  ::cMsgProc    := ""
  ::cEmpDest    := ""
  ::cFilDest    := ""

  ::oLstCabec     := ArrayList():New()
  ::oLstItem      := ArrayList():New()

Return


/*/{Protheus.doc} PTVinilicoIncluiPedidos::Process
Método para buscar os pedidos no portal vinilico
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
/*/
Method Process() Class PTVinilicoIncluiPedidos

  Local oDados        := Nil
  Local oError        := Nil
  Local aArea         := GetArea()
  Local cError        := ""
  Local bError        := ErrorBlock({|oError| cError := oError:Description})

  Begin Sequence

    //|Busca o pedido na stage area |
    ::GetCabec()
    ::GetItem()

    //|Valida se encontrou dados |
    If ::oLstCabec:GetCount() == 0 .Or. ::oLstItem:GetCount() == 0
      ::cMsgProc    := "###ERRO -> NAO FOI POSSIVEL LOCALIZAR PEDIDO E ITENS COM GUID: " + ::cGuidPedido + CRLF
      Return
    EndIf

    //|Muda a empresa e filial para a de destino do pedido |
    ::ChangeEmp()

    //|Analisa se o pedido esta apto a ser importado |
    If ::Analyze()

      ::GeraPedidoVenda()

    EndIf

  End Sequence

  ErrorBlock(bError)

  If !Empty(cError)
    _Super:Comunica( "Houve um erro no processamento: " + CRLF + CRLF + cError, .T. )
    ::cMsgProc  += "### ERRO - Houve um erro no processamento: " + CRLF + CRLF + cError
  EndIf

  FreeObj(oError)
  FreeObj(oDados)

  RestArea(aArea)

Return


/*/{Protheus.doc} PTVinilicoIncluiPedidos::GetCabec
Método responsável por buscar o cabeçalho do pedido
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@return object, dados do cliente
/*/
Method GetCabec() Class PTVinilicoIncluiPedidos

  Local cQuery    := ""
  Local oDados    := PTVinilicoPedidosCabecModel():New()

  ::oLstCabec:Clear()

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
  cQuery += " AND VPC.status_integrated = 'A' "

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

    ::oLstCabec:Add( oDados )

  EndIf
  
Return


/*/{Protheus.doc} PTVinilicoIncluiPedidos::GetItem
Método responsável por buscar o item do pedido
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@return object, dados do cliente
/*/
Method GetItem() Class PTVinilicoIncluiPedidos

  Local cQuery    := ""
  Local oDados    := Nil

  ::oLstItem:Clear()

  cQuery += " SELECT emp_fil                  AS emp_fil, "
  cQuery += "       id                        AS id, "
  cQuery += "       uuid                      AS uuid, "
  cQuery += "       req_id                    AS req_id, "
  cQuery += "       legacy_code               AS legacy_cod, "
  cQuery += "       order_uuid                AS order_uuid, "
  cQuery += "       product_uuid              AS prod_uuid, "
  cQuery += "       product_code              AS prod_code, "
  cQuery += "       price_list_uuid           AS price_list, "
  cQuery += "       quantity                  AS quantity, "
  cQuery += "       unitary_gross_value       AS unit_gross, "
  cQuery += "       unitary_net_value         AS unit_net, "
  cQuery += "       unitary_ipi_value         AS unit_ipi, "
  cQuery += "       unitary_discount_value    AS unit_disco, "
  cQuery += "       unitary_gross_weight      AS unit_gro_w, "
  cQuery += "       unitary_net_weight        AS unit_net_w, "
  cQuery += "       total_gross_value         AS total_gross, "
  cQuery += "       total_net_value           AS total_net, "
  cQuery += "       total_discount_value      AS total_disc, "
  cQuery += "       total_gross_weight        AS tot_gros_w, "
  cQuery += "       total_ipi_value           AS total_ipi, "
  cQuery += "       total_net_weight          AS tot_net_w, "
  cQuery += "       ipi_percentage            AS ipi_percen, "
  cQuery += "       discount_percentage       AS disc_perc, "
  cQuery += "       deadline                  AS deadline, "
  cQuery += "       created_at                AS created_at, "
  cQuery += "       is_pallet                 AS is_pallet  "
  cQuery += " FROM VNINTEGRACAO_PEDIDO_ITENS VPI "
  cQuery += " WHERE VPI.order_uuid = " + ValToSql( ::cGuidPedido )

  If Select("__ITEM") > 0
    __ITEM->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "__ITEM"

  __ITEM->( dbGoTop() )

  While !__ITEM->( EoF() )

    oDados    := PTVinilicoPedidosItemModel():New()

    oDados:emp_fil              := __ITEM->emp_fil
    oDados:id                   := __ITEM->id
    oDados:uuid                 := __ITEM->uuid
    oDados:req_id               := __ITEM->req_id
    oDados:legacy_code          := __ITEM->legacy_cod
    oDados:order_uuid           := __ITEM->order_uuid
    oDados:product_uuid         := __ITEM->prod_uuid
    oDados:product_code         := __ITEM->prod_code
    oDados:price_list_uuid      := __ITEM->price_list
    oDados:quantity             := __ITEM->quantity
    oDados:unit_gross_value     := __ITEM->unit_gross
    oDados:unit_net_value       := __ITEM->unit_net
    oDados:unit_ipi_value       := __ITEM->unit_ipi
    oDados:unit_discount_value  := __ITEM->unit_disco
    oDados:unit_gross_weight    := __ITEM->unit_gro_w
    oDados:unit_net_weight      := __ITEM->unit_net_w
    oDados:total_gross_value    := __ITEM->total_gross
    oDados:total_net_value      := __ITEM->total_net
    oDados:total_discount_value := __ITEM->total_disc
    oDados:total_gross_weight   := __ITEM->tot_gros_w
    oDados:total_ipi_value      := __ITEM->total_ipi
    oDados:total_net_weight     := __ITEM->tot_net_w
    oDados:ipi_percentage       := __ITEM->ipi_percen
    oDados:discount_percentage  := __ITEM->disc_perc
    oDados:deadline             := __ITEM->deadline
    oDados:created_at           := __ITEM->created_at
    oDados:is_pallet            := __ITEM->is_pallet

    ::oLstItem:Add( oDados )

    __ITEM->( dbSkip() )

  EndDo
  
Return 


/*/{Protheus.doc} PTVinilicoIncluiPedidos::Analyze
Validação de regras de negócio para permitir sincronizar o cliente
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param oObj, object, JsonObject do cliente
/*/
Method Analyze() Class PTVinilicoIncluiPedidos

  Local lValido   := .T.
  Local cQuery    := ""

  cQuery += " SELECT COUNT(*) AS QTD "
  cQuery += " FROM SC5" + ::cEmpDest + "0 SC5 "
  cQuery += " WHERE SC5.C5_FILIAL = " + ValToSql( ::cFilDest )
  cQuery += "   AND SC5.C5_EMISSAO >= '20210101' "
  cQuery += "   AND SC5.C5_YIDVINI = " + ValToSql( ::cGuidPedido )
  cQuery += "   AND SC5.D_E_L_E_T_ = '' "

  If Select("__VAL") > 0
    __VAL->( dbCloseArea() )
  EndIf

  TcQuery cQuery New Alias "__VAL"

  __VAL->( dbGoTop() )

  If !__VAL->( EoF() ) .And. __VAL->QTD > 0
    lValido := .F.
    ::cMsgProc  += "### ERRO -> Pedido ja existe no Protheus"
  EndIf

Return lValido


/*/{Protheus.doc} PTVinilicoIncluiPedidos::GeraPedidoVenda
Método responsável por gerar o pedido de venda no Protheus
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 19/12/2020
@param oDados, object, JsonObject com dados do cliente
/*/
Method GeraPedidoVenda() Class PTVinilicoIncluiPedidos

  Local aCabSC5		:= {}
  Local aItensSC6	:= {}
  Local aItemSC6	:= {}
  Local aRetorno  := {}
  Local nI        := 0
  Local nTotal    := 0
  Local cItem     := ""
  Local cNumPed   := ""
  Local oPedido   := Nil
  Local oItem     := Nil

  //------------------------------
  // Cabeçalho do Pedido de Venda
  //------------------------------

  oPedido := ::oLstCabec:GetItem(1)

  ::cMsgProc  += "Montando cabecalho da SC5 Guid: " + AllTrim(oPedido:uuid) + " - Cliente: " + oPedido:cust_code + oPedido:cust_store + CRLF

  aAdd(aCabSC5, {"C5_NUM"   		  , ""		   				                 , Nil})
  aAdd(aCabSC5, {"C5_TIPO"   		  , "N"				   		                 , Nil})
  
  aAdd(aCabSC5, {"C5_YLINHA"	    , "6"					                     , Nil})
  aAdd(aCabSC5, {"C5_YSUBTP"	    , "IM"					                   , Nil})

  aAdd(aCabSC5, {"C5_CLIENTE"   	, oPedido:cust_code		             , Nil})
  aAdd(aCabSC5, {"C5_LOJACLI"   	, oPedido:cust_store	             , Nil})
  aAdd(aCabSC5, {"C5_CLIENT"   	  , oPedido:cust_code		             , Nil})
  aAdd(aCabSC5, {"C5_LOJAENT"		  , oPedido:cust_store	             , Nil})
  
  aAdd(aCabSC5, {"C5_TRANSP"		  , ""						                   , Nil})

  aAdd(aCabSC5, {"C5_YCONF"		    , "S"						                   , Nil})
  aAdd(aCabSC5, {"C5_VEND1"		    , "999999"					               , Nil})
  aAdd(aCabSC5, {"C5_COMIS1"		  , 0							                   , Nil})
  aAdd(aCabSC5, {"C5_COMIS2"		  , 0							                   , Nil})
  aAdd(aCabSC5, {"C5_COMIS3"		  , 0							                   , Nil})
  aAdd(aCabSC5, {"C5_COMIS4"		  , 0							                   , Nil})
  aAdd(aCabSC5, {"C5_COMIS5"		  , 0							                   , Nil})
  
  aAdd(aCabSC5, {"C5_EMISSAO"		  , dDataBase					               , Nil})
  aAdd(aCabSC5, {"C5_TPFRETE"		  , SubStr(oPedido:freight_type,1,1) , Nil})

  aAdd(aCabSC5, {"C5_CONDPAG"		  , oPedido:pay_code  	             , Nil})
  aAdd(aCabSC5, {"C5_ORIGEM"		  , ""						                   , Nil})
  aAdd(aCabSC5, {"C5_MENNOTA"	    , oPedido:observation	             , Nil})
  aAdd(aCabSC5, {"C5_YIDVINI"	    , oPedido:uuid	                   , Nil})

  // aCabSC5 := FWVetByDic(aCabSC5, "SC5", .F., 1)

  //------------------------------
  // Itens do Pedido de Venda
  //------------------------------
  For nI := 1 To ::oLstItem:GetCount()

    aItemSC6  := {}
    oItem     := ::oLstItem:GetItem(nI)

    cItem     := StrZero( nI, TamSx3("C6_ITEM")[1] )

    ::cMsgProc  += "Montando itens da SC6 Produto: " + AllTrim(oItem:product_code) + CRLF
  
    aAdd(aItemSC6, {"C6_NUM"		  , ""								  	    , Nil})
    aAdd(aItemSC6, {"C6_ITEM"		  , cItem									    , Nil})
    aAdd(aItemSC6, {"C6_PRODUTO"	, oItem:product_code		    , Nil})
    aAdd(aItemSC6, {"C6_QTDVEN"		, oItem:quantity		        , Nil})
    aAdd(aItemSC6, {"C6_PRCVEN"		, oItem:unit_net_value	    , Nil})

    nTotal  := oItem:unit_net_value * oItem:quantity

    aAdd(aItemSC6, {"C6_VALOR"		, Round(nTotal ,2)          , Nil})
    aAdd(aItemSC6, {"C6_PRUNIT"		, oItem:unit_gross_value		, Nil})
    aAdd(aItemSC6, {"C6_YFATMUL"	, 1		                      , Nil})
    aAdd(aItemSC6, {"C6_YPRCTAB"	, oItem:unit_gross_value		, Nil})

    aItemSC6 := FWVetByDic(aItemSC6, "SC6", .F., 1)

    aAdd( aItensSC6, aClone(aItemSC6) )

  Next nI 

  //|Chama função responsável por gerar o pedido na empresa e filial correta |
  ::cMsgProc  += "Enviando pedido para execauto na empresa/filial: " + ::cEmpDest + "/" + ::cFilDest + CRLF

  // aRetorno := U_FROPCPRO( ::cEmpDest, ::cFilDest,"U_PTVPED03", aCabSC5, aItensSC6 )
  aRetorno    := U_PTVPED03( aCabSC5, aItensSC6 )

  ::cMsgProc  += aRetorno[1] + CRLF
  cNumPed     := aRetorno[2]

  //|Atualiza a stage area |
  ::UpdStageArea(cNumPed, aRetorno[1])

  FreeObj(oPedido)
  FreeObj(oItem)

Return


/*/{Protheus.doc} PTVinilicoIncluiPedidos::AdjustValue
Ajusta o valor recebido do Portal
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 11/01/2021
/*/
Method AdjustValue( xValor, cTipoRet ) Class PTVinilicoIncluiPedidos

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


/*/{Protheus.doc} PTVinilicoIncluiPedidos::ChangeEmp
Realiza a mudança da empresa e filial para a de destino do pedido de venda
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 12/01/2021
/*/
Method ChangeEmp() Class PTVinilicoIncluiPedidos

  //|Pega empresa e filial para o pedido |
  ::cEmpDest := "07"
  ::cFilDest := "01"

  nModulo := 5
  
Return

/*/{Protheus.doc} PTVinilicoIncluiPedidos::UpdStageArea
Método responsável por atualizar os dados na stage area
@type method
@version 1.0
@author Pontin - Facile Sistemas
@since 14/01/2021
@param cNumPed, character, numero do pedido
@param cMsgErro, character, Mensagem de erro
/*/
Method UpdStageArea(cNumPed, cMsgErro) Class PTVinilicoIncluiPedidos

  Local lErro   := Len( AllTrim(cNumPed) ) != TamSx3("C5_NUM")[1]
  Local cQuery  := ""

  cQuery += " UPDATE VPC SET "

  If !lErro

    cQuery += " VPC.emp_fil = " + ValToSql( ::cEmpDest + ::cFilDest ) + ", "
    cQuery += " VPC.timestamp_integrated = " + ValToSql( FwTimeStamp(3) ) + ", "
    cQuery += " VPC.status_integrated = 'P',
    cQuery += " VPC.pedido_protheus = " + ValToSql( cNumPed ) + ", "
    cQuery += " VPC.error_integrated = '' "
  
  Else

    cQuery += " VPC.timestamp_integrated = " + ValToSql( FwTimeStamp(3) ) + ", "
    cQuery += " VPC.error_integrated = " + ValToSql( cNumPed + "-" + cMsgErro )
  
  EndIf

  cQuery += " FROM VNINTEGRACAO_PEDIDO_CABEC VPC "
  cQuery += " WHERE VPC.uuid = " + ValToSql( ::cGuidPedido )

  If TcSqlExec(cQuery) < 0

    ConOut(TCSqlError())
    ::cMsgProc  += TCSqlError() + CRLF

  Else
    ::cMsgProc  += "PEDIDO DE VENDA " + cNumPed + " INCLUIDO COM SUCESSO!!" + CRLF
  EndIf

Return
