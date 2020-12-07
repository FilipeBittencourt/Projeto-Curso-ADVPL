#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT120FIM
@description Ponto de entrada no final da gravacao do pedido
@author Tiago Rossini Coradini - Facile Sistemas
@since 07/03/16
@version 1.0
@type function
/*/
User Function MT120FIM()

	Local aArea := GetArea()
	Local nOpc := ParamIxb[1]
	Local cA120Num := ParamIxb[2]
	Local nOpcA	:= ParamIxb[3]
	Local cSC7Filial := xFilial("SC7")
	Local cSC7KeySeek	:= (cSC7Filial + cA120Num)
	Local nSC7Order := RetOrder("SC7", "C7_FILIAL+C7_NUM+C7_ITEM")

	If (nOpc == 3 .Or. nOpc == 4) .And. nOpcA > 0

		DbSelectArea("SC7")
		SC7->(DbSetOrder(nSC7Order))
		SC7->(DbSeek(cSC7KeySeek))

		While SC7->(!Eof()) .And. SC7->(C7_FILIAL+C7_NUM) == cSC7KeySeek

			// Atualiza produto x fornecedor
			U_BIAF028(SC7->C7_FORNECE, SC7->C7_LOJA, SC7->C7_PRODUTO, SC7->C7_YPRDFOR)

			SC7->(DbSkip())

		EndDo

		DbSelectArea("SC7")
		SC7->(DbSetOrder(nSC7Order))
		SC7->(DbSeek(cSC7KeySeek))

		//Fernando em 29/06/2018 => Ticket 5309 => Envio de email para aprovação automatica
		//Somente pedido de compra incluso direto pela tela / pode ser tambem via Analise de Cotacao - PE AVALCOPC
		IF (Alltrim(FunName()) == "MATA120" .Or. Alltrim(FunName()) == "MATA121")

			If SC7->(!Eof()) .And. SC7->C7_NUM == cA120Num .And. SC7->C7_CONAPRO == "B" //.And. SC7->C7_EMISSAO >= '20180101'

				dbSelectArea("ZC1")
				If ZC1->(FieldPos("ZC1_TIPDOC")) > 0
					U_FPFCRT01(SC7->C7_NUM)
				ENDIF

			Else

				ConOut( "MT120FIM => ignorando pedido "+SC7->C7_NUM+" -> enviar e-mail aprovação. "+DTOC(dDataBase)+"-"+Time())
			EndIf

		ENDIF

	EndIf

	RestArea(aArea)

Return()