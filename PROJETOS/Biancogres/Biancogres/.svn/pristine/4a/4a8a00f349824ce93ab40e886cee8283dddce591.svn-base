#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF073
@author Tiago Rossini Coradini
@since 24/04/2017
@version 1.0
@description Rotina para visualizar proposta de engenharia no pedido de venda 
@obs OS: 0274-17 - Camila Brandemburg
@type function
/*/

User Function BIAF073()
	Local aArea := GetArea()
	Local aHAux := aClone(aHeader)
	Local aCAux := aClone(aCols)
	Local nLAux := N
	Local cEmpAtu := cEmpAnt
	Local cEmpNew := If (SC5->C5_YLINHA $ "1_5", "01", "05") //bianco/pegasus

	Local _AlteraBkp := ALTERA
	Local _IncluiBkp := INCLUI

	EmpChangeTable("Z68", cEmpNew, cEmpAtu, 1)
	EmpChangeTable("Z69", cEmpNew, cEmpAtu, 1) 

	DbSelectArea("Z68")
	Z68->(DbSetOrder(1))
	If Z68->(DbSeek(xFilial("Z68") + SC5->C5_YNPRENG))

		U_BFTE01MA("V")

	Else

		MsgInfo("Atenção, o pedido de venda não possui proposta de engenharia.")

	EndIf

	EmpChangeTable("Z68", cEmpAtu, cEmpNew, 1)
	EmpChangeTable("Z69", cEmpAtu, cEmpNew, 1)

	// Restaura aHeader, aCols e linha da tela de pedidos
	aHeader	:= aClone(aHAux)
	aCols := aClone(aCAux)
	n	:= nLAux

	ALTERA := _AlteraBkp
	INCLUI := _IncluiBkp

	RestArea(aArea)

Return()