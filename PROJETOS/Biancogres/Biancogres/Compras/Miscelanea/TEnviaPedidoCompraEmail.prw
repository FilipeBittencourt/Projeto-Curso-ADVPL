#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TEnviaPedidoCompraEmail
@author Tiago Rossini Coradini
@since 27/12/2017
@version 1.0
@description Classe para envio de pedidos de compra por e-mail 
@obs Ticket: 1146 - Projeto Demandas Compras - Item 2 - Complemento 1
@type class
/*/

Class TEnviaPedidoCompraEmail From LongClassName
	
	Data cNumPed // Numero do pedido de compra
	Data cTipEnv // Tipo de envio: A=Automatico;M=Manual
	Data cCodFor // Codigo do fornecedor
	Data cLojFor // Loja do fornecedor
	
	Method New() Constructor
	Method Valida() // Valida o envio do pedido
	Method VldEnvAut() // Valida Envio Automatico
	Method VldModVis() // Valida modo de visualização
	Method VldSalEst() // Valida se o pedido possui saldo em estoque
	Method VldPedLib() // Valida se o pedido esta lberado (Aprovado)
	Method VldUsuCom() // Valida se o usuário é um comprador
	Method VldTra() // Valida transportador do pedido
	Method Envia() // Envia o pedido
		
EndClass


Method New() Class TEnviaPedidoCompraEmail
	
	::cNumPed := ""
	::cTipEnv := ""
	::cCodFor := ""
	::cLojFor := ""

Return()


Method Valida() Class TEnviaPedidoCompraEmail
Local lRet := .F.

	If ::cTipEnv == "A"

		lRet := ::VldEnvAut()
						
	ElseIf ::cTipEnv == "M"
		
		lRet := ::VldModVis() .And. ::VldSalEst() .And. ::VldPedLib() .And. ::VldUsuCom() .And. ::VldTra()
		
	EndIf 

Return(lRet)


Method VldEnvAut() Class TEnviaPedidoCompraEmail
Local lRet := .T.
 
	lRet := SC7->C7_YENVAUT == "S" .And. ((AllTrim(FunName()) $ "MATA121/MATA150/MATA161" .And. SC7->C7_CONAPRO == "L") .Or. AllTrim(FunName()) == "MATA094" .Or. Upper(AllTrim(getenvserver())) $ "SCHEDULE###COMP-FERNANDO" .Or. IsInCallsTack("U_BIAFG030"))  
		
Return(lRet)


Method VldModVis() Class TEnviaPedidoCompraEmail
Local lRet := .T.

	If Inclui .Or. Altera
		
		MsgAlert("Somente é permitido enviar o pedido, quando o mesmo estiver sendo vizualizado", "Validação de envio de pedido")
	
		lRet := .F.
		
	EndIf

Return(lRet)


Method VldSalEst() Class TEnviaPedidoCompraEmail
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
		
		MsgAlert("Não é permitido o envio do pedido, pois o mesmo não possui saldo em estoque ou foi eliminado por residuo/encerrado.", "Validação de envio de pedido")
		
		lRet := .F.
		
	EndIf
	 
	(cQry)->(DbCloseArea())

Return(lRet)


Method VldPedLib() Class TEnviaPedidoCompraEmail
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL :=	" SELECT CR_STATUS "
	cSQL +=	" FROM " + RetSqlName("SCR")
	cSQL +=	" WHERE CR_NUM = " + ValToSQL(::cNumPed)
	cSQL +=	" AND D_E_L_E_T_ = '' "
	
	TcQuery cSQL New Alias (cQry)
	
	If (cQry)->CR_STATUS == "02"
	
		MsgAlert("Não é permitido o envio do pedido, pois o mesmo se encontra bloqueado.", "Validação de envio de pedido")
	
		lRet := .F.
	
	EndIf
	
	(cQry)->(DbCloseArea())

Return(lRet)


Method VldUsuCom() Class TEnviaPedidoCompraEmail
Local lRet := .T.
Local cSQL := ""
Local cQry := GetNextAlias()

	cSQL :=	" SELECT Y1_USER "
	cSQL +=	" FROM SY1010 "
	cSQL +=	" WHERE Y1_USER = " + ValToSQL(RetCodUsr())
	cSQL +=	"	AND D_E_L_E_T_ = '' "

	TcQuery cSQL New Alias (cQry)
	
	If Empty((cQry)->Y1_USER)
	
		MsgAlert("Não é permitido o envio do pedido, pois o usuário não tem autorização.", "Validação de envio de pedido")
	
		lRet := .F.
	
	EndIf
	
	(cQry)->(DbCloseArea())

Return(lRet)


Method VldTra() Class TEnviaPedidoCompraEmail
Local lRet := .T.
Local oObj := Nil
	
	oObj := TWTransportadorPedidoCompra():New()
	
	oObj:cNumPed := ::cNumPed
	oObj:lEnvMan := .T.
	
	oObj:Activate()
	
	lRet := oObj:lVldEnvMan 
			
Return(lRet)


Method Envia() Class TEnviaPedidoCompraEmail
Local oObj := Nil

	If ::Valida()
		
		DbSelectArea("SA2")
		DbsetOrder(1)
		SA2->(Dbseek(xFilial("SA2") + ::cCodFor + ::cLojFor))		
				
		oObj := TPedidoCompraEmail():New()
		
		oObj:cNumPed := ::cNumPed
		oObj:cCodApr := Posicione("SCR", 1, xFilial("SCR") + "PC" + PadR(::cNumPed, TamSx3("CR_NUM")[1]) + "01", "CR_USER")
		oObj:cEmailApr := AllTrim(UsrRetMail(Posicione("SCR", 1, xFilial("SCR") + "PC" + PadR(::cNumPed, TamSx3("CR_NUM")[1]) + "01", "CR_USER")))
		oObj:cCodCom := SC7->C7_USER
		oObj:cEmailCom := AllTrim(UsrRetMail(SC7->C7_USER))
		oObj:cCodFor := ::cCodFor
		oObj:cLojFor := ::cLojFor
		oObj:cNomFor := AllTrim(SA2->A2_NOME)
		oObj:cEmailFor := AllTrim(SA2->A2_EMAIL)
		oObj:cCodTra := SC7->C7_YTRANSP
		oObj:cNomTra := Posicione("SA4", 1, xFilial("SA4") + SC7->C7_YTRANSP, "A4_NOME")	
		oObj:cEmailTra := AllTrim(Posicione("SA4", 1, xFilial("SA4") + SC7->C7_YTRANSP, "A4_EMAIL"))		
		oObj:cTipFre := SC7->C7_TPFRETE
		oObj:cEnvTra := SC7->C7_YENVTRA
		oObj:cTipEnv := ::cTipEnv
		oObj:cChave := Upper(HMAC(cEmpAnt + cFilAnt + ::cNumPed, "Bi@nCoGrEs", 1))
		
		oObj:Envia()	
	
	EndIf

Return()