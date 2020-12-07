#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TAFBaixaPagar
@author Tiago Rossini Coradini
@since 07/03/2019
@project Automação Financeira
@version 1.0
@description Ponto de entrada para adcionar rotinas no menu do contas a pagar
@type class
/*/

User Function F050ROT()

	Local aRot := If(IsInCallStack("U_FA750BRW"), {}, ParamIxb)
	Local aSubRot := {}

	aAdd(aSubRot, {"Atualizar Dados Bancários - Fornecedor", "U_BAF018", 0, 8})
	aAdd(aSubRot, {"Comprovante", "U_BAF016", 0, 8})
	aAdd(aSubRot, {"Remessa", "U_BAF014", 0, 8})
	aAdd(aSubRot, {"Reenvio Remessa", "U_BAF015", 0, 8})
	aAdd(aSubRot, {"Retorno", "U_BAF019('A')", 0, 8})
	aAdd(aSubRot, {"Baixa", "U_BAF019('B')", 0, 8})
	aAdd(aSubRot, {"Conciliação DDA", "U_BAF019('C')", 0, 8})
	aAdd(aSubRot, {"Retorno Conciliação", "U_BAF019('D')", 0, 8})
	aAdd(aSubRot, {"Historico", "U_BAF017", 0, 8})
	aAdd(aSubRot, {"Rel.Movimento diario", "U_BIA933", 0, 8})

	aAdd(aRot, {"Posição de Títulos a Pagar", "FINC050(2)", 0, 8, 0, NIL})
	aAdd(aRot, {"Automação Financeira", aSubRot, 0, 8, 0, NIL})
	
Return(aRot)