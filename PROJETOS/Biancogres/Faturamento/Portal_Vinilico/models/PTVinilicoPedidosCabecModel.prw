#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} PTVinilicoPedidosCabecModel
Classe de interface para modelo de dados do cabeçalho do pedido de venda
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 12/01/2021
/*/
Class PTVinilicoPedidosCabecModel From LongClassName

  Data emp_fil
  Data id
  Data uuid
  Data req_id
  Data legacy_code
  Data cust_uuid
  Data cust_code
  Data cust_store
  Data pay_uuid
  Data pay_code
  Data total_sale_value
  Data freight_type
  Data ipi_value
  Data gross_value
  Data net_value
  Data disc_value
  Data disc_percentage
  Data inter_value
  Data inter_percentage
  Data gross_weight
  Data net_weight
  Data observation
  Data deadline
  Data status_code
  Data created_at
  Data freight_value
  Data freight_table_uuid
  Data time_import
  Data time_integrated
  Data status_integrated
  Data pedido_protheus
  Data error_integrated

  Method New() Constructor

EndClass


Method New() Class PTVinilicoPedidosCabecModel

  ::emp_fil            := ""
  ::id                 := 0
  ::uuid               := ""
  ::req_id             := ""
  ::legacy_code        := ""
  ::cust_uuid          := ""
  ::cust_code          := ""
  ::cust_store         := ""
  ::pay_uuid           := ""
  ::pay_code           := ""
  ::total_sale_value   := 0
  ::freight_type       := ""
  ::ipi_value          := 0
  ::gross_value        := 0
  ::net_value          := 0
  ::disc_value         := 0
  ::disc_percentage    := 0
  ::inter_value        := 0
  ::inter_percentage   := 0
  ::gross_weight       := 0
  ::net_weight         := 0
  ::observation        := ""
  ::deadline           := 0
  ::status_code        := 0
  ::created_at         := ""
  ::freight_value      := 0
  ::freight_table_uuid := ""
  ::time_import        := ""
  ::time_integrated    := ""
  ::status_integrated  := ""
  ::pedido_protheus    := ""
  ::error_integrated   := ""

Return()
