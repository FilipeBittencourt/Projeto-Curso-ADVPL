#include "PROTHEUS.CH"

/*/{Protheus.doc} MA410COR
@description Criar legendas para pedido de vendas	 
@author Fernando Rocha
@since 15/12/2014
@version undefined
@type function
/*/
User Function MA410COR
Local aArea := GetArea()
Local aCores := PARAMIXB
Local aCoresNew := {}
Local I

AAdd(aCoresNew, {"C5_YCRDENG <> '03' .And. Empty(C5_LIBEROK) .And. Empty(C5_NOTA) .And. Empty(C5_BLQ) .And. (Empty(C5_YCONF) .Or. C5_YCONF=='N')",'BR_CINZA',"Pedido Não Conferido"} )
AAdd(aCoresNew, {"C5_NOTA <> 'XXXXXXXXX' .AND. C5_YCRDENG == '03'",'BR_PINK',"Pedido de Engenharia com Bloqueio de Crédito"} )

For I := 1 To Len(aCores)
     
	AAdd(aCoresNew, aCores[I]) 

Next I

RestArea(aArea)
Return(aCoresNew)