#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT242TOK
@author Marcos Alberto Soprani
@since 20/02/13
@version 1.0
@description Realiza Validações Adicionais - Desmontagem de Produto
@type function
/*/

User Function MT242TOK()

	Local zlRet := .T.
	Local zVetChk := Acols
	Local zCtaOrig := Space(20)
	Local zxArea := GetArea()
	Local kd

	//  Implementado em 20/02/13 por Marcos Alberto Soprani para auxilio do fechamento de estoque vs movimentações retroativas que poderiam
	// acontecer pelo fato de o parâmtro MV_ULMES necessitar permanecer em aberto até que o fechamento de estoque esteja concluído
	If dEmis260 <= GetMv("MV_YULMES")
		MsgSTOP("Impossível prosseguir, pois este movimento interfere no fechamento de custo!!! Favor verificar com a contabilidade!!!","MT242TOK")
		zlRet := .F.
	EndIf

	zCtaOrig := Alltrim(Posicione("SB1", 1, xFilial("SB1") + cProduto, "B1_CONTA"))
	For kd := 1 to len(zVetChk)

		If !zlRet

			Exit

		Else

			If Alltrim(Gdfieldget("D3_CONTA", kd)) <> zCtaOrig
				MsgSTOP("Somente são permitidas DESMONTAGENS de produtoS utilizando contas contábeis do grupo de Ativo e somente se forem iguais quando comaradas entre produtos de origem e destino. Favor verificar com a controladoria!!!", "MT242TOK")
				zlRet := .F.
			EndIf

		EndIf

	Next kd

	RestArea( zxArea )

Return ( zlRet )
