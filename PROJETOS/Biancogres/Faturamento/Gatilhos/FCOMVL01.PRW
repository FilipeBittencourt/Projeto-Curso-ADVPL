#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} FCOMVL01
@author Fernando Soares Rocha
@since 22/10/2018
@version 1.0
@description validacoes de regras de pedido de venda - Comercial
@type User Function
/*/
User Function FCOMVL01

	Local lRet := .T.
	Local oRegra := TPedidoVendaRegras():New()

	//Tratamento especial para Replcacao de pedido LM
	If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC") .OR. AllTrim(FunName()) $ GetNewPar("FA_XPEDRQC","FRQCTE01###FRQCRT02")
		Return .T.	
	EndIf

	
	If !Empty(cRepAtu) .And. AllTrim(ReadVar()) == "M->C6_PRODUTO" .And. U_GETBIAPAR("REP_BLQPED",.F.)
		If !(AllTrim(M->C5_YSUBTP) $ "A/M")
            MsgInfo("Inclus�o de pedidos temporariamente bloqueada pelo departamento comercial, exceto pedidos de amostra e mostru�rio","FCOMVL01")
            lRet	:=	.F.
        Endif
	EndIf
	
	__lRep := Type("CREPATU") <> "U" .And. !Empty(CREPATU)
	If (__lRep)
		DbSelectArea('SA3')
		SA3->(DbSetOrder(1))
		If SA3->(DbSeek(XFilial("SA3")+CREPATU))
			If (SA3->A3_YBLQPED == 'S')
				If !(AllTrim(M->C5_YSUBTP) $ "A/M")
                    MsgInfo("Inclus�o de pedidos temporariamente bloqueada pelo departamento comercial, exceto pedidos de amostra e mostru�rio","FCOMVL01")
                    lRet	:=	.F.
                EndIf
			EndIf
		EndIf		
	EndIf


	If lRet .And. ( AllTrim(ReadVar()) == "M->C5_YSUBTP" .OR. AllTrim(ReadVar()) == "M->C6_PRODUTO" )

		oRegra:LoadSC5Mem()
		lRet := oRegra:Validar()

	EndIf

Return(lRet)
