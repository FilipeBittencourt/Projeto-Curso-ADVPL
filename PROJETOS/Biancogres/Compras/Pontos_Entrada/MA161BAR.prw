#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MTA161BUT
@author Tiago Rossini Coradini
@since 25/02/2021
@version 1.0
@description Adiciona botao na rotina de Analise de Cotação 
@type function
/*/

User Function MA161BAR()
Local aButton := {}
	
	aAdd(aButton, {"EDITABLE", {|| U_BIAF002("MATA161")}, "Hist. Preço"})
	SetKey(VK_F9, {|| U_BIAF117() })
	
Return(aButton)
