#include "PROTHEUS.CH"

/*/{Protheus.doc} MA410VLD
@description Validar o cancelamento e inclusao ou alteracao de pedido
@author Fernando Rocha
@since 25/02/2014
@version undefined
@type function
/*/
User Function MA410VLD           
Local aArea := GetArea()  
Local aOpc := PARAMIXB
Local lRetorno := .T.      
Local cPedido := M->C5_NUM    
Local _cProduto
     
//Cancelando Inclusao de Pedido - Projeto Reserva de OP - Verificar se pedido tem reserva temporaria e excluir
If aOpc[1] == 0 .And. INCLUI .And. !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES","")))

	If Type("n") <> "U" .And. (n > 0)          
	
		_cProduto := Gdfieldget("C6_PRODUTO",1)
		
		If !Empty(_cProduto)
			U_FRRT02EX(cPedido,,_cProduto,"XIN")
		EndIf
	
	EndIf

EndIf

//Exclui Solicitação de Crédito de Pedido de Engenharia, caso seja cancelado a inclusão do Pedido de Venda
If aOpc[1] == 0 .And. INCLUI
	If Type("_FROPCHVTEMPRES") <> "U" .And. !Empty(_FROPCHVTEMPRES)
		SZU->(DbSetOrder(2))
		If SZU->(DbSeek(xFilial("SZU")+_FROPCHVTEMPRES))
			RecLock("SZU",.F.)		
			SZU->(DBDelete())
			SZU->(MsUnlock())			
		EndIf			
	EndIf
EndIf

//Cancelando a tela - qualquer operacao
U_FRRT03CL()

RestArea(aArea)
Return(lRetorno)
