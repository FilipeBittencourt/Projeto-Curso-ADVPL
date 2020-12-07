#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF098
@author Tiago Rossini Coradini
@since 19/02/2018
@version 1.0
@description Rotina para chamada da classe de atualização de fornecedor do pedido de compra. 
@obs Ticket: 2599
@type Function
/*/

User Function BIAF098()
Local oObj := Nil

	If fVldPed(SC7->C7_NUM) .And. fVldUsrCom()
	
		oObj := TWAtualizaFornecedorPedidoCompra():New()
		oObj:cNumPed := SC7->C7_NUM
		oObj:Activate()
		
	EndIf

Return()


Static Function fVldPed(cNumPed)
Local lRet := .T.
Local aArea := GetArea()
	
	While !SC7->(Eof()) .And. SC7->C7_NUM == cNumPed .And. lRet
	
		If (SC7->C7_QUJE > 0 .And. SC7->C7_QTDACLA > 0) .Or. SC7->C7_RESIDUO == "S"
	
			lRet := .F.
		
			MsgAlert("Atenção, somente é permitido alterar o forncedor para pedidos em aberto.")
		
		EndIf
		
		SC7->(DbSkip())
		
	EndDo()
	
	RestArea(aArea)
	
Return(lRet) 


Static Function fVldUsrCom()
Local lRet := .F.
Local aArea := GetArea()

	DbSelectArea("SY1")
	DbSetOrder(3)
	If SY1->(DbSeek(xFilial("SY1") + RetCodUsr()))
	
		lRet := .T.
		
	Else
	
		MsgAlert("Atenção, somente compradores tem acesso a alterar o forncedor.")
		
	EndIf
	
	RestArea(aArea)
	
Return(lRet) 