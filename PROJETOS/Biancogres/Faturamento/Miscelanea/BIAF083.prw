#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF083
@author Tiago Rossini Coradini
@since 20/07/2017
@version 1.0
@description Rotina para exclusão do bloqueio comercial do pedido de venda
@obs OS: 4538-16 - Claudeir Fadini
@type function
/*/

User Function BIAF083(cNumPed)
Local aArea := GetArea()
Local oBlqCom := TBloqueioComercialPedidoVenda():New()

	oBlqCom:cNumPed := cNumPed
	
	If oBlqCom:Existe()
		
		oBlqCom:Exclui()		
	
	EndIf
	
	RestArea(aArea)
	
Return()