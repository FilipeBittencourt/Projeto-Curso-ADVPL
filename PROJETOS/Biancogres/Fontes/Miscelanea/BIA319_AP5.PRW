#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

User Function BIA319()

	/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	Autor     := Microsiga Vitoria
	Alterdo   := Ranisses Antonio Corona
	Programa  := BIA319
	Empresa   := Biancogres Ceramicas S/A
	Data      := 15/08/00
	Data Alt. := 07/04/14
	Uso       := Faturamento      
	Aplicação := Libera ou Bloqueia o Pedido de Vendas

	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

	Local aArea    		:= GetArea()
	Local xVetor   		:= paramixb
	Local wOpcao   		:= xVetor[1]
	Local wPedido  		:= xVetor[2] //UZ7->UZ7_PEDIDO 
	Local lLiberar 		:= .F.
	Local lBloquear 	:= .F.
	Local _wnomeaprov	:= Upper(cUserName)
	Local _oEmpAut 		:= Nil
	Local _aRetEmp 		:= Nil
	Local nLinhaEmp		:= Nil
	Local cRetEmp		:= Nil
	Local _NomeAprov	:= Upper(cUserName)


	Do Case
		Case wOpcao == "L"
		lLiberar  := .T.
		Case wOpcao == "B"
		lBloquear := .T.
	EndCase

	If !Empty(Alltrim(UZ7->UZ7_APROV)) .And. lLiberar
		MsgBox("Este pedido já está liberado!","BIA319","ALERT")
		Return
	EndIf

	If UZ7->UZ7_TPCRED == "5" .And. UZ7->UZ7_CRDENG == "03"
		If MsgBox("Este Pedido de Engenharia está aguardando liberação do Setor de Crédito e Cobrança. Deseja cancelar está operação?","BIA319","YesNo")
			Return
		EndIf
	EndIf

	If UZ7->UZ7_TPCRED == "2" .And. U_fVlApCT(wPedido)
		If MsgBox("Este Pedido de Contrato está aguardando liberação do Setor de Crédito e Cobrança. Deseja cancelar está operação?","BIA319","YesNo")
			Return
		EndIf
	EndIf

	//Seleciona ordem 
	If lLiberar
		
		oLibBloq 			:= TLiberacaoBloqueioPedidoVenda():New()
	
		oLibBloq:cEmp 		:= cEmpAnt
		oLibBloq:cFil 		:= cFilAnt
		oLibBloq:cNumPed	:= wPedido
		oLibBloq:cCodAprov	:= __cUserID
		oLibBloq:lAprovTemp	:= (AllTrim(UZ7->UZ7_AAPROV) <> AllTrim(__cUserID) .Or. AllTrim(UZ7->UZ7_AAPROV) <> AllTrim(_NomeAprov))
		oLibBloq:cOrigem	:= 'T'
		oLibBloq:lJob		:= .F.
		oLibBloq:cObs		:= ''
		
		oLibBloq:Liberar()
		
		
		/*//Libera Cabeçalho Pedido
		dbSelectArea("SC5")
		dbSetOrder(1)	
		If DbSeek(xFilial("SC5")+wPedido,.T.)
			Reclock("SC5",.F.)
			SC5->C5_YAPROV  := _wnomeaprov
			SC5->C5_LIBEROK := ""
			If nAusTmp == 1
				SC5->C5_YAPRTMP := "S"
			EndIf
			SC5->(MsUnlock())
		EndIf

		//Libera Itens do Pedido
		dbSelectArea("SC6")
		dbSetOrder(1)
		If dbSeek(xFilial("SC6")+SC5->C5_NUM,.F.)
			While ! Eof() .And. SC6->C6_NUM == SC5->C5_NUM       	

				//Se o pedido estiver eliminado por residuo, não faz nada
				If Alltrim(SC6->C6_BLQ) == "R"		
					SC6->(DbSkip())
					Loop
				EndIf

				Reclock("SC6",.F.)
				SC6->C6_BLOQUEI := "" //Alterado por Ranisses em 11/11/04 - Versão AP7
				SC6->C6_BLQ     := "N"
				SC6->(MsUnlock())  
				SC6->(DbSkip())

			EndDo
		EndIf

		//Libera UZ7 //RANISSES
		dbSelectArea("UZ7")
		Reclock("UZ7",.F.)
		UZ7->UZ7_APROV  := _wnomeaprov
		UZ7->(MsUnlock())  


		_oConfPedVen := TConferenciaPedidoVenda():New(cEmpAnt, cFilAnt, 3, "")
		_oConfPedVen:Checar(wPedido)			

		//Posicionar no Cabecalho do Pedido
		dbSelectArea("SC5")
		DbSeek(xFilial("SC5")+wPedido,.T.)

		//*****************************************************************************************************************************
		//Fernando/Facile em 02/10/2014 - Projeto Reserva de OP/Lote - Só enviaar o email de pedido apos liberacao das rejeicoes de lote
		//*****************************************************************************************************************************
		If U_FROPVLPV(SC5->C5_NUM, .F., .F.) .And. U_fVlLbDes(SC5->C5_NUM,SC5->C5_YCLIORI)   

			//(Thiago - 17/04/15) -> Envitar o envio do pedido errado.
			cEmpPed := cEmpAnt

			If !Empty(SC5->C5_YEMPPED)
				cEmpPed := SC5->C5_YEMPPED
			EndIf

			//09/08/2010 - CRIADO O CAMPO C5_YENVIO PARA CONTROLAR OS PEDIDOS QUE JA FORAM ENVIADOS E NAO ENVIAR NOVAMENTE - FERNANDO
			SEMAIL := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_YEMAIL") // MADALENO
			// If (Substr(SC5->C5_NUM,1,1) = "R") .AND. (SEMAIL = "S") .AND. (SC5->C5_YENVIO <> "S")
			If SC5->C5_YCONF == "S" .AND. SEMAIL = "S" .AND. SC5->C5_YENVIO <> "S"
				U_Env_Pedido(SC5->C5_NUM,.T.,.T.,cEmpPed) 
				//RUBENS JUNIOR (FACILE SISTEMAS) 14/02/14 OS:1801-13		   
				//ENVIAR WORKFLOW PARA O ATENDENTE, REFERENTE A LIBERACAO		
				U_BIA188()

				//Fernando/Facile em 02/09 - atualizar data das reservas de acordo com vencimento dodo boleto antecipado
				U_FR2VLRES(SC5->C5_NUM)	
			Else          
				IF (SC5->C5_YENVIO <> "S") 
					//cTexto := DTOC(dDataBase)+"-"+SUBSTR(Time(),1,5)+" -  Ped.: "+SC5->C5_NUM+" - Tipo: "+SC5->C5_TIPO+" - Aprov: "+Alltrim(SC5->C5_YAPROV)+" - SEMAIL: "+SEMAIL
					//MemoWrite("\PNE\PNE_"+cempant+AllTrim(SC5->C5_NUM)+".TXT", cTexto)
				ENDIF
			EndIf  

		EndIf //Fernando

		*/
		
		/*
		//Ticket - 9533
		If (AllTrim(CEMPANT) == "07" .And. !Empty(SC5->C5_YPEDORI))

			CONOUT("BIA319 - SITUACAO_1 C5_NUM: "+SC5->C5_NUM+", C5_YCONF: "+SC5->C5_YCONF+", C5_YAPROV: "+SC5->C5_YAPROV)

			If (SC5->C5_YCONF == "S")
				SC6->(dbSetOrder(1))
				If (SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM)))
					nLinhaEmp	:= SubStr(SC6->C6_YEMPPED,1,2)+"01"
					cRetEmp		:= U_FROPCPRO(SubStr(nLinhaEmp, 1, 2),SubStr(nLinhaEmp, 3, 2),"U_XEMPAUPO", SC5->C5_YPEDORI, SC5->C5_YAPROV)
					CONOUT("TLIBERACAOCOMERCIALPEDIDOVENDA (BIA319) - EMPENHO AUTOMATICO - Pedido: "+SC5->C5_YPEDORI+",  "+cRetEmp)
				EndIf
			EndIf		
		Else

			//Ticket 12575 - Pedido de Amostra nao gera empenho automatico
			If ( ALLTRIM(SC5->C5_YSUBTP) <> "A" )

				_oEmpAut := TBiaEmpenhoPedido():New()
				_aRetEmp := _oEmpAut:LibPedido(SC5->C5_NUM)

				CONOUT("TLIBERACAOCOMERCIALPEDIDOVENDA - EMPENHO AUTOMATICO - Pedido: "+SC5->C5_NUM)

				If (!Empty(_aRetEmp[2]))
					CONOUT("TLIBERACAOCOMERCIALPEDIDOVENDA - EMPENHO AUTOMATICO - Alerta empenho automático do pedido: "+_aRetEmp[2])
				EndIf	

			EndIf
			
		EndIf
		*/
		
		/*
		_oEmpAut := TBiaEmpenhoPedido():New()
		_aRetEmp := _oEmpAut:LibPedido(wPedido)

		If (!Empty(_aRetEmp[2]))
		CONOUT("BIA319 - EMPENHO AUTOMATICO TELA GERENTE - Alerta empenho automático do pedido: "+_aRetEmp[2])
		EndIf	
		//Fim
		*/

		/*
		//Altera o tipo do cliente no pedido para nao gerar substituicao tributaria para SP.
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.T.)
		IF SA1->A1_EST == 'SP' .AND. SC5->C5_TIPOCLI == 'S' .AND. ALLTRIM(SC5->C5_YSUBTP) == 'A'
			DbSelectArea("SC5")
			RecLock("SC5",.F.)
			SC5->C5_TIPOCLI := 'R'
			SC5->(MsUnlock())  
		ENDIF
		*/
		
	EndIf

	If lBloquear

		dbSelectArea("SC5")
		dbSetOrder(1)
		If DbSeek(xFilial("SC5")+wPedido,.T.)
			Reclock("SC5",.F.)
			SC5->C5_YAPROV := Space(15)
			SC5->(MsUnlock())  
		EndIf

		dbSelectArea("SC6")
		dbSetOrder(1)
		If dbSeek(xFilial("SC6")+SC5->C5_NUM,.F.)
			While ! Eof() .And. SC6->C6_NUM == SC5->C5_NUM

				//Se o pedido estiver eliminado por residuo, não faz nada
				If Alltrim(SC6->C6_BLQ) == "R"		
					SC6->(DbSkip())
					Loop
				EndIf

				Reclock("SC6",.F.)
				SC6->C6_BLOQUEI := "S" //Alterado por Ranisses em 11/11/04 - Versão AP7
				SC6->C6_BLQ     := "S"
				SC6->(DbSkip())

			EndDo
			SC6->(MsUnlock())  
		EndIf
	EndIf

	MsUnLockAll()
	RestArea(aArea)

Return