#include "TOTVS.CH"

/*/{Protheus.doc} FCTBRT01
@description Funcoes para verificar a origem dos Lancametos Contabeis e buscar o campos da Origem / Usar dentro do PE CT105LOK
@author Fernando Rocha
@since 05/04/18
@version undefined
@type function
/*/

/*/{Protheus.doc} FCTBRTSI
@description Buscar o CLIENTE / SI de acordo com a origem
/*/
User Function FCTBRTSI()

	Local aAreaC5	:= SC5->(GetArea())

	Local cArqOri  := Paramixb[1]
	Local cCmpOri  := Paramixb[2]

	Local cOrigem := AllTrim(FunName())
	Local cCliSi := Space(TamSX3("CT2_ATIVDE")[1])

	//Para rotina de Faturamento Off - garantir o posicionamento do SC5
	If ( cOrigem == "CTBANFS" ) .And. !SD2->(Eof())

		SC5->(DbSetOrder(1))
		SC5->(DbSeek(XFilial("SC5")+SD2->D2_PEDIDO))

	EndIf

	If Type(cArqOri+"->"+cCmpOri) <> "U" .And. !Empty(&(cArqOri+"->"+cCmpOri))

		cCliSi := &(cArqOri+"->"+cCmpOri)

	ElseIf Type("M->"+cCmpOri) <> "U" .And. !Empty(&("M->"+cCmpOri))

		cCliSi := &("M->"+cCmpOri)

	EndIf

	//Para pedidos de venda sem cliente SI / Usar o cliente principal - tem alguns LPs feitos sobre nota de venda comum (Provisao)
	If ( cCmpOri = "C5_YSI" ) .And. Empty(cCliSi)

		cArqOri := "SC5"
		cCmpOri := "C5_NUM"

		If Type(cArqOri+"->"+cCmpOri) <> "U" 

			//Para notas fiscais de saída que o pedido é do tipo “Utiliza Fornecedor”, considerar o cliente AI “000481” para despesas na marca Biancogres e cliente AI “004536” para marca Incesa
			//Solicitacao Claudeir dia 02/07/18
			IF SC5->C5_TIPO == "B"

				if SC5->C5_YLINHA == "1"
					cCliSi := "000481"
				else
					cCliSi := "004536"
				endif			

			Else

				cCliSi := SC5->C5_CLIENTE

			EndIf

		EndIf

	EndIf

	RestArea(aAreaC5)

Return(cCliSi)