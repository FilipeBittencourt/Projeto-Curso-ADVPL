#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} F200AVL
@author Tiago Rossini Coradini - Facile Sistemas
@since 14/05/15
@version 1.0
@description Utilizado para efeuar a baixa automatica dos titulos provisorios de recebimento antecipado.
@type function
/*/

User Function F200IMP()
Local oRecAnt := TRecebimentoAntecipado():New()
	
	If __lBaixarPr
		U_BIAMsgRun("Processando Recebimentos Antecipados...", "Aguarde!", {|| oRecAnt:BaixarPr() })
	EndIf
	
Return()