#include "PROTHEUS.CH"

/*/{Protheus.doc} M410ALOK
@description Ponto de Entrada no Pedido de Venda - Ao clicar em Alterar / Excluir ou Copiar
@author Fernando Rocha
@since 25/02/2014
@version 1.0
@type function
@obs revisão em 19/10/2016
/*/
User Function M410ALOK
	Local aArea := GetArea()
	Local lRetorno := .T.
	Local aAreaC6 := SC6->(GetArea())

	//Tratamento especial para Replicacao de reajuste de preço
	If (IsInCallStack("U_M410RPRC")) .OR. (AllTrim(FunName()) == "RPC")
		Return(.T.)
	EndIf

	IF ALTERA .OR. (!ALTERA .And. !INCLUI)  //Alterar ou Excluir

		//Gabriel Rossi Mafioletti - 21/02/2018 - Marcos - Impedir que se altere/exclua/elimine resíduo de pedidos cuja amostra esteja no ecosis
		If !U_BIAFG032(SC5->C5_NUM) .And. Alltrim(SC5->C5_YSUBTP) $ GETNEWPAR("MV_YTIPAMO","A#F#M")

			MsgStop("Atenção, O pedido não poderá ser alterado pois possui amostras enviadas para o Ecosis. Favor proceder com a exclusão das mesmas para poder alterar o pedido!")

			Return(.F.)

		EndIf


		If SC5->C5_TIPO == 'N' .And. !(CEMPANT $ AllTrim(GetNewPar("FA_EMNRES",""))) .And. SC5->C5_YLINHA <> "4"

			lRetorno := U_FROPRT03(SC5->C5_NUM)

		EndIf

	ELSEIF INCLUI .And. !ALTERA  //Copia
		If cEmpAnt <> '06'
			If SC5->C5_CLIENTE = '010064'
				MsgAlert("Não é permitido a cópia de pedido de venda para a LM.","M410ALOK")
				lRetorno := .F.
			EndIf

			If !(AllTrim(SC5->C5_YSUBTP) = 'A')
				MsgAlert("Operação de cópia somente permitida para pedidos de Amostra.","M410ALOK")
				lRetorno := .F.
			EndIf
		EndIf

	ENDIF

	RestArea(aAreaC6)
	RestArea(aArea)
Return(lRetorno)
