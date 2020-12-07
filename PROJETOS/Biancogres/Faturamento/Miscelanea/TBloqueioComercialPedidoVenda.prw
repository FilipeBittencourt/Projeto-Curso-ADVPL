#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TBloqueioComercialPedidoVenda
@author Tiago Rossini Coradini
@since 27/07/2017
@version 1.0
@description Classe para bloqueio comercial do pedidos de venda 
@obs OS: 4538-16 - Claudeir Fadini
@type class
/*/

Class TBloqueioComercialPedidoVenda From LongClassName	
	
	Data cNumPed
	
	Method New() Constructor
	Method Inclui()
	Method Exclui()
	Method Existe()
			
EndClass


Method New() Class TBloqueioComercialPedidoVenda
	
	::cNumPed 		:= ""
			
Return()


Method Inclui() Class TBloqueioComercialPedidoVenda
	
	Local cNomApr	:= ""
	Local cIdZKL	:= ""
	
	ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TBloqueioComercialPedidoVenda:Inclui() -- Empresa: "+ cEmpAnt +" -- Pedido: "+ ::cNumPed )
	
	If ::Existe()
	
		::Exclui()
	
	EndIf
	
	oPedAprov := TPedidoAprovador():New(::cNumPed)
	cIdZKL := oPedAprov:GetIdAprov()	
	
	If (!Empty(cIdZKL))
	
		DbSelectArea("ZKL")
		ZKL->(DbGoto(cIdZKL))
		
		cNomApr  := ZKL->ZKL_APROV	
		
		RecLock("UZ7", .T.)
		
			UZ7->UZ7_FILIAL	:= xFilial("UZ7")
			UZ7->UZ7_PEDIDO	:= ::cNumPed
			UZ7->UZ7_AAPROV := UsrRetName(cNomApr)
			
		UZ7->(MsUnlock())
	
	EndIf
	
		
Return()


Method Exclui() Class TBloqueioComercialPedidoVenda
		
	RecLock("UZ7", .F.)
	
		UZ7->(DbDelete())
	
	MsUnlock()

Return()


Method Existe() Class TBloqueioComercialPedidoVenda
	Local lRet := .F.

	DbSelectArea("UZ7")
	DbSetOrder(1)
	lRet := UZ7->(DbSeek(xFilial("UZ7") + ::cNumPed))

Return(lRet)