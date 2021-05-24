#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} PTVinilicoPedidosItemModel
Classe de interface para modelo de dados do item do pedido de venda
@type class
@version 1.0
@author Pontin - Facile Sistemas
@since 12/01/2021
/*/
Class PTVinilicoPedidosItemModel From LongClassName

  Data emp_fil
  Data id
  Data uuid
  Data req_id
  Data legacy_code
  Data order_uuid
  Data product_uuid
  Data product_code
  Data price_list_uuid
  Data quantity
  Data unit_gross_value
  Data unit_net_value
  Data unit_ipi_value
  Data unit_discount_value
  Data unit_gross_weight
  Data unit_net_weight
  Data total_gross_value
  Data total_net_value
  Data total_discount_value
  Data total_gross_weight
  Data total_ipi_value
  Data total_net_weight
  Data ipi_percentage
  Data discount_percentage
  Data deadline
  Data created_at
  Data is_pallet
  
  
  Method New() Constructor

EndClass


Method New() Class PTVinilicoPedidosItemModel

  ::emp_fil              := ""
  ::id                   := 0
  ::uuid                 := ""
  ::req_id               := ""
  ::legacy_code          := ""
  ::order_uuid           := ""
  ::product_uuid         := ""
  ::product_code         := ""
  ::price_list_uuid      := ""
  ::quantity             := 0
  ::unit_gross_value     := 0
  ::unit_net_value       := 0
  ::unit_ipi_value       := 0
  ::unit_discount_value  := 0
  ::unit_gross_weight    := 0
  ::unit_net_weight      := 0
  ::total_gross_value    := 0
  ::total_net_value      := 0
  ::total_discount_value := 0
  ::total_gross_weight   := 0
  ::total_ipi_value      := 0
  ::total_net_weight     := 0
  ::ipi_percentage       := 0
  ::discount_percentage  := 0
  ::deadline             := 0
  ::created_at           := ""
  ::is_pallet            := ""

Return()
