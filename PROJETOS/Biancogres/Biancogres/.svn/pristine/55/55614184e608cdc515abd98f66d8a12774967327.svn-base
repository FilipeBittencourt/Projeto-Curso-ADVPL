#include "PROTHEUS.CH"

/*/{Protheus.doc} M440ACOL
@description Ponto de Entrada após a montagem do ACOLS da tela de liberação de pedidos
@author Fernando Rocha
@since 15/03/2017
@version undefined
@type function
/*/
User Function M440ACOL

	Local aArea	:= GetArea()
	Local _nPItem := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_ITEM"})
	Local _nPQLib := aScan(aHeader,{|x| AllTrim(x[2]) == "C6_QTDLIB"})
	Local iX

	//NA Bianco/Incesa checkar se o pedido tem reserva de estoque e preencher a Qtd. Lib Automaticamente
	If AllTrim(CEMPANT) <> "07"

		For iX := 1 To Len(aCols)

			SC0->(DbSetOrder(8))
			If SC0->(DbSeek(XFilial("SC0")+M->C5_NUM+aCols[iX][_nPItem]))
			
				aCols[iX][_nPQLib] := SC0->C0_QUANT

			EndIf

		Next iX

	EndIf

	RestArea(aArea)

Return