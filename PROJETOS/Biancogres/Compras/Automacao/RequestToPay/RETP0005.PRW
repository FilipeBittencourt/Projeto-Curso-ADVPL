#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function RETP0005(_cNum)
	
	Local aArea 		:= GetArea()
	Local lOk			:= .T.
	Local cMsgLog		:= ""
	
	Conout('Executando função: RETP0005')
	
	If (!Empty(_cNum))
		
		oEResPC 	:= TEliminaResiduoPedidoCompra():New()
		oEResPC:Execute(_cNum)
		
		lOk		:= oEResPC:lOk
		cMsgLog	:= oEResPC:cMsgLog
		
		If (lOk)
			MsgAlert('<p style="color:green">Pedido de Compra, Numero: '+_cNum+' eliminado residuo com sucesso.</p>', 'Sucesso')
		Else
			MsgAlert('<p style="color:red">'+cMsgLog+'</p>', 'Erro')
			lRet := .F.
		EndIf
		
	EndIf
	
	RestArea(aArea)
	
Return lOk