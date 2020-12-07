#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TConfirmacaoManualPedidoCompra
@author Tiago Rossini Coradini
@since 27/12/2017
@version 1.0
@description Classe para confirmacao manuel do recebiemnto do pedido de compra pelo fornecedor 
@obs Ticket: 1445 - Projeto Demandas Compras - Item 2 - Complemento 3
@type class
/*/

Class TConfirmacaoManualPedidoCompra From LongClassName
	
	Data cNumPed // Numero do pedido de compra
	Data cCodFor // Codigo do fornecedor
	Data cLojFor // Loja do fornecedor
	Data nRecNo // Reno do pedido de compra
	
	Method New() Constructor
	Method Valida() // Valida o envio do pedido
	Method VldPedConf() // Valida se o pedido ja foi confirmado
	Method VldModVis() // Valida modo de visualização
	Method VldSalEst() // Valida se o pedido possui saldo em estoque
	Method VldPedLib() // Valida se o pedido esta lberado (Aprovado)
	Method VldUsuCom() // Valida se o usuário é um comprador
	Method Confirma() // Envia o pedido
		
EndClass


Method New() Class TConfirmacaoManualPedidoCompra
	
	::cNumPed := ""
	::cCodFor := ""
	::cLojFor := ""
	::nRecNo := 0

Return()


Method Valida() Class TConfirmacaoManualPedidoCompra
Local lRet := .F.

		lRet := ::VldPedConf() .And. ::VldModVis() .And. ::VldSalEst() .And. ::VldPedLib() .And. ::VldUsuCom()

Return(lRet)


Method VldPedConf() Class TConfirmacaoManualPedidoCompra
Local lRet := .T.
	
	DbSelectArea("SC7")
	DbSetOrder(1)
	If SC7->(DbSeek(xFilial("SC7") + ::cNumPed))		
	
		While !SC7->(Eof()) .And. SC7->C7_NUM == ::cNumPed .And. lRet
		
			If SC7->C7_YCONFIR == "S"
				
				MsgAlert("Não é permitido confimar o pedido, o mesmo ja se encontra confirmado", "Confirmação manual de pedido")
				
				lRet := .F.
				
			EndIf
			
			SC7->(DbSkip())
		
		EndDo()
	
		SC7->(DbGoTo(::nRecNo))
		
	EndIf

Return(lRet)


Method VldModVis() Class TConfirmacaoManualPedidoCompra
Local lRet := .T.

	If Inclui .Or. Altera
		
		MsgAlert("Somente é permitido confirmar o pedido, quando o mesmo estiver sendo vizualizado", "Confirmação manual de pedido")
	
		lRet := .F.
		
	EndIf

Return(lRet)


Method VldSalEst() Class TConfirmacaoManualPedidoCompra
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()
	
	cSQL := " SELECT COUNT(C7_NUM) AS COUNT " 
	cSQL += " FROM "+ RetSQLName("SC7")
	cSQL += " WHERE C7_FILIAL = " + ValToSQL(xFilial("SC7"))
	cSQL += "	AND C7_NUM = " + ValToSQL(::cNumPed)
	cSQL += "	AND C7_FORNECE = " + ValToSQL(::cCodFor)
	cSQL += "	AND C7_LOJA = " + ValToSQL(::cLojFor)
	cSQL += "	AND C7_RESIDUO = '' "
	cSQL += "	AND C7_ENCER = '' "
	cSQL += "	AND (C7_QUANT-C7_QUJE) > 0 "
	cSQL +=	" AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)

	If (cQry)->COUNT == 0
		
		MsgAlert("Não é permitido confirmar o pedido, pois o mesmo não possui saldo em estoque ou foi eliminado por residuo/encerrado.", "Confirmação manual de pedido")
		
		lRet := .F.
		
	EndIf
	 
	(cQry)->(DbCloseArea())

Return(lRet)


Method VldPedLib() Class TConfirmacaoManualPedidoCompra
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL :=	" SELECT CR_STATUS "
	cSQL +=	" FROM " + RetSqlName("SCR")
	cSQL +=	" WHERE CR_NUM = " + ValToSQL(::cNumPed)
	cSQL +=	" AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)
	
	If (cQry)->CR_STATUS == "02"
	
		MsgAlert("Não é permitido confirmar o pedido, pois o mesmo se encontra bloqueado.", "Confirmação manual de pedido")
	
		lRet := .F.
	
	EndIf
	
	(cQry)->(DbCloseArea())

Return(lRet)


Method VldUsuCom() Class TConfirmacaoManualPedidoCompra
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL :=	" SELECT Y1_USER "
	cSQL +=	" FROM SY1010 "
	cSQL +=	" WHERE Y1_USER = " + ValToSQL(RetCodUsr())
	cSQL +=	"	AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	
	If Empty((cQry)->Y1_USER)
	
		MsgAlert("Não é permitido confirmar o pedido, pois o usuário não tem autorização.", "Confirmação manual de pedido")
	
		lRet := .F.
	
	EndIf
	
	(cQry)->(DbCloseArea())

Return(lRet)


Method Confirma() Class TConfirmacaoManualPedidoCompra

	If ::Valida()
		
		If MsgYesNo("Deseja realmente confimar o recebimento do pedido: "+ ::cNumPed + Chr(13) + Chr(10) +;			 
							  " pelo fornecedor: "+ Upper(AllTrim(Posicione("SA2", 1, xFilial("SA2") + ::cCodFor + ::cLojFor, "A2_NOME"))) +"?", "Confirmação manual de pedido")
			
			DbSelectArea("SC7")
			DbSetOrder(1)
			If SC7->(DbSeek(xFilial("SC7") + ::cNumPed))		
			
				While !SC7->(Eof()) .And. SC7->C7_NUM == ::cNumPed
				
					RecLock("SC7")
						
						SC7->C7_YCONFIR := "S"
						SC7->C7_YTPCONF := "M"
						SC7->C7_YCOMCON := RetCodUsr()
						SC7->C7_YDATCON := dDataBase
									
					SC7->(MsUnLock())
					
					SC7->(DbSkip())
				
				EndDo()
			
				SC7->(DbGoTo(::nRecNo))
				
			EndIf
			
		EndIf
				
	EndIf

Return()