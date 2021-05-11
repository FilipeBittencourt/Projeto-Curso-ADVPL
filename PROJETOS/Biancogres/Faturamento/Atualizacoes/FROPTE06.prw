#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FROPTE06
@description VALIDACAO DO CLIENTE ESCOLHIDO NO PEDIDO DE VENDAS
@author ubens Junior (FACILE SISTEMAS) / Fernando Rocha
@since 14/07/2014
@version 1.0
@type function
/*/
User Function FROPTE06()
	Local lRet := .T.
	Local aArea := GetArea()
	Local cTpDVER	:= AllTrim(GetNewPar("FA_TPEDVDA","N #E #IM#R1#R2#"))
	Local _cEmpDACO := AllTrim(GetNewPar("FA_EMPDACO","01#05#07#"))
	Local oAceTela 	:= TAcessoTelemarketing():New()

//Tratamento especial para Replcacao de pedido LM
	If AllTrim(FunName()) $ GetNewPar("FA_XPEDRPC","BFATRT01###FCOMRT01###BFVCXPED###FCOMXPED###TESTEF1###RPC")
		Return(.T.)
	EndIf

//OS 3494-16 - Tania c/ aprovação do Fabio
	If cEmpAnt == "02"
		Return(.T.)
	EndIf

//Tratamento outros tipos de pedido
	If M->C5_TIPO <> "N" //.Or. Alltrim(M->C5_YSUBTP) == "A" //Retirado validação amostra 2148-16
		Return(.T.)
	EndIf

	// Ticket: 25464 - Automacao JK
	If IsInCallStack("U_JOBFATPARTE") .And. IsBlind()

		Return(.T.)

	EndIf

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE))

		If lRet .And. !Empty(cRepAtu) .And. !(SA1->A1_COD $ "010064")

			If cEmpAnt == "14"
				If Alltrim(M->C5_YLINHA) == "1" //VITCER

					If !(SA1->A1_YVENVT1 == cRepAtu .Or. A1_YVENVT2 == cRepAtu .Or. A1_YVENVT3 == cRepAtu)
						MsgStop("Cliente NÃO permitido para o Representante!","Valida Cliente")
						lRet := .F.
					EndIf

				EndIf
			Else
				If Alltrim(M->C5_YLINHA) == "1" //BIANCOGRES

					If !(SA1->A1_VEND == cRepAtu .Or. A1_YVENDB2 == cRepAtu .Or. A1_YVENDB3 == cRepAtu)
						MsgStop("Cliente NÃO permitido para o Representante!","Valida Cliente")
						lRet := .F.
					EndIf

				ElseIf Alltrim(M->C5_YLINHA) == "2" //INCESA

					If !(SA1->A1_YVENDI == cRepAtu .Or. A1_YVENDI2 == cRepAtu .Or. A1_YVENDI3 == cRepAtu)
						MsgStop("Cliente NÃO permitido para o Representante!","Valida Cliente")
						lRet := .F.
					EndIf

				ElseIf Alltrim(M->C5_YLINHA) == "3" //BELLACASA

					If !(SA1->A1_YVENBE1 == cRepAtu .Or. A1_YVENBE2 == cRepAtu .Or. A1_YVENBE3 == cRepAtu)
						MsgStop("Cliente NÃO permitido para o Representante!","Valida Cliente")
						lRet := .F.
					EndIf

				ElseIf Alltrim(M->C5_YLINHA) == "4" //MUNDIALLI

					If !(SA1->A1_YVENML1 == cRepAtu .Or. A1_YVENML2 == cRepAtu .Or. A1_YVENML3 == cRepAtu)
						MsgStop("Cliente NÃO permitido para o Representante!","Valida Cliente")
						lRet := .F.
					EndIf

				ElseIf Alltrim(M->C5_YLINHA) == "5" //PEGASUS

					If !(SA1->A1_YVENPEG == cRepAtu)
						MsgStop("Cliente NÃO permitido para o Representante!","Valida Cliente")
						lRet := .F.
					EndIf
				ElseIf Alltrim(M->C5_YLINHA) == "6" //VINILICO

					If !(SA1->A1_YVENVI1 == cRepAtu)
						MsgStop("Cliente NÃO permitido para o Representante!","Valida Cliente")
						lRet := .F.
					EndIf
				EndIf


			EndIf
		EndIf


		If (lRet .And. oAceTela:UserTelemaketing() .And. !(SA1->A1_COD $ "010064"))

			If (!oAceTela:CheckSA1Repre(M->C5_CLIENTE, Alltrim(M->C5_YLINHA)))
				MsgStop("Cliente NÃO permitido para o Atendente (Telemaketing) !", "Valida Cliente")
				lRet := .F.
			EndIf

		EndIf



		If (lRet .And. cEmpAnt == '07' .And. cFilAnt == '05' .And. SA1->A1_EST <> "SP")

			//ticket 24588 - exececao de clientes vinilico para fora de SP
			If !( AllTrim(M->C5_CLIENTE) $ AllTrim(AllTrim(GetNewPar("FA_VINSPCL","004072#"))))

				MsgStop("Na filial LM-SP não é possivel realizar vendas para fora do estado de São Paulo!", "Valida Cliente")
				lRet := .F.

			EndIf

		EndIf

		//Fernando - checkar se cliente tem AI em aberto com saldo e dar AVISO para o desconto
		//MANTER POR ULTIMO - AVISO
		If lRet .And. SC6->(FieldPos("C6_YDVER")) > 0 .And. (M->C5_YSUBTP $ cTpDVER)  .And. (AllTrim(CEMPANT) $ _cEmpDACO)

			cAliasTmp := GetNextAlias()
			cQUERY := "exec SP_AI_COM_SALDO_CLIENTE_01 '"+SA1->A1_COD+"','"+SA1->A1_LOJA+"', 1 "
			TcQuery cQUERY New Alias (cAliasTmp)
			_lSaldoDP := .F.
			While !(cAliasTmp)->(eof())
				
				If (AllTrim((cAliasTmp)->FPAGTO) == '2')
					_lSaldoDP := .T.
				EndIf
				
				(cAliasTmp)->(DbSkip())
			EndDo
			
			If (_lSaldoDP)
				MsgInfo("Este cliente tem AI(s) com saldo."+CRLF+"Selecione a AI no campo 'Numero AI'."+CRLF+"Será concecido desconto automaticamente nos produtos.","AUTORIZAÇÃO DE INVESTIMENTO - FROPTE06")
			EndIf
				
			(cAliasTmp)->(DbCloseArea())

		EndIf

	Else
		MsgStop("Cliente não cadastrado!","Valida Cliente")
		lRet := .F.
	EndIf

	RestArea(aArea)
Return lRet
