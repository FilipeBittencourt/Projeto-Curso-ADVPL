#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} A250ARD4
@author Marcos Alberto Soprani
@since 30/08/11
@version 1.0
@description Ponto de entrada para acertar as quantidades contidas no
.            empenho para baixa automática
.             Apontamento de Produção com adicional ao que foi previsto.
.             Faz-se necessário ajustar o empenho previsto para que não per-
.            petue o ganho de produção, quando produz-se uma quantidade a
.            maior com a mesma quantidade empenhada originalmente
@obs ...
@type function
/*/

User Function A250ARD4()

	Local fk
	Local gtArea     := GetArea()
	Local wQtdPallet := 1                         // Menor unidade de pallet a ser requisitada.
	Private _aRetEmp := aClone(PARAMIXB)

	// Implementado em 14/05/15 durante desenvolvimento do programa BIA570 - Apontamento de Produção Aglutinado.
	If Upper(Alltrim(FunName())) == "BIA570" .Or. IsInCallsTack("U_BIAFG120")
		wQtdPallet := kQtddPallet
		wQtdSupLat := kQtddSupLat
	EndIf

	// Implementação efetuada para tratamento EXCLISIVAMENTE do pallet e da caixa. 22/08/12 por Marcos Alberto Soprani
	For fk := 1 to Len(_aRetEmp[1])

		If Substr(_aRetEmp[1][fk][3],1,3) == "104"

			gtRetGrpB1 := Posicione("SB1", 1, xFilial("SB1") + _aRetEmp[1][fk][3], "B1_GRUPO")

			dbSelectArea("SD4")
			dbGoTo(_aRetEmp[1][fk][1])
			_aRetEmp[1][fk][2]  := Round(_aRetEmp[1][fk][2],0)

			// Ajuste efetuado para atender a OS effettivo 4368-16
			If gtRetGrpB1 == "104B"
				_aRetEmp[1][fk][2]  := wQtdPallet
				If Alltrim(_aRetEmp[1][fk][3]) == "1040544"
					_aRetEmp[1][fk][2]  := wQtdSupLat
				EndIf
			EndIf

			// Ajuste efetuado em 06/10/16 para corrigir perda na estrutura prevista para orçamento... Por Marcos Alberto Soprani
			If gtRetGrpB1 == "104A"
				gtB1Conv := Posicione("SB1", 1, xFilial("SB1") + SC2->C2_PRODUTO, "B1_CONV")
				gtD3Qunt := M->D3_QUANT
				_aRetEmp[1][fk][2]  := gtD3Qunt / gtB1Conv  
			EndIf

		EndIf

		// Tratamento implementado em 19/01/15 por Marcos Alberto Soprani para resolver problema de arredondamento durante apontamento de produção de PA com consumo de PP
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1") + Alltrim(_aRetEmp[1][fk][3]) ))
		If SB1->B1_TIPO == "PP"
			_aRetEmp[1][fk][2]  := Round(_aRetEmp[1][fk][2],2)
		EndIf

	Next fk

	RestArea(gtArea)

Return(_aRetEmp)
