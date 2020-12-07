#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} TLiberacaoComercialPedidoVenda
@author Tiago Rossini Coradini
@since 27/07/2017
@version 1.0
@description Classe para liberação comercial do pedidos de venda 
@obs OS: 4538-16 - Claudeir Fadini
@type class
/*/

Class TLiberacaoComercialPedidoVenda From LongClassName	

	Data cEmp
	Data cFil
	Data cNumPed
	Data cCodApr
	Data lAprTmp
	Data lJob

	Method New() Constructor
	Method Libera()

EndClass


Method New() Class TLiberacaoComercialPedidoVenda

	::cEmp := ""
	::cFil := ""
	::cNumPed := ""
	::cCodApr := ""	
	::lAprTmp := .F.
	::lJob := .F.

Return()


Method Libera() Class TLiberacaoComercialPedidoVenda

	Local aArea := GetArea()

	Local _oEmpAut 		:= Nil
	Local _aRetEmp 		:= Nil
	Local nLinhaEmp		:= Nil
	Local cRetEmp		:= Nil

	If ::lJob

		If cEmpAnt <> ::cEmp 

			RpcClearEnv()

			RpcSetType(3)
			RpcSetEnv(::cEmp, ::cFil)

		EndIf

	EndIf

	ConOut(cValToChar(dDataBase) +"-"+ Time() + " -- TLiberacaoComercialPedidoVenda:Libera() -- Empresa: "+ ::cEmp +" -- Pedido: "+ ::cNumPed + " -- Aprovador: " + ::cCodApr)

	// Rotina de liberação
	DbSelectArea("SC5")
	DbSetOrder(1)	
	If SC5->(DbSeek(xFilial("SC5") + ::cNumPed))

		Reclock("SC5", .F.)

		SC5->C5_YAPROV := UsrRetName(::cCodApr)
		SC5->C5_LIBEROK := ""

		// Aprovador temporario
		If ::lAprTmp

			SC5->C5_YAPRTMP := "S"

		EndIf

		// Altera o tipo do cliente no pedido para nao gerar substituicao tributaria para SP.
		If SC5->C5_TIPOCLI == "S" .And. AllTrim(SC5->C5_YSUBTP) == "A" .And. Posicione("SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_EST") == "SP"				

			SC5->C5_TIPOCLI := "R"

		EndIf			

		SC5->(MsUnlock())

	EndIf

	DbSelectArea("SC6")
	DbSetOrder(1)
	If SC6->(DbSeek(xFilial("SC6") + ::cNumPed))

		While !SC6->(Eof()) .And. SC6->C6_NUM == SC5->C5_NUM       	

			If Alltrim(SC6->C6_BLQ) <> "R"		

				Reclock("SC6", .F.)

				SC6->C6_BLOQUEI := ""
				SC6->C6_BLQ := "N"

				SC6->(MsUnlock())

			EndIf

			SC6->(DbSkip())

		EndDo()

	EndIf

	DbSelectArea("UZ7")
	DbSetOrder(1)
	If UZ7->(DbSeek(xFilial("UZ7") + ::cNumPed))

		Reclock("UZ7", .F.)

		UZ7->UZ7_APROV := UsrRetName(::cCodApr)

		UZ7->(MsUnlock())

	EndIf  


	// Projeto Reserva de OP/Lote - Só enviar o email de pedido apos liberacao das rejeicoes de lote
	If U_FROPVLPV(SC5->C5_NUM, .F., .F.) .And. U_fVlLbDes(SC5->C5_NUM,SC5->C5_YCLIORI)   

		cEmpPed := cEmpAnt

		If !Empty(SC5->C5_YEMPPED)

			cEmpPed := SC5->C5_YEMPPED

		EndIf

		// Controle para não enviar o pedido novamente
		If SC5->C5_YCONF == "S" .And. SC5->C5_YENVIO <> "S" .And. Posicione("SA1", 1, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_YEMAIL") == "S"

			// Envia e-mail do pedido de venda
			U_Env_Pedido(SC5->C5_NUM, .T., .T., cEmpPed, .T.) 

			// Envia e-mail para o atendente		
			U_BIA188()

			// Atualizar data das reservas de acordo com vencimento dodo boleto antecipado
			U_FR2VLRES(SC5->C5_NUM)

		EndIf  

	EndIf

	//Ticket - 9533
	If (AllTrim(::cEmp) == "07")
		DbSelectArea("SC5")
		DbSetOrder(1)	
		If SC5->(DbSeek(xFilial("SC5") + ::cNumPed))
			If (!Empty(SC5->C5_YPEDORI))
				CONOUT("EMAIL - SITUACAO_1 C5_NUM: "+SC5->C5_NUM+", C5_YCONF: "+SC5->C5_YCONF+", C5_YAPROV: "+SC5->C5_YAPROV)

				If (SC5->C5_YCONF == "S")
					SC6->(dbSetOrder(1))
					If (SC6->(DbSeek(xFilial("SC6")+::cNumPed)))
						nLinhaEmp	:= SubStr(SC6->C6_YEMPPED,1,2)+"01"
						cRetEmp 	:= U_FROPCPRO(SubStr(nLinhaEmp, 1, 2),SubStr(nLinhaEmp, 3, 2),"U_XEMPAUPO", SC5->C5_YPEDORI, SC5->C5_YAPROV)
						CONOUT("TLIBERACAOCOMERCIALPEDIDOVENDA (EMAIL) - EMPENHO AUTOMATICO - Pedido: "+SC5->C5_YPEDORI+",  "+cRetEmp)
					EndIf
				EndIf		
			EndIf
		EndIf	
	Else

		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(xFilial("SC5") + ::cNumPed))

			If ( ALLTRIM(SC5->C5_YSUBTP) <> "A" )

				_oEmpAut := TBiaEmpenhoPedido():New()
				_aRetEmp := _oEmpAut:LibPedido(::cNumPed)

				CONOUT("TLIBERACAOCOMERCIALPEDIDOVENDA - EMPENHO AUTOMATICO - Pedido: "+::cNumPed)

				If (!Empty(_aRetEmp[2]))
					CONOUT("TLIBERACAOCOMERCIALPEDIDOVENDA - EMPENHO AUTOMATICO - Alerta empenho automático do pedido: "+_aRetEmp[2])
				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(aArea)

Return()