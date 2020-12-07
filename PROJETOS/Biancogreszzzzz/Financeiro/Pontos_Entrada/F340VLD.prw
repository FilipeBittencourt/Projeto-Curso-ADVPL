#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} F340VLD
@author Marcos Alberto Soprani
@since 14/12/17
@version 1.0
@description Ponto de Entrada que permite validar se um título será ou não compensado.
@obs O motivo da implementação original deste ponto de entrada foi a necessidade de controlar qual titulo deveria estar posicionodo no browser para que a compensação
.    contabilizasse corretamente  
@type function
/*/

USER FUNCTION F340VLD()

	Local lRetComp := .T.

	If MV_PAR02 == 2

		If !SE2->E2_TIPO $ "PA /NDF"

			lRetComp := .F.
			MsgINFO("Para o processo de compensação com fornecedores DIFERENTES somente é permitido estando posicionando em TÍTULOS do TIPO = PA")

		EndIf 

	EndIf

Return lRetComp
